public with sharing class MobileContentDataProvider {
	
    
    public List<Object> getAlbums(String term, String siteId, Integer offset, Integer recordLimit, String sortBy, Boolean isFullModel){
    		List<Simpplr_Content__c>albumList = (new MobileContentDao()).getAlbums(term, siteId, offset, recordLimit, sortBy);
    		
    		if(isFullModel){
				return generateListOfContentCacheWrap(albumList);
    		}else {
    			return getContentIDList(albumList);
    		}
    }
    
    public List<Object> getPages(String term, String siteId, Integer offset, Integer recordLimit, String sortBy, String categoryId, Boolean isFullModel){
    		List<Simpplr_Content__c>pageList = (new MobileContentDao()).getPages(term ,siteId, offset, recordLimit, sortBy, categoryId);
    		
    		if(isFullModel){
			return generateListOfContentCacheWrap(pageList);
    		}else {
    			return getContentIDList(pageList);
    		}
    }
    
    public List<Object> getBlogs(String term, String peopleId, Integer offset, Integer recordLimit, String sortBy, Boolean isFullModel){
    		List<Simpplr_Content__c>blogList = (new MobileContentDao()).getBlogs(term, peopleId, offset, recordLimit, sortBy);
    		
    		if(isFullModel){
				return generateListOfContentCacheWrap(blogList);
    		}else {
    			return getContentIDList(blogList);
    		}
    }
    
    public List<Object> getFavoriteContentList(String contentType, String searchText, Integer recordLimit, Integer offsetVal, Boolean isFullModel){
    		MobileContentDao mblContentDao = new MobileContentDao();
    		List<Bookmark__c>listOfBookmarks =  mblContentDao.getFavoriteContentList(contentType, searchText, recordLimit, offsetVal);
    		
    		List<Id> listOfContentIds = new List<Id>();
    		List<ContentCacheWrapper> contentCacheWrapperList = new List<ContentCacheWrapper>();
        	for(Bookmark__c bookmarkObj:listOfBookmarks) {
        		listOfContentIds.add(bookmarkObj.Simpplr_Content__c);
        	}
        	
    		if(isFullModel){
    			Map<Id, Simpplr_Content__c> contentMapObj = mblContentDao.getCacheContentById(new Set<Id>(listOfContentIds));
    			
    			if(!contentMapObj.isEmpty()){
	    			for(Bookmark__c bookmarkObj:listOfBookmarks) {
		        		contentCacheWrapperList.add(convertContentToWrapperForMobileCaching(contentMapObj.get(bookmarkObj.Simpplr_Content__c)));
		        	}
    			}
			return contentCacheWrapperList;
    		}else {
    			return listOfContentIds;
    		}
    }
    
    public List<Object> getEventOrganizers(String eventId, String siteId, Integer offset, Integer recordLimit, Boolean isFullModel, String sortBy){
    		List<Id> eventOrganizerIdList = new List<Id>();
    		List<Content_Collaborator__c> contentCollist = (new MobileContentDao()).getEventOrganizers(eventId, siteId, offset, recordLimit, sortBy);
    		for(Content_Collaborator__c conCollObj : contentCollist){
			eventOrganizerIdList.add(conCollObj.Collaborator__c);
		}
    		
    		if(isFullModel){
    			List<PeopleCacheWrapper> peopleWrapperList = new List<PeopleCacheWrapper>();
    			MobilePeopleDataProvider mbPeopleDataProviderObj = new MobilePeopleDataProvider();
    			Map<Id, People__c> mapOfPeople = (new MobilePeopleDao()).getAllPeople(new Set<Id>(eventOrganizerIdList));
    			for(Content_Collaborator__c conCollObj : contentCollist){
    			peopleWrapperList.add(mbPeopleDataProviderObj.convertToPeopleCacheWrapper(mapOfPeople.get(conCollObj.Collaborator__c)));
    			}
    			
    			return peopleWrapperList;
    		}
    		
    		return eventOrganizerIdList;
    }
    
    public List<ContentCacheWrapper> generateListOfContentCacheWrap(List<Simpplr_Content__c> contentObjList){
    		List<ContentCacheWrapper> contentCacheWrapperList = new List<ContentCacheWrapper>();
		for(Simpplr_Content__c contentRecord : contentObjList){
	    		contentCacheWrapperList.add(convertContentToWrapperForMobileCaching(contentRecord));
	    	}
    		return contentCacheWrapperList;
    }
    public List<String> getContentIDList(List<Simpplr_Content__c> contentObjList){
    		List<String> contentIdList = new List<String>();
		for(Simpplr_Content__c siteObj : contentObjList){
			contentIdList.add(siteObj.id);
		}
		return contentIdList;
    }
    
	public Map<String,List<Object>> getEventsMap(String term, String siteId, String peopleId, String filter, String period, Integer offset, Integer recordLimit, String sortBy, String nextPageToken, Boolean isFullModel) {
    		Map<String,List<Object>> eventMap = new Map<String,List<Object>>();
		MobileContentDao mobileContentDaoObj = new MobileContentDao();
        List<Simpplr_Content__c> listOfThisWeekEvent = new List<Simpplr_Content__c>();
    		List<Simpplr_Content__c> listOfThisMonthEvent = new List<Simpplr_Content__c>();
    		List<Simpplr_Content__c> listOfAfterMonthEvent = new List<Simpplr_Content__c>();
    		
    		if(String.isBlank(nextPageToken)) {
     		period = 'this_week';
     		listOfThisWeekEvent = mobileContentDaoObj.getEvents(term, siteId, peopleId, filter, period, offset, recordLimit, sortBy);

     		period = 'this_month';
     		listOfThisMonthEvent = mobileContentDaoObj.getEvents(term, siteId, peopleId, filter, period, offset, recordLimit, sortBy);
     		
     		period = 'after_this_month';
     		listOfAfterMonthEvent = mobileContentDaoObj.getEvents(term, siteId, peopleId, filter, period, offset, recordLimit, sortBy);
     		
    		} else if('this_week'.equalsIgnoreCase(period)){
     		listOfThisWeekEvent = mobileContentDaoObj.getEvents(term, siteId, peopleId, filter, period, offset, recordLimit, sortBy);
 		} else if('this_month'.equalsIgnoreCase(period)){
 			listOfThisMonthEvent = mobileContentDaoObj.getEvents(term, siteId, peopleId, filter, period, offset, recordLimit, sortBy);
 		} else if('after_this_month'.equalsIgnoreCase(period)) {
 			listOfAfterMonthEvent = mobileContentDaoObj.getEvents(term, siteId, peopleId, filter, period, offset, recordLimit, sortBy);
 		}
     	
     	if(isFullModel){
     		eventMap.put('thisWeekEvents',generateListOfContentCacheWrap(listOfThisWeekEvent));
     		eventMap.put('thisMonthEvents',generateListOfContentCacheWrap(listOfThisMonthEvent));
     		eventMap.put('laterEvents',generateListOfContentCacheWrap(listOfAfterMonthEvent));
 		}else {
 			eventMap.put('thisWeekEvents',getContentIDList(listOfThisWeekEvent));
     		eventMap.put('thisMonthEvents',getContentIDList(listOfThisMonthEvent));
     		eventMap.put('laterEvents',getContentIDList(listOfAfterMonthEvent));
 		}
		return eventMap;
    }
    
    public List<ContentCacheWrapper> getMustReadContentListForMobile(Integer offset, Integer recordLimit, String nextPageToken){
    		Map<String,List<Object>> mapOfMustReadContentList = new Map<String,List<Object>>();
        List<Object> contentList = new List<Object>();
        
        MobileContentDao mobileContentDaoObj = new MobileContentDao();
		List<Simpplr_Content__c> listOfAllContents = mobileContentDaoObj.getMustReadContentListForMobile(recordLimit, offset);        
		return generateListOfContentCacheWrap(listOfAllContents);		
    }
    
    public List<CategoryWrapper> getPageCategories (String term, String siteId, Integer offset, Integer recordLimit, String sortBy) {
		
		MobileContentDao mobileContentDaoObj = new MobileContentDao();
		
		List<String> listOfPagesCategoriesIds = new List<String>();
		Map<String, CategoryWrapper> mapOfCategoryPages = new Map<String,CategoryWrapper>();

		List<Pages_Category__c> listOfPageCategories = mobileContentDaoObj.getPageCategories(term, siteId, offset, recordLimit, sortBy);
		CategoryWrapper categoryWrapperObj;
		for(Pages_Category__c pagesCategory : listOfPageCategories) {
			categoryWrapperObj = new CategoryWrapper();
			categoryWrapperObj.categoryId = pagesCategory.id;
			categoryWrapperObj.categoryName = pagesCategory.Name__c;
			mapOfCategoryPages.put(categoryWrapperObj.categoryId, categoryWrapperObj);
			listOfPagesCategoriesIds.add(pagesCategory.id);
		}
		
		List<AggregateResult> groupedResults = mobileContentDaoObj.getContentCountsPerCategory(listOfPagesCategoriesIds, siteId);
		for (AggregateResult ar : groupedResults) {
			String categoryId = (String) ar.get('categoryId');
			if(mapOfCategoryPages.get(categoryId) != null){
				mapOfCategoryPages.get(categoryId).pageCount = (Integer) ar.get('expr0');
			}
		}
		return mapOfCategoryPages.values();
    }
	
	public ContentCacheWrapper convertContentToWrapperForMobileCaching (Simpplr_Content__c contentRecord) {
		ContentCacheWrapper wrapperObj = new ContentCacheWrapper(); 
		wrapperObj.contentId = contentRecord.id;
		wrapperObj.isDeleted = (contentRecord.Is_Deleted__c == null) ? false : contentRecord.Is_Deleted__c; 
        wrapperObj.type = contentRecord.Type__c;
        wrapperObj.isActivatedByFeature = contentRecord.Activated_by_feature__c;
        wrapperObj.isShowInSimpplrEnabled = contentRecord.Site__r.Show_In_Simpplr__c;
		wrapperObj.title = contentRecord.Title__c;
        wrapperObj.excerpt = contentRecord.Display_Excerpt__c;

		if (contentRecord.Must_Read_Audits__r.isEmpty() == false) {
			wrapperObj.isMustRead =true;
			
		} else {
			wrapperObj.isMustRead = false;
		}
		
		if(contentRecord.Must_Read_Confirm_History__r.isEmpty()){
    		wrapperObj.hasRead = false;
        }else{
        	wrapperObj.hasRead = true;
		}
		if(contentRecord.Content_Interactions__r.isEmpty()){
    		wrapperObj.hasSeen = false;
        }else{
        	wrapperObj.hasSeen = true;
		}
		wrapperObj.status = contentRecord.Status__c;
		if(contentRecord.Bookmarked_Content__r.size() > 0) {
			wrapperObj.isFavorited = true;
        }else{
    		wrapperObj.isFavorited = false;
        }
		wrapperObj.publishAt = contentRecord.Publish_Start_DateTime__c == null ? '':Utility.dateTimeStringInGMT(contentRecord.Publish_Start_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.publishTo = contentRecord.Publish_End_DateTime__c == null ? '':Utility.dateTimeStringInGMT(contentRecord.Publish_End_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.createdAt = contentRecord.CreatedDate == null ? '':Utility.dateTimeStringInGMT(contentRecord.CreatedDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.modifiedAt = contentRecord.Last_Edited_DateTime__c == null ? '':Utility.dateTimeStringInGMT(contentRecord.Last_Edited_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        
		if('Page'.equalsIgnoreCase(contentRecord.Type__c) && String.isNotBlank(contentRecord.Pages_Category__c)) {
	        	wrapperObj.categoryId = contentRecord.Pages_Category__c;
				wrapperObj.categoryName = contentRecord.Pages_Category__r.Name__c;
				
        } else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c)) {
			TimeZone tz = Timezone.getTimeZone(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneIso = tz.getID();
			wrapperObj.timezoneOffset = tz.getOffset(system.today());
			
			wrapperObj.startsAt = Utility.dateTimeStringInGMT(contentRecord.Event_Start_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		    DateTime endDateTimeValue = contentRecord.Event_End_DateTime__c;
		    if('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
		    	endDateTimeValue = contentRecord.Event_End_DateTime__c.addMinutes(-1);
		    }
		    wrapperObj.endsAt = Utility.dateTimeStringInGMT(endDateTimeValue,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		    wrapperObj.isAllDay = contentRecord.Event_Is_All_Day__c;
		    if(contentRecord.Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
		    	wrapperObj.isMultiDay = false;
		    }
		    else {
		    	wrapperObj.isMultiDay = true;
		    }
        }
		wrapperObj.authorId = contentRecord.Primary_Author__c;
		wrapperObj.authorName  = contentRecord.Primary_Author__r.Full_Name__c;
		if (!ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c)){
			wrapperObj.siteId = contentRecord.site__c; 
			wrapperObj.siteImgContentDocumentId = contentRecord.Site__r.Title_Content_Document__c;
	 	}
	 	
	 	List<File__c> titleFilesList = contentRecord.File_Simpplr_Content__r;
    	for(File__c fileObj : titleFilesList){
    		if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
    			if(fileObj.Is_Title_Image__c){
    				if(String.isNotBlank(fileObj.Content_Document__c)){
    					wrapperObj.contentDocumentId = fileObj.Content_Document__c;
    					wrapperObj.imgUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
    				} else {
    					wrapperObj.imgUrl = fileObj.Thumbnail_URL__c;
    				}
        			break;
        		}
    		}else if(fileObj.Is_Title_Image__c) {
    			if(ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
    				wrapperObj.contentDocumentId = fileObj.Content_Document__c;	
    				wrapperObj.imgUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
        		} else if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
        			wrapperObj.contentDocumentId = fileObj.Content_Document__c;
        			wrapperObj.imgLandscapeUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
        		}
    		}
    	}
        return wrapperObj;
	}
	public class CategoryWrapper{
		public String categoryId;
		public String categoryName;
		public Integer pageCount;
	}
}