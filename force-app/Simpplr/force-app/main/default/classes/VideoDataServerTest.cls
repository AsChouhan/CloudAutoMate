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
public class VideoDataServerTest {
    private static PageReference pageRef;

    @testSetup static void setup() {
        TestHelper.setupAppConfig(); 
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        People_Preference__c prefObj = TestHelper.createPeoplePreference(peopleObj.id);
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('VideoDataServer_CollabGrp', 'Public');
        
        Simpplr_Site__c testSite = TestHelper.getSiteRecord(collGrp.Id);
        Simpplr_Content__c simpplrContent = TestHelper.createContent('VideoDataServer Event', 'Event', 'Approved', testAdminUser, testSite);
        File__c fileObj = TestHelper.createContentTitleImage(simpplrContent.Id);
        List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'native_video'});
        List<People_Integration__c> peopleIntegList = TestHelper.createPeopleIntegrationRecords(appIntegList, UserContext.peopleId, 'native_video');
    }
    
    private static void init() {   
        SimpplrContext.isNativeVideo = true;     
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','VideoDataServer');
        Test.setCurrentPage(pageRef);
    }
   
    
    private static User getAdminUser(){
        User userObj = [select id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
                        from User where profile.name ='System Administrator' and lastname='Simpplr_admin' LIMIT 1];
        return userObj;
    }

    @isTest static void testGetVideoReferences() {
        String siteId = [Select id From Simpplr_Site__c where name ='VideoDataServer_CollabGrp'][0].id;
        Simpplr_Content__c contentObj = [Select id From Simpplr_Content__c where title__c= 'VideoDataServer Event' limit 1];
        File__c fileObj = [Select id, external_Id__c, Repository__c, Is_Deleted__c  from File__c Where Simpplr_Content__c =: contentObj.id limit 1];
        fileObj.External_Id__c = '0000';
        fileObj.Repository__c = 'native_video';
        fileObj.Is_Deleted__c = false;
        fileObj.site__c = siteId;
        update fileObj;
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','getVideoReferences');
        pageRef.getParameters().put('data', '{"entryId":"0000","size":"4"}');
        Test.setCurrentPage(pageRef);
        VideoDataServer dSObject= new VideoDataServer();
        dSObject.handleRequest();
        fileObj.Simpplr_Content__c = null;
        fileObj.Feed_Item__c = '1111';
        update fileObj;
        dSObject.handleRequest();
        Test.setCurrentPage(pageRef);
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testAddVideoToCategory() {
        String siteId = [Select id From Simpplr_Site__c where name ='VideoDataServer_CollabGrp'][0].id;
        Simpplr_Content__c contentObj = [Select id From Simpplr_Content__c where title__c= 'VideoDataServer Event' limit 1];
        Folder__c folderObj = TestHelper.createChatterFolder('Albums', null, siteId, 'Intranet', null, 'readwrite');
        File__c fileObj = [Select id from File__c Where Simpplr_Content__c =: contentObj.id limit 1];
        fileObj.External_Id__c = '0000';
        update fileObj;
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','addVideoToCategory');
        pageRef.getParameters().put('data', '{"siteId":null,"mediaParams":{"mediaType":1,"conversionQuality":13556963,"sourceType":"1","dataUrl":"https://cdnapisec.kaltura.com/p/3094483/sp/309448300/playManifest/entryId/1_nuejey27/format/url/protocol/https","plays":0,"views":0,"duration":0,"msDuration":0,"id":"1_nuejey27","name":"Cl-3 Keyboard video.mp4","description":"","partnerId":3094483,"userId":"00D4W0000053bFXUAYa114W00000L41HqQAJ","creatorId":"00D4W0000053bFXUAYa114W00000L41HqQAJ","status":1,"moderationStatus":6,"moderationCount":0,"type":1,"createdAt":1607253028,"updatedAt":1607253029,"rank":0,"totalRank":0,"votes":0,"downloadUrl":"https://cdnapisec.kaltura.com/p/3094483/sp/309448300/playManifest/entryId/1_nuejey27/format/download/protocol/https/flavorParamIds/0","searchText":"_PAR_ONLY_ _3094483_ _MEDIA_TYPE_1|  Cl-3 Keyboard video.mp4 ","licenseType":-1,"version":0,"thumbnailUrl":"https://cfvod.kaltura.com/p/3094483/sp/309448300/thumbnail/entry_id/1_nuejey27/version/0","accessControlId":3663253,"replacementStatus":0,"partnerSortValue":0,"conversionProfileId":13556963,"rootEntryId":"1_nuejey27","operationAttributes":[],"entitledUsersEdit":"","entitledUsersPublish":"","entitledUsersView":"","capabilities":"","displayInSearch":1,"objectType":"KalturaMediaEntry"},"uploadedVideoParams":{"id":"1_06b8663b4afbc15d277a714a5376f75c","partnerId":3094483,"userId":"00D4W0000053bFXUAYa114W00000L41HqQAJ","status":2,"fileName":"Cl-3 Keyboard video.mp4","fileSize":"5976533","uploadedFileSize":"5976533","createdAt":1607253000,"updatedAt":1607253028,"uploadUrl":"https://ny-upload.kaltura.com","autoFinalize":false,"objectType":"KalturaUploadToken"}}');
        Test.setCurrentPage(pageRef);
        VideoDataServer dSObject= new VideoDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/Videos',false));
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        pageRef.getParameters().put('action','addToFolder');
        pageRef.getParameters().put('data','{"siteId":"'+siteId+'","directory":"'+folderObj.id+'","uploadVideoResponse":{"fileSize":"19863079"},"mediaParams":{"id":"1_ohwe1e04","name":"videoplayback.mp4"}}');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        pageRef.getParameters().put('action','getThumbnail');
        pageRef.getParameters().put('entryId','1_ohwe1e04');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        pageRef.getParameters().put('action','createVideoFolders');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        pageRef.getParameters().put('data', '{"entryId": "1_ohwe1e04", "status": 2}');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','updateVideoStatus');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        pageRef.getParameters().put('action','processVideoDisable');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        pageRef.getParameters().put('action','getCaptionsLanguages');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetVideoAccessToken() {
        Test.startTest();
        init();        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'VideoDataServer/accessToken',false));
        pageRef.getParameters().put('action','getAccessToken');
        Test.setCurrentPage(pageRef);
        VideoDataServer dSObject= new VideoDataServer();  
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testRevokeSession() {
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','revokeSession');
        Test.setCurrentPage(pageRef);
        VideoDataServer dSObject= new VideoDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'VideoDataServer/accessToken',false));
        pageRef.getParameters().put('session','dummySession');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetVideoDetails() {
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','get');
        Test.setCurrentPage(pageRef);
        VideoDataServer dSObject= new VideoDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/video',false));
        dSObject.handleRequest();
        File__c fileObj = [Select id,External_Id__c from File__c limit 1];
        fileObj.External_Id__c = '1_ohwe1e04';
        update fileObj;
        pageRef.getParameters().put('data','{"id":"1_ohwe1e04"}');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();
    }

    @isTest static void testUpdateVideoCaptionStatusInfo() {
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','updateVideoCaptionStatusInfo');
        Test.setCurrentPage(pageRef);
        VideoDataServer dSObject= new VideoDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/video',false));
        dSObject.handleRequest();
        File__c fileObj = [Select id,External_Id__c from File__c limit 1];
        fileObj.External_Id__c = '1_ohwe1e04';
        update fileObj;
        pageRef.getParameters().put('data','{"entityId":"1_ohwe1e04","captionStatus":"1"}');
        dSObject.handleRequest();
        pageRef.getParameters().put('action','updateVideoFiles');
        pageRef.getParameters().put('data','{"entryIdsSet":["1_ohwe1e04"]}');
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();     
    }

    @isTest
    static void testCleanupOrphanNativeVideos(){
        File__c fileObj = [SELECT Id, External_Id__c, Repository__c, Is_Deleted__c FROM File__c LIMIT 1];
        fileObj.External_Id__c = 'native_video_external_id';
        fileObj.Repository__c = 'native_video';
        fileObj.Is_Deleted__c = false;
        update fileObj;

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/CleanupOrphanNativeVideos',false));
        BatchManageVideo videoCleanupJob = new BatchManageVideo('cleanupOrphanNativeVideos');
        Database.executeBatch(videoCleanupJob, 500);

        Test.stopTest();

        List<File__c> fileList = [SELECT Id FROM File__c WHERE External_Id__c='native_video_external_id'];
        System.assertEquals(1, fileList.size(), 'Orphan video delete');
    }
    
    @isTest static void testSearch() {
        VideoDataServer dSObject= new VideoDataServer();
        File__c fileObj = [Select id,External_Id__c,Title__c,Site__c,Author__c,is_Deleted__c,Video_provider__c from File__c limit 1];
        Simpplr_Site__c site = Testhelper.getSiteRecordWithName('VideoDataServer_CollabGrp');
        People__c people = Testhelper.getPeopleRecordForUser(UserContext.id);
        fileObj.Title__c = 'testVideo';
        fileObj.Site__c = site.id;
        fileObj.Author__c = people.id;
        fileObj.Video_provider__c= 'native_video';
        fileObj.is_Deleted__c= false;
        fileObj.External_Id__c = '1_ohwe1e04';
        update fileObj;
        
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"term":"testVideo","site":"'+site.id+'","owner":"'+people.id+'","size":5,"nextPageToken":3}');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/GetNativeVideosFromKaltura',false));
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetByIds() {
        VideoDataServer dSObject= new VideoDataServer();
        File__c fileObj = [Select id,External_Id__c,is_Deleted__c,Video_provider__c from File__c limit 1];
        fileObj.External_Id__c = '1_ohwe1e04';
        fileObj.Video_provider__c= 'native_video';
        fileObj.is_Deleted__c= false;
        update fileObj;
        
		PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','getByIds');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('ids','[\"1_ohwe1e04\"]');
        
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/GetNativeVideosFromKaltura',false));
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status,'Running as expected');
        Test.stopTest();
    }
    
	@isTest static void testGetVideoStorage() {
		SimpplrContext.isVideosManagementFeatureEnabled = true;
		SimpplrContext.isNativeVideo = true;
		VideoDataService dataServiceObj = new VideoDataService();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'VideoDataService/sendNotification',false));    
		Boolean returnValue = dataServiceObj.getVideoStorage();
		Test.stopTest();
		System.assertEquals(true, returnValue, 'Running as expected');
	}

	@isTest static void testGetVideoStorageFailure() {
		SimpplrContext.isVideosManagementFeatureEnabled = true;
		SimpplrContext.isNativeVideo = true;
		VideoDataService dataServiceObj = new VideoDataService();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',400,'BatchVideoNotifications/sendNotification',false));    
		Boolean returnValue = dataServiceObj.getVideoStorage();
		Test.stopTest();
		System.assertEquals(false, returnValue, 'Running as expected');
	}
    
    @isTest static void testsyncPeopleData() {
        SimpplrContext.isNativeVideo = true;
        VideoDataServer dataServerObj = new VideoDataServer(); 
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','VideoDataServer');
        pageRef.getParameters().put('action','syncPeopleData');
        Test.setCurrentPage(pageRef);  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'VideoDataServer/syncPeopleData',false));    
        dataServerObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success', dataServerObj.response.status, 'success');
    }
}