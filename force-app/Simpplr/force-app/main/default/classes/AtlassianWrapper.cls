public with sharing class AtlassianWrapper {
    
    public String atlassianClientId;
    public String atlassianClientSecret;
    public Boolean atlassianEnabled;
    public String atlassianConnectedAs;
    public Boolean atlassianKeysSaved;
    public String atlassianInstanceUrl;
    public Boolean confluenceEnabled;      
    public String customConfluenceKnowledgeBaseName;
    public Boolean isConfluenceKnowledgeDefaultSelected;
    public Boolean isConfluenceKnowledgeSpacesSelected;
    public Boolean showAtlassianVPNMessage;
    public List<KnowledgeBaseWrapper> confluenceKBWrapperList;

    public class KnowledgeBaseWrapper {
        public String id;
        //public String key;
        public String name;
        //public String type;
        //public String status;
        //public Boolean isDeleted;
        //public string url;
    }

    public class ConfluenceSpacesWrapper {
        public List<KnowledgeBaseWrapper> results;
        public String nextPageToken;
    }

    public class SearchWrapper{
        public List<KBItemSearchWrapper> results;
        public String nextPageToken;
        public Integer totalRecords;

    }

    public class KBItemSearchWrapper {
        public String itemType;
		public SearchItemWrapper item;
    }

    public class SearchItemWrapper{
        public String space;
        public String url;
        public String title;
        public PeopleListWrapper authoredBy;
        public String modifiedAt;
        public String description;
        public String id;
    }

    public class ContributorWrapper{
        public List<ContributorItemWrapper> results;
        public String nextPageToken;

    }

    public class ContributorItemWrapper{
        public String id;
        public String confluenceUserId;
        public Boolean isSimpplrUser;
        public String name;
        public PeopleListWrapper people;
    }
}