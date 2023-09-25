public with sharing class MobileContentDao {
	
	@TestVisible private String loggedInPeopleId = UserContext.peopleId;
	List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
	
	private DateTime startTime;
	private DateTime endTime;
    private DateTime currentTime = DateTime.now(); 
    private DateTime startTimeForLaterSection;
	private Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
	private Map<String,Integer> mapOfDayWithNumberOfDaysToAdd = new Map<String,Integer>{
		'Mon'=>6,
		'Tue'=>5,
		'Wed'=>4,
		'Thu'=>3,
		'Fri'=>2,
		'Sat'=>1,
		'Sun'=>0
	};
    
    public List<Simpplr_Content__c> getAlbums(String term, String siteId, Integer offset, Integer recordLimit, String sortBy) {
		String albumType = ServiceConstants.TYPE_ALBUM;
		String queryStr = 'SELECT ' + String.join(getContentFieldList() ,',')+ ' FROM Simpplr_Content__c WHERE Status__c =\'Approved\' AND Type__c =:albumType '+
		'AND Is_Published__c = true '+
		'AND Is_Deleted__c = false '+
		'AND Site__r.Has_Albums__c = true ' +
		'AND Site__r.Show_In_Simpplr__c = true AND Site__r.is_Active__c=true ';
		queryStr += ' AND Site__c =:siteId  ';
		queryStr += getAlbumSortOrderCondition(sortby);
		queryStr += ' limit :recordLimit  offset :offset';
		return Database.query(queryStr);
    }
    
    public List<Simpplr_Content__c> getPages(String term, String siteId, Integer offset, Integer recordLimit, String sortBy, String categoryId) {
			String pageType = ServiceConstants.TYPE_PAGE;
			String queryStr = 'SELECT ' + String.join(getContentFieldList() ,',')+ ' FROM Simpplr_Content__c WHERE Site__r.Show_In_Simpplr__c = true AND Status__c =\'Approved\' AND Type__c =:pageType '+
			'AND Is_Published__c = true '+
			'AND Is_Deleted__c = false '+
			'And Site__r.Has_Pages__c = true ' +
			'And Site__r.is_Active__c=true ';
			queryStr += ' AND Site__c =:siteId  ';
			if(String.isNotBlank(categoryId)){
				queryStr += ' AND Pages_Category__c =:categoryId ';
			}
			queryStr += getPageSortOrderCondition(sortby);
			queryStr += ' limit :recordLimit  offset :offset';
            return Database.query(queryStr);
        
    }
    
    public List<Simpplr_Content__c> getBlogs(String term, String peopleId, Integer offset, Integer recordLimit, String sortBy) {
			String blogType = ServiceConstants.TYPE_BLOGPOST;
			String queryStr = 'SELECT ' + String.join(getContentFieldList() ,',')+ ' FROM Simpplr_Content__c WHERE Status__c =\'Approved\' AND Type__c =:blogType '+
			'AND Is_Published__c = true '+
			'AND Is_Deleted__c = false ';
			queryStr += ' AND Primary_Author__c =:peopleId  ';
			queryStr += getBlogSortOrderCondition(sortby);
			queryStr += ' limit :recordLimit  offset :offset';
            return Database.query(queryStr);
    }
    
    @testVisible
    private String getPageSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			if (sortby.equalsIgnoreCase('DisplayOrder')) {
            	queryStr += ' Order by Display_Order__c, Last_Edited_DateTime__c  DESC, publish_start_datetime__c desc '; 
				queryStr += SimpplrContext.isFeatureEnabled('Full_External_Search') ? '' : ', Title__c ';
            } else if (sortby.equalsIgnoreCase('Latest') ) {
            	queryStr += ' Order by Last_Edited_DateTime__c desc '; 
            }
		}
        return queryStr;
	}
	
	@testVisible
    private String getBlogSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			if (sortby.equalsIgnoreCase('Latest') ) {
            	queryStr += ' Order By Publish_Start_DateTime__c Desc, Last_Edited_DateTime__c desc '; 
				queryStr += SimpplrContext.isFeatureEnabled('Full_External_Search') ? '' : ', Title__c asc ';
            }
		}
        return queryStr;
	}
	
    public List<Simpplr_Content__c> getEvents(String term, String siteId, String peopleId, String filter, String period, Integer offset, Integer recordLimit, String sortBy) {
    	
			String eventType = ServiceConstants.TYPE_EVENT;
			String queryStr = 'SELECT ' + String.join(getContentFieldList() ,',')+' FROM Simpplr_Content__c WHERE Site__r.Show_In_Simpplr__c = true AND Status__c =\'Approved\' AND Type__c =:eventType '+
		            'AND Is_Published__c = true '+
		            'AND Is_Deleted__c = false '+
		            'And Site__r.Has_Events__c = true '+
		            'And Site__r.is_Deleted__c=false '+
		            'And Site__r.is_Active__c=true ';
		    
		    Set<Id> eventIdSet = new Set<Id>();
		   	Set<Id> chatterGroupsIFollowIdSet = new Set<ID>();
		   	
		    if(String.isNotBlank(siteId)){        
				queryStr += ' AND Site__c =:siteId  ';
		    } else if(String.isNotBlank(peopleId)){
				eventIdSet.addAll(getEventsWithRSVPYes());
				chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
				queryStr += ' AND (site__r.chatter_group_id__c IN :chatterGroupsIFollowIdSet OR ID IN:eventIdSet)';
		    }
		   	
			queryStr += getEventFilterCondition(filter, period);
			queryStr += getEventSortOrderCondition(sortby,filter);
			queryStr += ' limit :recordLimit  offset :offset';
          	return Database.query(queryStr);
    }
    
    private String getEventFilterCondition(String filter , String period){
	    String queryStr = '';
	    
		if(String.isNotBlank(filter)){
			 if('future'.equalsIgnoreCase(filter)){
			    Date weekEndDate = (Date.today()).addDays(mapOfDayWithNumberOfDaysToAdd.get(currentTime.format('EEE')));
			    DateTime startDateTimeOfNextWeek = DateTime.newInstance(weekEndDate.addDays(1).year(),weekEndDate.addDays(1).month(),weekEndDate.addDays(1).day(),0,0,0);
			    
	            if('this_week'.equalsIgnoreCase(period)){
	                startTime = currentTime;
	                endTime = DateTime.newInstance(weekEndDate.year(),weekEndDate.month(),weekEndDate.day(),23,59,59);
	                queryStr +=  ' AND ('+
	                          '(Event_Start_DateTime__c >=:startTime AND Event_Start_DateTime__c <=:endTime) OR ' +    
	                          '(Event_Start_DateTime__c <=:startTime AND Event_End_DateTime__c >=:startTime)'+
	                          ') ';
	            }else if('this_month'.equalsIgnoreCase(period)){
	            		startTime = startDateTimeOfNextWeek;
	            		endTime = DateTime.newInstance(currentTime.year(),currentTime.month(),Date.daysInMonth(currentTime.year(),currentTime.month()),23,59,59);
		            
		            	queryStr +=  ' AND '+ '(Event_Start_DateTime__c >=:startTime AND Event_Start_DateTime__c <=:endTime) ';
		            	
		        }else if('after_this_month'.equalsIgnoreCase(period)){
		            	Integer year = currentTime.month() == 12 ? currentTime.year()+1 : currentTime.year();
		            	Integer month = currentTime.month() == 12 ? 1 : currentTime.month()+1;
	                	startTime = DateTime.newInstance(year,month,1,0,0,0);
	                	endTime = DateTime.newInstance(weekEndDate.year(),weekEndDate.month(),weekEndDate.day(),23,59,59);
	                queryStr +=  ' AND '+
		                          '(Event_Start_DateTime__c >=:startTime AND Event_Start_DateTime__c >: endTime) ';
		         }
			}
		}
	    return queryStr; 
    }
    
    public List<Bookmark__c> getFavoriteContentList(String contentType, String searchText, Integer recordLimit, Integer offsetVal){
    	try {
        	String conditionString = ' Where People__c =:loggedInPeopleId ';
	        conditionString += ' And Simpplr_Content__r.TYPE__c IN : allowedFeaturesInAppList';
        	conditionString += ' And Simpplr_Content__r.Is_Deleted__c = false';
        	conditionString += ' AND Simpplr_Content__r.Activated_By_Feature__c = true';
        	conditionString += ' And ( Simpplr_Content__r.type__c = \'BlogPost\' OR (Simpplr_Content__r.Site__r.Show_In_Simpplr__c = true AND Simpplr_Content__r.Site__r.is_Active__c = true)) ';
        	conditionString += ' AND Simpplr_Content__r.Is_Published__c = true ';
        	conditionString += ' AND Is_Deleted__c = false ';
	        
	        if(String.isNotBlank(searchText)) {
	        	Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
	            conditionString += getSearchTermCondition(setOfSearchTerms, 'Simpplr_Content__r.Title__c');
	        }
	        
	        if(String.isNotBlank(contentType) && !'All'.equalsIgnoreCase(contentType)) {
	        	conditionString += ' And Simpplr_Content__r.TYPE__c=:contentType ';
	        }
	        
	        String subConditionString = ' Order by LastModifiedDate Desc ';
	        if(recordLimit != null && recordLimit > 0){
	            subConditionString+=' LIMIT :recordLimit';
	        }
	        if(offsetVal != null && offsetVal > 0){
	            subConditionString+=' OFFSET :offsetVal';
	        }
	        
        	String bookmarQuery  =  ' Select Simpplr_Content__c from Bookmark__c  ' + conditionString + subConditionString;
									 
         return Database.query(bookmarQuery);
	    				   
	    } catch(Exception e){
			throw new SimpplrException('Favorite content list exception', e);
    		}
    }
    
    @testVisible
    private String getSearchTermCondition(Set<String> setOfSearchTerms, String fieldToSearch){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
				queryStr += ' And ' + fieldToSearch + ' like \'%' + searchToken + '%\' ';
			}
        }
        return queryStr;
	}
	
    private String getEventSortOrderCondition(String sortby,String filter){
		String queryStr = '';
		if('future'.equalsignorecase(filter)){
			queryStr += ' Order by Event_Start_DateTime__c asc, Event_End_DateTime__c asc ';
		}else if('past'.equalsignorecase(filter)){
			queryStr += ' Order by Event_End_DateTime__c desc, Event_Start_DateTime__c desc ';
		}else{
			queryStr += ' Order by Event_Start_DateTime__c asc ';
		}
        return queryStr;
	}
    @testVisible
    private String getAlbumSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
            	queryStr += 'Order By Publish_Start_DateTime__c Desc, Last_Edited_DateTime__c desc ';
				queryStr += SimpplrContext.isFeatureEnabled('Full_External_Search') ? '' : ', Title__c asc ';
		}
        return queryStr;
	}
	
    public List<AggregateResult> getContentCountsPerCategory(List<String> listOfCategoryIds, String siteId) {
    	AggregateResult[] groupedResults = [Select pages_Category__c categoryId, count(Id)
											From Simpplr_Content__c
											Where pages_Category__c =:listOfCategoryIds
											AND site__c=:siteId AND Site__r.Show_In_Simpplr__c = true AND Site__r.Is_Active__c = true
											AND Is_Deleted__c = false
											AND Status__c = 'Approved' AND Type__c =:'Page'
											AND Is_Published__c = true  
											WITH SECURITY_ENFORCED GROUP BY Pages_Category__c];
		return groupedResults;
    }
    
    public List<Pages_Category__c> getPageCategories(String term, String siteId, Integer offset, Integer recordLimit,String sortBy) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', recordLimit);
		soqlParamMap.put('soqlParam3', offset);
		String pageCtgryQuery = 'select id, Name__c from Pages_Category__c ' +
			' where Is_Deleted__c = false AND site__c=:soqlParam1 AND Site__r.Show_In_Simpplr__c = true AND Site__r.Is_Active__c = true ' +
			' AND Id IN (select Pages_Category__c from Simpplr_content__c ' +
				' where pages_Category__c != null ' +
				' AND Status__c = \'Approved\' And Type__c =\'Page\' ' +
				' AND Is_Published__c = true   ' +
				' AND Is_Deleted__c = false ' +
				' AND site__c=:soqlParam1 AND Site__r.Show_In_Simpplr__c = true AND Site__r.Is_Active__c = true) ' +
			' order by order__c, LastModifiedDate DESC limit :soqlParam2 offset :soqlParam3';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Pages_Category__c> listOfPageCategories = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
		return listOfPageCategories;
    }
    
    @testVisible
    private Set<Id> getEventsWithRSVPYes(){
		String currentPeopleId = UserContext.peopleId;
		Set<Id> eventIdSet = new Set<Id>();
			List<Event_RSVP_Response__c> rsvpWithYesResponseList = [select id,Content__c from Event_RSVP_Response__c WHERE (RSVP_Response__c = 'Yes' OR RSVP_Response__c ='Maybe') 
																AND is_deleted__c=false AND People__c=:currentPeopleId 
																AND Content__r.Event_RSVP_Allowed__c = true AND Content__r.Is_published__c = true 
																AND Content__r.Is_Deleted__c = false AND Content__r.Site__r.Is_Active__c = true AND Content__r.Site__r.Show_In_Simpplr__c = true WITH SECURITY_ENFORCED];
		for(Event_RSVP_Response__c rsvpResObj : rsvpWithYesResponseList){
			eventIdSet.add(rsvpResObj.Content__c);
		}
		return eventIdSet;
	}
	
	public Boolean hasProfileWithBlogs(String profileId){
	 	Boolean hasBlogs = false;
	 	List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
	 	List<Simpplr_Content__c> blogList = [Select id From Simpplr_Content__c Where Type__c = 'BlogPost' AND Primary_Author__c = :profileId 
	 			AND Status__c ='Approved' AND Is_Published__c = true AND Is_Deleted__c = false
	 			AND Type__c IN :allowedFeaturesInAppList WITH SECURITY_ENFORCED limit 1];
	 	if(blogList.isEmpty() == false){
	 		hasBlogs = true;
	 	}
	 	return hasBlogs;
	}
	 
	public static Set<Id> getCollaborationGroupIdSet() {
		String queryStr = 'SELECT Id FROM CollaborationGroup ';
		if(SimpplrContext.isCommunitiesEnabled){
	    		queryStr += ' Where NetworkId = null';
	    }
		Set<Id> cgIdSet = new Set<Id>();
	    for(CollaborationGroup grpObj : Database.query(queryStr)){
	    	cgIdSet.add(grpObj.Id);
	    }
		return 	cgIdSet;
	}
    
    public Set<Id> getPrivateCGIdIFollow(){
		List<CollaborationGroupMember> collGrpMemList =  [select CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId=:UserContext.userId AND (CollaborationGroup.CollaborationType = 'Private' OR CollaborationGroup.CollaborationType = 'Unlisted') WITH SECURITY_ENFORCED];
		Set<Id> privateMemberCollGrpIdSet = new Set<Id>();
		for(CollaborationGroupMember cggrpMemObj : collGrpMemList){
			privateMemberCollGrpIdSet.add(cggrpMemObj.CollaborationGroupId);
		}
		return privateMemberCollGrpIdSet;  		
    } 
	 
	public Set<Id> getContentFavOrUnFavIDSet(DateTime pollTimeStamp){
		Set<Id> contentFavOrUnFavIDSet = new Set<Id>();
		List<Bookmark__c> bookmarkList = [Select Simpplr_Content__c From Bookmark__c Where (Type__c = 'Page' OR Type__c = 'Event' OR Type__c = 'Album' OR Type__c = 'BlogPost') AND LastModifiedById =: UserContext.userId AND LastModifiedDate >: pollTimeStamp WITH SECURITY_ENFORCED];
		for(Bookmark__c bookMarkObj : bookmarkList){
			contentFavOrUnFavIDSet.add(bookMarkObj.Simpplr_Content__c);
		}
		return contentFavOrUnFavIDSet;
	}
	
	public List<Simpplr_Content__c> getMustReadContentListForMobile(Integer recordLimit, Integer offset) {
		String query = ' SELECT ' + String.join(getContentFieldList() ,',') + ' FROM Simpplr_Content__c Where ' +
        				   ' Is_Deleted__c = false AND Is_Published__c = true AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentTime) AND  ( Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet)) ';

        query += ' Order by Publish_Start_DateTime__c Desc, Last_Edited_DateTime__c Desc LIMIT :recordLimit OFFSET :offSet';
        logger.logDebug('MobileContentDao.getMustReadContentListForMobile()----query----' + query);
   		List<Simpplr_Content__c> contentList = (List<Simpplr_Content__c>)Database.query(query);
        return contentList;

	}

	public List<String> getContentFieldList() {
		String mustReadSubCondition = '';

		if (UserContext.isUserAppModerator == false) {
			mustReadSubCondition = ' And (Audience_Type__c=\'everyone\' OR Content__r.Site__c=:sitesIFollowIdSet) ';
		}
		List<String> fieldList = new List<String>{
			'Id',
	        'Type__c',
	        'site__c',
			'Site__r.Title_Content_Document__c',
			'Primary_Author__c', 
			'Primary_Author__r.Full_Name__c',
	        'Title__c',
	        'Text_Intro__c',
	        'Display_Excerpt__c',
	        'Pages_Category__c',
	        'Pages_Category__r.Name__c',
	        'Is_Published__c',
	        'Is_Must_Read__c',
	        'Publish_Start_DateTime__c', 
	        'Publish_End_DateTime__c', 
	        'Event_Start_DateTime__c',
	        'Event_End_DateTime__c',
			'Event_Is_All_Day__c',
			'Event_TimezoneSidKey__c',
			'Status__c',
			'Is_Deleted__c',
			'CreatedDate',
			'Last_Edited_DateTime__c',
			'Activated_by_feature__c',
			'Site__r.Show_In_Simpplr__c',
			'(SELECT Id,Content_Version__c, Content_Document__c, Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false and Is_Title_Image__c = true)',
	        '(select id from Bookmarked_Content__r where People__c =:loggedInPeopleId and Is_Deleted__c=false)',
	        '(select id from Content_Interactions__r where People__c =: loggedInPeopleId )',
			'(Select Id from Must_Read_Confirm_History__r Where People__c =:loggedInPeopleId)',
			'(select Must_Read_Confirm_Count__c, Audience_Type__c from Must_Read_Audits__r where Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentTime) ' +  mustReadSubCondition + ' order by createddate desc limit 1)'

		};
		return fieldList;
	}
    
    //Get content based on content Id
	public Map<Id, Simpplr_Content__c> getCacheContentById(Set<Id> contentIdSet) {
    	
    	String query = ' SELECT ' + String.join(getContentFieldList() ,',')+' FROM Simpplr_Content__c WHERE Id =:contentIdSet ';
        Map<Id, Simpplr_Content__c> mapOfContent = new Map<Id, Simpplr_Content__c>((List<Simpplr_Content__c>)Database.query(query));
        
        	return mapOfContent;
	}
    
    public String getContentType(String contentId) {
        
        Simpplr_Content__c contentObj = [Select Type__c from Simpplr_Content__c Where Id =:contentId WITH SECURITY_ENFORCED limit 1];
        
        return contentObj.Type__c;
        
    }
    
    public List<Content_Collaborator__c> getEventOrganizers(String eventId, String siteId, Integer offset, Integer recordLimit, String sortBy){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String subConditionQuery = '';
		if(sortBy == 'CreatedDate') {
			subConditionQuery += ' order by CreatedDate asc ';
		} else {
			subConditionQuery += ' order by Collaborator__r.Full_Name__c ';
		}
		soqlParamMap.put('soqlParam1', recordLimit);
		soqlParamMap.put('soqlParam2', offset);
		subConditionQuery += ' limit :soqlParam1 offset :soqlParam2 ';
		soqlParamMap.put('soqlParam3', siteId);
		soqlParamMap.put('soqlParam4', eventId);
		String queryStr = 'SELECT Collaborator__c FROM Content_Collaborator__c where Type__c=\'Organizer\' AND Simpplr_Content__r.site__c=:soqlParam3 ' +
		'AND Simpplr_Content__r.site__r.Show_In_Simpplr__c= true ' +
		'AND Simpplr_Content__c=:soqlParam4 ' +
		'AND Is_Deleted__c = false ';
		queryStr = queryStr + subConditionQuery;

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Collaborator__c> contentCollist = (List<Content_Collaborator__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		return contentCollist;
	}
}