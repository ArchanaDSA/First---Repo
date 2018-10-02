@isTest
public class TestDataUtil {
    public static string suffix;


    private static final String EMAIL_SUFFIX = '@ef.com.dev.tst';
    private static final String USERNAME_SUFFIX = '@ef.com.dev.tst';
    private static Integer countUsersCreated = 0; //Use this to avoid duplicate Test User names


    /********************************************************************************************************************************
   *
   * ver 1.0 2017.09.22 Manos Spanoudakis <manos.spanoudakis@ef.com>
   *
   */
    public static User createAdminUser() {
        Profile p = getProfile(Label.System_administrator_profile_name);

        User u = new User();
        u.ProfileId = p.Id;
        u.alias = 'admnTU';
        u.email = u.alias + EMAIL_SUFFIX;
        u.emailencodingkey = 'UTF-8';
        u.lastname = 'admTU'+system.now();
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.timezonesidkey = 'Europe/Berlin';
        u.username = 'TestAdmin'+ (countUsersCreated++) + USERNAME_SUFFIX;

        insert u;

        system.debug('User:'+u);
        return u;
    }
    /*********************************************************************************************************************************/

    /********************************************************************************************************************************
	*
    * ver 1.0 2017.09.22 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    */
    public static User createUser() {

        User u = new User();
        u.alias = 'TUsr'+countUsersCreated;
        u.email = u.alias + EMAIL_SUFFIX;
        u.emailencodingkey = 'UTF-8';
        u.lastname = 'cdtUsr'+system.now();
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.timezonesidkey = 'Europe/Berlin';
        u.username = 'TestUser'+ (countUsersCreated++) + USERNAME_SUFFIX;
        insert u;

        system.debug('User:'+u);
        return u;
    }
    /*********************************************************************************************************************************/

    /********************************************************************************************************************************
	*
    * ver 1.0 2017.09.22 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    */
    public static Profile getProfile(String profile) {
        profile p = new profile();
        try {
            p = [SELECT Id, Name FROM profile WHERE name like :profile LIMIT 1];
        }
        catch (system.Queryexception exc) {
            p = [SELECT Id, Name FROM profile WHERE name like 'system%administrator' LIMIT 1];
        }

        system.debug('Profile:' +p);

        return  p;
    }
    /*********************************************************************************************************************************/

    /********************************************************************************************************************************
	*
    * ver 1.0 2017.09.22 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    */
    public static Account createAccount(String name,  String strRecordTypeId,boolean withInsert) {
        Account acc = new Account();
        acc.name = name;
        acc.RecordTypeId=strRecordTypeId;
        if (withInsert)
            insert acc;
        return acc;
    }
    /*********************************************************************************************************************************/


    /********************************************************************************************************************************
    *
    * ver 1.0 2017.09.22 Manos Spanoudakis <manos.spanoudakis@ef.com>
    *
    */
    public static List<Account> createAccounts(String name, String strRecordTypeId, Integer numAccounts, boolean withInsert) {

        List<Account> lAccounts = new List<Account>();

        for (Integer i=0;i<numAccounts;i++)
        {
            Account tAccount = createAccount(name,strRecordTypeId,withInsert);
            lAccounts.add(tAccount);
        }

        if (withInsert)
            insert lAccounts;
        return lAccounts;
    }
    /*********************************************************************************************************************************/

    public static void SetUniqueValues() {
        DateTime dateAndTime = DateTime.now();
        string dateTest = string.valueof(dateAndTime.date());
        string hh = string.valueof(dateAndTime.hour());
        string mm = string.valueof(dateAndTime.minute());
        string ss = string.valueof(dateAndTime.second());
        string mil = string.valueof(dateAndTime.millisecond());
        suffix = dateTest + hh + mm + ss + mil;
        // string tm = mm+ss+hh+mil;
        //alias = tm.substring(0,3);
    }
    public static User createUserRecord() {
        SetUniqueValues();
        // Getting the profile id
        Id sysAdminProfileId = [select Id from Profile where Name='System Administrator'].Id;
        //create a test role
        UserRole adminAsstRole = new UserRole(Name='Business Admin');
        insert adminAsstRole;

        //creating user 
        User adminUserOne = new User(TimeZoneSidKey='Europe/Berlin',firstname='User1', Username='John' + suffix + '@ef.com',Alias='P0044',
                Email='TestAdminOne' + suffix + '@ef.com',EmailEncodingKey='UTF-8',LastName='SA'+suffix,ProfileId=sysAdminProfileId,
                UserRoleId =adminAsstRole.Id,
                LanguageLocaleKey='en_US',LocaleSidKey='en_US',EmployeeNumber='P0044',Department='94444');

        insert adminUserOne;
        return adminUserOne;
    }

