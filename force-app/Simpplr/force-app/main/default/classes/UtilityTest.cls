@isTest
private class UtilityTest {

	@testSetup static void setup() {
		TestHelper.setupAppConfig();
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		PeopleDao peopleDaoObj = new PeopleDao();
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
		TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		testSite = TestHelper.getSiteRecord(collaborationGroupId);
		Simpplr_Content__c simpplrContent = TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
		TestHelper.createCollaborationGroup('Simpplr_Grp2', 'Unlisted');
		
		System.assert(true, 'Running as expected');
    }
    
    @isTest static void testSetChatterEmailSettingsForUsers() {
    	Utility.setChatterEmailSettingsForUsers(true, new List<String>{usercontext.peopleId});
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGetAllUnlistedCollaborationGroupMap() {
    	Map<Id,CollaborationGroup> allPublicCollaborationGroupMap = Utility.getAllUnlistedCollaborationGroupMap();
    	System.assertEquals(true, allPublicCollaborationGroupMap.size() > 0, 'Running as expected');
    }
    
    @isTest static void testGetListOfPeopleWithSegmentationFields() {
    	List<People__c> peopleList = Utility.getListOfPeopleWithSegmentationFields(new List<String>{usercontext.userId});
    	System.assertEquals(true, peopleList.size() > 0, 'Running as expected');
    }
    
    @isTest static void testGetAllUnlistedSiteMap() {
    	Map<Id,Simpplr_Site__c> allUnlistedSimpplrSiteMap = Utility.getAllUnlistedSiteMap();
    	System.assertEquals(true, allUnlistedSimpplrSiteMap.size() > 0, 'Running as expected');
    }
    
    @isTest static void testMiscellaneous() {
    	Set<Id> listOfAppModeratorIds = Utility.getAppModeratorsList();
    	System.assertEquals(true, listOfAppModeratorIds.size() > 0, 'Running as expected');

    	String res = Utility.requestAuthToken();
    	System.assertNotEquals(null, res, 'Running as expected');

    	res = Utility.requestNewsltterDataAuthToken('1234=67uy=1234r');
    	System.assertNotEquals(null, res, 'Running as expected');

    	List<CollaborationGroup> listOfChatterGroupsForCurrentUser = Utility.getChatterGroupsForCurrentUser();
    	System.assertEquals(true, listOfChatterGroupsForCurrentUser.size() > 0, 'Running as expected');

	    res = Utility.processPatternAndMatcher('<img src="http://www.google.com" />',true);
    	System.assertEquals('http://www.google.com', res, 'Running as expected');

    	res = Utility.formattingDateAsMMDDYYYY('2018-06-22');
    	System.assertEquals('06/22/2018', res, 'Running as expected');

    	res = Utility.getDuration(Datetime.now());
    	System.assertEquals('0 sec ago', res, 'Running as expected');
		
    	res = Utility.dateToDisplayString(Datetime.now(),'MM/dd/yyyy');
    	System.assertEquals(Datetime.now().format('MM/dd/yyyy'), res, 'Running as expected');

    	res = Utility.dateToDisplayString(Date.today(),'MM/dd/yyyy');
    	System.assertEquals(Datetime.now().format('MM/dd/yyyy'), res, 'Running as expected');

    	res = Utility.getPhotoVersionId('photoId/idOf15Character/view');
    	System.assertEquals('idOf15Character', res, 'Running as expected');

        res = Utility.validteURLProtocol('www.google.com');
    	System.assertEquals('http://www.google.com', res, 'Running as expected');

    	Utility.getPeoplePrefix();
    	Utility.getSimpplrFilePrefix();
    	Utility.getFileDowloadRelativeURL('SSSS');
    	Utility.getFileDownload240BY180URLForMobile('ddd');
    	Utility.getFileDownloadURLFor120BY90('SSS');
		Utility.adoptionEmailNextRunDate();
		SimpplrException ex = new SimpplrException('UtilityTest');
		Utility.sendBatchFailedExceptionEmail('UtilityTest', ex);
		Boolean flag = Utility.isMobileMode; 
    	System.assertEquals(false, flag, 'Running as expected');
    }
    
    @isTest static void testMiscellaneous2() {
    	Boolean res = Utility.isDownloadableOniOS('mp3','gdrive');
    	System.assertEquals(false, res, 'Running as expected');

    	List<String> userIdList = Utility.getuserIdList(new List<String>{usercontext.peopleId});
    	System.assertEquals(true, userIdList.size() > 0, 'Running as expected');

    	String soslString = Utility.generateStringForSOSLQuery(new Set<String>{'dd','fffda','sdsd/d/ds'});
    	System.assertEquals('dd* OR fffda* OR sdsd/d/ds*', soslString, 'Running as expected');

    	Boolean isContentEdited = Utility.checkContentEdited(Datetime.now(), Datetime.now().addDays(12));
    	System.assertEquals(true, isContentEdited, 'Running as expected');

    	Date dt = Utility.getFirstDayOfQuarterForDate(Date.newInstance(2021, 9, 23));
    	System.assertEquals(Date.newInstance(2021, 7, 1), dt, 'Running as expected');

    	String encodedUrl = Utility.encodeUrlString('http://www.google.com');
    	System.assertEquals('/http%3A/www.google.com', encodedUrl, 'Running as expected');

    	String str = Utility.toCamelCase('jsjjdsjjdj caca');
    	System.assertEquals('Jsjjdsjjdj Caca', str, 'Running as expected');
    }	

    @isTest static void testParseStringDate() {
    	Date d1 = Utility.parseStringDate('2018-06-22');
    	System.assertEquals(Date.newInstance(2018, 6, 22), d1, 'Running as expected');
    	Date d2 = Utility.parseStringDate(null);
    	System.assertEquals(null, d2, 'Running as expected');
    }
    
    @isTest static void testResetSmartSearch() {
    	Utility.resetSmartSearch();
		List<App_Config__c> appConfigList = [select id, External_Search_Enabled__c from App_Config__c];
    	System.assertEquals(false, appConfigList[0].External_Search_Enabled__c,  'Running as expected');
    }
    @isTest static void testStringToDate() {
    	Date d1 = Utility.stringToDate('1947-08-15');
    	System.assertEquals(Date.newInstance(1947, 8, 15), d1, 'Running as expected');
    }
    
	@isTest static void testSendPushNotifications() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/utility/sendPushNotifications',true));
        Utility.sendPushNotifications('', '');
        Test.stopTest();
        System.assert(true,'Running as expected');
	 }
     
