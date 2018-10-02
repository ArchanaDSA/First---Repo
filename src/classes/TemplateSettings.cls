/**
 * Created by savita.b on 2017-09-22.
 */

public class TemplateSettings {

    public static void onBeforeInsert(List<SObject> newItems) {

    }

    public static void onBeforeUpdate(List<TemplateSetting__c> oldtemplatesettingList, List<TemplateSetting__c> newtemplatesettingList) {

    }

    public static void onBeforeDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterInsert(List<TemplateSetting__c>newItems) {

        TemplateSettingsHelper.createShareOnInsert(newItems);
    }

    public static void onAfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        TemplateSettingsHelper.createShareOnUpdateTypes((List<TemplateSetting__c>) newItems.values(), (List<TemplateSetting__c>) oldItems.values());

    }
    public static void onAfterDelete(Map<Id, SObject> oldItems) {
    }

    public static void onAfterUndelete(Map<Id, SObject> oldItems) {
    }
}