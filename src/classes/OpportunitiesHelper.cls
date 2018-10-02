/**************************************************************************************
Apex Class Name    : OpportunityHelper
Version            : 1.0
Created Date       : Apr 25 2017
Function           : Opportunity related business logic here.
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  04/25/2017              Original Version
 *************************************************************************************/

public class OpportunitiesHelper{

//For after insert
public static void createShareOnInsert(List<Opportunity> oppList){

    Map<Id,String> OpportunityMap= new Map<Id,String>();
    
    for(Opportunity opp: oppList){
        OpportunityMap.put(opp.ID,opp.RecordSharingKey__c); //*** replace name with the Formula field
    }
    
    //get the public group details here
    Map<String,ID> publicGroupMap = publicGroupsSelector.getPublicGroups(OpportunityMap.values());

    List<OpportunityShare> OppShareList = new List<OpportunityShare>();
    OppShareList = createOpportunityShareRec(OpportunityMap,publicGroupMap);
    try{
        if(OppShareList.size() > 0){
            insert OppShareList;
        }
    }Catch(Exception ex){
        
    }
}


//For after update
public static void createShareOnUpdateTypes(List<Opportunity>  oppNewList,List<Opportunity>  oppOldList){
    Map<Id,String> OpportunityMap= new Map<Id,String>();
    Map<Id,ID> OpportunityShareDeleteMap= new Map<Id,ID>();

    //Query the public groups based on the LeadsharingKey
    List<String> sharingKeyNameList = new List<String>();
     for(Integer i=0;i<oppNewList.size();i++)
     {
     if(oppNewList[i].RecordSharingKey__c != oppOldList[i].RecordSharingKey__c) {
                sharingKeyNameList.add(oppOldList[i].RecordSharingKey__c);  //  this is for deleting the old share record
            }else sharingKeyNameList.add(oppNewList[i].RecordSharingKey__c);
      }
   //get the public group details here
    Map<String,ID> publicGroupMap = publicGroupsSelector.getPublicGroups(sharingKeyNameList);
    
    
    for(Integer i=0;i<oppNewList.size();i++){
        //if owner got changed OR market got changed.    
        if(oppNewList[i].OwnerId !=oppOldList[i].OwnerId ) {
            OpportunityMap.put(oppNewList[i].ID,oppNewList[i].RecordSharingKey__c);
        }else if(oppNewList[i].RecordSharingKey__c != oppOldList[i].RecordSharingKey__c){
            OpportunityMap.put(oppNewList[i].ID,oppNewList[i].RecordSharingKey__c);
            OpportunityShareDeleteMap.put(oppNewList[i].ID,publicGroupMap.get(oppOldList[i].RecordSharingKey__c));
        }
    }
    //create share
    List<OpportunityShare> OppShareList = new List<OpportunityShare>();
    if(OpportunityMap.size() > 0){
        OppShareList = createOpportunityShareRec(OpportunityMap,publicGroupMap);
    }
    if(OppShareList.size() > 0){
        insert OppShareList;
    }
     
    //delete old share records
    List<OpportunityShare> OppShareDeleteList = new List<OpportunityShare>();
    if(OpportunityShareDeleteMap !=NULL && OpportunityShareDeleteMap.size() >0){
        //call the selector class for getting the old share records needs to be deleted.
        OppShareDeleteList=OpportunitiesSelector.getOpportunityShareRecDetails(OpportunityShareDeleteMap);
        if(OppShareDeleteList.size() > 0){
            delete OppShareDeleteList;
        }
    }
}

//create share record for all the Opportunity
Public static List<OpportunityShare> createOpportunityShareRec(Map<Id,String> OpportunityMap,Map<String,ID> publicGroupMap){
    List<OpportunityShare> OppShareList = new List<OpportunityShare>();
    for(ID oppId:OpportunityMap.keyset()){
      
        if(publicGroupMap.containskey(OpportunityMap.get(oppId))){
            OpportunityShare os=createShareRecord(oppId,publicGroupMap.get(OpportunityMap.get(oppId)),System.Label.EditAccessLevel);
            OppShareList.add(os);
        }
        
    }
    return OppShareList;    
}

Public static OpportunityShare createShareRecord(ID recordId,ID userOrGroupId,String accessLevel){
    OpportunityShare os= new OpportunityShare();
    os.OpportunityId=recordId;
    os.UserOrGroupId=userOrGroupId;
    os.OpportunityAccessLevel = accessLevel;
    return os;
}

public static void UpdateMarketCodeOnAccount(List<Opportunity>  oppNewList,List<Opportunity>  oppOldList){
    Map<Id,String> accountmarketCodeMap= new Map<Id,String>();
    for(Integer i=0;i<oppNewList.size();i++){
            
        if(oppNewList[i].Market__c != oppOldList[i].Market__c) {
            accountmarketCodeMap.put(oppNewList[i].AccountID,oppNewList[i].Market__c);
        }  
    }
    
    List<ID> accIDList = new List<ID>(accountmarketCodeMap.keyset());
    
    List<Account> accList=OpportunitiesSelector.getAccountDetails(accIDList);
    for(Account acc:accList){
        if(accountmarketCodeMap.containskey(acc.ID)){
            acc.Market__c=accountmarketCodeMap.get(acc.ID);
        }
    }
    update accList;
}

      
}