    Public static List<Account> updateAccountRecords(List<Account> accList){
        for(Account acc: accList){
            acc.Market__c='FRP'; 
        }
        update accList;
        return accList;
    }
    Public static List<Opportunity> updateOpportunityRecords(List<Opportunity> oppList){
        for(Opportunity opp: oppList){
            opp.Market__c='DEB';
            opp.SalesOffice__c='DEB';
            opp.Program__c='ILSU';
        }
        update oppList;
        return oppList;
    }

    Public static List<Account> createAccountRecords(Integer count){
        List<Account> accList= new List<Account>();
        for(Integer i=0;i<count;i++){
            Account a= new Account();
            a.Name='TestAcc-'+i;
            a.Market__c='DEB';
            accList.add(a);
        }
        insert accList;
        return accList;
    }

    public static account creatAcc()
    {
        Account a= new Account();
        a.Name='TestAcc-';
        //insert a;
        return a;

    }

    Public static List<Opportunity> createOpportunityRecords(List<Account> accList,Integer count){
        List<Opportunity> oppList= new List<Opportunity>();
        for(Account acc:accList){
            for(Integer i=0;i<count;i++){
                Opportunity opp= new Opportunity();
                opp.Name='TestOpportunity-'+i;
                opp.AccountID=acc.ID;
                opp.Market__c='DEB';
                opp.SalesOffice__c='DEB';
                opp.Program__c='ILSH';
                opp.StageName='Open';
                opp.CloseDate=System.today();

                oppList.add(opp);
            }
        }
        insert oppList;
        return oppList;
    }
    
    public static List<Group> insertPublicGroup(){
        List<Group> groupList= new List<Group>();
        Group g1= new Group();
        g1.Name='DEB';
        
        Group g2= new Group();
        g2.Name='DEB_DEX';
        
        Group g3= new Group();
        g3.Name='DEB_DEB_ILSH';
        
        Group g4= new Group();
        g4.Name='DEB_DEB_ILSU';
        
        Group g5= new Group();
        g5.Name='FRP';
        
        Group g6= new Group();
        g6.Name='FRP_FRS_ILSH';
        
        Group g7= new Group();
        g7.Name='FRP_FRS_ILSU';
        
        Group g8= new Group();
        g8.Name='DEB_DEB';
        
        Group g9= new Group();
        g9.Name='FRP_FRP';
        
        Group g10= new Group();
        g10.Name='FRP_FRS';
        
        groupList.add(g1);
        groupList.add(g2);
        groupList.add(g3);
        groupList.add(g4);
        groupList.add(g5);
        groupList.add(g6);
        groupList.add(g7);
        groupList.add(g8);
        groupList.add(g9);
        groupList.add(g10);
        
        insert groupList;
        return groupList;
    
    }
    
    Public static List<LEAD> updateLEADRecords(List<LEAD> leadList){
           for(lead leadRec: leadList){
            //leadRec.Market__c='DEB';
            //leadRec.SalesOffice__c='DEB';
            //leadRec.Program__c='MLY';
            //leadRec.product__c='APP';
            leadrec.ownerid='0059E000000sR8L';
        }
        //update leadList;
        return leadList;
    } 
    
     Public static LEAD UpdateSharingKey(LEAD anotherlead){
            //leadRec.Market__c='DEB';
            //leadRec.SalesOffice__c='DEB';
            anotherlead.Program__c='MLY';
            anotherlead.product__c='APP';
            //leadrec.ownerid='0059E000000sR8L';
        
        //update anotherlead;
        return anotherlead;
    } 
    
    
    public static Lead insertAnotherSetOfLeadRecord()
    {
        Lead anotherlead=new Lead();
        anotherlead.FirstName='FirstName';
        anotherlead.LastName='LastName';
        anotherlead.street='street1';
        anotherlead.City='City';
        anotherlead.Triton_Id__c= 'triton id123';
        anotherlead.PostalCode='560048';
        anotherlead.Phone='9988776666';
        anotherlead.MobilePhone='9988776666';
        anotherlead.Other_Phone__c='9988776666';
       // anotherlead.Parent_Phone__c='9988776666';
        anotherlead.DOB__c=system.today();
        anotherlead.Email='StudentEmail1@email.com';
        anotherlead.Email2__c='StudentEmail2@email.com';
        //anotherlead.Parent_Email__c='ParentEmail@email.com';
        //anotherlead.Invoice_Email__c='InvoiceEmail@email.com';
        anotherlead.Region__c='Region' ;
        //  newLead.Activity__c=.Activity;
        anotherlead.Program__c='AY';
        anotherlead.market__c='DEB';
        anotherlead.SalesOffice__c='DEB';
        anotherlead.product__c='APP';
        anotherlead.InsertTime__c=system.now();
        anotherlead.Country='India';
        
        anotherlead.state='Maharashtra';
        anotherlead.PostalCode='560090';
        
        //anotherlead.Change_Reasons__c='Does not want to travel in group';

        //insert anotherlead;
        return anotherlead;
    }


