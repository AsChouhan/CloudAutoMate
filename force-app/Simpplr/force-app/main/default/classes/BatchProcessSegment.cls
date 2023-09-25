public without sharing class BatchProcessSegment implements Database.Batchable<SObject>, Database.Stateful  {
	public static final String KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_BODY_PLURAL = 'email.notification.system.segments.locked_out.body_plural';
	public static final String KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_SUBJECT_PLURAL = 'email.notification.system.segments.locked_out.subject_plural';
	public static final String KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_SUBJECT_SINGULAR = 'email.notification.system.segments.locked_out.subject_singular';
	public static final String KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_BODY_SINGULAR = 'email.notification.system.segments.locked_out.body_singular';
	
	private String batchType;
	private String query;
	private Boolean runNextBatchInSequence;
	private Exception exceptionDetailsObj;
	private Integer countOfpeopleWithoutSegmentAttrAndWithoutSegment = 0;
	private Integer countOfpeopleWithSegmentAttrAndWithoutSegment = 0;
	private Integer countOfpeopleExcludedFromSegments = 0;
	private Set<Id> segmentIdToRemoveSet = null;
	private Set<String> invalidAudienceMembersPeopleIdSet = new Set<String>();
	
    public BatchProcessSegment (String batchType, Boolean shouldInherit) {
        this.batchType = batchType;
        this.runNextBatchInSequence = shouldInherit;
    } 
    
	public BatchProcessSegment (String batchType, Boolean runNextBatchInSequence, Set<Id> segmentIdToRemoveSet) {
        this.batchType = batchType;
        this.runNextBatchInSequence = runNextBatchInSequence;
        this.segmentIdToRemoveSet = segmentIdToRemoveSet;
    }
    
  	public BatchProcessSegment (String batchType, Set<String> invalidAudienceMembersPeopleIdSet, Boolean runNextBatchInSequence) {
        this.batchType = batchType;
        this.runNextBatchInSequence = runNextBatchInSequence;
        this.invalidAudienceMembersPeopleIdSet = invalidAudienceMembersPeopleIdSet;
    }
	
	public database.querylocator start (Database.BatchableContext bc) {
		String packageName = SimpplrContext.packageName;

  		if ('setupsegment'.equalsIgnoreCase(batchType)) {
  			String segmentColumnName = SimpplrContext.segmentColumnName;
  			
  			if (String.isBlank(segmentColumnName)) {
  				throw new SimpplrException('Segment not enabled or not configured properly.');
  			}
  			
  			query = 'SELECT Id, ' + segmentColumnName + ', Segment_Attribute_Value__c,' + 
  					' Segment_Processing_Required__c, Segment__c, Is_Segment_Manager__c' +
  					' FROM People__c Where User__r.isActive=true AND  User__r.userType=\'Standard\' '; 
  		
  		}else if('updateAudienceMembers'.equalsIgnoreCase(batchType)) {
			query = 'SELECT id, User__c, Segment__c FROM People__c WHERE Segment__c != null AND User__r.IsActive=true ';
			
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
			}
			if(Utility.isApiOnlyUserQueryable()){
				query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			} else {
				query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\')) ';
			}

		} else if('copyorgdatatosegments'.equalsIgnoreCase(batchType)) {
			query = 'SELECT id FROM Segment__c';
			
  		} else if ('excludedUserSyncNotification'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT id, Segment_Attribute_Value__c, Segment__C  FROM People__c' + 
					' WHERE Segment__C=null AND User__r.isActive=true AND ' + 
					' User__r.userType=\'Standard\'';
					
			 if (String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){		
				query = query +	' AND  User__c IN ' +
            		' (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			 }
					
  		} else if ('disableSegmentation'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id, Segment_Attribute_Value__c, Segment_Processing_Required__c, Segment__c,' 
  					 + ' Is_Segment_Manager__c FROM People__c WHERE Is_Deleted__c = false';
  		
  		} else if ('removeSubscription'.equalsIgnoreCase(batchType)) {
			query = 'SELECT Id FROM Subscription__c WHERE Audience__r.Segment__c IN :segmentIdToRemoveSet';
			
		} else if ('removeNewsletter'.equalsIgnoreCase(batchType)) {
			query = 'SELECT Id FROM Mailer__c WHERE Audience__r.Segment__c IN :segmentIdToRemoveSet';
			
		} else if ('removeAlert'.equalsIgnoreCase(batchType)) {
			query = 'SELECT Id FROM Alert__c WHERE Audience__r.Segment__c IN :segmentIdToRemoveSet';
			
		} else if ('expireSegmentCampaigns'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id FROM Social_Campaign__c WHERE Is_Active__c = true And Audience__r.Segment__c IN :segmentIdToRemoveSet';

  		} else if ('removeAudience'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id FROM Audience__c WHERE Segment__C != null AND Segment__c IN :segmentIdToRemoveSet';
  			
  		} else if ('removeSegmentTilesConfig'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id FROM Tiles_Config__c WHERE Segment__c IN :segmentIdToRemoveSet';
  			
  		} else if ('removeSegmentSites'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id FROM Segment_Site__c WHERE Segment__c IN :segmentIdToRemoveSet';
  			
  		} else if ('removeAppDefaults'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id FROM App_Default__c WHERE Segment__c IN :segmentIdToRemoveSet';
  			
  		} else if ('removeCarouselContent'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id FROM Carousel_Content__c WHERE Segment__c IN :segmentIdToRemoveSet';
  			
  		} else if ('removeSegment'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT Id FROM Segment__c WHERE Id IN :segmentIdToRemoveSet';
  			
  		}
  		 
		return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext bc, sObject[] listOfsObject) {
    	try {
    		List<String> localeList = new List<String>();

	    	if ('setupsegment'.equalsIgnoreCase(batchType)) {
	    		List<People__c> peopleList = (List<People__c>) listOfsObject;
	    		mappingPeopleToSegment(peopleList);
	    	
			}else if('updateAudienceMembers'.equalsIgnoreCase(batchType)) {
				List<People__c> listOfPeople = (List<People__c>) listOfsObject;
				updateAudienceMembers(listOfPeople);
				
			} else if('copyorgdatatosegments'.equalsIgnoreCase(batchType)){
	    		List<Segment__c> listOfSegments = (List<Segment__c>) listOfsObject;	
	    		copyOrgDataToSegments(listOfSegments);
	    		
	    	} else if ('excludedUserSyncNotification'.equalsIgnoreCase(batchType)) {
				List<People__c> listOfPeople = (List<People__c>) listOfsObject;
				processExcludedUserSyncNotification(listOfPeople);
	    	
	    	} else if ('disableSegmentation'.equalsIgnoreCase(batchType)) {
	    		List<People__c> peopleList = (List<People__c>) listOfsObject;
	    		nullifyPeopleSegmentFields(peopleList);
	    		
	    	} else if ('removeSubscription'.equalsIgnoreCase(batchType)) {
	    		List<Subscription__c> SubscriptionList = (List<Subscription__c>) listOfsObject;
				
				if (!SubscriptionList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(SubscriptionList);
				}
				
			} else if ('removeNewsletter'.equalsIgnoreCase(batchType)) {
	    		List<Mailer__c> mailerList = (List<Mailer__c>) listOfsObject;
				
				if (!mailerList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(mailerList);
				}
				
			} else if ('removeAlert'.equalsIgnoreCase(batchType)) {
	    		List<Alert__c> alertList = (List<Alert__c>) listOfsObject;
				
				if (!alertList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(alertList);
				}
				
			} else if('expireSegmentCampaigns'.equalsIgnoreCase(batchType)){
				List<Social_Campaign__c> socialCampaignList = (List<Social_Campaign__c>) listOfsObject;
				expireSegmentCampaigns(socialCampaignList);

	    	} else if ('removeAudience'.equalsIgnoreCase(batchType)) {
	    		List<Audience__c> audienceList = (List<Audience__c>) listOfsObject;
				
				if (!audienceList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(audienceList);
				}
					
	    	} else if('removeSegmentTilesConfig'.equalsIgnoreCase(batchType)){
	    		List<Tiles_Config__c> segmentTilesConfigList = (List<Tiles_Config__c>) listOfsObject;
				
				if (!segmentTilesConfigList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(segmentTilesConfigList);
				}
	    	} else if('removeSegmentSites'.equalsIgnoreCase(batchType)){
	    		List<Segment_Site__c> segmentSiteList = (List<Segment_Site__c>) listOfsObject;
				
				if (!segmentSiteList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(segmentSiteList);
				}
	    	} else if('removeAppDefaults'.equalsIgnoreCase(batchType)){
	    		List<App_Default__c> segmentAppDefaultList = (List<App_Default__c>) listOfsObject;
				
				if (!segmentAppDefaultList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(segmentAppDefaultList);
				}
	    	} else if ('removeCarouselContent'.equalsIgnoreCase(batchType)) {
	  			List<Carousel_Content__c> carousalContentList = (List<Carousel_Content__c>) listOfsObject;
				
				if (!carousalContentList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(carousalContentList);
				}
	  			
	  		} else if ('removeSegment'.equalsIgnoreCase(batchType)) {
	    		List<Segment__c> segmentList = (List<Segment__c>) listOfsObject;
				
				if (!segmentList.isEmpty()) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(segmentList);
				}
				
	    	}
	    	
    	} catch (Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }
    
    public void finish (Database.BatchableContext bc) {
		AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, 
				CreatedBy.Email, ExtendedStatus 
				FROM AsyncApexJob 
				WHERE Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		
		if (currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
			
		} else {
			Utility.sendBatchFailedExceptionEmail('BatchProcessSegment.' + batchType, exceptionDetailsObj);
		}
		
		if (canStartNextBatch) {
		   
			if (runNextBatchInSequence) {
		    	
		    	if('setupsegment'.equalsIgnoreCase(batchType)){
					BatchProcessSegment job = new BatchProcessSegment('updateAudienceMembers', runNextBatchInSequence, null);
    				Database.executeBatch(job, 10);
    						    		
		    	} else if('updateAudienceMembers'.equalsIgnoreCase(batchType)){
		    		BatchProcessSegment job = new BatchProcessSegment('copyOrgDataToSegments', invalidAudienceMembersPeopleIdSet, runNextBatchInSequence);
    				Database.executeBatch(job, 200);
    						    		
		    	} else if('copyOrgDataToSegments'.equalsIgnoreCase(batchType)){
		    		BatchPushDataForExternalSearch failedTransactionJob = new BatchPushDataForExternalSearch('FailedTransactions', false);
		    		Database.executeBatch(failedTransactionJob, 50);

		    		markMaintenanceComplete();
		    	} else if ('disableSegmentation'.equalsIgnoreCase(batchType)) {
		    		BatchProcessSegment job = new BatchProcessSegment('removeSubscription', runNextBatchInSequence, this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
		    	
		    	} else if ('removeSubscription'.equalsIgnoreCase(batchType)) {
		    		BatchProcessSegment job = new BatchProcessSegment('removeNewsletter', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
    				
		    	} else if ('removeNewsletter'.equalsIgnoreCase(batchType)) {
		    		BatchProcessSegment job = new BatchProcessSegment('removeAlert', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
    				
		    	} else if ('removeAlert'.equalsIgnoreCase(batchType)) {
		    		BatchProcessSegment job = new BatchProcessSegment('expireSegmentCampaigns', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
    				
		    	} else if ('expireSegmentCampaigns'.equalsIgnoreCase(batchType)) {
		    		BatchProcessSegment job = new BatchProcessSegment('removeAudience', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
		    	
		    	} else if ('removeAudience'.equalsIgnoreCase(batchType)) {
		    		BatchProcessSegment job = new BatchProcessSegment('removeSegmentTilesConfig', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
    				
		    	} else if ('removeSegmentTilesConfig'.equalsIgnoreCase(batchType)) {
		  			BatchProcessSegment job = new BatchProcessSegment('removeSegmentSites', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
		  			
		  		} else if ('removeSegmentSites'.equalsIgnoreCase(batchType)) {
		  			BatchProcessSegment job = new BatchProcessSegment('removeAppDefaults', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
		  			
		  		} else if ('removeAppDefaults'.equalsIgnoreCase(batchType)) {
		  			BatchProcessSegment job = new BatchProcessSegment('removeCarouselContent', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
		  			
		  		} else if ('removeCarouselContent'.equalsIgnoreCase(batchType)) {
		  			BatchProcessSegment job = new BatchProcessSegment('removeSegment', runNextBatchInSequence ,this.segmentIdToRemoveSet);
    				Database.executeBatch(job, 2000);
		  			
		  		} else if ('removeSegment'.equalsIgnoreCase(batchType)) {
		    		markMaintenanceComplete();
		    	}
		    	
			} else {
				if(invalidAudienceMembersPeopleIdSet != null && !invalidAudienceMembersPeopleIdSet.isEmpty()){
					BatchProcessSegment job = new BatchProcessSegment('updateAudienceMembers', invalidAudienceMembersPeopleIdSet, runNextBatchInSequence);
    				Database.executeBatch(job, 10);
				}
				markMaintenanceComplete();
			}
			
		}
		
		if ('excludedUserSyncNotification'.equalsIgnoreCase(batchType) && countOfpeopleExcludedFromSegments > 0) {
			sendSegmentExcludedUserNotification();
		}
		
    }
    
    private void nullifyPeopleSegmentFields (List<People__c> peopleList) {
		
    	for (People__c peopleObj: peopleList) {
    		peopleObj.Segment_Attribute_Value__c = null;
    		peopleObj.Segment_Processing_Required__c = false;
    		peopleObj.Segment__c = null;
    		peopleObj.Is_Segment_Manager__c = false;
    	}
    	
		if(peopleList.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(peopleList), new List<Schema.SObjectField>{
																	People__c.Segment_Attribute_Value__c,
																	People__c.Segment_Processing_Required__c,
																	People__c.Segment__c,
																	People__c.Is_Segment_Manager__c
																});
		}
    }
    
    private void markMaintenanceComplete() {
			String appConfigQuery = 'select id, Maintenance_Reason__c,Maintenance_In_Progress__c  from App_Config__c limit 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

			appConfig.Maintenance_In_Progress__c = false;
			appConfig.Maintenance_Reason__c = null;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(appConfig, new List<Schema.SObjectField>{
																	App_config__c.Maintenance_In_Progress__c,
																	App_config__c.Maintenance_Reason__c
																});

			if(!Test.isRunningTest()) {
				BatchPushDataForExternalSearch failedTransactionJob = new BatchPushDataForExternalSearch('FailedTransactions', false);
				Database.executeBatch(failedTransactionJob, 50);
			}

			if ('removeSegment'.equalsIgnoreCase(batchType)) {

			} else {
				BatchPushAnalyticsData job = new BatchPushAnalyticsData('segment', true);
				Database.executeBatch(job, 500);
			}
    }
    
    private void mappingPeopleToSegment (List<People__c> listOfPeople) {
		Set<String> setOfSegmentAttrValue = new Set<String>(); 
    	
    	for (People__c peopleObj: listOfPeople) {
    		if(String.isBlank(peopleObj.Segment_Attribute_Value__c)) {
    			peopleObj.Segment__c = null;
    			peopleObj.Is_Segment_Manager__c = false;
    		} else {
    			setOfSegmentAttrValue.add(peopleObj.Segment_Attribute_Value__c.toLowerCase());
    		}
    	}
    	
		
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', SetOfSegmentAttrValue);
		soqlParamMap.put('soqlParam2', segmentIdToRemoveSet);
		String query = 'SELECT id, Attribute_Value__c, Segment__c '
							+ ' FROM Segment_Rule__c '
							+ ' WHERE Attribute_Value__c IN: soqlParam1 And Segment__c !=: soqlParam2';

    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Segment_Rule__c> listOfSegmentRule = (List<Segment_Rule__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
    	Map<String, String> mapOfAtrributeValueAndSegmentId = new Map<String, String>();
    	for (Segment_Rule__c segmentRuleObj: listOfSegmentRule) {
    		mapOfAtrributeValueAndSegmentId.put(segmentRuleObj.Attribute_Value__c.toLowerCase(), 
    				segmentRuleObj.Segment__c);
    	}
    	
    	for (People__c peopleObj: listOfPeople) {
    		if(String.isNotBlank(peopleObj.Segment_Attribute_Value__c)) {
    			String oldSegmentId = peopleObj.Segment__c;
    			String newSegmentId = mapOfAtrributeValueAndSegmentId.get(peopleObj.Segment_Attribute_Value__c.toLowerCase());
				if(String.isNotBlank(oldSegmentId) && !oldSegmentId.equalsIgnoreCase(newSegmentId)){
					invalidAudienceMembersPeopleIdSet.add(peopleObj.Id);
				}
				
				peopleObj.Segment__c = newSegmentId;
				
				if(String.isNotBlank(peopleObj.Segment__c) && 
						(String.valueOf(peopleObj.Segment__c).equalsIgnoreCase(oldSegmentId) == false)) {
					peopleObj.Is_Segment_Manager__c = false;
				}
    		}
    	} 
		
		if(listOfPeople.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(listOfPeople), new List<Schema.SObjectField>{
																	People__c.Segment__c,
																	People__c.Is_Segment_Manager__c
																});
		}
    	
    }
    
    private void copyOrgDataToSegments (List<Segment__c> listOfSegments) {
		createAppDefaultAndTileConfigForSegments(listOfSegments);
		createCarouselContentForSegments(listOfSegments);	
		createFeaturedSitesForSegments(listOfSegments);	
		if(ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode))	 {
			createSegmentDashboardTiles(listOfSegments);
		}
    } 
    
    private void createSegmentDashboardTiles(List<Segment__c> listOfSegments){
		String appConfigQuery = 'Select id, App_Home_Dashboard_Tile_Ids__c, Layout__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfigObj = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);									
		
		if((!listOfAppConfigObj.isEmpty()) && (String.isNotBlank(listOfAppConfigObj[0].App_Home_Dashboard_Tile_Ids__c))){
			List<String> listOfAppHomeTileIds = listOfAppConfigObj[0].App_Home_Dashboard_Tile_Ids__c.split(',');
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', listOfAppHomeTileIds);
			String query = 'SELECT Id, Name__c, Data__c, Is_Manager_Driven__c, Layout_Column__c, Order__c, ' +
				' People__c, Site__c, Type__c, Variant__c FROM Tiles_Config__c ' +
				' WHERE Id IN :soqlParam1 And Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> listOfAppHomeTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
			
			if(!listOfAppHomeTiles.isEmpty()){
				List<Tiles_Config__c> listOfSegmentHomeTilesToInsert = new List<Tiles_Config__c>();
				List<App_Default__c> listOfappDefaultObjToInsert = new List<App_Default__c>();
				Map<String, String> dataStringMap = new Map<String, String>();
				 
				for(Tiles_Config__c tileConfigRec : listOfAppHomeTiles){
					for(Segment__c segmentRec : listOfSegments){
						Tiles_Config__c tileConfigRecToInsert = new Tiles_Config__c();
						tileConfigRecToInsert.Name__c = tileConfigRec.Name__c;
						tileConfigRecToInsert.Data__c = tileConfigRec.Data__c;
						tileConfigRecToInsert.Is_Manager_Driven__c = tileConfigRec.Is_Manager_Driven__c;
						tileConfigRecToInsert.Layout_Column__c = tileConfigRec.Layout_Column__c;
						tileConfigRecToInsert.Order__c = tileConfigRec.Order__c;
						tileConfigRecToInsert.People__c = null;
						tileConfigRecToInsert.Site__c = null;
						tileConfigRecToInsert.Type__c = tileConfigRec.Type__c;
						tileConfigRecToInsert.Variant__c = tileConfigRec.Variant__c;
						tileConfigRecToInsert.Location__c = 'Segment Dashboard';
						tileConfigRecToInsert.Segment__c = segmentRec.Id;
						tileConfigRecToInsert.Variant_Type__c = tileConfigRec.Variant__c+ '_' +tileConfigRec.Type__c;	
						listOfSegmentHomeTilesToInsert.add(tileConfigRecToInsert);
						
						segmentRec.Layout__c = listOfAppConfigObj[0].Layout__c;
					}	
				}
				
				if(!listOfSegmentHomeTilesToInsert.isEmpty()){

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(listOfSegmentHomeTilesToInsert, new List<Schema.SObjectField>{
						Tiles_Config__c.Name__c,
						Tiles_Config__c.Data__c,
						Tiles_Config__c.Is_Manager_Driven__c,
						Tiles_Config__c.Layout_Column__c,
						Tiles_Config__c.Order__c,
						Tiles_Config__c.People__c,
						Tiles_Config__c.Site__c,
						Tiles_Config__c.Type__c,
						Tiles_Config__c.Variant__c,
						Tiles_Config__c.Location__c,
						Tiles_Config__c.Segment__c,
						Tiles_Config__c.Variant_Type__c
					});

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, Segment__c>(listOfSegments), new List<Schema.SObjectField>{
																			Segment__c.Layout__c
																		});
				}
			}																  	   					
		}    	
    } 
    
    private void createAppDefaultAndTileConfigForSegments(List<Segment__c> listOfSegments){
		String query = 'Select id, Data__c, Layout__c,Type__c,Last_Modified_By_People__c From App_Default__c where Segment__c = null And Type__c = \'home-default\' LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfappDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		if((!listOfappDefaultObj.isEmpty()) && (String.isNotBlank(listOfappDefaultObj[0].Data__c))){
			List<String> listOfHomeDefaultTileIds = listOfappDefaultObj[0].Data__c.split(',');
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', listOfHomeDefaultTileIds);
			String queryStr = 'SELECT Id, Name__c, Data__c, Is_Manager_Driven__c, Layout_Column__c, Order__c, ' +
				' People__c, Site__c, Type__c, Variant__c FROM Tiles_Config__c ' +
				' WHERE Id IN :soqlParam1 And Is_Deleted__c = false And Segment__c = null';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> listOfHomeDefaultTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			
			if(!listOfHomeDefaultTiles.isEmpty()){
				List<Tiles_Config__c> listOfHomeDefaultTilesToInsert = new List<Tiles_Config__c>();
				List<App_Default__c> listOfappDefaultObjToInsert = new List<App_Default__c>();
				Map<String, String> dataStringMap = new Map<String, String>();
				 
				for(Tiles_Config__c tileConfigRec : listOfHomeDefaultTiles){
					for(Segment__c segmentRec : listOfSegments){
						Tiles_Config__c tileConfigRecToInsert = new Tiles_Config__c();
						tileConfigRecToInsert.Name__c = tileConfigRec.Name__c;
						tileConfigRecToInsert.Data__c = tileConfigRec.Data__c;
						tileConfigRecToInsert.Is_Manager_Driven__c = tileConfigRec.Is_Manager_Driven__c;
						tileConfigRecToInsert.Layout_Column__c = tileConfigRec.Layout_Column__c;
						tileConfigRecToInsert.Order__c = tileConfigRec.Order__c;
						tileConfigRecToInsert.People__c = null;
						tileConfigRecToInsert.Site__c = null;
						tileConfigRecToInsert.Type__c = tileConfigRec.Type__c;
						tileConfigRecToInsert.Variant__c = tileConfigRec.Variant__c;
						tileConfigRecToInsert.Location__c = 'Home Default';
						tileConfigRecToInsert.Segment__c = segmentRec.Id;	
						tileConfigRecToInsert.Variant_Type__c = tileConfigRec.Variant__c+ '_' +tileConfigRec.Type__c;
						listOfHomeDefaultTilesToInsert.add(tileConfigRecToInsert);
					}	
				}
				
				if(!listOfHomeDefaultTilesToInsert.isEmpty()){

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT); 
					SIMPSFDCAccessControlResults.InsertResults insertResults = SIMPESAPI.accessController().insertAsUser(listOfHomeDefaultTilesToInsert, new List<Schema.SObjectField>{
						Tiles_Config__c.Name__c,
						Tiles_Config__c.Data__c,
						Tiles_Config__c.Is_Manager_Driven__c,
						Tiles_Config__c.Layout_Column__c,
						Tiles_Config__c.Order__c,
						Tiles_Config__c.People__c,
						Tiles_Config__c.Site__c,
						Tiles_Config__c.Type__c,
						Tiles_Config__c.Variant__c,
						Tiles_Config__c.Location__c,
						Tiles_Config__c.Segment__c,
						Tiles_Config__c.Variant_Type__c
					});
					listOfHomeDefaultTilesToInsert = (List<Tiles_Config__c>) insertResults.getInsertedObjects();

					for(Tiles_Config__c tileConfigRec : listOfHomeDefaultTilesToInsert){
						if(dataStringMap.containsKey(tileConfigRec.Segment__c)){
							String dataStringnew = dataStringMap.get(tileConfigRec.Segment__c) + ',' + tileConfigRec.Id;
							dataStringMap.put(tileConfigRec.Segment__c, dataStringnew);	
						} else {
							dataStringMap.put(tileConfigRec.Segment__c, tileConfigRec.Id);	
						}
					}
				}
			
				for(App_Default__c appDefaultRec : listOfappDefaultObj){
					for(Segment__c segmentRec : listOfSegments){
						App_Default__c appDefaultRecToInsert = new App_Default__c();
						appDefaultRecToInsert.Data__c = dataStringMap.get(segmentRec.id);
						appDefaultRecToInsert.Layout__c = appDefaultRec.Layout__c;
						appDefaultRecToInsert.Type__c = appDefaultRec.Type__c;
						appDefaultRecToInsert.Last_Modified_By_People__c = UserContext.peopleId;
						appDefaultRecToInsert.Segment__c = segmentRec.Id;	
						
						listOfappDefaultObjToInsert.add(appDefaultRecToInsert);
					}					
				}
				if(!listOfappDefaultObjToInsert.isEmpty()){

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(listOfappDefaultObjToInsert, new List<Schema.SObjectField>{
						App_Default__c.Data__c,
						App_Default__c.Layout__c,
						App_Default__c.Type__c,
						App_Default__c.Last_Modified_By_People__c,
						App_Default__c.Segment__c
					});
				}			
			}																  	   					
		}    	
    } 
    
    private void createCarouselContentForSegments(List<Segment__c> listOfSegments){
    	List<Carousel_Content__c> listOfcarouselContent = [SELECT Id, Embedly_Response_JSON__c, Item_Type__c, Order__c, Simpplr_Content__c, Social_Campaign__c
    													  FROM Carousel_Content__c Where Segment__c = null AND Site__c = null AND Is_Deleted__c = false];
    													  
		if(!listOfcarouselContent.isEmpty()){
			List<Carousel_Content__c> listOfcarouselContentToInsert = new List<Carousel_Content__c>();
			for(Carousel_Content__c carouselContentRec : listOfcarouselContent){
				for(Segment__c segmentRec : listOfSegments){
					Carousel_Content__c carouselContentRecToInsert = new Carousel_Content__c();	
					carouselContentRecToInsert.Embedly_Response_JSON__c = carouselContentRec.Embedly_Response_JSON__c;
					carouselContentRecToInsert.Item_Type__c = carouselContentRec.Item_Type__c;
					carouselContentRecToInsert.Order__c = carouselContentRec.Order__c;
					carouselContentRecToInsert.Simpplr_Content__c = carouselContentRec.Simpplr_Content__c;
					carouselContentRecToInsert.Social_Campaign__c = carouselContentRec.Social_Campaign__c;
					carouselContentRecToInsert.Segment__c = segmentRec.Id;							
			
					listOfcarouselContentToInsert.add(carouselContentRecToInsert);
				}
			}
			if(!listOfcarouselContentToInsert.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    				SIMPESAPI.accessController().insertAsUser(listOfcarouselContentToInsert, new List<Schema.SObjectField> { 
    																								Carousel_Content__c.Embedly_Response_JSON__c,
    																								Carousel_Content__c.Item_Type__c,
    																								Carousel_Content__c.Order__c,
    																								Carousel_Content__c.Simpplr_Content__c,
    																								Carousel_Content__c.Social_Campaign__c,
    																								Carousel_Content__c.Segment__c});	
			}			
		}    													  	
    }
	
	public Boolean updateAudienceMembers(List<People__c> peopleList) {
		String packageName = SimpplrContext.packageName;
		Map<String, Audience__c> mapOfSegmentIdAndAudience = getMapOfSegmentIdAndSegmentDefaultAudience();
		
		deleteInvalidAudienceMembers(invalidAudienceMembersPeopleIdSet);
		insertNewAudienceMembers(peopleList, mapOfSegmentIdAndAudience);
		invalidAudienceMembersPeopleIdSet=null;
		return true;
	}

	private void deleteInvalidAudienceMembers(Set<String> invalidAudienceMembersPeopleIdSet) {
		// Deleting invalid audience members
		if(invalidAudienceMembersPeopleIdSet != null && !invalidAudienceMembersPeopleIdSet.isEmpty()){
            List<Audience_Member__c> invalidAudienceMembers = [SELECT Id FROM Audience_Member__c 
                                                                WHERE Audience__r.Segment__c != null
                                                                AND People__c IN :invalidAudienceMembersPeopleIdSet];
            
            if(!invalidAudienceMembers.isEmpty()){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(invalidAudienceMembers);
            }
        }
	}

	private void insertNewAudienceMembers(List<People__c> peopleList, Map<String, Audience__c> mapOfSegmentIdAndAudience){
    	List<Audience_Member__c> newAudienceMemberList = new List<Audience_Member__c>();
    	for (People__c peopleObj : peopleList){
			if(runNextBatchInSequence){
				if(mapOfSegmentIdAndAudience.containsKey(peopleObj.Segment__c)) {
					String audienceId = ((Audience__c)mapOfSegmentIdAndAudience.get(peopleObj.Segment__c)).Id;
					Audience_Member__c audienceMember = new Audience_Member__c(
															Audience__c = audienceId,
															Is_All_Subscription_Required__c = true,
															People__c = peopleObj.Id,
															User__c = peopleObj.User__c);
					
					newAudienceMemberList.add(audienceMember);
				}
			}else{
				if(mapOfSegmentIdAndAudience.containsKey(peopleObj.Segment__c) && invalidAudienceMembersPeopleIdSet.contains(peopleObj.id)) {
					String audienceId = ((Audience__c)mapOfSegmentIdAndAudience.get(peopleObj.Segment__c)).Id;
					Audience_Member__c audienceMember = new Audience_Member__c(
															Audience__c = audienceId,
															Is_All_Subscription_Required__c = true,
															People__c = peopleObj.Id,
															User__c = peopleObj.User__c);
					
					newAudienceMemberList.add(audienceMember);
				}
			}
			
    	}
    	
    	// Add members to audience
		if(!newAudienceMemberList.isEmpty()){
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(newAudienceMemberList, new List<Schema.SObjectField>{
																			Audience_Member__c.Audience__c,
																			Audience_Member__c.Is_All_Subscription_Required__c,
																			Audience_Member__c.People__c,
																			Audience_Member__c.User__c});
    	}
    }
	
	public Map<String, Audience__c> getMapOfSegmentIdAndSegmentDefaultAudience() {
		Map<String, Audience__c> mapOfSegmentIdAndAudience = new Map<String, Audience__c>();

		// this list will be having one record per segment
		List<Audience__c> audienceList = [SELECT Id, Name__c, Audience_Member_Count__c, Segment__c FROM Audience__c 
											WHERE Segment__c != NULL AND Is_Hidden__c = true AND Is_Deleted__c = false];

		for(Audience__c audienceObj : audienceList) {
			mapOfSegmentIdAndAudience.put(audienceObj.Segment__c, audienceObj);
		}

		return mapOfSegmentIdAndAudience;
	}

	
	private void markEarlierAudienceAsDeleted() {
		List<Audience_Member__c> listOfAudienceMember = [SELECT Id FROM Audience_Member__c 
				WHERE Audience__r.Segment__c != NULL AND Audience__r.Is_Hidden__c = true];

		if (!listOfAudienceMember.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfAudienceMember);
		}
		
	}

    private void createFeaturedSitesForSegments(List<Segment__c> listOfSegments){
    	List<Simpplr_Site__c> listOfSites = [SELECT Id, Order__c FROM Simpplr_Site__c WHERE Is_Deleted__c = false AND Is_Featured__c = true];
    	
    	if(!listOfSites.isEmpty()) {
    		List<Segment_Site__c> listOfSegmentSitesToInsert = new List<Segment_Site__c>();
    		for(Simpplr_Site__c siteObj : listOfSites){
    			for(Segment__c segmentRec : listOfSegments){
    				Segment_Site__c segmentSiteRecToInsert = new Segment_Site__c();
    				segmentSiteRecToInsert.Is_Featured__c = true;
    				segmentSiteRecToInsert.Order__c = siteObj.Order__c;
    				segmentSiteRecToInsert.Site__c = siteObj.Id;
    				segmentSiteRecToInsert.Segment__c = segmentRec.Id;
    				
    				listOfSegmentSitesToInsert.add(segmentSiteRecToInsert);	
    			}	
    		}	
    		if(!listOfSegmentSitesToInsert.isEmpty()){

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listOfSegmentSitesToInsert, new List<Schema.SObjectField>{
					Segment_Site__c.Is_Featured__c,
    				Segment_Site__c.Order__c,
    				Segment_Site__c.Site__c,
    				Segment_Site__c.Segment__c
				});
    		}
    	}	
    }     
    
    private void  expireSegmentCampaigns(List<Social_Campaign__c> socialCampaignList) {
    	for(Social_Campaign__c campaignObj : socialCampaignList) {
    		campaignObj.Is_Active__c = false;
    	}

		if(socialCampaignList.isEmpty()){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Social_Campaign__c>(socialCampaignList), new List<Schema.SObjectField>{
																	Social_Campaign__c.Is_Active__c
																});
		}
    }
    private void  processExcludedUserSyncNotification (List<People__c> listOfPeople) {
    	countOfpeopleExcludedFromSegments = countOfpeopleExcludedFromSegments + listOfPeople.size();
    	List<People__C> listOfPeopleWithoutSegmentAttrAndWithoutSegment = new List<People__c>();
		List<People__C> listOfPeopleWithSegmentAttrAndWithoutSegment = new List<People__c>();
		String emailBody ='';
		
		for (People__C peopleObj: listOfPeople) {
			
			if (String.isNotBlank(peopleObj.Segment_Attribute_Value__c)) {
				countOfpeopleWithSegmentAttrAndWithoutSegment ++;
				 
			} else {
				countOfpeopleWithoutSegmentAttrAndWithoutSegment ++;
			}
			
		}
		
    }
    
    private String getSegmentExcludedUserNotificationEmailBody (People__c managerObj) {
    	String emailBody = '';
    	String userLanguage = Utility.getSimpplrLanguageLocaleKey(managerObj.User__r.languagelocalekey);

    	if (countOfpeopleExcludedFromSegments == 1) {
			emailBody = LocaleContext.getLabel(userLanguage, 
					KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_BODY_SINGULAR).replace(
					'{{count}}', String.valueOf(countOfpeopleExcludedFromSegments));
			emailBody = emailBody.replace('{{appName}}', SimpplrContext.applicationName);
			
		} else {
			emailBody = LocaleContext.getLabel(userLanguage, 
					KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_BODY_PLURAL).replace(
					'{{count}}', String.valueOf(countOfpeopleExcludedFromSegments));
			emailBody = emailBody.replace('{{appName}}', SimpplrContext.applicationName);
		}

		FilterService serviceObj = new FilterService();
		Map<String, String> segmentFieldMap = serviceObj.getAudienceAvailableFields();
		String fieldColumnFieldLabel = segmentFieldMap.get(SimpplrContext.segmentColumnName);	
    	
		if (countOfpeopleWithoutSegmentAttrAndWithoutSegment > 0) {
    		emailBody = emailBody.replace('{{segmentValue}}', fieldColumnFieldLabel);
    	}
    	
    	emailBody = emailBody.replace('{{manageAppSegmentsUrl}}', 
				PageContext.getPageURL(Pages.app)+ '?u=/manage/app/segments');
    	return emailBody;
    }
    
    private void sendSegmentExcludedUserNotification () {
    	String plainTextBody = ''; 
    	
    	Messaging.SingleEmailMessage[] listOfEmailToSend = new List<Messaging.SingleEmailMessage> ();
    	List<People__c> listOfAppManager = [SELECT id, User__C, User__r.languagelocalekey  
				FROM People__c 
				WHERE App_Moderation_Permission__c='yes' AND User__r.isActive=true 
				AND User__r.UserType='Standard'];
		List<String> localeList = new List<String>();
		
		for (People__c peopleObj: listOfAppManager) {
			localeList.add(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey));
		}

		LocaleContext.getAllLabelMap('EmailNotifications', localeList);

    	for (People__c managerObj: listOfAppManager) {
    		Messaging.SingleEmailMessage emailMsgObj = new Messaging.SingleEmailMessage(); 
    		String userLanguage = Utility.getSimpplrLanguageLocaleKey(managerObj.User__r.languagelocalekey);

    		if (countOfpeopleExcludedFromSegments == 1) {
    			emailMsgObj.subject = LocaleContext.getLabel(userLanguage, 
						KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_SUBJECT_SINGULAR).replace(
						'{{count}}', String.valueOf(countOfpeopleExcludedFromSegments));
				emailMsgObj.subject = emailMsgObj.subject.replace('{{appName}}', SimpplrContext.applicationName);
						
    		} else {
				emailMsgObj.subject = LocaleContext.getLabel(userLanguage, 
						KEY_EMAIL_NOTIFICATION_SEGMENT_LOCKEDOUT_SUBJECT_PLURAL).replace(
						'{{count}}', String.valueOf(countOfpeopleExcludedFromSegments));
    			emailMsgObj.subject = emailMsgObj.subject.replace('{{appName}}', SimpplrContext.applicationName);
    		}
    		
    		emailMsgObj.plainTextBody = getSegmentExcludedUserNotificationEmailBody(managerObj);
    		emailMsgObj.setTargetObjectId(managerObj.User__C);
    		emailMsgObj.setSaveAsActivity(false);
			listOfEmailToSend.add(emailMsgObj);
    	}
    	
		Messaging.SendEmailResult[] results = Messaging.sendEmail(listOfEmailToSend);
	}
}