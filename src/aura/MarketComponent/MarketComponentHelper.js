/**
 * Created by aneesh.bhat on 31-Jul-17.
 */
({
        toggle: function (cmp) {
            var spinner = cmp.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        },
        getSalesOfficesForMarket:function(component, market, recordId){
            var action = component.get("c.getAllSalesOfficesforMarket");
            action.setParams({
               marketName : market,
               entityId : recordId
            });
            action.setCallback(this,function(res){
               switch(res.getState()){
                   case 'SUCCESS':
                       component.set('v.salesOffices',JSON.parse(res.getReturnValue()));
                       component.set('v.selectedSalesOffice', component.get('v.initialData').SalesOffice__c);
                       break;
                   case 'INCOMPLETE':
                       break;
                   case 'ERROR':
                       break;
               }
            });
            $A.enqueueAction(action);
        },
        getProgramsForProduct:function(component, product, recordId){
            var action = component.get("c.getAllProgramsforProduct");
                    action.setParams({
                       product : product,
                       entityId : recordId
                    });
                    action.setCallback(this,function(res){
                       switch(res.getState()){
                           case 'SUCCESS':
                               component.set('v.programs',JSON.parse(res.getReturnValue()));
                               component.set('v.selectedProgram',component.get('v.initialData').Program__c);
                               break;
                           case 'INCOMPLETE':
                               break;
                           case 'ERROR':
                               break;
                       }
                    });
                    $A.enqueueAction(action);
        }
})