public with sharing class BatchDeleteFolderRecords implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    public Boolean isAdmin; 
    public String folderType; 
    public Set<String> domainSet; 
    private static final String BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION = 'removeDomainPeopleIntegration';

    public BatchDeleteFolderRecords(String folderType, Boolean isAdminOrUser) {
        isAdmin = isAdminOrUser;
        this.folderType = folderType;
    }

    public BatchDeleteFolderRecords(String folderType, Set<String> domainSet, Boolean isAdmin) {
        this.domainSet = domainSet;
        this.folderType = folderType;
        this.isAdmin = isAdmin;
    }

    public database.querylocator start(Database.BatchableContext bc){
        String query = 'SELECT Id FROM Folder__c where type__c=:folderType and Is_Deleted__c= false ';
        if(isAdmin == false) {
            query +=  ' and OwnerId =\''+UserInfo.getUserId()+'\'';
        }
        if(domainSet != null && domainSet.size()>0){
            query += ' AND Is_System_Folder__c = false AND Domain__c IN: domainSet';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, sObject[] objects) {
        List<Folder__c> folderList = (List<Folder__c>)objects;
        for(Folder__c folderObj : folderList) {
            folderObj.Is_Deleted__c = true;            
        }
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(folderList), new List<Schema.SObjectField>{
            Folder__c.Is_Deleted__c
        });
    }

    public void finish(Database.BatchableContext bc) {

        if(domainSet != null && domainSet.size()>0 && folderType == IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE){
            List<Folder__c> rootFolderList = getRootFolderList();
            if(rootFolderList!= null && rootFolderList.size()>0){
                Set<String> userIds = new Set<String>();
                for(Folder__c folder : rootFolderList){
                    userIds.add(folder.OwnerId);
                }
                Map<String, String> userIdPeopleIntDomainMap = PeopleDao.getUserIdPeopleIntDomainMap(userIds, IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE);
                Set<String> siteIdsToUpdate = new Set<String>();
                Set<String> folderIdsToUpdate = new Set<String>();
                for(Folder__c folder : rootFolderList){
                    if(userIdPeopleIntDomainMap.containsKey(folder.OwnerId) && String.isNotBlank(userIdPeopleIntDomainMap.get(folder.OwnerId)) && domainSet.contains(userIdPeopleIntDomainMap.get(folder.OwnerId))){
                        siteIdsToUpdate.add(folder.Site__c);
                        folderIdsToUpdate.add(folder.Id);
                    }
                }
                updateSiteList(siteIdsToUpdate);
                updateFolderList(folderIdsToUpdate);
                deleteLinkedSiteFolders(siteIdsToUpdate);
            }
            // synchornous Batch execution For deleting specific domain Google Drive people integration
		    Database.executeBatch(new BatchDeleteIntegrationRecords( new List<String>{ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING}, BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION, domainSet), 200);
        }
    }

    // get root folder list for integration type
    private List<Folder__c> getRootFolderList(){
        List<Folder__c> rootFolderList = new List<Folder__c>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', folderType);
        String query = 'SELECT Id, OwnerId, Site__c FROM Folder__c WHERE Is_Deleted__c= false ' +
                        ' AND type__c=: soqlParam1 AND Is_System_Folder__c = true';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        rootFolderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        return rootFolderList;
    }

    // update site settings to remove google drive as storage provider
    private void updateSiteList(Set<String> siteIds){
        if(siteIds != null && siteIds.size()>0){
            List<Simpplr_Site__c> siteList = new List<Simpplr_Site__c>();
            for(String siteId: siteIds){
                Simpplr_Site__c siteObj = new Simpplr_Site__c(Id = siteId);
                siteObj.File_Storage_Source__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
                siteList.add(siteObj);
            }     
            if(!siteList.isEmpty()) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
                                                                                Simpplr_Site__c.File_Storage_Source__c
                                                                            });
            }
        }
    }

    // soft delete root folder 
    private void updateFolderList(Set<String> folderIds){
        if(folderIds != null && folderIds.size()>0){
            List<Folder__c> folderList = new List<Folder__c>();
            for(String folderId: folderIds){
                Folder__c folderObj = new Folder__c(Id = folderId);
                folderObj.Is_Deleted__c = true;
                folderList.add(folderObj);
            }
            if(!folderList.isEmpty()) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(folderList), new List<Schema.SObjectField>{
                                                                                Folder__c.Is_Deleted__c
                                                                            });
            }
        }
    }

    // delete root folders child folders
    private void deleteLinkedSiteFolders(Set<String> siteIds){
        if(siteIds != null && siteIds.size()>0){
            Map<String, Object> soqlParamMap = new Map<String, Object>();
		    soqlParamMap.put('soqlParam1', folderType);
            soqlParamMap.put('soqlParam2', siteIds);
            List<Folder__c> folderList = new List<Folder__c>();
            String query = 'SELECT Id from Folder__c WHERE Type__c =: soqlParam1 ' + 
            ' AND Is_Deleted__c = false AND Site__c IN: soqlParam2';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
            for(Folder__c folder : folderList){
                folder.Is_Deleted__c = true;
            }
            if(!folderList.isEmpty()) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(folderList), new List<Schema.SObjectField>{
                                                                                Folder__c.Is_Deleted__c
                                                                            });
            }
        }
    }
}