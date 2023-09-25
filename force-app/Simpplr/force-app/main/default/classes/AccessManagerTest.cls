/*
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
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
private class AccessManagerTest {
	
	private static App_Config__c appConfigRecord;
	private static User siteOwnr; 
	private static User siteMember;
	private static User siteAdmin;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Site__c site;
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		TestHelper.createPeopleRecordForUser(UserContext.id); 
		siteOwnr = TestHelper.createUser('AccessManagerTest_siteOwnr', null, false);
		siteMember = TestHelper.createUser('AccessManagerTest_siteMmbr', null, false);
		siteAdmin = TestHelper.createUser('AccessManagerTest_siteAdmin', null, false);
		cgroup = TestHelper.createCollaborationGroup('AccessManagerTest_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		CollaborationGroupMember cgMember1 = TestHelper.createCollaborationGroupMember(cgroup.Id, siteAdmin.id,'Admin');
	    CollaborationGroupMember cgMember2 = TestHelper.createCollaborationGroupMember(cgroup.Id, siteMember.id, 'Standard');
	    	site = TestHelper.getSiteRecordWithName('AccessManagerTest_Grp1');
			TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
	     simpplrContent = TestHelper.createContent('simpplr test Page', 'Page', 'Submitted', siteMember, site);
	}
	
    private static void init() {
    	if(appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
	    	List<User> listOfUsers = [select Id, lastName from user where lastname like 'AccessManagerTest%'];
	    	for(User userObj : listOfUsers) {
	    		if(userObj.lastName == 'AccessManagerTest_siteOwnr') {
				siteOwnr = userObj;  
	    		} else if(userObj.lastName == 'AccessManagerTest_siteMmbr') {
	    			siteMember = userObj; 
	    		} else if(userObj.lastName == 'AccessManagerTest_siteAdmin') {
	    			siteAdmin = userObj; 
	    		}
	    	}
	    	site = TestHelper.getSiteRecordWithName('AccessManagerTest_Grp1');
	    	simpplrContent = [select id, status__c from simpplr_content__c limit 1];
    	}
    }
    
    
    @isTest static void testIsUserAppModerator(){
        Test.startTest();
    	init();
        Boolean b = AccessManager.isUserAppModerator(UserContext.id);
		People__c peopleObj = [select id from People__c where user__c=:siteOwnr.id limit 1];
		peopleObj.App_Moderation_Permission__c='Yes';
		update peopleObj;
		b = AccessManager.isUserAppModerator(siteOwnr.id);
        System.assert(true,'Running as expected');
        Test.stopTest();
    } 
    
    @isTest static void testHasContentCreateAccessWhenPerSite(){
    	Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
    	
    	system.runAs(siteAdmin){
		    Boolean hasContentCreateAccess = AccessManager.hasContentCreateAccess();
		    Boolean calculatePublishUnpublishAccess = AccessManager.calculatePublishUnpublishAccess(true, false, ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'public');
		    Boolean calculateModerateAccess = AccessManager.calculateModerateAccess(true, true,
		    		ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'public');
	  		
	  		Boolean calculateDeleteAccess = AccessManager.calculateDeleteAccess(true, false,
	  					ServiceConstants.CONTENT_STATUS_REJECTED, siteAdmin.id,'unlisted');
	  		calculateDeleteAccess = AccessManager.calculateDeleteAccess(true,  false,
	  				ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'public');
	  		calculateDeleteAccess = AccessManager.calculateDeleteAccess(true,  false,
	  				ServiceConstants.CONTENT_STATUS_DRAFT, siteAdmin.id,'public');
	  		
			Boolean calculateEditAccess = AccessManager.calculateEditAccess(false, false,
	  				ServiceConstants.CONTENT_STATUS_REJECTED, siteAdmin.id, 'public');
			calculateEditAccess = AccessManager.calculateEditAccess(true, true,
	  				ServiceConstants.CONTENT_STATUS_REJECTED, siteAdmin.id, 'public');
	  		calculateEditAccess = AccessManager.calculateEditAccess(false, true,
	  				ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'public');
            calculateEditAccess = AccessManager.calculateEditAccess(false, false,
	  				ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'public');
	  		calculateEditAccess = AccessManager.calculateEditAccess(true, true,
	  				ServiceConstants.CONTENT_STATUS_DRAFT, siteAdmin.id, 'public');
            calculateEditAccess = AccessManager.calculateEditAccess(false, false,
	  				ServiceConstants.CONTENT_STATUS_DRAFT, '###', 'public');
			calculateEditAccess = AccessManager.calculateEditAccess(false, true,
	  				ServiceConstants.CONTENT_STATUS_REJECTED, siteMember.id, 'public');
	  		Boolean hasSiteAccess = AccessManager.hasSiteAccess();
	  		System.assert(true,'Running as expected');
    	}
    	Test.stopTest();
    }

	@isTest static void testCalculateAccess(){
		Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
		system.runAs(siteAdmin) {
			AccessManager.calculateBlogEditAccess(siteAdmin.id, ServiceConstants.CONTENT_STATUS_PENDING);
	  		AccessManager.calculateContentViewAccess('Page', true, site.Id, 'public', ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id);
            AccessManager.calculateContentViewAccess('Page', true, site.Id, 'unlisted', ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id);
            AccessManager.calculateContentViewAccess('BlogPost', true, site.Id, 'unlisted', ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id);
            AccessManager.calculateContentViewAccess('Page', false, site.Id, 'unlisted', ServiceConstants.CONTENT_STATUS_DRAFT, siteAdmin.id);
            AccessManager.calculateContentViewAccess('Page', false, site.Id, 'private', ServiceConstants.CONTENT_STATUS_DRAFT, siteMember.id);
			AccessManager.calculateCanMakeMustRead('Page', true,'private', true, true, true);
			System.assert(true,'Running as expected');
    	}
    	Test.stopTest();
	}
    
    @isTest static void testHasContentCreateAccessWhenAcrossApp(){
		Test.startTest();
    	init();
    	
    	PageReference pageRef = Page.SitePages;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
  		Boolean hasContentCreateAccess = AccessManager.hasContentCreateAccess();
		AccessManager.calculateCanMakeMustRead('BlogPost', true,null, false, false, false);
		AccessManager.calculateCanMakeMustRead('Page', true,'private', true, true, true);
		AccessManager.calculateCanMakeMustRead('Page', true,'public', false, false, false);
		AccessManager.calculateManageBlogAccess(UserContext.id);
  		Test.stopTest();
  		System.assert(true,'Running as expected');
    }
    
    @isTest static void testHasContentCreateAccessWhenSiteManager(){
    	Test.startTest();
		init();
		User userObj = siteAdmin;
    	Simpplr_Site__c tempSiteObj = new Simpplr_Site__c(Id = site.Id);
		tempSiteObj.Allow_Public_Contribution__c = false;
		update tempSiteObj;
  	  	system.runAs(userObj){
            AccessManager.hasUserSiteAccessForAnalytics(site.Id);
	        PageReference pageRef = Page.DataServerRW;
	        pageRef.getParameters().put('siteId',site.Id);
	        Test.setCurrentpage(pageRef);
	        Boolean hasContentCreateAccess = AccessManager.hasContentCreateAccess();
	        Boolean hasContentCreateAccessWithParameters = AccessManager.hasContentCreateAccess(site.Id,site.site_type__c,site.Allow_Public_Contribution__c);
			AccessManager.hasContentCreateAccess(site.Id,site.site_type__c,site.Allow_Public_Contribution__c, false);
  		    AccessManager.hasUserSiteAccessForAnalytics(site.Id);
			System.assert(true,'Running as expected');
  	  	}
  	  Test.stopTest();
    }
    
    @isTest static void testHasContentAccess(){
    	Test.startTest();
		init();
        appConfigRecord.Allow_Public_Contribution__c = true;
        appConfigRecord.Site_Dashboard_Mode__c = ServiceConstants.SITE_DASHBOARD_OWNER_APP_MANAGER;
        update appConfigRecord;
		User userObj = siteAdmin;
		Simpplr_Site__c tempSiteObj = new Simpplr_Site__c(Id = site.Id);
		tempSiteObj.Allow_Public_Contribution__c = false;
		update tempSiteObj;
  	  	system.runAs(userObj){
	        PageReference pageRef = Page.DataServerRW;
	        pageRef.getParameters().put('siteId',site.Id);
	        Test.setCurrentpage(pageRef);
	        Boolean hasContentCreateAccess = AccessManager.hasContentCreateAccess();
			AccessManager.hasContentCreateAccess(site.Id,site.site_type__c,site.Allow_Public_Contribution__c, false);
            AccessManager.hasContentEditAccess('Rejected',true);
			System.assert(true,'Running as expected');
  	  	}
  	  Test.stopTest();
    }
    
    @isTest static void testHasContentCreateAccessWhenMember(){
    	Test.startTest();
    	init();
		Simpplr_Site__c tempSiteObj = new Simpplr_Site__c(Id = site.Id);
		tempSiteObj.Allow_Public_Contribution__c = false;
		update tempSiteObj;
    	
  	  	system.runAs(siteMember){
	        PageReference pageRef = Page.DataServerRW;
	        pageRef.getParameters().put('siteId',site.Id);
	        Test.setCurrentpage(pageRef);
	        Boolean hasContentCreateAccess = AccessManager.hasContentCreateAccess();
	        Boolean hasContentCreateAccessWithParameters = AccessManager.hasContentCreateAccess(site.Id,site.site_type__c,site.Allow_Public_Contribution__c);
  		    Boolean calculateDeleteAccess = AccessManager.calculateDeleteAccess(false, false, ServiceConstants.CONTENT_STATUS_REJECTED, siteAdmin.id,'unlisted');
            calculateDeleteAccess = AccessManager.calculateDeleteAccess(false, false, ServiceConstants.CONTENT_STATUS_DRAFT, '###','unlisted');
            calculateDeleteAccess = AccessManager.calculateDeleteAccess(false, false, ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'unlisted');
			Boolean calculateModerateAccess = AccessManager.calculateModerateAccess(false, false, ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'public');
			Boolean calculatePublishUnpublishAccess = AccessManager.calculatePublishUnpublishAccess(false, false, ServiceConstants.CONTENT_STATUS_PENDING, siteAdmin.id,'public');
			  System.assert(true,'Running as expected');
  	  	}
  	  		Test.stopTest();
    }
    
    @isTest static void testHasContentEditAccessWhenContentStatusIsRejected(){
	Test.startTest();
    	init();
    	PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
  	  	Boolean hasContentEditAccess = AccessManager.hasContentEditAccess('Rejected',true);
		hasContentEditAccess = AccessManager.hasContentEditAccess('Rejected',false);
  	  	Test.stopTest();
  	  	System.assert(true,'Running as expected');
    }
    
    @isTest static void testHasContentEditAccessWhenPerSite(){
    	Test.startTest();
    	init();
    	Simpplr_Site__c rec = site;
	    PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',rec.Id);
	    Test.setCurrentpage(pageRef);
  		Boolean hasContentEditAccess = AccessManager.hasContentEditAccess('Submitted',false);
		AccessManager.hasUserManageSiteAccess(site.Id);
  		Test.stopTest();
  		System.assert(true,'Running as expected');
    }
    
    @isTest static void testHasContentApprovalAccessWhenSiteManager(){
    	Test.startTest();
    	init();
  	  	system.runAs(siteAdmin){
	        PageReference pageRef = Page.DataServerRW;
	        pageRef.getParameters().put('siteId',site.Id);
	        Test.setCurrentpage(pageRef);
	        Boolean hasContentApprovalAccess = AccessManager.hasContentApprovalAccess();
	        Boolean hasContentApprovalAccessWithParams = AccessManager.hasContentApprovalAccess(site.Id,'public'.equalsIgnoreCase(site.site_type__c)?true:false);
  		    Test.stopTest();
  		    System.assert(true,'Running as expected');
  	  	}    
  	}
  	
  	@isTest static void testHasContentApprovalAccessWithoutBeingSiteManagerOfPublicSite(){
    	Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('siteId',site.Id);
		Test.setCurrentpage(pageRef);
		Boolean hasContentApprovalAccess = AccessManager.hasContentApprovalAccess();
		Boolean hasContentApprovalAccessWithParams = AccessManager.hasContentApprovalAccess(String.valueOf(site.Id),'public'.equalsIgnoreCase(site.site_type__c)?true:false);
  		    Test.stopTest();
  		    System.assert(true,'Running as expected');
  	}
    
    @isTest static void testHasNewsletterAndAlertCreateAccess() {
        Test.startTest();
        init();
		PageReference pageRef = Page.DataServerRW;
		Test.setCurrentpage(pageRef);
		Boolean hasNewsletterCreateAccess = AccessManager.hasNewsletterCreateAccess(site.Id);
		hasNewsletterCreateAccess = AccessManager.hasNewsletterCreateAccess(null);
		AccessManager.hasNewsletterModerationAccess(site.Id);
		AccessManager.hasAlertCreateAccess(site.Id);
		AccessManager.hasAlertModerationAccess(site.Id);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
  	
    @isTest static void testUserAsAppModerator(){
        Test.startTest();
		init();
		Boolean b = AccessManager.hasPageAccess('MANAGE_SITE');
        Test.stopTest();
		System.assert(true,'Running as expected');
    }
  
    @isTest static void testUserAsMember(){
		Test.startTest();
		init();
		System.runAs(siteMember){
			UserContext.canSendNewsletter = true;
			UserContext.canSendAlerts = true;
			UserContext.canAccessAnalytics=true;
			Boolean b = AccessManager.hasPageAccess('MANAGE_SITE');
			b = AccessManager.hasPageAccess('NEWSLETTER');
			b = AccessManager.hasPageAccess('ANALYTICS');
			b = AccessManager.hasPageAccess('ALERT');
			AccessManager.hasContentApprovalAccess();
			AccessManager.hasContentApprovalAccess(site.Id, true);
			AccessManager.hasUserManageSiteAccess(site.Id);
			AccessManager.isUserAppModerator(siteMember.id);
			
			PageReference pageRef = Page.DataServerRW;
			pageRef.getParameters().put('siteId',site.Id);
			Test.setCurrentpage(pageRef);
			Boolean hasContentEditAccess = AccessManager.hasContentEditAccess('Submitted',false);
			AccessManager.hasUserManageSiteAccess(site.Id);
			AccessManager.hasUserSiteAccessForAnalytics(site.Id);
			AccessManager.hasContentApprovalAccess(site.Id, true);
			AccessManager.hasContentApprovalAccess();
			AccessManager.hasUserManageDashboardAccess('home');
			AccessManager.hasUserManageDashboardAccess(site.Id);
			System.assert(true,'Running as expected');
		}
		Test.stopTest();
    }
	@isTest static void testMethods() {
		Test.startTest();
		Boolean b = AccessManager.hasBrandingUpdatePermissions();
		SimpplrContext.isEmployeeAdvocacyEnabled = false;
		b = AccessManager.isMySettingExternalAppsAccessible;
		System.assert(true,'Running as expected');
		Test.stopTest();
	}
    
    @isTest static void testCalculateEditQuestionAccess(){
        Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
        system.runAs(siteAdmin){
            Boolean calculateEditQuestionAccess = AccessManager.calculateEditQuestionAccess(true, true, siteAdmin.id,'public', true);
    		System.assertEquals(true, calculateEditQuestionAccess, 'Do not have the access to edit question');
        }
        Test.stopTest();
    }
    
    @isTest static void testCalculateDeleteQuestionAccess(){
        Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
        system.runAs(siteAdmin){
            Boolean calculateDeleteQuestionAccess = AccessManager.calculateDeleteQuestionAccess(true, true, siteAdmin.id,'public', true);
    		System.assertEquals(true, calculateDeleteQuestionAccess, 'Do not have the access to delete question');
        }
        Test.stopTest();
    }
    
     @isTest static void testCalculateDuplicateQuestionAccess(){
        Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
        system.runAs(siteAdmin){
            Boolean calculateDuplicateQuestionAccess = AccessManager.calculateDuplicateQuestionAccess(true, true, siteAdmin.id,'public');
    		System.assertEquals(true, calculateDuplicateQuestionAccess, 'Do not have the access to duplicate question');
        }
        Test.stopTest();
    }
    
    @isTest static void testCalculateUnpublishQuestionAccess(){
        Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
        system.runAs(siteAdmin){
            Boolean calculateUnpublishQuestionAccess = AccessManager.calculateUnpublishQuestionAccess(true, true, siteAdmin.id,'public');
    		System.assertEquals(true, calculateUnpublishQuestionAccess, 'Do not have the access to unpublish question');
        }
        Test.stopTest();
    }
    
    @isTest static void testCalculateSiteViewAccess(){
        Test.startTest();
    	init();
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
        system.runAs(siteAdmin){
            Boolean calculateSiteViewAccess = AccessManager.calculateSiteViewAccess(site.id,'public');
            calculateSiteViewAccess = AccessManager.calculateSiteViewAccess(site.id,'unlisted');
            calculateSiteViewAccess = AccessManager.calculateSiteViewAccess(site.id,'private');
    		System.assertEquals(true, calculateSiteViewAccess, 'Do not have the access to view site');
        }
        Test.stopTest();
    }
    
     @isTest static void testCalculateCanManageOnboarding(){
        Test.startTest();
    	init();
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(UserContext.peopleId, site.Id);
		siteRoleObj.Is_Content_Manager__c = true;
        siteRoleObj.Is_Manager__c = true;
        siteRoleObj.Is_Onboarding_Content_Manager__c = true;
		update siteRoleObj;
		PageReference pageRef = Page.DataServerRW;
	    pageRef.getParameters().put('siteId',site.Id);
	    Test.setCurrentpage(pageRef);
        system.runAs(siteAdmin){
            Boolean calculateCanManageOnboarding = AccessManager.calculateCanManageOnboarding(true, site.id, true, true);
    		System.assertEquals(true, calculateCanManageOnboarding, 'Cannot manage onboarding content');
        }
        Test.stopTest();
    }

	@isTest static void testProtectFromRequestForgery(){
		Test.startTest();
		init();

		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','NotificationDataServer');
		Test.setCurrentpage(pageRef);

		System.runAs(siteAdmin){
			Boolean validToken = true;
			try{
				AccessManager.protectFromRequestForgery('NotificationDataServer');
			}catch(Exception ex){
				validToken = false;
			}
			System.assertEquals(false, validToken, 'CSRF token is invalid');

			String csrfTokenServer = AccessManager.getCsrfToken();
			AccessManager.manageCookieCsrf(csrfTokenServer);
			String cookieCsrfToken = AccessManager.readCookieCsrf();

			System.assertEquals(csrfTokenServer, cookieCsrfToken, 'CSRF token matched');

			try{
				validToken = true;
				AccessManager.validateCsrfToken(csrfTokenServer, 'NotificationDataServer');
			}catch(Exception ex){
				validToken = false;
			}
			System.assertEquals(true, validToken, 'CSRF token is valid'); 
		}

		Test.stopTest();
	}
}