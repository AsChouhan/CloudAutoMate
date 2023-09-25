public with sharing class BatchResetMustRead implements Database.Batchable<sObject>, Database.stateful {
	String activity;
	Map<String, Object> mapOfActivityParams;
	Boolean runNextBatchInSequence; 
	private Exception exceptionDetailsObj;
	Set<String> setOfContentIds;
	List<String> listOfSiteIds;
	
	public BatchResetMustRead( String activity, Boolean runNextBatchInSequence,Map<String,Object> mapOfActivityParams) {
    	this.activity = activity;
    	this.runNextBatchInSequence = runNextBatchInSequence;
    	this.mapOfActivityParams = mapOfActivityParams;
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query ='';
		List<String> listOfContentIds;
		List<String> listOfArchivedSites;
		List<String> listOfInactiveFeatures;
		List<String> listOfSitesWithInactiveFeatures;
		Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
		DateTime currentDateTime = DateTime.now();
		if(activity.equalsIgnoreCase('SitesArchived')){
			setOfContentIds = new Set<String>();
			listOfArchivedSites = (List<String>) mapOfActivityParams.get('listOfArchivedSites');
			query = 'SELECT Id, Removed_By_People__c, Removed_DateTime__c, Content__c ' +
					'FROM Must_Read_Audit__c ' +
					'WHERE Content__r.site__c IN: listOfArchivedSites ' + 
					'And Content__r.Is_Deleted__c = false ' +
					'AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) ' +
					'AND Removed_DateTime__c = null ';
				
		}else if(activity.equalsIgnoreCase('FeaturesInactive')){
			setOfContentIds = new Set<String>();
			listOfInactiveFeatures = (List<String>) mapOfActivityParams.get('InactiveFeatures');
			listOfSitesWithInactiveFeatures = (List<String>) mapOfActivityParams.get('listOfSitesWithInactiveFeatures');
			
			Set<String> setOfSites = new Set<String>();
			setOfSites.addAll(listOfSitesWithInactiveFeatures);
			
			query = 'SELECT Id, Removed_By_People__c, Removed_DateTime__c, Content__c ' +
					'FROM Must_Read_Audit__c ' +
					'Where Content__r.Is_Deleted__c = false ' +
					'AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) ' +
					'AND Removed_DateTime__c = null ' +
					'And Content__r.Type__c IN : listOfInactiveFeatures ';

			if(setOfSites.contains('all') == false){				
				query += 'And Content__r.Site__c IN : listOfSitesWithInactiveFeatures ';

			}
			
		} else if(activity.equalsIgnoreCase('DeletePendingActionableNotifications')) {
			listOfContentIds = (List<String>) mapOfActivityParams.get('listOfContentIds');
			query = 'Select id from App_Notification__c where Content__c=:listOfContentIds ' + 
					' And Is_Deleted__c=false And Type__c=\'actionable\' ' +
					' And Category__c=\'Must_Read\' ' +
					' And Action_By__c=null ';
		} else if(activity.equalsIgnoreCase('DeleteMustReadNotificationsForNonSiteMembers')) {
			listOfSiteIds = (List<String>) mapOfActivityParams.get('listOfSiteIds');
			query = 'Select id, Sent_To__c, Sent_To__r.User__c, Content__r.Site__c, Content__r.Site__r.Chatter_Group_Id__c from App_Notification__c where Content__r.Site__c=:listOfSiteIds ' + 
					' And Is_Deleted__c=false And Type__c=\'actionable\' ' +
					' And Category__c=\'Must_Read\' ' +
					' And Action_By__c=null ';
		}
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
		try{
			if(activity.equalsIgnoreCase('SitesArchived')){
				List<Must_Read_Audit__c > mustReadAuditList = (List<Must_Read_Audit__c >)listOfsObject;
				updateMustReadAudit(mustReadAuditList);
			
			}else if(activity.equalsIgnoreCase('FeaturesInactive')){
				List<Must_Read_Audit__c > mustReadAuditList = (List<Must_Read_Audit__c >)listOfsObject;
				updateMustReadAudit(mustReadAuditList);

			} else if(activity.equalsIgnoreCase('DeletePendingActionableNotifications')) {
				List<App_Notification__c > appNotificationList = (List<App_Notification__c >)listOfsObject;
				markNotificationsDeleted(appNotificationList);
			} else if(activity.equalsIgnoreCase('DeleteMustReadNotificationsForNonSiteMembers')) {
				List<App_Notification__c > appNotificationList = (List<App_Notification__c >)listOfsObject;
				deleteMustReadNotificationsForNonSiteMembers(appNotificationList);
			}

		}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }


	public void deleteMustReadNotificationsForNonSiteMembers(List<App_Notification__c> appNotificationList) {
		Set<String> userIdSet = new Set<String>();
		Set<String> cgIdSet = new Set<String>();
		for(App_Notification__c appNotiObj : appNotificationList){
			userIdSet.add(appNotiObj.Sent_To__r.User__c);
			cgIdSet.add(appNotiObj.Content__r.Site__r.Chatter_Group_Id__c);
		}
		List<CollaborationGroupMember> cgmList = [SELECT Id, CollaborationGroupId, MemberId FROM CollaborationGroupMember WHERE MemberId IN:userIdSet];
		Map<String, Set<String>> mapOfUserIdToSetOfSiteIdFollowed = new Map<String,Set<String>>();
		for(CollaborationGroupMember cgmObj : cgmList){
			if(mapOfUserIdToSetOfSiteIdFollowed.get(cgmObj.MemberId) == null){
				mapOfUserIdToSetOfSiteIdFollowed.put(cgmObj.MemberId, new Set<String>());
			}
			if(cgIdSet.contains(cgmObj.CollaborationGroupId)) {
				mapOfUserIdToSetOfSiteIdFollowed.get(cgmObj.MemberId).add(cgmObj.CollaborationGroupId);
			}
		}
		List<App_Notification__c> appNotiListToBeDeleted = new List<App_Notification__c>();
		for(App_Notification__c appNotificationObj : appNotificationList) {
			Set<String> chatterGroupIdSet = mapOfUserIdToSetOfSiteIdFollowed.get(appNotificationObj.Sent_To__r.User__c);
			if(chatterGroupIdSet== null || chatterGroupIdSet.contains(appNotificationObj.Content__r.Site__r.Chatter_Group_Id__c) == false){
				App_Notification__c appNotificationTobeDelObj = new App_Notification__c();
				appNotificationTobeDelObj.id = appNotificationObj.id;
				appNotificationTobeDelObj.Is_Deleted__c = true;
				appNotiListToBeDeleted.add(appNotificationTobeDelObj);
			}
		}
		if(appNotiListToBeDeleted.isEmpty() == false) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Notification__c>(appNotiListToBeDeleted), 
														new List<Schema.SObjectField> {
															App_Notification__c.Is_Deleted__c
														});
		}
	}

	public void markNotificationsDeleted(List<App_Notification__c> appNotificationList) {
		for(App_Notification__c appNotificationObj : appNotificationList) {
			appNotificationObj.Is_Deleted__c = true;
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Notification__c>(appNotificationList), 
													new List<Schema.SObjectField> {
														App_Notification__c.Is_Deleted__c
													});
	}
	public void updateMustReadAudit(List<Must_Read_Audit__c > mustReadAuditList) {
		DateTime currentDateTime = DateTime.now();
		for(Must_Read_Audit__c mraObj : mustReadAuditList){
			mraObj.Removed_By_People__c = UserContext.peopleId;
			mraObj.Removed_DateTime__c = currentDateTime;
			mraObj.Removed_Reason__c = 'site_deactivated';
			setOfContentIds.add(mraObj.content__c);
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Must_Read_Audit__c>(mustReadAuditList), 
													new List<Schema.SObjectField> {
														Must_Read_Audit__c.Removed_By_People__c,
														Must_Read_Audit__c.Removed_DateTime__c,
														Must_Read_Audit__c.Removed_Reason__c
													});
	}
    
    public void finish(Database.BatchableContext BC){
    	
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchResetMustRead', exceptionDetailsObj);
		}
			
		if(runNextBatchInSequence) {
			if(activity.equalsIgnoreCase('SitesArchived') && setOfContentIds.isEmpty() == false){
				mapOfActivityParams.put('listOfContentIds', new List<String>(setOfContentIds));
				BatchResetMustRead job = new BatchResetMustRead('DeletePendingActionableNotifications',false,mapOfActivityParams);
				Database.executeBatch(job,2000);
			
			} else if(activity.equalsIgnoreCase('FeaturesInactive') && setOfContentIds.isEmpty() == false){
				mapOfActivityParams.put('listOfContentIds', new List<String>(setOfContentIds));
				BatchResetMustRead job = new BatchResetMustRead('DeletePendingActionableNotifications',false,mapOfActivityParams);
				Database.executeBatch(job,2000);
			}
		}
	}
}