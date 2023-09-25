/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PollChoiceWrapper {
	
	public String id {get;set;}
	public String title {get;set;}
	public Integer voteCount {get;set;}
	public Decimal percentage {get;set;}
	public Integer position {get;set;}
}