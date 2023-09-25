/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FilterAttributeWrapper implements Comparable {
	public String id{get;set;}
    public String name{get;set;}
    public String type;
	public Boolean isLinked{get;set;}
	public FilterAttributeWrapper() {
		
	}
	
	public FilterAttributeWrapper(String id, String name){
		this.id = id;
		this.name = name;
	}
	
	public Integer compareTo(Object compareToObj) {
    	FilterAttributeWrapper fAWObj = (FilterAttributeWrapper)compareToObj;
        return name.toLowerCase().compareTo(fAWObj.name.toLowerCase());     
	}
	
}