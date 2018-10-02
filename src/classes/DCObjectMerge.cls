/**
 * Created by shravan.boddula on 9/6/2017.
 */


public with sharing class DCObjectMerge {
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
        //6. address mergealeim
        sourceLead = addressMerge(sourceLead,duplicateLead, isExistingLead);
        //7. program merge
        system.debug('********* source type'+DCBusinessFlow.sourceCustomerRequstType);
        system.debug('********* latest type'+DCBusinessFlow.latestCustomerRequsetType);
        //if(sourceLead.Program__c == 'MULTI' || programMerge(DCBusinessFlow.sourceCustomerRequstType,DCBusinessFlow.latestCustomerRequsetType)) {
        if((sourceLead.Program__c == Label.MULTI) || (duplicateLead.RequestType__c == 'RES') ||
                (duplicateLead.RequestType__c != 'CAM' && sourceLead.RequestType__c == 'CAM')) {
            sourceLead.Product__c = duplicateLead.Product__c;
            sourceLead.Program__c = duplicateLead.Program__c;
        }
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
        system.debug('^^^^^^^^^^^^ final acocunt'+duplicateAccount);
        system.debug('duplicateAccount>>>>>'+duplicateAccount);
        return duplicateAccount;
    }

    //Lead to Opportuntiy
    public static void modifyOpportuntiy(Lead sourceLead, Opportunity opportunityRecord) {
        //1. stage update
        if(opportunityRecord.StageName == Label.ClosedLost) {
            // Always for revival
            opportunityRecord.StageName = Label.Prospecting;
            opportunityRecord.CloseDate = System.today()+90;
            if(sourceLead.RequestType__c != 'CAM'){
                opportunityRecord.Product__c = sourceLead.Product__c;
                opportunityRecord.Program__c = sourceLead.Program__c;
            }
        }else{
            // this is to update the program for exiting opportunity but no closedlost
            system.debug('**** product'+sourceLead.Product__c);
            system.debug('**** program'+sourceLead.Program__c);
            if(programMerge(DCBusinessFlow.sourceCustomerRequstType,opportunityRecord.Program__c)) {
                opportunityRecord.Product__c = sourceLead.Product__c;
                opportunityRecord.Program__c = sourceLead.Program__c;
            }
        }
        SObjectUnitOfWork.modifyOpportunity(opportunityRecord);
    }

    public static void inActiveOpportunity(Opportunity opportunityRecord) {
        opportunityRecord.isActive__c = false;
        SObjectUnitOfWork.modifyOpportunity(opportunityRecord);
    }

    //return the longest string
    public static String valueLength(String oldValue,String newValue) {
        String temp = '';
        if((oldValue != null && oldValue.length() > 0) &&
                (newValue != null && newValue.length() > 0 )) {
            temp = oldValue.length() > newValue.length()?oldValue:newValue;
        }
        else if(oldValue == null) {
            temp = newValue;
        }
        else if(newValue == null) {
            temp = oldValue;
        }
        return temp;
    }
    //age calculation
    public static Date calculateAge(Date oldDate, Date newDate) {
        if(newDate != null) {
            return system.today().year() - newDate.year() > 50 ? oldDate : newDate;
        }
        return oldDate;
    }

    public static Boolean programMerge(String sourceLeadRequestType,String dulicateProgram) {
        Boolean isupdate= false;
        if(sourceLeadRequestType != null &&
                (sourceLeadRequestType == Label.Reservation || dulicateProgram == Label.MULTI)
                || (sourceLeadRequestType != 'CAM' && DCBusinessFlow.latestCustomerRequsetType == 'CAM')) {
            isupdate = true;
        }
        return isupdate;
    }

    //mobile phone

    public static Lead phoneMerge(Lead extLead, Lead duplicateLead) {

        //Mobile Phone
        if(duplicateLead.MobilePhone != extLead.MobilePhone &&
                duplicateLead.MobilePhone != extLead.HomePhone__c &&
                duplicateLead.MobilePhone != extLead.Other_Phone__c &&
                duplicateLead.MobilePhone != NULL) {
            if(extLead.Other_Phone__c == NULL) {
                extLead.Other_Phone__c = extLead.MobilePhone;
            }else if(extLead.HomePhone__c == NULL){
                extLead.HomePhone__c = extLead.MobilePhone;
            }
            extLead.MobilePhone = duplicateLead.MobilePhone;
        }
        //HOme phone
        if(duplicateLead.HomePhone__c != extLead.MobilePhone &&
                duplicateLead.HomePhone__c != extLead.HomePhone__c &&
                duplicateLead.HomePhone__c != extLead.Other_Phone__c &&
                duplicateLead.HomePhone__c != NULL) {
            if(extLead.Other_Phone__c == NULL) {
                extLead.Other_Phone__c = extLead.HomePhone__c;
            }else if(extLead.HomePhone__c == NULL){
                extLead.MobilePhone = extLead.HomePhone__c;
            }
            extLead.HomePhone__c = duplicateLead.HomePhone__c;
        }
        //other phone
        if(duplicateLead.Other_Phone__c != extLead.MobilePhone &&
                duplicateLead.Other_Phone__c != extLead.HomePhone__c &&
                duplicateLead.Other_Phone__c != extLead.Other_Phone__c &&
                duplicateLead.Other_Phone__c != NULL) {
            if(extLead.MobilePhone == NULL) {
                extLead.MobilePhone = extLead.Other_Phone__c;
            }else if(extLead.HomePhone__c == NULL){
                extLead.HomePhone__c = extLead.Other_Phone__c;
            }
            extLead.Other_Phone__c = duplicateLead.Other_Phone__c;
        }
        return extLead;
    }

    //Email merge logic
    /*
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
    }*/

    //Email merge logic
    public static Lead emailMerge(Lead extLead, Lead duplicateLead) {
        //Email 1
        if(duplicateLead.Email != extLead.Email &&
                duplicateLead.Email != extLead.Email2__c &&
                duplicateLead.Email != NULL) {
            if(extLead.Email2__c == NULL) {
                extLead.Email2__c = extLead.Email;
            }
            extLead.Email = duplicateLead.Email;
        }
        //Email 2
        if(duplicateLead.Email2__c != extLead.Email2__c &&
                duplicateLead.Email2__c != extLead.Email &&
                duplicateLead.Email2__c != NULL) {
            if(extLead.Email == NULL){
                extLead.Email = duplicateLead.Email2__c;
            }
            else {
                extLead.Email2__c = duplicateLead.Email2__c;
            }
        }
        return extLead;
    }


    //Address merge logic
    public static Lead addressMerge(Lead sourceLead, Lead duplicateLead, boolean isExisting) {
        if(sourceLead.Street == NULL && (
                duplicateLead.PostalCode != NULL ||
                        duplicateLead.City  != NULL ||
                        duplicateLead.Region__c != NULL
        )) {
            sourceLead.Street = isExisting ?
                    duplicateLead.Street : valueLength(sourceLead.Street, duplicateLead.Street);
            sourceLead.PostalCode = duplicateLead.PostalCode;
            sourceLead.City = duplicateLead.City;
            sourceLead.Region__c = duplicateLead.Region__c;
        }else if(duplicateLead.Street == NULL && sourceLead.Street != NULL){
            //
        }
        else if(!(sourceLead.Street == duplicateLead.Street &&
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
/*
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
    }*/

    public static Account phoneLeadToAccountMerge(Account extAccount, Lead duplicateLead) {

        //Mobile Phone 
        if(duplicateLead.MobilePhone != extAccount.PersonMobilePhone &&
                duplicateLead.MobilePhone != extAccount.PersonHomePhone &&
                duplicateLead.MobilePhone != extAccount.PersonOtherPhone &&
                duplicateLead.MobilePhone != NULL) {
            if(extAccount.PersonOtherPhone == NULL) {
                extAccount.PersonOtherPhone = extAccount.PersonMobilePhone;
            }else if(extAccount.PersonHomePhone == NULL){
                extAccount.PersonHomePhone = extAccount.PersonMobilePhone;
            }
            extAccount.PersonMobilePhone = duplicateLead.MobilePhone;
            system.debug('My mobile phone'+extAccount.PersonMobilePhone);
        }
        //HOme phone
        if(duplicateLead.HomePhone__c != extAccount.PersonMobilePhone &&
                duplicateLead.HomePhone__c != extAccount.PersonHomePhone &&
                duplicateLead.HomePhone__c != extAccount.PersonOtherPhone &&
                duplicateLead.HomePhone__c != NULL) {
            if(extAccount.PersonOtherPhone == NULL) {
                extAccount.PersonOtherPhone = extAccount.PersonHomePhone;
            }else if(extAccount.PersonHomePhone == NULL){
                extAccount.PersonMobilePhone = extAccount.PersonHomePhone;
            }
            extAccount.PersonHomePhone = duplicateLead.HomePhone__c;
        }
        //other phone
        if(duplicateLead.Other_Phone__c != extAccount.PersonMobilePhone &&
                duplicateLead.Other_Phone__c != extAccount.PersonHomePhone &&
                duplicateLead.Other_Phone__c != extAccount.PersonOtherPhone &&
                duplicateLead.Other_Phone__c != NULL) {
            if(extAccount.PersonMobilePhone == NULL) {
                extAccount.PersonMobilePhone = extAccount.PersonOtherPhone;
            }else if(extAccount.PersonHomePhone == NULL){
                extAccount.PersonHomePhone = extAccount.PersonOtherPhone;
            }
            extAccount.PersonOtherPhone = duplicateLead.Other_Phone__c;
        }
        return extAccount;
    }

    public static Account emailLeadToAccountMerge(Account extAccount, Lead duplicateLead) {
        //Email 1
        if(duplicateLead.Email != extAccount.PersonEmail &&
                duplicateLead.Email != extAccount.Email2__c &&
                duplicateLead.Email != NULL) {
            if(extAccount.Email2__c == NULL) {
                extAccount.Email2__c = extAccount.PersonEmail;
            }
            extAccount.PersonEmail = duplicateLead.Email;
        }
        //Email 2
        if(duplicateLead.Email2__c != extAccount.Email2__c &&
                duplicateLead.Email2__c != extAccount.PersonEmail &&
                duplicateLead.Email2__c != NULL) {
            if(extAccount.PersonEmail == NULL){
                extAccount.PersonEmail = duplicateLead.Email2__c;
            }
            else {
                extAccount.Email2__c = duplicateLead.Email2__c;
            }
        }
        return extAccount;
    }


    public static Account addressLeadtoAccountMerge(Account duplicateAccount,Lead sourceLead) {
        if(duplicateAccount.PersonMailingStreet == NULL && (
                sourceLead.PostalCode != NULL ||
                        sourceLead.City  != NULL ||
                        sourceLead.Region__c != NULL
        )) {
            duplicateAccount.PersonMailingStreet = sourceLead.Street;
            duplicateAccount.PersonMailingPostalCode = sourceLead.PostalCode;
            duplicateAccount.PersonMailingCity = sourceLead.City;
            duplicateAccount.Region__c = sourceLead.Region__c;
        }else if(sourceLead.Street == NULL && duplicateAccount.PersonMailingStreet != NULL){
            //
        }

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