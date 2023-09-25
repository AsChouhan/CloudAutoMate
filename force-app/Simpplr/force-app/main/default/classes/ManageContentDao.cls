/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ManageContentDao{ 
	public Static final String CONTENT_STATUS_DELETED = 'Delete';
	public static List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		
	private static final String pagePlaceholderImage = 'https://static.simpplr.com/slack/page.png';
	private static final String eventPlaceholderImage = 'https://static.simpplr.com/slack/event.png';
	private static final String albumPlaceholderImage = 'https://static.simpplr.com/slack/album.png';
	private static final String blogPlaceholderImage = 'https://static.simpplr.com/slack/blog.png';
	private static final String filePlaceholderImage = 'https://static.simpplr.com/slack/file.png';	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static String getCurrentApprovalStatus(String contentId){
		String approvalStatus = null;
		try{
			List<Simpplr_Content__c> simContentList = [select id, Status__c from Simpplr_Content__c where Is_Deleted__c=false and id=:contentId WITH SECURITY_ENFORCED];
			if(simContentList!=null && simContentList.size()>0){
				approvalStatus = simContentList[0].Status__c;
			}
		}catch(Exception e){
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return approvalStatus;
	}
		
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public Boolean updateContent(String contentId, String status){
		logger.logDebug('ManageContentDao.updateContent()-----contentId----' + contentId + '----status----' + status);
		try{
			Simpplr_Content__c simContent = new Simpplr_Content__c(id=contentId);
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentId);
			String filesQuery = 'SELECT Id, Is_Deleted__c, Content_Document__c, Simpplr_content__r.Type__c, Simpplr_content__r.Site__c, '+
											' Simpplr_content__r.Site__r.Site_Type__c, Simpplr_content__r.Site__r.Chatter_Group_Id__c, Repository__c '+
											' FROM FILE__c Where Simpplr_Content__c =: soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> listOfFileObj = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
			String contentType = null;
			List<Simpplr_Content__c> simpContentList = null;

			if( !listOfFileObj.isEmpty() ) {
				contentType = listOfFileObj[0].Simpplr_content__r.Type__c;	
			} else {
				simpContentList = [SELECT Id, Type__c, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c FROM Simpplr_Content__c WHERE Id = :contentId WITH SECURITY_ENFORCED];
				if(!simpContentList.isEmpty()) {
					contentType = simpContentList[0].Type__c;
				}
			}
			
			soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentId);
			String folderQuery = 'SELECT id, Parent_Folder__r.name__c from Folder__c where External_Folder_Id__c =: soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOffolder = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			Folder__c folder;
			if(!listOffolder.isEmpty() && listOffolder.size()>0){
				if((ServiceConstants.DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP.get('ALBUMS')).equalsIgnoreCase(listOffolder[0].Parent_Folder__r.name__c)){
						folder = new Folder__c(id = listOffolder[0].id);
				}
			}
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>();
			List<Schema.SObjectField> listOfColumnsToBeUpdatedForFolder = new List<Schema.SObjectField>();

			if (!String.isBlank(status) && CONTENT_STATUS_DELETED.equalsIgnoreCase(status)) {
				simContent.Is_Deleted__c = true;
				listOfColumnsToBeUpdated.add(Simpplr_Content__c.Is_Deleted__c);

			} else if (!String.isBlank(status)){
				simContent.Status__c =status;
				listOfColumnsToBeUpdated.add(Simpplr_Content__c.Status__c);
			}
			
			simContent.Last_Edited_DateTime__c = DateTime.now();
			listOfColumnsToBeUpdated.add(Simpplr_Content__c.Last_Edited_DateTime__c);

			//album related change
			if(folder != null){
				if(CONTENT_STATUS_DELETED.equalsIgnoreCase(status)){
					folder.Is_Deleted__c = true;
					for(File__c fileObj : listOfFileObj){
						fileObj.Is_Deleted__c = true;
					}
					listOfColumnsToBeUpdatedForFolder.add(Folder__c.Is_Deleted__c);
				}
			}
			
			// Create CDL for all files based on Content Status, isPublished and siteType
			if(ServiceConstants.CONTENT_STATUS_SUBMIITED.equalsIgnoreCase(status) && listOfFileObj.size() > 0 && !(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentType))) {
				String groupId = listOfFileObj[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c;
        		Boolean isPublicSite = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(listOfFileObj[0].Simpplr_content__r.Site__r.Site_Type__c);
				
				logger.logDebug('AllContentDataServer.creating CDLs -----groupId:'+ groupId + '----isPublicSite:' + isPublicSite + '----listOfFileObj:' + listOfFileObj);
				FileDao fileDaoObj = new FileDao();
				fileDaoObj.createContentDocumentLinks(status, true, listOfFileObj, groupId, isPublicSite);
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(simContent,listOfColumnsToBeUpdated);
			
    		if(!listOfColumnsToBeUpdatedForFolder.isEmpty() && listOfColumnsToBeUpdatedForFolder.size()>0){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    			SIMPESAPI.accessController().updateAsUser(folder,listOfColumnsToBeUpdatedForFolder);
			}
    		if(!listOfFileObj.isEmpty() && listOfFileObj.size()>0){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(listOfFileObj), 
														new List<Schema.SObjectField>{File__c.Is_Deleted__c});
			}
			
    		// Delete all related notifications as well
    		
    		if(!String.isBlank(status) && CONTENT_STATUS_DELETED.equalsIgnoreCase(status)){ 
    			
    			BatchDeleteAppNotifications batchAppNoti = new BatchDeleteAppNotifications(contentId);
				Database.executeBatch(batchAppNoti, 1000);
				if(SimpplrContext.isInitiativesAndCampaignsEnabled){
					CIService.deleteCIItems('content', contentId);
				}
			}
			
			// Email notification on event delete
			if(CONTENT_STATUS_DELETED.equalsIgnoreCase(status) &&
					 'Event'.equalsIgnoreCase(contentType)){
				
				BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contentId, 'eventDeleted', true, true);
				Database.executeBatch(job, 25);
				
			}

			return true; 
		}catch(Exception e){
			logger.logError('ManageContentDao.updateContent()-----could not update content----',e);
			return false;
		}
	}
	
	public static String checkContentStatus(String contentId){
		String contentStatus = '';
		List<Simpplr_Content__c> simContentList = [SELECT Id, Status__c  FROM Simpplr_Content__c where Id=:contentId WITH SECURITY_ENFORCED];
		if(!simContentList.isEmpty()){
			contentStatus = simContentList.get(0).Status__c;
		}
		return contentStatus;
	}

	public Integer getContentPublishedCount(String peopleId) { 
		DateTime minAllowedEventEndDateTime = DateTime.now();
        
		return [Select count() from Simpplr_Content__c 
				Where Primary_Author__c =:peopleId 
				AND Activated_By_Feature__c = true
				And TYPE__c IN : allowedFeaturesInAppList
				AND (TYPE__c='BlogPost' or (site__r.is_Active__c=true AND Site__r.Show_In_Simpplr__c = true))
				AND Status__c ='Approved' 
				AND Is_Published__c = true 
				And ((Event_End_DateTime__c = null) OR (Event_End_DateTime__c >:minAllowedEventEndDateTime))
				AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
	}
	
	public String getMostPopularPublicContentURL() {
		String popularContentUrl;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', allowedFeaturesInAppList);
		String blogSubCondition = '';
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG)) {
			blogSubCondition = ' or Content__r.type__c = \'BlogPost\' ';
		}
		String query = 	' select content__c contentId, content__r.site__c siteId, content__r.Primary_Author__c authorId, content__r.Type__c contentType ' +
						' from Analytics_Top_Content__c ' +
    					' where createddate = LAST_N_DAYS: 14 ' +
    					' And content__r.TYPE__c IN : soqlParam1 ' +
    					' And content__r.Is_Deleted__c = false ' +
    					' And ((Content__r.Site__r.Is_Active__c = true And Content__r.Site__r.Show_In_Simpplr__c = true And Content__r.Site__r.Site_Type__c=\'Public\') ' + blogSubCondition + ' ) ' +
    					' And Content__r.Is_Published__c = true ' +
						' And Content__r.Activated_By_Feature__c = true ' +
						' group by content__c, content__r.site__c, content__r.Primary_Author__c, content__r.Type__c ' +
						' order by sum(Popularity_Score__c) desc ' +
						' LIMIT 1 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggrList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	for(AggregateResult ar: aggrList) {
    		String contentId = (String)ar.get('contentId');
    		String contentType = (String)ar.get('contentType');
    		String siteId = (String)ar.get('siteId');
    		String authorId = (String)ar.get('authorId');
    		if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentType)){
	            popularContentUrl = '/site/'+siteId+'/page/' + contentId;                                          
	
	        } else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentType)){
	            popularContentUrl = '/people/'+authorId+'/blog/' + contentId;                                        
	
	        } else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentType)){
	            popularContentUrl = '/site/'+siteId+'/event/' + contentId;                                           
	
	        } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentType)){
	            popularContentUrl = '/site/'+siteId+'/album/' + contentId;                                           
	        }
    	}
    	return popularContentUrl;
	}
	
	public static Boolean unpublishContent(String contentId){
		DateTime toDate = null;
		DateTime currentDateTime = DateTime.now();
		List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{Simpplr_Content__c.Publish_Start_DateTime__c,Simpplr_Content__c.Last_Edited_DateTime__c};
		
		Simpplr_Content__c simContent = [SELECT Id, Publish_Start_DateTime__c, Publish_End_DateTime__c, 
										Last_Edited_DateTime__c, Type__c,
										(SELECT id FROM Must_Read_Audits__r WHERE Removed_DateTime__c = null 
											order by createddate desc limit 1) 
										FROM Simpplr_Content__c where Id=:contentId WITH SECURITY_ENFORCED];

		simContent.Publish_Start_DateTime__c = simContent.Publish_Start_DateTime__c.addYears(20);
		
		if(simContent.Publish_End_DateTime__c != NULL) {
			simContent.Publish_End_DateTime__c = simContent.Publish_End_DateTime__c.addYears(20);
			listOfColumnsToBeUpdated.add(Simpplr_Content__c.Publish_End_DateTime__c);
		}
		
		simContent.Last_Edited_DateTime__c = currentDateTime;
	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(simContent,listOfColumnsToBeUpdated);

		if(simContent.Must_Read_Audits__r.isEmpty() == false){
			Must_Read_Audit__c auditObj = new Must_Read_Audit__c();
			auditObj.id = simContent.Must_Read_Audits__r[0].id;
			auditObj.Removed_DateTime__c = currentDateTime;
			auditObj.Removed_By_People__c = UserContext.peopleId;
			auditObj.Removed_Reason__c = 'content_unpublished';

			listOfColumnsToBeUpdated = new List<Schema.SObjectField>{Must_Read_Audit__c.Removed_DateTime__c,
																	Must_Read_Audit__c.Removed_By_People__c,
																	Must_Read_Audit__c.Removed_Reason__c};
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(auditObj,listOfColumnsToBeUpdated);

			Map<String, Object> mapOfActivityParams = new Map<String, Object>();
			List<String> listOfContentIds = new List<String>();
			listOfContentIds.add(contentId);
			mapOfActivityParams.put('listOfContentIds',listOfContentIds);

			// fire batch to delete pending actionable notifications
			BatchResetMustRead job = new BatchResetMustRead('DeletePendingActionableNotifications',false,mapOfActivityParams);
			Database.executeBatch(job, 2000);

			// fire batch to send in-app and email notifications
		}

		if('Event'.equalsIgnoreCase(simContent.Type__c)) {
			BatchNotificationsOnContentUpdate batchObj = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contentId, 'eventUnpublished', true, true);
			Database.executeBatch(batchObj, 25); 
		}

		// remove validation-required notifications
		removeValidationRequiredNotifications(contentId);
		
		if(SimpplrContext.isInitiativesAndCampaignsEnabled){
			CIService.deleteCIItems('content', contentId);
		}

		return true;
	}
	
	public static Boolean publishContent(String contentId){
		try{
			// TO DO : Assuming that content can only be published when it is currently Unpublished and was previously published.
			if(!String.isBlank(contentId)){
				
				Simpplr_Content__c simContent = [SELECT Id, Type__c, Display_Order__c,Status__c,Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Edited_DateTime__c FROM Simpplr_Content__c WHERE Id =: contentId WITH SECURITY_ENFORCED LIMIT 1];
				simContent.Status__c = ServiceConstants.CONTENT_STATUS_APPROVED;
								
				DateTime currentTime = System.Now();
				if (simContent.Publish_End_DateTime__c != NULL){
					
					simContent.Publish_End_DateTime__c = DateTime.newInstance(currentTime.getTime() + 
														 (simContent.Publish_End_DateTime__c.getTime() - 
														  simContent.Publish_Start_DateTime__c.getTime()));
					
				}
				
				simContent.Publish_Start_DateTime__c = currentTime;
				simContent.Last_Validated_DateTime__c = null;
				if(simContent != null){
					if(('Page').equalsIgnoreCase(simContent.Type__c)){
						simContent.Display_Order__c = 1;
					}
				}
				
				simContent.Last_Edited_DateTime__c = DateTime.now();
				List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{Simpplr_Content__c.Publish_End_DateTime__c,
																								   Simpplr_Content__c.Publish_Start_DateTime__c,
																								   Simpplr_Content__c.Status__c,
																								   Simpplr_Content__c.Display_Order__c,
																								   Simpplr_Content__c.Last_Edited_DateTime__c,
																								   Simpplr_Content__c.Last_Validated_DateTime__c
																								  };
				
				//update simContent;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    		SIMPESAPI.accessController().updateAsUser(simContent,listOfColumnsToBeUpdated);
				return true; 
			}else{
				return false;
			}	
		}catch(Exception e){
			return false;
		}
	}
	
	public Boolean updateContentOnboardingStatus(String contentId, String onboardingStatus){
		List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{Simpplr_Content__c.Content_Onboarding_Status__c};
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		String action;
		Boolean isFeatured = false;
		Boolean isOnboardingContentExist = false;
		soqlParamMap.put('soqlParam1', contentId);
		String query = 'SELECT Id, Content_Onboarding_Status__c, Is_Published__c, Site__c, Site__r.Is_Onboarding_Enabled__c, Site__r.Is_Featured__c, Site__r.Site_Type__c, Last_Edited_DateTime__c FROM Simpplr_Content__c where Id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Content__c> simContentList = (List<Simpplr_Content__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		
		List<App_Config__c> appConfigList = [Select Id,Is_Onboarding_Content_Exist__c From App_Config__c WITH SECURITY_ENFORCED];
		
		logger.logDebug('ManageContentDao.updateContentOnboardingStatus()----Content_Onboarding_Status__c----'+simContentList[0].Content_Onboarding_Status__c);
		if(SimpplrContext.isSegmentsEnabled){
			String segmentId = String.isBlank(UserContext.SegmentId) ? '' : UserContext.SegmentId;
			if(String.isNotBlank(segmentId)) {
				List<Segment_Site__c> segList = [SELECT id, Is_Featured__c from Segment_Site__c where site__c =: simContentList[0].Site__c and segment__c =:segmentId WITH SECURITY_ENFORCED limit 1];
				isFeatured = segList.size()>0 ? segList[0].Is_Featured__c : false;
			} else {
				isFeatured = false;
			}
		} else {
			isFeatured = simContentList[0].Site__r.Is_Featured__c;
		}
		if(((simContentList[0].Content_Onboarding_Status__c)==null
		|| simContentList[0].Content_Onboarding_Status__c.equalsIgnoreCase(ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING))
		&& ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(onboardingStatus)){
			action='Org Onboarding Enabled';
			isOnboardingContentExist = true;
			if(appConfigList.size()>0 && !appConfigList[0].Is_Onboarding_Content_Exist__c){
				appConfigList[0].Is_Onboarding_Content_Exist__c = true;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            	SIMPESAPI.accessController().updateAsUser(appConfigList[0], new List<Schema.SObjectField>{App_Config__c.Is_Onboarding_Content_Exist__c});
			}
		
		} else if(((simContentList[0].Content_Onboarding_Status__c)==null
		|| simContentList[0].Content_Onboarding_Status__c.equalsIgnoreCase(ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING))
		&& ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(onboardingStatus)){
			action='Site Onboarding Enabled';
			isOnboardingContentExist = true;
			if(appConfigList.size()>0 && !appConfigList[0].Is_Onboarding_Content_Exist__c){
				appConfigList[0].Is_Onboarding_Content_Exist__c = true;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            	SIMPESAPI.accessController().updateAsUser(appConfigList[0], new List<Schema.SObjectField>{App_Config__c.Is_Onboarding_Content_Exist__c});
			}
		
		} else if(simContentList[0].Content_Onboarding_Status__c.equalsIgnoreCase(ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING)
		&& ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(onboardingStatus)){
			action='Updated To Org Onboarding';
			isOnboardingContentExist = true;
		
		} else if(simContentList[0].Content_Onboarding_Status__c.equalsIgnoreCase(ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING)
		&& ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(onboardingStatus)){
			action='Updated To Site Onboarding';
			isOnboardingContentExist = true;
		
		} else if(simContentList[0].Content_Onboarding_Status__c.equalsIgnoreCase(ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING)
		&& ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING.equalsIgnoreCase(onboardingStatus)){
			action='Site Onboarding Disabled';
		
		} else if(simContentList[0].Content_Onboarding_Status__c.equalsIgnoreCase(ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING)
		&& ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING.equalsIgnoreCase(onboardingStatus)){
			action='Org Onboarding Disabled';
		}
		logger.logDebug('ManageContentDao.updateContentOnboardingStatus()----action----'+action);

        Boolean isPublicSite = simContentList[0].Site__r.Site_Type__c == 'Public' ? true : false;

		if(ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING.equalsIgnoreCase(onboardingStatus) && isPublicSite && (Usercontext.isUserAppModerator || UserContext.getCurrentUserInfo.Enable_Org_Level_Onboarding__c)) {
			simContentList[0].Content_Onboarding_Status__c = ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING; 
			simContentList[0].Onboarding_Added_Date__c= Date.today();
			simContentList[0].Last_Edited_DateTime__c = DateTime.now();
			listOfColumnsToBeUpdated.add(Simpplr_Content__c.Onboarding_Added_Date__c);
			listOfColumnsToBeUpdated.add(Simpplr_Content__c.Last_Edited_DateTime__c);
			
		} else if (ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING.equalsIgnoreCase(onboardingStatus) && (AccessManager.calculateCanManageOnboarding(simContentList[0].Is_Published__c, simContentList[0].Site__c, simContentList[0].Site__r.Is_Onboarding_Enabled__c,isFeatured))) {
			simContentList[0].Content_Onboarding_Status__c = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING; 
			simContentList[0].Onboarding_Added_Date__c= Date.today();
			simContentList[0].Last_Edited_DateTime__c = DateTime.now();
			listOfColumnsToBeUpdated.add(Simpplr_Content__c.Onboarding_Added_Date__c);
			listOfColumnsToBeUpdated.add(Simpplr_Content__c.Last_Edited_DateTime__c);
		} else {
			simContentList[0].Content_Onboarding_Status__c = ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING;
			simContentList[0].Last_Edited_DateTime__c = DateTime.now();	
			listOfColumnsToBeUpdated.add(Simpplr_Content__c.Last_Edited_DateTime__c);
		}
	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(simContentList[0],listOfColumnsToBeUpdated);

		if('Org Onboarding Disabled'.equalsIgnoreCase(action) || 'Site Onboarding Disabled'.equalsIgnoreCase(action)){
			List<AggregateResult> onboardingObjList = [Select count(Id) ContentCount From Simpplr_Content__c Where (Content_Onboarding_Status__c = 'siteOnboarding' OR Content_Onboarding_Status__c = 'orgOnboarding') And Is_Deleted__c = false AND Is_Published__c = true AND Site__r.Is_Active__c = true WITH SECURITY_ENFORCED GROUP BY Content_Onboarding_Status__c LIMIT 1];
			if(onboardingObjList.size()>0){
				isOnboardingContentExist = true;
				if(appConfigList.size()>0 && !appConfigList[0].Is_Onboarding_Content_Exist__c){
					appConfigList[0].Is_Onboarding_Content_Exist__c = true;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            		SIMPESAPI.accessController().updateAsUser(appConfigList[0], new List<Schema.SObjectField>{App_Config__c.Is_Onboarding_Content_Exist__c});
				}
			} else{
				isOnboardingContentExist = false;
				if(appConfigList.size()>0 && appConfigList[0].Is_Onboarding_Content_Exist__c){
					appConfigList[0].Is_Onboarding_Content_Exist__c = false;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            		SIMPESAPI.accessController().updateAsUser(appConfigList[0], new List<Schema.SObjectField>{App_Config__c.Is_Onboarding_Content_Exist__c});
				}
			}
		}
		createContentAuditTrail(contentId, action, null);
		return isOnboardingContentExist;


	}
	public static Boolean createContent(String contentId){
		try{
			if(!String.isBlank(contentId)){
				
				Simpplr_Content__c simContent = [SELECT Id, Type__c, Display_Order__c,Status__c,
						Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Edited_DateTime__c, 
						(SELECT Id, Is_Deleted__c, Content_Document__c, Simpplr_content__r.Site__c, Repository__c,
						Simpplr_content__r.Site__r.Site_Type__c, Simpplr_content__r.Site__r.Chatter_Group_Id__c 
						FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false) 
						FROM Simpplr_Content__c WHERE Id =: contentId WITH SECURITY_ENFORCED LIMIT 1];
				simContent.Status__c = ServiceConstants.CONTENT_STATUS_APPROVED;
				simContent.Last_Edited_DateTime__c = DateTime.now();
				simContent.Publish_Start_DateTime__c = DateTime.now();
				if(simContent != null){
					if(('Page').equalsIgnoreCase(simContent.Type__c)){
						simContent.Display_Order__c = 1;
					}
				}
				List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{Simpplr_Content__c.Publish_End_DateTime__c,
																								   Simpplr_Content__c.Publish_Start_DateTime__c,
																								   Simpplr_Content__c.Status__c,
																								   Simpplr_Content__c.Last_Edited_DateTime__c,
																								   Simpplr_Content__c.Display_Order__c
																								  };
				
				// Create CDL for all files based on Content Status, isPublished and siteType
				List<File__c> listOfFileObj = simContent.File_Simpplr_Content__r;
				if(listOfFileObj.size() > 0 && !(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(simContent.Type__c))) {
					String groupId = listOfFileObj[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c;
					Boolean isPublicSite = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(listOfFileObj[0].Simpplr_content__r.Site__r.Site_Type__c);
					
					FileDao fileDaoObj = new FileDao();
					fileDaoObj.createContentDocumentLinks(ServiceConstants.CONTENT_STATUS_APPROVED, true, listOfFileObj, groupId, isPublicSite);
				}
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    		SIMPESAPI.accessController().updateAsUser(simContent,listOfColumnsToBeUpdated);
				return true; 
			}else{
				return false;
			}	
		}catch(Exception e){
			return false;
		}
	}
	
	public static String rateContent(String contentIdArg,Boolean isUsefulBoolArg,String commentArg){
		String insertedObjId = '';
		try{
			Content_Feedback__c contentFeedbackObj = new Content_Feedback__c();
			List<Schema.SObjectField> listOfColumnsToBeAdded = new List<Schema.SObjectField>{Content_Feedback__c.Comment__c,
																							Content_Feedback__c.Is_Deleted__c,
																							Content_Feedback__c.Simpplr_Content__c,
																							Content_Feedback__c.Submitter__c,
																							Content_Feedback__c.Was_Content_Useful__c};
			
			
			if (String.isNotBlank(contentIdArg) && isUsefulBoolArg != NULL){
				contentFeedbackObj.Simpplr_Content__c = contentIdArg;
				contentFeedbackObj.Comment__c = commentArg;
				contentFeedbackObj.Was_Content_Useful__c = isUsefulBoolArg;
				contentFeedbackObj.Submitter__c = UserContext.peopleId;
				contentFeedbackObj.Is_Deleted__c = false;
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    			sObject obj = SIMPESAPI.accessController().insertAsUser(contentFeedbackObj,listOfColumnsToBeAdded);
    			contentFeedbackObj = (Content_Feedback__c)obj;
    			insertedObjId = contentFeedbackObj.Id;
			} 
		}catch(Exception e){
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return insertedObjId;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static List<Content_Feedback__c> getRatings(String contentIdArg, Integer nextPageToken, Integer size, String peopleId, String order, String orderByField){
		try{
			
			List<String> fieldList = New List<String>{
            'Id',
            'Submitter__r.Full_Name__c', 
            'Submitter__r.User__r.Id',
            'Submitter__r.User__r.SmallPhotoUrl',
            'Comment__c',
            'Is_Deleted__c',
            'CreatedDate',
            'Simpplr_Content__c',
            'Submitter__c',
			'Was_Content_Useful__c'            
        	};
	        Map<String, Object> soqlParamMap = new Map<String, Object>();
	        String conditionString = '';
	        conditionString += ' Is_Deleted__c = false AND Was_Content_Useful__c = false';
	        
			if (String.isNotBlank(contentIdArg)){
				soqlParamMap.put('soqlParam1', contentIdArg);
	        	conditionString += ' AND Simpplr_Content__c =: soqlParam1 ';
	        }
	        if (String.isNotBlank(peopleId)){
				soqlParamMap.put('soqlParam2', peopleId);
	        	conditionString += ' AND Submitter__c =: soqlParam2 ';
	        }
	        conditionString = !conditionString.equals('')?' WHERE'+conditionString : '';
	        String subConditionString = '';
	        if(String.isBlank(order)){
				order = 'DESC';
	        }
	        if(String.isNotBlank(orderByField)){
				subConditionString+=' ORDER BY '+orderByField+' '+order;
	        } else {
				subConditionString+=' ORDER BY CreatedDate'+' '+order;
	        }
	        if(size != null && size > 0){
				soqlParamMap.put('soqlParam3', size);
				subConditionString+=' LIMIT :soqlParam3 ';
	        }
	        if(nextPageToken != null && nextPageToken >= 0){
				soqlParamMap.put('soqlParam4', nextPageToken);
	            subConditionString+=' OFFSET :soqlParam4';
	        }
	
	        String query = 'SELECT '+String.join(fieldList,',')+' FROM Content_Feedback__c'+conditionString+subConditionString;

	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        return (List<Content_Feedback__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
				
		}catch(Exception e){
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
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
	public static Boolean deleteRatings(String contentIdArg,String recordIdArg){
		Boolean success= false;
		try{
			Content_Feedback__c contentFeedbackObj = new Content_Feedback__c (id=recordIdArg);
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>();
			if (String.isNotBlank(recordIdArg)) {
				contentFeedbackObj.Is_Deleted__c = true;
				listOfColumnsToBeUpdated.add(Content_Feedback__c.Is_Deleted__c);
			} 
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(contentFeedbackObj,listOfColumnsToBeUpdated);
		}catch(Exception e){
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return success;
	}
	
	public void makeMustRead(InternalRequestWrapper.MustRead reqMustReadWrapObj) {
		DateTime currentTime = dateTime.now();
		String chatterGroupId;
		Simpplr_Content__c simpContentObj = [select id, Is_Published__c, Is_Deleted__c, Site__c, Site__r.Is_Must_Read_Enabled__c,
										Site__r.chatter_group_id__c, Site__r.Site_Type__c, 
										(select id from Must_Read_Audits__r where Is_Deleted__c = false And Removed_DateTime__c = null
												And (Expiry_DateTime__c = null or Expiry_DateTime__c >: currentTime))
										FROM Simpplr_Content__c 
										WHERE id=:reqMustReadWrapObj.contentId WITH SECURITY_ENFORCED limit 1];

		if (simpContentObj.Is_Deleted__c == true) {
			logger.logError('ManageContentDao.makeMustRead() => Content has already been deleted.');
			throw new SimpplrException(ServiceConstants.ERROR_404);
		
		} else if(simpContentObj.Is_Published__c == false) {
			logger.logError('ManageContentDao.makeMustRead() => Content has already been unpublished.');
			throw new SimpplrException(ServiceConstants.ERROR_404);
		
		} else if(simpContentObj.Must_Read_Audits__r.isEmpty() == false) {
			logger.logError('ManageContentDao.makeMustRead() => Content has already been marked must read.');
			throw new SimpplrException(ServiceConstants.ERROR_403);

		} else if('everyone'.equalsIgnoreCase(reqMustReadWrapObj.audience)) {
			if(UserContext.isUserAppModerator == false) {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}
		} else if('site_members'.equalsIgnoreCase(reqMustReadWrapObj.audience) || 'site_members_and_followers'.equalsIgnoreCase(reqMustReadWrapObj.audience)) {
			chatterGroupId = simpContentObj.Site__r.chatter_group_id__c;
			if(UserContext.sitesIManageIdSet.contains(simpContentObj.Site__c) || UserContext.sitesIManageContentsIdSet.contains(simpContentObj.Site__c)) {
				
			} else if(UserContext.isUserAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(simpContentObj.Site__r.Site_Type__c)) {
				
			} else {
				logger.logError('ManageContentDao.makeMustRead() => User doesns\'t has permission.');
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}
		}
		Must_Read_Audit__c  mustReadAuditObj = new Must_Read_Audit__c();
		mustReadAuditObj.Audience_Type__c = reqMustReadWrapObj.audience;
		mustReadAuditObj.Mark_Datetime__c = System.Now();
		mustReadAuditObj.Marked_By_People__c = UserContext.peopleId;
		mustReadAuditObj.Message__c = reqMustReadWrapObj.message;
		mustReadAuditObj.Content__c = reqMustReadWrapObj.contentId;
		mustReadAuditObj.Duration__c = reqMustReadWrapObj.duration;
		if('ninety_days'.equalsIgnoreCase(reqMustReadWrapObj.duration)) {
			mustReadAuditObj.Expiry_DateTime__c = mustReadAuditObj.Mark_Datetime__c.date().addDays(90);
		}
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		mustReadAuditObj = (Must_Read_Audit__c)SIMPESAPI.accessController().insertAsUser(mustReadAuditObj, new List<Schema.SObjectField>{
				Must_Read_Audit__c.Audience_Type__c,
				Must_Read_Audit__c.Mark_Datetime__c,
				Must_Read_Audit__c.Marked_By_People__c,
				Must_Read_Audit__c.Message__c,
				Must_Read_Audit__c.Content__c,
				Must_Read_Audit__c.Duration__c,
				Must_Read_Audit__c.Expiry_DateTime__c
				});

		createExternalSearchDataTrailRecordForMustRead(mustReadAuditObj.Id);

		String activity = 'everyone'.equalsIgnoreCase(reqMustReadWrapObj.audience) ? 'sendNewMustReadToEveryone' : 
						  'site_members'.equalsIgnoreCase(reqMustReadWrapObj.audience) ? 'sendNewMustReadToSiteMembers' :'sendNewMustReadToSiteMembersAndFollowers';
		BatchMustReadNotifications mustReadBatch = new BatchMustReadNotifications(reqMustReadWrapObj.contentId, 
				activity, chatterGroupId);
		Database.executeBatch(mustReadBatch, 25);
	}
	

	private void createExternalSearchDataTrailRecordForMustRead(String mustReadId) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
		obj.Must_Read_Audit__c = mustReadId;
		obj.Type__c = 'Must_Read';
		SIMPESAPI.accessController().insertAsUser(obj, new List<Schema.SObjectField>{
			External_Search_Data_Trail__c.Must_Read_Audit__c,External_Search_Data_Trail__c.Type__c});
	}
    
	public void removeMustRead(String contentId){
		List<Must_Read_Audit__c> mustReadAuditList = [select id from Must_Read_Audit__c 
													   where content__c=:contentId
													   And Is_Deleted__c = false 
													   And Removed_DateTime__c = null WITH SECURITY_ENFORCED];

		if(!mustReadAuditList.isEmpty()) {
			for(Must_Read_Audit__c mustReadAudit : mustReadAuditList) {
				mustReadAudit.Removed_DateTime__c = DateTime.now();
				mustReadAudit.Removed_By_People__c = UserContext.peopleId;	
				mustReadAudit.Removed_Reason__c = 'manually_removed';
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Must_Read_Audit__c>(mustReadAuditList), new List<Schema.SObjectField>{
											Must_Read_Audit__c.Removed_DateTime__c,
											Must_Read_Audit__c.Removed_By_People__c,
											Must_Read_Audit__c.Removed_Reason__c
											});
			
			Map<String, Object> mapOfActivityParams = new Map<String, Object>();
			List<String> listOfContentIds = new List<String>();
			listOfContentIds.add(contentId);
			mapOfActivityParams.put('listOfContentIds',listOfContentIds);
			BatchResetMustRead job = new BatchResetMustRead('DeletePendingActionableNotifications',false,mapOfActivityParams);
			Database.executeBatch(job,2000);
		}
	}
	
	public static Boolean resetMustRead(String contentId){
		Boolean success= false;
		Map<String, Object> mapOfActivityParams = new Map<String, Object>();
		List<String> listOfContentIds = new List<String>();
  		try{
			if(String.isNotBlank(contentId)){
				Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
				DateTime currentDateTime = DateTime.now();
				List<Simpplr_Content__c> simpplrContentObjList = [SELECT Id FROM Simpplr_Content__c WHERE ID =: contentId AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null AND ( Audience_Type__c='everyone' OR Content__r.Site__c=:sitesIFollowIdSet))  
															AND Is_Deleted__c = false WITH SECURITY_ENFORCED limit 1];
				if(simpplrContentObjList.isEmpty() == false){
					success = true;
					listOfContentIds.add(contentId);
					mapOfActivityParams.put('listOfContentIds',listOfContentIds);
		        	
					BatchResetMustRead job = new BatchResetMustRead('DeleteMustReadDetails',true,mapOfActivityParams);
					Database.executeBatch(job,2000);
				}
			} else {
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}
		}catch(Exception e){
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return success;
	}

	public void sendMustReadReminderMail(String contentId){
		Map<String, Object> mapOfActivityParams = new Map<String, Object>();
		DateTime currentDateTime = DateTime.now();
		List<Must_Read_Audit__c> mRAList = [SELECT Id, Audience_Type__c, Content__c, Content__r.Site__r.Chatter_Group_Id__c 
															FROM Must_Read_Audit__c 
															WHERE Removed_DateTime__c = null 
																AND content__r.Id = :contentId 
																AND content__r.Is_Published__c = true
																AND Content__r.Is_Deleted__c = false WITH SECURITY_ENFORCED];
		if(mRAList.isEmpty() == false){
			String chatterGroupId = null;
			if(!'everyone'.equalsIgnoreCase(mRAList[0].Audience_Type__c)) {
				chatterGroupId = mRAList[0].Content__r.Site__r.Chatter_Group_Id__c;
			}

			String activity = 'site_members'.equalsIgnoreCase(mRAList[0].Audience_Type__c) ? 'mustReadsReminderEmailForSingleContentToSiteMembers' :'mustReadsReminderEmailForSingleContent';
			BatchMustReadNotifications job = new BatchMustReadNotifications(contentId, activity, chatterGroupId);

			Database.executeBatch(job,25);

		} else {
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		
	}

	public static Boolean markAsRead(String contentId){
		Boolean success= false;
		Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
		DateTime currentDateTime = DateTime.now();
		List<Must_Read_Audit__c>  mrAuditList = [SELECT Id,Content__c FROM Must_Read_Audit__c 
												 WHERE Removed_DateTime__c = null  
												 AND Content__c=:contentId
												 AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) 
												 AND  ( Audience_Type__c='everyone' OR Content__r.Site__c=:sitesIFollowIdSet) 
												 WITH SECURITY_ENFORCED ORDER BY createddate desc limit 1];
		if(mrAuditList.isEmpty() == false){
			Id peopleId = UserContext.peopleId;
			List<Must_Read_Confirm_History__c> listOfRecords= [Select Id, Content__c, People__c From Must_Read_Confirm_History__c Where Content__c =:contentId AND
							People__c =:peopleId and Must_Read_Audit__c=:mrAuditList[0].Id WITH SECURITY_ENFORCED];
			
			if(listOfRecords.isEmpty() == false){
				success = true;
				
			} else {
				Must_Read_Confirm_History__c mustReadObj = new Must_Read_Confirm_History__c();
				mustReadObj.People__c = peopleId;
				mustReadObj.Content__c = contentId;
				mustReadObj.Must_Read_Audit__c = mrAuditList[0].Id;
				mustReadObj.Confirm_DateTime__c = DateTime.now();
				List<Schema.SObjectField> listOfColumnsToBeAdded = new List<Schema.SObjectField>{Must_Read_Confirm_History__c.People__c,
																							Must_Read_Confirm_History__c.Must_Read_Audit__c,
																							Must_Read_Confirm_History__c.Confirm_DateTime__c,
																							Must_Read_Confirm_History__c.Content__c};
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				mustReadObj = (Must_Read_Confirm_History__c)SIMPESAPI.accessController().insertAsUser(mustReadObj,listOfColumnsToBeAdded);
				success = true;

				createExternalSearchDataTrailRecordForMustReadConfirmHistory(mustReadObj.id);
			}
			List<App_Notification__c> mustReadNotificationList = [select id from App_Notification__c where sent_to__c=:peopleId and object_id__c=:contentId and sub_Type__c='Must Read' and is_read__c=false AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
			if(mustReadNotificationList.isEMpty() == false) {
				for(App_Notification__c notiObj : mustReadNotificationList){
					notiObj.Action_By__c = peopleId;
					notiObj.Action_On__c = DateTime.now();
					notiObj.Is_Read__c = true;
					notiObj.Is_New__c = false;
				}
				
				List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
					App_Notification__c.Action_By__c,
					App_Notification__c.Action_On__c,
					App_Notification__c.Is_Read__c,
					App_Notification__c.Is_New__c
				};

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(mustReadNotificationList), listOfColumnsToBeUpdated);
			}
		}else {
			throw new SimpplrException('This content is no longer a Must Read !!');
		}
		return success;
	}

	private static void createExternalSearchDataTrailRecordForMustReadConfirmHistory(String mustReadConfirmHistoryId) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
		obj.Must_Read_Confirm_History__c = mustReadConfirmHistoryId;
		obj.Type__c = 'Must_Read_Confirm_History';
		SIMPESAPI.accessController().insertAsUser(obj, new List<Schema.SObjectField>{
			External_Search_Data_Trail__c.Must_Read_Confirm_History__c,External_Search_Data_Trail__c.Type__c});
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static List<Content_Feedback__c> getContentFeedbackList(String contentIdArg,String peopleIdArg){
		List<Content_Feedback__c> contentFeedbackList = new List<Content_Feedback__c> ();
		try{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentIdArg);
			soqlParamMap.put('soqlParam2', peopleIdArg);
			String feedbackQuery = 'SELECT Id,Comment__c,Is_Deleted__c,Simpplr_Content__c, ' +
				' Submitter__c,Was_Content_Useful__c  ' +
				' FROM Content_Feedback__c  ' +
				' WHERE Simpplr_Content__c =: soqlParam1 ' +
				' AND Submitter__c =: soqlParam2 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			contentFeedbackList = (List<Content_Feedback__c>)SIMPESAPI.accessController().queryAsUser(feedbackQuery, soqlParamMap);
		}catch(Exception e){
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return contentFeedbackList;
	}
	
	@future
	public static void updateEditDateForSiteContents(List<String> contentDocumentIdsList) {
		FileDao fileDaoObj = new FileDao();
		
		Set<Id> simContIdsSet = getSimpplrContentIdsWithAttachments(contentDocumentIdsList);
		List<Simpplr_Content__c> simContList = new List<Simpplr_Content__c>();
		
		for(Id simContentObjId : simContIdsSet) {
			Simpplr_Content__c conObj = new Simpplr_Content__c();
			conObj.Id = simContentObjId;
			conObj.Last_Edited_DateTime__c = DateTime.now();
			simContList.add(conObj);
		}
		
		if(!simContList.isEmpty() && simContList.size()>0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(simContList), 
														new List<Schema.SObjectField>{
																							Simpplr_Content__c.Last_Edited_DateTime__c
																					 });
		}
	}
	
	private static Set<Id> getSimpplrContentIdsWithAttachments(List<String> ContentDocumentId) {
		Set<Id> simContIdsSet = new Set<Id>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', ContentDocumentId);
		String filesQuery = 'select Id, Simpplr_Content__c FROM File__c '+
																		' WHERE Content_Document__c = :soqlParam1 '+
																		' AND Is_Deleted__c = false AND Location__c = \'attachment\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> filesList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		
		for(File__c fileObj : filesList) {
			simContIdsSet.add(fileObj.Simpplr_Content__c);
		}
		
		return simContIdsSet;
	}
	 
	 
	public SlackDataServer.ResponseStructure getSlackUnfurlInfoForContent(String contentId) { 
		SlackDataServer.ResponseStructure response = new SlackDataServer.ResponseStructure();
		ContentWrapper contentInfoWrapper = new ContentWrapper();
		List<Simpplr_Content__c> contentInfo = [SELECT Id, Title__c, Type__c, Display_Excerpt__c, Primary_Author__c, Primary_Author__r.Full_Name__c, Site__c, Site__r.Name, Site__r.Landing_Page__c, 
												Event_Start_DateTime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c, Event_Location__c, Event_Is_All_Day__c,Event_Map_URL__c, 
												(SELECT Id,Content_Version__c,Content_Document__c,Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r WHERE Is_Title_Image__c = true And Is_Deleted__c = false) 
												FROM Simpplr_Content__c WHERE Id = :contentId AND TYPE__c IN :allowedFeaturesInAppList AND Activated_By_Feature__c = true AND Is_Published__c = true AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
		if(!contentInfo.isEmpty()){
			contentInfoWrapper.contentId = contentInfo[0].Id;
			
			List<File__c> titleFilesList = contentInfo[0].File_Simpplr_Content__r;
			if(!titleFilesList.isEmpty()){
				if(String.isBlank(titleFilesList[0].Content_Version__c) && String.isNotBlank(titleFilesList[0].Thumbnail_URL__c)){ //video
					contentInfoWrapper.img = titleFilesList[0].Thumbnail_URL__c; 
					
				} else if(String.isNotBlank(titleFilesList[0].Content_Version__c)){ //image
					Map<Id, String> cvIdNPublicUrlMap = generateEmbedPublicUrl(new List<Id>{titleFilesList[0].Content_Version__c});
					contentInfoWrapper.img = cvIdNPublicUrlMap.get(titleFilesList[0].Content_Version__c);						
				}
			}
			
			contentInfoWrapper.title = String.isNotBlank(contentInfo[0].Title__c) ? contentInfo[0].Title__c : '';
			contentInfoWrapper.summary = String.isNotBlank(contentInfo[0].Display_Excerpt__c) ? contentInfo[0].Display_Excerpt__c.unescapeHtml4() : '';
			
			contentInfoWrapper.authoredBy = new PeopleListWrapper();	
			contentInfoWrapper.authoredBy.peopleId = contentInfo[0].Primary_Author__c;
			contentInfoWrapper.authoredBy.name = contentInfo[0].Primary_Author__r.Full_Name__c;
			contentInfoWrapper.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentInfo[0].Primary_Author__c;
				
			if(String.isNotBlank(contentInfo[0].Site__c)){
				contentInfoWrapper.site = new SiteLiteWrapper();	
				contentInfoWrapper.site.siteId = contentInfo[0].Site__c;
				contentInfoWrapper.site.name = contentInfo[0].Site__r.Name;
				contentInfoWrapper.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + contentInfo[0].Site__c + '/' + contentInfo[0].Site__r.Landing_Page__c;
			}

	        if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentInfo[0].Type__c)){
	            contentInfoWrapper.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentInfo[0].Site__c+'/page/'+contentInfo[0].Id;
	            if(String.isBlank(contentInfoWrapper.img)){
	            	contentInfoWrapper.img = pagePlaceholderImage;
	            }                                          
	
	        } else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentInfo[0].Type__c)){
	            contentInfoWrapper.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+contentInfo[0].Primary_Author__c+'/blog/'+contentInfo[0].Id;
	            if(String.isBlank(contentInfoWrapper.img)){
	            	contentInfoWrapper.img = blogPlaceholderImage;
	            }                                           
	
	        } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentInfo[0].Type__c)){
	            contentInfoWrapper.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentInfo[0].Site__c+'/album/'+contentInfo[0].Id;
	            if(String.isBlank(contentInfoWrapper.img)){
	            	contentInfoWrapper.img = albumPlaceholderImage;
	            }                                           
	        
	        } else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentInfo[0].Type__c)){
				TimeZone tz = Timezone.getTimeZone(contentInfo[0].Event_TimezoneSidKey__c);
				contentInfoWrapper.timezoneName = Utility.timezoneIdToDisplayLabel(contentInfo[0].Event_TimezoneSidKey__c);
				contentInfoWrapper.timezoneIso = tz.getID();
				contentInfoWrapper.timezoneOffset = tz.getOffset(system.today());

				contentInfoWrapper.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentInfo[0].Site__c+'/event/'+contentInfo[0].Id;
				contentInfoWrapper.startsAt = String.valueOf(contentInfo[0].Event_Start_DateTime__c);
				contentInfoWrapper.endsAt = String.valueOf(contentInfo[0].Event_End_DateTime__c);
			    
			    if (contentInfo[0].Event_Start_DateTime__c.isSameDay(contentInfo[0].Event_End_DateTime__c)) {
			    	contentInfoWrapper.isMultiDay = false;
			    
			    } else {
			    	contentInfoWrapper.isMultiDay = true;
			    }	
			    contentInfoWrapper.isAllDay = contentInfo[0].Event_Is_All_Day__c;			
				contentInfoWrapper.location = String.isNotBlank(contentInfo[0].Event_Location__c) ? contentInfo[0].Event_Location__c : '';		
	            contentInfoWrapper.googleCalendarWebUrl = String.isNotBlank(contentInfo[0].Event_Map_URL__c) ? contentInfo[0].Event_Map_URL__c : '';
	            
	            if(String.isBlank(contentInfoWrapper.img)){
	            	contentInfoWrapper.img = eventPlaceholderImage;
	            }  
			}
			
			response.type = contentInfo[0].Type__c;
			response.contentDetail = contentInfoWrapper;
		} else {
				throw new SimpplrException('Cannot find content with Id '+ contentId);
		}
		
		
		return response;
	}
	  

	public SlackDataServer.ResponseStructure getSlackUnfurlInfoForAlbumMedia(String fileId) {
		SlackDataServer.ResponseStructure response = new SlackDataServer.ResponseStructure();
		FileListingWrapper fileInfoWrapper = new FileListingWrapper();
		ContentWrapper contentInfoWrapper = new ContentWrapper();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileId);
		soqlParamMap.put('soqlParam2', allowedFeaturesInAppList);
		String filesQuery = 'SELECT Id, Description__c, Author__c, Author__r.Full_Name__c, Content_Version__c, Thumbnail_URL__c,'+
										' Simpplr_Content__c, Simpplr_Content__r.Title__c, Simpplr_Content__r.Type__c, Simpplr_Content__r.Display_Excerpt__c, Simpplr_Content__r.Primary_Author__c, Simpplr_Content__r.Primary_Author__r.Full_Name__c, '+
										' Simpplr_Content__r.Site__c, Simpplr_Content__r.Site__r.Name, Simpplr_Content__r.Site__r.Landing_Page__c'+
										' FROM File__c WHERE Id=:soqlParam1 And Simpplr_Content__r.TYPE__c IN :soqlParam2 AND Simpplr_Content__r.Activated_By_Feature__c = true AND Simpplr_Content__r.Is_Published__c = true AND Simpplr_Content__r.Is_Deleted__c = false ';				
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> albumFileInfo = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		if(!albumFileInfo.isEmpty()){
			contentInfoWrapper.contentId = albumFileInfo[0].Simpplr_Content__r.Id;
			contentInfoWrapper.title = String.isNotBlank(albumFileInfo[0].Simpplr_Content__r.Title__c) ? albumFileInfo[0].Simpplr_Content__r.Title__c : '';
			contentInfoWrapper.summary = String.isNotBlank(albumFileInfo[0].Simpplr_Content__r.Display_Excerpt__c) ? albumFileInfo[0].Simpplr_Content__r.Display_Excerpt__c.unescapeHtml4(): '';
			
			contentInfoWrapper.authoredBy = new PeopleListWrapper();	
			contentInfoWrapper.authoredBy.peopleId = albumFileInfo[0].Simpplr_Content__r.Primary_Author__c; 
			contentInfoWrapper.authoredBy.name = albumFileInfo[0].Simpplr_Content__r.Primary_Author__r.Full_Name__c;
			contentInfoWrapper.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + albumFileInfo[0].Simpplr_Content__r.Primary_Author__c;
				
			if(String.isNotBlank(albumFileInfo[0].Simpplr_Content__r.Site__c)){
				contentInfoWrapper.site = new SiteLiteWrapper();	
				contentInfoWrapper.site.siteId = albumFileInfo[0].Simpplr_Content__r.Site__c;
				contentInfoWrapper.site.name = albumFileInfo[0].Simpplr_Content__r.Site__r.Name;
				contentInfoWrapper.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + albumFileInfo[0].Simpplr_Content__r.Site__c + '/' + albumFileInfo[0].Simpplr_Content__r.Site__r.Landing_Page__c;
			}
			
            contentInfoWrapper.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+albumFileInfo[0].Simpplr_Content__r.Site__c+'/album/'+albumFileInfo[0].Simpplr_Content__r.Id;                                          
	        
			fileInfoWrapper.fileId = albumFileInfo[0].Id;
			fileInfoWrapper.url = contentInfoWrapper.url + '/gallery/' + albumFileInfo[0].Id;
			if(String.isBlank(albumFileInfo[0].Content_Version__c) && String.isNotBlank(albumFileInfo[0].Thumbnail_URL__c)){ //video
				fileInfoWrapper.img = albumFileInfo[0].Thumbnail_URL__c;
				
			} else if(String.isNotBlank(albumFileInfo[0].Content_Version__c)){ //image
				Map<Id, String> cvIdNPublicUrlMap = generateEmbedPublicUrl(new List<Id>{albumFileInfo[0].Content_Version__c});
				fileInfoWrapper.img = cvIdNPublicUrlMap.get(albumFileInfo[0].Content_Version__c);						
			}
			if(String.isBlank(fileInfoWrapper.img)){
				fileInfoWrapper.img = filePlaceholderImage;
			}	
			fileInfoWrapper.description = String.isNotBlank(albumFileInfo[0].Description__c) ? albumFileInfo[0].Description__c : '';		

			fileInfoWrapper.authoredBy = new PeopleLiteWrapper();	
			fileInfoWrapper.authoredBy.peopleId = albumFileInfo[0].Author__c;
			fileInfoWrapper.authoredBy.name = albumFileInfo[0].Author__r.Full_Name__c;
			fileInfoWrapper.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + albumFileInfo[0].Author__c;				
			
			response.type = 'Media';	
			response.contentDetail = contentInfoWrapper;
			response.fileDetail = fileInfoWrapper;	
		} else {
				throw new SimpplrException('Cannot find media with Id '+ fileId);
		}
		
		
		return response;
	}
	
    public Map<Id, String> generateEmbedPublicUrl(List<Id> cvIdsList) {
    	Map<Id, String> mapOfPublicURLs = FileContentProvider.generatePublicUrl(cvIdsList);
    	Map<Id, String> mapOfEmbedPublicURLs = new Map<Id, String>();
    	for(Id key:mapOfPublicURLs.keySet()) {
    		if(String.isNotBlank(mapOfPublicURLs.get(key))) {
    			mapOfEmbedPublicURLs.put(key, converDistributionPublicUrlToImageURL(key, mapOfPublicURLs.get(key)));
    		}
    	}
    	return mapOfEmbedPublicURLs;
    } 
    
    public String converDistributionPublicUrlToImageURL(String contentVersionId, String distributionPublicUrl) {
    	String urlPart = distributionPublicUrl.substringAfter(UserInfo.getOrganizationId().mid(3,12));
    	String publicURL = SimpplrContext.salesforceHost + '/sfc/dist/version/renditionDownload?versionId=' + contentVersionId + '&d=' + urlPart + '&oid=' + UserInfo.getOrganizationId() + '&rendition=THUMB720BY480';
    	return publicURL;
    }

	public Map<String,Integer> getContentIdToAudienceCountMap(List<Simpplr_Content__c> contentObjList){
		Map<String,Integer> contentIdToAudienceCountMap = new Map<String,Integer>();
		Set<String> siteIdsSet = new Set<String>();
		List<Must_Read_Audit__c> mrAuditList = new List<Must_Read_Audit__c>();
		Integer applicationAudienceCount = 0;
		String packageName = SimpplrContext.packageName;
		String queryStr = 'SELECT  count() FROM People__c';
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' Where (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}

		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){ 
			 queryStr = queryStr + ' and user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}

		applicationAudienceCount =  Database.countQuery(queryStr);
		Map<String,Integer> cgGroupIdToMemberCountMap = new Map<String,Integer>();
		for(Simpplr_Content__c contentObj : contentObjList){
			mrAuditList = contentObj.Must_Read_Audits__r;
			if(mrAuditList.isEmpty() == false){
				if('everyone'.equals(mrAuditList[0].Audience_Type__c) == false){
					siteIdsSet.add(contentObj.Site__c);
				 } else {
					contentIdToAudienceCountMap.put(contentObj.Id, applicationAudienceCount);
				}
			}
		}

		if(siteIdsSet.isEmpty() == false){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteIdsSet);
			soqlParamMap.put('soqlParam2', SimpplrContext.packageName);

			String query = 'SELECT Site__c siteId, COUNT(People__c) memberCount FROM Site_Role__c WHERE Site__c IN :soqlParam1 '+
			' AND is_deleted__c = false AND ( User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' '+
			' AND User__r.isActive=true AND User__r.UserType=\'Standard\'';
			
			if(Utility.isApiOnlyUserQueryable()) {
				query += ' AND User__r.Profile.PermissionsApiUserOnly = false ';
			}
			query += ' ))';

			if(String.isNotBlank(SimpplrContext.packageName)){
				query += ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix = :soqlParam2) ';
			}

			query += ' GROUP BY Site__c';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<AggregateResult> aggrList  = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
			for(AggregateResult agResult : aggrList){
				cgGroupIdToMemberCountMap.put((String)agResult.get('siteId'), (Integer)agResult.get('memberCount'));
			}

			for(Simpplr_Content__c contentObj : contentObjList){
				if(!contentIdToAudienceCountMap.containskey(contentObj.Id) && siteIdsSet.contains(contentObj.Site__c)){
					contentIdToAudienceCountMap.put(contentObj.Id,cgGroupIdToMemberCountMap.get(contentObj.Site__c));
				}
			}
		}
		return contentIdToAudienceCountMap;
	} 

    public void  createContentAuditTrail(String contentIdArg, String actionArg, 
            String rejectionComment) {
		List<ManageContentDao.ContentAuditTrailWrapper> listOfContentTrailWrap = new List<ManageContentDao.ContentAuditTrailWrapper>();
		ManageContentDao.ContentAuditTrailWrapper  contAudTrailWrapObj = new ManageContentDao.ContentAuditTrailWrapper();
		contAudTrailWrapObj.contentId = contentIdArg;
		contAudTrailWrapObj.action = actionArg;
        
        if (rejectionComment != null) {
            contAudTrailWrapObj.message = rejectionComment;
        }
        
		listOfContentTrailWrap.add(contAudTrailWrapObj);
		insertContentAuditTrail(listOfContentTrailWrap);
	}

	public void  insertContentAuditTrail (List<ContentAuditTrailWrapper> listOfContentTrailWrap) {
		List<Content_Audit_Trail__c> listOfContentAuditForInsert = new List<Content_Audit_Trail__c>();

		for (ContentAuditTrailWrapper contAuditTrailWrap: listOfContentTrailWrap) {
			Content_Audit_Trail__c contAudTrailObj = new Content_Audit_Trail__c();
			contAudTrailObj.Old_Site__c = contAuditTrailWrap.oldSite;
			contAudTrailObj.New_Site__c = contAuditTrailWrap.newSite;
			contAudTrailObj.Old_Author__c = contAuditTrailWrap.oldAuthor;
			contAudTrailObj.New_Author__c = contAuditTrailWrap.newAuthor;
			contAudTrailObj.Content__c =  contAuditTrailWrap.contentId; 
			contAudTrailObj.Action_By__c = UserContext.peopleId;
			contAudTrailObj.Action_DateTime__c = system.now();
			contAudTrailObj.Action__c = contAuditTrailWrap.action;
            contAudTrailObj.Comment__c = contAuditTrailWrap.message;
			listOfContentAuditForInsert.add(contAudTrailObj);
		}

		if( !listOfContentAuditForInsert.isEmpty() ) {
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
			fieldList.add(Content_Audit_Trail__c.Old_Site__c);
			fieldList.add(Content_Audit_Trail__c.New_Site__c);
			fieldList.add(Content_Audit_Trail__c.Old_Author__c);
			fieldList.add(Content_Audit_Trail__c.New_Author__c);
			fieldList.add(Content_Audit_Trail__c.Content__c);
			fieldList.add(Content_Audit_Trail__c.Action_By__c);
			fieldList.add(Content_Audit_Trail__c.Action_DateTime__c);
			fieldList.add(Content_Audit_Trail__c.Action__c);
			fieldList.add(Content_Audit_Trail__c.Comment__c);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfContentAuditForInsert, fieldList);
		}
	}

	public Set<String> getValidationExpiredLast14DaysContentIdSet(){
		Set<String> contentIdSet = new Set<String>();

		String loggedInUserId = UserContext.getCurrentUserInfo.Id;
		Set<Id> sitesIManageSet = UserContext.sitesIManageIdSet;
		Set<Id> sitesIManageContentsSet = UserContext.sitesIManageContentsIdSet;
		List<Content_Audit_Trail__c> auditTrailList = null;
		
		if(UserContext.isUserAppModerator){
			auditTrailList = [SELECT content__c FROM Content_Audit_Trail__c WHERE
						Content__r.Type__c = 'Page' AND Content__r.Content_Sub_Type__c = 'knowledge' AND 
						Action__c = 'Validation Expired' AND
						Dismiss_By__c =null AND
						Content__r.Is_Unpublished__c = true AND Content__r.Is_Deleted__c = false AND
						Action_DateTime__c = LAST_N_DAYS: 14 AND
						(Content__r.Site__c IN :sitesIManageSet OR Content__r.Site__c IN :sitesIManageContentsSet OR Content__r.Site__r.Site_Type__c = 'Public') WITH SECURITY_ENFORCED
					];
		} else {
			auditTrailList = [SELECT content__c FROM Content_Audit_Trail__c WHERE
						Content__r.Type__c = 'Page' AND Content__r.Content_Sub_Type__c = 'knowledge' AND 
						Action__c = 'Validation Expired' AND
						Dismiss_By__c =null AND
						Content__r.Is_Unpublished__c = true AND Content__r.Is_Deleted__c = false AND
						Action_DateTime__c = LAST_N_DAYS: 14 AND
						(Content__r.Site__c IN :sitesIManageSet OR Content__r.Site__c IN :sitesIManageContentsSet) WITH SECURITY_ENFORCED
					];
		}			

		for(Content_Audit_Trail__c contentAuditTrailObj : auditTrailList){
			contentIdSet.add(contentAuditTrailObj.content__c);
		}

		return contentIdSet;
	}

	public void dismissValidation(String contentId, String type) {
		List<Simpplr_Content__c> contentList = [SELECT id FROM Simpplr_Content__c 
													WHERE Is_Deleted__c = false
													AND Status__c = 'Approved'
													AND type__c = 'Page'
													AND Content_Sub_Type__c = 'knowledge'
													AND Id =: contentId WITH SECURITY_ENFORCED];

		if(!contentList.isEmpty()){
			Content_Audit_Trail__c contAudTrailObj = new Content_Audit_Trail__c();
			contAudTrailObj.Content__c = contentList[0].id;
			contAudTrailObj.Dismiss_By__c = UserContext.peopleId;

			if('required'.equalsIgnoreCase(type)){
				contAudTrailObj.action__c = 'Validation Require Dismissed';
				contAudTrailObj.action_DateTime__c = DateTime.now();
				contAudTrailObj.Action_By__c = UserContext.peopleId;
				contAudTrailObj.Dismiss_By__c = UserContext.peopleId;
				insert contAudTrailObj;
				
			} else if('expired'.equalsIgnoreCase(type)){
				List<Content_Audit_Trail__c> auditTrailList = [SELECT id from Content_Audit_Trail__c
															   WHERE content__c=: contentList[0].id 
															   AND Action_DateTime__c = LAST_N_DAYS: 14
															   AND ACTION__c='Validation Expired' WITH SECURITY_ENFORCED];
				contAudTrailObj.id = auditTrailList[0].id;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(contAudTrailObj,
					new List<Schema.SObjectField>{
						Content_Audit_Trail__c.Content__c,
						Content_Audit_Trail__c.Dismiss_By__c
					});

			}
			
			// remove validation-required notifications
			removeValidationRequiredNotifications(contentList[0].id);
		}
	}

	public void restoreVersion(String contentId, String versionIdStr){
		Decimal versionId = Decimal.valueOf(versionIdStr);
		List<Content_History__c> contentHistoryList = [SELECT Id, Content__c, Content__r.Type__c, Collaborator_Json__c, Content_Json_Part1__c,
														Content_Json_Part2__c, Content_Json_Part3__c, Content_Json_Part4__c,
														Content_Json_Part5__c, File_Json__c, File_Json_Part1__c, File_Json_Part2__c,
														File_Json_Part3__c, Topic_Json__c, Version__c FROM Content_History__c
														WHERE Content__c = :contentId AND Version__c = :versionId AND IsDeleted = false WITH SECURITY_ENFORCED];

		if(!contentHistoryList.isEmpty() && contentHistoryList.size() > 0
				 && !'BlogPost'.equalsIgnoreCase(contentHistoryList[0].Content__r.Type__c)){

			String contentJsonStr = mergeContentHistoryJsonStrings(contentHistoryList[0], 'content');
			String unescapedContentJsonStr = contentJsonStr.unescapeUnicode();
			Simpplr_Content__c historySimpplrContentObj;
			Map<String, Object> simpplrContentMap;
			try{
				historySimpplrContentObj = (Simpplr_Content__c) JSON.deserialize(unescapedContentJsonStr, Type.forName('Simpplr_Content__c'));
				simpplrContentMap = (Map<String, Object>) JSON.deserializeUntyped(unescapedContentJsonStr);
			}catch(Exception e) {            
				historySimpplrContentObj = (Simpplr_Content__c) JSON.deserialize(contentJsonStr, Type.forName('Simpplr_Content__c'));
				simpplrContentMap = (Map<String, Object>) JSON.deserializeUntyped(contentJsonStr);
			}
			
			List<String> contentObjectFieldsExcludedList = new List<String>{
				'Activated_By_Feature__c', 'Display_Excerpt__c','Event_Attending_Count__c',
				'Must_Read_Read_Count__c', 'Popularity_Score__c', 'Unique_View_Count__c',
				'Total_View_Count__c', 'Summary__c', 'Content_Age__c', 'Is_Published__c', 'Is_Unpublished__c',
				'Is_Promoted_For_Today__c', 'Status__c'
			};
			// Add namespace prefix
			for(String field : contentObjectFieldsExcludedList){
				contentObjectFieldsExcludedList[contentObjectFieldsExcludedList.indexOf(field)] = (SimpplrContext.namespaceprefix + field).toLowerCase();
			}

			List<String> contentObjectFields = new List<String>();
			for(String key : simpplrContentMap.keySet()){
				if(key.contains('__c')){
					contentObjectFields.add(key);
				}
			}
			String contentQuery = 'SELECT Id, ' + String.join(contentObjectFields, ',') + ', Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c FROM Simpplr_Content__c WHERE Id = :contentId ';
			List<Simpplr_Content__c> contentObjList = Database.query(contentQuery);

			// Create content history record if its missing, history record creation moved to after DML
			checkAndCreateContentHistory(contentObjList[0]);

			if(!contentObjList.isEmpty() && contentObjList.size() > 0){
				String versionFieldAPIName = (SimpplrContext.namespaceprefix + 'Version__c').toLowerCase();
				for(String field : contentObjectFields){
					
					if((versionFieldAPIName).equalsIgnoreCase(field.toLowerCase())){
						// Update version to the next version
						contentObjList[0].put(field, Integer.valueOf(contentObjList[0].get(field)) + 1);

					} else if(contentObjectFieldsExcludedList.indexOf(field.toLowerCase()) == (-1)){
						// Avoid updating, non updatable fields
						contentObjList[0].put(field, historySimpplrContentObj.get(field));
						
					}
					
				}

				update contentObjList;

				// Update topics
				if(String.isNotBlank(contentHistoryList[0].Topic_Json__c)){
					updateTopicReferences(contentHistoryList[0].Topic_Json__c, contentId);
				}

				// delete file ref
				if(String.isNotBlank(contentHistoryList[0].File_Json__c)){
					String fileJsonStr = mergeContentHistoryJsonStrings(contentHistoryList[0], 'file');
					Boolean isPublicSite = 'Public'.equalsIgnoreCase(contentObjList[0].Site__r.Site_Type__c);
					updateFileReferences(fileJsonStr, contentId, contentObjList[0].Status__c, contentObjList[0].Site__r.Chatter_Group_Id__c, isPublicSite);
				}

				// Create Audits and history records for this content
				ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObjList[0].Id, ServiceConstants.CONTENT_STATUS_UPDATE, contentObjList[0].Type__c);
			}

		}												
	}

	public Content_Notification_Setting__c getNotificationSetting(String contentId, String peopleId) {
		Content_Notification_Setting__c settingObj = null; 
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		soqlParamMap.put('soqlParam2', peopleId);
		String cnsQuery = 'SELECT Id, Notification_Enabled__c FROM Content_Notification_Setting__c WHERE Simpplr_Content__c = :soqlParam1 And People__c = :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Notification_Setting__c> contentNotiSettingList = (List<Content_Notification_Setting__c>)SIMPESAPI.accessController().queryAsUser(cnsQuery, soqlParamMap);

		if(!contentNotiSettingList.isEmpty()) {
			settingObj = contentNotiSettingList[0];
		}

		return settingObj;
	}

	public Content_Notification_Setting__c insertContentNotificationSettingForUser(String contentId, String peopleId) {

		Content_Notification_Setting__c notiSettingObj = new Content_Notification_Setting__c();
		notiSettingObj.Simpplr_Content__c = contentId;
		notiSettingObj.People__c = peopleId;
		notiSettingObj.Notification_Enabled__c = true;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		sObject obj = SIMPESAPI.accessController().insertAsUser(notiSettingObj, new List<Schema.SObjectField>{
																	Content_Notification_Setting__c.Simpplr_Content__c,
																	Content_Notification_Setting__c.People__c,
																	Content_Notification_Setting__c.Notification_Enabled__c
																});

		notiSettingObj = (Content_Notification_Setting__c)obj;

		return notiSettingObj;
	}

	public Content_Notification_Setting__c updateContentNotificationSettingForUser(Content_Notification_Setting__c notiSettingObj, Boolean isNotificationEnabled) {
		notiSettingObj.Notification_Enabled__c = isNotificationEnabled;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		sObject obj = SIMPESAPI.accessController().updateAsUser(notiSettingObj, new List<Schema.SObjectField>{
																	Content_Notification_Setting__c.Notification_Enabled__c
																});

		notiSettingObj = (Content_Notification_Setting__c)obj;

		return notiSettingObj;
	}

	private void updateFileReferences(String fileJsonStr, String contentId, String status, String chatterGroupId, Boolean isPublicSite){
				String unescapedFileJsonStr = fileJsonStr.unescapeUnicode();
				List<Object> fileObjList;
			
				try{
					fileObjList = (List<Object>) JSON.deserializeUntyped(unescapedFileJsonStr);
				}catch(Exception e) {           
					fileObjList = (List<Object>) JSON.deserializeUntyped(fileJsonStr);
				}
		

		Set<String> fileIdSet = new Set<String>();
		for(Object obj : fileObjList){
			Map<String, Object> fileObj = (Map<String, Object>) obj;

			fileIdSet.add((String) fileObj.get('Id'));
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileIdSet);
		soqlParamMap.put('soqlParam2', contentId);
		String filesQuery = 'SELECT Id, Simpplr_Content__c, Is_Deleted__c FROM File__c'+
									 ' WHERE '+
									 ' (Id IN :soqlParam1 OR Simpplr_Content__c = :soqlParam2)';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		logger.logDebug('id set of history files ==='+fileIdSet);
		List<File__c> updatedFilesList = new List<File__c>();							 
		for(File__c fileObj : fileList){
			if(!fileIdSet.contains(fileObj.Id)){
				// Delete files those were not present in the selected version

				fileObj.Simpplr_Content__c = null;
				updatedFilesList.add(fileObj);
			}  else if (fileIdSet.contains(fileObj.Id) && fileObj.Is_Deleted__c == true) {
				fileObj.Is_Deleted__c = false;
				fileObj.Simpplr_Content__c = contentId;
				updatedFilesList.add(fileObj);

			} else if(String.isBlank(fileObj.Simpplr_Content__c)){
				// Add deleted files

				fileObj.Simpplr_Content__c = contentId;
				updatedFilesList.add(fileObj);
			}
		}
		if(!updatedFilesList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(updatedFilesList), new List<Schema.SObjectField>{
																			File__c.Simpplr_Content__c,
																			File__c.Is_Deleted__c});
		}
	}	

	private void updateTopicReferences(String topicJsonStr, String contentId){
		List<Object> topicObjList = (List<Object>) JSON.deserializeUntyped(topicJsonStr);
		List<TopicWrapper> topicWrapperList = new List<TopicWrapper>();
		TopicWrapper topicwrapperObj = null;
		for(Object obj : topicObjList){
			topicwrapperObj = new TopicWrapper(); 

			Map<String, Object> topicMap = (Map<String, Object>) obj;
			Map<String, Object> topicAttrsMap = (Map<String, Object>) topicMap.get('Topic');

			topicwrapperObj.name = (String) topicAttrsMap.get('Name');
			topicwrapperObj.id = (String) topicAttrsMap.get('Id');

			topicWrapperList.add(topicwrapperObj);
		}

		// Create topics in case they were deleted
		Map<String, String> mapOfNewTopics = createNewTopics(topicWrapperList, null);
		// Create/ Delete topic references 
		saveTopicAssignmentsToDB(true, contentId, topicWrapperList, null, mapOfNewTopics);
	}

	public Map<String, String> createNewTopics(List<TopicWrapper> listOfTopics, List<String> listOfContentBodyTopics) {
		Map<String, String> mapOfTopicNameAndEnteredText = new Map<String, String>(); 
		if(listOfTopics != null) {
			for(TopicWrapper topicObj : listOfTopics) {
				if(String.isBlank(topicObj.id)) {
					String topicName = Utility.removeAllHashSymbolFromStart(topicObj.name).trim();
				mapOfTopicNameAndEnteredText.put(topicName, topicObj.name);
				}
			}
		}
		if(listOfContentBodyTopics != null) {
			for(String topicStr : listOfContentBodyTopics) {
				if(String.isNotBlank(topicStr) && topicStr.startsWithIgnoreCase('_new_')) {
					String topicName = topicStr.replaceFirst('_new_','');
					mapOfTopicNameAndEnteredText.put(topicName, topicStr);
				
				} 
			}
		}
		Map<String, String> mapOfNewTopics = new Map<String, String>();
		if(mapOfTopicNameAndEnteredText.isEmpty() == false) {
			Set<String> setOfTopicNames = mapOfTopicNameAndEnteredText.keySet();
			String BASE_QUERY= 'Select Id, Name from Topic where Name in: setOfTopicNames';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}
		List<Topic> listOfDBTopics = Database.query(BASE_QUERY);
		for(Topic dbTopic :listOfDBTopics){
			String enteredText = mapOfTopicNameAndEnteredText.get(dbTopic.name);
				if(String.isNotBlank(enteredText)) {
					mapOfTopicNameAndEnteredText.remove(dbTopic.name);
					mapOfNewTopics.put(enteredText, dbTopic.Id);
				}
			}
			if(mapOfTopicNameAndEnteredText.isEmpty() == false && UserContext.canCreateTopics) {
			List<Topic> listOfNewTopics = new List<Topic>(); 
				for(String topicStr : mapOfTopicNameAndEnteredText.keySet()) {
					listOfNewTopics.add(new Topic(name = topicStr));
				}
				Database.insert(listOfNewTopics, false);
				for(Topic topicSaved : listOfNewTopics) {
					String enteredText = mapOfTopicNameAndEnteredText.get(topicSaved.name);
					if(String.isNotBlank(enteredText) && String.isNotBlank(topicSaved.Id)) {
					mapOfNewTopics.put(enteredText, topicSaved.Id);
					}
				}
			}
		}
		
		return mapOfNewTopics;
	}

	public void saveTopicAssignmentsToDB(Boolean isEdit, Id contentId, List<TopicWrapper> listOfTopics, List<String> listOfContentBodyTopics, Map<String, String> mapOfNewTopics) {
		Map<String, TopicAssignment> mapOfTopicIdAndTopicAssignment = new Map<String, TopicAssignment>();
		if(listOfTopics != null) {
			for(TopicWrapper topicObj : listOfTopics) {
				if(String.isNotBlank(topicObj.id)) {
					mapOfTopicIdAndTopicAssignment.put(topicObj.id, new TopicAssignment(TopicId = topicObj.id, EntityId = contentId));
				
				} else if(mapOfNewTopics.containsKey(topicObj.name)) {
						String topicId = mapOfNewTopics.get(topicObj.name);
					mapOfTopicIdAndTopicAssignment.put(topicId, new TopicAssignment(TopicId = topicId, EntityId = contentId));
					
				}
			}
		}
		if(listOfContentBodyTopics != null) {
				for(String topicStr : listOfContentBodyTopics) {
					if(mapOfNewTopics.containsKey(topicStr)) {
						String topicId = mapOfNewTopics.get(topicStr);
						mapOfTopicIdAndTopicAssignment.put(topicId, new TopicAssignment(TopicId = topicId, EntityId = contentId));
						
					} else if(String.isNotBlank(topicStr) && topicStr.startsWithIgnoreCase('_new_') == false) {
						mapOfTopicIdAndTopicAssignment.put(topicStr, new TopicAssignment(TopicId = topicStr, EntityId = contentId));
						
					}
				}
			
		}
		List<TopicAssignment> listOfDeletedTopicAssignment = new List<TopicAssignment>();
		List<TopicAssignment> listOfNewTopicAssignment = new List<TopicAssignment>();
		
		if(isEdit) {
			List<TopicAssignment> existingTopicAssignmentList= [Select id, TopicId from TopicAssignment where entityId=:contentId WITH SECURITY_ENFORCED];
			
			for(TopicAssignment topicAssignmentObj : existingTopicAssignmentList) {
				if(mapOfTopicIdAndTopicAssignment.containsKey(topicAssignmentObj.topicId)) {
					mapOfTopicIdAndTopicAssignment.remove(topicAssignmentObj.topicId);
					
				} else {
					listOfDeletedTopicAssignment.add(topicAssignmentObj);
					
				}
			}
		}
		if(listOfDeletedTopicAssignment.size() > 0) {
			delete listOfDeletedTopicAssignment;
		}
		if(mapOfTopicIdAndTopicAssignment.size() > 0) {
			insert mapOfTopicIdAndTopicAssignment.values();
		}
	}

	public List<ContentVersionHistoryWrapper> getContentVersionHistory(String contentId, Integer offset, Integer size){
		List<ContentVersionHistoryWrapper> contentVersionHistoryWrapperList = new List<ContentVersionHistoryWrapper>();

		Integer recordLimit = size + 1;

		String aTQuery = 'SELECT Id, Content_History__c, Content_History__r.Version__c, Action__c, Content__r.Version__c, Content__r.CreatedDate, '
							+ ' Action_By__c, Action_DateTime__c, Content__r.Primary_Author__c, Content__r.Primary_Author__r.user__c, '
							+ ' Action_By__r.User__c, Action_By__r.First_Name__c, Action_By__r.Last_Name__c, Action_By__r.user__r.SmallPhotoURL, '
							+ ' Action_By__r.Title__c, Action_By__r.User__r.isactive '
							+ ' FROM Content_Audit_Trail__c WHERE '
							+ ' Content__c = :contentId AND ( '
								+ ' Action__c = \'Draft Created\' OR '
								+ ' Action__c = \'Draft Updated\' OR '
								+ ' Action__c = \'Created\' OR '
								+ ' Action__c = \'Updated\') '
							+ ' ORDER BY CreatedDate DESC ';

		if(offset != null) {
			aTQuery += ' LIMIT :recordLimit OFFSET :offset';
		}
		List<Content_Audit_Trail__c> auditTrailList = Database.query(aTQuery);
		if(!auditTrailList.isEmpty()){
			ContentVersionHistoryWrapper contentVersionHistoryWrapperObj = null;

			Integer index = 0;
			for(Content_Audit_Trail__c auditTrailObj : auditTrailList){
				contentVersionHistoryWrapperObj = new contentVersionHistoryWrapper();

				contentVersionHistoryWrapperObj.versionHistoryId = String.isNotBlank(auditTrailObj.Content_History__c) ? auditTrailObj.Content_History__r.Version__c + '' : auditTrailObj.Content__r.Version__c  + '';
				contentVersionHistoryWrapperObj.createdAt = Utility.dateToDisplayString(auditTrailObj.Action_DateTime__c, 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				contentVersionHistoryWrapperObj.updatedAt = Utility.dateToDisplayString(auditTrailObj.Action_DateTime__c, 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				contentVersionHistoryWrapperObj.user = convertToPeopleWrapper(auditTrailObj);
				contentVersionHistoryWrapperObj.isAuthor = auditTrailObj.Action_By__c == auditTrailObj.Content__r.Primary_Author__r.user__c;
				if('Created'.equalsIgnoreCase(auditTrailObj.Action__c)) {
					contentVersionHistoryWrapperObj.action = 'created';
				
				} else if ('Draft Created'.equalsIgnoreCase(auditTrailObj.Action__c)) {
					contentVersionHistoryWrapperObj.action = 'created';

				} else if ('Updated'.equalsIgnoreCase(auditTrailObj.Action__c)) {
					contentVersionHistoryWrapperObj.action = 'edited';

				} else if ('Approved'.equalsIgnoreCase(auditTrailObj.Action__c)) {
					contentVersionHistoryWrapperObj.action = 'created';

				} else if ('Draft Updated'.equalsIgnoreCase(auditTrailObj.Action__c)) {
					contentVersionHistoryWrapperObj.action = 'edited';
				
				} 	
				contentVersionHistoryWrapperObj.isLatest = (auditTrailObj.Content_History__r.Version__c == null);

				contentVersionHistoryWrapperList.add(contentVersionHistoryWrapperObj);

				++index;
			}
		}

		return contentVersionHistoryWrapperList;
	}

	private PeopleListWrapper convertToPeopleWrapper(Content_Audit_Trail__c auditTrailObj){
		PeopleListWrapper peopleWrapper = new PeopleListWrapper();

		peopleWrapper.id = auditTrailObj.Action_By__r.user__c;
		peopleWrapper.peopleId = auditTrailObj.Action_By__r.Id;
		peopleWrapper.sfUserId = auditTrailObj.Action_By__r.user__c;
		peopleWrapper.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + auditTrailObj.Action_By__r.Id;
		String nameForAuthor = Utility.buildName(auditTrailObj.Action_By__r.First_Name__c, auditTrailObj.Action_By__r.Last_Name__c);
		if(String.isNotBlank(nameForAuthor)){
			peopleWrapper.name = nameForAuthor;
		}
		peopleWrapper.img = auditTrailObj.Action_By__r.user__r.SmallPhotoURL.endsWith('005/T') ? null : auditTrailObj.Action_By__r.user__r.SmallPhotoURL;
		peopleWrapper.title = auditTrailObj.Action_By__r.Title__c;
		peopleWrapper.isActive = auditTrailObj.Action_By__r.User__r.isactive;

		return peopleWrapper;
	}

	/**
	* @description Invoke future to create content history if content hitory version less than content version
	* @param contentObj content record
	* @param type type of content
	**/
	public void checkAndCreateContentHistory(Simpplr_Content__c contentObj, String type){
		Content_History__c contentHistoryObj = getLatestContentHistoryByContentId(contentObj.Id);

		logger.logDebug('content version=> ' + contentObj.Version__c);
		logger.logDebug('latest contentHistory => ' + contentHistoryObj);

		if(contentObj != null 
			&& (contentHistoryObj == null 
			|| ( contentHistoryObj != null 
				&& contentObj.Version__c != null 
				&& contentHistoryObj.Version__c != null 
				&& contentHistoryObj.Version__c < contentObj.Version__c))){
			ManageContentDao.checkAndCreateContentHistoryAsync(contentObj.Id, type);
		}
	}

	/**
	* @description process content history and audit records in async
	* @param contentId content record id
	* @param action action value add/edit
	* @param type content type blog, page and album
	**/
	@future
	public static void createContentHistoryAndAuditRecordsAsync(Id contentId, String action, String type){
		ManageContentDao contentDoa = new ManageContentDao();
		Simpplr_Content__c contentObj = contentDoa.getContentById(contentId, type);
		if(contentObj != null) {
			contentDoa.createContentHistoryAndAuditRecords(contentObj, action);
		}
	}

	/**
	* @description create content history if content hitory version less than content version
	* @param contentId content id
	* @param type type of content
	**/
	@future
	public static void checkAndCreateContentHistoryAsync(Id contentId, String type){
		ManageContentDao contentDoa = new ManageContentDao();
		Simpplr_Content__c contentObj = contentDoa.getContentById(contentId, type);
		contentDoa.checkAndCreateContentHistory(contentObj);
	}

	/**
	* @description creates history records if missing
	* @param contentObj content record
	**/
	public void checkAndCreateContentHistory(Simpplr_Content__c contentObj){
		Content_History__c contentHistoryObj = getLatestContentHistoryByContentId(contentObj.Id);
		if(contentObj != null 
			&& (contentHistoryObj == null 
			|| ( contentHistoryObj != null 
				&& contentObj.Version__c != null 
				&& contentHistoryObj.Version__c != null 
				&& contentHistoryObj.Version__c < contentObj.Version__c))){
			createContentHistory(contentObj);
		}
	}

	/**
	* @description Insert trail record in async to send to elastic
	* @param contentId record id of content
	**/
	@future
	public static void insertSearchTrailObjectForContentAsync(String contentId){
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
		External_Search_Data_Trail__c searchObj = new External_Search_Data_Trail__c();
		searchObj.Content__c = contentId;
		searchObj.Type__c = 'Content';
		listToInsert.add(searchObj);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
									   External_Search_Data_Trail__c.Content__c,
									   External_Search_Data_Trail__c.Type__c});      
	}

	/**
	* @description this method returns latest content history record
	* @param contentId content record id
	* @return Content_History__c latest history record
	**/
	public Content_History__c getLatestContentHistoryByContentId(Id contentId){

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		
		String query = 'SELECT Id, Version__c FROM Content_History__c WHERE Content__c = :soqlParam1 ORDER BY CreatedDate DESC LIMIT 1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_History__c> listContentHistory = (List<Content_History__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

		return (listContentHistory != null && !listContentHistory.isEmpty() ? listContentHistory[0] : null);
	}

	/**
	 * Save audit trails and histories for a content 
	 */
	public void createContentHistoryAndAuditRecords(Simpplr_Content__c content, String action){
		String contentAction = '';

		if(ServiceConstants.CONTENT_STATUS_CREATE_DRAFT.equalsIgnoreCase(action)){
			contentAction = 'Draft Created';
		}else if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(action)){
			contentAction = 'Created';
		}else if(ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT.equalsIgnoreCase(action)){
			contentAction = 'Draft Updated';
		}else if(ServiceConstants.CONTENT_STATUS_UPDATE.equalsIgnoreCase(action)){
			contentAction = 'Updated';
		}

		Content_History__c contentHistoryObj = createContentHistory(content);

		if(ServiceConstants.CONTENT_STATUS_UPDATE.equalsIgnoreCase(action) 
			|| ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT.equalsIgnoreCase(action)){
			List<Content_Audit_Trail__c> auditTrailList = [SELECT Id, Content_History__c FROM Content_Audit_Trail__c WHERE
														Content__c = :content.Id AND (
															Action__c = 'Created' OR 
															Action__c = 'Updated' OR 
															Action__c = 'Draft Updated' OR 
															Action__c = 'Draft Created') 
															WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];

			if(!auditTrailList.isEmpty()){
				//Link Previous audit trail and history object
				Content_History__c oldContentHistoryObj = getPreviousContentHistory(content.Id, contentHistoryObj.Version__c);
				linkAuditTrailAndContentHistory(auditTrailList[0], oldContentHistoryObj);
			} //END IF - auditTrailList
		}

		// Create audit trail for currrent action
		createContentAuditTrail(content.id, contentAction, null);
	}

	/**
	* @description link audit trail and content history each other, this show up on content history tab UI.
	* @param auditTrailObj trail record
	* @param contentHistoryObj content history
	**/
	public void linkAuditTrailAndContentHistory(Content_Audit_Trail__c auditTrailObj, Content_History__c contentHistoryObj){
		if(auditTrailObj != null && contentHistoryObj != null){
			auditTrailObj.Content_History__c =  contentHistoryObj.Id;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(auditTrailObj, new List<Schema.SObjectField>{
				Content_Audit_Trail__c.Content_History__c
			});
		}
	}

	/**
	* @description get previous content history
	* @param contentId content id
	* @param versionNumber content version
	* @return Content_History__c previous content version record
	**/
	public Content_History__c getPreviousContentHistory(Id contentId, Decimal versionNumber){
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', contentId);
		sqlParamMap.put('soqlParam2', versionNumber);

		String queryStr = 'SELECT Id FROM Content_History__c WHERE Content__c = :soqlParam1 AND Version__c < :soqlParam2 ORDER BY CreatedDate DESC LIMIT 1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_History__c> listContentHistory = (List<Content_History__c>)SIMPESAPI.accessController().queryAsUser(queryStr, sqlParamMap);
		return (listContentHistory != null && !listContentHistory.isEmpty() ? listContentHistory[0] : null);	
	}

	/**
	* @description content by id before update, with less fields status and content sub type
	* @param contentId record Id
	* @return Simpplr_Content__c content record with status and sub time
	**/
	public static Simpplr_Content__c getContentById(Id contentId){

		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', contentId);

		String queryStr = 'SELECT id, Status__c, Content_Sub_Type__c, Feed_Posts__c, Feed_Questions__c, Question_Answer_Enabled__c, Allow_comments__c, '+
			' Site__c FROM Simpplr_Content__c WHERE Id =:soqlParam1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Content__c> contentList = (List<Simpplr_Content__c>)SIMPESAPI.accessController().queryAsUser(queryStr, sqlParamMap);

		return (contentList != null && !contentList.isEmpty() ? contentList[0] : null);
	}

	/**
	* @description get content by content id
	* @param contentId content id 
	* @param type content type
	* @return Simpplr_Content__c content record
	**/
	public Simpplr_Content__c getContentById(Id contentId, String type){
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		
		String query = '';
		if(type == ServiceConstants.TYPE_PAGE){
			query = 'SELECT id, Status__c, Type__c, site__c, Title__c, Content_Sub_Type__c, Text_Json__c, Text_Main_Json__c, Text_Main_Continued_Json__c, Text_Intro__c, Text_Main__c, Text_Main_Continued__c, Excerpt__c, Summary_1__c, Title_Image_Caption__c, Pages_Category__c, Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Edited_DateTime__c, Allow_comments__c, Use_Maximum_Screenwidth__c, Cover_Image_Layout__c, Primary_Author__c, Display_Order__c, Is_Published__c, Is_Unpublished__c, Version__c FROM Simpplr_Content__c WHERE Id =:soqlParam1';
		} else if(type == ServiceConstants.TYPE_ALBUM){
			query = 'SELECT id, Status__c, Title__c, Type__c, site__c, Content_Sub_Type__c, Text_Json__c, Text_Main_Json__c, Text_Main_Continued_Json__c, Text_Intro__c, Text_Main__c, Text_Main_Continued__c, Excerpt__c, Summary_1__c, Title_Image_Caption__c, Pages_Category__c, Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Edited_DateTime__c, Allow_comments__c, Cover_Image_Layout__c, Primary_Author__c, Album_Allow_All_to_Upload__c, Use_Maximum_Screenwidth__c, Album_Video_Count__c, Album_Image_Count__c, Is_Published__c, Is_Unpublished__c, Version__c FROM Simpplr_Content__c WHERE Id =:soqlParam1';
		} else if(type == ServiceConstants.TYPE_EVENT){
			query = 'SELECT id, Status__c, Type__c, site__c, Title__c, Content_Sub_Type__c, Text_Json__c, Text_Main_Json__c, Text_Main_Continued_Json__c, Text_Intro__c, Text_Main__c, Text_Main_Continued__c, Excerpt__c, Summary_1__c, Title_Image_Caption__c, Pages_Category__c, Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Edited_DateTime__c, Allow_comments__c, Cover_Image_Layout__c, Primary_Author__c, Event_Is_All_Day__c,Event_Start_DateTime__c, Event_End_DateTime__c, Event_RSVP_Allowed__c, Event_RSVP_Show_Maybe__c, Event_RSVP_Note__c, Event_RSVP_Limit__c, Event_RSVP_By_DateTime__c, Event_Location__c, Event_Map_URL__c, Event_TimezoneSidKey__c, Event_Directions_Enabled__c, Event_Directions__c, Is_Published__c, Is_Unpublished__c, Version__c FROM Simpplr_Content__c WHERE Id =:soqlParam1';
		}


		List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();

		if(String.isNotBlank(query)){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			contentList = (List<Simpplr_Content__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		}

		return (contentList != null && !contentList.isEmpty() ? contentList[0] : null);
	}

	/**
	* @description method to create content history record
	* @param content the content for which history records to be created
	* @return Content_History__c newly created content history record
	**/
	public Content_History__c createContentHistory(Simpplr_Content__c content){
		List<TopicAssignment> topicAssignmentList = [Select Topic.Name, TopicId, EntityId  From TopicAssignment Where EntityId = :content.Id WITH SECURITY_ENFORCED];
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', content.Id);
		String filesQuery = 'Select id, Title_Image_Type__c, Is_Title_Image__c, Thumbnail_URL__c, MIME_Type__c, External_Id__c,'+
									' Repository__c, URL__c, Title__c, Simpplr_Content__r.Site__c,Content_Document__c, Content_Version__c,'+
									' size__c, Location__c, Description__c From File__c Where Simpplr_Content__c = :soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		
		soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', content.Id);
		String collaboratorQuery = 'Select Type__c, Simpplr_Content__c, OwnerId, Name, id, Collaborator__c From Content_Collaborator__c Where Simpplr_Content__c = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Collaborator__c> collaboratorList = (List<Content_Collaborator__c>)SIMPESAPI.accessController().queryAsUser(collaboratorQuery, soqlParamMap);

		if(content.Text_Json__c!=null){
			content.Text_Intro__c = '';
			content.Text_Main__c = '';
			content.Text_Main_Continued__c = '';
		}
		Content_History__c contentHistoryObj = new Content_History__c();
		String oldContentJson = JSON.serialize(content);
		Map<Integer, String> contentJsonMap = getContentJsonMap(oldContentJson);
		contentHistoryObj.Content_Json_Part1__c = String.isNotBlank(contentJsonMap.get(1))?'"'+contentJsonMap.get(1)+'"':'';
		contentHistoryObj.Content_Json_Part2__c = String.isNotBlank(contentJsonMap.get(2))?'"'+contentJsonMap.get(2)+'"':'';
		contentHistoryObj.Content_Json_Part3__c = String.isNotBlank(contentJsonMap.get(3))?'"'+contentJsonMap.get(3)+'"':'';
		contentHistoryObj.Content_Json_Part4__c = String.isNotBlank(contentJsonMap.get(4))?'"'+contentJsonMap.get(4)+'"':'';
		contentHistoryObj.Content_Json_Part5__c = String.isNotBlank(contentJsonMap.get(5))?'"'+contentJsonMap.get(5)+'"':'';

		String fileJson = JSON.serialize(fileList);
		Map<Integer, String> fileJsonMap = getContentJsonMap(fileJson);
		contentHistoryObj.File_Json__c = String.isNotBlank(fileJsonMap.get(1))?'"'+fileJsonMap.get(1)+'"':'';
		contentHistoryObj.File_Json_Part1__c = String.isNotBlank(fileJsonMap.get(2))?'"'+fileJsonMap.get(2)+'"':'';
		contentHistoryObj.File_Json_Part2__c = String.isNotBlank(fileJsonMap.get(3))?'"'+fileJsonMap.get(3)+'"':'';
		contentHistoryObj.File_Json_Part3__c = String.isNotBlank(fileJsonMap.get(4))?'"'+fileJsonMap.get(4)+'"':'';
		
		contentHistoryObj.Topic_Json__c = JSON.serialize(topicAssignmentList);
		contentHistoryObj.Collaborator_Json__c = JSON.serialize(collaboratorList);
		contentHistoryObj.Content__c = content.Id;
		contentHistoryObj.Content_Status__c = getContentStatus(content.Status__c, content.Is_Published__c, content.Is_Unpublished__c);

		contentHistoryObj.Version__c = content.Version__c != null ? content.Version__c : 1;

		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

		fieldList.add(Content_History__c.Content_Json_Part1__c);
		fieldList.add(Content_History__c.Content_Json_Part2__c);
		fieldList.add(Content_History__c.Content_Json_Part3__c);
		fieldList.add(Content_History__c.Content_Json_Part4__c);
		fieldList.add(Content_History__c.Content_Json_Part5__c);
		
		fieldList.add(Content_History__c.File_Json__c);
		fieldList.add(Content_History__c.File_Json_Part1__c);
		fieldList.add(Content_History__c.File_Json_Part2__c);
		fieldList.add(Content_History__c.File_Json_Part3__c);
		
		fieldList.add(Content_History__c.Topic_Json__c);
		fieldList.add(Content_History__c.Collaborator_Json__c);
		fieldList.add(Content_History__c.Content__c);
		fieldList.add(Content_History__c.Content_Status__c);
		fieldList.add(Content_History__c.Version__c);

		List<Content_History__c> contentHistoryList = new List<Content_History__c>{contentHistoryObj};

		if( !contentHistoryList.isEmpty() ) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(contentHistoryList, fieldList);
			contentHistoryObj = (Content_History__c)(result.getInsertedObjects()[0]);
		}
		
		return contentHistoryObj;
	}

	private String getContentStatus(String dbStatus, Boolean isPublished, Boolean isUnpublished) {
		String status;
		if (dbStatus != NULL){
		   if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(dbStatus)){
			   status = ServiceConstants.CONTENT_STATUS_PENDING.toLowerCase();
		   
		   } else if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(dbStatus)){
			   status = ServiceConstants.CONTENT_STATUS_DRAFT.toLowerCase();
		   
		   } else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(dbStatus)){ 
			   status = ServiceConstants.CONTENT_STATUS_REJECTED.toLowerCase();
		   
		   } else if (isPublished){
			   status = ServiceConstants.CONTENT_STATUS_PUBLISH.toLowerCase();
		   
		   } else if (isUnpublished){
			   status = ServiceConstants.CONTENT_STATUS_UNPUBLISH.toLowerCase();
		   
		   } else if (ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(dbStatus)){
			   status = ServiceConstants.CONTENT_STATUS_APPROVED.toLowerCase();
		   }
	   }
	   return status;
   }

	@testVisible
	private Map<Integer, String> getContentJsonMap(String contentJson){
        contentJson = contentJson.escapeUnicode();
		Map<Integer, String> contentJsonMap = new Map<Integer, String>();
		Matcher m = Pattern.compile('.{1,131068}').matcher(contentJson);
    	contentJsonMap.put(1,m.find() ? contentJson.substring(m.start(), m.end()) : '');
    	contentJsonMap.put(2,m.find() ? contentJson.substring(m.start(), m.end()) : '');
    	contentJsonMap.put(3,m.find() ? contentJson.substring(m.start(), m.end()) : '');
    	contentJsonMap.put(4,m.find() ? contentJson.substring(m.start(), m.end()) : '');
		contentJsonMap.put(5,m.find() ? contentJson.substring(m.start(), m.end()) : '');
		
    	return contentJsonMap;
	}

	public String mergeContentHistoryJsonStrings(Content_History__c contHistObj, String type) {
		String mergedJsonStr = '';

		if('content'.equalsIgnoreCase(type)){
			if(String.isNotBlank(contHistObj.Content_Json_Part1__c)){
				mergedJsonStr = contHistObj.Content_Json_Part1__c.removeStart('"').removeEnd('"');
			}
			if(String.isNotBlank(contHistObj.Content_Json_Part2__c)){
				mergedJsonStr += contHistObj.Content_Json_Part2__c.removeStart('"').removeEnd('"');
			}
			if(String.isNotBlank(contHistObj.Content_Json_Part3__c)){
				mergedJsonStr += contHistObj.Content_Json_Part3__c.removeStart('"').removeEnd('"');
			}
			if(String.isNotBlank(contHistObj.Content_Json_Part4__c)){
				mergedJsonStr += contHistObj.Content_Json_Part4__c.removeStart('"').removeEnd('"');
			}
			if(String.isNotBlank(contHistObj.Content_Json_Part5__c)){
				mergedJsonStr += contHistObj.Content_Json_Part5__c.removeStart('"').removeEnd('"');
			}

		} else if('file'.equalsIgnoreCase(type)){
			if(String.isNotBlank(contHistObj.File_Json__c)){
				mergedJsonStr = contHistObj.File_Json__c.removeStart('"').removeEnd('"');
			}
			if(String.isNotBlank(contHistObj.File_Json_Part1__c)){
				mergedJsonStr += contHistObj.File_Json_Part1__c.removeStart('"').removeEnd('"');
			}
			if(String.isNotBlank(contHistObj.File_Json_Part2__c)){
				mergedJsonStr += contHistObj.File_Json_Part2__c.removeStart('"').removeEnd('"');
			}
			if(String.isNotBlank(contHistObj.File_Json_Part3__c)){
				mergedJsonStr += contHistObj.File_Json_Part3__c.removeStart('"').removeEnd('"');
			}
									 
		}

		return mergedJsonStr;
	}

	private static Boolean removeValidationRequiredNotifications(String contentId) {
		List<App_Notification__c> appNotiList = [SELECT Id, Is_Deleted__c FROM App_Notification__c 
													WHERE Is_Deleted__c = false AND Type__c = 'Actionable' AND Action_By__c = null 
													AND Category__c = 'CONTENT_FOR_REVIEW' AND Content__c = :contentId WITH SECURITY_ENFORCED];

		if(!appNotiList.isEmpty()){
			for(App_Notification__c notiObj : appNotiList) { 
                notiObj.Action_By__c = UserContext.peopleId;
                notiObj.Action_On__c = DateTime.now();
			} 

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Notification__c>(appNotiList), new List<Schema.SObjectField>{
                App_Notification__c.Action_By__c, 
                App_Notification__c.Action_On__c});
		}

		return true;
	}

	/**
	 * This method is used to fetch metadata of content
	 * @param contentId 
	 * @return  `Map<String, Object>`
	*/
	public Map<String, Object> getMetadata(String contentId) {
		Map<String, Object> resultMap = new Map<String, Object>();
		String loggedInPeopleId = UserContext.peopleId;
		String query = 'SELECT Id, Likes__c, Feed_Posts__c, Feed_Questions__c, Question_Answer_Enabled__c, Allow_comments__c,' +
							' (select id from Bookmarked_Content__r where People__c =: loggedInPeopleId and Is_Deleted__c = false), ' +
							' (select id from Likes_Simpplr_Content__r where People__c =: loggedInPeopleId and Is_Deleted__c = false) '+
							'  FROM Simpplr_Content__c WHERE Id =: contentId and Is_Deleted__c = false';

		List<Simpplr_Content__c> contentList = Database.query(query); 
		if(!contentList.isEmpty()) {
			Simpplr_Content__c contentRecord = contentList[0];
			resultMap.put('isLiked', !contentRecord.Likes_Simpplr_Content__r.isEmpty());
			resultMap.put('isFavorited', !contentRecord.Bookmarked_Content__r.isEmpty());
			resultMap.put('likeCount', Integer.valueOf(contentRecord.Likes__c));
			if(contentRecord.Allow_comments__c == true) {
				resultMap.put('postCount', Integer.valueOf(contentRecord.Feed_Posts__c));
			}
			if(contentRecord.Question_Answer_Enabled__c == true) {
				resultMap.put('questionCount', contentRecord.Feed_Questions__c != null ? Integer.valueOf(contentRecord.Feed_Questions__c) : 0);
			}
		}
		return resultMap;
	}

	/**
	 * @description This method is used for must read csv with more then 10K records
	 * @param contentId
	 * @param filter
	*/
	public void requestMustReadHistoryCsv(String contentId, String filter) {
		PeopleDao peopleDaoObj = new PeopleDao();
		List<Must_Read_Audit__c> mrAuditList = peopleDaoObj.getMustReadAuditList(contentId);
		Map<String, Object> requestBody = new Map<String, Object>();
		if(mrAuditList.isEmpty() == false){
			requestBody.put('mrAuditId', mrAuditList[0].id);
			requestBody.put('audienceType', mrAuditList[0].Audience_Type__c);
			requestBody.put('chatterGroupId', mrAuditList[0].Content__r.Site__r.Chatter_group_Id__c);
		}
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String query = 'SELECT Id, Language__c, Site__c, Title__c, OwnerId  ' +
							' FROM Simpplr_Content__c WHERE Id =: soqlParam1 and Is_Deleted__c = false';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.With);
		List<Simpplr_Content__c> contentList = (List<Simpplr_Content__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(!contentList.isEmpty()) {
			Simpplr_Content__c contentRecord = contentList[0];
			String siteId = String.isNotBlank(contentRecord.Site__c) ? (String) contentRecord.Site__c: null;
			String title = String.isNotBlank(contentRecord.Title__c) ? (String) contentRecord.Title__c: null;
			requestBody.put('contentId', contentId);
			requestBody.put('filter', filter);
			requestBody.put('siteId', siteId);
			requestBody.put('title', title);
			requestBody.put('widgetTab', 'Must Read History');
			requestBody.put('widgetTitle', title);
			requestBody.put('action', 'getMustReadHistory');
			requestBulkDataCsv(requestBody, null);
		}	
	}

	/**
	 * @description This method is used to send POST request to aws to generate csv for more then 10K records
	 * @param requestBody
	 * @param requestDataMap
	*/
	public void requestBulkDataCsv(Map<String, Object> requestBody, Map<String, Object> requestDataMap) {
		String groupBy = requestDataMap != null && requestDataMap.containsKey('groupBy') && requestDataMap.get('groupBy') != null ? (String) requestDataMap.get('groupBy') : null;
		String filterBy = requestDataMap != null && requestDataMap.containsKey('filterBy') && requestDataMap.get('filterBy') != null ? (String) requestDataMap.get('filterBy') : null;
		String filterValue = requestDataMap != null && requestDataMap.containsKey('filterValue') && requestDataMap.get('filterValue') != null ? (String) requestDataMap.get('filterValue') : null;
		String metric = requestDataMap != null && requestDataMap.containsKey('metric') && requestDataMap.get('metric') != null ? (String) requestDataMap.get('metric') : null;
		String siteId = requestDataMap != null && requestDataMap.containsKey('siteId') && requestDataMap.get('siteId') != null ? (String) requestDataMap.get('siteId') : null;
		String action = requestDataMap != null && requestDataMap.containsKey('action') && requestDataMap.get('action') != null ? (String) requestDataMap.get('action') : null;
		DateTime currentDateTime = Datetime.now();
		List<String> localeList = new List<String>();
		localeList.add(UserContext.languageLocaleKey);
		LocaleContext.getAllLabelMap('EmailNotifications', localeList);
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('userId', String.isNotBlank(UserContext.userId) ? (String) UserContext.userId: null);
		requestBody.put('lang', String.isNotBlank(UserContext.languageLocaleKey) ? (String) UserContext.languageLocaleKey: null);
		requestBody.put('isFullExternalSearchEnable', SimpplrContext.isFeatureEnabled('Full_External_Search'));
		requestBody.put('isApiOnlyUserQueryable', Utility.isApiOnlyUserQueryable());
		requestBody.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
		requestBody.put('packageName', SimpplrContext.packageName);
		requestBody.put('timeZoneName', UserContext.timeZoneName);
		requestBody.put('requestDateTime', currentDateTime);
		requestBody.put('localizedDateTime', LocaleContext.getLocalisedDateAsDDMMMMYYYYhhmmss(currentDateTime, UserContext.languageLocaleKey));
		if(String.isNotBlank(groupBy)){
			requestBody.put('groupBy', groupBy);
		}
		if(String.isNotBlank(filterBy)){
			requestBody.put('filterBy', filterBy);
		}
		if(String.isNotBlank(filterValue)){
			requestBody.put('filterValue', filterValue);
		}
		if(String.isNotBlank(metric)){
			requestBody.put('metric', metric);
		}
		if(String.isNotBlank(siteId)){
			requestBody.put('siteId', siteId);
		}
		if('getPeoplePerformance'.equalsIgnoreCase(action) && String.isNotBlank(siteId)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId); 
			String siteQuery = 'SELECT chatter_group_id__c from simpplr_site__c where Id =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
			if(!siteObjectList.isEmpty()){
				String chatterGrpId = siteObjectList[0].chatter_group_id__c;
				Map<String, Object> soqlParamMap1 = new Map<String, Object>();
				soqlParamMap1.put('soqlParam1', chatterGrpId); 
				String collaborationGrpQuery = 'select id, OwnerId from CollaborationGroup where Id =:soqlParam1 ';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<CollaborationGroup> collaborationGroupList = (List<CollaborationGroup>)SIMPESAPI.accessController().queryAsUser(collaborationGrpQuery, soqlParamMap1);
				requestBody.put('ownerId', (collaborationGroupList.isEmpty() ? '' : collaborationGroupList[0].OwnerId));
			}
			requestBody.put('includeName', true);
		}
		HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/analytics-data/processor-service', requestBody);
		if (res.getStatusCode() != 200) {
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
		}
	}

	public class ContentAuditTrailWrapper {
		public String oldSite; 
		public String newSite; 
		public String oldAuthor;
		public String newAuthor;
		public String message;
		public String actionBy;
		public String actionDate;
		public String action; 
		public String contentId; 
	}   			
		
}