public with sharing class DBAPIMember {
	String mainEndpoint = 'https://api.dropboxapi.com/2/team/groups/members/';
	
	DBAPIClient client;
	
	public DBAPIMember(DBAPIClient dbc) {
		this.client = dbc;
	}
	
	// Getter and Setter Methods
	public DBAPIClient getClient() { return this.client; }
	public DBAPIMember setClient(DBAPIClient gdc) {
		this.client = gdc;
		return this;
	}
	
	// Add Request - Method
	public AddRequest getAddRequest(String grpFld, String grpVal, String usrFld, List<String> usrList, Boolean retFlag) {
  		DBAPIModelMember.AddArgs content = new DBAPIModelMember.AddArgs();
  		content.id_field = grpFld;
  		content.id_value = grpVal;
		content.return_members = retFlag;
		
  		for(String usrVal: usrList) {
  			DBAPIModelMember.Access usrAccess = new DBAPIModelMember.Access();
  			usrAccess.user = Utility.getSelectorArg(usrFld, usrVal);
  			
  			content.members.add(usrAccess);
  		}
  		
		return new AddRequest(this, content);
	}
	
  	public class AddRequest extends SCoreClient.AbstractClientRequest {
  		public AddRequest(DBAPIMember mem, DBAPIModelMember.AddArgs args) {
			super(mem.getClient(), mem.mainEndpoint + 'add', 'POST', args, new SCoreJsonDeserializer(DBAPIModelMember.ChangeResult.class));
		}
	}

	// Remove Request - Method
	public RemoveRequest getRemoveRequest(String grpFld, String grpVal, String usrFld, List<String> usrList, Boolean retFlag) {
  		DBAPIModelMember.RemoveArgs content = new DBAPIModelMember.RemoveArgs();
  		content.id_field = grpFld;
  		content.id_value = grpVal;
		content.return_members = retFlag;
		
  		for(String usrVal: usrList) {
  			content.users.add(Utility.getSelectorArg(usrFld, usrVal));
  		}
  		
		return new RemoveRequest(this, content);
	}
	
  	public class RemoveRequest extends SCoreClient.AbstractClientRequest {
  		public RemoveRequest(DBAPIMember mem, DBAPIModelMember.RemoveArgs args) {
			super(mem.getClient(), mem.mainEndpoint + 'remove', 'POST', args, new SCoreJsonDeserializer(DBAPIModelMember.ChangeResult.class));
		}
	}
	
	// List Request - Method
	public ListRequest getListRequest(String grp_fld, String grp_val, Integer listLimit) {
  		DBAPIModelMember.ListArgs content = new DBAPIModelMember.ListArgs();
  		content.id_field = grp_fld;
  		content.id_value = grp_val;
  		content.returnLimit = listlimit;
  		
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
  		public ListRequest(DBAPIMember mem, String url, SCoreIHttpContent content) {
			super(mem.getClient(), mem.mainEndpoint + url, 'POST', content, new SCoreJsonDeserializer(DBAPIModelMember.ListResult.class));
		}
	}

	// Get User Account
	public class UserAccount extends SCoreClient.AbstractClientRequest {
  		public UserAccount(DBAPIMember mem) {
			super(mem.getClient(), 
				  'https://api.dropboxapi.com/2/users/get_current_account', 
				  'POST', 
				  null, 
				  new SCoreJsonDeserializer(DBAPIModelUser.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	// Get Admin Account
	public class AdminAccount extends SCoreClient.AbstractClientRequest {
  		public AdminAccount(DBAPIMember mem) {
			super(mem.getClient(), 
				  'https://api.dropboxapi.com/2/team/token/get_authenticated_admin', 
				  'POST', 
				  null, 
				  new SCoreJsonDeserializer(Map<String, DBAPIModelUser>.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
	
	// Since we are using only member access_type we will not require set_access_type api method
}