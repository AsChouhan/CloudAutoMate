public with sharing class FeedUtility {
    
    public static ResponseWrapper buildResponseWrapper (String statusArg, String messageArg, Object resultArg) {
    	String resolvedMessage = MessageHelper.resolveMessage(messageArg);
    	
  		ResponseWrapper responseWrappObj = new ResponseWrapper();
  		responseWrappObj.status= statusArg;
  		responseWrappObj.message= resolvedMessage;
  		responseWrappObj.result = resultArg;
  		return responseWrappObj;
  	}
  	
  	public static String processNameToPreventXSS (String textForProcessing) {
  		textForProcessing = textForProcessing.replaceAll('<', '&lt;');
  		textForProcessing = textForProcessing.replaceAll('>', '&gt;');
  		return textForProcessing;
  	
  	}

	public static Boolean isContentGroupingRequired {get {

		if (mapOfPostedOnIdWithContent != null && !mapOfPostedOnIdWithContent.keySet().isEmpty()) {
			return true;
		
		} else {
			return false;
		}

	}set;}
	public static Map<id, Simpplr_content__c> mapOfPostedOnIdWithContent = new Map<id, Simpplr_content__c>();
	
	public static List<Simpplr_content__c> loadPostedOnDetails(String contentId) {

		Set<String> locationSet = new Set<String>{'cover', 'media'};
		DateTime dateTimeVariable = DateTime.now();
		String peopleId = UserContext.getCurrentUserInfo.Id;
		List<String>  allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		
		String query = 'SELECT id, Site__r.Name, Site__r.Landing_Page__c, Site__r.Id, Site__r.Allow_File_Upload_App_Permission__c, ' + 
				' Site__r.Title_Content_Version__c, '+
				' Site__r.Title_Content_Document__c, Site__r.Site_Type__c,Site__r.Is_Active__c,Site__c, Primary_Author__r.Full_Name__c, '+
				' Primary_Author__c, CreatedById, Title__c, Is_Published__c, Site__r.Chatter_Group_Id__c ,Is_Must_read__c, CreatedDate, '+
				' Primary_Author__r.User__r.SmallPhotoUrl, Display_Excerpt__c, Type__c, Album_Video_Count__c, Album_Allow_All_to_Upload__c, '+
				' Album_Image_Count__c, Event_Is_All_Day__c, Event_Start_DateTime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c, '+		
				' Pages_Category__c, Pages_Category__r.Name__c,Feed_Posts__c, Feed_Questions__c, Question_Answer_Enabled__c, '+
				' Publish_Start_DateTime__c, Last_Edited_DateTime__c, '+
				' (Select Id, createdDate from Must_Read_Content_Details__r Where People__c =:peopleId and Is_Deleted__c=false), '+
				' (SELECT Id, Content_Version__c, Content_Document__c, Title_Image_Type__c, Is_Title_Image__c, Thumbnail_URL__c, MIME_Type__c, '+
				' External_id__c, Video_Status__c, Video_provider__c, Repository__c '+
				' FROM File_Simpplr_Content__r WHERE Location__c IN: locationSet And Is_Deleted__c = false '+
				' ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, Order__c desc LIMIT 4), '+
				' (select Must_Read_Confirm_Count__c, Audience_Type__c, Removed_By_People__c, Content__r.Title__c from Must_Read_Audits__r '+
				' where Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >:dateTimeVariable )) '+
				' FROM Simpplr_Content__c WHERE Id=:contentId and (Type__c=\'BlogPost\' or Site__r.Show_In_Simpplr__c = true) And TYPE__c IN : allowedFeaturesInAppList AND Activated_By_Feature__c = true ';

		List<Simpplr_content__c> listOfSimpplrContent = database.query(query);
		if (!listOfSimpplrContent.isEmpty()) {
			mapOfPostedOnIdWithContent.put(listOfSimpplrContent[0].id, listOfSimpplrContent[0]);
		} 

		return listOfSimpplrContent;
	}	

	public static Boolean isSimpplrContentLink(String urlToProcess) {
		Boolean isSimpplrContentLink = false;
		if ((urlToProcess.containsIgnoreCase('SitePagesDetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Page')) ||
			(urlToProcess.containsIgnoreCase('SiteEventsDetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Event')) ||
			(urlToProcess.containsIgnoreCase('profileblogdetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Blog')) ||
			(urlToProcess.containsIgnoreCase('sitealbumdetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Album')) ||
			(urlToProcess.containsIgnoreCase('FileDetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('File')) || 
			(urlToProcess.containsIgnoreCase('articledetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Page')) ||
			(urlToProcess.containsIgnoreCase('albumdetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Album')) ||
			(urlToProcess.containsIgnoreCase('blogdetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Blog')) ||
			(urlToProcess.containsIgnoreCase('eventdetail?') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Event')) ||
			(urlToProcess.containsIgnoreCase('ProfileBlogPost') && 
			SimpplrContext.AllowedFeatures.containsIgnoreCase('Blog')) ||
			(urlToProcess.containsIgnoreCase('SiteContent')) ||
			(urlToProcess.containsIgnoreCase('app') && (urlToProcess.containsIgnoreCase('/blog/') || 
			urlToProcess.containsIgnoreCase('/event/') || urlToProcess.containsIgnoreCase('/album/') || 
			urlToProcess.containsIgnoreCase('/page/')))) { 

			isSimpplrContentLink = true;
		}
		return isSimpplrContentLink;
	}

	/**
	 * @description this method is used to collect all the chatter group ids from feed post, content or favorities feed post items
	 * @param ConnectApi.FeedElementPage
	 * @return List<String> ids of siteß
	 */
	public static List<String> getChatterIdFromFeedElement(List<ConnectApi.FeedElement> feedElementObjList) {
		List<String> chatterIdsList = new List<String>();
		for (ConnectApi.FeedElement feedElementObj : feedElementObjList) {
			if(feedElementObj.header != null) {
				for (ConnectApi.MessageSegment segmentObj : feedElementObj.header.messageSegments) {
					if (segmentObj instanceOf ConnectApi.EntityLinkSegment && (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith('0F9') 
						|| ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith('069'))) {
						chatterIdsList.add(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id);
					}
				}
			}

			if (feedElementObj.body != null) {
				List<ConnectApi.MessageSegment> listOfMessageSegment = feedElementObj.body.messageSegments;
				for (ConnectApi.MessageSegment segment : listOfMessageSegment) {
					if (segment instanceof ConnectApi.MentionSegment) {
						ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
						chatterIdsList.add(mentionSegment.record.id);
					}
				}
			}
		}
		return chatterIdsList;
	}
}