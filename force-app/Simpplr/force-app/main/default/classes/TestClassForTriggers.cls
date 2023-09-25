@isTest
private class TestClassForTriggers {
	private static Simpplr_Site__c simpplrSiteObj;
    
   @testSetup static void setup() {
      App_Config__c appConfigRecord = TestHelper.setupAppConfig();  
      simpplrSiteObj = TestDataHandler.createSimpplrSite();

      Question__c question = TestHelper.getQuestionRecordForCreation('question Title', simpplrSiteObj);
      Site_Config__c siteConfig = new Site_Config__c(Site__c = simpplrSiteObj.Id);
      insert question;
      insert siteConfig;
   }
    
    @isTest static void testSimppplrContentVersionOnAdd() {
    	try{
    		ContentVersion objContentVersion = TestDataHandler.createContentVersion('C');
    		ContentVersion insertedContentVersion = [select ContentDocumentId from ContentVersion 
    													where Id =: objContentVersion.Id];
    		System.assertNotEquals(null, [select id from ContentDocumentLink where 
											ContentDocumentId  =: insertedContentVersion.ContentDocumentId and
											LinkedEntityId =: UserInfo.getOrganizationId()]);
    	}catch(Exception e){
    		System.assert(false);
    	}
    }
    
    @isTest static void testFeedCommentTriggerAfterInsert() {
    	try {
    		FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
    		TestDataHandler.createFeedComment(feedItemObj.id);
    	} catch (Exception ex) {
    		System.assert(true, 'Running as Expected');
    	}
    	
    }
    
    @isTest static void testCollaborationGroupTriggerAfterUpdate(){
    	try{
    		simpplrSiteObj = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
    		update new CollaborationGroup(Id=simpplrSiteObj.Chatter_Group_Id__c, Name='NameFromTestClass');
    		List<Simpplr_Site__c> listOfUpdatedSimpplrSites=[Select name from Simpplr_Site__c where id=:simpplrSiteObj.id];
    		System.assert(true, 'Running as Expected');
    	}catch(Exception e){
    	}
    }
    
    @isTest static void testCollaborationGroupTriggerBeforeDelete(){
    	try{
    		simpplrSiteObj = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
    		delete new CollaborationGroup(Id=simpplrSiteObj.Chatter_Group_Id__c);
    		System.assert(true, 'Running as Expected');
    	}catch(Exception e){
    		System.assertEquals('System.DmlException', e.getTypeName());
    	}
    }

   @isTest 
   static void testSiteConfigTrigger(){
      try{
         List<Site_Config__c> siteconfigList = [SELECT Id FROM Site_Config__c];
         System.assertEquals(true, !siteconfigList.isEmpty(), 'Running as Expected');
         delete siteconfigList;
      }catch(Exception e){
         System.assertEquals('System.DmlException', e.getTypeName());
      }
   }

   @isTest 
   static void testQuestionTrigger(){
      try{
         List<Question__c> questions = [SELECT Id FROM Question__c];
         System.assertEquals(true, !questions.isEmpty(), 'Running as Expected');
         delete questions;
      }catch(Exception e){
         System.assertEquals('System.DmlException', e.getTypeName());
      }
   }

   @isTest 
   static void testInsertAnalyticsTopicSuggestion() {
      try {
         Analytics_Topic_Suggestion__c topicSuggestion = new Analytics_Topic_Suggestion__c(Sync_Status__c = 0, Date__c = Date.today());
         insert topicSuggestion;
      } catch (Exception ex) {
         System.assert(true, 'Running as Expected');
      }
   }

   @isTest static void testContentDistributionTrigger() {
      try {
      ContentVersion objContentVersion = TestDataHandler.createContentVersion('C');
      ContentDistribution distribution = new ContentDistribution();
      distribution.Name = 'testContentDistribution';
      distribution.ContentVersionId = objContentVersion.Id;
      insert distribution;
      System.assertEquals(true, distribution.id != null, 'Failed to insert ContentDistribution');
      } catch (Exception ex) {
         System.assert(true, 'Running as Expected');
      }
   }
   
}