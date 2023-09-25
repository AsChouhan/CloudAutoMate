/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BoxWrapper {
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class FolderFile {
        public String type {get;set;}
        public String id {get;set;}
        public String sequence_id {get;set;}
        public Integer etag {get;set;}
        public String name {get;set;}
        public String description {get;set;}
        public Long size {get;set;}
        public PathCollection path_collection {get;set;}
        public DateTime created_at {get;set;}
        public DateTime modified_at {get;set;}
        public MiniBoxUser created_by {get;set;}
        public MiniBoxUser modified_by {get;set;}
        public MiniBoxUser owned_by {get;set;}
        public MiniFolderFile parent {get;set;}
        public String item_status {get;set;}
        public BoxItemCollection item_collection {get;set;} 
        public String ownerName{get;set;} 
        public String lastModifyDate{get;set;}
        public String smallPhotoUrl{get;set;}
        public String LatestPublishedVersionId{get;set;}
        public List<String> tags{get;set;}
        public String version_number {get;set;}
        public BoxEmbedLink expiring_embed_link{get;set;}
        public BoxPermissions permissions {get;set;}
        /**
         * @description flag indicates logged in user access to folder
         */
        public Boolean isAccessDenied {get;set;}
    }
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class MiniFolderFile implements Comparable{
        public String type {get;set;}
        public String id {get;set;}
        public String sequence_id {get;set;}
        public String etag {get;set;}
        public String sha1 {get;set;}
        public String name {get;set;}
        public Long size{get;set;}
        public Datetime modified_at {get;set;}
		public MiniBoxUser owned_by {get;set;}
		public MiniBoxUser owner {get;set;}
		public MiniBoxUser created_by {get;set;}
		public MiniBoxUser modified_by {get;set;}
		public PathCollection path_collection {get;set;}
		public String mime_type{get;set;}
		public DateTime created_at{get;set;}
		public MiniFolderFile parent {get;set;}
		public String folderPath {get;set;}
		public BoxPermissions permissions {get;set;}
        
        public Integer compareTo(Object compareToObj) {
	    	MiniFolderFile mfObj = (MiniFolderFile)compareToObj;
	        return name.toLowerCase().compareTo(mfObj.name.toLowerCase());     
		}
    }
    public class BoxEmbedLink {
    	public String url{get;set;}
    }
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class PathCollection {
        public Integer total_count {get;set;}
        public MiniFolderFile[] entries {get;set;}
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class MiniBoxUser {
        public String type {get;set;}
        public String id {get;set;}
        public String name {get;set;}
        public String login {get;set;}
        public String role{get;set;} // admin, coadmin, or user.
        public BoxEnterprise enterprise{get;set;}
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxEnterprise {
    	public String type {get;set;}
        public String id {get;set;}
        public String name {get;set;}
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class UserTokens {
    	public Boolean preferenceObjUpdated{get;set;}
    	public String boxUserId{get;set;}
		public String userId{get;set;} //SalesforceUserId
		public String peopleId{get;set;}
		public String userEmail{get;set;}
		public String favoriteCollectionId{get;set;}
		public String accessToken{get;set;}
		public String refreshToken{get;set;}
		public DateTime accessTokenExpiresIn{get;set;}
		public DateTime refreshTokenExpiresIn{get;set;}
		public String enterpriseId{get;set;}
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxItemCollection {
        public Integer total_count {get;set;}
        public List<MiniFolderFile> entries {get;set;}
        public Integer offset {get;set;}
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxPermissions {
        public Boolean can_download {get;set;}
        public Boolean can_delete {get;set;}
        public Boolean can_rename {get;set;}
        public Boolean can_preview {get;set;} 
        public Boolean can_upload {get;set;}
        public Boolean can_invite_collaborator{get;set;}
        public Boolean can_set_share_access{get;set;}
    }

	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxCollaboration {
        public String type {get;set;}
        public String id {get;set;}
        public MiniBoxUser created_by {get;set;}
        public DateTime created_at {get;set;}
        public DateTime modified_at {get;set;}
        public DateTime expires_at {get;set;}
        public String status {get;set;}
        public MiniBoxUser accessible_by {get;set;}
        public String role {get;set;}
        public DateTime acknowledged_at {get;set;}
        public MiniFolderFile item {get;set;}
    }

	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxCollaborationCollection {
        public Integer total_count {get;set;}
        public List<BoxCollaboration> entries {get;set;}
    }

	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxDocument{
    	public String type;
		public String id;
		public String status;
		public String name;
		public String created_at;
		public String modified_at;
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxUserMemberships{
    	public Integer total_count;
		public List<GroupEntries> entries;
		public Integer offset;
    }
    
    public class BoxCollectionWrapper {
    	public Integer total_count{get;set;}
    	public List<BoxCollection> entries{get;set;}
    }
    
    public class BoxCollection {
    	public String type {get;set;}
        public String id {get;set;}
        public String name {get;set;}
    	public String collection_type {get;set;}
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class GroupEntries {
    	public String type;
		public String id;
		public MiniBoxUser user;
		public BoxGroup group_x;
    }
    
    /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
    public class BoxGroup {
		public String type;
		public String id;
		public String name;
		public String created_at;
		public String modified_at;
	}
  
    /**
	* @Class [Class Name] 
	* @Purpose:  Class to wrap json into object for create a folder response
	*
	*/
   public class createFolderWrapper{
		public String type;	
		public Integer total_count{get;set;}
		public MiniFolderFile[] entries{get;set;}
		public Integer offset{get;set;}	//0
		public String id{get;set;}	
		public String sequence_id;
		public String etag;	
		public String name{get;set;}
		public String created_at;
		public DateTime modified_at;	
		public String description;	
		public Long size;	
		public String item_status;	
		public MiniBoxUser created_by;
		public MiniBoxUser owned_by;
		public PathCollection path_collection {get;set;}
	}

	/**
	* @Class [Class Name] 
	* @Purpose:  A Class to wrap error info from box.com api
	*
	*/
	public class BoxErrorWrapper {
	
		/**
		* 
		* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
		* Parameters:
		*      parameter_name -- [Explanation of the purpose of this parameter to the method.
		*      
		* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
		*/
		public void consumeObject(JSONParser parser) {
			Integer depth = 0;
			do {
				JSONToken curr = parser.getCurrentToken();
				if (curr == JSONToken.START_OBJECT || 
					curr == JSONToken.START_ARRAY) {
					depth++;
				} else if (curr == JSONToken.END_OBJECT ||
					curr == JSONToken.END_ARRAY) {
					depth--;
				}
			} while (depth > 0 && parser.nextToken() != null);
		}
		public String type {get;set;}
		public Integer status {get;set;}
		public String code {get;set;}
		public String context_info_message {get;set;}
		public cls_context_info context_info;
		public String help_url {get;set;}
		public String message {get;set;}
		public String request_id {get;set;}
	
		/**
		* 
		* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
		* Parameters:
		*      parameter_name -- [Explanation of the purpose of this parameter to the method.
		*      
		* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
		*/
		
		// TODO : need to refactor this code, we shoudl improve the way we are parsing. May occure "Apex CPU time limit exceeded" - Ajay 
		public BoxErrorWrapper(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type = parser.getText();
						} else if (text == 'status') {
							status = parser.getIntegerValue();
						} else if (text == 'code') {
							code = parser.getText();
						} else if (text == 'context_info') {
							try{
								context_info = (cls_context_info)parser.readValueAs(cls_context_info.class);
							}catch(System.JSONException ex){
								context_info_message = parser.getText();
							}
						} else if (text == 'help_url') {
							help_url = parser.getText();
						} else if (text == 'message') {
							message = parser.getText();
						} else if (text == 'request_id') {
							request_id = parser.getText();
						} else {
							//logger.logDebug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
		
		
		
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class cls_context_info {
		public cls_errors[] errors;
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class cls_errors {
		public String reason;	
		public String name;	
		public String message;	
	}
	
	/**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class BoxAddMemberWrapper{
		public String type;	//group_membership
		public String id;	//8996194
		//public cls_user user;
		//public cls_group group;
		public String role;	//member
		public String created_at;	//2015-06-16T01:59:12-07:00
		public String modified_at;	//2015-06-16T01:59:12-07:00
		
	}

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static BoxCollaborationCollection parseBoxCollaborationCollections(String json) {
		return (BoxCollaborationCollection) System.JSON.deserialize(json, BoxCollaborationCollection.class);
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static BoxCollaboration parseBoxCollaboration(String json){
		return (BoxCollaboration) System.JSON.deserialize(json, BoxCollaboration.class);
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static BoxErrorWrapper parseErrorInfo(String json) {
		return new BoxErrorWrapper(System.JSON.createParser(json));
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static BoxItemCollection parseBoxItems(String json){
		return (BoxItemCollection) System.JSON.deserialize(json, BoxItemCollection.class);
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static FolderFile parseFolderFile(String json){
		return (FolderFile) System.JSON.deserialize(json, FolderFile.class);
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static BoxUserMemberships parseBoxUserMemberships(String json){
		return (BoxUserMemberships) System.JSON.deserialize(json.replaceAll('"group":', '"group_x":'), BoxUserMemberships.class);
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static MiniBoxUser parseBoxUser(String json){
		return (MiniBoxUser) System.JSON.deserialize(json, MiniBoxUser.class);
	}
	
	public static BoxCollectionWrapper parseBoxCollections(String json) {
		return (BoxCollectionWrapper) System.JSON.deserialize(json, BoxCollectionWrapper.class);
	}
	
	public static MiniFolderFile parseMiniFolderFile(String json){
		return (MiniFolderFile) System.JSON.deserialize(json, MiniFolderFile.class);
	}
	
}