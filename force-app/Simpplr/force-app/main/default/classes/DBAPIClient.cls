/*
* Drop Box Client object
*/
public with sharing class DBAPIClient extends SCoreClient.AbstractClient {
	/**
	 * Constructor.
	 *
     * @param credentials HTTP request credentials required for authentication.
     * @return The Drop Box API HTTP client giving access to all API calls.
     */
	public DBAPIClient(SCoreClient.Credentials credentials) { 
		this.setCredentials(credentials);
		this.setClientType('dropbox');
	}
	
	// User Endpoints
	
	
	// Business Endpoints
	public DBAPIGroup groups() {
		return new DBAPIGroup(this);
	}
	
	public DBAPIMember members() {
		return new DBAPIMember(this);
	}
	
	public DBAPIFiles files() {
		return new DBAPIFiles(this);
	}

	public DBAPIUsers users() {
		return new DBAPIUsers(this);
	}
	
	public DBAPISharing sharing() {
		return new DBAPISharing(this);
	}	
}