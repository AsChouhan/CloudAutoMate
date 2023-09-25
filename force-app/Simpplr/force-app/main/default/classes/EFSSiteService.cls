/*
* Purpose: Service class for the Site related activities
* 
* Constructors in EFSSiteService
* 01. EFSSiteService()
* 02. EFSSiteService(EFSAccessService, EFSAccessService)
*
* Functions in EFSSiteService
* 01. void close()
* 02. FolderWrapper createSiteFolder(String, String, Boolean)
* 03. void addMember(String, String, Boolean)
* 04. void addAdmin(String, String, Boolean)
* 05. void removeMember(String, String)
* 06. void removeAdmin(String, String)
*/

public with sharing class EFSSiteService {
	

	// Instance Variables
	private EFSAccessService adminAccess { get; set; }
	private EFSAccessService usrAccess { get; set; }
	public String siteId { get; set; }

	// Class for the response from the Service
	public class FolderWrapper {
		public String sharedFolderId;
		public String folderId;
		public String rCollabId;
		public String rwCollabId;
		public String srchCollabId;
		public String storageType;
	}
		
	public EFSSiteService(String storage) {
		// Fetch the Access from the DB
		this(new EFSAccessService(storage, true), new EFSAccessService(storage, false));
	}
	
	// Constructor for the EFS Site Service
	public EFSSiteService(EFSAccessService aAccess, EFSAccessService uAccess) {
		EFSException.addTrace('EFSSiteService()');
		// Fetch the Access from the DB
		this.adminAccess = aAccess;
		this.usrAccess = uAccess;
	}
	
	// Function to do the clean ups and final steps
	public void close() {
		EFSException.addTrace('close()');
		
    	// Function that saves the token to DB
		if(!this.adminAccess.isSaved()) {
			this.adminAccess.saveToken();
		}
		
		if(!this.usrAccess.isSaved()) {
			this.usrAccess.saveToken();
		}
	}
	
	// Function to create the Site Root Folder and related Groups
	public FolderWrapper createSiteFolder(String siteName, String cgId, Boolean publicFlag) {
		EFSException.addTrace('createSiteFolder(' + siteName + ')');

		FolderWrapper EFSFW = new FolderWrapper();
		
		Criteria.Folder siteFold = new Criteria.Folder();
		siteFold.name = siteName;
		// Set the Parent Folder
		if(this.usrAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			siteFold.directory = '/' + SimpplrContext.applicationName;
		}
		// Create the external folder
		EFSFileService fs = new EFSFileService(this.usrAccess);
		fs.siteId = this.siteId;
		FileListingWrapper siteFoldWrap = fs.createFolder(siteFold);

		EFSFW.folderId = siteFoldWrap.id;
		EFSFW.sharedFolderId = siteFoldWrap.sharedFolderId;
		EFSGroupService gs = new EFSGroupService(this.adminAccess);

		// Create Read Group
		String rGrpKey = gs.createCollaboration(siteName, cgId, 'READ',this.usrAccess.pplInteg.User_Email__c);
		// Create ReadWrite Group
		String rwGrpKey = gs.createCollaboration(siteName, cgId, 'READWRITE',this.adminAccess.appInteg.User_Email__c);

		// Fetch the Root Folder from the Data Model based on the Storage Type
	   	if(this.usrAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
	   		EFSFW.storageType = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
	   		EFSFW.rCollabId = rGrpKey;
	   		EFSFW.rwCollabId = rwGrpKey;

			// Share the folder with R and RW Groups.
			EFSFW.sharedFolderId = fs.shareFolder(siteFoldWrap.fileUrl, siteFoldWrap.sharedFolderId, rGrpKey, rwGrpKey);
			
			// For Public Sites Share the folder with all company group
	   		if(publicFlag) {
	   			fs.shareFolder(siteFoldWrap.fileUrl, EFSFW.sharedFolderId, SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).All_Company_Group_Id__c, null);
	   		}
	   	}
	   	
	   	return EFSFW;
	}
	
	// Function to add member to the group
	public void addMember(String cgId, String memEmail, Boolean isPublic) {
		EFSException.addTrace('addMember(' + cgId + ',' + memEmail + ')');
		
		EFSGroupService gs = new EFSGroupService(this.adminAccess);
		
		// Group Id
		String grpKey = '';
		
		if(this.usrAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			grpKey = cgId + '.r@' + SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Enterprise_Id__c;
			gs.addMember(grpKey, memEmail);
		} 
	}
	
	// Function to add Admin/Manager to the group
	public void addAdmin(String cgId, String memEmail, Boolean isPublic) {
		EFSException.addTrace('addAdmin(' + cgId + ',' + memEmail + ')');
		
		EFSGroupService gs = new EFSGroupService(this.adminAccess);
		
		// Group Id
		String grpKey = '';
		
		if(this.usrAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			grpKey = cgId + '.rw@' + SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Enterprise_Id__c;
			gs.addMember(grpKey, memEmail);
		}
	}
	
	// Function to Remove member to the group
	public void removeMember(String cgId, String memEmail) {
		EFSException.addTrace('removeMember(' + cgId + ',' + memEmail + ')');
		
		EFSGroupService gs = new EFSGroupService(this.adminAccess);
		
		// Group Id
		String grpKey = '';
		
		if(this.usrAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING)
	    || this.usrAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			grpKey = cgId + '.r@' + SimpplrContext.integrations.get(this.usrAccess.fileStorage).Enterprise_Id__c;
			gs.removeMember(grpKey, memEmail);
		} else {

		}
	}
	
	// Function to Remove Admin/Manager to the group
	public void removeAdmin(String cgId, String memEmail) {
		EFSException.addTrace('removeAdmin(' + cgId + ',' + memEmail + ')');
		
		EFSGroupService gs = new EFSGroupService(this.adminAccess);
		
		// Group Id
		String grpKey = '';
		
		if(this.usrAccess.fileStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			grpKey = cgId + '.rw@' + SimpplrContext.integrations.get(this.usrAccess.fileStorage).Enterprise_Id__c;
			gs.removeMember(grpKey, memEmail);
		} else {
			
		}
	}
}