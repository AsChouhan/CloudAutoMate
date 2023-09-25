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
private class CampaignDataServerTest {
 
	static App_Config__c appConfig;
    static PageReference pageRef;
    static People__c currentUserPeopleObj; 
    static Social_Campaign__c campaignObj;
	static List<App_Integration__c> appIntegrationObjList;
    static List<People_Integration__c> peopleIntegrationObjList;
    
    	
    @testSetup static void setup() {
		appConfig = TestHelper.setupAppConfig();
		currentUserPeopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
		campaignObj = TestHelper.createSocialCampaign(currentUserPeopleObj.Id);
		appIntegrationObjList = TestHelper.createAppIntegrationRecords(true, new Set<String>{'twitter', 'facebook'});
		peopleIntegrationObjList = TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, getPeople().id, 'sadasdasdas'); 
        List<App_Integration__c> appIntegrationObjforLinkedin = TestHelper.createAppIntegrationRecords(true, new Set<String>{'Linkedin'});
		People_integration__c pIntegObj = TestHelper.createPeopleIntegRecordForUser(currentUserPeopleObj.id,'linkedin' ,appIntegrationObjforLinkedin[0].id);
        pIntegObj.Access_Token_Expiration_Datetime__c = system.today().addDays(2);
        update pIntegObj;
        List<Social_Campaign_Share__c> socialCampaignShareList = TestHelper.createSocialCampaignShareRecords(currentUserPeopleObj.id, campaignObj, new Set<String>{'Facebook','Twitter','Linkedin'});
        Segment__c segmentRecord = TestHelper.createSegment(currentUserPeopleObj.Id);
        Audience__c audienceRecord = TestHelper.createAudience(segmentRecord.Id); 
	}
    
    static void init() {
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','CampaignDataServer');
        Test.setCurrentPage(pageRef);
    }
    
    static Social_Campaign__c getCampaign(){
    	List<Social_Campaign__c> campaignListObj = [Select id, url__c from Social_Campaign__c LIMIT 1];
    	return campaignListObj[0];
    }
      
    static People__c getPeople(){
    	List<People__c> peopleListObj = [Select id from People__c LIMIT 1];
    	return peopleListObj[0];
    }      
	@isTest static void testEndpoints() {
        Test.startTest();
		init();
		String dataString = '';
		CampaignDataServer campaignDataServerObj = new CampaignDataServer();
		//save 
		dataString = '{"defaultDescription":"Hello dere","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","site":null,"isActive":true,"oembed":{"provider_url":"https://www.wsj.com","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","thumbnail_width":"553","version":"1.0","title":"Simpplr Raises $6M for Employee Productivity","provider_name":"WSJ","type":"link","thumbnail_height":"369","thumbnail_url":"https://si.wsj.net/public/resources/images/BN-QA589_Simppl_G_20160928153025.jpg"},"networks":{"twitter":{"isEnabled":true},"facebook":{"isEnabled":true},"linkedin":{"isEnabled":true}}}';
	    pageRef.getParameters().put('action', 'save');	
	    pageRef.getParameters().put('campaignid',null);
        pageRef.getParameters().put('data', dataString);
        Test.setCurrentPage(pageRef);
        campaignDataServerObj.handleRequest();	
        System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
	    
        Audience__c audience = [Select id from Audience__c LIMIT 1];
        dataString = '{"recipient":"audience","audience":{"audienceId":"'+audience.id+'"},"defaultDescription":"Hello dere","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","site":null,"isActive":true,"oembed":{"provider_url":"https://www.wsj.com","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","thumbnail_width":"553","version":"1.0","title":"Simpplr Raises $6M for Employee Productivity","provider_name":"WSJ","type":"link","thumbnail_height":"369","thumbnail_url":"https://si.wsj.net/public/resources/images/BN-QA589_Simppl_G_20160928153025.jpg"},"networks":{"twitter":{"isEnabled":true},"facebook":{"isEnabled":true},"linkedin":{"isEnabled":true}}}';
        pageRef.getParameters().put('data', dataString);
        campaignDataServerObj.handleRequest();
        System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
        
        dataString = '{"recipient":"everyone","defaultDescription":"Hello dere","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","site":null,"isActive":true,"oembed":{"provider_url":"https://www.wsj.com","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","thumbnail_width":"553","version":"1.0","title":"Simpplr Raises $6M for Employee Productivity","provider_name":"WSJ","type":"link","thumbnail_height":"369","thumbnail_url":"https://si.wsj.net/public/resources/images/BN-QA589_Simppl_G_20160928153025.jpg"},"networks":{"twitter":{"isEnabled":true},"facebook":{"isEnabled":true},"linkedin":{"isEnabled":true}}}';
        pageRef.getParameters().put('data', dataString);	
        campaignDataServerObj.handleRequest();
        System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
            
        dataString = '{"recipient":"segment","defaultDescription":"Hello dere","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","site":null,"isActive":true,"oembed":{"provider_url":"https://www.wsj.com","url":"https://www.wsj.com/articles/simpplr-raises-6m-for-employee-productivity-1475148604","thumbnail_width":"553","version":"1.0","title":"Simpplr Raises $6M for Employee Productivity","provider_name":"WSJ","type":"link","thumbnail_height":"369","thumbnail_url":"https://si.wsj.net/public/resources/images/BN-QA589_Simppl_G_20160928153025.jpg"},"networks":{"twitter":{"isEnabled":true},"facebook":{"isEnabled":true},"linkedin":{"isEnabled":true}}}';
        pageRef.getParameters().put('data', dataString);
        campaignDataServerObj.handleRequest();
        System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
    	
    	//get
    	campaignObj = getCampaign();
    	pageRef.getParameters().put('action', 'get');
    	pageRef.getParameters().put('campaignId', campaignObj.id);
	    Test.setCurrentPage(pageRef);
	    campaignDataServerObj.handleRequest();
	    System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
	     
	    //search 
	    dataString = '{"filter":null,"sortBy":"latest","size":12,"nextPageToken":2}'; 
		pageRef.getParameters().put('action', 'search');
    	pageRef.getParameters().put('data', dataString);
	    Test.setCurrentPage(pageRef);
	    campaignDataServerObj.handleRequest();	
	    System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
	    
	    //setActive
		pageRef.getParameters().put('action', 'setActive');
    	pageRef.getParameters().put('campaignId', campaignObj.id);
    	pageRef.getParameters().put('isActive', 'false');
	    Test.setCurrentPage(pageRef);
	    campaignDataServerObj.handleRequest();	
	    System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
	    
	    //search for expired
	    dataString = '{"filter":"expired","sortBy":"latest","size":12}'; 
		pageRef.getParameters().put('action', 'search');
    	pageRef.getParameters().put('data', dataString);
	    Test.setCurrentPage(pageRef);
	    campaignDataServerObj.handleRequest();	
	    System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');      
	   
	    //getShareHistory 
	    Social_Campaign__c campaignObj1 = getCampaign();
        update campaignObj1;
	    dataString = '{"campaignId":"' + campaignObj1.id+ '","size":16}';
		pageRef.getParameters().put('action', 'getShareHistory');
		pageRef.getParameters().put('data', dataString);
	    Test.setCurrentPage(pageRef);
	    campaignDataServerObj.handleRequest();	    
	    System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
        
	    //delete
		pageRef.getParameters().put('action', 'delete');
    	pageRef.getParameters().put('campaignId', campaignObj.id);
	    Test.setCurrentPage(pageRef);
	    campaignDataServerObj.handleRequest();
        System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
        
        //getCampaignShareHistoryReport 
        campaignDataServerObj.getCampaignShareHistoryReport('{"campaignId":"' + campaignObj.Id + '"}');
        Test.setCurrentPage(pageRef);
       	System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
        Test.stopTest();
	}
	
    @isTest 
    static void testFacebookService() {
    	Test.startTest(); 
    	init();
    	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/campaigndataserver/facebookshare', false));
    	campaignObj = getCampaign();
    	pageRef.getParameters().put('action', 'share');
    	pageRef.getParameters().put('data', '{"campaignId":"' +  campaignObj.id + '","network":"facebook","message":"Testing"}');
    	Test.setCurrentPage(pageRef);
    	CampaignDataServer campaignDataServerObj = new CampaignDataServer();
    	campaignDataServerObj.handleRequest();
    	Test.stopTest();
    	System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
    }
    
     @isTest 
    static void testLinkedinService() {
    	Test.startTest(); 
    	init();
    	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 201, '/campaigndataserver/linkedinshare', false));
    	campaignObj = getCampaign();
    	pageRef.getParameters().put('action', 'share');
    	pageRef.getParameters().put('data', '{"campaignId":"' +  campaignObj.id + '","network":"linkedin","message":"Testing"}');
    	Test.setCurrentPage(pageRef);
    	CampaignDataServer campaignDataServerObj = new CampaignDataServer();
    	campaignDataServerObj.handleRequest();
    	Test.stopTest();
    	System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
    }
    
     @isTest 
    static void testLinkedinServiceWithoutUrl() {
    	init();
    	campaignObj = getCampaign();
        campaignObj.URL__c = Null;
        update campaignObj;
    	pageRef.getParameters().put('action', 'share');
    	pageRef.getParameters().put('data', '{"campaignId":"' +  campaignObj.id + '","network":"linkedin","message":"Testing"}');
    	Test.setCurrentPage(pageRef);
    	CampaignDataServer campaignDataServerObj = new CampaignDataServer();
    	Test.startTest(); 	
    	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 201, '/campaigndataserver/linkedinshare', false));
    	campaignDataServerObj.handleRequest();
    	Test.stopTest();
    	System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');
    }
    
    @isTest 
    static void testTwitterServiceConnection() {
		Test.startTest();    	
    	init();
    	TwitterService twitterServiceObj = new TwitterService();
    	campaignObj = getCampaign();    
		
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/campaigndataserver/twitterRequest', false));
		String resp = twitterServiceObj.getTwitterRequestToken(null);
		System.assertEquals(IntegrationConstants.TWITTER_AUTH_ENDPOINT+'abcd1234', resp, 'Running as expected');
	    
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/campaigndataserver/twitterSaveToken', false));
		Boolean saveTokenResp = twitterServiceObj.saveAccessToken('dummy', '123');
		System.assertEquals(true, saveTokenResp, 'Running as expected');  	
		Test.stopTest();
    } 
    
    @isTest 
    static void testTwitterServiceShare() {	 
    	init();
    	campaignObj = getCampaign();
    	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/campaigndataserver/twittershare', false));
    	pageRef.getParameters().put('action', 'share');
    	pageRef.getParameters().put('data', '{"campaignId":"' +  campaignObj.id + '","network":"twitter","message":"Testing"}');
    	Test.setCurrentPage(pageRef);
    	CampaignDataServer campaignDataServerObj = new CampaignDataServer();
    	Test.startTest();  
    	campaignDataServerObj.handleRequest();
    	System.assertEquals('success', campaignDataServerObj.response.status, 'Running as expected');  	
    	Test.stopTest();     
    }  

	@isTest
	static void testSearchADAudienceCampaign() {
		init();
		campaignObj = getCampaign();
        Active_Directory_Group__c adGroupObj = TestHelper.createActiveDirectoryGroup(); 
        Audience__c audienceObj = TestHelper.createAudienceForADGroup(adGroupObj.AD_Object_Id__c);
		campaignObj.Audience__c = audienceObj.Id;
		campaignObj.Recipient__c = 'audience';	
		update campaignObj;

		pageRef.getParameters().put('action', 'search');
		pageRef.getParameters().put('data', '{"size":12,"sortBy":"latest"}');
    	Test.setCurrentPage(pageRef);
    	CampaignDataServer campaignDataServerObj = new CampaignDataServer();
    	Test.startTest();  
    	campaignDataServerObj.handleRequest();
    	System.assertEquals('success', campaignDataServerObj.response.status, 'Response should be success');  	
    	Test.stopTest(); 		
	}

	@isTest
	static void getCampaignForADAudience() {
		init();
		campaignObj = getCampaign();
        Active_Directory_Group__c adGroupObj = TestHelper.createActiveDirectoryGroup(); 
        Audience__c audienceObj = TestHelper.createAudienceForADGroup(adGroupObj.AD_Object_Id__c);
		campaignObj.Audience__c = audienceObj.Id;
		campaignObj.Recipient__c = 'audience';	
		update campaignObj;
		
		pageRef.getParameters().put('action', 'get');
		pageRef.getParameters().put('campaignId', campaignObj.Id);
    	Test.setCurrentPage(pageRef);
    	CampaignDataServer campaignDataServerObj = new CampaignDataServer();
    	Test.startTest();  
    	campaignDataServerObj.handleRequest();
    	System.assertEquals('success', campaignDataServerObj.response.status, 'Response should be success');  	
    	Test.stopTest(); 			
	}
    

}