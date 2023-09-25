public without sharing class BatchCampaignNotifications implements Database.Batchable<sObject>, Database.Stateful{
	private String campaignId;
	private String audienceId;
	private String recordType;
	private Boolean runNextBatchInSequence;
	private Exception exceptionDetailsObj;
	private Boolean isCalledFromScheduler = false;
	
	Integer totalCampaignsSharedCount = 0;
	Integer totalCampaignsSharedPeopleCount = 0;
	Set<Id> setCampaignSharedPeopleIds = new Set<Id>();
	Set<Id> setSharedCampaignIds = new Set<Id>();
	Map<Id, App_Notification__c> mapOfPeopleIdNotifications = new Map<ID, App_Notification__c>();
	
	public BatchCampaignNotifications(String campaignId, String recordType){
		this.campaignId = campaignId;
		this.audienceId = null;
		this.recordType = recordType; 
		this.runNextBatchInSequence = false;
	}
	
	public BatchCampaignNotifications(String recordType, Boolean runNextBatchInSequence){
		this.campaignId = null;
		this.audienceId = null;
		this.recordType = recordType;
		this.runNextBatchInSequence = runNextBatchInSequence;
		this.isCalledFromScheduler = true;
	}

	public BatchCampaignNotifications(String campaignId, String audienceId, String recordType){
		this.campaignId = campaignId;
		this.audienceId = audienceId;
		this.recordType = recordType; 
		this.runNextBatchInSequence = false;
	}
	
    public database.querylocator start(Database.BatchableContext bc){
    	String query = '';
    	
    	if('NewCampaignNotifcations'.equalsIgnoreCase(recordType)){
			query =  'Select People__c FROM Audience_Member__c WHERE Audience__c = :audienceId ';
			
			if (Utility.isApiOnlyUserQueryable()) {
				query += ' AND (People__r.User__r.Show_Simpplr__c =\'Yes\' OR (People__r.User__r.Show_Simpplr__c != \'No\' AND People__r.User__r.isActive=true AND People__r.User__r.UserType=\'Standard\' AND People__r.User__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				query += ' AND (People__r.User__r.Show_Simpplr__c =\'Yes\' OR (People__r.User__r.Show_Simpplr__c != \'No\' AND People__r.User__r.isActive=true AND People__r.User__r.UserType=\'Standard\')) ';
			}
			
    	} else if('CampaignAnalyticsDataPrepare'.equalsIgnoreCase(recordType)){
    		query = 'Select Id,Is_Created_In_Last_14_Days__c,Is_Created_In_Last_7_Days__c, CreatedDate From Social_Campaign_Share__c'
    				+ ' Where (Is_Created_In_Last_7_Days__c = true Or Is_Created_In_Last_14_Days__c = true Or CreatedDate = LAST_N_DAYS:7) ';
    	
    	}else if ('WeeklyCampaignNotifcations'.equalsIgnoreCase(recordType)){
    		query = 'Select Id,Share_Count_Last_7_Days__c,People__c From Social_Campaign__c Where Is_Deleted__c= false and Share_Count_Last_7_Days__c > 0';

    	} else if('DeleteCampaignNotifcations'.equalsIgnoreCase(recordType)) {
			query =  'Select Id, Is_Deleted__c FROM App_Notification__c WHERE Object_Id__c = :campaignId AND Category__c = \'Social_Campaign_Ready\' AND Is_Deleted__c = false';

    	}
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
		try {
			if('NewCampaignNotifcations'.equalsIgnoreCase(recordType)){
				List<Audience_Member__c> listOfAudienceMembers = (List<Audience_Member__c>) listOfsObject;
				sendNotificationtoUsers(listOfAudienceMembers, campaignId);
	    		
			} else if('CampaignAnalyticsDataPrepare'.equalsIgnoreCase(recordType)){
				updateCampaignShareData((List<Social_Campaign_Share__c>) listOfsObject);
						
			}else if ('WeeklyCampaignNotifcations'.equalsIgnoreCase(recordType)){
				List<Social_Campaign__c> listOfSocialCampaignObj = (List<Social_Campaign__c>) listOfsObject;
				collectCampaignShareDetails(listOfSocialCampaignObj);

			} else if('DeleteCampaignNotifcations'.equalsIgnoreCase(recordType)) {
				List<App_Notification__c> notificationList = (List<App_Notification__c>) listOfsObject;
				deleteNotification(notificationList);
			}
	    }catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    
    private void sendNotificationtoUsers(List<Audience_Member__c> listOfAudienceMembers, String campaignId){
	    List<App_Notification__c> listOfNewNotifications = new List<App_Notification__c>();
	    	
	    for(Audience_Member__c audMember : listOfAudienceMembers){ 
			App_Notification__c notificationObj = new App_Notification__c();
		
			notificationObj.Category__c = 'Social_Campaign_Ready';
			notificationObj.Type__c = 'Information';
			notificationObj.Sub_Type__c = 'Campaign';
			notificationObj.Object_Id__c = campaignId;
			notificationObj.Object_Type__c = 'Social  Campaign';
			notificationObj.Sent_to__c = audMember.People__c;
			notificationObj.Created_DateTime__c = DateTime.now();
			listOfNewNotifications.add(notificationObj);
		}
		
		if(listOfNewNotifications.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfNewNotifications, 
				new List<Schema.SObjectField>{
					App_Notification__c.Category__c,
					App_Notification__c.Type__c,
					App_Notification__c.Sub_Type__c,
					App_Notification__c.Sent_to__c,
					App_Notification__c.Object_Type__c,
					App_Notification__c.Created_DateTime__c,
					App_Notification__c.Object_Id__c
				});
		}
    }

	private void deleteNotification(List<App_Notification__c> notificationList) {
		for(App_Notification__c appNotifRec : notificationList) {
			appNotifRec.Is_Deleted__c = true;
		}
		SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Notification__c>(notificationList), new List<Schema.SObjectField>{
			App_Notification__c.Is_Deleted__c
		});
	}
    
    private void updateCampaignShareData(List<Social_Campaign_Share__c> listOfCampaignShareObj){
    	
    	for(Social_Campaign_Share__c sc : listOfCampaignShareObj){
			if(sc.CreatedDate >= system.now().addDays(-7)){
				sc.Is_Created_In_Last_7_Days__c = true;
			} else if(sc.CreatedDate >= system.now().addDays(-14)){
				sc.Is_Created_In_Last_14_Days__c = true;
				sc.Is_Created_In_Last_7_Days__c = false;
			} else if(sc.Is_Created_In_Last_14_Days__c){
				sc.Is_Created_In_Last_14_Days__c = false; 
			}
		}
		
		update listOfCampaignShareObj;
    }

    /**
    * @description collect social campaigns shared details like people and counts
    * @param listOfSocialCampaignObj list of social campaigns shared this week.
    **/
    private void collectCampaignShareDetails(List<Social_Campaign__c> listOfSocialCampaignObj){
    	Set<Id> setCampaignIds = new Set<Id>();
    	for(Social_Campaign__c campObj : listOfSocialCampaignObj){
    		setCampaignIds.add(campObj.Id);
    		//stateful variable
    		totalCampaignsSharedCount = totalCampaignsSharedCount + 1;
    	}

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', setCampaignIds);
    	String queryStr = 'SELECT Id, People__c, Social_Campaign__c From Social_Campaign_Share__c WHERE Social_Campaign__c IN :soqlParam1 AND Is_Created_In_Last_7_Days__c = true';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign_Share__c> listSocialCampaignShare = (List<Social_Campaign_Share__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

    	if(listSocialCampaignShare != null && !listSocialCampaignShare.isEmpty()){
    		for(Social_Campaign_Share__c scShare : listSocialCampaignShare){
    			//stateful variable - uniq ids of shared people
	    		setCampaignSharedPeopleIds.add(scShare.People__c);
	    	}
    	}
    }

    /**
    * @description prepare notifications list and save
    **/
    private void saveInAppWeeklyNotifications(){
    	totalCampaignsSharedPeopleCount = setCampaignSharedPeopleIds != null ? setCampaignSharedPeopleIds.size() : 0;
    	prepareInAppWeeklyNotifications();

    	if(mapOfPeopleIdNotifications != null && !mapOfPeopleIdNotifications.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    	SIMPESAPI.accessController().insertAsUser(mapOfPeopleIdNotifications.values(), 
				new List<Schema.SObjectField>{
					App_Notification__c.Submitter_Comment__c,
					App_Notification__c.Type__c,
					App_Notification__c.Sub_Type__c,
					App_Notification__c.Sent_to__c,
					App_Notification__c.Object_Type__c,
					App_Notification__c.Created_DateTime__c
				});
    	}
    }

    /**
    * @description prepare in app weekly notifications for all people with manage access to social campaigns
    **/
    private void prepareInAppWeeklyNotifications(){
    	//Get all the peoples with manage social compaign access
    	Map<Id, People__c> mapPeopleWithCompaignAccess = PeopleDao.getPeopleMapManageSocialCompAccess();
    	//ensure shared compaigns and people count > 0
    	if(mapPeopleWithCompaignAccess != null && totalCampaignsSharedPeopleCount > 0 && totalCampaignsSharedCount > 0){
    		String peopleCountText = totalCampaignsSharedPeopleCount == 1 ? '1 person' : totalCampaignsSharedPeopleCount +' people';
			String sharedCountText = totalCampaignsSharedCount == 1 ? '1 Social Campaign' : totalCampaignsSharedCount +' Social Campaigns';
    		for(People__c people: mapPeopleWithCompaignAccess.values()){
    			App_Notification__c notificationObj = new App_Notification__c();
	            notificationObj.Submitter_Comment__c = peopleCountText +' shared '+ sharedCountText +' this week';
				notificationObj.Type__c = 'Information';
				notificationObj.Sub_Type__c = 'Campaign';
				notificationObj.Sent_to__c = people.Id;
				notificationObj.Object_Type__c = 'Social  Campaign';
				notificationObj.Created_DateTime__c = DateTime.now();
				mapOfPeopleIdNotifications.put(people.Id, notificationObj);
    		}
    	}
    }
    
    public void finish(Database.BatchableContext BC){
    	
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchCampaignNotifications.' + recordType, exceptionDetailsObj);
		}
		
    	if('NewCampaignNotifcations'.equalsIgnoreCase(recordType)){
    			//Do Nothing
    		
		} else if('CampaignAnalyticsDataPrepare'.equalsIgnoreCase(recordType) && runNextBatchInSequence){
			BatchCampaignNotifications job = new BatchCampaignNotifications('WeeklyCampaignNotifcations', runNextBatchInSequence);
			Database.executeBatch(job,2000);
					
		} else if ('WeeklyCampaignNotifcations'.equalsIgnoreCase(recordType)){
			saveInAppWeeklyNotifications();
			if(isCalledFromScheduler && !Test.isRunningTest()) {
				// Added to execute nigthly jobs sequentially
				SchedulerSimpplrServices.executeNextJob('compaignNotifications');
			}			
		} else if(!'DeleteCampaignNotifcations'.equalsIgnoreCase(recordType)){
			if(isCalledFromScheduler) {
				// Added to execute nigthly jobs sequentially
				SchedulerSimpplrServices.executeNextJob('compaignNotifications');				
			}
		}
    }
    	
}