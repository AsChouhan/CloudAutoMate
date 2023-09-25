/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class TopicWrapper {
	
	public String id {get;set;}
	public String topicAssignmentId {get;set;}
	public String topicDisplayName{set;get;}
    public String topicName{set;get;}
    public Integer topicCount{set;get;}
    public String topicid {get;set;}
	public String name {get;set;}
	public String url {get;set;}
    public String topicurl {get;set;}
    public String feedUrl {get;set;}
	public Boolean canEdit{get;set;}
	public Boolean canDelete{get;set;}
    public Boolean isEndorsedByCurrentUser{get;set;}
    public Boolean isSelfEndorsed{get;set;}
	public Integer talkingAboutCount{get;set;}
	public PeopleLiteWrapper authoredBy{get;set;}
	public Boolean isFollowing{get;set;}
	
	public TopicWrapper(){
		authoredBy = New PeopleLiteWrapper();
	}
	
	public TopicWrapper(String id,String name){
    	this.id = id;
    	this.name = name;
    }

	public TopicWrapper(String id, String name, String url){
		this();
		this.id = String.isBlank(id)?'':id;
		this.name = String.isBlank(name)?'':name;
		this.url = String.isBlank(url)?'':url;
	}
    public TopicWrapper(String id, String name, Integer topicCount){
	}
}