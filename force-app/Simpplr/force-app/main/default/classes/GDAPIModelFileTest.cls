/**
 * This class contains unit tests for validating the behavior of Apex class GDAPIModelFile
 */
@isTest
private class GDAPIModelFileTest {

    static GDAPIModelFile createFile () {
    	GDAPIModelUser user = GDAPITestDataFactory.createUser('Test User',true,'345986644745126843664',
    								'test@test.com','https://google.com/photo.jpg');
		GDAPIModelFile file = GDAPITestDataFactory.createfile();
		file = new GDAPIModelFile();
		String fileString = '{"id":"j34l25g6fjj342kkf7u","name":"name","mimeType":"mimeType",'+
							'"description":"description","starred":true,"trashed":false,'+
							'"explicitlyTrashed":false,"parents":["parent1","parent2"],'+
							'"properties":{"key1":"value1"},"appProperties":{"key1":"value1"},'+
							'"spaces":["sapce1","space2"],"version":1,"webContentLink":"https://www.goog.com",'+
							'"iconLink":"https://www.goog.com/icon","webViewLink":"https://www.goog.com",'+
							'"thumbnailLink":"https://www.goog.com/thumbnail.jpg","viewedByMe":true,'+
							'"viewedByMeTime":"2017-06-06T10:03:03.000Z","createdTime":"2017-06-06T10:03:03.000Z",'+
							'"modifiedTime":"2017-06-06T10:03:03.000Z","modifiedByMeTime":"2017-06-06T10:03:03.000Z",'+
							'"sharedWithMeTime":"2017-06-06T10:03:03.000Z","sharingUser":'+ JSON.serialize(user)+','+
							'"owners":['+ JSON.serialize(user)+'],"lastModifyingUser":'+ JSON.serialize(user)+','+
							'"shared":true,"ownedByMe":true,"viewersCanCopyContent":true,"writersCanShare":true,'+
							'"permissions":[{"id":"kj4jk53ii64joo6o2o8k5",'+
											'"type":"user",'+
											'"expirationTime":"2017-06-06T10:03:03.000Z",'+
											'"emailAddress":"test@test.com",'+
											'"domain":"test.com",'+
											'"allowFileDiscovery":true,'+
											'"role":"writer",'+
											'"displayName":"displayName",'+
											'"photoLink":"https://www.test.com/test.jpeg",'+
											'"teamDrivePermissionDetails":[{"teamDrivePermissionType":"file member",'+
																	'"role":"writer",'+
																	'"inheritedFrom":"kj4jk53ii64joo6o2o8k5",'+
																	'"inherited":true}]}],'+
							'"folderColorRgb":"#ff0000","originalFilename":"originalFilename",'+
							'"fullFileExtension":".doc","fileExtension":"doc","md5Checksum":"md5Checksum",'+
							'"size":5432,"quotaBytesUsed":1234,"headRevisionId":"kjj234jjh5432i43everd",'+
							'"contentHints":{"thumbNail":{"image":'+JSON.serializePretty(Blob.valueof('String to blob'))+
										',"mimeType":"image/ruster"},"indexableText":"this is indexableText"},'+
							'"imageMediaMetadata":{"width":"22","height":11,"rotation":11,'+
										'"LocationModel":{"latitude":2.0967202,"longitude":2.3456,"altitude":3.06700},'+
										'"takentime":"2017-06-06T10:03:03.000Z","cameraMake":"canon",'+
										'"cameraModel":"canon-dslr","exposureTime":2.456,"aperture":9.4545,'+
										'"flashUsed":true,"focalLength":2.456,"isoSpeed":9,'+
										'"meteringMode":"meteringMode","sensor":"sensor",'+
										'"exposureMode":"exposureMode","colorSpace":"colorSpace",'+
										'"whiteBalance":"whiteBalance","exposureBias":1.45476,'+
										'"maxApertureValue":1.67,"subjectDistance":1,"lens":"lens"},'+
							'"videoMediaMetadata":{"width":2,"height":1,"durationMillis":92402325234525452},'+			
							'"capabilities":'+ JSON.serialize(GDAPITestDataFactory.createCapabilities()) +','+
							'"isAppAuthorized":true,"hasThumbnail":true,"thumbnailVersion":1,'+
							'"modifiedByMe":true,"trashingUser":'+ JSON.serialize(user)+',"teamDriveId":"k4j25n23k4",'+
							'"trashedTime":"2017-06-06T10:03:03.000Z","hasAugmentedPermissions":true,"eTag":"eTag"}';
	    file = (GDAPIModelFile)JSON.deserialize(fileString,GDAPIModelFile.class);
	    return file;
	}
	
