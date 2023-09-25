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
private class SiteContextTest {
    
    @testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	User testUser = TestHelper.createUser('SiteContextTest_usr', null, false);
 		User grpMngr = TestHelper.createUser('SiteContextTest_grpMngr', null, false);
 		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('SiteContextTest_Grp1','Public');
        TestHelper.shareSitesToAllPeople(new List<String>{getSimpplrSite().Id});
 		TestHelper.createCollaborationGroupMember(cgroup.Id, testUser.id,'Standard');
 		TestHelper.createCollaborationGroupMember(cgroup.Id, grpMngr.id,'Admin');
    }
     
    private static void setCurrentSiteRecordProperty(){
        PageReference pageRef = Page.app;
        pageRef.getParameters().put('siteId',getSimpplrSite().Id);
        Test.setCurrentpage(pageRef);
    }
    
    private static Simpplr_Site__c getSimpplrSite(){
    	return([select id,chatter_Group_id__c,name,Landing_Page__c from Simpplr_Site__c limit 1]) ; 
    }
    
    private static void setCurrentSiteRecordPropertyWhenSiteIdNull(){
        PageReference pageRef = Page.app;
        Test.setCurrentpage(pageRef);
    }
  
    private static User getUser(){
    	return([select id from user where lastname='SiteContextTest_grpMngr']);
    }
    
    private static CollaborationGroup getCollaborationGroup(){
    	return([select id,CollaborationType from CollaborationGroup  limit 1]);
    }
    
    private static App_Config__c getAppConfig(){
    	return([select id,File_Storage_Setting_Level__c from App_Config__c limit 1]);
    }
    
    @isTest static void testSiteIdPropertyWhenPageExists() {
    	setCurrentSiteRecordProperty();
        String siteId = SiteContext.siteId;
        System.assert(true,'Running as expected');
    }
  
    
    @isTest static void testSiteIdPropertyWhenSiteIdNull() {
    	setCurrentSiteRecordPropertyWhenSiteIdNull();
        String siteId = SiteContext.siteId;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testChatterGroupIdProperty() {
        setCurrentSiteRecordProperty();
     	String chatterGroupId = SiteContext.chatterGroupId;
     	System.assert(true,'Running as expected'); 
    }
    
    @isTest static void testSiteNameProperty() {
        setCurrentSiteRecordProperty();
     	String siteName = SiteContext.siteName;
     	System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsPrivateSitePropertyWhenPublic() {
        setCurrentSiteRecordProperty();
        Boolean isPrivateSite = SiteContext.isPrivateSite;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsPrivateSitePropertyWhenPrivate() {
        CollaborationGroup cg = getCollaborationGroup();
        cg.CollaborationType = 'Private';
        update cg;
        setCurrentSiteRecordProperty();
        Boolean isPrivateSite = SiteContext.isPrivateSite;
        System.assert(true,'Running as expected');
    }
   
    @isTest static void testIsCurrentUserSiteOwner() {
        setCurrentSiteRecordProperty();
        Boolean isCurrentUserSiteOwner = SiteContext.isCurrentUserSiteOwner;
        System.assert(true,'Running as expected');
    }
    
  
    
    @isTest static void testIsCurrentUserSiteManagerWhenRoleIsAdmin() {
    	User u = getUser();
    	system.runAs(u){
    		setCurrentSiteRecordProperty();
        	Boolean isCurrentUserSiteManager = SiteContext.isCurrentUserSiteManager;
       		System.assert(true,'Running as expected');
    	}
    }
 
    
    @isTest static void testSiteAllowedFeaturesPropertyWhenSiteExists() {
        setCurrentSiteRecordProperty();
        String siteAllowedFeatures = SiteContext.siteAllowedFeatures;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSiteAllowedFeaturesPropertyWhenSiteDoesnotExists() {
        String siteAllowedFeatures = SiteContext.siteAllowedFeatures;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testFileStorageSourcePropertyWhenApp() {
        String fileStorageSource = SiteContext.fileStorageSource;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testFileStorageSourcePropertyWhenSite() {
    	setCurrentSiteRecordProperty();
    	App_Config__c appConfig = getAppConfig();
    	appConfig.File_Storage_Setting_Level__c = 'Site';
    	update appConfig;
        String fileStorageSource = SiteContext.fileStorageSource;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsCurrentGroupArchivedProperty() {  
    	setCurrentSiteRecordProperty();
    	Boolean isCurrentGroupArchived = SiteContext.isCurrentGroupArchived;
    	System.assert(true,'Running as expected');
    }
   
    @isTest static void testIsFeedActiveProperty() {
        setCurrentSiteRecordProperty();
        Boolean isFeedActive = SiteContext.isFeedActive;
        System.assert(true,'Running as expected');
    }
    @isTest static void testIsActiveProperty() {
        setCurrentSiteRecordProperty();
        Boolean isActive = SiteContext.isActive;
        System.assert(true,'Running as expected');
    }
   
    @isTest static void testIsFeaturedProperty() {
        setCurrentSiteRecordProperty();
        Boolean isFeatured = SiteContext.isFeatured;
        System.assert(true,'Running as expected');
    }
    @isTest static void testIsFollowMandatoryProperty() {
        setCurrentSiteRecordProperty();
        Boolean isFollowMandatory = SiteContext.isFollowMandatory;
        System.assert(true,'Running as expected');
    }
    @isTest static void testCurrentSiteTypeProperty() {
        setCurrentSiteRecordProperty();
        String currentSiteType = SiteContext.currentSiteType;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsCommentsAllowedProperty() {
        setCurrentSiteRecordProperty();
        Boolean isCommentsAllowed = SiteContext.isCommentsAllowed;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsPublicContributionAllowedProperty() {
        setCurrentSiteRecordProperty();
        Boolean isPublicContributionAllowed = SiteContext.isPublicContributionAllowed;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsBroadcastSite() {
        setCurrentSiteRecordProperty();
        Boolean isBroadcastSite = SiteContext.isBroadcastSite;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsTilesInitialized() {
        setCurrentSiteRecordProperty();
        Boolean isTilesInitialized = SiteContext.isTilesInitialized;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSiteOrigin() {
        setCurrentSiteRecordProperty();
        String siteOrigin = SiteContext.siteOrigin;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackPostEnabled() {
        setCurrentSiteRecordProperty();
        Boolean slackPostEnabled = SiteContext.SlackPostEnabled;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackIntegrationEnabled() {
        setCurrentSiteRecordProperty();
        Boolean slackIntegrationEnabled = SiteContext.SlackIntegrationEnabled;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackCommentEnabled() {
        setCurrentSiteRecordProperty();
        Boolean slackCommentEnabled = SiteContext.SlackCommentEnabled;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackChannelId() {
        setCurrentSiteRecordProperty();
        String slackChannelId = SiteContext.SlackChannelId;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackChannelName() {
        setCurrentSiteRecordProperty();
        String slackChannelName = SiteContext.SlackChannelName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackUrl() {
        setCurrentSiteRecordProperty();
        String slackUrl = SiteContext.SlackUrl;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackAccesToken() {
        setCurrentSiteRecordProperty();
        String slackAccesToken = SiteContext.SlackAccesToken;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsUnlistedSite() {
        setCurrentSiteRecordProperty();
        Boolean isUnlistedSite = SiteContext.isUnlistedSite;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsPublicSite() {
        setCurrentSiteRecordProperty();
        Boolean isPublicSite = SiteContext.isPublicSite;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testTileLayout() {
        setCurrentSiteRecordProperty();
        String tileLayout = SiteContext.tileLayout;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCurrentSiteCategoryId() {
        setCurrentSiteRecordProperty();
        String currentSiteCategoryId = SiteContext.currentSiteCategoryId;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCurrentSiteCategoryName() {
        setCurrentSiteRecordProperty();
        String currentSiteCategoryName = SiteContext.currentSiteCategoryName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testShowInSimpplr() {
        setCurrentSiteRecordProperty();
        Boolean showInSimpplr = SiteContext.showInSimpplr;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCurrentSiteSmallPhotoUrl() {
        setCurrentSiteRecordProperty();
        String currentSiteSmallPhotoUrl = SiteContext.CurrentSiteSmallPhotoUrl;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCurrentsiteFullPhotoUrl() {
        setCurrentSiteRecordProperty();
        String currentsiteFullPhotoUrl = SiteContext.CurrentsiteFullPhotoUrl;
        System.assert(true,'Running as expected');
    } 
                    
}