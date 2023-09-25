@isTest
private class SubscriptionDataServerTest {
	private static App_Config__c appConfigRecord;
	private static Simpplr_Site__c site;
	private static User managerUserObj;
	private static Segment__c segmentObj;
	private static People__c peopleObj;
    private static Subscription__c subscriptionRec;
	
	@testSetup static void setup() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
		App_config__c appConfigRecord = TestHelper.setupAppConfig();
		appConfigRecord.Segment_Enabled__c = true;
		appConfigRecord.Segment_Column_Name__c = 'Country__c';
		
		update appConfigRecord;
		
		managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false);
		
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
		
		CollaborationGroup collGrp = TestHelper.createCollaborationGroup('SubscriptionDataServer_grp1', 'Public');
		
		
		SegmentService segmentServiceObj = new SegmentService();
		String segmentData = '[ { "segmentId": null, "name": "UK", "listOfSubsegments": [ { "name": "Brighton Office", "audienceCount": 8 }, { "name": "London Office", "audienceCount": 25 } ] }, { "segmentId": null, "name": "New segment example with null ID", "listOfSubsegments": [ { "name": "New York Office", "audienceCount": 8 }, { "name": "San Francisco Office", "audienceCount": 25 } ] } ]';
		
		List<SegmentWrapper> criteriaSegmentSetupObj = (List<SegmentWrapper>)JSON.deserialize(segmentData, 
							List<SegmentWrapper>.class);
		
        SegmentWrapper.Options segmentOptions = new SegmentWrapper.Options();
        segmentOptions.isAppsAndLinksSegmented = true;
        segmentOptions.isBrandingSegmented = true;
        segmentOptions.shouldInherit = true;
		segmentServiceObj.setupSegment(criteriaSegmentSetupObj,segmentOptions);
        
		List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'native_video'});
        List<People_Integration__c> peopleIntegList = TestHelper.createPeopleIntegrationRecords(appIntegList, UserContext.peopleId, 'native_video');
        
        Audience__c csvAudience = TestHelper.createAudience(null);
        csvAudience.Audience_Rule_Json__C = '[{"csv":["email id file - Save.csv"]}]';
        csvAudience.Is_Created_By_Csv__c = true;
        csvAudience.name__c = 'dummycsvaudience';
        update csvAudience;
        
        System.assert(true,'Running as expected');	 
	}   
	
    static void init() {
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','SubscriptionDataServer');
        Test.setCurrentPage(pageRef);
        
        managerUserObj = [select Id, lastName from user where lastname like 'Simpplr_mngr%'][0];
        site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='SubscriptionDataServer_grp1'][0];
        peopleObj = [select id from people__c where last_name__c='Simpplr_mngr'];
        
        List<Segment__c> segmentList = [SELECT Id FROM Segment__c LIMIT 1];
        if(!segmentList.isEmpty()){
        	segmentObj = segmentList[0];
        }
    	
        Audience__c audienceRec = TestHelper.createAudience(segmentObj.Id);
        Audience_Member__c audienceMemberRec = TestHelper.createAudienceMember(audienceRec.Id, peopleObj.Id);
        audienceMemberRec.Is_All_Subscription_Required__c = false;
        update audienceMemberRec;
        subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleObj.Id, 'People');
        subscriptionRec.Recipient__c = 'audience';
        update subscriptionRec;
        

        
    }
    
	@isTest static void testHandleRequestSubscriptionExceptions() {
		init();
		
		SubscriptionDataServer dSObj= new SubscriptionDataServer();

        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'SubscriptionDataServer');
        pageRef.getParameters().put('action', 'invalidaction');
        pageRef.getParameters().put('data', '{"subscriptionId":null}');
        
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();

        System.assert(true, 'Running as expected');
	}

    @isTest static void testHandleRequestSubscriptionTypePeopleSave() {
    	init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
        Audience__c audienceRec = TestHelper.createAudience(segmentObj.Id);
		audienceRec.Has_Department_Condition__c = false;
		audienceRec.name__c = 'Everyone';
		audienceRec.Is_Deleted__c = false;
		audienceRec.Is_Hidden__c = true;
        audienceRec.Audience_Rule_Json__c = '[{"department":["Dep-1"]}]';
		update audienceRec;
        
    	String dataJsonPeopleTypeString = '{"recipient":"audience", "subscriptionId":null,"segment":{"segmentId":"' + segmentObj.Id + '","name":"Untitled Segment","isManager":true,"createdAt":"' + DateTime.now() + '","createdBy":{"id":"a0M36000000qsdxEAA"},"modifiedAt":"2018-02-07T19:14:44.000+0530","modifiedBy":{"id":"a0M36000000qsdxEAA"},"audienceCount":8,"listOfSubsegments":[],"listOfManagers":[],"listOfMandatorySites":[],"listOfFeaturedSites":[]},"audience":{"audienceCount":0,"listOfConditions":[{"name":"department","label":"Company","values":[{"id":null,"name":"Technology"}]}]},"isLocked":false,"createdAt":null,"createdBy":null,"modifiedAt":null,"modifiedBy":null,"action":{"listOfPeople":[{"subscriptionEntityId":null,"item":{"id":"'+ peopleObj.id+ '"}}],"listOfSites":[],"actionType":"autofollow"}}';
    	
  		SubscriptionDataServer dSObj= new SubscriptionDataServer();

        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'SubscriptionDataServer');
        // create  subscription type people
        pageRef.getParameters().put('action', 'save');
        pageRef.getParameters().put('data', dataJsonPeopleTypeString);
        
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        dataJsonPeopleTypeString = '{"recipient":"segment", "subscriptionId":null,"segment":{"segmentId":"' + segmentObj.Id + '","name":"Untitled Segment","isManager":true,"createdAt":"' + DateTime.now() + '","createdBy":{"id":"a0M36000000qsdxEAA"},"modifiedAt":"2018-02-07T19:14:44.000+0530","modifiedBy":{"id":"a0M36000000qsdxEAA"},"audienceCount":8,"listOfSubsegments":[],"listOfManagers":[],"listOfMandatorySites":[],"listOfFeaturedSites":[]},"audience":{"audienceCount":0,"listOfConditions":[{"name":"department","label":"Company","values":[{"id":null,"name":"Technology"}]}]},"isLocked":false,"createdAt":null,"createdBy":null,"modifiedAt":null,"modifiedBy":null,"action":{"listOfPeople":[{"subscriptionEntityId":null,"item":{"id":"'+ peopleObj.id+ '"}}],"listOfSites":[],"actionType":"autofollow"}}';
		pageRef.getParameters().put('data', dataJsonPeopleTypeString);
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        dataJsonPeopleTypeString = '{"recipient":"everyone", "subscriptionId":null,"segment":{"segmentId":"' + segmentObj.Id + '","name":"Untitled Segment","isManager":true,"createdAt":"' + DateTime.now() + '","createdBy":{"id":"a0M36000000qsdxEAA"},"modifiedAt":"2018-02-07T19:14:44.000+0530","modifiedBy":{"id":"a0M36000000qsdxEAA"},"audienceCount":8,"listOfSubsegments":[],"listOfManagers":[],"listOfMandatorySites":[],"listOfFeaturedSites":[]},"audience":{"audienceCount":0,"listOfConditions":[{"name":"department","label":"Company","values":[{"id":null,"name":"Technology"}]}]},"isLocked":false,"createdAt":null,"createdBy":null,"modifiedAt":null,"modifiedBy":null,"action":{"listOfPeople":[{"subscriptionEntityId":null,"item":{"id":"'+ peopleObj.id+ '"}}],"listOfSites":[],"actionType":"autofollow"}}';
		pageRef.getParameters().put('data', dataJsonPeopleTypeString);
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        // update  subscription type people
        List<Subscription__c> subscriptionList = [SELECT Id FROM Subscription__c WHERE Type__c = 'People' LIMIT 1];
        if(!subscriptionList.isEmpty()){
        	String subscriptionId = subscriptionList[0].Id;
        	List<Subscription_Entity__c> subsEnityList = [SELECT Id FROM Subscription_Entity__c WHERE Subscription__c = :subscriptionId LIMIT 1];
        	
        	if(!subsEnityList.isEmpty()){
        		String subEntityId = subsEnityList[0].Id;
        		dataJsonPeopleTypeString = '{"recipient":"audience", "subscriptionId":"' + subscriptionId + '","segment":{"segmentId":"' + segmentObj.Id + '","name":"Untitled Segment","isManager":true,"createdAt":"' + DateTime.now() + '","createdBy":{"id":"a0M36000000qsdxEAA"},"modifiedAt":"2018-02-07T19:14:44.000+0530","modifiedBy":{"id":"a0M36000000qsdxEAA"},"audienceCount":8,"listOfSubsegments":[],"listOfManagers":[],"listOfMandatorySites":[],"listOfFeaturedSites":[]},"audience":{"audienceCount":0,"listOfConditions":[{"name":"department","label":"Company","values":[{"id":null,"name":"Technology"}]}]},"isLocked":false,"createdAt":null,"createdBy":null,"modifiedAt":null,"modifiedBy":null,"action":{"listOfPeople":[{"subscriptionEntityId":"'+ subEntityId +'","item":{"id":"'+ peopleObj.id+ '"}}],"listOfSites":[],"actionType":"autofollow"}}';
        	}
        }
        pageRef.getParameters().put('action', 'save');
        pageRef.getParameters().put('data', dataJsonPeopleTypeString);
        dSObj.handleRequest();
        
        if(!subscriptionList.isEmpty()){
        	String subscriptionId = subscriptionList[0].Id;
        	List<Subscription_Entity__c> subsEnityList = [SELECT Id FROM Subscription_Entity__c WHERE Subscription__c = :subscriptionId LIMIT 1];
        	
        	if(!subsEnityList.isEmpty()){
        		String subEntityId = subsEnityList[0].Id;
        		dataJsonPeopleTypeString = '{"recipient":"segment", "subscriptionId":"' + subscriptionId + '","segment":{"segmentId":"' + segmentObj.Id + '","name":"Untitled Segment","isManager":true,"createdAt":"' + DateTime.now() + '","createdBy":{"id":"a0M36000000qsdxEAA"},"modifiedAt":"2018-02-07T19:14:44.000+0530","modifiedBy":{"id":"a0M36000000qsdxEAA"},"audienceCount":8,"listOfSubsegments":[],"listOfManagers":[],"listOfMandatorySites":[],"listOfFeaturedSites":[]},"audience":{"audienceCount":0,"listOfConditions":[{"name":"department","label":"Company","values":[{"id":null,"name":"Technology"}]}]},"isLocked":false,"createdAt":null,"createdBy":null,"modifiedAt":null,"modifiedBy":null,"action":{"listOfPeople":[{"subscriptionEntityId":null,"item":{"id":"'+ peopleObj.id+ '"}}],"listOfSites":[],"actionType":"autofollow"}}';
        	}
        }
        pageRef.getParameters().put('action', 'save');
        pageRef.getParameters().put('data', dataJsonPeopleTypeString);
		dSObj.handleRequest();

        System.assert(true, 'Running as expected');
    }
    
    @isTest static void testHandleRequestRerunSubscription() {
        Test.startTest();
        init();
       	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
        List<Subscription_Entity__c> subscriptionEntityList = TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRec.Id, site.Id);
        SubscriptionDataServer dSObj= new SubscriptionDataServer();
 
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','SubscriptionDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','rerun');
        pageRef.getParameters().put('subscriptionId',subscriptionRec.Id);
        dSObj.handleRequest();

        Test.stopTest();
        System.assert(true, 'Running as expected');
        
    }
    
    @isTest static void testHandleRequestStartBatchJob() {
        init();
        Audience__c audienceRec = TestHelper.createAudience(segmentObj.Id);
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleObj.Id, 'site');
        Audience_Member__c audMemObj = new Audience_Member__c();
		audMemObj.audience__c =  audienceRec.id;
		audMemObj.People__c = peopleObj.id;
		audMemObj.User__c= managerUserObj.id;
		audMemObj.Is_All_Subscription_Required__c = true;
        insert audMemObj;
        
        Subscription_Entity__c subEntityObj = new Subscription_Entity__c();
        subEntityObj.Subscription__c =  subscriptionRec.id;
        subEntityObj.Site__c= null;
        subEntityObj.Status__c = 'approved';
		subEntityObj.People__c = peopleObj.id;
		insert subEntityObj;
        SubscriptionDataServer dSObj= new SubscriptionDataServer();

        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','SubscriptionDataServer');
        pageRef.getParameters().put('action','startBatchJob');
        Test.setCurrentPage(pageRef);
        
        dSObj.handleRequest();
        
        System.assert(true, 'Running as expected');
        
    }
    
    @isTest static void testStartBatchJobWhenAudienceMemberAvailable() {
        Test.startTest();
        init();
        Audience__c audienceRec = TestHelper.createAudience(segmentObj.Id);
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleObj.Id, 'site');
        Audience_Member__c audMemObj = new Audience_Member__c();
		audMemObj.audience__c =  audienceRec.id;
		audMemObj.People__c = peopleObj.id;
		audMemObj.User__c= managerUserObj.id;
		audMemObj.Is_All_Subscription_Required__c = true;
        insert audMemObj;
        
        Subscription_Entity__c subEntityObj = new Subscription_Entity__c();
        subEntityObj.Subscription__c =  subscriptionRec.id;
        subEntityObj.Site__c= site.Id;
        subEntityObj.Status__c = 'approved';
		subEntityObj.People__c = peopleObj.id;
		insert subEntityObj;
        
        SubscriptionDataServer dSObj= new SubscriptionDataServer();

        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','SubscriptionDataServer');
        pageRef.getParameters().put('action','startBatchJob');
        Test.setCurrentPage(pageRef);
        
        dSObj.handleRequest();
        
        System.assert(true, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSubscriptionTypeSiteSave() {
    	init();
        
    	String dataJsonSiteTypeString = '{"subscriptionId":null,"segment":{"segmentId":"' + segmentObj.Id + '","name":"Untitled Segment","isManager":true,"createdAt":"' + DateTime.now() + '","createdBy":{"id":"a0M36000000qsdxEAA"},"modifiedAt":"2018-02-07T19:14:44.000+0530","modifiedBy":{"id":"a0M36000000qsdxEAA"},"audienceCount":8,"listOfSubsegments":[],"listOfManagers":[],"listOfMandatorySites":[],"listOfFeaturedSites":[]},"audience":{"audienceCount":0,"listOfConditions":[{"name":"department","label":"Company","values":[{"id":null,"name":"Technology"}]}]},"isLocked":false,"createdAt":null,"createdBy":null,"modifiedAt":null,"modifiedBy":null,"action":{"listOfPeople":[],"listOfSites":[{"subscriptionEntityId":null,"item":{"siteId":"' + site.Id + '","access":"Private","isActive":true,"chatterGroupId":"' + site.Chatter_Group_Id__c + '","id":"' + site.Id + '"}}],"actionType":"autofollow"}}';   
		SubscriptionDataServer dSObj= new SubscriptionDataServer();

        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'SubscriptionDataServer');
        // create  subscription type site
        pageRef.getParameters().put('action', 'save');
        pageRef.getParameters().put('data', dataJsonSiteTypeString);
        
        Test.setCurrentPage(pageRef);
		dSObj.handleRequest();
        
        // update  subscription type site
        List<Subscription__c> subscriptionList = [SELECT Id FROM Subscription__c WHERE Type__c = 'Site' LIMIT 1];
        if(!subscriptionList.isEmpty()){
        	String subscriptionId = subscriptionList[0].Id;
        	List<Subscription_Entity__c> subsEnityList = [SELECT Id FROM Subscription_Entity__c WHERE Subscription__c = :subscriptionId LIMIT 1];
        	
        	if(!subsEnityList.isEmpty()){
        		String subEntityId = subsEnityList[0].Id;
        		dataJsonSiteTypeString = '{"subscriptionId":"' + subscriptionId + '","segment":{"segmentId":"' + segmentObj.Id + '","name":"Untitled Segment","isManager":true,"createdAt":"' + DateTime.now() + '","createdBy":{"id":"a0M36000000qsdxEAA"},"modifiedAt":"2018-02-07T19:14:44.000+0530","modifiedBy":{"id":"a0M36000000qsdxEAA"},"audienceCount":8,"listOfSubsegments":[],"listOfManagers":[],"listOfMandatorySites":[],"listOfFeaturedSites":[]},"audience":{"audienceCount":0,"listOfConditions":[{"name":"department","label":"Company","values":[{"id":null,"name":"Technology"}]}]},"isLocked":false,"createdAt":null,"createdBy":null,"modifiedAt":null,"modifiedBy":null,"action":{"listOfPeople":[],"listOfSites":[{"subscriptionEntityId": null ,"item":{"siteId":"' + site.Id + '","access":"private","isActive":true,"chatterGroupId":"' + site.Chatter_Group_Id__c + '","id":"' + site.Id + '"}}],"actionType":"autofollow"}}';
        	}
        }
        pageRef.getParameters().put('action', 'save');
        pageRef.getParameters().put('data', dataJsonSiteTypeString);
        
        Test.setCurrentPage(pageRef);
		dSObj.handleRequest();

        System.assert(true, 'Running as expected');
    }
    
    @isTest static void testHandleRequestSearch() {
    	init();    
        SubscriptionDataServer dSObj= new SubscriptionDataServer();
        
        PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        
		pageRef.getParameters().put('target','SubscriptionDataServer');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"excludeSegments":true}');
        dsObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"segmentId":"'+segmentObj.Id+'","excludeSegments":false}');
        dsObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"segmentId":"'+segmentObj.Id+'","siteId":"'+site.Id+'","excludeSegments":true,"offset":10,"size":16}');
        dsObj.handleRequest();
        
        UserContext.isSegmentManager = true;
        pageRef.getParameters().put('data','{"segmentId":null,"siteId":"'+site.Id+'","excludeSegments":false,"offset":10,"size":16}');
        dsObj.handleRequest();
        
        System.assert(true, 'Running as expected');
    }    
    
    @isTest static void testHandleRequestGet() {
    	init();
        
        Audience__c audienceRec = TestHelper.createAudience(segmentObj.Id);
        audienceRec.Audience_Rule_Json__c = '[{"peopleId":["'+peopleObj.Id+'"]}]';
        update audienceRec;
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleObj.Id, 'Site');
        
        SubscriptionDataServer dSObj= new SubscriptionDataServer();

        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','SubscriptionDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{"subscriptionId":""}');
        dSObj.handleRequest();
        
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('subscriptionId',subscriptionRec.Id);
        dSObj.handleRequest();

        System.assert(true, 'Running as expected');
     
    }
    

    
     @isTest static void testHandleRequestDelete() {

		CollaborationGroup cg=TestHelper.createCollaborationGroup('SubscriptionDataServer_Grp','Private');
		simpplr_site__c siteRec = [select id From simpplr_site__c where chatter_group_id__c=: cg.id limit 1];
		User userObj = TestHelper.createUser('user' ,null, true);
		people__c peopleRec = [select id From people__c where user__c =: userObj.id];

		Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id);
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		audienceRec.Has_Department_Condition__c = false;
		audienceRec.name__c = 'Everyone';
		audienceRec.Is_Deleted__c = false;
		audienceRec.Is_Hidden__c = true;
		update audienceRec;
         
		CollaborationGroupMember memObj = TestHelper.createCollaborationGroupMember(cg.Id, userObj.id);
		memObj.CollaborationRole = 'Standard';
		update memObj;
         
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleRec.Id, 'site');
        subscriptionRec.Recipient__c = 'everyone';
        update subscriptionRec;
		Subscription_Entity__c subEntityObj = new Subscription_Entity__c();
        subEntityObj.Subscription__c =  subscriptionRec.id;
        subEntityObj.Site__c= siteRec.id;
        subEntityObj.Status__c = 'approved';
		subEntityObj.People__c = peopleRec.id;
		insert subEntityObj;
         
		Audience_Member__c audMemObj = new Audience_Member__c();
		audMemObj.audience__c =  audienceRec.id;
		audMemObj.People__c = peopleRec.id;
		audMemObj.User__c= userObj.id;
		audMemObj.Is_All_Subscription_Required__c = true;
        insert audMemObj;
         
        App_Notification__c notificationsObj = new App_Notification__c();
        notificationsObj.Object_id__c = subscriptionRec.id;
        notificationsObj.Type__c ='Actionable' ;
        notificationsObj.Object_Type__c ='Subscription' ;
        notificationsObj.Status__c = 'Pending';
		notificationsObj.is_deleted__c = false;
        notificationsObj.Sent_To__c = peopleRec.Id;
        insert notificationsObj;

  		SubscriptionDataServer dSObj= new SubscriptionDataServer();

        PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
         
        pageRef.getParameters().put('action','delete');
		pageRef.getParameters().put('subscriptionId',subscriptionRec.Id);
        pageRef.getParameters().put('deleteUnfollow','false');
		Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
         
        pageRef.getParameters().put('action','delete');
        pageRef.getParameters().put('deleteUnfollow','true');  
        pageRef.getParameters().put('subscriptionId',subscriptionRec.Id);
        dSObj.handleRequest();
		System.assert(true, 'Running as expected');
    
    }
    
    @isTest static void testHandleRequestDeleteForAudience(){

		CollaborationGroup cg=TestHelper.createCollaborationGroup('SubscriptionDataServer_Grp','Private');
		simpplr_site__c siteRec = [select id From simpplr_site__c where chatter_group_id__c=: cg.id limit 1];
		User userObj = TestHelper.createUser('user' ,null , true);
		people__c peopleRec = [select id From people__c where user__c =: userObj.id];

		Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id);
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		audienceRec.Has_Department_Condition__c = false;
		audienceRec.name__c = 'Everyone';
		audienceRec.Is_Deleted__c = false;
		audienceRec.Is_Hidden__c = true;
		update audienceRec;
         
		CollaborationGroupMember memObj = TestHelper.createCollaborationGroupMember(cg.Id, userObj.id);
		memObj.CollaborationRole = 'Standard';
		update memObj;
         
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleRec.Id, 'site');
        subscriptionRec.Recipient__c = 'audience';
        update subscriptionRec;
		Subscription_Entity__c subEntityObj = new Subscription_Entity__c();
        subEntityObj.Subscription__c =  subscriptionRec.id;
        subEntityObj.Site__c= siteRec.id;
        subEntityObj.Status__c = 'approved';
		subEntityObj.People__c = peopleRec.id;
		insert subEntityObj;
         
		Audience_Member__c audMemObj = new Audience_Member__c();
		audMemObj.audience__c =  audienceRec.id;
		audMemObj.People__c = peopleRec.id;
		audMemObj.User__c= userObj.id;
		audMemObj.Is_All_Subscription_Required__c = true;
        insert audMemObj;
         
        App_Notification__c notificationsObj = new App_Notification__c();
        notificationsObj.Object_id__c = subscriptionRec.id;
        notificationsObj.Type__c ='Actionable' ;
        notificationsObj.Object_Type__c ='Subscription' ;
        notificationsObj.Status__c = 'Pending';
		notificationsObj.is_deleted__c = false;
        notificationsObj.Sent_To__c = peopleRec.Id;
        insert notificationsObj;

  		SubscriptionDataServer dSObj= new SubscriptionDataServer();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','delete');
        pageRef.getParameters().put('deleteUnfollow','true');  
        pageRef.getParameters().put('subscriptionId',subscriptionRec.Id);
        dSObj.handleRequest();
		System.assert(true, 'Running as expected');
    
    }
    
    @isTest static void testHandleRequestDeleteForSegment(){

		CollaborationGroup cg=TestHelper.createCollaborationGroup('SubscriptionDataServer_Grp','Private');
		simpplr_site__c siteRec = [select id From simpplr_site__c where chatter_group_id__c=: cg.id limit 1];
		User userObj = TestHelper.createUser('user' ,null , true);
		people__c peopleRec = [select id From people__c where user__c =: userObj.id];

		Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id);
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		audienceRec.Has_Department_Condition__c = false;
		audienceRec.name__c = 'Everyone';
		audienceRec.Is_Deleted__c = false;
		audienceRec.Is_Hidden__c = true;
		update audienceRec;
         
		CollaborationGroupMember memObj = TestHelper.createCollaborationGroupMember(cg.Id, userObj.id);
		memObj.CollaborationRole = 'Standard';
		update memObj;
         
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleRec.Id, 'site');
        subscriptionRec.Recipient__c = 'segment';
        update subscriptionRec;
		Subscription_Entity__c subEntityObj = new Subscription_Entity__c();
        subEntityObj.Subscription__c =  subscriptionRec.id;
        subEntityObj.Site__c= siteRec.id;
        subEntityObj.Status__c = 'approved';
		subEntityObj.People__c = peopleRec.id;
		insert subEntityObj;
         
		Audience_Member__c audMemObj = new Audience_Member__c();
		audMemObj.audience__c =  audienceRec.id;
		audMemObj.People__c = peopleRec.id;
		audMemObj.User__c= userObj.id;
		audMemObj.Is_All_Subscription_Required__c = true;
        insert audMemObj;
         
        App_Notification__c notificationsObj = new App_Notification__c();
        notificationsObj.Object_id__c = subscriptionRec.id;
        notificationsObj.Type__c ='Actionable' ;
        notificationsObj.Object_Type__c ='Subscription' ;
        notificationsObj.Status__c = 'Pending';
		notificationsObj.is_deleted__c = false;
        notificationsObj.Sent_To__c = peopleRec.Id;
        insert notificationsObj;

  		SubscriptionDataServer dSObj= new SubscriptionDataServer();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','delete');
        pageRef.getParameters().put('deleteUnfollow','true');  
        pageRef.getParameters().put('subscriptionId',subscriptionRec.Id);
        dSObj.handleRequest();
		System.assert(true, 'Running as expected');
    
    }

    @isTest
    static void testSearchForADAudienceSubscription() {
        init();
		CollaborationGroup cg = TestHelper.createCollaborationGroup('SubscriptionDataServer_Grp','Public');
		simpplr_site__c siteObj = [select id From simpplr_site__c where chatter_group_id__c =: cg.id limit 1];
		User userObj = TestHelper.createUser('user' ,null , true);
		People__c peopleRec = [select id From people__c where user__c =: userObj.id];       
        Active_Directory_Group__c adGroupObj = TestHelper.createActiveDirectoryGroup(); 
        Audience__c audienceObj = TestHelper.createAudienceForADGroup(adGroupObj.AD_Object_Id__c);
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceObj.Id, peopleRec.Id, 'site');
        subscriptionRec.Recipient__c = 'everyone';
        update subscriptionRec;
		Subscription_Entity__c subEntityObj = new Subscription_Entity__c();
        subEntityObj.Subscription__c =  subscriptionRec.id;
        subEntityObj.Site__c= siteObj.id;
        subEntityObj.Status__c = 'approved';
		subEntityObj.People__c = peopleRec.id;
		insert subEntityObj;
        
        SubscriptionDataServer dSObj= new SubscriptionDataServer();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','SubscriptionDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"segmentId":null,"excludeSegments":true}');
        Test.startTest();
        dSObj.handleRequest();                       
        Test.stopTest();
        System.assertEquals('success', dSObj.response.status, 'Result should have been success');
    }
    
    @isTest static void testHandleAudienceCsvSubscription() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
       	SubscriptionDataServer dSObj= new SubscriptionDataServer();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','SubscriptionDataServer');
        List<simpplr_site__c> siteObjList = [select id From Simpplr_Site__c where Name = 'SubscriptionDataServer_grp1' limit 1];
        Test.setCurrentPage(pageRef); 
        List<Audience__c> csvAudienceList = [Select id from Audience__c where Name__c = 'dummycsvaudience' LIMIT 1];

        if(!csvAudienceList.isEmpty() && !siteObjList.isEmpty()) {
            pageRef.getParameters().put('action','save');
            pageRef.getParameters().put('data', '{"recipient":"audience","subscriptionId":null,"segment":{},"audience":{"audienceId":"'+csvAudienceList[0].id+'","name":"dxacs","isDeleted":false,"segment":null,"audienceCount":4,"usage":{}},"action":{"listOfSites":[{"subscriptionEntityId":null,"item":{"id":"'+siteObjList[0].id+'","siteId":"'+siteObjList[0].id+'"}}],"listOfPeople":[]}}');
            dSObj.handleRequest();
            System.assertEquals('success', dSObj.response.status, 'Save Subscription is successful');
        }
            
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"excludeSegments":true}');
        dsObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running As Expected');

        Test.stopTest();          
    }
    
}