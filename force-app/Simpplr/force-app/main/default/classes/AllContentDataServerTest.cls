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
private class AllContentDataServerTest {
	
	private static App_Config__c appConfigRecord;
	private static simpplr_content__c content;
	private static simpplr_content__c albumContent;
	private static simpplr_content__c pendingContent;
	private static simpplr_content__c publishedContent;
	private static Simpplr_Site__c site;
	private static User standardUserObj;
	private static User adminUserObj;
	private static People__c standardUsersPeopleObj;
	private static People__c adminUsersPeopleObj;
	private static User managerUserObj;
	private static Pages_Category__c pageCategory;
    @testSetup static void setup() {
    	appConfigRecord = TestHelper.setupAppConfig();
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
		managerUserObj = TestHelper.createUser('AllContentDataServerTest_Simpplr_mngr', null, false); 
        standardUserObj = TestHelper.createUser('AllContentDataServerTest_Simpplr_usr', managerUserObj, false); 
        adminUserObj = TestHelper.createUser('AllContentDataServerTest_Simpplr_admin', null, true);
        standardUsersPeopleObj = getPeople(standardUserObj.id); 
	    adminUsersPeopleObj = getPeople(adminUserObj.id);
        
	    CollaborationGroup colabGroupObj= TestHelper.createCollaborationGroup('AllContentDataServerTest_Grp1','Public');
        site = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
        if(pageCategory == null){
        	pageCategory = new Pages_Category__c(Name__c='Test Page Category',Site__c =site.id,Order__c =0,Is_Deleted__c = false);
        	insert pageCategory;
        }
        
        Simpplr_Site__c  fullSiteRecord = TestHelper.getSiteRecord(site.Chatter_Group_Id__c);
        TestHelper.shareSitesToAllPeople(new List<String>{fullSiteRecord.Id});
        Topic topicObj = TestHelper.createTopic('AllContentDataServerTestTopic');
        albumContent = TestHelper.createContent('AllContentDataServerTest_testAlbumRecord', 'Album', 'Approved', adminUserObj, fullSiteRecord);
        TestHelper.createContentTitleImage(albumContent.Id);
        List<Simpplr_Content__c> pendingContentList = new List<Simpplr_Content__c>(); 
		System.runAs(adminUserObj) {
			content = new Simpplr_Content__c(
							Title__c='AllContentDataServerTest_testArticleRecord', 
								Text_Intro__c='AllContentDataServerTest Example text', 
								Text_Main__c='AllContentDataServerTest Example text',
								Text_Main_Continued__c='AllContentDataServerTest example text ',
								Type__c='Page', 
								Pages_Category__c = pageCategory.id,
								Status__c='Draft',
								Site__c = site.id,
								Publish_Start_DateTime__c=DateTime.now(),
								Primary_Author__c = adminUsersPeopleObj.id
								);
            insert content;
            
            
            
			TestHelper.addTopicToContent(topicObj.id, content.id);
            content = new Simpplr_Content__c(
							Title__c='AllContentDataServerTest_testArticleRecord1', 
								Text_Intro__c='AllContentDataServerTest Example text', 
								Text_Main__c='AllContentDataServerTest Example text',
								Text_Main_Continued__c='AllContentDataServerTest example text ',
								Type__c='Page', 
								Pages_Category__c = pageCategory.id,
								Status__c='Approved',
              				    Is_Deleted__c = false,Content_Sub_Type__c = 'knowledge',
								Site__c = site.id,
								Publish_Start_DateTime__c=DateTime.now(),
								Primary_Author__c = adminUsersPeopleObj.id
								);
           insert content;           
            
			pendingContentList.add(content.clone(false, false, false, false));
			pendingContentList.add(content.clone(false, false, false, false));
			pendingContentList.add(content.clone(false, false, false, false));
			pendingContentList.add(content.clone(false, false, false, false));
			TestHelper.addTopicToContent(topicObj.id, content.id);
        }
        System.runAs(standardUserObj) {
			
								content = new Simpplr_Content__c(
							    Title__c='AllContentDataServerTest_testArticleRecordInPendingState', 
								Text_Intro__c='AllContentDataServerTest Example text', 
								Text_Main__c='AllContentDataServerTest Example text',
								Text_Main_Continued__c='AllContentDataServerTest example text ',
								Type__c='Page',
								Pages_Category__c = pageCategory.id, 
								Status__c='Submitted', 
								Site__c = site.id,
								Publish_Start_DateTime__c=DateTime.now(),
								Primary_Author__c = standardUsersPeopleObj.id
								);
       insert content;  
            TestHelper.addTopicToContent(topicObj.id, content.id);           
		}

		System.runAs(standardUserObj) {
			content = new Simpplr_Content__c(
							Title__c='AllContentDataServerTest_BlogPost', 
								Text_Intro__c='AllContentDataServerTest Example text', 
								Text_Main__c='AllContentDataServerTest Example text',
								Text_Main_Continued__c='AllContentDataServerTest example text ',
								Type__c='BlogPost', 
								Status__c='Approved',
								Site__c = null,
                                Publish_Start_DateTime__c = DateTime.now(),
								Primary_Author__c = standardUsersPeopleObj.id
								);
			insert content;
			TestHelper.addTopicToContent(topicObj.id, content.id);
		}
        

    	System.assert(true,'Running as expected');
    }
    
 
    @isTest static void init() {
        
        standardUserObj = [select id from User where lastName='AllContentDataServerTest_Simpplr_usr' limit 1];
        adminUserObj = [select id from User where lastName='AllContentDataServerTest_Simpplr_admin' limit 1];
        managerUserObj = [select id from User where lastName='AllContentDataServerTest_Simpplr_mngr' limit 1];
        content  = [select id, site__c from simpplr_Content__c where title__c='AllContentDataServerTest_testArticleRecord' limit 1];
        albumContent  = [select id,version__c, site__c from simpplr_Content__c where title__c='AllContentDataServerTest_testAlbumRecord' limit 1];
        pendingContent  = [select id, site__c, Publish_Start_DateTime__c from simpplr_Content__c where title__c='AllContentDataServerTest_testArticleRecordInPendingState' And Status__c='Submitted' limit 1];
        publishedContent = [select id, site__c ,Is_Published__c from simpplr_Content__c where title__c='AllContentDataServerTest_BlogPost'  limit 1];
        site = TestHelper.getSiteRecordWithName('AllContentDataServerTest_Grp1');
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('siteId',site.Id);
        Test.setCurrentPage(pgRef);
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequestWhenActionNull() {
        Test.startTest();
    	init();
    	AllContentDataServer allContentDSObj= new AllContentDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId',site.Id);
        pageRef.getParameters().put('target','AllContentDataServer');
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequestWhenActionAvailable1() {
        Test.startTest();
        init();
        AllContentDataServer allContentDSObj= new AllContentDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId',site.Id);
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{}');
        allContentDSObj.handleRequest();
        System.assertEquals('success', allContentDSObj.response.status, 'Running as Expected');
        
        //data field is empty
        pageRef.getParameters().put('action','delete');
        allContentDSObj.handleRequest();
        System.assertEquals('error', allContentDSObj.response.status, 'Request data is invalid');
        
        //data field is empty
        pageRef.getParameters().put('action','create');
        allContentDSObj.handleRequest();
        System.assertEquals('error', allContentDSObj.response.status, 'Request data is invalid');
        
        pageRef.getParameters().put('action','approve');
        pageRef.getParameters().put('data','{"contentId":"'+ publishedContent.Id +'"}');
        allContentDSObj.handleRequest();
        System.assertEquals('success', allContentDSObj.response.status, 'Running as Expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"canAddToCarousel"}');
        allContentDSObj.handleRequest();
        System.assertEquals('success', allContentDSObj.response.status, 'Running as Expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"Draft"}');
        allContentDSObj.handleRequest();
        System.assertEquals('success', allContentDSObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','getMetadata');
        pageRef.getParameters().put('data', '{"contentId":"' + publishedContent.Id + '" }');
        allContentDSObj.handleRequest();
        System.assertEquals('success', allContentDSObj.response.status, 'Running as Expected');
        
        pageRef.getParameters().put('action','reject');
        pageRef.getParameters().put('data', '{"rejectionComment":"not liking", "contentId":"' + publishedContent.Id + '", "siteId":"' + site.Id + '"}');
        allContentDSObj.handleRequest(); 
        System.assertEquals('success', allContentDSObj.response.status, 'Running as Expected');
        Test.stopTest();
    }
    
     
    
    @isTest static void testHandleRequestWhenActionAvailable() {
        Test.startTest();
    	init();
    	AllContentDataServer allContentDSObj= new AllContentDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId',site.Id);
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);
        
        PageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"Published"}');//,"peopleId":"'+ standardUsersPeopleObj.Id +'"
        allContentDSObj.handleRequest();   
        
        PageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"updates"}');//,"peopleId":"'+ standardUsersPeopleObj.Id +'"
        allContentDSObj.handleRequest(); 
        
        UserContext.isUserAppModerator = true;
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"ValidationExpired"}');
        allContentDSObj.handleRequest();
        
