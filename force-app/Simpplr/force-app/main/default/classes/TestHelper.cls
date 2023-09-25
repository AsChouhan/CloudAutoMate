/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public with sharing class TestHelper {
	
	private static String[] wordArray =  'Unit tests are class methods that verify whether a particular piece of code is working properly.'.split(' ');
	
	/**
	*
	**/ 
	public static App_Config__c setupAppConfig() {

		String packageName = SimpplrContext.class.getName().substringBefore('SimpplrContext').substringBefore('.');
		Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));

    	App_Config__c appConfigRecord = new App_Config__c(App_Name__c = 'TestAppName',App_Dashboard_Mode__c='User',AT_User_Enabled__c=true,Name='Test App Config',AT_User_Trigger_Type__c='Realtime',Box_Access_Token__c = 'DummyValue',
    										Package_Name__c = packageName, Box_Client_Id__c = 'boxClientId', Box_Client_Secret__c = 'boxClientSecret',  Box_Refresh_Token__c ='DummyValue',
    										Box_Refresh_Token_Expires_At__c = DateTime.now().addHours(5), Box_Access_Token_Expires_At__c = DateTime.now().addHours(5),Box_Enterprise_Id__c = '17077211',
    										Box_Integration_Enabled__c=true, AWS_Access_Token__c = UserInfo.getOrganizationId() + ':', External_Search_Enabled__c =true,Segment_Column_Name__c= 'Division__c',
    										Feed_Show_Track_Change_Posts__c=true,Auto_provisioning_Process_Enabled__c = false,PP_BirthDate_Display__c=true,PP_JoiningDate_Display__c=true,PP_Manager_Display__c=true,
    										Allowed_Features__c='Page,Event,File,Album,Blog',Search_Content_Allowed_Field__c='{ "summary__c": 3,"title__c": 4}',PP_About_Me_Display__c=true,
    										PP_City_Display__c=true,PP_Country_Display__c=true,PP_Department_Display__c=true,PP_Extension_Display__c=true,PP_MobilePhone_Display__c=true,
    										PP_Phone_Display__c=true,PP_State_Display__c=true,PP_Title_Display__c=true,PP_FirstName_Display__c=true,PP_LastName_Display__c=true,
    										PDS_Workday_Password__c = 'LZRsukgT2soH8YhCe1jkaw==', Data_Key__c = 'MAvmUTTgRbZt4fyHHOlZUA==',Simpplr_Mobile_Notification_Allowed__c =false, 
    										AT_ContentDocument_Enabled__c = true,
    										SSO_Custom_JSON__c='[{ "name": "Google Mail", "url": "http://google.com", "img": "http://images.dailytech.com/nimage/Google_Doodle_Wide.gif" }, { "name": "Long application name - it\'s really long. Long", "url": "http://google.com", "img": "http://images.dailytech.com/nimage/Google_Doodle_Wide.gif" }, { "name": "Simpplr", "url": "http://google.com", "img": "http://images.dailytech.com/nimage/Google_Doodle_Wide.gif" }, { "name": "Another App", "url": "http://google.com", "img": "http://images.dailytech.com/nimage/Google_Doodle_Wide.gif" }, { "name": "Workday", "url": "http://google.com", "img": "http://images.dailytech.com/nimage/Google_Doodle_Wide.gif" }, { "name": "Xero", "url": "http://google.com", "img": "http://images.dailytech.com/nimage/Google_Doodle_Wide.gif" }, { "name": "One more app", "url": "http://google.com", "img": "http://images.dailytech.com/nimage/Google_Doodle_Wide.gif" }]',
									        Auto_Convert_ChatterGroup_To_Site__c = true,
									        App_Integrations_Enabled__c = 'facebook;linkedin;twitter',
									        Employee_Advocacy_Enabled__c = true,
											Embedly_Enabled__c = true, Mobile_Promotion_Enabled__c = true,
											EH_Debug_Enabled__c = true, SMS_Enabled__c = true,
											Embedly_API_Key__c = 'Simpplr',AD_Integration_Enabled__c=true, 
											PDS_Title__c = true, PDS_City__c = true, PDS_State__c=true, PDS_Country__c = true, PDS_Birth_Date__c = true,
											PDS_Community_Nickname__c = true, PDS_About_Me__c = true,  PDS_Department__c = true,PDS_Phone__c=true,
											PDS_Joining_Date__c = true, PDS_Street__c=true, PDS_Mobile_Phone__c =true,PDS_Postal_Code__c = true,
									        Feedback_Share_with_Simpplr__c = true,
									        Feedback_To_Emails__c = 'package.managers@simpplr.com',
									        Microsoft_Teams_Integration_Enabled__c = true,
									        Analytics_Data_Collection_Enabled__c=false,External_Analytics_Enabled__c=false,
									        Simpplr_Emails_Allowed__c = true,
											Allow_Only_Influencers_To_Create_Blog__c=false,
									        PP_User_Custom_Fields__c = '[{"onOff":true,"fieldName":"Fax","label":null,"itemOrder":"0","isHtml":false,"isEditable":true}, {"onOff":true,"fieldName":"DefaultGroupNotificationFrequency","label":"DefaultGroupNotificationFrequency","itemOrder":"1","isHtml":false,"isEditable":true}]',
									        External_search_app_connected__c = true,
											Validation_Period__c = 'P12M',
											Vbrick_Enabled__c = true, Vbrick_Base_Url__c = 'https://simpplr.com',
											Android_App_Link__c = 'https://simpplr.com',
											People_Category_Enabled__c = true,
    										People_Catgeory_Singular__c = 'Team',
											People_Catgeory_Plural__c = 'Teams',
											Start_Of_Week__c = dt.format('EEEE'),
                                            Feed_Mode__c = 'timeline',
											Branded_App_Distribution_Enabled__c = true,
											Auto_Free_Simpplr_License_Enabled__c = true,
											PDS_UKG_Pro_Password__c = 'nNt6PXvHc9FntPrNbkChAHl1Aip21Ima18NyDS2uag0=',
											PDS_UKG_Pro_API_Key__c = 'nNt6PXvHc9FntPrNbkChAHl1Aip21Ima18NyDS2uag0=',
											App_Languages_Enabled__c = 'en_US;en_GB;fr_FR',
											Okta_API_Token__c = 'TYa6bunAPj6pEi001L9+oS5dQG2cFlCEylJp+gHCbZM=',
											Custom_Links_JSON__c = '[{"onOff":true,"url":"https://www.simpplr.com","name":"Simpplr","itemOrder":"0"}]',
											Native_App_Enabled__c = true,
											GA_Tracking_Code4__c = 'xgthyyttw',
											Enable_Google_Analytics4__c = false,
											Enable_Google_Analytics3__c = false,
											debug_enabled_for_users__c = UserInfo.getUserId(),
											Debugging_Turn_Off_Time__c = System.now().addDays(1),
											Flow_External_Sync_Enabled__c = false
									    );

        insert appConfigRecord;
        System.assert(String.isNotBlank(appConfigRecord.id),'Running as expected');
        return appConfigRecord;
	}

	public static void updateAppConfigFields(App_Config__c appConfig){
		if(appConfig != null){
			update appConfig;
		}
	}

	public static App_Config__c getAppConfig(){
		String appConfigFields = String.join(new List<String>(App_Config__c.sObjectType.getDescribe().fields.getMap().keySet()), ',');
		String appConfigQuery = 'SELECT ' + appConfigFields + ' FROM App_Config__c LIMIT 1'; 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
		return appConfig;
	}

	public static void createEveryoneAudience() {
		List<Audience__c> audienceList = [select id from Audience__c where name__c='Everyone' And Is_Hidden__c = true];
		if(audienceList.isEmpty()) {
			Audience__c audienceObj = new Audience__c();
			audienceObj.Name__c = 'Everyone';
			audienceObj.Audience_Rule_Json__c = '[]';
			audienceObj.Is_Hidden__c = true;
			insert audienceObj;
		}
	}
	
	public static App_Integration__c setUpAppIntegration(){
		App_Integration__c appIntegObj = new App_Integration__c(Name='gdrive',Access_Token_Expiry__c=3600,Access_Token_Requested_Datetime__c=DateTime.now(),
							Client_Id__c='305062543529-g8bt3b2kfs63mrfb0360ehrqgmtqdgee.apps.googleusercontent.com',
							Client_Secret__c='OeFOIw12JqtltnS7n0g8Qzt4', Connected__c=true, External_Id__c='11551083267734841420', 
							Extra_Url_Parameters__c='prompt=consent&access_type=offline&include_granted_scopes=false', Is_Deleted__c=false,
							Scope_Required__c=true, Scope__c='https://www.googleapis.com/auth/drive', Token_Type__c='Bearer', User_Email__c='amit@bhootnath.in', 
							User_Name__c='Amit Kumar',  App_Access_Token__c='ya29.GlzTBV6RaKVMrREIrJnI2mW6BjM7PrsCNK8mg6BFfmQJ2YINhLqj0v64yn4eLQxb5qLJjR4z-VpUY9tCvLZ3MxmdqSp8931n7r_0_QzAYBvRhoBYYoCoN0vWQ06jyA', 
							App_Refresh_Token__c='1/XvT7HUvjj4yqMb6fy3bHoWEPq0nkFJ3PRxgobJp_se0', 
							Integration_Enabled__c=true, All_Company_Group_Id__c='00D61000000CKMDEA4@bhootnath.in', Enterprise_Id__c='bhootnath.in', Batch_Processing__c=false, Root_Folder_Id__c='test root folderid', Org_Id__c=UserInfo.getOrganizationId());
	
        
        
        App_Integration__c appIntegObj1 = new App_Integration__c(Name='adsi',Access_Token_Expiry__c=3600,Access_Token_Requested_Datetime__c=DateTime.now(),
							Client_Id__c='305062543529-g8bt3b2kfs63mrfb0360ehrqgmtqdgee.apps.googleusercontent.com',
							Client_Secret__c='OeFOIw12JqtltnS7n0g8Qzt4', Connected__c=true, External_Id__c='11551083267734841420', 
							Extra_Url_Parameters__c='prompt=consent&access_type=offline&include_granted_scopes=false', Is_Deleted__c=false,
							Scope_Required__c=true, Scope__c='https://www.googleapis.com/auth/drive', Token_Type__c='Bearer', User_Email__c='amit@bhootnath.in', 
							User_Name__c='Amit Kumar',  App_Access_Token__c='ya29.GlzTBV6RaKVMrREIrJnI2mW6BjM7PrsCNK8mg6BFfmQJ2YINhLqj0v64yn4eLQxb5qLJjR4z-VpUY9tCvLZ3MxmdqSp8931n7r_0_QzAYBvRhoBYYoCoN0vWQ06jyA', 
							App_Refresh_Token__c='1/XvT7HUvjj4yqMb6fy3bHoWEPq0nkFJ3PRxgobJp_se0', 
							Integration_Enabled__c=true, All_Company_Group_Id__c='00D61000000CKMDEA4@bhootnath.in', Enterprise_Id__c='bhootnath.in', Batch_Processing__c=false, Root_Folder_Id__c='test root folderid', Org_Id__c=UserInfo.getOrganizationId());
		insert appIntegObj;
		return appIntegObj;
        
	
	}

	public static App_Integration__c setUpAppIntegrationADSI(){
		App_Integration__c appIntegObj = new App_Integration__c(Name='adsi',Client_Id__c='dummyid', Client_Secret__c='dummysecret', App_Access_Token__c='dummttoken',
														App_Refresh_Token__c='dummyrefreshtoken', User_Email__c='amit@bhootnath.in', User_Name__c='Amit Kumar', Is_Deleted__c = false, Org_Id__c=UserInfo.getOrganizationId());

		insert appIntegObj;

		return appIntegObj;
	}
	
	public static App_Default__c setupAppDefault() {

		String packageName = SimpplrContext.class.getName().substringBefore('SimpplrContext').substringBefore('.');
    	App_Default__c appDefaultRecord = new App_Default__c(Type__c = 'email_notifications', OverwriteBatchInProgress__c = false, Data__c = '{"isProcessing":false,"isApplyToAllUsers":1, "allowSimpplrEmails": "enable", "emailNotificationFrequency": "Immediate", "emailContentMarkedAsMustRead": true, "emailAlerts": true, "emailUpdatesContentSitesFollow": true, "emailFollowsMe": true, "emailEndorseExpertise": true, "emailCommentsPostMade": true, "emailCommentsAfterMe": true, "emailCommentsPostLike": true, "emailLikesPostOrCommentMade": true, "emailSharesPostMade": true, "emailPostsToMe": true, "emailPrivateSiteMembershipResponse": true, "emailKnowledgeReview": true, "emailKnowledgeExpired": true, "emailCommentsContentPublished": true, "emailLikesSharesContentPublished": true, "emailContentSubmissionResponse": true, "emailForContentUseful": true, "emailEventInviteMore": true, "emailUpdatesEventIRsvpYes": true, "emailUpdatesEventIAuthorOrganize": true, "emailPrivateSiteMembershipRequest": true, "emailContentSubmittedForModeration": true, "emailSubscriptionRequest": true, "emailSubscriptionModeration": true, "emailSiteActionableForAppMgr": true, "emailContentPromotionMessageForAppMgr": true, "emailForContentUsefulAppMgr": true}');
        insert appDefaultRecord;
        System.assert(String.isNotBlank(appDefaultRecord.id),'Running as expected');
        return appDefaultRecord;
	}	

		public static Expertise__c setupExpertise() {

    	Expertise__c expertiseRecord = new Expertise__c(Name__c='testsimpplrexpertise', Display_Name__c='Test Simpplr Expertise');
        insert expertiseRecord;
        System.assert(String.isNotBlank(expertiseRecord.id),'Running as expected');
        return expertiseRecord;
	}	
	public static People_Expertise__c setupPeopleExpertise(Expertise__c exp,people__c peopleObj) {

    	People_Expertise__c peopleExpertiseRecord = new People_Expertise__c(name='Test Simpplr People Expertise',expertise__c=exp.id,people__c= peopleobj.id);
        insert peopleExpertiseRecord;
        System.assert(String.isNotBlank(peopleExpertiseRecord.id),'Running as expected');
        return peopleExpertiseRecord;
	}	

	public static People_Expertise_Detail__c setupPeopleExpertiseDetail(People_Expertise__c peopleExpertise,People__c peopleObj) {

    	People_Expertise_Detail__c peopleExpertiseDetailRecord = new People_Expertise_Detail__c(name='Test Simpplr People Expertise Detail',People_Expertise__c=peopleExpertise.id,Endorser__c= peopleobj.id);
        insert peopleExpertiseDetailRecord;
        System.assert(String.isNotBlank(peopleExpertiseDetailRecord.id),'Running as expected');
        return peopleExpertiseDetailRecord;
	}	


	public static Must_Read_Audit__c createMustReadAudit(String contentId, String audienceType, String peopleId) {
		Must_Read_Audit__c mustReadAuditObj = new Must_Read_Audit__c();
		mustReadAuditObj.Audience_Type__c = audienceType;
		mustReadAuditObj.Mark_Datetime__c = System.Now();
		mustReadAuditObj.Marked_By_People__c = peopleId;
		mustReadAuditObj.Message__c = 'test msg';
		mustReadAuditObj.Content__c = contentId;
		mustReadAuditObj.Duration__c = 'ninety_days';
		mustReadAuditObj.Expiry_DateTime__c = mustReadAuditObj.Mark_Datetime__c.date().addDays(90);		
		insert mustReadAuditObj;
		return mustReadAuditObj;	
	}
	
	public static Tiles_Config__c createTilesConfigData(String segmentId, String siteId, String peopleId, String type, String variant) {
		Tiles_Config__c tileConfigObj;
		TileDataWrapper.TileDataSettings tileDataSettingObj;
		
		//News Tile
		tileConfigObj = new Tiles_Config__c();	
        tileConfigObj.Type__c = type;
		tileConfigObj.Name__c = type;
		tileConfigObj.variant__c = variant;
		tileConfigObj.Variant_Type__c = variant + '_' + type;
		tileConfigObj.Is_Manager_Driven__c = false;
		tileConfigObj.Is_First_On_Mobile__c = true;
		tileConfigObj.Layout_Column__c = 1;
		tileConfigObj.Order__c = 1;
		tileConfigObj.Site__c = siteId;
		tileConfigObj.People__c = peopleId;
		tileDataSettingObj = new TileDataWrapper.TileDataSettings();
		tileDataSettingObj.size = 5;
		tileConfigObj.segment__c = segmentId;
		tileConfigObj.Data__c = JSON.serialize(tileDataSettingObj);
		tileConfigObj.Location__c = String.isNotBlank(siteId) ? 'Site Dashboard' : (String.isNotBlank(segmentId) ? 'Segment Dashboard' : 'Home Dashboard'); 
		insert tileConfigObj;
		return tileConfigObj;
	}
	
	public static void insertMemberToGroup(String groupId, String memberId,String role){
		CollaborationGroupMember groupMember = new CollaborationGroupMember();
		if(String.isNotBlank(groupId) && String.isNotBlank(memberId)){
			groupMember.CollaborationGroupId = groupId;
			groupMember.MemberId = memberId;
			if('admin'.equalsIgnoreCase(role)){
				groupMember.CollaborationRole = role;
			}else{
				groupMember.CollaborationRole = 'Standard';
			}
			insert groupMember;
		}
		System.assert(groupMember.id!=null,'Running as expected');
	}
	
	public static void addBookmarkForSite(String siteId, String peopleId){
		Bookmark__c bookmarkObj = new Bookmark__c(Simpplr_Site__c=siteId,People__c=peopleId,Type__c='Site');
        insert bookmarkObj;
       
        System.assert(bookmarkObj.id!=null,'Running as expected');
	}
	
	public static void addBookmarkForPeople(String receiverPeopleId, String peopleId){
		Bookmark__c bookmarkObj = new Bookmark__c(Bookmark_Receiver__c=receiverPeopleId,People__c=peopleId,Type__c='People');
        insert bookmarkObj;
       
        System.assert(bookmarkObj.id!=null,'Running as expected');
	}
	
	public static void createHelpTextRecords() {
		List<Help_Text__c> helpTextList = new List<Help_Text__c>();
		helpTextList.add(new Help_Text__c(Page_Name__c='HomeMyDashboard',Help_Text__c='Home dashboard shows content from sites and people that you follow. Customize to fit your needs.'));
		insert helpTextList;
	}
	
	/**
	*
	**/
	public static Simpplr_Content__c createContent(String title, String typeArg, String status, User asUser, Simpplr_Site__c simpplrSiteObj){
	
	    Simpplr_Content__c  contentRec = getContentRecordForCreation(title, typeArg, status, simpplrSiteObj);
        contentRec = TestHelper.createContent(contentRec, asUser);
        System.assert(contentRec.id!=null, 'Running as Expected');
        return contentRec;
    }

	public static Simpplr_Content__c getContentRecordForCreation(String title, String typeArg, String status, Simpplr_Site__c simpplrSiteObj) {
		String ctype = String.isBlank(typeArg) ? 'Page' : typeArg;
	    Simpplr_Content__c  contentRec = new Simpplr_Content__c(
					                    Title__c=title,
					                    Primary_Author__c = UserContext.peopleId,
					                    Text_Intro__c=getLongText(), 
					                    Text_Main__c=getLongText(),
					                    Text_Main_Continued__c=getLongText(),
					                    Type__c=ctype, 
					                    Summary_1__c='testSummary',
					                    Summary_2__c=' testSummary2',
					                    Status__c=status,
					                    Publish_Start_DateTime__c = DateTime.now(),
					                    Last_Edited_DateTime__c = DateTime.now(),
										Created_DateTime__c = DateTime.now(),
										Last_Updated_DateTime__c = DateTime.now(),
					                    Site__c=(simpplrSiteObj==null)?null:simpplrSiteObj.id);
		
		if('Event'.equalsIgnoreCase(typeArg)) {
			contentRec.Event_Start_DateTime__c = DateTime.now();
			Date nextWeekDate = Date.today().addDays(7);
			contentRec.Event_End_DateTime__c = DateTime.newInstance(nextWeekDate.year(), nextWeekDate.month(), nextWeekDate.day(), 0 ,0,0);
			contentRec.Event_RSVP_Allowed__c = true;
			contentRec.Event_Location__c = 'Test location';
			contentRec.Event_TimezoneSidKey__c = 'America/Los_Angeles';
		}
		return contentRec;
	}

	/**
	*
	**/
	public static Simpplr_Content__c createContent(String title, String typeArg, String subTypeArg, String status, User asUser, DateTime publishStartDate, DateTime publishEndDate, Simpplr_Site__c simpplrSiteObj){
		
		String ctype = String.isBlank(typeArg) ? 'News' : typeArg;
	    Simpplr_Content__c  contentRec = new Simpplr_Content__c(
					                    Title__c=title,
					                    Primary_Author__c = UserContext.peopleId,
					                    Text_Intro__c=getLongText(), 
					                    Text_Main__c=getLongText(),
					                    Text_Main_Continued__c=getLongText(),
					                    Type__c=ctype, 
										Content_Sub_Type__c=subTypeArg,
					                    Summary_1__c='testSummary',
					                    Summary_2__c=' testSummary2',
					                    Status__c=status,
					                    Publish_Start_DateTime__c = publishStartDate,
					                    Last_Edited_DateTime__c = publishEndDate,
										Created_DateTime__c = DateTime.now(),
										Last_Updated_DateTime__c = DateTime.now(),
					                    Site__c=(simpplrSiteObj==null)?null:simpplrSiteObj.id);
		
		if('Event'.equalsIgnoreCase(typeArg)) {
			contentRec.Event_Start_DateTime__c = DateTime.now();
			contentRec.Event_End_DateTime__c = DateTime.now().addDays(12);
			contentRec.Event_RSVP_Allowed__c = true;
			contentRec.Event_Location__c = 'Test location';
			contentRec.Event_TimezoneSidKey__c = 'America/Los_Angeles';
		}
        contentRec = TestHelper.createContent(contentRec, asUser);
        System.assert(contentRec.id!=null, 'Running as Expected');
        return contentRec;
    }

	

	public static Simpplr_Content__c createContent(String title, String typeArg, String status, People__c author, Simpplr_Site__c simpplrSiteObj){
	    Simpplr_Content__c  contentRec = new Simpplr_Content__c(
					                    Title__c=title,
					                    Primary_Author__c = author.id,
					                    Text_Intro__c=getLongText(), 
					                    Type__c=typeArg, 
					                    Summary_1__c='testSummary',
					                    Status__c=status,
					                    Publish_Start_DateTime__c = DateTime.now(),
					                    Last_Edited_DateTime__c = DateTime.now(),
										Created_DateTime__c = DateTime.now(),
										Last_Updated_DateTime__c = DateTime.now(),
					                    Site__c=(simpplrSiteObj==null)?null:simpplrSiteObj.id);
		
		if('Event'.equalsIgnoreCase(typeArg)) {
			contentRec.Event_Start_DateTime__c = DateTime.now();
			contentRec.Event_End_DateTime__c = DateTime.now().addDays(12);
			contentRec.Event_RSVP_Allowed__c = true;
			contentRec.Event_Location__c = 'Test location';
			contentRec.Event_TimezoneSidKey__c = 'America/Los_Angeles';

		}
        insert contentRec;
        System.assert(contentRec.id!=null, 'Running as Expected');
        return contentRec;
	}
	
	/**
	*
	**/
	public static Question__c createQuestion(String title, User asUser, Simpplr_Site__c simpplrSiteObj){
	
	    Question__c  questionRec = getQuestionRecordForCreation(title, simpplrSiteObj);
        questionRec = TestHelper.createContent(questionRec, asUser);
        System.assert(questionRec.id!=null, 'Running as Expected');
        return questionRec;
    }

	public static Question__c getQuestionRecordForCreation(String title, Simpplr_Site__c simpplrSiteObj) {
	    Question__c  questionRec = new Question__c(
					                    Title__c = title,
										Questioned_By__c = UserContext.peopleId,
										Description__c = 'tesing',
					                    Publish_DateTime__c = DateTime.now(),
					                    Last_Edited_DateTime__c = DateTime.now(),
										Site__c=(simpplrSiteObj==null)?null:simpplrSiteObj.id);
		return questionRec;
	}

	public static Question__c createContent(Question__c questionRec, User asUser){
    	try{
	    	System.runAs(asUser) {
	    		insert questionRec;
	    	}
	    	System.assert(questionRec.id!=null, 'Running as Expected');
    	}catch(DmlException e){
            throw e;
        }
    	return questionRec;
    }

    
    public static Pages_Category__c getPageCategory(String categoryName, String siteId) {
    	Pages_Category__c categoryObj = new Pages_Category__c(Name__c=categoryName, site__c=siteId );
    	insert categoryObj;
    	return categoryObj;
    }
    
    public static Mailer__c getMailerRecord(String subject, String sentById, String siteId, String contentId) {
    	
    	Mailer__c mailerObj = new Mailer__c();
        mailerObj.Sent_Time__c = Date.today();
        mailerObj.Site__c = siteId;
        mailerObj.Job_Id__c = 'TestJob';
        mailerObj.Sent_By__c = sentById;
        mailerObj.Test_Mailer_Sent__c = true; 
        mailerObj.Type__c = 'Manual';
        mailerObj.Scheduled_Date__c = Date.today().addDays(2); 
        mailerObj.Is_Deleted__c = false;
        mailerObj.Initial_Recipient_Count__c=1;
        mailerObj.Actual_Recipient_Count__c=1;                           
		mailerObj.Introduction_Inlined__c = '<p>' + subject + '</p>';
		mailerObj.Name__c = 'Newsletter test';
		mailerObj.From_Address_Id__c = '';
		mailerObj.Banner_Url__c = 'https://static.simpplr.com/newsletter/00D36000000bb1TEAQ_15299243292141.jpeg';
		mailerObj.Subject__c = subject;
		mailerObj.Initial_Recipient_Count__c = 10.0;
		mailerObj.status__c = 'Sent';
                                   
        insert mailerObj;   
        createMailerDetailRecords(mailerObj.Id, contentId);
        return mailerObj; 
    }
    
    public static List<Mailer_Details__c> createMailerDetailRecords(String mailerId, String contentId) {
    	List<Mailer_Details__c> mdList  = new List<Mailer_Details__c>();
    	
    	Mailer_Details__c mailerDetailTextObj = new Mailer_Details__c();
		mailerDetailTextObj.Text__c = 'Dummy text';
        mailerDetailTextObj.Mailer__c = mailerId;
        mailerDetailTextObj.Order__c = 0;
        mailerDetailTextObj.Type__c = 'Text';
		mailerDetailTextObj.Is_Showcase__c = false;
		
		Mailer_Details__c mailerDetailContentObj = new Mailer_Details__c();
		mailerDetailContentObj.Text__c = '';
        mailerDetailContentObj.Mailer__c = mailerId;
        mailerDetailContentObj.Order__c = 1;
        mailerDetailContentObj.Type__c = 'Content';
		mailerDetailContentObj.Is_Showcase__c = true;
		mailerDetailContentObj.Content__c = contentId;
		
		Mailer_Details__c mailerDetailheadingObj = new Mailer_Details__c();
		mailerDetailheadingObj.Text__c = 'Hello i am a dummy header';
        mailerDetailheadingObj.Mailer__c = mailerId;
        mailerDetailheadingObj.Order__c = 2;
        mailerDetailheadingObj.Type__c = 'Heading';
		mailerDetailheadingObj.Is_Showcase__c = false;
		
		Mailer_Details__c mailerDetailDividerObj = new Mailer_Details__c();
		mailerDetailDividerObj.Text__c = '';
        mailerDetailDividerObj.Mailer__c = mailerId;
        mailerDetailDividerObj.Order__c = 3;
        mailerDetailDividerObj.Type__c = 'Divider';
		mailerDetailDividerObj.Is_Showcase__c = false;
		
		mdList.add(mailerDetailTextObj);
		mdList.add(mailerDetailContentObj);
		mdList.add(mailerDetailheadingObj);
		mdList.add(mailerDetailDividerObj);
				
    	insert mdList;
    	return mdList;
    }
    
    public static Simpplr_Content__c createContent(String title, String typeArg, String status, User asUser, Simpplr_Site__c simpplrSiteObj, String peopleId){
		
		String ctype = String.isBlank(typeArg) ? 'News' : typeArg;
		
	    Simpplr_Content__c  contentRec = new Simpplr_Content__c(
					                    Title__c=title,
					                    Text_Intro__c=getLongText(), 
					                    Text_Main__c=getLongText(),
					                    Text_Main_Continued__c=getLongText(),
					                    Type__c=ctype, 
					                    Status__c=status,
					                    Primary_Author__c = peopleId,
										Created_DateTime__c = DateTime.now(),
										Last_Updated_DateTime__c = DateTime.now(),
            							Publish_Start_DateTime__c = DateTime.now(),
					                    Site__c=(simpplrSiteObj==null)?null:simpplrSiteObj.id);
		if('Event'.equalsIgnoreCase(typeArg)) {
			contentRec.Event_Start_DateTime__c = DateTime.now();
			contentRec.Event_End_DateTime__c = DateTime.now().addDays(12);
			contentRec.Event_Location__c = 'Test location';
			contentRec.Event_TimezoneSidKey__c = 'America/Los_Angeles';
		}
        contentRec = TestHelper.createContent(contentRec, asUser);
        System.assert(contentRec.id!=null, 'Running as Expected');
        return contentRec;
    }
    
   public static ContentVersion createContentVersion(String blobDataString, String name){
        System.assert(true, 'Running as Expected');
        ContentVersion obj = new ContentVersion(VersionData=Blob.valueOf(blobDataString), PathOnClient=name, 
        						Description = name,
        						Origin = 'H', Title='Title_'+name);
		try{
            insert obj;
            System.assert(obj.id!=null, 'Running as Expected');
            return obj;
        }catch(Exception e){
            throw e;
        }
    }
    
    /**
	* origin= H -- Chatter
	* origin= C -- CRM
	**/
    public static ContentVersion createContentVersion(String blobDataString, String name, User contentOwner){
        System.assert(true, 'Running as Expected');
        ContentVersion obj = new ContentVersion(VersionData=Blob.valueOf(blobDataString), PathOnClient=name, 
        						Origin = 'H', Title='Title_'+name, OwnerId=contentOwner.id);
		try{
            insert obj;
            System.assert(obj.id!=null, 'Running as Expected');
            return obj;
        }catch(Exception e){
            throw e;
        }
    }
    
    public static Folder__c createChatterFolder(String name, String parentFolder, String site, String ftype, String path, String permission){
        System.assert(true, 'Running as Expected');
        Folder__c obj = new Folder__c(Name__c = name, Parent_Folder__c = parentFolder, Site__c = site, Type__c = ftype, Path__c = path, Permissions__c = permission);
        
		try{
            insert obj;
            System.assert(obj.id!=null, 'Running as Expected');
            return obj;
        }catch(Exception e){
            throw e; 
        }
    }
    
    public static Topic getTopicByName(String topicText){
    	List<Topic> topicList = [select name, id from Topic where name =:topicText];
    	System.assert(topicList!=null, 'Running as Expected');
    	System.assert(topicList.size()>0, 'Running as Expected');
    	return topicList[0];
    }
    
    public static Topic createTopic(String topicText){
    	Topic topic = new Topic(Name = topicText);
	    insert topic;
	    System.assert(topic!=null, 'Running as Expected');
	 	return  topic;  
    }
	
	public static Expertise__c createExpertise(String expertiseName){
		String alphanumericName = expertiseName.replaceAll('[^\\p{L}\\p{M}\\p{N}]', '');
		alphanumericName = alphanumericName.toLowerCase();
			
    	Expertise__c expertiseObj = new Expertise__c(Name__c = alphanumericName, Display_Name__c = expertiseName);
	    insert expertiseObj;
	    System.assert(expertiseObj!=null, 'Running as Expected');
	 	return  expertiseObj;  
    }
	
	public static People_Expertise__c createPeopleExpertise(Expertise__c expertiseObj, People__c peopleObj){
    	People_Expertise__c pEObj = new People_Expertise__c(Expertise__c = expertiseObj.Id, People__c = peopleObj.Id);
	    insert pEObj;
	    System.assert(pEObj!=null, 'Running as Expected');
	 	return  pEObj;  
	}
	
	public static People_Expertise_Detail__c createPeopleExpertiseDetail(People_Expertise__c pEObj, People__c peopleObj){
    	People_Expertise_Detail__c pEDObj = new People_Expertise_Detail__c(People_Expertise__c = pEObj.Id, Endorser__c = peopleObj.Id);
	    insert pEDObj;
	    System.assert(pEDObj!=null, 'Running as Expected');
	 	return  pEDObj;  
    }

    public static Pages_Category__c createPageCategory(String siteId, String categoryName){
    		Pages_Category__c  pageCatObj = new Pages_Category__c(Site__c = siteId, Name__c = categoryName);
	    insert pageCatObj;
	 	return  pageCatObj;  
    }
    
    public static Boolean addTopicToContent(String topicId, String contentId){
    	TopicAssignment topicAssignment = new TopicAssignment(TopicId=topicId,EntityId=contentId);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);/*
		topicAssignment = (TopicAssignment)SIMPESAPI.accessController().insertAsUser(topicAssignment, 
													new List<String>{
														TopicAssignment.TopicId,
														TopicAssignment.EntityId														
												});         */
	//    System.assert(topicAssignment.id!=null, 'Running as Expected');
	 	return true;
	}
	
	public static Boolean addTopicToQuestion(String topicId, String questionId){
    	TopicAssignment topicAssignment = new TopicAssignment(TopicId=topicId,EntityId=questionId);
        insert topicAssignment;
	    System.assert(topicAssignment.id!=null, 'Running as Expected');
	 	return true;
    }
    
    /**
	*
	**/
    public static Simpplr_Content__c createContent(Simpplr_Content__c contentRec, User asUser){
    	try{
	    	System.runAs(asUser) {
	    		insert contentRec;
	    	}
	    	System.assert(contentRec.id!=null, 'Running as Expected');
    	}catch(DmlException e){
            throw e;
        }
    	return contentRec;
    }

	public static List<Simpplr_Content__c> createContentList(List<Simpplr_Content__c> contentRecList, User asUser){
    	try{
	    	System.runAs(asUser) {
	    		insert contentRecList;
	    	}
	    	System.assert(contentRecList[0].id!=null, 'Running as Expected');
    	}catch(DmlException e){
            throw e;
        }
    	return contentRecList;
    }
    
    /**
	*
	**/
    public static User getUserById(String idarg){
    	List<User> ulst = [SELECT Id, usertype, isActive, AboutMe, City, CommunityNickname, CompanyName, Country, Department, Division, Email, EmployeeNumber, 
        						Extension, Fax, FirstName, LastName, MobilePhone, Phone, PostalCode, State, Street, Title, Show_Simpplr__c,CreatedDate,
								AboutMe__c, City__c, CommunityNickname__c, CompanyName__c, Country__c, Department__c, Division__c, Email__c, EmployeeNumber__c, Extension__c, Fax__c, FirstName__c, LastName__c, MobilePhone__c, Phone__c, PostalCode__c, State__c, Street__c, Title__c
                                                FROM User where Id = :idarg];
    	System.assert(true, 'Running as Expected');
    	return ulst[0];
    }
    
    public static User getUser(String profileName, String lastName){
        List<User> ulst = [select id,usertype,isActive,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
        					from User where profile.name =:profileName and lastname=:lastName LIMIT 1];
    	System.assert(true, 'Running as Expected');
    	return ulst[0];
    }
    
	/**
	* can pass null
	**/ 
	public static User createUser(String lastName, User managerUser, Boolean isAdminProfile) {
		
        Profile pfl = null;
        isAdminProfile = isAdminProfile!=null? isAdminProfile : false;
        if(isAdminProfile){
        	pfl = [select id from profile where name='System Administrator'];
        }else{
        	pfl = [select id from profile where name='Standard User'];
        }
        
        User testUser = new User(alias = 'u1', email=lastName+'_usr@testorg.com', title=lastName,
            emailencodingkey='UTF-8', firstname=lastname,firstname__c=lastname,lastname=lastName,lastname__c=lastname,languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id, city=lastName,state=lastName, 
            aboutme=lastName,phone=lastname,Extension=lastname,MobilePhone=lastname,
            country='United States' +lastName, CommunityNickname = 'u_' + Math.random(),
            department='a',
            timezonesidkey='America/Los_Angeles', username=lastName+'_usr@testorg.com');
            
        if(managerUser!=null){
        	testUser.managerId = managerUser.id;
        }
        insert testUser;
        System.assert(testUser.id!=null, 'Running as Expected');
        
        return testUser;
    }
    
    public static User createUser(String lastName, User managerUser, String profileId) {
		
        User testUser = new User(alias = 'u1', email=lastName+'_usr@testorg.com', title=lastName,
            emailencodingkey='UTF-8', firstname=lastname,lastname=lastName, languagelocalekey='en_US',
            localesidkey='en_US', profileid = profileId, city=lastName,state=lastName, 
            aboutme=lastName,phone=lastname,Extension=lastname,MobilePhone=lastname,
            country='United States' +lastName, CommunityNickname = 'u_' + Math.random(),
            timezonesidkey='America/Los_Angeles', username=lastName+'_usr@testorg.com');
            
        if(managerUser!=null){
        	testUser.managerId = managerUser.id;
        }
        insert testUser;
        System.assert(testUser.id!=null, 'Running as Expected');
        
        return testUser;
    }

	public static File__c createFile(String title, String siteId, String folderId) {
    	File__c file = new File__c(is_deleted__c = false,title__c= title, Is_Title_Image__c=true, Folder__c = folderId, Site__c = siteId, MIME_Type__c='image', Likes__c = 2);
        insert file;
        return file;
    }
    
    public static File__c createContentTitleImage(String contentId) {
    	File__c file = new File__c(is_deleted__c = false,title__c='TitleImage',Is_Title_Image__c=true, Location__c='Cover', Simpplr_Content__c = contentId, Title_Image_Type__c='Widescreen', MIME_Type__c='image', Likes__c = 2);
        insert file;
        return file;
    }
    
    public static File__c createContentTitleImage(String contentId, String imageType) {
    	File__c file = new File__c(is_deleted__c = false,title__c='TitleImage',Is_Title_Image__c=true, Location__c='Cover', Simpplr_Content__c = contentId, Title_Image_Type__c=imageType, MIME_Type__c='image', Likes__c = 2);
        insert file;
        return file;
    }

	public static File__c createFileRecordForVideo(String contentId, String url) {
    	File__c file = new File__c(External_Id__c='1_3wy915mv', is_deleted__c = false,title__c='TitleImage',Is_Title_Image__c=false, Location__c='inline', Simpplr_Content__c = contentId, Title_Image_Type__c='Widescreen', MIME_Type__c='video', Url__c=url, Likes__c = 2);
        insert file;
        return file;
	}
	
	public static File__c createVideoFileRecordInQuestion(String questionId, String location) {
    	File__c file = new File__c(is_deleted__c = false,title__c='Title',Is_Title_Image__c=true, Location__c=location, Question__c = questionId, Likes__c = 2, MIME_Type__c='video', Repository__c = 'native_video', Thumbnail_URL__c = 'https://cdnapisec.kaltura.com/p/null/thumbnail/entry_id/1_lkn0vrb2/width/550/height/480');
        insert file;
        return file;
    }
	public static File__c createImageFileRecordInQuestion(String questionId, String location) {
    	File__c file = new File__c(is_deleted__c = false,title__c='TitleImage',Is_Title_Image__c=true, Location__c=location, Question__c = questionId, Likes__c = 2, MIME_Type__c='image');
        insert file;
        return file;
    }

	public static CollaborationGroup createCollaborationGroup(String groupName, String groupType) {
		return createCollaborationGroup(groupName, groupType, true);
	}

	public static CollaborationGroup createCollaborationGroup(String groupName, String groupType, Boolean isInsert) {
		CollaborationGroup newGroup = new CollaborationGroup(name=groupName, CollaborationType=groupType);
		newGroup.InformationTitle ='Title';
		newGroup.InformationBody = 'Information';
		newGroup.Description='TestDescription';
		newGroup.IsAutoArchiveDisabled = true;
		if(isInsert){
			insert newGroup;
		}
		return newGroup;
	}
	
	public static void changeCollaborationGroupOwner(String cid, String userId) {
		CollaborationGroup updatedObj = new CollaborationGroup(id=cid, ownerId=userId);
		update updatedObj;
	}
	
	public static ID createCollaborationGroup(String groupName, User GroupOwner, Boolean isArchived, Boolean isPrivate){
		CollaborationGroup newGroup = createCollaborationGroup2(groupName,GroupOwner,isArchived,isPrivate);
		return newGroup.id;
	}
	
	public static Content_Collaborator__c createContentCollaborator(String contentId, String peopleId, String collaboratorType) {
		Content_Collaborator__c contentCollaboratorObj = new Content_Collaborator__c(Simpplr_Content__c=contentId,Collaborator__c=peopleId, Type__c=collaboratorType);
		insert contentCollaboratorObj;
		return contentCollaboratorObj;
	}
	
	/**
	*
	**/
	public static CollaborationGroup createCollaborationGroup2(String groupName, User GroupOwner, Boolean isArchived, Boolean isPrivate){
		CollaborationGroup newGroup = null;
		System.runAs(GroupOwner) {
			newGroup = new CollaborationGroup();
			
			newGroup.Name=String.isBlank(groupName)? 'test Group - ' + System.now() : groupName;
			if(isPrivate){
				newGroup.CollaborationType='Private';
			}else{
				newGroup.CollaborationType='Public';
			}
			if(isArchived){
				newGroup.isArchived=true;
			}else{
				newGroup.isArchived=false;
			}
			newGroup.InformationTitle ='Title';
			newGroup.InformationBody = 'Information';
			newGroup.Description='TestDescription';
			newGroup.IsAutoArchiveDisabled=true;
			
			insert newGroup;
		}
		System.assert(newGroup.id!=null,'Running as expected');
		return newGroup;
	}
	
	public static Carousel_Content__c createCarousel(String siteId, String contentId){
		Carousel_Content__c carousel=null;
		carousel= new Carousel_Content__c();
		carousel.Simpplr_Content__c=contentId;
		carousel.Site__c=siteId;
		carousel.Order__c=1;
		carousel.Is_Deleted__c=false;
		insert carousel;
		System.assert(carousel!=null,'Running as expected');
		return carousel;
	}
    
    public static Carousel_Content__c createCarousel(String siteId, String contentId, String type, String socialCampaignId){
		Carousel_Content__c carousel=null;
		carousel= new Carousel_Content__c();
		carousel.Simpplr_Content__c=contentId;
		carousel.Site__c=siteId;
		carousel.Order__c=1;
		carousel.Is_Deleted__c=false;
        carousel.Item_Type__c=type;
        carousel.Embedly_Response_JSON__c='{"title":"test"}';
        carousel.Social_Campaign__c=socialCampaignId;
		insert carousel;
		System.assert(carousel!=null,'Running as expected');
		return carousel;
	}
	/**
	*
	**/
	public static Simpplr_Site__c getSiteRecord(String groupId){
		List<Simpplr_Site__c> siteRecList = [Select s.SystemModstamp, s.Site_Type__c, s.Site_Links__c, s.Site_Config__c, s.Site_Category__c, s.OwnerId, s.Name, s.Metadata__c, s.Is_Featured__c, s.Is_Active__c, s.IsDeleted, s.Id, s.Dashboard_Settings__c, s.Dashboard_Layout__c, s.CreatedDate, s.CreatedById, s.Chatter_Group_Id__c, s.Carousel_Content__c, s.Landing_Page__c, s.Allow_Public_Contribution__c From Simpplr_Site__c s where s.Chatter_Group_Id__c=:groupId];
		System.assert(siteRecList.size()>0,'Running as expected');
		return siteRecList[0];
	}
	
	public static Simpplr_Site__c getSiteRecordWithName(String siteName){
		List<Simpplr_Site__c> siteRecList = [Select s.SystemModstamp, s.Site_Type__c, s.Site_Links__c, s.Site_Config__c, s.Site_Category__c, s.OwnerId, s.Name, s.Metadata__c, s.Is_Featured__c, s.Is_Active__c, s.IsDeleted, s.Id, s.Dashboard_Settings__c, s.Dashboard_Layout__c, s.CreatedDate, s.CreatedById, s.Chatter_Group_Id__c, s.Carousel_Content__c, s.Landing_Page__c, s.Allow_Public_Contribution__c From Simpplr_Site__c s where s.name=:siteName];		
		System.assert(siteRecList.size()>0,'Running as expected');
		return siteRecList[0];
	}

	public static Site_Role__c createSiteRole(String peopleId, String siteId){
		Site_Role__c siterole = new Site_Role__c(
			is_Member__c = false,
			people__c = peopleId,
			site__c = siteId
		);
		insert siterole;
		return siterole;
	}
	
	public static Site_Role__c createSiteRole(String peopleId, String siteId, Boolean isManager, Boolean isMember){
		Site_Role__c siterole = new Site_Role__c(
			is_Member__c = (isManager || isMember),
			is_Manager__c = isManager,
			people__c = peopleId,
			site__c = siteId
		);
		insert siterole;
		return siterole;
	}
	
	public static void updateGroupType(String groupId,String siteType){
		CollaborationGroup grpRec = [select id,CollaborationType from CollaborationGroup where id=:groupId];
		grpRec.CollaborationType = siteType;
		update grpRec;
	}
	
	/**
	*
	**/
	public static CollaborationGroupMemberRequest createCollaborationGroupMemberRequest(Id cgId, String userId){
        System.assert(true, 'Running as Expected');
        CollaborationGroupMemberRequest obj = new CollaborationGroupMemberRequest(
                                                    CollaborationGroupId=cgId, RequesterId=userId);
         try{
            Database.SaveResult sr = Database.insert(obj, false);
            System.assert(sr.isSuccess(), 'Running as Expected');
            return obj;
        }catch(DmlException e){
            throw e;
        }
    }

	public static Site_Membership_Request__c createSiteMembershipRequest(string siteId, CollaborationGroupMemberRequest cgmr, string peopleId){
        System.assert(true, 'Running as Expected');
        Site_Membership_Request__c obj = new Site_Membership_Request__c(
                                                    User__c = cgmr.RequesterId,
													Status__c = 'Pending', 
													Site__c = siteId, 
													Request_By__c = peopleId);
         try{
            Database.SaveResult sr = Database.insert(obj, false);
            System.assert(sr.isSuccess(), 'Running as Expected');
            return obj;
        }catch(DmlException e){
            throw e;
        }
    }
    
    /**
	*
	**/
    public static CollaborationGroupMember createCollaborationGroupMember(Id groupId, String userId){
        CollaborationGroupMember obj = new CollaborationGroupMember(CollaborationGroupId=groupId, MemberId=userId);
        try{
            Database.SaveResult sr = Database.insert(obj, false);
            System.assert(sr.isSuccess(), 'Running as Expected');
            return obj;
        }catch(DmlException e){
            throw e;
        }
    }
    
    public static CollaborationGroupMember removeCollaborationGroupMember(Id groupId, String userId){
        CollaborationGroupMember obj = [select id from CollaborationGroupMember where CollaborationGroupId=:groupId and MemberId=:userId];
        try{
            Database.DeleteResult dr = Database.delete(obj, false);
            System.assert(dr.isSuccess(), 'Running as Expected');
            return obj;
        }catch(DmlException e){
            throw e;
        }
    }
    
    public static CollaborationGroupMember createCollaborationGroupMember(Id groupId, String userId, String role){
        CollaborationGroupMember obj = new CollaborationGroupMember(CollaborationGroupId=groupId, MemberId=userId, CollaborationRole=role);
        try{
            Database.SaveResult sr = Database.insert(obj);
            System.assert(sr.isSuccess(), 'Running as Expected');
            return obj;
        }catch(DmlException e){
            throw e;
        }
    }
    
    public static Event_RSVP_Response__c createRSVPResponse(String contentId, String peopleId, String response){
        Event_RSVP_Response__c obj = new Event_RSVP_Response__c();
        obj.Content__c = contentId;
        obj.people__c  = peopleId;
        obj.RSVP_Response__c=response;
        try{
            insert obj;
            return obj;
        }catch(DmlException e){
            throw e;
        }
    }
	/**
	*
	**/ 
    public static String getLongText() {
        String s='';
        //Reverting 131070 to 32767 as it is causing Apex CPU time limit exceeded
        while(s.length() <= 32767) {
            s+=' ' + wordArray;
        }
        System.assert(s!=null, 'Running as Expected');
        return s;
    }
    
    public static People_Preference__c createPeoplePreference(String peopleId){
    	
        People_Preference__c peoplePreference = insertPeoplePreference
            (new People_Preference__c(Name = 'SimpplrUserPref',People__c = peopleId, 
            								box_user_id__c = '001',
            								Box_Access_Token__c = 'DummyValue',
                                            Box_Access_Token_Expires_At__c = DateTime.now().addHours(5),
                                            Box_Enterprise_Id__c = '17077211',
                                            Box_Refresh_Token__c ='DummyValue', 
                                            Box_Refresh_Token_Expires_At__c = DateTime.now().addHours(5),
											Allow_Simpplr_Emails__c = true,
											Email_My_Content_Like_Or_Share__c = true,
									        User__c = UserInfo.getUserId()));
		
        System.assert(true, 'Running as Expected');
        return peoplePreference;
    }

	public static People_Preference__c createPeoplePreference(String peopleId, String userId){
    	
        People_Preference__c peoplePreference = insertPeoplePreference
            (new People_Preference__c(Name = 'SimpplrUserPref',People__c = peopleId, 
            								box_user_id__c = '001',
            								Box_Access_Token__c = 'DummyValue',
                                            Box_Access_Token_Expires_At__c = DateTime.now().addHours(5),
                                            Box_Enterprise_Id__c = '17077211',
                                            Box_Refresh_Token__c ='DummyValue', 
                                            Box_Refresh_Token_Expires_At__c = DateTime.now().addHours(5),
											Allow_Simpplr_Emails__c = true,
											Email_My_Content_Like_Or_Share__c = true,
									        User__c = userId));
		
        System.assert(true, 'Running as Expected');
        return peoplePreference;
    }
    
    public static People_integration__c createPeopleIntegRecordForUser(String peopleId){
    	People_integration__c peopleIntegRecord = new People_integration__c(name='googledrive',Access_Token_Expiry__c=3600,Access_Token_Requested_Datetime__c=datetime.now(),
    												Access_Token__c='ya29.GlzbBQmAF2CrRrVtbEd1yKHpJnq0zGvg3KlnSmOkZeTFD0PtMCQKbMK0vdxGrYY25at-6PVdVl-5UGOcypbApeYb45P7HslRMZ3QyMNXDpeBBaYfFnEAJn76XVBJpg',
    												Is_Deleted__c=false,People__c=peopleId,Refresh_Token__c='1/WierSYlxSUvVp3hvfPI68pladl5W9Z_L0-R0doJa3fA',Token_Type__c='Bearer',
    												User_Email__c=UserInfo.getUserEmail(),User_Name__c='User One',Connected__c=true);
    	insert peopleIntegRecord;
    	
    	return peopleIntegRecord;
    }
    
	public static People_integration__c createPeopleIntegRecordForUser(String peopleId, String integrationType, String appIntegId){
    	People_integration__c peopleIntegRecord = new People_integration__c(name=integrationType,Access_Token_Expiry__c=3600000,Access_Token_Requested_Datetime__c=datetime.now(),
    												Access_Token__c='ya29.GlzbBQmAF2CrRrVtbEd1yKHpJnq0zGvg3KlnSmOkZeTFD0PtMCQKbMK0vdxGrYY25at-6PVdVl-5UGOcypbApeYb45P7HslRMZ3QyMNXDpeBBaYfFnEAJn76XVBJpg',
    												Is_Deleted__c=false,People__c=peopleId,Refresh_Token__c='1/WierSYlxSUvVp3hvfPI68pladl5W9Z_L0-R0doJa3fA',Token_Type__c='Bearer',
    												User_Email__c=UserInfo.getUserEmail(),User_Name__c='User One',Connected__c=true, App_Integration__c=appIntegId);
    	insert peopleIntegRecord;
    	
    	return peopleIntegRecord;
    }

    public static void updatePeopleIntegRec(String pplintegId,String appIntegId){
    	People_integration__c peopleIntegRecord = new People_integration__c(id=pplintegId);
    	peopleIntegRecord.app_integration__c = appIntegId;
    	update peopleIntegRecord;
    }
    
    public static People__c createPeopleRecordForUser(String userId){
    	List<User> listofUsers = [SELECT UserType,AboutMe,City,CommunityNickname,CompanyName,Country,Department,Division,Email,EmployeeNumber,Extension,Fax,FirstName,LastName,ManagerId,MobilePhone,Phone,PostalCode,State,Street,Title, isActive, CreatedDate, 
				AboutMe__c, City__c, CommunityNickname__c, CompanyName__c, Country__c, Department__c, Division__c, Email__c, Extension__c, EmployeeNumber__c, FirstName__c, Fax__c, LastName__c, MobilePhone__c, Phone__c, PostalCode__c, State__c, Street__c, Title__c, Show_Simpplr__c,
		 		Dashboard_Layout__c, RssData__c, Sync_Whitelisted__c, Hide_Simpplr__c, Blog_CS_Enabled__c from User where id=:userId];
    	PeopleDao peopleDaoObj = new PeopleDao();
    	People__c peopleObj = peopleDaoObj.insertPeople(listofUsers)[0];
        peopleObj.App_Moderation_Permission__c='Yes';
        peopleObj.Campaign_Moderation_Permission__c='Yes';
    	peopleObj.Mobile_Token_Android__c = 'tk_VL79XkEN8Pp7IVbcPydT7rMZECKh2s2oolAx';
    	peopleObj.Mobile_Token_IOS__c = 'tkI_VL79XkEN8PoIVbcPydT7rMZECKh2s2oolAx';
    	peopleObj.Joining_Date__c = Date.today().addYears(-4);
    	peopleObj.Birth_Date__c = Date.today().addYears(22);
		peopleObj.Employee_Number__c = '123';
		peopleObj.Custom_Field_1__c = '123';
    	update peopleObj;
    	peopleObj.Leadership_Sequence__c = 0;
    	return peopleObj;
    }
	public static People__c getPeopleRecordForUser(String userId){
		List<People__c> peopleList = [SELECT id, name,User__r.Email, User__r.LanguageLocaleKey FROM People__c WHERE User__c =:userId];
		People__c peopleObj;
		if(peopleList.size()>0){
			peopleObj = peopleList[0];
		}
		return peopleObj;

	}
    
    private static People_Preference__c insertPeoplePreference(People_Preference__c peoplePreference){
        try{
            insert peoplePreference;
            return peoplePreference;
        }catch(DmlException e){
            throw e;
        }
    }
    public static ContentVersion createContentVersion(String origin){
        System.assert(true, 'Running as Expected');
        return insertContentVersion(new ContentVersion
                (
                    VersionData=Blob.valueOf('TestData'), PathOnClient='Test.jpg', Origin = origin, 
                    Title='Test', OwnerId=UserContext.id,Description='Test'
                ));
    }
    private static ContentVersion insertContentVersion(ContentVersion objContentVersion){
        try{
            insert objContentVersion;
            System.assert(true, 'Running as Expected');
            return objContentVersion;
        }catch(DmlException e){
            throw e;
        }
    }
    
    public static App_Notification__c createSimpplrNotification(String guid, String peopleId, String actionStatus, String subType,
                                                                    String objectId, String parentId){
        System.assert(true, 'Running as Expected');
        App_Notification__c notiObj = new App_Notification__c
                (
                    GUID__c = guid, Is_Read__c=false, Sent_To__c=peopleId,Sent_By__c=peopleId, Type__c='Information', sub_type__c=subType, Object_Type__c='Simpplr Content', 
                    Object_Id__c = objectId,  Submitter_Comment__c ='Some Comments', is_Deleted__c=false, Parent__c=parentId
				);
				
		if('Like'.equalsIgnoreCase(subType)) {
			notiObj.category__c='Content_Like';
		}
		List<App_Notification__c> notiList = insertSimpplrNotifications(new List<App_Notification__c>{notiObj});
        return notiList[0];
    }

    public static List<Ungrouped_Notification__c> createSimpplrUnGroupedNotifications(String peopleId){
        List<Ungrouped_Notification__c>  listOfUngroupedNotif= new List<Ungrouped_Notification__c>();
        Ungrouped_Notification__c notiObj1 = new Ungrouped_Notification__c(GUID__c = '3456899', 
                Is_Read__c=false, Is_New__c = true, Sent_To__c=peopleId, Sent_By__c=peopleId, 
                Type__c='Information', snippet__c = 'test blah blah',
                Category__c='Like_My_Reply', Object_Type__c='FeedComment', 
                Object_Id__c = '23456788', is_Deleted__c=false );

        Ungrouped_Notification__c notiObj2 = new Ungrouped_Notification__c(GUID__c = '908765555', 
                Is_Read__c=false, Sent_To__c=peopleId,Sent_By__c=peopleId, Type__c='Information', 
                Object_Type__c='FeedComment',Is_New__c = true, Object_Id__c = '23456788',  
                is_Deleted__c=false, snippet__c = 'test blah blah');
        listOfUngroupedNotif.add(notiObj1);
        listOfUngroupedNotif.add(notiObj2);                                                           
        insert  listOfUngroupedNotif;
        return listOfUngroupedNotif;
    }
    
    public static List<App_Notification__c> insertSimpplrNotifications(List<App_Notification__c> notiList){
        try{
            insert notiList;
            System.assert(true, 'Running as Expected');
            return notiList;
        }catch(DmlException e){
            throw e;
        }
    }
    
    public static Site_Category__c createSiteCategory() {
		Site_Category__c siteCatObj;
		 
		siteCatObj = new Site_Category__c();	
        siteCatObj.name = 'SiteCatName';
        siteCatObj.Name__c = 'SiteCatName';
        siteCatObj.Access__c = 'all';
        siteCatObj.Order__c = 0;
		siteCatObj.Is_Deleted__c = false;
		
		insert siteCatObj;
		return siteCatObj;
	}
	
	public static Simpplr_Social_Analytics__c createSocialAnalytics(String peopleId) {
		
		Topic newTopic = createTopic('createSocialAnalyticsForSearch');
		Simpplr_Social_Analytics__c simSocAnalyticsObj = new Simpplr_Social_Analytics__c();
		simSocAnalyticsObj.Page_Name__c = 'profileabout';
		simSocAnalyticsObj.People_Profile__c = peopleId;
		simSocAnalyticsObj.topic_id__c = newTopic.id;
		simSocAnalyticsObj.Interaction__c = 'View';
		
		insert simSocAnalyticsObj;
		return simSocAnalyticsObj;
	}
	
	public static Simpplr_Social_Analytics__c createSocialAnalyticsForSearch(String searchText) {
		
		Simpplr_Social_Analytics__c simSocAnalyticsObj = new Simpplr_Social_Analytics__c();
		simSocAnalyticsObj.Page_Name__c = 'profileabout';
		simSocAnalyticsObj.Search_Text__c = searchText;
		simSocAnalyticsObj.Interaction__c = 'Search Stats';
		
		insert simSocAnalyticsObj;
		return simSocAnalyticsObj;
	}
	    
    public static List<App_Integration__c> createAppIntegrationRecords(Boolean isConnected, Set<String> integrationNameSet){
    	List<App_Integration__c> appIntList = new List<App_Integration__c>();
		Set<String> integrationWithEncryptedClientIdSecret = new Set<String> {
																IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW
															};
		for(String name : integrationNameSet){
		    App_Integration__c appIntObj = new App_Integration__c();
		    appIntObj.Access_Token_Expiration_Datetime__c = DateTime.now().addDays(20);
			if(integrationWithEncryptedClientIdSecret.contains(name)) {
				appIntObj.Client_Id__c = Utility.encryptFn(name + 'dummyclientid');
				appIntObj.Client_Secret__c = Utility.encryptFn(name + 'dummyclientsecret');
			} else {
				appIntObj.Client_Id__c = name + 'dummyclientid';
				appIntObj.Client_Secret__c = name + 'dummyclientsecret';
			}
		    appIntObj.App_Access_Token__c = name + 'dummyaccestoken';
			appIntObj.Endpoint_Url__c = 'https://' + name + '.com';
		    appIntObj.App_Access_Token__c = name + 'dummyaccestoken';
		    appIntObj.Integration_Enabled__c = isConnected; 
		    appIntObj.Connected__c = isConnected;
		    appIntObj.Name = name;
		    
		    appIntObj.Org_Id__c = UserInfo.getOrganizationId();
			appIntObj.User_Name__c = 'testuser';
			appIntObj.User_Email__c = 'testuser@' + name + '.test';
			appIntObj.Extra_Url_Parameters__c = '&extra=true';
			if(name.equalsIgnoreCase('dropbox')) {  
				appIntObj.DB_User_Client_Id__c = 'dropboxdummyuserclientid';
				appIntObj.DB_User_Client_Secret__c = 'dropboxdummyuserclientsecret';
				appIntObj.All_Company_Group_Id__c = 'g:dropboxgroupid';
			} else if(name.equalsIgnoreCase('gdrive')) {
				appIntObj.All_Company_Group_Id__c = 'allcompany@test.com';
			} else if(name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW)) {
				appIntObj.Extra_Url_Parameters__c = '[{"1":"test"}]';
			} else if(name.equalsIgnoreCase('slack')) {
				appIntObj.Is_Slack_Upgraded__c = true;
			}
			appIntObj.App_installed__c = true; 
			appIntObj.Token_Type__c = 'Bearer';  
   			appIntObj.External_Id__c = name + 'dummyexternalid';
   			appIntObj.Is_Deleted__c = false; 
   			appIntObj.Batch_Processing__c = false;
			appIntObj.Root_Folder_Id__c = name + 'dummyrootfolderid';
			appIntObj.Enterprise_Id__c = name + 'dummyenterpriseid';
			appIntObj.Access_Token_Requested_Datetime__c = DateTime.now();
		    appIntObj.Access_Token_Expiration_Datetime__c = DateTime.now().addDays(20);
			appIntObj.Access_Token_Expiry__c=3600;
			if(name.equalsIgnoreCase('googledrive') || name.equalsIgnoreCase('googlecalendar')) {
				appIntObj.Whitelist_Domain__c = '[{"domainName":"simpplr.com"}]';
			} else {
				appIntObj.Whitelist_Domain__c = 'simpplr.onmicrosoft.com';
			}
			appIntList.add(appIntObj);
		}
        
		insert appIntList;
		return appIntList;
    }
    
    
    public static List<People_Integration__c> createPeopleIntegrationRecords(List<App_Integration__c> appIntList, String peopleId, String myDriveId){
    	List<People_Integration__c> piList = new List<People_Integration__c>();
		for(App_Integration__c appIntObj : appIntList){
		    People_Integration__c piObj = new People_Integration__c();
		    piObj.Name = appIntObj.Name;
		    piObj.People__c = peopleId;
		    piObj.Access_Token_Requested_Datetime__c = DateTime.now();
		    piObj.Access_Token_Expiration_Datetime__c = DateTime.now().addDays(20);
		    piObj.App_Integration__c = appIntObj.id;
		    piObj.Access_Token__c = appIntObj.Name + 'dummypeopleaccesstoken';
		    piObj.Access_Token_Secret__c = appIntObj.Name + 'dummypeopleaccesstokensecret';
			piObj.Token_Type__c = 'Bearer';
			piObj.My_Drive_Id__c = appIntObj.Name + 'dummydriveid';
			piObj.External_Id__c = UserInfo.getUserId();
			piObj.Group_Id_Set__c = '';
			piObj.User__c = UserInfo.getUserId();
			piObj.User_Email__c = 'test@test.test';
			piObj.User_Name__c = 'test';
			piObj.Batch_Flag__c = false;
			piObj.Connected__c = appIntObj.Connected__c;
			piObj.My_Drive_Id__c = myDriveId;
			piObj.SP_Instance_Id__c = 'testInstance';
		    piList.add(piObj);
		}
		insert piList;
		return piList;
    }
    public static Social_Campaign__c createSocialCampaign(String peopleId){
    	Social_Campaign__c sc = new Social_Campaign__c();
    	sc.Description__c = 'Test';
    	sc.people__c = peopleId;
    	sc.Twitter_Share_Enabled__c = true;
    	sc.Linkedin_Share_Enabled__c = true;
    	sc.Facebook_Share_Enabled__c = true;
    	sc.Is_Active__c = true;
    	sc.url__c = 'https://testurl.com';
    	insert sc;
    	return sc;
    }
    
    public static List<Social_Campaign_Share__c> createSocialCampaignShareRecords(String peopleId, Social_Campaign__c sc, Set<String> integrationNameSet){
    	List<Social_Campaign_Share__c> scsList = new List<Social_Campaign_Share__c>();
    	for(String name:integrationNameSet){
    		Social_Campaign_Share__c scs = new Social_Campaign_Share__c();
    		scs.Social_Campaign__c = sc.id;
    		scs.External_Post_Id__c = sc.id;
    		scs.Network_Shared__c = name;
    		scs.People__c = peopleId;
    		scsList.add(scs);
    	}
    	insert scsList;
    	return scsList;
    }
    
   public static Like__c createContentLike(String contentId, String peopleId) {
    		Like__c likeObj = new Like__c();
    		likeObj.Content__c = contentId;
    		likeObj.People__c = peopleId;
    		likeObj.Like_Receiver__c = peopleId;
            insert likeObj;
    		return likeObj;
    } 

	public static FeedLike createFeedLike(String feedItemId, String commentId) {
		FeedLike likeObj = new FeedLike(FeedItemId=feedItemId, FeedEntityId=commentId);
		insert likeObj;
		return likeObj;
	}
    
    public static Like__c createFeedLike(String feedItemId, String feedCommentId, String peopleId) {
    		Like__c likeObj = new Like__c();
    		likeObj.Feed_Item_Id__c = feedItemId;
    		likeObj.Feed_Item_Comment_Id__c = feedCommentId;
    		likeObj.People__c = peopleId;
    		likeObj.Like_Receiver__c = peopleId;
    		likeObj.Like_Receiver__c = peopleId;
            insert likeObj;
    		return likeObj;
    } 
    
    public static Share__c createContentShare(String contentId, String peopleId) {
    		Share__c shareObj = new Share__c();
    		shareObj.Content__c = contentId;
    		shareObj.People__c = peopleId;
    		shareObj.Share_Receiver__c = peopleId;
        	insert shareObj;
    		return shareObj;
    } 
    
    public static Share__c createFeedShare(String feedItemId, String peopleId) {
    		Share__c shareObj = new Share__c();
    		shareObj.Feed_Item_Id__c = feedItemId;
    		shareObj.People__c = peopleId;
    		shareObj.Share_Receiver__c = peopleId;
        	insert shareObj;
    		return shareObj;
	} 
	
	public static Analytics_File__c createAnalyticsFile() {
		Analytics_File__c fileObj = new Analytics_File__c();
		insert fileObj;
		return fileObj;
	}
    
    public static Bookmark__c createContentBookmark(String contentId, String peopleId) {
    		Bookmark__c bookmarkObj = new Bookmark__c();
    		bookmarkObj.Simpplr_Content__c = contentId;
    		bookmarkObj.People__c = peopleId;
    		bookmarkObj.Bookmark_Receiver__c = peopleId;
        	insert bookmarkObj;
    		return bookmarkObj;
    } 
    
    public static Segment__c createSegment(String peopleId){
		Segment__c segmentRecord = new Segment__c(Name__c = 'Untitled Segment', Created_By_People__c = peopleId, 
												  Modified_By_People__c = peopleId,
												  Segment_Attribute_Value_JSON__c = '[{"name":"India","audienceCount":1},{"name":"US","audienceCount":1}, {"name":"United States","audienceCount":1}]');
    	insert segmentRecord;
    	return segmentRecord;
    }
    
    public static Audience__c createAudience(String segmentId){
		Audience__c audienceRecord = new Audience__c(Segment__c = segmentId, Has_Department_Condition__c = true, Audience_Rule_Json__c='[]');
    	insert audienceRecord;
    	return audienceRecord;
	}    

	public static Audience_Member__c createAudienceMember(String audienceId, String peopleId){
		Audience_Member__c audienceMember = new Audience_Member__c(
			Audience__c = audienceId,
			People__c = peopleId
		);
		insert audienceMember;
    	return audienceMember;
    }

	public static Audience__c createAudienceForADGroup(String adGroupId) {
		String audienceRuleJson = '[{"aDGroupSet":["' + adGroupId + '"]}]';
		Audience__c audienceObj = new Audience__c(Is_Created_From_AD_Groups__c = true, Audience_Rule_Json__c = audienceRuleJson);
		insert audienceObj;
		return audienceObj;
	}

	public static Active_Directory_Group__c createActiveDirectoryGroup() {
		Active_Directory_Group__c adGroupObj = new Active_Directory_Group__c(Name__c = 'AD Test', AD_Object_Id__c = 'AD1');
		insert adGroupObj;
		return adGroupObj;
	}

	public static Active_Directory_Group_Member__c createActiveDirectoryGroupMember(String adGroupId, String peopleId) {
		Active_Directory_Group_Member__c adGroupMemberObj = new Active_Directory_Group_Member__c(Active_Directory_Group__c = adGroupId,
			People__c = peopleId);
		insert adGroupMemberObj;
		return adGroupMemberObj;
	}
    
    public static Subscription__c createSubscription(String audienceId, String peopleId, String type){
		Subscription__c subscriptionRecord = new Subscription__c(Audience__c = audienceId, Created_By_People__c = peopleId, Modified_By_People__c = peopleId, Status__c = 'Pending', Type__c = type);
    	insert subscriptionRecord;
    	return subscriptionRecord;
	} 
	
	public static Subscription__c createSiteSubscription(String audienceId, String siteId, String type){
		Subscription__c subscriptionRecord = new Subscription__c(Audience__c = audienceId, Type__c = type, Action_Type__c = 'autofollow');
    	insert subscriptionRecord;
    	return subscriptionRecord;
	}
    
	public static Subscription__c createSiteSubscriptionByActionType(String audienceId, String siteId, String type, String actionType){
		Subscription__c subscriptionRecord = new Subscription__c(Audience__c = audienceId, Type__c = type, Action_Type__c = actionType);
    	insert subscriptionRecord;
    	return subscriptionRecord;
	}

    public static List<Subscription_Entity__c> createSiteSubscriptionEntityByStatus(String subscriptionId, String siteId, String status){
		List<Subscription_Entity__c> listOfSubscriptionEntity = new List<Subscription_Entity__c>();
		Subscription_Entity__c subscriptionEntityRecord = new Subscription_Entity__c(Subscription__c = subscriptionId, Processing_Required__c = true, Site__c = siteId, Status__c =  status);
    	listOfSubscriptionEntity.add(subscriptionEntityRecord);
    	insert listOfSubscriptionEntity;
    	return listOfSubscriptionEntity;
    } 	

    public static List<Subscription_Entity__c> createPrivateSiteSubscriptionEntity(String subscriptionId, String siteId){
		List<Subscription_Entity__c> listOfSubscriptionEntity = new List<Subscription_Entity__c>();
		Subscription_Entity__c subscriptionEntityRecord = new Subscription_Entity__c(Subscription__c = subscriptionId, Processing_Required__c = true, Site__c = siteId, Status__c =  'Pending');
    	listOfSubscriptionEntity.add(subscriptionEntityRecord);
    	insert listOfSubscriptionEntity;
    	return listOfSubscriptionEntity;
    }  

	public static ConnectApi.FeedElement getFeedElement(String url) { 
		ConnectApi.FeedItem connectAPIFeedItemObj = new ConnectAPI.FeedItem(); 
		connectAPIFeedItemObj.OriginalFeedItem = new ConnectApi.Reference();
		connectAPIFeedItemObj.type = ConnectApi.FeedItemType.TextPost;
		connectAPIFeedItemObj.feedElementType = ConnectApi.FeedElementType.FeedItem;
		connectAPIFeedItemObj.photoUrl = 'https://photourl/005';
		connectAPIFeedItemObj.header = getConnectApiMessageBody();
		connectAPIFeedItemObj.body = new ConnectApi.FeedBody();
		connectAPIFeedItemObj.body.messageSegments = connectAPIFeedItemObj.header.messageSegments;		
		connectAPIFeedItemObj.capabilities =  getConnectApiFeedCapabilities(url);
		connectAPIFeedItemObj.parent = getConnectApiUserDetail();
		connectAPIFeedItemObj.actor = getConnectApiUserDetail();
		connectAPIFeedItemObj.isSharable = true;
		connectAPIFeedItemObj.isDeleteRestricted = false;
		connectAPIFeedItemObj.originalFeedItemActor = getConnectApiUserDetail();
		connectAPIFeedItemObj.createdDate = DateTime.now();
		return (connectAPIFeedItemObj);
	}            
    
	public static ConnectApi.FeedElementCapabilities getConnectApiFeedCapabilities(String url) {
		ConnectApi.FeedElementCapabilities capabilities = new ConnectApi.FeedElementCapabilities();
		capabilities.link = new ConnectApi.LinkCapability();
		capabilities.link.url = url == null ? '/apex/' : url;
		capabilities.link.urlName = 'DummyURL';

		capabilities.poll = new ConnectApi.PollCapability();
		capabilities.Poll.choices = new List<ConnectApi.FeedPollChoice>();
		capabilities.Poll.totalVoteCount = 0;
		capabilities.Poll.myChoiceId = '123';
		ConnectApi.FeedPollChoice choice = new ConnectApi.FeedPollChoice();
		choice.voteCountRatio = 10;
		capabilities.Poll.choices.add(choice);

		capabilities.Files = new ConnectApi.FilesCapability();
		ConnectApi.Content contObj = new ConnectApi.Content();
		contObj.id = '069';
		contObj.fileSize = '100';
		contObj.fileExtension = 'pdf';
		capabilities.Files.items = new List<ConnectApi.Content>();
		capabilities.Files.items.add(contObj);

		capabilities.comments = getConnectApiCommentsCapability();

		capabilities.Topics = new ConnectApi.TopicsCapability();
		ConnectApi.Topic connectApiTopic = new ConnectApi.Topic();
		connectApiTopic.id = '0TO61000000PkgvGAC'; 
		connectApiTopic.name = 'Topic'; 
		capabilities.Topics.items = new List<ConnectApi.Topic>();
		capabilities.Topics.items.add(connectApiTopic); 

		capabilities.chatterLikes = new ConnectApi.ChatterLikesCapability();
		capabilities.chatterLikes.page = new ConnectApi.ChatterLikePage();
		capabilities.chatterLikes.page.items = new List<ConnectApi.ChatterLike>();

		capabilities.trackedChanges = new  ConnectApi.TrackedChangesCapability();

		return capabilities;
	}

	public static ConnectApi.CommentsCapability getConnectApiCommentsCapability() {
		ConnectApi.CommentsCapability commentsCapabilityObj = new ConnectApi.CommentsCapability();
		commentsCapabilityObj.page = new ConnectApi.CommentPage();
		commentsCapabilityObj.page.items = new List<ConnectApi.Comment>();
		commentsCapabilityObj.page.total = 1;
		
		ConnectApi.Comment connectAPICommentObj = new ConnectApi.Comment();
		connectAPICommentObj.capabilities = new ConnectApi.CommentCapabilities();
		connectAPICommentObj.capabilities.content = new ConnectApi.ContentCapability();
		connectAPICommentObj.capabilities.content.id = '069';
		connectAPICommentObj.capabilities.content.fileExtension = 'pptx';
		connectAPICommentObj.capabilities.content.fileSize = '100';
		connectAPICommentObj.body = new ConnectApi.FeedBody();
		connectAPICommentObj.isDeleteRestricted = false;
		connectAPICommentObj.body.messageSegments = getMessageSegments();
		connectAPICommentObj.body.text = 'Test';

		connectAPICommentObj.user = new ConnectApi.UserSummary();
		connectAPICommentObj.user.photo = new ConnectApi.Photo();
		connectAPICommentObj.user.id = UserInfo.getUserId();
		connectAPICommentObj.user.name = 'Simpplr';

		connectAPICommentObj.likes = new ConnectApi.ChatterLikePage();
		connectAPICommentObj.likes.total = 100;
		commentsCapabilityObj.page.items.add(connectAPICommentObj);


		return commentsCapabilityObj;
	}

	public static ConnectApi.UserDetail getConnectApiUserDetail() {
		ConnectApi.UserDetail userDetailObj = new ConnectApi.UserDetail();
		userDetailObj.id = '0055f000003CKcF';
		userDetailObj.name = 'Test';
		return userDetailObj;
	}

	public static ConnectApi.Reference getConnectApiReference(String id, String url) {
		ConnectApi.Reference referenceObj = new ConnectApi.Reference();
		referenceObj.id = id;
		referenceObj.url = url;
		return referenceObj;
	}

	public static ConnectApi.MessageBody getConnectApiMessageBody() {						
		ConnectApi.MessageBody message = new ConnectApi.MessageBody();			
		message.messageSegments = getMessageSegments();
		return message;
	}

	public static List<ConnectApi.MessageSegment> getMessageSegments() {
		ConnectApi.TextSegment textSegment;
		ConnectApi.HashtagSegment hashSegment;
		ConnectApi.LinkSegment linkSegment;
		ConnectApi.EntityLinkSegment entityLinkSegment;
		ConnectApi.MentionSegment mentionSegment;
		ConnectApi.MarkupBeginSegment markupBeginSegment;
		ConnectApi.MarkupEndSegment markupEndSegment;
		ConnectApi.InlineImageSegment inlineSegment;

		List<ConnectApi.MessageSegment> messageSegments = new List<ConnectApi.MessageSegment>();						
		markupBeginSegment = new ConnectApi.MarkupBeginSegment();
		markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
		messageSegments.add(markupBeginSegment);
		
		textSegment = new ConnectApi.TextSegment();
		textSegment.text = 'created the public group';
		messageSegments.add(textSegment);
		
		mentionSegment = new ConnectApi.MentionSegment();
		mentionSegment.name = 'Test'; 
		mentionSegment.record = new ConnectApi.ChatterGroupDetail();
		mentionSegment.record.id = '0F94N0000006wbASAQ';
		mentionSegment.record.name = 'Test';
		messageSegments.add(mentionSegment);

		mentionSegment = new ConnectApi.MentionSegment();
		mentionSegment.name = 'Test'; 
		mentionSegment.record = new ConnectApi.ChatterGroupSummary();
		mentionSegment.record.id = '0F94N0000006wbASAQ';
		mentionSegment.record.name = 'Test';
		messageSegments.add(mentionSegment);

		mentionSegment = new ConnectApi.MentionSegment();
		mentionSegment.name = 'Test User'; 
		mentionSegment.record = getConnectApiUserDetail();
		messageSegments.add(mentionSegment);

		mentionSegment = new ConnectApi.MentionSegment();
		mentionSegment.name = 'Test User'; 
		mentionSegment.record = new ConnectApi.UserSummary();
		mentionSegment.record.id = UserInfo.getUserId();
		mentionSegment.record.name = 'Test';
		messageSegments.add(mentionSegment);
		
		textSegment = new ConnectApi.TextSegment();
		textSegment.text = '!';
		messageSegments.add(textSegment);
		
		markupEndSegment = new ConnectApi.MarkupEndSegment();
		markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
		messageSegments.add(markupEndSegment);

		entityLinkSegment = new ConnectApi.EntityLinkSegment();
		entityLinkSegment.reference = getConnectApiReference('https://www.simpplr.com', '0F94N0000006wbASAQ');
		messageSegments.add(entityLinkSegment);

		entityLinkSegment = new ConnectApi.EntityLinkSegment();
		entityLinkSegment.reference = getConnectApiReference('https://www.simpplr.com', '0D5');
		messageSegments.add(entityLinkSegment);

		entityLinkSegment = new ConnectApi.EntityLinkSegment();
		entityLinkSegment.reference = getConnectApiReference('https://www.simpplr.com', Utility.getPeoplePrefix());
		messageSegments.add(entityLinkSegment);

		entityLinkSegment = new ConnectApi.EntityLinkSegment();
		entityLinkSegment.reference = getConnectApiReference('https://www.simpplr.com', UserInfo.getUserId());
		messageSegments.add(entityLinkSegment);

		entityLinkSegment = new ConnectApi.EntityLinkSegment();
		entityLinkSegment.reference = getConnectApiReference('https://www.simpplr.com', '069');
		messageSegments.add(entityLinkSegment);

		entityLinkSegment = new ConnectApi.EntityLinkSegment();
		entityLinkSegment.reference = getConnectApiReference('https://www.simpplr.com', '001');
		messageSegments.add(entityLinkSegment);

		inlineSegment = new ConnectApi.InlineImageSegment();		 
		inlineSegment.url = '/app?campaignId=123';
		messageSegments.add(inlineSegment);

		textSegment = new ConnectApi.TextSegment();
		textSegment.text = 'Test\u2063\uFEFF\u200b\uFEFF\u2063Test';
		messageSegments.add(textSegment);

		linkSegment = new ConnectApi.LinkSegment();		
		linkSegment.url = '\u2063\uFEFF\u200b\uFEFF\u2063/FileDetail?fileId=dummy&provider=gdrive&directory=dummy&fileName=%E2%80%8B%EF%BB%BF%E2%81%A3date+chnages.wmv&size=2';
		messageSegments.add(linkSegment);

		hashSegment = new ConnectApi.HashtagSegment();
		hashSegment.tag = 'Test';
		messageSegments.add(hashSegment);

		return messageSegments;
	}
	public static ConnectApi.Topic getConnectAPITopic() {
		ConnectApi.Topic connectApiTopic = new ConnectApi.Topic();
		connectApiTopic.id = '0TO61000000PkgvGAC'; 
		connectApiTopic.name = 'Topic';
		return connectApiTopic;
	}
    
	public static Alert__c createAlert(Id peopleId, Datetime datetimeVal) {
		Alert__c alertRec = new Alert__c(Alert_Message__c = 'test message', Author__c = peopleId, Display_To_DateTime__c = datetimeVal);
		insert alertRec;
		return alertRec;
	}

	public static People_Category__c createPeopleCategory(String categoryName) {
		People_Category__c categoryRec = new People_Category__c(Name__c = categoryName);
		insert categoryRec;
		return categoryRec;
	}

	public static void shareSitesToAllPeople(List<String> siteIds) {
		List<Simpplr_Site__Share> shareObjList = new List<Simpplr_Site__Share>();
		String allInternalUserGroupId = Utility.getUserGroupId('AllInternalUsers');
		for(String siteId : siteIds) {
			Simpplr_Site__Share shareObj = new Simpplr_Site__Share();
			shareObj.ParentID = siteId;
			shareObj.AccessLevel='Edit';
			shareObj.RowCause = Schema.Simpplr_Site__Share.RowCause.Manual;
			shareObj.UserOrGroupId = allInternalUserGroupId;
			shareObjList.add(shareObj);
		}
        insert shareObjList;
	}
	
	/**
	 * @description shareContentsToAllPeople - make content editable to all user
	 * @param contentIds
	 */
	public static void shareContentsToAllPeople(List<String> contentIds) {
		List<Simpplr_Content__Share> shareObjList = new List<Simpplr_Content__Share>();
		String allInternalUserGroupId = Utility.getUserGroupId('AllInternalUsers');
		for(String contentId : contentIds) {
			Simpplr_Content__Share shareObj = new Simpplr_Content__Share();
			shareObj.ParentID = contentId;
			shareObj.AccessLevel='Edit';
			shareObj.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
			shareObj.UserOrGroupId = allInternalUserGroupId;
			shareObjList.add(shareObj);
		}
        insert shareObjList;
	}

	/**
	 * @description createUserProvisioningConfig - creates record for User_Provisioning_Config__c
	 * @param sourceName - provisioning source
	 * @return createdRecord
	 */
	public static User_Provisioning_Config__c createUserProvisioningConfig(String sourceName) {
		User_Provisioning_Config__c upc = new User_Provisioning_Config__c();
		upc.Provisioning_Source__c = sourceName;
		insert upc;
		return upc;
	}

    /**
    * @description createContentTemplate - creates record for ContentTemplate(page Template)
    * @param name template name
    * @param type type page
    * @param title tittle of content template
    * @param siteId site id not applicable of system templates
    * @param categoryId page category id
    * @param primaryAuthor simpplr people record id
    * @param isSystem is system template flag
    * @return Content_Template__c new content template record
    **/
    public static Content_Template__c createContentTemplate(String name, String type, String title, String siteId, String categoryId, String primaryAuthor, Boolean isSystem) {
        
        Content_Template__c conTemp = new Content_Template__c(name__c = name, Type__c = type, 
        Is_Enabled__c = true, title__c = title, site__c = siteId, Is_System_Template__c = isSystem, Primary_Author__c = primaryAuthor, Pages_Category__c = categoryId);
        insert conTemp;

        System.assert(conTemp.id!=null, 'Running as Expected');
        return conTemp;
    }
	/**
	 * @description addTopicToContentTemplate - creates record in topic assignment
	 * @param topicId - topic Id, contentTemplateId-> template Id
	 */
	public static void addTopicToContentTemplate(String topicId, String contentTemplateId){
    	TopicAssignment topicAssignment = new TopicAssignment(TopicId=topicId,EntityId=contentTemplateId);
		insert topicAssignment;
	}
	/**
	 * @description addTopicToContentTemplate - creates inline image record in file object
	 * @param contentTemplateId-> template Id, repository - file storage location
	 */
	public static void createContentTemplateInlineImage(String contentTemplateId, String repository) {
    	File__c file = new File__c(is_deleted__c = false,title__c='InlineImage',Is_Title_Image__c=false, Location__c='inline', Content_Template__c = contentTemplateId, Title_Image_Type__c='', MIME_Type__c='image', Likes__c = 2, Repository__c = repository);
        insert file;
    }
	/**
	 * @description addTopicToContentTemplate - creates title image record in file object
	 * @param contentTemplateId-> template Id, imageType - type of image
	 */
	public static void createContentTemplateTitleImage(String contentTemplateId, String imageType) {
    	File__c file = new File__c(is_deleted__c = false,title__c='TitleImage',Is_Title_Image__c=true, Location__c='Cover', Content_Template__c = contentTemplateId, Title_Image_Type__c=imageType, MIME_Type__c='image', Likes__c = 2, Repository__c = 'intranet');
        insert file;
    }

    public static Ungrouped_Notification__c getUnGroupedNotificationsForMembershipRequest(String guid, String sentTo){
        Ungrouped_Notification__c notiObj1 = new Ungrouped_Notification__c(GUID__c = guid,
            Is_Read__c=false, Is_New__c = true, Sent_To__c=sentTo, Sent_By__c=sentTo,
            Type__c='Actionable', snippet__c = 'siteName',
            Category__c='Private_Site_Membership_Requests', Object_Type__c='CollaborationGroupMemberRequest',
            Object_Id__c = '123456789012345', is_Deleted__c=false);
        return notiObj1;
    }
}