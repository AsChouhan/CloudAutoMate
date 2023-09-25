/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SiteDao {

	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
	private final String FILTER_MANDATORY  = 'mandatory';
	private final String FILTER_FEATURED  = 'featured';
	private final String FILTER_FAVORITE  = 'favorite';
	private final String FILTER_PUBLIC  = 'public';
	private final String FILTER_PRIVATE  = 'private';
	private final String FILTER_UNLISTED  = 'unlisted';
	private final String FILTER_DEACTIVATED  = 'deactivated';
	private final String FILTER_ACTIVE  = 'active';
	
	private String loggedInUserId {get {
		return UserContext.id;
	}set;}

	private Set<String> setOfSearchTokens;

	private String segmentId = UserContext.segmentId;
	public String loggedInPeopleId = UserContext.peopleId;
	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
	private final String SIMPPLR_APP_HOME_CHATTER_GROUP_ID = 'S06I000000MPPLR'; 
	
	private final String SITE_BASE_QUERY = 'SELECT '+String.join(getSiteFieldList(),',');
	
    private final String BASE_FROM_WHERE = ' FROM Simpplr_Site__c WHERE' + 
    										' Chatter_Group_Id__c !=: SIMPPLR_APP_HOME_CHATTER_GROUP_ID'+ 
    										' And Is_Active__c = true AND Show_In_Simpplr__c = true ';
    										
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	
	private List<Id> getListOfCollaborationGroupIds (){
		List<CollaborationGroup> listOfCollaborationGroup = new List<CollaborationGroup>();
		String BASE_QUERY= 'SELECT Id FROM CollaborationGroup ';
		if(SimpplrContext.isCommunitiesEnabled){
    		BASE_QUERY = BASE_QUERY+'Where NetworkId = null';
    	}
    	listOfCollaborationGroup = Database.query(BASE_QUERY);
		List<Id> listOfIds= new List<Id>();
		for(CollaborationGroup cg: listOfCollaborationGroup){
			listOfIds.add(cg.Id);
		}
		return listOfIds;
	}

	/**
     * @description method is used to get List of collaboration groups already exists
	 * @param Set of groups name that are being created
     * @return List of collaboration groups already exists
     */
	public Map<String,CollaborationGroup> getNameVsCollaborationGroupMap(Set<String> grpNames) {
		Map<String,CollaborationGroup> mapOfCollaborationGroup = new Map<String,CollaborationGroup>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', grpNames);
		String queryStr= 'SELECT Id, Name FROM CollaborationGroup WHERE Name =:soqlParam1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<CollaborationGroup> listOfCollaborationGroup = (List<CollaborationGroup>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
        for (CollaborationGroup grp : listOfCollaborationGroup) {
			mapOfCollaborationGroup.put(grp.Name.toLowerCase(), grp);
		}
    	return mapOfCollaborationGroup;
		
	}

	public List<Id> getListOfAppMgrOrSysAdmManagableCollaborationGroupIds(){
		Set<Id> groupIManageIdSet = new Set<Id>(UserContext.groupsIManageIdSet);
		List<CollaborationGroup> listOfCollaborationGroup = new List<CollaborationGroup>();
		Set<Id> groupsIContentManageIdList = new Set<Id>();
		for(Simpplr_Site__c site :UserContext.sitesIManageContentsMap.values())
		{
			groupsIContentManageIdList.add(site.chatter_Group_Id__c);
		}
		String BASE_QUERY= 'SELECT Id FROM CollaborationGroup ';
		if(SimpplrContext.isCommunitiesEnabled){
			if(UserContext.hasModifyAllDataPermission == false){
    			BASE_QUERY = BASE_QUERY+' WHERE NetworkId = null and (CollaborationType=\'Public\' OR Id IN:groupIManageIdSet) ';
			} else {
				BASE_QUERY = BASE_QUERY+' WHERE NetworkId = null ';
			}
				
    	} else {
	    	if(UserContext.hasModifyAllDataPermission == false){
    			BASE_QUERY = BASE_QUERY+' WHERE  CollaborationType=\'Public\' OR Id IN:groupIManageIdSet OR Id IN:groupsIContentManageIdList ';
			} else {
				BASE_QUERY = BASE_QUERY+' WHERE  CollaborationType=\'Public\' OR CollaborationType=\'Private\' OR ((Id IN:groupIManageIdSet OR Id IN:groupsIContentManageIdList) AND CollaborationType=\'Unlisted\') ';
			}
    	}
    	listOfCollaborationGroup = Database.query(BASE_QUERY);
		List<Id> listOfIds= new List<Id>();
		for(CollaborationGroup cg: listOfCollaborationGroup){
			listOfIds.add(cg.Id);
		}
		return listOfIds;
	}
	
	
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public List<Bookmark__c> getSitesAllFavoriteSites(Set<Id> setOfCollabIds, String textSearch, Integer offset,
    		Integer recordLimit, String categoryId, String sortBy) {
		try {
			String loggedInUserPeopleId = UserContext.peopleId;
			String queryStr = ' Select Simpplr_Site__c,Simpplr_Site__r.Is_Active__c,Simpplr_Site__r.Site_Category__c,'+
							  ' Simpplr_Site__r.Site_Category__r.Name__c, Simpplr_Site__r.Site_Category__r.Access__c, Simpplr_Site__r.Title_Content_Version__c,'+
							  ' Simpplr_Site__r.Chatter_Group_Id__c, Simpplr_Site__r.Landing_Page__c,'+
							  ' Simpplr_Site__r.Show_In_Simpplr__c from Bookmark__c '+
							  ' WHERE Type__c=\'Site\' And people__c =: loggedInUserPeopleId'+
							  ' And Simpplr_Site__r.Is_Active__c=true And Simpplr_Site__r.Is_Deleted__c = false'+ 
							  ' AND Is_Deleted__c = false AND Simpplr_Site__r.Show_In_Simpplr__c = true';
							  
			queryStr+= ' AND Simpplr_Site__r.Chatter_Group_Id__c= :setOfCollabIds ';
			if(String.isNotBlank(textSearch)) {
				queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)), new List<String>{'Simpplr_Site__r.Name'});
			}
			if('alphabetical'.equalsIgnoreCase(sortBy)){
				queryStr += ' Order by Name desc ';
			}else{
				queryStr += ' Order by LastModifiedDate desc ';
			}
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
				
			return Database.query(queryStr);
			
		} catch (exception e) {
			throw new SimpplrException(e.getMessage());
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
	public List<Simpplr_Site__c> getSitesAllFeaturedSites(String textSearch, Integer offset,
		Integer recordLimit, String categoryId, String sortBy) {
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE+ ' AND Is_Featured__c=true ';
		
		if (String.isNotBlank(textSearch)) {
			queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}
		
		if (String.isNotBlank(categoryId)){
            
            if (ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				queryStr += ' AND Site_Category__c = null ';
            
            } else if (!'all'.equalsIgnoreCase(categoryId)) {
	        	queryStr += ' AND Site_Category__c =:categoryId ';
	        }

		}

		if ('featured'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by Order__c, Name ';				
		}
		
		queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO
		logger.logDebug('SiteDao.getSitesAllFeaturedSites() ---- queryStr ----' + queryStr);		
		return Database.query(queryStr);
	}

    public List<Simpplr_Site__c> getSitesAllFeaturedSites(Criteria.Site siteCriteriaObjArg) {
        String textSearch = siteCriteriaObjArg.term;
        Integer offset = siteCriteriaObjArg.offset;
		Integer recordLimit =  siteCriteriaObjArg.size;
        String categoryId = siteCriteriaObjArg.category;
        String sortBy = siteCriteriaObjArg.sortBy;
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE+ ' AND Is_Featured__c=true ';
		Set<Id> setOfCollGroupId = siteCriteriaObjArg.setOfCollGroupId;
		if(siteCriteriaObjArg.canSubmitQuestion){
            queryStr+= ' AND Question_Answer_Enabled__c = true ';
            queryStr+= ' AND Chatter_Group_Id__c = :setOfCollGroupId ';
		}
		if (String.isNotBlank(textSearch)) {
			queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
		}
		
		if (String.isNotBlank(categoryId)){
			
            if (ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				queryStr += ' AND Site_Category__c = null ';
			
            } else if (!'all'.equalsIgnoreCase(categoryId)) {
	        	queryStr += ' AND Site_Category__c =:categoryId ';
	        }

		}

        if (!siteCriteriaObjArg.setOfIdToExclude.isEmpty()) {
            Set<id> setOfIdToExclude = new Set<Id>();
            setOfIdToExclude.addAll(siteCriteriaObjArg.setOfIdToExclude);
            queryStr+= ' AND id NOT IN :setOfIdToExclude ';
        }

		if('featured'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by Order__c, Name ';				
		}
		
		queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO
		logger.logDebug('SiteDao.getSitesAllFeaturedSites() ---- queryStr ----' + queryStr);		
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
    public List<Segment_Site__c> getSitesAllFeaturedSitesForSegments(Set<Id> setOfCollabIds, String textSearch, Integer offset,
		Integer recordLimit, String categoryId, String sortBy, String segmentId) {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		soqlParamMap.put('soqlParam2', setOfCollabIds);
		String queryStr =	' Select Id, Is_Featured__c, Order__c, Site__r.chatter_group_id__c,' + 
							' Site__c, Segment__c, Site__r.name, Site__r.Landing_Page__c,' +
							' Site__r.Title_Content_Version__c, Site__r.Title_Content_Document__c,' +
							' Site__r.Site_Type__c, Site__r.Is_Active__c,' +
							' Site__r.Site_Category__r.Name__c, Site__r.Site_Category__r.Access__c, Site__r.Site_Category__c From Segment_Site__c' +
							' Where Segment__c = :soqlParam1 And Is_Featured__c = true' +
							' And Site__r.Is_Active__c=true And Site__r.Is_Deleted__c = false' + 
							' AND Site__r.Show_In_Simpplr__c = true';				
						  
		queryStr+= ' AND Site__r.Chatter_Group_Id__c= :soqlParam2 ';
		if(String.isNotBlank(textSearch)) {
			queryStr += getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)), new List<String>{'Site__r.Name'});
		}
		if(String.isNotBlank(categoryId)){
			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
				queryStr += ' AND Site__r.Site_Category__c = null ';
			} else if (!'all'.equalsIgnoreCase(categoryId)) {
				soqlParamMap.put('soqlParam3', categoryId);
	        	queryStr += ' AND Site__r.Site_Category__c =:soqlParam3 ';
	        }
		}
		if('alphabetical'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by Site__r.Name desc ';
		}else{
			queryStr += ' Order by Order__c, Site__r.Name ';
		}
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		logger.logDebug('SiteDao.getSitesAllFeaturedSitesForSegments() ---- queryStr ----' + queryStr);	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Segment_Site__c> segSiteList = (List<Segment_Site__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap);	
		return segSiteList;
	}	
	
		/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Map<String,String> getSitesAllPopularSites(Set<Id> setOfChatterGroupId, Integer offset, Integer recordLimit) {
		Map<String, String> mapOfSiteIdAndChatterGroupId = new Map<String, String>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', setOfChatterGroupId);
		soqlParamMap.put('soqlParam2', recordLimit);
		soqlParamMap.put('soqlParam3', offset);
		String topSiteQuery = 'select Site__r.Chatter_Group_Id__c chatterGroupId, Site__c siteId  from Analytics_Top_Site__c ' +
			' where createddate = LAST_N_DAYS: 14 ' +
			' And Site__r.Is_Deleted__c = false ' +
			' And Site__r.is_Active__c = true ' +
			' And Site__r.Show_In_Simpplr__c = true ' +
			' And Site__r.Chatter_Group_Id__c =: soqlParam1 ' +
			' group by Site__r.Chatter_Group_Id__c, Site__c ' +
			' order by sum(Popularity_Score__c) desc ' +
			' LIMIT :soqlParam2 OFFSET :soqlParam3';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggrList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(topSiteQuery, soqlParamMap);
        								  
        for(AggregateResult ar : aggrList){
			mapOfSiteIdAndChatterGroupId.put((String)ar.get('siteId'), (String)ar.get('chatterGroupId'));
        }
        
		logger.logDebug('SiteDao.getSitesAllPopularSites() ----mapOfSiteIdAndChatterGroupId----' + mapOfSiteIdAndChatterGroupId);
		return mapOfSiteIdAndChatterGroupId;
	}
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Map<Id, Simpplr_Site__c> getSites(Set<String> setOfSiteIds) {
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE + ' And Id=:setOfSiteIds ';
		return new Map<Id, Simpplr_Site__c>((List<Simpplr_Site__c>)Database.query(queryStr));
	}
	
	public Map<Id, Simpplr_Site__c> getSites(String segmentId, Set<String> setOfSiteIds) {
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE + ' And Id=:setOfSiteIds ';
		return new Map<Id, Simpplr_Site__c>((List<Simpplr_Site__c>)Database.query(queryStr));
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Map<Id, CollaborationGroup> getMapOfIdWithCollaborationGroup(List<Id > listOfCollGroupId,
			String userIdArg) {
		Map<Id, CollaborationGroup> mapOfChatterGroups = new Map<Id, CollaborationGroup>();
		String BASE_QUERY = 'SELECT Id, name, OwnerId, MemberCount, Description,InformationTitle, InformationBody, isBroadcast, smallPhotoUrl, FullPhotoURL, CanHaveGuests, CollaborationType,'+
							' (SELECT Id, CollaborationGroupId, MemberId, CollaborationRole FROM GroupMembers WHERE MemberId =:userIdArg),'+
							' (SELECT status FROM GroupMemberRequests WHERE status =\'Pending\' AND RequesterId =:userIdArg)';
		String BASE_FROM_WHERE = ' FROM CollaborationGroup WHERE Id =:listOfCollGroupId ';
		String SUB_CONDITION = ' limit 5000';
		if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_FROM_WHERE = BASE_FROM_WHERE+' AND NetworkId = null';
	    }
	    String query = BASE_QUERY+BASE_FROM_WHERE+SUB_CONDITION;
	    logger.logDebug('SiteDao.getMapOfIdWithCollaborationGroup() ---- query ----' + query);
		return new Map<Id, CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
	}
	
	public Map<Id, CollaborationGroup> getMapOfIdWithCollaborationGroup(String userIdArg) {
		String query = 'SELECT Id, name, OwnerId, MemberCount, Description,InformationTitle, InformationBody, isBroadcast, smallPhotoUrl, FullPhotoURL, CanHaveGuests, CollaborationType,'+
							' (SELECT Id, CollaborationGroupId, MemberId, CollaborationRole FROM GroupMembers WHERE MemberId =:userIdArg),'+
							' (SELECT status FROM GroupMemberRequests WHERE status =\'Pending\' AND RequesterId =:userIdArg) ' +
							' FROM CollaborationGroup ';
		if(SimpplrContext.isCommunitiesEnabled){
	    		query = query+' WHERE NetworkId = null';
	    }
	    Map<Id, CollaborationGroup> mapOfChatterGroups = new Map<Id, CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
		return 	mapOfChatterGroups;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Simpplr_Site__c> getSitesAllManagingSites(String textSearch, Integer offset,
			Integer recordLimit, String categoryId, List<Id> listOfCollGrpIdArg, String sortBy) {
		try {
			String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE+ ' AND Chatter_Group_Id__c=:listOfCollGrpIdArg ';
			
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
			if('alphabetical'.equalsIgnoreCase(sortBy)){
				queryStr += ' Order by Name ';
			}
			queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO		
			
			return Database.query(queryStr);
			
		} catch (exception e) {
			throw new SimpplrException(e.getMessage());
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
	public List<Simpplr_Site__c> getSiteIdsToFilterFrom(List<String> siteIdsToFilterFrom) {
		String BASE_FROM_WHERE = ' FROM Simpplr_Site__c WHERE' + 
    								' Chatter_Group_Id__c !=: SIMPPLR_APP_HOME_CHATTER_GROUP_ID'+ 
    								' AND Show_In_Simpplr__c = true' ;
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE;
		queryStr += ' AND id =: siteIdsToFilterFrom Order by LastModifiedDate Desc';
		logger.logDebug('SiteDao.getSiteIdsToFilterFrom() ---- queryStr ----' + queryStr);		
		return Database.query(queryStr);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Simpplr_Site__c> getSitesAllSites(Set<Id> setOfCollabIds, String textSearch, Integer offset,
		Integer recordLimit, String categoryId, String sortBy,Boolean isPrivate, Boolean canSubmitQuestion) {
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE;
		if(canSubmitQuestion){
			queryStr+= ' AND Question_Answer_Enabled__c = true ';
		}
		queryStr+= ' AND Chatter_Group_Id__c= :setOfCollabIds ';
		if(isPrivate == false){
			queryStr += ' AND Site_Type__c=\'public\' ';
		}
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
		if('alphabetical'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by Name ';
		}else if ('createdNewest'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by createdDate desc';
		}else if('createdOldest'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by createdDate ';
		}
		queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO
		logger.logDebug('SiteDao.getSitesAllSites() ---- queryStr ----' + queryStr);		
		return Database.query(queryStr);
	}

    public List<Simpplr_Site__c> getSitesAllSites(Set<Id> setOfCollabIds, 
            Criteria.Site siteCriteriaObjArg) {
        String textSearch = siteCriteriaObjArg.term;
        Integer offset = siteCriteriaObjArg.offset;
		Integer recordLimit =  siteCriteriaObjArg.size;
        String categoryId = siteCriteriaObjArg.category;
        String sortBy = siteCriteriaObjArg.sortBy;
        Boolean isPrivate = siteCriteriaObjArg.isPrivate;
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE;
		if(siteCriteriaObjArg.canSubmitQuestion){
			queryStr+= ' AND Question_Answer_Enabled__c = true ';
		}
		queryStr+= ' AND Chatter_Group_Id__c= :setOfCollabIds ';
		if(isPrivate == false){
			queryStr += ' AND Site_Type__c=\'public\' ';
		}
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

        if (!siteCriteriaObjArg.setOfIdToExclude.isEmpty()) {
            Set<id> setOfIdToExclude = new Set<Id>();
            setOfIdToExclude.addAll(siteCriteriaObjArg.setOfIdToExclude);
            queryStr+= ' AND id NOT IN :setOfIdToExclude ';
        }

		if('alphabetical'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by Name ';
		}else if ('createdNewest'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by createdDate desc';
		}else if('createdOldest'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by createdDate ';
		}

		queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO
		logger.logDebug('SiteDao.getSitesAllSites() ---- queryStr ----' + queryStr);		
		return Database.query(queryStr);
	}
	
	public List<Simpplr_Site__c> getSitesSearchResults(Criteria.Site siteCriteriaObjArg) {
		try {
			String loggedInUserPeopleId = UserContext.peopleId;
			String filter = siteCriteriaObjArg.filter;
			Integer recordLimit = siteCriteriaObjArg.size + 1;
			Integer offset = siteCriteriaObjArg.offset;
			Set<String> setOfSearchTerms = String.isNotBlank(siteCriteriaObjArg.term)? Utility.getSearchTokens(String.escapeSingleQuotes(siteCriteriaObjArg.term)) : null;
			List<Id> listOfCollabIds = new List<Id>();
			List<Id> listOfSiteIds = new List<Id>();
			
			if (UserContext.isUserAppModerator) {
				listOfCollabIds = getListOfAppMgrOrSysAdmManagableCollaborationGroupIds();
			} else {
				listOfCollabIds.addAll(UserContext.groupsIManageIdSet);
				listOfSiteIds.addAll(UserContext.sitesIManageContentsIdSet);
				if(siteCriteriaObjArg.canManage == null || siteCriteriaObjArg.canManage == false){
					listOfCollabIds.addAll(UserContext.chatterGroupsIFollowIdSet);
				}
				
			}
			
			String queryStr = SITE_BASE_QUERY+ ' FROM Simpplr_Site__c WHERE Chatter_Group_Id__c !=: SIMPPLR_APP_HOME_CHATTER_GROUP_ID ';
			queryStr += getSearchTermCondition(setOfSearchTerms);
			queryStr += getFilterCondition(filter);
			
			if(siteCriteriaObjArg.canSubmitQuestion){
				queryStr += ' AND Question_Answer_Enabled__c = true';
			}

            if (UserContext.hasManageUnlistedSitePermission) {
				queryStr+= ' AND (Id = :listOfSiteIds OR Chatter_Group_Id__c= :listOfCollabIds OR SIte_Type__c = \'Unlisted\')';
			
            } else{
				queryStr+= ' AND (Id = :listOfSiteIds OR Chatter_Group_Id__c= :listOfCollabIds) ';
			}

            if (siteCriteriaObjArg.setOfIdToExclude != null && !siteCriteriaObjArg.setOfIdToExclude.isEmpty()) {
                Set<id> setOfIdToExclude = new Set<Id>();
                setOfIdToExclude.addAll(siteCriteriaObjArg.setOfIdToExclude);
                queryStr+= ' AND id NOT IN :setOfIdToExclude ';
            }

	        queryStr += ' AND Is_Deleted__c = false And Show_In_Simpplr__c = true Order by Name ';
			queryStr += getLimitOffsetCondition(recordLimit, offset); 
			return Database.query(queryStr);
			
		} catch (exception e) {
			throw new SimpplrException(e.getMessage());
		}
	}

	public List<Simpplr_Site__c> getSitesSearchResultsManagedByLoggedInUser(Criteria.Site siteCriteriaObjArg) {
		try {
			String loggedInUserPeopleId = UserContext.peopleId;
			String filter = siteCriteriaObjArg.filter;
			Integer recordLimit = siteCriteriaObjArg.size + 1;
			Integer offset = siteCriteriaObjArg.offset;
			Set<String> setOfSearchTerms = String.isNotBlank(siteCriteriaObjArg.term)? Utility.getSearchTokens(String.escapeSingleQuotes(siteCriteriaObjArg.term)) : null;
			List<Id> listOfCollabIds = new List<Id>();
			List<Id> listOfSiteIds = new List<Id>();
			for(Site_Role__c siteRoleRecord : UserContext.mySiteRolesMap.values()){
				if(siteRoleRecord.Is_Manager__c || siteRoleRecord.Is_Content_Manager__c){
					listOfCollabIds.add(siteRoleRecord.Site__r.Chatter_Group_Id__c);
					listOfSiteIds.add(siteRoleRecord.Site__c);
				}
				
			}
			String queryStr = SITE_BASE_QUERY+ ' FROM Simpplr_Site__c WHERE Chatter_Group_Id__c !=: SIMPPLR_APP_HOME_CHATTER_GROUP_ID ';
			queryStr += getSearchTermCondition(setOfSearchTerms);
			queryStr += getFilterCondition(filter);
			
			queryStr+= ' AND Chatter_Group_Id__c= :listOfCollabIds ';
			
			if (siteCriteriaObjArg.setOfIdToExclude != null && !siteCriteriaObjArg.setOfIdToExclude.isEmpty()) {
                Set<id> setOfIdToExclude = new Set<Id>();
                setOfIdToExclude.addAll(siteCriteriaObjArg.setOfIdToExclude);
                queryStr+= ' AND id NOT IN :setOfIdToExclude ';
            }

	        queryStr += ' AND Is_Deleted__c = false And Show_In_Simpplr__c = true Order by Name ';
			queryStr += getLimitOffsetCondition(recordLimit, offset); 
			return Database.query(queryStr);
			
		} catch (exception e) {
			throw new SimpplrException(e.getMessage());
		}
	}
	
	private String getSearchTermCondition(Set<String> setOfSearchTerms){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
    				queryStr += ' And Name like \'%'+searchToken+'%\' ';
			}
        }
        return queryStr;
	}
	
	private String getSearchTermCondition(Set<String> setOfSearchTerms, List<String> fieldsToSearch){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
				for(String field : fieldsToSearch) {
        				queryStr += ' And ' + field + ' like \'%'+searchToken+'%\' ';
				}
			}
        }
        return queryStr;
	}
	
	private String getFilterCondition(String filter){
		String queryStr = '';
		if(String.isNotBlank(filter)){
			if(FILTER_FEATURED.equalsIgnoreCase(filter)){
				queryStr += ' And Is_Featured__c = true ';
				
			}else if(FILTER_FAVORITE.equalsIgnoreCase(filter)){
				queryStr += ' And Id in (select Simpplr_Site__c from Bookmark__c ' +
							' WHERE Type__c=\'Site\' And people__c =: loggedInUserPeopleId AND Is_Deleted__c = false ) ';
							
			}else if(FILTER_PUBLIC.equalsIgnoreCase(filter)){
				queryStr += ' And Site_Type__c = \'Public\' ';
				
			}else if(FILTER_PRIVATE.equalsIgnoreCase(filter)){
				queryStr += ' And Site_Type__c = \'Private\' ';
			}else if(FILTER_UNLISTED.equalsIgnoreCase(filter)){
				queryStr += ' And Site_Type__c = \'Unlisted\' ';
			}else if(FILTER_DEACTIVATED.equalsIgnoreCase(filter)){
				queryStr += ' And Is_Active__c = false ';
			}else if(FILTER_ACTIVE.equalsIgnoreCase(filter)){
				queryStr += ' And Is_Active__c = true ';
			}else{
				// condition for ALL not needed
			}
		}
		return queryStr;
	}
	
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
	public List<Simpplr_Site__c> getSitesAllFollowingSites(String textSearch, Integer offset,
			Integer recordLimit, String categoryId, List<Id> listOfCollGrpIdArg, String sortBy) {
		try {
			String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE+ ' AND Chatter_Group_Id__c=:listOfCollGrpIdArg ';
			
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
	        
	        if('alphabetical'.equalsIgnoreCase(sortBy)){
	        	queryStr += ' Order by Name ';
	        }
			queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO		
			
			return Database.query(queryStr);
			
		} catch (exception e) {
			throw new SimpplrException(e.getMessage());
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
	public List<Simpplr_Site__c> getProfileSitesAllSites(String textSearch, Integer offset,
			Integer recordLimit, String categoryId, List<Id> listOfSelectedUsersChatterGroupIds) {
		try {
			String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE;
			List<Id> listOfCollabIds=getListOfCollaborationGroupIds();
			queryStr += ' And chatter_Group_id__c=:listOfSelectedUsersChatterGroupIds ';
			
			if(String.isNotBlank(textSearch)) {
				textSearch = '%' + textSearch + '%';
				queryStr += ' And Name like:textSearch ';
			}
			
			if(String.isNotBlank(categoryId)){
				if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
					queryStr += ' AND Site_Category__c = null ';
				} else if (!'all'.equalsIgnoreCase(categoryId)) {
		        	queryStr += ' AND Site_Category__c =:categoryId ';
		        }
			}
	        queryStr += ' Order by Name ';
			queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO		
			return Database.query(queryStr);
			
		} catch (exception e) {
			throw new SimpplrException(e.getMessage());
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
	public List<Simpplr_Site__c> getProfileSitesAllManagingSites(String textSearch, Integer offset,
			Integer recordLimit, String categoryId, List<Id> listOfCollGrpIdArg, String userId) {
		try {
			String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE+ ' AND Chatter_Group_Id__c=:listOfCollGrpIdArg ';
			
			if(String.isNotBlank(textSearch)) {
				textSearch = '%' + textSearch + '%';
				queryStr += ' And Name like:textSearch ';
			}
			
			if(String.isNotBlank(categoryId)){
				if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(categoryId)){
					queryStr += ' AND Site_Category__c = null ';
				} else if (!'all'.equalsIgnoreCase(categoryId)) {
		        	queryStr += ' AND Site_Category__c =:categoryId ';
		        }
			}
	        queryStr += ' Order by Name ';
			queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO		
			
			return Database.query(queryStr);
			
		} catch (exception e) {
			throw new SimpplrException(e.getMessage());
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
	public Map<Id,PeopleIdAndSiteRole> getMapOfMemberIdAndRoleOfSite(String siteId) {
		Map<Id,PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = new Map<Id,PeopleIdAndSiteRole>(); 

		if (String.isNotBlank(siteId)) {
			List<Site_Role__c> listOfSiteRole = [SELECT Id, Site__c, People__c, People__r.User__c, Is_Member__c,
														Is_Manager__c, Is_Content_Manager__c , Site__r.Chatter_Group_Id__c
														FROM Site_Role__c
														WHERE Site__c = :siteId AND People__c != null
														AND Is_Deleted__c = false];

														
			String chatterGrpId = '';
			if(listOfSiteRole.isEmpty()){
				List<Simpplr_Site__c> siteList = [SELECT Chatter_Group_Id__c from Simpplr_Site__c WHERE Id=:siteId];
				chatterGrpId = siteList.isEmpty() == false ? siteList[0].Chatter_Group_Id__c:'';
			} else {
				chatterGrpId = listOfSiteRole[0].Site__r.Chatter_Group_Id__c;
			}
			List<CollaborationGroup> collabGrpList = [SELECT Id, OwnerId, Name FROM CollaborationGroup where  id  =: chatterGrpId];											
			if(!collabGrpList.isEmpty() ) {
				for(Site_Role__c siteRoleObj : listOfSiteRole) {
					PeopleIdAndSiteRole peopleIdAndSiteRoleObj = new PeopleIdAndSiteRole();
					if(((String)siteRoleObj.People__r.User__c).equalsIgnoreCase(collabGrpList[0].OwnerId)) {
						peopleIdAndSiteRoleObj.role = 'Owner';
					} else if(siteRoleObj.Is_Manager__c == true){
						peopleIdAndSiteRoleObj.role = 'Manager';
					} else if(siteRoleObj.Is_Content_Manager__c == true){
						peopleIdAndSiteRoleObj.role = 'ContentManager';
					} else {
						if(siteRoleObj.Is_Member__c == true) {
							peopleIdAndSiteRoleObj.role = 'Member';
						} else {
							peopleIdAndSiteRoleObj.role = 'Follower';
						}
					}

					peopleIdAndSiteRoleObj.id = siteRoleObj.People__c;

					mapOfMemberIdAndRoleOfSite.put(siteRoleObj.People__r.User__c, peopleIdAndSiteRoleObj);
				}
				if(mapOfMemberIdAndRoleOfSite.get(collabGrpList[0].OwnerId) == null){
					PeopleIdAndSiteRole peopleIdAndSiteRoleObj = new PeopleIdAndSiteRole();
					peopleIdAndSiteRoleObj.role = 'Owner';
					mapOfMemberIdAndRoleOfSite.put(collabGrpList[0].OwnerId,peopleIdAndSiteRoleObj);
				}
			} else {
				//user does not have access to the site record now
				throw new SimpplrException(ExceptionCode.NO_SITE_ACCESS.name());
			}
			
		}
		
		return mapOfMemberIdAndRoleOfSite;
	}

	public class PeopleIdAndSiteRole {
		public String id;
		public String role;
	}
	
	public Set<Id> getSiteManagerIdsSet(String siteId) {
    	Set<Id> managerIds = new Set<Id>();
    	
    	if(String.isNotBlank(siteId)) {
    		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c
				WHERE Id=:siteId];
	    	if(!listOfSimpplrSite.isEmpty()) {
	    		List<CollaborationGroupMember> listOfCollabGrpMember = getCollaborationGroupMember(listOfSimpplrSite[0].Chatter_Group_Id__c, 'Admin'); 
				for (CollaborationGroupMember grpMemberObj : listOfCollabGrpMember) {
		    			managerIds.add(grpMemberObj.MemberId);
				}													
	    	}
    	}
    	
    	return managerIds;
	}
	
	public Set<String> getSiteContentManagerIdsSet(String siteId) {
    	Set<String> managerIds = new Set<String>();
    	
    	if(String.isNotBlank(siteId)) {
    		List<Site_Role__c> listOfSiteRole = [SELECT Id, Site__c, People__c, People__r.User__c,
														Is_Manager__c, Is_Content_Manager__c ,site__r.Chatter_Group_Id__c
														FROM Site_Role__c
														WHERE Site__c =:siteId 
														AND People__r.User__r.IsActive = true
														AND Is_Deleted__c = false
														AND Is_Content_Manager__c = true
														WITH SECURITY_ENFORCED];
			
	    	for(Site_Role__c roleObj : listOfSiteRole) {
				managerIds.add(roleObj.People__c);
	    	}
    	}
    	
    	return managerIds;
	}
	
	public Set<String> getSiteContentManagerUserIdsSet(String siteId) {
    	Set<String> managerIds = new Set<String>();
    	
    	if(String.isNotBlank(siteId)) {
    		List<Site_Role__c> listOfSiteRole = [SELECT Id, Site__c, People__c, People__r.User__c,
														Is_Manager__c, Is_Content_Manager__c ,site__r.Chatter_Group_Id__c
														FROM Site_Role__c
														WHERE Site__c =:siteId 
														AND People__r.User__r.IsActive = true
														AND Is_Deleted__c = false 
														AND Is_Content_Manager__c = true
												];
			
	    	for(Site_Role__c roleObj : listOfSiteRole) {
				managerIds.add(roleObj.People__r.User__c);
	    	}
    	}
    	
    	return managerIds;
    }
    
    public List<CollaborationGroupMember> getCollaborationGroupMember(String collaborationGroupId, String collaborationRole) {
    	List<CollaborationGroupMember> listOfCollabGrpMember = [SELECT MemberId
																FROM CollaborationGroupMember 
																WHERE CollaborationGroupId =:collaborationGroupId
																And CollaborationRole=:collaborationRole
																WITH SECURITY_ENFORCED];
		return listOfCollabGrpMember;
    }
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Map<Id,String> getMapOfManagerIdAndRoleOfSite (String chatterGroupId, String siteId) {
		Map<Id,String> mapOfManagerIdAndRoleOfSite = new Map<Id,String>(); 
		
		if (String.isNotBlank(chatterGroupId)) {
			String packageName = SimpplrContext.packageName;
			String query ='SELECT MemberId, CollaborationRole, CollaborationGroup.OwnerId FROM CollaborationGroupMember WHERE CollaborationRole = \'Admin\' And CollaborationGroupId =:chatterGroupId ';

			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
				query += ' And MemberId in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =\'Simpplr\') ';
			}
			
			List<CollaborationGroupMember> listOfCollabGrpMember = database.query(query);

			for (CollaborationGroupMember grpMemberObj : listOfCollabGrpMember) {
				if(grpMemberObj.MemberId == grpMemberObj.CollaborationGroup.OwnerId) {
					mapOfManagerIdAndRoleOfSite.put(grpMemberObj.MemberId, 'Owner');
				} else if('Admin'.equalsIgnoreCase(grpMemberObj.CollaborationRole)){
					mapOfManagerIdAndRoleOfSite.put(grpMemberObj.MemberId, 'Manager');
				}
			}
		}

		Set<String> contentManagerIds = getSiteContentManagerUserIdsSet(siteId);
		for(String peoplId : contentManagerIds) {
			mapOfManagerIdAndRoleOfSite.put((Id)peoplId, 'ContentManager');
		}
		
		return mapOfManagerIdAndRoleOfSite;
	}
	
	/**
	 * 
	 * It will create a junction object name: ContentManager, which have values of site and people.
	 * rather than this it will 
	 */
	public Boolean assignSiteRoles(String siteId, String userId, String membershipType, Boolean isManagerOrOwner, Boolean isContentManager) {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', userId);
		soqlParamMap.put('soqlParam2', siteId);
		String query = 'Select id, Is_Content_Manager__c, Is_Member__c, Is_Manager__c, Site__r.Is_Onboarding_Enabled__c '+
											' FROM Site_Role__c '+
											' WHERE People__r.User__c =: soqlParam1 and Site__c = :soqlParam2 and Is_Deleted__c = false ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Site_Role__c> siteRoleList = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(siteRoleList.isEmpty() == false){
			Site_Role__c siteRoleObj = siteRoleList[0];
			
			siteRoleObj.Is_Content_Manager__c = isContentManager;

			if(membershipType == 'follower') {
				siteRoleObj.Is_Member__c = false;
				siteRoleObj.Is_Content_Manager__c = false;
				siteRoleObj.Is_Manager__c  = false;
			} else if(membershipType == 'contentManager') {
				siteRoleObj.Is_Member__c = true;
				siteRoleObj.Is_Content_Manager__c = true;
				siteRoleObj.Is_Manager__c  = false;
			} else if(membershipType == 'manager') {
				siteRoleObj.Is_Member__c = true;
				siteRoleObj.Is_Content_Manager__c = false;
				siteRoleObj.Is_Manager__c  = true;
			} else {
				siteRoleObj.Is_Member__c = true;
				siteRoleObj.Is_Content_Manager__c = false;
				if(isManagerOrOwner == true){
					siteRoleObj.Is_Manager__c  = true;
				} else {
					siteRoleObj.Is_Manager__c  = false;
				}
			}
			siteRoleObj.Sync_Status__c = 0;
				
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(siteRoleObj, new List<Schema.SObjectField>{Site_Role__c.Is_Content_Manager__c,Site_Role__c.Is_Manager__c, Site_Role__c.Is_Member__c,Site_Role__c.Sync_Status__c});
		} else {
			Site_Role__c siteRoleObj = new Site_Role__c();
			siteRoleObj.Site__c = siteId;
			People__c peopleObj = [Select Id, User__c From People__c Where User__c =: userId WITH SECURITY_ENFORCED];
			siteRoleObj.People__c = peopleObj.Id;
			siteRoleObj.User__c = peopleObj.User__c;
			siteRoleObj.Is_Content_Manager__c = isContentManager;
			if(membershipType == 'follower') {
				siteRoleObj.Is_Member__c = false;
				siteRoleObj.Is_Content_Manager__c = false;
				siteRoleObj.Is_Manager__c  = false;
			} else {
				siteRoleObj.Is_Member__c = true;
				siteRoleObj.Is_Content_Manager__c = false;
				siteRoleObj.Is_Manager__c  = false;
			}
			if(SimpplrContext.isNativeVideo || Test.isRunningTest()) {
				siteRoleObj.Video_Provider_Sync_Status__c = 1;
			} else {
				siteRoleObj.Video_Provider_Sync_Status__c = 0;
			}
			siteRoleObj.Sync_Status__c = 0; 
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			SIMPESAPI.accessController().insertAsUser(siteRoleObj,new List<Schema.SObjectField>{
															Site_Role__c.Site__c,
															Site_Role__c.People__c,
															Site_Role__c.User__c,
															Site_Role__c.Is_Member__c,
															Site_Role__c.Is_Content_Manager__c,
															Site_Role__c.Is_Manager__c,
															Site_Role__c.Video_Provider_Sync_Status__c,
															Site_Role__c.Sync_Status__c
														});	
		}
		Set<String> setOfContentApprovers = new Set<String>{userId};
		updateAccessToFiles(siteId, setOfContentApprovers, isManagerOrOwner, isContentManager);

		return true;
	}

	private static void updateAccessToFiles(String siteId, Set<String> setOfContentApprovers, Boolean isManagerOrOwner, Boolean isContentManager) {
		// Get all draft contents for site
		Map<Id, Simpplr_Content__c> contentMap = new Map<Id, Simpplr_Content__c>([SELECT Id from Simpplr_Content__c WHERE Status__c = 'Draft' AND Site__c = :siteId WITH SECURITY_ENFORCED]);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentMap.keySet());

		// Get all Files(ContentDocument) that are title images to the above fetched Simpplr-Content
		String filesQuery = 'SELECT Id, Content_Document__c, Repository__c '+
							' FROM File__c '+
							' WHERE Simpplr_Content__c = :soqlParam1 AND Is_Deleted__c = false';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

		if(fileList.size() > 200 && !System.isBatch() && !System.isFuture() && !Test.isRunningTest()) {
			BatchContentDocument batchJob = new BatchContentDocument('updateAccessToFiles', contentMap.keySet(), setOfContentApprovers, isManagerOrOwner, isContentManager);
			Database.executeBatch(batchJob, 200);
		} else {
			// share Files With User
			FileDao fileDaoObj = new FileDao();
			if(isContentManager || isManagerOrOwner) {
				fileDaoObj.createContentDocumentLinks(fileList, setOfContentApprovers);
			} else {
				fileDaoObj.removeContentDocumentLinks(fileList, setOfContentApprovers);
			}
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
	public Boolean toggleMemberManager(String collaborationGroupId, String userId, String newRole) {
		CollaborationGroupMember groupMemberObj = [SELECT CollaborationRole from CollaborationGroupMember WHERE CollaborationGroupId =:collaborationGroupId AND MemberId =:userId WITH SECURITY_ENFORCED];
		if( !groupMemberObj.CollaborationRole.equalsIgnoreCase(newRole) ) {
			groupMemberObj.CollaborationRole = newRole;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(groupMemberObj, new List<Schema.SObjectField>{CollaborationGroupMember.CollaborationRole});
		}

		return true;
	}
	


	public Boolean makeOwner(String collaborationGroupId,String userId){
 		CollaborationGroup colGroupObj = [SELECT id,OwnerId from CollaborationGroup WHERE Id =:collaborationGroupId WITH SECURITY_ENFORCED];
		String prevOwnerId = colGroupObj.OwnerId;
 		colGroupObj.OwnerId = userId;
 		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
 		SIMPESAPI.accessController().updateAsUser(colGroupObj, new List<Schema.SObjectField>{CollaborationGroup.OwnerId});
		
		return true;
	}
	
	public Boolean transferOwnershipInEFS(String collaborationGroupId, String newOwnerId,String previousOwnerId) {
		//check if new owner was manager /member before he was made owner		
		CollaborationgroupMember cgm = [Select CollaborationRole from CollaborationGroupMember where MemberId =:newOwnerId and CollaborationGroupId =:collaborationGroupId WITH SECURITY_ENFORCED];		
		String newOwnerRole = cgm.CollaborationRole;
		String prevOwnerId = previousOwnerId;
		Simpplr_Site__c siteObj = [SELECT Id, File_Storage_Source__c FROM Simpplr_Site__c WHERE 
				chatter_group_id__c=:collaborationGroupId WITH SECURITY_ENFORCED limit 1];
    	String fileStorageSource = siteObj.File_Storage_Source__c;
    	String siteId = siteObj.Id;
		
    	// For Simpplr Managed External File Storages
    	if(SimpplrContext.connectedStorages.contains(fileStorageSource) &&
    	  (ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileStorageSource) || ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileStorageSource) || ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(fileStorageSource) ||  ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileStorageSource)) ) {
	    	People_Integration__c oldOwner = null;
	    	People_Integration__c newOwner = null;
	    	Map<String, Object> soqlParamMap1 = new Map<String, Object>();
			soqlParamMap1.put('soqlParam1', fileStorageSource);
			soqlParamMap1.put('soqlParam2', prevOwnerId);
			soqlParamMap1.put('soqlParam3', newOwnerId);
			String queryStr = 'SELECT Connected__c, User_Email__c, Group_Id_Set__c, User__c FROM People_Integration__c WHERE name=:soqlParam1 AND (User__c =:soqlParam2 OR User__c =:soqlParam3) and is_deleted__c=false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap1);
	    	for(People_Integration__c peopleInteg: peopleIntegList) {
	    		if(newOwnerId.equalsIgnoreCase(peopleInteg.User__c)) {
	    			newOwner = peopleInteg;
	    		} else if(prevOwnerId.equalsIgnoreCase(peopleInteg.User__c)) {
	    			oldOwner = peopleInteg;
	    		}
	    	}    
	    	
	    	if(oldOwner!=null && newOwner!=null && (ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(fileStorageSource) ||  ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileStorageSource))) {
	    		List<Folder__c> folderList = new List<Folder__c>();
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', siteId);
				soqlParamMap.put('soqlParam2', fileStorageSource);
				String folderQuery = 'SELECT Id, External_Folder_Id__c, EFS_Shared_Folder_Id__c FROM Folder__c WHERE Site__c = :soqlParam1 AND Type__c = :soqlParam2 AND is_deleted__c = false';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
					folderList.add(fold);			
				}
				//change owner of site root folder and delete explicit writer role of previous owner when downgraded
				if(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(fileStorageSource)) {
					handleFolderOwnership(folderList.get(0).External_Folder_Id__c, prevOwnerId, newOwner.User_Email__c,oldOwner.User_Email__c, siteId, fileStorageSource);	
				} else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileStorageSource)) {
					handleFolderOwnership(folderList.get(0).EFS_Shared_Folder_Id__c, prevOwnerId, newOwner.User__c, oldOwner.User__c, siteId, fileStorageSource);	
				}
				
	    	    if('admin'.equalsIgnoreCase(newOwnerRole)){
		    	    // if new owner was Manager previously- add him to Read group
		    	    updateEFSGroup(newOwner.User_Email__c, collaborationGroupId, false, true, true, fileStorageSource);
	    	    } else if ('standard'.equalsIgnoreCase(newOwnerRole)){
		    	    //if new owner was member previously-add him to RW group
		    	    updateEFSGroup(newOwner.User_Email__c, collaborationGroupId, false, false, true, fileStorageSource);
	    	    }
	    	    
	    	    //remove previous owner from Read group
	    	    updateEFSGroup(prevOwnerId, collaborationGroupId, false, true, false, fileStorageSource);	    	
	    	} else if(oldOwner.Connected__c && newOwner == null){
	    		// Data will be lost warning and Storage will be set to Intranet - Winter18
	    		ManageApplicationDao.resetSiteConfigStorage(null, fileStorageSource, 'Intranet',siteId);    		
	    	} else if(oldOwner==null && newOwner.Connected__c) {
	    		// Create the root folder in new user drive
	    		Database.executeBatch(new BatchEFSFolderSync('SITE', '["' + siteId + '"]',fileStorageSource), 1);
	    	} else if(oldOwner==null && newOwner==null) {
				// Nothing To Do    		
	    	}
    	}
		    	
		return true;
	}
	
	
	 @future (callout =true)
    public static void handleFolderOwnership(String efsFileId, String siteOwnerId, String newOwnerKey, String oldOwnerKey, String siteId, String storageSource) {
		if(SimpplrContext.connectedStorages.contains(storageSource) && UserContext.connectedStorages.contains(storageSource)) {
			EFSAccessService.setUser(siteOwnerId);
			EFSFileService fs = new EFSFileService(storageSource);
			
			// Make the new owner as member to the shared folder
			if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(storageSource)) {
				fs.shareFolder(null, efsFileId, newOwnerKey, null);
			}
			
			try {
				fs.ownershipTransfer(efsFileId, newOwnerKey);
			} catch(EFSException te) {
				// Request Folder owner to transfer the folder manually
			}
						
			// Remove the current user edit access
			fs.unshareFolder(efsFileId, oldOwnerKey);
			
			fs.close();
		}
    }
    
    @future (callout =true)
    public static void updateEFSGroup(String userId,String groupId,Boolean ismemberRemovedFromSite,Boolean isReadGrp, Boolean addToGroup, String fileStorageSource){
        if(SimpplrContext.connectedStorages.contains(fileStorageSource) && 
                UserContext.connectedStorages.contains(fileStorageSource) && 
                !fileStorageSource.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING)) {
			List<People_Integration__c> peopleIntegObjList;
			if(addToGroup == false){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', userId);
				soqlParamMap.put('soqlParam2', fileStorageSource);
				String queryStr = 'SELECT Id,Group_Id_Set__c, User_Email__c FROM People_Integration__c WHERE People__r.User__c =:soqlParam1 and name=:soqlParam2';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				peopleIntegObjList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			}
			/**
				Remove member from 'r' group in both cases(Site public or private..  
				NOTE: here manager case will not come as manager can not be removed directly)
			**/
			EFSGroupService groupServiceObj = new EFSGroupService(fileStorageSource);
			String grpKey='';
			if(isReadGrp){
		    	grpKey = groupId + '.r@' + SimpplrContext.integrations.get(fileStorageSource).Enterprise_Id__c;
			}else{
				grpKey = groupId + '.rw@' + SimpplrContext.integrations.get(fileStorageSource).Enterprise_Id__c;
			}
			
			if(addToGroup) {
				groupServiceObj.addMember(grpKey, userId);	
			} else {
				if(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(SimpplrContext.integrations.get(fileStorageSource).name)){
					if(String.isNotBlank(peopleIntegObjList[0].Group_Id_Set__c)  && peopleIntegObjList[0].Group_Id_Set__c.containsIgnoreCase(groupId)){
		    			groupServiceObj.removeMember(grpKey, peopleIntegObjList[0].User_Email__c);	
					}
				} else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(SimpplrContext.integrations.get(fileStorageSource).name)){
					if(String.isNotBlank(peopleIntegObjList[0].User_Email__c)){
						grpKey = grpKey.toLowerCase();
		    			groupServiceObj.removeMember(grpKey, peopleIntegObjList[0].User_Email__c);	
					}
				}
			}
			groupServiceObj.close();
			
			if((ismemberRemovedFromSite || !addToGroup) && String.isNotBlank(peopleIntegObjList[0].Group_Id_Set__c)) {
		    	Set<String> grpIdSet = new Set<String>(peopleIntegObjList[0].Group_Id_Set__c.split(','));
		    	grpIdSet.remove(groupId);
		    	peopleIntegObjList[0].Group_Id_Set__c = String.join(new list<String>(grpIdSet),',');
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(peopleIntegObjList[0], new List<Schema.SObjectField>{
									People_Integration__c.Group_Id_Set__c
								});
		    	
			}
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
	public Boolean removeMember(String collaborationGroupId, String userId ) {
		List<CollaborationGroupMember> groupMemberList= [SELECT CollaborationGroupId,CollaborationRole from CollaborationGroupMember WHERE CollaborationGroupId=:collaborationGroupId AND MemberId=:userId WITH SECURITY_ENFORCED];
		if(groupMemberList.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(groupMemberList[0]);
			return true;
		} else {
			return false;
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
	public static Boolean addMember(String collaborationGroupId, List<String> userIds ) {
		List<CollaborationGroupMember> groupMembersList = new List<CollaborationGroupMember>();
		
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', userIds);
		String query = 'select a.id from User a where UserPreferencesDisableAllFeedsEmail = false '+
														' and a.id IN :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.With);
		Map<String,User> mapOfUserIds = new Map<String,User>((List<User>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap));
														
		List<String> listOfUsersWithEmailEnabled = new List<String>(mapOfUserIds.keySet());
		
		if(SimpplrContext.isFeatureEnabled('Salesforce_Chatter_Emails_Switched_On')) {
			Utility.setChatterEmailSettingsForUsers(true,listOfUsersWithEmailEnabled);	
		}													
		
		for(String userId : userIds) {
			CollaborationGroupMember groupMemberObj= new CollaborationGroupMember();
			groupMemberObj.CollaborationRole='Standard';
			groupMemberObj.CollaborationGroupId=collaborationGroupId;
			groupMemberObj.MemberId=userId;
			
			groupMembersList.add(groupMemberObj);
		}
		Utility.IsSiteCreationFromSimpplrUI = true;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(groupMembersList,
															new List<Schema.SObjectField>{
	    														CollaborationGroupMember.CollaborationRole,
	    														CollaborationGroupMember.CollaborationGroupId,
	    														CollaborationGroupMember.MemberId
	    													});
		
		if(SimpplrContext.isFeatureEnabled('Salesforce_Chatter_Emails_Switched_On')) {								
			Utility.setChatterEmailSettingsForUsers(false,listOfUsersWithEmailEnabled);	
		}    													
    	
		return true;
	}

	public Boolean addPeople(String collaborationGroupId, List<SiteWrapper.UserDetail> userDetailList) {
		List<String> userIds = new List<String>();
		for(SiteWrapper.UserDetail userDetailObj : userDetailList) {
			userIds.add(userDetailObj.sfUserId);
		}

		Boolean success = false;
		Simpplr_Site__c siteObj = [Select Id From Simpplr_Site__c Where Chatter_Group_Id__c = :collaborationGroupId WITH SECURITY_ENFORCED];
		List<CollaborationGroupMember> collaborationGroupMemberList = [Select Id From CollaborationGroupMember Where CollaborationGroupId = :collaborationGroupId AND MemberId IN :userIds WITH SECURITY_ENFORCED];
		
        if(collaborationGroupMemberList.isEmpty()) {
            success = addMember(collaborationGroupId,userIds);
        } else {
			assignSiteRoles(siteObj.Id, userIds[0], '', false, false);
            success = ToggleMemberManager(collaborationGroupId,userIds[0],'Standard');
        }

		return success;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public void setPrivate (SiteWrapper.PrivateWrapper privateObj){
		try {
			List<CollaborationGroup> listOfCollaborationGroup= new List<CollaborationGroup>();
			List<String> chatterGroupIds= new List<String>();
			List<String> listOfSiteIds=privateObj.idsArray;
			Boolean makeItPrivateOrNot=privateObj.makePrivateBool;
			
			List<Simpplr_Site__c> listOfSimpplrSite= [SELECT Id, Chatter_Group_Id__c,Site_Type__c from Simpplr_Site__c where id=:listOfSiteIds WITH SECURITY_ENFORCED];
			
			for(Simpplr_Site__c siteObj: listOfSimpplrSite ){
				
				if(makeItPrivateOrNot==true && ('Public'.equalsIgnoreCase(siteObj.Site_Type__C) || 'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__C))){
					chatterGroupIds.add(siteObj.Chatter_Group_Id__c);
				}
				if(makeItPrivateOrNot==false && ('Private'.equalsIgnoreCase(siteObj.Site_Type__C) || 'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__C))){
					chatterGroupIds.add(siteObj.Chatter_Group_Id__c);
				}
			}
			
			for(String chatterId:chatterGroupIds){
				CollaborationGroup colabObj= new CollaborationGroup();
				colabObj.Id=chatterId;
				colabObj.CollaborationType=makeItPrivateOrNot?'Private':'Public';
				listOfCollaborationGroup.add(colabObj);
				}
			if(!listOfCollaborationGroup.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,CollaborationGroup>(listOfCollaborationGroup),new List<Schema.SObjectField>{CollaborationGroup.CollaborationType});
			}
		} catch(Exception ex) {
			if(ex.getMessage().containsIgnoreCase('INSUFFICIENT_ACCESS_OR_READONLY')) {
				throw new SimpplrException(ExceptionCode.INSUFFICIENT_ACCESS_OR_READONLY.name());
			} else if(ex.getMessage().containsIgnoreCase('INVALID_OPERATION') &&
			 	ex.getMessage().containsIgnoreCase('You cannot delete the owner from a group of type collaboration')){
		 		
		 		throw new SimpplrException(ServiceConstants.OPERATION_ON_INACTIVE_USER_CONTENT);
			} else if(ex.getMessage().containsIgnoreCase('Public groups can\'t have customers')){
				throw new SimpplrException('It\'s not possible to make this Site Public, "Allow Customers" is enabled');
			} else {
				throw ex;
			}
		}
	}
	
	public String deActivateSite (String siteId){
		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT Chatter_Group_Id__c, name FROM Simpplr_Site__c WHERE id =:siteId WITH SECURITY_ENFORCED];
		
		String siteName = null;
		if(!listOfSimpplrSite.isEmpty()){
			siteName = listOfSimpplrSite[0].name;

			CollaborationGroup colabObj = new CollaborationGroup();
			colabObj.Id = listOfSimpplrSite[0].Chatter_Group_Id__c;
			colabObj.IsArchived = true;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(colabObj, new List<Schema.SObjectField>{CollaborationGroup.IsArchived});
		}

		return siteName;
	}

	public void setActivate (SiteWrapper.ActivateWrapper activateObj){
		List<CollaborationGroup> listOfCollaborationGroup= new List<CollaborationGroup>();
		List<Simpplr_Site__c> listOfSitesToBeDeactivated= new List<Simpplr_Site__C>();
		List<String> chatterGroupIds= new List<String>();
		List<String> listOfSiteIds=activateObj.idsArray;
		List<Simpplr_Site__c> listOfSimpplrSite= [SELECT Chatter_Group_Id__c from Simpplr_Site__c where id=:listOfSiteIds WITH SECURITY_ENFORCED];
		for(Simpplr_Site__c siteObj: listOfSimpplrSite ){
			chatterGroupIds.add(siteObj.Chatter_Group_Id__c);
		}
		for(String chatterId:chatterGroupIds){
			CollaborationGroup colabObj= new CollaborationGroup();
			colabObj.Id=chatterId;
			colabObj.IsArchived = !activateObj.makeActivatedBool;
			listOfCollaborationGroup.add(colabObj);
		}
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,CollaborationGroup>(listOfCollaborationGroup),new List<Schema.SObjectField>{CollaborationGroup.IsArchived});
	}
	
	public SiteListingWrapper setCategory (SiteWrapper.EditSiteCategoryWrapper editSiteCategoryObj){
		SiteListingWrapper siteWrapObj = new SiteListingWrapper();

		//CategoryWrapper categoryWrpperObj = editSiteCategoryObj.categoryId;
		String categoryNameToBeInserted = editSiteCategoryObj.categoryObj.categoryName;
		String categoryId = editSiteCategoryObj.categoryObj.category;
		List<String> listOfSiteIds=editSiteCategoryObj.idsArray;
		Site_Category__c siteCategoryObj = new Site_Category__c();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', categoryNameToBeInserted);
		String query = 'SELECT Id, Name__c FROM Site_Category__c WHERE Name__c =:soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Category__c> listOfCategories = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);		
			if (!listOfCategories.isEmpty()){
				categoryId = listOfCategories[0].Id;
				siteCategoryObj.name = categoryNameToBeInserted;
			
			} else if(String.isBlank(categoryId) && String.isNotBlank(categoryNameToBeInserted)) {
				CategoryDao catDaoObj = new CategoryDao();
				siteCategoryObj = catDaoObj.addSiteCategory(categoryNameToBeInserted);
				categoryId = siteCategoryObj.Id;
			}

		// if new category being added before assigning it to site.
		
		Set<String> groupIdSet = new Set<String>();
		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT id,chatter_group_id__c,Site_Category__c from Simpplr_Site__c where id=:listOfSiteIds WITH SECURITY_ENFORCED];
		for(Simpplr_Site__c sc : listOfSimpplrSite){
			sc.Site_Category__c = categoryId;
			sc.Last_Edited_DateTime__c = DateTime.now();
			groupIdSet.add(sc.chatter_group_id__c);
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(listOfSimpplrSite)
														,new List<Schema.SObjectField>{Simpplr_Site__c.Site_Category__c, Simpplr_Site__c.Last_Edited_DateTime__c});
		
		
		String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE+' AND Chatter_Group_Id__c IN:groupIdSet';
		List<Simpplr_Site__c> listOfSimpplrSites = Database.query(queryStr);
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSites.isEmpty()) {
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSites) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
		}
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = getMapOfIdWithCollaborationGroup(listOfCollGroupId,
				UserContext.id);
		
		for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSites) {
			
			siteWrapObj = ObjectToWrapperAdapter.generateSiteWrapFromSiteAndCollGrp(simpplrSiteObj,
			mapOfIdWithCollaborationGrp.get(simpplrSiteObj.Chatter_Group_Id__c));
		}
		return 	siteWrapObj;
	}
	
	/**
	 * @description createSimpplrSites : create site from collaboration group
	 * @param listOfCollaborationGroups
	 * @return List<Simpplr_Site__c>
	 */
    public List<Simpplr_Site__c> createSimpplrSites(List<CollaborationGroup> listOfCollaborationGroups) {
		List<Simpplr_Site__c> listOfSitesToCreate = new List<Simpplr_Site__c>();
		
		for(CollaborationGroup collaborationGroupObj : listOfCollaborationGroups) {
			Simpplr_Site__c siteObject = new Simpplr_Site__c();
			siteObject.Name = collaborationGroupObj.Name;
			siteObject.Chatter_Group_Id__c = collaborationGroupObj.Id;  
			siteObject.Site_Type__c = collaborationGroupObj.CollaborationType;
			siteObject.Is_Active__c = !collaborationGroupObj.IsArchived;
			
			siteObject.Origin__c = 'Chatter';
			siteObject.Show_In_Simpplr__c = SimpplrContext.autoConvertChatterGroupToSite;
			
			if(siteObject.Show_In_Simpplr__c == false) {
				siteObject.Has_Albums__c = false;
				siteObject.Has_Events__c = false;
				siteObject.Has_Pages__c = false;
				siteObject.Landing_Page__c = 'feed';
			}else {
    			siteObject.Has_Albums__c = true;
				siteObject.Has_Events__c = true;
				siteObject.Has_Pages__c = true;
				siteObject.Landing_Page__c = 'feed';
    		}    		
    		siteObject.Last_Edited_DateTime__c = DateTime.now();
			
			listOfSitesToCreate.add(siteObject);
		}
		
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listOfSitesToCreate,new List<Schema.SObjectField>{
															Simpplr_Site__c.Name,
															Simpplr_Site__c.Chatter_Group_Id__c,
															Simpplr_Site__c.Site_Type__c,
															Simpplr_Site__c.Is_Active__c,
															Simpplr_Site__c.Has_Albums__c,
															Simpplr_Site__c.Has_Events__c,
															Simpplr_Site__c.Has_Pages__c,
															Simpplr_Site__c.Landing_Page__c,
															Simpplr_Site__c.Origin__c,
															Simpplr_Site__c.Show_In_Simpplr__c});
															
		List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)result.getInsertedObjects();
    	
    	createSystemFolders(siteList);
		return siteList;
    }
    
    public void createSystemFolders(List<Simpplr_Site__c> siteList) {
    	List<Folder__c> siteSystemFolderList = new List<Folder__c>();
    	
    	Set<ID> newSitesIdSet = new Set<ID>();
    	
    	for(Simpplr_Site__c siteObj : siteList){
    		for (String folderKey : ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.keySet()){
    			if(folderKey.equalsIgnoreCase('GDRIVE_FILES') || folderKey.equalsIgnoreCase('DROPBOX_FILES')
    					|| folderKey.equalsIgnoreCase('CRM_FILES') || folderKey.equalsIgnoreCase('BOX_FILES')) {
    				// Don't create gdrive/dropbox/crm/box system folder
    			} else {
					if('QUESTION_FILES'.equalsIgnoreCase(folderKey) && !SimpplrContext.isQuestionAnswerFeatureEnabled) {
						continue;
					}
	       			String folderName = ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get(folderKey);
	    			Folder__c siteSystemFolderObj = new Folder__c();
		    		siteSystemFolderObj.Name__c = folderName;
		    		siteSystemFolderObj.Site__c = siteObj.id;
		    		siteSystemFolderObj.Is_System_Folder__c  = true;
		    		siteSystemFolderObj.Type__c = ServiceConstants.SITE_SYSTEM_FOLDERS_TYPE_MAP.get(folderKey);
		    		siteSystemFolderObj.Permissions__c = 'Read';
		    		siteSystemFolderObj.Is_Hidden__c = false;		    		
		    		siteSystemFolderList.add(siteSystemFolderObj);	
    			}
    		}
    		if(SimpplrContext.isNativeVideo) {
				Folder__c siteSystemFolderObj = new Folder__c();
				siteSystemFolderObj.Name__c = ServiceConstants.SITE_VIDEOS_SYSTEM_FOLDER;
				siteSystemFolderObj.Site__c = siteObj.id;
				siteSystemFolderObj.Is_System_Folder__c  = true;
				siteSystemFolderObj.Type__c = ServiceConstants.VIDEO_PROVIDER_NATIVE;
				siteSystemFolderObj.Permissions__c = 'Read';
				siteSystemFolderObj.Is_Hidden__c = false;
				
				siteSystemFolderList.add(siteSystemFolderObj);
			}
    		newSitesIdSet.add(siteObj.id);
       	}
       
       	if(!siteSystemFolderList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
       	   	SIMPSFDCAccessControlResults.InsertResults folderInsertionResult = SIMPESAPI.accessController().insertAsUser(siteSystemFolderList,new List<Schema.SObjectField>{
	    														Folder__c.Name__c,
	    														Folder__c.Site__c,
	    														Folder__c.Is_System_Folder__c,
	    														Folder__c.Type__c,
	    														Folder__c.Permissions__c,
	    														Folder__c.Is_Hidden__c});
	    	List<Folder__c> subFolderList = new List<Folder__c>();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', newSitesIdSet);
			String folderQuery = 'SELECT Id, Site__c, path__c, Name__c FROM Folder__c WHERE Is_System_Folder__c = true AND (Site__c IN :soqlParam1) AND Name__c in (\'Content Files\', \'Feed Files\', \'Question Files\')';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			String albumSystemFolderName = ServiceConstants.DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP.get('ALBUMS');
			String videosSystemFolderName = ServiceConstants.DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP.get('VIDEOS');
	    	String folderPath;
    		for(Folder__c folderObj : folderList){
				for(String subFolderName : ServiceConstants.DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP.values()) {
					if(('Feed Files'.equalsIgnoreCase(folderObj.Name__c) || 'Question Files'.equalsIgnoreCase(folderObj.Name__c)) && subFolderName.equalsIgnoreCase(albumSystemFolderName)) {
						//Skip Albums folder for Feed Files
						continue;
					} else if(subFolderName.equalsIgnoreCase(videosSystemFolderName) && !SimpplrContext.isNativeVideo) {
						continue;
					}
					Folder__c siteSystemSubFolderObj = new Folder__c();
					siteSystemSubFolderObj.Name__c = subFolderName;
					siteSystemSubFolderObj.Site__c = folderObj.Site__c;
					siteSystemSubFolderObj.Is_System_Folder__c  = true;
					if(subFolderName.equalsIgnoreCase(videosSystemFolderName)) {
						siteSystemSubFolderObj.Type__c = ServiceConstants.VIDEO_PROVIDER_NATIVE;
					} else {
						siteSystemSubFolderObj.Type__c = 'Intranet';
					}
					siteSystemSubFolderObj.Parent_Folder__c = folderObj.Id;
					siteSystemSubFolderObj.Permissions__c = 'Read';
					siteSystemSubFolderObj.Is_Hidden__c = subFolderName.equalsIgnoreCase(albumSystemFolderName);
					siteSystemSubFolderObj.Path__c = folderObj.id;
					subFolderList.add(siteSystemSubFolderObj);
				}				
	    	}
	    	
	    	if(!subFolderList.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
       	   		SIMPESAPI.accessController().insertAsUser(subFolderList,new List<Schema.SObjectField>{
	    														Folder__c.Name__c,
	    														Folder__c.Site__c,
	    														Folder__c.Is_System_Folder__c,
	    														Folder__c.Type__c,
	    														Folder__c.Parent_Folder__c,
	    														Folder__c.Path__c,
	    														Folder__c.Permissions__c,
	    														Folder__c.Is_Hidden__c});
	   
	    	}
       	}
    }
    
    public Boolean isSitePrivate(String siteId) {
    	Boolean isPrivate = false;
		List<Simpplr_Site__c> siteList = [Select Site_Type__c FROM Simpplr_Site__c where Id =: siteId];
	
    	if(!siteList.isEmpty()) {
    		isPrivate = ('Private'.equalsIgnoreCase(siteList[0].Site_Type__c));
    	}
    	
    	return isPrivate;
    }

	public String getSiteName(String siteId) {
    	String siteName;
		List<Simpplr_Site__c> siteList = [Select Name FROM Simpplr_Site__c where Id =: siteId];
	
    	if(!siteList.isEmpty()) {
    		siteName = siteList[0].Name;
    	}
    	
    	return siteName;
    }
    
    public void setSiteSequence(String segmentId, List<Id> listOfSiteIds){
    	Integer orderSeq = 1;
    	if(String.isBlank(segmentId)){
	    	List<Simpplr_Site__c> orderedList = new List<Simpplr_Site__c>();
	    	Map<Id,Simpplr_Site__c> mapOfOrderedSite = new Map<Id,Simpplr_Site__c>([SELECT Id,Order__c From Simpplr_Site__c WHERE Is_Featured__c=true AND Is_Active__c=true AND Is_Deleted__c=false AND Id =:listOfSiteIds WITH SECURITY_ENFORCED]);
	    	
	    	for(Id siteId : listOfSiteIds){
	    		if(mapOfOrderedSite.containsKey(siteId)){
	    			Simpplr_Site__c orderedSite= new Simpplr_Site__c(Id = siteId, Order__C = orderSeq);
	    			orderedList.add(orderedSite);
	    			orderSeq = orderSeq + 1;	
	    		}
	    	}
	    	update orderedList;
    	
    	} else {
	    	List<Segment_Site__c> orderedList = new List<Segment_Site__c>();
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', segmentId);
			soqlParamMap.put('soqlParam2', listOfSiteIds);
	    	String query = 'SELECT Id,Order__c, Segment__c, Site__c From Segment_Site__c WHERE Is_Featured__c=true AND Site__r.Is_Active__c=true AND Site__r.Is_Deleted__c=false AND segment__c =:soqlParam1 AND site__c = :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Segment_Site__c> listOfSegmentSite = (List<Segment_Site__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
	    	Map<Id, Segment_Site__c> mapOfOrderedSegmentSite = new Map<Id, Segment_Site__c>();
	    	for(Segment_Site__c segmentSiteObj : listOfSegmentSite){
	    		mapOfOrderedSegmentSite.put(segmentSiteObj.Site__c, segmentSiteObj);	
	    	}
	    	
	    	for(Id siteId : listOfSiteIds){
	    		if(mapOfOrderedSegmentSite.containsKey(siteId)){
	    			Segment_Site__c orderedSite= new Segment_Site__c(Id = mapOfOrderedSegmentSite.get(siteId).Id, Order__C = orderSeq);
	    			orderedList.add(orderedSite);
	    			orderSeq = orderSeq + 1;	
	    		}
	    	}
			if(orderedList.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Segment_Site__c>(orderedList),new List<Schema.SObjectField>{
								Segment_Site__c.Order__C});
			}	
    	}
    }
    
	public void setFeatured(SiteWrapper.FeaturedWrapper featuredObj){
		if (featuredObj.makeFeaturedBool == false) {
			List<Simpplr_Site__c> listUpdateSites = new List<Simpplr_Site__c>();
			for (Id siteId: featuredObj.listOfSiteIds){
				Simpplr_Site__c site2Update= new Simpplr_Site__c(Id = siteId, Is_Featured__c = false, Order__c = null, Last_Edited_DateTime__c = DateTime.now());
				listUpdateSites.add(site2Update);
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listUpdateSites),
															new List<Schema.SObjectField> {
																	Simpplr_Site__c.Is_Featured__c,
																	Simpplr_Site__c.Order__c,
																	Simpplr_Site__c.Last_Edited_DateTime__c
															});
		} else {
			List<Simpplr_Site__c> listSites = [select Id, Order__c, Is_Featured__c from Simpplr_Site__c where (Is_featured__c = true or Id in :featuredObj.listOfSiteIds) WITH SECURITY_ENFORCED order by Order__c, name limit 10000];
			Integer order = 1;
			Set<String> setOfIds = new Set<String>(featuredObj.listOfSiteIds);
			for(Simpplr_Site__c currentSite : listSites) {
				if(setOfIds.contains(currentSite.Id)) {
					currentSite.Order__c = order++;
		        	currentSite.is_featured__c = true;
		        	currentSite.Last_Edited_DateTime__c = DateTime.now();
		    	} 
			}
			for(Simpplr_Site__c currentSite : listSites) {
				if(setOfIds.contains(currentSite.Id) == false) {
		        	currentSite.Order__c = order++;
		        	currentSite.Last_Edited_DateTime__c = DateTime.now();
				}
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listSites),
															new List<Schema.SObjectField> {
																	Simpplr_Site__c.Is_Featured__c,
																	Simpplr_Site__c.Order__c,
																	Simpplr_Site__c.Last_Edited_DateTime__c
															});
		}
    }
    
    public void setFeaturedWithSegment (SiteWrapper.FeaturedWrapper featuredObj) {
		if (featuredObj.makeFeaturedBool == false) {		
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', featuredObj.segmentId);
			soqlParamMap.put('soqlParam2', featuredObj.listOfSiteIds);
    		String query = 'select id from Segment_Site__c where segment__c=:soqlParam1 and site__c=:soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Segment_Site__c> segmentSiteListToDelete = (List<Segment_Site__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

			if(segmentSiteListToDelete.isEmpty() == false){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(segmentSiteListToDelete);
			}
			List<Simpplr_Site__c> listUpdateSites = new List<Simpplr_Site__c>();
			for (Id siteId: featuredObj.listOfSiteIds){
				Simpplr_Site__c siteUpdate= new Simpplr_Site__c(Id = siteId, Last_Edited_DateTime__c = DateTime.now());
				listUpdateSites.add(siteUpdate);
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listUpdateSites),
															new List<Schema.SObjectField> {
																	Simpplr_Site__c.Last_Edited_DateTime__c
															});
		} else{
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', featuredObj.listOfSiteIds);
			soqlParamMap.put('soqlParam2', featuredObj.segmentId);
    		String query = 'select id from Simpplr_Site__c where id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			List<String> siteIds = new List<String>();

			for(Simpplr_Site__c siteObj : siteList) {
				siteIds.add(siteObj.id);
			}
			soqlParamMap.put('soqlParam3', siteIds);
    		String strQuery = 'select Id, (Select id, order__c from Site_Segments__r where segment__c=:soqlParam2) from Simpplr_Site__c where id=:soqlParam3';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Simpplr_Site__c> listSites = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUSer(strQuery, soqlParamMap);
			List<Segment_Site__c> segmentSiteNewList = new List<Segment_Site__c>();
			List<Segment_Site__c> segmentSiteUpdatedList = new List<Segment_Site__c>();
			Integer order = 1;
			for(Simpplr_Site__c currentSite : listSites) {
				currentSite.Last_Edited_DateTime__c = DateTime.now();
				if(currentSite.Site_Segments__r.isEmpty()) {
					Segment_Site__c segmentSiteObj = new Segment_Site__c(Order__c = order++, is_featured__c = true, segment__c=featuredObj.segmentId, Site__c=currentSite.id);
	            	segmentSiteNewList.add(segmentSiteObj);
	        	} else {
	        		Segment_Site__c segmentSiteObj = currentSite.Site_Segments__r[0];
	            	segmentSiteObj.Order__c = order++;
	            	segmentSiteUpdatedList.add(segmentSiteObj);
        		}
			}
			
			String queryStr = 'select Id, order__c, site__c from Segment_Site__c where site__c !=:soqlParam1 and segment__c=:soqlParam2 order by order__c, Site__r.Name';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Segment_Site__c> listSegmentSites  = (List<Segment_Site__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap);
			for(Segment_Site__c segmentSiteObj : listSegmentSites) {
            	segmentSiteObj.Order__c = order++;
            	segmentSiteUpdatedList.add(segmentSiteObj);
			}
		
			insert segmentSiteNewList;
			if(listSites.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listSites),new List<Schema.SObjectField>{
							Simpplr_Site__c.Last_Edited_DateTime__c});
			}
			if(segmentSiteUpdatedList.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Segment_Site__c>(segmentSiteUpdatedList),new List<Schema.SObjectField>{
								Segment_Site__c.Order__c});
			}		
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
	public Map<String, Folder__c> getMapOfSystemFoldersForSite(String siteId) {
		Map<String, Folder__c> mapOfSystemFolders = new Map<String, Folder__c>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		String folderQuery = 'SELECT Id, Parent_Folder__r.Name__c, Name__c FROM Folder__c WHERE Site__c = :soqlParam1 AND Is_System_Folder__c = true AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfSystemFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		
		for(Folder__c folderObj : listOfSystemFolders){
			if(String.isNotBlank(folderObj.Parent_Folder__r.Name__c)) {
				mapOfSystemFolders.put(folderObj.Parent_Folder__r.Name__c + '.' + folderObj.Name__c, folderObj);
			} else {
				mapOfSystemFolders.put(folderObj.Name__c, folderObj);
			}
		}	
		return mapOfSystemFolders;
	}

    /**
     * @description existing site names
     * @param siteList - containing simpplr site Object
     */
	public void createContentDocumentLink(List<Simpplr_Site__c> siteList) {
		List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
    	Set<Id> idSet = new Set<Id>();
    	
    	logger.logDebug('SiteDao.createContentDocumentLink() ---- siteList ----' + siteList);
    	
    	for (Simpplr_Site__c site : siteList){
	    	if('Unlisted'.equalsIgnoreCase(site.Site_Type__c)) {
				ContentDocumentLink cdLink = new ContentDocumentLink();
				cdLink.ContentDocumentId = site.Title_Content_Document__c; 
				cdLink.ShareType = 'C';
				cdLink.LinkedEntityId = site.Chatter_Group_Id__c;
				cdlInsert.add(cdLink);
			}else {
				ContentDocumentLink cdLink2 = new ContentDocumentLink();
				cdLink2.ContentDocumentId = site.Title_Content_Document__c; 
				cdLink2.ShareType = 'V';
				cdLink2.LinkedEntityId = UserInfo.getOrganizationId();               
				cdlInsert.add(cdLink2);
				
			}
    	}
    	
    	logger.logDebug('SiteDao.createContentDocumentLink() ---- cdlInsert ----' + cdlInsert);
    	Database.SaveResult[] srList = Database.insert(cdlInsert , true);
	}

    /**
     * @description existing site names
     * @param siteList - containing simpplr site Object
     * @param type - containing simpplr site Object
     * @param allOrNone - containing simpplr site Object
     */
    public void createCDLSiteCover(List<Simpplr_Site__c> siteList, Boolean allOrNone){
    	List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();

    	logger.logDebug('SiteDao.createContentDocumentLink() ---- siteList ----' + siteList);
		// create contentDocument Link
		for (Simpplr_Site__c site : siteList){
			ContentDocumentLink cdLink = new ContentDocumentLink();
		    if('Unlisted'.equalsIgnoreCase(site.Site_Type__c)) {
				cdLink.ShareType = 'C';
				cdLink.LinkedEntityId = site.Chatter_Group_Id__c;
			}else {
				cdLink.ShareType = 'V';
				cdLink.LinkedEntityId = UserInfo.getOrganizationId();               
			}
			cdLink.ContentDocumentId = site.Cover_Content_Document__c;
			cdlInsert.add(cdLink);
		}	

    	logger.logDebug('SiteDao.createContentDocumentLink() ---- cdlInsert ----' + cdlInsert);
    	Database.SaveResult[] srList = Database.insert(cdlInsert , allOrNone);
    	logger.logDebug('SiteDao.createContentDocumentLink() ---- srList ----' + srList);
	}
	
	public void createCDLWithGroup(String cdId, String groupId, Boolean isSitePublic) {
    	List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
    	
    	if(isSitePublic) {
			ContentDocumentLink cdLink2 = new ContentDocumentLink();
			cdLink2.ContentDocumentId = cdId; 
			cdLink2.ShareType = 'V';
			cdLink2.LinkedEntityId = groupId;               
			cdlInsert.add(cdLink2);
		}else {
			ContentDocumentLink cdLink = new ContentDocumentLink();
			cdLink.ContentDocumentId = cdId; 
			cdLink.ShareType = 'C';
			cdLink.LinkedEntityId = groupId;
			cdlInsert.add(cdLink);
		}
		
		Database.SaveResult[] srList = Database.insert(cdlInsert , true);
    }
	
    public List<File__c> insertSiteFileRecords(List<File__c> filesList) {
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(
        																						filesList, 
        																						new List<Schema.SObjectField> {
                                                                                                    File__c.Title__c, 
                                                                                                    File__c.Size__c,
                                                                                                    File__c.MIME_Type__c,
                                                                                                    File__c.Content_Version__c,
                                                                                                    File__c.Content_Document__c,
                                                                                                    File__c.Folder__c,
                                                                                                    File__c.Content_Name__c,
                                                                                                    File__c.URL__c,
                                                                                                    File__c.Thumbnail_URL__c,
                                                                                                    File__c.Location__c,
                                                                                                    File__c.Site__c
																								});
    	return result.getInsertedObjects();
    }
    
    public List<Simpplr_Site__c> getAvailableSitesForNewsLetter(String searchTerm, Set<Id> listedCGIManageSet) {
    	
		String queryString = SITE_BASE_QUERY+' FROM Simpplr_Site__c WHERE is_Active__c=true and Show_In_Simpplr__c = true '+ 
							' AND is_Deleted__c=false AND name Like:searchTerm';
		if((UserContext.isUserAppModerator || UserContext.canSendNewsletter) == false){
			queryString = queryString + ' AND Is_Newsletter_Allowed__c = true ';
		}
		
		queryString = queryString + ' AND Chatter_Group_Id__c IN:listedCGIManageSet  order by Name ';
		List<Simpplr_Site__c> listOfSimpplrSite = Database.query(queryString);
		return listOfSimpplrSite;
    }
    
    public List<Simpplr_Site__c> getAvailableSitesForAlert(String searchTerm, Set<Id> listedCGIManageSet, Integer recordLimit, Integer offset) {
    	
		String queryString = SITE_BASE_QUERY+' FROM Simpplr_Site__c WHERE is_Active__c=true and Show_In_Simpplr__c = true '+ 
								' AND is_Deleted__c=false AND name Like:searchTerm';
		if((UserContext.isUserAppModerator || UserContext.canSendAlerts) == false){
			queryString = queryString + ' AND Is_Alert_Enabled__c = true ';
		}
		
		queryString = queryString + ' AND Chatter_Group_Id__c IN:listedCGIManageSet  order by Name ';
		if(recordLimit != null){
			queryString = queryString + ' LIMIT '+ recordLimit;
		}
		if(offset != null){
			queryString = queryString + ' OFFSET '+ offset;
		}
		List<Simpplr_Site__c> listOfSimpplrSite = Database.query(queryString);
		return listOfSimpplrSite;
    }
    
    public List<Simpplr_Site__c> searchSitesForAnalytics(String searchTerm, Set<Id> siteIManageIdSet) {
    	
		String queryString = SITE_BASE_QUERY+' FROM Simpplr_Site__c WHERE is_Active__c=true '+ 
								' AND is_Deleted__c=false AND name Like:searchTerm AND Id IN :siteIManageIdSet ';
		
		
		List<Simpplr_Site__c> listOfSites = Database.query(queryString);
		return listOfSites;
    }
    
    public List<Simpplr_Site__c> searchListedSites(String searchTerm, Set<Id> setOfCollGrpId) {
    	String queryString = SITE_BASE_QUERY+' FROM Simpplr_Site__c WHERE is_Active__c=true and Show_In_Simpplr__c = true '+ 
								' AND is_Deleted__c=false AND name Like:searchTerm  AND Chatter_Group_Id__c IN: setOfCollGrpId ';
    	List<Simpplr_Site__c> listOfSites = Database.query(queryString);
    	return listOfSites;
    }
    
    public List<Simpplr_Site__c> getSitesCanSubmitContent(String searchTerm, Set<Id> siteIFollowIdSet) {
        String  searchClause = ' ';

        if (searchTerm != null) {
            searchClause = ' AND name Like:searchTerm ';
        }
 
        String queryString = SITE_BASE_QUERY+' FROM Simpplr_Site__c '+ 
                ' WHERE is_Active__c=true and Show_In_Simpplr__c = true '+ 
				' AND is_Deleted__c=false ' + searchClause +  
                ' AND Id IN :siteIFollowIdSet ';
		List<Simpplr_Site__c> listOfSites = Database.query(queryString);
    	return listOfSites;
    }

    public List<Simpplr_Site__c> getSitesCanBeMentionedInFeed(String searchTerm) {
    	Set<Id> allowCustomerCGIdSet = new Set<Id>();
		Set<Id> cgIFollowIdSet = new Set<Id>();
		String queryString = SITE_BASE_QUERY+' FROM Simpplr_Site__c WHERE Site_Type__c != \'Unlisted\' AND is_Active__c=true '+ 
							' AND Show_In_Simpplr__c = true AND is_Deleted__c=false AND name Like:searchTerm ';
		
		List<CollaborationGroupMember> memberList = [SELECT Id,CollaborationRole,CollaborationGroupId, CollaborationGroup.CanHaveGuests FROM CollaborationGroupMember 
														WHERE CollaborationGroup.CollaborationType !='Unlisted' AND CollaborationGroup.CanHaveGuests = false AND ((CollaborationGroup.IsBroadcast = false AND memberId=:UserContext.userId) OR 
														(CollaborationGroup.IsBroadcast = true AND CollaborationRole = 'Admin' AND memberId=:UserContext.userId)) WITH SECURITY_ENFORCED];
		for(CollaborationGroupMember cgMember :memberList){
			cgIFollowIdSet.add(cgMember.CollaborationGroupId);
		}
		
		queryString = queryString +' AND (Site_Type__c = \'Public\' OR Chatter_Group_Id__c IN :cgIFollowIdSet) ';
    	
		List<Simpplr_Site__c> listOfSites = Database.query(queryString);
    	return listOfSites;
    }
    
    public List<String> getSiteFieldList() {
    	List<String> siteFieldList = New List<String>{
    		'chatter_group_id__c',
			'id',
			'name',
			'Has_Albums__c',
			'Has_Events__c',
			'Has_Pages__c',
			'Landing_Page__c', 
			'Title_Content_Version__c',
			'Title_Content_Document__c',
			'Site_Type__c',
			'Is_Active__c',
            'File_Storage_Source__c',
			'Is_Featured__c',
			'Site_Category__r.access__c',
			'Site_Category__r.Name__c',
			'Site_Category__c',
			'Allow_Public_Contribution__c',
			'Question_Answer_Enabled__c',
			'Slack_Channel_Id__c',
			'Slack_Channel_Name__c',
			'Slack_Url__c',
			'Is_Membership_Auto_Approved__c',
			'Is_Leadercast_Enabled__c',
			'Allow_File_Upload_App_Permission__c',
			'Member_Count__c',
			'Follower_Count__c',
			'(SELECT id FROM Site_Membership_Request__r WHERE Request_By__c=:loggedInPeopleId AND Status__c=\'Pending\') ',
			'(SELECT Id, Type__c, CreatedById FROM Bookmarked_Simpplr_Site__r WHERE People__c =:loggedInPeopleId AND Type__c=\'site\' AND Is_Deleted__c = false )',
			'(SELECT id FROM Simpplr_Content_Site__r WHERE is_published__c=true AND is_deleted__c=false AND Activated_By_Feature__c=true AND Type__c IN : allowedFeaturesInAppList limit 1)'
        };
        
        // Check if segmentation enabled
        if(SimpplrContext.isSegmentsEnabled){
        	if(String.isNotBlank(segmentId)){
        		siteFieldList.add('(SELECT id FROM Site_Segments__r WHERE Is_Featured__c = true AND Segment__c = :segmentId)');
        		
        		siteFieldList.add('(SELECT id, Subscription__c, Subscription__r.Audience__c FROM Subscription_Entity_Site__r WHERE Subscription__r.Action_Type__c = \'mandatory\' AND Status__c =\'Approved\' And Subscription__r.Status__c != \'Deleted\' And (Subscription__r.Audience__r.Segment__c = :segmentId OR Subscription__r.Audience__r.Segment__c = null) Limit 1)');
        	}
		} else {
			siteFieldList.add('(SELECT id, Subscription__c, Subscription__r.Audience__c FROM Subscription_Entity_Site__r WHERE Subscription__r.Action_Type__c = \'mandatory\' AND Status__c =\'Approved\' And Subscription__r.Status__c != \'Deleted\' AND Subscription__r.Audience__r.Segment__c = null Limit 1)');
		}
		
    	return siteFieldList;
    }

    public String convertToSite(String chatterGroupId) {
    	List<Simpplr_Site__c> sitesList = [SELECT Id, Show_In_Simpplr__c From Simpplr_Site__c WHERE Chatter_Group_Id__c = :chatterGroupId AND Is_Deleted__c = false WITH SECURITY_ENFORCED LIMIT 1];
    	if( !sitesList.isEmpty() ) {
    		sitesList[0].Show_In_Simpplr__c = true;
    		sitesList[0].Has_Albums__c = false;
			sitesList[0].Has_Events__c = false;
			sitesList[0].Has_Pages__c = false;
			sitesList[0].Landing_Page__c = 'feed'; 
			sitesList[0].Last_Edited_DateTime__c = DateTime.now();
			List<Schema.SObjectField> modifiledColumns = new List<Schema.SObjectField>();
			modifiledColumns.add(Simpplr_Site__c.Show_In_Simpplr__c); 
			modifiledColumns.add(Simpplr_Site__c.Has_Albums__c);
			modifiledColumns.add(Simpplr_Site__c.Has_Events__c);
			modifiledColumns.add(Simpplr_Site__c.Has_Pages__c);
			modifiledColumns.add(Simpplr_Site__c.Landing_Page__c);
			modifiledColumns.add(Simpplr_Site__c.Last_Edited_DateTime__c);
				
			if(SimpplrContext.isNativeVideo) { 
				sitesList[0].video_provider_sync_status__c = 1;
				modifiledColumns.add(Simpplr_Site__c.video_provider_sync_status__c);
			}
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(sitesList), modifiledColumns);
			
			return sitesList[0].Id;
    	} else {
    		return null;
    	} 
    }
    
    public String revertToChatterGroup(String siteId){
    	List<Simpplr_Site__c> sitesList = [SELECT Id, Chatter_Group_Id__c, Show_In_Simpplr__c 
    			FROM Simpplr_Site__c WHERE Id = :siteId AND Is_Deleted__c = false WITH SECURITY_ENFORCED LIMIT 1];
    	
    	if( !sitesList.isEmpty() ) {
    		
    		sitesList[0].Show_In_Simpplr__c = false;
    		sitesList[0].Has_Albums__c = false;
			sitesList[0].Has_Events__c = false;
			sitesList[0].Has_Pages__c = false;
			sitesList[0].Landing_Page__c = 'feed';
			sitesList[0].Last_Edited_DateTime__c = DateTime.now();
			
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(sitesList),new List<Schema.SObjectField>{ 
																															Simpplr_Site__c.Show_In_Simpplr__c, 
																															Simpplr_Site__c.Has_Albums__c,
																															Simpplr_Site__c.Has_Events__c,
																															Simpplr_Site__c.Has_Pages__c,
																															Simpplr_Site__c.Landing_Page__c,
																															Simpplr_Site__c.Last_Edited_DateTime__c
																														  });
			
			return sitesList[0].Chatter_Group_Id__c;
    	} else {
    		return null;
    	} 
    }
    
    public Subscription_Entity__c approveSubscription(String siteId, String subscriptionId){
    	Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', subscriptionId);
		
		String queryString = 'SELECT Id, Processing_Required__c, Action_By__c, Action_Comment__c, Action_On__c, Status__c, Site__r.Name, Subscription__r.Audience__c'
								+ ' FROM Subscription_Entity__c WHERE Site__c = :soqlParam1 AND Subscription__c = :soqlParam2 LIMIT 1';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Subscription_Entity__c> subscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

    	if(!subscriptionEntityList.isEmpty()) {
    		
    		subscriptionEntityList[0].Processing_Required__c = true;
    		subscriptionEntityList[0].Action_By__c = UserContext.peopleId;
    		subscriptionEntityList[0].Action_On__c = Datetime.now();
    		subscriptionEntityList[0].Status__c = 'Approved';
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Subscription_Entity__c>(subscriptionEntityList),new List<Schema.SObjectField>{ 
																															Subscription_Entity__c.Processing_Required__c, 
																															Subscription_Entity__c.Action_By__c,
																															Subscription_Entity__c.Action_On__c, 
																															Subscription_Entity__c.Status__c																															
																														  });
    		NotificationDispatcher.sendSubscriptionApprovalRejectNotification(siteId, subscriptionEntityList[0].Site__r.Name, subscriptionId, 'approved');
    	} else {
    		throw new SimpplrException(ServiceConstants.ERROR_404); 
    	}
    	
    	return subscriptionEntityList[0];
    } 
    
    public void rejectSubscription(String siteId, String subscriptionId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', subscriptionId);
		
		String queryString = 'SELECT Id, Processing_Required__c, Action_By__c, Action_Comment__c, Action_On__c, Status__c, Site__r.Name'
								+ ' FROM Subscription_Entity__c WHERE Site__c = :soqlParam1 AND Subscription__c = :soqlParam2 LIMIT 1';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Subscription_Entity__c> subscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

    	if(!subscriptionEntityList.isEmpty()) {
    		
    		subscriptionEntityList[0].Processing_Required__c = false;
    		subscriptionEntityList[0].Action_By__c = UserContext.peopleId;
    		subscriptionEntityList[0].Action_On__c = Datetime.now();
    		subscriptionEntityList[0].Status__c = 'Rejected';
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Subscription_Entity__c>(subscriptionEntityList),new List<Schema.SObjectField>{ 
																															Subscription_Entity__c.Processing_Required__c, 
																															Subscription_Entity__c.Action_By__c,
																															Subscription_Entity__c.Action_On__c, 
																															Subscription_Entity__c.Status__c																															
																														  });
    		NotificationDispatcher.sendSubscriptionApprovalRejectNotification(siteId, subscriptionEntityList[0].Site__r.Name, subscriptionId, 'rejected');
    	} else {
    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	}
    }         
    
    public CollaborationGroup getChatterGroupDetails(String chatterGroupId) {
    	List<CollaborationGroup> cgList = [SELECT Id, Name, CollaborationType, MemberCount, IsBroadcast from CollaborationGroup where id = :chatterGroupId WITH SECURITY_ENFORCED];
    	
    	if(cgList.isEmpty()) {
    		throw new SimpplrException(ServiceConstants.SF_EXCEPTION);
    	}
    	return cgList[0];
    }
    
    public List<CollaborationGroup> getChatterGroups(String textSearch, Integer offset, Integer recordLimit,
    						 String sortBy) {
    	Set<String> chatterGroupIdWithoutSiteSet = new Set<String>();					 	
    	List<Simpplr_Site__c> simpplrSiteList = [SELECT Id, Show_in_Simpplr__c, Chatter_Group_Id__c 
    												FROM Simpplr_Site__c 
    												WHERE Show_in_Simpplr__c = false WITH SECURITY_ENFORCED];			
    	for (Simpplr_Site__c site : simpplrSiteList) {
    		chatterGroupIdWithoutSiteSet.add(site.Chatter_Group_Id__c);
    	}		
    												 	
		String queryStr = 'SELECT Id, Name, CollaborationType, MemberCount FROM CollaborationGroup WHERE '+
								' Id IN : chatterGroupIdWithoutSiteSet ';
		
		if(String.isNotBlank(textSearch)) {
			String searchTermConditionStr = getSearchTermCondition(Utility.getSearchTokens(String.escapeSingleQuotes(textSearch)));
			
			queryStr += searchTermConditionStr;
		}
		
		if('alphabetical'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by Name ';
		}else if ('createdNewest'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by createdDate desc';
		}else if('createdOldest'.equalsIgnoreCase(sortBy)){
			queryStr += ' Order by createdDate ';
		}
		queryStr += ' limit ' + recordLimit + ' offset '+offset; //TODO
		logger.logDebug('SiteDao.getChatterGroupDetails() ---- queryStr ----' + queryStr);		
		return Database.query(queryStr);
	}
	
	// All sites where show_in_simpplr__c is true 
    public Map<String,Simpplr_Site__c> getColGrpIdToShowInSimpplrSitesMap (Set<String> colGrpIdSetArg) {
    	Map<String,Simpplr_Site__c> colGrpIdToShowInSimpplrSitesMap = new Map<String,Simpplr_Site__c> ();
    	List<Simpplr_Site__c> siteList = [SELECT Id, name, chatter_Group_id__c FROM Simpplr_Site__c WHERE 
    			Is_Active__c = true AND Show_In_Simpplr__c = true  AND chatter_Group_id__c =: colGrpIdSetArg WITH SECURITY_ENFORCED];
    	
    	for (Simpplr_Site__c site :  siteList) {
    		colGrpIdToShowInSimpplrSitesMap.put(site.chatter_Group_id__c,site);
    	}	
    	return colGrpIdToShowInSimpplrSitesMap;
    }
    
    private List<CollaborationGroupMember> getCollaborationGrpUserInvolved(String userId) {
		List<CollaborationGroupMember> listOfCollborationGrpMember = new List<CollaborationGroupMember>();
		Set<String> colGrpIdSet = new Set<String>();
		String BASE_QUERY = 'SELECT CollaborationRole, CollaborationGroupId, MemberId FROM CollaborationGroupMember'
				+' WHERE MemberId=:userId';
		
		if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+' AND CollaborationGroup.NetworkId = null';
	    }
		listOfCollborationGrpMember = Database.query(BASE_QUERY);
		
		return listOfCollborationGrpMember ; 
    }
    
    // Return list of CollaborationGroupMember for Sites Where Show_in_Simpplr is true
    public List<CollaborationGroupMember> getGrpMembrForSitesShowingInSimpplr (String userId) {
    	List<CollaborationGroupMember> cgmList = getCollaborationGrpUserInvolved(userId);
    	List<CollaborationGroupMember> listOfCollborationGrpMember = new List<CollaborationGroupMember>();
		Set<String> colGrpIdSet = new Set<String>();
		
		for (CollaborationGroupMember cgm : cgmList) {
			colGrpIdSet.add(cgm.CollaborationGroupId);
		}
		Map<String,Simpplr_Site__c> colGrpIdToShowInSimpplrSitesMap = getColGrpIdToShowInSimpplrSitesMap(colGrpIdSet);
		
		for (CollaborationGroupMember cgm : cgmList) {
			
			if (colGrpIdToShowInSimpplrSitesMap.containsKey(cgm.CollaborationGroupId) ) {
				listOfCollborationGrpMember.add(cgm);
			}	
		}
				
		return listOfCollborationGrpMember;
    }

	public void disconnectSlackForSitesConnectedByLoggedInUser(){
		List<Simpplr_Site__c> siteObjList = [SELECT Id, Slack_Access_Token__c, Slack_Channel_Name__c, Slack_Channel_Id__c, Slack_Url__c, Slack_Post_Enabled__c, Slack_Integration_Enabled__c, Slack_Comment_Enabled__c, Slack_Site_Manager__c, External_Apps_Site_Config_Json__c FROM Simpplr_Site__c where Slack_Site_Manager__c=:UserContext.peopleId WITH SECURITY_ENFORCED];
		if(siteObjList.size() > 2000) {
			BatchSlackDisconnectSites batchDisconnectSiteObj = new BatchSlackDisconnectSites();
			Database.executeBatch(batchDisconnectSiteObj,2000);

		} else if(siteObjList.isEmpty()==false) {
			for(Simpplr_Site__c  config : siteObjList) {
				config.Slack_Access_Token__c = null;
				config.Slack_Channel_Name__c = null;
				config.Slack_Channel_Id__c = null;
				config.Slack_Url__c = null;
				config.Slack_Post_Enabled__c = false;
				config.Slack_Integration_Enabled__c = false;
				config.Slack_Comment_Enabled__c = false;
				config.Slack_Site_Manager__c = null;
				if(config.External_Apps_Site_Config_Json__c != null){
					ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
					externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(config.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
					externalAppsSiteConfig.SlackSiteConfig = null;
					config.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
				}
			}
			update siteObjList;
		}
	}

	public Map<Id, Simpplr_Site__c> getSiteDetails(Set<String> siteIdSet){
		Map<Id, Simpplr_Site__c> simpplrSiteMap = new Map<Id, Simpplr_Site__c>([SELECT Id, Name, Title_Content_Version__c FROM Simpplr_Site__c WHERE
														 Is_Active__c = true AND Show_In_Simpplr__c = true AND
														 Id IN :siteIdSet WITH SECURITY_ENFORCED]);

		return simpplrSiteMap;
	} 

    public List<Simpplr_Site__c> getRecentUsedSites(Integer sizeArg, Boolean canSubmitQuestion) {
        Integer recordsToFetch = sizeArg * 40; 

		List<Simpplr_Content__c> listOfSimpplrContent = [SELECT id, title__c, 
                primary_author__c, CreatedById, CreatedDate, Site__c, Site__r.Is_Active__c,
                Site__r.Show_In_Simpplr__c
                FROM simpplr_content__c 
                WHERE createdById=:UserContext.id AND Is_deleted__c = false 
                AND Site__r.Is_Active__c = true AND Site__r.Show_In_Simpplr__c = true 
				WITH SECURITY_ENFORCED
                order by createdDate desc limit :recordsToFetch];
        List<String> listOfSiteId = new List<String>();
        Set<Id> setOfSiteId = new Set<Id>();
        

        if (!listOfSimpplrContent.isEmpty()) {

            for (Simpplr_Content__c contObj: listOfSimpplrContent) {
                Boolean isAdded = setOfSiteId.add(contObj.Site__c);
                
                if (isAdded) {
                    listOfSiteId.add(contObj.Site__c);
                }
                
                if (setOfSiteId.size() == sizeArg) {
                    break;
                }

            }

        }

        String queryStr = SITE_BASE_QUERY + BASE_FROM_WHERE + ' AND id IN:setOfSiteId';
		if(canSubmitQuestion){
			queryStr += ' AND Question_Answer_Enabled__c = true';
		}
		logger.logDebug('SiteDao.getRecentUsedSites() ---- queryStr ----' + queryStr);	
        List<Simpplr_Site__c> listOfSiteResult = new List<Simpplr_Site__c>();
        Map<String, Simpplr_Site__c> mapOfSiteIdWithSiteObj = new Map<String, Simpplr_Site__c>((List<Simpplr_Site__c>)Database.query(queryStr));
       

        for (String siteIdVar: listOfSiteId) {
            if(mapOfSiteIdWithSiteObj.get(siteIdVar) != null){
                listOfSiteResult.add(mapOfSiteIdWithSiteObj.get(siteIdVar));
            } 
        }	

        logger.logDebug('SiteDao.getRecentUsedSites() ---- listOfSiteResult ----' + listOfSiteResult);	
		return listOfSiteResult;
 	} 
 
	 public Boolean approveMembershipRequest(String requestId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', requestId);
		String query = 'SELECT Id, Action_By__c,Site__c, Site__r.Chatter_Group_Id__c, User__c,  Action_DateTime__c, Status__c FROM Site_Membership_Request__c WHERE Id =:soqlParam1 AND Is_Deleted__c = false AND Status__c =\'Pending\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Membership_Request__c> msRequestList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(msRequestList.isEmpty() == false){

			Boolean success = false;
			List<CollaborationGroupMember> collaborationGroupMemberList = new List<CollaborationGroupMember>();
			Map<String, Object> soqlParamMap1 = new  Map<String, Object>();
			soqlParamMap1.put('soqlParam1', msRequestList[0].User__c);
			soqlParamMap1.put('soqlParam2', msRequestList[0].Site__r.Chatter_Group_Id__c);
			query = 'Select Id, MemberId From CollaborationGroupMember Where MemberId = :soqlParam1 And CollaborationGroupId = :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			collaborationGroupMemberList = (List<CollaborationGroupMember>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap1);
			if(collaborationGroupMemberList.isEmpty()) {
				List<String> userIds = new List<String>();
				userIds.add(msRequestList[0].User__c);
				success = addMember(msRequestList[0].site__r.Chatter_Group_Id__c,userIds);
			} else {
				success = true;
			}
			
			if(success) {
				msRequestList[0].Status__c = 'Approved';
				msRequestList[0].Action_By__c = Usercontext.peopleId;
				msRequestList[0].Action_DateTime__c = DateTime.Now();
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(msRequestList[0], new List<Schema.SObjectField>{
					Site_Membership_Request__c.Status__c,
					Site_Membership_Request__c.Action_By__c,
					Site_Membership_Request__c.Action_DateTime__c
				});
				assignSiteRoles(msRequestList[0].site__c, msRequestList[0].User__c, 'member',false,false);
			}

			return true;
		} else {
			return false;
		}
	 }
	 @future
	 public static void approveSiteMembershipRequests(String siteId, Set<Id> listOfAdminUsers){
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		String query = 'SELECT Id, Action_By__c,Site__c, Site__r.Chatter_Group_Id__c, User__c,  Action_DateTime__c, Status__c '+
															' FROM Site_Membership_Request__c '+
															' WHERE Site__c =: soqlParam1 AND Is_Deleted__c = false AND Status__c =\'Pending\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Site_Membership_Request__c> msRequestList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		Set<String> requestByUserIds = new Set<String>();
		Set<String> nonGrpMemberUserIds = new Set<String>();
		Set<String> approvedSiteMembershipRequestIds = new Set<String>();

		if(msRequestList.isEmpty() == false){

			for(Site_Membership_Request__c smRequestObj : msRequestList){
				approvedSiteMembershipRequestIds.add(smRequestObj.id);
				requestByUserIds.add(smRequestObj.User__c);
				nonGrpMemberUserIds.add(smRequestObj.User__c);
				smRequestObj.Status__c = 'Approved';
				smRequestObj.Action_By__c = Usercontext.peopleId;
				smRequestObj.Action_DateTime__c = DateTime.Now();
			}

			List<CollaborationGroupMember> collaborationGroupMemberMap = new List<CollaborationGroupMember>();
			Map<String, Object> soqlParamMap1 = new  Map<String, Object>();
			soqlParamMap1.put('soqlParam1', requestByUserIds);
			soqlParamMap1.put('soqlParam2', msRequestList[0].Site__r.Chatter_Group_Id__c);
			query = 'Select Id, MemberId From CollaborationGroupMember Where MemberId IN :soqlParam1 And CollaborationGroupId = :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<CollaborationGroupMember> collaborationGroupMemberList = (List<CollaborationGroupMember>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap1);

			for(CollaborationGroupMember obj : collaborationGroupMemberList){
				nonGrpMemberUserIds.remove(obj.MemberId);				
			}

			if(!nonGrpMemberUserIds.isEmpty()){
				addMember(msRequestList[0].site__r.Chatter_Group_Id__c,new List<String>(nonGrpMemberUserIds));
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Site_Membership_Request__c>(msRequestList), new List<Schema.SObjectField>{
														Site_Membership_Request__c.Status__c,
														Site_Membership_Request__c.Action_By__c,
														Site_Membership_Request__c.Action_DateTime__c
													});
			assignMemberSiteRolestoAllUsers(msRequestList[0].site__c, requestByUserIds);
			approvePendingAppNotifications(approvedSiteMembershipRequestIds, siteId);			
			List<People__c> listOfSiteAdmins  = [select id from People__c where User__r.isActive = true and user__c =:listOfAdminUsers WITH SECURITY_ENFORCED];
			NotificationDispatcher.sendPublicSiteAutomaticRequestApprovedNotification(siteId, siteId, String.valueOf(msRequestList.size()), listOfSiteAdmins);			
		}
	 }
	 
	public static void approvePendingAppNotifications(Set<String> approvedSiteMembershipRequestIds,String siteId){
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', approvedSiteMembershipRequestIds);
		soqlParamMap.put('soqlParam2', siteId);
		String query = 'SELECT Id from App_Notification__c WHERE Type__c = \'Actionable\' AND Status__c = \'Pending\''+
						' AND Object_Id__c IN: soqlParam1 AND Simpplr_Site__c =: soqlParam2 AND Is_Deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Notification__c> pendingAppNotificationList = (List<App_Notification__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(App_Notification__c notificationObj : pendingAppNotificationList){
			notificationObj.Is_Read__c=true;
			notificationObj.Is_New__c=false;
			notificationObj.Action_By__c=UserContext.peopleId;
			notificationObj.Action_On__c=Datetime.now();				
			notificationObj.Status__c='Approved';
		}
		if(!pendingAppNotificationList.isEmpty()){
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Read__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c,				
				App_Notification__c.Status__c
			};

			NotificationDao.updateNotification(pendingAppNotificationList, listOfColumnsToBeUpdated);
		}
	}
	 
	public static Boolean assignMemberSiteRolestoAllUsers(String siteId, Set<String> userIds) {		
		Set<String> nonSiteRoleUserIds = new Set<String>(userIds);
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', userIds);
		soqlParamMap.put('soqlParam2', siteId);
		String query = 'Select id, Is_Content_Manager__c, Is_Member__c, Is_Manager__c, People__r.User__c'+
											' FROM Site_Role__c '+
											' WHERE People__r.User__c IN: soqlParam1 and Site__c = :soqlParam2 and Is_Deleted__c = false ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Site_Role__c> siteRoleList = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(Site_Role__c siteRoleObj : siteRoleList){
				siteRoleObj.Is_Member__c = true;
				siteRoleObj.Is_Content_Manager__c = false;
				siteRoleObj.Is_Manager__c  = false;
				nonSiteRoleUserIds.remove(siteRoleObj.People__r.User__c);
		}

		if(!siteRoleList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Site_Role__c>(siteRoleList), new List<Schema.SObjectField>{Site_Role__c.Is_Content_Manager__c, Site_Role__c.Is_Member__c});
		} 		
		if(!nonSiteRoleUserIds.isEmpty()){
			List<Site_Role__c> siteRolesList = new List<Site_Role__c>();			

			for(People__c peopleObj : [Select Id, User__c From People__c Where User__c IN: nonSiteRoleUserIds WITH SECURITY_ENFORCED]){
				Site_Role__c siteRoleObj = new Site_Role__c();
				siteRoleObj.Site__c = siteId;
				siteRoleObj.People__c = peopleObj.Id;
				siteRoleObj.User__c = peopleObj.User__c;			
				siteRoleObj.Is_Member__c = true;
				siteRoleObj.Is_Content_Manager__c = false;
				siteRoleObj.Is_Manager__c  = false;
				siteRolesList.add(siteRoleObj);
			}

			if(!siteRolesList.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        		SIMPESAPI.accessController().insertAsUser(siteRolesList,new List<Schema.SObjectField>{
															Site_Role__c.Site__c,
															Site_Role__c.People__c,
															Site_Role__c.User__c,
															Site_Role__c.Is_Member__c,
															Site_Role__c.Is_Content_Manager__c,
															Site_Role__c.Is_Manager__c
														});				
			}
		}

		updateAccessToFiles(siteId, userIds, false, false);

		return true;
	}

	 public Boolean rejectMembershipRequest(String requestId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', requestId);
		String query = 'SELECT Id, Action_By__c, Action_DateTime__c, Status__c FROM Site_Membership_Request__c WHERE Id =:soqlParam1 AND Is_Deleted__c = false AND Status__c =\'Pending\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Membership_Request__c> msRequestList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(msRequestList.isEmpty() == false){
			msRequestList[0].Status__c = 'Rejected';
			msRequestList[0].Action_By__c = Usercontext.peopleId;
			msRequestList[0].Action_DateTime__c = DateTime.Now();
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(msRequestList[0], new List<Schema.SObjectField>{
				Site_Membership_Request__c.Status__c,
				Site_Membership_Request__c.Action_By__c,
				Site_Membership_Request__c.Action_DateTime__c
			});
			return true;
		} else {
			return false;
		}
	}
	public String requestMembership(String siteId){
		Site_Membership_Request__c msRquestRecord = new Site_Membership_Request__c();
		msRquestRecord.Status__c = 'Pending';
		msRquestRecord.Request_By__c = Usercontext.peopleId;
		msRquestRecord.User__c = UserContext.userId;
		msRquestRecord.Site__c = siteId;
		msRquestRecord.Request_DateTime__c = DateTime.Now();
		Database.SaveResult sr = Database.insert(msRquestRecord, false);
		if(sr.isSuccess()){
			return sr.getId();
		} else {
			return null;
		}
	}

	public Boolean isAccessRequested(Simpplr_Site__c siteObj, CollaborationGroup collabGroup){
		Boolean isAccessRequested = false;
		if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteObj.Site_Type__c)){
			if(siteObj.Site_Membership_Request__r.isEmpty() == false){
				isAccessRequested = true;
			} 
		} else if(ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteObj.Site_Type__c)){
			if(!collabGroup.GroupMemberRequests.isEmpty()) {
				isAccessRequested = true;			
			} 
		}
		return isAccessRequested;
    }
    
    public List<Simpplr_Site__c> getSitesByIds (List<String> listOfSiteId) {
        String queryStr = 'SELECT chatter_group_id__c, id, name, ' + 
				' Title_Content_Version__c, Title_Content_Document__c, Site_Type__c, Is_Active__c, Is_Featured__c,' +
				' Landing_Page__c, Site_Category__r.Name__c, Site_Category__c ' 
				+ BASE_FROM_WHERE + ' AND Id IN:listOfSiteId';
        logger.logDebug(queryStr);
        List<Simpplr_Site__c> listOfSite = new List<Simpplr_Site__c>();
        listOfSite = Database.query(queryStr);
        return listOfSite;
    } 


	public Boolean makeSiteMember(Simpplr_Site__c siteObj){
						
		String currentUser = UserInfo.getUserId();
		Boolean success = false;
		List<CollaborationGroupMember> collaborationGroupMemberList = new List<CollaborationGroupMember>();
		collaborationGroupMemberList = [Select Id, MemberId From CollaborationGroupMember Where MemberId = :currentUser And CollaborationGroupId = :siteObj.Chatter_Group_Id__c];
		if(collaborationGroupMemberList.isEmpty()) {
			List<String> userIds = new List<String>();
			userIds.add(currentUser);
			success = addMember(siteObj.Chatter_Group_Id__c,userIds);
		} else {
			success = true;
		}
		
		if(success) {
			assignSiteRoles(siteObj.Id, currentUser, 'member',false,false);
			return true;
		}			
	
		return false;
	}

    /**
     * @description sitesIFollowIdSet is used to get sites followed by specifc user
     * @return Set<Id> of sites i follow
	 * @param userId of string type of people for which we want to fetch sites i follow id set
     */
	public set<Id> sitesIFollowIdSet(String userId){
		String baseQuery = 'select Id, Name, MemberCount, OwnerId, CollaborationType,SmallPhotoUrl, FullPhotoUrl, Description, HasPrivateFieldsAccess,'+
							'(select CollaborationRole from GroupMembers where MemberId=:userId)';
		String whereCondition = ' From CollaborationGroup where id in (select CollaborationGroupId from CollaborationGroupMember where MemberId=:userId)';
		if(SimpplrContext.isCommunitiesEnabled){
			whereCondition = whereCondition+' AND NetworkId = null';
		}
		String query = baseQuery+whereCondition;
		Map<Id,CollaborationGroup> chatterGroupsIFollowMap = new Map<Id, CollaborationGroup>((List<CollaborationGroup>)Database.query(query));

		Map<Id,Simpplr_Site__c> sitesIFollowMap = New Map<Id,Simpplr_Site__c>([Select Id,Is_Newsletter_Allowed__c,Is_Alert_Enabled__c, Chatter_Group_Id__c, File_Storage_Source__c, Site_Type__c, OwnerId from Simpplr_Site__c where Is_Active__c=true and Is_Deleted__c = false and chatter_Group_Id__c in :chatterGroupsIFollowMap.keyset() WITH SECURITY_ENFORCED]);
		return sitesIFollowMap.keyset();
	}

    /**
     * @description topicsIFollowIdSet is used to get topics followed by specifc user
     * @return Set<Id> of topics i follow
	 * @param userId of string type of people for which we want to fetch topics i follow id set
     */
	 public set<Id> topicsIFollowIdSet(String userId){
		//Limit 1000 is imposed by Salesforce for non-admin users
		String baseQuery = 'Select Id, ParentId From EntitySubscription '+
					   'where parent.type=\'Topic\' and  isDeleted=false '+
					   'And SubscriberId=:userId';
		
		if(SimpplrContext.isCommunitiesEnabled){
			baseQuery+=' And NetworkId = null';
		}
		String subCondition = ' Limit 1000';
		String query = baseQuery+subCondition;
		
		List<EntitySubscription> listOfES= new List<EntitySubscription>();
		listOfES = Database.query(query);
		Map<Id, EntitySubscription> topicsIFollowAndEntitySubscriptionIdMap = new Map<Id, EntitySubscription>();
		for(EntitySubscription es:listOfES) {
			topicsIFollowAndEntitySubscriptionIdMap.put(es.parentId, es);
		}
		return topicsIFollowAndEntitySubscriptionIdMap.keyset();
	}

    /**
     * @description existing site names
     * @param originalSiteName - containing site iname of original site
     * @return duplicate site name
     */
	public String getDuplicateSiteName(String originalSiteName){
		String suffixStr = ' Copy';
		//2 digits reserved for numbering and 6 digits for suffix 40-8 = 32
		Integer charLimitSiteName = 40; 
		Integer charLimitSuffix = 8; 

		String originalSiteNameTruncated = originalSiteName.left(charLimitSiteName - charLimitSuffix).trim();
		String duplicateSiteName = originalSiteNameTruncated + suffixStr;
		String searchExp = duplicateSiteName + '%';

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', searchExp);
		String queryStr = 'SELECT Id, Name FROM Simpplr_site__c WHERE Name LIKE :soqlParam1 ORDER BY Name DESC';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Simpplr_Site__c> existingSiteList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap);

		logger.logDebug('SiteDao.getDuplicateSiteName --existingDuplicateSiteList-- ' + existingSiteList);

		// Site names with copy already exists
		if(existingSiteList != null && !existingSiteList.isEmpty()){
			String regex = originalSiteNameTruncated + '('+suffixStr+' [0-9]+)$';
			Pattern p = Pattern.compile(regex);

			if(checkIfDuplicateSiteExists(existingSiteList, duplicateSiteName)){
				List<String> matchedSiteNames = getMatchedSiteNames(existingSiteList, p);
				suffixStr = getDuplicateSiteSuffix(matchedSiteNames, suffixStr);
			}
		}

		//Ensure site name is less than 40 characters
		duplicateSiteName = originalSiteName.left(charLimitSiteName - charLimitSuffix).trim() + suffixStr;

		logger.logDebug('SiteDao.getDuplicateSiteName --duplicateSiteName-- ' + duplicateSiteName);
		duplicateSiteName = duplicateSiteName.left(charLimitSiteName);

		return duplicateSiteName;
	}

    /**
     * @description checking existing site names
     * @param existingSiteList - containing simpplr site Object, Pattern
     * @param p - pattern
     * @return list of matched site namess
     */
	public List<String> getMatchedSiteNames(List<Simpplr_Site__c> existingSiteList, Pattern p){
		List<String> matchedSiteNames = new List<String>();
		for(Simpplr_Site__c site : existingSiteList){
			Matcher m = p.matcher(site.Name);
			while(m.find()) {
				matchedSiteNames.add(m.group());
				break;
			}
		}
		//sort the site names asc
		matchedSiteNames.sort();
		logger.logDebug('SiteDao.getMatchedSiteNames --matchedSiteNames-- ' + matchedSiteNames);
		return matchedSiteNames;
	}

    /**
     * @description createSimpplrSites : create site from collaboration group
     * @param matchedSiteNames
     * @param suffixStr
     * @return string duplicate site
     */
	public String getDuplicateSiteSuffix(List<String> matchedSiteNames, String suffixStr){
		if(matchedSiteNames != null && !matchedSiteNames.isEmpty()){
			Pattern p = Pattern.compile('([0-9]+)$');
			List<Integer> listKeys = new List<Integer>();
			for(String siteName: matchedSiteNames){
				Matcher m = p.matcher(siteName);
				while(m.find()) {
					listKeys.add(Integer.valueOf(m.group()));
					break;
				}
			}
			//sort asc order
			listKeys.sort();
			suffixStr = ' Copy ' + String.valueOf(listKeys[listKeys.size() - 1] + 1);
		}else{
			//only one version of Copy exists and so append 2 to get duplicate site name
			suffixStr = ' Copy 2';
		}
		logger.logDebug('SiteDao.getDuplicateSiteSuffix --suffixStr-- ' + suffixStr);
		return suffixStr;
	}

    /**
     * @description return true/false check if site name already exists
     * @param existingSiteList - list of existing sites matching the name
     * @param duplicateSiteName - duplicate site name
     * @return boolean duplicate or not
     */
	public Boolean checkIfDuplicateSiteExists(List<Simpplr_Site__c> existingSiteList, String duplicateSiteName){
		Boolean isDuplicateNameExists = false;
		for(Simpplr_Site__c site : existingSiteList){
			if(site.Name.equalsIgnoreCase(duplicateSiteName)){
				isDuplicateNameExists = true;
				break;
			}
		}
		logger.logDebug('SiteDao.checkIfDuplicateSiteExists --isDuplicateNameExists-- ' + isDuplicateNameExists);
		return isDuplicateNameExists;
	}

    /**
     * @description create content version and content document for site cover image
     * @param originalSiteObj - containing simpplr site Object
     * @param duplicateSiteObj - containing simpplr site Object
     * @return simpplr duplicate site with site cover
     */
    public Simpplr_Site__c duplicateSiteCover(Simpplr_Site__c originalSiteObj, Simpplr_Site__c duplicateSiteObj){
    	Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', originalSiteObj.Cover_Content_Version__c);
		String queryStr = 'SELECT Id, Title, VersionData, PathOnClient, ContentSize, Origin FROM ContentVersion WHERE Id=:soqlParam1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<ContentVersion> listCVs = (List<ContentVersion>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap);

		logger.logDebug('SiteDao.duplicateSiteCover --listCVs-- ' + listCVs);

		ContentVersion duplicateCVObj = new ContentVersion();
		try{
			if(listCVs != null && !listCVs.isEmpty()){
				ContentVersion orignalCV = listCVs[0];
				if(orignalCV != null && orignalCV.ContentSize != null){
					Double siteCoverSizeInMb = orignalCV.ContentSize * 1.0 / (1024 * 1024);
					logger.logDebug('SiteDao.duplicateSiteCover --siteCoverSizeInMb-- ' + siteCoverSizeInMb);
					//If the compressed file size is more than 2.0 MB, dont copy size cover image
					//This gives us compress size image and putting restriction to avoid heap limit error
					// VersionData is mandatory field for content version
					if(siteCoverSizeInMb < 2.0 && orignalCV.VersionData != null){
						duplicateCVObj.Title = orignalCV.Title;
						duplicateCVObj.VersionData = orignalCV.VersionData;
						duplicateCVObj.PathOnClient = orignalCV.PathOnClient;
						duplicateCVObj.Origin = orignalCV.Origin;

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						duplicateCVObj = (ContentVersion) SIMPESAPI.accessController().insertAsUser(duplicateCVObj, new List<Schema.SObjectField>{
							ContentVersion.Title,
							ContentVersion.VersionData,
							ContentVersion.PathOnClient,
							ContentVersion.Origin
						});	

						logger.logDebug('SiteDao.duplicateSiteCover --duplicateCVObj-- ' + duplicateCVObj);

						soqlParamMap = new Map<String, Object>();
						soqlParamMap.put('soqlParam1', duplicateCVObj.Id);
						queryStr = 'SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id=:soqlParam1';

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<ContentVersion> listNewCVs = (List<ContentVersion>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap);

						logger.logDebug('SiteDao.duplicateSiteCover --listNewCVs-- ' + listNewCVs);

						if(listNewCVs != null && !listNewCVs.isEmpty()){
							duplicateSiteObj.Cover_Content_Version__c = listNewCVs[0].Id;
							duplicateSiteObj.Cover_Content_Document__c = listNewCVs[0].ContentDocumentId;
						}
					} //END-siteCoverSizeInMb
				} // END - orignalCV
			}
		}catch(Exception exp){
			logger.logError(exp);
		}
		return duplicateSiteObj;
	}

	/**
     * @description method is used to get count of membership requests for a site
	 * @param String id of the site
	 * @param String search term
     * @return membership request count
     */
	
	public Integer getSiteMembershipRequestsCount(String siteId, String term) {
		Integer requestsCount = 0;

		Simpplr_Site__c simpplrSiteObj = [Select id, Chatter_Group_Id__c, Is_Deleted__c, Site_Type__c from Simpplr_Site__c where Is_Deleted__c=false and id =: siteId WITH SECURITY_ENFORCED];
		String cGroupId = simpplrSiteObj.Chatter_Group_Id__c;

		if (simpplrSiteObj.Site_Type__c == 'Private' ){
			
			String query =  ' SELECT COUNT(Id) requestsCount FROM CollaborationGroupMemberRequest '
							+ ' WHERE CollaborationGroupId = :cGroupId '
							+ ' AND Status = \'Pending\'';
			
			if(String.isNotBlank(term)) {
				setOfSearchTokens = Utility.getSearchTokens(String.escapeSingleQuotes(term));
				for(String searchToken : setOfSearchTokens) {
					query += ' ANd Requester.Name like \'%'+searchToken+'%\' ';
				}
			}

			String packageName = SimpplrContext.packageName;
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
				query += ' And RequesterId in (SELECT UserId FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =:packageName) ';
			}

			List<AggregateResult> aggResRequestsList = Database.query(query);

			requestsCount = !aggResRequestsList.isEmpty() ? (Integer) aggResRequestsList[0].get('requestsCount') : 0;

		} else if(simpplrSiteObj.Site_Type__c == 'Public' ){
			
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId);
			
			String query =  ' SELECT COUNT(Id) requestsCount FROM Site_Membership_Request__c '
							+ ' WHERE Site__c =:soqlParam1 AND Is_Deleted__c = false '
							+ ' AND Status__c = \'Pending\'';
			
			if(String.isNotBlank(term)) {
				setOfSearchTokens = Utility.getSearchTokens(String.escapeSingleQuotes(term));
				for(String searchToken : setOfSearchTokens) {
					query += ' AND Request_By__r.Full_Name__c like \'%'+searchToken+'%\' ';
				}
			}
			
			String packageName = SimpplrContext.packageName;
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
				soqlParamMap.put('soqlParam2', packageName);
				query += ' And User__c IN (SELECT UserId FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =:soqlParam2) ';
			}

			List<AggregateResult> aggResRequestsList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

			requestsCount = !aggResRequestsList.isEmpty() ? (Integer) aggResRequestsList[0].get('requestsCount') : 0;
		}
		
		return requestsCount;
	}

	/**
     * @description method is used to get count of managers for a site
	 * @param String id of the site
	 * @param String search term
     * @return managersCount
     */
	public Integer getSiteManagerCount(String siteId, String term) {
		String query =  ' SELECT COUNT(Id) managerCount FROM Site_Role__c WHERE '
						+ ' Is_Deleted__c=false AND Site__c = :siteId AND  '
						+ ' (User__r.Show_Simpplr__c = \'Yes\' OR '+
						+ ' (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true)) AND '
						+ ' (Is_Manager__c = true OR Is_Content_Manager__c = true)';
		
		if(String.isNotBlank(term)) {
			setOfSearchTokens = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken : setOfSearchTokens) {
				query += ' AND People__r.Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}

		String packageName = SimpplrContext.packageName;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			query += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}

		List<AggregateResult> aggResManagersList = Database.query(query);

		Integer managerCount = !aggResManagersList.isEmpty() ? (Integer) aggResManagersList[0].get('managerCount') : 0;

		return managerCount;
	}

	/**
     * @description method is used to get count of members for a site
	 * @param String id of the site
	 * @param String search term
     * @return membersCount
     */
	public Integer getSiteMemberCount(String siteId, String term) {
		String query =  ' SELECT COUNT(Id) memberCount FROM Site_Role__c WHERE '
						+ ' Is_Deleted__c=false AND Site__c = :siteId AND  '
						+ ' (User__r.Show_Simpplr__c = \'Yes\' OR '+
						+ ' (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true)) AND'
						+ ' Is_Member__c = true';
				
		if(String.isNotBlank(term)) {
			setOfSearchTokens = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken : setOfSearchTokens) {
				query += ' AND People__r.Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		
		String packageName = SimpplrContext.packageName;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			query += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}

		List<AggregateResult> aggResMembersList = Database.query(query);

		Integer memberCount = !aggResMembersList.isEmpty() ? (Integer) aggResMembersList[0].get('memberCount') : 0;

		return memberCount;
	}

	/**
     * @description method is used to get count of followers for a site
	 * @param String id of the site
	 * @param String search term
     * @return followersCount
     */
	public Integer getSiteFollowerCount(String siteId, String term) {
		String query =  ' SELECT COUNT(Id) followerCount FROM Site_Role__c WHERE '
						+ ' Is_Deleted__c=false AND Site__c = :siteId AND  '
						+ ' (User__r.Show_Simpplr__c = \'Yes\' OR '+
						+ ' (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true)) AND'
						+ ' Is_Member__c = false AND Is_Manager__c = false AND Is_Content_Manager__c = false';
				
		if(String.isNotBlank(term)) {
			setOfSearchTokens = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken : setOfSearchTokens) {
				query += ' AND People__r.Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		
		String packageName = SimpplrContext.packageName;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			query += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}

		List<AggregateResult> aggResFollowerssList = Database.query(query);

		Integer followerCount = !aggResFollowerssList.isEmpty() ? (Integer) aggResFollowerssList[0].get('followerCount') : 0;

		return followerCount;
	}

	/**
     * @description method is used to get List of managers for a site
	 * @param String id of the Site
     * @return List of Managers
     */
	public List<SiteDetailWrapper.ManagerWrapper> getSiteManagerList(String siteId) {
		List<SiteDetailWrapper.ManagerWrapper> managersList= new List<SiteDetailWrapper.ManagerWrapper>();

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);

		String queryStr =  ' SELECT Id, People__c FROM Site_Role__c WHERE '
						+ ' Is_Deleted__c=false AND Site__c = :soqlParam1 AND  '
						+ ' (User__r.Show_Simpplr__c = \'Yes\' OR '+
						+ ' (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true)) AND'
						+ ' (Is_Manager__c = true OR Is_Content_Manager__c = true)  ';

		String packageName = SimpplrContext.packageName;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			soqlParamMap.put('soqlParam2', packageName);
			queryStr += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:soqlParam2) ';
		}
		
		queryStr += 'LIMIT 16';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Role__c> listOfSiteRoles = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

		List<String> peopleIds = new List<String>();
		for(Site_Role__c roleObj : listOfSiteRoles) {
			peopleIds.add(roleObj.People__c);
		}

		if(!peopleIds.isEmpty()) {
			managersList = getSitePeopleWrapperList(peopleIds);
		}

		return managersList;
	}

	/**
	 * @description method is used to get List of mandatory subscriptions for a site
	 * @param String id of the Site
     * @return List of subscription entities
	 */
	public List<Subscription_Entity__c> getSiteMandatorySubscription(String siteId){
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.segmentId);
			soqlParamMap.put('soqlParam2', siteId);
			String query = 'SELECT Id, Subscription__r.Audience__c from Subscription_Entity__c ' + 
							'WHERE Subscription__r.Action_Type__c = \'mandatory\' ' + 
							'AND Status__c = \'Approved\' AND Subscription__r.Status__c != \'Deleted\' And ' +
							'(Subscription__r.Audience__r.Segment__c =: soqlParam1 OR ' +
							'Subscription__r.Audience__r.Segment__c = null) AND Site__c =: soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			return ((List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap));
	}

	/**
     * @description method is used to get List of members for a site
	 * @param String id of the Site
     * @return List of Members
     */
	public List<SiteDetailWrapper.ManagerWrapper> getSiteMemberList(String siteId) {
		List<SiteDetailWrapper.ManagerWrapper> membersList= new List<SiteDetailWrapper.ManagerWrapper>();

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);

		String queryStr =  ' SELECT Id, People__c FROM Site_Role__c WHERE '
						+ ' Is_Deleted__c=false AND Site__c = :soqlParam1 AND  '
						+ ' (User__r.Show_Simpplr__c = \'Yes\' OR '+
						+ ' (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true)) AND'
						+ ' Is_Manager__c = false AND Is_Content_Manager__c = false AND Is_Member__c = true ';

		String packageName = SimpplrContext.packageName;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			soqlParamMap.put('soqlParam2', packageName);
			queryStr += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:soqlParam2) ';
		}

		queryStr += 'LIMIT 16';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Role__c> listOfSiteRoles = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

		List<String> peopleIds = new List<String>();
		for(Site_Role__c roleObj : listOfSiteRoles) {
			peopleIds.add(roleObj.People__c);
		}

		if(!peopleIds.isEmpty()) {
			membersList = getSitePeopleWrapperList(peopleIds);
		}

		return membersList;
	}

	/**
     * @description method is used to get List of followers for a site
	 * @param String id of the Site
     * @return List of Followers
     */
	public List<SiteDetailWrapper.ManagerWrapper> getSiteFollowerList(String siteId) {
		List<SiteDetailWrapper.ManagerWrapper> followersList= new List<SiteDetailWrapper.ManagerWrapper>();

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);

		String queryStr =  ' SELECT Id, People__c FROM Site_Role__c WHERE '
						+ ' Is_Deleted__c=false AND Site__c = :soqlParam1 AND  '
						+ ' (User__r.Show_Simpplr__c = \'Yes\' OR '+
						+ ' (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true)) AND'
						+ ' Is_Manager__c = false AND Is_Content_Manager__c = false AND Is_Member__c = false ';

		String packageName = SimpplrContext.packageName;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			soqlParamMap.put('soqlParam2', packageName);
			queryStr += ' And User__c in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:soqlParam2) ';
		}

		queryStr += 'LIMIT 16';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Role__c> listOfSiteRoles = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

		List<String> peopleIds = new List<String>();
		for(Site_Role__c roleObj : listOfSiteRoles) {
			peopleIds.add(roleObj.People__c);
		}

		if(!peopleIds.isEmpty()) {
			followersList = getSitePeopleWrapperList(peopleIds);
		}

		return followersList;
	}

	/**
     * @description method is used to get owner for a site
	 * @param String id of the Owner
	 * @param List of managers
     * @return Owner of the site
     */
	public SiteDetailWrapper.ManagerWrapper getSiteOwner(String ownerId) {
		List<String> siteOwnerPeopleIds = new List<String>();
		List<SiteDetailWrapper.ManagerWrapper> ownerList= new List<SiteDetailWrapper.ManagerWrapper>();

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', ownerId);
        String queryStr = ' SELECT Id FROM People__c WHERE User__c =: soqlParam1 ' 
						+ ' And (User__r.Show_Simpplr__c = \'Yes\' OR '+
						+ ' (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true)) ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
        
		if(!peopleList.isEmpty()) {
            siteOwnerPeopleIds.add(peopleList[0].Id);
        }

		SiteDetailWrapper.ManagerWrapper siteOwner;

		if(!siteOwnerPeopleIds.isEmpty()) {
			siteOwner = new SiteDetailWrapper.ManagerWrapper();
			ownerList = getSitePeopleWrapperList(siteOwnerPeopleIds);
			if(!ownerList.isEmpty()) {
				siteOwner = ownerList[0];
			}
		}

		return siteOwner;
	}

	/**
     * @description method is used to get people(managers/members/followers) for a site
	 * @param List<String> id of the site people
     * @return List of site people wrapper
     */
	@TestVisible 
	private List<SiteDetailWrapper.ManagerWrapper> getSitePeopleWrapperList(List<String> peopleIds) {
		List<SiteDetailWrapper.ManagerWrapper> sitePeopleList= new List<SiteDetailWrapper.ManagerWrapper>();

		String loggedInPeopleId = UserContext.peopleId;

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', loggedInPeopleId);
		soqlParamMap.put('soqlParam2', peopleIds);

		String queryStr = 'select id, User__r.UserType, User__r.Show_Simpplr__c, Is_Deleted__c, user__c, Title__c, About__c, Department__c, Full_Name__c, City__c, State__c, Country__c, Street__c, ' +
										' First_Name__c, Last_Name__c, Mobile_Phone__c, Extension__c, Phone__c, Email__c,Joining_Date__c, user__r.FullPhotoURL,  User__r.MediumPhotoUrl, User__r.SmallPhotoUrl, User__r.isActive, ' +
										' Zoom_Id__c, Skype_Id__c, Cover_Content_Document_Id__c, Segment__c, ' +
	        							' (SELECT People__c, Bookmark_Receiver__c FROM Bookmark_Receiver_People__r WHERE People__c=:soqlParam1 AND Type__c=\'People\' And Is_Deleted__c=false ) '+
	        							' FROM People__c Where Id IN :soqlParam2';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

		for(People__c peopleObj : peopleList) {
			SiteDetailWrapper.ManagerWrapper wrapperObj = convertToSiteMemberWrapper(peopleObj);
			sitePeopleList.add(wrapperObj);
		}

		return sitePeopleList;
	}

	/**
     * @description method is used to people object to wrapper
	 * @param People__c People Object
     * @return wrapper object for people
     */
	@TestVisible 
	private SiteDetailWrapper.ManagerWrapper convertToSiteMemberWrapper(People__c peopleObj) {
		SiteDetailWrapper.ManagerWrapper memberWrapObj = new SiteDetailWrapper.ManagerWrapper();
		memberWrapObj.peopleId = peopleObj.id;
		memberWrapObj.sfUserId = peopleObj.User__c;
		memberWrapObj.firstName = peopleObj.First_Name__c;
		memberWrapObj.lastName = peopleObj.Last_Name__c;
		memberWrapObj.name = peopleObj.Full_Name__c;
		memberWrapObj.profileImg = Utility.getUserProfileImgUrl(peopleObj.user__r.MediumPhotoURL, peopleObj.user__r.FullPhotoURL);
		memberWrapObj.title = peopleObj.Title__c;
		memberWrapObj.department = peopleObj.Department__c;
		memberWrapObj.email = peopleObj.Email__c;
		memberWrapObj.address = Utility.buildLocation(peopleObj.City__c, peopleObj.State__c,  peopleObj.Country__c);
		memberWrapObj.phone = peopleObj.Phone__c;
		memberWrapObj.mobilePhone = peopleObj.Mobile_Phone__c;
		memberWrapObj.extension = peopleObj.Extension__c;
		memberWrapObj.street = peopleObj.Street__c;
		memberWrapObj.city = peopleObj.City__c;
		memberWrapObj.state = peopleObj.State__c;
		memberWrapObj.country = peopleObj.Country__c;
		memberWrapObj.isActive = peopleObj.User__r.isActive;
		
		return memberWrapObj;
	}

	public static Map<Id, Id> getSiteIdChatterGroupIdMapBySiteIds(Set<Id> siteIdSet){
		Map<Id, Id> siteIdChatterGroupIdMap = new Map<Id, Id> ();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteIdSet);
		String query = 'SELECT Id, Chatter_Group_Id__c ' +
			' FROM Simpplr_Site__c '+
			' WHERE id IN: soqlParam1 ';
       
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		for(Simpplr_Site__c siteRecord : (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap)){
			siteIdChatterGroupIdMap.put(siteRecord.id, siteRecord.Chatter_Group_Id__c);
		}
		return siteIdChatterGroupIdMap;

	}
	public List<CollaborationGroupMember> getCollaborationRoleUsingUserId(String collaborationGroupId, String userId) {
		List<CollaborationGroupMember> groupMemberRecords = [SELECT CollaborationRole from CollaborationGroupMember WHERE CollaborationGroupId =:collaborationGroupId AND MemberId =:userId];
		return groupMemberRecords;
    }

}