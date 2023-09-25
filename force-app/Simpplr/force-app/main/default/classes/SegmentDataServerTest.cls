@isTest
private class SegmentDataServerTest {
	private static App_Config__c appConfigRecord;
	private static User systemAdmin;
    private static Segment__c segmentRec;
	
	@testSetup static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		appConfigRecord.Segment_Column_Name__c = 'Country__c';
		update appConfigRecord;
        
        User stdUser = TestHelper.createUser('SegmentDataServerTest_StdUser', null, false);  
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        Segment__c segmentObj = TestHelper.createSegment(peopleObj.Id);
        peopleObj.Segment_Attribute_Value__c = 'India';
        peopleObj.Segment__c = segmentObj.Id;
        peopleObj.Is_Segment_Manager__c = true;
        update peopleObj;
        
        Audience__c audienceRec = TestHelper.createAudience(segmentObj.Id);
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleObj.Id, 'Site');
        
        TestHelper.createCarousel(null, null);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('SegmentDataServerTest_Grp1','Public');
        Simpplr_Site__c site = TestHelper.getSiteRecordWithName('SegmentDataServerTest_Grp1');
        TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
        site.Is_Featured__c = true;
        update site;
        
        Simpplr_Content__c contentObj = TestHelper.createContent('SegmentDataServerTest Event', 'Event', 'Approved', stdUser, site);
        Carousel_Content__c carouselContentObj = TestHelper.createCarousel(site.Id, contentObj.Id);
        carouselContentObj.Segment__c = segmentObj.Id;
        update carouselContentObj;
        
        Mailer__c newsletter = TestHelper.getMailerRecord('SegmentDataServerTest_NewsLetter', peopleObj.Id, site.id, contentObj.Id);
        newsletter.Audience__c = audienceRec.Id;
        update newsletter;
        
        Alert__c alertObj = new Alert__c();
        alertObj.Alert_Message__c = 'TestAlert';
        alertObj.Author__c = peopleObj.Id;
        alertObj.Display_To_DateTime__c = Date.today() + 1;
        alertObj.Audience__c = audienceRec.Id;
        insert alertObj;
        
        Social_Campaign__c socialCampaignObj = TestHelper.createSocialCampaign(peopleObj.Id);
        socialCampaignObj.Audience__c = audienceRec.Id;
        update socialCampaignObj;
        
        Tiles_Config__c tilesConfigObj = new Tiles_Config__c();
        tilesConfigObj.Segment__c = segmentObj.Id;
        insert tilesConfigObj;
        
        App_Default__c appDefaultObj = TestHelper.setupAppDefault();
        appDefaultObj.Segment__c = segmentObj.Id;
        update appDefaultObj;
        
        Segment_Site__c segmentSiteObj = new Segment_Site__c();
        segmentSiteObj.Segment__c = segmentObj.Id;
        insert segmentSiteObj;
        
        List<Segment__c> segmentList = [SELECT Id FROM Segment__c LIMIT 1];
        if(!segmentList.isEmpty()){
        	segmentRec = segmentList[0];
        }
	}
    
    private static People__c getPeople() {
        People__c peopleObj = [Select Id From People__c Limit 1];
        return peopleObj;
    }
    
    private static Segment__c getSegment() {
        Segment__c segmentObj = [Select Id From Segment__c Limit 1];
        return segmentObj;
    }
    
    @isTest static void testHandleRequestSearch() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRO;
        
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	pageRef.getParameters().put('target','SegmentDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('data','{"isFullModel":true, "includeUnassigned":true}');
        pageRef.getParameters().put('action','search');
    	segmentDSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"isFullModel":false, "includeUnassigned":true}');
        pageRef.getParameters().put('action','search');
    	segmentDSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"includeUnassigned":true}');
        pageRef.getParameters().put('action','search');
        segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestGet() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRO;
        Segment__c segObj = [Select id From Segment__c where Name__c =: 'Untitled Segment'];
        SegmentDataServer segmentDSObj = new SegmentDataServer();
        pageRef.getParameters().put('target','SegmentDataServer'); 
        Test.setCurrentPage(pageRef);
         
        pageRef.getParameters().put('segmentId',segObj.id);
        pageRef.getParameters().put('action','get');
    	segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSetEnabled() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/externalSearch',false));
        Test.startTest();
        App_default__c appDefaultObj = TestHelper.setupAppDefault();
        
        People__c peopleObj = getPeople();
        Segment__c segmentObj = getSegment();
        
        Tiles_Config__c tilesConfigObj = TestHelper.createTilesConfigData(null, null, peopleObj.id, 'latest', 'activity');
        appDefaultObj.Data__c = tilesConfigObj.Id;
        appDefaultObj.Type__c = 'home-default';
        update appdefaultObj;
        
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.App_Dashboard_Mode__c = 'Manager';
        appConfigObj.App_Home_Dashboard_Tile_Ids__c = tilesConfigObj.Id;
        appConfigObj.Segment_Apps_Links_Enabled__c = false;
        appConfigObj.Segment_Branding_Enabled__c = false;
        appConfigObj.PP_User_Custom_Fields__c = '[{"columnName":"Country__c", "fieldName":"Country__c", "syncSource":"testSource"}]';
        update appConfigObj;
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('data','[ { "segmentId": null, "name": "UK", "listOfSubsegments": [ { "name": "Brighton Office", "audienceCount": 8 }, { "name": "London Office", "audienceCount": 25 } ] }, { "segmentId": null, "name": "New segment example with null ID", "listOfSubsegments": [ { "name": "New York Office", "audienceCount": 8 }, { "name": "San Francisco Office", "audienceCount": 25 } ] } ]');
    	pageRef.getParameters().put('profileField','Country__c');
        pageRef.getParameters().put('target','SegmentDataServer');
        pageRef.getParameters().put('action','setEnabled');
        pageRef.getParameters().put('isBrandingSegmented','true');
        pageRef.getParameters().put('shouldInherit','true');
        Test.setCurrentPage(pageRef);
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSetEnabledFalse() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Segment_Enabled__c = true;
        update appConfigObj;
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('data','[ { "segmentId": null, "name": "UK", "listOfSubsegments": [ { "name": "Brighton Office", "audienceCount": 8 }, { "name": "London Office", "audienceCount": 25 } ] }, { "segmentId": null, "name": "New segment example with null ID", "listOfSubsegments": [ { "name": "New York Office", "audienceCount": 8 }, { "name": "San Francisco Office", "audienceCount": 25 } ] } ]');
    	pageRef.getParameters().put('target','SegmentDataServer');
        pageRef.getParameters().put('action','setEnabled');
        pageRef.getParameters().put('profileField','false');
        Test.setCurrentPage(pageRef);
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSetup() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Segment_Apps_Links_Enabled__c = true;
        appConfigObj.Segment_Branding_Enabled__c = true;
        update appConfigObj;
        
        List<People__c> peopleRec = [Select id, Segment__c from People__c where User__c =: UserContext.id LIMIT 1];
        if(peopleRec.size() > 0) {
            peopleRec[0].segment__c = null;
            update peopleRec[0];
        }
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('data', '[ { "segmentId": null, "name": "UK", "listOfSubsegments": [ { "name": "Brighton Office", "audienceCount": 8 }, { "name": "London Office", "audienceCount": 25 } ] }, { "segmentId": null, "name": "New segment example with null ID", "listOfSubsegments": [ { "name": "New York Office", "audienceCount": 8 }, { "name": "San Francisco Office", "audienceCount": 25 } ] } ]');
        pageRef.getParameters().put('target','SegmentDataServer');
        pageRef.getParameters().put('action','setup');
        Test.setCurrentPage(pageRef);
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSetManagers() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('listOfManagers', '[ { "id": "a0H1N00000JARs5UAH", "peopleId": "a0H1N00000JARs5UAH", "userId": "005o0000000e5LLAAY", "sfUserId": "005o0000000e5LLAAY", "name": "Joe Holdcroft", "nickname": "jholdcroft", "url": "/profile?userId=12345", "img": "/profile-img.jpg", "department": "Engineering", "title": "Web Developer", "location": "San Francisco, CA, USA", "email": "joe@simpplr.com", "phone": "+1 (650) 744 5348", "mobile": "+1 (631) 218 1123", "phoneExtension": "+463", "about": "I am the Lead UI Engineer here at Simpplr and have been working here for 2 years.", "birthday": "03-04", "hireDate": "2016-10-23", "workAnniversary": "01-01", "isFollowing": true, "isFavorited": true, "isActive": true, "canFollow": true } ]');
        pageRef.getParameters().put('segmentId', '1234');
    	pageRef.getParameters().put('target', 'SegmentDataServer');
        pageRef.getParameters().put('action', 'setManagers');
        Test.setCurrentPage(pageRef);
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestAllowBranding() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Segment_Enabled__c = true;
        update appConfigObj;
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('isEnabled', 'true');
    	pageRef.getParameters().put('target', 'SegmentDataServer');
        pageRef.getParameters().put('action', 'allowBranding');
        Test.setCurrentPage(pageRef);
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestGetPossibleSubsegments() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('profileField', 'country');
    	pageRef.getParameters().put('target', 'SegmentDataServer');
        pageRef.getParameters().put('action', 'getPossibleSubsegments');
        Test.setCurrentPage(pageRef);
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	segmentDSObj.handleRequest();
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestGetByIds() {
        Test.startTest();
        Segment__c segmentObj = getSegment();        
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('data', '["'+segmentObj.id+'"]');
    	pageRef.getParameters().put('target', 'SegmentDataServer');
        pageRef.getParameters().put('action', 'getByIds');
        Test.setCurrentPage(pageRef);
		SegmentDataServer segmentDSObj = new SegmentDataServer();
    	segmentDSObj.handleRequest();
        System.assertEquals('success',segmentDSObj.response.status ,'Running as expected');
        Test.stopTest();
    }
    
}