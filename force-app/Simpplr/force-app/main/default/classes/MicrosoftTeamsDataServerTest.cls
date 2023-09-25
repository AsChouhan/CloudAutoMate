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
private class MicrosoftTeamsDataServerTest {

    private static User standardUser;
	 
    @testSetup static void setup() {
        //standardUser = TestHelper.createUser('testUser', null, false);
        TestHelper.createPeopleRecordForUser(UserContext.id);
    }
    
    private static void init() {
        SimpplrContext.microsoftTeamsIntegrationEnabled = true;
        SimpplrContext.isFeatureMicrosoftTeamsEnabled = true;
    }
    
    
    @isTest static void testHandleRequestWhenActionNull() {
    	init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','MicrosoftTeamsDataServer');
        Test.setCurrentPage(pageRef);
    	MicrosoftTeamsDataServer teamsDSObj= new MicrosoftTeamsDataServer();
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        teamsDSObj.handleRequest();
        System.assertEquals('error', teamsDSObj.response.status, teamsDSObj.response.message);
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestgetJoinedTeams() {
    	init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','MicrosoftTeamsDataServer');
        Test.setCurrentPage(pageRef);
    	MicrosoftTeamsDataServer teamsDSObj= new MicrosoftTeamsDataServer();
        pageRef.getParameters().put('action','getJoinedTeams');
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'microsoftTeams',false));
        Test.startTest();
        teamsDSObj.handleRequest();
        System.assertEquals('success', teamsDSObj.response.status, teamsDSObj.response.message);
    	Test.stopTest();
    }

    @isTest static void testHandleRequestgetJoinedChannels() {
    	init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','MicrosoftTeamsDataServer');
        Test.setCurrentPage(pageRef);
    	MicrosoftTeamsDataServer teamsDSObj= new MicrosoftTeamsDataServer();
        pageRef.getParameters().put('action','getJoinedChannels');
        pageRef.getParameters().put('data','{"teamId" : "dummyId"}');
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'microsoftTeams',false));
        Test.startTest();
        teamsDSObj.handleRequest();
        System.assertEquals('success', teamsDSObj.response.status, teamsDSObj.response.message);
    	Test.stopTest();
    }

    @isTest static void testHandleRequestShareContent() {
    	init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','MicrosoftTeamsDataServer');
        Test.setCurrentPage(pageRef);
    	MicrosoftTeamsDataServer teamsDSObj= new MicrosoftTeamsDataServer();
        teamsDSObj.getPageFeature();
       	pageRef.getParameters().put('action','shareContent');
        String teamId = 'testTeam';
        String message = 'hello';
        String channelId = 'testChannel';
        String contentUrl = 'www.testcontenturl.com';
        pageRef.getParameters().put('data','{"teamId":"'+teamId+'","message":"'+message+'","channelId":"'+channelId+'","contentUrl":"'+contentUrl+'"}');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success',200,'microsoftTeams',false));
        teamsDSObj.handleRequest();
        System.assertEquals('success', teamsDSObj.response.status, teamsDSObj.response.message);
        Test.stopTest();
    }   

	@isTest static void testHandleRequestgetJoinedTeamsError() {
    	init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','MicrosoftTeamsDataServer');
        Test.setCurrentPage(pageRef);
    	MicrosoftTeamsDataServer teamsDSObj= new MicrosoftTeamsDataServer();
        pageRef.getParameters().put('action','getJoinedTeams');
        Test.setCurrentPage(pageRef);
       	Test.startTest();
        teamsDSObj.handleRequest();
        System.assertEquals('error', teamsDSObj.response.status, teamsDSObj.response.message);
    	Test.stopTest();
    }

    @isTest static void testHandleRequestgetJoinedChannelsError() {
    	init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','MicrosoftTeamsDataServer');
        Test.setCurrentPage(pageRef);
    	MicrosoftTeamsDataServer teamsDSObj= new MicrosoftTeamsDataServer();
        pageRef.getParameters().put('action','getJoinedChannels');
        pageRef.getParameters().put('data','{"teamId" : "dummyId"}');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        teamsDSObj.handleRequest();
        System.assertEquals('error', teamsDSObj.response.status, teamsDSObj.response.message);
    	Test.stopTest();
    }

    @isTest static void testHandleRequestShareContentError() {
    	init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','MicrosoftTeamsDataServer');
        Test.setCurrentPage(pageRef);
    	MicrosoftTeamsDataServer teamsDSObj= new MicrosoftTeamsDataServer();
        teamsDSObj.getPageFeature();
       	pageRef.getParameters().put('action','shareContent');
        String teamId = 'testTeam';
        String message = 'hello';
        String channelId = 'testChannel';
        String contentUrl = 'www.testcontenturl.com';
        pageRef.getParameters().put('data','{"teamId":"'+teamId+'","message":"'+message+'","channelId":"'+channelId+'","contentUrl":"'+contentUrl+'"}');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        teamsDSObj.handleRequest();
        System.assertEquals('error', teamsDSObj.response.status, teamsDSObj.response.message);
        Test.stopTest();
    }       
}