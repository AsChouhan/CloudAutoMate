public with sharing class MSAPIClient extends SCoreClient.AbstractClient {
    /**
	 * Constructor.
	 *
     * @param credentials HTTP request credentials required for authentication.
     * @return The Drop Box API HTTP client giving access to all API calls.
     */
	public MSAPIClient(SCoreClient.Credentials credentials, String storageType) { 
		this.setCredentials(credentials);
		this.setAdditionalHeaders(new Map<String, String> { 'Accept' => 'application/json' });
		this.setClientType(storageType);
	}
	
	// User Endpoints
	public MSAPIUser users() {
		return new MSAPIUser(this);
	}
	
	// Site Endpoints
	public MSAPISite sites() {
		return new MSAPISite(this);
	}
	
	// Drive Endpoints
	public MSAPIDrive drives() {
		return new MSAPIDrive(this);
	}
	
	//permissions endpoint
	public MSAPIPermission permissions() {
		return new MSAPIPermission(this);
	}
	
	
	//permissions endpoint
	public MSAPIDriveItem driveItems() {
		return new MSAPIDriveItem(this);
	}
	
	
}