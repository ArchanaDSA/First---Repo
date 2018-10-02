/**************************************************************************************
Apex Class Name    : DCdbSelector
Version            : 1.0
Created Date       : May 26 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
* Developer                   Date                   Description
* ----------------------------------------------------------------------------
* Aditi S                  05/26/2017              Original Version
*******************************************************************************/

public with sharing class DCRuleEngine {

    public static Map<String, LeadAccountMapping__c> leadAccountMapping = new Map<String, LeadAccountMapping__c>();
    public static Map<String, String> fieldAPIAndLabelMap = new Map<String, String>();
    public static Map<String, String> ruleNameRuleValMap = new Map<String, String>();
    public static map<string, string> ruleNameAndTritonIdMap = new map<string, string>();


    //This function has the logic of deciding what rule gets applied when there is an incoming Lead based on Bussiness logic
    public static DCBusinessHandler.MergeRules findAutoMergeRule(Lead sourceLead, Lead destLead, Account destAccount) {
        try {
            //DCBusinessHandler.MergeRules rule = DCBusinessHandler.MergeRules.None;
            Boolean destHasBooking = destAccount != null ? destAccount.HasBooking__c : false;
            String[] concatenateComparisionList = new String[]{
            };
            //query part is removed
            DCBusinessHandler.MergeRules rules = DCBusinessHandler.MergeRules.None;
            Map<String, LeadAccountMapping__c> leadAccountMapping = LeadAccountMapping__c.getAll();
            for (string field:fieldAPIAndLabelMap.keyset()) {
                //Lead
                if (destLead != null) {
                    if (field == constant.Has_Booking) {
                        concatenateComparisionList.add(constant.stringZero);
                    } else if (field == Constant.HOMEPHONE || field == Constant.MOBILEPHONE || field == Constant.OTHERPHONE) {
                        if (sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                destLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) &&
                                sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                        destLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) &&
                                sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                        destLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c)) {
                            concatenateComparisionList.add(constant.stringOne);
                        } else {
                            concatenateComparisionList.add(constant.stringZero);
                        }
                    } else {
                        if (sourceLead.get(leadAccountMapping.get(field).Lead_API_Name__c) == destLead.get(leadAccountMapping.get(field).Lead_API_Name__c)) {
                            concatenateComparisionList.add(constant.stringOne);
                        } else {
                            concatenateComparisionList.add(constant.stringZero);
                        }
                    }
                }
                //Account
                else if (destAccount != null) {
                    if (field == constant.Has_Booking) {
                        if (destAccount.HasBooking__c) {
                            concatenateComparisionList.add(constant.stringOne);
                        } else {
                            concatenateComparisionList.add(constant.stringZero);
                        }
                    } else if (field == Constant.HOMEPHONE || field == Constant.MOBILEPHONE || field == Constant.OTHERPHONE) {
                        if (sourceLead.get(leadAccountMapping.get(Constant.HOMEPHONE).Lead_API_Name__c) ==
                                destAccount.get(leadAccountMapping.get(Constant.HOMEPHONE).Account_API_Name__c) &&
                                sourceLead.get(leadAccountMapping.get(Constant.MOBILEPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.MOBILEPHONE).Account_API_Name__c) &&
                                sourceLead.get(leadAccountMapping.get(Constant.OTHERPHONE).Lead_API_Name__c) ==
                                        destAccount.get(leadAccountMapping.get(Constant.OTHERPHONE).Account_API_Name__c)) {
                            concatenateComparisionList.add(constant.stringOne);
                        } else {
                            concatenateComparisionList.add(constant.stringZero);
                        }
                    } else {
                        if (sourceLead.get(leadAccountMapping.get(field).Lead_API_Name__c) ==
                                destAccount.get(leadAccountMapping.get(field).Account_API_Name__c)) {
                            concatenateComparisionList.add(constant.stringOne);
                        } else {
                            concatenateComparisionList.add(constant.stringZero);
                        }
                    }
                }
            }

            String result = String.join(concatenateComparisionList, constant.Blank);
            system.debug('********* rule biary code'+result);
            system.debug('--------------------- rule result' + result);
            system.debug('--------------------- RuleNameRuleValMap' + RuleNameRuleValMap);
            system.debug('--------------------- rule result' + RuleNameRuleValMap.containskey(result));
            if (RuleNameRuleValMap.containskey(result)) {
                String ruleName = RuleNameRuleValMap.get(result);
                if (ruleNameAndTritonIdMap.get(ruleName) != constant.stringNA && ruleNameAndTritonIdMap.get(ruleName) != null) {

                    if (sourceLead.Triton_Id__c == destLead.Triton_Id__c) {
                        if (ruleNameAndTritonIdMap.get(ruleName) == constant.stringTrue)
                            ruleName = rulename; else {
                            ruleName = constant.blank;
                        }
                    } else {
                        if (ruleNameAndTritonIdMap.get(ruleName) == constant.stringFalse) {
                            ruleName = rulename;
                        } else {
                            ruleName = constant.blank;
                        }
                    }
                } else {
                    ruleName = ruleName;
                }
                system.debug('&&&&&&&&&&&&&&&&&&&&&& ruleName' + ruleName);
                for (DCBusinessHandler.MergeRules mrule: DCBusinessHandler.MergeRules.values()) {
                    if (mrule.name() == ruleName) {
                        rules = mrule;
                        break;
                    }
                }
            }
            system.debug('---------------------- return rule:' + rules);
            return rules;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCRuleEngine', 'newIsMergeOrConvert', '');
            return null;
        }

    }

    //This function has the logic of deciding what needs to be done while there is an incoming Lead based on Rules
    //whether to merge or create a new one or create a new one with Household.
    public static DCBusinessHandler.MergeConvertDecision findAutoMergeDecision(
            DCBusinessHandler.MergeRules rules,
            Lead sourceLead, Lead destinationLead, Account destinationAccount) {
        try {
            DCBusinessHandler.MergeConvertDecision decision =
                    DCBusinessHandler.MergeConvertDecision.None;
            String destinationStreet = destinationLead != null ?
                    destinationLead.street : destinationAccount.PersonMailingStreet;
            String desttinationLandline = destinationLead != null ?
                    destinationLead.HomePhone__c : destinationAccount.PersonHomePhone;
            if (rules == DCBusinessHandler.MergeRules.Rule15) {
                String newstreet = sourceLead.street;
                String newLandline = sourceLead.HomePhone__c;
                decision = ((!String.isBlank(newstreet) && (destinationStreet == newstreet)) ||
                        (!String.isBlank(newLandline) && desttinationLandline == newLandline)) ?
                        DCBusinessHandler.MergeConvertDecision.CreateHoushold :
                        DCBusinessHandler.MergeConvertDecision.Create;
            } else if (rules == DCBusinessHandler.MergeRules.Rule17) {
                if (destinationLead != null) {
                    decision = DCBusinessHandler.MergeConvertDecision.MergeOrConvert;
                } else if (destinationAccount != null) {
                    Date bookingDate = Date.newInstance(destinationAccount.BookingDate__c.year(),
                            destinationAccount.BookingDate__c.month(), destinationAccount.BookingDate__c.day());
                    Integer monthsBetween = bookingDate.monthsBetween(Date.today());
                    if (monthsBetween > 6) {
                        decision = DCBusinessHandler.MergeConvertDecision.CreateOpportunity;
                    } else {
                        decision = DCBusinessHandler.MergeConvertDecision.MergeOrConvert;
                    }
                }
            } else {
                map<string, string> ruleAndDecisionMap = new map<string, string>();
                Map<string, MergeRuleConfig__c> mapCodes = new map<string, MergeRuleConfig__c>();
                mapcodes = CustomSettingsSelector.getMergeRuleConfig();

                for (MergeRuleConfig__c objCstmSetting :mapcodes.values()) {
                    ruleAndDecisionMap.put(objCstmSetting.name, objCstmSetting.decision__c);
                }

                system.debug('************** my rule rule' + rules);
                system.debug('**************ruleAndDecisionMap******' + ruleAndDecisionMap);
                string decisionrule = string.valueof(ruleAndDecisionMap.get(rules.name()));
                system.debug('*******decisionrule******* ' + decisionrule);
                for (DCBusinessHandler.MergeConvertDecision decisionname: DCBusinessHandler.MergeConvertDecision.values()) {
                    if (decisionname.name() == String.valueOf(ruleAndDecisionMap.get(rules.name()))) {
                        decision = decisionname;

                        break;
                    }
                }

            }
            system.debug('*************final decision:' + decision);
            return decision;
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCRuleEngine', 'newGetMergeConvertDecision', '');
            return null;
        }

    }

    public static void loadMergeConfigRuleData() {
        try {
            string [] customSettingRuleValues = new string[]{
            };
            string[] myfieldsname = new string[]{
            };
            Map<String, Schema.SObjectField> fieldsMap = MergeRuleConfig__c.sObjectType.getDescribe().fields.getMap();
            for (String field : fieldsMap.keySet()) {
                Schema.SObjectField F = fieldsMap.get(field);
                Schema.DescribeFieldResult R = F.getDescribe();

                if (R.isCustom() && !(R.getLabel() == constant.Decision) && !(R.getLabel() == constant.triton_id)) {
                    String fName = R.getName();
                    String fLabel = R.getLabel();
                    fieldAPIAndLabelMap.put(fLabel, fName);
                }
            }
            Map<string, MergeRuleConfig__c> mapCodes = new map<string, MergeRuleConfig__c>();
            mapcodes = CustomSettingsSelector.getMergeRuleConfig(); //Known issues--sometimes we wont get all coulumns if we use the "getall" method.
            for (MergeRuleConfig__c customSettng:mapCodes.values()) {

                ruleNameAndTritonIdMap.put(customSettng.name, String.valueOf(customSettng.Triton_Id__c));  //check with aditi..some deployment issues..
                customSettingRuleValues.clear();
                for (string myFieldName:fieldAPIAndLabelMap.values()) {


                    myfieldsname.add(myFieldName);

                    if (string.valueof(customSettng.get(myFieldName)) == 'TRUE') {
                        customSettingRuleValues.add(constant.stringOne);
                    } else {
                        customSettingRuleValues.add(constant.stringZero);
                    }

                }
                RuleNameRuleValMap.put(String.join(customSettingRuleValues, ''), customSettng.name);
                system.debug('*********** '+RuleNameRuleValMap);
                map<string, string> getrulevaluebyrulename = new map<string, string>();
                getrulevaluebyrulename.put(customSettng.name, String.join(customSettingRuleValues, ''));
            }
        } catch (Exception ex) {
            ExceptionHandler.errorLog(ex.getMessage(),
                    ex.getStackTraceString(), 'DCRuleEngine', 'InitiateMergeConfigData', '');
        }
    }

}