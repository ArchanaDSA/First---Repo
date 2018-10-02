/**
 * Created by aneesh.bhat on 04-Sep-17.
 */
({
    doInit:function(component,event,helper){
        var currentYear = (new Date()).getFullYear();
        var years=[];
        years.push('Select');
        years.push(currentYear.toString());
        for(var year = 0 ;year<2;year++){
            years.push((++currentYear).toString());
        }
        component.set('v.selectedActionDate',new Date().toISOString());
        component.set('v.years',years);
        var salesAction = component.get('c.getSalesActions');
        salesAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      var salesActions = JSON.parse(res.getReturnValue());
                      if(salesActions.length>0){
                        component.set('v.selectedActionType',salesActions[0])
                      }
                      component.set('v.salesAction',salesActions);
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(salesAction);

         var likelihoodToBookAction = component.get('c.getLikelihoodToBookOptions');
        likelihoodToBookAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      var likelihoodToBookOptions = JSON.parse(res.getReturnValue());
                      component.set('v.likelihoodToBook',likelihoodToBookOptions);
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(likelihoodToBookAction);

         var hearAboutEFAction = component.get('c.getHearAboutUsOptions');
        hearAboutEFAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      var hearAboutEFOptions = JSON.parse(res.getReturnValue());
                      component.set('v.hearAboutEF',hearAboutEFOptions);
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(hearAboutEFAction);

        var destinationsAction = component.get('c.getDestinations');
        destinationsAction.setParams({
           recordId : component.get('v.recordId')
        });
        destinationsAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      component.set('v.destinations',res.getReturnValue());
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(destinationsAction);

        var durationAction = component.get('c.getDurations');
        durationAction.setParams({
                   recordId : component.get('v.recordId')
                });
        durationAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      component.set('v.durations',res.getReturnValue());
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(durationAction);

        var closeReasonsAction = component.get('c.getCloseReasons');
        closeReasonsAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      var closeReasons = JSON.parse(res.getReturnValue());
                      component.set('v.closeReasons',closeReasons);
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(closeReasonsAction);

         var subActionsAction = component.get('c.getSubActions');
        subActionsAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      var subActions = JSON.parse(res.getReturnValue());
                      component.set('v.subActions',subActions);
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(subActionsAction);

        var bookOnDateAction = component.get('c.getOpportunityCloseDate');
        bookOnDateAction.setParams({
                           recordId : component.get('v.recordId')
                        });
        bookOnDateAction.setCallback(this,function(res){
            debugger;
            switch(res.getState()){
                  case 'SUCCESS':
                      component.set('v.bookOnDate',res.getReturnValue());
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(bookOnDateAction);
    },
    onSalesActionChanged:function(component,event,helper){
        component.set('v.selectedSubActionType','Select');
        var callResultAction = component.get('c.getCallResults');
        callResultAction.setParams({
           callAction : component.get('v.selectedActionType')
        });
        callResultAction.setCallback(this,function(res){
            switch(res.getState()){
                  case 'SUCCESS':
                      var callResults = JSON.parse(res.getReturnValue());
                      component.set('v.callResults',callResults);
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
        });
        $A.enqueueAction(callResultAction);
    },
    onSaveClicked:function(component,event,helper){
        if(!helper.validateFields(component)){
            var saveDataAction = component.get('c.saveData');
            saveDataAction.setParams({
               callAction : (component.get('v.selectedActionType') === 'Select') ? '' :component.get('v.selectedActionType'),
               subAction : (component.get('v.selectedSubActionType') === 'Select') ? '': component.get('v.selectedSubActionType'),
               callResult : (component.get('v.selectedCallResult') === 'Select') ? '': component.get('v.selectedCallResult'),
               actionDateTime : (component.get('v.selectedActionDate') === 'Select') ? '' :component.get('v.selectedActionDate'),
               closeReason : (component.get('v.selectedCloseReason') === 'Select') ? '':component.get('v.selectedCloseReason'),
               recordId : component.get('v.recordId')
            });
            saveDataAction.setCallback(this,function(res){
                switch(res.getState()){
                  case 'SUCCESS':
                      component.set('v.messageType',"info");
                      component.set('v.messageTitle',"Success!");
                      component.set('v.message','Data saved successfully!');
                      component.set('v.showMessage',true);
                      setTimeout(function(){
                          component.set('v.showMessage',false);
                      }, 3000);
                      break;
                  case 'INCOMPLETE':
                      break;
                  case 'ERROR':
                      break;
              }
            });
            $A.enqueueAction(saveDataAction);
        }
    }
})