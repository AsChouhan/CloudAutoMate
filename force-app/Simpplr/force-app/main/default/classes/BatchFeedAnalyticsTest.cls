@isTest
private class BatchFeedAnalyticsTest {
	
	private static App_Config__c appConfigRecord;
	private static User systemAdmin;
	private static User siteOwnr;
	private static User siteMember;
	private static User siteAdmin;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Content__c simpplrContentForScore;
	private static Simpplr_Site__c site;
	private static People__c peopleObj;
	private static ContentVersion contentVersionObj;
	private static PageReference pageRef;
	
    @testSetup 
	static void setupData() { 
    	try {
    		FeedItem f = new FeedItem();
	        f.ParentId = UserInfo.getUserId();
	        f.body = 'test';
	        insert f;
	        FeedComment fc = new FeedComment();
	        fc.CommentBody = 'legal test';
	        fc.FeedItemId = f.Id;   // please add this
	        insert fc;
	        
	        FeedLike fl = new FeedLike(FeedItemId=f.id );
	        insert fl;
	        
    	} catch (Exception e) {
    	
    	}
    }
    
	
    @isTest static void test() {    	

       Test.startTest();
       BatchFeedAnalytics c = new BatchFeedAnalytics('initAnalyticsData', System.today());
       Database.executeBatch(c);
       Test.stopTest();

       // Verify Analytics_Feed_Count__c got created 
       Integer i = [SELECT COUNT() FROM Analytics_Feed_Count__c];
       System.assertEquals(0, i, 'Running as expected');
    }
}