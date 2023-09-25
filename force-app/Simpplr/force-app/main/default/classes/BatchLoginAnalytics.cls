/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchLoginAnalytics implements Database.Batchable<SObject>, Database.Stateful {
	Analytics_Login__c loginObj;
	Integer desktopCount = 0;
	Integer desktopAppCount = 0;
	Integer mobileCount = 0;
	Integer mobileAppCount = 0;
	Integer pageViewCount = 0;
	Decimal uniqueLogInCount = 0;
	Decimal totalLoginsCount = 0;
	Integer NativeIOSApp = 0;
	Integer NativeAndroidApp = 0;
	Integer HybridIOSApp = 0;
	Integer HybridAndroidApp = 0;
	
	Integer likesCount = 0;
	Integer postsCount = 0;
	Integer repliesCount = 0;
	Integer sharesCount = 0;
	Integer contentViewCount = 0;

	Date startDate ;
	Date endDate ;
	DateTime startDateTime;
	DateTime endDateTime;
	Set<String> loggedInPeopleSet = new Set<String>(); 
	
	public BatchLoginAnalytics(Date batchDate){
		startDate = batchDate;
		endDate = batchDate.addDays(1);
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Database.QueryLocator start(Database.BatchableContext BC){
        loginObj = new Analytics_Login__c();
        loginObj.Date__c = startDate;
    	loginObj.Average_logins_per_user__c = 0;
    	loginObj.Desktop__c = 0;
    	loginObj.DesktopApp__c = 0;
    	loginObj.Mobile__c = 0;
    	loginObj.MobileApp__c = 0;
    	loginObj.Page_Views__c = 0;
		loginObj.Content_Views__c = 0;
    	loginObj.Unique_logins__c = 0;
    	loginObj.Total_Logins__c = 0;
    	loginObj.Total_Simpplr_Users__c = 0;
    	loginObj.Users_logged_in__c = 0;
    	
        return Database.getQueryLocator('SELECT Id, Date__c, Is_Active__c,Has_Used_Native_IOS_App__c,Has_Used_Native_Android_App__c, Has_Used_Hybrid_IOS_App__c, Has_Used_Hybrid_Android_App__c, Is_Contributor__c, Is_Observer__c, Is_Participant__c, Page_Views__c, Content_Views__c, Desktop__c, DesktopApp__c, Mobile__c, MobileApp__c, People__c, User__c,Total_Logins__c FROM Analytics_Adoption__c where Date__c =: startDate');
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void execute(Database.BatchableContext BC, List<sObject> listOfsObject){
		try{
			
			Set<String> peopleIdSet = new Set<String>();
			for(Analytics_Adoption__c adoptionObj : (List<Analytics_Adoption__c>)listOfsObject){
				if(loggedInPeopleSet.contains(adoptionObj.People__c) == false) {
					desktopCount +=  adoptionObj.Desktop__c.intValue();
					desktopAppCount += adoptionObj.DesktopApp__c.intValue();
					mobileCount += adoptionObj.Mobile__c.intValue();
					mobileAppCount += adoptionObj.MobileApp__c.intValue();
					pageViewCount += adoptionObj.Page_Views__c.intValue();
					contentViewCount += adoptionObj.Content_Views__c.intValue();
					uniqueLogInCount += 1;
					totalLoginsCount += adoptionObj.Total_Logins__c.intValue();
					
					if(adoptionObj.Has_Used_Native_IOS_App__c){
					NativeIOSApp++;
					}
					if(adoptionObj.Has_Used_Native_Android_App__c){
					NativeAndroidApp++;
					}
					if(adoptionObj.Has_Used_Hybrid_IOS_App__c){
					HybridIOSApp++;
					}
					  
					if(adoptionObj.Has_Used_Hybrid_Android_App__c){
					HybridAndroidApp++;
					}
					peopleIdSet.add(adoptionObj.People__c);
					loggedInPeopleSet.add(adoptionObj.People__c);
				}
			}
			
			if(!peopleIdSet.isEmpty()) { 
				List<Analytics_Top_People__c> analyticsTopPeopleList = [SELECT Id, Likes_Made__c, Posts__c, Replies_Made__c, Shares_Made__c
																		 FROM Analytics_Top_People__c WHERE People__c IN :peopleIdSet AND Date__c >= :startDate AND Date__c < :endDate];
				for(Analytics_Top_People__c analyticsTopPeople : analyticsTopPeopleList){
					likesCount += analyticsTopPeople.Likes_Made__c.intValue();
					postsCount += analyticsTopPeople.Posts__c.intValue();
					repliesCount += analyticsTopPeople.Replies_Made__c.intValue();
					sharesCount += analyticsTopPeople.Shares_Made__c.intValue();	
				}
				
			}
						
		} catch(Exception ex) {
			Utility.sendBatchFailedExceptionEmail('BatchLoginAnalytics', ex);
		}
    } 
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void finish(Database.BatchableContext BC){
    	try {
    		saveBatchData();
    		
    	} catch(Exception ex) {
			Utility.sendBatchFailedExceptionEmail('BatchLoginAnalytics', ex);
		}
    	
    		BatchSaleforceActiveUserAnalytics job = new BatchSaleforceActiveUserAnalytics('initAnalyticsData', startDate);
	    Database.executeBatch(job, 2000);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void saveBatchData() {
    	try {
	    	List<People__c> peopleList = new List<People__c>();
	    	if(!Test.isRunningTest() && String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false){
	    		peopleList = [select id,user__c from People__c where User__r.isActive = true and createddate < :enddatetime and user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: SimpplrContext.packageName and createddate < :enddatetime)];
	    	} else {
	    		peopleList = [select id,user__c from People__c where User__r.isActive = true and User__r.UserType='Standard' and createddate < :enddatetime];
	    	}
	    	
	    	loginObj.Desktop__c = desktopCount;
	    	loginObj.DesktopApp__c = desktopAppCount;
	    	loginObj.Mobile__c = mobileCount;
	    	loginObj.MobileApp__c = mobileAppCount;
	    	loginObj.Page_Views__c = pageViewCount;
			loginObj.Content_Views__c = contentViewCount;
	    	loginObj.Unique_logins__c = uniqueLogInCount;
	    	loginObj.Total_Logins__c = totalLoginsCount;
	    	loginObj.Total_Simpplr_Users__c = peopleList.size();
	    	if(loginObj.Total_Simpplr_Users__c < loginObj.Unique_logins__c) {
	    		loginObj.Total_Simpplr_Users__c = loginObj.Unique_logins__c;
	    	}
	    	if(uniqueLogInCount > 0){
	    		loginObj.Average_logins_per_user__c = (totalLoginsCount/uniqueLogInCount).setScale(2);
	    	}
	    	if(peopleList.size()>0) {
	    		
	    		loginObj.Users_logged_in__c = uniqueLogInCount/peopleList.size();
	    	}
	    	loginObj.Native_IOS_App__c = NativeIOSApp;
	    	loginObj.Native_Android_App__c = NativeAndroidApp;
	    	loginObj.Hybrid_IOS_App__c = HybridIOSApp;
	    	loginObj.Hybrid_Android_App__c = HybridAndroidApp;
	    	
	    	loginObj.Likes__c = likesCount;
	    	loginObj.Posts__c = postsCount; 
	    	loginObj.Replies__c = repliesCount;
	    	loginObj.Shares__c = sharesCount;
	    	

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(loginObj, new List<Schema.SObjectField> { 
				Analytics_Login__c.Date__c,
				Analytics_Login__c.Average_logins_per_user__c,
				Analytics_Login__c.Desktop__c,
				Analytics_Login__c.DesktopApp__c,
				Analytics_Login__c.Mobile__c,
				Analytics_Login__c.MobileApp__c,
				Analytics_Login__c.Page_Views__c,
				Analytics_Login__c.Content_Views__c,
				Analytics_Login__c.Unique_logins__c,
				Analytics_Login__c.Total_Logins__c,
				Analytics_Login__c.Total_Simpplr_Users__c,
				Analytics_Login__c.Users_logged_in__c,
				Analytics_Login__c.Native_IOS_App__c,
				Analytics_Login__c.Native_Android_App__c,
				Analytics_Login__c.Hybrid_IOS_App__c,
				Analytics_Login__c.Hybrid_Android_App__c,
				Analytics_Login__c.Likes__c,
				Analytics_Login__c.Posts__c,
				Analytics_Login__c.Replies__c,
				Analytics_Login__c.Shares__c
			});
	    	
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchLoginAnalytics', ex);
    	}
    }
}