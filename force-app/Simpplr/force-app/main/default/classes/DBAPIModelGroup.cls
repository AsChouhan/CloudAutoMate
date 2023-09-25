public with sharing class DBAPIModelGroup {	
	public class DynamicContent extends SCoreAbstractJsonSerializable {
		public String id_field { get; set; }
		public Object id_value { get; set; }
		public Boolean tag_flag { get; set; }
		
		public override String serialize() {
    		Map<String, Object> grp = new Map<String, Object>();
    		if(this.tag_flag) {
    			grp.put('.tag', this.id_field);
    		}
    		
			grp.put(this.id_field, this.id_value);
			
			return JSON.serialize(grp, true);
		}
	}
	
	public class FullInfo extends SCoreAbstractJsonSerializable {
	    public String group_name { get; set; }
	    public String group_id { get; set; }
	    public Map<String, String> group_management_type { get; set; }
	    public String created { get; set; }
	    public String group_external_id { get; set; }
	    public Integer member_count { get; set; }
	    public List<DBAPIModelMember.FullInfo> members { get; set; }	
	    public String error_summary { get; set; }
	    public Map<String, String> error { get; set; }
	    public String tag { get; set; }
	    public String id_not_found { get; set; }
	}
	
	public class ListResult extends SCoreAbstractJsonSerializable {
		public List<FullInfo> groups { get; set; }
		public String cursor { get; set; }
		public boolean has_more { get; set; }
	}
	
	public class CreateArgs extends SCoreAbstractJsonSerializable {
		public String group_name;
		public String group_external_id;
		public Map<String, String> group_management_type;
		
		public CreateArgs() {
			group_management_type = new Map<String, String>{'.tag' => 'company_managed'};
		}
	}
	
	public class GroupMetadataReqArg extends SCoreAbstractJsonSerializable {
		public List<String> group_external_ids;
		public String group_Info_Req_Type;
		
		public override String serialize() {
			Map<String, Object> outputMap = new Map<String, Object>();
			outputMap.put(this.group_Info_Req_Type,this.group_external_ids);
			outputMap.put('.tag',this.group_Info_Req_Type);
			return JSON.serialize(outputMap, true);
		}
	}
	
	public class DeleteArgs extends SCoreAbstractJsonSerializable {
		public String id_field;
		public String id_value;
		
		public override String serialize() {
			return JSON.serialize(Utility.getSelectorArg(this.id_field, this.id_value), true);
		}
	}
    
    public class UpdateArgs extends SCoreAbstractJsonSerializable {
    	public String id_field;
    	public String id_value;
    	public Boolean return_members;
    	public String new_group_name;
    	public String new_group_external_id;
    	public Map<String, String> new_group_management_type;
    	
    	public UpdateArgs() {
    		return_members = false;
    		new_group_management_type = null;
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();
    		
    		outputMap.put('group', Utility.getSelectorArg(this.id_field, this.id_value));
    		outputMap.put('return_members', this.return_members);
    		
    		if(!String.isBlank(this.new_group_name)) {
    			outputMap.put('new_group_name', this.new_group_name);	
    		}
    		
    		if(!String.isBlank(this.new_group_external_id)) {
    			outputMap.put('new_group_external_id', this.new_group_external_id);
    		}
    		
    		if(this.new_group_management_type != null) {
    			outputMap.put('new_group_management_type', this.new_group_management_type);	
    		}
			
    		return JSON.serialize(outputMap, true);
    	}
    }
}