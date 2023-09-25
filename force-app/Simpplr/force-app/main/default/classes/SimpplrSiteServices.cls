public without sharing class SimpplrSiteServices {
    /**
     * @description QueueableCreateGroupMemberNQueueSobjectRecords : Queueable job class
     */
    public class QueueableCreateGroupMemberNQueueSobjectRecords implements System.Queueable{
        private List<Simpplr_Site__c> listOfNewSimpplrSites;

        /**
         * @description QueueableCreateGroupMemberNQueueSobjectRecords constructor
         * @param listOfNewSimpplrSites
         */
        public QueueableCreateGroupMemberNQueueSobjectRecords(List<Simpplr_Site__c> listOfNewSimpplrSites) {
            this.listOfNewSimpplrSites = listOfNewSimpplrSites;
        }

        /**
         * @description execute method of queueable apex
         * @param queueableContext
         */
        public void execute(System.QueueableContext ctx) {
            Map<String, String> mapOfGroupNamesAndOwnerId = new Map<String, String>();
            for(Simpplr_Site__c siteRecord : listOfNewSimpplrSites) {
                mapOfGroupNamesAndOwnerId.put('Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Standard', siteRecord.OwnerId);
                mapOfGroupNamesAndOwnerId.put('Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Admin', siteRecord.OwnerId);
            }
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', mapOfGroupNamesAndOwnerId.keySet());
            String queryStr = 'SELECT Id,Developername, (SELECT Id, SobjectType FROM QueueSobjects) FROM Group WHERE Developername = :soqlParam1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<Group> listOfGroups = (List<Group>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
            Map<String, String> mapOfGroupNameAndGroupId = new Map<String, String>();
            for(Group groupObj:listOfGroups) {
                mapOfGroupNameAndGroupId.put(groupObj.developername, groupObj.id);
            }
            SimpplrSiteServices.createQueueSobjectNGroupMember(listOfGroups, mapOfGroupNamesAndOwnerId);
            if(!Test.isRunningTest()) {
                system.enqueueJob(new SimpplrSiteServices.QueueableSiteOwnerNSiteShareRecords(listOfNewSimpplrSites, mapOfGroupNameAndGroupId));
            }
        }
    }

    /**
     * @description QueueableSiteOwnerNSiteShareRecords : Queueable job class
     */
    public class QueueableSiteOwnerNSiteShareRecords implements System.Queueable{
        private List<Simpplr_Site__c> listOfNewSimpplrSites;
        private Map<String, String> mapOfGroupNameAndGroupId;
        
        /**
         * @description QueueableSiteOwnerNSiteShareRecords constructor
         * @param listOfNewSimpplrSites
         * @param mapOfGroupNameAndGroupId
         */
        public QueueableSiteOwnerNSiteShareRecords(List<Simpplr_Site__c> listOfNewSimpplrSites, Map<String, String> mapOfGroupNameAndGroupId) {
            this.listOfNewSimpplrSites = listOfNewSimpplrSites;
            this.mapOfGroupNameAndGroupId = mapOfGroupNameAndGroupId;
        }

        /**
         * @description execute method of queueable apex
         * @param queueableContext
         */
        public void execute(System.QueueableContext ctx) {
            List<Simpplr_Site__c> siteListToUpdate = new List<Simpplr_Site__c>();
            for(Simpplr_Site__c siteRecord : listOfNewSimpplrSites) {
                String key = 'Simpplr_' + siteRecord.Chatter_Group_Id__c + '_Admin';
                if(mapOfGroupNameAndGroupId.containsKey(key)) {
                    siteListToUpdate.add(new Simpplr_Site__c(Id = siteRecord.Id, OwnerId = mapOfGroupNameAndGroupId.get(key)));
                }
            }
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteListToUpdate), 
					new List<Schema.SObjectField>{
						Simpplr_Site__c.OwnerId
			});
            Utility.createSimpplrSiteShareRecords(listOfNewSimpplrSites, true);
        }
    }

    /**
     * @description createQueueSobjectNGroupMember method
     * @param listOfGroups
     * @param mapOfGroupNamesAndOwnerId
     */
    public static void createQueueSobjectNGroupMember(List<Group> listOfGroups, Map<String, String> mapOfGroupNamesAndOwnerId) {
        List<QueueSObject> listOfQueueSObject = new List<QueueSObject>();
        String siteObjName = SimpplrContext.namespacePrefix + 'Simpplr_Site__c';
        String contentObjName = SimpplrContext.namespacePrefix + 'Simpplr_Content__c';
        for(Group groupObj : listOfGroups) {
            Set<String> supportedObjectNames = getSupportedObjectName(groupObj.QueueSobjects);
            addSObjectToList(listOfQueueSObject, groupObj.Id, supportedObjectNames.contains(siteObjName.toLowerCase()) ? '' : siteObjName);
            addSObjectToList(listOfQueueSObject, groupObj.Id, supportedObjectNames.contains(contentObjName.toLowerCase()) ? '' : contentObjName);
        }
        if(listOfQueueSObject.size() > 0) {
            Database.insert(listOfQueueSObject);
        }

        List<GroupMember> listOfGroupMemberToInsert = getListOfGroupMembership(listOfGroups, mapOfGroupNamesAndOwnerId);
        if(listOfGroupMemberToInsert.size() > 0) {
            Database.insert(listOfGroupMemberToInsert);
        }
    }

    private static Set<String> getSupportedObjectName(List<QueueSobject> queueSobjectList) {
        Set<String> supportedObjectNames = new Set<String>();
        for(QueueSobject queueObj : queueSobjectList) {
            supportedObjectNames.add(queueObj.SobjectType.toLowerCase());
        }
        return supportedObjectNames;
    }

    private static void addSObjectToList(List<QueueSObject> listOfQueueSObject, String groupId, String supportedObjectName) {
        if(String.isNotBlank(supportedObjectName)) {
            listOfQueueSObject.add(new QueueSObject(QueueId = groupId, SobjectType = supportedObjectName));
        }
    }

    private static List<GroupMember> getListOfGroupMembership(List<Group> listOfGroups, Map<String, String> mapOfGroupNamesAndOwnerId) {
        List<GroupMember> listOfGroupMembership = new List<GroupMember>();
        for(Group groupObj : listOfGroups) {
            if(mapOfGroupNamesAndOwnerId.containsKey(groupObj.DeveloperName)) {
                listOfGroupMembership.add(new GroupMember(GroupId=groupObj.id, UserOrGroupId=mapOfGroupNamesAndOwnerId.get(groupObj.DeveloperName)));
            }
        }
        return listOfGroupMembership;
    }
}