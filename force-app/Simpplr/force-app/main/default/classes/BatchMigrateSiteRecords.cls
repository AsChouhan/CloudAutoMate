public with sharing class BatchMigrateSiteRecords implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful {

	private String sfdcSessionId; 
	private String recordType;
	private Exception exceptionDetailsObj;
	
	public BatchMigrateSiteRecords(){
		this.sfdcSessionId = UserInfo.getSessionId();
		this.recordType = 'SiteTitleImage';
	}   
	public BatchMigrateSiteRecords(String recordType){
		this.sfdcSessionId = UserInfo.getSessionId();
		this.recordType = recordType;
	}
	
	
    public database.querylocator start(Database.BatchableContext bc) {
    	
    	String query;
    	if('disableAllSiteDashboardAndContentFeature'.equalsIgnoreCase(recordType)) {
    		query = 'Select id, Has_Albums__c, Has_Events__c, Has_Pages__c, Landing_Page__c, Layout__c from Simpplr_Site__c where is_Active__c = true and is_Deleted__c = false and Show_In_Simpplr__c = true';
		
		} else if('migrateCollaborationGroupMembers'.equalsIgnoreCase(recordType) || 'migrateGroupMembership'.equalsIgnoreCase(recordType)) {
			query = 'SELECT Id, CollaborationGroupId, CollaborationGroup.OwnerId, MemberId, CollaborationRole' +
					' FROM CollaborationGroupMember' +
					' WHERE Member.IsActive = true AND Member.UserType=\'Standard\'' +
					' ORDER BY CollaborationGroupId';

		} else {
    		query = 'SELECT Id, FullPhotoUrl FROM CollaborationGroup where isArchived=false and (not FullPhotoUrl like \'%/0F9/F%\')';
    	}
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, sObject[] listOfsObject) {
    	try{
	    	if('disableAllSiteDashboardAndContentFeature'.equalsIgnoreCase(recordType)) {
	    		List<Simpplr_Site__c > listOfSimpplrSite = (List<Simpplr_Site__c >)listOfsObject;
	    		disableAllSiteDashboardAndContentFeature(listOfSimpplrSite);
			
			} else if('migrateCollaborationGroupMembers'.equalsIgnoreCase(recordType)) {
				migrateCollaborationGroupMembers((List<CollaborationGroupMember>)listOfsObject);

			} else if('migrateGroupMembership'.equalsIgnoreCase(recordType)) {
				List<GroupMember> groupMembershipList = Utility.getGroupMembershipToCreate((List<CollaborationGroupMember>)listOfsObject);
				Database.insert(groupMembershipList);

	    	} else {
		    	List<CollaborationGroup > listOfCollGrp = (List<CollaborationGroup >)listOfsObject;
				updateSiteContentVrsnId(listOfCollGrp);
	    	}
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    
	}
	
	private void migrateCollaborationGroupMembers(List<CollaborationGroupMember> collabMembersList) {
		Set<String> chatterGroupIdsSet = new Set<String>();
		Set<String> userIdsSet = new Set<String>();

		for(CollaborationGroupMember collabMembersObj : collabMembersList) {
			chatterGroupIdsSet.add(collabMembersObj.CollaborationGroupId);
			userIdsSet.add(collabMembersObj.MemberId);
		}

		Map<String, String> chatterGroupIdAndSiteIdMap= new Map<String, String>();
		List<Simpplr_Site__c> sitesList = [SELECT Id, Name, Chatter_Group_Id__c FROM Simpplr_Site__c WHERE Chatter_Group_Id__c = :chatterGroupIdsSet];
		for(Simpplr_Site__c sSite : sitesList) {
			chatterGroupIdAndSiteIdMap.put(sSite.Chatter_Group_Id__c, sSite.id );
		}

		Map<String, String> userIdAndPeopleIdMap = new Map<String, String>();
		List<People__c> peopleList = [SELECT Id, User__c from People__c where User__c in: userIdsSet];
		for(People__c people: peopleList ){
			userIdAndPeopleIdMap.put(people.User__c, people.id);
		}

		
		List<Site_Role__c> siteRolesToInsert = new List<Site_Role__c>();
		for( CollaborationGroupMember cGMObj : collabMembersList ){
			Site_Role__c sRObj = new Site_Role__c();
			
			sRObj.People__c = userIdAndPeopleIdMap.get(cGMObj.MemberId);
			sRObj.Site__c = chatterGroupIdAndSiteIdMap.get(cGMObj.CollaborationGroupId);

			sRObj.Is_Manager__c = false;
			sRObj.Is_Content_Manager__c = false;
			sRObj.Is_Member__c = false;

			if('admin'.equalsIgnoreCase(cGMObj.CollaborationRole)) {
				sRObj.Is_Manager__c = true;
				sRObj.Is_Member__c = true;
			}
			
			siteRolesToInsert.add(sRObj);
		}
		
		SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().insertAsUser(siteRolesToInsert,
			new List<Schema.SObjectField>{
				Site_Role__c.People__c,
				Site_Role__c.Site__c,
				Site_Role__c.Is_Manager__c,
				Site_Role__c.Is_Content_Manager__c,
				Site_Role__c.Is_Member__c
			});
	}
    
    public void finish(Database.BatchableContext bc){
    		
    		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchMigrateSiteRecords.' + recordType, exceptionDetailsObj);
		}
		
    		if('disableAllSiteDashboardAndContentFeature'.equalsIgnoreCase(recordType)) {
	    		Map<String, Object> mapOfActivityParams = new Map<String, Object>();
	    		mapOfActivityParams.put('InactiveFeatures', new List<String>{'Page','Event','Album'});
		    	mapOfActivityParams.put('listOfSitesWithInactiveFeatures', new List<String>{'all'});
			
			BatchResetMustRead job = new BatchResetMustRead('FeaturesInactive',true,mapOfActivityParams);
			Database.executeBatch(job,2000);
    		} else if('migrateCollaborationGroupMembers'.equalsIgnoreCase(recordType)) {
				BatchMigrateSiteRecords job = new BatchMigrateSiteRecords('migrateGroupMembership');
                Database.executeBatch(job,200);
			}
    }
    private void disableAllSiteDashboardAndContentFeature(List<Simpplr_Site__c> listOfSimpplrSite){
		
	    	String newLayout = SimpplrContext.isFeedEnabled ? 'e' : 'd';
	    	for(Simpplr_Site__c siteObj : listOfSimpplrSite) {
	    		siteObj.Has_Albums__c = false;
	    		siteObj.Has_Events__c = false;
	    		siteObj.Has_Pages__c = false;
	    		siteObj.Landing_Page__c = 'feed';
	    		siteObj.Layout__c = newLayout;
	    	}
	    	update listOfSimpplrSite;
    	
    }
    
    private void updateSiteContentVrsnId(List<CollaborationGroup> listOfColbGrp){

		Set<Id> collIdSet = new Set<Id>();
		SiteDao siteDao =  new SiteDao();
		
		for(CollaborationGroup clbGrp : listOfColbGrp){
	        collIdSet.add(clbGrp.Id);
		}
		
		List<Simpplr_Site__c> simpplrSiteList = [SELECT id,Chatter_Group_Id__c,Site_Type__c,Title_Content_Version__c,Title_Content_Document__c FROM Simpplr_Site__c where Chatter_Group_Id__c IN : collIdSet AND Title_Content_Version__c = null];
		List<ContentVersion> listOfContVersn = new List<ContentVersion>();
				
		For (Simpplr_Site__c site: simpplrSiteList){
			Simpplr_Site__c siteObj = new Simpplr_Site__c();
			
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			String fullPhotoURL =SimpplrContext.salesforceHost+'/services/data/v36.0/chatter/groups/'+site.Chatter_Group_Id__c+'/photo';
		    req.setEndpoint(fullPhotoURL);
			req.setMethod('GET');
		    		
		    req.setHeader('Accept', 'application/json');
        	req.setHeader('Content-Type', 'application/json');
        	req.setHeader('Authorization', 'OAuth ' + sfdcSessionId);		
			HttpResponse res = http.send(req);
			Map<String, object> responseObj = (Map<String, object>)Json.deserializeUntyped(res.getBody());
			String url = (String) responseObj.get('fullEmailPhotoUrl');
			url = SimpplrContext.salesforceHost+'/ncsphoto' + url.substringAfter('ncsphoto');
			req = new HttpRequest();
			req.setMethod('GET');
			req.setEndpoint(url);
			res = http.send(req);
					
			ContentVersion contentObj = new ContentVersion();
		
			contentObj.versionData = res.getBodyAsBlob();
			contentObj.title = site.id +'SiteTitleImage.gif' ; 
			contentObj.origin = 'H' ; 
			contentObj.pathOnClient = 'simp_site_title_img'+ '#' + site.Id + '#' + ServiceConstants.REMOVE_FILE_SEARCH_IDENTIFIER +'#' + 'SiteTitleImage.gif';
			
			listOfContVersn.add(contentObj);
		}
		
		if(listOfContVersn.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listOfContVersn,
																												  new List<Schema.SObjectField>{
																												  		ContentVersion.versionData,
																												  		ContentVersion.title,
																												  		ContentVersion.Origin,
																												  		ContentVersion.pathOnClient});
			
			listOfContVersn = (List<ContentVersion>)result.getInsertedObjects();
			String queryStr = 'select id, contentDocumentId,pathOnClient from ContentVersion where id=:listOfContVersn';
	    	
	    	if(SimpplrContext.isCommunitiesEnabled){
	    		queryStr += ' AND networkid = null';
	    	}
	    	
			List<ContentVersion> listOfContentVersion = Database.query(queryStr);
			Map<String, ContentVersion> mapOfSiteIdAndContentVersion =  new  Map<String, ContentVersion>();
			
			for (ContentVersion cv : listOfContentVersion){
			    mapOfSiteIdAndContentVersion.put(cv.pathOnClient.subString(20,38),cv);
			}
			
			For (Simpplr_Site__c site : simpplrSiteList){
				site.Title_Content_Version__c = mapOfSiteIdAndContentVersion.get(site.id).Id;
				site.Title_Content_Document__c = mapOfSiteIdAndContentVersion.get(site.id).contentDocumentId;
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(simpplrSiteList),
													  new List<Schema.SObjectField>{Simpplr_Site__c.Title_Content_Version__c,
																				    Simpplr_Site__c.Title_Content_Document__c
																				   });		
			
			siteDao.createContentDocumentLink(simpplrSiteList);
		}
	}
}