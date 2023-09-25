public with sharing class MicrosoftTeamsService {
	
	public class MicrosoftTeamsWrapper {
		public String type {get;set;} 
		public String context {get;set;} 
		public String summary {get;set;} 
		public List<Object> sections {get;set;}
		public String siteFeedUrl {get;set;}
		
		public MicrosoftTeamsWrapper(){
			this.type = 'MessageCard';
			this.context = 'http://schema.org/extensions';
		}
	} 
	
	public class Activity {
		public String activityTitle {get;set;} 
		public String activityText {get;set;} 
	}
	public class ImageListWrapper {
		public List<ImageWrapper> images;
		public ImageListWrapper() {
			images = new List<ImageWrapper>();
		}
		
	}
	public class ImageWrapper {
		public String image;
	}
	
	public class FactListWrapper { 
		public List<FactWrapper> facts;
		public FactListWrapper() {
			facts = new List<FactWrapper>();
		}
	}
	public class FactWrapper {
		public String name;
		public String value;
	} 
}