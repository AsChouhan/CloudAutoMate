@isTest
public with sharing class ExternalSearchDataServerTest {
    
    @testSetup
    static void setUp() {
        App_Config__c appConfigRecord = TestHelper.setupAppconfig();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        TestHelper.createPeoplePreference(peopleObj.Id);
        User managerUserObj = TestHelper.createUser('Simpplr_usr', null, false); 
        appConfigRecord.External_Search_Enabled__c=true;
        appConfigRecord.External_search_app_connected__c=true;
        appConfigRecord.AWS_Access_Token__c= UserInfo.getOrganizationId() + ':OrgName:sometoken';
        appConfigRecord.External_Search_Base_URL__c = 'http://qa.simpplr-search.com/';
        update appConfigRecord;
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(false, new Set<String>{'native_video'});
        List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, peopleObj.id, 'sadadqeq');
        List<App_Integration__c> appIntListGoogleDrive  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'googledrive'});
        TestHelper.createPeopleIntegrationRecords(appIntListGoogleDrive, peopleObj.id, 'sadadqeq');
        Simpplr_Content__c simpContentObj = TestHelper.createContent('ExternaltestBlogPostRecord', 'BlogPost', 'Approved', managerUserObj, null);
        TestHelper.createCollaborationGroup('FileDataServerTestExternal', 'Public');    	     
        TestHelper.createFileRecordForVideo(simpContentObj.id, 'DummyUrl');
        TestHelper.getMailerRecord('ExternaltestnewLetter', UserContext.peopleId, null, simpContentObj.Id);
        Must_Read_Audit__c mustReadObj = TestHelper.createMustReadAudit(simpContentObj.id, 'everyone' , peopleObj.id);
        Must_Read_Confirm_History__c mustReadAuditHistoryObj = new Must_Read_Confirm_History__c();
        mustReadAuditHistoryObj.Must_Read_Audit__c = mustReadObj.Id;
        mustReadAuditHistoryObj.people__c = peopleObj.id;
        mustReadAuditHistoryObj.Content__c = simpContentObj.Id;
        insert mustReadAuditHistoryObj;
        
        System.assert(true,'Running as expected');
	}
	
	@isTest static void testhandleExternalSearchForTop() {
        Test.startTest(); 
        ResponseWrapper resp = new ResponseWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchTopResuls',true));
        ApexPages.currentPage().getParameters().put('target', 'ExternalSearchDataServer');
        ExternalSearchDataServer obj = new ExternalSearchDataServer();
        String contentCriteria = '{"term":"Arvind","size":16,"section":"Top","isCorrectionEnabled":true}';
        resp = obj.handleExternalSearch(contentCriteria,'Top');
        system.assertEquals('fail', resp.status, 'Running as expected');
        Test.stopTest();
    }
     
    @isTest static void testhandleExternalSearchForPeople() {
        Test.startTest(); 
        ResponseWrapper resp = new ResponseWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchPeople',true));
        ApexPages.currentPage().getParameters().put('target', 'ExternalSearchDataServer');
        ExternalSearchDataServer obj = new ExternalSearchDataServer();  
        String  peopleSearchCriteria = '{"term":"Arvind","size":16,"section":"User","isCorrectionEnabled":true,"department":"Product Development","location":"Gurugram @@ Haryana @@ IN"}';
        resp = obj.handleExternalSearch(peopleSearchCriteria,'User');
        system.assertEquals('success', resp.status, 'Running as expected');
        Test.stopTest();
    }
     
     
    @isTest static void testhandleExternalSearchForSite() {
        Test.startTest(); 
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchSites',true));
        ApexPages.currentPage().getParameters().put('target', 'ExternalSearchDataServer');
        ExternalSearchService obj = new ExternalSearchService();
        Criteria.ExternalSearchReq siteSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"Site","isCorrectionEnabled":true}', Criteria.ExternalSearchReq.class);
        resp = obj.searchSites(siteSearchCriteria,'Site');
        system.assertEquals(2, resp.listOfItems.size(), 'Running as expected');
        Test.stopTest();
    }
      
    @isTest static void testhandleExternalSearchForContent() {
        Test.startTest(); 
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchContents',true));
        ExternalSearchService obj = new ExternalSearchService();
        Criteria.ExternalSearchReq contentSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize('{"term":"Random","size":16,"section":"Content","isCorrectionEnabled":true,"publishStartDate":"past_year","contentType":"Page"}', Criteria.ExternalSearchReq.class);
        resp = obj.searchContents(contentSearchCriteria,'Content');
        system.assertEquals(2, resp.listOfItems.size(), 'Running as expected');
        Test.stopTest();
    }
     
    @isTest static void testhandleExternalSearchForFiles() {
        Test.startTest(); 
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchFiles',true));
        ExternalSearchService obj = new ExternalSearchService();
        Criteria.ExternalSearchReq fileSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File","isCorrectionEnabled":true}', Criteria.ExternalSearchReq.class);
        resp = obj.searchFiles(fileSearchCriteria,'File');
        system.assertEquals(2, resp.listOfItems.size(), 'Running as expected');
        Test.stopTest();     
    }

    @isTest static void testhandleExternalSearchForNativeVideos() {
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchNativeVideos',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','NativeVideo');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"NativeVideo","isCorrectionEnabled":true, "searchSite":false}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'External search failed');
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForTopics() {
        Test.startTest();
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchTopic',true));
        ExternalSearchService obj = new ExternalSearchService();  
        ManageContentRequestWrapper requestWrapper = new ManageContentRequestWrapper();
        requestWrapper.size = 16;
        requestWrapper.term = 'Random';
        requestWrapper.sortBy = 'alphabetical'; 
        resp = obj.searchTopic(requestWrapper);
        system.assertEquals(1, resp.listOfItems.size(), 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForExpertise() {
        Test.startTest(); 
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchExpertise',true));
        ExternalSearchService obj = new ExternalSearchService();
        ManageContentRequestWrapper requestWrapper = new ManageContentRequestWrapper();
        requestWrapper.size = 16;
        requestWrapper.term = 'Random';
        requestWrapper.sortBy = 'alphabetical';   
        resp = obj.searchExpertise(requestWrapper); 
        system.assertEquals(1, resp.listOfItems.size(), 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForAlert() {
        Test.startTest(); 
        List<String> resp = new List<String>();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchAlert',true));
        ExternalSearchService obj = new ExternalSearchService(); 
        Criteria.ExternalSearchReq searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File","sortBy":"createdNewest"}', Criteria.ExternalSearchReq.class);
        resp = obj.searchAlert(searchCriteria); 
        system.assertEquals(1, resp.size(), 'Running as expected');
        
        searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File","sortBy":"createdOldest"}', Criteria.ExternalSearchReq.class);
        resp = obj.searchAlert(searchCriteria); 
        system.assertEquals(1, resp.size(), 'Running as expected');
        
        searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File","sortBy":"displayToNewest"}', Criteria.ExternalSearchReq.class);
        resp = obj.searchAlert(searchCriteria); 
        system.assertEquals(1, resp.size(), 'Running as expected');
        
        searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File","sortBy":"displayToOldest"}', Criteria.ExternalSearchReq.class);
        resp = obj.searchAlert(searchCriteria); 
        system.assertEquals(1, resp.size(), 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForNewsletter() {
        Test.startTest(); 
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchNewsletters',true));
        ExternalSearchService obj = new ExternalSearchService();        
        Criteria.ExternalSearchReq searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File"}', Criteria.ExternalSearchReq.class); 
        resp = obj.searchNewsletters(searchCriteria, 'Newsletter');
        system.assertEquals(3, resp.listOfItems.size(), 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForSiteCategory() {
        Test.startTest();
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchSiteCategory',true));
        ExternalSearchService obj = new ExternalSearchService();    
        Criteria.ExternalSearchReq searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File"}', Criteria.ExternalSearchReq.class);
        resp = obj.searchSiteCategory(searchCriteria, 'Site_Category');
        system.assertEquals(1, resp.listOfItems.size(), 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForChatterGroups() {
        Test.startTest();
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper(); 
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchChatterGroups',true));
        ExternalSearchService obj = new ExternalSearchService();        
        Criteria.ExternalSearchReq searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File"}', Criteria.ExternalSearchReq.class); 
        resp = obj.searchChatterGroups(searchCriteria, 'Chatter_Group');
        system.assertEquals(1, resp.listOfItems.size(), 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForPageCategories() {
        Test.startTest();
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper(); 
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchPageCategories',true));
        ExternalSearchService obj = new ExternalSearchService();      
        Criteria.ExternalSearchReq searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File"}', Criteria.ExternalSearchReq.class);   
        resp = obj.searchPageCategories(searchCriteria, 'Pages_Category');
        system.assertEquals(1, resp.listOfItems.size(), 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForPeopleDepartment() {
        Test.startTest();
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper(); 
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchPeopleDepartment',true));
        ExternalSearchService obj = new ExternalSearchService();
        Criteria.People peopleCriteriaObj = new Criteria.People();
        peopleCriteriaObj.term = 'Random';
        peopleCriteriaObj.size = 99999;
        resp = obj.searchPeopleDepartment(peopleCriteriaObj); 
        system.assertEquals(1, resp.listOfItems.size(), 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForPeopleLocation() {
        Test.startTest();
        ExternalSearchWrapper.TopContentsWrapper resp = new ExternalSearchWrapper.TopContentsWrapper(); 
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchPeopleLocation',true));
        ExternalSearchService obj = new ExternalSearchService();  
        Criteria.People peopleCriteriaObj = new Criteria.People();
        peopleCriteriaObj.term = 'Random';
        peopleCriteriaObj.size = 99999;
        resp = obj.searchPeopleLocation(peopleCriteriaObj);
        system.assertEquals(1, resp.listOfItems.size(), 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForSiteMembers() {
        Test.startTest();
        List<PeopleListWrapper> resp = new List<PeopleListWrapper>(); 
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getSiteMembers',true));
        ExternalSearchService obj = new ExternalSearchService();        
        Criteria.ExternalSearchReq searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File"}', Criteria.ExternalSearchReq.class);
        resp = obj.getSiteMembers(searchCriteria);
        system.assertEquals(1, resp.size(), 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testhandleExternalSearchForSiteMemberRequest() {
        Test.startTest();
        List<PeopleListWrapper> resp = new List<PeopleListWrapper>(); 
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getSiteMemberRequest',true));
        ExternalSearchService obj = new ExternalSearchService();        
        Criteria.ExternalSearchReq searchCriteria = (Criteria.ExternalSearchReq) Json.deserialize('{"term":"Random","size":16,"section":"File"}', Criteria.ExternalSearchReq.class);
        resp = obj.getSiteMemberRequest(searchCriteria);
        system.assertEquals(1, resp.size(), 'Running as expected');  
        Test.stopTest();
    }


    @isTest static void testexternalSearchAutoComplete() {
        Test.startTest(); 
        ResponseWrapper resp = new ResponseWrapper(); 
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'externalSearchAutoComplete',true));
        ApexPages.currentPage().getParameters().put('target', 'ExternalSearchDataServer');
        ExternalSearchDataServer obj = new ExternalSearchDataServer();
        String searchCriteria = '{"term":"Random"}';
        resp = obj.externalSearchAutoComplete(searchCriteria);
        system.assertEquals('success', resp.status, 'Running as expected');  
        Test.stopTest();
    }
     
    @isTest static void testsaveSearchStats() {
        Test.startTest(); 

        String requestData = '{"url":"/apex/app?u=/search&term=wonder&siteId=a0W360000077WeZEAU&searchSite=false","term":"wonder","siteId":"a0W360000077WeZEAU","totalTimeTaken":9395,"totalResultCount":2,"sections":["Content"]}';
        Simpplr_social_analytics__c obj = new Simpplr_social_analytics__c(Search_Results_Summary__c=requestData);
        obj.Interaction__c = 'View';
        obj.Search_Text__c = 'wonder';
        insert obj;         
        ExternalSearchDataServer.saveSearchStats(requestData);      	
        Test.stopTest();
        Simpplr_social_analytics__c result = [select id, Search_Results_Count__c from Simpplr_social_analytics__c where id = :obj.id];
        system.assertEquals(2, result.Search_Results_Count__c, 'Result count should be 2');
    }
	 
	@isTest static void testBatchPushDataForExternalSearchForFailedTransactions() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'FailedTransactions',false));
		BatchPushDataForExternalSearch job = new BatchPushDataForExternalSearch('FailedTransactions', false);
		Database.executeBatch(job,10);
		List<App_Config__c> listOfAppConfig = new List<App_Config__c>();
		App_Config__c appConfig = new App_Config__c(Flow_External_Search_Enabled__c = true);
		listOfAppConfig.add(appConfig);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	 
    @isTest static void testSendFailedTransactionDataForPeople() {
        Test.startTest();
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        String jsonBody = ' ';
        People__c currentUserPeopleObj = [Select id from people__c where User__c=:UserInfo.getUserId()];
        External_Search_Data_Trail__c trailObj = new External_Search_Data_Trail__c(People__c =currentUserPeopleObj.id,Type__c='People');
        insert trailObj;
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'FailedTransactionsForPeople',false));
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForPeople(trailObj.People__c);
        BatchPushDataForExternalSearch job = new BatchPushDataForExternalSearch('FailedTransactions', false);
        Database.executeBatch(job,10);
        System.assertEquals(currentUserPeopleObj.id, resp.id,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapper() {
        Test.startTest();
        TestHelper.createCollaborationGroup('ExternalSearchSiteTest_Grp1', 'Public');
        Simpplr_Site__c siteObj = TestHelper.getSiteRecordWithName('ExternalSearchSiteTest_Grp1');
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        User adminUserObj = TestHelper.createUser('ExternalSearch_Simpplr_admin', null, true);
        Simpplr_Content__c contentObj = TestHelper.createContent('testAlbumRecord', 'Album', 'Approved', adminUserObj, siteObj);
        Topic topicObj = TestHelper.createTopic('ExternalSearchTestTopic');
        TestHelper.addTopicToContent(topicObj.id, contentObj.id);
        
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForSite(siteObj.Id);
        system.assertEquals('ExternalSearchSiteTest_Grp1', resp.site_name, 'Running as expected');
        
        resp = pushDataHelperObj.getSearchDataWrapperForSimpplrContent(contentObj.Id);
        system.assertEquals('Approved', resp.status, 'Running as expected');  
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForEventRSVPResponse() {
        Test.startTest();
        ExternalSearchWrapper.EventRSVPResponseWrapper resp = new ExternalSearchWrapper.EventRSVPResponseWrapper();
        User systemAdmin = TestHelper.createUser('RedirectionServer_admin1', null, true);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('RedirectionServer_Grp12','Public');
        Simpplr_Site__c site = TestHelper.getSiteRecord(cgroup.Id);
        Simpplr_Content__c simpplrContent = TestHelper.createContent('RSVPDataServerTest Event1', 'Event', 'Approved', systemAdmin, site);
        List<People__c> peopleList = [SELECT Id FROM People__c];
        Event_RSVP_Response__c eventRSVPRes = TestHelper.createRSVPResponse(simpplrContent.Id, peopleList[0].Id, 'Yes');       
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForEventRSVPResponse(eventRSVPRes.Id);
        system.assertEquals('Yes', resp.rsvp_response, 'Running as expected');  
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForExpertise() {
        Test.startTest();
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        Expertise__c expertiseRec = TestHelper.setupExpertise();
        Id expertiseId = expertiseRec.Id;
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForExpertise(expertiseId);
        system.assertEquals('Test Simpplr Expertise', resp.expertise_name, 'Running as expected'); 
        delete expertiseRec;
        resp = pushDataHelperObj.getSearchDataWrapperForExpertise(expertiseId);
        system.assertEquals(null, resp.status, 'Running as expected');  
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForAlert() {
        Test.startTest();
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        People__c people = [SELECT Id FROM People__c Limit 1];
        Alert__c alertRec = TestHelper.createAlert(people.Id, Datetime.now());
        Id alertId = alertRec.Id;    
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForAlert(alertId);
        system.assertEquals('test message', resp.alert_message, 'Running as expected'); 
        delete alertRec; 
        resp = pushDataHelperObj.getSearchDataWrapperForAlert(alertId);
        system.assertEquals(null, resp.alert_message, 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testGetSearchDataWrapperForMergeExpertise() {
        Test.startTest();
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        Expertise__c expertiseRecTo = new Expertise__c(Name__c='testsimpplrexpertise1', Display_Name__c='Test Simpplr Expertise 1');
        insert expertiseRecTo;
        Expertise__c expertiseRecFrom = new Expertise__c(Name__c='testsimpplrexpertise2', Display_Name__c='Test Simpplr Expertise 2');
        insert expertiseRecFrom;        
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForMergeExpertise(expertiseRecTo.Id, expertiseRecFrom.Id);
        system.assertEquals(expertiseRecTo.id, resp.merge_from_expertise.id, 'Running as expected');  
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForFile() {
        Test.startTest();
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        File__c fileRec =  [Select id, External_Id__c from File__c where title__c='TitleImage' LIMIT 1];
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForNativeVideo(fileRec.Id);
        system.assertEquals(fileRec.External_Id__c, resp.id, 'Running as expected');  
        Test.stopTest();
    }

    @isTest static void testGetSearchDataWrapperForTopic() {
        Test.startTest();
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        Topic topicRec = new Topic();
        topicRec.Name = 'testTopic';
        insert topicRec;
        Id topicId = topicRec.Id;
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForTopic(topicId);
        system.assertEquals('testTopic', resp.topic_name, 'Running as expected');  
        delete topicRec;
        resp = pushDataHelperObj.getSearchDataWrapperForTopic(topicId);
        system.assertEquals(true, resp.is_deleted, 'Running as expected');  
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForMergeTopic() {
        Test.startTest();
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();
        Topic topicTo = TestHelper.createTopic('Topic mergeTo');
        Topic topicFrom = TestHelper.createTopic('Topic mergeFrom');
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForMergeTopic(topicTo.id, topicFrom.id);
        system.assertEquals(topicFrom.id, resp.merge_from_topic, 'Running as expected'); 
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForSiteRole() {
        Test.startTest();
        ExternalSearchWrapper.SiteRole resp = new ExternalSearchWrapper.SiteRole();
        CollaborationGroup collabGroupObj = TestHelper.createCollaborationGroup('ExternalSearchSiteTest_Grp1', 'Public');
        Simpplr_Site__c siteObj = TestHelper.getSiteRecordWithName('ExternalSearchSiteTest_Grp1');
        People__c people = [SELECT Id FROM People__c Limit 1];
        Site_Role__c siteRole = TestHelper.createSiteRole(people.Id, siteObj.Id);      
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForSiteRole(siteRole.Id);
        system.assertEquals(false, resp.is_member, 'Running as expected'); 
        Test.stopTest();
    }

    @isTest static void testGetSearchDataWrapForSiteMembershipReq() {
        Test.startTest();
        Site_Membership_Request__c siteMemberReq = new Site_Membership_Request__c();
        insert siteMemberReq;
        ExternalSearchWrapper.SiteMembershipRequest resp = new ExternalSearchWrapper.SiteMembershipRequest();
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapForSiteMembershipReq(siteMemberReq.Id);
        system.assertEquals(null, resp.status, 'Running as expected'); 
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapForNewsletter() {
        Test.startTest();
        ExternalSearchWrapper.Newsletter resp = new ExternalSearchWrapper.Newsletter();
        Mailer__c mailerReq = [Select id, name__c from Mailer__c where Subject__c = 'ExternaltestnewLetter'];
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapForNewsletter(mailerReq.Id);
        system.assertEquals('Newsletter test', resp.name, 'Running as expected'); 
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForPeopleCategory() {
        Test.startTest();
        ExternalSearchWrapper.CategoryWrapper resp = new ExternalSearchWrapper.CategoryWrapper();
        People_Category__c peopleCategoryObj = new People_Category__c();
        peopleCategoryObj.Name__c = 'TestPeopleCategory';
        insert peopleCategoryObj;   
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForPeopleCategory(peopleCategoryObj.Id);
        system.assertEquals('TestPeopleCategory', resp.name, 'Running as expected'); 
        Test.stopTest();
    }
    
    @isTest static void testConvertContentDocumentListToSearchDataWrapperList() {
        Test.startTest();
        List<ExternalSearchWrapper.SearchDataWrapper> resp = new List<ExternalSearchWrapper.SearchDataWrapper>();
        ContentVersion contentVersionObj = TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
        List<ExternalSearchWrapper.ChatterGroupId> chatterGroupIdList = new List<ExternalSearchWrapper.ChatterGroupId>();
        ExternalSearchWrapper.ChatterGroupId chatterGroupIdObj = new ExternalSearchWrapper.ChatterGroupId();
        chatterGroupIdObj.id = 'testId';
        chatterGroupIdOBj.site_type = 'testSiteType';
        chatterGroupIdList.add(chatterGroupIdObj);       
        List<ContentDocument> contentDocumentList = [Select Id, LatestPublishedVersion.FileType, LatestPublishedVersion.title, LatestPublishedVersion.description, LatestPublishedVersion.ContentSize, LatestPublishedVersionId, LatestPublishedVersion.Origin, LatestPublishedVersion.OwnerId, LatestPublishedVersion.Owner.name, LatestPublishedVersion.ContentModifiedDate, isArchived, LatestPublishedVersion.FileExtension, createdDate From ContentDocument Limit 1];
        Map<String, List<ExternalSearchWrapper.ChatterGroupId>> mapOfChatterGroupId = new Map<String, List<ExternalSearchWrapper.ChatterGroupId>>();
        String contentDocId = contentDocumentList[0].id;
        mapOfChatterGroupId.put(contentDocId,chatterGroupIdList);        
        PushDataHelperForExternalSearch obj = new PushDataHelperForExternalSearch();
        resp = obj.convertContentDocumentListToSearchDataWrapperList(contentDocumentList, mapOfChatterGroupId);
        system.assertEquals(1, resp.size(), 'Running as expected'); 
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForSiteCategory() {
        Test.startTest();
        ExternalSearchWrapper.CategoryWrapper resp = new ExternalSearchWrapper.CategoryWrapper();
        Site_Category__c siteCategoryObj = TestHelper.createSiteCategory();    
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForSiteCategory(siteCategoryObj.Id);      
        System.assertEquals('SiteCatName', resp.name, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForPageCategory() {
        Test.startTest();
        ExternalSearchWrapper.CategoryWrapper resp = new ExternalSearchWrapper.CategoryWrapper();
        Pages_Category__c pagesCategoryObj = new Pages_Category__c();
        pagesCategoryObj.Name__c = 'TestPageCategory';
        insert pagesCategoryObj; 
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForPagesCategory(pagesCategoryObj.Id);
        System.assertEquals('TestPageCategory', resp.name, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testGetSearchDataWrapperForLinks() {
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchContents',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','Links');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Links","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'External search failed');
        Test.stopTest();
    }
    
    @isTest static void testConvertSiteListToSearchDataWrapperList() {
        Test.startTest();
        List<ExternalSearchWrapper.SearchDataWrapper> resp = new List<ExternalSearchWrapper.SearchDataWrapper>();
        CollaborationGroup collabGroupObj = TestHelper.createCollaborationGroup('ExternalSearchSiteTest_Grp1', 'Public');
        List<Simpplr_Site__c> siteList = [Select Id, Chatter_Group_Id__c, name, Is_Active__c, Is_Featured__c, Show_In_Simpplr__c, Site_Type__c, Is_Alert_Enabled__c,  
                                        Site_category__r.name__c, Site_category__c, Has_Albums__c, Has_Events__c, Has_Pages__c, Is_Newsletter_Allowed__c,  Question_Answer_Enabled__c,
                                        Landing_Page__c, Title_Content_Document__c, Title_Content_Version__c, CreatedDate, LastModifiedDate, Is_Onboarding_Enabled__c From Simpplr_Site__c Limit 1];
        String chatterGroupId = siteList[0].Id;
        Map<String,CollaborationGroup> groupmap = new Map<String,CollaborationGroup>();
        groupMap.put(chatterGroupId, collabGroupObj);        
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.convertSiteListToSearchDataWrapperList(siteList, groupmap);  
        System.assertEquals(1, resp.size(), 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForTilesConfig() {
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchContents',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','Tiles');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Tiles","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'External search failed');
        Test.stopTest();
    }
    
    @isTest static void testGetSearchDataWrapperForQuestions() {
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchQuestions',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','Question');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Question","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'External search success');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequest() {
        Test.startTest();
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','');
        esObj.handleRequest();
        system.assertEquals('error', esObj.response.status, 'Running as expected');
        
        pgRef.getParameters().put('action','unknownAction');
        esObj.handleRequest();
        system.assertEquals('error', esObj.response.status, 'Running as expected');
        
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','CrmFile');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Top","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testhandleRequest1() { 
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchContents',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','Content');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Top","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testhandleRequest2() { 
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchSites',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','Site');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Top","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testhandleRequest3() {       
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchFiles',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','File');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Top","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    
    @isTest static void testhandleRequest4() {   
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'externalSearchAutoComplete',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalAutoComplete');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"Top","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    private static Simpplr_Site__c getSimpplrSite(string siteName){
        return([select id, chatter_group_id__c,File_Storage_Source__c from Simpplr_Site__c where name = :siteName]);
    }
    
    @isTest
    static void searchGoogleDriveFilesSharedDriveTest() {
        Simpplr_Site__c eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'googledrive';
        update eSite;
        Folder__c folder = TestHelper.createChatterFolder('Test Folder 12345', null, eSite.id, 'googledrive', 'googledrive', null);
        folder.Drive_Type__c = 'shareddrive';
        folder.Is_System_Folder__c = false;
        folder.External_Folder_Id__c = '12345';
        update folder;         
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pageRef);  
        ExternalSearchDataServer dSObj= new ExternalSearchDataServer();
        pageRef.getParameters().put('action','externalSearch');
        pageRef.getParameters().put('searchForType','GoogleDriveFile');
        pageRef.getParameters().put('data','{"term" : "simpplr", "siteId" : "'+eSite.id+'", "driveType" : "shareddrive", "section" : "GoogleDriveFile"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'FileDataServer/searchGoogleDrive',false));		
        dSObj.handleRequest();
        ResponseWrapper response  = dSObj.response;   
        ExternalSearchWrapper.TopContentsWrapper result = (ExternalSearchWrapper.TopContentsWrapper) response.result;                 
        System.assertEquals('success', response.status, 'Failed - Status should have been success');
        System.assertEquals('Test Folder 12345', result.shareddriveName, 'Failed - folder name is incorrect');            
    }

    @isTest
    static void searchGoogleDriveFilesMyDriveTest() {
        Simpplr_Site__c eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'googledrive';
        update eSite;        
        Folder__c folder = TestHelper.createChatterFolder('Test Folder 12346', null, eSite.id, 'googledrive', 'googledrive', null);
        folder.Drive_Type__c = 'mydrive';
        folder.Is_System_Folder__c = false;
        folder.External_Folder_Id__c = '12346';
        update folder;   
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pageRef);  
        ExternalSearchDataServer dSObj= new ExternalSearchDataServer();
        pageRef.getParameters().put('action','externalSearch');
        pageRef.getParameters().put('searchForType','GoogleDriveFile');
        pageRef.getParameters().put('data','{"term" : "simpplr", "siteId" : "'+eSite.id+'", "driveType" : "mydrive", "section" : "GoogleDriveFile"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'FileDataServer/searchGoogleDrive',false));		
        dSObj.handleRequest();
        ResponseWrapper response  = dSObj.response;   
        ExternalSearchWrapper.TopContentsWrapper result = (ExternalSearchWrapper.TopContentsWrapper) response.result;                 
        System.assertEquals('success', response.status, 'Failed - status should have been success');
        System.assertEquals(true, result.isMyDriveFolderLinked, 'Failed - isMyDriveFolderLinked should have been true');
        Test.stopTest();    
    }
    
    @isTest static void testhandleRequestContentOnboarding() { 
        Test.startTest(); 
        ExternalSearchDataServer esObj = new ExternalSearchDataServer();
        esObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchContents',true));
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ExternalSearchDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action','externalSearch');
        pgRef.getParameters().put('searchForType','ContentOnboarding');
        pgRef.getParameters().put('data','{"term":"Test","size":16,"section":"ContentOnboarding","isCorrectionEnabled":true}');
        esObj.handleRequest();
        system.assertEquals('success', esObj.response.status, 'External search failed');
        Test.stopTest();
    }

    @isTest static void testSearchDataWrapperContentTemplate() {
        Test.startTest();
        
        TestHelper.createCollaborationGroup('ExternalSearchSiteTest_Grp1', 'Public');
        Simpplr_Site__c siteObj = TestHelper.getSiteRecordWithName('ExternalSearchSiteTest_Grp1');
        ExternalSearchWrapper.SearchDataWrapper resp = new ExternalSearchWrapper.SearchDataWrapper();

        People__c peopleObj = [SELECT Id FROM People__c LIMIT 1];
        Content_Template__c templateObj = TestHelper.createContentTemplate('template_test_1', 'Page', 'Page', siteObj.Id, null, peopleObj.Id, false);

        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        resp = pushDataHelperObj.getSearchDataWrapperForContentTemplate(templateObj.Id);
        system.assertEquals('template_test_1', resp.name, 'Running as expected');
        
        Test.stopTest();
    }

    @isTest static void testSearchDataWrapperForMustReadContentConfig() {
        Test.startTest();

        List<Must_Read_Audit__c> mustReadAuditList = [Select id From Must_Read_Audit__c Where Content__r.Title__c = 'ExternaltestBlogPostRecord' LIMIT 1];
        string mustReadAuditId= mustReadAuditList.size() > 0 ? mustReadAuditList[0].id : null;
        PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
        ExternalSearchWrapper.MustReadAudit mustReadAuditResp = pushDataHelperObj.getSearchDataWrapperForMustReadContentConfig(mustReadAuditId);       

        List<Must_Read_Confirm_History__c> mustReadConfirmHistoryList = [Select id From Must_Read_Confirm_History__c Where Must_Read_Audit__c =: mustReadAuditId LIMIT 1];
        string mustReadconfirmHistoryId = mustReadConfirmHistoryList.size() > 0 ? mustReadConfirmHistoryList[0].id : null;
        ExternalSearchWrapper.MustReadConfirmHistory mustReadConfirmHistoryResp = pushDataHelperObj.getSearchDataWrapperForMustReadConfirmHistoryConfig(mustReadconfirmHistoryId);
        
        Test.stopTest();
        system.assertEquals('Must_Read', mustReadAuditResp.object_type, 'Running as expected');
        system.assertEquals('Must_Read_Confirm_History', mustReadConfirmHistoryResp.object_type, 'Running as expected'); 
    }

}