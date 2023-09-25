public with sharing class FileDetailWrapper {
	public List<PermissionWrapper> listOfPermissions;
	public List<ParentWrapper> listOfParents{get;set;}
	public String id{get;set;}
	public String fileId{get;set;}
	public String name{get;set;}
	public String context{get;set;}
	public String description{get;set;}
	public String htmlDescription{get;set;}
	public String versionNumber{get;set;}
	public String title{get;set;}
    public String url{get;set;}
    public String publicUrl{get;set;}
    public String shareViaFeedUrl{get;set;}
    public String shareViaLinkUrl{get;set;}
    public String fileUrl{get;set;}
    public String downloadUrl{get;set;}
    public String permissions{get;set;}
    public String pathOnClient{get;set;}
    public String publishStatus{get;set;}
    public String thumbnailImg{get;set;}
    public String fileType{get;set;}
	public String type{get;set;}
	public Integer videoStatus{get;set;}
    public String fileExtension{get;set;}
	public String contentDocumentId{get;set;}
	public String latestPublishedVersionId{get;set;}
	public String viewInGoogleDrive{get;set;}
	public String viewInExternalSystem{get;set;}
	public String contentVersionId{get;set;}
    public Boolean canDelete{get;set;}
    public Boolean canCreateNewVersion{get;set;}
    public Boolean canCreatePublicShareLink{get;set;}
    public Boolean canUnlink{get;set;}
    public Boolean canChangeName{get;set;}
    public Boolean canSetPermissions{get;set;}
    public Boolean canDownload{get;set;}
    public Boolean onlyPDFDownload{get;set;}
    public Boolean isDir{get;set;}
    public Boolean isImage{get;set;}
    public Boolean isDownloadableOniOS{get;set;}
	public Boolean isFavorited{get;set;}
	public Boolean isBookmarked{get;set;}
	public String fileSize{get;set;}
    public Long size{get;set;}
    public String lastModifiedDate{get;set;}
	public OwnerWrapper owner{get;set;}
	public DirectoryWrapper directory;
	public String provider{get;set;}
	public String pdfViewUrl{get;set;}
	public Boolean isLiked{get;set;}
	public Integer likedCount{get;set;}
	public FileContentWrapper imgFile{get;set;}
	public String iframeViewUrl{get;set;}  
	public String modifiedAt{get;set;}
	public String rootDirectory{get;set;}
	public List<SiteLiteWrapper> listOfSite{get;set;}
	public Boolean canEdit{get;set;}
	public Integer videoCaptionStatus;
	public Boolean isAccessDenied;
	public String imageFullSizeRenderUrl{get;set;}
	/**
	 * @description Check If Sp File is from different Instance
	*/
	public Boolean isDifferentSpInstance{get;set;}

	//NativeVideo keys
	public Boolean canMove;
	public Boolean isAccessible;
	public Integer language;
	public String uploadedAt;
	public SiteWrapper site;
	public String directoryName;
	
	public FileDetailWrapper(){
		listOfParents = new List<ParentWrapper>();
		owner = new OwnerWrapper();
		listOfSite = new List<SiteLiteWrapper>();
		isDownloadableOniOS = true;
		canDownload = true;
		onlyPDFDownload = false;
	}

	public class OwnerWrapper {
		public String id{get;set;}
		public String name{get;set;}
		public String url{get;set;}
	}
	
	public class ParentWrapper {
		public String id{get;set;}
		public String name{get;set;}
		public String url{get;set;}
		public String permissions{get;set;}
	}
	
	public Class DirectoryWrapper {
		public String id;
		public String name;
		public String path;
		public String permissions;
	}
	
	public class PermissionWrapper{
		public String id;
		public String role;
		public String emailAddress;
		
	}

	public Class SiteWrapper {
		public String id{get;set;}
		public String name{get;set;}
		public String url{get;set;}
		public Boolean isManager{get;set;}
		public Boolean isOwner{get;set;}
		public Boolean hasCampaigns{get;set;}
	}
}