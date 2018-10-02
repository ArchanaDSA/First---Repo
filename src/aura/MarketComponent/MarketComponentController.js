/**
 * Created by aneesh.bhat on 25-Jul-17.
 */
({
    doInit:function(component, event, helper){
        var initialData = component.get("c.getInitialData");
        initialData.setParams({
           entityId : component.get('v.recordId')
        });
        initialData.setCallback(this,function(res){
           switch(res.getState()){
               case 'SUCCESS':
                   component.set('v.initialData', JSON.parse(res.getReturnValue()));
                   var marketsAction = component.get("c.getAllMarkets");
                   marketsAction.setParams({
                      entityId : component.get('v.recordId')
                   });
                   marketsAction.setCallback(this,function(res){
                      switch(res.getState()){
                          case 'SUCCESS':
                              var marketMap = JSON.parse(res.getReturnValue());
                              var markets = [];
                              for ( var key in marketMap ) {
                                  markets.push({value:marketMap[key], key:key});
                              }
                              component.set('v.markets',markets);
                              var selectedMarket = component.get('v.initialData').Market__c;
                              component.set('v.selectedMarket',selectedMarket);
                              if(selectedMarket){
                                  helper.getSalesOfficesForMarket(component,selectedMarket,component.get('v.recordId'));
                              }
                              break;
                          case 'INCOMPLETE':
                              break;
                          case 'ERROR':
                              break;
                      }
                   });
                   $A.enqueueAction(marketsAction);

                   var productsAction = component.get("c.getAllProducts");
                   productsAction.setParams({
                      entityId : component.get('v.recordId')
                   });
                   productsAction.setCallback(this,function(res){
                      switch(res.getState()){
                          case 'SUCCESS':
                              var productMap = JSON.parse(res.getReturnValue());
                              var products = [];
                              for ( var key in productMap ) {
                                  products.push({value:productMap[key], key:key});
                              }
                              component.set('v.products',products);
                              var selectedProduct = component.get('v.initialData').Product__c;
                              component.set('v.selectedProduct',selectedProduct);
                              debugger;
                              if(selectedProduct){
                                  helper.getProgramsForProduct(component, selectedProduct, component.get('v.recordId'));
                              }
                              break;
                          case 'INCOMPLETE':
                              break;
                          case 'ERROR':
                              break;
                      }
                   });
                   $A.enqueueAction(productsAction);
                   break;
               case 'INCOMPLETE':
                   break;
               case 'ERROR':
                   break;
           }
        });
        $A.enqueueAction(initialData);


    },
    saveData:function(component, event, helper){
        helper.toggle(component);
        var selectedMarket = component.get('v.selectedMarket');
        var selectedSalesOffice = component.get('v.selectedSalesOffice');
        var selectedProduct = component.get('v.selectedProduct');
        var selectedProgram = component.get('v.selectedProgram');
        var action = component.get("c.SaveData");
        action.setParams({
           market : selectedMarket,
           salesOffice : selectedSalesOffice,
           product : selectedProduct,
           program : selectedProgram,
           entityId : component.get('v.recordId')
        });

        action.setCallback(this,function(res){
            debugger;
           helper.toggle(component);
           switch(res.getState()){
               case 'SUCCESS':
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       mode: 'pester',
                       type : 'success',
                       message: 'Data saved successfully!',
                       duration:500
                   });
                   toastEvent.fire();
                   break;
               case 'INCOMPLETE':
                   break;
               case 'ERROR':
                   break;
           }
        });
        $A.enqueueAction(action);
    },
    onMarketChanged:function(component, event, helper){
        helper.getSalesOfficesForMarket(component,component.get('v.selectedMarket'), component.get('v.recordId'));
    },
    onProductChanged:function(component, event, helper){
        helper.getProgramsForProduct(component, component.get('v.selectedProduct'), component.get('v.recordId'));
    }
})