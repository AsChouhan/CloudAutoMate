public with sharing class DBAPIModelMember {
	public class Profile {
		public String team_member_id { get; set; }
		public String email { get; set; }
		public Boolean email_verified { get; set; }
		public Map<String, String> status { get; set; }
		public Map<String, String> name { get; set; }
		public Map<String, String> membership_type { get; set; }
		public String external_id { get; set; }
		public String account_id { get; set; }
		public Datetime joined_on { get; set; }
		public String persistent_id { get; set; }
	}
	
	public class FullInfo {
		public Profile profile { get; set; }
		public Map<String, String> access_type { get; set; }
	}
	
	public class ListResult extends SCoreAbstractJsonSerializable {
		public List<FullInfo> members { get; set; }
		public String cursor { get; set; }
		public boolean has_more { get; set; }
	}
	
	public class Access {
		public Map<String, String> user;
		private Map<String, String> access_type;
		
		public Access() {
			access_type = new Map<String, String> {'.tag' => 'member'}; 
		}
	}
    
    public class AddArgs extends SCoreAbstractJsonSerializable {
    	public String id_field;
    	public String id_value;
    	
    	public List<Access> members;
    	public Boolean return_members;
    	
    	public AddArgs() {
    		return_members = false;
			members = new List<Access>();
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();
    		
    		outputMap.put('group', Utility.getSelectorArg(this.id_field, this.id_value));
    		outputMap.put('members', this.members);
			outputMap.put('return_members', this.return_members);
			
    		return JSON.serialize(outputMap, true);
    	}
    }
    
    public class RemoveArgs extends SCoreAbstractJsonSerializable {
    	public String id_field;
    	public String id_value;
    	
    	public List<Map<String, String>> users;
    	public Boolean return_members;
    	
    	public RemoveArgs() {
    		return_members = false;
			users = new List<Map<String, String>>();
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();
    		
    		outputMap.put('group', Utility.getSelectorArg(this.id_field, this.id_value));
    		outputMap.put('users', this.users);
			outputMap.put('return_members', this.return_members);
			
    		return JSON.serialize(outputMap, true);
    	}
    }
    
    public class ListArgs extends SCoreAbstractJsonSerializable {
		public String id_field;
		public String id_value;
		public integer returnLimit;
		
		public override String serialize() {
			Map<String, Object> outputMap = new Map<String, Object>();
    		outputMap.put('group', Utility.getSelectorArg(this.id_field, this.id_value));
    		outputMap.put('limit', returnLimit);
    		
			return JSON.serialize(outputMap, true);
		}
    }
    
    public class ChangeResult extends SCoreAbstractJsonSerializable {
    	public DBAPIModelGroup.FullInfo group_info { get; set; }
    	public String async_job_id { get; set; }
    }
}