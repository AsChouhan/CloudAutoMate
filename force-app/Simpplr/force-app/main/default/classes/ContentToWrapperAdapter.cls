/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ContentToWrapperAdapter{
	
	/**
    **
    */
    private static Map<Id, CollaborationGroup> cGMap{
    	get {
	    	if(cGMap == null) {
	    		cGMap = Utility.getAllCollaborationGroupMap();
	    	}
	    	return cGMap;
         } private set;
    }
    
    /**
    **
    **/
    public static ContnetListingWrapper convertContentToContentLiteListingWrapper(Simpplr_Content__c contentObjArg){
    	ContnetListingWrapper wrapObj = new ContnetListingWrapper();
    	wrapObj.id = contentObjArg.Id;
    	wrapObj.contentType = contentObjArg.Type__c;
    	wrapObj.siteId = contentObjArg.Site__c;
    	wrapObj.relevancyScore = 0;
    	wrapObj.publishStartDateTimeInLong = contentObjArg.Publish_Start_DateTime__c.getTime();
    	return wrapObj;
    }
    
    public TileDataWrapper.TileData convertContentToTileDataWrapperPageContent(Simpplr_Content__c contentObjArg) {
    	TileDataWrapper.TileData pageWidgetWrapObj = new TileDataWrapper.TileData();
		pageWidgetWrapObj.title = contentObjArg.title__c;
		pageWidgetWrapObj.type = 'page';
		pageWidgetWrapObj.id = contentObjArg.id;
		pageWidgetWrapObj.contentId = contentObjArg.id;
		pageWidgetWrapObj.summary = String.isBlank(contentObjArg.Summary_1__c)?'':contentObjArg.Summary_1__c.unescapeHtml4();
		pageWidgetWrapObj.excerpt = String.isBlank(contentObjArg.Display_Excerpt__c)?'':contentObjArg.Display_Excerpt__c.unescapeHtml4();
		
		if('Public'.equalsIgnoreCase(contentObjArg.site__r.Site_Type__c)){
			pageWidgetWrapObj.isPrivate = false;
		} else {
			pageWidgetWrapObj.isPrivate = true;	
		}
		
		
		List<Must_Read_Audit__c> mRAList = contentObjArg.Must_Read_Audits__r;
		
		if ( mRAList != null &&  mRAList.isEmpty() == false && (mRAList[0].Expiry_DateTime__c == null || mRAList[0].Expiry_DateTime__c>DateTime.now()) && mRAList[0].Removed_DateTime__c == null) {
			pageWidgetWrapObj.isMustRead = true;
			Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
			mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;
			if(mRAList[0].Audience_Type__c == 'site_members') {
				Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentObjArg.Site__c);
				if(siteRoleForContentSite!= null && siteRoleForContentSite.Is_Member__c == true) {
					pageWidgetWrapObj.isMustRead = true;
				} else {
					pageWidgetWrapObj.isMustRead = false;
				}
			} else {
				pageWidgetWrapObj.isMustRead = true;
			}

		} else {
			pageWidgetWrapObj.isMustRead = false;
		}

        if(contentObjArg.Must_Read_Confirm_History__r.isEmpty()){
        	pageWidgetWrapObj.hasRead = false;
        }else{
        	pageWidgetWrapObj.hasRead = true;
        }
		pageWidgetWrapObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(pageWidgetWrapObj.type, contentObjArg.Is_Published__c, 
													contentObjArg.Site__r.Site_Type__c, contentObjArg.Site__r.Is_Must_Read_Enabled__c, 
													UserContext.sitesIManageIdSet.contains(contentObjArg.Site__c), UserContext.sitesIManageContentsIdSet.contains(contentObjArg.Site__c));
		pageWidgetWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentObjArg.Site__c+'/page/'+contentObjArg.id;
		
		DateTime dateTimeValue = null;
 	    String dateStringValue = String.valueOf(contentObjArg.Last_Edited_DateTime__c);
        String publishedDateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        if (String.isNotBlank(publishedDateStringValue) && contentObjArg.Last_Edited_DateTime__c.date() > contentObjArg.Publish_Start_DateTime__c.date()){
		        dateTimeValue = contentObjArg.Last_Edited_DateTime__c;
	    	    pageWidgetWrapObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		    	}else {
		    		pageWidgetWrapObj.modifiedAt = null;
		    	}
        }
        
        dateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.Publish_Start_DateTime__c;
    	    pageWidgetWrapObj.publishAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        dateStringValue = String.valueOf(contentObjArg.CreatedDate);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.CreatedDate;
    	    pageWidgetWrapObj.createdAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
		for(File__c fileObj : contentObjArg.File_Simpplr_Content__r) {
			if(fileObj.Is_Title_Image__c) {
				if(ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
					pageWidgetWrapObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c); 
					pageWidgetWrapObj.contentDocumentId = fileObj.Content_Document__c;	
					pageWidgetWrapObj.imgUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
        		
					
				}else if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
					pageWidgetWrapObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
					pageWidgetWrapObj.contentDocumentId = fileObj.Content_Document__c;
					pageWidgetWrapObj.imgLandscapeUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
        		
				}		
			}
		}
		pageWidgetWrapObj.status = getContentStatus(contentObjArg);
		pageWidgetWrapObj.category = new TileDataWrapper.Category();
	    	pageWidgetWrapObj.category.id = contentObjArg.Pages_Category__c;
	    	pageWidgetWrapObj.category.Name = contentObjArg.Pages_Category__r.Name__c;
	    	pageWidgetWrapObj.category.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentObjArg.Site__c + '/content&pageCategoryId=' + contentObjArg.Pages_Category__c;	    	
	    	//Author
	    pageWidgetWrapObj.authoredBy = convertToPeopleListWrapper(contentObjArg);
		
		//Site
		pageWidgetWrapObj.site = convertToSiteLiteWrapper(contentObjArg);
		
	    return pageWidgetWrapObj;
    }
    
    public TileDataWrapper.TileData convertContentToTileDataWrapperEventContent(Simpplr_Content__c contentObjArg) {
    	TileDataWrapper.TileData eventWidgetWrapObj = new TileDataWrapper.TileData();
    	
		eventWidgetWrapObj.title = contentObjArg.title__c;
		eventWidgetWrapObj.type = 'event';
		eventWidgetWrapObj.id = contentObjArg.id;
		eventWidgetWrapObj.contentId = contentObjArg.id;
		eventWidgetWrapObj.summary = String.isBlank(contentObjArg.Summary_1__c)?'':contentObjArg.Summary_1__c.unescapeHtml4();
		eventWidgetWrapObj.excerpt = String.isBlank(contentObjArg.Display_Excerpt__c)?'':contentObjArg.Display_Excerpt__c.unescapeHtml4();
		eventWidgetWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentObjArg.Site__c+'/event/'+contentObjArg.id;
		if('Public'.equalsIgnoreCase(contentObjArg.site__r.Site_Type__c)){
			eventWidgetWrapObj.isPrivate = false;
		} else {
			eventWidgetWrapObj.isPrivate = true;	
		}
		
		TimeZone tz = Timezone.getTimeZone(contentObjArg.Event_TimezoneSidKey__c);
		eventWidgetWrapObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentObjArg.Event_TimezoneSidKey__c);
		eventWidgetWrapObj.timezoneIso = tz.getID();
		eventWidgetWrapObj.timezoneOffset = tz.getOffset(system.today());

		String dateStringValue = String.valueOf(contentObjArg.Event_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        DateTime DateTimeValue = contentObjArg.Event_Start_DateTime__c;
    	    eventWidgetWrapObj.startsAt = DateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
		
		if(contentObjArg.Must_Read_Audits__r.isEmpty()){
        	eventWidgetWrapObj.isMustRead = false;
        }else{
        	eventWidgetWrapObj.isMustRead = true;
        }
        
		if(contentObjArg.Must_Read_Confirm_History__r.isEmpty()){
        	eventWidgetWrapObj.hasRead = false;
        }else{
        	eventWidgetWrapObj.hasRead = true;
        }
		eventWidgetWrapObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(eventWidgetWrapObj.type, contentObjArg.Is_Published__c, 
													contentObjArg.Site__r.Site_Type__c, contentObjArg.Site__r.Is_Must_Read_Enabled__c, 
													UserContext.sitesIManageIdSet.contains(contentObjArg.Site__c), UserContext.sitesIManageContentsIdSet.contains(contentObjArg.Site__c));
        DateTime endDateTimeValue = contentObjArg.Event_End_DateTime__c;
        if('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
        	endDateTimeValue = contentObjArg.Event_End_DateTime__c.addMinutes(-1);
        }
	    eventWidgetWrapObj.endsAt = endDateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
    	    
		eventWidgetWrapObj.isMultiDay = !contentObjArg.Event_Start_DateTime__c.isSameDay(endDateTimeValue);
		eventWidgetWrapObj.isAllDay = contentObjArg.Event_Is_All_Day__c;
		
		DateTime dateTimeValue = null;
		dateStringValue = String.valueOf(contentObjArg.Last_Edited_DateTime__c);
        String publishedDateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        if (String.isNotBlank(publishedDateStringValue) && contentObjArg.Last_Edited_DateTime__c.date() > contentObjArg.Publish_Start_DateTime__c.date()){
		        dateTimeValue = contentObjArg.Last_Edited_DateTime__c;
	    	    eventWidgetWrapObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	    	}else {
	    		eventWidgetWrapObj.modifiedAt = null;
	    	} 
        }
        
        dateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.Publish_Start_DateTime__c;
    	    eventWidgetWrapObj.publishAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        dateStringValue = String.valueOf(contentObjArg.CreatedDate);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.CreatedDate;
    	    eventWidgetWrapObj.createdAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
		for(File__c fileObj : contentObjArg.File_Simpplr_Content__r) {
			if(fileObj.Is_Title_Image__c) {
				if(ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
					eventWidgetWrapObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c); 
					eventWidgetWrapObj.contentDocumentId = fileObj.Content_Document__c;	
					eventWidgetWrapObj.imgUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';		
					
				}else if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
					eventWidgetWrapObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
					eventWidgetWrapObj.contentDocumentId = fileObj.Content_Document__c;
					eventWidgetWrapObj.imgLandscapeUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
        		
				}
			}
		}
		
		eventWidgetWrapObj.status = getContentStatus(contentObjArg);
		
		if(contentObjArg.Event_RSVP_Allowed__c) {
        		eventWidgetWrapObj.rsvp					= new RsvpWrapper();
            eventWidgetWrapObj.rsvp.capacityCount		= Integer.valueOf(contentObjArg.Event_RSVP_Limit__c);
            	eventWidgetWrapObj.rsvp.attendingCount 	= contentObjArg.Event_Attending_Count__c != null && contentObjArg.Event_Attending_Count__c > 0 ? 
        							  	  		  Integer.valueOf(contentObjArg.Event_Attending_Count__c) : null;
		}
		
		//Author
	    	eventWidgetWrapObj.authoredBy = convertToPeopleListWrapper(contentObjArg);
		//Site
		eventWidgetWrapObj.site = convertToSiteLiteWrapper(contentObjArg);
		
    	return eventWidgetWrapObj;
    }
    
    public TileDataWrapper.TileData convertContentToTileDataWrapperAlbumContent(Simpplr_Content__c contentObjArg) {
    	TileDataWrapper.TileData albumWidgetWrapObj = new TileDataWrapper.TileData();
		albumWidgetWrapObj.title = contentObjArg.title__c;
		albumWidgetWrapObj.type = 'album';
		albumWidgetWrapObj.id = contentObjArg.id;
		albumWidgetWrapObj.contentId = contentObjArg.id;
		albumWidgetWrapObj.summary = String.isBlank(contentObjArg.Summary_1__c)?'':contentObjArg.Summary_1__c.unescapeHtml4();
		albumWidgetWrapObj.excerpt = String.isBlank(contentObjArg.Display_Excerpt__c)?'':contentObjArg.Display_Excerpt__c.unescapeHtml4();
		albumWidgetWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentObjArg.Site__c+'/album/'+contentObjArg.id;
		if('Public'.equalsIgnoreCase(contentObjArg.site__r.Site_Type__c)){
			albumWidgetWrapObj.isPrivate = false;
		} else {
			albumWidgetWrapObj.isPrivate = true;	
		}
		DateTime dateTimeValue = null;

		if(contentObjArg.Must_Read_Audits__r.isEmpty()){
        	albumWidgetWrapObj.isMustRead = false;
        }else{
        	albumWidgetWrapObj.isMustRead = true;
        }

        if(contentObjArg.Must_Read_Confirm_History__r.isEmpty()){
        	albumWidgetWrapObj.hasRead = false;
        }else{
        	albumWidgetWrapObj.hasRead = true;
        }
        albumWidgetWrapObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(albumWidgetWrapObj.type, contentObjArg.Is_Published__c, 
													contentObjArg.Site__r.Site_Type__c, contentObjArg.Site__r.Is_Must_Read_Enabled__c, 
													UserContext.sitesIManageIdSet.contains(contentObjArg.Site__c), UserContext.sitesIManageContentsIdSet.contains(contentObjArg.Site__c));
 	    String dateStringValue = String.valueOf(contentObjArg.Last_Edited_DateTime__c);
        String publishedDateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        if (String.isNotBlank(publishedDateStringValue) && contentObjArg.Last_Edited_DateTime__c.date() > contentObjArg.Publish_Start_DateTime__c.date()){
		        dateTimeValue = contentObjArg.Last_Edited_DateTime__c;
	    	    albumWidgetWrapObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	    	}else {
	    		albumWidgetWrapObj.modifiedAt = null;
	    	} 
        }
        
        dateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.Publish_Start_DateTime__c;
    	    albumWidgetWrapObj.publishAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        dateStringValue = String.valueOf(contentObjArg.CreatedDate);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.CreatedDate;
    	    albumWidgetWrapObj.createdAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
		if (!contentObjArg.File_Simpplr_Content__r.isEmpty()) {
			
			
			for(File__c fileObj : contentObjArg.File_Simpplr_Content__r) {
				TileDataWrapper.AlbumImagesWrapper imagesWrapperObj = new TileDataWrapper.AlbumImagesWrapper();
				imagesWrapperObj.albumMediaId = fileObj.id;
				
				if (fileObj.MIME_Type__c == 'video') {
					imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
					imagesWrapperObj.img = fileObj.Thumbnail_URL__c;
				} else if(fileObj.Is_Title_Image__c){
    				if(String.isNotBlank(fileObj.Content_Document__c)){
    					imagesWrapperObj.contentDocumentId = fileObj.Content_Document__c;
    					imagesWrapperObj.imgUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
    					imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    					imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
				
    				} else {
    					imagesWrapperObj.imgUrl = fileObj.Thumbnail_URL__c;
    					imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    					imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
				
    				}
        		} else {
					imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
					imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
				}
				albumWidgetWrapObj.listOfTopAlbumImages.add(imagesWrapperObj);
			} 
			if(albumWidgetWrapObj.listOfTopAlbumImages.size() > 0) {
				albumWidgetWrapObj.img = albumWidgetWrapObj.listOfTopAlbumImages[0].img;
			}
		} 
		albumWidgetWrapObj.status = getContentStatus(contentObjArg);
		albumWidgetWrapObj.imageCount = Integer.valueOf(contentObjArg.Album_Image_Count__c);
    		albumWidgetWrapObj.videoCount = Integer.valueOf(contentObjArg.Album_Video_Count__c);
    		
    		//Author
	    	albumWidgetWrapObj.authoredBy = convertToPeopleListWrapper(contentObjArg);
		
		//Site
		albumWidgetWrapObj.site = convertToSiteLiteWrapper(contentObjArg);
		
    	return albumWidgetWrapObj;
    }
    
    public TileDataWrapper.TileData convertContentToTileDataWrapperBlogContent(Simpplr_Content__c contentObjArg) {
    	TileDataWrapper.TileData blogWidgetWrapObj = new TileDataWrapper.TileData();
		blogWidgetWrapObj.title = contentObjArg.title__c;
		blogWidgetWrapObj.type = 'blog_post';
		blogWidgetWrapObj.id = contentObjArg.id;
		blogWidgetWrapObj.contentId = contentObjArg.id;
		blogWidgetWrapObj.summary = String.isBlank(contentObjArg.Summary_1__c)?'':contentObjArg.Summary_1__c.unescapeHtml4();
		blogWidgetWrapObj.excerpt = String.isBlank(contentObjArg.Display_Excerpt__c)?'':contentObjArg.Display_Excerpt__c.unescapeHtml4();
		blogWidgetWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentObjArg.Primary_Author__c+'/blog/'+contentObjArg.id;
		
		DateTime dateTimeValue = null;
		
		if(contentObjArg.Must_Read_Audits__r.isEmpty()){
        	blogWidgetWrapObj.isMustRead = false;
        }else{
        	blogWidgetWrapObj.isMustRead = true;
        }

        if(contentObjArg.Must_Read_Confirm_History__r.isEmpty()){
        	blogWidgetWrapObj.hasRead = false;
        }else{
        	blogWidgetWrapObj.hasRead = true;
        }
        blogWidgetWrapObj.canMakeMustRead = contentObjArg.Is_Published__c && UserContext.isUserAppModerator;
 	    String dateStringValue = String.valueOf(contentObjArg.Last_Edited_DateTime__c);
        String publishedDateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        if (String.isNotBlank(publishedDateStringValue) && contentObjArg.Last_Edited_DateTime__c.date() > contentObjArg.Publish_Start_DateTime__c.date()){
		        dateTimeValue = contentObjArg.Last_Edited_DateTime__c;
	    	    blogWidgetWrapObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	    	}else {
	    		blogWidgetWrapObj.modifiedAt = null;
	    	} 
        }
        dateStringValue = String.valueOf(contentObjArg.Publish_Start_DateTime__c);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.Publish_Start_DateTime__c;
    	    blogWidgetWrapObj.publishAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        dateStringValue = String.valueOf(contentObjArg.CreatedDate);
        if(String.isNotBlank(dateStringValue)){
	        dateTimeValue = contentObjArg.CreatedDate;
    	    blogWidgetWrapObj.createdAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
		for(File__c fileObj : contentObjArg.File_Simpplr_Content__r) {
			if(fileObj.Is_Title_Image__c) {
				if(ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
					blogWidgetWrapObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c); 
					blogWidgetWrapObj.contentDocumentId = fileObj.Content_Document__c;	
					blogWidgetWrapObj.imgUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';

					
				}else if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
					blogWidgetWrapObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
					blogWidgetWrapObj.contentDocumentId = fileObj.Content_Document__c;
					blogWidgetWrapObj.imgLandscapeUrl = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
        		
				}
			}
		}
		blogWidgetWrapObj.status = getContentStatus(contentObjArg);
		
		//Author
	    	blogWidgetWrapObj.authoredBy = convertToPeopleListWrapper(contentObjArg);
		
    	return blogWidgetWrapObj;
    }
    
    private static String getContentStatus(Simpplr_Content__c contentRecord){
    	String status = '';
    	String contentStatus = contentRecord.Status__c;
    	if (contentStatus != NULL){
        	if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentStatus)){
        		status = ServiceConstants.CONTENT_STATUS_PENDING.toLowerCase();
        	} else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentStatus)){
        		status = ServiceConstants.CONTENT_STATUS_DRAFT.toLowerCase();
        	} else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(contentStatus)){ 
        		status = ServiceConstants.CONTENT_STATUS_REJECTED.toLowerCase();
        	} else if (contentRecord.Is_Published__c){
        		status = ServiceConstants.CONTENT_STATUS_PUBLISH.toLowerCase();
        	} else if (contentRecord.Is_Unpublished__c){
        		status = ServiceConstants.CONTENT_STATUS_UNPUBLISH.toLowerCase();
        	} else if (ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentStatus)){
				status = ServiceConstants.CONTENT_STATUS_APPROVED.toLowerCase();
			}
        }
        
        return status;
    }
    
    private SiteLiteWrapper convertToSiteLiteWrapper(Simpplr_Content__c contentObjArg) {
    		SiteLiteWrapper wrapperObj = new SiteLiteWrapper();
		wrapperObj.siteId = contentObjArg.site__c;
		wrapperObj.title = contentObjArg.site__r.Name;
		wrapperObj.isMember = UserContext.sitesIFollowIdSet.contains(wrapperObj.siteId);
	    wrapperObj.name = contentObjArg.site__r.Name;
	    wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentObjArg.site__c + '/' + contentObjArg.site__r.Landing_Page__c;
	    wrapperObj.img = String.isBlank(contentObjArg.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(contentObjArg.site__r.Title_Content_Version__c);
		wrapperObj.isActive = contentObjArg.site__r.Is_Active__c;
		wrapperObj.access = contentObjArg.site__r.site_type__c.toLowerCase();
		wrapperObj.imgContentDocumentId = contentObjArg.Site__r.Title_Content_Document__c;
		return wrapperObj;
    }
    
    private PeopleListWrapper convertToPeopleListWrapper(Simpplr_Content__c contentObjArg) {
    		PeopleListWrapper wrapperObj = new PeopleListWrapper();
        wrapperObj.id = contentObjArg.Primary_Author__c;
		wrapperObj.peopleId = contentObjArg.Primary_Author__c;
		wrapperObj.sfUserId = contentObjArg.Primary_Author__r.user__r.Id;
		wrapperObj.nickname = contentObjArg.Primary_Author__r.Community_Nickname__c;//TBD
		wrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentObjArg.Primary_Author__c;
		String nameForAuthor = Utility.buildName(contentObjArg.Primary_Author__r.First_Name__c,contentObjArg.Primary_Author__r.Last_Name__c);
		if(String.isNotBlank(nameForAuthor)){
			wrapperObj.name = nameForAuthor;
		}
		wrapperObj.img = contentObjArg.Primary_Author__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : contentObjArg.Primary_Author__r.user__r.SmallPhotoURL;
		wrapperObj.department = contentObjArg.Primary_Author__r.Department__c;
		wrapperObj.title = contentObjArg.Primary_Author__r.Title__c; 
		wrapperObj.location = Utility.buildLocation(contentObjArg.Primary_Author__r.City__c, contentObjArg.Primary_Author__r.State__c, contentObjArg.Primary_Author__r.Country__c);
		wrapperObj.email = contentObjArg.Primary_Author__r.Email__c;
		wrapperObj.phone = contentObjArg.Primary_Author__r.Phone__c;
		wrapperObj.mobile = contentObjArg.Primary_Author__r.mobile_phone__c;
		wrapperObj.phoneExtension = contentObjArg.Primary_Author__r.extension__c;
		wrapperObj.about = contentObjArg.Primary_Author__r.About__c;//TBD
		wrapperObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(contentObjArg.Primary_Author__r.Birth_Date__c,'MM-dd') : null;
		if(SimpplrContext.isPPJoiningDateDisplay && contentObjArg.Primary_Author__r.Joining_Date__c != null && contentObjArg.Primary_Author__r.Joining_Date__c < Date.today().addDays(-3)) {
			wrapperObj.hireDate = Utility.dateToDisplayString(contentObjArg.Primary_Author__r.Joining_Date__c,'yyyy-MM-dd');
		}
		
		if (UserContext.usersIFollowIdSet.contains(contentObjArg.Primary_Author__r.User__c)) {
	    		wrapperObj.isFollowing = true;
	    		
	    	} else {
	    		wrapperObj.isFollowing = false;
	    	}
    	
		wrapperObj.isActive = contentObjArg.Primary_Author__r.User__r.isactive;
		
		if (UserContext.getCurrentUserInfo.Id == contentObjArg.Primary_Author__c) {
			wrapperObj.canFollow = false;
			
		} else {
			wrapperObj.canFollow = contentObjArg.Primary_Author__r.User__r.isactive;
		}
		return wrapperObj;
    }
    
}