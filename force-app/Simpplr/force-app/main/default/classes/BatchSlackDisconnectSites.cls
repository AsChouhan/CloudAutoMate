public with sharing class BatchSlackDisconnectSites implements Database.Batchable<sObject>{
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query ='SELECT Id, Slack_Access_Token__c, Slack_Channel_Name__c, Slack_Channel_Id__c, Slack_Url__c, Slack_Post_Enabled__c, Slack_Integration_Enabled__c, Slack_Comment_Enabled__c, Slack_Site_Manager__c, External_Apps_Site_Config_Json__c FROM Simpplr_Site__c where Slack_Site_Manager__c=\''+UserContext.peopleId+'\'';

		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
		List<Simpplr_Site__c> siteconfigList = (List<Simpplr_Site__c >)listOfsObject;
		siteconfigList[0].Slack_Access_Token__c = null;
		siteconfigList[0].Slack_Channel_Name__c = null;
		siteconfigList[0].Slack_Channel_Id__c = null;
		siteconfigList[0].Slack_Url__c = null;
		siteconfigList[0].Slack_Post_Enabled__c = false;
		siteconfigList[0].Slack_Integration_Enabled__c = false;
		siteconfigList[0].Slack_Comment_Enabled__c = false;
		siteconfigList[0].Slack_Site_Manager__c = null;
		if(siteconfigList[0].External_Apps_Site_Config_Json__c != null){
			ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
			externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteconfigList[0].External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
			externalAppsSiteConfig.SlackSiteConfig = null;
			siteconfigList[0].External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteconfigList), new List<Schema.SObjectField>{
			Simpplr_Site__c.Slack_Access_Token__c,
			Simpplr_Site__c.Slack_Channel_Name__c,
			Simpplr_Site__c.Slack_Channel_Id__c,
			Simpplr_Site__c.Slack_Url__c ,
			Simpplr_Site__c.Slack_Post_Enabled__c,
			Simpplr_Site__c.Slack_Integration_Enabled__c,
			Simpplr_Site__c.Slack_Comment_Enabled__c,
			Simpplr_Site__c.Slack_Site_Manager__c,
			Simpplr_Site__c.External_Apps_Site_Config_Json__c
		});
	}
    
    public void finish(Database.BatchableContext BC){
    	
	}
}