/**************************************************************************************
Apex Class Name    : ExcelImportController
Version            : 1.0
Created Date       : July 21 2017
Function           : Apex Controller for Excel Import
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Aneesh B                  07/21/2017              Original Version
 *************************************************************************************/
public class ExcelImportController {
    public static transient ContentVersion fileContent;
    public static Boolean fileUploadProcessed{get;set;}
    public static String message{get;set;}
    public static String messageType{get;set;}
    public static String fileTitle{get;set;}
    public static Id fileId{get;set;}
    public static String contentType{get;set;}
    public static Integer fileSize{get;set;}

    //Use getter so we can make attachment transient
    public ContentVersion getFileContent(){
        fileContent = new ContentVersion();
        return fileContent;
    }

    Public static void uploadFile(){
        try {

            fileContent.PathOnClient = fileContent.Title;
            if( contentType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || contentType == 'application/vnd.ms-excel' ){
                if(fileSize>1023869){
                    message = 'Only files less than 1MB can be uploaded!';
                    messageType = 'error';
                    fileUploadProcessed = true;
                    return;
                }
                insert fileContent;

                message = 'File was uploaded successfully';
                messageType = 'success';
                fileId = fileContent.Id;
            }
            else{
                message = 'Only excel files can be uploaded';
                messageType = 'error';
                fileUploadProcessed = true;
                return;
            }
        }catch(Exception e){
            message = e.getMessage();
            messageType = 'error';
        }
        fileUploadProcessed = true;
    }

    /**
    Gets all templates defined in the library folder pointed by 'Label.Excel_Import_Standard_Templates_Library_Folder'
     */
    @AuraEnabled
    public static String getTemplates() {
//        List<ContentWorkSpace> ContentWorkSpaces = SObjectSelector.getTemplateDocuments(Label.Excel_Import_Standard_Templates_Library_Folder);
//        List<ContentDocument> files = new List<ContentDocument>();
//        if (ContentWorkSpaces != null && ContentWorkSpaces.size() > 0) {
//            for (ContentWorkSpace doc:ContentWorkSpaces) {
//                if (doc.AttachedContentDocuments != null && doc.AttachedContentDocuments.size() > 0) {
//                    for (AttachedContentDocument attDoc:doc.AttachedContentDocuments) {
//                        files.add(attdoc.ContentDocument);
//                    }
//                }
//            }
//        }
        List<Excel_Templates__mdt> files = SObjectSelector.getTemplateDocuments();
        return JSON.serialize(files);
    }

    /**
    Creates a chatter post for the file just created with the file being shown as a doownloadable attachment
     */
    @AuraEnabled
    public static String CreateChatterPost(Id newFileId, String chatterGroupName) {
        try {
            // Define the FeedItemInput object to pass to postFeedElement
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            chatterGroupName = (chatterGroupName == null || chatterGroupName == '') ? Label.ExcelImportChatterGroupName : chatterGroupName;
            List<CollaborationGroup> chatterGroup = SObjectSelector.getCollaborationGroup(chatterGroupName);
            if (chatterGroup != null && chatterGroup.size() > 0) {
                feedItemInput.subjectId = chatterGroup[0].Id;

                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                textSegmentInput.text = 'A new file has been uploaded for a Market. Please validate the file.';

                // The MessageBodyInput object holds the text in the post
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                messageBodyInput.messageSegments.add(textSegmentInput);
                feedItemInput.body = messageBodyInput;

                if (newFileId != null) {
                    // The FeedElementCapabilitiesInput object holds the capabilities of the feed item.
                    // For this feed item, we define a files capability to hold the file(s).
                    List<String> fileIds = new List<String>();
                    List<ContentDocument> doc = SObjectSelector.getDocument(newFileId);
                    if (doc != null && doc.size() > 0) {
                        fileIds.add(doc[0].Id);

                        ConnectApi.FilesCapabilityInput filesInput = new ConnectApi.FilesCapabilityInput();
                        filesInput.items = new List<ConnectApi.FileIdInput>();

                        for (String fileId : fileIds) {
                            ConnectApi.FileIdInput idInput = new ConnectApi.FileIdInput();
                            idInput.id = fileId;
                            filesInput.items.add(idInput);
                        }

                        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
                        feedElementCapabilitiesInput.files = filesInput;

                        feedItemInput.capabilities = feedElementCapabilitiesInput;
                    }
                }

                // Post the feed item.
                ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);

                return '1';
            }
            return '2';
        } catch (Exception e) {
            return '3';
        }
    }
}