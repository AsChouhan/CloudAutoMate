/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ContentLikeDataServer extends DataServer {
	
    private final String REQUEST_PARAM_DATA = 'data';
    
    public ContentLikeDataServer() {
    	
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
	public override void handleRequest() {
		try {
			logger.logDebug('ContentLikeDataServer----entered handleRequest----');
			
			String data = readParam(REQUEST_PARAM_DATA);
			Map<String,Object> dataObj =  (Map<String,Object>) JSON.deserializeUntyped(data);
			String contentId = '';
			String pageSize = '25';
			String nextPageToken = '0';
			if(dataObj.containsKey('id')) {
				contentId = String.valueOf(dataObj.get('id'));
			}
			if(dataObj.containsKey('size')) {
				pageSize = String.valueOf(dataObj.get('size'));
			}
			if(dataObj.containsKey('nextPageToken')) {
				nextPageToken = String.valueOf(dataObj.get('nextPageToken'));
			}
			if (String.isNotBlank(contentId)) {				
				if (nextPageToken == null || nextPageToken.length() == 0 || nextPageToken == 'null') {
					nextPageToken = '0';
				}
				Integer intPageSize = Integer.valueOf(pageSize);
				Integer rowLimit = intPageSize + 1;
				Integer rowOffset = Integer.valueOf(nextPageToken);
				String subConditionQuery = '';
				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					subConditionQuery += ' order by CreatedDate asc ';
				} else {
					subConditionQuery += ' order by People__r.Full_Name__c ';
				}
				subConditionQuery += ' limit :soqlParam2 OFFSET :soqlParam3';
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', contentId);
				soqlParamMap.put('soqlParam2', rowLimit);
				soqlParamMap.put('soqlParam3', rowOffset);
				String queryStr = 'Select Id, People__r.User__c, People__r.Title__c, People__r.State__c, '+
				'People__r.Department__c, People__r.Country__c, People__r.City__c, People__r.Full_Name__c, People__c,People__r.Mobile_Phone__c,People__r.Phone__c, People__r.Extension__c, ' +
				'Is_Deleted__c, Content__c, People__r.User__r.SmallPhotoUrl,People__r.Email__c,People__r.User__r.isactive ' +
				'From Like__c where Content__c = :soqlParam1 ' +
				'And ((People__r.User__r.UserType=\'Standard\' ' +
					'And People__r.User__r.Show_Simpplr__c != \'No\') ' + 
				'Or People__r.User__r.Show_Simpplr__c = \'Yes\') ';
				queryStr = queryStr + subConditionQuery;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Like__c> listOfLikes = (List<Like__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
				if(listOfLikes.size() > intPageSize) {
					rowOffset = rowOffset +  intPageSize;
				}	else {
					rowOffset = 0;
				}
				if(listOfLikes.size() > intPageSize) {
					listOfLikes.remove(listOfLikes.size()-1);	
				}
				Map<Object,Object> result = New Map<Object,Object>();
		        result.put('listOfItems', convertPeopleToContentLikerWrapper(listOfLikes));
		        result.put('nextPageToken',(rowOffset == 0 ? null : String.valueOf(rowOffset)));
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
			} else {
				response = buildResponseWrapper(RESPONSE_STATUS_FAIL, null, null);
			}	
		} catch (Exception ex) {
			logger.logError(ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
	}
	
	@TestVisible
	private List<LikersWrapper> convertPeopleToContentLikerWrapper(List<Like__c> listOfLikes) {
		List<LikersWrapper> listOfContentLikerWrapper = new List<LikersWrapper> ();
		String currentUserId = Userinfo.getUserid();
		String BASE_QUERY = 'Select ParentId From EntitySubscription where IsDeleted = false and SubscriberId = :currentUserId';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY+=' and NetworkId = null';
		}
		String SUB_CONDITION = ' Limit 1000';
		String query = BASE_QUERY+SUB_CONDITION;
		List<EntitySubscription> listofUsersIFollow = new List<EntitySubscription>();
		listofUsersIFollow = Database.query(query);
		Set<Id> setOfUserIds = new Set<Id>();
		for(EntitySubscription es : listofUsersIFollow)	{	
			setOfUserIds.add(es.ParentId);
		}
		List<Bookmark__c> listOfUsersFavorite = [SELECT People__c, Bookmark_Receiver__c 
				FROM Bookmark__c WHERE People__c=:UserContext.peopleId AND Type__c='People' AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
				
		Set<Id> setOfUsersFavorite = new Set<Id>();
		for(Bookmark__c bookmark : listOfUsersFavorite){
			setOfUsersFavorite.add(bookmark.Bookmark_Receiver__c);
		}
		for (Like__c pplLike : listOfLikes) {
			LikersWrapper clw = new LikersWrapper();
			clw.Id = pplLike.People__c;
			clw.peopleId = pplLike.People__c;
			clw.userId = pplLike.People__r.User__c;
			clw.name = pplLike.People__r.Full_Name__c;
			String profileImg = pplLike.People__r.User__r.SmallPhotoUrl;
			if(profileImg.containsIgnoreCase('/005/T') == false) {
				clw.img = profileImg;
			}
			clw.url = PageContext.getPageURL(Pages.app) + '?u=/people/' +  pplLike.People__r.Id;
			clw.department = SimpplrContext.isPPDepartmentDisplay == false ? null:pplLike.People__r.Department__c;
			clw.title = SimpplrContext.isPPTitleDisplay == false ? null:pplLike.People__r.Title__c;
			clw.email = pplLike.People__r.Email__c;
			clw.mobile = SimpplrContext.isPPMobilePhoneDisplay == false ? null:pplLike.People__r.Mobile_Phone__c;
			clw.phone = SimpplrContext.isPPPhoneDisplay == false ? null:pplLike.People__r.Phone__c;
			clw.phoneExtension = SimpplrContext.isPPExtensionDisplay == false ? null:pplLike.People__r.Extension__c;
			clw.location = utility.buildLocation(pplLike.People__r.City__c, pplLike.People__r.State__c, pplLike.People__r.Country__c) ;
			if(setOfUserIds.contains(clw.userId)) {
				clw.isFollowing = true;
			} else {
				clw.isFollowing = false;
			}
			if (setOfUsersFavorite.contains(pplLike.People__r.Id)) {
				clw.isFavorited = true;				
			} else {
				clw.isFavorited = false;
			}
			
			clw.isActive = pplLike.People__r.User__r.isactive;
			if(clw.userId == UserInfo.getUserId()) {
				clw.canFavorite = false;
			} else {
				clw.canFavorite = pplLike.People__r.User__r.isactive;
			}
			
			if(clw.userId == UserInfo.getUserId()) {
				clw.canFollow = false;
			} else {
				clw.canFollow = pplLike.People__r.User__r.isactive;
			}
			listOfContentLikerWrapper.add(clw);
		}
		return listOfContentLikerWrapper;
	}
    
}