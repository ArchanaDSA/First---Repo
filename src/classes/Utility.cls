/**
 * Created by savita.b on 7/26/2017.
 */

public with sharing class Utility
{
    public static boolean isIntegrationUser()
    {
        String currentUser=UserInfo.getUsername();
        boolean isIntegrationUser=false;
        if(currentUser==Label.Integration_User)
        {
            isIntegrationUser=true;
        }
        return isIntegrationUser;
    }

    public static string[] splitString(string splitstringvalue,string splitchar)
    {
        return splitstringvalue.split('\\'+splitchar);
    }

    public static Date ConvertDateTimeTodate(DateTime inputDatetime)
    {
        return date.newinstance(inputDatetime.year(), inputDatetime.month(), inputDatetime.day());
    }
   public static Boolean getTriggerSettings(String ObjectName)  {
       Boolean isDisable = false;
        BypassTriggersValidations__c setupUser = BypassTriggersValidations__c.getInstance();
       if(setupUser != null &&  String.isBlank(setupUser.TriggerObjects__c) 
           && setupUser.DisableTriggers__c!= null && setupUser.DisableTriggers__c == true)
        {
            System.debug('First Loop');
            isDisable= true;
        }
       else if(setupUser != null &&  setupUser.TriggerObjects__c != null && setupUser.TriggerObjects__c.containsIgnoreCase(ObjectName)
                && setupUser.DisableTriggers__c!= null && setupUser.DisableTriggers__c== true)
            {
                 System.debug('Second Loop');
                 isDisable= true;
            }
              else {
                      isDisable=false;
                      }
                      system.debug('************* final trigger result'+isDisable);
              return isDisable;        
     }
}