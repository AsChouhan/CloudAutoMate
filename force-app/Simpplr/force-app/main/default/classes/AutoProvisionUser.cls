public class AutoProvisionUser {

    public static void assignPermissionSets(List<Id> listOfUserIds) {
        List<PermissionSet> listOfPermissionSet = [SELECT Id FROM PermissionSet WHERE Name LIKE 'Simpplr_User%'];
        if(listOfPermissionSet.size() > 0) {
            Set<Id> permissionSetIds = new Set<Id>();
            for(PermissionSet permSet:listOfPermissionSet) {
                permissionSetIds.add(permSet.Id);
            }
            List<PermissionSetAssignment> listOfAssignment = [SELECT    Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment
                                                              WHERE     PermissionSetId IN :permissionSetIds 
                                                              AND       AssigneeId IN: listOfUserIds];
            
            Map<Id, Set<String>> assignmentMap = new Map<Id, Set<String>>();
            for (PermissionSetAssignment assignmentObj: listOfAssignment) {
                Set<String> permSetList = assignmentMap.get(assignmentObj.AssigneeId);
                permSetList = permSetList == null ? new Set<String>() : permSetList;
                permSetList.add(assignmentObj.PermissionSetId);
                assignmentMap.put(assignmentObj.AssigneeId, permSetList);
            }
            
            List<PermissionSetAssignment> listOfPermissionSetAssignment = new List<PermissionSetAssignment>();
            for(PermissionSet permissionSetRec:listOfPermissionSet) {
                for(Id userId:listOfUserIds) {
                    Set<String> assignedPermSetList = assignmentMap.containsKey(userId) ? assignmentMap.get(userId) : new Set<String>();
                    if (!assignedPermSetList.contains(permissionSetRec.Id)) {
                        PermissionSetAssignment permisssionSetAssignmentRec = new PermissionSetAssignment(AssigneeId=userId, PermissionSetId=permissionSetRec.Id);
                        listOfPermissionSetAssignment.add(permisssionSetAssignmentRec);
                    }   
                }
            }
            
            if(listOfPermissionSetAssignment.isEmpty() == false) {
                Database.insert(listOfPermissionSetAssignment, false);
            }
            assignSimpplrPackageLicense(listOfUserIds);
        }
    }
    
    private static void assignSimpplrPackageLicense(List<Id>  listOfUserIds) {
        if(String.isNotBlank(SimpplrContext.appConfig.Package_Name__c)){
            
            List<User> userList = [Select id, isActive From User where UserType = 'Standard' and isActive = true and id in: listOfUserIds];
            listOfUserIds.clear();
            for(User userObj : userList) {
                listOfUserIds.add(userObj.id);
            }

			List<PackageLicense> listOfPackageLicense = [SELECT Id, AllowedLicenses, UsedLicenses FROM PackageLicense WHERE NamespacePrefix = :SimpplrContext.appConfig.Package_Name__c Limit 1];
			List<UserPackageLicense> listOfUserPackageLicense = new List<UserPackageLicense>();
			if(!listOfPackageLicense.isEmpty() && listOfPackageLicense[0].AllowedLicenses > 0){
				if(listOfPackageLicense[0].AllowedLicenses > listOfPackageLicense[0].UsedLicenses){
					List<UserPackageLicense> licenseAssigmentList = [SELECT UserId FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: SimpplrContext.appConfig.Package_Name__c AND UserId IN :listOfUserIds];
                    List<Id> userLicenseAssigned = new List<Id>();
                    for(UserPackageLicense upl:licenseAssigmentList) {
                        userLicenseAssigned.add(upl.UserId);
                    }

                    List<Id> userLicenseNotAssigned = new List<Id>();
                    for(Id usrId:listOfUserIds) {
                        if(!userLicenseAssigned.contains(usrId)){
                            userLicenseNotAssigned.add(usrId);
                        }
                    }

                    Integer listOfUserIdSize = userLicenseNotAssigned.size();

					if(listOfPackageLicense[0].AllowedLicenses >= listOfPackageLicense[0].UsedLicenses + listOfUserIdSize){
						for(Id userId : userLicenseNotAssigned){
							UserPackageLicense userpackageLicenseRec = new UserPackageLicense(PackageLicenseId = listOfPackageLicense[0].Id, Userid = userId);
							listOfUserPackageLicense.add(userpackageLicenseRec);
						}
					} else {
						List<Id> listOfUseridAllowed = new List<Id>();
						List<Id> listOfUseridNotAllowed = new List<Id>();
						Integer allowedLicenseNumber = listOfPackageLicense[0].AllowedLicenses - listOfPackageLicense[0].UsedLicenses;
						for(Integer i = 0; i < allowedLicenseNumber; i++){
							listOfUseridAllowed.add(userLicenseNotAssigned[i]);			
						}
						for(Id userId : listOfUseridAllowed){
							UserPackageLicense userpackageLicenseRec = new UserPackageLicense(PackageLicenseId = listOfPackageLicense[0].Id, Userid = userId);
							listOfUserPackageLicense.add(userpackageLicenseRec);
						}															
					}
						
					if(!listOfUserPackageLicense.isEmpty()){
						insert listOfUserPackageLicense;
					}						
				}
				else{
					EmailUtility.sendEmailForUnavailableLicense(listOfPackageLicense[0].AllowedLicenses, listOfUserIds, SimpplrContext.simpplrOrg);		
				}		
			}		
		}
	}

	
    public static void createPeopleInKaltura(List<Id> listOfUserIds) {    
        Map<String, Object> sqlParamMap = new Map<String, Object>();
        sqlParamMap.put('soqlParam1', listOfUserIds);
        String peopleQuery = 'SELECT Id, First_Name__c, Last_Name__c, Email__c, Full_Name__c, App_Moderation_Permission__c, '
                    + ' Postal_Code__c, City__c, State__c, Country__c '
                    + ' FROM People__c WHERE User__c in : soqlParam1 and Id not in (SELECT People__c from People_Integration__c where name=\'native_video\')';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People__c> listOfPeopleInserted = ((List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, sqlParamMap));

        List<NativeVideoWrapper.peopleWrapper> listofPeopleToBeSynced = new List<NativeVideoWrapper.peopleWrapper>();
        for(people__c peopleObj :listOfPeopleInserted) {
            NativeVideoWrapper.peopleWrapper wrapperObj = new NativeVideoWrapper.peopleWrapper();
            wrapperObj.peopleId = peopleObj.id;
            wrapperObj.firstName = peopleObj.First_Name__c;
            wrapperObj.lastName = peopleObj.Last_Name__c;
            wrapperObj.email = peopleObj.Email__c;
            wrapperObj.name = peopleObj.Full_Name__c;
            wrapperObj.country = peopleObj.Country__c;
            wrapperObj.state = peopleObj.State__c;
            wrapperObj.city = peopleObj.City__c;
            wrapperObj.zip = peopleObj.Postal_Code__c;
            wrapperObj.isAppManager = 'Yes'.equalsIgnoreCase(peopleObj.App_Moderation_Permission__c);
            
            listofPeopleToBeSynced.add(wrapperObj);				
        }

        if(listofPeopleToBeSynced.size() > 0) {
            String USER_CREATION_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/user-manager';                
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('org_id', SimpplrContext.simpplrOrgId);
            requestBody.put('peopleList', (JSON.serialize(listofPeopleToBeSynced)));
            requestBody.put('action', 'syncDeltaUsers');
            HttpResponse res = Utility.getResponseFromAWS(USER_CREATION_ENDPOINT, requestBody);
        }
    }
    
    @future(callout=true)
    public static void autoProvision(List<Id> listOfUserIds) {    
        if(Test.isRunningTest() || SimpplrContext.appConfig == null){
            return;
        }
        if(SimpplrContext.isNativeVideo) {
            try {
                createPeopleInKaltura(listOfUserIds);
            } catch(Exception ex) {
                // putting try catch because if any chance invocation of method failed it will not stop permission set assignment/ licence assignment
            }
        }
        if(SimpplrContext.appConfig.Auto_provisioning_Process_Enabled__c == true) {
            assignPermissionSets(listOfUserIds);
        }
    }
}