public without sharing class BatchVideoNotifications implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
	
	private String batchContext;
	public Boolean runNext;
	private Exception exceptionDetailsObj;
	private final String BATCH_SEND_NOTIFICATION = 'sendNotification';
	
	public BatchVideoNotifications() {

	}

	public BatchVideoNotifications(String batchContext) {
		this.batchContext = batchContext;
	}

	public database.querylocator start(Database.BatchableContext bc) {
		String packageName = SimpplrContext.packageName;
		String query;
		if('sendNotification'.equalsIgnoreCase(batchContext)) {
			query = 'SELECT Id, Name, App_Moderation_Permission__c FROM People__c where User__r.isActive = true and User__r.UserType=\'Standard\' and is_Deleted__c = false and App_Moderation_Permission__c = \'yes\' ';
						
			if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
				query +=' and User__c IN '+
						'(select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			} 
		} else {
			// do nothing
		}

		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {    	
		try{
			if('sendNotification'.equalsIgnoreCase(batchContext)){ 
				List<People__c> peopleList = (List<People__c>)listOfsObject;
				Set<String> appManagerIdSet = new Set<String>();
				for(People__c peopleObj : peopleList){
					appManagerIdSet.add(peopleObj.id);
				}
				if(appManagerIdSet.size() > 0) {
					sendNotification(appManagerIdSet);
				}

			} else {
				// do nothing
			}
			
		} catch(Exception ex) {
			exceptionDetailsObj =  ex;
			throw ex;
		}
	}

	public void finish(Database.BatchableContext BC){
		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchVideoNotifications.' + batchContext, exceptionDetailsObj);
		}
	}

	private void sendNotification(Set<String> appManagerIds) {
		Set<String> appManagerUnreadNotification = new Set<String>();
		List<App_Notification__c> appNotificationList = [SELECT Id, Action_By__c, Sent_To__c, Category__c, Is_Deleted__c, Object_Id__c, Object_Type__c, Sub_Type__c, Type__c, Is_Read__c FROM App_Notification__c where 
															Is_Deleted__c = false and Is_Read__c = false and Object_Type__c = 'video' and Sub_Type__c = 'native_video'];
		
		
		for(App_Notification__c appNotificationObj : appNotificationList) {
			appManagerUnreadNotification.add(String.ValueOf(appNotificationObj.Sent_To__c));          
		}

		appManagerIds.removeAll(appManagerUnreadNotification);

		List<App_Notification__c> appNotificationInsertList = new List<App_Notification__c>();
		insertVideoNotificaion(appManagerIds);		
	}

	private void insertVideoNotificaion(Set<String> appManagerIdSet){
		List<App_Notification__c> appNotificationInsertList = new List<App_Notification__c>();
		for(String peopleId : appManagerIdSet) {
			App_Notification__c notificationObj = new App_Notification__c();
			notificationObj.GUID__c = UserContext.id + '-' + System.currentTimeMillis();
			notificationObj.Object_Type__c ='video';
			notificationObj.Category__c = 'video';
			notificationObj.Type__c = 'Actionable';
			notificationObj.Sub_Type__c = 'native_video';
			notificationObj.Status__c = 'Pending';
			notificationObj.Sent_To__c = peopleId;
			notificationObj.Created_DateTime__c = DateTime.now();
			notificationObj.Is_New__c = true;
			notificationObj.Is_Read__c = false;
			appNotificationInsertList.add(notificationObj);
		}
		if(appNotificationInsertList.size() > 0){
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

			fieldList.add(App_Notification__c.GUID__c);
			fieldList.add(App_Notification__c.Object_Type__c);
			fieldList.add(App_Notification__c.Category__c);
			fieldList.add(App_Notification__c.Type__c);
			fieldList.add(App_Notification__c.Sub_Type__c);
			fieldList.add(App_Notification__c.Status__c);
			fieldList.add(App_Notification__c.Sent_To__c);
			fieldList.add(App_Notification__c.Created_DateTime__c);
			fieldList.add(App_Notification__c.Is_New__c);
			fieldList.add(App_Notification__c.Is_Read__c);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(appNotificationInsertList, fieldList);
		}
	}

}