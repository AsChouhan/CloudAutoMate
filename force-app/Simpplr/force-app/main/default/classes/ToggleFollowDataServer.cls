public with sharing class ToggleFollowDataServer extends DataServer {
	public transient final String STR_ERROR_SITE_LIMIT_ERROR { get { return labelMap.get('manage_sites.site_limit_reached_error_flash');}}
	public transient final String STR_ERROR_TOPIC_FEED_TRACKING_DISABLED { get { return labelMap.get('feed.create.tracking_disabled_error_flash');}}
	public transient final String STR_ERROR_SITE_PER_USER_SUBSCRIPTION_EXCEEDED { get { return labelMap.get('common.follow_limit_reached_error_flash');}}
	private final String SITE_PER_USER_LIMIT_EXCEEDED_ERRMSG = 'You\'ve reached your Site limit. It\'s not possible to manage or follow more Sites';
	private final String SITE_USER_ALREADY_MEMBER_ERRMSG = 'You are already following this Site';
	private final String TOPIC_FEED_TRACKING_DISABLED = 'Its not possible to perform this action - Feed tracking is disabled';
	private final String SITE_PER_USER_SUBSCRIPTION_EXCEEDED_ERRMSG = 'Unable to perform action - follow limit reached';
	
	public ToggleFollowDataServer () {
		
	}
	//Dont remove this method as ToggleFollowDataServer.page referencing this method existing on server.
	public PageReference init () {
		return null;
	}
	
	public override void handleRequest () {
		response = new ResponseWrapper();
		String userId = readSafeParam('sfUserId');
		String action = readSafeParam('action');
		String siteId = readSafeParam('siteId');
		String data = readParam('data');
		
		try {
			if (String.isNotBlank(action) && action.equalsIgnoreCase('followSite') && 
					String.isNotBlank(siteId)) {
				Boolean isSuccess;
				isSuccess = followSite(siteId);
				
				if (isSuccess) {
					response = FeedUtility.buildResponseWrapper('success', null, isSuccess);
				
				} else {
					response = FeedUtility.buildResponseWrapper('failure', null, isSuccess);
				}
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('unfollowSite') &&
					String.isNotBlank(siteId)) {
				Boolean isSuccess = unfollowSite(siteId);
				 
				if (isSuccess) {
					response = FeedUtility.buildResponseWrapper('success', null, isSuccess);
				} else {
					response = FeedUtility.buildResponseWrapper('failure', null, isSuccess);
				}
				
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('followUser')) {
                
                if (data == null || String.isBlank(data)) {
		            throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		        }
		         
		        Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
                String sfUserId = String.valueOf(requestData.get('sfUserId'));
                Boolean isSuccess = false; 

                if (String.isNotBlank(sfUserId)) {
                    isSuccess = followUser(sfUserId);
                }

				if (isSuccess) {
                    response = FeedUtility.buildResponseWrapper('success', null, isSuccess);
                    
				} else {
					response = FeedUtility.buildResponseWrapper('failure', null, isSuccess);
				}
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('unFollowUser')) {
                
                if (data == null || String.isBlank(data)) {
		            throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		        }
		         
		        Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
                String sfUserId = String.valueOf(requestData.get('sfUserId'));
                Boolean isSuccess = false; 

                if (String.isNotBlank(sfUserId)) {
                    isSuccess = unFollowUser(sfUserId);
                }
				
				if (isSuccess) {
                    response = FeedUtility.buildResponseWrapper('success', null, isSuccess);
                    
				} else {
					response = FeedUtility.buildResponseWrapper('failure', null, isSuccess);
				}
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('followTopic')) {
				if(data == null || String.isBlank(data)){
		            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		        }
		         
		        Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
		        String topicId = String.valueOf(requestData.get('topicId'));
				
				Boolean isSuccess = false;
				if(String.isNotBlank(topicId)) {
					isSuccess = followTopic(topicId);
				}
				if (isSuccess) {
					response = FeedUtility.buildResponseWrapper('success', null, isSuccess);
				} else {
					response = FeedUtility.buildResponseWrapper('failure', null, isSuccess);
				}
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('unFollowTopic')) {
				if(data == null || String.isBlank(data)){
		            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		        }
		         
		        Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
		        String topicId = String.valueOf(requestData.get('topicId'));
		        
		        Boolean isSuccess = false;
		        if(String.isNotBlank(topicId)) {
		        	isSuccess = unFollowTopic(topicId);
		        }
				
				if (isSuccess) {
					response = FeedUtility.buildResponseWrapper('success', null, isSuccess);
				} else {
					response = FeedUtility.buildResponseWrapper('failure', null, isSuccess);
				}
			
			} 
			
		} catch(Exception e){
			MessageHelper.addErrorMessage(e.getMessage());
			
			if (e.getMessage().containsIgnoreCase('Maximum per user active group limit reached')) {
        		response = FeedUtility.buildResponseWrapper('error', STR_ERROR_SITE_LIMIT_ERROR, null);
        	
        		
        	} else if (e.getMessage().containsIgnoreCase('User is already a Member of this group')) {
        		response = FeedUtility.buildResponseWrapper(RESPONSE_STATUS_SUCCESS, SITE_USER_ALREADY_MEMBER_ERRMSG, null);
        	
        	} else if(e.getMessage().containsIgnoreCase('Topics do not have feeds enabled')){
        		response = FeedUtility.buildResponseWrapper('error', STR_ERROR_TOPIC_FEED_TRACKING_DISABLED, null);
        	} else if (e.getMessage().containsIgnoreCase('Maximum per user subscription limit reached')) {
        		response = FeedUtility.buildResponseWrapper('error', STR_ERROR_SITE_PER_USER_SUBSCRIPTION_EXCEEDED, null);
			} else {
				response = FeedUtility.buildResponseWrapper('error', e.getMessage(), false);
        	}
        	
		}
	}
	
	
	public Boolean followUser(String toBeFollowed) {
		List<EntitySubscription> alreadyfollowing = [SELECT Id FROM  EntitySubscription WHERE ParentId=:tobeFollowed AND SubscriberId=:UserContext.id WITH SECURITY_ENFORCED LIMIT 1];
		if(alreadyfollowing.isEmpty()){
			EntitySubscription entitySubcrptionObj = new EntitySubscription(ParentId = tobeFollowed, SubscriberId = UserContext.id);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(entitySubcrptionObj,
					new List<Schema.SObjectField>{EntitySubscription.ParentId,
												EntitySubscription.SubscriberId});
			List<Messaging.SingleEmailMessage> emailObjList = new List<Messaging.SingleEmailMessage>();
			try{									  
				NotificationDispatcher.sendNotificationForFollow(toBeFollowed);
				if (SimpplrContext.enableEmail && !toBeFollowed.equalsIgnoreCase(UserContext.id)){
					NotificationDispatcher.sendEmailForFollow(toBeFollowed);
				}
			} catch (Exception e){
			}
		}
		return true;
	}
	
	@testVisible 
	private Boolean unfollowUser(String userId) {
		List<EntitySubscription> listOfEntitySubscription = [select ParentId, SubscriberId from EntitySubscription where SubscriberId =: UserContext.id and ParentId=:userId WITH SECURITY_ENFORCED Limit 1];
		
		if (!listOfEntitySubscription.isEmpty()) {	
			EntitySubscription es = listOfEntitySubscription[0];
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().deleteAsUser(es);
		}
		return true;
				
	}
	
	public Boolean followSite (String siteIdArg) {
        String chatterGroupId;
        list<Simpplr_Site__c> listOfSimpplrSite;

		if (siteIdArg.startsWith('0F9')) {
            chatterGroupId = siteIdArg;			
            listOfSimpplrSite =  [SELECT Id, Chatter_Group_Id__c, Site_Type__c,  
                    File_Storage_Source__c
                    FROM Simpplr_Site__c 
                    WHERE Chatter_Group_Id__c=:siteIdArg WITH SECURITY_ENFORCED];
		} else {
            listOfSimpplrSite =  [SELECT Id, Chatter_Group_Id__c, Site_Type__c,  
                    File_Storage_Source__c
                    FROM Simpplr_Site__c 
                    WHERE Id=:siteIdArg WITH SECURITY_ENFORCED];

			if (!listOfSimpplrSite.isEmpty()) {
				chatterGroupId = listOfSimpplrSite[0].Chatter_Group_Id__c;
            }
            
        }

        if (!listOfSimpplrSite.isEmpty() && listOfSimpplrSite[0].File_Storage_Source__c == 'googledrive' && SimpplrContext.googleManagedPermission != true) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.id);
			soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
            String queryStr = 'SELECT id, user_email__c,  user__c'+
                    ' FROM People_Integration__c '+
                    ' WHERE user__c =:soqlParam1 AND '+
                    ' name=:soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
            if (!listOfPeopleInteg.isEmpty()) {
                String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
                String groupKey = chatterGroupId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                String memberKey = listOfPeopleInteg[0].user_email__c;
                String response = new GoogleDriveService().addMemberToGroup(groupKey, memberKey);
            }

        }
        
		if(String.isNotBlank(chatterGroupId)) {	
			CollaborationGroupMember  collGrpMemObj = new CollaborationGroupMember(
				CollaborationGroupId = chatterGroupId, MemberId = UserContext.id);
				
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   		SIMPESAPI.accessController().insertAsUser(collGrpMemObj,
	   			new List<Schema.SObjectField>{CollaborationGroupMember.CollaborationGroupId,
	   			CollaborationGroupMember.MemberId});
	   			
	   		return true;
	   			
		} else {
			return false;
		}
															           
	}
	
	@testVisible 
	private Boolean unFollowSite (String siteIdArg) {
        list<Simpplr_Site__c> listOfSimpplrSite = new list<Simpplr_Site__c>();
        
		if (siteIdArg.startsWith('0F9')) {
			listOfSimpplrSite =  [SELECT Id, Chatter_Group_Id__c ,Site_Type__c,  
                    File_Storage_Source__c
                    FROM Simpplr_Site__c 
                    WHERE Chatter_Group_Id__c=:siteIdArg WITH SECURITY_ENFORCED];
		} else {
			listOfSimpplrSite =  [SELECT Id, Chatter_Group_Id__c ,Site_Type__c,  
                File_Storage_Source__c
                FROM Simpplr_Site__c 
                WHERE Id=:siteIdArg WITH SECURITY_ENFORCED];
        }

		if (!listOfSimpplrSite.isEmpty()) {	
            String currentUserId = UserContext.id; 
			String groupId = listOfSimpplrSite[0].Chatter_Group_Id__c;

            if (listOfSimpplrSite[0].File_Storage_Source__c == 'googledrive' && SimpplrContext.googleManagedPermission != true) {
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', currentUserId);
				soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                String queryStr = 'SELECT id, user_email__c,  '+
                        ' user__c'+
                        ' FROM People_Integration__c '+
                        ' WHERE user__c =:soqlParam1 AND '+
                        ' name=:soqlParam2';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
                if (!listOfPeopleInteg.isEmpty()) {
                    String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
                    String groupKey = groupId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                    String memberKey = listOfPeopleInteg[0].user_email__c;
                    String response = new GoogleDriveService().removeMemberFromGroup(groupKey, memberKey);
                }

            }
			
			String BASE_QUERY= 'Select Id'+
					', (Select Id, MemberId FROM GroupMembers WHERE MemberId = :currentUserId) ';
			String BASE_FROM_WHERE = 'From CollaborationGroup where Id = :groupId ';
			
			if (SimpplrContext.isCommunitiesEnabled) {
				BASE_FROM_WHERE = BASE_FROM_WHERE+'AND NetworkId = null';
			}
			
			String queryStr=BASE_QUERY+BASE_FROM_WHERE;	
			List<CollaborationGroup> listOfCollabGroup = new List<CollaborationGroup>();
			listOfCollabGroup = Database.query(queryStr);
					
			if (!listOfCollabGroup.isEmpty()  && !listOfCollabGroup[0].GroupMembers.isEmpty()) {
				String subscriptionId = listOfCollabGroup[0].GroupMembers[0].Id;
				CollaborationGroupMember collGrpMemObj = new CollaborationGroupMember(id = subscriptionId);
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().deleteAsUser(collGrpMemObj);
				return true;
				
			} else {
				return false;
			}
	   			
		} else {
			return false;
		}
				
	}
	
	@testVisible
	//feed tracking should be enabled throw exception if not. 
	private Boolean followTopic(String topicId) {
		EntitySubscription entitySubcrptionObj = new EntitySubscription(ParentId = topicId, SubscriberId = UserContext.id);
			
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   	SIMPESAPI.accessController().insertAsUser(entitySubcrptionObj,
				new List<Schema.SObjectField>{EntitySubscription.ParentId,
		   										  EntitySubscription.SubscriberId});
	   
	   	return true;		
	}
	
	@testVisible 
	//feed tracking should be enabled throw exception if not.
	private Boolean unfollowTopic(String topicId) {
		List<EntitySubscription> listOfEntitySubscription = [select ParentId, SubscriberId from EntitySubscription where SubscriberId =: UserContext.id and ParentId=:topicId WITH SECURITY_ENFORCED Limit 1];
		if (!listOfEntitySubscription.isEmpty()) {	
			EntitySubscription es = listOfEntitySubscription[0];
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().deleteAsUser(es);
			return true;
		} else {
			return false;
		}
	}
	
}