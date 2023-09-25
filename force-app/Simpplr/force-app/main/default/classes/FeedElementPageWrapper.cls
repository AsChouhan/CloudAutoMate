/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FeedElementPageWrapper {
	
	public Integer total {get;set;}
	public List<FeedElementWrapper> listOfItems {get;set;} 
	public String nextPageToken {get;set;}
	public String timeStamp {get;set;}
	public String updatesToken {get;set;}
	public String type{get;set;}
	public String sortBy{get;set;}
	public Integer postCount{get;set;}
	public Integer questionCount{get;set;}
	public FeedElementPageWrapper(){
		listOfItems = new List<FeedElementWrapper>();
	}	
}