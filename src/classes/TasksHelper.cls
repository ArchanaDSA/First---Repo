/*************************************************************************************
Apex Class Name    : TasksHelper
Version            : 1.0
Created Date       : August 04 2017
Function           :
Modification Log   :We will delete this class after merging code
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Arjun                  08/04/2017              Original Version
*******************************************************************************/

Public   class TasksHelper {

    public enum CustomerActivities {
        BR, PQ, BKN, CNT, CALL, EXPRESS_CALL, CAM, CAM_BR
    }
    public enum SalesTasks {
        TCC, UCC, FUP, FUA, SPQ, SBR, MCR, PTS, CLOSEDCALL, OPENCALL
    }

    public enum SObjectName {
        LEAD, OPPORTUNITY, TASK, ACCOUNT
    }

    public enum TaskActivityType {
        CUSTOMERREQUEST, TASK
    }

    public enum SaveType {
        INSERTDATA, UPDATEDATA, CLOSEDINSERT
    }
    public static Opportunity oppRecord;
    public static Lead leadrecord;
    public static Event eventrecord;

    public static List<Task> TasksForActivitiesList = new List<Task>();
    public static Id EventId;
    public static Map<String, TaskSettings__mdt> taskSettingsMap = MetaDataSelector.getTaskSettingMetada();

    public static void convertActivitiesToTask(List<Id> parentIdList)
    {
        Id parentId;
        Map<Id, List<Task>> currentTaskMap =new Map<Id, List<Task>>();
        Map<Id, List<Event>> activityList =new Map<Id, List<Event>>();
        Map<Id, Opportunity> parentopportunityMap=new Map<Id, Opportunity> ();
        List<Event> eventsToUpdateList = new List<Event>();

        system.debug('events First Line:parentIdList-'+parentIdList);
        if (parentIdList.size() > 0) {
            //Map<Id, Lead> parentLeadMap = LeadsSelector.leadRecordMap(parentIdList);
            for (Opportunity opportunityRecords : OpportunitiesSelector.getAllEventsAndTasksforOpportunity(parentIdList)) {
                currentTaskMap.put(opportunityRecords.id, opportunityRecords.tasks);
                activityList.put(opportunityRecords.id,opportunityRecords.events);
                parentopportunityMap.put(opportunityRecords.id,opportunityRecords);
            }

            system.debug('--------currentTaskMap---------'+currentTaskMap);
            system.debug('--------activityList---------'+activityList);
            system.debug('--------parentopportunityMap---------'+parentopportunityMap);

            //Here we will get mix of LEAD and opportunity records
            //Here we are getting all the activities for parent
            //activityList = EventsSelector.getAllActivities(parentIdList);
            //system.debug('events size:'+ activityList.size());
            //taskSettingsMap = getTaskSettings();
            //Here we are getting all the tasks for parent

            //########Commented by suresh..why u need this ???*********
            //currentTaskMap = TasksSelector.getAllTasksForparent(parentIdList) ;

            try {
                for(id parentIds: activityList.keySet())
                {
                    for (Event parentActivity : activityList.get(parentIds)) {
                        eventrecord=parentActivity;
                        EventId = parentActivity.Id;
                        system.debug('events Id is:'+ parentActivity.Id);
                        //Here we are processing record by record for parent object(LEAD/OPPORTUNITY
                        //parentId = parentActivity.whatId != null ? parentActivity.whatId : parentActivity.WhoId;

                        Map<string, List<Task>> filterTaskTypeForParentMap = new Map<String,List<Task>>();
                        //leadrecord = parentLeadMap.containsKey(parentId) ? parentLeadMap.get(parentId) : null;
                        oppRecord = parentopportunityMap.containsKey(parentIds) ? parentopportunityMap.get(parentIds) : null;

                        //Filter tasks based on task type
                        if (currentTaskMap.containsKey(parentIds))
                            filterTaskTypeForParentMap = filterTaskTypeTaskForparent(currentTaskMap.get(parentIds), parentActivity.Program__c);

                        //Here we are collecting all the tasks which are to be saved(Insert/Update)
                        TasksForActivitiesList.addAll(saveActivityDataToTask(filterTaskTypeForParentMap, parentActivity));
                        parentActivity.ProcessedforTaskcreation__c = true;
                        eventsToUpdateList.add(parentActivity);

                    }}
                if (TasksForActivitiesList.size() > 0) {
                    system.debug('TasksForActivitiesList.size()'+TasksForActivitiesList);
                    SObjectUnitOfWork.saveTasks(TasksForActivitiesList);
                    //Here we are Marking Field on Events as ProcessedforTaskcreation__c=true;
                    SObjectUnitOfWork.modifyEvents(eventsToUpdateList);
                }
            } catch (exception ex) {
                system.debug('--------Exception---------'+ex.getStackTraceString());
                ExceptionHandler.errorLog(ex.getMessage(), ex.getStackTraceString(),
                        'TaskArjun', 'convertActivitiesToTask', EventId);
            }

        }

    }

    //Filter Tasks Types for parent using Map Ex:(SBR,List<3 SBR Tasks>)

    //Get the MetaData Values from Metadata Types
    public static Map<string, TaskSettings__mdt> getTaskSettings()
    {
        return MetaDataSelector.getTaskSettingMetada();
    }

    //Filter Tasks Types for parent using Map Ex:(SBR,List<3 SBR Tasks>)
    public static Map<string, List<Task>> filterTaskTypeTaskForparent(List<Task> currentParentTaskList,
            string CurrentProgram)
    {
        Map<string, List<Task>> currentParentTaskMap = new Map<string, List<Task>>();


        List<Task> brochureRequestTaskList = new List<Task>();
        List<Task> priceQuoteTaskList = new List<Task>();
        List<Task> taskClosedList = new List<Task>();
        List<Task> taskOpenList = new List<Task>();
        for (Task ParentTask:currentParentTaskList) {

            if ((ParentTask.Type == SalesTasks.TCC.name()
                    || ParentTask.Type == SalesTasks.FUA.name()
                    || ParentTask.Type == SalesTasks.FUP.name()
                    || ParentTask.Type == SalesTasks.UCC.name())) {

                //system.debug('Parent Task List Size is:'+taskList.size());
                if (ParentTask.IsClosed__c)
                    taskClosedList.add(ParentTask); else
                        taskOpenList.add(ParentTask);


            } else if (ParentTask.Type == SalesTasks.SBR.name() && CurrentProgram == ParentTask.Program__c) {
                brochureRequestTaskList.add(ParentTask);
            } else if (ParentTask.Type == SalesTasks.SPQ.name()) {
                priceQuoteTaskList.add(ParentTask);
            }


        }
        if (taskClosedList.size() > 0) {
            currentParentTaskMap.put(SalesTasks.CLOSEDCALL.name(), taskClosedList);
        }
        if (taskOpenList.size() > 0) {

            currentParentTaskMap.put(SalesTasks.OPENCALL.name(), taskOpenList);
        }
        if (brochureRequestTaskList.size() > 0) {
            currentParentTaskMap.put(SalesTasks.SBR.name(), brochureRequestTaskList);
        }
        if (priceQuoteTaskList.size() > 0) {
            currentParentTaskMap.put(SalesTasks.SPQ.name(), priceQuoteTaskList);
        }
           /* system.debug('Parent has related tasks:'+currentParentTaskMap.size());*/



        return currentParentTaskMap;
    }

    //This will return an List to upsert based on rules and condition
    public static List<Task> saveActivityDataToTask(
            Map<string, List<Task>> currentTasksOfParentMap,
            Event parentActivity)
    {
        List<Task> upserTasksRecordList = new List<Task>();

        system.debug('saveActivityDataToTask ');
        if (taskSettingsMap.containsKey(parentActivity.Type)) {

            TaskSettings__mdt objCurrentType = taskSettingsMap.get(parentActivity.Type);
            Map<string, string[]> saveTypeMap = returnTaskToSave(objCurrentType);
            upserTasksRecordList = finalTaskListToSave
                    (saveTypeMap,
                            currentTasksOfParentMap,
                            parentActivity, null);
        }

        return upserTasksRecordList;

    }

    //Here we get array of task types to save for perticular request(Event/Task)
    public static Map<string, string[]> returnTaskToSave(TaskSettings__mdt objCurrentType)
    {
        Map<string, string[]> retcallTypeMap = new Map<string, string[]>();
        system.debug('It is:' + objCurrentType.Type__c);
        string taskSettingsValues = '';
        if (!String.isBlank(objCurrentType.CreateCallType__c)) {
            taskSettingsValues = objCurrentType.CreateCallType__c;
            //Add is Active Condition
            String[] createcalltypearray = utility.splitString(taskSettingsValues, '|');
            retcallTypeMap.put(SaveType.INSERTDATA.name(), createcalltypearray);
        }
        if (!String.isBlank(objCurrentType.UpdateCallType__c)) {
            taskSettingsValues = objCurrentType.UpdateCallType__c;
            String[] updatecalltypearray = utility.splitString(taskSettingsValues, '|');
            system.debug('UPDATEDATA Tasks are:' + taskSettingsValues);
            retcallTypeMap.put(SaveType.UPDATEDATA.name(), updatecalltypearray);
        }
        if (!String.isBlank(objCurrentType.ForClosedCallTypes__c)) {
            taskSettingsValues = objCurrentType.ForClosedCallTypes__c;
            String[] closedcalltypearray = utility.splitString(taskSettingsValues, '|');
            retcallTypeMap.put(SaveType.CLOSEDINSERT.name(), closedcalltypearray);
        }
        return retcallTypeMap;
    }

    //This Method returns list to tasks to be saved for perticular request
    public static List<Task> finalTaskListToSave(Map<string, string[]> TypeToSave,
            Map<string, List<Task>> currentParentTaskMap,
            Event RequestEventObject, Task RequestTaskObj)
    {

        Boolean isClosedOpportunity = true;
        String currentrequestprogram = RequestEventObject != null ? RequestEventObject.Program__c : RequestTaskObj.Program__c;

        List<Task> taskList = new List<Task>();


        System.debug('finalTaskListToSave ');
        if (TypeToSave.containsKey(SaveType.INSERTDATA.name())) {
            string[] insertTypeCalls = TypeToSave.get(SaveType.INSERTDATA.name());
            Boolean hasCallTask = false;
            Boolean cancreateTask = false;
            Task newTask = new Task();
            system.debug('insertTypeCalls'+insertTypeCalls);
            for (string typeoftask:insertTypeCalls) {
                if (taskSettingsMap.containsKey(typeoftask.trim())) {

                    TaskSettings__mdt objtskSettingMap = taskSettingsMap.get(typeoftask);

                    if (objtskSettingMap.IsTaskPerCustomer__c) {
                        system.debug('typeoftask to save objtskSettingMap.IsTaskPerCustomer__c'+typeoftask +objtskSettingMap.IsTaskPerCustomer__c);
                        if (currentParentTaskMap!=null
                                &&currentParentTaskMap.size()>0
                                &&currentParentTaskMap.containsKey(SalesTasks.OPENCALL.name())
                                && typeoftask!= SalesTasks.MCR.name()) {
                            //as this will be call type we will
                            //  get only one call type task per customer

                            system.debug('OPENCALL'+currentParentTaskMap.get(SalesTasks.OPENCALL.name()));
                            hasCallTask = true;
                            isClosedOpportunity = false;
                        }
                        else if(currentParentTaskMap!=null
                                &&currentParentTaskMap.size()>0
                                &&!currentParentTaskMap.containsKey(SalesTasks.MCR.name())
                                )
                        {
                            system.debug('MCR COmes here'+typeoftask);
                            hasCallTask = false;
                            isClosedOpportunity = false;
                        }
                        system.debug('hasCallTask :'+hasCallTask +' Rule is'+objtskSettingMap.RuleForActivity__c);
                        if (!hasCallTask) {
                            system.debug('hasCallTask :'+hasCallTask +' Rule is'+objtskSettingMap.RuleForActivity__c);
                            isClosedOpportunity = false;
                            if (!String.isBlank(objtskSettingMap.RuleForActivity__c)) {
                                newTask.type = typeoftask;
                                system.debug('RuleForActivity__c :'+objtskSettingMap.RuleForActivity__c);
                                cancreateTask = canCreateCallTask();
                                //Create Task Directly TCC/UCC/FUP/FUA
                            } else
                                    cancreateTask = true;
                        }
                    } else {
                        system.debug('typeoftask now'+typeoftask);
                        isClosedOpportunity = false;
                        if (!String.isBlank(objtskSettingMap.RuleForActivity__c)
                                || !String.isBlank(objtskSettingMap.RuleForTask__c)) {
                            //Here we get SBR Tasks
                            system.debug('Checking with rule'+typeoftask);
                            cancreateTask = canSendBrochure(currentParentTaskMap.get(typeoftask), currentrequestprogram, leadrecord, oppRecord);
                            system.debug('with rule it says create task'+cancreateTask);
                        }
                        //SPQ Task Comes here
                        else
                        {
                            cancreateTask = true;
                            system.debug(' with out rule'+cancreateTask);
                            system.debug('typeoftask :'+typeoftask);

                        }



                    }
                    newTask.type = typeoftask;
                    Boolean ch=isTheTaskAlreadyInQue
                            (leadrecord != null ? RequestEventObject.WhoId : RequestEventObject.WhatId
                                    , RequestEventObject.Program__c,
                                    typeoftask);
                    system.debug('typeoftask:-----'+typeoftask+' -----------cancreateTask:'+cancreateTask +'------isTheTaskAlreadyInQue:'+ch);
                    if (cancreateTask && !isTheTaskAlreadyInQue
                            (leadrecord != null ? RequestEventObject.WhoId : RequestEventObject.WhatId
                                    , RequestEventObject.Program__c,
                                    typeoftask))
                        taskList.add(CraeteTaskObject(RequestEventObject, newTask));
                }
            }
        }

        if (TypeToSave.containsKey(SaveType.UPDATEDATA.name())) {
            string[] updateTypeCalls = TypeToSave.get(SaveType.UPDATEDATA.name());
            string tasktype = '';
            string currentParentProgram;
            List<Task> closedTaskList;
            Task currentactiveTaskToUpdate;
            for (string type:updateTypeCalls) {
                if (taskSettingsMap.containsKey(type.trim())) {
                    TaskSettings__mdt objtskSettingMap = taskSettingsMap.get(type);
                    boolean canUpdateTask = false;
                    if (currentParentTaskMap.containsKey(SalesTasks.OPENCALL.name())) {
                        //closedTaskList=new List<Task>();
                        //As Per rules update
                        canUpdateTask = true;
                        tasktype = currentParentTaskMap.get(SalesTasks.OPENCALL.name())[0].type;
                        isClosedOpportunity = false;
                        currentactiveTaskToUpdate = currentParentTaskMap.get(SalesTasks.OPENCALL.name())[0];
                        currentParentProgram = currentParentTaskMap.get(SalesTasks.OPENCALL.name())[0].Program__c;

                        if (canUpdateTask) {
                            isClosedOpportunity = false;
                            //Based on parent program we need to update the due date here
                            Task objUpdateTask;
                            if (currentParentTaskMap.containsKey(SalesTasks.CLOSEDCALL.name()))
                                closedTaskList = currentParentTaskMap.get(SalesTasks.CLOSEDCALL.name());

                            if (RequestEventObject != null && currentParentProgram == RequestEventObject.Program__c && !String.isBlank(taskSettingsMap.get(tasktype).RuleForActivity__c))
                                objUpdateTask = updateTaskRulesForActivity(closedTaskList, currentactiveTaskToUpdate); else if (RequestTaskObj != null && currentParentProgram == RequestTaskObj.Program__c && !String.isBlank(taskSettingsMap.get(tasktype).RuleForTask__c))
                                //objUpdateTask = updateTaskRulesForTask(currentParentTaskMap.get(tasktype));

                            if (objUpdateTask != null)
                                taskList.add(objUpdateTask);
                            break;
                        }
                    }
                }
            }
        }
        //This is  for closed opportunity Need to look into it
        if (TypeToSave.containsKey(SaveType.CLOSEDINSERT.name()) && isClosedOpportunity) {
            string[] closedInsertTypeCalls = TypeToSave.get(SaveType.UPDATEDATA.name());
            for (string type:closedInsertTypeCalls) {
                if (taskSettingsMap.containsKey(type.trim())) {
                    TaskSettings__mdt objtskSettingMap = taskSettingsMap.get(type);
                    if (objtskSettingMap.IsTaskPerCustomer__c) {
                        string[] groupItems = utility.splitString(objtskSettingMap.TaskGroup__c, '|');
                        boolean canInsertTask = false;
                        for (string Item:groupItems) {
                            if (currentParentTaskMap.containsKey(Item)) {
                                for (Task currentTask:currentParentTaskMap.get(Item)) {

                                    if (!currentTask.IsClosed__c) {
                                        canInsertTask = true;
                                        break;
                                    }

                                }
                                if (canInsertTask) {
                                    //Create Task FUP
                                }
                            }
                        }
                    }
                }
            }
        }


        return taskList;
    }

    //For Customer activities we need to updates the call tasks which are alrteady there that is being checked here
    public static Task updateTaskRulesForActivity(List<Task> closedTaskList, Task tasktoUpdate) {



        if (closedTaskList != null && closedTaskList.size() > 0) {
            for (Task objtask:closedTaskList) {
                if (date.today() == Utility.ConvertDateTimeTodate(objtask.FollowUpDate__c)) {
                    return tasktoUpdate;
                }
            }
            //we will update this only if the Sales user has not spoken to customer today.
            if (tasktoUpdate != null)
                tasktoUpdate.FollowUpDate__c = Datetime.now();
        }



        return tasktoUpdate;
    }

    //Under Construction
    public static Task updateTaskRulesForTask(List<Task> taskList) {
        taskList[0].IsClosed__c = true;
        taskList[0].CloseDate__c = date.today();
        taskList[0].ClosedBy__c = UserInfo.getUserId();
        return taskList[0];
    }

    //Partially done only mapping of event to task is done but stiil we need to do task to task mapping
    public static Task craeteTaskObject(Event eventObj, Task objTask) {
        system.debug('Event Record'+ eventObj +'Task '+objTask);
        Task newTask = new Task();
        system.debug('craeteTaskObject ');
String taskSubject='';
        if (eventObj != null) {

            newTask.WhoId = eventObj.WhoId;
            newTask.WhatId = eventObj.WhatId;
            newTask.Market__c = eventObj.Market__c;
            newTask.Type = objTask.Type;
            newTask.Program__c = eventObj.Program__c;
            newTask.IsExpressCall__c= eventObj.IsExpressCall__c;
            newTask.FollowUpDate__c = Datetime.now();
            newTask.ActivityDate = Utility.ConvertDateTimeTodate(Datetime.now()) ;
            newTask.EventId__c = eventObj.Id;
            newTask.recordtypeid ='0122600000098jo';
            newTask.AdditionalPrograms__c=eventObj.AdditionalPrograms__c;
            //newTask.recordtypeid ='0129E0000004uxOQAQ';

            taskSubject=taskSettingsMap.get(objTask.Type).TaskSubject__c;
            System.debug('Task Subject>>>'+ taskSubject);
            System.debug('TaskSettingsmap>>>>>'+ taskSettingsMap);
            string[] program=Utility.splitString(taskSubject,'_');
            if(program.size()>1)
            {
                taskSubject=program[0]+eventObj.Program__c;
            }
            newTask.Subject=String.isBlank(taskSubject)?objTask.Type:taskSubject;



        } else {
            newTask = objTask;
        }

        system.debug('Task to create is '+newTask);
        return newTask;
    }

    //SBR Complete rules are being verified here
    public static Boolean canSendBrochure(List<Task> taskList, string currentRequestProgram, Lead leadRecord, opportunity oppRecord) {
        boolean cansendBR = false;
        system.debug('canSendBrochure Program:'+currentRequestProgram);
        String temp ='';
        cansendBR = oppRecord != null ?  oppRecord.account.HasAddress__c:false;
        if (!cansendBR) {
            return cansendBR;
        }
        Map<String, MarketProgramLevelSetting__c> marketProgramSetting = MarketProgramLevelSetting__c.getAll();
        //system.debug('Task List:'+taskList.size());
        If(taskList!=null && taskList.size()>0)
        {
            for (Task taskRecord: taskList) {
                system.debug('Task List:'+taskList.size());
                //system.debug('Task Program:'+taskRecord);
                system.debug('Task :'+taskRecord);
                temp=taskRecord.market__c + '_' + taskRecord.program__c;
                if (marketProgramSetting.containsKey(temp)) {

                    if (taskRecord.IsClosed__c &&(marketProgramSetting.get(temp).AutoCloseBrochureRequest__c == null
                            || marketProgramSetting.get(temp).AutoCloseBrochureRequest__c == 0
                            || marketProgramSetting.get(temp).AutoCloseBrochureRequest__c
                            <
                            (Utility.ConvertDateTimeTodate(taskRecord.CloseDate__c).daysBetween(date.today())))
                            && !marketProgramSetting.get(temp).DoNotSendBrochure__c) {
                        system.debug('Closed canSendBrochure Program:'+currentRequestProgram+'taskRecord.program__c:'+taskRecord.program__c);
                        cansendBR = true;
                        break;
                    }
                    else if(taskRecord.program__c==currentRequestProgram && !taskRecord.IsClosed__c)
                    {
                        system.debug('taskRecord.program__c==currentRequestProgram && !taskRecord.IsClosed__c');
                        system.debug('canSendBrochure Program:'+currentRequestProgram+'taskRecord.program__c:'+taskRecord.program__c);
                        cansendBR = false;
                        break;
                    }
                    else if(!marketProgramSetting.get(temp).DoNotSendBrochure__c)
                    {
                        system.debug('!marketProgramSetting.get(temp).DoNotSendBrochure__c');
                        system.debug('canSendBrochure Program:'+currentRequestProgram+'taskRecord.program__c:'+taskRecord.program__c);
                        cansendBR = true;
                        break;
                    }


                }

                else if(taskRecord.program__c==currentRequestProgram && !taskRecord.IsClosed__c )
                {
                    system.debug('taskRecord.program__c==currentRequestProgram && !taskRecord.IsClosed__c');
                    system.debug('canSendBrochure Program:'+currentRequestProgram+'taskRecord.program__c:'+taskRecord.program__c);
                    cansendBR = false;
                    break;
                }

            }
        }
        else
        {
            temp=eventrecord.market__c + '_' + eventrecord.program__c;
            if (marketProgramSetting.containsKey(temp)) {
                if(marketProgramSetting.get(temp).DoNotSendBrochure__c)
                {
                    cansendBR = false;
                }
            }
           
        }

        system.debug('canSendBrochure ending :'+cansendBR);
        return cansendBR;
    }
    //Create call task only if below condition are verified
    public static Boolean canCreateCallTask() {
        system.debug('canCreateCallTask ');
        system.debug('has contact method returning-------------------------------- ' +oppRecord );
        //return (leadrecord != null)?(leadrecord.HasPhoneNumber__c && !leadrecord.DoNotCall) : (oppRecord.HasPhoneNumber__c &&  !oppRecord.DoNotCall__C);
        return (oppRecord != null)? (oppRecord.account.HasPhoneNumber__c &&  !oppRecord.account.PersonDoNotCall):false;
        //return true;
    }

    //Here we check weather we have already task for perticular request which we wiil be saving
    // we will be avoiding creating duplicate task for same request
    public static Boolean isTheTaskAlreadyInQue(Id parentId, String program, String taskType) {
        Boolean hasTaskToCreate = false;
        id whoIdOrWhatId;
        for (Task objTask:TasksForActivitiesList) {
            system.debug('objTask ');
            whoIdOrWhatId=((leadrecord != null) ? objTask.WhoId : objTask.WhatId);
            if (whoIdOrWhatId == parentId  && taskType != SalesTasks.SBR.name()){
                hasTaskToCreate = true;
                break;
            } else if (whoIdOrWhatId == parentId
                    && objTask.program__c == program
                    && taskType == SalesTasks.SBR.name()) {
                hasTaskToCreate = true;
                break;
            }
        }
        system.debug('hasTaskToCreate: '+hasTaskToCreate);
        return hasTaskToCreate;
    }

}