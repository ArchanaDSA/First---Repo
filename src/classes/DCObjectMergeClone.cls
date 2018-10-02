/**
 * Created by shravan.boddula on 9/6/2017.
 */


public with sharing class DCObjectMergeClone {
    //lead to lead merge
    public static Lead leadToLeadFieldMerge(Lead sourceLead, Lead duplicateLead, Boolean isExistingLead) {
        //1. first Name
        sourceLead.FirstName = valueLength(sourceLead.FirstName,duplicateLead.FirstName);
        //2. lastname
        sourceLead.LastName=valueLength(sourceLead.LastName,duplicateLead.LastName);
        //3. DOB
        sourceLead.DOB__c = calculateAge(sourceLead.DOB__c,duplicateLead.DOB__c);
        //4. Mobile Phone, Home phone, Oher phone
        sourceLead = phoneMerge(sourceLead,duplicateLead);
        //5. email merge
        sourceLead = emailMerge(sourceLead,duplicateLead);
        //6. address merge
        sourceLead = addressMerge(sourceLead,duplicateLead, isExistingLead);
        //7. program merge
        sourceLead.Program__c =  programMerge(DCBusinessFlow.sourceCustomerRequstType,
                DCBusinessFlow.latestCustomerRequsetType,
                sourceLead.Program__c,duplicateLead.Program__c);
        return sourceLead;
    }

    //Lead to account merge
    public static Account leadtoAccountFieldMerge(Account duplicateAccount, Lead sourceLead) {
        //1. first Name
        duplicateAccount.FirstName = valueLength(duplicateAccount.FirstName,sourceLead.FirstName);
        //2. lastname
        duplicateAccount.LastName = valueLength(duplicateAccount.LastName,sourceLead.LastName);
        //3. DOB
        duplicateAccount.DOB__c = calculateAge(duplicateAccount.DOB__c,sourceLead.DOB__c);
        //4. Mobile Phone, Home phone, other phone
        duplicateAccount = phoneLeadToAccountMerge(duplicateAccount,sourceLead);
        //5. email merge
        duplicateAccount = emailLeadToAccountMerge(duplicateAccount,sourceLead);
        //6. address merge
        duplicateAccount = addressLeadtoAccountMerge(duplicateAccount,sourceLead);
        return duplicateAccount;
    }

    //Lead to Opportuntiy
    public static void modifyOpportuntiy(Lead sourceLead, Opportunity opportunityRecord) {
        //1. program merge
        opportunityRecord.Program__c = programMerge(DCBusinessFlow.sourceCustomerRequstType,
                DCBusinessFlow.latestCustomerRequsetType,
                sourceLead.Program__c,opportunityRecord.Program__c);
        //2. stage update
        if(opportunityRecord.StageName == 'Closed Lost') {
            opportunityRecord.StageName = 'Prospecting';
        }
        //3.what should be the closed date
        update opportunityRecord;
    }

    //return the longest string
    public static String valueLength(String oldValue,String newValue) {
        return oldValue.length() > newValue.length()?oldValue:newValue;
    }
    //age calculation
    public static Date calculateAge(Date oldDate, Date newDate) {
        if(newDate != null) {
            return system.today().year() - newDate.year() > 50 ? oldDate : newDate;
        }
        return oldDate;
    }

    public static String programMerge(String sourceLeadRequestType,
            String duplicateLeadRequetType,
            String sourceProgram,String dulicateProgram) {
        String program = dulicateProgram;
        system.debug('**** source '+sourceLeadRequestType);
        system.debug('**** duplicate '+duplicateLeadRequetType);
        if(sourceLeadRequestType == 'RES') {
            system.debug('********* Im in if condition');
            system.debug('My prgam s'+sourceProgram);
            program = sourceProgram;
        }
        else if(sourceLeadRequestType != 'CAM' &&
                duplicateLeadRequetType == 'CAM') {
            system.debug('********** Im in if else condition');
            program = sourceProgram;
        }
        return program;
    }

    //mobile phone
    public static Lead phoneMerge(Lead sourceLead, Lead duplicateLead) {
        //Mobile Phone
        if(duplicateLead.MobilePhone != sourceLead.MobilePhone &&
                duplicateLead.MobilePhone != sourceLead.HomePhone__c &&
                duplicateLead.MobilePhone != sourceLead.Other_Phone__c &&
                duplicateLead.MobilePhone != NULL) {
            if(sourceLead.Other_Phone__c == null) {
                sourceLead.Other_Phone__c = sourceLead.MobilePhone;
            }
            sourceLead.MobilePhone = duplicateLead.MobilePhone;
        }
        //HOme phone
        if(duplicateLead.HomePhone__c != sourceLead.MobilePhone &&
                duplicateLead.HomePhone__c != sourceLead.HomePhone__c &&
                duplicateLead.HomePhone__c != sourceLead.Other_Phone__c &&
                duplicateLead.HomePhone__c != NULL) {
            if(sourceLead.Other_Phone__c == null) {
                sourceLead.Other_Phone__c = sourceLead.HomePhone__c;
            }
            sourceLead.HomePhone__c = duplicateLead.HomePhone__c;
        }
        //other phone
        if(duplicateLead.Other_Phone__c != sourceLead.MobilePhone &&
                duplicateLead.Other_Phone__c != sourceLead.HomePhone__c &&
                duplicateLead.Other_Phone__c != sourceLead.Other_Phone__c &&
                duplicateLead.Other_Phone__c != NULL) {
            if(duplicateLead.Other_Phone__c != null) {
                sourceLead.Other_Phone__c = duplicateLead.Other_Phone__c;
            }
        }
        return sourceLead;
    }

    public static Lead phoneMergetest(Lead sourceLead, Lead duplicateLead) {

        //Mobile Phone
        if(duplicateLead.MobilePhone != sourceLead.MobilePhone &&
                duplicateLead.MobilePhone != sourceLead.HomePhone__c &&
                duplicateLead.MobilePhone != sourceLead.Other_Phone__c &&
                duplicateLead.MobilePhone != NULL) {
            if(sourceLead.Other_Phone__c == NULL) {
                sourceLead.Other_Phone__c = sourceLead.MobilePhone;
            }else if(sourceLead.HomePhone__c == NULL){
                sourceLead.HomePhone__c = sourceLead.MobilePhone;
            }
            sourceLead.MobilePhone = duplicateLead.MobilePhone;
        }
        //HOme phone
        if(duplicateLead.HomePhone__c != sourceLead.MobilePhone &&
                duplicateLead.HomePhone__c != sourceLead.HomePhone__c &&
                duplicateLead.HomePhone__c != sourceLead.Other_Phone__c &&
                duplicateLead.HomePhone__c != NULL) {
            if(sourceLead.Other_Phone__c == NULL) {
                sourceLead.Other_Phone__c = sourceLead.HomePhone__c;
            }else if(sourceLead.HomePhone__c == NULL){
                sourceLead.MobilePhone = sourceLead.HomePhone__c;
            }
            sourceLead.HomePhone__c = duplicateLead.HomePhone__c;
        }
        //other phone
        if(duplicateLead.Other_Phone__c != sourceLead.MobilePhone &&
                duplicateLead.Other_Phone__c != sourceLead.HomePhone__c &&
                duplicateLead.Other_Phone__c != sourceLead.Other_Phone__c &&
                duplicateLead.Other_Phone__c != NULL) {
            if(sourceLead.MobilePhone == NULL) {
                sourceLead.MobilePhone = sourceLead.Other_Phone__c;
            }else if(sourceLead.HomePhone__c == NULL){
                sourceLead.HomePhone__c = sourceLead.Other_Phone__c;
            }
            sourceLead.Other_Phone__c = duplicateLead.Other_Phone__c;
        }
        return sourceLead;
    }


    //Email merge logic
    public static Lead emailMerge(Lead sourceLead, Lead duplicateLead) {
        //Email 1
        if(duplicateLead.Email != sourceLead.Email &&
                duplicateLead.Email != sourceLead.Email2__c &&
                duplicateLead.Email != NULL) {
            if(sourceLead.Email2__c == '') {
                sourceLead.Email2__c = sourceLead.Email;
            }
            sourceLead.Email = duplicateLead.Email;
        }
        //Email 2
        if(duplicateLead.Email2__c != sourceLead.Email2__c &&
                duplicateLead.Email2__c != sourceLead.Email &&
                duplicateLead.Email2__c != NULL) {
            if(sourceLead.Email == ''){
                sourceLead.Email = duplicateLead.Email2__c;
            }
            else {
                sourceLead.Email2__c = duplicateLead.Email2__c;
            }
        }
        return sourceLead;
    }
    //Address merge logic
    public static Lead addressMerge(Lead sourceLead, Lead duplicateLead, boolean isExisting) {
        if(!(sourceLead.Street == duplicateLead.Street &&
                ((sourceLead.PostalCode == duplicateLead.PostalCode
                        && sourceLead.Region__c == duplicateLead.Region__c
                        && sourceLead.City != duplicateLead.City)
                        ||
                        (sourceLead.PostalCode == duplicateLead.PostalCode
                                && sourceLead.Region__c != duplicateLead.Region__c
                                && sourceLead.City == duplicateLead.City)
                        ||
                        (sourceLead.PostalCode != duplicateLead.PostalCode
                                && sourceLead.Region__c == duplicateLead.Region__c
                                && sourceLead.City == duplicateLead.City))
        )){
            sourceLead.Street = isExisting?
                    duplicateLead.Street:valueLength(sourceLead.Street,duplicateLead.Street);
            sourceLead.PostalCode = duplicateLead.PostalCode;
            sourceLead.City = duplicateLead.City;
            sourceLead.Region__c = duplicateLead.Region__c;
        }

        return sourceLead;
    }
    //lead merge logic ends here


    public static Account phoneLeadToAccountMerge(Account duplicateAccount, Lead sourceLead) {
        //Mobile Phone
        if(duplicateAccount.PersonMobilePhone != sourceLead.MobilePhone &&
                duplicateAccount.PersonMobilePhone != sourceLead.HomePhone__c &&
                duplicateAccount.PersonMobilePhone != sourceLead.Other_Phone__c &&
                duplicateAccount.PersonMobilePhone != null) {
            if(duplicateAccount.PersonOtherPhone == null) {
                duplicateAccount.PersonOtherPhone = duplicateAccount.PersonMobilePhone;
            }
            duplicateAccount.PersonMobilePhone = sourceLead.MobilePhone;
        }
        //HOme phone
        if(duplicateAccount.PersonHomePhone != sourceLead.MobilePhone &&
                duplicateAccount.PersonHomePhone != sourceLead.HomePhone__c &&
                duplicateAccount.PersonHomePhone != sourceLead.Other_Phone__c &&
                duplicateAccount.PersonHomePhone != null) {
            if(duplicateAccount.PersonOtherPhone == null) {
                duplicateAccount.PersonOtherPhone = duplicateAccount.PersonHomePhone;
            }
            duplicateAccount.PersonHomePhone = sourceLead.HomePhone__c;
        }
        //other phone
        if(duplicateAccount.PersonOtherPhone != sourceLead.MobilePhone &&
                duplicateAccount.PersonOtherPhone != sourceLead.HomePhone__c &&
                duplicateAccount.PersonOtherPhone != sourceLead.Other_Phone__c &&
                duplicateAccount.PersonOtherPhone != null) {
            if(duplicateAccount.PersonOtherPhone != null) {
                duplicateAccount.PersonOtherPhone = sourceLead.Other_Phone__c;
            }
        }
        return duplicateAccount;
    }

    public static Account emailLeadToAccountMerge(Account duplicateAccount, Lead sourceLead) {
        //Email 1
        if(duplicateAccount.PersonEmail != sourceLead.Email &&
                duplicateAccount.PersonEmail != sourceLead.Email2__c &&
                duplicateAccount.PersonEmail != null) {
            if(duplicateAccount.Email2__c == '') {
                duplicateAccount.Email2__c = duplicateAccount.PersonEmail;
            }
            duplicateAccount.PersonEmail = sourceLead.Email;
        }
        //Email 2
        if(duplicateAccount.Email2__c != sourceLead.Email2__c &&
                duplicateAccount.Email2__c != sourceLead.Email &&
                duplicateAccount.Email2__c != null) {
            if(duplicateAccount.PersonEmail == ''){
                duplicateAccount.PersonEmail = duplicateAccount.Email2__c;
            }
            else {
                duplicateAccount.Email2__c = sourceLead.Email2__c;
            }
        }
        return duplicateAccount;
    }
    public static Account addressLeadtoAccountMerge(Account duplicateAccount,Lead sourceLead) {


        if(!(duplicateAccount.PersonMailingStreet == sourceLead.Street &&
                ((duplicateAccount.PersonMailingPostalCode == sourceLead.PostalCode
                        && duplicateAccount.Region__c == sourceLead.Region__c
                        && duplicateAccount.PersonMailingCity != sourceLead.City)
                        ||
                        (duplicateAccount.PersonMailingPostalCode == sourceLead.PostalCode
                                && duplicateAccount.Region__c != sourceLead.Region__c
                                && duplicateAccount.PersonMailingCity == sourceLead.City)
                        ||
                        (duplicateAccount.PersonMailingPostalCode != sourceLead.PostalCode
                                && duplicateAccount.Region__c == sourceLead.Region__c
                                && duplicateAccount.PersonMailingCity == sourceLead.City)
                ))){
            duplicateAccount.PersonMailingStreet = sourceLead.Street;
            duplicateAccount.PersonMailingPostalCode = sourceLead.PostalCode;
            duplicateAccount.PersonMailingCity = sourceLead.City;
            duplicateAccount.Region__c = sourceLead.Region__c;
        }
        return duplicateAccount;
    }

}