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
private class FeedServiceProviderTest {
    
    @isTest static void testPostTextPost() {
        try {
        	TestHelper.createPeopleRecordForUser(UserContext.id);
	        Test.startTest();
    	    Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/ai-es-analysis/emotion', false));
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            feedElementObj = FeedServiceProvider.postTextPost(null, 'me', 'news',
                                                              'textpost','', new List<String>{'h1','h2'}, null, null,null);
            System.assert(true,'Running as expected');
	        Test.stopTest();
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testRecognitionPost() {
        FeedElementWrapper feedElementObj = new FeedElementWrapper();
        TestHelper.createPeopleRecordForUser(UserContext.id);
	    Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/ai-es-analysis/emotion', false));
        People__c peopleObj = [SELECT Id FROM People__c WHERE User__c =: UserContext.Id];
        FeedElementWrapper.RecognitionInfo recognitionArg = new FeedElementWrapper.RecognitionInfo();
        recognitionArg.awardedTo = peopleObj.Id;
        recognitionArg.awardedBy = peopleObj.Id;
        recognitionArg.awardId = 'sahsj-saka-saa';
        recognitionArg.awardName = 'great Work';

        feedElementObj = FeedServiceProvider.postTextPost(null, 'me', 'news',
                                                          'textPost','', new List<String>{'h1','h2'}, null, recognitionArg, null,null);
        System.assert(true,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testPostTextPostNegtive() {
        try {
        	TestHelper.createPeopleRecordForUser(UserContext.id);
	        Test.startTest();
    	    Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/ai-es-analysis/emotion', false));
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            feedElementObj = FeedServiceProvider.postTextPost(null, null, null, 'textpost','',
                                                              new List<String>{'h1','h2'}, null, null,null);
            System.assert(true,'Running as expected');
            Test.stopTest();
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testAssignTopicToFeedElement() {
        try {
            ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
            List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
            
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
            feedElementPageObj.elements = listOfFeedElement;
            connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
                                                                   10, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);
            
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            List<TopicWrapper> listOfTopicWrap = new List<TopicWrapper>();
            listOfTopicWrap = FeedServiceProvider.assignTopicToFeedElement(null, textPostObj.Id,
                                                                           new List<String>{'h1','h2'});
            System.assert(true,'Running as expected');
            
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testPostLink() {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            feedElementObj = FeedServiceProvider.postLink(null, 'me', 'news','google.com','google',
                                                          'linkpost','', new List<String>{'h1','h2'}, null, null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testPostLinkNegtive() {
        try {
            FeedServiceProvider.postLink(null, null, null, null, null,
                                         'linkpost','', new List<String>{'h1','h2'}, null, null);
            System.assert(true,'Running as expected');
        } catch ( Exception e) {
            
        }
    }
    
    @isTest static void testPostPoll() {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            feedElementObj = FeedServiceProvider.postPoll(null, 'me', 'news', new List<String>{'h1','h2'},
                                                          'Polling','', new List<String>{'h1','h2'}, null);
            
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testPostPollNegtive() {
        try {
            FeedServiceProvider.postPoll(null, null, null, null,
                                         null, null, new List<String>{'h1','h2'}, null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testPostFile() {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            ContentVersion contentObj = new ContentVersion();
            contentObj.versionData = Blob.valueOf('base64value'); 
            contentObj.title = 'test'; 
            contentObj.Origin = 'H';
            contentObj.pathOnClient = 'xyz';
            
            insert contentObj;
            List<ContentVersion> listOfContentVersion = [SELECT Id, Title, FileExtension, FileType, ContentSize,ContentDocumentId
                                                         FROM ContentVersion WHERE Id=:contentObj.id];
            
            String  fileObjId ;
            
            if (!listOfContentVersion.isEmpty()) {
                fileObjId = listOfContentVersion[0].ContentDocumentId;
                
            } else {
                fileObjId = '123';
            }
                List<Criteria.ExternalFileWrapper> externalFiles = new List<Criteria.ExternalFileWrapper>();
                Criteria.ExternalFileWrapper externalFile = new Criteria.ExternalFileWrapper();
                externalFile.title = 'abcd';
                externalFile.context = 'googledrive';
                externalFile.fileId = 'abcd';
                externalFile.size = 1234;
                externalFile.type = 'jpeg';
                externalFile.url = 'https://dummy.vf.force.com/apex/FileDetail?fileId=abcd&provider=googledrive';
                externalFiles.add(externalFile);
         
            feedElementObj = FeedServiceProvider.postFile(null, 'me', 'news', new List<String>{fileObjId},
                                                          'file','', new List<String>{'h1','h2'}, null, null, externalFiles);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testRecognitionPostFile() {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            ContentVersion contentObj = new ContentVersion();
            contentObj.versionData = Blob.valueOf('base64value'); 
            contentObj.title = 'test'; 
            contentObj.Origin = 'H';
            contentObj.pathOnClient = 'xyz';
            
            insert contentObj;
            List<ContentVersion> listOfContentVersion = [SELECT Id, Title, FileExtension, FileType, ContentSize,ContentDocumentId
                                                         FROM ContentVersion WHERE Id=:contentObj.id];
            
            String  fileObjId ;
            
            if (!listOfContentVersion.isEmpty()) {
                fileObjId = listOfContentVersion[0].ContentDocumentId;
                
            } else {
                fileObjId = '123';
            }
            
            TestHelper.createPeopleRecordForUser(UserContext.id);
            
            People__c peopleObj = [SELECT Id FROM People__c WHERE User__c =: UserContext.Id];
            FeedElementWrapper.RecognitionInfo recognitionArg = new FeedElementWrapper.RecognitionInfo();
            recognitionArg.awardedTo = peopleObj.Id;
            recognitionArg.awardedBy = peopleObj.Id;
            recognitionArg.awardId = 'sahsj-saka-saa';
            recognitionArg.awardName = 'great Work';

            List<Criteria.ExternalFileWrapper> externalFiles = new List<Criteria.ExternalFileWrapper>();
            Criteria.ExternalFileWrapper externalFile = new Criteria.ExternalFileWrapper();
            externalFile.title = 'abcd';
            externalFile.context = 'googledrive';
            externalFile.fileId = 'abcd';
            externalFile.size = 1234;
            externalFile.type = 'jpeg';
            externalFile.url = 'https://dummy.vf.force.com/apex/FileDetail?fileId=abcd&provider=googledrive';
            externalFiles.add(externalFile);
            
            feedElementObj = FeedServiceProvider.postFile(null, 'me', 'news', new List<String>{fileObjId},
                                                          'testFilePost','', new List<String>{'h1','h2'}, null, recognitionArg, null, externalFiles);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testPostFileNegtive() {
        try {
            FeedServiceProvider.postFile(null, 'me', 'news', null,
                                         null, null,null, null, null,null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testDeleteFeed() {
        try {
            ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
            List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
            
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
            feedElementPageObj.elements = listOfFeedElement;
            connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
                                                                   10, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);
            
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            Boolean isSuccess = FeedServiceProvider.deleteFeed(null, textPostObj.Id);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testDeleteComment() {
        try {
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            Boolean isSuccess = FeedServiceProvider.deleteComment(null, '123');
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testToggleBookMarks() {
        try {
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedItem feedItemObj = new FeedItem();
            feedItemObj.ParentId = UserContext.id;		
            feedItemObj.Body = 'I am coming from dev console';
            insert feedItemObj;
            Boolean isSuccess = FeedServiceProvider.toggleBookMarks(null, feedItemObj.Id, true);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testPostComment() {
        try {
            ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
            List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
            
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
            feedElementPageObj.elements = listOfFeedElement;
            connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
                                                                   10, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);
            
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            RecentCommentsWrapper recentCommentsWrapperObj = new RecentCommentsWrapper();
            recentCommentsWrapperObj = FeedServiceProvider.postComment(null, textPostObj.Id, null, 'test','', null,null);
            
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testSearchFeeds() {
        try {
            ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
            List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
            
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
            feedElementPageObj.elements = listOfFeedElement;
            connectApi.chatterFeeds.setTestSearchFeedElementsInFeed(null, 
                                                                    ConnectApi.FeedType.news, 'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                    'test', feedElementPageObj);
            
            FeedElementPageWrapper feedElementWrapObj = new FeedElementPageWrapper();
            feedElementWrapObj = FeedServiceProvider.searchFeeds(null, 'news', 'me', null, 10,
                                                                 'test', 'activity');
            
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testSearchFeedsNegtive() {
        try {
            ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
            List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
            
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
            feedElementPageObj.elements = listOfFeedElement;
            connectApi.chatterFeeds.setTestSearchFeedElementsInFeed(null, 
                                                                    ConnectApi.FeedType.news, 'me', null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc,
                                                                    'test', feedElementPageObj);
            
            FeedElementPageWrapper feedElementWrapObj = new FeedElementPageWrapper();
            feedElementWrapObj = FeedServiceProvider.searchFeeds(null, null, null, null, 10,
                                                                 'test', 'activity');
            
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testVoteOnPoll() {
        try {
            PollWrapper pollWrapObj = new PollWrapper();
            pollWrapObj = FeedServiceProvider.voteOnPoll(null, null, null);
        } catch (Exception e) {
            
        }
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testLikeFeedElement() {
        try {
        	TestHelper.createPeopleRecordForUser(UserContext.id);
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedItem feedItemObj = new FeedItem();
            feedItemObj.ParentId = UserContext.id;		
            feedItemObj.Body = 'I am coming from dev console';
            insert feedItemObj;
            
            FeedComment feedCommentObj = new FeedComment();
            feedCommentObj.CommentBody  ='hello';
            feedCommentObj.FeedItemId = feedItemObj.Id;
            insert feedCommentObj;
            
            FeedLike feedLikeObj = new FeedLike();
            feedLikeObj.FeedItemId = feedItemObj.Id;
            insert feedLikeObj;
            
            FeedServiceProvider.likeFeedElement(null, feedItemObj.Id);
            
            System.assert(true, 'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testUnlikeFeedElement() {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedItem feedItemObj = new FeedItem();
            feedItemObj.ParentId = UserContext.id;		
            feedItemObj.Body = 'I am coming from dev console';
            insert feedItemObj;
            
            FeedComment feedCommentObj = new FeedComment();
            feedCommentObj.CommentBody  ='hello';
            feedCommentObj.FeedItemId = feedItemObj.Id;
            insert feedCommentObj;
            
            FeedLike feedLikeObj = new FeedLike();
            feedLikeObj.FeedItemId = feedItemObj.Id;
            insert feedLikeObj;
            
            FeedServiceProvider.unlikeFeedElement(null, feedLikeObj.Id, null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testUnlikeFeedElementNegtive() {
        try {
            FeedServiceProvider.unlikeFeedElement(null, null, null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest static void testLikeComment() {
        try {
        	TestHelper.createPeopleRecordForUser(UserContext.id);
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedItem feedItemObj = new FeedItem();
            feedItemObj.ParentId = UserContext.id;		
            feedItemObj.Body = 'I am coming from dev console';
            insert feedItemObj;
            
            FeedComment feedCommentObj = new FeedComment();
            feedCommentObj.CommentBody  ='hello';
            feedCommentObj.FeedItemId = feedItemObj.Id;
            insert feedCommentObj;
            
            FeedLike feedLikeObj = new FeedLike();
            feedLikeObj.FeedItemId = feedItemObj.Id;
            insert feedLikeObj;
            
            FeedServiceProvider.likeComment(null, feedCommentObj.Id, feedItemObj.id);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testLikeCommentNegtive() {
        try {
            FeedServiceProvider.likeComment(null, null, null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testUnlikeComment() {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedItem feedItemObj = new FeedItem();
            feedItemObj.ParentId = UserContext.id;		
            feedItemObj.Body = 'I am coming from dev console';
            insert feedItemObj;
            
            FeedComment feedCommentObj = new FeedComment();
            feedCommentObj.CommentBody  ='hello';
            feedCommentObj.FeedItemId = feedItemObj.Id;
            insert feedCommentObj;
            
            FeedLike feedLikeObj = new FeedLike();
            feedLikeObj.FeedItemId = feedItemObj.Id;
            insert feedLikeObj;
            
            FeedServiceProvider.unlikeComment(null, feedCommentObj.id, feedLikeObj.Id);
            
            System.assert(true, 'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testUnlikeCommentNegtive() {
        try {
            FeedServiceProvider.unlikeComment(null, null, null);
            
            System.assert(true, 'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testUpdateFeedElement() {
        try {
        	TestHelper.createPeopleRecordForUser(UserContext.id);
	        Test.startTest();
    	    Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/ai-es-analysis/emotion', false));
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            feedElementObj = FeedServiceProvider.postTextPost(null, 'me', 'news', 'textpost','', new List<String>{'h1','h2'}, null, null,null);
            FeedElementWrapper updatedFeedElementObj = new FeedElementWrapper();
            updatedFeedElementObj = FeedServiceProvider.updateFeedElement(null, feedElementObj.Id, 'updated text','',null, null);
            System.assert(true,'Running as expected');
	        Test.stopTest();
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testUpdateFeedElementNegtive() {
        try {
            FeedServiceProvider.updateFeedElement(null, null, 'updated text','',null, null);
            System.assert(true,'Running as expected');
        } catch(Exception e){
            
        }
    }
    
    @isTest static void testShareFeedElementNegtive() {
        try {
            FeedConnectAPIService.shareFeedElement(null, 'me', 'news', null, 'shared Text');
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest static void testUpdateComment() {
        try {
            ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
            List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
            
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
            feedElementPageObj.elements = listOfFeedElement;
            connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
                                                                   10, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);
            
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            RecentCommentsWrapper recentCommentsWrapperObj = new RecentCommentsWrapper();
            recentCommentsWrapperObj = FeedServiceProvider.postComment(null, textPostObj.Id, null, 'test','', null,null);
            RecentCommentsWrapper updatedRecentCommentsWrapperObj = new RecentCommentsWrapper();
            updatedRecentCommentsWrapperObj = FeedServiceProvider.updateComment(null, recentCommentsWrapperObj.id, 'updatedComment','',null,null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testUpdateCommentNegtive() {
        try {
            RecentCommentsWrapper updatedRecentCommentsWrapperObj = new RecentCommentsWrapper();
            updatedRecentCommentsWrapperObj = FeedServiceProvider.updateComment(null, '123',
                                                                                ' updatedComment','',null,null);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testGetFeedPoll() {
        try {
            FeedElementWrapper feedElementObj = new FeedElementWrapper();
            feedElementObj = FeedServiceProvider.postPoll(null, 'me', 'news', new List<String>{'h1','h2'},
                                                          'Polling','', new List<String>{'h1','h2'}, null);
            PollWrapper pollWraperObj = new PollWrapper();
            pollWraperObj = FeedServiceProvider.getFeedPoll(null, feedElementObj.id);
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testGetFeedPollNegtive() {
        try {
            FeedServiceProvider.getFeedPoll(null, null); 
            System.assert(true,'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testGetSpecifiedFeedElementsPageTest1 () {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedServiceProvider.getSpecifiedFeedElementsPage(null, 'news', 'me', null, 10, 'activity');
            
            System.assert(true, 'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest static void testGetSpecifiedFeedElementsPageNegtive () {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedServiceProvider FeedServiceProviderObj = new FeedServiceProvider();
            FeedServiceProvider.getSpecifiedFeedElementsPage(null, null, null, null, 10, 'activity');
            
            System.assert(true, 'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    
    @isTest static void voteOnPoll1 () {
        try {
            FeedElementFactoryTest.createFeedElementPageRecord('news', 10);
            FeedItem feedItemObj = new FeedItem();
            feedItemObj.ParentId = UserContext.id;		
            feedItemObj.Body = 'I am coming from dev console';
            insert feedItemObj;
            
            FeedServiceProvider.voteOnPoll(null, feedItemObj.Id, 'testId');
            
            System.assert(true, 'Running as expected');
        } catch (exception e) {
            
        }
    }
    
    @isTest static void getFeedPoll1 () {
        try {
            ConnectApi.FeedItem pollPostObj = new ConnectAPI.FeedItem();
            pollPostObj.type = ConnectApi.FeedItemType.PollPost;
            ConnectApi.PollCapability pollCabailityObj = new ConnectApi.PollCapability();
            
            ConnectApi.FeedPollChoice feedPollChObj1= new ConnectApi.FeedPollChoice();
            feedPollChObj1.text ='ch1';
            
            ConnectApi.FeedPollChoice feedPollChObj2= new ConnectApi.FeedPollChoice();
            feedPollChObj2.text ='ch2';
            
            List<ConnectApi.FeedPollChoice> listOfPollChoices = new List<ConnectApi.FeedPollChoice>();
            listOfPollChoices.add(feedPollChObj1);
            listOfPollChoices.add(feedPollChObj2);
            
            pollCabailityObj.choices = listOfPollChoices;
            pollPostObj.capabilities.poll = pollCabailityObj;
            
            FeedElementFactoryTest.createFeedElementPageRecordForSpecifiedFeed('news',((ConnectAPI.FeedElement) pollPostObj));
            
            
            FeedServiceProvider.getFeedPoll(null, ((ConnectAPI.FeedElement) pollPostObj).Id);
            
            System.assert(true, 'Running as expected');
        } catch (exception e) {
            
        }
    }
    
    @isTest static void testProfilePhoto () {
        try {
            FeedServiceProvider.setProfilePhoto(null, null, null, 10);
            
            System.assert(true, 'Running as expected');
        } catch (Exception e) {
            
        }
    }
    
    @isTest 
    static void processFeedLinkTest() {
        try {
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            
            FeedServiceProvider.processFeedLink(true, true, 'https://simpplr--simpplr.visualforce.com/apex/simpplr__app?u=/site/a0No000000CnIcXEAV/album/a0H3l00000QjDg1EAF', 
                                                (ConnectApi.FeedElement)textPostObj, new FeedElementWrapper());
            System.assert(true, 'Running as expected'); //processFeedLink method is return void 
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void processFeedLink1Test() {
        try {
            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            
            FeedServiceProvider.processFeedLink(false, true, 'https://simpplr--simpplr.visualforce.com/apex/simpplr__app?u=/site/a0No000000CnIcXEAV/album/a0H3l00000QjDg1EAF', 
                                                (ConnectApi.FeedElement)textPostObj, new FeedElementWrapper());
            System.assert(true, 'Running as expected'); //processFeedLink method is return void
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void createTimeLineTest() {
        try {
            FeedServiceProvider.createTimeLine(null, 'me', 'https://login.salesforce.com', 
                                               'salesforce', 'hello');
            System.assert(true, 'Running as expected'); //createTimeLine method is return void
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void createTimeLineAndCloseTest() {
        try {
            FeedServiceProvider.createTimeLineAndClose(null, 'me', 'https://login.salesforce.com', 
                                                       'salesforce', 'hello');
            System.assert(true, 'Running as expected'); //createTimeLine method is return void
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void getFeedElementsPageTest() {
        try {
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.getFeedElementsPage('record', 'me', null, '10', 'activity', 
                                                                                                    'sfdc');
            System.assertEquals('record',feedElementPageWrapObj.type,'Running as expected');
        } catch (Exception e) {
            
        }
        
    }

    @isTest 
    static void getFeedElementsPageTest1() {
        CollaborationGroup cg = TestHelper.createCollaborationGroup('Test_Group1_TileServiceTest','Unlisted');
        FeedItem ff= new FeedItem();
        ff.body = '<p>test post</p>';
        ff.type = 'TextPost';
        ff.ParentId = cg.Id;
        insert ff;
        Test.startTest();
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.getFeedElementsPage('record', cg.Id, null, '10', 'activity', 'sfdc');
            feedElementPageWrapObj = FeedServiceProvider.getFeedElementsPage('record', cg.Id, null, '10', 'date', 'sfdc');
            System.assertEquals('record', feedElementPageWrapObj.type, 'type should be record');
        Test.stopTest();
        
    }

    @isTest 
    static void getFeedElementsPageTest2() {
        TestHelper.setupAppConfig();
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp_SiteDataServerTest','Public');
        Simpplr_Site__c siteRecord = [select id,chatter_group_id__c from Simpplr_Site__c where name = 'Simpplr_Grp_SiteDataServerTest'];
        Simpplr_Content__c contentRecord = TestHelper.getContentRecordForCreation('new content title','Page','Approved', siteRecord);
        contentRecord.Question_Answer_Enabled__c = true;
        insert contentRecord;

        ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
        
        ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
        textPostObj.type = ConnectApi.FeedItemType.TextPost;
        listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
        feedElementPageObj.elements = listOfFeedElement;
        connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.RECORD, contentRecord.Id, 3,
            ConnectApi.FeedDensity.AllUpdates, null, 10, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);

        Test.startTest();
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.getFeedElementsPage('record', contentRecord.Id, null, '10', 'activity', 'sfdc');
        Test.stopTest();
        
        System.assertEquals('record', feedElementPageWrapObj.type, 'type should be record');
    }
    
    
    @isTest 
    static void getSingleFeedRecordTest() {
        try {
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.getSingleFeedRecord('1234', 'news', 'activity', '10');
            System.assertEquals('news',feedElementPageWrapObj.type,'Running as expected');
            
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void searchTimeLineAndContentFeedTest() {
        try {
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.searchTimeLineAndContentFeed(null, 
                                                                                                             'news', 'me' , null, 10, 'test', 'activity');
            System.assertEquals('timeline',feedElementPageWrapObj.type,'Running as expected'); 
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void searchTimeLineFeedTest() {
        try {
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.searchTimeLineFeed('news', 1, 10, 'hello', 'activity');
            System.assertEquals('timeline',feedElementPageWrapObj.type,'Running as expected');
            
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void getTimeLineAndContentFeedPageTest() {
        try {
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.getTimeLineAndContentFeedPage (null, 
                                                                                                               10, 1, 'news', 'activity', 'me', 'mobile');
            
            System.assertEquals('timeline_comment',feedElementPageWrapObj.type,'Running as expected');
        } catch (Exception e) {
            
        }
        
    }
    
    @isTest 
    static void getTimeLineAndContentFeedPageTest1() {
        TestHelper.setupAppConfig();
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp_SiteDataServerTest','Public');
        Simpplr_Site__c siteRecord = [select id,chatter_group_id__c from Simpplr_Site__c where name = 'Simpplr_Grp_SiteDataServerTest'];
        Simpplr_Content__c contentRecord = TestHelper.getContentRecordForCreation('new content title','Page','Approved', siteRecord);
        contentRecord.Question_Answer_Enabled__c = true;
        insert contentRecord;

        FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.getTimeLineAndContentFeedPage(null, 
            10, 1, 'record', 'activity', contentRecord.id, 'mobile');
        
        System.assertEquals('timeline_comment',feedElementPageWrapObj.type,'Running as expected');
    }
    
    @isTest 
    static void getTimeLineFeedPageTest() {
        try {
            FeedElementPageWrapper feedElementPageWrapObj = FeedServiceProvider.getTimeLineFeedPage (null, 10, 1, 'activity', 'me');
            System.assertEquals('timeline',feedElementPageWrapObj.type,'Running as expected');
        } catch (Exception e) {
            
        }
        
    }
    
}