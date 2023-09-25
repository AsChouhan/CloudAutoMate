public with sharing class BatchAnalyticsNotifications implements Database.Batchable<sObject>, Database.Stateful{
	
	private String batchContext;
	private Exception exceptionDetailsObj;
	private String packageName;
	public Map<String,Set<String>> peopleToSitesHeManageMap;
	public Map<String,String>siteIdToChatterGroupMap;
	
	public BatchAnalyticsNotifications(String batchContext) { 
		this.packageName = SimpplrContext.packageName;
		this.batchContext = batchContext;
		this.peopleToSitesHeManageMap = populatePeopleToSitesHeManageMap();
	}
	
	public database.querylocator start(Database.BatchableContext bc) {
		Set<String> siteManagersSet = peopleToSitesHeManageMap.keySet();
		String queryString = '';
    			
		if('AppManagerAnalytics'.equalsIgnoreCase(batchContext)) {
			queryString = 'SELECT Id, User__c FROM People__c WHERE (App_Moderation_Permission__c = \'Yes\' OR Can_Access_Analytics__c = True) ';

		} else if('SiteManagerAnalytics'.equalsIgnoreCase(batchContext)) {
			queryString = 'SELECT Id, User__c FROM People__c WHERE App_Moderation_Permission__c = \'No\' AND '+
    			'Can_Access_Analytics__c = false AND User__c IN : siteManagersSet ';
			
		} else if('ContentAuthorAnalytics'.equalsIgnoreCase(batchContext)) {
			queryString = 'SELECT id, User__c FROM People__c WHERE Id in (SELECT primary_author__c FROM simpplr_content__c '+
					'WHERE is_Published__c=true and is_Deleted__c=false) AND Id NOT IN : siteManagersSet AND '+
					'App_Moderation_Permission__c = \'No\' AND Can_Access_Analytics__c = false ';
			
		}
		queryString += ' AND User__r.isActive=true AND User__r.UserType=\'Standard\' ';
		
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
    		queryString += ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
    	}
    	return Database.getQueryLocator(queryString);	
	}
	public void execute(Database.BatchableContext bc, List<People__c> peopleList) {
		
	 	if('AppManagerAnalytics'.equalsIgnoreCase(batchContext)) {
	 		Integer allUserCount = getAllUserCount();
    		String usersLoggedInPercentage = getUsersLoggedInPercentage(allUserCount);
			generateAppManagerAnalyticsNotification(peopleList,usersLoggedInPercentage);
			
		} else if('SiteManagerAnalytics'.equalsIgnoreCase(batchContext)) {
			
			generateSiteManagerAnalyticsNotification(peopleList);
			
		} else if('ContentAuthorAnalytics'.equalsIgnoreCase(batchContext)) {
			
			generateContentAuthorAnalyticsNotification(peopleList);
			
		}
	 }
	 
	 private void generateAppManagerAnalyticsNotification(List<People__c> peopleList, String usersLoggedInPercentage) {
    	List<App_Notification__c> notiListToInsert = new List<App_Notification__c>();
    	String currentUserId = UserContext.id;
    	String baseUrl = Url.getSalesforceBaseUrl().toExternalForm(); 
    	String guid= currentUserId + '-' + System.currentTimeMillis(); 
    	
    	for(People__c people : peopleList) {
    		
    		App_Notification__c notificationObj = new App_Notification__c();
    		notificationObj.GUID__c = guid;
			notificationObj.Category__c = 'Last_Month_App_Analytics';
			notificationObj.snippet__c = usersLoggedInPercentage;
			notificationObj.Type__c = 'Information';
			notificationObj.Sub_Type__c = 'App Analytics';
			notificationObj.Status__c = 'Pending';
			notificationObj.Sent_To__c = people.Id;
			notificationObj.Created_DateTime__c = DateTime.now();
			notificationObj.Is_New__c = true;
			notificationObj.Is_Read__c = false;
			
    		notiListToInsert.add(notificationObj);
    	}
		
		if(notiListToInsert.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(notiListToInsert, new List<Schema.SObjectField>{
					App_Notification__c.GUID__c,
					App_Notification__c.Category__c,
					App_Notification__c.snippet__c,
					App_Notification__c.Type__c,
					App_Notification__c.Sub_Type__c,
					App_Notification__c.Status__c,
					App_Notification__c.Sent_To__c,
					App_Notification__c.Created_DateTime__c,
					App_Notification__c.Is_New__c,
					App_Notification__c.Is_Read__c
				}); 
		}
	 }
	 
	 private void generateSiteManagerAnalyticsNotification(List<People__c> peopleList) {
	 	List<App_Notification__c> notiListToInsert = new List<App_Notification__c>();
    	String currentUserId = UserContext.id;
    	String baseUrl = Url.getSalesforceBaseUrl().toExternalForm(); 
    	String guid= currentUserId + '-' + System.currentTimeMillis(); 
    	
    	for(People__c people : peopleList) {
    		List<AggregateResult> topSitesForUserList = getTopSitesForUserList(people.user__c);
			String siteId = '';
			String siteName = '';
			
			for (AggregateResult siteObj : topSitesForUserList) {
				siteId = String.valueOf(siteObj.get('site'));
				siteName = String.valueOf(siteObj.get('siteName'));
			}
    		
    		if(String.isNotBlank(siteId)) {
	    		App_Notification__c notificationObj = new App_Notification__c();
	    		notificationObj.GUID__c = guid;
				notificationObj.Object_Id__c = siteId;
				notificationObj.Simpplr_Site__c = siteId;
				notificationObj.Object_Type__c = 'site';
				notificationObj.Category__c = 'Last_Month_Site_Analytics';
				notificationObj.Type__c = 'Information';
				notificationObj.Sub_Type__c = 'Site Analytics';
				notificationObj.Status__c = 'Pending';
				notificationObj.Sent_To__c = people.Id;
				notificationObj.Created_DateTime__c = DateTime.now();
				notificationObj.Is_New__c = true;
				notificationObj.Is_Read__c = false;
	    		notiListToInsert.add(notificationObj);
    		}
    	}	

		if(notiListToInsert.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(notiListToInsert, new List<Schema.SObjectField>{
					App_Notification__c.GUID__c,
					App_Notification__c.Object_Id__c,
					App_Notification__c.Simpplr_Site__c,
					App_Notification__c.Object_Type__c,
					App_Notification__c.Category__c,
					App_Notification__c.snippet__c,
					App_Notification__c.Type__c,
					App_Notification__c.Sub_Type__c,
					App_Notification__c.Status__c,
					App_Notification__c.Sent_To__c,
					App_Notification__c.Created_DateTime__c,
					App_Notification__c.Is_New__c,
					App_Notification__c.Is_Read__c
				});
		}
	 }
	 
	 private void generateContentAuthorAnalyticsNotification(List<People__c> peopleList) {
	 	List<App_Notification__c> notiListToInsert = new List<App_Notification__c>();
    	String currentUserId = UserContext.id;
    	String baseUrl = Url.getSalesforceBaseUrl().toExternalForm(); 
    	String guid= currentUserId + '-' + System.currentTimeMillis(); 
    	
    	for(People__c people : peopleList) {
    		
    		List<AggregateResult> topContentForUserList = getTopContentForUserList(people.Id);
			String contentId = '';
			String contentTitle = '';
			String contentType = '';
			
			for (AggregateResult contentObj : topContentForUserList) {
				contentId = String.valueOf(contentObj.get('contentId'));
				contentTitle = String.valueOf(contentObj.get('contentTitle'));
				contentType = String.valueOf(contentObj.get('contentType'));
			}
    		
    		if(String.isNotBlank(contentId)) {
	    		App_Notification__c notificationObj = new App_Notification__c();
	    		notificationObj.GUID__c = guid;
				notificationObj.Object_Id__c = contentId;
				notificationObj.Object_Type__c = contentType;
				notificationObj.Category__c = 'Last_Month_Content_Analytics';
				notificationObj.Snippet__c = Utility.chompString(contentTitle,255);
				notificationObj.Type__c = 'Information';
				notificationObj.Sub_Type__c = 'Content Analytics';
				notificationObj.Status__c = 'Pending';
				notificationObj.Sent_To__c = people.Id;
				notificationObj.Created_DateTime__c = DateTime.now();
				notificationObj.Is_New__c = true;
				notificationObj.Is_Read__c = false;
				
	    		notiListToInsert.add(notificationObj);
    		}
    	}
		
		if(notiListToInsert.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(notiListToInsert, new List<Schema.SObjectField>{
					App_Notification__c.GUID__c,
					App_Notification__c.Object_Id__c,
					App_Notification__c.Object_Type__c,
					App_Notification__c.Category__c,
					App_Notification__c.snippet__c,
					App_Notification__c.Type__c,
					App_Notification__c.Sub_Type__c,
					App_Notification__c.Status__c,
					App_Notification__c.Sent_To__c,
					App_Notification__c.Created_DateTime__c,
					App_Notification__c.Is_New__c,
					App_Notification__c.Is_Read__c
				});
		}
	 }
	 
	 public void finish(Database.BatchableContext bc){
		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
				CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = true;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
		} else {
			Utility.sendBatchFailedExceptionEmail('BatchAnalyticsNotifications.' + batchContext, exceptionDetailsObj);
		}
		
	    if(canStartNextBatch) {
			if('AppManagerAnalytics'.equalsIgnoreCase(batchContext)) {
				BatchAnalyticsNotifications job = new BatchAnalyticsNotifications('SiteManagerAnalytics');
	  			Database.executeBatch(job,10);
			
			} else if('SiteManagerAnalytics'.equalsIgnoreCase(batchContext)) {
				BatchAnalyticsNotifications job = new BatchAnalyticsNotifications('ContentAuthorAnalytics');
	  			Database.executeBatch(job,10);
				
	  		} else if('ContentAuthorAnalytics'.equalsIgnoreCase(batchContext)) {
	  			BatchAdoptionEmail adoptionEmailBatch = new BatchAdoptionEmail('sendMonthlyAdoptionEmail');
    			Database.executeBatch(adoptionEmailBatch,20);
	  		}
		}
    }
    
    private Map<String,Set<String>> populatePeopleToSitesHeManageMap() {
    	Set<String> showInSimpplrChatterGroupSet = getActiveChatterGroups();
		Map<String,Set<String>> peopleToSitesHeManageMap = new Map<String,Set<String>>();
		
		for (CollaborationGroupMember collabGrpMember : [SELECT MemberId,CollaborationGroupId FROM 
				CollaborationGroupMember WHERE CollaborationRole='Admin' AND CollaborationGroupId IN : 
				showInSimpplrChatterGroupSet]){
			
			if (!peopleToSitesHeManageMap.containsKey(collabGrpMember.MemberId)) {
				peopleToSitesHeManageMap.put(collabGrpMember.MemberId,new Set<String>());
			}
			Set<String> tempSet = peopleToSitesHeManageMap.get(collabGrpMember.MemberId);
			tempSet.add(collabGrpMember.CollaborationGroupId);
			peopleToSitesHeManageMap.put(collabGrpMember.MemberId,tempSet);
		}
		return peopleToSitesHeManageMap;
    }
    
    private Integer getAllUserCount(){
		AggregateResult groupedResults = [SELECT MAX(Total_Simpplr_Users__c) totalUsers from Analytics_Login__c WHERE Date__c=LAST_MONTH];  
		Integer allUserCount = Integer.valueOf(groupedResults.get('totalUsers')); 
		return  allUserCount; 		   	
    }
    
    private String getUsersLoggedInPercentage(Integer allUserCount){
    	Long usersLoggedInPercentage = 0;
    	String queryString = 'SELECT count() FROM People__c WHERE Id IN (SELECT People__c FROM Analytics_Adoption__c where Date__c = LAST_MONTH) ';

    	Integer loginCount = Database.countQuery(queryString);

    	if(allUserCount !=null && allUserCount > 0) {
			if(loginCount > allUserCount){  //Upper Check for Adoption Percentage 
				allUserCount = loginCount; 
			}
			Decimal usersLoggedIn = ((loginCount * 100.0)/allUserCount).setScale(2);
			usersLoggedInPercentage = usersLoggedIn.round(System.RoundingMode.HALF_UP);
    	}
    	
    	return String.valueOf(usersLoggedInPercentage);
    }
    
    private List<AggregateResult> getTopSitesForUserList(String userId){
    	List<AggregateResult> topSitesForUserList = new List<AggregateResult>();
    	Set<String> sitesThisUserManagesSet = peopleToSitesHeManageMap.get(userId);
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', sitesThisUserManagesSet);
		String qStr = 'SELECT Site__c site,Site__r.Site_Type__c siteType, ' +
				'Site__r.name siteName, SUM(Popularity_Score__c) popularity FROM Analytics_Top_Site__c WHERE ' +
				'Site__r.Chatter_Group_Id__c IN : soqlParam1 AND Date__c = LAST_MONTH ' + 
				'GROUP BY Site__c,Site__r.Site_Type__c, Site__r.name '+
				'ORDER BY SUM(Popularity_Score__c) DESC LIMIT 1'; 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		topSitesForUserList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(qStr, soqlParamMap);
    	return 	topSitesForUserList;		
    }
    
    private List<AggregateResult> getTopContentForUserList(String peopleId){
    	List<AggregateResult> topContentForUserList = new List<AggregateResult>();
		
		String qStr = 'SELECT Content__c contentId, Content__r.Title__c contentTitle, ' +
					' Content__r.Type__c contentType, SUM(Popularity_Score__c) popularity '+ 
					' FROM Analytics_Top_Content__c WHERE ' +
					' Content__r.primary_author__c  =: peopleId AND Date__c = LAST_MONTH ' + 
					' GROUP BY Content__c,Content__r.Title__c,Content__r.Type__c ' + 
					' ORDER BY SUM(Popularity_Score__c) DESC LIMIT 1';
    	
    	topContentForUserList = Database.query(qStr);
		return 	topContentForUserList;		
    }
    
    private Set<String> getActiveChatterGroups() {
		Set<String> activeChatterGroups = new Set<String>();
		
		for (Simpplr_Site__c siteObj : [SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c WHERE 
				Is_Active__c = true AND Show_In_Simpplr__c = true]) {
			activeChatterGroups.add(siteObj.Chatter_Group_Id__c);
		}
		return activeChatterGroups;	
    }	
	
}