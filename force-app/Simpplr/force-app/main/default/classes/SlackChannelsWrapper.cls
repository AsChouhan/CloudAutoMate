public with sharing class SlackChannelsWrapper {
    public list<SlackChannels> channels;
	public SlackChannels channel;
    public list<SlackChannels> groups;
	public Boolean ok;
	public String error ;
	public ResponseMetaData response_metadata ;
    
    public class SlackChannels{
    	public String id{get;set;}
			public String name{get;set;}
			public Boolean is_channel;
			public Boolean is_archived;
			public Boolean is_group;
			public Boolean is_mpim;
			public Boolean is_im;
			
		
		public SlackChannels(){
			
		}
		public SlackChannels(String id, String name){
			this.id = id;
			this.name = name;
		}
    }
    
	public class ResponseMetaData {
		public String next_cursor;
	}

    public class SlackAuth{
    	public boolean ok{get;set;}
		public String access_token{get;set;}
    	public String url{get;set;}
    	public String team{get;set;}
		public String user{get;set;}
		public String team_name{get;set;}
		public String team_id{get;set;}
		public String enterprise_id{get;set;}
		public String user_id{get;set;}
		public String error{get;set;}
    }
    
    public class SlackAuthWrapper{
		public String access_token{get;set;}
		public IncomingWebhook incoming_webhook{get;set;}
	}
	
	public class IncomingWebhook{
		public String channel{get;set;}
		public String configuration_url{get;set;}
		public String channel_id{get;set;}
	}
}