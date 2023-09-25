public with sharing class OrgChartWrapper {
    public OrgChartNode grandparent;
	public OrgChartNode parent;
	public List<OrgChartNodeItem> siblings;
	public OrgChartNode userNode;
	public List<OrgChartNodeItem> children;
	public Boolean showSelfInVertical;
	public Boolean showChildrenInVertical;
	public String nextPageToken;
	
	public class OrgChartNodeItem{
    	public Integer childCount;
    	public PeopleLiteWrapper user;
    }
    
    public class OrgChartNode{
    	public OrgChartNodeItem person;
    	public List<OrgChartNodeItem> siblings;
    }
}