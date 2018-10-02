/**
 * Created by thejasvi.a on 8/10/2017.
 */

@isTest(SeeAllData=false)
private class TasksHelperTest {

    static testMethod void testIncomingLeads() {
        //  List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');
        Test.startTest();
        system.runAs(TestDataUtil.createUserRecord()) {
         List<id> oppId= new List<id>();
            List<string> requestTypeValues = new List<string>();
            List<lead> leadListExisting = new list<lead>();
            List<lead> leadList = new list<lead>();
            List<TaskSettings__mdt> customMetadata = [
                    SELECT CanCloseManually__c,CanCreateMannually__c,
                CreateCallType__c,ForClosedCallTypes__c,IsActive__c,RuleForTask__c,
                IsCallType__c,IsTaskPerCustomer__c,Name__c,RuleForActivity__c,
                No__c,RULE__c,TaskGroup__c,Type__c,UpdateCallType__c,TaskSubject__c
                    FROM TaskSettings__mdt order by No__c];

            for (TaskSettings__mdt values: customMetadata) {
                requestTypeValues.add(values.name__c);
            }

            system.debug('>>>>>values' + requestTypeValues);
            List<id> testids= new List<id>();
            List<lead> insertLead=new List<Lead>();
            for (integer i = 0; i <= 6; i++) {
              Lead leadRecord = new Lead();
                system.debug('>>>>>size' + requestTypeValues.size());
                leadRecord = TestDataUtil.DynamicinsertNewLeadRecords('ABC'+i, 'lastname'+i, 'city'+i, 'street'+i, 'karnataka'+i, ' postalcode'+i, '123456'+i, '1234567890'+i, '1234567890'+i, '12345'+i, 'u@gmail.com'+i, 'pppp@gmail.com'+i, 'region'+i, requestTypeValues[i], System.today());
                system.debug('leadList>>>>'+leadList);
                leadList.add(leadRecord);
                
            }
            insert leadList;
            system.debug('>>>>>>>leadList'+leadList);
            List<id> leadId= new List<id>();
            for(lead leadrec :leadList)
            {
            leadId.add(leadrec.id);
            }
            List<Event> eventList =[SELECT Type, WhoId FROM event where whoid in: leadId];
            system.debug('event >>>>'+eventList );

             List<Database.LeadConvert> leadConverts =new List<Database.LeadConvert>();
                for(Lead leadRecord : leadList){                    
                    
                        Database.LeadConvert leadConversion = new database.LeadConvert();
                        leadConversion.setLeadId(leadRecord.Id);
                        leadConversion.setConvertedStatus(System.Label.LeadStageConverted);
                        leadConversion.setOpportunityName(leadRecord.FirstName + ' ' + leadRecord.LastName);
                        leadConverts.add(leadConversion);
                    
                }
                
              if(!leadConverts.isEmpty()){
              system.debug('inside conversion');
                    for(Integer i = 0; i <= leadConverts.size()/100 ; i++){
                        list<Database.LeadConvert> tempList = new list<Database.LeadConvert>();
                        Integer startIndex = i*100;
                        Integer endIndex = ((startIndex+100) < leadConverts.size()) ? startIndex+100: leadConverts.size();
                        for(Integer j=startIndex;j<endIndex;j++){
                            tempList.add(leadConverts[j]);
                        }
                        Database.LeadConvertResult[] leadConvertedList = Database.convertLead(tempList, false);
                        //system.debug('>>>leadConvertedList '+leadConvertedList.getOpportunityId );
                         for(Database.LeadConvertResult lcr : leadConvertedList ){
                         System.assert(lcr.isSuccess());
                         system.debug('lcr>>>'+lcr.getOpportunityId());                        
                         oppId.add(lcr.getOpportunityId());
                            }                        
                    }
                }
        List<Id> oppsId= new List<Id>();
        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE id in: oppId];
        for(opportunity opp:opQuery) {
        oppsId.add(opp.id);        
        }
        system.debug('My ids are@@@@@'+oppsId);
        List<Task> taskList =[SELECT Type, WhatId, whoid FROM task where whatid in : oppsId order by type];
        system.debug('>>>>opQuery'+opQuery);
        system.debug('>>>>taskListtej'+taskList );
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);
        system.assertEquals('MCR', taskList[0].Type);
        system.assertEquals('SPQ', taskList[1].Type);
        system.assertEquals('SBR', taskList[2].Type);
        system.assertEquals('SBR', taskList[3].Type);
        system.assertEquals('SBR', taskList[4].Type);
        system.assertEquals('SBR', taskList[5].Type);
        system.assertEquals('SBR', taskList[6].Type);
        system.assertEquals('SBR', taskList[7].Type);
        system.assertEquals('TCC', taskList[8].Type);
        system.assertEquals('TCC', taskList[9].Type);
        }
        Test.stopTest();
    }

  
    Static testMethod void checkBrochureRequest()
    {
       
        system.runAs(TestDataUtil.createUserRecord()) {
        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'AY', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '9988776666', '9988776666', '9988776666', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','APP','BR','karnataka',False,'India');
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

        test.startTest();

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        test.stopTest();

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid FROM task where whatid in : opQuery ORDER BY type];
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);
        system.debug('>>>>taskList'+taskList);
        //system.debug('>>>>taskList'+taskList.Type);
        system.assertEquals('SBR', taskList[0].Type);
        system.assertEquals('TCC', taskList[1].Type);
        //system.assertEquals('AY', opQuery[0].program__c);


    }
    }

    Static testMethod void checkDoNotCall()
    {
      system.runAs(TestDataUtil.createUserRecord()) {
        List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'ILSU', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '9988776666', '9988776666', '9988776666', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','ILS','BR','karnataka',TRUE, 'India');
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

        test.startTest();

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        test.stopTest();

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task>  taskList =[SELECT Type, WhatId, whoid FROM task where whatid in: opQuery ORDER BY type];
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);
        system.debug('>>>>taskList'+taskList);
        system.assertEquals('SBR', taskList[0].Type);
        //system.assertEquals('ILSU', opQuery[0].Program__c);      
    }
    }

    Static testMethod void checkAddress()
    {
    
      system.runAs(TestDataUtil.createUserRecord()) {
      test.startTest();
        List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'AY', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '9988776666', '9988776666', '9988776666', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','APP','BR','karnataka',false,'India');
        insert leadRecord;
        Event eventList =[SELECT Type,Program__c, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);
        system.assertEquals('AY', eventList.Program__c);

        

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid FROM task where whatid in: opQuery ORDER BY type];
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);
        system.debug('>>>>opQuery'+opQuery);

        system.debug('>>>>taskList'+taskList);
        system.assertEquals('SBR', taskList[0].Type);
        system.assertEquals('TCC', taskList[1].Type);
        test.stopTest();
    }
    
    }

    Static testMethod void checkPhone()
    {
     system.runAs(TestDataUtil.createUserRecord()) {
      test.startTest();
        List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'ILSU', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '', '', '', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','ILS','BR','karnataka',false,'India'); 
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

       

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


       

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid FROM task where whatid in: opQuery ORDER BY type];
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);                    
        List<Event> eventsList = TestDataUtil.createEvents(opQuery);
        System.debug('new event list>>>>>'+eventsList);
        insert eventsList;
        System.debug('new event list'+eventsList);
        system.assertEquals('SBR', taskList[0].Type);
        system.debug('>>>>taskList'+taskList);
       // system.assertEquals('ILSU', opQuery[0].Program__c);
        test.stopTest();
    }
    }

   
    Static testMethod void checkClosedSBR()
    {
      system.runAs(TestDataUtil.createUserRecord()) {
      test.startTest();     
     List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'ILSH', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '', '', '', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','ILS','BR','karnataka',false,'India'); 
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

        

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid,status FROM task where whatid in: opQuery ORDER BY type];
        List<Task> addingTask= new List<Task>();
        for(Task taskRecord: taskList){
        taskRecord.status='completed';
        taskRecord.isclosed__c=true;
        addingTask.add(taskRecord);
        }
        update addingTask;
        system.debug('addingTask>>>>>'+addingTask);
                
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);
                     
        List<Event> eventsList = TestDataUtil.createEvents(opQuery);
        System.debug('new event list>>>>>'+eventsList);
        insert eventsList;
        System.debug('new event list'+eventsList);
       // system.assertnotEquals('SBR', taskList[0].Type);
        //system.assertEquals('SBR', taskList[0].Type);
        system.debug('>>>>taskList'+taskList);
       // system.assertEquals('ILSU', opQuery[0].Program__c);
       test.stopTest();

    }
    }
    Static testMethod void checkCallDone()
    {
        Map<String,TaskSettings__mdt> TaskSettingMap=MetaDataSelector.getTaskSettingMetada(); 
        system.runAs(TestDataUtil.createUserRecord()) {
      test.startTest(); 
      List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'ILSU', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '5689632140', '1234520123', '6574896321', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','ILS','BR','karnataka',false,'India'); 
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

        

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid,status FROM task where whatid in: opQuery ORDER BY type];
        List<Task> addingTask= new List<Task>();
        for(Task taskRecord: taskList){
        if(taskRecord.type=='TCC'){
        taskRecord.ActivityDate= Utility.ConvertDateTimeTodate(Datetime.now());
        addingTask.add(taskRecord);
        }
        
        }
        update addingTask;
                
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);               
        List<Event> eventsList = TestDataUtil.createEvents(opQuery);
        System.debug('new event list>>>>>'+eventsList);
        insert eventsList;
        System.debug('new event list>>>>2'+eventsList);
       // system.assertEquals('SBR', taskList[0].Type);
       List<Task> tasksList =[select id,type from task where id in : taskList order by type ];
       System.assertEquals(tasksList.size(),2);
       system.assertEquals('SBR', tasksList[0].Type);
       system.assertEquals('TCC', tasksList[1].Type);
        //system.debug('>>>>taskList'+taskList);
       // system.assertEquals('ILSU', opQuery[0].Program__c);
    test.stopTest();

    }
    }
    
     Static testMethod void checkSBR()
    {
      system.runAs(TestDataUtil.createUserRecord()) {
      test.startTest();     
     List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'ILSU', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '', '', '', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','ILS','BR','karnataka',false,'India'); 
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

        

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid,status FROM task where whatid in: opQuery ORDER BY type];
        List<Task> addingTask= new List<Task>();
        for(Task taskRecord: taskList){
        taskRecord.status='completed';
        taskRecord.isclosed__c=true;
        addingTask.add(taskRecord);
        }
        update addingTask;
        system.debug('addingTask>>>>>'+addingTask);
                
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);
                     
        List<Event> eventsList = TestDataUtil.createEvents(opQuery);
        System.debug('new event list>>>>>'+eventsList);
        insert eventsList;
        System.debug('new event list'+eventsList);
       system.assertEquals('SBR', taskList[0].Type);
        //system.assertEquals('SBR', taskList[0].Type);
        system.debug('>>>>taskList'+taskList);
       // system.assertEquals('ILSU', opQuery[0].Program__c);
       test.stopTest();

    }
    }
    Static testMethod void checkCallTypeClosed()
    {
       
       system.runAs(TestDataUtil.createUserRecord()) {
      test.startTest(); 
      Map<String,TaskSettings__mdt> TaskSettingMap=MetaDataSelector.getTaskSettingMetada(); 
      List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'ILSU', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '5689632140', '1234520123', '6574896321', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','ILS','BR','karnataka',false,'India'); 
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

        

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid,status FROM task where whatid in: opQuery ORDER BY type];
        List<Task> addingTask= new List<Task>();
        for(Task taskRecord: taskList){
        if(taskRecord.type=='TCC'){
        taskRecord.status='Completed';
        taskRecord.isclosed__c=True;
        addingTask.add(taskRecord);
        }
        
        }
        update addingTask;
                
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);               
        List<Event> eventsList = TestDataUtil.createEvents(opQuery);
        System.debug('new event list>>>>>'+eventsList);
        insert eventsList;
        System.debug('new event list>>>>2'+eventsList);
       // system.assertEquals('SBR', taskList[0].Type);
       List<Task> tasksList =[select id,type from task where id in : taskList order by type ];
       System.assertEquals(tasksList.size(),2);
       system.assertEquals('SBR', tasksList[0].Type);
       system.assertEquals('TCC', tasksList[1].Type);
        //system.debug('>>>>taskList'+taskList);
       // system.assertEquals('ILSU', opQuery[0].Program__c);
    test.stopTest();

    }
    }
    
    Static testMethod void checkPQ()
    {
       
       system.runAs(TestDataUtil.createUserRecord()) {
      test.startTest(); 
      Map<String,TaskSettings__mdt> TaskSettingMap=MetaDataSelector.getTaskSettingMetada(); 
      List<MarketProgramLevelSetting__c> newLeads = Test.loadData(MarketProgramLevelSetting__c.sObjectType, 'File_MarketProgramLevelSetting');

        Lead leadRecord = TestDataUtil.createDynamicLeads('Cole', 'Swain', 'Region', 'ILSU', 'DEB', ' DEB', 'street1', 'Bangalore', 'triton id123', '560048', '5689632140', '1234520123', '6574896321', system.today(),'StudentEmail1@email.com','StudentEmail2@email.com','ILS','BR','karnataka',false,'India'); 
        insert leadRecord;

        Event eventList =[SELECT Type, WhatId, whoid FROM event where whoid =: leadRecord.id];
        system.debug('>>>Type'+eventList.Type);

        

        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(leadRecord.id);

        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());

        lc.setOpportunityName('Cole Swain');


        

        List<opportunity> opQuery = [SELECT id, name,Program__c  FROM opportunity WHERE name = 'Cole Swain'];
        List<Task> taskList =[SELECT Type, WhatId, whoid,status FROM task where whatid in: opQuery ORDER BY type];
        List<Task> addingTask= new List<Task>();
        for(Task taskRecord: taskList){
        if(taskRecord.type=='TCC'){
        //taskRecord.status='Completed';
        //taskRecord.isclosed__c=True;
        addingTask.add(taskRecord);
        }
        
        }
        update addingTask;
                
        system.debug('>>>>opQuery'+opQuery);
        List<Id> Ids=new List<Id>();
        for( Opportunity oppRecord:opQuery)
        {
            Ids.add(oppRecord.Id);
        }
        TasksHelper.convertActivitiesToTask( Ids);               
         List<Event> eventsList = new List <Event>();
        for(Opportunity opp: opQuery)
        {
            Event eventRecord = new Event();
            eventRecord.Subject='test';
            eventRecord.StartDateTime=system.now();
            eventRecord.EndDateTime=system.today().adddays(4);
            eventRecord.whatid=opp.id;
            eventRecord.Type='PQ';
            eventsList.add(eventRecord);
        }
        insert eventsList;
        System.debug('new event list>>>>2'+eventsList);
       // system.assertEquals('SBR', taskList[0].Type);
       List<Task> tasksList =[select id,type from task where id in : taskList order by type ];
       System.assertEquals(tasksList.size(),2);
      // system.assertEquals('SBR', tasksList[0].Type);
      // system.assertEquals('TCC', tasksList[1].Type);
        //system.debug('>>>>taskList'+taskList);
       // system.assertEquals('ILSU', opQuery[0].Program__c);
    test.stopTest();

    }
    }
        
}