public with sharing class ContnetListingWrapper implements Comparable{
	
	public String id;
	public String contentType;
	public String siteId;
	public Double relevancyScore;
	public Boolean matchedOnTopic;
	public Boolean matchedOnExpertise;
	public Boolean matchedOnPageCategory;
	public String itemType;
	public Long publishStartDateTimeInLong;
	
	public ContnetListingWrapper(){
		
	}
	
	public Integer compareTo(Object compareTo){
        ContnetListingWrapper wrapperObj = (ContnetListingWrapper) compareTo;
        if(relevancyScore==null || wrapperObj.relevancyScore==null){
        	return 0;
        }
         if (relevancyScore == wrapperObj.relevancyScore){
        	if(publishStartDateTimeInLong != wrapperObj.publishStartDateTimeInLong) {
				return (publishStartDateTimeInLong > wrapperObj.publishStartDateTimeInLong ? -1 : 1);
			}else{
				return 0;
			}
        }else{
        	return (relevancyScore > wrapperObj.relevancyScore ? -1 : 1);
    	}
    }
    
}