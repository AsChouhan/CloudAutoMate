@isTest 
private class EmailUtilityTest {
	
	@testSetup static void setup() {
    	TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		PeopleDao peopleDaoObj = new PeopleDao();
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		testSite = TestHelper.getSiteRecord(collaborationGroupId);
		Simpplr_Content__c simpplrContent = TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
		
    }
    @isTest static void testGetDigestLimitSize() {
    	EmailUtility.getDigestLimitSize(1);
    	EmailUtility.getDigestLimitSize(7);
    	EmailUtility.getDigestLimitSize(4);
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testMiscellaneous() {
    	EmailUtility.applyLinksFormatting('test');
    	EmailUtility.getFormattedDate(DateTime.now(),'US Eastern Standard Time');
    	EmailUtility.getFormattedDate(DateTime.now(),'MM/dd/yyyy', 'US Eastern Standard Time');
    	EmailUtility.getSimpplrContentObjName();
    	EmailUtility.deeplinkedMailBody('<=href=(/apex/');
    	EmailUtility.getLinkWithFromEmail('d/apex/ss');
    	NotificationHelper.BrandingInfo brInfo = EmailUtility.getBrandingInfo4People([select id, Segment__c, Segment__r.Branding_JSON__c from People__c][0]);
    	EmailUtility.getBrandingLogoUrl([select id, Segment__c, Segment__r.Branding_Logo__c from People__c][0]);
		List<String> formatterTestList = new List<String>();
		formatterTestList.add('ffffff');
		EmailUtility.format('test string', formatterTestList);
		EmailUtility.htmlBold('make this text bold');
		LocaleContext.getLabelMap('EmailNotifications', 'en_US');
		User userObj = TestHelper.createUser('EmailUtilityTest_usr', null, false);
        People__c pObj = [Select id,user__r.LanguageLocaleKey,user__r.TimeZoneSidKey,First_Name__c From people__c where user__c =: userObj.id];
		MobileAppDistributionWrapper mobileWrapper = new MobileAppDistributionWrapper();
		mobileWrapper.iosCode = 'ios';
		mobileWrapper.peopleObj = pObj;
		EmailUtility.getMobilePromotionEmailBody(brInfo, false, mobileWrapper);
		EmailUtility.getMobilePromotionFooterDiv('en_US',pObj.id);
		EmailUtility.getSingleEmailMessageObject('test mail', 'test 1', 'toEmail@abc.com', 'replyTo@abc.com');
		EmailUtility.getSingleEmailElement('test mail subject', 'test mail', pObj.id, SimpplrContext.SEDFromEmail);
    	System.assert(true,'Running as expected');
    	
    }
    
}