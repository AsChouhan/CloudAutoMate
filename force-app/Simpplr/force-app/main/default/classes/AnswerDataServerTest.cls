@isTest
private class AnswerDataServerTest {
    private static PageReference pageRef;
    private static AnswerDataServer answerDSObject;

    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true);
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        People_Preference__c peoplePreferenceRec = Testhelper.createPeoplePreference(peopleObj.Id);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('AnswerDataServer_Grp1','Public');
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(cgroup.Id);
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(peopleObj.Id, testSite.Id);
        Topic topicObj = TestHelper.createTopic('Q&A');
    }

    private static void init() {
        SimpplrContext.isQuestionAnswerFeatureEnabled = true;
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AnswerDataServer');
        Test.setCurrentPage(pageRef);
        answerDSObject = new AnswerDataServer();
    }

    private static User getAdminUser(){
        User userObj = [select id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
                            from User where profile.name ='System Administrator' and lastname='Simpplr_admin' LIMIT 1];
        return userObj;
    }

    private static People__c getPeople(String lastName){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
                                    Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                    From People__c where Last_Name__c =: 'Simpplr_usr1' LIMIT 1];
        return peopleObj;
    }

    private static Simpplr_Site__c getSite(String siteName){
        Simpplr_Site__c  siteObj = [Select Id From Simpplr_Site__c where Name =: siteName LIMIT 1];
        return siteObj;
    }

    @isTest static void testGetPageFeature(){
        AnswerDataServer answerDSObject= new AnswerDataServer();
        String result = answerDSObject.getPageFeature();
        System.assertEquals('SIMPPLR', result , 'Running as expected');
    }

    @isTest static void testHandleRequestWhenActionIncorrect(){
        init();
        pageRef.getParameters().put('action',null);
        pageRef.getParameters().put('data','{}');
        answerDSObject.handleRequest();
        System.assertEquals('error', answerDSObject.response.status , 'Running as expected');

        pageRef.getParameters().put('action','unknown');
        pageRef.getParameters().put('data','{}');
        answerDSObject.handleRequest();
        System.assertEquals('error', answerDSObject.response.status , 'Running as expected');
    }

    @isTest static void testHandleRequestWhenActionCreate() {
        String siteId = getSite('AnswerDataServer_Grp1').Id;
        init();
        pageRef.getParameters().put('action','create');
        pageRef.getParameters().put('data','{"body":{"test":"test"}, "questionId":"test_question_uuid", "siteId":"'+ siteId +'"}');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'qna/answer',false));
            answerDSObject.handleRequest();
            System.assertEquals('success', answerDSObject.response.status , 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestWhenActionGet() {
        String siteId = getSite('AnswerDataServer_Grp1').Id;
        init();
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('questionId', 'questionId');
        pageRef.getParameters().put('siteId', siteId);
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'qna/answer',false));
            answerDSObject.handleRequest();
            System.assertEquals('success', answerDSObject.response.status , 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestWhenActionUpdate() {
        String siteId = getSite('AnswerDataServer_Grp1').Id;
        init();
        pageRef.getParameters().put('action','update');
        pageRef.getParameters().put('questionId','questionId');
        pageRef.getParameters().put('data','{"body":{"test":"test"}, "siteId":"'+ siteId +'"}');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'qna/answer',false));
            answerDSObject.handleRequest();
            System.assertEquals('success', answerDSObject.response.status , 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestWhenActionSearch() {
        String siteId = getSite('AnswerDataServer_Grp1').Id;
        init();
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data', '{"questionId":"questionId", "size":16, "sortby":null, "nextPageToken":0,"siteId":"'+ siteId +'"}');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'qna/answer',false));
            answerDSObject.handleRequest();
            System.assertEquals('success', answerDSObject.response.status , 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestWhenActionApprove() {
        String siteId = getSite('AnswerDataServer_Grp1').Id;
        init();
        pageRef.getParameters().put('action','approve');
        pageRef.getParameters().put('data','{"answerId":"answerId","siteId":"'+siteId+'"}');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'qna/answer',false));
            answerDSObject.handleRequest();
            System.assertEquals('success', answerDSObject.response.status , 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestWhenActionUnapprove() {
        String siteId = getSite('AnswerDataServer_Grp1').Id;
        init();
        pageRef.getParameters().put('action','unapprove');
        pageRef.getParameters().put('data','{"answerId":"answerId","siteId":"'+siteId+'"}');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'qna/answer',false));
            answerDSObject.handleRequest();
            System.assertEquals('success', answerDSObject.response.status , 'Running as expected');
        Test.stopTest();
    }
}