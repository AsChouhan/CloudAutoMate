public with sharing class SchedulerSimpplrServices extends SimpplrScheduler {
    
    private static final String USER_CUSTOM_FIELD_SYNC = 'UserCustomFieldSync';
    private static final String PEOPLE_SYNC = 'peopleSync';
    private static final String PEOPLE_LOCATION_NORMALIZATION = 'peopleLocationNormalization';
    private static final String INSERT_SITE_RECORDS  = 'insertSiteRecords';
    private static final String MANAGE_CONTENT_PERMISSION = 'manageContentPermission';
    private static final String VIDEO_CLEANUP_JOB = 'videoCleanupJob';
    private static final String CHECK_ADMIN_INTEGRATIONS = 'checkAdminIntegrations';
    private static final String COMPAIGN_NOTIFICATIONS = 'compaignNotifications';
    private static final String CONTENT_GOVERNANCE = 'contentGovernance';
    private static Map<String, String> userToPeopleFieldMap = new Map<String, String>();
    
    public override void execute(SchedulableContext SC) {
        
        //Notification jobs should run only via schedular not va Run now option.
        if(sc != null) {
			// calling first job of the batch
			executeNextJob('');
        } else {
            executeNextJob(CONTENT_GOVERNANCE);
        }
    }
    
    private static Map<String, String> getUserToPeopleFieldMap() {
        Map<String, String> userToPeopleFieldMap = new Map<String, String>();
        String jsonString = String.isBlank(SimpplrContext.PPUserCustomFields) ? '[]' : SimpplrContext.PPUserCustomFields;
        List<CustomProfileField> customFieldList = (List<CustomProfileField>)
            Json.deserialize(jsonString, Type.forName('List<CustomProfileField>'));
        for(CustomProfileField customField : customFieldList) {
            if(String.isBlank(customField.syncSource)) {
                userToPeopleFieldMap.put('User__r.' + customField.fieldName, customField.columnName);
            }
        }
        return userToPeopleFieldMap;
    }
    
    @future (callout =true)
    private static void initiateUkgProSyncService() {
        try {
            ManageApplicationDao.initiateUkgProSyncService();
            
            // Added to execute nigthly jobs sequentially
            System.enqueueJob(new ExcecuteNextJob('peopleSync'));    
        } catch (Exception ex) {
            // Added to execute nigthly jobs sequentially
            System.enqueueJob(new ExcecuteNextJob('peopleSync'));      
        }
    }
    
    @future (callout =true)
    private static void initiateCsvFileProvSyncService(Boolean callSchedulerAgain) {
        try {
            ManageApplicationDao.initiateCsvFileProvSyncService();
            
            if(callSchedulerAgain) {
                // Added to execute nigthly jobs sequentially
                System.enqueueJob(new ExcecuteNextJob('peopleSync'));
            }
            
        } catch (Exception ex) {
            
            if(callSchedulerAgain) {
                // Added to execute nigthly jobs sequentially
                System.enqueueJob(new ExcecuteNextJob('peopleSync'));  
            }    
        }
    }

    @future (callout = true)
    private static void intiatADPeopleSync() {
        try {
            ActiveDirectoryService.intiateADPeopleSyncJob();
            System.enqueueJob(new ExcecuteNextJob('peopleSync'));   
        } catch (Exception ex) {
            System.enqueueJob(new ExcecuteNextJob('peopleSync'));   
        }
    }
    
	/**
	* @description - method added to execute batches sequentially. This method is called from finish method of the batches
	* @param - String previousBatchType
	*/
    public static void executeNextJob(String previousBatchType) {

		if(previousBatchType == '') {

			Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
			String dayOfWeek = dt.format('EEEE');
			String startOfWeek;
			if (SimpplrContext.StartOfWeek != null) {
				startOfWeek = SimpplrContext.StartOfWeek;
			} else {
				startOfWeek = 'Monday';
			}
            Boolean weeklyJobRunRequired = dayOfWeek.startsWithIgnoreCase(startOfWeek);
            if(SimpplrContext.isEmployeeAdvocacyEnabled) {
                BatchCampaignNotifications notificationJob = new BatchCampaignNotifications('CampaignAnalyticsDataPrepare', weeklyJobRunRequired);
                Database.executeBatch(notificationJob,2000);
            } else {
                previousBatchType = COMPAIGN_NOTIFICATIONS;
            }			
		}
        
        if(previousBatchType.equalsIgnoreCase(COMPAIGN_NOTIFICATIONS)) {
            
            if(SimpplrContext.isContentGovernanceEnabled) {
                BatchContentAutoGovNotifications contentGovernanceJob = new BatchContentAutoGovNotifications('markContentsAsExpired', true, null);
                Database.executeBatch(contentGovernanceJob,20);
            } else {
                previousBatchType = CONTENT_GOVERNANCE;
            }      
        }
        
        if(previousBatchType.equalsIgnoreCase(CONTENT_GOVERNANCE)) {
            
            userToPeopleFieldMap = getUserToPeopleFieldMap();
            if(!userToPeopleFieldMap.isEmpty()) {
                BatchSfdcUserDataSync job = new BatchSfdcUserDataSync('UserCustomFieldSync', userToPeopleFieldMap);
                Database.executeBatch(job, 500); 
            } else {
                previousBatchType = USER_CUSTOM_FIELD_SYNC;
            }      
        }
        
        if(previousBatchType.equalsIgnoreCase(USER_CUSTOM_FIELD_SYNC)) {
            //Start People Data Sync batch
            if('Salesforce'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) { 
                BatchSfdcUserDataSync job = new BatchSfdcUserDataSync();
                Database.executeBatch(job, 200);   
                
            } else if('Workday'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {
                String workDayUrl = SimpplrContext.PDSWorkdayEndpoint;
                if(workDayUrl.endsWithIgnoreCase('usePassthrough=1')){
                    DataBase.executeBatch(new BatchSfdcUserDataSync(0,2));
                } else {
                    Database.executeBatch(new BatchSfdcUserDataSync('WorkdaySyncFromServiceClass'));
                }
            } else if('activedirectory'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {
                if(SimpplrContext.isAdsiIntegrationEnabled) {
                    BatchADAPIUserSync job = new BatchADAPIUserSync('', '50', 'InitialUserSync');
                    Database.executeBatch(job, 1);
                } else if(SimpplrContext.isActiveDirectoryEnabled) {
                    System.enqueueJob(new CallFutureMethodQueuable('intiatADPeopleSync'));
                } else {
                    previousBatchType = PEOPLE_SYNC;
                }
                
            } else if('okta'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {
                BatchOktaUserSync job = new BatchOktaUserSync('syncIdentifier');
                Database.executeBatch(job, 1);
                
            } else if('Google'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {
                BatchGoogleUserSync job = new BatchGoogleUserSync('userSync', true);
                Database.executeBatch(job, 1);
                
            } else if('UkgPro'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {
                System.enqueueJob(new CallFutureMethodQueuable('initiateUkgProSyncService'));
                
            } else if('CsvFile'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {    
                System.enqueueJob(new CallFutureMethodQueuable('initiateCsvFileUserSync'));
            } else {
                previousBatchType = PEOPLE_SYNC;
            }
            
        } 
        
        if(previousBatchType.equalsIgnoreCase(PEOPLE_SYNC)) {
            if(SimpplrContext.locationNormalizationEnabled) {
                BatchPeopleLocationNormalization batchOb = new BatchPeopleLocationNormalization();
                Database.executeBatch(batchOb, 2000);
            } 
            previousBatchType = PEOPLE_LOCATION_NORMALIZATION;
        }
        if(previousBatchType.equalsIgnoreCase(PEOPLE_LOCATION_NORMALIZATION)) {
            
            //Start Site Batch job to create sites if its not present in Simpplr
            BatchInsertSiteRecords job = new BatchInsertSiteRecords(false, true);
            Database.executeBatch(job,200);
            
        } 
        
        if(previousBatchType.equalsIgnoreCase(INSERT_SITE_RECORDS)) {
            
            //Start Content Permissions batch
            BatchManageContentPermissions migrateJob = new BatchManageContentPermissions('UserGroups',true); 
            Database.executeBatch(migrateJob,30);
            
        } 
        
        if(previousBatchType.equalsIgnoreCase(MANAGE_CONTENT_PERMISSION)) {
            
            if(SimpplrContext.isNativeVideo){
                BatchManageVideo videoCleanupJob = new BatchManageVideo('cleanupOrphanNativeVideos');
                Database.executeBatch(videoCleanupJob, 500);
            } else {
                previousBatchType = VIDEO_CLEANUP_JOB;
            }
            
        } 
        
        if(previousBatchType.equalsIgnoreCase(VIDEO_CLEANUP_JOB)) {
            
            BatchCheckAdminIntegrations syncJob = new BatchCheckAdminIntegrations();
            Database.executeBatch(syncJob, 25);
            
        } 
        
        if(previousBatchType.equalsIgnoreCase(CHECK_ADMIN_INTEGRATIONS)) {
            
            if(!'CsvFile'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {
                String query = 'SELECT Id, Provisioning_Source__c ' +
                    ' FROM User_Provisioning_Config__c LIMIT 1';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<User_Provisioning_Config__c> listOfUserProvisionConfig = (List<User_Provisioning_Config__c>)SIMPESAPI.accessController().queryAsUser(query, null);
                
                String userProvisioning;
                if(!listOfUserProvisionConfig.isEmpty()) {
                    userProvisioning = listOfUserProvisionConfig[0].Provisioning_Source__c;
                }
                if('CsvFile'.equalsIgnoreCase(userProvisioning)) {
                    System.enqueueJob(new CallFutureMethodQueuable('initiateCsvFileUserProv'));
                }
            }
            
            if(SimpplrContext.appConfig.Auto_Free_Simpplr_License_Enabled__c) {
                String packageName = SimpplrContext.packageName;
                List<User> inActiveUserList = [select id, name from user where isactive = false and usertype='Standard' 
                                               and id IN (select userid from UserPackageLicense 
                                                          Where PackageLicense.NamespacePrefix =:packageName) WITH SECURITY_ENFORCED];
                if (inActiveUserList.size () > 0) {        
                    List<UserPackageLicense> uplList = new List<UserPackageLicense> ([select id, PackageLicenseid, Userid 
                                                                                      from UserPackageLicense 
                                                                                      where PackageLicense.NamespacePrefix =:packageName
                                                                                      AND userId IN : inActiveUserList WITH SECURITY_ENFORCED]);
                    if (uplList.size () > 0) {
                        SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        SIMPESAPI.accessController().deleteAsUser(uplList);
                    }
                }
            }

            if(SimpplrContext.isExternalDataSyncEnabled && SimpplrContext.isFlowExternalSyncEnabled == false) {
                System.enqueueJob(new CallFutureMethodQueuable('cdcHistoricalMigration'));
            }
            
        }
    }

	/**
	* @description - CallFutureMethodQueuable class to call future methods
	*/		
    public class CallFutureMethodQueuable implements System.Queueable {

        public String futureMethod = '';
		/**
		* @description - constructor for CallFutureMethodQueuable
		* @param - String futureMethod
		*/
        public CallFutureMethodQueuable(String futureMethod) {
            this.futureMethod = futureMethod;
        }        
		/**
		* @desciption - method to call future method
		*/
        public void execute(System.QueueableContext ctx) { 
            
            if(futureMethod.equalsIgnoreCase('initiateUkgProSyncService')) {
                initiateUkgProSyncService();

            } else if(futureMethod.equalsIgnoreCase('initiateCsvFileUserSync')) {
                initiateCsvFileProvSyncService(true);

            } else if(futureMethod.equalsIgnoreCase('initiateCsvFileUserProv')) {
                initiateCsvFileProvSyncService(false);

            } else if(futureMethod.equalsIgnoreCase('intiatADPeopleSync')) {
                intiatADPeopleSync();
            }
            else if(futureMethod.equalsIgnoreCase('cdcHistoricalMigration')) {
                cdcHistoricalMigration();
            }
        }  
    }    
    
	/**
	* @description - ExcecuteNextJob Queueable class to call executeNextJob method
	*/		
    public class ExcecuteNextJob implements System.Queueable {
        
        public String previousBatchType = '';
		/**
		* @description - constructor for ExcecuteNextJob
		* @param - String previousBatchType
		*/
        public ExcecuteNextJob(String previousBatchType) {
            this.previousBatchType = previousBatchType;
        }
		/**
		* @description - method to call executeNextJob method of scheduler
		*/
        public void execute(System.QueueableContext ctx) { 
            executeNextJob(previousBatchType);
        }  
    }
    
    /**
	* @description - method added to call cdc lambda to migrate historical records
	*/
    @future (callout =true)
    private static void cdcHistoricalMigration() {
        ManageApplicationDao.cdcHistoricalMigration();  
    }
    
}