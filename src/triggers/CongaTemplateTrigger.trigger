trigger CongaTemplateTrigger on APXTConga4__Conga_Template__c (before insert,before update,before delete,after insert,after update,after delete,after undelete)
{
    System.debug('>>>em here');
   // Boolean isTriggerDisabled=Utility.getTriggerSettings();
    //if(!isTriggerDisabled)
   // {
    CongaTemplatesDispatcher.run();
   // }

}