/**
 * @description This batch job is used to delete all app notification records prior to the number of months specified.
 */
public class BatchNotificationArchival implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    private static final String BATCH_DELETE_UNGROUPED_NOTIFICATIONS = 'deleteUngroupedNotifications';
    private static final String BATCH_DELETE_NOTIFICATIONS = 'deleteNotifications';
    private static final String BATCH_PUSH_ANALYTICS_NOTFICATION = 'pushAppNotifications';
    private static final String ORGANIZATION_ID = UserInfo.getOrganizationId().subString(0,15);

    private String batchType;
    private Integer numMonths;
    private Boolean runNextBatchInSequence;
    private Exception exceptionDetailsObj;
    private String dateField = Test.isRunningTest() ? 'Created_DateTime__c' : 'CreatedDate';

    /**
     * @description parameterized constructor to execute batch with number of months
     * @param numMonths number of months prior to which all records should be deleted
     */
    public BatchNotificationArchival(String batchType, Boolean runNextBatchInSequence) {
        this.numMonths = SimpplrContext.appConfig.Notification_Archival_Duration_In_Months__c != null ? Integer.valueOf(SimpplrContext.appConfig.Notification_Archival_Duration_In_Months__c) : 6;
        this.batchType = batchType;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }

    /**
     * @description Fetch all notification records older than numMonths
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(BATCH_DELETE_UNGROUPED_NOTIFICATIONS.equals(batchType)) {
            query = 'SELECT Id FROM Ungrouped_Notification__c WHERE ' + this.dateField + ' < LAST_N_MONTHS:' + this.numMonths + ' LIMIT 50000';
        } else if (BATCH_DELETE_NOTIFICATIONS.equals(batchType)) {
            query = 'SELECT Id, (SELECT Id FROM App_Notifications_Parent__r WHERE ' + this.dateField + ' > LAST_N_MONTHS:' + this.numMonths + ') FROM App_Notification__c WHERE ' + this.dateField + ' < LAST_N_MONTHS:' + this.numMonths + ' LIMIT 50000';
        } else if (BATCH_PUSH_ANALYTICS_NOTFICATION.equals(batchType)) {
            query = 'SELECT Id, Is_Read__c, Is_New__c, Is_Grouped__c, Sent_to__c, Parent_Object_Id__c, Object_Id__c, Object_Type__c, Content__c, Sent_By__c, Snippet__c, Status__c, Sub_Type__c, Type__c, Category__c, Created_DateTime__c,' +
            ' Action_Count__c, Action_By__c, Action_Comment__c, Action_On__c, Csv_Download_Request__c, External_Id__c, External_URL__c,' +
            ' GUID__c, Is_Deleted__c, Old_Notification_Id__c, RAB_1__c, RAB_2__c, RAB_3__c, RAB_4__c, RAB_5__c, Simpplr_Site__c, Submitter_Comment__c' +
            ' FROM App_Notification__c WHERE ' + this.dateField + ' = YESTERDAY';
        }
        return Database.getQueryLocator(query);
    }

    /**
     * @description Actual batch execution for deleting the notification records
     * @param bc 
     * @param listOfSObjects 
     */
    public void execute(Database.BatchableContext bc, List<SObject> listOfSObjects) {
        try {
            if(BATCH_DELETE_UNGROUPED_NOTIFICATIONS.equals(batchType)) {
                List<Ungrouped_Notification__c> ungroupedNotificationList = (List<Ungrouped_Notification__c>) listOfSObjects;
                SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);											 
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(ungroupedNotificationList);  
            } else if(BATCH_DELETE_NOTIFICATIONS.equals(batchType)) {
                List<App_Notification__c> appNotifications = (List<App_Notification__c>) listOfSObjects;
                List<App_Notification__c> appNotificationsToDelete = new List<App_Notification__c>();
                for(App_Notification__c appNotification:appNotifications) {
                    if(appNotification.App_Notifications_Parent__r.size() == 0) {
                        appNotificationsToDelete.add(appNotification);
                    }
                }
                delete appNotificationsToDelete;
            } else if(BATCH_PUSH_ANALYTICS_NOTFICATION.equals(batchType)) {
                List<AnalyticsWrapper.AppNotification> notificationWrapperList = new List<AnalyticsWrapper.AppNotification>();
                for (App_Notification__c notification : (List<App_Notification__c>) listOfSObjects) {
                    AnalyticsWrapper.AppNotification notificationObj = new AnalyticsWrapper.AppNotification();
                    notificationObj.id = ORGANIZATION_ID+notification.Id;
                    notificationObj.is_read = notification.Is_Read__c;
                    notificationObj.is_new = notification.Is_New__c;
                    notificationObj.is_grouped = notification.Is_Grouped__c;
                    notificationObj.type = notification.Type__c;
                    notificationObj.category = notification.Category__c;
                    notificationObj.sub_type = notification.Sub_Type__c;
                    notificationObj.status = notification.Status__c;
                    notificationObj.sent_to = notification.Sent_to__c;
                    notificationObj.parent_object_id = notification.Parent_Object_Id__c;
                    notificationObj.object_id = notification.Object_Id__c;
                    notificationObj.object_type = notification.Object_Type__c;
                    notificationObj.content = notification.Content__c;
                    notificationObj.sent_by = notification.Sent_By__c;
                    notificationObj.snippet = notification.Snippet__c;
                    notificationObj.created_datetime = notification.Created_DateTime__c;
                    notificationObj.action_count = notification.Action_Count__c != null ? Integer.valueOf(notification.Action_Count__c) : null;
                    notificationObj.action_by = notification.Action_By__c;
                    notificationObj.action_comment = notification.Action_Comment__c;
                    notificationObj.action_on = notification.Action_On__c;
                    notificationObj.csv_download_request = notification.Csv_Download_Request__c;
                    notificationObj.external_id = notification.External_Id__c;
                    notificationObj.external_url = notification.External_URL__c;
                    notificationObj.guid = notification.GUID__c;
                    notificationObj.is_deleted = notification.Is_Deleted__c;
                    notificationObj.old_notification_id = notification.Old_Notification_Id__c;
                    notificationObj.rab_1 = notification.RAB_1__c;
                    notificationObj.rab_2 = notification.RAB_2__c;
                    notificationObj.rab_3 = notification.RAB_3__c;
                    notificationObj.rab_4 = notification.RAB_4__c;
                    notificationObj.rab_5 = notification.RAB_5__c;
                    notificationObj.site_id = notification.Simpplr_Site__c;
                    notificationObj.submitter_comment = notification.Submitter_Comment__c;
                    notificationObj.record_id = notification.Id;
                    notificationObj.org_id = ORGANIZATION_ID;
                    notificationWrapperList.add(notificationObj);
                }
                sendDataToAWS('app_notifications', notificationWrapperList);
            }
        } catch(Exception ex) {
            exceptionDetailsObj =  ex;
    		throw ex;
        }
    }

    /**
     * @description Batch finish method for running batch in sequence base on batch type
     * @param bc 
     */
    public void finish(Database.BatchableContext bc) {
        runNextBatch(bc, 2000);
    }

    /**
     * @description this method is used to run batch in sequence
     * @param batchType 
     * @param batchSize 
     */
    private void runNextBatch(Database.BatchableContext bc, Integer batchSize) {
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :bc.getJobId()];
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
            List<AggregateResult> arList;
            Integer recordCount;
            if(this.batchType == BATCH_DELETE_UNGROUPED_NOTIFICATIONS) {
            	arList = (List<AggregateResult>) Database.query('SELECT COUNT(Id) recordCount FROM Ungrouped_Notification__c WHERE ' + this.dateField + ' < LAST_N_MONTHS:' + this.numMonths);
                recordCount = Integer.valueOf(arList[0].get('recordCount'));
                if(recordCount != 0) {
                    Database.executeBatch(new BatchNotificationArchival(BATCH_DELETE_UNGROUPED_NOTIFICATIONS, this.runNextBatchInSequence), batchSize);
                } else if(this.runNextBatchInSequence && recordCount == 0) {
                    Database.executeBatch(new BatchNotificationArchival(BATCH_DELETE_NOTIFICATIONS, this.runNextBatchInSequence), batchSize);
                }
            } else if(this.batchType == BATCH_DELETE_NOTIFICATIONS) {
            	arList = (List<AggregateResult>) Database.query('SELECT COUNT(Id) recordCount FROM App_Notification__c WHERE ' + this.dateField + ' < LAST_N_MONTHS:' + this.numMonths);
                recordCount = Integer.valueOf(arList[0].get('recordCount'));
                if(recordCount != 0) {
                    Database.executeBatch(new BatchNotificationArchival(BATCH_DELETE_NOTIFICATIONS, this.runNextBatchInSequence), batchSize);
                }
            }
        } else {
            Utility.sendBatchFailedExceptionEmail('BatchNotificationArchival.' + batchType, exceptionDetailsObj);
        }
    }
    
    private void sendDataToAWS(String recordType, Object[] listOfsObject){
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('orgId', ORGANIZATION_ID);
        requestBody.put('isTest', isTest());
        requestBody.put('objectType', recordType);
        requestBody.put('listObjectViews', listOfsObject);
        String endpoint = 'https://services.simpplr.com/dataprocessor/analytics-data.php?dri=' + Utility.requestAdoptionDataAuthToken();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        req.setBody(Json.serialize(requestBody));
        Http http = new Http();
        HttpResponse res;
        res = http.send(req);
        if(res.getStatusCode() != 200) {
			throw new SimpplrException('Status - ' + res.getStatusCode() + 'received.');     	
        }
    }

    private Integer isTest() {
        Integer isTest = 0;
        if(SimpplrContext.isSandbox || String.isBlank(SimpplrContext.packageName) || SimpplrContext.isTestOrg) {
            isTest = 1;
        }
        return isTest;
    }

}