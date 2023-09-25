@isTest
private class FeedElementWrapperTest {
	@testSetup static void setup() {
	
	}
     @isTest static void testVariables () { 
     	FeedElementWrapper feedElementWrapObj = new FeedElementWrapper();
     	feedElementWrapObj.id = '123';
     	feedElementWrapObj.createdAt = String.valueOf(system.now());
     	
     	feedElementWrapObj.authoredBy = new PeopleLiteWrapper();
     	feedElementWrapObj.authoredBy.id = '122';
     	feedElementWrapObj.authoredBy.userId = '344' ;
     	feedElementWrapObj.authoredBy.peopleId = '566';
     	feedElementWrapObj.authoredBy.name = 'Vian';
     	feedElementWrapObj.authoredBy.title = 'IMG';
     	feedElementWrapObj.authoredBy.img = 'TestIMG';
     	feedElementWrapObj.authoredBy.url = 'Google';
     	feedElementWrapObj.authoredBy.role = 'CTO';
     	feedElementWrapObj.authoredBy.department = 'ggn';
     	feedElementWrapObj.authoredBy.location = 'ggn' ;
     	feedElementWrapObj.authoredBy.address = 'GGN';
     	feedElementWrapObj.authoredBy.canFollow = true;
     	
     	feedElementWrapObj.addressedTo = new PeopleLiteWrapper();
     	feedElementWrapObj.addressedTo.id = '123';
     	feedElementWrapObj.addressedTo.name =  'ajay';
     	feedElementWrapObj.addressedTo.department = 'IT';
     	feedElementWrapObj.addressedTo.img = 'google.com';
     	feedElementWrapObj.addressedTo.url = 'google.com';
     	
     	feedElementWrapObj.site = new SiteLiteWrapper();
     	feedElementWrapObj.createdSite = new FeedSiteWrapper();
     	feedElementWrapObj.createdSite.Id = '123';
     	feedElementWrapObj.createdSite.name = 'Simpplr';
     	feedElementWrapObj.createdSite.url = 'test.url';
     	
     	feedElementWrapObj.body = 'hello ';
     	feedElementWrapObj.postType = 'TextPost';
     	feedElementWrapObj.listOfTopics = new List<TopicWrapper>();
     	feedElementWrapObj.isLiked = true;
     	feedElementWrapObj.likeCount = 10;
     	feedElementWrapObj.commentCount = 10;
     	feedElementWrapObj.recentComments = new RecentCommentsContainerWrapper();
     	
     	feedElementWrapObj.canEdit = true;
     	feedElementWrapObj.canFavorite = true;
     	feedElementWrapObj.canChangeTopics = true;
     	feedElementWrapObj.canDelete = true;
     	feedElementWrapObj.feedElementType = 'News';
     	feedElementWrapObj.isBookmarked = true;
     	feedElementWrapObj.canShare = true;
     	feedElementWrapObj.likeId = '134';
     	feedElementWrapObj.link = new LinkWrapper();
     	feedElementWrapObj.listOfFiles = new List<FileWrapper>();
     	feedElementWrapObj.poll = new PollWrapper();
     	feedElementWrapObj.poll.title = 'CHQ';
     	feedElementWrapObj.poll.listOfAnswers = new List<PollChoiceWrapper>();
     	
     	PollChoiceWrapper pollChoiceObj = new PollChoiceWrapper();
     	pollChoiceObj.id = '123';
     	pollChoiceObj.title = 'SSE';
     	pollChoiceObj.voteCount = 10;
     	pollChoiceObj.percentage = 12.2;
     	pollChoiceObj.position = 1;
     	
     	feedElementWrapObj.poll.listOfAnswers.add(pollChoiceObj);
     	feedElementWrapObj.poll.totalVotes = 10;
     	feedElementWrapObj.poll.hasVoted = true;
     	feedElementWrapObj.poll.myChoiceId = '123';
     	
     	feedElementWrapObj.changes = new ChangeContainerWrapper();
     	feedElementWrapObj.changes.amountNotInSummary = 10;
     	feedElementWrapObj.changes.summary = 'hello';
     	feedElementWrapObj.changes.listOfChanges = new List<String>{'One'};
     	
     	feedElementWrapObj.url = '';
     	feedElementWrapObj.listOfMentions = new List<MentionWrapper>();
     	
     	feedElementWrapObj.originalPost = new FeedElementWrapper.OriginalPostWrapper();
     	feedElementWrapObj.originalPost.id = '123';
     	feedElementWrapObj.originalPost.url = 'SImp';
     	feedElementWrapObj.originalPost.authoredBy = new PeopleLiteWrapper();

		System.assert(true, 'Running as expected');
     }
}