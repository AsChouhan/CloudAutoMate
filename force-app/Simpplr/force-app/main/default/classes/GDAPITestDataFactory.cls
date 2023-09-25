public with sharing class GDAPITestDataFactory {
    
    // create user 
    public static GDAPIModelUser createUser(String displayName, Boolean setMeBool, String permissionIdStr,
    											String email, String photoLink) {
	    GDAPIModelUser user = new GDAPIModelUser();
	    user.setDisplayName(displayName);
	    user.setMe(setMeBool);
	    user.setPermissionId(permissionIdStr);
	    user.setEmailAddress(email);
	    user.setPhotoLink(photoLink);
	    
	    return user;
  	}
  	
  	// create file 
    public static GDAPIModelFile createfile() {
	    GDAPIModelFile file = new GDAPIModelFile();
	    file.setId('gdrivefileexternalid');
		file.setName('GDRIVETESTFILE');	
		file.setSize(Integer.valueOf('345789'));							
		file.setMimeType('image/jpeg');								
		file.setDescription('description about file');
	    file.setOwners(new List<GDAPIModelUser>{createUser('Test User',true,'345986644745126843664','test@test.com','https://google.com/photo.jpg')});
	    file.setStarred(true);
	    file.setTrashed(false);
	    file.setParents(new List<String>{'parent1','parent2'});
	    file.setproperties(new Map<String,String>{'key1' => 'value1',
	    										  'key2' => 'value2'});
	    file.setAppProperties(new Map<String,String>{'key1' => 'value1',
	    										  'key2' => 'value2'});										  
	    
	    
	    return file;
  	}
  	
  	// create Folder 
    public static GDAPIModelFile createFolder() {
	    GDAPIModelFile file = new GDAPIModelFile();
	    file.setId('gdrivefolderexternalid');
		file.setName('GDRIVETESTFOLDER');	
		file.setMimeType('application/vnd.google-apps.folder');								
		file.setDescription('description about folder');
	    file.setStarred(true);
	    file.setTrashed(false);
	    file.setParents(new List<String>{'parent1','parent2'});
	    file.setproperties(new Map<String,String>{'key1' => 'value1',
	    										  'key2' => 'value2'});
	    file.setAppProperties(new Map<String,String>{'key1' => 'value1',
	    										  'key2' => 'value2'});										  
	    
	    
	    return file;
  	}
  	
  	// create GDAPIModelFile.Capabilities
  	public static GDAPIModelFile.Capabilities createCapabilities() {
	    GDAPIModelFile.Capabilities capabilities = new GDAPIModelFile.Capabilities();
	    capabilities.setCanEdit(true);
		capabilities.setCanDelete(true);	
		capabilities.setCanRename(true);							
		capabilities.setCanTrash(true);								
		capabilities.setCanShare(true);
	    capabilities.setCanAddChildren(true);
	    
	    return capabilities;
  	}
	
	public static String createModelFileString(String fileId, String fileName, Boolean isFolder) {
    	GDAPIModelUser user = createUser('Test User',true,'345986644745126843664',
    								'test@test.com','https://google.com/photo.jpg');
		String fileString = '{"id":"' + fileId + '","name": "' + fileName + '", "mimeType":' + 
							(isFolder ? '"application/vnd.google-apps.folder"' : '"image/jpeg"') + ','+
							'"description":"description","starred":true,"trashed":false,'+
							'"explicitlyTrashed":false,"parents":["parent1","parent2"],'+
							'"properties":{"key1":"value1"},"appProperties":{"key1":"value1"},'+
							'"spaces":["sapce1","space2"],' +
							(isFolder ? '' : 
								'"version":1,"webContentLink":"https://www.goog.com",'+
								'"iconLink":"https://www.goog.com/icon","webViewLink":"https://www.goog.com",'+
								'"thumbnailLink":"https://www.goog.com/thumbnail.jpg","viewedByMe":true,'+
								'"viewedByMeTime":"2017-06-06T10:03:03.000Z",') + 
							'"createdTime":"2017-06-06T10:03:03.000Z",'+
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
							(isFolder ? '' : 
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
								'"videoMediaMetadata":{"width":2,"height":1,"durationMillis":92402325234525452},')+			
							'"capabilities":'+ JSON.serialize(createCapabilities()) +','+
							'"isAppAuthorized":true,"hasThumbnail":true,"thumbnailVersion":1,'+
							'"modifiedByMe":true,"trashingUser":'+ JSON.serialize(user)+',"teamDriveId":"k4j25n23k4",'+
							'"trashedTime":"2017-06-06T10:03:03.000Z","hasAugmentedPermissions":true,"eTag":"eTag"}';
	    return fileString;
	}
	
	public static GDAPIModelPermission createPermission () {
		String permissionString = '{"id":"kj4jk53ii64joo6o2o8k5",'+
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
																	'"inherited":true}]}';
	    GDAPIModelPermission permission = new GDAPIModelPermission();
	    permission = (GDAPIModelPermission)JSON.deserialize(permissionString,GDAPIModelPermission.class);
	    
	    return permission;
	}
	
	public static String getRevisionString() {
		GDAPIModelUser user = createUser('Test User',true,'345986644745126843664',
											'test@test.com','https://google.com/photo.jpg');
										
		return '{"id":"kj4jk53ii64joo6o2o8k5",'+
									'"lastModifyingUser":' + JSON.serialize(user) + ','+
									'"mimeType":"image/x-cmu-raster",'+
									'"modifiedTime":"2017-06-06T10:03:03.000Z",'+
									'"keepForever":true,'+
									'"published":true,'+
									'"publishAuto":false,'+
									'"publishedOutsideDomain":false,'+
									'"originalFilename":"originalFilename",'+
									'"md5Checksum":"md5Checksum",'+
									'"size":"3459866447451"}';
	}
	
	public static String getDropboxMetadataString(Boolean isFolder, String name) {
		return '{"name": "' + name + '",' +
				'".tag": ' + (isFolder ? '"folder",' : '"file",') + 
	            '"id": "id:a4ayc_80_OEAAAAAAAAAXw",' +
	            (isFolder ? '' : 
	            	'"client_modified": "2015-05-12T15:50:38Z",'+
	            	'"server_modified": "2015-05-12T15:50:38Z",'+
	            	'"rev": "a1c10ce0dd78",'+
	            	'"size": 7212,') + 
	            '"path_lower": "/homework/math/' + name.toLowerCase() + '",'+
	            '"path_display": "/Homework/math/' + name + '",'+
	            '"sharing_info": {'+
	                '"read_only": true,'+
	                '"parent_shared_folder_id": "84528192421",'+
	                '"modified_by": "dbid:AAH4f99T0taONIb-OurWxbNQ6ywGRopQngc"},'+
	            '"property_groups": [{'+
	                    '"template_id": "ptid:1a5n2i6d3OYEAAAAAAAAAYa",'+
	                    '"fields": [{"name": "Security Policy", "value": "Confidential"}]}]' + 
	          '}';
	}
		
	public static String getMSAPIDriveItem(Boolean isFolder, String name) {
		return '{ "createdBy": ' + getMSAPIIdentitySetString() + ',' +
				 '"lastModifiedBy": ' + getMSAPIIdentitySetString() + ',' +
  				 '"createdDateTime": "2016-09-20T14:34:00Z", "lastModifiedDateTime": "2016-09-20T14:34:00Z", "eTag": "343F1FBD-E9B3-4DDE-BCA7-D61AEAFF44E5,1", "id": "ACEA49D1-1444-45A9-A1CB-68B1B28AE491",' + 
				 '"name": "' + name + '",' + 
				 '"webDAVurl": "/root/testfolder/' + name + '",' +
				 '"weburl": "/root/testfolder/' + name + '",' +
				 '"parentReference": { "driveId": "5FE38E3C-051C-4D55-9B83-8A437658275B", "id": "E67A8F34-B0AA-46E1-8FF7-0750A29553DF", "path": "/drive/root:/" },' + 
				 (isFolder ? '"size": 0, "folder": {"childCount": 0}' : '"size": 123123, "file": {}') + 
				'}';
	}
	
	public static String getMSAPIDriveItemWithRelations(Boolean isFolder, String name) {
		return '{ "createdBy": ' + getMSAPIIdentitySetString() + ',' +
				 '"lastModifiedBy": ' + getMSAPIIdentitySetString() + ',' +
  				 '"createdDateTime": "2016-09-20T14:34:00Z", "lastModifiedDateTime": "2016-09-20T14:34:00Z", "eTag": "343F1FBD-E9B3-4DDE-BCA7-D61AEAFF44E5,1", "id": "ACEA49D1-1444-45A9-A1CB-68B1B28AE491",' + 
				 '"name": "' + name + '",' + 
				 '"webDAVurl": "/root/testfolder/' + name + '",' +
				 '"weburl": "/root/testfolder/' + name + '",' +
				 '"parentReference": { "driveId": "5FE38E3C-051C-4D55-9B83-8A437658275B", "id": "E67A8F34-B0AA-46E1-8FF7-0750A29553DF", "path": "/drive/root:/" },' + 
				 '"size": 0, "folder": {"childCount": 0}, ' +
				 (isFolder ? '"children": [' + getMSAPIDriveItem(true, 'Child Folder') + ',' + getMSAPIDriveItem(false, 'TestFile.jpeg') +'],' : '') +
				 (isFolder ? '' : '"versions": [' + getMSAPIRevisionString('rev01') + '],') +
				 '"permissions": [' + getMSAPIPermissionString(true) +']' +
				'}';
	}
	
	public static String getMSAPIPermissionString(Boolean roFlag) {
		return '{"id": "dummypermissionid", "roles" : ' + (roFlag ? '["read"]' : '["write"]') + '}';
	}
	
	public static String getMSAPIRevisionString(String revId) {
		return '{"id": "' + revId + '", "size" : "123123", "lastModifiedBy": ' + getMSAPIIdentitySetString() + ',"lastModifiedDateTime": "2016-09-20T14:34:00Z"}';
	}
	
	public static String getMSAPIIdentitySetString() {
		return '{"user": {"displayName": "' + UserInfo.getName() + '", "id": "' + UserInfo.getUserId() + '"} }';
	}
}