        UserContext.isUserAppModerator = false;
        pageRef.getParameters().put('action','search');     
        pageRef.getParameters().put('data','{"filter":"owned","status":"ValidationRequired"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"managing"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"Type":"BlogPost"}');
        allContentDSObj.handleRequest();
        
        UserContext.isUserAppModerator = false;
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"Submitted"}');
        allContentDSObj.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
	@isTest static void testHandleRequestWhenActionAvailable2() {
        Test.startTest();
    	init();
    	AllContentDataServer allContentDSObj= new AllContentDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId',site.Id);
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);

		pageRef.getParameters().put('action','reject');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','publish');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','unpublish');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','rate');
        allContentDSObj.handleRequest();
		
        pageRef.getParameters().put('action','sendMustReadReminderMail');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','dismissValidation');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','moveContent');
        allContentDSObj.handleRequest();
        
        ContentVersion cVersionObj = TestHelper.createContentVersion('developer', 'File_01');
        File__c fileObj = TestHelper.createContentTitleImage(albumContent.id);
        fileObj.Content_Version__c = cVersionObj.id;
        update fileObj;
        List<File__c> fileList = new List<File__c>();
        fileList.add(fileObj);
        string fileJson = JSON.serialize(fileList);
        string topicJson = JSON.serialize(new list<Topic> {});
        Content_History__c historyObj = new Content_History__c();
        historyObj.Content__c = albumContent.id;
        historyObj.Version__c = albumContent.Version__c;
        historyObj.File_Json__c = fileJson;
        historyObj.Topic_Json__c = topicJson;
        historyObj.Content_Json_Part1__c ='"{"attributes":{"type":"Simpplr_Content__c"},"Is_Unpublished__c":"false","Is_Published__c":"true","Total_View_Count__c":2,"Popularity_Score__c":20,"Version__c":1,"Last_Edited_DateTime__c":"2020-04-15T09:46:42.000+0000","First_Publish_DateTime__c":"2020-04-15T09:46:42.000+0000","Is_Published__c":true,"Primary_Author__c":"'+userContext.peopleId+'","Publish_Start_DateTime__c":"2020-04-14T18:30:00.000+0000","Title__c":"TestAlbum","Type__c":"Album","Id":"'+albumContent.Id+'","Status__c":"Approved","Unique_View_Count__c":1,"Display_Order__c":1,"Allow_Comments__c":true,"Site__c":"'+site.Id+'","Activated_By_Feature__c":true}"';
        insert historyObj;
        Content_Lock_Status__c lockStatusObj = new Content_Lock_Status__c();
        lockStatusObj.Content__c = albumContent.id;
        insert lockStatusObj;
        Content_Notification_Setting__c notiSettingObj = new Content_Notification_Setting__c();
        notiSettingObj.Simpplr_Content__c = albumContent.id;
        insert notiSettingObj;
        Carousel_Content__c carouselObj = TestHelper.createCarousel(site.id,albumContent.id);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"topic"}');
        allContentDSObj.handleRequest();
        User testUser = TestHelper.createUser('AllContent_usr1', null, false);
        people__c pObj =[select id from people__c where user__c =: testUser.id];
        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Action__c = 'Updated';
        auditTrailObj.Action_By__c = pObj.Id;
        auditTrailObj.Content__c = albumContent.id;
        insert auditTrailObj;
        
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('AllContent_Grp1', 'Public').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
    	Simpplr_Content__c simpplrContent = TestHelper.createContent('AllContent Event', 'Event', 'Approved', testUser, testSite);
        Event_RSVP_Response__c rSVPResObj = TestHelper.createRSVPResponse(simpplrContent.Id, pObj.id, 'Yes');
        fileObj = TestHelper.createContentTitleImage(simpplrContent.id);
        fileObj.Content_Version__c = cVersionObj.id;
        update fileObj;
        Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit( albumContent.Id, 'site_members_and_followers' , pObj.id);
        Must_Read_Confirm_History__c mustReadAuditHistoryObj = new Must_Read_Confirm_History__c();
		mustReadAuditHistoryObj.Must_Read_Audit__c = mustReadObj.Id;
		mustReadAuditHistoryObj.people__c = pObj.id;
		mustReadAuditHistoryObj.Content__c = albumContent.Id;
		insert mustReadAuditHistoryObj;
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"topic"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','getVersionHistory');
        pageRef.getParameters().put('data','{"size":16,"id":"'+albumContent.id+'"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','restoreVersion');
        pageRef.getParameters().put('data','{"size":16,"contentId":"'+albumContent.id+'","versionId":"'+albumContent.Version__c+'"}');
        allContentDSObj.handleRequest();

        pageRef.getParameters().put('action','renewLock');
        pageRef.getParameters().put('data','{"contentId":"'+albumContent.id+'"}');
        allContentDSObj.handleRequest(); 

        pageRef.getParameters().put('action','optForNotification');
        pageRef.getParameters().put('data','{"contentId":"'+albumContent.id+'","isOpenToNotification":true}');
        allContentDSObj.handleRequest();
        notiSettingObj.People__c = userContext.peopleId;
        update notiSettingObj;
        pageRef.getParameters().put('data','{"contentId":"'+albumContent.id+'","isOpenToNotification":false}');
        allContentDSObj.handleRequest();

        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"sortBy":"modifiedNewest"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"sortBy":"createdNewest"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"must_read"}'); 
        allContentDSObj.handleRequest();
        
        Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testHandleRequestWhenActionAvailable3() {
        Test.startTest();
    	init();
    	AllContentDataServer allContentDSObj= new AllContentDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId',site.Id);
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"Rejected"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"Unpublished"}');
        allContentDSObj.handleRequest();

        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"contentSubType" :"knowledge","nextPageToken":200}');
        allContentDSObj.handleRequest();
        
		pageRef.getParameters().put('action','getratings');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','makeMustRead');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','markAsRead');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','removeMustRead');
        allContentDSObj.handleRequest();
       
        pageRef.getParameters().put('action','resetMustRead');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','getRelated');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','getModerationHistory');
        
		pageRef.getParameters().put('data', '{"id":"' + publishedContent.Id + '","size":16 }');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','submit');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','getExpiringContentCounts');
        allContentDSObj.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
	}   
    @isTest static void testHandleRequestWhenActionAvailable4() {
        Test.startTest();
    	init();
    	AllContentDataServer allContentDSObj= new AllContentDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId',site.Id);
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"canAccess"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"peopleId":"'+UserContext.peopleId+'","filter":"owned","status":"rejected","term":"AllContentDataServer","type":"event","sortBy":"publishedNewest","size":10}');
        allContentDSObj.handleRequest();
    
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"pending","term":"AllContentDataServer","type":"event","sortBy":"publishedNewest","size":10}');
        allContentDSObj.handleRequest();
        
        UserContext.hasModifyAllDataPermission = false;
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"publish","term":"AllContentDataServer","type":"page","sortBy":"publishedNewest","size":10}');
        allContentDSObj.handleRequest();
        
        UserContext.hasManageUnlistedSitePermission = true;
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"owned","status":"unpublish","term":"AllContentDataServer","type":"album","sortBy":"publishedNewest","size":10}');
        allContentDSObj.handleRequest();

        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"latest","status":"all"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"popular"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"author"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"updates"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter":"canAddToNewsletter","size":5}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"isMustRead":true}');
        allContentDSObj.handleRequest();

        simpplr_content__c c = [select id from simpplr_content__c where title__c = 'AllContentDataServerTest_testArticleRecord1' limit 1];
        pageRef.getParameters().put('action', 'setValid');
        pageRef.getParameters().put('data', '{"contentId": "' + c.Id + '", "isValid": true}');
        allContentDSObj.handleRequest();
       
        pageRef.getParameters().put('action', 'setValid');
        pageRef.getParameters().put('data', '{"contentId": "' + c.Id + '", "isValid": false}');
        allContentDSObj.handleRequest();        
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSearch() {
        Test.startTest();
        init();
        PageReference pageRef = Page.DataServerRW;
        App_Notification__c app = TestHelper.createSimpplrNotification('Dummy',  UserContext.peopleId,null,'Like',pendingContent.id,null);
        app.Type__c = 'Actionable';
        update app;
        
    	//System.runAs(standardUserObj) {
	    	AllContentDataServer allContentDSObj = new AllContentDataServer();
		    allContentDSObj.search('{"status":"all","term":"AllContentDataServer","type":"all","sortBy":"publishedNewest","size":10}');
	    	allContentDSObj.search('{"status":"all","term":"AllContentDataServer","type":"album","sortBy":"publishedNewest","size":10}');
	    	allContentDSObj.search('{"status":"all","term":"AllContentDataServer","type":"page","sortBy":"publishedNewest","size":10,"siteId":"'+ content.Site__c + '","peopleId":"' + UserContext.peopleId + '","filter":"must_read","contentSubType":"test"}');
	    	allContentDSObj.search('{"status":"all","term":"AllContentDataServer","type":"event","sortBy":"publishedNewest","size":10}');
            allContentDSObj.search('{"status":"ValidationExpired","term":"AllContentDataServer","type":"Page","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
	    	allContentDSObj.searchContentForAddingInNewsltter('{"term":"AllContentDataServer","siteId":"'+ content.Site__c + '"}', 'canAddToNewsletter');
            allContentDSObj.searchContentForAddingInNewsltter('{"term":"AllContentDataServer","siteId":"'+ content.Site__c + '","type":"ent","excludeType":"pages","nextPageToken":200}', '{"filter":"canAddToNewsletterFromSite"}');
	    	allContentDSObj.getAllContentUserCanAccess('{"status":"all","term":"AllContentDataServer","type":"all","sortBy":"publishedNewest","filter":"canAccess","size":10}');
	        allContentDSObj.getAllContentUserCanAccess('{"status":"all","term":"AllContentDataServer","excludeType":"pages","siteId":"'+publishedContent.Site__c + '","type":"page","nextPageToken":200}');
	    //allContentDSObj.getLatestContents('{"siteId":"'+ publishedContent.Site__c + '","contentId":"'+ y.Id+ '","status":"all","term":"AllContentDataServer","type":"all",sortBy":"publishedNewest","filter":"latest",size":10,"nextPageToken":200}');  
            allContentDSObj.getLatestContents('{"siteId":"'+ publishedContent.Site__c + '","status":"all","term":"AllContentDataServer","type":"all",sortBy":"publishedNewest","filter":"latest",size":10,"nextPageToken":200}');
            allContentDSObj.getLatestContents('{"siteId":"'+publishedContent.Site__c + '","status":"all","term":"AllContentDataServer","type":"event","sortBy":"publishedNewest","filter":"latest","excludeType":"events","size":10,"nextPageToken":200}');
            allContentDSObj.getAuthoredByPeopleContents('{"siteId":"'+ publishedContent.Site__c + '","includeTotal":true,"excludeType":"events","sortBy":"publishNewest","term":"AllContentDataServer","size":16,"status":"published","peopleId":"' + UserContext.peopleId + '","filter":"author","type":"page","nextPageToken":200}');
            allContentDSObj.getAuthoredByPeopleContents('{"excludeType":"albums","sortBy":"most_liked"}');
            allContentDSObj.getAuthoredByPeopleContents('{"excludeType":"blogs","sortBy":"most_viewed"}');
            allContentDSObj.getAuthoredByPeopleContents('{"excludeType":"blogs","sortBy":"publishedNewest"}');
            allContentDSObj.getPopularContents('{"siteId":"'+ pendingContent.Site__c + '","contentId":"'+ pendingContent.Id+ '","status":"all","term":"AllContentDataServer","type":"all","sortBy":"publishedNewest","filter":"popular","excludeType":"blogs","nextPageToken":"200"}');
            allContentDSObj.getFavoriteContents('{"status":"all","term":"AllContentDataServer","type":"page","sortBy":"publishedNewest","filter":"favorites","size":10,"excludeType":"blogs","nextPageToken":3}');
	        allContentDSObj.getContentMustReadForUser('{"status":"all","term":"AllContentDataServer","excludeType":"blogs","type":"all","sortBy":"publishedNewest","filter":"favorites","nextPageToken":"1:2","size":10}');
		    allContentDSObj.getContentMustReadForUser('{"status":"all","term":"AllContentDataServer","excludeType":"blogs","type":"all","sortBy":"unreadNewest","filter":"favorites","size":10,"nextPageToken":"2:"}');
	        allContentDSObj.getContentMustReadForUser('{"status":"all","term":"AllContentDataServer","excludeType":"blogs","type":"all","sortBy":"unreadNewest","filter":"favorites","size":1,"nextPageToken":"2:","limit":0}');
            allContentDSObj.getContentMustReadForUser('{"status":"all","term":"AllContentDataServer","excludeType":"blogs","type":"all","sortBy":"unreadNewest","filter":"favorites","size":0,"nextPageToken":"2:"}');
            allContentDSObj.getContentMustReadForUser('{"size":16,"peopleId":"' + UserContext.peopleId + '","sortBy":"unreadNewest","filter":"all","isMustRead":true}');
            allContentDSObj.createContent('{"siteId":"'+ pendingContent.Site__c + '","contentId":"'+ pendingContent.Id+ '"}');
       
	    System.assert(true,'Running as expected');
        Test.stopTest();
    	//} 
    }
    
    @isTest static void testSearchBlogPost() {
        Test.startTest();
        init();
        
        AllContentDataServer allContentDSObj = new AllContentDataServer();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"status":"ValidationExpired","term":"AllContentDataServer","type":"BlogPost","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
        allContentDSObj.handleRequest();
            
        pageRef.getParameters().put('data','{"status":"Pending","term":"AllContentDataServer","type":"BlogPost","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"status":"Rejected","term":"AllContentDataServer","type":"BlogPost","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"status":"Published","term":"AllContentDataServer","type":"BlogPost","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"status":"Unpublished","term":"AllContentDataServer","type":"BlogPost","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"status":"Draft","term":"AllContentDataServer","type":"BlogPost","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
        allContentDSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"status":"all","term":"AllContentDataServer","type":"BlogPost","sortBy":"publishedNewest","size":10,"peopleId":"' + UserContext.peopleId + '","filter":"must_read"}');
        allContentDSObj.handleRequest();
        
        System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testStatrtIndexingForAI() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'initialSetup',true));
        init();
        
        AllContentDataServer allContentDSObj = new AllContentDataServer();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','statrtIndexingForAI');
        pageRef.getParameters().put('data','{}');
        allContentDSObj.handleRequest();
        
        System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testContentRatings() {
		Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AIRelatedContent',false)); 
        AllContentDataServer allContentDSObj = new AllContentDataServer();
        allContentDSObj.getAIRelatedContent('{"contentId":"'+ publishedContent.Id+ '"}');
	    ResponseWrapper resp = allContentDSObj.rateContent('{"siteId":"'+ content.Site__c + '","contentId":"'+ content.Id+ '","isUsefulBool":true}');
		Content_Feedback__c feedbackObj = [select id from Content_Feedback__c where Simpplr_Content__c=:content.id limit 1];
        resp = allContentDSObj.deleteRatings('{"siteId":"'+ content.Site__c + '","contentId":"'+ content.Id+ '","recordId":"'+ feedbackObj.id+ '","isUsefulBool":true}');
		allContentDSObj.getPopularContentListWrap('page', pendingContent.Site__c);
		allContentDSObj.getLatestContentListWrap('page', pendingContent.Site__c );
		allContentDSObj.getRelated('{"contentId":"'+ content.Id+ '"}', false);
        allContentDSObj.getRelated('{"contentId":"'+ publishedContent.Id+ '"}', false);
        system.assertEquals('error', resp.status, 'Running as expected');
        Test.stopTest();
	}
    
    @isTest static void testDelete() {
        Test.startTest();
    	init();
        CollaborationGroup priCollabGrp = new CollaborationGroup();
        priCollabGrp = TestHelper.createCollaborationGroup('SiteAddAlbumDataServer_Grp', 'Public');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'getJWTToken',false));
        List<Simpplr_Site__c> listOfSitePublic = [select id, Name, Chatter_Group_Id__c FROM 
              Simpplr_Site__c  WHERE Chatter_Group_Id__c=:priCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSitePublic[0].Id});
        User UserObj = TestHelper.createUser('SiteAddAlbumDataServer_User', null, false);
        people__c pObj = [select id from people__c where user__c =:UserObj.id];
        Simpplr_Content__c Content = TestHelper.createContent('simpplr test Album', 'Album', 'Submitted', UserObj, listOfSitePublic[0]);
        File__c fileObj = TestHelper.createContentTitleImage(Content.id); 
        Folder__c folderObj = TestHelper.createChatterFolder('Albums', null, listOfSitePublic[0].id, 'Intranet', null, 'readwrite');
        folderObj.External_Folder_Id__c = Content.id;
        update folderObj;
        App_Notification__c notiObj = TestHelper.createSimpplrNotification('Dummy', pObj.id,null,'Like',Content.id,null);
	    AllContentDataServer allContentDSObj = new AllContentDataServer();
        ResponseWrapper resp = allContentDSObj.deleteContent('{"siteId":"'+listOfSitePublic[0].id+'","contentId":"'+Content.id+'"}');
        allContentDSObj.getModerationHistory('{"id":"' + pendingContent.Id + '","size":16 ,"nextPageToken":200}');
	    system.assert(true,'Running as expected');
        Test.stopTest();
    	} 
  
    
    @isTest static void testApprove() {
        Test.startTest();
    	init();
        AllContentDataServer allContentDSObj = new AllContentDataServer();
        allContentDSObj.approveContent('{"siteId":"'+pendingContent.site__c+'","contentId":"'+pendingContent.id+'","status":"Rejected","filter":"updates"}');
		allContentDSObj.getModerationHistory('{"id":"' + pendingContent.Id + '","size":16 ,"nextPageToken":200}');
	    System.assert(true,'Running as expected');	
        Test.stopTest();
    }
    
    @isTest static void testReject() {
        Test.startTest();
    	init();
        pendingContent.status__c = 'Submitted';
        update pendingContent;
        
        AllContentDataServer allContentDSObj = new AllContentDataServer();
	    ResponseWrapper resp = allContentDSObj.rejectContent('{"siteId":"'+pendingContent.site__c+'","contentId":"'+pendingContent.id+'","rejectionComment":"rejected because i want to reject","status":"Submitted","filter":"owned","excludeType":"albums"}');
        allContentDSObj.getModerationHistory('{"id":"' + pendingContent.Id + '","size":16}');
		System.assert(true,'Running as expected');	
        Test.stopTest();
    }
    

    @isTest static void testUnpublish() {
        Test.startTest();
    	init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
		AllContentDataServer allContentDSObj = new AllContentDataServer();
        pendingContent.Publish_End_DateTime__c = DateTime.Now().addDays(2);
        update pendingContent;
        Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(pendingContent.id, 'everyone', UserContext.peopleId);
		ResponseWrapper resp = allContentDSObj.unpublishContent('{"siteId":"'+pendingContent.site__c+'","contentId":"'+pendingContent.id+'"}');
		allContentDSObj.getModerationHistory('{"id":"' + pendingContent.Id + '","size":16}');
        Test.stopTest();
		System.assert(true,'Running as expected');
    }
    
    @isTest static void testPublish() {
        Test.startTest();
    	init();
        
        pendingContent.Publish_End_DateTime__c = DateTime.Now().addDays(2);
        update pendingContent;
	    AllContentDataServer allContentDSObj = new AllContentDataServer();
	    ResponseWrapper resp = allContentDSObj.publishContent('{"siteId":"'+pendingContent.site__c+'","contentId":"'+pendingContent.id+'","type":"album"}');
        allContentDSObj.getModerationHistory('{"id":"' + pendingContent.Id + '","size":16}');
	    System.assert(true,'Running as expected');	
        Test.stopTest();
    }
    
     @isTest static void testRate() {
		Test.startTest();
    	init();    	
    	AllContentDataServer allContentDSObj = new AllContentDataServer();
    	ResponseWrapper resp = allContentDSObj.rateContent('{"isUsefulBool":true,"contentId":"'+albumContent.id+'","comment":"I found the content Useful"}');
        string b = allContentDSObj.getPageFeature();
    	System.assertEquals('success', resp.status, 'Running as expected');
		Test.stopTest();
    }
    
    @isTest static void testGetRatings() {
		Test.startTest();
    	init();    		
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.rateContent('{"isUsefulBool":true,"contentId":"'+publishedContent.id+'","comment":"I found the content Useful"}');
		ResponseWrapper resp2 = allContentDSObj.getRatings('{"contentId":"'+publishedContent.id+'","nextPageToken":null,"limit":8 }');
		allContentDSObj.getModerationHistory('{"id":"' + publishedContent.Id + '","size":16}');
		System.assertEquals('success', resp.status, 'Running as expected');
		System.assertEquals('success', resp2.status, 'Running as expected');
		Test.stopTest();
    }

	@isTest static void testGetContentsByTopic() {
		Test.startTest();
    	init();    	
		Topic topicObj = [select id from topic where name='AllContentDataServerTestTopic'];	
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.rateContent('{"isUsefulBool":true,"contentId":"'+publishedContent.id+'","comment":"I found the content Useful"}');
		ResponseWrapper resp2 = allContentDSObj.getRatings('{"contentId":"'+publishedContent.id+'","nextPageToken":null,"limit":8}');
		allContentDSObj.getContentsByTopic('{"contentId":"'+publishedContent.id+'","topicId":"'+topicObj.id+'","filter":"topic","limit":8,"size":6,"nextPageToken":200,"sortBy":"publishedNewest","term":"aaa","nextPageToken":200,"excludeType":"Event"}');
        allContentDSObj.getContentsByTopic('{"contentId":"'+publishedContent.id+'","topicId":"'+topicObj.id+'","filter":"topic","limit":8,"size":6,"nextPageToken":200,"sortBy":"most_liked"}');
        allContentDSObj.getContentsByTopic('{"contentId":"'+publishedContent.id+'","topicId":"'+topicObj.id+'","filter":"topic","limit":8,"size":6,"nextPageToken":200,"sortBy":"most_viewed"}');
        allContentDSObj.getContentsByTopic('{"contentId":"'+publishedContent.id+'","topicId":"'+topicObj.id+'","filter":"topic","type":"page","excludeType":"pages"}');
		System.assert(true,'Running as expected');
		Test.stopTest();
    }
   
     @isTest static void testSubmitContent() {
        Test.startTest();
    	init();
        pendingContent.status__c = 'Rejected';
        update pendingContent;
	    AllContentDataServer allContentDSObj = new AllContentDataServer();
	    allContentDSObj.submitContent('{"siteId":"'+pendingContent.site__c+'","contentId":"'+pendingContent.id+'","isSuccess":"true"}');       
        System.assert(true,'Running as expected');
		Test.stopTest();
    }
    
    @isTest static void testDismissValidation() {
        Test.startTest();
    	init();
        AllContentDataServer allContentDSObj = new AllContentDataServer();
        CollaborationGroup priCollabGrp = new CollaborationGroup ();
		priCollabGrp = TestHelper.createCollaborationGroup('AllContent_Grp', 'Private');
		List<Simpplr_Site__c> listOfSitePrivate = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:priCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSitePrivate[0].Id});
        Simpplr_Content__c conObj =  TestHelper.createContent( 'title',  'Page',  'knowledge',  'Approved',  adminUserObj,  DateTime.Now(), DateTime.Now().addDays(2),  listOfSitePrivate[0]);
        Content_Audit_Trail__c auditTrailObj = new Content_Audit_Trail__c();
        auditTrailObj.Content__c = conObj.id;
        insert auditTrailObj;
        ResponseWrapper resp =  allContentDSObj.dismissValidation('{"contentId":"'+conObj.id+'","type":"required"}');
        System.assert(true,'Running as expected');
		Test.stopTest();

    }
    
    @isTest static void testMakeMustread() {
        Test.startTest();
    	init();
        People__c peopleObj = [Select Id From People__c Limit 1];
        Simpplr_Site__c site = TestHelper.getSiteRecordWithName('AllContentDataServerTest_Grp1');
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(peopleObj.Id, site.Id);
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
        adminUsersPeopleObj = [Select id From People__c where user__c =:adminUserObj.id];
        adminUsersPeopleObj.Mobile_Token_Android__c = 'dunny';
        adminUsersPeopleObj.Mobile_Token_IOS__c = 'dummy';
        update adminUsersPeopleObj;
        People_Preference__c peoplePrefObj = TestHelper.createPeoplePreference(adminUsersPeopleObj.id);
        peoplePrefObj.Allow_Simpplr_Emails__c = true;
        peoplePrefObj.Email_Content_Marked_As_Must_Read__c = true;
        peoplePrefObj.Email_Notification_Digest_Frequency__c= 'Immediate';
        update peoplePrefObj;
		AllContentDataServer allContentDSObj = new AllContentDataServer();        
		appConfigRecord.Simpplr_Mobile_Notification_Allowed__c = true;
        update appConfigRecord;
        allContentDSObj.makeMustRead('{"contentId":"'+albumContent.id+'","audience":"site_members_and_followers"}');
		allContentDSObj.sendMustReadReminderMail('{"contentId":"'+albumContent.id+'"}');
        Test.stopTest();
	    System.assert(true,'Running as expected');
    }
    
    @isTest static void testRemoveMustread() {
        Test.startTest();
    	init();    	    
        albumContent.Is_Deleted__c = false;
        update albumContent;
        Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(albumContent.id, 'everyone', UserContext.peopleId);
        mustReadAuditObj.Removed_DateTime__c = null;
        update mustReadAuditObj;    
	    AllContentDataServer allContentDSObj = new AllContentDataServer();
	    ResponseWrapper resp = allContentDSObj.removeMustRead('{"contentId":"'+albumContent.id+'"}');                 
        ResponseWrapper resp2 = allContentDSObj.resetMustRead('{"contentId":"'+albumContent.id+'"}');
        Test.stopTest();
	    System.assert(true,'Running as expected');
    }
    
    @isTest static void testResetMustread() {
        Test.startTest();
    	init();    
        System.runAs(adminUserObj) {
	    	AllContentDataServer allContentDSObj = new AllContentDataServer();
			InternalRequestWrapper.MustRead reqMustReadWrapObj = new InternalRequestWrapper.MustRead();
			reqMustReadWrapObj.contentId = publishedContent.id;
	    	ResponseWrapper resp = allContentDSObj.makeMustRead(json.serialize(reqMustReadWrapObj));
	    	ResponseWrapper resp2 = allContentDSObj.resetMustread('{"contentId":"'+publishedContent.id+'"}');


	    	System.assert(true,'Running as expected');
        }
        Test.stopTest();
    }
    
    @isTest static void testMarkAsRead() {
        Test.startTest();
    	init();    	
    	System.runAs(adminUserObj) {
	    	AllContentDataServer allContentDSObj = new AllContentDataServer();
			InternalRequestWrapper.MustRead reqMustReadWrapObj = new InternalRequestWrapper.MustRead();
			reqMustReadWrapObj.contentId = albumContent.id;
            reqMustReadWrapObj.audience = 'everyone';
            UserContext.isUserAppModerator = true;
	    	ResponseWrapper resp = allContentDSObj.makeMustRead(json.serialize(reqMustReadWrapObj));
            Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(publishedContent.id, 'everyone', UserContext.peopleId);
            mustReadAuditObj.Removed_DateTime__c = null;
            mustReadAuditObj.Expiry_DateTime__c = null;
            update mustReadAuditObj;
            ResponseWrapper resp2 = allContentDSObj.markAsRead('{"contentId":"'+publishedContent.id+'"}');
            Must_Read_Confirm_History__c readConfirmHistoryObj = new Must_Read_Confirm_History__c();
            readConfirmHistoryObj.Content__c = publishedContent.id;
            readConfirmHistoryObj.People__c = UserContext.peopleId;
            readConfirmHistoryObj.Must_Read_Audit__c = mustReadAuditObj.id;
            insert readConfirmHistoryObj;
            App_Notification__c notiObj = TestHelper.createSimpplrNotification('Dummy',UserContext.peopleId,null,'Must Read',publishedContent.id,null);
            notiObj.is_read__c = false;
            update notiObj;
            allContentDSObj.markAsRead('{"contentId":"'+publishedContent.id+'"}');
	    	System.assert(true,'Running as expected');
    	} 
        Test.stopTest();
    }

    @isTest static void testGetExpiringContentCounts() {
        Test.startTest();
    	init();    	
    	System.runAs(adminUserObj) {
	    	AllContentDataServer allContentDSObj = new AllContentDataServer();
            InternalRequestWrapper.MustRead reqMustReadWrapObj = new InternalRequestWrapper.MustRead();
			allContentDSObj.getExpiringContentCounts('');
            pendingContent.Is_Deleted__c = true;
            update pendingContent;
            UserContext.isUserAppModerator = true;
            allContentDSObj.getExpiringContentCounts('{"siteId":"'+pendingContent.site__c+'","contentId":"'+pendingContent.id+'"}');
	    	System.assert(true, 'Running as expected');
        }  
        Test.stopTest(); 
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c,user__r.name, Mobile_Phone__c, Manager__c, 
        							Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
									From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }

	 @isTest static void testContentMove() {
        Test.startTest();
    	init();
        AllContentDataServer allContentDSObj = new AllContentDataServer();
        ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + pendingContent.id+'"],"siteId":"'+pendingContent.site__c+'","type": "page","CategoryId":"pageCategory.id"}');
        System.assert(true,'Running as expected'); 
        Test.stopTest();
    }

	@isTest static void testContentMovePublicToPrivate() {
    	Test.startTest();
        init();
		CollaborationGroup privateCollabGrp = new CollaborationGroup ();
		privateCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPriv_2', 'Private');
		List<Simpplr_Site__c> listOfSitePrivate = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:privateCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSitePrivate[0].Id});
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + pendingContent.id+'"],"siteId":"'+listOfSitePrivate[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }

    @isTest static void testContentMovePrivateToPublic() {
    	Test.startTest();
        User testUser = TestHelper.createUser('Allcontent_usr1', null, false);
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('Allcontent_Grp1', 'Private').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
		CollaborationGroup privateCollabGrp = new CollaborationGroup ();
        privateCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPriv_2', 'Public');
		List<Simpplr_Site__c> listOfSitePublic = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:privateCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSitePublic[0].Id, testSite.Id});
        Simpplr_Content__c simpplrContent = TestHelper.createContent('Allconten Event', 'Event', 'Approved', testUser, testSite);
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + simpplrContent.id+'"],"siteId":"'+listOfSitePublic[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testContentMovePrivateToUnlisted() {
    	Test.startTest();
        User testUser = TestHelper.createUser('Allcontent_usr1', null, false);
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('Allcontent_Grp1', 'Private').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
		CollaborationGroup privateCollabGrp = new CollaborationGroup ();
        privateCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPriv_2', 'Unlisted');
		List<Simpplr_Site__c> listOfSiteUnlisted = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:privateCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id, listOfSiteUnlisted[0].Id});
        Simpplr_Content__c simpplrContent = TestHelper.createContent('Allcontent Event', 'Event', 'Approved', testUser, testSite);
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + simpplrContent.id+'"],"siteId":"'+listOfSiteUnlisted[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testContentMovePrivateToPrivate() {
    	Test.startTest();
        User testUser = TestHelper.createUser('Allcontent_usr1', null, false);
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('Allcontent_Grp1', 'Private').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
		CollaborationGroup privateCollabGrp = new CollaborationGroup ();
        privateCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPriv_2', 'Private');
		List<Simpplr_Site__c> listOfSitePrivate = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:privateCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id, listOfSitePrivate[0].Id});
        Simpplr_Content__c simpplrContent = TestHelper.createContent('Allcontent Event', 'Event', 'Approved', testUser, testSite);
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + simpplrContent.id+'"],"siteId":"'+listOfSitePrivate[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testContentMoveUnlistedToPublic() {
    	Test.startTest();
        User testUser = TestHelper.createUser('Allcontent_usr1', null, false);
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('Allcontent_Grp1', 'Unlisted').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
		CollaborationGroup UnlistedCollabGrp = new CollaborationGroup ();
        UnlistedCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPriv_2', 'Public');
		List<Simpplr_Site__c> listOfSitePublic = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:UnlistedCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id, listOfSitePublic[0].Id});
        Simpplr_Content__c simpplrContent = TestHelper.createContent('Allcontent Event', 'Event', 'Approved', testUser, testSite);
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + simpplrContent.id+'"],"siteId":"'+listOfSitePublic[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testContentMoveUnlistedToPrivate() {
    	Test.startTest();
        User testUser = TestHelper.createUser('Allconten_usr1', null, false);
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('Allconten_Grp1', 'Unlisted').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
		CollaborationGroup UnlistedCollabGrp = new CollaborationGroup ();
        UnlistedCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPriv_2', 'Private');
		List<Simpplr_Site__c> listOfSitePrivate = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:UnlistedCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id, listOfSitePrivate[0].Id});
        Simpplr_Content__c simpplrContent = TestHelper.createContent('Allcontens Event', 'Event', 'Approved', testUser, testSite);
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + simpplrContent.id+'"],"siteId":"'+listOfSitePrivate[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testContentMoveUnlistedToUnlisted() {
    	Test.startTest();
        User testUser = TestHelper.createUser('Allcontent_usr1', null, false);
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('AllcontentGrp1', 'Unlisted').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
		CollaborationGroup UnlistedCollabGrp = new CollaborationGroup ();
        UnlistedCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPriv_2', 'Unlisted');
		List<Simpplr_Site__c> listOfSiteUnlisted = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:UnlistedCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id, listOfSiteUnlisted[0].Id});
        Simpplr_Content__c simpplrContent = TestHelper.createContent('Allcontent Event', 'Event', 'Approved', testUser, testSite);
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + simpplrContent.id+'"],"siteId":"'+listOfSiteUnlisted[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
	@isTest static void testContentMovePublicToPublic() {
    	Test.startTest();
        init();
		CollaborationGroup pubCollabGrp = new CollaborationGroup ();
		pubCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpPub_2', 'Public');
		List<Simpplr_Site__c> listOfSitePublic = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:pubCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSitePublic[0].Id});
        File__c fileObj = TestHelper.createContentTitleImage(pendingContent.id);
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + pendingContent.id+'"],"siteId":"'+listOfSitePublic[0].id+'","categoryId":null}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
        @isTest static void testContentMovePublicToUnlisted() {
    	Test.startTest();
        init(); 
        CollaborationGroup UnlistedCollabGrp = TestHelper.createCollaborationGroup('AllContent_GrpUnl_2', 'Unlisted');
		List<Simpplr_Site__c> listOfSiteUnlisted = [select id, Name, Chatter_Group_Id__c FROM 
				Simpplr_Site__c  WHERE Chatter_Group_Id__c=:UnlistedCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSiteUnlisted[0].Id});
        AllContentDataServer allContentDSObj = new AllContentDataServer();
		ResponseWrapper resp = allContentDSObj.moveContent('{"contentIdList":["' + pendingContent.id+'"],"siteId":"'+listOfSiteUnlisted[0].id+'"}');
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
   
	@isTest static void testInsertSearchTrailObjectForContentList() {
        Test.startTest();
    	init();
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		allContentDSObj.insertSearchTrailObjectForContentList(new List<string>{pendingContent.id});
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
     @isTest static void testCheckAndApproveNotifications() {
        Test.startTest();
    	init();
		AllContentDataServer allContentDSObj = new AllContentDataServer();
		allContentDSObj.checkAndApproveNotifications(pendingContent);
		System.assert(true,'Running as expected');
        Test.stopTest();
    }
	
     @isTest static void testGetCustomTilesData() {
        Test.startTest();
    	init();
		AllContentDataServer allContentDSObj = new AllContentDataServer();
        allContentDSObj.getCustomTilesData(pendingContent.site__c,new List<string>{pendingContent.id});
		System.assert(true,'Running as expected');
        Test.stopTest();
    }

    @isTest static void testGetByIds() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','getByIds');
        pgRef.getParameters().put('data', '["'+pendingContent.id+'"]');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }
    @isTest static void testGetPopularContents() {
        Test.startTest();
    	init();
        People__c people = [SELECT Id FROM People__c WHERE User__r.lastname = 'AllContentDataServerTest_Simpplr_admin'];
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','getPopularContents');
       	pgRef.getParameters().put('data', '{}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);

        pgRef.getParameters().put('data', '{"isAllContent":"true"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);

       	pgRef.getParameters().put('data', '{"isAllContent":"false","peopleIdContext":"true","personId":"'+people.Id+'"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
        Test.stopTest();
    }
     
    @isTest static void testGetLatestContents() {
        Test.startTest();
    	init();
        People__c people = [SELECT Id FROM People__c WHERE User__r.lastname = 'AllContentDataServerTest_Simpplr_admin'];
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','getLatestContents');
        pgRef.getParameters().put('data', '{}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);

        pgRef.getParameters().put('data', '{"isAllContent":"true"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);

        pgRef.getParameters().put('data', '{"isAllContent":"false","peopleIdContext":"true","personId":"'+people.Id+'"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
        Test.stopTest();
    }

    /**
     * @description test case with custom address fields
     */
    @isTest static void testPrepareMustReadHistoryCsv() {
		Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
        AllContentDataServer allContentDSObj = new AllContentDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AllContentDataServer');
        pageRef.getParameters().put('action','prepareBulkDataCsv');
        pageRef.getParameters().put('data', '{"contentId":"'+ publishedContent.Id+ '","filter":"all"}');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
        System.assertEquals('success', allContentDSObj.response.status, 'Running as Expected');
        Test.stopTest();
	}
    
    @isTest static void testSaveContentOnboardingStatus() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','saveContentOnboardingStatus');
        pgRef.getParameters().put('data', '{"contentId":"' +content.Id+ '", "onboardingStatus":"orgOnboarding","type":"album"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }
    
    @isTest static void testGetOnboardingContents() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','search');
        pgRef.getParameters().put('data', '{"status":"onboarding","siteId":"' +site.Id+ '","type":"album"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }
    
    @isTest static void testGetOnboardingHistory() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','getOnboardingHistory');
        pgRef.getParameters().put('data', '{"id":"' +content.Id+ '","type":"album"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }
    @isTest static void testUpdateContentPosition() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','updateContentPosition');
        pgRef.getParameters().put('data', '{"contentIdArray":["' + pendingContent.id+'"],"siteId":"'+pendingContent.site__c+'"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }
    
    @isTest static void testMoveContentToBottom() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','moveContentToBottom');
        pgRef.getParameters().put('data', '{"contentId":"' +content.Id+ '","siteId":"' +site.Id+ '"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }

	@isTest static void testMoveContentToTop() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','moveContentToTop');
        pgRef.getParameters().put('data', '{"contentId":"' +content.Id+ '","siteId":"' +site.Id+ '"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }
    
    @isTest static void testGetMyOnboardingContents() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','AllContentDataServer');
        pgRef.getParameters().put('action','getMyOnboardingContents');
        pgRef.getParameters().put('data', '{"type":"album", "sortBy":"site"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"type":"album", "sortBy":"dateadded"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"type":"album", "sortBy":"read"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status ,serverObj.response.message);
    }
    
    @isTest static void testGetFeedOnboardingContents() {
        Test.startTest();
    	init();
        AllContentDataServer serverObj = new AllContentDataServer();
        ResponseWrapper result = serverObj.getFeedOnboardingContents('{"siteId":"' +site.Id+ '", "type":"page"}');
        Test.stopTest();
        System.assertEquals('success',result.status ,result.message);
    }
    @isTest static void testSearchFavContent() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchContents',true));
        init(); 
        AllContentDataServer allContentDSObj = new AllContentDataServer();      
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AllContentDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"status":"all","term":"AllContentDataServer","type":"page","sortBy":"publishedNewest","filter":"favorites","size":10,"excludeType":"blogs","nextPageToken":3}');
        allContentDSObj.handleRequest();  
        System.assertEquals('success',allContentDSObj.response.status ,allContentDSObj.response.message);
        pageRef.getParameters().put('data','{"status":"all","term":"","type":"page","sortBy":"publishedNewest","filter":"favorites","size":10,"excludeType":"blogs","nextPageToken":3}');
        allContentDSObj.handleRequest();
        System.assertEquals('success',allContentDSObj.response.status ,allContentDSObj.response.message); 
        pageRef.getParameters().put('data','{"status":"all","term":"AllContentDataServer","type":"page","sortBy":"publishedNewest","filter":"canAddToNewsletter","size":10,"excludeType":"blogs","nextPageToken":3}');
        allContentDSObj.handleRequest();
        System.assertEquals('success',allContentDSObj.response.status ,allContentDSObj.response.message);
        Test.stopTest();
    }

    @isTest static void testContentWrapperMethods() {
        init();
        Test.startTest();
        List<String> contentList = new List<String>();
        Topic topicObj = TestHelper.createTopic('ContentWrapperTestTopic');
        contentList.add(content.id);
        contentList.add(publishedContent.id);
        ContentWrapper contentWrapper = new ContentWrapper();
        contentWrapper.id = content.id;
        contentWrapper.compareTo(contentWrapper);
        contentWrapper.relevancyScore = 2;
        contentWrapper.compareTo(contentWrapper);
        List<TopicAssignment> topicList = contentWrapper.getTopicList(contentList);
        Test.stopTest();
        System.assert(true,'Running as expected');
    }


}