/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AlertDataServerTest {
    
    private static App_Config__c appConfigRecord;
    private static Alert__c alert;
    private static User standardUserObj;
    private static People__c standardUsersPeopleObj;
    private static User managerUserObj;
    
    @testSetup static void setup() {
       appConfigRecord = TestHelper.setupAppConfig();
        People__c peopleRec = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());

        managerUserObj = TestHelper.createUser('AlertDataServerTest_Simpplr_mngr', null, false); 
		standardUserObj = TestHelper.createUser('AlertDataServerTest_Simpplr_usr', managerUserObj, false); 
		standardUsersPeopleObj = getPeople(standardUserObj.id); 
        
        addPermSet(standardUserObj.id);
         
        CollaborationGroup cg=TestHelper.createCollaborationGroup('AlertDataServerTest_Grp1','Private');
        CollaborationGroupMember cgMember = TestHelper.createCollaborationGroupMember(cg.Id, standardUserObj.id,'Admin');
        Simpplr_Site__c siteObj = TestHelper.getSiteRecord(cg.id);
        Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id);
        Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
        createAlertRecord(standardUsersPeopleObj.Id, Date.today().addDays(2), null,'');
        createAlertRecord(standardUsersPeopleObj.Id, Date.today(), null,'');
        createAlertRecord(standardUsersPeopleObj.Id, Date.today(), siteObj.id,'');
        
        System.assertEquals('AlertDataServerTest_Simpplr_usr',standardUserObj.title, 'Running as Expected');
    }
    
    @future
    private static void addPermSet(String userId) {
        List<PermissionSet> perAssignments = [SELECT Id, Name FROM PermissionSet where Name = 'Simpplr_User' limit 1];
        if(!perAssignments.isEmpty()) {
        	PermissionSetAssignment perSetAssignObj = new PermissionSetAssignment();
            perSetAssignObj.PermissionSetId = perAssignments[0].id;
            perSetAssignObj.AssigneeId = userId;
            insert perSetAssignObj;
    	}
    }
    
    @isTest static void init() {
        
        standardUserObj = [select id from User where lastName='AlertDataServerTest_Simpplr_usr' limit 1];
        standardUsersPeopleObj = getPeople(standardUserObj.id); 
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        String queryStr  = 'select id,Alert_Message__c,Members_Type__c,Alert_Url__c,Author__c,Recipient_Site__c,Seen_Count__c,Is_Expired__c, '
                  + ' Recipient_Site__r.name,Recipient_Site__r.Chatter_Group_Id__c,Recipient_Site__r.Title_Content_Version__c, '
                  + ' Recipient_Site__r.Landing_Page__c,Recipient_Site__r.Site_Type__c, Is_Deleted__c, '
                  + ' Is_Dismissible__c,Recipient_Count__c,Is_Active__c,CreatedDate,LastModifiedDate, '
                  + ' Display_From_DateTime__c,Display_To_DateTime__c,Author__r.User__r.Id, Audience__c,Author__r.User__c, '
                  + ' Author__r.Zoom_Id__c, Author__r.Skype_Id__c,  Is_Scheduled__c, Recipient__c, Audience__r.Name__c, Audience__r.Is_Deleted__c,' 
                  + ' Author__r.Full_Name__c,Author__r.User__r.SmallPhotoUrl from Alert__c limit 1';
        List<Alert__c> alertList = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, null);
        alert = alertList[0];
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AlertDataServer');
        Test.setCurrentPage(pgRef);
        System.assertEquals('AlertTest_testArticleRecord',alert.Alert_Message__c, 'Running as Expected');
    }
    
    private static Alert__c createAlertRecord(String authorId, DateTime fromDateTime, String siteId, String extDistribution) {
    	Alert__c alertObj = new Alert__c(
                            Alert_Message__c='AlertTest_testArticleRecord', 
                            Author__c=authorId, Is_Deleted__c=false, Is_Dismissible__c = false,
                            Is_Link_Alert__c = false, Is_Manually_Expired__c = false,
                            Recipient_Count__c = 0, Display_From_DateTime__c = fromDateTime,
                            Recipient_Site__c=siteId,
                            Display_To_DateTime__c = Date.today().addDays(2),
                            External_Apps_Config_Json__c = extDistribution                                             
                           );
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    	alertObj = (Alert__c)SIMPESAPI.accessController().insertAsUser(alertObj, new List<Schema.SObjectField>{
																			Alert__c.Alert_Message__c,
																			Alert__c.Author__c,
																			Alert__c.Is_Link_Alert__c,
                                                                            Alert__c.Recipient_Count__c,
																			Alert__c.Recipient_Site__c,
                                                                            Alert__c.Is_Deleted__c,
																			Alert__c.Is_Dismissible__c,
																			Alert__c.Is_Manually_Expired__c,
                                                                            Alert__c.Display_From_DateTime__c,
                                                                            Alert__c.Display_To_DateTime__c,
                                                                            Alert__c.External_Apps_Config_Json__c});
        return alertObj;
    }

    @isTest static void testHandleRequestWhenActionNull() {
        init();
        Test.startTest();
        AlertDataServer alertDataServerDSObj= new AlertDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AlertDataServer');
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        alertDataServerDSObj.handleRequest();
        Test.stopTest();
        System.assertEquals('error', alertDataServerDSObj.response.status, 'Running as Expected');
    }
    
    @isTest static void testHandleRequestWhenActionAvailable() {
        init();
        Test.startTest();
        AlertDataServer alertDataServerDSObj= new AlertDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AlertDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','getAlert');
        pageRef.getParameters().put('data',alert.id);
        alertDataServerDSObj.handleRequest();
        System.assertEquals('success', alertDataServerDSObj.response.status, 'Result should have been success');
        
        pageRef.getParameters().put('action','searchAlert');
        pageRef.getParameters().put('data','{}');
        alertDataServerDSObj.handleRequest();
        System.assertEquals('success', alertDataServerDSObj.response.status, 'Result should have been success');
        
        pageRef.getParameters().put('action','create');
        pageRef.getParameters().put('data','{"message":"Test alert","displayFrom":"2021-12-02T18:59:41+10:30","segmentId":null,"isDismissible":true,"membersType":"site_members_and_followers","hasUrl":false,"recipient":"everyone","displayTo":"2021-12-03T18:59:41+10:30"}');
        alertDataServerDSObj.handleRequest();
        System.assertEquals('success', alertDataServerDSObj.response.status, 'Result should have been success');
        
        pageRef.getParameters().put('action','update');
        pageRef.getParameters().put('data','{}');
        alertDataServerDSObj.handleRequest();
        System.assertEquals('error', alertDataServerDSObj.response.status, 'Result should have been error as request data is blank');
        
        pageRef.getParameters().put('action','expireNow');
        pageRef.getParameters().put('data',alert.id);
        alertDataServerDSObj.handleRequest();
        System.assertEquals('success', alertDataServerDSObj.response.status, 'Result should have been success');
        
        pageRef.getParameters().put('action','getActive');
        alertDataServerDSObj.handleRequest();
        System.assertEquals('success', alertDataServerDSObj.response.status, 'Result should have been success');
        
        pageRef.getParameters().put('action','markAsDismissed');
        pageRef.getParameters().put('data',alert.id);
        alertDataServerDSObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success', alertDataServerDSObj.response.status, 'Result should have been success');
        
    }
    
    
   @isTest static void testSearch() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            list<Simpplr_Site__c> siteID = [Select id from Simpplr_site__c];
            ResponseWrapper resp = alertDataServerDSObj.searchAlert('{"filter":"all","term":"abc","recipient":"everyone","pageName":"Alerts","sortBy":"createdNewest","size":16}');
            UserContext.hasModifyAllDataPermission = true;
            alertDataServerDSObj.searchAlert('{"filter":"active","term":"abc","recipient":"everyone","pageName":"Alerts","sortBy":"displayToNewest","size":16}');
            UserContext.isUserAppModerator = true;
            UserContext.hasModifyAllDataPermission = false;
            alertDataServerDSObj.searchAlert('{"filter":"scheduled","term":"abc","recipient":"everyone","pageName":"Alerts","sortBy":"displayFromNewest","size":16}');
            alertDataServerDSObj.searchAlert('{"filter":"expired","term":"abc","recipient":null,"pageName":"Alerts","sortBy":"displayFromNewest","size":16}');
            System.assertEquals('success',alertDataServerDSObj.response.status, 'Running as Expected');
        } 
        Test.stopTest();
    }
    
    
    @isTest static void testGetAlert() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            ResponseWrapper resp = alertDataServerDSObj.getAlert('{"alertId":"'+alert.Id+'"}');
            System.assertEquals('success',alertDataServerDSObj.response.status, 'Running as Expected');
        } 
        Test.stopTest();
    }
    
      @isTest static void testGetListedSitesForAppManagerMap() {
        init();
        Test.startTest();
        AlertDataServer alertDataServerDSObj= new AlertDataServer();
        Map<Id,Simpplr_Site__c> simpplrSiteMap = alertDataServerDSObj.getListedSitesForAppManagerMap();
        System.assertEquals(1,simpplrSiteMap.size(), 'Running as Expected');
        Test.stopTest();
    }
    
    
       @isTest static void testGetAlertListFromQuery() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            Map<String,Object> paramData= new Map<String, Object>{'term'=>'testing','filter'=>'scheduled','recipient'=>null,'sortBy'=>null,'size'=>10,'nextPageToken'=>0};
            Set<Id> siteIdSet = new Set<Id>();
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            List<Alert__c> alc = alertDataServerDSObj.getAlertListFromQuery(paramData,siteIdSet);
            System.assertEquals(0,alc.size(), 'Running as Expected');
        } 
        Test.stopTest();
    } 
      
    
        @isTest static void testGetAlertList() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            UserContext.isUserAppModerator = true;
            String UserId = UserInfo.getUserId();
            Set<Id> s = new Set<Id>(); 
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            List<Alert__c> alertList = alertDataServerDSObj.getAlertList('everyone',UserId,'testing','Display_To_DateTime__c','ASC',16,10,s);
            System.assertEquals(0,alertList.size(), 'Running as Expected');
        } 
        Test.stopTest();
    }
    
        @isTest static void testDisplayNow() {
        init();
        standardUsersPeopleObj = getPeople(standardUserObj.id);
        standardUsersPeopleObj.Microsoft_Teams_User_Id__c = '80f82678-110b-4151-b0d4-7b24f0402bdb';
        standardUsersPeopleObj.Microsoft_Tenant_Id__c = '3c0a0034-da1f-479d-a860-082149bd9a54';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        SIMPESAPI.accessController().updateAsUser(standardUsersPeopleObj, new List<Schema.SObjectField>{
            People__c.Microsoft_Teams_User_Id__c,
            People__c.Microsoft_Tenant_Id__c});
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'microsoftTeamsAlert',false));
        Alert__c alertToDisplay = createAlertRecord(standardUsersPeopleObj.Id, Date.today().addDays(2), null,'{"isMSTeamsPostAlertAsChannel":true,"msTeamsTeamId":"abcabd","msTeamsChannelId":"abcslie","isMSTeamsPostAlertAsDM":true}');
        AlertDataServer alertDataServerDSObj= new AlertDataServer();
        ResponseWrapper resp = alertDataServerDSObj.displayNow(alertToDisplay.Id);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'status should have been success');
    }
    
        @isTest static void testCreateAlert() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'microsoftTeamsAlert',false));
            ResponseWrapper resp = alertDataServerDSObj.createAlert(' {"message":"sxs","site":{},"displayFrom":"2020-01-12T21:55:15-08:00","segmentId":"a0x4T0000005PO3QAM","isDismissible":true,"hasUrl":false,"recipient":"everyone","displayTo":"2020-01-13T21:55:15-08:00","externalDistribution":{"isMSTeamsPostAlertAsChannel":true,"msTeamsTeamId":"abcabd","msTeamsChannelId":"abcslie","isMSTeamsPostAlertAsDM":false}}');
            alertDataServerDSObj.createAlert(' {"message":"sxs","site":{},"displayFrom":"2020-01-12T21:55:15-08:00","segmentId":"a0x4T0000005PO3QAM","isDismissible":true,"hasUrl":false,"recipient":"segment","displayTo":"2020-01-13T21:55:15-08:00","externalDistribution":{"isMSTeamsPostAlertAsChannel":true,"msTeamsTeamId":"abcabd","msTeamsChannelId":"abcslie","isMSTeamsPostAlertAsDM":false}}'); 
            alertDataServerDSObj.createAlert('{');
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            String query = 'Select Id From Simpplr_Site__c where name = \'AlertDataServerTest_Grp1\' Limit 1';
            List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
            siteList[0].Is_Alert_Enabled__c = true;
            SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(siteList),new List<Schema.SObjectField>{Simpplr_Site__c.Is_Alert_Enabled__c});
            query = 'Select Id From Segment__C where Name__c = \'Untitled Segment\'';
            List<Segment__C> segmentList = (List<Segment__C>)SIMPESAPI.accessController().queryAsUSer(query, null);
            PageReference pageRef = Page.DataServerRW;
            pageRef.getParameters().put('target','AlertDataServer');
            pageRef.getParameters().put('action','create');
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('data','{"message":"testAlert","siteId":"'+siteList[0].Id+'","displayFrom":"2020-01-12T21:55:15-08:00","segmentId":"'+segmentList[0].Id+'","isDismissible":true,"hasUrl":false,"recipient":"everyone","displayTo":"2020-01-13T21:55:15-08:00","externalDistribution":{"isMSTeamsPostAlertAsChannel":true,"msTeamsTeamId":"abcabd","msTeamsChannelId":"abcslie","isMSTeamsPostAlertAsDM":false}}');
            alertDataServerDSObj.handleRequest();
            
            pageRef.getParameters().put('data','{"message":"testAlert","durationStart":"immediately", "siteId":null,"displayFrom":"2020-01-12T21:55:15-08:00","segmentId":"'+segmentList[0].Id+'","isDismissible":true,"hasUrl":false,"recipient":"everyone","displayTo":"2020-01-13T21:55:15-08:00","externalDistribution":{"isMSTeamsPostAlertAsChannel":true,"msTeamsTeamId":"abcabd","msTeamsChannelId":"abcslie","isMSTeamsPostAlertAsDM":false}}');
            alertDataServerDSObj.handleRequest();
            
            System.assertEquals('success',resp.status, 'Running as Expected');
        } 
        Test.stopTest();
    }

    @isTest static void testCreateAlertPostInMSTeam() {
        init();
        standardUsersPeopleObj = getPeople(standardUserObj.id);
        standardUsersPeopleObj.Microsoft_Teams_User_Id__c = '80f82678-110b-4151-b0d4-7b24f0402bdb';
        standardUsersPeopleObj.Microsoft_Tenant_Id__c = '3c0a0034-da1f-479d-a860-082149bd9a54';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        SIMPESAPI.accessController().updateAsUser(standardUsersPeopleObj, new List<Schema.SObjectField>{
            People__c.Microsoft_Teams_User_Id__c,
            People__c.Microsoft_Tenant_Id__c});
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AlertDataServer');
        pageRef.getParameters().put('action','create');
        pageRef.getParameters().put('data','{"message":"testAlert","durationStart":"immediately","displayFrom":"2020-01-12T21:55:15-08:00","isDismissible":true,"hasUrl":false,"recipient":"everyone","displayTo":"2020-01-13T21:55:15-08:00","externalDistribution":{"isMSTeamsPostAlertAsChannel":true,"msTeamsTeamId":"abcabd","msTeamsChannelId":"abcslie","isMSTeamsPostAlertAsDM":true}}');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'microsoftTeamsAlert',false));
        AlertDataServer alertDataServerDSObj= new AlertDataServer();
        alertDataServerDSObj.handleRequest();
        System.assertEquals('success',alertDataServerDSObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

        @isTest static void testUpdateAlert() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            Analytics_Alert__c analyticAlertObj = new Analytics_Alert__c();
            analyticAlertObj.Alert__c =alert.id;
            analyticAlertObj.Is_Marked_Dismissed__c = true;
            analyticAlertObj.Is_Deleted__C = false;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		analyticAlertObj = (Analytics_Alert__c)SIMPESAPI.accessController().insertAsUser(analyticAlertObj, new List<Schema.SObjectField>{
																			Analytics_Alert__c.Alert__c,
																			Analytics_Alert__c.Is_Marked_Dismissed__c,
                                                                            Analytics_Alert__c.Is_Deleted__c 
																			});
            AlertDataServer alertDataServerDSObj= new AlertDataServer();  
            standardUsersPeopleObj = getPeople(standardUserObj.id);
            standardUsersPeopleObj.Microsoft_Teams_User_Id__c = '80f82678-110b-4151-b0d4-7b24f0402bdb';
            standardUsersPeopleObj.Microsoft_Tenant_Id__c = '3c0a0034-da1f-479d-a860-082149bd9a54';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
            SIMPESAPI.accessController().updateAsUser(standardUsersPeopleObj, new List<Schema.SObjectField>{
                                                    People__c.Microsoft_Teams_User_Id__c,
                                                    People__c.Microsoft_Tenant_Id__c});
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'microsoftTeamsAlert',false));          
            ResponseWrapper resp = alertDataServerDSObj.updateAlert('{"alertId":"'+ alert.Id + '","itemData":{"isScheduled":true,"message":"Testing Alert","displayTo":"'+DateTime.now().addDays(2)+'","url":"www.google.com","isDismissible":true,"hasUrl":true,"recipient":"all","displayFrom":"'+DateTime.now()+'","externalDistribution":{"isMSTeamsPostAlertAsChannel":true,"msTeamsTeamId":"abcabd","msTeamsChannelId":"abcslie","isMSTeamsPostAlertAsDM":true}}}');
            alertDataServerDSObj.updateAlert('{');
            System.assertEquals('success',resp.status, 'Running as Expected');
        } 
        Test.stopTest();
    }
    
        @isTest static void testExpireNow() {
            init();
            Test.startTest();
            System.runAs(standardUserObj) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
                String query = 'Select Id From Audience__c';
                List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
                alert.Recipient__c = 'segment';
                alert.Audience__c = audienceList[0].Id;
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    			alert = (Alert__c)SIMPESAPI.accessController().updateAsUser(alert, new List<Schema.SObjectField>{
																			Alert__c.Recipient__c,
																			Alert__c.Audience__c
																			});

                AlertDataServer alertDataServerDSObj= new AlertDataServer();
                ResponseWrapper resp = alertDataServerDSObj.expireNow(alert.Id);
                System.assertEquals('success', resp.status, 'status should have been success');
        	} 
            Test.stopTest();
    	}
    
        @isTest static void testMarkAsSeen() {
        init();
        Set<Id> s = new Set<Id>{alert.Id};   
        List<People__c> peopleList = [SELECT Id from People__c WHERE user__c =: UserInfo.getUserId()];    
        Test.startTest();        
        AlertDataServer.markAsSeen(s, peopleList[0].Id);
        Test.stopTest();
        List<Analytics_Alert__c> analyticsAlertList = [SELECT Id FROM Analytics_Alert__c where Alert__c =: alert.Id AND 
                                                        People__c =: peopleList[0].Id];
        System.assertEquals(1, analyticsAlertList.size(), 'Size should have been 1');
    } 
    
          
    
        @isTest static void testDeleteAlert() {
        init();
        Test.startTest();
        Alert__c alertToDelete = createAlertRecord(standardUsersPeopleObj.Id, Date.today().addDays(2), null, '');
        System.runAs(standardUserObj) {
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            ResponseWrapper resp = alertDataServerDSObj.deleteAlert(alertToDelete.Id);
            System.assertEquals('success', resp.status, 'Result should have been success');
        } 
        Test.stopTest();
    }


        @isTest static void testGetActiveAlert() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            ResponseWrapper resp = alertDataServerDSObj.getActiveAlert();
            System.assertEquals('success',resp.status, 'Running as Expected');
        } 
        Test.stopTest();
    }    
    
        @isTest static void testMarkAsDismiss() {
        init();
        Test.startTest();
        System.runAs(standardUserObj) {
            AlertDataServer alertDataServerDSObj= new AlertDataServer();
            ResponseWrapper resp = alertDataServerDSObj.markAsDismiss(alert.Id);
            System.assertEquals('success',resp.status, 'Running as Expected');
        } 
        Test.stopTest();
    }
    
    @isTest static void testObjectToWrapper() {
        init();
        Test.startTest();
        Audience__c audienceObj = [Select Id From Audience__c];
        alert.Recipient__c = 'audience';
        alert.Audience__c = audienceObj.Id;
        alert.External_Apps_Config_Json__c = '{"msTeamsTeamId":"team1ms"}';
        update alert;
        AlertDataServer alertDataServerDSObj= new AlertDataServer();
        AlertWrapper alertWrapperObj = alertDataServerDSObj.objectToWrapper(alert);
        System.assertEquals(false, alertWrapperObj.isDismissible, 'Running as Expected');
        Test.stopTest();
    } 
    
   @isTest static void testBatchUpdateAlertAnalytics() {
        init();
        Test.startTest();
        BatchUpdateAlertAnalytics job = new BatchUpdateAlertAnalytics('ResetMarkAsDismiss', alert.id, new List<String>());
        Database.executeBatch(job,20);
        Test.stopTest();
        List<Analytics_Alert__c> analyticsAlertList = [SELECT Id, Is_Marked_Dismissed__c from Analytics_Alert__c WHERE Alert__c =: alert.id
                                                        AND Is_Marked_Dismissed__c = true];
        System.assertEquals(0, analyticsAlertList.size(), 'Size should be zero');
    }
    
    
    
      
     private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
        							Zoom_Id__c, Skype_Id__c, 
                                    Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                    From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }

}