/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ExpertiseWrapper {
	
	public String id;
    public Integer users;
    public String expertiseid;
	public String name;
	public String url;
	public Boolean canEdit;
	public Boolean canDelete;
    public Boolean isSelfEndorsed;
	public PeopleLiteWrapper authoredBy;
	
	public ExpertiseWrapper() {
		authoredBy = New PeopleLiteWrapper();
	}
}