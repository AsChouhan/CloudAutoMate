/*
* Class for Processing the User SYNC operations for any EFS based on the storage
* Listed below are the valid requests for processing
*    1. SITEDEL				-
*    2. ADMINDEL			-
*    3. Mandatory Sites		-	
*    4. MOUNT				-	Specific to Dropbox to Mount and Move the folder to Application Root Folder
*    5. GoogleAddMembersToGroup
*/
public without sharing class BatchEFSUserSync implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
	private String request = null;
	private Set<Id> grpIdSet = new Set<Id>();
	
	private String efsType; 	
	private Map<String, String> mountFolderPathMap = new Map<String, String>();
	
	public BatchEFSUserSync(String req, String grpIds, String storageType){
		efsType = storageType;
	
		if (req != null) {
			request = req;

		} else {
			request = 'DEFAULT';
		}
		
		if (request.equalsIgnoreCase('MOUNT') && 
				efsType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			UserDao.setMountBatchFlag(false, UserInfo.getUserId());			

		} else {
			
			if (grpIds != null) {
				grpIdSet = (Set<Id>) JSON.deserialize(grpIds, Set<Id>.class);
			}

		}

	}
	
	public database.querylocator start(Database.BatchableContext bc) {	
		String query = '';

		if (!UserContext.Integrations.containsKey(efsType)) {
			query = 'SELECT Id from Folder__c limit 0';
		
		} else {
			
			if (request.equalsIgnoreCase('MOUNT')) {
				query = 'SELECT Id, Name, EFS_Shared_Folder_Id__c, Path__c from Folder__c where Type__c =:efsType AND Is_System_Folder__c=TRUE AND Is_Deleted__c=FALSE';
				
				// Get the Mountable Folder List
				try {
					EFSFileService fs = new EFSFileService(efsType);
					mountFolderPathMap = Test.isRunningTest()?new Map<String,String>{'test'=>'test'} :fs.listFolders();
					fs.close();

				} catch (Exception e) {
					
					if (e.getMessage().startsWith('TokenType') && UserContext.Integrations.get(efsType).Connected__c) {
					 	// Reset the Mount Flag
					 	UserDao.setMountBatchFlag(true, UserInfo.getUserId());			
					
					} else {
					 	throw new EFSException('Mount Folders Listing Error', e.getMessage());
					}

				}

			} else {
				query = 'Select id, Group_Id_Set__c, Unsuccessful_Group_Id_Set__c, User__c, User_Email__c from People_Integration__c where User__r.IsActive = true AND User_Email__c!=null AND is_deleted__c=false AND name=:efsType';
				
				if (grpIdSet.size() > 0) {
					List<CollaborationGroupMember> grpMemList = [Select memberId from CollaborationGroupMember where CollaborationGroupId IN:grpIdSet];
					Set<Id> membersOfGrp = new Set<Id>();

					for (CollaborationGroupMember cgmObj : grpMemList) {
						membersOfGrp.add(cgmObj.memberId);
					}

					query += ' AND User__c IN :membersOfGrp';
				}

			}

		}
		
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
		try {

			if (request.equalsIgnoreCase('MOUNT')) {
				// For the list of Folder records create mount request
				List<Folder__c> folderList = (List<Folder__c>)listOfsObject;
				String path = '';
				
				EFSFileService mfs = new EFSFileService(efsType);
				
				for (Folder__c fold: folderList) {
					// Shared Folder exist in Mountable List
					
					if (mountFolderPathMap.containsKey(fold.EFS_Shared_Folder_Id__c)) {
						path = mountFolderPathMap.get(fold.EFS_Shared_Folder_Id__c);

						try {
							// Mount if the path is blank/null
							if (String.isBlank(path)) {
								path = mfs.mountFolder(fold.EFS_Shared_Folder_Id__c);
							} 
							
							// Move the folder to right location
							if (!(fold.Path__c).equalsIgnoreCase(path)) {
								// Delete the old folders if any
								try {
									mfs.deleteFile(fold.Path__c);

								} catch(EFSException de) {
									// If folder doesn't exist no problem
								}
								
								mfs.updateFileName(path, fold.Path__c);
							}

						} catch (EFSException updateException) {
							// Handle the exception
							Utility.sendExceptionEmail('BatchEFSUserSync[E](' + request + ',' + 'Path:' + path + ' && Site Root Folder:' + fold.Path__c + ')', updateException);
						}

					}

				}

				mfs.close();

			} else {
				
				List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)listOfsObject;
                Map<Id,People_Integration__c> userIdWithPeopleInteg = new Map<Id,People_Integration__c>();
                for (People_Integration__c peopleIntegObj : peopleIntegList) {
                    userIdWithPeopleInteg.put(peopleIntegObj.User__c, peopleIntegObj);
                }

                Set<Id> userIdSet = new Set<Id>();
                userIdSet.addAll(userIdWithPeopleInteg.keySet());
                // Make a Map containing User Id as key and collaborationgroup ids as value with respect to key
                String grpQuery = 'Select CollaborationGroupId,MemberId,CollaborationGroup.CollaborationType,CollaborationRole from CollaborationGroupMember where MemberId IN:userIdSet AND CollaborationGroup.IsArchived=false';
                
                if (grpIdSet.size() > 0) {
                    grpQuery += ' AND CollaborationGroupId IN:grpIdSet';
                }

                // Inialize the variables
                List<CollaborationGroupMember> cgmList = Database.query(grpQuery);

                //====> Google drive adding members to site group for provided sites. 
                if (efsType == IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE) {
                    Map<Id, Set<People_Integration__c>> mapOfCGrpIdWithSetOfPeopleInteg = new Map<Id, Set<People_Integration__c>>();
                    
                    for (CollaborationGroupMember groupMemberObj: cgmList) {
                        
                        
                        if (mapOfCGrpIdWithSetOfPeopleInteg.containsKey(groupMemberObj.CollaborationGroupId)) {
                            Set<People_Integration__c> setOfPeopleIntgTemp = new Set<People_Integration__c>();
                            setOfPeopleIntgTemp = mapOfCGrpIdWithSetOfPeopleInteg.get(groupMemberObj.CollaborationGroupId);
                            setOfPeopleIntgTemp.add(userIdWithPeopleInteg.get(groupMemberObj.MemberId));
                            mapOfCGrpIdWithSetOfPeopleInteg.put(groupMemberObj.CollaborationGroupId, setOfPeopleIntgTemp);

                        } else {
                            Set<People_Integration__c> setOfPeopleIntgTemp = new Set<People_Integration__c>();
                            setOfPeopleIntgTemp.add(userIdWithPeopleInteg.get(groupMemberObj.MemberId));
                            mapOfCGrpIdWithSetOfPeopleInteg.put(groupMemberObj.CollaborationGroupId, setOfPeopleIntgTemp);
                        }

                        
                    }

                    if (!mapOfCGrpIdWithSetOfPeopleInteg.keySet().isEmpty()) {

                        for  (Id groupId: mapOfCGrpIdWithSetOfPeopleInteg.keySet()) {

                            for (People_Integration__c peopleIntObj: mapOfCGrpIdWithSetOfPeopleInteg.get(groupId)) {
                                Boolean statusFlag = addMemberToGoogleSiteGroup(groupId , peopleIntObj.User_Email__c);
                            }

                        }

                    }
                    
                // People Pref List containing people connected to EFS
                } else {
					
					Set<Id> groupIdSet = new Set<Id>();
					Set<String> usrIdSetToProcess = new Set<String>();
					Map<String,Map<String,CollaborationGroupMember>> userIdWithCGMMap = new Map<String,Map<String,CollaborationGroupMember>>();
					
					for (CollaborationGroupMember cgm : cgmList) {
						groupIdSet.add(cgm.CollaborationGroupId);
						usrIdSetToProcess.add(cgm.memberId);
						
						if (!userIdWithCGMMap.containsKey(cgm.MemberId)) {
	 						userIdWithCGMMap.put(cgm.MemberId,new Map<String,CollaborationGroupMember>());
						}

						userIdWithCGMMap.get(cgm.MemberId).put(cgm.CollaborationGroupId,cgm);
					}

					List<People_Integration__c> listToUpdate = new List<People_Integration__c>();
					String successfulGrpIdStr = '';
					String unsuccessfulGrpIdStr = '';
					Set<String> successfulGrpIdSet = null;
					Set<String> unsuccessfulGrpIdSet = null;
								
					//when SITEDEL happen remove that group from members of that site
					if (request.equalsIgnorecase('SITEDEL') || 
							request.equalsIgnoreCase('USERDISCONNECT')) {
						
						if (grpIdSet.size() > 0) {

							for (String userId : usrIdSetToProcess) {
								People_Integration__c pplInteg = userIdWithPeopleInteg.get(userId);		
								successfulGrpIdStr = ''; 
								unsuccessfulGrpIdStr = '';
								successfulGrpIdSet = stringToSet(pplInteg.Group_Id_Set__c, ',');
								unsuccessfulGrpIdSet = stringToSet(pplInteg.Unsuccessful_Group_Id_Set__c, ',');
													
								for (Id grpId: groupIdSet) {
									successfulGrpIdSet.remove((String)grpId);
									unsuccessfulGrpIdSet.remove((String)grpId);
								}
								
								successfulGrpIdStr = setToString(successfulGrpIdSet, ',');
								unsuccessfulGrpIdStr = setToString(unsuccessfulGrpIdSet, ',');
								listToUpdate.add(new People_Integration__c(Id = userIdWithPeopleInteg.get(userId).Id, 
										Group_Id_Set__c = successfulGrpIdStr,
										Unsuccessful_Group_Id_Set__c=unsuccessfulGrpIdStr));
							}

						}

					} else {
						// Need only those sites which are connected to EFS else member wont be added to respective group
						Map<String,Simpplr_Site__c> siteConnectedToEFSMap = new Map<String,Simpplr_Site__c>();
						// check for mandatory sites
						String siteQuery = 'Select Chatter_Group_Id__c,Site_Type__c '+ 
								' FROM Simpplr_Site__c WHERE Chatter_Group_Id__c '+
								' IN:groupIdSet AND File_Storage_Source__c=:efsType';
						
						List<Simpplr_Site__c> siteList = Database.query(siteQuery);

						for (Simpplr_Site__c siteObj : siteList) {
							siteConnectedToEFSMap.put(siteObj.Chatter_Group_Id__c, siteObj);
						}
						
						EFSGroupService gs = new  EFSGroupService(efsType);

						for (String userId : usrIdSetToProcess) {
							People_Integration__c pplInteg = userIdWithPeopleInteg.get(userId);		
							successfulGrpIdStr = ''; 
							unsuccessfulGrpIdStr = '';
							successfulGrpIdSet = stringToSet(pplInteg.Group_Id_Set__c, ',');
							unsuccessfulGrpIdSet = stringToSet(pplInteg.Unsuccessful_Group_Id_Set__c, ',');
							
							if (EFSConstants.clientManagedStorages.contains(efsType)) {

								for (String cgIdStr: grpIdSet) {
									successfulGrpIdSet.add(cgIdStr);
								}

							} else {
								/* Remove CollaborationGroup ids for which member is already added to respective EFS group*/
								List<String> grpIdsToAdd = new List<String>();
								List<String> unsuccessfulGrps = new List<String>();
								
								Set<String> allGrpIdsToProcess = userIdWithCGMMap.get(userId).keySet();
								allGrpIdsToProcess.removeAll(successfulGrpIdSet);
								allGrpIdsToProcess.retainAll(siteConnectedToEFSMap.keySet());
								
								List<String> grpListConvertedFromSet = new List<String>(allGrpIdsToProcess);
								Integer counter=0,flag=0;
								List<String> listToProcess;
								integer traversalflag = math.mod(grpListConvertedFromSet.size(), 25) == 0 ? 1:0;
								
								while (traversalflag <= grpListConvertedFromSet.size() / 25 ) {
									listToProcess=new List<String>();
									counter=0;

									while (counter < 25 && flag<grpListConvertedFromSet.size()) {
										listToProcess.add(grpListConvertedFromSet.get(flag) + 
												('Admin'.equalsIgnoreCase(userIdWithCGMMap.get(userId).get(grpListConvertedFromSet.get(flag)).CollaborationRole)?'.rw@':'.r@')+SimpplrContext.integrations.get(efsType).Enterprise_Id__c) ;
										flag++;
										counter++;
									}

									traversalflag++;
									
									if (listToProcess.size() > 0) {
										Map<String,List<String>> mapToReturn = gs.addMember(listToProcess,userIdWithPeopleInteg.get(userId).User_Email__c);
										grpIdsToAdd.addAll(mapToReturn.get('Successful'));
										unsuccessfulGrps.addAll(mapToReturn.get('Unsuccessful'));
									}

								}
								
								successfulGrpIdSet.addAll(grpIdsToAdd);
								unsuccessfulGrpIdSet.addAll(unsuccessfulGrps);
							}

							successfulGrpIdStr = setToString(successfulGrpIdSet, ',');
							unsuccessfulGrpIdStr = setToString(unsuccessfulGrpIdSet, ',');
							listToUpdate.add(new People_Integration__c(Id = userIdWithPeopleInteg.get(userId).Id, 
									Group_Id_Set__c = successfulGrpIdStr,
									Unsuccessful_Group_Id_Set__c = unsuccessfulGrpIdStr));
						}

						gs.close();
					}

					if (listToUpdate.size() > 0) {
						update listToUpdate;
                    }
                }

			}

		} catch (Exception e) {
			Utility.sendExceptionEmail('BatchEFSUserSync[E](' + request + ',' + grpIdSet + ')',e);
		}

	}
	
	public void finish(Database.BatchableContext bc) {
		
		if (request.equalsIgnoreCase('USER') && UserContext.Integrations.containsKey(efsType)) {
			
			if (efsType.equalsIgnorecase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) && UserContext.Integrations.get(efsType).Connected__c){
				Database.executeBatch(new BatchEFSUserSync('MOUNT', null,efsType), 1);
			}

		}
		
	}

	public String setToString(Set<String> strSet, String delimiter) {
   		return strSet.size()>0 ? String.join(new List<String>(strSet), delimiter) : '';
   	}

	public static Set<String> stringToSet(String inpStr, String delimiter) {
   		return String.isNotBlank(inpStr) ? new Set<String>(inpStr.split(delimiter)) : new Set<String>();
    }

    private Boolean addMemberToGoogleSiteGroup (String chatterGrpId, String memberEmail) {
        String externalEndPoint = EFSConstants.GOOGLE_API_ADD_GROUP_MEMBER;
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
        String groupEmailAddress = chatterGrpId + '.r@' + 
                SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).Enterprise_Id__c;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('groupEmailAddress', groupEmailAddress);
        mapOfRequestParam.put('memberEmail', memberEmail);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(externalEndPoint); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', simpDri);
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        HttpResponse res;
        Boolean responsFlag = false; 

        if (!Test.isRunningTest()) {
            res = http.send(req);

            if (res.getStatusCode() == 200){
                String googleResponseStr = res.getBody();
                Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(googleResponseStr);
                
                if (responseObj.get('status') == 'success'){
                    responsFlag =  true;  

                } 

            } 

        }

        return responsFlag; 
    }
       

}