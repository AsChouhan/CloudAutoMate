public with sharing class DBAPISharing {
	public String mainEndpoint = 'https://api.dropboxapi.com/2/sharing/';
	
	DBAPIClient client;
	
	public DBAPISharing(DBAPIClient dbc) {
		this.client = dbc;
	}
	
	// Getter and Setter Methods
	public DBAPIClient getClient() { return this.client; }
	public DBAPISharing setClient(DBAPIClient gdc) {
		this.client = gdc;
		return this;
	}
	
	public ShareFolderRequest getShareFolderRequest(String foldName) {
		DBAPIModelSharing.ShareFolderArg args = new DBAPIModelSharing.ShareFolderArg();
		args.path = foldName;
		return new ShareFolderRequest(this, args);
	}
	
  	public class ShareFolderRequest extends SCoreClient.AbstractClientRequest {
  		public ShareFolderRequest(DBAPISharing fil, DBAPIModelSharing.ShareFolderArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'share_folder', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.SharedFolderMetadata.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public UnshareFolderRequest getUnshareFolderRequest(String foldName) {
		return new UnshareFolderRequest(this, new DBAPIModelSharing.UnshareFolderArg(foldName));
	}
	
  	public class UnshareFolderRequest extends SCoreClient.AbstractClientRequest {
  		public UnshareFolderRequest(DBAPISharing fil, DBAPIModelSharing.UnshareFolderArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'unshare_folder', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(Map<String, String>.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public ListMountableFolderRequest getListMountableFolderRequest(Integer listLimit) {
		return new ListMountableFolderRequest(this, 'list_mountable_folders', new DBAPIModelSharing.ListFolderArgs(listLimit));
	}
	
	public ListMountableFolderRequest getListMountableFolderRequest(String cursor) {
		if(String.isBlank(cursor)) {
			return new ListMountableFolderRequest(this, 'list_mountable_folders', new DBAPIModelSharing.ListFolderArgs(600));			
		}
		
		return new ListMountableFolderRequest(this, 'list_mountable_folders/continue', new DBAPIModelSharing.ListFolderArgs(cursor));
	}
	
  	public class ListMountableFolderRequest extends SCoreClient.AbstractClientRequest {
  		public ListMountableFolderRequest(DBAPISharing fil, String method, DBAPIModelSharing.ListFolderArgs args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + method, 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.ListFoldersResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public ListFileMembersRequest getListFileMembersRequest(String fileId, String cursor) {
		if(String.isBlank(cursor)) {
			return new ListFileMembersRequest(this, 'list_file_members', new DBAPIModelSharing.ListFileMembersArgs(fileId, 5));			
		}
		
		return new ListFileMembersRequest(this, 'list_file_members/continue', new DBAPIModelSharing.ListFileMembersArgs(cursor));
	}
	
  	public class ListFileMembersRequest extends SCoreClient.AbstractClientRequest {
  		public ListFileMembersRequest(DBAPISharing fil, String method, DBAPIModelSharing.ListFileMembersArgs args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + method, 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.SharingListMembersResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public ListFolderMembersRequest getListFolderMembersRequest(String folderId, String cursor) {
		if(String.isBlank(cursor)) {
			return new ListFolderMembersRequest(this, 'list_folder_members', new DBAPIModelSharing.ListFolderMembersArgs(folderId, 5));			
		}
		
		return new ListFolderMembersRequest(this, 'list_folder_members/continue', new DBAPIModelSharing.ListFolderMembersArgs(cursor));
	}
	
  	public class ListFolderMembersRequest extends SCoreClient.AbstractClientRequest {
  		public ListFolderMembersRequest(DBAPISharing fil, String method, DBAPIModelSharing.ListFolderMembersArgs args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + method, 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.SharingListMembersResult.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public ListFileMembersBatchRequest getListFileMembersBatchRequest(List<String> files) {
		return new ListFileMembersBatchRequest(this, 'list_file_members/batch', new DBAPIModelSharing.ListFileMembersBatchArgs(files));			
	}
	
  	public class ListFileMembersBatchRequest extends SCoreClient.AbstractClientRequest {
  		public ListFileMembersBatchRequest(DBAPISharing fil, String method, DBAPIModelSharing.ListFileMembersBatchArgs args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + method, 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(List<DBAPIModelSharing.ListFileMembersBatchResult>.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public MountFolderRequest getMountFolderRequest(String folderId) {
		return new MountFolderRequest(this, new DBAPIModelSharing.MountFolderArg(folderId));
	}
	
  	public class MountFolderRequest extends SCoreClient.AbstractClientRequest {
  		public MountFolderRequest(DBAPISharing fil, DBAPIModelSharing.MountFolderArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'mount_folder', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.SharedFolderMetadata.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	public UnmountFolderRequest getUnmountFolderRequest(String folderId) {
		return new UnmountFolderRequest(this, new DBAPIModelSharing.MountFolderArg(folderId));
	}
	
  	public class UnmountFolderRequest extends SCoreClient.AbstractClientRequest {
  		public UnmountFolderRequest(DBAPISharing fil, DBAPIModelSharing.MountFolderArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'unmount_folder', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.DBAPIModelAbstract.class));
		}
	}
	
	public TransferFolderRequest getTransferFolderRequest(String folderId, String dpId) {
		return new TransferFolderRequest(this, new DBAPIModelSharing.TransferFolderArg(folderId, dpId));
	}
	
  	public class TransferFolderRequest extends SCoreClient.AbstractClientRequest {
  		public TransferFolderRequest(DBAPISharing fil, DBAPIModelSharing.TransferFolderArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'transfer_folder', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.DBAPIModelAbstract.class));
		}
	}
	
  	public class AddMemberRequest extends SCoreClient.AbstractClientRequest {
  		public AddMemberRequest(DBAPISharing fil, DBAPIModelSharing.AddFolderMemberArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'add_folder_member', 
				  'POST', 
				  args, 
				  null);
		}
	}
	
  	public class UpdateMemberRequest extends SCoreClient.AbstractClientRequest {
  		public UpdateMemberRequest(DBAPISharing fil, DBAPIModelSharing.UpdateFolderMemberArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'update_folder_member', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(DBAPIModelSharing.UpdateMemberResponse.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
  	public class RemoveMemberRequest extends SCoreClient.AbstractClientRequest {
  		public RemoveMemberRequest(DBAPISharing fil, DBAPIModelSharing.RemoveFolderMemberArg args) {
			super(fil.getClient(), 
				  fil.mainEndpoint + 'remove_folder_member', 
				  'POST', 
				  args, 
				  new SCoreJsonDeserializer(Map<String, String>.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
}