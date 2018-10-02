/**
 * Created by aditi.sharma on 9/5/2017.
 */


public with sharing class DCBusinessFlow {
    public static Lead sourceLead ;
    public static Lead duplicateLead = new Lead();
    public static Account duplicateAccount = new Account();
    public static Boolean isLeadDupe = false;
    public static Boolean isAccountDupe = false;
    public static String latestCustomerRequsetType = 'BR';  
    public static String sourceCustomerRequstType = '';

    public static void dcSearchResults(String methodName, Id sourceId, Map <String, Object> searchResults) {
        try {
            system.debug('search result *** ' + searchResults);
            List<Lead> sourceLeadList = new List<Lead>();
            sourceLeadList = LeadsSelector.getLeadRecordOnId(sourceId);

            if(!sourceLeadList.isEmpty()){
                sourceLead = new Lead();
                sourceLead=sourceLeadList[0];

            }
            //load custom setting
             DCMergeRuleEngine.loadMergeConfigRuleData();
            Map<Id, Lead> duplicateMap = new Map<Id, Lead>();
            if (sourceLead != null && !sourceLead.IsDupeProcessed__c) {
                sourceLead.IsDupeProcessed__c = true;
                Id duplicateAccountId;
                duplicateMap = duplicateRecords(searchResults);
                for (string objectType : searchResults.keySet()) {
                    List<Object> duplicateObjects = (List<Object>) searchResults.get(objectType);
                    if (duplicateObjects.size() == 1) {
                        sourceLead.IsDupe__c = true ;
                        //Lead - Leads are duplicates
                        if (objectType == constant.LEAD_PREFIX) {
                            isLeadDupe = true;
                            dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) duplicateObjects[0];
                            duplicateLead = (Lead) result.objectData;
                            if (duplicateMap.containsKey(duplicateLead.id)) {
                                duplicateLead = duplicateMap.get(duplicateLead.id);
                            }
                        }
                        //Account - accounts are duplicates
                        else if (objectType == constant.ACCOUNT_PREFIX) {
                            isAccountDupe = true;
                            dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) duplicateObjects[0];
                            Account duplicateAccount = (Account) result.objectData;
                            duplicateAccountId = duplicateAccount.Id;
                        }
                    } else if (duplicateObjects.size() > 1) {
                        sourceLead.IsDupe__c = true ;
                    }
                }
                duplicateAccount = duplicateAccountId != null?
                        AccountsSelector.getAccountOnId(duplicateAccountId):null;
                system.debug('********* account'+duplicateAccount);
                system.debug('******** lead '+duplicateLead);

                if (isAccountDupe || isLeadDupe) {
                    system.debug('-------isAccountDupe----------'+isAccountDupe);
                    system.debug('-------isLeadDupe----------'+isLeadDupe);
                    system.debug('************** lead for notify ranking'+sourceLead);
                    decision();

                }
                else {
                    system.debug('****************** '+sourceLead.id);
                    DCBusinessFlowHelper.notifyForRanking(sourceLead);
                }
            }
        }catch (Exception ex) {
            system.debug('---------ecx-------- ***'+ex.getMessage());
            system.debug('-------------err------- ***'+ex.getStackTraceString());
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessFlow', 'dcSearchResults', '');
        }

    }

    public static void decision() {
        string decisionFound = '';
        system.debug('I am here in decision ****');
        String finalDecision = '';
        Lead finalLead = new Lead();
        //sourceCustomerRequstType = latestActivityType(sourceLead);
        sourceCustomerRequstType = EventsSelector.eventType(sourceLead);
        latestCustomerRequsetType = EventsSelector.eventType(duplicateLead);
        //automerge
        if(isLeadDupe) {
            system.debug('--------isLeadDupe---------****');
            if(sourceLead.InsertTime__c == duplicateLead.InsertTime__c &&
                    sourceLead.ActivityDateTime__c > duplicateLead.ActivityDateTime__c) {
                system.debug('incoming duplicate lead ****');
                finalDecision = DCMergeRuleEngine.findAutoMergeRule(sourceLead, duplicateLead, null);
                //merge fields
                if(finalDecision==null || finalDecision=='') {

                }
                else {
                    //latestCustomerRequsetType = latestActivityType(duplicateLead);
                    //latestCustomerRequsetType = EventsSelector.eventType(duplicateLead);
                    finalLead = DCObjectMerge.leadToLeadFieldMerge(sourceLead, duplicateLead,false);
                    transferEvent(sourceLead,duplicateLead,finalDecision);
                    DCBusinessFlowHelper.notifyForRanking(finalLead);
                    //transfer events
                    system.debug('************ my event transfer 1');
                    //delete the dupicate lead
                    //deleteDuplicate(duplicateLead);
                    SObjectUnitOfWork.deleteLead(duplicateLead);
                    //DCBusinessFlowHelper.notifyForRanking(finalLead);
                }
            }
            else {
                Boolean isExistingLead = false;
                isExistingLead = sourceLead.InsertTime__c == duplicateLead.InsertTime__c ? false:true;
                system.debug('existing duplicate lead ****');
                finalDecision = DCMergeRuleEngine.findAutoMergeRule(duplicateLead,sourceLead, null);
                system.debug('******* final decision'+finalDecision);
                //merge fields
                if(!(
                        finalDecision==null || finalDecision=='')) {

                }
                else {
                    system.debug('********** exit merge');
                    finalLead = DCObjectMerge.leadToLeadFieldMerge(duplicateLead,sourceLead,isExistingLead);
                    system.debug('********** '+finalLead);
                    transferEvent(duplicateLead,sourceLead,finalDecision);
                    DCBusinessFlowHelper.notifyForRanking(finalLead);
                    //transfer the events
                    system.debug('************ my event transfer 2');

                    //delete the dupicate lead
                    //deleteDuplicate(sourceLead);
                    SObjectUnitOfWork.deleteLead(sourceLead);
                    //DCBusinessFlowHelper.notifyForRanking(finalLead);
                }

            }

        }
        else {
            //account merge
            //1.step - merge the account with lead
            finalDecision = DCMergeRuleEngine.findAutoMergeRule(sourceLead,null,duplicateAccount);
            system.debug('--------finalDecision-------'+finalDecision);
            system.debug('--------duplicateAccount-------'+duplicateAccount);
            if(!(finalDecision==null || finalDecision=='')) {

            }
            else{
                //2. step - merge account fields
                system.debug('^^^^^^^^^^ source Lead'+sourceLead);
                system.debug('^^^^^^^^^^ duplicate account before update'+duplicateAccount);
                sourceLead.isAccountMerge__c = true;
                update sourceLead;
                duplicateAccount = DCObjectMerge.leadtoAccountFieldMerge(duplicateAccount,sourceLead);
                //system.debug('--------duplicateAccount2-------'+sourceLead);
                //update sourceLead;
                convertsourcelead();
                //3. update the fields
                system.debug('^^^^^^^^^^^^^^ modify account'+duplicateAccount);
                update duplicateAccount;
                system.debug('My updated account is>>>>>'+duplicateAccount);


            }
            //4.step transfer opportunity
           // DCBusinessFlowHelper.notifyForRanking(sourceLead);
        }
    }

    //convert the lead to account
    public static void convertsourcelead() {
        //query the opportunity
        List<Opportunity> opportuntyList = OpportunitiesSelector.dupeCheckOpportunities(duplicateAccount);
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(sourceLead.id);
        lc.setAccountId(duplicateAccount.id);
        lc.setConvertedStatus(Constant.LEAD_STAGE_CONVERTED);
        system.debug('*********** opportunity list'+opportuntyList);
        if(opportuntyList != null && !opportuntyList.isEmpty()) {
            if(opportuntyList[0].StageName != Label.ClosedWon) {
                lc.setOpportunityId(opportuntyList[0].id);
                Opportunity opportunityRecord = opportuntyList[0];
                system.debug('*********** '+opportunityRecord);
                system.debug('*********** '+[SELECT Id,Type From Event Where WhatId = :opportuntyList[0].id]);
                List<Event> eventType = [SELECT Id,Type From Event Where WhatId = :opportuntyList[0].id
                ORDER BY CreatedDate DESC Limit 1];
                if(eventType != null && !eventType.isEmpty()) {
                    latestCustomerRequsetType = eventType[0].Type;
                }

                DCObjectMerge.modifyOpportuntiy(sourceLead, opportunityRecord);
            }
            //inactive if opportunity is
            else if(opportuntyList[0].StageName == Label.ClosedWon) {
                //update the closed won opportunity. Make isActive as 'false'
                DCObjectMerge.inActiveOpportunity(opportuntyList[0]);
            }
        }
        Database.LeadConvertResult lcr = Database.convertLead(lc);

    }

    //transfer the event from duplicate lead to source lead
    public static void transferEvent(Lead sourceLead, Lead duplicateLead,String decisionName) {
        List<Event> eventList = new List<Event>();
        system.debug('********** event transfer method');
        system.debug('My current event records'+ [Select id,WhoId,Type From Event Where WhoId=:duplicateLead.id
        ORDER BY CreatedDate DESC]);
        for(Event eventRecord : [Select id,WhoId,Type From Event Where WhoId=:duplicateLead.id
        ORDER BY CreatedDate DESC]) {
            system.debug('inside event loop **********');
            //sourceCustomerRequstType = eventRecord.Type;
            eventRecord.whoId = sourceLead.id;
            eventRecord.Merge_Reason__c = decisionName;
            eventList.add(eventRecord);
        }
        system.debug('updatable event list is'+eventList);
        //update the whoid with source lead id(source might be existing or incoming lead)
        SObjectUnitOfWork.executeUpdateEvents(eventList);
    }

    //this method is used to avoid soql query inside for loop
    public static Map<Id, Lead> duplicateRecords(Map <string, Object> searchResults) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        List<Id> leadIdList = new List<Id>();
        for (string objectType : searchResults.keySet()) {
            List<Object> duplicateObjects = (List<Object>) searchResults.get(objectType);
            if (duplicateObjects.size() == 1 && objectType == constant.LEAD_PREFIX) {
                dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) duplicateObjects[0];
                Lead duplicateLead = (Lead) result.objectData;
                if (duplicateLead != null) {
                    leadIdList.add(duplicateLead.id);
                }
            }
        }
        leadMap = LeadsSelector.leadRecordMap(leadIdList);
        return leadMap;
    }

}