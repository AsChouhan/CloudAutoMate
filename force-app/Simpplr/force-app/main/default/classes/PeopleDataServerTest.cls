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
private class PeopleDataServerTest {

    @testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Box_Managed_Permissions__c = 'simpplr';
        update appConfigRecord;
    	People__c peopleRec = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id);
        User userObj = TestHelper.createUser('PeopleDataServerTest_usr', null, false);
        People__c pObj = [Select id From people__c where user__c =: userObj.id];
        TestHelper.createPeoplePreference(peopleRec.Id);
        User adminUserObj = TestHelper.createUser('PeopleDataServerTest_admin', null, true);
        addPermissionSet(adminUserObj.id);
        People__c pObjAd = [Select id From people__c where user__c =: adminUserObj.id];
        Topic topicObj = TestHelper.createTopic('PeopleDataServer_test_addEndorsement');
        CollaborationGroup colabGroupObj= TestHelper.createCollaborationGroup('PeopleDataServerTest_Grp1','Public');
        TestHelper.createCollaborationGroupMember(colabGroupObj.id,adminUserObj.id);
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(colabGroupObj.Id);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
        Folder__c folderObj = TestHelper.createChatterFolder('googledrive', null, testSite.id, 'googledrive', null, 'readwrite');
        Simpplr_Content__c contentObj =  TestHelper.createContent('PeopleDataServerTest Event', 'Event', 'Approved', userObj, testSite);
        TestHelper.createContent('PeopleDataServerTest Blog', ServiceConstants.TYPE_BLOGPOST, 
        ServiceConstants.STATUS_APPROVED, userObj, null);
        TestHelper.createMustReadAudit(contentObj.id, 'everyone' , pObjAd.id);
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleRec.Id, 'Site'); 
		List<Subscription_Entity__c> listOfSubscriptionEntity =  TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRec.Id, getSite().Id);
        
        Expertise__c expertiseObj = TestHelper.createExpertise('PeopleDataServer_test_addExpertise');

        People_Expertise__c pEObj_1 = TestHelper.createPeopleExpertise(expertiseObj ,pObj);
        People_Expertise__c pEObj_2 = TestHelper.createPeopleExpertise(expertiseObj, peopleRec);
        
        People_Expertise_Detail__c pEDObj_1 = TestHelper.createPeopleExpertiseDetail(pEObj_1, peopleRec);
        People_Expertise_Detail__c pEDObj_2 = TestHelper.createPeopleExpertiseDetail(pEObj_2, peopleRec);
        People_Expertise_Detail__c pEDObj_3 = TestHelper.createPeopleExpertiseDetail(pEObj_2, peopleRec);
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(false, new Set<String>{'twitter', 'facebook', 'linkedin', 'googledrive', 'box', 'googlecalendar','onedrive'});
        List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, peopleRec.id, 'sadadqeq');
    	
        
        People__c peopleObj = getPeople(adminUserObj.Id);
        Site_Role__c siteroleObj = new Site_Role__c();
        siteroleObj.People__c = peopleObj.id;
        siteroleObj.Site__c = getSite().Id;
        siteroleObj.Is_Deleted__c = false;
        insert siteroleObj;
    }
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c siteObj = [select id from Simpplr_Site__c where name =: 'PeopleDataServerTest_Grp1' LIMIT 1];
        return siteObj;
    }
    
    private static Topic getTopic() {
    	Topic topicObj = [select id, name from Topic where name ='PeopleDataServer_test_addEndorsement'];
    	return topicObj;
    }
    
    private static Segment__c getSegment(){
    	Segment__c segmentObj = [select id from Segment__c LIMIT 1];
    	return segmentObj;
    }
    
    private static Audience__c getAudience() {
        Audience__c audienceObj = [Select Id From Audience__c Limit 1];
        return audienceObj;
    }
    
    private static Subscription__c getSubscription(){
    	Subscription__c subscriptionObj = [select id from Subscription__c LIMIT 1];
    	return subscriptionObj;
    }
    
    private static Simpplr_Content__c getContent(String contentType){
    	Simpplr_Content__c contentObj = [select id from Simpplr_Content__c where type__c=:contentType LIMIT 1];
        return contentObj;
    }
    
    private static User getAdminUser(){
		User userObj = TestHelper.getUser('System Administrator', 'PeopleDataServerTest_admin');
        return userObj;
    }

    private static User getStandardUser(){
		User userObj = TestHelper.getUser('Standard User', 'PeopleDataServerTest_usr');
        return userObj;
    }

    private static User getUserId(){
        User userObj = [select id from User where lastName = 'PeopleDataServerTest_usr'];
        return userObj;
    }
    
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
        							Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
									From People__c where User__c = :userId LIMIT 1];
       
        return peopleObj;
    }

    private static Expertise__c getExpertise() {
        Expertise__c expertiseObj = [SELECT Id, Name__c, Display_Name__c FROM Expertise__c 
                                                WHERE Display_Name__c = 'PeopleDataServer_test_addExpertise'];
    	return expertiseObj;
    }

    private static People_Expertise__c getPeopleExpertise(Expertise__c expertiseObj, People__c peopleObj) {
        String expertiseId = expertiseObj.Id;
        String peopleId = peopleObj.Id;
        
        People_Expertise__c peopleExpertiseObj = [SELECT Id, Expertise__c, People__c FROM People_Expertise__c 
                                                WHERE Expertise__c = :expertiseId AND People__c = :peopleId];
    	return peopleExpertiseObj;
    }

    private static People_Expertise_Detail__c getPeopleExpertiseDetail(People_Expertise__c pEObj, People__c peopleObj) {
        String peopleExpertiseId = pEObj.Id;
        String peopleId = peopleObj.Id;
        
        People_Expertise_Detail__c pEDObj = [SELECT Id, People_Expertise__c, Endorser__c FROM People_Expertise_Detail__c 
                                                WHERE People_Expertise__c = :peopleExpertiseId AND Endorser__c = :peopleId];
    	return pEDObj;
    }

    private static void init() {
    	PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
    }

    @isTest static void testExpertise() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser(); 
        User standardUserObj = getStandardUser();
        PeopleDataServer pDServerObj = new PeopleDataServer();
        ExpertiseDataServer expertiseServerObj = new ExpertiseDataServer();
        
        PageReference pgRef = Page.DataServerRW;
        Test.setCurrentPage(pgRef);

        // add expertise
        pgRef.getParameters().put('action', 'save');
        pgRef.getParameters().put('data', '{"id":null,"name":"Test_exp-1"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status , expertiseServerObj.response.message);
        
        pgRef.getParameters().put('data', '{"id":null,"name":"Test_exp-2"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status , expertiseServerObj.response.message);
        
        pgRef.getParameters().put('data', '{"id":null,"name":"Test_exp-3"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status , expertiseServerObj.response.message);
        
        // create a new expertise
        Expertise__c expertiseObj_2 = TestHelper.createExpertise('Test_Expertise_2');

        // update expertise
        pgRef.getParameters().put('action', 'save');
        pgRef.getParameters().put('data', '{"id":"' + expertiseObj_2.Id + '","name":"Test_Expertise_2a"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status , expertiseServerObj.response.message);
 
        // create another expertise
        Expertise__c expertiseObj_3 = TestHelper.createExpertise('Test_Expertise_3');

        //merge expertises
        pgRef.getParameters().put('action', 'mergeExpertises');
        pgRef.getParameters().put('data', '{"fromExpertiseId":"' + expertiseObj_3.Id + '","toExpertiseId":"' + expertiseObj_2.Id + '"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status , expertiseServerObj.response.message);

        // search expertise
        pgRef.getParameters().put('action', 'deleteExpertise');
        pgRef.getParameters().put('data', '{"expertiseId":["' + expertiseObj_2.Id + '"]}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status , expertiseServerObj.response.message);

        Test.stopTest();
        
    }
    @isTest static void testSearchExpertise() {
    	init();
		ExpertiseDataServer expertiseServerObj = new ExpertiseDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        
        // search expertise
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"term":"tes","size":9999}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status , expertiseServerObj.response.message);
        Test.stopTest();
        
    }
    @isTest static void testSearchNewHireByDays()
    {
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
        PeopleDataServer serverObj = new PeopleDataServer();
        
        pgRef.getParameters().put('data', '{"size":16,"sortBy":"hire_date","siteId":null,"filter_days":"1months"}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);

        pgRef.getParameters().put('data', '{"size":16,"sortBy":"hire_date","siteId":null,"filter_days":"30days"}');
        Test.setCurrentPage(pgRef);
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }
    @isTest static void testSearchByFilterAndSorting() {
        User adminObj = getAdminUser();
        system.runAs(adminObj) {
            
            init();
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');
            pgRef.getParameters().put('data', '{"term":"' + peopleObj.Full_Name__c + '","userCategory":"all","department":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "my_department", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "my_department", "userCategory":"all","department":"all","location":"all","sortBy":"random","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "my_location", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "my_location", "userCategory":"all","department":"all","location":"all","sortBy":"random","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
                        
            pgRef.getParameters().put('data', '{"filter": "custom_field", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "custom_field", "userCategory":"all","department":"all","location":"all","sortBy":"random","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            Test.stopTest();
        }
    }

    @isTest static void testSearchByFilterAndNextPageToken() {
        User adminObj = getAdminUser();
        system.runAs(adminObj) {
            init();
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');

            pgRef.getParameters().put('data', '{"filter": "following","expertise_term":"newTerm","userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "leadership", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "leadership","nextPageToken":10, "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "direct_reports", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "direct_reports","nextPageToken":10, "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);

            Test.stopTest();
        }
    }

    @isTest static void testSearchByFilter() {
        User adminObj = getAdminUser();
            init();
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');
            pgRef.getParameters().put('data', '{"filter": "new_hires","userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
        	Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "new_hires","nextPageToken":10, "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "celebrations", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
            pgRef.getParameters().put('data', '{"filter": "favorite", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"siteId":"'+ getSite().Id +'","filter": "site_members", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            Test.stopTest();
    }

    @isTest static void testSearchByFilter2() {
        User adminObj = getAdminUser();
            init();
            App_config__c appConfig = [SELECT Id, PP_BirthDate_Display__c, PP_JoiningDate_Display__c FROM App_config__c LIMIT 1];
            appConfig.PP_BirthDate_Display__c = false;
            update appConfig;
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');
        	Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));            
            pgRef.getParameters().put('data', '{"filter": "celebrations", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            Test.stopTest();
    }

    @isTest static void testSearchByFilter3() {
        User adminObj = getAdminUser();
            init();
            App_config__c appConfig = [SELECT Id, PP_BirthDate_Display__c, PP_JoiningDate_Display__c FROM App_config__c LIMIT 1];
            appConfig.PP_JoiningDate_Display__c = false;
            update appConfig;
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');
        	Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));            
            pgRef.getParameters().put('data', '{"filter": "celebrations", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            Test.stopTest();
    }
    
    @isTest static void testSearchBySiteIdFilterAndTerm() {
        User adminObj = getAdminUser();
        system.runAs(adminObj) {
            init();
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');

            pgRef.getParameters().put('data', '{"siteId":"'+ getSite().Id +'","filter": "site_followers", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "site_members_and_followers", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            

            
            pgRef.getParameters().put('data', '{"filter": "","term":"' + peopleObj.Full_Name__c + '", "includeTotal": false, "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);

            Test.stopTest();
        }
    }


    @isTest static void testSearchByFilterAndId() {
        User adminObj = getAdminUser();
        system.runAs(adminObj) {
            init();
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');
			
            pgRef.getParameters().put('data', '{"filter": "","term":"' + peopleObj.Full_Name__c + '", "includeTotal": false, "chatterGroupId":"0F961000000EfSTCA0", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
        	pgRef.getParameters().put('data', '{"filter": "following", "sfUserId":"' + peopleObj.User__c + '","term":"apex", "userCategory":"all","department":"all","location":"gur @@ dd @@ In","sortBy":"alphabetical","size":10,"name_term":"site","title_term":"codeCoverage","telephone_term":"1234","city_term":"gur","state_term":"dd","country_term":"In"}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "followers", "sfUserId":"' + peopleObj.User__c + '", "userCategory":"all","department":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "featured", "profileId":"' + peopleObj.Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"filter": "managers", "siteId":"' + getSite().Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            Test.stopTest();
        }
    }


    @isTest static void testSearchBySiteIdContentId() {
        User adminObj = getAdminUser();
        system.runAs(adminObj) {
            init();
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');

            pgRef.getParameters().put('data', '{"filter": "members", "siteId":"' + getSite().Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"hire_date","size":10}');
            Test.setCurrentPage(pgRef);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.debugLogs);
            
            pgRef.getParameters().put('data', '{ "siteId":"' + getSite().Id + '","contentId":"' + getContent(ServiceConstants.TYPE_EVENT).Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10,"isPrivate":false}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.debugLogs);
            
            pgRef.getParameters().put('data', '{"filter": "members","contentId":"' + getContent(ServiceConstants.TYPE_BLOGPOST).Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.debugLogs);
            
            Test.stopTest();
        }
    }

    @isTest static void testSearchByContentIdProfileIdExpertiseId() {
        User adminObj = getAdminUser();
            init();
            People__c peopleObj = getPeople(adminObj.Id);
            PeopleDataServer serverObj = new PeopleDataServer();
            Topic topicObj = getTopic();
            Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(getContent(ServiceConstants.TYPE_BLOGPOST).id, 'site_members' , peopleObj.id);
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');
            
            pgRef.getParameters().put('data', '{"contentId":"' + getContent(ServiceConstants.TYPE_BLOGPOST).Id + '", "filter":"read", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
            Test.setCurrentPage(pgRef);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('data', '{"PageName":"Favorites","filter": "favorites", "profileId":"' + peopleObj.Id + '", "userCategory":"all","department":"all","location":"all","size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            Expertise__c expertiseObj = [select id From Expertise__c where Display_Name__c =: 'PeopleDataServer_test_addExpertise'];
            pgRef.getParameters().put('action', 'search');
            pgRef.getParameters().put('data', ' {"size":16,"Custom_Field_1__c":"all","limitToSubsegment":"true","userCategory":"all","term":"","expertise":{"id":"'+expertiseObj.id+'","name":"newTopic"},"department":null,"sortBy":"alphabetical","location":null,"includeTotal":true}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            pgRef.getParameters().put('action', 'search');
            pgRef.getParameters().put('data', ' {"size":16,"Custom_Field_1__c":"all","limitToSubsegment":"true","userCategory":"all","term":"","expertiseId":"'+expertiseObj.id+'","department":null,"sortBy":"alphabetical","location":null,"includeTotal":null}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            
            Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test Page', 'Page', 'Submitted', getAdminUser(), getSite());
            Must_Read_Audit__c mustReadObj1 = TestHelper.createMustReadAudit(simpplrContent.id, 'site_members' , peopleObj.id);
            pgRef.getParameters().put('data', '{"contentId":"contentId", "filter":"unread","includeTotal":true,"size":10}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);

            Test.stopTest();
    }

    @isTest static void testSearchById(){
        Test.startTest();
        init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        Audience__c audienceObj = getAudience();
        PeopleDataServer serverObj = new PeopleDataServer();
        Topic topicObj = getTopic(); 
    	List<App_Integration__c> appIntegrationObjList = TestHelper.createAppIntegrationRecords(false, new Set<String>{'twitter', 'facebook', 'linkedin', 'slack','microsoftteams'});
    	List<People_Integration__c> peopleIntegrationObjList = TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, peopleObj.id, 'asdasd');
        
         
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{ "siteId":"' + getSite().Id + '","contentId":"' + getContent(ServiceConstants.TYPE_EVENT).Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10,"isPrivate":true}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        
        pgRef.getParameters().put('data', '{"filter": "followers","sfUserId":"' + peopleObj.User__c + '","expertise_term":"apex", "userCategory":"all","department":"all","location":"GUR@@HAR@@INDIA","sortBy":"alphabetical","size":10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{ "siteId":"' + getSite().Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
	
        Test.stopTest();
        
    }

    @isTest static void testSearchBySiteId(){
        Test.startTest();
        init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        Audience__c audienceObj = getAudience();
        PeopleDataServer serverObj = new PeopleDataServer();
        Topic topicObj = getTopic();   
         
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
        Site_Role__c siteroleObj = [Select Id from Site_Role__c Where Site__c = :getSite().Id];
        siteroleObj.Is_Manager__c = true;
        update siteroleObj;
        pgRef.getParameters().put('data', '{"filter":"managers", "siteId":"' + getSite().Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
		Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
 
        siteroleObj.Is_Manager__c = false;
        siteroleObj.Is_Content_Manager__c = true;
        update siteroleObj;
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        siteroleObj.Is_Manager__c = false;
        siteroleObj.Is_Content_Manager__c = false;        
        CollaborationGroup colabGroupObj= [Select id From CollaborationGroup where name =: 'PeopleDataServerTest_Grp1'];
        TestHelper.changeCollaborationGroupOwner( colabGroupObj.id, adminObj.id);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
              
        pgRef.getParameters().put('data', '{"filter":"managers", "siteId":"' + getSite().Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10}');
		Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{"filter":"following", "sfUserId":"' + peopleObj.User__c + '","expertise_term":"Test_Expertise_2a","userCategory":"all","sortBy":"alphabetical","size":10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        Test.stopTest();
        
    }
    
    @isTest static void testSearchBySorting(){
        init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        Audience__c audienceObj = getAudience();
        PeopleDataServer serverObj = new PeopleDataServer();
        Topic topicObj = getTopic();
         
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');

        pgRef.getParameters().put('data', '{"filter": "managers", "siteId":"' + getSite().Id + '", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10,"contentId" : "' + getContent(ServiceConstants.TYPE_BLOGPOST).Id + '"}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);

        pgRef.getParameters().put('data', '{"includeTotal":true, "userCategory":"all","department":"all","location":"GUR @@ HAR @@ INDIA","sortBy":"alphabetical","size":10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{"filter": "following", "userCategory":"all","department":"all","location":"all","sortBy":"random","size":10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{"filter": "favorite", "userCategory":"all","department":"all","location":"all","sortBy":"random","size":10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message); 

        Test.stopTest();
        
    }

    @isTest static void testSearchByTopicIdAndAudienceId(){
        Test.startTest();
        init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        Audience__c audienceObj = getAudience();
        PeopleDataServer serverObj = new PeopleDataServer();
        Topic topicObj = getTopic();  
         
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');

        pgRef.getParameters().put('data', '{"filter": "following", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10, "nextPageToken" :10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	
    	pgRef.getParameters().put('data', '{"filter": "following", "userCategory":"all","department":"all","location":"all","sortBy":"alphabetical","size":10,"topicId":"' + topicObj.Id + '", "nextPageToken" :10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);  
        
        pgref.getParameters().put('data', '{"audienceId": "'+audienceObj.Id+'", "term":"' + peopleObj.Full_Name__c + '"}');
        test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

    @isTest static void testSearchSegment() {
    	init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        Segment__c segmentObj = getSegment();
        People__c peopleObj2 = [Select Id from People__c Where User__r.lastName = 'PeopleDataServerTest_admin' Limit 1];
        Site_Role__c siteroleObj = [Select Id from Site_Role__c Where Site__c = :getSite().Id];
        siteroleObj.People__c = peopleObj2.id;
        siteroleObj.Is_Deleted__c = false;
        siteroleObj.Is_Member__c = true;
        siteroleObj.Is_Content_Manager__c = true;
        update siteroleObj;

        Test.startTest();
        PeopleDataServer serverObj = new PeopleDataServer();
        
        init();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
    	pgRef.getParameters().put('data', '{"segmentId":"' + segmentObj.id + '","term":"' + peopleObj.Full_Name__c + '","limitToSubsegment":"true","department":"all","location":"India@@Harayana@@Gurgaon","sortBy":"alphabetical","size":10,"nextPageToken":10}');
    	Test.setCurrentPage(pgRef);
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{"filter": "my_department", "userCategory":"all","department":"all","location":"","sortBy":"alphabetical","size":10}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{"size":16,"siteId":"'+ getSite().Id +'","type":"members","term":""}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
                
        siteroleObj.Is_Member__c = false;
        siteroleObj.Is_Content_Manager__c = false;
        update siteroleObj;
        pgRef.getParameters().put('data', '{"size":16,"siteId":"'+ getSite().Id +'","type":"followers","term":""}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

    @isTest static void testSearchSegmentWithoutTerm() {
        Test.startTest();
    	init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        People__c peopleObj2 = [Select Id from People__c Where User__r.lastName = 'PeopleDataServerTest_admin' Limit 1];
        Site_Role__c siteroleObj = [Select Id from Site_Role__c Where Site__c = :getSite().Id];
        siteroleObj.People__c = peopleObj2.id;
        siteroleObj.Is_Deleted__c = false;
        siteroleObj.Is_Member__c = true;
        siteroleObj.Is_Content_Manager__c = true;
        update siteroleObj;
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
    	pgRef.getParameters().put('data', '{"size":16,"siteId":"'+ getSite().Id +'","type":"requests","term":""}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }
    @isTest static void testSearchSegmentByMemberTypeForSiteWithoutTerm(){
        init();
        User adminObj = getAdminUser();
        PeopleDataServer serverObj = new PeopleDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":16,"includeMemberTypeForSite":"'+ getSite().Id +'"}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
		Test.stopTest();
    }
    
    @isTest static void testSearchSegmentSiteData(){
        init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id); 
        People__c peopleObj2 = [Select Id from People__c Where User__r.lastName = 'PeopleDataServerTest_admin' Limit 1];
        Site_Role__c siteroleObj = [Select Id from Site_Role__c Where Site__c = :getSite().Id];
        siteroleObj.People__c = peopleObj2.id;
        siteroleObj.Is_Deleted__c = false;
        siteroleObj.Is_Member__c = true;
        siteroleObj.Is_Content_Manager__c = true;
        update siteroleObj;
        siteroleObj.Is_Member__c = true;
        siteroleObj.Is_Manager__c = true;
        update siteroleObj;
        PeopleDataServer serverObj = new PeopleDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":16,"siteId":"'+ getSite().Id +'","type":"requests","term":"dummy"}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }
    
        @isTest static void testSearchSegmentByMemberTypeForSiteWithTerm(){
        init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id); 
                
        PeopleDataServer serverObj = new PeopleDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":16,"term":"test","includeMemberTypeForSite":"'+ getSite().Id +'"}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
      	Test.stopTest();
    }
    
        @isTest static void testSearchSegmentSiteId(){
        init();
        User adminObj = getAdminUser();
        PeopleDataServer serverObj = new PeopleDataServer();
         People__c peopleObj2 = [Select Id from People__c Where User__r.lastName = 'PeopleDataServerTest_admin' Limit 1];
        Site_Role__c siteroleObj = [Select Id from Site_Role__c Where Site__c = :getSite().Id];
        siteroleObj.People__c = peopleObj2.id;
        siteroleObj.Is_Deleted__c = false;
        siteroleObj.Is_Member__c = true;
        siteroleObj.Is_Content_Manager__c = true;
        update siteroleObj;
        siteroleObj.Is_Member__c = true;
        siteroleObj.Is_Manager__c = true;
        update siteroleObj;
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        pgRef.getParameters().put('data', '{"size":16,"siteId":"'+ getSite().Id +'","term":"dummy"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
		Test.stopTest();
    }
    
    
    @isTest static void testSearchSubscription() {
        Test.startTest();
        init();
        
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        Subscription__c subscriptionObj = getSubscription();
        PeopleDataServer serverObj = new PeopleDataServer();
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'search');
    	pgRef.getParameters().put('data', '{"subscriptionId":"' + subscriptionObj.id + '","department":"all","location":"all","sortBy":"alphabetical","size":10}');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        
        Test.stopTest();
    }
    
    @isTest static void testActions() {
        Test.startTest();
    	init();

    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        People_Category__c peopleCategoryObj = new People_Category__c();
        peopleCategoryObj.Name__c = 'testPeopleCategory';
        insert peopleCategoryObj;
    	List<App_Integration__c> appIntegrationObjList = TestHelper.createAppIntegrationRecords(false, new Set<String>{'twitter', 'facebook', 'linkedin', 'slack'});
    	List<People_Integration__c> peopleIntegrationObjList = TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, peopleObj.id, 'asdasd');
        
        PeopleDataServer serverObj = new PeopleDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'getCompanyStats'); 
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('action', 'getUser');
    	pgRef.getParameters().put('data', '{"peopleId":"' + peopleObj.id + '","includeCustomFields":"true"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        User userObj = TestHelper.createUser('PeopleDataServerTest_user', null, false);
        pgRef.getParameters().put('action', 'getUser');
    	pgRef.getParameters().put('data', '{"peopleId":"' + userObj.id + '","includeCustomFields":"true"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
       
    	Test.stopTest();
    	
    }

    @isTest static void testActionsById() {
        Test.startTest();
    	init();

    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        People_Category__c peopleCategoryObj = new People_Category__c();
        peopleCategoryObj.Name__c = 'testPeopleCategory';
        insert peopleCategoryObj;
    	List<App_Integration__c> appIntegrationObjList = TestHelper.createAppIntegrationRecords(false, new Set<String>{'twitter', 'facebook', 'linkedin'});
    	List<People_Integration__c> peopleIntegrationObjList = TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, peopleObj.id, 'asdasd');
        
        PeopleDataServer serverObj = new PeopleDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'getFollowStats');
    	pgRef.getParameters().put('data', '{"peopleId":"' + peopleObj.id + '"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	
		pgRef.getParameters().put('action', 'setCoverImage');
    	pgRef.getParameters().put('data', '{"peopleId":"' + peopleObj.id + '"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	
    	pgRef.getParameters().put('action', 'getInstallStats');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);

    	pgRef.getParameters().put('action', 'getCustomFields');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	
    	pgRef.getParameters().put('action', 'getLocation');
    	pgRef.getParameters().put('locationId', 'Gurgaon@@Haryana@@India');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	
        pgRef.getParameters().put('action', 'getPeopleByUserId');
        pgRef.getParameters().put('userId', adminObj.id);
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            	
    	pgRef.getParameters().put('action', 'searchDepartment');
        pgRef.getParameters().put('data', '{"size":10}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	Test.stopTest();
    	
    }

    @isTest static void testIntegrationActions() {
      
    	init();

        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "twitter"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/campaigndataserver/twitterRequest',false));
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "facebook"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "linkedin"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);

        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_BOX});
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_BOX,appIntegList[0].id);
		SimpplrContext.IsBoxIntegrationEnabled = true;		
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "box"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
    	
        Test.stopTest();
    }
    @isTest static void testIntegrationActionSlackUnfurl() {
        Test.startTest();
    	init();

    	PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "slackUnfurl"}');
    	Test.setCurrentPage(pgRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/slackUnfurl',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        
    	Test.stopTest();
    	
    }
    @isTest static void testIntegrationActionGoogleCalendar() {
        Test.startTest();
    	init();

    	PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "googlecalendar"}');
    	Test.setCurrentPage(pgRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'googleCalendarEvents',false));
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

    @isTest static void testIntegrationActionTwitterAndBox() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');

        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "twitter"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest(); 
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "box"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        Test.stopTest();
    }

    @isTest static void testIntegrationActionDisconnectAppSlackContentShare() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');

        App_Integration__c appIntegObj = new App_Integration__c();
        appIntegObj.Name = 'slackContentShare';
        appIntegObj.Is_Deleted__c = false;
		appIntegObj.Org_Id__c = UserInfo.getOrganizationId();
        appIntegObj.Integration_Enabled__c = true;
        appIntegObj.Client_Id__c = 'clientId';
        appIntegObj.Client_Secret__c = 'clientSecret';
        appIntegObj.User_Email__c = 'dummy@simpplr.com';
        insert appIntegObj;
        People_Integration__c pIntegObj = TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE,appIntegObj.id);
        pIntegObj.Connected__c = true;
        update pIntegObj;
        Simpplr_Site__c siteConfigObj = new Simpplr_Site__c();
        siteConfigObj.Slack_Site_Manager__c=UserContext.peopleId;
        insert siteConfigObj;
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "slackContentShare"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest static void testIntegrationActionDisconnectAppGoogledrive(){
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));

        PageReference pgRef = Page.DataServerRW;                
        PeopleDataServer serverObj = new PeopleDataServer();

        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "googledrive"}');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

    @isTest static void testGetUserWebpushTokens(){
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'web-push-manager',false));

        PageReference pgRef = Page.DataServerRW;                
        PeopleDataServer serverObj = new PeopleDataServer();

        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'getUserWebpushTokens');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }
    
    
    @isTest static void testSearchLocation(){
    	init();
        User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
		PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeopleLocation',false));
        pgRef.getParameters().put('action', 'searchLocation');
        pgRef.getParameters().put('data', '{"term":"' + peopleObj.Full_Name__c + '", "size": 10}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{"term":"", "size": 10}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	 
    	Test.stopTest();
    }

    @isTest static void testGetGoogleCalenders(){
    	init();
		PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'googleCalendarEvents',false));
        pgRef.getParameters().put('action', 'getGoogleCalendars');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
    	
    	 
    	Test.stopTest();
    }

    @isTest static void testIntegrationActionsSharepoint() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'sharepoint';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "sharepoint"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testIntegrationActionsConnectAppMicrosoftTeams() {
        Test.startTest();
    	init();
        SimpplrContext.isFeatureMicrosoftTeamsEnabled = true;
        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'microsoftteams';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "microsoftteams"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }

    @isTest static void testIntegrationActionsDisconnectAppMicrosoftTeams() {
       
    	init();
        SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2=true;
        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'microsoftteams';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        SimpplrContext.uuid = 'sfshfso-sfowf-wdvns-lsdhfos';
        UserContext.uuid = 'vnkhjs-ndfhgao-xnvjsk-shfs';
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS,appIntegList.id);	
        Simpplr_Site__c siteObj = getSite();
        siteObj.Microsoft_Teams_Site_Manager__c = UserContext.peopleId;
        update siteObj;
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "microsoftteams"}');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/externalSearch',false));
    	Test.setCurrentPage(pgRef);
        Test.startTest();
    	serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }

    @isTest static void testIntegrationActionsDisconnectAppMicrosoftTeams1() {
       
    	init();
        SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2=false;
        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        SimpplrContext.uuid = 'test-account-id';
        UserContext.uuid = 'test-user-id';
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'microsoftteams';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS,appIntegList.id);	
        Simpplr_Site__c siteObj = getSite();
        siteObj.Microsoft_Teams_Site_Manager__c = UserContext.peopleId;
        update siteObj;
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "microsoftteams"}');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/externalSearch',false));
    	Test.setCurrentPage(pgRef);
        Test.startTest();
    	serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }

    @isTest static void testIntegrationActionsConnectAppGoogleDrive() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'googledrive';
        appIntegList.Is_Deleted__c = false;
	    appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "googledrive"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testIntegrationActionsConnectAppGoogleCalendar() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'googlecalendar';
        appIntegList.Is_Deleted__c = false;
	    appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "googlecalendar"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testIntegrationActionsConnectAppSlackContentShare() {
        Test.startTest();
    	init();
        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'slack';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "slackContentShare"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
     @isTest static void testIntegrationActionsConnectAppServicenow() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'servicenow';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
		appIntegList.connected__c = true;
        appIntegList.Client_Id__c = Utility.encryptFn('clientid');
        appIntegList.Client_Secret__c = Utility.encryptFn('clientsecret');
		appIntegList.DB_User_Client_Id__c = 'dummay';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName":"servicenow"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testIntegrationActionsConnectAppDropbox() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;	
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'dropbox';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        appIntegList.DB_User_Client_Id__c = 'dummay';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_DROPBOX,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "dropbox"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testIntegrationActionsConnectAppFacebook() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "facebook"}');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testIntegrationActionsConnectAppOnedrive() {
        Test.startTest();
    	init();

        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'onedrive';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE,appIntegList.id);	
        pgRef.getParameters().put('action', 'connectApp');
        pgRef.getParameters().put('data', '{"appName": "onedrive"}');
    	Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testGetEndorsements() {
        Test.startTest();
        init();

        PeopleDataServer serverObj = new PeopleDataServer();
        User adminObj = getAdminUser();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'getEndorsements');
    	pgRef.getParameters().put('sfUserId', adminObj.Id );
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testGetFieldValues() {
        Test.startTest();
        init();
        User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgref = Page.DataServerRW;
        
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action','getFieldValues');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('data', '{"filter": "following", "term":"' + peopleObj.Full_Name__c + '", "columnName":"First_Name__c", "department":"all","location":"all","sortBy":"alphabetical","size":10,"nextPageToken" :10}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        Test.stopTest();
    }
    
    @isTest static void testRemoveEndorsement() {
        Test.startTest();
        init();

        User adminObj = getAdminUser();
        Topic topicObj = getTopic();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        PeopleDataServer serverObj = new PeopleDataServer();
        Simpplr_Metadata__c metdataObj = new Simpplr_Metadata__c();
        metdataObj.User__c = UserContext.Id;
        metdataObj.Topic__c = topicObj.Id;
        metdataObj.Type__c = 'Endorsement';
        insert metdataObj;
        pgRef.getParameters().put('action', 'removeEndorsement');
        Test.setCurrentPage(pgRef);
    	serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"sfUserId":"' + adminObj.Id + '","topicId":"' + topicObj.Id + '"}');
    	serverObj.handleRequest();
        
        SimpplrContext.isExternalSearchEnabled = true;
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }

    @isTest static void testUndefinedActionwithoutData() {
        
    	init();
		Test.startTest();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'undefinedAction');
    	pgRef.getParameters().put('data', '{}');
    	Test.setCurrentPage(pgRef);
    	
        PeopleDataServer serverObj = new PeopleDataServer();
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status , serverObj.response.message);
        
        Test.stopTest();
        
    }


    @isTest static void testActionSearch() {
        
    	init();
        Topic topicObj = getTopic();
        PageReference pgRef = Page.DataServerRW;
        PeopleDataServer serverObj = new PeopleDataServer();
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"userCategory":"all","department":"all","sortBy":"alphabetical","size":10,"topicId":"' + topicObj.Id + '", "nextPageToken" :10}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest(); 
    }    
    @isTest static void testMissingAction() {
        Test.startTest();
    	init();
        PeopleDataServer serverObj = new PeopleDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', '');
        Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testPeopleDataServerEndpoints() {
        Test.startTest();
    	init();
		string peopleId = UserContext.peopleId;
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	String dataJson = '{"peopleId":"'+peopleId+'","includeParent":true,"includeGrandparent":true,"includeChildren":true}';
    	pgRef.getParameters().put('data', dataJson);
        pgRef.getParameters().put('action', 'getOrgChart');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    @isTest static void testPeopleDataServerEndpointsOrgChart() {
        Test.startTest();
    	init();
		string peopleId = UserContext.peopleId;
        List<People__c> peoplelist = new List<People__c>();
        User userObj1 = TestHelper.createUser('a', null, false);
        User userObj2 = TestHelper.createUser('b', null, false);
        User userObj3 = TestHelper.createUser('c', null, false);
        User userObj4 = TestHelper.createUser('d', null, false);
        User userObj5 = TestHelper.createUser('e', null, false);
        User userObj6 = TestHelper.createUser('f', null, false);
        User userObj7 = TestHelper.createUser('g', null, false);
        Set<Id> records = new Set<Id>{userObj1.Id,userObj2.id,userObj3.id,userObj4.id,userObj5.id,userObj6.id,userObj7.id}; //or an existing collection from elsewhere

        List<People__c> pObj = [Select id From people__c where user__c In :records];
        for(People__c obj : pObj) {
            obj.Manager__c = peopleId;
        }
        update pObj;
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	String dataJson = '{"peopleId":"'+pObj[2].Id+'","includeParent":true,"includeGrandparent":true,"includeChildren":true,"size":"8"}';
    	pgRef.getParameters().put('data', dataJson);
        pgRef.getParameters().put('action', 'getOrgChart');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    @isTest static void testPeopleDataServerEndpointsOrgChart1() {
        Test.startTest();
    	init();
		string peopleId = UserContext.peopleId;
        List<People__c> peoplelist = new List<People__c>();
        User userObj1 = TestHelper.createUser('a', null, false);
        User userObj2 = TestHelper.createUser('b', null, false);
        User userObj3 = TestHelper.createUser('c', null, false);
        User userObj4 = TestHelper.createUser('d', null, false);
        User userObj5 = TestHelper.createUser('e', null, false);
        User userObj6 = TestHelper.createUser('f', null, false);
        User userObj7 = TestHelper.createUser('g', null, false);
        Set<Id> records = new Set<Id>{userObj1.Id,userObj2.id,userObj3.id,userObj4.id,userObj5.id,userObj6.id,userObj7.id}; //or an existing collection from elsewhere

        List<People__c> pObj = [Select id, full_name__c, Manager__c From people__c where user__c In :records];
        for(People__c obj : pObj) {
            obj.Manager__c = peopleId;
        }
        update pObj;
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	String dataJson = '{"peopleId":"'+pObj[3].Id+'","includeParent":true,"includeGrandparent":true,"includeChildren":true,"size":"8"}';
    	pgRef.getParameters().put('data', dataJson);
        pgRef.getParameters().put('action', 'getOrgChart');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    @isTest static void testPeopleDataServerEndpointsOrgChart2() {
        Test.startTest();
    	init();
		string peopleId = UserContext.peopleId;
        List<People__c> peoplelist = new List<People__c>();
        User userObj1 = TestHelper.createUser('a', null, false);
        User userObj2 = TestHelper.createUser('b', null, false);
        User userObj3 = TestHelper.createUser('c', null, false);
        User userObj4 = TestHelper.createUser('d', null, false);
        User userObj5 = TestHelper.createUser('e', null, false);
        User userObj6 = TestHelper.createUser('f', null, false);
        User userObj7 = TestHelper.createUser('g', null, false);
        Set<Id> records = new Set<Id>{userObj1.Id,userObj2.id,userObj3.id,userObj4.id,userObj5.id,userObj6.id,userObj7.id}; //or an existing collection from elsewhere

        List<People__c> pObj = [Select id, full_name__c, Manager__c From people__c where user__c In :records];
        for(People__c obj : pObj) {
            obj.Manager__c = peopleId;
        }
        update pObj;
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	String dataJson = '{"peopleId":"'+pObj[4].Id+'","includeParent":true,"includeGrandparent":true,"includeChildren":true,"size":"8"}';
    	pgRef.getParameters().put('data', dataJson);
        pgRef.getParameters().put('action', 'getOrgChart');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    @isTest static void testGetOrgChartOnProfile() {
        Test.startTest();
    	init();
		string peopleId = UserContext.peopleId;
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	String dataJson = '{"peopleId":"'+peopleId+'","includeParent":true,"size":"8","nextPageToken":"8"}';
    	pgRef.getParameters().put('data', dataJson);
        pgRef.getParameters().put('action', 'getOrgChartOnProfile');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    @isTest static void testGetOrgChartOnWithSize() {
        Test.startTest();
    	init();
		string peopleId = UserContext.peopleId;
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
    	String dataJson = '{"peopleId":"'+peopleId+'","includeParent":true,"includeGrandparent":true,"includeChildren":true,"size":8}';
    	pgRef.getParameters().put('data', dataJson);
        pgRef.getParameters().put('action', 'getOrgChart');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testRemoveExpertise() {
        Test.startTest();
        init();
        PeopleDataServer serverObj = new PeopleDataServer();
        User adminObj = getAdminUser();
        Topic topicObj = getTopic();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'removeExpertise');
        pgRef.getParameters().put('data', '{"sfUserId":"' + UserContext.id + '","topicId":"' + topicObj.Id + '"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        SimpplrContext.isExternalSearchEnabled = false;
        pgRef.getParameters().put('data', '{"sfUserId":"' + UserContext.id + '","topicId":"' + topicObj.Id + '"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testGetPageFeature() {
        Test.startTest();
    	init();
        PeopleDataServer serverObj = new PeopleDataServer();
        String pageFeature = serverObj.getPageFeature();
        System.assertEquals(AccessManager.FEATURE_SIMPPLR,pageFeature,'PeopleDataServer.testGetPageFeature Failed');
        Test.stopTest();
    }
    
    @isTest static void testSaveAboutMe() {
        Test.startTest();
        init();
        App_config__c appConfig = [SELECT Id, PDS_About_Me__c FROM App_config__c LIMIT 1];
        appConfig.PDS_About_Me__c = false;
        update appConfig;
        
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'saveAboutMe');
        pgRef.getParameters().put('peopleId', UserContext.peopleId);
        pgRef.getParameters().put('aboutMe', 'About me is nothing');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest static void testSaveAppTokenTwitter() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectexternalapp/processcodefromlinkedin', false));
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'saveAppToken');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('data','{"appName":"twitter"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        }
    
    @isTest static void testSaveAppTokenLinkedin() {
        
        init();
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'saveAppToken');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('data','{"appName":"linkedin","access_token":"abc","expires_in":1000}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectexternalapp/processCodefromlinkedin', false));
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        }
    @isTest static void testSaveWebPushPromptFlag() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectexternalapp/processcodefromlinkedin', false));
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'saveWebPushPromptFlag');
        pgRef.getParameters().put('webPushPromptFlag', 'true');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('data','true');
       
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('webPushPromptFlag', 'false');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('data','false');
       
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        Test.stopTest();
    }
       
    @isTest static void testAddEndorsement() {
        Test.startTest();
        init();
        App_Config__c appConfigRecord =[select id from App_config__c where App_Name__c =: 'TestAppName'];
        appConfigRecord.External_search_app_connected__c = false;
        update appConfigRecord;
        User adminObj = getAdminUser();
        People__c peopleObj = [Select Id from People__c Where User__c = :UserContext.Id];
        Topic topicObj = getTopic();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        Expertise__c expertiseObj_3 = TestHelper.createExpertise('Test_Expertise_3');
        pgRef.getParameters().put('action', 'addEndorsement');
    	pgRef.getParameters().put('data', '{"sfUserId":"' + adminObj.Id + '","expertiseId":"' + expertiseObj_3.Id + '"}');
    	Test.setCurrentPage(pgRef);
        PeopleDataServer serverObj = new PeopleDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'peopleDataServer/addEndorsement',false));
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
     } 
    
    @isTest static void testSearchWhenExternalSearchEnable() {
        Test.startTest();
        init();
 		PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','PeopleDataServer');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"term":"simran","filter":"favorites"}');
        Test.setCurrentPage(pageRef);
        PeopleDataServer dSObject= new PeopleDataServer(); 
       	Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchPeople',true));
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status , dSObject.response.message);

        pageRef.getParameters().put('data', '{"size":16,"term":"test","includeTotal":true}');
        Test.setCurrentPage(pageRef);
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status , dSObject.response.message);

        pageRef.getParameters().put('data', '{"size":16,"term":"test","includeTotal":false}');
        Test.setCurrentPage(pageRef);
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status , dSObject.response.message);

        pageRef.getParameters().put('data', '{"size":16,"term":"test","includeMemberTypeForSite":"'+ getSite().Id +'"}');
        Test.setCurrentPage(pageRef);
        dSObject.handleRequest(); 
        System.assertEquals('success', dSObject.response.status , dSObject.response.message);       
        Test.stopTest();
    }

    @isTest 
    static void testGetAppManagerList() {
        Test.startTest();
        init(); 
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'getAppManagerList');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }

    @isTest 
    static void testGetAppAndSegmentManagerList() {
        Test.startTest();
        init(); 
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'getAppAndSegmentManagerList');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
    
    @isTest 
    static void testCreatePeople() {
        User admin = getAdminUser();
        System.runAs(admin){
            Test.startTest();
            init();
            User userObj = TestHelper.createUser('testUserUnique', null, false);
            PeopleDataServer serverObj = new PeopleDataServer();
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'createPeople');
            pgRef.getParameters().put('data', '{"userIds":["'+userObj.Id+'"]}');
            Test.setCurrentPage(pgRef);
            serverObj.handleRequest();
            System.assertEquals('error', serverObj.response.status , 'running as expected');
            Test.stopTest();
        }
    }
    @isTest 
    static void testSendResetPasswordEmail() {
        Test.startTest();
        init(); 
        User userObj1 = getUserId();
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action','sendResetPasswordEmail');
        pgRef.getParameters().put('data', '{"userIds":["'+userObj1.Id+'"]}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        Test.stopTest();
    }
    
    @isTest 
    static void testGetCount() {
        Test.startTest();
        init();
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action','getCount');
        pgRef.getParameters().put('data', '{"includePreviousRecords":true, "departmentId":"Product", "startDate" : "2022-06-01","endDate": "2022-07-10", "locationId":"jaipur @@ Rajasthan @@ null"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
        Test.stopTest();

    }

    @isTest 
    static void testGetByIds() {
        Test.startTest();
        init();
        User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        User userObj1 = getUserId();
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action','getByIds');
        pgRef.getParameters().put('data', '["'+peopleObj.id+'"]');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
        Test.stopTest();

    }
    
    @isTest static void testSearchBulkApi(){
        Test.startTest();
        init();
    	User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        Audience__c audienceObj = getAudience();
        PeopleDataServer serverObj = new PeopleDataServer();
        Topic topicObj = getTopic(); 
         
        Segment__c segmentObj = getSegment();
        Subscription__c subscriptionObj = getSubscription();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action', 'getAllPeopleData');
        
        pgRef.getParameters().put('data', '{"nextPageToken":"token"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{ "siteId":"' + getSite().Id + '", "nextPageToken":"token"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{ "siteId":"' + getSite().Id + '", "type":"members","nextPageToken":"token"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);

        pgref.getParameters().put('data', '{"audienceId": "'+audienceObj.Id+'", "nextPageToken":"token"}');
        test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        
        pgRef.getParameters().put('data', '{"segmentId":"' + segmentObj.id + '", "limitToSubsegment":"true", "nextPageToken":"token"}');
    	test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
       
        pgRef.getParameters().put('data', '{"subscriptionId":"' + subscriptionObj.id + '","nextPageToken":16}');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
		System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }
     @isTest 
    static void testunhidePeopleExpertiseRecord() {
        Test.startTest();
        init();
        User adminObj = getAdminUser();
        People__c peopleObj = getPeople(adminObj.Id);
        User userObj1 = getUserId();
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action','getByIds');
        pgRef.getParameters().put('data', '["'+peopleObj.id+'"]');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
        Test.stopTest();

    }
    
    @isTest static void testGetUsersCountByCountry(){
        Test.startTest();
        List<AggregateResult> result=new PeopleDao().getUsersCountByCountry();
        System.assertNotEquals(0, result.size(), 'Get users count by country');
        Test.stopTest();
    }

    @isTest static void testGetUsersCountByCustomField(){
        Test.startTest();
        List<AggregateResult> result=new PeopleDao().getValues(null,'Custom_Field_1__c',3);
        System.assertNotEquals(0, result.size(), 'Get users count by Custom field');
        Test.stopTest();
    }
    
    @isTest static void testGetUserByMobileNumber(){
        Test.startTest();
        List<People__c> listOfPeople=new PeopleDao().getUserByMobileNumber('PeopleDataServerTest_usr');
        System.assertEquals('United StatesPeopleDataServerTest_usr',listOfPeople[0].Country__c, 'Successful');
        Test.stopTest();
    }
    
    @isTest static void testGetUserByEmail(){
        Test.startTest();
        List<People__c> listOfPeople=new PeopleDao().getUserByEmail('PeopleDataServerTest_usr_usr@testorg.com');
        System.assertEquals('United StatesPeopleDataServerTest_usr',listOfPeople[0].Country__c, 'Successful');
        Test.stopTest();
    }
    
    @isTest static void testUsersIFollowIdSet(){
        Test.startTest();
        User userObj=getUserId();
        set<Id> id=new PeopleDao().usersIFollowIdSet(userObj.Id);
        System.assertEquals(0,id.size(), 'Successful');
        Test.stopTest();
    }
    
    @isTest static void testGetPeopleListBySearchTermAndSegmentId(){
        Test.startTest();
        Segment__c segmentObj=getSegment();
        User userObj=getUserId();
        People__c pObj = [Select id From people__c where user__c =: userObj.id];
        List<string> peopleIds=new List<String>();
        peopleIds.add(pObj.Id);
        List<People__c> result=new PeopleDao().getPeopleListBySearchTermAndSegmentId('PeopleDataServerTest_usr',segmentObj.Id,peopleIds,1);
       	System.assertEquals(0, result.size(), 'Successful');
        Test.stopTest();
    }

    @isTest static void testGetPeopleListBySearchTermChange(){
        Criteria.People peopleWrapper = new Criteria.People();
        peopleWrapper.Custom_Field_1 = 'test';
        peopleWrapper.Custom_Field_2 = 'test';
        peopleWrapper.Custom_Field_3 = 'test';
        peopleWrapper.Custom_Field_4 = 'test';
        peopleWrapper.Custom_Field_5 = 'test';
        peopleWrapper.Custom_Field_6 = 'test';
        peopleWrapper.Custom_Field_7 = 'test';
        peopleWrapper.Custom_Field_8 = 'test';
        peopleWrapper.Custom_Field_9 = 'test';
        peopleWrapper.Custom_Field_10 = 'test';
        peopleWrapper.Custom_Field_11 = 'test';
        peopleWrapper.Custom_Field_12 = 'test';
        peopleWrapper.Custom_Field_13 = 'test';
        peopleWrapper.Custom_Field_14 = 'test';
        peopleWrapper.Custom_Field_15 = 'test';
        peopleWrapper.Custom_Field_16 = 'test';
        peopleWrapper.Custom_Field_17 = 'test';
        peopleWrapper.Custom_Field_18 = 'test';
        peopleWrapper.Custom_Field_19 = 'test';
        peopleWrapper.Custom_Field_20 = 'test';
        peopleWrapper.Custom_Field_21 = 'test';
        peopleWrapper.Custom_Field_22 = 'test';
        peopleWrapper.Custom_Field_23 = 'test';
        peopleWrapper.Custom_Field_24 = 'test';
        peopleWrapper.Custom_Field_25 = 'test';
        peopleWrapper.filterDays = 'Last_10_days';
        Test.startTest();
        PeopleDao peopleDaoObj = New PeopleDao();
        List<People__c> getAllPeopleResult= peopleDaoObj.getAllPeople(null,null,null,null,null,null,null,null,null,null,peopleWrapper);
        List<People__c> getAllPeopleDataResult= peopleDaoObj.getAllPeopleData(null,null,null,peopleWrapper);
        System.assertEquals(0, getAllPeopleResult.size(), 'Successful');
        System.assertEquals(0, getAllPeopleDataResult.size(), 'Successful');
        Test.stopTest();
    }

    @isTest static void testrefreshUserGoogleToken() {
        String bodyPass = '{"type": "Ok"}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'googleOK',bodyPass,false));
        Test.startTest();
            PeopleDataServer.refreshUserGoogleToken();
        Test.stopTest();
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];

        Set<String> integrationType = new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE,IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR};
        List<People_Integration__c> peopleInt = new List<People_Integration__c>();
        peopleInt = [select id  from People_Integration__c where People__c in:people and name in:integrationType];
        System.assertEquals(2, peopleInt.size() , 'Running as Expected');
    }

    @isTest static void testreupdateIntegrationInfo() {
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];
        Set<String> integrationType = new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE,IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR};
        List<People_Integration__c> peopleIntBefore = new List<People_Integration__c>();
        peopleIntBefore = [select id  from People_Integration__c where name in:integrationType];
        Database.delete(peopleIntBefore);
        List<App_Integration__c> appListBefore = [select id  from App_Integration__c where name in:integrationType];
        Database.delete(appListBefore);
        List<App_Integration__c> appList = TestHelper.createAppIntegrationRecords(true,integrationType);
        List<People_Integration__c> peopleInt = TestHelper.createPeopleIntegrationRecords(appList,people[0].Id,'');
        List<ConnectedUsersWrapper> wrapperList = new List<ConnectedUsersWrapper>();
        ConnectedUsersWrapper drive = new ConnectedUsersWrapper();
        drive.peopleId = people[0].Id;
        drive.type = 'drive';
        ConnectedUsersWrapper calendar = new ConnectedUsersWrapper();
        calendar.peopleId = people[0].Id;
        calendar.type = 'calendar';
        wrapperList.add(drive);
        wrapperList.add(calendar);
        String wrapper = JSON.serialize(wrapperList);
        String bodyPass = '{"type": "Ok"}';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'googleOK',bodyPass,false));
            init();
            PageReference pageRef = Page.DataServerRW;
            pageRef.getParameters().put('target','PeopleDataServer');
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('data',wrapper);
            pageRef.getParameters().put('action','updateIntegrationInfo');
            PeopleDataServer testObj = new PeopleDataServer();
            testObj.handleRequest();
        Test.stopTest();
        List<People__c> peopleAfter = new List<People__c>();
        peopleAfter = [select Id from People__c where User__c =: UserInfo.getUserId()];
        List<People_Integration__c> peopleIntAfter = new List<People_Integration__c>();
        peopleIntAfter = [select id  from People_Integration__c where People__c in:people and name in:integrationType];
        System.assertEquals(0, peopleIntAfter.size() , 'Running as Expected');
    }
  
    @isTest static void testMustRead() {
        User adminObj = getAdminUser();
        system.runAs(adminObj) {
            init();
            List<Simpplr_Content__c> contentList = [Select id From Simpplr_Content__c Where Title__c = 'PeopleDataServerTest Event' LIMIT 1];
            String contentId = contentList.size() > 0 ? contentList[0].id : null;
            
            PeopleDataServer serverObj = new PeopleDataServer();
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','PeopleDataServer');
            pgRef.getParameters().put('action', 'search');
            pgRef.getParameters().put('data', '{"contentId":"'+contentId+'", "term":"dummy", "filter":"unread", "includeTotal":true, "size":10}');
            Test.setCurrentPage(pgRef);
        
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
            serverObj.handleRequest();
            System.assertEquals('success', serverObj.response.status , serverObj.response.message);
            Test.stopTest();
        }
    }

    @isTest
    static void testGetRedirectUrl() {
        init();
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        pgRef.getParameters().put('action','getRedirectUrl');
        pgRef.getParameters().put('data', '{"appName":"outlookcalendar", "retURL":"https://test.com"}');  
        Test.setCurrentPage(pgRef);  
        Test.startTest();  
        serverObj.handleRequest();
        pgRef.getParameters().put('data', '{"appName":"microsoftteams", "retURL":"https://test.com"}');
        serverObj.handleRequest();
        pgRef.getParameters().put('data', '{"appName":"slack", "retURL":"https://test.com"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);

        pgRef.getParameters().put('data', '{"appName":"microsoftTeamsAdmin", "retURL":"https://test.com"}');
        Test.setCurrentPage(pgRef); 
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , 'failed to get msteams admin redirect url');

        pgRef.getParameters().put('data', '{"appName":"microsoftteams", "retURL":"https://test.com"}');
        Test.setCurrentPage(pgRef); 
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , 'failed to get msteams redirect url');

        pgRef.getParameters().put('data', '{"appName":"slackUnfurl", "retURL":"https://test.com"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();        
    }

    private class ConnectedUsersWrapper{
        String peopleId;
		String type;
    }

    @isTest static void testDisconnectOutlookCalendar() {
    	init();
        PeopleDataServer serverObj = new PeopleDataServer(); 
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PeopleDataServer');
        Test.setCurrentPage(pgRef);
        App_Integration__c appIntegList = new App_Integration__c();
        appIntegList.Name = 'outlookcalendar';
        appIntegList.Is_Deleted__c = false;
		appIntegList.Org_Id__c = UserInfo.getOrganizationId();
        appIntegList.Integration_Enabled__c = true;
        appIntegList.Client_Id__c = 'clientId';
        appIntegList.Client_Secret__c = 'clientSecret';
        insert appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId, 
                IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR,appIntegList.id);	

        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "outlookcalendar"}');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/externalSearch',false));
    	Test.setCurrentPage(pgRef);
        Test.startTest();
    	serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
        
    }

    @isTest static void testDisconnectAppSlack() {
        
    	init();
        PeopleDataServer serverObj = new PeopleDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PeopleDataServer');
        List<App_Integration__c> appInteList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        SimpplrContext.uuid ='adoc1-dlkji4-9238823-dlshfls';
        UserContext.uuid = 'sfjo-3ud9-lsdfji8-87sj';
        People_Integration__c pIntegObj = TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK,appInteList[0].id);
        pgRef.getParameters().put('action', 'disconnectApp');
        pgRef.getParameters().put('data', '{"appName": "slack"}');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/externalSearch',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/getJWTToken',false));
    	Test.setCurrentPage(pgRef);
        Test.startTest();
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status , 'Unable to disconnect slack from profile');
        Test.stopTest();
    }
    
    @isTest static void testSaveExternalPhoto(){
        User adminObj = getAdminUser();
        List<User> userList = new List<User>();
        userList.add(adminObj);
        String json = JSON.serialize(userList);
        People__c peopleObj = getPeople(adminObj.Id);
        Test.startTest();
        PeopleDataServer serverObj = new PeopleDataServer(); 
        PeopleDao peopleDaoObj = new PeopleDao();
        peopleDaoObj.saveExternalPhotoURL(peopleObj.Id,null,null,null);
        PeopleDao.insertPeopleInFuture(json);
        System.assertEquals('success', serverObj.response.status , serverObj.response.message);
        Test.stopTest();
    }

    @future
    private static void addPermissionSet(String userId) {
        List<PermissionSet> perAssignments = [SELECT Id, Name FROM PermissionSet where Name = 'Simpplr_User' limit 1];
        if(!perAssignments.isEmpty()) {
            PermissionSetAssignment perSetAssignObj = new PermissionSetAssignment();
            perSetAssignObj.PermissionSetId = perAssignments[0].id;
            perSetAssignObj.AssigneeId = userId;
            insert perSetAssignObj;
        }
    }
}