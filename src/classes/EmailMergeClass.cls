/**************************************************************************************
Apex Class Name    : EmailMergeClass
Version            : 1.0
Created Date       : June 22 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  06/22/2017              Original Version
*******************************************************************************/
public class EmailMergeClass
{
	public string Email1;
    public string Email2;
    
    public static EmailMergeClass MergeEmails(EmailMergeClass incomingEmailObj,EmailMergeClass existingEmailObj)
    {
        EmailMergeClass mergedEmail=new EmailMergeClass();
        
        	Boolean email1Replaced=false;
            Boolean email2Replaced=false;
        	
        	string existingEmail1=existingEmailObj.Email1;
        	string existingEmail2=existingEmailObj.Email2;
        
        	string IncomingEmail1=incomingEmailObj.Email1;
        	string IncomingEmail2=incomingEmailObj.Email2;
        
        	string updateStudentEmail1=existingEmailObj.Email1;
            string updateStudentEmail2=existingEmailObj.Email2;

        	if (String.isBlank(IncomingEmail1) && String.isBlank(IncomingEmail2))
            {
               return existingEmailObj;
            }
            if (!String.isBlank(IncomingEmail1))
            {
            	if (!String.isBlank(existingEmail1) && !String.isBlank(existingEmail2)
                    && IncomingEmail1 != existingEmail1 && IncomingEmail1 != existingEmail2)
                {
                    updateStudentEmail1=IncomingEmail1;
                    email1Replaced=true;
                }
                else if (String.isBlank(existingEmail1) && !String.isBlank(existingEmail2)
                    && IncomingEmail1 != existingEmail2)
                {
                    updateStudentEmail1=IncomingEmail1;
                    email1Replaced=true;
                }
                else if (!String.isBlank(existingEmail1) && String.isBlank(existingEmail2)
                    && IncomingEmail1 != existingEmail1)
                {
                    updateStudentEmail2=IncomingEmail1;
                    email2Replaced=true;
                }
                else if (String.isBlank(existingEmail1) && String.isBlank(existingEmail2))
                {
                    updateStudentEmail1=IncomingEmail1;
                    email1Replaced=true;
                }
            }
            if (!email1Replaced && !email2Replaced && !String.isBlank(IncomingEmail2))
            {
                if (!String.isBlank(existingEmail1) && !String.isBlank(existingEmail2)
                    && IncomingEmail2 != existingEmail1 && IncomingEmail2 != existingEmail2)
                {
                    updateStudentEmail2=IncomingEmail2;                    
                }
                else if (String.isBlank(existingEmail1) && !String.isBlank(existingEmail2)
                    && IncomingEmail2 != existingEmail2)
                {
                    updateStudentEmail1=IncomingEmail2;                    
                }
                else if (!String.isBlank(existingEmail1) && String.isBlank(existingEmail2)
                    && IncomingEmail2 != existingEmail1)
                {
                    updateStudentEmail2=IncomingEmail2;                    
                }
                else if (String.isBlank(existingEmail1) && String.isBlank(existingEmail2))
                {
                    updateStudentEmail1=IncomingEmail2;
                   
                }
                
            }
            else if ((email1Replaced || email2Replaced) && !String.isBlank(IncomingEmail2))
            {
                if (!String.isBlank(updateStudentEmail1) && !String.isBlank(updateStudentEmail2)
                    && IncomingEmail2 != updateStudentEmail1 && IncomingEmail2 != updateStudentEmail2)
                {
                   if (email1Replaced)
                       updateStudentEmail2=IncomingEmail2;
                   else if (email2Replaced)
                   {
                       updateStudentEmail1=updateStudentEmail2;
                       updateStudentEmail2=IncomingEmail2;
                   }                       
                }
                else if (String.isBlank(updateStudentEmail1) && !String.isBlank(updateStudentEmail2)
                    && IncomingEmail2 != updateStudentEmail2)
                {
                        updateStudentEmail1= updateStudentEmail2;
                    	updateStudentEmail2=IncomingEmail2;
                }
                else if (!String.isBlank(updateStudentEmail1) && String.isBlank(updateStudentEmail2)
                    && IncomingEmail2 != updateStudentEmail1)
                {
                    updateStudentEmail2=IncomingEmail2;                    
                }
            }
        mergedEmail.Email1=updateStudentEmail1;
        mergedEmail.Email2=updateStudentEmail2;
        return mergedEmail;
    }
}