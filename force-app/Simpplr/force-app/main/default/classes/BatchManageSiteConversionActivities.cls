public with sharing class BatchManageSiteConversionActivities implements Database.Batchable<SObject>{
    private String siteIdSetJSON;
    private String previousSiteType;
    private String newSitetype;
    private Set<String> siteIdSet = new Set<String>();
    
    public BatchManageSiteConversionActivities(String reqJSON , String oldType, String newType) {
        siteIdSetJSON = reqJSON;
        previousSiteType = oldType;
        newSitetype = newType;
    }

    public database.querylocator start(Database.BatchableContext bc){
        siteIdSet = ( Set<String>)JSON.deserializeStrict(siteIdSetJSON, Set<String>.class);
        String query = 'SELECT Id, Chatter_Group_Id__c, Site_Type__c, Is_Active__c, Is_Deleted__c, '+
            ' (SELECT Id, Is_Member__c, Is_Manager__c, Is_Content_Manager__c, People__c, People__r.User__c From Site_Roles__r WHERE Is_Deleted__c = false) FROM Simpplr_Site__c WHERE Id IN:siteIdSet ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, sObject[] objects) {
        List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)objects;
        if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(newSitetype) && 'Non Public'.equalsIgnoreCase(previousSiteType)){
            //Do nothing
        } else if((ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(newSitetype) || ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(newSitetype)) && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(previousSiteType)){
           Set<String> siteIdSetForTiles = new Set<String>();
            for(Simpplr_Site__c siteRecord : siteList){
                siteIdSetForTiles.add(siteRecord.id);
           }
           changeSiteRoleWhenSiteChangesToPrivate(siteIdSetForTiles);
            removeFollowersRelatedTiles(siteIdSetForTiles);
        }
        
    }

    public void finish(Database.BatchableContext bc) {
    }

    private void removeFollowersRelatedTiles(Set<String> siteIdSet){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', siteIdSet);
        String query = 'SELECT Id, Is_Deleted__c, Data__c, Is_Active__c FROM Tiles_Config__c WHERE Variant__c=\'site_members\' AND site__c IN :soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Tiles_Config__c> tileConfigList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(Tiles_Config__c tileConfigRecord : tileConfigList){

            TileDataWrapper.TileDataSettings tileDataWrapper;
			if(String.isNotBlank(tileConfigRecord.Data__c)){
                tileDataWrapper = (TileDataWrapper.TileDataSettings) JSON.deserialize(tileConfigRecord.Data__c, TileDataWrapper.TileDataSettings.class);
                if(tileDataWrapper.siteMembers != null && (tileDataWrapper.siteMembers == false || (tileDataWrapper.siteMembers == true && tileDataWrapper.siteFollowers == true))) {
                    tileConfigRecord.Is_Deleted__c = true;
			        tileConfigRecord.Is_Active__c = false;
                }
            }
            
		}
		if(tileConfigList.isEmpty() == false){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(tileConfigList),new List<Schema.SObjectField>{Tiles_Config__c.Is_Deleted__c, Tiles_Config__c.Is_Active__c});
		}
    }
    
    private void changeSiteRoleWhenSiteChangesToPrivate(Set<String> siteIdSet){
        //Convert all "Members and Followers" of Public Site to "Members" of Private Site
        List<Site_Role__c> siteRoleListOfFollowers = [Select Id, Is_Member__c, Is_Manager__c, Sync_Status__c, Is_Content_Manager__c From Site_Role__c Where Site__c IN: siteIdSet And Is_Member__c = false AND Is_Deleted__c = false];
        List<Site_Role__c> listOfFollowers = new List<Site_Role__c>();
        for(Site_Role__c siteRoleObj : siteRoleListOfFollowers) {
            siteRoleObj.Is_Member__c = true;
            siteRoleObj.Sync_Status__c = 0;
            listOfFollowers.add(siteRoleObj);
        }

        if(listOfFollowers.isEmpty() == false){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Site_Role__c>(listOfFollowers), new List<Schema.SObjectField>{
                                                                    Site_Role__c.Is_Member__c,
                                                                    Site_Role__c.Sync_Status__c
                                                                });

        }
    }
    
}