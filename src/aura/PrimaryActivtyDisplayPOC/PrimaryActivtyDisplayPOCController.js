({
	doInit : function(component, event, helper){
    var action = component.get("c.getAllEvents");
    action.setParams({"OpportunityID":component.get("v.recordId")});
        
    action.setCallback(this, function(data) {
        if (data.getState() === "SUCCESS") {
                component.set("v.eventRecord", data.getReturnValue());
        }
    });
     $A.enqueueAction(action); 
}
})