    public static list<Lead> insertLeadRecord(){
        Lead newLead=new Lead();
        newLead.FirstName='FirstName';
        newLead.LastName='LastName';
        newLead.street='street1';
        newLead.City='City';
        newLead.Triton_Id__c= 'triton id123';
        newLead.PostalCode='560048';
        newLead.Phone='9988776666';
        newLead.MobilePhone='9988776666';
        newLead.Other_Phone__c='9988776666';
        //newLead.Parent_Phone__c='9988776666';
        newLead.DOB__c=system.today();
        newLead.Email='StudentEmail1@email.com';
        newLead.Email2__c='StudentEmail2@email.com';
        //newLead.Parent_Email__c='ParentEmail@email.com';
       // newLead.Invoice_Email__c='InvoiceEmail@email.com';
        newLead.Region__c='Region' ;
        //  newLead.Activity__c=.Activity;
        newLead.Program__c='AY';
        newLead.market__c='DEB';
        newLead.SalesOffice__c='DEB';
        newLead.product__c='APP';
        //newLead.Change_Reasons__c='Does not want to travel in group';



        //newLead.MarketCode__c=.MarketCode;
        // newLead.RecordTypeId=GetRecordTypeOnMarketCode(.MarketCode);
        //  newLead.ActivityDateTime__c=.ActivityDate;//this field is being used in


        Lead newLead2=new Lead();
        newLead2.FirstName='FirstName2';
        newLead2.LastName='LastName';
        newLead2.street='street1';

        newLead2.City='City';
        newLead2.Triton_Id__c= 'triton id123';
        newLead2.PostalCode='560048';
        newLead2.Phone='9988776666';
        newLead2.MobilePhone='9988776666';
        newLead2.Other_Phone__c='9988776666';
        //newLead2.Parent_Phone__c='9988776666';
        newLead2.DOB__c=system.today();
        newLead2.Email='StudentEmail1@email.com';
        newLead2.Email2__c='StudentEmail2@email.com';
        //newLead2.Parent_Email__c='ParentEmail@email.com';
        //newLead2.Invoice_Email__c='InvoiceEmail@email.com';
        newLead2.Region__c='Region' ;
        newLead2.Program__c='AY';
        newLead2.market__c='DEB';
        newLead2.SalesOffice__c='DEB';
         newLead2.product__c='APP';
         //newLead2.Change_Reasons__c='Does not want to travel in group';
        



        List<Lead> leadList = new List<Lead>();
        leadList.add(newLead);
        leadList.add(newLead2);
        //insert leadList;
        return leadList;
    }
    
