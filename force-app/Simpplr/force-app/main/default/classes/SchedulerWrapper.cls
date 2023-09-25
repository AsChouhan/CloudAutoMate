public with sharing class SchedulerWrapper {
	public class PaginationWrapper {
		public String nextPageToken;
    	public List<ApexClassWrapper> listOfItems ;
    	public PaginationWrapper() { 
    		listOfItems=new List<ApexClassWrapper>();
    	}
	}
	public class ApexClassWrapper{
		public String id {get;set;}
		public String name{get;set;}
		public String description{get;set;}
		public Integer size{get;set;}
		public boolean isRunning{get;set;}
		public Boolean isScheduled {get;set;}
		public String jsonText{get;set;}
		public String batchName {get;set;}
		public String nextRunAt {get;set;}
		public String lastRunAt {get;set;}   
		public String cronExp {get;set;}
		public Boolean canOperate {get;set;}
	}
}