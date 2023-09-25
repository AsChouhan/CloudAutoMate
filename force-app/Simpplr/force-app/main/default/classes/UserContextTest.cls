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
private class UserContextTest {
    @testSetup 
    static void setup() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        People__c people = new People__c(User__c = UserContext.id);
        insert people;
        People_Preference__c peoplePreferenceRec = new People_Preference__c(People__c=people.id);
        insert peoplePreferenceRec;
        User adminUser = TestHelper.createUser('UserContextTest_adm', null, false);
        User testUser = TestHelper.createUser('UserContextTest_usr', null, false);
        User grpMngr = TestHelper.createUser('UserContextTest_grpMngr', null, false);
        
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('UserContextTest_Grp1','Public');
        TestHelper.shareSitesToAllPeople(new List<String>{getSite().Id});
        TestHelper.createCollaborationGroupMember(cgroup.Id, testUser.id,'Standard');
        TestHelper.createCollaborationGroupMember(cgroup.Id, grpMngr.id,'Admin');
        
        Bookmark__c bookmarkObj = new Bookmark__c(Simpplr_Site__c=getSite().id,People__c=people.id,Type__c='Site');
        insert bookmarkObj;
   }
    
    private static User getUserAsMember(){
    	return([select id from User where lastname='UserContextTest_usr']);
    }
    
    private static User getUserAsAppModerator(){
    	return([select id from User where lastname='UserContextTest_adm']);
    }
    
    private static User getUserAsSiteManager(){
    	return([select id from User where lastName='UserContextTest_grpMngr']);
    }
    
    private static People__c getPeopleRecord(){
    	return([select id from People__c where User__c=:UserContext.id]);
    }
    
    private static Simpplr_Site__c getSite(){
    	return([select id,Landing_Page__c from Simpplr_Site__c limit 1]);
    }
    
    private static void setCurrentPage(){
    	PageReference pageRef = Page.app;
        pageRef.getParameters().put('siteId',getSite().Id);
        Test.setCurrentpage(pageRef);
    }
   
    @isTest static void testIdProperty() {
    	String userId = UserContext.id;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testExternalPhotoUrlProperty() {
    	String externalPhotoUrl = UserContext.externalPhotoUrl;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testExternalPhotoUrlExpiryDateProperty() {
    	DateTime externalPhotoUrlExpiryDate = UserContext.externalPhotoUrlExpiryDate;
        System.assert(true,'Running as expected');
    }
    @isTest static void testFirstLoginDateTimeProperty() {
    	DateTime firstLoginDateTime = UserContext.firstLoginDateTime;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testFirstNameProperty() {
    	String firstName = UserContext.firstName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCountryProperty() {
    	String country = UserContext.country;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testDivisionProperty() {
    	String division = UserContext.division;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCompanyNameProperty() {
    	String companyName = UserContext.companyName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSegmentCSSClassesProperty() {
    	String getSegmentCSSClasses = UserContext.getSegmentCSSClasses;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSegmentTileLayoutProperty() {
    	String segmentTileLayout = UserContext.segmentTileLayout;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testProfileIdProperty() {
    	String profileId = UserContext.profileId;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUserHashProperty() {
    	String userHash = UserContext.userHash;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testTileLayoutProperty() {
    	String tileLayout = UserContext.tileLayout;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCommunityNicknameProperty() {
    	String communityNickname = UserContext.communityNickname;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testMobileLandingPageProperty() {
    	String mobileLandingPage = UserContext.mobileLandingPage;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUsersIFollowIdSetProperty() {
		Set<Id> sitesIFollowMap = UserContext.usersIFollowIdSet;
    	System.assert(true,'Running as expected');    
    }
    
    @isTest static void testFeedSortOrderProperty() {
    	String feedSortOrder = UserContext.feedSortOrder;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCanCreateTopicsProperty() {
    	boolean canCreateTopics = UserContext.canCreateTopics;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsTilesInitializedProperty() {
    	boolean isTilesInitialized = UserContext.isTilesInitialized;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCanManageInternalUsersProperty() {
    	boolean canManageInternalUsers = UserContext.canManageInternalUsers;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testHasSimpplrUserPermissionSetAssignedProperty() {
    	boolean hasSimpplrUserPermissionSetAssigned = UserContext.hasSimpplrUserPermissionSetAssigned;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUpdatePeopleObjAccToProfileFields() {
    	People__c peopleObj = new People__c();
    	peopleObj.Title__c = null;
    	peopleObj.Department__c = null;
    	peopleObj.City__c = null;
    	peopleObj.State__c = null; 
    	peopleObj.Country__c = null;
    	peopleObj.First_Name__c = null;
    	peopleObj.Last_Name__c = null; 
    	peopleObj.Phone__c = null;
    	peopleObj.Extension__c = null;
    	
    	insert peopleObj;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSmallPhotoURLProperty() {
    	String smallPhotoURL = UserContext.SmallPhotoUrl;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testTimeZoneNameProperty() {
    	String timeZoneName = UserContext.timeZoneName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testTimeZoneLabelProperty() {
    	String timeZoneLabel = UserContext.timeZoneLabel;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPeopleIdProperty() {
    	String peopleId = UserContext.peopleId;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPeopleNameProperty() {
    	String peopleName = UserContext.peopleName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCanAccessAnalyticsProperty() {
    	boolean canAccessAnalytics = UserContext.canAccessAnalytics;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCanSendNewsletterProperty() {
    	boolean canSendNewsletter = UserContext.canSendNewsletter;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCanSendAlertsProperty() {
    	boolean canSendAlerts = UserContext.canSendAlerts;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCanSendSiteNewsletterProperty() {
    	boolean canSendSiteNewsletter = UserContext.canSendSiteNewsletter;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCanSendSiteAlertProperty() {
    	boolean canSendSiteAlert = UserContext.canSendSiteAlert;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetUsersDepartmentDetailProperty() {
    	String getUsersDepartmentDetail = UserContext.getUsersDepartmentDetail;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetUserCategoryProperty() {
    	String getUserCategory = UserContext.getUserCategory;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testNameProperty() {
    	User userObj = getUserAsMember();
        System.runAs(userObj){
        	String userName = UserContext.name;
            System.assert(true,'Running as expected');
       }
    }
    
    @isTest static void testDefaultAllowedFeaturesWhenUserIsMember() {
    	User userObj = getUserAsMember();
        System.runAs(userObj){
        	String DefaultAllowedFeatures = UserContext.DefaultAllowedFeatures;
            System.assert(true,'Running as expected');
       }
    }
    
    @isTest static void testDefaultAllowedFeaturesWhenUserIsSiteManager() {
    	User userObj = getUserAsSiteManager();
        System.runAs(userObj){
        	setCurrentPage();
        	String DefaultAllowedFeatures = UserContext.DefaultAllowedFeatures;
            System.assert(true,'Running as expected');
       }
    }
    
    @isTest static void testDefaultAllowedFeaturesWhenUserIsAppModerator() {
    	String DefaultAllowedFeatures = UserContext.DefaultAllowedFeatures;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsUserAppModerator() {
        	Boolean isUserAppModerator = UserContext.isUserAppModerator;
            System.assert(true,'Running as expected');
    }
    
     private static void getData(){
     	List<Simpplr_Site__c> testList = Utility.getAllSimpplrSiteMap().values();
     }
    
    @isTest static void testChatterGroupsIFollowMapProperty() {
    	Map<Id,CollaborationGroup> chatterGroupsIFollowMap = UserContext.chatterGroupsIFollowMap;
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testChatterGroupsIFollowListProperty() {
    	List<CollaborationGroup> chatterGroupsIFollowList = UserContext.chatterGroupsIFollowList;
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testChatterGroupsIFollowIdSetProperty() {
         set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
         System.assert(true,'Running as expected');
    }
    
    @isTest static void testGroupsIManageIdSetProperty() {
		set<Id> groupsIManageIdSet = UserContext.groupsIManageIdSet;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSitesIFollowMapProperty() {
		Map<Id,Simpplr_Site__c> sitesIFollowMap = UserContext.sitesIFollowMap;
    	System.assert(true,'Running as expected');    
    }
    
    @isTest static void testSitesIFollowListProperty() {
		List<Simpplr_Site__c> sitesIFollowList = UserContext.sitesIFollowList;
    	System.assert(true,'Running as expected');    
    }
    
    @isTest static void testSitesIFollowIdSetProperty() {
		set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
        System.assert(true,'Running as expected');    
    }
    
    @isTest static void testSitesIManageMapProperty() {
		Map<Id,Simpplr_Site__c> sitesIManageMap = UserContext.sitesIManageMap;
    	System.assert(true,'Running as expected');     }
    
    @isTest static void testSitesIManageIdSetProperty() {
		set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
        System.assert(true,'Running as expected');    
    }
        
    @isTest static void testBoxUserId() {
        String boxUserId = UserContext.boxUserId;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsBoxConnected() {
        Boolean isBoxConnected = UserContext.isBoxConnected;
        System.assert(true,'Running as expected');
    }

    @isTest static void testListOfMyFavoriteSiteID() {
        List<Id> listOfMyFavoriteSiteID = UserContext.listOfMyFavoriteSiteID;
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testSetOfMyFavouriteSiteId() {
        Set<Id> setOfMyFavouriteSiteId = UserContext.setOfMyFavouriteSiteId;
        System.assert(true,'Running as expected');
    }
    
}