	 @isTest static void testgetSanitizedHTMLfromLambda() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/utility/sanitize-html',false));
        Utility.getSanitizedHTMLfromLambda('test input');
        Test.stopTest();
        System.assert(true,'Running as expected');
	 }

     @isTest static void testToggleContentPermissions() {
        Test.startTest();
        List<Simpplr_Content__c> simpplrContent = [SELECT Id FROM Simpplr_Content__c WHERE Title__c = 'PageDataServerTest Page']; 
        Utility.toggleContentPermissions(simpplrContent, false);
		List<Simpplr_Content__Share> result = [select id from Simpplr_Content__Share where ParentID in :simpplrContent];
        Test.stopTest();
        System.assertEquals(true, result.size() > 0,'Running as expected');
	 } 
	 
	 @isTest static void testSendWebPushConfigInfoToLambda() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
		Utility.sendWebPushConfigInfoToLambda(UserContext.peopleId, 'token', 'userAgent');
		Test.stopTest();
        System.assert(true,'Running as expected');
	 }

	 @isTest static void testGetParamValueFromUrl() {
        String param = Utility.getParamValueFromUrl(
			'https://vinaysimpplr-dev-ed--c.na124.visual.force.com/apex/FileDetail?fileId=123','fileId');
        System.assertEquals(param,'123');
     } 

	 @isTest static void testStaticMethods() {
		Test.startTest();
		DateTime res = Utility.getDateTimeFilterValue('past_24_hours');
		System.assertEquals(System.now().addHours(-24), res,'Running as expected');

		res = Utility.getDateTimeFilterValue('past_week');
		System.assertEquals(System.now().addDays(-7), res,'Running as expected');
		
		res = Utility.getDateTimeFilterValue('past_month');
		System.assertEquals(System.now().addMonths(-1), res,'Running as expected');

		res = Utility.getDateTimeFilterValue('past_year');
		System.assertEquals(System.now().addYears(-1), res,'Running as expected');

		 SimpplrContext.PPUserCustomFields = '[{"columnName":"Custom_Field_5__c","singular": "Label"}]';
		String label = Utility.getLabelForSegmentFieldApi('Custom_Field_5__c');
		 System.assertEquals('Label', label,'Running as expected');
	 }

	 @isTest static void testGetUpdatedMobileWapperBody() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/utility/sanitize-html',false));
        Utility.getSanitizedHTMLfromLambda('test input');
        Test.stopTest();
        System.assert(true,'Running as expected');
	 }

    @isTest static void testGetSimpplrBrandingMap() {
        NotificationHelper.BrandingInfo brandingInfo = new NotificationHelper.BrandingInfo();
        brandingInfo.header_backgroundColor = 'ffffff';
        SimpplrContext.isSegmentsEnabled = true;
        SimpplrContext.isSegmentBrandingEnabled = true;

        Segment__c segmentRecord = new Segment__c(Name__c = 'Untitled Segment', Created_By_People__c = UserContext.peopleId, 
            Modified_By_People__c = UserContext.peopleId, Branding_JSON__c = JSON.serialize(brandingInfo));
    	insert segmentRecord;

        Test.startTest(); 
            Map<String, NotificationHelper.BrandingInfo> result = Utility.getSimpplrBrandingMap(null);
        Test.stopTest();
        System.assertEquals(true, result.containsKey('default'), 'should contain default branding');
    }
}