/**************************************************************************************
Apex Class Name    : DcDiscardTrigger
Version            : 1.0
Created Date       : May 29 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Suresh S                  05/29/2017              Original Version
*******************************************************************************/
trigger DcDiscardTrigger on dupcheck__dcDiscard__c (after insert)
{
    Boolean isTriggerDisabled=Utility.getTriggerSettings(Label.dcDiscardApiName);
    if(!isTriggerDisabled) {
        DcDiscardsDispatcher.run();
    }
}