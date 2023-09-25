public with sharing class FileVersionHistoryWrapper {
	public String versionId {get;set;}
	public String versionNumber {get;set;}
	public String downloadUrl {get;set;}
    public OwnerWrapper user {get;set;}
    public String createdAt {get;set;}
    public Boolean canDownload { get; set; }

    public FileVersionHistoryWrapper(){
		user = new OwnerWrapper();
		canDownload = true;
	}
	
	public class OwnerWrapper {
		public String id {get;set;}
		public String name {get;set;}
		public String url {get;set;}
	}
}