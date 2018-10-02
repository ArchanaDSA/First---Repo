/**
 * Created by aneesh.bhat on 04-Sep-17.
 */

public with sharing class LogACallController {
    @auraEnabled
    public static Date getOpportunityCloseDate(Id recordId){
        return [SELECT Id, CloseDate FROM Opportunity where Id = :recordId LIMIT 1].CloseDate;
    }
    @AuraEnabled
    public static string getSalesActions(){
        return JSON.serialize(addDefaultOption(FieldUtilityClass.getPickListValues(Task.getSObjectType(),'SalesAction__c').keySet()));
    }

    @AuraEnabled
    public static string getSubActions(){
        return JSON.serialize(addDefaultOption(FieldUtilityClass.getPickListValues(Task.getSObjectType(),'SubActions__c').keySet()));
    }

    @AuraEnabled
    public static string getLikelihoodToBookOptions(){
        return JSON.serialize(addDefaultOption(FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(),'Likelihood_To_Book__c').keySet()));
    }

    @AuraEnabled
    public static string getHearAboutUsOptions(){
        return JSON.serialize(addDefaultOption(FieldUtilityClass.getPickListValues(Opportunity.getSObjectType(),'HearAboutUs__c').keySet()));
    }

    @AuraEnabled
    public static List<string> getDestinations(Id recordId){
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        Opportunity objectToUpdate = Database.query('SELECT Program__c FROM '+sObjectName+' WHERE Id = :recordId LIMIT 1');
        Map<String,List<String>> dependentPicklists = FieldUtilityClass.GetDependentOptions(Opportunity.getSObjectType().getDescribe().getName(),'Program__c','Destinations__c');
        return addDefaultOption(dependentPicklists.get(objectToUpdate.Program__c));
    }

    @AuraEnabled
    public static List<string> getDurations(Id recordId){
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        Opportunity objectToUpdate = Database.query('SELECT Program__c FROM '+sObjectName+' WHERE Id = :recordId LIMIT 1');
        Map<String,List<String>> dependentPicklists = FieldUtilityClass.GetDependentOptions(Opportunity.getSObjectType().getDescribe().getName(),'Program__c','Duration__c');
        return addDefaultOption(dependentPicklists.get(objectToUpdate.Program__c));
    }

    @AuraEnabled
    public static string getCloseReasons(){
        return JSON.serialize(addDefaultOption(FieldUtilityClass.getPickListValues(Task.getSObjectType(),'CloseMainReason__c').keySet()));
    }

    @AuraEnabled
    public static String getCallResults(String callAction){
        Map<String,List<String>> dependentPicklists = FieldUtilityClass.getFieldDependencies(Task.getSObjectType().getDescribe().getName(),'SalesAction__c','ResultType__c');
        return JSON.serialize(addDefaultOption(dependentPicklists.get(callAction)));
    }

    private static Set<String> addDefaultOption(Set<String> input){
        Set<String> picklistValues = new Set<String>();
        picklistValues.add('Select');
        picklistValues.addAll(input);
        return picklistValues;
    }

    private static List<String> addDefaultOption(List<String> input){
        List<String> picklistValues = new List<String>();
        picklistValues.add('Select');
        picklistValues.addAll(input);
        return picklistValues;
    }

    @AuraEnabled
    public static void saveData(String callAction, String subAction, String callResult, DateTime actionDateTime, string closeReason, Id recordId){
        try
        {
            Task task = new Task();
            task.SalesAction__c = callAction;
            task.SubActions__c = subAction;
            task.ResultType__c = callResult;
            task.ActivityDateTime__c = actionDateTime;
            task.CloseMainReason__c = closeReason;
            task.RecordTypeId = Label.TaskRecordTypeId;
            task.WhatId = recordId;
            insert task;
        }
        catch(Exception ex){
            System.debug('Error :'+ ex.getMessage());
        }
    }
}