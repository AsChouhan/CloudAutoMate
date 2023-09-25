public with sharing class MSAPIPermission {
	String endpoint = 'https://graph.microsoft.com/v1.0/me/drive/items';
    String driveItemId = '';
    String permissionSurfix = '/permissions';
    MSAPIClient client;
    
    public MSAPIPermission (MSAPIClient clientObj){ 
    	this.client = clientObj;
    }
    public MSAPIClient getClient() { return this.client; }
    public MSAPIPermission setClient(MSAPIClient msc) {
    	this.client = msc;
    	return this;
    }
    
    public class getDrivePermissions extends SCoreClient.AbstractClientRequest {
    	public getDrivePermissions(MSAPIPermission permissionObj, Id driveItemId) {
    		super(permissionObj.getClient(), 
    		'https://graph.microsoft.com/v1.0/me/drive/items/' + driveItemId 
    		+ '/permissions' , 
    		 'GET', 
    		  null, 
    		  new SCoreJsonDeserializer(MSAPIModelPermission.class, null));
    	}
    }
}