/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SiteWrapper {
	public static final String SITE_ABOUT_DEFAULT_TEXT = 'Site Managers are yet to add About text';
	
	public String siteImageThumbnail;
	public String name;
	public String description;
	public String category;
	public String categoryName;
	public string access;
	public boolean isMandatory;
	public boolean isFeatured;
	public boolean isBroadcast;
	public List<FileContentWrapper> titleImage = new List<FileContentWrapper>();
	public String titleImageCaption;
	public List<String> deletedTitleImage = new List<String>();
	
	public SiteWrapper(){
	}
	
   /**
	* @Class [Class Name] 
	* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
	*
	*/
	public class SiteFilterWrapper{
		public Set<FilterAttributeWrapper> categories{get;set;}
		public Boolean canCreate{get;set;}
		public Boolean isManager{get;set;}
		public SiteFilterWrapper(){
			this.categories = new Set<FilterAttributeWrapper>();
		}
	}
	
	public class MandatoryWrapper {
		public List<String> idsArray {get;set;}
		public Boolean makeMandatoryBool {get;set;}
	}
	
	public class FeaturedWrapper {
		public String segmentId; 
		public List<String> listOfSiteIds {get;set;}
		public Boolean makeFeaturedBool {get;set;}
	}
	
	public class FeaturedSegmentWrapper {
		public List<SiteSegmentWrapper> idsArray {get;set;}
		public Boolean makeFeaturedBool {get;set;}
	}	
	
	public class SiteSegmentWrapper {
		public String siteId {get;set;}
		public List<String> segmentIds {get;set;}
	}
	
	public class PrivateWrapper {
		public List<String> idsArray {get;set;}
		public Boolean makePrivateBool{get;set;}
	}
	
	public class ActivateWrapper {
		public List<String> idsArray {get;set;}
		public Boolean makeActivatedBool{get;set;}
	}
	
	public class EditSiteCategoryWrapper {
		public List<String> idsArray {get;set;}
		public CategoryWrapper categoryObj {get;set;}
		
		public EditSiteCategoryWrapper(){
			this.categoryObj = new CategoryWrapper();
		}	
	}
	public class CategoryWrapper {
		public String category {get;set;}
		public String categoryName{get;set;}
	}
	public class SequenceWrapper {
		public String segmentId{get;set;}
		public List<Id> idsArray {get;set;}
	}

	public class AddPeopleParams {
        public String siteId;
        public List<UserDetail> userDetail; 
    }

    public class UserDetail {
        public String sfUserId;
        public String membershipType; 
    }

	/**
	 * @description wrapper for get endpoint of  Duplicate site
	 */
    public class DuplicateSite {
        public String siteId;
        public Boolean shouldCopyPageCategories; 
        public Boolean shouldCopyDashboard; 
    }
	
}