    public static void BeforeInsertRecords(list<lead> LeadRec)
    {
        
        lead LeadRec1=new lead();
        LeadRec1.FirstName='FirstName2';
        LeadRec1.LastName='LastName';
        LeadRec1.Region__c='Region' ;
        LeadRec1.Program__c='AY';
        LeadRec1.market__c='DEB';
        LeadRec1.SalesOffice__c='DEB';
        LeadRec1.street='street1';
        LeadRec1.City='City';
        LeadRec1.Triton_Id__c= 'triton id123';
        LeadRec1.PostalCode='560048';
        LeadRec1.Phone='9988776666';
        LeadRec1.MobilePhone='9988776666';
        LeadRec1.Other_Phone__c='9988776666';
        //LeadRec1.Parent_Phone__c='9988776666';
        LeadRec1.DOB__c=system.today();
        LeadRec1.Email='StudentEmail1@email.com';
        LeadRec1.Email2__c='StudentEmail2@email.com';
       // LeadRec1.Parent_Email__c='ParentEmail@email.com';
        //LeadRec1.Invoice_Email__c='InvoiceEmail@email.com';
        LeadRec1.product__c='APP';
        //leadrec1.Change_Reasons__c='Does not want to travel in group';
        
        lead LeadRec2=new lead();
        LeadRec2.FirstName='FirstName2';
        LeadRec2.LastName='LastName';
        LeadRec2.Region__c='Region' ;
        LeadRec2.Program__c='AY';
        LeadRec2.market__c='DEB';
        LeadRec2.SalesOffice__c='DEB';
        LeadRec2.street='street1';
        LeadRec2.City='City';
        LeadRec2.Triton_Id__c= 'triton id123';
        LeadRec2.PostalCode='560048';
        LeadRec2.Phone='9988776666';
        LeadRec2.MobilePhone='9988776666';
        LeadRec2.Other_Phone__c='9988776666';
        //LeadRec2.Parent_Phone__c='9988776666';
        LeadRec2.DOB__c=system.today();
        LeadRec2.Email='StudentEmail1@email.com';
        LeadRec2.Email2__c='StudentEmail2@email.com';
        //LeadRec2.Parent_Email__c='ParentEmail@email.com';
        //LeadRec2.Invoice_Email__c='InvoiceEmail@email.com';
        LeadRec2.product__c='APP';
        //leadrec2.Change_Reasons__c='Does not want to travel in group';
        
        LeadRec.add(LeadRec1);
        LeadRec.add(LeadRec2);
        
    }
    
    Public static LEAD DeleteLeads(LEAD insertAnotherSetOfLeadRecord)
    { 
        //delete insertAnotherSetOfLeadRecord;
        return insertAnotherSetOfLeadRecord;
    }
    
    Public static LEAD UnDeleteLeads(LEAD insertAnotherSetOfLeadRecord)
    {
        //insert insertAnotherSetOfLeadRecord;
        delete insertAnotherSetOfLeadRecord;
        //undelete insertAnotherSetOfLeadRecord;
        return insertAnotherSetOfLeadRecord;
    }
    //Single record insertion
    public static Lead createLead() {
        Lead leadRecord = new Lead();
        leadRecord.FirstName='FirstName2';
        leadRecord.LastName='LastName';
        leadRecord.Region__c='Region' ;
        leadRecord.Program__c='AY';
        leadRecord.market__c='DEB';
        leadRecord.SalesOffice__c='DEB';
        leadRecord.street='street1';
        leadRecord.City='City';
        leadRecord.Triton_Id__c= 'triton id123';
        leadRecord.PostalCode='560048';
        leadRecord.Phone='9988776666';
        leadRecord.MobilePhone='9988776666';
        leadRecord.Other_Phone__c='9988776666';
        //leadRecord.Parent_Phone__c='9988776666';
        leadRecord.DOB__c=system.today();
        leadRecord.Email='StudentEmail1@email.com';
        leadRecord.Email2__c='StudentEmail2@email.com';
        //leadRecord.Parent_Email__c='ParentEmail@email.com';
        //leadRecord.Invoice_Email__c='InvoiceEmail@email.com';
        leadRecord.product__c='APP';
        leadRecord.Country='India';
        leadRecord.state='KArnataka';
        
        leadRecord.PostalCode='560090';
        
        //leadRecord.Change_Reasons__c='Does not want to travel in group';
        return leadRecord;
    }

    public static Account createAccount(){
        Account accountRecord = new Account();
        accountRecord.Name='TestAcc';
        return accountRecord;
    }

    public static dupcheck__dcDiscard__c createDupcheckDiscard(String objectA,String objectB) {
        dupcheck__dcDiscard__c dupcheckdiscard = new dupcheck__dcDiscard__c();
        dupcheckdiscard.dupcheck__objectA__c =objectA;
        dupcheckdiscard.dupcheck__objectB__c = objectA;
        dupcheckdiscard.dupcheck__Relation__c='Duplicate';
        dupcheckdiscard.dupcheck__recordA__c=objectA;
        dupcheckdiscard.dupcheck__recordB__c=objectB;
        return dupcheckdiscard;
    }

