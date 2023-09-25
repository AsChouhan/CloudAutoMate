public with sharing class ManageSiteWrapper {

	public class SiteExternalAppWrapper {
		public String name;
        public Boolean isConnected;
		public String connectedAs;
        public Options options;
	}

	public class Options {
		public String sendFeed;
		public String channelId;
		public String channelName;
		public String channelUrl;
		public String webhookUrl;
		public MsTeamsSiteConfig msTeamsSiteConfig;
		public SlackSiteConfig slackSiteConfig;
	}

    public class SiteExternalAppsWrapper{
    	public String siteId;
    	public String slackUrl;
    	public String slackAccessToken;
    	public String slackSiteManager;
		public String slackSiteManagerName;
		public Boolean slackCommentEnabled;
    	public Boolean slackPostEnabled;
    	public String slackSendFeed;
		public Boolean slackIntegrationEnabled;
		public SlackChannelsWrapper.SlackChannels slackChannel;
		public String teamsSendFeed;
    	public String microsoftTeamsWebhookURL; 
    	public Boolean microsoftTeamsIntegrationEnabled;
    	public String microsoftTeamsSiteManager;	
    	public Boolean microsoftTeamsCommentEnabled;
		public ExternalAppsSiteConfig externalAppsSiteConfig;
    }
	 
	public class ExternalAppsSiteConfig {
		public MsTeamsSiteConfig msTeamsSiteConfig;
		public SlackSiteConfig slackSiteConfig;

	}

	public class MsTeamsSiteConfig{
		public String microsoftTeamsConnectedAs;
		public String msTeamsConnectedUserId;
		public String msTeamsChannelId;
		public String msTeamsChannelName;
		public String msTeamsTeamId;
		public String msTeamsTeamName;
		public String webUrl;
		public List<String> msTeamsSiteFeedOptions;
	}

	public class SlackSiteConfig{
		public String slackConnectedAs;
		public String slackConnectedUserId;
		public String slackChannelId;
		public String slackChannelName;
		public String slackWebUrl;
		public List<String> slackSiteFeedOptions;
	}
}