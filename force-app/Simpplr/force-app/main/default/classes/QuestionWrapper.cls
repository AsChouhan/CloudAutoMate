public with sharing class QuestionWrapper {     
    public String id;
    public String questionId;
    public String title;
    public String description;
    public Object body;
    public String siteId;
    public Integer answersCount;
    public Boolean hasApprovedAnswer;
    public SiteLiteWrapper site;
    public PeopleLiteWrapper askedBy;
    public ContentWrapper content;
    public QuestionWrapper duplicateOf;
    public Boolean isDuplicate;
    public Boolean isPublished;
    public String url;
    public String createdAt;
    public String modifiedAt;
    public String editedAt;
    public String publishAt;	//2021-01-18T0716:37.000Z
    public Boolean canDelete;
    public Boolean canEdit;
    public Boolean canMarkDuplicate;
    public Boolean canPublishUnpublish;
    public Boolean markAsDuplicate;
}