public without sharing class PrimaryActivityPOCController {
    @AuraEnabled
    public static List<Event> getAllEvents(ID OpportunityID) {
        Opportunity opp=[select ID,PrimaryOpportunityID__c from opportunity where ID=:OpportunityID];
        list<Event> eveList = new list<Event>();
        if(opp.PrimaryOpportunityID__c != null){
            eveList=[SELECT Id,Location,whoID,whatID,what.Name,Subject,Description,Owner.Name,StartDateTime FROM Event where whatID=:opp.PrimaryOpportunityID__c ];
       
        }
        list<Event> eveList2=[SELECT Id,Location,whoID,whatID,what.Name,Subject,Description,Owner.Name,StartDateTime,AccountID FROM Event where AccountID ='0012600000Vm4QwAAJ'];
        system.debug('-----------eveList-----------'+eveList);
        system.debug('-----------eveList-----------'+eveList2);
        return eveList;
    }
}