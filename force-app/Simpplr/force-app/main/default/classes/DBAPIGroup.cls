public with sharing class DBAPIGroup {
	String mainEndpoint = 'https://api.dropboxapi.com/2/team/groups/';
	
	DBAPIClient client;
	
	public DBAPIGroup(DBAPIClient dbc) {
		this.client = dbc;
	}
	
	// Getter and Setter Methods
	public DBAPIClient getClient() { return this.client; }
	public DBAPIGroup setClient(DBAPIClient gdc) {
		this.client = gdc;
		return this;
	}
	
	// Create Request - Method
	public CreateRequest getCreateRequest(String grp_name, String grp_eid) {
  		DBAPIModelGroup.CreateArgs content = new DBAPIModelGroup.CreateArgs();
  		content.group_name = grp_name;
  		content.group_external_id = grp_eid;
  		
		return new CreateRequest(this, content);
	}
	
  	public class CreateRequest extends SCoreClient.AbstractClientRequest {
  		public CreateRequest(DBAPIGroup grp, DBAPIModelGroup.CreateArgs args) {
			super(grp.getClient(), grp.mainEndpoint + 'create', 'POST', args, new SCoreJsonDeserializer(DBAPIModelGroup.FullInfo.class));
		}
	}

	// Delete Request - Method
	public DeleteRequest getDeleteRequest(String fld, String val) {
  		DBAPIModelGroup.DeleteArgs content = new DBAPIModelGroup.DeleteArgs();
  		content.id_field = fld;
  		content.id_value = val;
  		
		return new DeleteRequest(this, content);
	}
	
  	public class DeleteRequest extends SCoreClient.AbstractClientRequest {
  		public DeleteRequest(DBAPIGroup grp, DBAPIModelGroup.DeleteArgs args) {
			super(grp.getClient(), grp.mainEndpoint + 'delete', 'POST', args, new SCoreJsonDeserializer(Map<String, String>.class));
		}
	}
	
	// List Request - Method
	public ListRequest getListRequest(Integer listLimit) {
  		DBAPIModelGroup.DynamicContent content = new DBAPIModelGroup.DynamicContent();
  		content.tag_flag = false;
  		content.id_field = 'limit';
  		content.id_value = listLimit;
  		
		return new ListRequest(this, 'list', content);
	}

	// List (continue) Request - Method
	public ListRequest getListRequest(String cursor) {
  		DBAPIModelGroup.DynamicContent content = new DBAPIModelGroup.DynamicContent();
  		content.tag_flag = false;
  		content.id_field = 'cursor';
  		content.id_value = cursor;
  		
		return new ListRequest(this, 'list/continue', content);
	}
	
  	public class ListRequest extends SCoreClient.AbstractClientRequest {
  		public ListRequest(DBAPIGroup grp, String url, DBAPIModelGroup.DynamicContent content) {
			super(grp.getClient(), grp.mainEndpoint + url, 'POST', content, new SCoreJsonDeserializer(DBAPIModelGroup.ListResult.class));
		}
	}

	// Update Request - Method
	public UpdateRequest getUpdateRequest(DBAPIModelGroup.UpdateArgs content) {  		
		return new UpdateRequest(this, content);
	}
	
  	public class UpdateRequest extends SCoreClient.AbstractClientRequest {
  		public UpdateRequest(DBAPIGroup grp, DBAPIModelGroup.UpdateArgs args) {
			super(grp.getClient(), grp.mainEndpoint + 'update', 'POST', args, new SCoreJsonDeserializer(DBAPIModelGroup.FullInfo.class));
		}
	}
	
	public GroupInfoRequest getGroupInfoRequest(DBAPIModelGroup.GroupMetadataReqArg args) {  		
		return new GroupInfoRequest(this, args);
	}
	
	public class GroupInfoRequest extends SCoreClient.AbstractClientRequest {
		public GroupInfoRequest(DBAPIGroup grp, DBAPIModelGroup.GroupMetadataReqArg args){
			super(grp.getClient(), grp.mainEndpoint + 'get_info', 'POST', args, new SCoreJsonDeserializer(List<DBAPIModelGroup.FullInfo>.class,EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
}