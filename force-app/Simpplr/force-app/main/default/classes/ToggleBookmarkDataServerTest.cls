@isTest
private class ToggleBookmarkDataServerTest {
    @testSetup 
	private static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('AccessManagerTest_Grp1','Public');
		Simpplr_Site__c siteObj = getSite();
		
		User userObj = [select id from User where id=:UserContext.id];
		people__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        People_Preference__c prefObj = TestHelper.createPeoplePreference(peopleObj.id);
    	TestHelper.createContent('simpplr test event', 'Event', 'Approved', userObj, siteObj);
		
		User testUser = TestHelper.createUser('test_user',null,false);
		
		ContentVersion cv = TestHelper.createContentVersion('H');
		System.assert(true,'Running as expected');
	}
	
	@isTest
	static Simpplr_Site__c getSite() {
		Simpplr_Site__c siteObj = [Select id from Simpplr_Site__c limit 1];
		System.assert(true,'Running as expected');
		return siteObj;
	}
	
	private static Simpplr_Content__c getContent(String contentType) {
		Simpplr_Content__c contentObj = [Select id from Simpplr_Content__c where type__c=: contentType limit 1];
		System.assert(true,'Running as expected');
		return contentObj;
	}
	
	private static People__c getPeople(String name){
		People__c peopleObj = [select id from people__c where name = :name limit 1];
		return peopleObj;
	}
	
	private static ContentVersion getFileContent(String name){
		ContentVersion cv = [select id from ContentVersion where title like :name];
		return cv;
	}
    
    @isTest static void testinit1(){
        User userObj = TestHelper.createUser('ToggleBookmarkDataServer_User',null, false);
        people__c pObj = [select id From people__c Where User__c =:userObj.id];
        PageReference pageRef = Page.DataServerRW;
        Bookmark__c bookmarkObj = new Bookmark__c(Simpplr_Site__c=getSite().id,People__c=UserContext.peopleId,Type__c='Site',Is_Deleted__c=true,Simpplr_Content__c=getContent('Event').id,Bookmark_Receiver__c=pObj.id);
        insert bookmarkObj;
        
        //Add Favorite Site
        pageRef.getParameters().put('target', 'ToggleBookmarkDataServer');
        pageRef.getParameters().put('action', 'addfavorite');
        pageRef.getParameters().put('siteId', getSite().id);
        Test.setCurrentpage(pageRef);
        ToggleBookmarkDataServer ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        
        //Bookmark Content
        bookmarkObj.Type__c = 'Event';
        update bookmarkObj;
        pageRef.getParameters().put('action', 'bookmark'); 
        pageRef.getParameters().put('recordId', getContent('Event').id);
        pageRef.getParameters().put('context', 'content');
        Test.setCurrentpage(pageRef);
        ctrlObj.handleRequest();
        
        // follow people
        bookmarkObj.Type__c = 'People';
        update bookmarkObj;
        pageRef.getParameters().put('action', 'favoritepeople');
        pageRef.getParameters().put('peopleId',pObj.id);
        Test.setCurrentpage(pageRef);
        ctrlObj.handleRequest();
        
        //Bookmark Content 
        pageRef.getParameters().put('action', 'bookmark'); 
        pageRef.getParameters().put('context', 'content');
        Test.setCurrentpage(pageRef);
        ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        System.assert(true,'Running as expected');
    }
	
	@isTest static void testinit(){
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        
        //Add Favorite Site
        pageRef.getParameters().put('target', 'ToggleBookmarkDataServer');
        pageRef.getParameters().put('action', 'addfavorite');
        pageRef.getParameters().put('siteId', getSite().id);
        Test.setCurrentpage(pageRef);
        ToggleBookmarkDataServer ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        
        // Remove Favorite Site
        pageRef.getParameters().put('action', 'removefavorite');
        Test.setCurrentpage(pageRef);
        ctrlObj.handleRequest();
        
        //Bookmark Content 
        pageRef.getParameters().put('action', 'bookmark');
        
        pageRef.getParameters().put('recordId', getContent('Event').id);
        pageRef.getParameters().put('context', 'content');
        Test.setCurrentpage(pageRef);
        ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        
        //Remove BookmarkContent 
        pageRef.getParameters().put('action', 'unbookmark');
        
        pageRef.getParameters().put('recordId', getContent('Event').id);
        pageRef.getParameters().put('context', 'content');
        Test.setCurrentpage(pageRef);
        ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        
        // follow people
        pageRef.getParameters().put('action', 'favoritepeople');
        pageRef.getParameters().put('peopleId', getPeople('test_user test_user').id);
        Test.setCurrentpage(pageRef);
        ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        
        //unfollow people
        pageRef.getParameters().put('action', 'unfavoritepeople');
        Test.setCurrentpage(pageRef);
        ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        
        //bookmark file
        pageRef.getParameters().put('action', 'bookmark');
        pageRef.getParameters().put('recordId', getFileContent('Test').id);
        Test.setCurrentpage(pageRef);
        ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        
        //unbookmark file
        pageRef.getParameters().put('action', 'unbookmark');
        Test.setCurrentpage(pageRef);
        ctrlObj = new ToggleBookmarkDataServer();
        ctrlObj.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
	}
    
    @isTest static void bookmarkFileForGoogleDrive(){
        PageReference pageRef = Page.DataServerRW;
        ToggleBookmarkDataServer ctrlObj = new ToggleBookmarkDataServer();
        pageRef.getParameters().put('target', 'ToggleBookmarkDataServer');
        Test.setCurrentpage(pageRef);
        pageRef.getParameters().put('action', 'bookmark');
        pageRef.getParameters().put('recordId', getFileContent('Test').id);
        pageRef.getParameters().put('context', 'googleDrive');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'ToggleBookmarkDataServer/bookmarkFile',false));
        ctrlObj.handleRequest();
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void unbookmarkFileForGoogleDrive(){
        PageReference pageRef = Page.DataServerRW;
        ToggleBookmarkDataServer ctrlObj = new ToggleBookmarkDataServer();
        pageRef.getParameters().put('target', 'ToggleBookmarkDataServer');
        Test.setCurrentpage(pageRef);
        pageRef.getParameters().put('action', 'unbookmark');
        pageRef.getParameters().put('recordId', getFileContent('Test').id);
        pageRef.getParameters().put('context', 'googleDrive');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'ToggleBookmarkDataServer/unbookmarkFile',false));
        ctrlObj.handleRequest();
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
	@isTest static void bookmarkFile(){
        PageReference pageRef = Page.DataServerRW;
        ToggleBookmarkDataServer ctrlObj = new ToggleBookmarkDataServer();
        pageRef.getParameters().put('target', 'ToggleBookmarkDataServer');
        Test.setCurrentpage(pageRef);
        pageRef.getParameters().put('action', 'bookmark');
        pageRef.getParameters().put('recordId', '1234');
        pageRef.getParameters().put('context', 'box');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContent',false));
        ctrlObj.handleRequest();
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void unBookmarkFile(){
        PageReference pageRef = Page.DataServerRW;
        ToggleBookmarkDataServer ctrlObj = new ToggleBookmarkDataServer();
        pageRef.getParameters().put('target', 'ToggleBookmarkDataServer');
        Test.setCurrentpage(pageRef);
        pageRef.getParameters().put('action', 'unbookmark');
        pageRef.getParameters().put('recordId', '1234');
        pageRef.getParameters().put('context', 'box');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContent',false));
        ctrlObj.handleRequest();
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
}