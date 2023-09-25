public class BatchTopStories implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts{
    public String packageName = SimpplrContext.packageName;
    public Integer frequency;
	public String appTopStoriesFrequency;
	public String peopleTopStoriesFrequency;
	public Integer digestLimit;
    public string logoUrl;
    public string query;	
    public String applicationName;
    public App_Config__c appConfig;
    public String simpplrDefaultLogoUrl;
    public Map<Id, String> contentIdWithPublicUrlMap = new Map<Id, String>();
	public NotificationHelper.BrandingInfo brandingInfo;
    private Exception exceptionDetailsObj;
	private static final String KEY_EMAIL_HI = 'email.common.salutation';
	private static final String KEY_EMAIL_DAILY_INTRO = 'email.notification.summary.top_stories.intro';
	private static final String KEY_EMAIL_DAILY_SUBJECT = 'email.notification.summary.top_stories.subject';
	private static final String KEY_EMAIL_DAILY_SUBJECT_PLURAL1 = 'email.notification.summary.top_stories.subject_plural';
	private static final String KEY_EMAIL_DAILY_SUBJECT_PLURAL2 = 'email.notification.summary.top_stories.subject_plural_2';
	private static final String KEY_EMAIL_PAGE_RECOMMENDATION_INTRO = 'email.notification.summary.page_recommendation.intro';
	private static final String KEY_EMAIL_PAGE_RECOMMENDATION_SUBJECT = 'email.notification.summary.page_recommendation.subject';
	private static final String KEY_EMAIL_PAGE_RECOMMENDATION_SUBJECT_PLURAL = 'email.notification.summary.page_recommendation.subject_plural';
	private static final String KEY_EMAIL_PAGE_RECOMMENDATION_SUBJECT_PLURAL_2 = 'email.notification.summary.page_recommendation.subject_plural_2';
	private static final String KEY_EMAIL_DIGEST_TYPE_DAILY = 'common.top_stories.daily';
	private static final String KEY_EMAIL_DIGEST_TYPE_WEEKLY = 'common.top_stories.weekly';
	private static final String KEY_EMAIL_COMMON_ALL_DAY_DIGEST = 'email.common.all_day.digest';
	public static final String KEY_COPYRIGHT = 'email.common.footer.copyright';
	public Boolean runForAI;
    
    public BatchTopStories(App_Config__c appConfig, Integer frequency, String query, NotificationHelper.BrandingInfo brandingInfo, String simpplrDefaultLogoUrl){
        this.appConfig = appConfig;
        this.query = query;
        this.frequency = frequency;
        this.applicationName = appConfig.App_Name__c;
        this.simpplrDefaultLogoUrl = simpplrDefaultLogoUrl;
		this.peopleTopStoriesFrequency = frequency == 1 ? 'Daily' : 'Weekly';
		this.appTopStoriesFrequency = getAppTopStoriesFrequency();
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<People_Preference__c> peoplePrefList){
    	
    	try{
		List<String> localeList = new List<String>();
		Map<String,String> peopleToUserIdMap = new Map<String,String>();
		// Initialize Locale Context
		
    	//Target User IdSet
    	Set<String> userIdSet = new Set<String>();
    	List<Messaging.SingleEmailMessage> digestEmailList = new List<Messaging.SingleEmailMessage>();
    	for(People_Preference__c peoplePref: peoplePrefList){
    		userIdSet.add(peoplePref.people__r.user__c);
			peopleToUserIdMap.put(peoplePref.people__c,peoplePref.people__r.user__c);
			localeList.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey));
    	}
    	LocaleContext.getAllLabelMap('EmailNotifications', localeList);
    	//Followed User Id Set
    	String BASE_QUERY_FOR_ENTITYSUBSCRIPTION = 'select parentId, SubscriberId from EntitySubscription  where SubscriberId IN : userIdSet';
    	if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY_FOR_ENTITYSUBSCRIPTION+=' and NetworkId = null';
		}
    	List<EntitySubscription> esList = new List<EntitySubscription>();
    	esList = Database.query(BASE_QUERY_FOR_ENTITYSUBSCRIPTION);
        Map<String, List<EntitySubscription>> userEntitySubMap = new  Map<String, List<EntitySubscription>>();
        for(EntitySubscription es : esList) {
        	if(userEntitySubMap.get(es.SubscriberId)==null){
        		userEntitySubMap.put(es.SubscriberId, new List<EntitySubscription>());
        	}
        	userEntitySubMap.get(es.SubscriberId).add(es);
        }
    	
    	//Followed CG Id Set
    	List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
    	String BASE_QUERY = 'Select CollaborationGroupId, memberid From CollaborationGroupMember where  memberid in :userIdSet';
    	if(SimpplrContext.isCommunitiesEnabled){
	    	BASE_QUERY = BASE_QUERY+' AND CollaborationGroup.NetworkId = null';
	    }
    	cgmList = Database.query(BASE_QUERY);
    	Map<String, List<CollaborationGroupMember>> userColGroupMap = new  Map<String, List<CollaborationGroupMember>>();
        for(CollaborationGroupMember cg : cgmList) {
        	if(userColGroupMap.get(cg.memberid)==null){
        		userColGroupMap.put(cg.memberid, new List<CollaborationGroupMember>());
        	}
        	userColGroupMap.get(cg.memberid).add(cg);
        }

		Map<String, Set<String>> peopleToContentMap = new Map<String, Set<String>>();
		Boolean isSuccess = false;
		//Call AI endpoint if AI is Enabled
		if(SimpplrContext.aiContentRecommendationEnabled){
			List<String> peopleIdList = new List<String>();
			for(People_Preference__c peoplePref : peoplePrefList) {

				peopleIdList.add(peoplePref.People__c);
			}
			
			if(peopleIdList.isEmpty() == false){
				AiPageRecommendationsWrapper aIPageRecommendationsWrapper = getAIPageRecommendations(peopleIdList);
				Map<String, Set<String>> peopleVsContentIdsMap = aIPageRecommendationsWrapper.peopleVsContentIdsMap;
				isSuccess = aIPageRecommendationsWrapper.isSuccess;
				if(isSuccess && peopleVsContentIdsMap.isEmpty() == false){
					peopleToContentMap.putAll(peopleVsContentIdsMap);
				}
			}
		}

    	for(People_Preference__c peoplePref : peoplePrefList) {
    		Set<String> followedUserIdSet = new Set<String>();
	        for(String userId : userEntitySubMap.keySet()) {
		        if(String.valueOf(peoplePref.People__r.user__c).equalsIgnoreCase(userId)) {
			        for(EntitySubscription es : userEntitySubMap.get(peoplePref.People__r.user__c)){
			        	followedUserIdSet.add(es.parentId);
			        }
	        	}
    		}
    		Set<String> cgGroupIdSet = new Set<String>();
    		for(String userId : userColGroupMap.keySet()){
    			if(String.valueOf(peoplePref.People__r.user__c).equalsIgnoreCase(userId)) {
		    		for(CollaborationGroupMember cgMember : userColGroupMap.get(peoplePref.People__r.user__c)) {
		    			cgGroupIdSet.add(cgMember.CollaborationGroupId);
		    		}
    			}
    		}
    		digestLimit = 5;
    		if(frequency == 7) {
    			digestLimit = 10;
    		}
    		String targetUser = peoplePref.people__r.User__c;

			Set<String> contentIds = new Set<String>();

			//Use AI Content if AI is Enabled
			if(SimpplrContext.aiContentRecommendationEnabled && peopleToContentMap.containsKey(peoplePref.People__c)){
				contentIds.addAll(peopleToContentMap.get(peoplePref.People__c));
			}

			//check if AI failed
			if(SimpplrContext.aiContentRecommendationEnabled && isSuccess){
			 runForAI = true;
			} else {
			 runForAI = false;
			}

    		String contentQuery = 'select id,Popularity_Score__c, Title__c, Type__c,Text_Intro__c, Site__c,'+ 
					' Site__r.Name,Publish_Start_DateTime__c, Last_Edited_DateTime__c, '+
    				' Event_Start_Datetime__c,Event_End_Datetime__c,Event_TimezoneSidKey__c,Primary_Author__c,Primary_Author__r.Full_Name__c,'+ 
					' Display_Excerpt__c, Summary_1__c, Site__r.Chatter_Group_Id__c,Primary_Author__r.External_Photo_URL__c, '+
					' createdDate, Site__r.Site_Type__c, Site__r.Landing_Page__c, Is_Must_Read__c,' +   
					' Site__r.Title_Content_Version__c, Event_Is_All_Day__c, ' +
    				' (SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c, Thumbnail_URL__c FROM File_Simpplr_Content__r ' + 
					'  WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c ) ' +
    				' from Simpplr_Content__c where Is_Deleted__c = false AND Is_Published__c=true ' +
    				' AND (Site__r.Chatter_Group_Id__c IN: cgGroupIdSet OR Site__r.Site_Type__c = \'Public\' OR ( type__c=\'BlogPost\' AND Primary_Author__r.User__c IN:followedUserIdSet) OR Primary_Author__r.User__c=:targetUser) ';
			
			if(runForAI){
				contentQuery += 'AND Id IN :contentIds ';
			}else{
				contentQuery += 'AND First_Publish_DateTime__c=LAST_N_DAYS:'+frequency +' order by Popularity_Score__c desc, CreatedDate desc limit '+digestLimit;
			}

    		List<Simpplr_Content__c> contentList = Database.query(contentQuery);
    		Map<String, Simpplr_Content__C> contentMap;
    		String digestBody = '';
    		if(!contentList.isEmpty()){
				contentMap = new Map<String, Simpplr_Content__c>(contentList);
				
				contentList = processContentSorting(contentMap, contentList, contentIds);

				digestBody = getDigestBody(frequency, applicationName, peoplePref, contentList);
				
				String localeKey = Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey);
				String digestType;
				if(frequency == 1) {
		        	digestType = LocaleContext.getLabel(localeKey, KEY_EMAIL_DIGEST_TYPE_DAILY);

		        } else if(frequency == 7) {
		        	digestType = LocaleContext.getLabel(localeKey, KEY_EMAIL_DIGEST_TYPE_WEEKLY);
		        }

		        String subject = '';
		        
				if (!contentList.isEmpty()) {

					if (contentList.size() == 1) {
						subject = runForAI ? 
									LocaleContext.getLabel(localeKey, KEY_EMAIL_PAGE_RECOMMENDATION_SUBJECT) : 
									LocaleContext.getLabel(localeKey, KEY_EMAIL_DAILY_SUBJECT);
					
					} else if (contentList.size() == 2) {
						subject = runForAI ? 
									LocaleContext.getLabel(localeKey, KEY_EMAIL_PAGE_RECOMMENDATION_SUBJECT_PLURAL).replace('{{count}}', '1') : 
									LocaleContext.getLabel(localeKey, KEY_EMAIL_DAILY_SUBJECT_PLURAL1).replace('{{count}}', '1');
					
					} else {
						subject =  runForAI ? 
									LocaleContext.getLabel(localeKey, KEY_EMAIL_PAGE_RECOMMENDATION_SUBJECT_PLURAL_2).replace('{{count}}', String.valueOf(contentList.size() - 1)) : 
									LocaleContext.getLabel(localeKey, KEY_EMAIL_DAILY_SUBJECT_PLURAL2).replace('{{count}}', String.valueOf(contentList.size() - 1));
						
					}

					subject = subject.replace('{{contentTitle}}', contentList.get(0).Title__c);
					subject = subject.replace('{{appName}}', applicationName);
					subject = subject.replace('{{digestType}}', digestType);
				}

				if(String.isNotBlank(digestBody)) {
		    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
					singleMail.setTargetObjectId(peoplePref.people__r.User__c);
					singleMail.setSubject(subject);
					// singleMail.setReplyTo(ServiceConstants.EMAIL_NOTI_NOREPLY_ADDRESS);
					if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
						singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
					}
					if(SimpplrContext.DeeplinkingEnabled) {
						digestBody = EmailUtility.deeplinkedMailBody(digestBody);
					}
					
					singleMail.setHtmlBody(digestBody);
					singleMail.setCharset('UTF-8');
					singleMail.setUseSignature(false);
					singleMail.setSaveAsActivity(false);			
					digestEmailList.add(singleMail);
            	}
            	
    		}
    		
	    	}
			
	        if(digestEmailList.size() > 0) {
	        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(digestEmailList);
	        }
		}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }

	private List<Simpplr_Content__c> processContentSorting(Map<String, Simpplr_Content__c> contentMap,List<Simpplr_Content__c> contentList, Set<String> contentIds){
		if(runForAI){
			return getContentsForAI(contentMap, contentIds);

		}else{
			List<ContentTopStory> contentTopStoryList = new List<ContentTopStory>();
			for(Simpplr_Content__c content : contentList){
				ContentTopStory topStory = new ContentTopStory(String.valueOf(content.id), (content.Popularity_Score__c).intValue());
				contentTopStoryList.add(topStory);
			}
			contentTopStoryList.sort(); //Sort on popularity basis without AI
			return getContents(contentMap, contentTopStoryList);
		}
	}

	private List<Simpplr_Content__c> getContentsForAI(Map<String, Simpplr_Content__c> contentMap, Set<String> contentIds){
		List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();
		for(String contentId : contentIds) { //Sort on score basis from AI
			if(contentList.size() < digestLimit && contentMap.get(contentId) != null) {
					contentList.add(contentMap.get(contentId));
			}else if(contentList.size() == digestLimit){
				break;
			}
		}
		return contentList;
	}

	private List<Simpplr_Content__c> getContents(Map<String, Simpplr_Content__c> contentMap, List<ContentTopStory> contentTopStoryList){
		List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();
		for(ContentTopStory contentStory : contentTopStoryList) {
			if(contentList.size() < digestLimit && contentMap.get(contentStory.id) != null) {
				contentList.add(contentMap.get(contentStory.id));
			}else if(contentList.size() == digestLimit){
				break;
			}
		}
		return contentList;
	}
    
    private String getDigestBody(Integer frequency, String applicationName, People_Preference__c peoplePref, List<Simpplr_Content__c> contentList) {
    	String topStoryDigestHtmlBody = '';
    	if(!contentList.isEmpty()) {
			brandingInfo = EmailUtility.getBrandingInfo4People(peoplePref.People__r);
	    	Map<String,String> partMap = contentTopStoryDigestPartMap;
	    	String localeKey = '';
			localeKey = Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey);
	    	List<String> baseEmailBodyList = new List<String>();
	    	
	    	baseEmailBodyList.add('' +SimpplrContext.salesforceBaseUrl  + Page.app.getUrl()+'?origin=tse'); // 0
	    	
	    	baseEmailBodyList.add(brandingInfo.logo_url); // 1
							
	    	baseEmailBodyList.add(LocaleContext.getLocalisedDateAsMMMDDYYYY(DateTime.now(), localeKey, peoplePref.People__r.User__r.timezonesidkey));
	    	
	    	//{3} userName 
            if(String.isNotBlank(peoplePref.People__r.First_Name__c)) {
				baseEmailBodyList.add(LocaleContext.getLabel(localeKey, 
						KEY_EMAIL_HI).replace('{{firstName}}', peoplePref.People__r.First_Name__c));
            } else {
            	baseEmailBodyList.add(LocaleContext.getLabel(localeKey, 
						KEY_EMAIL_HI).replace('{{firstName}}', peoplePref.People__r.Full_Name__c));
            }
			
			//{4} Daliy intro 
			String frequenceArg = '';

			if (frequency == 1) {
				frequenceArg = LocaleContext.getLabel(localeKey, KEY_EMAIL_DIGEST_TYPE_DAILY);

			} else {
				frequenceArg = LocaleContext.getLabel(localeKey, KEY_EMAIL_DIGEST_TYPE_WEEKLY);
			}

			String introText = runForAI ? 
			LocaleContext.getLabel(localeKey, KEY_EMAIL_PAGE_RECOMMENDATION_INTRO).replace('{{appName}}', applicationName) : LocaleContext.getLabel(localeKey, 
						KEY_EMAIL_DAILY_INTRO).replace('{{appName}}', applicationName);
			introText = introText.replace('{{digestType}}', frequenceArg);

			baseEmailBodyList.add(introText); 
	    	
	    	baseEmailBodyList.add('');
	    	 
	    	baseEmailBodyList.add(''); // 6
			baseEmailBodyList.add(LocaleContext.getLabel(localeKey,KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
			
			baseEmailBodyList.add('https://www.simpplr.com'); //8
			baseEmailBodyList.add('Simpplr'); //9

	    	
	    	String allContentRows = '';
	    	String viewURL = '';
	    	String thumbnailTitleImageHTML = '';
	    	String widescreenTitleImageHTML = '';
	    	
	    	getcontentIdNPublicUrlMap(contentList);
	    	Integer index = 0;			
			
			// *******************Content ROW************************************
	    	for (Simpplr_Content__c content :contentList) {
				String contentPart = '';
				Boolean isMustReadPage = false;
				if ('Page'.equalsIgnoreCase(content.type__c)) {

					if (content.Is_Must_Read__c) {
						isMustReadPage  = true;
					}

					if (String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
						contentPart = partMap.get('pageRow');
					} else {
						contentPart = partMap.get('pageWithoutImageRow');
					}

				} else if ('Event'.equalsIgnoreCase(content.type__c)) {
					
					contentPart = partMap.get('eventWithoutImageRow');

				} else if ('BlogPost'.equalsIgnoreCase(content.type__c)) {
					
					if (String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
						contentPart = partMap.get('blogPostRow');
					} else {
						contentPart = partMap.get('blogWithoutImagePostRow');
					}

				} else if ('Album'.equalsIgnoreCase(content.type__c)) {
					contentPart = partMap.get('albumRow');
				}

	    		List<String> contentPartList = new List<String>();
	    		String localizedContentType = LocaleContext.getLocalisedContentTypeLabel(localeKey, content.type__c.toLowerCase()).capitalize();
				contentPartList.add(EmailUtility.format(partmap.get('ContentType'),
									new List<String>{
											localizedContentType
											})); // 10.0								

				//10.1
	    		viewURL = '' +SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?siteId=' + content.site__c +'&contentId='+content.id+'&pageToRedirect=ContentDetailPage'+'&origin=tse&contentType='+content.type__c.tolowercase()+'&utm_medium=email&utm_source=top_stories&utm_content='+frequency+'&model='+SimpplrContext.aiContentRecommendationVersion+'&org_email_freq='+appTopStoriesFrequency+'&email_freq='+peopleTopStoriesFrequency+'&pos='+String.valueOf(index);
	    		contentPartList.add(viewURL);
	    		//10.2
				contentPartList.add(content.Title__c.length()>100 ? content.Title__c.substring(0,97)+'...' : content.Title__c);
	    		
	    		//Adding title Image 

    			if(!'Event'.equalsIgnoreCase(content.type__c) && String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
		    		//10.3
					contentPartList.add(contentIdWithPublicUrlMap.get(content.id));
		    	
				} else {
					contentPartList.add(' ');
				}
		    	
	    		// adding content body text 
	    		if(String.isNotBlank(content.Display_Excerpt__c)){
					//10.4
					if(runForAI && String.isBlank(content.Summary_1__c)){
						contentPartList.add(Utility.getPlainText(content.Display_Excerpt__c, 100, true));
					}else{
						contentPartList.add(content.Display_Excerpt__c);
					}
	    		} else {
					//10.4
	    			contentPartList.add('');
	    		}
			
			//Promoted Stamp
			//10.5
			contentPartList.add('');
	    		
	    		if(content.site__r.Site_Type__c != null && content.site__r.Site_Type__c.equalsIgnoreCase('Private')){
	    			//10.6
					contentPartList.add('<span style="border: 1px solid #cccccc; color: #666; font-size: 8px; line-height: 1; padding: 1px 3px; text-align: center; text-decoration: none; text-transform: uppercase; margin-right: 6px;" href="#">PRIVATE</span>');
	    		} else if(content.site__r.Site_Type__c != null && content.site__r.Site_Type__c.equalsIgnoreCase('Unlisted')){
	    			//10.6
					contentPartList.add('<span style="border: 1px solid #cccccc; color: #666; font-size: 8px; line-height: 1; padding: 1px 3px; text-align: center; text-decoration: none; text-transform: uppercase; margin-right: 6px;" href="#">UNLISTED</span>');
	    		} else{
	    			//10.6
					contentPartList.add('');
	    		}

	    		// adding view button 
	    		//10.7
	    		contentPartList.add(viewURL);
	    		//10.8
	    		contentPartList.add(brandingInfo.general_primaryColor); // {7} branding color for links/buttons 
	    		//10.9
	    		contentPartList.add(thumbnailTitleImageHTML);
				
				String eventMonth = '';
				String eventDay = '';

	    		if('Event'.equalsIgnoreCase(content.type__c)){
					String badge = '';
					String dayForEvent = '';
					String startDay = LocaleContext.getLocalisedDateAsEEEEMMMDYYYY(content.Event_Start_Datetime__c, localeKey, content.Event_TimezoneSidKey__c);
					String endDay = LocaleContext.getLocalisedDateAsEEEEMMMDYYYY(content.Event_End_DateTime__c, localeKey, content.Event_TimezoneSidKey__c);
					String startTime = LocaleContext.getLocalisedDateAs12HourFormatTime(content.Event_Start_DateTime__c, localeKey, content.Event_TimezoneSidKey__c);
					String endTime = LocaleContext.getLocalisedDateAs12HourFormatTime(content.Event_End_DateTime__c, localeKey, content.Event_TimezoneSidKey__c);
					eventMonth = LocaleContext.getLocalisedMonth(content.Event_Start_Datetime__c, localeKey, content.Event_TimezoneSidKey__c);
					eventDay = content.Event_Start_Datetime__c.format('dd', content.Event_TimezoneSidKey__c);

					String timeZoneLabel;
					if(content.Event_Is_All_Day__c == false) {
						timeZoneLabel = Utility.timezoneIdToDisplayLabel(peoplePref.People__r.User__r.Timezonesidkey);
					} else {
						timeZoneLabel = Utility.timezoneIdToDisplayLabel(content.Event_TimezoneSidKey__c);
					}

					if('12:00 AM'.equalsIgnoreCase(content.Event_Start_Datetime__c.format('h:mm a')) && content.Event_Start_Datetime__c.addDays(1) == content.Event_End_DateTime__c){
						dayForEvent = startDay;
						badge = LocaleContext.getLabel(localeKey, KEY_EMAIL_COMMON_ALL_DAY_DIGEST);
					}else if(content.Event_Start_DateTime__c.isSameDay(content.Event_End_DateTime__c)){
						dayForEvent = startDay;
						badge = startTime+' - '+endTime + ' (' + timeZoneLabel + ')';
					}else if('12:00 AM'.equalsIgnoreCase(content.Event_Start_Datetime__c.format('h:mm a')) && '12:00 AM'.equalsIgnoreCase(content.Event_End_DateTime__c.format('h:mm a'))){
						String eventEndDateMinusOneMinute = LocaleContext.getLocalisedDateAsEEEEDMMMYYYY(content.Event_End_DateTime__c.addMinutes(-1), localeKey, content.Event_TimezoneSidKey__c);
						badge = startDay+' - '+ eventEndDateMinusOneMinute + ' (' + timeZoneLabel + ')';
					}else{
						badge = startDay+' - '+endDay + ' (' + timeZoneLabel + ')';
					}
					//10.10
					contentPartList.add(EmailUtility.format(partmap.get('BadgeForEvent'),//10
							new List<String>{dayForEvent}));
					//10.11
					contentPartList.add(EmailUtility.format(partmap.get('BadgeForEvent'),//11
							new List<String>{badge}));
				}else{
					//10.10
					contentPartList.add(' ');
					//10.11
					contentPartList.add(' ');
				}

				if (String.isNotBlank(content.site__c)) {
					//10.12
					contentPartList.add(content.site__r.name); // Site name
					//10.13
					contentPartList.add(PageContext.getPageURL(Pages.app) +'?u=/site/' + content.site__c + '/' + content.site__r.Landing_Page__c); // Site Link
					
				} else {
					//10.12
					contentPartList.add(' ');
					//10.13
					contentPartList.add(' ');
				}

				//10.14
				contentPartList.add(LocaleContext.getLocalisedDateAsEEEEDMMMYYYY(content.Last_Edited_DateTime__c, localeKey, peoplePref.People__r.User__r.timezonesidkey));//Created date time
				
				if ('BlogPost'.equalsIgnoreCase(content.type__c) && 
						String.isNotBlank(content.Primary_Author__r.Full_Name__c)) {
					//10.15 
					contentPartList.add(content.Primary_Author__r.Full_Name__c);
					//10.16
					contentPartList.add(PageContext.getPageURL(Pages.app)+ '?u=/people/' + content.Primary_Author__c);
				
				} else {
					//10.15 
					contentPartList.add('');
					//10.16 
					contentPartList.add('');
				}
				//10.17 
				contentPartList.add(eventMonth) ;
				//10.18 
				contentPartList.add(eventDay);

				//10.19 must read stamp 
				if(isMustReadPage) {
					contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey),EmailConstants.KEY_LABEL_MUSTREAD));
				}  else {
					contentPartList.add('');
				}

				// 10.20 contentType 
				if ('Page'.equalsIgnoreCase(content.type__c)) {
					contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
								peoplePref.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_PAGE));
				
				} else if ('Album'.equalsIgnoreCase(content.type__c)){
					contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
								peoplePref.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_ALBUM));
				
				} else if ('BlogPost'.equalsIgnoreCase(content.type__c)){
					contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
								peoplePref.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_BLOGPOST));
				
				} else if ('Event'.equalsIgnoreCase(content.type__c)){
					contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
						peoplePref.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_EVENT));
				}

				//10.21 In keyword
				contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
						peoplePref.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_IN)+' ');
				
				//10.22 By keyword 
				contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
						peoplePref.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_BY)+' ');

	    		allContentRows +=EmailUtility.format(contentPart, contentPartList);
	    		index++;
	    	}
	    	// *******************Content Row ends************************************
	    	baseEmailBodyList.add(allContentRows); // 10 for content rows. 
	    	
	    	//Email Setting
	    	baseEmailBodyList.add('' + SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?userId=' + peoplePref.people__r.user__c +'&pageToRedirect='+Pages.MySettingsEmail+'&origin=tse');
	    	
	    	// header background // 12
			if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
				baseEmailBodyList.add('000000');
			} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
				baseEmailBodyList.add(brandingInfo.general_primaryColor);
			} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
				baseEmailBodyList.add('ffffff');
			} else {
				baseEmailBodyList.add(brandingInfo.header_backgroundColor);
			}
			
			// footer background //13
			
	    	baseEmailBodyList.add('f8f8f8');
			baseEmailBodyList.add(brandingInfo.header_iconColor); // header text color Applicable for date only. // 14
	    	
			//baseEmailBodyList.add(brandingInfo.footer_textColor); // footer text color Applicable for footer text only. // 15
			baseEmailBodyList.add('333333'); // footer text color Applicable for footer text only. // 15

			baseEmailBodyList.add(brandingInfo.general_primaryColor); // Link color Applicable for all links in header and footer. // 16
			//17 CSS media rule
			baseEmailBodyList.add('<style type="text/css">/* MOBILE STYLES */@media screen and (max-width: 525px) {/* USE THESE CLASSES TO HIDE CONTENT ON MOBILE */td[class="mobile-hide"]{display:none;}}</style><!--[if(gte mso 9)|(IE)]><style type="text/css">table {border-collapse: collapse;}</style><![endif]-->');
			
			String languagelocalekey = Utility.getSimpplrLanguageLocaleKey(peoplePref.People__r.User__r.languagelocalekey);
			if(frequency == 1){
				baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, KEY_EMAIL_DIGEST_TYPE_DAILY));
			} else {
				baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, KEY_EMAIL_DIGEST_TYPE_WEEKLY));
			}
			
			//19 app name
			baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, EmailConstants.KEY_FOOTER_SETTINGS).replace('{{appName}}',SimpplrContext.applicationName));
			//20 copyright 
			baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, EmailConstants.KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
			//21 powered by 
			baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, EmailConstants.KEY_POWERED_BY));

			//22 APPName 
			baseEmailBodyList.add(SimpplrContext.applicationName);
			// 23 mediaCSS
			baseEmailBodyList.add('<style>@media all {    .ExternalClass {      width: 100%;    }    .ExternalClass,    .ExternalClass p,    .ExternalClass span,    .ExternalClass font,    .ExternalClass td,    .ExternalClass div {      line-height: 100%;    }    .apple-link a {      color: inherit !important;      font-family: inherit !important;      font-size: inherit !important;      font-weight: inherit !important;      line-height: inherit !important;      text-decoration: none !important;    }  }@media only screen and (max-width:620px) {    table[class=body] .wrapper,    table[class=body] .header,    table[class=body] .article {      padding: 10px !important;    }    table[class=body] .content {      padding: 0 !important;    }    table[class=body] .container {      padding: 0 !important;      width: 100% !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .btn a {      width: 100% !important;    }    table[class=body] .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }    td[class="mobile-hide"] {      display: none;    }    .mobile-hide {      display: none;    }    .newsletter-item .media {      width: 100px !important;    }    .newsletter-item .media .Calendar .CalendarMonth {      font-size: 14px !important;    }    .newsletter-item .media .Calendar .CalendarDay {      font-size: 33px !important;    }    .newsletter-item--showCase .media {      width: 100% !important;    }    .newsletter-item--showCase .media .Calendar .CalendarMonth {      font-size: 20px !important;    }    .newsletter-item--showCase .media .Calendar .CalendarDay {      font-size: 40px !important;    }    .wrapper,    .header,    .article {      padding: 10px !important;    }    .content {      padding: 0 !important;    }    .container {      padding: 0 !important;      width: 100% !important;    }    .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    .btn table {      width: 100% !important;    }    .btn a {      width: 100% !important;    }    .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }  }    a[x-apple-data-detectors] {        color: inherit !important;        text-decoration: none !important;        font-size: inherit !important;        font-family: inherit !important;        font-weight: inherit !important;        line-height: inherit !important;    }</style>');
			
			// 24 mobile promotion footer
			baseEmailBodyList.add(EmailUtility.getMobilePromotionFooterDiv(languagelocalekey, peoplePref.People__c));

			// 25 Recommendation Email track url
			baseEmailBodyList.add(SimpplrContext.emailOpenTrackerURL);

			// 26 Recommendation Email tracker code
			baseEmailBodyList.add(getEncrypyedTrackingParams(peoplePref, appTopStoriesFrequency, peopleTopStoriesFrequency));
			topStoryDigestHtmlBody = EmailUtility.format(partMap.get('BaseEmailBody'), baseEmailBodyList);
    	}
    	return topStoryDigestHtmlBody;
    }

	private AiPageRecommendationsWrapper getAIPageRecommendations(List<String> peopleIds) { 
		AiPageRecommendationsWrapper aIPageRecommendationsWrapperObj = new AiPageRecommendationsWrapper();
		Map<String, Set<String>> peopleToContentIdsMap = new Map<String, Set<String>>();      
		Map<String, Object> requestBody = new Map<String, Object>();
		Boolean isSuccess = false;
		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/content/topic-suggest'; //Using topic-suggest endpoint for Page Recommendations as well
		requestBody.put('action', 'pageRecommendation');
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('peopleIds', peopleIds);
		requestBody.put('version', ServiceConstants.PAGE_RECOMMENDATION_API_VERSION);
		requestBody.put('source', 'email');
		digestLimit = 5;
		if(frequency == 7) {
			digestLimit = 10;
		}
		requestBody.put('topn', digestLimit);
		HttpRequest req = new HttpRequest();
		req.setEndpoint(externalEndPoint);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('simpplr-dri', Utility.getSimpDri());
		req.setHeader('jwttoken', Utility.getJWTToken());
		req.setMethod('POST');
		req.setBody(Json.serialize(requestBody));
		req.setTimeout(30000);
		Http http = new Http();

		HttpResponse httpresponseObj = http.send(req);
		if(httpresponseObj.getStatusCode() == 200) {
			String bodyStr = httpresponseObj.getBody();
			if(String.isNotBlank(bodyStr)) {
				Map<String, Object> resultBodyMap = ((Map<String, Object>) JSON.deserializeUntyped(bodyStr));
				peopleToContentIdsMap = processResponseBody(resultBodyMap);
			}
			isSuccess = true;
		}
		aIPageRecommendationsWrapperObj.isSuccess = isSuccess;
		aIPageRecommendationsWrapperObj.peopleVsContentIdsMap = peopleToContentIdsMap;

		return aIPageRecommendationsWrapperObj;
	}

	private Map<String, Set<String>> processResponseBody(Map<String, Object> resultBodyMap) {
		Map<String, Set<String>> peopleToContentIdsMap = new Map<String, Set<String>>();
		Map<String, Object> resultsMap = (Map<String, Object>)resultBodyMap.get('content_recommendations');
 		for(String peopleId:resultsMap.keySet()){
			List<Object> recommendationsList = (List<Object>)resultsMap.get(peopleId);
			Set<String> contentIds = new Set<String>();
			for(Object recommendationsObj : recommendationsList){
				Map<String, Object> recommendationmap = (Map<String, Object>) recommendationsObj;
				contentIds.add(((String) recommendationmap.get('Simpplr__Content__Id')));
			}
			peopleToContentIdsMap.put(peopleId, contentIds);
		}
		return peopleToContentIdsMap;
    }

	/**
	 * @description fetch App Level Top Stories Frequency
	 * @return String - Daily/ Weekly
	 */
	private String getAppTopStoriesFrequency() {
		String query = 'select id, Data__c from App_Default__c where Type__c = \'summaries_and_digest\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);

		ManageApplicationWrapper.SummariesAndDigestWrapper summariesAndDigestWrap = new ManageApplicationWrapper.SummariesAndDigestWrapper();
        
		if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)) {
			summariesAndDigestWrap = (ManageApplicationWrapper.SummariesAndDigestWrapper)JSON.deserialize(
                    listOfAppDefault[0].Data__c, 
                    ManageApplicationWrapper.SummariesAndDigestWrapper.class);
		} else {  
			PostInstallHelper piHelper = new PostInstallHelper();
			summariesAndDigestWrap = piHelper.getDefaultSummariesAndDigestSettings();
    	}
		return summariesAndDigestWrap.topStoriesFrequency;
    }

    public void finish(Database.BatchableContext BC){
    	
		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchTopStories - ' + (frequency == 1 ? 'Daily' : 'Weekly'), exceptionDetailsObj);
		}
		
    	if(frequency == 1) {
			Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
			String dayOfWeek = dt.format('EEEE');
			String startOfWeek;
			if (SimpplrContext.StartOfWeek != null) {
				startOfWeek = SimpplrContext.StartOfWeek;
			} else {
				startOfWeek = 'Monday';
			}
			if(dayOfWeek.startsWithIgnoreCase(startOfWeek)) {
				String queryWeeklyTopStoryDigest = 'Select People__r.User__c,People__r.User__r.UserName, People__r.User__r.timezonesidkey, People__r.User__r.LanguageLocaleKey, People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c,People__r.Last_Name__c, Id, People__r.Segment__c, People__r.Segment__r.Branding_Logo__c, People__r.Segment__r.Branding_JSON__c, People__r.User_Hash__c From People_Preference__c where  people__r.User__r.isActive=true and people__r.User__r.UserType=\'Standard\' And Allow_Simpplr_Emails__c = true and Email_Content_Digest_Frequency__c = \'Weekly\'';
				BatchTopStories jobWeeklyTopStoryDigest = new BatchTopStories(appConfig, 7, queryWeeklyTopStoryDigest,brandingInfo, simpplrDefaultLogoUrl);		
		        Database.executeBatch(jobWeeklyTopStoryDigest,25);
			}
		}
    }

	public String getEncrypyedTrackingParams(People_Preference__c peoplePref, String appTopStoriesFrequency, String peopleTopStoriesFrequency) {
    	String url = 'user_hash=' + peoplePref.People__r.User_Hash__c + '&people_id=' + peoplePref.People__c + '&user_id=' + peoplePref.People__r.User__c + '&org_id=' +SimpplrContext.simpplrOrgId
		+ '&utm_source=top_stories'
		+ '&utm_medium=email' 
		+ '&org_email_freq=' + appTopStoriesFrequency 
		+ '&email_freq=' + peopleTopStoriesFrequency 
		+ '&org_name=' + UserInfo.getOrganizationName() ; 

		if(runForAI){
			url += '&model=V' + SimpplrContext.aiContentRecommendationVersion;
		}else{
			url += '&model=legacy';
		}

		String orgId = SimpplrContext.simpplrOrgId;
		
		if (orgId.length() == 18) {
		    orgId = orgId.substring(0, 15);
		}  
		Integer randomNumber = Integer.valueof((Math.random() * 1000000));
		String recordId = String.valueOf(randomNumber) + SimpplrContext.simpplrOrgId.substring(0, 18 - String.valueOf(randomNumber).length());
		String seedValue = orgId + recordId + url;
		String initVectorString = (orgID + 'SIMPPLR').substring(0, 16);
		Blob initVector = Blob.valueOf(initVectorString);
		Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
		Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
		Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
		String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0, 40);
		String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0, 32);
		Blob dataToEncrypt = Blob.valueOf(seedValue);
		Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
		String keyVal = EncodingUtil.base64Encode(encryptedData);
		String paddingLeft = '';
		
		if (keyVal.endsWith('=') == false) {
		    paddingLeft = 'C';
		}
		
		if (keyVal.endsWith('==')) {
		    paddingLeft = 'A';
		    keyVal = keyVal.removeEnd('==');
		}
		
		if (keyVal.endsWith('=')) {
		    paddingLeft = 'B';
		    keyVal = keyVal.removeEnd('=');
		} 	
			
		String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
		
		if (cryptoKeyString.endsWith('=') == false) {
		    paddingLeft = paddingLeft + 'c';
		}
		
		if (cryptoKeyString.endsWith('==')) {
		    paddingLeft = paddingLeft + 'a';
		    cryptoKeyString = cryptoKeyString.removeEnd('==');
		}
		
		if (cryptoKeyString.endsWith('=')) {
		    paddingLeft = paddingLeft + 'b';
		    cryptoKeyString = cryptoKeyString.removeEnd('=');
		} 	
			
		paddingLeft = paddingLeft + saltStringPrefix.substring(0, 32) 
		    + saltStringPrefix.substring(0, 16) 
		    + cryptoKeyString
		    + saltStringPrefix.substring(16, 32);
		String token = paddingLeft + keyVal + saltStringSuffix + Utility.simpleObfuscateString(orgId);
		
		return token;
    }
    
    private void getcontentIdNPublicUrlMap(List<Simpplr_Content__c> contentList) {
    	Map<Id, Id> contentIdAndCVIdMap = new Map<Id, Id>();
    	
    	// Widescreen image is required for First content, Thumbnail image for the rest..
    	String desiredImageType = 'Thumbnail';
    	for(Simpplr_Content__c contentObj : contentList) {
    		if(!contentIdWithPublicUrlMap.containsKey(contentObj.Id)){
	    		List<File__c> fileList = contentObj.File_Simpplr_Content__r;
				if(!fileList.isEmpty()) {
					// below 'for' loop will execute max 2 times per iteration
					for(File__c fileObj : fileList) {
						if(fileObj.Is_Title_Image__c){
							if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)){
								if(String.isNotBlank(fileObj.Content_Version__c)) {
									contentIdAndCVIdMap.put(contentObj.Id, fileObj.Content_Version__c);
								} else {
									contentIdWithPublicUrlMap.put(contentObj.id, fileObj.Thumbnail_URL__c);
								}
								break;
							} else if(desiredImageType.equalsIgnoreCase(fileObj.Title_Image_Type__c)) {
								contentIdAndCVIdMap.put(contentObj.Id, fileObj.Content_Version__c);
								break;
							}
						}
					}
				} else {
					Simpplr_Site__c siteObj = contentObj.Site__r;
					if(siteObj != null && String.isNotBlank(siteObj.Title_Content_Version__c) && contentObj.Type__c != 'Event') {
						contentIdAndCVIdMap.put(contentObj.Id, siteObj.Title_Content_Version__c);
					}
				}
    		
    			desiredImageType = 'Thumbnail';
    		}
    	}
    	Map<Id, String> cvIdNPublicUrlMap;
    	if(contentIdAndCVIdMap.size()>0){
    		cvIdNPublicUrlMap = FileContentProvider.generateEmbedPublicUrl(contentIdAndCVIdMap.values());
    	
	    	for(Id contentId : contentIdAndCVIdMap.keySet()){
	    		contentIdWithPublicUrlMap.put(contentId,cvIdNPublicUrlMap.get( contentIdAndCVIdMap.get(contentId)));
	    	}
    	}
    }

	public static Map<String,String> contentTopStoryDigestPartMap = new Map<String,String>{
		'BaseEmailBody' =>'<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">{23}<title>Simpplr Email Digest</title></head><body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"><div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"><table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{12}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"></td><td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"><span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span></td></tr></tbody></table></td></tr><tr><td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;">{3},<br>{4}</h2></td></tr>{10}</tbody></table></td></tr></tbody></table>{24}<div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"><a href="{11}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{19}.</a><br>{20}</td></tr><tr><td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {21} <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">{9}</a>. </td></tr><tr><td><img src={25}{26} width="1" height="1" alt="" class="CToWUd"></td></tr></tbody></table></div></div></td></tr></tbody></table></body></html>',
		
		/*{0} LogoLink*/
		/*{1} LogoImage*/  
		/*{2} EmailDate*/
		/*{3} UserName*/
		/*{4} AppName*/
		/*{5} UserName link to HomeMyDashboard page*/
		/*{6} EMAIL User Name*/
		/*{7} Copywrite*/
		/*{8} App Link*/
		/*{9} App Name*/
		/*{10} ContentRow*/
		
				'BadgeForEvent' => '<div style="padding-top: 6px; line-height: 0; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;"><span style="color: #999; font-size: 12px; line-height: 1;">{0}</span></div>',
			/*{0}*/ 'ContentType' =>'<span style="border: 1px solid #cccccc; color: #666; font-size: 8px; line-height: 1; padding: 1px 3px; text-align: center; text-decoration: none; text-transform: uppercase; margin-right: 6px;" href="#">{0}</span>',
			/*{1} CONTENT LINK*/
			/*{2} CONTENT Title*/
			/*{3} Widescreen Title Image */  'WidescreenTitleImage' => '<tr><td valign="top" style="padding-bottom: 12px"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{0}"><img width="570" src="{1}" alt="" style="border: none; height: auto; max-width: 100%; width: auto"></a></div></td></tr>',
			/*{4} CONTENT BODY*/
			/*{5} Promoted Tag*/ 
			/*{6} Private tag*/
			/*{7} View Link*/
			/*{8} color for all links/buttons in body*/
			/*{9} ThumbnailTitle Title Image */'ThumbnailTitleImage' =>  '<td class="mobile-hide" width="108" align="right" valign="top" style="padding: 0 0 0 16px;"><a href="{0}" style="overflow: hidden; display: block; max-width: 108px; max-height: 108px; border: none; text-decoration: none;"><table width="108" height="108" align="center" cellspacing="0" cellpadding="0" border="0" style="border-collapse: collapse; border-spacing: 0; background-color: #ffffff; padding: 0; margin: 0;"><tbody><tr><td width="108" height="108" align="center" valign="middle" style="background-color: #f9f9f9; margin: 0; font-size: 18px; padding: 0; text-decoration: none; color: #ffffff; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;"><img src="{1}" alt="" width="108" height="108" style="border: none;"></td></tr></tbody></table></a></td>',
			/*{10} Event */
			/*{11} Event Badge*/
			/*{12} Site Name*/
			/*{13} Site link*/
			/*{14} Modified date*/
			/*{15} Author*/
			/*{16} Author Link*/
			/*{17} Month*/
			/*{18} Day*/
			/*{19} Must Read*/
			/*{20} Content type*/
			/*{21} In*/
			/*{22} By*/

		/*{11} Email Setting page link	
		/*{12} header backgroundcolor*/
		/*{13} footer backgroundcolor*/
		/*{14} header text color Applicable for date only.*/
		/*{15} footer text color Applicable for footer text only*/
		/*{16} footer color Applicable for all links/buttons in header and footer.*/
		/*{17} CSS media rule*/
		/*{18} Frequency */
		/*{19} app name*/
		/*{20} copyright*/
		/*{21} powered by */
		/*{22} appname*/
		/*{23} media css */

		'allDayEventRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;"> {2} </a> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;">All Day</span> </div> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;">{10}{11}</span> </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4} </p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'eventWithoutImageRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #fff; border: 1px solid #e6e6e6; border-collapse: separate; border-radius: 2px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-decoration: none; width: 100%;"> <tbody><tr> <td align="center" valign="top" class="CalendarMonth" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{8}; border-collapse: collapse; color: #fff; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: normal; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px 0; text-align: center; text-transform: uppercase; vertical-align: top;"> <a href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #fff; text-decoration: none;"> {17} </a> </td> </tr> <tr> <td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 60px; font-weight: 100; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: center; vertical-align: top;"> <a href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; text-decoration: none;"> {18} </a> </td> </tr> </tbody></table> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;"> {2} </a> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;"> {10} {11}</span> </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'pageWithoutImageRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="'+ EmailConstants.pageDefaultIconSquareIcon+'" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20} <span class="type--mustRead" style="color: #333;">{19}</span></span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;"> {2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;"> {12} </a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'pageRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20} <span class="type--mustRead" style="color: #333;">{19}</span></span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;"> {2}</a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;"> {12} </a> {14}</p> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td></tr>',
		'blogPostRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}</span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{22} <a href="{16}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;">{15} </a> on {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'blogWithoutImagePostRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="'+EmailConstants.blogDefaultIconSquareIcon+'" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}</span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;"> {2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{22} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;">{15}</a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'albumRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{2}</a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;">{12}</a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>'
	};
	/**
     * @description wrapper class for AiPageRecommendationsWrapper Obj
     */
	public class AiPageRecommendationsWrapper{
    	public Boolean isSuccess;
    	public Map<String, Set<String>> peopleVsContentIdsMap;
    }
}