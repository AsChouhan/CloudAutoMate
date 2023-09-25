public with sharing class ContentTopStory implements comparable {
	
	public String id;
    public Integer popularityScore;
    
	public ContentTopStory(String id, Integer popularityScore) {
    	this.id = id;
    	this.popularityScore = popularityScore; 
    	
    }
    
    public Integer compareTo(Object compareTo) {
        ContentTopStory compareToEmp = (ContentTopStory)compareTo;
        if(popularityScore==null || compareToEmp.popularityScore==null){
        	return 0;
        }
        if (popularityScore == compareToEmp.popularityScore) return 0;
        if (popularityScore < compareToEmp.popularityScore) return 1;
        return -1;       
    }
    
    
}