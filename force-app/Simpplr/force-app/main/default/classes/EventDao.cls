/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class EventDao extends DAO{
	
	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
	
	private final String contentType = ServiceConstants.TYPE_EVENT;
	private final String FILTER_FUTURE  = 'future';
	private final String FILTER_PAST  = 'past';
	DateTime startTime;
	DateTime endTime;
	DateTime startTimeForLaterSection;
	
	private Map<String,Integer> mapOfDayWithNumberOfDaysToAdd = new Map<String,Integer>{
		'Mon'=>6,
		'Tue'=>5,
		'Wed'=>4,
		'Thu'=>3,
		'Fri'=>2,
		'Sat'=>1,
		'Sun'=>0
	};
	
    private Set<String> setOfSearchTerms;
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
		            ' FROM Simpplr_Content__c ' +
		            ' WHERE Status__c =\'Approved\' AND Type__c =:contentType '+
		            ' AND Is_Published__c = true '+
		            ' AND Is_Deleted__c = false '+
		            ' And Site__r.Has_Events__c = true '+
		            ' And Site__r.is_Deleted__c=false '+
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
    public List<Simpplr_Content__c> getContentListFromCriteria(String siteId,String searchText,String status,String orderByField,String order,Integer recordLimit,Integer offsetVal,Set<Id> siteIdSet,Boolean isAppModerator, String filter, String peopleId, String contribution){
        String currentUserId = UserContext.id;
        String thumbnail = 'thumbnail';
        Boolean isPublished = false;
        Id currentPeopleRecordId = UserContext.getCurrentUserInfo.Id;
        String type = ServiceConstants.TYPE_EVENT;
        String conditionString = '';
        conditionString += ' Type__c =:type AND Type__c IN : allowedFeaturesInAppList';
        conditionString += ' AND Is_Deleted__c = false ';
        conditionString += ' AND Site__c != null';
        conditionString += ' And Site__r.Is_Active__c = true';
        conditionString += ' And Site__r.Show_In_Simpplr__c = true';
        conditionString += ' AND Site__r.Has_Events__c = true ';
        if (String.isNotBlank(peopleId)){
        	conditionString += ' AND Primary_Author__c =: peopleId';
        }
        
        if('owned'.equalsIgnoreCase(filter)) {
        	 conditionString += ' AND Primary_Author__c =: currentPeopleRecordId';
        } else if('favorites'.equalsIgnoreCase(filter)) {
        	conditionString += ' AND Is_Published__c = true And Id in (Select Simpplr_Content__c from Bookmark__c where ' +
							   ' Type__c =:type And People__c =:currentPeopleRecordId  AND Is_Deleted__c = false) ';
        } else if('must_read'.equalsIgnoreCase(filter)) {
        	conditionString += ' AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) AND  ( Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet)) ';
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

        String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c'+conditionString+subConditionString;
        
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
    public List<Content_Collaborator__c> getEventOrganizerFromId(String Id){
        List<Content_Collaborator__c> result = New List<Content_Collaborator__c>();
        if(!String.isBlank(Id)){
           Map<Id,Content_Collaborator__c> mapOfContent = getEventOrganizer(New List<String>{Id});
            if(mapOfContent.size() > 0){
                result = mapOfContent.values();
            }
        }
        return result;
    }
    
    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Event_RSVP_Response__c> getEventRsvpList(String Id){
        List<Event_RSVP_Response__c> result = New List<Event_RSVP_Response__c>();
        if(!String.isBlank(Id)){
           Map<Id,Event_RSVP_Response__c> mapOfContent = getEventRsvpMap(New List<String>{Id});
            if(mapOfContent.size() > 0){
                result = mapOfContent.values();
            }
        }
        return result;
    }
    
    /**
    * 
    * Purpose:  This method return the rsvp count for this event. This count will exclude the response of the logged-in user.
    * Parameters:
    *      contentId -- The Id of the event
    *      response -- The response-type for which count is required (ie. Yes/No/Maybe)
    *      
    * Returns:  rsvp count excluding logged-in user response.
    */
    public Integer getRSVPVoteCount(String contentId, String response) {
    	List<Event_RSVP_Response__c> listOfRSVPResponses = [select id from Event_RSVP_Response__c 
                                                      WHERE Content__c =:contentId
                                                      And RSVP_Response__c =: response
                                                      And People__c != :loggedInPeopleId WITH SECURITY_ENFORCED];
        return listOfRSVPResponses.size();                                              
    }
    
    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Event_Invitee__c> getEventInvitedUsersList(String Id,Integer offsetVar, String sortBy){
        List<Event_Invitee__c> result = New List<Event_Invitee__c>();
        if(!String.isBlank(Id)){
           Map<Id,Event_Invitee__c> mapOfContent = getEventInvitedUsersMap(New List<String>{Id},offsetVar, sortBy);
            if(mapOfContent.size() > 0){
                result = mapOfContent.values();
            }
        }
        return result;
    }
    
    public List<Event_RSVP_Response__c> getEventAttendingList(String Id,Integer offsetVar, String sortBy){
        List<Event_RSVP_Response__c> result = New List<Event_RSVP_Response__c>();
        if(!String.isBlank(Id)){
           Map<Id,Event_RSVP_Response__c> mapOfContent = getEventAttendingUsersMap(New List<String>{Id},offsetVar, sortBy);
            if(mapOfContent.size() > 0){
                result = mapOfContent.values();
            }
        }
        return result;
    }
    
    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Event_Invitee__c> getEventInvitedUsersBySearchTermList(String Id,String query){
        List<Event_Invitee__c> result = New List<Event_Invitee__c>();
        if(!String.isBlank(Id)){
           Map<Id,Event_Invitee__c> mapOfContent = getEventInvitedUsersBySearchTermMap(New List<String>{Id},query);
            if(mapOfContent.size() > 0){
                result = mapOfContent.values();
            }
        }
        return result;
    }   
    
    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Simpplr_Content__c getContentForRsvpFields(String Id){
        Simpplr_Content__c result;
        if(!String.isBlank(Id)){
           Map<Id,Simpplr_Content__c> mapOfContent = getContentForRsvpFieldsMap(New List<String>{Id});
            if(mapOfContent.size() > 0){
                result = mapOfContent.values().get(0);
            }
        }
        return result;
    }    



    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Simpplr_Content__c> getContentForRsvpFieldsMap(List<Id> listOfContentIds) {
        return new Map<Id, Simpplr_Content__c>([SELECT Event_RSVP_Allowed__c,Event_RSVP_Note__c,Event_RSVP_Show_Maybe__c,Event_RSVP_Limit__c,
                                                Event_RSVP_By_DateTime__c
                                                    FROM Simpplr_Content__c
                                                        WHERE Id IN: listOfContentIds]);
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
    	return new Map<Id, Simpplr_Content__c>([SELECT Is_Deleted__c,Display_Excerpt__c, Summary_1__c,
                                                Type__c, Title__c, Text_Main__c, Text_Main_Continued__c, Text_Intro__c,Status__c, Shares__c, 
                                                Title_Image_Caption__c,Publish_Start_DateTime__c,Publish_End_DateTime__c,
                                                Likes__c, Site__c,  Site__r.chatter_group_id__c, Site__r.name,
                                                Site__r.Site_Type__c, Is_Must_Read__c,
                                                Is_Published__c, Is_Unpublished__c,
                                                Primary_Author__c,Primary_Author__r.Full_Name__c, Primary_Author__r.User__r.SmallPhotoUrl,Primary_Author__r.User__r.FullPhotoUrl,
                                                Primary_Author__r.Street__c,Primary_Author__r.City__c,Primary_Author__r.State__c,
                                                Primary_Author__r.Country__c,Primary_Author__r.Postal_Code__c,Primary_Author__r.Title__c,
                                                Primary_Author__r.Department__c,Id, Allow_comments__c, CreatedDate,CreatedBy.name, CreatedById,Created_DateTime__c, CreatedBy_People__c, Last_UpdatedBy_People__c, Last_Updated_DateTime__c,
                                                Allow_Follow__c,lastModifiedDate,Cover_Image_Layout__c,
                                                //----------------Event specific fields-------------------------------
                                                Event_Start_DateTime__c,Event_End_DateTime__c,Event_TimezoneSidKey__c,Event_Is_All_Day__c,Event_RSVP_Allowed__c,
                                                Event_RSVP_Note__c,Event_RSVP_Show_Maybe__c,Event_RSVP_Limit__c,Event_Map_URL__c,Event_Location__c,
                                                Event_Directions_Enabled__c,Event_Directions__c,Event_RSVP_By_DateTime__c,Last_Edited_DateTime__c,Event_Attending_Count__c, Excerpt__c  
                                                    FROM Simpplr_Content__c
                                                        WHERE Id IN: listOfContentIds 
                                                            AND site__c =:siteId
                                                            And Site__r.IsDeleted = false 
                                                            And Site__r.is_Active__c = true And Site__r.Show_In_Simpplr__c = true 
                                                            And Site__r.Has_Events__c = true
                                                            And Is_Deleted__c = false
                                                            AND Type__c =: ServiceConstants.TYPE_EVENT]);
    }

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Content_Collaborator__c> getEventOrganizer(List<Id> listOfContentIds){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', listOfContentIds);
        soqlParamMap.put('soqlParam2', ServiceConstants.EVENT_ORGANIZER);
        String collaboratorQuery = 'SELECT Id,Collaborator__c,Collaborator__r.Full_Name__c, Collaborator__r.User__r.SmallPhotoUrl,Collaborator__r.User__r.FullPhotoUrl, ' +
            ' Collaborator__r.Street__c,Collaborator__r.City__c,Collaborator__r.State__c, ' +
            ' Collaborator__r.Country__c,Collaborator__r.Postal_Code__c,Collaborator__r.Title__c, ' +
            ' Collaborator__r.Department__c ' +
            ' FROM Content_Collaborator__c  ' +
                ' WHERE Simpplr_Content__c IN :soqlParam1 ' +
                ' AND Type__c=:soqlParam2 ' +
                ' And Is_Deleted__C = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return new Map<Id,Content_Collaborator__c> ((List<Content_Collaborator__c>)SIMPESAPI.accessController().queryAsUser(collaboratorQuery, soqlParamMap));
    }

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Event_RSVP_Response__c> getEventRsvpMap(List<Id> listOfContentIds){
        return New Map<Id,Event_RSVP_Response__c> ([SELECT Id,Content__c,People__c,People__r.Full_Name__c, People__r.User__r.SmallPhotoUrl,People__r.User__r.FullPhotoUrl,
                                                        People__r.Street__c,People__r.City__c,People__r.State__c,
                                                        People__r.Country__c,People__r.Postal_Code__c,People__r.Title__c,
                                                        People__r.Department__c,RSVP_Response__c,RSVP_Response_Text__c
                                                        FROM Event_RSVP_Response__c 
                                                            WHERE Content__c IN : listOfContentIds]);
    }

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Event_Invitee__c> getEventInvitedUsersMap(List<Id> listOfContentIds,Integer offsetVar, String sortBy){
        Integer size = SimpplrContext.simpplrDefaultPageSize;
        String subQueryCondition = '';    
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', listOfContentIds);
        soqlParamMap.put('soqlParam2', size);
        soqlParamMap.put('soqlParam3', offsetVar);
        if(sortBy == 'CreatedDate') {
            subQueryCondition += ' order by CreatedDate asc ';
        } else {
            subQueryCondition += ' order by Invitee__r.Full_Name__c ';
        }
        subQueryCondition += ' LIMIT :soqlParam2 OFFSET :soqlParam3 ';
        String queryStr = 'SELECT Id,Invitee__c,Invitee__r.Full_Name__c,Invitee__r.Department__c,Invitee__r.title__c,Invitee__r.Mobile_Phone__c, ' +
                'Invitee__r.city__c,Invitee__r.state__c,Invitee__r.country__c,Invitee__r.User__r.SmallPhotoUrl,Invitee__r.User__r.FullPhotoUrl,Invitee__r.Phone__c,Invitee__r.Extension__c, ' +
                'Invitee__r.User__r.Id,Invited_By__c,Invitation_Status__c,Content__c,Invitee__r.Email__c,Invitee__r.User__r.isactive, ' +
                'Invitee__r.Zoom_Id__c, Invitee__r.Skype_Id__c ' +
            'FROM Event_Invitee__c ' +
            'WHERE Content__c IN :soqlParam1 ';
        queryStr = queryStr + subQueryCondition;
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        return New Map<Id,Event_Invitee__c> ((List<Event_Invitee__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap));
    }
    
    public Map<Id,Event_RSVP_Response__c> getEventAttendingUsersMap(List<Id> listOfContentIds,Integer offsetVar, String sortBy){
        Integer recordLimit = SimpplrContext.simpplrDefaultPageSize+1;
        String subQueryCondition = '';
        if(sortBy == 'CreatedDate') {
            subQueryCondition += ' order by CreatedDate asc ';
        } else {
            subQueryCondition += ' order by People__r.Full_Name__c ';
        }
        subQueryCondition += ' LIMIT :recordLimit OFFSET :offsetVar ';
        String queryStr = 'SELECT Id,Content__c,People__c,People__r.Full_Name__c, People__r.User__r.SmallPhotoUrl,People__r.User__r.FullPhotoUrl, ' +
                'People__r.Street__c,People__r.City__c,People__r.State__c,People__r.Email__c,People__r.Mobile_Phone__c,People__r.Phone__c,People__r.Extension__c, ' +
                'People__r.Country__c,People__r.Postal_Code__c,People__r.Title__c,People__r.User__r.isactive, ' +
                'People__r.Department__c,RSVP_Response__c,RSVP_Response_Text__c, ' +
                'People__r.Zoom_Id__c, People__r.Skype_Id__c ' +
            'FROM Event_RSVP_Response__c ' +
            'WHERE Content__c IN :listOfContentIds AND RSVP_Response__c = \'Yes\' ';
        queryStr = queryStr + subQueryCondition;
        return New Map<Id,Event_RSVP_Response__c> ((List<Event_RSVP_Response__c>)Database.query(queryStr));
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Event_Invitee__c> getEventInvitedUserMapById(String contentId, List<String> listOfInviteeId){
        
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', contentId);
        soqlParamMap.put('soqlParam2', listOfInviteeId);
        String query = 'SELECT Id,Invitee__c,Invitee__r.Full_Name__c,Invitee__r.Department__c,Invitee__r.title__c,Invitee__r.Mobile_Phone__c, '
                                + ' Invitee__r.city__c,Invitee__r.state__c,Invitee__r.country__c,Invitee__r.User__r.SmallPhotoUrl,Invitee__r.User__r.FullPhotoUrl,Invitee__r.Phone__c,Invitee__r.Extension__c, '
                                + ' Invitee__r.User__r.Id,Invited_By__c,Invitation_Status__c,Content__c,Invitee__r.Email__c,Invitee__r.User__r.isactive, '
                                + ' Invitee__r.Zoom_Id__c, Invitee__r.Skype_Id__c '
                                + ' FROM Event_Invitee__c ' 
                                + ' WHERE Content__c = : soqlParam1 ' 
                                + ' and Invitee__c in :soqlParam2';


        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        return New Map<Id,Event_Invitee__c> ((List<Event_Invitee__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap));
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id,Event_Invitee__c> getEventInvitedUsersBySearchTermMap(List<Id> listOfContentIds,String query){
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', listOfContentIds);
        soqlParamMap.put('soqlParam2', query);
        String queryStr = 'SELECT Id,Invitee__c,Invited_By__c,Invitation_Status__c,Content__c ' +
            'FROM Event_Invitee__c ' +
            'WHERE Content__c IN : soqlParam1 ';
        if(String.isNotBlank(query)) {
            query = '%' + query + '%';
            queryStr += ' AND Invitee__r.Full_Name__c LIKE :soqlParam2 ';
        }
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        return New Map<Id,Event_Invitee__c> ((List<Event_Invitee__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap));
    }

    public List<Event_Invitee__c> getEventInvitedUsers(List<String> listOfContentIds, Set<String> peopleIds){ 
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', listOfContentIds);
        soqlParamMap.put('soqlParam2', peopleIds);
        String query = ' SELECT Id,Invitee__c,Invited_By__c,Invitation_Status__c,Content__c '
                            + ' FROM Event_Invitee__c '
                            + ' WHERE Content__c IN : soqlParam1 AND Invitee__c IN :soqlParam2';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<Event_Invitee__c> eventIviteeList = (List<Event_Invitee__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        return eventIviteeList;
    }

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Event_RSVP_Response__c getEventRsvpForUser(Id contentId,String peopleId){
        Event_RSVP_Response__c result;
        List<Event_RSVP_Response__c> responseList = [SELECT Id,Content__c,People__c,People__r.Full_Name__c, People__r.User__r.SmallPhotoUrl,People__r.User__r.FullPhotoUrl,
                                                        People__r.Street__c,People__r.City__c,People__r.State__c,
                                                        People__r.Country__c,People__r.Postal_Code__c,People__r.Title__c,
                                                        People__r.Department__c,RSVP_Response__c,RSVP_Response_Text__c
                                                        FROM Event_RSVP_Response__c 
                                                            WHERE Content__c =: contentId
                                                            AND People__c=:peopleId WITH SECURITY_ENFORCED LIMIT 1];
        if(responseList != null && responseList.size() > 0){
            result = responseList.get(0);
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
    public List<Simpplr_Content__c> getEventDatesMap(Integer year, Integer month, String siteId, String filter, String searchTerm) {
                                                                  
        Map<String, Boolean> result = new Map<String, Boolean>();
		String loggedInUserPeopleId = UserContext.peopleId;
		Date todayDate = Date.Today();
		DateTime currentTime = DateTime.now();
		Integer numberOfDays = Date.daysInMonth(year, month);
		DateTime queryStartDateTime = DateTime.newInstance(year,month, 1,0,0,0);
		DateTime queryEndDateTime = DateTime.newInstance(year,month, numberOfDays,23,59,59);
		String status=ServiceConstants.STATUS_APPROVED;
		/*						ES|-----------------------------------------|ED									//Event Range
						QS|----------------|QE																	//Left boundary overlap
																QS|-----------------|QE							//Right boundary overlap
										 QS|-------------------|QE												//query range contained in boundary
					    QS|---------------------------------------------------------|QE							//query range containing boundary 
		*/
		String query = 'SELECT s.Id, s.Event_Start_DateTime__c, s.Event_End_DateTime__c '+
					 ' FROM Simpplr_Content__c s ' +
					 ' WHERE ( ' +
					 '		 (s.Event_Start_DateTime__c >=:queryStartDateTime AND s.Event_Start_DateTime__c <=:queryEndDateTime) OR	' +	//Left boundary overlap
					 '		 (s.Event_End_DateTime__c >=:queryStartDateTime AND s.Event_End_DateTime__c <=:queryEndDateTime) OR ' +			//Right boundary overlap 
					 '		 (s.Event_Start_DateTime__c <=:queryStartDateTime AND s.Event_End_DateTime__c >:queryEndDateTime) OR ' +		//query range contained in boundary 
					 '		 (s.Event_Start_DateTime__c <=:queryStartDateTime AND s.Event_End_DateTime__c <=:queryEndDateTime) ' +			//query range containing boundary 
					 '	     ) '+
					 ' AND Status__c =\'Approved\' AND Type__c =:contentType '+
		             ' AND Is_Published__c = true '+
		             ' AND Is_Deleted__c = false '+
		             ' AND Site__r.Has_Events__c = true '+
		             ' And Site__r.Is_Active__c = true ' + 
					 ' And Site__r.Show_In_Simpplr__c = true ';
		if(String.isNotBlank(siteId)) {
			query += ' AND Site__c =:siteId ';
		} else {
			Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
			query += getFilterCondition(filter,null,false);
		}
		Set<String> setOfSearchTerms = String.isNotBlank(searchTerm) ? Utility.getSearchTokens(String.escapeSingleQuotes(searchTerm)) : null;
		query += getSearchTermCondition(setOfSearchTerms);
		List<Simpplr_Content__c> listOfSimpplrContent = Database.query(query);
		
		return listOfSimpplrContent;  
    }


    public List<Simpplr_Content__c> getEventDataFromSF(List<String> contentIds) {
		
		String query = 'SELECT '+String.join(getContentFieldList(),',')+' FROM Simpplr_Content__c WHERE id = :contentIds';
		
        logger.logDebug('EventDao.getEventDataFromSF----query----'+query);
        return Database.query(query); 
	}
    /****************************************************************************************************************
    //************************************************************************************************
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public List<Simpplr_Content__c> getEventsSearchResults (Criteria.Event eventCriteriaObjArg) {
        String loggedInUserPeopleId = UserContext.peopleId;
        String siteId = eventCriteriaObjArg.siteId;
        String filter = eventCriteriaObjArg.filter;
        String period = eventCriteriaObjArg.period;
        Boolean isPromoted = eventCriteriaObjArg.isPromoted;
        Integer recordLimit = eventCriteriaObjArg.size + 1;
        Integer offset = eventCriteriaObjArg.offset;
        String topicId = eventCriteriaObjArg.topicId;
        DateTime publishStartDateTime = Utility.getDateTimeFilterValue(eventCriteriaObjArg.publishStartDate);
        String author = eventCriteriaObjArg.authoredBy;
        String source = eventCriteriaObjArg.source;
        String sortBy = eventCriteriaObjArg.sortBy;
        String eventDate = eventCriteriaObjArg.eventDate;
        Set<String> contentIdSet = new Set<String>();
        if(eventCriteriaObjArg.contentIdSet!=null && eventCriteriaObjArg.contentIdSet.size()>0){
            contentIdSet.addAll(eventCriteriaObjArg.contentIdSet);
        }
        Set<String> setOfSearchTerms = String.isNotBlank(eventCriteriaObjArg.term) ? Utility.getSearchTokens(String.escapeSingleQuotes(eventCriteriaObjArg.term)) : null;
        String publishStartDateSpan = eventCriteriaObjArg.publishStartDateSpan;

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

        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        DateTime minAllowedEventEndDateTime = getMinAllowedEventEndDateTime(eventDate);
        Set<Id> eventIdSet = new Set<Id>();
        if('all'.equalsIgnoreCase(source) || 'rsvp'.equalsIgnoreCase(source)){
            eventIdSet.addAll(getEventsWithRSVPYes());
        }
        String queryStr = BASE_QUERY;
        if(String.isBlank(topicId) && contentIdSet.size()==0 && !('past'.equalsIgnorecase(filter)) && !('future'.equalsIgnorecase(filter)) && eventCriteriaObjArg.term==null) {
            queryStr += ' And Event_End_DateTime__c >:minAllowedEventEndDateTime ';
        }
        queryStr += getSearchTermCondition(setOfSearchTerms); 
        queryStr += getSourceCondition(source);
        queryStr += getFilterCondition(filter,period,isPromoted);
        queryStr += getTopicCondition(topicId);
        queryStr += getPublishStartDateCondition(publishStartDateTime);
        queryStr += getAuthorCondition(author);
        queryStr += getSiteCondition(siteId);
        queryStr += getIdFilterCondition(contentIdSet);
        queryStr += getSortOrderCondition(sortBy,filter);
        queryStr += getLimitOffsetCondition(recordLimit, offset); 
        return Database.query(queryStr);
	}
	
	/**
     *event
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
	
	private String getSourceCondition(String source){
		String queryStr = '';
		
		if('all'.equalsIgnoreCase(source)){
			queryStr = ' AND (site__r.chatter_group_id__c IN :chatterGroupsIFollowIdSet OR ID IN:eventIdSet)';
		}else if('following'.equalsIgnoreCase(source)){
			queryStr = ' AND site__r.chatter_group_id__c IN :chatterGroupsIFollowIdSet';
		}else if('rsvp'.equalsIgnoreCase(source)){
			queryStr = ' AND ID IN:eventIdSet';
		}
		return queryStr;
	}
	
	private Set<Id> getEventsWithRSVPYes(){
		String currentPeopleId = UserContext.peopleId;
		Set<Id> eventIdSet = new Set<Id>();
			List<Event_RSVP_Response__c> rsvpWithYesResponseList = [select id,Content__c from Event_RSVP_Response__c WHERE (RSVP_Response__c = 'Yes' OR RSVP_Response__c ='Maybe') 
																AND is_deleted__c=false AND People__c=:currentPeopleId 
																AND Content__r.Event_RSVP_Allowed__c = true AND Content__r.Is_published__c = true 
																AND Content__r.Is_Deleted__c = false AND Content__r.Site__r.Is_Active__c = true And Content__r.Site__r.Show_In_Simpplr__c = true WITH SECURITY_ENFORCED];
		for(Event_RSVP_Response__c rsvpResObj : rsvpWithYesResponseList){
			eventIdSet.add(rsvpResObj.Content__c);
		}
		return eventIdSet;
	}
	
	/**
     *
     **/
	private String getfiltercondition(String filter , String period, Boolean isPromoted){
	    String queryStr = '';
	    DateTime currentTime = DateTime.now(); 
		if(String.isNotBlank(filter)){
			if(FILTER_BOOKMARKED.equalsIgnoreCase(filter)){
				queryStr += ' And Id in (Select Simpplr_Content__c from Bookmark__c where ' +
							   ' Type__c =: contentType And People__c =:loggedInUserPeopleId  AND Is_Deleted__c = false) ';
			}else if(FILTER_FOLLOWING.equalsIgnoreCase(filter)){
				contentIdsForFollowingTopics = getContentIdSetForFollowedTopics(ServiceConstants.TYPE_EVENT);
				queryStr += ' And (Site__r.Chatter_Group_Id__c =:chatterGroupsIFollowIdSet ' + 
									' OR Primary_Author__c =:loggedInUserPeopleId' + 
									' OR Id IN :contentIdsForFollowingTopics)';
			}else if(FILTER_FUTURE.equalsIgnoreCase(filter)){
			    Date weekEndDate = (Date.today()).addDays(mapOfDayWithNumberOfDaysToAdd.get(currentTime.format('EEE')));
			    DateTime startDateTimeOfNextWeek = DateTime.newInstance(weekEndDate.addDays(1).year(),weekEndDate.addDays(1).month(),weekEndDate.addDays(1).day(),0,0,0);
			    DateTime nextWeekEndDate = startDateTimeOfNextWeek.addDays(6);
			    DateTime endDateTimeOfNextweek = DateTime.newInstance(startDateTimeOfNextWeek.addDays(6).year(),startDateTimeOfNextWeek.addDays(6).month(),startDateTimeOfNextWeek.addDays(6).day(),23,59,59);
		        if(isPromoted!=null && isPromoted == true){
		        	startTime = currentTime;
		            queryStr +=  ' AND ('+
		            			'Event_Start_DateTime__c >=:startTime OR Event_End_DateTime__c >=:startTime'+
		            			') ';
		        }else{
		            if('this_week'.equalsIgnoreCase(period)){
		                startTime = currentTime;
		                endTime = DateTime.newInstance(weekEndDate.year(),weekEndDate.month(),weekEndDate.day(),23,59,59);
		                queryStr +=  ' AND ('+
		                          '(Event_Start_DateTime__c >=:startTime AND Event_Start_DateTime__c <=:endTime) OR ' +    
		                          '(Event_Start_DateTime__c <=:startTime AND Event_End_DateTime__c >=:startTime)'+
		                          ') ';
		            }else if('next_week'.equalsIgnoreCase(period)){
		                startTime = startDateTimeOfNextWeek;
		                endTime = endDateTimeOfNextweek;
		                queryStr +=  ' AND '+
		                          '(Event_Start_DateTime__c >=:startTime AND Event_Start_DateTime__c <=:endTime) ';
		            }else if('this_month'.equalsIgnoreCase(period)){
		                startTime = DateTime.newInstance(nextWeekEndDate.addDays(1).year(),nextWeekEndDate.addDays(1).month(),nextWeekEndDate.addDays(1).day(),0,0,0);
		                endTime = DateTime.newInstance(currentTime.year(),currentTime.month(),Date.daysInMonth(currentTime.year(),currentTime.month()),23,59,59);
		            	queryStr +=  ' AND '+
		                          '(Event_Start_DateTime__c >=:startTime AND Event_Start_DateTime__c <=:endTime) ';
		            }else if('after_this_month'.equalsIgnoreCase(period)){
		            	Integer year = currentTime.month() == 12 ? currentTime.year()+1 : currentTime.year();
		            	Integer month = currentTime.month() == 12 ? 1 : currentTime.month()+1;
		                startTime = DateTime.newInstance(year,month,1,0,0,0);
		                DateTime startDateAfterNextWeekEndDate = nextWeekEndDate.addDays(1);
		                startTimeForLaterSection = DateTime.newInstance(startDateAfterNextWeekEndDate.year(),startDateAfterNextWeekEndDate.month(),startDateAfterNextWeekEndDate.day(),0,0,0);
		            	queryStr +=  ' AND '+
		                          '(Event_Start_DateTime__c >=:startTime) '+
		                          'AND (Event_Start_DateTime__c >=:startTimeForLaterSection)';
		            } else {
		            	endTime = currentTime;
		            	queryStr +=  ' AND '+
		                          '(Event_End_DateTime__c >:endTime) ';    
		            }
		            
		        }  
			}else if(FILTER_PAST.equalsIgnoreCase(filter)){
				startTime = currentTime;
				queryStr +=  ' AND '+
		                          '(Event_End_DateTime__c <:startTime) ';    
			}
		}
	    return queryStr; 
     }
     
     /**
-     * 
-     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
-     * Parameters:
-     * parameter_name -- [Explanation of the purpose of this parameter to the method.
-     *      
-     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
-    */
    private DateTime getMinAllowedEventEndDateTime(String eventdate) {
    	DateTime minAllowedEventEndDateTime;
    	if(String.isNotBlank(eventDate)) {
			minAllowedEventEndDateTime = DateTime.newInstance(Integer.valueOf(eventDate.left(4)),
													 Integer.valueOf(eventDate.mid(5,2)),
													 Integer.valueOf(eventDate.mid(8,2)), 0, 0, 0);
		} else {
			Date todayDate = Date.today();
			minAllowedEventEndDateTime = DateTime.newInstance(todayDate.year(), 
																 todayDate.month(),
																 todayDate.day());
		}
		return minAllowedEventEndDateTime;
    }
	
	/**
     * event
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
     *event
     **/
    private String getSiteCondition(String siteId){
		String queryStr = '';
		if(String.isNotBlank(siteId)){
			queryStr += ' And site__c=:siteId ';
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
     * event
     **/
	private String getSortOrderCondition(String sortby,String filter){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			if (sortby.equalsIgnoreCase('Latest') ) {
                queryStr += ' Order By Publish_Start_DateTime__c Desc, Last_Updated_DateTime__c desc, Created_DateTime__c desc '; 

            } else if (sortby.equalsIgnoreCase('Liked')) {
                queryStr += ' Order by Likes__c desc, Event_Start_DateTime__c asc '; 
                
            } else if (sortby.equalsIgnoreCase('Viewed')) {
                queryStr += ' Order by Total_View_Count__c desc, Event_Start_DateTime__c asc '; 
                
            }else if(sortby.equalsIgnoreCase('Popular')){
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

            } else if(sortBy.equalsIgnoreCase('eventNewest')) {
                if(FILTER_FUTURE.equalsignorecase(filter)){
                    queryStr += ' Order by Event_Start_DateTime__c asc, Event_End_DateTime__c asc, Last_Updated_DateTime__c desc ';
                }else{
                    queryStr += ' Order by Event_Start_DateTime__c desc, Event_End_DateTime__c desc, Last_Updated_DateTime__c desc ';
                }

			} else if(sortBy.equalsIgnoreCase('eventOldest')) {
                if(FILTER_FUTURE.equalsignorecase(filter)){
				    queryStr += ' Order by Event_End_DateTime__c desc, Event_Start_DateTime__c desc ';
                }else{
                    queryStr += ' Order by Event_End_DateTime__c asc, Event_Start_DateTime__c asc ';
                }

            } 
            
		}else{
			if(FILTER_FUTURE.equalsignorecase(filter)){
				queryStr += ' Order by Event_Start_DateTime__c asc, Event_End_DateTime__c asc ';
			}else if(FILTER_PAST.equalsignorecase(filter)){
				queryStr += ' Order by Event_End_DateTime__c desc, Event_Start_DateTime__c desc ';
			}else{
				queryStr += ' Order by Event_Start_DateTime__c asc ';
			}
		}
        return queryStr;
	}
	
	/**
     * event
     **/
	private String getLimitOffsetCondition(Integer recordLimit, Integer offset){
		String	queryStr = '';
		if(recordLimit!=null && offset!=null) {
			queryStr += ' limit :recordLimit  offset :offset';
		}
		return queryStr;
	}
}