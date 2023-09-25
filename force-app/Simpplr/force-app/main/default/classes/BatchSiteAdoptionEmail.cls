public with sharing class BatchSiteAdoptionEmail implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful {

	public final String KEY_ORG_MONTHLY_INTRO = 'email.notification.analytics.org.monthly.intro';
	public final String KEY_MONTHLY_DIGEST_THIS_MONTH_YOUR = 'email.notification.sites.manager.monthly.digest.this_month_your';
	public final String KEY_SENT_TO = 'email.common.footer.sent_to';
	public final String KEY_POSTS_REPLIES = 'email.common.posts_replies';
	public final String KEY_LIKES = 'email.common.likes';
	public final String KEY_SHARES = 'email.common.shares';
	public final String KEY_SITE_ANALYTICS_BTN = 'email.common.site_anaytics.button';
	public final String KEY_MONTHLY_DIGEST_OTHER_SITES = 'email.notification.sites.manager.monthly.digest.other_sites';
	public final String KEY_SITE_LBL = 'email.common.label.site';
	public final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';
	public final String KEY_FOOTER_COPYRIGHT = 'email.common.footer.copyright';
	public final String KEY_FOOTER_POWERED_BY = 'email.common.footer.powered_by';
	public final String KEY_TOTAL_CONTENT_VIEWS = 'email.common.total_content_views';
	public final String KEY_MONTHLY_DIGEST_SUBJECT = 'email.notification.sites.manager.monthly.digest.subject';
	public final String KEY_SITE = 'email.common.site';
	public final String KEY_DEACTIVATE = 'email.common.deactivate';
	public final String KEY_LOW_ACTIVITY_SITES = 'email.low_activity_sites';
	public final String KEY_LOW_ACTIVITY_SITES_HELP = 'email.low_activity_sites_help';

	private Exception exceptionDetailsObj;
	String packageName;
	private String context;
	private Boolean isSendOnlyToMe;
	public Boolean callChainBatch ; 
	public Map<String,Set<String>> peopleToSitesHeManageMap;
	public Map<String,String> siteIdToChatterGroupMap;
	
	public BatchSiteAdoptionEmail(String context, Boolean callChainBatchArg) {
		this.packageName = SimpplrContext.packageName;
		this.isSendOnlyToMe = false;
		this.context = context;
		this.callChainBatch = callChainBatchArg;
		this.peopleToSitesHeManageMap = populatePeopleToSitesHeManageMap();
	}
	
	public BatchSiteAdoptionEmail(String context,Boolean isSendOnlyToMe,Boolean callChainBatchArg) {
		this.packageName = SimpplrContext.packageName;
		this.isSendOnlyToMe = isSendOnlyToMe;
		this.context = context;
		this.callChainBatch = callChainBatchArg;
		this.peopleToSitesHeManageMap = populatePeopleToSitesHeManageMap();
	}

	private void initLangKeyValueMap(List<People__c> PeopleList) {
        List<String> localeList = new List<String>();
		localeList.add(UserContext.languageLocaleKey);
		for(People__c peopleObj : PeopleList){
			localeList.add(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey));
		}
		LocaleContext.getAllLabelMap('EmailNotifications', localeList);
    }
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String loggedInUserId = UserInfo.getUserId();
		String queryString = 'SELECT Id, user__r.languagelocalekey, user__r.timeZonesidkey, User__r.Id, User__r.Profile.PermissionsModifyAllData, Can_Access_Analytics__c,User__r.profile.PermissionsModerateChatter,App_Moderation_Permission__c, user__r.username, Segment__r.Branding_JSON__c, '+
				'Segment__c, Segment__r.Branding_Logo__c FROM People__c WHERE '+ 
				'Id IN (SELECT People__c FROM People_Preference__c WHERE Email_Site_Analytics_Frequency__c='+
    			'\'monthly\') ';
		
		if ('toSiteManagers'.equalsIgnoreCase(context)) {
			Set<String> siteManagersSet = peopleToSitesHeManageMap != NULL ? peopleToSitesHeManageMap.keySet() : 
					new Set<String>();
					
			queryString += 'AND App_Moderation_Permission__c = \'No\' AND Can_Access_Analytics__c = false AND '+
    			'User__r.isActive=true AND User__r.UserType=\'Standard\' AND User__c IN : siteManagersSet ' ;
    					
		} else if ('toAppManagers'.equalsIgnoreCase(context)) {
			queryString += 'AND (App_Moderation_Permission__c = \'Yes\' OR Can_Access_Analytics__c = True) AND '+
    			' User__r.isActive=true AND User__r.UserType=\'Standard\' ';
		} 
    	
        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
    		queryString = queryString + ' AND User__c IN (select userid from UserPackageLicense where '+
    				'PackageLicense.NamespacePrefix =: packageName) ';
    	}
    	if(isSendOnlyToMe) {
    		queryString = queryString + ' And User__c=: loggedInUserId ';
		}    
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<People__C> peopleList){
    	try{
			initLangKeyValueMap(peopleList);

    		List<Messaging.SingleEmailMessage> adoptionEmailList = new List<Messaging.SingleEmailMessage>();
			Boolean managingSingleSite;	
			Date previousMonthStart = Date.today().addMonths(-1).toStartOfMonth();
			DateTime previousMonthStartDateTime = DateTime.newInstance(previousMonthStart.year(), previousMonthStart.month(), previousMonthStart.day());
			
			Date previousMonthEnd = Date.today().toStartOfMonth().addDays(-1);
			DateTime previousMonthEndDateTime = DateTime.newInstance(previousMonthEnd.year(), previousMonthEnd.month(), previousMonthEnd.day());
			Map<Id, Set<String>> peopleIdVsPrivateSiteIdsSetMap = new Map<Id, Set<String>>();
			List<AnalyticsWrapper.ViewsOverTime> allLowActivitySites = null;
			Map<Id, List<AnalyticsWrapper.ViewsOverTime>> peopleIdVsLowActivitySitesMap = new Map<Id, List<AnalyticsWrapper.ViewsOverTime>>();
			Map<String, String> siteIdVsImageUrlMap = null;
			if(Test.isRunningTest() == false && 'toAppManagers'.equalsIgnoreCase(context)){
				Map<String, Object> soqlParamMap1 = new Map<String, Object>();
				soqlParamMap1.put('soqlParam1', peopleList); // here peopleList contains only app managers
				String siteRoleQuery = 'SELECT Site__c, site__r.site_type__c, Is_Member__c, Id, Is_deleted__c, People__c FROM Site_Role__c where site__r.site_type__c!=\'Public\' And Is_Member__c = true And Is_deleted__c = false And People__c IN:soqlParam1 And Site__r.Is_Active__c=true And Site__r.Is_Deleted__c = false';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Site_Role__c> listOfsiteRoles = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUser(siteRoleQuery, soqlParamMap1);
				
				if (!listOfsiteRoles.isEmpty()) {
					for (Site_Role__c siteRoleObj: listOfsiteRoles) {
						if(peopleIdVsPrivateSiteIdsSetMap.containsKey(siteRoleObj.People__c)){
							Set<String> tempSet = peopleIdVsPrivateSiteIdsSetMap.get(siteRoleObj.People__c);
							tempSet.add(siteRoleObj.Site__c);
							peopleIdVsPrivateSiteIdsSetMap.put(siteRoleObj.People__c, tempSet);
						}else{
							peopleIdVsPrivateSiteIdsSetMap.put(siteRoleObj.People__c, new Set<String>{siteRoleObj.Site__c});
						}
					}
				}
				ExternalAnalyticsService externalAnalyticsServiceObj = new ExternalAnalyticsService();
				Map<String, Object> requestParamMap = new Map<String, Object>{
					'from' => date.today().addDays(-90).format(), // Dummy dates as request param because API will return low activity sites for last 90 days
					'to' => date.today().format(),
					'size' => 10
				};
				allLowActivitySites = (List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestParamMap, 'getLowActivitySites', 10);
				for(People__c people : peopleList ){ 
					List<AnalyticsWrapper.ViewsOverTime> lowActivitySites = null;
					if(people.User__r.Profile.PermissionsModifyAllData != null && people.User__r.Profile.PermissionsModifyAllData){
						requestParamMap.put('nonPublicSitesAccessibleSet',null);
					} else {
						Set<String> nonPublicSitesAccessibleSet = new Set<String>();
						if(peopleIdVsPrivateSiteIdsSetMap.containsKey(people.Id)){
							nonPublicSitesAccessibleSet = peopleIdVsPrivateSiteIdsSetMap.get(people.Id);
						}
						requestParamMap.put('nonPublicSitesAccessibleSet', nonPublicSitesAccessibleSet);
					}
					lowActivitySites = (List<AnalyticsWrapper.ViewsOverTime>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestParamMap, 'getLowActivitySites', 10);
					peopleIdVsLowActivitySitesMap.put(people.Id, lowActivitySites);
				}
					
				if(allLowActivitySites != null && !allLowActivitySites.isEmpty()){
					siteIdVsImageUrlMap = getSiteIdNTitleImageUrlMap(allLowActivitySites);
				}
			}
			String subject = '';
			for(People__c people : peopleList ){ 
				String userLanguage = Utility.getSimpplrLanguageLocaleKey(people.User__r.languagelocalekey);
				subject = LocaleContext.getLabel(userLanguage, KEY_MONTHLY_DIGEST_SUBJECT).replace('{{appName}}', SimpplrContext.applicationName)  + ' - ' + LocaleContext.getLocalisedDateAsMMMMYYYY(previousMonthStartDateTime, userLanguage);

				managingSingleSite = true;
				NotificationHelper.BrandingInfo brandingInfo = EmailUtility.getBrandingInfo4People(people);
				Set<String> siteIdSet = new Set<String>();
	    		Map<Id, String> siteIdNPublicUrlMap; 
				
				String lowActivitySiteHtml = '';
				if(peopleIdVsLowActivitySitesMap != null && peopleIdVsLowActivitySitesMap.containsKey(people.Id) && peopleIdVsLowActivitySitesMap.get(people.Id) != null){
					lowActivitySiteHtml = getLowActivitySiteHtml(peopleIdVsLowActivitySitesMap.get(people.Id), brandingInfo, siteIdVsImageUrlMap, userLanguage);
				} 

	    		List<AggregateResult> otherTopSitesList = new List<AggregateResult>();// Rest 4 sites
				AggregateResult topSite ;
				Map<String,Integer> siteToShareCountMap = new Map<String,Integer>();

				List<AggregateResult> topSitesForUserList = getTopSitesForUserList(context,people.user__c);
				
				if (topSitesForUserList == NULL || topSitesForUserList.size() == 0) {
					continue; 
				}

				for (AggregateResult siteObj : topSitesForUserList) {
					siteIdSet.add(String.valueOf(siteObj.get('site')));
				}
				siteToShareCountMap = getSiteToShareCountMap(siteIdSet);								
				topSite = topSitesForUserList[0];
				
				if (topSitesForUserList.size() > 1) {
					managingSingleSite = false;
					otherTopSitesList.addAll(topSitesForUserList);
					otherTopSitesList.remove(0);
				}
				
				siteIdNPublicUrlMap = getSiteIdNPublicUrlMap(topSitesForUserList);		
				List<String> formatterList = new List<String>();
				String adoptionEmailBody = '';
				String shareCountOfTopSite = (siteToShareCountMap != NULL && 
						siteToShareCountMap.get(String.valueOf(topSite.get('site'))) != NULL) ? String.valueOf(
						siteToShareCountMap.get(String.valueOf(topSite.get('site')))):'0';
				String contentInfoString = getContentInfoString(topSite,shareCountOfTopSite, userLanguage);
				String footerString = getFooterString(people,brandingInfo.general_primaryColor, userLanguage);
				String otherTopSitesString = managingSingleSite ? '' : getOtherSitesBody(otherTopSitesList,
						siteIdNPublicUrlMap,brandingInfo.general_primaryColor, userLanguage);
								
				formatterList.clear();
				formatterList.add(LocaleContext.getLabel(userLanguage, KEY_ORG_MONTHLY_INTRO).replace('{{appName}}', SimpplrContext.applicationName)); //{0}
				formatterList.add(brandingInfo.logo_url);//{1}

				String dateNow = LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(), userLanguage);
				formatterList.add(dateNow); //{2}
				formatterList.add(SimpplrContext.applicationName);//{3}

				String startDate = LocaleContext.getLocalisedDateAsDDMMMM(previousMonthStartDateTime, userLanguage);
				String endDate = LocaleContext.getLocalisedDateAsDDMMMMYYYY(previousMonthEndDateTime, userLanguage);
				formatterList.add(startDate + ' - ' + endDate); //{4}
				formatterList.add(siteIdNPublicUrlMap.get(String.valueOf(topSite.get('site')))); //{5}
				formatterList.add(managingSingleSite ? '' : String.valueOf(topSite.get('siteName')));//{6}
				formatterList.add(String.valueOf(Integer.valueOf(topSite.get('contentViews')))); //{7}
				formatterList.add(contentInfoString);//{8} with/withoutFeed
				formatterList.add(SimpplrContext.salesforceBaseUrl + Page.app.getUrl() + '?u=/manage/sites/' + String.valueOf(topSite.get('site'))  + '/analytics'+'&utm_medium=email&utm_source=monthly_report&utm_content='+String.valueOf(topSite.get('site')));
				formatterList.add(otherTopSitesString + lowActivitySiteHtml); //{10} other sites you manage
				formatterList.add(footerString);//{11} footer
				//branding 
				formatterList.add(brandingInfo.general_primaryColor);//{12} footer
				// header background // 13
		    	if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
					formatterList.add('000000');// 13
				} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
					formatterList.add(brandingInfo.general_primaryColor);// 13
				} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
					formatterList.add('ffffff');// 13
				} else {
					formatterList.add(brandingInfo.header_backgroundColor);
				}
				formatterList.add(brandingInfo.header_iconColor);//14
				formatterList.add(getMonthlyReportString (managingSingleSite,String.valueOf(topSite.get('siteName')), userLanguage));//{15}
				formatterList.add(getStyleString());//{16}
				formatterList.add(LocaleContext.getLabel(userLanguage, KEY_TOTAL_CONTENT_VIEWS));//{17}
				formatterList.add(LocaleContext.getLabel(userLanguage, KEY_SITE_ANALYTICS_BTN));//{18}
				
				adoptionEmailBody = EmailUtility.format(siteAdoptionEmailTemplateMap.get(
						'emailBodyWithHeaderFooter'), formatterList);
				
				if(String.isNotBlank(adoptionEmailBody)) {
		    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
					singleMail.setTargetObjectId(people.User__c);
					singleMail.setSubject(subject);
					if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
						singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
					}
					if(SimpplrContext.DeeplinkingEnabled) {
						adoptionEmailBody = EmailUtility.deeplinkedMailBody(adoptionEmailBody);
					}
					
					singleMail.setHtmlBody(adoptionEmailBody);
					singleMail.setCharset('UTF-8');
					singleMail.setUseSignature(false);
					singleMail.setSaveAsActivity(false);			
					adoptionEmailList.add(singleMail);
	        	} 
	        	
    		}
    		
	        if(adoptionEmailList.size() > 0) {
	        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(adoptionEmailList);
	        }
	        
    	} catch(Exception ex) {
			exceptionDetailsObj =  ex;
    		throw ex;
		}		
    }

	private String getLowActivitySiteHtml(List<AnalyticsWrapper.ViewsOverTime> lowActivitySites,
							 NotificationHelper.BrandingInfo brandingInfo,
							  Map<String, String> siteIdVsImageUrlMap, String userLanguage){
		
		String contentString = '';
		List<String> formatterList = null;

		/**
			{0} => site image src url
			{1} => Site Name
			{2} => theme color (#1abc9c)
			{3} => View Site Analytics
			{4} => theme color (#1abc9c)
			{5} => Deactivate
			{6} => view analytics link
			{7} => site deactivate link
			{8} => site URL
		 */

		for (AnalyticsWrapper.ViewsOverTime viewsOverTimeObj : lowActivitySites){
			if(viewsOverTimeObj.hasAccess == true){
				formatterList = new List<String>();
				
				formatterList.add(siteIdVsImageUrlMap.get(viewsOverTimeObj.id)); // {0}
				formatterList.add(viewsOverTimeObj.name); //{1}
				formatterList.add(brandingInfo.general_primaryColor); //{2}
				formatterList.add(LocaleContext.getLabel(userLanguage, KEY_SITE_ANALYTICS_BTN)); //{3}
				formatterList.add(brandingInfo.general_primaryColor); //{4}

				formatterList.add(LocaleContext.getLabel(userLanguage, KEY_DEACTIVATE)); //{5}
				formatterList.add(SimpplrContext.salesforceBaseUrl + Page.app.getUrl() + '?u=/manage/sites/' + viewsOverTimeObj.id  + '/analytics'+'&utm_medium=email&utm_source=monthly_report&utm_content='+viewsOverTimeObj.id); //{6}
				formatterList.add(SimpplrContext.salesforceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + viewsOverTimeObj.id + '&pageToRedirect=manageDeactivatedSites'); //{7}
				formatterList.add(viewsOverTimeObj.url); //{8}
				
				contentString += EmailUtility.format(siteAdoptionEmailTemplateMap.get(
					'lowActivitySitesItemList'), formatterList);
			}
		}

		/**
			{0} => Low activity sites
			{1} => Some sites and their content have very low views over the last 90 days. Consider deactivating these sites to help keep resources up-to-date and relevant for employees.
			{2} => Site
			{3} => Total Content Views
			{4} => lowActivitySitesList.html

		 */

		formatterList = new List<String>();			
		 
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_LOW_ACTIVITY_SITES)); //{0}
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_LOW_ACTIVITY_SITES_HELP)); //{1}
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_SITE)); //{2}
		formatterList.add(''); //{3}
		formatterList.add(contentString); //{4}

		contentString = EmailUtility.format(siteAdoptionEmailTemplateMap.get(
			'lowActivitySitesBody'), formatterList);

		return contentString;
	}

	private Map<String, String> getSiteIdNTitleImageUrlMap(List<AnalyticsWrapper.ViewsOverTime> lowActivitySites) {
    	Map<String, String> siteIdNPublicUrlMap = new Map<String, String>();
    	
		Set<String> siteIdSet = new Set<String>();
		Map<Id, Id> siteIdAndCVIdMap = new Map<Id, Id>();
		for(AnalyticsWrapper.ViewsOverTime siteAnalyticsObj : lowActivitySites) {
			siteIdSet.add(siteAnalyticsObj.id);
		}	

		SiteDao siteDaoObj = new SiteDao();
		Map<Id, Simpplr_Site__c> simpplrSiteDetailsMap = siteDaoObj.getSiteDetails(siteIdSet);

    	for(AnalyticsWrapper.ViewsOverTime siteAnalyticsObj : lowActivitySites) {
    		
    		if(!siteIdNPublicUrlMap.containsKey(siteAnalyticsObj.id)){
				String cvId = simpplrSiteDetailsMap.get(siteAnalyticsObj.id).Title_Content_Version__c;
				
				if(String.isBlank(cvId)){
					siteIdNPublicUrlMap.put(siteAnalyticsObj.id, EmailTemplateService.siteDefaultIconUrl);

				} else {
					siteIdAndCVIdMap.put(siteAnalyticsObj.id, cvId);
				}
    		}
    	}
		Map<Id, String> cvIdNPublicUrlMap;
    	if(siteIdAndCVIdMap.size()>0){
    		cvIdNPublicUrlMap = FileContentProvider.generateEmbedPublicUrl(siteIdAndCVIdMap.values());
    	
	    	for(Id siteId : siteIdAndCVIdMap.keySet()){
				if(String.isBlank(cvIdNPublicUrlMap.get(siteIdAndCVIdMap.get(siteId)))){
					siteIdNPublicUrlMap.put(siteId,EmailTemplateService.siteDefaultIconUrl);
				} else {
		    		siteIdNPublicUrlMap.put(siteId,cvIdNPublicUrlMap.get(siteIdAndCVIdMap.get(siteId)));
				}
	    	}
    	}
    	
    	return siteIdNPublicUrlMap;
    }
    
    public void finish(Database.BatchableContext BC){
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		
		if(!(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0)) {
			Utility.sendExceptionEmail('BatchSiteAdoptionEmail', exceptionDetailsObj);
		}
		if (callChainBatch) {
			BatchSiteAdoptionEmail siteAdoptionEmailForSiteManagers = new BatchSiteAdoptionEmail('toSiteManagers',
					false, false);		
			Database.executeBatch(siteAdoptionEmailForSiteManagers,50);
		}		
    	
    }
    
    private Set<String> getActiveChatterGroups() {
		Set<String> activeChatterGroups = new Set<String>();
		
		for (Simpplr_Site__c siteObj : [SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c WHERE 
				Is_Active__c = true AND Show_In_Simpplr__c = true]) {
			activeChatterGroups.add(siteObj.Chatter_Group_Id__c);
		}
		return activeChatterGroups;	
    }	
    
    private Map<Id, String> getSiteIdNPublicUrlMap(List<AggregateResult> siteAnalyticsList) {
    	Map<Id, String> siteIdNPublicUrlMap = new Map<Id, String>();
    	Map<Id, Id> siteIdAndCVIdMap = new Map<Id, Id>();
    	
    	for(AggregateResult siteAnalyticsObj : siteAnalyticsList) {
    		
    		if(!siteIdNPublicUrlMap.containsKey(String.valueOf(siteAnalyticsObj.get('site')))){
				if(String.isNotBlank(String.valueOf(siteAnalyticsObj.get('titleImage')))) {
					siteIdAndCVIdMap.put(String.valueOf(siteAnalyticsObj.get('site')), 
							String.valueOf(siteAnalyticsObj.get('titleImage')));
				} else {
					siteIdNPublicUrlMap.put(String.valueOf(siteAnalyticsObj.get('site')),EmailTemplateService.siteDefaultIconUrl);
				}
    		}
    	}
    	Map<Id, String> cvIdNPublicUrlMap;
    	if(siteIdAndCVIdMap.size()>0){
    		cvIdNPublicUrlMap = FileContentProvider.generateEmbedPublicUrl(siteIdAndCVIdMap.values());
    	
	    	for(Id siteId : siteIdAndCVIdMap.keySet()){
				if(String.isBlank(cvIdNPublicUrlMap.get(siteIdAndCVIdMap.get(siteId)))){
					siteIdNPublicUrlMap.put(siteId,EmailTemplateService.siteDefaultIconUrl);
				} else {
		    		siteIdNPublicUrlMap.put(siteId,cvIdNPublicUrlMap.get(siteIdAndCVIdMap.get(siteId)));
				}
	    	}
    	}
    	
    	return siteIdNPublicUrlMap;
    }
    
    private String getContentInfoString(AggregateResult topSite,String shareCount, String userLanguage) {
    	String contentString = '';
		List<String> formatterList = new List<String>();			
		formatterList.clear();
				
		if(SimpplrContext.isFeedEnabled){
			formatterList.add(String.valueOf(Integer.valueOf(topSite.get('posts')) + 
					Integer.valueOf(topSite.get('replies')))); // {0}
			formatterList.add(String.valueOf(Integer.valueOf(topSite.get('likes')))); //{1}
			formatterList.add(String.valueOf(shareCount)); //{2}
			formatterList.add(LocaleContext.getLabel(userLanguage, KEY_POSTS_REPLIES)); //{3}
			formatterList.add(LocaleContext.getLabel(userLanguage, KEY_LIKES)); //{4}
			formatterList.add(LocaleContext.getLabel(userLanguage, KEY_SHARES)); //{5}

			contentString = EmailUtility.format(siteAdoptionEmailTemplateMap.get(
					'contentWithFeedEnabled'),formatterList);
		} else {
			formatterList.add(String.valueOf(Integer.valueOf(topSite.get('likes')))); //{0}
			formatterList.add(LocaleContext.getLabel(userLanguage, KEY_LIKES)); //{1}
			
			contentString = EmailUtility.format(siteAdoptionEmailTemplateMap.get(
					'contentWithFeedDisabled'),formatterList);	
		} 
		return contentString;
    }	
    
    private String getOtherSitesBody(List<AggregateResult> otherTopSitesList, Map<Id,String> siteIdNPublicUrlMap,
    		String primaryColor, String userLanguage){
    	String otherSitesBody = '';
		List<String> formatterList = new List<String>();			
		formatterList.clear();
		String otherSitesItemStr = getOtherSitesItemBody(otherTopSitesList, siteIdNPublicUrlMap, primaryColor, userLanguage);
		formatterList.add(otherSitesItemStr);	//{0}
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_MONTHLY_DIGEST_OTHER_SITES));	//{1}	
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_SITE_LBL));	//{2}	
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_TOTAL_CONTENT_VIEWS));	//{3}	

		otherSitesBody = EmailUtility.format(siteAdoptionEmailTemplateMap.get(
					'OtherSitesYouManage'),formatterList);
		
		return otherSitesBody;
    }	
    
    private String getOtherSitesItemBody(List<AggregateResult> otherTopSitesList, Map<Id,String> 
    		siteIdNPublicUrlMap, String primaryColor, String userLanguage){
    	String otherSitesBody = '';
		List<String> formatterList = new List<String>();			
		
		for (AggregateResult siteInfo : otherTopSitesList ) {
			String siteInfoStr = '';
			formatterList.clear();
				
			formatterList.add(String.valueOf(siteInfo.get('siteName'))); //{0}
			formatterList.add(SimpplrContext.salesforceBaseUrl + Page.app.getUrl() + '?u=/manage/sites/' + String.valueOf(siteInfo.get('site'))  + '/analytics'+'&utm_medium=email&utm_source=monthly_report&utm_content='+String.valueOf(siteInfo.get('site')));//{1}
			formatterList.add(String.valueOf(Integer.valueOf(siteInfo.get('contentViews'))));//{2}
			formatterList.add(siteIdNPublicUrlMap.get(String.valueOf(siteInfo.get('site'))));//{3}
			formatterList.add(primaryColor);//{4}
			formatterList.add(LocaleContext.getLabel(userLanguage, KEY_SITE_ANALYTICS_BTN));//{5}
			
			siteInfoStr = EmailUtility.format(siteAdoptionEmailTemplateMap.get(
					'otherSitesYouManageItem'),formatterList);
			otherSitesBody += siteInfoStr;		
		}
		
		return otherSitesBody;
    }	
    
    private String getFooterString(people__c people, String primaryBrandingColor, String userLanguage) {
    	String footerString = '';
		List<String> formatterList = new List<String>();			
		formatterList.clear();
		formatterList.add('' + SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + 
				'?userId=' + people.user__c +'&pageToRedirect='+Pages.MySettingsEmail+'&origin=nde');//0

		String footerSettingsString = LocaleContext.getLabel(userLanguage, KEY_FOOTER_SETTINGS).replace('{{appName}}', SimpplrContext.applicationName);	
		formatterList.add(footerSettingsString);//1
		formatterList.add('' + SimpplrContext.salesforceBaseUrl  + Page.app.getUrl()+'?u=/people/'+ people.id +'/?origin=nde'); //{2}
		formatterList.add(people.User__r.UserName); //{3}
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_FOOTER_COPYRIGHT).replace('{{year}}', String.valueOf(Date.today().year())));//{4} 
		formatterList.add('http://www.simpplr.com');//5
		formatterList.add(primaryBrandingColor);//6
		formatterList.add(LocaleContext.getLabel(userLanguage, KEY_FOOTER_POWERED_BY));//7
		formatterList.add(EmailUtility.getMobilePromotionFooterDiv(userLanguage, people.id));  // 8 - mobile promotion footer

		footerString = EmailUtility.format(siteAdoptionEmailTemplateMap.get('footer'),formatterList);
		
		return footerString;
    }		
    
    private Map<String,Integer> getSiteToShareCountMap(Set<String> siteIdSet){
    	Map<String,Integer> siteToShareCountMap = new Map<String,Integer>();
    	Map<String, Object> soqlParamMap = new Map<String, Object>();
    	soqlParamMap.put('soqlParam1', siteIdSet);
    	String feedCountQuery = 'SELECT id, Site__c, Shares__c FROM Analytics_Feed_Count__c ' +
    		' WHERE Site__c IN : soqlParam1 AND Date__c = LAST_MONTH AND Shares__c > 0';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    	List<Analytics_Feed_Count__c> feedCountList = (List<Analytics_Feed_Count__c>)SIMPESAPI.accessController().queryAsUser(feedCountQuery, soqlParamMap);
    	
    	for (Analytics_Feed_Count__c feedCountObj : feedCountList) {
    		
    		if (!siteToShareCountMap.containsKey(feedCountObj.site__c)) {
    			siteToShareCountMap.put(feedCountObj.site__c,0);
    		}
    		siteToShareCountMap.put(feedCountObj.site__c,Integer.valueOf(siteToShareCountMap.get(
    				feedCountObj.site__c)+ feedCountObj.Shares__c));
    	}
    	
    	return 	siteToShareCountMap; 
    }
    
    private String getMonthlyReportString (Boolean managingSingleSite, String siteName, String userLanguage) {
    	String monthlytext = managingSingleSite ? siteName +'\'s Monthly Report&hellip;' : 
    							LocaleContext.getLabel(userLanguage, KEY_MONTHLY_DIGEST_THIS_MONTH_YOUR);
    	String defaultStr = '<td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 18px; font-weight: 400; line-height: 25px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 26px 0; text-align: center; vertical-align: top; word-break: break-word;" class="Heading Heading--medium Heading--centred"> '
    						+ monthlytext + '</td>';
    	
		return defaultStr;
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
    
    private List<AggregateResult> getTopSitesForUserList(String context, String userId){
    	List<AggregateResult> topSitesForUserList = new List<AggregateResult>();
		Set<String> sitesThisUserManagesSet = peopleToSitesHeManageMap.containsKey(userId) ? peopleToSitesHeManageMap.get(userId) : new Set<String>();
		String conditionsQueryStr = '';
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		if ('toSiteManagers'.equalsIgnoreCase(context)) {
			soqlParamMap.put('soqlParam1', sitesThisUserManagesSet);
			conditionsQueryStr += 'Site__r.Chatter_Group_Id__c IN : soqlParam1 AND Date__c = LAST_MONTH ';
		} else if ('toAppManagers'.equalsIgnoreCase(context)) {
			soqlParamMap.put('soqlParam1', sitesThisUserManagesSet);
			conditionsQueryStr += '(Site__r.Chatter_Group_Id__c IN : soqlParam1 OR Site__r.Site_Type__c = \'public\') '+
					'AND Date__c = LAST_MONTH ';
		} else {
			soqlParamMap.put('soqlParam1', sitesThisUserManagesSet);
			conditionsQueryStr += 'Site__r.Chatter_Group_Id__c IN : soqlParam1 AND Date__c = LAST_MONTH ';
		}
		String qStr = 'SELECT Site__c site,Site__r.Title_Content_Version__c titleImage, ' +
				' Site__r.name siteName, SUM(Content_Views__c) contentViews, SUM(Posts__c) posts, '+
				' SUM(Replies__c) replies , SUM(Likes__c) likes FROM Analytics_Top_Site__c ' +
				' WHERE Site__r.is_active__c = true And ' +
				conditionsQueryStr + 'GROUP BY Site__c, Site__r.Title_Content_Version__c,Site__r.name, '+ 
				' Site__r.Chatter_Group_Id__c ORDER BY SUM(Content_Views__c) DESC LIMIT 5';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		topSitesForUserList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(qStr, soqlParamMap);
		return 	topSitesForUserList;		
    }
    
    private String getStyleString () {
    	String defaultString = '<style> @media all { .ExternalClass { width: 100%; } .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div { line-height: 100%; } .apple-link a { color: inherit !important; font-family: inherit !important; font-size: inherit !important; font-weight: inherit !important; line-height: inherit !important; text-decoration: none !important; } } @media only screen and (max-width: 620px) { table[class=body] .wrapper, table[class=body] .header, table[class=body] .article { padding: 10px !important; } table[class=body] .content { padding: 0 !important; } table[class=body] .container { padding: 0 !important; width: 100% !important; } table[class=body] .main { border-left-width: 0 !important; border-radius: 0 !important; border-right-width: 0 !important; } table[class=body] .btn table { width: 100% !important; } table[class=body] .btn a { width: 100% !important; } table[class=body] .img-responsive { height: auto !important; max-width: 100% !important; width: auto !important; } td[class="mobile-hide"] { display: none; } .mobile-hide { display: none; } .wrapper, .header, .article { padding: 10px !important; } .content { padding: 0 !important; } .container { padding: 0 !important; width: 100% !important; } .main { border-left-width: 0 !important; border-radius: 0 !important; border-right-width: 0 !important; } .btn table { width: 100% !important; } .btn a { width: 100% !important; } .img-responsive { height: auto !important; max-width: 100% !important; width: auto !important; } } a[x-apple-data-detectors] { color: inherit !important; text-decoration: none !important; font-size: inherit !important; font-family: inherit !important; font-weight: inherit !important; line-height: inherit !important; } </style> <!--[if (gte mso 9)|(IE)]> <style type="text/css"> table {border-collapse: collapse;} </style> <![endif]--><title>Site Analytics</title> <style type="text/css"> @media screen and (max-width: 525px) { [class="StatTile"] { width: 100% !important; display: block; margin: 0 0 4px; } } </style> <!-- Because gmail strips the above style tag --> <style type="text/css"> @media screen and (max-width: 525px) { .Stat-heading--small { font-size: 14px !important; } .Stat--leftAlign { border-right: 0 !important; width: 100% !important; display: block; } .Stat--leftAlign:first-child { border-bottom: 1px solid #CCCCCC !important; } } </style> ';
    	return defaultString;
    }

	public static Map<String,String> siteAdoptionEmailTemplateMap = new Map<String,String> {
		'emailBodyWithHeaderFooter' => '<!doctype html> <html> <head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection">{16}</head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <!-- START CENTERED WHITE CONTAINER --> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <!-- START HEADER --> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{13}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span> </td> </tr> </table> </td> </tr> <!-- END HEADER --> <!-- START MAIN CONTENT AREA --> <tr> <td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; max-width: 600px !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 28px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="Heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 21px; font-weight: 400; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; padding-bottom: 4px; text-align: left; vertical-align: top; word-break: break-word;"> {0} </td> </tr> <tr> <td class="Heading Heading--sub" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: 400; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top; word-break: break-word;">{4}</td> </tr> </table> </td> </tr> </table> </td> </tr> </table> </td> </tr> <!-- Email Content Starts --> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; max-width: 600px !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" class="u-border-top" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-top: 1px solid #cccccc; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> {15} </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table width="100%" border="0" cellspacing="0" cellpadding="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top;" align="center"> <img height="150" width="150" src="{5}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; margin: 0 auto; max-width: 100%; outline: none; text-decoration: none;"> </td> </tr> </table> </td> </tr> <tr> <!-- Switch the td if there is only 1 site mentioned in this email --> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 18px; font-weight: 400; line-height: 25px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 15px 0; text-align: center; vertical-align: top; word-break: break-word;" class="Heading Heading--medium Heading--centred"> {6} </td> <!-- <td style="padding: 15px 0;"></td> --> </tr> <tr> <td class="Stat" valign="bottom" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; padding-bottom: 10px; text-align: center;">{17}</p> <p class="Stat-number u-brandText" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: {12}; font-size: 60px; font-weight: bold; line-height: 70px; margin: 0; text-align: center;">{7}</p> </td> </tr> {8} <tr class="u-textAlign-center" style="text-align: center;"> <td class="Button" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #1abc9c; border: 1px solid #1abc9c; border-collapse: collapse; border-radius: 4px; color: #333; display: inline-block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 14px 20px; text-align: center; vertical-align: top; width: 150px;"> <a href="{9}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: none; color: #ffffff; font-size: 14px; font-weight: bold; text-decoration: none;">{18}</a> </td> </tr> </table> </td> </tr> </table> </td> </tr> {10} </table> </td> </tr> <!-- END MAIN CONTENT AREA --> </table> <!-- START FOOTER --> {11} <!-- END FOOTER --> <!-- END CENTERED WHITE CONTAINER --> </div> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </body> </html>',
		'contentWithFeedEnabled'    => '<tr> <td class="StatTilesContainer" valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 0 32px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-spacing: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="StatTile" valign="top" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f4f4f4; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 5px; text-align: center; vertical-align: top; width: 33.333%;"> <p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; padding-bottom: 10px; text-align: center;"> {3} </p> <p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;"> {0} </p> </td> <td class="StatTile" valign="top" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f4f4f4; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 5px; text-align: center; vertical-align: top; width: 33.333%;"> <p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; padding-bottom: 10px; text-align: center;"> {4} </p> <p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;"> {1} </p> </td> <td class="StatTile" valign="top" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f4f4f4; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 5px; text-align: center; vertical-align: top; width: 33.333%;"> <p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; padding-bottom: 10px; text-align: center;"> {5} </p> <p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;"> {2} </p> </td> </tr> </table> </td> </tr>',
		'contentWithFeedDisabled'   => '<tr> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 0 12px 0; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-spacing: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="" valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;">{0}<span style="font-size: 20px;"> {1}</span> </p> </td> </tr> </table> </td> </tr>',
		'otherSitesYouManageItem'   => '<tr class="u-border-top" style="border-top: 1px solid #cccccc;"> <td height="60" width="60" valign="middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 12px 10px 0; text-align: left; vertical-align: middle;"> <a href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"> <img height="60" width="60" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;"> </a> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: middle;"> <div style="color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: 400; line-height: 20px; margin: 0; padding: 0; padding-bottom: 4px; word-break: break-word;" class="Heading Heading--small">{0}</div> <a href="{1}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{4}; font-size: 14px; text-decoration: none;">{5}</a> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: 400; line-height: 20px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: right; vertical-align: middle; word-break: break-word;" class="Heading Heading--small">{2}</td> </tr>',
		'OtherSitesYouManage' 		=> '<tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <div style="border-top: 1px solid #cccccc; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 18px; font-weight: 400; line-height: 25px; margin: 0; padding: 26px 0; text-align: center; word-break: break-word;" class="u-border-top Heading Heading--medium Heading--centred"> {1} </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 50px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <thead> <tr> <td colspan="2" class="Heading Heading--sub" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: 400; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top; word-break: break-word;">{2}</td> <td class="Heading Heading--sub" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: 400; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: right; vertical-align: top; word-break: break-word;" width="150px">{3}</td> </tr> </thead> <tbody> {0} </tbody> </table> </td> </tr>',
		'lowActivitySitesBody'      => '<tr> <td height="10" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"></td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <div class="u-border-top" style="border-top: 1px solid #ccc;"> </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="1" borderColor="#FF6A23" bgcolor="#fff7f4" height="100" cellpadding="20" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <div class="Heading Heading--medium Heading--centred Heading--bold" style="color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 18px; font-weight: bold; line-height: 25px; margin: 0; padding: 0; text-align: center; word-break: break-word;">{0}</div> <p class="u-textAlign-center" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-align: center;">{1}</p> </td> </tr> </tbody> </table> </td> </tr> <tr> <td height="25" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"></td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <thead> <tr> <td colspan="2" class="Heading Heading--sub Heading--bold" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: bold; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top; word-break: break-word;">{2}</td> <td class="Heading Heading--sub Heading--bold align-right" width="150px" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: bold; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: right; vertical-align: top; word-break: break-word;">{3}</td> </tr> </thead> <tbody> {4} </tbody> </table> </td> </tr>',
		'lowActivitySitesItemList'  => '<tr class="u-border-top" style="border-top: 1px solid #ccc;"> <td height="60" width="60" valign="middle" class="align-middle u-pad-tb--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px !important; padding-top: 10px !important; text-align: left; vertical-align: middle;"> <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"> <img height="60" width="60" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;"> </a> </td> <td class="align-middle u-pad-l--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-left: 10px !important; text-align: left; vertical-align: middle;"> <div class="u-pad-b--xsmall Heading Heading--small Heading--bold" style="color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: bold; line-height: 20px; margin: 0; padding: 0; padding-bottom: 5px !important; word-break: break-word;">{1}</div> <a href="{6}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{2}; text-decoration: none;">{3}</a> </td> <td class="align-middle align-right Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #{4}; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <a href="{7}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: {2}; text-decoration: none;">{5}</a> </td> </tr>',
		'footer' 					=> '{8}<div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> <a href="{0}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{1}</a> <br>{4} </td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {7} <a href="{5}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">Simpplr</a>. </td> </tr> </table> </div>'
	};

}