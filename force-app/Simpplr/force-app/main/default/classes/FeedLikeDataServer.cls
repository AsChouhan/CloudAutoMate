public with sharing class FeedLikeDataServer extends DataServer {

	
	public override void handleRequest () {
		try {
			String nextPageToken = readParam('nextPageToken');
			String feedElementId = readParam('postId');
			String feedCommentId = readParam('commentId');
			String pageSize = readParam('size');
			
			if(feedElementId != null || feedCommentId != null) {
				ConnectApi.ChatterLikePage likePageObj;
				if (nextPageToken == null || nextPageToken.length() == 0 || nextPageToken == 'null') {
					nextPageToken = '0';
				}
				if (feedCommentId != null) {
					likePageObj = FeedConnectAPIService.getLikesForComment(null,
							feedCommentId , Integer.valueOf(nextPageToken), Integer.valueOf(pageSize));
				
				} else {
					likePageObj = FeedConnectAPIService.getLikesForFeedElement(null,
							feedElementId , Integer.valueOf(nextPageToken), Integer.valueOf(pageSize));
				}	
				String currentUserId = userInfo.getUserId();
				String loggedInPeopleId = UserContext.peopleId;
				map<ID, LikersWrapper>mapUserIDLikeWrap = new map<ID, LikersWrapper>();
				Boolean isPPDepartmentDisplay = SimpplrContext.isPPDepartmentDisplay;
				Boolean isPPTitleDisplay = SimpplrContext.isPPTitleDisplay;
				Boolean isPPMobilePhoneDisplay =SimpplrContext.isPPMobilePhoneDisplay;
				Boolean isPPPhoneDisplay = SimpplrContext.isPPPhoneDisplay;
				Boolean isPPExtensionDisplay = SimpplrContext.isPPExtensionDisplay;
				LikersWrapper likeWrapObj;
				List<LikersWrapper> listOfLikersTemp =  new List<LikersWrapper>();
				String departmentStr;
				Set<ID>usersIFollowIdSet = UserContext.usersIFollowIdSet;

				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					for(ConnectApi.ChatterLike likeObj: likePageObj.items){
						FeedDataAdapter.getUserIdsToConvert(likeObj);
					}
					FeedDataAdapter.getPeopleFromUserIds();
				}
				for (ConnectApi.ChatterLike likeObj: likePageObj.items) {
					likeWrapObj = new LikersWrapper();
					likeWrapObj = FeedDataAdapter.generateLikeUserWrapObj(likeObj, 1);
					listOfLikersTemp.add(likeWrapObj);
					mapUserIDLikeWrap.put(likeWrapObj.userId, likeWrapObj);
				}
				
				List<People__c>  listOfPeople = [SELECT User__c, City__c, State__c,
						Country__c, Title__c, Department__c,Email__c,Mobile_Phone__c,Phone__c,Extension__c,User__r.isactive,(select id from Bookmark_Receiver_People__r where People__c=:loggedInPeopleId AND Type__c='People' And Is_Deleted__c=false)  FROM People__c WHERE User__c In: mapUserIDLikeWrap.keySet() WITH SECURITY_ENFORCED];			
				
				if (!listOfPeople.isEmpty()) {
					
					for (People__c peopleObj : listOfPeople) {
						
						likeWrapObj = new LikersWrapper();
						likeWrapObj = mapUserIDLikeWrap.get(peopleObj.User__c);
						likeWrapObj.location = utility.buildLocation(peopleObj.City__c,peopleObj.State__c, peopleObj.Country__c) ; 
									
						likeWrapObj.canFollow = true;
						likeWrapObj.peopleId = peopleObj.Id;
						likeWrapObj.id = likeWrapObj.userId;
						
						if (likeWrapObj.userId == currentUserId) {
							likeWrapObj.canFollow = false;
						}
						departmentStr = '';
						if (peopleObj.Title__c != null && isPPTitleDisplay == true) {
							departmentStr = peopleObj.Title__c ;
						}
						if (peopleObj.Department__c != null && isPPDepartmentDisplay == true) {
							likeWrapObj.department = String.isNotBlank(departmentStr)?departmentStr+ ' - ' + peopleObj.Department__c : peopleObj.Department__c;
						}
				    	
				    	likeWrapObj.isFavorited = !peopleObj.Bookmark_Receiver_People__r.isEmpty() ? true : false;
						likeWrapObj.email = peopleObj.Email__c;
						likeWrapObj.mobile = isPPMobilePhoneDisplay == false ? null:peopleObj.Mobile_Phone__c;
						likeWrapObj.phone = isPPPhoneDisplay == false ? null:peopleObj.Phone__c;
						likeWrapObj.phoneExtension = isPPExtensionDisplay == false ? null:peopleObj.Extension__c;
						likeWrapObj.isActive = peopleObj.User__r.isactive;
				    	likeWrapObj.isFollowing = usersIFollowIdSet.contains(peopleObj.User__c) ? true : false;
					}	
				}
				Map<String, Object> resultObj = new Map<String, Object>();
				resultObj.put('nextPageToken', likePageObj.nextPageToken);
				resultObj.put('listOfItems', listOfLikersTemp);
				response = buildResponseWrapper('success', null, resultObj);
				logger.logDebug('END:init()-');
			
		}else {
			response = buildResponseWrapper('success', null, null);	
			}				
		} catch (Exception e) {
			logger.logError('FeedLikeDataServer.handleRequest()-----could not retrieve data----',e);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
	}
}