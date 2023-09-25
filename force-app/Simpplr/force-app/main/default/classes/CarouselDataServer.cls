/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class CarouselDataServer extends DataServer{
	private ExternalAnalyticsService externalAnalyticsServiceObj = new ExternalAnalyticsService();
	public transient final String STR_ERROR_DUPLICATE_FLASH { get { return labelMap.get('carousel.add_item.duplicate_error_flash');}}
    @TestVisible private final String ACTION_VALUE_GET = 'get';
    @TestVisible private final String ACTION_VALUE_SAVEORDER = 'saveOrder';
    @TestVisible private final String ACTION_VALUE_SETLAYOUT = 'setLayout';
    @TestVisible private final String ACTION_VALUE_REMOVEITEM = 'removeItem';
    @TestVisible private final String ACTION_VALUE_REMOVE_CONTENT_ITEM = 'removeContentItem';
    @TestVisible private final String ACTION_VALUE_REMOVE_CAMPAIGN_ITEM = 'removeCampaignItem';
    @TestVisible private final String ACTION_VALUE_ADDITEM = 'addItem';
    @TestVisible private final String ACTION_VALUE_GETANALYTICS= 'getAnalytics';
    private final String REQUEST_PARAM_DATA = 'data';
    private final String REQUEST_PARAM_QUERY = 'query';
    @TestVisible private final String REQUEST_HOME_CARSOUSEL = 'home';
	private final Integer TOTAL_NUMBER_OF_CAROUSEL_TILES = 6;
    
    
    // Content status Constants
    public final String CONTENT_STATUS_REJECTED = 'Rejected';
    public final String CONTENT_STATUS_APPROVED = 'Approved';
    public final String CONTENT_STATUS_DRAFT = 'Draft';
    public final String CONTENT_STATUS_SUBMITTED = 'Submitted';
    public final String CONTENT_STATUS_INACTIVE = 'Inactive';
    public final String CONTENT_STATUS_PUBLISH = 'published';
    public final String CONTENT_STATUS_UNPUBLISH = 'unpublished';
    public final String CONTENT_STATUS_PENDING = 'pending';
    private String NO_PERMISSION = 'You do not have permission to perform this action';
    private static String loggedInUserId = UserContext.id;
    private static String loggedInPeopleId = UserContext.peopleId;
    private static Boolean isAppModerator = UserContext.isUserAppModerator;
    private static Set<Id> siteIManageIdSet = UserContext.sitesIManageIdSet;
	private Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
	private DateTime currentDateTime = DateTime.now();
    private List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
    private Set<String> allowedFeaturesInAppSet = new Set<String>();

	Private String mustReadSubCondition = UserContext.isUserAppModerator ? '' : ' And (Audience_Type__c=\'everyone\' OR Content__r.Site__c = :soqlParam1) ';
	
	@TestVisible
    private List<String> fieldList = New List<String>{'Is_Deleted__c','Display_Excerpt__c','Summary_1__c','Type__c','Title__c','Text_Main__c','Last_Edited_DateTime__c ', 
    													'Text_Main_Continued__c','Text_Intro__c','Status__c','Publish_Start_DateTime__c',
    													'Publish_End_DateTime__c', 'First_Publish_DateTime__c', 'Album_Image_Count__c','Album_Video_Count__c', 'Activated_By_Feature__c','Site__r.is_Active__c',
    													'Site__c','Site__r.name','Site__r.Landing_Page__c','Site__r.Chatter_Group_Id__c','Site__r.Site_Type__c','Site__r.Title_Content_Version__c',
													  	'Primary_Author__c','Primary_Author__r.Full_Name__c','Site__r.Is_Must_Read_Enabled__c',
													  	'Primary_Author__r.User__r.Id', 'Primary_Author__r.User__r.SmallPhotoUrl','Id',
													  	'CreatedDate','lastModifiedDate','Is_Published__c','Is_Unpublished__c',
													  	'Pages_Category__c', 'Pages_Category__r.Name__c',
													  	'Event_Is_All_Day__c','Event_Start_DateTime__c','Event_End_DateTime__c','Event_TimezoneSidKey__c',
														'(select  Audience_Type__c, Removed_DateTime__c, Expiry_DateTime__c, Must_Read_Confirm_Count__c from Must_Read_Audits__r where Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c > :soqlParam2) ' +  mustReadSubCondition + ' order by createddate desc limit 1)',
													  	'(Select Id, Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c = :soqlParam3 and Must_Read_Audit__r.Removed_DateTime__c=null) ',
														'(select id from Content_Interactions__r where People__c = :soqlParam4 )',
														'(SELECT Id, Content_Version__c, Content_Document__c, Is_Title_Image__c, Mime_Type__c, Title_Image_Type__c, Thumbnail_URL__c FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Location__c in (\'cover\' , \'media\') ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, Order__c desc LIMIT 4)'
	        										};
    
    public CarouselDataServer() {

    }

    public String getPageFeature() {
        return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest(){
    	
    	try {
        	logger.logDebug('CarouselDataServer----entered handleRequest----');
            
            String action = readParam(REQUEST_PARAM_ACTION);
            
            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }

            String dataJSON = readParam(REQUEST_PARAM_DATA);
            
			logger.logDebug('CarouselDataServer----dataJSON----' + dataJSON);
			Map<String, String> requestMap = new Map<String, String>();	
			if(!String.isEmpty(dataJSON)) {
				requestMap = (Map<String, String>)JSON.deserialize(dataJSON, Type.forName('Map<String, String>'));	
			}
			logger.logDebug('CarouselDataServer----requestMap----' + requestMap);
			
			String siteId = requestMap.get('siteId');
			String segmentId = requestMap.get('segmentId');
			Boolean isInAllSegments = false;
			if('true'.equalsIgnoreCase(requestMap.get('isInAllSegments'))){
				isInAllSegments = true;
			}
			SiteContext.siteId = siteId;

            if (ACTION_VALUE_GET.equalsIgnoreCase(action)) {
				response = carouselDataForDashboard(siteId, segmentId, false);
				
            } else {
	        	
	        	if (checkCarouselModerationAccess(siteId, segmentId) == false) {
	            		throw new SimpplrException(NO_PERMISSION);
	            }
	            
	            if (ACTION_VALUE_SAVEORDER.equalsIgnoreCase(action)) {
	                response = saveOrder(siteId, requestMap.get('orderOfItemIds'), segmentId);
	                
	            } else if (ACTION_VALUE_REMOVEITEM.equalsIgnoreCase(action)) {
	                response = removeItem(siteId, requestMap.get('carouselItemId'));
	            
	            } else if (ACTION_VALUE_REMOVE_CONTENT_ITEM.equalsIgnoreCase(action)) {
	                response = removeContentItem(siteId, requestMap.get('contentId'), segmentId, isInAllSegments);
	                
	            } else if (ACTION_VALUE_REMOVE_CAMPAIGN_ITEM.equalsIgnoreCase(action)) {
	                response = removeCampaignItem(siteId, segmentId, requestMap.get('campaignId'));
	                
	            } else if (ACTION_VALUE_ADDITEM.equalsIgnoreCase(action)) {
	            	response = addItem(siteId, segmentId, requestMap.get('type'), requestMap.get('model'), isInAllSegments);
	                
	            } else if (ACTION_VALUE_SETLAYOUT.equalsIgnoreCase(action)) {
	                response = setLayout(siteId, requestMap.get('layout'), segmentId,requestMap.get('governance'));
	                
	            } else if (ACTION_VALUE_GETANALYTICS.equalsIgnoreCase(action)) {
	                response = getAnalytics();
	                
	            } else {
	                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
	            }
	            
            }
            
        } catch (Exception ex) {
            logger.logError('Either no page access or action parameter returning wrong data',ex);  
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }

/**
 * @api {post} /apex/DataServerRW?target=CarouselDataServer&action=addItem addItem
 * @apiVersion 1.0.0
 * @apiGroup CarouselDataServer
 * @apiName addItem
 *
 * @apiParam (Query Parameter) {String} action addItem
 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#carousel-carousel.addItem" target="_blank">carousel-carousel.addItem</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Carousel.addItem
 * 2. This is used for adding content or embed model to the Carousel List
 * 
 * @apiSuccess {CarouselWrapper} result Contain OembedModel or ContentWrapper based on the itemType
 * @apiUse CarouselWrapperWITHIC
 * @apiUse ContentWrapper
 *
 * @apiError SimpplrException Simpplr Exception
 */
 	@TestVisible
 	private ResponseWrapper addItem (String siteId, String segmentId, String itemType, String modelData, Boolean isInAllSegments) {
        if (String.isBlank(modelData)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
     	ResponseWrapper resultWrapper = New ResponseWrapper();
     	
    	if (itemType.equalsIgnoreCase('content')) {
			
        	response = addContent(siteId, segmentId, modelData, isInAllSegments);
    	
    	} else if (itemType.equalsIgnoreCase('external')) {
    		response = addEmbedly(siteId, segmentId, modelData);
    	
    	} else if (itemType.equalsIgnoreCase('campaign')) {
    		response = addCampaign(siteId, segmentId, modelData);
    	
    	} else {
    		throw new SimpplrException(ExceptionCode.INVALID_TYPE.name());
    	}	
		CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
    	return response;
 	}
 	
    @TestVisible 
    private ResponseWrapper addContent (String siteId, String segmentId, String data, Boolean isInAllSegments) {
    	logger.logDebug('CarouselDataServer.addContent()----data----'+data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        
        try {
        	ContentWrapper requestObj = (ContentWrapper) Json.deserialize(data, ContentWrapper.class);
	        String contentId = String.isBlank(requestObj.contentId) ? '':requestObj.contentId;
	        
	        logger.logDebug('CarouselDataServer.addContent()----siteId----'+siteId);
	        logger.logDebug('CarouselDataServer.addContent()----contentId----'+contentId);
	        
	        if ((UserContext.isUserAppModerator && isInAllSegments) || !alreadyAddedToCarousel(contentId, segmentId, siteId)) {
	        	CarouselDao carouselDaoObj = new CarouselDao();
		        String carouselID = '';
				Simpplr_Content__c simCont = [SELECT Id,Title__c,Publish_Start_DateTime__c FROM Simpplr_Content__c WHERE Id =: contentId WITH SECURITY_ENFORCED LIMIT 1];
				CarouselWrapper wrapperObj = new CarouselWrapper();
				Map<String,String> requestDataMap = new Map<String,String>();
				requestDataMap.put('from',simCont.Publish_Start_DateTime__c.format('yyyy-MM-dd'));
				requestDataMap.put('to',Datetime.now().format('yyyy-MM-dd'));
				requestDataMap.put('contentId',contentId);
				requestDataMap.put('groupBy','day');
			
				AnalyticsWrapper.ContentWrapper contentWrapperObj = new AnalyticsWrapper.ContentWrapper(); 
				contentWrapperObj.data = (AnalyticsWrapper.ContentRelatedData) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getContentViews',null);
				if(contentWrapperObj.data != null) {
					wrapperObj.viewsOverTime = contentWrapperObj.data.viewsOverTime;
					wrapperObj.totalViews = contentWrapperObj.data.uniqueViewCount;
					wrapperObj.addedAt = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
					Integer totalPeopleCount = getPeopleCount();
					wrapperObj.viewedBy = contentWrapperObj.data.uniqueViewCount*100/totalPeopleCount;
				}
				if(UserContext.isUserAppModerator && isInAllSegments){
					carouselID = carouselDaoObj.addContentToCarouselForAllSegments(siteId, contentId, simCont.Title__c);
				} else {
					carouselID = carouselDaoObj.addContentToCarousel(siteId, segmentId, contentId,simCont.Title__c);
				}
				wrapperObj.order = 0;
				wrapperObj.itemType = 'content';
				wrapperObj.carouselItemId = carouselID;

				if (String.isBlank(siteId)) {
					requestObj.isInHomeCarousel = true;
					
				} else {
					requestObj.isInSiteCarousel = true;
				}
				
				wrapperObj.item = requestObj;
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content has been added!', wrapperObj);
	        
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_DUPLICATE_FLASH, null);
	        }
	        
	        logger.logDebug('CarouselDataServer.addContent()----resultWrapper----'+resultWrapper);
            return resultWrapper;
            
        } catch (Exception e) { 
        	logger.logError('CarouselDataServer.addContent()----Could not add content', e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	return resultWrapper;
        }	 
        
    }
    
    
    @TestVisible 
    private ResponseWrapper addCampaign(String siteId, String segmentId, String data){
    	logger.logDebug('CarouselDataServer.addCampaign()----data----'+data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        
        try {
        	
        	CampaignWrapper requestObj = (CampaignWrapper) Json.deserialize(data, CampaignWrapper.class);
        	if(String.isBlank(siteId)){
        		requestObj.isInHomeCarousel = true;
        	} else {
        		requestObj.isInHomeCarousel = false;
        	}
        	String campaignId = requestObj.campaignId;
	        
	        if (!alreadyAddedCampaignToCarousel(campaignId, segmentId, siteId)){
	        	
	        	CampaignService campServObj = new CampaignService();
	        	String carouselId = campServObj.addCampaignToCarousel(siteId, segmentId, campaignId);
				
				CarouselWrapper wrapperObj = new CarouselWrapper();
				wrapperObj.order = 0;
				wrapperObj.itemType = 'campaign';
				wrapperObj.carouselItemId = carouselId;
				wrapperObj.item = requestObj;
				wrapperObj.addedAt = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
	            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Campaign has been added!', wrapperObj);
	        
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_DUPLICATE_FLASH, null);
	        }
	        logger.logDebug('CarouselDataServer.addCampaign()----resultWrapper----'+resultWrapper);
            return resultWrapper;
            
        } catch (Exception e) { 
        	logger.logError('CarouselDataServer.addCampaign()----Could not add campaign', e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	return resultWrapper;
        }	 
        
    }
    
    @TestVisible 
    private ResponseWrapper addEmbedly(String siteId, String segmentId, String data){
    	logger.logDebug('CarouselDataServer.addEmbedly()----data----'+data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        
        try {
        	CarouselWrapper.OembedModel requestObj = (CarouselWrapper.OembedModel) Json.deserialize(data, 
        			CarouselWrapper.OembedModel.class);
	        
	        if (!alreadyAddedToCarousel(siteId, segmentId, requestObj.provider_url, requestObj.url)){
	        	CarouselDao carouselDaoObj = new CarouselDao();
	            Carousel_Content__c ccObj = new Carousel_Content__c();  
	            ccObj.Site__c = siteId;
	            if(String.isNotBlank(segmentId)) {
	            	ccObj.Segment__c = segmentId;
	            } else {
	            	ccObj.Segment__c = null;
	            }
	            ccObj.Embedly_Response_JSON__c = data;
	            ccObj.Item_Type__c = 'external';
	            ccObj.Created_by_People__c = UserContext.peopleId;

	            List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField> { 	Carousel_Content__c.Segment__c, 
	            																					Carousel_Content__c.Site__c,
	            																					Carousel_Content__c.Name, 
																									Carousel_Content__c.Created_by_People__c,
	            																					Carousel_Content__c.Embedly_Response_JSON__c, 
	            																					Carousel_Content__c.Item_Type__c};
	            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    		ccObj = (Carousel_Content__c) SIMPESAPI.accessController().insertAsUser(ccObj, listOfColumnsToBeSet);
    			carouselDaoObj.reArrangeCarouselRecords(siteId);
				CarouselWrapper wrapperObj = new CarouselWrapper();
				wrapperObj.order = 0;
				wrapperObj.itemType = 'external';
				wrapperObj.carouselItemId = ccObj.id;
				wrapperObj.item = requestObj;
				wrapperObj.addedAt = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
	            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
	            		'External Content has been added!', wrapperObj);
	        
	        } else {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR,  STR_ERROR_DUPLICATE_FLASH, null);
	        }
	        
	        logger.logDebug('CarouselDataServer.addEmbedly()----resultWrapper----'+resultWrapper);
            return resultWrapper;
            
        } catch (Exception e) { 
        	logger.logError('CarouselDataServer.addEmbedly()----Could not add content', e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	return resultWrapper; 
        }	 
        
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible 
    private Boolean alreadyAddedToCarousel (String contentId, String segmentId, String siteId) {
    	logger.logDebug('CarouselDataServer.alreadyAddedToCarousel()----contentId----'+contentId+'----siteId----'+siteId+'----segmentId----'+segmentId);
       
        if (REQUEST_HOME_CARSOUSEL.equalsIgnoreCase(siteId)) {
			siteId = null;
		}
		
        List<AggregateResult> groupedResults = database.query('SELECT count(Id) c FROM Carousel_Content__c WHERE Simpplr_Content__c =:contentId AND Is_Deleted__c = false AND Site__c = :siteId AND Segment__c = :segmentId');
		
		if (groupedResults != null && groupedResults.size() > 0 && Integer.valueOf(groupedResults[0].get('c')) > 0) {
			return true;
			
		} else {
			return false;
		}
		
    }
    
    @TestVisible 
    private Boolean alreadyAddedCampaignToCarousel (String campaignId, String segmentId, String siteId) {
    	logger.logDebug('CarouselDataServer.alreadyAddedCampaignToCarousel()----campaignId----'+campaignId+'----siteId----'+siteId+'----segmentId----'+segmentId);
       
        if (REQUEST_HOME_CARSOUSEL.equalsIgnoreCase(siteId)) {
			siteId = null;
		}
		
        List<AggregateResult> groupedResults = database.query('SELECT count(Id) c FROM Carousel_Content__c WHERE Social_Campaign__c  =:campaignId AND Is_Deleted__c = false AND Site__c = :siteId AND Segment__c = :segmentId');
		
		if (groupedResults != null && groupedResults.size() > 0 && Integer.valueOf(groupedResults[0].get('c')) > 0) {
			return true;
			
		} else {
			return false;
		}
		
    }
    
    @TestVisible 
    private Boolean alreadyAddedToCarousel (String siteId, String segmentId, String providerUrl, String url) {
    	logger.logDebug('CarouselDataServer.alreadyAddedToCarousel()----siteId----'+siteId+'----segmentId----'+segmentId+'----url----'+url+'----providerUrl----'+providerUrl);
        
        if (REQUEST_HOME_CARSOUSEL.equalsIgnoreCase(siteId)) {
			siteId = null;
		}
        
        for (Carousel_Content__c cc: [SELECT Id, Embedly_Response_JSON__c FROM Carousel_Content__c WHERE Site__c = :siteId AND Segment__c = :segmentId AND Is_Deleted__c = false AND Item_Type__c = 'external' WITH SECURITY_ENFORCED]) {
        	CarouselWrapper.OEmbedModel obj = (CarouselWrapper.OEmbedModel) JSON.deserialize(cc.Embedly_Response_JSON__c, CarouselWrapper.OEmbedModel.class);
        	
        	if (obj.url == url && obj.provider_url == providerUrl) {
        		return true;
        	}
        	
        }
		
		return false;
    }
    
/**
 * @api {post} /apex/DataServerRW?target=CarouselDataServer&action=saveOrder saveOrder
 * @apiVersion 1.0.0
 * @apiGroup CarouselDataServer
 * @apiName saveOrder
 *
 * @apiParam (Query Parameter) {String} action saveOrder
 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#carousel-carousel.saveOrder" target="_blank">carousel-carousel.saveOrder</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Carousel.saveOrder
 * 2. This is used for reordering the contents in the carousel
 * 
 * @apiSuccess {Null} Response.result Null
 *
 * @apiError SimpplrException Simpplr Exception
 */
    @TestVisible 
    private ResponseWrapper saveOrder (String siteId, String data, String segmentId) {
    	logger.logDebug('data - ' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper(); 
        Boolean isSuccess = false;
        
        if (data == null || String.isBlank(data)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }

		//Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(data);
		String dataString = data.substringBetween('[',']').replaceAll('"','');
       	List<String> ccIdList = dataString.split(',');
    	CarouselDao cdObj = new CarouselDao();
    	isSuccess = cdObj.updateOrder(siteId, ccIdList, segmentId);
    	
    	if (isSuccess) {
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Order has been updated!', null);
			CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
    	} else {
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}

        return resultWrapper;
    }
    
    /**
 * @api {post} /apex/DataServerRW?target=CarouselDataServer&action=setLayout setLayout
 * @apiVersion 1.0.0
 * @apiGroup CarouselDataServer
 * @apiName setLayout
 *
 * @apiParam (Query Parameter) {String} action setLayout
 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#carousel-carousel.setLayout" target="_blank">carousel-carousel.setLayout</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Carousel.setLayout
 * 2. This is used for reordering the contents in the carousel
 * 
 * @apiSuccess {Null} Response.result Null
 *
 * @apiError SimpplrException Simpplr Exception
 */
    @TestVisible 
    private ResponseWrapper setLayout (String siteId, String layout, String segmentId, String governance) {
    	logger.logDebug('caraouselDataServer.setLayout()---siteId ------------ ' + siteId);
    	logger.logDebug('caraouselDataServer.setLayout()---layout ------------ ' + layout);
    	logger.logDebug('caraouselDataServer.setLayout()---segmentId ------------ ' + segmentId);
    	logger.logDebug('caraouselDataServer.setLayout()---governance ------------ ' + governance);
        
        ResponseWrapper resultWrapper = New ResponseWrapper(); 
        try{
	        if (String.isBlank(layout)) {
	            throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
	    	CarouselDao cdObj = new CarouselDao();
	    	cdObj.setLayout(siteId, layout, segmentId, governance);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Layout has been set!', null);
        } catch(Exception ex){
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        return resultWrapper;
    }
    
/**
 * @api {post} /apex/DataServerRW?target=CarouselDataServer&action=removeContentItem removeContentItem
 * @apiVersion 1.0.0
 * @apiGroup CarouselDataServer
 * @apiName removeContentItem
 *
 * @apiParam (Query Parameter) {String} action removeItem
 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#carousel-carousel.removeitem" target="_blank">carousel-carousel.removeContentItem</a>   
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Carousel.removeItem
 * 2. This is used for remove the carousel item from home or selected site
 * 
 * @apiSuccess {Null} Response.result Null
 *
 * @apiError SimpplrException Simpplr Exception
 */
    @TestVisible 
    private ResponseWrapper removeContentItem (String siteId, String contentId, String segmentId, Boolean isInAllSegments) {
    	logger.logDebug('CarouselDataServer.removeItem()----contentId----'+contentId);
        ResponseWrapper resultWrapper = New ResponseWrapper(); 
        Boolean isSuccess = false;
        
        if (contentId == null || String.isBlank(contentId)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        
        //Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));

    	CarouselDao cdObj = new CarouselDao();
    	isSuccess = cdObj.removeContentItemFromCarousel(siteId, contentId, segmentId, isInAllSegments);
    	
    	if (isSuccess) {
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Carousel has beed deleted!', null);
			CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
    	} else {
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
        	
        logger.logDebug('CarouselDataServer.removeItem()----resultWrapper----'+resultWrapper);
        return resultWrapper;
    }
    
    /**
 * @api {post} /apex/DataServerRW?target=CarouselDataServer&action=removeCampaignItem removeCampaignItem
 * @apiVersion 1.0.0
 * @apiGroup CarouselDataServer
 * @apiName removeCampaignItem
 *
 * @apiParam (Query Parameter) {String} action removeItem
 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#carousel-carousel.removeitem" target="_blank">carousel-carousel.removeCampaignItem</a>   
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Carousel.removeItem
 * 2. This is used for remove the carousel item from home or selected site
 * 
 * @apiSuccess {Null} Response.result Null
 *
 * @apiError SimpplrException Simpplr Exception
 */
    @TestVisible 
    private ResponseWrapper removeCampaignItem (String siteId, String segmentId, String campaignId) {
    	logger.logDebug('CarouselDataServer.removeItem()----CampaignId----'+campaignId);
        ResponseWrapper resultWrapper = New ResponseWrapper(); 
        Boolean isSuccess = false;
        
        if (CampaignId == null || String.isBlank(CampaignId)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        try{
	    	CarouselDao cdObj = new CarouselDao();
	    	cdObj.removeCampaignItemFromCarousel(siteId, segmentId, CampaignId);
	    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Carousel has beed deleted!', null);
			CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
        } catch(Exception ex){
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
	    logger.logDebug('CarouselDataServer.removeCampaignItem()----resultWrapper----'+resultWrapper);
        return resultWrapper;
    }
    
/**
 * @api {post} /apex/DataServerRW?target=CarouselDataServer&action=removeItem removeItem
 * @apiVersion 1.0.0
 * @apiGroup CarouselDataServer
 * @apiName removeItem
 *
 * @apiParam (Query Parameter) {String} action removeItem
 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#carousel-carousel.removeitem" target="_blank">carousel-carousel.removeitem</a>   
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Carousel.removeItem
 * 2. This is used for remove the carousel item from home or selected site
 * 
 * @apiSuccess {Null} Response.result Null
 *
 * @apiError SimpplrException Simpplr Exception
 */
    @TestVisible 
    private ResponseWrapper removeItem (String siteId, String itemId) {
    	logger.logDebug('CarouselDataServer.removeItem()----itemId----'+itemId);
        ResponseWrapper resultWrapper = New ResponseWrapper(); 
        Boolean isSuccess = false;
        
        if (itemId == null || String.isBlank(itemId)) {
            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
        }
        //Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
    	CarouselDao cdObj = new CarouselDao();
    	isSuccess = cdObj.removeCarousel(itemId);
    	
    	if (isSuccess) {
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Carousel has beed deleted!', null);
			CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
    	} else {
    		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
    	}
        	
        logger.logDebug('CarouselDataServer.removeItem()----resultWrapper----'+resultWrapper);
        return resultWrapper;
    }
    
/**
 * @api {post} /apex/DataServerRW?target=CarouselDataServer&action=get get
 * @apiVersion 1.0.0
 * @apiGroup CarouselDataServer
 * @apiName get
 *
 * @apiParam (Query Parameter) {String} action get
 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#carousel-carousel.get" target="_blank">carousel-carousel.get</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Carousel.get
 * 2. This is used for retrieving the carousel items for home or for specific site
 * 
 * @apiSuccess {List[CarouselWrapper]} Response.listOfItems Item will contain OembedModel or ContentWrapper based on the itemType
 * @apiSuccess {String} Response.siteId ID of the Site this Carousel is for (null for Home Carousel)
 * @apiUse CarouselWrapperWITHIC
 * @apiUse ContentWrapper
 *
 * @apiError SimpplrException Simpplr Exception
 */
    public ResponseWrapper carouselDataForDashboard (String siteId, String segmentId, Boolean isMobileOrigin) {
		logger.logDebug('CarouselDataServer.carouselDataForDashobard----siteId----'+siteId+'----segmentId----'+segmentId);
        ResponseWrapper resultWrapper = New ResponseWrapper();
			try{
			if(String.isNotBlank(siteId)) {
				if(!SiteContext.isActive) {
					throw new SimpplrException(ServiceConstants.ERROR_404);
			
				} else if(!AccessManager.hasSiteAccess()) {
					SiteDetailWrapper sdWrapperObj = new MobileSiteDataProvider().getSiteMembership(siteId);
					resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.ERROR_403, sdWrapperObj);
					return resultWrapper;
				}
			}
			if('mobile'.equalsIgnoreCase(readParam('origin')) && String.isBlank(siteId) && SimpplrContext.isSegmentsEnabled){
				segmentId = UserContext.segmentId;
			}
			
			Map<String,Object> result = New Map<String,Object>();
			result.put('governance', 'disable');
            Boolean isCarouselGovernanceEnabled = false;
			if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(segmentId)){
				Map<String, Object> soqlParamMap1 = new  Map<String, Object>();
				soqlParamMap1.put('soqlParam1', segmentId);
				String query =  'Select id, Carousel_Layout__c,Carousel_Governance__c from Segment__c Where Id=:soqlParam1 limit 1';		
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Segment__c> segmentList = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap1);
				Segment__c segObj = segmentList[0];
				if(segObj.Carousel_Governance__c && SimpplrContext.carouselGovernance) {
					result.put('governance', 'enable');
					isCarouselGovernanceEnabled = true;
				}
				result.put('layout', segObj.Carousel_Layout__c);
			} else if(String.isNotBlank(siteId)){
				result.put('layout', SiteContext.carouselLayout);
			} else {
				if(SimpplrContext.carouselGovernance) {
					result.put('governance', 'enable');
					isCarouselGovernanceEnabled = true;
				} 
				result.put('layout', SimpplrContext.carouselLayout);
			}

			Boolean isHomeAppManagerControlled = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode);
			String orgCacheCarouselDataStr = '';
			Boolean cacheCarousel = true;
			Boolean isAiRecommendationAndGovernanceEnabled = SimpplrContext.aiContentRecommendationEnabled && String.isBlank(siteId) && isCarouselGovernanceEnabled;

			if(SimpplrContext.isKitaPSARChangesEnabled && isHomeAppManagerControlled && !isAiRecommendationAndGovernanceEnabled){

				Map<String,Object> result1 = New Map<String,Object>();
				String cacheName = 'cacheCarousel';
				if(String.isBlank(siteId)){
					cacheName = cacheName+'Home';
				}else{
					cacheName = cacheName + 'Site'+siteId;
				}
				if(isMobileOrigin){
					cacheName += 'Mobile';
				}
				orgCacheCarouselDataStr = 'Local.Cache.'+cacheName;
				if(!String.isBlank(SimpplrContext.namespacePrefix)){
					orgCacheCarouselDataStr = 'Simpplr.Cache.'+cacheName;
				}				
					
				result1 = (Map<String,Object>)Cache.Org.get(orgCacheCarouselDataStr);
				if(result1 != null){
					logger.logDebug('Returned from Cache '+orgCacheCarouselDataStr);
					return buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content data fetched successfully!', result1);
				}
					
			}
				
			List<CarouselWrapper> respList = new List<CarouselWrapper>();
			List<CarouselWrapper> respListNew = new List<CarouselWrapper>();
			// Winter18 Carousel Changes
			String carousalListQuery = '';

			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId);
			soqlParamMap.put('soqlParam2', segmentId);
			
			carousalListQuery = 'select Id, Item_Type__c, Social_Campaign__c, Simpplr_Content__c, Order__c, Embedly_Response_JSON__c, CreatedDate from Carousel_Content__c where Site__c = :soqlParam1 and Segment__c = :soqlParam2 and Is_Deleted__c = false';
			if(SimpplrContext.aiContentRecommendationEnabled && String.isBlank(siteId) && isCarouselGovernanceEnabled){
				carousalListQuery += ' and CreatedDate > N_DAYS_AGO : 14';
			}

			if('mobile'.equalsIgnoreCase(readParam('origin')) && String.isBlank('includeCampaign')){
				carousalListQuery += ' and Item_Type__c !=' +'\'Campaign\'';
			}
			carousalListQuery += ' order by order__c ASC, createddate desc';

			if(isMobileOrigin) {
				soqlParamMap.put('soqlParam3', 99);
				carousalListQuery += ' LIMIT : soqlParam3 ';
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Carousel_Content__c> carouselList = (List<Carousel_Content__c>)SIMPESAPI.accessController().queryAsUSer(carousalListQuery, soqlParamMap);
			
			List<ID> contentIdList = new List<ID>();
			List<ID> campaignIdList = new List<ID>();
			Map<Id,Social_Campaign__c> campMap = new Map<Id,Social_Campaign__c>();
			Map<Id, CampaignWrapper> campWrapperMap = new 	Map<Id, CampaignWrapper>();
			Map<Id, ContentWrapper> contentWrapperMap = new Map<Id, ContentWrapper>();
			
			if (carouselList != null && carouselList.size() > 0) {
				for (Carousel_Content__c obj :carouselList) {
					
					if (obj.Item_Type__c.equalsIgnoreCase('content')) {
						contentIdList.add(obj.Simpplr_Content__c);
					}
					
					if (obj.Item_Type__c.equalsIgnoreCase('campaign')) {
						campaignIdList.add(obj.Social_Campaign__c);
					}
				}
			}
			Set<Id> setViews = new Set<Id>();
			if(isAiRecommendationAndGovernanceEnabled){	
				contentIdList.addAll(campaignIdList);
				soqlParamMap.put('soqlParam1', contentIdList);
				soqlParamMap.put('soqlParam2', loggedInPeopleId);
				String viewsListQuery = 'SELECT Id, People__c, Content__c FROM Simpplr_Social_Analytics__c WHERE People__c = :soqlParam2 and Content__c IN :soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Simpplr_Social_Analytics__c> viewsList = (List<Simpplr_Social_Analytics__c>)SIMPESAPI.accessController().queryAsUSer(viewsListQuery, soqlParamMap);
				for(Simpplr_Social_Analytics__c obj : viewsList) {
					setViews.add(obj.Content__c);
				}
			}
			List<Simpplr_Content__c> contentObjList = New List<Simpplr_Content__c>();
			if(!contentIdList.isEmpty()){
				contentObjList = getContentListForUser(siteId, contentIdList);
				contentWrapperMap = convertContentsListTowrapperList(contentObjList);
			}
			if(!campaignIdList.isEmpty()){
				campMap = getCampaignMap(campaignIdList);
				campWrapperMap = convertCampaignsListTowrapperList(campMap);
			}
			Integer sequence=1;
			if (carouselList!=null && carouselList.size() > 0) {
				for (Carousel_Content__c obj :carouselList) {
					CarouselWrapper wrapperObj = new CarouselWrapper();
					wrapperObj.itemType = obj.Item_Type__c;
					wrapperObj.carouselItemId = obj.id;
					wrapperObj.originalOrder = (Integer)obj.Order__c;
					wrapperObj.source = 'curated';
					wrapperObj.addedAt = String.valueOf(obj.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));

					if (obj.Item_Type__c.equalsIgnoreCase('content')) {
						ContentWrapper contentWrapperObj = contentWrapperMap.get(obj.Simpplr_Content__c);
						
						if (contentWrapperObj != null) {
							if(contentWrapperObj.site!=null && contentWrapperObj.site.isPublic == false){
								cacheCarousel = false;
							}
							wrapperObj.item = contentWrapperObj;
							if(!setViews.contains(obj.Simpplr_Content__c) && isCarouselGovernanceEnabled) {
								wrapperObj.order = sequence;
								respList.add(wrapperObj);
								sequence++;
							}
							else {
								respListNew.add(wrapperObj);
							}
						}
						
					} else if (obj.Item_Type__c.equalsIgnoreCase('campaign')) {
						CampaignWrapper campWrapperObj = campWrapperMap.get(obj.Social_Campaign__c);
						
						if (campWrapperObj != null) {
							wrapperObj.item = campWrapperObj;
							respListNew.add(wrapperObj);
						}
						
					} else if (obj.Item_Type__c.equalsIgnoreCase('external')) {
						wrapperObj.item = (CarouselWrapper.OembedModel) JSON.deserialize(obj.Embedly_Response_JSON__c , CarouselWrapper.OembedModel.class);
						respListNew.add(wrapperObj);
					}
					
				}
				
			}
			
			if (respList!=null && respList.size()+respListNew.size() < TOTAL_NUMBER_OF_CAROUSEL_TILES) {
				if(isAiRecommendationAndGovernanceEnabled) {			
					Integer size = TOTAL_NUMBER_OF_CAROUSEL_TILES-carouselList.size();
					Set<String> contentIds = new Set<String>();
					contentIds = ContentDataProvider.getAIContentRecommendations(new List<String>{UserContext.peopleId}, 'carousel', TOTAL_NUMBER_OF_CAROUSEL_TILES);
					for (String contentId : contentIds) {
						if (contentIdList.contains(contentId) || campaignIdList.contains(contentId)) {
							contentIds.remove(contentId);
						}
					}
					if(!contentIds.isEmpty()){
						AllContentDataServer allContentServ = new AllContentDataServer();
						List<Simpplr_Content__c> listOfContents = allContentServ.getSortedContentList(contentIds, size);//Sorted on score basis from AI
						for (Simpplr_Content__c contentRecord: listOfContents) {

							if(contentRecord.Site__r.Site_Type__c !=null && contentRecord.Site__r.Site_Type__c != 'Public' && contentRecord.Site__r.Site_Type__c != ''){
								cacheCarousel = false;
							}
							CarouselWrapper wrapperObj = new CarouselWrapper();
							wrapperObj.order = sequence;
							wrapperObj.itemType = 'content';
							wrapperObj.carouselItemId = 'recommended_'+contentRecord.Id;
							wrapperObj.source = 'recommended';
	            			ContentWrapper wrapObj=convertContentToWrapper(sequence, contentRecord);
							if (wrapObj != null) {
								wrapperObj.item = wrapObj;
								respList.add(wrapperObj); 
								sequence++;
							}
						}
					}
				}
	
			}
			for(CarouselWrapper wrap : respListNew) {
				wrap.order = sequence;
				respList.add(wrap);
				sequence++;
			}	
			result.put('listOfItems', respList);
			result.put('siteId', siteId);

			if(cacheCarousel && isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled && !isAiRecommendationAndGovernanceEnabled){
				logger.logDebug('Added To CACHE '+orgCacheCarouselDataStr);
				Cache.Org.put(orgCacheCarouselDataStr, result);
			}
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content data fetched successfully!', result);
			logger.logDebug('carouselDataForDashobard----resultWrapper----'+resultWrapper);       
	    } catch(exception e){
      		logger.logError('CarouselDataServer.carouselDataForDashboard()-----could not retrieve data----',e);
  			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return resultWrapper;
    }
    
    @testVisible
    private Map<Id, CampaignWrapper> convertCampaignsListTowrapperList(Map<Id,Social_Campaign__c> campMap) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);
		soqlParamMap.put('soqlParam2', campMap.keySet());
    	String queryString = 'Select Id, Network_Shared__c, People__c, Social_Campaign__c '+
														' from Social_Campaign_Share__c'+ 
														' where People__c =: soqlParam1 and Social_Campaign__c =: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign_Share__c> shareList = (List<Social_Campaign_Share__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		Map<Id, set<String>> mapCampaignIdIntegrationShared = new Map<Id, set<String>>();												
		for(Social_Campaign_Share__c shareObj : shareList){
			if(mapCampaignIdIntegrationShared.containsKey(shareObj.Social_Campaign__c)){
				mapCampaignIdIntegrationShared.get(shareObj.Social_Campaign__c).add(shareObj.Network_Shared__c);
			}else{
				mapCampaignIdIntegrationShared.put(shareObj.Social_Campaign__c, new set<String> {shareObj.Network_Shared__c});
			}
		
		}

		Set<String> setOfActiveDirectoryGroups = new Set<String>();
		Map<String, Active_Directory_Group__c> adIdToADObjectMap = new Map<String, Active_Directory_Group__c>();			

		List<Audience__c> audienceList = new List<Audience__c>(); 
		for(Social_Campaign__c campaignObj : campMap.values()) {
			if('audience'.equalsIgnoreCase(campaignObj.Recipient__c)){
				audienceList.add(campaignObj.Audience__r);
				Set<String> activeDirectoryGroupIds = ActiveDirectoryHelper.getActiveDirectoryGroupIds(campaignObj.Audience__r.Audience_Rule_Json__c);
				if(!activeDirectoryGroupIds.isEmpty()) {
					setOfActiveDirectoryGroups.addAll(activeDirectoryGroupIds);
				}
			}
		}

		// For AD audience
		if(!setOfActiveDirectoryGroups.isEmpty()) {
			adIdToADObjectMap = ActiveDirectoryHelper.getSelectedActiveDirectoryGroups(setOfActiveDirectoryGroups);
		}		

    	Map<Id, CampaignWrapper> campWrapMap = new Map<Id, CampaignWrapper>();
    	CampaignService csObj = new CampaignService();
    	for(Social_Campaign__c campaignObj : campMap.values()) {
			campWrapMap.put(campaignObj.id ,csObj.convertToWrapper(campaignObj, mapCampaignIdIntegrationShared, adIdToADObjectMap));
		}
    	return campWrapMap;
    }
    
    @testVisible
    private Map<Id,Social_Campaign__c> getCampaignMap(List<Id> campaignIdList){
		CampaignService csobj = new CampaignService();
		Map<Id, Social_Campaign__c> campMap = new Map<Id, Social_Campaign__c>();
		if(SimpplrContext.isFeatureEnabled('Employee_Advocacy')) {
			campMap = csobj.getCampaignByIds('all', new List<Id>(campaignIdList));
		}
    	return campMap;
    }
    
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible 
    private List<Simpplr_Content__c> getContentListForUser(String siteId,List<ID> contentIdList){
		logger.logDebug('CarouselDataServer.getContentListForUser()----siteId----'+siteId+'----contentIdList----'+contentIdList);
	    List<Simpplr_Content__c> result = new List<Simpplr_Content__c>();
	    list<Simpplr_Content__c> listOfCarouselContentsInOrder = new list<Simpplr_Content__c>();

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', sitesIFollowIdSet);
		soqlParamMap.put('soqlParam2', currentDateTime);
		soqlParamMap.put('soqlParam3', loggedInPeopleId);
		soqlParamMap.put('soqlParam4', loggedInPeopleId);
		soqlParamMap.put('soqlParam5', siteId);
		soqlParamMap.put('soqlParam6', allowedFeaturesInAppList);

	    fieldList.add('(SELECT Id,Order__c,Is_Deleted__c,Site__c FROM Simpplr_Carousel_Contents__r WHERE\n'+
				' Site__c = :soqlParam5 AND Is_Deleted__c = false LIMIT 1)');
        String conditionString = 'WHERE Is_Deleted__c = false' + 
        		' AND Status__c = \'Approved\' AND Activated_By_Feature__c = true' +
        		' AND ((Site__c != null And Site__r.is_Active__c = true And Site__r.Show_In_Simpplr__c = true) OR TYPE__c = \'BlogPost\')' +
        		' AND TYPE__c IN : soqlParam6';
		
        if (contentIdList != null && contentIdList.size() > 0) {
        	soqlParamMap.put('soqlParam7', contentIdList);
			conditionString += ' AND ID in :soqlParam7';
        }
        
       	String query = 'SELECT '+String.join(fieldList,',')+' FROM Simpplr_Content__c '+conditionString;
        logger.logDebug('CarouselDataServer.getContentListForUser()----query----'+query);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Content__c> carContentList = (List<Simpplr_Content__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

		Map<Id, Simpplr_Content__c> simpplrContentIdAndContentMap = new Map<Id, Simpplr_Content__c>(carContentList);
        if (contentIdList.size()>0 && contentIdList != null) {
        	
        	for (String id : contentIdList) {
        		
	        	if (simpplrContentIdAndContentMap.size() > 0 && simpplrContentIdAndContentMap != null) {
	        		
	        		if (simpplrContentIdAndContentMap.containsKey(id)) {
	                	listOfCarouselContentsInOrder.add(simpplrContentIdAndContentMap.get(id));
	            	}
	            	
	        	}
	        	
        	}
        	
        }
        
        logger.logDebug('CarouselDataServer.getContentListForUser()----result----'+result);
        return listOfCarouselContentsInOrder;	
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible 
    private Map<Id, ContentWrapper> convertContentsListTowrapperList (List<Simpplr_Content__c> recordsList) {
        Map<Id, ContentWrapper> result = new Map<Id, ContentWrapper>();
        ContentWrapper wrapperObj;
        Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
        
        if (recordsList != null && recordsList.size() > 0) {
        	
			for(String feature : allowedFeaturesInAppList) {
		    	allowedFeaturesInAppSet.add(feature.toLowerCase());
		    }
            for (Simpplr_Content__c contentRecord: recordsList) {
            	List<Carousel_Content__c> carouselList = contentRecord.Simpplr_Carousel_Contents__r;
            	
            	if (carouselList.size() > 0) {
            	
            		if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.Type__c)) {
            			ContentWrapper wrapObj=convertContentToWrapper(carouselList[0].Order__c != NULL ?Integer.valueOf(carouselList[0].Order__c):NULL, contentRecord);
            			result.put(contentRecord.Id, wrapObj);
            		
            		} else if (SimpplrContext.AllowedFeatures.containsIgnoreCase(contentRecord.Type__c)) {
		                ContentWrapper wrapObj=convertContentToWrapper(carouselList[0].Order__c != NULL ?Integer.valueOf(carouselList[0].Order__c):NULL, contentRecord);
		                result.put(contentRecord.Id, wrapObj);
	            		
	            	}
	            	
            	}
            	
            }
            
        }
        return result;
    }
    
    @TestVisible 
    private ContentWrapper convertContentToWrapper (Integer order, Simpplr_Content__c contentRecord) {
        ContentWrapper wrapperObj  = New ContentWrapper();
	    wrapperObj.order = order;
        wrapperObj.id = contentRecord.id;
        
		List<Must_Read_Audit__c> mRAList = contentRecord.Must_Read_Audits__r;
		
		if (mRAList != null && mRAList.isEmpty() == false && (mRAList[0].Expiry_DateTime__c == null || mRAList[0].Expiry_DateTime__c>DateTime.now()) && mRAList[0].Removed_DateTime__c == null) {
			wrapperObj.isMustRead = true;
			Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
			mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap; 
            if(mRAList[0].Audience_Type__c == 'site_members' && 
                    mapofSiteIdAndSiteRole.keyset().contains(contentRecord.Site__c)) {
				Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
				if(siteRoleForContentSite!= null && siteRoleForContentSite.Is_Member__c == true) {
					wrapperObj.isMustRead = true;
				} else {
					wrapperObj.isMustRead = false;
				}
			} else {
				wrapperObj.isMustRead = true;
			}

		} else {
			wrapperObj.isMustRead = false;
		}


		wrapperObj.hasRead = !contentRecord.Must_Read_Confirm_History__r.isEmpty();
        wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c)?'':contentRecord.Display_Excerpt__c.unescapeHtml4();
    	wrapperObj.summary = String.isBlank(contentRecord.Summary_1__c)?'':contentRecord.Summary_1__c.unescapeHtml4();
    	
        // TODO : Riyaz please review following mapping.
        wrapperObj.isPublished = contentRecord.Is_Published__c;
        
        if (contentRecord.Status__c != NULL) {
            
            if (CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentRecord.Status__c)) {
                wrapperObj.status = CONTENT_STATUS_PENDING;
            
            } else if (CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentRecord.Status__c)) {
                wrapperObj.status = CONTENT_STATUS_DRAFT.toLowerCase();
                
            } else if (CONTENT_STATUS_REJECTED.equalsIgnoreCase(contentRecord.Status__c)) { 
                wrapperObj.status = CONTENT_STATUS_REJECTED.toLowerCase();
                
            } else if (contentRecord.Is_Published__c) {
                wrapperObj.status = CONTENT_STATUS_PUBLISH.toLowerCase();
                
            } else if (contentRecord.Is_Unpublished__c){
                wrapperObj.status = CONTENT_STATUS_UNPUBLISH.toLowerCase();
            } 
            
        }
        
        wrapperObj.siteId = contentRecord.Site__c;
        wrapperObj.isTypeActive =  (allowedFeaturesInAppSet.contains(contentRecord.Type__c.toLowerCase()) && contentRecord.Activated_By_Feature__c == true) ? true : false;
        if (ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentRecord.Type__c)) {
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/page/'+contentRecord.Id + '&origin=cl';
            wrapperObj.editUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/page/'+contentRecord.Id + '/edit&origin=cl'; 
            wrapperObj.category = new CategoryWrapper();
        	wrapperObj.category.id = contentRecord.Pages_Category__c;
        	wrapperObj.category.Name = contentRecord.Pages_Category__r.Name__c;
			wrapperObj.category.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentRecord.Site__c + '/content&pageCategoryId=' + contentRecord.Pages_Category__c;
			
        } else if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.Type__c)) {
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRecord.Primary_Author__c+'/blog/'+contentRecord.id + '&origin=cl';
            wrapperObj.editUrl = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentRecord.Primary_Author__c+'/blog/'+contentRecord.id + '/edit&origin=cl';                                           
        
        } else if (ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentRecord.Type__c)) {
        	wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/event/'+contentRecord.Id + '&origin=cl';
            wrapperObj.editUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/event/'+contentRecord.Id + '/edit&origin=cl';
            wrapperObj.isAllDay = contentRecord.Event_Is_All_Day__c;
            DateTime startDateTimeValue = null;
	        String startDateStringValue = String.valueOf(contentRecord.Event_Start_DateTime__c);
			
			TimeZone tz = Timezone.getTimeZone(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentRecord.Event_TimezoneSidKey__c);
            wrapperObj.timezoneIso = tz.getID();
            wrapperObj.timezoneOffset = tz.getOffset(system.today());
			
	        if (String.isNotBlank(startDateStringValue)) {
		        startDateTimeValue = contentRecord.Event_Start_DateTime__c;
	    	    wrapperObj.startsAt = startDateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	        }
	        
	        DateTime endDateTimeValue = contentRecord.Event_End_DateTime__c;
		    wrapperObj.endsAt = Utility.dateTimeToMomentJSDateTime(endDateTimeValue);
	        
	        if (contentRecord.Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
	        	wrapperObj.isMultiDay = false;
	        
	        } else {
	        	wrapperObj.isMultiDay = true;
	        }
	                                                   
        } else if (ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)) {
            wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/album/'+contentRecord.Id + '&origin=cl';
            wrapperObj.editUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/album/'+contentRecord.Id + '/edit&origin=cl';
            wrapperObj.img = null;
            wrapperObj.imageCount = Integer.valueOf(contentRecord.Album_Image_Count__c);
			wrapperObj.videoCount = Integer.valueOf(contentRecord.Album_Video_Count__c);
        }
        
        List<File__c> titleFilesList = contentRecord.File_Simpplr_Content__r;
		if(!titleFilesList.isEmpty()){
			for(File__c fileObj : titleFilesList){
    			if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentRecord.Type__c)){
        			if(fileObj.Is_Title_Image__c) {
	        			if(String.isNotBlank(fileObj.Content_Version__c)) {
	        				wrapperObj.img = Utility.getFileDownloadURLFor240BY180(fileObj.Content_Version__c);
	        				wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
	        				wrapperObj.imgFile = new FileContentWrapper();
							wrapperObj.imgFile.imgTHUMB240BY180URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB240BY180';
    						wrapperObj.imgFile.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
    						wrapperObj.imgFile.imgFullURL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/content';
        				} else {
        					wrapperObj.img = fileObj.Thumbnail_URL__c;
        					wrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;
        					wrapperObj.imgFile = new FileContentWrapper();
							wrapperObj.imgFile.imgTHUMB240BY180URL = fileObj.Thumbnail_URL__c;
    						wrapperObj.imgFile.imgTHUMB720BY480URL = fileObj.Thumbnail_URL__c;
    						wrapperObj.imgFile.imgFullURL = fileObj.Thumbnail_URL__c;
	        			}
	        		} 
    				// Add the image to the TopAlbumImages
    				ContentWrapper.AlbumImagesWrapper imagesWrapperObj = new ContentWrapper.AlbumImagesWrapper();
					imagesWrapperObj.albumMediaId = fileObj.id;
        			
	        			if (String.isNotBlank(fileObj.Content_Version__c)) {
							imagesWrapperObj.isVideo = false;
	        				imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
	        			
	        			} else {
							imagesWrapperObj.isVideo = true;
	        				imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
						imagesWrapperObj.img = fileObj.Thumbnail_URL__c;	
    				}
	        		wrapperObj.listOfTopAlbumImages.add(imagesWrapperObj);
        		}else{
        			if(fileObj.Title_Image_Type__c == 'Thumbnail' && fileObj.Is_Title_Image__c){
        				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
        				wrapperObj.imgFile = new FileContentWrapper();
						wrapperObj.imgFile.imgTHUMB240BY180URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB240BY180';
						wrapperObj.imgFile.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
						wrapperObj.imgFile.imgFullURL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/content';
	        		} else if('WideScreen'.equalsIgnoreCase(fileObj.Title_Image_Type__c) && fileObj.Is_Title_Image__c){
	        			wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
	        			wrapperObj.imgFile = new FileContentWrapper();
						wrapperObj.imgFile.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
						wrapperObj.imgFile.imgFullURL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/content';
						wrapperObj.imgLandscapeFile = new FileContentWrapper();
						wrapperObj.imgLandscapeFile.imgTHUMB240BY180URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB240BY180';
						wrapperObj.imgLandscapeFile.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/rendition?type=THUMB720BY480';
						wrapperObj.imgLandscapeFile.imgFullURL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +fileObj.Content_Document__c+'/content';
	        		}
	        	}
	        	
        		}
		}
        
        wrapperObj.type = contentRecord.Type__c;
        DateTime dateTimeValue = null;
        String dateStringValue = String.valueOf(contentRecord.Last_Edited_DateTime__c);
        
        if (String.isNotBlank(dateStringValue)) {
			dateTimeValue = contentRecord.Last_Edited_DateTime__c;
	    	wrapperObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        dateStringValue = String.valueOf(contentRecord.Publish_Start_DateTime__c);
        
        if (String.isNotBlank(dateStringValue)){
    		dateTimeValue = contentRecord.Publish_Start_DateTime__c;
	    	wrapperObj.publishAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
        
        dateStringValue = String.valueOf(contentRecord.CreatedDate);
        
        if (String.isNotBlank(dateStringValue)) {
	        dateTimeValue = contentRecord.CreatedDate;
    	    wrapperObj.createdAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        }
		
		if(contentRecord.Content_Interactions__r.isEmpty()){
    		wrapperObj.hasSeen = false;
        } else{
        	wrapperObj.hasSeen = true;
		}
        wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, contentRecord.Title__c.length(), false);
        wrapperObj.authoredBy = new PeopleListWrapper();
        wrapperObj.authoredBy.userId = contentRecord.Primary_Author__r.User__r.Id;
        wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.name = contentRecord.Primary_Author__r.Full_Name__c;
        wrapperObj.authoredBy.img = contentRecord.Primary_Author__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : contentRecord.Primary_Author__r.User__r.SmallPhotoUrl;
        wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentRecord.Primary_Author__c + '&origin=cl';

		if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentRecord.type__c)) {
			wrapperObj.canMakeMustRead = wrapperObj.isPublished && UserContext.isUserAppModerator;
			wrapperObj.canEdit = AccessManager.calculateBlogEditAccess(contentRecord.primary_author__r.user__c, wrapperObj.status);
			wrapperObj.canDelete = AccessManager.calculateManageBlogAccess(contentRecord.Primary_Author__r.User__c);
			wrapperObj.canPublishUnpublish = wrapperObj.canDelete;
			wrapperObj.canSendUpdateNotification = false;
			wrapperObj.canModerate = AccessManager.calculateModerateAccess(false, false, wrapperObj.status, 
        		contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
        		
		} else {
			Boolean isSiteManager = (UserContext.sitesIManageIdSet).contains(contentRecord.Site__c);
			Boolean isContentManager = (UserContext.sitesIManageContentsIdSet).contains(contentRecord.Site__c);

			wrapperObj.site = New SiteLiteWrapper();
	        wrapperObj.site.siteid = contentRecord.Site__c;
	        wrapperObj.site.name = contentRecord.Site__r.name;
	        wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentRecord.Site__c + '/' + contentRecord.Site__r.Landing_Page__c + '&origin=cl';
	        wrapperObj.site.chatterGroupId = contentRecord.Site__r.Chatter_Group_Id__c;
	        wrapperObj.site.isPublic = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
	        wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
	        wrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
	        wrapperObj.site.isActive = contentRecord.site__r.Is_Active__c;
	        wrapperObj.site.img = String.isBlank(contentRecord.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(contentRecord.Site__r.Title_Content_Version__c);
	        wrapperObj.site.imgThumbnail = String.isBlank(contentRecord.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(contentRecord.Site__r.Title_Content_Version__c);

			wrapperObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(wrapperObj.type, wrapperObj.isPublished, 
													wrapperObj.site.access, contentRecord.Site__r.Is_Must_Read_Enabled__c, 
													isSiteManager, isContentManager);
			wrapperObj.canDelete = AccessManager.calculateDeleteAccess(isSiteManager, isContentManager, wrapperObj.status, 
        		contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
			wrapperObj.canEdit = AccessManager.calculateEditAccess(isSiteManager, isContentManager, wrapperObj.status, 
        						 contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
			wrapperObj.canPublishUnpublish = AccessManager.calculatePublishUnpublishAccess(isSiteManager, isContentManager, wrapperObj.status, 
        		contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
			wrapperObj.canSendUpdateNotification =  wrapperObj.canEdit;
			wrapperObj.canModerate = AccessManager.calculateModerateAccess(isSiteManager, isContentManager, wrapperObj.status, 
        		contentRecord.primary_author__r.user__c, contentRecord.Site__r.Site_Type__c);
		}
		
		//-------To Do security check--------------------------
        return wrapperObj;
    }
	
	private Boolean checkCarouselModerationAccess (String siteId, String segmentId) {
    	Boolean hasCarouselModerationAccess = false;
    	
    	if (String.isNotBlank(siteId) && 'home'.equalsIgnoreCase(siteId) == false) {
    		
			if (SiteContext.isCurrentUserSiteManager || SiteContext.isCurrentUserSiteContentManager || (UserContext.isUserAppModerator && SiteContext.isPublicSite)) {
				hasCarouselModerationAccess = true;
			
			} else if (SiteContext.isUnlistedSite == false && UserContext.hasModifyAllDataPermission) {
				hasCarouselModerationAccess = true;

			} else if (SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission) {
				hasCarouselModerationAccess = true;
			}
			
    	} else {
    		
    		if (UserContext.canControlHomeDashboard || UserContext.isUserAppModerator || 
    				UserContext.hasModifyAllDataPermission || (String.isNotBlank(segmentId) && UserContext.segmentId == segmentId && UserContext.isSegmentManager)) {
    			hasCarouselModerationAccess = true;
    		}
    		
    	} 
    	
		return hasCarouselModerationAccess;
    }
	public Integer getPeopleCount() {
	    String packageName = SimpplrContext.packageName;
		return [SELECT count() FROM People__c  Where (User__r.Show_Simpplr__c ='Yes' OR (user__r.Show_Simpplr__c != 'No' AND user__r.isActive=true AND user__r.UserType='Standard')) WITH SECURITY_ENFORCED];
	}
    @TestVisible 
    private ResponseWrapper getAnalytics () {
		logger.logDebug('CarouselDataServer.getAnalytics');
        ResponseWrapper resultWrapper = New ResponseWrapper();
		try{				
			List<CarouselWrapper> respList = new List<CarouselWrapper>();
			Map<String,Object> result = New Map<String,Object>();
			String segmentId;
			if(SimpplrContext.isSegmentsEnabled){
				segmentId = UserContext.segmentId;
			}
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', null);
			soqlParamMap.put('soqlParam2', segmentId);
			String carousalListQuery = 'select Id, Item_Type__c, Social_Campaign__c, Simpplr_Content__c, Order__c, Embedly_Response_JSON__c from Carousel_Content__c where Site__c = :soqlParam1 and Segment__c = :soqlParam2 and Is_Deleted__c = false and Simpplr_Content__c != null ';
			String carouseListQueryDelete = carousalListQuery + ' and CreatedDate < N_DAYS_AGO : 14';
			if(SimpplrContext.aiContentRecommendationEnabled && SimpplrContext.carouselGovernance){
				carousalListQuery += ' and CreatedDate > N_DAYS_AGO : 14';
			}
			carousalListQuery += ' order by order__c ASC, createddate desc';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Carousel_Content__c> carouselList = (List<Carousel_Content__c>)SIMPESAPI.accessController().queryAsUSer(carousalListQuery, soqlParamMap);			
			List<ID> contentIdList = new List<ID>();
			Map<String, String> carouselItemIdMap = new Map<String, String> ();
		
			for (Carousel_Content__c obj :carouselList) {
				if (obj.Item_Type__c.equalsIgnoreCase('content')) {
					contentIdList.add(obj.Simpplr_Content__c);
					carouselItemIdMap.put(UserInfo.getOrganizationId().subString(0,15)+String.valueOf(obj.Simpplr_Content__c).subString(0,15),obj.Id);
				}
			}
			if(!contentIdList.isEmpty()){
				Map<String,Object> requestDataMap = new Map<String,Object>();
				requestDataMap.put('from',Datetime.now().addDays(-14).format('yyyy-MM-dd'));
				requestDataMap.put('to',Datetime.now().format('yyyy-MM-dd'));
				requestDataMap.put('contentIdList',contentIdList);
				requestDataMap.put('groupBy','day');
				List<AnalyticsWrapper.ContentRelatedData> contentWrapperObjList = new List<AnalyticsWrapper.ContentRelatedData>(); 
				contentWrapperObjList = (List<AnalyticsWrapper.ContentRelatedData>) externalAnalyticsServiceObj.getExternalAnalyticsResults(requestDataMap,'getContentListViews',null);
				if(!contentWrapperObjList.isEmpty()){
					Integer totalPeopleCount = getPeopleCount();
					for(AnalyticsWrapper.ContentRelatedData contentWrapperObj : contentWrapperObjList) {
						CarouselWrapper wrapperObj = new CarouselWrapper();
						wrapperObj.viewsOverTime = contentWrapperObj.viewsOverTime;
						wrapperObj.totalViews = contentWrapperObj.totalViewCount;
						wrapperObj.viewedBy = contentWrapperObj.totalViewCount*100/totalPeopleCount;
						wrapperObj.carouselItemId = carouselItemIdMap.get(contentWrapperObj.contentId);
						respList.add(wrapperObj);
						carouselItemIdMap.remove(contentWrapperObj.contentId);
					}
				}
				for (String key : carouselItemIdMap.keySet()) {
					CarouselWrapper wrapperObj = new CarouselWrapper();
					wrapperObj.totalViews = 0;
					wrapperObj.viewedBy = 0;
					wrapperObj.carouselItemId = carouselItemIdMap.get(key);
					respList.add(wrapperObj);
				}

			}
			if(SimpplrContext.aiContentRecommendationEnabled && SimpplrContext.carouselGovernance){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Carousel_Content__c> carouselListDelete = (List<Carousel_Content__c>)SIMPESAPI.accessController().queryAsUSer(carouseListQueryDelete, null);			
				if (!carouselListDelete.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(carouselListDelete);
				}
			}
			result.put('listOfItems', respList);
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Analytics data fetched successfully!', result);
			logger.logDebug('getAnalytics----resultWrapper----'+resultWrapper);       
	    } catch(exception e){
      		logger.logError('CarouselDataServer.getAnalytics()-----could not retrieve data----',e);
  			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return resultWrapper;
	}
    
}