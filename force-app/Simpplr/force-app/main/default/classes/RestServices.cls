@RestResource(urlMapping='/*')
global with sharing class RestServices{
    @HttpGet  
    global static void getBasicAppInformation() {
    	ResponseWrapper respWrapObj = new ResponseWrapper();
        respWrapObj.isManagedPackage = String.isNotBlank(SimpplrContext.packageName)?true:false;

        String visualforceNameSpacePrefix = String.isNotBlank(SimpplrContext.packageName) ? SimpplrContext.packageName : 'c';
		respWrapObj.baseUrl = SimpplrContext.salesforceBaseUrl.substringBefore('.') + '--' + visualforceNameSpacePrefix + '.' + SimpplrContext.instance+'.visual.force.com';
		
        respWrapObj.mediumPhotoUrl = Utility.getUserProfileImgUrl(UserContext.MediumPhotoUrl, UserContext.FullPhotoUrl);
        respWrapObj.sfUserId = UserContext.userId;
        respWrapObj.peopleId = UserContext.peopleId;
        respWrapObj.userName = UserContext.peopleName;
        if(String.isNotBlank(SimpplrContext.SABrandingJSON)){
			Map<String,Object> brandingInfoMap = (Map<String,Object>)JSON.deserializeUntyped(SimpplrContext.SABrandingJSON);
			respWrapObj.primaryColor = brandingInfoMap.get('general_primaryColor')!=null ? brandingInfoMap.get('general_primaryColor')+'':null;
			respWrapObj.backgroundColor = brandingInfoMap.get('general_backgroundColor')!=null ? brandingInfoMap.get('general_backgroundColor')+'':null;
            //respWrapObj.backgroundColor = brandingInfoMap.get('general_lightModelinkColor')!=null ? brandingInfoMap.get('general_lightModelinkColor')+'':null;            //CONT-10737
            //respWrapObj.backgroundColor = brandingInfoMap.get('general_darkModelinkColor')!=null ? brandingInfoMap.get('general_darkModelinkColor')+'':null;              //CONT-10737
            //respWrapObj.backgroundColor = brandingInfoMap.get('general_brandingAnchorPrimaryColor')!=null ? brandingInfoMap.get('general_brandingAnchorPrimaryColor')+'':null;              //CONT-10737


		}
        respWrapObj.isFeedEnabled = SimpplrContext.isFeedEnabled;
        respWrapObj.size = SimpplrContext.simpplrDefaultPageSize;
        respWrapObj.isSysAdmin = UserContext.hasModifyAllDataPermission;
        respWrapObj.isAppManager = UserContext.isUserAppModerator;
        respWrapObj.isUnlistedManager = UserContext.hasManageUnlistedSitePermission;
        respWrapObj.notificationCount = NotificationDao.getNewNotificationCount();
        Integer notirefreshInterval = (SimpplrContext.simpplrNotificationRefreshInterval == null || SimpplrContext.simpplrNotificationRefreshInterval == 0)?60000:(SimpplrContext.simpplrNotificationRefreshInterval)*1000;
        respWrapObj.notificationRefreshInterval =notirefreshInterval;
        
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(respWrapObj));
        
        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }
    
    private class ResponseWrapper{
    
	    	Boolean isManagedPackage;
	    	String baseUrl;
	    	String mediumPhotoUrl;
	    	String sfUserId;
	    	String peopleId;
	    	String userName;
	    	String primaryColor;
	    	String backgroundColor;
	    	Boolean isFeedEnabled;
	    	Integer size;
	    	Integer notificationCount;
	    	Boolean isSysAdmin;
		Boolean isAppManager;
		Boolean isUnlistedManager;
    		Integer notificationRefreshInterval;
    	
    }
    
}