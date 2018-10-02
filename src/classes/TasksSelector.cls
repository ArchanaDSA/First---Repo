/**************************************************************************************
Apex Class Name    : ContactsSelector
Version            : 1.0
Created Date       : July 16 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * shravan.boddula                 07/12/2017              Original Version
*******************************************************************************/

public class TasksSelector {
    public static List<Task> getTasksOnWhoIds(List<Id> whoIds) {
        return [select Id,whoid,WhatId,Program__c,Type,Merge_Reason__c from Task where WhoId in :whoIds];
    }

    public static List<Task> getTasksListOnWhoId(Id whoId) {
        return [select Id,whoid,WhatId,Program__c,Type,Merge_Reason__c from Task where WhoId = :whoId];
    }

    public static Task getLatestTaskOnWhoId(Id whoId) {
        return [select Id,whoid,WhatId,Program__c,Type,Merge_Reason__c from Task where WhoId = :whoId order by CreatedDate Desc limit 1];

    }

    public static List<Task> getTasksWithoutWhatId(Id whoId) {
        return [select id,whoid,WhatId,Type from Task where whoid = :whoId and WhatId = null order by createdDate];

    }

    public static List<Task> getTasksWithoutWhatId_optm(List<Id> whoId) {
        return [select id,whoid,WhatId,Type from Task where whoid = :whoId and WhatId = null order by createdDate];

    }

    public static List<Task> getAllTasksOnLeads(List<Id> leadIDList) {
        return [select Id,whoid,WhatId,Program__c,Type,Merge_Reason__c from Task where WhoId IN:leadIDList];
    }

    public static List<Task> getAllTasks(List<Id> parentIds) {

        //[SELECT CloseMainReason__c, TaskSubtype, SalesAction__c, Program__c, Merge_Reason__c, ResultType__c, SubActions__c, EventId__c, Id, WhoId, WhatId, Subject, Status, Priority, IsHighPriority, OwnerId, Type, CloseSubReason__c, FollowUpDate__c, CustomerRequest__c, Market__c, IsClosed__c, IsExpress__c, CloseDate__c, ClosedBy__c, AutoClosed__c, Programs__c, AdditionalPrograms__c, TaskResult__c, TaskSubResult__c, OriginalDueDate__c, TaskType__c FROM Task where WhoId IN:parentIds or Whatid in : parentIds];
        return
                null;
    }
    public static List<Event> getAllActivities(List<Id> parentIds) {

        return [SELECT id,Type, CloseSubReason__c  FROM Event where WhatId IN:parentIds or whoid in:parentIds];
    }
    public static  Map<Id,List<Task>> getAllTasksForparent(List<Id> parentIds) {

        Map<Id,List<Task>> taskMap=new Map<Id,List<Task>>();
        integer index=0;
        List<Task> taskList=new List<Task>();
        taskList= [SELECT Id, WhoId, WhatId, Subject, Status,
                FollowUpDate__c,SalesAction__c, Program__c,Market__c, Merge_Reason__c,Type,IsClosed__c,
                CloseDate__c  FROM Task where  WhoId in:parentIds or whatId in:parentIds];
        Id parentId;
        List<Task> taskDummyList;
        for(Task taskobj :taskList)
        {
            taskDummyList=new List<Task>();
            parentId = taskobj.whatId != null ?taskobj.whatId:taskobj.WhoId;

            if(taskMap.containsKey(parentId))
            {
                taskDummyList=taskMap.get(parentId);
                //eventDummyList.add(eventobj);
                //eventMap.put(parentIds[index],eventDummyList);
            }
            //else
            // {
            taskDummyList.add(taskobj);
            taskMap.put(parentId,taskDummyList);
            //}

            index++;
        }
        return taskMap;




    }
}