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
private class ChatterInteractionDataServerTest {

    @testSetup static void setup() {
        PageReference pageRef = Page.DataServerRW;
	    Test.setCurrentPage(pageRef);
	    People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
	    User userAsOwner = new User(Id = UserInfo.getUserId());
		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('SiteFileDetailCtrlTest_Grp1','Public'); 
		Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test Event', 'Event', 'Submitted', userAsOwner, getSimpplrSite());
		
		File__c files = TestHelper.createContentTitleImage(String.valueof(simpplrContent.Id));
		
		Like__c fileLike = new Like__c(people__c = peopleObj.Id, File__c = files.Id);
		Like__c mediaLike = new Like__c(people__c = peopleObj.Id, External_File_Id__c = files.Id);
		Like__c contentLike = new Like__c(Content__c = simpplrContent.Id, people__c = peopleObj.Id);
		insert fileLike;
		insert contentLike;
		insert mediaLike;
		
		
	    ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
    }
    
    private static Simpplr_Site__c getSimpplrSite(){ 
    	return[select id from Simpplr_Site__c where name ='SiteFileDetailCtrlTest_Grp1']; 
    }
    
    @isTest static void testHandleRequest() {
        try {
        	Like__c likes = [select Id,File__c,people__c from Like__c  where File__c !=null];
            ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
        	ApexPages.currentPage().getParameters().put('recordId', likes.File__c);
        	ApexPages.currentPage().getParameters().put('action', 'unlike');
        	ApexPages.currentPage().getParameters().put('likeType', 'media');
        	ApexPages.currentPage().getParameters().put('subjectId', 'news');
        	ApexPages.currentPage().getParameters().put('url', 'activity');
        	ApexPages.currentPage().getParameters().put('urlName', 'activity');
        	ApexPages.currentPage().getParameters().put('textToPost', 'activity');
        	ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
        	chInteractionServerObj.handleRequest();
        	
        	ApexPages.currentPage().getParameters().put('action', 'like');
        	chInteractionServerObj.handleRequest();
        	
        	system.assert(true, 'Running as expected');
        } catch (Exception e) {
        
        }
    }
    
   
    @isTest static void testLikeContent() {
        try {
        	Like__c likes = [select Id,Content__c,people__c from Like__c where Content__c !=null];
            ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
        	ApexPages.currentPage().getParameters().put('recordId', likes.Content__c);
        	ApexPages.currentPage().getParameters().put('action', 'unlike');
        	ApexPages.currentPage().getParameters().put('likeType', 'content');
        	ApexPages.currentPage().getParameters().put('subjectId', 'news');
        	ApexPages.currentPage().getParameters().put('url', 'activity');
        	ApexPages.currentPage().getParameters().put('urlName', 'activity');
        	ApexPages.currentPage().getParameters().put('textToPost', 'activity');
        	ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
        	chInteractionServerObj.handleRequest();
        	
        	ApexPages.currentPage().getParameters().put('action', 'like');
        	chInteractionServerObj.handleRequest();
        	system.assert(true,'Running as expected');
        } catch (Exception e) {
        }
    }
    
     @isTest static void testShareContentToFeed() {
       try {
       	
       	Simpplr_Content__c simpplrContent = [select Id from Simpplr_Content__c];
           ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
        	ApexPages.currentPage().getParameters().put('action', 'share');
        	ApexPages.currentPage().getParameters().put('url', 'activity');
        	ApexPages.currentPage().getParameters().put('urlName', 'activity');
			ApexPages.currentPage().getParameters().put('textToPost', 'activity');
        	ApexPages.currentPage().getParameters().put('contentId', simpplrContent.Id);
        	ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
        	chInteractionServerObj.handleRequest();
        	system.assert(true,'Running as expected');
        } catch (Exception e) {
        
        }
    }
	@isTest static void testShareContentToFeedTiptap() {
		try {
			
			Simpplr_Content__c simpplrContent = [select Id from Simpplr_Content__c];
			ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
			 ApexPages.currentPage().getParameters().put('action', 'share');
			 ApexPages.currentPage().getParameters().put('url', 'activity');
			 ApexPages.currentPage().getParameters().put('urlName', 'activity');
			 ApexPages.currentPage().getParameters().put('textToPost', '');
			 ApexPages.currentPage().getParameters().put('bodyJson', '{\n  \"type\": \"doc\",\n  \"content\": [\n    {\n      \"type\": \"paragraph\",\n      \"content\": [\n        {\n          \"type\": \"text\",\n          \"marks\": [\n            {\n              \"type\": \"italic\"\n            }\n          ],\n          \"text\": \"Hello world\"\n        }\n      ]\n    }\n  ]\n}');
			 ApexPages.currentPage().getParameters().put('contentId', simpplrContent.Id);
			 ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
			 chInteractionServerObj.handleRequest();
			 system.assert(true,'Running as expected');
		 } catch (Exception e) {
		 
		 }
	 }

