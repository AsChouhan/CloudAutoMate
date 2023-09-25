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
private class ExpertiseDataServerTest {

    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
    	People__c peopleRec = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User userObj = TestHelper.createUser('ExpertiseDataServerTest_usr', null, false);
        People__c pObj = [Select id From people__c where user__c =: userObj.id];
        User adminUserObj = TestHelper.createUser('ExpertiseDataServerTest_admin', null, true);
        
        Expertise__c expertiseObj = TestHelper.createExpertise('ExpertiseDataServer_test_addExpertise');

        People_Expertise__c pEObj_1 = TestHelper.createPeopleExpertise(expertiseObj ,pObj);
        People_Expertise__c pEObj_2 = TestHelper.createPeopleExpertise(expertiseObj, peopleRec);
        
        People_Expertise_Detail__c pEDObj_1 = TestHelper.createPeopleExpertiseDetail(pEObj_1, peopleRec);
        People_Expertise_Detail__c pEDObj_2 = TestHelper.createPeopleExpertiseDetail(pEObj_2, peopleRec);
        People_Expertise_Detail__c pEDObj_3 = TestHelper.createPeopleExpertiseDetail(pEObj_2, peopleRec);
    }
    
    private static User getAdminUser(){
		User userObj = TestHelper.getUser('System Administrator', 'ExpertiseDataServerTest_admin');
        return userObj;
    }

    private static User getStandardUser(){
		User userObj = TestHelper.getUser('Standard User', 'ExpertiseDataServerTest_usr');
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
                                                WHERE Display_Name__c = 'ExpertiseDataServer_test_addExpertise'];
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
    	pgRef.getParameters().put('target','PageDataServer');
        Test.setCurrentPage(pgRef);
    }

    @isTest static void testExpertise() {
        Test.startTest();
        init();

        User adminUserObj = getAdminUser();
        //People__c peopleAdminObj = getPeople(adminObj.Id);
        
        User standardUserObj = getStandardUser();
 		People__c peopleObj =  getPeople(standardUserObj.id);
        PeopleDataServer pDServerObj = new PeopleDataServer();
        ExpertiseDataServer expertiseServerObj = new ExpertiseDataServer();
        
        PageReference pgRef = Page.DataServerRW;
        Test.setCurrentPage(pgRef);

        // add expertise
        pgRef.getParameters().put('action', 'save');
        pgRef.getParameters().put('data', '{"id":null,"name":"Test_exp-1"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status, 'Should be success');
        
        pgRef.getParameters().put('data', '{"id":null,"name":"Test_exp-2"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status, 'Should be success');
        
        pgRef.getParameters().put('data', '{"id":null,"name":"Test_exp-3"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status, 'Should be success');

        pgRef.getParameters().put('data', '{"id":null,"name":"TestExp1"}'); // duplicate
        expertiseServerObj.handleRequest();
        System.assertEquals('error', expertiseServerObj.response.status, 'Should be error. duplicate expertise');

        // create a new expertise
        Expertise__c expertiseObj_2 = TestHelper.createExpertise('Test_Expertise_2');

        // update expertise
        pgRef.getParameters().put('action', 'save');
        pgRef.getParameters().put('data', '{"id":"' + expertiseObj_2.Id + '","name":"Test_Expertise_2a"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status, 'Should be success');

        // search expertise
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('data', '{"size":9999}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status, 'Should be success');


        //add endorsement
        pgRef.getParameters().put('action', 'addEndorsement');
        pgRef.getParameters().put('data', '{"sfUserId":"' + UserInfo.getUserId() + '","expertiseId":"' + expertiseObj_2.Id + '"}');
        pDServerObj.handleRequest();
        System.assertEquals('error', pDServerObj.response.status, 'Should be error. as involves callout');

        //add endorsement
        pgRef.getParameters().put('action', 'addEndorsement');
        pgRef.getParameters().put('data', '{"sfUserId":"' + adminUserObj.Id + '","expertiseId":"' + expertiseObj_2.Id + '"}');
        pDServerObj.handleRequest();
        System.assertEquals('error', pDServerObj.response.status, 'Should be error. as involves callout');

        // create another expertise
        Expertise__c expertiseObj_3 = TestHelper.createExpertise('Test_Expertise_3');

        //merge expertises
        TestHelper.setupPeopleExpertise(expertiseObj_3,peopleObj);
        TestHelper.setupPeopleExpertise(expertiseObj_2,peopleObj);
        pgRef.getParameters().put('action', 'mergeExpertises');
        pgRef.getParameters().put('data', '{"fromExpertiseId":"' + expertiseObj_3.Id + '","toExpertiseId":"' + expertiseObj_2.Id + '"}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status, 'Should be success');

        //remove expertise
        pgRef.getParameters().put('action', 'removeExpertise');
        pgRef.getParameters().put('data', '{"sfUserId":"' + UserInfo.getUserId() + '","expertiseId":"' + expertiseObj_2.Id + '"}');
        pDServerObj.handleRequest();
        System.assertEquals('error', pDServerObj.response.status, 'Should be error. as involves callout');

        //remove expertise - expertise wont be found
        pgRef.getParameters().put('action', 'removeExpertise');
        pgRef.getParameters().put('data', '{"sfUserId":"' + UserInfo.getUserId() + '","expertiseId":"' + expertiseObj_3.Id + '"}');
        pDServerObj.handleRequest();
        System.assertEquals('success', pDServerObj.response.status, 'Should be success');

        //remove expertise - with wrong sfUserId
        pgRef.getParameters().put('action', 'removeExpertise');
        pgRef.getParameters().put('data', '{"sfUserId":"' + expertiseObj_2.Id + '","expertiseId":"' + expertiseObj_2.Id + '"}');
        pDServerObj.handleRequest();
        System.assertEquals('error', pDServerObj.response.status, 'Should be error. as involves callout');

        // search expertise
        pgRef.getParameters().put('action', 'deleteExpertise');
        pgRef.getParameters().put('data', '{"expertiseId":["' + expertiseObj_2.Id + '"]}');
        expertiseServerObj.handleRequest();
        System.assertEquals('success', expertiseServerObj.response.status, 'Should be success');
        	
        Test.stopTest();
    }
    
   @isTest static void testSearchWhenExternalSearchEnable() {
        init();
        TestHelper.setupExpertise(); 
 		PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','ExpertiseDataServer');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"term":"testsimpplrexpertise"}');
        Test.setCurrentPage(pageRef);
        ExpertiseDataServer dSObject= new ExpertiseDataServer(); 
       	Test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchExpertise',true));
        dSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', dSObject.response.status, 'Should be success');
    }
}