/**************************************************************************************
Apex Class Name    : ExcelImportControllertest
Version            : 1.0
Created Date       : July 21 2017
Function           : Test class for ExcelImportController
Modification Log   :
-----------------------------------------------------------------------------
 * Developer                   Date                   Description
 * ----------------------------------------------------------------------------
 * Aneesh B                  08/02/2017              Original Version
 *************************************************************************************/
@IsTest(seealldata=true)
Public class ExcelImportControllertest {
    static testMethod void testTemplate() {
        test.starttest();
        User user = [SELECT Id,Name FROM User WHERE Name like '%Aneesh%' LIMIT 1];
        system.runAs(user) {
            string files = ExcelImportController.getTemplates();
            List<Excel_Templates__mdt> lstOfFiles = (List<Excel_Templates__mdt>) JSON.deserialize(files, List<Excel_Templates__mdt>.class);
            Boolean leadTemplatePresent, oppTemplatePresent;
            if(lstOfFiles != null) {
                for (Excel_Templates__mdt document:lstOfFiles) {
                    if (document.Label == 'Lead Template') {
                        leadTemplatePresent = true;
                    }
                    if (document.Label == 'Opportunity Template') {
                        oppTemplatePresent = true;
                    }
                }
            }

            System.assert(leadTemplatePresent, 'Lead template is not present');
            System.assert(oppTemplatePresent, 'Opportunity template is not present');
        }
        test.stoptest();
    }

     static testMethod void testchatterForBothNullFileId() {
         test.starttest();
         system.runAs(TestDataUtil.createUserRecord()) {
             String status = ExcelImportController.CreateChatterPost(null, 'Invalid Chatter Group Name');
             System.assertEquals('2', status);
         }
         test.stoptest();

    }

    static testMethod void InvalidChatterGroupName() {
        test.starttest();
        system.runAs(TestDataUtil.createUserRecord()) {
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            ContentVersion v = new ContentVersion();
            v.versionData = EncodingUtil.base64Decode(bodyBlob.toString());
            v.title = 'Test upload';
            v.pathOnClient = 'Test upload';
            insert v;
            String status = ExcelImportController.CreateChatterPost(v.Id, 'Invalid Group Name');
            System.assertEquals('2', status);
        }
        test.stoptest();

    }

    static testMethod void ValidChatterGroupName() {
        test.starttest();
        system.runAs(TestDataUtil.createUserRecord()) {
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            ContentVersion v = new ContentVersion();
            v.versionData = EncodingUtil.base64Decode(bodyBlob.toString());
            v.title = 'Test upload';
            v.pathOnClient = 'Test upload';
            insert v;
            String status = ExcelImportController.CreateChatterPost(v.Id, Label.ExcelImportChatterGroupName);
            System.assertEquals('1', status);
        }
        test.stoptest();
    }

    static testMethod void TestValidFileUpload(){
        test.starttest();
        system.runAs(TestDataUtil.createUserRecord()) {
            ContentVersion fileTobeUploaded = new ContentVersion();
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            fileTobeUploaded.VersionData = EncodingUtil.base64Decode(bodyBlob.toString());
            fileTobeUploaded.Title = 'Test File';
            ExcelImportController.fileContent = fileTobeUploaded;
            ExcelImportController.contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            ExcelImportController.fileSize = 1023868;
            ExcelImportController.uploadFile();
            System.assertEquals('File was uploaded successfully',ExcelImportController.message);
            System.assertEquals('success',ExcelImportController.messageType);
        }
        test.stoptest();
    }

    static testMethod void TestInvalidFileUpload(){
        test.starttest();
        system.runAs(TestDataUtil.createUserRecord()) {
            ContentVersion fileTobeUploaded = new ContentVersion();
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            fileTobeUploaded.VersionData = EncodingUtil.base64Decode(bodyBlob.toString());
            fileTobeUploaded.Title = 'Test File';
            ExcelImportController.fileContent = fileTobeUploaded;
            ExcelImportController.contentType = '';
            ExcelImportController.uploadFile();
            System.assertEquals('Only excel files can be uploaded',ExcelImportController.message);
            System.assertEquals('error',ExcelImportController.messageType);
        }
        test.stoptest();
    }

    static testMethod void TestBiggerFileUpload(){
        test.starttest();
        system.runAs(TestDataUtil.createUserRecord()) {
            ContentVersion fileTobeUploaded = new ContentVersion();
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            fileTobeUploaded.VersionData = EncodingUtil.base64Decode(bodyBlob.toString());
            fileTobeUploaded.Title = 'Test File';
            ExcelImportController.fileContent = fileTobeUploaded;
            ExcelImportController.contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
            ExcelImportController.fileSize = 1023870;
            ExcelImportController.uploadFile();
//            System.assertEquals('Only files less than 1MB can be uploaded!',ExcelImportController.message);
            System.assertEquals('error',ExcelImportController.messageType);
        }
        test.stoptest();
    }
}