public with sharing class ExternalSearchResultToWrapper {

    public PeopleWrapper.peopleStatsWrapper extPeopleStatToWrapper (String peopleStatJson) {
        PeopleWrapper.peopleStatsWrapper peopleStatsObj = new PeopleWrapper.peopleStatsWrapper();
        ExternalSearchWrapper.PeopleStatResponse peopleStatExtRespObj = (ExternalSearchWrapper.PeopleStatResponse)JSON.deserialize(peopleStatJson, 
                ExternalSearchWrapper.PeopleStatResponse.class);

        Integer peopleIdsList = getInactiveUserCount(peopleStatExtRespObj.member_people_id_list);
        peopleStatsObj.memberCount = peopleStatExtRespObj.member_count - peopleIdsList;
        peopleStatsObj.requestCount = peopleStatExtRespObj.membership_request_count;
        peopleStatsObj.followerCount = 0;
        return peopleStatsObj;
    }

    private Integer getInactiveUserCount(List<String> peopleIds) {
        PeopleDao peopleDaoObj = new PeopleDao();
        return peopleDaoObj.getInactiveUserCount(peopleIds);
    }

    public List<PeopleListWrapper> extSiteMembersToPeopleListWrap(ExternalSearchWrapper.AIResponse responseWrapES) {
        List<PeopleListWrapper> listOfPeopleWrap = new List<PeopleListWrapper>();

        Boolean isCurrentUserSiteOwner = false;
        List<Simpplr_Site__c> siteObj;
        Set<String> mandatorySiteSubscriptionPeopleIdSet = null;
        String ownerId;
        if(responseWrapES.hits.hit != null && responseWrapES.hits.hit.size() > 0 && (responseWrapES.hits.hit[0]).current_site_role.site_id!=null){
            Map<String, Object> soqlParamMap = new  Map<String, Object>();
            soqlParamMap.put('soqlParam1', (responseWrapES.hits.hit[0]).current_site_role.site_id);
            String query = 'Select Id, Site_Type__c,  chatter_Group_id__c From Simpplr_Site__c Where Id = :soqlParam1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            siteObj = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
            soqlParamMap.put('soqlParam2',siteObj[0].chatter_Group_id__c );
            String cgQuery = 'SELECT Id, CollaborationType, OwnerId, Owner.name FROM CollaborationGroup Where Id= :soqlParam2';
            List<CollaborationGroup> collabGroupObj = (List<CollaborationGroup>)SIMPESAPI.accessController().queryAsUSer(cgQuery,soqlParamMap);
            ownerId = collabGroupObj[0].OwnerId;
            if(UserInfo.getUserId().equalsIgnoreCase(collabGroupObj[0].OwnerId)){
                isCurrentUserSiteOwner = true;
            }
            Set<Id> siteSearchMembersPeopleIdSet = new Set<Id>();
            for(ExternalSearchWrapper.SearchDataWrapper extPepObj : responseWrapES.hits.hit) {
                siteSearchMembersPeopleIdSet.add(extPepObj.id);
            }
            String siteId = siteObj[0].id;
            PeopleDao peopleDaoObj = new PeopleDao();
            List<Subscription_Entity__c> siteSubscriptionEntityList = peopleDaoObj.getSubscriptionEntity(siteId);

            Set<String> audienceIdSet = new Set<String>();
            for(Subscription_Entity__c susbcriptionEntity : siteSubscriptionEntityList){
                if(String.isNotBlank(susbcriptionEntity.Subscription__c)){
                    audienceIdSet.add(susbcriptionEntity.Subscription__r.Audience__c);
                }
            }
            
            if(!audienceIdSet.isEmpty()){
                mandatorySiteSubscriptionPeopleIdSet = new Set<String>();
                List<Audience_Member__c> audienceMemberList = peopleDaoObj.getAudienceMembers(siteSearchMembersPeopleIdSet, audienceIdSet);											 
                for(Audience_Member__c audienceMember : audienceMemberList){
                    mandatorySiteSubscriptionPeopleIdSet.add(audienceMember.People__c);
                }												 
            }
        }

        for (ExternalSearchWrapper.SearchDataWrapper extPeopleObj : responseWrapES.hits.hit) {
            PeopleListWrapper peopleWrapObj = new PeopleListWrapper();
            peopleWrapObj.id = extPeopleObj.id;
            peopleWrapObj.peopleId = extPeopleObj.id;
            peopleWrapObj.name = extPeopleObj.name; 
            peopleWrapObj.mobile = extPeopleObj.mobile_phone;
            peopleWrapObj.state = extPeopleObj.state;
            peopleWrapObj.sfUserId = extPeopleObj.user;
            peopleWrapObj.nickname =  extPeopleObj.community_nickname;
            peopleWrapObj.location =  Utility.buildLocation(extPeopleObj.city, 
                    extPeopleObj.state, extPeopleObj.country);
            peopleWrapObj.isMember =  extPeopleObj.current_site_role.is_member;
            peopleWrapObj.isOwner =  extPeopleObj.current_site_role.is_owner;
            peopleWrapObj.isManager =  extPeopleObj.current_site_role.is_manager;
            peopleWrapObj.isActive =  extPeopleObj.is_active;
            peopleWrapObj.isContentManager =  extPeopleObj.current_site_role.is_content_manager;
            peopleWrapObj.img =  extPeopleObj.img;

            peopleWrapObj.isFollower = (peopleWrapObj.isMember != null && peopleWrapObj.isMember == false && 
                                        peopleWrapObj.isOwner != null && peopleWrapObj.isOwner == false && 
                                        peopleWrapObj.isManager != null && peopleWrapObj.isManager == false && 
                                        peopleWrapObj.isContentManager !=null && peopleWrapObj.isContentManager == false) ? true : false ;
            peopleWrapObj.canRemove = true;
            peopleWrapObj.canMakeOwner = true; 
            peopleWrapObj.canMakeManager = true;
            peopleWrapObj.canMakeContentManager = true;
            peopleWrapObj.canMakeNotManager = false;
            peopleWrapObj.canMakeNotContentManager = false;

            if(ownerId!=null){
                if(extPeopleObj.user == ownerId){
                    peopleWrapObj.isOwner = true;
                }
                else{
                    peopleWrapObj.isOwner = false;
                }
            }
            if(peopleWrapObj.isOwner != null && peopleWrapObj.isOwner) {
                peopleWrapObj.canRemove = false;
                peopleWrapObj.canMakeManager = false;
                peopleWrapObj.canMakeContentManager = false;
                peopleWrapObj.canMakeNotManager = false;
                peopleWrapObj.canMakeNotContentManager = false;
                peopleWrapObj.isMember = true;
                peopleWrapObj.isManager = false;
            } else if(peopleWrapObj.isManager != null && peopleWrapObj.isManager) {
                peopleWrapObj.canMakeManager = false;
                peopleWrapObj.canMakeContentManager = true;
                peopleWrapObj.canMakeNotManager = true;
                peopleWrapObj.canMakeNotContentManager = false;
                peopleWrapObj.isMember = true;
            } else if(peopleWrapObj.isContentManager !=null && peopleWrapObj.isContentManager) {
                peopleWrapObj.canMakeManager = true;
                peopleWrapObj.canMakeContentManager = false;
                peopleWrapObj.canMakeNotManager = false;
                peopleWrapObj.canMakeNotContentManager = true;
                peopleWrapObj.isMember = true;
            }

            
            if(mandatorySiteSubscriptionPeopleIdSet != null && !mandatorySiteSubscriptionPeopleIdSet.isEmpty() && mandatorySiteSubscriptionPeopleIdSet.contains(extPeopleObj.Id)){
                // Check if users other than managers/owner not in the subscriptions then provide an option to remove them.
                peopleWrapObj.canRemove = false;
            }

            if(((UserContext.hasModifyAllDataPermission && siteObj!=null && !'Unlisted'.equalsIgnoreCase(siteObj[0].Site_Type__c) 
						|| (siteObj!=null && 'Unlisted'.equalsIgnoreCase(siteObj[0].Site_Type__c) && UserContext.hasManageUnlistedSitePermission)
						|| isCurrentUserSiteOwner || (UserContext.isUserAppModerator && siteObj!=null &&  'Public'.equalsIgnoreCase(siteObj[0].Site_Type__c))) && peopleWrapObj.isOwner == false)){
			    peopleWrapObj.canMakeOwner = true;
            } else {
                peopleWrapObj.canMakeOwner = false;
            }

            listOfPeopleWrap.add(peopleWrapObj);
        }

        return listOfPeopleWrap; 

    }

    public List<PeopleListWrapper> extSiteMemberRequestToPeopleListWrap(ExternalSearchWrapper.AIResponse responseWrapES) {
        List<PeopleListWrapper> listOfPeopleWrap = new List<PeopleListWrapper>();

        for (ExternalSearchWrapper.SearchDataWrapper extPeopleObj : responseWrapES.hits.hit) {
            PeopleListWrapper peopleWrapObj = new PeopleListWrapper();
            peopleWrapObj.user = new PeopleListWrapper();
            peopleWrapObj.user.id = extPeopleObj.id;
            peopleWrapObj.user.peopleId = extPeopleObj.id;
            peopleWrapObj.user.name = extPeopleObj.name; 
            peopleWrapObj.user.mobile = extPeopleObj.mobile_phone;
            peopleWrapObj.user.state = extPeopleObj.state;
            peopleWrapObj.user.sfUserId = extPeopleObj.user;
            peopleWrapObj.user.nickname =  extPeopleObj.community_nickname;
            peopleWrapObj.user.location =  Utility.buildLocation(extPeopleObj.city, 
                    extPeopleObj.state, extPeopleObj.country);
            peopleWrapObj.user.isActive =  extPeopleObj.is_active;
            peopleWrapObj.user.img =  extPeopleObj.img;
            PeopleListWrapper.Request requestObj = new PeopleListWrapper.Request();
             
            if(extPeopleObj.current_site_membership_request.collaboration_group_member_request_id != null) {
                requestObj.id = extPeopleObj.current_site_membership_request.collaboration_group_member_request_id;
            } else {
                requestObj.id = extPeopleObj.current_site_membership_request.Id;
            }
            
            requestObj.requestedBy = extPeopleObj.current_site_membership_request.request_by_name;
            requestObj.requestedByPeopleId = extPeopleObj.current_site_membership_request.request_by;
            
            if (extPeopleObj.current_site_membership_request.Request_DateTime != null) {
                requestObj.requestedOn = DateTime.ValueofGMT(extPeopleObj.current_site_membership_request.Request_DateTime.replace('T', ' ')).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            }

            requestObj.status = String.isNotBlank(extPeopleObj.current_site_membership_request.Status) ? (extPeopleObj.current_site_membership_request.Status).toLowerCase():null;
            
            if (extPeopleObj.current_site_membership_request.Action_DateTime != null) {
                requestObj.actionOn = DateTime.ValueofGMT(extPeopleObj.current_site_membership_request.Action_DateTime.replace('T', ' ')).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            }

            requestObj.actionBy = extPeopleObj.current_site_membership_request.Action_By_Name;
            requestObj.actionByPeopleId = extPeopleObj.current_site_membership_request.Action_By;
            peopleWrapObj.request = requestObj;
            listOfPeopleWrap.add(peopleWrapObj);

        }

        return listOfPeopleWrap; 

    }

    public List<PeopleListWrapper> extSearchResponseToPeopleListWrap(ExternalSearchWrapper.AIResponse responseWrapES, String filter) {
        List<PeopleListWrapper> listOfPeopleWrap = new List<PeopleListWrapper>();
				
        for (ExternalSearchWrapper.SearchDataWrapper extPeopleObj : responseWrapES.hits.hit) {
            
            PeopleListWrapper peopleWrapObj = new PeopleListWrapper();
            peopleWrapObj.id = extPeopleObj.id;
            peopleWrapObj.peopleId = extPeopleObj.id;
            peopleWrapObj.sfUserId = extPeopleObj.user;
            peopleWrapObj.nickname =  extPeopleObj.community_nickname;
            peopleWrapObj.name = extPeopleObj.name; 
            peopleWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + extPeopleObj.id;
            peopleWrapObj.mobile = extPeopleObj.mobile_phone;
            peopleWrapObj.state = extPeopleObj.state;
            peopleWrapObj.sfUserId = extPeopleObj.user;
            peopleWrapObj.nickname =  extPeopleObj.community_nickname;
            peopleWrapObj.location =  Utility.buildLocation(extPeopleObj.city, 
                    extPeopleObj.state, extPeopleObj.country);
            peopleWrapObj.isActive =  extPeopleObj.is_active;
            peopleWrapObj.img =  extPeopleObj.img;
            peopleWrapObj.hasRead = 'read'.equalsIgnoreCase(filter) ? true : false;
            
            listOfPeopleWrap.add(peopleWrapObj);
        }

		return listOfPeopleWrap;
	}
}