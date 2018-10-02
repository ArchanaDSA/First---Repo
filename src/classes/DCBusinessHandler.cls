/**************************************************************************************
Apex Class Name    : DCBusinessHandler
Version            : 1.0
Created Date       : May 26 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh/Shravan                  05/26/2017              Original Version
*******************************************************************************/
public without sharing class DCBusinessHandler {
    public static Map<String, LeadAccountMapping__c> leadAccountMapping;
    public static Map<String, String> fieldAPIAndLabelMap = new Map<String, String>();
    public static Map<String, String> ruleNameRuleValMap = new Map<String, String>();
    public static Map<String, String> ruleNameAndTritonIdMap = new map<string, string>();
    public static Map<String, String> ruleAndDecisionMap = new Map<String, String>();
    //public static Map<Id, Task> whoIdTaskRecordMap = new Map<Id, Task>();
    public static Map<Id, Event> whoIdEventRecordMap = new Map<Id, Event>();
    //the variale is created to store existing duplicate leads. Not used existing variable to not to break the code
    public static Boolean isFinalDup = false;
    public static List<Lead> incomingDuplicateLeadList;
    public static List<Lead> existingDuplicateLeadList;
    public static List<Account> duplicateExistAccountList;
    public static String ScenarioNum='';

    public static void processDCSearchPlugin(String methodName, Id sourceId, Map <string, Object> searchResults) {
        try {

            system.debug('source lead **** ' + sourceId);
            system.debug('search result *** ' + searchResults);
            //Initialize the merge rules from the custom settings.
            DCRuleEngine.loadMergeConfigRuleData();

            incomingDuplicateLeadList = new List<Lead>();
            existingDuplicateLeadList = new List<Lead>();
            duplicateExistAccountList = new List<Account>();

            Boolean isLeadDupe = false;
            Boolean isAccountDupe = false;
            Map<Id, Lead> duplicateMap = new Map<Id, Lead>();
            List<Id> accountIdList = new List<Id>();

            //Query the sourceLead Record
            Lead sourceLead = LeadsSelector.getLeadOnId(sourceId);
            //sending email for testing purpose. please delete this after testing.
            sendEmail(sourceLead,searchResults);

            //Task latestTaskRecord = TasksSelector.GetLatestTaskOnWhoId(sourceLead.Id);
            //whoIdTaskRecordMap.put(sourceLead.id, latestTaskRecord);
            Event latestEventRecord = EventsSelector.retriveEvent(sourceLead.Id);
            whoIdEventRecordMap.put(sourceLead.id,latestEventRecord);
            if (!sourceLead.IsDupeProcessed__c) {
                //Used for identifying the duplicate incoming lead versus existing lead
                sourceLead.IsDupeProcessed__c = true;
                //Used for identifying the duplicate incoming lead versus existing lead.
                DateTime incomingLeadTime = sourceLead.InsertTime__c;
                //map of id and lead. used in iside for loop to avoid soql query inside loop
                duplicateMap = duplicateRecords(searchResults);
                for (string objectType : searchResults.keySet()) {
                    List<Object> duplicateObjects = (List<Object>) searchResults.get(objectType);
                    // if the duplicate is lead
                    if (duplicateObjects.size() > 0) {
                        sourceLead.IsDupe__c = true ;
                        if (objectType == constant.LEAD_PREFIX) {

                            isLeadDupe = true;
                            for (Object objLead : duplicateObjects) {
                                dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) objLead;
                                Lead duplicateLead = (Lead) result.objectData;
                                if (duplicateMap.containsKey(duplicateLead.id)) {
                                    duplicateLead = duplicateMap.get(duplicateLead.id);
                                    system.debug('**************** '+duplicateLead.InsertTime__c);
                                    system.debug('**************** '+sourceLead.InsertTime__c);
                                    if (duplicateLead.InsertTime__c == incomingLeadTime) {

                                        duplicateLead.IsDupe__c = true;
                                        //duplicateLead.IsDupeProcessed__c = true;
                                        incomingDuplicateLeadList.add(duplicateLead);
                                        system.debug('income lead dupe ******');
                                    } else {
                                        existingDuplicateLeadList.add(duplicateLead);
                                        system.debug('existing dupe ********');
                                    }
                                }
                            }
                        }
                        //if the duplicate is account
                        else if (objectType == constant.ACCOUNT_PREFIX) {

                            isAccountDupe = true;
                            system.debug('account dupe ****' + isAccountDupe);
                            for (Object objAcc : duplicateObjects) {
                                dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) objAcc;
                                Account duplicateAccount = (Account) result.objectData;
                                accountIdList.add(duplicateAccount.Id);
                            }
                        }
                    }
                    //end of for loop
                }
                duplicateExistAccountList = AccountsSelector.getAllAccountOnId(accountIdList);

                system.debug('source dupe ******' + sourceLead.IsDupe__c);
                system.debug('isleaddupe ****' + isLeadDupe);
                system.debug('isaccount dupe *****' + isAccountDupe);
                /*update the source and incoming leads


                 */
                List<Lead> sourceAndIncomingLeadList = new List<Lead>();
                sourceAndIncomingLeadList.addAll(incomingDuplicateLeadList);
                sourceAndIncomingLeadList.add(sourceLead);
                //save isdup and isdupprocessed in database
                SObjectUnitOfWork.ExecuteUpdateLeads(sourceAndIncomingLeadList);



                /*
                //this is commented to test the dc tool ----------
                //Scenario 1:["No Dupe"]
                if (isLeadDupe == false && isAccountDupe == false && existingDuplicateLeadList.size() == 0) {
                    ScenarioNum='SEN#:1';
                    system.debug('Scenario-- 1 *****');
                    DCBusinessHelper.notifyForRanking(new List<Lead>{
                            sourceLead
                    });
                }

                //Scenario 2:["Incoming Lead Dupe","Exisitng Lead Dupe"]
                else if (isLeadDupe && !isAccountDupe) {
                    List<Lead> tempLeadList = new List<lead>();
                    tempLeadList.addAll(incomingDuplicateLeadList);
                    //merge the duplicate incoming lead here.
                    if (incomingDuplicateLeadList != null && incomingDuplicateLeadList.size() > 0) {
                        ScenarioNum='SEN#:2.1';
                        tempLeadList = mergeLeads(sourceLead, incomingDuplicateLeadList);
                        system.debug('Scenario-- 2 ***** 2.1');

                    }
                    //if there is only one existing lead,then merge with incoming Lead and Convert.
                    if (existingDuplicateLeadList != null && existingDuplicateLeadList.size() == 1) {
                        //Sce- incoming soucelead is duplicate with EL.
                        if(incomingDuplicateLeadList.size()==0) {
                            system.debug('Scenario-- 2****** 2.2');
                            ScenarioNum='SEN#:2.2';
                            tempLeadList.add(sourceLead);
                        }
                        ScenarioNum='SEN#:2.3';
                        tempLeadList = mergeLeads(existingDuplicateLeadList[0], tempLeadList);
                        system.debug('Scenario-- 2****** 2.3');

                    }
                    DCBusinessHelper.notifyForRanking(tempLeadList);
                }


                //Scenario 3:["Dupe Account"]
                else if (!isLeadDupe && isAccountDupe) {
                    if (duplicateExistAccountList.size() == 1) {
                        system.debug('Scenario-- 3 ***** 3.1');
                        ScenarioNum='SEN#:3.1';
                        Account existingAccount = duplicateExistAccountList[0];
                        Lead notConvertedLead = convertLead(sourceLead, existingAccount);
                        if (notConvertedLead != null) {
                            DCBusinessHelper.notifyForRanking(new List<Lead>{
                                    notConvertedLead
                            });
                        }
                    }
                    else {
                        //if multple account found set dup as a true
                        sourceLead.isdupe__c = true;
                        update sourceLead;
                        ScenarioNum='SEN#:3.2';
                    }

                }

                //Scenario 4: if incoming lead has "duplicate Lead" ,"dupe accounts" & "Dupe Existing Lead"
                else if (isLeadDupe && isAccountDupe) {
                    List<Lead> tempLeadList = new List<lead>();
                    tempLeadList.addAll(incomingDuplicateLeadList);

                    if (incomingDuplicateLeadList != null && incomingDuplicateLeadList.size() > 0) {
                        ScenarioNum='SEN#:4.1';
                        tempLeadList = mergeLeads(sourceLead, incomingDuplicateLeadList);
                        system.debug('Scenario-- 4 ***** 4.1');

                    }
                    if (existingDuplicateLeadList != null && existingDuplicateLeadList.size() == 1) {
                        ScenarioNum='SEN#:4.2';
                        tempLeadList = mergeLeads(existingDuplicateLeadList[0], tempLeadList);
                        system.debug('Scenario-- 4 ***** 4.2');

                    }
                    if (duplicateExistAccountList != null && duplicateExistAccountList.size() == 1) {
                        system.debug('Scenario-- 4 ***** 4.3');
                        ScenarioNum='SEN#:4.3';
                        //tempLeadList.clear();
                        List<Lead> unconvertedLeadList = new List<Lead>();
                        List<Lead> notifyRankingLeadList = new List<lead>();
                        for (Lead lead : tempLeadList) {
                            Lead notConvertedLead = convertLead(lead, duplicateExistAccountList[0]);
                            //notConvertedLead--->If NO rule matched then retrun the Lead without convert.
                            if (notConvertedLead != null) {
                                notifyRankingLeadList.add(notConvertedLead);
                            }
                        }
                        if (notifyRankingLeadList.size() > 0) {
                            DCBusinessHelper.notifyForRanking(notifyRankingLeadList);
                        }
                    }

                    if (duplicateExistAccountList != null && duplicateExistAccountList.size() != 1) {
                        ScenarioNum='SEN#:4.4';
                        for(Lead leadRec: tempLeadList){
                         //   isFinalDup = true;
                            leadRec.IsDupe__c=true;
                        }
                    }
                    //
                    update tempLeadList;

                }
                //this is commented to  test the lead dc tool----------
                */

            }
        } catch (Exception ex) {
            system.debug('Exception in processDCSearchPlugin ***');
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHandler', 'processDCSearchPlugin', '');
        }

    }

    //******************************** ProcessDCSearchPlugin method Ends here*********************//

    //this method is used to avoid soql query inside for loop
    public static Map<Id, Lead> duplicateRecords(Map <string, Object> searchResults) {
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        List<Id> leadIdList = new List<Id>();
        for (string objectType : searchResults.keySet()) {
            List<Object> duplicateObjects = (List<Object>) searchResults.get(objectType);
            if (duplicateObjects.size() > 0 && objectType == constant.LEAD_PREFIX) {
                for (Object objLead : duplicateObjects) {
                    dupcheck.dc3SearchResult result = (dupcheck.dc3SearchResult) objLead;
                    Lead duplicateLead = (Lead) result.objectData;
                    if (duplicateLead != null) {
                        leadIdList.add(duplicateLead.id);
                    }
                }
            }
        }
        leadMap = LeadsSelector.leadRecordMap(leadIdList);
        return leadMap;
    }

    //This function merges an incoming lead with an existing Lead
    public static List<Lead> mergeLeads(Lead sourceLead, List<Lead> duplicateIncomeLeadList) {
        List<Lead> resultantLeadList = new List<Lead>();
        try {
            //we need the last created lead some time.
            duplicateIncomeLeadList = LeadsSelector.GetSortedLeadsOnActivityDate(duplicateIncomeLeadList);
            system.debug('mergeLeads *******');
            MergeRules rule = MergeRules.None;
            // List<Lead> householdLeadList = new List<Lead>();
            List<Lead> notaDupLeadList = new List<Lead>();
            Map<Lead, MergeRules> mergeLeadRuleMap = new Map<Lead, MergeRules>();
            List<Lead> modifyDupCheckList = new List<Lead>();
            for (Lead leadRecord : duplicateIncomeLeadList) {

                rule = DCRuleEngine.findAutoMergeRule(leadRecord, sourceLead, null);
                system.debug('passing rule ******' + rule);
                if (rule != MergeRules.None) {
                    MergeConvertDecision convertDecision = DCRuleEngine.findAutoMergeDecision(rule, leadRecord, sourceLead, null);
                    system.debug('convertDecision ******' + convertDecision);
                    if (convertDecision == MergeConvertDecision.MergeOrConvert) {
                        mergeLeadRuleMap.put(leadRecord, rule);
                    } else if (convertDecision == MergeConvertDecision.Create) {
                        notaDupLeadList.add(leadRecord);
                    }
                } else {
                    isFinalDup = true;
                    leadRecord.IsDupe__c = true;
                    modifyDupCheckList.add(leadRecord);
                    system.debug('Incoming dupe Lead ***** ' + leadRecord.Id + 'Source Lead: *****' + sourceLead + '-is not merged as it does not meet any Rules.');
                }
            }
            //should be bulkified from here
            List<Lead> duplicateLeads = new List<Lead>();
            List<ID> leadIdList = new List<ID>();
            Map<ID, Lead> leadIdObjMap = new Map<ID, Lead>();
            for (Lead incomingLead : mergeLeadRuleMap.keySet()) {
                if (incomingLead.id != sourceLead.id) {
                    leadIdList.add(incomingLead.ID);
                    leadIdObjMap.put(incomingLead.ID, incomingLead);
                    duplicateLeads.add(incomingLead);
                }

            }

            //List<Task> updateableTasks = new List<Task>();
            //updateableTasks = taskCreation(leadIdList, leadIdObjMap, mergeLeadRuleMap, sourceLead);
            List<Event> modifyEventList = new List<Event>();
            modifyEventList = eventCreation(leadIdList, leadIdObjMap, mergeLeadRuleMap, sourceLead);

            //merge all data from latest lead to the existing lead here.
            system.debug('mergeLeads ***** ProcessAfterMergeorConvert *****');
            DCBusinessHelper.processMergeFields(mergeLeadRuleMap, sourceLead, null, null, null);
            update modifyDupCheckList;
            sourceLead.Program__c = DCBusinessHelper.GetProgramAfterMerge(sourceLead, duplicateLeads);
            //sourceLead.IsDupe__c = false;
            sourceLead.IsDupe__c = isFinalDup;
            //update the Data here...
            //system.debug('********** delete duplicate leads'+duplicateLeads);
            //system.debug('********** update tasks'+updateableTasks);
            //SObjectUnitOfWork.executeLeadMerge(sourceLead, duplicateLeads, updateableTasks);

            //This is used for Testing..
            List<ID> incomingLeadIDList = new List<ID>();
            List<ID> existingLeadIDList = new List<ID>();
            List<ID> existingAccountIDList = new List<ID>();

            for (Lead l : incomingDuplicateLeadList) {
                incomingLeadIDList.add(l.id);
            }
            for (Lead el : existingDuplicateLeadList) {
                existingLeadIDList.add(el.id);
            }
            for (Account acc : duplicateExistAccountList) {
                existingAccountIDList.add(acc.id);
            }


            sourceLead.DuplicateRecordSets__c = 'ScenarioNum[ '+ScenarioNum+' ] Incoming Lead###: [ ' + incomingLeadIDList + ']  Existing Lead###: [ ' +
                    existingLeadIDList + ' ]   Account###:  [ ' + existingAccountIDList + ' ]';

            SObjectUnitOfWork.executeLeadMerge(sourceLead, duplicateLeads, modifyEventList);

            system.debug('mergeLeads******* after delete******');
            resultantLeadList.addAll(notaDupLeadList);
            resultantLeadList.add(sourceLead);
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHandler', 'mergeLeads', '');
        }
        return resultantLeadList;
    }


    public static Lead convertLead(Lead sourceLead, Account existingAccount) {
        try {
            Database.LeadConvert leadConvertRecord = new Database.LeadConvert();
            leadConvertRecord.setLeadId(sourceLead.Id);
            leadConvertRecord.setConvertedStatus(Constant.LEAD_STAGE_CONVERTED); //######move this to Label.

            MergeConvertDecision convertDecision = MergeConvertDecision.Create;
            MergeRules rules = MergeRules.None;
            Boolean isNewAccount = false;
            if (existingAccount == null) {
                convertDecision = MergeConvertDecision.Create;
                isNewAccount = true;
            } else {
                rules = DCRuleEngine.findAutoMergeRule(sourceLead, null, existingAccount);
                if (rules == MergeRules.None) {
                    return sourceLead;
                }
            }
            convertDecision = DCRuleEngine.findAutoMergeDecision(rules, sourceLead, null, existingAccount);

            //Task latestTask = whoIdTaskRecordMap.get(sourceLead.id);
            Event latestEvent = whoIdEventRecordMap.get(sourceLead.id);
            latestEvent.Merge_Reason__c = String.valueOf(rules);
            whoIdEventRecordMap.put(sourceLead.id, latestEvent);

            leadConvertRecord.setAccountId(existingAccount.Id);
            if (convertDecision == MergeConvertDecision.CreateOpportunity) {
                //do dml once method is completed - convert lead is inside a loop. set of task are in global variable
                leadConvertRecord.setOpportunityName(sourceLead.FirstName + ' ' + sourceLead.LastName);
            } else if (convertDecision == MergeConvertDecision.MergeOrConvert) {
                leadConvertRecord.setDoNotCreateOpportunity(true);
            }
            convertLeadandModify(leadConvertRecord, existingAccount, convertDecision, isNewAccount, rules, sourceLead);
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHandler', 'convertLead', '');
        }
        return null;
    }


    public static void convertLeadandModify(Database.LeadConvert leadConvert, Account existingAccount,
            MergeConvertDecision convertDecision, Boolean isNewAccount, MergeRules rules, Lead sourceLead) {
        try {
            //Task latestTask = whoIdTaskRecordMap.get(sourceLead.id);
            Event latestEvent = whoIdEventRecordMap.get(sourceLead.id);
            SObjectUnitOfWork.modifyEvents(new List<Event>{
                    latestEvent
            });

            Database.LeadConvertResult lcr = Database.convertLead(leadConvert);
            if (lcr.isSuccess()) {
                Id accountId = lcr.getAccountId();
                Account convertedAccount = AccountsSelector.getAccountOnId(accountId);
                if (!isNewAccount) {
                    //update all the fields of account from the Lead data based on the Rule.
                    DCBusinessHelper.processMergeFields(null, null, convertedAccount, rules, sourceLead);
                    SObjectUnitOfWork.ExecuteUpdateAccounts(new List<Account>{
                            convertedAccount
                    });
                } else {
                    if (convertDecision == MergeConvertDecision.CreateHoushold) {
                        createRelatedHouseholdRecords(convertedAccount.id, existingAccount.id);
                        DCBusinessHelper.createDCDiscard(convertedAccount.id, existingAccount.id);

                    }
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHandler', 'convertLeadandModify', '');
        }
    }
    //delete this method once the tasks are trasffered to event
    /*public static List<Task> taskCreation(List<Id> leadIdList, Map<Id, Lead> leadIdObjMap,
            Map<Lead, MergeRules> mergeLeadRuleMap, Lead sourceLead) {
        List<Task> updateableTaskList = new List<Task>();
        try {
            List<Task> tasks = TasksSelector.getAllTasksOnLeads(leadIdList);
            for (Task task : tasks) {
                if (leadIdObjMap.containsKey(task.WhoId)) {
                    MergeRules mergeRules = mergeLeadRuleMap.get(leadIdObjMap.get(task.WhoId));
                    task.Merge_Reason__c = String.valueOf(mergeRules);
                }
                task.WhoId = sourceLead.Id;
                updateableTaskList.add(task);
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHandler', 'taskCreation', '');
        }
        return updateableTaskList;
    }*/

    public static List<Event> eventCreation(List<Id> leadIdList, Map<Id, Lead> leadIdObjMap,
            Map<Lead, MergeRules> mergeLeadRuleMap, Lead sourceLead) {
        List<Event> updateableTaskList = new List<Event>();
        try {
            List<Event> eventList = EventsSelector.retriveEventsOnLead(leadIdList);
            for (Event eventRecord : eventList) {
                if (leadIdObjMap.containsKey(eventRecord.WhoId)) {
                    MergeRules mergeRules = mergeLeadRuleMap.get(leadIdObjMap.get(eventRecord.WhoId));
                    eventRecord.Merge_Reason__c = String.valueOf(mergeRules);
                }
                eventRecord.WhoId = sourceLead.Id;
                updateableTaskList.add(eventRecord);
            }
            //Task mapping  - Transfer all task to newly created lead
            /*List<Task> taskMappingList = TasksSelector.getTasksOnWhoIds(leadIdList);
            for(Task taskRecord : taskMappingList) {
                if (leadIdObjMap.containsKey(taskRecord.WhoId)) {
                    MergeRules mergeRules = mergeLeadRuleMap.get(leadIdObjMap.get(taskRecord.WhoId));
                    taskRecord.Merge_Reason__c = String.valueOf(mergeRules);
                }
                taskRecord.WhoId = sourceLead.Id;
            }
            update taskMappingList;*/
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHandler', 'taskCreation', '');
        }
        return updateableTaskList;
    }


    public static void createRelatedHouseholdRecords(ID sourceId, ID destinationId) {
        List<AccountContactRelation> createAccountContactList = new List<AccountContactRelation>();
        List<Id> finalaccountList = new List<Id>();
        try {
            finalaccountList.add(sourceId);
            finalaccountList.add(destinationId);
            for (Contact contactRecord : [select id,accountId from contact where accountId in :finalaccountList]) {
                AccountContactRelation temp = new AccountContactRelation();
                temp.AccountId = contactRecord.accountId;
                temp.ContactId = contactRecord.id;
                createAccountContactList.add(temp);
            }
            insert createAccountContactList;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHandler', 'createRelatedHouseholdRecords', '');
        }
    }


    //delete this method once testing is over.
    public static void sendEmail(Lead leadRecord,Map <string, Object> searchResults) {
        //New instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Who you are sending the email to
        mail.setTargetObjectId(leadRecord.ownerId);
        mail.setSubject('Dupcheck Search Results');
        String finalSearchResult = '';
        for(String objectKey : searchResults.keySet()) {
            finalSearchResult += objectKey + ' - '+string.valueOf(searchResults.get(objectKey));
        }
        mail.setPlainTextBody(finalSearchResult);
        // The email template ID used for the email
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }


    public enum MergeRules {
        None, Rule1, Rule2, Rule3, Rule4, Rule5, Rule6,
        Rule7, Rule8, Rule9, Rule10, Rule11, Rule12,
        Rule13, Rule14, Rule15, Rule16, Rule17, Rule18,
        Rule19, Rule20, Rule21, Rule22, Rule23, Rule24,
        Rule25, Rule26, Rule27, Rule28, Rule29, Rule30,
        Rule31, Rule32, Rule33, Rule34, Rule35, Rule36, Rule37, Rule38
    }

    public enum MergeConvertDecision {
        None,
        Booking,
        Family,
        CreateHoushold,
        MergeOrConvert,
        Create,
        CreateOpportunity
    }

}