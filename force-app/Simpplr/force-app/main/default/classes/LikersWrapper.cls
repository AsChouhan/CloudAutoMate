/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class LikersWrapper implements Comparable {
	public String id {get;set;}
	public String userId {get;set;}
	public String peopleId {get;set;}
	public String name {get;set;}
	public String img {get;set;}
	public String userUrl {get;set;}
	public String url {get;set;}
	public String location {get;set;}
	public String department {get;set;}
	public String title {get;set;}
	public boolean isFollowing {get;set;}
	public boolean canFollow {get;set;}
	public String email {get;set;}
	public boolean isFavorited {get;set;}
	public Boolean isActive {get;set;}
	public Boolean canFavorite {get;set;}
	public String mobile {get;set;}
	public String phone {get;set;}
	public String phoneExtension {get;set;}
	
	public Integer compareTo(Object compareTo) {
        LikersWrapper likersWrapperObj = (LikersWrapper) compareTo;
        if(name==null || likersWrapperObj.name==null){
        	return 0;
        }
        if (name == likersWrapperObj.name) return 0;
        if (name > likersWrapperObj.name) return 1;
        return -1;      
    }
    
    
}