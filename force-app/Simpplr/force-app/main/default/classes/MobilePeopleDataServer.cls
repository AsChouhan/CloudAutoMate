public with sharing class MobilePeopleDataServer extends DataServer {
	@TestVisible private final String ACTION_GET_SITE_ALL_MEMBERS = 'getAllSiteMembers';
	@TestVisible private final String ACTION_UPDATE_PROFILE_PHOTO = 'renewExternalPhotoURL';
	public MobilePeopleDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try{
        	logger.logDebug('MobilePeopleDataServer.handleRequest()----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
            String data = readParam('data');	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else {
            	if(ACTION_GET_SITE_ALL_MEMBERS.equalsIgnoreCase(action)){
            		response = getAllSiteMembers(data);
            	} else if(ACTION_UPDATE_PROFILE_PHOTO.equalsIgnoreCase(action)){
            		renewExternalPhotoURL();
            	}else{
                	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            	}
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    @testVisible ResponseWrapper renewExternalPhotoURL(){
    		ResponseWrapper responseToReturn = null;
    		try{
	    		PeopleDao peopleDaoObj = new PeopleDao();
	    		peopleDaoObj.renewExternalPhotoURL();
    			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Profile Photo saved successfully!', true);
    		} catch(Exception e) {
        	logger.logError('PeopleDao.renewExternalPhotoURL()----Could not save profile photo',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
        }
    		return responseToReturn;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobilePeopleDataServer&action=getAllSiteMembers getAllSiteMembers
	 * @apiVersion 1.0.0
	 * @apiGroup MobilePeopleDataServer
	 * @apiName getAllSiteMembers
	 *
	 * @apiParam (Query Parameter) {String} action getAllSiteMembers
	 * @apiParam (Post Parameter) {String} data {"chatterGroupId":"","size":16,"nextPageToken":16} 
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting member id list for a site
	 * 
	 * @apiSuccess {Number} nextPageToken It defines the offset of successive results
	 * @apiSuccess {List[String]} listOfItems List of site member ids
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getAllSiteMembers(String requestData){
    	logger.logDebug('MobilePeopleDataServer.getAllSiteMembers()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
        	
        	Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
        	String term = requestDataMap.get('term');
        	String chatterGroupId = requestDataMap.get('chatterGroupId');
        	Integer size = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        Integer	recordLimit = size + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
        	
        	List<Object> memberList = new List<Object>();
        	
	        Map<String,Object> resultMap = new Map<String,Object>();
	        	memberList = (new MobilePeopleDataProvider()).getAllSiteMemberList(chatterGroupId , offset, recordLimit, isFullModel);
	        
	        if(memberList.size() == recordLimit){
	        	memberList.remove(recordLimit - 1);
	        	resultMap.put('nextPageToken',offset + size);
	        } else {
	        	resultMap.put('nextPageToken',null);
	        }
	        resultMap.put('listOfItems',memberList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Site member list returned successfully!', resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord( 'SiteAbout',requestDataMap);
        }catch(Exception e){
        	logger.logError('MobilePeopleDataServer.getAllSiteMembers()----Could not retrieve list of all site members',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobilePeopleDataServer.getAllSiteMembers()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
}