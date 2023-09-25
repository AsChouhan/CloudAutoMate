@RestResource(urlMapping= '/v1.0')
global with sharing class DataServices {

/**
 * @api {post} /apex/DataServerRW?target=https://instance.salesforce.com/services/apexrest/v1.0 v1.0
 * @apiVersion 1.229.1
 * @apiGroup RESTServices
 * @apiName v1.0
 * 
 * @apiParam (Request JSON) {String} action actionDesc
 * @apiParam (Request JSON) {String} objectType type
 * @apiParam (Request JSON) {String} externalURL URL
 * @apiParam (Request JSON) {String} jsonData Alert/Notification JSON. Refer the sample mentioned below
 * @apiParamExample Alert(CREATE) Sample JSON
 *              { 
 *					"message" : "Company Invite",
 *					"url" : "www.simpplr.com",
 *					"displayFrom" : "2017-12-25T12:00:00",
 *					"displayTo" : "2017-12-30T12:00:00",
 *					"isDismissable" : "yes",
 *					"ExternalId" : "companyinvite001",
 *					"SiteId" : ""
 *				}
 * @apiParamExample Alert(UPDATE) Sample JSON
 *              { 
 *					"message" : "Company Invite",
 *					"url" : "www.simpplr.com",
 *					"isDismissable" : "no",
 *					"ExternalId" : "companyinvite001",
 *					"recordId" : ""
 *				}
 * @apiParamExample Alert(DisplayNow) Sample JSON
 *              { 
 *					"ExternalId" : "companyinvite001",
 *					"recordId" : ""
 *				}
 * @apiParamExample Alert(ExpireNow) Sample JSON
 *              { 
 *					"ExternalId" : "companyinvite001",
 *					"recordId" : ""
 *				}
 * @apiParamExample Notification(CREATE) Sample Notification CREATE request JSON
 *              {
 *					"Content" : "System Review Invite",
 *                  "PropertyName" : "email",
 *                  "SentBy" : "riyaz@simpplr.com",
 *                  "SentTo" : "ashish@simpplr.com",
 *					"ActionBy" : "piyush@simpplr.com",
 *                  "ExternalId" : "systemreview001",
 *				}
 *
 * @apiDescription 
 * 1. Called from External System for creating Simpplr object record
 * 2. Simpplr Objects exposed for external systems
 * <br/>		a. Alert
 * <br/>		b. Notification
 * 
 * @apiSuccess (Response JSON) {Boolean} status Whether the REST request is processed successfully or not
 * @apiSuccess (Response JSON) {String} message Detail of the response from the server
 * @apiSuccess (Response JSON) {String} jsonBody Custom response needed for the operation
 * @apiSuccess (Response JSON) {String} recordId Id of the record created/updated. Null for delete operation
 */

	global static Map<String, Set<String>> operationFields = new Map<String, Set<String>>{
		'create_notification' => new Set<String>{'propertyname', 'content', 'sentby', 'sentto', 'actionby', 'externalid', 'mobile'}, 
		//'update_notification' => new Set<String>{'propertyname', 'content', 'sentby', 'sentto', 'externalid', 'recordid'},
		//'delete_notification' => new Set<String>{'externalid', 'recordid'},
		// To be designed
		'create_alert' => new Set<String>{'message', 'url', 'displayfrom', 'displayto', 'externalid', 'isdismissable', 'siteid'}, 
		'update_alert' => new Set<String>{'message', 'url', 'isdismissable', 'externalid', 'recordid'},
		'expirenow_alert' => new Set<String>{'externalid', 'recordid'},
		'displaynow_alert' => new Set<String>{'externalid', 'recordid'}
	};
       
    @HttpPost
    global static RestResponseWrapper doPost(){
    	RestResponseWrapper resp = new RestResponseWrapper();
    	
    	String action = '';
    	String objType = '';
    	String eURL = '';
    	
    	String requestData = RestContext.request.requestBody.toString();
    	
        try { 
            if(String.isEmpty(requestData) || requestData == null) {
            	resp.success = false;
            	resp.message = 'Empty request body. Please provide required json in the body.';
            } else {
//	        	RestRequestWrapper req = (RestRequestWrapper)JSON.deserialize(requestData, RestRequestWrapper.class);
	        	Map<String, Object> reqMap = convertKey((Map<String, Object>) JSON.deserializeUntyped(requestData));
	        	
//	        	Map<String, String> req = (Map<String, String>) JSON.deserialize(requestData, Map<String, String>.class);
				Map<String, String> fldMap = convertKeyandType((Map<String, Object>) reqMap.get('jsondata'));
				objType = reqMap.get('objecttype') + '';
				action = reqMap.get('action') + '';
				eURL = reqMap.get('externalurl') + '';
				
				// Validate the required fields are in the request
				String operation = (action + '_' + objType).toLowerCase();
				Set<String> opFields = operationFields.get(operation);
				
				if(opFields == null || opFields.isEmpty()) {
					resp.message = 'Invalid action and objectType - ' + operation;
				} else {
					Set<String> inpFields = new Set<String>();
					for(String keyStr: fldMap.keySet()) {
						inpFields.add(keyStr.toLowerCase());
					}
					
					Boolean fldCheck = inpFields.removeAll(opFields);
					
					if(fldCheck && !inpFields.isEmpty()) {
						resp.success = false;
						resp.message = 'Incorrect Fields (' + inpFields + ') are in the Request.';
					} else {
						try {
				    		if(objType.equalsIgnoreCase('notification')) {
				    			if(action.equalsIgnoreCase('create')) {
				    				App_Notification__c inpNoti = new App_Notification__c();
				    				
					    			inpNoti.Object_Type__c = 'External';
			    					inpNoti.External_Id__c = fldMap.get('externalid');
			    					inpNoti.Type__c = 'Actionable';
			    					inpNoti.External_URL__c = eURL;
			    					inpNoti.Submitter_Comment__c = fldMap.get('content');	
			    					
				    				// Get the people records
				    				try {
										Map<String, People__c> pplMap = findPeople(fldMap.get('propertyname')+'',
																					new Set<String>{ fldMap.get('sentto')+'', 
																									 fldMap.get('sentby')+'',
																									 fldMap.get('actionby')+''
																					});
	
				    					inpNoti.Sent_By__c = pplMap.get(fldMap.get('sentby')).id;
				    					inpNoti.Sent_To__c = pplMap.get(fldMap.get('sentto')).id;
				    					if(fldMap.get('actionby') != null && !String.isBlank(fldMap.get('actionby'))) {
				    						inpNoti.Action_By__c = pplMap.get(fldMap.get('actionby')).id;
				    					}
				    				} catch(Exception e) {
				    					resp.message = 'Incorrect/invalid data on sentto, sentby or actionby.';
				    					return resp;
				    				}
					    			
									try {
										insert inpNoti;

										if(fldMap.get('mobile').equalsIgnoreCase('yes')) {
											NotificationDao.sendPushNotifications(JSON.serialize(new List<App_Notification__c>{inpNoti}));
										}
																				
										resp.success = true;
										resp.message = 'Your ' + action + ' request is successful.';
										resp.recordId = inpNoti.id;
									} catch(Exception ie) {
										resp.message = Utility.convertExceptionToString(ie);
									} 		
				    			} else {
				    				resp.success = false;
				    				resp.message = 'Your ' + action + ' is not supported.';
				    			}
				    		} else if(objType.equalsIgnoreCase('alert')) {
				    			Alert__c alertObj;
				    			// Pass the operation and data to the AlertDao Class
								Map<String, Object> soqlParamMap = new  Map<String, Object>();
								List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
			    				String alertId = fldMap.get('recordid');
			    				String extId = fldMap.get('externalid');
				    			soqlParamMap.put('soqlParam1', alertId);
								soqlParamMap.put('soqlParam2', extId);	
				    			if(action.equalsIgnoreCase('expirenow')) {
				    				String query= 'select id, Is_Manually_Expired__c,Display_From_DateTime__c,Display_To_DateTime__c,Recipient_Count__c, '
													+ '	Recipient_Site__c,Author__c,Alert_Message__c,Alert_Url__c,Is_Dismissible__c,Is_Link_Alert__c,External_Id__c,External_URL__c '
								 					+ ' from Alert__c where (id=:soqlParam1 OR external_id__c=:soqlParam2)'
								 					+ ' AND Is_Deleted__c = false Limit 1';
									SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
									alertObj = ((List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap))[0];
	    							alertObj.Is_Manually_Expired__c = true;
									listOfModifiedFields.add(Alert__c.Is_Manually_Expired__c);
				    			} else if(action.equalsIgnoreCase('displaynow')) {
				    				String query= 'select id, Is_Manually_Expired__c,Display_From_DateTime__c,Display_To_DateTime__c,Recipient_Count__c, '
													+ '	Recipient_Site__c,Author__c,Alert_Message__c,Alert_Url__c,Is_Dismissible__c,Is_Link_Alert__c,External_Id__c,External_URL__c '
								 					+ ' from Alert__c where (id=:soqlParam1 OR external_id__c=:soqlParam2)'
								 					+ ' AND Is_Deleted__c = false Limit 1';

									SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
									alertObj = ((List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap))[0];
						    		alertObj.Display_From_DateTime__c = DateTime.now();
						    		DateTime displayToTime = (DateTime.now()).addHours(168);
						    		Integer minute = displayToTime.minute() - Math.Mod(displayToTime.minute(), 15);
						    		displayToTime = DateTime.newInstance(displayToTime.Year(), displayToTime.Month(), displayToTime.Day(), 
						    															   displayToTime.Hour(), minute, 0);
									listOfModifiedFields.add(Alert__c.Display_From_DateTime__c);
					    			if(displayToTime < alertObj.Display_To_DateTime__c) {
					    				alertObj.Display_To_DateTime__c = displayToTime;
										listOfModifiedFields.add(Alert__c.Display_To_DateTime__c);
					    			}
				    			} else {
				    				if(action.equalsIgnoreCase('create')) {
				    					alertObj = new Alert__c();
				    					String dispFrom = fldMap.get('displayfrom');
					    				if(String.isNotBlank(dispFrom)){
								    		alertObj.Display_From_DateTime__c = Utility.convertStringTodateTime(dispFrom);
								    	} else {
								    		alertObj.Display_From_DateTime__c = DateTime.now();
								    	}
										
								    	alertObj.Display_To_DateTime__c = Utility.convertStringTodateTime(fldMap.get('displayto'));
								    	listOfModifiedFields.add(Alert__c.Display_From_DateTime__c);
										listOfModifiedFields.add(Alert__c.Display_To_DateTime__c);
				    					String siteId = fldMap.get('siteid');
								    	if(String.IsNotBlank(siteId)){
									    	Simpplr_Site__c siteObj =[select Chatter_Group_Id__c from Simpplr_Site__c Where id=:siteId WITH SECURITY_ENFORCED Limit 1];
									    	alertObj.Recipient_Count__c = [select memberCount from CollaborationGroup Where id=:siteObj.Chatter_Group_Id__c].memberCount;
									    	alertObj.Recipient_Site__c = siteId;
											listOfModifiedFields.add(Alert__c.Recipient_Count__c);
											listOfModifiedFields.add(Alert__c.Recipient_Site__c);
								    	} else {
								    		alertObj.Recipient_Count__c =  Utility.getTotalPeopleInSimpplr();
											listOfModifiedFields.add(Alert__c.Recipient_Count__c);
								    	}
								    	alertObj.Author__c = UserContext.peopleId;
										listOfModifiedFields.add(Alert__c.Author__c);						    			
				    				} else {
						    			String query = 'SELECT id, Alert_Message__c, Alert_Url__c, Display_From_DateTime__c, Display_To_DateTime__c, Is_Active__c, Is_Dismissible__c,' 
														+ ' Is_Expired__c, Is_Link_Alert__c, Is_Manually_Expired__c, Is_Scheduled__c, Recipient_Count__c, Seen_Count__c, CreatedDate, LastModifiedDate,' 
														+ ' Author__c, Author__r.User__r.Id, Author__r.Full_Name__c, Author__r.User__r.SmallPhotoUrl,  Recipient_Site__c, Recipient_Site__r.name,' 
														+ ' Recipient_Site__r.Chatter_Group_Id__c, Recipient_Site__r.Title_Content_Version__c, Recipient_Site__r.Landing_Page__c, Recipient_Site__r.Site_Type__c'
														+ ' from Alert__c Where (id=:soqlParam1 OR external_id__c=:soqlParam2) AND Is_Scheduled__c = true AND Is_Expired__c=false AND Is_Deleted__c = false Limit 1';
										SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
										alertObj = ((List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap))[0];
				    				}

				    				alertObj.Alert_Message__c = fldMap.get('message');
				    				alertObj.Alert_Url__c = fldMap.get('url');
							    	alertObj.Is_Dismissible__c = fldMap.get('isdismissable').equalsIgnoreCase('yes') ? true : false;
							    	alertObj.Is_Link_Alert__c = String.isEmpty(alertObj.alert_url__c) ? true : false;
							    	alertObj.External_Id__c = extId;
							    	alertObj.External_URL__c = eURL;
									listOfModifiedFields.add(Alert__c.Alert_Message__c);
									listOfModifiedFields.add(Alert__c.Alert_Url__c);
									listOfModifiedFields.add(Alert__c.Is_Dismissible__c);
									listOfModifiedFields.add(Alert__c.Is_Link_Alert__c);
									listOfModifiedFields.add(Alert__c.External_Id__c);
									listOfModifiedFields.add(Alert__c.External_URL__c);
				    			}
				    			
				    			try {
									if(String.isNotBlank(alertId) || String.isNotBlank(extId)) {
										SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
										SIMPESAPI.accessController().updateAsUser(alertObj, listOfModifiedFields);
									}
									else {
										SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
										SIMPESAPI.accessController().InsertAsUser(alertObj, listOfModifiedFields); 
									}
									
									resp.success = true;
									resp.message = 'Your ' + action + ' request is successful.';
									resp.jsonBody = '';
									resp.recordId = alertObj.id;
				    			} catch (Exception ce) {
									resp.message = Utility.convertExceptionToString(ce);				    				
				    			}     			
				    		}     								
						} catch(Exception daoe) {
							resp.message = Utility.convertExceptionToString(daoe);
						}
					}
				}				
            }
        } catch(Exception ex){
        	resp.success = false;
        	resp.message = ex.getMessage();
        	
			String jsonBody = Utility.convertExceptionToString(ex);

        	resp.jsonBody = jsonBody;
        	
        	resp.recordId = RestContext.request.requestBody.toString();
        }
        
        // Save the request and resp
        try {
        	REST_Service__c obj = new REST_Service__c();
        	obj.Request_Action__c = action;
        	obj.Request_By__c = eURL;
        	obj.Request_Data__c = requestData;
        	obj.Request_Object_Type__c = objType;
        	obj.Response_Object__c = JSON.serialize(resp);
//        	obj.Response_On__c = Datetime.now();

			insert obj;
        } catch (Exception ae) {
        	// Email app admin about the process failure
        	
        }
        
        return resp;
    }   
 
	public static Map<String, Object> convertKey(Map<String, Object> inMap) {
		Map<String, Object> outMap = new Map<String, Object>();
			
		String keyLower = '';
		for(String key: inMap.keySet()) {
			outMap.put(key.toLowerCase(), inMap.get(key));	
		}
		
		return outMap;	
	}

	public static Map<String, String> convertKeyAndType(Map<String, Object> inMap) {
		Map<String, String> outMap = new Map<String, String>();
			
		String keyLower = '';
		for(String key: inMap.keySet()) {
			outMap.put(key.toLowerCase(), (inMap.get(key) + ''));	
		}
		
		return outMap;	
	}

	public static Map<String, People__c> findPeople(String pName, Set<String> pValues) {
		Map<String, People__c> pplMap = new Map<String, People__c>();
		
		String pplQuery = 'SELECT id, user__c, user__r.' + pName + ' FROM People__c WHERE user__r.' + pName + ' IN :pValues';
		
		for(sObject ppl: Database.query(pplQuery)) {
			pplMap.put(String.valueOf(ppl.getSObject('User__r').get(pName)), (People__c) ppl);
		}
		
		return pplMap;
	}	
	 
    public class RestRequestWrapper {
    	public String action;
    	public String objectType;
		public Object jsonData; //Map<String, Object>
		public String externalURL;        
    }
			
/*	public class NotificationRequestWrapper {
		public String propertyName;
		public String content;
		public String sentBy;
		public String sentTo;
		public String externalId;
		public String recordId;
	} */
    
    global class RestResponseWrapper {
    	global boolean success;
    	global String message;
    	global String jsonBody;
    	global String recordId;
    	
    	RestResponseWrapper() {
    		success = false;
    		message = '';
    		jsonBody = '';
    		recordId = null;
    	}
    }
}