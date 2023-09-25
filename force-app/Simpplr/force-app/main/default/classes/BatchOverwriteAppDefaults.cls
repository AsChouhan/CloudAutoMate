public with sharing class BatchOverwriteAppDefaults implements Database.Batchable<sObject>, Database.stateful{
    String activity;
    Boolean runNextBatchInSequence;
	private Exception exceptionDetailsObj;
	String segmentId;
	
	public BatchOverwriteAppDefaults(String activity, Boolean runNextBatchInSequence, String segmentId){
    	this.activity = activity;
    	this.runNextBatchInSequence = runNextBatchInSequence;
    	this.segmentId = segmentId;
    	
    }
     
    public Database.QueryLocator start(Database.BatchableContext BC){
    	String query;
    	String packageName = SimpplrContext.packageName;
    	
    	if('DeleteOldTiles'.equalsIgnoreCase(activity)) {
    		query = 'SELECT Id FROM Tiles_Config__c Where people__c !=null And Location__c = \'Home Dashboard\' AND people__r.Segment__c =:segmentId';
		
    	}else if('createDefaultHomeTiles'.equalsIgnoreCase(activity)){
			query = 'Select id,user__c from People__c where User__r.UserType=\'Standard\' And User__r.isActive=true AND Segment__c =:segmentId ';
			query += ' and id in (select People__c from People_Preference__c where tiles_initialized__c=true) ';
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 	query = query + ' and user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName)';
			}
    	}else if('email_notifications'.equalsIgnoreCase(activity)){
	        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
	        }else{
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' ';
	        }    		
    	}else if('Default Feed'.equalsIgnoreCase(activity)){
	        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
	        }else{
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' ';
	        }    		
    	}else if('sms_notifications'.equalsIgnoreCase(activity)){
	        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
	        }else{
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' ';
	        }    		
    	}else if('Native Mobile Notifications'.equalsIgnoreCase(activity)){
	        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
	        }else{
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' ';
	        }    		
    	}else if('browser_notifications'.equalsIgnoreCase(activity)){
	        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
	        }else{
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' ';
	        }    		
    	}else if('summaries_and_digest'.equalsIgnoreCase(activity)){
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
	        }else{
	            query = 'Select id From People_Preference__c where User__r.IsActive=true and User__r.UserType=\'Standard\' ';
	        } 
		}
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
    	
    	try{
	    	if('DeleteOldTiles'.equalsIgnoreCase(activity)) {
	    		List<Tiles_Config__c > listOfTileObjects = (List<Tiles_Config__c >)listOfsObject;
				deleteOldTiles(listOfTileObjects);			
	    	}else if('createDefaultHomeTiles'.equalsIgnoreCase(activity)) {
	    		List<People__c > listOfPeople = (List<People__c >)listOfsObject;
				createDefaultHomeTiles(listOfPeople);

	    	}else if('email_notifications'.equalsIgnoreCase(activity)){
		        List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)listOfsObject;
				overrideEmailNotification(peoplePreferenceList);	
				
			}else if('Default Feed'.equalsIgnoreCase(activity)){
		        List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)listOfsObject;
				overrideFeedSettings(peoplePreferenceList);	
				
			}else if('sms_notifications'.equalsIgnoreCase(activity)){
		        List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)listOfsObject;
				overrideSMSSettings(peoplePreferenceList);	
				
			}else if('Native Mobile Notifications'.equalsIgnoreCase(activity)){
		        List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)listOfsObject;
				overrideNativeMobileSettings(peoplePreferenceList);	
				
			}else if('browser_notifications'.equalsIgnoreCase(activity)){
				List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)listOfsObject;
				overrideBrowserSettings(peoplePreferenceList);	
				
			}else if('summaries_and_digest'.equalsIgnoreCase(activity)){
				List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)listOfsObject;
	        	overrideSummariesAndDigestSettings(peoplePreferenceList);	
			}
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    
    public void finish(Database.BatchableContext BC){
    	
    		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchOverwriteAppDefaults', exceptionDetailsObj);
		}
		
    	if(runNextBatchInSequence) {
    		if('DeleteOldTiles'.equalsIgnoreCase(activity)) {
				BatchOverwriteAppDefaults job = new BatchOverwriteAppDefaults('createDefaultHomeTiles',true, segmentId);
				Database.executeBatch(job,100);
    		}else if('createDefaultHomeTiles'.equalsIgnoreCase(activity)){
    			updateIsProcessRunningFlag('home-default');
    		}
    	}else {
    		if('email_notifications'.equalsIgnoreCase(activity)){
    			updateIsProcessRunningFlag('email_notifications');	
    			
    		}else if('Default Feed'.equalsIgnoreCase(activity)){
    			updateIsProcessRunningFlag('home-feed');	
    		}else if('sms_notifications'.equalsIgnoreCase(activity)){
    			updateIsProcessRunningFlag('sms_notifications');	
    		}else if('Native Mobile Notifications'.equalsIgnoreCase(activity)){
    			updateIsProcessRunningFlag('native_mobile_notifications');	
    		}else if('browser_notifications'.equalsIgnoreCase(activity)){
				updateIsProcessRunningFlag('browser_notifications');	
			}else if('summaries_and_digest'.equalsIgnoreCase(activity)){
				updateIsProcessRunningFlag('summaries_and_digest');	
			}
    	}
    }
    
    private void deleteOldTiles(List<Tiles_Config__c > listOfTileObjects){
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().deleteAsUser(listOfTileObjects);
	}
	
	private void createDefaultHomeTiles(List<People__c > listOfPeople){
		List <App_Default__c> listOfDefaultObj = new List <App_Default__c>();
   		List <String> listOfHomeDefaultTileIds = new List <String>();
   		List<Tiles_Config__c> listOfHomeDefaultTiles = new List<Tiles_Config__c>();
   		
   		Map<String, Object> soqlParamMap = new Map<String, Object>();
   		soqlParamMap.put('soqlParam1', segmentId);
   		String query = 'Select id, Data__c, Type__c,Layout__c,OverwriteBatchInProgress__c From App_Default__c where Type__c=\'home-default\' and Segment__c =:soqlParam1 LIMIT 1';
   		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
   		listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   		
   		if(listOfDefaultObj.isEmpty() == false){
   			if(String.isNotBlank(listOfDefaultObj[0].Data__c)){
   				listOfHomeDefaultTileIds = listOfDefaultObj[0].Data__c.split(',');
   			}
   		}
   		
   		if(listOfHomeDefaultTileIds != null){
			Map<String, Object> tileSoqlParamMap = new Map<String, Object>();
			tileSoqlParamMap.put('soqlParam1', listOfHomeDefaultTileIds);
			String queryStr = 'SELECT Id, Name__c, Data__c, Layout_Column__c, Order__c, People__c, Site__c, Type__c, Variant__c FROM Tiles_Config__c ' +
				' where Id IN:soqlParam1 And Is_deleted__c = false ' +
				' order by Layout_Column__c,Order__c,CreatedDate desc';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			listOfHomeDefaultTiles = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(queryStr, tileSoqlParamMap);
			
   		}
		
		List<Tiles_Config__c> listOfUserTiles = new List<Tiles_Config__c>();
		
		for(People__c pplObj : listOfPeople){
			for(Tiles_Config__c configObj: listOfHomeDefaultTiles) {
				Tiles_Config__c newTilesConfig = new Tiles_Config__c();
				newTilesConfig.Data__c = configObj.Data__c;
				newTilesConfig.Name__c = configObj.Name__c;
				newTilesConfig.Type__c = configObj.Type__c;
				newTilesConfig.Variant__c = configObj.Variant__c;
				newTilesConfig.Location__c = 'Home Dashboard';
				newTilesConfig.Layout_Column__c = configObj.Layout_Column__c;
				newTilesConfig.Order__c = configObj.Order__c;
				newTilesConfig.People__c = pplObj.id;
				newTilesConfig.Variant_Type__c = configObj.Variant__c+ '_' +configObj.Type__c;
				listOfUserTiles.add(newTilesConfig);
   			}
		}
		if(!listOfUserTiles.isEmpty()){
			List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{Tiles_Config__c.Data__c,
																							Tiles_Config__c.Name__c,
																							Tiles_Config__c.Type__c,
																							Tiles_Config__c.Variant__c,
																							Tiles_Config__c.Layout_column__c,
																							Tiles_Config__c.Order__c,
																							Tiles_Config__c.Location__c,
																							Tiles_Config__c.People__c,
																							Tiles_Config__c.Variant_Type__c};
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfUserTiles, listOfColumnsToBeSet);
		}
		if(listOfDefaultObj.isEmpty() == false) { 
			List<People_Preference__c> listOfPplPrefToUpdate = new List<People_Preference__c>();
			String layoutToSet = listOfDefaultObj[0].Layout__c;
			List<People_Preference__c> listOfPeoplePreference = [Select Id, Layout__c, User__c, People__c 
																 From People_Preference__c 
																 Where User__r.isActive=true And Layout__c != :layoutToSet 
																 And People__r.Segment__c =:segmentId
																 And User__r.UserType='Standard'];
			if(!listOfPeoplePreference.isEmpty()){
				for(People_Preference__c pplPref : listOfPeoplePreference){
					People_Preference__c pplPrefObj = new People_Preference__c();
					pplPrefObj.id = pplPref.id;
					pplPrefObj.Layout__c = listOfDefaultObj[0].Layout__c;
					listOfPplPrefToUpdate.add(pplPrefObj);
				}

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(listOfPplPrefToUpdate), new List<Schema.SObjectField>{
																		People_Preference__c.Layout__c
																	});
			}
		}
	}
	
    private void overrideEmailNotification(List<People_Preference__c> peoplePreferenceList) {
		List<App_Default__c> appDefaultList = [Select Data__c from 
				App_Default__c where Type__c = 'email_notifications'];
		
		if (!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Data__c)) {
			ManageApplicationWrapper.EmailNotificationWrapper emailWrapper =  (ManageApplicationWrapper.EmailNotificationWrapper) JSON.deserialize(appDefaultList[0].Data__c, 
					ManageApplicationWrapper.EmailNotificationWrapper.class);
			List<People_Preference__c> peoplePreferenceToUpdateList = new List<People_Preference__c>();
			 
			for (People_Preference__c peoplePreference : peoplePreferenceList){
				People_Preference__c peoplePreferenceToUpdate = new People_Preference__c();
				
				peoplePreferenceToUpdate.Id = peoplePreference.Id;

				if ('Never'.equalsIgnoreCase(emailWrapper.emailNotificationFrequency)) {
					emailWrapper.emailNotificationFrequency  =  'none';
				}

				peoplePreferenceToUpdate.Email_Notification_Digest_Frequency__c  =  emailWrapper.emailNotificationFrequency;
				peoplePreferenceToUpdate.Allow_Simpplr_Emails__c  = 'none'.equalsIgnoreCase(emailWrapper.allowSimpplrEmails) ||
                        'disable'.equalsIgnoreCase(emailWrapper.allowSimpplrEmails) 
						? false : true;
						
				peoplePreferenceToUpdate.Email_Alerts__c = emailWrapper.emailAlerts == null ? false : emailWrapper.emailAlerts;
				peoplePreferenceToUpdate.Email_Follows_Me__c  = emailWrapper.emailFollowsMe == null ? false : emailWrapper.emailFollowsMe;
				peoplePreferenceToUpdate.Email_Endorses_Me__c  = emailWrapper.emailEndorseExpertise == null ? false : emailWrapper.emailEndorseExpertise;
				peoplePreferenceToUpdate.Email_Like_My_Post_Or_Comment__c  = emailWrapper.emailLikesPostOrCommentMade == null ? false : emailWrapper.emailLikesPostOrCommentMade;
				peoplePreferenceToUpdate.Email_Comments_On_My_Post__c  = emailWrapper.emailCommentsPostMade == null ? false : emailWrapper.emailCommentsPostMade; 
				peoplePreferenceToUpdate.Email_Comments_After_Me__c  = emailWrapper.emailCommentsAfterMe == null ? false : emailWrapper.emailCommentsAfterMe;
				peoplePreferenceToUpdate.Email_Comments_On_Post_I_Like__c  = emailWrapper.emailCommentsPostLike == null ? false : emailWrapper.emailCommentsPostLike; 
				peoplePreferenceToUpdate.Email_Posts_To_Me__c  = emailWrapper.emailPostsToMe == null ? false : emailWrapper.emailPostsToMe;
				peoplePreferenceToUpdate.Email_Shares_My_Post__c  = emailWrapper.emailSharesPostMade == null ? false : emailWrapper.emailSharesPostMade;
				peoplePreferenceToUpdate.Email_My_Content_Post__c  = emailWrapper.emailCommentsContentPublished == null ? false : emailWrapper.emailCommentsContentPublished; 
				peoplePreferenceToUpdate.Email_My_Content_Like_Or_Share__c  = emailWrapper.emailLikesSharesContentPublished == null ? false : emailWrapper.emailLikesSharesContentPublished;
				peoplePreferenceToUpdate.Email_Updates_Content_Sites_I_Follow__c = emailWrapper.emailUpdatesContentSitesFollow == null ? false : emailWrapper.emailUpdatesContentSitesFollow;
				peoplePreferenceToUpdate.Email_Event_Invite_More__c  = emailWrapper.emailEventInviteMore == null ? false : emailWrapper.emailEventInviteMore;
                
                peoplePreferenceToUpdate.Email_Content_Submission_Response__c = emailWrapper.emailContentSubmissionResponse == null ? false : emailWrapper.emailContentSubmissionResponse;
				peoplePreferenceToUpdate.Email_PrivateSiteMembership_Response__c  = emailWrapper.emailPrivateSiteMembershipResponse == null ? false : emailWrapper.emailPrivateSiteMembershipResponse;

				peoplePreferenceToUpdate.Email_Content_Useful__c  = emailWrapper.emailForContentUseful == null ? false : emailWrapper.emailForContentUseful;
				peoplePreferenceToUpdate.Email_Content_Marked_As_Must_Read__c = emailWrapper.emailContentMarkedAsMustRead == null ? false : emailWrapper.emailContentMarkedAsMustRead;
				
				peoplePreferenceToUpdate.Email_My_Content_Validation_Required__c = emailWrapper.emailKnowledgeReview == null ? true : emailWrapper.emailKnowledgeReview;
				peoplePreferenceToUpdate.Email_My_Content_Validation_Expired__c = emailWrapper.emailKnowledgeExpired == null ? true : emailWrapper.emailKnowledgeExpired;

				peoplePreferenceToUpdate.Email_Updates_Event_I_RSVP_Yes__c = emailWrapper.emailUpdatesEventIRsvpYes == null ? true : emailWrapper.emailUpdatesEventIRsvpYes;
				peoplePreferenceToUpdate.Email_Updates_Event_I_Author_Organize__c = emailWrapper.emailUpdatesEventIAuthorOrganize == null ? true : emailWrapper.emailUpdatesEventIAuthorOrganize;
                
                peoplePreferenceToUpdate.Receive_Content_Update_Notifications__c = emailWrapper.emailContentPromotionMessageForAppMgr == null ? true : emailWrapper.emailContentPromotionMessageForAppMgr;
                peoplePreferenceToUpdate.Receive_Content_Useful_Notifications__c = emailWrapper.emailForContentUsefulAppMgr == null ? true : emailWrapper.emailForContentUsefulAppMgr;
                peoplePreferenceToUpdate.Receive_Content_Moderation_Notifications__c = emailWrapper.emailSiteActionableForAppMgr == null ? true : emailWrapper.emailSiteActionableForAppMgr;
                peoplePreferenceToUpdate.Email_Subscription_Moderation__c = emailWrapper.emailSubscriptionModeration == null ? true : emailWrapper.emailSubscriptionModeration;

				peoplePreferenceToUpdate.Email_Private_Site_Membership_Requests__c = emailWrapper.emailPrivateSiteMembershipRequest == null ? false : emailWrapper.emailPrivateSiteMembershipRequest;
        		peoplePreferenceToUpdate.Email_Content_Submitted_For_Moderation__c = emailWrapper.emailContentSubmittedForModeration == null ? false : emailWrapper.emailContentSubmittedForModeration;
				peoplePreferenceToUpdate.Email_Subscription_Request__c = emailWrapper.emailSubscriptionRequest == null ? false : emailWrapper.emailSubscriptionRequest;
				peoplePreferenceToUpdate.Email_QnA_New_Question__c = emailWrapper.emailQnANewQuestion == null ? false : emailWrapper.emailQnANewQuestion;
				peoplePreferenceToUpdate.Email_QnA_New_Answer__c = emailWrapper.emailQnANewAnswer == null ? false : emailWrapper.emailQnANewAnswer;
				peoplePreferenceToUpdate.Email_QnA_Question_Mention__c = emailWrapper.emailQnAQuestionMention == null ? false : emailWrapper.emailQnAQuestionMention;
				peoplePreferenceToUpdate.Email_QnA_Answer_Mention__c = emailWrapper.emailQnAAnswerMention == null ? false : emailWrapper.emailQnAAnswerMention;
				peoplePreferenceToUpdate.Email_QnA_Answer_Approval__c = emailWrapper.emailQnAAnswerApproval == null ? false : emailWrapper.emailQnAAnswerApproval;
				peoplePreferenceToUpdate.Email_QnA_New_Answer_Approval__c = emailWrapper.emailQnANewApprovedAnswer == null ? false : emailWrapper.emailQnANewApprovedAnswer;
				peoplePreferenceToUpdate.Email_QnA_Duplicate_Question__c = emailWrapper.emailQnADuplicateQuestion == null ? false : emailWrapper.emailQnADuplicateQuestion;
				peoplePreferenceToUpdate.Email_QnA_Answer_Vote__c = emailWrapper.emailQnAVote == null ? false : emailWrapper.emailQnAVote;
				peoplePreferenceToUpdate.Email_QnA_New_Content_Question__c = emailWrapper.emailForContentQuestion == null ? false : emailWrapper.emailForContentQuestion;
				peoplePreferenceToUpdate.Email_QnA_New_Content_Answer__c = emailWrapper.emailForContentAnswer == null ? false : emailWrapper.emailForContentAnswer;

				peoplePreferenceToUpdate.Email_CnI_Campaign_End__c = emailWrapper.emailCnIEndCampaign == null ? false : emailWrapper.emailCnIEndCampaign;
				peoplePreferenceToUpdate.Email_CnI_Campaign_New__c = emailWrapper.emailCnINewCampaign == null ? false : emailWrapper.emailCnINewCampaign;
				peoplePreferenceToUpdate.Email_CnI_Initiative_End__c = emailWrapper.emailCnIInitiativeEnd == null ? false : emailWrapper.emailCnIInitiativeEnd;
				peoplePreferenceToUpdate.Email_CnI_Initiative_Start__c = emailWrapper.emailCnIInitiativeStart == null ? false : emailWrapper.emailCnIInitiativeStart;

					
				peoplePreferenceToUpdateList.add(peoplePreferenceToUpdate);
			}

    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(peoplePreferenceToUpdateList) , 
					new List<Schema.SObjectField>{
					People_Preference__c.Allow_Simpplr_Emails__c,
					People_Preference__c.Email_Alerts__c,
					People_Preference__c.Email_Notification_Digest_Frequency__c,
					People_Preference__c.Email_Follows_Me__c,
					People_Preference__c.Email_Endorses_Me__c,
					People_Preference__c.Email_Like_My_Post_Or_Comment__c,
					People_Preference__c.Email_Comments_On_My_Post__c,
					People_Preference__c.Email_Comments_After_Me__c,
					People_Preference__c.Email_Comments_On_Post_I_Like__c,
					People_Preference__c.Email_Posts_To_Me__c,
					People_Preference__c.Email_Shares_My_Post__c,
					People_Preference__c.Email_My_Content_Post__c,
					People_Preference__c.Email_My_Content_Like_Or_Share__c,
					People_Preference__c.Email_Updates_Content_Sites_I_Follow__c,
					People_Preference__c.Email_Event_Invite_More__c,
					People_Preference__c.Email_Content_Submission_Response__c,
					People_Preference__c.Email_PrivateSiteMembership_Response__c,
					People_Preference__c.Email_Content_Submitted_For_Moderation__c,
					People_Preference__c.Email_Content_Useful__c,
					People_Preference__c.Email_Private_Site_Membership_Requests__c,
					People_Preference__c.Email_Content_Marked_As_Must_Read__c,
					People_Preference__c.Email_My_Content_Validation_Required__c,
					People_Preference__c.Email_My_Content_Validation_Expired__c,
					People_Preference__c.Email_Updates_Event_I_RSVP_Yes__c,
					People_Preference__c.Email_Updates_Event_I_Author_Organize__c,
                    People_Preference__c.Receive_Content_Update_Notifications__c,
                    People_Preference__c.Receive_Content_Useful_Notifications__c,
                    People_Preference__c.Receive_Content_Moderation_Notifications__c,
					People_Preference__c.Email_Subscription_Moderation__c,
					People_Preference__c.Email_Subscription_Request__c,
					People_Preference__c.Email_QnA_New_Question__c,
					People_Preference__c.Email_QnA_New_Answer__c,
					People_Preference__c.Email_QnA_Question_Mention__c,
					People_Preference__c.Email_QnA_Answer_Mention__c,
					People_Preference__c.Email_QnA_Answer_Approval__c,
					People_Preference__c.Email_QnA_New_Answer_Approval__c,
					People_Preference__c.Email_QnA_Duplicate_Question__c,
					People_Preference__c.Email_QnA_Answer_Vote__c,
					People_Preference__c.Email_QnA_New_Content_Answer__c,
					People_Preference__c.Email_QnA_New_Content_Question__c,
					People_Preference__c.Email_CnI_Campaign_End__c,
					People_Preference__c.Email_CnI_Campaign_New__c,
					People_Preference__c.Email_CnI_Initiative_End__c,
					People_Preference__c.Email_CnI_Initiative_Start__c
                });
		} 	
    }
        		
	private void updateIsProcessRunningFlag(String appDefaultType){
   		Map<String, Object> soqlParamMap = new Map<String, Object>();
   		soqlParamMap.put('soqlParam1', appDefaultType);
   		soqlParamMap.put('soqlParam2', segmentId);
   		String query = 'Select id From App_Default__c where Type__c=:soqlParam1 AND Segment__c =:soqlParam2 LIMIT 1';
   		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
   		List <App_Default__c> listOfDefaultObj = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
   		if(!listOfDefaultObj.isEmpty()){
   			listOfDefaultObj[0].OverwriteBatchInProgress__c = false;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(listOfDefaultObj[0], 
				new List<Schema.SObjectField>{
					App_Default__c.OverwriteBatchInProgress__c
				}
			);
   			notifyAppMangrOnBatchRun();
   		}
	}
	
	private void notifyAppMangrOnBatchRun(){
		List <App_Default__c> appDefaultList = new List <App_Default__c>();
		List<App_Notification__c> notificationList = new list<App_Notification__c>();
		
		String guid= UserContext.id + '-' + System.currentTimeMillis();
		
		App_Notification__c notificationObj = new App_Notification__c();
		notificationObj.GUID__c = guid;
		notificationObj.Is_New__c = true;
		notificationObj.Is_Read__c = false;
		if('createDefaultHomeTiles'.equalsIgnoreCase(activity)){
			notificationObj.Category__c = 'Home_Default_Overwrite';
			notificationObj.Sub_Type__c = 'Home Default';
		} else if('email_notifications'.equalsIgnoreCase(activity)) {
			notificationObj.Category__c = 'Email_Notifcation_Overwrite';
			notificationObj.Sub_Type__c = 'Email Notifications Default';
		} else if('Default Feed'.equalsIgnoreCase(activity)){
			notificationObj.Category__c = 'Feed_Default_Overwrite';
			notificationObj.Sub_Type__c = 'Feed Default';
		} else if('sms_notifications'.equalsIgnoreCase(activity)){
			notificationObj.Category__c = 'SMS_Notification_Overwrite';
			notificationObj.Sub_Type__c = 'SMS Notifications Default';
		} else if('Native Mobile Notifications'.equalsIgnoreCase(activity)){
			notificationObj.Category__c = 'Native_Mobile_Notification_Overwrite';
			notificationObj.Sub_Type__c = 'Native Mobile Notifications Default';
		} else if('browser_notifications'.equalsIgnoreCase(activity)){
			notificationObj.Category__c = 'Browser_Notification_Overwrite';
			notificationObj.Sub_Type__c = 'Browser Notifications Default';
		}
		notificationObj.Type__c = 'Information';
		notificationObj.Status__c = 'Completion';
		notificationObj.Sent_To__c = UserContext.peopleId;
		notificationObj.Created_DateTime__c = DateTime.now();
		notificationList.add(notificationObj);
		
		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{App_Notification__c.GUID__c,
																						App_Notification__c.Is_New__c,
																						App_Notification__c.Is_Read__c,
																						App_Notification__c.Type__c,
																						App_Notification__c.Category__c,
																						App_Notification__c.Type__c,
																						App_Notification__c.Sub_Type__c,
																						App_Notification__c.Sent_To__c,
																						App_Notification__c.Created_DateTime__c};
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(notificationList, listOfColumnsToBeSet);
	}
	
	private void overrideFeedSettings(List<People_Preference__c> peoplePreferenceList){
		String query = 'Select Data__c from App_Default__c where Type__c = \'home-feed\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		if(!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Data__c)){
			ManageApplicationWrapper.DefaultFeedSettingsWrapper feedWrapper =  (ManageApplicationWrapper.DefaultFeedSettingsWrapper) JSON.deserialize(appDefaultList[0].Data__c, ManageApplicationWrapper.DefaultFeedSettingsWrapper.class);
			List<People_Preference__c> peoplePreferenceToUpdateList = new List<People_Preference__c>();
			
			for(People_Preference__c peoplePreference : peoplePreferenceList){
				People_Preference__c peoplePreferenceToUpdate = new People_Preference__c();
				
				peoplePreferenceToUpdate.Id = peoplePreference.Id;
				peoplePreferenceToUpdate.Feed_Type__c = feedWrapper.feedSetting;
				peoplePreferenceToUpdate.Feed_Sort_Order__c = feedWrapper.feedFilter;
				
				peoplePreferenceToUpdateList.add(peoplePreferenceToUpdate);
				
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(peoplePreferenceToUpdateList), new List<Schema.SObjectField>{
																	People_Preference__c.Feed_Type__c,
																	People_Preference__c.Feed_Sort_Order__c
																});

		}
	}

	private void overrideSMSSettings(List<People_Preference__c> peoplePreferenceList){
		String query = 'Select Data__c from App_Default__c where Type__c = \'sms_notifications\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		if(!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Data__c)){
			ManageApplicationWrapper.SMSNotificationWrapper sMSNotificationWrapper =  (ManageApplicationWrapper.SMSNotificationWrapper) JSON.deserialize(appDefaultList[0].Data__c, ManageApplicationWrapper.SMSNotificationWrapper.class);
			List<People_Preference__c> peoplePreferenceToUpdateList = new List<People_Preference__c>();
			
			for(People_Preference__c peoplePreference : peoplePreferenceList){
				People_Preference__c peoplePreferenceToUpdate = new People_Preference__c();
				
				peoplePreferenceToUpdate.Id = peoplePreference.Id;
				peoplePreferenceToUpdate.SMS_Alerts__c = sMSNotificationWrapper.smsAlerts;
				peoplePreferenceToUpdate.SMS_Must_Reads__c = sMSNotificationWrapper.smsContentMarkedAsMustRead;
				peoplePreferenceToUpdate.SMS_Content_Promotion_Message__c = sMSNotificationWrapper.smsContentPromotionMessage;
				
				peoplePreferenceToUpdateList.add(peoplePreferenceToUpdate);
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(peoplePreferenceToUpdateList) , 
				new List<Schema.SObjectField>{
					People_Preference__c.SMS_Alerts__c,
					People_Preference__c.SMS_Must_Reads__c,
					People_Preference__c.SMS_Content_Promotion_Message__c
				}
			);
		}
	}

	private void overrideNativeMobileSettings(List<People_Preference__c> peoplePreferenceList){
		String query = 'Select Data__c from App_Default__c where Type__c = \'native_mobile_notifications\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		if(!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Data__c)){
			ManageApplicationWrapper.MobileAppNotificationWrapper mobileAppNotificationWrapper =  (ManageApplicationWrapper.MobileAppNotificationWrapper) JSON.deserialize(appDefaultList[0].Data__c, ManageApplicationWrapper.MobileAppNotificationWrapper.class);
			List<People_Preference__c> peoplePreferenceToUpdateList = new List<People_Preference__c>();
			
			for(People_Preference__c peoplePreference : peoplePreferenceList){
				People_Preference__c peoplePreferenceToUpdate = new People_Preference__c();
				
				peoplePreferenceToUpdate.Id = peoplePreference.Id;
				
				peoplePreferenceToUpdate.Native_Mob_Content_Marked_As_Must_Read__c = mobileAppNotificationWrapper.mobileAppContentMarkedAsMustRead;
				peoplePreferenceToUpdate.Native_Mobile_Alerts__c = mobileAppNotificationWrapper.mobileAppAlerts;
				peoplePreferenceToUpdate.Native_Mob_Update_Content_Site_I_Follow__c = mobileAppNotificationWrapper.mobileAppUpdatesContentSitesFollow;
				
				
				peoplePreferenceToUpdate.Native_Mobile_Follows_Me__c = mobileAppNotificationWrapper.mobileAppFollowsMe;
				peoplePreferenceToUpdate.Native_Mob_Endorse_Expertise__c = mobileAppNotificationWrapper.mobileAppEndorseExpertise;

				peoplePreferenceToUpdate.Native_Mob_Comments_On_My_Post__c = mobileAppNotificationWrapper.mobileAppCommentsPostMade;
				peoplePreferenceToUpdate.Native_Mob_Reply_After_Me__c = mobileAppNotificationWrapper.mobileAppReplyAfterMe;
				peoplePreferenceToUpdate.Native_Mob_Replied_On_liked_Post__c = mobileAppNotificationWrapper.mobileAppReplyOnLikedPost;
				peoplePreferenceToUpdate.Native_Mob_Like_My_Post_Or_Comment__c = mobileAppNotificationWrapper.mobileAppLikesPostOrCommentMade;
				peoplePreferenceToUpdate.Native_Mob_Shares_My_Post__c = mobileAppNotificationWrapper.mobileAppSharesMyPost;
				peoplePreferenceToUpdate.Native_Mob_Posts_To_Me__c = mobileAppNotificationWrapper.mobileAppPostsToMe;
				
				peoplePreferenceToUpdate.Native_MobPrivateSiteMembership_Resp__c = mobileAppNotificationWrapper.mobileAppPrivateSiteMembershipResponse;

				peoplePreferenceToUpdate.Native_Mob_My_Content_Post__c = mobileAppNotificationWrapper.mobileAppCommentsContentPublished;
				peoplePreferenceToUpdate.Native_Mobile_My_Content_Like_Or_Share__c = mobileAppNotificationWrapper.mobileAppLikesOrSharesContentPublished;
				peoplePreferenceToUpdate.Native_Mob_Content_ApproveReject__c = mobileAppNotificationWrapper.mobileAppContentApprovalRejection;
				
				peoplePreferenceToUpdate.Native_Mobile_Event_Invite_More__c = mobileAppNotificationWrapper.mobileAppEventInviteMore;
				
				peoplePreferenceToUpdate.Native_Mob_Private_Site_Membership_Req__c = mobileAppNotificationWrapper.mobileAppPrivateSiteMembershipRequest;
				peoplePreferenceToUpdate.Native_Mob_Content_Submit_Moderation__c = mobileAppNotificationWrapper.mobileAppContentSubmittedForModeration;
				
				peoplePreferenceToUpdate.Native_Mobile_QnA_Question_Mention__c = mobileAppNotificationWrapper.mobileQnAQuestionMention;
				peoplePreferenceToUpdate.Native_Mobile_QnA_Answer_Mention__c = mobileAppNotificationWrapper.mobileQnAAnswerMention;
				peoplePreferenceToUpdate.Native_Mobile_QnA_Answer_Vote__c = mobileAppNotificationWrapper.mobileQnAVote;
				peoplePreferenceToUpdate.Native_Mobile_QnA_Answer_Approval__c = mobileAppNotificationWrapper.mobileQnAAnswerApproval;
				peoplePreferenceToUpdate.Native_Mobile_QnA_New_Answer__c = mobileAppNotificationWrapper.mobileQnANewAnswer;
				peoplePreferenceToUpdate.Native_Mobile_QnA_New_Answer_Approval__c = mobileAppNotificationWrapper.mobileQnANewApprovedAnswer;
				peoplePreferenceToUpdate.Native_Mobile_QnA_Duplicate_Question__c = mobileAppNotificationWrapper.mobileQnADuplicateQuestion;
				peoplePreferenceToUpdate.Native_Mobile_QnA_New_Question__c = mobileAppNotificationWrapper.mobileQnANewQuestion;
				peoplePreferenceToUpdate.Native_Mobile_QnA_New_Content_Question__c = mobileAppNotificationWrapper.mobileAppContentQuestion;
				peoplePreferenceToUpdate.Native_Mobile_QnA_New_Content_Answer__c = mobileAppNotificationWrapper.mobileAppContentAnswer;

				peoplePreferenceToUpdate.Native_Mobile_Surveys__c = mobileAppNotificationWrapper.mobileSurveys; 
				peoplePreferenceToUpdateList.add(peoplePreferenceToUpdate);
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(peoplePreferenceToUpdateList) , 
				new List<Schema.SObjectField>{
					People_Preference__c.Native_Mob_Content_Marked_As_Must_Read__c,
					People_Preference__c.Native_Mobile_Alerts__c,              
					People_Preference__c.Native_Mob_Update_Content_Site_I_Follow__c,          
					People_Preference__c.Native_Mobile_Follows_Me__c,
					People_Preference__c.Native_Mob_Endorse_Expertise__c,
					People_Preference__c.Native_Mob_Comments_On_My_Post__c,
					People_Preference__c.Native_Mob_Reply_After_Me__c,
					People_Preference__c.Native_Mob_Replied_On_liked_Post__c,
					People_Preference__c.Native_Mob_Like_My_Post_Or_Comment__c,
					People_Preference__c.Native_Mob_Shares_My_Post__c,
					People_Preference__c.Native_Mob_Posts_To_Me__c,
					People_Preference__c.Native_MobPrivateSiteMembership_Resp__c,
					People_Preference__c.Native_Mob_My_Content_Post__c,
					People_Preference__c.Native_Mobile_My_Content_Like_Or_Share__c,
					People_Preference__c.Native_Mob_Content_ApproveReject__c,
					People_Preference__c.Native_Mobile_Event_Invite_More__c,
					People_Preference__c.Native_Mob_Private_Site_Membership_Req__c,
					People_Preference__c.Native_Mob_Content_Submit_Moderation__c,
					People_Preference__c.Native_Mobile_QnA_Question_Mention__c,
					People_Preference__c.Native_Mobile_QnA_Answer_Mention__c,
					People_Preference__c.Native_Mobile_QnA_Answer_Vote__c,
					People_Preference__c.Native_Mobile_QnA_Answer_Approval__c,
					People_Preference__c.Native_Mobile_QnA_New_Answer__c,
					People_Preference__c.Native_Mobile_QnA_New_Answer_Approval__c,
					People_Preference__c.Native_Mobile_QnA_Duplicate_Question__c,
					People_Preference__c.Native_Mobile_QnA_New_Question__c,
					People_Preference__c.Native_Mobile_QnA_New_Content_Question__c,
					People_Preference__c.Native_Mobile_QnA_New_Content_Answer__c,
					People_Preference__c.Native_Mobile_Surveys__c
				}
			);
		}
	}

	private void overrideBrowserSettings(List<People_Preference__c> peoplePreferenceList){
		String query = 'Select Data__c from App_Default__c where Type__c = \'browser_notifications\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		if(!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Data__c)){
			ManageApplicationWrapper.BrowserNotificationWrapper browserNotificationWrapper =  (ManageApplicationWrapper.BrowserNotificationWrapper) JSON.deserialize(appDefaultList[0].Data__c, ManageApplicationWrapper.BrowserNotificationWrapper.class);
			List<People_Preference__c> peoplePreferenceToUpdateList = new List<People_Preference__c>();
			
			for(People_Preference__c peoplePreference : peoplePreferenceList){
				People_Preference__c peoplePreferenceToUpdate = new People_Preference__c();
				
				peoplePreferenceToUpdate.Id = peoplePreference.Id;
				//Org
				peoplePreferenceToUpdate.Browser_Must_Read__c = browserNotificationWrapper.browserMustRead;
				peoplePreferenceToUpdate.Browser_Alerts__c = browserNotificationWrapper.browserAlerts;
				peoplePreferenceToUpdate.Browser_Update_Content_Site_I_Follow__c = browserNotificationWrapper.browserUpdatesContentSitesFollow;
				//Profile
				peoplePreferenceToUpdate.Browser_Follows_Me__c = browserNotificationWrapper.browserFollowsMe;
				peoplePreferenceToUpdate.Browser_Endorse_Expertise__c = browserNotificationWrapper.browserEndorseExpertise;
				//Feed
				peoplePreferenceToUpdate.Browser_Comments_On_My_Post__c = browserNotificationWrapper.browserReplyOnMyPost;
				peoplePreferenceToUpdate.Browser_Comments_After_Me__c = browserNotificationWrapper.browserReplyAfterMe;
				peoplePreferenceToUpdate.Browser_Comments_On_Liked_Post__c = browserNotificationWrapper.browserReplyOnLikedPost;
				peoplePreferenceToUpdate.Browser_Like_My_Post_Or_Comment__c = browserNotificationWrapper.browserLikesMyPostOrReply;
				peoplePreferenceToUpdate.Browser_Shares_My_Post__c = browserNotificationWrapper.browserSharesMyPost;
				peoplePreferenceToUpdate.Browser_Posts_To_Me__c = browserNotificationWrapper.browserPostsToMe;
				//Site
				peoplePreferenceToUpdate.Browser_PrivateSiteMembership_Resp__c = browserNotificationWrapper.browserPrivateSiteMembershipResponse;
				//Content
				peoplePreferenceToUpdate.Browser_Content_Validation_Required__c = browserNotificationWrapper.browserContentValidationRequired;
				peoplePreferenceToUpdate.Browser_Content_Validation_Expired__c = browserNotificationWrapper.browserContentValidationExpired;
				peoplePreferenceToUpdate.Browser_Content_Comments_On_Published__c = browserNotificationWrapper.browserContentCommentsOnPublished;
				peoplePreferenceToUpdate.Browser_Content_LikesShares_On_Published__c = browserNotificationWrapper.browserContentLikesSharesOnPublished;
				peoplePreferenceToUpdate.Browser_Content_Approval_Rejection__c = browserNotificationWrapper.browserContentApprovalRejection;
				peoplePreferenceToUpdate.Browser_Content_Feedback__c = browserNotificationWrapper.browserContentFeedback;
				//Event
				peoplePreferenceToUpdate.Browser_Event_Invite__c = browserNotificationWrapper.browserEventInvite;
				peoplePreferenceToUpdate.Browser_Event_Updates_Attending__c = browserNotificationWrapper.browserEventUpdatesAttending;
				peoplePreferenceToUpdate.Browser_Event_Updates_Authored_Organized__c = browserNotificationWrapper.browserEventUpdatesAuthoredOrganized;
				//Sites Management
				peoplePreferenceToUpdate.Browser_Site_Membership_Request__c = browserNotificationWrapper.browserPrivateSiteMembershipRequest;
				peoplePreferenceToUpdate.Browser_Subscription_Submission__c = browserNotificationWrapper.browserSubscriptionRequest;
				peoplePreferenceToUpdate.Browser_Content_Submission__c = browserNotificationWrapper.browserContentSubmittedForModeration;
				//Question answer
				peoplePreferenceToUpdate.Browser_QnA_New_Question__c = browserNotificationWrapper.browserQnANewQuestion;
				peoplePreferenceToUpdate.Browser_QnA_New_Answer__c = browserNotificationWrapper.browserQnANewAnswer;
				peoplePreferenceToUpdate.Browser_QnA_Question_Mention__c = browserNotificationWrapper.browserQnAQuestionMention;
				peoplePreferenceToUpdate.Browser_QnA_Answer_Mention__c = browserNotificationWrapper.browserQnAAnswerMention;
				peoplePreferenceToUpdate.Browser_QnA_Answer_Approval__c = browserNotificationWrapper.browserQnAAnswerApproval;
				peoplePreferenceToUpdate.Browser_QnA_New_Answer_Approval__c = browserNotificationWrapper.browserQnANewApprovedAnswer;
				peoplePreferenceToUpdate.Browser_QnA_Duplicate_Question__c = browserNotificationWrapper.browserQnADuplicateQuestion;
				peoplePreferenceToUpdate.Browser_QnA_Answer_Vote__c = browserNotificationWrapper.browserQnAVote;
				peoplePreferenceToUpdate.Browser_QnA_New_Content_Question__c = browserNotificationWrapper.browserContentQuestion;
				peoplePreferenceToUpdate.Browser_QnA_New_Content_Answer__c = browserNotificationWrapper.browserContentAnswer;
				//Campaign Initiative
				peoplePreferenceToUpdate.Browser_CnI_Campaign_End__c = browserNotificationWrapper.browserCnIEndCampaign == null ? false : browserNotificationWrapper.browserCnIEndCampaign;
				peoplePreferenceToUpdate.Browser_CnI_Campaign_New__c = browserNotificationWrapper.browserCnINewCampaign == null ? false : browserNotificationWrapper.browserCnINewCampaign;
				peoplePreferenceToUpdate.Browser_CnI_Initiative_End__c = browserNotificationWrapper.browserCnIInitiativeEnd == null ? false : browserNotificationWrapper.browserCnIInitiativeEnd;
				peoplePreferenceToUpdate.Browser_CnI_Initiative_Start__c = browserNotificationWrapper.browserCnIInitiativeStart == null ? false : browserNotificationWrapper.browserCnIInitiativeStart;

				peoplePreferenceToUpdateList.add(peoplePreferenceToUpdate);
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(peoplePreferenceToUpdateList) , 
				new List<Schema.SObjectField>{
					People_Preference__c.Browser_Must_Read__c,
					People_Preference__c.Browser_Alerts__c,
					People_Preference__c.Browser_Update_Content_Site_I_Follow__c,
					People_Preference__c.Browser_Follows_Me__c,
					People_Preference__c.Browser_Endorse_Expertise__c,
					People_Preference__c.Browser_Comments_On_My_Post__c,
					People_Preference__c.Browser_Comments_After_Me__c,
					People_Preference__c.Browser_Comments_On_Liked_Post__c,
					People_Preference__c.Browser_Like_My_Post_Or_Comment__c,
					People_Preference__c.Browser_Shares_My_Post__c,
					People_Preference__c.Browser_Posts_To_Me__c,
					People_Preference__c.Browser_PrivateSiteMembership_Resp__c,
					People_Preference__c.Browser_Content_Validation_Required__c,
					People_Preference__c.Browser_Content_Validation_Expired__c,
					People_Preference__c.Browser_Content_Comments_On_Published__c,
					People_Preference__c.Browser_Content_LikesShares_On_Published__c,
					People_Preference__c.Browser_Content_Approval_Rejection__c,
					People_Preference__c.Browser_Content_Feedback__c,
					People_Preference__c.Browser_Event_Invite__c,
					People_Preference__c.Browser_Event_Updates_Attending__c,
					People_Preference__c.Browser_Event_Updates_Authored_Organized__c,
					People_Preference__c.Browser_Site_Membership_Request__c,
					People_Preference__c.Browser_Subscription_Submission__c,
					People_Preference__c.Browser_Content_Submission__c,
					People_Preference__c.Browser_QnA_New_Question__c,
					People_Preference__c.Browser_QnA_New_Answer__c,
					People_Preference__c.Browser_QnA_Question_Mention__c,
					People_Preference__c.Browser_QnA_Answer_Mention__c,
					People_Preference__c.Browser_QnA_Answer_Approval__c,
					People_Preference__c.Browser_QnA_New_Answer_Approval__c,
					People_Preference__c.Browser_QnA_Duplicate_Question__c,
					People_Preference__c.Browser_QnA_Answer_Vote__c,
					People_Preference__c.Browser_QnA_New_Content_Question__c,
					People_Preference__c.Browser_QnA_New_Content_Answer__c,
					People_Preference__c.Browser_CnI_Campaign_End__c,
					People_Preference__c.Browser_CnI_Campaign_New__c,
					People_Preference__c.Browser_CnI_Initiative_End__c,
					People_Preference__c.Browser_CnI_Initiative_Start__c
				}
			);
		}
	}

	private void overrideSummariesAndDigestSettings(List<People_Preference__c> peoplePreferenceList){
		String query = 'Select Data__c from App_Default__c where Type__c = \'summaries_and_digest\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		if(!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Data__c)){
			ManageApplicationWrapper.SummariesAndDigestWrapper SummariesNotificationWrapper =  (ManageApplicationWrapper.SummariesAndDigestWrapper) JSON.deserialize(appDefaultList[0].Data__c, ManageApplicationWrapper.SummariesAndDigestWrapper.class);
			List<People_Preference__c> peoplePreferenceToUpdateList = new List<People_Preference__c>();
			
			for(People_Preference__c peoplePreference : peoplePreferenceList){
				People_Preference__c peoplePreferenceToUpdate = new People_Preference__c();
				
				peoplePreferenceToUpdate.Id = peoplePreference.Id;
				peoplePreferenceToUpdate.Email_Digest_Frequency__c = String.isNotBlank(SummariesNotificationWrapper.digestFrequency) ? SummariesNotificationWrapper.digestFrequency : 'Daily';
				peoplePreferenceToUpdate.Email_Content_Digest_Frequency__c = String.isNotBlank(SummariesNotificationWrapper.topStoriesFrequency) ? SummariesNotificationWrapper.topStoriesFrequency : 'Daily';
				peoplePreferenceToUpdate.Email_Site_Analytics_Frequency__c = String.isNotBlank(SummariesNotificationWrapper.siteAnalyticsFrequency) ? SummariesNotificationWrapper.siteAnalyticsFrequency : 'monthly'; 
				peoplePreferenceToUpdate.Email_Onboarding_Frequency__c= String.isNotBlank(SummariesNotificationWrapper.emailOnboardingFrequency) ? SummariesNotificationWrapper.emailOnboardingFrequency : 'Never'; 
				
				peoplePreferenceToUpdateList.add(peoplePreferenceToUpdate);
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(peoplePreferenceToUpdateList) , 
				new List<Schema.SObjectField>{
					People_Preference__c.Email_Digest_Frequency__c,
					People_Preference__c.Email_Content_Digest_Frequency__c,
					People_Preference__c.Email_Site_Analytics_Frequency__c,
					People_Preference__c.Email_Onboarding_Frequency__c
				}
			);
		}
	}			

}