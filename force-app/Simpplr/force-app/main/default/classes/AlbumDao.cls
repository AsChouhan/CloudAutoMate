/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AlbumDao extends DAO{
	

	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
	
	private final String contentType = ServiceConstants.TYPE_ALBUM;
	
	private Set<Id> contentIdsForFollowingTopics;
    
    private Id loggedInPeopleId{get{
    	return UserContext.getCurrentUserInfo.Id;
    }}
    private Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
	private DateTime currentDateTime = DateTime.now();
    
    public List<String> getContentFieldList() {
        String mustReadSubCondition = UserContext.isUserAppModerator ? '' : ' And (Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet) ';
    	return New List<String>{
    		'Id',
            'First_Publish_DateTime__c',
            'Type__c',
            'Activated_By_Feature__c',
            'site__c',
            'Primary_Author__c',
            'Title__c',
            'Text_Intro__c',
            'Display_Excerpt__c',
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
            '(select  Audience_Type__c, Must_Read_Confirm_Count__c from Must_Read_Audits__r where Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) ' +  mustReadSubCondition + ' order by createddate desc limit 1)',
            '(Select Id,Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId and Must_Read_Audit__r.Removed_DateTime__c=null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) )',
            '(select id from Bookmarked_Content__r where People__c =:loggedInPeopleId and Is_Deleted__c=false)',
            '(Select Id FROM Content_Notification_Setting__r where People__c =:loggedInPeopleId)',
            '(select id from Likes_Simpplr_Content__r where People__c =: loggedInPeopleId and Is_Deleted__c=false)',
            '(Select Id, Was_Content_Useful__c from Simpplr_Content_Feedback__r where submitter__c =:loggedInPeopleId and Is_Deleted__c=false)',
            '(Select Id,Rsvp_Response__c,People__c,RSVP_Response_Text__c from Event_RSVP_Responses__r where is_deleted__c = false And People__c=:loggedInPeopleId)',
            '(select id, Site__c from Simpplr_Carousel_Contents__r where Is_Deleted__c = false)',
            '(SELECT Id,Content_Version__c, Content_Document__c, Title_Image_Type__c,Is_Title_Image__c,Size__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false and Is_Title_Image__c = true)' 

        };
    }
    
    private final String BASE_QUERY = 'SELECT '+String.join(getContentFieldList(),',')+
			' FROM Simpplr_Content__c WHERE Status__c =\'Approved\' AND Type__c =:contentType '+
			' AND Is_Published__c = true '+
			' AND Is_Deleted__c = false '+
			' And Site__r.Has_Albums__c = true ' +
			' And Site__r.Is_Active__c = true ' + 
			' And Site__r.Show_In_Simpplr__c = true ';
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Simpplr_Content__c> getAlbumsSearchResults (Criteria.Album albumCriteriaObjArg) {
        String loggedInUserId = UserContext.id;
        String siteId = albumCriteriaObjArg.siteId;
        String filter = albumCriteriaObjArg.filter;
        Integer recordLimit = albumCriteriaObjArg.size + 1;
        Integer offset = albumCriteriaObjArg.offset; 
        String topicId = albumCriteriaObjArg.topicId;
        DateTime publishStartDateTime = Utility.getDateTimeFilterValue(albumCriteriaObjArg.publishStartDate);
        String author = albumCriteriaObjArg.authoredBy;
        String sortBy = albumCriteriaObjArg.sortBy;
        Set<String> contentIdSet = new Set<String>();

        if(albumCriteriaObjArg.contentIdSet!=null && albumCriteriaObjArg.contentIdSet.size()>0){
            contentIdSet.addAll(albumCriteriaObjArg.contentIdSet);
        }

        String publishStartDateSpan = albumCriteriaObjArg.publishStartDateSpan;

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

        Set<String> setOfSearchTerms = String.isNotBlank(albumCriteriaObjArg.term) ? Utility.getSearchTokens(String.escapeSingleQuotes(albumCriteriaObjArg.term)) : null;
        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet; // for following filter
        String loggedInUserPeopleId = UserContext.peopleId;
        
        String queryStr = BASE_QUERY;
        queryStr += getSearchTermCondition(setOfSearchTerms);
        queryStr += getIdFilterCondition(contentIdSet);
        queryStr += getSiteIdCondition(siteId);
        queryStr += getFilterCondition(filter);
        queryStr += getTopicCondition(topicId);
        queryStr += getPublishStartDateCondition(publishStartDateTime);
        queryStr += getAuthorCondition(author);
        queryStr += ' WITH SECURITY_ENFORCED ';
        queryStr += getSortOrderCondition(sortBy);
        queryStr += getLimitOffsetCondition(recordLimit, offset); 
        
        return Database.query(queryStr);
	}
	/**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Simpplr_Content__c> getContentListFromCriteria(String siteId,String searchText,String status,String orderByField,String order,Integer recordLimit,Integer offsetVal,Set<Id> siteIdSet,Boolean isAppModerator, String filter, String peopleId, String contribution){
        String currentUserId = UserContext.id;
        String thumbnail = 'thumbnail';
        String contentStatusPreDraft = ServiceConstants.CONTENT_STATUS_PREDRAFT;
        Boolean isPublished = false;
        Id currentPeopleRecordId = UserContext.getCurrentUserInfo.Id;
        String type = ServiceConstants.TYPE_ALBUM;
        String conditionString = '';
        conditionString += ' Type__c =:type AND Type__c IN : allowedFeaturesInAppList';
        conditionString += ' AND Is_Deleted__c = false ';
        conditionString += ' And Status__c !=: contentStatusPreDraft ';
        conditionString += ' AND Site__c != null';
        conditionString += ' And Site__r.Is_Active__c = true';
        conditionString += ' And Site__r.Show_In_Simpplr__c = true';
        conditionString += ' AND Site__r.Has_Albums__c = true';
        if (String.isNotBlank(peopleId)){
        	conditionString += ' AND Primary_Author__c =: peopleId';
        }
        
        if('owned'.equalsIgnoreCase(filter)) {
        	 conditionString += ' AND Primary_Author__c =: currentPeopleRecordId';
        } else if('favorites'.equalsIgnoreCase(filter)) {
        	conditionString += ' AND Is_Published__c = true And Id in (Select Simpplr_Content__c from Bookmark__c where ' +
							   ' Type__c =:type And People__c =:currentPeopleRecordId And Is_Deleted__c = false ) ';
        } else if('must_read'.equalsIgnoreCase(filter)) {
        	conditionString += ' AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) AND ( Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet)) ';
        }

        if('contributedByMe'.equalsIgnoreCase(contribution)) {
			conditionString += ' AND id IN (Select Content__c from Content_Audit_Trail__c where Action_By__c =: loggedInPeopleId) ';
        }
	    
        if(!isAppModerator && !'favorites'.equalsIgnoreCase(filter)){
            if(siteIdSet != null && siteIdSet.size() > 0){
                conditionString += ' AND (site__c IN:siteIdSet OR Primary_Author__c =: currentPeopleRecordId)';
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
            } else if (ServiceConstants.CONTENT_STATUS_ORG_OR_SITE_ONBOARDING.equalsIgnoreCase(status) ){
				conditionString+=' AND (Content_Onboarding_Status__c = \'orgOnboarding\' OR Content_Onboarding_Status__c = \'siteOnboarding\') ';
			} else if (ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(status) ){
				conditionString+=' AND Content_Onboarding_Status__c =\'orgOnboarding\' ';
			} else if (ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(status) ){
				conditionString+=' AND Content_Onboarding_Status__c =\'siteOnboarding\' ';
			} else {
                conditionString+=' AND Status__c =:status';
            }
        } else if (String.isNotBlank(status) && status.equalsIgnoreCase('all')){
        	String draftStatus = ServiceConstants.CONTENT_STATUS_DRAFT;
        	conditionString+=' AND (Status__c !=: draftStatus OR (Status__c =: draftStatus AND Primary_Author__c =: currentPeopleRecordId))';
        } 
        if(String.isNotBlank(searchText)) {
        		Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
            conditionString += getSearchTermCondition(setOfSearchTerms);
        }
        if(String.isNotBlank(siteId)){
            conditionString+=' AND Site__c = :siteId';
        }
        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        if(isAppModerator && !'favorites'.equalsIgnoreCase(filter) && !UserContext.hasModifyAllDataPermission){
    		conditionString+=' AND ((Site__r.Chatter_Group_Id__c =:chatterGroupsIFollowIdSet And Primary_Author__c =: currentPeopleRecordId) OR Site__r.Site_Type__c =\'Public\' OR Type__c=\'BlogPost\' OR site__c IN:siteIdSet)';
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

        String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c'+conditionString + ' WITH SECURITY_ENFORCED ' +subConditionString;
        
        return Database.query(query); 
    }
	
	/**
     *album
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
     *album
     **/
	private String getSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			if (sortby.equalsIgnoreCase('Latest') ) {
                queryStr += ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c desc '; 
                
            } else if (sortby.equalsIgnoreCase('Liked')) {
                queryStr += ' Order by Likes__c desc, Last_Updated_DateTime__c desc '; 
                
            } else if (sortby.equalsIgnoreCase('Viewed')) {
                queryStr += ' Order by Total_View_Count__c  desc, Last_Updated_DateTime__c desc '; 
                
            }else if(sortby.equalsIgnoreCase('Popular')){
                queryStr += ' Order by Popularity_Score__c desc, Last_Updated_DateTime__c desc ';
                
            } else if(sortBy.equalsIgnoreCase('publishedNewest')) {
				queryStr += ' Order by Is_Published__c desc, Publish_Start_DateTime__c desc, Last_Updated_DateTime__c desc, Created_DateTime__c desc ';

			} else if(sortBy.equalsIgnoreCase('publishedOldest')) {
				queryStr += ' Order by Is_Published__c desc, Publish_Start_DateTime__c asc, Last_Updated_DateTime__c asc, Created_DateTime__c asc ';

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
			queryStr += ' Order by Is_Published__c desc, Publish_Start_DateTime__c desc, Last_Updated_DateTime__c desc, Created_DateTime__c desc  '; // Add default sort order
		}
        return queryStr;
	}
	
	/**
     *album
     **/
	private String getLimitOffsetCondition(Integer recordLimit, Integer offset){
		String	queryStr = '';
		if(recordLimit!=null && offset!=null) {
			queryStr += ' limit :recordLimit  offset :offset';
		}
		return queryStr;
	}
	
	/**
     *album
     **/
	private String getSiteIdCondition(String siteId){
		String queryStr = '';
		if(String.isNotBlank(siteId)) {
			queryStr += ' And site__c=:siteId ';
		}
		return queryStr;
	}
	
    public Integer getTotalAlbumRecords(Criteria.Album albumCriteriaObjArg){    
        logger.logDebug('AlbumDao.getTotalAlbumRecords()------albumCriteriaObjArg--' + albumCriteriaObjArg);
        Integer totalRecords = 0;
        String siteId = albumCriteriaObjArg.siteId;
        String author = albumCriteriaObjArg.authoredBy;
        DateTime publishStartDateTime = Utility.getDateTimeFilterValue(albumCriteriaObjArg.publishStartDateSpan); 
        String filterCondition = getPublishStartDateCondition(publishStartDateTime);
        filterCondition += getAuthorCondition(author);
        filterCondition += getSiteIdCondition(siteId);
        filterCondition += 'AND Is_Deleted__c = false  AND Is_Published__c = true';
        String queryStr = 'SELECT count(Id) FROM Simpplr_Content__c where type__c = \'Album\'' + filterCondition + ' WITH SECURITY_ENFORCED ';      
        logger.logDebug('AlbumDao.getTotalAlbumRecords()------queryStr--' + queryStr);      
        AggregateResult ar = Database.query(queryStr);
        totalRecords = (Integer) ar.get('expr0');    
        return totalRecords;
    }
	/**
     *album
     **/
	private String getFilterCondition(String filter){
		String queryStr = '';
		if(String.isNotBlank(filter)){
			if(FILTER_BOOKMARKED.equalsIgnoreCase(filter)){
				queryStr += ' And Id in (Select Simpplr_Content__c from Bookmark__c where ' +
							   ' Type__c =: contentType And createdById =:loggedInUserId And Is_Deleted__c = false ) ';
			}else if(FILTER_FOLLOWING.equalsIgnoreCase(filter)){
				contentIdsForFollowingTopics = getContentIdSetForFollowedTopics(ServiceConstants.TYPE_ALBUM);
				queryStr += ' And (Site__r.Chatter_Group_Id__c =:chatterGroupsIFollowIdSet ' + 
									' OR Primary_Author__c =:loggedInUserPeopleId' + 
									' OR Id IN :contentIdsForFollowingTopics)';
			}else{
				// condition for ALL not needed
			}
		}
		return queryStr;
	}
	
	/**
     *album
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
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override Map<Id,Simpplr_Content__c> getContentsMapFromIds(List<Id> listOfContentIds,String siteId) {

    	return new Map<Id, Simpplr_Content__c>([SELECT Is_Deleted__c, Summary_2__c, Display_Excerpt__c, Type__c, 
    			Title__c, Text_Main__c, Text_Main_Continued__c, Text_Intro__c, Status__c, Shares__c, 
    			Title_Image_Caption__c, Publish_Start_DateTime__c, Publish_End_DateTime__c, 
    			Likes__c, Site__c,  Site__r.chatter_group_id__c, Site__r.name,
                Site__r.Site_Type__c, Primary_Author__c,Is_Must_Read__c,
                Primary_Author__r.Full_Name__c, Primary_Author__r.User__r.SmallPhotoUrl, Primary_Author__r.User__r.FullPhotoUrl, Primary_Author__r.Street__c,
                Primary_Author__r.City__c, Primary_Author__r.State__c, Primary_Author__r.Country__c, 
                Primary_Author__r.Postal_Code__c, Primary_Author__r.Title__c, Primary_Author__r.Department__c,
                Id, Allow_comments__c, CreatedDate, CreatedBy.name, CreatedById, Allow_Follow__c, Created_DateTime__c, CreatedBy_People__c, Last_UpdatedBy_People__c, Last_Updated_DateTime__c,
                lastModifiedDate, Album_Image_Count__c, Album_Video_Count__c,
                Is_Published__c, Is_Unpublished__c,
                Last_Edited_DateTime__c, (Select Id, MIME_Type__c From File_Simpplr_Content__r)
                FROM Simpplr_Content__c WHERE Id IN: listOfContentIds AND site__c = :siteId
                AND site__r.IsDeleted = false AND Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true AND 
                site__r.Has_Albums__c = true AND Is_Deleted__c = false
                AND Type__c =: ServiceConstants.TYPE_ALBUM]);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Simpplr_Content__c updateAlbumWithLatestCount(String albumId, Integer videoCount, Integer photoCount) {
    	Simpplr_Content__c albumObj = new Simpplr_Content__c();
    	
    	List<Simpplr_Content__c> listOfAlbum = [SELECT Id, Album_Video_Count__c,Album_Image_Count__c, 
						Primary_Author__c, Primary_Author__r.User__c, Primary_Author__r.First_Name__c, 
						Title__c, Site__c, Site__r.name, Site__r.Chatter_Group_Id__c, Display_Excerpt__c,
						Primary_Author__r.External_Photo_URL__c,type__c ,Album_Allow_All_to_Upload__c, 
						Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c
						FROM Simpplr_Content__c WHERE Id = :albumId WITH SECURITY_ENFORCED LIMIT 1 FOR UPDATE];
        if (!listOfAlbum.isEmpty()) {
        	 
        	albumObj = listOfAlbum[0];
        	
        	if (albumObj.Album_Video_Count__c == null) {
        		albumObj.Album_Video_Count__c = 0;
        	}
        	
        	if (albumObj.Album_Image_Count__c == null) {
        		albumObj.Album_Image_Count__c = 0;
        	}
        	
        	albumObj.Album_Video_Count__c = albumObj.Album_Video_Count__c + videoCount;
        	albumObj.Album_Image_Count__c = albumObj.Album_Image_Count__c + photoCount;
        	
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        	SIMPESAPI.accessController().updateAsUser(albumObj, new List<Schema.SObjectField>{
        			Simpplr_Content__c.Album_Video_Count__c,Simpplr_Content__c.Album_Image_Count__c});
        			
        }
        
        return albumObj;
    }
    
}