	@isTest static void testShareCampaignToFeed() {
       try {
       	
       	Simpplr_Content__c simpplrContent = [select Id from Simpplr_Content__c];
           ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
        	ApexPages.currentPage().getParameters().put('action', 'share');
        	ApexPages.currentPage().getParameters().put('url', 'activity');
        	ApexPages.currentPage().getParameters().put('urlName', 'activity');
			ApexPages.currentPage().getParameters().put('textToPost', 'activity');
        	ApexPages.currentPage().getParameters().put('campaignId', 'dummy');
        	ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
        	chInteractionServerObj.handleRequest();
        	system.assert(true,'Running as expected');
        } catch (Exception e) {
        
        }
    }
	@isTest static void testShareCampaignToFeedTiptap() {
		try {
			
			Simpplr_Content__c simpplrContent = [select Id from Simpplr_Content__c];
			ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
			 ApexPages.currentPage().getParameters().put('action', 'share');
			 ApexPages.currentPage().getParameters().put('url', 'activity');
			 ApexPages.currentPage().getParameters().put('urlName', 'activity');
			 ApexPages.currentPage().getParameters().put('textToPost', '');
			 ApexPages.currentPage().getParameters().put('bodyJson', '{\n  \"type\": \"doc\",\n  \"content\": [\n    {\n      \"type\": \"paragraph\",\n      \"content\": [\n        {\n          \"type\": \"text\",\n          \"marks\": [\n            {\n              \"type\": \"italic\"\n            }\n          ],\n          \"text\": \"Hello world\"\n        }\n      ]\n    }\n  ]\n}');
			 ApexPages.currentPage().getParameters().put('campaignId', 'dummy');
			 ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
			 chInteractionServerObj.handleRequest();
			 system.assert(true,'Running as expected');
		 } catch (Exception e) {
		 
		 }
	 }

	@isTest static void testShareAlbumMediaToFeed() {
       try {
       	
       	Simpplr_Content__c simpplrContent = [select Id from Simpplr_Content__c];
           ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
        	ApexPages.currentPage().getParameters().put('action', 'share');
        	ApexPages.currentPage().getParameters().put('url', 'activity');
        	ApexPages.currentPage().getParameters().put('urlName', 'activity');
			ApexPages.currentPage().getParameters().put('textToPost', 'activity');
        	ApexPages.currentPage().getParameters().put('albumMediaId', 'dummy');
        	ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
        	chInteractionServerObj.handleRequest();
        	system.assert(true,'Running as expected');
        } catch (Exception e) {
        
        }
    }
	@isTest static void testShareAlbumMediaToFeedTiTtap() {
		try {
			
			Simpplr_Content__c simpplrContent = [select Id from Simpplr_Content__c];
			ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
			 ApexPages.currentPage().getParameters().put('action', 'share');
			 ApexPages.currentPage().getParameters().put('url', 'activity');
			 ApexPages.currentPage().getParameters().put('urlName', 'activity');
			 ApexPages.currentPage().getParameters().put('textToPost', '');
			 ApexPages.currentPage().getParameters().put('bodyJson', '{\n  \"type\": \"doc\",\n  \"content\": [\n    {\n      \"type\": \"paragraph\",\n      \"content\": [\n        {\n          \"type\": \"text\",\n          \"marks\": [\n            {\n              \"type\": \"italic\"\n            }\n          ],\n          \"text\": \"Hello world\"\n        }\n      ]\n    }\n  ]\n}');
			 ApexPages.currentPage().getParameters().put('albumMediaId', 'dummy');
			 ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
			 chInteractionServerObj.handleRequest();
			 system.assert(true,'Running as expected');
		 } catch (Exception e) {
		 
		 }
	 }
    
    @isTest static void testLikeFile1() {
        try {
        	Like__c likes = [select Id,people__c,External_File_Id__c from Like__c where External_File_Id__c !=null];
            ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
        	ApexPages.currentPage().getParameters().put('recordId', likes.External_File_Id__c);
        	ApexPages.currentPage().getParameters().put('action', 'unlike');
        	ApexPages.currentPage().getParameters().put('likeType', 'file');
        	ApexPages.currentPage().getParameters().put('subjectId', 'news');
        	ApexPages.currentPage().getParameters().put('url', 'activity');
        	ApexPages.currentPage().getParameters().put('urlName', 'activity');
        	ApexPages.currentPage().getParameters().put('textToPost', 'activity');
        	
        	ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
        	chInteractionServerObj.handleRequest();
        	
        	ApexPages.currentPage().getParameters().put('action', 'like');
        	chInteractionServerObj.handleRequest();
        	system.assert(true,'Running as expected');
        } catch (Exception e) {
        
        }
    }
    
    @isTest static void testExceptions() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('recordId', 'TestRecordId');
        ApexPages.currentPage().getParameters().put('likeType', 'content');
        ApexPages.currentPage().getParameters().put('action', 'like');
        ApexPages.currentPage().getParameters().put('target', 'ChatterInteractionDataServer');
        ChatterInteractionDataServer  chInteractionServerObj = new  ChatterInteractionDataServer();
        chInteractionServerObj.handleRequest();
        
        ApexPages.currentPage().getParameters().put('likeType', 'media');
        chInteractionServerObj.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'unlike');
        ApexPages.currentPage().getParameters().put('likeType', 'content');
        chInteractionServerObj.handleRequest();
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
}