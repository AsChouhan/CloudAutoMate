/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class NewsletterDataServer extends DataServer {
	public transient final String STR_ERROR_DATE_TIME_FUTURE_FLASH { get { return labelMap.get('newsletter_manage.date_time_future_error_flash');}}
	public transient final String STR_ERROR_REVIEW_NEWSLETTER_CONTENTS { get { return labelMap.get('newsletter_manage.deleted_unpublished_content_error_flash');}}
	@TestVisible private final String ACTION_VALUE_GET = 'get';
	@TestVisible private final String ACTION_VALUE_SAVE_DRAFT = 'saveDraft';
	@TestVisible private final String ACTION_VALUE_SAVE_UPDATE = 'update';
	@TestVisible private final String ACTION_VALUE_SAVE_DELETE = 'delete';
	@TestVisible private final String ACTION_VALUE_EDIT = 'edit';
	@TestVisible private final String ACTION_VALUE_SAVE_SCHEDULE = 'schedule';
	@TestVisible private final String ACTION_VALUE_SEND_PREVIEW = 'sendPreview'; 
	@TestVisible private final String ACTION_VALUE_SEND_NOW = 'sendNow';
	@TestVisible private final String ACTION_VALUE_NEWSLETTER_SEARCH = 'search';
	@TestVisible private final String ERROR_REVIEW_NEWSLETTER_CONTENTS = 'It\'s not possible to proceed, please review content added';
	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
    private final String REQUEST_PARAM_DATA = 'data';
    String currentUserId = UserContext.Id;
    Map<Id,Simpplr_Content__c> contentMap = null;
    
    /* whenever you modify below query , make sure you add the same field in SchedulerHourlySimpplrServices*/
    String contentBaseQuery = 'Select Is_Must_Read__c,Is_Deleted__c,Activated_By_Feature__c,Display_Excerpt__c,Summary_1__c,Type__c,Title__c,Text_Main__c,Event_End_DateTime__c,'+
			'Text_Main_Continued__c,Text_Intro__c,Status__c,Publish_Start_DateTime__c,Event_Is_All_Day__c,'+
			'Publish_End_DateTime__c,First_Publish_DateTime__c,Event_Start_DateTime__c,Event_TimezoneSidKey__c,'+
			'Site__c,Site__r.Landing_Page__c,Site__r.name,site__r.is_Active__c,Site__r.Chatter_Group_Id__c,Site__r.Show_In_Simpplr__c,Site__r.Is_Deleted__c,'+
			'Site__r.Site_Type__c, Site__r.Title_Content_Version__c, Primary_Author__c,Primary_Author__r.Full_Name__c, '+
			'Primary_Author__r.User__r.Id,Primary_Author__r.User__r.SmallPhotoUrl,'+
			'Id,CreatedDate,lastModifiedDate,Is_Published__c,Is_Unpublished__c,'+
			'(SELECT Id,Content_Version__c,Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Is_Title_Image__c=true)'+
			' from Simpplr_Content__c ';
    
    private Set<String>  allowedFeaturesInAppSet = new  Set<String>();
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }

    public override void handleRequest() {

        try {

	    	for (String feature : allowedFeaturesInAppList) {
		    	allowedFeaturesInAppSet.add(feature.toLowerCase());
		    }
	    	
        	String action = readParam(REQUEST_PARAM_ACTION);
	    	String requestData = readParam(REQUEST_PARAM_DATA);
			System.debug('..51....handleRequest().......requestData...' + requestData);


	        if (String.isBlank(action)) {
	        	throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
	        }

			if(ACTION_VALUE_SAVE_UPDATE.equalsIgnoreCase(action) || ACTION_VALUE_SAVE_DELETE.equalsIgnoreCase(action) 
					|| ACTION_VALUE_SAVE_SCHEDULE.equalsIgnoreCase(action) 
					|| ACTION_VALUE_SEND_PREVIEW.equalsIgnoreCase(action) || ACTION_VALUE_SEND_NOW.equalsIgnoreCase(action)){
				
				String newsletterId = readParam('newsletterId');
				if(String.isNotBlank(requestData)){
					Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
        			newsletterId = String.valueOf(requestDataMap.get('newsletterId'));
					if(AccessManager.hasNewsletterModerationAccess(newsletterId) ==  false){
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				} else if(String.isNotBlank(newsletterId)){
					if(AccessManager.hasNewsletterModerationAccess(newsletterId) ==  false){
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				} else {
					throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
				}
			}
			if(ACTION_VALUE_SAVE_DRAFT.equalsIgnoreCase(action)){
				if(String.isNotBlank(requestData)){
					Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
					NewsletterListingWrapper newsletterDataObj = (NewsletterListingWrapper)JSON.deserialize(Json.serialize(requestDataMap.get('data')), NewsletterListingWrapper.class);
					String siteId = newsletterDataObj.site != null ? newsletterDataObj.site.siteId : null;
					if(AccessManager.hasNewsletterCreateAccess(siteId) ==  false){
						throw new SimpplrException(ServiceConstants.ERROR_403);
					}
				} else {
					throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
				}
			}


	        if (ACTION_VALUE_SEND_PREVIEW.equalsIgnoreCase(action)) {
	        	response = sendPreview(requestData);
	        
			} else if (ACTION_VALUE_SEND_NOW.equalsIgnoreCase(action)) {
	        	response = sendNewsletter(requestData);

	        } else if (ACTION_VALUE_GET.equalsIgnoreCase(action)){
            	response = getNewsletter(readParam('newsletterId'));

            } else if (ACTION_VALUE_SAVE_DRAFT.equalsIgnoreCase(action)) {
            	response = saveDraft(requestData);

            } else if (ACTION_VALUE_SAVE_UPDATE.equalsIgnoreCase(action)) {
            	response = updateNewsletter(requestData);

            } else if (ACTION_VALUE_SAVE_DELETE.equalsIgnoreCase(action)) {
            	response = deleteNewsletter(readParam('newsletterId'));

            } else if (ACTION_VALUE_EDIT.equalsIgnoreCase(action)){
            	response = editNewsletter(readParam('newsletterId'));

            } else if (ACTION_VALUE_SAVE_SCHEDULE.equalsIgnoreCase(action)) {
            	response = scheduleNewsletter(requestData);

            } else if (ACTION_VALUE_NEWSLETTER_SEARCH.equalsIgnoreCase(action)) {
            	response = search(requestData);

            } else {
	            throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
	        }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
   	@TestVisible 
	private Set<Id> getContentIdSetOfNewsletter(List<Mailer_Details__c> mailerDetailList) {
    	Set<Id> contentIds = new Set<Id>();

		for (Mailer_Details__c mailerdetail : mailerDetailList) {

			if (String.isNotBlank(mailerdetail.Content__c)) {
				contentIds.add(mailerdetail.Content__c);
			}

		}

		return contentIds;
    }

   	@TestVisible 
	private ResponseWrapper sendPreview(String data) {
   		Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(data);
	    String newsletterId = String.valueOf(requestDataMap.get('newsletterId'));
	    String emailId = '';
	    
	   	if (requestDataMap.get('email') != null){
	    	emailId = String.valueOf(requestDataMap.get('email'));
	    }

    	List<NewsletterListingWrapper> NLWrapperList = new List<NewsletterListingWrapper>();
	    ResponseWrapper responseToReturn = null;
	    
	    try {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);

	    	String query = 'SELECT ' + 
					String.join(getNewsletterFieldList(),',') + 
					' FROM Mailer__c WHERE id=:soqlParam1 limit 1';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> mailerObjList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
    		
	    	if (mailerObjList.isEmpty() == false) {

	    		if (mailerObjList[0].Is_Deleted__c == true) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been deleted');
	    		}
	    		
	    		if ('Sent'.equalsIgnoreCase(mailerObjList[0].status__c)) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been sent');
	    		}
	    		
	    		if ('Draft'.equalsIgnoreCase(mailerObjList[0].status__c) && 
						mailerObjList[0].Sent_By__c!=UserContext.peopleId) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been drafted by someone');
	    		}
	    		
	    		if ('On Hold'.equalsIgnoreCase(mailerObjList[0].status__c)) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter is On Hold');
	    		}

	    		if (String.isNotBlank(mailerObjList[0].site__c) && 
						mailerObjList[0].Site__r.Is_Active__c == false) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is deactivated');
	    		}

	    		if (String.isNotBlank(mailerObjList[0].site__c) && 
						mailerObjList[0].Site__r.Show_In_Simpplr__c == false) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is unavailable');
	    		}

	    	} else {
	    		throw new SimpplrException('Newsletter must be saved before sending preview');
	    	}

			List<Id> audienceIdsList = new List<Id>();
			if(String.isNotBlank(mailerObjList[0].Audience__c)) {
				audienceIdsList.add(mailerObjList[0].Audience__c);
			}

			AudienceService audServiceObj = new AudienceService();
			Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);
	    	
			NewsletterListingWrapper wrapperObj = convertMailerToNewsletterListingWrapper(mailerObjList[0], audienceIdByWrapperMap, true);
			NLWrapperList.add(wrapperObj);
	    	Boolean isError = false;

			if (contentMap != null && !contentMap.keySet().isEmpty()) {

				for (Simpplr_Content__c scObj : contentMap.values()) {

					if (scObj.Is_Unpublished__c || scObj.Is_Deleted__c || 
							( (scObj.Type__c.equalsIgnoreCase('BlogPost') != true) && 
							(scObj.Site__r.Is_Active__c == false || 
							scObj.Site__r.Show_In_Simpplr__c == false || 
							scObj.Site__r.Is_Deleted__c)) || 
							(scObj.Activated_By_Feature__c == false || 
							!allowedFeaturesInAppSet.contains(scObj.Type__c.toLowerCase()))) {
						isError = true;
					}

				}

			}

    		if (isError) {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_REVIEW_NEWSLETTER_CONTENTS, NLWrapperList[0]);
    		
			} else { 
    			BatchNewsletter newsletterBatch = new BatchNewsletter(mailerObjList[0], null, true, false);
				newsletterBatch.sendPreview(emailId);

				if (mailerObjList[0].Test_Mailer_Sent__c == false) {
					Mailer__c mailerObj = mailerObjList[0];
					mailerObj.Test_Mailer_Sent__c = true;		
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(mailerObj, new List<Schema.SObjectField>{
																	Mailer__c.Test_Mailer_Sent__c});
				}

				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, 
						NLWrapperList[0]);
    		}

	     } catch (Exception e) {
        	logger.logError('Could not sent preview',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,
					MessageHelper.translateSFMessageToErrorCode(e), NLWrapperList[0]);
        }

    	return responseToReturn;
    }
    
   	@TestVisible 
   	private ResponseWrapper sendNewsletter(String data) {
    	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(data);
		NewsletterListingWrapper newsLetter = (NewsletterListingWrapper)JSON.deserialize(
				Json.serialize(requestDataMap.get('itemData')), NewsletterListingWrapper.class);
	    String newsletterId = String.valueOf(requestDataMap.get('newsletterId'));
	    
	    NewsletterListingWrapper nlWrapperObject = null;
	    ResponseWrapper responseToReturn = new ResponseWrapper();
	    
	    try {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);

	    	String query = 'SELECT ' + 
					String.join(getNewsletterFieldList(),',') + 
					' FROM Mailer__c WHERE id=:soqlParam1 limit 1';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> mailerObjList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	

			Mailer__c mailerObject = null;
			for(Mailer__c mailerObjectTemp : mailerObjList){
				mailerObject = mailerObjectTemp;

				break;
			}
	    	if (mailerObject != null) {

	    		if (mailerObject.Is_Deleted__c == true) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been deleted');
	    		}
	    		
	    		if ('Sent'.equalsIgnoreCase(mailerObject.status__c)) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been sent');
	    		}
	    		
	    		if ('Draft'.equalsIgnoreCase(mailerObject.status__c) && 
						mailerObject.Sent_By__c != UserContext.peopleId){
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been drafted by someone');
	    		}
	    		
	    		if ('On Hold'.equalsIgnoreCase(mailerObject.status__c)) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter is On Hold');
	    		}
	    		
	    		if (String.isNotBlank(mailerObject.site__c) && 
						mailerObject.Site__r.Is_Active__c == false) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is deactivated');
	    		}

	    		if (String.isNotBlank(mailerObject.site__c) && 
						mailerObject.Site__r.Show_In_Simpplr__c == false) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is unavailable');
	    		}

	    	} else {
	    		throw new SimpplrException('Newsletter must be saved before sending');
	    	}

			List<Id> audienceIdsList = new List<Id>();
			if(String.isNotBlank(mailerObject.Audience__c)) {
				audienceIdsList.add(mailerObject.Audience__c);
			}

			AudienceService audServiceObj = new AudienceService();
			Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);

			nlWrapperObject = convertMailerToNewsletterListingWrapper(mailerObject, audienceIdByWrapperMap, true);
			
	    	Boolean isError = false;

			if (contentMap != null && !contentMap.keyset().isEmpty()) {

				for (Simpplr_Content__c scObj : contentMap.values()) {
					
					if (scObj.Is_Unpublished__c || scObj.Is_Deleted__c || 
							((scObj.Type__c.equalsIgnoreCase('BlogPost') != true) && 
							(scObj.Site__r.Is_Active__c == false || 
							scObj.Site__r.Show_In_Simpplr__c == false || 
							scObj.Site__r.Is_Deleted__c)) || scObj.Activated_By_Feature__c == false || 
							!allowedFeaturesInAppSet.contains(scObj.Type__c.toLowerCase())) {
						isError = true;
					}

				}

			}

    		if (isError) {
    			// method to update status and wrapper
    			NewsletterListingWrapper NLWrapper = nlWrapperObject;

    			if ('scheduled'.equalsIgnorecase(mailerObject.Status__c)) {
		    		NLWrapper = updateStatusAndWrapper(mailerObject,nlWrapperObject,'On Hold',null);
    				NotificationDispatcher.sendNotificationForOnholdNewsletter(mailerObject.Sent_By__c, 
							mailerObject.Id, 'Unpublished Data');
	   				NotificationDispatcher.sendEmailForOnholdNewsletter(mailerObject.Sent_By__c, 
					   		mailerObject.Subject__c, mailerObject.Id, 'Unpublished Data');
    			}

				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
						STR_ERROR_REVIEW_NEWSLETTER_CONTENTS, NLWrapper);

    		} else {
				// method to update status and wrapper
				NewsletterListingWrapper NLWrapper = updateStatusAndWrapper(mailerObject, 
						nlWrapperObject, 'Sent', null);
    			BatchNewsletter newsletterBatch = new BatchNewsletter(mailerObject, null, false, 
						false);
                Database.executeBatch(newsletterBatch,25);
                createExternalSearchDataTrailRecord(NLWrapper.newsletterId);
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, NLWrapper);
	    	}

	     } catch(Exception e) {
        	logger.logError('Could not send newsletter',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), nlWrapperObject);
        }

    	return responseToReturn;
    }
     
    @TestVisible 
	private NewsletterListingWrapper updateStatusAndWrapper(Mailer__c mailerObj , 
	 		NewsletterListingWrapper newsletterWrapper , String status,String dateTimeStr ) {
		List<Schema.SObjectField> listOfModifiedFileds = new List<Schema.SObjectField>();
		if ('Sent'.equalsIgnoreCase(status)){
     		     		
     		mailerObj.Status__c = status;
			listOfModifiedFileds.add(Mailer__c.Status__c);
			if ('site'.equalsIgnoreCase(mailerObj.Recipient__c) && String.isNotBlank(mailerObj.site__c)) {
				if('site_members'.equals(newsletterWrapper.membersType)){
					SiteDao siteDaoObj = new SiteDao();
					mailerObj.Actual_Recipient_Count__c = siteDaoObj.getSiteMemberCount(mailerObj.site__c, null);
				}else {
					mailerObj.Actual_Recipient_Count__c = getCGMemberCount(mailerObj.site__c);
				}
	    		
	    	} else {
				if('segment'.equalsIgnoreCase(mailerObj.Recipient__c)) {
					AudienceService audServiceObj = new AudienceService();
					Audience__c audienceObj  = audServiceObj.getSegmentDefaultAudience(newsletterWrapper.segment.segmentId);
					mailerObj.Audience__c = audienceObj.Id;
					mailerObj.Actual_Recipient_Count__c = audienceObj.Audience_Member_Count__c;
				} else if('audience'.equalsIgnoreCase(mailerObj.Recipient__c)) {
					mailerObj.Audience__c = newsletterWrapper.audience.audienceId;
					AudienceService audServiceObj = new AudienceService();
					mailerObj.Actual_Recipient_Count__c = audServiceObj.getAudienceMemberCount(newsletterWrapper.audience.audienceId);
				} else {
					mailerObj.Actual_Recipient_Count__c = Utility.getTotalPeopleInSimpplr();
				}
	    	}
			listOfModifiedFileds.add(Mailer__c.Actual_Recipient_Count__c);
	    	Datetime currentTime = DateTime.now();
	    	mailerObj.Sent_Time__c = currentTime;
			listOfModifiedFileds.add(Mailer__c.Sent_Time__c);
     		newsletterWrapper.status = 'sent';
     		newsletterWrapper.sendAt = currentTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

     	} else if ('On Hold'.equalsIgnoreCase(status)) {
     		mailerObj.status__c = status;
     		newsletterWrapper.status = 'on_hold';
			listOfModifiedFileds.add(Mailer__c.status__c);

     	} else if ('Scheduled'.equalsIgnoreCase(status)) {
     		mailerObj.status__c = status;
     		mailerObj.Scheduled_date__c = stringToDateTime(dateTimeStr);
     		newsletterWrapper.status = 'scheduled';
     		newsletterWrapper.sendAt = dateTimeStr;
     		newsletterWrapper.isScheduled = true;
			listOfModifiedFileds.add(Mailer__c.status__c);
			listOfModifiedFileds.add(Mailer__c.Scheduled_date__c);
     	}
		 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(mailerObj, listOfModifiedFileds);
     	return newsletterWrapper;
     }
     
    private Integer getCGMemberCount (String recipientCollGrpId) {
    	Simpplr_Site__c siteObj = [select chatter_group_id__c 
				from simpplr_site__c 
				where id =:recipientCollGrpId WITH SECURITY_ENFORCED limit 1];
    	String grpId = siteObj.chatter_group_id__c;
    	CollaborationGroup cGMember = [select memberCount 
				from CollaborationGroup 
				where Id =:grpId WITH SECURITY_ENFORCED limit 1];
    	return cGMember.memberCount;
    }
    
    @TestVisible 
	private ResponseWrapper getNewsletter(String newsletterId) {
    	ResponseWrapper resultWrapper = New ResponseWrapper();

    	try {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);
			String query = 'SELECT '+String.join(getNewsletterFieldList(),',')+' FROM Mailer__c where id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> newsletterList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	

			if (newsletterList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
			} else {

	    		if (newsletterList[0].Is_Deleted__c == true) {
		    		throw new SimpplrException(ServiceConstants.ERROR_404);

	    		} else if (String.isNotBlank(newsletterList[0].site__c) && 
						newsletterList[0].Site__r.Is_Active__c == false) {
	    			throw new SimpplrException(ServiceConstants.ERROR_404);

	    		} else if (String.isNotBlank(newsletterList[0].site__c) && 
						newsletterList[0].Site__r.Show_In_Simpplr__c == false) {
		    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    		}

	    	}

			List<Id> audienceIdsList = new List<Id>();
			if(String.isNotBlank(newsletterList[0].Audience__c)) {
				audienceIdsList.add(newsletterList[0].Audience__c);
			}

			AudienceService audServiceObj = new AudienceService();
			Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);

			NewsletterListingWrapper wrapperObj = convertMailerToNewsletterListingWrapper(newsletterList[0], audienceIdByWrapperMap, true);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
					null, wrapperObj);

    	} catch (exception e) {
    		logger.logError('Exception Details', e);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }

        return resultWrapper;
    }
    
    @TestVisible 
	private ResponseWrapper saveDraft(String data) {
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	NewsletterListingWrapper newsletterDataObj;
    	try {
			Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(data);
			List<NewsletterListingWrapper> NLWrapperList = new List<NewsletterListingWrapper>();
			newsletterDataObj = (NewsletterListingWrapper)JSON.deserialize(Json.serialize(requestDataMap.get('data')), NewsletterListingWrapper.class); 
    		Set<Id> contentIds = new Set<Id>();

    		for (NewsletterListingWrapper.ContentListWrapper item: newsletterDataObj.listOfItems){
    			
				if (item.type.equalsIgnorecase('content')) {
    				contentIds.add(item.content.id);
    			}

    		}

    		contentMap = getContentMap(contentIds);
	    	Boolean isError = false;
	    	Map<Id, Simpplr_Content__c> unpublishedContentMap = new Map<Id, Simpplr_Content__c>();

	    	if ('site'.equalsIgnoreCase(newsletterDataObj.recipient)) {
		    	String siteid = newsletterDataObj.site.siteId;
		    	Simpplr_Site__c siteObj =[Select Is_Active__c, Show_In_Simpplr__c 
						from Simpplr_Site__c 
						where Id=:siteId WITH SECURITY_ENFORCED];
		    	
				if (siteObj.Is_Active__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is deactivated');
		    	
				} else if (siteObj.Show_In_Simpplr__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is unavailable');
		    	}

	    	}

	    	for (Simpplr_Content__c scObj : contentMap.values()) {
	    		
				if (scObj.Is_Unpublished__c || scObj.Is_Deleted__c || 
						((scObj.Type__c.equalsIgnoreCase('BlogPost') != true) && 
						(scObj.Site__r.Is_Active__c == false || 
						scObj.Site__r.Show_In_Simpplr__c == false || 
						scObj.Site__r.Is_Deleted__c)) || 
						scObj.Activated_By_Feature__c == false || 
						!allowedFeaturesInAppSet.contains(scObj.Type__c.toLowerCase())) {
	    			isError = true;
	    			unpublishedContentMap.put(scObj.id,scObj);
	    		}

    		}

    		if (isError) {

    			for (NewsletterListingWrapper.ContentListWrapper item : newsletterDataObj.listOfItems){
    				
					if ('Content'.equalsIgnoreCase(item.type)) {
	    				
						if (unpublishedContentMap.containsKey(item.content.id)) {
	    					Simpplr_Content__c scObj = unpublishedContentMap.get(item.content.id);
	    					
							if (scObj.Is_Unpublished__c) {
	    						item.content.isPublished = false;
	    						item.content.status = 'unpublished';

	    					} else if (scObj.Is_Deleted__c) {
	    						item.content.isDeleted = true;

	    					} else if (scObj.Activated_By_Feature__c == false || 
									!allowedFeaturesInAppSet.contains(scObj.Type__c.toLowerCase())) {
	    						item.content.isContentTypeActive = false;
	    					}

	    					if ((scObj.Type__c.equalsIgnoreCase('BlogPost') != true) && 
									(scObj.Site__r.Is_Active__c == false || 
									scObj.Site__r.Show_In_Simpplr__c == false || 
									scObj.Site__r.Is_Deleted__c)) {
	    						item.content.site.isActive = false;
	    					}

	    				}

    				}

    			}

    			throw new SimpplrException(STR_ERROR_REVIEW_NEWSLETTER_CONTENTS);

    		} else {
	    		// insert newsletter here if no unpublished/deleted content or deleted content's site found
	    		Mailer__c mailerObj = new Mailer__c();
				mailerObj.Introduction_Text__c =  newsletterDataObj.introduction;
				mailerObj.Introduction_Inlined__c = newsletterDataObj.introductionInlined;
				mailerObj.Name__c = newsletterDataObj.name;
				mailerObj.From_Address_Id__c = newsletterDataObj.fromAddressId;
				mailerObj.From_Address__c = null;
				
				if (String.isNotBlank(newsletterDataObj.fromAddressId)) {
					List<OrgWideEmailAddress> emailAdressList =[SELECT id, Address 
							FROM OrgWideEmailAddress 
							WHERE IsAllowAllProfiles = true AND
							id = :newsletterDataObj.fromAddressId];
																
					if (!emailAdressList.isEmpty()) {
						mailerObj.From_Address__c = emailAdressList[0].Address;
					}	

				}
				
				mailerObj.Banner_Url__c = newsletterDataObj.bannerUrl;
	    		mailerObj.Subject__c = newsletterDataObj.subject;

				mailerObj.Recipient__c = (newsletterDataObj.site != null && String.isNotBlank(newsletterDataObj.site.siteId)) ? 'site' : newsletterDataObj.recipient;
				mailerObj.Audience__c = null;
				mailerObj.Members_Type__c = null;

	    		if ('site'.equalsIgnoreCase(newsletterDataObj.recipient)) {
	    			mailerObj.Site__c = newsletterDataObj.site.siteId;
					
	    			String siteId = newsletterDataObj.site.siteId;
	    			Simpplr_Site__c siteObj = [select chatter_group_id__c 
							from Simpplr_Site__c 
							where id=:siteId WITH SECURITY_ENFORCED limit 1];
                    if ('site_members'.equalsIgnoreCase(newsletterDataObj.membersType)){
                        SiteDao siteDaoObj = new SiteDao();
                        mailerObj.Initial_Recipient_Count__c = siteDaoObj.getSiteMemberCount(siteId, null);
                    }else {
                        mailerObj.Initial_Recipient_Count__c = Utility.getCGMemberCount(siteObj.chatter_group_id__c);
                    }
					mailerObj.Members_Type__c = newsletterDataObj.membersType;
	    		} else {
					mailerObj.Site__c = null;
					if('segment'.equalsIgnoreCase(newsletterDataObj.recipient)) {
						AudienceService audServiceObj = new AudienceService();
						Audience__c audienceObj  = audServiceObj.getSegmentDefaultAudience(newsletterDataObj.segment.segmentId);
						mailerObj.Audience__c = audienceObj.Id;
						mailerObj.Initial_Recipient_Count__c = audienceObj.Audience_Member_Count__c;
					} else if('audience'.equalsIgnoreCase(newsletterDataObj.recipient)) {
						mailerObj.Audience__c = newsletterDataObj.audience.audienceId;
						AudienceService audServiceObj = new AudienceService();
						mailerObj.Initial_Recipient_Count__c = audServiceObj.getAudienceMemberCount(newsletterDataObj.audience.audienceId);
					} else {
	    				mailerObj.Initial_Recipient_Count__c = Utility.getTotalPeopleInSimpplr();
					}
	    		}

	    		mailerObj.Status__c = 'Draft';
	    		mailerObj.Sent_By__c = UserContext.peopleId;
	    		
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				mailerObj = (Mailer__c)SIMPESAPI.accessController().insertAsUser(mailerObj, new List<Schema.SObjectField>{
																Mailer__c.Introduction_Text__c,
																Mailer__c.Introduction_Inlined__c,
																Mailer__c.Name__c,
																Mailer__c.From_Address_Id__c,
																Mailer__c.From_Address__c,
																Mailer__c.Banner_Url__c,
																Mailer__c.Subject__c,
																Mailer__c.Recipient__c,
																Mailer__c.Members_Type__c,
																Mailer__c.Site__c,
																Mailer__c.Audience__c,
																Mailer__c.Initial_Recipient_Count__c,
																Mailer__c.Status__c,
																Mailer__c.Sent_By__c
														 });

	    		convertWrapperToMailerDetailObject(newsletterDataObj.listOfItems,mailerObj.id);
	    		String newsletterId = mailerObj.Id;			
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', newsletterId);
				
				String query = 'SELECT '+String.join(getNewsletterFieldList(),',')+' FROM Mailer__c where id=:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Mailer__c> newsletterList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
				
				List<Id> audienceIdsList = new List<Id>();
				if(String.isNotBlank(newsletterList[0].Audience__c)) {
					audienceIdsList.add(newsletterList[0].Audience__c);
				}

				AudienceService audServiceObj = new AudienceService();
				Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);
				
				newsletterDataObj =  convertMailerToNewsletterListingWrapper(newsletterList[0], audienceIdByWrapperMap, true);
                createExternalSearchDataTrailRecord(newsletterDataObj.newsletterId);
	    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, newsletterDataObj);
    		}
    		
    	} catch (exception e) {
    		logger.logError('NewsletterDataServer.saveDraft()----Exception Occured----', e);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(e), newsletterDataObj);
        }

        return resultWrapper;
    }
    
    public void convertWrapperToMailerDetailObject(List<NewsletterListingWrapper.ContentListWrapper> contentWrapperList,
			String newsletterId) {
        set<id> oldContentIds = new Set<Id>();
        set<id> newContentIds = new Set<Id>();
        List<Mailer_Details__c> listToAdd = new List<Mailer_Details__c>();
        List<Mailer_Details__c> listToUpdate = new List<Mailer_Details__c>();
        List<Mailer_Details__c> listToDelete = new List<Mailer_Details__c>();
        Map<Id, Mailer_Details__c> contentIdToMailerDetailMap = new Map<Id, Mailer_Details__c>();

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', newsletterId);
		String query = 'SELECT Id, Content__c, Order__c FROM Mailer_Details__c WHERE Mailer__c =: soqlParam1';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        for (Mailer_Details__c mailerDetailObj: (List<Mailer_Details__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap)) {
        	
			if (String.isBlank(mailerDetailObj.content__c)) {
        		listToDelete.add(mailerDetailObj);

        	} else {
        		contentIdToMailerDetailMap.put(mailerDetailObj.content__c, mailerDetailObj);
        	}

        }

        oldContentIds.addAll(contentIdToMailerDetailMap.keySet());
        Mailer_Details__c mailerDetailObj = null;
        
		for (NewsletterListingWrapper.ContentListWrapper newsletterContentObj: contentWrapperList) {
        	Boolean isShowCase = (newsletterContentObj.isShowcase != null) ? 
					newsletterContentObj.isShowcase : false;

        	if (newsletterContentObj.content == null) {
        		mailerDetailObj = new Mailer_Details__c();
                mailerDetailObj.Text__c = String.isNotBlank(newsletterContentObj.heading) ? 
						newsletterContentObj.heading : newsletterContentObj.text;
                mailerDetailObj.Mailer__c = newsletterId;
                mailerDetailObj.Order__c = newsletterContentObj.index;
                mailerDetailObj.Type__c = newsletterContentObj.type;
        		mailerDetailObj.Is_Showcase__c = isShowCase;
        		listToAdd.add(mailerDetailObj);

        	} else if (oldContentIds.contains(newsletterContentObj.content.id)) {
        		mailerDetailObj = new Mailer_Details__c(
        		Id = contentIdToMailerDetailMap.get(newsletterContentObj.content.id).Id,
				Order__c = newsletterContentObj.index,
				Is_Showcase__c = isShowCase);
        		listToUpdate.add(mailerDetailObj);

        	} else if (!oldContentIds.contains(newsletterContentObj.content.id)) {
        		mailerDetailObj = New Mailer_Details__c();
                mailerDetailObj.Mailer__c = newsletterId;
                mailerDetailObj.Order__c = newsletterContentObj.index;
                mailerDetailObj.Content__c = newsletterContentObj.content.id;
                mailerDetailObj.Type__c = newsletterContentObj.type;
                mailerDetailObj.Text__c = '';
        		mailerDetailObj.Is_Showcase__c = isShowCase;
                listToAdd.add(mailerDetailObj);
        	}
        	
        	if (newsletterContentObj.content != null) {
        		newContentIds.add(newsletterContentObj.content.id);
        	}

        }

        oldContentIds.removeAll(newContentIds);

        for (Id contentId : oldContentIds) {

        	if (contentIdToMailerDetailMap.containsKey(contentId)) {
        		listToDelete.add(contentIdToMailerDetailMap.get(contentId));
        	}

        }

        if (listToAdd.size() > 0) {
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(listToAdd, 
				new List<Schema.SObjectField>{
				Mailer_Details__c.Mailer__c,
				Mailer_Details__c.Content__c,
				Mailer_Details__c.Order__c,
				Mailer_Details__c.Type__c,
				Mailer_Details__c.Text__c,
				Mailer_Details__c.Is_Showcase__c
			});

        }
        
        if (listToDelete.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listToDelete);
        }
        
        if (listToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Mailer_Details__c>(listToUpdate), new List<Schema.SObjectField>{
						Mailer_Details__c.Is_Showcase__c,Mailer_Details__c.Order__c});
        }

    }
    
    
   @TestVisible 
   private DateTime stringToDateTime(String dateTimeString) {

    	if (String.isBlank(dateTimeString)) {
    		return null;
    	}

        String year = dateTimeString.substring(0, 4);
		String month = dateTimeString.substring(5, 7);
		String day = dateTimeString.substring(8, 10);
		String hour = dateTimeString.substring(11, 13);
		String minute = dateTimeString.substring(14, 16);
		String second = dateTimeString.substring(17, 19);
        DateTime returnDate = DateTime.newInstance(Integer.valueOf(year), 
			Integer.valueOf(month), Integer.valueOf(day), 
			Integer.valueOf(hour), Integer.valueOf(minute), Integer.valueOf(second));

        return returnDate;
    }
    
     @TestVisible 
	 private ResponseWrapper updateNewsletter(String data) {
    	Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(data);
        String newsletterId = String.valueOf(requestDataMap.get('newsletterId')); 
        NewsletterListingWrapper newsletterData = (NewsletterListingWrapper)JSON.deserialize(
				Json.serialize(requestDataMap.get('itemData')), NewsletterListingWrapper.class);
        newsletterData.newsletterId = newsletterId;
        List<NewsletterListingWrapper> NLWrapperList = new List<NewsletterListingWrapper>();
    	ResponseWrapper resultWrapper = new ResponseWrapper();

    	try {

	    	if (data == null || String.isBlank(data)) {
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
			List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
	        Set<Id> contentIds = new Set<Id>();
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);
			String query = 'SELECT '+String.join(getNewsletterFieldList(),',')+' FROM Mailer__c where id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> newsletterList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
	    	logger.logDebug(query);
	    	//when draft is opened by same user in two tabs
	    	if ('sent'.equalsIgnoreCase(newsletterList[0].Status__c) || 
					newsletterList[0].Is_Deleted__c == true || 
					(String.isNotBlank(newsletterList[0].site__c) && 
					(newsletterList[0].Site__r.Is_Active__c == false || 
					newsletterList[0].Site__r.Show_In_Simpplr__c == false) )) {

			    if ('sent'.equalsIgnoreCase(newsletterList[0].Status__c)) {
			    	throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been sent');
			    }
				
				if (newsletterList[0].Is_Deleted__c == true) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been deleted');
		    	} 

		    	if (String.isNotBlank(newsletterList[0].site__c) && 
						newsletterList[0].Site__r.Is_Active__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is deactivated');
		    	}

		    	if (String.isNotBlank(newsletterList[0].site__c) && 
						newsletterList[0].Site__r.Show_In_Simpplr__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is unavailable');
		    	}

	    	}

    		for (NewsletterListingWrapper.ContentListWrapper item: newsletterData.listOfItems) {
    			
				if (item.type.equalsIgnorecase('content')) {
    				contentIds.add(item.content.id);
    			}

    		}

    		contentMap = getContentMap(contentIds);
	    	Boolean isError = false;

	    	for (Simpplr_Content__c scObj: contentMap.values()) {

	    		if (scObj.Is_Unpublished__c || scObj.Is_Deleted__c || 
						((scObj.Type__c.equalsIgnoreCase('BlogPost') != true) && 
						(scObj.Site__r.Is_Active__c == false || 
						scObj.Site__r.Show_In_Simpplr__c == false || 
						scObj.Site__r.Is_Deleted__c)) || 
						scObj.Activated_By_Feature__c == false || 
						!allowedFeaturesInAppSet.contains(scObj.Type__c.toLowerCase())) {
	    			isError = true;

	    		}

    		}

    		if (isError) {
    			//convert to wrapper again using content id as details might have changed
    			newsletterData.listOfItems = getNewsletterWrapperList(newsletterData.listOfItems,contentMap);
				newsletterData.status = 'draft';
    			newsletterData.isDeleted = false;

    			if ('Site'.equalsIgnoreCase(newsletterData.recipient)) {
    				String siteId = newsletterData.site.siteId;
    				List<Simpplr_Site__c> siteList = [select id, Is_Active__c, name, 
							Chatter_Group_Id__c, Site_Type__c, Landing_Page__c, 
							Title_Content_Version__c 
							from simpplr_site__c 
							where id=: siteId WITH SECURITY_ENFORCED];
    				newsletterData.site.title = siteList[0].name;
    				newsletterData.site.img = String.isBlank(siteList[0].Title_Content_Version__c) ? null:Utility.getFileDownloadURLFor720By480(siteList[0].Title_Content_Version__c);
		        	newsletterData.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteList[0].Site_Type__c);
		        	newsletterData.site.isActive = siteList[0].Is_Active__c;
    			}

    			newsletterData.recipientCount = newsletterList[0].Actual_Recipient_Count__c == null ?
						Integer.valueOf(newsletterList[0].Initial_Recipient_Count__c) : Integer.valueOf(newsletterList[0].Actual_Recipient_Count__c);
    			newsletterData.canEdit = true;
    			newsletterData.canDelete = true;
    			String peopleId = UserContext.peopleId;
    			List<People__c> peopleList = [Select Id, User__c, user__r.Id, Full_Name__c, 
						User__r.SmallPhotoUrl 
						from People__c 
						where Id =:peopleId WITH SECURITY_ENFORCED];
    			newsletterData.authoredBy = new PeopleLiteWrapper();
    			newsletterData.authoredBy.userId = peopleList[0].User__c;
		        newsletterData.authoredBy.peopleId = peopleList[0].Id;
		        newsletterData.authoredBy.name = peopleList[0].Full_Name__c;
		        newsletterData.authoredBy.img = peopleList[0].User__r.SmallPhotoUrl.endsWith('005/T') ? null : peopleList[0].User__r.SmallPhotoUrl;
		        newsletterData.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleList[0].Id;
	    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
						STR_ERROR_REVIEW_NEWSLETTER_CONTENTS, newsletterData);

    		} else {
	        	Mailer__c mailerObj = newsletterList[0];
		        mailerObj.Introduction_Text__c =  newsletterData.introduction;
				mailerObj.Introduction_Inlined__c = newsletterData.introductionInlined;
		        mailerObj.Name__c = newsletterData.name;
				mailerObj.From_Address_Id__c = newsletterData.fromAddressId;
				listOfModifiedFields.add(Mailer__c.Introduction_Text__c);
				listOfModifiedFields.add(Mailer__c.Introduction_Inlined__c);
				listOfModifiedFields.add(Mailer__c.Name__c);
				listOfModifiedFields.add(Mailer__c.From_Address_Id__c);
				if (String.isNotBlank(newsletterData.fromAddressId)) {
					List<OrgWideEmailAddress> emailAdressList =[SELECT id, Address 
					FROM OrgWideEmailAddress 
					WHERE
			    	IsAllowAllProfiles = true AND
					id = :newsletterData.fromAddressId];
																
					if (!emailAdressList.isEmpty()) {
						mailerObj.From_Address__c = emailAdressList[0].Address;
						listOfModifiedFields.add(Mailer__c.From_Address__c);
					}			

				}
				
				mailerObj.Banner_Url__c = newsletterData.bannerUrl;
				listOfModifiedFields.add(Mailer__c.Banner_Url__c);
	    		if (String.isNotBlank(newsletterData.subject)) {
	    			mailerObj.Subject__c = newsletterData.subject;
					listOfModifiedFields.add(Mailer__c.Subject__c);
	    		}

	    		if ('site'.equalsIgnoreCase(newsletterData.recipient)) {
	    			mailerObj.Site__c = newsletterData.site.siteId;
					mailerObj.Audience__c = null;
					listOfModifiedFields.add(Mailer__c.Site__c);
					listOfModifiedFields.add(Mailer__c.Audience__c);
	    		} else {
					mailerObj.Site__c = null;
					listOfModifiedFields.add(Mailer__c.Site__c);
					if('segment'.equalsIgnoreCase(newsletterData.recipient)) {
						AudienceService audServiceObj = new AudienceService();
						Audience__c audienceObj  = audServiceObj.getSegmentDefaultAudience(newsletterData.segment.segmentId);
						mailerObj.Audience__c = audienceObj.Id;
						mailerObj.Initial_Recipient_Count__c = audienceObj.Audience_Member_Count__c;
						listOfModifiedFields.add(Mailer__c.Audience__c);
						listOfModifiedFields.add(Mailer__c.Initial_Recipient_Count__c);
					} else if('audience'.equalsIgnoreCase(newsletterData.recipient)) {
						mailerObj.Audience__c = newsletterData.audience.audienceId;
						AudienceService audServiceObj = new AudienceService();
						mailerObj.Initial_Recipient_Count__c = audServiceObj.getAudienceMemberCount(newsletterData.audience.audienceId);
						listOfModifiedFields.add(Mailer__c.Audience__c);
						listOfModifiedFields.add(Mailer__c.Initial_Recipient_Count__c);
					} else {
	    				mailerObj.Initial_Recipient_Count__c = Utility.getTotalPeopleInSimpplr();
						listOfModifiedFields.add(Mailer__c.Initial_Recipient_Count__c);
					}
				}

				mailerObj.Recipient__c = (newsletterData.site != null && String.isNotBlank(newsletterData.site.siteId)) ? 'site' : newsletterData.recipient;
				listOfModifiedFields.add(Mailer__c.Recipient__c);
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        		SIMPESAPI.accessController().updateAsUser(mailerObj,listOfModifiedFields);
	    		convertWrapperToMailerDetailObject(newsletterData.listOfItems, mailerObj.id);
				List<Mailer__c> mailerList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);				List<Id> audienceIdsList = new List<Id>();
				if(String.isNotBlank(mailerList[0].Audience__c)) {
					audienceIdsList.add(mailerList[0].Audience__c);
				}

				AudienceService audServiceObj = new AudienceService();
				Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);
				
				newsletterData = convertMailerToNewsletterListingWrapper(mailerList[0], audienceIdByWrapperMap, true);
                createExternalSearchDataTrailRecord(newsletterData.newsletterId);
                resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, newsletterData);
    		}
    		
    	} catch (exception e) {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(e), newsletterData);
        }

        return resultWrapper;
    }
    
    @TestVisible 
	private ResponseWrapper deleteNewsletter(String newsletterId) {
    	logger.logDebug('NewsletterDataServer.deleteNewsletter()---newsletterId---' + newsletterId);
    	ResponseWrapper resultWrapper = new ResponseWrapper();

    	try {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);
			String query = 'select id, is_deleted__c, status__c, ' 
								+ ' sent_by__c, ' 
								+ ' (select id from Mailer_Details_Mailer__r where Is_Deleted__c = false) ' 
								+ ' from Mailer__c where id=:soqlParam1 and Is_Deleted__c = false limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> mailerList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			if (mailerList.isEmpty()) {
    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been deleted'); 
    		
			} else if ('Draft'.equalsIgnoreCase(mailerList[0].status__c) && 
					mailerList[0].Sent_By__c!=UserContext.peopleId ) {
    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been drafted by someone');
    		
			} else if ('sent'.equalsIgnoreCase(mailerList[0].status__c)) {
    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been sent');
    		}

    		Mailer__c mailerObj = mailerList[0];
    		mailerObj.Is_Deleted__c = true;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(mailerObj, new List<Schema.SObjectField>{
																Mailer__c.Is_Deleted__c});
																
           	createExternalSearchDataTrailRecord(mailerObj.id); 
    		List<Mailer_Details__c>	mailerDetailList = mailerList[0].Mailer_Details_Mailer__r;
    		for (Mailer_Details__c mailerDetailObj :mailerDetailList) {
    			mailerDetailObj.Is_Deleted__c = true;
    		}

    		//update newsletterMailerObj;
    		if (mailerDetailList.isEmpty() == false) {
    			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        		SIMPESAPI.accessController().updateAsUser(new Map<Id,Mailer_Details__c>(mailerDetailList), new List<Schema.SObjectField>{
        										Mailer_Details__c.Is_Deleted__c});
    		}

    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

    	} catch (exception e) {
    		logger.logError('Exception Details', e);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(e), null);
        }

        return resultWrapper;
    }
    
    @TestVisible 
	private ResponseWrapper editNewsletter(String newsletterId) {
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	NewsletterListingWrapper wrapperObj;

    	try {
	    	Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);
			String query = 'SELECT '+String.join(getNewsletterFieldList(),',')+' FROM Mailer__c where id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> newsletterList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
	    	if (newsletterList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);

	    	} else if (newsletterList.isEmpty() == false) {

	    		if (newsletterList[0].Is_Deleted__c == true) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been deleted');
	    		}
	    		
	    		if ('Sent'.equalsIgnoreCase(newsletterList[0].status__c)) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been sent');
	    		}
	    		
	    		if ('Draft'.equalsIgnoreCase(newsletterList[0].status__c) && 
						newsletterList[0].Sent_By__c!=UserContext.peopleId) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been drafted by someone');
	    		}

	    		if (String.isNotBlank(newsletterList[0].site__c) && 
						newsletterList[0].Site__r.Is_Active__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is deactivated');
		    	}

		    	if (String.isNotBlank(newsletterList[0].site__c) && 
						newsletterList[0].Site__r.Show_In_Simpplr__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is unavailable');
		    	}

	    		if ('On Hold'.equalsIgnoreCase(newsletterList[0].status__c)) {
	    			Mailer__c objToUpdate = newsletterList[0];
	    			objToUpdate.Status__c = 'Draft';
	    			objToUpdate.Sent_By__c = UserContext.peopleId;
	    			objToUpdate.Scheduled_Date__c = null;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        			SIMPESAPI.accessController().updateAsUser(objToUpdate, new List<Schema.SObjectField>{
														Mailer__c.Status__c,Mailer__c.Sent_By__c,Mailer__c.Scheduled_Date__c});

					List<Id> audienceIdsList = new List<Id>();
					if(String.isNotBlank(newsletterList[0].Audience__c)) {
						audienceIdsList.add(newsletterList[0].Audience__c);
					}

					AudienceService audServiceObj = new AudienceService();
					Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);
					
	    			wrapperObj = convertMailerToNewsletterListingWrapper(newsletterList[0], audienceIdByWrapperMap, true);
	    		}
				//Added for SV2-33162 Scheduled newletter should not go to draft after clicking cancel on edit
				if ('Scheduled'.equalsIgnoreCase(newsletterList[0].status__c)) {
					List<Id> audienceIdsList = new List<Id>();
					if(String.isNotBlank(newsletterList[0].Audience__c)) {
						audienceIdsList.add(newsletterList[0].Audience__c);
					}
					AudienceService audServiceObj = new AudienceService();
					Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);
	    			wrapperObj = convertMailerToNewsletterListingWrapper(newsletterList[0], audienceIdByWrapperMap, true);
	    		}
	    	} 
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, 
					wrapperObj);
    	} catch (exception e) {
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), wrapperObj);
		}
        return resultWrapper;
    }
    
    @TestVisible 
	private ResponseWrapper scheduleNewsletter(String data) {
		System.debug('......scheduleNewsletter()...START...');
		System.debug('..1152....scheduleNewsletter()...data...' + data);

    	if (data == null || String.isBlank(data)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());

        }

        Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(data);
		System.debug('..1161....scheduleNewsletter()...requestDataMap...' + requestDataMap);

        NewsletterListingWrapper newsLetter = (NewsletterListingWrapper)JSON.deserialize(Json.serialize(requestDataMap.get('itemData')), 
				NewsletterListingWrapper.class);
		System.debug('..1167....scheduleNewsletter()...newsLetter...' + newsLetter);

	    String newsletterId = String.valueOf(requestDataMap.get('newsletterId'));
		System.debug('..1170....scheduleNewsletter()...newsletterId...' + newsletterId);

	    newsLetter.newsletterId = newsletterId;
	    ResponseWrapper responseToReturn = new ResponseWrapper();
		NewsletterListingWrapper nLWrapperObject = null;

	    try {
	    	Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);
			String query = 'SELECT '+String.join(getNewsletterFieldList(),',')+' FROM Mailer__c where id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> mailerObjList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			System.debug('..1182....scheduleNewsletter()...mailerObjList...' + mailerObjList);

			Mailer__c mailerObject = null;
			for(Mailer__c mailerObj : mailerObjList){
				mailerObject = mailerObj;

				break;
			}
			if (mailerObject != null) {
	    		
				if (mailerObject.Is_Deleted__c == true) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been deleted');
	    		}
	    		
	    		if ('Sent'.equalsIgnoreCase(mailerObject.status__c)) {
	    			throw new SimpplrException('It\'s not possible to perform this action - Newsletter has already been sent');
	    		}
	    		
	    		if (String.isNotBlank(mailerObject.site__c) && 
						mailerObject.Site__r.Is_Active__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is deactivated');
		    	}
	    		
	    		if (String.isNotBlank(mailerObject.site__c) && 
						mailerObject.Site__r.Show_In_Simpplr__c == false) {
		    		throw new SimpplrException('It\'s not possible to perform this action - Newsletter\'s Site is unavailable');
		    	}
		    	
	    	} else {
	    		throw new SimpplrException('Newsletter must be saved before scheduling');
	    	}
			
	    	Boolean isError = false;

			List<Id> audienceIdsList = new List<Id>();
			if(mailerObject != null && String.isNotBlank(mailerObject.Audience__c)) {
				audienceIdsList.add(mailerObject.Audience__c);
			}
			
			AudienceService audServiceObj = new AudienceService();
			Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);

			nLWrapperObject = convertMailerToNewsletterListingWrapper(mailerObject, audienceIdByWrapperMap, true);
			Set<Id> contentIds = new Set<Id>();

    		for (NewsletterListingWrapper.ContentListWrapper item: newsLetter.listOfItems) {
    			
				if (item.type.equalsIgnorecase('content')) {
    				contentIds.add(item.content.id);
    			}

    		}

    		contentMap = getContentMap(contentIds);

	    	if (contentMap != null && !contentMap.keySet().isEmpty()) {

				for (Simpplr_Content__c scObj: contentMap.values()) {

					if(scObj.Is_Unpublished__c || scObj.Is_Deleted__c || 
							((scObj.Type__c.equalsIgnoreCase('BlogPost') != true) && 
							(scObj.Site__r.Is_Active__c == false || 
							scObj.Site__r.Show_In_Simpplr__c == false || 
							scObj.Site__r.Is_Deleted__c)) || scObj.Activated_By_Feature__c == false || 
							!allowedFeaturesInAppSet.contains(scObj.Type__c.toLowerCase())) {
						isError = true;
					}

				}
			}

    		if (isError) {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_REVIEW_NEWSLETTER_CONTENTS, nLWrapperObject);
    		
			} else if (stringToDateTime(newsLetter.sendAt)<DateTime.now()){
    			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
						STR_ERROR_DATE_TIME_FUTURE_FLASH, newsLetter);
    		
			} else {
    			NewsletterListingWrapper NLWrapper = updateStatusAndWrapper(mailerObject, nLWrapperObject, 'Scheduled', newsLetter.sendAt);
				createExternalSearchDataTrailRecord(NLWrapper.newsletterId);
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, NLWrapper);
	    	}

    	} catch (exception e) {
			logger.logError('NewsletterDataServer.scheduleNewsletter()-----could not retrieve data----',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, nLWrapperObject);
        }
		System.debug('..1270....scheduleNewsletter()...responseToReturn...' + responseToReturn);

        return responseToReturn;
    }

	private void createExternalSearchDataTrailRecord(String newsletterId) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
		obj.Mailer__c = newsletterId;
		obj.Type__c = 'Newsletter';
		SIMPESAPI.accessController().insertAsUser(obj, new List<Schema.SObjectField>{
			External_Search_Data_Trail__c.Mailer__c,External_Search_Data_Trail__c.Type__c});
	}
    
    @TestVisible 
	private Map<Id,Simpplr_Content__c> getContentMap(Set<Id> contentIdSet) {
    	List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();

		if (!contentIdSet.isEmpty()) {
			String queryStr = contentBaseQuery + ' where Id IN :contentIdSet';
			contentList = Database.query(queryStr);
		}

		Map<Id, Simpplr_Content__c> contentIdToContentMap = new Map<Id, 
				Simpplr_Content__c>(contentList);
		return contentIdToContentMap;
    }
    
     @TestVisible 
	 private Map<Id,CollaborationGroup> getListedCollabGrpIManageMap() {
    	String userId = UserContext.Id;
    	String BASE_QUERY = 'SELECT Id, SmallPhotoUrl,CollaborationType,description,InformationBody,MemberCount,OwnerId, '+
    	        '(SELECT Id,CollaborationRole FROM GroupMembers WHERE memberId=:userId AND CollaborationRole = \'Admin\') '+
    	        'FROM CollaborationGroup where IsArchived=false ';
    	List<CollaborationGroupMember> memberList;
    	Set<Id> cgGrpIdSet = new Set<Id>();
    	String unlistedCondition = '';

    	if (UserContext.hasManageUnlistedSitePermission) {
    		unlistedCondition += ' OR Collaborationtype = \'Unlisted\'';
    	}

    	if (UserContext.hasModifyAllDataPermission) {

    	} else if (UserContext.isUserAppModerator || UserContext.canSendNewsletter) {
    		memberList = [SELECT Id,CollaborationRole,CollaborationGroupId 
					FROM CollaborationGroupMember 
    				WHERE memberId=:userId AND CollaborationRole = 'Admin' WITH SECURITY_ENFORCED];

    		for (CollaborationGroupMember cgMember: memberList) {
				cgGrpIdSet.add(cgMember.CollaborationGroupId);
			}

    		BASE_QUERY = BASE_QUERY + ' AND (Id IN:cgGrpIdSet OR CollaborationType =\'Public\'' 
					+ unlistedCondition+')';
    	
		} else {
    		memberList = [SELECT Id, CollaborationRole, CollaborationGroupId 
					FROM CollaborationGroupMember 
    				WHERE memberId=:userId AND CollaborationRole = 'Admin' WITH SECURITY_ENFORCED];

    		for (CollaborationGroupMember cgMember: memberList) {
				cgGrpIdSet.add(cgMember.CollaborationGroupId);
			}

    		BASE_QUERY = BASE_QUERY + ' AND (Id IN:cgGrpIdSet'+unlistedCondition+')';
    	}
    	
		if (SimpplrContext.isCommunitiesEnabled) {
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}

		BASE_QUERY = BASE_QUERY + ' WITH SECURITY_ENFORCED';

		Map<Id, CollaborationGroup> collabGrpMap = new Map<Id, CollaborationGroup>((List<CollaborationGroup>)Database.query(BASE_QUERY));
		return collabGrpMap;
    }
    
    @TestVisible 
	private ResponseWrapper search(String data) {
    	ResponseWrapper resultWrapper = New ResponseWrapper();

    	try {
	    	
			if (data == null || String.isBlank(data)) {
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }

	        Map<String, Object> requestdataMap = (Map<String, Object>)JSON.deserializeUntyped(data);
			String searchTerm = requestdataMap.get('term')==null ? '':String.valueOf(requestdataMap.get('term'));
			String filter = requestdataMap.get('filter')==null ? '':String.valueOf(requestdataMap.get('filter'));
			String recipient = requestdataMap.get('recipient')==null ? '':String.valueOf(requestdataMap.get('recipient'));
			String sortBy = requestdataMap.get('sortBy')==null ? '':String.valueOf(requestdataMap.get('sortBy'));
			String orderBy = '';		
			String order = '';
			Integer size = requestdataMap.get('size') != null ? Integer.valueOf(requestdataMap.get('size')) : 0; 
			Integer nextPageToken = requestdataMap.get('nextPageToken') == null ? 0 : Integer.valueOf(requestdataMap.get('nextPageToken'));
			
			if (!String.isblank(sortBy)) {

				if (sortBy.equalsIgnoreCase('createdNewest') || 
						sortBy.equalsIgnoreCase('createdOldest')) {
					orderBy = 'CreatedDate';
					order = sortBy.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';

				} else if (sortBy.equalsIgnoreCase('sendAtNewest') || 
						sortBy.equalsIgnoreCase('sendAtOldest')) {
					orderBy = 'Send_Time__c';
					order = sortBy.equalsIgnoreCase('sendAtNewest') ? 
							'DESC NULLS LAST' : 'ASC NULLS LAST';
				}

			}

			List<Mailer__c> newsletterList = new List<Mailer__c>();
			Map<Id, CollaborationGroup> listedCGIManageMap = getListedCollabGrpIManageMap();
    		Set<Id> listedCGIManageSet = listedCGIManageMap.keySet();
    		String siteQuery = 'SELECT Name,Id, Chatter_Group_Id__c, Site_Type__c,'+ 
					' Landing_Page__c, Is_Active__c, '+
    				' Is_Featured__c,Title_Content_Version__c '+
    				' FROM Simpplr_Site__c WHERE is_Active__c=true '+ 
    				' AND is_Deleted__c=false AND chatter_Group_Id__c != \'S06I000000MPPLR\' ' +
    				' AND Show_in_Simpplr__c = true ';

    		if ((UserContext.hasModifyAllDataPermission || UserContext.isUserAppModerator || 
					UserContext.canSendNewsletter) == false) {
    			siteQuery = siteQuery + ' AND Is_Newsletter_Allowed__c = true ';
    		}

    		siteQuery = siteQuery + ' AND Chatter_Group_Id__c IN:listedCGIManageSet WITH SECURITY_ENFORCED order by Name ';
			
			map<Id, Simpplr_Site__c> siteMap = new map<Id, Simpplr_Site__c>((List<Simpplr_Site__c>)DataBase.query(siteQuery));
			List<NewsletterListingWrapper> newsletterWrapperList= new List<NewsletterListingWrapper>();
			
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(searchTerm)) {
				
				Criteria.ExternalSearchReq newsletterCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(data, Criteria.ExternalSearchReq.class);
				
				if('scheduled'.equalsIgnoreCase(filter)){
					newsletterCriteria.status= 'Scheduled';
				}else if('draft'.equalsIgnoreCase(filter)){
					newsletterCriteria.status= 'Draft';
				}else if('on_hold'.equalsIgnoreCase(filter)){
					newsletterCriteria.status= 'On Hold';
				}else if('sent'.equalsIgnoreCase(filter)){
					newsletterCriteria.status= 'Sent';
				}else{
					newsletterCriteria.status= 'All';
				}

				Set<Id> siteSet=new Set<Id>();
				if(!siteMap.isEmpty()){
					siteSet=siteMap.keySet();
					newsletterCriteria.siteSet=siteSet;
				}
				if('createdOldest'.equalsIgnoreCase(sortBy)){
					newsletterCriteria.sortBy='created_date_oldest';
				}else if('createdNewest'.equalsIgnoreCase(sortBy)){
					newsletterCriteria.sortBy='created_date_newest';
				}else if('sendAtNewest'.equalsIgnoreCase(sortBy)){
					newsletterCriteria.sortBy='send_date_newest';
				}else if('sendAtOldest'.equalsIgnoreCase(sortBy)){
					newsletterCriteria.sortBy='send_date_oldest';
				}

				
				newsletterCriteria.recipient=recipient;
				
				ExternalSearchService externalSearchServiceObj=new ExternalSearchService();
				String SearchForType='Newsletter';
				ExternalSearchWrapper.TopContentsWrapper returnWrapperObj=externalSearchServiceObj.searchNewsletters(newsletterCriteria, SearchForType);
				List<String> newsletterIds = new List<String>();
				if(returnWrapperObj.listOfItems != null && returnWrapperObj.listOfItems.size() > 0) {
				 	newsletterIds = getNewsletterIdsFromAWSResponse(returnWrapperObj.listOfItems, newsletterCriteria);
				}
				newsletterList = getNewsletterListFromSF(newsletterIds,orderBy,order);

			}else{
				newsletterList = getNewsletterListFromCriteria(filter, recipient, 
						searchTerm, orderBy, order, size, nextPageToken, siteMap);
			}	
			newsletterWrapperList = convertNewsletterListTowrapperList(newsletterList);
			nextPageToken = newsletterWrapperList.size() < size ? null : nextPageToken + size;
			Map<String, Object> result = new Map<String, Object>();
	        result.put('listOfItems', newsletterWrapperList);
	        result.put('nextPageToken', nextPageToken);
	        Map<String, Object> siteFilterOptions = new Map<String, Object>(); 
        	List<siteWrapper> siteWrapperLst = new List<siteWrapper>();

			if (siteMap.size() > 0) {

				for (Simpplr_Site__c siteObj: siteMap.values()) {
					siteWrapper siteWrapperObj = new siteWrapper();
					siteWrapperObj.id = siteObj.Id;
					siteWrapperObj.title = siteObj.Name;
					siteWrapperLst.add(siteWrapperObj);
				}

			}

			siteFilterOptions.put('sites', siteWrapperLst);
			result.put('filterOptions', siteFilterOptions);
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);

    	} catch (exception e) {
    		
			if (String.isNotBlank(e.getMessage())) {
    			logger.logError('Exception Details NewsletterDataServer.search()', e);
	        	
				if (e.getMessage().containsIgnoreCase('Could not update status for newsletter')) {
	        		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
							STR_ERROR_REVIEW_NEWSLETTER_CONTENTS, null);
	        	
				} else {
	        		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        	}

    		} else {
        		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    		}

        }

        return resultWrapper;
    }

    private NewsletterListingWrapper convertMailerToNewsletterListingWrapper(Mailer__c newsletterRecord, 
			Map<Id, AudienceWrapper> audienceIdByWrapperMap,
			Boolean includeMailerDetails) {
		NewsletterListingWrapper wrapperobj = new NewsletterListingWrapper();
		wrapperobj.url = '';
		wrapperobj.totalClickCount = Integer.valueOf(newsletterRecord.Total_Click_Count__c);
		wrapperobj.uniqueClickCount = Integer.valueOf(newsletterRecord.Unique_Click_Count__c);
		wrapperobj.openCount = Integer.valueOf(newsletterRecord.Open_Count__c);
		wrapperobj.newsletterId = newsletterRecord.Id;
		wrapperobj.introductionInlined = newsletterRecord.Introduction_Inlined__c;
		wrapperobj.name  = newsletterRecord.Name__c;
		wrapperobj.fromAddress = newsletterRecord.From_Address__c;
		wrapperobj.fromAddressId = newsletterRecord.From_Address_Id__c;
		wrapperobj.bannerUrl = newsletterRecord.Banner_Url__c;
		
		wrapperobj.recipient = newsletterRecord.Recipient__c;
		wrapperobj.recipientCount = newsletterRecord.Actual_Recipient_Count__c == null ? Integer.valueOf(newsletterRecord.Initial_Recipient_Count__c):Integer.valueOf(newsletterRecord.Actual_Recipient_Count__c);
		
		if('segment'.equalsIgnoreCase(newsletterRecord.Recipient__c)) {
			wrapperobj.segmentId = newsletterRecord.Audience__r.Segment__c;
			wrapperobj.segment = new AudienceWrapper.SegmentLiteWrapper();
			wrapperobj.segment.id = newsletterRecord.Audience__r.Segment__c;
			wrapperobj.segment.segmentId = newsletterRecord.Audience__r.Segment__c;
			wrapperobj.segment.name = newsletterRecord.Audience__r.Segment__r.Name__c;
		} else if('audience'.equalsIgnoreCase(newsletterRecord.Recipient__c)) {
			if(String.isBlank(newsletterRecord.Audience__c)) {
				wrapperobj.audience = new AudienceWrapper();
				wrapperobj.audience.isDeleted = true;
			} else {
				wrapperobj.audienceId = newsletterRecord.Audience__c;
				wrapperobj.audience = audienceIdByWrapperMap.get(newsletterRecord.Audience__c);
			}
		}

		if ('On Hold'.equalsignoreCase(newsletterRecord.Status__c)) {
			wrapperobj.status = 'on_hold';

		} else {
			wrapperobj.status = newsletterRecord.Status__c.toLowerCase();
		}

		if ('On Hold'.equalsignoreCase(newsletterRecord.Status__c) || 
				'Scheduled'.equalsignoreCase(newsletterRecord.Status__c) || 
				('Draft'.equalsignoreCase(newsletterRecord.Status__c) && 
				newsletterRecord.Sent_By__c == UserContext.peopleId)) {
			wrapperobj.canEdit = true;

		} else {
			wrapperobj.canEdit = false;
		}

		wrapperobj.introduction = newsletterRecord.Introduction_Text__c;
		wrapperobj.subject = newsletterRecord.Subject__c;

		if (('On Hold'.equalsignoreCase(newsletterRecord.Status__c) && 
				String.isNotBlank(String.valueOf(newsletterRecord.Scheduled_Date__c))) || 
				'Scheduled'.equalsignoreCase(newsletterRecord.Status__c)) {
			wrapperobj.sendAt = newsletterRecord.Scheduled_Date__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); 
			
		} else if ('Sent'.equalsignoreCase(newsletterRecord.Status__c)) {
			wrapperobj.sendAt = newsletterRecord.Sent_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		
		} else {
			wrapperobj.sendAt = null;
		}
		
		wrapperobj.sentAt = null;
		
		if (newsletterRecord.Sent_Time__c != null) {
			wrapperobj.sentAt = newsletterRecord.Sent_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		
		wrapperobj.createdAt = newsletterRecord.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperobj.modifiedAt = newsletterRecord.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.authoredBy = new PeopleLiteWrapper();
		wrapperObj.authoredBy.userId = newsletterRecord.Sent_By__r.User__r.Id;
		wrapperObj.authoredBy.peopleId = newsletterRecord.Sent_By__c;
		wrapperObj.authoredBy.name = newsletterRecord.Sent_By__r.Full_Name__c;
		wrapperObj.authoredBy.img = newsletterRecord.Sent_By__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : newsletterRecord.Sent_By__r.User__r.SmallPhotoUrl;
		wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + 
				'?u=/people/' + newsletterRecord.Sent_By__c;

		if (String.isNotBlank(newsletterRecord.Site__c)) {
			wrapperobj.site = new SiteLiteWrapper();
			wrapperObj.site.siteId = newsletterRecord.Site__c;
			wrapperObj.site.name = newsletterRecord.Site__r.name;
			wrapperObj.site.title = newsletterRecord.Site__r.name;
			wrapperObj.site.chatterGroupId = newsletterRecord.Site__r.Chatter_Group_Id__c;
			wrapperObj.site.img = String.isBlank(newsletterRecord.Site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(newsletterRecord.Site__r.Title_Content_Version__c);			
			wrapperObj.site.imgThumbnail = String.isBlank(newsletterRecord.Site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor120BY90(newsletterRecord.Site__r.Title_Content_Version__c);
			wrapperObj.site.url = PageContext.getPageURL(Pages.app) + 
					'?u=/site/' + newsletterRecord.Site__c + '/' + 
					newsletterRecord.Site__r.Landing_Page__c;
			wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(newsletterRecord.Site__r.Site_Type__c);
			wrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(newsletterRecord.Site__r.Site_Type__c);
			wrapperObj.site.isActive = newsletterRecord.Site__r.Is_Active__c;
			wrapperobj.membersType = newsletterRecord.Members_Type__c;

		} else {
			wrapperobj.site = null;
		}

		List<Mailer_Details__c> recordsList = newsletterRecord.Mailer_Details_Mailer__r;
		
		if (includeMailerDetails) {
			List<NewsletterListingWrapper.ContentListWrapper> listOfNLContListWrap = new List<NewsletterListingWrapper.ContentListWrapper>();
			listOfNLContListWrap = getMailerDetails(newsletterRecord.Id);
			if (!listOfNLContListWrap.isEmpty()) {
				wrapperobj.listOfItems.addAll(listOfNLContListWrap);
			}
		}

		wrapperobj.canDelete = 'Sent'.equalsignoreCase(newsletterRecord.Status__c) ? false : true;
		wrapperobj.isDeleted = newsletterRecord.Is_Deleted__c;
		return wrapperobj;
	}

   	@TestVisible 
	private List<NewsletterListingWrapper> convertNewsletterListTowrapperList(List<Mailer__c> newsletterList) {
    	List<NewsletterListingWrapper> wrapperList = new List<NewsletterListingWrapper>();

		List<Id> audienceIdsList = new List<Id>();
		for (Mailer__c newsletterRecord : newsletterList) {
			if(String.isNotBlank(newsletterRecord.Audience__c)) {
				audienceIdsList.add(newsletterRecord.Audience__c);
			}
		}

		AudienceService audServiceObj = new AudienceService();
		Map<Id, AudienceWrapper> audienceIdByWrapperMap = audServiceObj.getAudienceIdByWrapperMap(audienceIdsList);

    	for (Mailer__c newsletterRecord : newsletterList) {
        	wrapperList.add(convertMailerToNewsletterListingWrapper(newsletterRecord, audienceIdByWrapperMap, false));
        }

        return wrapperList;
    }
    
    @TestVisible 
	private List<NewsletterListingWrapper.ContentListWrapper> convertNewsletterContentsListTowrapperList(
			List<Mailer_Details__c> recordsList, Map<Id, Simpplr_Content__c> contentIdToContentMap) {
        List<NewsletterListingWrapper.ContentListWrapper> result = new List<NewsletterListingWrapper.ContentListWrapper>();
		Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
		Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;

        if (recordsList != null && recordsList.size() > 0) {
            
			for (Mailer_Details__c mailerDetailRecord: recordsList) {
        		result.add(convertNewsletterContentToWrapper(mailerDetailRecord, 
						contentIdToContentMap, sitesIManageIdSet, sitesIManageContentsIdSet));
            }

        }

        return result;
    }
    
     @TestVisible 
	 private List<NewsletterListingWrapper.ContentListWrapper> getNewsletterWrapperList(
		 	List<NewsletterListingWrapper.ContentListWrapper> wrapperList, 
			Map<Id, Simpplr_Content__c> contentIdToContentMap) {
        List<NewsletterListingWrapper.ContentListWrapper> result = new List<NewsletterListingWrapper.ContentListWrapper>();
		Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
		Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;

        if (wrapperList != null && wrapperList.size() > 0) {
            
			for (NewsletterListingWrapper.ContentListWrapper wrapperObj: wrapperList) {
        		result.add(getNewsletterWrapperObj(wrapperObj, contentIdToContentMap, 
				sitesIManageIdSet, sitesIManageContentsIdSet));
            }
        }

        return result;
    }
    
    private NewsletterListingWrapper.ContentListWrapper convertNewsletterContentToWrapper(
			Mailer_Details__c mailerDetailRecord, Map<Id, Simpplr_Content__c> contentIdToContentMap, 
			Set<Id> sitesIManageIdSet, Set<Id> sitesIManageContentsIdSet) {
    	NewsletterListingWrapper.ContentListWrapper wrapperObj = new NewsletterListingWrapper.ContentListWrapper();
		
		if ('text'.equalsIgnoreCase(mailerDetailRecord.Type__c)) { 
    		wrapperObj.text = mailerDetailRecord.Text__c;

    	} else if ('heading'.equalsIgnoreCase(mailerDetailRecord.Type__c)) {
    		wrapperObj.heading = mailerDetailRecord.Text__c;
		
		} else {
			if (contentIdToContentMap != null && 
					contentIdToContentMap.containskey(mailerDetailRecord.Content__c)) {
				wrapperObj.content= convertContentToWrapper(contentIdToContentMap.get(mailerDetailRecord.Content__c), 
						sitesIManageIdSet, sitesIManageContentsIdSet, new Map<String, String>());
			} else {
				ContentWrapper contentWrapObj = new ContentWrapper();
				contentWrapObj.isDeleted = true;
				wrapperObj.content= contentWrapObj;
			}
		}

    	wrapperObj.type = mailerDetailRecord.Type__c.toLowerCase();    	

    	wrapperObj.index = Integer.valueOf(mailerDetailRecord.Order__c);
    	wrapperObj.isShowcase = mailerDetailRecord.Is_Showcase__c;
    	return wrapperObj;
    }
    
    private NewsletterListingWrapper.ContentListWrapper getNewsletterWrapperObj(
			NewsletterListingWrapper.ContentListWrapper wrapperObj, 
			Map<Id, Simpplr_Content__c> contentIdToContentMap, Set<Id> sitesIManageIdSet, Set<Id> sitesIManageContentsIdSet) {
    	NewsletterListingWrapper.ContentListWrapper newWrapperObj = new NewsletterListingWrapper.ContentListWrapper();
    	
		if (wrapperObj.content == null) {
    		newWrapperObj = wrapperObj;

    	} else {
    		newWrapperObj.index = wrapperObj.index;
    		newWrapperObj.type = 'content';
    		newWrapperObj.content = convertContentToWrapper(contentIdToContentMap.get(
					wrapperObj.content.id), sitesIManageIdSet, sitesIManageContentsIdSet, new Map<String, String>());
    	}

    	return newWrapperObj;
    }
    
	private List<String> getNewsletterIdsFromAWSResponse(List<ExternalSearchWrapper.ItemWrapper> listOfItems, Criteria.ExternalSearchReq newsletterCriteria) {
		List<String> newsletterIds = new List<String>();

		for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems) {
			Object item = itemWrapperObj.item;
			NewsletterListingWrapper nlWrapper = (NewsletterListingWrapper)item;

			newsletterIds.add(nlWrapper.newsletterId);
		}
		return newsletterIds;
	}

	private List<Mailer__c> getNewsletterListFromSF(List<String> newsletterIds, String orderBy, String order) {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', newsletterIds);
		String query = 'SELECT '+String.join(getNewsletterFieldList(),',')+' FROM Mailer__c where id=:soqlParam1';
		if (String.isNotBlank(orderBy)) {
			query+=' ORDER BY '+orderBy+' '+order;
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer__c> mailerObjList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		logger.logDebug('NewsletterDataServer.getNewsletterListFromSF()----query----' + query);
        return mailerObjList;
	}			

    @TestVisible 
	private List<Mailer__c> getNewsletterListFromCriteria(String filter, String recipient, 
			String searchText, String orderBy, String order, Integer recordLimit, 
			Integer offsetVal, Map<Id, Simpplr_Site__c> siteMap) {
		String conditionString = '';
		String subConditionString = '';
		String conditionStringForChildRecords = '';
		Set<Id> sitesIdSet = new Set<Id> ();
		String currentPeopleRecordId = UserContext.peopleId;
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		conditionString += ' Is_Deleted__c = false';

		if (String.isBlank(filter) || 'everyone'.equalsIgnoreCase(filter)) {
			soqlParamMap.put('soqlParam1', currentPeopleRecordId);
			conditionString += ' AND (Status__c!=\'Draft\' OR (Status__c = \'Draft\' AND Sent_By__c=:soqlParam1))';		
		
		} else if ('draft'.equalsIgnoreCase(filter)) {
			soqlParamMap.put('soqlParam1', currentPeopleRecordId);
			conditionString += ' AND Status__c = \'Draft\' AND Sent_By__c=:soqlParam1';		
		
		} else if ('on_hold'.equalsIgnoreCase(filter)) {
			conditionString += ' AND Status__c = \'On Hold\'';

		} else {
			soqlParamMap.put('soqlParam1', filter);
			conditionString += ' AND Status__c =: soqlParam1';
		}

		sitesIdSet.addAll(siteMap.keySet());

		if ('everyone'.equalsIgnoreCase(recipient)) { // Only All-Org newsletters
			conditionString += ' AND Recipient__c = \'everyone\'';

		} else if (String.isBlank(recipient)) {
			soqlParamMap.put('soqlParam2', sitesIdSet);
			if (UserContext.hasModifyAllDataPermission || UserContext.canSendNewsletter || 
					UserContext.isUserAppModerator) {
				conditionString += ' AND (Site__c = null OR Site__c IN:soqlParam2)';

			} else {
				conditionString += ' AND Site__c IN:soqlParam2';
			}
			

		} else {
			soqlParamMap.put('soqlParam2', recipient);
			conditionString += ' AND Site__c =:soqlParam2';
			
		}

		Set<Id> mailerIdSet = new Set<Id>();

		if (String.isNotBlank(searchText)) {
			Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
			String queryOnTheBasisOfSearchTerm = 'SELECT mailer__c FROM Mailer_Details__c WHERE Is_Deleted__c = false ';
			
			for (String searchToken : setOfSearchTerms) {
				queryOnTheBasisOfSearchTerm += ' AND ((Content__c != null AND (Content__r.Title__c like \'%' + searchToken + '%\' OR Content__r.Display_Excerpt__c like \'%' + searchToken + '%\')) ';
				queryOnTheBasisOfSearchTerm += ' OR Mailer__r.Sent_By__r.Full_Name__c like \'%' + searchToken+'%\' ';
				queryOnTheBasisOfSearchTerm += ' OR Mailer__r.Subject__c like \'%' + searchToken+'%\' ';
				queryOnTheBasisOfSearchTerm += ' OR Mailer__r.Name__c like \'%' + searchToken+'%\') ';
			}
			 
	     	logger.logDebug('NewsletterDataServer.getNewsletterListFromCriteria() ---- queryOnTheBasisOfSearchTerm----' + queryOnTheBasisOfSearchTerm);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
	     	List<Mailer_Details__c> mailerDetailList =(List<Mailer_Details__c>)SIMPESAPI.accessController().queryAsUSer(queryOnTheBasisOfSearchTerm, null);

	     	for (Mailer_Details__c mailerDetailObj: mailerDetailList) {
	     		mailerIdSet.add(mailerDetailObj.mailer__c);
	     	}	

		}

		if (mailerIdSet.size() > 0) {
			soqlParamMap.put('soqlParam3', mailerIdSet);
	     	conditionString += ' AND Id IN:soqlParam3';		

	    } else if (String.isNotBlank(searchText)) {
	    	return new List<Mailer__c>();
	    }

		//query formation
		conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';

		if (String.isNotBlank(orderBy)) {
			subConditionString+=' ORDER BY '+orderBy+' '+order;
		}
		
		if (recordLimit != null && recordLimit > 0) {
			soqlParamMap.put('soqlParam4', recordLimit);
			subConditionString+=' LIMIT :soqlParam4';		
		}

		if (offsetVal != null && offsetVal > 0) {
			soqlParamMap.put('soqlParam5', offsetVal);
			subConditionString+=' OFFSET :soqlParam5';
		}


		String query = 'SELECT ' + String.join(getNewsletterFieldList(),',') + 
				' FROM Mailer__c'+conditionString+subConditionString;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer__c> mailerObjList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		
		logger.logDebug('NewsletterDataServer.getNewsletterListFromCriteria()----query----' + query);
        return mailerObjList;
	}
	
	public static List<String> getNewsletterFieldList() {
    	return New List<String> {
    		'Id',
            'Name__c',
            'Is_Deleted__c',
            'Open_Count__c',
            'Total_Click_Count__c',
            'Unique_Click_Count__c',
            'Test_Mailer_Sent__c',
            'Actual_Recipient_Count__c',
            'Initial_Recipient_Count__c',
			'Audience__c',
			'Audience__r.Name__c',
			'Recipient__c',
			'Audience__r.Segment__c',
			'Audience__r.Segment__r.Name__c',
            'From_Address__c',
            'From_Address_Id__c',
            'Introduction_Inlined__c',
            'Introduction_Text__c',
            'Job_Id__c', 
            'Scheduled_Date__c', 
            'Sent_By__c',
            'Sent_By__r.User__r.Id', 
            'Sent_By__r.Full_Name__c',
            'Sent_By__r.User__r.SmallPhotoUrl',
            'Sent_Time__c',
            'Status__c',
            'Site__c',
            'Site__r.name',
            'Site__r.Is_Active__c',
            'Site__r.Show_In_Simpplr__c',
            'Site__r.Chatter_Group_Id__c',
            'Site__r.Site_Type__c',
            'Site__r.Landing_Page__c',
			'Site__r.Title_Content_Version__c',
			'Members_Type__c',
            'Banner_Url__c',
            'Subject__c',
            'CreatedDate',
			'lastModifiedDate'
        };
    }
    
	@TestVisible 
	private List<NewsletterListingWrapper.ContentListWrapper> getMailerDetails(Id mailerId) {
		List<NewsletterListingWrapper.ContentListWrapper> result = new List<NewsletterListingWrapper.ContentListWrapper>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', mailerId);
		String query = 'SELECT Id, Is_Deleted__c, Mailer__c, '
				+ ' content__r.Is_Must_Read__c, Order__c, Content__c, ' 
				+ ' Content__r.Last_Edited_DateTime__c, '
				+ ' content__r.Activated_By_Feature__c, content__r.site__c, '
				+ ' content__r.Event_Is_All_Day__c, ' 
				+ ' content__r.Event_Start_Datetime__c, content__r.Event_End_Datetime__c, content__r.Event_TimezoneSidKey__c, '
				+ ' content__r.type__c, Content__r.Primary_Author__c, '
				+ ' Content__r.Primary_Author__r.Full_Name__c,content__r.Title__c, ' 
				+ ' content__r.Display_Excerpt__c, '
				+ ' Content__r.Is_Unpublished__c, Content__r.Is_Deleted__c, '
				+ ' Content__r.Site__r.Landing_Page__c, '
				+ ' Content__r.Site__r.Is_Active__c, Content__r.Site__r.Is_Deleted__c, '
				+ ' Content__r.Site__r.Show_In_Simpplr__c, Content__r.Site__r.Name, ' 
				+ ' Content__r.Site__r.Title_Content_Version__c, '
				+ ' Text__c,Type__c,Is_Showcase__c  '
				+ ' FROM Mailer_Details__c ' 
				+ ' WHERE Mailer__c =:soqlParam1 '
				+ ' order by Order__c asc ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer_Details__c> mailerDetailsList = (List<Mailer_Details__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		if (!mailerDetailsList.isEmpty()) {
			Set<Id> contentIds = getContentIdSetOfNewsletter(mailerDetailsList);
			contentMap = getContentMap(contentIds);
			Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
			Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;

			for (Mailer_Details__c mailerDetailRecord : mailerDetailsList) {
				result.add(convertNewsletterContentToWrapper(mailerDetailRecord, 
					contentMap, sitesIManageIdSet, sitesIManageContentsIdSet));
			}
		}

		return result;
    }
    
   
    @TestVisible 
	private List<ContentWrapper> convertContentsListTowrapperList(List<Simpplr_Content__c> recordsList, 
			Map<String, String> contentIdSentDateMap) {
        List<ContentWrapper> result = new List<ContentWrapper>();
		Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
		Set<Id> sitesIManageContentsIdSet = UserContext.sitesIManageContentsIdSet;

        if (recordsList != null && recordsList.size() > 0) {

            for (Simpplr_Content__c contentRecord: recordsList) {
        		result.add(convertContentToWrapper(contentRecord, sitesIManageIdSet, sitesIManageContentsIdSet,
					contentIdSentDateMap));
            }

        }

        return result;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible 
	private ContentWrapper convertContentToWrapper(Simpplr_Content__c contentRecord, 
			Set<Id> sitesIManageIdSet, Set<Id> sitesIManageContentsIdSet, Map<String, String> contentIdSentDateMap) {
        ContentWrapper wrapperObj  = new ContentWrapper();
        wrapperObj.isMustRead = contentRecord.is_must_read__c;
        wrapperObj.id = contentRecord.id; 
        wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c) ? '':contentRecord.Display_Excerpt__c.unescapeHtml4();
    	wrapperObj.summary = String.isBlank(contentRecord.Summary_1__c) ? '' : contentRecord.Summary_1__c.unescapeHtml4();
        wrapperObj.isPublished = contentRecord.Is_Published__c;
        wrapperObj.isContentTypeActive = (allowedFeaturesInAppSet.contains(
				contentRecord.Type__c.toLowerCase()) && 
				contentRecord.Activated_By_Feature__c == true) ? true : false;
        wrapperObj.isDeleted = contentRecord.Is_Deleted__c;

        if (contentRecord.Status__c != null) {
        	
			if (ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentRecord.Status__c)) {
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_PENDING;
        	
			} else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentRecord.Status__c)) {
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_DRAFT.toLowerCase();
        	
			} else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(contentRecord.Status__c)) { 
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_REJECTED.toLowerCase();

        	} else if (contentRecord.Is_Published__c) {
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_PUBLISH.toLowerCase();

        	} else if (contentRecord.Is_Unpublished__c) {
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_UNPUBLISH.toLowerCase();

        	} else if (ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentRecord.Status__c)) {
				wrapperObj.status = ServiceConstants.CONTENT_STATUS_APPROVED.toLowerCase();
			}

        }

        wrapperObj.siteId = contentRecord.Site__c;

        if (ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentRecord.Type__c)) {
            wrapperObj.url = PageContext.getPageURL(Pages.app) + 
					'?u=/site/' + contentRecord.site__c + '/page/' + contentRecord.Id ;                                          

        } else if (ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c)) {
            wrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + 
					contentRecord.site__c + '/event/'+contentRecord.Id;                                           

        } else if (ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)) {
            wrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + 
					contentRecord.site__c + '/album/' + contentRecord.Id;                                           

        } else if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.Type__c)) {
            wrapperObj.url = PageContext.getPageURL(Pages.app) + 
					'?u=/people/' + contentRecord.Primary_Author__c + '/blog/' + contentRecord.Id;                                          
        }

        wrapperObj.editUrl = wrapperObj.url + '/edit';
        List<File__c> titleFilesList = contentRecord.File_Simpplr_Content__r;
        wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, 
				contentRecord.Title__c.length(), false);

        if (titleFilesList.size() > 0) {
        	
			for (File__c fileObj : titleFilesList) {
        		
				if (ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)) {

        			if (fileObj.Is_Title_Image__c) {

	        			if (String.isNotBlank(fileObj.Content_Version__c)) {
	        				wrapperObj.img = Utility.getFileDownloadURLFor240BY180(fileObj.Content_Version__c);
	        				wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
        				
						} else {
        					wrapperObj.img = fileObj.Thumbnail_URL__c;
        					wrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;
        				}

	        			break;
	        		}

        		} else {

        			if (fileObj.Title_Image_Type__c == 'Thumbnail' && fileObj.Is_Title_Image__c) {
        				wrapperObj.img = Utility.getFileDownloadURLFor240BY180(
								fileObj.Content_Version__c);
        				
	        		} else if (fileObj.Title_Image_Type__c == 'WideScreen' && 
							fileObj.Is_Title_Image__c) {
	        			wrapperObj.imgLandscape = Utility.getFileDownloadURL(
								fileObj.Content_Version__c);
	        		}

        		}

        	}

        }

        if ('BlogPost'.equalsIgnoreCase(contentRecord.Type__c)) {
        	wrapperObj.type = 'blog_post';

        } else {
        	wrapperObj.type = contentRecord.Type__c;
        }
        
        if ('Event'.equalsIgnoreCase(contentRecord.Type__c)) {
			TimeZone tz = Timezone.getTimeZone(contentRecord.Event_TimezoneSidKey__c);
			wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentRecord.Event_TimezoneSidKey__c);
			wrapperObj.timezoneIso = tz.getID();
			wrapperObj.timezoneOffset = tz.getOffset(system.today());
			
			wrapperObj.startsAt = contentRecord.Event_Start_DateTime__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		    DateTime endDateTimeValue = contentRecord.Event_End_DateTime__c;

		    if ('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
		    	endDateTimeValue = contentRecord.Event_End_DateTime__c.addMinutes(-1);
		    }

		    wrapperObj.endsAt = endDateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		    wrapperObj.isAllDay = contentRecord.Event_Is_All_Day__c;

		    if (contentRecord.Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
		    	wrapperObj.isMultiDay = false;
		    
			} else {
		    	wrapperObj.isMultiDay = true;
		    }

        }
        
        wrapperObj.createdAt = contentRecord.createdDate == null ? '':Utility.dateToDisplayString(contentRecord.createdDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        wrapperObj.publishAt = contentRecord.Publish_Start_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Publish_Start_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        wrapperObj.publishTo = contentRecord.Publish_End_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Publish_End_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        wrapperObj.modifiedAt = contentRecord.lastModifiedDate == null ? '':Utility.dateToDisplayString(contentRecord.lastModifiedDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        wrapperObj.authoredBy = new PeopleListWrapper();
        wrapperObj.authoredBy.userId = contentRecord.Primary_Author__r.User__r.Id;
        wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.name = contentRecord.Primary_Author__r.Full_Name__c;
        wrapperObj.authoredBy.img = contentRecord.Primary_Author__r.User__r.SmallPhotoUrl;
        wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentRecord.Primary_Author__c;
        
		if (String.isNotBlank(contentRecord.Site__c)) {
	        wrapperObj.site = new SiteLiteWrapper();
	        wrapperObj.site.siteId = contentRecord.Site__c;
	        wrapperObj.site.name = contentRecord.Site__r.name;
	        wrapperObj.site.url = PageContext.getPageURL(Pages.app) + 
					'?u=/site/' + contentRecord.Site__c + '/' + 
					contentRecord.Site__r.Landing_Page__c; 
	        wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
        	wrapperObj.site.isActive = contentRecord.Site__r.Is_Active__c && !contentRecord.Site__r.Is_Deleted__c;
			
			wrapperObj.site.img = String.isBlank(contentRecord.Site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(contentRecord.Site__r.Title_Content_Version__c);
			wrapperObj.site.imgThumbnail = String.isBlank(contentRecord.Site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor120BY90(contentRecord.Site__r.Title_Content_Version__c);
        }

		Boolean isSiteManager = sitesIManageIdSet.contains(contentRecord.Site__c);
		Boolean isContentManager = sitesIManageContentsIdSet.contains(contentRecord.Site__c);
		
		wrapperObj.canPublishUnpublish = (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(wrapperObj.type) ? true : AccessManager.calculatePublishUnpublishAccess(isSiteManager, isContentManager, wrapperObj.status, wrapperObj.authoredBy.userId, contentRecord.Site__r.Site_Type__c));
        wrapperObj.canModerate = AccessManager.calculateModerateAccess(isSiteManager, isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.userId, contentRecord.Site__r.Site_Type__c);
        wrapperObj.canDelete = ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(wrapperObj.type) ? true :
        		 AccessManager.calculateDeleteAccess(isSiteManager, isContentManager, wrapperObj.status, wrapperObj.authoredBy.userId, 
        		 contentRecord.Site__r.Site_Type__c);
        wrapperObj.canEdit = ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(wrapperObj.type) ? true : 
        		AccessManager.calculateEditAccess(isSiteManager, isContentManager, wrapperObj.status, wrapperObj.authoredBy.userId, 
        		contentRecord.Site__r.Site_Type__c);
        wrapperObj.newsletterLastSentAt = contentIdSentDateMap.get(contentRecord.id);
        return wrapperObj;
    }
    
    private class siteWrapper {
    	String id;
    	String title;
    }
    
}