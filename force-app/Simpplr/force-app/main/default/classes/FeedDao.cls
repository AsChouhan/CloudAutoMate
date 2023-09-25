public with sharing class FeedDao {
    

    // Method to getTimeline feed
    public List<Simpplr_Content__Feed> getTimeLineFeed(Integer recordLimit, Integer offset,
            String filterArg,  String subjectIdArg) {
        recordLimit ++;
        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
        String currentUserId = UserContext.id;
        List<Simpplr_Content__Feed> listOfSimpContentFeed = new List<Simpplr_Content__Feed>();
        // Timeline feed for news 
        if (filterArg.equalsIgnoreCase('news')) {
            listOfSimpContentFeed = [SELECT id, parentId, type, createdDate
                    FROM simpplr_content__feed 
                    WHERE type= 'LinkPost' AND (parent.site__r.Chatter_Group_Id__c 
                    IN:chatterGroupsIFollowIdSet OR parent.primary_author__r.user__C 
                    IN: usersIFollowIdSet OR parent.primary_author__r.user__C = :currentUserId) AND parent.is_deleted__c = false 
                    AND parent.Is_Published__c = true WITH SECURITY_ENFORCED
                    order by createdDate DESC 
                    limit :recordLimit  offset :offset];

        //Timeline feed for site
        } else if (filterArg.equalsIgnoreCase('record') && subjectIdArg.startsWith('0F9')) {
            listOfSimpContentFeed = [SELECT id, parentId, type, createdDate
                    FROM simpplr_content__feed 
                    WHERE type= 'LinkPost' 
                    AND parent.site__r.Chatter_Group_Id__c =:subjectIdArg 
                    AND parent.is_deleted__c = false 
                    AND parent.Is_Published__c = true WITH SECURITY_ENFORCED
                    order by createdDate DESC 
                    limit :recordLimit  offset :offset];

        //Timeline feed for content detail page 
        } else if (filterArg.equalsIgnoreCase('record') && 
                subjectIdArg.startsWith(Utility.getSimpplrContentPrefix())) {
            // No timeline data for content record page 

        //Topic feed 
        } else if (filterArg.equalsIgnoreCase('record') && 
                subjectIdArg.startsWith(Utility.getTopicPrefix())) {
            // No timeline data for topic feed

        //Timeline feed for all Company 
        } else {
            listOfSimpContentFeed = [SELECT id, parentId, type, createdDate  
                    FROM simpplr_content__feed 
                    WHERE type= 'LinkPost' AND parent.is_deleted__c = false 
                    AND parent.Is_Published__c = true WITH SECURITY_ENFORCED
                    order by createdDate DESC 
                    limit :recordLimit  offset :offset];
        }

        return listOfSimpContentFeed;
    }

    //Method to get timeline and comment feed 
    public List<Object> getTimeLineAndContentFeed(Integer recordLimit, 
                Integer offset, String filterArg, String sortByArg, String subjectIdArg) {
        List<Object> listOfFeedInObjectContainer = new List<Object>();
        List<Simpplr_Content__Feed> listOfSimpContentFeed = new List<Simpplr_Content__Feed>();
        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;

        // Timeline and comment feed for IFollow 
        if (filterArg.equalsIgnoreCase('news')) {
            
            //According to recent activity 
            if (sortByArg == 'activity') {
                listOfSimpContentFeed = [SELECT id, parentId, type  
                    FROM simpplr_content__feed 
                    WHERE (parent.site__r.Chatter_Group_Id__c 
                    IN:chatterGroupsIFollowIdSet OR parent.primary_author__r.user__C 
                    IN: usersIFollowIdSet) AND parent.is_deleted__c = false WITH SECURITY_ENFORCED
                    ORDER BY lastModifiedDate DESC
                    limit :recordLimit  offset :offset];
            
            //According to created date 
            } else {
                 listOfSimpContentFeed = [SELECT id, parentId, type  
                    FROM simpplr_content__feed 
                    WHERE parent.site__r.Chatter_Group_Id__c 
                    IN:chatterGroupsIFollowIdSet AND parent.is_deleted__c = false WITH SECURITY_ENFORCED
                    ORDER BY createdDate DESC
                    limit :recordLimit  offset :offset];
            } 

        // Site feed for Timeline and comment 
        } else if (filterArg.equalsIgnoreCase('record') && 
                subjectIdArg.startsWith('0F9')) {
            
            //According to recent activity 
            if (sortByArg == 'activity') {
                listOfSimpContentFeed = [SELECT id, parentId, type  
                    FROM simpplr_content__feed 
                    WHERE parent.site__r.Chatter_Group_Id__c =:subjectIdArg  
                    AND parent.is_deleted__c = false WITH SECURITY_ENFORCED
                    ORDER BY lastModifiedDate DESC
                    limit :recordLimit  offset :offset];
            
            //According to created Date 
            } else {
                 listOfSimpContentFeed = [SELECT id, parentId, type  
                    FROM simpplr_content__feed 
                    WHERE parent.site__r.Chatter_Group_Id__c =:subjectIdArg 
                    AND parent.is_deleted__c = false WITH SECURITY_ENFORCED
                    ORDER BY createdDate DESC
                    limit :recordLimit  offset :offset];
            } 
        
        // Content detail timeline and comment feed
        } else if (filterArg.equalsIgnoreCase('record') && 
                subjectIdArg.startsWith(Utility.getSimpplrContentPrefix())) {

            // Accroding to recent activity         
            if (sortByArg == 'activity') {
                listOfSimpContentFeed = [SELECT id, parentId, type  
                    FROM simpplr_content__feed 
                    WHERE parentId =:subjectIdArg  
                    AND parent.is_deleted__c = false 
                    AND type != 'LinkPost' WITH SECURITY_ENFORCED
                    ORDER BY lastModifiedDate DESC
                    limit :recordLimit  offset :offset];
            
            //According to created date 
            } else {
                 listOfSimpContentFeed = [SELECT id, parentId, type  
                    FROM simpplr_content__feed 
                    WHERE parentId =:subjectIdArg 
                    AND parent.is_deleted__c = false  
                    AND type != 'LinkPost' WITH SECURITY_ENFORCED
                    ORDER BY createdDate DESC
                    limit :recordLimit  offset :offset];
            } 
        

        // For topic feed  
        } else if (filterArg.equalsIgnoreCase('record') && 
                subjectIdArg.startsWith(Utility.getTopicPrefix())) {
            String contentApiName = Utility.getSimpplrContentApiName();
            List<FeedItem> listOfFeedItem = [SELECT id, parentId, type,parent.type 
                FROM Feeditem 
                WHERE parent.type = :contentApiName
                And id in (SELECT EntityId FROM TopicAssignment 
                WHERE TopicId =:subjectIdArg AND entitytype='FeedItem')
                ORDER BY lastModifiedDate DESC
                limit :recordLimit  offset :offset] ;
            
            listOfFeedInObjectContainer = listOfFeedItem;
            return listOfFeedInObjectContainer;

        // Timeline and comment fro ALL COMPANY 
        } else {

            //According to recent activity 
            if (sortByArg == 'activity') {
                listOfSimpContentFeed = [SELECT id, parentId, type   
                        FROM simpplr_content__feed 
                        WHERE parent.is_deleted__c = false WITH SECURITY_ENFORCED
                        ORDER BY lastModifiedDate DESC
                        limit :recordLimit  offset :offset];
            
            // According to created date 
            } else {
                listOfSimpContentFeed = [SELECT id, parentId, type   
                        FROM simpplr_content__feed 
                        WHERE  parent.is_deleted__c = false WITH SECURITY_ENFORCED
                        ORDER BY createdDate DESC
                        limit :recordLimit  offset :offset];
            }

        }

        listOfFeedInObjectContainer = listOfSimpContentFeed;
        return listOfFeedInObjectContainer;  
    }

    public List<FeedItem> getUnlistedSiteTimelineContentAndFeedPosts(Integer recordLimit, Integer offset, String sortByArg, String subjectIdArg) {
        List<FeedItem> listOfFeedItems = new List<FeedItem>();
        Map<Id, Simpplr_Content__c> contentMap = getSimpplrContentMapByChatterId(subjectIdArg);
        List<Id> feedItemsParentIds = new List<Id>(contentMap.keySet());
        feedItemsParentIds.add(subjectIdArg);

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', feedItemsParentIds); 
        soqlParamMap.put('soqlParam2', recordLimit); 
        soqlParamMap.put('soqlParam3', offset); 
        String trackedQueryCondition = SimpplrContext.showTrackChangesFeedPosts == true ? '' : ' AND Type != \'TrackedChange\' ';
        if (sortByArg == 'activity') {
            String feedItemQuery = 'SELECT id, parentId, type FROM FeedItem WHERE ParentId = :soqlParam1 ' + trackedQueryCondition + ' WITH SECURITY_ENFORCED'+
                ' ORDER BY lastModifiedDate DESC limit :soqlParam2 offset :soqlParam3';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            listOfFeedItems = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);

        } else {
            String feedItemQuery = 'SELECT id, parentId, type FROM FeedItem WHERE ParentId = :soqlParam1 ' + trackedQueryCondition + ' WITH SECURITY_ENFORCED'+
                ' ORDER BY createdDate DESC limit :soqlParam2 offset :soqlParam3';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            listOfFeedItems = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
        } 

        return listOfFeedItems;  
    }

    public List<Simpplr_Content__Feed> searchTimeLineFeed(Integer recordLimit, Integer offset, String filterArg, String sortByArg, String searchString) {
        recordLimit ++;
        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        List<Simpplr_Content__Feed> listOfSimpContentFeed = new List<Simpplr_Content__Feed>();
        List<Id> contentIds = new List<Id>();
        Boolean includeAllContents = false;
        
        // Search timeline for news 
        if (filterArg.equalsIgnoreCase('news')) {
            if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
                contentIds = getContentListFromAWS(searchString, chatterGroupsIFollowIdSet,includeAllContents);
            }
            else {
                String queryString = 'SELECT Id, Site__r.Chatter_Group_Id__c, Title__c FROM Simpplr_Content__c ' +
                                     ' WHERE Site__r.Chatter_Group_Id__c IN: chatterGroupsIFollowIdSet AND Title__c Like :searchString';
                                                            
                List<Simpplr_Content__c> listOfContent = Database.query(queryString);

                for(Simpplr_Content__c contentObj : listOfContent) {
                    contentIds.add(contentObj.Id);
                }
            }
        }
        else { // Search timeline for all company 
            if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
                includeAllContents = true;
                contentIds = getContentListFromAWS(searchString, chatterGroupsIFollowIdSet, includeAllContents);
            }
            else {
                String queryString = 'SELECT Id, Site__r.Chatter_Group_Id__c, Title__c FROM Simpplr_Content__c ' +
                                     ' WHERE Title__c like :searchString';

                List<Simpplr_Content__c> listOfContent = Database.query(queryString);
                
                for(Simpplr_Content__c contentObj : listOfContent) {
                    contentIds.add(contentObj.Id);
                }
            }
        }

        listOfSimpContentFeed = [SELECT Id, ParentId, Type, Body  
                                    FROM Simpplr_Content__feed 
                                    WHERE Type= 'LinkPost' AND ParentId IN :contentIds 
                                    AND Parent.Is_Published__c = true WITH SECURITY_ENFORCED
                                    LIMIT :recordLimit  OFFSET :offset];

        return listOfSimpContentFeed;
    }
    
    private List<String> getcontentListFromAWS(String queryString, Set<Id> chatterGroupsIFollowIdSet, Boolean includeAllContents) {
        String SearchForType='Content';
        List<String> contentIds = new List<String>();

        Criteria.ExternalSearchReq contentCriteria = new Criteria.ExternalSearchReq();

        contentCriteria.status= 'Published';
        contentCriteria.term = queryString;
        contentCriteria.includeAllContents = includeAllContents;
        contentCriteria.targetGroupIds = chatterGroupsIFollowIdSet;
        contentCriteria.listOfAllowedFeatures = (SimpplrContext.AllowedFeatures).split(',');
        ExternalSearchService externalSearchServiceObj=new ExternalSearchService();
        ExternalSearchWrapper.TopContentsWrapper returnWrapperObj=externalSearchServiceObj.searchContents(contentCriteria, SearchForType);
        
        if(returnWrapperObj.listOfItems != null && returnWrapperObj.listOfItems.size() > 0) {
            contentIds = getContentIdsFromAWSResponse(returnWrapperObj.listOfItems, contentCriteria);
        }

        return contentIds;
    }

    private List<String> getContentIdsFromAWSResponse(List<ExternalSearchWrapper.ItemWrapper> listOfItems, Criteria.ExternalSearchReq contentCriteria) {
		List<String> contentIds = new List<String>();

		for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems) {
			Object item = itemWrapperObj.item;
			ContentWrapper clWrapper = (ContentWrapper)item;

			contentIds.add(clWrapper.id);
		}
		return contentIds;
	}

    private Map<Id, Simpplr_Content__c> getSimpplrContentMapByChatterId(String chatterGroupId) {
        Map<Id, Simpplr_Content__c> contentMap = new Map<Id, Simpplr_Content__c>([SELECT Id FROM Simpplr_Content__c
            WHERE Site__r.Chatter_Group_Id__c = :chatterGroupId AND Is_Deleted__c = false WITH SECURITY_ENFORCED]);
        return contentMap;
    }
}