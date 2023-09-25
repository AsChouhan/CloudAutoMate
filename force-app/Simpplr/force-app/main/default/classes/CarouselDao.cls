/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class CarouselDao{

    private String loggedInUserId = UserContext.id;
    private Boolean isAppModerator = UserContext.isUserAppModerator;
    private Set<Id> siteIManageIdSet = UserContext.sitesIManageIdSet;
    private List<String> fieldList = New List<String>{'Is_Deleted__c','Summary_1__c','Type__c','Title__c','Text_Main__c','Display_Excerpt__c', 
    													'Text_Main_Continued__c','Text_Intro__c','Status__c','Publish_Start_DateTime__c', 'Last_Edited_DateTime__c',
    													'Publish_End_DateTime__c','Site__c','Site__r.name','Site__r.Chatter_Group_Id__c','Site__r.Site_Type__c', 
													  	'Primary_Author__c','Primary_Author__r.Full_Name__c',
													  	'Primary_Author__r.User__r.Id', 'Primary_Author__r.User__r.SmallPhotoUrl','Id',
													  	'CreatedDate','lastModifiedDate','Is_Published__c','Is_Unpublished__c',
														'(SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c FROM File_Simpplr_Content__r where Is_Deleted__c = false)'
	        										}; 
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public String addContentToCarousel(String siteId, String segmentId, String contentId, String name){
        Simpplr_Content__c simCont = [SELECT Id,Title__c FROM Simpplr_Content__c WHERE Id =: contentId  WITH SECURITY_ENFORCED LIMIT 1];
        
        String returnId = null;
        if(!String.isBlank(contentId)){
            Carousel_Content__c carContentObj = new Carousel_Content__c();  
            carContentObj.Simpplr_Content__c = contentId;
            carContentObj.Site__c = siteId;
            if(String.isNotBlank(segmentId)) {
            	carContentObj.Segment__c = segmentId;
            } else {
            	carContentObj.Segment__c = null;
            }
            carContentObj.name = name;
            carContentObj.Item_Type__c = 'content';
			carContentObj.Created_by_People__c = UserContext.peopleId;
            List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{
																			Carousel_Content__c.Site__c,
																			Carousel_Content__c.Created_by_People__c,
																			Carousel_Content__c.Segment__c,
																			Carousel_Content__c.Simpplr_Content__c,
																			Carousel_Content__c.Item_Type__c};
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		carContentObj = (Carousel_Content__c) SIMPESAPI.accessController().insertAsUser(carContentObj, listOfColumnsToBeSet);
    		returnId = carContentObj.id;
    		
    		reArrangeCarouselRecords(siteId);
        }
        return returnId; 
    }

	public String addContentToCarouselForAllSegments(String siteId, String contentId, String name){
        if(!String.isBlank(contentId)){
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentId);
			String query = 'SELECT Id from Segment__c ' 
								+ ' WHERE id not in (SELECT Segment__c from Carousel_Content__c '
								+ ' WHERE Simpplr_Content__c=:soqlParam1 '
								+ ' AND Item_Type__c = \'content\' '
								+ ' AND Segment__c != null '
								+ ' AND is_Deleted__c=false )';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            Map<String,Segment__c> segMap = new Map<String,Segment__c>((List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap));
			List<Carousel_Content__c> carouselContentListToBeAdded = new List<Carousel_Content__c>();
			for(String segmentId  : segMap.keySet()){
				Carousel_Content__c carContentObj = new Carousel_Content__c();  
				carContentObj.Simpplr_Content__c = contentId;
				carContentObj.Site__c = siteId;
				carContentObj.Segment__c = segmentId;
				carContentObj.name = name;
				carContentObj.Item_Type__c = 'content';
				carContentObj.Created_by_People__c = UserContext.peopleId;
				carouselContentListToBeAdded.add(carContentObj);
			}

            List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{
																			Carousel_Content__c.Site__c,
																			Carousel_Content__c.Created_by_People__c,
																			Carousel_Content__c.Segment__c,
																			Carousel_Content__c.Simpplr_Content__c,
																			Carousel_Content__c.Item_Type__c};
			if(carouselContentListToBeAdded.size()>0){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(carouselContentListToBeAdded, listOfColumnsToBeSet);
				reArrangeCarouselRecords(siteId);
			}
        }
        return ''; 
    }
    
    public void reArrangeCarouselRecords(String siteId) {
    	List<Carousel_Content__c> carouselContentList  =   new List<Carousel_Content__c>();
        
        if('home'.equalsIgnoreCase(siteId)) {
        	carouselContentList = [Select Id, Order__c from Carousel_Content__c  where Is_Deleted__c = false and Site__c = null  WITH SECURITY_ENFORCED order by order__c ASC, lastModifiedDate DESC];
        }
        else {
        	carouselContentList = [Select Id, Order__c from Carousel_Content__c  where Is_Deleted__c = false and Site__c = :siteId  WITH SECURITY_ENFORCED order by order__c ASC, lastModifiedDate DESC];
        }
        
        Integer i = 1;
        for(Carousel_Content__c carouselObj : carouselContentList) {
        	carouselObj.Order__c = i++;
        }
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Carousel_Content__c>(carouselContentList),new List<Schema.SObjectField>{
	    													Carousel_Content__c.Order__c
    											 });
    }
    
    public Boolean removeContentItemFromCarousel(String siteId, String contentId, String segmentId, Boolean isInAllSegments){
		try{
			List<Carousel_Content__c> carouselContentList = new List<Carousel_Content__c>();
			if(UserContext.isUserAppModerator && isInAllSegments){
				carouselContentList = [SELECT Id,Is_Deleted__c FROM Carousel_Content__c WHERE Is_Deleted__c= false AND Simpplr_Content__c=:contentId And Site__c=:siteId WITH SECURITY_ENFORCED] ;
			} else {
				carouselContentList = [SELECT Id,Is_Deleted__c FROM Carousel_Content__c WHERE Is_Deleted__c= false AND Simpplr_Content__c=:contentId And Site__c=:siteId AND Segment__c =:segmentId WITH SECURITY_ENFORCED];
			}

			for (Carousel_Content__c carouselContent : carouselContentList){
				carouselContent.Is_Deleted__c = true;
				carouselContent.Deleted_by_People__c=UserContext.peopleId;
			}

			if(carouselContentList.size() > 0) {
				List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
																Carousel_Content__c.Is_Deleted__c,
																Carousel_Content__c.Deleted_by_People__c};
			
				//update simContent;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    			SIMPESAPI.accessController().updateAsUser(new Map<Id,Carousel_Content__c>(carouselContentList),listOfColumnsToBeUpdated);
				
				return true;
			} else {
				return false;
			}

		}catch(Exception e){
			logger.logError('CarouselDao.removeContentItemFromCarousel()----Exception Occured----', e);
			return false;
		}
	}
	
	
	public void removeCampaignItemFromCarousel(String siteId, String segmentId, String campaignId){
		if(String.isNotBlank(siteId) && 'home'.equalsIgnoreCase(siteId)){
			siteId = null;
		}
		List<Carousel_Content__c> carouselContentList = [SELECT Id,Is_Deleted__c FROM Carousel_Content__c 
																WHERE Social_Campaign__c=:campaignId AND Segment__c =: segmentId And Site__c=:siteId And Is_Deleted__c = false WITH SECURITY_ENFORCED];
		for (Carousel_Content__c carouselContent : carouselContentList){
			carouselContent.Is_Deleted__c = true;
			carouselContent.Deleted_by_People__c=UserContext.peopleId;
		}
		if(carouselContentList.size() > 0) {
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
																Carousel_Content__c.Is_Deleted__c,
																Carousel_Content__c.Deleted_by_People__c};
		
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Carousel_Content__c>(carouselContentList),listOfColumnsToBeUpdated);
		} 
	}
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public Boolean removeCarousel(String recId){
		try{
			List<Carousel_Content__c> carouselContentList = new List<Carousel_Content__c>();
			// TODO : Need to ask for carousal Id from Joe as this query can throw non selective index error when data is more
			carouselContentList = [SELECT Id,Is_Deleted__c FROM Carousel_Content__c WHERE Id=:recId WITH SECURITY_ENFORCED];

			for (Carousel_Content__c carouselContent : carouselContentList){
				carouselContent.Is_Deleted__c = true;
				carouselContent.Deleted_by_People__c=UserContext.peopleId;
			}

			if(carouselContentList.size() > 0) {
				List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
																Carousel_Content__c.Is_Deleted__c,
																Carousel_Content__c.Deleted_by_People__c};
			
				//update simContent;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    			SIMPESAPI.accessController().updateAsUser(new Map<Id,Carousel_Content__c>(carouselContentList),listOfColumnsToBeUpdated);
				return true;
			} else {
				return false;
			} 
		}catch(Exception e){
			logger.logError('CarouselDao.removeCarousel()----Exception Occured----', e);
			return false;
		}
	}
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public Boolean updateOrder(String siteId,List<String> listOfIds, String segmentId){
		try{
			decimal i = 1;
			Map<String,Decimal> idToOrderMap = new Map<String,Decimal>();
			for (String s : listOfIds){
				idToOrderMap.put(s,i);
				i++;
			}
			
			List<Carousel_Content__c> objList = null;
			
			if('home'.equalsIgnoreCase(siteId)) {
				objList = [SELECT Id, Order__c FROM Carousel_Content__c WHERE Site__c = null AND Is_Deleted__c = false AND Segment__c =: segmentId WITH SECURITY_ENFORCED];
			}
			else {
				objList = [SELECT Id, Order__c FROM Carousel_Content__c WHERE Site__c =: siteId AND Is_Deleted__c = false AND  Segment__c =: segmentId WITH SECURITY_ENFORCED];
			}
			for (Carousel_Content__c cc : objList){
				if (idToOrderMap != NULL && idToOrderMap.get(cc.Id) != NULL){
					cc.Order__c = idToOrderMap.get(cc.Id);					
				}
			}
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{Carousel_Content__c.Order__c};
			
			//update simContent;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id,Carousel_Content__c>(objList),listOfColumnsToBeUpdated);
			return true; 
		}catch(Exception e){
			return false;
		}
	}
	
	public void setLayout(String siteId, String layout, String segmentId, String governance){
		if(String.isNotBlank(segmentId)){
			Segment__c segObj = [Select id, Carousel_Layout__c,Carousel_Governance__c from Segment__c Where Id=:segmentId WITH SECURITY_ENFORCED limit 1];
			segObj.Carousel_Layout__c = layout;
			if('enable'.equalsIgnoreCase(governance)) {
				segObj.Carousel_Governance__c = true;
			}
			else {
				segObj.Carousel_Governance__c = false;
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(segObj, new List<Schema.SObjectField>{Segment__c.Carousel_Layout__c,
																					Segment__c.Carousel_Governance__c});

		} else if(String.isNotBlank(siteid)){
			Simpplr_Site__c siteObj = [Select id, Carousel_Layout__c from Simpplr_Site__c Where Id=:siteId WITH SECURITY_ENFORCED limit 1];
			siteObj.Carousel_Layout__c = layout;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(siteObj, new List<Schema.SObjectField>{Simpplr_Site__c.Carousel_Layout__c});
																					
		} else {
			String appConfigQuery = 'Select id, Carousel_Layout__c,Carousel_Governance__c from App_Config__c limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

			appConfigObj.Carousel_Layout__c = layout;
			if('enable'.equalsIgnoreCase(governance)) {
				appConfigObj.Carousel_Governance__c = true;
			}
			else {
				appConfigObj.Carousel_Governance__c = false;
			}
			SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
				App_Config__c.Carousel_Layout__c, App_Config__c.Carousel_Governance__c});
		}
	}
    
}