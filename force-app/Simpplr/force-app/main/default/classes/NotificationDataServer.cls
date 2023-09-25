/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class NotificationDataServer extends DataServer{
	public static String baseUrl = BaseCtrl.salesForceBaseUrl;
	private final String REQUEST_PARAM_DATA = 'data';
	private final String ACTION_VALUE_SEARCH = 'search'; 
	private final String ACTION_VALUE_CREATE = 'create'; 
	private final String ACTION_VALUE_MARK_ALL_NON_ACTIONABLE_AS_READ = 'markAllNonActionableAsRead';
	private final String ACTION_VALUE_MARK_ALL_TYPE_AS_SEEN = 'markAllTypeAsSeen';
	private final String ACTION_VALUE_MARK_AS_ACTIONED = 'markAsActioned';
	private final String ACTION_VALUE_SEND_NOTIFICATION = 'sendNotification';
	private final String ACTION_VALUE_GET_NOTIFICATION_MESSAGE = 'getNotificationMessage';
	private final String ACTION_SEND_MOBILE_PROMOTION_LINK = 'sendMobilePromotionLink';	
	private final String ACTION_SEND_BRANDED_APP_DISTRIBUTION_LINK = 'sendBrandedAppDistributionLink';
	private final String ACTION_BULK_SEND_BRANDED_APP_DISTRIBUTION_LINK = 'buldSendBrandedAppDistributionLink';
	private final String ACTION_VALUE_SEND_NOTIFICATION_IN_APP_PUSH = 'sendInAppPushNotifications';
	private final String ACTION_SEND_EMAIL = 'sendEmail';

	/* 
	private final String STR_KEY_BRANDED_APP_NO_CODE_ERROR = 'notification.branded_apps.no_codes_error';
	private final String STR_KEY_BRANDED_APP_ALL_CODE_USED_ERROR = 'notification.branded_apps.all_codes_used_error';
	private final String STR_KEY_BRANDED_APP_NO_LOCATION_CODE_ERROR = 'notification.branded_apps.no_codes_in_user_location';
	private final String STR_KEY_BRANDED_APP_FAILED_TO_SEND_UPLOAD_MORE_CODES = 'notification.branded_apps.failed_to_send_upload_more_codes';
	private final String STR_KEY_BRANDED_APP_FAILED_TO_SEND_TO_ALL = 'notification.branded_apps.failed_to_send_to_all';
	private final String STR_KEY_BRANDED_APP_INVALID_INPUT = 'notification.branded_apps.invalid_input';
	private final String STR_KEY_BRANDED_APP_USER_NOT_FOUND = 'notification.branded_apps.user_not_found';
	*/
	
	public NotificationDataServer() {

    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
	
    public override void handleRequest() {
    	try{
    		logger.logDebug('NotificationDataServer----entered handleRequest----');
    		String action = readParam(REQUEST_PARAM_ACTION);
	        String requestData = readParam(REQUEST_PARAM_DATA);
			logger.logDebug('NotificationDataServer----requestData'+requestData);
	        String state = readParam('state') != null ? String.valueOf(readParam('state')).subStringBetween('"','"'):'';
			String id = readParam('id') != null ? String.valueOf(readParam('id')).subStringBetween('"','"'):'';
			String contentId = readParam('contentId') != null ? String.valueOf(readParam('contentId')):'';	        

	        if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
				response = getNotifications(action, requestData);
	        	
	        } else if (ACTION_VALUE_MARK_ALL_NON_ACTIONABLE_AS_READ.equalsIgnoreCase(action)) {
	        	markAllActivityNotificationAsRead();
            
            } else if(ACTION_VALUE_MARK_ALL_TYPE_AS_SEEN.equalsIgnoreCase(action)) {
            	markAllActivityNotificationAsSeen();
			
			} else if(ACTION_VALUE_MARK_AS_ACTIONED.equalsIgnoreCase(action)) {
            	response = markAsActioned(requestData);
				
            } else if(ACTION_VALUE_SEND_NOTIFICATION.equalsIgnoreCase(action)) {
					String message = readParam('message');
					String membersType = readParam('membersType');
					sendNotification(contentId, message, membersType);

			} else if(ACTION_VALUE_SEND_NOTIFICATION_IN_APP_PUSH.equalsIgnoreCase(action)) {
				Criteria.NotificationList notificationCriteriaObj = (Criteria.NotificationList)JSON.deserialize(requestData, Criteria.NotificationList.class);
				if(String.isNotBlank(notificationCriteriaObj.notificationsListJson)){
					List<NotificationDao.Notification> notificationsList = (List<NotificationDao.Notification>)JSON.deserialize(notificationCriteriaObj.notificationsListJson, List<NotificationDao.Notification>.class);

					if(notificationsList != null && notificationsList.isEmpty() == false) {
						NotificationDao notificationDaoObj = new NotificationDao();
						notificationDaoObj.createAndSendPushNotifications(null, notificationsList); // send in-app and push from other microservices, pass fromId if required
					}
				}

			} else if(ACTION_VALUE_GET_NOTIFICATION_MESSAGE.equalsIgnoreCase(action)) {
				String contentMessageId = readParam('contentMessageId');
            	response = getNotificationMessage(contentMessageId);
			
			} else if (ACTION_SEND_MOBILE_PROMOTION_LINK.equalsIgnoreCase(action)) {
            	String mobileNumberStr = readParam('mobileNumber');
            	String notifType = readParam('type');
				String emailAddressStr = readParam('emailAddress');
				if(SimpplrContext.mobilePromotionEnabled){
					if ('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(notifType)) {
						response = sendMobilePromotionLinkSmsInRealtime(mobileNumberStr, null);
	
					} else if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(notifType)) {
						MobileAppDistributionWrapper distributionWrapperObj = new MobileAppDistributionWrapper();
						distributionWrapperObj.peopleObj = UserContext.getCurrentUserInfo;
						response = sendMobilePromotionLinkEmail(emailAddressStr, distributionWrapperObj);
					}
				}else{
					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);	
				}
			} else if (ACTION_SEND_BRANDED_APP_DISTRIBUTION_LINK.equalsIgnoreCase(action)) {
				String mobileNumberStr = readParam('mobileNumber');
				String notifType = readParam('type');
				String emailAddressStr = readParam('emailAddress');

				if(SimpplrContext.brandedAppDistributionEnabled){
					response = handeleBrandedAppDistribution(notifType, mobileNumberStr, emailAddressStr);
				} else{
					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);	
				}
			} else if (ACTION_BULK_SEND_BRANDED_APP_DISTRIBUTION_LINK.equalsIgnoreCase(action)) {
				String notifType = readParam('type');

				if(SimpplrContext.brandedAppDistributionEnabled){
					response = handleBulkSendBrandedAppLinks(notifType);
				} else{
					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);	
				}
			} else if(ACTION_VALUE_CREATE.equalsIgnoreCase(action)) {
				response = createNotification(requestData); 

			} else if(ACTION_SEND_EMAIL.equalsIgnoreCase(action)) {
				response = sendEmail(requestData); 

			} else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        } catch(Exception ex){
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
          	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }

    

    @TestVisible
    private Integer sumUpMapValues(Map<String, Integer> mapCollection ){
		Integer total = 0;
        for(Integer count : mapCollection.values()){
			total+=count;            
        }
        return total;
    }
	
    @TestVisible
    private Map<String, Integer> getNoOfAvailableBrandedAppCodes(){
		BrandedAppDistributionDao brandedAppDistributionDaoObj = new BrandedAppDistributionDao();
        AggregateResult[] groupedResults = brandedAppDistributionDaoObj.getCountOfCodesByCountry();
		Map<String, Integer> countByCountry = new Map<String, Integer>();
		if(groupedResults!=null && groupedResults.size()>0){
			for(AggregateResult result : groupedResults){
				String country = String.valueOf(result.get('country'));
				Integer count = Integer.valueOf(result.get('c'));
				countByCountry.put(country, count);
			}
		}
        return countByCountry;
    }

    
    @TestVisible
    private Set<id> getPeopleWithCodes(){
        Set<id> peopleWithCodes = new Set<id>();   
		BrandedAppDistributionDao brandedAppDistributionDaoObj = new BrandedAppDistributionDao();
		List<Branded_App_Distribution__c> assignedCodes = brandedAppDistributionDaoObj.getUsedCodes();
		if(assignedCodes!=null && assignedCodes.size()>0){
			for(Branded_App_Distribution__c bad : assignedCodes){
				peopleWithCodes.add(bad.people__c);
			}
		}
        return peopleWithCodes;
    }
    
    @TestVisible
    private Set<String> getCountriesWithLowCodes(Map<String, Integer> peopleMap, Map<String, Integer> codeMap){
        if((peopleMap==null || peopleMap.size()==0 ) ||(codeMap==null || codeMap.size()==0 )){
            return new Set<String>();
        }
        Set<String> countriesWithLowCodes = new Set<String>();
        for(String country : peopleMap.keySet()){
            if(codeMap.containsKey(country) ){
                if(codeMap.get(country) < peopleMap.get(country)){
                    countriesWithLowCodes.add(country);
                }
            }else{
	            countriesWithLowCodes.add(country);                
            }
        }
        return countriesWithLowCodes;
    }

    @TestVisible
    private String getStringFromSet(Set<String> countries){
        String str = '';
        List<String> countriesList = new List<String>(countries);
        Integer len = countriesList.size();
        for (Integer i = 0; i < len; i++) {
            if(i == len-2){
                str +='<'+countriesList[i]+'> and ';
            }else if(i == len-1){
                str +='<'+countriesList[i]+'>';
            }else{
                str +='<'+countriesList[i]+'>, ';
            }
        }
        return str;
    }
   
    @TestVisible
    private Map<String, Integer> getPeopleCountByCountry(){
		Map<String, Integer> peopleCountByCountry = new Map<String, Integer>();  
		if(SimpplrContext.isFeatureEnabled('Full_External_Search') ) {
            ExternalSearchService searchServiceObj = new ExternalSearchService();
            peopleCountByCountry = searchServiceObj.getUsersCountByCountry();
			
        } else{
			PeopleDao peopleDaoObj = new PeopleDao();
			List<AggregateResult> groupedResults  = peopleDaoObj.getUsersCountByCountry();
		    if(groupedResults!=null && groupedResults.size()>0){
				for(AggregateResult result : groupedResults){
					String country = String.valueOf(result.get('peopleCountry'));
				  	Integer count = Integer.valueOf(result.get('noOfPeople'));
				  	peopleCountByCountry.put(country, count);
			  	}
		  	}
		}
		return peopleCountByCountry;
    }
    
    private Integer getCodeCount(){
        BrandedAppDistributionDao brandedAppDistributionDaoObj = new BrandedAppDistributionDao();
		return brandedAppDistributionDaoObj.codeCount();
    }
    
    @TestVisible
	private  ResponseWrapper handleBulkSendBrandedAppLinks(String type) {
		ResponseWrapper response;
		
		Map<String, Integer> peopleCountByCountry = getPeopleCountByCountry();
        Integer totalPeople = sumUpMapValues(peopleCountByCountry);
        Integer totalCodes = getCodeCount();

		Integer diff = totalPeople - totalCodes;

		if(diff > 0){
			String codesRequired = String.valueOf(diff * 2);
			String errorMsg = LocaleContext.getLabel( UserContext.languageLocaleKey, 'notification.branded_apps.failed_to_send_upload_more_codes').replace('{{codesNeeded}}', codesRequired);
            return buildResponseWrapper(RESPONSE_STATUS_ERROR, errorMsg, null); 
        }
	
        Map<String, Integer> codeCountByCountry = getNoOfAvailableBrandedAppCodes();        
		
        Set<String> countriesWithLowCodes = getCountriesWithLowCodes(peopleCountByCountry, codeCountByCountry);
        
        if(countriesWithLowCodes!=null && countriesWithLowCodes.size()>0){
         	for(String country : countriesWithLowCodes){
                if(peopleCountByCountry.containsKey(country)){
                    peopleCountByCountry.remove(country);                
                }
            }   
        }
        
        if(peopleCountByCountry!=null && peopleCountByCountry.size()>0){
            BatchSendBrandedAppLinks job = new BatchSendBrandedAppLinks(peopleCountByCountry.KeySet(), type);
            Database.executeBatch(job, 80);

            if(countriesWithLowCodes.size()>0){
				return lowCodeError(countriesWithLowCodes);
            } else if('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(type)) {
                return buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , null);
            } else {
                return  buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , null);
            }
        }else if(countriesWithLowCodes.size()>0){
           return lowCodeError(countriesWithLowCodes);
        }else{
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , null);
		}
		return response;
	}
    
    private ResponseWrapper lowCodeError(Set<String> countriesWithLowCodes){
        String countryList = getStringFromSet(countriesWithLowCodes);
        String errorLowCodeForCountries = LocaleContext.getLabel( UserContext.languageLocaleKey, 'notification.branded_apps.failed_to_send_to_all').replace('{{countryList}}', countryList);
        return buildResponseWrapper(RESPONSE_STATUS_ERROR, errorLowCodeForCountries, null); 
        
    }

	private Boolean isValidInput(String type, String mobile, String email){
		if('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(type) &&
			String.isBlank(UserContext.email) &&
		 	String.isBlank(email)){
				return false;
		}
		if('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(type) && 
			(String.isBlank(UserContext.mobile) || String.isBlank(UserContext.phone)) &&
			String.isBlank(mobile) ){
				return false;
		}
		return true;
	}

	private Boolean sendingToSelf(String type, String mobile, String email){
		if('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(type) ){
			return (email != null && UserContext.email != null && UserContext.email == email);
		} else if('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(type)){
			return mobile != null && ((UserContext.mobile != null && mobile == UserContext.mobile)
				|| (UserContext.phone != null && mobile == UserContext.phone));
		}
		return false;
	}



	private List<People__c> getReceiver(String type, String mobile, String email ){
		PeopleDao peopleDaoObj = new PeopleDao();
		if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(type) && String.isNotBlank(email)) {
			return peopleDaoObj.getUserByEmail(email);
			
		} 
		if('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(type) && String.isNotBlank(mobile)){
			return peopleDaoObj.getUserByMobileNumber(mobile);
		}
		return null;
	}



	private ResponseWrapper handeleBrandedAppDistribution(String type, String mobile, String email ){
		ResponseWrapper response;
		if(!isValidInput(type, mobile, email)){
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, LocaleContext.getLabel( UserContext.languageLocaleKey, 'notification.branded_apps.invalid_input'), null);
		}

		Boolean isSendingToSelf = sendingToSelf(type, mobile, email);
        	
		String peopleId = '';
		String receiverCountry = '';

		if(isSendingToSelf){
			peopleId = UserContext.peopleId;
			receiverCountry = UserContext.country;
		}else{
            List<People__c>  receiver = new List<People__c>();
			receiver = getReceiver(type, mobile, email);
            
			if(receiver != null && receiver.size()>0 && String.isNotBlank(receiver[0].Country__c)){
				peopleId = receiver[0].Id;
				receiverCountry = receiver[0].Country__c;
			}else{
				return buildResponseWrapper(RESPONSE_STATUS_ERROR, LocaleContext.getLabel( UserContext.languageLocaleKey, 'notification.branded_apps.user_not_found'), null);
			}	
		}
		BrandedAppDistributionDao brandedAppDistributionDaoObj = new BrandedAppDistributionDao();
		List<Branded_App_Distribution__c> existingAppDistributionCode = brandedAppDistributionDaoObj.getExistingAppDistributionCode(peopleId);
		
		if(existingAppDistributionCode!=null && existingAppDistributionCode.size()>0){
            
			MobileAppDistributionWrapper distributionWrapperObj = new MobileAppDistributionWrapper();
			distributionWrapperObj.iosLink = existingAppDistributionCode[0].Link__c;
			distributionWrapperObj.iosCode = existingAppDistributionCode[0].Code__c;
			distributionWrapperObj.androidLink = SimpplrContext.androidAppLink;

			if ('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(type)) {
				sendMobilePromotionLinkSmsInFuture(mobile, JSON.serialize(distributionWrapperObj));
			} else if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(type)) {
				distributionWrapperObj.peopleObj = UserContext.getCurrentUserInfo;
				response = sendMobilePromotionLinkEmail(email, distributionWrapperObj); 
			}
			if(response==null){
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			}
		}else{
			List<Branded_App_Distribution__c> appDistributionCode = brandedAppDistributionDaoObj.getAppDistributionCodeUsingCountry(receiverCountry);
			if(appDistributionCode != null && appDistributionCode.size()>0){

				appDistributionCode[0].Is_Used__c = true;
				MobileAppDistributionWrapper distributionWrapperObj = new MobileAppDistributionWrapper();
				distributionWrapperObj.iosLink = appDistributionCode[0].Link__c;
				distributionWrapperObj.iosCode = appDistributionCode[0].Code__c;
				distributionWrapperObj.androidLink = SimpplrContext.androidAppLink;
				if ('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(type)) {
					appDistributionCode[0].Type__c = 'SMS';
					appDistributionCode[0].Phone__c = mobile;
					sendMobilePromotionLinkSmsInFuture(mobile, JSON.serialize(distributionWrapperObj));

				} else if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(type)) {
					appDistributionCode[0].Type__c = 'Email';
					appDistributionCode[0].Email__c = email;
					distributionWrapperObj.peopleObj = UserContext.getCurrentUserInfo;
					response = sendMobilePromotionLinkEmail(email, distributionWrapperObj); 
				}

				appDistributionCode[0].People__c = peopleId;
				SIMPESAPI.accessController().updateAsUser(appDistributionCode[0], new List<Schema.SObjectField>{
					Branded_App_Distribution__c.People__c,
					Branded_App_Distribution__c.Type__c,
					Branded_App_Distribution__c.Phone__c,
					Branded_App_Distribution__c.Email__c,
					Branded_App_Distribution__c.Is_Used__c
				});
				if(response==null){
					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
				}
			}else{
				// no codes
				// all used
				// not in the users country
				Boolean noCodes = true;
				Boolean allUsed = true;
				Integer noOfcodes = brandedAppDistributionDaoObj.codeCount();
                Integer unUsedCodes = brandedAppDistributionDaoObj.unUsedCodeCount();
				
				if(noOfcodes == 0){
					response = buildResponseWrapper(RESPONSE_STATUS_ERROR,
													 LocaleContext.getLabel( UserContext.languageLocaleKey, 'notification.branded_apps.no_codes_error'),
													  null);	
				}else if(unUsedCodes == 0){
					response = buildResponseWrapper(RESPONSE_STATUS_ERROR,
													LocaleContext.getLabel( UserContext.languageLocaleKey, 'notification.branded_apps.all_codes_used_error'),
													 null);	
				}else {
					response = buildResponseWrapper(RESPONSE_STATUS_ERROR,  
													LocaleContext.getLabel( UserContext.languageLocaleKey, 'notification.branded_apps.no_codes_in_user_location'),
													 null);	
				}		
			}
		}
		return response;
	}
	
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private ResponseWrapper getPopUpNotifications(Criteria.Notification notificationCriteriaObj) {
    	logger.logDebug('NotificationDataServer.getPopUpNotifications()----notificationCriteriaObj----'+notificationCriteriaObj);
    	ResponseWrapper localResult = new ResponseWrapper();
    	List<NotificationListingWrapper> listOfNotificationWrapper = new List<NotificationListingWrapper>(); 
        try {
        	if (notificationCriteriaObj.nextPageToken == 0 || notificationCriteriaObj.nextPageToken == null) {
    			notificationCriteriaObj.offset = 0;
    			
    		} else {
    			notificationCriteriaObj.offset = notificationCriteriaObj.nextPageToken;
    		}
        	notificationCriteriaObj.peopleId = UserContext.peopleId;
        	NotificationListingWrapper.PaginationWrapper notificationPaginatorObj = new NotificationListingWrapper.PaginationWrapper();
        	Integer activityToken = 0;
        	Integer actionableToken = 0;
        	String userId = UserContext.peopleId;
        	if(String.isBlank(notificationCriteriaObj.filter)){
        		listOfNotificationWrapper = NotificationContentProvider.getPopUpNotifications(notificationCriteriaObj);
        		
	        	notificationPaginatorObj.listOfItems.addAll(listOfNotificationWrapper);
	        	if (notificationPaginatorObj.listOfItems.size() == (SimpplrContext.simpplrDefaultPageSize + 1) &&
		        	notificationCriteriaObj.offset < 2000) {
		        	notificationPaginatorObj.listOfItems.remove((notificationPaginatorObj.listOfItems.size()-1));
		        	notificationPaginatorObj.nextPageToken = Integer.valueOf(notificationCriteriaObj.offset + SimpplrContext.simpplrDefaultPageSize);
		        } else {
		        	notificationPaginatorObj.nextPageToken = null;
		        }
		        
        	} else {
	        	listOfNotificationWrapper = NotificationContentProvider.getPopUpNotifications(notificationCriteriaObj);
	        	
	        	notificationPaginatorObj.listOfItems.addAll(listOfNotificationWrapper);
	        	
	        	if (notificationPaginatorObj.listOfItems.size() == (SimpplrContext.simpplrDefaultPageSize + 1) &&
		        	notificationCriteriaObj.offset < 2000) {
		        	notificationPaginatorObj.listOfItems.remove((notificationPaginatorObj.listOfItems.size()-1));
		        	notificationPaginatorObj.nextPageToken = Integer.valueOf(notificationCriteriaObj.offset + SimpplrContext.simpplrDefaultPageSize);
		        } else {
		        	notificationPaginatorObj.nextPageToken = null;
		        }
        	}
        	notificationPaginatorObj.newCounts = NotificationContentProvider.getNewNotificationCount(notificationCriteriaObj.peopleId, notificationCriteriaObj.origin);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, notificationPaginatorObj);        
        
        } catch (Exception e) {
        	logger.logError('Could not retrieve notification pop up data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('NotificationDataServer.getPopUpNotifications()----localResult----'+localResult);
        return localResult;
	}
	   
	private ResponseWrapper createNotification(String requestData) {
    	logger.logDebug('NotificationDataServer.createNotification()----requestData----' + requestData);
		ResponseWrapper localResult = new ResponseWrapper();
        try {
			Map<String, String> requestMap = (Map<String, String>) JSON.deserialize(requestData, Map<String, String>.class);
			String notificationId = new NotificationContentProvider().createNotification(requestMap);
			Map<String, String> responseMap = new Map<String, String>();
			responseMap.put('notificationId', notificationId);
			localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);    
		} catch (Exception e) {
        	logger.logError('NotificationDataServer.createNotification()----Exception Occured----',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
        }
        return localResult;
	}
	
    private ResponseWrapper markAsActioned(String requestData) {
    	logger.logDebug('NotificationDataServer.markAsActioned()----requestData----' + requestData);
		ResponseWrapper localResult = new ResponseWrapper();
        try {
			Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			new NotificationContentProvider().markAsActioned(readParam('notificationId'), requestMap);  
		} catch (Exception e) {
        	logger.logError('NotificationDataServer.markAsActioned()----Exception Occured----',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
        }
        return localResult;
	}

    @TestVisible 
    private ResponseWrapper getAllNotifications(Criteria.Notification notificationCriteriaObj) {
    	logger.logDebug('NotificationDataServer.getAllNotifications()----notificationCriteriaObj----'+notificationCriteriaObj);
    	ResponseWrapper localResult = new ResponseWrapper();
        try {

        	if (notificationCriteriaObj.nextPageToken == 0 || notificationCriteriaObj.nextPageToken == null) {
    			notificationCriteriaObj.offset = 0;
    			 
    		} else {
    			notificationCriteriaObj.offset = Integer.valueOf(notificationCriteriaObj.nextPageToken);
    		}
    		
    		notificationCriteriaObj.peopleId = UserContext.peopleId;
            NotificationListingWrapper.PaginationWrapper notificationPaginatorObj = new NotificationListingWrapper.PaginationWrapper();
            notificationPaginatorObj = NotificationContentProvider.getAllNotifications(notificationCriteriaObj);
            localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, notificationPaginatorObj);    
	        		
        } catch (Exception e) {
        	logger.logError('Could not get all notifications',e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);        
		}
		logger.logDebug('NotificationDataServer.getAllNotifications()----localResult----'+localResult);
		return localResult;
    }
    
    private void markAllActivityNotificationAsRead() {
    	ResponseWrapper localResult = new ResponseWrapper();
    	try {
    		NotificationDao notificationDaoObj = new NotificationDao();
    		notificationDaoObj.markNotificationsAsRead(UserContext.peopleId);
    		
        } catch(Exception e) { 
        	logger.logError('Could not mark all activities as read',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    }
    
    private void markAllActivityNotificationAsSeen() {
    	ResponseWrapper localResult = new ResponseWrapper();
    	try {
			NotificationDao notificationDaoObj = new NotificationDao();
			notificationDaoObj.markNotificationAsSeen('Information');    		
        } catch(Exception e) {
        	logger.logError('Could not mark all activities as seen',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    }
    @TestVisible
    private void setNotificationsAsSeen(String commaSaperatedIds, String state) {
		Set<String> idSet = new Set<String>(commaSaperatedIds.split(','));
		NotificationDao notificationDaoObj = new NotificationDao();
		notificationDaoObj.setStateAsSeen(idSet, state);
    }
    
    private void sendNotification(String contentId, String message, String membersType) { 
		String activity = 'site_members'.equalsIgnoreCase(membersType) ? 'sendNotificationToSiteMembers' :'sendNotificationToSiteMembersAndFollowers';
		BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate(contentId, message,activity, membersType);
		Database.executeBatch(job,80);
    	ResponseWrapper localResult = new ResponseWrapper();
    	
    }

	private ResponseWrapper getNotificationMessage(String contentMessageId) {
		ResponseWrapper response;
		try {
			NotificationContentProvider providerObj = new NotificationContentProvider();
			Map<String, Object> resultObj = providerObj.getContentNotificationMessage(contentMessageId);
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultObj); 
		} catch(Exception e) {
        	logger.logError('NotificationDataServer.getNotificationMessage()----Exceeption Occured----',e);
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
		return response;
		
	}

	@future(callout=true)
	private static void sendMobilePromotionLinkSmsInFuture (String mobileNumber, String distributionWrapperStr) {
		MobileAppDistributionWrapper distributionWrapperObj = (MobileAppDistributionWrapper)JSON.deserialize(distributionWrapperStr, MobileAppDistributionWrapper.class);
		Utility.sendMobilePromotionLinkSms(mobileNumber, distributionWrapperObj);
	}

	private ResponseWrapper sendMobilePromotionLinkSmsInRealtime (String mobileNumber, MobileAppDistributionWrapper distributionWrapperObj) {
		Map<String, Object> requestDataMap = Utility.sendMobilePromotionLinkSms(mobileNumber, distributionWrapperObj);
		if (requestDataMap != null && requestDataMap.containsKey('status')) {
			if ('error'.equalsIgnoreCase((String)requestDataMap.get('status'))) {
				response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			} else {
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			}
		} else {
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 
		}
		return response;
	}

	private ResponseWrapper sendMobilePromotionLinkEmail (String emailStr, MobileAppDistributionWrapper distributionWrapperObj) { 
		ResponseWrapper response;
		String localeKey = Utility.getSimpplrLanguageLocaleKey(UserContext.languagelocalekey);
		LocaleContext.getAllLabelMap('EmailNotifications', new List<String>{localeKey});
		NotificationHelper.BrandingInfo brandingInfo = EmailUtility.getBrandingInfo4People(UserContext.getCurrentUserInfo);

		List<Messaging.SingleEmailMessage> listOfEmailsToSend = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage singleMailObj = new Messaging.SingleEmailMessage();
		singleMailObj.setToAddresses(new List<String>{emailStr});
		String emailSubjectStr = LocaleContext.getLabel(UserContext.languageLocaleKey, 
				'email.mobile_promotion.subject').replace('{{appName}}', 
				SimpplrContext.applicationName);
		singleMailObj.setSubject(emailSubjectStr);
		if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
			singleMailObj.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
		}
		String mobilePromotionEmailBody = EmailUtility.getMobilePromotionEmailBody(brandingInfo, false, distributionWrapperObj);
		singleMailObj.setHtmlBody(mobilePromotionEmailBody);
		listOfEmailsToSend.add(singleMailObj);
		
		if (listOfEmailsToSend.size() > 0) {
			List<Messaging.SendEmailResult> results = Messaging.sendEmail(listOfEmailsToSend);
		}
		response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		return response;
	}

	private ResponseWrapper sendEmail(String requestData){
        ResponseWrapper responseWrapperObj = null;
        try{
            EmailWrapper emailWrapperObj = (EmailWrapper)JSON.deserialize(requestData, EmailWrapper.class);
            Database.executeBatch(new BatchEmailService(emailWrapperObj), 100);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        } catch(Exception e){
            logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        return responseWrapperObj;
    }
	public ResponseWrapper getNotifications(String action, String requestData) {
		Criteria.Notification notificationCriteriaObj = (Criteria.Notification)JSON.deserialize(requestData,
				Criteria.Notification.class);
		notificationCriteriaObj.origin = readParam('origin');
		if(!'mobile'.equalsIgnoreCase(notificationCriteriaObj.origin) && SimpplrContext.isMaintenanceInProgress) {
			throw new SimpplrException('MAINTENANCE_MODE');
		}
		if (notificationCriteriaObj.includeActioned) {
			return getAllNotifications(notificationCriteriaObj);
		} else {
			return getPopUpNotifications(notificationCriteriaObj);
		}
	}	
}