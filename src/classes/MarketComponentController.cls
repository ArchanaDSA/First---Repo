/**
 * Created by Archana on 27-07-2017.
 */

public with sharing class MarketComponentController {
    @AuraEnabled
    public static String getInitialData(Id entityId){
        String sObjectName = entityId.getSObjectType().getDescribe().getName();
        SObject objectToUpdate = Database.query('SELECT Market__c, SalesOffice__c, Product__c, Program__c FROM '+sObjectName+' WHERE Id = :entityId LIMIT 1');
        return JSON.serialize(objectToUpdate);
    }

    @AuraEnabled
    public static String getAllMarkets(Id entityId){
        Map<String,String> markets = FieldUtilityClass.getPickListValues(entityId.getSObjectType(),'Market__c');
        return JSON.serialize(markets);
    }
    @AuraEnabled
    public static String getAllSalesOfficesforMarket(string marketName,Id entityId){
        String sObjectName = entityId.getSObjectType().getDescribe().getName();
        Map<String,List<String>> pickValueMap=FieldUtilityClass.GetDependentOptions(sObjectName,'Market__c','SalesOffice__c');
        return JSON.serialize(pickValueMap.get(marketName));
    }

    @AuraEnabled
    public static String getAllProducts(Id entityId){
        Map<String,String> products = FieldUtilityClass.getPickListValues(entityId.getSObjectType(),'Product__c');
        return JSON.serialize(products);
    }

    @AuraEnabled
    public static String getAllProgramsforProduct(String product,Id entityId){
        String sObjectName = entityId.getSObjectType().getDescribe().getName();
        Map<String,List<String>> pickValueMap=FieldUtilityClass.GetDependentOptions(sObjectName,'Product__c','Program__c');
        return JSON.serialize(pickValueMap.get(product));
    }

    @AuraEnabled
    public static void SaveData(String product, String program, String market, String salesOffice, Id entityId)
    {
        String sObjectName = entityId.getSObjectType().getDescribe().getName();
        SObject objectToUpdate = Database.query('SELECT Market__c, SalesOffice__c, Product__c, Program__c FROM '+sObjectName+' WHERE Id =: entityId LIMIT 1');
//        objectToUpdate.put('Market__c',market);
        objectToUpdate.put('SalesOffice__c',salesOffice);
        objectToUpdate.put('Product__c',product);
        objectToUpdate.put('Program__c',program);

        update objectToUpdate;
    }
}