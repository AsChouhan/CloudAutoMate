/**
 * @description This batch is used to validate all integration on app level
 * This batch check all the app integration and validate for refresh token or access token 
 */
public with sharing class BatchCheckAdminIntegrations implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
	
    private App_Config__c appConfigRecord;
    List<People__c> appManagerList;
    private List<String> removeIntegration;
    private List<String> integrationsRecordsToQuery = new List<String>();
    /*
    After Reconnect stories are done we will include them in above list
        IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR,
        IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE,
        IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC
        IntegrationConstants.INTEGRATION_TYPE_DROPBOX,
        IntegrationConstants.INTEGRATION_TYPE_ADSI,
        IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN,
        IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW
    */

     /**
     * @description consutructor 
     */
    public BatchCheckAdminIntegrations() {
        this.appConfigRecord = getAppConfigRecord();
        this.appManagerList = new PeopleDao().getAppManagerList();
        this.removeIntegration = new List<String>();
    }

    /**
     * @description This is the batch class entry method which returns dynamic record set based on batch type
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public database.querylocator start(Database.BatchableContext bc){
        String orgId = SimpplrContext.simpplrOrgId;
        String query = 'SELECT Id, Name, Scope__c, Scope_Required__c, User_Name__c, User_Email__c, Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c,' +
                        ' DB_User_Client_Id__c, DB_User_Client_Secret__c, App_Access_Token__c, App_Refresh_Token__c, Token_Type__c, Redirect_Uri__c, App_Installed__c,' +
                        ' Access_Token_Requested_Datetime__c, Refresh_Token_Requested_Datetime__c, Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,' +
                        ' Access_Token_Expiry__c,  External_Id__c, Integration_Enabled__c, Connected__c, Is_Deleted__c ,All_Company_Group_Id__c, Batch_Processing__c,' +
                        ' Root_Folder_Id__c, Enterprise_Id__c, Endpoint_Url__c, Data__c, Is_My_Drive_Enabled__c, Simpplr_Managed_Permission__c,' +
                        ' Active_Directory_Groups_Enabled__c, Is_Shared_Drive_Enabled__c, Show_Open_In_Google_Drive__c,Show_Atlassian_VPN_Message__c,' +
                        ' Owner.UserName, Owner.IsActive FROM App_Integration__c WHERE Is_Deleted__c = false AND Name IN :integrationsRecordsToQuery AND Org_Id__c = :orgId';
    	return database.getQueryLocator(query);
    }
    
    /**
     * @description Actual batch execution based on type
     * @param `Database.BatchableContext` bc 
     * @param `List<sObject>` listOfSObjects 
     */
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
        /**
        List<App_Integration__c> appIntegRecList =  (List<App_Integration__c>)listOfsObject;
        List<Email_Log__c> emailLogsList = new List<Email_Log__c>();
        for (App_Integration__c appIntegRecord : appIntegRecList) {
            if (appIntegRecord.Connected__c == true) {
                if (appIntegRecord.Refresh_Token_Expiration_Datetime__c == null) {
                    appIntegRecord.Refresh_Token_Expiration_Datetime__c = isIntegrationRefreshTokenValid(appIntegRecord) ? null : DateTime.now();
                } else {
                    List<Email_Log__c> emails = handleAdminIntegration(appIntegRecord);
                    emailLogsList.addAll(emails);
                }
            }
        }
        if (emailLogsList.size() > 0) {
            saveEmailLogs(emailLogsList);
        }
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntegRecList), new List<Schema.SObjectField>{
            App_Integration__c.App_Refresh_Token__c,
            App_Integration__c.Refresh_Token_Expiration_Datetime__c,
            App_Integration__c.App_Access_Token__c,
            App_Integration__c.Access_Token_Expiry__c,
            App_Integration__c.Access_Token_Expiration_Datetime__c,
            App_Integration__c.Access_Token_Requested_Datetime__c
        });
        */
    }
    
    /**
     * @description Batch finish method for running batch in sequence base on batch type
     * @param bc 
     */
    public void finish(Database.BatchableContext bc) {
        if (appConfigRecord != null) {
            //handleBoxAdminIntegration();
        }

        Database.executeBatch(new BatchDeleteIntegrationRecords(removeIntegration, true),2000);

        // Added to execute nigthly jobs sequentially
        SchedulerSimpplrServices.executeNextJob('checkAdminIntegrations');
    }

    /**
     * @description method to check is google refresh token is valid or not
     * @return `Boolean` true is refresh token is valid
     */
    @TestVisible
    private Boolean isGoogleIntegrationRefreshTokenValid() {
        try {
            String endPoint = SimpplrContext.simpplrAPIEndpoint+'/oauth/google-oauth-manager?action=isRefreshTokenValid';        
            Map<String, Object> requestMap = new Map<String, Object>();
            requestMap.put('orgId', UserInfo.getOrganizationId());
            String requestId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-simpplr-request-id', requestId);
            req.setHeader('simpplr-dri', Utility.getSimpDri());
            req.setMethod('POST');
            req.setTimeout(60000);
            req.setBody(Json.serialize(requestMap));
            Http http = new Http();
            HttpResponse response = http.send(req);
            if(response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (results.containsKey('isRefreshTokenValid')) {
                    return (Boolean)results.get('isRefreshTokenValid');
                }
            }
            return true;
        } catch (Exception ex) {
            throw new EFSException('Google refresh token error on AWS', ex.getMessage());
        }
    }

    /**
     * @description method to check integration refresh token and send email to app manager
     * @param `App_Integration__c` appIntegRecord
     * @return `List<Email_Log__c>` list of email records sent to app managers
     */
    @TestVisible
    private List<Email_Log__c> handleAdminIntegration(App_Integration__c appIntegRecord) {
        if (isTokenExpiredWithInFifteenDays(appIntegRecord.Refresh_Token_Expiration_Datetime__c.date())) {
            Integer noOfDays = 15 - appIntegRecord.Refresh_Token_Expiration_Datetime__c.date().daysBetween(Date.today());
            return NotificationDispatcher.sendMailToReconnectIntegration(appIntegRecord.Name, this.appManagerList, noOfDays);
        } else if (isTokenExpiredAfterFifteenDays(appIntegRecord.Refresh_Token_Expiration_Datetime__c.date())) {
            removeIntegration.add(appIntegRecord.Name);
            appIntegRecord.Refresh_Token_Expiration_Datetime__c = null;
            return NotificationDispatcher.sendInterationDisconnectedEmail(appIntegRecord.Name, this.appManagerList);
        }
        return new List<Email_Log__c>();
    }

    /**
     * @description method to query the app config record
     * @return `App_Config__c` app config record 
     */
    @TestVisible
    private App_Config__c getAppConfigRecord() {
        String query = 'select Id, Box_Enterprise_Id__c, Box_User_Id__c, Box_Username__c, Box_Integration_Enabled__c, '+
                        'Box_Access_Token__c, Box_Refresh_Token__c , Box_Access_Token_Expires_At__c, '+
                        'Box_Refresh_Token_Expires_At__c FROM App_Config__c limit 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<App_Config__c> listOfAppConfigRecords = (List<App_Config__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
        if (listOfAppConfigRecords != null && listOfAppConfigRecords.size() > 0) {
            return listOfAppConfigRecords[0];
        }
        return null;
    }

    /**
     * @description method to check if token is expired in last 15 days
     * @param `Date` refresh token expire date
     * @return `Boolean` true if token expired in last 15 days else false 
     */
    @TestVisible
    private Boolean isTokenExpiredWithInFifteenDays(Date tokenExpireDate) {
        Set<Integer> daysIntervals = new Set<Integer>{3,5,7,10,12,14};
        Date todayDate = Date.today();
        Integer diffOfDays = tokenExpireDate.daysBetween(todayDate);
        return daysIntervals.contains(diffOfDays);
    }

    /**
     * @description method to check if token is expired before 15 days
     * @param `Date` refresh token expire date
     * @return `Boolean` true if token expired before 15 days else false 
     */
    @TestVisible
    private Boolean isTokenExpiredAfterFifteenDays(Date tokenExpireDate) {
        Date todayDate = Date.today();
        Integer diffOfDays = tokenExpireDate.daysBetween(todayDate);
        return diffOfDays >= 15;
    }
}