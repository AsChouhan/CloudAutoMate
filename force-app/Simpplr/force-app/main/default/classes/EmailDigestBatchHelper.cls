public class EmailDigestBatchHelper {
	public static final String KEY_VIEW_POLL_BUTTON = 'email.notification.digest.view_poll';
	public static final String KEY_VIEW_POST_BUTTON = 'email.notification.digest.view_post';
	public static final String KEY_COMMON_SALUTATION = 'email.common.salutation';
	public static final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';
	public static final String KEY_COPYRIGHT = 'email.common.footer.copyright';
	public static final String KEY_POWERED_BY = 'email.common.footer.powered_by';
	private static final String KEY_FILE_ATTACHED = 'email.common.file_attached';
	private static final String KEY_FILES_ATTACHED='email.common.file_attached_plural';
	
	public static List<Feed_Cache__c> listOfFeedItemWithMentionsInSimpplrMetadata;
	
	public static String baseUrl = SimpplrContext.salesforceBaseUrl;
	public static String INACTIVE = 'Inactive';

	public static Map<String,String> emailDigestPartMap = new Map<String, String>{
		'digestFinalBodyWithHeaderFooter' =>'<html> <head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection"> {0} <title>Followed you</title> </head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr><td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{8}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"></td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"><span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span></td> </tr> </table> </td> </tr> {3} </table> {9} <div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"><a href="{4}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{5}.</a><br>{6}</td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;">{7}<a href="http://simpplr.com" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;"> Simpplr</a>.</td> </tr> </table> </div> </div> </td></tr> </table> </body> </html>',

		//0= targetUser First Name 1=  digest Type  2=DigestItemRows 3= App Name
		'digestItemRowsWithGreetingHeader'=>' <tr><td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;">{0},<br>{1}</h2></td></tr>{2}</table></td></tr>',
		
		//0=FeedCreatorAvatarWithTitleAndFeedCreatedDate, 1=Feed Body ,2=digestLastTwoCommentsTable,3=view poll/post button
		'digestItemRows'=> '<tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: left; vertical-align: top;"><table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr> <td class="Post" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: 1px solid #eeeeee; border-collapse: collapse; border-radius: 5px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 10px 0; text-align: left; vertical-align: top;">{0}{1}{2}{3}</td></tr></table></td></tr>',
		
		//0= ProfileImage/Alphabet 1=title 2=body 3=digestLikeAndDateRow 4=viewLink 5=viewLink 6=digestOtherReplyTable 7=Primary color
		'digestPostTable'=>'<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; border-spacing: 0;"><tbody><tr>{0}<td valign="top" style="padding: 0 0 16px 16px;"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; border-spacing: 0; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; color: #333333;"><tbody>{1}{2}{3}<tr><td><table border="0" cellpadding="0" cellspacing="0" style="font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 12px; line-height: 8px; border: 1px solid #cccccc;"><tbody><tr><td width="28" height="28" valign="top" style="background: #{7};"><a href="{4}"><img src="'+EmailConstants.checkIcon+'" alt="" width="28" height="28" style="border: none;"></a></td><td><table cellspacing="0" cellpadding="0" border="0" align="left" style="padding:0;margin:0;line-height:1px; font-size:1px;"><tbody><tr><td bgcolor="#ffffff" align="center" style="padding: 0; margin: 0; line-height: 1px; font-size: 1px; line-height: 16px;"><a target="_blank" style="text-decoration: none; border-style: none; padding: 0; margin: 0; font-size: 12px; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; color: #{7}; text-decoration: none; padding: 5px 12px; border: 1px solid #FFFFFF; display: inline-block; font-weight: normal;" href="{5}">View</a></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table>{6}</td></tr></tbody></table>',		
		
		//ProfileImage/Alphabet 1=titleWithDateAndbody
		'fullReply' => ' <table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="Reply" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #eeeeee; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 10px 0; text-align: left; vertical-align: top;"><table width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr>{0}{1}</tr></table></td></tr></table>',
		
		//0=feed createddate
		'digestFeedCreateddDateRow' => ' <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="Post-date" style="color: #999; font-size: 12px;">{0}</span></td></tr>',
		
		//0= reply createddate
		'digestReplyCreateddDateRow' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="Reply-date" style="color: #999; font-size: 12px;">{0}</span></td></tr>',
		
		// 0= reply created by name, 1= reply created date, 2=reply body
		'replyHeaderWithNameDateAndBody' => ' <td class="Reply-header" v-align="middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; line-height: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-left: 10px; text-align: left; vertical-align: top;"><table width="500" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;">{0}{1}{2}</table></td>',
		
		//0=Header Title 1=Feed Created Date
		'feedHeaderTitleAndDateRow' => ' <td class="Post-header" v-align="middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; line-height: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-left: 10px; padding-top: 4px; text-align: left; vertical-align: top;"><table width="500" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;">{0}{1}</table></td>',
		
		//0=Avatar 1=HeaderTitleWithFeedCreatedDate
		'digestAvatarAndHeaderWithFeedCreatedDate'=>' <table width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr>{0}{1}</tr></table>',
				
		//0=BG color 1=Link to profile image
		'profileImage' => '<td width="40" valign="top"><span style="border-radius: 50%; overflow: hidden; display: block; max-width: 40px; max-height: 40px; border: none; text-decoration: none;"><table width="40" height="40" align="center" cellspacing="0" cellpadding="0" border="0" style="border-collapse: collapse; border-spacing: 0; background-color: #ffffff; padding: 0; margin: 0;"><tbody><tr><td width="40" height="40" align="center" valign="middle" style="background-color: #{0}; margin: 0; font-size: 18px; padding: 0; text-decoration: none; color: #ffffff; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;"><img src="{1}" alt="" width="40" height="40" style="border: none;"></td></tr></tbody></table></span></td>',
				
		'profileImageDigest' => '<td class="Post-avatar-cell" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top; width: 45px;"><img class="Post-avatar" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; border-radius: 50%; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 45px;" width="45" height="45"></td>',
		'replyProfileImageDigest' => '<td class="Reply-avatar-cell" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top; width: 35px;"><img class="Reply-avatar" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; border-radius: 50%; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 35px;" width="35" height="35"></td>',
		'contentBody' => '<table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="Post-attachments" style="color: #999; font-size: 14px;">{5}</span></td></tr></table>',
		'viewButton' => '<table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><center><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; box-sizing: border-box; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px !important;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td><td align="center" class="btn-spacer" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 15px; padding-top: 15px; text-align: left; vertical-align: top; width: 120px;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px;"><tbody><tr><td class="btn-inner" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{0}; border-collapse: collapse; border-radius: 4px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top; width: 120px;"><a href="{1}" target="_blank" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{0}; border: solid 1px #{0}; border-color: #{0}; border-radius: 5px; box-sizing: border-box; color: #ffffff; cursor: pointer; display: inline-block; font-size: 14px; font-weight: normal; margin: 0; padding: 5px 15px; text-decoration: none; width: 120px;">{2}</a></td></tr></tbody></table></td><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td></tr></table></center></td></tr></table>',
		'pollPostChoicesRow' => '<ol style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px; padding-left: 0;">{0}</ol>',
		'pollTextWithChoices' => '{0}{1}',
		'wholePostBody'=> '<table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="Post-body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">{0}</td></tr></table>'
	};


	public static String getDigestEmailBody(Set<String> feedCacheIdSet , 
			String digestType, People_Preference__c pplPreference, 
			Set<String> userColGrpSet, List<EntitySubscription> userEntSubList, 
			Set<String> cachedFeedItemIdSet, Set<String> commentFeedItemIdSet, 
			Integer frequency, String applicationName, 
			NotificationHelper.BrandingInfo brandingInfo) {
		String targetUserTimeZone = String.ValueOf(pplPreference.people__r.user__r.timeZonesidkey);
		String user = pplPreference.people__r.user__c;
        String feedItemJSON = '';
        String digestBody = '';
        Datetime dt= Datetime.now();
        ConnectApi.FeedElement feedItem;
        //Entity Subscription filter
        List<EntitySubscription> es = userEntSubList;
        Set<String> esSet = new Set<String>();

        for (EntitySubscription ess: es) {
            esSet.add(esS.parentId);
        }
        
        //applying filters to get feeditem id
        Integer digestLimitSize = EmailUtility.getDigestLimitSize(frequency);
        String queryFeedItem = ''; 

        if (SimpplrContext.feedMode == 'timeline_comment') {
            queryFeedItem = 'SELECT id, parentId, type, (SELECT Id, FeedItemId, ' + 
				    ' CreatedById, CreatedBy.Name FROM FeedLikes ORDER BY createdDate DESC)' + 
				    ' FROM FeedItem ' +
	    		    ' WHERE (parentId=\'' + user + '\' OR parentId IN: esSet OR parentId IN: userColGrpSet OR id IN: cachedFeedItemIdSet OR id IN: commentFeedItemIdSet) '+ 
        		    ' AND LastModifiedDate = LAST_N_DAYS:' + frequency + 
                    ' AND parent.Type=\'' + EmailUtility.getSimpplrContentObjName() + '\''+ 
                    ' AND type != \'LinkPost\' '; 

        } else {
            queryFeedItem = 'SELECT id, parentId, type, (SELECT Id, FeedItemId, ' + 
				    ' CreatedById, CreatedBy.Name FROM FeedLikes ORDER BY createdDate DESC)' + 
				    ' FROM FeedItem ' +
	    		    ' WHERE (parentId=\'' + user + '\' OR parentId IN: esSet OR parentId IN: userColGrpSet OR id IN: cachedFeedItemIdSet OR id IN: commentFeedItemIdSet) '+ 
        		    ' AND LastModifiedDate = LAST_N_DAYS:' + frequency + ' AND (parent.type=\'User\' OR parent.type=\'CollaborationGroup\' OR' + 
                    ' (parent.Type=\'' + EmailUtility.getSimpplrContentObjName() + '\' AND type != \'LinkPost\')) '; 
        }

        if (SimpplrContext.showTrackChangesFeedPosts == false) {
        	queryFeedItem += ' And type !=\'TrackedChange\' ';
        }

        if (SimpplrContext.isCommunitiesEnabled) {
			queryFeedItem += ' AND NetworkId = null ';
		}

        queryFeedItem += ' ORDER BY LastModifiedDate DESC LIMIT '+digestLimitSize;
        Map<String,FeedItem> fiMap = new Map<String,FeedItem>((List<FeedItem>)Database.query(queryFeedItem));
        Map<String, File__c> nativeVideoMap = new Map<String, File__c>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fiMap.keySet());
		String filesQuery = 'Select id, Title__c, Thumbnail_URL__c, External_Id__c from File__c where Feed_Item__c in :soqlParam1 and Repository__c = \'native_video\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

        for(File__c fileObj : listOfFile) {
            nativeVideoMap.put(fileObj.External_Id__c, fileObj);
        }
        Map<String, String> simpContentIdFeedIdMap = new Map<String, String>();
        
		for (FeedItem feedItemObj : fiMap.values()) {
			
			if (String.isNotBlank(feedItemObj.parentId) && 
					String.valueOf(feedItemObj.parentId).startsWithIgnoreCase(simpplrContentPrefix)) {
				simpContentIdFeedIdMap.put(feedItemObj.parentId, feedItemObj.id);
			}

        }

        Map<String,Simpplr_Content__c> simpContentMap = new Map<String,Simpplr_Content__c>();
        
		if (simpContentIdFeedIdMap.isEmpty() == false) {
			simpContentMap = new Map<String,Simpplr_Content__c>([select id, Title__c, Site__r.Chatter_Group_Id__c, Site__c, Primary_Author__r.Full_Name__c, Primary_Author__r.Email__c, Primary_Author__c, Type__c,Name  from Simpplr_content__c where id IN:simpContentIdFeedIdMap.keySet() And (Site__r.Site_type__c='Public' Or Site__r.Chatter_Group_Id__c =:userColGrpSet)]);
			//Remove content from Private Site
			
			for (String contentId:simpContentIdFeedIdMap.keySet()) {
				
				if(simpContentMap.containsKey(contentId) == false) {
					fiMap.remove(simpContentIdFeedIdMap.get(contentId));
				}

			}	

        }
        Map<String,Feed_Cache__c> simMetaDataValueJSONMap = getFeedItemValueMapFromSimpplrMetadata(fiMap.keySet(), frequency);
        List<Feed_Cache__c> feedMetadaInsertList = new List<Feed_Cache__c>();
        
		for (String feedItemId : fiMap.keySet()) {
				if (simMetaDataValueJSONMap.keySet().contains(feedItemId)) {
               
					if (simMetaDataValueJSONMap.get(feedItemId) != null && !simMetaDataValueJSONMap.get(feedItemId).Feed_Data__c.contains(ServiceConstants.RECOGNITION_FILE_SEPRATOR)) { // ignoring recognition posts, should be removed once get optimized solution
						digestBody = digestBody + getProcessedFeedBody( simMetaDataValueJSONMap.get(feedItemId).Feed_Data__c, fiMap.get(feedItemId), user, simpContentMap, targetUserTimeZone, brandingInfo, pplPreference, nativeVideoMap);
					}
	
				} else {
					
					if (!Test.isRunningTest()) {
						feedItem = ConnectApi.ChatterFeeds.getFeedElement(null,feedItemId);
					   
						if (feedItem != null) {
							feedItemJSON = JSON.serialize(feedItem);
							if(!feedItemJSON.contains(ServiceConstants.RECOGNITION_FILE_SEPRATOR)){ // ignoring recognition posts, should be removed once get optimized solution
								digestBody = digestBody + getProcessedFeedBody( feedItemJSON, fiMap.get(feedItemId), user, simpContentMap, targetUserTimeZone, brandingInfo, pplPreference, nativeVideoMap);
								List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
								Set<String> mentionedUserIdSet = getMentionedUserIdSet(messageSegments);
								Set<String> mentionedGroupIdSet = getMentionedGroupIdSet(messageSegments);
								Boolean isComment = false;
								String feedCommentId = '';
								
								if (feedCacheIdSet.contains(feedItemId) == false){
									feedCacheIdSet.add(feedItemId);
									feedMetadaInsertList.add(getCacheFeedElement(feedItemJSON , mentionedUserIdSet, mentionedGroupIdSet, feedItemId, isComment, feedCommentId, feedItem.parent.id));
								}
							}
						}
	
					}
	
				}
			}

        try {
	        
			if (feedMetadaInsertList.size()>0 && !Test.isRunningTest()) {

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(feedMetadaInsertList, new List<Schema.SObjectField>{
					Feed_Cache__c.Feed_Id__c, 
					Feed_Cache__c.Parent_Id__c, 
					Feed_Cache__c.Feed_Data__c, 
					Feed_Cache__c.Mention_1__c, 
					Feed_Cache__c.Mention_2__c, 
					Feed_Cache__c.Mention_3__c,
					Feed_Cache__c.Mention_4__c, 
					Feed_Cache__c.Mention_5__c, 
					Feed_Cache__c.myFeedCacheRecord.Group_Mention_1__c,
					Feed_Cache__c.myFeedCacheRecord.Group_Mention_2__c,
					Feed_Cache__c.myFeedCacheRecord.Group_Mention_3__c,
					Feed_Cache__c.myFeedCacheRecord.Group_Mention_4__c,
					Feed_Cache__c.myFeedCacheRecord.Group_Mention_5__c,
					Feed_Cache__c.Feed_Item_Type__c, 
					Feed_Cache__c.Feed_Comment_Id__c});
	        }

        } catch (Exception e) {
        	
        }
        
        String digestItemRowsWithGreetingHeader='';
        
		if (String.isNotBlank(digestBody)) {
        	digestItemRowsWithGreetingHeader = getDigestItemRowsWithGreetingHeader(digestType, pplPreference.People__r.First_Name__c, pplPreference.People__r.Last_Name__c, applicationName,digestBody, new List<String>(), brandingInfo,pplPreference.User__r.languagelocalekey);
        }
        
        String digestFinalBodyWithHeaderFooter = '';
        
        if (String.isNotBlank(digestItemRowsWithGreetingHeader)) {
        	digestFinalBodyWithHeaderFooter = getDigestFinalBodyWithHeaderFooter(brandingInfo.logo_url, pplPreference,digestItemRowsWithGreetingHeader, brandingInfo);
        }

    	return digestFinalBodyWithHeaderFooter;
    }   
    
    
    //function to generate email HTML bodies from jsonFeedItem 
    public static String getProcessedFeedBody( String jsonFeedItem, FeedItem feedItemObj, String user, Map<String,Simpplr_Content__c> simpContentMap, 
    											String targetUserTimeZone,NotificationHelper.BrandingInfo brandingInfo, People_Preference__c pplPreference, Map<String, File__c> nativeVideoMap) {
        String languagelocalekey = Utility.getSimpplrLanguageLocaleKey(pplPreference.User__r.languagelocalekey);
        JSONFeedElementWrapper feedElementWrapperObj = JSONFeedElementWrapper.parse(jsonFeedItem);
		FeedDataAdapter.getUserIdsToConvert(feedElementWrapperObj);
		FeedDataAdapter.getPeopleFromUserIds();
        List<String> formatterList =  new List<String>();
        Boolean isReply = false;
        String postProfilePicOrImage = getProfileDisplayIcon(feedElementWrapperObj.actor.photo.standardEmailPhotoUrl,feedElementWrapperObj.actor.photo.photoVersionId,isReply); 
		
		String headerTitle = createEmailTitle( feedElementWrapperObj,simpContentMap.get(feedItemObj.parentId));
		headerTitle =  '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><a class="Post-name" href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #222; font-weight: bold; text-decoration: none;">'+headerTitle+'</a></td></tr>';
        
		String dateItem = addFeedCreatedDateToEmail(DateTime.ValueofGMT(feedElementWrapperObj.createdDate.replace('T', ' ')),languagelocalekey,targetUserTimeZone,formatterList);		
		String digestHeaderAndDateRow = getDigestHeaderAndDateRow(headerTitle,dateItem,formatterList);        
		
		String digestAvatarAndHeaderWithFeedCreatedDate = getDigestAvatarAndHeaderWithFeedCreatedDate(postProfilePicOrImage,digestHeaderAndDateRow,formatterList);
		
		String digestPostTable='';
		List<JSONFeedElementWrapper.MessageSegments> bodyMessSegment = feedElementWrapperObj.body.messagesegments;
		
		Boolean externalAppLinkForPost = false;
		Boolean externalAppLinkForComment = false;
		Boolean isPoll = false;

		String recognitionBody = '';
		Boolean isRecognitionFeed = false;
		for(JSONFeedElementWrapper.MessageSegments bodySegments : bodyMessSegment) {
            if(bodySegments.type =='Mention') {
                if(bodySegments.record.type == 'User') {
                    digestPostTable = digestPostTable +'<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" target="_blank" href=\"'+baseUrl + Page.PageRedirector.getUrl() + '?userId=' + bodySegments.record.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=de\">@'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.displayName)+' </a>'; 
                } else if(bodySegments.record.type == 'CollaborationGroup') {
                    digestPostTable = digestPostTable +'<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" target="_blank" href=\"'+baseUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + bodySegments.record.id + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=de\">@'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.name)+' </a>';
                	if(bodySegments.record.additionalLabel != null){
                    	if('Archived'.equalsIgnoreCase(bodySegments.record.additionalLabel)){
                    		digestPostTable = digestPostTable + '<span style="color:#999999;"> ('+INACTIVE+')</span>';
                    	}else if('Private'.equalsIgnoreCase(bodySegments.record.additionalLabel)){
                    		digestPostTable = digestPostTable +'<span style="color:#999999;"> ('+bodySegments.record.additionalLabel+')</span>';
                    	}else if('Unlisted'.equalsIgnoreCase(bodySegments.record.additionalLabel)){
                    		digestPostTable = digestPostTable +'<span style="color:#999999;"> ('+bodySegments.record.additionalLabel+')</span>';
                    	}
                    } 
                }
            }          
            if(bodySegments.type =='Text') {
            	String tempFeedBody = bodySegments.text;
                if('\n'.equalsIgnoreCase(tempFeedBody)){
                	tempFeedBody = '';
                }
                if(String.isNotBlank(tempFeedBody) && tempFeedBody.containsIgnoreCase(ServiceConstants.FEED_EXT_FILE_SEPRATOR)){
	            	externalAppLinkForPost = true;
	            	tempFeedBody = tempFeedBody.remove(ServiceConstants.FEED_EXT_FILE_SEPRATOR);	
	            	if(String.isBlank(tempFeedBody)){            	
	            		continue;
	            	}
                }

				//Process recognition body separately
				if(String.isNotBlank(tempFeedBody) && tempFeedBody.containsIgnoreCase(ServiceConstants.RECOGNITION_FILE_SEPRATOR)){
					isRecognitionFeed = true;
					tempFeedBody = tempFeedBody.remove(ServiceConstants.RECOGNITION_FILE_SEPRATOR); //remove recognition special
				}            	
            	digestPostTable = digestPostTable + tempFeedBody;
            }
            if(bodySegments.type =='Link') {
            	if(externalAppLinkForPost && bodySegments.url.containsIgnoreCase('provider=')){
            		String externalLinkBody = '';
            		externalLinkBody = getLinkEmailBody(bodySegments.url, brandingInfo);	
            		digestPostTable = digestPostTable + externalLinkBody;
            	} else{
					String feedUrl = baseUrl+Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=de';
                	digestPostTable = digestPostTable + getLinkEmailBody(bodySegments.url, bodySegments.text, brandingInfo, nativeVideoMap, feedUrl);
                }                	
            }
            if(bodySegments.type =='HashTag') {
            	if(feedElementWrapperObj.capabilities.topics.items.isEmpty()){
            		digestPostTable = digestPostTable + '#' + bodySegments.tag;
            	} else {
                	digestPostTable = digestPostTable + '<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" target="_blank" href=\"' + baseUrl+Page.PageRedirector.getUrl() + '?topicName=' + EncodingUtil.urlEncode(bodySegments.tag, 'utf-8')+ '&pageToRedirect=TopicFeed&origin=de\">#' + bodySegments.tag + ' </a>';
            	}
            }
            if(bodySegments.type =='MarkupBegin'){
            	digestPostTable = digestPostTable + '<'+bodySegments.htmlTag+'>';
            }
            if(bodySegments.type =='MarkupEnd'){
            	digestPostTable = digestPostTable + '</'+bodySegments.htmlTag+'>';	
            }
    	}


    	digestPostTable = '<p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;">'+digestPostTable+'</p>';

		//Process Recognition Body
		if(isRecognitionFeed){
			digestPostTable += NotificationHelper.getEmailRecognitionBody(feedItemObj.Id);
		}

		String pollBody = '';
        Map<String,String> pollChoiceMap = new Map<String,String>();
        if(feedElementWrapperObj.capabilities.poll != null) {
			isPoll = true;
            digestPostTable = getEmailPollBody(digestPostTable, feedElementWrapperObj.capabilities.poll.choices, feedElementWrapperObj.id, formatterList, brandingInfo);
        }
        
        String attchmentBody = '';
        if(feedElementWrapperObj.capabilities.files != null) {
        	digestPostTable = digestPostTable + getEmailFileBody(feedElementWrapperObj.capabilities.files.items, languagelocalekey);
        }
       String linkBody = '';
       if(feedElementWrapperObj.capabilities.Link != null) {
           digestPostTable = digestPostTable + getEmailLinkBody(feedElementWrapperObj.capabilities.Link, formatterList, brandingInfo); 
        }
        
		digestPostTable = String.format(emailDigestPartMap.get('wholePostBody'),new List<String>{digestPostTable});

        String viewLink = baseUrl+Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=de';
       
	   //last 3 comments
		String commentList ='';
        List<JSONFeedElementWrapper.Items_Z> commentItemsList = feedElementWrapperObj.capabilities.comments.page.items;
        for(JSONFeedElementWrapper.Items_Z  items : commentItemsList) {
			isReply = true;
        	String commentProfilePicOrAlphabet = getProfileDisplayIcon(items.user.photo.standardEmailPhotoUrl,items.user.photo.photoVersionId,isReply);
        	String title = '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><a class="Reply-name" href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #222; font-weight: bold; text-decoration: none;">'
                                +(FeedDataAdapter.mapUserIdToPeople.containsKey(items.user.id) ? FeedDataAdapter.mapUserIdToPeople.get(items.user.id).Full_Name__c : items.user.name)+'</a></td></tr>';

			//created date
	        String commentCreatedDate = addReplyCreatedDateToEmail(DateTime.ValueofGMT(items.createdDate.replace('T', ' ')),languagelocalekey,targetUserTimeZone,formatterList);		

        	String digestLastTwoCommentsTable = '';
            
            for( JSONFeedElementWrapper.MessageSegments_Y bodySegments: items.body.messageSegments) {
            	if(bodySegments.type =='Mention') {
                	if(bodySegments.record.type == 'User') {
                    	digestLastTwoCommentsTable = digestLastTwoCommentsTable +'<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" target="_blank" href=\"'+baseUrl + Page.PageRedirector.getUrl() + '?userId=' + bodySegments.record.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=de\">@'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.displayName)+' </a>';  
                    																																															
                    } else if(bodySegments.record.type == 'CollaborationGroup') {
                         digestLastTwoCommentsTable = digestLastTwoCommentsTable +'<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" target="_blank" href=\"'+baseUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + bodySegments.record.id + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=de\">'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.name)+' </a>';
                   		 if(bodySegments.record.additionalLabel != null){
	                    	if('Archived'.equalsIgnoreCase(bodySegments.record.additionalLabel)){
	                    		digestLastTwoCommentsTable = digestLastTwoCommentsTable + '<span style="color:#999999;"> ('+INACTIVE+')</span>';
	                    	}else if('Private'.equalsIgnoreCase(bodySegments.record.additionalLabel)){
	                    		digestLastTwoCommentsTable = digestLastTwoCommentsTable +'<span style="color:#999999;"> ('+bodySegments.record.additionalLabel+')</span>';
	                    	} else if('Unlisted'.equalsIgnoreCase(bodySegments.record.additionalLabel)){
	                    		digestLastTwoCommentsTable = digestLastTwoCommentsTable +'<span style="color:#999999;"> ('+bodySegments.record.additionalLabel+')</span>';
	                    	}
                    	} 
                    }
                }            
                if(bodySegments.type =='Text') {
                	String tempFeedBody = bodySegments.text;
                	if(('posted a file.'.equalsIgnoreCase(tempFeedBody)) || ('\n'.equalsIgnoreCase(tempFeedBody))){
                		tempFeedBody = '';
               		}                	
                	if(String.isNotBlank(tempFeedBody) && tempFeedBody.containsIgnoreCase(ServiceConstants.FEED_EXT_FILE_SEPRATOR)){
                		externalAppLinkForComment = true;
                		tempFeedBody = tempFeedBody.remove(ServiceConstants.FEED_EXT_FILE_SEPRATOR);
                		if(String.isBlank(tempFeedBody)){
                			continue;
                		}	
                	}
                	digestLastTwoCommentsTable = digestLastTwoCommentsTable + tempFeedBody;
                }
                if(bodySegments.type =='Link') {
	            	if(externalAppLinkForComment && bodySegments.url.containsIgnoreCase('provider=')){
	            		String externalLinkBody = '';
	            		externalLinkBody = getLinkEmailBody(bodySegments.url, brandingInfo);	
	            		digestLastTwoCommentsTable = digestLastTwoCommentsTable + externalLinkBody;
	            	} else{  
						String feedUrl = baseUrl+Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=de';
                		digestLastTwoCommentsTable = digestLastTwoCommentsTable + getLinkEmailBody(bodySegments.url, bodySegments.text, brandingInfo, nativeVideoMap, feedUrl);
	        		}                	
                }
                if(bodySegments.type =='HashTag') {
                	if(feedElementWrapperObj.capabilities.topics.items.isEmpty()){
                		digestLastTwoCommentsTable = digestLastTwoCommentsTable + '#' + bodySegments.tag;
                	} else {
                    	digestLastTwoCommentsTable = digestLastTwoCommentsTable + '<a style="color:#'+brandingInfo.general_primaryColor+';text-decoration:none;word-break:break-word;font-size:15px" target="_blank" href=\"' + baseUrl+Page.PageRedirector.getUrl() + '?topicName=' + EncodingUtil.urlEncode(bodySegments.tag, 'utf-8')+ '&pageToRedirect='+Pages.TopicFeed+'&origin=de\">#' + bodySegments.tag + ' </a>';
                	}
                }
            
            }
            
            digestLastTwoCommentsTable = ' <tr><td class="Reply-body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; line-height: 1.4; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;">'+ digestLastTwoCommentsTable +'</p></td></tr>';
            //attachment
       		String commentAttachBody ='';
            if(items.capabilities.content!= null) {
                commentAttachBody =  getEmailFileBody(new List<JSONFeedElementWrapper.Content>{items.capabilities.content}, languagelocalekey);
            }
            digestLastTwoCommentsTable = digestLastTwoCommentsTable + commentAttachBody;

			String replyHeaderWithNameDateAndBody = getReplyHeaderWithNameDateAndBody(title,commentCreatedDate,digestLastTwoCommentsTable,formatterList);

			commentList = commentList + getfullReply(commentProfilePicOrAlphabet,replyHeaderWithNameDateAndBody,formatterList, brandingInfo);
        }

		String viewPostOrPollButton = getViewPostOrPollButton(feedElementWrapperObj.id,formatterList,brandingInfo,isPoll,languagelocalekey);

        String digestItemRows = getDigestItemRows(digestAvatarAndHeaderWithFeedCreatedDate, digestPostTable,commentList,viewPostOrPollButton,formatterList, brandingInfo);
        return digestItemRows;
    }
    
    private static String getLinkEmailBody(String linkUrl, NotificationHelper.BrandingInfo brandingInfo){
		PageReference externalAppPageRefLink = new PageReference(linkUrl);
    	String externalAppLinkBody = '';
    	List<String> formatterList = new List<String>();
    	
		externalAppLinkBody = emailDigestPartMap.get('contentBody');
		formatterList.add(linkUrl.trim());
		formatterList.add(externalAppPageRefLink.getParameters().get('fileName'));
		if(externalAppPageRefLink.getParameters().get('size') !=null){
			formatterList.add(Utility.byteToHumanReadableFormate(Decimal.valueOf(externalAppPageRefLink.getParameters().get('size'))));
		} else{
			formatterList.add('');
		}
		formatterList.add(linkUrl.trim());
		formatterList.add(brandingInfo.general_primaryColor);
		externalAppLinkBody = EmailUtility.format(externalAppLinkBody, formatterList);							                			                			

		return externalAppLinkBody;    		
    }

    private static String getLinkEmailBody(String linkUrl, String linkText, NotificationHelper.BrandingInfo brandingInfo, Map<String, File__c> nativeVideoMap, String feedUrl){
        PageReference externalAppPageRefLink = new PageReference(linkUrl);
        String externalAppLinkBody = linkText;
        if(externalAppPageRefLink.getParameters().get('entry_id') != null) {
            File__c videoFile = nativeVideoMap.get(externalAppPageRefLink.getParameters().get('entry_id'));
            if(videoFile != null && String.isNotBlank(videoFile.Thumbnail_URL__c)) {
                externalAppLinkBody = '<img src="' + videoFile.Thumbnail_URL__c + '"/>' + videoFile.Title__c;
            }
        }
        externalAppLinkBody = '<a style="color:#'+brandingInfo.general_primaryColor+';text-decoration:none;word-break:break-word;font-size:15px" target="_blank" href=\"' + EmailUtility.getLinkWithFromEmail(feedUrl) + '\">' + externalAppLinkBody + ' </a>';
        return externalAppLinkBody;
    }
    
    @testVisible
    private static string getProfileDisplayIcon(String extPicUrl, String photoVersionId, Boolean isReply) {
    	String profileDisplayIcon = '';
		List<String> formatterList = new List<String>();
    	if(string.isNotBlank(photoVersionId)){
    		formatterList.add(extPicUrl);
    	} else {
    		formatterList.add(EmailConstants.peopleDefaultIcon);
    	}
		if(isReply){
			profileDisplayIcon = EmailUtility.format(emailDigestPartMap.get('replyProfileImageDigest'), formatterList);
		}else{
			profileDisplayIcon = EmailUtility.format(emailDigestPartMap.get('profileImageDigest'), formatterList);
		}
    	return profileDisplayIcon;
    }

	@testVisible
	private static String getDigestHeaderAndDateRow(String headerTitle,String dateRow,List<String> formatterList){
		String feedHeaderTitleAndDateRow = '';
		formatterList.add(headerTitle);
		formatterList.add(dateRow);
		feedHeaderTitleAndDateRow = EmailUtility.format(emailDigestPartMap.get('feedHeaderTitleAndDateRow'), formatterList);
		formatterList.clear();
    	return feedHeaderTitleAndDateRow;
	}

	@testVisible
	private static String getDigestAvatarAndHeaderWithFeedCreatedDate(String postProfilePicOrImage,String digestHeaderAndDateRow,List<String> formatterList){
		String digestAvatarAndHeaderWithFeedCreatedDate = '';
		formatterList.add(postProfilePicOrImage);
		formatterList.add(digestHeaderAndDateRow);
		digestAvatarAndHeaderWithFeedCreatedDate = EmailUtility.format(emailDigestPartMap.get('digestAvatarAndHeaderWithFeedCreatedDate'), formatterList);
		formatterList.clear();
    	return digestAvatarAndHeaderWithFeedCreatedDate;
	}


	@testVisible
	private static String addFeedCreatedDateToEmail(dateTime feedCreateddate,String languagelocalekey ,String timeZonesidkey,List<String> formatterList){
		String digestFeedCreateddDateRow = '';
		formatterList.add(LocaleContext.getLocalisedDateWithTime(feedCreateddate,languagelocalekey,timeZonesidkey));
		digestFeedCreateddDateRow = EmailUtility.format(emailDigestPartMap.get('digestFeedCreateddDateRow'), formatterList);
		formatterList.clear();
		return digestFeedCreateddDateRow;
	}

	@testVisible
	private static String addReplyCreatedDateToEmail(dateTime replyCreateddate,String languagelocalekey ,String timeZonesidkey,List<String> formatterList){
		String digestReplyCreateddDateRow = '';
		formatterList.add(LocaleContext.getLocalisedDateWithTime(replyCreateddate,languagelocalekey,timeZonesidkey));
		digestReplyCreateddDateRow = EmailUtility.format(emailDigestPartMap.get('digestReplyCreateddDateRow'), formatterList);
		formatterList.clear();
		return digestReplyCreateddDateRow;
	}

	
	@testVisible
	private static String getReplyHeaderWithNameDateAndBody(String title,String replyCreatedDate,String replyBody,List<String> formatterList){
		String replyBodyWithHeaderDateAndBody = '';
		formatterList.add(title);
		formatterList.add(replyCreatedDate);
		formatterList.add(replyBody);
		replyBodyWithHeaderDateAndBody = EmailUtility.format(emailDigestPartMap.get('replyHeaderWithNameDateAndBody'), formatterList);
		formatterList.clear();
		return replyBodyWithHeaderDateAndBody;
	}

	@testVisible
	private static String getViewPostOrPollButton(String feedItemId,List<String> formatterList,NotificationHelper.BrandingInfo brandingInfo,Boolean isPoll , String languagelocalekey){
		String viewPollOrPostButton = emailDigestPartMap.get('viewButton');
		if(String.isBlank(brandingInfo.general_primaryColor)) {
			brandingInfo.general_primaryColor = ServiceConstants.DEFAULT_BRANDING.get('general_primaryColor');
		}
		formatterList.add(brandingInfo.general_primaryColor);
		formatterList.add(baseUrl+Page.app.getUrl()+'?u=/feed/'+feedItemId+'&origin=de');
		if(isPoll){
			formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_VIEW_POLL_BUTTON));
		}else{
			formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_VIEW_POST_BUTTON));
		}
		
		viewPollOrPostButton = EmailUtility.format(viewPollOrPostButton,formatterList);
		formatterList.clear();
		return viewPollOrPostButton;
	}
    
    @testVisible
    private static string getfullReply(String profilePicOrAlphabet, String replyHeaderWithNameDateAndBody, 
    												List<String> formatterList, NotificationHelper.BrandingInfo brandingInfo) {
    	String fullReply = '';
		formatterList.add(profilePicOrAlphabet);
		formatterList.add(replyHeaderWithNameDateAndBody);
		fullReply = EmailUtility.format(emailDigestPartMap.get('fullReply'), formatterList);
		formatterList.clear();
    	return fullReply;
    }
    
    @testVisible
    private static string getDigestItemRows(String digestAvatarAndHeaderWithFeedCreatedDate, String digestPostTable, String digestLastTwoCommentsTable,String viewPostOrPollButton,  List<String> formatterList, NotificationHelper.BrandingInfo brandingInfo) {
    	String digestItemRows = '';
		formatterList.add(digestAvatarAndHeaderWithFeedCreatedDate);
		formatterList.add(digestPostTable);
		formatterList.add(digestLastTwoCommentsTable);
		formatterList.add(viewPostOrPollButton);
		digestItemRows = EmailUtility.format(emailDigestPartMap.get('digestItemRows'), formatterList);
		formatterList.clear();
    	return digestItemRows;
    }

	@testVisible
    private static string getDigestItemRowsWithGreetingHeader(String digestType, 
			String targetUserFirstName,String targetUserLastName, 
			String appName, String digestItemRows, List<String> formatterList, 
			NotificationHelper.BrandingInfo brandingInfoString, String languagelocalekey) {
    	languagelocalekey = Utility.getSimpplrLanguageLocaleKey(languagelocalekey);
		String digestItemRowsWithGreetingHeader = '';

		if (String.isNotBlank(targetUserFirstName)) {
			formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_COMMON_SALUTATION).replace('{{firstName}}',targetUserFirstName));
		
		} else {
			formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_COMMON_SALUTATION).replace('{{firstName}}',targetUserLastName));
		}

		formatterList.add(LocaleContext.getLabel(languagelocalekey,digestType).replace('{{appName}}',appName));
		formatterList.add(digestItemRows);
		digestItemRowsWithGreetingHeader = EmailUtility.format(emailDigestPartMap.get('digestItemRowsWithGreetingHeader'), formatterList);
		formatterList.clear();
    	return digestItemRowsWithGreetingHeader;
    }

	@testVisible
	private static string getDigestFinalBodyWithHeaderFooter(String logoUrl,People_Preference__c peoplePrefObj, String emailBody,NotificationHelper.BrandingInfo brandingInfo){
		String digestFinalBodyWithHeaderFooter = '';
		String languagelocalekey = peoplePrefObj.User__r.languagelocalekey;

		languagelocalekey = Utility.getSimpplrLanguageLocaleKey(languagelocalekey);

		List<String> formatterList = new List<String>();
		formatterList.add('<style> @media all {.ExternalClass {width: 100%;}.ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font, .ExternalClass td,.ExternalClass div {line-height: 100%; }.apple-link a {color: inherit !important;font-family: inherit !important;font-size: inherit !important;font-weight: inherit !important; line-height: inherit !important; text-decoration: none !important;}}@media only screen and (max-width: 620px) {table[class=body] .wrapper,table[class=body] .header, table[class=body] .article { padding: 10px !important; } table[class=body] .content { padding: 0 !important; } table[class=body] .container {padding: 0 !important; width: 100% !important; }table[class=body] .main {border-left-width: 0 !important;border-radius: 0 !important;border-right-width: 0 !important;} table[class=body] .btn table {width: 100% !important;}table[class=body] .btn a {width: 100% !important; }table[class=body] .img-responsive {height: auto !important;max-width: 100% !important;width: auto !important; }td[class="mobile-hide"] {display: none; }.mobile-hide {display: none;} .wrapper,.header, .article { padding: 10px !important;} .content { padding: 0 !important;}.container {padding: 0 !important;width: 100% !important;}.main { border-left-width: 0 !important;border-radius: 0 !important; border-right-width: 0 !important;}.btn table { width: 100% !important;} .btn a { width: 100% !important; }.img-responsive { height: auto !important;max-width: 100% !important;width: auto !important;}} a[x-apple-data-detectors] {color: inherit !important;text-decoration: none !important;font-size: inherit !important;font-family: inherit !important; font-weight: inherit !important;line-height: inherit !important; }</style>');
		//***url to backyard logo not used anymore*** formatterList.add(PageContext.getPageURL(Pages.app)+'?u=/&origin=ne');
		formatterList.add(logoUrl);
		
		formatterList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(),languagelocalekey, peoplePrefObj.People__r.User__r.timeZonesidkey));// current date
		formatterList.add(emailBody);
		formatterList.add(baseUrl + Page.PageRedirector.getUrl()+'?userId='+peoplePrefObj.people__c+'&pageToRedirect='+Pages.MySettingsEmail+'&origin=ne');
		formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_FOOTER_SETTINGS).replace('{{appName}}',SimpplrContext.applicationName));
		formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
		formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_POWERED_BY));
		
		if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('000000');
		} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
			formatterList.add(brandingInfo.general_primaryColor);
		} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('ffffff');
		} else {
			formatterList.add(brandingInfo.header_backgroundColor);
		}

		// 9 mobile promotion footer
		formatterList.add(EmailUtility.getMobilePromotionFooterDiv(languagelocalekey, peoplePrefObj.People__c));
		
		digestFinalBodyWithHeaderFooter = EmailUtility.format(emailDigestPartMap.get('digestFinalBodyWithHeaderFooter'), formatterList);

		return digestFinalBodyWithHeaderFooter;
	}
    
    @testVisible 
    public static String getEmailContentBody(JSONFeedElementWrapper.Content content, List<String> formatterList, NotificationHelper.BrandingInfo brandingInfo) {
        String contentBody = '';
        if(content.id != null && content.fileSize != null){
	        contentBody = emailDigestPartMap.get('contentBody');
	        formatterList.add(PageContext.getPageURL(Pages.FileDetail,new Map<String,String>{'fileId'=>content.id,'fromEmail'=>'1'}));
	        formatterList.add(content.title);
	        formatterList.add(Utility.byteToHumanReadableFormate(Decimal.valueOf(content.fileSize)));
	        formatterList.add(content.downloadUrl);
	        formatterList.add(brandingInfo.general_primaryColor);
	        contentBody = EmailUtility.format(contentBody, formatterList);
	        formatterList.clear();
        }
        return contentBody;
        
    }
    
    @testVisible
    private static String getEmailLinkBody(JSONFeedElementWrapper.Link link, List<String> formatterList, NotificationHelper.BrandingInfo brandingInfo) {
        String linkBody = String.format('<p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;"><a href="{0}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{2}; text-decoration: underline;">{1}</a></p>',new List<String>{link.url,link.urlName,brandingInfo.general_primaryColor});
        formatterList.clear();
        return linkBody;
    }
    
    @testVisible
    private static String getEmailPollBody(String postBody, List<JSONFeedElementWrapper.Choices> pollChoiceList, String feedItemId,
    											 List<String> formatterList, NotificationHelper.BrandingInfo brandingInfo){
    	String pollBody = '';
		for(JSONFeedElementWrapper.Choices feedChoice : pollChoiceList){
			pollBody = pollBody + '<li style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; list-style-position: inside; margin-left: 5px;">'+ feedChoice.text+'</li>';
		}
		formatterList.add(pollBody);
		String pollPostChoices = emailDigestPartMap.get('pollPostChoicesRow');
		pollPostChoices = EmailUtility.format(pollPostChoices,formatterList);
		formatterList.clear();

		String pollTextWithChoices = emailDigestPartMap.get('pollTextWithChoices');
		formatterList.add(postBody);
		formatterList.add(pollPostChoices);
		pollTextWithChoices = EmailUtility.format(pollTextWithChoices,formatterList);
		formatterList.clear();

		return pollTextWithChoices;
    }
    
    
    
    public static Map<String,Feed_Cache__c> getFeedItemValueMapFromSimpplrMetadata(Set<String> setOfFeedItemIds, Integer frequency) {
		Map<String,Feed_Cache__c> mapOfFeedItemValueFromSimpplrMetadata = new Map<String,Feed_Cache__c>();
    	if(setOfFeedItemIds != null) {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', setOfFeedItemIds);
    		String queryMetadata = 'Select Feed_Id__c, Feed_Data__c from Feed_Cache__c where Feed_Id__c IN: soqlParam1'+
                                ' And Is_Deleted__c = false And LastModifiedDate =  LAST_N_DAYS:'+frequency+' order by LastModifiedDate desc ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Feed_Cache__c> listOfSimpplrMetadata = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(queryMetadata, soqlParamMap);
			Integer orderFlag = 0;
			String lastFeedItemId='';
            for(Feed_Cache__c simMetaObj : listOfSimpplrMetadata) {
            		if(mapOfFeedItemValueFromSimpplrMetadata.containsKey(simMetaObj.Feed_Id__c) == false) {
                 	mapOfFeedItemValueFromSimpplrMetadata.put(simMetaObj.Feed_Id__c, simMetaObj);
            		}
            }
			
    	}
    	return mapOfFeedItemValueFromSimpplrMetadata;	
    }
    
    private static String createEmailTitle(JSONFeedElementWrapper feedElementWrapperObj, Simpplr_Content__c parentSimpplrContentObj) {
        
        List<JSONFeedElementWrapper.MessageSegments_Z> headerMessSegment = feedElementWrapperObj.header.messagesegments;
        Integer headerMesaageSegmentsSize = headerMessSegment.size();
        
        
        String emailTitle ='';
        String firstSegment = '';
        String secondSegment = '';
        String thirdSegment = '';
        String extraLabel = '';
        
        if(feedElementWrapperObj.originalFeedItemActor == null) {
            
            for( Integer index=0 ;index<headerMesaageSegmentsSize;index++){
                JSONFeedElementWrapper.MessageSegments_Z header = headerMessSegment.get(index);
                
                if('EntityLink'.equalsIgnoreCase(header.type)){
                    String headerText = header.reference?.id != null && header.reference.id.startsWith('005') && FeedDataAdapter.mapUserIdToPeople.containsKey(header.reference.id) ? FeedDataAdapter.mapUserIdToPeople.get(header.reference.id).Full_name__c : header.text;
                    if(feedElementWrapperObj.parent.id.subString(0,3).equalsIgnoreCase('005')) {
                        if(feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                            if(feedElementWrapperObj.parent.id != feedElementWrapperObj.actor.id){
                                if(index == 0){
                                    firstSegment = headerText.unescapeHtml4();
                                }
                                if(index == 2){
                                    thirdSegment = headerText.unescapeHtml4();
                                }
                            }else{
                                thirdSegment = headerText.unescapeHtml4();
                                firstSegment = '';
                            }
                            
                        }else if(feedElementWrapperObj.type.equalsIgnoreCase('CollaborationGroupCreated')){
        					if(index == 0){
	    						firstSegment = headerText.unescapeHtml4();
	    					}
	    					if(index == 2){
	    						thirdSegment = headerText.unescapeHtml4();
	    					}
         				}else{
                            emailTitle = emailTitle+headerText.unescapeHtml4();
                        }
                    }else if(feedElementWrapperObj.parent.id.startsWith('0F9') || feedElementWrapperObj.parent.id.startsWithIgnoreCase(simpplrContentPrefix)){
                        if(index == 0){
                            if(parentSimpplrContentObj != null){
                                if(parentSimpplrContentObj.Name.equalsIgnoreCase(header.text)) {
                                    String contentTitle = parentSimpplrContentObj.Title__c.length()>73 ? parentSimpplrContentObj.Title__c.substring(0,70)+'...' : parentSimpplrContentObj.Title__c;
                                    firstSegment = contentTitle.unescapeHtml4();
                                } else {
                                    firstSegment = headerText.unescapeHtml4();
                                }
                            }else{
                                firstSegment = headerText.unescapeHtml4();
                            }
                        }else if(index == 2){
                            thirdSegment = headerText.unescapeHtml4();
                        }else{
                            emailTitle = emailTitle+headerText.escapeHtml4();
                        }
                    }else{
                    	if(index == 0){
    						firstSegment = headerText.escapeHtml4();
    					}
    					if(index == 2){
    						thirdSegment = headerText.unescapeHtml4();
    					}
                    }
                    
                }else { 
                    if(index == 1 && feedElementWrapperObj.parent.type.equalsIgnoreCase('CollaborationGroup')){
                        extraLabel = header.text;
                        if(extraLabel.containsIgnoreCase('Archived')){
                        	extraLabel = '<span style="color:#999999;"> ('+INACTIVE+')</span>';
                        }else{
                        	extraLabel = '<span style="color:#999999;">'+extraLabel.remove(' — ')+'</span>';
                        }
                    }
                    String str = '';
                    
                    if(index == 1 && !header.text.containsIgnoreCase(' posted a ')){
                        if(feedElementWrapperObj.parent.id.startsWith('0F9')){
                            if(!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                                str = ' in ';
                            }else{
                                str = ' made changes in ';
                            }
                            
                        }else if(feedElementWrapperObj.parent.id.startsWithIgnoreCase(simpplrContentPrefix)){
                            if(!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                                str = ' on ';
                            }else{
                                str = ' made changes on ';
                            }
                        }else if(feedElementWrapperObj.parent.id.startsWithIgnoreCase('005')){
                            if(feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                                if(feedElementWrapperObj.parent.id != feedElementWrapperObj.actor.id){
                                    str = ' made changes to ';
                                }else{
                                    str = ' made changes ';
                                }
                            }else{
                                emailTitle = emailTitle+'<span style="color:#999999;">'+header.text.unescapeHtml4()+'</span>';
                            }
                            
                        }else{
                            str = ' made changes on ';
                        }
                        secondSegment = '<span style="color:#999999;">'+str+'</span>';
                    }else{
                    	if(index == 3 && !feedElementWrapperObj.parent.id.startsWithIgnoreCase('005') && !feedElementWrapperObj.parent.id.startsWith('0F9')){
        					continue;
	       				}
                    	
                        if((!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange') && !header.text.containsIgnoreCase(' posted a ') && !header.text.containsIgnoreCase(':')) || (!header.text.equalsIgnoreCase(' changed ') && feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange'))){
                            emailTitle = emailTitle+header.text.unescapeHtml4();
                        }
                    }
                        
                }
            }
            if(feedElementWrapperObj.type.equalsIgnoreCase('CollaborationGroupCreated')){
        		emailTitle = firstSegment+'<span style="color:#999999;"> added Site </span>'+thirdSegment;
        	}else if(!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                emailTitle = thirdSegment+secondSegment+firstSegment+emailTitle+extraLabel;
            }else{
                emailTitle = thirdSegment+secondSegment+firstSegment+extraLabel+'<br>'+emailTitle;
            }
        }
        
        if(feedElementWrapperObj.originalFeedItemActor != null){
            String siteName = '';
            String newPostOwner = '';
            String originalPostOwner = '';
            String originalPost = '';
            for( Integer index=0 ;index<headerMesaageSegmentsSize;index++){
                JSONFeedElementWrapper.MessageSegments_Z header = headerMessSegment.get(index);
                
                if('EntityLink'.equalsIgnoreCase(header.type)){
                     
                     if('0F9'.equals(header.reference.id.subString(0,3))){
                        siteName = '<span style="color:#999999;"> in </span>' + header.text.unescapeHtml4();
                     }else if(header.reference.id.startsWithIgnoreCase('005')){
						String headerText = FeedDataAdapter.mapUserIdToPeople.containsKey(header.reference.id) ? FeedDataAdapter.mapUserIdToPeople.get(header.reference.id).Full_name__c : header.text;
                        if(String.isBlank(originalPost)){
                            newPostOwner = headerText.unescapeHtml4();
                        }else{
                            originalPostOwner = headerText.unescapeHtml4();
                        }
                     }else if(header.reference.id.startsWithIgnoreCase('0D5')){
                        originalPost = 'post';
                     }
                } else {
                    if(index == 1 && feedElementWrapperObj.parent.type.equalsIgnoreCase('CollaborationGroup')){
                        extraLabel = header.text;
                        if(extraLabel.containsIgnoreCase('Archived')){
                        	extraLabel = '<span style="color:#999999;"> ('+INACTIVE+')</span>';
                        }else{
                        	extraLabel = '<span style="color:#999999;">'+extraLabel.remove(' — ')+'</span>';
                        }
                    }
                   
                }
            }
            emailTitle = emailTitle + newPostOwner+'<span style="color:#999999;"> shared </span>'+originalPostOwner+'<span style="color:#999999;">&apos;s </span>'+originalPost+siteName+extraLabel;
        }
         
        return emailTitle ;
    }
    
    private static String simpplrContentPrefix {get {
		if(simpplrContentPrefix == null) {
			Schema.DescribeSObjectResult r = Simpplr_Content__c.sObjectType.getDescribe();
			simpplrContentPrefix = r.getKeyPrefix();
		}
		return simpplrContentPrefix;
	}private set;}
	
	@testVisible 
    private static Feed_Cache__c getCacheFeedElement(String feedElementJson, Set<String> mentionUserIds,Set<String> mentionGrpIds, String feedItemId, boolean isComment, String feedCommentId, String parentId){ 
	    Feed_Cache__c myFeedCacheRecord = new Feed_Cache__c();
        try{
	        myFeedCacheRecord.Feed_Id__c = feedItemId;
	        myFeedCacheRecord.Parent_Id__c = parentId;
	        myFeedCacheRecord.Feed_Data__c = feedElementJson;
	        Integer count = 0;
	        myFeedCacheRecord.Mention_1__c = '';
	        myFeedCacheRecord.Mention_2__c = '';
	        myFeedCacheRecord.Mention_3__c = '';
	        myFeedCacheRecord.Mention_4__c = '';
	        myFeedCacheRecord.Mention_5__c = '';
	        for(String mentionUserId : mentionUserIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Mention_1__c = myFeedCacheRecord.Mention_1__c + mentionUserId;
	            }
	            if(count>=252 && count<252*2) {
	                myFeedCacheRecord.Mention_2__c = myFeedCacheRecord.Mention_2__c + mentionUserId;
	            }
	            if(count>=252*2 && count<252*3) {
	                myFeedCacheRecord.Mention_3__c = myFeedCacheRecord.Mention_3__c + mentionUserId;
	            }
	            if(count>=252*3 && count<252*4) {
	                myFeedCacheRecord.Mention_4__c = myFeedCacheRecord.Mention_4__c + mentionUserId;
	            }
	            if(count>=252*4 && count<252*5) {
	                myFeedCacheRecord.Mention_5__c = myFeedCacheRecord.Mention_5__c + mentionUserId;
	            }
	            count +=18;
	        }
	        count = 0;
	        myFeedCacheRecord.Group_Mention_1__c = '';
	        myFeedCacheRecord.Group_Mention_2__c = '';
	        myFeedCacheRecord.Group_Mention_3__c = '';
	        myFeedCacheRecord.Group_Mention_4__c = '';
	        myFeedCacheRecord.Group_Mention_5__c = '';
	        
	        for(String mentionGrpId : mentionGrpIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Group_Mention_1__c = myFeedCacheRecord.Group_Mention_1__c + mentionGrpId;
	            }
	            if(count>252 && count<252*2) {
	                myFeedCacheRecord.Group_Mention_2__c = myFeedCacheRecord.Group_Mention_2__c + mentionGrpId;
	            }
	            if(count>252*2 && count<252*3) {
	                myFeedCacheRecord.Group_Mention_3__c = myFeedCacheRecord.Group_Mention_3__c + mentionGrpId;
	            }
	            if(count>252*3 && count<252*4) {
	                myFeedCacheRecord.Group_Mention_4__c = myFeedCacheRecord.Group_Mention_4__c + mentionGrpId;
	            }
	            if(count>252*4 && count<252*5) {
	                myFeedCacheRecord.Group_Mention_5__c = myFeedCacheRecord.Group_Mention_5__c + mentionGrpId;
	            }
	            count +=18;
	        }
	        if(isComment){
	        	myFeedCacheRecord.Feed_Item_Type__c = 'Comment';
	        	myFeedCacheRecord.Feed_Comment_Id__c = feedCommentId;
	        }
        }catch(Exception e){
        	
        }
	    return myFeedCacheRecord; 
    }
    
    @testVisible
    private static Set<String> getMentionedUserIdSet(List<ConnectApi.MessageSegment> messageSegments){
        Set<String> mentionedUserIdSet = new Set<String>();
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if(messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                if(mentionSegment.record instanceof ConnectApi.UserSummary) {
                    ConnectApi.UserSummary userRecord = (ConnectApi.UserSummary) mentionSegment.record;
                    mentionedUserIdSet.add(userRecord.Id);
                }
            }
        }
        return mentionedUserIdSet;
    }
    
    @testVisible
    private static Set<String> getMentionedGroupIdSet(List<ConnectApi.MessageSegment> messageSegments){
        Set<String> mentionedGroupIdSet = new Set<String>();
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if(messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                if(mentionSegment.record instanceof ConnectApi.ChatterGroupSummary) {
                    ConnectApi.ChatterGroupSummary grpRecord = (ConnectApi.ChatterGroupSummary) mentionSegment.record;
                    mentionedGroupIdSet.add(grpRecord.Id);
                }
            }
        }
        return mentionedGroupIdSet;
    }

	private static String getEmailFileBody(List<JSONFeedElementWrapper.Content> fileList, String userLanguage) {
		String fileBody = '<span class="Post-attachments" style="color: #999; font-size: 14px;">{0}</span>';
		List<String> formatterList = new List<String>();
		String fileText='';
		if(fileList.size() == 1) {
			fileText = LocaleContext.getLabel(userLanguage, KEY_FILE_ATTACHED).replace('{{count}}', '1');
		} else if(fileList.size() > 1) {
			fileText = LocaleContext.getLabel(userLanguage, KEY_FILES_ATTACHED).replace('{{count}}', String.valueOf(fileList.size()));
		}

		formatterList.add(fileText);
		fileBody = EmailUtility.format(fileBody, formatterList);
        
		return fileBody;
    }  

}