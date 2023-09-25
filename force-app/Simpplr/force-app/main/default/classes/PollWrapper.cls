/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PollWrapper {
	
	public String title {get;set;}
	public List<PollChoiceWrapper> listOfAnswers {get;set;}
	public Integer totalVotes {get;set;}
	public Boolean hasVoted {get;set;}
	public String myChoiceId {get;set;}
	
	public PollWrapper(){
		listOfAnswers = new List<PollChoiceWrapper>();
	}
}