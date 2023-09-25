public with sharing class AutoCompleteWrapper implements Comparable{
    public String id;
	public String name;
	public String title; 
	public Boolean isPrivate;
	public Boolean isListed;
	public Boolean isMustRead ;
	public Boolean hasRead;
	public String img; 
	public String imgTHUMB240BY180URL;
	public String type; 
	public Boolean isPromoted;
	public String resourceType;
	public String url;
	public String startsAt;
	public String timezoneName;
	public String timezoneIso;
	public Integer timezoneOffset;
	public PeopleLiteWrapper authoredBy = new PeopleLiteWrapper();
	public String access;
	public String siteId;
	public Integer score;
	public Double aws_score;
	public Integer baseScore;
	public Long publishStartDateTimeInLong;
	public SiteLiteWrapper site;
	public String imgContentDocumentId;
	public String siteTitleContentDocumentId;
	
	public Integer compareTo(Object compareTo) 
    {
        AutoCompleteWrapper Obj = (AutoCompleteWrapper) compareTo;
        	if (score == obj.score) {
        		if(baseScore == obj.baseScore) {
        			if(baseScore == 3 && publishStartDateTimeInLong != Obj.publishStartDateTimeInLong) {
        				return (publishStartDateTimeInLong > obj.publishStartDateTimeInLong ? -1 : 1);
        			} else {
        				return (name.compareTo(obj.name));
        			}
        		}else {
        			return (baseScore > obj.baseScore ? -1 : 1);
        		}
        	} else {
        		return (score > obj.score  ? -1 : 1);
        	}
	        	
    }
}