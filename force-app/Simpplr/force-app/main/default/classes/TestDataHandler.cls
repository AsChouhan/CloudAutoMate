@isTest
public with sharing class TestDataHandler {
     
     // DONE
    public static String getLongText() {
        String s='';
        //Reverting 131070 to 32767 as it is causing Apex CPU time limit exceeded
        while(s.length() <= 32767) {
            s+='a';
        }
        System.assert(true, 'Running as Expected');
        return s;
    }
    
    public static FeedItem insertFeedItem4Content(Simpplr_Content__c contentObj) {
        FeedItem post = new FeedItem();
        post.ParentId = contentObj.Id;
        post.Body = 'I am coming from dev console';
        insert post;
        System.assert(true, 'Running as Expected');
        return post;
    }
    
    // DONE
    public static User createUser() {
        Profile pfl = [select id from profile where name='Standard User'];

        User testUser = new User(alias = 'u1', email='testu1@testorg.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id,  country='United States', CommunityNickname = 'testuserStandard' + Math.random() ,
            timezonesidkey='America/Los_Angeles', username=Math.random() + '@testorg.com');
        insert testUser;
        
        System.assert(true, 'Running as Expected');
        return testUser;
    }
    
    // DONE
    public static User createManagerUser(User usr) {
        Profile pfl = [select id from profile where name='Standard User'];

        User testUser = new User(alias = 'u1', email='testu1@testorg.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id,  country='United States', CommunityNickname = 'testuserManager' + Math.random() ,
            timezonesidkey='America/Los_Angeles', username=Math.random() + '@testorg.com', Managerid = usr.id);
        insert testUser;
        
        System.assert(true, 'Running as Expected');
        return testUser;
    }
    
    // DONE
    public static User createSystemAdmin() {
        Profile pfl = [select id from profile where name='System Administrator'];

        User testUser =  new User(alias = 'u1', email='u1@testorg.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id,  country='United States', CommunityNickname = 'testsys1',
            timezonesidkey='America/Los_Angeles', username=Math.random() + '@testorg.com');
        insert testUser;
        
        System.assert(true, 'Running as Expected');
        return testUser;
    }
    
    public static Simpplr_Social_Analytics__c createSocialAnalytics(Id simpplrContentId, Id userId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertSocialAnalytics(new Simpplr_Social_Analytics__c
        (
            Content__c=simpplrContentId, Interaction__c='Like', User__c = userId
        ));
    }
    
    public static Simpplr_Social_Analytics__c createSocialAnalytics(Id simpplrContentId, Id siteId, Id userId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertSocialAnalytics(new Simpplr_Social_Analytics__c
        (
            Content__c=simpplrContentId, Interaction__c='View', User__c = userId, Page_URL__c=siteId, Simpplr_Site__c=siteId
        ));
    }
    
    public static Simpplr_Social_Analytics__c createSocialAnalytics(Id simpplrContentId, Id siteId, Id userId, Id peopleId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertSocialAnalytics(new Simpplr_Social_Analytics__c
        (
            Content__c=simpplrContentId, Interaction__c='View', User__c = userId, Page_URL__c=siteId, Simpplr_Site__c=siteId, people__c=peopleId
        ));
    }
    
    public static ContentVersion createContentVersion(String origin){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertContentVersion(new ContentVersion
                (
                    VersionData=Blob.valueOf('TestData'), PathOnClient='Test.jpg', Origin = origin, 
                    Title='TitleOfContentVersion', OwnerId=UserContext.id
                ));
    }
    
    public static ContentVersion createContentVersion(String origin, String pathOnClient){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertContentVersion(new ContentVersion
                (
                    VersionData=Blob.valueOf('TestData'), PathOnClient= pathOnClient, Origin = origin, 
                    Title='TitleOfContentVersion', OwnerId=UserContext.id
                ));
    }
    
    public static Document createDocument(){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertDocument(new Document
                (
                    Body=Blob.valueOf('TestData'), Name='Test', FolderId='12345678'
                ));
    }
    
    public static ContentVersion createContentVersion(String origin, String pathOnClient, String contentWorkspaceId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertContentVersion(new ContentVersion
                (
                    VersionData=Blob.valueOf('TestData'), PathOnClient=pathOnClient+'_simp_cont_Test.jpg', Origin = origin, 
                    Title='TitleOfContentVersion', OwnerId=UserContext.id, FirstPublishLocationId = contentWorkspaceId
                ));
    }
    
    public static ContentWorkspaceDoc createContentWorkspaceDoc(Id contentDocumentId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertContentWorkspaceDoc(new ContentWorkspaceDoc
                (
                    ContentDocumentId=contentDocumentId, ContentWorkspaceId=[SELECT Id FROM ContentWorkspace][0].Id
                ));
    }
    
    public static ContentDocumentLink createContentDocumentLink(Id contentDocumentId, String linkedEntityId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertContentDocumentLink(new ContentDocumentLink
                (
                    LinkedEntityId=linkedEntityId, shareType='V', ContentDocumentId=contentDocumentId
                ));
    }
    
    public static FeedItem createFeedItem(String parentId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertFeedItem(new FeedItem
                        (
                            Body='Testtextarea', ParentId=parentId, Type='ContentPost'
                        ));
    }
    
    public static FeedComment createFeedComment(String feedItemId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertFeedComment(new FeedComment
                        (
                            CommentBody='Testtextarea', feedItemId=feedItemId 
                        ));
    }

    public static FeedComment createFeedCommentForSlackPlaceholderReply(String feedItemId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertFeedComment(new FeedComment
                        (
                            CommentBody=ServiceConstants.FEED_COMMENT_BODY_PLACEHOLDER, feedItemId=feedItemId 
                        ));
    }
    
    public static FeedItem createFeedItemPollPost(String parentId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertFeedItem(new FeedItem
                        (
                            Body='Testtextarea', ParentId=parentId, Type='PollPost' 
                        ));
    }
    
    public static FeedItem createFeedItem(String parentId, String postType){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertFeedItem(new FeedItem
                        (
                            Body='Testtextarea', ParentId=parentId, Type=postType 
                        ));
    }
    
    public static Simpplr_Site__c createSimpplrSite(User userId){
      Simpplr_Site__c siteObj;
      //system.runAs(userId){
        Id collaborationGroupId = createCollaborationGroup(userId);

         siteObj = updateSimpplrSite
        (new Simpplr_Site__c(Name='SiteTest', Chatter_Group_Id__c=collaborationGroupId,
                                Has_Pages__c = true, Has_Albums__c = true, Has_Events__c = true, Landing_Page__c = 'about', 
                                Carousel_Content__c='test1, test2',
                                Site_Links__c='{"listOfHelpLink":[{"simpplrSiteId":"","orderOfHelpLink":1,"helpLinkUrl":"Url"'+
                                ',"helpLinkTitle":"Title","chatterGroupId":""}],"listOfApps":null,"filter":null}')
        ,collaborationGroupId);
        
        System.assert(true, 'Running as Expected');
      //}  
        return siteObj;
        
    }
    
    public static List<Simpplr_Site__c> createSimpplrSites(String chatterGroupName){
        Id collaborationGroupId = createCollaborationGroup(chatterGroupName);
        List<Simpplr_Site__c> listOSimpplrSite = new List<Simpplr_Site__c>{TestDataHandler.updateSimpplrSite
        (new Simpplr_Site__c(Name=chatterGroupName, Chatter_Group_Id__c=collaborationGroupId, 
            Has_Pages__c = true, Has_Albums__c = true, Has_Events__c = true, Landing_Page__c = 'about'),collaborationGroupId)};
        
        System.assert(true, 'Running as Expected');
        return listOSimpplrSite;
        
    }
    
    public static List<Simpplr_Site__c> createSimpplrSites(String chatterGroupName, String contentWorkspaceId){
        
        System.assert(true, 'Running as Expected');
        return null;
        
    }
    
    public static Id createCollaborationGroup(User uId){
     List<CollaborationGroup> listOfCollaborationGroup;
    //system.runAs(uId){
       listOfCollaborationGroup = TestDataHandler.insertCollaborationGroups
            (new List<CollaborationGroup>
            {
                new CollaborationGroup(Name='Site', CollaborationType='Public', isArchived=false, 
                                        InformationTitle ='Title', InformationBody = 'Information',
                                        Description='TestDescription')
           });
        
        System.assert(true, 'Running as Expected');
    //} 
            return listOfCollaborationGroup[0].Id;
   
    }
    
    // DONE
    public static Id createArchivedCollaborationGroup(){
        User testUser = createUser();
        List<CollaborationGroup> listOfCollaborationGroup = TestDataHandler.insertCollaborationGroups
            (new List<CollaborationGroup>
            {
                new CollaborationGroup(Name='SiteA', CollaborationType='Public', isArchived=true, 
                                        InformationTitle ='TitleA', InformationBody = 'InformationA',
                                        Description='TestDescriptionA')
            });
        
        System.assert(true, 'Running as Expected');
        return listOfCollaborationGroup[0].Id;
    }
	
	// DONE    
    public static Id createPrivateGroup(){
        User testUser = createUser();
        List<CollaborationGroup> listOfCollaborationGroup = TestDataHandler.insertCollaborationGroups
            (new List<CollaborationGroup>
            {
                new CollaborationGroup(Name='Private Group', CollaborationType='Private', isArchived=false, 
                                        InformationTitle ='Title', InformationBody = 'Information',
                                        Description='TestDescription')
            });
        
        System.assert(true, 'Running as Expected');
        return listOfCollaborationGroup[0].Id;
    }
    
    // DONE
    public static Id createCollaborationGroup(String chatterGroupName){
        List<CollaborationGroup> listOfCollaborationGroup = TestDataHandler.insertCollaborationGroups
            (new List<CollaborationGroup>
            {
                new CollaborationGroup(Name=chatterGroupName, CollaborationType='Public',Description='TestDescription', InformationTitle='TestTitle',InformationBody='TestInformationBody')
            });
        
        System.assert(true, 'Running as Expected');
        return listOfCollaborationGroup[0].Id;
    }
    
    // DONE
    public static CollaborationGroupMember createCollaborationGroupMember(Id groupId, String userId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertCollaborationGroupMember(new CollaborationGroupMember(
                                                    CollaborationGroupId=groupId, MemberId=userId
        ));
    }
    
    // DONE
    public static CollaborationGroupMember createCollaborationGroupMember(Id groupId){
        System.assert(true, 'Running as Expected');
        return TestDataHandler.insertCollaborationGroupMember(new CollaborationGroupMember(
                                                    CollaborationGroupId=groupId, MemberId=UserContext.id
        ));
    }

    public static void deleteContentById(Id contetnID) {
        try{
            List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();
            listOfSimpplrContent.add(new Simpplr_Content__c(id = contetnID, Is_Deleted__c=true));
            update listOfSimpplrContent;
            System.assert(true, 'Running as Expected');
        }catch(DmlException e){
            throw e;
        }
    }
    
    public static List<Simpplr_Site__c> insertSimpplrSites(List<Simpplr_Site__c> listOfSimpplrSite){
        try{
            insert listOfSimpplrSite;
            System.assert(true, 'Running as Expected');
            return listOfSimpplrSite;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static Simpplr_Site__c updateSimpplrSite(Simpplr_Site__c siteObj, Id chatterGroupId){
        try{
            List<Simpplr_Site__c> listOfSimpplrSite = [select id,name from Simpplr_Site__c where chatter_group_id__c=:chatterGroupId];
            if(!listOfSimpplrSite.isEmpty()) {
                siteObj.id = listOfSimpplrSite[0].id;
                
                update siteObj;
            }
            System.assert(true, 'Running as Expected');
            return siteObj;
        }catch(DmlException e){
            throw e;
        }
    }
    
    
    // DONE
    private static List<CollaborationGroup> insertCollaborationGroups(List<CollaborationGroup> listOfCollaborationGroup){
        try{
            insert listOfCollaborationGroup;
            System.assert(true, 'Running as Expected');
            return listOfCollaborationGroup;
        }catch(DmlException e){
            throw e;
        }
      
    }
    // DONE
    private static CollaborationGroupMember insertCollaborationGroupMember(CollaborationGroupMember obj){
        try{
            Database.insert(obj, false);
            System.assert(true, 'Running as Expected');
            return obj;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static void insertContent(List<Simpplr_Content__c> listOfcontent){
        try{
            Test.startTest();
                insert listOfcontent;
            Test.stopTest();
            System.assert(true, 'Running as Expected');
        }catch(DmlException e){
            throw e;
        }
    }
    private static void insertGroupMember(List<GroupMember> listOfGroupMember){
        try{
            Test.startTest();
                insert listOfGroupMember;
            Test.stopTest();
            System.assert(true, 'Running as Expected');
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static Simpplr_Content__c insertContent(Simpplr_Content__c content){
        try{
            insert content;
            System.assert(true, 'Running as Expected');
            return content;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static Simpplr_Social_Analytics__c insertSocialAnalytics(Simpplr_Social_Analytics__c socialAnalytics){
        try{
            insert socialAnalytics;
            System.assert(true, 'Running as Expected');
            return socialAnalytics;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static ContentVersion insertContentVersion(ContentVersion objContentVersion){
        try{
            insert objContentVersion;
            System.assert(true, 'Running as Expected');
            return objContentVersion;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static Document insertDocument(Document objDocument){
        try{
            insert objDocument;
            System.assert(true, 'Running as Expected');
            return objDocument;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static ContentWorkspaceDoc insertContentWorkspaceDoc
                                                            (ContentWorkspaceDoc objContentWorkspaceDoc){
        try{
            insert objContentWorkspaceDoc;
            System.assert(true, 'Running as Expected');
            return objContentWorkspaceDoc;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static ContentDocumentLink insertContentDocumentLink
                                                            (ContentDocumentLink objContentDocumentLink){
        try{
            insert objContentDocumentLink;
            System.assert(true, 'Running as Expected');
            return objContentDocumentLink;
        }catch(DmlException e){
            throw e;
        }
    }
    
    
    
    private static FeedItem insertFeedItem(FeedItem objFeedItem){
        try{
            insert objFeedItem;
            System.assert(true, 'Running as Expected');
            return objFeedItem;
        }catch(DmlException e){
            throw e;
        }
    }
    
    private static FeedComment insertFeedComment(FeedComment objFeedComment){
        try{
            insert objFeedComment;
            System.assert(true, 'Running as Expected');
            return objFeedComment;
        }catch(DmlException e){
            throw e;
        }
    }
    
    public static User getUser(String profile, Boolean blogCSEnabled, String metaDataStr) {
        
        Profile p = [SELECT Id FROM Profile WHERE Name=:profile]; 
        String uniqueVal = String.valueOf(Math.Random());
        uniqueVal = uniqueVal.left(7);
        System.assert(true, 'Running as Expected');
        return new User(Alias = 'S' + uniqueVal, Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName =  'U' + uniqueVal + '@testorg.com', 
                    Blog_CS_Enabled__c=blogCSEnabled,
                    Metadata__c=metaDataStr
                    );
    }

	public static Id createCollaborationGroup(){
		List<CollaborationGroup> listOfCollaborationGroup = TestDataHandler.insertCollaborationGroups
			(new List<CollaborationGroup>
			{
                new CollaborationGroup(Name='Site', CollaborationType='Public', isArchived=false, 
                						InformationTitle ='Title', InformationBody = 'Information',
                						Description='TestDescription')
			});
		
		System.assert(true, 'Running as Expected');
		return listOfCollaborationGroup[0].Id;
	}
	
	public static Simpplr_Site__c createSimpplrSite(){
		Id collaborationGroupId = createCollaborationGroup();

		Simpplr_Site__c siteObj = updateSimpplrSite
		(new Simpplr_Site__c(Name='SiteTest', Chatter_Group_Id__c=collaborationGroupId,
								Has_Pages__c = true, Has_Albums__c = true, Has_Events__c = true, Landing_Page__c = 'about', 
								Carousel_Content__c='test1, test2',
								Site_Links__c='{"listOfHelpLink":[{"simpplrSiteId":"","orderOfHelpLink":1,"helpLinkUrl":"Url"'+
								',"helpLinkTitle":"Title","chatterGroupId":""}],"listOfApps":null,"filter":null}')
		,collaborationGroupId);
		
		System.assert(true, 'Running as Expected');
		return siteObj;
		
	}
	
}