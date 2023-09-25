public with sharing class SegmentWrapper implements Comparable{
	public Boolean isDeleted;
	public String segmentId;
	public String id;
	public String name;
	public Boolean isManager;
	public String createdAt;
	public PeopleLiteWrapper createdBy;
	public String modifiedAt;
	public PeopleLiteWrapper modifiedBy;
	public Integer audienceCount;
	public List<SubsegmentWrapper> listOfSubsegments; 
	public List<SubsegmentWrapper> subsegments; 
	public List<PeopleLiteWrapper> listOfManagers;

	public Integer compareTo(Object compareToObj) {
		SegmentWrapper segmentObj = (SegmentWrapper)compareToObj;
		return name.toLowerCase().compareTo(segmentObj.name.toLowerCase());
	}
	
	public class SubsegmentListWrapper {
		public Integer audienceCount;
		public List<SubsegmentWrapper> listOfSubsegments; 
		public SubsegmentListWrapper() {
			this.audienceCount = 0;
			this.listOfSubsegments = new List<SubsegmentWrapper>();
		}
	}
	
	public class SubsegmentWrapper {
		public String name;
		public Integer audienceCount;
	}
	
	public class UnassignedWrapper {
		public Integer unclassifiedAudienceCount;
		public List<SubsegmentWrapper> listOfSubsegments;
		public String csvUrl;	
		public UnassignedWrapper() {
			this.listOfSubsegments = new List<SubsegmentWrapper>();
			this.unclassifiedAudienceCount = 0;
		}
	}
	
	public class PaginationWrapper {
		public List<SegmentWrapper> listOfItems = new List<SegmentWrapper>();
    	public UnassignedWrapper unassigned;
	}

	public class UnassignedSegmentUsers {
		public String username;
		public String emailAddress;
		public String companyName;
		public String division;
		public String department;
		public String city;
		public String state;
		public String country;
		
	}	

	/**
	 * @description Options - wrapper class
	 */
	public class Options{
		public Boolean isAppsAndLinksSegmented;
		public Boolean isBrandingSegmented;
		public Boolean shouldInherit;
	}
}