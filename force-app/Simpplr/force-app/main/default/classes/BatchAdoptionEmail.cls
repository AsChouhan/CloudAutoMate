public with sharing class BatchAdoptionEmail implements Database.Batchable<SObject>, Database.stateful, Database.AllowsCallouts{
	
	private Exception exceptionDetailsObj;
	private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};

	String packageName;
	private Boolean isSendOnlyToMe;
	public String recordType ;
	private AdoptionEmailWrapper previousAdoptionEmailWrapperObj;
	private AdoptionEmailWrapper currentAdoptionEmailWrapperObj;
	private final String KEY_MONTHLY_SUBJECT = 'email.notification.analytics.org.monthly.subject';
	private final String KEY_MONTHLY_INTRO = 'email.notification.analytics.org.monthly.intro';
	private final String KEY_THIS_MONTH = 'email.notification.analytics.org.monthly.this_month';
	private final String KEY_MONTHLY_LOGIN_NUMBER = 'email.notification.analytics.org.monthly.number.logged_in';
	private final String KEY_MONTHLY_REVIEW_ACTIVITY = 'email.notification.analytics.org.monthly.number.review_activity';
	
	private final String KEY_ALBUM = 'email.notification.analytics.org.monthly.number.viewed.album';
	private final String KEY_BLOG = 'email.notification.analytics.org.monthly.number.viewed.blog_post';
	private final String KEY_EVENT = 'email.notification.analytics.org.monthly.number.viewed.event';
	private final String KEY_PAGE = 'email.notification.analytics.org.monthly.number.viewed.page';

	private final String KEY_ALBUM_BLOG = 'email.notification.analytics.org.monthly.number.viewed.album_blog_post';
	private final String KEY_EVENT_ALBUM = 'email.notification.analytics.org.monthly.number.viewed.event_album';
	private final String KEY_PAGE_ALBUM = 'email.notification.analytics.org.monthly.number.viewed.page_album';
	private final String KEY_PAGE_BLOG = 'email.notification.analytics.org.monthly.number.viewed.page_blog_post';
	private final String KEY_EVENT_BLOG = 'email.notification.analytics.org.monthly.number.viewed.event_blog_post';
	private final String KEY_PAGE_EVENT = 'email.notification.analytics.org.monthly.number.viewed.page_event';

	private final String KEY_EVENT_ALBUM_BLOG = 'email.notification.analytics.org.monthly.number.viewed.event_album_blog_post';
	private final String KEY_PAGE_ALBUM_BLOG = 'email.notification.analytics.org.monthly.number.viewed.page_album_blog';
	private final String KEY_PAGE_EVENT_ALBUM = 'email.notification.analytics.org.monthly.number.viewed.page_event_album';
	private final String KEY_PAGE_EVENT_BLOG = 'email.notification.analytics.org.monthly.number.viewed.page_event_blog_post';
	
	private final String KEY_ALL_CONTENT = 'email.notification.analytics.org.monthly.number.viewed.all_content';
	
	private final String KEY_SAME_AS_LAST_MONTH = 'email.common.same_last_month.digest';
	private final String KEY_COMMON_DIGEST = 'email.common.digest';
	private final String KEY_THAT_IS_TOTAL = 'email.notification.analytics.org.monthly.that_is_total';
	private final String KEY_CONTENT_VIEWS = 'email.common.content_views';
	private final String KEY_MONTHLY_AVERAGE_OF = 'email.notification.analytics.org.monthly.average_of';
	private final String KEY_VIEWS_PER_USER = 'email.common.views_per_user';
	private final String KEY_MONTHLY_TOGETHER_THEY = 'email.notification.analytics.org.monthly.together_they';
	private final String KEY_POSTS_AND_REPLIES = 'email.common.posts_replies';
	private final String KEY_SHARES = 'email.common.shares';
	private final String KEY_LIKES = 'email.common.likes';
	private final String KEY_DEEPER_SIGHT = 'email.notification.analytics.org.monthly.deeper_insight';
	private final String KEY_VIEW_ANALYTICS_BUTTON = 'email.common.analytics.button';
	private final String KEY_COPYRIGHT = 'email.common.footer.copyright';
	private final String KEY_POWERED_BY = 'email.common.footer.powered_by';
	private final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';

	private static final String KEY_MOST_POPULAR_CONTENT = 'email.common.popular_content.digest';
	private static final String KEY_IN = 'common.in';
	private static final String KEY_ON = 'email.common.on.digest';
	private static final String KEY_ALL_DAY = 'email.common.all_day.digest';
	private static final String KEY_BY = 'email.common.by';
	private static final String KEY_EDITED = 'email.common.edited.digest';
	private static final String KEY_MUST_READ = 'email.common.stamp.must_read';
	private static final String KEY_PAGE_KEYWORD = 'email.common.label.page';
	private static final String KEY_EVENT_KEYWORD = 'email.common.label.event';
	private static final String KEY_ALBUM_KEYWORD = 'email.common.label.album';
	private static final String KEY_BLOGPOST_KEYWORD = 'email.common.blog_post';
	public static NotificationHelper.BrandingInfo brandingInfo;
	private void initLangKeyValueMap(List<People__c> PeopleList) {
        List<String> localeList = new List<String>();
		for(People__c peopleObj : PeopleList){
			localeList.add(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey));
		}
		LocaleContext.getAllLabelMap('EmailNotifications', localeList);
    }

	public static Map<String,String> adoptionEmailTemplateMap = new Map<String,String>{
    	
    	//0=Date 1=Application Name 2=Previous Month 3=This Month keyword 4=employee login percentage  5=Content items read 6=items read per user 7=Together we added section 8=Most Popular Content 9=Analytics Page URL 10=Receiver's Email 11 = style tag 12 = logo url 13 = people who view content percentage 14 = list of contents enabled 15=changeInUserPercentWhoViewedContent  16=ChangeInContentViewCount  17=ChangeInContentViewedPerPerson 18=Receiver's profile link
    	'emailBodyWithHeaderFooter' => '<html><head><meta charset="utf-8"><meta content="width=device-width, initial-scale=1.0" name="viewport"><meta content="text/html" http-equiv="Content-Type"><meta content="telephone=no" name="format-detection">{10}<title>{1} Monthly Report</title>{11}</head><body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"><table width="580" align="center" role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 580px;"><tr><td width="580" align="center" class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"><div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"><!-- START CENTERED WHITE CONTAINER --><table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><!-- START HEADER --><tr><td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #{32}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{12}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td><td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{0}</span></td></tr></table></td></tr><!-- END HEADER --><!-- START MAIN CONTENT AREA --><tr><td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; max-width: 600px !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 28px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="Heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 21px; font-weight: 400; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; padding-bottom: 4px; text-align: left; vertical-align: top; word-break: break-word;">{1}</td></tr><tr><td class="Heading Heading--sub" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: 400; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top; word-break: break-word;">{2}</td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; max-width: 600px !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" class="u-border-top" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-top: 1px solid #cccccc; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 24px 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="Heading Heading--small Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: 400; line-height: 20px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: center; vertical-align: top; word-break: break-word;">{3}</td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; margin-bottom: 5px; margin-top: 7px; padding-bottom: 10px; text-align: center;">{4}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="Stat-number Stat-number--large u-brandText" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{30}; font-size: 100px; font-weight: bold; line-height: 110px; margin: 0; text-align: center;">{13}%</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace:0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="Heading Heading--tiny Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: 400; line-height: 16px; margin: 0; padding: 0; text-align: center; word-break: break-word;">{14}</p></td></tr>{15}</tbody></table></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 28px; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" class="u-border-top u-border-bottom" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-bottom: 1px solid #cccccc; border-collapse: separate; border-top: 1px solid #cccccc; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="Stat--leftAlign" valign="bottom" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-right: 1px solid #e6e6e6; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 24px 2px; text-align: left; vertical-align: top; width: 50%;"><p class="Heading Heading--small Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: 400; line-height: 20px; margin: 0; padding: 0; text-align: center; word-break: break-word;">{19}</p><p class="Stat-number u-brandText" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{30}; font-size: 60px; font-weight: bold; line-height: 70px; margin: 0; text-align: center;">{5}</p><p class="Heading Heading--sub Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: 400; line-height: 1.4; margin: 0; padding: 0; text-align: center; word-break: break-word;">{20}</p><p class="Stat-diff" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #8F8F93; font-size: 13px; margin: 0; padding-top: 5px; text-align: center;">{16}</p></td><td valign="bottom" class="Stat--leftAlign" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 24px 2px; text-align: left; vertical-align: top; width: 50%;"><p class="Heading Heading--small Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: 400; line-height: 20px; margin: 0; padding: 0; text-align: center; word-break: break-word;">{21}</p><p class="Stat-number u-brandText" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{30}; font-size: 60px; font-weight: bold; line-height: 70px; margin: 0; text-align: center;">{6}</p><p class="Heading Heading--sub Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; font-weight: 400; line-height: 1.4; margin: 0; padding: 0; text-align: center; word-break: break-word;">{22}</p><p class="Stat-diff" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #8F8F93; font-size: 13px; margin: 0; padding-top: 5px; text-align: center;"><span style="font-weight: bold; color: #{30};">{17}</p></td></tr></tbody></table></td></tr><tr><td class="Heading Heading--medium Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 18px; font-weight: 400; line-height: 13px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: center; vertical-align: top; word-break: break-word;">{23}</td></tr><tr>{7}</tr></tbody></table></td></tr></tbody></table></td></tr>{8} <!-- Deeper insights --> <tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; max-width: 600px !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-top: 1px solid #cccccc; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 16px 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="Heading Heading--medium Heading--centred" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 18px; font-weight: 400; line-height: 25px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 0 20px; text-align: center; vertical-align: top; word-break: break-word;">{24}</td></tr><tr class="u-textAlign-center" style="text-align: center;"><td class="Button" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{30}; border: 1px solid #{30}; border-collapse: collapse; border-radius: 4px; color: #333; display: inline-block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 14px 20px; text-align: center; vertical-align: top; width: 150px;"><a href="{9}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: none; color: #ffffff; font-size: 14px; font-weight: bold; text-decoration: none;">{25}</a> </td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr><!-- END MAIN CONTENT AREA --></table><!-- START FOOTER -->{31}<div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> <a href="{29}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{28}</a> <br>{26} </td></tr><tr><td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;">{27} <a href="http://simpplr.com" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12p; text-align: center; text-decoration: none;">Simpplr</a>. </td></tr></table></div><!-- END FOOTER --> <!-- END CENTERED WHITE CONTAINER --></div></td></tr></table></body></html>',
		
		//0=Post & replies Count 1=Likes count 2=Shares count 3=postsAndRepliesChangePercent 4=likesChangePercent 5=sharesChangePercent 
		'togetherTheyAddedWithFeedEnabled' => '<td class="StatTilesContainer" valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 0 32px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-spacing: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="StatTile" valign="top" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f4f4f4; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 5px; text-align: center; vertical-align: top; width: 33.333%;"><p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; padding-bottom: 10px; text-align: center;">{6}</p><p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;">{0}</p>{3}</td><td class="StatTile" valign="top" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f4f4f4; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 5px; text-align: center; vertical-align: top; width: 33.333%;"><p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; padding-bottom: 10px; text-align: center;">{8}</p><p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;">{1}</p>{4}</td><td class="StatTile" valign="top" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f4f4f4; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px 5px; text-align: center; vertical-align: top; width: 33.333%;"><p class="Stat-label" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; margin: 0; padding-bottom: 10px; text-align: center;">{7}</p><p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;">{2}</p>{5}</td></tr></tbody></table></td>',
				
		//0=Likes Count 1=likesCountChangePercentage
		'togetherTheyAddedWithFeedDisabled' => '<td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 0 12px 0; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-spacing: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="" valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="Stat-number Stat-number--small" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 40px; font-weight: bold; line-height: 40px; margin: 0; text-align: center;">{0}<span style="font-size: 20px;">{2}</span></p>{1}</td></tr></tbody></table></td>',
		
		//Blog Post 0=Thumbnail URL 1=Blog Post Link 2=Title 3=Description 4=Author Link  5=Author name 6=Publication Date
		'blogPost' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125">  <a href="{2}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table></a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{1} {8}</span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{2}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{3}</a></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4}</p></td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{9} <a href="{5}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{12}; text-decoration: none;">{6}</a> {10} {7}{11}</p> </td></tr></table></td></tr> </table> </td> </tr> </table></td></tr> </table> </td></tr>',
	
		//Page & Album 0= Thumbnail URL 1=Content Type 2=Page/Album Link 3=Title 4=Description 5=Site Landing Page URL 6=Site Name 7=Publication Date 
		'pageORAlbum' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{2}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td></tr></tbody></table> </a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{1} {8}</span></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{2}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{3}</a></td></tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{9} <a href="{5}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{11}; text-decoration: none;">{6}</a> {7} {10}</p></td> </tr> </tbody></table></td></tr></tbody></table></td> </tr></tbody></table></td></tr></tbody></table></td></tr>', 
	
		//Event =Event Month 1=Event Day 2=Event Link 3=Title 4=Start Date 5=End Date 6=Description
		'event' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125">{0}</td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{2}</a> {3}</td> </tr> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4}</p></td> </tr> </table> </td></tr></table></td></tr></table></td></tr></table></td></tr>',
	
		// percentangeChange  0=Actual difference
		'percentangeChangeForUser' => '<tr><td class="Stat-diff" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #8F8F93; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 13px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-top: 5px; text-align: center; vertical-align: top;">{0}</td></tr>',
		
		// percentangeChangeForContent 0=Actual difference
		'percentangeChangeForContent' => '<p class="Stat-diff" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #8F8F93; font-size: 13px; margin: 0; padding-top: 5px; text-align: center;">{0}</p>'
		
	};

	public BatchAdoptionEmail(String recordType) {
		this.packageName = SimpplrContext.packageName;
		this.isSendOnlyToMe = false;
		this.previousAdoptionEmailWrapperObj = getAdoptionInfoForMonth(Integer.valueOf(DateTime.now().addMonths(-2).format('yyyyMM')));
	    this.recordType = recordType ;
	}
	
	public BatchAdoptionEmail(String recordType,Boolean isSendOnlyToMe) {
		this.packageName = SimpplrContext.packageName;
		this.isSendOnlyToMe = isSendOnlyToMe;
		this.previousAdoptionEmailWrapperObj = getAdoptionInfoForMonth(Integer.valueOf(DateTime.now().addMonths(-2).format('yyyyMM')));
	    this.recordType = recordType ;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String loggedInUserId = UserInfo.getUserId();
		String queryString = '' ;

		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			//Dummy Query to create Adoption Email Data.
			 queryString = 'SELECT Id,user__r.languagelocalekey, user__r.timeZonesidkey, user__r.username, Segment__c, ' + 
													 ' Segment__r.Branding_JSON__c, Segment__r.Branding_Logo__c ' + 
													 ' FROM People__c WHERE (App_Moderation_Permission__c = \'Yes\' OR Can_Access_Analytics__c = True) ' + 
													 ' AND User__r.isActive=true AND User__r.UserType=\'Standard\' LIMIT 1';      
		
		}else if('sendMonthlyAdoptionEmail'.equalsIgnoreCase(recordType)){
    		 queryString = 'SELECT Id,user__r.languagelocalekey, user__r.timeZonesidkey, user__r.username, Segment__c, ' + 
													 ' Segment__r.Branding_JSON__c, Segment__r.Branding_Logo__c ' + 
													 ' FROM People__c WHERE (App_Moderation_Permission__c = \'Yes\' OR Can_Access_Analytics__c = True) ' + 
													 ' AND User__r.isActive=true AND User__r.UserType=\'Standard\'';
        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
    		queryString = queryString + ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
    	}
    	if(isSendOnlyToMe) {
    		queryString = queryString + ' And User__c=: loggedInUserId ';
		}    	
	}
        return Database.getQueryLocator(queryString);
    }
     
    
    public void execute(Database.BatchableContext BC, List<People__C> analyticsPeopleList){
    	try{
			Integer allUserCount ;
			String usersLoggedInPercentage;
			Integer usersWhoViewedContent;
			String usersWhoViewedContentPercentage ;
			Map<String, Decimal> contentInfo;
			String contentViewsCount ;
			String contentPostsAndRepliesCount  ;
			String contentLikesCount ;
			String contentSharesCount ;
			String averageContentPerPerson ;

		if('initAnalyticsData'.equalsIgnoreCase(recordType)){

			allUserCount = getAllUserCount();
			usersLoggedInPercentage = getUsersLoggedInPercentage(allUserCount);
			usersWhoViewedContent = getUsersWhoViewedContent(DateTime.now().addMonths(-1));
			usersWhoViewedContentPercentage = getUsersWhoViewedContentPercentage(usersWhoViewedContent, allUserCount);
		   
			List<Analytics_Login__c> analyticsLoginList = [SELECT Content_Views__c, Likes__c, Posts__c, Replies__c, 
				   Shares__c FROM Analytics_Login__c WHERE Date__c =  LAST_MONTH];
		   
			contentInfo = getContentInfo(analyticsLoginList);
			contentViewsCount = String.valueOf(contentInfo.get('contentViewsCount'));
			contentPostsAndRepliesCount = String.valueOf(contentInfo.get('contentPostsAndRepliesCount'));
			contentLikesCount = String.valueOf(contentInfo.get('contentLikesCount'));
			contentSharesCount = String.valueOf(contentInfo.get('contentSharesCount'));
			averageContentPerPerson = getAverageContentPerPerson(contentInfo.get('contentViewsCount'), usersWhoViewedContent);
				   
			Integer previousMonthInt = Integer.valueOf(DateTime.now().addMonths(-1).format('yyyyMM'));
				List<Adoption_Email__c> adoptionEmailObj = [SELECT Id FROM Adoption_Email__c WHERE Adoption_Email_Month__c = :previousMonthInt];
				
			if(adoptionEmailObj.isEmpty()){
						
				AdoptionEmailWrapper adoptionEmailWrapperObj = new AdoptionEmailWrapper();
				adoptionEmailWrapperObj.allUserCount = allUserCount;
				adoptionEmailWrapperObj.usersLoggedInPercentage = usersLoggedInPercentage;
				adoptionEmailWrapperObj.usersWhoViewedContent = usersWhoViewedContent;
				adoptionEmailWrapperObj.usersWhoViewedContentPercentage = usersWhoViewedContentPercentage;	
				adoptionEmailWrapperObj.contentViewsCount = contentViewsCount;
				if(SimpplrContext.isFeedEnabled){
					adoptionEmailWrapperObj.contentPostsAndRepliesCount = contentPostsAndRepliesCount;
					adoptionEmailWrapperObj.contentSharesCount = contentSharesCount;
				}
				adoptionEmailWrapperObj.contentLikesCount = contentLikesCount;
				adoptionEmailWrapperObj.averageContentPerPerson = averageContentPerPerson;  	        	
					
				Adoption_Email__c adoptionEmailRec = new Adoption_Email__c();
				adoptionEmailRec.Adoption_Email_Month__c = previousMonthInt;
				adoptionEmailRec.Adoption_Email_JSON__c = JSON.serialize(adoptionEmailWrapperObj);
				
				List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

				fieldList.add(Adoption_Email__c.Adoption_Email_Month__c);
				fieldList.add(Adoption_Email__c.Adoption_Email_JSON__c);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
 				SIMPESAPI.accessController().insertAsUser(adoptionEmailRec, fieldList);
			}

		}else if ('sendMonthlyAdoptionEmail'.equalsIgnoreCase(recordType)){
			initLangKeyValueMap(analyticsPeopleList);
			currentAdoptionEmailWrapperObj = getAdoptionInfoForMonth(Integer.valueOf(DateTime.now().addMonths(-1).format('yyyyMM')));
    		List<Messaging.SingleEmailMessage> adoptionEmailList = new List<Messaging.SingleEmailMessage>();
    		allUserCount = currentAdoptionEmailWrapperObj.allUserCount ;
    		usersLoggedInPercentage = currentAdoptionEmailWrapperObj.usersLoggedInPercentage ;
			usersWhoViewedContent = currentAdoptionEmailWrapperObj.usersWhoViewedContent;			
    		usersWhoViewedContentPercentage = currentAdoptionEmailWrapperObj.usersWhoViewedContentPercentage ;
    		
    		contentViewsCount = currentAdoptionEmailWrapperObj.contentViewsCount ; 
    		contentPostsAndRepliesCount = currentAdoptionEmailWrapperObj.contentPostsAndRepliesCount ;
    		contentLikesCount = currentAdoptionEmailWrapperObj.contentLikesCount ;
    		contentSharesCount = currentAdoptionEmailWrapperObj.contentSharesCount ;
			averageContentPerPerson = currentAdoptionEmailWrapperObj.averageContentPerPerson ;
			List<Simpplr_Content__c> popularContentList = getMostPopularContent();
			Map<Id, String> contentIdWithPublicUrlMap = getcontentIdNPublicUrlMap(popularContentList);
			//String listOfContentsEnabled = getListOfContentsEnabled();
				
			for(People__c analyticsPeople : analyticsPeopleList ){
				String userLanguage = Utility.getSimpplrLanguageLocaleKey(analyticsPeople.user__r.languagelocalekey);
				List<String> formatterList = new List<String>();
				brandingInfo = Emailutility.getBrandingInfo4People(analyticsPeople);
				String logoUrl = String.isNotBlank(brandingInfo.logo_url) ? brandingInfo.logo_url : EmailTemplateService.simpplrDefaultLogoUrl;
				String adoptionEmailBody = '';
				String togetherTheyAddedString = getTogetherTheyAddedString(contentPostsAndRepliesCount, 
						contentLikesCount, contentSharesCount,userLanguage,brandingInfo);
				String popularContentString = getPopularContentBody(popularContentList, contentIdWithPublicUrlMap, 
						analyticsPeople.user__r.timeZonesidkey,userLanguage,brandingInfo);
								
				formatterList.clear();
				formatterList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(), userLanguage));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_MONTHLY_INTRO).replace('{{appName}}',SimpplrContext.applicationName));
				Date previousMonthStart = Date.today().addMonths(-1).toStartOfMonth();
				DateTime previousMonthStartDateTime = DateTime.newInstance(previousMonthStart.year(), previousMonthStart.month(), previousMonthStart.day());
				String previousMonthStartStr = LocaleContext.getLocalisedDateAsDDMMMM(previousMonthStartDateTime, userLanguage);
				
				Date previousMonthEnd = Date.today().toStartOfMonth().addDays(-1);
				DateTime previousMonthEndDateTime = DateTime.newInstance(previousMonthEnd.year(), previousMonthEnd.month(), previousMonthEnd.day());
				String previousMonthEndStr = LocaleContext.getLocalisedDateAsDDMMMMYYYY(previousMonthEndDateTime, userLanguage);

				formatterList.add(previousMonthStartStr + ' - ' + previousMonthEndStr);
				/*3*/formatterList.add(LocaleContext.getLabel(userLanguage,KEY_THIS_MONTH));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_MONTHLY_REVIEW_ACTIVITY).replace('{{count}}',usersLoggedInPercentage));
				formatterList.add(contentViewsCount); 
				formatterList.add(averageContentPerPerson);
				formatterList.add(togetherTheyAddedString);
				formatterList.add(popularContentString);
				formatterList.add(PageContext.getPageURL(Pages.app) + '?u=/analytics'+'&utm_medium=email&utm_source=monthly_report');
				formatterList.add('<style>@media all { .ExternalClass {width: 100%;}.ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td,.ExternalClass div {line-height: 100%;}.apple-link a {color: inherit !important; font-family: inherit !important;font-size: inherit !important; font-weight: inherit !important; line-height: inherit !important;text-decoration: none !important; } } @media only screen and (max-width: 620px) {table[class=body] .wrapper, table[class=body] .header,table[class=body] .article {padding: 10px !important; }table[class=body] .content {padding: 0 !important;} table[class=body] .container { padding: 0 !important; width: 100% !important;}table[class=body] .main {border-left-width: 0 !important;border-radius: 0 !important;border-right-width: 0 !important; }table[class=body] .btn table { width: 100% !important;} table[class=body] .btn a {width: 100% !important; }  table[class=body] .img-responsive {height: auto !important; max-width: 100% !important; width: auto !important;}td[class="mobile-hide"] { display: none;}.mobile-hide {display: none;}.wrapper,.header,.article {padding: 10px !important;}.content { padding: 0 !important;}.container {padding: 0 !important;width: 100% !important;}.main { border-left-width: 0 !important;border-radius: 0 !important; border-right-width: 0 !important; }.btn table {width: 100% !important;}.btn a { width: 100% !important;}.img-responsive { height: auto !important;max-width: 100% !important;width: auto !important;}}a[x-apple-data-detectors] { color: inherit !important;text-decoration: none !important;font-size: inherit !important;font-family: inherit !important; font-weight: inherit !important;line-height: inherit !important;}</style>'); 
				formatterList.add('<style type="text/css">@media screen and (max-width: 525px) {[class="StatTile"] {width: 100% !important; display: block;margin: 0 0 4px; }}</style><style type="text/css">@media screen and (max-width: 525px) {.Stat-heading--small { font-size: 14px !important;} .Stat--leftAlign {border-right: 0 !important; width: 100% !important; display: block; }.Stat--leftAlign:first-child { border-bottom: 1px solid #CCCCCC !important; }}</style>');
				formatterList.add(logoUrl);
				/*13*/formatterList.add(usersWhoViewedContentPercentage);
				formatterList.add(getListOfContentsEnabled(userLanguage));
				
				if (previousAdoptionEmailWrapperObj != NULL) {
					// Percentage change of users Who Viewed Content calculations 
					String usersWhoViewedContentPercentageChangeStr;
					
					if (previousAdoptionEmailWrapperObj.usersWhoViewedContentPercentage != NULL 
							&& usersWhoViewedContentPercentage != NULL) {
						Integer usersWhoViewedContentPercentageChange = Integer.valueOf(usersWhoViewedContentPercentage) - 
							Integer.valueOf(previousAdoptionEmailWrapperObj.usersWhoViewedContentPercentage) ;
						usersWhoViewedContentPercentageChangeStr = getUsersWhoViewedContentPercentageChange(usersWhoViewedContentPercentage,
								previousAdoptionEmailWrapperObj.usersWhoViewedContentPercentage,userLanguage,brandingInfo);
					}
					formatterList.add(String.isNotBlank(usersWhoViewedContentPercentageChangeStr) ? 
								usersWhoViewedContentPercentageChangeStr : '');//{15}
							
					// Percentage change of content views calculations
					String contentViewCountPercentageChangeStr;
					if (previousAdoptionEmailWrapperObj.contentViewsCount != NULL && contentViewsCount != NULL) {
						String contentViewCountPercentageChange = getPercentageChange(Integer.valueOf(
								previousAdoptionEmailWrapperObj.contentViewsCount),Integer.valueOf(contentViewsCount)) ;
						contentViewCountPercentageChangeStr = getPercentChangeHtml(contentViewCountPercentageChange,userLanguage,brandingInfo);
					}
					formatterList.add(String.isNotBlank(contentViewCountPercentageChangeStr) ? 
								contentViewCountPercentageChangeStr : '');// {16}
							
					// Percentage change in average content per person calculations
					String averageContentPerPersonChangeStr;
					
					if (previousAdoptionEmailWrapperObj.averageContentPerPerson != NULL && 
							averageContentPerPerson != NULL) {
						String averageContentPerPersonChange = getPercentageChange(Integer.valueOf(
								previousAdoptionEmailWrapperObj.averageContentPerPerson),Integer.valueOf(
								averageContentPerPerson)) ;
						averageContentPerPersonChangeStr = getPercentChangeHtml(averageContentPerPersonChange,userLanguage,brandingInfo);
					}
					
					formatterList.add(String.isNotBlank(averageContentPerPersonChangeStr) ? 
							averageContentPerPersonChangeStr : '');// {17}		
				}
				formatterList.add('' + SimpplrContext.salesforceBaseUrl  + Page.app.getUrl()+'?u=/people/'+ analyticsPeople.id +'/?origin=mae');//{18}
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_THAT_IS_TOTAL));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_CONTENT_VIEWS));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_MONTHLY_AVERAGE_OF));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_VIEWS_PER_USER));
				/*23*/formatterList.add(LocaleContext.getLabel(userLanguage,KEY_MONTHLY_TOGETHER_THEY));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_DEEPER_SIGHT).replace('{{appName}}',SimpplrContext.applicationName));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_VIEW_ANALYTICS_BUTTON));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_POWERED_BY));
				formatterList.add(LocaleContext.getLabel(userLanguage,KEY_FOOTER_SETTINGS).replace('{{appName}}',SimpplrContext.applicationName));
				// link to settings
				/*29*/formatterList.add('' + SimpplrContext.salesforceBaseUrl  + Page.MySettingsEmail.getUrl()+'?profileId='+analyticsPeople.id);
				formatterList.add(brandingInfo.general_primaryColor);

				// 31 mobile promotion footer
				formatterList.add(EmailUtility.getMobilePromotionFooterDiv(userLanguage, analyticsPeople.id));
				// header background // 32
		    	if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
					formatterList.add('000000');// 32
				} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
					formatterList.add(brandingInfo.general_primaryColor);// 32
				} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
					formatterList.add('ffffff');// 32
				} else {
					formatterList.add(brandingInfo.header_backgroundColor);
				}
				adoptionEmailBody = EmailUtility.format(adoptionEmailTemplateMap.get('emailBodyWithHeaderFooter'), formatterList);
				
				if(String.isNotBlank(adoptionEmailBody)) { 
					String previousMonthStr = LocaleContext.getLocalisedDateAsMMMMYYYY(previousMonthStartDateTime, userLanguage);
					String subject = LocaleContext.getLabel(userLanguage,KEY_MONTHLY_SUBJECT).replace('{{appName}}',SimpplrContext.applicationName).replace('{{monthYear}}', previousMonthStr);
		    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
					singleMail.setTargetObjectId(analyticsPeople.User__c);
					singleMail.setSubject(subject);
					if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
						singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
					}
					if(SimpplrContext.DeeplinkingEnabled) {
						adoptionEmailBody = EmailUtility.deeplinkedMailBody(adoptionEmailBody);
					}
					
					singleMail.setHtmlBody(adoptionEmailBody);
					singleMail.setCharset('UTF-8');
					singleMail.setUseSignature(false);
					singleMail.setSaveAsActivity(false);			
					adoptionEmailList.add(singleMail);
	        	} 
	        	
    		}
    		
	        if(adoptionEmailList.size() > 0) {
	        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(adoptionEmailList);
			}
		}    
    		
    	} catch(Exception ex) {
			exceptionDetailsObj =  ex;
    		throw ex;
		}		
    }
    
    public void finish(Database.BatchableContext BC){		
		Date currentDate = Date.today();
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		
		String appConfigQuery = 'SELECT Id, Adoption_Email_Next_Run_Date__c FROM App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfigRec = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

		if(!(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0)) {
			Utility.sendExceptionEmail('BatchAdoptionEmail', exceptionDetailsObj);
					
		} else if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			sendAdoptionEmailDataToAWS();
		}
		
		if(isSendOnlyToMe == false && currentDate == appConfigRec.Adoption_Email_Next_Run_Date__c && 'sendMonthlyAdoptionEmail'.equalsIgnoreCase(recordType)) {
			Date adoptionEmailNextRunDate = Utility.adoptionEmailNextRunDate();	
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
        
			appConfigRec.Adoption_Email_Next_Run_Date__c = adoptionEmailNextRunDate;
			fieldList.add(App_Config__c.Adoption_Email_Next_Run_Date__c);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(appConfigRec, fieldList);
		}

		if('sendMonthlyAdoptionEmail'.equalsIgnoreCase(recordType)){
    	BatchSiteAdoptionEmail siteAdoptionEmailForSiteManagers = new BatchSiteAdoptionEmail('toAppManagers',isSendOnlyToMe,true);		
		Database.executeBatch(siteAdoptionEmailForSiteManagers,50);
		}
    }
    private void sendAdoptionEmailDataToAWS() {
    	List<Adoption_Email__c> adoptionEmailList = [select id, Adoption_Email_Month__c, Adoption_Email_JSON__c, Sync_Status__c 
    												 from Adoption_Email__c where Sync_Status__c !=:SYNC_STATUS_SENT ];
    	PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
    	analyticsHandler.sendAdoptionEmailListToAWS(adoptionEmailList);
    }
    
    public Integer getAllUserCount(){
		AggregateResult groupedResults = [SELECT MAX(Total_Simpplr_Users__c) totalUsers from Analytics_Login__c WHERE Date__c=LAST_MONTH];  
		Integer allUserCount = Integer.valueOf(groupedResults.get('totalUsers')); 
		return  allUserCount; 		   	
    }
        
    public String getUsersLoggedInPercentage(Integer allUserCount){
    	Long usersLoggedInPercentage = 0;
    	String queryString = 'SELECT count() FROM People__c WHERE Id IN (SELECT People__c FROM Analytics_Adoption__c where Date__c = LAST_MONTH) ';

    	Integer loginCount = Database.countQuery(queryString);

    	if(allUserCount !=null && allUserCount > 0) {
			if(loginCount > allUserCount){  //Upper Check for Adoption Percentage 
				allUserCount = loginCount; 
			}
			Decimal usersLoggedIn = ((loginCount * 100.0)/allUserCount).setScale(2);
			usersLoggedInPercentage = usersLoggedIn.round(System.RoundingMode.HALF_UP);
    	}
    	
    	return String.valueOf(usersLoggedInPercentage);
    }
    
    public Integer getUsersWhoViewedContent(DateTime monthDateTime){
    	Integer monthInt = Integer.valueOf(String.valueOf(monthDateTime.format('yyyyMM')));
    	Integer usersWhoViewedContent = [SELECT count() FROM People_Interaction__c WHERE Content_Accessed_Month__c = :monthInt];
    	 
    	return usersWhoViewedContent;			
    }
        
    public Map<String, Decimal> getContentInfo(List<Analytics_Login__c> analyticsLoginList){
    	Decimal contentViewsCount = 0;
    	Decimal contentPostsAndRepliesCount = 0;
    	Decimal contentLikesCount = 0;
    	Decimal contentSharesCount = 0;
    	Map<String, Decimal> contentInfo = new Map<String, Decimal>();
    	  
    	for(Analytics_Login__c analyticsLoginObj : analyticsLoginList){
    		contentViewsCount += analyticsLoginObj.Content_Views__c == null ? 0: analyticsLoginObj.Content_Views__c;	
    		contentPostsAndRepliesCount += ((analyticsLoginObj.Posts__c == null ? 0 : analyticsLoginObj.Posts__c) + (analyticsLoginObj.Replies__c == null ? 0: analyticsLoginObj.Replies__c));
    		contentLikesCount += analyticsLoginObj.Likes__c == null ? 0 : analyticsLoginObj.Likes__c;
    		contentSharesCount += analyticsLoginObj.Shares__c == null ? 0 : analyticsLoginObj.Shares__c;
    	}	
    	
    	contentInfo.put('contentViewsCount', contentViewsCount);
    	contentInfo.put('contentPostsAndRepliesCount', contentPostsAndRepliesCount);
    	contentInfo.put('contentLikesCount', contentLikesCount);
    	contentInfo.put('contentSharesCount', contentSharesCount);
    	
    	return contentInfo;
    } 

	public String getUsersWhoViewedContentPercentage(Integer usersWhoViewedContent, Integer allUserCount){
		Long usersWhoViewedContentPercentage = 0;
		
		if(allUserCount != null && allUserCount > 0 && allUserCount > 0) {
			Decimal usersWhoViewedContentPerc = (usersWhoViewedContent * 100.0)/allUserCount;
			usersWhoViewedContentPercentage = usersWhoViewedContentPerc.round(System.RoundingMode.HALF_UP);
		}
		
		return String.valueOf(usersWhoViewedContentPercentage);		
	}  
	
    public String getAverageContentPerPerson(Decimal contentViewsCount, Integer usersWhoViewedContent){ 
    	Long averageContentPerPersonCount = 0;
		
		Decimal averageCount = (usersWhoViewedContent == 0)? 0.0 :((contentViewsCount * 1.0)/usersWhoViewedContent).setScale(2);
		averageContentPerPersonCount = averageCount.round(System.RoundingMode.HALF_UP);
		
		return String.valueOf(averageContentPerPersonCount);
    }
    
	public String getTogetherTheyAddedString(String contentPostsAndRepliesCount, String contentLikesCount, 
			String contentSharesCount,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo){
		String togetherTheyAdded = '';
		List<String> formatterList = new List<String>();
		formatterList.clear();
		String contentPostsAndRepliesCountChangeStr;
		String contentSharesCountChangeStr;
		String contentLikesCountChangeStr = getLikesCountChangeStr(contentLikesCount,languagelocalekey,brandingInfo);
		
		if(SimpplrContext.isFeedEnabled){
			contentPostsAndRepliesCountChangeStr = getContentPostsAndRepliesCountChangeStr(contentPostsAndRepliesCount,languagelocalekey,brandingInfo);
			contentSharesCountChangeStr = getContentSharesCountChangeStr(contentSharesCount,languagelocalekey,brandingInfo);
			
			formatterList.add(contentPostsAndRepliesCount);
			formatterList.add(contentLikesCount);
			formatterList.add(contentSharesCount);
			formatterList.add(contentPostsAndRepliesCountChangeStr);
			formatterList.add(contentLikesCountChangeStr);
			formatterList.add(contentSharesCountChangeStr);
			/*6*/formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_POSTS_AND_REPLIES));
			formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_SHARES));
			formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_LIKES));
			togetherTheyAdded = EmailUtility.format(adoptionEmailTemplateMap.get('togetherTheyAddedWithFeedEnabled'), formatterList);
		
		} else {
			formatterList.add(contentLikesCount);
			formatterList.add(contentLikesCountChangeStr);
			formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_LIKES));
			togetherTheyAdded = EmailUtility.format(adoptionEmailTemplateMap.get('togetherTheyAddedWithFeedDisabled'), formatterList);			
		}
		
		return togetherTheyAdded; 
	}    
    public List<Simpplr_Content__c> getMostPopularContent(){
    	List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', allowedFeaturesInAppList);
		String blogSubCondition = '';
		if(SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_BLOG)) {
			blogSubCondition = ' or Content__r.type__c = \'BlogPost\' ';
		}
		String query = 	' select content__c contentId from Analytics_Top_Content__c ' +
    					' where Date__c = LAST_MONTH ' +
    					' And content__r.TYPE__c IN : soqlParam1 ' +
    					' And content__r.Is_Deleted__c = false ' +
    					' And ((Content__r.Site__r.Is_Active__c = true And Content__r.Site__r.Show_In_Simpplr__c = true And Content__r.Site__r.Site_Type__c = \'Public\') ' + blogSubCondition + ' ) ' +
    					' And Content__r.Is_Published__c = true ' +
						' And Content__r.Activated_By_Feature__c = true ';
						
		query 	+=		' group by content__c ' + 
						' order by sum(Popularity_Score__c) desc ' +
						' LIMIT 3 ';						
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<AggregateResult> aggrList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	List<String> listOfContentIds = new List<String>(); 
    	for(AggregateResult ar: aggrList) {
    		listOfContentIds.add((String)ar.get('contentId'));
    	}
    	
		String contentQuery = 'select id,Is_Must_Read__c,Event_Is_All_Day__c,Popularity_Score__c, Title__c, Type__c,Text_Intro__c, Site__c, Site__r.Name,Publish_Start_DateTime__c, Last_Edited_DateTime__c, '+
								' Event_Start_Datetime__c,Event_End_Datetime__c,Event_TimezoneSidKey__c,Primary_Author__c,Primary_Author__r.Full_Name__c,Display_Excerpt__c, Site__r.Chatter_Group_Id__c,Primary_Author__r.External_Photo_URL__c, createdDate, Site__r.Site_Type__c, ' +   
								' Site__r.Title_Content_Version__c, ' +
								' (SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c, Thumbnail_URL__c FROM File_Simpplr_Content__r ' + 
								'  WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c ) ' +
								' from Simpplr_Content__c where Id In :listOfContentIds ' +
								' order by Popularity_Score__c desc,  Publish_Start_DateTime__c desc, Title__c asc';
								
		List<Simpplr_Content__c> popularContentList = Database.query(contentQuery);
		
		return popularContentList;	
    }
    
    private Map<Id, String> getcontentIdNPublicUrlMap(List<Simpplr_Content__c> contentList) {
    	Map<Id, String> contentIdWithPublicUrlMap = new Map<Id, String>();
    	Map<Id, Id> contentIdAndCVIdMap = new Map<Id, Id>();
    	for(Simpplr_Content__c contentObj : contentList) {
    		if(!contentIdWithPublicUrlMap.containsKey(contentObj.Id)){
	    		List<File__c> fileList = contentObj.File_Simpplr_Content__r;
				if(!fileList.isEmpty()) {
					// below 'for' loop will execute max 2 times per iteration
					for(File__c fileObj : fileList) {
						if(fileObj.Is_Title_Image__c){
							if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)){
								if(String.isNotBlank(fileObj.Content_Version__c)) {
									contentIdAndCVIdMap.put(contentObj.Id, fileObj.Content_Version__c);
								} else {
									contentIdWithPublicUrlMap.put(contentObj.id, fileObj.Thumbnail_URL__c);
								}
								break;
							} /*else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.Type__c)){
								break;	
							} */else {
								contentIdAndCVIdMap.put(contentObj.Id, fileObj.Content_Version__c);
								break;
							}
						}
					}
				} else {
					Simpplr_Site__c siteObj = contentObj.Site__r;
					if(siteObj != null && String.isNotBlank(siteObj.Title_Content_Version__c) && contentObj.Type__c != 'Event') {
						contentIdAndCVIdMap.put(contentObj.Id, siteObj.Title_Content_Version__c);
					}
				}
				
    		}
    	}
    	Map<Id, String> cvIdNPublicUrlMap;
    	if(contentIdAndCVIdMap.size()>0){
    		cvIdNPublicUrlMap = FileContentProvider.generateEmbedPublicUrl(contentIdAndCVIdMap.values());
    	
	    	for(Id contentId : contentIdAndCVIdMap.keySet()){
	    		contentIdWithPublicUrlMap.put(contentId,cvIdNPublicUrlMap.get( contentIdAndCVIdMap.get(contentId)));
	    	}
    	}
    	
    	return contentIdWithPublicUrlMap;
    }
    
    public static String getPopularContentBody(List<Simpplr_Content__c> popularContentList, Map<Id, String> contentIdWithPublicUrlMap, String timeZonesidkey,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo){
    	 
    	List<String> formatterList = new List<String>();
    	String popularContentString = '';
    	if(!popularContentList.isEmpty()){
    		popularContentString += String.format('<tr> <td valign="top" s="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; border-top: 1px solid #cccccc; max-width: 600px !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt;" width="100%" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 18px; font-weight: 400; line-height: 25px; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 26px 0; text-align: center;vertical-align: top; word-break: break-word;" class="Heading Heading--medium Heading--centred">{0}</td></tr></tbody> </table> </td> </tr>',new String[]{LocaleContext.getLabel(languagelocalekey,KEY_MOST_POPULAR_CONTENT)});
			for(Simpplr_Content__c popularContent : popularContentList){
				if('BlogPost'.equalsIgnoreCase(popularContent.Type__c)){
					String blogPostString = '';
					String blogPostPublishedDate = LocaleContext.getLocalisedDateAsMMMDDYYYY(popularContent.Publish_Start_DateTime__c, languagelocalekey, timeZonesidkey);
					formatterList.clear();
					
					if(String.isNotBlank(contentIdWithPublicUrlMap.get(popularContent.Id))){
						formatterList.add(contentIdWithPublicUrlMap.get(popularContent.Id));
					} else {
						formatterList.add(EmailTemplateService.blogDefaultIconSquareIcon);
					}
					formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_BLOGPOST_KEYWORD));
					formatterList.add(SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?peopleId=' + popularContent.Primary_Author__c +'&contentId='+popularContent.id+'&pageToRedirect=ContentDetailPage'+'&origin=mae'+'&utm_medium=email&utm_source=analytics_monthly_report&utm_content=adoption_email');  
					formatterList.add(popularContent.Title__c);
					if(String.isNotBlank(popularContent.Display_Excerpt__c)){
						formatterList.add(popularContent.Display_Excerpt__c);	
					} else{
						formatterList.add('');		
					}
					formatterList.add(SimpplrContext.salesforceBaseUrl   + Page.app.getUrl()+'?u=/people/'+ popularContent.Primary_Author__c+'&origin=mae');
					formatterList.add(popularContent.Primary_Author__r.Full_Name__c);
					formatterList.add(blogPostPublishedDate);
					if(popularContent.Is_Must_Read__c){
						formatterList.add(String.format('<span class="type--mustRead" style="color: #333;">{0}</span>',new String[]{LocaleContext.getLabel(languagelocalekey,KEY_MUST_READ)}));
					}else{
						formatterList.add('');
					}
					/*9*/ formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_BY));
					formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_ON));
					if(popularContent.Publish_Start_DateTime__c != popularContent.Last_Edited_DateTime__c){
						/*11*/ formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_EDITED));
					}else{
						formatterList.add('');
					}
					formatterList.add(brandingInfo.general_primaryColor);
					blogPostString = EmailUtility.format(adoptionEmailTemplateMap.get('blogPost'), formatterList);
					 
					popularContentString+=blogPostString;	
				} else if('Event'.equalsIgnoreCase(popularContent.Type__c)){
					String eventString = '';
					
					String eventStartDate = LocaleContext.getLocalisedDateAsMMMDDYYYY(popularContent.Event_Start_DateTime__c, languagelocalekey, popularContent.Event_TimezoneSidKey__c);
					String eventMonth = String.isNotBlank(eventStartDate)?eventStartDate.subString(0,3):'';
					String eventDay = String.isNotBlank(eventStartDate)?eventStartDate.subString(4,6):'';
					
					formatterList.clear();
					
					String linkToContent = SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?siteId=' + popularContent.site__c +'&contentId='+popularContent.id+'&pageToRedirect=ContentDetailPage'+'&origin=mae&contentType='+popularContent.Type__c.toLowerCase()+'&utm_medium=email&utm_source=analytics_monthly_report&utm_content=adoption_email';
					if(String.isNotBlank(contentIdWithPublicUrlMap.get(popularContent.Id))){
						formatterList.add(String.format('<a href="{0}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody><tr><td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{1}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td> </tr> </tbody> </table> </a>',new String[]{linkToContent,contentIdWithPublicUrlMap.get(popularContent.Id)}));
					} else {
						formatterList.add(String.format(' <table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #fff; border: 1px solid #e6e6e6; border-collapse: separate; border-radius: 2px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-decoration: none; width: 100%;"> <tr><td align="center" valign="top" class="CalendarMonth" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #1abc9c; border-collapse: collapse; color: #fff; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: normal; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px 0; text-align: center; text-transform: uppercase; vertical-align: top;"><a href="{0}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #fff; text-decoration: none;">{1} </a> </td> </tr> <tr> <td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 60px; font-weight: 100; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: center; vertical-align: top;"> <a href="{0}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; text-decoration: none;">{2}</a></td></tr></table>',new String[]{linkToContent,eventMonth,eventDay}));
					}
					formatterList.add(linkToContent);
					formatterList.add(popularContent.Title__c);
					if(popularContent.Event_Is_All_Day__c){

						formatterList.add(String.format('<div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{0}</span> </div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{1}</span> </div>',new String[]{LocaleContext.getLabel(languagelocalekey,KEY_ALL_DAY),LocaleContext.getLocalisedDayAndDate(popularContent.Event_Start_DateTime__c,languagelocalekey,popularContent.Event_TimezoneSidKey__c)}));
					}else{
						formatterList.add(String.format('<div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{0} - {1}</span></div>',new String[]{LocaleContext.getLocalisedDayAndDate(popularContent.Event_Start_DateTime__c,languagelocalekey,popularContent.Event_TimezoneSidKey__c),LocaleContext.getLocalisedDayAndDate(popularContent.Event_End_DateTime__c,languagelocalekey,popularContent.Event_TimezoneSidKey__c)}));
					}
					if(String.isNotBlank(popularContent.Display_Excerpt__c)){
						formatterList.add(popularContent.Display_Excerpt__c);	
					} else{
						formatterList.add('');		
					}
					
					eventString = EmailUtility.format(adoptionEmailTemplateMap.get('event'), formatterList);
					 
					popularContentString+=eventString;							
				} else{
					String contentString = '';
					
					formatterList.clear();
					
					if(String.isBlank(contentIdWithPublicUrlMap.get(popularContent.Id)) &&
							 'Page'.equalsIgnoreCase(popularContent.Type__c)){
						formatterList.add(EmailTemplateService.pageDefaultIconSquareIcon);
					} else {
						formatterList.add(contentIdWithPublicUrlMap.get(popularContent.Id));
					}
					
					formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_PAGE_KEYWORD));
					formatterList.add(SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?siteId=' + popularContent.site__c +'&contentId='+popularContent.id+'&pageToRedirect=ContentDetailPage'+'&origin=mae&contentType='+popularContent.Type__c.toLowerCase()+'&utm_medium=email&utm_source=analytics_monthly_report&utm_content=adoption_email');
					formatterList.add(popularContent.Title__c);
					if(String.isNotBlank(popularContent.Display_Excerpt__c)){
						formatterList.add(popularContent.Display_Excerpt__c);	
					} else{
						formatterList.add('');		
					}
					formatterList.add(SimpplrContext.salesforceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + popularContent.site__c + '&pageToRedirect='+ ServiceConstants.SITE_LANDING_PAGE_STRING + '&origin=mae');							
					formatterList.add(popularContent.Site__r.Name);
					formatterList.add(LocaleContext.getLocalisedDateAsMMMDDYYYY(popularContent.Publish_Start_DateTime__c, languagelocalekey, timeZonesidkey));
					if(popularContent.Is_Must_Read__c){
						formatterList.add(String.format('<span class="type--mustRead" style="color: #333;">{0}</span>',new String[]{LocaleContext.getLabel(languagelocalekey,KEY_MUST_READ)}));
					}else{
						formatterList.add('');
					}
					/*9*/ formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_IN));
					if(popularContent.Publish_Start_DateTime__c != popularContent.Last_Edited_DateTime__c){
						/*10*/ formatterList.add(LocaleContext.getLabel(languagelocalekey,KEY_EDITED));
					}else{
						formatterList.add('');
					}
					formatterList.add(brandingInfo.general_primaryColor);
					contentString = EmailUtility.format(adoptionEmailTemplateMap.get('pageORAlbum'), formatterList);
					
					popularContentString+=contentString;	
				}
			}    	
    	}

		
		return popularContentString;    	
    } 
    
    private String getListOfContentsEnabled(String languagelocalekey){
		String strToPassAsPerEnabledCOntents = '';
		String allowedFeaturesInAppList =  String.valueOf(SimpplrContext.AllowedFeatures);
		Set<String> enabledContents = new Set<String>();
		if(allowedFeaturesInAppList.containsIgnoreCase('Blog')) {
		    enabledContents.add('Blog');
		}
		if(allowedFeaturesInAppList.containsIgnoreCase('Album')) {
		    enabledContents.add('Album');
		}
		if(allowedFeaturesInAppList.containsIgnoreCase('Event')) {
		    enabledContents.add('Event');
		}
		if(allowedFeaturesInAppList.containsIgnoreCase('Page')) {
		    enabledContents.add('Page');
		}

		Integer totSize = enabledContents.size();

		switch on totSize {
			when 1 {
				if(enabledContents.contains('Album')){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_ALBUM).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.contains('Event')){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_EVENT).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.contains('Blog')){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_BLOG).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.contains('Page')){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_PAGE).replace('{{appName}}',SimpplrContext.applicationName);
				}
			}	
			when 2 {
				if(enabledContents.containsAll(new Set<String>{'Album', 'Event'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_EVENT_ALBUM).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Album', 'Blog'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_ALBUM_BLOG).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Album', 'Page'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_PAGE_ALBUM).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Event', 'Blog'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_EVENT_BLOG).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Event', 'Page'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_PAGE_EVENT).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Page', 'Blog'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_PAGE_BLOG).replace('{{appName}}',SimpplrContext.applicationName);
				}	
			}
			when 3 {
				if(enabledContents.containsAll(new Set<String>{'Album', 'Event','Blog'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_EVENT_ALBUM_BLOG).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Album', 'Blog','Page'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_PAGE_ALBUM_BLOG).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Album', 'Page','Event'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_PAGE_EVENT_ALBUM).replace('{{appName}}',SimpplrContext.applicationName);
				} else if(enabledContents.containsAll(new Set<String>{'Event', 'Blog','Page'})){
					strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_PAGE_EVENT_BLOG).replace('{{appName}}',SimpplrContext.applicationName);
				}		
			}
			when 4 {
				strToPassAsPerEnabledContents = LocaleContext.getLabel(languagelocalekey,KEY_ALL_CONTENT).replace('{{appName}}',SimpplrContext.applicationName);		  
			}
		}
		return strToPassAsPerEnabledContents;
	}
		
    
    public static String getFormattedContentDate(DateTime dateTimeVal, String userTimeZone, String dateFormat) {
		String formatedDateTime =  dateTimeVal!=null?String.valueOf(dateTimeVal.format(dateFormat,userTimeZone)):'';
		return formatedDateTime;
    }
    
    public String getPercentageChange (Integer oldValue, Integer newValue) {
	    String percentageChangeStr = '0';
	    
	    if (oldValue != null && oldValue > 0 && newValue != null && newValue >= 0) {
	    	Decimal percentageChange = (((newValue - oldValue)*100.0)/oldValue).setScale(2);
		    percentageChangeStr = String.valueOf(percentageChange.round(System.RoundingMode.HALF_UP));
	    }
	    return percentageChangeStr;
	} 
	
	public String getDerivativeHTMLSuffixString(String differenceStr,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo) {
		String derivativeString = '';
    	Integer difference = Integer.valueOf(differenceStr);
    	
		if (difference != NULL) {
			
			if (difference > 0) {
			    derivativeString = '<span style="font-weight: bold; color: #'+brandingInfo.general_primaryColor+';">+'+ difference + 
			    		'%</span> '+ LocaleContext.getLabel(languagelocalekey,KEY_COMMON_DIGEST);
			} else if (difference < 0) {
			    derivativeString = '<span style="font-weight: bold; color: #E15567;">'+ difference + 
			    		'%</span> '+ LocaleContext.getLabel(languagelocalekey,KEY_COMMON_DIGEST) ;
			} else {
			    derivativeString = LocaleContext.getLabel(languagelocalekey,KEY_SAME_AS_LAST_MONTH);
			}
			
		}
		
		return derivativeString;
	}  
	
	public AdoptionEmailWrapper getAdoptionInfoForMonth(Integer lastMonthInt) {
		AdoptionEmailWrapper wrapObj = new AdoptionEmailWrapper();
    	List<Adoption_Email__c> adoptionEmailObj = [SELECT Id,Adoption_Email_Month__c,Adoption_Email_JSON__c 
    			FROM Adoption_Email__c WHERE Adoption_Email_Month__c = :lastMonthInt];
    	
    	if (adoptionEmailObj.size() > 0 && String.isNotBlank(adoptionEmailObj[0].Adoption_Email_JSON__c)) {
    		wrapObj = (AdoptionEmailWrapper)JSON.deserialize(adoptionEmailObj[0].Adoption_Email_JSON__c,
    				AdoptionEmailWrapper.class);
    	}		
    	
    	return wrapObj;		
	}
	
	public String getUsersWhoViewedContentPercentageChange(String newValue,String oldValue,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo){
		String percentChangeHtmlStr = '';
		List<String> formatterList = new List<String>();
		formatterList.clear();
		String difference = String.valueOf(Integer.valueOf(newValue) - Integer.valueOf(oldValue)) ;
		String finalString = getDerivativeHTMLSuffixString(difference,languagelocalekey,brandingInfo);
		formatterList.add(finalString);
		percentChangeHtmlStr = EmailUtility.format(adoptionEmailTemplateMap.get(
				'percentangeChangeForUser'), formatterList);
		
		return percentChangeHtmlStr; 
	}   
	
	public String getPercentChangeHtml(String difference,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo){
		String percentChangeHtmlStr = '';
		List<String> formatterList = new List<String>();
		formatterList.clear();
		String finalString = getDerivativeHTMLSuffixString(difference,languagelocalekey,brandingInfo) ;
		formatterList.add(finalString);
		percentChangeHtmlStr = EmailUtility.format(adoptionEmailTemplateMap.get(
				'percentangeChangeForContent'), formatterList);
		
		return percentChangeHtmlStr; 
	}      
	
	public String getLikesCountChangeStr (String likesCount,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo) {
		String contentLikesCountChangeStr = '';
		
		if (previousAdoptionEmailWrapperObj != NULL) {
			
			if (previousAdoptionEmailWrapperObj.contentLikesCount != NULL && likesCount != NULL) {
				String contentLikesCountChange = getPercentageChange(Integer.valueOf(
						previousAdoptionEmailWrapperObj.contentLikesCount),Integer.valueOf(likesCount));
				contentLikesCountChangeStr = getPercentChangeHtml(contentLikesCountChange,languagelocalekey,brandingInfo);
			}
			
		}
		
		return contentLikesCountChangeStr;
	}
	
	public String getContentPostsAndRepliesCountChangeStr (String postAndRepliesCount,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo) {
		String contentPostsAndRepliesCountChangeStr = '';
		
		if (previousAdoptionEmailWrapperObj != NULL) {
			if (previousAdoptionEmailWrapperObj.contentPostsAndRepliesCount != NULL && postAndRepliesCount != NULL) {
				
				String contentPostsAndRepliesCountChange = getPercentageChange(Integer.valueOf(
						previousAdoptionEmailWrapperObj.contentPostsAndRepliesCount),Integer.valueOf(postAndRepliesCount));
				contentPostsAndRepliesCountChangeStr = getPercentChangeHtml(contentPostsAndRepliesCountChange,languagelocalekey,brandingInfo);
			}
		}
		return contentPostsAndRepliesCountChangeStr;
	}
	
	public String getContentSharesCountChangeStr (String contentSharesCount,String languagelocalekey,NotificationHelper.BrandingInfo brandingInfo) {
		String contentSharesCountChangeStr = '';
		
		if (previousAdoptionEmailWrapperObj != NULL) {
			
			if (previousAdoptionEmailWrapperObj.contentSharesCount != NULL && contentSharesCount != NULL) {
				String contentSharesCountChange = getPercentageChange(Integer.valueOf(
						previousAdoptionEmailWrapperObj.contentSharesCount),Integer.valueOf(contentSharesCount));
				contentSharesCountChangeStr = getPercentChangeHtml(contentSharesCountChange,languagelocalekey,brandingInfo);
			}
		}
		return contentSharesCountChangeStr;
	}
    
}