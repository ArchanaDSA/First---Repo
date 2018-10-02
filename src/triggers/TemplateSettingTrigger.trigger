/**
 * Created by savita.b on 2017-09-22.
 */

trigger TemplateSettingTrigger on TemplateSetting__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {
    Boolean isTriggerDisabled=Utility.getTriggerSettings(Label.TemplateSetting);
    if(!isTriggerDisabled)
   {
        TemplateSettingsDispatcher.run();
   }
}