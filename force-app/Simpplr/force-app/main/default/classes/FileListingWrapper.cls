public with sharing class FileListingWrapper  implements Comparable{
    public String spInstanceId;
    public String id {get;set;}
    public String fileId {get;set;}
    public String externalFileId {get;set;}
    public String name {get;set;}
    public String title {get;set;}
    public String url {get;set;}
    public String publicUrl {get;set;}
    public String fileUrl {get;set;}
    public String downloadUrl {get;set;}
    public String rootDirectory{get;set;}
    public Boolean canRemove {get;set;}
    public Boolean canDelete {get;set;}
    public Boolean canCreateNewVersion {get;set;}
    public Boolean canCreatePublicShareLink{get;set;}
    public Boolean canUnlink {get;set;}
    public Boolean canChangeName {get;set;}
    public Boolean canDownload {get;set;}
    public Boolean onlyPDFDownload {get;set;}
    public Boolean canSetPermissions {get;set;}
    public Boolean isDir {get;set;}
    public Boolean isImage {get;set;}
    public Boolean isBookmarked {get;set;}
    public Boolean isFavorited {get;set;}
    public Boolean isLiked {get;set;}
    public String permissions {get;set;}
    public String publishStatus {get;set;}
    public String thumbnailImg;
    public String type {get;set;}
    public String driveType{get;set;}
    public String boxUrl{get;set;} 
    public String gdriveUrl{get;set;}
    public String dropboxUrl{get;set;}
    public String externalUrl{get;set;}
    public String fileExtension {get;set;}
    public Long size {get;set;}
    public String modifiedAt {get;set;}
    public DateTime modifiedAtDateTime {get;set;}
    public String createdAt {get;set;}
    public DateTime createdAtDateTime {get;set;}
    public OwnerWrapper owner {get;set;}
    public List<SiteLiteWrapper> listOfSite {get;set;}
    public String location {get;set;}
    public String pathOnClient{get;set;}
    public String contentDocumentId {get;set;}
    public List<ParentWrapper> listOfParents {get;set;} 
    public String img {get;set;}
    public String videoProvider  {get;set;}
    public Integer videoStatus;
    public String provider  {get;set;}
    public Boolean isVideo {get;set;}
    public String videoId {get;set;}
    public String description {get;set;}
    public String context {get;set;}
    public Integer isFolder {get;set;} // 0 for files and 1 for folders
    public Boolean isCover {get;set;}
    public String contentVersionId {get;set;}
    public Integer relevancyScore {get;set;}
    public Boolean isDownloadableOniOS {get;set;}
    public String sortBy {get;set;}
    public Boolean isSystemDir{get;set;}
    public Boolean canMove{get;set;}
    public Integer photoCount{get;set;}
    public Integer videoCount{get;set;}
    public Integer likeCount{get;set;}
    public Integer index;
    public PeopleLiteWrapper authoredBy;
    public String imgTHUMB720BY480URL;
	public String imgTHUMB240BY180URL;
	public String imgFullURL;
	public Boolean matchedOnTopic;
	public Boolean matchedOnExpertise;
	public String itemType;
	public String file_data;
	public String sharedFolderId {get;set;}
    public Boolean isMyDriveEnabled;
    public Boolean canEdit;
    public Integer runTime;
    public Boolean isInHomeFeed;
    public VideoCaptionWrapper captions{get;set;}
    public List<NativeVideoWrapper.ReferenceItemWrapper> references;
    public Boolean isAccessible;

    public Integer compareTo(Object compareTo) {
        FileListingWrapper fileListWrapperObj = (FileListingWrapper) compareTo;
        if(fileListWrapperObj!=null){
        	
            //Sort by folders first
        	if(isFolder!=null && fileListWrapperObj.isFolder!=null){
	            if (isFolder < fileListWrapperObj.isFolder) return 1;
	            if (isFolder > fileListWrapperObj.isFolder) return -1;
        	}
        	
            //Sort by relevancyScore second
            if(relevancyScore!=null && fileListWrapperObj.relevancyScore!=null){
	            if (relevancyScore < fileListWrapperObj.relevancyScore) return 1;
	            if (relevancyScore > fileListWrapperObj.relevancyScore) return -1;
            }
            //Sort by modifiedAt third
            if(sortby != null && fileListWrapperObj.sortBy != null) {
	            if(createdAtDateTime!=null && fileListWrapperObj.createdAtDateTime!=null){
		            if('createdNewest'.equalsIgnoreCase(fileListWrapperObj.sortBy)){
		            	if (createdAtDateTime < fileListWrapperObj.createdAtDateTime) return 1;
		            	if (createdAtDateTime > fileListWrapperObj.createdAtDateTime) return -1;
		            }else if('createdOldest'.equalsIgnoreCase(fileListWrapperObj.sortBy)){
		            	if (createdAtDateTime < fileListWrapperObj.createdAtDateTime) return -1;
		            	if (createdAtDateTime > fileListWrapperObj.createdAtDateTime) return 1;
	            	}
	            
		        }
		        if(modifiedAtDateTime!=null && fileListWrapperObj.modifiedAtDateTime!=null){
		        	if('modifiedNewest'.equalsIgnoreCase(fileListWrapperObj.sortBy)){
		            	if (modifiedAtDateTime < fileListWrapperObj.modifiedAtDateTime) return 1;
		            	if (modifiedAtDateTime > fileListWrapperObj.modifiedAtDateTime) return -1;
		            }else if('modifiedOldest'.equalsIgnoreCase(fileListWrapperObj.sortBy)){
		            	if (modifiedAtDateTime < fileListWrapperObj.modifiedAtDateTime) return -1;
		            	if (modifiedAtDateTime > fileListWrapperObj.modifiedAtDateTime) return 1;
	            	}
		        }
            }
        }
        return 0;      
    }

    public String originalImageUrl {get;set;}

    
    public FileListingWrapper(){
        owner = new OwnerWrapper();
        listOfSite = new List<SiteLiteWrapper>();
        isDownloadableOniOS = true;
        onlyPDFDownload = false;
    }
        
    public class OwnerWrapper {
        public String id {get;set;}
        public String name {get;set;}
        public String url {get;set;}
    }
    
    public Class ParentWrapper {
        public String id {get;set;}
        public String name{get;set;}
        public String rootDirectory{get;set;}
        public Boolean canCreateBoxFolder{get;set;}
        public Boolean canLinkBoxFolder{get;set;}
        public Boolean canCreateFolder{get;set;}
        public Boolean canLinkFolder{get;set;}
        public Boolean isSystemFolder{get;set;}
        public String permissions{get;set;}
        public String provider;
    }
    
    public Class DirectoryWrapper {
        public String id {get;set;}
        public String rootDirectory {get;set;}
        public String provider {get;set;}
        public String name{get;set;}
        public String path{get;set;}
        public String permissions{get;set;}
        public Boolean isSystemDir{get;set;}
        public Boolean canCreateBoxFolder{get;set;}
        public Boolean canLinkBoxFolder{get;set;}
        public Boolean canCreateFolder{get;set;}
        public Boolean canLinkFolder{get;set;}
        public Boolean canLinkSharepointFolder{get;set;}
        public Boolean canCreateSharepointFolder{get;set;}
        public Boolean canLinkOnedriveFolder{get;set;}
        public Boolean canCreateOnedriveFolder{get;set;}
        /**
         * @description flag indicates logged in user access to folder
         */
        public Boolean isAccessDenied{get;set;}
        /**
         * @description Check for SharePoint Instance different
        */
        public Boolean isDifferentSpInstance{get;set;}
        /**
         * @description SharePoint Instance Id
        */
        public String spInstanceId{get;set;} 
        public String externalUrl{get;set;} 
    }
    
    public class PaginationWrapper {
        public String nextPageToken;
        public String nextPageUrl;
        public Integer totalRecords;
        public String totalRecordsStr;
        public Boolean includeFolders;
        public Boolean canUpload;
        public String shareddriveName;
        public Boolean isMyDriveFolderLinked;
        public DirectoryWrapper directory;
        public List<FileListingWrapper> listOfItems = new List<FileListingWrapper>();
        public List<ParentWrapper> listOfParents = new List<ParentWrapper>();
        public Boolean canCreateFolder;
    }
    
    public class BoxFolderContentsWrapper {
        public Boolean isAccessDenied;
        public Boolean canUpload;
        public String folderName;
        public List<ParentWrapper> listOfParents = new List<ParentWrapper>();
        public List<FileListingWrapper> listOfFile = new List<FileListingWrapper>();
    }

    public class VideoCaptionWrapper {
        public Integer totalRecords{get;set;}
        public List<VideoCaptionItem> listOfItems{get;set;}
    }
    
    public class VideoCaptionItem {
        public String id{get;set;}
        public Integer timeStamp {get;set;}
        public String text{get;set;}
    }
}