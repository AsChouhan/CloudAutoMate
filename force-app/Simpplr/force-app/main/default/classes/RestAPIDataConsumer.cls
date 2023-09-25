public with sharing class RestAPIDataConsumer {
	

	
    public string jsonString {set; get;}
	/**
	* @description request parameters
	* @return Map<String, String> request parameters map
	**/
	public Map<String, String> urlParams {set; get;}
    private transient String matchingString  {set; get;}
    private transient String resultValue  {set; get;}
    private transient String error  {set; get;}
	private transient String loggedInUserId {set; get;}
    
    public RestAPIDataConsumer() {
    	if(SimpplrContext.isRESTServiceContext != true){
    		urlParams = ApexPages.currentPage().getParameters();
    	}
    	loggedInUserId = UserContext.id;
    	matchingString = '';
    	error = 'Error';
    	jsonString = '{"status": "error","message": "Invalid Parameters passed."}';
    }
    
    public void handleRequest() {
    	if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
	    	try {
	        	if(urlParams.containsKey('object')) {
	        		if(urlParams.get('object').equalsIgnoreCase('tokenupdate')) {
		        		if(urlParams.containsKey('type') && urlParams.containsKey('token')) {
		        			String appType = urlParams.containsKey('appType') ?  urlParams.get('appType') : 'Hybrid';
		        			String appVersion = urlParams.containsKey('appVersion') ?  urlParams.get('appVersion') : null;
		        			String fcmId  = urlParams.containsKey('fcmId') ?  urlParams.get('fcmId') : '';
		        			String bundleId  = urlParams.containsKey('bundleId') ?  urlParams.get('bundleId') : '';
		        			
		        			if(urlParams.get('type').trim().equalsIgnoreCase('ios')) {
		        				resultValue = updatePeopleMobileToken(loggedInUserId, 'ios', urlParams.get('token').trim(), appType.trim(), fcmId, bundleId, appVersion);
							
							} else if(urlParams.get('type').trim().equalsIgnoreCase('android')) {
		        				resultValue = updatePeopleMobileToken(loggedInUserId, 'android', urlParams.get('token').trim(), appType.trim(), fcmId, bundleId, appVersion);
							
							} else {
								error = 'Invalid parameters passed for token update. Please check the parameters and try again.'; 
							}
		        		} else {
		        			error = 'Invalid parameters passed for token update. Please check the parameters and try again.'; 
						}
					} else if(urlParams.get('object').equalsIgnoreCase('cleartoken')) {
						if(urlParams.get('type').trim().equalsIgnoreCase('ios')) {
							resultValue = clearToken(loggedInUserId, 'ios');

						} else if(urlParams.get('type').trim().equalsIgnoreCase('android')) {
							resultValue = clearToken(loggedInUserId, 'android');
						
						} else {
							error = 'Invalid parameters passed. Please check the parameters and try again.'; 
						}

	        		} else {
	        			error = 'Invalid parameters passed. Please check the parameters and try again.'; 
	        		}        	
	        	} else {
	        		error = 'Invalid parameters passed. Please check the parameters and try again.'; 
	        	}        	
	        } catch (Exception ex) {
	            error = 'The server encountered an error while processing your request. ' + ex.getMessage();    
	        }
    	}else{
    		error = 'You do not have license to use Simpplr.';
    	}

        if(String.isBlank(error)) {
            jsonString = '{"status": "success","data": ' + resultValue + ',"error": ""}';
        } else {
            jsonString = '{"status": "failed","data": "[]","error": "'+ error + '"}';
        }
		
	}
	
	private String clearToken(String userId, String deviceType) {
		String retVal = '';
		List<People__c> lstPeopleUpdate =  new List<People__c>();
		List<People__c> lstPeople;
		List<Schema.SObjectField> peopleFieldList = new List<Schema.SObjectField>();

		if('ios'.equalsIgnoreCase(deviceType)) {
			lstPeople = [select Id, Mobile_Token_iOS__c, Mobile_App_Type_iOS__c, Mobile_FCM_ID_iOS__c,Mobile_Bundle_ID_iOS__c from People__c where User__c = :userId WITH SECURITY_ENFORCED];

			peopleFieldList.add(People__c.Mobile_Token_iOS__c);
			peopleFieldList.add(People__c.Mobile_App_Type_iOS__c);
			peopleFieldList.add(People__c.Mobile_FCM_ID_iOS__c);
			peopleFieldList.add(People__c.Mobile_Bundle_ID_iOS__c);
		
		} else if('android'.equalsIgnoreCase(deviceType)) {
			lstPeople = [select Id, Mobile_Token_Android__c, Mobile_App_Type_Android__c,Mobile_FCM_ID_Android__c, Mobile_Bundle_ID_Android__c from People__c where User__c = :userId WITH SECURITY_ENFORCED];

			peopleFieldList.add(People__c.Mobile_Token_Android__c);
			peopleFieldList.add(People__c.Mobile_App_Type_Android__c);
			peopleFieldList.add(People__c.Mobile_FCM_ID_Android__c);
			peopleFieldList.add(People__c.Mobile_Bundle_ID_Android__c);

		}
		for(People__c peopleCurrent : lstPeople) {

			if('ios'.equalsIgnoreCase(deviceType)) {
				peopleCurrent.Mobile_Token_iOS__c = '';
				peopleCurrent.Mobile_App_Type_iOS__c = 'Hybrid';
				peopleCurrent.Mobile_FCM_ID_iOS__c = '';
				peopleCurrent.Mobile_Bundle_ID_iOS__c = '';

			} else if('android'.equalsIgnoreCase(deviceType)) {
				peopleCurrent.Mobile_Token_Android__c = '';
				peopleCurrent.Mobile_App_Type_Android__c = 'Hybrid';
				peopleCurrent.Mobile_FCM_ID_Android__c = '';
				peopleCurrent.Mobile_Bundle_ID_Android__c = '';
			}
			lstPeopleUpdate.add(peopleCurrent);
		}

		SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(lstPeopleUpdate), peopleFieldList);
	
        retVal = '[]'; 
        error = '';   
		return retVal;
	}
    
    @TestVisible
    private string updatePeopleMobileToken(string userId, String deviceType, String token, String appType, String fcmId, String bundleId, String appVersion) {
		String retVal = '';
		
		if(String.isBlank(userId) || String.isBlank(deviceType) || String.isBlank(token)) {
			return '[]';
		}
		
		List<People__c> lstPeopleUpdate =  new List<People__c>();
		List<People__c> lstPeople;
		List<People__c> lstPeopleExisting;
		List<Schema.SObjectField> peopleFieldList = new List<Schema.SObjectField>();
		if(deviceType == 'ios') {
			lstPeople = [select Id, Mobile_Token_iOS__c, Mobile_App_Type_iOS__c, Mobile_FCM_ID_iOS__c,Mobile_Bundle_ID_iOS__c from People__c where User__c = :userId WITH SECURITY_ENFORCED];

			peopleFieldList.add(People__c.Mobile_Token_iOS__c);
			peopleFieldList.add(People__c.Mobile_App_Type_iOS__c);
			peopleFieldList.add(People__c.Mobile_FCM_ID_iOS__c);
			peopleFieldList.add(People__c.Mobile_Bundle_ID_iOS__c);
		} else if(deviceType == 'android') {
			lstPeople = [select Id, Mobile_Token_Android__c, Mobile_App_Type_Android__c,Mobile_FCM_ID_Android__c, Mobile_Bundle_ID_Android__c from People__c where User__c = :userId WITH SECURITY_ENFORCED];

			peopleFieldList.add(People__c.Mobile_Token_Android__c);
			peopleFieldList.add(People__c.Mobile_App_Type_Android__c);
			peopleFieldList.add(People__c.Mobile_FCM_ID_Android__c);
			peopleFieldList.add(People__c.Mobile_Bundle_ID_Android__c);
		}
		
		if(deviceType == 'ios') {
			lstPeopleExisting = [select Id, Mobile_Token_iOS__c, Mobile_App_Type_iOS__c,Mobile_FCM_ID_iOS__c,Mobile_Bundle_ID_iOS__c from People__c where Mobile_Token_iOS__c = :token and User__c != :userId WITH SECURITY_ENFORCED];
		} else if(deviceType == 'android') {
			lstPeopleExisting = [select Id, Mobile_Token_Android__c, Mobile_App_Type_Android__c, Mobile_FCM_ID_Android__c, Mobile_Bundle_ID_Android__c from People__c where Mobile_Token_Android__c = :token and User__c != :userId WITH SECURITY_ENFORCED];
		}
		
		for(People__c peopleCurrent : lstPeopleExisting) {
			if(deviceType == 'ios') {
				peopleCurrent.Mobile_Token_iOS__c = '';
				peopleCurrent.Mobile_App_Type_iOS__c = 'Hybrid';
				peopleCurrent.Mobile_FCM_ID_iOS__c = '';
				peopleCurrent.Mobile_Bundle_ID_iOS__c = '';
			} else if(deviceType == 'android') {
				peopleCurrent.Mobile_Token_Android__c = '';
				peopleCurrent.Mobile_App_Type_Android__c = 'Hybrid';
				peopleCurrent.Mobile_FCM_ID_Android__c = '';
				peopleCurrent.Mobile_Bundle_ID_Android__c = '';
			}
			lstPeopleUpdate.add(peopleCurrent);
		}
		if(lstPeople.size() == 1) {
			People__c people = lstPeople[0];
			if(deviceType == 'ios') {
				people.Mobile_Token_iOS__c = token;
				people.Mobile_App_Type_iOS__c = appType;
				people.Mobile_App_Version_iOS__c = appVersion;
				people.Mobile_FCM_ID_iOS__c = fcmId;
				people.Mobile_Bundle_ID_iOS__c = bundleId;
			} else if(deviceType == 'android') {
				people.Mobile_Token_Android__c = token;
				people.Mobile_App_Type_Android__c = appType;
				people.Mobile_App_Version_Android__c = appVersion;
				people.Mobile_FCM_ID_Android__c = fcmId;
				people.Mobile_Bundle_ID_Android__c = bundleId;
			}
			lstPeopleUpdate.add(people);
		}
		
		SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(lstPeopleUpdate), peopleFieldList);

        retVal = '[]'; 
        error = '';   
		return retVal;
	}
}