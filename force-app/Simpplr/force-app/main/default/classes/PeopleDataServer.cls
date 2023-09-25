/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PeopleDataServer extends DataServer { 
	private final String ACTION_VALUE_SEARCH = 'search'; // NOPMD - correct naming convension, suppressed codacy error 
	private final String ACTION_GET_ORG_CHART = 'getOrgChart'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_GET_ORG_CHART_PROFILE = 'getOrgChartOnProfile'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_PEOPLE_BY_USER_ID = 'getPeopleByUserId'; // NOPMD - correct naming convension, suppressed codacy error 
    private final String ACTION_VALUE_GET_ENDORSEMENT = 'getEndorsements'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_ADD_ENDORSEMENT = 'addEndorsement'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_REMOVE_ENDORSEMENT = 'removeEndorsement'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_REMOVE_EXPERTISE = 'removeExpertise'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_GET_COMPANY_STATS = 'getCompanyStats'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_GET_INSTALL_STATS = 'getInstallStats'; // NOPMD - correct naming convension, suppressed codacy error  
    private final String ACTION_GET_DEPARTMENT = 'getDepartments'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_GET_CUSTOM_FIELD = 'getCustomFields'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_GET_LOCATION = 'getLocation'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_GET_FIELD_VALUES = 'getFieldValues'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SEARCH_LOCATION = 'searchLocation'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SEARCH_DEPARTMENT = 'searchDepartment'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_CONNECT_APP = 'connectApp'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_REDIRECT_URL = 'getRedirectUrl'; // NOPMD - correct naming convension, suppressed codacy error	
    private final String ACTION_VALUE_DISCONNECT_APP = 'disconnectApp'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_FOLLOW_STATS = 'getFollowStats'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_APP_TOKEN = 'saveAppToken'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_WEB_PUSH_PROMPT_FLAG = 'saveWebPushPromptFlag'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_GOOLGE_CALENDARS = 'getGoogleCalendars'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_ALL_PEOPLE_DATA = 'getAllPeopleData'; // NOPMD - correct naming convension, suppressed codacy error


    private final String ACTION_VALUE_GET_USER = 'getUser'; // NOPMD - correct naming convension, suppressed codacy error
    
	private final String ACTION_VALUE_SET_COVER_IMAGE = 'setCoverImage'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_USER_WEB_PUSH_TOKENS = 'getUserWebpushTokens'; // NOPMD - correct naming convension, suppressed codacy error
    
    private final String REQUEST_PARAM_SAVE_ABOUT_ME = 'saveAboutMe'; // NOPMD - correct naming convension, suppressed codacy error
    private final String REQUEST_PARAM_DATA = 'data'; // NOPMD - correct naming convension, suppressed codacy error
    private final String REQUEST_PARAM_NEXT_PAGE_TOKEN = 'nextPageToken'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_GET_APP_MANAGER_LIST = 'getAppManagerList'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_GET_APP_SEGMENT_MANAGER_LIST = 'getAppAndSegmentManagerList'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_CREATE_PEOPLE = 'createPeople'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_SEND_RESET_PASSWORD_EMAIL = 'sendResetPasswordEmail'; // NOPMD - correct naming convension, suppressed codacy error
	@TestVisible private final String ACTION_VALUE_GET_PEOPLE_COUNT_ORG = 'getCount'; // NOPMD - correct naming convension, suppressed codacy error
    @TestVisible private final String ACTION_VALUE_GET_PEOPLE_BY_IDS = 'getByIds'; // NOPMD - correct naming convension, suppressed codacy error
	@TestVisible private final String ACTION_VALUE_UPDATE_INTEGRATION_INFO = 'updateIntegrationInfo'; // NOPMD - correct naming convension, suppressed codacy error
	@TestVisible private static final String DATA_TYPE_VALUE_DRIVE = 'drive'; // NOPMD - correct naming convension, suppressed codacy error
    @TestVisible private static final String DATA_TYPE_VALUE_GDRIVE = 'Google Drive'; // NOPMD - correct naming convension, suppressed codacy error
    @TestVisible private static final String DATA_TYPE_VALUE_GCALENDAR = 'Google Calendar'; // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_BATCH_PROCESSING_TRY_LATER { get { return labelMap.get('apps.connection.batch_processing_try_later');}} // NOPMD - correct naming convension, suppressed codacy error

	public PeopleDataServer() {}
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
        
        try {
        	logger.logDebug('PeopleDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION);
            if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
            	String requestData = readParam(REQUEST_PARAM_DATA);
                requestData = requestData.replaceAll('__c":', '":');
	        	Criteria.People criteriaPeopleObj = (Criteria.People)JSON.deserialize(requestData, 
                        Criteria.People.class);

				response = getPeople(criteriaPeopleObj); 
    			
            } else if (ACTION_VALUE_GET_ALL_PEOPLE_DATA.equalsIgnoreCase(action)) {
				String requestData = readParam(REQUEST_PARAM_DATA);
                requestData = requestData.replaceAll('__c":', '":');
	        	Criteria.People criteriaPeopleObj = (Criteria.People)JSON.deserialize(requestData, 
                        Criteria.People.class);

            	response = getAllPeopleData(criteriaPeopleObj);
            
            } else if (ACTION_GET_ORG_CHART.equalsIgnoreCase(action)) {
            	response = getOrgChart(readParam(REQUEST_PARAM_DATA));
			} else if (ACTION_GET_ORG_CHART_PROFILE.equalsIgnoreCase(action)) {
            	response = getOrgChartOnProfile(readParam(REQUEST_PARAM_DATA));
            
            } else if (ACTION_VALUE_GET_ENDORSEMENT.equalsIgnoreCase(action)) {
            	response=getEndorsements(readParam('sfUserId'));
            
            } else if (ACTION_VALUE_ADD_ENDORSEMENT.equalsIgnoreCase(action)) {
				PeopleWrapper.EndorsementWrapper endorseObj= (PeopleWrapper.EndorsementWrapper)Json.deserialize(readParam(REQUEST_PARAM_DATA),PeopleWrapper.EndorsementWrapper.class);
				String endorsedById = String.isNotBlank(endorseObj.endorsedById) ? endorseObj.endorsedById : UserContext.peopleId;
				response=addEndorsement(endorseObj.sfUserId, endorseObj.expertiseId, endorsedById);
            
            } else if (ACTION_VALUE_REMOVE_ENDORSEMENT.equalsIgnoreCase(action)) {
            	PeopleWrapper.EndorsementWrapper endorseObj= (PeopleWrapper.EndorsementWrapper)Json.deserialize(readParam(REQUEST_PARAM_DATA),PeopleWrapper.EndorsementWrapper.class);
            	String endorsedById = String.isNotBlank(endorseObj.endorsedById) ? endorseObj.endorsedById : UserContext.peopleId;
				response=removeEndorsement(endorseObj.sfUserId, endorseObj.expertiseId, endorsedById);
            
            } else if (ACTION_VALUE_REMOVE_EXPERTISE.equalsIgnoreCase(action)) {
            	PeopleWrapper.EndorsementWrapper endorseObj= (PeopleWrapper.EndorsementWrapper)Json.deserialize(readParam(REQUEST_PARAM_DATA),PeopleWrapper.EndorsementWrapper.class);
            	response=removeExpertise(endorseObj.sfUserId, endorseObj.expertiseId);
            
            } else if (ACTION_GET_COMPANY_STATS.equalsIgnoreCase(action)) {
            	response=getCompanyStats();
            	
            } else if (ACTION_GET_INSTALL_STATS.equalsIgnoreCase(action)) {
            	response = getInstallStats(); 
            	
            } else if (ACTION_GET_CUSTOM_FIELD.equalsIgnoreCase(action)) {
            	response=getCustomFields();
            	
            } else if(ACTION_VALUE_SEARCH_LOCATION.equalsIgnoreCase(action)) {
        		String requestData = readParam(REQUEST_PARAM_DATA);
        		Criteria.People pplCriteriaObj = (Criteria.People)JSON.deserialize(requestData, Criteria.People.class);
            	response = searchLocation(pplCriteriaObj);
            
            } else if(ACTION_VALUE_SEARCH_DEPARTMENT.equalsIgnoreCase(action)) {
        		String requestData = readParam(REQUEST_PARAM_DATA);
        		Criteria.People pplCriteriaObj = (Criteria.People)JSON.deserialize(requestData, Criteria.People.class);
            	response = searchDepartment(pplCriteriaObj);
            		
            } else if (ACTION_GET_LOCATION.equalsIgnoreCase(action)) {
		    	String locationId = readParam('locationId');
            	response=getLocation(locationId);

			} else if (ACTION_GET_FIELD_VALUES.equalsIgnoreCase(action)) {
		    	String requestData = readParam(REQUEST_PARAM_DATA);
            	response=getFieldValues(requestData);
            	
            } else if(ACTION_VALUE_GET_PEOPLE_BY_USER_ID.equalsIgnoreCase(action)){
            	String userId = readParam('userId');
            	response = getPeopleByUserId(userId);
            } else if(REQUEST_PARAM_SAVE_ABOUT_ME.equalsIgnoreCase(action)){
            	String peopleId = readParam('peopleId');
            	String aboutMeText = readParam('aboutMe');
            	response = saveAboutMe(peopleId, aboutMeText);
            } else if(ACTION_VALUE_CONNECT_APP.equalsIgnoreCase(action)){
				String requestData = readParam(REQUEST_PARAM_DATA);
				response = connectApp(requestData);
			} else if(ACTION_VALUE_GET_REDIRECT_URL.equals(action)) {
				String requestData = readParam(REQUEST_PARAM_DATA);
				response = getRedirectUrl(requestData);

			} else if(ACTION_VALUE_DISCONNECT_APP.equalsIgnoreCase(action)){
				String requestData = readParam(REQUEST_PARAM_DATA);
				response = disconnectApp(requestData);
			} else if(ACTION_VALUE_GET_USER.equalsIgnoreCase(action)) {
				String requestData = readParam(REQUEST_PARAM_DATA);
				response = getUser(requestData);
			} else if(ACTION_VALUE_GET_FOLLOW_STATS.equalsIgnoreCase(action)) {
				String requestData = readParam(REQUEST_PARAM_DATA);
				response = getFollowStats(requestData);
			} else if(ACTION_VALUE_SET_COVER_IMAGE.equalsIgnoreCase(action)) {
				response = setCoverImage(readParam('peopleId'), readParam('file'));	
			} else if(ACTION_VALUE_SAVE_APP_TOKEN.equalsIgnoreCase(action)){
				String requestData = readParam(REQUEST_PARAM_DATA);
				response = saveAppToken(requestData);
			} else if(ACTION_VALUE_SAVE_WEB_PUSH_PROMPT_FLAG.equalsIgnoreCase(action)){
				String requestData = readParam(REQUEST_PARAM_DATA);
				response = saveWebPushPromptFlag(requestData);
			} else if(ACTION_VALUE_GET_GOOLGE_CALENDARS.equalsIgnoreCase(action)){
				response = getGoogleCalendars();
			} else if(ACTION_VALUE_GET_USER_WEB_PUSH_TOKENS.equalsIgnoreCase(action)){
				response = getUserWebpushTokens();

			} else if (ACTION_GET_APP_MANAGER_LIST.equalsIgnoreCase(action)) {
                response = getAppManagerList();

			} else if (ACTION_GET_APP_SEGMENT_MANAGER_LIST.equalsIgnoreCase(action)){
				response = getAppAndSegmentManagerList();

			} else if(ACTION_VALUE_CREATE_PEOPLE.equalsIgnoreCase(action)){
            	response = createPeople(readParam(REQUEST_PARAM_DATA));

			} else if (ACTION_SEND_RESET_PASSWORD_EMAIL.equalsIgnoreCase(action)) {
                response = sendResetPasswordEmail(readParam(REQUEST_PARAM_DATA));

            }  else if (ACTION_VALUE_GET_PEOPLE_BY_IDS.equalsIgnoreCase(action)){
				String requestData = readParam(REQUEST_PARAM_DATA);
                String[] listOfPeopleId = (String[])JSON.deserialize(requestData, 
                        String[].class);

                logger.logDebug(listOfPeopleId);
                List<People__c> listOfPeople = new PeopleDao().getPeopleByIds(listOfPeopleId); 
                List<PeopleLiteWrapper> listOfPeopleWrap = new NewsletterV2DataAdapter().convertToListOfPeopleLiteWrapper(listOfPeople);
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfPeopleWrap);
            
            } else if (ACTION_VALUE_GET_PEOPLE_COUNT_ORG.equalsIgnoreCase(action)){
				String requestData = readParam(REQUEST_PARAM_DATA);
				requestData = String.isNotBlank(requestData) ? requestData : '{}';
                Map<String, Integer> mapOfResult = new PeopleDao().getTotalPeopleCountForOrg(requestData);
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, mapOfResult);
            
            } 
			else if(ACTION_VALUE_UPDATE_INTEGRATION_INFO.equalsIgnoreCase(action)){
	            response = updateIntegrationInfo(readParam(REQUEST_PARAM_DATA));		    
             } else {
                throw new SimpplrException(ServiceConstants.ERROR_404);
            }

        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
           	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
	}
	
	private ResponseWrapper getUserWebpushTokens() {
		ResponseWrapper responseWrapperObj = null;
    	try{
			PeopleContentProvider pCPObj= new PeopleContentProvider();
    		List<String> webpushTokensList = pCPObj.getUserWebpushTokens(UserContext.peopleId, UserInfo.getOrganizationId());
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, webpushTokensList);
    		
    	} catch(Exception  e){
    		logger.logError('PeopleDataServer.getUserWebpushTokens()----'+e);
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return responseWrapperObj;
	}

    private ResponseWrapper getAppManagerList() {
		ResponseWrapper responseWrapperObj = null;
    	try{
			PeopleContentProvider pCPObj= new PeopleContentProvider();
    		List<PeopleWrapper.AppManagerWrapper> listOfAppManager = pCPObj.getAppManagerList();
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfAppManager);
    		
    	} catch(Exception  e){
    		logger.logError('PeopleDataServer.getAppManagerList()----'+e);
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return responseWrapperObj;
	}

	private ResponseWrapper getAppAndSegmentManagerList() {
		ResponseWrapper responseWrapperObj = null;
    	try{
			PeopleContentProvider pCPObj= new PeopleContentProvider();
    		List<PeopleWrapper.AppManagerWrapper> listOfAppManager = pCPObj.getAppAndSegmentManagerList();
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfAppManager);
    		
    	} catch(Exception  e){
    		logger.logError('PeopleDataServer.getAppAndSegmentManagerList()----'+e);
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return responseWrapperObj;
	}

	private ResponseWrapper createPeople(String requestData) {
		ResponseWrapper responseWrapperObj = null;
		PeopleWrapper.UserIdWrapper request = (PeopleWrapper.UserIdWrapper)JSON.deserialize(requestData, PeopleWrapper.UserIdWrapper.class);
		try {
			List<String> userIdList = request.userIds;
			String query = 'SELECT AboutMe,City,CommunityNickname,CompanyName,Country,Department,Division, ' + 
							'Email,EmployeeNumber,Extension,Fax,FirstName,LastName,ManagerId,MobilePhone, '+
							'Name,Phone,PostalCode,State,Street,Title,' +
							'AboutMe__c,City__c,CommunityNickname__c,CompanyName__c,' +
							'Country__c,Department__c,Division__c, ' + 
							'Email__c,EmployeeNumber__c,Extension__c,Fax__c,FirstName__c,LastName__c,MobilePhone__c, '+
							'Phone__c,PostalCode__c,State__c,Street__c,Title__c, ' +
							'IsActive, UserType, Show_Simpplr__c, CreatedDate ';
			Set<String> userFieldsSet = User.getSObjectType().getDescribe().fields.getMap().keySet();
			if(userFieldsSet.contains('birth_date__c')) {
				query += ', Birth_Date__c ';
			}
			if(userFieldsSet.contains('joining_date__c')) {
				query += ', Joining_Date__c ';
			}
			query += ' from User where id in: userIdList';
			List<User> listOfUsers = Database.query(query);
			PeopleDao peopleDaoObj = new PeopleDao();
    		List<People__c> listOfPeople = peopleDaoObj.insertPeople(listOfUsers);
			peopleDaoObj.insertPeoplePreference(listOfPeople);
			Map<String,String> mapOfUserIdPeopleId = new Map<String,String>();
			for(People__c people : listOfPeople){
				mapOfUserIdPeopleId.put(people.User_Id__c, people.Id);
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, mapOfUserIdPeopleId);
		}catch(Exception e){
        	logger.logError('PeopleDataServer.createPeople()----Exception Occured', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
	}
    private ResponseWrapper sendResetPasswordEmail(String requestData) {
		ResponseWrapper responseWrapperObj = null;
		PeopleWrapper.UserIdWrapper request = (PeopleWrapper.UserIdWrapper)JSON.deserialize(requestData, PeopleWrapper.UserIdWrapper.class);
    	try{
			List<User> listOfUsers = [SELECT Id,Email FROM User WHERE id IN :request.userIds WITH SECURITY_ENFORCED ];
			if(listOfUsers.size() < 100){
				for(User usr : listOfUsers)
				{
					System.resetPassword(usr.Id,true);
				}
			}
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    		
    	} catch(Exception  e){
    		logger.logError('PeopleDataServer.sendResetPasswordEmail()----'+e);
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
    	return responseWrapperObj;
	}

    private ResponseWrapper getPeopleByUserId (String userId) {
   		logger.logDebug('PeopleDataServer.getPeopleByUserId()--------'+userId);
   		ResponseWrapper responseToReturn = null;
   		try{
   			List<PeopleListingWrapper> peopleListWrapper = new List<PeopleListingWrapper>();
   			peopleListWrapper = PeopleContentProvider.getPeopleByUserId(userId);
   			if(!peopleListWrapper.isEmpty()){
   				
   				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleListWrapper[0]);
   			} else {
   				throw new SimpplrException(ServiceConstants.ERROR_404);
   			}
   		
   		} catch(Exception e) {
        	logger.logError('PeopleDataServer.getPeopleByUserId()----Could not fetch people information',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
   		return responseToReturn;
   	}
    
    
    
   	private ResponseWrapper getPeople (Criteria.People peopleCriteriaObjArg) {
   		logger.logDebug('PeopleDataServer.getPeople()----peopleCriteriaObjArg----'+peopleCriteriaObjArg);
   		ResponseWrapper responseToReturn = null;
   		List<PeopleListWrapper> listOfPeopleWrapper = null;
   		PeopleListWrapper.PaginationWrapper peopleListingContainerObj = new PeopleListWrapper.PaginationWrapper();
        Boolean isNextPageSetFromExternalSearch = false;
   		try {
			
	   		if (peopleCriteriaObjArg.nextPageToken == null) {
				peopleCriteriaObjArg.offset = 0;
				
			} else {
				peopleCriteriaObjArg.offset = Integer.valueOf(peopleCriteriaObjArg.nextPageToken);
			}

			if (peopleCriteriaObjArg.filter != null && 
   					peopleCriteriaObjArg.filter.containsIgnoreCase('following') &&
   					String.isNotBlank(peopleCriteriaObjArg.sfUserId)) {
   				listOfPeopleWrapper = PeopleContentProvider.getProfileConnectionsFollowing(peopleCriteriaObjArg);
   				
   			} else if (peopleCriteriaObjArg.filter != null && 
   					peopleCriteriaObjArg.filter.containsIgnoreCase('followers') &&
   					String.isNotBlank(peopleCriteriaObjArg.sfUserId)) {
   				listOfPeopleWrapper = PeopleContentProvider.getProfileConnectionsFollowers(peopleCriteriaObjArg);
   			
   			} else if (peopleCriteriaObjArg.filter != null &&
   				    peopleCriteriaObjArg.filter.containsIgnoreCase('favorites') &&
   				    peopleCriteriaObjArg.sortBy == null) {

   				listOfPeopleWrapper = getAllFavoritesPeople(peopleCriteriaObjArg);
   			
   			} else if(peopleCriteriaObjArg.filter != null && peopleCriteriaObjArg.filter.equalsIgnoreCase('site_members')) {
				listOfPeopleWrapper = PeopleContentProvider.getSiteMembers(peopleCriteriaObjArg);

			} else if(peopleCriteriaObjArg.filter != null && peopleCriteriaObjArg.filter.equalsIgnoreCase('site_followers')) {
				listOfPeopleWrapper = PeopleContentProvider.getSiteFollowers(peopleCriteriaObjArg);
				
			} else if(peopleCriteriaObjArg.filter != null && peopleCriteriaObjArg.filter.equalsIgnoreCase('site_members_and_followers')) {
				listOfPeopleWrapper = PeopleContentProvider.getSitesMembersEveryone(peopleCriteriaObjArg, 
	   						null);
				
			} else if (String.isNotBlank(peopleCriteriaObjArg.siteId)) {
	   			
				if ((peopleCriteriaObjArg.filter != null && peopleCriteriaObjArg.filter.containsIgnoreCase('managers')) || 
					(peopleCriteriaObjArg.type != null && peopleCriteriaObjArg.type.containsIgnoreCase('managers')) ) {
	   				listOfPeopleWrapper = PeopleContentProvider.getSiteManagers(peopleCriteriaObjArg);

	   			} else if(String.isNotBlank(peopleCriteriaObjArg.contentId)){
					logger.logDebug('PeopleDataServer.searchInvitee()----called');
	   				listOfPeopleWrapper = searchInvitee(peopleCriteriaObjArg.term, peopleCriteriaObjArg.siteId, peopleCriteriaObjArg.contentId, peopleCriteriaObjArg.isPrivate);
	   			
	   			} else if(peopleCriteriaObjArg.type != null && peopleCriteriaObjArg.type.containsIgnoreCase('members')){
					listOfPeopleWrapper = PeopleContentProvider.getSiteMembers(peopleCriteriaObjArg);
				
				} else if(peopleCriteriaObjArg.type != null && peopleCriteriaObjArg.type.containsIgnoreCase('followers')) {
					listOfPeopleWrapper = PeopleContentProvider.getSiteFollowers(peopleCriteriaObjArg);
				
				} else if(peopleCriteriaObjArg.type != null && (peopleCriteriaObjArg.type.containsIgnoreCase('requests') || peopleCriteriaObjArg.type.containsIgnoreCase('requests-search'))) {
                    
                    if (!String.isBlank(peopleCriteriaObjArg.term) && 
                            SimpplrContext.isFeatureEnabled('Full_External_Search')) {
                        Criteria.ExternalSearchReq extSiteCriteriaObj = new Criteria.ExternalSearchReq();
                        extSiteCriteriaObj.siteId = peopleCriteriaObjArg.siteId;
                        extSiteCriteriaObj.term = peopleCriteriaObjArg.term;
                        extSiteCriteriaObj.requestType = 'membership_request';
                        listOfPeopleWrapper = new ExternalSearchService().getSiteMemberRequest(extSiteCriteriaObj); 

                    } else {
                        listOfPeopleWrapper = PeopleContentProvider.getListOfRequest(peopleCriteriaObjArg);
                    }

				} else {

                    if (!String.isBlank(peopleCriteriaObjArg.term) && 
                            SimpplrContext.isFeatureEnabled('Full_External_Search')) {
                        Criteria.ExternalSearchReq extSiteCriteriaObj = new Criteria.ExternalSearchReq();
                        extSiteCriteriaObj.siteId = peopleCriteriaObjArg.siteId;
                        extSiteCriteriaObj.term = peopleCriteriaObjArg.term;
                        extSiteCriteriaObj.requestType = 'member';
                        listOfPeopleWrapper = new ExternalSearchService().getSiteMembers(extSiteCriteriaObj); 
						listOfPeopleWrapper = PeopleContentProvider.removeInactiveUsersFromList(listOfPeopleWrapper);

                    } else {
	   				    listOfPeopleWrapper = PeopleContentProvider.getSitesMembersEveryone(peopleCriteriaObjArg, null);
                    }
	   			}
	   			
	   		}  else if (peopleCriteriaObjArg.contentId != null) {
				PeopleDao peopleDaoObj = new PeopleDao();
				List<Must_Read_Audit__c> mrAuditList = peopleDaoObj.getMustReadAuditList(peopleCriteriaObjArg.contentId);
				String mrAuditId = '';
   				String cgId = '';
				String siteId = '';
				String audienceType = '';

                if (mrAuditList.isEmpty() == false) {
					mrAuditId = mrAuditList[0].id;
					
					cgId = mrAuditList[0].Content__r.Site__r.Chatter_group_Id__c;
					siteId = mrAuditList[0].Content__r.Site__c;
					audienceType = mrAuditList[0].Audience_Type__c;

				}

				Integer totalRecods = 0;
				if(String.isNotBlank(peopleCriteriaObjArg.term) && SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					Criteria.ExternalSearchReq extPeopleCriteriaObj = new Criteria.ExternalSearchReq();
					extPeopleCriteriaObj.term = peopleCriteriaObjArg.term;
					extPeopleCriteriaObj.collaborationId = cgId;
					extPeopleCriteriaObj.siteId = siteId;
					extPeopleCriteriaObj.contentId = peopleCriteriaObjArg.contentId;	
					extPeopleCriteriaObj.filter = peopleCriteriaObjArg.filter;
					extPeopleCriteriaObj.audienceType = audienceType;	
					extPeopleCriteriaObj.size = peopleCriteriaObjArg.size;
					extPeopleCriteriaObj.nextPageToken = peopleCriteriaObjArg.nextPageToken;
					extPeopleCriteriaObj.requestType = 'must_read_content';
					isNextPageSetFromExternalSearch = true;
					listOfPeopleWrapper = new ExternalSearchService().getMustReadRecordHistory(extPeopleCriteriaObj);
					peopleListingContainerObj.nextPageToken = ExternalSearchService.nextPageToken;
					totalRecods =  ExternalSearchService.totalResults;
				} else {
					listOfPeopleWrapper = PeopleContentProvider.getMustReadRecordHistory(peopleCriteriaObjArg, cgId, mrAuditId, audienceType);
					totalRecods = PeopleContentProvider.totalRecords;
				}
   				peopleListingContainerObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action=getMustReadHistory&contentId=' + peopleCriteriaObjArg.contentId +'&filter=all';
				Decimal readCount = peopleDaoObj.getReadCount(mrAuditId, peopleCriteriaObjArg.contentId, cgId, audienceType);
				Decimal unreadCount = peopleDaoObj.getUnReadCount(mrAuditId,peopleCriteriaObjArg.contentId, cgId, audienceType);
				Decimal totalCount = readCount + unreadCount;
				peopleListingContainerObj.readCount = readCount.intValue();
				peopleListingContainerObj.totalCount = totalCount.intValue();
				Decimal readPercent = (readCount/totalCount)*100;
				peopleListingContainerObj.readPercent = readPercent;
				Decimal averageReadPercent = getReadBenchmarkPercent();
				peopleListingContainerObj.averageReadPercent = averageReadPercent;
				Decimal benchmarkVal = readPercent - averageReadPercent;
				peopleListingContainerObj.readBenchmarkPercent = benchmarkVal;
				if(totalCount.intValue() > 5000){
					peopleListingContainerObj.isCsvDownloadable = false;
				}else{
					peopleListingContainerObj.isCsvDownloadable = true;
				}
				
                if (peopleCriteriaObjArg.nextPageToken == null){
                    if ('read'.endsWithIgnoreCase(peopleCriteriaObjArg.filter)){
						peopleListingContainerObj.totalRecords = totalRecods; // readCount.intValue();
                    } else {
						peopleListingContainerObj.totalRecords = totalRecods; //unreadCount.intValue();
					}
				}
			} else if (String.isNotBlank(peopleCriteriaObjArg.expertiseId) && peopleCriteriaObjArg.includeTotal == null && !SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				listOfPeopleWrapper = PeopleContentProvider.getPeopleExpertiseList(peopleCriteriaObjArg);	
				peopleListingContainerObj.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action=getPeopleExpertise&expertiseId=' + peopleCriteriaObjArg.expertiseId;
	
	   		} else if (String.isNotBlank(peopleCriteriaObjArg.filter)) {
	   			
    			Map<String, Object> mapOfTileData = new Map<String, Object>();

				if ('my_department'.equalsIgnoreCase(peopleCriteriaObjArg.filter)) {
    				mapOfTileData = PeopleContentProvider.getPeopleInMyDepartment(peopleCriteriaObjArg);
    				
    			} else if ('my_location'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getMyLocationTileData(peopleCriteriaObjArg);
    				
    			} else if ('following'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getFollowingTileData(peopleCriteriaObjArg);
    				
    			} else if ('leadership'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getLeadershipTileData(peopleCriteriaObjArg);
    				
    			} else if ('direct_reports'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getMyDirectReportTileData(peopleCriteriaObjArg);
    				
    			} else if ('new_hires'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getNewHireTileData(peopleCriteriaObjArg);
    				
    			} else if ('celebrations'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getCelebrationTileData(peopleCriteriaObjArg);
    				
    			} else if ('custom_field'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getCustomFieldTileData(peopleCriteriaObjArg);
    				
    			} else if ('favorite'.equalsIgnoreCase(peopleCriteriaObjArg.filter)){
    				mapOfTileData = PeopleContentProvider.getFavoriteTileData(peopleCriteriaObjArg);
    				
    			}

    			listOfPeopleWrapper = (List<PeopleListWrapper>) mapOfTileData.get('listOfItems');
    			peopleListingContainerObj.totalRecords = (Integer) mapOfTileData.get('total');

			} else if(String.isNotBlank(peopleCriteriaObjArg.audienceId)) {
				listOfPeopleWrapper = PeopleContentProvider.getAudienceMembers(peopleCriteriaObjArg);

				String audienceMemberCsvUrl = PageContext.getPageURL(Pages.Reports) + '?action=getAudienceMembers' ;

				if (String.isNotBlank(peopleCriteriaObjArg.audienceId)){
					audienceMemberCsvUrl += '&audienceId=' + peopleCriteriaObjArg.audienceId;
				}

				if (String.isNotBlank(peopleCriteriaObjArg.term)){
					audienceMemberCsvUrl += '&term=' + peopleCriteriaObjArg.term;
				}

				peopleListingContainerObj.csvUrl = audienceMemberCsvUrl;
	   		
	   		} else if (String.isNotBlank(peopleCriteriaObjArg.segmentId) || 
                    String.isNotBlank(peopleCriteriaObjArg.subscriptionId)) {
				
					if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(peopleCriteriaObjArg.term)) {
						Criteria.ExternalSearchReq peopleSearchCriteria = new Criteria.ExternalSearchReq();
						
						peopleSearchCriteria.size = 9999;
						peopleSearchCriteria.term = peopleCriteriaObjArg.term;
						peopleSearchCriteria.ppl_segment_id = peopleCriteriaObjArg.segmentId;
	
						String searchForType = 'User';
	
						ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
						ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchServiceObj.searchPeople(peopleSearchCriteria, searchForType);
	
						Map<String, Object> mapOfAllPeople = new Map<String, Object> ();
						if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
							mapOfAllPeople = getPeopleDetailsfromSF(returnWrapper.listOfItems, peopleCriteriaObjArg);
						}
	
						listOfPeopleWrapper = (List<PeopleListWrapper>) mapOfAllPeople.get('listOfItems');
	
					} else {
						listOfPeopleWrapper = PeopleContentProvider.getSegmentationMembers(peopleCriteriaObjArg);
					}
				
				String segmentationMemberCsvUrl = PageContext.getPageURL(Pages.Reports) + '?action=getSegmentationMembers' ;
				
				if (String.isNotBlank(peopleCriteriaObjArg.segmentId)){
					segmentationMemberCsvUrl += '&segmentId=' + peopleCriteriaObjArg.segmentId;
				}

				if (String.isNotBlank(peopleCriteriaObjArg.subscriptionId)){
					segmentationMemberCsvUrl += '&subscriptionId=' + peopleCriteriaObjArg.subscriptionId;
				}

				if (String.isNotBlank(peopleCriteriaObjArg.term)){
					segmentationMemberCsvUrl += '&term=' + peopleCriteriaObjArg.term;
				}

				if (String.isNotBlank(peopleCriteriaObjArg.limitToSubsegment)){
					segmentationMemberCsvUrl += '&limitToSubsegment=' + peopleCriteriaObjArg.limitToSubsegment;
				}

				peopleListingContainerObj.csvUrl = segmentationMemberCsvUrl;					   			

			} else if(String.isNotBlank(peopleCriteriaObjArg.term) && String.isNotBlank(peopleCriteriaObjArg.includeMemberTypeForSite)){
				if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(peopleCriteriaObjArg.term)) {
					Criteria.ExternalSearchReq peopleSearchCriteria = new Criteria.ExternalSearchReq();
					
					peopleSearchCriteria.size = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size : 999;
					peopleSearchCriteria.term = peopleCriteriaObjArg.term;

					String searchForType = 'User';

					ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
					ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchServiceObj.searchPeople(peopleSearchCriteria, searchForType);

					Map<String, Object> mapOfAllPeople = new Map<String, Object> ();
					if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
						mapOfAllPeople = getPeopleDetailsfromSF(returnWrapper.listOfItems, peopleCriteriaObjArg);
					}

					listOfPeopleWrapper = (List<PeopleListWrapper>) mapOfAllPeople.get('listOfItems');

				} else {
					listOfPeopleWrapper = PeopleContentProvider.getEveryone(peopleCriteriaObjArg, null);

				}

			} else if (String.isNotBlank(peopleCriteriaObjArg.term) && peopleCriteriaObjArg.includeTotal != true){
				if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(peopleCriteriaObjArg.term)) {
					logger.logDebug('--In External Search--');
					Criteria.ExternalSearchReq peopleSearchCriteria = new Criteria.ExternalSearchReq();
					
					peopleSearchCriteria.size = peopleCriteriaObjArg.size;
					peopleSearchCriteria.term = peopleCriteriaObjArg.term;
					peopleSearchCriteria.nextPageToken = peopleCriteriaObjArg.nextPageToken;


					String searchForType = 'User';

					ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
					ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchServiceObj.searchPeople(peopleSearchCriteria, searchForType);
					peopleListingContainerObj.nextPageToken = returnWrapper.nextPageToken;
					isNextPageSetFromExternalSearch = true;
					List<String> peopleIds = new List<String>();
					for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : returnWrapper.listOfItems) {
						Object item = itemWrapperObj.item;
						PeopleListingWrapper plWrapper = (PeopleListingWrapper)item;
						peopleIds.add(plWrapper.id);
					}

					listOfPeopleWrapper = PeopleContentProvider.autoComplete(peopleCriteriaObjArg, peopleIds);
				} else {
					if(peopleCriteriaObjArg.size != null && peopleCriteriaObjArg.size > 999) {
						peopleCriteriaObjArg.size = 999;
					}
					listOfPeopleWrapper = PeopleContentProvider.autoComplete(peopleCriteriaObjArg, null);
				}
	   		
	   		} else {
				Map<String, Object> mapOfAllPeople = new Map<String, Object> ();
				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
					if( String.isNotBlank(peopleCriteriaObjArg.filterDays) && !'all_time'.equalsIgnoreCase(peopleCriteriaObjArg.filterDays))
					{
						integer totalDays = 0;
						String filter_value = peopleCriteriaObjArg.filterDays;
						date newdate = date.today();
						//filter_value is supposed to hold values like 'Last_7_days' or 'last_6_months'
						if( filter_value.containsIgnoreCase('days'))
						{
							filter_value = filter_value.removeStartIgnoreCase('Last_').removeEndIgnoreCase('_days');
							totalDays = integer.valueOf(filter_value);
						}
						if( filter_value.containsIgnoreCase('months'))
						{
							filter_value = filter_value.removeStartIgnoreCase('Last_').removeEndIgnoreCase('_months');
							newdate = date.today().addMonths(-integer.valueOf(filter_value));
							totalDays = -date.today().daysBetween(newdate);
						}
						List<String> listOfPeopleId = externalSearchServiceObj.getLatestHiresId(9999,totalDays);
						mapOfAllPeople = PeopleContentProvider.getAllPeople(peopleCriteriaObjArg,listOfPeopleId);
					}
					else
					{
						Criteria.ExternalSearchReq peopleSearchCriteria = new Criteria.ExternalSearchReq();

						if(String.isNotBlank(peopleCriteriaObjArg.term)) {
							peopleSearchCriteria.term = peopleCriteriaObjArg.term;
						}
						if('true'.equalsIgnoreCase(peopleCriteriaObjArg.limitToSubsegment)) {
							peopleSearchCriteria.ppl_segment_id =  UserContext.segmentId;
						}
						peopleSearchCriteria.sortBy = 'hire_date'.equalsIgnoreCase(peopleCriteriaObjArg.sortBy) ? peopleCriteriaObjArg.sortBy : null;
						peopleSearchCriteria.size = peopleCriteriaObjArg.size;
						peopleSearchCriteria.nextPageToken = peopleCriteriaObjArg.nextPageToken;
						peopleSearchCriteria.location = peopleCriteriaObjArg.location;
						peopleSearchCriteria.department = peopleCriteriaObjArg.department;
						peopleSearchCriteria.userCategory = peopleCriteriaObjArg.userCategory;
						
						peopleSearchCriteria.expertise = new ExpertiseWrapper();
						peopleSearchCriteria.expertise.id = peopleCriteriaObjArg.expertiseId;
						
						peopleSearchCriteria.Custom_Field_1 = peopleCriteriaObjArg.Custom_Field_1;
						peopleSearchCriteria.Custom_Field_2 = peopleCriteriaObjArg.Custom_Field_2;
						peopleSearchCriteria.Custom_Field_3 = peopleCriteriaObjArg.Custom_Field_3;
						peopleSearchCriteria.Custom_Field_4 = peopleCriteriaObjArg.Custom_Field_4;
						peopleSearchCriteria.Custom_Field_5 = peopleCriteriaObjArg.Custom_Field_5;
						peopleSearchCriteria.Custom_Field_6 = peopleCriteriaObjArg.Custom_Field_6;
						peopleSearchCriteria.Custom_Field_7 = peopleCriteriaObjArg.Custom_Field_7;
						peopleSearchCriteria.Custom_Field_8 = peopleCriteriaObjArg.Custom_Field_8;
						peopleSearchCriteria.Custom_Field_9 = peopleCriteriaObjArg.Custom_Field_9;
						peopleSearchCriteria.Custom_Field_10 = peopleCriteriaObjArg.Custom_Field_10;
						peopleSearchCriteria.Custom_Field_11 = peopleCriteriaObjArg.Custom_Field_11;
						peopleSearchCriteria.Custom_Field_12 = peopleCriteriaObjArg.Custom_Field_12;
						peopleSearchCriteria.Custom_Field_13 = peopleCriteriaObjArg.Custom_Field_13;
						peopleSearchCriteria.Custom_Field_14 = peopleCriteriaObjArg.Custom_Field_14;
						peopleSearchCriteria.Custom_Field_15 = peopleCriteriaObjArg.Custom_Field_15;
						peopleSearchCriteria.Custom_Field_16 = peopleCriteriaObjArg.Custom_Field_16;
						peopleSearchCriteria.Custom_Field_17 = peopleCriteriaObjArg.Custom_Field_17;
						peopleSearchCriteria.Custom_Field_18 = peopleCriteriaObjArg.Custom_Field_18;
						peopleSearchCriteria.Custom_Field_19 = peopleCriteriaObjArg.Custom_Field_19;
						peopleSearchCriteria.Custom_Field_20 = peopleCriteriaObjArg.Custom_Field_20;
						peopleSearchCriteria.Custom_Field_21 = peopleCriteriaObjArg.Custom_Field_21;
						peopleSearchCriteria.Custom_Field_22 = peopleCriteriaObjArg.Custom_Field_22;
						peopleSearchCriteria.Custom_Field_23 = peopleCriteriaObjArg.Custom_Field_23;						
						peopleSearchCriteria.Custom_Field_24 = peopleCriteriaObjArg.Custom_Field_24;
						peopleSearchCriteria.Custom_Field_25 = peopleCriteriaObjArg.Custom_Field_25;


						String searchForType = 'User';

						ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchServiceObj.searchPeople(peopleSearchCriteria, searchForType);
						peopleListingContainerObj.nextPageToken = returnWrapper.nextPageToken;
						peopleListingContainerObj.totalRecords = (Integer)returnWrapper.totalRecords;
						if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
							mapOfAllPeople = getPeopleDetailsfromSF(returnWrapper.listOfItems, peopleCriteriaObjArg);
						}
						isNextPageSetFromExternalSearch = true;
					}
				}
				else {
					mapOfAllPeople = PeopleContentProvider.getAllPeople(peopleCriteriaObjArg);
					peopleListingContainerObj.totalRecords = mapOfAllPeople.get('total') == null ? 0 : (Integer) mapOfAllPeople.get('total');
				}
				
				listOfPeopleWrapper = (List<PeopleListWrapper>) mapOfAllPeople.get('listOfItems');
			}

	   		if (listOfPeopleWrapper != null) {
	   			peopleListingContainerObj.listOfItems.addAll(listOfPeopleWrapper);
	   		}

	        if (!isNextPageSetFromExternalSearch && peopleListingContainerObj.listOfItems.size() == 
                    (SimpplrContext.simpplrDefaultPageSize + 1) &&
	     		    peopleCriteriaObjArg.offset < 2000) {
	        	peopleListingContainerObj.listOfItems.remove((peopleListingContainerObj.listOfItems.size()-1));
	        	peopleListingContainerObj.nextPageToken = String.valueOf(peopleCriteriaObjArg.offset + SimpplrContext.simpplrDefaultPageSize);
	       
	        } else if(!isNextPageSetFromExternalSearch){
	        	peopleListingContainerObj.nextPageToken = null;
	        }
	        logger.logdebug(listOfPeopleWrapper);
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleListingContainerObj);

			logger.logDebug('PeopleDataServer---- peopleListingContainerObj  :: ' + peopleListingContainerObj);
   		
   		} catch (Exception e) {
        	logger.logError('PeopleDataServer----Could not fetch people',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
   		return responseToReturn;
	}

	public Decimal getReadBenchmarkPercent(){
		Map<String, Object> soqlParamMap = new Map<String, Object>();	
		
		String queryStr = 'SELECT Id, Content__c,Content__r.Site__r.Chatter_group_Id__c,Audience_Type__c FROM Must_Read_Audit__c where Content__r.Is_Deleted__c = false AND Content__r.Is_Published__c = true';
		//				Removed_DateTime__c = null and (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime)
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Must_Read_Audit__c> mustReadAuditList = (List<Must_Read_Audit__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		Decimal totalReadPercent = 0;
		PeopleDao peopleDaoObj = new PeopleDao();
		Map<String,Integer> readMap = peopleDaoObj.getReadCountforList(mustReadAuditList);
		for(Must_Read_Audit__c mReadAudit : mustReadAuditList){
			if(!readMap.containsKey(mReadAudit.Id)){
				readMap.put(mReadAudit.Id, 0);
			}
		}
		Set<Id> chattergroupIdSet = new Set<Id>();
		for(Must_Read_Audit__c auditRec : mustReadAuditList){
			chattergroupIdSet.add(auditRec.Content__r.Site__r.Chatter_group_Id__c);
		}
		Map<String,Integer> totalMap = peopleDaoObj.getTotalCountforList(mustReadAuditList,chattergroupIdSet);
		logger.logDebug('--'+readMap);
		logger.logDebug('--'+totalMap);
		for(Must_Read_Audit__c auditRec : mustReadAuditList){
			if(totalMap.containsKey(auditRec.Id)){
				Decimal readCount = readMap.get(auditRec.Id);
				Decimal totalCount = totalMap.get(auditRec.Id) ;
				Decimal readPercent = (readCount/totalCount)*100;
					
				totalReadPercent = totalReadPercent + readPercent;
			}
		}
		logger.logDebug('--'+totalReadPercent);
		Decimal averageReadPercent = totalReadPercent/mustReadAuditList.size();
		return averageReadPercent;
	}

	/*
		@description Use when all the records of People required by API as offset supports upto 2000 records only.
		this is implemented for Newsletter+ unless required for other features.

		Supported functionalities until changes required:
		1. All Org (Return all people) - Accept {size, nextPageToken}
		2. Site (Return People people) - Accept {size, nextPageToken, siteId, type)}  optional - type = without type returns all Members and Followers, with Type = Members returns Site Members only
		3. Audience (Return Audience people) - Accept {size, nextPageToken, audienceId}
		4. Segment (Return Segment people) - Accept {size, nextPageToken, segmentId}

		Note: no sorting, term search allowed
		@return ResponseWrapper
	*/
	private ResponseWrapper getAllPeopleData (Criteria.People peopleCriteriaObjArg) {
		logger.logDebug('PeopleDataServer.getAllPeopleData() :: peopleCriteriaObjArg :: '+peopleCriteriaObjArg);
		ResponseWrapper responseToReturn = null;
		List<PeopleListWrapper> listOfPeopleWrapper = null;
		try {
		
			if (String.isNotBlank(peopleCriteriaObjArg.siteId)) {
				listOfPeopleWrapper = getSiteFilterData(peopleCriteriaObjArg);
					
			} else if(String.isNotBlank(peopleCriteriaObjArg.audienceId)) {
				listOfPeopleWrapper = PeopleContentProvider.getAllAudienceMembers(peopleCriteriaObjArg);
			
			} else if (String.isNotBlank(peopleCriteriaObjArg.segmentId) || String.isNotBlank(peopleCriteriaObjArg.subscriptionId)) {
				listOfPeopleWrapper = PeopleContentProvider.getAllSegmentationMembers(peopleCriteriaObjArg);					   			

			} else {
				Map<String, Object> mapOfAllPeople = new Map<String, Object> ();
				mapOfAllPeople = PeopleContentProvider.getAllPeopleData(peopleCriteriaObjArg, null);
				
				listOfPeopleWrapper = (List<PeopleListWrapper>) mapOfAllPeople.get('listOfItems');
			}

			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, handlePagination(listOfPeopleWrapper, peopleCriteriaObjArg));

		} catch (Exception e) {
			logger.logError('PeopleDataServer.getAllPeopleData() :: exception :: ',e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
		return responseToReturn;
	}

	private List<PeopleListWrapper> getSiteFilterData (Criteria.People peopleCriteriaObjArg) {
		if(peopleCriteriaObjArg.type != null && peopleCriteriaObjArg.type.containsIgnoreCase('members')){
			return PeopleContentProvider.getAllSiteMembers(peopleCriteriaObjArg);
		} else {
			return PeopleContentProvider.getAllSitesMembersFollowers(peopleCriteriaObjArg, null);
		}
	}

	private PeopleListWrapper.PaginationWrapper handlePagination (List<PeopleListWrapper> listOfPeopleWrapper, Criteria.People peopleCriteriaObjArg)  {
		PeopleListWrapper.PaginationWrapper peopleListingContainerObj = new PeopleListWrapper.PaginationWrapper();
		if (listOfPeopleWrapper != null) {
			peopleListingContainerObj.listOfItems.addAll(listOfPeopleWrapper);
		}

		Integer size = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size : SimpplrContext.simpplrDefaultPageSize;

		if (peopleListingContainerObj.listOfItems.size() == (size + 1)) {
			peopleListingContainerObj.listOfItems.remove((peopleListingContainerObj.listOfItems.size()-1));
			peopleListingContainerObj.nextPageToken = peopleListingContainerObj.listOfItems[(peopleListingContainerObj.listOfItems.size()-1)].peopleId;
		
		} else {
			peopleListingContainerObj.nextPageToken = null;
		}
		logger.logDebug('PeopleDataServer.getAllPeopleData() :: peopleListingContainerObj  :: ' + peopleListingContainerObj);
		return peopleListingContainerObj;
	}

    private List<PeopleListWrapper> searchInvitee(String searchTerm, String siteId, String contentId, Boolean isPrivate){
        Simpplr_Site__c siteObj = [select id, Site_Type__c, Chatter_Group_Id__c from  Simpplr_Site__c where id=:siteId WITH SECURITY_ENFORCED ]; 
        String groupId = siteObj.Chatter_Group_Id__c;
        EventDao eventDaoObj = new EventDao();
        Simpplr_Content__c contentRecord = eventDaoObj.getContentFromId(contentId, siteId);
        if(contentRecord == null){
            throw New SimpplrException(ExceptionCode.EVENT_IS_DELETED.name());
        }
        List<Event_Invitee__c> invitedUsersList;
        Set<String> peopleIds = new Set<String>();
        Boolean isSearchWithPeopleId = false;
        if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(searchTerm)) {
            ExternalSearchService searchServiceObj = new ExternalSearchService();
            peopleIds = searchServiceObj.getPeopleIds(searchTerm, 2000);
            invitedUsersList  = eventDaoObj.getEventInvitedUsers(new List<String>{contentId}, peopleIds);
            isSearchWithPeopleId = true;
        } else {
            invitedUsersList  = eventDaoObj.getEventInvitedUsersBySearchTermList(contentId,searchTerm);
        }
        List<Content_Collaborator__c> contentOrganizers = eventDaoObj.getEventOrganizerFromId(contentId);
        Set<Id> exclusionIdSet = New Set<Id>();
        for(Event_Invitee__c record : invitedUsersList){
            exclusionIdSet.add(record.Invitee__c);
            peopleIds.remove(record.Invitee__c);
        }
        for(Content_Collaborator__c record : contentOrganizers){
            exclusionIdSet.add(record.Collaborator__c);
            peopleIds.remove(record.Collaborator__c);
        }
        exclusionIdSet.add(contentRecord.Primary_Author__c);
        peopleIds.remove(contentRecord.Primary_Author__c);
        List<People__c> peopleList = New List<People__c>();

        Boolean isUnlisted = false;
        if(ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteObj.Site_Type__c)) {
            isUnlisted = true;
        }

        if(isPrivate || isUnlisted){
            peopleList = PeopleContentProvider.getSiteMembersBySearchTermWithExclusionList(groupId,searchTerm,exclusionIdSet);
        }else if(isSearchWithPeopleId){
            PeopleDao peopleDaoObj = new PeopleDao();
            List<String> tempPeopleIds = new List<String>();
            tempPeopleIds.addAll(peopleIds);
            peopleList = peopleDaoObj.getPeopleByPeopleIds(tempPeopleIds);
            tempPeopleIds.clear();
        } else {
            UserDao userDaoObj = new UserDao();
            peopleList = userDaoObj.getUsersBySearchTermWithExclusion(searchTerm, exclusionIdSet);
        }
        List<PeopleListWrapper> peopleListWrapperObj = PeopleListWrapper.peopleListToWrapper(peopleList);
        return peopleListWrapperObj;
    }

	private List<PeopleListWrapper> getAllFavoritesPeople(Criteria.People peopleCriteriaObjArg) {
		List<PeopleListWrapper> peopleWrapperList = new List<PeopleListWrapper>();

		if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotEmpty(peopleCriteriaObjArg.term)) {
			List<String> favPeopleIds = PeopleContentProvider.getAllFavoritePeopleIds(peopleCriteriaObjArg);

			String SEARCH_TYPE_USER = 'User';
			ExternalSearchService externalSearchService = new ExternalSearchService();

			Criteria.ExternalSearchReq peopleSearchCriteria = new Criteria.ExternalSearchReq();
			peopleSearchCriteria.favouriteIds = favPeopleIds;
			peopleSearchCriteria.term = peopleCriteriaObjArg.term;
			peopleSearchCriteria.filter = peopleCriteriaObjArg.filter;
			peopleSearchCriteria.size = peopleCriteriaObjArg.size;
			peopleSearchCriteria.nextPageToken = peopleCriteriaObjArg.nextPageToken;

			ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchPeople(peopleSearchCriteria, SEARCH_TYPE_USER);

			if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
				List<String> peopleIds = new List<String>();
				for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : returnWrapper.listOfItems) {
					Object item = itemWrapperObj.item;
					PeopleListingWrapper slWrapper = (PeopleListingWrapper)item;
					peopleIds.add(slWrapper.id);
				}						

				peopleWrapperList = PeopleContentProvider.getFavPeopleFromPeopleIds(peopleIds);
			}
		} 
		else {
			peopleWrapperList = PeopleContentProvider.getAllFavoritesPeople(peopleCriteriaObjArg);
		}

		return peopleWrapperList;
	}

	private Map<String, Object> getPeopleDetailsfromSF(List<ExternalSearchWrapper.ItemWrapper> listOfItems, Criteria.People peopleCriteriaObjArg) {
		
		//removed term - so that Name__c like '' is not appended to Database.query when people details are fetched from SF
		peopleCriteriaObjArg.term = null;

		List<String> peopleIds = new List<String>();
		
		for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems) {
			Object item = itemWrapperObj.item;
			PeopleListingWrapper plWrapper = (PeopleListingWrapper)item;
			peopleIds.add(plWrapper.id);
		}
		Map<String, Object> mapOfAllPeople = PeopleContentProvider.getAllPeople(peopleCriteriaObjArg, peopleIds);
		return mapOfAllPeople;
	}
    
    private ResponseWrapper getEndorsements(String profileId){
    	logger.logDebug('PeopleDataServer.getEndorsements()----profileId----'+profileId);
    	ResponseWrapper localResult = new ResponseWrapper();
    	
    	try {
    		UserDao userDaoObj = new UserDao();
    		List<PeopleWrapper.EndorsementsWrapper> listOfEndorsements= userDaoObj.getEndorsementsForUser(profileId);
    		localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
    				null,  
    				listOfEndorsements);
    		logger.logDebug('PeopleDataServer.getEndorsements()----localResult----'+localResult);
    	
    	} catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not fetch endorsements',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        return localResult;
    }
    
    private ResponseWrapper addEndorsement (String userId, String expertiseId, String endorsedById){
    	logger.logDebug('PeopleDataServer.addEndorsement()----userId----' + userId);
    	logger.logDebug('PeopleDataServer.addEndorsement()----expertiseId----' + expertiseId);
    	ResponseWrapper localResult = new ResponseWrapper();
    	
    	try {
    		List<Expertise__c> listOfDBExpertise = new List<Expertise__c>();
	        String queryExpertise= 'select Id, Name__c, Display_Name__c from Expertise__c where Id = :expertiseId';
	        
	        listOfDBExpertise = Database.query(queryExpertise);
    		
    		if (listOfDBExpertise.size()==0) {
    			throw new SimpplrException(ServiceConstants.ERROR_404);
    		}

			List<String> userIdList = new List<String>{userId, endorsedById};
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', userIdList);
			String query = '';
			
			if (String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
				soqlParamMap.put('soqlParam2', SimpplrContext.packageName);
				query = 'select id, user__c, name, Full_Name__c, External_Photo_URL__c, External_Photo_URL_Expiry_Date__c, About__c from People__c where (user__c IN :soqlParam1 OR Id IN :soqlParam1) and User__r.IsActive=true and User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: soqlParam2)';
			
			} else {
				query = 'select id, user__c, name, Full_Name__c, External_Photo_URL__c, External_Photo_URL_Expiry_Date__c, About__c from People__c where (user__c IN :soqlParam1 OR Id IN :soqlParam1) and User__r.IsActive=true and User__r.UserType=\'Standard\'';
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

			Map<String,People__c> peopleIdToPeopleMap = new Map<String,People__c>(); 
			Map<String, String> userIdToPeopleId = new Map<String, String>();
			for (People__c ppl : peopleList){
				userIdToPeopleId.put(ppl.User__c, ppl.id);
				peopleIdToPeopleMap.put(ppl.id,ppl);
			}
			
			userId = userId.startsWith('005') ? userIdToPeopleId.get(userId) : userId; //make sure its peopleId
			endorsedById = endorsedById.startsWith('005') ? userIdToPeopleId.get(endorsedById) : endorsedById; //make sure its peopleId

			if(!peopleIdToPeopleMap.containsKey(userId) || !peopleIdToPeopleMap.containsKey(endorsedById)){
				throw new SimpplrException('Invalid User!');
			}
			
			PeopleWrapper.EndorsementsWrapper addEndorsementObj = null;

			Expertise__c expertiseObject = null;
			for(Expertise__c expertiseObj : listOfDBExpertise){
				expertiseObject = expertiseObj;
			}

			if(SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected) {
				List<ExternalSearchWrapper.ExpertiseWrapper> listOfExpertiseWrap = new List<ExternalSearchWrapper.ExpertiseWrapper>();
				ExternalSearchWrapper.ExpertiseWrapper expertObj = new ExternalSearchWrapper.ExpertiseWrapper();
				expertObj.id = expertiseObject.Id;
				expertObj.name = expertiseObject.Display_Name__c;
				expertObj.count = 1;
				listOfExpertiseWrap.add(expertObj);
				ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
				objectToIndex.id = userId;
				objectToIndex.object_type = 'People';
				objectToIndex.expertise = listOfExpertiseWrap;
				String body = JSON.serialize(objectToIndex); 
                indexDataInElastic(body);
			}
    		
			// Check if people-Expertise already exists, if yes, fetch it else insert a new record.
			People_Expertise__c peopleExpertiseObj = checkAndFetchPeopleExpertiseRecord(expertiseId, peopleIdToPeopleMap.get(userId));
			if(peopleExpertiseObj ==  null) {
				peopleExpertiseObj = insertPeopleExpertiseRecord(expertiseId, peopleIdToPeopleMap.get(userId));
			} else {
				// If its a self hidden expertise
				peopleExpertiseObj = unhidePeopleExpertiseRecord(expertiseId, peopleIdToPeopleMap.get(userId));
			}

			People_Expertise_Detail__c pEDObj = insertPeopleExpertiseDetailRecord(peopleExpertiseObj, endorsedById);

			sendNotificationAndEmailForEndorsement(peopleIdToPeopleMap.get(userId), peopleIdToPeopleMap.get(endorsedById), expertiseObject);

			PeopleWrapper.EndorsementsWrapper endorsementObj = toEndorsementWrapper(expertiseObject);
    		
			localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, endorsementObj);
    		logger.logDebug('PeopleDataServer.addEndorsement()----after endorsementObj----' + localResult);
    	
    	} catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not add endorsements',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return localResult;
	}
	
	private People_Expertise__c checkAndFetchPeopleExpertiseRecord(String expertiseId, People__c peopleObjForEndorsee) {
		String endorseeId = peopleObjForEndorsee.Id;
		List<People_Expertise__c> peopleExpertiseList = [SELECT Id, Expertise__c, People__c, Is_Self_Endorsed__c FROM People_Expertise__c
															WHERE Expertise__c = :expertiseId AND People__c = :endorseeId WITH SECURITY_ENFORCED];

		return (peopleExpertiseList.isEmpty() ? null : peopleExpertiseList[0]);
	}

	private People_Expertise__c insertPeopleExpertiseRecord(String expertiseId, People__c peopleObjForEndorsee) {
		People_Expertise__c peopleExpertiseObj = new People_Expertise__c();

		peopleExpertiseObj.Expertise__c = expertiseId;
		peopleExpertiseObj.People__c = peopleObjForEndorsee.Id;
		if(UserContext.userId.equalsIgnorecase(peopleObjForEndorsee.User__c)) {
			peopleExpertiseObj.Is_Self_Endorsed__c = true;
		} else {
			peopleExpertiseObj.Is_Self_Endorsed__c = false;
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    	peopleExpertiseObj = (People_Expertise__c)SIMPESAPI.accessController().insertAsUser(peopleExpertiseObj, new List<Schema.SObjectField>{
																			People_Expertise__c.Expertise__c,
																			People_Expertise__c.People__c,
																			People_Expertise__c.Is_Self_Endorsed__c});

		return peopleExpertiseObj;
	}

	private People_Expertise__c unhidePeopleExpertiseRecord(String expertiseId, People__c peopleObjForEndorsee) {
		People_Expertise__c peopleExpertiseObj;
		List<People_Expertise__c> peopleExpertiseList = [SELECT Id, Expertise__c from People_Expertise__c WHERE Expertise__c= :expertiseId AND People__c = :peopleObjForEndorsee.Id WITH SECURITY_ENFORCED LIMIT 1];

		if (!peopleExpertiseList.isEmpty()) {

			for(People_Expertise__c peopleExpertise : peopleExpertiseList){
				peopleExpertiseObj = peopleExpertise;

				break;
			}

			if(UserContext.peopleId.equalsIgnoreCase(peopleObjForEndorsee.id)) {

				peopleExpertiseObj.Is_Self_Hidden__c = false;
				
				if(UserContext.userId.equalsIgnorecase(peopleObjForEndorsee.User__c)) {
					peopleExpertiseObj.Is_Self_Endorsed__c = true;
				} else {
					peopleExpertiseObj.Is_Self_Endorsed__c = false;
				}
			
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<id, People_Expertise__c>(peopleExpertiseList), 
															new List<Schema.SObjectField>{
																People_Expertise__c.Is_Self_Hidden__c,
																People_Expertise__c.Is_Self_Endorsed__c});
			}
		}

		return peopleExpertiseObj;
	}

	private People_Expertise_Detail__c insertPeopleExpertiseDetailRecord(People_Expertise__c peopleExpertiseObj, String endorsedById) {
		List<People_Expertise_Detail__c> peopleExpertiseDetailList = [SELECT Id FROM People_Expertise_Detail__c WHERE People_Expertise__c = :peopleExpertiseObj.Id AND Endorser__c =: endorsedById]; 
		People_Expertise_Detail__c pEDObj = new People_Expertise_Detail__c();
		if(peopleExpertiseDetailList.size() == 0){
			pEDObj.People_Expertise__c = peopleExpertiseObj.Id;
			pEDObj.Endorser__c = endorsedById;
	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			pEDObj = (People_Expertise_Detail__c)SIMPESAPI.accessController().insertAsUser(pEDObj, new List<Schema.SObjectField>{
																				People_Expertise_Detail__c.People_Expertise__c,
																				People_Expertise_Detail__c.Endorser__c});
		} else {
			throw new SimpplrException('Already Endorsed!');
		}
		return pEDObj;
	}

	private PeopleWrapper.EndorsementsWrapper toEndorsementWrapper(Expertise__c expertiseObj) {
		PeopleWrapper.EndorsementsWrapper endorsementObj = new PeopleWrapper.EndorsementsWrapper();

		endorsementObj.expertise.id = expertiseObj.id;
		endorsementObj.expertise.name = expertiseObj.Display_Name__c;
		//endorsementObj.expertise.url = PageContext.getPageURL(Pages.PeopleExpertise) + '?topicId=' + expertiseObj.Id;
		
		endorsementObj.count=4;
		endorsementObj.isEndorsed=true;

		return endorsementObj;
	}

	private void sendNotificationAndEmailForEndorsement(People__c targetUser, People__c endorsedBy, Expertise__c expertiseObj) {
		NotificationDispatcher.sendNotificationForEndorsement(targetUser.Id, endorsedBy.Id, expertiseObj.Id, expertiseObj.Display_Name__c);    					
		if (SimpplrContext.enableEmail && !targetUser.id.equals(UserContext.id)){	
			Map<String,String> expertiseMap = new Map<String,String>{expertiseObj.Id => expertiseObj.Display_Name__c};
			NotificationDispatcher.sendEmailForEndorsement(targetUser, endorsedBy, expertiseMap);
		}
	}
    
    private ResponseWrapper removeEndorsement (String userId, String expertiseId, String endorsedById){
    	logger.logDebug('PeopleDataServer.removeEndorsement()----userId----' + userId);
    	logger.logDebug('PeopleDataServer.removeEndorsement()----expertiseId----' + expertiseId);
		ResponseWrapper localResult = new ResponseWrapper();
		
		try {
			List<String> userIdList = new List<String>{userId};
			List<Expertise__c> listOfExpertise = [SELECT id, Name, Display_Name__c FROM Expertise__c WHERE id = :expertiseId];

			List<People__c> peopleListForEndorsee = [select Id from People__c WHERE User__c IN :userIdList OR Id IN :userIdList];
			String peopleId = peopleListForEndorsee.get(0).Id;
			if (!listOfExpertise.isEmpty() && SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected) { 
                List<ExternalSearchWrapper.ExpertiseWrapper> listOfExpertiseWrap = new List<ExternalSearchWrapper.ExpertiseWrapper>();
                ExternalSearchWrapper.ExpertiseWrapper expertObj = new ExternalSearchWrapper.ExpertiseWrapper();
                expertObj.id = expertiseId;
                expertObj.count = -1;
                expertObj.name = listOfExpertise[0].name;
                listOfExpertiseWrap.add(expertObj);
                ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
                objectToIndex.id = peopleId;
                objectToIndex.object_type = 'People';
                objectToIndex.expertise = listOfExpertiseWrap;
                String body = JSON.serialize(objectToIndex); 
                indexDataInElastic(body);
			}

			// Delete People_Expertise_Detail record
			List<People_Expertise_Detail__c> peopleExpertiseDetailList = [SELECT Id FROM People_Expertise_Detail__c 
														WHERE People_Expertise__r.Expertise__c = :expertiseId 
														AND People_Expertise__r.People__c = :peopleId
														AND Endorser__c = :endorsedById WITH SECURITY_ENFORCED
														LIMIT 1];
			if( !peopleExpertiseDetailList.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(peopleExpertiseDetailList);
			}

			// Delete People_Expertise record
			List<People_Expertise__c> peopleExpertiseList = [SELECT id, name FROM People_Expertise__c 
														WHERE Expertise__c = :expertiseId 
														AND People__c = :peopleId 
														AND Endorser_Count__c = 0 WITH SECURITY_ENFORCED];
			if( !peopleExpertiseList.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(peopleExpertiseList);
			}

			localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	} catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not remove Expertises',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return localResult;

    }
    
    //"Hide me" option from salesforce endorsement 
    private ResponseWrapper removeExpertise (String userId, String expertiseId){
    	logger.logDebug('PeopleDataServer.removeExpertise()----userId----' + userId);
    	logger.logDebug('PeopleDataServer.removeExpertise()----expertiseId----' + expertiseId);
    	ResponseWrapper localResult = new ResponseWrapper();
		if(UserInfo.getUserId() != userId) {
        	logger.logError('PeopleDataServer---- UserId does not match current users');
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			return localResult;
		}
    	List<Expertise__c> listOfExpertise = [SELECT id, Name, Display_Name__c FROM Expertise__c WHERE id = :expertiseId WITH SECURITY_ENFORCED];
        List<People__c> peopleListForEndorsee = [select Id from People__c WHERE User__c = :userId WITH SECURITY_ENFORCED];
		String peopleId = peopleListForEndorsee.get(0).Id;			
    	
        try {    		
            if (!listOfExpertise.isEmpty() && SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected) { 
                List<ExternalSearchWrapper.ExpertiseWrapper> listOfExpertiseWrap = new List<ExternalSearchWrapper.ExpertiseWrapper>();
                ExternalSearchWrapper.ExpertiseWrapper expertObj = new ExternalSearchWrapper.ExpertiseWrapper();
                expertObj.id = expertiseId;
                expertObj.count = -999;
                expertObj.name = listOfExpertise[0].name; 
                listOfExpertiseWrap.add(expertObj);
                ExternalSearchWrapper.SearchDataWrapper objectToIndex = new ExternalSearchWrapper.SearchDataWrapper();
                objectToIndex.id = peopleId;
                objectToIndex.object_type = 'People';
                objectToIndex.expertise = listOfExpertiseWrap;
                String body = JSON.serialize(objectToIndex); 
                indexDataInElastic(body);
			}
			
			// set expertise as hidden for the people
			ExpertiseDao expertiseDaoObj = new ExpertiseDao();
			expertiseDaoObj.removeExpertiseFromProfile(expertiseId, peopleId);
    	} catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not remove Expertises',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return localResult;
    }
    
    private ResponseWrapper getCompanyStats(){
    	logger.logDebug('PeopleDataServer.getCompanyStats()');
    	PeopleWrapper.CompanyStats compStatObj = new PeopleWrapper.CompanyStats();
    	ResponseWrapper localResult = new ResponseWrapper();
    	
    	try {
    		PeopleDao peopleDaoObj = new PeopleDao();
    		compStatObj = peopleDaoObj.getCompanyStats();
	 		localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, compStatObj);
    		
    	} catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not retrieved company stats',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return localResult;
    }
    
    private ResponseWrapper getInstallStats(){
    	logger.logDebug('PeopleDataServer.getCompanyStats()');
    	PeopleWrapper.InstallStats installStatObj = new PeopleWrapper.InstallStats();
    	ResponseWrapper localResult = new ResponseWrapper();
    	
    	try {
    		FilterService serviceObj = new FilterService();
    		installStatObj = serviceObj.getInstallStats();
	 		localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, installStatObj);
    		
    	} catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not retrieved Install stats',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return localResult;
    }
    
    private ResponseWrapper getCustomFields(){
    	logger.logDebug('PeopleDataServer.getCustomFields()');
    	ResponseWrapper localResult = new ResponseWrapper();
    	
    	PeopleWrapper.CustomField customFieldObj = new PeopleWrapper.CustomField(); 
    	
    	try {
    		FilterService service = new FilterService();
    		customFieldObj.listOfItems = service.getListOfPeopleCategories();
	 		localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, customFieldObj);
    		logger.logDebug('PeopleDataServer.getCustomFields()----localResult----'+localResult);
    		
    	} catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not retrieved Custom field list',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return localResult;
    }
    
	private ResponseWrapper getFieldValues(String requestData) {
		ResponseWrapper responseWrapperObj = null;
		try{
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			PeopleContentProvider providerObj = new PeopleContentProvider();
			Integer recordLimit = 33;
			if(requestMap.containsKey('size')) {
				recordLimit = Integer.valueOf(requestMap.get('size') + 1);

			}
			List<FilterAttributeWrapper> listOfItems;
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				listOfItems = providerObj.getValues(requestMap.get('term'), requestMap.get('columnName'));
			} else {
				listOfItems = providerObj.getValues(requestMap.get('term'), requestMap.get('columnName'), recordLimit);
			}

			Integer nextPageToken;
			if (listOfItems.size() == recordLimit) {
				listOfItems.remove((listOfItems.size()-1));
				nextPageToken = listOfItems.size();
			
			} 
			Map<String, Object> resultMap = new Map<String, Object>();
			resultMap.put('listOfItems', listOfItems);
			resultMap.put('nextPageToken', nextPageToken);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);     	
		} catch(Exception ex) {
			logger.logError('PeopleDataServer.getFieldValues()----Exception Occured----', ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
     	return responseWrapperObj;
	}

 	private ResponseWrapper searchLocation(Criteria.People pplCriteriaObj) {
     	ResponseWrapper responseWrapperObj = null;
     	
		pplCriteriaObj.offset = pplCriteriaObj.nextPageToken == null ? 0 : Integer.valueOf(pplCriteriaObj.nextPageToken);
     	PeopleContentProvider providerObj = new PeopleContentProvider();
     	
		List<FilterAttributeWrapper> listOfItems = new List<FilterAttributeWrapper>();

		if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(pplCriteriaObj.term)) {
			ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
			ExternalSearchWrapper.TopContentsWrapper externalSearchResponse = new ExternalSearchWrapper.TopContentsWrapper();
			externalSearchResponse = externalSearchServiceObj.searchPeopleLocation(pplCriteriaObj);

			listOfItems = convertToFilterWrapper(externalSearchResponse.listOfItems, 'location');

		} else {
			listOfItems = providerObj.searchLocation(pplCriteriaObj);
		}
		
		Integer nextPageToken;
		if (listOfItems.size() == (pplCriteriaObj.size + 1) &&
			pplCriteriaObj.offset < 2000) {
			listOfItems.remove((listOfItems.size()-1));
			nextPageToken = pplCriteriaObj.offset + pplCriteriaObj.size;
		
		} 

		Map<String, Object> resultMap = new Map<String, Object>();
		resultMap.put('listOfItems', listOfItems);
		resultMap.put('nextPageToken', nextPageToken);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);     	
     	return responseWrapperObj;
     }
     
     private ResponseWrapper searchDepartment(Criteria.People pplCriteriaObj) {
     	logger.logDebug('PeopleDataServer.searchDepartment()----pplCriteriaObj----'+pplCriteriaObj);
     	ResponseWrapper responseWrapperObj = null;
     			
		pplCriteriaObj.offset = pplCriteriaObj.nextPageToken == null ? 0 : Integer.valueOf(pplCriteriaObj.nextPageToken);
     	PeopleContentProvider providerObj = new PeopleContentProvider();
     	
		List<FilterAttributeWrapper> listOfItems = new List<FilterAttributeWrapper>();

		if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(pplCriteriaObj.term)) {
			ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
			ExternalSearchWrapper.TopContentsWrapper externalSearchResponse = new ExternalSearchWrapper.TopContentsWrapper();
			externalSearchResponse = externalSearchServiceObj.searchPeopleDepartment(pplCriteriaObj);

			listOfItems = convertToFilterWrapper(externalSearchResponse.listOfItems, 'department');

		} else {
			listOfItems = providerObj.searchDepartment(pplCriteriaObj);
		}

		Integer nextPageToken;
		if (listOfItems.size() == (pplCriteriaObj.size + 1) &&
			pplCriteriaObj.offset < 2000) {
			listOfItems.remove((listOfItems.size()-1));
			nextPageToken = pplCriteriaObj.offset + pplCriteriaObj.size;
		
		}
		
		Map<String, Object> resultMap = new Map<String, Object>();
		resultMap.put('listOfItems', listOfItems);
		resultMap.put('nextPageToken', nextPageToken);
     	 
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
     	return responseWrapperObj;
     }
	 
	 private List<FilterAttributeWrapper> convertToFilterWrapper(List<ExternalSearchWrapper.ItemWrapper> listOfItems, String convertFor){
        List<FilterAttributeWrapper> wrapperList = new List<FilterAttributeWrapper>();
		FilterAttributeWrapper filterWrapperItem ;
		
        for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems){

            Object item = itemWrapperObj.item;

            ExternalSearchWrapper.FilterAttributeWrapper expertiseObj = (ExternalSearchWrapper.FilterAttributeWrapper)item;

            filterWrapperItem = new FilterAttributeWrapper();
            filterWrapperItem.id = String.isNotBlank(expertiseObj.id) ? convertFor.equalsIgnoreCase('department') ? expertiseObj.id.toLowerCase() : expertiseObj.id : null;
            filterWrapperItem.name = expertiseObj.name;

            wrapperList.add(filterWrapperItem);
        }

        return wrapperList;

	}
	
    private ResponseWrapper getLocation(String  locationId) {
     	ResponseWrapper responseWrapperObj = null;
     	PeopleWrapper.UserLocation locationObj;
     	
     	ResponseWrapper localResult = new ResponseWrapper();
     	
     	PeopleDao peopleDaoObj = new PeopleDao();
		if(locationId != null && !'all'.equalsIgnoreCase(locationId)) {
     		locationObj =peopleDaoObj.getLocation(locationId);
		}
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, locationObj);
     	logger.logDebug('PeopleDataServer.getLocation()----responseWrapperObj----'+responseWrapperObj);
     	return responseWrapperObj;
	}
    
    private ResponseWrapper saveAboutMe(String peopleId, String aboutMeText) {
   		logger.logDebug('PeopleDataServer.saveAboutMe()----peopleId----'+peopleId+'--aboutMeText--'+aboutMeText);
   		ResponseWrapper responseToReturn = null;
   		try{
   			Boolean isSyncDisabled = 'None'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication);
   			Boolean isAboutMeEditable =  isSyncDisabled ? true : !SimpplrContext.isPDSAboutMe;
   			if(isAboutMeEditable){
   				People__c people =[SELECT id, About__c FROM People__c WHERE id=:peopleId limit 1];
   				people.About__c =  aboutMeText;
				
   				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(people,new List<Schema.SObjectField>{
						People__c.About__c});
   				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
   			} else {
   				throw new SimpplrException(ServiceConstants.ERROR_403);
   			}
   		
   		} catch(Exception e) {
        	logger.logError('PeopleDataServer.saveAboutMe()----Could not save about me',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
   		return responseToReturn;
   	}

	private ResponseWrapper getRedirectUrl(String requestData) {
		ResponseWrapper responseWrapperObj;
		try {
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('PeopleDataServer.getRedirectUrl()----requestMap----' + requestMap);
			String appName = requestMap.get('appName');
			String retURL = requestMap.get('retURL');
			String redirectUrl = '';
			if(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equals(appName)) {
				redirectUrl = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + '?retURL=' + retURL + '&state=' + IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR;
			} else if(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equals(appName)) {
				redirectUrl = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + '?retURL=' + retURL + '&state=' + IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS;
			} else if(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS_ADMIN.equals(appName)) {
				redirectUrl = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + '?retURL=' + retURL + '&state=' + IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS_ADMIN;
			} else if(IntegrationConstants.INTEGRATION_TYPE_SLACK.equals(appName)) {
				redirectUrl = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + '?retURL=' + retURL + '&state=' + IntegrationConstants.INTEGRATION_TYPE_SLACK;
			} else if(IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL.equals(appName)) {
				redirectUrl = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + '?retURL=' + retURL + '&state=' + IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL;
			}
			Map<String, String> responseMap = new Map<String, String>();
			responseMap.put('redirectUrl', redirectUrl);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);	
		} catch (Exception ex) {
			logger.logError('PeopleDataServer.getRedirectUrl()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);			
		}
		return responseWrapperObj;
	}

	private ResponseWrapper connectApp(String requestData) {
		ResponseWrapper responseWrapperObj;
		try {
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('PeopleDataServer.connectApp()----requestMap----' + requestMap);
			String appName = requestMap.get('appName');
			String retURL = requestMap.get('retURL');
			String redirectUrl = '';
			
			Boolean isFacebookEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
		    	Boolean isLinkedinEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
		    	Boolean isTwitterEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_TWITTER);
		    	IntegrationService integrationServiceObj = new IntegrationService(UserContext.peopleId);
		    	
		    	if (IntegrationConstants.INTEGRATION_TYPE_FACEBOOK.equalsIgnoreCase(appName) && 
		    		SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK)) {
		    			
		    		integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
		    		redirectUrl = integrationServiceObj.getAuthPage();
		    		
		    	} else 	if (IntegrationConstants.INTEGRATION_TYPE_LINKEDIN.equalsIgnoreCase(appName) && 
		    		SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN)) {
		    			
		    		integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
		    		redirectUrl = integrationServiceObj.getAuthPage();
					System.debug('redirectUrl---Amit--'+redirectUrl);
		    		
		    	} else if (IntegrationConstants.INTEGRATION_TYPE_TWITTER.equalsIgnoreCase(appName) && 
		    		SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_TWITTER)) {
		    			
		    		TwitterService twtService = new TwitterService();
					redirectUrl = twtService.getTwitterRequestToken(retURL);
				
		    	} else 	if (IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE.equalsIgnoreCase(appName) && SimpplrContext.slackIntegrationEnabled) {
					
					String REDIRECT_URL_STRING = 'https://services.simpplr.com/oauth/redirect/code_passthrough.php';
					String finalRedirectUrl = REDIRECT_URL_STRING + '?state=' + EncodingUtil.urlEncode(PageContext.getPageURL(Pages.SlackSettings)+'&state='+UserContext.peopleId, 'UTF-8');
					redirectUrl = 'https://slack.com/oauth/authorize?client_id=' + SimpplrContext.SlackClientId +
							 '&state='+EncodingUtil.urlEncode(PageContext.getPageURL(Pages.SlackSettings)+'?state='+UserContext.peopleId+'&retUrl='+retUrl, 'UTF-8')+
            				 '&scope=groups:read,channels:read,links:read,links:write,chat:write:bot,team:read,users:read' + 
            				 '&redirect_uri='+finalRedirectUrl+'&retUrl='+retUrl;
				
				} else if (SimpplrContext.isServiceNowConnected && IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appName)) {
				
					integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW); 
					redirectUrl = integrationServiceObj.getAuthPage();
                
                } else if (SimpplrContext.isAtlassianConnected && IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN.equalsIgnoreCase(appName)) {
					redirectUrl = new AtlassianHelper().getPeopleAuthUrl();
                
                } else if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE.equalsIgnoreCase(appName) && 
						SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE) != null && 
						SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).Integration_Enabled__c) {
					
					redirectUrl = new GoogleDriveHelper().getPeopleAuthUrl();
				
				}  else if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(appName) && 
					SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR) != null && 
					SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR).Integration_Enabled__c) {
			
					redirectUrl = new GoogleCalendarHelper().getPeopleAuthUrl();

				} else 	if (IntegrationConstants.INTEGRATION_TYPE_DROPBOX.equalsIgnoreCase(appName) && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_DROPBOX) != null && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_DROPBOX).Integration_Enabled__c) {
					redirectUrl = EFSAccessService.getAuthURL(appName);

				} else 	if (IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE.equalsIgnoreCase(appName) && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE) != null && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE).Integration_Enabled__c) {
					redirectUrl = EFSAccessService.getAuthURL(appName);

				} else 	if (IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT.equalsIgnoreCase(appName) && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT) != null && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT).Integration_Enabled__c) {
                    redirectUrl = EFSAccessService.getAuthURL(appName);
                    	
				} else 	if (IntegrationConstants.INTEGRATION_TYPE_BOX.equalsIgnoreCase(appName) && SimpplrContext.IsBoxIntegrationEnabled) {
					if(IntegrationConstants.BOX_CLIENT_ID.equalsIgnoreCase(SimpplrContext.BoxClientId)) {
						redirectUrl = ServiceConstants.BOX_CONNECT_URL + 
										'&client_id=' + SimpplrContext.BoxClientId +
										'&redirect_uri=' +  EncodingUtil.urlEncode(SimpplrContext.simpplrAPIEndpoint + '/oauth/box-oauth-manager', 'UTF-8') + 
										'&state=' + EncodingUtil.urlEncode(PageContext.getPageURL(Pages.StorageSettings) + '?state=Box', 'UTF-8');
					} else {
						redirectUrl = ServiceConstants.BOX_CONNECT_URL + 
									'&state=Box'  +
									'&client_id=' + SimpplrContext.BoxClientId +
									'&redirect_uri=' +  SimpplrContext.salesforceBaseUrl  + 
									Page.StorageSettings.getUrl() + '?type=box'; 
					}					

				} else if(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equalsIgnoreCase(appName) && SimpplrContext.microsoftTeamsIntegrationEnabled && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
                    redirectUrl = (new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS, null)).getAuthPage(false);
                } else {
		    		
		    		throw new SimpplrException('Unable to perform action');
		    	}			
			if(IntegrationConstants.INTEGRATION_TYPE_TWITTER.equalsIgnoreCase(appName) || String.isBlank(retURL)) {
				//No change
			} else {
				redirectUrl = redirectUrl + '%26retURL%3D' + EncodingUtil.urlEncode(EncodingUtil.urlEncode(retURL, 'UTF-8'),'UTF-8');
				
			}
			Map<String, String> responseMap = new Map<String, String>();
			responseMap.put('redirectUrl', redirectUrl);
			if(SimpplrContext.Integrations.get(appName) !=null) {
				if('dropbox'.equalsIgnoreCase(appName)) {

					responseMap.put('clientId', SimpplrContext.Integrations.get(appName).DB_User_Client_Id__c);
					responseMap.put('clientSecret', SimpplrContext.Integrations.get(appName).DB_User_Client_Secret__c);
				} else if(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appName)) { 
					
					String clientIdDecrypted = Utility.decryptFn(SimpplrContext.Integrations.get(appName).Client_Id__c);
					String clientSecretDecrypted = Utility.decryptFn(SimpplrContext.Integrations.get(appName).Client_Secret__c);
					responseMap.put('clientId', clientIdDecrypted);
					responseMap.put('clientSecret', clientSecretDecrypted);
				}else {

					responseMap.put('clientId', SimpplrContext.Integrations.get(appName).Client_Id__c);
					responseMap.put('clientSecret', SimpplrContext.Integrations.get(appName).Client_Secret__c);
				}
			}
			responseMap.put('redirectUrl', redirectUrl);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);
			responseWrapperObj.redirectUrl = redirectUrl;
		} catch(Exception ex) {
			logger.logError('PeopleDataServer.connectApp()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);
		}
		return responseWrapperObj;
	}
	
	/**
	 * @api {get} /apex/DataServerRO?target=PeopleDataServer&action=disconnectApp disconnectApp
	 * @apiVersion 1.0.0
	 * @apiGroup PeopleDataServer
	 * @apiName disconnectApp
	 *
	 * @apiParam {String} action=disconnectApp disconnectApp is the action for disconnecting the User accounts
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.GoogleDrive.disconnectApp, Simpplr.Salesforce.User.disconnectApp
	 * 2. Used in Manage Profile Settings -> External Apps
	 * 
	 * @apiSuccess {Null} Response.result Null
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */ 
	public ResponseWrapper disconnectApp(String requestData) {
		ResponseWrapper responseWrapperObj;
		try {
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('PeopleDataServer.disconnectApp()----requestMap----' + requestMap);
			String appName = requestMap.get('appName');
			
			if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(appName)) {

				GoogleDriveService gdService = new GoogleDriveService();				
				gdService.disconnectGoogleDrivePeople();

				//Batch For deleting Google Drive folders
				Database.executeBatch(new BatchDeleteFolderRecords(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING, false),200);

				//Delete People Integration Record
				List<People_Integration__c> peopleIntegrationToDelete = new List<People_Integration__c>();
				peopleIntegrationToDelete = [Select Id, name from People_Integration__c where people__c = :UserContext.peopleId AND name = :appName WITH SECURITY_ENFORCED];   	
				
				Set<String> collaborationGroupIdsSet = new Set<String>();
				for (CollaborationGroup collabObj : [SELECT Id, Name, OwnerId FROM CollaborationGroup where ownerId =: userinfo.getUserId() WITH SECURITY_ENFORCED]){
					collaborationGroupIdsSet.add(collabObj.Id);
				}

				//Changing Site Storage to Intranet
				List<Simpplr_Site__c> siteList = [Select id, File_Storage_Source__c, Chatter_Group_Id__c from Simpplr_Site__c where Chatter_Group_Id__c in:collaborationGroupIdsSet and File_Storage_Source__c = 'googledrive' and is_Deleted__c = false WITH SECURITY_ENFORCED];
				for (Simpplr_Site__c siteObj : siteList){
					siteObj.File_Storage_Source__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
				}

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
					Simpplr_Site__c.File_Storage_Source__c
				});
				
				if(!peopleIntegrationToDelete.isEmpty()){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(peopleIntegrationToDelete);
				}
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
				
			} else if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(appName)) {
				GoogleCalendarHelper gdService = new GoogleCalendarHelper();				
				gdService.disconnectGoogleCalendarPeople();

				List<People_Integration__c> peopleIntegrationToDelete = new List<People_Integration__c>();
				peopleIntegrationToDelete = [Select Id, name from People_Integration__c where people__c = :UserContext.peopleId AND name = :appName WITH SECURITY_ENFORCED];   	
		    	
		    	if(!peopleIntegrationToDelete.isEmpty()){
		    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(peopleIntegrationToDelete);
		    	}
		    	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

			} else if(IntegrationConstants.INTEGRATION_TYPE_TWITTER.equalsIgnoreCase(appName) ||
				IntegrationConstants.INTEGRATION_TYPE_FACEBOOK.equalsIgnoreCase(appName) ||
				IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appName) ||
				IntegrationConstants.INTEGRATION_TYPE_LINKEDIN.equalsIgnoreCase(appName)) {
				
				List<People_Integration__c> peopleIntegrationToDelete = new List<People_Integration__c>();
				peopleIntegrationToDelete = [Select Id, name from People_Integration__c where people__c = :UserContext.peopleId AND name = :appName WITH SECURITY_ENFORCED];   	
		    	
		    	if(!peopleIntegrationToDelete.isEmpty()){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(peopleIntegrationToDelete);			    		
		    	}
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
				
			} else if (IntegrationConstants.INTEGRATION_TYPE_BOX.equalsIgnoreCase(appName)) {
				BoxContentProvider.disconnectUser();
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);	

			} else if (ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(appName) || 
						ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(appName) ||
						ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(appName)) {
				if(SimpplrContext.integrations.containsKey(appName) && SimpplrContext.integrations.get(appName).Batch_Processing__c) {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_BATCH_PROCESSING_TRY_LATER, null);
	        	} else {
                   
		       		// Set the EFS Connected Flag to false
                    People_Integration__c pplIntegObj = new People_Integration__c(Id = UserContext.integrations.get(appName).Id);
                    pplIntegObj.Connected__c = false;
                    pplIntegObj.Is_Deleted__c = true;// Should not we remove this if we want to hard delete people integ records
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().updateAsUser(pplIntegObj, new List<Schema.SObjectField>{
                                People_Integration__c.Connected__c, People_Integration__c.Is_Deleted__c});
		        	// when user disconnects
		        	  //1. Delete groups/folders of site he is owner of
		        	  //2.Change storage to intranet for sites that he owns if storage level is site
		        	  //3. Remove user from groups for the sites he manages(not owner) or member of		        	
					Database.executeBatch(new BatchEFSFolderSync('USERDISCONNECT', UserContext.Id, appName), 1);

		            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
				}
			
			} else if(IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL.equalsIgnoreCase(appName)){
				String endPoint = 'https://services.simpplr.com/integration/slack.php';
				String driString = Utility.requestAdoptionDataAuthToken();
				String reqBody = '{"dri":"' + driString + '" , "action_name":"deleteSlackIntegration", "sfUserId":"' + UserContext.userId + '"}';
				HttpResponse res = Utility.getJsonResponseFromExternalSystem('POST', endPoint, '', reqBody);
				Map<String, Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
				if(res.getStatusCode() == 200 && String.valueOf(responseMap.get('message')) == 'Successfully deleted integration record'){
					List<People_Integration__c> peopleInteg = new List<People_Integration__c>();
					peopleInteg = [Select Id, Connected__c from People_Integration__c where people__c = :UserContext.peopleId AND Name=:integrationConstants.INTEGRATION_TYPE_SLACK_UNFURL WITH SECURITY_ENFORCED];   					
					if(!peopleInteg.isEmpty()){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(peopleInteg);
					}
				
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, res.getBody(), null);				
					
				} else {
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, res.getBody(), null);
				}
			} else if(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE.equalsIgnoreCase(appName)){
				List<People_Integration__c> peopleInteg = new List<People_Integration__c>();
				peopleInteg = [Select Id, Connected__c from People_Integration__c where people__c = :UserContext.peopleId AND Name=:integrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE AND Connected__c =true WITH SECURITY_ENFORCED];   					
				if(!peopleInteg.isEmpty()){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(peopleInteg);
					new SiteDao().disconnectSlackForSitesConnectedByLoggedInUser();
				}
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

			} else if (IntegrationConstants.INTEGRATION_TYPE_SLACK.equalsIgnoreCase(appName)) {
				SlackHelper slackHelperObj = new SlackHelper();
				HttpResponse disconnectResponse = slackHelperObj.processSlackDisconnectionAtZeus(IntegrationConstants.INTEGRATION_TYPE_SLACK, IntegrationConstants.INTEGRATION_FLOW_STANDARD, false, false);
				if(disconnectResponse.getStatusCode() == 200) {
					List<People_Integration__c> peopleInteg = new List<People_Integration__c>();
					peopleInteg = [Select Id, Connected__c from People_Integration__c where people__c = :UserContext.peopleId AND Name=:integrationConstants.INTEGRATION_TYPE_SLACK AND Connected__c =true WITH SECURITY_ENFORCED];   					
					if(!peopleInteg.isEmpty()){
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().deleteAsUser(peopleInteg);
					}
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', UserContext.peopleId);
					String query = 'SELECT Id, Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c,Last_Edited_DateTime__c FROM People__c WHERE Id =:soqlParam1 AND Is_Deleted__c = false ';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<People__c> peopleList = (List<People__c>) SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
					if(!peopleList.isEmpty()) {
						peopleList[0].Slack_User_Id__c = '';
						peopleList[0].Slack_User_Name__c = '';
						peopleList[0].Slack_Tenant_Id__c = '';
						peopleList[0].Last_Edited_DateTime__c = DateTime.now();
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(peopleList), new List<Schema.SObjectField>{
								People__c.Slack_User_Id__c,
								People__c.Slack_User_Name__c,
								People__c.Slack_Tenant_Id__c,
								People__c.Last_Edited_DateTime__c
						});
					}
					List<Simpplr_Site__c> siteList = [SELECT Id,External_Apps_Site_Config_Json__c FROM Simpplr_Site__c WHERE Slack_Site_Manager__c = :UserContext.peopleId WITH SECURITY_ENFORCED];
					for(Simpplr_Site__c siteObj : siteList) {
						siteObj.Slack_Integration_Enabled__c = false;
						siteObj.Slack_Site_Manager__c = null;
						if(siteObj.External_Apps_Site_Config_Json__c != null){
							ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
							externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
							externalAppsSiteConfig.SlackSiteConfig = null;
							siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
						}
					}
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
						Simpplr_Site__c.Slack_Integration_Enabled__c,
						Simpplr_Site__c.Slack_Site_Manager__c,
						Simpplr_Site__c.External_Apps_Site_Config_Json__c
					});
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, disconnectResponse.getBody(), null);
				} else {
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, disconnectResponse.getBody(), null);
				}
			} else if(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN.equalsIgnoreCase(appName)){
				String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/atlassian?action=disconnectuser';
				Map<String, Object> mapOfRequestParam = new Map<String, Object>();
				mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
				mapOfRequestParam.put('peopleId', UserContext.peopleId);
				HTTPResponse res = Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);

				List<People_Integration__c> peopleInteg = new List<People_Integration__c>();
				peopleInteg = [Select Id, Connected__c from People_Integration__c where people__c = :UserContext.peopleId AND Name=:integrationConstants.INTEGRATION_TYPE_ATLASSIAN AND Connected__c =true WITH SECURITY_ENFORCED];   					
				if(!peopleInteg.isEmpty()){

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().deleteAsUser(peopleInteg);	
				}
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);	
						
			} else if(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equalsIgnoreCase(appName)){
				if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2){
					MicrosoftTeamsHelper msTeamsHelperObj = new MicrosoftTeamsHelper();
					HttpResponse res = msTeamsHelperObj.processMSTeamsDisconnectAtZeus(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS, IntegrationConstants.INTEGRATION_FLOW_STANDARD);
					if(res.getStatusCode() == 200) {
						List<People__c> people = new List<People__c>();
						people = [SELECT Id, Microsoft_Teams_User_Id__c, Microsoft_Tenant_Id__c  FROM People__c WHERE Id = :UserContext.peopleId AND Is_Deleted__c = false WITH SECURITY_ENFORCED LIMIT 1];
						MicrosoftTeamsHelper.installOrUninstallMSTeamsAppForUser(people[0].Microsoft_Teams_User_Id__c, people[0].Microsoft_Tenant_Id__c, false);

						List<People_Integration__c> peopleInteg = new List<People_Integration__c>();
						peopleInteg = [Select Id, Connected__c from People_Integration__c where people__c = :UserContext.peopleId AND Name=:integrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS AND Connected__c =true WITH SECURITY_ENFORCED];   					
						if(!peopleInteg.isEmpty()){

							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
							SIMPESAPI.accessController().deleteAsUser(peopleInteg);
						}
						if(!people.isEmpty()) {
							people[0].Microsoft_Teams_User_Id__c = '';
							people[0].Microsoft_Teams_User_Name__c = '';
							people[0].Microsoft_Tenant_Id__c = '';

							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
							SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(people), new List<Schema.SObjectField>{
								People__c.Microsoft_Teams_User_Id__c,
								People__c.Microsoft_Teams_User_Name__c,
								People__c.Microsoft_Tenant_Id__c
							});
						}

						List<Simpplr_Site__c> siteList = [SELECT Id,External_Apps_Site_Config_Json__c FROM Simpplr_Site__c WHERE Microsoft_Teams_Site_Manager__c = :UserContext.peopleId WITH SECURITY_ENFORCED];
						for(Simpplr_Site__c siteObj : siteList) {
							siteObj.Microsoft_Teams_Integration_Enabled__c = false;
							siteObj.Microsoft_Teams_Site_Manager__c = null;
							if(siteObj.External_Apps_Site_Config_Json__c != null){
								ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
								externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
								externalAppsSiteConfig.MsTeamsSiteConfig = null;
								siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
							}
						}
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
							Simpplr_Site__c.Microsoft_Teams_Integration_Enabled__c,
							Simpplr_Site__c.Microsoft_Teams_Site_Manager__c,
							Simpplr_Site__c.External_Apps_Site_Config_Json__c
						});
					}
				} else {
					String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/ms-teams-oauth-manager?action=disconnectuser';
					Map<String, Object> mapOfRequestParam = new Map<String, Object>();
					mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
					mapOfRequestParam.put('peopleId', UserContext.peopleId);
					HTTPResponse res = Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);

					List<People_Integration__c> peopleInteg = new List<People_Integration__c>();
					peopleInteg = [Select Id, Connected__c from People_Integration__c where people__c = :UserContext.peopleId AND Name=:integrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS AND Connected__c =true WITH SECURITY_ENFORCED];   					
					if(!peopleInteg.isEmpty()){

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().deleteAsUser(peopleInteg);
					}
					List<People__c> people = new List<People__c>();
					people = [SELECT Id, Microsoft_Teams_User_Id__c, Microsoft_Teams_User_Name__c, Microsoft_Tenant_Id__c FROM People__c WHERE Id = :UserContext.peopleId AND Is_Deleted__c = false WITH SECURITY_ENFORCED LIMIT 1];
					if(!people.isEmpty()) {
						people[0].Microsoft_Teams_User_Id__c = '';
						people[0].Microsoft_Teams_User_Name__c = '';
						people[0].Microsoft_Tenant_Id__c = '';

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(people), new List<Schema.SObjectField>{
							People__c.Microsoft_Teams_User_Id__c,
							People__c.Microsoft_Teams_User_Name__c,
							People__c.Microsoft_Tenant_Id__c
						});
					}
				}
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);	
						
			} else if (IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(appName)) {
				OutlookCalendarHelper oLService = new OutlookCalendarHelper();				
				oLService.disconnectOutlookCalendarPeople();

				List<People_Integration__c> peopleIntegrationToDelete = new List<People_Integration__c>();
				peopleIntegrationToDelete = [SELECT Id, name, Is_Deleted__c FROM People_Integration__c 
						WHERE people__c = :UserContext.peopleId AND name = :appName AND Is_Deleted__c= false WITH SECURITY_ENFORCED];   	
		    	
		    	if (!peopleIntegrationToDelete.isEmpty()){
					peopleIntegrationToDelete[0].Is_Deleted__c = true;
					SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegrationToDelete), 
						new List<Schema.SObjectField>{
							People_Integration__c.Is_Deleted__c
						});
		    	}
				
		    	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

			} else {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}
		} catch(Exception ex) {
			logger.logError('PeopleDataServer.disconnectApp()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);
		}
		return responseWrapperObj;
	}
	
	/**
	 * @api {get} /apex/DataServerRO?target=PeopleDataServer&action=getOrgChart getOrgChart
	 * @apiVersion 1.0.0
	 * @apiGroup PeopleDataServer
	 * @apiName getOrgChart
	 *
	 * @apiParam {String} action=getOrgChart getOrgChart fetches the org chart
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.User.getOrgChart
	 * 
	 * @apiSuccess {Null} Response.result Null
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */
	private ResponseWrapper getOrgChart(String requestData) {
    	logger.logDebug('PeopleDataServer.getOrgChart()----requestData----'+requestData);
        ResponseWrapper localResult = new ResponseWrapper();
        try {
        	Map<String,Object> paramData = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	
        	String peopleId = paramData.get('peopleId')==null ? '':String.valueOf(paramData.get('peopleId'));
        	Boolean includeChildren = paramData.get('includeChildren')==null ? false :Boolean.valueOf(paramData.get('includeChildren'));
        	Boolean includeParent = paramData.get('includeParent')==null ? false :Boolean.valueOf(paramData.get('includeParent'));
        	Boolean includeGrandparent = paramData.get('includeGrandparent')==null ? false :Boolean.valueOf(paramData.get('includeGrandparent'));
        	String size = paramData.get('size')==null ? '':String.valueOf(paramData.get('size'));
        	String nextPageToken = paramData.get('nextPageToken')==null ? '':String.valueOf(paramData.get('nextPageToken'));
        	if (String.isNotBlank(peopleId)) {
		        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, PeopleContentProvider.getOrgChartDetail(peopleId, includeChildren, includeParent, includeGrandparent, size, nextPageToken));
        	}
        } catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not get org charts',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('PeopleDataServer.getOrgChart()----localResult----'+localResult);
        return localResult;
    }
	private ResponseWrapper getOrgChartOnProfile(String requestData) {
    	logger.logDebug('PeopleDataServer.getOrgChartOnProfile()----requestData----'+requestData);
        ResponseWrapper localResult = new ResponseWrapper();
        try {
        	Map<String,Object> paramData = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	
        	String peopleId = paramData.get('peopleId')==null ? '':String.valueOf(paramData.get('peopleId'));
        	String size = paramData.get('size')==null ? '':String.valueOf(paramData.get('size'));
        	String nextPageToken = paramData.get('nextPageToken')==null ? '':String.valueOf(paramData.get('nextPageToken'));
        	if (String.isNotBlank(peopleId)) {
		        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, PeopleContentProvider.getOrgChartDetailForProfile(peopleId, size, nextPageToken));
        	}
        } catch(Exception e) {
        	logger.logError('PeopleDataServer----Could not get org charts',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('PeopleDataServer.getOrgChartOnProfile()----localResult----'+localResult);
        return localResult;
    }

	/**
	 * @api {get} /apex/DataServerRO?target=PeopleDataServer&action=getUser getUser
	 * @apiVersion 1.0.0
	 * @apiGroup PeopleDataServer
	 * @apiName getUser
	 *
	 * @apiParam {String} action=getUser getUser fetches the full user modal(PeopleWrapper)
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.User.getUser
	 * 
	 * @apiSuccess {Null} Response.result Null
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */ 
	public ResponseWrapper getUser(String requestData) {
		ResponseWrapper responseWrapperObj;
		try {
			Map<String, String> requestMap = new Map<String, String>();
			if(String.isNotBlank(requestData)) {
				requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			}
			logger.logDebug('PeopleDataServer.getUser()----requestMap----' + requestMap);
			String peopleId = requestMap.get('peopleId');
			String sfUserId = requestMap.get('sfUserId');
			Boolean includeCustomFields = 'true'.equalsIgnoreCase(requestMap.get('includeCustomFields')) ? true : false;
			Boolean includeHiddenProfileFields = 'true'.equalsIgnoreCase(requestMap.get('includeHiddenProfileFields')) ? true : false;
		
			String peopleOrSFUserId = '';
			if(String.isNotBlank(sfUserId)){
				peopleOrSFUserId = sfUserId;

			}else if(String.isNotBlank(peopleId)) {
				peopleOrSFUserId = peopleId;

			} else if(String.isNotBlank(readParam('peopleId'))) {
				peopleOrSFUserId = readParam('peopleId');
			
			} else if(String.isNotBlank(readParam('sfUserId'))) {
				peopleOrSFUserId = readParam('sfUserId');

			} else {
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			}
			
			PeopleWrapper pwObj = new PeopleWrapper();
   			pwObj = new PeopleContentProvider().getUser(peopleOrSFUserId, includeCustomFields,includeHiddenProfileFields);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, pwObj);
		} catch(Exception ex) {
			logger.logError('PeopleDataServer.getUser()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);
		}
		return responseWrapperObj;
	}
	
	/**
	 * @api {get} /apex/DataServerRO?target=PeopleDataServer&action=getFollowStats getFollowStats
	 * @apiVersion 1.0.0
	 * @apiGroup PeopleDataServer
	 * @apiName getFollowStats
	 *
	 * @apiParam {String} action=getFollowStats getFollowStats is the action for getting the count of 1. followers  2. people following  3. sites following (for a user)
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.GoogleDrive.getFollowStats, Simpplr.Salesforce.User.getFollowStats
	 * 2. Used in Manage Profile Settings -> External Apps
	 * 
	 * @apiSuccess {Null} Response.result Null
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */ 
	public ResponseWrapper getFollowStats(String requestData) {
		ResponseWrapper responseWrapperObj;
		try {
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('PeopleDataServer.getFollowStats()----requestMap----' + requestMap);
			String peopleId = requestMap.get('peopleId');
			
			if(String.isBlank(peopleId)) {
				throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
			} else {
				PeopleWrapper.FollowStats followStatsWrapper = new PeopleWrapper.FollowStats();
   				followStatsWrapper = PeopleContentProvider.getFollowStats(peopleId);
				
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, followStatsWrapper);
			}
				
		} catch(Exception ex) {
			logger.logError('PeopleDataServer.getFollowStats()---Exception occured----', ex);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);
		}
		return responseWrapperObj;
	}
	
	private ResponseWrapper setCoverImage(String peopleId, String fileJsonData) {
    	ResponseWrapper responseWrapperObj = null;
        try{
        	FileContentWrapper fileObj = String.isNotBlank(fileJsonData) ? (FileContentWrapper) Json.deserialize(fileJsonData, FileContentWrapper.class) : null;
	    	if(String.isNotBlank(peopleId)){
	    		PeopleContentProvider.setCoverImage(peopleId, fileObj!=null ? fileObj.contentDocumentId : null, fileObj!=null ? fileObj.contentVersionId : null);
	    	} 
	    	
	    	if(fileObj!=null){
	    		ContentDocumentLink cdLink = new ContentDocumentLink();
		    	cdLink.ShareType = 'V';
				cdLink.LinkedEntityId = UserInfo.getOrganizationId();
				cdLink.ContentDocumentId = fileObj.contentDocumentId; 
			    insert cdLink;
	    	}
	    	
	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        	logger.logError('PeopleDataServer.setCoverImage()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        return responseWrapperObj;
	}
	
	private ResponseWrapper getGoogleCalendars() {
		ResponseWrapper responseWrapperObj = null;
		try {
			GoogleCalendarHelper helperObj = new GoogleCalendarHelper();
			List<FilterAttributeWrapper> calendarList = helperObj.getGoogleCalendars();
			Map<String, Object> respultObj = new Map<String, Object>();
			respultObj.put('listOfItems', calendarList);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, respultObj);
		}catch(Exception e){
        	logger.logError('PeopleDataServer.getGoogleCalendars()----Exception Occured', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
	}
	private ResponseWrapper saveAppToken(String requestData) {
		ResponseWrapper responseWrapperObj = null;
		try {
			Map<String, Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
			String appName = String.valueOf(requestMap.get('appName'));
			if('twitter'.equalsIgnoreCase(appName)) {
				TwitterService.TwitterAccessTokenResponse twitterAccessResponse = new TwitterService.TwitterAccessTokenResponse();
				TwitterService twtService = new TwitterService();
				twitterAccessResponse.oauth_token = String.valueOf(requestMap.get('oauth_token'));
				twitterAccessResponse.oauth_token_secret = String.valueOf(requestMap.get('oauth_token_secret'));
				twitterAccessResponse.screen_name = String.valueOf(requestMap.get('screen_name')); 
				twitterAccessResponse.user_id = String.valueOf(requestMap.get('user_id'));
				twitterAccessResponse.x_auth_expires = String.valueOf(requestMap.get('x_auth_expires'));
				twtService.saveAccessTokenToDB(twitterAccessResponse);

			} else if('linkedin'.equalsIgnoreCase(appName)) {
				String accessToken = String.valueOf(requestMap.get('access_token'));
				Decimal expiresIn = Integer.valueOf(requestMap.get('expires_in'));
				PeopleDao daoObj = new PeopleDao();
				daoObj.saveLinkedInTokenToDB(accessToken, expiresIn);
			} else {
				throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		}catch(Exception e){
        	logger.logError('PeopleDataServer.saveAppToken()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
	}
	
	private ResponseWrapper saveWebPushPromptFlag(String requestData) {
		ResponseWrapper responseWrapperObj = null;
		try {
			Boolean webPushPromptFlag =  Boolean.valueOf(readParam('webPushPromptFlag'));
			if(webPushPromptFlag != null) {
				PeopleDao peopleDaoObj = new PeopleDao();
				peopleDaoObj.saveWebPushPromptFlag(webPushPromptFlag);
			} else {
				throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		}catch(Exception e){
			logger.logError('PeopleDataServer.saveWebPushPromptFlag()----Exception Occured',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}
    
    private void indexDataInElastic(String body) {
        String externalEndPoint = SearchConstants.APIS_UPSERT;
        String awsAccessToken = SimpplrContext.getAWSAccessToken.substring(19); 

        String reqBodyStr = '{"data":' + body + ', "base_url":"' + 
                SimpplrContext.getExternalSearchBaseUrl + '",'+ 
                ' "org_id":"' + SimpplrContext.simpplrOrgId + '", '+ 
                ' "request_path":"upsert_expertise", "instance_url":"' + 
                SimpplrContext.salesforceHost + '"}';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(externalEndPoint); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setBody(reqBodyStr);
        Http http = new Http();
        HttpResponse res; 
        res = http.send(req);
    }

	/**
     * @description method to separate drive and calendar users
     * and call disconnect method
    */
    private ResponseWrapper updateIntegrationInfo(String requestData ) {
        ResponseWrapper responseWrapObj = null;
        try{
            logger.logDebug('PeopleDataServer.updateIntegrationInfo() '+requestData);
            Set<Id> disconnectDriveSet = new Set<Id>();
            Set<Id> disconnectCalendarSet = new Set<Id>();
            List<ConnectedUsersWrapper> dataList = (List<ConnectedUsersWrapper>)JSON.deserialize(requestData, List<ConnectedUsersWrapper>.class);
            for(ConnectedUsersWrapper data : dataList){
                if(DATA_TYPE_VALUE_DRIVE.equalsIgnoreCase(data.type)){
                    disconnectDriveSet.add(data.peopleId);
                }
                else{
                    disconnectCalendarSet.add(data.peopleId);
                }
            }
            if(disconnectDriveSet.size()>0){
                disconnectUsers(disconnectDriveSet,IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE,DATA_TYPE_VALUE_GDRIVE);
            }
            if(disconnectCalendarSet.size()>0){
                disconnectUsers(disconnectCalendarSet,IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR,DATA_TYPE_VALUE_GCALENDAR);
            }
            responseWrapObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }
        catch(Exception ex){
            logger.logError('PeopleDataServer.updateIntegrationInfo()---Exception occured----', ex);
			responseWrapObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapObj;
    }

    /**
	 * @description Makes callout to AWS to update Refresh token 
     * for google calendar and drive integration
	*/
    public static void refreshUserGoogleToken(){
        Map<String, Object> requestBody = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=refreshtokensbulk';
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		Utility.getResponseFromAWS(externalEndPoint, requestBody);
    }

    /**
	 * @description disconnect users and send mail
	*/
    private Boolean disconnectUsers(Set<Id> peopleIdSet,String type,String name){
        Boolean success = true;
        try{
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', type);
            soqlParamMap.put('soqlParam2', peopleIdSet);
            String queryStr =   'SELECT Id FROM People_Integration__c WHERE name=: soqlParam1 '+
                                ' AND is_Deleted__c=false AND connected__c=true '+
                                ' AND People__c in: soqlParam2 ';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<People_Integration__c> peopleIntegrationList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
            if(!peopleIntegrationList.isEmpty()) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(peopleIntegrationList);
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIdSet,name);
            }
        }
        catch(Exception ex){
            logger.logError('PeopleDataServer.updateIntegrationInfo()---Exception occured----', ex);
            success = false;
        }
        return success;
    }

    /**
	 * @description response wrapper class
	*/
    private class ConnectedUsersWrapper{
        String peopleId;
		String type;
    }
}