public with sharing class DBAPIModelSharing {
    public class ShareFolderArg extends SCoreAbstractJsonSerializable {
    	public String path;
    	public String acl_update_policy;
    	public Boolean force_async;
    	public String member_policy;
    	public String shared_link_policy;
    	public String viewer_info_policy;
    	//public FolderAction actions;
    	//public String link_settings;
    	
    	public ShareFolderArg() {
    		acl_update_policy = 'owner';
    		force_async = false;
    		member_policy = 'team';
    		shared_link_policy = 'members';
    		viewer_info_policy = 'disabled';		
    	}
    }
    
    public class UnshareFolderArg extends SCoreAbstractJsonSerializable {
    	private String shared_folder_id { get; set; }
    	private Boolean leave_a_copy { get; set; }
    	
    	public UnshareFolderArg(String folderId) {
    		this.shared_folder_id = folderId;
    		this.leave_a_copy = false;
    	}
    }
    
    public class MountFolderArg extends SCoreAbstractJsonSerializable {
    	private String shared_folder_id;
    	
    	public MountFolderArg(String folderId) {
    		this.shared_folder_id = folderId;
    	}
    }
    
    public class TransferFolderArg extends SCoreAbstractJsonSerializable {
    	private String shared_folder_id;
    	private String to_dropbox_id;
    	
    	public TransferFolderArg(String folderId, String dpId) {
    		this.shared_folder_id = folderId;
    		this.to_dropbox_id = dpId;
    	}
    }
    
    public class AddFolderMemberArg extends SCoreAbstractJsonSerializable {
    	public String shared_folder_id;
    	public List<AddMember> members;
    	public Boolean quiet;
    	public String custom_message;
    	
    	public AddFolderMemberArg(Map<String, String> memAccessMap) {
    		quiet = false;
    		members = new List<AddMember>();
    		for(String memId: memAccessMap.keySet()) {
    			members.add(new AddMember(memId, memAccessMap.get(memId)));
    		}
    	}
    }
    
    public class UpdateFolderMemberArg extends SCoreAbstractJsonSerializable {
    	private String shared_folder_id { get; set; }
    	private Map<String, String> member { get; set; }
    	private String access_level { get; set; }
    	
    	public UpdateFolderMemberArg(String folderId, String groupId, String perm) {
    		this.shared_folder_id = folderId;
    		this.member = Utility.getSelectorArg('dropbox_id', groupId);
    		this.access_level = 'viewer';
    		if(perm.equalsIgnoreCase('READWRITE') || perm.equalsIgnoreCase('editor')) {
    			this.access_level = 'editor';
    		}
    	}
    }
    
	public class UpdateMemberResponse extends DBAPIModelAbstract {
		private Map<String, String> access_level;
		private String warning;
		private ParentFolderAccessInfo access_details;
	}
	
	public class ParentFolderAccessInfo {
		private String folder_name;
		private String shared_folder_id;
		private List<MemberPermission> permissions;
		private String path;
	}
	
	public class MemberPermission {
		private Map<String, String> action;
		private Boolean allow;
		private Map<String, String> reason;
	}
    
    public class RemoveFolderMemberArg extends DBAPIModelAbstract {
    	private String shared_folder_id { get; set; }
    	private Map<String, String> member { get; set; }
    	private Boolean leave_a_copy { get; set; }
    	
    	public RemoveFolderMemberArg(String folderId, String groupId) {
    		this.shared_folder_id = folderId;
    		this.leave_a_copy = false;
    		this.member = Utility.getSelectorArg('dropbox_id', groupId);
    	}
    }
    
    public class AddMember {
    	public Map<String, String> member;
    	public Map<String, String> access_level;
    	
    	public AddMember(String memId, String access) {
    		member = new Map<String, String>();
    		member.put('.tag', 'dropbox_id');
    		member.put('dropbox_id', memId);
    		
    		access_level = new Map<String, String>();
    		access_level.put('.tag', access);
    	}
    }
    
    public class FolderAction {
    	
    }
    
    public class SharedFolderMetadata {
    	public String tag;
    	public String async_job_id;
    	public Map<String, String> access_type;
    	public Boolean is_inside_team_folder;
    	public Boolean is_team_folder;
    	public String name;
    	public FolderPolicy policy;
    	public String preview_url;
    	public String shared_folder_id;
    	public Datetime time_invited;
    	public String path_lower;
    	public SharedContentLinkMetadata link_metadata;
    	public List<FolderPermission> permissions;
    }
    
    public class FolderPermission {
    	public Map<String, String> action;
    	public Boolean allow;
    	public Map<String, String> reason;
    }
    
    public class FolderPolicy {
    	public Map<String, String> acl_update_policy;
    	public Map<String, String> shared_link_policy;
    	public Map<String, String> member_policy;
    	public Map<String, String> resolved_member_policy;
    	public Map<String, String> viewer_info_policy;
    }
    
    public class SharedContentLinkMetadata {
    	public List<Map<String, String>> audience_options;
    	public Map<String, String> current_audience;
    	public Map<String, String> link_permissions;
    	public Boolean password_protected;
    	public String url;
    	public Map<String, String> access_level;
    	public AudienceRestrictingSharedFolder audience_restricting_shared_folder;
    	public Datetime expiry;
    	public AudienceExceptions audience_exceptions;
    }
    
    public class AudienceRestrictingSharedFolder {
    	public String shared_folder_id;
    	public String name;
    	public Map<String, String> audience;
    }
    
    public class AudienceExceptions {
    	public Integer count;
    	public List<Map<String, String>> exceptions;
    }
    
    public class ListFolderArgs extends SCoreAbstractJsonSerializable {
    	private Integer reqLimit { get; set; }
    	private String cursor { get; set; }
    	// private List<Map<String, String>> actions { get; set; }
    	
    	public ListFolderArgs(Integer lim) {
    		this.reqLimit = lim;
    		this.cursor = null;
    	}
    	
    	public ListFolderArgs(String cursorString) {
    		this.cursor = cursorString;
    		this.reqLimit = null;
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();    		
    		
    		if(this.cursor == null) {
    			outputMap.put('limit', this.reqLimit);
    		} else {
    			outputMap.put('cursor', this.cursor);
    		}
    		
    		return JSON.serialize(outputMap, true);
    	}
    }
    
    public class ListFoldersResult extends DBAPIModelAbstract {
    	public List<SharedFolderMetadata> entries;
    	public String cursor;
    }
    
    public class UserInfo {
    	public String account_id { get; set; }
    	private Boolean same_team { get; set; }
    	private String team_member_id { get; set; }	
    }
    
    public class GroupInfo {
    	private String group_name { get; set; }
    	private String group_id { get; set; }
    	private Map<String, String> group_management_type { get; set; }
    	private Map<String, String> group_type { get; set; }
    	private Boolean is_member { get; set; }
    	private Boolean is_owner { get; set; }
    	private Boolean same_team { get; set; }
    	private String group_external_id { get; set; }
    	private Integer member_count { get; set; }    	
    }
    
    public abstract class MembershipInfo {
    	public Map<String, String> access_type { get; set; }
    	public List<MemberPermission> permissions { get; set; }
    	public String initials { get; set; }
    	public Boolean is_inherited { get; set; }
    	public DateTime time_last_seen { get; set; }
    }
    
    public class UserFileMembershipInfo extends MembershipInfo {
    	public UserInfo user { get; set; }
    }
    
    public class GroupMembershipInfo extends MembershipInfo {
    	public GroupInfo grp { get; set; }
    }
    
    public class InviteeMembershipInfo extends MembershipInfo {
    	public Map<String, String> invitees { get; set; }
    }
    
    public class ListFileMembersArgs extends SCoreAbstractJsonSerializable {
    	private String file { get; set; }
    	private Boolean include_inherited { get; set; }
    	private Integer reqLimit { get; set; }
    	private String cursor { get; set; }

    	public ListFileMembersArgs(String fileId, Integer lim) {
    		this.file = fileId;
    		this.reqLimit = lim;
    		this.cursor = null;
    	}
    	
    	public ListFileMembersArgs(String cursorString) {
    		this.cursor = cursorString;
    		this.reqLimit = null;
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();    		
    		
    		if(this.cursor == null) {
    			outputMap.put('file', this.file);
    			outputMap.put('include_inherited', true);
    			outputMap.put('limit', this.reqLimit);
    		} else {
    			outputMap.put('cursor', this.cursor);
    		}
    		
    		return JSON.serialize(outputMap, true);
    	}
    }
    
    public class ListFolderMembersArgs extends SCoreAbstractJsonSerializable {
    	private String shared_folder_id { get; set; }
    	private Integer reqLimit { get; set; }
    	private String cursor { get; set; }

    	public ListFolderMembersArgs(String folderId, Integer lim) {
    		this.shared_folder_id = folderId;
    		this.reqLimit = lim;
    		this.cursor = null;
    	}
    	
    	public ListFolderMembersArgs(String cursorString) {
    		this.cursor = cursorString;
    		this.reqLimit = null;
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();    		
    		
    		if(this.cursor == null) {
    			outputMap.put('shared_folder_id', this.shared_folder_id);
    			outputMap.put('limit', this.reqLimit);
    		} else {
    			outputMap.put('cursor', this.cursor);
    		}
    		
    		return JSON.serialize(outputMap, true);
    	}
    }
    
    public class SharingListMembersResult extends DBAPIModelAbstract {
    	public List<UserFileMembershipInfo> users;
    	public List<GroupMembershipInfo> groups;
    	public List<InviteeMembershipInfo> invitees;
    	public String cursor;
    }
    
    public class ListFileMembersBatchArgs extends SCoreAbstractJsonSerializable {
    	private List<String> files { get; set; }
    	private Integer reqLimit { get; set; }
    	
    	public ListFileMembersBatchArgs(List<String> fileList) {
    		this.files = fileList;
    		this.reqLimit = 5;
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();    		
    		
    		outputMap.put('files', this.files);
    		outputMap.put('limit', this.reqLimit);
    		
    		return JSON.serialize(outputMap, true);
    	}
    }
    
    public class ListFileMembersBatchResult extends DBAPIModelAbstract {
    	public String file;
    	public ListFileMembersIndividualResult result;
    }
    
    public class ListFileMembersIndividualResult {
		public ListFileMembersCountResult result;
    	public Map<String, String> access_error;
    }
    
    public class ListFileMembersCountResult {
    	public List<SharingListMembersResult> members;
    	public Integer member_count;
    }
}