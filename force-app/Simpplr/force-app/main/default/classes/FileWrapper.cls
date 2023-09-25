/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FileWrapper {
    
    public String id {get;set;}
    //public String thumbnail{get;set;}
    public String name {get;set;}
    //public Integer size {get;set;}
    public String downloadURL{get;set;}
    public Boolean isAccessible {get;set;}
    public String fileType {get;set;}
    public String type {get;set;}
    public String fileExtension {get;set;}
    public List<String> locationList{set;get;}
    public List<String> tages{set;get;} 
    public String fileName{set;get;}
    public blob filebody{set;get;}
    public String context {get;set;}
    public String DocumentId{set;get;}
   // public ContentLiteWrapper parent{set;get;}
    
    public boolean allowComments {set;get;}
    public String author {set;get;}
    public String contentId {set;get;}
    public String contentName {set;get;}
    public boolean coverStory{set;get;}
    public String CSStartDate{set;get;}
    public String CSEndDate{set;get;}
    public Integer downloads {set;get;}
    public Integer duration {set;get;}
    public String groups {set;get;}
    public Integer likes {set;get;}
    public String locations{set;get;}
    public String metadata{set;get;}
    public String MIMeTypec {set;get;}
    public String publishStartDate{set;get;}
    public String publishEndDate{set;get;}
    public String repository {set;get;}
    public Integer shares {set;get;}
    public String simpplrContent {set;get;}
    public Integer size {set;get;}
    public String status {set;get;}
    public String tags{set;get;}
    public String text{set;get;}
    public String thumbnail {set;get;}
    public String title {set;get;}
    public String url {set;get;}
    public String fileId {set;get;}
    public Boolean isImage {get;set;}
    public Boolean isVideo;
    public Boolean isDownloadableOniOS {get; set;}
    public boolean fileDeleted {set;get;}
    public boolean recordDeleted {set;get;}
    public Integer videoStatus; 
    
    public String thumbnailMed {set; get;}
    public String thumbnailLarge {set; get;}
    public String thumbnailSml {set; get;}
    
    public String provider {set; get;}
    public String rootDirectory {get;set;}
    // @description Sharepoint file InstanceId
    public String spInstanceId {set; get;}
    public FileWrapper(){
        locationList = new List<String>();
        tages = new List<String>();
        isDownloadableOniOS = true;
    }
    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    *      parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public static FileWrapper parseFileWrapper(String json) {
        return (FileWrapper) System.JSON.deserialize(json, FileWrapper.class);
    } 
    
        /**
    * @Class [Class Name] 
    * @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
    *
    */
    public class FileFilterWrapper{
        public Set<FilterAttributeWrapper> sites{get;set;}
        public Set<FilterAttributeWrapper> providers{get;set;}
        public Boolean canCreateBoxFolder{get;set;}
        public Boolean isManager {get;set;}
        public FileFilterWrapper(){
            this.sites = new Set<FilterAttributeWrapper>();
            this.providers = new Set<FilterAttributeWrapper>();
        }
        
    }   
    
    public class FilePaginationWrapper{
        public List<Object> objectList{get;set;}
        public String nextPageToken{get;set;}
        public String nextPageUrl{get;set;}
        public String endIndex{get;set;}
      
        public FilePaginationWrapper(){
            this.objectList = new List<Object>();
        }
        
    } 

    public FileWrapper(String url){
        this.url=url;
        isDownloadableOniOS = true;
    }
}