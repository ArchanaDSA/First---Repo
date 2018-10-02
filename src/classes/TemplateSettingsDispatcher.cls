/**
 * Created by savita.b on 2017-09-22.
 */

public with sharing class TemplateSettingsDispatcher {
    public static void run() {
        // Check to see if the trigger has been disabled. If it has, return
       /*** if (handler.IsTriggerDisabled())
            return;
        ***/
        // Before trigger logic
        system.debug('&&&&&&&&&&&&&&&&');
        try { if (Trigger.IsBefore) {
                if (Trigger.IsInsert) {
                    TemplateSettings.onBeforeInsert(trigger.new);
                }

                if (Trigger.IsUpdate) {
                    TemplateSettings.onBeforeUpdate(trigger.old, trigger.new);
                }
                if (Trigger.IsDelete) {
                    TemplateSettings.onBeforeDelete(trigger.oldMap);
                }
            }
        } catch (Exception e){}

        // After trigger logic
        if (Trigger.IsAfter) {

            if (Trigger.IsInsert) {
                TemplateSettings.onAfterInsert(Trigger.new);
            }

            if (Trigger.IsUpdate) {
                system.debug('###################');
                TemplateSettings.onAfterUpdate(trigger.newMap, trigger.oldMap);
            }

            if (trigger.IsDelete) {
                TemplateSettings.onAfterDelete(trigger.oldMap);
            }

            if (trigger.isUndelete) {
                TemplateSettings.onAfterUndelete(trigger.oldMap);
            }
        }
    }
}