/**
 * Created by aneesh.bhat on 31-Jul-17.
 */
({
    toggle: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    }
})