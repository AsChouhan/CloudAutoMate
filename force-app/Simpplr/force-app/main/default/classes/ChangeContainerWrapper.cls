/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ChangeContainerWrapper {
	
	public Integer amountNotInSummary {get;set;}
	public String summary {get;set;}
	public List<String> listOfChanges {get;set;}
	
	public ChangeContainerWrapper(){
		listOfChanges = new List<String>(); 
	}
}