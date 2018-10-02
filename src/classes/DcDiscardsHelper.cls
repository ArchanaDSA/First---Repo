/**************************************************************************************
Apex Class Name    : DcDiscardsHelper
Version            : 1.0
Created Date       : June 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/22/2017              Original Version
*******************************************************************************/
public class DcDiscardsHelper {
    public static void notifyRankingAfterInsert(List<dupcheck__dcDiscard__c > dcDiscardList) {
        //This trigger will invoke once we click "Discard" button in the DC Tool and hit for ranking once we discard the record.
        List<Id> leadIdList = new List<Id>();
        for (dupcheck__dcDiscard__c discardedItem : dcDiscardList) {
            Id leadId = discardedItem.dupcheck__objectA__c;
            leadIdList.add(leadId);
        }
        
        //Modify the leads with ready for ranking
        List<Lead> leadUpdateList = new List<Lead>();
        leadUpdateList = LeadsSelector.leadListDetails(leadIdList);
        for (Lead lead : leadUpdateList) {
            lead.IsDupe__c = false;
            lead.ReadyForRanking__c = true;
        }
        SObjectUnitOfWork.ExecuteUpdateLeads(leadUpdateList);

    }


}