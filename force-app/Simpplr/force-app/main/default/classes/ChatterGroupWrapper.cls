public with sharing class ChatterGroupWrapper {
    public String chatterGroupId;
    public String name;
    public String url;
    public String access;
    public Integer memberCount;
    
    public class PaginationWrapper {
        public String nextPageToken;
        public Integer totalRecords;
        Public List<ChatterGroupWrapper> listOfItems = new List<ChatterGroupWrapper>();
    }
    
}