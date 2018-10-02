/**
 * Created by aneesh.bhat on 07-Sep-17.
 */
({
    validateFields:function(component){
        var isMandatoryFieldsMissing = false;
        var error ="";
        var selectedAction = component.get('v.selectedActionType');
        var selectedSubActionType = component.get('v.selectedSubActionType');
        if(selectedAction === 'Select' && !isMandatoryFieldsMissing){
            isMandatoryFieldsMissing = true;
            error = error.concat(" Opportunity Action is mandatory");
        }
        if(!isMandatoryFieldsMissing  && selectedAction === 'Call Not Reached' && selectedSubActionType === 'Select' ){
            isMandatoryFieldsMissing = true;
            error = error.concat(" Sub Action is mandatory");
        }
        var selectedLikelihoodToBook = component.get('v.selectedLikelihoodToBook');
        if(!isMandatoryFieldsMissing &&
            selectedAction === 'Call Reached' &&
            ( selectedLikelihoodToBook === 'Select' || typeof selectedLikelihoodToBook === 'undefined')){
            isMandatoryFieldsMissing = true;
            error = error.concat(" Likelihood To Book is mandatory");
        }

        var selectedCallResult = component.get('v.selectedCallResult');
        if(!isMandatoryFieldsMissing && (selectedCallResult === 'Select' ||typeof  selectedCallResult === 'undefined')){
            isMandatoryFieldsMissing = true;
            error = error.concat(" Result next/Action is mandatory");
        }
         var selectedActionDate = component.get('v.selectedActionDate');
        if(!isMandatoryFieldsMissing &&
            selectedCallResult != 'Close' &&
            ( selectedActionDate === null || typeof selectedActionDate === 'undefined')){
            isMandatoryFieldsMissing = true;
            error = error.concat(" Next Action Date is mandatory");
        }

        var selectedCloseReason = component.get('v.selectedCloseReason');
        if(!isMandatoryFieldsMissing && selectedCallResult === 'Close' && ( selectedCloseReason === 'Select' || typeof selectedCloseReason === 'undefined' )){
            isMandatoryFieldsMissing = true;
            error = error.concat(" Close Reason is mandatory");
        }

        component.set('v.messageType',"warning");
        component.set('v.messageTitle',"Warning");
        component.set('v.message',error);
        component.set('v.showMessage',isMandatoryFieldsMissing);
        setTimeout(function(){
            component.set('v.showMessage',false);
        }, 3000);
        return isMandatoryFieldsMissing;
    }
})