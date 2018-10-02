public with sharing class DCMergeRuleEngine {
    /*This function has the logic of deciding what rule gets applied when there is an
    incoming Lead based on Bussiness logic
     */

    public static Map<String, LeadAccountMapping__c> leadAccountMapping = new Map<String, LeadAccountMapping__c>();
    public static Map<String, String> fieldAPIAndLabelMap = new Map<String, String>();
    public static Map<String,MergeRuleConfig__c> mergeRuleMap = new Map<String,MergeRuleConfig__c>();
    public static map<string, string> ruleNameAndTritonIdMap = new map<string, string>();
    public static String findAutoMergeRule(Lead sourceLead, Lead destLead, Account destAccount) {
        try {
            Boolean destHasBooking = destAccount != null ? destAccount.HasBooking__c : false;

            //query part is removed
            string resultantBinaryCode;
            string decision = '';
            string rulename;
            String binaryRuleCode = '';
            Map<String, LeadAccountMapping__c> leadAccountMapping = LeadAccountMapping__c.getAll();
            for (string field:fieldAPIAndLabelMap.keyset()) {
                //Lead

                if (destLead != null) {
                    if (field == constant.Has_Booking) {
                        binaryRuleCode+=constant.stringZero;
                    } else if (field == Constant.HOMEPHONE || field == Constant.MOBILEPHONE ||
                            field == Constant.OTHERPHONE) {
                        if (
                                sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                        destLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ||

                                        sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                                destLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c)){

                            binaryRuleCode+=constant.stringOne;
                        } else {
                            binaryRuleCode+=constant.stringZero;
                        }
                    } else if(field == Constant.EMAILONEFIELD || field == Constant.EMAILSECONDFIELD){
                        if(sourceLead.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Lead_API_Name__c) ==
                                destLead.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Lead_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Lead_API_Name__c) ==
                                        destLead.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Lead_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Lead_API_Name__c) ==
                                        destLead.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Lead_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Lead_API_Name__c) ==
                                        destLead.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Lead_API_Name__c)) {
                            binaryRuleCode+=Constant.StringOne;

                        }
                        else {
                            binaryRuleCode+=Constant.StringZero;
                        }
                    }else {
                        if (sourceLead.get(leadAccountMapping.get(field).Lead_API_Name__c) ==
                                destLead.get(leadAccountMapping.get(field).Lead_API_Name__c) && !(sourceLead.get(leadAccountMapping.get(field).Lead_API_Name__c)==null && destLead.get(leadAccountMapping.get(field).Lead_API_Name__c)==null)) {
                            binaryRuleCode+=constant.stringOne;
                        } else {
                            binaryRuleCode+=constant.stringZero;
                        }
                    }
                }
                //Account
                else if (destAccount != null) {
                    if (field == constant.Has_Booking) {
                        if (destAccount.HasBooking__c) {
                            binaryRuleCode+=constant.stringOne;
                        } else {
                            binaryRuleCode+=constant.stringZero;
                        }
                    } else if (field == Constant.HOMEPHONE || field == Constant.MOBILEPHONE || field ==
                            Constant.OTHERPHONE) {
                        if (sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                destAccount.get(leadAccountMapping.get(Constant.HOMEPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.MOBILEPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.OTHERPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.MOBILEPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.HOMEPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.OTHERPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.OTHERPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.MOBILEPHONE).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.HOMEPHONE).Account_API_Name__c)
                                ) {
                            binaryRuleCode+=constant.stringOne;
                        } else {
                            binaryRuleCode+=constant.stringZero;
                        }
                    }
                    else if(field == Constant.EMAILONEFIELD || field == Constant.EMAILSECONDFIELD) {
                        if(sourceLead.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Lead_API_Name__c) ==
                                destAccount.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Account_API_Name__c) ||

                                sourceLead.get(leadAccountMapping.get(Constant.EMAILONEFIELD).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Account_API_Name__c) ||
                                sourceLead.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.EMAILSECONDFIELD).Account_API_Name__c)
                                ) {
                            binaryRuleCode += constant.stringOne;
                        }
                        else {
                            binaryRuleCode+=constant.stringZero;
                        }
                    }
                    else {
                        if (sourceLead.get(leadAccountMapping.get(field).Lead_API_Name__c) ==
                                destAccount.get(leadAccountMapping.get(field).Account_API_Name__c) && !(sourceLead.get(leadAccountMapping.get(field).Lead_API_Name__c)==null && destAccount.get(leadAccountMapping.get(field).Account_API_Name__c)==null)) {
                            binaryRuleCode+=constant.stringOne;
                        } else {
                            binaryRuleCode+=constant.stringZero;
                        }
                    }
                }
                resultantBinaryCode =  binaryRuleCode;
            }
            //return the decision
            system.debug('My binary code is'+resultantBinaryCode);
            system.debug('My mregerulemapis@@@@@'+mergeRuleMap);
            if(mergeRuleMap.containsKey(resultantBinaryCode)) {

                if (ruleNameAndTritonIdMap.get(ruleName) != constant.stringNA && ruleNameAndTritonIdMap.get(ruleName) != null) {

                    if (sourceLead.Triton_Id__c == destLead.Triton_Id__c) {
                        if (ruleNameAndTritonIdMap.get(ruleName) == constant.stringTrue)
                            decision = mergeRuleMap.get(resultantBinaryCode).Decision__c;
                    } else {
                        if (ruleNameAndTritonIdMap.get(ruleName) == constant.stringFalse) {
                            decision = mergeRuleMap.get(resultantBinaryCode).Decision__c;
                        }
                    }
                } else {
                    decision = mergeRuleMap.get(resultantBinaryCode).Decision__c;
                }


                system.debug('custom setting map contains binary key --- '+mergeRuleMap.get(resultantBinaryCode).Decision__c);
                system.debug('My decision is>>>>>'+mergeRuleMap.get(resultantBinaryCode).Decision__c);
                sourceLead.DuplicateRecordSets__c = mergeRuleMap.get(resultantBinaryCode).Decision__c + ' '+
                        mergeRuleMap.get(resultantBinaryCode).Name;
                return decision;
            }
            return '';
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCRuleEngine', 'newIsMergeOrConvert', '');
            return '';
        }
    }

    public static void loadMergeConfigRuleData() {
        try {
            string [] customSettingRuleValues = new string[]{};
            String resultantBinaryCode = '';
            Map<String, Schema.SObjectField> fieldsMap = MergeRuleConfig__c.sObjectType.getDescribe().fields.getMap();
            for (String field : fieldsMap.keySet()) {
                Schema.SObjectField F = fieldsMap.get(field);
                Schema.DescribeFieldResult R = F.getDescribe();

                if (R.isCustom() && !(R.getLabel() == constant.Decision || R.getLabel() == constant.triton_id)) {
                    String fName = R.getName();
                    String fLabel = R.getLabel();
                    fieldAPIAndLabelMap.put(fLabel, fName);
                }
            }
            Map<String, MergeRuleConfig__c> mapCodes = new map<String, MergeRuleConfig__c>();
            //  mapcodes = MergeRuleConfig__c.getAll();
            mapcodes = CustomSettingsSelector.getMergeRuleConfig();
            for (MergeRuleConfig__c customSettng : mapCodes.values()) {
                ruleNameAndTritonIdMap.put(customSettng.name, String.valueOf(customSettng.Triton_Id__c));  //check with aditi..some deployment issues..
                String BinaryCode = '';
                for (String myFieldName:fieldAPIAndLabelMap.values()) {
                    binaryCode += string.valueof(customSettng.get(myFieldName)) == 'TRUE'?
                            constant.stringOne:constant.stringZero;
                }
                mergeRuleMap.put(binaryCode,customSettng);
                system.debug('custom setting map --- '+mergeRuleMap);
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCRuleEngine', 'InitiateMergeConfigData', '');
        }
    }



}