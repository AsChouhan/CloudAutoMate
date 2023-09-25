public with sharing class BatchNewHireGraduatedNotification implements Database.Batchable<sObject>, Database.Stateful{

	private String batchType;
    private Exception exceptionDetailsObj;
	
    private static final String BATCH_NEW_HIRE_NOTIFICATION = 'newHireNotification';
    private static final String BATCH_MOVE_TO_FAVORITES = 'moveOnboardingToFavorites';

    public BatchNewHireGraduatedNotification(String batchType) {
        this.batchType = batchType;
    }

    public database.querylocator start(Database.BatchableContext bc){
       	Date joiningDate = Date.today().addDays(-30);
        String query =  'SELECT Id FROM People__c WHERE Joining_Date__c = :joiningDate AND Is_Deleted__c = false';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, sObject[] listOfsObject){
    	try {
            if(BATCH_NEW_HIRE_NOTIFICATION.equals(this.batchType)) {
                List<People__c> listOfGradutedPeople = (List<People__c>) listOfsObject;
                List<App_Notification__c> listOfNewNotifications = new List<App_Notification__c>();
                for(People__c peopleObj : listOfGradutedPeople) {
                    App_Notification__c notificationObject = new App_Notification__c();
                    notificationObject.Object_Id__c = peopleObj.Id;
                    notificationObject.Object_Type__c = 'NewHireGraduated';
                    notificationObject.Status__c = 'Pending';
                    notificationObject.Type__c = 'Information';
                    notificationObject.Sub_Type__c = 'New Hire Graduated';
                    notificationObject.Is_Read__c = false;
                    notificationObject.Is_New__c = true;
                    notificationObject.Sent_to__c = peopleObj.Id;
                    notificationObject.Created_DateTime__c = DateTime.now();
                    notificationObject.Category__c = 'New_Hire_Graduated';
                    listOfNewNotifications.add(notificationObject);
                }
                NotificationDao.createNotifications(listOfNewNotifications);
            } 
            else if(BATCH_MOVE_TO_FAVORITES.equals(this.batchType)) {
                List<People__c> listOfGradutedPeople = (List<People__c>) listOfsObject;
				moveOnboardingToFavorites(listOfGradutedPeople);
			}
            
	    } catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
	private void moveOnboardingToFavorites(List<People__c> listOfGradutedPeople){
		Set<Id> peopleIds = new Set<Id>();
        for(People__c peopleObj:listOfGradutedPeople) {
            peopleIds.add(peopleObj.id);
        }
		List<Site_Role__c> siteRoleList = [SELECT Id, People__c, Site__c FROM Site_Role__c WHERE People__c IN :peopleIds AND Is_Deleted__c = false AND Site__r.Is_Deleted__c = false AND Site__r.Is_Active__c=true];
        Map<Id, Set<Id>> peopleSiteListMap = new Map<Id, Set<Id>>();
        Set<Id> siteIds = new Set<Id>();
        for(Site_Role__c role:siteRoleList) {
            Set<Id> temp = peopleSiteListMap.get(role.People__c);
            if(temp == null) {
                temp = new Set<Id>();
            }
            temp.add(role.Site__c);
            peopleSiteListMap.put(role.People__c, temp);
            siteIds.add(role.Site__c);
        }

        String orgOnboarding = ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING;
        String siteOnboarding = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING;
        List<String> onboardingStatus = new List<String> {orgOnboarding, ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING};
        String contentQuery =   'SELECT Id, Type__c, Site__c, Title__c, CreatedById FROM Simpplr_Content__c WHERE Site__c IN :siteIds ' +
                                'AND Content_Onboarding_Status__c = :siteOnboarding AND Is_Deleted__c = false  AND Is_Published__c = true';

        String orgcontentQuery = 'SELECT Id, Type__c, Site__c, Title__c, CreatedById FROM Simpplr_Content__c WHERE ' +
                                'Content_Onboarding_Status__c = :orgOnboarding AND Is_Deleted__c = false  AND Is_Published__c = true';

        List<Simpplr_Content__c> contentList = (List<Simpplr_Content__c>) Database.query(contentQuery);
        List<Simpplr_Content__c> orgcontentList = (List<Simpplr_Content__c>) Database.query(orgcontentQuery);
        contentList.addAll(orgcontentList);

        for(People__c peopleObj:listOfGradutedPeople) {
            for(Simpplr_Content__c org : orgcontentList) {
                Set<Id> temp = peopleSiteListMap.get(peopleObj.Id);
                    if(temp == null) {
                        temp = new Set<Id>();
                    }
                temp.add(org.Site__c);
                peopleSiteListMap.put(peopleObj.Id, temp);
                siteIds.add(org.Site__c);
            }
        }
        
        Map<Id, List<Simpplr_Content__c>> siteContentMap = new Map<Id, List<Simpplr_Content__c>>();
        Set<String> contentTypes = new Set<String>();
        Set<String> contentIds = new Set<String>();
        Set<String> userIds = new Set<String>();
        for(Simpplr_Content__c content:contentList) {
            List<Simpplr_Content__c> temp = siteContentMap.get(content.Site__c);
            if(temp == null) {
                temp = new List<Simpplr_Content__c>();
            }
            temp.add(content);
            siteContentMap.put(content.Site__c, temp);
            contentTypes.add(content.Type__c);
            contentIds.add(content.Id);
            userIds.add(content.CreatedById);
        }
	
        Map<Id, List<Simpplr_Content__c>> peopleContentMap = new Map<Id, List<Simpplr_Content__c>>();
        for(Id peopleId:peopleSiteListMap.keySet()) {
            siteIds = peopleSiteListMap.get(peopleId);
            List<Simpplr_Content__c> peopleContentTempList = peopleContentMap.get(peopleId);
            if(peopleContentTempList == null) {
                peopleContentTempList = new List<Simpplr_Content__c>();
            }
            for(Id siteId:siteIds) {
                List<Simpplr_Content__c> siteContentList = siteContentMap.get(siteId);
                if(siteContentList == null) {
                    siteContentList = new List<Simpplr_Content__c>();
                }
                peopleContentTempList.addAll(siteContentList);
            }
            peopleContentMap.put(peopleId, peopleContentTempList);
        }
        

        //*** User People Map */
        Map<String, People__c> peopleMap = new Map<String, People__c>([SELECT Id, User__c FROM People__c WHERE User__c IN :userIds]);
		Map<String, String> peopleUserMap = new Map<String, String>();
        for(People__c ppl:peopleMap.values()) {
            peopleUserMap.put(ppl.User__c, ppl.Id);
        }

        //** Check for exisiting bookmarks */
        Set<Id> contentToExclude = new Set<Id>();
        List<Bookmark__c> listOfFavorite = [SELECT  Id, Name, Type__c, People__c, Bookmark_Receiver__c, Simpplr_Content__c, Simpplr_Content__r.CreatedById , Simpplr_Content__r.Title__c 
                                            FROM    Bookmark__c 
                                            WHERE   People__c IN :peopleContentMap.keySet()
                                            AND     Type__c IN :contentTypes AND Simpplr_Content__c IN :contentIds 
                                            AND     Is_Deleted__c = true];
        for(Bookmark__c bookmarkObj:listOfFavorite) {
            String peopleIdArg = peopleUserMap.get(bookmarkObj.Simpplr_Content__r.CreatedById);
            String bookmarkName = bookmarkObj.Simpplr_Content__r.Title__c.length() > 80 ? bookmarkObj.Simpplr_Content__r.Title__c.subString(0,80) : bookmarkObj.Simpplr_Content__r.Title__c;
            bookmarkObj.Name = bookmarkName;
            bookmarkObj.Bookmark_Receiver__c = peopleIdArg;
            bookmarkObj.Is_Deleted__c = false;
            contentToExclude.add(bookmarkObj.Simpplr_Content__c);
        }

        if(listOfFavorite.isEmpty() == false){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Bookmark__c>(listOfFavorite), new List<Schema.SObjectField>{
                                                                    Bookmark__c.Name,
                                                                    Bookmark__c.Bookmark_Receiver__c,
                                                                    Bookmark__c.Is_Deleted__c
                                                                });
        }

        List<AggregateResult> myReadDetails = [SELECT People__c p, COUNT(Content__c) content FROM Content_Interaction__c WHERE People__c IN :peopleIds AND View_Count__c > 0 AND Content__r.Content_Onboarding_Status__c IN :onboardingStatus AND (Content__r.Site__c IN :siteIds OR (Content__r.Site__r.Site_Type__c = 'Public' AND Content__r.Content_Onboarding_Status__c =: orgOnboarding)) GROUP BY People__c];
        Map<Object,Integer> userReadDetails = new Map<Object,Integer>();
        for(AggregateResult ci : myReadDetails) {
            userReadDetails.put(ci.get(String.valueOf('p')), (Integer)ci.get(String.valueOf('content')));
        }
        
        //** Create new bookmarks */
        listOfFavorite = new List<Bookmark__c>();
        for(Id peopleId:peopleContentMap.keySet()) {
           List<Simpplr_Content__c> conList = peopleContentMap.get(peopleId);
            if(conList != null){
				for(Simpplr_Content__c con : conList){
					if(con!=null && !contentToExclude.contains(con.Id)){
						Bookmark__c  favouriteObj = new Bookmark__c();
						favouriteObj.Simpplr_Site__c = con.Site__c;
						favouriteObj.Simpplr_Content__c = con.Id;
						favouriteObj.People__c = peopleId;
						favouriteObj.Name = con.Title__c.length() > 80 ? con.Title__c.subString(0,80) : con.Title__c;
						favouriteObj.Type__c = con.Type__c;
						favouriteObj.Is_Deleted__c = false;
						favouriteObj.Bookmark_Receiver__c = peopleUserMap.get(con.CreatedById);
						listOfFavorite.add(favouriteObj);
					}
                }
                if(userReadDetails.get(peopleId)==conList.size()){
                    List<People__c> peopleList = [SELECT Id, Has_Read_All_Onboarding_Content__c from People__c WHERE id=:peopleId];
                    peopleList[0].Has_Read_All_Onboarding_Content__c=true;

                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                    SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(peopleList), new List<Schema.SObjectField>{
                                                                            People__c.Has_Read_All_Onboarding_Content__c
                                                                        });
                }
			}
        }

        if(listOfFavorite.isEmpty() == false){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(listOfFavorite, new List<Schema.SObjectField> { 
                Bookmark__c.Simpplr_Site__c,
                Bookmark__c.Simpplr_Content__c,
                Bookmark__c.People__c,
                Bookmark__c.Name,
                Bookmark__c.Type__c,
                Bookmark__c.Is_Deleted__c,
                Bookmark__c.Bookmark_Receiver__c});
        }

    }

	public void finish(Database.BatchableContext bc){
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
            canStartNextBatch=true;
		} else {
            Utility.sendExceptionEmail('BatchNewHireGraduatedNotification', exceptionDetailsObj);
        }
		if(canStartNextBatch) {
			if(BATCH_NEW_HIRE_NOTIFICATION.equalsIgnoreCase(batchType)){
				BatchNewHireGraduatedNotification job = new BatchNewHireGraduatedNotification(BATCH_MOVE_TO_FAVORITES);
				Database.executeBatch(job, 1);
			} else if(BATCH_MOVE_TO_FAVORITES.equalsIgnoreCase(batchType)){
				Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
				String dayOfWeek = dt.format('EEEE');
				String startOfWeek = SimpplrContext.StartOfWeek != null ? SimpplrContext.StartOfWeek : 'Monday';
				if (dayOfWeek.startsWithIgnoreCase(startOfWeek)) {
			    	Database.executeBatch(new BatchContentOnboardingEmailDigest(), 50);
            	}
			}
		}
	}

}