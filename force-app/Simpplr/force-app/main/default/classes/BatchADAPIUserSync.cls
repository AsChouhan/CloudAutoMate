/*
* Batch Class for the Initial/regular user sync with Active Directory
* It will Update the People__c records as per the Active Directory records, using Sync_Field__c as an identifier. 
*
* NOTE: Initial user synch will be run first.
*/

public with sharing class BatchADAPIUserSync implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
	 
	 private String recordType;
	 private String skipToken;
	 private String top;
	 private String nextLink;
	 private String adIdentifier = 'id';
	 private App_Config__c configObj;
	 private Set<Schema.SObjectField> peopleSyncFieldsSet;
	 private Set<String> peopleSyncStrFieldsSet;
	 private List<String> adSyncStrFieldsList;
	 private Boolean isBulkOperation;
	 private Exception exceptionDetailsObj;
	 private IntegrationService adIS = null;
	 private static final Integer EXTERNAL_PHOTO_EXPIRY_DAYS = 15;
	 private static List<String> bulkUpdateRestrictedFields = new List<String>{'About__c', 'Birth_Date__c', 'Joining_Date__c', 'External_Photo_URL__c', 'Photo_Version_Id__c', 'External_Photo_URL_Expiry_Date__c'};
	 private Map<String, String> customFieldNameLabelMap = new Map<String, String>();
	 private Map<String, SObjectField> peopleFieldMap = People__c.getSObjectType().getDescribe().fields.getMap();
     
     public BatchADAPIUserSync(){
     	
	 }
	 //Depricated 
     public BatchADAPIUserSync(String skipToken, String top, String recordType, String deltaLink){
	 }

     public BatchADAPIUserSync(String skipToken, String top, String recordType){
	 	this.skipToken = skipToken;
	 	this.top = top;
	 	this.recordType = recordType;
	 	
 	 	configObj = new ManageApplicationDao().fetchSyncingSettings();
 	 	this.peopleFieldsToBeUpdated();
	 }
	
	 public BatchADAPIUserSync(String nextLink, String recordType){
	 	this.nextLink = nextLink;
	 	this.recordType = recordType;
	 	
 	 	configObj = new ManageApplicationDao().fetchSyncingSettings();
    	this.peopleFieldsToBeUpdated();
	 }
	 
	 public database.querylocator start(Database.BatchableContext bc){
	 	String query = null;
	 	String dummyQuery = 'SELECT Id from User where id = \'' + UserInfo.getUserId() + '\'';
	 	
	 	if('InitialUserSync'.equalsIgnoreCase(recordType)){
			query = dummyQuery;
		} else if('UserBulkSync'.equalsIgnoreCase(recordType)){
			query = dummyQuery;
		} else if('UserIndividualSync'.equalsIgnoreCase(recordType)){
			String peopleFieldStr = String.join(new List<String>(peopleSyncStrFieldsSet), ',');
		 	query = 'SELECT ' + peopleFieldStr + ' FROM People__c WHERE User__r.IsActive = true AND '
 					+ ' (User__r.UserType = \'Standard\' Or User__r.Show_Simpplr__c =\'Yes\') AND Is_Deleted__c = false AND Sync_Field__c != null';
		} else {
			throw new SimpplrException('Invalid operation.');
		}
    	
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
    		if('InitialUserSync'.equalsIgnoreCase(recordType)){
    			this.updateSyncIdentifier();
    		} else if('UserBulkSync'.equalsIgnoreCase(this.recordType)){
    			this.updatePeopleList();
    		} else if('UserIndividualSync'.equalsIgnoreCase(this.recordType)){
    			// Batch size will always be 1
    			List<People__c> peopleList = (List<People__c>) listOfsObject;
				People__c peopleObj = peopleList[0];
				if(String.isNotBlank(peopleObj.Sync_Field__c)){
					this.updatePeople(peopleObj);
				}
	 		}
		} catch(Exception ex) {
			logger.logDebug('BatchADAPIUserSync failed: ' + ex.getMessage());
			exceptionDetailsObj = ex;
    		throw ex;
    	}
    }
    
    public void finish(Database.BatchableContext bc){
    	if(adIS != null){
    		logger.logDebug('ADIS closed.');
    		
    		adIS.close();
    	}
    	
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendBatchFailedExceptionEmail('BatchADAPIUserSync.' + recordType, exceptionDetailsObj);
		}
        if(Test.isRunningTest()){
            return;
        }
		
    	if(canStartNextBatch) {
    		if('InitialUserSync'.equalsIgnoreCase(recordType)) {
    			if(String.isNotBlank(this.nextLink)){
    				BatchADAPIUserSync job = new BatchADAPIUserSync(this.nextLink, 'InitialUserSync');
					Database.executeBatch(job, 1);
    			} else {
    				String batchToFire = 'UserIndividualSync';
    				String top = '';
    				if(isBulkOperation){
    					batchToFire = 'UserBulkSync';
    					top = '50';
    				}
    				
    				BatchADAPIUserSync job = new BatchADAPIUserSync('', top, batchToFire);
					Database.executeBatch(job, 1);
    			}	
    		} else if('UserBulkSync'.equalsIgnoreCase(recordType)){
    			if(String.isNotBlank(this.nextLink)){
    				BatchADAPIUserSync job = new BatchADAPIUserSync(this.nextLink, 'UserBulkSync');
					Database.executeBatch(job, 1);

    			} 
    		}

			if('InitialUserSync'.equalsIgnoreCase(recordType) == false && String.isBlank(this.nextLink)){
				// create logs for this batch job
				ManageApplicationDao.logUserSyncProvStatus('successful', 'User Sync activedirectory');

				// Added to execute nigthly jobs sequentially
				SchedulerSimpplrServices.executeNextJob('peopleSync');				
			}
    	} else {
			// create logs for this batch job
            ManageApplicationDao.logUserSyncProvStatus('failed', 'User Sync activedirectory');

			// Added to execute nigthly jobs sequentially
			SchedulerSimpplrServices.executeNextJob('peopleSync');			
		}
    }
    	
	private String getAccessToken(){
		String accessToken = null;
		try{
			if(SimpplrContext.adIntegrationEnabled){
				adIS = new IntegrationService('adsi', null);
				
				if(adIS.appAccessTokenExpired()) {
					adIS.exchangeCode(adIS.appIntegrator.App_Refresh_Token__c, false);
					logger.logDebug('Exchange Code successfull.');
				}
				
				accessToken = adIS.appIntegrator.App_Access_Token__c;
				logger.logDebug('Access token: ' + accessToken);
			} else {
				throw new SimpplrException('Active Directory is not enabled.');
			}
		}catch(Exception ex){
			logger.logDebug('BatchADAPIUserSync Failed while getting token:' + ex.getMessage());
			
			exceptionDetailsObj = ex;
    		throw ex;
		}
		
		return accessToken;
	}
	
	private ConnectApi.Photo getSyncedProfilePhoto(People__c peopleObj){
		ConnectApi.Photo photoObj = null;
		try{
			String accessToken = getAccessToken();
			String synchFieldValue = peopleObj.Sync_Field__c;
			
			String metaDataEndpoint = 'https://graph.microsoft.com/v1.0/users/' + synchFieldValue + '/photo/';
			logger.logDebug('Get User Photo Meta Data Endpoint: ' + metaDataEndpoint);
			
			Map<String, Object> respJsonMap = getRespJsonMap(metaDataEndpoint, accessToken);
			String mediaContentType = null;
			
			if(respJsonMap != null && !respJsonMap.isEmpty()){
				mediaContentType = (String) respJsonMap.get('@odata.mediaContentType');
			} else {
				throw new SimpplrException('mediaContentType is NULL for the endpoint: ' + metaDataEndpoint);
			}
			
			String blobEndpoint = 'https://graph.microsoft.com/v1.0/users/' + synchFieldValue + '/photo/$value';
			logger.logDebug('Get User Photo blob Endpoint: ' + blobEndpoint);
			
			HTTPResponse res = getResponse(blobEndpoint, accessToken);
			Blob blobObj = res.getBodyAsBlob();
			
			if(blobObj.size() > 0){
				ConnectApi.BinaryInput binaryInputObj = new ConnectApi.BinaryInput(blobObj, mediaContentType, (peopleObj.User__c + '.png'));
				photoObj = ConnectApi.UserProfiles.setPhoto(null, peopleObj.User__c, binaryInputObj);
			}
		} catch(Exception ex) {
			logger.logDebug('Unable to Update Profile Image.' + ex.getMessage());
		}
		
		return photoObj;
	}
	
	private void updatePeople(People__c peopleObj){
		try{
			List<Logs__c> simpplrLogList = new List<Logs__c>();
			String synchFieldValue = peopleObj.Sync_Field__c;
			String accessToken = getAccessToken();
			String endpoint = this.getUserEndPoint(synchFieldValue);
			
			logger.logDebug('Get user endpoint: ' + endpoint);
			
			// Request on the enpoint and process data
			Map<String, Object> respJsonMap = getRespJsonMap(endpoint, accessToken);
			if(respJsonMap == null){
				respJsonMap = new Map<String, Object>();
			}
			
			logger.logDebug('User data: ' + respJsonMap);
			
			/**
				Check if syncing for manager is ON 
				(Here, manager will have to be fetched separately since its auto available for delta query only)
			**/
			if(peopleSyncStrFieldsSet.contains('Manager__c')){
				String managerInfoEndpoint = this.getManagerEndPoint(synchFieldValue);
				Map<String, Object> managerRespJsonMap = getRespJsonMap(managerInfoEndpoint, accessToken);
				
				if(managerRespJsonMap != null  && managerRespJsonMap.size() > 0){
					String managerSyncFieldValue = (String) managerRespJsonMap.get('id');
					String managerSyncFieldValueInSimpplr = peopleObj.Manager__r.Sync_Field__c;
					
					if(String.isNotBlank(managerSyncFieldValue) &&
					 		!managerSyncFieldValue.equalsIgnoreCase(managerSyncFieldValueInSimpplr)){
			 			List<People__c>	peopleList = [SELECT Id FROM People__c WHERE Sync_Field__c = :managerSyncFieldValue LIMIT 1];
			 			if(!peopleList.isEmpty()){
			 				respJsonMap.put('manager', peopleList[0].Id);
			 			
			 				simpplrLogList.add(constructSimpplrLogMessage('Manager updated against sync field ' + synchFieldValue + '.', 'BatchADAPIUserSync.updatePeople()'));
			 			} else {
			 				simpplrLogList.add(constructSimpplrLogMessage('User doesn\'t exists against sync field ' + managerSyncFieldValue + '.', 'BatchADAPIUserSync.updatePeople()'));
			 			}	
					}
				} else {
					// clear the manager
					respJsonMap.put('manager', '');
				}
			}
			
			// Check if photo is ON for sync
			ConnectApi.Photo photo = null;
			if(peopleSyncStrFieldsSet.contains('External_Photo_URL__c')){
				try{
					photo = getSyncedProfilePhoto(peopleObj);
					
					if(photo != null){
						Map<String, String> photoMap = new Map<String, String>();
						photoMap.put('standardEmailPhotoUrl', photo.standardEmailPhotoUrl);
						photoMap.put('photoVersionId', photo.photoVersionId);
						
						respJsonMap.put('photo', photoMap);
						
						simpplrLogList.add(constructSimpplrLogMessage('Successfully updated Photo for ' + peopleObj.Id, 'BatchADAPIUserSync.updatePeople()'));
						logger.logDebug('Updated Profile Photo:-  URL: ' + photo.url + ' VersionId: ' + photo.photoVersionId);
					}
				}catch(Exception ex){
					simpplrLogList.add(constructSimpplrLogMessage('Unable to Sync profile photo for user ' + peopleObj.User__c, 'BatchADAPIUserSync.updatePeople()'));
				}
			}
			
			// respJsonMap has not to be empty, i.e. there can be user data, photo or manager to be updated
			if((respJsonMap != null && respJsonMap.size() > 0)){
				List<People__c> peopleListToUpdate = new List<People__c>();
				peopleSyncFieldsSet = new Set<Schema.SObjectField>();
				
				updatePeopleDelta(peopleObj, respJsonMap, peopleListToUpdate, null); 
			
				try {
					// Check if any field is bieng updated
					if(!peopleListToUpdate.isEmpty() && !peopleSyncFieldsSet.isEmpty()){
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c> (peopleListToUpdate), new List<Schema.SObjectField>(peopleSyncFieldsSet));
						
						simpplrLogList.add(constructSimpplrLogMessage('Successfully updated People__c (' + peopleListToUpdate[0].Id + ')', 'BatchADAPIUserSync.updatePeople()'));
					} else {
						simpplrLogList.add(constructSimpplrLogMessage('No record found to be updated in People__c.', 'BatchADAPIUserSync.updatePeople()'));
					}
		        } catch (Exception ex) {
		        	simpplrLogList =  new List<Logs__c>{constructSimpplrLogMessage('Failed to update People__c for ' + peopleListToUpdate.size() + ' users due to error: ' + ex.getMessage() + ': ' + ex.getStackTraceString(), 'BatchADAPIUserSync.updatePeople()')};
		        }
		        
		        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		        SIMPESAPI.accessController().insertAsUser(simpplrLogList, new List<Schema.SObjectField>{Logs__c.Log_Type__c,
		        																						Logs__c.Source_Info__c,
		        																						Logs__c.Log_Data__c});
			}
		} catch(Exception ex) {
			logger.logDebug(ex.getMessage());
			exceptionDetailsObj = ex;
    		throw ex;
		}
	}
    
    private void updatePeopleList(){
		try{
			List<Logs__c> simpplrLogList = new List<Logs__c>();
			Map<String, Object> synchFieldUserObjMap = new Map<String, Object>();  
			String accessToken = getAccessToken();
			String endpoint = null;
			
			// If next link is there then there is no need to create a link
			if(String.isNotBlank(this.nextLink)){
				endpoint = this.nextLink;

			} else {
				endpoint = getUserListEndPoint();
			}
			
			logger.logDebug('Get User List Endpoint: ' + endpoint);
			
			// Request on the enpoint and process data
			Map<String, Object> respJsonMap = getRespJsonMap(endpoint, accessToken);
			
			logger.logDebug('Get User List Endpoint: ' + endpoint);
			
			if(String.isNotBlank((String) respJsonMap.get('@odata.nextLink'))){
			 		this.nextLink = (String) respJsonMap.get('@odata.nextLink');
			} else {
				this.nextLink = null;
			}
			
			logger.logDebug('nextLink: ' + this.nextLink);
			
			for(Object usrObj : (List<Object>) respJsonMap.get('value')) {
				Map<String, Object> usrMap = (Map<String, Object>) usrObj;
				
				if(String.isNotBlank((String) usrMap.get(adIdentifier))){
					synchFieldUserObjMap.put((String) usrMap.get(adIdentifier), usrMap);
				}
			}
			
			if(synchFieldUserObjMap.size() > 0){
				Set<String> synchFieldValueSet = synchFieldUserObjMap.keySet();
				String peopleFieldStr = String.join(new List<String>(peopleSyncStrFieldsSet), ',');
				String query = 'SELECT ' + peopleFieldStr + ' FROM People__c WHERE User__r.IsActive = true AND '
 								+ ' (User__r.UserType = \'Standard\' Or User__r.Show_Simpplr__c =\'Yes\') AND Is_Deleted__c = false AND '
 								+ 'Sync_Field__c IN :synchFieldValueSet ORDER BY CreatedDate asc';
 				List<People__c> peopleList = (List<People__c>) Database.query(query);				
				
				if(!peopleList.isEmpty()){
					peopleSyncFieldsSet = new Set<Schema.SObjectField>();
					List<People__c> peopleListToUpdate = new List<People__c>();
					Map<String, String> syncFieldPeopleIdMap = new Map<String, String>();
					
					// Check if syncing for manager is ON
					if(peopleSyncStrFieldsSet.contains('Manager__c')){
						Set<String> syncFieldSet = new Set<String>();
						for(People__c peopleObj : peopleList){
							syncFieldSet.add(peopleObj.Sync_Field__c); 
						}
						
						List<People__c>	syncFieldPeopleList = [SELECT Id, Sync_Field__c FROM People__c WHERE User__r.IsActive = true AND (User__r.UserType='Standard' OR User__r.Show_Simpplr__c ='Yes') AND Sync_Field__c != null];
						for(People__c peopleObj : syncFieldPeopleList){
							syncFieldPeopleIdMap.put(peopleObj.Sync_Field__c, peopleObj.Id); 
						}	
					}
					
					for(People__c peopleObj : peopleList){
						Object adUserObj = synchFieldUserObjMap.get(peopleObj.Sync_Field__c);
						Map<String, Object> usrMap = (Map<String, Object>) adUserObj;
						updatePeopleDelta(peopleObj, usrMap, peopleListToUpdate, syncFieldPeopleIdMap);
						
						simpplrLogList.add(constructSimpplrLogMessage('Successfully updated People__c (' + peopleObj.Id + ')', 'BatchADAPIUserSync.updatePeopleList()')); 
					}
					
					
					try {
						if(!peopleListToUpdate.isEmpty() && !peopleSyncFieldsSet.isEmpty()){
							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
							SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(peopleListToUpdate), new List<Schema.SObjectField>(peopleSyncFieldsSet));
						} else {
							simpplrLogList.add(constructSimpplrLogMessage('No record found to be updated in People__c.', 'BatchADAPIUserSync.updatePeopleList()'));
						}
			        } catch (Exception ex) {
			        	simpplrLogList =  new List<Logs__c>{constructSimpplrLogMessage('Failed to update People__c for ' + peopleList.size() + ' users due to error: ' + ex.getMessage() + ': ' + ex.getStackTraceString(), 'BatchADAPIUserSync.updatePeopleList()')};
			        }
			        
			       	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			        SIMPESAPI.accessController().insertAsUser(simpplrLogList, new List<Schema.SObjectField>{Logs__c.Log_Type__c,
			        																						Logs__c.Source_Info__c,
			        																						Logs__c.Log_Data__c});
				}
			}
		} catch(Exception ex) {
			exceptionDetailsObj = ex;
    		throw ex;
		}
	}
	
	private void updateSyncIdentifier(){
		try{
			List<Logs__c> simpplrLogList = new List<Logs__c>();
			Map<String, String> userAdMailIdentifierMap = new Map<String, String>();
			String accessToken = getAccessToken();
			String endpoint = null;
			
			// If next link is there then there is no need to create a link
			if(String.isNotBlank(this.nextLink)){
				endpoint = this.nextLink;
			} else {
				if(String.isNotBlank(this.top)){
					endpoint = this.getUserEndPoint(null);
				}
			}
			
			// Request on the enpoint and process data
			Map<String, Object> respJsonMap = getRespJsonMap(endpoint, accessToken);
			
			if(respJsonMap != null) {
				if(respJsonMap.containsKey('@odata.nextLink') &&
					String.isNotBlank((String) respJsonMap.get('@odata.nextLink'))){
						this.nextLink = (String) respJsonMap.get('@odata.nextLink');
				} else {
					this.nextLink = null;
				}
				
				for(Object usrObj : (List<Object>) respJsonMap.get('value')) {
					Map<String, Object> usrMap = (Map<String, Object>) usrObj;
					
					if(usrMap.get('mail') != null && String.isNotBlank((String) usrMap.get('mail'))){
						userAdMailIdentifierMap.put(((String) usrMap.get('mail')).toLowerCase(), (String) usrMap.get(adIdentifier));
					}
				}
			}
			
			if(userAdMailIdentifierMap.size() > 0){
				Set<String> userAdMail = userAdMailIdentifierMap.keySet();
				// Get records those have syncfield value as null to avoid unneccessary editing of record.
				List<People__c> peopleList = [SELECT Id, Sync_Field__c, Email__c, User__r.Email FROM People__c WHERE User__r.IsActive = true AND
				 								(User__r.UserType = 'Standard' Or User__r.Show_Simpplr__c ='Yes') AND Is_Deleted__c = false AND
				 								User__r.Email IN :userAdMail AND Sync_Field__c = null ORDER BY CreatedDate asc];
				
				String prevEmail = null;
				
				for(People__c peopleObj : peopleList){
					// Skip updating for the users with duplicate emails.
					if(prevEmail == null || !(prevEmail.equalsIgnoreCase(peopleObj.User__r.Email))){
						peopleObj.Sync_Field__c = userAdMailIdentifierMap.get(peopleObj.User__r.Email.toLowerCase());
						
						simpplrLogList.add(constructSimpplrLogMessage('Successfully updated Sync Field Value for People(' + peopleObj.Id + ') as ' +  peopleObj.Sync_Field__c, 'BatchADAPIUserSync.updateSyncIdentifier()'));
					}
					
					prevEmail = peopleObj.User__r.Email; 
				}
				
				try {
		        	if(!peopleList.isEmpty()){
						update peopleList;
					} else {
						simpplrLogList.add(constructSimpplrLogMessage('No Id(sync field) found to be updated in People__c.', 'BatchADAPIUserSync.updateSyncIdentifier()'));
					}
		        } catch (Exception ex) {
		        	simpplrLogList =  new List<Logs__c>{constructSimpplrLogMessage('Failed to update People__c for ' + peopleList.size() + ' users due to error: ' + ex.getMessage() + ': ' + ex.getStackTraceString(), 'BatchADAPIUserSync.updateSyncIdentifier()')};
		        }
		        
		        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		        SIMPESAPI.accessController().insertAsUser(simpplrLogList, new List<Schema.SObjectField>{Logs__c.Log_Type__c,
		        																						Logs__c.Source_Info__c,
		        																						Logs__c.Log_Data__c});
			}
		} catch(Exception ex) {
			logger.logDebug(ex.getMessage());
			exceptionDetailsObj = ex;
    		throw ex;
		}
	}
	
	// get manager info endpoint
	private String getManagerEndPoint(String syncFieldValue){
		String endpoint = 'https://graph.microsoft.com/v1.0/users/' + syncFieldValue + '/manager';
		
		return endpoint;
	}
	
	// get userinfo endpoint
	private String getUserEndPoint(String syncFieldValue){
		String properties = 'id';
		String endpoint = 'https://graph.microsoft.com/v1.0/users/';
		
		if(String.isNotEmpty(syncFieldValue)){
			endpoint += syncFieldValue + '/';
		}
		
		// mail is needed for intial user sync
		If('InitialUserSync'.equalsIgnoreCase(recordType)){
			properties += ',mail';
		}
		
		If((!'InitialUserSync'.equalsIgnoreCase(recordType)) &&
 					!adSyncStrFieldsList.isEmpty()){
			properties += (',' + String.join(adSyncStrFieldsList, ','));
		}
		
		endpoint += ('?$select=' + properties);
		
		// Adding pagination
		if(String.isNotBlank(this.top)){
			endpoint += ('&$top=' + this.top);
		}
		if(String.isNotBlank(this.skipToken)){
			endpoint += ('&skipToken=' + this.skipToken);
		}
		
		endpoint += '&$format=json';
		
		return endpoint;
	}

	// get user list endpoint (beta API)
	private String getUserListEndPoint(){
		String properties = 'id';
		String endpoint = 'https://graph.microsoft.com/beta/users?$expand=manager';
		
		// Adding pagination
		if(String.isNotBlank(this.top)){
			endpoint += ('&$top=' + this.top);
		}
		endpoint += '&$format=json';
		
		return endpoint;
	}
	
	private String getBody(String endpoint, String accessToken){
		String bodyStr = null;
		try{
			if(Test.isRunningTest()) {
				bodyStr ='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users(id,mail,surname,givenName,manager)","value":[{"id":"2210","mail":"package.managers@simpplr.com","surname":"Ashish","givenName":"Narang","birthday":"1947-08-15","state":"Haryana","city":"Gurgaon","country":"India","postalCode":"122001","companyName":"Simpplr","department":"Engineering"}]}';
			
			} else if(String.isNotBlank(endpoint)){
				HTTPResponse res = getResponse(endpoint, accessToken);

				if(res != null){
					bodyStr = res.getBody();
				}
				
			}
		}catch(Exception ex){
			exceptionDetailsObj = ex;
    		throw ex;
		}
				
		return bodyStr;
	}
	
	private static HTTPResponse getResponse(String endpoint, String accessToken){
		// Request the enpoint
		Http h = new Http();
				
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + accessToken);
		req.setHeader('Accept', 'application/json');
		req.setTimeout(60000);
		
		HTTPResponse res = h.send(req);
		
		if(res.getStatusCode() == 200){
			return res;
		} else{
			return null;
		}
	}
	
	private Map<String, Object> getRespJsonMap(String endpoint, String accessToken){
		String bodyStr = getBody(endpoint, accessToken);
		
		if(String.isNotBlank(bodyStr)){
			return ((Map<String, Object>) JSON.deserializeUntyped(bodyStr));
		} else {
			return null;
		}
	}
	
	private void peopleFieldsToBeUpdated(){
		isBulkOperation = true;
		peopleSyncStrFieldsSet = new Set<String>();
		adSyncStrFieldsList = new List<String>();
		
		peopleSyncStrFieldsSet.add('Id');
		peopleSyncStrFieldsSet.add('Sync_Field__c');
		peopleSyncStrFieldsSet.add('User__c');
		
		if(configObj.PDS_First_Name__c){
			peopleSyncStrFieldsSet.add('First_Name__c');
			adSyncStrFieldsList.add('givenName');
		}
		if(configObj.PDS_Last_Name__c){
			peopleSyncStrFieldsSet.add('Last_Name__c');
			adSyncStrFieldsList.add('surname');
		}
		if(configObj.PDS_Birth_Date__c && String.isNotBlank(SimpplrContext.pdsBirthDateKey)){
			peopleSyncStrFieldsSet.add('Birth_Date__c');
			adSyncStrFieldsList.add(SimpplrContext.pdsBirthDateKey);
			
			isBulkOperation = false;
		}
		if(configObj.PDS_Title__c){
			peopleSyncStrFieldsSet.add('Title__c');
			adSyncStrFieldsList.add('jobTitle');
		}
		if(configObj.PDS_Email__c){
			peopleSyncStrFieldsSet.add('Email__c');
			adSyncStrFieldsList.add('mail');
		}
		if(configObj.PDS_Community_Nickname__c){
			peopleSyncStrFieldsSet.add('Community_Nickname__c');
			adSyncStrFieldsList.add('mailNickname');
		}
		if(configObj.PDS_About_Me__c){
			peopleSyncStrFieldsSet.add('About__c');
			
			adSyncStrFieldsList.add('aboutMe');
			
			isBulkOperation = false;
		}
		if(configObj.PDS_Manager_Id__c){
			peopleSyncStrFieldsSet.add('Manager__c');
			peopleSyncStrFieldsSet.add('Manager__r.Sync_Field__c');
			
			adSyncStrFieldsList.add('manager');
		}
		if(configObj.PDS_Department__c){
			peopleSyncStrFieldsSet.add('Department__c');
			adSyncStrFieldsList.add('department');
		}
		if(configObj.PDS_Company_Name__c){
			peopleSyncStrFieldsSet.add('Company_Name__c');
			adSyncStrFieldsList.add('companyName');
		}
		if(configObj.PDS_Joining_Date__c && String.isNotBlank(SimpplrContext.pdsJoiningDateKey)){
			peopleSyncStrFieldsSet.add('Joining_Date__c');
			adSyncStrFieldsList.add(SimpplrContext.pdsJoiningDateKey);
			
			isBulkOperation = false;
		}
		if(configObj.PDS_Street__c){
			peopleSyncStrFieldsSet.add('Street__c');
			adSyncStrFieldsList.add('streetAddress');
		}
		if(configObj.PDS_Postal_Code__c){
			peopleSyncStrFieldsSet.add('Postal_Code__c');
			adSyncStrFieldsList.add('postalCode');
		}

		if(configObj.PDS_City__c){
			peopleSyncStrFieldsSet.add('City__c');
			adSyncStrFieldsList.add('city');
		}
		if(configObj.PDS_State__c){
			peopleSyncStrFieldsSet.add('State__c');
			adSyncStrFieldsList.add('state');
		}
		if(configObj.PDS_Country__c){
			peopleSyncStrFieldsSet.add('Country__c');
			adSyncStrFieldsList.add('country');
		}
		if(configObj.PDS_Phone__c){
			peopleSyncStrFieldsSet.add('Phone__c');
			adSyncStrFieldsList.add('businessPhones');
		}
		if(configObj.PDS_Mobile_Phone__c){
			peopleSyncStrFieldsSet.add('Mobile_Phone__c');
			adSyncStrFieldsList.add('mobilePhone');
		}
		if(configObj.PDS_Division__c && String.isNotBlank(SimpplrContext.pdsDivisionKey)){
			peopleSyncStrFieldsSet.add('Division__c');
			adSyncStrFieldsList.add(SimpplrContext.pdsDivisionKey);
		}
		if(configObj.PDS_Photo__c){
			peopleSyncStrFieldsSet.add('External_Photo_URL__c');
			peopleSyncStrFieldsSet.add('Photo_Version_Id__c');
			peopleSyncStrFieldsSet.add('External_Photo_URL_Expiry_Date__c');
			
			isBulkOperation = false;
		}

		// Sync custom fields.
		String customFieldsStr = configObj.PP_User_Custom_Fields__c;
		if(String.isNotBlank(customFieldsStr)){
			List<CustomProfileField> customFieldList = (List<CustomProfileField>)
							Json.deserialize(customFieldsStr, List<CustomProfileField>.class);
			
			Map<String, String> customFieldMap = new Map<String, String>();
			String peopleFieldApiName = '';
			for(CustomProfileField customField : customFieldList){
				if(!'activeDirectory'.equalsIgnoreCase(customField.syncSource)){
					continue;
				}

				peopleFieldApiName = customField.columnName;	
				if(bulkUpdateRestrictedFields.contains(customField.fieldName)){
					isBulkOperation = false;
				}

				customFieldNameLabelMap.put(peopleFieldApiName, customField.fieldName);

				adSyncStrFieldsList.add(customField.fieldName);
				peopleSyncStrFieldsSet.add(peopleFieldApiName);
			}
		}				
	}
	
	private void updatePeopleDelta(People__c peopleObj, Map<String, Object> adUserObj,
	 								List<People__c> peopleListToUpdate, Map<String, String> synchPeopleIdMap) {
		Boolean isModified = false;
		
		if(adSyncStrFieldsList.contains('givenName')){
			String givenName = (String) adUserObj.get('givenName');

			if(String.isNotBlank(givenName) && !givenName.equalsIgnoreCase(peopleObj.First_Name__c)){
				peopleObj.First_Name__c = givenName;
				
				peopleSyncFieldsSet.add(People__c.First_Name__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('surname')){
			String surname = (String) adUserObj.get('surname');
			if(String.isNotBlank(surname) && !surname.equalsIgnoreCase(peopleObj.Last_Name__c)){
				peopleObj.Last_Name__c = surname;
				
				peopleSyncFieldsSet.add(People__c.Last_Name__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains(SimpplrContext.pdsBirthDateKey)){
			String birthdayStr = (String) adUserObj.get(SimpplrContext.pdsBirthDateKey);
			Date birthday = String.isNotBlank(birthdayStr) ? convertStringToDate(birthdayStr) : null; 
			if((birthday == null && peopleObj.Birth_Date__c != null) || (birthday != null && !(birthday == peopleObj.Birth_Date__c))) {
				peopleObj.Birth_Date__c = birthday;
				
				peopleSyncFieldsSet.add(People__c.Birth_Date__c);
				
				isModified = true;
			}
		}

		if(adSyncStrFieldsList.contains(SimpplrContext.pdsJoiningDateKey)){
			String hireDateStr = (String) adUserObj.get(SimpplrContext.pdsJoiningDateKey);
			Date hireDate = String.isNotBlank(hireDateStr) ? convertStringToDate(hireDateStr) : null; 
			if((hireDate == null && peopleObj.Joining_Date__c != null) || (hireDate != null && !(hireDate == peopleObj.Joining_Date__c))) {
				peopleObj.Joining_Date__c = hireDate;
			
				peopleSyncFieldsSet.add(People__c.Joining_Date__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains(SimpplrContext.pdsDivisionKey)){
			String division = (String) adUserObj.get(SimpplrContext.pdsDivisionKey);

			if((division == null && peopleObj.Division__c != null) || (division != null && !(division == peopleObj.Division__c))) {
				peopleObj.Division__c = division;
				
				peopleSyncFieldsSet.add(People__c.Division__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('jobTitle')){
			String jobTitle = (String) adUserObj.get('jobTitle');
			if((String.isBlank(jobTitle) && String.isNotBlank(peopleObj.Title__c)) || (String.isNotBlank(jobTitle) && !jobTitle.equals(peopleObj.Title__c))){
				peopleObj.Title__c = jobTitle;
				
				peopleSyncFieldsSet.add(People__c.Title__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('mail')){
			String mail = (String) adUserObj.get('mail');
			if(String.isNotBlank(mail) && !mail.equalsIgnoreCase(peopleObj.Email__c)){
				peopleObj.Email__c = mail;
				
				peopleSyncFieldsSet.add(People__c.Email__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('mailNickname')){
			String mailNickname = (String) adUserObj.get('mailNickname');
			if((String.isBlank(mailNickname) && String.isNotBlank(peopleObj.Community_Nickname__c)) || (String.isNotBlank(mailNickname) && !mailNickname.equals(peopleObj.Title__c))){
				peopleObj.Community_Nickname__c = mailNickname;
				
				peopleSyncFieldsSet.add(People__c.Community_Nickname__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('aboutMe')){
			String aboutMe = (String) adUserObj.get('aboutMe');
			if(String.isBlank(aboutMe) && String.isNotBlank(peopleObj.About__c)){
				peopleObj.About__c= null;
				
				peopleSyncFieldsSet.add(People__c.About__c);
				isModified = true;
			} else if(String.isNotBlank(aboutMe) && !aboutMe.equals(peopleObj.About__c)){
				peopleObj.About__c= aboutMe;
				
				peopleSyncFieldsSet.add(People__c.About__c);
				
				isModified = true;
			}
		}	
		
		if(adSyncStrFieldsList.contains('department')){
			String department = (String) adUserObj.get('department');
			if((String.isBlank(department) && String.isNotBlank(peopleObj.Department__c)) || (String.isNotBlank(department) && !department.equals(peopleObj.Department__c))){
				peopleObj.Department__c = department;
				
				peopleSyncFieldsSet.add(People__c.Department__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('companyName')){
			String companyName = (String) adUserObj.get('companyName');
			if((String.isBlank(companyName) && String.isNotBlank(peopleObj.Company_Name__c)) || (String.isNotBlank(companyName) && !companyName.equals(peopleObj.Company_Name__c))){
				peopleObj.Company_Name__c = companyName;
				
				peopleSyncFieldsSet.add(People__c.Company_Name__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('streetAddress')){
			String streetAddress = (String) adUserObj.get('streetAddress');
			if((String.isBlank(streetAddress) && String.isNotBlank(peopleObj.Street__c)) || (String.isNotBlank(streetAddress) && !streetAddress.equals(peopleObj.Street__c))){
				peopleObj.Street__c = streetAddress;
				
				peopleSyncFieldsSet.add(People__c.Street__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('postalCode')){
			String postalCode = (String) adUserObj.get('postalCode');
			if((String.isBlank(postalCode) && String.isNotBlank(peopleObj.Postal_Code__c)) || (String.isNotBlank(postalCode) && !postalCode.equals(peopleObj.Postal_Code__c))){
				peopleObj.Postal_Code__c = postalCode;
				
				peopleSyncFieldsSet.add(People__c.Postal_Code__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('city')){
			String city = (String) adUserObj.get('city');
			if((String.isBlank(city) && String.isNotBlank(peopleObj.City__c)) || (String.isNotBlank(city) && !city.equals(peopleObj.City__c))){
				peopleObj.City__c = city;
				
				peopleSyncFieldsSet.add(People__c.City__c);
				
				isModified = true;
		}
		}
		
		if(adSyncStrFieldsList.contains('state')){
			String state = (String) adUserObj.get('state');
			if((String.isBlank(state) && String.isNotBlank(peopleObj.State__c)) || (String.isNotBlank(state) && !state.equals(peopleObj.State__c))){
				peopleObj.State__c = state;
				
				peopleSyncFieldsSet.add(People__c.State__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('country')){
			String country = (String) adUserObj.get('country');
			if((String.isBlank(country) && String.isNotBlank(peopleObj.Country__c)) || (String.isNotBlank(country) && !country.equals(peopleObj.Country__c))){
				peopleObj.Country__c = country;
				
				peopleSyncFieldsSet.add(People__c.Country__c);
				
				isModified = true;
			}
		}
		
		if(adSyncStrFieldsList.contains('mobilePhone')){
			String mobilePhone = (String) adUserObj.get('mobilePhone');
			if((String.isBlank(mobilePhone) && String.isNotBlank(peopleObj.Mobile_Phone__c)) || (String.isNotBlank(mobilePhone) && !mobilePhone.equals(peopleObj.Mobile_Phone__c))){
				peopleObj.Mobile_Phone__c = mobilePhone;
				
				peopleSyncFieldsSet.add(People__c.Mobile_Phone__c);	
				
				isModified = true;		
			}
		}
		
		if(adSyncStrFieldsList.contains('businessPhones')){
			if(adUserObj.get('businessPhones') != null){
				List<Object> businessPhones = (List<Object>) adUserObj.get('businessPhones');
				if(businessPhones.isEmpty() && String.isNotBlank(peopleObj.Phone__c)){
					peopleObj.Phone__c = null;
					
					peopleSyncFieldsSet.add(People__c.Phone__c);
				
					isModified = true;

				} else if(!businessPhones.isEmpty() && String.isNotBlank((String)businessPhones[0]) && !((String)businessPhones[0]).equalsIgnoreCase(peopleObj.Phone__c)){
					peopleObj.Phone__c = (String)businessPhones[0];
					
					peopleSyncFieldsSet.add(People__c.Phone__c);
				
					isModified = true;
				}
			}
		}
		
		if(adSyncStrFieldsList.contains('manager')){
			if(synchPeopleIdMap != null && !synchPeopleIdMap.isEmpty()){
				// This will the case when bulk sync is happening
				if(adUserObj.get('manager') != null){
					// This will come incase of bulk user sync
					Map<String, Object> managerMap = (Map<String, Object>) adUserObj.get('manager');
					if(String.isNotBlank((String) managerMap.get('id'))){
								
						String managerSyncFieldValue = (String) managerMap.get('id');
						// Check if the manager is not up to date
						if(!managerSyncFieldValue.equalsIgnoreCase(peopleObj.Manager__r.Sync_Field__c)) {
	
							if(String.isNotBlank(synchPeopleIdMap.get(managerSyncFieldValue))) {
								peopleObj.Manager__c = synchPeopleIdMap.get(managerSyncFieldValue);
								
								peopleSyncFieldsSet.add(People__c.Manager__c);
						
								isModified = true;
							}
						}
					}
				} else {
					// Remove manager
					peopleObj.Manager__c = null;
								
					peopleSyncFieldsSet.add(People__c.Manager__c);
			
					isModified = true;
				}
			} else if(adUserObj.containsKey('manager')){
				// This will come incase of individual user sync
				Object manager = adUserObj.get('manager');
				String newManagerId = (manager != null && String.isNotBlank((String) manager)) ? (String) manager : null;
				peopleObj.Manager__c = newManagerId;
				peopleSyncFieldsSet.add(People__c.Manager__c);	
				
				isModified = true;
			}
		}
		
		if(adUserObj.containsKey('photo') && adUserObj.get('photo') != null){
			Map<String, String> photoMap = (Map<String, String>) adUserObj.get('photo');
			
			peopleObj.External_Photo_URL__c = photoMap.get('standardEmailPhotoUrl');
			peopleObj.Photo_Version_Id__c = photoMap.get('photoVersionId');
			peopleObj.External_Photo_URL_Expiry_Date__c = DateTime.now().addDays(EXTERNAL_PHOTO_EXPIRY_DAYS);
				
			peopleSyncFieldsSet.add(People__c.External_Photo_URL__c);
			peopleSyncFieldsSet.add(People__c.Photo_Version_Id__c);
			peopleSyncFieldsSet.add(People__c.External_Photo_URL_Expiry_Date__c);
			
			isModified = true;
		}

		// Sync custom fields
		String adFieldValue = null;
		String peopleObjFieldValue = null;
		
		for(String peopleFieldApiName : customFieldNameLabelMap.keySet()){
			String syncFieldLabel = customFieldNameLabelMap.get(peopleFieldApiName);

			if(adUserObj.get(syncFieldLabel) != null){
				adFieldValue = (String) adUserObj.get(syncFieldLabel);
				
				peopleObjFieldValue = (String) peopleObj.get(SimpplrContext.namespacePrefix + peopleFieldApiName);
				if(String.isNotBlank(adFieldValue) && !adFieldValue.equalsIgnoreCase(peopleObjFieldValue)){
					peopleObj.put(SimpplrContext.namespacePrefix + peopleFieldApiName, adFieldValue);
			
					peopleSyncFieldsSet.add(peopleFieldMap.get(SimpplrContext.namespacePrefix + peopleFieldApiName));	
					
					isModified = true;
				}
			}
		}
		
		if(isModified){
			Datetime syncDateTime = DateTime.now();
			
			peopleObj.Is_Data_Sync_Done__c = true;
	    	peopleObj.Last_Sync_DateTime__c = syncDateTime;
	    	peopleObj.Last_Edited_DateTime__c = syncDateTime;
	    	
	    	peopleSyncFieldsSet.add(People__c.Is_Data_Sync_Done__c);
			peopleSyncFieldsSet.add(People__c.Last_Sync_DateTime__c);
			peopleSyncFieldsSet.add(People__c.Last_Edited_DateTime__c);
			
			peopleListToUpdate.add(peopleObj);
			
			logger.logDebug('BatchADAPIUserSync Modified peopleObj: ' + peopleObj);
		}
    }
    
    private Date convertStringToDate(String dateObj){
    	// DateObj is assumed to be in yyyy-MM-ddT00:00:00Z format
    	List<String> dateObjSplitArray = dateObj.split('-');
    	Date convertedDate = null;
    	if(dateObjSplitArray.size() == 3){
			Integer year 	= Integer.valueOf(dateObjSplitArray[0]);
			
			if(year < 1900){ return null;}
			
			Integer month 	= Integer.valueOf(dateObjSplitArray[1]);
			Integer day		= Integer.valueOf(dateObjSplitArray[2].split('T')[0]);
			convertedDate 	= Date.newInstance(year, month, day);
    	}
    	
    	return convertedDate;
    }
    
    /**
     * Log sync messages in simpplr log object
     * */
    @TestVisible 
    private Logs__c constructSimpplrLogMessage(String message, String source){
        Logs__c simpplrLogObj = new Logs__c(Log_Type__c = 'ActiveDirectory_SYNC',
        													Source_Info__c = source,
        													Log_Data__c = message);
        
        return simpplrLogObj;
    }
}