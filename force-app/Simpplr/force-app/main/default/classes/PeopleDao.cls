/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PeopleDao{

	
	private static final Integer EXTERNAL_PHOTO_EXPIRY_DAYS = 15;
	private static String loggedInPeopleId = UserContext.peopleId;
	public String packageName = SimpplrContext.packageName;
	public static String PEOPLE_BASE_QUERY = 'SELECT '+String.join(PeopleListWrapper.getPeopleFieldList(loggedInPeopleId),',')+' FROM People__c ' ;
	private String cityQueryParam;
	private String stateQueryParam;
	private String countryQueryParam;
	private String nameQueryParam;
	private String titleQueryParam;
	private String telephoneQueryParam;
	private Set<String> setOfSearchTerms;
	private String Custom_Field_1;
	private String Custom_Field_2;
	private String Custom_Field_3;
	private String Custom_Field_4;
	private String Custom_Field_5;
	private String Custom_Field_6;
	private String Custom_Field_7;
	private String Custom_Field_8;
	private String custom_field_9;
	private String Custom_Field_10;
	private String Custom_Field_11;
	private String Custom_Field_12;
	private String Custom_Field_13;
	private String Custom_Field_14;
	private String Custom_Field_15;
	private String Custom_Field_16;
	private String Custom_Field_17;
	private String Custom_Field_18;
	private String Custom_Field_19;
	private String Custom_Field_20;
	private String Custom_Field_21;
	private String Custom_Field_22;
	private String Custom_Field_23;
	private String Custom_Field_24;
	private String Custom_Field_25;

	private String myDivision = UserContext.division;
	private String myDepartment = UserContext.getUsersDepartmentDetail;
	private String myCity = UserContext.city;
	private String myState = UserContext.state;

	private String myManagerId = UserContext.manager;
	private List<Id> listOfFollowedUserId = new List<Id>(UserContext.usersIFollowIdSet);
	private List<Must_Read_Confirm_History__c> historyList = new List<Must_Read_Confirm_History__c>();
	public static Integer minDayOfYear=0;
	public static Integer maxDayOfYear=0;
	public static Map<String, String> mapUserIdToPeopleName = new Map<String, String>();

	public final String BASE_QUERY = 'SELECT Id, User__c, Title__c, Street__c, State__c,About__c,Community_Nickname__c, Is_Protected_Author__c, '+
			' Mobile_Phone__c, Department__c, Email__c, Phone__c, Extension__c,Leadership_Sequence__c,Manager__c,Day_Of_Year_J__c,Birth_Date__c, '+
			' Day_Of_Year_B__c, User__r.SmallPhotoURL, User__r.MediumPhotoURL, User__r.FullPhotoURL, Full_Name__c, City__c, Country__c, First_Name__c, Last_Name__c, '+
			' (select id from Bookmark_Receiver_People__r where People__c=:loggedInPeopleId AND Type__c=\'People\' And Is_Deleted__c=false ), ' +
			' (Select connected__c, name from People_Integrations__r where Is_Deleted__c = false),'+
			' (Select Box_Access_Token__c, Feed_Sort_Order__c from Preferences_People__r),'+
			' User__r.Profile.PermissionsManageUnlistedGroups, User__r.Profile.PermissionsChatterOwnGroups,'+
			' User__r.Profile.PermissionsModifyAllData, User__r.Profile.PermissionsModerateChatter,'+
			' App_Moderation_Permission__c, Is_Campaign_Manager__c, Is_Influencer__c, Can_Control_Dashboard__c, Is_Segment_Manager__c, ' +
			' Can_Access_Analytics__c, External_Photo_URL__c, External_Full_Photo_URL__c, Can_Send_Newsletter__c, Can_Send_Alert__c, User__r.TimeZoneSidKey, ' + 
			' Joining_Date__c, User__r.isactive, Company_Name__c, Division__c, Segment__c, Segment__r.Name__c, ' +
			'  Custom_Field_1__c, Custom_Field_2__c, Custom_Field_3__c, Custom_Field_4__c, Custom_Field_5__c, User__r.LanguageLocaleKey, ' +
			'  Custom_Field_6__c, Custom_Field_7__c, Custom_Field_8__c, Custom_Field_9__c, Custom_Field_10__c, ' +
			'  Custom_Field_11__c, Custom_Field_12__c, Custom_Field_13__c, Custom_Field_14__c, Custom_Field_15__c, ' +
			'  Custom_Field_16__c, Custom_Field_17__c, Custom_Field_18__c, Custom_Field_19__c, Custom_Field_20__c, ' +
			'  Custom_Field_21__c, Custom_Field_22__c, Custom_Field_23__c, Custom_Field_24__c, Custom_Field_25__c, ' +
			' Cover_Content_Document_Id__c, Cover_Content_Version_Id__c, Zoom_Id__c, Skype_Id__c, People_Category__c, People_Category__r.Name__c, Microsoft_Teams_User_Name__c, Microsoft_Teams_User_Id__c, Microsoft_Tenant_Id__c, ' +
			' Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c FROM People__c ';
		
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<People__c> getProfileConnectionsFollowing (String categoryId, String departmentArg,
			String locationArg, Integer offset, Integer recordLimit, List <Id> listOfUserId, String sortby,
			List<Id> listOfTopicExpertiseUserId) {
		List<People__c> listOfPeople = new List<People__c>();
		String queryStr = PEOPLE_BASE_QUERY + ' Where User__c=:listOfUserId ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		
		// term will be null as no way to enter term for profile-connections (following)
		queryStr += getFilterCriteria(null, categoryId, departmentArg, locationArg);
		
		if(listOfTopicExpertiseUserId != null) {
			queryStr += ' And User__c=:listOfTopicExpertiseUserId '; 
		}

		if (!'relevance'.equalsIgnoreCase(sortby)) {
	        queryStr += ' Order by createddate desc ';
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
		}

		logger.logDebug('PeopleDao.getProfileConnectionsFollowing() - queryStr '+ queryStr);
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	public List<People__c> getPeopleListBySearchTermAndGroupId(String searchTerm, String chatterGroupId, List<String> peopleIds, Integer recordLimit){
		String SUB_CONDITION = '';
		if(peopleIds != null) {
			SUB_CONDITION += ' Where Id IN: peopleIds ';
		}
		else {
			SUB_CONDITION+= ' Where Full_Name__c Like: searchTerm ';
		}
		SUB_CONDITION += ' AND user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' '+
					+' AND User__c NOT IN (SELECT MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId = : chatterGroupId)';
					
		String LIMIT_CONDITION = '';
		if(recordLimit != null) {
			LIMIT_CONDITION = ' LIMIT ' + recordLimit;
		}

		String queryStr = PEOPLE_BASE_QUERY + SUB_CONDITION + LIMIT_CONDITION;
		logger.logDebug('queryStr' + queryStr); 
		
		List<People__c> peopleList = Database.query(queryStr);		
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	 
	public List<People__c> getPeopleListBySearchTermAndSegmentId(String searchTerm, String segmentId, List<String> peopleIds, Integer recordLimit){
		String SUB_CONDITION = '';
		if(peopleIds != null) {
			SUB_CONDITION +=' Where Id IN: peopleIds ';
		}
		else {
			SUB_CONDITION += ' Where user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' ';
			
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchTerm));
			for(String searchToken:setOfSearchTerms){
				SUB_CONDITION+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		SUB_CONDITION +=' AND Segment__c = :segmentId ';

		String LIMIT_CONDITION = '';
		if(recordLimit != null) {
			LIMIT_CONDITION = ' LIMIT ' + recordLimit;
		}

		String queryStr = PEOPLE_BASE_QUERY + SUB_CONDITION + LIMIT_CONDITION;
		logger.logDebug('queryStr' + queryStr); 
		List<People__c> peopleList = Database.query(queryStr);		
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	public List<People__c> getPeopleListBySearchTerm (String searchTerm, List<String> peopleIds, Integer recordLimit, Integer offset) {
		String queryString;
		if(peopleIds != null) {
			queryString = PEOPLE_BASE_QUERY +' WHERE Id IN : peopleIds ';
		}
		else {
			queryString = PEOPLE_BASE_QUERY +' WHERE user__r.isActive=true ';
			
			if(Utility.isApiOnlyUserQueryable()){
				queryString += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				queryString += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchTerm));
			for(String searchToken:setOfSearchTerms){
				queryString+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}

			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				queryString += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) ';
			}

			if(recordLimit != null) {
				queryString += ' LIMIT ' + recordLimit;
			}
			if(offset != null){
				queryString += ' OFFSET ' + offset;
			}
		}
		logger.logDebug('queryStr' + queryString); 
    	List<People__c> peopleList = Database.query(queryString);
		return (updatePeopleListAccToProfileFields(peopleList));									
												
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<People__c> getProfileConnectionsFollowers (String categoryId, String departmentArg,
			String locationArg, Integer offset, Integer recordLimit, List <Id> listOfUserId, String sortby,
			List<Id> listOfTopicExpertiseUserId) {
		List<People__c> listOfPeople = new List<People__c>();
		String queryStr = PEOPLE_BASE_QUERY + ' Where User__c=:listOfUserId ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			queryStr += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) ';
		}
		
		// term will be null as no way to enter term for profile-connections (followers)
		queryStr += getFilterCriteria(null, categoryId, departmentArg, locationArg);
		
		if(listOfTopicExpertiseUserId != null) {
			queryStr += ' And User__c=:listOfTopicExpertiseUserId '; 
		}
		
		if (!'relevance'.equalsIgnoreCase(sortby)) {
	        queryStr += ' Order by createddate desc ';
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
		}

		logger.logDebug('PeopleDao.getProfileConnectionsFollowers() - queryStr '+ queryStr);
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Id> getUsersFollowingList(String userId){
        List <Id> listOfUsersFollowingId = new List <Id>();
        
        //Limit 1000 is imposed by Salesforce for non-admin users
        String BASE_QUERY_ENTITYSUBSCRIPTION = 'SELECT Id, ParentId FROM EntitySubscription WHERE parent.type=\'User\' AND  isDeleted = false '+
        					'AND ParentID IN (SELECT User__c FROM People__c WHERE User__r.Show_Simpplr__c != \'No\') '+
        					'AND SubscriberId=:userId';
        if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY_ENTITYSUBSCRIPTION+=' And NetworkId = null';
		}
		String SUB_CONDITION = ' Limit 1000';
		String query = BASE_QUERY_ENTITYSUBSCRIPTION + SUB_CONDITION;
		
		List<EntitySubscription> listOfES= new List<EntitySubscription>();
        listOfES = Database.query(query);
        for (EntitySubscription es : listOfES) {
        	listOfUsersFollowingId.add(es.parentId);
        }
        
    	return listOfUsersFollowingId; 
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Id> getUsersFollowerList(String userId){
        List <Id> listOfUsersFollowingId = new List <Id>();
        
        //Limit 1000 is imposed by Salesforce for non-admin users
        String BASE_QUERY_ENTITYSUBSCRIPTION = 'SELECT Id, SubscriberId FROM EntitySubscription WHERE parent.type=\'User\' AND  isDeleted = false '+
        					'AND SubscriberId IN (SELECT User__c FROM People__c WHERE User__r.Show_Simpplr__c != \'No\') '+
        					'AND ParentID=:userId';
        					
        if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY_ENTITYSUBSCRIPTION+=' And NetworkId = null';
		}
		String SUB_CONDITION = ' Limit 1000';
		String query = BASE_QUERY_ENTITYSUBSCRIPTION + SUB_CONDITION;
		
		List<EntitySubscription> listOfES= new List<EntitySubscription>();
        listOfES = Database.query(query);
            	
        for (EntitySubscription es : listOfES) {
        	listOfUsersFollowingId.add(es.SubscriberId);
        }
        
    	return listOfUsersFollowingId; 
    }
	
	public Integer getUserSiteMembersList(String peopleId){
		List<Site_Role__c> siteRoleList = new List<Site_Role__c>();		
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			siteRoleList = [Select id, is_Member__c, people__c, site__c, site__r.Chatter_Group_Id__c from Site_Role__c where people__c =:peopleId and (is_Member__c = true OR Is_Manager__c = true OR Is_Content_Manager__c = true) and Is_Deleted__c=false and site__r.Is_Active__c = true
				AND  User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) AND site__r.Show_In_Simpplr__c = true WITH SECURITY_ENFORCED];
		} else {
			siteRoleList = [Select id, is_Member__c, people__c, site__c, site__r.Chatter_Group_Id__c from Site_Role__c where people__c =:peopleId and (is_Member__c = true OR Is_Manager__c = true OR Is_Content_Manager__c = true) and Is_Deleted__c=false and site__r.Is_Active__c = true
							AND site__r.Show_In_Simpplr__c = true WITH SECURITY_ENFORCED];

		}
		Map<String, String> siteSiteRoleIdsMap = new Map<String, String>();
		for ( Site_Role__c siteRole: siteRoleList){
			siteSiteRoleIdsMap.put(siteRole.site__c, siteRole.id );
		}
		return siteSiteRoleIdsMap.size();
	}

	public Integer getUserSiteFollowersList(String peopleId){
		List<Site_Role__c> siteRoleList = new List<Site_Role__c>();
		
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			siteRoleList = [Select id, is_Member__c, people__c, site__c, site__r.Chatter_Group_Id__c from Site_Role__c where people__c =:peopleId and (is_Member__c = false And Is_Manager__c = false And Is_Content_Manager__c = false) and Is_Deleted__c=false
			AND  User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) WITH SECURITY_ENFORCED];
		} else {
			siteRoleList = [Select id, is_Member__c, people__c, site__c, site__r.Chatter_Group_Id__c from Site_Role__c where people__c =:peopleId and (is_Member__c = false And Is_Manager__c = false And Is_Content_Manager__c = false) and Is_Deleted__c=false WITH SECURITY_ENFORCED];
		}
		Map<String, String> siteSiteRoleIdsMap = new Map<String, String>();
		for ( Site_Role__c siteRole: siteRoleList){
			siteSiteRoleIdsMap.put(siteRole.site__c, siteRole.id );
		}
		return siteSiteRoleIdsMap.size();
	}
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    //TBD
    public List<People__c> getSiteManagers (String term, Integer offset, Integer recordLimit,
    		Set<Id> setOfUserId) {
		List<People__c> listOfPeople = new List<People__c>();
		
		String queryStr = BASE_QUERY + ' Where User__c=:setOfUserId ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				queryStr+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			queryStr += ' order by CreatedDate asc ';
		} else {
			queryStr += ' order by Full_Name__c asc ';
		}
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		
		
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}

	public List<People__c> getSiteMembers (String siteId, Integer offset, Integer recordLimit) {
		List<People__c> listOfPeople = new List<People__c>();
		
		
		Set<Id> userIdSet = new Set<Id>();

		Simpplr_Site__c siteObj = new Simpplr_Site__c();
		siteObj = [Select Id, Site_Type__c, Chatter_Group_Id__c From Simpplr_Site__c Where Id =: siteId  WITH SECURITY_ENFORCED];

		String packageName = SimpplrContext.packageName;
		String chatter_GroupId = siteObj.Chatter_Group_Id__c;
		
		String query ='SELECT Id, CollaborationGroupId, MemberId, CollaborationRole FROM CollaborationGroupMember where collaborationGroupId = :chatter_GroupId  ';
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			query += ' And MemberId in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}
		
		List<CollaborationGroupMember> collaborationGroupMemberList = database.query(query);

		if(siteObj.Site_Type__c == 'Public') {
 
			Set<Id> tempUserIdSet = new Set<Id>();
			for(CollaborationGroupMember collabGroupObj : collaborationGroupMemberList) {
				tempUserIdSet.add(collabGroupObj.MemberId);
			}
			List<Site_Role__c> siteRoleList = new List<Site_Role__c>();
			
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				siteRoleList = [Select People__r.User__c FROM Site_Role__c WHERE (Is_Member__c = true OR Is_Content_Manager__c = true OR Is_Manager__c = true) AND Site__c=:siteId AND People__r.User__c IN :tempUserIdSet AND Is_Deleted__c = false  
				AND  User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) WITH SECURITY_ENFORCED];
			} else {
				siteRoleList = [Select People__r.User__c FROM Site_Role__c WHERE (Is_Member__c = true OR Is_Content_Manager__c = true OR Is_Manager__c = true) AND Site__c=:siteId AND People__r.User__c IN :tempUserIdSet AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
			}
			for(Site_Role__c siteRoleObj : siteRoleList) {
				userIdSet.add(siteRoleObj.People__r.User__c);
			}
		} else {
			for(CollaborationGroupMember collabGroupMemObj : collaborationGroupMemberList) {
				userIdSet.add(collabGroupMemObj.MemberId);
			}
		}

		String queryStr = BASE_QUERY + ' Where User__c IN :userIdSet ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			queryStr += ' order by CreatedDate asc ';
		} else {
			queryStr += ' order by Full_Name__c asc ';
		}
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}

	/*
		@description Use when all the records of People required by API as offset supports upto 2000 records only.
		this is implemented for Newsletter+ unless required for other features.

		Note: no sorting, term search allowed
		@return List<People__c>
	*/
	public List<People__c> getAllSiteMembers (String siteId, String nextPageToken, Integer recordLimit) {
		List<People__c> listOfPeople = new List<People__c>();
		
		
		Set<Id> userIdSet = new Set<Id>();

		Simpplr_Site__c siteObj = new Simpplr_Site__c();
		siteObj = [Select Id, Site_Type__c, Chatter_Group_Id__c From Simpplr_Site__c Where Id =: siteId  WITH SECURITY_ENFORCED];

		String packageName = SimpplrContext.packageName;
		String chatter_GroupId = siteObj.Chatter_Group_Id__c;
		
		String query ='SELECT Id, CollaborationGroupId, MemberId, CollaborationRole FROM CollaborationGroupMember where collaborationGroupId = :chatter_GroupId  ';
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			query += ' And MemberId in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}
		
		List<CollaborationGroupMember> collaborationGroupMemberList = database.query(query);

		if(siteObj.Site_Type__c == 'Public') {
 
			Set<Id> tempUserIdSet = new Set<Id>();
			for(CollaborationGroupMember collabGroupObj : collaborationGroupMemberList) {
				tempUserIdSet.add(collabGroupObj.MemberId);
			}
			List<Site_Role__c> siteRoleList = new List<Site_Role__c>();
			
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				siteRoleList = [Select People__r.User__c FROM Site_Role__c WHERE (Is_Member__c = true OR Is_Content_Manager__c = true OR Is_Manager__c = true) AND Site__c=:siteId AND People__r.User__c IN :tempUserIdSet AND Is_Deleted__c = false  
				AND  User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) WITH SECURITY_ENFORCED];
			} else {
				siteRoleList = [Select People__r.User__c FROM Site_Role__c WHERE (Is_Member__c = true OR Is_Content_Manager__c = true OR Is_Manager__c = true) AND Site__c=:siteId AND People__r.User__c IN :tempUserIdSet AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
			}
			for(Site_Role__c siteRoleObj : siteRoleList) {
				userIdSet.add(siteRoleObj.People__r.User__c);
			}
		} else {
			for(CollaborationGroupMember collabGroupMemObj : collaborationGroupMemberList) {
				userIdSet.add(collabGroupMemObj.MemberId);
			}
		}

		String queryStr = BASE_QUERY + ' Where User__c IN :userIdSet ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		
		if(String.isNotBlank(nextPageToken)){
			queryStr += ' AND Id > :nextPageToken ';
		}
		
		queryStr += ' ORDER BY Id ASC ';

		queryStr += ' limit ' + recordLimit;
		
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}

	public List<People__c> getSiteFollowers (String siteId, Integer offset, Integer recordLimit) {
		List<People__c> listOfPeople = new List<People__c>();
		
		
		Set<Id> userIdSet = new Set<Id>();
		Set<Id> userIdSetFollowers = new Set<Id>();

		Set<Id> siteMemberIdSet = new Set<Id>();

		Simpplr_Site__c siteObj = new Simpplr_Site__c();
		siteObj = [Select Id, Chatter_Group_Id__c From Simpplr_Site__c Where Id =: siteId];
		
		String packageName = SimpplrContext.packageName;
		id chatter_GroupId = siteObj.Chatter_Group_Id__c;
		String query ='SELECT Id, CollaborationGroupId, MemberId, CollaborationRole FROM CollaborationGroupMember where CollaborationRole != \'Admin\' AND collaborationGroupId =: chatter_GroupId ';

		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			query += ' And MemberId in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}
		List<CollaborationGroupMember> collaborationGroupMemberList = Database.query(query);

		for(CollaborationGroupMember collabGroupMemObj : collaborationGroupMemberList) {
			userIdSet.add(collabGroupMemObj.MemberId);
		}

		List<Site_Role__c> siteRoleList = new List<Site_Role__c>();
		
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			siteRoleList = [Select People__r.User__c FROM Site_Role__c WHERE (Is_Member__c = true OR Is_Content_Manager__c = true OR Is_Manager__c = true) AND Site__c=:siteId AND Is_Deleted__c = false  
			AND  User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)];
		} else {
			siteRoleList = [Select People__r.User__c FROM Site_Role__c WHERE (Is_Member__c = true OR Is_Content_Manager__c = true OR Is_Manager__c = true) AND Site__c=:siteId AND Is_Deleted__c = false];
		}
		for(Site_Role__c siteRoleObj : siteRoleList) {
			siteMemberIdSet.add(siteRoleObj.People__r.User__c);
		}

		for(Id idObj : userIdSet) {
			if(siteMemberIdSet.contains(idObj)) {
				//Do Nothing
			} else {
				userIdSetFollowers.add(idObj);
			}
		}

		String queryStr = BASE_QUERY + ' Where User__c IN :userIdSetFollowers ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			queryStr += ' order by CreatedDate asc ';
		} else {
			queryStr += ' order by Full_Name__c asc ';
		}
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	//TBD
	public List<People__c> getSitesMembersEveryone (String term, Integer offset, Integer recordLimit, String sortBy,
			Set<Id> setOfUserId) {
		List<People__c> listOfPeople = new List<People__c>();
		Date maxJoiningDate = Date.today();

		String queryStr = BASE_QUERY + ' Where User__c=:setOfUserId ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				queryStr+=' ANd Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		if ('hire_date'.equalsIgnoreCase(sortBy)) {
				queryStr += ' And Joining_Date__c <=:maxJoiningDate ';
        		queryStr += ' Order by Joining_Date__c desc NULLS LAST';   
				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					queryStr += ', CreatedDate asc ';
				} else {
					queryStr += ', Full_Name__c Asc ';
				}

		} else if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			queryStr += ' order by CreatedDate asc ';

		} else {
			queryStr += ' order by Full_Name__c asc ';
		}
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		
		
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}

	/*
		@description Use when all the records of People required by API as offset supports upto 2000 records only.
		this is implemented for Newsletter+ unless required for other features.

		Note: no sorting, term search allowed
		@return List<People__c>
	*/
	public List<People__c> getAllSitesMembersFollowers (String nextPageToken, Integer recordLimit, Set<Id> setOfUserId) {
		List<People__c> listOfPeople = new List<People__c>();
		Date maxJoiningDate = Date.today();

		String queryStr = BASE_QUERY + ' Where User__c=:setOfUserId ';
		
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}

		if(String.isNotBlank(nextPageToken)){
			queryStr += ' AND Id > :nextPageToken ';
		}

		queryStr += ' ORDER BY Id ASC ';

		queryStr += ' limit ' + recordLimit;
		
		
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	private list<People__c> updatePeopleListAccToProfileFields(List<People__c> pplList){
			for(People__c peopleObj : pplList){
				if(SimpplrContext.isPPTitleDisplay == false){
					peopleObj.Title__c = null;
				}
				if(SimpplrContext.isPPDepartmentDisplay == false){
					peopleObj.Department__c = null;
				}
				if(SimpplrContext.isPPCityDisplay == false){
					peopleObj.City__c = null;
				}
				if(SimpplrContext.isPPStateDisplay == false){
					peopleObj.State__c = null;
				}
				if(SimpplrContext.isPPCountryDisplay == false){
					peopleObj.Country__c = null;
				}
				if(SimpplrContext.isPPFirstNameDisplay == false){
					peopleObj.First_Name__c = null;
				}
				if(SimpplrContext.isPPLastNameDisplay == false){
					peopleObj.Last_Name__c = null;
				}
				if(SimpplrContext.isPPPhoneDisplay == false){
					peopleObj.Phone__c = null;
				}
				if(SimpplrContext.isPPExtensionDisplay == false){
					peopleObj.extension__c = null;
				}
				if(SimpplrContext.isPPMobilePhoneDisplay == false){
					peopleObj.Mobile_Phone__c = null;
				}
			}
			
		return pplList;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private String getFilterCriteria(String term, String categoryId, String departmentArg, String locationArg) {
		String filterCriteria = '';
        if(String.isNotBlank(categoryId)) {
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				filterCriteria += ' AND People_Category__c = null ';
			} else if(!'all'.equalsIgnoreCase(categoryId)){
				filterCriteria += ' AND People_Category__c =:categoryId ';
			}
        }
        
        if(String.isNotBlank(departmentArg) && !'all'.equalsIgnoreCase(departmentArg)) {
        	filterCriteria += ' AND Department__c =:departmentArg ';
        }
        
		if(String.isNotBlank(locationArg) ){
			cityQueryParam = locationArg.SubString(0,(locationArg.indexOf('@@')-1));
			stateQueryParam = locationArg.SubString((locationArg.indexOf('@@') + 3),(locationArg.lastIndexOf('@@')-1));
			countryQueryParam = locationArg.SubString((locationArg.lastIndexOf('@@') + 3),locationArg.length());

			filterCriteria += (cityQueryParam == 'null' ? '' : ' AND City__c =:cityQueryParam ');
			filterCriteria += (stateQueryParam == 'null' ? '' : ' AND State__c =:stateQueryParam ');
			filterCriteria += (countryQueryParam == 'null' ? '' : ' AND Country__c =:countryQueryParam ');
		}
        
		if(String.isNotBlank(term) && !SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				filterCriteria+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		
		return filterCriteria;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<String> getExpertises(String searchText) {
		List<String> listOfExpertiseIds = new List<String>();
		String BASE_QUERY= 'SELECT Id FROM Expertise__c';
		String WHERE_CONDITION = ' WHERE Name__c = :searchText';
		
		String queryStr = BASE_QUERY + WHERE_CONDITION;	
		
		//Exact matched expertise
		List<Expertise__c> expertiseList = new List<Expertise__c>();
		expertiseList = Database.query(queryStr);
		Integer recordLimit = 3 - expertiseList.size();

		//Partial match if no result found
		if(expertiseList.isEmpty()) {
			searchText = '%' + searchText + '%';
			queryStr = queryStr + ' LIMIT :recordLimit';
			expertiseList = Database.query(queryStr);
		}
		 
		for(Expertise__c expertiseObj : expertiseList) {
			listOfExpertiseIds.add(expertiseObj.id);
		}
		return listOfExpertiseIds;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	@future
    public static void insertPeopleInFuture(String listOfUsersJson) {
    	List<User> listOfUsers = (List<User>)JSON.deserialize(listOfUsersJson, List<User>.class);
    	List<User> listOfNewUsers = new List<User>(); 
    	Map<String, String> mapOfUserIdAndManagersId = new Map<String, String>();
    	Map<Id, User> usersWithoutPeopleMap = new Map<Id, User>([select id from User where id=: listOfUsers And id not in (select user__c from people__c where user__c=:listOfUsers) WITH SECURITY_ENFORCED]);
    	for(User userObj : listOfUsers) {
    		if((userObj.IsActive == true && 'Standard'.equalsIgnoreCase(userObj.usertype)) || ('Yes'.equalsIgnoreCase(userObj.Show_Simpplr__c))) {
	    		if(usersWithoutPeopleMap.containsKey(userObj.id)) {
		    		mapOfUserIdAndManagersId.put(userObj.Id, userObj.ManagerId);
	    			listOfNewUsers.add(userObj);
	    		}
    		}
    	}
    	PeopleDao peopleDaoObj = new PeopleDao();
    	List<People__c> listOfPeople = peopleDaoObj.insertPeople(listOfNewUsers);
    	peopleDaoObj.updateManagerInfo(listOfPeople, mapOfUserIdAndManagersId);
		peopleDaoObj.insertPeoplePreference(listOfPeople);

    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void insertPeopleInRealtime(List<User> listOfUsers) {
    	Map<String, String> mapOfUserIdAndManagersId = new Map<String, String>();
        List<Id> listOfStandardUsers = new List<Id>();
    	for(User userObj : listOfUsers) {
    		mapOfUserIdAndManagersId.put(userObj.Id, userObj.ManagerId);
            if(userObj.UserType == 'Standard') {
                listOfStandardUsers.add(userObj.Id);
            }
    	}
    	PeopleDao peopleDaoObj = new PeopleDao();
    	List<People__c> listOfPeople = peopleDaoObj.insertPeople(listOfUsers);
    	peopleDaoObj.updateManagerInfo(listOfPeople, mapOfUserIdAndManagersId);
		peopleDaoObj.insertPeoplePreference(listOfPeople);
        AutoProvisionUser.autoProvision(listOfStandardUsers);
    }
    
    public void autoCreatePeopleOnFirstLogin() {
    		List<User> listOfFetchedUsers = [SELECT AboutMe,City,CommunityNickname,CompanyName,Country,Department,Division,
    										 Email,EmployeeNumber,Extension,Fax,FirstName,LastName,ManagerId,MobilePhone,
    										 Phone,PostalCode,State,Street,Title, isActive, UserType, Show_Simpplr__c,
    										 CreatedDate from User where id=:UserInfo.getUserId() And  id not in (select user__c from People__c) WITH SECURITY_ENFORCED];
    		if(listOfFetchedUsers.isEmpty() == false) {
    			List<People__c> insertedPeopleList = insertPeople(listOfFetchedUsers);
    			if(insertedPeopleList.isEmpty() == false && String.isNotBlank(listOfFetchedUsers[0].ManagerId)) {
    				List<People__c> listOfPeople = [select id From People__c where User__c=:listOfFetchedUsers[0].ManagerId And User__r.UserType='Standard'];
    				if(listOfPeople.isEmpty() == false) {
    					People__c peopleObj = new People__c(Id=insertedPeopleList[0].id, Manager__c=listOfPeople[0].Id);

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(peopleObj, new List<Schema.SObjectField>{
							People__c.Manager__c
						});
    				}
    			}
    			insertPeoplePreference(insertedPeopleList);

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
    public List<People__c> insertPeople(List<User> listOfUsers) {
    	List<People__c> listOfPople = new List<People__c>();
		Set<String> userFieldSet = getUserFields();
		Boolean isBirthDateExists = false;
		Boolean isJoiningDateExists = false;
		if(userFieldSet.contains('Birth_Date__c')){
			isBirthDateExists = true;
		}
		if(userFieldSet.contains('Joining_Date__c')){
			isJoiningDateExists = true;
		}

		for(User userObj : listOfUsers) {
			if((userObj.IsActive == true && 'Standard'.equalsIgnoreCase(userObj.usertype)) || ('Yes'.equalsIgnoreCase(userObj.Show_Simpplr__c))){
				People__c peopleObj = new People__c();
				
				peopleObj.User__c = userObj.id;
				peopleObj.User_id__c = userObj.id;
				peopleObj.User_Hash__c = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-512', Blob.valueOf(peopleObj.user__c)));
				peopleObj.User_Created_DateTime__c = userObj.CreatedDate;
				peopleObj.Is_First_Login__c = true;
				
				if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)) {
					peopleObj.About__c = userObj.AboutMe__c;					
					peopleObj.City__c = userObj.City__c;
					peopleObj.Community_Nickname__c = userObj.CommunityNickname__c;
					peopleObj.Company_Name__c = userObj.CompanyName__c;
					peopleObj.Country__c = userObj.Country__c;
					peopleObj.Department__c = userObj.Department__c;
					peopleObj.Division__c = userObj.Division__c;
					peopleObj.Email__c = userObj.Email__c;
					peopleObj.Employee_Number__c = userObj.EmployeeNumber__c;
					peopleObj.Extension__c = userObj.Extension__c;
					peopleObj.Fax__c = userObj.Fax__c;
					peopleObj.First_Name__c = userObj.FirstName__c;
					peopleObj.Last_Name__c = userObj.LastName__c;
					peopleObj.Mobile_Phone__c = userObj.MobilePhone__c;
					peopleObj.Phone__c = userObj.Phone__c;
					peopleObj.Postal_Code__c = userObj.PostalCode__c;
					peopleObj.State__c = userObj.State__c;
					peopleObj.Street__c = userObj.Street__c;
					peopleObj.Title__c = userObj.Title__c;
				} else {
					peopleObj.About__c = userObj.AboutMe;					
					peopleObj.City__c = userObj.City;
					peopleObj.Community_Nickname__c = userObj.CommunityNickname;
					peopleObj.Company_Name__c = userObj.CompanyName;
					peopleObj.Country__c = userObj.Country;
					peopleObj.Department__c = userObj.Department;
					peopleObj.Division__c = userObj.Division;
					peopleObj.Email__c = userObj.Email;
					peopleObj.Employee_Number__c = userObj.EmployeeNumber;
					peopleObj.Extension__c = userObj.Extension;
					peopleObj.Fax__c = userObj.Fax;
					peopleObj.First_Name__c = userObj.FirstName;
					peopleObj.Last_Name__c = userObj.LastName;
					peopleObj.Mobile_Phone__c = userObj.MobilePhone;
					peopleObj.Phone__c = userObj.Phone;
					peopleObj.Postal_Code__c = userObj.PostalCode;
					peopleObj.State__c = userObj.State;
					peopleObj.Street__c = userObj.Street;
					peopleObj.Title__c = userObj.Title;
				}


	    		peopleObj.App_Moderation_Permission__c = 'No';
	    		peopleObj.Last_Edited_DateTime__c = DateTime.now();
				peopleObj.OwnerId = userObj.id;

				if(isBirthDateExists){
					peopleObj.Birth_Date__c = (Date) userObj.get('Birth_Date__c');
				}
				if(isJoiningDateExists){
					peopleObj.Joining_Date__c = (Date) userObj.get('Joining_Date__c');
				}
				
				listOfPople.add(peopleObj);
			}
		} 
		if(listOfPople.size() > 0) {
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listOfPople,new List<Schema.SObjectField>{
																People__c.User__c,
																People__c.User_Id__c,
																People__c.User_Hash__c,
																People__c.User_Created_DateTime__c,
																People__c.Is_First_Login__c,
																People__c.About__c,
																People__c.City__c,
																People__c.Community_Nickname__c,
																People__c.Company_Name__c,
																People__c.Country__c,
																People__c.Department__c,
																People__c.Division__c,
																People__c.Email__c,
																People__c.Employee_Number__c,
																People__c.Extension__c,
																People__c.Fax__c,
																People__c.First_Name__c,
																People__c.Last_Name__c,
																People__c.Mobile_Phone__c,
																People__c.Phone__c,
																People__c.Postal_Code__c,
																People__c.State__c,
																People__c.Street__c,
																People__c.Last_Edited_DateTime__c,
																People__c.App_Moderation_Permission__c,
																People__c.Title__c,
																People__c.Birth_Date__c,
																People__c.Joining_Date__c,
																People__c.OwnerId});
			listOfPople = result.getInsertedObjects();
		}
		return listOfPople;
    }

	private Set<String> getUserFields () {
        Set<String> userFieldsSet = new Set<String>();
		List<Schema.SObjectField> userFieldsSchema = User.getSObjectType().getDescribe().fields.getMap().values();
		for(Schema.SObjectField field : userFieldsSchema){
            userFieldsSet.add(field + '');
        }

		return userFieldsSet;          
	}
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void insertPeoplePreference(List<People__c> listOfPeople) {
		List<People__c> peopleList = [SELECT Id, User__c, Segment__c FROM People__c WHERE Id IN :listOfPeople WITH SECURITY_ENFORCED];
		List<People_Preference__c> listOfPeoplePreference = new List<People_Preference__c>();
    	try {
			List<String> recordTypesList = new List<String>{'sms_notifications', 'email_notifications', 'native_mobile_notifications','browser_notifications','summaries_and_digest' , 'home-feed', 'home-default'};
			
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', recordTypesList);
			String query = 'SELECT Id, Type__c, Data__c, Layout__c, Segment__c FROM App_Default__c where Type__c = :soqlParam1 ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

			App_Default__c appDefaultSMS;
			App_Default__c appDefaultEmail;
			App_Default__c appDefaultMobile;
			App_Default__c appDefaultBrowser;
			App_Default__c appDefaultSummariesAndDigest;
            App_Default__c appDefaultHomeFeed;
            App_Default__c appDefaultHomeDefault;
            Map<Id, App_Default__c> mapOfSegmentToAppHomeDefault = new Map<Id, App_Default__c>();
            
			for(App_Default__c appDefaultObj : appDefaultList) {
				if('sms_notifications'.equalsIgnoreCase(appDefaultObj.Type__c)) {
					appDefaultSMS = appDefaultObj;
				} else if('email_notifications'.equalsIgnoreCase(appDefaultObj.Type__c)) {
					appDefaultEmail = appDefaultObj;
				} else if('native_mobile_notifications'.equalsIgnoreCase(appDefaultObj.Type__c)) {
					appDefaultMobile = appDefaultObj;
				} else if('browser_notifications'.equalsIgnoreCase(appDefaultObj.Type__c)) {
					appDefaultBrowser = appDefaultObj;
				} else if('summaries_and_digest'.equalsIgnoreCase(appDefaultObj.Type__c)) {
					appDefaultSummariesAndDigest = appDefaultObj;
				} else if('home-feed'.equalsIgnoreCase(appDefaultObj.Type__c)) {
					appDefaultHomeFeed = appDefaultObj;
				} else if('home-default'.equalsIgnoreCase(appDefaultObj.Type__c) && appDefaultObj.Segment__c != null) {
					mapOfSegmentToAppHomeDefault.put(appDefaultObj.Segment__c, appDefaultObj);
				} else if('home-default'.equalsIgnoreCase(appDefaultObj.Type__c)) {
					appDefaultHomeDefault = appDefaultObj;
				}
			}

			PostInstallHelper piHelper = new PostInstallHelper();
			//sms
			ManageApplicationWrapper.SMSNotificationWrapper smsWrapper;
			if(appDefaultSMS != null && String.isNotBlank(appDefaultSMS.Data__c)){
				smsWrapper = (ManageApplicationWrapper.SMSNotificationWrapper) JSON.deserialize(appDefaultSMS.Data__c, ManageApplicationWrapper.SMSNotificationWrapper.class);
			} else {
				smsWrapper = piHelper.getDefaultSMSNotificationSettings();
			}

			//email
			ManageApplicationWrapper.EmailNotificationWrapper defaultEmailNotificationWrapper = new ManageApplicationWrapper.EmailNotificationWrapper();
			if(appDefaultEmail != null && String.isNotBlank(appDefaultEmail.Data__c)){
				defaultEmailNotificationWrapper = (ManageApplicationWrapper.EmailNotificationWrapper)JSON.deserialize(appDefaultEmail.Data__c,ManageApplicationWrapper.EmailNotificationWrapper.class);		
    		} else{
				defaultEmailNotificationWrapper = piHelper.getDefaultEmailNotificationsSettings();    			
			}
			
			//mobile
			ManageApplicationWrapper.MobileAppNotificationWrapper mobileWrapper;
			if(appDefaultMobile != null && String.isNotBlank(appDefaultMobile.Data__c)){
				mobileWrapper = (ManageApplicationWrapper.MobileAppNotificationWrapper) JSON.deserialize(appDefaultMobile.Data__c, ManageApplicationWrapper.MobileAppNotificationWrapper.class);
			} else{				
				mobileWrapper = piHelper.getDefaultMobileAppNotificationSettings();    			
			}
			
			//browser
			ManageApplicationWrapper.BrowserNotificationWrapper browserWrapper;
			if(appDefaultBrowser != null && String.isNotBlank(appDefaultBrowser.Data__c)){
				browserWrapper = (ManageApplicationWrapper.BrowserNotificationWrapper) JSON.deserialize(appDefaultBrowser.Data__c, ManageApplicationWrapper.BrowserNotificationWrapper.class);
            } else {
				browserWrapper = piHelper.getDefaultBrowserNotificationSettings();
			}
            
            //SummariesAndDigest
			ManageApplicationWrapper.SummariesAndDigestWrapper summariesAndDigestWrapper;
			if(appDefaultSummariesAndDigest != null && String.isNotBlank(appDefaultSummariesAndDigest.Data__c)){
				summariesAndDigestWrapper = (ManageApplicationWrapper.SummariesAndDigestWrapper) JSON.deserialize(appDefaultSummariesAndDigest.Data__c, ManageApplicationWrapper.SummariesAndDigestWrapper.class);
			} else {
				summariesAndDigestWrapper = piHelper.getDefaultSummariesAndDigestSettings();
			}
			
			//feed
    		ManageApplicationWrapper.DefaultFeedSettingsWrapper feedWrapper;
    		if(appDefaultHomeFeed != null && String.isNotBlank(appDefaultHomeFeed.Data__c)){
    			feedWrapper =  (ManageApplicationWrapper.DefaultFeedSettingsWrapper) JSON.deserialize(appDefaultHomeFeed.Data__c, ManageApplicationWrapper.DefaultFeedSettingsWrapper.class);
            } else {
				feedWrapper = piHelper.getDefaultFeedSettings();
			}
            
    		for(People__c peopleObj : peopleList) { 
    			People_Preference__c peoplePrefObj = new People_Preference__c();
    			peoplePrefObj.People__c = peopleObj.id;
    			peoplePrefObj.User__c = peopleObj.user__c;
				peoplePrefObj.OwnerId = peopleObj.user__c;
				App_Default__c appDefault = mapOfSegmentToAppHomeDefault.containsKey(peopleObj.Segment__c) ?
					mapOfSegmentToAppHomeDefault.get(peopleObj.Segment__c) : appDefaultHomeDefault;
				if(appDefault != null && appDefault.Layout__c != null) {
					peoplePrefObj.Layout__c = appDefaultHomeDefault.Layout__c;
				}
				
				//feed
				if(feedWrapper != null){
    				peoplePrefObj.Feed_Type__c = feedWrapper.feedSetting;
    				peoplePrefObj.Feed_Sort_Order__c = feedWrapper.feedFilter;
    			}else{
    				peoplePrefObj.Feed_Type__c = 'news';
    				peoplePrefObj.Feed_Sort_Order__c = 'activity';
				}
				
				//sms
				peoplePrefObj.SMS_Alerts__c = smsWrapper.smsAlerts;
				peoplePrefObj.SMS_Must_Reads__c = smsWrapper.smsContentMarkedAsMustRead;
				peoplePrefObj.SMS_Content_Promotion_Message__c = smsWrapper.smsContentPromotionMessage;

				//email
				peoplePrefObj.Allow_Simpplr_Emails__c = true;
				peoplePrefObj.Email_Alerts__c = defaultEmailNotificationWrapper.emailAlerts == null ? true : defaultEmailNotificationWrapper.emailAlerts;
				peoplePrefObj.Email_Content_Marked_As_Must_Read__c = defaultEmailNotificationWrapper.emailContentMarkedAsMustRead == null ? true : defaultEmailNotificationWrapper.emailContentMarkedAsMustRead;
				peoplePrefObj.Email_Updates_Content_Sites_I_Follow__c = defaultEmailNotificationWrapper.emailUpdatesContentSitesFollow == null ? false : defaultEmailNotificationWrapper.emailUpdatesContentSitesFollow;
				peoplePrefObj.Email_Event_Invite_More__c  = defaultEmailNotificationWrapper.emailEventInviteMore == null ? false : defaultEmailNotificationWrapper.emailEventInviteMore;
				peoplePrefObj.Email_Updates_Event_I_RSVP_Yes__c = defaultEmailNotificationWrapper.emailUpdatesEventIRsvpYes == null ? true : defaultEmailNotificationWrapper.emailUpdatesEventIRsvpYes;
				peoplePrefObj.Email_Updates_Event_I_Author_Organize__c = defaultEmailNotificationWrapper.emailUpdatesEventIAuthorOrganize == null ? true : defaultEmailNotificationWrapper.emailUpdatesEventIAuthorOrganize;
				peoplePrefObj.Email_Notification_Digest_Frequency__c  =  defaultEmailNotificationWrapper.emailNotificationFrequency;
				peoplePrefObj.Email_Follows_Me__c  = defaultEmailNotificationWrapper.emailFollowsMe == null ? false : defaultEmailNotificationWrapper.emailFollowsMe;
				peoplePrefObj.Email_Endorses_Me__c  = defaultEmailNotificationWrapper.emailEndorseExpertise == null ? false : defaultEmailNotificationWrapper.emailEndorseExpertise;
				peoplePrefObj.Email_Like_My_Post_Or_Comment__c  = defaultEmailNotificationWrapper.emailLikesPostOrCommentMade == null ? false : defaultEmailNotificationWrapper.emailLikesPostOrCommentMade;
				peoplePrefObj.Email_Comments_On_My_Post__c  = defaultEmailNotificationWrapper.emailCommentsPostMade == null ? false : defaultEmailNotificationWrapper.emailCommentsPostMade; 
				peoplePrefObj.Email_Comments_After_Me__c  = defaultEmailNotificationWrapper.emailCommentsAfterMe == null ? false : defaultEmailNotificationWrapper.emailCommentsAfterMe;
				peoplePrefObj.Email_Comments_On_Post_I_Like__c  = defaultEmailNotificationWrapper.emailCommentsPostLike == null ? false : defaultEmailNotificationWrapper.emailCommentsPostLike; 
				peoplePrefObj.Email_Posts_To_Me__c  = defaultEmailNotificationWrapper.emailPostsToMe == null ? false : defaultEmailNotificationWrapper.emailPostsToMe;
				peoplePrefObj.Email_Shares_My_Post__c  = defaultEmailNotificationWrapper.emailSharesPostMade == null ? false : defaultEmailNotificationWrapper.emailSharesPostMade;
				peoplePrefObj.Email_My_Content_Post__c  = defaultEmailNotificationWrapper.emailCommentsContentPublished == null ? false : defaultEmailNotificationWrapper.emailCommentsContentPublished; 
				peoplePrefObj.Email_My_Content_Like_Or_Share__c  = defaultEmailNotificationWrapper.emailLikesSharesContentPublished == null ? false : defaultEmailNotificationWrapper.emailLikesSharesContentPublished;
				peoplePrefObj.Email_Content_Submission_Response__c = defaultEmailNotificationWrapper.emailContentSubmissionResponse == null ? false : defaultEmailNotificationWrapper.emailContentSubmissionResponse;
				peoplePrefObj.Email_My_Content_Rejected__c  = defaultEmailNotificationWrapper.emailContentSubmissionResponse == null ? false : defaultEmailNotificationWrapper.emailContentSubmissionResponse;
				peoplePrefObj.Email_My_Content_Approved__c  = defaultEmailNotificationWrapper.emailContentSubmissionResponse == null ? false : defaultEmailNotificationWrapper.emailContentSubmissionResponse;
				peoplePrefObj.Email_My_Content_Validation_Required__c  = defaultEmailNotificationWrapper.emailKnowledgeReview == null ? false : defaultEmailNotificationWrapper.emailKnowledgeReview;
				peoplePrefObj.Email_My_Content_Validation_Expired__c  = defaultEmailNotificationWrapper.emailKnowledgeExpired == null ? false : defaultEmailNotificationWrapper.emailKnowledgeExpired;
				peoplePrefObj.Email_PrivateSiteMembership_Response__c = defaultEmailNotificationWrapper.emailPrivateSiteMembershipResponse == null ? false : defaultEmailNotificationWrapper.emailPrivateSiteMembershipResponse;				
				peoplePrefObj.Email_Content_Useful__c  = defaultEmailNotificationWrapper.emailForContentUseful == null ? false : defaultEmailNotificationWrapper.emailForContentUseful;			
				peoplePrefObj.Receive_Content_Moderation_Notifications__c = defaultEmailNotificationWrapper.emailSiteActionableForAppMgr == null ? true : defaultEmailNotificationWrapper.emailSiteActionableForAppMgr;
                peoplePrefObj.Receive_Content_Update_Notifications__c = defaultEmailNotificationWrapper.emailContentPromotionMessageForAppMgr == null ? true : defaultEmailNotificationWrapper.emailContentPromotionMessageForAppMgr;
                peoplePrefObj.Receive_Content_Useful_Notifications__c = defaultEmailNotificationWrapper.emailForContentUsefulAppMgr == null ? true : defaultEmailNotificationWrapper.emailForContentUsefulAppMgr;
				peoplePrefObj.Email_Private_Site_Membership_Requests__c = defaultEmailNotificationWrapper.emailPrivateSiteMembershipRequest == null ? false : defaultEmailNotificationWrapper.emailPrivateSiteMembershipRequest;
        		peoplePrefObj.Email_Content_Submitted_For_Moderation__c = defaultEmailNotificationWrapper.emailContentSubmittedForModeration == null ? false : defaultEmailNotificationWrapper.emailContentSubmittedForModeration;
				peoplePrefObj.Email_Subscription_Request__c = defaultEmailNotificationWrapper.emailSubscriptionRequest == null ? false : defaultEmailNotificationWrapper.emailSubscriptionRequest;
				peoplePrefObj.Email_Subscription_Moderation__c = defaultEmailNotificationWrapper.emailSubscriptionModeration == null ? false : defaultEmailNotificationWrapper.emailSubscriptionModeration;

                //mobile
				peoplePrefObj.Native_Mob_Content_Marked_As_Must_Read__c = mobileWrapper.mobileAppContentMarkedAsMustRead == null ? true : mobileWrapper.mobileAppContentMarkedAsMustRead;
				peoplePrefObj.Native_Mobile_Alerts__c = mobileWrapper.mobileAppAlerts == null ? true : mobileWrapper.mobileAppAlerts;
				peoplePrefObj.Native_Mob_Update_Content_Site_I_Follow__c = mobileWrapper.mobileAppUpdatesContentSitesFollow == null ? true : mobileWrapper.mobileAppUpdatesContentSitesFollow;

				peoplePrefObj.Native_Mobile_Follows_Me__c = mobileWrapper.mobileAppFollowsMe == null ? true : mobileWrapper.mobileAppFollowsMe;
				peoplePrefObj.Native_Mob_Endorse_Expertise__c = mobileWrapper.mobileAppEndorseExpertise == null ? true : mobileWrapper.mobileAppEndorseExpertise;
				
				peoplePrefObj.Native_Mob_Comments_On_My_Post__c = mobileWrapper.mobileAppCommentsPostMade == null ? true : mobileWrapper.mobileAppCommentsPostMade;
				peoplePrefObj.Native_Mob_Reply_After_Me__c = mobileWrapper.mobileAppReplyAfterMe == null ? true : mobileWrapper.mobileAppReplyAfterMe;
				peoplePrefObj.Native_Mob_Replied_On_liked_Post__c = mobileWrapper.mobileAppReplyOnLikedPost == null ? true : mobileWrapper.mobileAppReplyOnLikedPost;
				peoplePrefObj.Native_Mob_Like_My_Post_Or_Comment__c = mobileWrapper.mobileAppLikesPostOrCommentMade == null ? true : mobileWrapper.mobileAppLikesPostOrCommentMade;
				peoplePrefObj.Native_Mob_Shares_My_Post__c = mobileWrapper.mobileAppSharesMyPost == null ? true : mobileWrapper.mobileAppSharesMyPost;
				peoplePrefObj.Native_Mob_Posts_To_Me__c = mobileWrapper.mobileAppPostsToMe == null ? true : mobileWrapper.mobileAppPostsToMe;
				
				peoplePrefObj.Native_MobPrivateSiteMembership_Resp__c = mobileWrapper.mobileAppPrivateSiteMembershipResponse == null ? true : mobileWrapper.mobileAppPrivateSiteMembershipResponse;

				peoplePrefObj.Native_Mob_My_Content_Post__c = mobileWrapper.mobileAppCommentsContentPublished == null ? true : mobileWrapper.mobileAppCommentsContentPublished;
				peoplePrefObj.Native_Mobile_My_Content_Like_Or_Share__c = mobileWrapper.mobileAppLikesOrSharesContentPublished == null ? true : mobileWrapper.mobileAppLikesOrSharesContentPublished;
				peoplePrefObj.Native_Mob_Content_ApproveReject__c = mobileWrapper.mobileAppContentApprovalRejection == null ? true : mobileWrapper.mobileAppContentApprovalRejection;

				peoplePrefObj.Native_Mobile_Event_Invite_More__c = mobileWrapper.mobileAppEventInviteMore == null ? true : mobileWrapper.mobileAppEventInviteMore;
				
				peoplePrefObj.Native_Mob_Private_Site_Membership_Req__c = mobileWrapper.mobileAppPrivateSiteMembershipRequest == null ? true : mobileWrapper.mobileAppPrivateSiteMembershipRequest;
				peoplePrefObj.Native_Mob_Content_Submit_Moderation__c = mobileWrapper.mobileAppContentSubmittedForModeration == null ? true : mobileWrapper.mobileAppContentSubmittedForModeration;

				peoplePrefObj.Native_Mobile_Surveys__c = mobileWrapper.mobileSurveys == null ? true : mobileWrapper.mobileSurveys;

				// SummariesAndDigest 
                peoplePrefObj.Email_Digest_Frequency__c = summariesAndDigestWrapper.digestFrequency == null ? 'Daily' : summariesAndDigestWrapper.digestFrequency;
                peoplePrefObj.Email_Product_Research__c = false;
                peoplePrefObj.Email_Site_Analytics_Frequency__c = summariesAndDigestWrapper.siteAnalyticsFrequency == null ? 'monthly' : summariesAndDigestWrapper.siteAnalyticsFrequency;
                peoplePrefObj.Email_Content_Digest_Frequency__c = summariesAndDigestWrapper.topStoriesFrequency == null ? 'Daily' : summariesAndDigestWrapper.topStoriesFrequency;
        
				//browser
				peoplePrefObj.Browser_Must_Read__c = browserWrapper.browserMustRead;
				peoplePrefObj.Browser_Alerts__c = browserWrapper.browserAlerts;
				peoplePrefObj.Browser_Update_Content_Site_I_Follow__c = browserWrapper.browserUpdatesContentSitesFollow;

				// Profile and Expertise
				peoplePrefObj.Browser_Follows_Me__c = browserWrapper.browserFollowsMe;
				peoplePrefObj.Browser_Endorse_Expertise__c = browserWrapper.browserEndorseExpertise;
				
				// Feed
				peoplePrefObj.Browser_Comments_On_My_Post__c = browserWrapper.browserReplyOnMyPost;
				peoplePrefObj.Browser_Comments_After_Me__c = browserWrapper.browserReplyAfterMe;
				peoplePrefObj.Browser_Comments_On_Liked_Post__c = browserWrapper.browserReplyOnLikedPost;
				peoplePrefObj.Browser_Like_My_Post_Or_Comment__c = browserWrapper.browserLikesMyPostOrReply;
				peoplePrefObj.Browser_Shares_My_Post__c = browserWrapper.browserSharesMyPost;
				peoplePrefObj.Browser_Posts_To_Me__c = browserWrapper.browserPostsToMe;

				//Site
				peoplePrefObj.Browser_PrivateSiteMembership_Resp__c = browserWrapper.browserPrivateSiteMembershipResponse;
				
				// Content
				peoplePrefObj.Browser_Content_Validation_Required__c = browserWrapper.browserContentValidationRequired;
				peoplePrefObj.Browser_Content_Validation_Expired__c = browserWrapper.browserContentValidationExpired;
				peoplePrefObj.Browser_Content_Comments_On_Published__c = browserWrapper.browserContentCommentsOnPublished;
				peoplePrefObj.Browser_Content_LikesShares_On_Published__c = browserWrapper.browserContentLikesSharesOnPublished;
				peoplePrefObj.Browser_Content_Approval_Rejection__c = browserWrapper.browserContentApprovalRejection;
				peoplePrefObj.Browser_Content_Feedback__c = browserWrapper.browserContentFeedback;

				// Events
				peoplePrefObj.Browser_Event_Invite__c = browserWrapper.browserEventInvite;
				peoplePrefObj.Browser_Event_Updates_Attending__c = browserWrapper.browserEventUpdatesAttending;
				peoplePrefObj.Browser_Event_Updates_Authored_Organized__c = browserWrapper.browserEventUpdatesAuthoredOrganized;

				// Site-Manager
				peoplePrefObj.Browser_Site_Membership_Request__c = browserWrapper.browserPrivateSiteMembershipRequest;
				peoplePrefObj.Browser_Content_Submission__c = browserWrapper.browserContentSubmittedForModeration;
				peoplePrefObj.Browser_Subscription_Submission__c = browserWrapper.browserSubscriptionRequest;
				
				listOfPeoplePreference.add(peoplePrefObj );			
			}
			
    		if(listOfPeoplePreference.size() > 0) {   			
				SIMPESAPI.accessController().insertAsUser(listOfPeoplePreference,
					new List<Schema.SObjectField>{
						People_Preference__c.People__c,
						People_Preference__c.User__c,
						
						//feed
						People_Preference__c.Feed_Type__c,
						People_Preference__c.Feed_Sort_Order__c,
						
						//sms
						People_Preference__c.SMS_Alerts__c,
						People_Preference__c.SMS_Must_Reads__c,
						People_Preference__c.SMS_Content_Promotion_Message__c,
						
						//email
						People_Preference__c.Allow_Simpplr_Emails__c,
						People_Preference__c.Email_Notification_Digest_Frequency__c,
						People_Preference__c.Email_Digest_Frequency__c, 		
						People_Preference__c.Email_Content_Digest_Frequency__c,
						People_Preference__c.Email_Site_Analytics_Frequency__c,
						//-----------
						People_Preference__c.Email_Alerts__c,
						People_Preference__c.Email_Content_Marked_As_Must_Read__c,
						People_Preference__c.Email_Follows_Me__c,
						People_Preference__c.Email_Endorses_Me__c,
						People_Preference__c.Email_Like_My_Post_Or_Comment__c,
						People_Preference__c.Email_Comments_On_My_Post__c,
						People_Preference__c.Email_Comments_After_Me__c,
						People_Preference__c.Email_Comments_On_Post_I_Like__c,
						People_Preference__c.Email_Posts_To_Me__c,
						People_Preference__c.Email_Shares_My_Post__c,
						People_Preference__c.Email_My_Content_Post__c,
						People_Preference__c.Email_My_Content_Like_Or_Share__c,
						People_Preference__c.Email_Updates_Content_Sites_I_Follow__c,
						People_Preference__c.Email_Event_Invite_More__c,
						People_Preference__c.Email_Updates_Event_I_RSVP_Yes__c,
						People_Preference__c.Email_Updates_Event_I_Author_Organize__c,
						People_Preference__c.Email_My_Content_Rejected__c,
						People_Preference__c.Email_My_Content_Approved__c,
						People_Preference__c.Email_My_Content_Validation_Required__c,
						People_Preference__c.Email_My_Content_Validation_Expired__c,
						People_Preference__c.Email_Content_Submission_Response__c,
						People_Preference__c.Email_PrivateSiteMembership_Response__c,
						People_Preference__c.Email_Content_Submitted_For_Moderation__c,
						People_Preference__c.Email_Content_Useful__c,
                        People_Preference__c.Email_Private_Site_Membership_Requests__c,
                        People_Preference__c.Receive_Content_Moderation_Notifications__c,
                        People_Preference__c.Receive_Content_Update_Notifications__c,
						People_Preference__c.Receive_Content_Useful_Notifications__c,
						People_Preference__c.peoplePrefObj.Email_Subscription_Request__c,
						People_Preference__c.peoplePrefObj.Email_Subscription_Moderation__c,

						//mobile
						People_Preference__c.Native_Mob_Content_Marked_As_Must_Read__c,
						People_Preference__c.Native_Mobile_Alerts__c,              
						People_Preference__c.Native_Mob_Update_Content_Site_I_Follow__c,          
						People_Preference__c.Native_Mobile_Follows_Me__c,
						People_Preference__c.Native_Mob_Endorse_Expertise__c,
						People_Preference__c.Native_Mob_Comments_On_My_Post__c,
						People_Preference__c.Native_Mob_Reply_After_Me__c,
						People_Preference__c.Native_Mob_Replied_On_liked_Post__c,
						People_Preference__c.Native_Mob_Like_My_Post_Or_Comment__c,
						People_Preference__c.Native_Mob_Shares_My_Post__c,
						People_Preference__c.Native_Mob_Posts_To_Me__c,
						People_Preference__c.Native_Mob_My_Content_Post__c,
						People_Preference__c.Native_Mobile_My_Content_Like_Or_Share__c,
						People_Preference__c.Native_Mob_Content_ApproveReject__c,
						People_Preference__c.Native_MobPrivateSiteMembership_Resp__c,
						People_Preference__c.Native_Mobile_Event_Invite_More__c,
						People_Preference__c.Native_Mob_Private_Site_Membership_Req__c,
						People_Preference__c.Native_Mob_Content_Submit_Moderation__c,
						People_Preference__c.Native_Mobile_Surveys__c,

						//browser
						People_Preference__c.Browser_Must_Read__c,
						People_Preference__c.Browser_Alerts__c,
						People_Preference__c.Browser_Update_Content_Site_I_Follow__c,
						People_Preference__c.Browser_Follows_Me__c,
						People_Preference__c.Browser_Endorse_Expertise__c,
						People_Preference__c.Browser_Comments_On_My_Post__c,
						People_Preference__c.Browser_Comments_After_Me__c,
						People_Preference__c.Browser_Comments_On_Liked_Post__c,
						People_Preference__c.Browser_Like_My_Post_Or_Comment__c,
						People_Preference__c.Browser_Shares_My_Post__c,
						People_Preference__c.Browser_Posts_To_Me__c,
						People_Preference__c.Browser_PrivateSiteMembership_Resp__c,
						People_Preference__c.Browser_Content_Validation_Required__c,
						People_Preference__c.Browser_Content_Validation_Expired__c,
						People_Preference__c.Browser_Content_Comments_On_Published__c,
						People_Preference__c.Browser_Content_LikesShares_On_Published__c,
						People_Preference__c.Browser_Content_Approval_Rejection__c,
						People_Preference__c.Browser_Content_Feedback__c,
						People_Preference__c.Browser_Event_Invite__c,
						People_Preference__c.Browser_Event_Updates_Attending__c,
						People_Preference__c.Browser_Event_Updates_Authored_Organized__c,
						People_Preference__c.Browser_Site_Membership_Request__c,
						People_Preference__c.Browser_Subscription_Submission__c,
						People_Preference__c.Browser_Content_Submission__c,

						People_Preference__c.OwnerId
					}
				);
    		}
	    } catch (Exception e) {
			logger.logError(e);
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
    public void updateManagerInfo(List<People__c> listOfPeople, Map<String, String> mapOfUserIdAndManagersId) {
    	List<People__c> listOfManagers = [select Id, User__c from People__c where user__c =:mapOfUserIdAndManagersId.values() And User__r.UserType='Standard' WITH SECURITY_ENFORCED];
    	Map<String,String> mapOfManagerPeopleIds = new Map<String,String>();
    	for(People__c peopleObj : listOfManagers) {
    		mapOfManagerPeopleIds.put(peopleObj.User__c, peopleObj.Id);
    	}
    	List<People__c> listOfUpdatedPeople = new List<People__c>();
    	for(People__c peopleObj : listOfPeople) {
    		if(mapOfUserIdAndManagersId.containsKey(peopleObj.user__c)) {
    			peopleObj.Manager__c = mapOfManagerPeopleIds.get(mapOfUserIdAndManagersId.get(peopleObj.user__c));
    			listOfUpdatedPeople.add(peopleObj);
    		}
    	}
    	if(listOfUpdatedPeople.size() > 0) {
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(listOfUpdatedPeople),new List<Schema.SObjectField>{People__c.Manager__c});
		}
    }
    public void renewExternalPhotoURL() {
    	Boolean updateFlag = false;
		List<People__c> listOfPeople = [select Id, User__r.SmallPhotoUrl, Photo_Version_Id__c, External_Photo_URL__c, 
										First_Name__c, Last_Name__c, User__r.timezonesidkey,Full_Name__c, User__r.UserName, User__r.languagelocalekey,
										External_Photo_URL_Expiry_Date__c, Is_First_Login__c, Segment__r.Id, Segment__r.Branding_JSON__c, Segment__r.Branding_Logo__c
										from People__c
										where User__c =: UserContext.Id and User__r.isActive=true WITH SECURITY_ENFORCED];
		
		if(!listOfPeople.isEmpty()) {
			People__c peopleObj = listOfPeople[0];
			if(Utility.getPhotoVersionId(peopleObj.User__r.SmallPhotoUrl) == null) {
				if(peopleObj.Photo_Version_Id__c != null) {
					saveExternalPhotoURL(peopleObj.Id, null, null, null);
				}
			}
			else {
				// if photo url has expired || photoIds dont match
				// Every 7th day renew public photo url for next 15 days
				DateTime expiryTime = DateTime.now().addDays(-7);
				if( !Utility.getPhotoVersionId(peopleObj.User__r.smallPhotoUrl).equalsIgnoreCase(peopleObj.photo_Version_Id__c) || 
					peopleObj.External_Photo_URL_Expiry_Date__c < DateTime.now()|| 
					peopleObj.External_Photo_URL_Expiry_Date__c > expiryTime) {
						
					ConnectApi.Photo outputPhoto = ConnectApi.UserProfiles.getPhoto(null, peopleObj.User__c);
					String publicPhotoUrl = outputPhoto.standardEmailPhotoUrl;
					String fullEmailPhotoUrl = outputPhoto.fullEmailPhotoUrl;
					saveExternalPhotoURL(peopleObj.Id, peopleObj.User__r.SmallPhotoUrl, publicPhotoUrl, fullEmailPhotoUrl);
				}
			}
			if(peopleObj.Is_First_Login__c) {
				completeOnBoardActivities(peopleObj);
			}
		}
    }
    
    public void completeOnBoardActivities(People__c peopleObj) {
    	peopleObj.Is_First_Login__c = false;
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    	SIMPESAPI.accessController().updateAsUser(peopleObj,new List<Schema.SObjectField>{
    														People__c.Is_First_Login__c});
    	new NotificationDispatcher().sendOnBoardMustReadsEmail(peopleObj);
    }
    
    public void saveExternalPhotoURL(String peopleId, String smallPhotoURL, String publicPhotoUrl, String fullEmailPhotoUrl) {    	
		People__c peopleObj=new People__c();
		peopleObj.id = peopleId;
		peopleObj.External_Photo_URL__c = publicPhotoUrl;
		peopleObj.External_Full_Photo_URL__c = fullEmailPhotoUrl;
		peopleObj.Photo_Version_Id__c = Utility.getPhotoVersionId(smallPhotoURL);
		peopleObj.External_Photo_URL_Expiry_Date__c = DateTime.now().addDays(EXTERNAL_PHOTO_EXPIRY_DAYS);
		peopleObj.Last_Edited_DateTime__c = DateTime.now();
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(peopleObj,new List<Schema.SObjectField>{
													People__c.External_Photo_URL__c,
													People__c.External_Photo_URL_Expiry_Date__c, 
													People__c.External_Full_Photo_URL__c,
													People__c.Last_Edited_DateTime__c,
													People__c.Photo_Version_Id__c});
    }
    
    public List<People__c> getFavoritesPeopleForLoggedInUser (String term, Integer offset, Integer recordLimit) {
		List<Bookmark__c> listOfFavorite = new List<Bookmark__c>();
		String favoriteQueryStr = 'SELECT Id, People__c, Type__c, Bookmark_Receiver__c , createddate, Bookmark_Receiver__r.User__c ' +
					   'FROM Bookmark__c '+
					   'WHERE People__c=:loggedInPeopleId AND Type__c=\'People\'  AND Is_Deleted__c = false ';
		
		if(Utility.isApiOnlyUserQueryable()){
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\' AND Bookmark_Receiver__r.User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\')) ';
		}
		
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				favoriteQueryStr+=' And Bookmark_Receiver__r.Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		
		favoriteQueryStr += 'Order by LastModifiedDate desc '+
					   		'limit :recordLimit  offset :offset ';
		
		logger.logDebug('PeopleDao.getFavoritesPeopleForLoggedInUser() - favoriteQueryStr '+ favoriteQueryStr);			   		
		listOfFavorite = Database.query(favoriteQueryStr);
		
    	List<Id> favoritePeopleIdsOrderedList = new List<Id>(); 
    	
		for (Bookmark__c favoriteObj : listOfFavorite) {
			favoritePeopleIdsOrderedList.add(favoriteObj.Bookmark_Receiver__c);
		}
    	
    	String queryStr = PEOPLE_BASE_QUERY + ' WHERE Id IN :favoritePeopleIdsOrderedList ';
    	Map<Id, People__c> mapOfPeopleIdAndPeople = new map<Id, People__c>((List<People__c>)Database.query(queryStr));
		List<People__c> peopleList = new List<People__c>();
		for (Id peopleId: favoritePeopleIdsOrderedList) {
			if(mapOfPeopleIdAndPeople.containsKey(peopleId)) {
				peopleList.add(mapOfPeopleIdAndPeople.get(peopleId));
			}
		}
		
		return peopleList;
	}

	public List<People__c> getFavPeopleFromPeopleIds (List<String> peopleIds) {
		logger.logDebug('PeopleDao.getFavPeopleFromPeopleIds() - peopleIds :: '+ peopleIds);			   		
		
    	
    	String queryStr = PEOPLE_BASE_QUERY + ' WHERE Id IN :peopleIds ';
    	List<People__c> peopleList = Database.query(queryStr);
		
		return peopleList;
	}

	public List<Subscription_Entity__c> getSubscriptionEntity (String siteId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		
		String queryString = 'SELECT Id, Subscription__r.Audience__c FROM Subscription_Entity__c WHERE '
								+ ' Site__c = :soqlParam1 AND Subscription__r.Action_Type__c = \'mandatory\' AND '
								+ ' Subscription__r.Type__c = \'Site\' AND Status__c = \'Approved\' AND '
								+ ' Subscription__r.Status__c != \'Deleted\' ';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
	}

	public List<Audience_Member__c> getAudienceMembers (Set<Id> siteMembersPeopleIdSet, Set<String> audienceIdSet ) {
		Map<String, Object> soqlParamMap1 = new Map<String, Object>();
		soqlParamMap1.put('soqlParam1', siteMembersPeopleIdSet);
		soqlParamMap1.put('soqlParam2', audienceIdSet);
		String audienceMemberQuery = 'SELECT Id, People__c FROM Audience_Member__c WHERE '
										+ ' User__c IN :soqlParam1 AND '
										+ ' Audience__c IN :soqlParam2 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(audienceMemberQuery, soqlParamMap1);
	}

	public Simpplr_Site__c getSite (String siteId) {
		return [Select Id, Site_Type__c, chatter_Group_id__c, File_Storage_Source__c From Simpplr_Site__c Where Id = :siteId WITH SECURITY_ENFORCED];
	}

	public CollaborationGroup getCollaborationGroup (String chatterGroupId) {
		return [SELECT Id, CollaborationType, OwnerId, Owner.name FROM CollaborationGroup Where Id= : chatterGroupId WITH SECURITY_ENFORCED];
	}

	public List<String> getAllFavoritePeopleIds() {
		List<String> favoritePeopleIds = new List<String>(); 
		
		String favoriteQueryStr = 'SELECT Id, Bookmark_Receiver__c FROM Bookmark__c '+
					   'WHERE People__c=:loggedInPeopleId AND Type__c=\'People\' AND Is_Deleted__c = false ';
		
		if(Utility.isApiOnlyUserQueryable()){
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\' AND Bookmark_Receiver__r.User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\')) ';
		}
		
		logger.logDebug('PeopleDao.getAllFavoritePeopleIds() - favoriteQueryStr '+ favoriteQueryStr);	
		List<Bookmark__c> listOfFavorite = Database.query(favoriteQueryStr);
		
    	
		for (Bookmark__c favoriteObj : listOfFavorite) {
			favoritePeopleIds.add(favoriteObj.Bookmark_Receiver__c);
		}
    	
		return favoritePeopleIds;
	}
	
	public List<People__c> getPeopleBySubscriptionId(String subscriptionId, String term, Integer recordLimit, Integer offset, Boolean limitToSubsegment){
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', subscriptionId);

        String queryString = 'SELECT Id, Audience__c FROM Subscription__c WHERE Id = :soqlParam1 ';
        List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

		List<People__c> peopleList = new List<People__c>();
		
		if(!subscriptionList.isEmpty()){
			String audienceId = subscriptionList[0].Audience__c;
			Map<String, Object> soqlParamMap1 = new Map<String, Object>();
			soqlParamMap1.put('soqlParam1', audienceId);
			String audienceMemberInnerQuery = '(SELECT People__c FROM Audience_Member__c WHERE Audience__c = :soqlParam1)';
			String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Id IN ' + audienceMemberInnerQuery
									+ ' AND User__r.isActive = true ';
									
			if(String.isNotBlank(term)) {
				setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
				for(String searchToken:setOfSearchTerms){
					peopleQuery+=' And Full_Name__c like \'%'+searchToken+'%\' ';
				}
			}
			
			String segmentAttValue = UserContext.segmentAttributeValue;
			if(SimpplrContext.isSegmentsEnabled && limitToSubsegment){
				soqlParamMap1.put('soqlParam2', segmentAttValue);
				peopleQuery += ' AND Segment_Attribute_Value__c = :soqlParam2 ';
			}
			
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){//##
				soqlParamMap1.put('soqlParam3', packageName);
				 peopleQuery += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam3)';
			}
			if(Utility.isApiOnlyUserQueryable()){
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}
			
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				peopleQuery += ' order by CreatedDate asc ';
			} else {
				peopleQuery += ' ORDER BY Full_Name__c ASC';
			}
			
			if(recordLimit != null && recordLimit > 0){
				soqlParamMap1.put('soqlParam4', recordLimit);
	            peopleQuery += ' LIMIT :soqlParam4';
	        }
	        if(offset != null && offset > 0){
				soqlParamMap1.put('soqlParam5', offset);
	            peopleQuery +=' OFFSET :soqlParam5';
	        }	
			peopleQuery = peopleQuery.replace(':loggedInPeopleId', ':soqlParam6');
			soqlParamMap1.put('soqlParam6', loggedInPeopleId);					
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap1);
		}
			
		return peopleList;
	}

	/*
		@description Use when all the records of People required by API as offset supports upto 2000 records only.
		this is implemented for Newsletter+ unless required for other features.

		Note: no sorting, term search allowed
		@return List<People__c>
	*/
	public List<People__c> getAllPeopleBySubscriptionId(String subscriptionId, Integer recordLimit, String nextPageToken, Boolean limitToSubsegment){
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', subscriptionId);

        String queryString = 'SELECT Id, Audience__c FROM Subscription__c WHERE Id = :soqlParam1 ';
        List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

		List<People__c> peopleList = new List<People__c>();
		
		if(!subscriptionList.isEmpty()){
			String audienceId = subscriptionList[0].Audience__c;
			Map<String, Object> soqlParamMap1 = new Map<String, Object>();
			soqlParamMap1.put('soqlParam1', audienceId);
			String audienceMemberInnerQuery = '(SELECT People__c FROM Audience_Member__c WHERE Audience__c = :soqlParam1)';
			String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Id IN ' + audienceMemberInnerQuery
									+ ' AND User__r.isActive = true ';
									
			String segmentAttValue = UserContext.segmentAttributeValue;
			if(SimpplrContext.isSegmentsEnabled && limitToSubsegment){
				soqlParamMap1.put('soqlParam2', segmentAttValue);
				peopleQuery += ' AND Segment_Attribute_Value__c = :soqlParam2 ';
			}
			
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				soqlParamMap1.put('soqlParam3', packageName);
				 peopleQuery += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam3)';
			}
			if(Utility.isApiOnlyUserQueryable()){
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}

			if(String.isNotBlank(nextPageToken)){
				soqlParamMap1.put('soqlParam5', nextPageToken);
	            peopleQuery +=' AND Id >:soqlParam5';
	        }

			peopleQuery += ' ORDER BY Id ASC';
			
			if(recordLimit != null && recordLimit > 0){
				soqlParamMap1.put('soqlParam4', recordLimit);
	            peopleQuery += ' LIMIT :soqlParam4';
	        }
	        
			peopleQuery = peopleQuery.replace(':loggedInPeopleId', ':soqlParam6');
			soqlParamMap1.put('soqlParam6', loggedInPeopleId);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap1);
		}
			
		return peopleList;
	}

	public List<People__c> getPeopleByAudienceId(String audienceId, String term, Integer recordLimit, Integer offset){
		List<People__c> peopleList = new List<People__c>();
		
		if(String.isNotBlank(audienceId)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', audienceId);
			String audienceMemberInnerQuery = '(SELECT People__c FROM Audience_Member__c WHERE Audience__c = :soqlParam1)';
			String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Id IN ' + audienceMemberInnerQuery
									+ ' AND User__r.isActive = true ';
									
			if(String.isNotBlank(term)) {
				setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
				for(String searchToken:setOfSearchTerms){
					peopleQuery+=' And Full_Name__c like \'%'+searchToken+'%\' ';
				}
			}
			
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				soqlParamMap.put('soqlParam2', packageName);
				 peopleQuery += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
			}
			if(Utility.isApiOnlyUserQueryable()){
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}
			
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				peopleQuery += ' order by CreatedDate asc ';
			} else {
				peopleQuery += ' ORDER BY Full_Name__c ASC';
			}
			
			if(recordLimit != null && recordLimit > 0){
				soqlParamMap.put('soqlParam3', recordLimit);
	            peopleQuery += ' LIMIT :soqlParam3';
	        }
	        if(offset != null && offset > 0){
				soqlParamMap.put('soqlParam4', offset);
	            peopleQuery +=' OFFSET :soqlParam4';
	        }						
			peopleQuery = peopleQuery.replace(':loggedInPeopleId', ':soqlParam5');
			soqlParamMap.put('soqlParam5', loggedInPeopleId);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
		}
			
		return peopleList;
	}

	/*
		@description Use when all the records of People required by API as offset supports upto 2000 records only.
		this is implemented for Newsletter+ unless required for other features.

		Note: no sorting, term search allowed
		@return List<People__c>
	*/
	public List<People__c> getAllAudienceMembers(String audienceId,Integer recordLimit, String nextPageToken){
		List<People__c> peopleList = new List<People__c>();
		
		if(String.isNotBlank(audienceId)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', audienceId);
			String audienceMemberInnerQuery = '(SELECT People__c FROM Audience_Member__c WHERE Audience__c = :soqlParam1)';
			String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Id IN ' + audienceMemberInnerQuery
									+ ' AND User__r.isActive = true ';
									
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				soqlParamMap.put('soqlParam2', packageName);
				 peopleQuery += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
			}
			if(Utility.isApiOnlyUserQueryable()){
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}

			if(String.isNotBlank(nextPageToken)){
				soqlParamMap.put('soqlParam3', nextPageToken);
				peopleQuery += ' AND Id > :soqlParam3 ';
			}
			peopleQuery += ' ORDER BY Id asc ';
			
			if(recordLimit != null && recordLimit > 0){
				soqlParamMap.put('soqlParam4', recordLimit);
	            peopleQuery += ' LIMIT :soqlParam4';
	        }
	        					
			peopleQuery = peopleQuery.replace(':loggedInPeopleId', ':soqlParam5');
			soqlParamMap.put('soqlParam5', loggedInPeopleId);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
		}
			
		return peopleList;
	}

	
	public List<People__c> getPeopleBySegmentId(String segmentId, String term, Integer recordLimit, Integer offset, Boolean limitToSubsegment){
		String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Segment__c =:segmentId AND User__r.isActive = true ';

		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				peopleQuery+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		
		String segmentAttValue = UserContext.segmentAttributeValue;
		if(limitToSubsegment){
			peopleQuery += ' AND Segment_Attribute_Value__c = :segmentAttValue ';
		}
		
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 peopleQuery += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			peopleQuery += ' order by CreatedDate asc ';
		} else {
			peopleQuery += ' ORDER BY Full_Name__c ASC';
		}
		
		if(recordLimit != null && recordLimit > 0){
            peopleQuery += ' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            peopleQuery +=' OFFSET :offset';
        }
		
		return Database.query(peopleQuery);
	}

	/*
		@description Use when all the records of People required by API as offset supports upto 2000 records only.
		this is implemented for Newsletter+ unless required for other features.

		Note: no sorting, term search allowed
		@return List<People__c>
	*/
	public List<People__c> getAllPeopleBySegmentId(String segmentId, Integer recordLimit, String nextPageToken, Boolean limitToSubsegment){
		String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Segment__c =:segmentId AND User__r.isActive = true ';

		String segmentAttValue = UserContext.segmentAttributeValue;
		if(limitToSubsegment){
			peopleQuery += ' AND Segment_Attribute_Value__c = :segmentAttValue ';
		}
		
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 peopleQuery += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			peopleQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		
		if(String.isNotBlank(nextPageToken)){
			peopleQuery += ' AND Id > :nextPageToken ';
		}

		peopleQuery += ' ORDER BY Id asc ';
		
		if(recordLimit != null && recordLimit > 0){
            peopleQuery += ' LIMIT :recordLimit';
        }
		
		return Database.query(peopleQuery);
	}
	
	public PeopleWrapper.CompanyStats getCompanyStats(){
		
		PeopleWrapper.CompanyStats compStat = new PeopleWrapper.CompanyStats();
		String appConfigQuery = 'select id, PP_Departments_Count__c, PP_Employees_Count__c, PP_Locations_Count__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		FilterService service = new FilterService();
		
		if(SimpplrContext.isPPDepartmentDisplay){
			if(listOfAppConfig[0].PP_Departments_Count__c != null && listOfAppConfig[0].PP_Departments_Count__c >=0){
				compStat.departments = Integer.valueOf(listOfAppConfig[0].PP_Departments_Count__c);
			}else{
				compStat.departments = service.getListOfUserDepartment().size();
			}
		}
		
		if(listOfAppConfig[0].PP_Employees_Count__c != null &&listOfAppConfig[0].PP_Employees_Count__c >=0){
			compStat.people = Integer.valueOf(listOfAppConfig[0].PP_Employees_Count__c);
		}else{
			compStat.people = service.getEmployeeCount();
		}
		
		if(SimpplrContext.isLocationTileEnabled){
			if(listOfAppConfig[0].PP_Locations_Count__c != null && listOfAppConfig[0].PP_Locations_Count__c >=0){
				compStat.locations = Integer.valueOf(listOfAppConfig[0].PP_Locations_Count__c);
			}else {
				compStat.locations = service.getListOfUserLocation().size();
			}
		}
		
		return compStat;
	}
	
	public List<AggregateResult> searchDepartment(String searchTerm, Integer offset, Integer recordLimit){	
		String query ='Select Department__c department from People__c where'; 
		if(Utility.isApiOnlyUserQueryable()){
			query += ' (user__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		}else {
			query += ' (user__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		if(String.isNotBlank(searchTerm)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchTerm));
			for(String searchToken:setOfSearchTerms){
				query+=' And Department__c like \'%'+searchToken+'%\' ';
			}
		} else {
			query+=' And Department__c != null ';
		}

		query += ' Group by Department__c order by Department__c asc';
		
		if(recordLimit != null && recordLimit > 0){
			query+=' LIMIT :recordLimit';
		}
		if(offset != null && offset > 0){
			query+=' OFFSET :offset';
		}
		return Database.query(query);
		
	}
	
	public List<People__c> searchLocation(String searchTerm){
		List<People__c> listOfPeople = new List<People__c>();
		
		String query ='Select id,user__c,city__c,state__c,country__c,user__r.isActive from People__c where'; 
		if(Utility.isApiOnlyUserQueryable()){
			query += ' (user__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		}else {
			query += ' (user__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		String queryPart;
		if(String.isNotBlank(searchTerm)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchTerm)); 
			for(String searchToken:setOfSearchTerms) {
				queryPart='';
				if(SimpplrContext.isPPCityDisplay){
					queryPart+=' OR City__c like \'%'+searchToken+'%\' ';
				}
				if(SimpplrContext.isPPStateDisplay){
					queryPart+=' OR State__c like \'%'+searchToken+'%\' ';
				}
				if(SimpplrContext.isPPCountryDisplay){
					queryPart+=' OR Country__c like \'%'+searchToken+'%\' ';
				}
				query += 'and (' + queryPart.removeStart(' OR') + ')';
			}
		} else {
			queryPart='';
			if(SimpplrContext.isPPCityDisplay){
				queryPart+=' OR City__c != null ';
			}
			if(SimpplrContext.isPPStateDisplay){
				queryPart+=' OR State__c !=null ';
			}
			if(SimpplrContext.isPPCountryDisplay){
				queryPart+=' OR Country__c !=null ';
			}
			query += 'and (' + queryPart.removeStart(' OR') + ')';
		}
		
		return Database.query(query);		
	}
	
	public PeopleWrapper.UserLocation getLocation(String LocationId){
		String location ='';
		PeopleWrapper.UserLocation usrLocation =new PeopleWrapper.UserLocation();
		
		if(LocationId != null){
			
			List<String> listOfAttributes = new  List<String>();
			
			String city = LocationId.SubString(0,(LocationId.indexOf('@@')-1));
			listOfAttributes.add(city);
			String state = LocationId.SubString((LocationId.indexOf('@@') + 3),(LocationId.lastIndexOf('@@')-1));
			listOfAttributes.add(state);
			String country = LocationId.SubString((LocationId.lastIndexOf('@@') + 3),LocationId.length());
			listOfAttributes.add(country);
			
			
			for (String str : listOfAttributes ){
				if(!'null'.containsIgnoreCase(str)){
					location += str +', ';
				}
			}
			location = location.trim().removeEnd(',').trim().removeEnd(',');
			
			usrLocation.id = LocationId;
			usrLocation.name = location;
		}
		return usrLocation;
	}
	
	public List<People__c> getPeopleInMyDepartment(String sortBy, Integer recordLimit, Integer offset){
		List<People__c> listOfPeople = new List<People__c>();
		String department = UserContext.getUsersDepartmentDetail;
		String ppId = UserContext.peopleId;
		
		if(String.isNotBlank(department)){
			String queryStr = PEOPLE_BASE_QUERY + ' Where Department__c =:department AND ID !=:ppId ' +getUserStatusCondition();
			
			if ('alphabetical'.equalsIgnoreCase(sortBy)) {
	        	queryStr += ' Order by Full_Name__c asc '; 
			}
			if(recordLimit != null && recordLimit > 0){
	            queryStr+=' LIMIT :recordLimit';
	        }
	        if(offset != null && offset > 0){
	            queryStr+=' OFFSET :offset';
	        }
			listOfPeople = 	Database.query(queryStr);
			List<People__c> peopleList = Database.query(queryStr);
			listOfPeople = updatePeopleListAccToProfileFields(peopleList);
		}
		
		return listOfPeople;
	}
	
	public List<People__c> getAllPeople(String sortBy, Integer recordLimit, Integer offset, String term, String departmentArg, 
	String locationArg, String categoryId, List<Id> listOfExpertisePeopleId, List<String> peopleIdsToFilterFrom, 
	String limitToSubsegment, Criteria.People peopleCriteriaObjArg) {
		
		List<People__c> listOfPeople = new List<People__c>();
		Date maxJoiningDate = Date.today();
		String ppId = UserContext.peopleId;
        String segmentAttValue = UserContext.segmentAttributeValue;
		String queryStr = PEOPLE_BASE_QUERY + getAllPeopleWhereCondition(term, departmentArg, 
			locationArg, categoryId, listOfExpertisePeopleId, peopleIdsToFilterFrom, 
			limitToSubsegment, peopleCriteriaObjArg);
		if(!SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			if ('alphabetical'.equalsIgnoreCase(sortBy)) {
				queryStr += ' Order by Full_Name__c asc ';

			} else if ('hire_date'.equalsIgnoreCase(sortBy)) {
				queryStr += ' And Joining_Date__c <=:maxJoiningDate ';
				queryStr += ' Order by Joining_Date__c desc NULLS LAST, Full_Name__c Asc ';
			}
		}
		
		if (recordLimit != null && recordLimit > 0) {
			queryStr += ' LIMIT :recordLimit';
		}
		
		if (offset != null && offset > 0 && 
			!(SimpplrContext.isFeatureEnabled('Full_External_Search') && 'hire_date'.equalsIgnoreCase(sortBy) && peopleIdsToFilterFrom != null && peopleIdsToFilterFrom.size() > 0)) {
			queryStr += ' OFFSET :offset';
		}
		
        logger.logDebug('PeopleDao.getAllPeople()----queryStr---- >>>>> ' + queryStr);
		List<People__c> peopleList = Database.query(queryStr);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Map<Id, People__c> peopleMap = new Map<Id, People__c>(peopleList);
			List<People__c> sortedPeopleList = new List<People__c>();
			if (peopleIdsToFilterFrom != null) {
				for(String peopleId : peopleIdsToFilterFrom) {
					if(peopleMap.containsKey(peopleId)) {
						sortedPeopleList.add(peopleMap.get(peopleId));
					}
				}
				peopleList = sortedPeopleList;
			}			
		}
		peopleList = updatePeopleListAccToProfileFields(peopleList);
		
		return peopleList;
	}
	
	public Integer getAllPeopleCount(String sortBy, String term, String departmentArg, 
		String locationArg, String categoryId, List<Id> listOfExpertisePeopleId, List<String> peopleIdsToFilterFrom, 
		String limitToSubsegment, Criteria.People peopleCriteriaObjArg) {
		
		Date maxJoiningDate = Date.today();
		String ppId = UserContext.peopleId;
        String segmentAttValue = UserContext.segmentAttributeValue;
		String queryStr = 'SELECT count() FROM People__c ' + getAllPeopleWhereCondition(term, departmentArg, 
			locationArg, categoryId, listOfExpertisePeopleId, peopleIdsToFilterFrom, 
			limitToSubsegment, peopleCriteriaObjArg);
		if(!SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			if ('hire_date'.equalsIgnoreCase(sortBy)) {
				queryStr += ' And Joining_Date__c <=:maxJoiningDate ';
			}
		}
		
        logger.logDebug('PeopleDao.getAllPeopleCount()----queryStr---- >>>>> ' + queryStr);
		return Database.countQuery(queryStr);
	}
	
	private String getAllPeopleWhereCondition(String term, String departmentArg, 
		String locationArg, String categoryId, List<Id> listOfExpertisePeopleId, List<String> peopleIdsToFilterFrom, 
		String limitToSubsegment, Criteria.People peopleCriteriaObjArg) {
		
		Date maxJoiningDate = Date.today();
		String ppId = UserContext.peopleId;
		String queryStr = '';
		
		String packageName = SimpplrContext.packageName;
				
			if (Utility.isApiOnlyUserQueryable()) {
				queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false))';
			
			} else {
				queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\'))';
			}

			queryStr += getFilterCriteria(term, categoryId, departmentArg, locationArg);
			
			if (peopleIdsToFilterFrom != null && peopleIdsToFilterFrom.size() > 0) {
				queryStr += ' And Id = :peopleIdsToFilterFrom ';
			}
							
			if (listOfExpertisePeopleId != null) {
				queryStr += ' And Id = :listOfExpertisePeopleId ';
			}
			queryStr = queryStrUpdate( queryStr, peopleCriteriaObjArg );
			
			String segmentAttValue = UserContext.segmentAttributeValue;
			
			if (SimpplrContext.isSegmentsEnabled && 'true'.equalsIgnoreCase(limitToSubsegment)) {
				queryStr += ' AND Segment_Attribute_Value__c = :segmentAttValue ';
			}

			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
				queryStr += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
			}
			
		if(!SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			if ( String.isNotBlank(peopleCriteriaObjArg.filterDays) && !'all_time'.equalsIgnoreCase(peopleCriteriaObjArg.filterDays))
			{
				integer numeric_value=0;
				String filter_value = peopleCriteriaObjArg.filterDays;
				//filter_value is supposed to hold value like 'Last_7_days' or 'last_6_months'
				if( filter_value.containsIgnoreCase('days'))
				{
					filter_value = filter_value.removeStartIgnoreCase('Last_').removeEndIgnoreCase('_days');
					numeric_value = integer.valueOf(filter_value);
					queryStr += ' And Joining_Date__c > '+ string.valueOf(date.today().addDays(-numeric_value));
				}
				if( filter_value.containsIgnoreCase('months'))
				{
					filter_value = filter_value.removeStartIgnoreCase('Last_').removeEndIgnoreCase('_months');
					numeric_value = integer.valueOf(filter_value);
					queryStr += ' And Joining_Date__c > '+ string.valueOf(date.today().addMonths(-numeric_value));
				}
			}
		}
		return queryStr;
	}

	/*
		@description Use when all the records of People required by API as offset supports upto 2000 records only.
		this is implemented for Newsletter+ unless required for other features.

		Note: no sorting, term search allowed
		@return List<People__c>
	*/
	public List<People__c> getAllPeopleData( Integer recordLimit, List<String> peopleIdsToFilterFrom, 
														String limitToSubsegment, Criteria.People peopleCriteriaObjArg) {
		
		List<People__c> listOfPeople = new List<People__c>();
		String queryStr = PEOPLE_BASE_QUERY;
		
		String packageName = SimpplrContext.packageName;
				
		if (Utility.isApiOnlyUserQueryable()) {
			queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false))';
		
		} else {
			queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\'))';
		}
		
		if (peopleIdsToFilterFrom != null && peopleIdsToFilterFrom.size() > 0) {
			queryStr += ' And Id = :peopleIdsToFilterFrom ';
		}

		queryStr = queryStrUpdate( queryStr, peopleCriteriaObjArg );

		String segmentAttValue = UserContext.segmentAttributeValue;
		
		if (SimpplrContext.isSegmentsEnabled && 'true'.equalsIgnoreCase(limitToSubsegment)) {
			queryStr += ' AND Segment_Attribute_Value__c = :segmentAttValue ';
		}

		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			queryStr += ' And User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}

		if (String.isNotBlank(peopleCriteriaObjArg.nextPageToken)) {
			String nextPageToken = peopleCriteriaObjArg.nextPageToken;
			queryStr += ' AND Id >:nextPageToken ';
		}
		queryStr += ' ORDER BY Id ASC '; //Required to work with Id filtring instead of offset
	
		if (recordLimit != null && recordLimit > 0) {
			queryStr += ' LIMIT :recordLimit';
		}
		
        logger.logDebug('PeopleDao.getAllPeopleData()----queryStr---- >>>>> ' + queryStr);
		List<People__c> peopleList = Database.query(queryStr);
		peopleList = updatePeopleListAccToProfileFields(peopleList);
		
		return peopleList;
	}
	
	public List<People__c> getPeopleByUserId(String userId){
		List<People__c> listOfPeople;
		if(String.isBlank(userId)){
			userId = UserContext.id;
		}
		String queryStr = BASE_QUERY + ' Where User__c =:userId ';
		listOfPeople = 	Database.query(queryStr);
		
		return listOfPeople;
	}
	
	public People__c getPeopleByPeopleId(String peopleId){
		List<People__c> listOfPeople;
		String queryStr = BASE_QUERY + ' Where id =:peopleId ';
		listOfPeople = 	Database.query(queryStr);
		
		People__c peopleObj = new People__c();
		if(listOfPeople.size() > 0) {

			for(People__c peopleObjTemp : listOfPeople){
				peopleObj = peopleObjTemp;

				break;
			}
		
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		
		return peopleObj;
	}
	
	public List<People__c> getPeopleByPeopleIds(List<String> peopleIds){
		List<People__c> listOfPeople = [
			SELECT Id, User__c, Phone__c, Email__c, Title__c, About__c,Zoom_Id__c,Skype_Id__c, User__r.LanguageLocaleKey, User__r.TimeZoneSidKey,
				User__r.SmallPhotoUrl, User__r.FullPhotoUrl, Full_Name__c, Department__c,Birth_Date__c,Joining_Date__c, 
				City__c, Street__c, Country__c, State__c, User__r.IsActive,Mobile_Phone__c,Last_Name__c,Extension__c,
				Manager__r.User__c,  Manager__r.Full_Name__c, Manager__r.User__r.IsActive, Community_Nickname__c, First_Name__c,
				Segment__r.Name__c, Division__c, Company_Name__c,Is_Protected_Author__c, Microsoft_Teams_User_Id__c, Microsoft_Teams_User_Name__c, Microsoft_Tenant_Id__c,
				Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c,
				(select connected__c,name from People_Integrations__r)
			FROM People__c 
			WHERE Id IN :peopleIds AND User__r.isActive = true WITH SECURITY_ENFORCED
		];
		return listOfPeople;
	}
	
	public String getUserIdByPeopleId(String peopleId){
		String userId = null;
		List<People__c> listOfPeople;
		
		String queryStr = 'Select User__c FROM People__c Where Id =:peopleId ';
		listOfPeople = 	Database.query(queryStr);
		
		if(listOfPeople.isEmpty() == false) {
			userId = listOfPeople[0].User__c;
		}
		
		return userId;
	}
	
	public List<People__c> getCustomFieldTileData(String sortBy, Integer recordLimit, Integer offset){
		List<People__c> listOfPeople = new List<People__c>();
		String ppId = UserContext.peopleId;
		String categoryId = UserContext.getUserCategory;
		if(String.isNotBlank(categoryId)) {
			String queryStr = PEOPLE_BASE_QUERY + ' Where People_Category__c =:categoryId AND ID !=:ppId' + getUserStatusCondition();
			if ('alphabetical'.equalsIgnoreCase(sortBy)) {
	        	queryStr += ' Order by Full_Name__c asc '; 
			}
			if(recordLimit != null && recordLimit > 0){
	            queryStr+=' LIMIT :recordLimit';
	        }
	        if(offset != null && offset > 0){
	            queryStr+=' OFFSET :offset';
	        }
	        
	        List<People__c> peopleList = Database.query(queryStr);
			listOfPeople = updatePeopleListAccToProfileFields(peopleList);
		
		}
		return listOfPeople;
	}
	
	public List<People__c> getLeadershipTileData(String sortBy, Integer recordLimit, Integer offset){
		String ppId = UserContext.peopleId;
		
		String queryStr = PEOPLE_BASE_QUERY + ' Where Leadership_Sequence__c > 0 ' + getUserStatusCondition();
		if ('alphabetical'.equalsIgnoreCase(sortBy)) {
        	queryStr += ' Order by Full_Name__c asc '; 
		} else {
			queryStr += ' Order by Leadership_Sequence__c asc';
		}
		if(recordLimit != null && recordLimit > 0){
            queryStr+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            queryStr+=' OFFSET :offset';
        }
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	public List<People__c> getMyDirectReportTileData(String sortBy, Integer recordLimit, Integer offset){
		String ppId = UserContext.peopleId;
		String queryStr = PEOPLE_BASE_QUERY + ' Where Manager__c =:ppId ' +getUserStatusCondition();
		if ('alphabetical'.equalsIgnoreCase(sortBy)) {
        	queryStr += ' Order by Full_Name__c asc '; 
		}
		if(recordLimit != null && recordLimit > 0){
            queryStr+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            queryStr+=' OFFSET :offset';
        }
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	public List<People__c> getNewHireTileData(String sortBy, Integer recordLimit, Integer offset){
		String ppId = UserContext.peopleId;
		String queryStr = BASE_QUERY + ' Where Joining_Date__c = LAST_N_DAYS:30 ' +getUserStatusCondition();
		if ('hire_date'.equalsIgnoreCase(sortBy)) {
        		queryStr += ' Order by Joining_Date__c desc, Full_Name__c Asc '; 
		}
		if(recordLimit != null && recordLimit > 0){
            queryStr+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            queryStr+=' OFFSET :offset';
        }
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	public List<People__c> getFollowingTileData(String sortBy, Integer recordLimit, Integer offset){
		List<People__c> listOfPeopleIFollow = new List<People__c>();
		String ppId = UserContext.peopleId;
		List<Id> listOfUserId = new List<Id>(UserContext.usersIFollowIdSet);
		
		String queryStr = PEOPLE_BASE_QUERY + ' Where User__c IN :listOfUserId ' +getUserStatusCondition();
		if('alphabetical'.equalsIgnoreCase(sortBy)) {
        	queryStr += ' Order by Full_Name__c asc '; 
		}
		if(recordLimit != null && recordLimit > 0){
            queryStr+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            queryStr+=' OFFSET :offset';
        }
        logger.logDebug('PeopleDao.getFollowingTileData()----queryStr----' + queryStr);
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
		
	}
	
	public List<People__c> getFavoriteTileData(String sortBy, Integer recordLimit, Integer offset){
		List<Bookmark__c> listOfFavorite = new List<Bookmark__c>();
		
		String favoriteQueryStr = 'SELECT Id, People__c, Type__c, Bookmark_Receiver__c , createddate, Bookmark_Receiver__r.User__c ' +
					   'FROM Bookmark__c '+
					   'WHERE People__c=:loggedInPeopleId AND Type__c=\'People\' AND Is_Deleted__c = false  ';
		
		if(Utility.isApiOnlyUserQueryable()){
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\' AND Bookmark_Receiver__r.User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\')) ';
		}
		
		listOfFavorite = Database.query(favoriteQueryStr);
    	List<Id> favoritePeopleIdsOrderedList = new List<Id>(); 
    	
		for (Bookmark__c favoriteObj : listOfFavorite) {
			favoritePeopleIdsOrderedList.add(favoriteObj.Bookmark_Receiver__c);
		}		
		String queryStr = PEOPLE_BASE_QUERY + ' Where Id IN :favoritePeopleIdsOrderedList ';
		
		if('alphabetical'.equalsIgnoreCase(sortBy)) {
        	queryStr += ' Order by Full_Name__c asc '; 
		}
		if(recordLimit != null && recordLimit > 0){
            queryStr+=' LIMIT :recordLimit';
        }
        if(offset != null && offset > 0){
            queryStr+=' OFFSET :offset';
        }
        logger.logDebug('PeopleDao.getFavoriteTileData()----queryStr----' + queryStr);
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
		
	}
	
	public List<People__c> getMyLocationTileData(String sortBy, Integer recordLimit, Integer offset){
		List<People__c> listOfPeopleInMyLocation = new List<People__c>(); 
		String ppId = UserContext.peopleId;
		String myCity = UserContext.getCurrentUserInfo.City__c;
		String myState = UserContext.getCurrentUserInfo.State__c;
		String myCountry = UserContext.getCurrentUserInfo.Country__c;
		
		if(String.isNotBlank(myCity) || String.isNotBlank(myState) || String.isNotBlank(myCountry)) {
			String locationCondition = '';
			if(String.isNotBlank(myCity)) {
				locationCondition = ' And City__c =:myCity '; 
			}
			if(String.isNotBlank(myState)) {
				locationCondition = ' AND State__c =:myState ';
			}
			if(String.isNotBlank(myCountry)) {
				 locationCondition = ' AND Country__c =: myCountry ';
			}
			
			String queryStr = PEOPLE_BASE_QUERY + ' Where Id !=:ppId ' + locationCondition + getUserStatusCondition();
			if('alphabetical'.equalsIgnoreCase(sortBy)) {
        		queryStr += ' Order by Full_Name__c asc '; 
			}
			if(recordLimit != null && recordLimit > 0){
	            queryStr+=' LIMIT :recordLimit';
	        }
	        if(offset != null && offset > 0){
	            queryStr+=' OFFSET :offset';
	        }
	        logger.logDebug('PeopleDao.getMyLocationTileData()----queryStr----' + queryStr);
			List<People__c> peopleList = Database.query(queryStr);
			listOfPeopleInMyLocation = updatePeopleListAccToProfileFields(peopleList);
		}
		return listOfPeopleInMyLocation;
		
	}

	public static String getCelebrationCondition(Integer daysLimit,Integer todayDayofYear){	
			String conditionString = '';
			if(SimpplrContext.isPPBirthDateDisplay && SimpplrContext.isPPJoiningDateDisplay){
				if(todayDayofYear < 4) {
					maxDayOfYear = 366 - 3 + todayDayofYear;
					minDayOfYear = daysLimit + todayDayofYear;
					conditionString = 'WHERE((Day_Of_Year_J__c >: maxDayOfYear Or Day_Of_Year_J__c  <: minDayOfYear) OR (Day_Of_Year_B__c >: maxDayOfYear Or Day_Of_Year_B__c  <: minDayOfYear))';
				//If less days are left than dayLimit in current year
				} else if(daysLimit > (366 - todayDayOfYear)) {
					minDayOfYear = daysLimit  - (366 - todayDayOfYear);
					maxDayOfYear = todayDayOfYear - 3;
					conditionString = 'WHERE((Day_Of_Year_J__c <: minDayOfYear Or  Day_Of_Year_J__c>: maxDayOfYear) OR  (Day_Of_Year_B__c <: minDayOfYear Or  Day_Of_Year_B__c>: maxDayOfYear))';
				// If more days are left than dayLimit in current year
				} else  {
					minDayOfYear = todayDayOfYear - 3;
					maxDayOfYear = todayDayOfYear + daysLimit;
					conditionString = 'WHERE((Day_Of_Year_J__c >: minDayOfYear  And Day_Of_Year_J__c <: maxDayOfYear) OR (Day_Of_Year_B__c >: minDayOfYear  And Day_Of_Year_B__c <: maxDayOfYear))';
			}
			}else if (SimpplrContext.isPPJoiningDateDisplay){
				if(todayDayofYear < 4) {
					maxDayOfYear = 366 - 3 + todayDayofYear;
					minDayOfYear = daysLimit + todayDayofYear;
					conditionString = 'WHERE(Day_Of_Year_J__c >: maxDayOfYear Or Day_Of_Year_J__c  <: minDayOfYear)';
				//If less days are left than dayLimit in current year
				} else if(daysLimit > (366 - todayDayOfYear)) {
					minDayOfYear = daysLimit  - (366 - todayDayOfYear);
					maxDayOfYear = todayDayOfYear - 3;
					conditionString = 'WHERE(Day_Of_Year_J__c <: minDayOfYear Or  Day_Of_Year_J__c>: maxDayOfYear)';
				// If more days are left than dayLimit in current year
				} else  {
					minDayOfYear = todayDayOfYear - 3;
					maxDayOfYear = todayDayOfYear + daysLimit;
					conditionString = 'WHERE(Day_Of_Year_J__c >: minDayOfYear  And Day_Of_Year_J__c <: maxDayOfYear)';
			}
			}else if (SimpplrContext.isPPBirthDateDisplay){
				if(todayDayofYear < 4) {
					maxDayOfYear = 366 - 3 + todayDayofYear;
					minDayOfYear = daysLimit + todayDayofYear;
					conditionString = 'WHERE(Day_Of_Year_B__c >: maxDayOfYear Or Day_Of_Year_B__c  <: minDayOfYear)';
				//If less days are left than dayLimit in current year
				} else if(daysLimit > (366 - todayDayOfYear)) {
					minDayOfYear = daysLimit  - (366 - todayDayOfYear);
					maxDayOfYear = todayDayOfYear - 3;
					conditionString = 'WHERE(Day_Of_Year_B__c <: minDayOfYear Or  Day_Of_Year_B__c>: maxDayOfYear)';
				// If more days are left than dayLimit in current year
				} else  {
					minDayOfYear = todayDayOfYear - 3;
					maxDayOfYear = todayDayOfYear + daysLimit;
					conditionString = 'WHERE(Day_Of_Year_B__c >: minDayOfYear  And Day_Of_Year_B__c <: maxDayOfYear)';
			} }
			else {
				conditionString = ' WHERE Id = null ';			
			}
			return conditionString;
		}


	public List<People__c> getCelebrations(String filter, Integer daysLimit,Integer todayDayofYear){
		List<Id> listOfUserId = new List<Id>();
		String conditionString = getCelebrationCondition(daysLimit,todayDayofYear);
		if('following'.equalsIgnoreCase(filter)) {
			listOfUserId.addAll(UserContext.usersIFollowIdSet);
			listOfUserId.add(UserContext.Id);
			conditionString += ' AND User__c IN :listOfUserId ';	
		}
		
		String queryStr = BASE_QUERY + conditionString + getUserStatusCondition();
		//logger.logDebug('PeopleDao.getCelebrations()----maxJoiningDate----' + maxJoiningDate);
		logger.logDebug('PeopleDao.getCelebrations()----daysLimit----' + daysLimit);
		logger.logDebug('PeopleDao.getCelebrations()----queryStr----' + queryStr);
		List<People__c> peopleList = Database.query(queryStr);
		return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	public List<People__c> getMustReadRecordHistory(String contentId, String term, String filter, String chatterGroupId, String auditId, String audienceType, Integer recordLimit, Integer offset){
		
		List<String> peopleIdList = getMustReadPeopleIds(contentId, auditId);
		String BASE_QUERY = 'SELECT Id, User__c, Title__c, Street__c, State__c, Department__c, Email__c, Phone__c, Extension__c, User__r.SmallPhotoURL,User__r.FullPhotoURL,About__c, Zoom_Id__c, Skype_Id__c, '+
											' People_Category__r.Name__c, Role__c, Is_Protected_Author__c,User__r.LanguageLocaleKey, User__r.TimeZoneSidKey, ' +
			                              	' Full_Name__c, City__c, Country__c, First_Name__c,Mobile_Phone__c, Last_Name__c,User__r.isactive,Birth_Date__c,Joining_Date__c, Company_Name__c, Segment__r.Name__c, Division__c, Microsoft_Teams_User_Id__c, Microsoft_Teams_User_Name__c, Microsoft_Tenant_Id__c, '+
											' Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c, ' + 
			                              	' (select Confirm_DateTime__c from Must_Read_Confirmed_By__r where content__c=:contentId And Must_Read_Audit__c=:auditId),Community_Nickname__c, ' + 
			                              	' (select id from Bookmark_Receiver_People__r where People__c=:loggedInPeopleId AND Type__c=\'People\' And Is_Deleted__c=false),(Select connected__c, name from People_Integrations__r) ' +
			                              	' FROM People__c';
		String queryStr = BASE_QUERY;
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			queryStr += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) ';
		}
		if('read'.equalsIgnoreCase(filter)){
			queryStr += ' And Id =: peopleIdList ';
		} else if ('unread'.equalsIgnoreCase(filter)){
			queryStr += ' And Id !=: peopleIdList ';
		}

		if(audienceType == 'site_members') {
			queryStr += ' AND Id IN (Select People__c FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = true AND Site__r.Chatter_group_id__c = :chatterGroupId) ';
		}else if(audienceType == 'everyone'){

		} else if(String.isNotBlank(chatterGroupId)) {
			queryStr += ' And User__c IN (SELECT MemberId FROM CollaborationGroupMember Where CollaborationGroupId=:chatterGroupId) ';
		}
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				queryStr+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			queryStr += ' order by CreatedDate asc ';
		} else {
			queryStr += ' Order by Full_Name__c asc';
		}
		if(recordLimit != null && recordLimit > 0){
			queryStr += ' limit ' + recordLimit;
		}
		if(offset != null && offset > 0) {
			queryStr += ' offset '+offset;
		}
		logger.logDebug('PeopleDao.getMustReadRecordHistory()-----queryStr----' + queryStr);
		return Database.query(queryStr);
	}

	/**
	* @description This method returns people ids of users who confirmed must read, 
	* optimized to avoid query of records multiple times in single transaction.
	**/
	public List<String> getMustReadPeopleIds(String contentId, String auditId){
		if(historyList == null || historyList.isEmpty()){
			historyList = [SELECT People__c FROM Must_Read_Confirm_History__c WHERE content__c=:contentId AND Must_Read_Audit__c =: auditId];
		}

		List<String> peopleIdList = new List<String>();
		if(historyList != null && !historyList.isEmpty()){
			for(Must_Read_Confirm_History__c histObj : historyList) {
				peopleIdList.add(histObj.People__c);
			}
		}
		return peopleIdList;
	}

	/**
	* @description This method similar to getMustReadRecordHistory method,
	* but this results total records count, this count required in must read history
	**/
	public Integer getMustReadRecordHistoryCount(String contentId, String term, String filter, String chatterGroupId, String auditId, String audienceType){
		List<String> peopleIdList = getMustReadPeopleIds(contentId, auditId);

		String BASE_QUERY = 'SELECT count() FROM People__c';
		String queryStr = BASE_QUERY;
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			queryStr += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) ';
		}
		if('read'.equalsIgnoreCase(filter)){
			queryStr += ' And Id =: peopleIdList ';
		} else if ('unread'.equalsIgnoreCase(filter)){
			queryStr += ' And Id !=: peopleIdList ';
		}

		if(audienceType == 'site_members') {
			queryStr += ' AND Id IN (Select People__c FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = true AND Site__r.Chatter_group_id__c = :chatterGroupId) ';
		}else if(audienceType == 'everyone'){

		} else if(String.isNotBlank(chatterGroupId)) {
			queryStr += ' And User__c IN (SELECT MemberId FROM CollaborationGroupMember Where CollaborationGroupId=:chatterGroupId) ';
		}
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				queryStr+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		logger.logDebug('PeopleDao.getMustReadRecordHistoryCount()-----queryStr----' + queryStr);
		return Database.countQuery(queryStr);
	}

	public Integer getUnReadCount(String auditId, String contentId, String cgId, String audienceType){
		List<String> peopleIdList = new List<String>();
		List<Must_Read_Confirm_History__c> historyList = [select People__c from Must_Read_Confirm_History__c where content__c=:contentId And Must_Read_Audit__c =: auditId];
		for(Must_Read_Confirm_History__c histObj : historyList) {
			peopleIdList.add(histObj.People__c);
		}
		String queryStr = 'SELECT  count() FROM People__c';
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			queryStr += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) ';
		}
		queryStr += ' And Id !=: peopleIdList ';
		if(String.isNotBlank(cgId)){			
			if(audienceType == 'site_members') {
				queryStr += ' AND Id IN (Select People__c FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = true AND Site__r.Chatter_group_id__c = :cgId) ';
			} else if(audienceType == 'everyone') {
			//Do nothing give all the active member of organisation
			} else {
				queryStr += ' And User__c IN (SELECT MemberId FROM CollaborationGroupMember Where CollaborationGroupId=:cgId) ';
			}
		}	

		return Database.countQuery(queryStr);
	}

	public Integer getReadCount(String auditId, String contentId, String cgId, String audienceType){
		String queryStr = 'SELECT  count() FROM People__c';
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		queryStr += ' And Id IN (select People__c from Must_Read_Confirm_History__c where content__c=:contentId And Must_Read_Audit__c =: auditId) ';
		if(String.isNotBlank(cgId)){			
			if(audienceType == 'site_members') {
				queryStr += ' AND Id IN (Select People__c FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = true AND Site__r.Chatter_group_id__c = :cgId) ';
			} else if(audienceType == 'everyone') {
			//Do nothing give all the active member of organisation
			} else {
				queryStr += ' And User__c IN (SELECT MemberId FROM CollaborationGroupMember Where CollaborationGroupId=:cgId) ';
			}
		}

		return Database.countQuery(queryStr);
	}

	public Map<String,Integer> getReadCountforList(List<Must_Read_Audit__c> mustReadAuditList){
		Map<String, Integer> mustReadCountMap = new Map<String, Integer>();

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', mustReadAuditList);
		
		String queryStr = 'SELECT Must_Read_Audit__c mustReadAuditId, count(Id) readCount FROM Must_Read_Confirm_History__c';
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' Where (People__r.User__r.Show_Simpplr__c =\'Yes\' OR (People__r.user__r.Show_Simpplr__c != \'No\' AND People__r.user__r.isActive=true AND People__r.user__r.UserType=\'Standard\' AND People__r.user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' Where (People__r.User__r.Show_Simpplr__c =\'Yes\' OR (People__r.user__r.Show_Simpplr__c != \'No\' AND People__r.user__r.isActive=true AND People__r.user__r.UserType=\'Standard\')) ';
		}
		queryStr += ' And Must_Read_Audit__c in : soqlParam1 GROUP BY Must_Read_Audit__c';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<AggregateResult> mreadList= (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		for(AggregateResult mRead : mreadList) {
			String mustReadId = (String)mRead.get('mustReadAuditId');
			Integer readCount = ((Integer)mRead.get('readCount'));

			mustReadCountMap.put(mustReadId, readCount);
		}
		
		return mustReadCountMap;
	}

	public Map<String,Integer> getTotalCountforList(List<Must_Read_Audit__c> mustReadAuditList,Set<Id> chatterGpIdSet){
		Map<String, Integer> mustReadTotalCountMap = new Map<String, Integer>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		Map<String, Integer> membMap = new Map<String, Integer>();
		Map<String, Integer> membFollowerMap = new Map<String, Integer>();
		FilterService fls = new FilterService();
		PeopleWrapper.InstallStats installStats = fls.getInstallStats();
		Integer everyoneInOrgCount = installStats.activeLicenseCount;

		soqlParamMap.put('soqlParam1', chatterGpIdSet);
		String queryMembers = 'Select Site__r.Chatter_group_id__c chatterId ,count(Id) siteMembCount FROM Site_Role__c WHERE Is_Deleted__c = false AND Is_Member__c = true AND Site__r.Chatter_group_id__c in :soqlParam1 GROUP BY Site__r.Chatter_group_id__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<AggregateResult> memberList= (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(queryMembers, soqlParamMap);
		for(AggregateResult mList : memberList) {
			membMap.put((String)mList.get('chatterId'), (Integer)mList.get('siteMembCount'));
		}

		String queryMembersAndFollowers = 'SELECT CollaborationGroupId chatterId , count(Id) membCount  FROM CollaborationGroupMember Where CollaborationGroupId in :soqlParam1 GROUP BY CollaborationGroupId';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<AggregateResult> memberFollowerList= (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(queryMembersAndFollowers, soqlParamMap);
		for(AggregateResult m : memberFollowerList) {
			membFollowerMap.put((String)m.get('chatterId'), (Integer)m.get('membCount'));
		}

		for(Must_Read_Audit__c mRead : mustReadAuditList){
			if(String.isNotBlank(mRead.Content__r.Site__r.Chatter_group_Id__c)){			
				if(mRead.Audience_Type__c == 'site_members') {
				   if(membMap.containsKey(mRead.Content__r.Site__r.Chatter_group_Id__c)){
						mustReadTotalCountMap.put(mRead.Id, membMap.get(mRead.Content__r.Site__r.Chatter_group_Id__c));
				   }
				} else if(mRead.Audience_Type__c == 'everyone') {
					mustReadTotalCountMap.put(mRead.Id, everyoneInOrgCount);
				} else {
					if(membFollowerMap.containsKey(mRead.Content__r.Site__r.Chatter_group_Id__c)){
						mustReadTotalCountMap.put(mRead.Id, membFollowerMap.get(mRead.Content__r.Site__r.Chatter_group_Id__c));
					}
				}
			}		
		}

		return mustReadTotalCountMap;
	}

	public List<Must_Read_Audit__c> getMustReadAuditList(String contentId){
		return [Select id, Audience_Type__c, Content__r.Site__r.Chatter_group_Id__c from Must_Read_Audit__c where Content__c=:contentId order by CreatedDate Desc Limit 1];
	}
	
	private String getUserStatusCondition(){
		String whereClause ='';
		if (Utility.isApiOnlyUserQueryable()) {
			whereClause = ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false))';
		} else {
			whereClause = ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\'))';
		}
		return whereClause;
	}
	
	public void updateFirstLoginDateTime() {
		logger.logDebug('PeopleDao.updateFirstLoginDateTime()');
		People__c peopleObj = new People__c(Id=UserContext.peopleId, First_Login_DateTime__c = DateTime.now());
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(peopleObj,new List<Schema.SObjectField> {People__c.First_Login_DateTime__c});
	}
	
	public String ORGCHART_PEOPLE_QUERY = 'SELECT Id, First_Name__c, Last_Name__c, User__c, Title__c, Street__c, State__c,About__c,Community_Nickname__c,'+
			' Mobile_Phone__c, Department__c, Email__c, Phone__c, Extension__c,Manager__c,Birth_Date__c, User__r.SmallPhotoURL, User__r.FullPhotoURL, Full_Name__c, City__c, Country__c, '+
			' Joining_Date__c, User__r.isActive, Company_Name__c, Division__c FROM People__c ';
	
	
	public String getNodeQueryFilterString(){
    	String filterQueryString = '';
    	if(Utility.isApiOnlyUserQueryable()){
				filterQueryString += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				filterQueryString += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
			}
    	return filterQueryString;
    }
	public  String getManagerId(String reporteeId){
    	String managerId = '';
    	if(String.isNotBlank(reporteeId)){
	    	String nodeQuery = ORGCHART_PEOPLE_QUERY + ' WHERE Id=:reporteeId And Manager__r.user__r.isActive=true ';
	    	if(Utility.isApiOnlyUserQueryable()){
	    		nodeQuery += ' And (Manager__r.User__r.Show_Simpplr__c =\'Yes\' OR (Manager__r.user__r.Show_Simpplr__c != \'No\' AND Manager__r.user__r.UserType=\'Standard\' AND Manager__r.user__r.Profile.PermissionsApiUserOnly = false)) ';
				nodeQuery += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				nodeQuery += ' And (Manager__r.User__r.Show_Simpplr__c =\'Yes\' OR (Manager__r.user__r.Show_Simpplr__c != \'No\' AND Manager__r.user__r.UserType=\'Standard\')) ';
				nodeQuery += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
			}
			nodeQuery += ' LIMIT 1 ';
	    	List<People__c> userList = (List<People__c>)Database.query(nodeQuery);
	    	if(!userList.isEmpty()) {
	    		managerId = userList[0].Manager__c;
	    	}
    	} 
    	return managerId;
    }	
	public  People__c getManagerIdAndName(String reporteeId){
    	People__c User = new People__c();
    	if(String.isNotBlank(reporteeId)){
	    	String nodeQuery = ORGCHART_PEOPLE_QUERY + ' WHERE Id=:reporteeId And Manager__r.user__r.isActive=true ';
	    	if(Utility.isApiOnlyUserQueryable()){
	    		nodeQuery += ' And (Manager__r.User__r.Show_Simpplr__c =\'Yes\' OR (Manager__r.user__r.Show_Simpplr__c != \'No\' AND Manager__r.user__r.UserType=\'Standard\' AND Manager__r.user__r.Profile.PermissionsApiUserOnly = false)) ';
				nodeQuery += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				nodeQuery += ' And (Manager__r.User__r.Show_Simpplr__c =\'Yes\' OR (Manager__r.user__r.Show_Simpplr__c != \'No\' AND Manager__r.user__r.UserType=\'Standard\')) ';
				nodeQuery += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
			}
			nodeQuery += ' LIMIT 1 ';
	    	List<People__c> userList = (List<People__c>)Database.query(nodeQuery);
	    	if(!userList.isEmpty()) {
	    		User = userList[0];
	    	}
    	} 
    	return User;
    }
    
    public Map<Id, Integer> getChildCountMap(String nodePeopleId, String managerId){
    	Map<Id, Integer> childCountMap = new Map<Id,Integer>();
    	List<AggregateResult> grandChildCountList = new List<AggregateResult>();

    	if(String.isNotBlank(managerId)){
    		
			String childCountMapQueryStr = ' SELECT count(Id) c, Manager__c  m FROM people__c WHERE Manager__r.Manager__c =: managerId ' +getNodeQueryFilterString() + ' Group By Manager__c ';
    		grandChildCountList = (List<AggregateResult>)Database.query(childCountMapQueryStr) ;
    		for(AggregateResult agg : grandChildCountList){
	    		if((Id)agg.get('m') != null){
	    			childCountMap.put((Id)agg.get('m'),(Integer)agg.get('c'));
	    		}
	    		
	    	}
    	} else {
    		
    		String childCountMapQueryStr = ' SELECT count(Id) c, Manager__c  m FROM people__c WHERE Manager__c =: nodePeopleId ' +getNodeQueryFilterString()+ ' Group By Manager__c ';
    		grandChildCountList = (List<AggregateResult>)Database.query(childCountMapQueryStr);
    		for(AggregateResult agg : grandChildCountList){
	    		childCountMap.put(nodePeopleId,(Integer)agg.get('c'));
	    	}
    	}
    	
    	return childCountMap;
    }
    
    public List<People__c> getNodePeopleList(String nodePeopleId, String managerId){
    	String nodeQuery = '';

    	if(String.isNotBlank(managerId)){
    		nodeQuery = ORGCHART_PEOPLE_QUERY + ' WHERE Manager__c=:managerId  ' + getNodeQueryFilterString();
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				nodeQuery += ' order by CreatedDate asc LIMIT 50';
			} else {
				nodeQuery += ' order by Full_Name__c LIMIT 50 ';
			}
    	} else {
    		nodeQuery = ORGCHART_PEOPLE_QUERY + ' WHERE Id=:nodePeopleId ' + getNodeQueryFilterString();
    	}
    	List<People__c> peopleList = (List<People__c>)Database.query(nodeQuery);
    	return (updatePeopleListAccToProfileFields(peopleList));
    }
    public List<People__c> getPeopleListIndexed(String nodePeopleId, String managerId, String fullName){
    	String nodeQuery = '';
		Integer offset = 0;
        Integer iterator;
    	if(String.isNotBlank(managerId)){
    		String offsetCountQueryStr = ' SELECT count(Id) c FROM people__c WHERE Manager__c=:managerId AND Full_Name__c <: fullName ' + getNodeQueryFilterString();
    		List<AggregateResult> offsetCountList = (List<AggregateResult>)Database.query(offsetCountQueryStr);
    		for(AggregateResult agg : offsetCountList){
                iterator = (Integer)agg.get('c');
	    		offset = iterator > 4 ? iterator - 4 : 0;
	    	}
    		nodeQuery = ORGCHART_PEOPLE_QUERY + ' WHERE Manager__c=:managerId '+getNodeQueryFilterString();
			nodeQuery += ' order by Full_Name__c LIMIT 7 OFFSET :offset ';
		} else {
			nodeQuery = ORGCHART_PEOPLE_QUERY + ' WHERE Id=:nodePeopleId '+getNodeQueryFilterString();
		}
		List<People__c> peopleList = (List<People__c>)Database.query(nodeQuery);
		if(peopleList.size() == 7 && iterator > 3) {
			peopleList.remove(0);
			peopleList.remove(1);
		}
		if(peopleList.size() == 7 && iterator == 3) {
			peopleList.remove(6);
			peopleList.remove(0);
		}
		if(peopleList.size() == 7 && iterator < 3) {
			peopleList.remove(6);
			peopleList.remove(5);
		}
		if(peopleList.size() == 6 && iterator >= 3) {
			peopleList.remove(0);
		}
		if(peopleList.size() == 6 && iterator < 3) {
			peopleList.remove(5);
		}
    	return (updatePeopleListAccToProfileFields(peopleList));
    }
    
    public List<People__c> geOrgChartChildrenNodePeopleList(String managerId, String size, String nextPageToken){
    	String nodeQuery = PEOPLE_BASE_QUERY + ' WHERE Manager__c = :managerId ' + getNodeQueryFilterString();
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			nodeQuery += ' order by CreatedDate asc ';
		} else {
			nodeQuery += ' order by Full_Name__c ';
		}

		Integer recordSize = 0;
		Integer nextPagetokenVal = 0;
		if(String.isNotBlank(size)) {
			recordSize = Integer.valueOf(size);
			nodeQuery += ' LIMIT :recordSize';
			if(String.isNotBlank(nextPageToken)) {
				nextPagetokenVal = Integer.valueOf(nextPageToken);
				nodeQuery += ' OFFSET :nextPagetokenVal';
			}
		} else {
			nodeQuery += ' LIMIT 50 ';
		}

    	List<People__c> peopleList = (List<People__c>)Database.query(nodeQuery);
    	return (updatePeopleListAccToProfileFields(peopleList));
    }
    
    public Map<Id, Integer> geOrgChartChildrenNodeChildCountMap(String managerId){
    	String childCountMapQueryStr = ' SELECT count(Id) c, Manager__c  m FROM people__c WHERE Manager__r.Manager__c =: managerId  ' + getNodeQueryFilterString() + ' Group By Manager__c ';
    	List<AggregateResult> grandChildCountList = (List<AggregateResult>)Database.query(childCountMapQueryStr);
    	Map<Id, Integer> childCountMap = new Map<Id,Integer>();
    	for(AggregateResult agg : grandChildCountList){
    		if((Id)agg.get('m') != null){
    			childCountMap.put((Id)agg.get('m'),(Integer)agg.get('c'));
    		}
    	}
    	return  childCountMap;
    }
    
	public void setCoverImage(String peopleId, String contentDocumentId, String contentVersionId){
   		List<People__c> peopleList = [Select id, Cover_Content_Document_Id__c, Cover_Content_Version_Id__c From People__c where id = :peopleId WITH SECURITY_ENFORCED];
   		if(!peopleList.isEmpty()){
   			peopleList[0].Cover_Content_Document_Id__c = contentDocumentId;
   			peopleList[0].Cover_Content_Version_Id__c = contentVersionId;
   			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c> (peopleList), new List<Schema.SObjectField>{
				People__c.Cover_Content_Document_Id__c,
				People__c.Cover_Content_Version_Id__c
			});
   		}
   	}
   	
   	public List<People__c> getLatestHiresForTilesData (String siteOrHomeId, String segmentId, Integer daysLimit, List<String> peopleIds) {
   		String loggedInPeopleId = UserContext.peopleId;
        String query =  'SELECT Id, Full_Name__c, title__c, City__c, State__c, Country__c, Joining_Date__c, ' + 
        				'User__r.SmallPhotoURL, User__r.FullPhotoURL, Department__c, Role__c,User__r.isactive, ' + 
        				'(SELECT Bookmark_Receiver__c FROM Bookmark_Receiver_People__r ' +
        				'WHERE People__c=:loggedInPeopleId and Type__c=\'People\' And Is_Deleted__c=false) ' +
        				'FROM People__c where ';
        	
		if(peopleIds != null) {
			query += ' Id IN :peopleIds AND ';
		}

        if(Utility.isApiOnlyUserQueryable()){
			query += ' (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\' AND User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\')) ';
		}
		
		if(String.isNotBlank(segmentId)) {
			query += ' AND Segment__c = :segmentId';
    	} else if(String.isNotBlank(siteOrHomeId) && 'home'.equalsIgnoreCase(siteOrHomeId) == false && 'home-default'.equalsIgnoreCase(siteOrHomeId) == false){
			String chatterGroupId = SiteContext.chatterGroupId;
        	query += ' AND user__c IN (Select memberid From CollaborationGroupMember where Member.IsActive=true and CollaborationGroupId =: chatterGroupId) ';
        }
		if(daysLimit != null) {
			query += ' AND Joining_Date__c = LAST_N_DAYS: ' + daysLimit +
				' ORDER BY Joining_Date__c DESC';
		}
        List<People__c> peopleList = Database.query(query);
        return (updatePeopleListAccToProfileFields(peopleList));      
   	}
   	
   	public List<People__c> getPeopleListDataForTiles (List<String> listOfUserIds, String variant) {
   		String query = '';
		String loggedInPeopleId = UserContext.peopleId;
		query = 'SELECT Id,user__c, user__r.name, user__r.userRole.Name, user__r.department,user__r.city,user__r.state, user__r.country,'+
				'user__r.smallPhotoUrl,user__r.FullPhotoUrl,Full_Name__c,title__c,Department__c,city__c,country__c,state__c,User__r.isactive, ' +
				'(SELECT Bookmark_Receiver__c FROM Bookmark_Receiver_People__r ' +
    			'WHERE People__c=:loggedInPeopleId and Type__c=\'People\' And Is_Deleted__c=false) ' + 
				'FROM People__c WHERE User__c IN:listOfUserIds';
		
		if(Utility.isApiOnlyUserQueryable()){
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
					
		String subCondition = ' order by Full_Name__c';
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			subCondition = ' order by CreatedDate asc ';
		}
		List<People__c> peopleList = DataBase.query(query + subCondition);
		return (updatePeopleListAccToProfileFields(peopleList)); 
   	}
   	
   	public List<People__c> peopleListForSiteAboutManagers (List<String> userIdList) {
   		List<People__c> peopleList = [SELECT Id, User__c, User__r.SmallPhotoUrl, Full_Name__c, Title__c, Department__c, 
	  			External_Photo_Url__c, City__c, State__c, Country__c, Email__c, Phone__c, Mobile_Phone__c,
	  			(SELECT People__c, Bookmark_Receiver__c 
				FROM Bookmark_Receiver_People__r WHERE People__c=:UserContext.peopleId 
				AND Type__c='People' And Is_Deleted__c=false )
	  			FROM people__c 
	  			where User__c = : userIdList WITH SECURITY_ENFORCED];
		  return (updatePeopleListAccToProfileFields(peopleList));
	}
	
	public void saveWebPushPromptFlag (Boolean webPushPromptFlag) {
		List<People_Preference__c> ppfObjList = [SELECT Id, Dismissed_Prompt_Web_Notifications__c FROM People_Preference__c WHERE People__c =:UserContext.peopleId WITH SECURITY_ENFORCED];
		
		if (ppfObjList.size() > 0) {
			People_Preference__c ppfObj = ppfObjList[0];

			if(webPushPromptFlag != ppfObj.Dismissed_Prompt_Web_Notifications__c) {
				ppfObj.Dismissed_Prompt_Web_Notifications__c = webPushPromptFlag;

				SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(
																new List<People_Preference__c>{ppfObj}),new List<Schema.SObjectField>{
																	People_Preference__c.Dismissed_Prompt_Web_Notifications__c
															});
			}
		} else {
			throw new SimpplrException(ServiceConstants.SF_EXCEPTION);
		}
					
	}
   	
   	// itemToDismiss is the item we need to save in list which means this item has been read by user.
   	public void dismissOnboarding (String itemToDismiss) {
   		People_Preference__c ppfObj = getPeoplePreferenceRecord();
   		
   		if (ppfObj != null) {
   			String onboardingJSONStr = ppfObj.Dismissed_Onboarding_Flags__c;
	   		Set<String> onboardingSet = new Set<String>();
	   		
	   		if (String.isNotBlank(onboardingJSONStr)) {
	   			onboardingSet.addAll(onboardingJSONStr.split(','));
	   		}
	   		
	   		if (!onboardingSet.contains(itemToDismiss)) {
	   			onboardingSet.add(itemToDismiss);
		   		ppfObj.Dismissed_Onboarding_Flags__c = String.join(new List<String>(onboardingSet), ',');
		   		updateOnboardingJSON(ppfObj);
	   		}
   		} else {
   			throw new SimpplrException(ServiceConstants.SF_EXCEPTION);
   		}
   					
   	}
   	
   	public void resetOnboarding () {
   		People_Preference__c ppfObj = getPeoplePreferenceRecord();
   		
   		if (ppfObj != NULL) {
   			ppfObj.Dismissed_Onboarding_Flags__c = '';
   			updateOnboardingJSON(ppfObj);
   		} else {
   			throw new SimpplrException(ServiceConstants.SF_EXCEPTION);
   		}
   		
   	}
   	
   	private void updateOnboardingJSON (People_Preference__c ppfObj) {
   		
   		if(ppfObj != NULL) {
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(
					new List<People_Preference__c>{ppfObj}),new List<Schema.SObjectField>{
					People_Preference__c.Dismissed_Onboarding_Flags__c});
   		}	
   	}
   	
   	private People_Preference__c getPeoplePreferenceRecord () {
   		List<People_Preference__c> peoplePrefList = [SELECT Id, Dismissed_Onboarding_Flags__c FROM People_Preference__c 
   				WHERE People__c =:UserContext.peopleId WITH SECURITY_ENFORCED];
   		return (peoplePrefList.size() > 0 ? peoplePrefList[0] : NULL);		
   	}

	public List<People_Integration__c> getPeopleIntegrationRecordByProfileIdAndType(String profileId, String type){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', profileId);
		soqlParamMap.put('soqlParam2', type);
		String queryStr = 'SELECT Id, Access_Token__c, User_Name__c,App_Integration__c, User_Email__c, Active__c, Connected__c, Name, External_Id__c, Is_Muted__c FROM People_Integration__c Where People__c=:soqlParam1 AND Name=:soqlParam2 AND Is_Deleted__c= false AND Connected__c=true ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		return peopleIntegList;
	}

	public void deletePeopleIntegrationRecordByProfileIdAndType(String profileId, String type){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', profileId);
		soqlParamMap.put('soqlParam2', type);
		String queryStr = 'SELECT Id,User_Name__c,User_Email__c, Connected__c, Name, External_Id__c, Is_Muted__c FROM People_Integration__c Where People__c=:soqlParam1 AND Name=:soqlParam2 AND Is_Deleted__c= false AND Connected__c=true ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(peopleIntegList.isEmpty()==false){
			peopleIntegList[0].Is_Deleted__c = true;
			peopleIntegList[0].Connected__c = false;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(peopleIntegList[0], new List<Schema.SObjectField>{									
											People_Integration__c.Connected__c,
											People_Integration__c.Is_Deleted__c
											});	
		}
	}

	public void syncGroupMembership() {
		String userId = UserInfo.getUserId();
		List<GroupMember> groupMemberList = [SELECT id, Group.developerName from GroupMember 
											WHERE Group.developerName like 'Simpplr_0F9%'
											AND userorgroupid=:userId WITH SECURITY_ENFORCED];
		List<CollaborationGroupMember> memberList = [select CollaborationGroupId, CollaborationRole from CollaborationGroupMember
													where CollaborationGroup.isArchived=False
													And MemberId=:userId WITH SECURITY_ENFORCED];
		Map<String, String> mapOfGroupMemberShips = new Map<String, String>();
		for(GroupMember gm:groupMemberList) {
			mapOfGroupMemberShips.put(gm.Group.developerName, gm.id);
		}		
		Set<String> setOfPendingGroupDeveloperName = new Set<String>();
		for(CollaborationGroupMember cgm : memberList) {
			String key = 'Simpplr_' + cgm.CollaborationGroupId + '_' + cgm.CollaborationRole;
			if(mapOfGroupMemberShips.containsKey(key)) {
				mapOfGroupMemberShips.remove(key);
			} else {
				setOfPendingGroupDeveloperName.add(key);
			}
		}
		if(mapOfGroupMemberShips.size() > 0) {
			List<GroupMember> listOfGroupMemberToDelete = new List<GroupMember>();
			for(String gmId : mapOfGroupMemberShips.values()) {
				listOfGroupMemberToDelete.add(new GroupMember(Id=gmId));
			}			
			List<AsyncApexJob> currentPendingDeleteGroupMemberJobs = [SELECT Id FROM AsyncApexJob 
																where JobType='future' 
																and MethodName = 'deleteGroupMemberRecords'
																And createdbyid =: userId
																And status not in ('Aborted', 'Completed','Failed')
																WITH SECURITY_ENFORCED
																limit 1];
			if(currentPendingDeleteGroupMemberJobs.isEmpty()) {
				deleteGroupMemberRecords(JSON.serialize(listOfGroupMemberToDelete));
			}
		}
		List<GroupMember> listOfGroupMemberToInsert = new List<GroupMember>();
		List<Group> groupList = [select id, DeveloperName from Group where DeveloperName=:setOfPendingGroupDeveloperName WITH SECURITY_ENFORCED];
		for(Group groupObj: groupList) {
			listOfGroupMemberToInsert.add(new GroupMember(groupId=groupObj.id, UserOrGroupId=userId));
		}
		if(listOfGroupMemberToInsert.size() > 0) {
			List<AsyncApexJob> currentPendingInsertGroupMemberJobs = [SELECT Id FROM AsyncApexJob 
																where JobType='future' 
																and MethodName = 'insertGroupMemberRecords'
																And createdbyid =: userId
																And status not in ('Aborted', 'Completed','Failed')
																WITH SECURITY_ENFORCED
																limit 1];
			if(currentPendingInsertGroupMemberJobs.isEmpty()) {
				insertGroupMemberRecords(JSON.serialize(listOfGroupMemberToInsert));
			}
		}
	}

	@future 
	public static void insertGroupMemberRecords(String memberShipRecords) {
		List<GroupMember> listOfGroupMemberToInsert = (List<GroupMember>)JSON.deserialize(memberShipRecords, List<GroupMember>.class); 
		String userId = UserInfo.getUserId();
		List<AsyncApexJob> currentRunningGroupMemberJobs = [SELECT Id FROM AsyncApexJob 
															where JobType='future' 
															and ((MethodName = 'deleteGroupMemberRecords') OR
																	(MethodName = 'insertGroupMemberRecords' and createdbyid !=: userId))																
															and status = 'Processing'
															WITH SECURITY_ENFORCED
															limit 1];
		if(currentRunningGroupMemberJobs.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(listOfGroupMemberToInsert, new List<Schema.SObjectField>{GroupMember.groupId,GroupMember.UserOrGroupId});
		}
	}
	
	@future 
	public static void deleteGroupMemberRecords(String memberShipRecords) {
		List<GroupMember> listOfGroupMemberToDelete = (List<GroupMember>)JSON.deserialize(memberShipRecords, List<GroupMember>.class); 
		List<GroupMember>  listOfPendingRecordsToDelete = [select id from GroupMember where id in :listOfGroupMemberToDelete WITH SECURITY_ENFORCED];
		if(!listOfPendingRecordsToDelete.isEmpty()) {
			String userId = UserInfo.getUserId();
			List<AsyncApexJob> currentRunningGroupMemberJobs = [SELECT Id FROM AsyncApexJob 
															where JobType='future' 
															and ((MethodName = 'insertGroupMemberRecords') OR
																 (MethodName = 'deleteGroupMemberRecords' and createdbyid !=: userId))																
															and status = 'Processing'
															WITH SECURITY_ENFORCED
															limit 1];
			if(currentRunningGroupMemberJobs.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(listOfPendingRecordsToDelete);
			}
		}
	}

	public void sendMobilePromotionInAppNotification() {
		if (SimpplrContext.appConfig.Mobile_Promotion_Enabled__c && 
					UserContext.getCurrentUserInfo != null &&
					UserContext.getCurrentUserInfo.Mobile_Promotion_Sent_Datetime__c == null 
					&& UserContext.getCurrentUserInfo.Mobile_Token_iOS__c == null && 
					UserContext.getCurrentUserInfo.Mobile_Token_Android__c == null) {

			DateTime currentTime = DateTime.now();
			//Create InAppNotification
			App_Notification__c notificationObj = new App_Notification__c();
			notificationObj.Category__c = 'Mobile_Promotion';
			notificationObj.Type__c = 'Information';
			notificationObj.Sub_Type__c = 'Mobile Promotion';
			notificationObj.Sent_To__c = UserContext.peopleId;
			notificationObj.Created_DateTime__c = currentTime;

			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
			fieldList.add(App_Notification__c.Category__c);
			fieldList.add(App_Notification__c.Type__c);
			fieldList.add(App_Notification__c.Sub_Type__c);
			fieldList.add(App_Notification__c.Sent_To__c);
			fieldList.add(App_Notification__c.Created_DateTime__c);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(notificationObj, fieldList);

			//Update Notification sent datetime	
			People__c peopleObj = new People__c(id=UserContext.getCurrentUserInfo.Id, 
												Mobile_Promotion_Sent_Datetime__c=currentTime);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(peopleObj, new List<Schema.SObjectField>{
				People__c.Mobile_Promotion_Sent_Datetime__c
			});
		}
	}

	public List<AggregateResult> getValues(String term, String columnName, Integer recordLimit) {
		String query = 	' Select ' + columnName + ' value, count(Id) recordCount From People__c ' +
						' Where ' + columnName + ' !=null ';						
		
		if(Utility.isApiOnlyUserQueryable()) {
			query += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				query += ' And ' + columnName + ' like \'%'+searchToken+'%\' ';
			}
		}
		query += ' Group by ' + columnName + ' order by ' + columnName + ' asc ';

		if(recordLimit != null && recordLimit > 0){
			query += ' LIMIT :recordLimit';
		}
		
		String query1='';
		if(String.isNotBlank(term)) {
			query1 = query;
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				query1 = query1.replace('%'+searchToken+'%',searchToken+'%');
			}
		} 
		List<AggregateResult> finalValuesList = New List<AggregateResult>();// Contains the values sorted by Exact match
		List<AggregateResult> tempValuesList = Database.query(query);
		if(query1 != '')
			finalValuesList = Database.query(query1);

		Map<String,AggregateResult> finalValuesVsPeople = new Map<String,AggregateResult>();
		Map<String,Integer> valuesVsLengthMap = new Map<String,Integer>();
		List<Integer> strLenghtList = New List<Integer>();
		Set<Integer> strLenghtSet = New Set<Integer>();
		List<String> valuesVsLengthMapValuesList = New List<String>();
		List<String> tempValuesListFinalValues = New List<String>(); // Contains the values sorted by length of 'tempValuesList'
		if(finalValuesList!=null && !finalValuesList.isEmpty()){
			for(AggregateResult p : finalValuesList){
				finalValuesVsPeople.put(String.valueOf(p.get('value')),p);
			}
		}

		if(tempValuesList!=null && !tempValuesList.isEmpty()){
			Map<String,AggregateResult> tempValuesMap = new Map<String,AggregateResult>();
			for(AggregateResult p : tempValuesList){
				if(!finalValuesVsPeople.containsKey(String.valueOf(p.get('value')))){
					tempValuesMap.put(String.valueOf(p.get('value')),p);
					valuesVsLengthMap.put(String.valueOf(p.get('value')),(String.valueOf(p.get('value'))).length());
					strLenghtList.add((String.valueOf(p.get('value'))).length());
				}
			}
			valuesVsLengthMapValuesList.addAll(valuesVsLengthMap.keySet());
			valuesVsLengthMapValuesList.sort();
			strLenghtSet.addAll(strLenghtList);
			strLenghtList.clear();
			strLenghtList.addAll(strLenghtSet);
			strLenghtList.sort();

			for(Integer lenFromList : strLenghtList){
				for(String dpt : valuesVsLengthMapValuesList){
					if(lenFromList==valuesVsLengthMap.get(dpt) && !tempValuesListFinalValues.contains(dpt)){
						tempValuesListFinalValues.add(dpt);
					}
					else
						continue;
				}
			}

			for(String dpt : tempValuesListFinalValues){
				finalValuesList.add(tempValuesMap.get(dpt));
			}
		}
		return finalValuesList;
	}

	public List<People__c> getValues(String columnName) {
		String packageName = SimpplrContext.packageName;
		String query = 	'Select ' + columnName + ', Id From People__c ' +
			' Where ' + columnName + ' !=null ';
		
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			query += ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
		}
		if(Utility.isApiOnlyUserQueryable()) {
			query += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}

		return Database.query(query);
	}
	
	public Integer getUncategorizedPeopleCount() {
        String queryStr = 'Select count(id) peopleCount from People__c where People_Category__c = null ';
        if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\' AND User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\')) ';
		}
        Integer peopleCount = 0;
        List<AggregateResult> groupedResult = Database.query(queryStr);
        for(AggregateResult res : groupedResult) {
            peopleCount = Integer.valueOf(res.get('peopleCount'));
        }
        return peopleCount;
    }

	public Integer getInactiveUserCount(List<String> peopleIds) {
        Integer peopleCount = 0;
		String queryStr = 'SELECT count(Id) peopleCount FROM People__c WHERE User__r.IsActive = false AND Id = :peopleIds ';
        
		List<AggregateResult> groupedResult = Database.query(queryStr);
        for(AggregateResult res : groupedResult) {
            peopleCount = Integer.valueOf(res.get('peopleCount'));
        }
        return peopleCount;
    }

	public Map<String, Integer> getPeopleCountMap(List<String> categoryIds) {
        String queryStr = 'Select People_Category__c peopleCategory, count(id) peopleCount from People__c where People_Category__c IN :categoryIds ';
        if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\' AND User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\')) ';
		}
		queryStr += ' GROUP BY People_Category__c';
        Map<String, Integer> peopleCountMap = new Map<String, Integer>();
        List<AggregateResult> groupedResult = Database.query(queryStr);
        for(AggregateResult res : groupedResult) {
            peopleCountMap.put(String.valueOf(res.get('peopleCategory')), Integer.valueOf(res.get('peopleCount')));
        }
        return peopleCountMap;
    }

	public void saveLinkedInTokenToDB(String accessTokenArg, Decimal expiresInArg) {
		DateTime currentTime = DateTime.now();
		Decimal expiresIn = expiresInArg;
		if(expiresIn == null) {
			expiresIn = 946080000000.00; // 30 Years
		}
		HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET', 'https://api.linkedin.com/v2/me', 'Bearer ' + accessTokenArg,'');
		String linkedUserId;
		String linkedInUserName;
		if(res.getStatusCode() == 200) {
			Map<String, Object> profileData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			linkedUserId = (String)profileData.get('id');
			linkedInUserName = (String)profileData.get('localizedFirstName') + ' ' + (String)profileData.get('localizedLastName');
		} else {
			throw new SimpplrException(res.getStatus());
		}
		IntegrationService intServiceObj = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN, UserContext.peopleId);
		if(String.isBlank(intServiceObj.integrator.id)){
			intServiceObj.integrator.name = IntegrationConstants.INTEGRATION_TYPE_LINKEDIN;
			intServiceObj.integrator.Access_Token__c = accessTokenArg;
			intServiceObj.integrator.Access_Token_Requested_Datetime__c = currentTime;
			intServiceObj.integrator.Access_Token_Expiration_Datetime__c =  System.now().addSeconds((Integer)expiresInArg - 600);
			intServiceObj.integrator.Access_Token_Expiry__c = expiresIn;
			intServiceObj.integrator.App_Integration__c = intServiceObj.appIntegrator.id;
			intServiceObj.integrator.User_Name__c = linkedInUserName;
			intServiceObj.integrator.External_Id__c = linkedUserId;
			intServiceObj.integrator.People__c = UserContext.peopleId;
			intServiceObj.integrator.User__c = UserContext.userId;
			if(UserContext.getCurrentUserInfo != null){
				intServiceObj.integrator.OwnerId = UserContext.getCurrentUserInfo.User__c;
			}	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(intServiceObj.integrator, new List<Schema.SObjectField>{
					People_Integration__c.name,
					People_Integration__c.Access_Token__c,
					People_Integration__c.Access_Token_Requested_Datetime__c,
					People_Integration__c.Access_Token_Expiration_Datetime__c,
					People_Integration__c.Access_Token_Expiry__c,
					People_Integration__c.App_Integration__c,
					People_Integration__c.User_Name__c,
					People_Integration__c.External_Id__c,
					People_Integration__c.People__c,
					People_Integration__c.User__c,
					People_Integration__c.OwnerId
					});

		} else {
			intServiceObj.integrator.Access_Token__c = accessTokenArg;
			intServiceObj.integrator.Access_Token_Requested_Datetime__c = currentTime;
			intServiceObj.integrator.User_Name__c = linkedInUserName;
			intServiceObj.integrator.External_Id__c = linkedUserId;
			intServiceObj.integrator.Access_Token_Expiration_Datetime__c =  System.now().addSeconds((Integer)expiresInArg - 600);
			intServiceObj.integrator.Access_Token_Expiry__c = expiresIn;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(intServiceObj.integrator, new List<Schema.SObjectField>{
					People_Integration__c.Access_Token__c,
					People_Integration__c.Access_Token_Requested_Datetime__c,
					People_Integration__c.User_Name__c,
					People_Integration__c.External_Id__c,
					People_Integration__c.Access_Token_Expiration_Datetime__c,
					People_Integration__c.Access_Token_Expiry__c
					});
		}
	}

	public Map<String, People__c> findPeopleByValue(String columnAPIName, Set<String> columnValues) {
		Map<String, People__c> pplMap = new Map<String, People__c>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', columnValues);
		String pplQuery = 'SELECT id, user__c, user__r.' + String.escapeSingleQuotes(columnAPIName) + ' FROM People__c WHERE user__r.' + String.escapeSingleQuotes(columnAPIName) + ' IN :soqlParam1 ';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<sObject> peopleList = SIMPESAPI.accessController().queryAsUSer(pplQuery, soqlParamMap);
		
		for(sObject ppl: peopleList) {
			pplMap.put(String.valueOf(ppl.getSObject('User__r').get(columnAPIName)), (People__c) ppl);
		}
		
		return pplMap;
	}

	
	public List<People__c> getCelebrationsForPeoplePosts(String filter, Integer daysLimit,Integer todayDayofYear, Boolean isMobileOrigin){
		List<Id> listOfUserId = new List<Id>();
		String conditionString = getCelebrationCondition(daysLimit,todayDayofYear);
		String queryStr = BASE_QUERY + conditionString + getUserStatusCondition() + getfilterConditionForPeoplePost();
		if(isMobileOrigin) {
			queryStr += ' LIMIT  99';
		}
		logger.logDebug('PeopleDao.getCelebrations()----queryStr----' + queryStr);
		
		List<People__c> peopleList = Database.query(queryStr);

		return (updatePeopleListAccToProfileFields(peopleList));
	}

	public List<People__c> getNewHiresForPeoplePosts(String siteOrHomeId, String segmentId, Integer daysLimit, List<String> peopleIds, Boolean isMobileOrigin) { 
		String loggedInPeopleId = UserContext.peopleId;
		String query =  BASE_QUERY + 'Where ';

		if(peopleIds != null) {
			query += ' Id IN :peopleIds AND ';
		}
					
		if(Utility.isApiOnlyUserQueryable()){
			query += ' (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\' AND User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\')) ';
		}

		if(String.isNotBlank(segmentId)) {
			query += ' AND Segment__c = :segmentId';
		}

		query += getfilterConditionForPeoplePost();

		if(daysLimit != null) {
			query += ' AND Joining_Date__c = LAST_N_DAYS: ' + daysLimit +
				' ORDER BY Joining_Date__c DESC, Full_Name__c ASC';
		}
		
		if(isMobileOrigin) {
			query+= ' LIMIT 99';
		}
		logger.logDebug('PeopleDao.getNewHiresForPeoplePosts() - query '+ query);
		List<People__c> peopleList = Database.query(query);
		return (updatePeopleListAccToProfileFields(peopleList));      
	}
	

	public String getfilterConditionForPeoplePost() {
		String filterCondition;
		
		Integer licencedUsers = 0;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			List<PackageLicense> licenceList= [SELECT Id, UsedLicenses FROM PackageLicense WHERE NamespacePrefix =: packageName];
			licencedUsers = licenceList[0].UsedLicenses;
		}

		filterCondition = ' AND ( ';
		filterCondition += ' Id = :myManagerId OR Manager__c = :loggedInPeopleId OR User__c = :listOfFollowedUserId OR Is_Influencer__c = true OR Manager__c = :myManagerId';
		
		if(licencedUsers < 1000) {
			// if enabled -> division else department -----OR----- similarly city else state

			if(SimpplrContext.isPPDivisionDisplay && String.isNotBlank(myDivision)) {
				filterCondition += ' OR Division__c = :myDivision ';
			
			} else if(String.isNotBlank(myDepartment)) {
				filterCondition += ' OR Department__c = :myDepartment ';
			}

			if(SimpplrContext.isPPCityDisplay && String.isNotBlank(myCity)) {
				filterCondition += ' OR City__c = :myCity ';

			} else if(String.isNotBlank(myState)) {
				filterCondition += ' OR State__c = :myState ';
			}
		}

		filterCondition += ')';

		return filterCondition;
	}

	public List<People__c> getPeopleExpertiseList(String expertiseId, String term, Integer recordLimit, Integer offset) {		
        List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		List<People__c> peopleList = new List<People__c>();
		
		if(String.isNotBlank(expertiseId)){
			String peopleExpertiseInnerQuery = '(SELECT People__c FROM People_Expertise__c WHERE Endorser_Count__c > 0 AND Expertise__c = :expertiseId)';
		String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Id IN ' + peopleExpertiseInnerQuery 
									+ ' AND User__r.isActive = true AND User__r.UserType = \'Standard\' ';
									
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				peopleQuery+=' And Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
									
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			peopleQuery += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		
		peopleQuery += ' ORDER BY Full_Name__c ASC';
									
		if(recordLimit != null && recordLimit > 0){
			peopleQuery += ' LIMIT :recordLimit';
		}
		if(offset != null && offset > 0){
			peopleQuery +=' OFFSET :offset';
		}						 
									
		peopleList = Database.query(peopleQuery);
		}
									
		return peopleList;	
    }
    
    public Map<String, Integer> getTotalPeopleCountForOrg (String requestData) {
		Map<String,Object> requestParams = (Map<String,Object>)JSON.deserializeUntyped(requestData);
		logger.logDebug('PeopleDao.getTotalPeopleCountForOrg() - requestParams --> ' + requestParams);
		Boolean includePreviousRecords = requestParams.containsKey('includePreviousRecords') ? (Boolean) requestParams.get('includePreviousRecords') : false;
		String startDate = requestParams.containsKey('startDate') ? (String) requestParams.get('startDate') : null;
		String endDate = requestParams.containsKey('endDate') ?(String) requestParams.get('endDate') : null;
		String departmentId = requestParams.containsKey('departmentId') ? (String) requestParams.get('departmentId') : null;
		String locationId = requestParams.containsKey('locationId') ? (String) requestParams.get('locationId') : null;


		String query = 'SELECT Count() FROM People__c WHERE ';

		if(Utility.isApiOnlyUserQueryable()){
			query += ' (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\' AND User__r.Profile.PermissionsApiUserOnly = false)) AND ';
		} else {
			query += ' (User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\')) AND ';
		}

		if(String.isNotBlank(departmentId)){
			query += ' Department__c = :departmentId AND ';
		}

		if(String.isNotBlank(locationId)){

			String city = LocationId.SubString(0,(LocationId.indexOf('@@')-1));
			String state = LocationId.SubString((LocationId.indexOf('@@') + 3),(LocationId.lastIndexOf('@@')-1));
			String country = LocationId.SubString((LocationId.lastIndexOf('@@') + 3),LocationId.length());
			
			if(!'null'.equalsIgnoreCase(city)){
				query += ' city__c = :city AND ';
			} else {
				query += ' city__c = null AND ';
			}

			if(!'null'.equalsIgnoreCase(state)){
				query += ' state__c = :state AND ';
			} else {
				query += ' state__c = null AND ';
			}

			if(!'null'.equalsIgnoreCase(country)){
				query += ' country__c = :country AND ';
			} else {
				query += ' country__c = null AND ';
			}
		}

		Map<String, Integer> mapOfResult = new Map<String, Integer>(); 
		if(includePreviousRecords){
			//querying for previous users count to save UI call
			String previousPeopleQuery = query;
			if(String.isNotBlank(startDate)){
				Date startDateValue = Date.valueOf(startDate);
				previousPeopleQuery += ' ((Joining_Date__c = NULL AND DAY_ONLY(createddate) <= :startDateValue) OR (Joining_Date__c != NULL AND Joining_Date__c <= :startDateValue)) ';
			}

			previousPeopleQuery = previousPeopleQuery.removeEnd(' WHERE ');
			previousPeopleQuery = previousPeopleQuery.removeEnd(' AND ');
			logger.logDebug('PeopleDao.getTotalPeopleCountForOrg() - previousPeopleQuery --> '+ previousPeopleQuery);
			Integer totalPreviousPeople = Database.countQuery(previousPeopleQuery);
			mapOfResult.put('totalPreviousRecords', totalPreviousPeople);
		}

		if(String.isNotBlank(endDate)){
			Date endDateValue = Date.valueOf(endDate);
			query += ' ((Joining_Date__c = NULL AND DAY_ONLY(createddate) <= :endDateValue) OR (Joining_Date__c != NULL AND Joining_Date__c <= :endDateValue)) ';
		} 

		query = query.removeEnd(' WHERE ');
		query = query.removeEnd(' AND ');
		logger.logDebug('PeopleDao.getTotalPeopleCountForOrg() - query --> '+ query);
		Integer totalPeople = Database.countQuery(query);
        mapOfResult.put('totalRecords', totalPeople);
        return mapOfResult;
    } 

    public List<People__c> getPeopleByIds (List<String> listOfPeopleId) {
        String peopleQuery = PEOPLE_BASE_QUERY + ' WHERE Id IN : listOfPeopleId ';
        logger.logDebug(peopleQuery);
        List<People__c> listOfPeople = new List<People__c>();
        listOfPeople = Database.query(peopleQuery);
        return listOfPeople;
    }
	

    public List<People__c> getAppManagerList() {		
		List<People__c> peopleList = new List<People__c>();
		String peopleQuery = 'Select id, Full_Name__c ,Segment__c,Segment__r.Branding_JSON__c, App_Moderation_Permission__c, User__r.Email, User__r.LanguageLocaleKey from people__c ' +
                 ' WHERE App_Moderation_Permission__c =\'Yes\' AND User__r.isActive = true AND User__r.UserType = \'Standard\' ';
		peopleList = Database.query(peopleQuery);
		return peopleList;	
	}

	public List<People__c> getAppAndSegmentManagerList() {
		Map<String, Object> soqlParamMap = new Map<String, Object>();

		String peopleQuery = 'Select Id, Full_Name__c, Segment__c, Segment__r.Branding_JSON__c, App_Moderation_Permission__c, User__r.Email, User__r.LanguageLocaleKey FROM people__c ' +
                 ' WHERE App_Moderation_Permission__c =\'Yes\' AND User__r.isActive = true AND User__r.UserType = \'Standard\' ';

		if(SimpplrContext.isSegmentsEnabled){
			peopleQuery = 'Select Id, Full_Name__c, Segment__c, Segment__r.Branding_JSON__c, App_Moderation_Permission__c, User__r.Email, User__r.LanguageLocaleKey FROM people__c ' +
                 ' WHERE User__r.isActive = true AND User__r.UserType = \'Standard\' AND (App_Moderation_Permission__c =\'Yes\' OR Is_Segment_Manager__c = true) ';

		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
	}

	public void updatePeopleOwnerIdToCurrentUserId() {
		People__c peopleRec = new People__c(Id = UserContext.peopleId, OwnerId = UserContext.userId);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(peopleRec,new List<Schema.SObjectField>{People__c.OwnerId});
	}
		
	public void updatePeoplePrefOwnerIdToCurrentUserId() {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);
		String query = 'SELECT Id, OwnerId FROM People_Preference__c where People__c = :soqlParam1 LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		People_Preference__c peoplePrefRec = ((List<People_Preference__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap))[0];
		peoplePrefRec.OwnerId = UserContext.userId;
		SIMPESAPI.accessController().updateAsUser(peoplePrefRec,new List<Schema.SObjectField>{People_Preference__c.OwnerId});
	}

	public void updatePeopleIntegrationOwnerIdToCurrentUserId() {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);
		String query = 'SELECT Id, OwnerId FROM People_Integration__c where People__c = :soqlParam1 AND Is_Deleted__c = false ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntegrationList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(People_Integration__c integrationRec : peopleIntegrationList) {
			integrationRec.OwnerId = UserContext.userId;
		}
		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegrationList), new List<Schema.SObjectField>{People_Integration__c.OwnerId});
	}

	/**
     * @description usersIFollowIdSet is used to get users followed by specifc user
     * @return Set<Id> of users i follow
	 * @param String userId of people for which we want to fetch users i follow id set
     */
	public set<Id> usersIFollowIdSet(String userId){
		String BASE_QUERY = 'Select Id, ParentId From EntitySubscription '+
    					   'where parent.type=\'User\' and  isDeleted=false '+
    					   'AND ParentID IN (SELECT User__c from People__c '+
    					   'WHERE ((User__r.isActive=true And User__r.UserType=\'Standard\' '+
    					   'And User__r.Show_Simpplr__c != \'No\') Or User__r.Show_Simpplr__c = \'Yes\')) '+
    					   'And SubscriberId=:userId';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY+=' And NetworkId = null';
		}
		String SUB_CONDITION = ' Limit 1000';
		String query = BASE_QUERY + SUB_CONDITION;

		Map<Id, EntitySubscription> usersIFollowAndEntitySubscriptionIdMap= new Map<Id, EntitySubscription>();
		List<EntitySubscription> listOfES= new List<EntitySubscription>();
		listOfES = Database.query(query);
		for(EntitySubscription es:listOfES) {
			usersIFollowAndEntitySubscriptionIdMap.put(es.parentId, es);
		}
		return usersIFollowAndEntitySubscriptionIdMap.keyset();
	}

	/**
     * @description getUserByEmail is used to get users by email
     * @return List<People__c> listof users
	 * @param String email 
     */
	public List<People__c> getUserByEmail(String email){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', email);
		soqlParamMap.put('soqlParam2', packageName);
		String query = 'SELECT Id, Country__c ' +
			' FROM People__c '+
			' WHERE Email__c =: soqlParam1 ';
        if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				 query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
			}	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<People__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	}
	
	/**
     * @description getUserByMobileNumber is used to get users using mobile number
     * @return List<People__c> listof users
	 * @param String mobile 
     */
	public List<People__c> getUserByMobileNumber(String mobile){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', mobile);
			soqlParamMap.put('soqlParam2', packageName);
			String query = 'SELECT Id, Country__c ' +
				' FROM People__c '+
				' WHERE mobile_phone__c =: soqlParam1  ';
        	if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				 query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			return (List<People__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	}
    
    
    /**
     * @description getUsersCountByCountry is used to get count of users country wise
     * @return List<AggregateResult> users count by country
     */
	public List<AggregateResult> getUsersCountByCountry(){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', packageName);
		String query = 'Select count(id) noOfPeople, Country__c peopleCountry  from People__c WHERE Country__c != NULL  ';	
        if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam1)';
		}
        query += ' GROUP BY Country__c ';
        return (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    }
    
	/**
     * @description setPeopleNameMapByUserId
     * @param userIds
     */
	public static void setPeopleNameMapByUserId(Set<String> userIds){
		userIds.removeAll(mapUserIdToPeopleName.keySet());
		if(!userIds.isEmpty()) {
			for(People__c peopleObj : [SELECT Id, Full_Name__c, User__c FROM People__c WHERE User__c IN :userIds WITH SECURITY_ENFORCED]) {
				mapUserIdToPeopleName.put(peopleObj.User__c, peopleObj.Full_Name__c);
			}
		}
    }

	/**
     * @description people map used as parameter to created branded email
     * @param peopleId
	 * @return Map<Id,People__c> Map of Id to People
     */
	public Map<Id,People__c> getPeopleMapforEmail(Set<Id> peopleId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		List<People__c> peopleList = new List<People__c>();
		soqlParamMap.put('soqlParam1', peopleId);
		soqlParamMap.put('soqlParam2', packageName);
		String query = 'SELECT Id, User__c, User__r.languageLocaleKey, ' +
			' Segment__c, Segment__r.Branding_JSON__c, Segment__r.Branding_Logo__c ' +
			' FROM People__c '+
			' WHERE User__r.isActive = true AND Id IN: soqlParam1  ';
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		Map<Id, People__c> peopleMap = new Map<Id, People__c>(peopleList);
		return peopleMap;
	}

	/**
	* @description returns peoples map having social compaign manage access, used to send weekly in app notifications
	* @return Map<Id, People__c> people map
	**/
	public static Map<Id, People__c> getPeopleMapManageSocialCompAccess() {	
		Map<String, Object> soqlParamMap = new Map<String, Object>();	
		String peopleQuery = 'SELECT Id, Full_Name__c, App_Moderation_Permission__c, Is_Campaign_Manager__c FROM People__c WHERE (App_Moderation_Permission__c =\'Yes\' OR Is_Campaign_Manager__c = true) AND User__r.isActive = true AND User__r.UserType = \'Standard\' WITH SECURITY_ENFORCED ';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Map<Id, People__c> peopleMap = new Map<Id, People__c>((List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap));
		return peopleMap;	
	}


	/**
     * @description getPeopleIdUserIdMapByPeopleIds 
     * @return Map<id,id> map of people and user ids
	 * @param Set<id> peopleIdSet
     */
	public Map<Id, Id> getPeopleIdUserIdMapByPeopleIds(Set<Id> peopleIdSet){
		Map<Id, Id> peopeIdUserIdMap = new Map<Id, Id> ();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', packageName);
		soqlParamMap.put('soqlParam2', peopleIdSet);
		String query = 'SELECT Id, User__c ' +
			' FROM People__c '+
			' WHERE id IN: soqlParam2 ';
        if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				 query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam1)';
			}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		for(People__c peopleRecord : (List<People__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap)){
			peopeIdUserIdMap.put(peopleRecord.id, peopleRecord.user__c);
		}
		return peopeIdUserIdMap;
	}


	/**
     * @description get getPeopleIdByUserIdMap 
     * @return Map<id,id> map of peopleId by userId map
	 * @param Set<id> userIdSet
     */
	public Map<Id, Id> getPeopleIdByUserIdMap(Set<Id> userIdSet){
		Map<Id, Id> peopleIdByUserIdMap = new Map<Id, Id> ();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', packageName);
		soqlParamMap.put('soqlParam2', userIdSet);
		String query = 'SELECT Id, User__c ' +
			' FROM People__c '+
			' WHERE User__c IN: soqlParam2 ';
        if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				 query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam1)';
			}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		for(People__c peopleRecord : (List<People__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap)){
			peopleIdByUserIdMap.put(peopleRecord.user__c, peopleRecord.id);
		}
		return peopleIdByUserIdMap;
	}


	/**
     * @description get connected user's integration domain 
     * @return String Domain
	 * @param Id peopleId
	 * @param String intType
     */
	public static String getPeopleIntDomainByPeopleId(Id peopleId, String intType){
		String domain = '';
		List<People_Integration__c> peopleIntList = new List<People_Integration__c>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleId);
		soqlParamMap.put('soqlParam2', intType);
		String query = 'SELECT Domain__c, User_Email__c FROM People_Integration__c WHERE '
		+' People__c =: soqlParam1 AND name =: soqlParam2 AND Is_Deleted__c = false'
		+' AND Connected__c = true';
        
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		peopleIntList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(peopleIntList <> NULL && peopleIntList.size()>0){
			if(String.isNotBlank(peopleIntList[0].Domain__c)){
				domain = peopleIntList[0].Domain__c;
			}
			else if(String.isNotBlank(peopleIntList[0].User_Email__c) && peopleIntList[0].User_Email__c.contains('@')){
				domain = peopleIntList[0].User_Email__c.split('@')[1];
			}
		}
		return domain;
	}

	/**
     * @description user id to peopleint domain map
     * @return Map<String, String>
	 * @param Set<String> userIds
	 * @param String type
     */
	public static Map<String, String> getUserIdPeopleIntDomainMap(Set<String> userIds, String type){
		List<People__c> peopleList = new List<People__c>(); 
		Map<String, String> peopleUserMap = new Map<String, String>(); 
		Map<String, Object> peopleSoqlParamMap = new Map<String, Object>();
		peopleSoqlParamMap.put('soqlParam1', userIds);
		String peopleQuery = 'SELECT Id, User__c FROM People__c where User__c IN: soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, peopleSoqlParamMap);
		Set<String> peopleSet = new Set<String>();
		for (People__c people : peopleList){
			peopleUserMap.put(people.Id, people.User__c);
			peopleSet.add(people.Id);
		}
		List<People_Integration__c> peopleIntList = new List<People_Integration__c>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		Map<String, String> userIdPeopleIntDomainMap = new Map<String, String>();
		soqlParamMap.put('soqlParam1', peopleSet);
		soqlParamMap.put('soqlParam2', type);
		String query = 'SELECT Id, Domain__c, People__c FROM People_Integration__c WHERE ' +
		' People__c IN: soqlParam1 AND name =: soqlParam2 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		peopleIntList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(People_Integration__c peopleInt : peopleIntList){
			if(peopleUserMap.containsKey(peopleInt.People__c)){
				userIdPeopleIntDomainMap.put(peopleUserMap.get(peopleInt.People__c), peopleInt.Domain__c);
			}
		}
		return userIdPeopleIntDomainMap;
	}

	public String queryStrUpdate( String queryStr, Criteria.People peopleCriteriaObjArg){
				
		if (peopleCriteriaObjArg.Custom_Field_1 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_1)) {
			Custom_Field_1 = peopleCriteriaObjArg.Custom_Field_1;
			queryStr += ' AND Custom_Field_1__c=:Custom_Field_1 ';
		}  
		
		if (peopleCriteriaObjArg.Custom_Field_2 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_2)) {
			Custom_Field_2 = peopleCriteriaObjArg.Custom_Field_2;
			queryStr += ' AND Custom_Field_2__c=:Custom_Field_2 ';
		}
		
		if (peopleCriteriaObjArg.Custom_Field_3 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_3)) {
			Custom_Field_3 = peopleCriteriaObjArg.Custom_Field_3;
			queryStr += ' AND Custom_Field_3__c=:Custom_Field_3 ';
		} 
		
		if (peopleCriteriaObjArg.Custom_Field_4 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_4)) {
			Custom_Field_4 = peopleCriteriaObjArg.Custom_Field_4;
			queryStr += ' AND Custom_Field_4__c=:Custom_Field_4 ';
		} 
		
		if (peopleCriteriaObjArg.Custom_Field_5 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_5)) {
			Custom_Field_5 = peopleCriteriaObjArg.Custom_Field_5;
			queryStr += ' AND Custom_Field_5__c=:Custom_Field_5 ';
		}
		
		if (peopleCriteriaObjArg.Custom_Field_6 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_6)) {
			Custom_Field_6 = peopleCriteriaObjArg.Custom_Field_6;
			queryStr += ' AND Custom_Field_6__c=:Custom_Field_6 ';
		}
		
		if (peopleCriteriaObjArg.Custom_Field_7 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_7)) {
			Custom_Field_7 = peopleCriteriaObjArg.Custom_Field_7;
			queryStr += ' AND Custom_Field_7__c=:Custom_Field_7 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_8 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_8)) {
			Custom_Field_8 = peopleCriteriaObjArg.Custom_Field_8;
			queryStr += ' AND Custom_Field_8__c=:Custom_Field_8 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_9 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_9)) {
			Custom_Field_9 = peopleCriteriaObjArg.Custom_Field_9;
			queryStr += ' AND Custom_Field_9__c=:Custom_Field_9 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_10 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_10)) {
			Custom_Field_10 = peopleCriteriaObjArg.Custom_Field_10;
			queryStr += ' AND Custom_Field_10__c=:Custom_Field_10 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_11 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_11)) {
			Custom_Field_11 = peopleCriteriaObjArg.Custom_Field_11;
			queryStr += ' AND Custom_Field_11__c=:Custom_Field_11 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_12 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_12)) {
			Custom_Field_12 = peopleCriteriaObjArg.Custom_Field_12;
			queryStr += ' AND Custom_Field_12__c=:Custom_Field_12 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_13 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_13)) {
			Custom_Field_13 = peopleCriteriaObjArg.Custom_Field_13;
			queryStr += ' AND Custom_Field_13__c=:Custom_Field_13 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_14 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_14)) {
			Custom_Field_14 = peopleCriteriaObjArg.Custom_Field_14;
			queryStr += ' AND Custom_Field_14__c=:Custom_Field_14 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_15 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_15)) {
			Custom_Field_15 = peopleCriteriaObjArg.Custom_Field_15;
			queryStr += ' AND Custom_Field_15__c=:Custom_Field_15 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_16 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_16)) {
			Custom_Field_16 = peopleCriteriaObjArg.Custom_Field_16;
			queryStr += ' AND Custom_Field_16__c=:Custom_Field_16 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_17 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_17)) {
			Custom_Field_17 = peopleCriteriaObjArg.Custom_Field_17;
			queryStr += ' AND Custom_Field_17__c=:Custom_Field_17 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_18 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_18)) {
			Custom_Field_18 = peopleCriteriaObjArg.Custom_Field_18;
			queryStr += ' AND Custom_Field_18__c=:Custom_Field_18 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_19 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_19)) {
			Custom_Field_19 = peopleCriteriaObjArg.Custom_Field_19;
			queryStr += ' AND Custom_Field_19__c=:Custom_Field_19 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_20 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_20)) {
			Custom_Field_20 = peopleCriteriaObjArg.Custom_Field_20;
			queryStr += ' AND Custom_Field_20__c=:Custom_Field_20 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_21 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_21)) {
			Custom_Field_21 = peopleCriteriaObjArg.Custom_Field_21;
			queryStr += ' AND Custom_Field_21__c=:Custom_Field_21 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_22 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_22)) {
			Custom_Field_22 = peopleCriteriaObjArg.Custom_Field_22;
			queryStr += ' AND Custom_Field_22__c=:Custom_Field_22 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_23 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_23)) {
			Custom_Field_23 = peopleCriteriaObjArg.Custom_Field_23;
			queryStr += ' AND Custom_Field_23__c=:Custom_Field_23 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_24 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_24)) {
			Custom_Field_24 = peopleCriteriaObjArg.Custom_Field_24;
			queryStr += ' AND Custom_Field_24__c=:Custom_Field_24 ';
		}

		if (peopleCriteriaObjArg.Custom_Field_25 != null && !'all'.equalsIgnoreCase(peopleCriteriaObjArg.Custom_Field_25)) {
			Custom_Field_25 = peopleCriteriaObjArg.Custom_Field_25;
			queryStr += ' AND Custom_Field_25__c=:Custom_Field_25 ';
		}
		return queryStr;
	}
}