    //bulk record insertion
    public static List<Lead> createLeadList(Integer count) {
        List<Lead> leadList = new List<Lead>();
        for(Integer index=0;index<count;index++) {
            Lead leadRecord = new Lead();
            leadRecord.FirstName='FirstName2';
            leadRecord.LastName='LastName';
            leadRecord.Region__c='Region' ;
            leadRecord.Program__c='AY';
            leadRecord.market__c='DEB';
            leadRecord.SalesOffice__c='DEB';
            leadRecord.street='street1';
            leadRecord.City='City';
            leadRecord.Triton_Id__c= 'triton id123';
            leadRecord.PostalCode='560048';
            leadRecord.Phone='9988776666';
            leadRecord.MobilePhone='9988776666';
            leadRecord.Other_Phone__c='9988776666';
            //leadRecord.Parent_Phone__c='9988776666';
            leadRecord.DOB__c=system.today();
            leadRecord.Email='StudentEmail1@email.com';
            leadRecord.Email2__c='StudentEmail2@email.com';
            //leadRecord.Parent_Email__c='ParentEmail@email.com';
           // leadRecord.Invoice_Email__c='InvoiceEmail@email.com';
            leadRecord.product__c='APP';
            leadRecord.Country='India';
        leadRecord.State='Karnataka';
        
        leadRecord.PostalCode='560090';
        
            //leadRecord.Change_Reasons__c='Does not want to travel in group';
            leadList.add(leadRecord);
        }
        return leadList;
    }

    public static list<Account> createAccountList(Integer count) {
        List<Account> accountList = new List<Account>();
        for(Integer i=0;i<count;i++){
            Account acc= new Account();
            acc.Name='TestAcc-'+i;
            accountList.add(acc);
        }
        return accountList;
    }

    public static List<Group> createPublicGroup(){
        List<Group> groupList = new List<Group>();

        return groupList;
    }


    public static dupcheck__dcJob__c createDupCheck(Lead leadRecord) {
        dupcheck__dcJob__c dupCheck = new dupcheck__dcJob__c();
        dupCheck.dupcheck__name__c ='Tset';
        dupCheck.dupcheck__status__c='Open';
        dupCheck.dupcheck__Ended__c=System.now();
        dupCheck.dupcheck__sourceObject__c = String.valueOf(leadRecord.id).subString(0,2);
        //dupCheck.dupcheck__MatchObject__c=leadRecord.id;
        return dupcheck;
    }

    public static dupcheck__dcGroup__c createdcGroup(dupcheck__dcJob__c job) {
        dupcheck__dcGroup__c dcGroup = new dupcheck__dcGroup__c();
        dcGroup.dupcheck__dcJob__c=job.id;
        dcGroup.dupcheck__group__c=6;
        return dcGroup;
    }

    public static dupcheck__dc3Duplicate__c createdc3Duplicate(dupcheck__dcJob__c job,Lead leadRecord,
            dupcheck__dcGroup__c dcGroup) {
        dupcheck__dc3Duplicate__c dc3duplicate = new dupcheck__dc3Duplicate__c();
        dc3duplicate.dupcheck__dcJob__c=job.id;
        dc3duplicate.dupcheck__sourceObject__c = leadRecord.id;
        dc3duplicate.dupcheck__MatchObject__c =leadRecord.id;
        dc3duplicate.dupcheck__Score__c=45;
        dc3duplicate.dupcheck__dcGroup__c = dcGroup.id;

        return dc3duplicate;
    }

    public static list<Lead>  insertLead() {
        Lead leadRecord = new Lead();
        leadRecord.FirstName='FirstName2';
        leadRecord.LastName='LastName';
        leadRecord.Region__c='Region' ;
        leadRecord.product__c='ILS';
        leadRecord.Program__c='ILSU';
        leadRecord.market__c='DEB';
        leadRecord.SalesOffice__c='DEB';
        leadRecord.state='Karnataka';
        leadRecord.Triton_Id__c= 'triton id123';
        leadRecord.PostalCode='560048';
        leadRecord.Phone='9988776666';
        leadRecord.MobilePhone='9988776666';
        leadRecord.Other_Phone__c='9988776666';       
        leadRecord.DOB__c=system.today();
        leadRecord.Email='StudentEmail1@email.com';
        leadRecord.Email2__c='StudentEmail2@email.com';      
       // leadRecord.product__c='APP';
        leadRecord.Country='India';
        leadRecord.City='Bang';
        leadRecord.Street='Ulsoor';
        leadRecord.RequestType__c='BR';
        leadRecord.PostalCode='560090';

        List<Lead> leadList = new List<Lead>();
        //leadList.add(newLead);
        leadList.add(leadRecord);
        //insert leadList;
        return leadList;
    }
    
