public with sharing class NewsletterV2DataAdapter {

    public List<PeopleLiteWrapper> convertToListOfPeopleLiteWrapper(List<People__c> listOfpeople) {
		List<PeopleLiteWrapper> peopleLiteWrapperList = new List<PeopleLiteWrapper>();

		for (People__c peopleObj : listOfpeople) {
			PeopleLiteWrapper peopleLiteWrapperObj = new PeopleLiteWrapper();
			peopleLiteWrapperObj = convertToPeopleLiteWrapper(peopleObj);
			peopleLiteWrapperList.add(peopleLiteWrapperObj);
		}

		return peopleLiteWrapperList; 
    }
    
    public PeopleLiteWrapper convertToPeopleLiteWrapper(People__c peopleObj) {
        PeopleLiteWrapper peopleLiteWrapperObj = new PeopleLiteWrapper();
        peopleLiteWrapperObj.id =  peopleObj.Id;
        peopleLiteWrapperObj.peopleId =  peopleObj.Id;
        peopleLiteWrapperObj.userId =  peopleObj.user__r.Id;
        peopleLiteWrapperObj.sfUserId =  peopleObj.user__r.Id;
        peopleLiteWrapperObj.segmentId = peopleObj.segment__c;
        if (String.isNotBlank(Utility.buildName(peopleObj.First_Name__c,peopleObj.Last_Name__c))){
            peopleLiteWrapperObj.name = Utility.buildName(peopleObj.First_Name__c,peopleObj.Last_Name__c);
        }	

        peopleLiteWrapperObj.nickname = peopleObj.Community_Nickname__c;
        peopleLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.Id;
        peopleLiteWrapperObj.img = peopleObj.user__r.FullPhotoUrl.endsWith('005/F') ? null : peopleObj.user__r.FullPhotoUrl;
        peopleLiteWrapperObj.department = peopleObj.Department__c;
        peopleLiteWrapperObj.title = peopleObj.Title__c;
        peopleLiteWrapperObj.location = Utility.buildLocation(peopleObj.City__c, peopleObj.State__c, peopleObj.Country__c);
        peopleLiteWrapperObj.email = peopleObj.Email__c;
        peopleLiteWrapperObj.phone = peopleObj.Phone__c;
        peopleLiteWrapperObj.mobile = peopleObj.mobile_phone__c;
        peopleLiteWrapperObj.phoneExtension = peopleObj.extension__c;
        peopleLiteWrapperObj.about = peopleObj.About__c;
        peopleLiteWrapperObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(peopleObj.Birth_Date__c,'MM-dd') : null;
        
        if (SimpplrContext.isPPJoiningDateDisplay && peopleObj.Joining_Date__c != null && peopleObj.Joining_Date__c < Date.today().addDays(-3)) {
            peopleLiteWrapperObj.hireDate = Utility.dateToDisplayString(peopleObj.Joining_Date__c,'yyyy-MM-dd');
            peopleLiteWrapperObj.workAnniversary = Utility.dateToDisplayString(peopleObj.Joining_Date__c,'MM-dd');
        }	

        TimeZone tz = Timezone.getTimeZone(peopleObj.User__r.TimeZoneSidKey);
		peopleLiteWrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(peopleObj.User__r.TimeZoneSidKey);
		peopleLiteWrapperObj.timezoneIso = tz.getID();
		peopleLiteWrapperObj.timezoneOffset = tz.getOffset(system.today());

        if (UserContext.usersIFollowIdSet.contains(peopleObj.User__c)) {
    		peopleLiteWrapperObj.isFollowing = true;
    		
    	} else {
    		peopleLiteWrapperObj.isFollowing = false;
    	}

        peopleLiteWrapperObj.isActive = peopleObj.User__r.isactive;
        return peopleLiteWrapperObj;
    }

    public List<SiteLiteWrapper> convertToListOfSiteLiteWrapper(List<Simpplr_Site__c> listOfSites, 
            Boolean includeMemberFollowerCount) {
		List<SiteLiteWrapper> siteLiteWrapperList = new List<SiteLiteWrapper>();

		for (Simpplr_Site__c siteObj : listOfSites) {
			SiteLiteWrapper siteLiteWrapperObj = new SiteLiteWrapper();
			siteLiteWrapperObj = convertToSiteLiteWrapper(siteObj);
			siteLiteWrapperList.add(siteLiteWrapperObj);
		}

        if (!listOfSites.isEmpty() && listOfSites.size() == 1 && includeMemberFollowerCount) {
            Criteria.Site siteCriteriaObj = new Criteria.Site();
            siteCriteriaObj.siteId = listOfSites[0].id;
            PeopleWrapper.peopleStatsWrapper statsObj = new PeopleWrapper.peopleStatsWrapper();
            statsObj = new siteContentProvider().getPeopleStats(siteCriteriaObj);
            siteLiteWrapperList[0].memberCount = statsObj.memberCount;
            siteLiteWrapperList[0].followerCount = statsObj.followerCount;
        }
        
		return siteLiteWrapperList; 
    }

    public SiteLiteWrapper convertToSiteLiteWrapper(Simpplr_Site__c siteObjArg) {
        SiteLiteWrapper siteWrapObj = new SiteLiteWrapper();
        siteWrapObj.siteId = siteObjArg.id;
        siteWrapObj.chatterGroupId = siteObjArg.Chatter_Group_Id__c;
        siteWrapObj.title = siteObjArg.Name;
        siteWrapObj.name = siteObjArg.Name;
        siteWrapObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObjArg.id + '/' + siteObjArg.Landing_Page__c;
        siteWrapObj.img = String.isBlank(siteObjArg.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(siteObjArg.Title_Content_Version__c);
        siteWrapObj.imgThumbnail = String.isBlank(siteObjArg.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor120BY90(siteObjArg.Title_Content_Version__c);
        siteWrapObj.isActive = siteObjArg.Is_Active__c;
        siteWrapObj.access = siteObjArg.site_type__c;
        siteWrapObj.isListed  = !'Unlisted'.equalsIgnoreCase(siteObjArg.Site_Type__c);
        return siteWrapObj; 
    }

    public List<AudienceWrapper.SegmentLiteWrapper> convertToListOfSegmentLiteWrapper(List<Segment__c> listOfSegments) {
        List<AudienceWrapper.SegmentLiteWrapper> listOfSegmentWrap = new List<AudienceWrapper.SegmentLiteWrapper>();
        
        for (Segment__c segmentObj: listOfSegments) {
            AudienceWrapper.SegmentLiteWrapper segmentWrapObj = new AudienceWrapper.SegmentLiteWrapper();
            segmentWrapObj.id = segmentObj.id;
            segmentWrapObj.name = segmentObj.name__c; 
            segmentWrapObj.segmentId = segmentObj.id; 
            listOfSegmentWrap.add(segmentWrapObj);

        }

        return listOfSegmentWrap; 
    }
		 		
}