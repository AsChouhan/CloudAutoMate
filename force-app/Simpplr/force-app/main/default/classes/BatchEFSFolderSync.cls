/* 
* Batch Class for the Sites which the user is Admin
*   --> Sync the Application Name with EFS
*   --> Sync the Site Name with EFS
* 	--> Create the Site Root Folders in EFS for selected user
* 	--> Create the Site Root Folders in EFS for all Sites
*/

public with sharing class BatchEFSFolderSync implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
	private String req = null;
	private String input = null;
	private String appName = '';
	private String domainName = '';
    private String gdUserEmail = '';
	// map with site id as key and CG id as value needed when user disconnects
	Map<Id,CollaborationGroupMember> siteIdWithCGM;
	
	//grp ids that connecting user is part of (member,manager,owner)
	List<String> listOfGrpId;
	Boolean dropboxPublicSiteFlag = false;
	List<String> grpIdList = new List<String>(); // when user sync batch is called for app or siteadd or site(storage changed)
	private String efsType;
	
	public BatchEFSFolderSync(String typ, String recIds, String storageType) {
		efsType = storageType;
		req = typ;
		input = recIds;
		appName = SimpplrContext.applicationName;
		domainName =  SimpplrContext.integrations.get(efsType).Enterprise_Id__c;
		 
		// USER - When User connect to EFS - 20
		// SITE - when site storage is changed to EFS
		// SITERW - when site storage is changed to EFS and Site Root Folder permission is set to ReadWrite 
		// SITEADD - When Site is created - 50 [This should be obsolete without App Level Storage]
		// SITENAME - When the Site Name is Changed - 50
		// SITEDEL - When Site Storage is Changed from EFS to other value - 01
		// APP - When App storage is set to EFS - 01 [This should be obsolete without App Level Storage]
		// APPDEL - When the App Storage is reset from EFS - 01 [This should be obsolete without App Level Storage]
		// APPNAME - When the App Name Changed - 50
		// ADMINDEL - When the Service account is disconnected from integration - 01
		// SITEMADEPUBLIC - When the Site set as Public
		// SITEMADEPRIVATE - When the Site set as Private
		
		ManageApplicationDao.setEFSBatchProcessingFlag(true, efsType);
	}

    public BatchEFSFolderSync(String typ, String recIds, String storageType, String gdUserEmailArg) {
		efsType = storageType;
		req = typ;
		input = recIds;
		appName = SimpplrContext.applicationName;
		domainName =  SimpplrContext.integrations.get(efsType).Enterprise_Id__c;
		ManageApplicationDao.setEFSBatchProcessingFlag(true, efsType);
        gdUserEmail = gdUserEmailArg;
	}
	
	public database.querylocator start(Database.BatchableContext bc){
		String query = '';
		if('USERDISCONNECT'.equalsIgnoreCase(req)){
			siteIdWithCGM = new map<Id,CollaborationGroupMember>();
		} else if('USER'.equalsIgnoreCase(req)){
			listOfGrpId = new List<String>();
		}
		query = ' SELECT Id, Chatter_Group_Id__c, Site_Type__c, Name, createdById ' +
	    				   ' from Simpplr_Site__c';
		
		Set<Id> siteIds = new Set<Id>(); 
		
		// USER - When User connect to EFS - 20
		if(req.equalsIgnoreCase('USER')) {
			String usrId = input;
			try {
				EFSGroupService gs = new EFSGroupService(efsType);
	        	gs.addMember(SimpplrContext.integrations.get(efsType).All_Company_Group_Id__c, UserContext.integrations.get(efsType).User_Email__c);
	        	gs.close();				
			} catch (EFSException ue) {
				Utility.sendExceptionEmail('BatchEFSFolderSync[S](' + req + ',' + input + +',' + siteIds + ')', ue);
			}			// Site for which the user is Owner
			Set<Id> myCGIds = new Set<Id>();
			for(CollaborationGroupMember grp: [Select id, CollaborationGroup.ownerId, CollaborationGroupid 
												from CollaborationGroupMember 
												where memberId =:usrId AND CollaborationGroup.IsArchived=false]) {
				listOfGrpId.add(grp.CollaborationGroupid);
				if(grp.CollaborationGroup.ownerId == usrId){
					myCGIds.add(grp.CollaborationGroupid);
				}
			}
		} else if(req.equalsIgnoreCase('APP') || req.equalsIgnoreCase('APPNAME')) {
			// Apply for sites which is not having EFS folders
			
			// Fetch all Sites using EFS as file storage
			for(Simpplr_Site__c site : [Select Id , Chatter_Group_Id__c FROM Simpplr_Site__c WHERE 
					File_Storage_Source__c = :efsType AND is_deleted__c =false]) {
				siteIds.add(site.Id);
			}
			
			if(req.equalsIgnoreCase('APP')) {
				// Sites for which EFS system folder is existing
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', efsType);
				String folderQuery = 'SELECT Site__c FROM Folder__c where Type__c = :soqlParam1 AND Is_System_Folder__c = true AND is_deleted__c = false';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
					siteIds.remove(fold.Site__c);
				}
			}
		} else if(req.equalsIgnoreCase('APPDEL') || req.endsWithIgnoreCase('ADMINDEL')) {
			// Apply for all Site records which has EFS site root folders
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', efsType);
			String folderQuery = 'SELECT Site__c FROM Folder__c where Type__c = :soqlParam1 AND Is_System_Folder__c = true AND is_deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
				siteIds.add(fold.Site__c);
			}
		} else if(req.equalsIgnoreCase('SITE') || 
				  req.equalsIgnoreCase('SITERW') ||
				  req.equalsIgnoreCase('SITEADD') || 
				  req.equalsIgnoreCase('SITENAME') || 
				  req.equalsIgnoreCase('SITEDEL') || 
				  req.equalsIgnoreCase('SITEMADEPUBLIC') || 
				  req.equalsIgnoreCase('SITEMADEPRIVATE')) {
			siteIds = (Set<Id>) JSON.deserialize(input, Set<Id>.class);
			if(req.equalsIgnoreCase('SITE')) {
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', efsType);
				soqlParamMap.put('soqlParam2', siteIds);
				String folderQuery = 'SELECT Site__c FROM Folder__c where Type__c = :soqlParam1 AND Is_System_Folder__c = true AND is_deleted__c = false AND Site__c IN:soqlParam2';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
					siteIds.remove(fold.Site__c);
				}
			} else if(req.equalsIgnoreCase('SITEDEL')) {
				Set<Id> actualEFSSiteIds = new Set<Id>();
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', efsType);
				soqlParamMap.put('soqlParam2', siteIds);
				String folderQuery = 'SELECT Site__c FROM Folder__c where Type__c = :soqlParam1 AND Is_System_Folder__c = true AND is_deleted__c = false AND Site__c IN:soqlParam2';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
					actualEFSSiteIds.add(fold.Site__c);
				}
				siteIds.clear();
				siteIds.addAll(actualEFSSiteIds);
			}
		} else if(req.equalsIgnoreCase('USERDISCONNECT')) {
			String usrId = input;
			Set<Id> allCGIds = new Set<Id>();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', usrId);
			soqlParamMap.put('soqlParam2', efsType);
			String queryStr = 'Select Group_Id_Set__c from People_Integration__c where User__c =:soqlParam1 and is_deleted__c =false and Name =:soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People_Integration__c> peopleIntegObj = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			
			if(!peopleIntegObj.isEmpty() && peopleIntegObj.get(0).Group_Id_Set__c != null) {
				allCGIds = new Set<Id>();
				for(String cgKey : peopleIntegObj.get(0).Group_Id_Set__c.split(',')) {
					allCGIds.add(cgKey);	
				} 
				
				// find only CG for which user is member
				List<CollaborationGroupMember> CGMList = [select CollaborationGroupId, CollaborationRole, CollaborationGroup.OwnerId from CollaborationGroupMember where 
										CollaborationGroupId IN:allCGIds AND MemberId=:usrId AND CollaborationGroup.IsArchived=false];
				
				Map<Id,CollaborationGroupMember> cgIdWithCGM = new Map<Id,CollaborationGroupMember>();
				
				for(CollaborationGroupMember cgm : CGMList) {
					cgIdWithCGM.put(cgm.CollaborationGroupId,cgm);
				}
				
				for(Simpplr_Site__c siteObj: [select id,Chatter_Group_Id__c from simpplr_site__c where chatter_group_id__c IN:cgIdWithCGM.keyset() and Is_Deleted__c=false]){
					siteIdWithCGM.put(siteObj.id,cgIdWithCGM.get(siteObj.Chatter_Group_Id__c));
				}
			} else {
				siteIdWithCGM.put(usrId,null);	// Passing dummy ID so the execute has no records to process
			}

			siteIds = siteIdWithCGM.keySet();
		}
		
		if(siteIds.size() == 1) {
			for(Id siteId: siteIds) {
				query += ' WHERE ID = \'' + siteId + '\' AND';	
			}
		} else if(siteIds.size() > 1) {
			query += ' WHERE ID IN :siteIds AND';	
		} else {
			query += ' WHERE ID=NULL AND ';
		}
		
		query += ' is_deleted__c = false';
    	
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, sObject[] objects) {
    	    	
    	Boolean dropboxFlag = efsType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) ? true : false;
    	Boolean spFlag = efsType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING) ? true : false;
    	Boolean odFlag = efsType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING) ? true : false;
    	
    	Boolean simpplrManaged = EFSConstants.simpplrManagedStorages.contains(efsType) ? true : false;
    	
    	Boolean appNameFlag = req.equalsIgnoreCase('APPNAME') ? true : false;
    	Boolean siteNameFlag = req.equalsIgnoreCase('SITENAME') ? true : false;
    	
    	List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)objects;
    	Id siteOwnerId;
		Set<Id> siteIds = new Set<Id>();
		for(Simpplr_Site__c site: siteList) {
			siteIds.add(site.id);
		}
		String siteId = '';
    	// For each Site record		
    	try {
    		EFSAccessService adminAccess = new EFSAccessService(efsType, true);
	    	if(simpplrManaged && (siteNameFlag || appNameFlag)) {
	    		// Sync the Folder Names
	    		EFSFileService EFSFileServiceObj = new EFSFileService(efsType);
	    		List<Folder__c> foldList = new List<Folder__c>();

				EFSGroupService gs = new EFSGroupService(adminAccess);
				String grpEmail = '';
				String grpName = '';
				String grpDesc = '';
				
				if(appNameFlag) {
					appName = input;								
					// Change the Company Group
					grpEmail = UserInfo.getOrganizationId() + '@' + domainName;
					
					if (dropboxFlag) {
						grpName = appName + '[' + UserInfo.getOrganizationId() + '] Company Group';
					} else {
						grpName = appName + ' Company Group';
					}
					 
					grpDesc = 'READ Group for ' + appName;
					gs.updateGroup(grpEmail, grpName, grpDesc);
				}
				
				// Sites for which EFS system folder is existing
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', efsType);
				soqlParamMap.put('soqlParam2', siteIds);
				String folderQuery = 'SELECT Id, Site__r.Chatter_Group_Id__c, Site__r.Name, External_Folder_Id__c, Is_System_Folder__c, EFS_Read_Write_Collaboration_Id__c, Path__c ' +
					' FROM Folder__c where Type__c = :soqlParam1 AND Is_System_Folder__c = true AND is_deleted__c = false AND Site__c IN:soqlParam2';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
					grpEmail = fold.Site__r.Chatter_Group_Id__c + '.r@' + domainName;
					grpName = fold.Site__r.Name + ' Users';
					grpDesc = 'READ Group for ' + fold.Site__r.Name;
					gs.updateGroup(grpEmail, grpName, grpDesc);
					
					grpEmail = fold.Site__r.Chatter_Group_Id__c + '.rw@' + domainName;
					grpName = fold.Site__r.Name + ' Administrators';
					grpDesc = 'READWRITE Group for ' + fold.Site__r.Name;
					gs.updateGroup(grpEmail, grpName, grpDesc);
				}
				
				EFSFileServiceObj.close();
				gs.close();
				
				if(appNameFlag && dropboxFlag) {
					ManageApplicationDao.setEFSRootFolderId('/'+appName);
				}				
	    	} else if(req.equalsIgnoreCase('APPDEL') || req.equalsIgnoreCase('SITEDEL') 
	    			|| req.equalsIgnoreCase('ADMINDEL') || req.equalsIgnoreCase('USERDISCONNECT')) {
	    		// When user disconnects, only remove his groups membership if he is only a member/manager.	    		
	    		if(req.equalsIgnoreCase('USERDISCONNECT') && 
	    		   siteIdWithCGM.get(siteList[0].Id).CollaborationGroup.OwnerId != input) {
	    			if(simpplrManaged){
		    			EFSSiteService ss = new EFSSiteService(efsType);
	    				String role = siteIdWithCGM.get(siteList[0].Id).CollaborationRole;
			    		if('standard'.equalsIgnoreCase(role)) {
			    			ss.removeMember(siteIdWithCGM.get(siteList[0].Id).CollaborationGroupId,UserContext.integrations.get(efsType).User_Email__c);
			    		} else {
			    			ss.removeAdmin(siteIdWithCGM.get(siteList[0].Id).CollaborationGroupId,UserContext.integrations.get(efsType).User_Email__c);
			    		}
		    			ss.close();
	    			}
	    		} else {
		    		// Remove the Internal Folders and External Collaborations
					List<Folder__c> delFolderList = new List<Folder__c>();
					siteId = siteList[0].id;
					EFSGroupService gs = new EFSGroupService(adminAccess);
					EFSFileService fs = null;
					// Get the Chatter Group Owner Id for the site
					if(!req.equalsIgnoreCase('SITEDEL')) {
						try {
							siteOwnerId = [Select OwnerId from CollaborationGroup WHERE Id =: siteList[0].Chatter_Group_Id__c][0].OwnerId;	
						} catch (Exception e) {
							siteOwnerId = siteList[0].createdById;
						}
						EFSAccessService.setUser(siteOwnerId);
					}	    				
					
					fs = new EFSFileService(efsType);
					
					// Remove the Site Folder Records and Groups.
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', siteId);
					soqlParamMap.put('soqlParam2', efsType);
					String folderQuery = 'SELECT Id, Site__c, Site__r.Chatter_Group_Id__c, Is_System_Folder__c, External_Folder_Id__c, EFS_Shared_Folder_Id__c, Path__c, ' +
						' EFS_Read_Collaboration_Id__c, EFS_Read_Write_Collaboration_Id__c, EFS_Search_Collaboration_Id__c ' +
						' FROM Folder__c WHERE Site__c = :soqlParam1 AND Type__c = :soqlParam2 AND is_deleted__c = false';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
						try {
							if(dropboxFlag) {
								if(fold.Is_System_Folder__c == true) {
									// Remove the groups	
									gs.deleteGroup(fold.Site__r.Chatter_Group_Id__c + '.r@' + domainName);
									gs.deleteGroup(fold.Site__r.Chatter_Group_Id__c + '.rw@' + domainName);
									
									// Unshare the Folder from All Company Group
									fs.unshareFolder(fold.EFS_Shared_Folder_Id__c, SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).All_Company_Group_Id__c);
								}
							}			
						} catch (Exception e) {
							// All exception should be handled and the records should be deleted.							
						}
							
						delFolderList.add(fold);
					}
					
					if((spFlag) && req.equalsIgnoreCase('SITEDEL')){
						fs.deleteAWSRecordForFolder(siteId, true, null, null, null, efsType);
					}
					if(req.equalsIgnoreCase('SITEDEL') || req.equalsIgnoreCase('USERDISCONNECT')){
						grpIdList.add(siteList[0].Chatter_Group_Id__c);
					}
					
					if(delFolderList.size() > 0) {
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().deleteAsUser(delFolderList);
					}
					fs.close();
					gs.close();
	    		}
	    	} else if(//simpplrManaged &&
	    			  (req.equalsIgnoreCase('USER') || 
	    			   req.equalsIgnoreCase('APP') || 
	    			   req.equalsIgnoreCase('SITEADD') || 
	    			   req.equalsIgnoreCase('SITE') ||
	    			   req.equalsIgnoreCase('SITERW'))) {
				// Create the External and Internal Folders
    			List<Folder__c> siteEFSFolderList = new List<Folder__c>();
    			
    			// Override the user
    			if(siteList.size()>0){
    				// Get the Chatter Group Owner Id for the site
    				try {
    					siteOwnerId = [Select OwnerId from CollaborationGroup WHERE Id =: siteList[0].Chatter_Group_Id__c][0].OwnerId;	
    				} catch (Exception e) {
    					siteOwnerId = siteList[0].createdById;
    				}
    				
	    			EFSAccessService.setUser(siteOwnerId);
	    			
	    			//Pulling up the below variable in order to make it stateful and available in finish
	    			//////Boolean dropboxPublicSiteFlag = false;
			    	// if site owner is connected only then create folders
			    	if(simpplrManaged && String.isNotBlank(UserContext.Integrations.get(efsType).User_Email__c)) {
				    	EFSSiteService EFSSiteServiceObj = new EFSSiteService(efsType);
				    	EFSFileService fs = new EFSFileService(efsType);
						for(Simpplr_Site__c site: siteList) {
							siteId = site.id;
				    		EFSSiteService.FolderWrapper EFSFW = null;
				    		EFSSiteServiceObj.siteId = site.id;
				    		
				    		if(site.Site_Type__c.equalsIgnoreCase('Public')){
								EFSFW = EFSSiteServiceObj.createSiteFolder(site.Name, site.Chatter_Group_Id__c, true);
								if(dropboxFlag) { dropboxPublicSiteFlag = true; }
							} else {
								EFSFW = EFSSiteServiceObj.createSiteFolder(site.Name, site.Chatter_Group_Id__c, false);
							}
							
							Folder__c newFoldObj = new Folder__c();
							newFoldObj.Name__c = EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get(
									String.isNotBlank(efsType) ? efsType.toLowerCase() : efsType);
							newFoldObj.Site__c = site.Id;
							newFoldObj.Type__c = efsType;
		    				newFoldObj.Is_System_Folder__c = true;
					    	newFoldObj.External_Folder_Id__c = EFSFW.folderId;
					    	newFoldObj.EFS_Read_Collaboration_Id__c = EFSFW.rCollabId;
					    	newFoldObj.EFS_Read_Write_Collaboration_Id__c = EFSFW.rwCollabId;
					    	if(dropboxFlag) {
						    	newFoldObj.EFS_Shared_Folder_Id__c = EFSFW.sharedFolderId;
						    	newFoldObj.Path__c = '/'+SimpplrContext.ApplicationName+'/'+site.Name;
								if(req.equalsIgnoreCase('SITERW')) {
			    					newFoldObj.Permissions__c = 'READWRITE';
			    					fs.changeFolderSharing(EFSFW.sharedFolderId, EFSFW.rCollabId, 'READWRITE');
								} else {
									newFoldObj.Permissions__c = 'READ';
								}
					    	} else {
					    		newFoldObj.EFS_Search_Collaboration_Id__c = EFSFW.srchCollabId;
					    	}
							
							siteEFSFolderList.add(newFoldObj);
						}

						EFSSiteServiceObj.close();
						fs.close();
			    	}
			    	
			    	if(!simpplrManaged && (spFlag || odFlag)) {
			    		new Folderdao().createMSStorageFoldersForSite(siteList[0].id, '', efsType, true, '', '', '', null, '');
			    	}
						
					if(req.equalsIgnoreCase('APP') || req.equalsIgnoreCase('SITE') || req.equalsIgnoreCase('SITERW') || req.equalsIgnoreCase('SITEADD')){
						grpIdList.add(siteList[0].Chatter_Group_Id__c);
					}
    			}
		    	// Insert the Folder records
		    	if(siteEFSFolderList.size() > 0){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(siteEFSFolderList, new List<Schema.SObjectField>{
																					Folder__c.Name__c,
																					Folder__c.Site__c,
																					Folder__c.Type__c,
																					Folder__c.Permissions__c,
																					Folder__c.Is_System_Folder__c,
																					Folder__c.External_Folder_Id__c,
			   																		Folder__c.EFS_Read_Collaboration_Id__c,
			   																		Folder__c.EFS_Read_Write_Collaboration_Id__c,
			   																		Folder__c.EFS_Shared_Folder_Id__c,
			   																		Folder__c.Path__c,
			   																		Folder__c.EFS_Search_Collaboration_Id__c});
		    	}
	    	} else if(simpplrManaged && (req.equalsIgnoreCase('SITEMADEPUBLIC') || req.equalsIgnoreCase('SITEMADEPRIVATE'))) {
				
				// Get the Chatter Group Owner Id for the site
				try {
					siteOwnerId = [Select OwnerId from CollaborationGroup WHERE Id =: siteList[0].Chatter_Group_Id__c][0].OwnerId;	
				} catch (Exception e) {
					siteOwnerId = siteList[0].createdById;
				}
    				
				EFSAccessService.setUser(siteOwnerId);
		    	// if site owner is connected only then create folders
		    	if(String.isNotBlank(UserContext.Integrations.get(efsType).User_Email__c)) {
					EFSFileService fs = new EFSFileService(efsType);
	
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', efsType);
					soqlParamMap.put('soqlParam2', siteIds);
					String folderQuery = 'SELECT Id, Site__c, External_Folder_Id__c, Path__c, EFS_Shared_Folder_Id__c, EFS_Search_Collaboration_Id__c ' +
						' FROM Folder__c where Type__c = :soqlParam1 AND Is_System_Folder__c = true AND is_deleted__c = false AND Site__c IN :soqlParam2';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
						if(req.equalsIgnoreCase('SITEMADEPUBLIC')) {
							if(dropboxFlag) {
								fs.shareFolder(fold.Path__c, fold.EFS_Shared_Folder_Id__c, SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).All_Company_Group_Id__c, null);
							}
						} else {
							if(dropboxFlag) {
								// Unshare the Folder from All Company Group
								fs.unshareFolder(fold.EFS_Shared_Folder_Id__c, SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).All_Company_Group_Id__c);
							}
						}
					}
					fs.close();
		    	}
	    	} 
    	} catch(Exception e) {
    		Utility.sendExceptionEmail('BatchEFSFolderSync[E](' + req + ',' + input + +',' + siteIds + ')', e);
    	}
    }
    
    public void finish(Database.BatchableContext bc) {

    	try {
			if(req.equalsIgnoreCase('ADMINDEL')) {
				if(EFSConstants.simpplrManagedStorages.contains(efsType)) {
					try {
						EFSGroupService gs = new EFSGroupService(efsType);
						gs.deleteGroup(UserInfo.getOrganizationId()+'@'+SimpplrContext.integrations.get(efsType).Enterprise_Id__c);
						
						gs.close();
					} catch (Exception e) {
						Utility.sendExceptionEmail('BatchEFSFolderSync[F](' + req + ',' + input + ')',e);		
					}
				}
				ManageApplicationDao.disconnectEFSAdmin(efsType);
				// the below was fail proof to avoid having external file storage as source after admin/service account disconnect
				ManageApplicationDao.resetSiteConfigStorage(null, efsType, 'Intranet', null);				
			} else if(req.equalsIgnoreCase('APPDEL') && !Test.isRunningTest()) {
				Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('APPDEL'), 5000);
			} else if(req.equalsIgnoreCase('USERDISCONNECT')) {
				if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(efsType) || ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(efsType)){

					ManageApplicationDao.deleteLinkedFoldersByUser(input, efsType);
				}
				ManageApplicationDao.disconnectEFSUser(efsType, gdUserEmail);
				ManageApplicationDao.resetSiteConfigStorage(input, efsType, 'Intranet', null);
			} else if(req.equalsIgnoreCase('USER')) {
				Database.executeBatch(new BatchEFSUserSync(req, JSON.serialize(listOfGrpId), efsType), 6);
			} else if(//EFSConstants.simpplrManagedStorages.contains(efsType) && !Test.isRunningTest() &&
					  (req.equalsIgnoreCase('SITE') ||
					   req.equalsIgnoreCase('SITERW') || 
					   req.equalsIgnoreCase('APP') || 
					   req.equalsIgnoreCase('SITEADD') || 
					   req.equalsIgnoreCase('SITEDEL'))) {
				Database.executeBatch(new BatchEFSUserSync(req, JSON.serialize(grpIdList),efsType),1);
				if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(efsType)) {
					// For Dropbox, the EFS_Batch_Flag__c has to be set for all users whose flag is false
					Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('SETMOUNTFLAG'), 5000);
				}
			} else if(req.equalsIgnoreCase('SITENAME') || req.equalsIgnoreCase('APPNAME')) {
				if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(efsType)) {
					Boolean nameFlag = FolderDao.syncPathName(efsType, appName, null);

					if(nameFlag) {
						// For Dropbox, the EFS_My_Drive_Id__c and EFS_Batch_Flag__c has to be set for all users whose flag is false
						Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('SETMOUNTFLAG'), 5000);
					}
				}
			} else if('SITEMADEPUBLIC'.equalsIgnoreCase(req)){
				if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(efsType)) {
					// For Dropbox, the EFS_Batch_Flag__c has to be set for all users whose flag is false
					Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('SETMOUNTFLAG'), 5000);
				}
			}
		} catch (Exception e) {
	    	Utility.sendExceptionEmail('BatchEFSFolderSync[F](' + req + ',' + input + ')', e);
	    }
    		
		ManageApplicationDao.setEFSBatchProcessingFlag(false, efsType);
	}   
}