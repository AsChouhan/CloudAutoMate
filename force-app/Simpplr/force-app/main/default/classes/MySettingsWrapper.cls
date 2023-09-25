public with sharing class MySettingsWrapper {
	public class ProfileWrapper {
		public String peopleId;
		public String firstName;
		public Boolean firstNameEditable;
		public String lastName;
		public String name;
		public Boolean lastNameEditable;
		public String title;
		public String location;
		public Boolean titleEditable;
		public String language;
		public String department;
		public Boolean departmentEditable;
		public String manager;
		public String managerName;
		public String managerImg;
		public String managerJson ;
		public ManagerWrapper managerDetails;
		public Boolean managerEditable;
		public String peopleCategoryId;
		public String peopleCategoryName;
		public Boolean peopleCategoryEditable;
		public String aboutMe;
		public Boolean aboutMeEditable;
		public String phone;
		public Boolean phoneEditable;
		public String extension;
		public Boolean extensionEditable;
		public String mobile;
		public Boolean mobileEditable;
		public String city;
		public Boolean cityEditable;
		public String street;
		public Boolean streetEditable;
		public String state;
		public Boolean stateEditable;
		public String country;
		public Boolean countryEditable;
		public String timeZone;
		public Boolean timeZoneEditable;
		public String simpplrLanguageLocaleKey;
		public String salesforceLanguageLocaleKey;
		public Boolean languageEditable;
		public List<FilterAttributeWrapper> timeZoneFilter;
		public String url ;
		public String img ;
		public String joiningDate ;
		public Boolean birthDateEditable ;
		public Boolean joiningDateEditable ;
		public String birthdayDay;
		public String birthdayMonth;
		public String birthdayMonthName;
		public String division;
		public Boolean divisionEditable;
		public String companyName;
		public Boolean companyNameEditable;
		
		public String video;
		public Boolean videoEditable;
		public String zoomId;
		public Boolean zoomEditable;
		public String skypeId;
		public Boolean skypeEditable;
		
		public Boolean isZoomEnabled;
		public Boolean isSkypeEnabled;
		
		public Boolean isTitleEnabled;
	    public Boolean isBirthdayEnabled;
	    public Boolean isHireDateEnabled;
	    public Boolean isAboutEnabled;
	    public Boolean isManagerEnabled;
	    public Boolean isDepartmentEnabled;
	    public Boolean isCityEnabled;
	    public Boolean isStateEnabled;
	    public Boolean isCountryEnabled;
	    public Boolean isStreetEnabled;
	    public Boolean isPhoneEnabled;
	    public Boolean isExtensionEnabled;
	    public Boolean isMobilePhoneEnabled;
	    public Boolean isTimeZoneEnabled;
		public Boolean isLanguageEnabled;
	    public Boolean isCategoryEnabled;
	    public Boolean customUserFieldsEditable;
		public Boolean isDivisionEnabled;
		public Boolean isCompanyNameEnabled;
	    public List<CustomUserFields> customUserFieldList;

		public String timezoneName;
		public String timezoneIso;
		public Integer timezoneOffset;
    	
		public ProfileWrapper(){
			timeZoneFilter = new List<FilterAttributeWrapper>();
			
		}
		
	}
	
	public class ManagerWrapper {
		public String id;
		public String name;
		public String img ;
	}
    
	public class FeedWrapper{
		public String profileId;
		public String feedVisibility;
	}
	
	public class EmailNotificationWrapper {
		public String peopleId;
		public String allowSimpplrEmails;

		//Org
		public boolean emailContentMarkedAsMustRead;
		public boolean emailAlerts;
		public Boolean emailUpdatesContentSitesFollow;

		//Profile and Expertise
		public boolean emailFollowsMe;
		public boolean emailEndorseExpertise;

		//Feed
		public Boolean emailCommentsPostMade;
		public Boolean emailCommentsAfterMe;
		public Boolean emailCommentsPostLike;
		public Boolean emailLikesPostOrCommentMade;
		public Boolean emailSharesPostMade;
		public Boolean emailPostsToMe;

		//Sites
		public Boolean emailPrivateSiteMembershipResponse;

		//Content
		public Boolean emailKnowledgeReview;
		public Boolean emailKnowledgeExpired;
		public Boolean emailCommentsContentPublished;
		public Boolean emailLikesSharesContentPublished;
		public Boolean emailContentSubmissionResponse;
		public Boolean emailForContentUseful;

		//Event
		public Boolean emailEventInviteMore;
		public Boolean emailUpdatesEventIRsvpYes;
		public Boolean emailUpdatesEventIAuthorOrganize;

		//Site-management 
		public Boolean emailPrivateSiteMembershipRequest;	
		public Boolean emailContentSubmittedForModeration;
		public Boolean emailSubscriptionRequest;

		//App-management 	
		public Boolean emailSubscriptionModeration;
		public Boolean emailSiteActionableForAppMgr;
		public Boolean emailContentPromotionMessageForAppMgr;
		public Boolean emailForContentUsefulAppMgr;

		public boolean emailContentSubmittedApproved;
		public boolean emailContentSubmittedRejected;

		//Email Notification Frequency
		public String emailNotificationFrequency ;

		public Boolean emailContentUseful; 

		//Question Answer
		public Boolean emailQnANewQuestion;
		public Boolean emailQnAQuestionMention;
		public Boolean emailQnAAnswerMention;
		public Boolean emailQnAVote;
		public Boolean emailQnAAnswerApproval;
		public Boolean emailQnANewAnswer;
		public Boolean emailQnANewApprovedAnswer;
		public Boolean emailQnADuplicateQuestion;
		public Boolean emailForContentQuestion;
		public Boolean emailForContentAnswer;

		//Campaign & Initiative
		public Boolean emailCnIEndCampaign;
		public Boolean emailCnINewCampaign;
		public Boolean emailCnIInitiativeEnd;
		public Boolean emailCnIInitiativeStart;
    }
    
    public class SummariesAndDigestWrapper {
        public String peopleId;
        public String digestFrequency;
        public String topStoriesFrequency;
        public String siteAnalyticsFrequency;
        public Boolean emailProductResearch;
		public string emailOnboardingFrequency;
    }

	public class NativeMobileNotificationWrapper {
		public String peopleId;
		public boolean mobileAppNotifications;
		//Org
		public boolean mobileAppContentMarkedAsMustRead;
		public boolean mobileAppAlerts;
		public boolean mobileAppUpdatesContentSitesFollow;
		//Profile And Expertise
		public boolean mobileAppFollowsMe;
		public boolean mobileAppEndorseExpertise;
		//Feed
		public boolean mobileAppCommentsPostMade;
		public boolean mobileAppReplyAfterMe;
		public boolean mobileAppReplyOnLikedPost;
		public boolean mobileAppLikesPostOrCommentMade;
		public boolean mobileAppSharesMyPost;
		public boolean mobileAppPostsToMe;
		//Site
		public boolean mobileAppPrivateSiteMembershipResponse;
		//Content
		public boolean mobileAppCommentsContentPublished;
		public boolean mobileAppLikesOrSharesContentPublished;
		public boolean mobileAppContentApprovalRejection;
		//Event
		public boolean mobileAppEventInviteMore;
		//Site management
		public boolean mobileAppPrivateSiteMembershipRequest;
		public boolean mobileAppContentSubmittedForModeration;
		//Question Answer
		public boolean mobileQnAQuestionMention;
		public boolean mobileQnAAnswerMention;
		public boolean mobileQnAVote;
		public boolean mobileQnAAnswerApproval;
		public boolean mobileQnANewAnswer;
		public boolean mobileQnANewApprovedAnswer;
		public boolean mobileQnADuplicateQuestion;
		public boolean mobileQnANewQuestion;
		public Boolean mobileAppContentQuestion;
		public Boolean mobileAppContentAnswer;

		//Survey
		public Boolean mobileSurveys;
		
	}
	
	public class MobileNotificationWrapper {
		public String peopleId;
		public boolean mobileAppNotifications;
		public boolean mobileAppFollowsMe;
		public boolean mobileAppEndorseExpertise;
		public boolean mobileAppLikesPostOrCommentMade;
		public boolean mobileAppCommentsPostMade;
		public boolean mobileAppCommentsAfterMe;
		public boolean mobileAppCommentsPostLike;
		public boolean mobileAppPostsToMe;
		public boolean mobileAppSharesPostMade;
		public boolean mobileAppCommentsContentPublished;
		public boolean mobileAppLikesOrSharesContentPublished;
		public boolean mobileAppUpdatesContentSitesFollow;
		public boolean mobileAppEventInviteMore;
		public boolean mobileAppContentSubmittedApproved;
		public boolean mobileAppContentSubmittedRejected;
		public boolean mobileAppContentSubmissionResponse;
		public boolean mobileAppPrivateSiteMembershipResponse;
		public boolean mobileAppContentSubmittedForModeration;
		public boolean mobileAppContentUseful;
		public boolean mobileAppPrivateSiteMembershipRequest;
		public boolean mobileAppContentMarkedAsMustRead;
		public boolean mobileAppAlerts;

		//Survey
		public Boolean mobileSurveys;
	}

	public class BrowserNotificationWrapper {
		public String peopleId;

		// Org
		public Boolean browserMustRead;
		public Boolean browserAlerts;
		public Boolean browserUpdatesContentSitesFollow;
		
		// Profile and Expertise
		public Boolean browserFollowsMe;
		public Boolean browserEndorseExpertise;
		
		// Feed
		public Boolean browserReplyOnMyPost;
		public Boolean browserReplyAfterMe;
		public Boolean browserReplyOnLikedPost;
		public Boolean browserLikesMyPostOrReply;
		public Boolean browserSharesMyPost;
		public Boolean browserPostsToMe;

		//Site
		public Boolean browserPrivateSiteMembershipResponse;
		
		// Content
		public Boolean browserContentValidationRequired;
		public Boolean browserContentValidationExpired;
		public Boolean browserContentCommentsOnPublished;
		public Boolean browserContentLikesSharesOnPublished;
		public Boolean browserContentApprovalRejection;
		public Boolean browserContentFeedback;

		// Events
		public Boolean browserEventInvite;
		public Boolean browserEventUpdatesAttending;
		public Boolean browserEventUpdatesAuthoredOrganized;

		// Site-Manager
		public Boolean browserPrivateSiteMembershipRequest;	
		public Boolean browserContentSubmittedForModeration;
		public Boolean browserSubscriptionRequest;

		// Question Answer
		public Boolean browserQnAQuestionMention;
		public Boolean browserQnAAnswerMention;
		public Boolean browserQnAVote;
		public Boolean browserQnAAnswerApproval;
		public Boolean browserQnANewAnswer;
		public Boolean browserQnANewApprovedAnswer;
		public Boolean browserQnADuplicateQuestion;
		public Boolean browserQnANewQuestion;
		public Boolean browserContentQuestion;
		public Boolean browserContentAnswer;

		//Campaign Initiative
		public Boolean browserCnIEndCampaign;
		public Boolean browserCnINewCampaign;
		public Boolean browserCnIInitiativeEnd;
		public Boolean browserCnIInitiativeStart;
	}
	
	public class LanguageWrapper {
		public String languageLocaleKey;
		public String languageLocaleLabel;
		public LanguageWrapper(String languageLocaleKey, String languageLocaleLabel) {
			this.languageLocaleKey = languageLocaleKey;
			this.languageLocaleLabel = languageLocaleLabel;
		}
	}
	public class TimezoneWrapper implements Comparable {
		public String TimezoneId;
		public Integer Offset;
		public String Label;
		public String ShortLabelWithID;
		public String ShortLabel;
		
		public Integer compareTo(Object compareTo) {
	        TimezoneWrapper timezoneWrapperObj = (TimezoneWrapper) compareTo;
	        if(Offset==null || timezoneWrapperObj.Offset==null){
	        	return 0;
	        }
	        if (Offset == timezoneWrapperObj.Offset) return 0;
	        if (Offset > timezoneWrapperObj.Offset) return -1;
	        return 1;      
	    }
	}
	
	public class MobileSettingsWrapper {
		public String profileId;
		public String landingPage ;
	}
	
	public class CustomUserFields {
		public Integer index;
		public Integer maxLength;
	    public String label ;
		public String value ;
	    public Boolean isHTML ;
	    public String isEditable;
		public String fieldType;
		public String fieldName;
		public String columnName;
		public Boolean booleanFieldValue;
		public Integer integerFieldValue;
		public String stringFieldValue;
		public String multiPickListFieldKeys;
		public List<String> listOfMultiPickListFieldKeys;
		public transient List<String> listOfMultiPickListFieldValues;
		public transient List<Schema.PicklistEntry> picklistEntryList;
	}

	public class AppManagerNotificationWrapper {
		public boolean appManagerNotifications;
		public boolean appManagerUsefulContentNotifications;
		public boolean appManagerUpdateContentNotifications;
	}

	public class SMSNotificationsWrapper {
		public String peopleId;
		public boolean smsAlerts;
		public boolean smsContentMarkedAsMustRead;
		public boolean smsContentPromotionMessage;
	}

	public class MobileNumberWrapper {
		public String peopleId;
		public String mobile;
	}
	
}