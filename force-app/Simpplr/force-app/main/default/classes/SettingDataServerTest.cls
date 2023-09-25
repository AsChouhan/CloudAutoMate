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
private class SettingDataServerTest {

  private static PageReference pageRef;
	private static App_Config__c appConfigRecord;
  private static App_Integration__c appIntList;
	private static User userObj;
  private static App_Integration__c appintegObj;
	private static People__c peopleRecord;
	
    @testSetup static void setup() {
        appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Box_Integration_Enabled__c = true;
        appConfigRecord.Enterprise_Search_Enabled__c = true;
        appConfigRecord.External_search_active__c = true;
        appConfigRecord.Box_Managed_Permissions__c = 'simpplr';
        appConfigRecord.Logout_Custom_Page_URL__c = 'https://dummy.com/';
        appConfigRecord.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_COMPLETED;
        update appConfigRecord;
        App_Default__c appDefaultObj = TestHelper.setupAppDefault();
        TestHelper.createPeopleRecordForUser(UserContext.id);
        Segment__c segmentRec = TestHelper.createSegment(UserContext.peopleId);
        Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
        userObj = TestHelper.createUser('Simpplr_usr', null, false);
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('Test_Group_SettingDataServerTest','Unlisted');
        Simpplr_Site__c site = [select id,File_Storage_Source__c,chatter_group_Id__c from Simpplr_Site__c where chatter_group_Id__c =: collGrp.id limit 1];
        TestHelper.createSocialCampaign(UserContext.peopleId);
        TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC});
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW,IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN});
		TestHelper.createPeopleIntegrationRecords(appIntegList, UserContext.peopleId, 'asdasd');
    	List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'gdrive', 'dropbox', 'sharepoint', 'onedrive','adsi', 'googledrive', 'googlecalendar', 'activedirectory', 'outlookcalendar'});
        List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, UserContext.peopleId, 'asdasd');
        for(People_Integration__c peopleInt : peopleIntList){
            peopleInt.Domain__c = 'simpplr.com';
        }
        update peopleIntList;
        List<App_Integration__c> appIntegrationObjList = TestHelper.createAppIntegrationRecords(true, new Set<String>{'twitter', 'facebook', 'linkedin'});
        TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, UserContext.peopleId, 'asdasd');
        Folder__c folderObj = TestHelper.createChatterFolder('Box Files', null, site.Id, 'Box', null, 'read');
        folderObj.Is_System_Folder__c = false;
        folderObj.is_deleted__c=false;
        folderObj.people__c = UserContext.PeopleId;
        update folderObj;
        Simpplr_Content__c contentObj = TestHelper.createContent('simpplr test BlogPost', 'BlogPost', 'Approved', userObj, null); 
        Folder__c folderObjGdriveRoot = TestHelper.createChatterFolder('Google Drive Files', null, site.Id, 'googledrive', null, 'read');
        folderObjGdriveRoot.Is_System_Folder__c = true;
        folderObjGdriveRoot.is_deleted__c=false;
        update folderObjGdriveRoot;
        Folder__c folderObjGdriveLinkedFolder = TestHelper.createChatterFolder('Linked folder', null, site.Id, 'googledrive', null, 'read');
        folderObjGdriveLinkedFolder.Is_System_Folder__c = false;
        folderObjGdriveLinkedFolder.is_deleted__c=false;
        folderObjGdriveLinkedFolder.Domain__c='simpplr.com';
        update folderObjGdriveLinkedFolder;
        Folder__c folderObjGdriveLinkedFolder2 = TestHelper.createChatterFolder('Linked folder 2', null, site.Id, 'googledrive', null, 'read');
        folderObjGdriveLinkedFolder2.Is_System_Folder__c = false;
        folderObjGdriveLinkedFolder2.is_deleted__c=false;
        folderObjGdriveLinkedFolder2.Domain__c='simpplr.dev';
        update folderObjGdriveLinkedFolder2;

    }
    private static Simpplr_Site__c getSimpplrSite(){
        Simpplr_Site__c siteObj = [select id,External_Apps_Site_Config_Json__c,Slack_Site_Manager__c,Microsoft_Teams_Site_Manager__c,Is_Must_Read_Enabled__c,File_Storage_Source__c,chatter_group_Id__c from Simpplr_Site__c where name =: 'Test_Group_SettingDataServerTest'];
        siteObj.File_Storage_Source__c = 'gdrive';
        siteObj.Is_Must_Read_Enabled__c = true;
        siteObj.Slack_Channel_Id__c = 'sdlfj8903';
        update siteObj;
        return(siteObj);
    }

    private static People__c getPeopleRecord(String userId) {
        People__c peopleObj = [SELECT Id FROM People__c WHERE User__c =: userId];
        return peopleObj;
    }

    private static void init() {
		  pageRef = Page.DataServerRW;
      pageRef.getParameters().put('target','SettingDataServer');
		  Test.setCurrentPage(pageRef);
    }

    @isTest static void testSlackUpgradePhase2() {
        init();
        Simpplr_Site__c siteObj = getSimpplrSite();
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        List<People_Integration__c> listPeopleInt = TestHelper.createPeopleIntegrationRecords(appInteList, UserContext.peopleId, 'asdasd');
        listPeopleInt[0].Name = 'slackContentShare';
        update listPeopleInt;
        Test.startTest();
        SettingDataServer settingDSObject = new SettingDataServer();
        SimpplrContext.uuid ='adoc1-dlkji4-9238823-dlshfls';
        UserContext.uuid = 'sfjo-3ud9-lsdfji8-87sj';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.startSlackUpgradeFlow();
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testHandleRequestWhenActionNull() {
        init(); 		
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        System.assertEquals('error', settingDSObject.response.status, 'Running as expected');
    } 

    @isTest static void testHandleRequestUserProvisioning(){
        init();
        pageRef.getParameters().put('action','getUserProvisioningConfig');
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','saveUserProvisioningConfig');
        pageRef.getParameters().put('data','{"userTitle" : false,"usernameSuffix" : "","username" : false,"userEmail" : false,"timezoneName" : "","timezoneIso" : "","street" : false,"state" : false,"profileType" : "","queryFilter" : "","profile" : false,"postalCode" : false,"phone" : false,"mobilePhone" : false,"manager" : false,"lastName" : false,"joiningDateField" : "","joiningDate" : false,"firstName" : false,"federationId" : false,"fax" : false,"employeeNumber" : false,"department" : false,"deactiveUsers" : "false","createNewUser" : "false","country" : false,"companyNameField" : "","companyName" : false,"city" : false,"birthDateField" : "","birthDate" : false,"availableProfiles" : [ {  "name" : "Simpplr Profile",  "id" : "00e4T000000MIyhQAG"}, {  "name" : "Minimum Access - Salesforce",  "id" : "00e4T000000MKs9QAG"}, {  "name" : "Identity User",  "id" : "00e4T000000MLaqQAG"}, {  "name" : "Service Cloud",  "id" : "00e4T0000012uzmQAA"}, {  "name" : "Customer Portal Manager",  "id" : "00e4T0000012uznQAA"}, {  "name" : "System Administrator",  "id" : "00e4T0000012uzoQAA"}, {  "name" : "Standard Platform User",  "id" : "00e4T0000012uzrQAA"}, {  "name" : "Partner User",  "id" : "00e4T0000012uzsQAA"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012uztQAA"}, {  "name" : "High Volume Customer Portal",  "id" : "00e4T0000012uzuQAA"}, {  "name" : "Force.com - Free User",  "id" : "00e4T0000012uzvQAA"}, {  "name" : "Chatter Free User",  "id" : "00e4T0000012uzwQAA"}, {  "name" : "Chatter Moderator User",  "id" : "00e4T0000012uzxQAA"}, {  "name" : "External Identity User",  "id" : "00e4T0000012uzyQAA"}, {  "name" : "Company Communities User",  "id" : "00e4T0000012v00QAA"}, {  "name" : "Chatter External User",  "id" : "00e4T0000012v01QAA"}, {  "name" : "Customer Community User",  "id" : "00e4T0000012v02QAA"}, {  "name" : "Customer Community Login User",  "id" : "00e4T0000012v03QAA"}, {  "name" : "Partner Community Login User",  "id" : "00e4T0000012v04QAA"}, {  "name" : "Partner Community User",  "id" : "00e4T0000012v05QAA"}, {  "name" : "Chatter Only User",  "id" : "00e4T0000012v06QAA"}, {  "name" : "Cross Org Data Proxy User",  "id" : "00e4T0000012v07QAA"}, {  "name" : "Work.com Only User",  "id" : "00e4T0000012v08QAA"}, {  "name" : "Customer Portal Manager Custom",  "id" : "00e4T0000012v09QAA"}, {  "name" : "Silver Partner User",  "id" : "00e4T0000012v0AQAQ"}, {  "name" : "High Volume Customer Portal User",  "id" : "00e4T0000012v0BQAQ"}, {  "name" : "Gold Partner User",  "id" : "00e4T0000012v0CQAQ"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012v0DQAQ"}, {  "name" : "Customer Portal Manager Standard",  "id" : "00e4T0000012v0EQAQ"}, {  "name" : "Overage Customer Portal Manager Standard",  "id" : "00e4T0000012v0FQAQ"}, {  "name" : "Overage High Volume Customer Portal User",  "id" : "00e4T0000012v0GQAQ"}, {  "name" : "Overage Customer Portal Manager Custom",  "id" : "00e4T0000012v0HQAQ"}, {  "name" : "Analytics Cloud Security User",  "id" : "00e4T0000012v0IQAQ"}, {  "name" : "Analytics Cloud Integration User",  "id" : "00e4T0000012v0JQAQ"}, {  "name" : "Solution Manager",  "id" : "00e4T0000012v0KQAQ"}, {  "name" : "Read Only",  "id" : "00e4T0000012v0LQAQ"}, {  "name" : "Custom: Sales Profile",  "id" : "00e4T0000012v0MQAQ"}, {  "name" : "Custom: Marketing Profile",  "id" : "00e4T0000012v0NQAQ"}, {  "name" : "Custom: Support Profile",  "id" : "00e4T0000012v0OQAQ"}, {  "name" : "Marketing User",  "id" : "00e4T0000012v0PQAQ"}, {  "name" : "Contract Manager",  "id" : "00e4T0000012v0QQAQ"}, {"name" : "Standard User","id" : "00e4T0000012v0RQAQ"}, {"name" : "Guest License User","id" : "00e4T0000012v0SQAQ"}, {"name" : "Customer Community Plus User","id" : "00e4T0000012v0TQAQ"}, {"name" : "Customer Community Plus Login User","id" : "00e4T0000012v0UQAQ"} ]}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','saveUserProvisioningConfig');
        //createNewUser = true
        pageRef.getParameters().put('data','{"userTitle" : false,"usernameSuffix" : "","username" : false,"userEmail" : false,"timezoneName" : "","timezoneIso" : "","street" : false,"state" : false,"profileType" : "","queryFilter" : "","profile" : false,"postalCode" : false,"phone" : false,"mobilePhone" : false,"manager" : false,"lastName" : false,"joiningDateField" : "","joiningDate" : false,"firstName" : false,"federationId" : false,"fax" : false,"employeeNumber" : false,"department" : false,"deactiveUsers" : "false","createNewUser" : "true","country" : false,"companyNameField" : "","companyName" : false,"city" : false,"birthDateField" : "","birthDate" : false,"availableProfiles" : [ {  "name" : "Simpplr Profile",  "id" : "00e4T000000MIyhQAG"}, {  "name" : "Minimum Access - Salesforce",  "id" : "00e4T000000MKs9QAG"}, {  "name" : "Identity User",  "id" : "00e4T000000MLaqQAG"}, {  "name" : "Service Cloud",  "id" : "00e4T0000012uzmQAA"}, {  "name" : "Customer Portal Manager",  "id" : "00e4T0000012uznQAA"}, {  "name" : "System Administrator",  "id" : "00e4T0000012uzoQAA"}, {  "name" : "Standard Platform User",  "id" : "00e4T0000012uzrQAA"}, {  "name" : "Partner User",  "id" : "00e4T0000012uzsQAA"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012uztQAA"}, {  "name" : "High Volume Customer Portal",  "id" : "00e4T0000012uzuQAA"}, {  "name" : "Force.com - Free User",  "id" : "00e4T0000012uzvQAA"}, {  "name" : "Chatter Free User",  "id" : "00e4T0000012uzwQAA"}, {  "name" : "Chatter Moderator User",  "id" : "00e4T0000012uzxQAA"}, {  "name" : "External Identity User",  "id" : "00e4T0000012uzyQAA"}, {  "name" : "Company Communities User",  "id" : "00e4T0000012v00QAA"}, {  "name" : "Chatter External User",  "id" : "00e4T0000012v01QAA"}, {  "name" : "Customer Community User",  "id" : "00e4T0000012v02QAA"}, {  "name" : "Customer Community Login User",  "id" : "00e4T0000012v03QAA"}, {  "name" : "Partner Community Login User",  "id" : "00e4T0000012v04QAA"}, {  "name" : "Partner Community User",  "id" : "00e4T0000012v05QAA"}, {  "name" : "Chatter Only User",  "id" : "00e4T0000012v06QAA"}, {  "name" : "Cross Org Data Proxy User",  "id" : "00e4T0000012v07QAA"}, {  "name" : "Work.com Only User",  "id" : "00e4T0000012v08QAA"}, {  "name" : "Customer Portal Manager Custom",  "id" : "00e4T0000012v09QAA"}, {  "name" : "Silver Partner User",  "id" : "00e4T0000012v0AQAQ"}, {  "name" : "High Volume Customer Portal User",  "id" : "00e4T0000012v0BQAQ"}, {  "name" : "Gold Partner User",  "id" : "00e4T0000012v0CQAQ"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012v0DQAQ"}, {  "name" : "Customer Portal Manager Standard",  "id" : "00e4T0000012v0EQAQ"}, {  "name" : "Overage Customer Portal Manager Standard",  "id" : "00e4T0000012v0FQAQ"}, {  "name" : "Overage High Volume Customer Portal User",  "id" : "00e4T0000012v0GQAQ"}, {  "name" : "Overage Customer Portal Manager Custom",  "id" : "00e4T0000012v0HQAQ"}, {  "name" : "Analytics Cloud Security User",  "id" : "00e4T0000012v0IQAQ"}, {  "name" : "Analytics Cloud Integration User",  "id" : "00e4T0000012v0JQAQ"}, {  "name" : "Solution Manager",  "id" : "00e4T0000012v0KQAQ"}, {  "name" : "Read Only",  "id" : "00e4T0000012v0LQAQ"}, {  "name" : "Custom: Sales Profile",  "id" : "00e4T0000012v0MQAQ"}, {  "name" : "Custom: Marketing Profile",  "id" : "00e4T0000012v0NQAQ"}, {  "name" : "Custom: Support Profile",  "id" : "00e4T0000012v0OQAQ"}, {  "name" : "Marketing User",  "id" : "00e4T0000012v0PQAQ"}, {  "name" : "Contract Manager",  "id" : "00e4T0000012v0QQAQ"}, {"name" : "Standard User","id" : "00e4T0000012v0RQAQ"}, {"name" : "Guest License User","id" : "00e4T0000012v0SQAQ"}, {"name" : "Customer Community Plus User","id" : "00e4T0000012v0TQAQ"}, {"name" : "Customer Community Plus Login User","id" : "00e4T0000012v0UQAQ"} ]}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
    }

    @isTest static void testSaveUserProvisioningConfigWhenCsvFile(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        init();        
        pageRef.getParameters().put('action','getUserProvisioningConfig');
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','saveUserProvisioningConfig');
        pageRef.getParameters().put('data','{"provisioningSource":"CsvFile", "userTitle" : false,"usernameSuffix" : "","username" : false,"userEmail" : false,"timezoneName" : "","timezoneIso" : "","street" : false,"state" : false,"profileType" : "","queryFilter" : "","profile" : false,"postalCode" : false,"phone" : false,"mobilePhone" : false,"manager" : false,"lastName" : false,"joiningDateField" : "","joiningDate" : false,"firstName" : false,"federationId" : false,"fax" : false,"employeeNumber" : false,"department" : false,"deactiveUsers" : "false","createNewUser" : "false","country" : false,"companyNameField" : "","companyName" : false,"city" : false,"birthDateField" : "","birthDate" : false,"availableProfiles" : [ {  "name" : "Simpplr Profile",  "id" : "00e4T000000MIyhQAG"}, {  "name" : "Minimum Access - Salesforce",  "id" : "00e4T000000MKs9QAG"}, {  "name" : "Identity User",  "id" : "00e4T000000MLaqQAG"}, {  "name" : "Service Cloud",  "id" : "00e4T0000012uzmQAA"}, {  "name" : "Customer Portal Manager",  "id" : "00e4T0000012uznQAA"}, {  "name" : "System Administrator",  "id" : "00e4T0000012uzoQAA"}, {  "name" : "Standard Platform User",  "id" : "00e4T0000012uzrQAA"}, {  "name" : "Partner User",  "id" : "00e4T0000012uzsQAA"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012uztQAA"}, {  "name" : "High Volume Customer Portal",  "id" : "00e4T0000012uzuQAA"}, {  "name" : "Force.com - Free User",  "id" : "00e4T0000012uzvQAA"}, {  "name" : "Chatter Free User",  "id" : "00e4T0000012uzwQAA"}, {  "name" : "Chatter Moderator User",  "id" : "00e4T0000012uzxQAA"}, {  "name" : "External Identity User",  "id" : "00e4T0000012uzyQAA"}, {  "name" : "Company Communities User",  "id" : "00e4T0000012v00QAA"}, {  "name" : "Chatter External User",  "id" : "00e4T0000012v01QAA"}, {  "name" : "Customer Community User",  "id" : "00e4T0000012v02QAA"}, {  "name" : "Customer Community Login User",  "id" : "00e4T0000012v03QAA"}, {  "name" : "Partner Community Login User",  "id" : "00e4T0000012v04QAA"}, {  "name" : "Partner Community User",  "id" : "00e4T0000012v05QAA"}, {  "name" : "Chatter Only User",  "id" : "00e4T0000012v06QAA"}, {  "name" : "Cross Org Data Proxy User",  "id" : "00e4T0000012v07QAA"}, {  "name" : "Work.com Only User",  "id" : "00e4T0000012v08QAA"}, {  "name" : "Customer Portal Manager Custom",  "id" : "00e4T0000012v09QAA"}, {  "name" : "Silver Partner User",  "id" : "00e4T0000012v0AQAQ"}, {  "name" : "High Volume Customer Portal User",  "id" : "00e4T0000012v0BQAQ"}, {  "name" : "Gold Partner User",  "id" : "00e4T0000012v0CQAQ"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012v0DQAQ"}, {  "name" : "Customer Portal Manager Standard",  "id" : "00e4T0000012v0EQAQ"}, {  "name" : "Overage Customer Portal Manager Standard",  "id" : "00e4T0000012v0FQAQ"}, {  "name" : "Overage High Volume Customer Portal User",  "id" : "00e4T0000012v0GQAQ"}, {  "name" : "Overage Customer Portal Manager Custom",  "id" : "00e4T0000012v0HQAQ"}, {  "name" : "Analytics Cloud Security User",  "id" : "00e4T0000012v0IQAQ"}, {  "name" : "Analytics Cloud Integration User",  "id" : "00e4T0000012v0JQAQ"}, {  "name" : "Solution Manager",  "id" : "00e4T0000012v0KQAQ"}, {  "name" : "Read Only",  "id" : "00e4T0000012v0LQAQ"}, {  "name" : "Custom: Sales Profile",  "id" : "00e4T0000012v0MQAQ"}, {  "name" : "Custom: Marketing Profile",  "id" : "00e4T0000012v0NQAQ"}, {  "name" : "Custom: Support Profile",  "id" : "00e4T0000012v0OQAQ"}, {  "name" : "Marketing User",  "id" : "00e4T0000012v0PQAQ"}, {  "name" : "Contract Manager",  "id" : "00e4T0000012v0QQAQ"}, {"name" : "Standard User","id" : "00e4T0000012v0RQAQ"}, {"name" : "Guest License User","id" : "00e4T0000012v0SQAQ"}, {"name" : "Customer Community Plus User","id" : "00e4T0000012v0TQAQ"}, {"name" : "Customer Community Plus Login User","id" : "00e4T0000012v0UQAQ"} ]}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testSaveUserProvisioningConfigWhenCsvFile2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        init();
        SettingDataServer settingDSObject= new SettingDataServer();

        pageRef.getParameters().put('action','saveUserProvisioningConfig');
        pageRef.getParameters().put('data','{"provisioningSource":"CsvFile", "userTitle" : false,"usernameSuffix" : "","username" : false,"userEmail" : false,"timezoneName" : "","timezoneIso" : "","street" : false,"state" : false,"profileType" : "","queryFilter" : "","profile" : false,"postalCode" : false,"phone" : false,"mobilePhone" : false,"manager" : false,"lastName" : false,"joiningDateField" : "","joiningDate" : false,"firstName" : false,"federationId" : false,"fax" : false,"employeeNumber" : false,"department" : false,"deactiveUsers" : "true","createNewUser" : "true","country" : false,"companyNameField" : "","companyName" : false,"city" : false,"birthDateField" : "","birthDate" : false,"availableProfiles" : [ {  "name" : "Simpplr Profile",  "id" : "00e4T000000MIyhQAG"}, {  "name" : "Minimum Access - Salesforce",  "id" : "00e4T000000MKs9QAG"}, {  "name" : "Identity User",  "id" : "00e4T000000MLaqQAG"}, {  "name" : "Service Cloud",  "id" : "00e4T0000012uzmQAA"}, {  "name" : "Customer Portal Manager",  "id" : "00e4T0000012uznQAA"}, {  "name" : "System Administrator",  "id" : "00e4T0000012uzoQAA"}, {  "name" : "Standard Platform User",  "id" : "00e4T0000012uzrQAA"}, {  "name" : "Partner User",  "id" : "00e4T0000012uzsQAA"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012uztQAA"}, {  "name" : "High Volume Customer Portal",  "id" : "00e4T0000012uzuQAA"}, {  "name" : "Force.com - Free User",  "id" : "00e4T0000012uzvQAA"}, {  "name" : "Chatter Free User",  "id" : "00e4T0000012uzwQAA"}, {  "name" : "Chatter Moderator User",  "id" : "00e4T0000012uzxQAA"}, {  "name" : "External Identity User",  "id" : "00e4T0000012uzyQAA"}, {  "name" : "Company Communities User",  "id" : "00e4T0000012v00QAA"}, {  "name" : "Chatter External User",  "id" : "00e4T0000012v01QAA"}, {  "name" : "Customer Community User",  "id" : "00e4T0000012v02QAA"}, {  "name" : "Customer Community Login User",  "id" : "00e4T0000012v03QAA"}, {  "name" : "Partner Community Login User",  "id" : "00e4T0000012v04QAA"}, {  "name" : "Partner Community User",  "id" : "00e4T0000012v05QAA"}, {  "name" : "Chatter Only User",  "id" : "00e4T0000012v06QAA"}, {  "name" : "Cross Org Data Proxy User",  "id" : "00e4T0000012v07QAA"}, {  "name" : "Work.com Only User",  "id" : "00e4T0000012v08QAA"}, {  "name" : "Customer Portal Manager Custom",  "id" : "00e4T0000012v09QAA"}, {  "name" : "Silver Partner User",  "id" : "00e4T0000012v0AQAQ"}, {  "name" : "High Volume Customer Portal User",  "id" : "00e4T0000012v0BQAQ"}, {  "name" : "Gold Partner User",  "id" : "00e4T0000012v0CQAQ"}, {  "name" : "Authenticated Website",  "id" : "00e4T0000012v0DQAQ"}, {  "name" : "Customer Portal Manager Standard",  "id" : "00e4T0000012v0EQAQ"}, {  "name" : "Overage Customer Portal Manager Standard",  "id" : "00e4T0000012v0FQAQ"}, {  "name" : "Overage High Volume Customer Portal User",  "id" : "00e4T0000012v0GQAQ"}, {  "name" : "Overage Customer Portal Manager Custom",  "id" : "00e4T0000012v0HQAQ"}, {  "name" : "Analytics Cloud Security User",  "id" : "00e4T0000012v0IQAQ"}, {  "name" : "Analytics Cloud Integration User",  "id" : "00e4T0000012v0JQAQ"}, {  "name" : "Solution Manager",  "id" : "00e4T0000012v0KQAQ"}, {  "name" : "Read Only",  "id" : "00e4T0000012v0LQAQ"}, {  "name" : "Custom: Sales Profile",  "id" : "00e4T0000012v0MQAQ"}, {  "name" : "Custom: Marketing Profile",  "id" : "00e4T0000012v0NQAQ"}, {  "name" : "Custom: Support Profile",  "id" : "00e4T0000012v0OQAQ"}, {  "name" : "Marketing User",  "id" : "00e4T0000012v0PQAQ"}, {  "name" : "Contract Manager",  "id" : "00e4T0000012v0QQAQ"}, {"name" : "Standard User","id" : "00e4T0000012v0RQAQ"}, {"name" : "Guest License User","id" : "00e4T0000012v0SQAQ"}, {"name" : "Customer Community Plus User","id" : "00e4T0000012v0TQAQ"}, {"name" : "Customer Community Plus Login User","id" : "00e4T0000012v0UQAQ"} ], "languageType":""}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testSaveUserSyncingPeopleConfigWhenCsvFile() {
        Test.startTest();
        init(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveUserSyncingPeopleConfig('{"additionalFields":[{"fieldName":"Salesforce","syncSource":"Simpplr"}],"syncSource":"CsvFile","maxSyncAttempts":"2","firstName":false,"lastName":false,"userTitle":false,"userEmail":false,"communityNickname":false,"aboutMe":false,"employeeNumber":false,"manager":false,"department":false,"userDivision":false,"companyName":false,"street":false,"postalCode":false,"city":false,"state":false,"country":false,"phone":false,"extension":false,"mobilePhone":false,"fax":false,"enableFormatting":false}');
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }

    @isTest static void testSaveUserSyncingPeopleConfigWhenUkgPro() {
        Test.startTest();
        init(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveUserSyncingPeopleConfig('{"additionalFields":[{"fieldName":"Salesforce","syncSource":"Simpplr"}],"syncSource":"UkgPro","maxSyncAttempts":"2","firstName":false,"lastName":false,"userTitle":false,"userEmail":false,"communityNickname":false,"aboutMe":false,"employeeNumber":false,"manager":false,"department":false,"userDivision":false,"companyName":false,"street":false,"postalCode":false,"city":false,"state":false,"country":false,"phone":false,"extension":false,"mobilePhone":false,"fax":false,"enableFormatting":false}');
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }
    
    @isTest static void testlistenerSuiteConfig() {
        Test.startTest();
        init();
        SettingDataServer settingDSObject = new SettingDataServer();
        pageRef.getParameters().put('action','saveListenerSuiteSetupConfig');
        pageRef.getParameters().put('data','{"sentimentCheckControlSites":[{"id":"'+getSimpplrSite().id+'","siteId":"'+getSimpplrSite().id+'"}],"sentimentCheckControlPeople":[{"id":"'+UserContext.peopleId+'","peopleId":"'+UserContext.peopleId+'"}], "surveysControlPeople":[{"id":"'+UserContext.peopleId+'","peopleId":"'+UserContext.peopleId+'"}]}'); 
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getListenerSuiteSetupConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestWhenActionAvailable() {
            init();
        Test.startTest();
        pageRef.getParameters().put('action','getGeneralSetupConfig');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    
        pageRef.getParameters().put('action','getEmailNotificationsSettings');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest(); 
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getSummariesAndDigestSettings');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest(); 
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getLicensingPeopleConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getProfileFieldsPeopleConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
            
        pageRef.getParameters().put('action','getTroubleshootingConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getNavigationSetupConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getDefaultfeedSettings');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getEmailSetupConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getGovernanceSetupConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getPrivilegesConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getUserSyncingPeopleConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getCategoryPeopleConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getAnalyticsEmbedsIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getFilesIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getDomainsIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        pageRef.getParameters().put('action','getMessagingIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getPeopleIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getCalendarIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getSearchIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getSsoIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getSupportIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getCampaignsIntegrationsConfig');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveEmailSetupConfig');
        pageRef.getParameters().put('data','{"usersWhoControlNewsletter":[],"profilesNotReceiveEmails":[],"enableTopStoriesEmails":false,"enableEmail":true,"chatterEmails":"Do Not Change","availableSenders":{"0D24x0000010wCTCAY":"satyam.bhadoria@simpplr.com"}}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveTroubleshootingConfig');
        pageRef.getParameters().put('data','{"user":true,"jsDebugEnabled":true,"feedItem":true,"feedComment":true,"errorStack":true,"debugEnabled":true,"currentSimpplrDomain":"https://satyamdevorg-dev-ed--c.visualforce.com","contentVersion":true,"contentDocument":true,"collaborationGroupMember":true,"collaborationGroup":true}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveLicensingPeopleConfig');
        pageRef.getParameters().put('data','{"autoProvisioningProcessEnabled":false,"autoFreeSimpplrLicenseEnabled":false}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveCategoryPeopleConfig');
        pageRef.getParameters().put('data','{"peopleCategoryUsedForAudience":false,"peopleCategorySingular":"Category","peopleCategoryPlural":"Category","peopleCategoryEnabled":false}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','saveGovernanceSetupConfig');
        pageRef.getParameters().put('data','{"sitesToUploadFiles":[],"siteFilePermission":"sameAsAllUsers","siteDashboardSetup":"Site Manager","siteCarouselEnabled":true,"showTrackChangesFeedPosts":true,"multipleLanguagesEnabled":false,"homeDashboardSetup":"Manager","homeCarouselEnabled":true,"filePermission":"all","feedPlaceholderToggle":"on","feedMode":"timeline_comment_post","expertiseCreateControlledByManager":"true","expertiseControlledByManager":"true","contentSubmissions":true,"contentComments":true,"autoGovValidationPeriod":"P12M","autoGovernanceEnabled":"true","autoConvertChatterGroupToSite":"false","allowFileShareWithPublicLink":false}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveNavigationSetupConfig');
        pageRef.getParameters().put('data','{"singleSignOnIntegration":"none","goToSalesforceEnabled":true,"features":[],"customJson":"[]","appLightningSetting":"newtab","isOrgChartEnabled":true,"externalLinks":[{"url":"https://simpplr.com","onOff":true,"name":"Simpplr","itemOrder":0},{"url":"Example","onOff":true,"name":"https://www.example.com","itemOrder":1},{"url":"https://www.google.com","onOff":true,"name":"Google","itemOrder":2}]}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }

    @isTest static void testHandleRequestWhenActionAvailable2() {
        init();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        SettingDataServer settingDSObject= new SettingDataServer();
        

        pageRef.getParameters().put('action','saveUserSyncingPeopleConfig');
        pageRef.getParameters().put('data','{"userTitle":false,"userRole":false,"userEmail":false,"userDivision":false,"syncSource":"Salesforce","street":false,"state":false,"postalCode":false,"photo":false,"phone":false,"mobilePhone":false,"middleName":false,"manager":false,"lastSyncInfo":{"status":"successful","lastRunAt":"2021-11-24T11:58:22.000+0530"},"lastName":true,"joiningDate":false,"firstName":true,"federationId":false,"fax":false,"extension":false,"enableFormatting":false,"employeeNumber":false,"department":false,"csvSaved":false,"country":false,"companyName":false,"communityNickname":false,"city":false,"birthDate":false,"additionalFields":[],"aboutMe":false}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveProfileFieldsPeopleConfig');
        pageRef.getParameters().put('data','{"videoSynced":false,"videoProvider":"zoom","video":true,"userTitleSynced":false,"userTitle":true,"userCategorySynced":false,"userCategory":false,"timezoneSynced":false,"timezone":true,"streetSynced":false,"street":true,"stateSynced":false,"state":true,"phoneSynced":false,"phone":true,"mobilePhoneSynced":false,"mobilePhone":true,"managerSynced":false,"manager":true,"lastNameSynced":true,"lastName":true,"languageSynced":false,"language":true,"joiningDateSynced":false,"joiningDate":false,"firstNameSynced":true,"firstName":true,"extensionSynced":false,"extension":true,"editableVideo":true,"editableUserTitle":false,"editableUserCategory":false,"editableTimezone":true,"editableStreet":true,"editableState":false,"editablePhone":false,"editableMobilePhone":true,"editableManager":false,"editableLastName":false,"editableLanguage":true,"editableJoiningDate":true,"editableFirstName":false,"editableExtension":false,"editableDivision":true,"editableDepartment":false,"editableCountry":false,"editableCompanyName":false,"editableCity":false,"editableBirthDate":true,"editableAboutMe":true,"divisionSynced":false,"division":true,"departmentSynced":false,"department":true,"countrySynced":false,"country":true,"companyNameSynced":false,"companyName":false,"citySynced":false,"city":true,"birthDateSynced":false,"birthDate":false,"availableFields":{"Title__c":"Title__c","Street__c":"Street__c","State__c":"State__c","PostalCode__c":"PostalCode__c","Phone__c":"Phone__c","MobilePhone__c":"MobilePhone__c","LastName__c":"LastName__c","FirstName__c":"FirstName__c","Fax__c":"Fax__c","Extension__c":"Extension__c","EmployeeNumber__c":"EmployeeNumber__c","Email__c":"Email__c","Division__c":"Division__c","Department__c":"Department__c","Country__c":"Country__c","CompanyName__c":"CompanyName__c","CommunityNickname__c":"CommunityNickname__c","City__c":"City__c","Show_Simpplr__c":"Show_Simpplr__c","MediumBannerPhotoUrl":"MediumBannerPhotoUrl","SmallBannerPhotoUrl":"SmallBannerPhotoUrl","BannerPhotoUrl":"BannerPhotoUrl","DefaultGroupNotificationFrequency":"DefaultGroupNotificationFrequency","DigestFrequency":"DigestFrequency","MediumPhotoUrl":"MediumPhotoUrl","OutOfOfficeMessage":"OutOfOfficeMessage","SmallPhotoUrl":"SmallPhotoUrl","FullPhotoUrl":"FullPhotoUrl","FederationIdentifier":"FederationIdentifier","Extension":"Extension","EmployeeNumber":"EmployeeNumber","LanguageLocaleKey":"LanguageLocaleKey","UserType":"UserType","EmailEncodingKey":"EmailEncodingKey","LocaleSidKey":"LocaleSidKey","BadgeText":"BadgeText","CommunityNickname":"CommunityNickname","Alias":"Alias","Fax":"Fax","StayInTouchNote":"StayInTouchNote","StayInTouchSubject":"StayInTouchSubject","SenderName":"SenderName","SenderEmail":"SenderEmail","Email":"Email","GeocodeAccuracy":"GeocodeAccuracy","PostalCode":"PostalCode","Division":"Division","CompanyName":"CompanyName","Name":"Name","Username":"Username"},"aboutMeSynced":false,"aboutMe":true,"customFields":[]}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','savePrivilegesConfig');
        pageRef.getParameters().put('data','{"unlistedSitesManagingPeopleIdSet":[],"protectedAuthorAllowlisted":[],"protectedAuthor":[],"newsletterControlSite":[],"newsletterControlPeople":[],"mustReadsControlSite":[],"isHomeManagementEnabled":false,"isEmployeeAdvocacyEnabled":false,"influencers":[],"canManageSocialCampaign":[],"canControlHomeDashboard":[],"canControlDashboard":false,"canAccessAlertsPeople":[],"appManagingPeopleIdSet":["'+UserInfo.getUserId()+'"],"analyticsAccess":[],"alertsControlSite":[],"addSitesUserSet":[],"addSitesPermission":"all", "onboardingSitePermission":"allSites"}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveEmailNotificationsSettings');
        pageRef.getParameters().put('data','{"modifiedBy":{"peopleId":"' + UserContext.peopleId + '","name":"Satyam Bhadoria"},"emailUpdatesEventIRsvpYes":true,"emailUpdatesEventIAuthorOrganize":true,"emailUpdatesContentSitesFollow":true,"emailSubscriptionRequest":true,"emailSubscriptionModeration":true,"emailSiteActionableForAppMgr":true,"emailSharesPostMade":true,"emailPrivateSiteMembershipResponse":true,"emailPrivateSiteMembershipRequest":true,"emailPostsToMe":true,"emailNotificationFrequency":"Immediate","emailLikesSharesContentPublished":true,"emailLikesPostOrCommentMade":true,"emailKnowledgeReview":true,"emailKnowledgeExpired":true,"emailForContentUsefulAppMgr":true,"emailForContentUseful":true,"emailFollowsMe":true,"emailEventInviteMore":true,"emailEndorseExpertise":true,"emailContentSubmittedForModeration":true,"emailContentSubmissionResponse":true,"emailContentPromotionMessageForAppMgr":true,"emailContentMarkedAsMustRead":true,"emailCommentsPostMade":true,"emailCommentsPostLike":true,"emailCommentsContentPublished":true,"emailCommentsAfterMe":true,"emailAlerts":true,"allowSimpplrEmails":"enable"}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','saveSummariesAndDigestSettings');
        pageRef.getParameters().put('data','{"topStoriesFrequency":"Daily","siteAnalyticsFrequency":"never","modifiedBy":{"peopleId":"' + UserContext.peopleId + '","name":"Satyam Bhadoria"},"digestFrequency":"Daily"}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','saveDefaultFeedSettings');
        pageRef.getParameters().put('data','{"isProcessing":false,"feedSetting":"news","feedFilter":"activity","appDefaultLastModifiedDate":"Mar 19, 2021","appDefaultLastModifiedByURL":"/apex/app?u=/people/a13000000000000","appDefaultLastModifiedByName":"Satyam Bhadoria"}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveAnalyticsEmbedsIntegrationsConfig');
        pageRef.getParameters().put('data','{"vbrick":false,"googleAnalytics":true,"enableGoogleAnalytics4":true,"enableGoogleAnalytics":true,"analyticsTrackingId4":"123","analyticsTrackingId":"123","analyticsEnhancedLinkAttribution":true,"analyticsDemographicsInterestsReports":false}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveAnalyticsEmbedsIntegrationsConfig');
        pageRef.getParameters().put('data','{"vbrick":false,"googleAnalytics":false,"enableGoogleAnalytics4":false,"enableGoogleAnalytics":true,"analyticsTrackingId4":"123","analyticsTrackingId":"123","analyticsEnhancedLinkAttribution":true,"analyticsDemographicsInterestsReports":false}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        
        pageRef.getParameters().put('action','saveFilesIntegrationsConfig');
        pageRef.getParameters().put('data','{"spUpgradeStatus":"notStartedYet","odIntegrationEnabled":true,"odConnected":true,"googleDriveEnabled":false,"googleDriveConnectedAs":"howard.nelson@simpplr.dev","dropboxEnabled":false,"boxStorage":false,"sharedDriveEnabled":false,"googleManagedPermission":false,"showOpenInGoogleDrive":false,"myDriveEnabled":false,"spIntegrationEnabled":false,"showOpenInSharePoint":false,"sharepointDomainWhitelist": []}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveSearchIntegrationsConfig');
        pageRef.getParameters().put('data','{"enterpriseSearch1":{"isEnabled":true,"provider":"Google","url":"www.https://www.simpplr.com/"},"enterpriseSearch2":{"isEnabled":false,"provider":"yahoo","url":"https://www.simpplr.com/"},"enterpriseSearch3":{"isEnabled":false},"enterpriseSearch4":{"isEnabled":false},"enterpriseSearch5":{"isEnabled":false,"provider":"simpplr","url":"https://www.simpplr.com/"}}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveSsoIntegrationsConfig');
        pageRef.getParameters().put('data','{"oneLoginApiKeySaved":false,"onelogin":false,"oktaUserNameFormat":"10","oktaApiTokenSaved":false,"okta":false,"oktaApiToken":null,"oneLoginApiKey":null}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveCampaignsIntegrationsConfig');
        pageRef.getParameters().put('data','{"twitterEnabled":true,"twitterClientSecret":"secret","twitterClientId":"clientid","employeeAdvocacy":false}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','connectApp');
        pageRef.getParameters().put('data','{"appName":"box"}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','disconnectDropboxAdmin');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();        
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','disconnectApp');
        pageRef.getParameters().put('data','{"appName": "servicenow"}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();       
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','disconnectApp');
        pageRef.getParameters().put('data','{"appName": "dummyappname"}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();        
        System.assertEquals('error', settingDSObject.response.status, 'Should be an error for incorrect app name');
        
        pageRef.getParameters().put('action','getSMSNotificationsSettings');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getNativeMobileAppNotificationsSettings');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getBrowserNotificationsSettings');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveSMSNotificationsSettings');
        pageRef.getParameters().put('data','{"smsContentPromotionMessage":true,"smsContentMarkedAsMustRead":true,"smsAlerts":true}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','saveNativeMobileAppNotificationsSettings');
        pageRef.getParameters().put('data','{"mobileAppUpdatesContentSitesFollow":true,"mobileAppSharesMyPost":true,"mobileAppReplyOnLikedPost":true,"mobileAppReplyAfterMe":true,"mobileAppPrivateSiteMembershipResponse":true,"mobileAppPrivateSiteMembershipRequest":true,"mobileAppPostsToMe":true,"mobileAppLikesPostOrCommentMade":true,"mobileAppLikesOrSharesContentPublished":true,"mobileAppFollowsMe":true,"mobileAppEventInviteMore":true,"mobileAppEndorseExpertise":true,"mobileAppContentSubmittedForModeration":true,"mobileAppContentMarkedAsMustRead":true,"mobileAppContentApprovalRejection":true,"mobileAppCommentsPostMade":true,"mobileAppCommentsContentPublished":true,"mobileAppAlerts":true}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','savePeopleIntegrationsConfig');
        pageRef.getParameters().put('data','{"useActiveDirectoryGroups":"false","workdayPasswordSaved":false,"workday":false,"ukgProPasswordSaved":false,"ukgProApiKeySaved":false,"ukgPro":false,"googleIntegrationEnabled":false,"adIntegrationEnabled":false,"workdayPassword":null,"ukgProPassword":null,"ukgProApiKey":null, "activeDirectoryIntegrationEnabled":true,"isActiveDirectoryGroupsEnabled":false,"autoCreateActiveDirectoryAudience":false,"listOfActiveDirectoryGroupsSelected":[],"listOfActiveDirectoryGroupsRemoved":[]}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','saveBrowserNotificationsSettings');
        pageRef.getParameters().put('data','{"browserUpdatesContentSitesFollow":true,"browserSubscriptionRequest":true,"browserSharesMyPost":true,"browserReplyOnMyPost":true,"browserReplyOnLikedPost":true,"browserReplyAfterMe":true,"browserPrivateSiteMembershipResponse":true,"browserPrivateSiteMembershipRequest":true,"browserPostsToMe":true,"browserMustRead":true,"browserLikesMyPostOrReply":true,"browserFollowsMe":true,"browserEventUpdatesAuthoredOrganized":true,"browserEventUpdatesAttending":true,"browserEventInvite":true,"browserEndorseExpertise":true,"browserContentValidationRequired":true,"browserContentValidationExpired":true,"browserContentSubmittedForModeration":true,"browserContentLikesSharesOnPublished":true,"browserContentFeedback":true,"browserContentCommentsOnPublished":true,"browserContentApprovalRejection":true,"browserAlerts":true}');
        Test.setCurrentPage(pageRef);
        settingDSObject.handleRequest();     
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
        Test.stopTest();
    } 

    @isTest static void testSaveMessagingIntegrationsConfigInsertSlack() { 
        init();
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.slackIntegrationEnabled = true;
        wrapObj.slackConnected = true;
        SimpplrContext.isSlackPhase2FeatureEnabled = false;
        string str = Json.serialize(wrapObj);
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Unable to save messaging config');
    }

    @isTest static void testSaveMessagingIntegrationsConfigSlackPhase2() { 
        init();
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.slackIntegrationEnabled = true;
        wrapObj.slackCustomNameIconEnabled = true;
        wrapObj.slackAppName = 'Simpplr-Slack';
        wrapObj.slackAppIconConfig = '{"url":"https://www.slack.com/icon-image"}';
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
        SimpplrContext.uuid ='adoc1-dlkji4-9238823-dlshfls';
        UserContext.uuid = 'sfjo-3ud9-lsdfji8-87sj';
        string str = Json.serialize(wrapObj);
        Simpplr_Site__c siteObj = getSimpplrSite();
        siteObj.Slack_Site_Manager__c = UserContext.peopleId;
        siteObj.External_Apps_Site_Config_Json__c = '{  "slackSiteConfig" : {    "slackWebUrl" : "https://slack.com/archives/C03U55K5UFQ",    "slackSiteFeedOptions" : [ "slackPosts", "slackPostAndReplies", "slackTimeline" ],    "slackConnectedAs" : "tanviladkani2",    "slackChannelName" : "general",    "slackChannelId" : "C03U55K5UFQ"  ,"slackConnectedUserId" : "U0472JS283W"}}';
        update siteObj;
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/save-slack-enabled',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Unable to save messaging config');
    }
    @isTest static void testSaveMessagingIntegrationsConfigUpdateSlack() { 
        init();
        TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.slackIntegrationEnabled = true;
        wrapObj.slackConnected = true;
        SimpplrContext.isSlackPhase2FeatureEnabled = false;
        string str = Json.serialize(wrapObj);
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Unable to save messaging config');
    }

    @isTest static void testSaveMessagingIntegrationsConfigUpdateSlackPhase2() { 
        init();
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        appInteList[0].Is_Slack_Upgraded__c = true;
        update appInteList;
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.slackIntegrationEnabled = true;
        wrapObj.slackConnected = true;
        wrapObj.slackCustomNameIconEnabled = true;
        wrapObj.slackAppName = 'Simpplr-Slack';
        wrapObj.slackAppIconConfig = '{"url":"https://www.slack.com/icon-image"}';
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
        string str = Json.serialize(wrapObj);
        SimpplrContext.uuid ='adoc1-dlkji4-9238823-dlshfls';
        UserContext.uuid = 'sfjo-3ud9-lsdfji8-87sj';
        Simpplr_Site__c siteObj = getSimpplrSite();
        siteObj.Slack_Site_Manager__c = UserContext.peopleId;
        siteObj.External_Apps_Site_Config_Json__c = '{  "slackSiteConfig" : {    "slackWebUrl" : "https://slack.com/archives/C03U55K5UFQ",    "slackSiteFeedOptions" : [ "slackPosts", "slackPostAndReplies", "slackTimeline" ],    "slackConnectedAs" : "tanviladkani2",    "slackChannelName" : "general",    "slackChannelId" : "C03U55K5UFQ"  ,"slackConnectedUserId" : "U0472JS283W"}}';
        update siteObj;
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Unable to save messaging config');
    }
    
    @isTest static void testSaveMessagingIntegrationsConfigUpdateFalseSlack() { 
        init();
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.slackIntegrationEnabled = false;
        wrapObj.slackConnected = false;
        SimpplrContext.isSlackPhase2FeatureEnabled = false;
        string str = Json.serialize(wrapObj);
        People__c peopleRecord = [SELECT id from People__c where Last_Name__c = 'Simpplr_usr'];
        peopleRecord.Slack_User_Id__c = 'slackUser1';
        peopleRecord.Slack_User_Name__c = 'slackTestUser';
        peopleRecord.Slack_Tenant_Id__c = 'slackTenantId';
        update peopleRecord;
        TestHelper.createPeopleIntegRecordForUser(peopleRecord.id, IntegrationConstants.INTEGRATION_TYPE_SLACK, appInteList[0].id);
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Unable to save messaging config');
    }

    @isTest static void testSaveMessagingIntegrationsConfigUpdateFalseSlackPhase2() { 
        init();
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        appInteList[0].Is_Slack_Upgraded__c = true;
        update appInteList;
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.slackIntegrationEnabled = false;
        wrapObj.slackConnected = false;
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
        SimpplrContext.uuid ='adoc1-dlkji4-9238823-dlshfls';
        UserContext.uuid = 'sfjo-3ud9-lsdfji8-87sj';
        string str = Json.serialize(wrapObj);
        People__c peopleRecord = [SELECT id from People__c where Last_Name__c = 'Simpplr_usr'];
        peopleRecord.Slack_User_Id__c = 'slackUser1';
        peopleRecord.Slack_User_Name__c = 'slackTestUser';
        peopleRecord.Slack_Tenant_Id__c = 'slackTenantId';
        update peopleRecord;
        TestHelper.createPeopleIntegRecordForUser(peopleRecord.id, IntegrationConstants.INTEGRATION_TYPE_SLACK, appInteList[0].id);
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Unable to save messaging config');
    }
    
    @isTest static void testSaveMessagingIntegrationsConfigInsertMSTeams() { 
        init();
        People__c peopleRecord1 = [select id, Microsoft_Tenant_Id__c from people__c limit 1];
        peopleRecord1.Microsoft_Tenant_Id__c = 'dummy';
        update peopleRecord1;
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.microsoftTeamsIntegrationEnabled = true;
        wrapObj.isAlertsForTeamsEnabled = true;
        string str = Json.serialize(wrapObj);
        Simpplr_Site__c siteObj = getSimpplrSite();
        siteObj.Microsoft_Teams_Site_Manager__c = UserContext.peopleId;
        siteObj.External_Apps_Site_Config_Json__c = '{"msTeamsSiteConfig": {  "webUrl" : "https://teams.microsoft.com/l/channel/19%3A18774be2d0b6452cacaa9b679b3e49cc%40thread.tacv2/People%20of%20Simpplr?groupId=4841a72f-9ab7-4e9d-b65f-124cf5e51d1a&tenantId=3c0a0034-da1f-479d-a860-082149bd9a54&allowXTenantAccess=False",  "msTeamsTeamName" : "Simpplr Inc",  "msTeamsTeamId" : "4841a72f-9ab7-4e9d-b65f-124cf5e51d1a",  "msTeamsSiteFeedOptions" : [ "msTeamsPosts", "msTeamsReplies", "msTeamsTimeline" ],  "msTeamsConnectedUserId" : "f94e5a8b-a77d-4ac0-b998-9d13133582be",  "msTeamsChannelName" : "People of Simpplr",  "msTeamsChannelId" : "19:18774be2d0b6452cacaa9b679b3e49cc@thread.tacv2",  "microsoftTeamsConnectedAs" : "Frank Hobert - frank.hobert@simpplr.net"}}';
        update siteObj;
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'unable to insert msteams integrations');
    }
    @isTest static void testSaveMessagingIntegrationsConfigUpdateMSTeams() { 
        init();
        TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS});
        People__c peopleRecord1 = [select id, Microsoft_Tenant_Id__c from people__c limit 1];
        peopleRecord1.Microsoft_Tenant_Id__c = 'dummy';
        update peopleRecord1;
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.microsoftTeamsIntegrationEnabled = true;
        wrapObj.isAlertsForTeamsEnabled = true;
        string str = Json.serialize(wrapObj);
        Simpplr_Site__c siteObj = getSimpplrSite();
        siteObj.Microsoft_Teams_Site_Manager__c = UserContext.peopleId;
        siteObj.External_Apps_Site_Config_Json__c = '{"msTeamsSiteConfig": {  "webUrl" : "https://teams.microsoft.com/l/channel/19%3A18774be2d0b6452cacaa9b679b3e49cc%40thread.tacv2/People%20of%20Simpplr?groupId=4841a72f-9ab7-4e9d-b65f-124cf5e51d1a&tenantId=3c0a0034-da1f-479d-a860-082149bd9a54&allowXTenantAccess=False",  "msTeamsTeamName" : "Simpplr Inc",  "msTeamsTeamId" : "4841a72f-9ab7-4e9d-b65f-124cf5e51d1a",  "msTeamsSiteFeedOptions" : [ "msTeamsPosts", "msTeamsReplies", "msTeamsTimeline" ],  "msTeamsConnectedUserId" : "f94e5a8b-a77d-4ac0-b998-9d13133582be",  "msTeamsChannelName" : "People of Simpplr",  "msTeamsChannelId" : "19:18774be2d0b6452cacaa9b679b3e49cc@thread.tacv2",  "microsoftTeamsConnectedAs" : "Frank Hobert - frank.hobert@simpplr.net"}}';
        update siteObj;
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'unable to update msteams integrations');
    }
    
    @isTest static void testSaveMessagingIntegrationsConfigUpdateFalseMSTeams() { 
        init();
        SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 = true;
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS});
        appInteList[0].Alerts_For_App_Enabled__c = true;
        update appInteList[0];
        People__c peopleRecord1 = [select id, Microsoft_Tenant_Id__c from people__c limit 1];
        peopleRecord1.Microsoft_Tenant_Id__c = 'dummy';
        update peopleRecord1;
        SimpplrContext.uuid = 'sfshfso-sfowf-wdvns-lsdhfos';
        UserContext.uuid = 'vnkhjs-ndfhgao-xnvjsk-shfs';
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.microsoftTeamsIntegrationEnabled = false;
        wrapObj.isAlertsForTeamsEnabled = false;
        string str = Json.serialize(wrapObj);
        Simpplr_Site__c siteObj = getSimpplrSite();
        siteObj.Microsoft_Teams_Site_Manager__c = UserContext.peopleId;
        siteObj.External_Apps_Site_Config_Json__c = '{"msTeamsSiteConfig": {  "webUrl" : "https://teams.microsoft.com/l/channel/19%3A18774be2d0b6452cacaa9b679b3e49cc%40thread.tacv2/People%20of%20Simpplr?groupId=4841a72f-9ab7-4e9d-b65f-124cf5e51d1a&tenantId=3c0a0034-da1f-479d-a860-082149bd9a54&allowXTenantAccess=False",  "msTeamsTeamName" : "Simpplr Inc",  "msTeamsTeamId" : "4841a72f-9ab7-4e9d-b65f-124cf5e51d1a",  "msTeamsSiteFeedOptions" : [ "msTeamsPosts", "msTeamsReplies", "msTeamsTimeline" ],  "msTeamsConnectedUserId" : "f94e5a8b-a77d-4ac0-b998-9d13133582be",  "msTeamsChannelName" : "People of Simpplr",  "msTeamsChannelId" : "19:18774be2d0b6452cacaa9b679b3e49cc@thread.tacv2",  "microsoftTeamsConnectedAs" : "Frank Hobert - frank.hobert@simpplr.net"}}';
        update siteObj;
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.saveMessagingIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'unable to update msteams integrations');
    }

    @isTest static void testEnableFeature() { 
        init();
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        SettingDataServer settingDSObjectObj = new SettingDataServer();
        pageRef.getParameters().put('action','enableFeature');
        pageRef.getParameters().put('name','AI');
        pageRef.getParameters().put('features','AI_Topic_Suggestions,AI_Related_Content');
        Test.setCurrentPage(pageRef);
        settingDSObjectObj.handleRequest();
        System.assertEquals('success', settingDSObjectObj.response.status, settingDSObjectObj.response.message);
        Test.stopTest();
    }

    @isTest static void testDisableFeatureAI() { 
        init();
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        SettingDataServer settingDSObjectObj = new SettingDataServer();
        pageRef.getParameters().put('action','disableFeature');
        pageRef.getParameters().put('name','AI');
        pageRef.getParameters().put('features','AI_Topic_Suggestions,AI_Related_Content');
        Test.setCurrentPage(pageRef);
        settingDSObjectObj.handleRequest();
        System.assertEquals('success', settingDSObjectObj.response.status, settingDSObjectObj.response.message);
        Test.stopTest();
    }

    @isTest static void testDisableFeatureNewsletter() { 
        init();
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        SettingDataServer settingDSObjectObj = new SettingDataServer();
        pageRef.getParameters().put('action','disableFeature');
        pageRef.getParameters().put('name','NewsletterPlus');
        Test.setCurrentPage(pageRef);
        settingDSObjectObj.handleRequest();
        System.assertEquals('success', settingDSObjectObj.response.status, settingDSObjectObj.response.message);
        Test.stopTest();
    }

    @isTest static void testSaveCalendarIntegrationsConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ManageApplicationWrapper.CalendarIntegrationsWrapper wrapObj = new ManageApplicationWrapper.CalendarIntegrationsWrapper();
        wrapObj.googleCalendar = true;
        wrapObj.outlookCalendar = true;
        wrapObj.outlookCalendarDomainWhitelist = new List<String>{'test.com'};
        string str = Json.serialize(wrapObj);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.saveCalendarIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, resp.message);
    }


    @isTest static void testSaveFilesIntegrationsConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveFilesIntegrationsConfig('{"spUpgradeStatus":"completed","odIntegrationEnabled":true,"odConnected":true,"googleDriveEnabled":false,"googleDriveConnectedAs":"howard.nelson@simpplr.dev","dropboxEnabled":true,"boxStorage":true,"sharedDriveEnabled":false,"googleManagedPermission":false,"showOpenInGoogleDrive":false,"myDriveEnabled":false,"spIntegrationEnabled":true,"showOpenInSharePoint":true}');
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testSaveFilesIntegrationsConfigGoogleMultiInstance() { 
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        SettingDataServer settingDSObject = new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveFilesIntegrationsConfig('{"spUpgradeStatus":"completed","odIntegrationEnabled":false,"odConnected":false,"googleDriveEnabled":true,"googleDriveConnectedAs":"howard.nelson@simpplr.dev","dropboxEnabled":false,"boxStorage":false,"sharedDriveEnabled":false,"googleManagedPermission":true,"showOpenInGoogleDrive":true,"myDriveEnabled":false,"spIntegrationEnabled":true,"showOpenInSharePoint":false}');
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testDisconnectAndUpgradeSPConfig() { 
        init();
        pageRef.getParameters().put('action','disconnectApp');
        pageRef.getParameters().put('data','{"spUpgradeStatus": "inProgress", "appName": "sharepoint"}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();        
        System.assertEquals('success', settingDSObject.response.status, settingDSObject.response.message);
    }

    @isTest static void testSaveLicensingPeopleConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveLicensingPeopleConfig('{"autoProvisioningProcessEnabled":true,"autoFreeSimpplrLicenseEnabled":true}');
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest static void testAddDomainsIntegrationsConfig() {
        init();
        SettingDataServer settingDSObject = new SettingDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.saveDomainsIntegrationsConfig('{"type":"add","googleDriveDomainList":[{"domainName":"simpplr.xyz"}],"googleCalendarDomainList":[{"domainName":"simpplr.xyz"}]}');
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testRemoveDomainsIntegrationsConfig() {
        init();
        SettingDataServer settingDSObject = new SettingDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.saveDomainsIntegrationsConfig('{"type":"remove","googleDriveDomainList":[{"domainName":"simpplr.com"}]}');
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testRemoveDomainsCalendarIntegrationsConfig() {
        init();
        SettingDataServer settingDSObject = new SettingDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.saveDomainsIntegrationsConfig('{"type":"remove","googleCalendarDomainList":[{"domainName":"simpplr.com"}]}');
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testStartGoogleMultiInstanceManualUpgradeFlowRetainGroups() {
        init();
        App_Config__c appConfig = [SELECT Id, Google_Multi_Domain_Upgrade_Status__c FROM App_Config__c LIMIT 1];
        appConfig.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_NOT_STARTED_YET;
        update appConfig;
        Test.startTest();
        SettingDataServer settingDSObject = new SettingDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.startGoogleMultiInstanceUpgradeFlow('{"retainGoogleGroups":true}');
        List<String> chattergroupIds = new List<String>{};
        GoogleDriveService.startGoogleMultiInstanceUpgradeFlow(true, chattergroupIds);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testStartGoogleMultiInstanceManualUpgradeFlowRemoveGroups() {
        init();
        App_Config__c appConfig = [SELECT Id, Google_Multi_Domain_Upgrade_Status__c FROM App_Config__c LIMIT 1];
        appConfig.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_NOT_STARTED_YET;
        update appConfig;
        Test.startTest();
        SettingDataServer settingDSObject = new SettingDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.startGoogleMultiInstanceUpgradeFlow('{"retainGoogleGroups":false}');
        List<String> chattergroupIds = new List<String>{getSimpplrSite().chatter_group_Id__c};
        GoogleDriveService.startGoogleMultiInstanceUpgradeFlow(false, chattergroupIds);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Runnning as expected');
    }

    @isTest static void testStartGoogleMultiInstanceManualUpgradeFlowFailure() {
        init();
        Test.startTest();
        SettingDataServer settingDSObject = new SettingDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.startGoogleMultiInstanceUpgradeFlow('{"retainGoogleGroups":true}');
        List<String> chattergroupIds = new List<String>{};
        GoogleDriveService.startGoogleMultiInstanceUpgradeFlow(true, chattergroupIds);
        Test.stopTest();
        System.assertEquals('error', 'error', 'Runnning as expected');
    }

    @isTest static void testSaveGeneralSetupConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();  
        pageRef.getParameters().put('action','saveGeneralSetupConfig'); 
        pageRef.getParameters().put('data','{"socialCampaignEnabled":"false","questionAnswerEnabled":"false","showMobilePromotionOption":true,"shareFeedback":true,"postLogoutUrl":"https://dummy2/","pagesFeatureEnabled":true,"newsFeatureEnabled":false,"mobilePromotionEnabled":"true","mobileAppAdditionalSecurityEnabled":"false","loginTimeoutSeconds":"86400","languages":[{"onOff":true,"name":"en_US","label":"en_US.language.en_us"},{"onOff":false,"name":"zh_CN","label":"en_US.language.zh_cn"},{"onOff":false,"name":"nl_NL","label":"en_US.language.nl_nl"},{"onOff":false,"name":"en_GB","label":"en_US.language.en_gb"},{"onOff":false,"name":"fr_FR","label":"en_US.language.fr_fr"},{"onOff":false,"name":"de_DE","label":"en_US.language.de_de"},{"onOff":false,"name":"it_IT","label":"en_US.language.it_it"},{"onOff":false,"name":"ja_JP","label":"en_US.language.ja_jp"},{"onOff":false,"name":"pt_BR","label":"en_US.language.pt_br"},{"onOff":false,"name":"es_ES","label":"en_US.language.es_es"}],"fileFeatureEnabled":true,"feedbackRecipients":[],"feature":[],"eventsFeatureEnabled":true,"enableSMSNotifications":false,"enablePushNotificationMobile":true,"enablePushNotificationDesktop":true,"calendarOutlookEnabled":true,"calendarOffice365Enabled":true,"calendarGoogleEnabled":true,"calendarAppEnabled":true,"blogsFeatureEnabled":false,"blogPostSetup":"influencer","automatedTranslationEnabled":"false","applicationName":"T1: Video","albumsFeatureEnabled":true}');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'SettingDataServer/saveGeneralSetupConfig', false));
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }
        
    @isTest static void testSaveAnalyticsEmbedsIntegrationsConfig() {
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveAnalyticsEmbedsIntegrationsConfig('{"vbrick":false,"googleAnalytics":true,"enableGoogleAnalytics4":true,"enableGoogleAnalytics":true,"analyticsTrackingId4":"123","analyticsTrackingId":"123","analyticsEnhancedLinkAttribution":true,"analyticsDemographicsInterestsReports":false}');
        System.assertEquals('success', resp.status, resp.message);        
    }

    @isTest static void testSavePeopleIntegrationsConfig() { 
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success','{"showEmployeeUserDefinedFieldName":true,"showCompanyUserDefinedFieldName": false,"showInternationalUserDefinedFieldName":false}',false));
        Test.startTest();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.savePeopleIntegrationsConfig('{"ukgPro": true, "ukgProUsername": "Dummy", "ukgProPassword": "Dummy@1234", "ukgProBaseUrl": "DummyURL", "ukgProApiKey": "DummyApiKey", "googleIntegrationEnabled": true, "workdayUsername":"Simpplr","workdayPassword":"Simpplr", "workdayEndpointUrl":"https://na136.salesforce.com/setup/forcecomHomepage.apexp?setupid=ForceCom&retURL=%2Fhome%2Fhome.jsp","workday":true,"adRedirectURL":"https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=simran&redirect_uri=https%3A%2F%2Fservices.simpplr.com%2Foauth%2Fredirect%2Fcode_passthrough.php&&state=https%3A%2F%2Fc.na136.visual.force.com%2Fapex%2Fconnectexternalapp%3Fstate%3Dadsi&response_mode=query&prompt=admin_consent","adIntegrationEnabled":false,"activeDirectoryIntegrationEnabled":false,"adClientSecret":"DummyClientSecret","adClientId":"DummyClienID"}');
        System.assertEquals('success', resp.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void savePeopleIntegrationsConfigADGroupsV2Enabled() {
        init();
        SimpplrContext.isActiveDirectoryGroupsEnabled = true;
        SimpplrContext.autoCreateActiveDirectoryAudience = false;
        pageRef.getParameters().put('action','savePeopleIntegrationsConfig');
        pageRef.getParameters().put('data','{"useActiveDirectoryGroups":"false","workdayPasswordSaved":false,"workday":false,"ukgProPasswordSaved":false,"ukgProApiKeySaved":false,"ukgPro":false,"googleIntegrationEnabled":true,"googleConnectedAs":"amit@bhootnath.in","adRedirectURL":"https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=cfca14ca-05d2-4e5e-830f-10a54e1574cf&redirect_uri=https%3A%2F%2Fservices.simpplr.com%2Foauth%2Fredirect%2Fcode_passthrough.php&&state=https%3A%2F%2Fhimanshuranadev-dev-ed--c.visualforce.com%2Fapex%2Fconnectexternalapp%3Fstate%3Dadsi&response_mode=query&prompt=admin_consent","adIntegrationEnabled":true,"adConnectedAs":"Simpplr Admin","workdayPassword":null,"ukgProPassword":null,"ukgProApiKey":null,"activeDirectoryIntegrationEnabled":true,"isActiveDirectoryGroupsEnabled":true,"autoCreateActiveDirectoryAudience":true,"listOfActiveDirectoryGroupsSelected":[{"id":"AdGroupId-225434","name":"Ad group name 225434","isSelected": true,"groupType":"microsoft365"}],"listOfActiveDirectoryGroupsRemoved":[{"id":"AdGroupId-225434","name":"Ad group name 1549","isSelected": true}]}');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        FeatureFlagManager.featureFlagValueMap.put('ad_groups_v2', true);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Failed to save people config');
        Test.stopTest();
    }

    @isTest static void testSaveSsoIntegrationsConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveSsoIntegrationsConfig('{"oneLoginEmbeddingUrl":"simran","oneLoginEmbeddingCode":"simran","oneLoginApiKey":"simran","onelogin":true,"oktaUserNameFormat":"1","oktaLink":"simran","oktaApiToken":"simran","okta":true}');
        System.assertEquals('success', resp.status, resp.message);       
    }

    @isTest static void testSaveSupportIntegrationsConfig1() { 
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        Test.startTest();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveSupportIntegrationsConfig('{"serviceNow":{"spIntegrationEnabled":false,"snTicketCreationEnabled":true, "snNotificationsEnabled":true,"snTicketEnabled":true,"snEnabled":true,"snConnectedAs":"","odIntegrationEnabled":false,"kbWrapperList":[],"gdriveEnabled":false,"dropboxEnabled":false,"boxStorage":false,"customSNKnowledgebaseName":"ServiceNow knowledgebase","customSNTicketingSystemName":"ServiceNow tickets","snClientId":"dummy","servicenowInstanceUrl":"https://my-company.service-now.com","snClientSecret":"dummy","isSNKnowledgeDefaultSelected":true,"isSNTicketingDefaultSelected":true},"atlassian":{"isConfluenceKnowledgeSpacesSelected":true,"isConfluenceKnowledgeDefaultSelected":true,"customConfluenceKnowledgeBaseName":"Confluence","confluenceKBWrapperList":[],"confluenceEnabled":true,"atlassiankeysSaved":true,"atlassianInstanceUrl":"https://simpplr.atlassian.net","atlassianEnabled":true,"atlassianConnectedAs":"dummy "}}'); 
        System.assertEquals('success', resp.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testSaveSupportIntegrationsConfig2() { 
        init();
        delete [select id from people_integration__c where name='servicenow'];
        delete [select id from App_Integration__c where name = 'servicenow'];
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        Test.startTest();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveSupportIntegrationsConfig('{"serviceNow":{"snEnabled":false,"snKeysSaved":false,"snNotificationsEnabled": false,"snTicketEnabled":false},"atlassian":{"isConfluenceKnowledgeSpacesSelected":true,"isConfluenceKnowledgeDefaultSelected":true,"customConfluenceKnowledgeBaseName":"Confluence","confluenceKBWrapperList":[],"confluenceEnabled":true,"atlassiankeysSaved":true,"atlassianInstanceUrl":"https://simpplr.atlassian.net","atlassianEnabled":false,"atlassianConnectedAs":"Rohit Kumar"}}');
        System.assertEquals('success', resp.status, 'Running as expected');
        Test.stopTest();
    }
        
    @isTest static void testSaveCampaignsIntegrationsConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveCampaignsIntegrationsConfig('{"employeeAdvocacy":true,"facebookEnabled":true,"twitterEnabled":true,"linkedInEnabled":true}');
        System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testSaveGovernanceSetupConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveGovernanceSetupConfig('{"allowFileShareWithPublicLink":true,"homeCarouselEnabled":true,"siteCarouselEnabled":true, "expertiseCreateControlledByManager":true, "autoGovernanceEnabled":"","expertiseControlledByManager":"","feedEnabled":"true","homeDashboardSetup":"User","siteDashboardSetup":"App Manager","contentSubmissions":true,"contentComments":true,"autoConvertChatterGroupToSite":"true","showTrackChangesFeedPosts":false,"siteFilePermission":"allFilesInSelectedSites","sitesToUploadFiles":[]}');
        System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testSaveNavigationSetupConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveNavigationSetupConfig('{"singleSignOnIntegration":"none","customJson":null,"url":"https://www.google.com","label":"Google","goToSalesforceEnabled":true,"isOrgChartEnabled":false}');
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest static void testSaveGovernanceSetupConfig2ForError() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveGovernanceSetupConfig('{"homeCarouselEnabled":true,"siteCarouselEnabled":true,"interactionLevel":"Across Application","feedVisibility":"dashboard",contentComments":true,"contentSubmissions":true}');
        System.assertEquals('error', resp.status, 'Running as expected');
    }

    @isTest static void testSaveEmailSetupConfig1() {
        init();
        People__c peopleRecord1 = [select id from people__c limit 1];
        String jsonString = '{' + '"enableEmail":true,"emailSender":"' +peopleRecord1.id+ '","chatterEmails":"Do Not Change"}';
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveEmailSetupConfig(jsonString);
        System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testSaveEmailSetupConfig2() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveEmailSetupConfig('{"enableEmail":true,"emailSender":null,"chatterEmails":"Off For Selected Profiles","profilesNotReceiveEmails":["00e61000000KaGOAA0"],"enableTopStoriesEmails":false}');
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest static void testSaveTroubleshootingConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveTroubleshootingConfig('{"user":true,"jsDebugEnabled":true,"feedItem":true,"feedComment":true,"errorStack":false,"debugEnabled":true,"contentVersion":true,"contentDocument":true,"collaborationGroupMember":true,"collaborationGroup":true,"simpplrDomain":true}');
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest static void testSaveGeneralPeopleConfig() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveGeneralPeopleConfig('{"peopleCategorySingular":null,"peopleCategoryPlural":null,"peopleCategoryEnabled":true}');
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest static void testSaveUserSyncingPeopleConfig() {
        init(); 
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveUserSyncingPeopleConfig('{"additionalFields":[{"fieldName":"Salesforce","syncSource":"Simpplr"}],"syncSource":"Simpplr","maxSyncAttempts":"2","firstName":false,"lastName":false,"userTitle":false,"userEmail":false,"communityNickname":false,"aboutMe":false,"employeeNumber":false,"manager":false,"department":false,"userDivision":false,"companyName":false,"street":false,"postalCode":false,"city":false,"state":false,"country":false,"phone":false,"extension":false,"mobilePhone":false,"fax":false,"enableFormatting":false}');
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest static void testSaveUserSyncingPeopleConfig2() {
        init(); 
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveUserSyncingPeopleConfig('{"syncSource":"none","maxSyncAttempts":"2","firstName":false,"lastName":false,"userTitle":false,"userEmail":false,"communityNickname":false,"aboutMe":false,"employeeNumber":false,"manager":false,"department":false,"userDivision":false,"companyName":false,"street":false,"postalCode":false,"city":false,"state":false,"country":false,"phone":false,"extension":false,"mobilePhone":false,"fax":false,"enableFormatting":false}');
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest static void testSaveProfileFieldsPeopleConfig() { 
        init();
        SimpplrContext.isSegmentsEnabled = true;
        SettingDataServer settingDSObject= new SettingDataServer();
        SettingDataServer profileFieldsObj= new SettingDataServer();  
        ResponseWrapper resp = settingDSObject.saveProfileFieldsPeopleConfig('{"editableFirstName":true,"lastName":true,"editableLastName":true,"editableUserCategory":true,"editableDivision":false,"editableCompanyName":true,"userTitle":true,"editableUserTitle":true,"aboutMe":true,"editableAboutMe":true,"department":true,"editableDepartment":true,"userState":true,"editableState":true,"country":true,"editableCountry":true,"editableCity":true,"phone":true,"editablePhone":true,"extension":true,"editableExtension":true,"mobilePhone":true,"editableMobilePhone":true,"field":"FirstName","firstName":false}');
        System.assertEquals('error', resp.status, 'will throw exception due to editableCompanyName = true. should be an error');

        resp = settingDSObject.saveProfileFieldsPeopleConfig('{"videoSynced":false,"videoProvider":"zoom","video":true,"userTitleSynced":true,"userTitle":true,"userStateSynced":false,"userState":true,"userCategorySynced":false,"userCategory":false,"timezoneSynced":false,"timezone":true,"streetSynced":false,"street":true,"phoneSynced":false,"phone":true,"mobilePhoneSynced":false,"mobilePhone":true,"managerSynced":true,"manager":true,"lastNameSynced":true,"lastName":true,"languageSynced":false,"language":true,"joiningDate":false,"joiningDateSynced":false,"firstNameSynced":true,"firstName":true,"extensionSynced":false,"extension":true,"editableVideo":true,"editableUserTitle":false,"editableUserCategory":false,"editableTimezone":true,"editableStreet":true,"editableState":false,"editablePhone":false,"editableMobilePhone":true,"editableManager":false,"editableLastName":false,"editableLanguage":true,"editableJoiningDate":true,"editableFirstName":false,"editableExtension":false,"editableDivision":false,"editableDepartment":false,"editableCountry":false,"":false,"editableCity":false,"editableBirthDate":true,"editableAboutMe":true,"divisionSynced":false,"division":true,"departmentSynced":false,"department":true,"countrySynced":true,"country":true,"companyNameSynced":false,"companyName":false,"citySynced":false,"city":true,"birthDateSynced":false,"birthDate":true,"availableFields":{"Show_Simpplr__c":"Show_Simpplr__c","MediumBannerPhotoUrl":"MediumBannerPhotoUrl","SmallBannerPhotoUrl":"SmallBannerPhotoUrl","BannerPhotoUrl":"BannerPhotoUrl","DefaultGroupNotificationFrequency":"DefaultGroupNotificationFrequency","DigestFrequency":"DigestFrequency","MediumPhotoUrl":"MediumPhotoUrl","OutOfOfficeMessage":"OutOfOfficeMessage","SmallPhotoUrl":"SmallPhotoUrl","FullPhotoUrl":"FullPhotoUrl","FederationIdentifier":"FederationIdentifier","Extension":"Extension","EmployeeNumber":"EmployeeNumber","LanguageLocaleKey":"LanguageLocaleKey","UserType":"UserType","EmailEncodingKey":"EmailEncodingKey","LocaleSidKey":"LocaleSidKey","BadgeText":"BadgeText","CommunityNickname":"CommunityNickname","Alias":"Alias","Fax":"Fax","StayInTouchNote":"StayInTouchNote","StayInTouchSubject":"StayInTouchSubject","SenderName":"SenderName","SenderEmail":"SenderEmail","Email":"Email","GeocodeAccuracy":"GeocodeAccuracy","PostalCode":"PostalCode","Division":"Division","CompanyName":"CompanyName","Name":"Name","Username":"Username"},"aboutMeSynced":false,"aboutMe":true,"customFields":[]}');        
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = profileFieldsobj.saveProfileFieldsPeopleConfig('{"segmentFieldName": "City__c","editableFirstName":true,"lastName":true,"editableLastName":true,"editableUserCategory":true,"editableDivision":true,"editableCompanyName":true,"userTitle":true,"editableUserTitle":true,"aboutMe":true,"editableAboutMe":true,"department":true,"editableDepartment":true,"userState":true,"editableState":true,"country":true,"editableCountry":true,"editableCity":true,"phone":true,"editablePhone":true,"extension":true,"editableExtension":true,"mobilePhone":true,"editableMobilePhone":true,"field":"FirstName","firstName":false}');  	
        System.assertEquals('error', resp.status, 'will throw exception due to editable field = true. should be an error');

        resp = profileFieldsobj.saveProfileFieldsPeopleConfig('{"segmentFieldName": "division__C","editableFirstName":true,"lastName":true,"editableLastName":true,"editableUserCategory":true,"editableDivision":true,"editableCompanyName":true,"userTitle":true,"editableUserTitle":true,"aboutMe":true,"editableAboutMe":true,"department":true,"editableDepartment":true,"userState":true,"editableState":true,"country":true,"editableCountry":true,"editableCity":true,"phone":true,"editablePhone":true,"extension":true,"editableExtension":true,"mobilePhone":true,"editableMobilePhone":true,"field":"FirstName","firstName":false}');  	
        System.assertEquals('error', resp.status, 'will throw exception due to editable field = true. should be an error');
    }

    @isTest static void testDisconnectAppADSI() {
    	init();
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"adsi"}');
        System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    /**
     * @description method to test active directory disconnect
     */
    @isTest static void testDisconnectAppActiceDirectory() {
    	init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"activedirectory"}');
        System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testDisconnectAppSmartSearch() {
    	init();
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"smartsearch"}');
        System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testDisconnectAppServicenow() {
    	init();
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"servicenow"}');
        System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testDisconnectAppAtlassian() {
    	init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        Test.startTest();
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"atlassian"}');
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testDisableGoogleDrive() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));  
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveFilesIntegrationsConfig('{"spIntegrationEnabled":true,"odIntegrationEnabled":true,"gdriveEnabled":true,"dropboxEnabled":false,"googleDriveEnabled":false,"boxStorage":true,"boxClientSecret":"dummy","boxClientId":"dummy"}');   
        System.assertEquals('success', resp.status, resp.status);
        Test.stopTest();  
    }
    
    @isTest static void testDisconnectBox() {
      Test.startTest();
       Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/UserDetails',true));  
       BoxService obj = new BoxService();
       SettingDataServer settingDSObject= new SettingDataServer();
       ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"box"}');     
       Test.stopTest();  
       System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testDisconnectGoogleCalendarAdmin() {
        Test.startTest();
       Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));  
       SettingDataServer settingDSObject= new SettingDataServer();
       ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"googlecalendar"}');     
       Test.stopTest();  
       System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testDisconnectMicrosoftTeamsAdmin() {
       
    	init();
        SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 = true;
        SettingDataServer serverObj = new SettingDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','SettingDataServer');
        Test.setCurrentPage(pgRef);
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{'microsoftteams'});
        appInteList[0].Alerts_For_App_Enabled__c = true;
        appInteList[0].Enterprise_Id__c = 'tenantId';
        update appInteList;
        SimpplrContext.uuid = 'sfshfso-sfowf-wdvns-lsdhfos';
        UserContext.uuid = 'vnkhjs-ndfhgao-xnvjsk-shfs';
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS,appInteList[0].id);	
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "microsoftTeamsAdmin"}');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/externalSearch',false));
    	Test.setCurrentPage(pgRef);
        Test.startTest();
    	serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status , 'Unable to disconnect microsoftTeamsAdmin');
        Test.stopTest();
        
    }

    @isTest static void testDisconnectGoogleUserSyncAdmin() {
        Test.startTest();
        TestHelper.createUserProvisioningConfig('Google');
       Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));  
       SettingDataServer settingDSObject= new SettingDataServer();
       ResponseWrapper resp = settingDSObject.disconnectApp('{"appName":"googleusersync"}');     
       Test.stopTest();  
       System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testConnectApp() {
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.connectApp('{"appName":"adsi"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"dropbox"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"salesforce"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"servicenow"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"googledrive"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"googleusersync"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"googleCalendar"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"dropbox"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"sharepoint"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"box"}');
        System.assertEquals('success', resp.status, 'Running as expected');

        resp = settingDSObject.connectApp('{"appName":"smartsearch"}');
        System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testSavePrivilegesConfig1() { 
      init();
      People__c peopleRecord1 = [select id from people__c limit 1];
      peopleRecord1.Unlisted_Site_Moderation_Permission__c = 'true';
      peopleRecord1.Is_Campaign_Manager__c = true;
      peopleRecord1.Can_Control_Dashboard__c = true;
      peopleRecord1.Unlisted_Site_Moderation_Permission__c = 'Yes';
      peopleRecord1.Can_Add_Sites__c = true;
      update peopleRecord1;
      string siteObj = getSimpplrSite().id;
      List<String> values = new List<String>{peopleRecord1.id};
      String str = '"analyticsAccess":["{0}"],"addSitesPermission":"Yes","addSitePeopleSet":["{0}"]';
      String jsonString = '{' + EmailUtility.format(str,values) + '}';
      SettingDataServer settingDSObject= new SettingDataServer();
      ResponseWrapper resp = settingDSObject.savePrivilegesConfig(jsonString);
      System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testSavePrivilegesConfig2() {
      init();
      People__c peopleRecord1 = [select id from people__c limit 1];
      Simpplr_Site__c siteObj = getSimpplrSite();
      update siteObj;
      List<String> values = new List<String>{peopleRecord1.id, siteObj.id};
      String str = '"canManageSocialCampaign":["{0}"],"unlistedSitesManagingPeopleIdSet":["{0}"],"canAccessAlertsPeople":["{0}"],"alertsControlSite":["{1}"],"analyticsAccess":["{0}"],"influencers":["{0}"],"leadership":["{0}"],"newsletterControlPeople":["{0}"],"newsletterControlSite":["{1}","{1}"]';
      String jsonString = '{' + EmailUtility.format(str,values) + '}';
      SettingDataServer settingDSObject= new SettingDataServer();
      ResponseWrapper resp = settingDSObject.savePrivilegesConfig(jsonString);
      System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testSaveEmailNotificationsSettings1() { 
		init();
		    People__c peopleRecord1 = [select id from people__c limit 1];
        List<String> values = new List<String>{peopleRecord1.id};
        String str = '"analyticsAccess":["{0}"],"isApplyToAllUsers":"1"';
		    String jsonString = '{' + EmailUtility.format(str,values) + '}';
  	  	
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveEmailNotificationsSettings(jsonString);
        System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testSaveEmailNotificationsSettings2() { 
        Test.startTest();
        init();
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        App_Default__c appDefaultObj = [Select id from App_Default__c where Type__c = 'email_notifications'];
        string appDefault = JSON.serialize(appDefaultObj);
        ResponseWrapper resp = settingDSObject.saveEmailNotificationsSettings(appDefault);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testSaveDefaultFeedSettings1() { 
      init();
        People__c peopleRecord1 = [select id from people__c limit 1];
        List<String> values = new List<String>{peopleRecord1.id};
        String str = '"analyticsAccess":["{0}"],"isApplyToAllUsers":"1"';
        String jsonString = '{' + EmailUtility.format(str,values) + '}';
        SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.saveDefaultFeedSettings(jsonString);
        System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testSaveDefaultFeedSettings2() { 
      init();
      Test.startTest();
      SettingDataServer settingDSObject= new SettingDataServer();
      App_Default__c appDefaultObj = [Select id from App_Default__c where Type__c = 'email_notifications'];
      appDefaultObj.Type__c = 'home-feed';
      update appDefaultObj;
      string appDefault = JSON.serialize(appDefaultObj);
      ResponseWrapper resp = settingDSObject.saveDefaultFeedSettings(appDefault);
      Test.stopTest();
      System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testSaveSMSSetting() { 
      init();
      Test.startTest();
      SettingDataServer settingDSObject= new SettingDataServer();
      ManageApplicationWrapper.MobileAppNotificationWrapper mobileAppNotificationObj = new ManageApplicationWrapper.MobileAppNotificationWrapper();
      App_Default__c appDefaultObj = new App_Default__c(Type__c = 'sms_notifications', OverwriteBatchInProgress__c = false, Data__c = '{"smsContentMarkedAsMustRead":true,"smsAlerts":true,"smsContentPromotionMessage":true}');
      insert appDefaultObj;
      string appDefault = JSON.serialize(appDefaultObj);
      ResponseWrapper resp = settingDSObject.saveSMSNotificationsSettings('{"smsContentMarkedAsMustRead":true,"smsAlerts":true,"smsContentPromotionMessage":true,"isProcessing":false,"isApplyToAllUsers":1}');
      settingDSObject.getSMSNotificationsSettings();
      Test.stopTest();
      System.assertEquals('success', resp.status, 'Running as expected');
    }

    @isTest static void testSaveBrowserSettings() { 
      init();
      Test.startTest();
      SettingDataServer settingDSObject= new SettingDataServer();
      App_Default__c appDefaultObj = new App_Default__c(Type__c = 'browser_notifications', OverwriteBatchInProgress__c = false, Data__c = '{"isApplyToAllUsers":1,"browserMustRead":true,"browserAlerts":true,"browserUpdatesContentSitesFollow":true, "browserFollowsMe":true,"browserEndorseExpertise":true,"browserReplyOnMyPost":true,"browserReplyAfterMe":true,"browserReplyOnLikedPost":true,"browserLikesMyPostOrReply":true,"browserSharesMyPost":true,"browserPostsToMe":true,"browserPrivateSiteMembershipResponse":true,"browserContentValidationRequired":true,"browserContentValidationExpired":true,"browserContentCommentsOnPublished":true,"browserContentLikesSharesOnPublished":true,"browserContentApprovalRejection":true,"browserContentFeedback":true,"browserEventInvite":true,"browserEventUpdatesAttending":true,"browserEventUpdatesAuthoredOrganized":true,"browserPrivateSiteMembershipRequest":true,	"browserContentSubmittedForModeration":true,"browserSubscriptionRequest":true}');
      insert appDefaultObj;
      ManageApplicationWrapper.BrowserNotificationWrapper browserNotificationWrapper  = new ManageApplicationWrapper.BrowserNotificationWrapper();
      browserNotificationWrapper.isProcessing= true;
      browserNotificationWrapper.isApplyToAllUsers = '1';
      browserNotificationWrapper.browserMustRead= true;
      browserNotificationWrapper.browserAlerts= true;
      browserNotificationWrapper.browserUpdatesContentSitesFollow= true;
      browserNotificationWrapper.browserFollowsMe= true;
      browserNotificationWrapper.browserEndorseExpertise= true;
      browserNotificationWrapper.browserReplyOnMyPost= true;
      browserNotificationWrapper.browserReplyAfterMe= true;
      browserNotificationWrapper.browserReplyOnLikedPost= true;
      browserNotificationWrapper.browserLikesMyPostOrReply= true;
      browserNotificationWrapper.browserSharesMyPost= true;
      browserNotificationWrapper.browserPostsToMe= true;
      browserNotificationWrapper.browserPrivateSiteMembershipResponse= true;
      browserNotificationWrapper.browserContentValidationRequired= true;
      browserNotificationWrapper.browserContentValidationExpired= true;
      browserNotificationWrapper.browserContentCommentsOnPublished= true;
      browserNotificationWrapper.browserContentLikesSharesOnPublished= true;
      browserNotificationWrapper.browserContentApprovalRejection= true;
      browserNotificationWrapper.browserContentFeedback= true;
      browserNotificationWrapper.browserEventInvite= true;
      browserNotificationWrapper.browserEventUpdatesAttending= true;
      browserNotificationWrapper.browserEventUpdatesAuthoredOrganized= true;
      browserNotificationWrapper.browserPrivateSiteMembershipRequest= true;	
      browserNotificationWrapper.browserContentSubmittedForModeration= true;
      browserNotificationWrapper.browserSubscriptionRequest= true;

      browserNotificationWrapper.browserQnANewQuestion = true;
      browserNotificationWrapper.browserQnANewAnswer = true;
      browserNotificationWrapper.browserQnAQuestionMention = true;
      browserNotificationWrapper.browserQnAAnswerMention = true;
      browserNotificationWrapper.browserQnAAnswerApproval = true;
      browserNotificationWrapper.browserQnANewApprovedAnswer = true;
      browserNotificationWrapper.browserQnADuplicateQuestion = true;
      browserNotificationWrapper.browserQnAVote = true;
      browserNotificationWrapper.browserContentQuestion = true;
      browserNotificationWrapper.browserContentAnswer = true;
      
      String appDefault = JSON.serialize(browserNotificationWrapper);
      ResponseWrapper resp = settingDSObject.saveBrowserNotificationsSettings(appDefault);
      settingDSObject.getBrowserNotificationsSettings();
      
      Test.stopTest();
      System.assertEquals('success', resp.status, 'Running as expected');
  }
    
    @isTest static void testSaveNativeMobileSetting() { 
      	init();
      	Test.startTest();
      	SettingDataServer settingDSObject= new SettingDataServer();
      	App_Default__c appDefaultObj = new App_Default__c(Type__c = 'native_mobile_notifications', OverwriteBatchInProgress__c = false, Data__c = '{"mobileAppUpdatesContentSitesFollow":true,"mobileAppSharesMyPost":true,"mobileAppReplyOnLikedPost":true,"mobileAppReplyAfterMe":true,"mobileAppPrivateSiteMembershipResponse":true,"mobileAppPrivateSiteMembershipRequest":true,"mobileAppPostsToMe":true,"mobileAppLikesPostOrCommentMade":true,"mobileAppLikesOrSharesContentPublished":true,"mobileAppFollowsMe":true,"mobileAppEventInviteMore":true,"mobileAppEndorseExpertise":true,"mobileAppContentSubmittedForModeration":true,"mobileAppContentMarkedAsMustRead":true,"mobileAppContentApprovalRejection":true,"mobileAppCommentsPostMade":true,"mobileAppCommentsContentPublished":true,"mobileAppAlerts":true, "mobileQnAQuestionMention": true, "mobileQnAAnswerMention": true, "mobileQnAVote": true, "mobileQnAAnswerApproval": true, "mobileQnANewAnswer": true, "mobileQnANewApprovedAnswer": true, "mobileQnADuplicateQuestion": true, "mobileQnANewQuestion": true,"mobileAppContentQuestion":true,"mobileAppContentAnswer":true,"isApplyToAllUsers":1,"mobileSurveys":true}');
      	insert appDefaultObj;
      	
      ResponseWrapper resp = settingDSObject.saveNativeMobileAppNotificationsSettings(appDefaultObj.Data__c);
      	Test.stopTest();
      	System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testDisconnectEFSAdmin() { 
		init();
  	  	SettingDataServer settingDSObject= new SettingDataServer();
        ResponseWrapper resp = settingDSObject.disconnectEFSAdmin('dropbox');
        System.assertEquals('success', resp.status, 'Running as expected');
    }
    @isTest static void testDisconnectServicenowAdmin() { 
      Test.startTest();
      init();
      SettingDataServer settingDSObject= new SettingDataServer();
      ResponseWrapper resp = settingDSObject.disconnectServicenowAdmin();
      test.stopTest();
      System.assertEquals('success', resp.status, 'Running as expected');
    }
    
    @isTest static void testDisconnectAtlassianAdmin() {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/SettingDataServer/disconnectAtlassianAdmin',false));
      init();
      Test.setCurrentPage(pageRef);      
      pageRef.getParameters().put('action','disconnectAtlassianAdmin');
      pageRef.getParameters().put('data','{}');
      SettingDataServer settingDSObject= new SettingDataServer();
      settingDSObject.handleRequest();
      
      System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
      Test.stopTest();
  }
  
    @isTest static void testDeleteSecretTokenforExternalSearch() {
      Test.startTest(); 
      init();
      Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/SettingDataServer/deleteToken',false));
      SettingDataServer settingDSObject= new SettingDataServer();
      ResponseWrapper resp = settingDSObject.deleteSecretTokenforExternalSearch();
      System.assertEquals('success', resp.status, 'Running as expected');

      SettingDataServer appConfigObj= new SettingDataServer();
      ResponseWrapper resp1 = appConfigObj.deleteSecretTokenforExternalSearch();       
      System.assertEquals('success', resp1.status, 'Running as expected');
      Test.stopTest();
    }
     @isTest static void sendOrgWideEmailVerificationStatusTest() { 
      Test.startTest();
      init();
      SettingDataServer.sendOrgWideEmailVerificationStatus(null);
      SettingDataServer.sendOrgWideEmailVerificationStatus(UserInfo.getOrganizationId());
  	  System.assert(true, 'Running as expected if no errors in sending email');
      Test.stopTest();
    }
    
    
    @isTest static void testDefaultFeedSettingsWrapper() {
		ManageApplicationWrapper.DefaultFeedSettingsWrapper wrapperObj = new ManageApplicationWrapper.DefaultFeedSettingsWrapper();
		
		wrapperObj.feedSetting = '';
		wrapperObj.feedFilter = '';
		wrapperObj.isProcessing = false;
		wrapperObj.appDefaultLastModifiedDate = '';
		wrapperObj.appDefaultLastModifiedByURL = '';
		wrapperObj.appDefaultLastModifiedByName = '';
		wrapperObj.isApplyToAllUsers  = '';
		
		System.assert(true,'Running as expected');
    }
    
    @isTest static void testCategoryEditWrapper() {
		ManageApplicationWrapper.CategoryEditWrapper wrapperObj = new ManageApplicationWrapper.CategoryEditWrapper();
		
		wrapperObj.categoryName = '';
		wrapperObj.newCategoryName = '';
		
		System.assert(true,'Running as expected');
    }
    
    @isTest static void testPrivilegesSetsWrapper() {
		ManageApplicationWrapper.PrivilegesSetsWrapper wrapperObj = new ManageApplicationWrapper.PrivilegesSetsWrapper();
		
		System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetGeneralSetupConfig() { 
      init();
      Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'settingDataServer/getGeneralSetupConfig',false));
      pageRef.getParameters().put('action','getGeneralSetupConfig');
      Test.setCurrentPage(pageRef);        
      Test.startTest();
      SettingDataServer settingDSObject= new SettingDataServer();
      settingDSObject.handleRequest();
      Test.stopTest();
      System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }

    @isTest static void testSaveSummariesAndDigestSettings() { 
      init();
      Test.setCurrentPage(pageRef);
      Test.startTest();
      SettingDataServer settingDSObject= new SettingDataServer();
      pageRef.getParameters().put('action','saveSummariesAndDigestSettings');
      pageRef.getParameters().put('data','{"topStoriesFrequency":"Daily","siteAnalyticsFrequency":"monthly","isProcessing":false,"digestFrequency":"Daily"}');
      settingDSObject.handleRequest();
      System.assertEquals('success', settingDSObject.response.status, 'Running as expected');

      pageRef.getParameters().put('data','{"topStoriesFrequency":"Daily","siteAnalyticsFrequency":"monthly","isProcessing":false,"digestFrequency":"Daily","isApplyToAllUsers":1}');
      settingDSObject.handleRequest();
      System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
      Test.setCurrentPage(pageRef);   
      Test.stopTest();
    }
    
    @isTest static void testGetUKGUserFieldConfig() {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/SettingDataServer/getUKGUserFieldConfig',false));
      init();      
      pageRef.getParameters().put('action','getUKGUserFieldConfig');
      pageRef.getParameters().put('data','{}');
      Test.setCurrentPage(pageRef);
      SettingDataServer settingDSObj = new SettingDataServer();
      settingDSObj.handleRequest();
      
      System.assertEquals('success', settingDSObj.response.status, 'Running as expected');
      Test.stopTest();
  }

    @isTest static void testSaveMobileAppConfig() { 
        init();
        Test.startTest();
        pageRef.getParameters().put('action','saveMobileAppConfig');
        pageRef.getParameters().put('data','{"nativeAppEnabled":true, "brandedAppEnabled": true}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }
    
    @isTest static void testGetMobileAppConfig() { 
        init();
        Test.startTest();
        pageRef.getParameters().put('action','getMobileAppConfig');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }

    @isTest
    static void savePrivilegesConfigLeadercastSettingTest() {
        init();
        Simpplr_Site__c siteObj = getSimpplrSite();
        People__c peoleObj = getPeopleRecord(UserInfo.getUserId());
        Test.startTest();
        pageRef.getParameters().put('action','savePrivilegesConfig');
        pageRef.getParameters().put('data','{"leadercastControlSites":["' + siteObj.Id + '"], "leadercastControlPeople": ["' + peoleObj.Id + '"]}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }

    @isTest
    static void savePeopleIntegrationsConfigADGroupsTest() {
        init();
        SimpplrContext.isActiveDirectoryGroupsEnabled = true;
        SimpplrContext.autoCreateActiveDirectoryAudience = false;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        pageRef.getParameters().put('action','savePeopleIntegrationsConfig');
        pageRef.getParameters().put('data','{"useActiveDirectoryGroups":"false","workdayPasswordSaved":false,"workday":false,"ukgProPasswordSaved":false,"ukgProApiKeySaved":false,"ukgPro":false,"googleIntegrationEnabled":true,"googleConnectedAs":"amit@bhootnath.in","adRedirectURL":"https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=cfca14ca-05d2-4e5e-830f-10a54e1574cf&redirect_uri=https%3A%2F%2Fservices.simpplr.com%2Foauth%2Fredirect%2Fcode_passthrough.php&&state=https%3A%2F%2Fhimanshuranadev-dev-ed--c.visualforce.com%2Fapex%2Fconnectexternalapp%3Fstate%3Dadsi&response_mode=query&prompt=admin_consent","adIntegrationEnabled":true,"adConnectedAs":"Simpplr Admin","workdayPassword":null,"ukgProPassword":null,"ukgProApiKey":null,"activeDirectoryIntegrationEnabled":true,"isActiveDirectoryGroupsEnabled":true,"autoCreateActiveDirectoryAudience":true,"listOfActiveDirectoryGroupsSelected":[{"id":"AdGroupId-225434","name":"Ad group name 225434","isSelected": true,"groupTypes":["mail"]}],"listOfActiveDirectoryGroupsRemoved":[{"id":"AdGroupId-1549","name":"Ad group name 1549","isSelected": true,"groupTypes":["mail","security"]}]}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        System.assertEquals('success', settingDSObject.response.status, 'Should be success');
        pageRef.getParameters().put('data','{"useActiveDirectoryGroups":"false","workdayPasswordSaved":false,"workday":false,"ukgProPasswordSaved":false,"ukgProApiKeySaved":false,"ukgPro":false,"googleIntegrationEnabled":true,"googleConnectedAs":"amit@bhootnath.in","adRedirectURL":"https://login.microsoftonline.com/common/oauth2/authorize?response_type=code&client_id=cfca14ca-05d2-4e5e-830f-10a54e1574cf&redirect_uri=https%3A%2F%2Fservices.simpplr.com%2Foauth%2Fredirect%2Fcode_passthrough.php&&state=https%3A%2F%2Fhimanshuranadev-dev-ed--c.visualforce.com%2Fapex%2Fconnectexternalapp%3Fstate%3Dadsi&response_mode=query&prompt=admin_consent","adIntegrationEnabled":true,"adConnectedAs":"Simpplr Admin","workdayPassword":null,"ukgProPassword":null,"ukgProApiKey":null,"activeDirectoryIntegrationEnabled":true,"isActiveDirectoryGroupsEnabled":true,"autoCreateActiveDirectoryAudience":true,"listOfActiveDirectoryGroupsSelected":[],"listOfActiveDirectoryGroupsRemoved":[{"id":"AdGroupId-225434","name":"Ad group name 1549","isSelected": true,"groupTypes":["mail","security"]}]}');
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('error', settingDSObject.response.status, 'Error should be thrown in case total group count is 0');
    }
    
    @isTest
    static void saveRecognitionSetupConfigTest() {
        init();
        Test.startTest();
        People__c peoleObj = getPeopleRecord(UserInfo.getUserId());
        pageRef.getParameters().put('action','saveRecognitionSetupConfig');
        pageRef.getParameters().put('data','{"recognitionManagersIds":["'+peoleObj.Id+'"]}]}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }
    @isTest
    static void getRecognitionSetupConfigTest() {
        init();
        Test.startTest();
        pageRef.getParameters().put('action','getRecognitionSetupConfig');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Running as expected');
    }

    @isTest
    static void saveOutlookCalendarDomainChange() {
        init();
        List<App_Integration__c> appIntegrationList = [SELECT Id FROM App_Integration__c WHERE Name = 'outlookcalendar'];
        appIntegrationList[0].Whitelist_Domain__c = 'xyz.com';
        update appIntegrationList[0];
        List<People_Integration__c> peopleIntegrationList = [SELECT Id FROM People_Integration__c WHERE App_Integration__c =: appIntegrationList[0].Id];
        peopleIntegrationList[0].Domain__c = 'xyz.com';
        update peopleIntegrationList[0];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        pageRef.getParameters().put('action','saveCalendarIntegrationsConfig');
        pageRef.getParameters().put('data','{"outlookCalendarDomainWhitelist":[],"outlookCalendar":false,"isGoogleCalendarAccountReconnectRequired":false,"googleCalendarConnectedAs":"howard.nelson@simpplr.dev","googleCalendar":true}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Status should have been success');                
    }

    @isTest static void saveGoogleCalendarDisabled() { 
        init();
        SettingDataServer settingDSObject= new SettingDataServer();
        ManageApplicationWrapper.CalendarIntegrationsWrapper wrapObj = new ManageApplicationWrapper.CalendarIntegrationsWrapper();
        wrapObj.googleCalendar = false;
        wrapObj.outlookCalendar = true;
        wrapObj.outlookCalendarDomainWhitelist = new List<String>{'test.com'};
        string str = Json.serialize(wrapObj);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        ResponseWrapper resp = settingDSObject.saveCalendarIntegrationsConfig(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, resp.message);
    }

    @isTest
    static void saveDomainsInitialInsert() {
        init();
        List<App_Integration__c> appIntegrationList = [SELECT Id FROM App_Integration__c WHERE Name = 'googledrive'];
        appIntegrationList[0].Whitelist_Domain__c = '';
        update appIntegrationList[0];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/success',false));
        pageRef.getParameters().put('action','saveDomainsIntegrationsConfig');
        pageRef.getParameters().put('data','{"type":"add","googleDriveDomainList":[{"domainName":"simpplr.xyz"}]}');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Status should have been success');                
    }

    @isTest
    static void getGoogleMultiDomainConfig() {
        init();
        Test.startTest();
        pageRef.getParameters().put('action','getGoogleMultiDomainConfig');
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        settingDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', settingDSObject.response.status, 'Status should have been success');                  
    }

    @isTest static void testDisableSlackWhenAppRemovedFromWorkspace() { 
        init();
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        ManageApplicationWrapper.MessagingIntegrationWrapper wrapObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
        wrapObj.slackIntegrationEnabled = false;
        wrapObj.isSlackUnfurlAppInstalled = true;
        SimpplrContext.uuid ='adoc1-dlkji4-9238823-dlshfls';
        UserContext.uuid = 'sfjo-3ud9-lsdfji8-87sj';
        string str = Json.serialize(wrapObj);
        People__c peopleRecord = [SELECT id from People__c where Last_Name__c = 'Simpplr_usr'];
        peopleRecord.Slack_User_Id__c = 'slackUser1';
        peopleRecord.Slack_User_Name__c = 'slackTestUser';
        peopleRecord.Slack_Tenant_Id__c = 'slackTenantId';
        update peopleRecord;
        TestHelper.createPeopleIntegRecordForUser(peopleRecord.id, IntegrationConstants.INTEGRATION_TYPE_SLACK, appInteList[0].id);
        Test.setCurrentPage(pageRef);
        SettingDataServer settingDSObject= new SettingDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/manage-slack-info',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/get-jwt-token',false));
        ResponseWrapper resp = settingDSObject.disableSlackWhenAppRemovedFromWorkspace(str);
        Test.stopTest();
        System.assertEquals('success', resp.status, 'Unable to disable slack');
    }
        
}