    Public static List<Opportunity> createOpportunityRecordsForAddress(List<Account> accList,Integer count){
        List<Opportunity> oppList= new List<Opportunity>();
        for(Account acc:accList){
            for(Integer i=0;i<count;i++){
                Opportunity opp= new Opportunity();
                opp.Name='TestOpportunity-'+i;
                opp.AccountID=acc.ID;
                opp.Market__c='DEB';
                opp.SalesOffice__c='DEB';
                opp.Program__c='ILSU';
                opp.Product__c='ILS';
                opp.StageName='Open';
                opp.CloseDate=System.today();
                oppList.add(opp);
            }
        }       
        return oppList;
    }
    
    public static List<Account> createAccountRecordsForAddress(Integer count){
        List<Account> accList= new List<Account>();
        for(Integer i=0;i<count;i++){
            Account accRecord= new Account();
            accRecord.Name='TestAcc-'+i;
            accRecord.Market__c='DEB';
            accRecord.ShippingCountry='India';
            accRecord.ShippingCity='Bang';
            accRecord.ShippingStreet='cross';
            accRecord.ShippingState='karnataka';
            accRecord.ShippingPostalCode='560090';
            accList.add(accRecord);
        }       
        return accList;
    }
    
    public static List<Task> checkIncomingLead(List<Task> tskList){    
    List<Task> taskList = new List<Task>();
     //List<Task> tskList =[SELECT AccountId,Id,Programs__c,Market__c, WhoId FROM Task where whoid in: leadList];
    for(Task taskRecord: tskList){
        taskRecord.Type='UCC';
        taskRecord.FollowUpDate__c=system.today().addDays(20);
        taskList.add(taskRecord);
    }
    return taskList;
    }
    
   
    

    
  /* @testVisible static List<TaskSettings__mdt> customMetadata { 
    get {
        if ( customMetadata == null )
            customMetadata = [ SELECT CanCloseManually__c,CanCreateMannually__c,CreateCallType__c,ForClosedCallTypes__c,
            IsActive__c,IsCallType__c,IsTaskPerCustomer__c,Name__c,No__c,RULE__c,TaskGroup__c,Type__c,UpdateCallType__c,
            DeveloperName,MasterLabel,NamespacePrefix FROM TaskSettings__mdt ]; 
        return customMetadata;
    } set; }*/
    
   /*public static SObject Metadata(SObjectType metadataSObjectType, Map<String, Object> fields) {
    
    Map<String, Object> jsonFields = new Map<String, Object> {
        'attributes' => new Map<String, Object> {
            'type' => metadataSObjectType.getDescribe().getName()
        }
    };
    if(fields != null) {
        jsonFields.putAll(fields);
    }
    return (SObject) JSON.deserialize(JSON.serialize(jsonFields), SObject.class);
}*/

    public static List<Account>  insertAccount() {
    List<Account> accountList= new List<Account>();
        account accountRecord = new Account();
        accountRecord.Name='TestAccount';
        accountRecord.Market__c='DEB';
        accountList.add(accountRecord);   
        
        return accountList; 
        }
        
    Public static List<Opportunity> createOpportunityRecord(List<Account> accList){
    List<Opportunity> opportunityList= new List<Opportunity>();
    for(Account acc:accList){            
        Opportunity opp= new Opportunity();
        opp.Name='TestOpportunity';
        opp.AccountID=acc.ID;
        opp.Market__c='DEB';
        opp.SalesOffice__c='DEB';
        opp.Program__c='ILSU';
        opp.Product__c='ILS';
        opp.StageName='Open';
        opp.CloseDate=System.today();
        opportunityList.add(opp);
        }          
    return opportunityList;
    }

    /*public static List<Event> createEvents( List<Lead> leadList, Integer count){
        List<Event> eventList= new List<Event>();
        for(Lead lead: leadList) {
            for (Integer i = 0; i < count; i++) {
                Event eventRecord= new Event();
                eventRecord.whoid=lead.id;
                eventRecord.Subject='call';
                eventRecord.StartDateTime=System.today();
                eventRecord.EndDateTime=system.today().addDays(5);
                eventList.add(eventRecord);
            }
        }
        return eventList;

    }*/
     public static List<Event> createEvents( List<opportunity> opQuery){
        List<Event> eventList =  new List<Event>();
        for(Opportunity opp: opquery){
            Event eventRecord = new Event();
            eventRecord.Subject='test';
            eventRecord.StartDateTime=system.now();
            eventRecord.EndDateTime=system.today().adddays(12);
            eventRecord.whatid=opp.id;
            eventRecord.Type='BR';
            eventList.add(eventRecord);
        }
        return eventList;
 }

