public with sharing class BatchCheckAccessAndSendNotification implements Database.Batchable<sObject>, Database.Stateful{
	ConnectApi.FeedElement feedObject = null;
	List<Simpplr_Content__c> simpplrContentList = new List<Simpplr_Content__c>();
    Map<String, NotificationDao.Notification> notificationObjMap = new Map<String, NotificationDao.Notification>();
    Map<String,NotificationHelper.NotificationMetadata> targetIdtoSubjectMap = new Map<String,NotificationHelper.NotificationMetadata>();
    Map<String, String> body = new Map<String, String>();
    List<People_Preference__c> peoplePrefList = new List<People_Preference__c>();
    Boolean isReplyLike = false;
	Map<String, Integer> localisationCountsMap = new Map<String, Integer>();
    private Exception exceptionDetailsObj;
    
	// to be depricated
	public BatchCheckAccessAndSendNotification(String feedId, Map<String, NotificationDao.Notification> notificationObjMap,Map<String,NotificationHelper.NotificationMetadata> targetIdtoSubjectMap, Map<String, String> body,List<People_Preference__c> peoplePrefList, Boolean isReplyLike){
	}
	// to be depricated
	public BatchCheckAccessAndSendNotification(String feedId, Map<String, NotificationDao.Notification> notificationObjMap,Map<String,NotificationHelper.NotificationMetadata> targetIdtoSubjectMap, Map<String, String> body,List<People_Preference__c> peoplePrefList, Boolean isReplyLike, Map<String, Integer> localisationCountsMap){
	}

	public BatchCheckAccessAndSendNotification(ConnectApi.FeedElement feedObject, List<Simpplr_Content__c> simpplrContentList, Map<String, NotificationDao.Notification> notificationObjMap,Map<String,NotificationHelper.NotificationMetadata> targetIdtoSubjectMap, Map<String, String> body,List<People_Preference__c> peoplePrefList, Boolean isReplyLike, Map<String, Integer> localisationCountsMap){
    	this.feedObject = feedObject;
		this.simpplrContentList = simpplrContentList;
    	this.notificationObjMap = notificationObjMap;
    	this.targetIdtoSubjectMap = targetIdtoSubjectMap;
    	this.body = body;
    	
    	this.peoplePrefList = peoplePrefList;
    	
    	this.isReplyLike = isReplyLike;
		this.localisationCountsMap = localisationCountsMap;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	Set<String> userIdSet = new Set<String>();
    	userIdSet.addAll(notificationObjMap.keySet());
    	String query = 'Select Id from User where Id in :userIdSet';
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, User[] userList){
    	try{
    		Map<String, NotificationDao.Notification> notificationObjMapToSend = new Map<String, NotificationDao.Notification>();
    		Map<String,NotificationHelper.NotificationMetadata> targetIdtoSubjectMapToSend = new Map<String,NotificationHelper.NotificationMetadata>();
    		for(User userObj : userList) {
    			notificationObjMapToSend.put(userObj.id, notificationObjMap.get(userObj.id));
    			if(targetIdToSubjectMap.containsKey(userObj.id)) {
    				targetIdtoSubjectMapToSend.put(userObj.id, targetIdToSubjectMap.get(userObj.id));
    			}
    		}
		NotificationDispatcher.initLangKeyValueMap(peoplePrefList);
		NotificationDispatcher.checkAccessAndSendEmail(feedObject, simpplrContentList, notificationObjMapToSend,targetIdtoSubjectMapToSend,body,peoplePrefList, isReplyLike, localisationCountsMap);
    	}catch(Exception ex) {
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
			Utility.sendExceptionEmail('BatchCheckAccessAndSendNotification', exceptionDetailsObj);
		}
    }
}