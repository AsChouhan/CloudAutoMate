@isTest
private class QuestionsDataServerTest {

    public static PageReference pageRef;
    @testSetup static void setup() {        
		TestHelper.setupAppConfig(); 
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        People_Preference__c peoplePreferenceRec = Testhelper.createPeoplePreference(peopleObj.Id);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('QuestionDataServer_Grp1','Public');
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(cgroup.Id);
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(peopleObj.Id, testSite.Id);
        Topic topicObj = TestHelper.createTopic('Q&A');
    }
    
    private static PageReference init() {
        SimpplrContext.isQuestionAnswerFeatureEnabled = true;
    	pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','QuestionsDataServer');
        Test.setCurrentPage(pageRef);
        return pageRef;
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
       QuestionsDataServer questionDSObject= new QuestionsDataServer();
       String result = questionDSObject.getPageFeature();
       System.assertEquals('SIMPPLR', result , 'Running as expected');
   }
   @isTest static void testHandleRequestWhenActionNull(){
        init();
        QuestionsDataServer questionDSObject= new QuestionsDataServer();
            
        pageRef.getParameters().put('action',null);
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('error', questionDSObject.response.status , 'Running as expected');
   }
    @isTest static void testHandleRequestWhenActionAvailable() {
        String siteId = getSite('QuestionDataServer_Grp1').Id;
        init();
        QuestionsDataServer questionDSObject= new QuestionsDataServer();

        pageRef.getParameters().put('action','unknown');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('error', questionDSObject.response.status , 'Running as expected');
         
        pageRef.getParameters().put('action','create');
        pageRef.getParameters().put('data','{"title":"Question_1", "siteId":"'+ siteId +'"}'); 
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'qna/question',false));
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');
        
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('questionId', 'questionId'); 
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');  	
        
        pageRef.getParameters().put('action','unpublish');
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');
        
        pageRef.getParameters().put('action','publish');
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');
        
       	pageRef.getParameters().put('action','markAsDuplicate');
        pageRef.getParameters().put('originalQuestionId', 'originalQuestionId'); 
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');

        pageRef.getParameters().put('action','markAsNotDuplicate');
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"term":"Question", "siteId":"'+ siteId +'","offset":0,"sortBy":null,"size":0,"filter":"all"}'); 
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');
        
        pageRef.getParameters().put('action','update');
        pageRef.getParameters().put('data','{"title":"NewQuestion_1", "siteId":"'+ siteId +'"}'); 
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');
        
        pageRef.getParameters().put('action','suggestion');
        pageRef.getParameters().put('data','{"criteria":"original", "term":"new", "siteId":"'+ siteId +'"}'); 
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');
        
        pageRef.getParameters().put('action','delete'); 
        Test.setCurrentPage(pageRef);
        questionDSObject.handleRequest();
        System.assertEquals('success', questionDSObject.response.status , 'Running as expected');

        Test.stopTest();
                
     }
    
   

}