    public static List<Lead> createLeadRecords(Integer count){
        List<Lead> leadList= new List<Lead>();
        for(Integer i=0;i<count;i++){
            lead LeadRec=new lead();
            leadRec.FirstName='FirstName2';
            leadRec.LastName='TestLead-'+i;
            leadRec.Region__c='Region' ;
            leadRec.Program__c='AY';
            leadRec.market__c='DEB';
            leadRec.SalesOffice__c='DEB';
            leadRec.street='street1';
            leadRec.City='City';
            leadRec.Triton_Id__c= 'triton id123';
            leadRec.PostalCode='560048';
            leadRec.Phone='9988776666';
            leadRec.MobilePhone='9988776666';
            leadRec.Other_Phone__c='9988776666';
            leadRec.DOB__c=system.today();
            leadRec.Email='StudentEmail1@email.com';
            leadRec.Email2__c='StudentEmail2@email.com';
            leadRec.product__c='APP';
            leadList.add(leadRec);
        }
        return leadList;
    }
    
   public static Lead DynamicinsertNewLeadRecords(string firstname,string lastname,string city,string street,string state,string postalcode,string phone,
            string mobilephone,string otherphone,string tritonid,string studentemail1,string studentemail2,string region,string type,date DOB) {
        Datetime nowdatetime=datetime.now()-(1/6.0);
              
       
        Lead newLead = new Lead();
        newLead.FirstName = firstname;
        newLead.LastName = lastname;
        newLead.city = city;
        newLead.street = street;
        newLead.state = state;
        newLead.PostalCode = postalcode;
        newLead.homephone__c = phone;
        newLead.MobilePhone = mobilephone;
        newLead.Other_Phone__c = otherphone;
        newLead.Triton_Id__c = tritonid;
        newLead.Email = studentemail1;
        newLead.Email2__c = studentemail2;
        newLead.Region__c = region ;
        newLead.RequestType__c=type;
        newlead.Program__c='AY';       
        newlead.product__c='APP';
        newLead.DOB__c = DOB;
        newLead.SalesOffice__c = 'DEB';
        newLead.InsertTime__c =nowdatetime;
        newLead.Market__c='DEB';
       
        return newLead;
        //return newLead;
    }

    public static Lead createDynamicLeads(string FirstName,string LastName,string Region,string Program,string market,string SalesOffice,
            string street, string City,string Triton_Id,string PostalCode,string Phone,string MobilePhone,string OtherPhone,date DOB,string Email,string Email2, string product, string RequestType, string state,Boolean DoNotCall,string country) {
        lead leadRec=new lead();
        leadRec.FirstName= FirstName;
        leadRec.LastName= LastName;
        leadRec.Region__c= Region ;
        leadRec.Program__c=Program;
        leadRec.market__c= Market;
        leadRec.SalesOffice__c= SalesOffice;
        leadRec.street=street;
        leadRec.City=City;
        leadRec.Triton_Id__c= Triton_Id;
        leadRec.PostalCode= PostalCode;
        leadRec.Phone= Phone;
        leadRec.MobilePhone=MobilePhone;
        leadRec.Other_Phone__c= OtherPhone;
        leadRec.DOB__c= DOB;
        leadRec.Email=Email;
        leadRec.Email2__c=Email2;
        leadRec.product__c=product;
        leadRec.RequestType__c=RequestType;
        leadRec.state = State;
        leadRec.DoNotCall=DoNotCall;
        leadRec.country=country;

        return leadRec;

    }

