/**************************************************************************************
Apex Class Name    : DcDiscardsDispatcher 
Version            : 1.0
Created Date       : June 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/22/2017              Original Version
*******************************************************************************/
public class DcDiscardsDispatcher {

    public static void run() {
        // Check to see if the trigger has been disabled. If it has, return
       /*** if (handler.IsTriggerDisabled())
            return;
        ***/
        // Before trigger logic
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert)
                DcDiscards.onBeforeInsert(trigger.new);

            if (Trigger.IsUpdate)
                DcDiscards.onBeforeUpdate(trigger.newMap, trigger.oldMap);

            if (Trigger.IsDelete)
                DcDiscards.onBeforeDelete(trigger.oldMap);
        }

        // After trigger logic
        if (Trigger.IsAfter) {
            if (Trigger.IsInsert)
                DcDiscards.onAfterInsert(Trigger.newMap);

            if (Trigger.IsUpdate)
                DcDiscards.onAfterUpdate(trigger.newMap, trigger.oldMap);

            if (trigger.IsDelete)
                DcDiscards.onAfterDelete(trigger.oldMap);

            if (trigger.isUndelete)
                DcDiscards.onAfterUndelete(trigger.oldMap);
        }
    }
}