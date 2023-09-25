public with sharing class FacebookService {
    
    private final String ERROR_NOT_PERFORMING_CAMPAIGN_FACEBOOK = 'Unable to perform action';
    
    public void postToFacebook (Social_Campaign__c campaignRec, String msgToShare) {
    	Social_Campaign_Share__c socialCampaignShare = new Social_Campaign_Share__c();
		socialCampaignShare.Network_Shared__c = IntegrationConstants.INTEGRATION_TYPE_FACEBOOK;
		socialCampaignShare.people__c = UserContext.peopleId;
		socialCampaignShare.Social_Campaign__c = campaignRec.Id;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().insertAsUser(socialCampaignShare, new List<Schema.SObjectField>{
							Social_Campaign_Share__c.Network_Shared__c,
							Social_Campaign_Share__c.people__c,
							Social_Campaign_Share__c.Social_Campaign__c
							});
    }
    
    public class FacebookResponseWrapper {
    	public String id {get;set;}
    } 
    
    public class PermissionContainerWrapper {
    	public List<PermissionWrapper> data {get;set;}
    }
    
    public class PermissionWrapper {
    	public String permission {get;set;}
      	public String status {get; set;}
    }
    
}