/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class TileService {
	

	private static final Map<String,String> contentTileIdToContentTypeMap = new Map<String,String>{'News'=>'News', 'Pages'=>'Page', 'Albums'=>'Album','album'=>'Album','Events'=>'Event', 'blog_posts'=>'Blog'};
	private final Integer CONTENT_TILE_ITEM_LIMIT = 18;
	private final Integer SITE_MEMBER_MANAGER_TILE_ITEM_LIMIT = 14;
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	/**
	 * @description fetch user home tile order
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	*/
	public TileDataWrapper.TileOrderData getUserHomeTilesOrderConfig(Boolean isMobileOrigin, List<String> mobileTileList) {
   		TileDataWrapper.TileOrderData tilesOrderData = new TileDataWrapper.TileOrderData();
   		//User Controlled Tiles
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.id);
		String query = 'SELECT Id, Name__c, Data__c, Is_Newly_Pushed__c, Mobile_Order__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
			' FROM Tiles_Config__c where people__r.User__c=:soqlParam1 And Location__c = \'Home Dashboard\' ' +
			' And Is_Deleted__c = false ';
		if(isMobileOrigin == true) {
			soqlParamMap.put('soqlParam2', mobileTileList);	
			query += ' And Variant_Type__c In: soqlParam2 ';
		}

		query += ' order by Is_Newly_Pushed__c, Layout_Column__c, Order__c,CreatedDate desc ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfUserTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   			
   		Map<String, TileDataWrapper.TilesOrder> mapOfOrderedTile = new Map<String, TileDataWrapper.TilesOrder>();
   		List<Tiles_Config__c> listOfTilesToUpdate = new List<Tiles_Config__c>();
   		for(Tiles_Config__c userTile : listOfUserTiles) {
   			if('content'.equalsIgnoreCase(userTile.Type__c) && 'latest_popular'.equalsIgnoreCase(userTile.Variant__c)) {
   				TileDataWrapper.TileDataSettings tilesData = (TileDataWrapper.TileDataSettings)JSON.deserialize(userTile.Data__c,TileDataWrapper.TileDataSettings.class);
   				if(isContentFeatureDisabled(tilesData.type)){
   					continue;
   				}
   			} else if('campaigns'.equalsIgnoreCase(userTile.Type__c)) {
   				if(SimpplrContext.isEmployeeAdvocacyEnabled == false){
   					continue;
   				}
   			}
			TileDataWrapper.TilesOrder orderedTile = new TileDataWrapper.TilesOrder();
			orderedTile.id = userTile.Id;
   			orderedTile.isNewlyPushed = userTile.Is_Newly_Pushed__c;
	   		orderedTile.order = userTile.Order__c.intValue();	
	   		orderedTile.mobileDashboardIndex = userTile.Mobile_Order__c != null ? userTile.Mobile_Order__c.intValue() : 0;
	   		orderedTile.column = String.valueOf(userTile.Layout_Column__c);
	   		orderedTile.title = userTile.Name__c;
		   	orderedTile.type = userTile.Type__c;
		   	orderedTile.variant = userTile.Variant__c;
	   		mapOfOrderedTile.put(orderedTile.id, orderedTile);
	   		
	   		if(userTile.Is_Newly_Pushed__c == true){
	   			userTile.Is_Newly_Pushed__c = false;
	   			listOfTilesToUpdate.add(userTile);
	   		}
   		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(listOfTilesToUpdate),
			new List<Schema.SObjectField>{
				Tiles_Config__c.Is_Newly_Pushed__c
		});
		tilesOrderData.layout = (String.isNotBlank(UserContext.tileLayout)) ? UserContext.tileLayout : 'D';
		tilesOrderData.canManage = ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode); 
		// DASHBOARD_OWNER_USER = user //AppDashboardMode = null
		System.debug('********tilesOrderData  80'+tilesOrderData.canManage);

		
		String segmentId = UserContext.segmentId;
		soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		query = 'select id, OverwriteBatchInProgress__c from App_Default__c where Type__c = \'home-default\' And segment__c =:soqlParam1 LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		system.debug('listOfDefaultObj----'+listOfDefaultObj);
		if(!listOfDefaultObj.isEmpty()){
   			tilesOrderData.isProcessing = listOfDefaultObj[0].OverwriteBatchInProgress__c;
			   System.debug('((( TS(93((((isProcessing' + tilesOrderData.isProcessing);

 			tilesOrderData.isDefaultConfigured = true;
 		}else{
 			tilesOrderData.isProcessing = false;
			 System.debug('((TS((98((((isProcessing' + tilesOrderData.isProcessing);

 			tilesOrderData.isDefaultConfigured = false;
   		}
   		tilesOrderData.isManagerControlled = false;
 		tilesOrderData.listOfItems = mapOfOrderedTile.values();
		logger.logDebug('TileService.getUserHomeTilesOrderConfig()----tilesOrderData----'+tilesOrderData);
    	
   		return tilesOrderData;
    }
    
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	/**
	 * @description fetch App Manager home tile recorrd
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	*/
	public TileDataWrapper.TileOrderData getAppManagerHomeTilesOrderConfig(Boolean isMobileOrigin, List<String> mobileTileList) {
    	logger.logDebug('TileService.getAppManagerHomeTilesOrderConfig()');
   		TileDataWrapper.TileOrderData tilesOrderData = new TileDataWrapper.TileOrderData();
   		
   		List<String> listOfAppConfigTiles = new List<String>();
   		if(SimpplrContext.appConfig != null && String.isNotBlank(SimpplrContext.appConfig.App_Home_Dashboard_Tile_Ids__c)){
			listOfAppConfigTiles = SimpplrContext.appConfig.App_Home_Dashboard_Tile_Ids__c.split(',');
   		}
   		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfAppConfigTiles);
		String query = 'SELECT Id, Name__c, Data__c,Mobile_Order__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c, CreatedDate ' +
			' FROM Tiles_Config__c where people__c = null And id IN :soqlParam1 And Is_Deleted__c = false ';

		if(isMobileOrigin == true) {
			soqlParamMap.put('soqlParam2', mobileTileList);
			query += 'And Variant_Type__c In: soqlParam2 ';
		}
		query +=' order by Layout_Column__c, Order__c,CreatedDate desc';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfAppDashboardTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		List<Tiles_Config__c> newListOfAppDashboardTiles = listOfAppDashboardTiles.clone();
		
 		Map<String, TileDataWrapper.TilesOrder> mapOfOrderedTile = new Map<String, TileDataWrapper.TilesOrder>();
		
		String peopleId = UserContext.peopleId;
		List<People_Preference__c> peoplePrefList = [SELECT Id, Disable_Onboarding_Home_Tile__c FROM People_Preference__c WHERE People__r.Id =:peopleId AND Is_Deleted__c = false AND People__r.Is_Deleted__c = false WITH SECURITY_ENFORCED];
		
		if(!peoplePrefList.isEmpty() && peoplePrefList[0].Disable_Onboarding_Home_Tile__c){
			for(Tiles_Config__c appDashboardTile : listOfAppDashboardTiles) {
				if('content_onboarding'.equalsIgnoreCase(appDashboardTile.Variant__c)){
					Integer i = newListOfAppDashboardTiles.indexOf(appDashboardTile);
					newListOfAppDashboardTiles.remove(i);
				}
			}
		}
		
		
		for(Tiles_Config__c appDashboardTile : newListOfAppDashboardTiles) {
   			if('content'.equalsIgnoreCase(appDashboardTile.Type__c) && 'latest_popular'.equalsIgnoreCase(appDashboardTile.Variant__c)) {
   				TileDataWrapper.TileDataSettings widgetData = (TileDataWrapper.TileDataSettings)JSON.deserialize(appDashboardTile.Data__c,TileDataWrapper.TileDataSettings.class);
	   			if(isContentFeatureDisabled(widgetData.type)){
					continue;
				}
   			} else if('campaigns'.equalsIgnoreCase(appDashboardTile.Type__c)) {
   				if(SimpplrContext.isEmployeeAdvocacyEnabled == false){
   					continue;
   				}
   			}
   			TileDataWrapper.TilesOrder orderedTile = new TileDataWrapper.TilesOrder();
   			orderedTile.id = appDashboardTile.Id;
	   		orderedTile.order = appDashboardTile.Order__c.intValue();	
	   		orderedTile.mobileDashboardIndex = appDashboardTile.Mobile_Order__c != null ? appDashboardTile.Mobile_Order__c.intValue() : 0;
	   		orderedTile.column = String.valueOf(appDashboardTile.Layout_Column__c);
			orderedTile.title = appDashboardTile.Name__c;
			orderedTile.type = appDashboardTile.Type__c;
			orderedTile.variant = appDashboardTile.Variant__c;
			mapOfOrderedTile.put(orderedTile.id, orderedTile);
	   				
   		}
		   tilesOrderData.layout = (String.isNotBlank(SimpplrContext.tileLayout)) ? SimpplrContext.tileLayout : 'D';

		

		tilesOrderData.layout = (String.isNotBlank(SimpplrContext.tileLayout)) ? SimpplrContext.tileLayout : 'D';

	// 	//*********************** */
	// 	String userId = UserInfo.getUserId();
	// 	list<PermissionSetAssignment> lstUserIdvsPermissionSet = [SELECT Id,Assignee.Profile.name, PermissionSet.Name, AssigneeId,Assignee.UserType FROM PermissionSetAssignment WHERE AssigneeId = :UserId];
	// 	system.debug('******size******'+lstUserIdvsPermissionSet.size());
	// 	if(lstUserIdvsPermissionSet!=null && !lstUserIdvsPermissionSet.isEmpty()){
	// 		if(lstUserIdvsPermissionSet.size() == 2 && (lstUserIdvsPermissionSet[0].PermissionSet.Name == 'Simpplr_User' || lstUserIdvsPermissionSet[1].PermissionSet.Name == 'Simpplr_User')){
	// 			system.debug('******false******');
	// 			tilesOrderData.canManage = false;
	// 		}else if(lstUserIdvsPermissionSet.size() > 2){
	// 			system.debug('******true******');
	// 			tilesOrderData.canManage = UserContext.canControlHomeDashboard || (UserContext.isUserAppModerator && ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode));
	// 		}
	// 	}
	// //************************ */

   		tilesOrderData.canManage = UserContext.canControlHomeDashboard || (UserContext.isUserAppModerator && ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode));
		//Can_Control_Dashboard__c = fase   // (isUserAppModerator =  User__r.Profile.PermissionsModerateChatter= false // App_Moderation_Permission__c = No) // DASHBOARD_OWNER_APP_MANAGER = Mnager // AppDashboardMode = Manger

		System.debug('********tilesOrderData.canManage  180'+tilesOrderData.canManage);

   		tilesOrderData.isManagerControlled = (ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode));
   		tilesOrderData.listOfItems = mapOfOrderedTile.values();
		System.debug('********tilesOrderData  182'+tilesOrderData);

    	
   		return tilesOrderData;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	/**
	 * @description fetch home default tile order
	 * @param segmentId
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	*/
	public TileDataWrapper.TileOrderData getHomeDefaultTilesOrder(String segmentId, Boolean isMobileOrigin, List<String> mobileTileList) {
   		TileDataWrapper.TileOrderData tilesOrderData = new TileDataWrapper.TileOrderData();
  		Map<String, TileDataWrapper.TilesOrder> mapOfOrderedTile = new Map<String, TileDataWrapper.TilesOrder>();
   		List<String> listOfHomeDefaultTileIds = new List <String>();
   		List<Tiles_Config__c> listOfHomeDefaultTiles = new List<Tiles_Config__c>();
   		
   		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'select id, Data__c, Layout__c,OverwriteBatchInProgress__c,Last_Modified_By_People__c, Last_Modified_By_People__r.First_Name__c, LastModifiedDate, Last_Modified_By_People__r.Last_Name__c from App_Default__c where Type__c = \'home-default\' And segment__c =:soqlParam1 LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   		
   		if(!listOfDefaultObj.isEmpty() && String.isNotBlank(listOfDefaultObj[0].Data__c)){
			listOfHomeDefaultTileIds = listOfDefaultObj[0].Data__c.split(',');
   		}
   		if(listOfHomeDefaultTileIds != null){
   			Map<String, Object> tileSoqlParamMap = new Map<String, Object>();
			tileSoqlParamMap.put('soqlParam1', listOfHomeDefaultTileIds);
			String tileQuery = 'SELECT Id, Name__c, Data__c,Mobile_Order__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
				' FROM Tiles_Config__c where id IN :soqlParam1 And Is_Deleted__c = false ';
				

			if(isMobileOrigin == true) {
				tileSoqlParamMap.put('soqlParam2', mobileTileList);
				tileQuery += ' And Variant_Type__c In: soqlParam2 ';
			}
			tileQuery += ' order by Layout_Column__c, Order__c,CreatedDate desc';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			listOfHomeDefaultTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(tileQuery, tileSoqlParamMap);
			
  			for(Tiles_Config__c homeDefaultTile : listOfHomeDefaultTiles) {
	   			if('content'.equalsIgnoreCase(homeDefaultTile.Type__c) && 'latest_popular'.equalsIgnoreCase(homeDefaultTile.Variant__c)) {
	   				TileDataWrapper.TileDataSettings tilesData = (TileDataWrapper.TileDataSettings)JSON.deserialize(homeDefaultTile.Data__c,TileDataWrapper.TileDataSettings.class);
		   			if(isContentFeatureDisabled(tilesData.type)){
		   				continue;
		   			}
	   			} else if('campaigns'.equalsIgnoreCase(homeDefaultTile.Type__c)) {
	   				if(SimpplrContext.isEmployeeAdvocacyEnabled == false){
	   					continue;
	   				}
	   			}
	   			TileDataWrapper.TilesOrder orderedTile = new TileDataWrapper.TilesOrder();
	   			orderedTile.id = homeDefaultTile.Id;
				orderedTile.order = homeDefaultTile.Order__c.intValue();
				orderedTile.mobileDashboardIndex = homeDefaultTile.Mobile_Order__c != null ? homeDefaultTile.Mobile_Order__c.intValue() : 0;
	  			orderedTile.column = String.valueOf(homeDefaultTile.Layout_Column__c);
 				orderedTile.title = homeDefaultTile.Name__c;
   				orderedTile.type = homeDefaultTile.Type__c;
   				orderedTile.variant = homeDefaultTile.Variant__c;
   				mapOfOrderedTile.put(orderedTile.id, orderedTile);
		   				
   			}
   		}
   		if(SimpplrContext.isSegmentsEnabled) {
   			tilesOrderData.canManage = UserContext.isUserAppModerator || UserContext.isSegmentManager;
			 // (isUserAppModerator =  User__r.Profile.PermissionsModerateChatter= false // App_Moderation_Permission__c = No) // isSegmentManager = Is_Segment_Manager__c = False
			System.debug('********tilesOrderData  262'+tilesOrderData.canManage);
   		} else {
	   		tilesOrderData.canManage = UserContext.isUserAppModerator || UserContext.canControlHomeDashboard;
			// (isUserAppModerator =  User__r.Profile.PermissionsModerateChatter= false // App_Moderation_Permission__c = No) //canControlHomeDashboard = Can_Control_Dashboard__c =false
			System.debug('********tilesOrderData  267'+tilesOrderData.canManage);
   		}
		if(!listOfDefaultObj.isEmpty()){
			tilesOrderData.layout = (String.isNotBlank(listOfDefaultObj[0].Layout__c)) ? listOfDefaultObj[0].Layout__c : 'D';
   			tilesOrderData.isDefaultConfigured = true;
	   		tilesOrderData.modifiedAt = listOfDefaultObj[0].LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	   		tilesOrderData.isProcessing = listOfDefaultObj[0].OverwriteBatchInProgress__c;

	   		TileDataWrapper.PeopleDetail pplDetail = new TileDataWrapper.PeopleDetail();
	   		pplDetail.id = listOfDefaultObj[0].Last_Modified_By_People__c;
	   		pplDetail.name = Utility.buildName(listOfDefaultObj[0].Last_Modified_By_People__r.First_Name__c,listOfDefaultObj[0].Last_Modified_By_People__r.Last_Name__c);
			pplDetail.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + listOfDefaultObj[0].Last_Modified_By_People__c;
			tilesOrderData.modifiedBy = pplDetail;
		}else{
   			tilesOrderData.isDefaultConfigured = false;
   			tilesOrderData.isProcessing = false;
			tilesOrderData.layout ='D';
		}
   			
   		
   		tilesOrderData.listOfItems = mapOfOrderedTile.values();	
		logger.logDebug('TileService.getHomeDefaultTilesOrder()----tilesOrderData----'+tilesOrderData);
    	
   		return tilesOrderData;
    }
    
		/**
	 * @description fetch site tile record
	 * @param siteId
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	 */
	public TileDataWrapper.TileOrderData getSiteTilesOrderConfig(String siteId, Boolean isMobileOrigin, List<String> mobileTileList) {
		logger.logDebug('TileService.getSiteTilesOrderConfig()----siteId----'+siteId);
    	TileDataWrapper.TileOrderData tilesOrderData = new TileDataWrapper.TileOrderData();
    	
    	Simpplr_Site__c siteObj = [Select id, Chatter_group_Id__c From Simpplr_Site__c where is_Active__c=true and Id=:siteId And Is_Deleted__c = false WITH SECURITY_ENFORCED limit 1];
    	
    	String informationTitle = '';
    	if(siteObj != null){
    		String groupId = siteObj.Chatter_group_Id__c;
    		List <CollaborationGroup> listOfCollaborationGroups = new List <CollaborationGroup>();
	    	String BASE_QUERY= 'select InformationTitle from CollaborationGroup where id =: groupId ';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+'AND NetworkId = null';
	    	}
			listOfCollaborationGroups = Database.query(BASE_QUERY);
    		
    		if(listOfCollaborationGroups.isEmpty()) {
    			throw new SimpplrException(ServiceConstants.ERROR_404);
    		}
    		
    		CollaborationGroup collabGroupObj = listOfCollaborationGroups[0];
    		
    		informationTitle = String.isNotBlank(collabGroupObj.informationTitle) ? collabGroupObj.informationTitle : 'Information';
    	}

		List<TileDataWrapper.TilesOrder> tileOrderDataList = new List<TileDataWrapper.TilesOrder>();
			
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		String query = 'SELECT Id, Name__c, Data__c,Mobile_Order__c, Layout_Column__c, Order__c, People__c, Site__c, Site__r.Has_Pages__c, Type__c, Variant__c ' +
			' FROM Tiles_Config__c where site__c=:soqlParam1 And Location__c = \'Site Dashboard\' And Is_Deleted__c = false ';
			

		if(isMobileOrigin == true) {
			soqlParamMap.put('soqlParam2', mobileTileList);
			query += ' And Variant_Type__c In: soqlParam2 ';
		}
		query +=' order by Layout_Column__c, Order__c,CreatedDate desc';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfSiteTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   			
  		for(Tiles_Config__c siteTileObj : listOfSiteTiles) {
 			if('content'.equalsIgnoreCase(siteTileObj.Type__c) && 'latest_popular'.equalsIgnoreCase(siteTileObj.Variant__c)) {
   				TileDataWrapper.TileDataSettings tilesData = (TileDataWrapper.TileDataSettings)JSON.deserialize(siteTileObj.Data__c,TileDataWrapper.TileDataSettings.class);

				if(isContentFeatureDisabled(tilesData.type) 
						|| !('all'.equalsIgnoreCase(tilesData.type) || (SiteContext.siteAllowedFeatures).containsIgnoreCase(tilesData.type)) ){

   					continue;
   				}
   			} else if('campaigns'.equalsIgnoreCase(siteTileObj.Type__c)) {
   				if(SimpplrContext.isEmployeeAdvocacyEnabled == false){
   					continue;
   				}
   			} else if('page_categories'.equalsIgnoreCase(siteTileObj.Type__c)) {
				List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
				Set<String>  allowedFeaturesInAppSet = new  Set<String>();
				for(String feature : allowedFeaturesInAppList) {
					allowedFeaturesInAppSet.add(feature.toLowerCase());
				}

				if(!allowedFeaturesInAppSet.contains('page') || !siteTileObj.Site__r.Has_Pages__c) {
					continue;
				}

			}
			TileDataWrapper.TilesOrder orderedTile = new TileDataWrapper.TilesOrder();
		   	orderedTile.id = siteTileObj.Id;
		   	orderedTile.order = siteTileObj.Order__c.intValue();
		   	orderedTile.mobileDashboardIndex = siteTileObj.Mobile_Order__c != null ? siteTileObj.Mobile_Order__c.intValue() : 0;
		   	orderedTile.column = String.valueOf(siteTileObj.Layout_Column__c);
			   			
			orderedTile.title = siteTileObj.Name__c;
			orderedTile.type = siteTileObj.Type__c;
			orderedTile.variant = siteTileObj.Variant__c;
			
	   		tileOrderDataList.add(orderedTile);
			 
			if('site_info'.equalsIgnoreCase(siteTileObj.Type__c)) {
	   			orderedTile.title = informationTitle;
			}
   		}
		tilesOrderData.layout = (String.isNotBlank(SiteContext.tileLayout)) ? SiteContext.tileLayout : 'D';
		tilesOrderData.canManage =  AccessManager.hasUserManageDashboardAccess(siteId);
		System.debug('********tilesOrderData  387'+tilesOrderData.canManage);

		tilesOrderData.isDefaultConfigured = false;
   		tilesOrderData.isManagerControlled = ('App Manager'.equalsIgnoreCase(SimpplrContext.SiteDashboardMode));
   		tilesOrderData.listOfItems = tileOrderDataList;
    	logger.logDebug('TileService.getSiteTilesOrderConfig()----tilesOrderData----'+tilesOrderData);
    	
   		return tilesOrderData;
    }
    
	/**
	 * @description fetch segment tile order
	 * @param segmentId
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	 */
    public TileDataWrapper.TileOrderData getSegmentTilesOrderConfig(String segmentId, Boolean isMobileOrigin, List<String> mobileTileList) {
		logger.logDebug('TileService.getSegmentTilesOrderConfig()----segmentId----'+segmentId);
    	TileDataWrapper.TileOrderData tilesOrderData = new TileDataWrapper.TileOrderData();
    	
		List<TileDataWrapper.TilesOrder> tileOrderDataList = new List<TileDataWrapper.TilesOrder>();
			
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'SELECT Id, Name__c, Data__c,Mobile_Order__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
		' FROM Tiles_Config__c where Segment__c = :soqlParam1 And Location__c = \'Segment Dashboard\' And Is_Deleted__c = false ';
		if(isMobileOrigin == true) { 
			soqlParamMap.put('soqlParam2', mobileTileList);
			query += 'And Variant__c Not In: soqlParam2 ';
		}
		query += ' order by Layout_Column__c, Order__c,CreatedDate desc';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfSegmentTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   			
  		for(Tiles_Config__c segmentTileObj : listOfSegmentTiles) {
 			if('content'.equalsIgnoreCase(segmentTileObj.Type__c) && 'latest_popular'.equalsIgnoreCase(segmentTileObj.Variant__c)) {
   				TileDataWrapper.TileDataSettings tilesData = (TileDataWrapper.TileDataSettings)JSON.deserialize(segmentTileObj.Data__c,TileDataWrapper.TileDataSettings.class);
	   			if(isContentFeatureDisabled(tilesData.type)){
   					continue;
   				}
   			} else if('campaigns'.equalsIgnoreCase(segmentTileObj.Type__c)) {
   				if(SimpplrContext.isEmployeeAdvocacyEnabled == false){
   					continue;
   				}
   			}
			TileDataWrapper.TilesOrder orderedTile = new TileDataWrapper.TilesOrder();
		   	orderedTile.id = segmentTileObj.Id;
		   	orderedTile.order = segmentTileObj.Order__c.intValue();
		   	orderedTile.mobileDashboardIndex = segmentTileObj.Mobile_Order__c != null ? segmentTileObj.Mobile_Order__c.intValue() : 0;
		   	orderedTile.column = String.valueOf(segmentTileObj.Layout_Column__c);
			   			
			orderedTile.title = segmentTileObj.Name__c;
			orderedTile.type = segmentTileObj.Type__c;
			orderedTile.variant = segmentTileObj.Variant__c;
	   		tileOrderDataList.add(orderedTile);
   		}
		Map<String, Object> soqlParamMap1 = new  Map<String, Object>();
		soqlParamMap1.put('soqlParam1', segmentId);
		query = 'Select Layout__c from Segment__c where id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Segment__c> segmentList  = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap1);
		
		if(!segmentList.isEmpty()) {
			tilesOrderData.layout = (String.isNotBlank(segmentList[0].Layout__c)) ? segmentList[0].Layout__c : 'D';
		}

		//*********************** */
		// System.debug('check this method---');
		// String userId = UserInfo.getUserId();
		// list<PermissionSetAssignment> lstUserIdvsPermissionSet = [SELECT Id,Assignee.Profile.name, PermissionSet.Name, AssigneeId,Assignee.UserType FROM PermissionSetAssignment WHERE AssigneeId = :UserId];
		// system.debug('******size******'+lstUserIdvsPermissionSet.size());
		// if(lstUserIdvsPermissionSet!=null && !lstUserIdvsPermissionSet.isEmpty()){
		// 	if(lstUserIdvsPermissionSet.size() == 2 && (lstUserIdvsPermissionSet[0].PermissionSet.Name == 'Simpplr_User' || lstUserIdvsPermissionSet[1].PermissionSet.Name == 'Simpplr_User')){
		// 		system.debug('******false******');
		// 		tilesOrderData.canManage = false;
		// 	}else if(lstUserIdvsPermissionSet.size() > 2){
		// 		system.debug('******true******');
		// 		tilesOrderData.canManage = (UserContext.isSegmentManager || UserContext.isUserAppModerator);
		// 	}
		// }
	//************************ */

   		tilesOrderData.canManage = (UserContext.isSegmentManager || UserContext.isUserAppModerator);
		//isSegmentManager = Is_Segment_Manager__c =false // // isUserAppModerator =  User__r.Profile.PermissionsModerateChatter= false // App_Moderation_Permission__c = No 
		System.debug('********tilesOrderData  491'+tilesOrderData.canManage);

   		tilesOrderData.isDefaultConfigured = false;
   		tilesOrderData.isManagerControlled = (ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode));
   		tilesOrderData.listOfItems = tileOrderDataList;
		   System.debug('********tilesOrderData  496'+tilesOrderData);

   		return tilesOrderData;
    }
    
    private void updateTilesInitializedInPeopleContext(String peopleId, String layout) {
    	People_Preference__c peoplePrefObject = [Select Id, Tiles_Initialized__c, Layout__c from People_Preference__c where People__c = :peopleId WITH SECURITY_ENFORCED];
		
		peoplePrefObject.Tiles_Initialized__c = true;
		peoplePrefObject.Layout__c = layout;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(peoplePrefObject, new List<Schema.SObjectField>{People_Preference__c.Tiles_Initialized__c, People_Preference__c.Layout__c});
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void setHomeDashboardPosition(String positionJson) {
    	logger.logDebug('TileService.setHomeDashboardPosition()----positionJson----'+positionJson);
    	try{
    		String appConfigQuery = 'Select id, App_Home_Dashboard_Tile_Ids__c From App_Config__c LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
			
			List<String> listOfAppHomeTileIds = new List<String>();
			if(!listOfAppConfig.isEmpty() && String.isNotBlank(listOfAppConfig[0].App_Home_Dashboard_Tile_Ids__c)){
				listOfAppHomeTileIds = listOfAppConfig[0].App_Home_Dashboard_Tile_Ids__c.split(',');
			} 
			String commaSeperatedAppHomeTileIds ='';	
		
	    	Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', listOfAppHomeTileIds);
			String query = 'SELECT Id, Name__c, Data__c, Is_Manager_Driven__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
				' FROM Tiles_Config__c where people__c = null And id IN :soqlParam1 And Location__c = \'Home Dashboard\' And Is_Deleted__c = false ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> userWidgetPrefList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    	
	    	Map<String,Tiles_Config__c> jsWidgetIdToWidgetMap = new Map<String,Tiles_Config__c>();
	    	
	    	for(Tiles_Config__c widget : userWidgetPrefList){
	    		commaSeperatedAppHomeTileIds += widget.id + ',';
	    		jsWidgetIdToWidgetMap.put(widget.Id,widget);
	    	}
	    	commaSeperatedAppHomeTileIds = commaSeperatedAppHomeTileIds.removeEnd(',');
	    	Integer orderSeq = 1;
	    	
	    	Map<String,Object> positionObj = (Map<String,Object>)JSON.deserializeUntyped(positionJson);
	    	
	    	Set<String> widgetIdSet = new Set<String>();
	    	if(positionObj!= null) {
	    		List<Tiles_Config__c> widgetList = new List<Tiles_Config__c>();
	    		for(String column : positionObj.keySet()) {
	    			if(positionObj.get(column) !=null) {
		    			for(Object columnItem : (List<Object>)positionObj.get(column)){
		    				String columnItemOrder  = String.valueOf(columnItem);
		    				if(jsWidgetIdToWidgetMap.get(columnItemOrder) != null) {
		    					Tiles_Config__c widgetObj = jsWidgetIdToWidgetMap.get(columnItemOrder);
		    					if(!widgetIdSet.contains(jsWidgetIdToWidgetMap.get(columnItemOrder).id)) {
			    					widgetObj.Layout_Column__c = Integer.valueOf(column);
			    					widgetObj.Order__c = orderSeq;
			    					widgetList.add(widgetObj);
			    					widgetIdSet.add(jsWidgetIdToWidgetMap.get(columnItemOrder).id);
		    					}
		    				}
				    	orderSeq = orderSeq + 1;
		    			}
	    			}
	    			orderSeq = 1;
	    		}
		    	update(widgetList);
	    	}
	    	listOfAppConfig[0].App_Home_Dashboard_Tile_Ids__c = commaSeperatedAppHomeTileIds;
	    	
			if(!listOfAppConfig.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(listOfAppConfig),new List<Schema.SObjectField> {
																											App_Config__c.App_Home_Dashboard_Tile_Ids__c
																										});
			}

    	} catch(Exception e) {            
        	logger.logError(e.getStackTraceString()); 
    	}
    	
    	
    }
    
    public void setUserHomeDashboardPosition(String positionJson) {
    	logger.logDebug('TileService.setHomeDashboardPosition()----positionJson----'+positionJson);
    	try{
	    	List<Tiles_Config__c> userWidgetPrefList = null;
	    	
	    	String userId = UserContext.id;
	    	Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', userId);
			String query = 'SELECT Id, Name__c, Data__c, Is_Manager_Driven__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
				' FROM Tiles_Config__c where people__r.User__c = :soqlParam1 And Location__c = \'Home Dashboard\' And Is_Deleted__c = false ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			userWidgetPrefList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    	
	    	Map<String,Tiles_Config__c> jsWidgetIdToWidgetMap = new Map<String,Tiles_Config__c>();
	    	
	    	for(Tiles_Config__c widget : userWidgetPrefList){
	    		jsWidgetIdToWidgetMap.put(widget.Id,widget);
	    	}
	    	
	    	Integer orderSeq = 1;
	    	
	    	Map<String,Object> positionObj = (Map<String,Object>)JSON.deserializeUntyped(positionJson);
	    	
	    	Set<String> widgetIdSet = new Set<String>();
	    	if(positionObj!= null) {
	    		List<Tiles_Config__c> widgetList = new List<Tiles_Config__c>();
	    		for(String column : positionObj.keySet()) {
	    			if(positionObj.get(column) !=null) {
		    			for(Object columnItem : (List<Object>)positionObj.get(column)){
		    				String columnItemOrder  = String.valueOf(columnItem);
		    				if(jsWidgetIdToWidgetMap.get(columnItemOrder) != null) {
		    					Tiles_Config__c widgetObj = jsWidgetIdToWidgetMap.get(columnItemOrder);
		    					if(!widgetIdSet.contains(jsWidgetIdToWidgetMap.get(columnItemOrder).id)) {
			    					widgetObj.Layout_Column__c = Integer.valueOf(column);
			    					widgetObj.Order__c = orderSeq;
			    					widgetList.add(widgetObj);
			    					widgetIdSet.add(jsWidgetIdToWidgetMap.get(columnItemOrder).id);
		    					}
		    				}
				    	orderSeq = orderSeq + 1;
		    			}
	    			}
	    			orderSeq = 1;
	    		}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(widgetList),
					new List<Schema.SObjectField>{
						Tiles_Config__c.Layout_Column__c,
						Tiles_Config__c.Order__c
				});
	    	}
	    	
    	} catch(Exception e) {            
        	logger.logError(e.getStackTraceString()); 
    	}
    	
    	
    }
    
    public void setHomeDefaultPosition(String segmentId, String positionJson) {
    		logger.logDebug('TileService.setHomeDefaultPosition()----segmentId----' + '----positionJson----'+positionJson);
	    	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id, Data__c From App_Default__c where Segment__c=:soqlParam1 And Type__c=\'home-default\' LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		List<String> listOfHomeDefaultTileIds = new List<String>();
		if(!listOfDefaultObj.isEmpty() && String.isNotBlank(listOfDefaultObj[0].Data__c)){
			listOfHomeDefaultTileIds = listOfDefaultObj[0].Data__c.split(',');
		} 
		String commaSeperatedDefaultTileIds ='';	
		Map<String, Object> tileSoqlParamMap = new Map<String, Object>();
		tileSoqlParamMap.put('soqlParam1', listOfHomeDefaultTileIds);
		String tilesQuery = 'SELECT Id, Name__c, Data__c, Is_Manager_Driven__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
			' FROM Tiles_Config__c where Location__c = \'Home Default\' And Id IN:soqlParam1 And Is_Deleted__c = false ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> homeDefaultWidgetList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(tilesQuery, tileSoqlParamMap);
    	
		Map<String,Tiles_Config__c> jsWidgetIdToWidgetMap = new Map<String,Tiles_Config__c>();
    	
	    	for(Tiles_Config__c widget : homeDefaultWidgetList){
		    	commaSeperatedDefaultTileIds += widget.Id + ',';
		    	jsWidgetIdToWidgetMap.put(widget.Id,widget);
	    	}
    		commaSeperatedDefaultTileIds = commaSeperatedDefaultTileIds.removeEnd(',');
    	
    		Integer orderSeq = 1;
    	
    		Map<String,Object> positionObj = (Map<String,Object>)JSON.deserializeUntyped(positionJson);
    	
	    	Set<String> widgetIdSet = new Set<String>();
	    	if(positionObj!= null) {
		    	List<Tiles_Config__c> widgetList = new List<Tiles_Config__c>();
		    	
		    	for(String column : positionObj.keySet()) {
		    		
		    		if(positionObj.get(column) !=null) {
		    			
			    		for(Object columnItem : (List<Object>)positionObj.get(column)) {
			    			String columnItemOrder  = String.valueOf(columnItem);
			    			
			    			if(jsWidgetIdToWidgetMap.get(columnItemOrder) != null) {
			    				Tiles_Config__c widgetObj = jsWidgetIdToWidgetMap.get(columnItemOrder);
			    				
			    				if(!widgetIdSet.contains(jsWidgetIdToWidgetMap.get(columnItemOrder).id)) {
				    				widgetObj.Layout_Column__c = Integer.valueOf(column);
				    				widgetObj.Order__c = orderSeq;
				    				widgetList.add(widgetObj);
				    				widgetIdSet.add(jsWidgetIdToWidgetMap.get(columnItemOrder).id);
			    				}
			    			}
				    	orderSeq = orderSeq + 1;
			    		}
		    		}
		    		orderSeq = 1;
		    	}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(widgetList),
					new List<Schema.SObjectField>{
						Tiles_Config__c.Layout_Column__c,
						Tiles_Config__c.Order__c
				});
    		}
	    	
    		if(!listOfDefaultObj.isEmpty()) {
    			
			for (App_Default__c  appDefaultObj : listOfDefaultObj){
				appDefaultObj.Data__c = commaSeperatedDefaultTileIds;
				appDefaultObj.Last_Modified_By_People__c = UserContext.getCurrentUserInfo.Id;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Default__c>(listOfDefaultObj), 
				new List<Schema.SObjectField>{
					App_Default__c.Data__c,
					App_Default__c.Last_Modified_By_People__c
				}
			);
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
    public void setSiteDashboardPosition(String siteId, String positionJson) {
    	logger.logDebug('TileService.setSiteDashboardPosition()----siteId----'+siteId+'---positionJson----'+positionJson);
    	try{
	    	Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId);
			String query = 'SELECT Id, Name__c, Data__c, Is_Manager_Driven__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c ' +
				' FROM Tiles_Config__c where site__c=:soqlParam1 and Location__c=\'Site Dashboard\' And Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> userWidgetPrefList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    	Map<String,Tiles_Config__c> jsWidgetIdToWidgetMap = new Map<String,Tiles_Config__c>();
	    	
	    	for(Tiles_Config__c widget : userWidgetPrefList){
	    		jsWidgetIdToWidgetMap.put(widget.Id,widget);
	    	}
	    	
	    	Integer orderSeq = 1;
	    	
	    	Map<String,Object> positionObj = (Map<String,Object>)JSON.deserializeUntyped(positionJson);
	    	
	    	Set<String> widgetIdSet = new Set<String>();
	    	if(positionObj!= null) {
	    		List<Tiles_Config__c> widgetList = new List<Tiles_Config__c>();
	    		for(String column : positionObj.keySet()) {
	    			if(positionObj.get(column) !=null) {
		    			for(Object columnItem : (List<Object>)positionObj.get(column)){
		    				String columnItemOrder  = String.valueOf(columnItem);
		    				if(jsWidgetIdToWidgetMap.get(columnItemOrder) != null) {
		    					Tiles_Config__c widgetObj = jsWidgetIdToWidgetMap.get(columnItemOrder);
		    					if(!widgetIdSet.contains(jsWidgetIdToWidgetMap.get(columnItemOrder).id)) {
			    					widgetObj.Layout_Column__c = Integer.valueOf(column);
			    					widgetObj.Order__c = orderSeq;
			    					widgetList.add(widgetObj);
			    					widgetIdSet.add(jsWidgetIdToWidgetMap.get(columnItemOrder).id);
		    					}
		    				}
				    	orderSeq = orderSeq + 1;
		    			}
	    			}
	    			orderSeq = 1;
	    		}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(widgetList),
				new List<Schema.SObjectField>{
					Tiles_Config__c.Layout_Column__c,
					Tiles_Config__c.Order__c
				});
	    	}
	    	
    	} catch(Exception e) {            
        	logger.logError(e.getStackTraceString()); 
    	}
    }
    
    public void setSegmentDashboardPosition(String segmentId, String positionJson) {
    	logger.logDebug('TileService.setSiteDashboardPosition()----segmentId----'+segmentId+'---positionJson----'+positionJson);
    	try{
	    	Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', segmentId);
			String query = 'SELECT Id, Name__c, Data__c, Is_Manager_Driven__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c ' +
				' FROM Tiles_Config__c where Segment__c=:soqlParam1 and Location__c=\'Segment Dashboard\' And Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> userWidgetPrefList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    	Map<String,Tiles_Config__c> jsWidgetIdToWidgetMap = new Map<String,Tiles_Config__c>();
	    	
	    	for(Tiles_Config__c widget : userWidgetPrefList){
	    		jsWidgetIdToWidgetMap.put(widget.Id,widget);
	    	}
	    	
	    	Integer orderSeq = 1;
	    	
	    	Map<String,Object> positionObj = (Map<String,Object>)JSON.deserializeUntyped(positionJson);
	    	
	    	Set<String> widgetIdSet = new Set<String>();
	    	if(positionObj!= null) {
	    		List<Tiles_Config__c> tilesList = new List<Tiles_Config__c>();
	    		for(String column : positionObj.keySet()) {
	    			if(positionObj.get(column) !=null) {
		    			for(Object columnItem : (List<Object>)positionObj.get(column)){
		    				String columnItemOrder  = String.valueOf(columnItem);
		    				if(jsWidgetIdToWidgetMap.get(columnItemOrder) != null) {
		    					Tiles_Config__c widgetObj = jsWidgetIdToWidgetMap.get(columnItemOrder);
		    					if(!widgetIdSet.contains(jsWidgetIdToWidgetMap.get(columnItemOrder).id)) {
			    					widgetObj.Layout_Column__c = Integer.valueOf(column);
			    					widgetObj.Order__c = orderSeq;
			    					tilesList.add(widgetObj);
			    					widgetIdSet.add(jsWidgetIdToWidgetMap.get(columnItemOrder).id);
		    					}
		    				}
				    	orderSeq = orderSeq + 1;
		    			}
	    			}
	    			orderSeq = 1;
	    		}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(tilesList),
				new List<Schema.SObjectField>{
					Tiles_Config__c.Layout_Column__c,
					Tiles_Config__c.Order__c
				});
	    	}
	    	
    	} catch(Exception e) {            
        	logger.logError(e.getStackTraceString()); 
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
    public  TileDataWrapper.LatestHiresData getLatestHires(String siteOrHomeId, String segmentId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getLatestHires()----siteOrHomeId----'+siteOrHomeId+'---segmentId----'+segmentId+'---tileId----'+tileId);
    	TileDataWrapper.LatestHiresData latestHiresData= new TileDataWrapper.LatestHiresData();
		Integer daysLimit = '7'.equalsIgnoreCase(tiledataSetting.hireDaysThreshold) ? 7 : 30;
		PeopleDao peopleDaoObj = new PeopleDao();
        List<People__c> peopleList = new List<People__c>();
        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
            ExternalSearchService searchServiceObj = new ExternalSearchService();
            List<String> peopleIds = searchServiceObj.getLatestHiresId(500, daysLimit);
            Map<Id, People__c> peopleMap = new Map<Id, People__c>(peopleDaoObj.getLatestHiresForTilesData(siteOrHomeId, segmentId, null, peopleIds));
            for(String peopleId : peopleIds) {
                if(peopleMap.containsKey(peopleId)) {
                    peopleList.add(peopleMap.get(peopleId));
                }
            }
        } else {
            peopleList = peopleDaoObj.getLatestHiresForTilesData(siteOrHomeId, segmentId, daysLimit, null);
        }
        TileDataWrapper.TileData latestHireObj; 
    	Set<Id> follwersIdSet = UserContext.usersIFollowIdSet;
        
        for(People__c peopleObj : peopleList){
            latestHireObj = new TileDataWrapper.TileData();
            latestHireObj.id = peopleObj.id;
            latestHireObj.sfUserId = peopleObj.User__c;
            latestHireObj.peopleId = peopleObj.id;
            latestHireObj.name = peopleObj.Full_Name__c;
            latestHireObj.location = Utility.buildLocation(peopleObj.City__c, peopleObj.State__c, peopleObj.Country__c);
            latestHireObj.department = peopleObj.Department__c;
            latestHireObj.img = peopleObj.user__r.FullPhotoURL.endsWith('005/F') ? null : peopleObj.user__r.FullPhotoURL;
            latestHireObj.title = peopleObj.Title__c;
            latestHireObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.id;
            latestHireObj.isFollowing = follwersIdSet.contains(peopleObj.User__c)?true:false;
            latestHireObj.isFavorited = peopleObj.Bookmark_Receiver_People__r.size() > 0;
            latestHireObj.isActive = peopleObj.User__r.isactive;
            if(SimpplrContext.isPPJoiningDateDisplay){
            	latestHireObj.hireDate = Utility.dateToDisplayString(peopleObj.Joining_Date__c,'yyyy-MM-dd');
            }
        	if (UserContext.peopleId == peopleObj.Id) {
				latestHireObj.canFollow = false;
			} else {
				latestHireObj.canFollow = peopleObj.User__r.isactive;
			}
            latestHiresData.listOfItems.add(latestHireObj);
        }
    	latestHiresData.id=tileId;
		latestHiresData.options.layout = tiledataSetting.layout;
		latestHiresData.options.hireDaysThreshold = String.valueOf(daysLimit);
        logger.logDebug('TileService.getLatestHires()----latestHiresData----'+latestHiresData);
        return latestHiresData;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public TileDataWrapper.WidgetOptions getGroupDescription(String siteId, String tileId){
		TileDataWrapper.WidgetOptions about = new TileDataWrapper.WidgetOptions();
		TileDataWrapper.Options options	= new TileDataWrapper.Options();				
		String description = '';
		if(String.isNotBlank(siteId)) {
			List<Simpplr_Site__c> simpplrSiteList = [SELECT Chatter_Group_Id__c From Simpplr_Site__c WHERE Id=:siteId WITH SECURITY_ENFORCED];
			if(!simpplrSiteList.isEmpty() && String.isNotEmpty(simpplrSiteList[0].Chatter_Group_Id__c)) {
				String groupId = simpplrSiteList[0].Chatter_group_Id__c;
		    	String BASE_QUERY= 'select Description FROM CollaborationGroup WHERE Id=: groupId ';
				if(SimpplrContext.isCommunitiesEnabled){
		    		BASE_QUERY = BASE_QUERY+'AND NetworkId = null';
		    	}
				List<CollaborationGroup> listOfChatterGroup = new List<CollaborationGroup>();
				listOfChatterGroup = Database.query(BASE_QUERY);
				if(!listOfChatterGroup.isEmpty()) {
					if(string.isNotBlank(listOfChatterGroup[0].Description)){
        				description = listOfChatterGroup[0].Description;
					}
				}
			}
		}
		options.text = description;
		about.options = options;
		return about;
	}
	
	public TileDataWrapper.WidgetOptions getSiteInformationTileData(String siteId, String tileId){
		TileDataWrapper.WidgetOptions informationTile = new TileDataWrapper.WidgetOptions();				
		TileDataWrapper.Options options	= new TileDataWrapper.Options();
		String InformationBody = '';
		String InformationHeading = '';
		if(String.isNotBlank(siteId)) {
			List<Simpplr_Site__c> simpplrSiteList = [SELECT Chatter_Group_Id__c From Simpplr_Site__c WHERE Id=:siteId WITH SECURITY_ENFORCED];
			if(!simpplrSiteList.isEmpty() && String.isNotEmpty(simpplrSiteList[0].Chatter_Group_Id__c)) {
				String groupId = simpplrSiteList[0].Chatter_group_Id__c;
		    	String BASE_QUERY= 'select InformationBody,InformationTitle FROM CollaborationGroup WHERE Id=: groupId ';
				if(SimpplrContext.isCommunitiesEnabled){
		    		BASE_QUERY = BASE_QUERY+'AND NetworkId = null';
		    	}
				List<CollaborationGroup> listOfChatterGroup = new List<CollaborationGroup>();
				listOfChatterGroup = Database.query(BASE_QUERY);
				if(!listOfChatterGroup.isEmpty()) {
					if(string.isNotBlank(listOfChatterGroup[0].InformationBody)){
        				InformationBody = listOfChatterGroup[0].InformationBody;
					}
					if(string.isNotBlank(listOfChatterGroup[0].InformationTitle)){
						InformationHeading = listOfChatterGroup[0].InformationTitle;
					}
				}
			}
		} 
		options.text = InformationBody;
		informationTile.options = options;
		return informationTile;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
	public TileDataWrapper.MySitesData getSiteList(String siteOrHomeId, String tileId,String variant, TileDataWrapper.TileDataSettings tiledataSetting) {
	    TileDataWrapper.MySitesData mySiteData = new TileDataWrapper.MySitesData();
	    Map<Id, Simpplr_Site__c> mapOfIdWithSimpplrSite = new Map<Id, Simpplr_Site__c>();
	    Integer limitOfGroups = tiledataSetting.size != null?tiledataSetting.size : 0;
	    List<String> listOfGrpIds = new List<String>();
	    if(String.isNotBlank(tiledataSetting.value)){
	    	listOfGrpIds = tiledataSetting.value.split(',');
	    }
	    List<CollaborationGroup> listOfCollaborationGroup = new List<CollaborationGroup>();
	    List<CollaborationGroup> listOfCollaborationGroupInOrder = new List<CollaborationGroup>();
	   
	    String BASE_QUERY = '';
	    String subConditionString = '';
	    
	    if('custom'.equalsIgnoreCase(variant)){
			mySiteData.listOfItems.addAll(getCustomSiteList(limitOfGroups,listOfGrpIds));
		    }
	    mySiteData.options.size = limitOfGroups;
	    mySiteData.id = tileId;
    	logger.logDebug('TileService.mySiteData()----mySiteData----'+mySiteData);
    	
	    return mySiteData;
	}
    
    private List<TileDataWrapper.TileData> getCustomSiteList(Integer limitOfGroups,List<String> listOfGrpIds) {
		List<TileDataWrapper.TileData> customSiteList =  new List<TileDataWrapper.TileData>();
		
		Map<String,String> groupIdToFeaturesMap = new Map<String,String>();
		Map<String,Simpplr_site__c> groupIdsAndSiteMap = new Map<String,Simpplr_site__c>();
		Map<String,String> mapOfSiteIdsAndGroupIds = new Map<String,String>();
		Set<String> setOfFavoritedSiteIds = new Set<String>();
		List<CollaborationGroup> listOfCollaborationGroup = new List<CollaborationGroup>();
		List<CollaborationGroup> listOfCollaborationGroupInOrder = new List<CollaborationGroup>();
		
		List<Simpplr_site__c> siteListUserHaveAccess = [Select id FROM simpplr_site__c 
															WHERE chatter_group_id__c IN : listOfGrpIds AND is_Active__c=true 
															AND is_deleted__c= false AND Show_In_Simpplr__c = true];

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.segmentId);
		soqlParamMap.put('soqlParam2', siteListUserHaveAccess);
		soqlParamMap.put('soqlParam3', UserContext.peopleId);
		String queryStr= 'select id,Name,Landing_Page__c,chatter_group_id__c,Site_Type__c, '
							+ ' Title_Content_Version__c,Site_Category__c, Site_Category__r.Name__c, '
							+ ' is_Active__c,Show_In_Simpplr__c, Is_Featured__c, Title_Content_Document__c, '
							+ ' (SELECT Id, Is_Featured__c FROM Site_Segments__r WHERE Segment__c =: soqlParam1), '
							+ ' (SELECT id FROM Subscription_Entity_Site__r WHERE '
							+ ' Subscription__r.Action_Type__c = \'mandatory\' AND Status__c = \'Approved\' AND '
							+ ' Subscription__r.Status__c != \'Deleted\' AND '
							+ ' (Subscription__r.Audience__r.Segment__c = : soqlParam1 OR '
							+ ' Subscription__r.Audience__r.Segment__c = null) Limit 1), '
							+ ' (SELECT Id, Type__c, CreatedById FROM Bookmarked_Simpplr_Site__r WHERE '
							+ ' People__c=:soqlParam3 AND Type__c=\'Site\' And Is_Deleted__c=false) From Simpplr_Site__c where id IN : soqlParam2';
		logger.logDebug('----query---'+queryStr);
													
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Simpplr_site__c> siteList = (List<Simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap); 								
    	 								   	
	 	if(siteList.size()>0) {
    	 	for(Simpplr_site__c siteObj : siteList) {
		    	groupIdToFeaturesMap.put(siteObj.chatter_group_id__c, siteObj.Landing_Page__c);
		    	groupIdsAndSiteMap.put(siteObj.chatter_group_id__c, siteObj);
		    	mapOfSiteIdsAndGroupIds.put(siteObj.id,siteObj.chatter_group_id__c);
		    	if(siteObj.Bookmarked_Simpplr_Site__r.isEmpty() == false) {
	    		setOfFavoritedSiteIds.add(siteObj.Id);
		    	}
	    	}
	    }
			    
    	String BASE_QUERY= 'select Id,name,OwnerId, MemberCount,Description,InformationTitle,CollaborationType,smallPhotoUrl, createdDate FROM CollaborationGroup WHERE isArchived=false '
		    								+'And id in :listOfGrpIds';
		String subConditionString = ' order by Name ASC';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
    	}
		    
		String query = BASE_QUERY + subConditionString;
		listOfCollaborationGroup = Database.query(query);
		map<Id,CollaborationGroup> mapOfGroupIdAndGroup = new map<Id,CollaborationGroup>(listOfCollaborationGroup);
		if(!listOfGrpIds.isEmpty()){
			for(String groupId : listOfGrpIds){
				if(mapOfGroupIdAndGroup.containsKey(groupId)){
					listOfCollaborationGroupInOrder.add(mapOfGroupIdAndGroup.get(groupId));
				}
			}
			listOfCollaborationGroup.clear();
			listOfCollaborationGroup.addAll(listOfCollaborationGroupInOrder);
		}
			
	    for(CollaborationGroup cgObj : listOfCollaborationGroup){
	    	Simpplr_Site__c siteObj = groupIdsAndSiteMap.get(cgObj.Id);
	        TileDataWrapper.TileData mySiteObj = new TileDataWrapper.TileData();
	        if(siteObj != null){
	        	mySiteObj.id = siteObj.Id;
	        mySiteObj.chatterGroupId = cgObj.Id;
	        mySiteObj.siteId = siteObj.Id;
	        mySiteObj.name = siteObj.name;
	        mySiteObj.isActive = siteObj.is_Active__c;
	        mySiteObj.memberCount = cgObj.memberCount;
			mySiteObj.isMandatory = (siteObj.Subscription_Entity_Site__r.isEmpty() == false);
			mySiteObj.isInMandatorySubscription = (siteObj.Subscription_Entity_Site__r.isEmpty() == false);
			if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
				if(siteObj.Site_Segments__r.isEmpty() == false){
					mySiteObj.isFeatured = siteObj.Site_Segments__r[0].Is_Featured__c;
				} else {
					mySiteObj.isFeatured = false;
				}
			} else {
				mySiteObj.isFeatured = siteObj.Is_Featured__c;
			}
			mySiteObj.contentDocumentid = siteObj.Title_Content_Document__c;
	        if(String.isNotBlank(cgObj.description)) {
	            mySiteObj.description = Utility.getAllValidWords(cgObj.description, 45 , false);
	        }
	        mySiteObj.img = String.isBlank(siteObj.Title_Content_Version__c) ? null:Utility.getFileDownloadURLFor720By480(siteObj.Title_Content_Version__c);
	        mySiteObj.isPrivate = cgObj.CollaborationType.equalsIgnoreCase(ServiceConstants.PRIVATE_SITE);
	        mySiteObj.isPublic = cgObj.CollaborationType.equalsIgnoreCase(ServiceConstants.PUBLIC_SITE);
	        mySiteObj.isListed = cgObj.CollaborationType.equalsIgnoreCase(ServiceConstants.UNLISTED_SITE)?false:true;
	        mySiteObj.isFavorited = setOfFavoritedSiteIds.contains(siteObj.Id) ? true : false;
	        mySiteObj.isOwner = UserContext.id.equalsIgnoreCase(cgObj.OwnerId);
	        mySiteObj.isMember = UserContext.sitesIFollowIdSet.contains(siteObj.Id);
	        mySiteObj.isManager = UserContext.sitesIManageIdSet.contains(siteObj.Id);
			mySiteObj.isContentManager = UserContext.sitesIManageContentsIdSet.contains(siteObj.Id);
	        String landingPage = groupIdToFeaturesMap.get(cgObj.Id);
			mySiteObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/' + landingPage;
	        if(String.isNotBlank(siteObj.Site_Category__c)) {
	        	TileDataWrapper.category  catObject= new TileDataWrapper.category();
		    	catObject.id = siteObj.Site_Category__c;
		    	catObject.categoryId = siteObj.Site_Category__c;
			    catObject.name = siteObj.Site_Category__r.Name__c;
			    catObject.url = PageContext.getPageURL(Pages.app)+'?u=/sites/category&category='+ siteObj.Site_Category__c;
			    mySiteObj.category = catObject;
		 	} else {
		 		mySiteObj.category = null;
		 	}
	        customSiteList.add(mySiteObj);
	        }
	    }
	    return customSiteList;
    }
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public TileDataWrapper.WidgetOptions getTwitterWidgetData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
		logger.logDebug('TileService.getTwitterWidgetData()----siteOrHomeId----'+siteOrHomeId+'---tileId----'+tileId);
		TileDataWrapper.WidgetOptions twitterWidgetOptions = new TileDataWrapper.WidgetOptions();
		try {
			TileDataWrapper.Options options = new TileDataWrapper.Options();
			options.widgetId = tiledataSetting.Id;
			options.url = '';
			options.code = tiledataSetting.code;
			twitterWidgetOptions.options = options;
		} catch(Exception e) {            
    			logger.logError('TileService.getTwitterWidgetData()----Exception Occured----', e); 
		}
		logger.logDebug('TileService.getTwitterWidgetData()----twitterWidgetOptions----'+twitterWidgetOptions);
	
		return twitterWidgetOptions;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public  TileDataWrapper.WidgetOptions getFacebookWidgetData(String siteOrHomeId,String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getFacebookWidgetData()----siteOrHomeId----'+siteOrHomeId+'---tileId----'+tileId);
    	
    	TileDataWrapper.WidgetOptions facebookWidgetOptions = new TileDataWrapper.WidgetOptions();
    	try {
    		TileDataWrapper.Options options = new TileDataWrapper.Options();
    		options.height = tiledataSetting.height;
    		options.url = tiledataSetting.url;
    		options.showPosts = tiledataSetting.posts;
    		options.showFaces = tiledataSetting.faces;
    		options.showCover = tiledataSetting.cover;
    		
    		String code = tiledataSetting.code;
    		code = code.replaceAll('#URL#', tiledataSetting.url);
			code = code.replaceAll('#HEIGHT#', String.valueOf(tiledataSetting.height));
			code = code.replaceAll('#WIDTH#', '500');
			code = code.replaceAll('#COVER#', String.valueOf(!tiledataSetting.cover));
			code = code.replaceAll('#FACES#', String.valueOf(tiledataSetting.faces));
			code = code.replaceAll('#POSTS#', String.valueOf(tiledataSetting.posts));
    		options.code = code;
     		facebookWidgetOptions.options = options;
    	} catch(Exception e) {            
        	logger.logError('TileService.getFacebookWidgetData()----Exception Occured----', e);
    	}
    	logger.logDebug('TileService.getFacebookWidgetData()----facebookWidgetOptions----'+facebookWidgetOptions);
    	
    	return facebookWidgetOptions;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public TileDataWrapper.WidgetOptions getHTMLWidgetOneData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getHTMLWidgetOneData()----siteOrHomeId----'+siteOrHomeId+'---tileId----'+tileId);
   		TileDataWrapper.WidgetOptions htmlWidget = new TileDataWrapper.WidgetOptions();
    	try {
    		TileDataWrapper.Options options = new TileDataWrapper.Options();
    		options.code  = String.isNotBlank(tiledataSetting.code) ? tiledataSetting.code : '';
    		options.height = tiledataSetting.height;
    		htmlWidget.options = options;
    	} catch(Exception e) {        
        	logger.logError('TileService.getHTMLWidgetOneData()----Exception Occured----', e); 
    	}
    	logger.logDebug('TileService.getHTMLWidgetOneData()----htmlWidget----'+htmlWidget);
    	
    	return htmlWidget;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public TileDataWrapper.WidgetOptions getTextWidgetData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getTextWidgetData()----siteOrHomeId----'+siteOrHomeId+'---tileId----'+tileId);
   		TileDataWrapper.WidgetOptions textWidget = new TileDataWrapper.WidgetOptions();
    	try {
    		TileDataWrapper.Options options = new TileDataWrapper.Options();
     		options.text = String.isNotBlank(tiledataSetting.code) ? tiledataSetting.code : '';
     		textWidget.options = options;
    	} catch(Exception e) {            
        	logger.logError('TileService.getTextWidgetData()----Exception Occured----', e); 
    	}
    	logger.logDebug('TileService.getTextWidgetData()----textWidget----'+textWidget);
    	
    	return textWidget;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public TileDataWrapper.AppData getAppData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getAppData()----siteOrHomeId----'+siteOrHomeId+'----tileId----'+tileId);
    	
    	TileDataWrapper.AppData appDataObj = new TileDataWrapper.AppData();
    	List<TileDataWrapper.TileData> appList = new List<TileDataWrapper.TileData>();
    	try {
    		List<SetupEntityAccess> listOfSetupEntityAccess = [select SetupEntityId from SetupEntityAccess where (SetupEntityType='ConnectedApplication' or SetupEntityType='TabSet') and ParentId IN (Select PermissionSetId 
                                                                   From PermissionSetAssignment where (AssigneeId =:UserContext.id or PermissionSet.profileid=:UserInfo.getProfileId()))];
            List<String> listOfApplicationId = new List<String>();
            
            for(SetupEntityAccess obj : listOfSetupEntityAccess) {
                listOfApplicationId.add(obj.SetupEntityId);
            }
 		   	List<AppMenuItem> appMenuList = [Select StartUrl, LogoUrl, Name, NamespacePrefix, Label, IconUrl From AppMenuItem WHERE 
 		   		applicationid=:listOfApplicationId AND (type='ConnectedApplication' or type='Tabset') 
 		   		and IsVisible = true and IsDeleted = false and IsAccessible = true WITH SECURITY_ENFORCED
 		   		ORDER BY SortOrder, UserSortOrder, Name];
			Integer i=0;
    		for(AppMenuItem appMenu : appMenuList) {
    			if(appMenu.Name.equalsIgnoreCase('platform') == false 
    				&& appMenu.Name.equalsIgnoreCase('applauncher') == false
    				&& appMenu.NamespacePrefix != 'Simpplr'){
    				TileDataWrapper.TileData app = new TileDataWrapper.TileData();
	    			app.iconImg = appMenu.LogoUrl;
	    			app.url = appMenu.StartUrl;
	    			app.label = appMenu.Label;
	    			appList.add(app);	
					i++;
    			}    	
				if(tiledataSetting.size <= i) {
					break;
				}		
    		}

			
    		appDataObj.listOfitems = appList;
    		appDataObj.options.size = tiledataSetting.size;
    	} catch(Exception e) {            
        	logger.logError('TileService.getAppData()----Exception Occured----', e);
    	}
    	logger.logDebug('TileService.getAppData()----appDataObj----'+appDataObj);
    	
    	return appDataObj;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public  TileDataWrapper.PeopleData getPeopleListData(String siteOrHomeId, String tileId,String variant, TileDataWrapper.TileDataSettings tiledataSetting) {
		logger.logDebug('TileService.getPeopleListData()----siteOrHomeId----'+siteOrHomeId+'----tileId----'+tileId+'----variant----'+variant);
    	TileDataWrapper.PeopleData PeopleDataObj = new TileDataWrapper.PeopleData();
    	try{
			Integer limitOfRecords = tiledataSetting.size != null ? tiledataSetting.size : 0;
			List<String> listOfUserIds = new  List<String>();
			
			if(variant.equalsIgnorecase('site_members') || variant.equalsIgnorecase('site_managers')) {
				List<Simpplr_Site__c> simpplrSiteList = [SELECT Chatter_Group_Id__c, Site_Type__c From Simpplr_Site__c WHERE Id=:siteOrHomeId WITH SECURITY_ENFORCED];
				if(simpplrSiteList.size()>0) {
					Set<String> memberUserIds = new Set<String>();
					Set<String> followerUserIds = new Set<String>();
					List<String> alluserIds = new List<String>();
					Set<String> memberUserIdSet = new Set<String>();
					Set<String> followerUserIdSet = new Set<String>();
					String ownerId;
					if(variant.equalsIgnorecase('site_members')){
						if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(simpplrSiteList[0].Site_Type__c)){
							for(CollaborationGroupMember grpMember : [SELECT id, CollaborationGroup.OwnerId, memberId,CollaborationRole FROM CollaborationGroupMember where CollaborationGroupId=:simpplrSiteList[0].Chatter_Group_Id__c WITH SECURITY_ENFORCED order by CreatedDate desc]) {
								alluserIds.add(grpMember.MemberId);
								if('Admin'.equalsIgnoreCase(grpMember.CollaborationRole)){
									ownerId = grpMember.CollaborationGroup.OwnerId;
									followerUserIdSet.add(ownerId);
									memberUserIds.add(grpMember.MemberId);
								} 
							}
							for(Site_Role__c roleRecord : [SELECT People__r.User__c, Is_Member__c, Is_Content_Manager__c,Is_Manager__c  FROM Site_Role__c WHERE Site__c = :siteOrHomeId  AND Is_Deleted__c = false WITH SECURITY_ENFORCED]) {
								if((roleRecord.Is_Member__c == true || roleRecord.Is_Content_Manager__c == true || roleRecord.Is_Manager__c == true)){
									if(memberUserIdSet.add(roleRecord.People__r.User__c)){
										memberUserIds.add(roleRecord.People__r.User__c);
										memberUserIdSet.add(roleRecord.People__r.User__c);
									}
								} else {
									if(followerUserIdSet.add(roleRecord.People__r.User__c)){
										followerUserIds.add(roleRecord.People__r.User__c);
										followerUserIdSet.add(roleRecord.People__r.User__c);
									}
								}
								
							}
							if(tiledataSetting.siteMembers == true && tiledataSetting.siteFollowers == true){
								listOfUserIds.addAll(alluserIds);
							} else if(tiledataSetting.siteMembers == true){
								listOfUserIds.addAll(memberUserIds);
							} else if(tiledataSetting.siteFollowers == true){
								listOfUserIds.addAll(followerUserIds);
							}
						}  else {
							for(CollaborationGroupMember grpMember : [SELECT id, memberId,CollaborationRole FROM CollaborationGroupMember where CollaborationGroupId=:simpplrSiteList[0].Chatter_Group_Id__c WITH SECURITY_ENFORCED order by CreatedDate desc]) {
								listOfUserIds.add(grpMember.memberId);
							}
						}
					} else{
						for(CollaborationGroupMember grpMember : [SELECT id, memberId,CollaborationRole FROM CollaborationGroupMember where CollaborationGroupId=:simpplrSiteList[0].Chatter_Group_Id__c AND CollaborationRole = 'Admin' WITH SECURITY_ENFORCED]) {
	    					listOfUserIds.add(grpMember.memberId);
	    				}
					}
	    			 
				}
			}else if(variant.equalsIgnorecase('custom')){
				
				if(String.isNotBlank(tiledataSetting.value)) {
		            listOfUserIds = tiledataSetting.value.split(',');  
		        }
		        limitOfRecords = listOfUserIds.size();
		        
			}
			
			List<TileDataWrapper.TileData> peopleList = new List<TileDataWrapper.TileData>();
			PeopleDao peopleDaoObj = new PeopleDao();
			List<People__c> listOfPeople = peopleDaoObj.getPeopleListDataForTiles(listOfUserIds,variant);
			
			if(variant.equalsIgnorecase('custom')){
				map<Id,people__c> peopleIdWithPeopleMap = new map<Id,people__c>();
				
				for(People__c peopleObj : listOfPeople){
					peopleIdWithPeopleMap.put(peopleObj.user__c,peopleObj);
				}
			    	
				List<People__c> listOfPeopleInOrder = new List<People__c>();
				if(!listOfUserIds.isEmpty()){
					for(String userId : listOfUserIds){
						if(peopleIdWithPeopleMap.containsKey(userId)){
							listOfPeopleInOrder.add(peopleIdWithPeopleMap.get(userId));
						}
					}
				}
				listOfPeople.clear();
				listOfPeople.addAll(listOfPeopleInOrder);
			}
			
			for(People__c peopleObj : listOfPeople) {
				TileDataWrapper.TileData people = new TileDataWrapper.TileData();
				people.id = peopleObj.id;
				people.sfUserId = peopleObj.user__c;
				people.peopleId = peopleObj.id;
				people.name = peopleObj.Full_Name__c;
				people.title = peopleObj.title__c;
				people.department = peopleObj.department__c;
				people.img = peopleObj.user__r.FullPhotoUrl.endsWith('005/F') ? null : peopleObj.user__r.FullPhotoUrl;	    				
				
				people.location = Utility.buildLocation(peopleObj.city__c, peopleObj.State__c, peopleObj.Country__c);
				people.isFavorited = peopleObj.Bookmark_Receiver_People__r.size() > 0;
				people.isActive = peopleObj.User__r.isactive;
				if (UserContext.peopleId == peopleObj.Id) {
					people.canFollow = false;
				} else {
					people.canFollow = peopleObj.User__r.isactive;
				}
        		people.isFollowing = UserContext.usersIFollowIdSet.contains(peopleObj.user__c) ? true:false;
        		people.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.id;
				if(peopleList.size() < limitOfRecords) {
        			peopleList.add(people);
        		}
			}
    			
    		PeopleDataObj.total = listOfPeople.size();
    		if(PeopleDataObj.total > limitOfRecords) {//TBD
    			PeopleDataObj.options.totalNotShown = PeopleDataObj.total - limitOfRecords;
    		} else {
    			PeopleDataObj.options.totalNotShown = 0;
    		} 
			PeopleDataObj.options.size = limitOfRecords;
			TileDataWrapper.MembershipType memType = new TileDataWrapper.MembershipType();
			memType.siteMembers = tiledataSetting.siteMembers;
			memType.siteFollowers = tiledataSetting.siteFollowers;
			PeopleDataObj.options.membershipType = memType;
    		PeopleDataObj.siteId = siteOrHomeId;	
    		PeopleDataObj.listOfItems = peopleList;
	    		
    	} catch(Exception e) {            
        	logger.logError('TileService.getPeopleListData()----Exception Occured----', e);
    	}
    	logger.logDebug('TileService.getPeopleListData()----PeopleDataObj----'+PeopleDataObj);
    	
    	return PeopleDataObj;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public  TileDataWrapper.WidgetOptions getRSSData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getRSSData()----siteOrHomeId----'+siteOrHomeId+'----tileId----'+tileId);
    	
    	TileDataWrapper.WidgetOptions RSSObj = new TileDataWrapper.WidgetOptions();
    	TileDataWrapper.Options options = new TileDataWrapper.Options();
    	try {
	    	String userTimeZone = UserInfo.getTimeZone().getID();
	    	options.url = tiledataSetting.url;
 	    	options.size = tiledataSetting.size;
 	    	options.showImages = false;
 	    	RSSObj.options = options;
    	} catch(Exception e) {            
        	logger.logError('TileService.getRSSData()----Exception Occured----', e);
    	}
    	logger.logDebug('TileService.getRSSData()----RSSObj----'+RSSObj);
    	
    	return RSSObj;
    }
    
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public  TileDataWrapper.WidgetOptions getImageData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getImageData()----siteOrHomeId----'+siteOrHomeId+'----tileId----'+tileId);
    	
    	TileDataWrapper.WidgetOptions imageObj = new TileDataWrapper.WidgetOptions();
    	TileDataWrapper.Options options = new TileDataWrapper.Options();
    	try {
	    	options.url = tiledataSetting.url;
 	    	options.title = tiledataSetting.title;
 	    	options.description = tiledataSetting.description;
 	    	options.showInfo = tiledataSetting.showInfo;
 	    	options.imageFile = getImageFile(tiledataSetting.imageFile);
 	    	imageObj.options = options;
    	} catch(Exception e) {            
        	logger.logError('TileService.getImageData()----Exception Occured----', e);
    	}
    	logger.logDebug('TileService.getImageData()---imageobj-----'+imageObj);
    	
    	return imageobj;
    }
    
    public FileListingWrapper getImageFile(FileListingWrapper imgFileObj){
    	ContentDocument conDocObj;
    	FileListingWrapper fileObj;
    	if(imgFileObj != null){
	    	FileDao fileDaoObj = new FileDao();
	    	conDocObj = fileDaoObj.getContentDocumentById(imgFileObj.contentDocumentId);
    		
    	}
    	if(conDocObj != null){
	    	fileObj = ObjectToWrapperAdapter.myFileToWrapper(conDocObj); 
    	} else {
    		fileObj = new FileListingWrapper();
    	}
    	return fileObj;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public  TileDataWrapper.WidgetOptions getVideoData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getVideoData()----siteOrHomeId----'+siteOrHomeId+'----tileId----'+tileId);
    	
    	TileDataWrapper.WidgetOptions videoObj = new TileDataWrapper.WidgetOptions();
    	TileDataWrapper.Options options = new TileDataWrapper.Options();
    	try {
	    	options.url = tiledataSetting.url;
			options.oembed = tiledataSetting.oembed;
			if(SimpplrContext.isNativeVideo) {
				options.videoFile = tiledataSetting.videoFile;
				if(tiledataSetting.videoFile !=null) {
					VideoDetails videoDetailsObj = getVideoDetails(tiledataSetting.videoFile.externalFileId);
					options.videoFile.videoStatus = videoDetailsObj.videoStatus;
					options.videoFile.isAccessible = videoDetailsObj.isAccessible;
					options.videoFile.thumbnailImg = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + tiledataSetting.videoFile.externalFileId +'/width/550/height/480';
				}
			}
 	    	options.title = tiledataSetting.title;
 	    	options.description = tiledataSetting.description;
 	    	options.showInfo = tiledataSetting.showInfo;
 	    	videoObj.options = options;
    	} catch(Exception e) {            
        	logger.logError('TileService.getVideoData()----Exception Occured----', e);
    	}
    	logger.logDebug('TileService.getVideoData()----videoObj------'+videoObj);
    	
    	return videoObj;
	}

    private class VideoDetails{
		private Integer videoStatus;
		private Boolean isAccessible;
    	public VideoDetails(Integer videoStatus, Boolean isAccessible) {
			this.videoStatus = videoStatus;
			this.isAccessible = isAccessible;
		}
	}	
	
	private VideoDetails getVideoDetails(string videoId) {
		Integer videoStatus = 1;
		Boolean isAccessible = false;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', videoId);
		String filesQuery = 'select id, Video_Status__c, Is_Deleted__c from File__c where External_Id__c=:soqlParam1 limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		if(!fileList.isEmpty()) {
			videoStatus = fileList[0].Video_Status__c != null ? Integer.valueOf(fileList[0].Video_Status__c) : videoStatus;
			isAccessible = SimpplrContext.isNativeVideo ? !fileList[0].Is_Deleted__c : isAccessible;
		}
		return new VideoDetails(videoStatus, isAccessible);
	}
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public  TileDataWrapper.FileData getFileList(String siteOrHomeId, String tileId,String variant, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getFileList()----siteOrHomeId----'+siteOrHomeId+'----tileId----'+tileId);
		
		TileDataWrapper.FileData fileDataObj = new TileDataWrapper.FileData();
    	List<TileDataWrapper.TileData> fileList = new List<TileDataWrapper.TileData>();
    	try {
			if(EFSConstants.storageTypes.contains(variant)) {
    			for(TileDataWrapper.TileData tileDataObj : tiledataSetting.listOfItems){
					if(String.isNotBlank(tileDataObj.type)){
						tileDataObj.fileExtension = tileDataObj.type;
					}
					else{
						tileDataObj.fileExtension = tileDataObj.title.indexOf('.') == -1 ? 'UNKNOWN' : tileDataObj.title.substringAfterLast('.').toUpperCase();
					}
    			}
				fileDataObj.listOfItems = tiledataSetting.listOfItems;
				fileDataObj.options.type = tiledataSetting.type;
				
    		} else {
				List<String> listOfFileIds = new  List<String>();
				if(String.isNotBlank(tiledataSetting.value)) {
		            listOfFileIds = tiledataSetting.value.split(',');  
		        }
		        String queryStr = 'SELECT Id, Title, LatestPublishedVersion.pathOnClient, LatestPublishedVersion.VersionNumber, Owner.name,Owner.id, LastModifiedDate, LatestPublishedVersionId,'
							 	  + ' LatestPublishedVersion.description, LatestPublishedVersion.ContentSize,LatestPublishedVersion.FileExtension, LatestPublishedVersion.fileType, LatestPublishedVersion.Origin'
							 	  + ' From ContentDocument WHERE Id IN:listOfFileIds';
		    	if(SimpplrContext.isCommunitiesEnabled){
		    		queryStr += ' AND LatestPublishedVersion.networkid = null';
		    	}
		    	
		    	List<ContentDocument> listOfDocuments = Database.query(queryStr);
		    	Map<Id,ContentDocument> mapOfContentDocIdWithContentDoc = new Map<Id,ContentDocument>(listOfDocuments);
			    List<ContentDocument> listOfDocumentsInOrder = new List<ContentDocument>();
			    if(!listOfFileIds.isEmpty()){
				    for(String contentDocId : listOfFileIds){
				    	if(mapOfContentDocIdWithContentDoc.containsKey(contentDocId)){
				    		listOfDocumentsInOrder.add(mapOfContentDocIdWithContentDoc.get(contentDocId));
				    	}
				    }
			    }
			    
				for(ContentDocument contentDoc : listOfDocumentsInOrder) {
					TileDataWrapper.TileData file = new TileDataWrapper.TileData();
					file.id = contentDoc.Id;
					file.spInstanceId = tiledataSetting.spInstanceId;
					file.title = contentDoc.Title;
					file.type = contentDoc.LatestPublishedVersion.fileType;
					file.fileExtension = contentDoc.LatestPublishedVersion.fileExtension;
					if(contentDoc.LatestPublishedVersion.fileExtension.equalsIgnoreCase('jpeg') 
					|| contentDoc.LatestPublishedVersion.fileExtension.equalsIgnoreCase('jpg') 
					|| contentDoc.LatestPublishedVersion.fileExtension.equalsIgnoreCase('png') 
					|| contentDoc.LatestPublishedVersion.fileExtension.equalsIgnoreCase('gif')) {
						file.thumbnail = Utility.getFileDownloadURLFor240BY180(contentDoc.LatestPublishedVersionId);
					}
					file.size = contentDoc.LatestPublishedVersion.ContentSize;
					if(contentDoc.LastModifiedDate != NULL) {
						file.modifiedAt = contentDoc.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
					}
					file.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => contentDoc.id});
			    	file.downloadUrl = Utility.getFileDownloadURL(contentDoc.LatestPublishedVersionId);
	    	
	        		//file.isAccessible = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.id;
	        		fileList.add(file);
				}
    			
    			fileDataObj.listOfItems = fileList;
    		}
    	} catch(Exception e) {            
        	logger.logError('TileService.getFileList()----Exception Occured----', e); 
    	}
    	logger.logDebug('TileService.getFileList()----fileDataObj----'+fileDataObj);
    	return fileDataObj;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/ 
    public TileDataWrapper.WidgetOptions getCountDownData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	TileDataWrapper.WidgetOptions countDownWidget = new TileDataWrapper.WidgetOptions();
		TileDataWrapper.Options options = new TileDataWrapper.Options();
		if(String.isNotBlank(tiledataSetting.endTitle)) {
			options.endMessage = tiledataSetting.endTitle;    		
		}
		options.stopAt = tiledataSetting.stopDateTime;
		//Added following back for backward compatibility
		if(options.stopAt == null) {
			DateTime countdownStopDateTime = getGmtDateTimeFromStringDate(tiledataSetting.stopDate, tiledataSetting.stopTime);
			options.stopAt = countdownStopDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
		countDownWidget.options = options;
    	return countDownWidget;
    }
		@testVisible
    	private DateTime getGmtDateTimeFromStringDate(String stopDate, String stopTime){
		Map <String, String> monthNames = new Map <String, String> {
		            'Jan'=>'1', 
		            'Feb'=>'2', 
		            'Mar'=>'3', 
		            'Apr'=>'4', 
		            'May'=>'5', 
		            'Jun'=>'6', 
		            'Jul'=>'7', 
		            'Aug'=>'8', 
		            'Sep'=>'9', 
		            'Oct'=>'10', 
		            'Nov'=>'11', 
		            'Dec'=>'12'
		        };		
		List<String> dateTokens = stopDate.split(' ');
		Integer year;
		Integer day;
		Integer month;
		Integer hour;
		Integer minute;
		Datetime dt = DateTime.now();
		if(dateTokens!=null){
		    if(dateTokens.size()> 0){
				year = Integer.valueOf(dateTokens[2]);
		        day = Integer.valueOf(dateTokens[1]);
		        month = Integer.valueOf(monthNames.get(dateTokens[0]));
		        List<String> timeTokens = stopTime.split(':');
	        	hour = Integer.valueOf(timeTokens[0]);
			    minute = Integer.valueOf(timeTokens[1]);
				dt = Datetime.newInstanceGMT(year, month, day, hour, minute,0);
			}
		}
    	return dt;
    }
    
    public void setSegmentDashboardLayout(String segmentId, String layout) {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'select Id, Layout__c from Segment__c where Id = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Segment__c>  listOfSegmentObj = (List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
    	String oldLayout = listOfSegmentObj[0].Layout__c ;
    	
    	if (!listOfSegmentObj.isEmpty()) {
	    	listOfSegmentObj[0].Layout__c = layout;
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Segment__c>(listOfSegmentObj),new List<Schema.SObjectField>{Segment__c.Layout__c});
    	}

    	if (SimpplrContext.isAuditTrailEnabled) {
    		Audit_Trail__c auditTrailObj = new Audit_Trail__c();
	    	auditTrailObj.Created_By__c = UserContext.peopleId;
	    	auditTrailObj.New_Value__c = layout;
	    	auditTrailObj.Column_Name__c = 'Layout__c';
	    	auditTrailObj.Old_Value__c = oldLayout;
	    	auditTrailObj.Object_Name__c = 'Segment__c';
	    	auditTrailObj.Segment__c = segmentId;
	    	
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(auditTrailObj, new List<Schema.SObjectField>{
					Audit_Trail__c.Created_By__c,
					Audit_Trail__c.New_Value__c,
					Audit_Trail__c.Column_Name__c,
					Audit_Trail__c.Old_Value__c,
					Audit_Trail__c.Object_Name__c,
					Audit_Trail__c.Segment__c
			});
    	}

    }
    
    public void setHomeDashboardLayout(String layout) {
    	String appConfigQuery = 'select Id, Layout__c from App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfConfigObj = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
    	String oldLayout = listOfConfigObj[0].Layout__c ;
    	
    	if (!listOfConfigObj.isEmpty()) {
	    	listOfConfigObj[0].Layout__c = layout;
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(listOfConfigObj),new List<Schema.SObjectField>{App_Config__c.Layout__c});
    	}

    	if (SimpplrContext.isAuditTrailEnabled) {
    		Audit_Trail__c auditTrailObj = new Audit_Trail__c();
    	
	    	auditTrailObj.Created_By__c = UserContext.peopleId;
	    	auditTrailObj.New_Value__c = layout;
	    	auditTrailObj.Column_Name__c = 'Layout__c';
	    	auditTrailObj.Old_Value__c = oldLayout;
	    	auditTrailObj.Object_Name__c = 'App_Config__c';
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(auditTrailObj, new List<Schema.SObjectField>{
					Audit_Trail__c.Created_By__c,
					Audit_Trail__c.New_Value__c,
					Audit_Trail__c.Column_Name__c,
					Audit_Trail__c.Old_Value__c,
					Audit_Trail__c.Object_Name__c
			});
    	}

    }
    
    public void setHomeDefaultLayout(String segmentId, String layout){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id,Sync_Status__c, Data__c, Layout__c,Type__c,Last_Modified_By_People__c From App_Default__c where Segment__c=:soqlParam1 And Type__c=\'home-default\' LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfappDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    												
    	String oldLayout = '';
    	
    	if(!listOfappDefaultObj.isEmpty()) {
    		oldLayout = listOfappDefaultObj[0].Layout__c;
	    	listOfappDefaultObj[0].Layout__c = layout;
			listOfappDefaultObj[0].Last_Modified_By_People__c = UserContext.getCurrentUserInfo.Id;
			listOfappDefaultObj[0].Sync_Status__c = null ;
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Default__c>(listOfappDefaultObj),new List<Schema.SObjectField>{App_Default__c.Layout__c,App_Default__c.Last_Modified_By_People__c,App_Default__c.Sync_Status__c});
    	
    	} else {
    		App_Default__c homeDefaultObj = new App_Default__c();
    		homeDefaultObj.Layout__c = layout;
    		homeDefaultObj.Last_Modified_By_People__c = UserContext.getCurrentUserInfo.Id;
    		homeDefaultObj.Type__c='home-default';
    		homeDefaultObj.Segment__c = String.isBlank(segmentId) ? null : segmentId;
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    		SIMPESAPI.accessController().insertAsUser(homeDefaultObj, new List<Schema.SObjectField> { App_Default__c.Layout__c,
    																								App_Default__c.Type__c,
    																								App_Default__c.Segment__c,
    																								App_Default__c.Last_Modified_By_People__c});	
    			
    	}
    	
    	if (SimpplrContext.isAuditTrailEnabled) {
    		Audit_Trail__c auditTrailObj = new Audit_Trail__c();
	    	auditTrailObj.Created_By__c = UserContext.peopleId;
	    	auditTrailObj.New_Value__c = layout;
	    	auditTrailObj.Column_Name__c = 'Layout__c';
	    	auditTrailObj.Old_Value__c = oldLayout;
	    	auditTrailObj.Object_Name__c = 'App_Default__c';
	    	
			if (String.isNotBlank(segmentId)) {
		   		auditTrailObj.Segment__c = segmentId;
	    	}

	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(auditTrailObj, new List<Schema.SObjectField>{
					Audit_Trail__c.Created_By__c,
					Audit_Trail__c.New_Value__c,
					Audit_Trail__c.Column_Name__c,
					Audit_Trail__c.Old_Value__c,
					Audit_Trail__c.Object_Name__c,
					Audit_Trail__c.Segment__c
					});
    	}
    }
    
    public void setSiteDashboardLayout(String siteId, String newLayout){
    	List<Simpplr_Site__c>  listOfSiteObj = [select id, Layout__c from Simpplr_Site__c where Id=:siteId WITH SECURITY_ENFORCED];
    	String oldLayout = listOfSiteObj[0].Layout__c ;
    	
    	if (!listOfSiteObj.isEmpty()) {
	    	listOfSiteObj[0].Layout__c = newLayout;
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listOfSiteObj),new List<Schema.SObjectField>{Simpplr_Site__c.Layout__c});

	    	if (SimpplrContext.isAuditTrailEnabled) {
	    		Audit_Trail__c auditTrailObj = new Audit_Trail__c();
		    	auditTrailObj.New_Value__c = newLayout;
		    	auditTrailObj.Column_Name__c = 'Layout__c';
		    	auditTrailObj.Old_Value__c = oldLayout;
		    	auditTrailObj.Object_Name__c = 'Simpplr_Site__c';
		    	auditTrailObj.Created_By__c = UserContext.peopleId;
		    	auditTrailObj.Site__c = siteId;
		    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(auditTrailObj, new List<Schema.SObjectField>{
						Audit_Trail__c.New_Value__c,
						Audit_Trail__c.Column_Name__c,
						Audit_Trail__c.Old_Value__c,
						Audit_Trail__c.Object_Name__c,
						Audit_Trail__c.Created_By__c,
						Audit_Trail__c.Site__c
						});

	    	}

    	}
    }
    
    
    public void setUserDashboardLayout(String layout){
    	List<People_Preference__c>  listOfPeoplePreferenceObj = [select id, Layout__c from People_Preference__c where People__c=:UserContext.peopleId WITH SECURITY_ENFORCED];
    	
		if (!listOfPeoplePreferenceObj.isEmpty()) {
    		listOfPeoplePreferenceObj[0].Layout__c = layout;
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(listOfPeoplePreferenceObj),new List<Schema.SObjectField>{People_Preference__c.Layout__c});
 
    	}

	}
	
	public List<Tiles_Config__c> addTileOnSegmentDashboard(String segmentId,TileDataWrapper.AddTile tileWrapperObj){
		List<Tiles_Config__c> listOfTilesToAdd= new List<Tiles_Config__c>();
		Tiles_Config__c tileConfigObject = new Tiles_Config__c();
		tileConfigObject.Name__c=tileWrapperObj.title;
		tileConfigObject.Data__c=populateData(tileWrapperObj.title, tileWrapperObj.type, tileWrapperObj.variant, tileWrapperObj.options ,tileWrapperObj.items,segmentId,false);
		tileConfigObject.Type__c=tileWrapperObj.type;
	    tileConfigObject.Variant__c=tileWrapperObj.variant;
	    tileConfigObject.Variant_Type__c =  tileWrapperObj.variant+ '_' +tileWrapperObj.type;
		tileConfigObject.Location__c = 'Segment Dashboard';
		tileConfigObject.Layout_Column__c = 1;
		tileConfigObject.Order__c = 0;
		tileConfigObject.Segment__c = segmentId;
		
		creatContentDocumentLinkRecords(tileWrapperObj, false);
		
		List<Tiles_Config__c> listToInsert= new List<Tiles_Config__c>(); 
		listToInsert.add(tileConfigObject);
		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																						Tiles_Config__c.Type__c,
																						Tiles_Config__c.Variant__c,
																						Tiles_Config__c.Data__c,
																						Tiles_Config__c.Location__c,
																						Tiles_Config__c.Segment__c,
																						Tiles_Config__c.Order__c,
																						Tiles_Config__c.Layout_Column__c,
																						Tiles_Config__c.Variant_Type__c};
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listToInsert, listOfColumnsToBeSet);
		listOfTilesToAdd = (List<Tiles_Config__c>)result.getInsertedObjects();
		updateOrderOfExistingTiles(null, null, segmentId);
		return listOfTilesToAdd;
	}
	
	@testVisible
	private void creatContentDocumentLinkRecords(TileDataWrapper.AddTile tileWrapperObj, Boolean isRelatedToSite){
    	List<ContentDocumentLink> cdLinkList =  new List<ContentDocumentLink>();
		if(tileWrapperObj.options !=null && tileWrapperObj.options.imageFile != null){
    		ContentDocumentLink cdLink = new ContentDocumentLink();
	    	cdLink.ShareType = 'V';
	    	if(isRelatedToSite){
	    		cdLink.LinkedEntityId = SiteContext.chatterGroupId;
	    	} else {
				cdLink.LinkedEntityId = UserInfo.getOrganizationId();
	    	}
			cdLink.ContentDocumentId = tileWrapperObj.options.imageFile.contentDocumentId; 
		    cdLinkList.add(cdLink);
    	}
    	
    	if(tileWrapperObj.options !=null && tileWrapperObj.options.links != null){
    		for(TileDataWrapper.TileData linkObj: tileWrapperObj.options.links){
    			if(linkObj.imageFile != null && String.isNotBlank(linkObj.imageFile.contentDocumentId)){
					ContentDocumentLink cdLink = new ContentDocumentLink();
			    	cdLink.ShareType = 'V';
					if(isRelatedToSite){
			    		cdLink.LinkedEntityId = SiteContext.chatterGroupId;
			    	} else {
						cdLink.LinkedEntityId = UserInfo.getOrganizationId();
			    	}
					cdLink.ContentDocumentId = linkObj.imageFile.contentDocumentId;
					cdLinkList.add(cdLink);
    			}
    		}
    	}
    	if(cdLinkList.isEmpty() == false){
			insert cdLinkList;
    	}
	}
	
	@testVisible
	private void creatContentDocumentLinkRecordsForEdit(TileDataWrapper.AddTile tileWrapperObj, Boolean isRelatedToSite){
    	List<ContentDocumentLink> cdLinkList =  new List<ContentDocumentLink>();
		Set<String> siteContentDocIdSet = new Set<String>();
		Set<String> allCompanyContentDocIdSet = new Set<String>();
		if(tileWrapperObj.options !=null && tileWrapperObj.options.imageFile != null){
    		ContentDocumentLink cdLink = new ContentDocumentLink();
	    	cdLink.ShareType = 'V';
	    	if(isRelatedToSite){
	    		cdLink.LinkedEntityId = SiteContext.chatterGroupId;
	    		siteContentDocIdSet.add(tileWrapperObj.options.imageFile.contentDocumentId);
	    	} else {
				cdLink.LinkedEntityId = UserInfo.getOrganizationId();
				allCompanyContentDocIdSet.add(tileWrapperObj.options.imageFile.contentDocumentId);
	    	}
			cdLink.ContentDocumentId = tileWrapperObj.options.imageFile.contentDocumentId; 
		    cdLinkList.add(cdLink);
    	}
    	
    	if(tileWrapperObj.options !=null && tileWrapperObj.options.links != null){
    		for(TileDataWrapper.TileData linkObj: tileWrapperObj.options.links){
    			if(linkObj.imageFile != null && String.isNotBlank(linkObj.imageFile.contentDocumentId)){
					ContentDocumentLink cdLink = new ContentDocumentLink();
			    	cdLink.ShareType = 'V';
			    	if(isRelatedToSite){
			    		cdLink.LinkedEntityId = SiteContext.chatterGroupId;
			    		siteContentDocIdSet.add(linkObj.imageFile.contentDocumentId);
			    	} else {
						cdLink.LinkedEntityId = UserInfo.getOrganizationId();
						allCompanyContentDocIdSet.add(linkObj.imageFile.contentDocumentId);
			    	}
					cdLink.ContentDocumentId = linkObj.imageFile.contentDocumentId;
					cdLinkList.add(cdLink);
    			}
    		}
    	}
    	Set<String> contentDocIdToBeInserted = new Set<String>();
    	if(cdLinkList.isEmpty() == false){
    		if(siteContentDocIdSet.isEmpty() == false){
	    		List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId=:SiteContext.chatterGroupId AND ContentDocumentId IN:siteContentDocIdSet WITH SECURITY_ENFORCED];
    			if(contentDocList.isEmpty() == false){
	    			for(ContentDocumentLink cdl : contentDocList){
		    			if(siteContentDocIdSet.contains(cdl.ContentDocumentId)){
		    				siteContentDocIdSet.remove(cdl.ContentDocumentId);
		    			}
		    		}
    			}	
    			contentDocIdToBeInserted.addAll(siteContentDocIdSet);
    		}
    		if(allCompanyContentDocIdSet.isEmpty() == false){
	    		List<ContentDocumentLink> contentDocList = [SELECT ContentDocumentId from ContentDocumentLink WHERE LinkedEntityId=:UserInfo.getOrganizationId() AND ContentDocumentId IN:allCompanyContentDocIdSet WITH SECURITY_ENFORCED];
    			if(contentDocList.isEmpty() == false){
	    			for(ContentDocumentLink cdl : contentDocList){
		    			if(allCompanyContentDocIdSet.contains(cdl.ContentDocumentId)){
		    				allCompanyContentDocIdSet.remove(cdl.ContentDocumentId);
		    			}
		    		}
    			}	
    			contentDocIdToBeInserted.addAll(allCompanyContentDocIdSet);
    		}
    		List<ContentDocumentLink> finalListToBeInserted = new List<ContentDocumentLink>();
    		for(ContentDocumentLink cdl : cdLinkList){
    			if(contentDocIdToBeInserted.contains(cdl.ContentDocumentId)){
    				finalListToBeInserted.add(cdl);
    			}
    		}
    		if(finalListToBeInserted.isEmpty() == false){
				insert finalListToBeInserted;
    		}
    	}
	}
	
	public List<Tiles_Config__c> addTileOnSiteDashboard(String siteId,TileDataWrapper.AddTile tileWrapperObj){
		List<Tiles_Config__c> listOfTilesToAdd= new List<Tiles_Config__c>();
		Tiles_Config__c tileConfigObject = new Tiles_Config__c();
		tileConfigObject.Name__c=tileWrapperObj.title;
		tileConfigObject.Data__c=populateData(tileWrapperObj.title, tileWrapperObj.type, tileWrapperObj.variant, tileWrapperObj.options ,tileWrapperObj.items,siteId,false);
		tileConfigObject.Type__c=tileWrapperObj.type;
	    tileConfigObject.Variant__c=tileWrapperObj.variant;
	    tileConfigObject.Variant_Type__c=tileWrapperObj.variant+ '_' +tileWrapperObj.type;
		tileConfigObject.Location__c = 'Site Dashboard';
		tileConfigObject.Layout_Column__c = 1;
		tileConfigObject.Order__c = 0;
		tileConfigObject.site__c=siteId;
		
    	creatContentDocumentLinkRecords(tileWrapperObj, true);
    	
		List<Tiles_Config__c> listToInsert= new List<Tiles_Config__c>(); 
		listToInsert.add(tileConfigObject);
		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																						Tiles_Config__c.Type__c,
																						Tiles_Config__c.Variant__c,
																						Tiles_Config__c.Data__c,
																						Tiles_Config__c.Location__c,
																						Tiles_Config__c.site__c,
																						Tiles_Config__c.Order__c,
																						Tiles_Config__c.Layout_Column__c,
																						Tiles_Config__c.Variant_Type__c};
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listToInsert, listOfColumnsToBeSet);
		listOfTilesToAdd = (List<Tiles_Config__c>)result.getInsertedObjects();
		updateOrderOfExistingTiles(null, siteId, null);
		return listOfTilesToAdd;
	}
	
	private String populateData(String title, String type , String variant , TileDataWrapper.Options options , List<String> items,String siteId,Boolean isLibTile ){
		TileDataWrapper.TileDataSettings widgetData = new TileDataWrapper.TileDataSettings();
		
		if('latest'.equalsIgnoreCase(variant)   || 'popular'.equalsIgnoreCase(variant) || 
		   		'upcoming'.equalsIgnoreCase(variant) || 'from_category'.equalsIgnoreCase(variant)) { 
		   	
			widgetData.size = CONTENT_TILE_ITEM_LIMIT;
			widgetData.siteFilter = options.siteFilter;
			widgetData.layout = options.layout;
			widgetData.pageCategoryID = options.pageCategoryID;
			if(String.isNotBlank(options.siteId)){
				widgetData.siteId = options.siteId;
			}
		
		} else if('latest_popular'.equalsIgnoreCase(variant)) {
			widgetData.type = options.type;
			widgetData.layout = options.layout;
			widgetData.calendar = options.calendar;
			widgetData.outlookCalendar = options.outlookCalendar;
			widgetData.siteFilter = options.siteFilter;
			if(String.isNotBlank(options.siteId)){
				widgetData.siteId = options.siteId;
			}
			
		} else if('favorites'.equalsIgnoreCase(variant) || 'managing'.equalsIgnoreCase(variant) || 
		   'site_members'.equalsIgnoreCase(variant) ||  'site_managers'.equalsIgnoreCase(variant)){
			widgetData.size = SITE_MEMBER_MANAGER_TILE_ITEM_LIMIT + 1;
			widgetData.layout = options.layout;
			if('site_members'.equalsIgnoreCase(variant)){
				widgetData.siteMembers = (options.membershipType != null && options.membershipType.siteMembers !=null) ? options.membershipType.siteMembers:false;
				widgetData.siteFollowers = (options.membershipType != null && options.membershipType.siteFollowers !=null) ? options.membershipType.siteFollowers:false;	
			}

		} else if('people'.equalsIgnoreCase(type) && !'custom'.equalsIgnoreCase(variant)) {
			if('new_hires'.equalsIgnoreCase(variant)) {
				widgetData.layout = options.layout;
				widgetData.hireDaysThreshold = options.hireDaysThreshold;

			} else if('celebrations'.equalsIgnoreCase(variant)) {
				widgetData.layout = options.layout;
				widgetData.celebrationsPeople = options.celebrationsPeople;
				widgetData.celebrationsDays = options.celebrationsDays;
				
			}
		
		} else if ('content'.equalsIgnoreCase(type) && 'content_onboarding'.equalsIgnoreCase(variant)) {
			widgetData.layout = options.layout;
		
	 	} else if('custom'.equalsIgnoreCase(variant)){
			 if(items != null && items.size() > 0) {
	        		widgetData.value = Utility.convertToCommaSeparatedString(items);
			 }
			 widgetData.layout = options.layout;
		}
		
		if('links'.equalsIgnoreCase(type)){
			Integer order = 0;
			if(options.links != null && options.links.size()>0){
				// setting false if null in onOff flag
				for(TileDataWrapper.TileData link : options.links){
					 if(link.imageFile != null) {
					 	FileListingWrapper fileWrapObj = new FileListingWrapper();
                        fileWrapObj.contentDocumentId = link.imageFile.contentDocumentId;
                        fileWrapObj.contentVersionId = link.imageFile.contentVersionId;
                        fileWrapObj.downloadurl = link.imageFile.downloadUrl;
                        link.imageFile = fileWrapObj;
                    }
					if(link.id == null) {
						link.id = String.valueOf(order++);
					}
				}
				String helpfulLinkJSON = JSON.serialize(options.links);
				widgetData.layout = options.layout;
				widgetData.listOfItems = (List<TileDataWrapper.TileData>)JSON.deserialize(helpfulLinkJSON,List<TileDataWrapper.TileData>.class);
			}
    	
    	} else if('latest'.equalsIgnoreCase(type) || 'popular'.equalsIgnoreCase(type)) {
			widgetData.size = options.size == null ? 1 : options.size;
			
		} else  if('twitter'.equalsIgnoreCase(type)){
    		widgetData.code = String.isBlank(options.code) ? '' : options.code;
    	
    	} else if('salesforce_apps'.equalsIgnoreCase(type) || 'site_categories'.equalsIgnoreCase(type) || 'page_categories'.equalsIgnoreCase(type)){
    		widgetData.size = options.size == null ? 1 : options.size;
    	
    	} else if('facebook'.equalsIgnoreCase(type)){
    		widgetData.height = options.height==null ? 0 :options.height;
			widgetData.url = Utility.validteURLProtocol(options.url);
			widgetData.posts = options.showPosts;
			widgetData.faces = options.showFaces;
			widgetData.cover = options.showCover;
			widgetData.code = '<div id=\"fb-root\"></div><script>(function(d, s, id) { var js, fjs = d.getElementsByTagName(s)[0];if (d.getElementById(id)) return;js = d.createElement(s); js.id = id;js.src = \"//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.3&appId=1592273594353540\";fjs.parentNode.insertBefore(js, fjs);}(document, \"script\", \"facebook-jssdk\"));</script><div class=\"fb-page\" data-href=\"#URL#\" data-width=\"#WIDTH#\" data-adapt-container-width="true" data-height=\"#HEIGHT#\" data-hide-cover=\"#COVER#\" data-show-facepile=\"#FACES#\" data-show-posts=\"#POSTS#\"><div class=\"fb-xfbml-parse-ignore\"><blockquote cite=\"#URL#\"></blockquote></div></div>';
    	
    	} else if('rss'.equalsIgnoreCase(type)){
    		widgetData.size = options.size == null ? 1 : options.size;
			widgetData.url = Utility.validteURLProtocol(options.url);
    	
    	} else if('html'.equalsIgnoreCase(type)){
			options.code = options.code?.replaceAll('allow-top-navigation', '');
			options.code = options.code?.replaceAll('allow-top-navigation-by-user-activation', '');

    		if('iframe'.equalsIgnoreCase(variant)) {
	    		widgetData.height = options.height==null ? 0 : options.height;
				widgetData.code = String.isBlank(options.code) ? '' : options.code;
    	
    		} else if('text'.equalsIgnoreCase(variant)){
				widgetData.code = String.isBlank(options.text) ? '' : options.text;
    		}
    	} else if('files'.equalsIgnoreCase(type)) {
			widgetData.type = options.type;
    		if('intranet'.equalsIgnoreCase(variant)){
				widgetData.value = Utility.convertToCommaSeparatedString(items);
    		}
    		
    		if(EFSConstants.storageTypes.contains(variant)) {
    			Integer order = 0;
				if(options.files != null && options.files.size()>0){
					
					for(TileDataWrapper.TileData file : options.files){
						file.url = Utility.validteURLProtocol(file.url);
						file.provider = variant;
						file.spInstanceId = UserContext.spInstanceId;
					}
					
					String boxFilesJSON = JSON.serialize(options.files);
					widgetData.listOfItems = (List<TileDataWrapper.TileData>)JSON.deserialize(boxFilesJSON,List<TileDataWrapper.TileData>.class);
				}
    		}
    	} else if('countdown'.equalsIgnoreCase(type)){
    		DateTime countdownStopDateTime = Utility.momentJSDateTimeStringToDateTime(options.stopAt);
	        widgetData.stopDateTime = countdownStopDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			widgetData.endTitle = options.endMessage;
    	
    	} else if('site_about'.equalsIgnoreCase(type) || 'site_info'.equalsIgnoreCase(type)){
    		if(String.isNotBlank(siteId)){
				List<Simpplr_Site__c> simpplrSiteList = [select id,Chatter_Group_Id__c from Simpplr_Site__c where id=:siteId];
				if(!simpplrSiteList.isEmpty() && String.isNotEmpty(simpplrSiteList[0].Chatter_Group_Id__c)) {
					String groupId = simpplrSiteList[0].Chatter_Group_Id__c;
					List <CollaborationGroup> cgList = new List <CollaborationGroup>();
					String BASE_QUERY= 'select description, InformationBody, InformationTitle from CollaborationGroup where id =:groupId ';
					if(SimpplrContext.isCommunitiesEnabled){
						BASE_QUERY = BASE_QUERY+'and NetworkId = null';
					}
					cgList = Database.query(BASE_QUERY);
					CollaborationGroup collabGroupObj = new CollaborationGroup();
					List<CollaborationGroup> collabGroupListToUpdate = new List<CollaborationGroup>();
					if(cgList.size()>0){
						collabGroupObj = cgList[0];
						if('site_about'.equalsIgnoreCase(type)){
							collabGroupObj.description = options.text;
							collabGroupListToUpdate.add(collabGroupObj);
							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
							SIMPESAPI.accessController().updateAsUser(new Map<Id,CollaborationGroup>(collabGroupListToUpdate),new List<Schema.SObjectField>{CollaborationGroup.description});
				    
						}else{
							collabGroupObj.InformationBody = options.text;
							collabGroupObj.InformationTitle = title;
					    	collabGroupListToUpdate.add(collabGroupObj);
					    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
							SIMPESAPI.accessController().updateAsUser(new Map<Id,CollaborationGroup>(collabGroupListToUpdate),new List<Schema.SObjectField>{CollaborationGroup.InformationBody,CollaborationGroup.InformationTitle});
						}
					}
				}
    		}
    	} else if('media'.equalsIgnoreCase(type)){
    		if('image'.equalsIgnoreCase(variant)) {
    			widgetData.url = options.url;
	    		widgetData.imageFile = options.imageFile;
	    		widgetData.title = options.title;
				widgetData.description = options.description;
				widgetData.showInfo = options.showInfo;
    	
    		} else if('video'.equalsIgnoreCase(variant)){
				widgetData.url = options.url;
				widgetData.oembed = options.oembed;
				widgetData.videoFile = options.videoFile;
				widgetData.title = options.title;
				widgetData.description = options.description;
				widgetData.showInfo = options.showInfo;
    		}
    	} else if('campaign'.equalsIgnoreCase(type)){
    		if(items != null && items.size() > 0) {
	        		widgetData.value = Utility.convertToCommaSeparatedString(items);
			 }
			 widgetData.layout = options.layout;
    	}
		return (JSON.serializePretty(widgetData,true));
	}
	
	public List<Tiles_Config__c> addTileOnUserDashboard(TileDataWrapper.AddTile tileWrapperObj){
		List<Tiles_Config__c> listOfTilesToAdd= new List<Tiles_Config__c>();
		Tiles_Config__c tileConfigObject = new Tiles_Config__c();
		tileConfigObject.Name__c=tileWrapperObj.title;
		tileConfigObject.Data__c=populateData(tileWrapperObj.title, tileWrapperObj.type, tileWrapperObj.variant, tileWrapperObj.options ,tileWrapperObj.items,'',false);
		tileConfigObject.Type__c=tileWrapperObj.type;
	    tileConfigObject.Variant__c=tileWrapperObj.variant;
		tileConfigObject.Location__c = 'Home Dashboard';
		tileConfigObject.people__c=UserContext.peopleId;
		tileConfigObject.Layout_Column__c = 1;
		tileConfigObject.Order__c = 0;
		tileConfigObject.People__c=UserContext.peopleId;
		tileConfigObject.Variant_Type__c=tileWrapperObj.variant+ '_' + tileWrapperObj.type;
		
		creatContentDocumentLinkRecords(tileWrapperObj, false);
		
		List<Tiles_Config__c> listToInsert= new List<Tiles_Config__c>(); 
		listToInsert.add(tileConfigObject);
		
		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																						Tiles_Config__c.Type__c,
																						Tiles_Config__c.Variant__c,
																						Tiles_Config__c.Data__c,
																						Tiles_Config__c.Location__c,
																						Tiles_Config__c.People__c,
																						Tiles_Config__c.Layout_Column__c,
																						Tiles_Config__c.Order__c,
																						Tiles_Config__c.Variant_Type__c};

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listToInsert, listOfColumnsToBeSet);
		
		listOfTilesToAdd = (List<Tiles_Config__c>)result.getInsertedObjects();
		
		updateOrderOfExistingTiles(UserContext.peopleId, null, null);
		
		return listOfTilesToAdd;
	}
	
	public List<Tiles_Config__c> addTileOnHomeDefaultDashboard(String segmentId, TileDataWrapper.AddTile tileWrapperObj){
		List<Tiles_Config__c> listOfTilesToAdd= new List<Tiles_Config__c>();
		Tiles_Config__c tileConfigObject = new Tiles_Config__c();
		
		tileConfigObject.Name__c=tileWrapperObj.title;
		tileConfigObject.Data__c=populateData(tileWrapperObj.title, tileWrapperObj.type, tileWrapperObj.variant, tileWrapperObj.options ,tileWrapperObj.items,'',false);
		tileConfigObject.Type__c=tileWrapperObj.type;
	    tileConfigObject.Variant__c=tileWrapperObj.variant;
		tileConfigObject.Location__c = 'Home Default';
		tileConfigObject.Layout_Column__c = 1;
		tileConfigObject.Order__c = 0;
		tileConfigObject.Segment__c = String.isBlank(segmentId) ? null : segmentId;
		tileConfigObject.Variant_Type__c = tileWrapperObj.variant+ '_' +tileWrapperObj.type;
		
    	creatContentDocumentLinkRecords(tileWrapperObj, false);
    	
		List<Tiles_Config__c> listToInsert= new List<Tiles_Config__c>(); 
		listToInsert.add(tileConfigObject);
		
		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																						Tiles_Config__c.Type__c,
																						Tiles_Config__c.Variant__c,
																						Tiles_Config__c.Data__c,
																						Tiles_Config__c.Location__c,
																						Tiles_Config__c.Layout_Column__c,
																						Tiles_Config__c.Order__c,
																						Tiles_Config__c.Segment__c,
																						Tiles_Config__c.Variant_Type__c};

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listToInsert, listOfColumnsToBeSet);
		
		listOfTilesToAdd = (List<Tiles_Config__c>)result.getInsertedObjects();
		
		List <App_Default__c> listOfDefaultObj = new List <App_Default__c>(); 
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id, Data__c From App_Default__c where Type__c=\'home-default\' And Segment__c=:soqlParam1 LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		
		if(!listOfDefaultObj.isEmpty()){
   			for (App_Default__c  appDefaultObj : listOfDefaultObj){
   				if(String.isBlank(appDefaultObj.Data__c)){
   					appDefaultObj.Data__c = listOfTilesToAdd[0].id;
   					appDefaultObj.Last_Modified_By_People__c = UserContext.peopleId;
   				}else{
   					appDefaultObj.Data__c = appDefaultObj.Data__c+','+listOfTilesToAdd[0].id;
   					appDefaultObj.Last_Modified_By_People__c = UserContext.peopleId;
   				}
   			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Default__c>(listOfDefaultObj), 
				new List<Schema.SObjectField>{
					App_Default__c.Data__c,
					App_Default__c.Last_Modified_By_People__c
				}
			);
   		}
   		else{
   			List<App_Default__c> listOfAppDefaultObj = new List<App_Default__c>();
   			for (Tiles_Config__c tileObj : listOfTilesToAdd){
   				App_Default__c defaultObj = new App_Default__c();
   				defaultObj.Data__c = tileObj.id;
   				defaultObj.Type__c = 'home-default';
   				defaultObj.Last_Modified_By_People__c = UserContext.peopleId;
   				if(String.isNotBlank(segmentId)){
   					defaultObj.Segment__c = segmentId;
   				}	
   				listOfAppDefaultObj.add(defaultObj);
   			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfAppDefaultObj, new List<Schema.SObjectField>{
					App_Default__c.Data__c,
					App_Default__c.Type__c,
					App_Default__c.Last_Modified_By_People__c,
					App_Default__c.Segment__c
					});
   		}
   		
		
		return listOfTilesToAdd;
	}
	
	public List<Tiles_Config__c> addTileOnAppHomeDashboard(TileDataWrapper.AddTile tileWrapperObj){
		List<Tiles_Config__c> listOfTilesToAdd= new List<Tiles_Config__c>();
		Tiles_Config__c tileConfigObject = new Tiles_Config__c();
		
		tileConfigObject.Name__c=tileWrapperObj.title;
		tileConfigObject.Data__c=populateData(tileWrapperObj.title, tileWrapperObj.type, tileWrapperObj.variant, tileWrapperObj.options ,tileWrapperObj.items,'',false);
		tileConfigObject.Type__c=tileWrapperObj.type;
		tileConfigObject.Variant__c=tileWrapperObj.variant;
		tileConfigObject.Location__c = 'Home Dashboard';
		tileConfigObject.Layout_Column__c = 1;
		tileConfigObject.Order__c = 0;
		tileConfigObject.Variant_Type__c = tileWrapperObj.variant+ '_' +tileWrapperObj.type;
		
    	creatContentDocumentLinkRecords(tileWrapperObj, false);
    	
		List<Tiles_Config__c> listToInsert= new List<Tiles_Config__c>(); 
		listToInsert.add(tileConfigObject);

		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																						Tiles_Config__c.Type__c,
																						Tiles_Config__c.Variant__c,
																						Tiles_Config__c.Data__c,
																						Tiles_Config__c.Location__c,
																						Tiles_Config__c.Layout_Column__c,
																						Tiles_Config__c.Order__c,
																						Tiles_Config__c.Variant_Type__c};																				
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listToInsert, listOfColumnsToBeSet);
		listOfTilesToAdd = (List<Tiles_Config__c>)result.getInsertedObjects();
		
		updateTileIdListInAppConfig(listOfTilesToAdd);
		updateOrderOfExistingTiles(null, null, null);
		
		return listOfTilesToAdd;
	}
	
	private void updateTileIdListInAppConfig(List<Tiles_Config__c> listOfNewTiles) {
		List<App_Config__c> listOfAppConfigObj = new List<App_Config__c>();
		String appConfigQuery = 'Select id, App_Home_Dashboard_Tile_Ids__c From App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		listOfAppConfigObj = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
				
		if(!listOfAppConfigObj.isEmpty()){
   			for (Tiles_Config__c  tilesConfigObj : listOfNewTiles){
   				if(String.isBlank(listOfAppConfigObj[0].App_Home_Dashboard_Tile_Ids__c)){
   					listOfAppConfigObj[0].App_Home_Dashboard_Tile_Ids__c = tilesConfigObj.id;
   				}else{
   					listOfAppConfigObj[0].App_Home_Dashboard_Tile_Ids__c = listOfAppConfigObj[0].App_Home_Dashboard_Tile_Ids__c+','+tilesConfigObj.id;
   				}
   			}
			if(!listOfAppConfigObj.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(listOfAppConfigObj),new List<Schema.SObjectField> {
																											App_Config__c.App_Home_Dashboard_Tile_Ids__c
																										});
			}
   		}
	}
	
	private void updateOrderOfExistingTiles(String peopleId, String siteId, String segmentId) {
		String query = 'Select Id, Order__c from Tiles_Config__c where Layout_Column__c = 1 and Is_Deleted__c = false';
		
		if(String.isBlank(peopleId) && String.isBlank(segmentId) && ('home'.equalsIgnoreCase(siteId) || String.isBlank(siteId))) {
			query += ' and Location__c = \'Home Dashboard\' and People__c = null and Site__c = null and Segment__c = null ';
		}
		else if(String.isBlank(peopleId) && 'home-default'.equalsIgnoreCase(siteId)) {
			query += ' and Location__c = \'Home Default\' and People__c = null and Site__c = null and Segment__c = \'' + SegmentId + '\'';
		}
		else if(String.isNotBlank(peopleId)) {
			query += ' and Location__c = \'Home Dashboard\' and People__c = \'' + peopleId + '\'';
		}
		else if(String.isNotBlank(siteId)) {
			query += ' and Location__c = \'Site Dashboard\' and Site__c = \'' +  String.escapeSingleQuotes(SiteId) + '\'';
		}
		else if(String.isNotBlank(segmentId)) {
			query += ' and Location__c = \'Segment Dashboard\' and Segment__c = \'' + SegmentId + '\'';
		}
		
		query+= ' Order by Order__c, CreatedDate DESC';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> tilesConfigList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		Integer orderCount = 1;
		for(Tiles_Config__c tileConfigObj : tilesConfigList) {
			tileConfigObj.Order__c = orderCount++;
		}
		
		if(!tilesConfigList.isEmpty()){
			RecursionCheck.stopRecursion();
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	 		SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(tilesConfigList),new List<Schema.SObjectField>{Tiles_Config__c.Order__c});
			RecursionCheck.allowToRun();
		}
	}
	
	public Boolean removeTile(String tileId, String segmentId, String dashboardId) {
		Boolean result = false;
		Map<String, Object> tileSoqlParamMap = new Map<String, Object>();
		tileSoqlParamMap.put('soqlParam1', tileId);
		String queryStr = 'select Id, Is_Deleted__c, Data__c, Variant__c, Type__c, People__c from Tiles_Config__c where id = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfTileObj = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(queryStr, tileSoqlParamMap);
		
		if('home-default'.equalsIgnoreCase(dashboardId)) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id, Data__c From App_Default__c where Type__c=\'home-default\' And Segment__c=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
			if(!listOfAppDefault.isEmpty()){
				List<String> listOfHomeDefaultTileIds =  new List<String>(); 
				for (App_Default__c  appDefaultObj : listOfAppDefault) {
					listOfHomeDefaultTileIds = appDefaultObj.Data__c.split(',');
					appDefaultObj.Last_Modified_By_People__c = UserContext.peopleId;
					if(listOfHomeDefaultTileIds[0] == tileId){
						appDefaultObj.Data__c = appDefaultObj.Data__c.replace(tileId,'').removeStart(',').removeEnd(',');
					}else{
						appDefaultObj.Data__c = appDefaultObj.Data__c.replace(','+tileId,'').removeStart(',').removeEnd(',');
					}
   				}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Default__c>(listOfAppDefault), 
					new List<Schema.SObjectField>{
						App_Default__c.Data__c,
						App_Default__c.Last_Modified_By_People__c
					}
				);
				   
			}
		} else if('home'.equalsIgnoreCase(dashboardId) && 
			SimpplrContext.isSegmentsEnabled == false && 
			ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
			if ('content_onboarding'.equalsIgnoreCase(listOfTileObj[0].Variant__c) && 
				!UserContext.isUserAppModerator && !UserContext.isNewHire) {
				if(!listOfTileObj.isEmpty()){
					String peopleId = UserContext.peopleId;
            		List<People_Preference__c> peoplePrefList = [SELECT Id, Disable_Onboarding_Home_Tile__c FROM People_Preference__c WHERE People__r.Id =:peopleId AND Is_Deleted__c = false AND People__r.Is_Deleted__c = false];
					peoplePrefList[0].Disable_Onboarding_Home_Tile__c = true;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(peoplePrefList[0],new List<Schema.SObjectField>{People_Preference__c.Disable_Onboarding_Home_Tile__c});
					result = true;
				}
			} else {
				String appConfigQuery = 'Select id, App_Home_Dashboard_Tile_Ids__c From App_Config__c LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
			
				if(!listOfAppConfig.isEmpty()){
					List<String> listOfAppHomeTileIds =  new List<String>(); 
					for (App_Config__c  appConfigObj : listOfAppConfig){
						listOfAppHomeTileIds = appConfigObj.App_Home_Dashboard_Tile_Ids__c.split(',');
						if(listOfAppHomeTileIds[0] == tileId){
							appConfigObj.App_Home_Dashboard_Tile_Ids__c = appConfigObj.App_Home_Dashboard_Tile_Ids__c.replace(tileId,'').removeStart(',').removeEnd(',');
						} else {
							appConfigObj.App_Home_Dashboard_Tile_Ids__c = appConfigObj.App_Home_Dashboard_Tile_Ids__c.replace(','+tileId,'').removeStart(',').removeEnd(',');
						}
   					}
   				
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(listOfAppConfig),new List<Schema.SObjectField> {
																												App_Config__c.App_Home_Dashboard_Tile_Ids__c});
				}
			}
		} else if ('home'.equalsIgnoreCase(dashboardId) && ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
			if(UserContext.peopleId != listOfTileObj[0].People__c) {
				throw new SimpplrException(ServiceConstants.ERROR_403); 
			}
		} else if ('home'.equalsIgnoreCase(dashboardId) && ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
			if(UserContext.peopleId != listOfTileObj[0].People__c) {
				throw new SimpplrException(ServiceConstants.ERROR_403); 
			}
		}
		// update DB record here
		if ('content_onboarding'.equalsIgnoreCase(listOfTileObj[0].Variant__c) && 
				!UserContext.isUserAppModerator && !UserContext.isNewHire &&
				ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
					//do nothing

		} else if(!listOfTileObj.isEmpty()){
			listOfTileObj[0].Is_Deleted__c = true;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	 		SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(listOfTileObj),new List<Schema.SObjectField>{Tiles_Config__c.Is_Deleted__c});
			result = true;

			//Mark File Record for native video deleted 
			if('video'.equalsIgnoreCase(listOfTileObj[0].Variant__c) && 'media'.equalsIgnoreCase(listOfTileObj[0].Type__c)){
				Map<String, Object> dataMap = ((Map<String, Object>) JSON.deserializeUntyped(listOfTileObj[0].Data__c));
				deleteVideoRecord(dataMap, tileId);
			}
		}
		return result;
	}

	/**
	 * @description delete removed videos
	 * @param dataMap - Map<String,Object> 
	 * @param tileId - String
	 */
	private void deleteVideoRecord(Map<String,Object> dataMap, String tileId){
		Map<String,Object> videoFileMap = (Map<String,Object>)dataMap.get('videoFile'); 
		if('native_video'.equalsIgnoreCase((String)videoFileMap?.get('provider'))){
			String entryId = (String)videoFileMap.get('externalFileId');
			if(String.isNotBlank(entryId)){
				List<File__c> fileList = [SELECT Id, External_id__c, is_deleted__c, Tile_Id__c FROM File__c WHERE External_id__c = :entryId AND Tile_Id__c = :tileId WITH SECURITY_ENFORCED];
				if(fileList.size() > 0){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(fileList);
					//delete video from kaltura
					VideoDao.deleteVideoInFuture(entryId);
				}
			}
		}
	}
	
	/**
		Function: editTile
		
		Params:
			   - 
	*/
	public TileDataWrapper.AddTile editTile(String segmentId, String dashboardId, String siteId, String tileId, TileDataWrapper.AddTile tileWrapperObj){
		// Update tile config object
		Tiles_Config__c tileObj = new Tiles_Config__c();
		tileObj.id = tileId;
		tileObj.Name__c = tileWrapperObj.title;
		tileObj.Type__c = tileWrapperObj.type;
		tileObj.Variant__c = tileWrapperObj.variant;
		tileObj.Data__c = populateData(tileWrapperObj.title, tileWrapperObj.type, tileWrapperObj.variant, tileWrapperObj.options ,tileWrapperObj.items, siteId,false);
		List<Tiles_Config__c> listOfTileConfig = new List<Tiles_Config__c>{tileObj};
		
		if(!listOfTileConfig.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Tiles_Config__c>(listOfTileConfig),new List<Schema.SObjectField> {
																										Tiles_Config__c.Name__c,
																										Tiles_Config__c.Type__c,
																										Tiles_Config__c.Variant__c,
																										Tiles_Config__c.Data__c
																									});
		}

		Boolean isRelatedToSite = String.isNotBlank(siteId)?true:false;
		creatContentDocumentLinkRecordsForEdit(tileWrapperObj,isRelatedToSite);
		if('home-default'.equalsIgnoreCase(dashboardId)){
			List <App_Default__c> listOfDefaultObj = new List <App_Default__c>(); 
		
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', segmentId);
			String query = 'Select id,Last_Modified_By_People__c From App_Default__c where segment__c=:soqlParam1 And Type__c=\'home-default\' LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
			
			if(!listOfDefaultObj.isEmpty()){
				for (App_Default__c  appDefaultObj : listOfDefaultObj){
					appDefaultObj.Last_Modified_By_People__c = UserContext.getCurrentUserInfo.Id;
				}

				if(!listOfDefaultObj.isEmpty()){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Default__c>(listOfDefaultObj),new List<Schema.SObjectField> {
																													App_Default__c.Last_Modified_By_People__c
																												});
				}
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Default__c>(listOfDefaultObj), 
					new List<Schema.SObjectField>{
						App_Default__c.Last_Modified_By_People__c
					}
				);
			}
			
		}
		
		return tileWrapperObj;
	}
    
    public TileDataWrapper.CategoriesData getPageCategoriesTileData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	Integer limitOfRecords = tiledataSetting.size != null ? tiledataSetting.size : 5; 
    	TileDataWrapper.CategoriesData pageCategoriesDataObj = new TileDataWrapper.CategoriesData();
    	
    	List<TileDataWrapper.TileData> listOfTileDataWrap = new List<TileDataWrapper.TileData>();
    	
    	Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteOrHomeId);
		soqlParamMap.put('soqlParam2', limitOfRecords);
		String pageCtgryQuery = 'select id, Name__c, Site__c, (Select id ' +
				' from Simpplr_Content_Page_Category__r where is_deleted__c=false and is_Published__c=true) ' +
			' from Pages_category__c  ' +
			' where is_deleted__c = false  ' +
			' and site__c=:soqlParam1  ' +
			' and id in (select Pages_Category__c  ' +
						' from Simpplr_Content__c  ' +
						' where is_deleted__c=false  ' +
						' and is_Published__c=true  ' +
						' and site__c=:soqlParam1) ' +
			' order by Order__c asc, lastModifiedDate desc limit :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Pages_Category__c> listOfPageCategories = (List<Pages_Category__c>)SIMPESAPI.accessController().queryAsUser(pageCtgryQuery, soqlParamMap);
	
    	for(Pages_Category__c categoryObj : listOfPageCategories) {
    		TileDataWrapper.TileData dataObj = new TileDataWrapper.TileData();
		 	dataObj.pageCount = categoryObj.Simpplr_Content_Page_Category__r.size();
		 	dataObj.Id = categoryObj.Id;
		 	dataObj.Name = categoryObj.Name__c;
		 	dataObj.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + categoryObj.Site__c + '/content&type=page&pageCategoryId=' + categoryObj.id;
		 	listOfTileDataWrap.add(dataObj);
			
    	}
    	pageCategoriesDataObj.listOfItems = listOfTileDataWrap;
    	pageCategoriesDataObj.options.size = limitOfRecords;
    	pageCategoriesDataObj.id = tileId;


    	return pageCategoriesDataObj;
    }
    
    public TileDataWrapper.CategoriesData getSiteCategoriesTileData(String siteOrHomeId, String tileId, TileDataWrapper.TileDataSettings tiledataSetting) {
    	Integer limitOfRecords = tiledataSetting.size != null ? tiledataSetting.size : 5; 
    	TileDataWrapper.CategoriesData siteCategoriesDataObj = new TileDataWrapper.CategoriesData();
    	
    	List<TileDataWrapper.TileData> listOfTileDataWrap = new List<TileDataWrapper.TileData>();
    	List<Id> listOfCollabIds=getListOfCollaborationGroupIds();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfCollabIds);
		soqlParamMap.put('soqlParam2', limitOfRecords);
		String query = 'select id, Name__c, (Select id from Simpplr_Sites_Site_Category__r  ' +
				' where Chatter_Group_Id__c !=\'S06I000000MPPLR\' ' +
				' And Is_Active__c=true And Show_In_Simpplr__c = true ' +
				' And Chatter_Group_Id__c= :soqlParam1)  ' +
			' from Site_Category__c  ' +
			' where is_deleted__c = false  ' +
			' and id in (select Site_Category__c  ' +
				' from Simpplr_Site__c  ' +
				' where Is_Active__c=true  ' +
				' and Chatter_Group_Id__c !=\'S06I000000MPPLR\' ' +
				' And Chatter_Group_Id__c= :soqlParam1) ' +
			' order by Order__c,CreatedDate limit :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Category__c> listOfSiteCategories = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    													
    	for(Site_Category__c categoryObj : listOfSiteCategories) {
    		TileDataWrapper.TileData dataObj = new TileDataWrapper.TileData();
		 	dataObj.siteCount = categoryObj.Simpplr_Sites_Site_Category__r.size();
		 	dataObj.Id = categoryObj.Id;
		 	dataObj.Name = categoryObj.Name__c;
		 	listOfTileDataWrap.add(dataObj);
    	}
    	siteCategoriesDataObj.listOfItems = listOfTileDataWrap;
    	siteCategoriesDataObj.options.size = limitOfRecords;
    	siteCategoriesDataObj.id = tileId;
    	
    	return siteCategoriesDataObj;
    }
    
    private List<Id> getListOfCollaborationGroupIds (){
		List<CollaborationGroup> listOfCollaborationGroup = new List<CollaborationGroup>();
		String BASE_QUERY= 'SELECT Id FROM CollaborationGroup ';
		if(SimpplrContext.isCommunitiesEnabled){
    		BASE_QUERY = BASE_QUERY+'Where NetworkId = null';
    	}
    	listOfCollaborationGroup = Database.query(BASE_QUERY);
		List<Id> listOfIds= new List<Id>();
		for(CollaborationGroup cg: listOfCollaborationGroup){
			listOfIds.add(cg.Id);
		}
		return listOfIds;
	}
    
   	public  TileDataWrapper.PeopleData getCelebrationPeopleData(String siteOrHomeId, String tileId,String variant, TileDataWrapper.TileDataSettings tiledataSetting) {
    	logger.logDebug('TileService.getCelebrationPeopleData()----siteOrHomeId----'+siteOrHomeId+'----tileId----'+tileId+'----variant----'+variant);
    	TileDataWrapper.PeopleData peopleDataObj = new TileDataWrapper.PeopleData();
    	String loggedInPeopleId = UserContext.peopleId;
		Integer daysLimit = '7'.equalsIgnoreCase(tiledataSetting.celebrationsDays) ? 7 : 30;
		String filter = 'all'.equalsIgnoreCase(tiledataSetting.celebrationsPeople) ? 'all' : 'following';
    	List<TileDataWrapper.TileData> listOfTileDataWrap = new List<TileDataWrapper.TileData>();
    	date today = date.today();
		Integer thisyear = today.year();
		Integer todayDayofYear =today.dayofYear(); 
		if(Date.isLeapYear(thisyear) == false){
			todayDayofYear = today.dayofYear() + 1; 
		}
    	PeopleDao daoObj = new PeopleDao();
		List<People__c> listOfPeople = daoObj.getCelebrations(filter, daysLimit,todayDayofYear);
		Integer total = listOfPeople.size();
	
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		for(People__c peopleObj : listOfPeople) {
			String daysToBirthday;
            String daysToJoining;
            if(peopleObj.Birth_Date__c != null){
                daysToBirthday = String.valueOf(PeopleContentProvider.getdaystocelebration(integer.valueOf(peopleobj.Day_Of_Year_B__c),todayDayofYear)) + 'B';
            }
            if(peopleObj.Joining_Date__c != null){
                daysToJoining = String.valueOf(PeopleContentProvider.getdaystocelebration(integer.valueOf(peopleobj.Day_Of_Year_J__c),todayDayofYear)) + 'A';
            }
			PeopleListWrapper wrapperObj = PeopleListWrapper.peopleToWrapper(peopleObj);
			wrapperObj.img = peopleObj.user__r.FullPhotoURL.endsWith('005/F') ? null : peopleObj.user__r.FullPhotoURL;
			wrapperObj.relevancyScore = PeopleContentProvider.getCelbrationScore(daysToBirthday , daysToJoining);
			listOfPeopleWrapper.add(wrapperObj);
		}
		listOfPeopleWrapper.sort();
		
		for(Integer i =0; i<total ; i++){
			TileDataWrapper.TileData tilePeopleWrapObj = new TileDataWrapper.TileData();
			
			PeopleListWrapper pplWrapper = listOfPeopleWrapper[i];
			tilePeopleWrapObj.id = pplWrapper.peopleId;
			tilePeopleWrapObj.sfUserId = pplWrapper.sfUserId;
			tilePeopleWrapObj.name = pplWrapper.name;
			tilePeopleWrapObj.title = pplWrapper.title;
			tilePeopleWrapObj.department = pplWrapper.department;
			tilePeopleWrapObj.img = pplWrapper.img;	    				
			tilePeopleWrapObj.location = pplWrapper.location;
			tilePeopleWrapObj.peopleId = pplWrapper.peopleId;
			tilePeopleWrapObj.isFavorited = pplWrapper.isFavorited; 
			tilePeopleWrapObj.isActive = pplWrapper.isActive;
			tilePeopleWrapObj.isFollowing =pplWrapper.isFollowing;
			tilePeopleWrapObj.canFollow = pplWrapper.canFollow;
        	tilePeopleWrapObj.birthday = pplWrapper.birthday;
        	tilePeopleWrapObj.hireDate = pplWrapper.hireDate;
        	tilePeopleWrapObj.url = pplWrapper.url;
        	
			listOfTileDataWrap.add(tilePeopleWrapObj);
			
		}
		
		peopleDataObj.total = total;
    	peopleDataObj.siteId = siteOrHomeId;	
    	peopleDataObj.listOfItems = listOfTileDataWrap;	
		peopleDataObj.options.layout = tiledataSetting.layout;
		peopleDataObj.options.celebrationsPeople = filter;
		peopleDataObj.options.celebrationsDays = String.valueOf(daysLimit);
    	return peopleDataObj;
   	}
   	
   	public TileDataWrapper.TileOrderData createUserDefaultTiles(){
   		List<App_Default__c> appDefaultList = new List<App_Default__c>();
   		if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
   			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.segmentId);
			String query = 'Select id, Data__c, Layout__c From App_Default__c where Type__c=\'home-default\' and Segment__c =:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   		} else if(SimpplrContext.isSegmentsEnabled == false){
   			String query = 'Select id, Data__c, Layout__c From App_Default__c where Type__c=\'home-default\' and Segment__c = null';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
   		}
   		TileDataWrapper.TileOrderData tilesOrderData = new TileDataWrapper.TileOrderData();
   		
   		List <String> listOfHomeDefaultTileIds = new List <String>();
   		List<Tiles_Config__c> listOfHomeDefaultTiles = new List<Tiles_Config__c>();
   		String layout = 'd';
   		if(appDefaultList.isEmpty() == false){
   			if(String.isNotBlank(appDefaultList[0].Data__c)) {
				listOfHomeDefaultTileIds = appDefaultList[0].Data__c.split(',');
			   }
			   if(String.isNotBlank(appDefaultList[0].Layout__c)) {
				layout = appDefaultList[0].Layout__c;
			   }
   		}
   		
   		try {
   			if(listOfHomeDefaultTileIds != null){
   				Map<String, Object> tileSoqlParamMap = new Map<String, Object>();
				tileSoqlParamMap.put('soqlParam1', listOfHomeDefaultTileIds);
				String queryStr = 'SELECT Id, Name__c, Data__c,Mobile_Order__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
					' FROM Tiles_Config__c where Id IN: soqlParam1 and Is_Deleted__c=false';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				listOfHomeDefaultTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(queryStr, tileSoqlParamMap);
			
				List<Tiles_Config__c> listOfUserTiles = new List<Tiles_Config__c>();	
				for(Tiles_Config__c configObj: listOfHomeDefaultTiles) {
					Tiles_Config__c newTilesConfig = new Tiles_Config__c();
					
					newTilesConfig.Data__c = configObj.Data__c;
					newTilesConfig.Name__c = configObj.Name__c;
					newTilesConfig.Type__c = configObj.Type__c;
					newTilesConfig.Variant__c = configObj.Variant__c;
					newTilesConfig.Location__c = 'Home Dashboard';
					newTilesConfig.Layout_Column__c = configObj.Layout_Column__c;
					newTilesConfig.Order__c = configObj.Order__c;
					newTilesConfig.People__c = UserContext.peopleId;
					newTilesConfig.Variant_Type__c = configObj.Variant__c+ '_' +configObj.Type__c;
					listOfUserTiles.add(newTilesConfig);
	   			}
	   			if(listOfUserTiles.size() > 0) {
		   			List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Data__c,
																							Tiles_Config__c.Name__c,
																							Tiles_Config__c.Type__c,
																							Tiles_Config__c.Variant__c,
																							Tiles_Config__c.Layout_column__c,
																							Tiles_Config__c.Order__c,
																							Tiles_Config__c.People__c,
																							Tiles_Config__c.Location__c,
																							Tiles_Config__c.Variant_Type__c};

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listOfUserTiles, listOfColumnsToBeSet);

					listOfUserTiles = (List<Tiles_Config__c>)result.getInsertedObjects();
	   			}
				
				updateTilesInitializedInPeopleContext(UserContext.peopleId, layout);
				
				Map<String, TileDataWrapper.TilesOrder> mapOfOrderedTile = new Map<String, TileDataWrapper.TilesOrder>();
				
	   			for(Tiles_Config__c userTile : listOfUserTiles) {
   					if('content'.equalsIgnoreCase(userTile.Type__c) && 'latest_popular'.equalsIgnoreCase(userTile.Variant__c)) {
		   				TileDataWrapper.TileDataSettings tilesData = (TileDataWrapper.TileDataSettings)JSON.deserialize(userTile.Data__c,TileDataWrapper.TileDataSettings.class);
			   			if(isContentFeatureDisabled(tilesData.type)){
							continue;
						}
		   			} else if('campaigns'.equalsIgnoreCase(userTile.Type__c)) {
		   				if(SimpplrContext.isEmployeeAdvocacyEnabled == false){
		   					continue;
		   				}
		   			}
	   				TileDataWrapper.TilesOrder orderedTile = new TileDataWrapper.TilesOrder();
	   				orderedTile.id = userTile.Id;
		   			orderedTile.order = userTile.Order__c.intValue();	
		   			orderedTile.mobileDashboardIndex = userTile.Mobile_Order__c != null ? userTile.Mobile_Order__c.intValue() : 0;
		   			orderedTile.column = String.valueOf(userTile.Layout_Column__c);
	   				orderedTile.title = userTile.Name__c;
	   				orderedTile.type = userTile.Type__c;
	   				orderedTile.variant = userTile.Variant__c;
   					mapOfOrderedTile.put(orderedTile.id, orderedTile);
	   			}
	   			
   				tilesOrderData.layout = layout;
   			
   				tilesOrderData.canManage = ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode);
				//DASHBOARD_OWNER_USER = user // AppDashboardMode = Manager// 
				System.debug('********tilesOrderData  2849'+tilesOrderData.canManage);

   				
   			if(!listOfHomeDefaultTiles.isEmpty()){
   				tilesOrderData.isDefaultConfigured = true;
   			}else{
   				tilesOrderData.isDefaultConfigured = false;
   			}
   			tilesOrderData.isManagerControlled = false;
   			tilesOrderData.listOfItems = mapOfOrderedTile.values();
   			}
   		}catch(Exception e){
   			logger.logError('Records are not fetched',e);
   		}
   		return tilesOrderData;
   	}
   	
   	public Boolean resetToDefaultHomeDashboard(String segmentId){
   		Boolean isRecordInserted = false;
   		
			Map<String, Object> tileSoqlParamMap = new Map<String, Object>();
			tileSoqlParamMap.put('soqlParam1', UserContext.peopleId);
			String tileQuery = 'SELECT Id FROM Tiles_Config__c where people__c=:soqlParam1 And Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> listOfUserTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(tileQuery, tileSoqlParamMap);
   														 
	   		if (!listOfUserTiles.isEmpty() && ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
	   			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(listOfUserTiles);
	   		}
   		
   		List <String> listOfHomeDefaultTileIds = new List <String>();
   		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id, Data__c, Type__c,Layout__c From App_Default__c where Segment__c=:soqlParam1 And Type__c=\'home-default\' LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List <App_Default__c> listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   		
   		if(listOfDefaultObj.isEmpty() == false){
   			if(String.isNotBlank(listOfDefaultObj[0].Data__c)) {
				listOfHomeDefaultTileIds = listOfDefaultObj[0].Data__c.split(',');
   			}
   			
			String layoutToSet = listOfDefaultObj[0].Layout__c;
			
			List<People_Preference__c> listOfPeoplePreference = [Select Id, Layout__c, User__c, People__c 
																 From People_Preference__c 
																 Where people__c = :UserContext.peopleId And Layout__c != :layoutToSet WITH SECURITY_ENFORCED];
																 
			if(!listOfPeoplePreference.isEmpty()){
				for(People_Preference__c pplPref : listOfPeoplePreference){
					pplPref.Layout__c = layoutToSet;
				}
				update listOfPeoplePreference;
			}
   		}
   		tileSoqlParamMap = new Map<String, Object>();
		tileSoqlParamMap.put('soqlParam1', listOfHomeDefaultTileIds);
		tileQuery = 'SELECT Id, Name__c, Data__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c ' +
			' FROM Tiles_Config__c where Id IN:soqlParam1 And Is_Deleted__c = false ' +
			' order by Layout_Column__c, Order__c,CreatedDate desc';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfHomeDefaultTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(tileQuery, tileSoqlParamMap);
		List<Tiles_Config__c> listToInsert= new List<Tiles_Config__c>(); 
		for(Tiles_Config__c tileObj : listOfHomeDefaultTiles){
			Tiles_Config__c tileConfigObject = new Tiles_Config__c();
			tileConfigObject.Name__c = tileObj.Name__c;
			tileConfigObject.Type__c = tileObj.Type__c;
			tileConfigObject.Variant__c = tileObj.Variant__c;
			tileConfigObject.Data__c = tileObj.Data__c;
			tileConfigObject.Location__c = 'Home Dashboard';
			tileConfigObject.people__c=UserContext.peopleId;
			tileConfigObject.Layout_Column__c = tileObj.Layout_Column__c;
			tileConfigObject.Order__c = tileObj.Order__c;
			tileConfigObject.Variant_Type__c = tileObj.Variant__c + '_' + tileObj.Type__c;
			listToInsert.add(tileConfigObject);
			}
			
			List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																							Tiles_Config__c.Type__c,
																							Tiles_Config__c.Variant__c,
																							Tiles_Config__c.Data__c,
																							Tiles_Config__c.Location__c,
																							Tiles_Config__c.People__c,
																							Tiles_Config__c.Layout_Column__c,
																							Tiles_Config__c.Order__c,
																							Tiles_Config__c.Variant_Type__c};
			if(!listToInsert.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert, listOfColumnsToBeSet);
				isRecordInserted = true;
			}
			
		return isRecordInserted;
   	}
   	
   	public Boolean applyDefaultHomeToAllUsers(String segmentId, String dashboardId){
	   	Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', segmentId);
		String query = 'Select id, OverwriteBatchInProgress__c From App_Default__c where Type__c=\'home-default\' AND Segment__c=:soqlParam1 LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List <App_Default__c> listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

   		if(!listOfDefaultObj.isEmpty()){
   			listOfDefaultObj[0].OverwriteBatchInProgress__c = true;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(listOfDefaultObj[0], 
				new List<Schema.SObjectField>{
					App_Default__c.OverwriteBatchInProgress__c
				}
			);
   		}
   		BatchOverwriteAppDefaults deleteTileJob = new BatchOverwriteAppDefaults('DeleteOldTiles', true, segmentId);
		Database.executeBatch(deleteTileJob,100);
		return true;
   	}
   	
   	private Boolean isContentFeatureDisabled(String tilesType){
   		Boolean isFeatureDisabled = true;
   		if(String.isBlank(tilesType) || 'all'.equalsIgnoreCase(tilesType)) {
   			isFeatureDisabled = false;
   		} else if(SimpplrContext.AllowedFeatures.containsIgnoreCase('Blog') && 'blog_post'.containsIgnoreCase(tilesType)) {
   			isFeatureDisabled = false;
   		} else if(SimpplrContext.AllowedFeatures.containsIgnoreCase(tilesType)){
   			isFeatureDisabled = false;
   		}
		return isFeatureDisabled;
	}
	
	public TileDataWrapper.FileDataGoogleDrive getStarredAndRecentGoogleDriveFiles(String siteOrHomeId) {
		TileDataWrapper.FileDataGoogleDrive fileDataGoogleDriveObj = new TileDataWrapper.FileDataGoogleDrive();

		fileDataGoogleDriveObj.options.type = 'recent_and_starred';
		
		TileDataWrapper.TileDataSection recentGDriveFiles = getRecentGoogleDriveFiles(siteOrHomeId);
		TileDataWrapper.TileDataSection starredGDriveFiles = getStarredGoogleDriveFiles(siteOrHomeId);

		fileDataGoogleDriveObj.listOfItems.add(recentGDriveFiles);
		fileDataGoogleDriveObj.listOfItems.add(starredGDriveFiles);
		
		return fileDataGoogleDriveObj;
	} 

	private TileDataWrapper.TileDataSection getRecentGoogleDriveFiles(String siteOrHomeId) {
		TileDataWrapper.TileDataSection recentGDriveFiles = new TileDataWrapper.TileDataSection();

		GoogleDriveService gDServiceObj = new GoogleDriveService();
		List<TileDataWrapper.TileData> fileList = gDServiceObj.getGoogleDriveTilesData('recent');
		
		recentGDriveFiles.listOfItems = fileList;
		recentGDriveFiles.section = 'recent';

		return recentGDriveFiles;
	}

	private TileDataWrapper.TileDataSection getStarredGoogleDriveFiles(String siteOrHomeId) {
		TileDataWrapper.TileDataSection recentGDriveFiles = new TileDataWrapper.TileDataSection();
		
		GoogleDriveService gDServiceObj = new GoogleDriveService();
		List<TileDataWrapper.TileData> fileList = gDServiceObj.getGoogleDriveTilesData('starred');
		
		recentGDriveFiles.listOfItems = fileList;
		recentGDriveFiles.section = 'starred';

		return recentGDriveFiles;
	}
	public void createVideoFileRecord(FileListingWrapper videoFile) {
		File__c fileObj = new File__c();
        fileObj.External_Id__c = videoFile.externalFileId;
		fileObj.Title__c = videoFile.title;
		fileObj.size__c = videoFile.size !=null ? Decimal.valueOf(videoFile.size) : 0;
        fileObj.MIME_Type__c = 'video';
        fileObj.Author__c = UserContext.peopleId;
		fileObj.Video_Provider__c = ServiceConstants.VIDEO_PROVIDER_NATIVE;
		fileObj.Repository__c = ServiceConstants.VIDEO_PROVIDER_NATIVE;
        fileObj.Thumbnail_URL__c = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + videoFile.externalFileId +'/width/550/height/480';

		Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
		if(captionLanguageId != null){
			
			fileObj.Video_Caption_Language__c = String.valueOf(captionLanguageId);
		}

        insert fileObj;
	}

	/**
	 * @description make udpates in file__c records for Tile 
	 * @param String - entryId
	 * @param String - tileId
	 */
	public void updateVideoFileRecord(String entryId, String tileId) {
		String oldVideoId = '';
		List<File__c> fileList = [SELECT Id, External_id__c, Tile_Id__c, Site__c FROM File__c WHERE External_id__c = :entryId OR Tile_Id__c =:tileId  WITH SECURITY_ENFORCED ORDER BY Createddate DESC];
		List<File__c> filesToDelete = new List<File__c>();

		Integer i = 0;
		for(File__c file: fileList){
			if(file.External_id__c != entryId){
				oldVideoId = file.External_id__c;
				file.External_id__c = entryId;
			}
			if(String.isBlank(file.Tile_Id__c) && String.isNotBlank(tileId)){
				file.Tile_Id__c = tileId;
				file.Site__c = null;
			}

			if(i != 0 ){
				filesToDelete.add(file);
			}
			i++;
		}
		if(fileList.size() > 0){
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				File__c.External_id__c,
				File__c.Tile_Id__c,
				File__c.Site__c
			};

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,File__c>(fileList), listOfColumnsToBeUpdated);
		}

		//Delete duplicate files for a tile if any
		if(filesToDelete.size() > 0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(filesToDelete);
		}
		
		//removed video from edit modal - delete from kaltura
		if(String.isNotBlank(oldVideoId)){
			VideoDao.deleteVideoInFuture(oldVideoId);
		}
	}
	
    /**
     * @description duplicate site tiles
     * @param originalSiteId original site id
     * @param duplicateSiteId new duplicate site id
     */
	public void duplicateSiteDashboardTiles(String originalSiteId, String duplicateSiteId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', originalSiteId);
		String query = 'SELECT Id, Name__c, Data__c, Type__c, Variant__c, Layout_Column__c, Order__c, People__c, Site__c, Location__c ' +
			' FROM Tiles_Config__c where Site__c =: soqlParam1 And Location__c = \'Site Dashboard\' And Is_Deleted__c = false '+
			' And Is_Active__c = true order by Order__c ASC' ;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> listOfTilesToAdd = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(listOfTilesToAdd != null && !listOfTilesToAdd.isEmpty()) { 
			duplicateSiteDashboardTiles(listOfTilesToAdd, duplicateSiteId);
		}
	}

    /**
     * @description duplicate site tiles
     * @param listOfTilesToAdd tiles to add
     * @param duplicateSiteId duplicate site id
     */
	public void duplicateSiteDashboardTiles(List<Tiles_Config__c> listOfTilesToAdd, String duplicateSiteId){
		List<Tiles_Config__c> listToInsert = new List<Tiles_Config__c>(); 
		Integer order = 1;
		for(Tiles_Config__c oriTileConfigObj : listOfTilesToAdd) {
 			TileDataWrapper.TileDataSettings tileDataSettings = (TileDataWrapper.TileDataSettings)JSON.deserialize(oriTileConfigObj.data__c, TileDataWrapper.TileDataSettings.class);
			Tiles_Config__c tileConfigObject = new Tiles_Config__c();
			if('media'.equalsIgnoreCase(oriTileConfigObj.Type__c) && 'image'.equalsIgnoreCase(oriTileConfigObj.Variant__c)) {
				continue;
			} else if('media'.equalsIgnoreCase(oriTileConfigObj.Type__c) && 'video'.equalsIgnoreCase(oriTileConfigObj.Variant__c) && tileDataSettings.videoFile != null) {
				continue;
			} else if('content'.equalsIgnoreCase(oriTileConfigObj.Type__c) && 'custom'.equalsIgnoreCase(oriTileConfigObj.Variant__c)) {
				continue;
			} else if('Files'.equalsIgnoreCase(oriTileConfigObj.Type__c) && 'intranet'.equalsIgnoreCase(oriTileConfigObj.Variant__c)) {
				String contentDocumentIds = tileDataSettings.value;
				List<String> contentDocumentList = contentDocumentIds.split(',');
				List<ContentDocument> listOfAccessContentDocument = [Select id From ContentDocument Where Id In: contentDocumentList WITH SECURITY_ENFORCED];
				List<String> listOfCD = new List<String>();
				for(ContentDocument cd : listOfAccessContentDocument) {
					listOfCD.add(cd.id);
				}
				TileDataWrapper.TileDataSettings widgetData = new TileDataWrapper.TileDataSettings();
				if(listOfCD != null && listOfCD.size() > 0) {
					widgetData.value = Utility.convertToCommaSeparatedString(listOfCD);
				} else {
					widgetData.value = '';
				}
				tileConfigObject.Data__c =  JSON.serializePretty(widgetData,true);
			} else {
				tileConfigObject.Data__c = oriTileConfigObj.Data__c;
			}
			
			tileConfigObject.Name__c = oriTileConfigObj.Name__c;			
			tileConfigObject.Type__c = oriTileConfigObj.Type__c;
			tileConfigObject.Variant__c = oriTileConfigObj.variant__c;		
			tileConfigObject.Location__c = 'Site Dashboard';
			tileConfigObject.Layout_Column__c = oriTileConfigObj.Layout_Column__c;
			tileConfigObject.Order__c = order;
			tileConfigObject.site__c = duplicateSiteId;
			tileConfigObject.Variant_Type__c = oriTileConfigObj.variant__c+ '_' +oriTileConfigObj.Type__c;
			listToInsert.add(tileConfigObject);
			order = order+1;
		}
    	
		
		if(listToInsert.size() > 0) {
			List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Name__c,
																							Tiles_Config__c.Type__c,
																							Tiles_Config__c.Variant__c,
																							Tiles_Config__c.Data__c,
																							Tiles_Config__c.Location__c,
																							Tiles_Config__c.site__c,
																							Tiles_Config__c.Order__c,
																							Tiles_Config__c.Layout_Column__c,
																							Tiles_Config__c.Variant_Type__c};
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(listToInsert, listOfColumnsToBeSet);
		}       
    }

}