/**************************************************************************************
Apex Class Name    : MetaDataSelector
Version            : 1.0
Created Date       : August 09 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * arjun.mohan                09/08/2017              Original Version
*******************************************************************************/

public with sharing class MetaDataSelector {

    public static Map<String,TaskSettings__mdt> getTaskSettingMetada() {

        Map<String,TaskSettings__mdt> taskSettingsMap = new  Map<String,TaskSettings__mdt>();

        for(TaskSettings__mdt taskSetting :[Select CanCloseManually__c,CanCreateMannually__c,
                CreateCallType__c,ForClosedCallTypes__c,IsActive__c,RuleForTask__c,
                IsCallType__c,IsTaskPerCustomer__c,Name__c,RuleForActivity__c,
                No__c,RULE__c,TaskGroup__c,Type__c,UpdateCallType__c,TaskSubject__c
        from TaskSettings__mdt])
        {
            taskSettingsMap.put(taskSetting.Name__c, taskSetting);
        }

        return taskSettingsMap;
    }

}