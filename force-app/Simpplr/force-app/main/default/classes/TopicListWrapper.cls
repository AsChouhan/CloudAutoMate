/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class TopicListWrapper {
	
	public List<TopicWrapper> records{get;set;}
	
	public TopicListWrapper() {
		records = new List<TopicWrapper>();

    }
}