/**************************************************************************************
Apex Class Name    : PhoneMergeClass
Version            : 1.0
Created Date       : June 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/22/2017              Original Version
*******************************************************************************/
public class PhoneMergeClass
{
    public string Phone1;
    public string Phone2;
    public string Phone3;
    public static PhoneMergeClass MergePhones(PhoneMergeClass incomingPhoneObj,PhoneMergeClass existingPhoneObj)
    {
        PhoneMergeClass mergedPhone=new PhoneMergeClass();
        
        Boolean phone1Replaced=false;
        Boolean phone2Replaced=false;
        Boolean phone3Replaced=false;
        
        string existingPhone1=existingPhoneObj.Phone1;
        string existingPhone2=existingPhoneObj.Phone2;
        string existingPhone3=existingPhoneObj.Phone3;
        
        string incomingPhone1=incomingPhoneObj.Phone1;
        string incomingPhone2=incomingPhoneObj.Phone2;
        string incomingPhone3=incomingPhoneObj.Phone3;
        
        string updatePhone1=existingPhoneObj.Phone1;
        string updatePhone2=existingPhoneObj.Phone2;
        string updatePhone3=existingPhoneObj.Phone3;
        
        if (!String.isBlank(incomingPhone2) && incomingPhone2 != existingPhone2)  
        {
            if(String.isBlank(existingPhoneObj.Phone3))
            {
                updatePhone3=existingPhone2; //
            }
            updatePhone2=incomingPhone2;
        }
        if (!String.isBlank(incomingPhone1) && incomingPhone1 != existingPhone1)
        {
            if(!String.isBlank(existingPhone1) && String.isBlank(existingPhone3))
            {
                updatePhone3=existingPhone1;
            }
            updatePhone1=incomingPhone1;
        }
        if (!String.isBlank(incomingPhone3) && incomingPhone3 != existingPhone3 && String.isBlank(updatePhone3))
        {
            updatePhone3=incomingPhone3;
        }
        
        mergedPhone.Phone1=updatePhone1;
        mergedPhone.Phone2=updatePhone2;
        mergedPhone.Phone3=updatePhone3;
        
        return mergedPhone;
        
        
        
    }
}