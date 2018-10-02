/**************************************************************************************
Apex Class Name    : OpportunitiesSelector
Version            : 1.0
Created Date       : Apr 25 2017
Function           : All SOQL queries related Opportunity
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  04/25/2017              Original Version
 *************************************************************************************/
public class OpportunitiesSelector{

    Public static List<OpportunityShare> getOpportunityShareRecDetails(Map<Id,ID> OpportunityShareDeleteMap){

        return [select Id from OpportunityShare where UserOrGroupId IN:OpportunityShareDeleteMap.values()
                            AND OpportunityId IN:OpportunityShareDeleteMap.keyset()];
    }
    
    Public static List<Account> getAccountDetails(List<ID> accIDList){
        return [SELECT ID,Market__c FROM ACCOUNT WHERE ID IN:accIDList];
    }

    public static Opportunity getOpportunityOnId(Id oppId) {
        return [
                select id, Name, FollowupDatetime__c, AccountId, StageName,Program__c
                from Opportunity where Id = :oppId limit 1];
    }

    public static List<Opportunity> getOpportunityOnId_Optm(Set<Id> oppId) {
        return [
                select id, Name, FollowupDatetime__c, AccountId, StageName,Program__c
                from Opportunity where Id in :oppId];
    }
    
    public static List<Opportunity> getOpportunitiesOnAccountId(Id accId) {
        return [
                select id,Name, FollowupDatetime__c,AccountId,StageName,Program__c
                from Opportunity where AccountId = :accId order by FollowupDateTime__c ASC];
    }

    public static Opportunity getLatestOpportunityOnAccountId(Id accId) {
        List<Opportunity> opportunities = null;
        Opportunity latestOpportunity = null;
        try {
            opportunities = [SELECT Id,StageName,Name,AccountId,CloseDate FROM Opportunity WHERE AccountId = :accId AND IsDeleted = false ORDER BY CreatedDate desc];
            if (opportunities != null && opportunities.size() > 0) {
                latestOpportunity = opportunities[0];
            }
        } catch (Exception ex) {
        }
        return latestOpportunity;
    }

    public static List<Opportunity> getLatestOpportunityOnAccountId_Optm(Set<Id> accId)
    {
        List<Opportunity> latestOpportunity=[SELECT Id,StageName,Name,AccountId,CloseDate FROM Opportunity WHERE AccountId = :accId AND IsDeleted = false ORDER BY CreatedDate desc];
        return latestOpportunity;
    }
    public static list<opportunity> getLstOpportunityOrderByCrtdDateASC(list<opportunity> mergedOpps){

        list<opportunity> opportunityOrderByCreatedDateASC = [select id,FollowupDateTime__c,stageName from opportunity where id in:mergedOpps ORDER BY createddate ASC];
       return opportunityOrderByCreatedDateASC;
    }
    public static list<opportunity> getLstOfFollowupOpportunity(list<opportunity> mergedOpps){
        list<opportunity> lstOfOpportunity = [select id,FollowupDateTime__c,stageName from opportunity where id in:mergedOpps AND stageName ='FOLLOWUP' ORDER BY FollowupDateTime__c ASC];
        return lstOfOpportunity;

    }
    public static list<opportunity> getlstOfOpportunityByCreatedDateDesc(account masterAccount){
       list<opportunity> lstOfOpportunity= [select id, Name, FollowupDateTime__c,AccountId,StageName,Program__c
        from Opportunity Where accountId=:masterAccount.id ORDER BY CreatedDate DESC];
        return lstOfOpportunity;
    }
    //Commented by suresh..
    /*public static List<Opportunity> getAllEventsAndTasksforOpportunity(List<id> opportunityIds)
    {
        return [select id,(Select id,AdditionalPrograms__c,Type from tasks),(Select id,Type from events) from Opportunity where id in : opportunityIds];
    }*/

    public static List<Opportunity> getAllEventsAndTasksforOpportunity(List<id> opportunityIds)
    {
        return [select id,Name,account.PersonDoNotCall,account.HasAddress__c,account.HasPhoneNumber__c,Program__c,Market__c,
        (SELECT Id, WhoId, WhatId, Subject, Status,
                FollowUpDate__c,SalesAction__c, Program__c,Market__c, Merge_Reason__c,Type,IsClosed__c,
                CloseDate__c,AdditionalPrograms__c  FROM Tasks),
        (Select Id, WhoId, WhatId, Subject, OwnerId,
                Type, SalesAction__c, Program__c, EventId__c, Market__c,
                IsExpressCall__c, AdditionalPrograms__c,ProcessedforTaskcreation__c
        FROM Events where ProcessedforTaskcreation__c=false) from Opportunity where id in : opportunityIds];
    }

    public static Map<Id,Opportunity> getopportunityMap(List<Id> parentId)
    {

        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity> ([SELECT Id
                , Name,account.PersonDoNotCall,account.HasAddress__c,account.HasPhoneNumber__c,Program__c,Market__c
        FROM Opportunity
        WHERE Id in  :parentId]);
        return opportunityMap;

    }

    //This method used to get the active opportunity
    public static List<Opportunity> dupeCheckOpportunities(Account duplicateAccount) {
        return [Select id,StageName,CloseDate,Program__c from Opportunity
        Where AccountId=:duplicateAccount.id And
        IsPrimary__c=TRUE AND isActive__c = TRUE];
    }
    
    public static Opportunity getOpportunityrecords(Id recordId){
        return [Select Id,AccountId,CampaignId,Market__c,Program__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
    }
}