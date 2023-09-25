/*
* Purpose: Service class for the Group related activities
* 
* Constructor
* 1. EFSGroupService()
* 2. EFSGroupService(EFSAccessService)
* 
* Functions defined in the Class
* 01. void close()
* 02. String createGroup(String, String, String)
* 03. String updateGroup(String, String, String)
* 04. boolean deleteGroup(String)
* 05. boolean addMember(String, String)
* 06. boolean removeMember(String, String)
* 07. String createCollaboration(String, String, String)
* 08. boolean addMember(List<String>, String)
* 08. boolean addMember(String, List<String>)
*
*/
public with sharing class EFSGroupService {
	

	// Instance Variables
	public EFSAccessService clientAccess { get; set; }
	
	// For Dropbox Client
	public DBAPIClient dbClient { get; set; }
	
	// For Sharepoint/Onedrive Client
	public MSAPIClient msClient { get; set; }
	
	// Abstract Client for the execution and response handling
	public SCoreClient.AbstractClient client { get; set; }
		
	// Constructor for the Collaboration Service
	public EFSGroupService(String storage) {
		this(new EFSAccessService(storage, true));
	}
	
	// Constructor for the Collaboration Service
	public EFSGroupService(EFSAccessService access) {
		EFSException.addTrace('EFSGroupService()');
		if(!access.isAdmin()) {
			throw new EFSException('INCORRECT ACCESS', 'Please share Admin Access for this request');	
		}
		
		// Fetch the Access from the DB
		this.clientAccess = access;
		
		// Function that abstracts the Access Token Refresh from the Service, Provider classes
		if(this.clientAccess.isAccessExpired()) {
			this.clientAccess.refreshToken();
		}
		
		SCoreClient.Credentials cred = new SCoreClient.Credentials(clientAccess.getTokenType(), clientAccess.getAccessToken());
		// Based on the File Storage type set the client 
		if(this.clientAccess.dropboxFlag) {
			dbClient = new DBAPIClient(cred);			
		} else if(this.clientAccess.boxFlag) {

		} else if(this.clientAccess.sharepointFlag || this.clientAccess.onedriveFlag) {
			msClient = new MSAPIClient(cred, this.clientAccess.fileStorage);			
		}
	}
	
	// Function to do the clean ups and final steps
	public void close() {
		EFSException.addTrace('close()');
		
    	// Function that saves the token to DB
		if(!this.clientAccess.isSaved()) {
			this.clientAccess.saveToken();
		}
	}
	
	// Create Group
	public String createGroup(String name, String description, String email) {
		//logger.logDebug('EFSGroupService createGroup() ----name----' + name);
		EFSException.addTrace('createGroup()');
		if(this.clientAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)){
			DBAPIGroup grp = new DBAPIGroup(this.dbclient);
			DBAPIGroup.CreateRequest newGrpReq;
			try{
				newGrpReq = grp.getCreateRequest(name, email.toLowerCase()); 
				DBAPIModelGroup.FullInfo newGrpInfo = (DBAPIModelGroup.FullInfo)newGrpReq.execute(); 
				return newGrpInfo.group_id;
			} catch(SCoreAppException appEx) {
				if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT) {
					DBAPIModelGroup.GroupMetadataReqArg reqArgs = new DBAPIModelGroup.GroupMetadataReqArg();
					reqArgs.group_external_ids  = new List<String>{email.toLowerCase()};
					reqArgs.group_Info_Req_Type = 'group_external_ids';
					DBAPIGroup.GroupInfoRequest grpInfoReq = grp.getGroupInfoRequest(reqArgs);
					List<DBAPIModelGroup.FullInfo> grpInfoList = (List<DBAPIModelGroup.FullInfo>)grpInfoReq.execute();
					if(String.isNotBlank(grpInfoList[0].tag) && 'group_info'.equalsIgnoreCase(grpInfoList[0].tag)){
						return grpInfoList[0].group_id;
					}
				}
				this.close();
				throw new EFSException(newGrpReq, 'GROUP CREATION ERROR', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
			}
		}
		return '';
	}
	
	// Update Group
	public String updateGroup(String grpEmail, String name, String description) {
		//logger.logDebug('EFSGroupService updateGroup() ----name----' + name);
		EFSException.addTrace('updateGroup()');
		
		if(this.clientAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)){
			DBAPIModelGroup.UpdateArgs updArg = new DBAPIModelGroup.UpdateArgs(); 

			if(grpEmail.endsWithIgnoreCase(this.clientAccess.appInteg.Enterprise_Id__c)) {
				updArg.id_field = 'group_external_id';
			} else {
				updArg.id_field = 'group_id';
			}
			
			updArg.id_value = grpEmail.toLowerCase();
			updArg.return_members = true; 
			updArg.new_group_name = name;
			DBAPIGroup grp = new DBAPIGroup(this.dbclient);
			DBAPIGroup.UpdateRequest updReq = grp.getUpdateRequest(updArg);
			try{ 
				DBAPIModelGroup.FullInfo updGrpInfo = (DBAPIModelGroup.FullInfo)updReq.execute();
			} catch(SCoreAppException appEx) {
				this.close();
				throw new EFSException(updReq, 'UPDATION ERROR', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
			}
		}
		return '';
	}
	
	// Delete Group
	public boolean deleteGroup(String grpemail) {
		//logger.logDebug('EFSGroupService updateGroup() ----name----' + name);
		EFSException.addTrace('deleteGroup()');
		Boolean retFlag = false;
		
		if(this.clientAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			DBAPIGroup grp = new DBAPIGroup(this.dbclient);
			DBAPIGroup.DeleteRequest delReq = null;
			
			if(grpemail.endsWithIgnoreCase(this.clientAccess.appInteg.Enterprise_Id__c)) {
				delReq = grp.getDeleteRequest('group_external_id', grpemail.toLowerCase());	
			} else {
				delReq = grp.getDeleteRequest('group_id', grpemail);
			}

			try{
				Map<String, String> delResp = (Map<String, String>)delReq.execute(); 
			} catch(SCoreAppException appEx) {
				// Dropbox returns Conflist 409 if the group doesn't exist	
				if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT) {
					return true;
				} else {
					this.close();
					throw new EFSException(delReq, 'DELETION ERROR', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
				}
			}
		}
		return retFlag;
	}
	
	// Add Member to the Group
	public boolean addMember(String grpKey, String usrKey) {
		EFSException.addTrace('addMember('+grpKey +','+usrKey+')');
		Boolean retFlag = false;
		if(this.clientAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			DBAPIMember.AddRequest addReq;
			try{
				DBAPIMember mem = new DBAPIMember(this.dbClient);
				List<String> userEmails = new List<String>(); 
				userEmails.add(usrKey);
				if(grpKey.endsWithIgnoreCase(this.clientAccess.appInteg.Enterprise_Id__c)) {
					addReq = mem.getAddRequest('group_external_id', grpKey.toLowerCase(), 'email', userEmails, false);	
				} else {
					addReq = mem.getAddRequest('group_id', grpKey, 'email', userEmails, false);
				}
				DBAPIModelMember.ChangeResult addResp = (DBAPIModelMember.ChangeResult)addReq.execute(); 
	
				retFlag = true;
			} catch(SCoreAppException appEx) {
				if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT) {
					// User Email is already Existing in the Group Membership
					return true;
				} else if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_NOT_FOUND) {
					//GroupKey is not existing
					return false;
				}
				this.close();
				throw new EFSException(addReq, 'MEMBER CREATION ERROR', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
			}
		} else {
			
		}
		return retFlag;
	}

	// Add Member to the Multiple Groups
	public Map<String,List<String>> addMember(List<String> grpKeyList, String usrKey) {
		EFSException.addTrace('addMember(List<String>, String)');
		//List<Boolean> statusList = new List<Boolean>();
		List<String> grpsForWhichUserWasAdded = new List<String>();
		List<String> grpsForWhichUserWasnotAdded = new List<String>();
		if(this.clientAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			DBAPIMember mem = new DBAPIMember(this.dbClient);
			List<String> userEmails = new List<String>(); 
			userEmails.add(usrKey);
			DBAPIMember.AddRequest addReq;
			
			for(String grpKey : grpKeyList){
				if(grpKey.endsWithIgnoreCase(this.clientAccess.appInteg.Enterprise_Id__c)) {
					addReq = mem.getAddRequest('group_external_id', grpKey.toLowerCase(), 'email', userEmails, false);	
				} else {
					addReq = mem.getAddRequest('group_id', grpKey, 'email', userEmails, false);
				}
				
				try { 
					DBAPIModelMember.ChangeResult addResp = (DBAPIModelMember.ChangeResult)addReq.execute();
					grpsForWhichUserWasAdded.add(grpKey.subString(0,18));
				} catch (SCoreAppException ae) {
					grpsForWhichUserWasnotAdded.add(grpKey.subString(0,18));
				} 	
			}
		}
		
		Map<String,List<String>> mapToReturn = new Map<String,List<String>>();
		mapToReturn.put('Successful',grpsForWhichUserWasAdded);
		mapToReturn.put('Unsuccessful',grpsForWhichUserWasnotAdded);
		return mapToReturn;
	}
	
	// Remove Member from the Group
	public boolean removeMember(String grpKey, String usrKey) {
		EFSException.addTrace('removeMember(' + grpKey + ',' + usrKey + ')');
		Boolean retFlag = false;
		
		if(this.clientAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)){
			DBAPIMember mem = new DBAPIMember(dbClient);
			List<String> userEmails = new List<String>();
			userEmails.add(usrKey);

			DBAPIMember.RemoveRequest remReq;
			
			if(grpKey.endsWithIgnoreCase(this.clientAccess.appInteg.Enterprise_Id__c)) {
				remReq = mem.getRemoveRequest('group_external_id', grpKey.toLowerCase(), 'email', userEmails, true);	
			} else {
				remReq = mem.getRemoveRequest('group_id', grpKey, 'email', userEmails, true);
			}				
 
			try {
				DBAPIModelMember.ChangeResult remResp = (DBAPIModelMember.ChangeResult)remReq.execute(); 
			} catch(SCoreAppException appEx) {
				if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT) {
					// Group/Member is not existing. Dropbox Returns 409 for most of the failures.
					return true;
				}
				this.close();
				throw new EFSException('MEMBER UPDATION ERROR', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
			}
		}
		return retFlag;
	}
	
	// Function to create Collaboration
	public String createCollaboration(String siteName, String cgId, String perm, String userEmail) {
		EFSException.addTrace('createCollaboration()');
		// Create the Groups
		String grpName = siteName;
		String grpEmail = '';
		String grpId = '';
		if(perm.equalsIgnoreCase('READWRITE')) {
			grpName += ' Administrators';
		} else if(perm.equalsIgnoreCase('READ')) {
			grpName += ' Users';
		} else {
			throw new EFSException('INVALID PERMISSION','Valid values are READ/READWRITE');
		}
	    // Execute code based on the storage
   		grpEmail = cgId + ('read'.equalsIgnoreCase(perm)?'.r':'.rw') + '@' + this.clientAccess.appInteg.Enterprise_Id__c;
   		grpId = createGroup(grpName, perm + ' Group for ' + siteName, grpEmail);
   		addMember(grpId, userEmail);
	   	return grpId;
	}	
}