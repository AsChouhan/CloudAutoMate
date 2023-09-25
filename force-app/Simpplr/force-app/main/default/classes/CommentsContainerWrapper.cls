/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class CommentsContainerWrapper {
	
	public String nextPageToken {get;set;}
	public List<CommentsWrapper> listOfItems {get;set;}
	
	public CommentsContainerWrapper(){
		listOfItems = new List<CommentsWrapper>();
	}
}