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
private class TopicDataServerTest {
	private static App_Config__c appConfigRecord;
	private static User userObj;
	private static People__c peopleRecord;
	@testSetup static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	userObj = TestHelper.createUser('TopicDataServerTest_usr', null, false); 
    	peopleRecord = [select id from People__c where User__c =: userObj.id];
        TestHelper.createTopic('TestTopic');
    	
	}
    
     @isTest static void testHandleRequestWhenActionNull() {
        PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','TopicDataServer');
    	
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);

     	TopicDataServer TopicDSObject= new TopicDataServer();
        TopicDSObject.handleRequest();
        System.assert(true,'Running as expected');  
    } 
    
    @isTest static void testHandleRequestWhenActionAvailable() {
        Topic topicRecord = TestHelper.getTopicByName('TestTopic');
        TopicDataServer TopicDSObject= new TopicDataServer();
        PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','TopicDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','all');
        TopicDSObject.handleRequest();
        System.assert(true,'Running as expected'); 
        
        pageRef.getParameters().put('action','search');
        TopicDSObject.handleRequest(); 
        
        pageRef.getParameters().put('action','save');
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','delete');
        TopicDSObject.handleRequest();
         
        pageRef.getParameters().put('action','create');
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','get');
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('topicId',topicRecord.Id);
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":10}');
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"term":"Test","sortBy":"talkingAbout","nextPageToken":16,"size":16}');
        TopicDSObject.handleRequest();
        
        System.assert(true,'Running as expected');
    } 
    
    @isTest static void testMergeTopics() {
        Topic topicRecord = TestHelper.getTopicByName('TestTopic');
        TopicDataServer TopicDSObject= new TopicDataServer();
        PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','TopicDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','mergeTopics');
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','mergeTopics');
        pageRef.getParameters().put('data','{"fromTopicId":"'+topicRecord.Id+'","toTopicId":"'+topicRecord.Id+'"}');
        TopicDSObject.handleRequest();
        
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testDeleteTopic() {
        Topic topicRecord = TestHelper.getTopicByName('TestTopic');
        TopicDataServer TopicDSObject= new TopicDataServer();
        PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','TopicDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','deleteTopic');
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','deleteTopic');
        pageRef.getParameters().put('data','{"topicId":""}');
        TopicDSObject.handleRequest();
        
        pageRef.getParameters().put('action','deleteTopic');
        pageRef.getParameters().put('data','{"topicId":"'+topicRecord.Id+'"}');
        TopicDSObject.handleRequest();
        
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSave() { 
        PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','TopicDataServer');
        Test.setCurrentPage(pageRef);
        TopicDataServer TopicDSObject= new TopicDataServer();
        Topic topicRecord = TestHelper.createTopic('TopicDataServerTest_test_save');
        List<String> values = new List<String>{topicRecord.id,topicRecord.name};
        String str = '"id":"{0}","name":"{1}"';
		String jsonString = '{' + EmailUtility.format(str,values) + '}';
        ResponseWrapper resp = TopicDSObject.save(jsonString);
  	  	System.assert(true,'Running as expected');  
    }
    
    @isTest static void testCreateNewTopic() { 
        PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','TopicDataServer');
        Test.setCurrentPage(pageRef);
        TopicDataServer TopicDSObject= new TopicDataServer();
        Topic newTopicToInsert = new Topic(Name='TopicDataServerTest_test_createNewTopic');
        List<String> values = new List<String>{newTopicToInsert.name};
        String str = '"name":"{0}"';
		String jsonString = '{' + EmailUtility.format(str,values) + '}';
        Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(jsonString,Type.forName('Map<String,String>'));
        ResponseWrapper resp = TopicDSObject.createNewTopic(requestDataMap);
  	  	System.assert(true,'Running as expected');  
    }
    
    @isTest static void testSearchWhenExternalSearchEnable() {
		Topic topicRecord = TestHelper.getTopicByName('TestTopic');
        TestHelper.setupExpertise(); 
 		PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','TopicDataServer');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"term":"TestTopic"}');
        Test.setCurrentPage(pageRef);
        TopicDataServer dSObject= new TopicDataServer(); 
       	Test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchTopic',true));
        dSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
}