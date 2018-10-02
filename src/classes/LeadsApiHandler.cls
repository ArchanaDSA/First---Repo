@RestResource(urlMapping='/Lead/*')
global class LeadsApiHandler
{
    @HttpPost
    global static Boolean CreateBulkLead(LeadWrapperClass[] leadWrapperObj)
    {
        boolean success=false;
        List<Lead> leads=new List<Lead>();
        Datetime nowdatetime=datetime.now();
        try{
            for(LeadWrapperClass leadWrapper : leadWrapperObj)
            {
                /*if (AllowLead(leadWrapper)==false)
                {
                    continue;
                }*/
                Lead newLead=new Lead();
                newLead.FirstName=leadWrapper.FirstName;
                newLead.LastName=leadWrapper.LastName;
                newLead.street=leadWrapper.street;
                newLead.City=leadWrapper.City;

                newLead.PostalCode=leadWrapper.PostalCode;
                newLead.State=leadWrapper.State;
                // newLead.Country=leadWrapper.Country;
                // newLead.CountryCode=leadWrapper.CountryCode;   //some deployment issues..need to check once

                newLead.MobilePhone=leadWrapper.MobilePhone;
                newLead.Other_Phone__c=leadWrapper.OtherPhone;
                newLead.HomePhone__c=leadWrapper.LandlinePhone;

                newLead.DOB__c=leadWrapper.DOB;
                newLead.Email=leadWrapper.StudentEmail1;
                newLead.Email2__c=leadWrapper.StudentEmail2;
               // newLead.Parent_Email__c=leadWrapper.ParentEmail;
                //newLead.Invoice_Email__c=leadWrapper.InvoiceEmail;
                newLead.Region__c=leadWrapper.Region ;
                //newLead.Activity__c=LeadWrapper.Activity;
                newLead.RequestType__c=LeadWrapper.Activity;

                newLead.Product__c=LeadWrapper.Product;
                newLead.Program__c=leadWrapper.Program;
                newLead.Market__c=leadWrapper.MarketCode;
                //newLead.RecordTypeId=GetRecordTypeOnMarketCode(leadWrapper.MarketCode);
                newLead.InsertTime__c=nowdatetime;
                newLead.SalesOffice__c = 'DEB';
                newLead.ActivityDateTime__c=LeadWrapper.ActivityDate;//this field is being used in order to keep track of latest activity done by same customer.
                leads.add(newLead);
            }
            if(leads.size()>0)
            {
                success=HandleIncomingLeads(leads);
            }
            else
            {
            }}catch (Exception e){
            return false;
        }
        return success;
    }

    //It finds out the record type based on marketcode
   /* public static Id GetRecordTypeOnMarketCode(string marketCode)
    {
        recordtype rType=[select id from recordtype where name=:marketCode and IsActive=true and SObjectType='Lead'];
        return rType.Id;
    }*/
    //This function checks if an incoming Customer Request can be imported into SF or not.
    public static boolean AllowLead(LeadWrapperClass leadWrapperObj)
    {
        if (leadWrapperObj.StudentEmail1.EndsWith('@ef.com')
                ||leadWrapperObj.StudentEmail1.Contains('test')
                ||leadWrapperObj.StudentEmail2.EndsWith('@ef.com')
                ||leadWrapperObj.StudentEmail2.Contains('test')
                ||leadWrapperObj.InvoiceEmail.EndsWith('@ef.com')
                ||leadWrapperObj.InvoiceEmail.Contains('test')
                ||leadWrapperObj.ParentEmail.EndsWith('@ef.com')
                ||leadWrapperObj.ParentEmail.Contains('test'))
        {
            return false;
        }
        else
                return true;
    }
    //This function Processes the incoming Leads.
    public static boolean HandleIncomingLeads(List<Lead> incomingLeads)
    {
        boolean success=false;
        //we can add one dummy lead if there is only one incoming lead just to avoid dc api call.
        //Lead newLead=new Lead();
        // newLead.FirstName='DEMO';
        //newLead.LastName='DEMO LAst';
        //incomingLeads.add(newLead);
        success=SObjectUnitOfWork.executeInsertLeads(incomingLeads);
        if (success)
        {
            if (incomingLeads.size()==1)//if there is only one lead insert DC Search plugin does not get hit, so in this case we are explicitly calling search api.
            {
                Lead lead=incomingLeads[0];
                dupcheck.dc3Api api = new dupcheck.dc3Api();
                api.doSearch(lead);
            }
        }
        else
        {
        }
        return success;
    }
}