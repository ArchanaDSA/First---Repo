/**************************************************************************************
Apex Class Name    : DCBusinessHelper
Version            : 1.0
Created Date       : May 26 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  05/26/2017              Original Version
*******************************************************************************/

public with sharing class DCBusinessHelper {

    //This function makes the resulatant Leads ready for ranking after Leads are processed through the DC and Business Logic
    public static void notifyForRanking(List<Lead> resultantLeads) {
        try {
            List<Lead> updatableLeads = new List<Lead>();
            for (Lead lead : resultantLeads) {
                if (lead.IsDupeProcessed__c == true && lead.IsDupe__c == false) {
                    lead.ReadyForRanking__c = true;
                    updatableLeads.add(lead);
                }
            }
            if (updatableLeads.size() > 0) {
                SObjectUnitOfWork.executeUpdateLeads(updatableLeads);
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHelper', 'notifyForRanking', '');
        }
    }

    //This function processes the fields of Lead or Account after they are autoMerged or autoConverted.
    //Set the Fields value based on "Auto Merge rules" table.
    public static void processMergeFields(Map<Lead, DCBusinessHandler.MergeRules> duplicateIncomingLeadsWithRules,
            Lead existingLead, Account existingAccount, DCBusinessHandler.MergeRules rulesForAccount,
            Lead incomingLeadForAccount) {
        try {
            system.debug('DCBusinessHelper-Inside ProcessAfterMergeorConvert');
            boolean isLeadMerge = false;
            DCBusinessHandler.MergeRules rules = rulesForAccount;
            Lead latestIncomingLead = incomingLeadForAccount;
            List<Lead> duplicateIncomingLeads = new List<Lead>();
            if (existingLead != null) {
                if (duplicateIncomingLeadsWithRules.size() == 0)
                    return;
                for (Lead incomingLead : duplicateIncomingLeadsWithRules.keySet()) {
                    duplicateIncomingLeads.add(incomingLead);
                }
                latestIncomingLead = duplicateIncomingLeads[duplicateIncomingLeads.size() - 1];     //get the latest lead here
                rules = duplicateIncomingLeadsWithRules.get(latestIncomingLead);
                isLeadMerge = true;
            }

            string existingLandline = isLeadMerge ? existingLead.HomePhone__c : existingAccount.PersonHomePhone;
            string existingMobile = isLeadMerge ? existingLead.MobilePhone : existingAccount.PersonMobilePhone;
            string existingOther = isLeadMerge ? existingLead.Other_Phone__c : existingAccount.PersonOtherPhone;
            string existingStudentEmail1 = isLeadMerge ? existingLead.Email : existingAccount.PersonEmail;
            string existingStudentEmail2 = isLeadMerge ? existingLead.Email2__c : existingAccount.Email2__c;
            //string existingInvoiceEmail = isLeadMerge ? existingLead.Invoice_Email__c : existingAccount.Invoice_Email__c;
            //string existingParentEmail = isLeadMerge ? existingLead.Parent_Email__c : existingAccount.Parent_Email__c;
            string existingStreet = isLeadMerge ? existingLead.street : existingAccount.PersonMailingStreet;
            string existingPostalCode = isLeadMerge ? existingLead.PostalCode : existingAccount.PersonMailingPostalCode;
            string existingCity = isLeadMerge ? existingLead.City : existingAccount.personmailingcity;
            string existingRegion = isLeadMerge ? existingLead.Region__c : existingAccount.Region__c;
            string existingFirstName = isLeadMerge ? existingLead.FirstName : existingAccount.FirstName;
            string existingLastName = isLeadMerge ? existingLead.LastName : existingAccount.LastName;
            Date existingDOB = isLeadMerge ? existingLead.DOB__c : existingAccount.DOB__c;

            string updateLandline = existingLandline;
            string updateMobile = existingMobile;
            string updateOther = existingOther;
            string updateStudentEmail1 = existingStudentEmail1;
            string updateStudentEmail2 = existingStudentEmail2;
            //string updateInvoiceEmail = existingInvoiceEmail;
            // string updateParentEmail = existingParentEmail;
            string updatestreet = existingStreet;
            string updatePostalCode = existingPostalCode;string updateCity = existingCity;string updateRegion = existingRegion;
            string updateFirstName = existingFirstName;string updateLastName = existingLastName;
            Date updateDOB = existingDOB;

            //its all about phone numbers
            if (rules == DCBusinessHandler.MergeRules.Rule2) {

                PhoneMergeClass incomingPhoneObj = new PhoneMergeClass();
                incomingPhoneObj.Phone1 = latestIncomingLead.HomePhone__c;
                incomingPhoneObj.Phone2 = latestIncomingLead.MobilePhone;
                incomingPhoneObj.Phone3 = latestIncomingLead.Other_Phone__c;

                PhoneMergeClass existingPhoneObj = new PhoneMergeClass();
                existingPhoneObj.Phone1 = existingLandline;
                existingPhoneObj.Phone2 = existingMobile;
                existingPhoneObj.Phone3 = existingOther;
                PhoneMergeClass mergedPhoneObj = PhoneMergeClass.MergePhones(incomingPhoneObj, existingPhoneObj);
                updateLandline = mergedPhoneObj.Phone1;
                updateMobile = mergedPhoneObj.Phone2;
                updateOther = mergedPhoneObj.Phone3;

            } else if (rules == DCBusinessHandler.MergeRules.Rule3) {

                EmailMergeClass incomingEmailObj = new EmailMergeClass();
                incomingEmailObj.Email1 = latestIncomingLead.Email;
                incomingEmailObj.Email2 = latestIncomingLead.Email2__c;

                EmailMergeClass existingEmailObj = new EmailMergeClass();
                existingEmailObj.Email1 = existingStudentEmail1;
                existingEmailObj.Email2 = existingStudentEmail2;

                EmailMergeClass mergedEmailObj = EmailMergeClass.MergeEmails(incomingEmailObj, existingEmailObj);
                updateStudentEmail1 = mergedEmailObj.Email1;
                updateStudentEmail2 = mergedEmailObj.Email2;
                /*
                updateInvoiceEmail = !String.isBlank(latestIncomingLead.Invoice_Email__c) && latestIncomingLead.Invoice_Email__c != existingInvoiceEmail
                        ? latestIncomingLead.Invoice_Email__c : existingInvoiceEmail;
                        */

            } else if (rules == DCBusinessHandler.MergeRules.Rule4) {
                updatestreet = !String.isBlank(latestIncomingLead.street) ?
                        (isLeadMerge ? getMergedstreet(duplicateIncomingLeads) : getMergedstreet(existingAccount, latestIncomingLead)) : existingStreet;
            } else if (rules == DCBusinessHandler.MergeRules.Rule6) {
                //retain existing city: nothing to do here.
            } else if (rules == DCBusinessHandler.MergeRules.Rule7) {
                updatePostalCode = !String.isBlank(latestIncomingLead.PostalCode) && IsNumeric(latestIncomingLead.PostalCode) ? latestIncomingLead.PostalCode : existingPostalCode;
            } else if (rules == DCBusinessHandler.MergeRules.Rule8) {
                updateRegion = !String.isBlank(latestIncomingLead.Region__c) ? latestIncomingLead.Region__c : existingRegion;
            } else if (rules == DCBusinessHandler.MergeRules.Rule9) {
                updateDOB = latestIncomingLead.DOB__c != null && latestIncomingLead.DOB__c.year() > 1960 ? latestIncomingLead.DOB__c : existingDOB;
            } else if (rules == DCBusinessHandler.MergeRules.Rule10) {
                updateLastName = !String.isBlank(latestIncomingLead.LastName) && latestIncomingLead.LastName == existingFirstName ? existingLastName : latestIncomingLead.LastName;
            } else if (rules == DCBusinessHandler.MergeRules.Rule11) {
                updateFirstName = !String.isBlank(latestIncomingLead.FirstName) && latestIncomingLead.FirstName == existingLastName ? existingFirstName : latestIncomingLead.FirstName;
            } else if (rules == DCBusinessHandler.MergeRules.Rule12) {
                updatestreet = !String.isBlank(latestIncomingLead.street) ? latestIncomingLead.street : existingstreet;
                updatePostalCode = !String.isBlank(latestIncomingLead.PostalCode) && IsNumeric(latestIncomingLead.PostalCode) ? latestIncomingLead.PostalCode : existingPostalCode;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
            } else if (rules == DCBusinessHandler.MergeRules.Rule17) {
                updatePostalCode = !String.isBlank(existingPostalCode) && IsNumeric(existingPostalCode) ? existingPostalCode : latestIncomingLead.PostalCode;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
                updateRegion = !String.isBlank(latestIncomingLead.Region__c) ? latestIncomingLead.Region__c : existingRegion;
            } else if (rules == DCBusinessHandler.MergeRules.Rule19) {
                updatestreet = !String.isBlank(latestIncomingLead.street) ? latestIncomingLead.street : existingstreet;
                updatePostalCode = !String.isBlank(latestIncomingLead.PostalCode) && IsNumeric(latestIncomingLead.PostalCode) ? latestIncomingLead.PostalCode : existingPostalCode;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
                updateRegion = !String.isBlank(latestIncomingLead.Region__c) ? latestIncomingLead.Region__c : existingRegion;
            } else if (rules == DCBusinessHandler.MergeRules.Rule20) {
                updateFirstName = !String.isBlank(latestIncomingLead.FirstName) && latestIncomingLead.FirstName == existingFirstName ? existingFirstName : latestIncomingLead.FirstName;
                updatestreet = !String.isBlank(latestIncomingLead.street) ? latestIncomingLead.street : existingstreet;
                updatePostalCode = !String.isBlank(latestIncomingLead.PostalCode) && IsNumeric(latestIncomingLead.PostalCode) ? latestIncomingLead.PostalCode : existingPostalCode;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
                updateRegion = !String.isBlank(latestIncomingLead.Region__c) ? latestIncomingLead.Region__c : existingRegion;
            } else if (rules == DCBusinessHandler.MergeRules.Rule21) {
                PhoneMergeClass incomingPhoneObj = new PhoneMergeClass();
                incomingPhoneObj.Phone1 = latestIncomingLead.HomePhone__c;
                incomingPhoneObj.Phone2 = latestIncomingLead.MobilePhone;
                incomingPhoneObj.Phone3 = latestIncomingLead.Other_Phone__c;
                PhoneMergeClass existingPhoneObj = new PhoneMergeClass();
                existingPhoneObj.Phone1 = existingLandline;
                existingPhoneObj.Phone2 = existingMobile;
                existingPhoneObj.Phone3 = existingOther;
                PhoneMergeClass mergedPhoneObj = PhoneMergeClass.MergePhones(incomingPhoneObj, existingPhoneObj);
                updateLandline = mergedPhoneObj.Phone1;
                updateMobile = mergedPhoneObj.Phone2;
                updateOther = mergedPhoneObj.Phone3;
                updatestreet = !String.isBlank(latestIncomingLead.street) ? latestIncomingLead.street : existingstreet;
                updatePostalCode = !String.isBlank(latestIncomingLead.PostalCode) && IsNumeric(latestIncomingLead.PostalCode) ? latestIncomingLead.PostalCode : existingPostalCode;
                updateRegion = !String.isBlank(latestIncomingLead.Region__c) ? latestIncomingLead.Region__c : existingRegion;
            } else if (rules == DCBusinessHandler.MergeRules.Rule25) {
                PhoneMergeClass incomingPhoneObj = new PhoneMergeClass();
                incomingPhoneObj.Phone1 = latestIncomingLead.HomePhone__c;
                incomingPhoneObj.Phone2 = latestIncomingLead.MobilePhone;
                incomingPhoneObj.Phone3 = latestIncomingLead.Other_Phone__c;
                PhoneMergeClass existingPhoneObj = new PhoneMergeClass();
                existingPhoneObj.Phone1 = existingLandline;
                existingPhoneObj.Phone2 = existingMobile;
                existingPhoneObj.Phone3 = existingOther;
                PhoneMergeClass mergedPhoneObj = PhoneMergeClass.MergePhones(incomingPhoneObj, existingPhoneObj);
                updateLandline = mergedPhoneObj.Phone1;
                updateMobile = mergedPhoneObj.Phone2;
                updateOther = mergedPhoneObj.Phone3;
                updatestreet = !String.isBlank(latestIncomingLead.street) ? latestIncomingLead.street : existingstreet;
            } else if (rules == DCBusinessHandler.MergeRules.Rule26) {
                updateStreet = !String.isBlank(latestIncomingLead.street) ?
                        (isLeadMerge ? GetMergedstreet(duplicateIncomingLeads) : GetMergedstreet(existingAccount, latestIncomingLead)) : existingstreet;

                updatePostalCode = !String.isBlank(latestIncomingLead.PostalCode) && IsNumeric(latestIncomingLead.PostalCode) ? latestIncomingLead.PostalCode : existingPostalCode;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
                updateRegion = !String.isBlank(latestIncomingLead.Region__c) ? latestIncomingLead.Region__c : existingRegion;
            } else if (rules == DCBusinessHandler.MergeRules.Rule27) {
                PhoneMergeClass incomingPhoneObj = new PhoneMergeClass();
                incomingPhoneObj.Phone1 = latestIncomingLead.HomePhone__c;
                incomingPhoneObj.Phone2 = latestIncomingLead.MobilePhone;
                incomingPhoneObj.Phone3 = latestIncomingLead.Other_Phone__c;
                PhoneMergeClass existingPhoneObj = new PhoneMergeClass();
                existingPhoneObj.Phone1 = existingLandline;
                existingPhoneObj.Phone2 = existingMobile;
                existingPhoneObj.Phone3 = existingOther;
                PhoneMergeClass mergedPhoneObj = PhoneMergeClass.MergePhones(incomingPhoneObj, existingPhoneObj);
                updateLandline = mergedPhoneObj.Phone1;
                updateMobile = mergedPhoneObj.Phone2;
                updateOther = mergedPhoneObj.Phone3;
                updatestreet = !String.isBlank(latestIncomingLead.street) ? latestIncomingLead.street : existingstreet;
            } else if (rules == DCBusinessHandler.MergeRules.Rule28) {
                EmailMergeClass incomingEmailObj = new EmailMergeClass();
                incomingEmailObj.Email1 = latestIncomingLead.Email;
                incomingEmailObj.Email2 = latestIncomingLead.Email2__c;

                EmailMergeClass existingEmailObj = new EmailMergeClass();
                existingEmailObj.Email1 = existingStudentEmail1;
                existingEmailObj.Email2 = existingStudentEmail2;

                EmailMergeClass mergedEmailObj = EmailMergeClass.MergeEmails(incomingEmailObj, existingEmailObj);
                updateStudentEmail1 = mergedEmailObj.Email1;
                updateStudentEmail2 = mergedEmailObj.Email2;
                /**
                updateInvoiceEmail = !String.isBlank(latestIncomingLead.Invoice_Email__c) && latestIncomingLead.Invoice_Email__c != existingInvoiceEmail
                        ? latestIncomingLead.Invoice_Email__c : existingInvoiceEmail;
                updateParentEmail = !String.isBlank(latestIncomingLead.Parent_Email__c) && latestIncomingLead.Parent_Email__c != existingParentEmail
                        ? latestIncomingLead.Parent_Email__c : existingParentEmail;
                        **/

                PhoneMergeClass incomingPhoneObj = new PhoneMergeClass();
                incomingPhoneObj.Phone1 = latestIncomingLead.HomePhone__c;
                incomingPhoneObj.Phone2 = latestIncomingLead.MobilePhone;
                incomingPhoneObj.Phone3 = latestIncomingLead.Other_Phone__c;

                PhoneMergeClass existingPhoneObj = new PhoneMergeClass();
                existingPhoneObj.Phone1 = existingLandline;
                existingPhoneObj.Phone2 = existingMobile;
                existingPhoneObj.Phone3 = existingOther;

                PhoneMergeClass mergedPhoneObj = PhoneMergeClass.MergePhones(incomingPhoneObj, existingPhoneObj);
                updateLandline = mergedPhoneObj.Phone1;
                updateMobile = mergedPhoneObj.Phone2;
                updateOther = mergedPhoneObj.Phone3;

            } else if (rules == DCBusinessHandler.MergeRules.Rule31) {
                updateLastName = !String.isBlank(latestIncomingLead.LastName) &&
                        existingLastName.length() > latestIncomingLead.LastName.length() ? existingLastName : latestIncomingLead.LastName;
                updatePostalCode = !String.isBlank(latestIncomingLead.PostalCode) && IsNumeric(latestIncomingLead.PostalCode) ? latestIncomingLead.PostalCode : existingPostalCode;
            } else if (rules == DCBusinessHandler.MergeRules.Rule32) {
                updateLastName = !String.isBlank(latestIncomingLead.LastName) &&
                        existingLastName.length() > latestIncomingLead.LastName.length() ? existingLastName : latestIncomingLead.LastName;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
            } else if (rules == DCBusinessHandler.MergeRules.Rule33) {
                updateDOB = latestIncomingLead.DOB__c != null && latestIncomingLead.DOB__c.year() > 1960 ? latestIncomingLead.DOB__c : existingDOB;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
            } else if (rules == DCBusinessHandler.MergeRules.Rule37) {
                updateDOB = latestIncomingLead.DOB__c != null && latestIncomingLead.DOB__c.year() > 1960 ? latestIncomingLead.DOB__c : existingDOB;
                updateCity = !String.isBlank(latestIncomingLead.City) ? latestIncomingLead.City : existingCity;
                updateRegion = !String.isBlank(latestIncomingLead.Region__c) ? latestIncomingLead.Region__c : existingRegion;
                PhoneMergeClass incomingPhoneObj = new PhoneMergeClass();
                incomingPhoneObj.Phone1 = latestIncomingLead.HomePhone__c;
                incomingPhoneObj.Phone2 = latestIncomingLead.MobilePhone;
                incomingPhoneObj.Phone3 = latestIncomingLead.Other_Phone__c;
                PhoneMergeClass existingPhoneObj = new PhoneMergeClass();
                existingPhoneObj.Phone1 = existingLandline;
                existingPhoneObj.Phone2 = existingMobile;
                existingPhoneObj.Phone3 = existingOther;

                PhoneMergeClass mergedPhoneObj = PhoneMergeClass.MergePhones(incomingPhoneObj, existingPhoneObj);
                updateLandline = mergedPhoneObj.Phone1;
                updateMobile = mergedPhoneObj.Phone2;
                updateOther = mergedPhoneObj.Phone3;
            }
            if (isLeadMerge) {
                existingLead.HomePhone__c = updateLandline;
                existingLead.MobilePhone = updateMobile;
                existingLead.Other_Phone__c = updateOther;
                existingLead.Email = updateStudentEmail1;
                existingLead.Email2__c = updateStudentEmail2;
                //existingLead.Invoice_Email__c = updateInvoiceEmail;
                existingLead.street = updatestreet;
                existingLead.PostalCode = updatePostalCode;
                existingLead.City = updateCity;
                existingLead.Region__c = updateRegion;
                existingLead.FirstName = updateFirstName;
                existingLead.LastName = updateLastName;
                existingLead.DOB__c = updateDOB;

            }

            else {

                existingAccount.PersonHomePhone = updateLandline;
                existingAccount.PersonMobilePhone = updateMobile;
                existingAccount.PersonOtherPhone = updateOther;
                existingAccount.PersonEmail = updateStudentEmail1;
                existingAccount.Email2__c = updateStudentEmail2;
                //existingAccount.Invoice_Email__c = updateInvoiceEmail;
                existingAccount.PersonMailingStreet = updatestreet;
                existingAccount.PersonMailingPostalCode = updatePostalCode;
                existingAccount.PersonMailingCity = updateCity;
                existingAccount.Region__c = updateRegion;
                existingAccount.FirstName = updateFirstName;
                existingAccount.LastName = updateLastName;
                existingAccount.DOB__c = updateDOB;
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHelper', 'processAfterMergeorConvert', '');
        }
    }

    //Logic to merge street
    private static string getMergedstreet(Account existingAccount, lead incomingLead) {
        try {
            string maxLengthstreet = '';
            if (existingAccount.PersonMailingStreet != null && existingAccount.PersonMailingStreet.Length() > incomingLead.street.Length()) {
                maxLengthstreet = existingAccount.PersonMailingStreet;
            } else {
                maxLengthstreet = incomingLead.street;
            }
            return maxLengthstreet;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHelper', 'getMergedstreet', '');
            return null;
        }
    }

    //Logic to merge stree
    private static string getMergedstreet(List<Lead> duplicateLeads) {
        try {
            integer max = 0;
            string maxLengthstreet = '';
            for (Lead duplicateLead : duplicateLeads) {
                if (duplicateLead.street != null && duplicateLead.street.Length() >= max) {
                    max = duplicateLead.street.Length();
                    maxLengthstreet = duplicateLead.street;
                }
            }
            return maxLengthstreet;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHelper', 'getMergedstreet', '');
            return null;
        }
    }


    //This function gets the appropiate Program into the Merged Lead or converted Opportunity based on Business.
    //Workes based on "Merging Rules"
    public static string getProgramAfterMerge(Lead leadToBeRetained, List<Lead> duplicateIncomingLeads) {
        try {
            List<Lead> mergableLeads = new List<Lead>(duplicateIncomingLeads);
            mergableLeads.add(leadToBeRetained);
            string resultantProgram = mergableLeads[0].Program__c;
            List<Lead> leadsWithRES = LeadsSelector.getLeadsWithReservations(mergableLeads);
            if (leadsWithRES.size() > 0) {
                resultantProgram = leadsWithRES[0].Program__c;
            } else {
                List<Lead> sortedLeads = LeadsSelector.getSortedLeadsOnActivityDate(mergableLeads);
                resultantProgram = sortedLeads[0].Program__c;
            }
            return resultantProgram;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHelper', 'getProgramAfterMerge', '');
            return null;
        }
    }

    public static boolean IsQualifiedLead(Lead lead) {
        try {
            boolean qualified = lead.RequestType__c == 'CAM' ? false : true;
            return qualified;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCBusinessHelper', 'IsQualifiedLead', '');
            return null;
        }
    }

    public static void createDCDiscard(ID sourceAccID, ID destAccID) {

        dupcheck__dcDiscard__c discObj = new dupcheck__dcDiscard__c();
        discObj.dupcheck__objectA__c = sourceAccID;
        discObj.dupcheck__recordA__c = sourceAccID;
        discObj.dupcheck__objectB__c = destAccID;
        discObj.dupcheck__recordB__c = destAccID;
        insert discObj;
    }

    public static Boolean IsNumeric(string str)
    {
        Pattern isnumber = Pattern.Compile('^[0-9]+$');
        Matcher postalMatch = isnumber.matcher(str);
        if (postalMatch.matches())
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}