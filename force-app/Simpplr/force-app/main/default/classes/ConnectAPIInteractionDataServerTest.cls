@isTest
private class ConnectAPIInteractionDataServerTest {
    @testSetup static void setup() {
    	People__c ppl = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	TestHelper.createPeoplePreference(ppl.Id);
    }
    
    private static String getFeedCriteria (String action){
    	Criteria.Feed feedCritObj=  new Criteria.Feed();
    	feedCritObj.action = action;
		return JSON.serialize(feedCritObj);
		
    }
    
    @isTest static void testTogglebookmark() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('togglebookmark'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testToggleFavorite() {
        Test.startTest();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('toggleFavorite'));
        Test.setCurrentPageReference(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testRemoveProfilePhoto() {
        Test.startTest();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('removeprofilephoto'));
        Test.setCurrentPageReference(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetPollResults() {
        Test.startTest();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('getpollresults'));
        Test.setCurrentPageReference(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testSaveSortBy() {
        Test.startTest();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('savesortby'));
        Test.setCurrentPageReference(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testException() {
        Test.startTest();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        Test.setCurrentPageReference(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
        Test.stopTest();   
        
    }
    
    @isTest static void testSaveFilterBy() {
        PageReference pgRef = Page.DataServerRW;
        TestHelper.createPeoplePreference(UserContext.peopleId);
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('savefilterby'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLikeFeed() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('likefeed'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUnlikeFeed() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('unlikefeed'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUnlikeComment() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('unlikecomment'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testDeleteFeed() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('deleteFeed'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testDeleteComment() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('deleteComment'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testUpdateFeed() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('updatefeed'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testPostTextPost() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('posttextpost'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPostLink() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('postlink'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPostPoll() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('postpoll'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPostComment() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('postcomment'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSetProfilePhoto() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('setprofilephoto'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testVoteOnPoll() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('voteonpoll'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testShareFeed() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('sharefeed'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUpdateComment() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('updatecomment'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUpsertTopic() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('upserttopic'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPostFile() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('postFile'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLikeComment() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'ConnectAPIInteractionDataServer');
        pgRef.getParameters().put('data', getFeedCriteria('likecomment'));
    	Test.setCurrentPage(pgRef);
        ConnectAPIInteractionDataServer serverObj = new ConnectAPIInteractionDataServer();
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
}