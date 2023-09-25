/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AnalyticsDao{
	
	private final String INTERACTION_VIEW = 'View';
	private Integer recordLimit = 10;
	private Date fDate;
	private Date tDate;
	private String sId;
	private Integer counter;
	private Boolean hasFullAccess{get{
		if(hasFullAccess == null){
			hasFullAccess = UserContext.canAccessAnalytics || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission;
		}
		return hasFullAccess;
	}set;
	}
	
	private set<Date> getdateSetWhenBatchRuns(Date fDate, Date tDate){
		set<Date> dateSet = new set<Date>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		String query = 'select id , Date__c from Analytics_Login__c where Date__c >= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Login__c> analyticsLoginList = (List<Analytics_Login__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(Analytics_Login__c loginObj : analyticsLoginList){
			dateSet.add(loginObj.Date__c);
		}
		return dateSet;
	
	}
	
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void pushViewData(Map<String, String> mapOfParams) {
    	Simpplr_Social_Analytics__c ssa = new Simpplr_Social_Analytics__c();
    	ssa.User__c = UserContext.id;
    	ssa.Interaction__c = INTERACTION_VIEW;
    	
    	String userAgent = mapOfParams.get('userAgent');
    	
    	if(String.isNotBlank(userAgent)) {
    		ssa.User_Agent__c = userAgent.trim().left(255);
    		if(userAgent.containsIgnoreCase('Desktop App')) {
    			ssa.Origin_Desktop_App__c = true;	
    			ssa.Origin_Mobile_App__c = false;
    			ssa.Origin_Mobile_Browser__c  = false;
    			ssa.Origin_Native_Mobile_App__c = false;
    		} else if(userAgent.containsIgnoreCase('Native Mobile App')) {
    			ssa.Origin_Native_Mobile_App__c = true;
    			ssa.Origin_Desktop_App__c = false;
    			ssa.Origin_Mobile_App__c = false;
    			ssa.Origin_Mobile_Browser__c  = false;
    		} else if(userAgent.containsIgnoreCase('Mobile App')) {
    			ssa.Origin_Native_Mobile_App__c = false;
    			ssa.Origin_Desktop_App__c = false;
    			ssa.Origin_Mobile_App__c = true;
    			ssa.Origin_Mobile_Browser__c  = false;
    		} else if(userAgent.containsIgnoreCase('Windows Phone') || userAgent.containsIgnoreCase('iPhone')  
    					 || userAgent.containsIgnoreCase('iPad') || userAgent.containsIgnoreCase('Android') || userAgent.containsIgnoreCase('SymbianOS')
    					 ||  userAgent.containsIgnoreCase('BlackBerry')){
    			ssa.Origin_Native_Mobile_App__c = false;
    			ssa.Origin_Desktop_App__c = false;
    			ssa.Origin_Mobile_App__c = false;
    			ssa.Origin_Mobile_Browser__c  = true;
    		} else {
    			ssa.Origin_Native_Mobile_App__c = false;
    			ssa.Origin_Desktop_App__c = false;
    			ssa.Origin_Mobile_App__c = false;
    			ssa.Origin_Mobile_Browser__c  = false;
    		}
    		
    		if(userAgent.containsIgnoreCase('iOS')){
			ssa.Origin_Device_Type__c = 'iOS';
		
		}else if (userAgent.containsIgnoreCase('Android')){
			ssa.Origin_Device_Type__c = 'Android';
		
		}
    	}
	
		ssa.UTM_Source__c = mapOfParams.get('utm_source');
		ssa.UTM_Medium__c = mapOfParams.get('utm_medium');
		ssa.UTM_Content__c = mapOfParams.get('utm_content');
		ssa.UTM_term__c = mapOfParams.get('utm_term');
		ssa.Page_Analytics_Category__c = mapOfParams.get('pageCategory');
		ssa.Page_Group__c = mapOfParams.get('pageGroup');

		String fileId = mapOfParams.get('fileId');
    	if(String.isNotBlank(fileId)) {
    		ssa.File_Id__c = fileId;
    	}
	
    	String pageURL = mapOfParams.get('pageURL');
    	if(String.isNotBlank(pageURL)) {
    		ssa.PAGE_URL__c = pageURL.trim().left(255);
    	}
    	
    	String pageName = mapOfParams.get('pageName');
    	if(String.isNotBlank(pageName)) {
    		ssa.Page_Name__c = pageName.replace('Simpplr__','');
		
		} else if(String.isNotBlank(pageURL)) {
			ssa.Page_Name__c = pageURL.substringBefore('?').replace('/apex/','').replace('simpplr__','');
			if(String.isNotBlank(fileId)) {
				ssa.Page_Group__c = 'file_detail';
				ssa.Page_Analytics_Category__c = (String.isBlank(mapOfParams.get('provider')) ? 'intranet' : mapOfParams.get('provider') ) + '_file_detail';
			}
		}
    	
    	String topicId = mapOfParams.get('topicId');
    	if(String.isNotBlank(topicId)) {
    		ssa.Topic_ID__c = topicId;
    	}
    	
    	String contentId = mapOfParams.get('contentId');
    	if(String.isNotBlank(contentId)) {
			ssa.Content__c = contentId;
    	}
    	
    	String peopleId = mapOfParams.get('peopleId');
    	if(String.isNotBlank(peopleId)) {
    		UserDao userDaoObj = new UserDao();
    		ssa.People_Profile__c = peopleId;
    	}
    	
    	String term = mapOfParams.get('term');
    	if(String.isNotBlank(term)) {
    		ssa.Search_Text__c = term;
    	}
	
    	String os = mapOfParams.get('os');
    	if(String.isNotBlank(term)) {
    		ssa.OS__c = os;
    	}
    	
    	String newsletterId = mapOfParams.get('newsletterId');
    	if(String.isNotBlank(newsletterId)) {
    		ssa.Mailer__c = newsletterId;
    	}
    	
    	ssa.People__c = UserContext.peopleId;
    	
    	String siteId = mapOfParams.get('siteId');
    	if(String.isNotBlank(siteId)) {
    		ssa.Simpplr_Site__c = siteId;
    	}
    	
    	
    	String refererURL = mapOfParams.get('refererURL');
    	if(String.isNotBlank(refererURL)) {
    		ssa.Referer__c = refererURL.length() > 255 ? refererURL.substring(0,255):refererURL;	
    	}
    	
    	String linkOrigin = mapOfParams.get('origin');
    	
    	if('ne'.equalsIgnoreCase(linkOrigin)) {
	    	ssa.Origin__c = 'Notification Email';
	    
	} else if('nde'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Notification Digest Email';
    		
    	} else if('pade'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Pending Approval Digest Email';
    		
	} else if('de'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Digest Email';
    	
    	} else if('tse'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Top Stories Email';
    	
    	} else if('nle'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Newsletter Email';
    					
    	} else if('pn'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Push Notification';
    		
    	} else if('ian'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'In App Notification';
    		
    	} else if('dn'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Desktop Notification';
    		
    	} else if('bn'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Browser Notification';
    		
    	} else if('ac'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Search Autocomplete';
    		
    	} else if('gs'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Global Search';
    		
    	} else if('mobile'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Mobile';
    	
    	} else if('cl'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Carousel';
    	
    	} else if('mrr'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Must Read Reminder';
    		
    	} else if('mae'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Monthly Adoption Email';

		} else if('feed'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Feed';

		} else if('rc'.equalsIgnoreCase(linkOrigin)) {
    		ssa.Origin__c = 'Related Content';

    	} else {
    		ssa.Origin__c = 'Application';
    	}
    	if(Test.isRunningTest() == false){
	    	Map<String, String> sessionMap =Auth.SessionManagement.getCurrentSession();
	    	ssa.Login_History_Id__c = sessionMap.get('LoginHistoryId');
    	}
    	
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().insertAsUser(ssa,new List<Schema.SObjectField>{Simpplr_Social_Analytics__c.User__c,
									              Simpplr_Social_Analytics__c.Page_Name__c,
									              Simpplr_Social_Analytics__c.Search_Results_Count__c,
									              Simpplr_Social_Analytics__c.Origin__c,
									              Simpplr_Social_Analytics__c.Page_URL__c,
									              Simpplr_Social_Analytics__c.Interaction__c,
									              Simpplr_Social_Analytics__c.Simpplr_Site__c,
												  Simpplr_Social_Analytics__c.Content__c,
									              Simpplr_Social_Analytics__c.People_Profile__c,
									              Simpplr_Social_Analytics__c.People__c,
									              Simpplr_Social_Analytics__c.File_Id__c,
									              Simpplr_Social_Analytics__c.User_Agent__c,
									              Simpplr_Social_Analytics__c.Topic_ID__c,
									              Simpplr_Social_Analytics__c.Search_Text__c,
									              Simpplr_Social_Analytics__c.Origin_Mobile_Browser__c ,
									              Simpplr_Social_Analytics__c.Origin_Mobile_App__c,
									              Simpplr_Social_Analytics__c.Origin_Desktop_App__c,
									              Simpplr_Social_Analytics__c.Origin_Native_Mobile_App__c,
									              Simpplr_Social_Analytics__c.Origin_Device_Type__c,
									              Simpplr_Social_Analytics__c.Mailer__c,
												  Simpplr_Social_Analytics__c.UTM_Source__c,
												  Simpplr_Social_Analytics__c.UTM_Medium__c,
												  Simpplr_Social_Analytics__c.UTM_Content__c,
												  Simpplr_Social_Analytics__c.UTM_Term__c,
												  Simpplr_Social_Analytics__c.Page_Analytics_Category__c,
												  Simpplr_Social_Analytics__c.Page_Group__c,
									              Simpplr_Social_Analytics__c.Login_History_Id__c,
									              Simpplr_Social_Analytics__c.Referer__c});
		
		if(String.isNotBlank(newsletterId) && 'nle'.equalsIgnoreCase(linkOrigin)) {
			updateAnalyticsForMailer(newsletterId);
		}							              
		if(String.isNotBlank(contentId)) {
			updateViewCountForContent(contentId);
			createPeopleInteraction();
		}	
	}
	
	public void pushAnalyticsFileData(Map<String, String> mapOfParams) {
		Analytics_File__c fileObj = new Analytics_File__c() ;
		fileObj.Action__c = mapOfParams.get('action');
		if(mapOfParams.containsKey('context') && mapOfParams.get('context') !=null){
			fileObj.Context__c = mapOfParams.get('context');
		}
		if(mapOfParams.containsKey('externalUrl')){
			fileObj.External_Url__c = mapOfParams.get('externalUrl');
		}			
		fileObj.File_Extension__c = mapOfParams.get('fileExtension');
		fileObj.File_Url__c  =  mapOfParams.get('fileUrl');	
		if(mapOfParams.containsKey('isFavorited') && mapOfParams.get('isFavorited') !=null){
			fileObj.Is_Bookmarked__c  = Boolean.valueOf( mapOfParams.get('isFavorited'));
		}else{
			fileObj.Is_Bookmarked__c = false;
		}
		if(mapOfParams.containsKey('isNew') && mapOfParams.get('isNew') !=null){
			fileObj.Is_New__c  =  Boolean.valueOf(mapOfParams.get('isNew'));
		}else{
			fileObj.Is_New__c = false ;
		}
		fileObj.Name  =  mapOfParams.get('name');
		fileObj.File_Id__c  =  mapOfParams.get('id');
		fileObj.Owner_Id__c  =  mapOfParams.get('ownerId');
		fileObj.Provider__c = mapOfParams.get('provider');
		if(mapOfParams.containsKey('siteId') && mapOfParams.get('siteId') != null ){
			fileObj.Site_Id__c = mapOfParams.get('siteId');
		}
		fileObj.Size__c = Integer.valueof(mapOfParams.get('size'));
		fileObj.Source__c = mapOfParams.get('source');
		fileObj.Title__c = mapOfParams.get('title');
		fileObj.Type__c = mapOfParams.get('type');
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        SIMPESAPI.accessController().insertAsUser(fileObj,new List<Schema.SObjectField>{Analytics_File__c.Action__c,
									              Analytics_File__c.Context__c,
									              Analytics_File__c.External_Url__c,
									              Analytics_File__c.File_Extension__c,
									              Analytics_File__c.File_Url__c,
												  Analytics_File__c.Is_Bookmarked__c,
									              Analytics_File__c.Is_New__c,
									              Analytics_File__c.Name,
									              Analytics_File__c.Owner_Id__c,
									              Analytics_File__c.Provider__c,
									              Analytics_File__c.Site_Id__c,
									              Analytics_File__c.Size__c,
									              Analytics_File__c.Source__c ,
									              Analytics_File__c.Title__c,									             
												  Analytics_File__c.Type__c,
												  Analytics_File__c.File_Id__c
												 });
		

	}
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private void updateAnalyticsForMailer(String mailerId) {
    	String peopleId = UserContext.peopleId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleId);
		soqlParamMap.put('soqlParam2', mailerId);
		String anlytcsMailerQuery = 'select Id, Click_Count__c from Analytics_Mailer__c ' +
			' where People__c=:soqlParam1 ' +
			' And Mailer__c=:soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Mailer__c> listOfMailerAnalytics = (List<Analytics_Mailer__c>)SIMPESAPI.accessController().queryAsUser(anlytcsMailerQuery, soqlParamMap);
    	if(listOfMailerAnalytics.isEmpty()) {
	    	Analytics_Mailer__c mailerObj = new Analytics_Mailer__c();
	    	mailerObj.People__c = peopleId;
	    	mailerObj.Mailer__c = mailerId;
	    	mailerObj.Click_Count__c = 1;
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().insertAsUser(mailerObj, new List<Schema.SObjectField>{
    															 Analytics_Mailer__c.People__c,
    															 Analytics_Mailer__c.Mailer__c,
    															 Analytics_Mailer__c.Click_Count__c});
    		
    	} else {
    		Analytics_Mailer__c mailerObj = listOfMailerAnalytics[0];
    		mailerObj.Click_Count__c = mailerObj.Click_Count__c + 1;
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(mailerObj, new List<Schema.SObjectField>{
    															 Analytics_Mailer__c.Click_Count__c});
		}
	}	
    
    @TestVisible
    private void updateViewCountForContent(String contentIdArg) {
    	List<Content_Interaction__c> contentInteractionList = [SELECT id, View_Count__c, Sync_Status__c FROM Content_Interaction__c WHERE
    															People__c =: UserContext.peopleId AND Content__c=:contentIdArg WITH SECURITY_ENFORCED limit 1];
    	if(contentInteractionList.isEmpty()){
    		Content_Interaction__c contentInteractionObj = new Content_Interaction__c();
    		contentInteractionObj.View_Count__c = 1;
    		contentInteractionObj.People__c = UserContext.peopleId;
    		contentInteractionObj.Content__c = contentIdArg;
			contentInteractionObj.Sync_Status__c = 0;
    		insert contentInteractionObj;
    		
    	} else {
    		contentInteractionList[0].View_Count__c = contentInteractionList[0].View_Count__c + 1;
			contentInteractionList[0].Sync_Status__c = contentInteractionList[0].Sync_Status__c != null ? 2 : 0;
    		update contentInteractionList;
    	}
    	
    }
    
    @Testvisible
    private void createPeopleInteraction(){
    	Integer currentMonthInt = Integer.valueOf(DateTime.now().format('yyyyMM'));
    	List<People_Interaction__c> peopleInteractionList = [SELECT Id, People__c, Content_Accessed_Month__c From People_Interaction__c 
    														 WHERE People__c = :UserContext.peopleId
    														 AND Content_Accessed_Month__c = :currentMonthInt WITH SECURITY_ENFORCED];
		if(peopleInteractionList.isEmpty()){
			People_Interaction__c peopleInteractionRec = new People_Interaction__c(People__c = UserContext.peopleId, Content_Accessed_Month__c = currentMonthInt);
			insert peopleInteractionRec;
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
    public AnalyticsWrapper.Logins getLoginsAnalytics(String fromDate,String toDate){
    	AnalyticsWrapper.Logins loginObj = new AnalyticsWrapper.Logins();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String query = 'select ID, Date__c, Total_Simpplr_Users__c from Analytics_Login__c where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Login__c> alObjList = (List<Analytics_Login__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	Map<Date, Analytics_Login__c> loginAnalyticsMap = new Map<Date, Analytics_Login__c>();
    	Decimal totalSimpplrUsersMax = 0;
    	Decimal totalSimpplrLicencedUserTmp = 0;
    	
    	for(Analytics_Login__c alObj : alObjList){
    		loginAnalyticsMap.put(alObj.Date__c, alObj);
    		
    		totalSimpplrLicencedUserTmp = (alObj.Total_Simpplr_Users__c == null) ? 0 : alObj.Total_Simpplr_Users__c;
    		if(totalSimpplrUsersMax < totalSimpplrLicencedUserTmp){
    			totalSimpplrUsersMax = totalSimpplrLicencedUserTmp;
    		}
    	}
		
		String queryStr1 = 'select People__c from Analytics_Adoption__c where Desktop__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		String queryStr2 = 'select People__c from Analytics_Adoption__c where DesktopApp__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		String queryStr3 = 'select People__c from Analytics_Adoption__c where Mobile__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		String queryStr4 = 'select People__c from Analytics_Adoption__c where MobileApp__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticsAdoptionDekstopList = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr1, soqlParamMap);
		List<Analytics_Adoption__c> analyticsAdoptionDekstopAppList = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr2, soqlParamMap);
		List<Analytics_Adoption__c> analyticsAdoptionMobileList = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr3, soqlParamMap);
		List<Analytics_Adoption__c> analyticsAdoptionMobileAppList = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr4, soqlParamMap);
		List<String> analyticsAdoptionDekstopPeopleList = new List<String>();
		List<String> analyticsAdoptionDekstopAppPeopleList = new List<String>();
		List<String> analyticsAdoptionMobilePeopleList = new List<String>();
		List<String> analyticsAdoptionMobileAppPeopleList = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionDekstopList) {
			analyticsAdoptionDekstopPeopleList.add(analyticsAdoptionObj.people__c);
		}
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionDekstopAppList) {
			analyticsAdoptionDekstopAppPeopleList.add(analyticsAdoptionObj.people__c);
		}
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionMobileList) {
			analyticsAdoptionMobilePeopleList.add(analyticsAdoptionObj.people__c);
		}
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionMobileAppList) {
			analyticsAdoptionMobileAppPeopleList.add(analyticsAdoptionObj.people__c);
		}
		
	    List<People__c> desktopPeopleList = new List<People__c>([SELECT id from People__c where id IN : analyticsAdoptionDekstopPeopleList]);
	    List<People__c> desktopAppPeopleList = new List<People__c>([SELECT id from People__c where id IN :analyticsAdoptionDekstopAppPeopleList]);
		List<People__c> mobilePeopleList = new List<People__c>([SELECT id from People__c where id IN :analyticsAdoptionMobilePeopleList]);
		List<People__c> mobileAppPeopleList = new List<People__c>([SELECT id from People__c where id IN :analyticsAdoptionMobileAppPeopleList]);
	    
		String queryStr5 = 'SELECT Date__c recordDate, COUNT_DISTINCT(People__c) dcount FROM Analytics_Adoption__c WHERE Desktop__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 GROUP BY Date__c';
		String queryStr6 = 'SELECT Date__c recordDate, COUNT_DISTINCT(People__c) dacount FROM Analytics_Adoption__c WHERE DesktopApp__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 GROUP BY Date__c';
		String queryStr7 = 'SELECT Date__c recordDate, COUNT_DISTINCT(People__c) mcount FROM Analytics_Adoption__c WHERE Mobile__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 GROUP BY Date__c';
		String queryStr8 = 'SELECT Date__c recordDate, COUNT_DISTINCT(People__c) macount FROM Analytics_Adoption__c WHERE MobileApp__c > 0 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 GROUP BY Date__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<AggregateResult> desktopAggObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(queryStr5, soqlParamMap);
		List<AggregateResult> desktopAppAggObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(queryStr6, soqlParamMap);
		List<AggregateResult> mobileAggObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(queryStr7, soqlParamMap);
		List<AggregateResult> mobileAppAggObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(queryStr8, soqlParamMap);
    	
    	Map<Date, AnalyticsWrapper.LoginsData> loginDataMap = new Map<Date, AnalyticsWrapper.LoginsData>();
    	
    	for(Date dateObj : dateSet){
    		loginDataMap.put(dateObj,new AnalyticsWrapper.LoginsData(String.valueOf(dateObj), new AnalyticsWrapper.LoginCountData(0,0,0,0)));
    	}
    	
    	Integer maxLength = desktopAggObjList.size();
    	
    	if(maxLength < desktopAppAggObjList.size()){
    		maxLength = desktopAppAggObjList.size();
    	}
    	
    	if(maxLength < mobileAggObjList.size()){
    		maxLength = mobileAggObjList.size();
    	}
    	
    	if(maxLength < mobileAppAggObjList.size()){
    		maxLength = mobileAppAggObjList.size();
    	}
    	
    	AggregateResult desktopAggObj;
    	AggregateResult desktopAppAggObj;
    	AggregateResult mobileAggObj;
    	AggregateResult mobileAppAggObj;
    	AnalyticsWrapper.LoginsData dataObj;
    	
    	Integer desktopAggObjListSize = desktopAggObjList.size();
    	Integer desktopAppAggObjListSize = desktopAppAggObjList.size();
    	Integer mobileAggObjListSize = mobileAggObjList.size();
    	Integer mobileAppAggObjListSize = mobileAppAggObjList.size();
    	
    	Decimal totalSimpplrLicencedUser = 0;
    	Decimal loginPercentViaDevice = 0;
    	
    	for(Integer index = 0; index < maxLength; index++){
    		if(index < desktopAggObjListSize){
    			desktopAggObj = desktopAggObjList.get(index);
    			Date date1 = (Date)desktopAggObj.get('recordDate');
    			Decimal desktopCount = (Integer)desktopAggObj.get('dcount');
    			totalSimpplrLicencedUser = loginAnalyticsMap.get(date1) != null ? (loginAnalyticsMap.get(date1)).Total_Simpplr_Users__c : 0;
    			loginPercentViaDevice = (((totalSimpplrLicencedUser != null) && (totalSimpplrLicencedUser > 0)) ? ((desktopCount * 100)/totalSimpplrLicencedUser).setScale(2) : 0);
    			
    			if(!loginDataMap.containsKey(date1)){
					dataObj = new AnalyticsWrapper.LoginsData();
					dataObj.day = String.valueOf(date1);
					dataObj.counts = new AnalyticsWrapper.LoginCountData(loginPercentViaDevice, 0, 0, 0);
					
					loginDataMap.put(date1, dataObj);
    			} else {
    				loginDataMap.get(date1).counts.desktop = loginPercentViaDevice;
    			}
			}
    		
    		if(index < desktopAppAggObjListSize){
    			desktopAppAggObj = desktopAppAggObjList.get(index);
    			Date date2 = (Date)desktopAppAggObj.get('recordDate');
    			Integer desktopAppCount = (Integer)desktopAppAggObj.get('dacount');
    			totalSimpplrLicencedUser = loginAnalyticsMap.get(date2) != null ? (loginAnalyticsMap.get(date2)).Total_Simpplr_Users__c : 0;
    			loginPercentViaDevice = (((totalSimpplrLicencedUser != null) && (totalSimpplrLicencedUser > 0)) ? ((desktopAppCount * 100)/totalSimpplrLicencedUser).setScale(2) : 0);
    			
    			if(!loginDataMap.containsKey(date2)){
					dataObj = new AnalyticsWrapper.LoginsData();
					dataObj.day = String.valueOf(date2);
					dataObj.counts = new AnalyticsWrapper.LoginCountData(0, loginPercentViaDevice, 0, 0);
					
					loginDataMap.put(date2, dataObj);
    			} else {
    				loginDataMap.get(date2).counts.desktop_app = loginPercentViaDevice;
    			}
    		}
    		
    		if(index < mobileAggObjListSize){
    			mobileAggObj = mobileAggObjList.get(index);
    			Date date3 = (Date)mobileAggObj.get('recordDate');
    			Integer mobileCount = (Integer)mobileAggObj.get('mcount');
    			totalSimpplrLicencedUser = loginAnalyticsMap.get(date3) != null ? (loginAnalyticsMap.get(date3)).Total_Simpplr_Users__c : 0;
    			loginPercentViaDevice = (((totalSimpplrLicencedUser != null) && (totalSimpplrLicencedUser > 0)) ? ((mobileCount * 100)/totalSimpplrLicencedUser).setScale(2) : 0);
    		
    			if(!loginDataMap.containsKey(date3)){
	    			dataObj = new AnalyticsWrapper.LoginsData();
	    			dataObj.day = String.valueOf(date3);
					dataObj.counts = new AnalyticsWrapper.LoginCountData(0, 0, loginPercentViaDevice, 0);
					
					loginDataMap.put(date3, dataObj);
    			} else {
    				loginDataMap.get(date3).counts.mobile = loginPercentViaDevice;
    			}
    		}
    		
    		if(index < mobileAppAggObjListSize){
    			mobileAppAggObj = mobileAppAggObjList.get(index);
    			Date date4 = (Date)mobileAppAggObj.get('recordDate');
    			Integer mobileAppCount = (Integer)mobileAppAggObj.get('macount');
    			totalSimpplrLicencedUser = loginAnalyticsMap.get(date4) != null ? (loginAnalyticsMap.get(date4)).Total_Simpplr_Users__c : 0;
				loginPercentViaDevice = (((totalSimpplrLicencedUser != null) && (totalSimpplrLicencedUser > 0)) ? ((mobileAppCount * 100)/totalSimpplrLicencedUser).setScale(2) : 0);
				
				if(!loginDataMap.containsKey(date4)){
					dataObj = new AnalyticsWrapper.LoginsData();
					dataObj.day = String.valueOf(date4);
					dataObj.counts = new AnalyticsWrapper.LoginCountData(0, 0, 0, loginPercentViaDevice);
					
					loginDataMap.put(date4, dataObj);
				} else {
    				loginDataMap.get(date4).counts.mobile_app = loginPercentViaDevice;
    			}
    		}
    	}
    	String queryStr9 = 'select People__c from Analytics_Adoption__c where Is_active__c = true And Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticsAdoptionList = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr9, soqlParamMap);
		List<String> peopleList = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionList) {
			peopleList.add(analyticsAdoptionObj.People__c);
		}
    	List<People__c> adoptionPeopleList = new List<People__c>([SELECT id from People__c where id IN : peopleList]);
	    Decimal uniqueLogins = adoptionPeopleList.size();
    	
    	Decimal averageLoggedInUserPercent = ((totalSimpplrUsersMax > 0) ? ((uniqueLogins * 100)/totalSimpplrUsersMax).setScale(2) : 0);
    	List<AnalyticsWrapper.LoginsData> loginsDataList = loginDataMap.values();
    	loginsDataList.sort();
    	loginObj.data = loginsDataList;
    	loginObj.totals = new AnalyticsWrapper.TotalCount(
    							averageLoggedInUserPercent,
							 	((totalSimpplrUsersMax > 0)? ((desktopPeopleList.size()/totalSimpplrUsersMax)*100).setScale(2) : 0), 
							 	((totalSimpplrUsersMax > 0)? ((desktopAppPeopleList.size()/totalSimpplrUsersMax)*100).setScale(2) : 0),
							 	((totalSimpplrUsersMax > 0)? ((mobilePeopleList.size()/totalSimpplrUsersMax)*100).setScale(2) : 0), 
							 	((totalSimpplrUsersMax > 0)? ((mobileAppPeopleList.size()/totalSimpplrUsersMax)*100).setScale(2) : 0)
							 );
    	
    	return loginObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public AnalyticsWrapper.PageViews getPageviewsAnalytics(String fromDate,String toDate){
	    	AnalyticsWrapper.PageViews pageViewsObj = new AnalyticsWrapper.PageViews();
	    	pageViewsObj.totals = new AnalyticsWrapper.PageViewsCountData(0,0,0,0);
	    pageViewsObj.totals.desktop = 0;
	    pageViewsObj.totals.desktop_app = 0;
	    	pageViewsObj.totals.mobile = 0;
	    	pageViewsObj.totals.mobile_app = 0;
	    	
	    	List<AnalyticsWrapper.PageViewsData> pageViewsDataList = new List<AnalyticsWrapper.PageViewsData>();
	    	fDate = setStringToDateFormat(fromDate);
	    	tDate = setStringToDateFormat(toDate);
	    	List<Analytics_PageView__c> pageviewsCount = new List<Analytics_PageView__c>();
	    	map<Date,AnalyticsWrapper.PageViewsData> dateWithPageViewDataMap =  new map<Date,AnalyticsWrapper.PageViewsData>();
	    	
	    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
	    	for(Date dateObj : dateSet){
	    		dateWithPageViewDataMap.put(dateObj,new AnalyticsWrapper.PageViewsData(String.valueOf(dateObj),new AnalyticsWrapper.PageViewsCountData(0,0,0,0)));
	    	}
	    	
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String pageViewQuery = 'SELECT Desktop__c, DesktopApp__c,Mobile__c,MobileApp__c,Date__c from Analytics_PageView__c where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	pageviewsCount.addAll((List<Analytics_PageView__c>)SIMPESAPI.accessController().queryAsUser(pageViewQuery, soqlParamMap));
	    	for(Analytics_PageView__c pageViewRec : pageviewsCount){
	    		if(dateWithPageViewDataMap.get(pageViewRec.Date__c) == null){
	    			dateWithPageViewDataMap.put(pageViewRec.Date__c, new AnalyticsWrapper.PageViewsData());
	    		}
	    		pageViewsObj.totals.desktop += Integer.valueof(pageViewRec.Desktop__c);
	    		pageViewsObj.totals.desktop_app += Integer.valueof(pageViewRec.DesktopApp__c);
	    		pageViewsObj.totals.mobile += Integer.valueof(pageViewRec.Mobile__c);
	    		pageViewsObj.totals.mobile_app += Integer.valueof(pageViewRec.MobileApp__c);
	    		pageViewsObj.totals.total = pageViewsObj.totals.desktop + pageViewsObj.totals.mobile + pageViewsObj.totals.desktop_app + pageViewsObj.totals.mobile_app;
	    		
	    		AnalyticsWrapper.PageViewsData dataObj = dateWithPageViewDataMap.get(pageViewRec.Date__c);
	    		dataObj.day = String.valueOf(pageViewRec.Date__c);
	    		dataObj.counts.desktop = (pageViewRec.Desktop__c==null) ? 0 : Integer.valueof(pageViewRec.Desktop__c);
	    		dataObj.counts.desktop_app = (pageViewRec.DesktopApp__c==null) ? 0 : Integer.valueof(pageViewRec.DesktopApp__c);
	    		dataObj.counts.mobile = (pageViewRec.Mobile__c==null)? 0 : Integer.valueof(pageViewRec.Mobile__c);
	    		dataObj.counts.mobile_app =(pageViewRec.MobileApp__c==null)? 0 : Integer.valueof(pageViewRec.MobileApp__c);
	    		dateWithPageViewDataMap.put(pageViewRec.Date__c,dataObj);
		}
		
	    	pageViewsDataList = dateWithPageViewDataMap.values();
	    	pageViewsDataList.sort();
	    	pageViewsObj.data = pageViewsDataList;
	    	return pageViewsObj;
    }
    
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<AnalyticsWrapper.AdoptionData> getAdoptionAnalytics(String fromDate, String toDate){
    	List<AnalyticsWrapper.AdoptionData> adoptionDataObjList = new List<AnalyticsWrapper.AdoptionData>();
    	Date fDate = setStringToDateFormat(fromDate);
	    Date tDate = setStringToDateFormat(toDate);
    	
    	List<Analytics_Login__c> analyticsLoginObjList = new List<Analytics_Login__c>();
    	map<Date,AnalyticsWrapper.AdoptionData> dateWithAdoptionDataMap =  new map<Date,AnalyticsWrapper.AdoptionData>();
    	
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	for(Date dateObj : dateSet){
    		dateWithAdoptionDataMap.put(dateObj,new AnalyticsWrapper.AdoptionData(String.valueOf(dateObj)));
    	}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String query = 'SELECT ID, Date__c, Total_Simpplr_Users__c, Unique_logins__c from Analytics_Login__c'+
								    					   ' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		analyticsLoginObjList = (List<Analytics_Login__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		AnalyticsWrapper.AdoptionData adoptionData;
		for(Analytics_Login__c alObj : analyticsLoginObjList){
			if(dateWithAdoptionDataMap.get(alObj.Date__c) == null){
    			dateWithAdoptionDataMap.put(alObj.Date__c, new AnalyticsWrapper.AdoptionData());
    		}
    		AnalyticsWrapper.AdoptionData dataObj = dateWithAdoptionDataMap.get(alObj.Date__c);
			Date dateStr = alObj.Date__c;
			Decimal activeCount =(alObj.Unique_logins__c==null) ? 0: alObj.Unique_logins__c;
			Decimal totalSimpplrUser = ((alObj.Total_Simpplr_Users__c  == null) ? 0 : alObj.Total_Simpplr_Users__c);
			Decimal inactiveCount = (((totalSimpplrUser - activeCount) > 0) ? (totalSimpplrUser - activeCount) : 0);
			Decimal totalCount = totalSimpplrUser;
			Decimal activeCountPercent = ((totalCount > 0) ? ((activeCount/totalCount)*100).setScale(2) : 0);
			Decimal inactiveCountPercent = ((totalCount > 0) ? ((inactiveCount/totalCount)*100).setScale(2) : 0);
			
			dataObj.day = String.valueOf(dateStr);
			dataObj.counts = new AnalyticsWrapper.CountData(inactiveCountPercent, activeCountPercent);
			dateWithAdoptionDataMap.put(alObj.Date__c,dataObj);
			
		}
		adoptionDataObjList = dateWithAdoptionDataMap.values();
		adoptionDataObjList.sort();
		return adoptionDataObjList;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    
    
    		
    		loginsDataList.add(dataObj);
    	}
    	Decimal averageLoggedInUserPercent = ((alObjList.size() > 0) ? (totalUsersLoggedIn/alObjList.size()).setScale(2) : 0);
    */
    public AnalyticsWrapper.AdoptionCountData getAdoptionCount(String fromDate,String toDate){
    	AnalyticsWrapper.AdoptionCountData adoptionCountDataObj = new AnalyticsWrapper.AdoptionCountData();
	    Date fDate = setStringToDateFormat(fromDate);
	    Date tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
	    String query = 'select People__c from Analytics_Adoption__c where Is_active__c = true And Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticsAdoptionList = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		List<String> peopleList = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionList) {
			peopleList.add(analyticsAdoptionObj.People__c);
		}
	    List<People__c> adoptionPeopleList = new List<People__c>([SELECT id from People__c where id IN : peopleList]);
	    List<Analytics_Login__c> analyticsLoginObjList = new List<Analytics_Login__c>();
		query = 'SELECT Unique_logins__c, Total_Simpplr_Users__c, Average_logins_per_user__c, Page_Views__c from Analytics_Login__c'+
														  ' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		analyticsLoginObjList = (List<Analytics_Login__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		Decimal pageViewSum = 0;
		Decimal averageLoginsPerUserSum = 0;
		Decimal totalSimpplrUsers = 0;
		Decimal totalSimpplrUsersMax = adoptionPeopleList.size();
		
		for (Analytics_Login__c analyticsLoginObj : analyticsLoginObjList){
    		pageViewSum += ((analyticsLoginObj.Page_Views__c == null) ? 0 : analyticsLoginObj.Page_Views__c);
			averageLoginsPerUserSum += ((analyticsLoginObj.Average_logins_per_user__c == null) ? 0 : analyticsLoginObj.Average_logins_per_user__c);
    		totalSimpplrUsers = ((analyticsLoginObj.Total_Simpplr_Users__c == null) ? 0 : analyticsLoginObj.Total_Simpplr_Users__c);
    		
    		if(totalSimpplrUsersMax < totalSimpplrUsers){
    			totalSimpplrUsersMax = totalSimpplrUsers;
    		}
    	}
		
		Decimal analyticsLoginListSize = analyticsLoginObjList.size();
		adoptionCountDataObj.usersLoggedIn = adoptionPeopleList.size();
		 // ((unique number of logins/total users)*100);
		adoptionCountDataObj.loggedInPercentage = (totalSimpplrUsersMax > 0) ? ((adoptionCountDataObj.usersLoggedIn * 100)/totalSimpplrUsersMax).setScale(2) : 0;
		//(sum of total number of logins by all users / total nmbr of users);
		adoptionCountDataObj.averageLoginsPerUser = (analyticsLoginListSize > 0) ? ((averageLoginsPerUserSum/analyticsLoginListSize).setScale(2)) : 0;
		adoptionCountDataObj.pageViews = pageViewSum;
    	
    	return adoptionCountDataObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */

    public List<AnalyticsWrapper.AdoptionAverageData> getAdoptionAverage(String fromDate,String toDate){
    	List<AnalyticsWrapper.AdoptionAverageData> adoptionAvgDataList = new List<AnalyticsWrapper.AdoptionAverageData>();
    	Date fDate = setStringToDateFormat(fromDate);
    	Date tDate = setStringToDateFormat(toDate);
    
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
	    String queryStr1 = 'select People__c from Analytics_Adoption__c where Is_Contributor__c = true AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticsAdoptionList1 = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr1, soqlParamMap);
		List<String> peopleList1 = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionList1) {
			peopleList1.add(analyticsAdoptionObj.People__c);
		}
		List<People__c> contributorPeopleList = new List<People__c>([SELECT id from People__c where id IN : peopleList1]);

		soqlParamMap.put('soqlParam3', contributorPeopleList);
	    String queryStr2 = 'select People__c from Analytics_Adoption__c where Is_Participant__c = true AND People__c NOT IN :soqlParam3 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticsAdoptionList2 = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr2, soqlParamMap);
		List<String> peopleList2 = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionList2) {
			peopleList2.add(analyticsAdoptionObj.People__c);
		}
		List<People__c> participantPeopleList = new List<People__c>([SELECT id from People__c where id IN : peopleList2]);

		soqlParamMap.put('soqlParam4', participantPeopleList);
	    String queryStr3 = 'select People__c from Analytics_Adoption__c where Is_Observer__c = true AND People__c NOT IN :soqlParam4 AND People__c NOT IN :soqlParam3 AND Date__c>= :soqlParam2 AND Date__c<= :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticsAdoptionList3 = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(queryStr3, soqlParamMap);
		List<String> peopleList3 = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticsAdoptionList3) {
			peopleList3.add(analyticsAdoptionObj.People__c);
		}
	    List<People__c> observerPeopleList = new List<People__c>([SELECT id from People__c where id IN : peopleList3]);

	    String query = 'SELECT MAX(Total_Simpplr_Users__c) max_total_simpplr_users from Analytics_Login__c'+
														  ' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> analyticsLoginAggObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    Integer totalSimpplrUsersMax = 0;
	    Integer inactiveUserCount = 0;
	    if(analyticsLoginAggObjList.size() > 0){
	    	AggregateResult ar = analyticsLoginAggObjList.get(0);
	    	Decimal maxTotalUsers = (Decimal)ar.get('max_total_simpplr_users');
	    	if(maxTotalUsers != null) { 
	    		totalSimpplrUsersMax = maxTotalUsers.intValue(); 
		    	if(totalSimpplrUsersMax > (contributorPeopleList.size() + participantPeopleList.size() + observerPeopleList.size())) {
		    		inactiveUserCount = totalSimpplrUsersMax - (contributorPeopleList.size() + participantPeopleList.size() + observerPeopleList.size());
		    	}
			    adoptionAvgDataList.add(new AnalyticsWrapper.AdoptionAverageData('Contributors', contributorPeopleList.size()));
			    adoptionAvgDataList.add(new AnalyticsWrapper.AdoptionAverageData('Participants', participantPeopleList.size()));
			    adoptionAvgDataList.add(new AnalyticsWrapper.AdoptionAverageData('Observers', observerPeopleList.size()));
			    adoptionAvgDataList.add(new AnalyticsWrapper.AdoptionAverageData('Inactive', inactiveUserCount));
	    	}
	    }
	   	return adoptionAvgDataList;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */

    public AnalyticsWrapper.AdoptionOverview getAdoptionOverview(String fromDate,String toDate, String orderBy){
    	Date fDate = setStringToDateFormat(fromDate);
    	Date tDate = setStringToDateFormat(toDate);
    	Date maxUserCreateDate = tDate.addDays(1);
    	
    	List<AnalyticsWrapper.AdoptionOverviewData> adoptionOverviewDataList = new List<AnalyticsWrapper.AdoptionOverviewData>();
    	
    	
    	List<String> userFieldToShow;
    	if(SimpplrContext.isSegmentsEnabled){
    		userFieldToShow = new List<String>{'Name','Email','Adoption','Segment Name','Company Name','Division','Department','City','State','Country'};
    	}else{
    		userFieldToShow = new List<String>{'Name','Email','Adoption','Company Name','Division','Department','City','State','Country'};
    	}
    	
    	if(SimpplrContext.isPeopleCategoryEnable){
    		userFieldToShow.add(SimpplrContext.peopleCategorySingular);
    	}
    	userFieldToShow.add('Job Title');
    	if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
    		userFieldToShow.add('Role');
    	}
    	List<String> fieldAPIList = Utility.getLabelWithUserFieldAPIMap(userFieldToShow);
    	Map<String,User> userMap = getUserMap(fieldAPIList);
	    Map<String, Object> soqlParamsMap = new  Map<String, Object>();
		soqlParamsMap.put('soqlParam1', fDate);
		soqlParamsMap.put('soqlParam2', tDate);
	    String query1 = 'select People__c from Analytics_Adoption__c where Is_Contributor__c = true AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticAdoptionList1 = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(query1, soqlParamsMap);
		List<String> peoList1 = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticAdoptionList1) {
			peoList1.add(analyticsAdoptionObj.People__c);
		}
		String contributorPeopleQuery = 'SELECT id,People_Category__r.name__c,Title__c, User__c,Full_Name__c, Email__c,Company_Name__c, Division__c, City__c,Country__c,State__c,Department__c, Segment__r.Name__c,Role__c from People__c where id IN : peoList1 ';
		if(orderBy == 'CreatedDate') {
            contributorPeopleQuery += ' order by CreatedDate ASC';
        } else {
            contributorPeopleQuery += ' order by Full_Name__c';
        }
		List<People__c> contributorPeopleList = Database.query(contributorPeopleQuery);

		soqlParamsMap.put('soqlParam3', contributorPeopleList);
	    String query2 = 'select People__c from Analytics_Adoption__c where Is_Participant__c = true AND People__c NOT IN :soqlParam3 AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticAdoptionList2 = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(query2, soqlParamsMap);
		List<String> peoList2 = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticAdoptionList2) {
			peoList2.add(analyticsAdoptionObj.People__c);
		}
        String participantPeopleQuery = 'SELECT id,People_Category__r.name__c,Title__c, user__c,Full_Name__c, Email__c,Company_Name__c, Division__c, City__c,Country__c,State__c,Department__c, Segment__r.Name__c,Role__c from People__c where id IN : peoList2 ';
		if(orderBy == 'CreatedDate') {
            participantPeopleQuery += ' order by CreatedDate ASC';
        } else {
            participantPeopleQuery += ' order by Full_Name__c';
        }
        List<People__c> participantPeopleList = Database.query(participantPeopleQuery);
		
		soqlParamsMap.put('soqlParam4', participantPeopleList);
	    String query3 = 'select People__c from Analytics_Adoption__c where Is_Observer__c = true AND People__c NOT IN :soqlParam4 AND People__c NOT IN :soqlParam3 AND Date__c>= :soqlParam2 AND Date__c<= :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticAdoptionList3 = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(query3, soqlParamsMap);
		List<String> peoList3 = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticAdoptionList3) {
			peoList3.add(analyticsAdoptionObj.People__c);
		}
		String observerPeopleQuery = 'SELECT id,People_Category__r.name__c,Title__c, user__c,Full_Name__c, Email__c,Company_Name__c, Division__c, City__c,Country__c,State__c,Department__c, Segment__r.Name__c,Role__c from People__c where id IN : peoList3 ';
        if(orderBy == 'CreatedDate') {
            observerPeopleQuery += ' order by CreatedDate ASC';
        } else {
            observerPeopleQuery += ' order by Full_Name__c';
        }
        List<People__c> observerPeopleList = Database.query(observerPeopleQuery);
	    
		soqlParamsMap.put('soqlParam5', observerPeopleList);
	    String query4 = 'select People__c from Analytics_Adoption__c where (People__c IN :soqlParam4 OR People__c IN :soqlParam3 OR People__c IN :soqlParam5) AND Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Analytics_Adoption__c> analyticAdoptionList4 = (List<Analytics_Adoption__c>)SIMPESAPI.accessController().queryAsUSer(query4, soqlParamsMap);
		List<String> peoList4 = new List<String>();
		for(Analytics_Adoption__c analyticsAdoptionObj : analyticAdoptionList4) {
			peoList4.add(analyticsAdoptionObj.People__c);
		}
	    String inactivePeopleQueryStr = 'SELECT id,People_Category__r.name__c,Title__c, user__c,Full_Name__c, Email__c,Company_Name__c, Division__c, City__c,Country__c,State__c,Department__c, Segment__r.Name__c,Role__c FROM People__c WHERE User__r.IsActive = true AND User__r.UserType = \'Standard\' AND User__r.CreatedDate < :maxUserCreateDate AND Id NOT IN : peoList4';
	    String packageName = SimpplrContext.packageName;
	    if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 inactivePeopleQueryStr += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		inactivePeopleQueryStr += ' ORDER BY Full_Name__c';
	    
	    List<People__c> inactivePeopleList = Database.query(inactivePeopleQueryStr);
	    Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
	    String query = 'SELECT MAX(Total_Simpplr_Users__c) max_total_simpplr_users from Analytics_Login__c'+
														  ' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> analyticsLoginAggObjList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    Integer totalSimpplrUsersMax = 0;
	    Integer inactiveUserCount = 0;
	    if(analyticsLoginAggObjList.size() > 0){
	    	AggregateResult ar = analyticsLoginAggObjList.get(0);
	    	Decimal maxTotalUsers = (Decimal)ar.get('max_total_simpplr_users');
	    	if(maxTotalUsers != null) { 
	    		totalSimpplrUsersMax = maxTotalUsers.intValue(); 
		    	if(totalSimpplrUsersMax > (contributorPeopleList.size() + participantPeopleList.size() + observerPeopleList.size())) {
		    		inactiveUserCount = totalSimpplrUsersMax - (contributorPeopleList.size() + participantPeopleList.size() + observerPeopleList.size());
		    	}
	    	}
	    }
	    for(People__c peopleObj : contributorPeopleList) {
	    	adoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, 'Contributor',userMap.get(peopleObj.user__c),fieldAPIList));
	    }
	    for(People__c peopleObj : participantPeopleList) {
	    	adoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, 'Participant',userMap.get(peopleObj.user__c),fieldAPIList));
	    }
	    for(People__c peopleObj : observerPeopleList) {
	    	adoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, 'Observer',userMap.get(peopleObj.user__c),fieldAPIList));
	    }
	    for(People__c peopleObj : inactivePeopleList) {
	    	adoptionOverviewDataList.add(new AnalyticsWrapper.AdoptionOverviewData(peopleObj, 'No Login',userMap.get(peopleObj.user__c),fieldAPIList));
	    }
	    AnalyticsWrapper.AdoptionOverview adoptionOverviewObj = new AnalyticsWrapper.AdoptionOverview(contributorPeopleList.size(), participantPeopleList.size(), observerPeopleList.size(), inactiveUserCount, adoptionOverviewDataList,userFieldToShow);
	   	return adoptionOverviewObj;
    }
    
    private Map<String,User> getUserMap(List<String> fieldAPIList){
    	Map<String,User> userMap;
	    
		String userFieldQueryString = 'SELECT id,';
		for(String str: fieldAPIList){
			userFieldQueryString += str +',';
		}
		userFieldQueryString = userFieldQueryString.removeEnd(',') + ' From user ';
		userMap = new Map<String,User>((List<User>) Database.query(userFieldQueryString));
	    return userMap;
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getEngagementFeedPosts(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = new List<AnalyticsWrapper.EngagementfeedData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Feed_Count__c> analyticsFeedCount = new List<Analytics_Feed_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementfeedData> dateWithEngagementFeedDataMap =  new map<Date,AnalyticsWrapper.EngagementfeedData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'posts'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementFeedDataMap.put(dateObj,new AnalyticsWrapper.EngagementfeedData(String.valueOf(dateObj),countMap));
    	}
    	
    	if(siteId!=null){
    		//sId = getSiteIdFromChatterGroup(siteId);
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String feedCountQuery = 'SELECT Posts__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String feedCountQuery = 'SELECT Posts__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String feedCountQuery = 'SELECT Posts__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}
    	for(Analytics_Feed_Count__c feedCountRec : analyticsFeedCount){
    		if(dateWithEngagementFeedDataMap.get(feedCountRec.Date__c) == null){
    			dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,new AnalyticsWrapper.EngagementfeedData());
    		}
    		AnalyticsWrapper.EngagementfeedData dataObj = dateWithEngagementFeedDataMap.get(feedCountRec.Date__c);
    		dataObj.day = String.valueOf(feedCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('posts');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((feedCountRec.Posts__c == null) ? 0 : feedCountRec.Posts__c));
    		dataObj.counts.put('posts', val);
    		dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,dataObj);
    	}
    	listofEngagementfeedWrapper = dateWithEngagementFeedDataMap.values();
    	listofEngagementfeedWrapper.sort();
    	return listofEngagementfeedWrapper;
    	
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getEngagementFeedLikes(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = new List<AnalyticsWrapper.EngagementfeedData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Feed_Count__c> analyticsFeedCount = new List<Analytics_Feed_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementfeedData> dateWithEngagementFeedDataMap =  new map<Date,AnalyticsWrapper.EngagementfeedData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'likes'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementFeedDataMap.put(dateObj,new AnalyticsWrapper.EngagementfeedData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
    		//sId = getSiteIdFromChatterGroup(siteId);
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String feedCountQuery = 'SELECT Likes__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String feedCountQuery = 'SELECT Likes__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String feedCountQuery = 'SELECT Likes__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}
    	for(Analytics_Feed_Count__c feedCountRec : analyticsFeedCount){
    		if(dateWithEngagementFeedDataMap.get(feedCountRec.Date__c) == null){
    			dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,new AnalyticsWrapper.EngagementfeedData());
    		}
    		AnalyticsWrapper.EngagementfeedData dataObj = dateWithEngagementFeedDataMap.get(feedCountRec.Date__c);
    		dataObj.day = String.valueOf(feedCountRec.Date__c);

    		Integer val = dataObj.counts.get('likes');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((feedCountRec.Likes__c == null) ? 0 : feedCountRec.Likes__c));
    		dataObj.counts.put('likes', val);
    		
    		dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,dataObj);
    	}
    	listofEngagementfeedWrapper = dateWithEngagementFeedDataMap.values();
    	listofEngagementfeedWrapper.sort();
    	return listofEngagementfeedWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getEngagementFeedReplies(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = new List<AnalyticsWrapper.EngagementfeedData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Feed_Count__c> analyticsFeedCount = new List<Analytics_Feed_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementfeedData> dateWithEngagementFeedDataMap =  new map<Date,AnalyticsWrapper.EngagementfeedData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'replies'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementFeedDataMap.put(dateObj,new AnalyticsWrapper.EngagementfeedData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
    		//sId = getSiteIdFromChatterGroup(siteId);
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String feedCountQuery = 'SELECT Replies__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String feedCountQuery = 'SELECT Replies__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
		}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String feedCountQuery = 'SELECT Replies__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
		}
    	for(Analytics_Feed_Count__c feedCountRec : analyticsFeedCount){
    		if(dateWithEngagementFeedDataMap.get(feedCountRec.Date__c) == null){
    			dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,new AnalyticsWrapper.EngagementfeedData());
    		}
    		AnalyticsWrapper.EngagementfeedData dataObj = dateWithEngagementFeedDataMap.get(feedCountRec.Date__c);
    		dataObj.day = String.valueOf(feedCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('replies');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((feedCountRec.Replies__c == null) ? 0 : feedCountRec.Replies__c));
    		dataObj.counts.put('replies', val);
    		
    		dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,dataObj);
    	}
    	listofEngagementfeedWrapper = dateWithEngagementFeedDataMap.values();
    	listofEngagementfeedWrapper.sort();
    	return listofEngagementfeedWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementfeedData> getEngagementFeedShares(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementfeedData> listofEngagementfeedWrapper = new List<AnalyticsWrapper.EngagementfeedData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Feed_Count__c> analyticsFeedCount = new List<Analytics_Feed_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementfeedData> dateWithEngagementFeedDataMap =  new map<Date,AnalyticsWrapper.EngagementfeedData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'shares'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementFeedDataMap.put(dateObj,new AnalyticsWrapper.EngagementfeedData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
    		//sId = getSiteIdFromChatterGroup(siteId);
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String feedCountQuery = 'SELECT Shares__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String feedCountQuery = 'SELECT Shares__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
		}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String feedCountQuery = 'SELECT Shares__c, Date__c,Site__c from Analytics_Feed_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsFeedCount = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
		}
    	for(Analytics_Feed_Count__c feedCountRec : analyticsFeedCount){
    		if(dateWithEngagementFeedDataMap.get(feedCountRec.Date__c) == null){
    			dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,new AnalyticsWrapper.EngagementfeedData());
    		}
    		AnalyticsWrapper.EngagementfeedData dataObj = dateWithEngagementFeedDataMap.get(feedCountRec.Date__c);
    		dataObj.day = String.valueOf(feedCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('shares');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((feedCountRec.Shares__c == null) ? 0 : feedCountRec.Shares__c));
    		dataObj.counts.put('shares', val);
    		
    		dateWithEngagementFeedDataMap.put(feedCountRec.Date__c,dataObj);
    	}
    	listofEngagementfeedWrapper = dateWithEngagementFeedDataMap.values();
    	listofEngagementfeedWrapper.sort();
    	return listofEngagementfeedWrapper;
    }
    
    
     /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */ 
   public List<AnalyticsWrapper.EngagementContentData> getEngagementContentBookmarks(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = new List<AnalyticsWrapper.EngagementContentData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentData> dateWithEngagementContentDataMap =  new map<Date,AnalyticsWrapper.EngagementContentData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'favorites'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Bookmarks__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Bookmarks__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Bookmarks__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}  
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentDataMap.put(contentCountRec.Date__c, new AnalyticsWrapper.EngagementContentData());
    		}
    		AnalyticsWrapper.EngagementContentData dataObj = dateWithEngagementContentDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('favorites');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((contentCountRec.Bookmarks__c == null) ? 0 : contentCountRec.Bookmarks__c));
    		dataObj.counts.put('favorites', val);
    		
    		dateWithEngagementContentDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	listofEngagementContentWrapper = dateWithEngagementContentDataMap.values();
    	listofEngagementContentWrapper.sort();
    	return listofEngagementContentWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getEngagementContentLikes(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = new List<AnalyticsWrapper.EngagementContentData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentData> dateWithEngagementContentDataMap =  new map<Date,AnalyticsWrapper.EngagementContentData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'likes'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Likes__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Likes__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Likes__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentDataMap.put(contentCountRec.Date__c, new AnalyticsWrapper.EngagementContentData());
    		}
    		AnalyticsWrapper.EngagementContentData dataObj = dateWithEngagementContentDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('likes');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((contentCountRec.Likes__c == null) ? 0 : contentCountRec.Likes__c));
    		dataObj.counts.put('likes', val);
    		
    		dateWithEngagementContentDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	listofEngagementContentWrapper = dateWithEngagementContentDataMap.values();
    	listofEngagementContentWrapper.sort();
    	return listofEngagementContentWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getEngagementContentPosts(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = new List<AnalyticsWrapper.EngagementContentData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentData> dateWithEngagementContentDataMap =  new map<Date,AnalyticsWrapper.EngagementContentData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'posts'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Posts__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Posts__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Posts__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentDataMap.put(contentCountRec.Date__c, new AnalyticsWrapper.EngagementContentData());
    		}
    		AnalyticsWrapper.EngagementContentData dataObj = dateWithEngagementContentDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('posts');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((contentCountRec.Posts__c == null) ? 0 : contentCountRec.Posts__c));
    		dataObj.counts.put('posts', val);
    		
    		dateWithEngagementContentDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	listofEngagementContentWrapper = dateWithEngagementContentDataMap.values();
    	listofEngagementContentWrapper.sort();
    	return listofEngagementContentWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getEngagementContentPublished(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = new List<AnalyticsWrapper.EngagementContentData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentData> dateWithEngagementContentDataMap =  new map<Date,AnalyticsWrapper.EngagementContentData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'published'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Pages__c,Events__c,Blogs__c,Albums__c,Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Pages__c,Events__c,Blogs__c,Albums__c,Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Pages__c,Events__c,Blogs__c,Albums__c,Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentDataMap.put(contentCountRec.Date__c,  new AnalyticsWrapper.EngagementContentData());
    		}
    		AnalyticsWrapper.EngagementContentData dataObj = dateWithEngagementContentDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('published');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((contentCountRec.Pages__c == null) ? 0 : contentCountRec.Pages__c))+
    		Integer.valueof(((contentCountRec.Events__c == null) ? 0 : contentCountRec.Events__c))+
    		Integer.valueof(((contentCountRec.Blogs__c == null) ? 0 : contentCountRec.Blogs__c))+
    		Integer.valueof(((contentCountRec.Albums__c == null) ? 0: contentCountRec.Albums__c));
    		dataObj.counts.put('published', val);
    		
    		dateWithEngagementContentDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	listofEngagementContentWrapper = dateWithEngagementContentDataMap.values();
    	listofEngagementContentWrapper.sort();
    	return listofEngagementContentWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getEngagementContentReplies(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = new List<AnalyticsWrapper.EngagementContentData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentData> dateWithEngagementContentDataMap =  new map<Date,AnalyticsWrapper.EngagementContentData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'replies'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Replies__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Replies__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Replies__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentDataMap.put(contentCountRec.Date__c, new AnalyticsWrapper.EngagementContentData());
    		}
    		AnalyticsWrapper.EngagementContentData dataObj = dateWithEngagementContentDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('replies');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((contentCountRec.Replies__c == null) ? 0 : contentCountRec.Replies__c));
    		dataObj.counts.put('replies', val);
    		
    		dateWithEngagementContentDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	listofEngagementContentWrapper = dateWithEngagementContentDataMap.values();
    	listofEngagementContentWrapper.sort();
    	return listofEngagementContentWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getEngagementContentShares(String fromDate,String toDate,String siteid){
    	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = new List<AnalyticsWrapper.EngagementContentData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentData> dateWithEngagementContentDataMap =  new map<Date,AnalyticsWrapper.EngagementContentData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'shares'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Shares__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Shares__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Shares__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentDataMap.put(contentCountRec.Date__c, new AnalyticsWrapper.EngagementContentData());
    		}
    		AnalyticsWrapper.EngagementContentData dataObj = dateWithEngagementContentDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);
    		
    		Integer val = dataObj.counts.get('shares');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((contentCountRec.Shares__c == null) ? 0 : contentCountRec.Shares__c));
    		dataObj.counts.put('shares', val);
    		
    		dateWithEngagementContentDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	listofEngagementContentWrapper = dateWithEngagementContentDataMap.values();
    	listofEngagementContentWrapper.sort();
    	return listofEngagementContentWrapper;
    }
    
    public List<AnalyticsWrapper.EngagementContentData> getEngagementContentViews(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementContentData> listofEngagementContentWrapper = new List<AnalyticsWrapper.EngagementContentData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentData> dateWithEngagementContentDataMap =  new map<Date,AnalyticsWrapper.EngagementContentData>();
    	
    	Map<String,Integer> countMap = new Map<String,Integer>{'views'=>0};
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentData(String.valueOf(dateObj),countMap));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Views__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Views__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Views__c, Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentDataMap.put(contentCountRec.Date__c, new AnalyticsWrapper.EngagementContentData());
    		}
    		AnalyticsWrapper.EngagementContentData dataObj = dateWithEngagementContentDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);

    		Integer val = dataObj.counts.get('views');
    		if(val==null) val = 0;
    		val = val + Integer.valueof(((contentCountRec.Views__c == null) ? 0 : contentCountRec.Views__c));
    		dataObj.counts.put('views', val);
    		
    		dateWithEngagementContentDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	listofEngagementContentWrapper = dateWithEngagementContentDataMap.values();
    	listofEngagementContentWrapper.sort();
    	return listofEngagementContentWrapper;
    }
    
    
     /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<AnalyticsWrapper.EngagementContentTypesData> getEngagementContentTypes(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.EngagementContentTypesData> engagementContentTypesDataList = new List<AnalyticsWrapper.EngagementContentTypesData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	set<Date> dateSet = getdateSetWhenBatchRuns(fDate,tDate);
    	List<Analytics_Content_Count__c> analyticsContentCount = new List<Analytics_Content_Count__c>();
    	map<Date,AnalyticsWrapper.EngagementContentTypesData> dateWithEngagementContentTypesDataMap =  new map<Date,AnalyticsWrapper.EngagementContentTypesData>();
    	
    	for(Date dateObj : dateSet){
    		dateWithEngagementContentTypesDataMap.put(dateObj,new AnalyticsWrapper.EngagementContentTypesData(String.valueOf(dateObj),new AnalyticsWrapper.EngagementContentTypesCountData()));
    	}
    	if(siteId!=null){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', siteId);
			String contentCountQuery = 'SELECT Pages__c,Events__c,Blogs__c,Albums__c,Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String contentCountQuery = 'SELECT Pages__c,Events__c,Blogs__c,Albums__c,Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String contentCountQuery = 'SELECT Pages__c,Events__c,Blogs__c,Albums__c,Date__c,Site__c from Analytics_Content_Count__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsContentCount = (List<Analytics_Content_Count__c>)SIMPESAPI.accessController().queryAsUser(contentCountQuery, soqlParamMap);
    	}
    	for(Analytics_Content_Count__c contentCountRec : analyticsContentCount){
    		if(dateWithEngagementContentTypesDataMap.get(contentCountRec.Date__c) == null){
    			dateWithEngagementContentTypesDataMap.put(contentCountRec.Date__c,new AnalyticsWrapper.EngagementContentTypesData());
    		}
    		AnalyticsWrapper.EngagementContentTypesData dataObj = dateWithEngagementContentTypesDataMap.get(contentCountRec.Date__c);
    		dataObj.day = String.valueOf(contentCountRec.Date__c);
    		dataObj.counts.pages = dataObj.counts.pages + Integer.valueof(((contentCountRec.Pages__c == null) ? 0 : contentCountRec.Pages__c));
    		dataObj.counts.albums = dataObj.counts.albums + Integer.valueof(((contentCountRec.Albums__c == null) ? 0 : contentCountRec.Albums__c));
    		dataObj.counts.events = dataObj.counts.events + Integer.valueof(((contentCountRec.Events__c == null) ? 0 : contentCountRec.Events__c));
    		dataObj.counts.blog_posts = dataObj.counts.blog_posts + Integer.valueof(((contentCountRec.Blogs__c == null) ? 0 : contentCountRec.Blogs__c));
    		dateWithEngagementContentTypesDataMap.put(contentCountRec.Date__c,dataObj);
    	}
    	engagementContentTypesDataList = dateWithEngagementContentTypesDataMap.values();
    	engagementContentTypesDataList.sort();
    	return engagementContentTypesDataList;
    }
    
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesMembers(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSitesData> listOfPerformanceSitesWrapper = new List<AnalyticsWrapper.PerformanceSitesData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	List<Analytics_Top_Site__c> analyticsTopSite;
    	if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Members__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Members__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}
    	
    	
    	Map<Id, AnalyticsWrapper.PerformanceSitesData> SiteCountMap = new Map<Id, AnalyticsWrapper.PerformanceSitesData>();
    	for(Analytics_Top_Site__c siteRec : analyticsTopSite){
    		
    		if(SiteCountMap.get(siteRec.Site__c) == null){
    			SiteCountMap.put(siteRec.Site__c,new AnalyticsWrapper.PerformanceSitesData());
    		}
    		AnalyticsWrapper.PerformanceSitesData siteData = SiteCountMap.get(siteRec.Site__c);
    		siteData.name = siteRec.Site__r.name;
    		siteData.isActive = (siteRec.Site__r.Is_Active__c == true) ? true : false;
    		siteData.count = siteData.count + Integer.valueOf(((siteRec.Members__c == null) ? 0 : siteRec.Members__c));
    		siteData.url =  PageContext.getPageURL(Pages.app) +'?u=/site/' + siteRec.Site__c + '/' + siteRec.Site__r.Landing_Page__c;
    		SiteCountMap.put(siteRec.Site__c, siteData);
    	}
    	listOfPerformanceSitesWrapper = SiteCountMap.values();
    	listOfPerformanceSitesWrapper.sort();
    	return listOfPerformanceSitesWrapper;
    	
    }
    
     public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesLikes(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSitesData> listOfPerformanceSitesWrapper = new List<AnalyticsWrapper.PerformanceSitesData>();
    	fDate = setStringToDateFormat(fromDate); 
    	tDate = setStringToDateFormat(toDate);
    	List<Analytics_Top_Site__c> analyticsTopSite;
    	if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Likes__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Likes__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}
    	Map<Id, AnalyticsWrapper.PerformanceSitesData> SiteCountMap = new Map<Id, AnalyticsWrapper.PerformanceSitesData>();
    	for(Analytics_Top_Site__c siteRec : analyticsTopSite){
    		
    		if(SiteCountMap.get(siteRec.Site__c) == null){
    			SiteCountMap.put(siteRec.Site__c,new AnalyticsWrapper.PerformanceSitesData());
    		}
    		AnalyticsWrapper.PerformanceSitesData siteData = SiteCountMap.get(siteRec.Site__c);
    		siteData.name = siteRec.Site__r.name;
    		siteData.isActive = (siteRec.Site__r.Is_Active__c == true) ? true : false;
    		siteData.count = siteData.count + Integer.valueOf(((siteRec.Likes__c == null) ? 0 : siteRec.Likes__c));
    		siteData.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteRec.Site__c + '/' + siteRec.Site__r.Landing_Page__c;
    		SiteCountMap.put(siteRec.Site__c, siteData);
    	}
    	
    	listOfPerformanceSitesWrapper = SiteCountMap.values();
    	listOfPerformanceSitesWrapper.sort();
    	return listOfPerformanceSitesWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesPosts(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSitesData> listOfPerformanceSitesWrapper = new List<AnalyticsWrapper.PerformanceSitesData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	List<Analytics_Top_Site__c> analyticsTopSite;
    	if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Posts__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Posts__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}
    	Map<Id, AnalyticsWrapper.PerformanceSitesData> SiteCountMap = new Map<Id, AnalyticsWrapper.PerformanceSitesData>();
    	for(Analytics_Top_Site__c siteRec : analyticsTopSite){
    		
    		if(SiteCountMap.get(siteRec.Site__c) == null){
    			SiteCountMap.put(siteRec.Site__c,new AnalyticsWrapper.PerformanceSitesData());
    		}
    		AnalyticsWrapper.PerformanceSitesData siteData = SiteCountMap.get(siteRec.Site__c);
    		siteData.name = siteRec.Site__r.name;
    		siteData.isActive = (siteRec.Site__r.Is_Active__c == true) ? true : false;
    		siteData.count = siteData.count + Integer.valueOf(((siteRec.Posts__c == null) ? 0 : siteRec.Posts__c));
    		siteData.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteRec.Site__c + '/' + siteRec.Site__r.Landing_Page__c;
    		SiteCountMap.put(siteRec.Site__c, siteData);
    	}
    	
    	listOfPerformanceSitesWrapper = SiteCountMap.values();
    	listOfPerformanceSitesWrapper.sort();
    	return listOfPerformanceSitesWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesReplies(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSitesData> listOfPerformanceSitesWrapper = new List<AnalyticsWrapper.PerformanceSitesData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	List<Analytics_Top_Site__c> analyticsTopSite;
    	if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Replies__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Replies__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}
    	Map<Id, AnalyticsWrapper.PerformanceSitesData> SiteCountMap = new Map<Id, AnalyticsWrapper.PerformanceSitesData>();
    	for(Analytics_Top_Site__c siteRec : analyticsTopSite){
    		
    		if(SiteCountMap.get(siteRec.Site__c) == null){
    			SiteCountMap.put(siteRec.Site__c,new AnalyticsWrapper.PerformanceSitesData());
    		}
    		AnalyticsWrapper.PerformanceSitesData siteData = SiteCountMap.get(siteRec.Site__c);
    		siteData.name = siteRec.Site__r.name;
    		siteData.isActive = (siteRec.Site__r.Is_Active__c == true) ? true : false;
    		siteData.count = siteData.count + Integer.valueOf(((siteRec.Replies__c == null) ? 0 : siteRec.Replies__c));
    		siteData.url =  PageContext.getPageURL(Pages.app) +'?u=/site/' + siteRec.Site__c + '/' + siteRec.Site__r.Landing_Page__c;
    		SiteCountMap.put(siteRec.Site__c, siteData);
    	}
    	
    	listOfPerformanceSitesWrapper = SiteCountMap.values();
    	listOfPerformanceSitesWrapper.sort();
    	return listOfPerformanceSitesWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesViews(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSitesData> listOfPerformanceSitesWrapper = new List<AnalyticsWrapper.PerformanceSitesData>();
    	fDate = setStringToDateFormat(fromDate);
    	tDate = setStringToDateFormat(toDate);
    	List<Analytics_Top_Site__c> analyticsTopSite;
    	if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Views__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Views__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
    	}
    	Map<Id, AnalyticsWrapper.PerformanceSitesData> SiteCountMap = new Map<Id, AnalyticsWrapper.PerformanceSitesData>();
    	for(Analytics_Top_Site__c siteRec : analyticsTopSite){
    		
    		if(SiteCountMap.get(siteRec.Site__c) == null){
    			SiteCountMap.put(siteRec.Site__c,new AnalyticsWrapper.PerformanceSitesData());
    		}
    		AnalyticsWrapper.PerformanceSitesData siteData = SiteCountMap.get(siteRec.Site__c);
    		siteData.name = siteRec.Site__r.name;
    		siteData.isActive = (siteRec.Site__r.Is_Active__c == true) ? true : false;
    		siteData.count = siteData.count + Integer.valueOf(((siteRec.Views__c == null) ? 0 : siteRec.Views__c));
    		siteData.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteRec.Site__c + '/' + siteRec.Site__r.Landing_Page__c;
    		SiteCountMap.put(siteRec.Site__c, siteData);
    	}
    	
    	listOfPerformanceSitesWrapper = SiteCountMap.values();
    	listOfPerformanceSitesWrapper.sort();
    	return listOfPerformanceSitesWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceSitesData> getPerformanceSitesContentPublished(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSitesData> listOfPerformanceSitesWrapper = new List<AnalyticsWrapper.PerformanceSitesData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Site__c> analyticsTopSite;
        if(hasFullAccess){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Content_Published__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
        }else{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fDate);
			soqlParamMap.put('soqlParam2', tDate);
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
			String topSiteQuery = 'SELECT Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Is_Active__c, Content_Published__c from Analytics_Top_Site__c ' +
				' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Site__c IN :soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopSite = (List<Analytics_Top_Site__c>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
        }
    	Map<Id, AnalyticsWrapper.PerformanceSitesData> SiteCountMap = new Map<Id, AnalyticsWrapper.PerformanceSitesData>();
    	for(Analytics_Top_Site__c siteRec : analyticsTopSite){
    		
    		if(SiteCountMap.get(siteRec.Site__c) == null){
    			SiteCountMap.put(siteRec.Site__c,new AnalyticsWrapper.PerformanceSitesData());
    		}
    		AnalyticsWrapper.PerformanceSitesData siteData = SiteCountMap.get(siteRec.Site__c);
    		siteData.name = siteRec.Site__r.name;
    		siteData.isActive = (siteRec.Site__r.Is_Active__c == true) ? true : false;
    		siteData.count = siteData.count + Integer.valueOf(((siteRec.Content_Published__c == null) ? 0 : siteRec.Content_Published__c));
    		siteData.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteRec.Site__c + '/' + siteRec.Site__r.Landing_Page__c;
    		SiteCountMap.put(siteRec.Site__c, siteData);
    	}
    	
    	listOfPerformanceSitesWrapper = SiteCountMap.values();
    	listOfPerformanceSitesWrapper.sort();
    	return listOfPerformanceSitesWrapper;
    }
    
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleBookmarks(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, People__r.User__r.isActive, Bookmarks_Made__c from Analytics_Top_People__c '+
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Bookmarks_Made__c > 0)) Limit 1000000 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Bookmarks_Made__c == null) ? 0 : peopleRec.Bookmarks_Made__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
		}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleBookmarksReceived(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Bookmarks_Received__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Bookmarks_Received__c > 0)) Limit 1000000 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Bookmarks_Received__c == null) ? 0 : peopleRec.Bookmarks_Received__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeoplePublished(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Content_Published__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Content_Published__c > 0)) Limit 1000000 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Content_Published__c == null) ? 0 : peopleRec.Content_Published__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleMentions(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Feed_Mentions__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Feed_Mentions__c > 0)) LIMIT 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap); 	
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Feed_Mentions__c == null) ? 0 : peopleRec.Feed_Mentions__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeoplePosts(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Posts__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Posts__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Posts__c == null) ? 0 : peopleRec.Posts__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleReplies(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Replies_Made__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Replies_Made__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Replies_Made__c == null) ? 0 : peopleRec.Replies_Made__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleRepliesReceived(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Replies_Received__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Replies_Received__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Replies_Received__c == null) ? 0 : peopleRec.Replies_Received__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleFollowers(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Followers__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Followers__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Followers__c == null) ? 0 : peopleRec.Followers__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleFollowing(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Following__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Following__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Following__c == null) ? 0 : peopleRec.Following__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
    public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleLikes(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Likes_Made__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Likes_Made__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Likes_Made__c == null) ? 0 : peopleRec.Likes_Made__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleLikesReceived(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Likes_Received__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Likes_Received__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Likes_Received__c == null) ? 0 : peopleRec.Likes_Received__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleShares(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Shares_Made__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Shares_Made__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Shares_Made__c == null) ? 0 : peopleRec.Shares_Made__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData> getPerformancePeopleSharesReceived(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Shares_Received__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Shares_Received__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Shares_Received__c == null) ? 0 : peopleRec.Shares_Received__c));
    		peopleData.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
     public List<AnalyticsWrapper.PerformancePeopleData>getPerformancePeopleProfileViews(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformancePeopleData> listOfPerformancePeopleWrapper = new List<AnalyticsWrapper.PerformancePeopleData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT People__c,People__r.Full_Name__c, Views_Received__c, People__r.User__r.isActive from Analytics_Top_People__c'+ 
    															' where (Date__c>= :soqlParam1 AND Date__c<= :soqlParam2) AND ((People__r.User__r.isActive = true) AND (Views_Received__c > 0)) Limit 1000000 ';
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_People__c> analyticsTopPeople = (List<Analytics_Top_People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<Id, AnalyticsWrapper.PerformancePeopleData> peopleCountMap = new Map<Id, AnalyticsWrapper.PerformancePeopleData>();
    	Set<String> peopleIdSet = new Set<String>();
    	for(Analytics_Top_People__c peopleRec : analyticsTopPeople){
    		
    		if(peopleCountMap.get(peopleRec.People__c) == null){
    			peopleCountMap.put(peopleRec.People__c,new AnalyticsWrapper.PerformancePeopleData());
    		}
    		AnalyticsWrapper.PerformancePeopleData peopleData = peopleCountMap.get(peopleRec.People__c);
    		peopleData.name = peopleRec.People__r.Full_Name__c;
    		peopleData.count = peopleData.count + Integer.valueOf(((peopleRec.Views_Received__c == null) ? 0 : peopleRec.Views_Received__c));
    		peopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleRec.People__c;
    		peopleData.isActive = peopleRec.People__r.User__r.isActive;
    		peopleCountMap.put(peopleRec.People__c, peopleData);
    		
    		peopleIdSet.add(peopleRec.People__c);
    	}
    	
    	listOfPerformancePeopleWrapper = peopleCountMap.values();
    	listOfPerformancePeopleWrapper.sort();
    	
    	// This method will add more number of records to the list if the records in the list are lesser than the recordLimit
    	updateAnalyticsPerformanceWrapperList(listOfPerformancePeopleWrapper, peopleIdSet);
    	
    	return listOfPerformancePeopleWrapper;
    }
    
    public String convertTextToCsv(String changeText){
	    	if(String.isNotBlank(changeText)){
	    		changeText = changeText.escapeCsv();
	    	}
	    	return changeText;
    }
    
     public String checkScore(Integer score){
     	String responseString;
	    	if(score == -1){
	    		responseString = 'Did not respond';
	    	}else {
	    		responseString = String.valueOf(score);
	    	}
	    	return responseString;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *       
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private map<String,String> contentTypeMap = new map<String,String>{'news'=>'News','pages'=>'Page','events'=>'Event','albums'=>'Album','blog_posts' => 'BlogPost'};
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentBookmarks(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String queryString;
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);		
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Bookmarks__c from Analytics_Top_Content__c '+
    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
        }else if(hasFullAccess){			
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Bookmarks__c from Analytics_Top_Content__c '+
    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
        }else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Bookmarks__c from Analytics_Top_Content__c '+
    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';												
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	    	
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Bookmarks__c == null) ? 0 : contentRec.Bookmarks__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =  PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =  PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentBookmarksAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);	
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Bookmarks__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Bookmarks__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';														
        }else{
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());	
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Bookmarks__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
			
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Bookmarks__c == null) ? 0 : contentRec.Bookmarks__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =  PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentLikes(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);	
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Likes__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
        }else if(hasFullAccess){
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Likes__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
        }else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Likes__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Likes__c == null) ? 0 : contentRec.Likes__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentLikesAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
	
		
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Likes__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Likes__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';
        }else{
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Likes__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Likes__c == null) ? 0 : contentRec.Likes__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentPosts(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);	
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Posts__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
        }else if(hasFullAccess){
    		queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Posts__c from Analytics_Top_Content__c '+
    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
        }else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Posts__c from Analytics_Top_Content__c '+
    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Posts__c == null) ? 0 : contentRec.Posts__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentPostsAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Posts__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Posts__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';
        }else{
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Posts__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Posts__c  == null)  ? 0 : contentRec.Posts__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentReplies(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);	
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Replies__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Replies__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
        }else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Replies__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';
        }	
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}													
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Replies__c == null) ? 0 : contentRec.Replies__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentRepliesAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Replies__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Replies__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';
        }else{
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Replies__c from Analytics_Top_Content__c '+
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
        }	
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}													
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Replies__c == null) ? 0 : contentRec.Replies__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentShares(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);	
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Shares__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Shares__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
        }else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Shares__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';
        }	
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}													
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Shares__c == null) ? 0 : contentRec.Shares__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentSharesAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);			
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Shares__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Shares__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';
        }else{
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Shares__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Shares__c == null) ? 0 : contentRec.Shares__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentUnuseful(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);	
		
	
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Unuseful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
        }else if(hasFullAccess){
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Unuseful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
        }else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Unuseful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';
        }
    	if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Unuseful__c == null) ? 0 : contentRec.Unuseful__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentUnusefulAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Unuseful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Unuseful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';
        }else{
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Unuseful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Unuseful__c == null) ? 0 : contentRec.Unuseful__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentUseful(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);	
		
		
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Useful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
        }else if(hasFullAccess){
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Useful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
        }else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Useful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';
        }
    	if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Useful__c == null) ? 0 : contentRec.Useful__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
    public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentUsefulAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Useful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Useful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';
        }else{
			soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Useful__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
        }
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Useful__c == null) ? 0 : contentRec.Useful__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentViews(String fromDate,String toDate,String contentType,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        String simpplrContentType = contentTypeMap.get(contentType);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		soqlParamMap.put('soqlParam3', simpplrContentType);	
    	if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam4', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Views__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c=:soqlParam4';
    	}else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Views__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3';
    	}else{
			soqlParamMap.put('soqlParam4', UserContext.sitesIManageMap.keySet());
    		queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Views__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Type__c=:soqlParam3 AND Content__r.Site__c IN :soqlParam4';
    	}														
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Views__c == null) ? 0 : contentRec.Views__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url =PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
     public List<AnalyticsWrapper.PerformanceContentData> getPerformanceContentViewsAll(String fromDate,String toDate,String siteId){
    	List<AnalyticsWrapper.PerformanceContentData> listOfPerformanceContentWrapper = new List<AnalyticsWrapper.PerformanceContentData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
        List<Analytics_Top_Content__c> analyticsTopContent = new List<Analytics_Top_Content__c>();
		String queryString;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);		
        if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam3', siteId);
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Views__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c=:soqlParam3';
        }else if(hasFullAccess){
	    	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Views__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 And Content__r.title__c != null';
        }else{
		soqlParamMap.put('soqlParam3', UserContext.sitesIManageMap.keySet());
        	queryString = 'SELECT Content__c,Content__r.Type__c,Content__r.title__c,Content__r.Site__c,Content__r.Primary_Author__c,Views__c from Analytics_Top_Content__c '+ 
	    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Content__r.Site__c IN :soqlParam3';
        }			
		if(queryString != null){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			analyticsTopContent = (List<Analytics_Top_Content__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		}											
    	Map<Id, AnalyticsWrapper.PerformanceContentData> ContentCountMap = new Map<Id, AnalyticsWrapper.PerformanceContentData>();
    	for(Analytics_Top_Content__c contentRec : analyticsTopContent){
    		
    		if(ContentCountMap.get(contentRec.Content__c) == null){
    			ContentCountMap.put(contentRec.Content__c,new AnalyticsWrapper.PerformanceContentData());
    		}
    		AnalyticsWrapper.PerformanceContentData contentData = ContentCountMap.get(contentRec.Content__c);
    		contentData.name = contentRec.Content__r.title__c;
    		contentData.count = contentData.count + Integer.valueOf(((contentRec.Views__c == null) ? 0 : contentRec.Views__c));
    		if('Page'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/page/'+contentRec.Content__c;
    		}
    		if('Event'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/event/'+contentRec.Content__c;
    		}
    		if('Album'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRec.Content__r.Site__c+'/album/'+contentRec.Content__c;
    		}
    		if('BlogPost'.equalsIgnoreCase(contentRec.Content__r.Type__c)){
    			contentData.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRec.Content__r.Primary_Author__c+'/blog/'+contentRec.Content__c;
    		}
    		ContentCountMap.put(contentRec.Content__c, contentData);
    	}
    	listOfPerformanceContentWrapper = ContentCountMap.values();
    	listOfPerformanceContentWrapper.sort();
    	return listOfPerformanceContentWrapper;
    }
    
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsEndorsements(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceTopicsData> listOfPerformanceTopicsWrapper = new List<AnalyticsWrapper.PerformanceTopicsData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		String topTopicQuery = 'SELECT Topic_Id__c,Topic_Name__c, Endorsements__c from Analytics_Top_Topic__c ' +
			' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_Topic__c> analyticsTopTopics = (List<Analytics_Top_Topic__c>)SIMPESAPI.accessController().queryAsUser(topTopicQuery, soqlParamMap);
    	
    	
    	Map<Id, AnalyticsWrapper.PerformanceTopicsData> TopicsCountMap = new Map<Id, AnalyticsWrapper.PerformanceTopicsData>();
    	for(Analytics_Top_Topic__c topicRec : analyticsTopTopics){
    		
    		if(TopicsCountMap.get(topicRec.Topic_Id__c) == null){
    			TopicsCountMap.put(topicRec.Topic_Id__c,new AnalyticsWrapper.PerformanceTopicsData());
    		}
    		AnalyticsWrapper.PerformanceTopicsData topicData = TopicsCountMap.get(topicRec.Topic_Id__c);
    		topicData.name = topicRec.Topic_Name__c;
    		topicData.count = topicData.count + Integer.valueOf(((topicRec.Endorsements__c == null) ? 0 : topicRec.Endorsements__c));
    		Map<String, String> args = new Map<String, String>();
    		List<Object> topicDetailList = new List<Object>{ new Map<String, String>{'id'=>topicRec.Topic_Id__c,'name'=> topicRec.Topic_Name__c}};
		args.put('expertise', EncodingUtil.urlEncode(Json.serialize(topicDetailList),'UTF-8'));
		args.put('u', '/people');
    		topicData.url =  PageContext.getPageURL(Pages.app, args);
    		TopicsCountMap.put(topicRec.Topic_Id__c, topicData);
    	}
    	
    	listOfPerformanceTopicsWrapper = TopicsCountMap.values();
    	listOfPerformanceTopicsWrapper.sort();
    	return listOfPerformanceTopicsWrapper;
    }
    
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsExpertise(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceTopicsData> listOfPerformanceTopicsWrapper = new List<AnalyticsWrapper.PerformanceTopicsData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		String topTopicQuery = 'SELECT Topic_Id__c,Topic_Name__c, Expertise__c from Analytics_Top_Topic__c ' +
			' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_Topic__c> analyticsTopTopics = (List<Analytics_Top_Topic__c>)SIMPESAPI.accessController().queryAsUser(topTopicQuery, soqlParamMap);
    	
    	
    	Map<Id, AnalyticsWrapper.PerformanceTopicsData> TopicsCountMap = new Map<Id, AnalyticsWrapper.PerformanceTopicsData>();
    	for(Analytics_Top_Topic__c topicRec : analyticsTopTopics){
    		
    		if(TopicsCountMap.get(topicRec.Topic_Id__c) == null){
    			TopicsCountMap.put(topicRec.Topic_Id__c,new AnalyticsWrapper.PerformanceTopicsData());
    		}
    		AnalyticsWrapper.PerformanceTopicsData topicData = TopicsCountMap.get(topicRec.Topic_Id__c);
    		topicData.name = topicRec.Topic_Name__c;
    		Integer expertise = Integer.valueOf(((topicRec.Expertise__c == null) ? 0 : topicRec.Expertise__c));
    		if(expertise > topicData.count){
    			topicData.count = expertise;
    		}
    		Map<String, String> args = new Map<String, String>();
    		List<Object> topicDetailList = new List<Object>{ new Map<String, String>{'id'=>topicRec.Topic_Id__c,'name'=> topicRec.Topic_Name__c}};
		args.put('expertise', EncodingUtil.urlEncode(Json.serialize(topicDetailList),'UTF-8'));
		args.put('u', '/people');
    		topicData.url =  PageContext.getPageURL(Pages.app, args);
    		TopicsCountMap.put(topicRec.Topic_Id__c, topicData);
    	}
    	
    	listOfPerformanceTopicsWrapper = TopicsCountMap.values();
    	listOfPerformanceTopicsWrapper.sort();
    	return listOfPerformanceTopicsWrapper;
    }
    
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsFollowers(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceTopicsData> listOfPerformanceTopicsWrapper = new List<AnalyticsWrapper.PerformanceTopicsData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		String topTopicQuery = 'SELECT Topic_Id__c,Topic_Name__c, Followers__c from Analytics_Top_Topic__c ' +
			' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_Topic__c> analyticsTopTopics = (List<Analytics_Top_Topic__c>)SIMPESAPI.accessController().queryAsUser(topTopicQuery, soqlParamMap);
    	
    	
    	Map<Id, AnalyticsWrapper.PerformanceTopicsData> TopicsCountMap = new Map<Id, AnalyticsWrapper.PerformanceTopicsData>();
    	for(Analytics_Top_Topic__c topicRec : analyticsTopTopics){
    		
    		if(TopicsCountMap.get(topicRec.Topic_Id__c) == null){
    			TopicsCountMap.put(topicRec.Topic_Id__c,new AnalyticsWrapper.PerformanceTopicsData());
    		}
    		AnalyticsWrapper.PerformanceTopicsData topicData = TopicsCountMap.get(topicRec.Topic_Id__c);
    		topicData.name = topicRec.Topic_Name__c;
    		topicData.count = topicData.count + Integer.valueOf(((topicRec.Followers__c == null) ? 0 : topicRec.Followers__c));
    		topicData.url =  PageContext.getPageURL(Pages.app)+ '?u=/topic/' + topicRec.Topic_Id__c;
    		TopicsCountMap.put(topicRec.Topic_Id__c, topicData);
    	}
    	
    	listOfPerformanceTopicsWrapper = TopicsCountMap.values();
    	listOfPerformanceTopicsWrapper.sort();
    	
    	return listOfPerformanceTopicsWrapper;
    }
    
    public List<AnalyticsWrapper.PerformanceTopicsData> getPerformanceTopicsViews(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceTopicsData> listOfPerformanceTopicsWrapper = new List<AnalyticsWrapper.PerformanceTopicsData>();
    	fDate = setStringToDateFormat(fromDate);
        tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
		String topTopicQuery = 'SELECT Topic_Id__c,Topic_Name__c, Views__c from Analytics_Top_Topic__c ' +
			' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_Topic__c> analyticsTopTopics = (List<Analytics_Top_Topic__c>)SIMPESAPI.accessController().queryAsUser(topTopicQuery, soqlParamMap);
    	
    	
    	Map<Id, AnalyticsWrapper.PerformanceTopicsData> TopicsCountMap = new Map<Id, AnalyticsWrapper.PerformanceTopicsData>();
    	for(Analytics_Top_Topic__c topicRec : analyticsTopTopics){
    		
    		if(TopicsCountMap.get(topicRec.Topic_Id__c) == null){
    			TopicsCountMap.put(topicRec.Topic_Id__c,new AnalyticsWrapper.PerformanceTopicsData());
    		}
    		AnalyticsWrapper.PerformanceTopicsData topicData = TopicsCountMap.get(topicRec.Topic_Id__c);
    		topicData.name = topicRec.Topic_Name__c;
    		topicData.count = topicData.count + Integer.valueOf(((topicRec.Views__c == null) ? 0 : topicRec.Views__c));
    		topicData.url =  PageContext.getPageURL(Pages.app)+ '?u=/topic/' + topicRec.Topic_Id__c;
    		TopicsCountMap.put(topicRec.Topic_Id__c, topicData);
    	}
    	
    	listOfPerformanceTopicsWrapper = TopicsCountMap.values();
    	listOfPerformanceTopicsWrapper.sort();
    	return listOfPerformanceTopicsWrapper;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<AnalyticsWrapper.PerformanceSearchData> getPerformanceSearch(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSearchData> listOfPerformanceSearchWrapper = new List<AnalyticsWrapper.PerformanceSearchData>();
    	Date fDate = setStringToDateFormat(fromDate);
    	Date tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT Search_Text__c,Site__c, Search_Type__c,Date__c from Analytics_Top_Search__c '+
    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_Search__c> analyticsTopSearch = (List<Analytics_Top_Search__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<String, AnalyticsWrapper.PerformanceSearchData> SearchCountMap = new Map<String, AnalyticsWrapper.PerformanceSearchData>();
    	for(Analytics_Top_Search__c searchRec : analyticsTopSearch){
	    		if(SearchCountMap.get(searchRec.Search_Text__c) == null){
	    			SearchCountMap.put(searchRec.Search_Text__c,new AnalyticsWrapper.PerformanceSearchData());
	    		}
	    		AnalyticsWrapper.PerformanceSearchData searchData = SearchCountMap.get(searchRec.Search_Text__c);
	    		searchData.name = searchRec.Search_Text__c;
	    		searchData.count = searchData.count+1;
	    		searchData.url =  PageContext.getPageURL(Pages.SearchResults) + '?term=' + searchRec.Search_Text__c;
	    		SearchCountMap.put(searchRec.Search_Text__c, searchData);
    	}
    	
    	listOfPerformanceSearchWrapper = SearchCountMap.values();
    	listOfPerformanceSearchWrapper.sort();
    	return listOfPerformanceSearchWrapper;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<AnalyticsWrapper.PerformanceSearchData> getPerformanceZeroSearchResults(String fromDate,String toDate){
    	List<AnalyticsWrapper.PerformanceSearchData> listOfPerformanceSearchWrapper = new List<AnalyticsWrapper.PerformanceSearchData>();
    	Date fDate = setStringToDateFormat(fromDate);
    	Date tDate = setStringToDateFormat(toDate);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fDate);
		soqlParamMap.put('soqlParam2', tDate);
    	String queryStr = 'SELECT Search_Text__c,Site__c, Search_Type__c,Date__c, Search_Results_Count__c from Analytics_Top_Search__c '+
    															' where Date__c>= :soqlParam1 AND Date__c<= :soqlParam2 AND Search_Results_Count__c = 0 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Analytics_Top_Search__c> analyticsTopSearch = (List<Analytics_Top_Search__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	Map<String, AnalyticsWrapper.PerformanceSearchData> SearchCountMap = new Map<String, AnalyticsWrapper.PerformanceSearchData>();
    	for(Analytics_Top_Search__c searchRec : analyticsTopSearch){
	    		if(SearchCountMap.get(searchRec.Search_Text__c) == null){
	    			SearchCountMap.put(searchRec.Search_Text__c,new AnalyticsWrapper.PerformanceSearchData());
	    		}
	    		AnalyticsWrapper.PerformanceSearchData searchData = SearchCountMap.get(searchRec.Search_Text__c);
	    		searchData.name = searchRec.Search_Text__c;
	    		searchData.count = searchData.count+1;
	    		searchData.url =  PageContext.getPageURL(Pages.app) + '?u=/search&term=' + EncodingUtil.urlEncode(searchRec.Search_Text__c, 'UTF-8');
	    		SearchCountMap.put(searchRec.Search_Text__c, searchData);
    	}
    	
    	listOfPerformanceSearchWrapper = SearchCountMap.values();
    	listOfPerformanceSearchWrapper.sort();
    	return listOfPerformanceSearchWrapper;
    }
    
    private Date setStringToDateFormat(String myDate) {
	  String[] strDate = myDate.split('-');
	  Integer intDate = integer.valueOf(strDate[2]);
	  Integer intMonth = integer.valueOf(strDate[1]);
	  Integer intYear = integer.valueOf(strDate[0]);
	  Date d = Date.newInstance(intYear, intMonth, intDate);
	  return d;
  	}
  	
  	private void updateAnalyticsPerformanceWrapperList(
  					List<AnalyticsWrapper.PerformancePeopleData> performancePeopleWrapperList, Set<String> excludeIdSet){
  		// Check if the number of records are lesser than the recordLimit then
    	// fetch people other tahn the covered above and make records.
    	if(performancePeopleWrapperList.size() < recordLimit){
    		Integer recordCount = (recordLimit - performancePeopleWrapperList.size());
    		List<People__c> peopleList = getPeopleInSimpplr(excludeIdSet, recordCount);
			AnalyticsWrapper.PerformancePeopleData performancePeopleData = null;
	    		
			for (People__c peopleObj : peopleList){
				performancePeopleData = new AnalyticsWrapper.PerformancePeopleData();
				performancePeopleData.name = peopleObj.Full_Name__c;
	    		performancePeopleData.count = 0;
	    		performancePeopleData.isActive = peopleObj.User__r.IsActive;
	    		performancePeopleData.url =  PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.id;
	    		
	    		performancePeopleWrapperList.add(performancePeopleData);
			}
    	}
  	}
  	
  	private List<People__c> getPeopleInSimpplr(Set<String> excludeIdSet, Integer recordLimit){
   	 	String packageName = SimpplrContext.packageName;
   	 	String peopleQuery = 'SELECT id, Full_Name__c, User__r.IsActive FROM People__c WHERE User__r.IsActive=true AND User__r.UserType=\'Standard\'';
    	if(!Test.isRunningTest() && String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false){
			peopleQuery = peopleQuery + ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		
		peopleQuery = peopleQuery + ' AND Id NOT IN :excludeIdSet ORDER BY Full_Name__c ASC LIMIT ' + recordLimit;
		
    	List<People__c> peopleInSimpplr = Database.query(peopleQuery);
    	
    	return peopleInSimpplr;
    }

	/**
	 * @description This method is used to save csv download url and other details from AWS
	 * @param requestDataMap
	 * @return `String`
	*/
	public String saveCsvDownloadDetails(Map<String, Object> requestDataMap) {
		logger.logDebug('AnalyticsDao.saveCsvDownloadDetails() '+ requestDataMap);
		String insertedObjId = '';
		String csvUrl = requestDataMap != null && requestDataMap.containsKey('preSignedUrl') && requestDataMap.get('preSignedUrl') != null ? (String) requestDataMap.get('preSignedUrl') : null;
		String contentId = requestDataMap != null && requestDataMap.containsKey('contentId') && requestDataMap.get('contentId') != null ? (String) requestDataMap.get('contentId') : null;
		String peopleId = requestDataMap != null && requestDataMap.containsKey('peopleId') && requestDataMap.get('peopleId') != null ? (String) requestDataMap.get('peopleId') : null;
		Datetime requestDateTime = requestDataMap != null && requestDataMap.containsKey('requestDateTime') && requestDataMap.get('requestDateTime') != null ? Datetime.valueOf(((String)requestDataMap.get('requestDateTime')).replace('T',' ')) : null;
		String widgetTab = requestDataMap != null && requestDataMap.containsKey('widgetTab') && requestDataMap.get('widgetTab') != null ? (String) requestDataMap.get('widgetTab') : null;
		String widgetTitle = requestDataMap != null && requestDataMap.containsKey('widgetTitle') && requestDataMap.get('widgetTitle') != null ? (String) requestDataMap.get('widgetTitle') : null;
		try{
			Csv_Download_Request__c csvDownloadRequestObj = new Csv_Download_Request__c();
			List<Schema.SObjectField> listOfColumnsToBeAdded = new List<Schema.SObjectField>{Csv_Download_Request__c.Csv_Url__c,
																							Csv_Download_Request__c.Content__c,
																							Csv_Download_Request__c.People__c,
																							Csv_Download_Request__c.Request_DateTime__c,
																							Csv_Download_Request__c.Widget_Tab__c,
																							Csv_Download_Request__c.Widget_Title__c};
			if (String.isNotBlank(csvUrl)){
				csvDownloadRequestObj.Csv_Url__c = csvUrl;
				csvDownloadRequestObj.Content__c = contentId;
				csvDownloadRequestObj.People__c = peopleId;
				csvDownloadRequestObj.Request_DateTime__c = requestDateTime;
				csvDownloadRequestObj.Widget_Tab__c = widgetTab;
				csvDownloadRequestObj.Widget_Title__c = widgetTitle;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    			sObject obj = SIMPESAPI.accessController().insertAsUser(csvDownloadRequestObj,listOfColumnsToBeAdded);
    			csvDownloadRequestObj = (Csv_Download_Request__c)obj;
    			insertedObjId = csvDownloadRequestObj.Id;
			} 
		}catch(Exception e){
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return insertedObjId;
    }
    
}