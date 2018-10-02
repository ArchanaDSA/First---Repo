/**
 * Created by savita.b on 2017-09-22.
 */

public class TemplateSettingsHelper {
    public static void createShareOnInsert(List<TemplateSetting__c> templateSettingList) {
        try {
            Map<Id, String> templateSettingMap = new Map<Id, String>();
            for (TemplateSetting__c templateSettingRec: templateSettingList) {
                templateSettingMap.put(templateSettingRec.ID, templateSettingRec.RecordSharingKey__c);
            }
            //get the public group details here
            Map<String, Id> publicGroupMap = publicGroupsSelector.getPublicGroups(templateSettingMap.values());
            List<TemplateSetting__share> templateSettingShareList = new List<TemplateSetting__share>();
            templateSettingShareList = createtemplateSettingShareRec(templateSettingMap, publicGroupMap);
            if (templateSettingShareList.size() > 0) {
                insert templateSettingShareList;
            }
        } Catch (Exception ex) {
            String errMessage = ex.getMessage();
            String trace = ex.getStackTraceString();
            String className = 'TemplateSettingsHelper';
            String methodName = 'createShareOnInsert';
            Id id = '';
            ExceptionHandler.errorLog(errMessage, trace, className, methodName, id);
        }
    }
    public static List<TemplateSetting__share> createtemplateSettingShareRec(Map<Id, String> templateSettingMap, Map<String, ID> publicGroupMap) {
        List<TemplateSetting__share> templateSettingShareList = new List<TemplateSetting__share>();
        for (ID LId:templateSettingMap.keyset()) {

            if (publicGroupMap.containskey(templateSettingMap.get(LId))) {
                TemplateSetting__share shareRecord = createShareRecord(LId, publicGroupMap.get(templateSettingMap.get(LId)), System.Label.EditAccessLevel);
                templateSettingShareList.add(shareRecord);
            }

        }
        return templateSettingShareList;
    }

    public static TemplateSetting__share createShareRecord(ID recordId, ID userOrGroupId, String accessLevel) {
        TemplateSetting__share shareRecord = new TemplateSetting__share();
        shareRecord.parentid = recordId;
        shareRecord.UserOrGroupId = userOrGroupId;
        shareRecord.AccessLevel = accessLevel;
        return shareRecord;
    }

    //For after update
    public static void createShareOnUpdateTypes(List<TemplateSetting__c> templateSettingNewList, List<TemplateSetting__c> templateSettingOldList) {
        List<String> addPublicGroupNameList = new List<String>();
        List<String> removePublicGroupNameList = new List<String>();
        List<String> allPublicGroupList = new List<String>();
        List<Id> templateShareIdList = new List<Id>();

        for (Integer index = 0; index < templateSettingNewList.size(); index++) {
            templateShareIdList.add(templateSettingNewList[index].id);
            if (templateSettingNewList[index].RecordSharingKey__c != templateSettingOldList[index].RecordSharingKey__c) {
                addPublicGroupNameList.add(templateSettingNewList[index].RecordSharingKey__c);
                removePublicGroupNameList.add(templateSettingOldList[index].RecordSharingKey__c);
            }
            if (templateSettingNewList[index].OwnerId != templateSettingOldList[index].OwnerId) {
                addPublicGroupNameList.add(templateSettingNewList[index].RecordSharingKey__c);
            }
        }
        allPublicGroupList.addAll(addPublicGroupNameList);
        allPublicGroupList.addAll(removePublicGroupNameList);
        Map<String, ID> publicGroupMap = publicGroupsSelector.getPublicGroups(allPublicGroupList);
        //access level
        List<TemplateSetting__share> templateSettingShareList = new List<TemplateSetting__share>();
        List<TemplateSetting__share> deleteAccess = new List<TemplateSetting__share>();
        //share table query
        List<TemplateSetting__share> tsIdList = [select id,userOrGroupId,parentid from TemplateSetting__share Where parentid in :templateShareIdList];
        Map<String, TemplateSetting__share> templateSettingShareIdKeyMap = new Map<String, TemplateSetting__share>();
        Map<Id, Id> groupIdMap = new Map<Id, Id>();
        String templateSettingGroupIdCombinatinMap = '';
        for (TemplateSetting__share share : tsIdList) {
            templateSettingGroupIdCombinatinMap = String.valueOf(String.valueOf(share.userOrGroupId) + String.valueOf(share.parentid));
            templateSettingShareIdKeyMap.put(templateSettingGroupIdCombinatinMap, share);
        }

        for (Integer index = 0; index < templateSettingNewList.size(); index++) {
            if (templateSettingNewList[index].RecordSharingKey__c != templateSettingOldList[index].RecordSharingKey__c)
            {
                if (publicGroupMap.containsKey(templateSettingNewList[index].RecordSharingKey__c)) {
                    //add acccess level
                    templateSettingShareList.add(createShareRecord(templateSettingNewList[index].id, publicGroupMap.get(templateSettingNewList[index].RecordSharingKey__c), 'Edit'));
                }
                if (publicGroupMap.containsKey(templateSettingOldList[index].RecordSharingKey__c)) {
                    String groupstr = String.valueOf(publicGroupMap.get(templateSettingOldList[index].RecordSharingKey__c));
                    groupstr += templateSettingNewList[index].id;
                    if (templateSettingShareIdKeyMap.containsKey(groupstr)) {
                        deleteAccess.add(templateSettingShareIdKeyMap.get(groupstr));
                    }
                }
            }
            if (templateSettingNewList[index].OwnerId != templateSettingOldList[index].OwnerId) {
                if (publicGroupMap.containsKey(templateSettingNewList[index].RecordSharingKey__c)) {
                    templateSettingShareList.add(createShareRecord(templateSettingNewList[index].id, publicGroupMap.get(templateSettingNewList[index].RecordSharingKey__c), 'Edit'));
                }
            }
        }
        if (deleteAccess != null && deleteAccess.size() > 0) {
            delete deleteAccess;
        }
        if (templateSettingShareList != null && templateSettingShareList.size() > 0) {
            System.debug('templateSettingShareList'+templateSettingShareList);
             insert templateSettingShareList;
        }

    }
}