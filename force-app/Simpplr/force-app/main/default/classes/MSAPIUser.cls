public with sharing class MSAPIUser {
	
	String mainEndpoint = 'https://graph.microsoft.com/v1.0/users/';
	
	MSAPIClient client;
	
	public MSAPIUser(MSAPIClient msc) {
		this.client = msc;
	}
	
	// Getter and Setter  Methods
	public MSAPIClient getClient() { return this.client; }
	public MSAPIUser setClient(MSAPIClient msc) {
		this.client = msc;
		return this;
	}
	
	// Get Current User Detail
	public class CurrentUserDetail extends SCoreClient.AbstractClientRequest {
  		public CurrentUserDetail(MSAPIUser usr) {
			super(usr.getClient(), 
				  'https://graph.microsoft.com/v1.0/me', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelUser.class, null));
		}
	}
	
	// Get Current User Drive Detail
	public class CurrentUserDriveDetail extends SCoreClient.AbstractClientRequest {
  		public CurrentUserDriveDetail(MSAPIUser usr) {
			super(usr.getClient(), 
				  'https://graph.microsoft.com/v1.0/me/drive', 
				  'GET', 
				  null, 
				  new SCoreJsonDeserializer(MSAPIModelDrive.class, null));
		}
	}
	
	// Get Groups the user belongs to
	public class GroupsMemberOf extends SCoreClient.AbstractClientRequest {
		public GroupsMemberOf(MSAPIUser usr) {
			super(usr.getClient(),
				  'https://graph.microsoft.com/v1.0/me/memberOf',
				  'GET',
				  null,
				  new SCoreJsonDeserializer(MSAPIModelUser.GroupList.class, null));
		}
	}
	
    /**
    * @description Class to create graph api organization detail callout
    */
	public class OrganizationDetail extends SCoreClient.AbstractClientRequest {
        /**
        * @description constructor to create graph api organization detail callout
        * @param usr takes an argument of type MSAPIUser having client details
        */
		public OrganizationDetail(MSAPIUser usr) {
            /**
            * @description calling super constructor (AbstractClientRequest) to provide client details
            */
			super(usr.getClient(),
				  'https://graph.microsoft.com/v1.0/organization',
				  'GET',
				  null,
				  new SCoreJsonDeserializer(MSAPIModelUser.OrganizationList.class, null));
		}
	}

    /**
    * @description Class to create graph api folder permission callout
    */
	public class FolderAccess extends SCoreClient.AbstractClientRequest {
        /**
        * @description constructor to create graph api folder permission callout
        * @param usr takes an argument of type MSAPIUser having client details
        * @param folderId takes an argument of type String having external folder id
        */
		public FolderAccess(MSAPIUser usr, String folderId) {
            /**
            * @description calling super constructor (AbstractClientRequest) to provide client details
            */
			super(usr.getClient(),
				  'https://graph.microsoft.com/v1.0/drives/'+ folderId,
				  'GET',
				  null,
				  new SCoreJsonDeserializer(MSAPIModelUser.FolderPermissionResponse.class, null));
		}
	}
}