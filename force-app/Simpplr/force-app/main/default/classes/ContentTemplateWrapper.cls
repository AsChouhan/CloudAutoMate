public with sharing class ContentTemplateWrapper implements Comparable{
    
    public String id;
    public String templateId;
    public String siteId;
    public String type;
    public String contentTemplateSubType;
    public Boolean isEnabled;
    public Boolean isDeleted;
    public Boolean isSystemTemplate;
    public String language;
    public String title;
    public String body;
    public String editUrl;
    public String url;
    public String name;
    public boolean canEdit;
    public boolean canDelete;
    public boolean canDuplicate;
    public boolean canMove;
    public boolean canChangeStatus;
    public String imgCaption;
    public String coverImgLayout;
    public String img;
	public String imgLandscape;
	public String imgOriginal;
    public CategoryWrapper category;
    public SiteLiteWrapper site;
    public String createdAt;   //2015-08-17T07:16:37.000Z
	public String modifiedAt;
    public List<TopicWrapper> listOfTopics;
    public List<String> listOfTemplateTopicIds;
    public PeopleListWrapper authoredBy;
    public List<FileContentWrapper> listOfInlineImages;
	public List<FileContentWrapper> listOfInlineVideos;
	public FileContentWrapper imgOriginalFile;
	public FileContentWrapper imgFile;
	public FileContentWrapper imgLandscapeFile;

    public ContentTemplateWrapper (){
    }

    public Integer compareTo(Object compareTo){
        return 0;
    }

    /**
     * @description TemplateFilesWrapper
     */
    public class TemplateFilesWrapper {
        public String folderId; 
        public String location; 
        public String titleImageType;
    	public FileContentWrapper fileWrapperObj;
    }

    /**
     * 
     * @Description:  [This method convert the json string to ContentTemplateWrapper object]
     * @Parameters:
     * json -> json string of ContentTemplateWrapper object
     *      
     * @Returns:  [Returns ContentTemplateWrapper object corresponding to json stirng]
    */
    public static ContentTemplateWrapper parse(String json){
		return (ContentTemplateWrapper) System.JSON.deserialize(json, ContentTemplateWrapper.class);
	}
}