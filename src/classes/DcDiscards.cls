/**************************************************************************************
Apex Class Name    : DcDiscards
Version            : 1.0
Created Date       : June 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/22/2017              Original Version
*******************************************************************************/
public class DcDiscards {

    public static void onBeforeInsert(List<SObject> newItems) {
    }

    public static void onBeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(Map<Id, SObject> newItems) {
        DcDiscardsHelper.notifyRankingAfterInsert((List<dupcheck__dcDiscard__c>) newItems.values());
    }

    public static void onAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }
}