public with sharing class MobilePeopleDataProvider {
	
	public List<PeopleCacheWrapper> getAllPeopleForCaching(Integer size, Integer offset){
		MobilePeopleDao mblPeopleDaoObj = new MobilePeopleDao();
		List<People__c> peopleList = mblPeopleDaoObj.getAllPeopleForCaching(size, offset);
		List<PeopleCacheWrapper> peopleWrapperList = generateListOfPeopleCacheWrap(peopleList);
		return  peopleWrapperList;
	}
	
    public Map<String,Object> getUpdatedPeopleMap(DateTime pollTimeStamp, Integer offset, Integer size){
    	String loggedInPeopleId = UserContext.peopleId;
    	MobilePeopleDao mblPeopleDaoObj = new MobilePeopleDao();
    	List<People__c> peopleList = mblPeopleDaoObj.getLastEditedPeopleList(pollTimeStamp, offset, size);
        List<People__c> deletePeopleList = new List<People__c>();
        List<People__c> updatedPeopleList = new List<People__c>();
        
        if(offset == null || offset == 0){
			Integer loopIterationIndex = (size+offset) > peopleList.size()? peopleList.size():(size+offset);
			for(Integer Counter = offset; Counter<loopIterationIndex;  Counter++){
				updatedpeopleList.add(peopleList[Counter]);
			}
		} else {
			for(People__c peopleObj : peopleList){
				updatedpeopleList.add(peopleObj);
			}
		}
        
        Map<String,Object> peopleChangeMap = new Map<String,Object>();
        peopleChangeMap.put('deleteList',generateListOfPeopleCacheWrap(deletePeopleList));
        peopleChangeMap.put('updateList',generateListOfPeopleCacheWrap(updatedPeopleList));
        peopleChangeMap.put('updateRecordCount',peopleList.size());
        return peopleChangeMap;
    }
    
    public List<Object> getAllFavoritePeople(String term, Integer offset, Integer recordLimit, Boolean isFullModel){
		MobilePeopleDao mblPeopleDaoObj = new MobilePeopleDao();
		List<Bookmark__c> listOfBookmarks = mblPeopleDaoObj.getAllFavoritePeople(term, offset, recordLimit);
		
		List<Id> favoritePeopleIdsOrderedList = new List<Id>();
    		for (Bookmark__c favoriteObj : listOfBookmarks) {
			favoritePeopleIdsOrderedList.add(favoriteObj.Bookmark_Receiver__c);
		}
		if(isFullModel){
			List<PeopleCacheWrapper> peopleWrapperList = new List<PeopleCacheWrapper>();
			Map<Id,People__c> mapOfPeople = mblPeopleDaoObj.getAllPeople(new Set<Id>(favoritePeopleIdsOrderedList));
			for (Bookmark__c favoriteObj : listOfBookmarks) {
				peopleWrapperList.add(convertToPeopleCacheWrapper(mapOfPeople.get(favoriteObj.Bookmark_Receiver__c)));
			}
			return peopleWrapperList;
		}else{
			return favoritePeopleIdsOrderedList;
		}
	}
	
    public List<Object> getAllSiteMemberList(String chatterGroupId, Integer offset, Integer recordLimit, Boolean isFullModel){
    	MobilePeopleDao mpd = new MobilePeopleDao();
		List<CollaborationGroupMember> cgMemberList = Utility.getColGroupMembers(chatterGroupId);
		Set<Id> memberIdSet = new Set<Id>();
		for(CollaborationGroupMember collMember: cgMemberList){
	        memberIdSet.add(collMember.memberId);
	    }
	    
		List<People__c> peopleList = mpd.getAllSiteMemberPeopleList(memberIdSet, offset, recordLimit);
		return generateListOfPeopleCacheWrap(peopleList);		
    }
    
    public List<PeopleCacheWrapper> generateListOfPeopleCacheWrap(List<People__c> peopleObjList){
    		List<PeopleCacheWrapper> peopleCacheWrapperList = new List<PeopleCacheWrapper>();
		for(People__c peopleRecord : peopleObjList){
	    		peopleCacheWrapperList.add(convertToPeopleCacheWrapper(peopleRecord));
	    	}
    		return peopleCacheWrapperList;
    }
    
	public PeopleCacheWrapper convertToPeopleCacheWrapper(People__c peopleObj){
		PeopleCacheWrapper peopleWrapObj = new PeopleCacheWrapper(); 
		peopleWrapObj.firstName = peopleObj.First_Name__c;
		peopleWrapObj.LastName = peopleObj.Last_Name__c;
        	peopleWrapObj.peopleId = peopleObj.id;
        	peopleWrapObj.isActivated = peopleObj.User__r.isActive;
        	peopleWrapObj.isActive = peopleObj.User__r.isActive;
		peopleWrapObj.showInSimpplr = peopleObj.User__r.Show_Simpplr__c;
		peopleWrapObj.userType = peopleObj.User__r.UserType;
        	peopleWrapObj.isDeleted = (peopleObj.Is_Deleted__c == null) ? false : peopleObj.Is_Deleted__c;
        	peopleWrapObj.sfuserId = peopleObj.user__c;
			peopleWrapObj.img = Utility.getProfilePhotoURL(peopleObj.user__r.FullPhotoURL);
        	peopleWrapObj.mediumPhotoUrl = Utility.getUserProfileImgUrl(peopleObj.user__r.MediumPhotoURL, peopleObj.user__r.FullPhotoURL);
        	
        	if(String.isNotBlank(peopleObj.user__r.SmallPhotoURL)) {
        		peopleWrapObj.smallPhotoUrl = peopleObj.user__r.SmallPhotoURL.endsWith('005/T') ? null : peopleObj.user__r.SmallPhotoURL;
        	}
        	peopleWrapObj.name = Utility.buildName(peopleObj.First_Name__c,peopleObj.Last_Name__c);
        	peopleWrapObj.department = peopleObj.Department__c;
        	peopleWrapObj.title = peopleObj.Title__c;
        	peopleWrapObj.isFollowing = UserContext.usersIFollowIdSet.contains(peopleObj.User__c);
        
		    if (!peopleObj.Bookmark_Receiver_People__r.isEmpty()) {
		        peopleWrapObj.isFavorited = true;
		    } else {
		        peopleWrapObj.isFavorited = false;
		    }
		    if (UserContext.peopleId == peopleObj.Id) {
	            peopleWrapObj.canFollow = false;
	            peopleWrapObj.canFavorite = false;
	        } else {
	            peopleWrapObj.canFollow = peopleObj.User__r.isActive;
	            peopleWrapObj.canFavorite = peopleObj.User__r.isActive;
	        }

			if(SimpplrContext.isPPVideoDisplay){
				if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					peopleWrapObj.videoCallUsername = String.isNotBlank(peopleObj.Zoom_Id__c) ? peopleObj.Zoom_Id__c : '';
				} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					peopleWrapObj.videoCallUsername = String.isNotBlank(peopleObj.Skype_Id__c) ? peopleObj.Skype_Id__c : '';
				}
				peopleWrapObj.videoCallProvider = String.isNotBlank(SimpplrContext.PPVideoProvider) ? SimpplrContext.PPVideoProvider : '' ;
			} else {
				peopleWrapObj.videoCallProvider = 'N.A.';
			}
			
			if(String.isNotBlank(peopleObj.Cover_Content_Document_Id__c)) {
				peopleWrapObj.coverImageFile = new FileDetailWrapper();
				peopleWrapObj.coverImageFile.id = peopleObj.Cover_Content_Document_Id__c;
			}

		    peopleWrapObj.location = Utility.buildLocation(peopleObj.City__c, peopleObj.State__c, peopleObj.Country__c);
		    peopleWrapObj.street = peopleObj.Street__c;
		    peopleWrapObj.city = peopleObj.City__c;
		    peopleWrapObj.state = peopleObj.State__c;
		    peopleWrapObj.country = peopleObj.Country__c;
		    peopleWrapObj.email = peopleObj.Email__c;
		    peopleWrapObj.mobile = peopleObj.Mobile_Phone__c;
		    peopleWrapObj.phone = peopleObj.Phone__c;
		    peopleWrapObj.phoneExtension = peopleObj.Extension__c;
		    peopleWrapObj.about = peopleObj.About__c;
			peopleWrapObj.segmentID = peopleObj.Segment__c;
		    
		return peopleWrapObj;
	}
}