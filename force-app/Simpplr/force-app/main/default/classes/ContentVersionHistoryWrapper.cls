public with sharing class ContentVersionHistoryWrapper{
    public String versionHistoryId;
    public String createdAt;
    public String updatedAt;
    public PeopleListWrapper user;
    public String action;
    public Boolean isAuthor;
    public Boolean isLatest;
     
    public Integer offset {get;set;}
    public String nextPageToken {get;set;} 
    public Integer size {get;set;}

}