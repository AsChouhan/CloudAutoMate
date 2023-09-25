public with sharing class SchedulerBatchTopStories extends SimpplrScheduler {
	
    public override void execute(SchedulableContext SC) {    	
    	try{
    		String appConfigQuery = 'select Simpplr_Top_Stories_Emails_Allowed__c,Branding_Logo__c, Branding_JSON__c, App_Name__c from App_Config__c limit 1';
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
			
			logger.logDebug('Inside Execute : appConfig = ' + appConfig);
    		if(appConfig != null){
    			logger.logDebug('Inside Execute : appConfig.Simpplr_Top_Stories_Emails_Allowed__c = ' + appConfig.Simpplr_Top_Stories_Emails_Allowed__c);
    			if(appConfig.Simpplr_Top_Stories_Emails_Allowed__c){
	    			Integer frequency = 1;
		    		
		    		String queryDailyTopStoryDigest = 'Select Id, People__r.User__c,People__r.User__r.UserName, People__r.User__r.timezonesidkey, People__r.User__r.LanguageLocaleKey,'+
		    										' People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c,People__r.Last_Name__c, People__r.Segment__c, People__r.Segment__r.Branding_Logo__c, People__r.Segment__r.Branding_JSON__c, People__r.User_Hash__c  From People_Preference__c '+
		    										' where people__r.User__r.isActive=true and people__r.User__r.UserType=\'Standard\' And '+
		    										' Allow_Simpplr_Emails__c = true and Email_Content_Digest_Frequency__c = \'Daily\'';
		    		if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
		    			
		    			queryDailyTopStoryDigest = queryDailyTopStoryDigest + ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName)';
		    		}
		    		
		    		String brandingJsonString = appConfig.Branding_JSON__c;
					NotificationHelper.BrandingInfo brandingInfo = Utility.getBrandingInfoJson(brandingJsonString, appConfig.Branding_Logo__c);
		    		
		    		String simpplrDefaultLogoUrl = '';
		    		if(String.isBlank(appConfig.Branding_Logo__c)){
		    			simpplrDefaultLogoUrl = EmailTemplateService.simpplrDefaultLogoUrl;
		    		}
		    		
		    		BatchTopStories job = new BatchTopStories(appConfig, frequency, queryDailyTopStoryDigest, brandingInfo, simpplrDefaultLogoUrl);
					Database.executeBatch(job,size);
    			}
    		}  		
    	}catch(Exception ex){
    		logger.logError('Error in Batch Top Stories Digest Scheduler: ', ex);
    	}
		
    	try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }
}