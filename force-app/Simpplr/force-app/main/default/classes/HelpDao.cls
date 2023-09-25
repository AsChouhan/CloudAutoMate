/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class HelpDao{
    
    public String getHelpTextId(String taskId) {
    	String helpTextId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', taskId);
    	String query = 'select id from Help_Text__c where Type__c=\'Task\' and Task_Id__c=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Help_Text__c> helpTextList = (List<Help_Text__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(helpTextList.isEmpty() == false) {
			helpTextId = helpTextList[0].id;
		} else {
			String siteId;
			List<String> taskParts = taskId.split('-');
			if(taskParts !=null && taskParts.size() == 3) {
				if('home'.equalsIgnoreCase(taskParts[2]) == false && 'newFeatures'.equalsIgnoreCase(taskParts[0]) == false && 'prompt'.equalsIgnoreCase(taskParts[2]) == false){
					siteId = taskParts[2];
				}
			}
			
			
			Help_Text__c helpTextObj = new Help_Text__c();
			helpTextObj.Type__c = 'Task';
			helpTextObj.Task_Id__c = taskId;
			helpTextObj.site__c = siteId;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			Help_Text__c insertedObj = (Help_Text__c) SIMPESAPI.accessController().insertAsUser(helpTextObj,
																						new List<Schema.SObjectField>{
																							Help_Text__c.Type__c,
																							Help_Text__c.Site__c,
																							Help_Text__c.Task_Id__c
																						});
			
			helpTextId = insertedObj.id;
		}
		return helpTextId;
    }
    
    public void dismissTask(String taskId) {
    	Help_Text_View__c helpTextViewObj = new Help_Text_View__c();
    	helpTextViewObj.Help_Text__c = getHelpTextId(taskId);
    	helpTextViewObj.People__c = UserContext.peopleId; 
    	
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    	SIMPESAPI.accessController().insertAsUser(helpTextViewObj, new List<Schema.SObjectField>{
    																	Help_Text_View__c.Help_Text__c,
    																	Help_Text_View__c.People__c
    																});
    } 

	/**
	 * @description overloaded method to get Help_Text__c Id for taskId and taskType provided
	 * @param taskId
	 * @param taskType
	 * @return Help_Text__c Object
	 */	
	public Help_Text__c getDismissibleFlashesHelpTextId(String taskId, String taskType) {
		Help_Text__c helpText;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', taskType);
		soqlParamMap.put('soqlParam2', taskId);
		String query = 'select id, createdDate from Help_Text__c where Type__c=:soqlParam1 and Task_Id__c=:soqlParam2 '+
						'AND is_deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Help_Text__c> helpTextList = (List<Help_Text__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(helpTextList.isEmpty() == false) {
			helpText = new Help_Text__c();
			helpText = helpTextList[0];
		} else {
			helpText = insertHelpTextRecord(taskId, taskType);
		}
		return helpText;		
	}

	/**
	 * @description method to create new Help_Text record for taskId and taskType provided
	 * @param taskId
	 * @param taskType
	 * @return Help_Text__c inserted record
	 */	
	public Help_Text__c insertHelpTextRecord(String taskId, String taskType) {

		Help_Text__c helpTextObj = new Help_Text__c();
		helpTextObj.Type__c = taskType;
		helpTextObj.Task_Id__c = taskId;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		Help_Text__c insertedObj = (Help_Text__c) SIMPESAPI.accessController().insertAsUser(helpTextObj,
																					new List<Schema.SObjectField>{
																						Help_Text__c.Type__c,
																						Help_Text__c.Task_Id__c
																					});
		
		return insertedObj;
		
	}
	
	/**
	 * @description method to create Help_Text_View records for peopleIds, helpText provided and taskType provided
	 * @param peopleIds
	 * @param helpTextTask
	 * @param taskType
	 */
	public void insertHelptextViewRecords(Set<Id> peopleIds, String helpTextTask, String taskType) {
		logger.logDebug('HelpDao.InsertHelptextViewRecords() -----');
		String helpTextTaskId;
		Help_Text__c helpTextTaskObj = getDismissibleFlashesHelpTextId(helpTextTask, taskType);
		if(helpTextTaskObj != null && String.isNotEmpty(helpTextTaskObj.id)) {
			helpTextTaskId = helpTextTaskObj.id;
			List<Help_Text_View__c> helpTextViewInsertList = new List<Help_Text_View__c>();
			for(Id peopleId : peopleIds) {
				Help_Text_View__c helpTextViewObj = new Help_Text_View__c(People__c = peopleId, Help_Text__c = helpTextTaskId);
				helpTextViewInsertList.add(helpTextViewObj);
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(helpTextViewInsertList, new List<Schema.SObjectField>{
																			Help_Text_View__c.Help_Text__c,
																			Help_Text_View__c.People__c
																		});	
		}	
	}

	/**
	 * @description dismiss the new Integration
	 * @param taskId - id which we have to dismiss
	 */
	public void dismissConnectAccountsPrompt(String taskId) {
		Help_Text_View__c helpTextViewObj = new Help_Text_View__c();
		helpTextViewObj.Help_Text__c = getHelpTextId(taskId);
		helpTextViewObj.People__c = UserContext.peopleId;
		Boolean isRecordExist = false;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', taskId);
		soqlParamMap.put('soqlParam2', UserContext.peopleId);
		String query = 'Select id, Help_Text__c, People__c From Help_Text_View__c where Help_Text__r.Task_Id__c =: soqlParam1 And People__c =: soqlParam2 LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Help_Text_View__c> helpTextViewList = (List<Help_Text_View__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(helpTextViewList.size() > 0) {
			helpTextViewObj = helpTextViewList[0];
			isRecordExist = true;
		}
		if (isRecordExist) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(helpTextViewObj, new List<Schema.SObjectField>{
																				Help_Text_View__c.Help_Text__c,
																				Help_Text_View__c.People__c
																			});
		} else {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(helpTextViewObj, new List<Schema.SObjectField>{
																				Help_Text_View__c.Help_Text__c,
																				Help_Text_View__c.People__c
																			});
		}
	}

	/**
	 * @description this is used to get new integration added in manage app screen
	 * @param integrationConnectedDateTime - used to fetch result only after this dt
	 * @return set of new integration
	 */
	public Set<String> getNewIntegrationsEnabled(Datetime integrationConnectedDateTime) {
		Set<String> newIntegrations = new Set<String>();
		List<String> integrationsToShow = new List<String>{'box', 'dropbox', 'googledrive', 'onedrive', 'sharepoint', 'atlassian', 'servicenow'};
		Map<String, People_Integration__c> peopleIntegrationsMap = getPeopleIntegrations(UserContext.peopleId);
		if(SimpplrContext.integrations != null && integrationConnectedDateTime != null) {
			for(String name : SimpplrContext.integrations.keySet()){
				if(SimpplrContext.integrations.get(name) != null && integrationsToShow.contains(SimpplrContext.integrations.get(name).Name) && SimpplrContext.integrations.get(name).Integration_Enabled__c &&  
					SimpplrContext.integrations.get(name).Connected__c && SimpplrContext.integrations.get(name).Connected_DateTime__c != null && SimpplrContext.integrations.get(name).Connected_DateTime__c > integrationConnectedDateTime &&  
					((peopleIntegrationsMap.get(name) != null && peopleIntegrationsMap.get(name).Connected__c == false) || peopleIntegrationsMap.get(name) == null)){
						if(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE.equalsIgnoreCase(SimpplrContext.integrations.get(name).Name)) {
							if(SimpplrContext.myDriveEnabled == true) {
								newIntegrations.add(name); 
							} else {
								continue;
							}
						} else {
							newIntegrations.add(name); 
						}
						
				}
			}
		}

		if(SimpplrContext.IsBoxIntegrationEnabled && String.isNotBlank(SimpplrContext.BoxUsername) && String.isNotBlank(SimpplrContext.boxManagedPermission) &&  
			SimpplrContext.boxConnectedAt != null && SimpplrContext.boxConnectedAt > integrationConnectedDateTime &&  
			('simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) || 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)) &&  
			((peopleIntegrationsMap.get(IntegrationConstants.INTEGRATION_TYPE_BOX) != null && peopleIntegrationsMap.get(IntegrationConstants.INTEGRATION_TYPE_BOX).Connected__c == false) || peopleIntegrationsMap.get(IntegrationConstants.INTEGRATION_TYPE_BOX) == null)) {
				newIntegrations.add('box'); 
		}
		return newIntegrations;
	}

	/**
	 * @description Fetch all people integration records based on peopleId received
	 * @param peopleId - id of people for which we have to fetch peopleIntegration result
	 * @return Map<String, People_Integration__c>
	 */
	private Map<String, People_Integration__c> getPeopleIntegrations(String peopleId){
        Map<String, People_Integration__c> peopleIntegrationsMap = new Map<String, People_Integration__c>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1',peopleId );
        soqlParamMap.put('soqlParam2', UserInfo.getOrganizationId());
        String query = 'Select Name, Connected__c,User_Name__c, User_Email__c FROM People_Integration__c '+
                                            ' WHERE People__c =: soqlParam1 AND Is_Deleted__c = false AND App_Integration__r.Org_Id__c =: soqlParam2';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People_Integration__c> peopleIntList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        for(People_Integration__c integObj : peopleIntList){
            peopleIntegrationsMap.put(integObj.Name, integObj);
        }

        return peopleIntegrationsMap;
    }
    
}