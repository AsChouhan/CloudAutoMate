public with sharing class SegmentationWrapperAdapter {
	private static Boolean isPageContext = false; 
	public static SegmentWrapper.PaginationWrapper convertToLightSegmentWrapList (List<Segment__c> listOfSegment, Boolean includeUnassigned) {
		isPageContext = true;
		List<SegmentWrapper> listOfSegmentWrap = new List<SegmentWrapper>();
		Map<String, SegmentWrapper.SubsegmentListWrapper> mapOfSubsegmentListWrapper = getSubsegments(null);
		
		for (Segment__c segmentObj: listOfSegment) {
			SegmentWrapper segmentWrapObj = new SegmentWrapper();
			segmentWrapObj = convertToLightSegmentWrap(segmentObj);
			segmentWrapObj.audienceCount = mapOfSubsegmentListWrapper.get(segmentObj.Id).audienceCount;
			listOfSegmentWrap.add(segmentWrapObj);
		}
		
		SegmentWrapper.PaginationWrapper paginationWrapperObj = new SegmentWrapper.PaginationWrapper();
		paginationWrapperObj.listOfItems = listOfSegmentWrap;
		
		if(includeUnassigned == true){
			paginationWrapperObj.unassigned = new SegmentWrapper.UnassignedWrapper();
			if(mapOfSubsegmentListWrapper.containsKey(null)) {
				SegmentWrapper.SubsegmentListWrapper unassignedSubSegments = mapOfSubsegmentListWrapper.get(null);
				for(SegmentWrapper.SubsegmentWrapper subsegmentWrapperObj : unassignedSubSegments.listOfSubsegments) {
					if(String.isBlank(subsegmentWrapperObj.name)) {
						paginationWrapperObj.unassigned.unclassifiedAudienceCount = subsegmentWrapperObj.audienceCount;
					} else {
						paginationWrapperObj.unassigned.listOfSubsegments.add(subsegmentWrapperObj);
					}
					if(paginationWrapperObj.unassigned.unclassifiedAudienceCount > 0 || !paginationWrapperObj.unassigned.listOfSubsegments.isEmpty()){
						paginationWrapperObj.unassigned.csvUrl = PageContext.getPageURL(Pages.Reports)+ '?action=getUnassignedSegmentUsers';	
					}					
				}
			}
		}
		return paginationWrapperObj;
	}
	
	private static SegmentWrapper convertToSegmenLiteWrapper (Subscription__c subscriptionObj, Integer audienceCount) {
		Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;
		
		SegmentWrapper segmentWrapObj = new SegmentWrapper();
		segmentWrapObj.segmentId = subscriptionObj.Audience__r.Segment__c;
		segmentWrapObj.name = subscriptionObj.Audience__r.Segment__r.Name__c;
		segmentWrapObj.createdAt = subscriptionObj.Audience__r.Segment__r.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		segmentWrapObj.audienceCount = audienceCount;
		segmentWrapObj.createdBy = new PeopleLiteWrapper();
	    segmentWrapObj.createdBy.id = subscriptionObj.Audience__r.Segment__r.Created_By_People__c;
	    segmentWrapObj.createdBy.peopleId =  subscriptionObj.Audience__r.Segment__r.Created_By_People__c;
	    segmentWrapObj.createdBy.userId =  subscriptionObj.Audience__r.Segment__r.Created_By_People__r.user__r.Id;
	    segmentWrapObj.createdBy.sfUserId =  subscriptionObj.Audience__r.Segment__r.Created_By_People__r.user__r.Id;	    
		
		if (String.isNotBlank(Utility.buildName(subscriptionObj.Audience__r.Segment__r.Created_By_People__r.First_Name__c, 
				subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Last_Name__c))){
			segmentWrapObj.createdBy.name = Utility.buildName(subscriptionObj.Audience__r.Segment__r.Created_By_People__r.First_Name__c, 
					subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Last_Name__c);
		}		
		
	    segmentWrapObj.createdBy.nickname = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Community_Nickname__c;
		segmentWrapObj.createdBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + subscriptionObj.Audience__r.Segment__r.Created_By_People__c;
	    segmentWrapObj.createdBy.img = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : subscriptionObj.Audience__r.Segment__r.Created_By_People__r.user__r.SmallPhotoURL;
	    segmentWrapObj.createdBy.department = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Department__c;
	    segmentWrapObj.createdBy.title = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Title__c;
	    segmentWrapObj.createdBy.location = Utility.buildLocation(subscriptionObj.Audience__r.Segment__r.Created_By_People__r.City__c, subscriptionObj.Audience__r.Segment__r.Created_By_People__r.State__c, subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Country__c);
	    segmentWrapObj.createdBy.email = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Email__c;
	    segmentWrapObj.createdBy.phone = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Phone__c;
	    segmentWrapObj.createdBy.mobile = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.mobile_phone__c;
	    segmentWrapObj.createdBy.phoneExtension = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.extension__c;
	    segmentWrapObj.createdBy.about = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.About__c;
	    segmentWrapObj.createdBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Birth_Date__c,'MM-dd') : null;
		
		if (SimpplrContext.isPPJoiningDateDisplay && 
				subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Joining_Date__c != null && 
				subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
			segmentWrapObj.createdBy.hireDate = Utility.dateToDisplayString(subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Joining_Date__c,'yyyy-MM-dd');
			segmentWrapObj.createdBy.workAnniversary = Utility.dateToDisplayString(subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Joining_Date__c,'MM-dd');
		}	
		
		segmentWrapObj.createdBy.isFollowing = usersIFollowIdSet.contains(subscriptionObj.Audience__r.Segment__r.Created_By_People__r.User__c);	
		segmentWrapObj.createdBy.isFavorited = setOfMyFavouritePeopleId.contains(subscriptionObj.Audience__r.Segment__r.Created_By_People__c);	
		segmentWrapObj.createdBy.isActive = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.User__r.isactive;
		segmentWrapObj.createdBy.canFollow = (UserContext.getCurrentUserInfo.Id == subscriptionObj.Audience__r.Segment__r.Created_By_People__c) ? false : subscriptionObj.Audience__r.Segment__r.Created_By_People__r.User__r.isactive;
		
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.createdBy.videoCallUsername = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.createdBy.videoCallUsername = subscriptionObj.Audience__r.Segment__r.Created_By_People__r.Skype_Id__c;
		}
		segmentWrapObj.createdBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		segmentWrapObj.modifiedAt = subscriptionObj.Audience__r.Segment__r.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); 
		segmentWrapObj.modifiedBy = new PeopleLiteWrapper();
	    segmentWrapObj.modifiedBy.id =  subscriptionObj.Audience__r.Segment__r.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.peopleId =  subscriptionObj.Audience__r.Segment__r.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.userId =  subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.user__r.Id;
	    segmentWrapObj.modifiedBy.sfUserId =  subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.user__r.Id;
		
		if (String.isNotBlank(Utility.buildName(subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.First_Name__c, 
				subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Last_Name__c))){
			segmentWrapObj.modifiedBy.name = Utility.buildName(subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.First_Name__c,subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Last_Name__c);
		}
			
	    segmentWrapObj.modifiedBy.nickname = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Community_Nickname__c;
		segmentWrapObj.modifiedBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + subscriptionObj.Audience__r.Segment__r.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.img = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.user__r.SmallPhotoURL;
	    segmentWrapObj.modifiedBy.department = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Department__c;
	    segmentWrapObj.modifiedBy.title = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Title__c;
	    segmentWrapObj.modifiedBy.location = Utility.buildLocation(subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.City__c, subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.State__c, subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Country__c);
	    segmentWrapObj.modifiedBy.email = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Email__c;
	    segmentWrapObj.modifiedBy.phone = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Phone__c;
	    segmentWrapObj.modifiedBy.mobile = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.mobile_phone__c;
	    segmentWrapObj.modifiedBy.phoneExtension = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.extension__c;
	    segmentWrapObj.modifiedBy.about = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.About__c;
	    segmentWrapObj.modifiedBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Birth_Date__c,'MM-dd') : null;
		
		if (SimpplrContext.isPPJoiningDateDisplay && 
				subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Joining_Date__c != null && 
				subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
			segmentWrapObj.modifiedBy.hireDate = Utility.dateToDisplayString(subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Joining_Date__c,'yyyy-MM-dd');
			segmentWrapObj.modifiedBy.workAnniversary = Utility.dateToDisplayString(subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Joining_Date__c,'MM-dd');
		}	
		
		segmentWrapObj.modifiedBy.isFollowing = usersIFollowIdSet.contains(subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.User__c);	
		segmentWrapObj.modifiedBy.isFavorited = setOfMyFavouritePeopleId.contains(subscriptionObj.Audience__r.Segment__r.Modified_By_People__c);	
		segmentWrapObj.modifiedBy.isActive = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.User__r.isactive;
		segmentWrapObj.modifiedBy.canFollow = (UserContext.getCurrentUserInfo.Id == subscriptionObj.Audience__r.Segment__r.Modified_By_People__c) ? false : subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.User__r.isactive;		
		
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.modifiedBy.videoCallUsername = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.modifiedBy.videoCallUsername = subscriptionObj.Audience__r.Segment__r.Modified_By_People__r.Skype_Id__c;
		}
		segmentWrapObj.modifiedBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		return segmentWrapObj;
	}
	
	public static SegmentWrapper convertToLightSegmentWrap (Segment__c segmentObj) {
		Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;
		
		SegmentWrapper segmentWrapObj = new SegmentWrapper();
		segmentWrapObj.segmentId = segmentObj.Id;
		segmentWrapObj.name = segmentObj.Name__c;
		segmentWrapObj.createdAt = segmentObj.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		segmentWrapObj.createdBy = new PeopleLiteWrapper();
	    segmentWrapObj.createdBy.id =  segmentObj.Created_By_People__c;
	    segmentWrapObj.createdBy.peopleId =  segmentObj.Created_By_People__c;
	    segmentWrapObj.createdBy.userId =  segmentObj.Created_By_People__r.user__r.Id;
	    segmentWrapObj.createdBy.sfUserId =  segmentObj.Created_By_People__r.user__r.Id;	    
		
		if (String.isNotBlank(Utility.buildName(segmentObj.Created_By_People__r.First_Name__c, 
				segmentObj.Created_By_People__r.Last_Name__c))){
			segmentWrapObj.createdBy.name = Utility.buildName(segmentObj.Created_By_People__r.First_Name__c, 
					segmentObj.Created_By_People__r.Last_Name__c);
		}		
		
	    segmentWrapObj.createdBy.nickname = segmentObj.Created_By_People__r.Community_Nickname__c;
		segmentWrapObj.createdBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + segmentObj.Created_By_People__c;
	    segmentWrapObj.createdBy.img = segmentObj.Created_By_People__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : segmentObj.Created_By_People__r.user__r.SmallPhotoURL;
	    segmentWrapObj.createdBy.department = segmentObj.Created_By_People__r.Department__c;
	    segmentWrapObj.createdBy.title = segmentObj.Created_By_People__r.Title__c;
	    segmentWrapObj.createdBy.location = Utility.buildLocation(segmentObj.Created_By_People__r.City__c, segmentObj.Created_By_People__r.State__c, segmentObj.Created_By_People__r.Country__c);
	    segmentWrapObj.createdBy.email = segmentObj.Created_By_People__r.Email__c;
	    segmentWrapObj.createdBy.phone = segmentObj.Created_By_People__r.Phone__c;
	    segmentWrapObj.createdBy.mobile = segmentObj.Created_By_People__r.mobile_phone__c;
	    segmentWrapObj.createdBy.phoneExtension = segmentObj.Created_By_People__r.extension__c;
	    segmentWrapObj.createdBy.about = segmentObj.Created_By_People__r.About__c;
	    segmentWrapObj.createdBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(segmentObj.Created_By_People__r.Birth_Date__c,'MM-dd') : null;
		
		if (SimpplrContext.isPPJoiningDateDisplay && 
				segmentObj.Created_By_People__r.Joining_Date__c != null && 
				segmentObj.Created_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
			segmentWrapObj.createdBy.hireDate = Utility.dateToDisplayString(segmentObj.Created_By_People__r.Joining_Date__c,'yyyy-MM-dd');
			segmentWrapObj.createdBy.workAnniversary = Utility.dateToDisplayString(segmentObj.Created_By_People__r.Joining_Date__c,'MM-dd');
		}	
		
		segmentWrapObj.createdBy.isFollowing = usersIFollowIdSet.contains(segmentObj.Created_By_People__r.User__c);	
		segmentWrapObj.createdBy.isFavorited = setOfMyFavouritePeopleId.contains(segmentObj.Created_By_People__c);	
		segmentWrapObj.createdBy.isActive = segmentObj.Created_By_People__r.User__r.isactive;
		segmentWrapObj.createdBy.canFollow = (UserContext.getCurrentUserInfo.Id == segmentObj.Created_By_People__c) ? false : segmentObj.Created_By_People__r.User__r.isactive;
		
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.createdBy.videoCallUsername = segmentObj.Created_By_People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.createdBy.videoCallUsername = segmentObj.Created_By_People__r.Skype_Id__c;
		}
		segmentWrapObj.createdBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		segmentWrapObj.modifiedAt = segmentObj.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); 
		segmentWrapObj.modifiedBy = new PeopleLiteWrapper();
	    segmentWrapObj.modifiedBy.id =  segmentObj.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.peopleId =  segmentObj.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.userId =  segmentObj.Modified_By_People__r.user__r.Id;
	    segmentWrapObj.modifiedBy.sfUserId =  segmentObj.Modified_By_People__r.user__r.Id;
		
		if (String.isNotBlank(Utility.buildName(segmentObj.Modified_By_People__r.First_Name__c, 
				segmentObj.Modified_By_People__r.Last_Name__c))){
			segmentWrapObj.modifiedBy.name = Utility.buildName(segmentObj.Modified_By_People__r.First_Name__c,segmentObj.Modified_By_People__r.Last_Name__c);
		}
			
	    segmentWrapObj.modifiedBy.nickname = segmentObj.Modified_By_People__r.Community_Nickname__c;
		segmentWrapObj.modifiedBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + segmentObj.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.img = segmentObj.Modified_By_People__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : segmentObj.Modified_By_People__r.user__r.SmallPhotoURL;
	    segmentWrapObj.modifiedBy.department = segmentObj.Modified_By_People__r.Department__c;
	    segmentWrapObj.modifiedBy.title = segmentObj.Modified_By_People__r.Title__c;
	    segmentWrapObj.modifiedBy.location = Utility.buildLocation(segmentObj.Modified_By_People__r.City__c, segmentObj.Modified_By_People__r.State__c, segmentObj.Modified_By_People__r.Country__c);
	    segmentWrapObj.modifiedBy.email = segmentObj.Modified_By_People__r.Email__c;
	    segmentWrapObj.modifiedBy.phone = segmentObj.Modified_By_People__r.Phone__c;
	    segmentWrapObj.modifiedBy.mobile = segmentObj.Modified_By_People__r.mobile_phone__c;
	    segmentWrapObj.modifiedBy.phoneExtension = segmentObj.Modified_By_People__r.extension__c;
	    segmentWrapObj.modifiedBy.about = segmentObj.Modified_By_People__r.About__c;
	    segmentWrapObj.modifiedBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(segmentObj.Modified_By_People__r.Birth_Date__c,'MM-dd') : null;
		
		if (SimpplrContext.isPPJoiningDateDisplay && 
				segmentObj.Modified_By_People__r.Joining_Date__c != null && 
				segmentObj.Modified_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
			segmentWrapObj.modifiedBy.hireDate = Utility.dateToDisplayString(segmentObj.Modified_By_People__r.Joining_Date__c,'yyyy-MM-dd');
			segmentWrapObj.modifiedBy.workAnniversary = Utility.dateToDisplayString(segmentObj.Modified_By_People__r.Joining_Date__c,'MM-dd');
		}	
		
		segmentWrapObj.modifiedBy.isFollowing = usersIFollowIdSet.contains(segmentObj.Modified_By_People__r.User__c);	
		segmentWrapObj.modifiedBy.isFavorited = setOfMyFavouritePeopleId.contains(segmentObj.Modified_By_People__c);	
		segmentWrapObj.modifiedBy.isActive = segmentObj.Modified_By_People__r.User__r.isactive;
		segmentWrapObj.modifiedBy.canFollow = (UserContext.getCurrentUserInfo.Id == segmentObj.Modified_By_People__c) ? false : segmentObj.Modified_By_People__r.User__r.isactive;		
		
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.modifiedBy.videoCallUsername = segmentObj.Modified_By_People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.modifiedBy.videoCallUsername = segmentObj.Modified_By_People__r.Skype_Id__c;
		}
		segmentWrapObj.modifiedBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		return segmentWrapObj;
	}
	
	 public static SegmentWrapper.PaginationWrapper convertToFullSegmentWrapList (List<Segment__c> listOfSegment, Boolean includeUnassigned) {
	 	isPageContext = true;
		List<SegmentWrapper> listOfSegmentWrap = new List<SegmentWrapper>();
		Map<String, SegmentWrapper.SubsegmentListWrapper> mapOfSubsegmentListWrapper = getSubsegments(null);
		for (Segment__c segmentObj: listOfSegment) {
			SegmentWrapper segmentWrapObj = new SegmentWrapper();
			segmentWrapObj = convertToFullSegmentWrap(segmentObj);
			if(mapOfSubsegmentListWrapper.containsKey(segmentObj.Id)) {
				segmentWrapObj.listOfSubsegments = mapOfSubsegmentListWrapper.get(segmentObj.Id).listOfSubsegments;
				segmentWrapObj.audienceCount = mapOfSubsegmentListWrapper.get(segmentObj.Id).audienceCount;
			} else {
				segmentWrapObj.listOfSubsegments = new List<SegmentWrapper.SubsegmentWrapper>();
				segmentWrapObj.audienceCount = 0;
			}
			listOfSegmentWrap.add(segmentWrapObj);
		}
		SegmentWrapper.PaginationWrapper paginationWrapperObj = new SegmentWrapper.PaginationWrapper();
		paginationWrapperObj.listOfItems = listOfSegmentWrap;
		
		if(includeUnassigned == true){
			paginationWrapperObj.unassigned = new SegmentWrapper.UnassignedWrapper();
			if(mapOfSubsegmentListWrapper.containsKey(null)) {
				SegmentWrapper.SubsegmentListWrapper unassignedSubSegments = mapOfSubsegmentListWrapper.get(null);
				for(SegmentWrapper.SubsegmentWrapper subsegmentWrapperObj : unassignedSubSegments.listOfSubsegments) {
					if(String.isBlank(subsegmentWrapperObj.name)) {
						paginationWrapperObj.unassigned.unclassifiedAudienceCount = subsegmentWrapperObj.audienceCount;
					} else {
						paginationWrapperObj.unassigned.listOfSubsegments.add(subsegmentWrapperObj);
					}
					if(paginationWrapperObj.unassigned.unclassifiedAudienceCount > 0 || !paginationWrapperObj.unassigned.listOfSubsegments.isEmpty()){
						paginationWrapperObj.unassigned.csvUrl = PageContext.getPageURL(Pages.Reports)+ '?action=getUnassignedSegmentUsers';	
					}
				}
			}
		}
		return paginationWrapperObj;
	}
	

	public static SegmentWrapper convertToFullSegmentWrap (Segment__c segmentObj) {
		Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;
		
		SegmentWrapper segmentWrapObj = new SegmentWrapper();
		segmentWrapObj.segmentId = segmentObj.Id;
		segmentWrapObj.name = segmentObj.Name__c;
		segmentWrapObj.isManager = UserContext.hasManageSegmentAccess;
		segmentWrapObj.createdAt = segmentObj.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		
		segmentWrapObj.createdBy = new PeopleLiteWrapper();
	    segmentWrapObj.createdBy.id =  segmentObj.Created_By_People__c;
	    segmentWrapObj.createdBy.peopleId =  segmentObj.Created_By_People__c;
	    segmentWrapObj.createdBy.userId =  segmentObj.Created_By_People__r.user__r.Id;
	    segmentWrapObj.createdBy.sfUserId =  segmentObj.Created_By_People__r.user__r.Id;	    
		
		if (String.isNotBlank(Utility.buildName (segmentObj.Created_By_People__r.First_Name__c, 
				segmentObj.Created_By_People__r.Last_Name__c))) {
			segmentWrapObj.createdBy.name = Utility.buildName(segmentObj.Created_By_People__r.First_Name__c, 
					segmentObj.Created_By_People__r.Last_Name__c);
		}		
		
	    segmentWrapObj.createdBy.nickname = segmentObj.Created_By_People__r.Community_Nickname__c;
		segmentWrapObj.createdBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + segmentObj.Created_By_People__c;
	    segmentWrapObj.createdBy.img = Utility.getProfilePhotoURL(segmentObj.Created_By_People__r.user__r.SmallPhotoURL);
	    segmentWrapObj.createdBy.department = segmentObj.Created_By_People__r.Department__c;
	    segmentWrapObj.createdBy.title = segmentObj.Created_By_People__r.Title__c;
	    segmentWrapObj.createdBy.location = Utility.buildLocation(segmentObj.Created_By_People__r.City__c, segmentObj.Created_By_People__r.State__c, segmentObj.Created_By_People__r.Country__c);
	    segmentWrapObj.createdBy.email = segmentObj.Created_By_People__r.Email__c;
	    segmentWrapObj.createdBy.phone = segmentObj.Created_By_People__r.Phone__c;
	    segmentWrapObj.createdBy.mobile = segmentObj.Created_By_People__r.mobile_phone__c;
	    segmentWrapObj.createdBy.phoneExtension = segmentObj.Created_By_People__r.extension__c;
	    segmentWrapObj.createdBy.about = segmentObj.Created_By_People__r.About__c;
	    segmentWrapObj.createdBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(segmentObj.Created_By_People__r.Birth_Date__c,'MM-dd') : null;
		
		if (SimpplrContext.isPPJoiningDateDisplay && 
				segmentObj.Created_By_People__r.Joining_Date__c != null && 
				segmentObj.Created_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
			segmentWrapObj.createdBy.hireDate = Utility.dateToDisplayString(segmentObj.Created_By_People__r.Joining_Date__c,'yyyy-MM-dd');
			segmentWrapObj.createdBy.workAnniversary = Utility.dateToDisplayString(segmentObj.Created_By_People__r.Joining_Date__c,'MM-dd');
		}	
		
		segmentWrapObj.createdBy.isFollowing = usersIFollowIdSet.contains(segmentObj.Created_By_People__r.User__c);	
		segmentWrapObj.createdBy.isFavorited = setOfMyFavouritePeopleId.contains(segmentObj.Created_By_People__c);	
		segmentWrapObj.createdBy.isActive = segmentObj.Created_By_People__r.User__r.isactive;
		segmentWrapObj.createdBy.canFollow = (UserContext.getCurrentUserInfo.Id == segmentObj.Created_By_People__c) ? false : segmentObj.Created_By_People__r.User__r.isactive;		
		
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.createdBy.videoCallUsername = segmentObj.Created_By_People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.createdBy.videoCallUsername = segmentObj.Created_By_People__r.Skype_Id__c;
		}
		segmentWrapObj.createdBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		segmentWrapObj.modifiedAt = segmentObj.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); 

		segmentWrapObj.modifiedBy = new PeopleLiteWrapper();
	    segmentWrapObj.modifiedBy.id =  segmentObj.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.peopleId =  segmentObj.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.userId =  segmentObj.Modified_By_People__r.user__r.Id;
	    segmentWrapObj.modifiedBy.sfUserId =  segmentObj.Modified_By_People__r.user__r.Id;
		
		if (String.isNotBlank(Utility.buildName(segmentObj.Modified_By_People__r.First_Name__c,
				segmentObj.Modified_By_People__r.Last_Name__c))) {
			segmentWrapObj.modifiedBy.name = Utility.buildName(segmentObj.Modified_By_People__r.First_Name__c,segmentObj.Modified_By_People__r.Last_Name__c);
		}	
		
	    segmentWrapObj.modifiedBy.nickname = segmentObj.Modified_By_People__r.Community_Nickname__c;
		segmentWrapObj.modifiedBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + segmentObj.Modified_By_People__c;
	    segmentWrapObj.modifiedBy.img = Utility.getProfilePhotoURL(segmentObj.Modified_By_People__r.user__r.SmallPhotoURL);
	    segmentWrapObj.modifiedBy.department = segmentObj.Modified_By_People__r.Department__c;
	    segmentWrapObj.modifiedBy.title = segmentObj.Modified_By_People__r.Title__c;
	    segmentWrapObj.modifiedBy.location = Utility.buildLocation(segmentObj.Modified_By_People__r.City__c, segmentObj.Modified_By_People__r.State__c, segmentObj.Modified_By_People__r.Country__c);
	    segmentWrapObj.modifiedBy.email = segmentObj.Modified_By_People__r.Email__c;
	    segmentWrapObj.modifiedBy.phone = segmentObj.Modified_By_People__r.Phone__c;
	    segmentWrapObj.modifiedBy.mobile = segmentObj.Modified_By_People__r.mobile_phone__c;
	    segmentWrapObj.modifiedBy.phoneExtension = segmentObj.Modified_By_People__r.extension__c;
	    segmentWrapObj.modifiedBy.about = segmentObj.Modified_By_People__r.About__c;
	    segmentWrapObj.modifiedBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(segmentObj.Modified_By_People__r.Birth_Date__c,'MM-dd') : null;
		
		if (SimpplrContext.isPPJoiningDateDisplay && 
				segmentObj.Modified_By_People__r.Joining_Date__c != null && 
				segmentObj.Modified_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
			segmentWrapObj.modifiedBy.hireDate = Utility.dateToDisplayString(segmentObj.Modified_By_People__r.Joining_Date__c,'yyyy-MM-dd');
			segmentWrapObj.modifiedBy.workAnniversary = Utility.dateToDisplayString(segmentObj.Modified_By_People__r.Joining_Date__c,'MM-dd');
		}	
		
		segmentWrapObj.modifiedBy.isFollowing = usersIFollowIdSet.contains(segmentObj.Modified_By_People__r.User__c);	
		segmentWrapObj.modifiedBy.isFavorited = setOfMyFavouritePeopleId.contains(segmentObj.Modified_By_People__c);	
		segmentWrapObj.modifiedBy.isActive = segmentObj.Modified_By_People__r.User__r.isactive;
		segmentWrapObj.modifiedBy.canFollow = (UserContext.getCurrentUserInfo.Id == segmentObj.Modified_By_People__c) ? false : segmentObj.Modified_By_People__r.User__r.isactive;		

		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.modifiedBy.videoCallUsername = segmentObj.Modified_By_People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			segmentWrapObj.modifiedBy.videoCallUsername = segmentObj.Modified_By_People__r.Skype_Id__c;
		}
		segmentWrapObj.modifiedBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		segmentWrapObj.listOfManagers = getListOfManagers(segmentObj.People_Segment__r, usersIFollowIdSet, setOfMyFavouritePeopleId);
		
		
		return segmentWrapObj;
	}
	
	public static Map<String, SegmentWrapper.SubsegmentListWrapper> getSubsegments(List<Segment__c> listOfSegment) {
		String packageName = SimpplrContext.packageName;
		String query = 'SELECT Segment__c , Segment_Attribute_Value__c FROM People__c ' +
					   ' Where User__r.IsActive = true ';
		if(listOfSegment !=null){
			query +=  ' And segment__c IN :listOfSegment';
		}	
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		
		List<People__c> peopleList = Database.query(query);
		Map<String, Integer> segmentVsAudienceCountMap = new Map<String,Integer>();
		for(People__c peopleObj: peopleList){
			String segmentIdSegmentAttributeValueKey = (String.isBlank(peopleObj.Segment__c)? '' : peopleObj.Segment__c)+':'+
				(String.isBlank(peopleObj.Segment_Attribute_Value__c)? '' : peopleObj.Segment_Attribute_Value__c);

			if(!segmentVsAudienceCountMap.containsKey(segmentIdSegmentAttributeValueKey)){
				segmentVsAudienceCountMap.put(segmentIdSegmentAttributeValueKey, 1);
			}else {
				segmentVsAudienceCountMap.put(segmentIdSegmentAttributeValueKey, segmentVsAudienceCountMap.get(segmentIdSegmentAttributeValueKey)+1);
			}
		}

		Map<String, SegmentWrapper.SubsegmentListWrapper> mapOfsubSegmentWrapper = new Map<String, SegmentWrapper.SubsegmentListWrapper>(); 
		
		for(String segmentIdSegmentAttributeValueKey : segmentVsAudienceCountMap.keySet()){
			List<String> segmentIdSegmentAttributeValueList = segmentIdSegmentAttributeValueKey.split(':');
			String segmentId = segmentIdSegmentAttributeValueList.size() > 0 ? segmentIdSegmentAttributeValueList.get(0) : null;
			SegmentWrapper.SubsegmentListWrapper subsegmentListWrapperObj = mapOfsubSegmentWrapper.get(String.isNotBlank(segmentId) ? segmentId : null);
			if(subsegmentListWrapperObj == null) {
				subsegmentListWrapperObj = new SegmentWrapper.SubsegmentListWrapper();
			}
			SegmentWrapper.SubsegmentWrapper subSegmentRecord = new SegmentWrapper.SubsegmentWrapper();
			subSegmentRecord.name = segmentIdSegmentAttributeValueList.size() > 0 ?segmentIdSegmentAttributeValueList.get(1) : '';
			subSegmentRecord.audienceCount = segmentVsAudienceCountMap.get(segmentIdSegmentAttributeValueKey);
			subsegmentListWrapperObj.listOfSubsegments.add(subSegmentRecord);
			subsegmentListWrapperObj.audienceCount += subSegmentRecord.audienceCount;

			if(String.isNotBlank(segmentId)){
				mapOfsubSegmentWrapper.put(segmentId, subsegmentListWrapperObj);
				
			} else {
				mapOfsubSegmentWrapper.put(null, subsegmentListWrapperObj);
			}
		}
		logger.logDebug('SegmentationWrapperAdapter.getSubsegments()----mapOfsubSegmentWrapper----' + mapOfsubSegmentWrapper);
		return mapOfsubSegmentWrapper;
	}
	
	public static List<PeopleLiteWrapper> getListOfManagers(List<People__c> managerList, Set<Id> usersIFollowIdSet, Set<Id> setOfMyFavouritePeopleId){
		List<PeopleLiteWrapper> managerWrapperList = new List<PeopleLiteWrapper>();
		
		if(!managerList.isEmpty()){
			for(People__c manager: managerList){
				PeopleLiteWrapper managerWrapper = new PeopleLiteWrapper();
				
			    managerWrapper.id =  manager.Id;
			    managerWrapper.peopleId =  manager.Id;
			    managerWrapper.userId =  manager.user__r.Id;
			    managerWrapper.sfUserId =  manager.user__r.Id;	    
				if(String.isNotBlank(Utility.buildName(manager.First_Name__c,manager.Last_Name__c))){
					managerWrapper.name = Utility.buildName(manager.First_Name__c,manager.Last_Name__c);
				}		
			    managerWrapper.nickname = manager.Community_Nickname__c;
				managerWrapper.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + manager.Id;
			    managerWrapper.img = manager.user__r.SmallPhotoURL.endsWith('005/T') ? null : manager.user__r.SmallPhotoURL;
			    managerWrapper.department = manager.Department__c;
			    managerWrapper.title = manager.Title__c;
			    managerWrapper.location = Utility.buildLocation(manager.City__c, manager.State__c, manager.Country__c);
			    managerWrapper.email = manager.Email__c;
			    managerWrapper.phone = manager.Phone__c;
			    managerWrapper.mobile = manager.mobile_phone__c;
			    managerWrapper.phoneExtension = manager.extension__c;
			    managerWrapper.about = manager.About__c;
			    managerWrapper.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(manager.Birth_Date__c,'MM-dd') : null;
				if(SimpplrContext.isPPJoiningDateDisplay && manager.Joining_Date__c != null && manager.Joining_Date__c < Date.today().addDays(-3)) {
					managerWrapper.hireDate = Utility.dateToDisplayString(manager.Joining_Date__c,'yyyy-MM-dd');
					managerWrapper.workAnniversary = Utility.dateToDisplayString(manager.Joining_Date__c,'MM-dd');
				}	
				managerWrapper.isFollowing = usersIFollowIdSet.contains(manager.User__c);	
				managerWrapper.isFavorited = setOfMyFavouritePeopleId.contains(manager.Id);	
				managerWrapper.isActive = manager.User__r.isactive;
				managerWrapper.canFollow = (UserContext.getCurrentUserInfo.Id == manager.Id) ? false : manager.User__r.isactive;				
				
				if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					managerWrapper.videoCallUsername = manager.Zoom_Id__c;
				} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					managerWrapper.videoCallUsername = manager.Skype_Id__c;
				}
				managerWrapper.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		managerWrapperList.add(managerWrapper); 
			}
		}
		return managerWrapperList;
		
	}
	
	public static List<SubscriptionWrapper> convertToSubscriptionWrapper(List<Subscription__c> subscriptionObjList) {
		List<SubscriptionWrapper> subscriptionWrapperList = new List<SubscriptionWrapper>();
		
		Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;
		Set<String> setOfActiveDirectoryGroups = new Set<String>();
		Map<String, Active_Directory_Group__c> adIdToADObjectMap = new Map<String, Active_Directory_Group__c>();
		

		Map<String, Integer> audienceCountMap = new Map<String, Integer>();
		Map<String, Integer> segIdAudienceCountMap = new Map<String, Integer>();
		for(Subscription__c subscriptionObj : subscriptionObjList){
			segIdAudienceCountMap.put(subscriptionObj.Audience__r.Segment__c, 0);
			audienceCountMap.put(subscriptionObj.Audience__c, 0);
			// For AD audiences
			Set<String> activeDirectoryGroupIds = ActiveDirectoryHelper.getActiveDirectoryGroupIds(subscriptionObj.Audience__r.Audience_Rule_Json__c);
			if(!activeDirectoryGroupIds.isEmpty()) {
				setOfActiveDirectoryGroups.addAll(activeDirectoryGroupIds);
			}
		}
		// For AD audiences
		if(!setOfActiveDirectoryGroups.isEmpty()) {
			adIdToADObjectMap = ActiveDirectoryHelper.getSelectedActiveDirectoryGroups(setOfActiveDirectoryGroups);
		}
		
		// prepare subscription vs audience count
		Set<String> audienceSet = audienceCountMap.keySet();
		
		String packageName = SimpplrContext.packageName;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceSet);
		String subscriptionAudienceCountQuery = 'SELECT audience__c audienceId, COUNT(id) FROM Audience_Member__c WHERE Audience__c IN :soqlParam1 AND User__r.isActive = true ';
		
		List<String> simpplrUserIdList = new List<String>(); 
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			soqlParamMap.put('soqlParam2', packageName);
			subscriptionAudienceCountQuery += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: soqlParam2)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			subscriptionAudienceCountQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			subscriptionAudienceCountQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		
		subscriptionAudienceCountQuery += ' GROUP BY Audience__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggResList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(subscriptionAudienceCountQuery, soqlParamMap);
		
		for(AggregateResult aggResObj : aggResList){
			audienceCountMap.put((String)aggResObj.get('audienceId'), (Integer)aggResObj.get('expr0'));
		}
		
		// prepare segment vs audience count
		Set<String> segmentIdSet = segIdAudienceCountMap.keySet();
		String segmentAudienceCountQuery = 'SELECT Segment__c segmentId, COUNT(id) FROM people__c WHERE Segment__c IN :segmentIdSet AND User__r.IsActive = true AND User__r.UserType = \'Standard\'';
		
		if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			segmentAudienceCountQuery += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
		if(Utility.isApiOnlyUserQueryable()){
			segmentAudienceCountQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			segmentAudienceCountQuery += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
		}
		
		
		segmentAudienceCountQuery += ' GROUP BY Segment__c';
		
		List<AggregateResult> segAggResList = Database.query(segmentAudienceCountQuery);
		for(AggregateResult aggResObj : segAggResList){
			segIdAudienceCountMap.put((String)aggResObj.get('segmentId'), (Integer)aggResObj.get('expr0'));
		}
		
		// prepare category id vs name map,IF AND ONLY IF people category in Enabled.
		Map<String, String> peopleCatIdVsNameMap = new Map<String, String>();
		
		if(SimpplrContext.isPeopleCategoryEnable) {
				String pCatQuery = 'SELECT Id, Name__c FROM People_Category__c WHERE'
													+ ' Is_Deleted__c = false LIMIT 5000';
																
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People_Category__c> peopelCategoryList = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, null);
			
			for (People_Category__c peopleCatObj : peopelCategoryList){
				peopleCatIdVsNameMap.put(peopleCatObj.Id, peopleCatObj.Name__c);
			}
		}
		
		// Pull all the accessible unlisted chatter groups for the Logged In user
		String unlistedGroupsQuery = 'SELECT Id FROM CollaborationGroup WHERE CollaborationType=\'Unlisted\'';
		if(SimpplrContext.isCommunitiesEnabled){
			unlistedGroupsQuery += ' AND NetworkId = null';
		}
		Map<Id, CollaborationGroup> unlistedCollaborationGroupMap = new Map<Id, CollaborationGroup>((List<CollaborationGroup>) Database.query(unlistedGroupsQuery));
		Set<String> groupsIOwnedIdSet = new Set<String>();
		Map<Id, CollaborationGroup> groupsIManagedMap = UserContext.groupsIManageMap;
		for(CollaborationGroup cGrpObj : groupsIManagedMap.values()){
			if(UserContext.id.equalsIgnoreCase(cGrpObj.OwnerId)){
				groupsIOwnedIdSet.add(cGrpObj.Id);
			}
		}
		
		SubscriptionWrapper subscriptionWrapperObj = null;
		for(Subscription__c subscriptionObj : subscriptionObjList){
			subscriptionWrapperObj = new SubscriptionWrapper();
			
			subscriptionWrapperObj.subscriptionId = subscriptionObj.Id;
			subscriptionWrapperObj.recipient = subscriptionObj.Recipient__c;
			subscriptionWrapperObj.membershipType = subscriptionObj.membership_Type__c;
			if('segment'.equalsIgnoreCase(subscriptionObj.Recipient__c)) {
				subscriptionWrapperObj.segment = convertToSegmenLiteWrapper(subscriptionObj, segIdAudienceCountMap.get(subscriptionObj.Audience__r.Segment__c));
				subscriptionWrapperObj.audience = new AudienceWrapper();
				subscriptionWrapperObj.audience.audienceId = subscriptionObj.Audience__c;
				subscriptionWrapperObj.audience.audienceCount = subscriptionWrapperObj.segment.audienceCount;
			} else if('everyone'.equalsIgnoreCase(subscriptionObj.Recipient__c)) {
				subscriptionWrapperObj.audience = getAudienceRuleForSubscription(subscriptionObj, audienceCountMap.get(subscriptionObj.Audience__c), peopleCatIdVsNameMap, adIdToADObjectMap);
			} else {
				subscriptionWrapperObj.audience = getAudienceRuleForSubscription(subscriptionObj, audienceCountMap.get(subscriptionObj.Audience__c), peopleCatIdVsNameMap, adIdToADObjectMap);
			}
			subscriptionWrapperObj.action = getSubscriptionAction(subscriptionObj, unlistedCollaborationGroupMap, groupsIOwnedIdSet);
			subscriptionWrapperObj.isLocked = false;
			if('Pending'.equalsIgnoreCase(subscriptionObj.Status__c)){
				subscriptionWrapperObj.isLocked = true;
			}
			
			subscriptionWrapperObj.createdAt = subscriptionObj.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			
			subscriptionWrapperObj.createdBy = new PeopleLiteWrapper();
		    subscriptionWrapperObj.createdBy.id = subscriptionObj.Created_By_People__c;
		    subscriptionWrapperObj.createdBy.peopleId = subscriptionObj.Created_By_People__c;
		    subscriptionWrapperObj.createdBy.userId = subscriptionObj.Created_By_People__r.user__r.Id;
		    subscriptionWrapperObj.createdBy.sfUserId = subscriptionObj.Created_By_People__r.user__r.Id;	    
			if(String.isNotBlank(Utility.buildName(subscriptionObj.Created_By_People__r.First_Name__c,subscriptionObj.Created_By_People__r.Last_Name__c))){
				subscriptionWrapperObj.createdBy.name = Utility.buildName(subscriptionObj.Created_By_People__r.First_Name__c,subscriptionObj.Created_By_People__r.Last_Name__c);
			}		
		    subscriptionWrapperObj.createdBy.nickname = subscriptionObj.Created_By_People__r.Community_Nickname__c;
			subscriptionWrapperObj.createdBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + subscriptionObj.Created_By_People__c;
		    subscriptionWrapperObj.createdBy.img = subscriptionObj.Created_By_People__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : subscriptionObj.Created_By_People__r.user__r.SmallPhotoURL;
		    subscriptionWrapperObj.createdBy.department = subscriptionObj.Created_By_People__r.Department__c;
		    subscriptionWrapperObj.createdBy.title = subscriptionObj.Created_By_People__r.Title__c;
		    subscriptionWrapperObj.createdBy.location = Utility.buildLocation(subscriptionObj.Created_By_People__r.City__c, subscriptionObj.Created_By_People__r.State__c, subscriptionObj.Created_By_People__r.Country__c);
		    subscriptionWrapperObj.createdBy.email = subscriptionObj.Created_By_People__r.Email__c;
		    subscriptionWrapperObj.createdBy.phone = subscriptionObj.Created_By_People__r.Phone__c;
		    subscriptionWrapperObj.createdBy.mobile = subscriptionObj.Created_By_People__r.mobile_phone__c;
		    subscriptionWrapperObj.createdBy.phoneExtension = subscriptionObj.Created_By_People__r.extension__c;
		    subscriptionWrapperObj.createdBy.about = subscriptionObj.Created_By_People__r.About__c;
		    subscriptionWrapperObj.createdBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(subscriptionObj.Created_By_People__r.Birth_Date__c,'MM-dd') : null;
			if(SimpplrContext.isPPJoiningDateDisplay && subscriptionObj.Created_By_People__r.Joining_Date__c != null && subscriptionObj.Created_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
				subscriptionWrapperObj.createdBy.hireDate = Utility.dateToDisplayString(subscriptionObj.Created_By_People__r.Joining_Date__c,'yyyy-MM-dd');
				subscriptionWrapperObj.createdBy.workAnniversary = Utility.dateToDisplayString(subscriptionObj.Created_By_People__r.Joining_Date__c,'MM-dd');
			}	
			subscriptionWrapperObj.createdBy.isFollowing = usersIFollowIdSet.contains(subscriptionObj.Created_By_People__r.User__c);	
			subscriptionWrapperObj.createdBy.isFavorited = setOfMyFavouritePeopleId.contains(subscriptionObj.Created_By_People__c);	
			subscriptionWrapperObj.createdBy.isActive = subscriptionObj.Created_By_People__r.User__r.isactive;
			subscriptionWrapperObj.createdBy.canFollow = (UserContext.getCurrentUserInfo.Id == subscriptionObj.Created_By_People__c) ? false : subscriptionObj.Created_By_People__r.User__r.isactive;		
			
			if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				subscriptionWrapperObj.createdBy.videoCallUsername = subscriptionObj.Created_By_People__r.Zoom_Id__c;
			} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				subscriptionWrapperObj.createdBy.videoCallUsername = subscriptionObj.Created_By_People__r.Skype_Id__c;
			}
			subscriptionWrapperObj.createdBy.videoCallProvider = SimpplrContext.PPVideoProvider;
			
			subscriptionWrapperObj.modifiedAt = subscriptionObj.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'); 
	
			subscriptionWrapperObj.modifiedBy = new PeopleLiteWrapper();
		    subscriptionWrapperObj.modifiedBy.id =  subscriptionObj.Modified_By_People__c;
		    subscriptionWrapperObj.modifiedBy.peopleId =  subscriptionObj.Modified_By_People__c;
		    subscriptionWrapperObj.modifiedBy.userId =  subscriptionObj.Modified_By_People__r.user__r.Id;
		    subscriptionWrapperObj.modifiedBy.sfUserId =  subscriptionObj.Modified_By_People__r.user__r.Id;
			if(String.isNotBlank(Utility.buildName(subscriptionObj.Modified_By_People__r.First_Name__c,subscriptionObj.Modified_By_People__r.Last_Name__c))){
				subscriptionWrapperObj.modifiedBy.name = Utility.buildName(subscriptionObj.Modified_By_People__r.First_Name__c,subscriptionObj.Modified_By_People__r.Last_Name__c);
			}	
		    subscriptionWrapperObj.modifiedBy.nickname = subscriptionObj.Modified_By_People__r.Community_Nickname__c;
			subscriptionWrapperObj.modifiedBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + subscriptionObj.Modified_By_People__c;
		    subscriptionWrapperObj.modifiedBy.img = subscriptionObj.Modified_By_People__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : subscriptionObj.Modified_By_People__r.user__r.SmallPhotoURL;
		    subscriptionWrapperObj.modifiedBy.department = subscriptionObj.Modified_By_People__r.Department__c;
		    subscriptionWrapperObj.modifiedBy.title = subscriptionObj.Modified_By_People__r.Title__c;
		    subscriptionWrapperObj.modifiedBy.location = Utility.buildLocation(subscriptionObj.Modified_By_People__r.City__c, subscriptionObj.Modified_By_People__r.State__c, subscriptionObj.Modified_By_People__r.Country__c);
		    subscriptionWrapperObj.modifiedBy.email = subscriptionObj.Modified_By_People__r.Email__c;
		    subscriptionWrapperObj.modifiedBy.phone = subscriptionObj.Modified_By_People__r.Phone__c;
		    subscriptionWrapperObj.modifiedBy.mobile = subscriptionObj.Modified_By_People__r.mobile_phone__c;
		    subscriptionWrapperObj.modifiedBy.phoneExtension = subscriptionObj.Modified_By_People__r.extension__c;
		    subscriptionWrapperObj.modifiedBy.about = subscriptionObj.Modified_By_People__r.About__c;
		    subscriptionWrapperObj.modifiedBy.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(subscriptionObj.Modified_By_People__r.Birth_Date__c,'MM-dd') : null;
			if(SimpplrContext.isPPJoiningDateDisplay && subscriptionObj.Modified_By_People__r.Joining_Date__c != null && subscriptionObj.Modified_By_People__r.Joining_Date__c < Date.today().addDays(-3)) {
				subscriptionWrapperObj.modifiedBy.hireDate = Utility.dateToDisplayString(subscriptionObj.Modified_By_People__r.Joining_Date__c,'yyyy-MM-dd');
				subscriptionWrapperObj.modifiedBy.workAnniversary = Utility.dateToDisplayString(subscriptionObj.Modified_By_People__r.Joining_Date__c,'MM-dd');
			}	
			subscriptionWrapperObj.modifiedBy.isFollowing = usersIFollowIdSet.contains(subscriptionObj.Modified_By_People__r.User__c);	
			subscriptionWrapperObj.modifiedBy.isFavorited = setOfMyFavouritePeopleId.contains(subscriptionObj.Modified_By_People__c);	
			subscriptionWrapperObj.modifiedBy.isActive = subscriptionObj.Modified_By_People__r.User__r.isactive;
			subscriptionWrapperObj.modifiedBy.canFollow = (UserContext.getCurrentUserInfo.Id == subscriptionObj.Modified_By_People__c) ? false : subscriptionObj.Modified_By_People__r.User__r.isactive;
		
			if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				subscriptionWrapperObj.modifiedBy.videoCallUsername = subscriptionObj.Modified_By_People__r.Zoom_Id__c;
			} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				subscriptionWrapperObj.modifiedBy.videoCallUsername = subscriptionObj.Modified_By_People__r.Skype_Id__c;
			}
			subscriptionWrapperObj.modifiedBy.videoCallProvider = SimpplrContext.PPVideoProvider;
			
			subscriptionWrapperList.add(subscriptionWrapperObj);
		}	
		
		return subscriptionWrapperList;
	}
	
	private static SubscriptionWrapper.SubscriptionAction getSubscriptionAction(Subscription__c subscriptionObj,
				Map<Id, CollaborationGroup> unlistedCollaborationGroupMap, Set<String> groupsIOwnedIdSet){
		List<Subscription_Entity__c> subscriptionEntityList = (List<Subscription_Entity__c>) subscriptionObj.Subscription_Entities__r;	
		
		SubscriptionWrapper.SubscriptionAction actionObj = new SubscriptionWrapper.SubscriptionAction();
		List<SubscriptionWrapper.SubscriptionSiteItem> listOfActionSites = new List<SubscriptionWrapper.SubscriptionSiteItem>();
		List<SubscriptionWrapper.SubscriptionPeopleItem> listOfActionPeople = new List<SubscriptionWrapper.SubscriptionPeopleItem>();
		SubscriptionWrapper.SubscriptionSiteItem actionSite = null;
		SubscriptionWrapper.SubscriptionPeopleItem actionPeople = null;
		
		for (Subscription_Entity__c subEntityObj : subscriptionEntityList) {
			
			if('Site'.equalsIgnoreCase(subscriptionObj.Type__c) && subEntityObj.isDeleted__c == false) {
				actionSite = convertSiteObjToSubscriptionActionItem(subEntityObj, unlistedCollaborationGroupMap, groupsIOwnedIdSet);
				listOfActionSites.add(actionSite);
				
			} else if('People'.equalsIgnoreCase(subscriptionObj.Type__c)) {
				actionPeople = convertPeopleObjToSubscriptionActionItem(subEntityObj);
				listOfActionPeople.add(actionPeople);
			}
		}
		
		actionObj.listOfPeople = listOfActionPeople;
		actionObj.listOfSites = listOfActionSites;
		actionObj.actionType = subscriptionObj.Action_Type__c;
		
		return actionObj;
	}
	
	private static AudienceWrapper getAudienceRuleForSubscription(Subscription__c subscriptionObj,
			Integer audienceCount, Map<String, String> peopleCatIdVsNameMap,
			Map<String, Active_Directory_Group__c> adIdToADObjectMap) {
		
		AudienceWrapper audienceWrapperObj = new AudienceWrapper();
		audienceWrapperObj.audienceCount = audienceCount;
		audienceWrapperObj.audienceId = subscriptionObj.Audience__c;
		audienceWrapperObj.name = subscriptionObj.Audience__r.Name__c;
		audienceWrapperObj.isDeleted = subscriptionObj.Audience__r.Is_Deleted__c;

		if(String.isNotBlank(subscriptionObj.Audience__c) && String.isNotBlank(subscriptionObj.Audience__r.Segment__c)) {
			audienceWrapperObj.segment = new AudienceWrapper.SegmentLiteWrapper();
			audienceWrapperObj.segment.id = subscriptionObj.Audience__r.Segment__c;
			audienceWrapperObj.segment.segmentId = subscriptionObj.Audience__r.Segment__c;
			audienceWrapperObj.segment.name = subscriptionObj.Audience__r.Segment__r.Name__c;

			audienceWrapperObj.segmentId = subscriptionObj.Audience__r.Segment__c;
		}

		String audienceRuleStr = subscriptionObj.Audience__r.Audience_Rule_Json__c;
		
		List<Map<String, Set<String>>> audienceRuleMapList = new List<Map<String, Set<String>>>();
		if(String.isNotBlank(audienceRuleStr)){
			audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(audienceRuleStr, Type.forName('List<Map<String, Set<String>>>'));
		}

		if(audienceRuleMapList != null && audienceRuleMapList.size() > 0 && audienceRuleMapList[0].containsKey('peopleId')) {
			audienceWrapperObj.listOfPeople = getAudiencePeopleList(subscriptionObj.Audience__c);
			audienceWrapperObj.type = 'people';
		}else if (audienceRuleMapList != null && audienceRuleMapList.size() > 0 && audienceRuleMapList[0].containsKey('csv')) {
			audienceWrapperObj.listOfFiles = new List<FileContentWrapper>();
			Set<String> fileNameSet = new Set<String>();
			fileNameSet.addAll(audienceRuleMapList[0].get('csv'));
			for(String fileName : fileNameSet) {
				FileContentWrapper fileContentwrapper = new FileContentWrapper();
				fileContentwrapper.title = fileName;
				audienceWrapperObj.listOfFiles.add(fileContentwrapper);		
			}
			audienceWrapperObj.type = 'csv';
		} else if(audienceRuleMapList != null && !audienceRuleMapList.isEmpty() && audienceRuleMapList[0].containsKey('aDGroupSet')) {
			// for AD audiences
			audienceWrapperObj.type = 'activeDirectoryGroups';
			audienceWrapperObj.listOfActiveDirectoryGroups = new List<AudienceWrapper.ADGroup>();
			Set<String> setOfActiveDirectoryGrpId = new Set<String>();
			setOfActiveDirectoryGrpId.addAll(audienceRuleMapList[0].get('aDGroupSet'));
			for (String aDGrpIdStr : setOfActiveDirectoryGrpId) {
				AudienceWrapper.ADGroup aDGroupWrapObj = new AudienceWrapper.ADGroup();
				Active_Directory_Group__c aDGroupObj = adIdToADObjectMap.get(aDGrpIdStr);
				aDGroupWrapObj.id = aDGrpIdStr;
				if(aDGroupObj != null) {
					aDGroupWrapObj.name = aDGroupObj.name__c;
					aDGroupWrapObj.email = aDGroupObj.Email__c;
	
					if (aDGroupObj.Mail_Enabled__c) {
						aDGroupWrapObj.groupTypes = new List<String> {'Unified'};
	
					} else {
						aDGroupWrapObj.groupTypes = new List<String>();
					}
				}
				audienceWrapperObj.listOfActiveDirectoryGroups.add(aDGroupWrapObj);
			}

		} else {
		
			List<AudienceWrapper.AudienceCondition> audienceConditionList = new List<AudienceWrapper.AudienceCondition>();
			for(Map<String, Set<String>> audienceRuleMap : audienceRuleMapList) {
				String conditionType = (new list<String>(audienceRuleMap.keySet()))[0];
				AudienceWrapper.AudienceCondition audienceConditionObj = new AudienceWrapper.AudienceCondition();
				
				audienceConditionObj.name = conditionType;
				audienceConditionObj.label = conditionType;
				
				List<AudienceWrapper.AudienceConditionValue> audienceConditionValuesList = new List<AudienceWrapper.AudienceConditionValue>();
				
				for(String valueStr : audienceRuleMap.get(conditionType)) {
					AudienceWrapper.AudienceConditionValue valueObj = new AudienceWrapper.AudienceConditionValue();
					
					valueObj.name = valueStr;
					valueObj.id = null;
					
					if('category'.equalsIgnoreCase(conditionType)){
						valueObj.name = peopleCatIdVsNameMap.get(valueStr);
						valueObj.id = valueStr;

					} else if('hireDateBefore'.equalsIgnoreCase(conditionType) || 'hireDateAfter'.equalsIgnoreCase(conditionType)) {
						valueObj.name = valueStr;
						valueObj.id = conditionType;
						audienceConditionObj.name = 'hireDate';
						audienceConditionObj.label = 'Hire date';

					}
					
					audienceConditionValuesList.add(valueObj);
				}
				
				audienceConditionObj.values = audienceConditionValuesList;
				
				audienceConditionList.add(audienceConditionObj);
			}
			audienceWrapperObj.listOfConditions = audienceConditionList;
			audienceWrapperObj.type = 'conditions';
		}
			
		return audienceWrapperObj;
	}

	private static List<PeopleLiteWrapper> getAudiencePeopleList(String audienceId) {
		List<PeopleLiteWrapper> audiencePeopleList = new List<PeopleLiteWrapper>();

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceId);
		String queryStr = 'SELECT Id, People__r.Id, People__r.Full_Name__c, People__r.User__c FROM Audience_Member__c WHERE Audience__c = :soqlParam1 LIMIT 5';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		for(Audience_Member__c audienceMemberObj : (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap)) {
			audiencePeopleList.add(toPeopleLiteWrapper(audienceMemberObj.People__r));
		}
		return audiencePeopleList;
	}

	private static PeopleLiteWrapper toPeopleLiteWrapper(People__c peopleObject) {
		PeopleLiteWrapper peopleLiteWrapperObj = new PeopleLiteWrapper();
		peopleLiteWrapperObj.id = peopleObject.Id;
		peopleLiteWrapperObj.peopleId = peopleObject.Id;
		peopleLiteWrapperObj.sfUserId = peopleObject.User__c;
		peopleLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObject.Id;
		peopleLiteWrapperObj.name = peopleObject.Full_Name__c;
		return peopleLiteWrapperObj;
	}
	
	public static SubscriptionWrapper.SubscriptionSiteItem convertSiteObjToSubscriptionActionItem(Subscription_Entity__c subEntityObj,
				Map<Id, CollaborationGroup> unlistedCollaborationGroupMap, Set<String> groupsIOwnedIdSet){
		SubscriptionWrapper.SubscriptionSiteItem subscriptionActionItem = new SubscriptionWrapper.SubscriptionSiteItem();
        subscriptionActionItem.subscriptionEntityId = subEntityObj.Id;
        subscriptionActionItem.item = siteLiteWrapperFromSubsEntity(subEntityObj, unlistedCollaborationGroupMap, groupsIOwnedIdSet);
        subscriptionActionItem.status = subEntityObj.Status__c;
        subscriptionActionItem.actionedBy = null;
        
        if(!'pending'.equalsIgnoreCase(subEntityObj.Status__c)){
        	subscriptionActionItem.actionedBy = peopleLiteWrapperFromSubsEntity(subEntityObj);
        }
        
		return subscriptionActionItem;
	}
	
	private static SiteLiteWrapper siteLiteWrapperFromSubsEntity(Subscription_Entity__c subEntityObj,
	 			Map<Id, CollaborationGroup> unlistedCollaborationGroupMap, Set<String> groupsIOwnedIdSet){
		SiteLiteWrapper siteWrapperObj = new SiteLiteWrapper();
        
        siteWrapperObj.siteId = subEntityObj.Site__c;
        siteWrapperObj.access = subEntityObj.Site__r.Site_Type__c;
		siteWrapperObj.isChatterGroupOnly = !subEntityObj.Site__r.Show_In_Simpplr__c;
	    siteWrapperObj.isActive = subEntityObj.Site__r.Is_Active__c;
	    siteWrapperObj.isMember = UserContext.chatterGroupsIFollowIdSet.contains(subEntityObj.Site__r.Chatter_Group_Id__c);
        siteWrapperObj.isOwner = groupsIOwnedIdSet.contains(subEntityObj.Site__r.Chatter_Group_Id__c);
        siteWrapperObj.isManager = UserContext.groupsIManageIdSet.contains(subEntityObj.Site__r.Chatter_Group_Id__c);
        
        // No need to send this info incase of unlisted sites that the loggedin user doesn't have access to.
        if(!'Unlisted'.equalsIgnoreCase(siteWrapperObj.access) || 
        		unlistedCollaborationGroupMap.containsKey(subEntityObj.Site__r.Chatter_Group_Id__c)){
        	siteWrapperObj.chatterGroupId = subEntityObj.Site__r.Chatter_Group_Id__c;
        	siteWrapperObj.name = subEntityObj.Site__r.Name;
	        siteWrapperObj.img = String.isBlank(subEntityObj.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(subEntityObj.Site__r.Title_Content_Version__c);
	        siteWrapperObj.imgThumbnail = String.isBlank(subEntityObj.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(subEntityObj.Site__r.Title_Content_Version__c);
	        siteWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + subEntityObj.Site__c + '/' + subEntityObj.Site__r.Landing_Page__c;
        }
        
        return siteWrapperObj;
	}
	
	private static PeopleLiteWrapper peopleLiteWrapperFromSubsEntity(Subscription_Entity__c subEntityObj){
		PeopleLiteWrapper peopleWrapperObj = new PeopleLiteWrapper();
        
        Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;
		
        peopleWrapperObj.id = subEntityObj.Action_By__c;
        peopleWrapperObj.peopleId = subEntityObj.Action_By__c;
        
	    peopleWrapperObj.userId = subEntityObj.Action_By__r.User__r.Id;
	    peopleWrapperObj.sfUserId = subEntityObj.Action_By__r.Id;
		if(String.isNotBlank(Utility.buildName(subEntityObj.Action_By__r.First_Name__c, subEntityObj.Action_By__r.Last_Name__c))){
			peopleWrapperObj.name = Utility.buildName(subEntityObj.Action_By__r.First_Name__c, subEntityObj.Action_By__r.Last_Name__c);
		}	
	    peopleWrapperObj.nickname = subEntityObj.Action_By__r.Community_Nickname__c;
		peopleWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + subEntityObj.Action_By__c;
	    peopleWrapperObj.img = Utility.getProfilePhotoURL(subEntityObj.Action_By__r.user__r.SmallPhotoURL);
	    peopleWrapperObj.department = subEntityObj.Action_By__r.Department__c;
	    peopleWrapperObj.title = subEntityObj.Action_By__r.Title__c;
	    peopleWrapperObj.location = Utility.buildLocation(subEntityObj.Action_By__r.City__c, subEntityObj.Action_By__r.State__c, subEntityObj.Action_By__r.Country__c);
	    peopleWrapperObj.email = subEntityObj.Action_By__r.Email__c;
	    peopleWrapperObj.phone = subEntityObj.Action_By__r.Phone__c;
	    peopleWrapperObj.mobile = subEntityObj.Action_By__r.mobile_phone__c;
	    peopleWrapperObj.phoneExtension = subEntityObj.Action_By__r.extension__c;
	    peopleWrapperObj.about = subEntityObj.Action_By__r.About__c;
	    peopleWrapperObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(subEntityObj.Action_By__r.Birth_Date__c,'MM-dd') : null;
		if(SimpplrContext.isPPJoiningDateDisplay && subEntityObj.Action_By__r.Joining_Date__c != null && subEntityObj.Action_By__r.Joining_Date__c < Date.today().addDays(-3)) {
			peopleWrapperObj.hireDate = Utility.dateToDisplayString(subEntityObj.Action_By__r.Joining_Date__c,'yyyy-MM-dd');
			peopleWrapperObj.workAnniversary = Utility.dateToDisplayString(subEntityObj.Action_By__r.Joining_Date__c,'MM-dd');
		}	
		peopleWrapperObj.isFollowing = usersIFollowIdSet.contains(subEntityObj.Action_By__r.User__c);	
		peopleWrapperObj.isFavorited = setOfMyFavouritePeopleId.contains(subEntityObj.Action_By__c);	
		peopleWrapperObj.isActive = subEntityObj.Action_By__r.User__r.isActive;
		peopleWrapperObj.canFollow = (UserContext.getCurrentUserInfo.Id == subEntityObj.Action_By__c) ? false : subEntityObj.Action_By__r.User__r.isActive;
		
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			peopleWrapperObj.videoCallUsername = subEntityObj.Action_By__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			peopleWrapperObj.videoCallUsername = subEntityObj.Action_By__r.Skype_Id__c;
		}
		peopleWrapperObj.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		return peopleWrapperObj;
	}
	
	public static SubscriptionWrapper.SubscriptionPeopleItem convertPeopleObjToSubscriptionActionItem(Subscription_Entity__c subEntityObj){
		SubscriptionWrapper.SubscriptionPeopleItem subscriptionActionItem = new SubscriptionWrapper.SubscriptionPeopleItem();
		PeopleLiteWrapper peopleWrapperObj = new PeopleLiteWrapper();
        
        Set<Id> usersIFollowIdSet = UserContext.usersIFollowIdSet;
		Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;
		
        peopleWrapperObj.id = subEntityObj.People__c;
        peopleWrapperObj.peopleId = subEntityObj.People__c;
        
	    peopleWrapperObj.userId = subEntityObj.People__r.User__r.Id;
	    peopleWrapperObj.sfUserId = subEntityObj.People__r.Id;
		if(String.isNotBlank(Utility.buildName(subEntityObj.People__r.First_Name__c, subEntityObj.People__r.Last_Name__c))){
			peopleWrapperObj.name = Utility.buildName(subEntityObj.People__r.First_Name__c, subEntityObj.People__r.Last_Name__c);
		}	
	    peopleWrapperObj.nickname = subEntityObj.People__r.Community_Nickname__c;
		peopleWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + subEntityObj.People__c;
	    peopleWrapperObj.img = Utility.getProfilePhotoURL(subEntityObj.People__r.user__r.SmallPhotoURL);
	    peopleWrapperObj.department = subEntityObj.People__r.Department__c;
	    peopleWrapperObj.title = subEntityObj.People__r.Title__c;
	    peopleWrapperObj.location = Utility.buildLocation(subEntityObj.People__r.City__c, subEntityObj.People__r.State__c, subEntityObj.People__r.Country__c);
	    peopleWrapperObj.email = subEntityObj.People__r.Email__c;
	    peopleWrapperObj.phone = subEntityObj.People__r.Phone__c;
	    peopleWrapperObj.mobile = subEntityObj.People__r.mobile_phone__c;
	    peopleWrapperObj.phoneExtension = subEntityObj.People__r.extension__c;
	    peopleWrapperObj.about = subEntityObj.People__r.About__c;
	    peopleWrapperObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(subEntityObj.People__r.Birth_Date__c,'MM-dd') : null;
		if(SimpplrContext.isPPJoiningDateDisplay && subEntityObj.People__r.Joining_Date__c != null && subEntityObj.People__r.Joining_Date__c < Date.today().addDays(-3)) {
			peopleWrapperObj.hireDate = Utility.dateToDisplayString(subEntityObj.People__r.Joining_Date__c,'yyyy-MM-dd');
			peopleWrapperObj.workAnniversary = Utility.dateToDisplayString(subEntityObj.People__r.Joining_Date__c,'MM-dd');
		}	
		peopleWrapperObj.isFollowing = usersIFollowIdSet.contains(subEntityObj.People__r.User__c);	
		peopleWrapperObj.isFavorited = setOfMyFavouritePeopleId.contains(subEntityObj.People__c);	
		peopleWrapperObj.isActive = subEntityObj.People__r.User__r.isActive;
		peopleWrapperObj.canFollow = (UserContext.getCurrentUserInfo.Id == subEntityObj.People__c) ? false : subEntityObj.People__r.User__r.isActive;		
		
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			peopleWrapperObj.videoCallUsername = subEntityObj.People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			peopleWrapperObj.videoCallUsername = subEntityObj.People__r.Skype_Id__c;
		}
		peopleWrapperObj.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		subscriptionActionItem.subscriptionEntityId = subEntityObj.Id;
		subscriptionActionItem.item = peopleWrapperObj;
		
		return subscriptionActionItem;
	}

}