    public static campaign createNewCampaign()
    {
        DateTime dateAndTime = DateTime.now();
        system.debug('dateAndTime'+dateAndTime);
        campaign newCampaignRecord=new campaign();
        newCampaignRecord.name='TestClass1';
        List<String> markets = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(),'Market__c').values();
        if(markets!= null &&markets.size() >0 ){
            newCampaignRecord.Market__c=markets[0];
        }
        List<String> product = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(),'Product__c').values();
        if(product!= null &&product.size() >0 ){
            newCampaignRecord.Product__c=product[0];
        }
        List<String> MeetingType = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(),'MeetingType__c').values();
        if(MeetingType!= null &&MeetingType.size() >0 ){
           newCampaignRecord.MeetingType__c=MeetingType[0];
        }
        newCampaignRecord.DateFrom__c =dateAndTime.addHours(3);
        newCampaignRecord.DateTo__c=dateAndTime.addHours(5);
        newCampaignRecord.MeetingSize__c=10;
        newCampaignRecord.SendtoEFCOM__c=true;
        newCampaignRecord.Description='Test record';
        newCampaignRecord.SalesOffice__c = FieldUtilityClass.getFieldDependencies('Campaign','Market__c','SalesOffice__c').get(markets[0])[0];
        newCampaignRecord.MeetingCity__c=FieldUtilityClass.getFieldDependencies('Campaign','Market__c','MeetingCity__c').get(markets[0])[0];
        newCampaignRecord.EFCOMMarket__c=FieldUtilityClass.getFieldDependencies('Campaign','Market__c','EFCOMMarket__c').get(markets[0])[0];
        return newCampaignRecord;
    }
    
    public static Campaign createDynamicCampaigns(string Market,string Product, string MeetingType,string salesOffice, string meetingCity, string program, string Status, Datetime datefrom,Datetime dateto,integer MeetingSize, string name)

     {
       // Datetime dateefrom=system.today().addDays(5);
       // Datetime dateeto=datefrom.addhours(2);
                     
        Campaign newCampaign = new Campaign();
        newCampaign.Market__c = Market;
        newCampaign.Product__c = Product;
        newCampaign.MeetingType__c = MeetingType;
         newCampaign.SalesOffice__c = salesOffice;
         newCampaign.MeetingCity__c = meetingCity;
         newCampaign.Program__c = program;
        newCampaign.Status = Status;
        newCampaign.DateFrom__c = datefrom;
        newCampaign.DateTo__c = dateto;
        newCampaign.MeetingSize__c = MeetingSize;
        newCampaign.Name = Name;

        return newCampaign;
        
    }
    
    public static Opportunity createOpportunity(Account newacc,string Market,string Product,string salesOffice, string program)
    {
    
    Id accountId= newacc.id;
    Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Name='TestOpportunity';
        opportunityRecord.AccountID=accountId;
        opportunityRecord.Market__c=Market;
        opportunityRecord.Product__c=Product;
        opportunityRecord.SalesOffice__c=salesOffice;
        opportunityRecord.Program__c=program;
        opportunityRecord.StageName='Open';
        opportunityRecord.CloseDate=System.today().addDays(20);
        
        return opportunityRecord;
    
    
    }

    public static Campaign createNewCampaignRecords() {
        List<Campaign> campaignList =  new List<Campaign>();
        DateTime dateAndTime = DateTime.now();
        system.debug('dateAndTime' + dateAndTime);

        for (integer i=0;i<5;i++) {
            campaign newCampaignRecord = new campaign();
            newCampaignRecord.name = 'TestClass1';
            List<String> markets = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'Market__c').values();
            if (markets != null && markets.size() > 0) {
                newCampaignRecord.Market__c = markets[0];
            }
            List<String> product = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'Product__c').values();
            if (product != null && product.size() > 0) {
                newCampaignRecord.Product__c = product[0];
            }
            List<String> MeetingType = FieldUtilityClass.getPickListValues(Campaign.getSObjectType(), 'MeetingType__c').values();
            if (MeetingType != null && MeetingType.size() > 0) {
                newCampaignRecord.MeetingType__c = MeetingType[0];
            }
            newCampaignRecord.DateFrom__c = dateAndTime.addHours(3);
            newCampaignRecord.DateTo__c = dateAndTime.addHours(5);
            newCampaignRecord.MeetingSize__c = 10;
            newCampaignRecord.SendtoEFCOM__c = true;
            newCampaignRecord.Description = 'Test record';
            newCampaignRecord.SalesOffice__c = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'SalesOffice__c').get(markets[0])[0];
            newCampaignRecord.MeetingCity__c = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'MeetingCity__c').get(markets[0])[0];
            newCampaignRecord.EFCOMMarket__c = FieldUtilityClass.getFieldDependencies('Campaign', 'Market__c', 'EFCOMMarket__c').get(markets[0])[0];
           // campaignList.add(newCampaignRecord) ;
        }
        return null;
    }
    
    public static Account creatPersonAccount() {
        Id recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account newAccount = new Account();
            newAccount.RecordTypeId=recordTypeId;
            newAccount.FirstName = 'Testfirstname';
            newAccount.LastName = 'Testlastname';
            return newAccount;

    }


}

/**************************************************************************************
Apex Class Name    : TestDataUtil
Version            : 1.0 
Created Date       : June 01 2017
Function           : Utility class for Creating the TestData.
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------                 
 * Suresh S                  06/01/2017              Original Version
 *************************************************************************************/