public with sharing class ContentDataProvider {
    
    
    public List<ContentWrapper> getAlbumsSearchResults (Criteria.Album albumCriteriaObjArg) {
    	logger.logDebug('ContentDataProvider.getAlbumsSearchResults()----albumCriteriaObjArg----' + albumCriteriaObjArg);
		List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize;
		AlbumDao AlbumDaoObj = new AlbumDao();
		listOfSimpplrContent.addAll(albumDaoObj.getAlbumsSearchResults(albumCriteriaObjArg));
        List<ContentWrapper> listOfAlbumWrapper = new List<ContentWrapper>();
     	listOfAlbumWrapper = convertToContentWrapperList(listOfSimpplrContent);
     	logger.logDebug('ContentDataProvider.getAlbumsSearchResults()----listOfAlbumWrapper----' + listOfAlbumWrapper);
		return listOfAlbumWrapper; 
    }
    
    
	public List<ContentWrapper> getBlogsSearchResults (Criteria.Blog blogCriteriaObjArg) {
	    logger.logDebug('ContentDataProvider.getBlogsSearchResults()----blogCriteriaObjArg----' + blogCriteriaObjArg);
		List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
		
		List<Id> listOfUserId = new List<Id>(UserContext.usersIFollowIdSet);
		BlogDao blogDaoObj = new BlogDao();
		listOfSimpplrContent.addAll( blogDaoObj.getBlogsSearchResults(blogCriteriaObjArg));
        
        List<ContentWrapper> listOfBlogWrapper = new List<ContentWrapper>();
     	
     	listOfBlogWrapper = convertToContentWrapperList(listOfSimpplrContent);
     	logger.logDebug('ContentDataProvider.getBlogsSearchResults()----listOfBlogWrapper----' + listOfBlogWrapper);
		return listOfBlogWrapper;
	}
	
    public List<ContentWrapper> getEventsSearchResults (Criteria.Event eventCriteriaObjArg) {
    	logger.logDebug('ContentDataProvider.getEventsSearchResults()----eventCriteriaObjArg----' + eventCriteriaObjArg);
    	List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
		EventDao eventDaoObj = new EventDao();
		listOfSimpplrContent.addAll(eventDaoObj.getEventsSearchResults(eventCriteriaObjArg));
        List<ContentWrapper> listOfEventWrapper = new List<ContentWrapper>();
     	listOfEventWrapper = convertToContentWrapperList(listOfSimpplrContent);
     	logger.logDebug('ContentDataProvider.getEventsSearchResults()----listOfEventWrapper----' + listOfEventWrapper);
		return listOfEventWrapper;
    }

	public List<ContentWrapper> getEventDataFromSF (List<String> contentIds) {
    	logger.logDebug('ContentDataProvider.getEventDataFromSF()----contentIds----' + contentIds);
    	List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
		EventDao eventDaoObj = new EventDao();
		listOfSimpplrContent.addAll(eventDaoObj.getEventDataFromSF(contentIds));
        List<ContentWrapper> listOfEventWrapper = new List<ContentWrapper>();
     	listOfEventWrapper = convertToContentWrapperList(listOfSimpplrContent);
     	logger.logDebug('ContentDataProvider.getEventDataFromSF()----listOfEventWrapper----' + listOfEventWrapper);
		return listOfEventWrapper;
    }

    public List<ContentWrapper> getPagesSearchResults (Criteria.Pages pagesCriteriaObjArg) {
		logger.logDebug('ContentDataProvider.getPagesSearchResults()----pagesCriteriaObjArg----' + pagesCriteriaObjArg);
		List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
		PageDao pageDaoObj = new PageDao();
		
		listOfSimpplrContent.addAll( pageDaoObj.getPagesSearchResults(pagesCriteriaObjArg));
		
        List<ContentWrapper> listOfPagesWrapper = new List<ContentWrapper>();
     	listOfPagesWrapper = convertToContentWrapperList(listOfSimpplrContent);
     	logger.logDebug('ContentDataProvider.getPagesSearchResults()----listOfPagesWrapper----' + listOfPagesWrapper);
		return listOfPagesWrapper;
    }
    
    public static List<TileDataWrapper.TileData> getCustomTilesData(String siteId, TileDataWrapper.TileDataSettings tiledataSettings){
    	List<String> ListOfContentIds = new List<String>();
    	ListOfContentIds = tiledataSettings.value.split(',');
    	List<TileDataWrapper.TileData> listOfTileDataContent = new List<TileDataWrapper.TileData>();
    	AllContentDataServer dataServerObj = new AllContentDataServer();
		Map<Id, Simpplr_Content__c> mapOfContentObjects = dataServerObj.getCustomTilesData(siteId,ListOfContentIds);
		ContentToWrapperAdapter converterObj = new ContentToWrapperAdapter();
    	
		for(String contentId : ListOfContentIds) {
			Simpplr_Content__c contentObj = mapOfContentObjects.get(contentId);
			if(contentObj != null) {
				if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.type__c)) {
					listOfTileDataContent.add(converterObj.convertContentToTileDataWrapperPageContent(contentObj));
			    	
				} else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.type__c)) {
					listOfTileDataContent.add(converterObj.convertContentToTileDataWrapperEventContent(contentObj));
			    		
				} else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.type__c)) {
					listOfTileDataContent.add(converterObj.convertContentToTileDataWrapperAlbumContent(contentObj));
			    		
				} else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.type__c)) {
					listOfTileDataContent.add(converterObj.convertContentToTileDataWrapperBlogContent(contentObj));
			    		
				}
			}
		}
		return listOfTileDataContent;
    }
    public static List<TileDataWrapper.TileData> getLatestTileData(String siteId, String contentType, Integer recordLimit) {
    	AllContentDataServer dataServerObj = new AllContentDataServer();
    	
    	contentType = 'blog_post'.containsIgnoreCase(contentType) ? 'BlogPost' : contentType;

		Criteria.ContentSearchFilter criteriaObj = new Criteria.ContentSearchFilter();
		criteriaObj.offset = 0;
		criteriaObj.recordLimit = recordLimit;
		criteriaObj.siteId = siteID;
		criteriaObj.contentType = contentType;
		criteriaObj.excludeType = null;
		criteriaObj.searchText = null;
		criteriaObj.sortBy ='latest';
		criteriaObj.publishStartDateTime = null;
		criteriaObj.author = null;
		criteriaObj.maxAllowedEventEndDateTime = null;
		criteriaObj.isAllContent = false;
		criteriaObj.futureEventsOnly = true;

    	List<Simpplr_Content__c> listOfContents = dataServerObj.getLatestContentList(criteriaObj); 
    	
		List<TileDataWrapper.TileData> listOfLatestTileDataContent = new List<TileDataWrapper.TileData>();
	    ContentToWrapperAdapter converterObj = new ContentToWrapperAdapter();
	    for (Simpplr_Content__c contentObj : listOfContents) {
			if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.type__c)) {
				listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperPageContent(contentObj));
		    	
			} else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.type__c)) {
				listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperEventContent(contentObj));
		    		
			} else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.type__c)) {
				listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperAlbumContent(contentObj));
		    		
			} else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.type__c)) {
				listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperBlogContent(contentObj));
		    		
			}
	    }
	    
	    return listOfLatestTileDataContent;
    }
    
    public static List<TileDataWrapper.TileData> getPopularTileData(String siteId, String contentType, Integer recordLimit) {
    	AllContentDataServer dataServerObj = new AllContentDataServer();
    	contentType = 'blog_post'.containsIgnoreCase(contentType) ? 'BlogPost' : contentType;
    	List<Simpplr_Content__c> listOfContents = dataServerObj.getPopularContentList(siteId, contentType, null, 0, recordLimit, null, null, false); 
    	
    	List<TileDataWrapper.TileData> listOfLatestTileDataContent = new List<TileDataWrapper.TileData>();
    	ContentToWrapperAdapter converterObj = new ContentToWrapperAdapter();
	for (Simpplr_Content__c contentObj : listOfContents) {
	    	if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.type__c)) {
	    		listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperPageContent(contentObj));
	    	
	    	} else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.type__c)) {
	    		listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperEventContent(contentObj));
	    		
	    	} else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.type__c)) {
	    		listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperAlbumContent(contentObj));
	    		
	    	} else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.type__c)) {
	    		listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperBlogContent(contentObj));
	    		
	    	}
	    }
	    
	    return listOfLatestTileDataContent;
    }
    
    public static List<TileDataWrapper.TileData> getPagesWidgetData(String siteId, Integer recordLimit,String variant,String ids, String pageCategoryId){
		logger.logDebug('ContentDataProvider.getPagesWidgetData()----siteId----' + siteId+'----recordLimit----'+recordLimit);
		List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();  
		List<String> idList = new List<String>();
		Criteria.Pages pageCriteria = new Criteria.Pages();
		pageCriteria.term = null;
		pageCriteria.offset = 0;
		pageCriteria.size = recordLimit - 1;
		if('latest'.equalsIgnorecase(variant)) {
			pageCriteria.sortby = 'latest';
		} else if('popular'.equalsIgnorecase(variant)) {
			pageCriteria.sortby = 'Popular';
		} else if('from_Category'.equalsIgnorecase(variant)) {
			pageCriteria.sortby = 'DisplayOrder';
		}
		
		if(String.isNotBlank(ids)){
			idList = ids.split(',');
			pageCriteria.contentIdSet.addAll(idList);
		}
		if('Popular'.equalsIgnoreCase(variant) || 'Latest'.equalsIgnoreCase(variant)) {
			if('home'.equalsIgnoreCase(siteId) || 'home-default'.equalsIgnoreCase(siteId) || String.isBlank(siteId)) {
				pageCriteria.filter = 'following';
			} else {
				pageCriteria.siteId = siteId;
			}
		}
		pageCriteria.category = pageCategoryId;
		PageDao pageDaoObj = new PageDao();
		listOfSimpplrContent = pageDaoObj.getPagesSearchResults(pageCriteria);
		
		if('custom'.equalsIgnoreCase(variant) || 'favorites'.equalsIgnoreCase(variant)){
    		Map<Id,Simpplr_content__c> mapOfContentIdWithContent = new Map<Id,Simpplr_content__c>(listOfSimpplrContent);
    		List<Simpplr_content__c> listOfContentInOrder = new List<Simpplr_content__c>();
    		if(!idList.isEmpty()){
	    		for(String contentId : idList){
	    			if(mapOfContentIdWithContent.containsKey(contentId)){
	    				listOfContentInOrder.add(mapOfContentIdWithContent.get(contentId));
	    			}
	    		}
    		}
    		listOfSimpplrContent.clear();
    		listOfSimpplrContent.addAll(listOfContentInOrder);
    	}
		
		List<TileDataWrapper.TileData> listOfWidgetPageContent = new List<TileDataWrapper.TileData>();
	    TileDataWrapper.TileData pageContentObj;
	    ContentToWrapperAdapter converterObj = new ContentToWrapperAdapter();
	    for (Simpplr_Content__c contentObj : listOfSimpplrContent) {
	    	pageContentObj = converterObj.convertContentToTileDataWrapperPageContent(contentObj);
	    	listOfWidgetPageContent.add(pageContentObj);
	    }
	    logger.logDebug('ContentDataProvider.getPagesWidgetData()----listOfWidgetPageContent----' + listOfWidgetPageContent);
        return listOfWidgetPageContent;
    }
    
    public static List<PageListingWrapper.CategoryWrapper> getSitePagesGroupByCategories (Criteria.Pages pagesCriteriaObjArg) {
		logger.logDebug('ContentDataProvider.getSitePagesGroupByCategories()----pagesCriteriaObjArg----' + pagesCriteriaObjArg);
		Integer recordLimit = (pagesCriteriaObjArg.size == null ?  SimpplrContext.simpplrDefaultPageSize :pagesCriteriaObjArg.size) + 1; 
		
		PageDao pageDaoObj = new PageDao();
		List<Pages_Category__c> listOfPageCategories = pageDaoObj.getSitePagesGroupByCategory(pagesCriteriaObjArg, recordLimit);
		Map<String, PageListingWrapper.CategoryWrapper> mapOfCategoryPages = new Map<String, PageListingWrapper.CategoryWrapper>();
		List<String> listOfSimpplrContentIds = new List<String>();
		List<String> listOfPagesCategoriesIds = new List<String>();
		PageListingWrapper.CategoryWrapper categoryWrapperObj;
		Map<String,List<Simpplr_Content__c>> categoryToPagesMap = new Map<String,List<Simpplr_Content__c>>();
		for(Pages_Category__c pagesCategory : listOfPageCategories) {
			categoryWrapperObj = new PageListingWrapper.CategoryWrapper();
			categoryWrapperObj.id = pagesCategory.id;
			categoryWrapperObj.name = pagesCategory.Name__c;
			mapOfCategoryPages.put(categoryWrapperObj.id, categoryWrapperObj);
			
			listOfPagesCategoriesIds.add(pagesCategory.id);
			for(Simpplr_Content__c contentObj : pagesCategory.Simpplr_Content_Page_Category__r) {
				listOfSimpplrContentIds.add(contentObj.id);
			}
			categoryToPagesMap.put(pagesCategory.id,pagesCategory.Simpplr_Content_Page_Category__r);
		}
		
		List<Simpplr_Content__c> listOfSimpplrContents = pageDaoObj.getContentDetailsByIds(listOfSimpplrContentIds);
		
		Map<String,Simpplr_Content__c> contentMap = new Map<String,Simpplr_Content__c>(listOfSimpplrContents);
		Set<String> favoritePageSet = Utility.favouriteContentSet(listOfSimpplrContentIds);
		for(String categoryObj: categoryToPagesMap.keySet()){
			for(Simpplr_Content__c simpplrContentObj : categoryToPagesMap.get(categoryObj)){
				if (contentMap.get(simpplrContentObj.id)!=null && contentMap.containskey(simpplrContentObj.id) ) { 
				simpplrContentObj = contentMap.get(simpplrContentObj.id); 
				categoryWrapperObj = mapOfCategoryPages.get(categoryObj);
				PageListingWrapper articleWrapObj = new PageListingWrapper();
				articleWrapObj.id = simpplrContentObj.id;
				articleWrapObj.title = simpplrContentObj.title__c;
				articleWrapObj.type = simpplrContentObj.type__c;
				articleWrapObj.authoredBy = new PeopleLiteWrapper();
				articleWrapObj.authoredBy.id = simpplrContentObj.Primary_Author__r.User__c;
        		articleWrapObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + articleWrapObj.authoredBy.id;
        		articleWrapObj.authoredBy.peopleId = simpplrContentObj.Primary_Author__c;
				articleWrapObj.authoredBy.sfUserId = simpplrContentObj.Primary_Author__c;
				articleWrapObj.authoredBy.name = simpplrContentObj.Primary_Author__r.Full_Name__c;

				if (!simpplrContentObj.File_Simpplr_Content__r.isEmpty()) {

					List<File__c> titleFilesList = simpplrContentObj.File_Simpplr_Content__r;
					if(titleFilesList.size() > 0){
						AllContentDataServer dsObj = new AllContentDataServer();
						for(File__c fileObj : titleFilesList){
							if(fileObj.Is_Title_Image__c) {
								if(ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
									articleWrapObj.imgFile = dsObj.convertFileToFileContentWrapper(fileObj);
									articleWrapObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
									
								} 
								if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
									articleWrapObj.imgLandscapeFile = dsObj.convertFileToFileContentWrapper(fileObj);
									articleWrapObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
								}
							}
						}
					}
				}

				//Site
				if (!ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(simpplrContentObj.type__c)){
					articleWrapObj.site = new SiteLiteWrapper();
					articleWrapObj.site.siteId = simpplrContentObj.site__c;
					articleWrapObj.site.chatterGroupId = simpplrContentObj.site__r.Chatter_Group_Id__c;
					articleWrapObj.site.title = simpplrContentObj.site__r.Name;
					articleWrapObj.site.name = simpplrContentObj.site__r.Name;
					articleWrapObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + simpplrContentObj.site__c + '/' + simpplrContentObj.site__r.Landing_Page__c;
					articleWrapObj.site.imgContentDocumentId = simpplrContentObj.Site__r.Title_Content_Document__c;
					articleWrapObj.site.img = String.isBlank(simpplrContentObj.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(simpplrContentObj.site__r.Title_Content_Version__c);
					articleWrapObj.site.imgThumbnail = String.isBlank(simpplrContentObj.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor120BY90(simpplrContentObj.site__r.Title_Content_Version__c);
					articleWrapObj.site.access = simpplrContentObj.site__r.site_type__c;
					articleWrapObj.site.isActive = true;

					if('Unlisted'.equalsIgnoreCase(simpplrContentObj.site__r.Site_Type__c)) {
						articleWrapObj.site.isListed  = false;
					} else {
						articleWrapObj.site.isListed  = true;
					}
					
					if('Private'.equalsIgnoreCase(simpplrContentObj.site__r.Site_Type__c)) {
						articleWrapObj.site.isPrivate = true;
					} else {
						articleWrapObj.site.isPrivate = false;
					}

					if('Public'.equalsIgnoreCase(simpplrContentObj.site__r.Site_Type__c)) {
						articleWrapObj.site.isPublic = true;
					} else {
						articleWrapObj.site.isPublic  = false;
					}
				}

			    articleWrapObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+simpplrContentObj.site__c+'/page/'+simpplrContentObj.Id;
			    articleWrapObj.summary = String.isBlank(simpplrContentObj.Display_Excerpt__c)?'':simpplrContentObj.Display_Excerpt__c.unescapeHtml4();
			    articleWrapObj.isMustRead = simpplrContentObj.Is_Must_read__c;
			    if(simpplrContentObj.Must_Read_Confirm_History__r.isEmpty()){
		        	articleWrapObj.hasRead = false;
		        }else{
		        	articleWrapObj.hasRead = true;
		        }
			    if(favoritePageSet.contains(simpplrContentObj.id)){
			    	articleWrapObj.isFavorited = true;
			    } else {
			    	articleWrapObj.isFavorited = false;
			    }
			    if(simpplrContentObj.CreatedDate != null){
			    	articleWrapObj.createdAt = simpplrContentObj.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');//TBD
			    }
			    DateTime dateTimeValue = null;
			    String dateStringValue = String.valueOf(simpplrContentObj.Last_Edited_DateTime__c);
		        String publishedDateStringValue = String.valueOf(simpplrContentObj.Publish_Start_DateTime__c);
		        if(String.isNotBlank(dateStringValue)){
		        	if (String.isNotBlank(publishedDateStringValue) && simpplrContentObj.Last_Edited_DateTime__c.date() > simpplrContentObj.Publish_Start_DateTime__c.date()){
				        dateTimeValue = simpplrContentObj.Last_Edited_DateTime__c;
			    	    articleWrapObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			    	}else {
			    		articleWrapObj.modifiedAt = null;
			    	} 
		        }
			    if(simpplrContentObj.Publish_Start_DateTime__c != null){
			    	articleWrapObj.publishAt = simpplrContentObj.Publish_Start_DateTime__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');//TBD
			    }
				categoryWrapperObj.topPages.add(articleWrapObj);
				mapOfCategoryPages.put(categoryWrapperObj.id, categoryWrapperObj);
			} 
			}
		}
		
		List<AggregateResult> groupedResults = pageDaoObj.getContentCountsPerCategory(pagesCriteriaObjArg, listOfPagesCategoriesIds);
		for (AggregateResult ar : groupedResults) {
			String categoryId = (String) ar.get('categoryId');
			categoryWrapperObj = mapOfCategoryPages.get(categoryId);
			categoryWrapperObj.pageCount = (Integer) ar.get('expr0');
			mapOfCategoryPages.put(categoryWrapperObj.Id, categoryWrapperObj);
		}
		
		
		logger.logDebug('ContentDataProvider.getSitePagesGroupByCategories()----mapOfCategoryPages.values()----' + mapOfCategoryPages.values());
		return mapOfCategoryPages.values();
    }
    
    public List<ContentWrapper.PopularTopicsWrapper> getPopularTopics(Criteria.Pages pagesCriteriaObjArg){
    	
    	List<ContentWrapper.PopularTopicsWrapper> listOfPopularTopics = new List<ContentWrapper.PopularTopicsWrapper>();
    	ContentWrapper.PopularTopicsWrapper topicWrapper;
    	PageDao pageDaoObj = new PageDao();
    	List<AggregateResult> listOfTopics = pageDaoObj.getPopularTopic(pagesCriteriaObjArg.siteId, pagesCriteriaObjArg.category);
    	
    	
    	if(null != listOfTopics && listOfTopics.size()>0){
    		for(AggregateResult topicObj : listOfTopics){
    			topicWrapper = new ContentWrapper.PopularTopicsWrapper();
    			topicWrapper.id = (Id)(topicObj.get('topicId'));
    			topicWrapper.name = (String)(topicObj.get('topicName'));
    			topicWrapper.pageCount = (Integer)(topicObj.get('topicCount'));
    			listOfPopularTopics.add(topicWrapper);
    		}
    	}
    	
    	return listOfPopularTopics;
    }
    
    private List<ContentWrapper> convertToContentWrapperList(List<Simpplr_Content__c> simpplrContentList) {
    	List<ContentWrapper> contentWrapperList = new List<ContentWrapper>(); 
    	for(Simpplr_Content__c contentRecord : simpplrContentList) {
    		contentWrapperList.add(convertToContentWrapper(contentRecord));
    	}
    	return contentWrapperList;
    }
    
    private ContentWrapper convertToContentWrapper(Simpplr_Content__c contentRecord){
    	ContentWrapper wrapperObj = new ContentWrapper();
    	
    	List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		Set<String>  allowedFeaturesInAppSet = new  Set<String>();
		for(String feature : allowedFeaturesInAppList) {
	    	allowedFeaturesInAppSet.add(feature.toLowerCase());
	    }
	    wrapperObj.id = contentRecord.id; 
		wrapperObj.contentId = contentRecord.id; 
        if('BlogPost'.equalsIgnoreCase(contentRecord.Type__c)){
        	wrapperObj.type = 'blog_post';
        }else{
        	wrapperObj.type = contentRecord.Type__c;
        }
        wrapperObj.isTypeActive =  (allowedFeaturesInAppSet.contains(contentRecord.Type__c.toLowerCase()) && contentRecord.Activated_By_Feature__c == true) ? true : false;
		List<File__c> titleFilesList = contentRecord.File_Simpplr_Content__r;
        if(titleFilesList.size() > 0){
        	for(File__c fileObj : titleFilesList){
        		if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
        			if(fileObj.Is_Title_Image__c){
	        			if(String.isNotBlank(fileObj.Content_Version__c)) {
	        				wrapperObj.imgLandscape = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
	        				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);

							wrapperObj.imgFile = new FileContentWrapper();
							wrapperObj.imgFile.id = fileObj.Content_Document__c;
							
							wrapperObj.imgLandscapeFile = new FileContentWrapper();
							wrapperObj.imgLandscapeFile.id = fileObj.Content_Document__c;
        				} else {
        					wrapperObj.img = fileObj.Thumbnail_URL__c;
        					wrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;
        				}
	        			break;
	        		}
        		}else{
        			if(fileObj.Title_Image_Type__c == 'Thumbnail' && fileObj.Is_Title_Image__c){
        				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgFile = new FileContentWrapper();
						wrapperObj.imgFile.id = fileObj.Content_Document__c;
        				
	        		} else if(fileObj.Title_Image_Type__c == 'WideScreen' && fileObj.Is_Title_Image__c){
	        			wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgLandscapeFile = new FileContentWrapper();
						wrapperObj.imgLandscapeFile.id = fileObj.Content_Document__c;
	        		}
        		}
        	}
        }
        wrapperObj.imgCaption = String.isBlank(contentRecord.Title_Image_Caption__c) ? null : contentRecord.Title_Image_Caption__c;
        wrapperObj.imgLayout = contentRecord.Cover_Image_Layout__c;
        if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/page/'+contentRecord.Id;                                          

        } else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRecord.Primary_Author__c+'/blog/'+contentRecord.id;                                          

        } else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/event/'+contentRecord.Id;                                           

        } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/album/'+contentRecord.Id;                                           
        }
        wrapperObj.editUrl = wrapperObj.url + '/edit';
        
		wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, contentRecord.Title__c.length(), false);
        wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c)?'':contentRecord.Display_Excerpt__c.unescapeHtml4();
        
        wrapperObj.isPublished = contentRecord.Is_Published__c;
		if(contentRecord.Bookmarked_Content__r.size() > 0) {
        	wrapperObj.isFavorited = true;
        }else{
        	wrapperObj.isFavorited = false;
        }
		wrapperObj.isMustRead = contentRecord.Is_Must_Read__c;
        wrapperObj.isDeleted = contentRecord.Is_Deleted__c;
		if(contentRecord.Must_Read_Confirm_History__r.isEmpty()){
        	wrapperObj.hasRead = false;
        }else{
        	wrapperObj.hasRead = true;
        	DateTime dateTimeValue = null;
        	dateTimeValue = contentRecord.Must_Read_Confirm_History__r[0].Confirm_DateTime__c;
        }
		wrapperObj.favoriteContext = ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c)?'blog post':contentRecord.Type__c;
		wrapperObj.createdAt = contentRecord.createdDate == null ? '':Utility.dateToDisplayString(contentRecord.createdDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        wrapperObj.publishAt = contentRecord.Publish_Start_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Publish_Start_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.publishTo = contentRecord.Publish_End_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Publish_End_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.modifiedAt = contentRecord.Last_Edited_DateTime__c == null ? '':Utility.dateToDisplayString(contentRecord.Last_Edited_DateTime__c,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c)){

			TimeZone tz = Timezone.getTimeZone(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneIso = tz.getID();
            wrapperObj.timezoneOffset = tz.getOffset(system.today());

			wrapperObj.startsAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_Start_DateTime__c);
		    DateTime endDateTimeValue = contentRecord.Event_End_DateTime__c;
		    if('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
		    	endDateTimeValue = contentRecord.Event_End_DateTime__c.addMinutes(-1);
		    }
			wrapperObj.endsAt = Utility.dateTimeToMomentJSDateTime(endDateTimeValue);
			
		    wrapperObj.isAllDay = contentRecord.Event_Is_All_Day__c;
		    if(contentRecord.Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
		    	wrapperObj.isMultiDay = false;
		    }
		    else {
		    	wrapperObj.isMultiDay = true;
		    }
        }
        if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
        	wrapperObj.videoCount = Integer.valueOf(contentRecord.Album_Video_Count__c);
        	wrapperObj.imageCount = Integer.valueOf(contentRecord.Album_Image_Count__c);
        }
        if (contentRecord.Status__c != NULL){
        	if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentRecord.Status__c)){
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_PENDING;
        	} else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentRecord.Status__c)){
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_DRAFT.toLowerCase();
        	} else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(contentRecord.Status__c)){ 
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_REJECTED.toLowerCase();
        	} else if (contentRecord.Is_Published__c){
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_PUBLISH.toLowerCase();
        	} else if (contentRecord.Is_Unpublished__c){
        		wrapperObj.status = ServiceConstants.CONTENT_STATUS_UNPUBLISH.toLowerCase();
        	} else if (ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentRecord.Status__c)){
				wrapperObj.status = ServiceConstants.CONTENT_STATUS_APPROVED.toLowerCase();
			}
        }
         if('Page'.equalsIgnoreCase(contentRecord.Type__c) && String.isNotBlank(contentRecord.Pages_Category__c)) {
        	wrapperObj.category = new CategoryWrapper();
        	wrapperObj.category.id = contentRecord.Pages_Category__c;
        	wrapperObj.category.categoryId = contentRecord.Pages_Category__c;
        	wrapperObj.category.Name = contentRecord.Pages_Category__r.Name__c;
        	wrapperObj.category.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentRecord.Site__c + '/content&pageCategoryId=' + contentRecord.Pages_Category__c;
        }
        //Author 
        wrapperObj.authoredBy.id = contentRecord.Primary_Author__r.user__r.Id;
		wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
		wrapperObj.authoredBy.sfUserId = contentRecord.Primary_Author__r.user__r.Id;
		wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentRecord.Primary_Author__c;
		String nameForAuthor = Utility.buildName(contentRecord.Primary_Author__r.First_Name__c,contentRecord.Primary_Author__r.Last_Name__c);
		if(String.isNotBlank(nameForAuthor)){
			wrapperObj.authoredBy.name = nameForAuthor;
		}
		wrapperObj.authoredBy.img = contentRecord.Primary_Author__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : contentRecord.Primary_Author__r.user__r.SmallPhotoURL;
		wrapperObj.authoredBy.title = contentRecord.Primary_Author__r.Title__c;
		wrapperObj.authoredBy.isActive = contentRecord.Primary_Author__r.User__r.isactive;
		
		//Site
		if (!ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c)){
			wrapperObj.site = new SiteLiteWrapper();
			wrapperObj.site.siteId = contentRecord.site__c;
	    	wrapperObj.site.chatterGroupId = contentRecord.site__r.Chatter_Group_Id__c;
	    	wrapperObj.site.title = contentRecord.site__r.Name;
	    	wrapperObj.site.name = contentRecord.site__r.Name;
	    	wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentRecord.site__c + '/' + contentRecord.site__r.Landing_Page__c;
			wrapperObj.site.imgContentDocumentId = contentRecord.Site__r.Title_Content_Document__c;
			wrapperObj.site.img = String.isBlank(contentRecord.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor720By480(contentRecord.site__r.Title_Content_Version__c);
 			wrapperObj.site.imgThumbnail = String.isBlank(contentRecord.site__r.Title_Content_Version__c) ? null : Utility.getFileDownloadURLFor120BY90(contentRecord.site__r.Title_Content_Version__c);
			wrapperObj.site.access = contentRecord.site__r.site_type__c;
			wrapperObj.site.isActive = true;
			if('Unlisted'.equalsIgnoreCase(contentRecord.site__r.Site_Type__c)){
		 		wrapperObj.site.isListed  = false;
		 	} else {
		 		wrapperObj.site.isListed  = true;
		 	}
	    	
	    	if('Private'.equalsIgnoreCase(contentRecord.site__r.Site_Type__c)){
		 		wrapperObj.site.isPrivate = true;
		 	} else {
		 		wrapperObj.site.isPrivate = false;
		 	}
	    	if('Public'.equalsIgnoreCase(contentRecord.site__r.Site_Type__c)){
		 		wrapperObj.site.isPublic = true;
		 	} else {
		 		wrapperObj.site.isPublic  = false;
		 	}
		}
		
		if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c) && contentRecord.Event_RSVP_Allowed__c){
        		wrapperObj.rsvp					= new ContentWrapper.RsvpWrapper();
            wrapperObj.rsvp.noteLabel 		= contentRecord.Event_RSVP_Note__c ;
            wrapperObj.rsvp.capacityCount	= Integer.valueOf(contentRecord.Event_RSVP_Limit__c);
            	wrapperObj.rsvp.attendingCount 	= contentRecord.Event_Attending_Count__c != null && contentRecord.Event_Attending_Count__c > 0 ? 
        							  	  		  Integer.valueOf(contentRecord.Event_Attending_Count__c) : null;
		    	
	        if(contentRecord.Event_RSVP_Responses__r.isEmpty() == false) {
	        		Event_RSVP_Response__c rsvpResponse = contentRecord.Event_RSVP_Responses__r[0];
	    			wrapperObj.rsvp.noteValue = rsvpResponse.RSVP_Response_Text__c;
	    			wrapperObj.rsvp.respondedWith = rsvpResponse.RSVP_Response__c.toLowerCase();
	    		}
        }
        
    	return wrapperObj;
    }
	public Integer getContentCounts (Criteria.Pages pagesCriteriaObjArg) {
		logger.logDebug('ContentDataProvider.getContentCounts()----pagesCriteriaObjArg----' + pagesCriteriaObjArg);
		Integer contentCountsPerCategory = 0;	
		List<string> listOfCategoryIds = new List<string>();
		listOfCategoryIds.add(pagesCriteriaObjArg.category);
		PageDao pageDaoObj= new PageDao();
		List<AggregateResult> groupedResults;	
		groupedResults = pageDaoObj.getContentCountsPerCategory(pagesCriteriaObjArg, listOfCategoryIds);
		for (AggregateResult ar : groupedResults) {
			contentCountsPerCategory += (Integer) ar.get('expr0');
		}
		return contentCountsPerCategory;
	}    

	/**
     * @description This method is used to get AI Recommended Content Tile Data
     * @param peopleId 
     * @param recordLimit
     * @return  `List<TileDataWrapper.TileData>`
    */
    @TestVisible
	public static List<TileDataWrapper.TileData> getAIRecommendedContentTileData(String peopleId, Integer recordLimit) {
    	AllContentDataServer allContentDataServerObj = new AllContentDataServer();
		List<TileDataWrapper.TileData> listOfLatestTileDataContent = new List<TileDataWrapper.TileData>();
    	Set<String> contentIds = new Set<String>();
		contentIds = getAIContentRecommendations(new List<String>{peopleId}, 'tile', 15);
		if(!contentIds.isEmpty()){
			List<Simpplr_Content__c> listOfContents = allContentDataServerObj.getSortedContentList(contentIds, 15);//Sorted on score basis from AI
			ContentToWrapperAdapter converterObj = new ContentToWrapperAdapter();
			for (Simpplr_Content__c contentObj : listOfContents) {
				if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.type__c)) {
					listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperPageContent(contentObj));
				
				} else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.type__c)) {
					listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperEventContent(contentObj));
					
				} else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.type__c)) {
					listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperAlbumContent(contentObj));
					
				} else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.type__c)) {
					listOfLatestTileDataContent.add(converterObj.convertContentToTileDataWrapperBlogContent(contentObj));
					
				}
			}
		}
		return listOfLatestTileDataContent;
    }

	/**
     * @description This method is used to call topic-suggest lambda to get AI Content Recommendations 
     * @param peopleIds 
     * @param requestFrom 
     * @return  `Set<String>`
    */
    @TestVisible
	public static Set<String> getAIContentRecommendations(List<String> peopleIds, String requestFrom, Integer size) { 
		Map<String, Set<String>> peopleToContentIdsMap = new Map<String, Set<String>>();      
		Map<String, Object> requestBody = new Map<String, Object>();
		String externalEndPoint = SimpplrContext.simpplrAPIEndpoint + '/content/topic-suggest'; //Using topic-suggest endpoint for Page Recommendations as well
		requestBody.put('action', 'pageRecommendation');
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('peopleIds', peopleIds);
		requestBody.put('version', ServiceConstants.PAGE_RECOMMENDATION_API_VERSION);
		requestBody.put('topn', size); //for feed/tile recommendations limit is 15
		requestBody.put('source', requestFrom);

		HttpRequest req = new HttpRequest();
		req.setEndpoint(externalEndPoint);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('simpplr-dri', Utility.getSimpDri());
		req.setHeader('jwttoken', Utility.getJWTToken());
		req.setMethod('POST');
		req.setBody(Json.serialize(requestBody));
		Http http = new Http();

		HttpResponse httpresponseObj = http.send(req);
		logger.logDebug('ContentDataProvider.getAIContentRecommendations()----endpoint----' + externalEndPoint);
		logger.logDebug('ContentDataProvider.getAIContentRecommendations()----request body----' + requestBody);
        logger.logDebug('ContentDataProvider.getAIContentRecommendations()----response body----' + httpresponseObj.getBody());
		logger.logDebug('ContentDataProvider.getAIContentRecommendations()----response status code ----' + httpresponseObj.getStatusCode());
        if(httpresponseObj.getStatusCode() == 200) {
		String bodyStr = httpresponseObj.getBody();
			if(String.isNotBlank(bodyStr)) {
				Map<String, Object> resultBodyMap = ((Map<String, Object>) JSON.deserializeUntyped(bodyStr));
				peopleToContentIdsMap = processResponseBody(resultBodyMap);
			}
		}
		return peopleToContentIdsMap.containsKey(peopleIds[0]) ? peopleToContentIdsMap.get(peopleIds[0]) : new Set<String>(); //will remove get part once Emplay fix issue on API end
	}

	/**
     * @description This method is used to process Response Body
     * @param resultBodyMap 
     * @return  `Map<String, Set<String>>`
    */
    @TestVisible
	public static Map<String, Set<String>> processResponseBody(Map<String, Object> resultBodyMap) {
		Map<String, Set<String>> peopleToContentIdsMap = new Map<String, Set<String>>();
		Map<String, Object> resultsMap = (Map<String, Object>)resultBodyMap.get('content_recommendations');
		if(resultsMap.containsKey(UserContext.peopleId)){
			List<Object> recommendationsList = (List<Object>)resultsMap.get(UserContext.peopleId);
			Set<String> contentIds = new Set<String>();
			for(Object recommendationsObj : recommendationsList){
				Map<String, Object> recommendationmap = (Map<String, Object>) recommendationsObj;
				contentIds.add(((String) recommendationmap.get('Simpplr__Content__Id')));
			}
			peopleToContentIdsMap.put(UserContext.peopleId, contentIds);
		}
		return peopleToContentIdsMap;
    }
}