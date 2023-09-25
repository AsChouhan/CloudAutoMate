/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PageDao extends DAO{

	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
	
	private final String contentType = ServiceConstants.TYPE_PAGE;
	private Set<String> setOfSearchTerms;
	private Set<Id> contentIdsForFollowingTopics;
	private List<String> existingImpPageIds;
	
    private Id loggedInPeopleId{get{
    	return UserContext.getCurrentUserInfo.Id;
    }}
	private Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
	private DateTime currentDateTime = DateTime.now();
	
	public List<String> getContentFieldList() {
		String mustReadSubCondition = UserContext.isUserAppModerator ? '' : ' And (Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet) ';
    	List<String> fieldList = new List<String>{
    		'Id',
			'First_Publish_DateTime__c',
            'Type__c',
			'Content_Sub_Type__c',
            'Activated_By_Feature__c',
            'site__c',
            'Primary_Author__c',
            'Title__c',
            'Text_Intro__c',
            'Display_Excerpt__c',
            'Summary_1__c',
            'Use_Maximum_Screenwidth__c',
            'Is_Published__c',
            'Is_Unpublished__c',
            'Is_Must_Read__c',
            'Is_Deleted__c',
            'Allow_comments__c',
            'Likes__c',
            'Feed_Posts__c',
            'createdDate',
            'Publish_Start_DateTime__c', 
            'Publish_End_DateTime__c', 
			'Last_Validated_DateTime__c',
            'lastModifiedDate',
            'Event_Start_DateTime__c',
			'Event_End_DateTime__c',
			'Event_TimezoneSidKey__c',
			'Event_Is_All_Day__c',
			'Status__c',
			'Last_Edited_DateTime__c',
			'Album_Image_Count__c',
            'Album_Video_Count__c',
			'Event_Attending_Count__c',
			'Event_Location__c',
			'Title_Image_Caption__c',
			'Cover_Image_Layout__c',
			'Event_RSVP_Allowed__c',
			'Event_RSVP_Show_Maybe__c',
			'Event_RSVP_Note__c',
			'Event_RSVP_Limit__c',
			'Event_RSVP_By_DateTime__c',
			'Event_Map_URL__c',
			'Event_Directions_Enabled__c',
			'Event_Directions__c',
			'Pages_Category__c',
			'Content_Onboarding_Status__c',
			'Onboarding_Added_Date__c',
			'Created_DateTime__c',
			'CreatedBy_People__c',
			'Last_UpdatedBy_People__c',
			'Last_Updated_DateTime__c',
			'Pages_Category__r.Name__c',
			'Primary_Author__r.user__r.Id',
			'Primary_Author__r.First_Name__c', 
			'Primary_Author__r.Community_Nickname__c',
            'Primary_Author__r.Last_Name__c',
            'Primary_Author__r.Full_Name__c',
            'Primary_Author__r.user__r.SmallPhotoURL',
            'Primary_Author__r.user__r.FullPhotoURL',
			'Primary_Author__r.Department__c',
			'Primary_Author__r.About__c',
			'Primary_Author__r.Title__c',
			'Primary_Author__r.City__c',
			'Primary_Author__r.State__c',
			'Primary_Author__r.Country__c',
			'Primary_Author__r.Email__c',
			'Primary_Author__r.Phone__c',
			'Primary_Author__r.mobile_phone__c',
			'Primary_Author__r.extension__c',
			'Primary_Author__r.Birth_Date__c',
			'Primary_Author__r.Joining_Date__c',
			'Primary_Author__r.User__c',
			'Primary_Author__r.User__r.isactive',
            'Site__r.name',
            'Site__r.Is_Active__c',
            'Site__r.Chatter_Group_Id__c',
            'Site__r.Site_Type__c',
            'Site__r.Landing_Page__c',
            'Site__r.Title_Content_Version__c',
			'Site__r.Title_Content_Document__c',
			'Site__r.Is_Onboarding_Enabled__c',
			'Site__r.Is_Must_Read_Enabled__c',
			'Site__r.Is_Featured__c',
			'Site__r.Has_Campaigns__c',
			'(select  Audience_Type__c, Removed_By_People__c, Must_Read_Confirm_Count__c, Expiry_DateTime__c, Removed_DateTime__c  from Must_Read_Audits__r where Removed_DateTime__c = null  ' +  mustReadSubCondition + ' order by createddate desc limit 1)',
            '(Select Id,Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId and Must_Read_Audit__r.Removed_DateTime__c=null  AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) )',
            '(select id from Bookmarked_Content__r where People__c =:loggedInPeopleId and Is_Deleted__c=false)',
			'(Select Id FROM Content_Notification_Setting__r where People__c =:loggedInPeopleId)',
			'(select id from Likes_Simpplr_Content__r where People__c =: loggedInPeopleId and Is_Deleted__c=false)',
            '(Select Id, Was_Content_Useful__c from Simpplr_Content_Feedback__r where submitter__c =:loggedInPeopleId and Is_Deleted__c=false)',
            '(Select Id,Rsvp_Response__c,People__c,RSVP_Response_Text__c from Event_RSVP_Responses__r where is_deleted__c = false And People__c=:loggedInPeopleId)',
            '(select id, Site__c from Simpplr_Carousel_Contents__r where Is_Deleted__c = false)',
            '(SELECT Id,Content_Version__c, Content_Document__c, Title_Image_Type__c,Is_Title_Image__c,Size__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false and Is_Title_Image__c = true)' 

        };

		if(SimpplrContext.isContentGovernanceEnabled){
			fieldList.add('(select LastModifiedDate from Content_Audit_Trails__r where Dismiss_By__c !=null order by LastModifiedDate Limit 1)');
		}

		return fieldList;
    }
    
	private final String BASE_QUERY = 'SELECT '+String.join(getContentFieldList(),',')+
                	' FROM Simpplr_Content__c ' +
		            ' WHERE Status__c =\'Approved\' AND Type__c =:contentType '+
		            ' AND Is_Published__c = true '+
		            ' AND Is_Deleted__c = false '+
		            ' And Site__r.Has_Pages__c = true '+
		            ' And Site__r.Is_Active__c = true ' + 
		            ' And Site__r.Show_In_Simpplr__c = true ';
	
	
	/**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Simpplr_Content__c> getContentListFromCriteria(String siteId,String searchText,String status,String orderByField,String order,Integer recordLimit,Integer offsetVal,Set<Id> allSitesIdsICanManageContents,Boolean isAppModerator, String filter, String category, String peopleId, String contentSubType, String contribution){
        String currentUserId = UserContext.id;
        String thumbnail = 'thumbnail';
        String type = ServiceConstants.TYPE_PAGE;
        Boolean isPublished = false;
        Id currentPeopleRecordId = UserContext.getCurrentUserInfo.Id;
		Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
		Set<String> contentIdSet = new Set<String>();
		String loggedInUserId = UserContext.getCurrentUserInfo.Id;
		
		Datetime expiryStartDateTime = null;
		Datetime expiry28DaysStartDateTime = null;
		Datetime expiry14DaysStartDateTime = null;

		Datetime expiry28DaysEndDate = null;
		Datetime expiry14DaysEndDate = null;
		
        String conditionString = '';
        conditionString += ' Type__c =:type AND Type__c IN : allowedFeaturesInAppList';
        conditionString += ' AND Is_Deleted__c = false ';
        conditionString += ' AND Site__c != null';
        conditionString += ' And Site__r.Is_Active__c = true';
        conditionString += ' And Site__r.Show_In_Simpplr__c = true';
        conditionString += ' AND Site__r.Has_Pages__c = true ';
        if (String.isNotBlank(peopleId)){
        	conditionString += ' AND Primary_Author__c =: peopleId';
        }
        
        if('owned'.equalsIgnoreCase(filter)) {
        	 conditionString += ' AND Primary_Author__c =: currentPeopleRecordId';
        } else if('favorites'.equalsIgnoreCase(filter)) {
        	conditionString += ' AND Is_Published__c = true And Id in (Select Simpplr_Content__c from Bookmark__c where ' +
							   ' Type__c =:type And People__c =:currentPeopleRecordId  AND Is_Deleted__c = false ) ';
        } else if('must_read'.equalsIgnoreCase(filter)) {
        	conditionString += ' AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) AND  ( Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet)) ';
		}
		
		if('contributedByMe'.equalsIgnoreCase(contribution)) {
			conditionString += ' AND id IN (Select Content__c from Content_Audit_Trail__c where Action_By__c =: loggedInPeopleId) ';
		}
        
	    if(String.isNotBlank(category) && !'all'.equalsIgnoreCase(category)) {
	    	conditionString += ' AND Pages_Category__c =: category ';
	    }
        if(!isAppModerator && !'favorites'.equalsIgnoreCase(filter)){
            if(allSitesIdsICanManageContents != null && allSitesIdsICanManageContents.size() > 0){
                conditionString += ' AND (site__c IN :allSitesIdsICanManageContents OR Primary_Author__c =: currentPeopleRecordId)';
            }else{
                conditionString += ' AND Primary_Author__c =: currentPeopleRecordId';
            }
        }
        if(String.isNotBlank(status) && !status.equalsIgnoreCase('all') ){
            if(ServiceConstants.CONTENT_STATUS_PENDING.equalsIgnoreCase(status)){
                status = ServiceConstants.CONTENT_STATUS_SUBMITTED;
                conditionString+=' AND Status__c =:status';
            } else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(status) ){
                status = ServiceConstants.CONTENT_STATUS_REJECTED;
                conditionString+=' AND Status__c =:status';
            } else if (ServiceConstants.CONTENT_STATUS_PUBLISH.equalsIgnoreCase(status) ){
                conditionString+=' AND Is_Published__c = true';
            } else if (ServiceConstants.CONTENT_STATUS_UNPUBLISH.equalsIgnoreCase(status)){
                conditionString+=' AND Is_Unpublished__c = true';
            } else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(status) ){
                status = ServiceConstants.CONTENT_STATUS_DRAFT;
                conditionString+=' AND Status__c =:status ';
            } else if (ServiceConstants.CONTENT_VALIDATION_EXPIRED.equalsIgnoreCase(status)){
					ManageContentDao daoObj = new ManageContentDao();
					contentIdSet = daoObj.getValidationExpiredLast14DaysContentIdSet();

					conditionString += ' AND id IN :contentIdSet ';

			} else if (ServiceConstants.CONTENT_VALIDATION_REQUIRED.equalsIgnoreCase(status)){
				Datetime currentTime = Datetime.now();
	
				expiryStartDateTime = currentTime.addMonths(- (SimpplrContext.validationPeriodMonth));
				expiry28DaysStartDateTime = expiryStartDateTime.addDays(28);
				expiry14DaysStartDateTime = expiryStartDateTime.addDays(14);

				expiry28DaysEndDate = currentTime.addDays(28);
				expiry14DaysEndDate = currentTime.addDays(14);

				conditionString += ' AND Id not in (SELECT content__c from Content_Audit_Trail__c ' +
												'WHERE Action__c=\'Validation Require Dismissed\' ' +
												'AND Action_DateTime__c=LAST_N_DAYS: 14) ';
				if(UserContext.isUserAppModerator){
					conditionString += ' AND type__c = \'Page\' AND Content_Sub_Type__c = \'knowledge\' AND '
								+ ' Is_Published__c = true AND Is_Deleted__c = false AND '
								+'	( '
								+'		( '
								+'			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry28DaysEndDate) AND  '
								+'			Primary_Author__c = :loggedInUserId AND (Site__c IN :allSitesIdsICanManageContents OR Site__r.Site_Type__c = \'Public\') AND '
								+'			(  '
								+'				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry28DaysStartDateTime) '
								+'				OR  '
								+'				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry28DaysStartDateTime)  '
								+'	    	) '
								+'		) '
								+'		OR '
								+'		( '
								+'			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry14DaysEndDate) AND  '
								+'			Primary_Author__c != :loggedInUserId AND (Site__c IN :allSitesIdsICanManageContents OR Site__r.Site_Type__c = \'Public\') AND '
								+'			(  '
								+'				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry14DaysStartDateTime) '
								+'				OR  '
								+'				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry14DaysStartDateTime)  '
								+'	    	) '
								+'		) '
								+'	) ';
				} else {
					conditionString += ' AND type__c = \'Page\' AND Content_Sub_Type__c = \'knowledge\' AND '
								+ ' Is_Published__c = true AND Is_Deleted__c = false AND '
								+'  	( '
								+'  		( '
								+'  			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry28DaysEndDate) AND  '
								+'  			Primary_Author__c = :loggedInUserId AND (Site__c IN :allSitesIdsICanManageContents) AND '
								+'  			(  '
								+'  				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry28DaysStartDateTime) '
								+'  				OR  '
								+'  				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry28DaysStartDateTime)  '
								+'  	    	) '
								+'  		) '
								+'  		OR '
								+'  		( '
								+'  			(Publish_End_DateTime__c = null OR Publish_End_DateTime__c >= :expiry14DaysEndDate) AND  '
								+'  			Primary_Author__c != :loggedInUserId AND (Site__c IN :allSitesIdsICanManageContents) AND '
								+'  			(  '
								+'  				(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <= :expiry14DaysStartDateTime) '
								+'  				OR  '
								+'  				(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <= :expiry14DaysStartDateTime)  '
								+'  	    	) '
								+'  		) '
								+'  	)';
				}					

			} else if (ServiceConstants.CONTENT_STATUS_ORG_OR_SITE_ONBOARDING.equalsIgnoreCase(status) ){
				conditionString+=' AND (Content_Onboarding_Status__c = \'orgOnboarding\' OR Content_Onboarding_Status__c = \'siteOnboarding\') ';
			} else if (ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(status) ){
				conditionString+=' AND Content_Onboarding_Status__c =\'orgOnboarding\' ';
			} else if (ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(status) ){
				conditionString+=' AND Content_Onboarding_Status__c =\'siteOnboarding\' ';
			}

        } else if (String.isNotBlank(status) && status.equalsIgnoreCase('all')){
        	String draftStatus = ServiceConstants.CONTENT_STATUS_DRAFT;
        	conditionString+=' AND (Status__c !=: draftStatus OR (Status__c =: draftStatus AND Primary_Author__c =: currentPeopleRecordId))';
        } 
        if(String.isNotBlank(searchText)) {
        		setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
            conditionString += getSearchTermCondition(setOfSearchTerms);
        }
        if(String.isNotBlank(siteId)){
            conditionString+=' AND Site__c = :siteId';
        }
        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        if(isAppModerator && !'favorites'.equalsIgnoreCase(filter) && !UserContext.hasModifyAllDataPermission){
    		conditionString+=' AND ((Site__r.Chatter_Group_Id__c =:chatterGroupsIFollowIdSet And Primary_Author__c =: currentPeopleRecordId) OR Site__r.Site_Type__c =\'Public\' OR Type__c=\'BlogPost\' OR site__c IN :allSitesIdsICanManageContents)';
    	}

		if(String.isNotBlank(contentSubType)){
			conditionString += ' AND Content_Sub_Type__c = :contentSubType ';
		}

        conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
        String subConditionString = '';
        if(String.isBlank(order)){
            order = 'DESC';
        }
        if(String.isNotBlank(orderByField)){
            subConditionString+=' ORDER BY '+orderByField+' '+order;
        }
        if(recordLimit != null && recordLimit > 0){
            subConditionString+=' LIMIT :recordLimit';
        }
        if(offsetVal != null && offsetVal > 0){
            subConditionString+=' OFFSET :offsetVal';
        }

        String query = 'SELECT ' + String.join(getContentFieldList(), ',') + ' FROM Simpplr_Content__c' + conditionString + subConditionString;
        
        return Database.query(query); 
    }
    
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
   public override Map<Id,Simpplr_Content__c> getContentsMapFromIds(List<Id> listOfContentIds,String siteId) {
        return new Map<Id, Simpplr_Content__c>([SELECT Is_Deleted__c,LastModifiedDate,Display_Excerpt__c,Summary_1__c,
                                                Type__c, Title__c, Text_Main__c, Text_Main_Continued__c, Text_Intro__c, Status__c, Shares__c, 
                                                Title_Image_Caption__c,Publish_Start_DateTime__c,Publish_End_DateTime__c,
                                                Likes__c, site__c,site__r.chatter_group_id__c,site__r.name,
                                                site__r.Site_Type__c, Primary_Author__c,Primary_Author__r.Full_Name__c, 
                                                Is_Published__c, Is_Unpublished__c, Use_Maximum_Screenwidth__c,Is_Must_Read__c,
                                                Primary_Author__r.User__r.SmallPhotoUrl,Primary_Author__r.User__r.FullPhotoUrl,Primary_Author__r.Street__c,Primary_Author__r.City__c,
                                                Primary_Author__r.State__c,Primary_Author__r.Country__c,Primary_Author__r.Postal_Code__c,Primary_Author__r.Title__c,
                                                Primary_Author__r.Department__c, Id, Allow_comments__c, CreatedDate,CreatedBy.name, Created_DateTime__c, CreatedBy_People__c, Last_UpdatedBy_People__c, Last_Updated_DateTime__c,
                                                CreatedById,Allow_Follow__c,Pages_Category__r.Id, Pages_Category__r.Name__c,Cover_Image_Layout__c,
                                                Last_Edited_DateTime__c, Excerpt__c
                                                FROM Simpplr_Content__c
                                                WHERE Id IN: listOfContentIds 
                                                AND site__c = :siteId
                                                And site__r.IsDeleted = false 
                                                And site__r.is_Active__c = true And Site__r.Show_In_Simpplr__c = true 
                                                And site__r.Has_Pages__c = true
                                                And Is_Deleted__c = false
                                                AND Type__c =: ServiceConstants.TYPE_PAGE]);
    }

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<String,Integer> getContentGroupByCategory(){
        Map<String,Integer> result = new Map<String,Integer>();
        List<AggregateResult> resultList = [select count(Id) pageCount,Pages_Category__c categoryId FROM Simpplr_Content__c Where Is_Deleted__c = false WITH SECURITY_ENFORCED Group By Pages_Category__c];
        if(resultList != null && resultList.size() > 0){
            for(AggregateResult record : resultList){
                result.put(String.valueOf(record.get('categoryId')),Integer.valueOf(record.get('pageCount')));
            }
        }
        return result;
    }
    
    public Map<String,Integer> getPublishedContentGroupByCategory(){
        Map<String,Integer> result = new Map<String,Integer>();
        List<AggregateResult> resultList = [select count(Id) pageCount,Pages_Category__c categoryId FROM Simpplr_Content__c where Status__c =: ServiceConstants.CONTENT_STATUS_APPROVED WITH SECURITY_ENFORCED Group By Pages_Category__c];
        if(resultList != null && resultList.size() > 0){
            for(AggregateResult record : resultList){
                result.put(String.valueOf(record.get('categoryId')),Integer.valueOf(record.get('pageCount')));
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
	public List<Simpplr_Content__c> getPagesSearchResults (Criteria.Pages pagesCriteriaObjArg) {
		if(pagesCriteriaObjArg.category == null){
			if(!'importantPageList'.equalsIgnoreCase(pagesCriteriaObjArg.filter)){
				pagesCriteriaObjArg.category = 'all';
			} 
			if(pagesCriteriaObjArg.size == null){
				pagesCriteriaObjArg.size = 100;
			}
		}
		String loggedInUserPeopleId = UserContext.peopleId;
		String siteId = pagesCriteriaObjArg.siteId;
		String categoryId = pagesCriteriaObjArg.category;
		String filter = pagesCriteriaObjArg.filter;
		Integer recordLimit = pagesCriteriaObjArg.size + 1;
		Integer offset = pagesCriteriaObjArg.offset;
		String topicId = pagesCriteriaObjArg.topicId;
		DateTime publishStartDateTime = Utility.getDateTimeFilterValue(pagesCriteriaObjArg.publishStartDate);
        String author = pagesCriteriaObjArg.authoredBy;
        String contentSubType = pagesCriteriaObjArg.contentSubType;
        String publishStartDateSpan = pagesCriteriaObjArg.publishStartDateSpan;
		Set<String> contentIdSet = new Set<String>();
		if(pagesCriteriaObjArg.contentIdSet!=null && pagesCriteriaObjArg.contentIdSet.size()>0){
			contentIdSet.addAll(pagesCriteriaObjArg.contentIdSet);
		}
		
		String sortBy = pagesCriteriaObjArg.sortBy;
		if(String.isBlank(sortBy) && String.isNotBlank(categoryId) && !'all'.equalsIgnoreCase(categoryId)){
			sortBy = 'DisplayOrder';
		}
		
		Set<Id> listOfSelectedTopics;
		if(null != pagesCriteriaObjArg.topics && pagesCriteriaObjArg.topics.size() > 0){
			listOfSelectedTopics = new Set<Id>(pagesCriteriaObjArg.topics);
		}

        if (!String.isBlank(publishStartDateSpan)) {
            
            if (publishStartDateSpan.equalsIgnoreCase('past_24_hours')) {
                publishStartDateTime = System.now().addHours(-24);

            } else if (publishStartDateSpan.equalsIgnoreCase('past_week')) {
                publishStartDateTime = System.now().addDays(-7);

            } else if (publishStartDateSpan.equalsIgnoreCase('past_month')) {
                publishStartDateTime = System.now().addMonths(-1);

            } else if (publishStartDateSpan.equalsIgnoreCase('past_year')) {
                publishStartDateTime = System.now().addYears(-1);
            }

        }
        
		Set<String> setOfSearchTerms = String.isNotBlank(pagesCriteriaObjArg.term) ? Utility.getSearchTokens(String.escapeSingleQuotes(pagesCriteriaObjArg.term)) : null;
		
		Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet; // for following filter
		Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
		
		String queryStr = BASE_QUERY;
		queryStr += getSearchTermCondition(setOfSearchTerms);
		queryStr += getIdFilterCondition(contentIdSet);
		queryStr += getFilterCondition(filter, siteId);
		queryStr += getTopicCondition(topicId);
		queryStr += getPublishStartDateCondition(publishStartDateTime);
		queryStr += getAuthorCondition(author);
        queryStr += getSiteCondition(siteId);
        queryStr += getContentSubTypeCondition(contentSubType);
		queryStr += getCategoryCondition(categoryId);
		queryStr += getPopularTopicsCondition(listOfSelectedTopics);
		queryStr += getSortOrderCondition(sortBy);
		queryStr += getLimitOffsetCondition(recordLimit, offset); 

		logger.logDebug('PageDao.getPagesSearchResults()----queryStr----' + queryStr);
		List<Simpplr_Content__c> queryResult = Database.query(queryStr);
		
		if(null != listOfSelectedTopics && listOfSelectedTopics.size() > 1){
			queryResult = populateData(queryResult,listOfSelectedTopics);
		}
		return queryResult;
	}
	
	public Pages_Category__c createPagesCategory(String categoryName, String siteId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', categoryName);
		String pageCtgryQuery = 'Select Id FROM Pages_Category__c WHERE site__c =:soqlParam1 AND Name__c =:soqlParam2 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Pages_Category__c> pagesCategoryList = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
        if(pagesCategoryList.isEmpty()) {
	        Pages_Category__c record = New Pages_Category__c();
	        record.Name__c = categoryName;
	        record.site__c = siteId;
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(New List<Pages_Category__c>{record},new List<Schema.SObjectField>{Pages_Category__c.site__c,Pages_Category__c.Name__c});
	        pagesCategoryList = result.getInsertedObjects();
		}
		return pagesCategoryList[0];
	}
	/**
     *page
     **/
	private String getSearchTermCondition(Set<String> setOfSearchTerms){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms){
				queryStr += ' And Title__c like \'%'+searchToken+'%\' ';
			}
        }
        return queryStr;
	}
	
	private String getIdFilterCondition(Set<String> contentIdSet){
		String queryStr = '';
		if(contentIdSet.size()>0){
			queryStr = ' AND Id IN :contentIdSet';
		}
		return queryStr;
	}

	private String getPublishStartDateCondition(DateTime publishStartDateTime){
		String queryStr = '';
		if(publishStartDateTime != null){
			queryStr = ' And Publish_Start_DateTime__c >=: publishStartDateTime  ';
		}
		return queryStr;
	}
	private String getAuthorCondition(String author) {
		String queryStr = '';
		if(String.isNotBlank(author)) {
			queryStr = ' And primary_author__c =:author ';
		}
		return queryStr;
	}
	
	/**
     *page
     **/
	private String getFilterCondition(String filter, String siteId){
		String queryStr = '';
		if(String.isNotBlank(filter)){
			if(FILTER_BOOKMARKED.equalsIgnoreCase(filter)){
				queryStr += ' And Id in (Select Simpplr_Content__c from Bookmark__c where ' +
							   ' Type__c =: contentType And People__c =:loggedInUserPeopleId AND Is_Deleted__c = false ) ';
			}else if(FILTER_FOLLOWING.equalsIgnoreCase(filter)){
				contentIdsForFollowingTopics = getContentIdSetForFollowedTopics(ServiceConstants.TYPE_PAGE);
				queryStr += ' And (Site__r.Chatter_Group_Id__c =:chatterGroupsIFollowIdSet ' + 
									' OR Primary_Author__c =:loggedInUserPeopleId' + 
									' OR Id IN :contentIdsForFollowingTopics)';
			}else if('ImportantPages'.equalsIgnoreCase(filter)){
				queryStr += ' And (Site__r.Chatter_Group_Id__c =:chatterGroupsIFollowIdSet OR Site__r.Site_Type__c =\'Public\') ';
				
			} else {
				// condition for ALL not needed
			}
		}
		return queryStr;
	}
	
	/**
     *page
     **/
	private String getTopicCondition(String topicId){
		String queryStr = '';
		if(String.isNotBlank(topicId)){
			queryStr += 'And Id in (select EntityId from TopicAssignment where TopicId=: topicId ' +
            				'And EntityType=\'Simpplr_Content\') ';
		}
		
		return queryStr;
	}
    
    /**
     *page
     **/
    private String getSiteCondition(String siteId){
		String queryStr = '';
		if(String.isNotBlank(siteId)){
			queryStr += ' And site__c=: siteId ';
		}
    	return queryStr; 
    }

    private String getContentSubTypeCondition(String contentSubType){
        String queryStr = '';
        
		if(String.isNotBlank(contentSubType)){
			queryStr += ' AND Content_Sub_Type__c = :contentSubType ';
		}
    	return queryStr; 
    }
    
	
	/**
     *page
     **/
	private String getCategoryCondition(String categoryId){
		String queryStr = '';
		if(String.isNotBlank(categoryId) && !'all'.equalsIgnoreCase(categoryId)){
			queryStr += ' AND Pages_Category__c =:categoryId ';
		}
    	return queryStr; 
	}
	/**
     *page
     **/
	private String getSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			if (sortby.equalsIgnoreCase('DisplayOrder')) {
				queryStr += ' Order by Display_Order__c, Last_Updated_DateTime__c  DESC, publish_start_datetime__c desc, Created_DateTime__c '; 
				
            } else if (sortby.equalsIgnoreCase('Latest') ) { 
				queryStr += ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c desc '; 
				
            } else if (sortby.equalsIgnoreCase('Liked')) {
				queryStr += ' Order by Likes__c desc, Last_Updated_DateTime__c desc '; 
				
            } else if (sortby.equalsIgnoreCase('Viewed')) {				
				queryStr += ' Order by Total_View_Count__c desc, Last_Updated_DateTime__c desc '; 
				
            }else if(sortby.equalsIgnoreCase('Popular')) {
				queryStr += ' Order by Popularity_Score__c desc, Last_Updated_DateTime__c desc ';
				
			} else if(sortBy.equalsIgnoreCase('publishedNewest')) {
				queryStr += ' Order by Is_Published__c desc, Publish_Start_DateTime__c desc, Last_Updated_DateTime__c desc, Created_DateTime__c desc ';

			} else if(sortBy.equalsIgnoreCase('publishedOldest')) {
				queryStr += ' Order by Is_Published__c desc, Publish_Start_DateTime__c asc, Last_Updated_DateTime__c asc, Created_DateTime__c desc ';

			} else if(sortBy.equalsIgnoreCase('modifiedNewest')) {
				queryStr += ' Order by Last_Updated_DateTime__c desc '; 

			} else if(sortBy.equalsIgnoreCase('modifiedOldest')) {
				queryStr += ' Order by Last_Updated_DateTime__c asc ';
			
			} else if(sortBy.equalsIgnoreCase('createdNewest')) {
				queryStr += ' Order by Created_DateTime__c desc ';

			} else if(sortBy.equalsIgnoreCase('createdOldest')) {
				queryStr += ' Order by Created_DateTime__c asc ';

			}
			
		}else{
			queryStr += ' Order by Is_Published__c desc, Publish_Start_DateTime__c desc, Last_Updated_DateTime__c desc, Created_DateTime__c desc ';
		}
        return queryStr;
	}
	
	/**
     *page
     **/
	private String getLimitOffsetCondition(Integer recordLimit, Integer offset){
		String	queryStr = '';
		if(recordLimit!=null && offset!=null) {
			queryStr += ' limit :recordLimit  offset :offset';
		}
		return queryStr;
	}
	

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Pages_Category__c> getSitePagesGroupByCategory(Criteria.Pages pagesCriteriaObjArg, Integer recordLimit) {
		Integer offset = pagesCriteriaObjArg.offset;		
		String siteId = pagesCriteriaObjArg.siteId;
		String author = pagesCriteriaObjArg.authoredBy;
		DateTime publishStartDateTime = Utility.getDateTimeFilterValue(pagesCriteriaObjArg.publishStartDateSpan);

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', author);
		soqlParamMap.put('soqlParam2', publishStartDateTime);
		String filterCondition = String.isNotBlank(author) ? ' And primary_author__c =:soqlParam1 ' : '';
		filterCondition += publishStartDateTime != null ? ' And Publish_Start_DateTime__c >=: soqlParam2  ' : '';
		soqlParamMap.put('soqlParam3', siteId);
		soqlParamMap.put('soqlParam4', contentType);
		soqlParamMap.put('soqlParam5', siteId);
		soqlParamMap.put('soqlParam6', recordLimit);
		soqlParamMap.put('soqlParam7', offset);
		String query = 	'select id, Name__c, (select id from Simpplr_Content_Page_Category__r ' +
												'Where Is_Published__c = true AND Is_Deleted__c = false ' +
												'And Status__c = \'Approved\' ' +
												filterCondition + 
												'order by Display_Order__c, ' +
												'Publish_Start_DateTime__c DESC, ' +
												'Last_Edited_DateTime__c  DESC, ' +
												'CreatedDate DESC, Type__c, Primary_Author__c ' +
												'limit 3) ' +
						'from Pages_Category__c ' +
						'where site__c=:soqlParam3 ' +
						'and id in (select Pages_Category__c from Simpplr_content__c ' +
						'where pages_Category__c != null ' +
						'And Status__c = \'Approved\' And Type__c =:soqlParam4 ' +
							'AND Is_Published__c = true  ' +
							'AND Is_Deleted__c = false ' +
							filterCondition + 
							'And site__c=:soqlParam5) ' +
						'order by order__c, LastModifiedDate DESC limit :soqlParam6 offset :soqlParam7 ';
		logger.logDebug('PageDao.getSitePagesGroupByCategory()----query----' + query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Pages_Category__c> listOfPageCategories = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	 return listOfPageCategories;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Simpplr_Content__c> getContentDetailsByIds(List<String> listOfIds) {
    	List<Simpplr_Content__c> listOfSimpplrContents = [select id, title__c, type__c, Primary_Author__c, Primary_Author__r.User__c, Primary_Author__r.Full_Name__c, Display_Excerpt__c, Pages_Category__c, Pages_Category__r.Id, Publish_Start_DateTime__c, Last_Edited_DateTime__c, CreatedDate,Is_Must_read__c, Created_DateTime__c, CreatedBy_People__c, Last_UpdatedBy_People__c, Last_Updated_DateTime__c,
    															(Select Id, Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId and Must_Read_Audit__r.Removed_DateTime__c=null),  
																(select Must_Read_Confirm_Count__c, Audience_Type__c, Removed_By_People__c, Content__r.Title__c from Must_Read_Audits__r where Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: DateTime.now())),
																(Select Content_Version__c, Content_Document__c, MIME_Type__c, Title_Image_Type__c, Is_Title_Image__c from File_Simpplr_Content__r 
    																Where Content_Version__c != null 
    																And Is_Deleted__c = false AND (Title_Image_Type__c ='Thumbnail' OR Title_Image_Type__c='Widescreen') And Is_Title_Image__c = true),
																	Site__c, Site__r.Name, Site__r.Chatter_Group_Id__c, Site__r.Landing_Page__c, Site__r.Title_Content_Version__c, Site__r.Title_Content_Document__c, Site__r.Site_Type__c
    													  from Simpplr_Content__c where id=:listOfIds WITH SECURITY_ENFORCED];
    	return listOfSimpplrContents;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<AggregateResult> getContentCountsPerCategory(Criteria.Pages pagesCriteriaObjArg, List<String> listOfCategoryIds) {
		String siteId = pagesCriteriaObjArg.siteId;
		String author = pagesCriteriaObjArg.authoredBy;
		String contentSubType = pagesCriteriaObjArg.contentSubType;
		DateTime publishStartDateTime = Utility.getDateTimeFilterValue(pagesCriteriaObjArg.publishStartDateSpan);

		String filterCondition = getAuthorCondition(author);
		filterCondition += getPublishStartDateCondition(publishStartDateTime);
		filterCondition += getContentSubTypeCondition(contentSubType);

		String query = 	'select pages_Category__c categoryId, count(Id) ' +
						'from Simpplr_Content__c ' +
						'where site__c=:siteId ' +
						'AND Is_Deleted__c = false ' +
						'And Status__c = \'Approved\' And Type__c =:contentType '+
						'And Is_Published__c = true ' + 
						filterCondition ;
						
		if(!('all').equalsIgnoreCase(pagesCriteriaObjArg.category)){
			query +=' AND pages_Category__c =:listOfCategoryIds ';
		}
		query +=' group by pages_Category__c ';
		logger.logDebug('query-----'+query);
    	AggregateResult[] groupedResults = Database.query(query);
		return groupedResults;
    }
    /**
     *page
     **/
	private String getPopularTopicsCondition(Set<Id> listOfSelectedTopics){
		String queryStr = '';
		if(null != listOfSelectedTopics && listOfSelectedTopics.size() >0){
			queryStr += ' And Id in (select EntityId from TopicAssignment where TopicId in :listOfSelectedTopics ' +
            				'And EntityType=\'Simpplr_Content\') ';
		}
		return queryStr;
	}
	
	private List<Simpplr_Content__c> populateData(List<Simpplr_Content__c> queryResult,Set<Id> listOfSelectedTopics){
		
		List<TopicAssignment> listOfEntity = [Select EntityId,TopicId from TopicAssignment
													where TopicId in :listOfSelectedTopics and EntityId in :queryResult WITH SECURITY_ENFORCED];
													
		List<Simpplr_Content__c> finalResult = new List<Simpplr_Content__c>();
																			
		Id entityId;
		Id selectedTopicId;
		Map<Id,Set<Id>> mapOfTopics = new Map<Id,Set<Id>>();
		Set<Id> relatedTopics;		
		for(TopicAssignment resultObj : listOfEntity){
			entityId = resultObj.EntityId;
			selectedTopicId = resultObj.TopicId;
			if(mapOfTopics.containsKey(entityId)){
				relatedTopics = mapOfTopics.get(entityId);
			}else{
				relatedTopics = new Set<Id>();
			}
			relatedTopics.add(selectedTopicId);
			mapOfTopics.put(entityId,relatedTopics);
		}
						
				
		
		
		for(Simpplr_Content__c content : queryResult){
			if(mapOfTopics.containsKey(content.id)){
				Set<Id> listOfTopicsForEntity = mapOfTopics.get(content.id);
				if(listOfTopicsForEntity.equals(listOfSelectedTopics)){
					finalResult.add(content);
				}
			}
		}
		return finalResult;		
	}
	
	public List<AggregateResult> getPopularTopic(String siteId, String categoryId){
		List<AggregateResult> topics;
		if(('all').equalsIgnoreCase(categoryId)){
			topics = getPopularTopicsForSite(siteId);
		}else{
			topics = getPopularTopicsForSiteCategory(siteId,categoryId);
		}
		
		return topics;
	}
	
	private List<AggregateResult> getPopularTopicsForSite(String siteId){
		List<AggregateResult> topics = [Select Topic.id topicId, Topic.name topicName, count(Id) topicCount from TopicAssignment
    										where EntityId in (Select Id from Simpplr_Content__c 
    										where Is_Deleted__c = false 
    										and Is_Published__c = true 
    										and Status__c = 'Approved' 
    										and site__c =: siteId
    										and Type__c = 'Page') WITH SECURITY_ENFORCED group by Topic.id , Topic.name order by count(Id) desc, Topic.name asc limit 16]; 
    										
		return topics;  										    										
	}
	
	private List<AggregateResult> getPopularTopicsForSiteCategory(String siteId, String categoryId){	
		List<AggregateResult> topics = [Select Topic.id topicId, Topic.name topicName, count(Id) topicCount from TopicAssignment
    										where EntityId in (Select Id from Simpplr_Content__c 
    										where Is_Deleted__c = false 
    										and Is_Published__c = true 
    										and Status__c = 'Approved' 
    										and site__c =: siteId
    										and Pages_Category__c =: categoryId
    										and Type__c = 'Page') WITH SECURITY_ENFORCED group by Topic.id , Topic.name order by count(Id) desc, Topic.name asc limit 16]; 
    										
		return topics;  										    										
	}
	
	private String getContentIdContition(List<String> listOfContentIds){
		String queryStr = '';
			queryStr += 'And Id in :listOfContentIds ';
    	
    	return queryStr; 
	}

}