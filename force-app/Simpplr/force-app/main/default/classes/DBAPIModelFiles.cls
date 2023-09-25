public with sharing class DBAPIModelFiles {
    public class CreateFolderArg extends SCoreAbstractJsonSerializable {
    	public String path;
    	public Boolean autorename;
    }
    
    public class CreateFolderResult extends SCoreAbstractJsonSerializable {
    	public FolderMetadata metadata; 
    }
    
    public class OnlyPathArg extends SCoreAbstractJsonSerializable {
    	public String path;
    	
    	public OnlyPathArg(String path) {
    		this.path = path;
    	}
    }
    
    public class DeleteResult extends SCoreAbstractJsonSerializable {
    	public Metadata metadata;
    }
    
    public class GetTemporaryLinkResult extends SCoreAbstractJsonSerializable {
    	public Metadata metadata;
    	public String link;
    }
    
    public class SearchResult extends SCoreAbstractJsonSerializable {
    	public List<SearchResultItem> matches;
		public Boolean has_more;
		public String cursor;
    	public Integer start;
    	public Boolean more;
    	
    }
    
    public class SearchResultItem {
    	public Metadata metadata;
    	public MatchType match_type;
    }
    
    public class MatchType{
		public String tag;
	}
	
	public class SearchRequestParams extends SCoreAbstractJsonSerializable {
		public String path;
		public String query;
		public Integer start;
		public Integer max_results;
		public String mode;
		public String cursor;
		public Options options;
	}
    
	public class Options {
		public String path;
		public Integer max_results;
	}

    public class MoveArg extends SCoreAbstractJsonSerializable {
    	public String from_path;
    	public String to_path;
    	public Boolean allow_shared_folder;
    	public Boolean autorename;
    	public Boolean allow_ownership_transfer;
    	
    	public MoveArg() {
    		autorename = false;
    		allow_shared_folder = true;
    		allow_ownership_transfer = false;
    	}
    }
    
    public class MoveResult extends SCoreAbstractJsonSerializable {
    	public Metadata metadata;
    }
    
    public class ListFolderArg extends SCoreAbstractJsonSerializable {
    	public String path;
    	public Boolean recursive;
    	public Boolean include_media_info;
    	public Boolean include_deleted;
    	public Boolean include_has_explicit_shared_members;
    	public Boolean include_mounted_folders;
    	public Integer respLimit;
		
		public ListFolderArg() {
			recursive = false;
			include_media_info = false;
			include_deleted = false;
			include_has_explicit_shared_members = false;
			include_mounted_folders = false;
			respLimit = 0;	
		}
		
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();
    		
    		outputMap.put('path', this.path);
    		
    		if(this.recursive) { outputMap.put('recursive', true); }
    		if(this.include_media_info) { outputMap.put('include_media_info', true); }
    		if(this.include_deleted) { outputMap.put('include_deleted', true); }
    		if(this.include_has_explicit_shared_members) { outputMap.put('include_has_explicit_shared_members', true); }
    		if(this.include_mounted_folders) { outputMap.put('include_mounted_folders', true); }
    		if(respLimit > 0) { outputMap.put('limit', respLimit); }
    		
    		return JSON.serialize(outputMap, true);
    	}
    }

	public class ListResult extends SCoreAbstractJsonSerializable {
		public List<Metadata> entries { get; set; }
		public String cursor { get; set; }
		public boolean has_more { get; set; }
	}
	
	public class GetMetadataArg extends SCoreAbstractJsonSerializable {
    	public String path;
    	public Boolean include_media_info;
    	public Boolean include_deleted;
    	public Boolean include_has_explicit_shared_members;
    	//public Boolean include_property_groups; 
    	
    	public GetMetadataArg() {
    		include_deleted = false;
    		include_has_explicit_shared_members = false;
    		//include_property_groups = false;
    	}
	}
	
    public class Metadata extends SCoreAbstractJsonSerializable implements Comparable {
    	public String tag;
		public String name;
		public String id;
		public Datetime client_modified;
		public Datetime server_modified;
		public String rev;
		public Long size;
		public String path_lower;
		public String path_display;
		public MediaInfo media_info;
		public FolderSharingInfo sharing_info;
		public List<PropertyGroup> property_groups;    	
		public Boolean has_explicit_shared_members;
		public String content_hash;
		
		public Metadata metadata;

		public Metadata() {
			size = 0;
			sharing_info = new FolderSharingInfo();
		}
		
		public Integer compareTo(Object compareTo) {
			Metadata cmpObj = (Metadata) compareTo;
			
			if(cmpObj != null) {
				//Sort by type
				if(cmpObj.tag != tag) { 
					if(cmpObj.tag == 'folder') { return 1; }
					if(tag == 'folder') { return -1; }
				} else {
					return path_lower.compareTo(cmpObj.path_lower);
				}
				/* else if(cmpObj.tag != 'folder') {
					if(cmpObj.server_modified > server_modified) { return -1; }
					else { return 1; }
				}*/
			}

			return 0;
		}
    }
    
    public class FolderMetadata extends SCoreAbstractJsonSerializable {
		public String name;
		public String id;
		public String path_lower;
		public String path_display;
		public FolderSharingInfo sharing_info;
		public List<PropertyGroup> property_groups;    	
    }
    
    public class DeletedMetaData extends SCoreAbstractJsonSerializable {
		public String name;
		public String path_lower;
		public String path_display;
    }
    
    public class FolderSharingInfo {
    	public Boolean read_only;
    	public String parent_shared_folder_id;
    	public String shared_folder_id;
    	public Boolean traverse_only;
    	public Boolean no_access;
    	public String modified_by;
    	
    	public FolderSharingInfo() {
    		read_only = true;
    		no_access = false;
    	}
    }
    
    public class PropertyGroup {
    	public String template_id;
    	public List<PropertyField> fields; 
    }
    
    public class PropertyField {
    	public String name;
    	public String value;
    }
    
    public class MediaInfo {
    	
    }
    
	public class GetRevisionsArg extends SCoreAbstractJsonSerializable {
    	public String path;
    	public String mode;
    	public Integer retlimit; 
    	
    	public GetRevisionsArg(String path, Integer lim) {
    		if(path.startsWith('id')) {
    			this.mode = 'id';	
    		} else {
    			this.mode = 'path';
    		}

    		this.path = path;
    		this.retLimit = lim;
    	}
    	
    	public override String serialize() {
    		Map<String, Object> outputMap = new Map<String, Object>();
    		
    		outputMap.put('path', this.path);
    		outputMap.put('mode', this.mode);
    		
    		if(this.retlimit > 0) { outputMap.put('limit', this.retLimit); }
    		
    		return JSON.serialize(outputMap, true);
    	}
	}
	
	public class ListRevisionResult extends SCoreAbstractJsonSerializable {
		public List<Metadata> entries { get; set; }
		public Boolean is_deleted { get; set; }
		public Datetime server_deleted { get; set; }
	}

}