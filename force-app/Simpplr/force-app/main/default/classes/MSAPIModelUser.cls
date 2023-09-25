public with sharing class MSAPIModelUser extends MSAPIModelAbstract{
 	public List<String> businessPhones;
 	public String id;
 	public String displayName;
 	public String givenName;
 	public String jobTitle;
 	public String mail;
 	public String mobilePhone;
 	public String officeLocation;
 	public String preferredLanguage;
 	public String surname;
 	public String userPrincipalName;

	public class IdentitySet {
		public Identity application;
		public Identity device;
		public Identity user;
	}
	
	public class Identity {
		public String displayName;
		public String id;
		public String email;
	}
	
	public class GraphGroup {
		public String id;
		public String mail;
		public String displayName;
	}
	
	public class GroupList {
		public List<GraphGroup> value;
	}
	
    /**
    * @description Wrapper class to handle graph api organization detail response
    */
    public class Organization {
		public String id;
		public String displayName;
		public String tenantType;
	}

    /**
    * @description Wrapper class to handle graph api organization detail reponse array
    */
    public class OrganizationList {
        /**
        * @description Graph API returns an array of organization details
        */
		public List<Organization> value;
	}

    /**
     * @description Wrapper class to handle graph api folder access reponse
     */
    public class FolderPermissionResponse {
        /** @description error details **/
        public String error;
        /** @description success details **/
        public FolderAccessObject value; 
    }

    /** @description folder access response on success **/
    public class FolderAccessObject {
        /** @description success response id **/
        public String id;
    }
}