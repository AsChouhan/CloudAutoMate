public with sharing class BatchPullNewsletterTrackerData implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    private boolean hasmoredata;
    private String lastDataId;
    private Exception exceptionDetailsObj;
    
    public BatchPullNewsletterTrackerData() {
    	hasmoredata = false;
    }
    
    public database.querylocator start(Database.BatchableContext bc) {
    	String query = ' select id, Newsletter_Tracker_Data_Fetch_URL__c, Newsletter_Tracker_Last_Data_Id__c ' +
    				   ' from App_Config__c ';
    				   
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<App_config__c> listOfAppConfig) {
    	
    	try{
	    	App_config__c appConfigObj = listOfAppConfig[0];
	    	Boolean status = pullNewsletterTrackerData(appConfigObj);
	    	if(status) {
	    		appConfigObj.Newsletter_Tracker_Last_Data_Id__c = lastDataId;

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
																		App_config__c.Newsletter_Tracker_Last_Data_Id__c
																	});
	    	}
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    
    private Boolean pullNewsletterTrackerData(App_Config__c appConfigObj) {
    	Boolean success = false;
		lastDataId = String.isBlank(appConfigObj.Newsletter_Tracker_Last_Data_Id__c) ? '0' : appConfigObj.Newsletter_Tracker_Last_Data_Id__c;
		String url = String.isBlank(appConfigObj.Newsletter_Tracker_Data_Fetch_URL__c) ? 'https://services.simpplr.com/nlt/fetch-tracker-data.php?dri=' : appConfigObj.Newsletter_Tracker_Data_Fetch_URL__c;
		
		HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET',url + Utility.requestNewsltterDataAuthToken(lastDataId), '',null,new Map<String,String>());
		if(res.getStatusCode()==200){
			NewsletterTrackerData trackerData = (NewsletterTrackerData) JSON.deserialize(res.getBody(), NewsletterTrackerData.class);
			if(trackerData != null) {
				success = 'success'.equalsIgnoreCase(trackerData.status);
				if(success && trackerData.data != null && trackerData.data.size() > 0) {
					lastDataId = trackerData.lastdataid;
					updateTrackerDataInDB(trackerData.data);
					hasmoredata = trackerData.hasmoredata;
				}
			}
		}
		return success;
    }
    @TestVisible
    private void updateTrackerDataInDB(List<TrackerData> listOfTrackerData) {
    	Set<String> setOfUserHash = new Set<String>(); 
    	for(TrackerData trackerDataObj : listOfTrackerData) {
    		setOfUserHash.add(trackerDataObj.useridhash);
    	}
    	
    	List<People__c> listOfPeople = [select id, User_Hash__c from People__c where User_Hash__c=:setOfUserHash];
    	Map<String, String> mapOfUserHashToPeopleId = new Map<String, String>(); 
    	for(People__c peopleObj:listOfPeople) {
    		mapOfUserHashToPeopleId.put(peopleObj.User_Hash__c, peopleObj.Id);
    	}
    	
		Set<String> setOfUniqueKeys = new Set<String>();
		List<Id> listOfNewsletterIds = new List<Id>();
    	for(TrackerData trackerDataObj : listOfTrackerData) {
    		String peopleId = mapOfUserHashToPeopleId.get(trackerDataObj.useridhash);
    		if(String.isNotBlank(peopleId)) {
				setOfUniqueKeys.add(trackerDataObj.newsletterId + peopleId);
				listOfNewsletterIds.add(trackerDataObj.newsletterid);
    		}
    	}
    	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', setOfUniqueKeys);
		String anlytcsMailerQuery = 'select id, First_Open_DateTime__c, Unique_key__c ' +
			' from Analytics_Mailer__c ' +
			' where Unique_key__c =: soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Analytics_Mailer__c> listOfMailerDetails = (List<Analytics_Mailer__c>)SIMPESAPI.accessController().queryAsUser(anlytcsMailerQuery, soqlParamMap);
														 

		soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfNewsletterIds);
		String query = 'Select Id From Mailer__c where Id =: soqlParam1';													 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer__c> ListOfNewsletter = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);												 
		Map<Id, Mailer__c> mapOfNewsletterIds = new Map<Id, Mailer__c>(ListOfNewsletter);
    	
    	Map<String, Analytics_Mailer__c> mapOfExistingAnalyticsRecords = new Map<String, Analytics_Mailer__c>();
    	for(Analytics_Mailer__c analyticsMailerObj : listOfMailerDetails) {
    		mapOfExistingAnalyticsRecords.put(analyticsMailerObj.Unique_key__c, analyticsMailerObj);	
		}

    	List<Analytics_Mailer__c> listOfNewAnalyticsRecords = new List<Analytics_Mailer__c>();
    	List<Analytics_Mailer__c> listOfUpdatedAnalyticsRecords = new List<Analytics_Mailer__c>();
    	
    	for(TrackerData trackerDataObj : listOfTrackerData) {
    		String peopleId = mapOfUserHashToPeopleId.get(trackerDataObj.useridhash);
    	
    		if(String.isNotBlank(trackerDataObj.useridhash)) {
    			Analytics_Mailer__c analyticsObj;
    	
    			if(mapOfExistingAnalyticsRecords.containsKey(trackerDataObj.newsletterid + peopleId)) {
    				analyticsObj = mapOfExistingAnalyticsRecords.get(trackerDataObj.newsletterid + peopleId);
    				analyticsObj.First_Open_DateTime__c = Utility.convertStringTodateTime(trackerDataObj.createddatetime);
    				analyticsObj.Tracker_Data_Id__c = trackerDataObj.Id;
    				listOfUpdatedAnalyticsRecords.add(analyticsObj);
    	
    			} else if(mapOfNewsletterIds.containsKey(trackerDataObj.newsletterid)) {
    				analyticsObj = new Analytics_Mailer__c();
    				analyticsObj.People__c = peopleId;
    				analyticsObj.Mailer__c = trackerDataObj.newsletterid;
    				analyticsObj.Click_Count__c = 0;
    				analyticsObj.First_Open_DateTime__c = Utility.convertStringTodateTime(trackerDataObj.createddatetime);
    				analyticsObj.Tracker_Data_Id__c = trackerDataObj.Id;
    				listOfNewAnalyticsRecords.add(analyticsObj);
    			}
    		}
    	}
    	if(listOfUpdatedAnalyticsRecords.isEmpty() == false) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Mailer__c>(listOfUpdatedAnalyticsRecords), new List<Schema.SObjectField>{
				Analytics_Mailer__c.First_Open_DateTime__c,
				Analytics_Mailer__c.Tracker_Data_Id__c
			});
    	} 
    	if(listOfNewAnalyticsRecords.isEmpty() == false) {

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfNewAnalyticsRecords, new List<Schema.SObjectField>{
				Analytics_Mailer__c.People__c,
				Analytics_Mailer__c.Mailer__c,
				Analytics_Mailer__c.Click_Count__c,
				Analytics_Mailer__c.First_Open_DateTime__c,
				Analytics_Mailer__c.Tracker_Data_Id__c
			});
    	}
    }
    
    public void finish(Database.BatchableContext bc) {
    	
		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		Boolean hasError = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			hasError = true;
			Utility.sendExceptionEmail('BatchPullNewsletterTrackerData', exceptionDetailsObj);
		}
		
	    	if(hasmoredata) {
	    		BatchPullNewsletterTrackerData job = new BatchPullNewsletterTrackerData();
	    		DataBase.executeBatch(job, 1);
	    	} else if(checkAnalyticsDataCollectionAllowed(hasError)) {
	    		BatchNewsletter job = new BatchNewsletter('sendAnalyticsDataToAWS');
		    	DataBase.executeBatch(job, 500);
	    	}
    }
    
    public Boolean checkAnalyticsDataCollectionAllowed(Boolean hasError) {
    	Boolean analyticsDataCollectionAllowed = true;
    	
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('site', true);
		DataBase.executeBatch(job, 1000);
    	
    	return analyticsDataCollectionAllowed;
    }
    
    public class NewsletterTrackerData {
    	 public String status;
    	 public String message;
    	 public String lastdataid;
    	 public Boolean hasmoredata;
    	 public List<TrackerData> data;
    }
    
	public class TrackerData {
		public String id;
	 	public String newsletterid;
	 	public String useridhash;
	 	public String createddatetime;
	 }
}