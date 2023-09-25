/**
* Class [Class Name] 
* Purpose: 
*
*/
public with sharing class AnalyticsWrapper {
	
	/**
	* Class [Class Name] 
	* Purpose: get adoption count
	*
	*/
	public class AdoptionCount{
		public String csvUrl;
		public AdoptionCountData data;
		
		public AdoptionCount(){
			data = new AdoptionCountData();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose: 
	*
	*/
	public class AdoptionCountData{
		public Decimal usersLoggedIn;
		public Decimal loggedInPercentage;
		public Decimal averageLoginsPerUser;
		public Decimal pageViews; 
	}
	
	/**
	* Class [Class Name] 
	* Purpose: get adoption average
	*
	*/
	public class AdoptionAverage{
		public String csvUrl;
		public List<AdoptionAverageData> data;
		
		public AdoptionAverage(){
			data = new List<AdoptionAverageData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose: 
	*
	*/
	public class AdoptionAverageData{
		public String name{set;get;}
		public Integer count{set;get;}
		
		public AdoptionAverageData(){
		}
		
		public AdoptionAverageData(String name, Integer count){
			this.name = name;
			this.count = count;
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose: 
	*
	*/
	public class AdoptionOverview{
		public Integer contributorCount{set;get;}
		public Integer participantCount{set;get;}
		public Integer observerCount{set;get;}
		public Integer inactiveCount{set;get;}
		public List<AdoptionOverviewData> adoptionOverviewDataList{set;get;}
		public List<String> customFields{get;set;}
		public AdoptionOverview(){
		}
		
		public AdoptionOverview(Integer contributorCount, Integer participantCount, Integer observerCount, Integer inactiveCount, List<AdoptionOverviewData> adoptionOverviewDataList,List<String> customFields){
			this.contributorCount = contributorCount;
			this.participantCount = participantCount;
			this.observerCount = observerCount;
			this.inactiveCount = inactiveCount;
			this.adoptionOverviewDataList = adoptionOverviewDataList;
			this.customFields = customFields;
		}
	}
	/**
	* Class [Class Name] 
	* Purpose: 
	*
	*/
	public class AdoptionOverviewData{
		public List<String> fieldValues{get;set;}
		//UnUsed Attributes
		public String name{get;set;}
		public String email{get;set;}
		public String adoption{get;set;}
		public String segmentname{get;set;}
		public String companyname{get;set;}
		public String division{get;set;}
		public String department{get;set;}
		public String city{get;set;}
		public String state{get;set;}
		public String country{get;set;}
		
		public AdoptionOverviewData(){
		}
		
		public AdoptionOverviewData(String name, String email, String adoption, String city, String state, String country, String department, String segmentName){
		}
		
		public AdoptionOverviewData(People__c peopleObj, String adoption, User userObj, List<String> fieldAPIList){
			fieldValues = new List<String>();
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Full_Name__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Email__c));
			fieldValues.add(adoption);
			if(SimpplrContext.isSegmentsEnabled){
				fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Segment__r.Name__c));
			}
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Company_Name__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Division__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Department__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.City__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.State__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Country__c));
			if(SimpplrContext.isPeopleCategoryEnable){
				fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.People_Category__r.name__c));
			}
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.title__c));
			if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
				fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.role__c));
			}
			for(String field: fieldAPIList){
				fieldValues.add(addFieldValueInDoubleQuotes(String.valueOf(userObj.get(field))));
			}
		}
		
		public AdoptionOverviewData(People__c peopleObj, String adoption, List<String> fieldAPIList){
			fieldValues = new List<String>();
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Full_Name__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Email__c));
			fieldValues.add(adoption);
			if(SimpplrContext.isSegmentsEnabled){
				fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Segment__r.Name__c));
			}
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Company_Name__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Division__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Department__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.City__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.State__c));
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.Country__c));
			if(SimpplrContext.isPeopleCategoryEnable){
				fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.People_Category__r.name__c));
			}
			fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.title__c));
			if('Workday'.equalsIgnorecase(SimpplrContext.PDSSourceApplication) && SimpplrContext.isPDSRole){
				fieldValues.add(addFieldValueInDoubleQuotes(peopleObj.role__c));
			}
			for(String field: fieldAPIList){
				String uField = 'user__r.'+field;
				fieldValues.add(addFieldValueInDoubleQuotes(String.valueOf(peopleObj.get(uField))));
			}
		}
		
		private String addFieldValueInDoubleQuotes(String fieldVal){
			String valToReturn = String.isNotBlank(fieldVal) ? '"'+fieldVal.replace('"','""')+'"' :'';
			return valToReturn;
		}
	}

	public class AppPageViews {
		public String csvUrl;
		public List<ViewsOverTime> data;
		public AppPageViews(){
			data = new List<ViewsOverTime>();
		}
	
	}

	/**
	* Class [Class Name] 
	* Purpose: get NPS Survey Report analytics
	*
	*/
	public class NPSSurveyData{
		public String csvUrl;
		public Integer score;
		public Integer shownToCount;
		public String period;
		public Integer respondedCount;
		public NPSSurveyData(){
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose: get adoption analytics
	*
	*/
	public class Adoption{
		public String csvUrl;
		public List<AdoptionData> data;
		
		public Adoption(){
			data = new List<AdoptionData>();
		}
	}
	
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class AdoptionData implements Comparable{ 
		public String localizedDate {set;get{
			return LocaleContext.getLocalisedDateCSV(day, UserContext.languageLocaleKey);
		}}

		public String day{set;get;}
		public CountData counts{set;get;}
		
		public AdoptionData(){
			counts = new CountData(0, 0);
		}
		
		public AdoptionData(String day){
			this.day = day;
			counts = new CountData(0, 0);
		}
		
		public Integer compareTo(Object compareTo) {
	        AdoptionData AdoptionData = (AdoptionData) compareTo;
	        if(AdoptionData!=null){
	        	Date date1 = Utility.parseStringDate(day);
	        	Date date2 = Utility.parseStringDate(AdoptionData.day);
	        	if(date1==null || date2==null){
	        		return 0;
	        	}
		        if (date1 < date2) return 1;
		        if (date1 > date2) return -1;
	        }
	        return 0;      
	    }
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class CountData{
		public Decimal inactive{set;get;}
		public Decimal active{set;get;}
		
		public CountData(Decimal inactive, Decimal active){
			this.inactive = inactive;
			this.active = active;
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose: get login analytics
	*
	*/
	public class Logins{
		public String csvUrl;
		public List<LoginsData> data;
		public TotalCount totals;
		public Logins(){
			data = new List<LoginsData>();
			totals = new TotalCount(0,0,0,0,0);
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class TotalCount{
		public Decimal percentage;
		public Decimal desktop_percentage;
		/*public Decimal desktop_app_percentage; SV2-3879*/ 
		public Decimal mobile_percentage;
		public Decimal mobile_app_percentage;
		
		public TotalCount(Decimal percentage, Decimal desktop_percentage, 
		Decimal desktop_app_percentage, Decimal mobile_percentage, Decimal mobile_app_percentage){
			this.percentage = percentage;
			this.desktop_percentage = desktop_percentage;
			/*this.desktop_app_percentage = desktop_app_percentage; SV2-3879*/
			this.mobile_percentage = mobile_percentage;
			this.mobile_app_percentage = mobile_app_percentage;
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class LoginsData implements Comparable{
		public String localizedDate {set;get{
			return LocaleContext.getLocalisedDateCSV(day, UserContext.languageLocaleKey);
		}}
		public String day{set;get;}
		public LoginCountData counts{set;get;}
		
		public LoginsData(){
			counts = new LoginCountData(0, 0, 0, 0);
		}
		
		public LoginsData(String dayVal , LoginCountData loginCount){
			day = dayVal;
			counts = loginCount;
		}
		
		public Integer compareTo(Object compareTo) {
	        LoginsData loginsDataObj = (LoginsData) compareTo;
	        if(loginsDataObj!=null){
	        	Date date1 = Utility.parseStringDate(day);
	        	Date date2 = Utility.parseStringDate(loginsDataObj.day);
	        	
	        	if(date1==null || date2==null){
	        		return 0;
	        	}
		        if (date1 < date2) return 1;
		        if (date1 > date2) return -1;
	        }
	        return 0;      
	    }
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class LoginCountData{
		public Decimal desktop{set;get;}
		public Decimal desktop_app{set;get;}
		public Decimal mobile{set;get;}
		public Decimal mobile_app{set;get;}
		
		public LoginCountData(Decimal desktop, Decimal desktop_app, Decimal mobile, Decimal mobile_app){
			this.desktop = desktop;
			this.desktop_app = desktop_app;
			this.mobile = mobile;
			this.mobile_app = mobile_app;
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose: get page view
	*
	*/
    public class PageViews{
		public String csvUrl;
		public List<PageViewsData> data;
		public PageViewsCountData totals;
		public PageViews(){
			data = new List<PageViewsData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class PageViewsData implements Comparable{
		public String localizedDate {set;get{
			return LocaleContext.getLocalisedDateCSV(day, UserContext.languageLocaleKey);
		}}
		public String day{set;get;}
		public PageViewsCountData counts{set;get;}
		
		public PageViewsData(){
			counts = new PageViewsCountData();
		}
		
		public PageViewsData(String day,PageViewsCountData counts){
			this.day = day;
			this.counts = counts;
		}
		
		public Integer compareTo(Object compareTo) {
	        PageViewsData pageViewsDataObj = (PageViewsData) compareTo;
	        if(pageViewsDataObj!=null){
	        	Date date1 = Utility.parseStringDate(day);
	        	Date date2 = Utility.parseStringDate(pageViewsDataObj.day);
	        	
	        	if(date1==null || date2==null){
	        		return 0;
	        	}
		        if (date1 < date2) return 1;
		        if (date1 > date2) return -1;
	        }
	        return 0;      
	    }
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class PageViewsCountData{
		public Integer total{set;get;}
		public Integer desktop{set;get;}
		public Integer desktop_app{set;get;}
		public Integer mobile{set;get;}
		public Integer mobile_app{set;get;}
		
		public PageViewsCountData(){
			
		}
		
		public PageViewsCountData(Integer desktop,Integer desktop_app,Integer mobile,Integer mobile_app){
			this.desktop = desktop;
			this.desktop_app = desktop_app;
			this.mobile = mobile;
			this.mobile_app = mobile_app;
			this.total = desktop + desktop_app + mobile + mobile_app;
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:Engagement feed
	*
	*/
	public class Engagementfeed{
		public String csvUrl;
		public List<EngagementfeedData> data;
		public Engagementfeed(){
			data = new List<EngagementfeedData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class EngagementfeedData implements Comparable{
		public String localizedDate {set;get{
			return LocaleContext.getLocalisedDateCSV(day, UserContext.languageLocaleKey);
		}}
		public String day{get;set;}
		public Map<String,Integer> counts{get;set;}
		public EngagementfeedData(){
			counts = new Map<String,Integer>();
		}
		
		public EngagementfeedData(String dayVal , Map<String,Integer> countMap){
			day = dayVal;
			counts = new Map<String,Integer>(countMap);
		}
		
		public Integer compareTo(Object compareTo) {
	        EngagementfeedData engagementfeedDataObj = (EngagementfeedData) compareTo;
	        if(engagementfeedDataObj!=null){
		        if (Utility.parseStringDate(day) < Utility.parseStringDate(engagementfeedDataObj.day)) return 1;
		        if (Utility.parseStringDate(day) > Utility.parseStringDate(engagementfeedDataObj.day)) return -1;
	        }
        	return 0;      
    	}	
	}
	
	/**
	* Class [Class Name] 
	* Purpose:Engagement Content
	*
	*/
	public class EngagementContent{
		public String csvUrl;
		public List<EngagementContentData> data;
		public EngagementContent(){
			data = new List<EngagementContentData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class EngagementContentData implements Comparable{
		public String localizedDate {set;get{
			return LocaleContext.getLocalisedDateCSV(day, UserContext.languageLocaleKey);
		}}
		public String day{get;set;}
		public Map<String,Integer> counts{get;set;}
		
		public EngagementContentData(){
			counts = new Map<String,Integer>();
		}
		
		public EngagementContentData(String dayVal , Map<String,Integer> countMap){
			day = dayVal;
			counts = new Map<String,Integer>(countMap);
		}
		
		public Integer compareTo(Object compareTo) {
	        EngagementContentData engagementContentDataObj = (EngagementContentData) compareTo;
	        if(engagementContentDataObj!=null){
		        if (Utility.parseStringDate(day) < Utility.parseStringDate(engagementContentDataObj.day)) return 1;
		        if (Utility.parseStringDate(day) > Utility.parseStringDate(engagementContentDataObj.day)) return -1;
	        }
        	return 0;
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:Engagement Content Types
	*
	*/
	public class EngagementContentTypes{
		public String csvUrl;
		public List<EngagementContentTypesData> data;
		
		public EngagementContentTypes(){
			data = new List<EngagementContentTypesData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class EngagementContentTypesData implements Comparable{
		public String day{get;set;}
		public EngagementContentTypesCountData counts{get;set;}
		public EngagementContentTypesData(){
			counts = new EngagementContentTypesCountData();
		}
		
		public EngagementContentTypesData(String dayVal , EngagementContentTypesCountData countForContent){
			day = dayVal;
			counts = countForContent;
		}
		
		public Integer compareTo(Object compareTo) {
	        EngagementContentTypesData engagementContentTypesDataObj = (EngagementContentTypesData) compareTo;
	        if(engagementContentTypesDataObj!=null){
		        if (Utility.parseStringDate(day) < Utility.parseStringDate(engagementContentTypesDataObj.day)) return 1;
		        if (Utility.parseStringDate(day) > Utility.parseStringDate(engagementContentTypesDataObj.day)) return -1;
	        }
        	return 0;
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class EngagementContentTypesCountData{
		public Integer albums{get;set;}
		public Integer pages{get;set;}
		public Integer events{get;set;}
		public Integer blog_posts{get;set;}
		
		public EngagementContentTypesCountData(){
			albums = 0;
			pages = 0;
			events = 0;
			blog_posts = 0;
		}
		
		
	}
	
	/**
	* Class [Class Name] 
	* Purpose:performance sites
	*
	*/
	public class PerformanceSites{
		public String csvUrl;
		public List<PerformanceSitesData> data;
		public PerformanceSites(){
			data = new List<PerformanceSitesData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:performance sites
	*
	*/
	public class PerformanceSitesData implements Comparable{
		public String name{get;set;}
		public String url{get;set;}
		public Integer count{get;set;}
		public Boolean isActive{get;set;}
		
		public PerformanceSitesData(){
			count = 0;
		}
		public Integer compareTo(Object compareTo) {
	        PerformanceSitesData performanceSitesDataObj = (PerformanceSitesData) compareTo;
	        if(performanceSitesDataObj!=null){
	        	if(count==null || performanceSitesDataObj.count==null){
	        		return 0;
	        	}
		        if (count < performanceSitesDataObj.count) return 1;
		        if (count > performanceSitesDataObj.count) return -1;
		        if(count == performanceSitesDataObj.count){
		        	 return (name.CompareTo(performanceSitesDataObj.name));
		        }
	        }
	        return 0;      
    	}	
	}
	
	/**
	* Class [Class Name] 
	* Purpose:performance people
	*
	*/
	public class PerformancePeople{
		public String csvUrl;
		public List<PerformancePeopleData> data;
		public PerformancePeople(){
			data = new List<PerformancePeopleData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class PerformancePeopleData implements Comparable{
		public String name{get;set;}
		public String url;
		public Integer count{get;set;}
		public Boolean isActive{get;set;}
		
		public PerformancePeopleData(){
			count = 0;
		}
		public Integer compareTo(Object compareTo) {
	        PerformancePeopleData performancePeopleDataObj = (PerformancePeopleData) compareTo;
	        if(performancePeopleDataObj!=null){
	        	if(count==null || performancePeopleDataObj.count==null){
	        		return 0;
	        	}
		        if (count < performancePeopleDataObj.count) return 1;
		        if (count > performancePeopleDataObj.count) return -1;
		        
		        if(count == performancePeopleDataObj.count){
		        	 return (name.CompareTo(performancePeopleDataObj.name));
		        }
	        }
	        return 0;      
    	}	
	}

	public class PeopleOverview{
		public PeopleOverviewData data;
		public PeopleOverview(){
			data = new PeopleOverviewData();
		}
	}

	public class PeopleOverviewData{
		public Integer totalUserCount{get;set;}
		public Integer activeUserCount{get;set;}
		public Integer departmentCount{get;set;}
		public Integer locationCount{get;set;}
		public Integer customCategoryCount{get;set;}
		
	}
	
	/**
	* Class [Class Name] 
	* Purpose:performance Content
	*
	*/
	public class PerformanceContent{
		public String csvUrl;
		public List<PerformanceContentData> data;
		public Boolean hasLowActivityContent{get;set;}
		public PerformanceContent(){
			data = new List<PerformanceContentData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class PerformanceContentData implements Comparable{
		public String name{get;set;}
		public String url{get;set;}
		public Integer count{get;set;}
		public Integer popularityScore{get;set;}
		public String status{get;set;}
		//for csv
		public Integer shares{get;set;}
    	public Integer views{get;set;}
    	public Integer replies{get;set;}
    	public Integer favorites{get;set;}
    	public Integer posts{get;set;}
    	public Integer likes{get;set;}
    	public String type{get;set;}
    	public String siteName{get;set;}
    	public String authorName{get;set;}
    	public String publishedDate{get;set;}
		public String publishedLocalizedDate {set;get{
			return String.isBlank(publishedDate) ? '' : LocaleContext.getLocalisedDateCSV(publishedDate, UserContext.languageLocaleKey);
		}}
    	public Integer value{get;set;}
    	
		public PerformanceContentData(){
			count = 0;
		}
		
		public Integer compareTo(Object compareTo) {
	        PerformanceContentData performanceContentDataObj = (PerformanceContentData) compareTo;
	        if(performanceContentDataObj!=null){
	        	if(count==null || performanceContentDataObj.count==null){
	        		return 0;
	        	}
		        if (count < performanceContentDataObj.count) return 1;
		        if (count > performanceContentDataObj.count) return -1;
		        
		        if(count == performanceContentDataObj.count){
		        	 return (name.CompareTo(performanceContentDataObj.name));
		        }
	        }
	        return 0;      
    	}	
	}
	
	/**
	* Class [Class Name] 
	* Purpose:performance topics
	*
	*/
	public class PerformanceTopics{
		public String csvUrl;
		public List<PerformanceTopicsData> data;
		public PerformanceTopics(){
			data = new List<PerformanceTopicsData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class PerformanceTopicsData implements Comparable{
		public String name{get;set;}
		public String url;
		public Integer count{get;set;}
		public PerformanceTopicsData(){
			count = 0;
		}
		public Integer compareTo(Object compareTo) {
	        PerformanceTopicsData performanceTopicsDataObj = (PerformanceTopicsData) compareTo;
	        if(performanceTopicsDataObj!=null){
	        	if(count==null || performanceTopicsDataObj.count==null){
	        		return 0;
	        	}
		        if (count < performanceTopicsDataObj.count) return 1;
		        if (count > performanceTopicsDataObj.count) return -1;
		        
		        if(count == performanceTopicsDataObj.count){
		        	 return (name.CompareTo(performanceTopicsDataObj.name));
		        }
	        }
	        return 0;      
    	}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:performance search
	*
	*/
	public class PerformanceSearch{
		public String csvUrl;
		public List<PerformanceSearchData> data;
		public PerformanceSearch(){
			data = new List<PerformanceSearchData>();
		}
	}
	
	/**
	* Class [Class Name] 
	* Purpose:
	*
	*/
	public class PerformanceSearchData implements Comparable{
		public String name{get;set;}
		public String url;
		public Integer count{get;set;}
		public PerformanceSearchData(){
			count = 0;
		}
		public Integer compareTo(Object compareTo) {
	        PerformanceSearchData performanceSearchDataObj = (PerformanceSearchData) compareTo;
	        if(performanceSearchDataObj!=null){
	        	if(count==null || performanceSearchDataObj.count==null){
	        		return 0;
	        	}
		        if (count < performanceSearchDataObj.count) return 1;
		        if (count > performanceSearchDataObj.count) return -1;
		        
		        if(count == performanceSearchDataObj.count){
		        	 return (name.CompareTo(performanceSearchDataObj.name));
		        }
	        }
	        return 0;      
    	}
	}
	
	public class NPSData{
	    	public String orgId;
	    	public String packageVersion;
	    	public String userid; 
	    	public String nps_q;
	    	public Integer nps_s;
	    	public String nps_vq;
	    	public String nps_va;
    }
    
    public class AppNotification{
        public String id;
        public Boolean is_read;
        public Boolean is_new;
        public Boolean is_grouped;
        public String type;
        public String category;
        public String sub_type;
        public String status;
        public String sent_to;
        public String parent_object_id;
        public String object_id;
        public String object_type;
        public String content;
        public String sent_by;
        public String snippet;
        public DateTime created_datetime;
        public String record_id;
        public String org_id;
        public Integer action_count;
        public String action_by;
        public String action_comment;
        public DateTime action_on;
        public String csv_download_request;
        public String external_id;
        public String external_url;
        public String guid;
        public Boolean is_deleted;
        public String old_notification_id;
        public String rab_1;
        public String rab_2;
        public String rab_3;
        public String rab_4;
        public String rab_5;
        public String site_id;
        public String submitter_comment;
    }

    public class AnalyticsAdoption{
    public Date record_date;
    public Integer desktop;
    public Integer desktop_app;
    public Boolean is_active;
    public Boolean is_contributer;
    public Boolean is_observer;
    public Boolean is_participant;
    public Boolean used_native_ios;
    public Boolean used_native_android;
    public Boolean used_hybrid_ios;
    public Boolean used_hybrid_android;
    public Integer mobile;
    public Integer mobile_app;
    public Integer page_views;
	public Integer content_views;
    public Integer total_logins;
    public String people_id;
    public String user;
    public String record_id;
    public String org_id_people_id;
    }
    
    public class AnalyticsContentCount{
    public Date record_date;
    public Integer albums;
    public Integer blogs;
    public Integer bookmarks;
    public Integer events;
    public Integer likes;
    public Integer pages;
    public Integer posts;
    public Integer replies;
    public Integer shares;
    public Integer views;
    public String site;
    public String record_id;
    public String org_id_site_id;
    }

   public class AnalyticsFeedCount{
    public Date record_date;
    public Integer likes;
    public Integer posts;
    public Integer replies;
    public Integer shares;
    public String site;
    public String record_id;
    public String org_id_site_id;
    }
    
    public class AnalyticsLogin{
    public Date record_date;
    public Decimal average_logins_per_user;
    public Integer desktop;
    public Integer desktop_app;
    public Integer mobile;
    public Integer mobile_app;
    public Integer page_views;
    public Integer total_active_salesforce_user;
    public Integer total_logins;
    public Integer total_simpplr_users;
    public Integer unique_logins;
    public Integer users_logged_in;
    public Integer likes;
    public Integer posts;
    public Integer replies;
    public Integer shares;
    public Integer content_views;
    public Integer hybrid_android_app;
    public Integer hybrid_ios_app;
    public Integer native_android_app;
    public Integer native_ios_app;
    public String record_id;
    }
	
	public class AnalyticsPageView{
    public Date record_date;
    public Integer desktop;
    public Integer desktop_app;
    public Integer mobile;
    public Integer mobile_app;
    public String record_id;
    }

	public class AnalyticsSearchResultSelect{
    public String content;
    public String context;
    public String created_by_people;
    public String org_id_created_by_people_id;
    public String file_id;
    public Boolean is_external;
    public String item_type;
    public String people;
    public Integer position;
    public Integer page_position;
    public Integer score;
    public String section;
    public String site;
    public String site_context;
    public String subsection;
    public String term;
    public String record_id;
    public String org_id_content_id;
    public String org_id_site_id;
    public String org_id_people_id;
    public Date record_date;
    public String record_date_time;
    }

	public class AnalyticsSocialCampaign{
    public Date record_date;
    public Integer likes;
    public Integer shares;
    public String social_campaign_share;
    public String record_id;
    public String network_share;
    public String social_campaign;
    }
    
    public class AnalyticsTopContent{
    public String id;
    public String content;
    public String content_type;
    public String site;
    public Date record_date;
    public Integer bookmarks;
    public Integer likes;
    public Boolean is_published;
	public Boolean is_validated;
	public Boolean is_validation_expired;
	public Boolean is_validation_pending;
    public Integer popularity_score;
    public Integer posts;
    public Integer replies;
    public Integer shares;
    public Integer unuseful;
    public Integer useful;
    public Integer views;
    public String org_id_content_id;
    public String org_id_site_id;
    public String record_id;
    }
	
	public class AnalyticsTopPeople{
    public String id;
    public Date record_date;
    public Integer bookmarks_made;
    public Integer bookmarks_received;
    public Integer feed_mentions;
    public Integer content_published;
    public Integer followers;
    public Integer following;
    public Integer likes_made;
    public Integer likes_received;
    public Integer posts;
    public Integer replies_made;
    public Integer replies_received;
    public Integer shares_made;
    public Integer shares_received;
    public Integer views_received;
    public String people_id;
    public String org_id_people_id;
    public String record_id;
    }
    
    public class AnalyticsTopSearch{
    public Date record_date;
    public Integer search_results_count;
    public String search_text;
    public String search_type;
    public String record_id;
    public String site;
    }
	
	public class AnalyticsTopSite{
    public String id;
    public Date record_date;
    public Integer content_published;
    public Integer likes;
    public Integer members;
    public Integer popularity_score;
    public Integer posts;
    public Integer replies;
	public Integer shares;
	public Integer bookmarks;
    public Integer views;
	public Integer content_hybrid_app_views;
    public Integer dashboard_hybrid_app_views;
    public Integer dashboard_mobile_browser_Views;
    public Integer content_mobile_browser_Views;
    public Integer content_web_browser_Views;
    public Integer dashboard_web_browser_views;
    public String site_name;
    public String org_id_site_id;
    public String site;
	public String record_id;
    

    }
    	
	public class AnalyticsTopTopic{
    public Date record_date;
    public Integer endorsements;
    public Integer expertise;
    public Integer followers;
    public Integer views;
	public Integer contents;
	public Integer posts;
	public Integer comments;
    public String topic_name;
    public String org_id_topic_id;
    public String record_id;
    public String topic_id;
    }
    
    public class AdoptionEmail {
    	public String email_json;
    	public Integer email_month;
    	public String record_id; 
    }
	
	public class Site{
		public String id;
	public String site_id;
	public String site_name;
	public String site_type;
	public Boolean is_active;
	public String chatter_group_id;
	public Boolean is_featured;
	public Boolean is_newsletter_allowed;
	public Boolean is_alert_enabled;
	public Boolean is_must_read_enabled;
	public Boolean has_albums;
	public Boolean has_events;
	public Boolean has_pages;
	public String banner_content_document;
	public String cover_content_document;
	public String title_content_document;
	public String site_category;
	public String site_category_name;
	public Boolean show_in_simpplr;
	public String landing_page;
	public String origin;
	public String site_created_date;
	public Integer member_count;
	public String layout ;
	public String file_storage_source ;
	public Boolean allow_file_upload_app_permission;
	public Boolean is_onboarding_enabled;
	}
	
	public class Content{
		public String id;
	public String content_id;
	public String content_title;
	public String content_type;
	public String content_sub_type;
	public String author_id;
	public String site;
	public String org_id_site_id;
	public String org_id_people_id;
	public String first_publish_date;
	public String publish_start_date;
	public String publish_end_date;
	public String last_validated_date_time;
	public Boolean is_deleted;
	public String status;
	public Double album_video_count;
	public Double album_image_count;
	public Decimal version;
	public Boolean event_rsvp_allowed;
	public String event_rsvp_deadline;
	public Integer rsvp_removed_count; 
	public Integer topic_count ;
	public Integer read_time ;
    public String onboarding_status;
    public Date onboarding_added_date;
	}
	
	public class Topic{
		public String id;
	public String topic_id;
	public String topic_name;
	}

	public class People {
		public String id;
		public String people_id;
		public String people_name;
		public String people_category;
		public String people_category_name;
		public String segment_id;
		public String segment_name;
		public String title;
		public String department;
		public String company_name;
		public String division;
		public String city;
		public String street;
		public String state;
		public String country;
		public Boolean is_active;
		public Boolean is_site_manager;
		public Integer managing_site_count;
		public String app_moderation_permission;
		public String unlisted_site_moderation_permission;
		public Boolean can_access_analytics;
		public Boolean can_control_dashboard;
		public Boolean can_send_alert;
		public Boolean can_send_newsletter;
		public Boolean is_influencer;
		public Boolean is_campaign_manager;
		public String profile_photo_fill_datetime;
		public String cover_photo_fill_datetime;
		public String aboutme_fill_datetime;
		public String phone_fill_datetime;
		public String mobile_fill_datetime;
		public String birthdate_fill_datetime;
		public String last_edited_datetime;
		public String last_sync_datetime;
		public String language;
		public String first_login_datetime;
		public String custom_field_1;
		public String custom_field_2;
		public String custom_field_3;
		public String custom_field_4;
		public String custom_field_5;
		public String custom_field_6;
		public String custom_field_7;
		public String custom_field_8;
		public String custom_field_9;
		public String custom_field_10;
		public String custom_field_11;
		public String custom_field_12;
		public String custom_field_13;
		public String custom_field_14;
		public String custom_field_15;
		public String custom_field_16;
		public String custom_field_17;
		public String custom_field_18;
		public String custom_field_19;
		public String custom_field_20;
		public String custom_field_21;
		public String custom_field_22;
		public String custom_field_23;
		public String custom_field_24;
		public String custom_field_25;							

		public Boolean allow_simpplr_emails;
		public Boolean email_endorses_me;
		public Boolean email_my_content_post;
		public String email_actionable_notification_frequency;
		public String email_notification_digest_frequency;
		public String email_digest_frequency;
		public String content_digest_frequency;
		public Boolean receive_content_useful_notifications;
		public Boolean email_made_site_manager_or_owner;
		public Boolean native_mob_content_submit_moderation;
		public Boolean native_mobile_event_invite_more;
		public Boolean native_mob_comments_on_my_post;
		public Boolean email_subscription_moderation;
		public Boolean email_comments_after_me;
		public Boolean email_follows_me;
		public Boolean email_my_content_share;
		public String email_content_digest_frequency;
		public Boolean email_content_submitted_for_moderation;
		public Boolean email_private_site_membership_response;
		public String default_site_digest_frequency;
		public Boolean email_event_invite_more;
		public Boolean email_content_marked_as_must_read;
		public Boolean native_mob_private_site_membership_req;
		public Boolean native_mobile_follows_me;
		public Boolean native_mob_like_my_post_or_comment;
		public Boolean email_comments_on_my_post;
		public Boolean email_like_my_post_or_comment;
		public Boolean email_posts_on_my_profile;
		public Boolean email_my_content_approved;
		public Boolean email_private_site_membership_requests;
		public Boolean email_content_submission_response;
		public String notification_digest_frequency;
		public Boolean email_updates_content_sites_i_follow;
		public Boolean email_my_content_like_or_share;
		public Boolean native_mob_update_content_site_i_follow;
		public Boolean native_mobile_my_content_like_or_share;
		public Boolean native_mob_my_content_post;
		public Boolean email_comments_on_post_i_like;
		public Boolean email_mentions_me;
		public Boolean email_shares_my_post;
		public Boolean email_my_content_rejected;
		public String actionable_notification_frequency;
		public Boolean email_content_useful;
		public Boolean receive_content_update_notifications;
		public Boolean email_posts_to_me;
		public String email_site_analytics_frequency;
		public Boolean native_mob_posts_to_me;
		public String show_in_simpplr;
		public Boolean email_my_content_validation_required;
		public Boolean email_my_content_validation_expired;

		public Boolean email_alerts;
		public Boolean sms_alerts;
		public Boolean sms_must_reads;
		public Boolean sms_content_promotion_message;
		public Boolean native_mobile_alerts;
		public Boolean native_mob_content_marked_as_must_read;
		
		public boolean integration_box_enabled;
		public boolean integration_dropbox_enabled;
		public boolean integration_google_drive_enabled;
		public boolean integration_onedrive_enabled;
		public boolean integration_sharepoint_enabled;
		public boolean integration_servicenow_enabled;
		public boolean integration_linkedin_enabled;
		public boolean integration_twitter_enabled;
		public boolean integration_slack_content_share_enabled;
		public boolean integration_slack_unfurl_enabled;
		public String layout ;
		public string mobile_app_type;

		public Boolean is_protected_author;
		public Boolean is_protected_author_allowlisted;
		public Boolean email_updates_event_i_rsvp_yes ;
		public Boolean email_updates_event_i_author_organize;
		public Boolean integration_shared_drive_enabled ;
		public boolean integration_google_calendar_enabled;

		public String people_created_at;
		public String people_last_deactivated_at;

        public Boolean enable_org_level_onboarding;
		public Boolean has_simpplr_license;
		public String onboarding_email_frequency ;
		public Boolean has_read_all_onboarding_content ;
		public String user_id ;
		public Boolean has_profile_photo ;
		public String email;
	}
	
	public class SocialAnalytics{
		public Integer search_results_count;
		public String content_status;
	    public String page_name;
	    public String people_id;
	    public String org_id_people_id;
	    public String user;
	    public String search_results_summary;
	    public String origin;
	    public String page_url;
	    public String interaction;
	    public String org_id_site_id;
	    public String org_id_content_id;
	    public String people_profile;
	    public String file_id;
	    public String user_agent;
	    public String topic_id;
	    public String search_text;
	    public Boolean origin_mobile_browser;
	    public Boolean origin_mobile_app;
	    public Boolean origin_desktop_app;
	    public Boolean origin_native_mobile_app;
	    public String mailer;
		public String login_history_id;
		public String referer;		              
	    public String record_id;
	    public Date record_date;
	    public String record_date_time;
		public String utm_content;
		public String utm_term;
		public String page_group;
		public String page_analytics_category;
		public String utm_source;
		public String utm_medium;

	}
   public Class File {
	    public String id;
        public String org_id ;
		public Boolean allow_comments;
		public String author_id ;
		public String org_id_author_id ;
		public String content_document ;
		public String content_name;
		public String content_version ;
		public String description ;
		public Double downloads ;
		public Double duration ;
		public String external_Id;
		public String feed_comment;
		public String feed_item_id;
		public String fileInfo_last_updated_Datetime ;
		public String folder_id ;
		public String org_id_folder_id;
		public Boolean is_deleted;
		public Boolean is_title_image;
		public Double likes ;
		public String location;
		public String mime_type;
		public String name;
		public Double order;
		public String repository;
		public Double shares;
		public String content_id;
		public String org_id_content_id;
		public String site_id;
		public String org_id_site_id;
		public Double size;
		public Double subscribers;
		public String thumbnail_url	;
		public String title_image_type;
		public String title;
		public String video_provider;
		public Double views;
		public String sp_instance_id;

   }
   public class Folder{
		Public String id;
		Public String org_id;
		Public String box_collaboration_id;
		Public String drive_type;
		Public String efs_drive_id ;
		Public String efs_shared_folder_id;
		Public String efs_read_collaboration_id;
		Public String efs_read_write_collaboration_id ;
		Public String efs_search_collaboration_id;
		Public String external_folder_id;
		Public Boolean is_deleted;
		Public Boolean is_external_system_folder;
		Public Boolean is_hidden ;
		Public Boolean is_system_folder ;
		Public String linked_folder_owner ;
		Public String Name;
		Public String parent_folder;
		Public String path;
		Public String people_id;
		Public String org_id_people_id;
		Public String permissions;
		Public String site_id;
		Public String org_id_site_id;
		Public String type;
		Public String sp_instance_id;

   }
    public class SiteCount{
    	public String csvUrl{get;set;}
    	public SiteCountData data{get;set;}
    }
    
    public class SiteCountData{
    	public Integer publicSiteCount{get;set;}
    	public Integer privateSiteCount{get;set;}
    	public Integer unlistedSiteCount{get;set;}
		public Integer featuredSiteCount{get;set;}
    	public Boolean hasLowActivitySites{get;set;}
		public Integer siteManagerCount{get;set;}
		public Long newlyAddedSiteCount{get;set;}

    	public SiteCountData() {
    		publicSiteCount = 0;
    		privateSiteCount = 0;
    		unlistedSiteCount = 0;
			featuredSiteCount = 0;
			siteManagerCount = 0;
			newlyAddedSiteCount = 0;
    	}
    }
    
    public class PeoplePerformanceWrappper{
    	public String csvUrl;
		public long totalRecordsCount;
    	public List<PeoplePerformanceData> data;
    	
    	public peoplePerformanceWrappper(){
    		data = new List<PeoplePerformanceData>();
    	}
    }
    
    public class PeoplePerformanceData{
    	public String label{get;set;}
    	public integer value{get;set;}
    	public String url{get;set;}
    	public String id{get;set;}
    	public Boolean isActive{get;set;}
    	public String email{get;set;}
    	public String companyName{get;set;}
    	public String segment{get;set;}
    	public String location{get;set;}
    	public String division{get;set;}
    	public String department{get;set;}
    	public String city{get;set;}
    	public String state{get;set;}
    	public String country{get;set;}
		public String category{get;set;}
		/**
		* @description phone
		*/
		public String phone{get;set;}
		/**
		* @description job title
		*/
		public String title{get;set;}
		/**
		* @description site name
		*/
		public String siteName{get;set;}
		/**
		* @description audience role
		*/
		public String role{get;set;}
		/**
		* @description site role
		*/
		public String siteRole{get;set;}
    }
    
    public class ViewsOverTime{
		public long uniqueViews;
    	public String label{get;set;}
    	public String name{get;set;}
		public integer value{get;set;}
		public double percentageValue{get;set;}
    	public String url{get;set;}
    	public String id{get;set;}
		public long totalUsers{get;set;}
    	public Boolean isActive{get;set;}
    	public Integer totalViewCount{get;set;}
		public String status{get;set;}
		public String landingPage{get;set;}
		public Boolean hasAccess{get;set;}
    	//for site popularity
    	public Integer likes{get;set;}
    	public Integer posts{get;set;}
    	public Integer shares{get;set;}
    	public Integer replies{get;set;}
    	public Integer favorites{get;set;}
		public Integer views{get;set;}
		public Integer contentViews{get;set;}
		public Integer uniqueContentViews{get;set;}
    	//fir site publications
    	public Integer albums{get;set;}
    	public Integer events{get;set;}
    	public Integer pages{get;set;}
    	public Boolean canManage;
    	public String access{get;set;}
		public Integer popularityScore{get;set;}
		//for app page
		public String page{get;set;}
		public Integer uniqueViewsCount{get;set;}
		public Decimal uniqueViewsPercentage{get;set;}
		public Integer totalViewsCount{get;set;}
		public Decimal totalViewsPercentage{get;set;}
    }
    
    public class ViewsList{
    	public String csvUrl;
    	public List<ViewsOverTime> data;
    }
    
    public class SearchList{
    	public String csvUrl;
    	public SearchData data;
    	
    	public SearchList(){
    		data = new SearchData();
    	}
    }
    
    public class SearchData{
    	public List<ViewsOverTime> searchList;
    	public Integer searchTotal;
    	public List<ViewsOverTime> searchesOverTime;
    	public Integer totalCount;
    	
    	public SearchData(){
    		searchList = new List<ViewsOverTime>();
    		searchesOverTime = new List<ViewsOverTime>();
    	}
    }
    
    public class SiteWrapper{
    	public String csvUrl;
    	public SiteData data;
    }
    
    public class SiteData{
    	public Boolean hasLowActivitySites;
    	public List<ViewsOverTime> sites;
    }
    
    public class Engagement{
    	public String csvUrl{get;set;}
		public String trackingStartdate{get;set;}
    	public EngagementData data{get;set;}
    }
    
    public class EngagementData{
    	public List<ViewsOverTime> likes{get;set;}
    	public List<ViewsOverTime> comments{get;set;}
    	public List<ViewsOverTime> shares{get;set;}
    	public List<ViewsOverTime> replies{get;set;}
    	public List<ViewsOverTime> favorites{get;set;}
		public List<ViewsOverTime> popularityScore{get;set;}
		public List<ViewsOverTime> contentViews{get;set;}

		public List<ViewsOverTime> uniqueContentViews{get;set;}
     }
    
    public class ContentWrapper{
    	public String csvUrl;
    	public String csvUrlTopDepartments;
    	public String csvUrlTopLocations;
    	public ContentRelatedData data;
    }
    
    public class ContentRelatedData{
    	public Integer totalViewCount{get;set;}
    	public Integer uniqueViewCount{get;set;}
		public long uniqueViews{get;set;}
    	public List<ViewsOverTime> viewsOverTime{get;set;}
    	public List<ViewsOverTime> loginsOverTime{get;set;}
    	public List<Category> topDepartments{get;set;}
    	public List<Category> topLocations{get;set;}
    	public List<ViewsOverTime> views{get;set;}
		public long desktopViews{get;set;}
		public long desktopAppViews{get;set;}
    	public long mobileViews{get;set;}
    	public long mobileAppViews{get;set;}
		public Decimal loggedInPercentage{get;set;}
		public Integer desktopLogins{get;set;}
		public Integer mobileLogins{get;set;}
		public Integer mobileAppLogins{get;set;}
		public Decimal desktopPercentage{get;set;}
		public Decimal mobilePercentage{get;set;}
		public Decimal mobileAppPercentage{get;set;}
		public Integer contentViewCount{get;set;}
		public Integer pageViewCount{get;set;}
		public Decimal averageLoginsPerUser{get;set;}
		public Decimal averageContentViewsPerUser{get;set;}
		public Integer usersLoggedInCount{get;set;}
		public Integer totalUserCount{get;set;}
		public Integer totalCountForCSV{get;set;}
		public Integer contentPublished{get;set;}
		public Decimal totalUniqueUserCount{get;set;}
		public Integer usersWhoViewedContent {get;set;}
		public String contentId {get;set;}
		/**
		* @description uniqueViewsOverTime
		*/
		public List<ViewsOverTime> uniqueViewsOverTime{get;set;}
    	public ContentRelatedData(){
			views = new List<ViewsOverTime>();
    	}
    }
	
	public class Category{
		public String id{get;set;}
		public String labe{get;set;}
		public String name{get;set;}
		public Integer viewCount{get;set;}
	}

	public class GovernanceWrapper{
		public String csvUrl{get;set;}
		public List<LabelValueData> data{get;set;}
	}
	
	public class ContentPopular{
		public String csvUrl{get;set;}
		public List<ContentInformation> data{get;set;}
	}
	
	public class ContentViews{
		public String csvUrl{get;set;}
		public List<ContentInformation> data{get;set;}
	}
	
	public class ContentPublications{
		public String csvUrl{get;set;}
		public ContentInformation data{get;set;}
	}
	
    public class ContentInformation{
		public String id;
		public String siteId;
    	//for UI
    	public Integer pages{get;set;}
    	public Integer events{get;set;}
    	public Integer albums{get;set;}
    	public Integer blogPosts{get;set;}
    	public Integer averageContentAge{get;set;}
		public String status{get;set;}
    	
    	// for CSV
    	public Integer shares{get;set;}
    	public Integer views{get;set;}
    	public Integer replies{get;set;}
    	public Integer favorites{get;set;}
    	public Integer posts{get;set;}
    	public Integer likes{get;set;}
    	public String title{get;set;}
    	public String label{get;set;}
    	public String type{get;set;}
    	public String siteName{get;set;}
    	public String authorName{get;set;}
    	public String url{get;set;}
    	public Integer totalCount{get;set;}
    	public Integer value{get;set;}
    	public String publishedDate{get;set;}
		public String publishedLocalizedDate {set;get{
			return String.isBlank(publishedDate) ? '' : LocaleContext.getLocalisedDateCSV(publishedDate, UserContext.languageLocaleKey);
		}}
    	
    	public ContentInformation(){
    		this.pages = 0;
    		this.events = 0;
    		this.albums = 0;
    		this.blogPosts = 0;
    	}
    }
    
    public class MonthlyReport{
    	public String csvUrl{get;set;}
    	public List<MonthlyReportData> data{get;set;}
    }
    public class MonthlyReportData{
    	public String label{get;set;}
    	public Decimal usersLoggedInPercentage{get;set;}
    	public Decimal viewedContentPercentage{get;set;}
    	public Decimal averageViewsPerUserCount{get;set;}
    	public Integer usersLoggedInCount{get;set;}
    	public Integer viewedContentCount{get;set;}
    	public Integer postsAndRepliesCount{get;set;}
    	public Integer likesCount{get;set;}
    	public Integer sharesCount{get;set;}
		public Integer month{get;set;}
		public Integer year{get;set;}
    	public Decimal activeUsersLoggedInPercentage{get;set;}
    	public Integer activeUsersLoggedInCount{get;set;}
    }
    
    public class Newsletter{
    	public NewsletterData data{get;set;}
    }
    
    public class NewsletterData{
    	public Integer sentCount{get;set;}
    	public Integer recentlysentCount{get;set;}
    	public Integer totalRecipientCount{get;set;}
    	public Decimal averageOpenPercentage{get;set;}
    	public Decimal averageClickPercentage{get;set;}
    }

	public class ProfileCompletenessCsvWrapper {
		public String id{get;set;}
		public String name{get;set;}
		public String email{get;set;}
		public String companyName{get;set;}
		public String division{get;set;}
		public String department{get;set;}
		public String country{get;set;}
		public String state{get;set;}
		public String city{get;set;}
		public Boolean profileImage{get;set;}
		public Boolean phoneNumber{get;set;}
		public Boolean aboutText{get;set;}
		public Boolean birthday{get;set;}
    }

	public class ProfileCompletenessWrapper {
		public String csvUrl{get;set;}
		public ProfileCompleteness data{get;set;}
    }

	public class ProfileCompleteness {
		public Integer totalUserCount{get;set;}
		public List<ProfileCompletenessData> profileCompletenessList {get;set;}
    }

	public class ProfileCompletenessData {
		public String label{get;set;}
		public Integer value{get;set;}
    }

	public class KnowledgePageWrapper {
		public String csvUrl{get;set;}
		public List<LabelValueData> data{get;set;}
    }

	public class LabelValueData {
		public String label{get;set;}
		public Integer value{get;set;}
    }
    
    public class Campaign{
    	public CampaignData data{get;set;}
    }
    
    public class CampaignData{
    	public Integer totalCount{get;set;}
    	public Integer activeCount{get;set;}
    	public Integer facebookCount{get;set;}
    	public Integer twitterCount{get;set;}
    	public Integer linkedinCount{get;set;}
    }
    
	public class AdoptionCSVData {
		public List<AdoptionCSV> adoptionCSVList {get;set;}
		public List<String> fieldsList {get;set;}
    }

    public class AdoptionCSV{
		public List<String> fieldValues{get;set;}
		
    	public String label{get;set;}
    	public Integer value{get;set;}
    	public String name{get;set;}
    	public String email{get;set;}
    	public String companyName{get;set;}
    	public String segment{get;set;}
    	public String location{get;set;}
    	public String division{get;set;}
    	public String department{get;set;}
    	public String city{get;set;}
    	public String state{get;set;}
    	public String country{get;set;}
    }
    
    public class ContentViewsCSV{
    	public String id;
    	public String lastViewed{get;set;}
    	public String firstViewed{get;set;}
    	public Integer totalViews{get;set;}
    	public Integer uniqueViews{get;set;}
    	
    	public String name{get;set;}
    	public String email{get;set;}
    	public String companyName{get;set;}
    	public String segment{get;set;}
    	public String division{get;set;}
    	public String department{get;set;}
    	public String city{get;set;}
    	public String state{get;set;}
    	public String country{get;set;}
    	public String phone{get;set;}
    	public String location{get;set;}
    	public String jobTitle{get;set;}
    	public Integer likes{get;set;}
    	public Integer posts{get;set;}
    	public Integer shares{get;set;}
    	public Integer replies{get;set;}
    	public Integer favorites{get;set;}
		/**
		* @description audience role
		*/
    	public String role{get;set;}
		/**
		* @description siteName
		*/
    	public String siteName{get;set;}
		/**
		* @description siteRole
		*/
    	public String siteRole{get;set;}
    	public String status{get;set;}

    	
    }
    
    public class Mailer{
    	public String id;
    	public String record_id;
    	public String from_address;
    	public String from_address_id;
    	public String org_id_site_id;
    	public String name;
    	public Integer actual_recipient_count;
    	public Integer total_click_count;
    	public Integer unique_click_count;
    	public Integer open_count;
    	public String sent_date_time;
    }
    
	public class Carousel_Content {
		public String id;
		public String record_id;
		public String org_id_content_id;
		public String org_id_site_id;
		public String social_campaign;
		public String org_id_social_campaign;
		public Boolean is_deleted;
		public String item_type;
		public Integer item_order;
		public String site;
		public String segment;
		public String org_id_inserted_by_people_id;
		public String org_id_deleted_by_people_id;
		public String inserted_at;
		public String deleted_at;
		
	}
    public class SocialCampaign {
        public String id;
        public String record_id;
        public String record_date;
        public Boolean facebook_share_enabled;
        public Boolean linkedin_share_enabled;
        public Boolean twitter_share_enabled;
        public Integer total_facebook_share_count;
        public Integer total_linkedin_share_count;
        public Integer total_twitter_share_count;
        public String url;
        public Boolean is_active;
        public Boolean is_deleted;
    }

	public class Audience {
		public String id;
		public String org_id;
        public Double audience_member_count;
        public String audience_rule_json;
        public Boolean has_city_condition;
        public Boolean has_country_condition;
        public Boolean has_company_name_condition;
        public Boolean has_department_condition;
        public Boolean has_division_condition;
        public Boolean has_people_category_condition;
        public Boolean has_state_condition;
		public Boolean has_title_condition;
		public String org_id_segment_Id;
	}

	public class TilesConfig {
		public String id;
		public String org_id;
        public Boolean is_deleted;
        public Double layout_column;
        public String location;
        public Double tiles_order;
        public String org_id_people_id;
        public String org_id_segment_id;
        public String org_id_site_id;
        public String type;
        public String variant;
		public String created_at;
		public String updated_at;
	}

	public class SiteRole {
		public String id;
		public String org_id;
        public Boolean is_content_manager;
        public Boolean is_deleted;
        public Boolean is_manager;
        public Boolean is_member;
        public String site;
        public String people_id;
        public String unique_id1;
        public String user_id;
        public String org_id_people_id;
        public String org_id_site_id;
        public String site_id_people_id;
	}

	public class ContentAuditTrail {
		public String id;
		public String org_id;
		public String action_datetime;
		public String org_id_content_id;
		public String comment;
		public String org_id_action_by_people_id;
		public String org_id_dismiss_by_people_id;
		public String org_id_new_author_people_id;
		public String org_id_old_author_people_id;
		public String org_id_new_site_id;
		public String org_id_old_site_id;
		public String action;
	}

	public class App_Config {
		public String org_name;
		public Boolean ad_integration_enabled;
		public Boolean album;
		public Boolean allow_comments;
		public Boolean allow_file_share_with_public_link;
		public String allow_file_upload;
		public String allow_file_upload_site_managers;
		public Boolean allow_follow;
		public Boolean allow_only_influencers_to_create_blog;
		public Boolean allow_public_contribution;
		public String allow_site_add;
		public String allowed_features;
		public String app_dashboard_mode;
		public String app_download_info_url;
		public String app_home_dashboard_tile_ids;
		public String app_integrations_enabled;
		public String app_languages_enabled;
		public String app_name;
		public String app_page_title;
		public Boolean at_bookmark_enabled;
		public Boolean at_collaborationgroup_enabled;
		public Boolean at_collaborationgroupmember_enabled;
		public Boolean at_contentdocument_enabled;
		public Boolean at_contentdocumentlink_enabled;
		public Boolean at_contentversion_enabled;
		public Boolean at_feed_itemenabled;
		public Boolean at_feedcomment_enabled;
		public Boolean at_file_enabled;
		public Boolean at_folder_enabled;
		public Boolean at_like_enabled;
		public Boolean at_people_category_enabled;
		public Boolean at_people_enabled;
		public Boolean at_people_preference_enabled;
		public Boolean at_share_enabled;
		public Boolean at_simpplr_content_enabled;
		public Boolean at_simpplr_site_enabled;
		public Boolean at_simpplr_social_analytics_enabled;
		public Boolean at_user_enabled;
		public String at_user_trigger_type;
		public Boolean audit_trail_enabled;
		public Boolean auto_convert_chattergroup_to_site;
		public Boolean auto_provisioning_process_enabled;
		public Boolean aws_file_upload_enabled;
		public Boolean blog;
		public Boolean box_integration_enabled;
		public String box_user_id;
		public String branding_css_class;
		public String branding_css;
		public String branding_custom_font_css;
		public String branding_json;
		public String branding_logo;
		public Boolean calendar_app_enabled;
		public Boolean calendar_google_enabled;
		public Boolean calendar_office365_enabled;
		public Boolean calendar_outlook_web_enabled;
		public String carousel_layout;
		public Integer carousel_speed;
		public String chatter_email_off_profiles;
		public String communities_basepath;
		public Boolean communities_enabled;
		public Boolean content_history_enabled;
		public String custom_links_json;
		public Integer default_page_size;
		public Boolean embedly_enabled;
		public Boolean employee_advocacy_enabled;
		public Boolean event;
		public String expertise_controlled_by;
		public String expertise_create_controlled_by ;
		public Boolean external_analytics_enabled;
		public String external_analytics_url;
		public Boolean external_search_active;
		public Boolean external_search_app_connected;
		public String external_search_base_url;
		public String external_search_connected_by_people;
		public String external_search_enabled_by_people;
		public Boolean external_search_enabled;
		public Boolean external_search_file_connected;
		public String external_search_provider;
		public String favicons_folder;
		public Boolean feed_enabled;
		public String feed_mode;
		public Integer feed_page_size;
		public Integer feed_refresh_interval;
		public Boolean feed_rich_text_enabled;
		public Boolean feed_show_track_change_posts;
		public Boolean feedback_share_with_simpplr;
		public String feedback_to_emails;
		public String feed_placeholder;
		public String file_storage_setting_level;
		public String file_storage_source;
		public Boolean flow_external_search_enabled;
		public Boolean ga_demography_interests;
		public Boolean ga_enabled;
		public Boolean ga_enhanced_link_attribution;
		public Boolean go_to_salesforce_enabled;
		public String golive_chatter_email_setup;
		public Boolean home_carousel_enabled;
		public String interaction_control_level;
		public DateTime last_edited_datetime;
		public DateTime last_major_upgrade_datetime;
		public String layout;
		public String lightning_ux_tab_open_setting;
		public Integer login_timeout;
		public Boolean logout_custom_page_enabled;
		public String logout_custom_page_url;
		public Boolean microsoft_teams_integration_enabled;
		public String mobile_app_bundle_id_android;
		public String mobile_app_bundle_id_ios;
		public Boolean mobile_app_deeplinking_enabled;
		public Boolean mobile_promotion_enabled;
		public Boolean branded_app_distribution_enabled;
		public Boolean mute_content_post_in_sitefeed_enabled;
		public String newsletter_tracker_last_data_id;
		public Integer notification_refresh_interval;
		public Integer nps_survey_days_to_end;
		public Boolean nps_survey_enabled;
		public Boolean okta_enabled;
		public String okta_link;
		public String okta_people_name_format;
		public Boolean onelogin_enabled;
		public String onelogin_link;
		public Boolean org_chart_enabled;
		public String package_name;
		public String package_version;
		public String release_name;
		public Boolean page;
		public Boolean pds_about_me;
		public Boolean pds_birth_date;
		public Boolean pds_city;
		public Boolean pds_community_nickname;
		public Boolean pds_company_name;
		public Boolean pds_country;
		public Boolean pds_department;
		public Boolean pds_division;
		public Boolean pds_email;
		public Boolean pds_employee_number;
		public Boolean pds_enable_formatting;
		public Boolean pds_extension;
		public Boolean pds_fax;
		public Boolean pds_first_name;
		public Boolean pds_first_pull_sync_all_fields;
		public Boolean pds_joining_date;
		public Boolean pds_last_name;
		public Boolean pds_manager_id;
		public Integer pds_max_sync_attempts;
		public Boolean pds_middle_name;
		public Boolean pds_mobile_phone;
		public Boolean pds_phone;
		public Boolean pds_photo;
		public Boolean pds_postal_code;
		public Boolean pds_role;
		public String pds_source_application;
		public Boolean pds_state;
		public Boolean pds_street;
		public Boolean pds_language;
		public Boolean pds_locale;
		public Boolean pds_manager_identifier;
		public String pds_manager_unique_identifier_key;
		public Boolean pds_timezone;
		public String pds_unique_identifier;
		public Boolean pds_title;
		public Boolean pds_workday_enabled;
		public Boolean pds_ukg_pro_enabled;
		public Boolean people_category_enabled;
		public String people_catgeory_plural;
		public String people_catgeory_singular;
		public Boolean pp_about_me_display;
		public Boolean pp_about_me_editable;
		public Boolean pp_birthdate_display;
		public Boolean pp_birthdate_editable;
		public Boolean pp_category_display;
		public Boolean pp_category_editable;
		public Boolean pp_city_display;
		public Boolean pp_city_editable;
		public Boolean pp_company_name_display;
		public Boolean pp_company_name_editable;
		public Boolean pp_country_display;
		public Boolean pp_country_editable;
		public Boolean pp_department_display;
		public Boolean pp_department_editable;
		public Integer pp_departments_count;
		public Boolean pp_division_display;
		public Boolean pp_division_editable;
		public Integer pp_employees_count;
		public Boolean pp_extension_display;
		public Boolean pp_extension_editable;
		public Boolean pp_firstname_display;
		public Boolean pp_firstname_editable;
		public Boolean pp_joiningdate_display;
		public Boolean pp_joiningdate_editable;
		public Boolean pp_lastname_display;
		public Boolean pp_lastname_editable;
		public Integer pp_locations_count;
		public Boolean pp_manager_display;
		public Boolean pp_manager_editable;
		public Boolean pp_mobilephone_display;
		public Boolean pp_mobilephone_editable;
		public Boolean pp_phone_display;
		public Boolean pp_phone_editable;
		public Boolean pp_state_display;
		public Boolean pp_state_editable;
		public Boolean pp_street_display;
		public Boolean pp_street_editable;
		public Boolean pp_timezone_display;
		public Boolean pp_timezone_editable;
		public Boolean pp_title_display;
		public Boolean pp_title_editable;
		public String pp_user_custom_fields;
		public Boolean pp_video_display;
		public Boolean pp_video_editable;
		public String pp_video_provider;
		public String search_content_allowed_field;
		public String search_people_allowed_field;
		public Integer sed_daily_digest_size;
		public String sed_from_email;
		public Integer sed_weekly_digest_size;
		public Boolean segment_apps_links_enabled;
		public Boolean segment_branding_enabled;
		public String segment_column_name;
		public Boolean segment_enabled;
		public Boolean show_hidden_folders;
		public Boolean show_logo_on_mobile;
		public Boolean simpplr_desktop_notification_allowed;
		public Boolean simpplr_emails_allowed;
		public Boolean simpplr_mobile_notification_allowed;
		public Boolean simpplr_setup_complete;
		public Boolean simpplr_top_stories_emails_allowed;
		public Boolean site_carousel_enabled;
		public String site_dashboard_mode;
		public Boolean slack_integration_enabled;
		public Boolean slack_link_unfurl_enabled;
		public String social_campaign_policy_url;
		public Boolean social_tiles_enabled;
		public Boolean sp_integration_enabled;
		public String sso_custom_json;
		public String sso_provider;
		public String start_of_week;
		public Boolean use_connectapi_for_feed_update_check;
		public Boolean vbrick_enabled;
		public String validation_period;
		public Boolean content_governance_enabled;
		public Boolean enterprise_search_enabled;
		public String enterprise_search_provider;
		public String enterprise_search_url;
		public String record_created_at;
		public String record_updated_at;
		public boolean integration_box_enabled;
		public boolean integration_dropbox_enabled;
		public boolean integration_google_drive_enabled;
		public boolean integration_onedrive_enabled;
		public boolean integration_sharepoint_enabled;
		public boolean integration_microsoft_teams_enabled;
		public boolean integration_slack_enabled;
		public boolean integration_active_directory_enabled;
		public boolean integration_workday_enabled;
		public Boolean integration_ukg_pro_enabled;
		public boolean integration_okta_enabled;
		public boolean integration_onelogin_enabled;
		public boolean integration_servicenow_enabled;
		public boolean integration_facebook_enabled;
		public boolean integration_linkedin_enabled;
		public boolean integration_twitter_enabled;
		public boolean integration_servicenow_notification_enabled;
		public boolean integration_smartsearch_enabled;
		public boolean integration_vbrick_enabled;
		public boolean integration_google_analytics_enabled;
		public boolean integration_my_drive_enabled;
		public boolean integration_shared_drive_enabled ;
		public boolean integration_google_calendar_enabled;
		public Integer allowed_licenses; 
		public Integer used_licenses;
		public string package_expiration_date;
		public string package_installation_date;
		public String ukg_pro_department_key;
		public String ukg_pro_birthdate_key;
		public String ukg_pro_user_division_key;
		public String sp_upgrade_status;
		public boolean show_open_in_share_point;
		public String data_key;
		public String site_level_onboarding;
	}

	public class User_Provisioning_Config {
		public String id;
		public String org_id;
		public String org_name;
		public boolean about;
		public boolean birthdate;
		public String birthdate_field;
		public boolean city;
		public boolean company_name;
		public String company_name_field;
		public boolean country;
		public boolean create_new_users;
		public boolean deactive_user;
		public boolean department;
		public boolean division;
		public boolean employee_number;
		public boolean fax;
		public boolean federationid;
		public boolean firstname;
		public boolean joining_date;
		public String joining_date_field;
		public boolean language;
		public String language_type;
		public boolean lastname;
		public boolean locale;
		public String locale_type;
		public boolean manager;
		public String manager_unique_identifier;
		public boolean mobilephone;
		public boolean phone;
		public boolean phoneextension;
		public boolean postalcode;
		public boolean profile;
		public String profile_type;
		public String provisioning_source;
		public String query_filter;
		public boolean send_emails;
		public boolean state;
		public boolean street;
		public boolean timezone;
		public String timezonesidkey;
		public String unique_identifier;
		public boolean user_email;
		public String user_provisioning_config_name;
		public boolean user_title;
		public boolean username;
		public String username_suffix;
		public String created_at;
		public String updated_at;
	}

	public class Segment {
    	public String id;
    	public String segment_id;
    	public String org_id;
    	public String segment_name;
    	public String branding_json;
		public String branding_css_class;
		public String branding_css;
		public String branding_costom_font_css;
		public String branding_logo;
		public String favicons_folder;
		public String segment_attribute_value_json;
		public String branding_package_version;
		public String carousel_layout;
		public String custom_links_json;
		public String sso_provider;
		public String sso_custom_json;
    }

	public class SegmentSite {
    	public String id;
    	public String segment_id;
    	public String org_id;
		public String site_id;
		public Boolean is_featured;
		public String org_id_site_id;
		public String org_id_segment_id;
		public Integer item_order;
    }

	public class FeedItem {
		public String id;
		public Integer comment_count;
		public Boolean has_content;
		public Integer like_count;
		public String link_url; 
		public String feed_item_id; 
		public String title; 
		public String type;
		public String body; 
		public String feed_item_type; 
		public String feed_post_type; 
		public String group_mention_1; 
		public String group_mention_2; 
		public String group_mention_3; 
		public String group_mention_4; 
		public String group_mention_5; 
		public String group_mentions;
		public Boolean is_deleted;
		public String mention_1; 
		public String mention_2; 
		public String mention_3; 
		public String mention_4; 
		public String mention_5; 
		public String mentions;
		public String parent_type;  
		public String org_id_site_id;
		public String org_id_content_id;
		public String org_id_people_id;
		public String created_by_id;
		public String record_date;
		public String parent_id;  
	}

	public class FeedComment {
		public String id; 
		public String comment_body; 
		public String comment_type; 
		public String org_id_feed_item_id; 
		public String org_id_inserted_by_id;
		public String related_record_id; 
		public String feed_comment_id;
		public String group_mention_1; 
		public String group_mention_2; 
		public String group_mention_3; 
		public String group_mention_4; 
		public String group_mention_5; 
		public String group_mentions;
		public Boolean is_deleted;
		public String mention_1; 
		public String mention_2; 
		public String mention_3; 
		public String mention_4; 
		public String mention_5; 
		public String mentions; 
		public String status;
		public String created_by_id;
		public String feed_item_id;
		public String parent_id;
		public String org_id_created_by_id;
		public String record_date;
	}
	
	public class FeedLike {
		public String id; 
		public String org_id_feed_item_id;  
		public String org_id_inserted_by_id;  
		public String feed_entity_id; 
		public String feed_like_id; 
	}

	public class FeedPollChoice {
		public String id;   
		public String org_id_feed_item_id;  
		public Integer position;   
		public String choice_body;   
		public String feed_poll_choice_id; 
	}
	public class AnalyticsFile{		
		public String id;
		public String org_id;
		public String action ;
		public String context;
		public String file_extension;
		public String file_id ;
		public Boolean is_bookmarked;
		public Boolean is_new ;
		public String file_name;
		public String owner_id;
		public String provider;
		public String org_id_site_id;
		public String site_id;
		public Integer size;
		public String source;
		public String title;
		public String type;
		public String created_at;

	}

	public class ContentViewsByTypeWrapper{
		public String csvUrl{get;set;}
		public ContentViewsByTypeData data{get;set;}

	}
	
	public class ContentViewsByTypeData{
		public long pageViewCount{get;set;}
		public long eventViewCount{get;set;}
		public long albumViewCount{get;set;}
		public long blogPostViewCount{get;set;}
		public long averageViewsPerPageCount{get;set;}
		public long averageViewsPerEventCount{get;set;}
		public long averageViewsPerAlbumCount{get;set;}
		public long averageViewsPerBlogPostCount{get;set;}

	}

	public class ContentViewsCsvWrapper{	
		public long pageViews{get;set;}
		public long eventViews{get;set;}
		public long albumViews{get;set;}
		public long blogViews{get;set;}
		public String name{get;set;}
		public String email{get;set;}
		public String companyName{get;set;}
		public String segment{get;set;}
		public String division{get;set;}
		public String department{get;set;}
		public String city{get;set;}
		public String state{get;set;}
		public String country{get;set;}

	}

	public class ContentViewsOverTimeWrapper{
		public String csvUrl{get;set;}
		public ContentViewsOverTimeData data{get;set;}

	}

	public class ContentViewsOverTimeData{
		public List<ViewsOverTime> contentViews{get;set;}
		public long uniqueContentViews{get;set;}
		public long mobileAppContentViews{get;set;}
		public long mobileContentViews{get;set;}
		public long desktopContentViews{get;set;}
		public List<ViewsOverTime> uniqueContentViewsOverTime{get;set;}

		public ContentViewsOverTimeData(){
			this.contentViews = new List<ViewsOverTime>();
			this.uniqueContentViewsOverTime = new List<ViewsOverTime>();
		}

	}
	
	public class KnowledgePageWrapperCsv {
		public String name{get;set;}
		public String url{get;set;}
		public String type{get;set;}
    	public String siteName{get;set;}
    	public String authorName{get;set;}
    	public String publishedDate{get;set;}
		public Integer views{get;set;}
		public Boolean validationRequired{get;set;}
		public String lastValidatedDateTime{get;set;}
		public String validationExpired{get;set;}
		public String publishedLocalizedDate {set;get{
			return String.isBlank(publishedDate) ? '' : LocaleContext.getLocalisedDateCSV(publishedDate, UserContext.languageLocaleKey);
		}}
		public String lastValidatedLocalizedDate {set;get{
			return String.isBlank(lastValidatedDateTime) ? '' : LocaleContext.getLocalisedDateCSV(lastValidatedDateTime, UserContext.languageLocaleKey);
		}}
		public String validationExpiredLocalizedDate {set;get{
			return String.isBlank(validationExpired) ? '' : LocaleContext.getLocalisedDateCSV(validationExpired, UserContext.languageLocaleKey);
		}}

	}
	public class WeeklyContentReadershipData{

	 public String content ;
	 public String org_id;
	 public String org_id_content_id;
	 public Integer content_owner_subscription_count ;
	 public Integer site_subscription_count ;
	 public Integer content_readership;
	 public Integer week ;

	}

	public class LastSyncData{
		public String updatedAt;

	}

	public class ContentReferralSource{
		public String csvUrl;
		public List<ContentReferralSourceData> data;
		
		public ContentReferralSource(){
			data = new List<ContentReferralSourceData>();
		}
	}

	public class ContentReferralSourceData{
		public String label {get;set;}
		public String siteName {get;set;}
		public String contentTitle {get;set;}
		public Decimal contentItemsCount {get;set;}
		public Decimal totalViewsCount {get;set;}
		public Decimal referralsCount {get;set;}
		public Decimal referralsPercentage {get;set;}
		public Decimal referralsPerItemCount {get;set;}
		public Decimal referralsPerItemPercentage {get;set;}
	}
	public class Subscription {
		public String id;
		public String org_id;
		public String action_type;
		public String recipient;
		public String audience;
		public String org_id_audience_id;
		public String status;
		public String type;
	}
	public class SubscriptionEntity {
		public String id;
		public String org_id ;
		public String action_by;
		public String action_on;
		public String people;
		public String org_id_people_id;
		public String site;
		public String org_id_site_id;
		public Boolean processing_required;
		public String status;
		public String subscription;
		public String org_id_subscription_id;
	}
	public class app_default{
		public String id ;
		public String org_id ;
		public String layout ;
		public Boolean overwrite_batch_in_progress;
		public String people_id ;
		public String org_id_people_id ;
		public String segment_id ;
		public String org_id_segment_id ;
		public String type ;
		public String  top_stories_frequency;
		public String  site_analytics_frequency;
		public Boolean email_updates_content_sites_follow ;
		public Boolean email_private_site_membership_response;
		public Boolean email_shares_post_made ;
		public Boolean email_posts_to_me ;
		public String  email_notification_frequency ;
		public Boolean email_likes_shares_content_published;
		public Boolean email_likes_post_or_comment_made;
		public Boolean email_for_content_useful;
		public Boolean email_follows_me;
		public Boolean email_event_invite_more;
		public Boolean email_endorse_expertise;
		public Boolean email_content_submission_response;
		public Boolean email_content_marked_as_must_read;
		public Boolean email_comments_post_made;
		public Boolean email_comments_post_like;
		public Boolean email_comments_content_published;
		public Boolean email_comments_after_me;
		public Boolean email_alerts;
		public String  email_actionable_frequency;
		public String  digest_frequency;
		public String  allow_simpplr_emails;
		public Boolean email_knowledge_review;
		public Boolean email_knowledge_expired;
		public Boolean email_subscription_moderation;
		public Boolean sms_content_marked_as_must_read;
		public Boolean sms_alerts;
		public Boolean sms_content_promotion_message;
		public Boolean is_processing ;

		//native mobile
		public Boolean mobile_app_content_marked_as_must_read;
		public Boolean mobile_app_alerts;
		public Boolean mobile_app_updates_content_sites_follow;
		
		public Boolean mobile_app_follows_me;
		public Boolean mobile_app_endorse_expertise;
		
		public Boolean mobile_app_comments_post_made;
		public Boolean mobile_app_reply_after_me;
		public Boolean mobile_app_reply_liked_post;
		public Boolean mobile_app_likes_post_or_comment_made;
		public Boolean mobile_app_shares_my_post;
		public Boolean mobile_app_post_to_me;
		
		public Boolean mobile_app_comments_content_published;
		public Boolean mobile_app_likes_or_shares_content_published;
		public Boolean mobile_app_content_approval_rejection;
		
		public Boolean mobile_app_event_invite_more;
		public Boolean mobile_app_event_updates_attending;
		public Boolean mobile_app_event_updates_authored_organised;
		
		public Boolean mobile_app_private_site_membership_request;
		public Boolean mobile_app_content_submitted_for_moderation;
		
		public String  feed_setting;
		public String  feed_filter;
		public String  app_default_last_modified_date;
		public String  app_default_last_modified_by_url;
		public String  app_default_last_modified_by_name ;
		public Boolean is_apply_to_all_users ;
		public String tiles_config_json ;
		public String onboarding_email_frequency;

	}
	public class PeopleExpertise{

		public String id ;
		public String org_id ; 
	 	public String expertise_name;
		public String endorser_id;
		public Boolean is_self_endorsed ; 
		public Boolean is_self_hidden ;
	 	public String org_id_endorser_id ;
	 	public String people_id ;
	 	public String org_id_people_id;	 
	}

	public class Recommendation {
		public RecommendationData data;
		public Recommendation(){
			data = new RecommendationData();
		}
	
	}

	public class RecommendationData{
		public String recommendationGroup ;
		public List<RecommendationItem> recommendationItem;
		public List<RecommendationStats> recommendationStats;
		public RecommendationData(){
			recommendationItem = new List<RecommendationItem>();
			recommendationStats= new List<RecommendationStats>();
		}
	}
	public  class RecommendationItem{
		public String label;
		public Boolean value;
		public RecommendationItem(){
			
		}
		public RecommendationItem(String label, Boolean value){
			this.label = label;
			this.value = value;
		}
	}
	public  class RecommendationStats{
		public String label;
		public Double value;
		public RecommendationStats(){

		}
		public RecommendationStats(String label, Double value){
			this.label = label;
			this.value = value;
		}
	}
	public class CustomerSegmentAdoption{
    	public Decimal usersLoggedInPercentage ;
    	public Decimal contentPublishedPercentage ;
    	public Decimal usersWhoViewedContentPercentage ;
    	public Decimal averageContentViewsPerUserCount ;
    	public Decimal contributorsParticipantPercentage;    	
    }

	public class videoStats{
		public String csvUrl;
		public List<videoPopularity> data ;
		public videoStats(){
			data = new List<videoPopularity>();
		}
	}

	public  class videoPopularity{
		//For UI
		public String videoId {get;set;}
		public String label {get;set;}
		public Long views {get;set;}
		public String url {get;set;}
		//For Csv
		public String uploader {get;set;}
		public String uploadedAt {get;set;}
	}

	public class VideoAdoption{
		public String csvUrl;
		public videoAdoptionData data ;
		public VideoAdoption(){
			data = new videoAdoptionData();
		}
	}

	public class videoAdoptionData {

		public Long totalVideosPlayed {get;set;}
		public Long totalViewers {get;set;}
		public Long totalVideoViews {get;set;}
		public Double totalWatchTime {get;set;}
		Public Long totalPeople{get;set;}
	}

	public class videoAdoptionCsvStats{
		public List<videoAdoptionCsv> data ;
		public videoAdoptionCsvStats(){
			data = new List<videoAdoptionCsv>();
		}
	}


	public class videoAdoptionCsv{
		
		public String label{get;set;}
		public Long  views {get;set;}
		public Long viewers {get;set;}
		public Double watchTime {get;set;}
	}

	public class ContentEngagement{
    	public String csvUrl{get;set;}
		public String trackingStartdate{get;set;}
    	public ViewedEngagementData viewedData{get;set;}
    }

	public class ViewedEngagementData{
		public Long membersViewedCount {get;set;}
		public Long followersViewedCount {get;set;}
		public Long othersViewedCount {get;set;}
		public Long totalViewedCount {get;set;}
		public Long totalSiteMembers {get;set;}
		public Long totalSiteFollowers {get;set;}
		public List<ContentViewsCSV> data {get;set;}
    }
	/**
     * @description ContentInteraction Wrapper class
     */
	public class ContentInteraction {
		public String id;
		public String org_id;
        public String unique_key;
        public String people_id;
        public String content_id;
        public Double view_count;
		public String last_activity_date;
		public String last_modified_date;
		public String created_date;
        public Boolean is_deleted;
        public Boolean is_read;
        public Double scroll_depth;
        public String org_id_people_id;
	}
	/**
     * @description Likes Wrapper class
     */
	public class Likes {
		public String id;
		public String org_id;
        public String people_id;
        public String like_receiver;
        public Boolean is_deleted;
        public String file;
        public String feed_item_id;
        public String feed_item_comment_id;
        public String external_file_id;
        public String record_date;
        public String content_id;
		public String site;
        public String org_id_people_id;
		public String org_id_site_id;
		public String org_id_content_id;
		public String org_id_feed_item_id;
	}
	/**
     * @description Bookmark Wrapper class
     */
	public class Bookmark {
		public String id;
		public String org_id;
        public String people_id;
        public String bookmark_receiver;
        public Boolean is_deleted;
        public String file;
        public String feed_item_id;
        public String feed_item_comment_id;
        public String external_file_id;
        public String record_date;
        public String content_id;
		public String site;
        public String org_id_people_id;
		public String org_id_site_id;
		public String org_id_content_id;
		public String org_id_feed_item_id;
	}
	/**
     * @description Share Wrapper class
     */
	public class Share {
		public String id;
		public String org_id;
        public String people_id;
        public String share_receiver;
        public Boolean is_deleted;
        public String file;
        public String feed_item_id;
        public String feed_item_comment_id;
        public String external_file_id;
        public String record_date;
        public String content_id;
		public String site;
        public String org_id_people_id;
		public String org_id_site_id;
		public String org_id_content_id;
		public String org_id_feed_item_id;
	}
}