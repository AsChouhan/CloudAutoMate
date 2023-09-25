global without sharing class SimpplrPostInstallScript implements InstallHandler {
    global void onInstall(InstallContext context) { 

		Version currentVersion = System.requestVersion();
		// Create Upgrade History Record
    	Package_Upgrade_History__c historyObj = new Package_Upgrade_History__c();
    	historyObj.name = ServiceConstants.RELEASE_VERSION;
    	historyObj.Major__c = currentVersion.major();
    	historyObj.Minor__c = currentVersion.minor();
    	historyObj.patch__c = Integer.valueOf(ServiceConstants.PATCH_VERSION);
    	historyObj.Is_Push__c = context.isPush();
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(historyObj, new List<Schema.SObjectField>{
				Package_Upgrade_History__c.name,
				Package_Upgrade_History__c.Major__c,
				Package_Upgrade_History__c.Minor__c,
				Package_Upgrade_History__c.patch__c,
				Package_Upgrade_History__c.Is_Push__c
				});
		createEveryoneAudience();  
    	if (context.isUpgrade()) {
			if(!canServiceAccountModifyData()) {
				throw new SimpplrException('Either service account is inactive or does not have Modify All Data permission.');
			}
			clearPlatformCache();
    		Version previousVersion = context.previousVersion();
    		
			if(shouldMigrationBeRun(previousVersion.major(), previousVersion.minor(), previousVersion.patch())) {
				updateAppConfig(context);
				registerMigrationJob(context.isPush(), previousVersion.major(), previousVersion.minor(), previousVersion.patch());
			}
    	}
	}

	@testVisible
	private Boolean shouldMigrationBeRun(Integer majorVersion, Integer minorVersion, Integer patchVersion) {
		Boolean result = false;
		//Fuji Release Base Version 1.330
		if (majorVersion == 1 && minorVersion < 342) {
			throw new SimpplrException('Please first upgrade to latest Gorgonio release');

		} else if(majorVersion <= 3) { //check added in Laki v4
			result = true;
		}
		return result;
	}

	/**
	 * @description check if service account is connected and have modify all data permission
	 * @return boolean
	 */
	private Boolean canServiceAccountModifyData() {
		Boolean hasModifyAllDataPermission = true;
		String packageName = SimpplrPostInstallScript.class.getName().substringBefore('SimpplrPostInstallScript').substringBefore('.');
		Organization orgDetail = [SELECT Id, InstanceName, IsSandbox, Name FROM Organization LIMIT 1];

		List<User> userList;
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && orgDetail.IsSandbox == false) {
			userList = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE Username LIKE 'simpplr.serviceaccount@%' AND IsActive = true AND Id IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix = :packageName)];
		} else {
			userList = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE Username LIKE 'simpplr.serviceaccount@%' AND IsActive = true];
		}
		if(userList.isEmpty()) {
			hasModifyAllDataPermission = false;

		} else if(!userList[0].Profile.PermissionsModifyAllData) {
			hasModifyAllDataPermission = false;
			for(PermissionSetAssignment assignmentObj: [SELECT Id, PermissionSet.PermissionsModifyAllData
				FROM PermissionSetAssignment WHERE AssigneeId =:userList[0].Id]) {

				if(assignmentObj.PermissionSet.PermissionsModifyAllData) {
					hasModifyAllDataPermission = true;
					break;
				}
			}
		}
		return hasModifyAllDataPermission;
	}

	@TestVisible
	private void createEveryoneAudience() {
		List<Audience__c> newAudienceList = new List<Audience__c>();
		List<Audience__c> audienceList = [SELECT id from Audience__c where name__c='Everyone' And Is_Hidden__c = true];
		if(audienceList.isEmpty()) {
			Audience__c audienceObj = new Audience__c();
			audienceObj.Name__c = 'Everyone';
			audienceObj.Audience_Rule_Json__c = '[]';
			audienceObj.Is_Hidden__c = true;
			newAudienceList.add(audienceObj);
		}
		List<Segment__c> segmentList = [SELECT id, Name__c, Created_By_People__c, Modified_By_People__c 
										From Segment__c 
										WHERE id not in (SELECT Segment__c from Audience__c 
														 WHERE Is_Hidden__c = true)];
		for(Segment__c segmentObj : segmentList) {
			Audience__c audienceObj = new Audience__c();
			audienceObj.Name__c = 'Everyone in segment - ' + segmentObj.Name__c.left(200);
			audienceObj.Segment__c = segmentObj.Id;
			audienceObj.Created_By_People__c = segmentObj.Created_By_People__c;
			audienceObj.Modified_By_People__c = segmentObj.Modified_By_People__c;
			audienceObj.Audience_Rule_Json__c = '[]';
			audienceObj.Is_Hidden__c = true;			
			newAudienceList.add(audienceObj);			
		}

		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
		
		if( !newAudienceList.isEmpty() ) {
			fieldList.add(Audience__c.Name__c);
			fieldList.add(Audience__c.Segment__c);
			fieldList.add(Audience__c.Created_By_People__c);
			fieldList.add(Audience__c.Modified_By_People__c);
			fieldList.add(Audience__c.Audience_Rule_Json__c);
			fieldList.add(Audience__c.Is_Hidden__c);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(newAudienceList, fieldList);
		}
	}

    @TestVisible
    private void updateAppConfig(InstallContext context) {
		List<App_Config__c> listOfAppConfig = [select id, Maintenance_In_Progress__c, Maintenance_Reason__c, Allow_Leadercast__c,
											Maintenance_Batches_Pending_Count__c, Last_Major_Upgrade_DateTime__c, AT_User_Trigger_Type__c
											From App_config__c limit 1];
														
			if(!listOfAppConfig.isEmpty()) {
				if(listOfAppConfig[0].Maintenance_In_Progress__c) {
					throw new SimpplrException('Please first complete migration of Everest release');
				}
				listOfAppConfig[0].Maintenance_In_Progress__c = true;
				listOfAppConfig[0].Maintenance_Reason__c = 'migration';
				listOfAppConfig[0].AT_User_Trigger_Type__c = 'Future';
				listOfAppConfig[0].Allow_Leadercast__c = 'all';

				listOfAppConfig[0].Maintenance_Batches_Pending_Count__c = ServiceConstants.TOTAL_NUMBER_OF_MIGRATION_BATCHES;
				listOfAppConfig[0].Last_Major_Upgrade_DateTime__c =  DateTime.now();
			
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(listOfAppConfig), new List<Schema.SObjectField>{
					App_Config__c.Maintenance_In_Progress__c, 
					App_Config__c.Maintenance_Reason__c, 
					App_Config__c.AT_User_Trigger_Type__c, 
					App_Config__c.Allow_Leadercast__c,
					App_Config__c.Maintenance_Batches_Pending_Count__c,
					App_Config__c.Last_Major_Upgrade_DateTime__c
				});
	    	}
	}

	private void clearPlatformCache() {
		String platformCacheAppConfigStr = 'Simpplr.Cache.appConfig';
		String platformCacheAppInteStr = 'Simpplr.Cache.appIntegrations';

        if (Cache.Org.contains(platformCacheAppConfigStr)) {  
            Cache.Org.remove(platformCacheAppConfigStr);
        }
		if (Cache.Org.contains(platformCacheAppInteStr)) {  
            Cache.Org.remove(platformCacheAppInteStr);
        }
	}

	@testvisible 
	@future(callout=true)
	/**
	 * @description Register Migration jobs using this method
	 * @param isPush - Boolean
	 * @param previousMajorVersion - Integer
	 * @param previousMinorVersion - Integer
	 * @param previousPatchVersion - Integer
	 */
	private static void registerMigrationJob(Boolean isPush, Integer previousMajorVersion, Integer previousMinorVersion, Integer previousPatchVersion) {
		Organization orgDetails = [SELECT Id, InstanceName, IsSandbox, Name
									FROM Organization LIMIT 1];
		String appConfigQuery = 'select id, is_Test__c from App_Config__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
					
		String endpoint;
		if(appConfig.is_Test__c || orgDetails.IsSandbox) {
			endpoint = 'https://staging.api.simpplr.com';
		} else {
			endpoint = 'https://api.simpplr.com';
		}
		endpoint += '/salesforce/package-upgrade';  

		Map<String, Object> mapOfRequestParam = new Map<String, Object>();
		mapOfRequestParam.put('orgId', UserInfo.getOrganizationId());
		mapOfRequestParam.put('orgName', UserInfo.getOrganizationName());
		mapOfRequestParam.put('action', 'registerMigrationJob');
		mapOfRequestParam.put('releaseVersion', ServiceConstants.MIGRATION_VERSION);
		mapOfRequestParam.put('isPush', isPush);
		mapOfRequestParam.put('previousMajorVersion', previousMajorVersion);
		mapOfRequestParam.put('previousMinorVersion', previousMinorVersion);
		mapOfRequestParam.put('previousPatchVersion', previousPatchVersion);
		mapOfRequestParam.put('packageVersion', ServiceConstants.PACKAGE_VERSION);

		HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', getSimpDri());
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        http.send(req);
	}

	public static String getSimpDri() {	
        String orgId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
                 
        if (orgId.length() == 18) {
            orgId = orgId.substring(0, 15);
        } 
        
        if (userId.length() == 18) {
            userId = userId.substring(0, 15);
        } 
        
        String seedValue = String.valueOf(datetime.now().getTime()) + '#$#$#$' + orgId + '#$#$#$' + userId ;         
        String initVectorString = (orgID + 'SIMPPLR').substring(0,16);
        Blob initVector = Blob.valueOf(initVectorString);
        Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
        Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
        Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
        String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0,40);
        String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0,32);
        Blob dataToEncrypt = Blob.valueOf(seedValue);
        Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
        String keyVal = EncodingUtil.base64Encode(encryptedData);
        String paddingLeft = '';
        
        if (keyVal.endsWith('=') == false) {
            paddingLeft = 'C';
        }
        
        if (keyVal.endsWith('==')) {
            paddingLeft = 'A';
            keyVal = keyVal.removeEnd('==');
        }
        
        if (keyVal.endsWith('=')) {
            paddingLeft = 'B';
            keyVal = keyVal.removeEnd('=');
        } 
        
        String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
        
        if (cryptoKeyString.endsWith('=') == false) {
            paddingLeft = paddingLeft + 'c';
        }
        
        if (cryptoKeyString.endsWith('==')) {
            paddingLeft = paddingLeft + 'a';
            cryptoKeyString = cryptoKeyString.removeEnd('==');
        }
        
        if (cryptoKeyString.endsWith('=')) {
            paddingLeft = paddingLeft + 'b';
            cryptoKeyString = cryptoKeyString.removeEnd('=');
        } 
        
        paddingLeft = paddingLeft + saltStringPrefix.substring(0,32) 
                + saltStringPrefix.substring(0,16) 
                + cryptoKeyString
                + saltStringPrefix.substring(16,32);
        String token = paddingLeft + keyVal + saltStringSuffix + simpleObfuscateString(orgId) + simpleObfuscateString(userId);
        return token + ' ' + UserInfo.getOrganizationId().substring(0, 15) + ' ' + UserInfo.getUserId().substring(0, 15);
	}
	
	private static string simpleObfuscateString (String inputVal) {
		String outputVal = '';
		
		if (inputVal.length() > 48) {
			outputVal = inputVal;
		
		} else {
			Blob seedKey = Crypto.generateDigest('SHA-256', Blob.valueOf(inputVal));
			String seedKeyString = EncodingUtil.base64Encode(seedKey);			
		
			for (Integer i = 0; i < inputVal.length(); i++) {
				outputVal = outputVal + inputVal.mid(i, 1) + seedKeyString.mid(i, 1);
			}
			
		}
		
		return outputVal;
	}
    
}