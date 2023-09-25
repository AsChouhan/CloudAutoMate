public with sharing class MobileSiteDao {

	@TestVisible private String loggedInPeopleId = UserContext.peopleId;
	String SIMPPLR_APP_HOME_CHATTER_GROUP_ID = 'S06I000000MPPLR';
	@TestVisible private String userSegmentId = UserContext.segmentId; 
	
    String BASE_QUERY = 'Select Id, Show_In_Simpplr__c, Is_Deleted__c, Name, Has_Albums__c, Has_Events__c, Has_Pages__c, Landing_Page__c, Chatter_Group_Id__c, Site_Type__c, Is_Active__c, Is_Featured__c, Site_Category__r.Name__c ,Site_Category__c, Title_Content_Document__c, Title_Content_Version__c,Slack_Channel_Name__c,Slack_Url__c,Member_Count__c,Follower_Count__c,'+
			'(SELECT Id, Type__c, CreatedById FROM Bookmarked_Simpplr_Site__r WHERE People__c =:loggedInPeopleId AND Type__c=\'site\' AND Is_Deleted__c = false ), '+
			'(SELECT id FROM Site_Membership_Request__r WHERE Request_By__c=:loggedInPeopleId AND Status__c=\'Pending\'), '+
			'(SELECT Id, Is_Featured__c FROM Site_Segments__r WHERE Segment__c =: userSegmentId), ' +
			'(SELECT Id FROM Subscription_Entity_Site__r WHERE Subscription__r.Action_Type__c = \'mandatory\' AND Status__c = \'Approved\' AND Subscription__r.Status__c != \'Deleted\' '+
			' AND (Subscription__r.Audience__r.Segment__c = : userSegmentId OR Subscription__r.Audience__r.Segment__c = null)) ' +
			'FROM Simpplr_Site__c WHERE Chatter_Group_Id__c !=: SIMPPLR_APP_HOME_CHATTER_GROUP_ID AND Is_Active__c=true AND Show_In_Simpplr__c = true';
    
    String CACHE_BASE_QUERY = ' Select Id, Show_In_Simpplr__c, Is_Deleted__c, Name, Has_Albums__c, Has_Events__c, Has_Pages__c, Landing_Page__c, Chatter_Group_Id__c, Site_Type__c, Is_Active__c, Is_Featured__c, Site_Category__r.Name__c ,Site_Category__c, Title_Content_Document__c, Title_Content_Version__c,Slack_Channel_Name__c,Slack_Url__c,Member_Count__c,Follower_Count__c,'+
			'(SELECT Id, Type__c, CreatedById FROM Bookmarked_Simpplr_Site__r WHERE People__c =:loggedInPeopleId AND Type__c=\'site\' AND Is_Deleted__c = false ), '+
			'(SELECT id FROM Site_Membership_Request__r WHERE Request_By__c=:loggedInPeopleId AND Status__c=\'Pending\'), '+
			'(SELECT Id, Is_Featured__c FROM Site_Segments__r WHERE Segment__c =: userSegmentId), '+
			'(SELECT Id FROM Subscription_Entity_Site__r WHERE Subscription__r.Action_Type__c = \'mandatory\' AND Status__c = \'Approved\' AND Subscription__r.Status__c != \'Deleted\' '+
			' AND (Subscription__r.Audience__r.Segment__c = : userSegmentId OR Subscription__r.Audience__r.Segment__c = null)) ' +
			' FROM Simpplr_Site__c ';
	
	public Map<Id,Simpplr_Site__c> getSitesForCaching(Set<Id> siteIdSet) {
		String queryStr = CACHE_BASE_QUERY + ' WHERE Id =: siteIdSet'; 
		return new Map<Id,Simpplr_Site__c>((List<Simpplr_Site__c>)Database.query(queryStr));
	}
	
	@testVisible
	private Set<Id> getOffsetSiteIdSet(Set<Id> setOfCollabIds,Integer size, Integer offset){
		Set<Id> siteIdSet = new Set<Id>();
	    List<Simpplr_Site__c> siteList = [SELECT Id FROM Simpplr_Site__c WHERE Chatter_Group_Id__c IN :setOfCollabIds WITH SECURITY_ENFORCED order by CreatedDate];
	    Integer loopIterationIndex = (size+offset) > siteList.size()? siteList.size():(size+offset);
	    for(Integer Counter = offset; Counter<loopIterationIndex;  Counter++){
	    	siteIdSet.add(siteList[Counter].Id);
	    }
	    return siteIdSet;
	}
	
	public Map<Id,Simpplr_Site__c> getOffsetSiteIdSet(Set<Id> setOfCollabIds){
		String queryStr = CACHE_BASE_QUERY + ' WHERE Chatter_Group_Id__c =: setOfCollabIds';
		
		return new Map<Id,Simpplr_Site__c>((List<Simpplr_Site__c>)Database.query(queryStr));	    
	}    
    
    public Map<String,Integer> getMapOfSiteAndContentCount(){
    	Map<String,Integer> mapOfSiteAndContentCount = new Map<String,Integer>{'siteCount'=>0,'contentCount'=>0};
    	
    	Set<Id> cgIdSet = CollaborationGroupIdSet; 
    	List<Simpplr_Site__c> siteList = [select id, Chatter_Group_Id__c, Site_Type__c from Simpplr_Site__c where Show_In_Simpplr__c = true AND Is_Deleted__c = false AND Chatter_Group_Id__c IN:cgIdSet WITH SECURITY_ENFORCED];
    	Set<Id> privateCGIFollowSet = getPrivateCGIdIFollow();
    	Integer contentCount = 0;
    	if(UserContext.hasModifyAllDataPermission == false){
    		contentCount = [select count() from Simpplr_Content__c Where  Is_Deleted__c = false AND Status__c = 'Approved'  AND (Site__c = null OR Site__r.Site_Type__c = 'Public' OR Site__r.Chatter_Group_Id__c IN: privateCGIFollowSet) WITH SECURITY_ENFORCED];
    	} else {
    		contentCount = [select count() from Simpplr_Content__c Where  Is_Deleted__c = false AND Status__c = 'Approved'  AND (Site__c = null OR Site__r.Chatter_Group_Id__c IN: cgIdSet)];	
    	}
    	mapOfSiteAndContentCount.put('siteCount',siteList.size());
    	mapOfSiteAndContentCount.put('contentCount',contentCount);
    	return mapOfSiteAndContentCount;
    }
    
    public Set<Id> getPrivateCGIdIFollow(){
		List<CollaborationGroupMember> collGrpMemList =  [select CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId=:UserContext.userId AND (CollaborationGroup.CollaborationType = 'Private' OR CollaborationGroup.CollaborationType = 'Unlisted') WITH SECURITY_ENFORCED];
		Set<Id> privateMemberCollGrpIdSet = new Set<Id>();
		for(CollaborationGroupMember cggrpMemObj : collGrpMemList){
			privateMemberCollGrpIdSet.add(cggrpMemObj.CollaborationGroupId);
		}  
		return privateMemberCollGrpIdSet;
    }
    
    public Map<Id,Simpplr_Site__c> getAllFeaturedSites(String textSearch, Integer offset, Integer recordLimit, String categoryId) {
		
		Set<Id> cgIdSet = CollaborationGroupIdSet;
		String queryStr = BASE_QUERY+' And chatter_Group_id__c=:cgIdSet AND Is_Featured__c=true ';
		
		if(String.isNotBlank(textSearch)) {
			queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}
		
		if(String.isNotBlank(categoryId)){
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				queryStr += ' AND Site_Category__c = null ';
			} else if (!'all'.equalsIgnoreCase(categoryId)) {
	        	queryStr += ' AND Site_Category__c =:categoryId ';
	        }
		}
        queryStr += ' Order by Order__c, Name ';
		queryStr += ' limit ' + recordLimit + ' offset '+offset; 	
		return new Map<Id,Simpplr_Site__c>((List<Simpplr_Site__c>)Database.query(queryStr));
	}
	
	public List<Simpplr_Site__c> getAllLatestSites(String textSearch, Integer offset, Integer recordLimit, String categoryId) {
		
		Set<Id> cgIdSet = CollaborationGroupIdSet;
		String queryStr = BASE_QUERY+' And chatter_Group_id__c=:cgIdSet ';
		
		if(String.isNotBlank(textSearch)) {
			queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}
		
		if(String.isNotBlank(categoryId)){
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				queryStr += ' AND Site_Category__c = null ';
			} else if (!'all'.equalsIgnoreCase(categoryId)) {
	        	queryStr += ' AND Site_Category__c =:categoryId ';
	        }
		}
        queryStr += ' Order by createdDate desc ';
		queryStr += ' limit ' + recordLimit + ' offset '+offset;		
		return Database.query(queryStr);
	}
	
	public List<Simpplr_Site__c> getAllSites(String textSearch, Integer offset, Integer recordLimit, String categoryId) {
		
		Set<Id> cgIdSet = CollaborationGroupIdSet;
		String queryStr = BASE_QUERY+' And Chatter_Group_Id__c=:cgIdSet ';
		
		if(String.isNotBlank(textSearch)) {
			queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}
		
		if(String.isNotBlank(categoryId)){
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				queryStr += ' AND Site_Category__c = null ';
			} else if (!'all'.equalsIgnoreCase(categoryId)) {
	        	queryStr += ' AND Site_Category__c =:categoryId ';
	        }
		}
        queryStr += ' Order by Name ';
		queryStr += ' limit ' + recordLimit + ' offset '+offset;		
		return Database.query(queryStr);
	}
	
	public List<Bookmark__c> getAllFavoriteSites(String textSearch, Integer offset, Integer recordLimit, String categoryId) {
		List<Id> listOfSelectedUsersChatterGroupIds = new List<Id>();
		Set<Id> cgIdSet = CollaborationGroupIdSet;
		
		String bookmarkQueryStr = ' Select Simpplr_Site__c, Simpplr_Site__r.Chatter_Group_Id__c from Bookmark__c '+
							  ' WHERE Type__c=\'Site\'  AND Is_Deleted__c = false And people__c =: loggedInPeopleId And Simpplr_Site__r.Is_Active__c=true AND Simpplr_Site__r.Show_In_Simpplr__c=true And Simpplr_Site__r.Is_Deleted__c = false AND Simpplr_Site__r.Chatter_Group_Id__c=:cgIdSet';
							  
		if(String.isNotBlank(textSearch)) {
			bookmarkQueryStr += getSearchTermConditionForParentSite(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}
		
		if(String.isNotBlank(categoryId)){
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				bookmarkQueryStr += ' AND Simpplr_Site__r.Site_Category__c = null ';
			} else if (!'all'.equalsIgnoreCase(categoryId)) {
	        	bookmarkQueryStr += ' AND Simpplr_Site__r.Site_Category__c =:categoryId ';
	        }
		}
		bookmarkQueryStr += ' order by lastModifiedDate desc ';
		bookmarkQueryStr += ' limit ' + recordLimit + ' offset '+offset;
		return Database.query(bookmarkQueryStr);
	}
	
	public static Set<Id> CollaborationGroupIdSet {
		get {
			if(CollaborationGroupIdSet == null){
				String queryStr = 'SELECT Id FROM CollaborationGroup ';
				if(SimpplrContext.isCommunitiesEnabled){
			    		queryStr += ' Where NetworkId = null';
			    }
			    		
			    Map<Id, CollaborationGroup> mapOfAllCollaborationGrp = new Map<Id, CollaborationGroup>((List<CollaborationGroup>)Database.query(queryStr));
			    CollaborationGroupIdSet = mapOfAllCollaborationGrp.keySet();
			}
		return CollaborationGroupIdSet;
		}
		private set;
	}
	
	public Map<Id, CollaborationGroup> getMapOfAllCollaborationGrp(){
		String userIdArg = UserContext.id;
		String CG_QUERY = 'SELECT Id, OwnerId, description, MemberCount, IsBroadcast, (SELECT Id, CollaborationGroupId, MemberId, CollaborationRole FROM GroupMembers WHERE MemberId =:userIdArg),'
				+'(SELECT status FROM GroupMemberRequests WHERE status =\'Pending\' AND RequesterId =:userIdArg) FROM CollaborationGroup ';
		if(SimpplrContext.isCommunitiesEnabled){
	    		CG_QUERY = CG_QUERY+' Where NetworkId = null';
	    }
 		return new Map<Id, CollaborationGroup>((List<CollaborationGroup>)Database.query(CG_QUERY));
	}
	   
	public List<Simpplr_Site__c> getAllFollowingSites(String textSearch, Integer offset, Integer recordLimit, String categoryId) {
		List<CollaborationGroupMember> listOfCollaborationGrpMem = getCollaborationGrpFollowedBy(UserContext.id);
		List<Id> listOfCollabGrpId = new List<Id>();
		
		for (CollaborationGroupMember grpMemberObj : listOfCollaborationGrpMem) {
			listOfCollabGrpId.add(grpMemberObj.CollaborationGroupId);
		}
		
		String queryStr = BASE_QUERY+ ' AND Chatter_Group_Id__c=:listOfCollabGrpId ';
		
		if(String.isNotBlank(textSearch)) {
			queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}
		
		if(String.isNotBlank(categoryId)){
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				queryStr += ' AND Site_Category__c = null ';
			} else if (!'all'.equalsIgnoreCase(categoryId)) {
	        	queryStr += ' AND Site_Category__c =:categoryId ';
	        }
		}
        
       	queryStr += ' Order by Name ';
		queryStr += ' limit ' + recordLimit + ' offset '+offset;		
		return Database.query(queryStr);
	}
	
	public List<CollaborationGroupMember> getCollaborationGrpFollowedBy(String userId) {
		List<CollaborationGroupMember> listOfCollborationGrpMember = new List<CollaborationGroupMember>();
		String BASE_QUERY = 'SELECT  CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId=:userId';
		if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+' AND CollaborationGroup.NetworkId = null';
	    }
		listOfCollborationGrpMember = Database.query(BASE_QUERY);
				
		return listOfCollborationGrpMember;
	}
	@testVisible
	private String getSearchTermCondition(Set<String> setOfSearchTerms){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
    			queryStr += ' And Name like \'%'+searchToken+'%\' ';
			}
        }
        return queryStr;
	}
	
	private String getSearchTermConditionForParentSite(Set<String> setOfSearchTerms){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
    			queryStr += ' And Simpplr_Site__r.Name like \'%'+searchToken+'%\' ';
			}
        }
        return queryStr;
	}
	
	public Set<Id> getSitesFavOrUnFavIDSet(DateTime pollTimeStamp){
		Set<Id> sitesFavOrUnFavIDSet = new Set<Id>();
		List<Bookmark__c> bookmarkList = [Select Simpplr_Site__c From Bookmark__c Where  Type__c = 'Site' AND LastModifiedById =: UserContext.userId AND LastModifiedDate >: pollTimeStamp WITH SECURITY_ENFORCED];
		for(Bookmark__c bookMarkObj : bookmarkList){
			sitesFavOrUnFavIDSet.add(bookMarkObj.Simpplr_Site__c);
		}
		return sitesFavOrUnFavIDSet;
	}
}