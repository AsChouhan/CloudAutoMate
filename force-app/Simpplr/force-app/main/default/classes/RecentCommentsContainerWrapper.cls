/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class RecentCommentsContainerWrapper {
	
	public String nextPageToken {get;set;}
	public List<RecentCommentsWrapper> listOfRecentComments {get;set;}
	public List<RecentCommentsWrapper> listOfItems {get;set;}
	public Integer total {get;set;}
	
	public RecentCommentsContainerWrapper(){
		listOfRecentComments = new List<RecentCommentsWrapper>();
	}
	
}