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
private class NewsletterDataServerTest {

    
     @testSetup static void setup() {
        TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User siteMngr = TestHelper.createUser('Simpplr_siteMngr', null, false);
        Id collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').id;
        TestHelper.createCollaborationGroupMember(collaborationGroupId,siteMngr.id,'Admin');
        People__c peopleObj = TestHelper.createPeopleRecordForUser(String.valueOf(UserContext.id));
        TestHelper.createPeoplePreference(String.valueOf(peopleObj.Id));
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
        Simpplr_Content__c testContent = TestHelper.createContent('Test content','Event','Approved',testUser,testSite,String.valueOf(peopleObj.Id));
        TestHelper.getMailerRecord('NewsletterDataServerTest_NewsLetter1', peopleObj.Id, testSite.id,testContent.Id);
        Segment__c segmentRec = TestHelper.createSegment(peopleObj.Id);
        Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
        ContentVersion conObj = TestHelper.createContentVersion('conVer', 'File_01');
    }
    
    private static User getStandardUser(){
        User userObj = [select id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
                            from User where profile.name ='Standard User' and lastname='Simpplr_usr1' LIMIT 1];
        return userObj;
    }
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [select Id, Name, Chatter_Group_Id__c, Landing_Page__c 
                                        from Simpplr_Site__c  LIMIT 1];
        return siteObj;
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, 
        							Manager__c,Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, 
        							Department__c, Country__c, City__c,Mobile_Token_Android__c,Mobile_Token_IOS__c
                                    From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }
    
    private static Simpplr_Content__c getContent(){
        Simpplr_Content__c  contentObj = [Select Id,Text_Intro__c,Display_Excerpt__c,Summary_1__c,Type__c,
        Is_Published__c,Is_Unpublished__c,Is_Deleted__c,Activated_By_Feature__c,Publish_End_DateTime__c,First_Publish_DateTime__c,Is_Must_Read__c,
        Status__c,Primary_Author__c,site__c,Title__c,CreatedDate,Publish_Start_DateTime__c,Event_End_DateTime__c,Event_Is_All_Day__c,
        Event_Start_DateTime__c,LastModifiedDate,Primary_Author__r.User__r.Id,Primary_Author__r.Full_Name__c,Site__r.Landing_Page__c,
        Primary_Author__r.User__r.SmallPhotoUrl,Site__r.name,Site__r.Is_Active__c,Site__r.Is_Deleted__c,Site__r.Site_Type__c,
        Site__r.Title_Content_Version__c,
        (SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c FROM File_Simpplr_Content__r where Is_Deleted__c = false)                                  
        From Simpplr_Content__c where Title__c =  'Test content' LIMIT 1];
        return contentObj;
    }
    
   
    private static void init() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','NewsletterDataServer');
        Test.setCurrentPage(pgRef);        
        System.assertEquals('NewsletterDataServer',ApexPages.currentPage().getParameters().get('target'), 'Running as Expected');
          }
    		
    		private static Mailer__c getNewsletter() {
    			return Database.query('SELECT '+String.join(NewsletterDataServer.getNewsletterFieldList(),',')+' FROM Mailer__c where Subject__c=\'NewsletterDataServerTest_NewsLetter1\' limit 1');
    		}
    
        @isTest static void testHandleRequestWhenActionNull() {
        init();        
        NewsletterDataServer serverObj = new NewsletterDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterDataServer');
        pageRef.getParameters().put('action','');
        pageRef.getParameters().put('siteId', getSite().Id);
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, 'Running as Expected');
    }
    
    @isTest static void testHandleRequestWhenActionAvailable() {
        init();
        NewsletterDataServer serverObj = new NewsletterDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterDataServer');
        pageRef.getParameters().put('siteId', getSite().Id);
        Test.setCurrentPage(pageRef);
        
        
        pageRef.getParameters().put('action','getContentIdSetOfNewsletter');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','sendPreview');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','sendNewsletter');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','updateStatusAndWrapper');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','getCGMemberCount');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','getNewsletter');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','saveDraft');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','convertWrapperToMailerDetailObject');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','stringToDateTime');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','updateNewsletter');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','deleteNewsletter');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
         pageRef.getParameters().put('action','editNewsletter');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','scheduleNewsletter');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','sitesIManageIdSet');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        
        pageRef.getParameters().put('action','getContentMap');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','getListedCollabGrpIManageMap');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','convertContentToWrapper');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','convertNewsletterListTowrapperList');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','update');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','edit');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','delete');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        System.assertEquals('error',serverObj.response.status,'Running as expected');
    }
    
    
    @isTest static void testSendPreview() {
        Test.startTest();
        init();
        NewsletterDataServer serverObj = new NewsletterDataServer();
        Simpplr_Content__c contentRecId = getContent();
        Mailer__c newsletter = getNewsletter();
        newsletter.Test_Mailer_Sent__c = false;
        update newsletter;
        List<Mailer__c> mailerObjList = new List<Mailer__c>{newsletter};
        Mailer_Details__c mailerDetailObj = [SELECT Id,Mailer__c,Content__c FROM Mailer_Details__c 
				WHERE Mailer__c =:newsletter.Id limit 1];       
        mailerDetailObj.Content__c = contentRecId.Id;
        update mailerDetailObj;
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','NewsletterDataServer');
        pgRef.getParameters().put('action', 'sendPreview');
        pgRef.getParameters().put('siteId', getSite().Id);
        pgRef.getParameters().put('data', '{"newsletterId":"'+newsletter.Id+'","itemData":{"sendAt":"2016-10-13T23:00:00","listOfItems":[],"recipient":"site","site":{"isAccessRequested":false,"aboutUrl":null,"siteId":"'+newsletter.Site__c+'","canCreateAlbum":false,"isManager":false,"img":null,"isMember":false,"canControlDashboard":false,"isListed":true,"imgThumbnail":null,"isOwner":false,"hasPages":false,"information":null,"about":null,"canCreateEvent":false,"sections":[],"url":null,"isActive":false,"slack":null,"chatterGroupId":"'+newsletter.Site__c+'","isPublic":false,"hasEvents":false,"title":"ESCAPE2","isFeatured":false,"isFeedEnabled":false,"isPrivate":false,"members":0,"id":"'+newsletter.Site__c+'","canCreatePage":false,"description":null,"isFavorited":false,"category":null,"hasAlbums":false,"hasContent":false}}}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        newsletter.status__c = 'Draft';
        update newsletter;
        serverObj.handleRequest();
        newsletter.status__c = 'On Hold';
        update newsletter;
        serverObj.handleRequest();
        contentRecId.status__c = 'draft';
        update contentRecId;
        newsletter.status__c = 'On Hold';
        update newsletter;
        serverObj.handleRequest();
        System.assertEquals(1,Limits.getEmailInvocations(), 'Running as Expected');
        Test.stopTest();
    }
    
        @isTest static void testSendNewsletter() {
        Test.startTest();
        init();
        NewsletterDataServer serverObj = new NewsletterDataServer();
        Mailer__c newsletter = getNewsletter();
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','NewsletterDataServer');
        pgRef.getParameters().put('action', 'sendNow');
        pgRef.getParameters().put('siteId', getSite().Id);
        pgRef.getParameters().put('data', '{"newsletterId":"'+newsletter.Id+'","itemData":{"sendAt":"2016-10-13T23:00:00","listOfItems":[],"recipient":"site","site":{"isAccessRequested":false,"aboutUrl":null,"siteId":"'+newsletter.Site__c+'","canCreateAlbum":false,"isManager":false,"img":null,"isMember":false,"canControlDashboard":false,"isListed":true,"imgThumbnail":null,"isOwner":false,"hasPages":false,"information":null,"about":null,"canCreateEvent":false,"sections":[],"url":null,"isActive":false,"slack":null,"chatterGroupId":"'+newsletter.Site__c+'","isPublic":false,"hasEvents":false,"title":"ESCAPE2","isFeatured":false,"isFeedEnabled":false,"isPrivate":false,"members":0,"id":"'+newsletter.Site__c+'","canCreatePage":false,"description":null,"isFavorited":false,"category":null,"hasAlbums":false,"hasContent":false}}}');
        Test.setCurrentPage(pgRef);        
        serverObj.handleRequest();
        newsletter.status__c = 'On Hold';
        update newsletter;
        serverObj.handleRequest();
        newsletter.status__c = 'Draft';
        update newsletter;
        serverObj.handleRequest();
        newsletter.status__c = 'scheduled';
        update newsletter;
        simpplr_content__c conObj = getContent();
        conObj.Is_Deleted__c = true;
        update conObj; 
        serverObj.handleRequest();
        System.assertEquals('It\'s not possible to include content that has been unpublished or deleted',serverObj.response.message, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testUpdateStatusAndWrapper() {  	
        init();                  
        NewsletterListingWrapper newsletterWrapper = new NewsletterListingWrapper(); 
        NewsletterDataServer serverObj = new NewsletterDataServer();
        Mailer__c newsletter = getNewsletter();
        serverObj.updateStatusAndWrapper(newsletter,newsletterWrapper,'Sent','2016-10-13T23:00:00');
        System.assertEquals('sent',newsletterWrapper.status, 'Running as Expected');
        
        serverObj.updateStatusAndWrapper(newsletter,newsletterWrapper,'On Hold','2016-10-13T23:00:00');
        System.assertEquals('on_hold',newsletterWrapper.status, 'Running as Expected');
        
        serverObj.updateStatusAndWrapper(newsletter,newsletterWrapper,'Scheduled','2016-10-13T23:00:00');
        System.assertEquals('scheduled',newsletterWrapper.status, 'Running as Expected');
    }

    @isTest static void testGetContentIdSetOfNewsletter() {  	
		init();                  
	    NewsletterListingWrapper newsletterWrapper = new NewsletterListingWrapper(); 
        NewsletterDataServer serverObj = new NewsletterDataServer();
        Mailer__c newsletter = getNewsletter();
        List<Mailer__c> mailerObjList = new List<Mailer__c>{newsletter};
		Mailer_Details__c mailerDetailObj = [SELECT Content__c, Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
				SystemModstamp, Is_Deleted__c, Is_Showcase__c, Mailer__c, Order__c, Text__c, Type__c FROM Mailer_Details__c 
				WHERE Mailer__c =:newsletter.Id limit 1];       
		mailerDetailObj.Content__c = getContent().Id;
		update mailerDetailObj;
        serverObj.getContentIdSetOfNewsletter(new List<Mailer_Details__c>{mailerDetailObj}); 
        simpplr_content__c contentObj = getcontent();
        Map<Id, Simpplr_Content__c> contentIdToContentMap = new Map<Id, Simpplr_Content__c>();
        contentIdToContentMap.put(UserContext.Id,contentObj); 
        serverObj.convertNewsletterContentsListTowrapperList(new List<Mailer_Details__c>{mailerDetailObj},contentIdToContentMap);
        ResponseWrapper resp = serverObj.getNewsletter(newsletter.Id);
        List<NewsletterListingWrapper.ContentListWrapper> contentWrapperList = new List<NewsletterListingWrapper.ContentListWrapper>();
        NewsletterListingWrapper.ContentListWrapper contentWrapper = new NewsletterListingWrapper.ContentListWrapper();
            contentWrapper.isShowcase = true;
            contentWrapper.text ='text';
        	contentWrapper.index = 2;
        contentWrapperList.add(contentWrapper);
        serverObj.convertWrapperToMailerDetailObject(contentWrapperList,newsletter.Id);
        System.assertEquals(1,contentIdToContentMap.size(), 'Running as Expected');
	        
    }
    
     @isTest static void testSaveDraft() {  	
        Test.startTest();
        init();
        PageReference pgRef = Page.DataServerRW;
        Mailer__c newsletter = getNewsletter();
        
        List<Mailer__c> mailerObjList = new List<Mailer__c>{newsletter};
        Mailer_Details__c mailerDetailObj = [SELECT Id,Mailer__c,Content__c FROM Mailer_Details__c 
                WHERE Mailer__c =:newsletter.Id limit 1];       
            mailerDetailObj.Content__c = getContent().Id;
        update mailerDetailObj;
        List<File__c> fileObj = [Select Id,Content_Version__c ,Is_Deleted__c from File__c];
        File__c fileId = new File__c(); 
         if (fileObj.size() > 0){
                fileId.Id = fileObj[0].Id;
                fileId.Content_Version__c = fileObj[0].Content_Version__c;
            insert fileId;
         }
        Simpplr_content__c ContentId = getContent(); 
        ContentId.Is_Deleted__c = true;
        update ContentId;
        NewsletterDataServer serverObj = new NewsletterDataServer();                      
        
        segment__c segmentId = [Select Id from segment__c];
        audience__c audienceId = [Select Id from audience__c];
        people__c peopleId = getPeople(UserContext.Id);
        simpplr_site__c siteId = getSite();
        siteId.Is_Deleted__c = true;
        update siteId;
         
        ContentDocument ContentDocumentId = [SELECT Id, IsDeleted, Title FROM ContentDocument];
        update ContentDocumentId;
        ResponseWrapper resp = serverObj.saveDraft('{"data":{"recipient":"site","site":{"siteId":"'+siteId.id+'"},"listOfItems":[{"type":"content","content":{"id":"'+ContentId.id+'"}}]}}');
		serverObj.saveDraft('{"data":{"recipient":"site","site":{"siteId":"'+siteId.id+'"},"listOfItems":[]}}');
        serverObj.saveDraft('{"data":{"recipient":"segment","segment":{"segmentId":"'+segmentId.id+'"},"listOfItems":[]}}');
        serverObj.saveDraft('{"data":{"recipient":"audience","audience":{"audienceId":"'+audienceId.id+'"},"listOfItems":[]}}');
        ContentId.Is_Deleted__c = false;
        update ContentId;
		serverObj.saveDraft('{"data":{"recipient":"site","site":{"siteId":"'+siteId.id+'"},"listOfItems":[{"type":"content","content":{"id":"'+ContentId.id+'"}}]}}');
        serverObj.saveDraft('{"data":{"recipient":"null","listOfItems":[]}}');
        System.assertEquals('error',resp.status, 'Running as Expected');
        Test.stopTest();
            
    }
    
   @isTest static void testStringToDateTime() {
        init();                
        NewsletterDataServer serverObj = new NewsletterDataServer();          
        Datetime dateTimeObj = serverObj.stringToDateTime('2016-10-13T23:00:00');
        System.assertEquals('13/10/2016, 11:00 PM',dateTimeObj.format('dd/MM/yyyy, h:mm a'), 'Running as Expected');
    }
    
    @isTest 
    static void testUpdateNewsletter() {  
        Test.startTest();
		init();   
        NewsletterListingWrapper newsletterWrapper = new NewsletterListingWrapper();          
        NewsletterDataServer serverObj = new NewsletterDataServer();
        
        Simpplr_Content__c contentRecId = getContent();
        update contentRecId;
        Mailer__c newsletter = getNewsletter();
        newsletter.Status__c = 'On Hold';
        newsletter.site__c = getSite().Id;
		update newsletter;
        List<Mailer__c> mailerObjList = new List<Mailer__c>{newsletter};
        Mailer_Details__c mailerDetailObj = [SELECT Id,Mailer__c,Content__c FROM Mailer_Details__c 
				WHERE Mailer__c =:newsletter.Id limit 1];       
        mailerDetailObj.Content__c = contentRecId.Id;
        update mailerDetailObj;
        segment__c segObj = [Select id From Segment__c where Name__c =: 'Untitled Segment'];
        audience__c audObj = [Select id From audience__c where segment__c =: segObj.id];
        PageReference pgRef = Page.DataServerRW;
                       
        ResponseWrapper resp = serverObj.updateNewsletter('{"newsletterId":"'+newsletter.Id+'","itemData":{"recipient":"site","site":{"siteId":"'+getSite().Id+'"},"listOfItems":[{"type":"content","content":{"id":"'+contentRecId.id+'"}}]}}');
        serverObj.updateNewsletter('{"newsletterId":"'+newsletter.Id+'","itemData":{"subject":"newSubject","recipient":"site","site":{"siteId":"'+getSite().Id+'"},"listOfItems":[]}}');
        serverObj.updateNewsletter('{"newsletterId":"'+newsletter.Id+'","itemData":{"recipient":"segment","segment":{"segmentId":"'+segObj.id+'"},"listOfItems":[]}}');
        serverObj.updateNewsletter('{"newsletterId":"'+newsletter.Id+'","itemData":{"recipient":"audience","audience":{"audienceId":"'+audObj.Id+'"},"listOfItems":[]}}');
        serverObj.updateNewsletter('{"newsletterId":"'+newsletter.Id+'","itemData":{"recipient":null,"listOfItems":[]}}');

        serverObj.updateStatusAndWrapper(newsletter,newsletterWrapper,'Sent','2016-10-13T23:00:00');
        serverObj.updateStatusAndWrapper(newsletter,newsletterWrapper,'On Hold','2016-10-13T23:00:00');  
        serverObj.updateStatusAndWrapper(newsletter,newsletterWrapper,'Scheduled','2016-10-13T23:00:00');
		
        Test.stopTest();
        System.assertEquals('It\'s not possible to include content that has been unpublished or deleted',resp.message, 'Running as Expected');
        
            
    }
        
    
    @isTest static void testDeleteNewsletter() {  	
    	init();               
		NewsletterDataServer serverObj = new NewsletterDataServer(); 
		Mailer__c newsletter = getNewsletter();                     
        ResponseWrapper resp = serverObj.deleteNewsletter(newsletter.Id); 
        newsletter.Status__c = 'Draft';
        update newsletter; 
        serverObj.deleteNewsletter(newsletter.Id);
        System.assertEquals('It\'s not possible to perform this action - Newsletter has already been sent',resp.message, 'Running as Expected');
	}
    
    @isTest 
    static void testEditNewsletter() {  
        Test.startTest();
    	init();                    
        NewsletterDataServer serverObj = new NewsletterDataServer(); 
        Mailer__c newsletter = getNewsletter();                     
        ResponseWrapper resp = serverObj.editNewsletter(newsletter.Id);           
        serverObj.search('{"filter":"draft","term":"abc","recipient":null,"pageName":"Newsletter","sortBy":"createdNewest","size":16}');
        serverObj.search('{"filter":"on_hold","term":"abc","recipient":"everyone","pageName":"Newsletter","sortBy":"sendAtNewest","size":16}');
        serverObj.search('{"filter":null,"term":"abc","recipient":null,"pageName":"Newsletter","sortBy":"sendAtNewest","size":16}');
                         
        Map<Id,CollaborationGroup> getListedCollabGrpIManage = serverObj.getListedCollabGrpIManageMap();
        Set<Id> contentIdSet = new Set<Id>{};
        Map<Id,Simpplr_Content__c> contentid = serverObj.getContentMap(contentIdSet);
        newsletter.Status__c = 'Draft';
        update newsletter; 
        serverObj.editNewsletter(newsletter.Id);
        newsletter.Status__c = 'On Hold';
        update newsletter; 
        serverObj.editNewsletter(newsletter.Id);
        UserContext.hasModifyAllDataPermission = false;
        UserContext.hasManageUnlistedSitePermission = true;
        serverObj.getListedCollabGrpIManageMap();
        UserContext.hasManageUnlistedSitePermission = false;
        UserContext.isUserAppModerator = true;
        serverObj.getListedCollabGrpIManageMap();
        UserContext.isUserAppModerator = false;
        serverObj.getListedCollabGrpIManageMap();
        System.assertEquals('It\'s not possible to perform this action - Newsletter has already been sent',resp.message, 'Running as Expected');
        Test.stopTest();
            
    }
    
    
     @isTest static void testScheduleNewsletter() {
        init();
        simpplr_content__c contentObj = getContent();
        contentObj.Is_Deleted__c = true;
        update contentObj;
        NewsletterDataServer serverObj = new NewsletterDataServer();
        Mailer__c newsletter = getNewsletter();
        newsletter.status__c = 'd';
        update newsletter;
        Set<Id> sitesManage = UserContext.sitesIManageIdSet;
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','NewsletterDataServer');
        pgRef.getParameters().put('action', 'schedule');
        pgRef.getParameters().put('data', '{"newsletterId":"'+newsletter.Id+'","itemData":{"sendAt":"2016-10-13T23:00:00","isScheduled":true,"listOfItems":[],"recipient":"site","site":{"isAccessRequested":false,"aboutUrl":null,"siteId":"'+newsletter.Site__c+'","canCreateAlbum":false,"isManager":false,"img":null,"isMember":false,"canControlDashboard":false,"isListed":true,"imgThumbnail":null,"isOwner":false,"hasPages":false,"information":null,"about":null,"canCreateEvent":false,"sections":[],"url":null,"isActive":false,"slack":null,"chatterGroupId":null,"isPublic":false,"hasEvents":false,"title":"Second Site","isFeatured":false,"isFeedEnabled":false,"isPrivate":true,"members":0,"id":"'+newsletter.Site__c+'","canCreatePage":false,"description":null,"isFavorited":false,"category":null,"hasAlbums":false,"hasContent":false}}}');
        Test.setCurrentPage(pgRef);        
        serverObj.handleRequest();
        String futureDateTimeStr = DateTime.Now().addDays(2).format('yyyy-MM-dd\'T\'HH:mm:ss');
        pgRef.getParameters().put('data', '{"newsletterId":"'+newsletter.Id+'","itemData":{"sendAt":"'+futureDateTimeStr+'","isScheduled":true,"listOfItems":[],"recipient":"site","site":{"isAccessRequested":false,"aboutUrl":null,"siteId":"'+newsletter.Site__c+'","canCreateAlbum":false,"isManager":false,"img":null,"isMember":false,"canControlDashboard":false,"isListed":true,"imgThumbnail":null,"isOwner":false,"hasPages":false,"information":null,"about":null,"canCreateEvent":false,"sections":[],"url":null,"isActive":false,"slack":null,"chatterGroupId":null,"isPublic":false,"hasEvents":false,"title":"Second Site","isFeatured":false,"isFeedEnabled":false,"isPrivate":true,"members":0,"id":"'+newsletter.Site__c+'","canCreatePage":false,"description":null,"isFavorited":false,"category":null,"hasAlbums":false,"hasContent":false}}}');
        Test.setCurrentPage(pgRef);        
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status, 'Running as Expected');
        
	}
	@isTest 
	static void testConvertContentToWrapper() {  	
        init();                     
        NewsletterDataServer serverObj = new NewsletterDataServer(); 
        
        Simpplr_Content__c contentRecord = getContent();
        contentRecord.Status__c = 'Draft';
        contentRecord.Type__c = 'Page';
        update contentRecord;
        String siteIManageId = getSite().Id;    
        Set<Id> sitesIManageIdSet = new Set<Id>{siteIManageId};   
        Set<Id> sitesIManageContentsIdSet = new Set<Id>{siteIManageId};   
        List<Simpplr_Content__c> recordsList = new List<Simpplr_Content__c>{contentRecord}; 
        Map<String, String> contentIdSentDateMap = new Map<String,String>{contentRecord.Id=>'02 Jan 2040'};           
        ContentWrapper resp = serverObj.convertContentToWrapper(contentRecord, sitesIManageIdSet, sitesIManageContentsIdSet, contentIdSentDateMap); 
        List<ContentWrapper> contentWrapperlist = serverObj.convertContentsListTowrapperList(recordsList,contentIdSentDateMap); 
        contentRecord.Status__c = 'Draft';
        contentRecord.Type__c = 'Page';
        update contentRecord;
        recordsList = new List<Simpplr_Content__c>{contentRecord}; 
        serverObj.convertContentsListTowrapperList(recordsList,contentIdSentDateMap); 
        contentRecord.Status__c = 'Rejected';
        contentRecord.Type__c = 'Album';
        update contentRecord;
        recordsList = new List<Simpplr_Content__c>{contentRecord}; 
        serverObj.convertContentsListTowrapperList(recordsList,contentIdSentDateMap); 
        contentRecord.Status__c = 'Submitted';
        contentRecord.Type__c = 'BlogPost';
        update contentRecord;
        recordsList = new List<Simpplr_Content__c>{contentRecord}; 
        serverObj.convertContentsListTowrapperList(recordsList,contentIdSentDateMap); 
        
        System.assertEquals(1,contentWrapperlist.size(), 'Running as Expected');
            
	}
      
            
	@isTest 
	static void testGetNewsletterListFromCriteria() {  	
           init();                      
           NewsletterDataServer serverObj = new NewsletterDataServer();           
           String filter = 'everyone';
           String recipient = null;
           String searchText = 'Test';
           String orderBy = 'Id';
           String order = 'ASC';
           Integer recordLimit = 10;
           Integer offsetVal = 10;
           Simpplr_Site__c simpplrsite = getSite(); 
           String siteIManageId =  simpplrsite.Id; 
           Map<Id,Simpplr_Site__c> siteMap = new Map<Id,Simpplr_Site__c>{siteIManageId=>simpplrsite};
           List<Mailer__c> resp = serverObj.getNewsletterListFromCriteria(filter,recipient,searchText,orderBy,order,recordLimit,offsetVal,siteMap);         
           System.assertEquals(0,resp.size(), 'Running as Expected');
      }
      
      @isTest static void testConvertNewsletterListTowrapperList() {  	
	      init();                      
	      NewsletterDataServer serverObj = new NewsletterDataServer();      
          Mailer__c newsletter = getNewsletter();
          newsletter.Recipient__c = 'audience';
	      Simpplr_Content__c contentRecord = getContent(); 
	      List<Mailer__c> newsletterList = new List<Mailer__c>{newsletter};
	      Map<Id,Simpplr_Content__c> contentIdToContentMap = new Map<Id,Simpplr_Content__c>{contentRecord.Id=>contentRecord};
	      List<NewsletterListingWrapper> newsletterLiist=  serverObj.convertNewsletterListTowrapperList(newsletterList);       
	      System.assertEquals('audience',newsletterLiist[0].recipient, 'Running as Expected');
      }
    
   
}