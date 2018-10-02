/**
 * Created by shravan.boddula on 9/6/2017.
 */

public with sharing class DCBusinessFlowHelper {
    //notify ranking
    public static void notifyForRanking(Lead sourceLead) {
        try {
            system.debug('********** hitting ranking');
            system.debug('***** is dupe'+sourceLead.IsDupe__c);
            if (sourceLead.IsDupe__c == false) {
                sourceLead.ReadyForRanking__c = true;
                system.debug('********** hitting ranking inside if');
            }
            system.debug('***** ready for ranking'+sourceLead.ReadyForRanking__c);
            system.debug('********** final dml');
            SObjectUnitOfWork.executeUpdateLeads(new List<Lead>{sourceLead});

        } catch (Exception ex) {
            system.debug('exception in notifyranking');
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessFlowHelper', 'notifyForRanking', '');
        }
    }

}