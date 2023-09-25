public with sharing class ApprovalHistoryService {
    

    public static List<ModerationHistoryWrapper> getModerationHistory (String contentId, Integer size, 
			Integer nextPageToken) { 
    	logger.logDebug('ApprovalHistoryService.getModerationHistory()----contentId----'+contentId);
    	logger.logDebug('ApprovalHistoryService.getModerationHistory()----size----'+size);
	    ModerationHistoryWrapper modHistoryWrapObj;
		List<ModerationHistoryWrapper> moderationHistoryList = new List<ModerationHistoryWrapper>();
		
		List<String> actionsToIgnore = new List<String>{'Created', 'Draft Created', 'Updated', 'Draft Updated','Site Onboarding Enabled','Org Onboarding Enabled','Site Onboarding Disabled','Org Onboarding Disabled','Updated To Site Onboarding','Updated To Org Onboarding'};

		String query = 'SELECT id, Content__c, Action_DateTime__c, Comment__c, Old_Author__c,'+ 
				' New_Author__c, Action_By__c, Old_Site__c, New_Site__c, Action__c,'+ 
				' Action_By__r.Full_Name__c, Action_By__r.User__r.smallPhotoUrl, New_Author__r.Full_Name__c, ' + 
				' New_Author__r.User__r.SmallPhotoUrl, Old_site__r.name, New_site__r.name' + 
				' FROM Content_Audit_Trail__c WHERE content__c=:contentId ' + 
				' AND Action__c != :actionsToIgnore' + 
				' order by Action_DateTime__c desc, createdDate desc limit:size offset:nextPageToken';
		List<Content_Audit_Trail__c> listOfContentAuditTrail = Database.query(query);
  
		for (Content_Audit_Trail__c contAuditTrailObj : listOfContentAuditTrail) {
			modHistoryWrapObj = new ModerationHistoryWrapper();
			modHistoryWrapObj.moderationHistoryId = contAuditTrailObj.id;
			modHistoryWrapObj.createdAt = Utility.dateTimeToMomentJSDateTime(contAuditTrailObj.Action_DateTime__c);
			ModerationHistoryUser userObj = new ModerationHistoryUser();
			userObj.id = contAuditTrailObj.Action_By__c;
			userObj.name = contAuditTrailObj.Action_By__r.Full_Name__c;
			userObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contAuditTrailObj.Action_By__c;
			userObj.img = Utility.getProfilePhotoURL(contAuditTrailObj.Action_By__r.User__r.SmallPhotoUrl);
			modHistoryWrapObj.user = userObj;	
			modHistoryWrapObj.action = contAuditTrailObj.Action__c;		    
			
			if ('Author Changed'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				ModerationHistoryUser userOwnerObj = new ModerationHistoryUser();
				userOwnerObj.id = contAuditTrailObj.New_Author__c; //New Aut 
				userOwnerObj.name = contAuditTrailObj.New_Author__r.Full_Name__c;
				userOwnerObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contAuditTrailObj.New_Author__c;
				userOwnerObj.img = Utility.getProfilePhotoURL(contAuditTrailObj.New_Author__r.User__r.SmallPhotoUrl);					
				modHistoryWrapObj.subjectUser = userOwnerObj;	               

			} else if ('Rejected'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				modHistoryWrapObj.reason = contAuditTrailObj.Comment__c;

			} else if ('Site Changed'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				modHistoryWrapObj.fromSite = new ModerationSiteWrapper();
				modHistoryWrapObj.fromSite.id = contAuditTrailObj.Old_site__c;
				modHistoryWrapObj.fromSite.name = contAuditTrailObj.Old_site__r.name;
				modHistoryWrapObj.fromSite.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contAuditTrailObj.Old_Site__c;

				modHistoryWrapObj.toSite = new ModerationSiteWrapper();
				modHistoryWrapObj.toSite.id = contAuditTrailObj.New_site__c;
				modHistoryWrapObj.toSite.name = contAuditTrailObj.New_site__r.name;
				modHistoryWrapObj.toSite.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contAuditTrailObj.New_Site__c;
			}

			moderationHistoryList.add(modHistoryWrapObj);
		}
        return moderationHistoryList;
    }

	public static List<OnboardingHistoryWrapper> getOnboardingHistory (String contentId, Integer size, 
			Integer nextPageToken) { 
    	logger.logDebug('ApprovalHistoryService.getOnboardingHistory()----contentId----'+contentId);
    	logger.logDebug('ApprovalHistoryService.getOnboardingHistory()----size----'+size);
	    OnboardingHistoryWrapper onboardHistoryWrapObj;
		List<OnboardingHistoryWrapper> onboardingHistoryList = new List<OnboardingHistoryWrapper>();
		List<String> actions = new List<String>{'Site Onboarding Enabled', 'Org Onboarding Enabled', 'Updated To Site Onboarding','Updated To Org Onboarding', 'Site Onboarding Disabled','Org Onboarding Disabled'};

		String query = 'SELECT id, Content__c,Content__r.Content_Onboarding_Status__c,'+
				' Action_DateTime__c, Comment__c, Old_Author__c,'+ 
				' New_Author__c, Action_By__c, Old_Site__c, New_Site__c, Action__c,'+ 
				' Action_By__r.Full_Name__c, Action_By__r.User__r.smallPhotoUrl, New_Author__r.Full_Name__c, ' + 
				' New_Author__r.User__r.SmallPhotoUrl, Old_site__r.name, New_site__r.name' + 
				' FROM Content_Audit_Trail__c WHERE content__c=:contentId ' + 
				' AND Action__c IN :actions' +
				' order by Action_DateTime__c desc, createdDate desc limit:size offset:nextPageToken';
		List<Content_Audit_Trail__c> listOfContentAuditTrail = Database.query(query);
  
		for (Content_Audit_Trail__c contAuditTrailObj : listOfContentAuditTrail) {
			onboardHistoryWrapObj = new OnboardingHistoryWrapper();
			onboardHistoryWrapObj.onboardingHistoryId = contAuditTrailObj.id;
			onboardHistoryWrapObj.createdAt = Utility.dateTimeToMomentJSDateTime(contAuditTrailObj.Action_DateTime__c);
			OnboardingHistoryUser userObj = new OnboardingHistoryUser();
			userObj.id = contAuditTrailObj.Action_By__c;
			userObj.name = contAuditTrailObj.Action_By__r.Full_Name__c;
			userObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contAuditTrailObj.Action_By__c;
			userObj.img = Utility.getProfilePhotoURL(contAuditTrailObj.Action_By__r.User__r.SmallPhotoUrl);
			onboardHistoryWrapObj.user = userObj;
			
			if('Site Onboarding Enabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)
			|| 'Site Onboarding Disabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				onboardHistoryWrapObj.type=	'site';
			} else if('Org Onboarding Enabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)
			|| 'Org Onboarding Disabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				onboardHistoryWrapObj.type=	'org';
			} else if('Updated To Org Onboarding'.equalsIgnoreCase(contAuditTrailObj.Action__c)){
			 	onboardHistoryWrapObj.type=	'org';
			}else if('Updated To Site Onboarding'.equalsIgnoreCase(contAuditTrailObj.Action__c)){
				onboardHistoryWrapObj.type=	'site';
		   }

			if('Site Onboarding Enabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)
			|| 'Org Onboarding Enabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				onboardHistoryWrapObj.action = 'added';
			} else if ('Updated To Org Onboarding'.equalsIgnoreCase(contAuditTrailObj.Action__c)
			||'Updated To Site Onboarding'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				onboardHistoryWrapObj.action = 'updated';
			} else if ('Site Onboarding Disabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)
			||'Org Onboarding Disabled'.equalsIgnoreCase(contAuditTrailObj.Action__c)) {
				onboardHistoryWrapObj.action = 'removed';
			}
			onboardingHistoryList.add(onboardHistoryWrapObj);
		}
        return onboardingHistoryList;
    }
    
     public class ModerationHistoryWrapper {
     	public String moderationHistoryId {get;set;}
     	public String createdAt {get;set;}
     	public ModerationHistoryUser user {get;set;}
     	public ModerationHistoryUser subjectUser {get;set;}
     	public String action {get;set;}
     	public String reason {get;set;}
		public ModerationSiteWrapper fromSite;
		public ModerationSiteWrapper toSite; 
    }

	public class ModerationSiteWrapper {
		public String name;
		public String id; 
		public STring url; 
	}
    
    public class ModerationHistoryUser {
    	public String id {get;set;}
    	public String name {get;set;}
    	public String url {get;set;}
    	public String img {get;set;}
    }

	public class OnboardingHistoryWrapper {
		public String onboardingHistoryId {get;set;}
		public String createdAt {get;set;}
		public OnboardingHistoryUser user {get;set;}
		public String action {get;set;}
		public String type {get;set;}
   }

   	public class OnboardingHistoryUser {
		public String id {get;set;}
		public String name {get;set;}
		public String url {get;set;}
		public String img {get;set;}
	}
}