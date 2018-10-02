/**
 * Created by Archana on 28-07-2017.
 */
({
    toggle: function (cmp) {
        var spinner = cmp.find("sectionHeader");
        $A.util.toggleClass(spinner, "slds-is-open");
    }
})