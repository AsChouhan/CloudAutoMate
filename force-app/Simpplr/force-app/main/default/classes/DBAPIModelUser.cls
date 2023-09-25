public with sharing class DBAPIModelUser extends DBAPIModelAbstract {
	public String account_id;
	public DPName name;
	public String email;
	public Boolean email_verified;
	public String locale;
	public String referral_link;
	public Boolean is_paired;
	public UnionType account_type;
	public RootInfo root_info;
	public String profile_photo_url;
	public String country;
	public FullTeam team;
	public String team_member_id;

	// Specific to Admin Profile
	public UnionType status;
	public UnionType membership_type;
	public List<String> groups;
	public String member_folder_id;
	public String external_id;
	public DateTime joined_on;
	public String persistent_id; 
	
	public class DPName {
		public String given_name;
		public String surname;
		public String familiar_name;
		public String display_name;
		public String abbreviated_name;
	}	    
	
	public class UnionType {
		public String tag;
	}
	
	public class RootInfo {
		public String tag;
		public String root_namespace_id;
		public String home_namespace_id;
		public String home_path;
	}
	
	public class FullTeam {
		public String id;
		public String name;
		public TeamSharingPolicies sharing_policies;
		public OfficeAddInPolicy office_addin_policy;
	}
	
	public class TeamSharingPolicies {
		public Map<String, String> shared_folder_member_policy;
		public Map<String, String> shared_folder_join_policy;
		public Map<String, String> shared_link_join_policy;
	}
	
	public class OfficeAddInPolicy {
		public Map<String, String> office_addin_policy;
	}
}