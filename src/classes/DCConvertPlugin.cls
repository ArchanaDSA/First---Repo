/**************************************************************************************
Apex Class Name    : DCConvertPlugin
Version            : 1.0
Created Date       : May 29 2017
Function           :
Modification Log   :
------------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Suresh S                  05/29/2017              Original Version
*******************************************************************************/
global class DCConvertPlugin implements dupcheck.dc3Plugin.InterfaceConvert {
    //Not using this class.
    global void beforeConvert(Database.LeadConvert leadConvertData) {
    }
    global void convertFailed(Database.LeadConvert leadConvertData, dupcheck.dc3Exception.ConvertException exceptionData) {
    }
    global void afterConvert(Database.LeadConvertResult leadConvertResult, Task taskData) {

    }
}