	@isTest static void GDAPIModelFileListTest() {
    	GDAPIModelFile file = createFile();
    	GDAPIModelFileList fileListObj = new GDAPIModelFileList();
    	String fileListString = '{"files":['+ JSON.serialize(file) +'],"incompleteSearch":true}';
	    fileListObj = (GDAPIModelFileList)JSON.deserialize(fileListString,GDAPIModelFileList.class);
        System.assertEquals(fileListObj.getFiles().size(),1 );
        System.assertEquals(fileListObj.getIncompleteSearch(),true );
    }
    
    @isTest static void getIdTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getId(),'j34l25g6fjj342kkf7u');
    }
    
    @isTest static void getNameTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getName(),'name');
    }
    
    @isTest static void getSizeTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getSize(),5432);
    }
    
    @isTest static void getMimeTypeTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getMimeType(),'mimeType');
    }
    
    @isTest static void getDescriptionTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getDescription(),'description');
    }
    
    @isTest static void getWebContentLinkTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getWebContentLink(),'https://www.goog.com');
    }
    
    @isTest static void getParentsTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getParents(),new List<String>{'parent1','parent2'});
    }
    
    @isTest static void getThumbnailLinkTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getThumbnailLink(),'https://www.goog.com/thumbnail.jpg');
    }
    
    @isTest static void getWebViewLinkTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getWebViewLink(),'https://www.goog.com');
    }
    
    @isTest static void getOwnersTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getOwners().size(),1);
    }
    
    @isTest static void getStarredTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getStarred(),true);
    }
    
    @isTest static void getTrashedTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getTrashed(),false);
    }
    
    @isTest static void getExplicitlyTrashedTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getExplicitlyTrashed(),false);
    }
    
    @isTest static void getPropertiesTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getProperties().get('key1'),'value1');
    }
    
    @isTest static void getAppPropertiesTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getAppProperties().get('key1'),'value1');
    }
    
    @isTest static void getModifiedTimeTest() {
        GDAPIModelFile file = createFile();
        System.assertEquals(file.getModifiedTime(),DateTime.newInstanceGmt(2017, 6, 6, 10, 3, 3));
    }
    
    @isTest static void getCapabilitiesTest() {
        GDAPIModelFile file = createFile();
        GDAPIModelFile.Capabilities capabilities = file.getCapabilities();
	    System.assertEquals(capabilities.getCanEdit(),true);
		System.assertEquals(capabilities.getCanDelete(),true);	
		System.assertEquals(capabilities.getCanRename(),true);							
		System.assertEquals(capabilities.getCanTrash(),true);						
		System.assertEquals(capabilities.getCanShare(),true);
	    System.assertEquals(capabilities.getCanAddChildren(),true);
    }
    
    @isTest static void locationModelTest() {
        GDAPIModelFile.LocationModel lmObj = new GDAPIModelFile.LocationModel();
        String lmString = '{"latitude":2.0967202,"longitude":2.3456,"altitude":3.06700}';
        lmObj = (GDAPIModelFile.LocationModel)JSON.deserialize(lmString,GDAPIModelFile.LocationModel.class);
        System.assertEquals(lmObj.getLatitude(),Double.valueOf(2.0967202));
        lmObj.setLatitude(Double.valueOf(2.09));
        System.assertEquals(lmObj.getLatitude(),Double.valueOf(2.09));
        System.assertEquals(lmObj.getlongitude(),Double.valueOf(2.3456));
        lmObj.setlongitude(Double.valueOf(2.56));
        System.assertEquals(lmObj.getlongitude(),Double.valueOf(2.56));
        System.assertEquals(lmObj.getaltitude(),Double.valueOf(3.06700));
        lmObj.setaltitude(Double.valueOf(2.09));
        System.assertEquals(lmObj.getaltitude(),Double.valueOf(2.09));
    }
    
    @isTest static void videoMediaMetadataModelTest() {
        GDAPIModelFile.VideoMediaMetadataModel vmObj = new GDAPIModelFile.VideoMediaMetadataModel();
        String vmObjString = '{"width":2,"height":1,"durationMillis":92402325234525452}';
        vmObj = (GDAPIModelFile.VideoMediaMetadataModel)
        		JSON.deserialize(vmObjString,GDAPIModelFile.VideoMediaMetadataModel.class);
        System.assertEquals(vmObj.getWidth(),2);
        vmObj.setWidth(1);
        System.assertEquals(vmObj.getWidth(),1);
        System.assertEquals(vmObj.getHeight(),1);
        vmObj.setHeight(2);
        System.assertEquals(vmObj.getHeight(),2);
        System.assertEquals(vmObj.getDurationMillis(),Long.valueOf('92402325234525452'));
        vmObj.setDurationMillis(Long.valueOf('9240232523452'));
        System.assertEquals(vmObj.getDurationMillis(),Long.valueOf('9240232523452'));
    }
    
}