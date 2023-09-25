public with sharing class DBAPIUsers {
    public String mainEndpoint = 'https://api.dropboxapi.com/2/users/';
	
	DBAPIClient client;
	
	public DBAPIUsers(DBAPIClient dbc) {
		this.client = dbc;
	}
	
	// Getter and Setter Methods
	public DBAPIClient getClient() { return this.client; }
	public DBAPIUsers setClient(DBAPIClient dbc) {
		this.client = dbc;
		return this;
	}
    
    // Get Account Request - Method
	public ListRequest getAccountRequest(String accId) {
		return new ListRequest(this, 'get_account', new DBAPIModelUsers.GetAccountArg(accId));
	}

    public class ListRequest extends SCoreClient.AbstractClientRequest {
  		public ListRequest(DBAPIUsers fil, String url, DBAPIModelUsers.GetAccountArg content) {
			super(fil.getClient(), 
				  fil.mainEndpoint + url,
				  'POST', 
				  content, 
				  new SCoreJsonDeserializer(DBAPIModelUsers.BasicAccount.class, EFSConstants.DPtoApexKeywordsMap));
		}
	}
}