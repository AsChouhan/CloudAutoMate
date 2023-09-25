public class BatchPendingApprovalDigest implements Database.Batchable<sObject>, Database.stateful{

	private static final String BATCH_TYPE_SITE_MODERATION = 'site_moderation';
	private static final String BATCH_TYPE_CONTENT_MODERATION = 'content_moderation';
    
	//private static final String KEY_REQUEST_PENDING_INTRO = 'email.notification.summary.approval_request_pending.intro';
	private static final String KEY_SITE_REQUEST_PENDING_INTRO_SINGULAR = 'email.notification.summary.site.approval_request_pending.intro_singular';
	private static final String KEY_SITE_REQUEST_PENDING_INTRO_PLURAL = 'email.notification.summary.site.approval_request_pending.intro_plural';
	private static final String KEY_CONTENT_REQUEST_PENDING_INTRO_SINGULAR = 'email.notification.summary.content.approval_request_pending.intro_singular';
	private static final String KEY_CONTENT_REQUEST_PENDING_INTRO_PLURAL = 'email.notification.summary.content.approval_request_pending.intro_plural';
	

	private static final String KEY_REQUEST_PENDING_SUBJECT_PLURAL = 'email.notification.summary.approval_request_pending.subject_plural';
	private static final String KEY_REQUEST_PENDING_SUBJECT_SINGULAR = 'email.notification.summary.approval_request_pending.subject_singular';
	private static final String KEY_REQUEST_ALBUM_APPROVAL = 'email.notification.content.moderation.album.message';
	private static final String KEY_REQUEST_EVENT_APPROVAL = 'email.notification.content.moderation.event.message';
	private static final String KEY_REQUEST_PAGE_APPROVAL = 'email.notification.content.moderation.page.message';
	private static final String KEY_REQUEST_ACCESS_SITE = 'email.notification.summary.approval_request_pending.requested_access';

	private static final String KEY_VIEW_ALL_REQUESTS = 'email.notification.summary.approval_request_pending.view_all_requests';
	private static final String KEY_EMAIL_VIEW_BTN = 'email.common.view_button';
	private static final String KEY_EMAIL_HI = 'email.common.salutation';
	private static final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';
	private static final String KEY_COPYRIGHT_TEXT = 'email.common.footer.copyright';
	private static final String KEY_POWERED_BY = 'email.common.footer.powered_by';
	private static final String KEY_DIGEST_HTML_TITLE = 'email.notification.batch.digest.html_title';
	
	private static final String KEY_EMAIL_MUST_READ_SHARED_WITH_APP = 'email.notification.content.must_read.shared_with_app';
	private static final String KEY_EMAIL_MUST_READ_SHARED_WITH_SITE = 'email.notification.content.must_read.shared_with_site';
	private static final String KEY_EMAIL_ALL_DAY_DIGEST = 'email.common.all_day.digest';
	private static final String KEY_IN = 'common.in';
	private static final String KEY_BY = 'email.common.by';
	private static final String KEY_AT = 'email.common.at_time';

	private Boolean runNextBatchInSequence;
	private String batchContext;

	public Integer frequency;
    public string logoUrl;
    public string query;	
    public String applicationName;
    public App_Config__c appConfig;
    public NotificationHelper.BrandingInfo brandingInfo;
    public string packageName = SimpplrContext.packageName;
    private Exception exceptionDetailsObj;
	
	public Map<Id, String> contentIdWithPublicUrlMap = new Map<Id, String>();


	public static Map<String,String> contentBlockPartMap = new Map<String,String>{
		'ContentType' =>'<span style="border: 1px solid #cccccc; color: #666; font-size: 8px; line-height: 1; padding: 1px 3px; text-align: center; text-decoration: none; text-transform: uppercase; margin-right: 6px;" href="#">{0}</span>',
		'BadgeForEvent' => '<div style="padding-top: 6px; line-height: 0; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;"><span style="color: #999; font-size: 12px; line-height: 1;">{0}</span></div>',
		'ThumbnailTitleImage' =>  '<td class="mobile-hide" width="80" align="right" valign="top" style="padding: 0 0 0 32px;"><a href="{0}" style="overflow: hidden; display: block; max-width: 80px; max-height: 80px; border: none; text-decoration: none;"></a><table width="80" align="center" cellspacing="0" cellpadding="0" border="0" style="border-collapse: collapse; border-spacing: 0; background-color: #ffffff; padding: 0; margin: 0;"><tbody><tr><td width="80" height="80" align="center" valign="middle" style="background-color: #f9f9f9; margin: 0; font-size: 18px; padding: 0; text-decoration: none; color: #ffffff; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;"><img src="{1}" alt="alt" width="80" height="80" style="border: none;"></td></tr></tbody></table></td>',
		'allDayEventRow' => '<tr><td><p style="font-weight:bold;text-decoration:none"></p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;">All Day</span> </div> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;">{10}{11}</span> </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4} </p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'eventWithoutImageRow' => '<tr><td><p style="font-weight:bold;text-decoration:none"></p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #fff; border: 1px solid #e6e6e6; border-collapse: separate; border-radius: 2px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-decoration: none; width: 100%;"> <tbody><tr> <td align="center" valign="top" class="CalendarMonth" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #1abc9c; border-collapse: collapse; color: #fff; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: normal; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px 0; text-align: center; text-transform: uppercase; vertical-align: top;"> <a href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #fff; text-decoration: none;"> {17} </a> </td> </tr> <tr> <td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 60px; font-weight: 100; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: center; vertical-align: top;"> <a href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; text-decoration: none;"> {18} </a> </td> </tr> </tbody></table> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;"> {10} {11}</span> </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'pageWithoutImageRow' => '<tr><td><p style="font-weight:bold;text-decoration:none"></p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="'+ EmailConstants.pageDefaultIconSquareIcon+'" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20} <span class="type--mustRead" style="color: #333;">{19}</span></span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #1abc9c; text-decoration: none;"> {12} </a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'pageRow' => '<tr><td><p style="font-weight:bold;text-decoration:none"></p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20} <span class="type--mustRead" style="color: #333;">{19}</span></span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2}</a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #1abc9c; text-decoration: none;"> {12} </a> {14}</p> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td></tr>',
		'blogPostRow' => '<tr><td><p style="font-weight:bold;text-decoration:none"></p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}</span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;">{2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{22} <a href="{16}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #1abc9c; text-decoration: none;">{15} </a> on {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'blogWithoutImagePostRow' => '<tr><td><p style="font-weight:bold;text-decoration:none"></p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="'+EmailConstants.blogDefaultIconSquareIcon+'" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}</span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{22} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #1abc9c; text-decoration: none;">{15}</a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'albumRow' => '<tr><td><p style="font-weight:bold;text-decoration:none"></p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;">{2}</a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #1abc9c; text-decoration: none;">{12}</a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'viewButtonRow' => '<table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><center><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; box-sizing: border-box; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px !important;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"></td><td align="center" class="btn-spacer" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 15px; padding-top: 15px; text-align: left; vertical-align: top; width: 120px;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px;"><tbody><tr><td class="btn-inner" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #1abc9c; border-collapse: collapse; border-radius: 4px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top; width: 120px;"><a href="{0}" target="_blank" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: {1}; border: solid 1px #1abc9c; border-color: #1abc9c; border-radius: 5px; box-sizing: border-box; color: #ffffff; cursor: pointer; display: inline-block; font-size: 14px; font-weight: normal; margin: 0; padding: 5px 15px; text-decoration: none; text-transform: capitalize; width: 120px;">{2}</a></td></tr></tbody></table></td><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"></td></tr></table></center></td></tr></table>',
		'topMessageRow' => '<table style="border-collapse:separate;width:100%"><tbody><tr> <td class="Post-body" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"> <p style="font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;font-weight:normal;margin:0;margin-bottom:15px"> </p><p>{0}</p> <p></p> </td> </tr></tbody></table>',
		'authorDetailsRow' => '<table style="border-collapse:separate;width:100%"><tbody><tr><td class="Notification-avatar-cell" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top;width:45px"><img class="Notification-avatar CToWUd" src="{0}" style="border:none;border-radius:50%;display:block;height:auto;max-width:100%;outline:none;text-decoration:none;width:45px"></td><td class="Post-header" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;line-height:14px;padding-left:10px;padding-top:4px;text-align:left;vertical-align:middle"><table width="500" style="border-collapse:separate;width:100%"><tbody><tr><td style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"><a class="Post-name" style="color:#222;font-weight:bold;text-decoration:none">{1}</a> &nbsp; <a class="Post-name" style="color:#222;font-weight:normal;text-decoration:none">{2}</a></td></tr><tr><td style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"><span class="Post-date" style="color:#999;font-size:12px">{3}</span></td></tr></tbody></table></td></tr></tbody></table>'
		
	};
    
    public static Map<String,String> pendingApprovalDigestPartMap = new Map<String, String>{
		
		//0=style-text 1=LogUrl 2=Date 3= notificationRowsWithGreeting 4= MyEmailSetting page link 5=MyEmailSetting page link 6=HomemyDashboard link 7= target UserName
		//8=copyright 9=www.simpplr.com 10=Primary color 11=footer BG 12= Footer Text Color 13= Header  BG Color  14= Header Icon Color 15=Link to homemydashboard
		'notificationDigestWithHeaderFooter'=> '<!doctype html> <html> <head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection"> {0} <title>{7}</title> </head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <!-- START CENTERED WHITE CONTAINER --> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <!-- START HEADER --> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{9}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span> </td> </tr> </table> </td> </tr> <!-- END HEADER --> <!-- START MAIN CONTENT AREA --> {3} <!-- END MAIN CONTENT AREA --> </table> <!-- START FOOTER --> <div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{4}.</a> <br>{5} </td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {6} <a href="http://simpplr.com" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">Simpplr</a>. </td> </tr> </table> </div> <!-- END FOOTER --> <!-- END CENTERED WHITE CONTAINER --> </div> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </body> </html>',
		
		//0=targetUserFirstName 1=Total number of actionable pending noti for target User +  requests/request are/is pending for your approval
		'notificationDigestGreeting' =>'<tr> <td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;"> {0}, <br> {1} </h2> </td> </tr>',
		
		
		//0=link to notifications page
		'showAllRequestRow' => '<tr><td style="padding-bottom:24px;"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; border-spacing: 0; float: left;"><tbody><tr><td height="32" align="center" valign="middle" style="background-color: #f5f5f5;"><a href="{0}" style="text-transform: uppercase; text-decoration: none; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; color: #666666; font-size: 14px; line-height: 14px; width: 100%; float: left; padding: 9px 0;">{1}</a></td></tr></tbody></table></td></tr>',
		
		//0= NotiCreator profileImage  1= Noti creator Full Name 2=Link to noti 3= Submitter comment 
		//4=created date 5=link to noti 6=link to noti 7=Primary color
		'notificationRows' => '<tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: left; vertical-align: top;"> <table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="Notification" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: 1px solid #eeeeee; border-collapse: collapse; border-radius: 5px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 10px 0; text-align: left; vertical-align: top;"> <table width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> {0} <td class="Notification-header" v-align="middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; line-height: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-left: 10px; padding-top: 4px; text-align: left; vertical-align: top;"> <table width="500" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <a class="Notification-name" href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #222; font-weight: bold; text-decoration: none;"> {2} </a> {3} </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="Notification-date" style="color: #999; font-size: 12px;">{4}</span> </td> </tr> </table> </td> </tr> </table> <table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <!-- START OF BUTTON --> <tr> <td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <center> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; box-sizing: border-box; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100px !important;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td align="center" class="btn-spacer" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 15px; padding-top: 15px; text-align: left; vertical-align: top; width: 100px;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100px;"> <tbody> <tr> <td class="btn-inner" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #1abc9c; border-collapse: collapse; border-radius: 4px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top; width: 100px;"> <a href="{5}" target="_blank" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #1abc9c; border: solid 1px #1abc9c; border-color: #1abc9c; border-radius: 5px; box-sizing: border-box; color: #ffffff; cursor: pointer; display: inline-block; font-size: 14px; font-weight: normal; margin: 0; padding: 5px 15px; text-decoration: none; text-transform: capitalize; width: 100px;">{6}</a> </td> </tr> </tbody> </table> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </center> </td> </tr> <!-- END OF BUTTON --> </table> </td> </tr> </table> </td> </tr>',
		
		//0=notificationDigestGreeting 1= notificationRows
		'notificationRowsWithGreeting' => '<tr> <td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <!-- START OF INTRO --> {0} <!-- END OF INTRO --> <!-- START OF NOTIFICATION --> {1} <!-- END OF NOTIFICATION --> </table> </td> </tr>',
		
		//0=BG color 1=Link to profile image
		'profileImage' => '<td class="Notification-avatar-cell" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top; width: 45px;"> <img class="Notification-avatar" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; border-radius: 50%; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 45px;"> </td>'
				
	};
	
	public BatchPendingApprovalDigest(String batchContext, Boolean runNextBatchInSequence){
        this.batchContext = batchContext;
		this.runNextBatchInSequence = runNextBatchInSequence;
		
		String appConfigQuery = 'select Simpplr_Emails_Allowed__c,Branding_Logo__c, Branding_JSON__c, App_Name__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

		if(String.isNotBlank(appConfig.Branding_Logo__c)){
        	this.logoUrl = appConfig.Branding_Logo__c;
        } else {
        	this.logoUrl = EmailConstants.simpplrDefaultLogoUrl;
		}
		this.applicationName = appConfig.App_Name__c;
    }

	public Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'Select Id, Email_Content_Submitted_for_Moderation__c, Email_Private_Site_Membership_Requests__c, People__r.User__c,People__r.User__r.UserName, People__r.User__r.timezonesidkey, '+
											' People__r.Segment__c, People__r.Segment__r.Branding_Logo__c, People__r.Segment__r.Branding_JSON__c, ' +
											' People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c, People__r.Last_Name__c, People__r.User__r.languagelocalekey '+
											' FROM People_Preference__c '+
											' WHERE people__r.User__r.isActive=true and people__r.User__r.UserType=\'Standard\' And '+
											' Allow_Simpplr_Emails__c = true and Email_Notification_Digest_Frequency__c = \'Daily\' ';
		if(!Test.isRunningTest() && String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false){
			query += ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName)';
		}
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<People_Preference__c> peoplePrefList){
    	try{
			List<String> localeList = new List<String>();

			//Target User IdSet
			Map<String,String> peopleToUserIdMap = new Map<String,String>();
			List<Messaging.SingleEmailMessage> digestEmailList = new List<Messaging.SingleEmailMessage>();
			Map<String,People_Preference__c> peoplePrefMap = new Map<String,People_Preference__c>();
			for(People_Preference__c peoplePref: peoplePrefList){
				peopleToUserIdMap.put(peoplePref.people__c,peoplePref.people__r.user__c);
				peoplePrefMap.put(peoplePref.people__c,peoplePref);

				localeList.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey));
			}

			// Initialize Locale Context
			LocaleContext.getAllLabelMap('EmailNotifications', localeList);			
			Set<String> peopleIdSet = peopleToUserIdMap.keySet();
			String notificationQuery ='';

			if (BATCH_TYPE_SITE_MODERATION.equalsIgnoreCase(batchContext)) {
				notificationQuery = 'Select id, Type__c, Sub_Type__c, status__c, Object_Type__c, Sent_By__r.External_Photo_URL__c, Sent_By__r.External_Photo_URL_Expiry_Date__c, category__c, '+
									' Submitter_Comment__c, Simpplr_Site__c, Sent_By__r.Full_Name__c, Sent_By__c, Sent_to__c, Object_Id__c, Is_Read__c, Is_New__c, CreatedDate, Simpplr_Site__r.name, '+
									' Action_By__c FROM App_Notification__c  WHERE sub_type__c != \'Must Read\' AND is_Deleted__c = false ' +
									' AND Category__c = \'Private_Site_Membership_Requests\'' +
									' AND (Simpplr_Site__c = null OR (Simpplr_Site__r.is_active__c = true AND Simpplr_Site__r.Show_In_Simpplr__c = true)) ' + 
									' AND type__c=\'Actionable\' AND Action_By__c=null And Sent_By__r.User__r.isActive = true AND Sent_to__r.Id IN: peopleIdSet  '+
									' ORDER BY CreatedDate desc ';
									
			} else if (BATCH_TYPE_CONTENT_MODERATION.equalsIgnoreCase(batchContext)) {
				notificationQuery = 'Select id, Type__c, Sub_Type__c, status__c, Object_Type__c, Sent_By__r.External_Photo_URL__c, Sent_By__r.External_Photo_URL_Expiry_Date__c, category__c, '+
									' Submitter_Comment__c, Simpplr_Site__c, Sent_By__r.Full_Name__c, Sent_By__c, Sent_to__c, Object_Id__c, Is_Read__c, Is_New__c, CreatedDate, Simpplr_Site__r.name, '+
									' Action_By__c FROM App_Notification__c  WHERE sub_type__c != \'Must Read\' AND is_Deleted__c = false ' +
									' AND Category__c != \'Private_Site_Membership_Requests\'' +
									' AND (Simpplr_Site__c = null OR (Simpplr_Site__r.is_active__c = true AND Simpplr_Site__r.Show_In_Simpplr__c = true)) ' + 
									' AND type__c=\'Actionable\' AND Action_By__c=null And Sent_By__r.User__r.isActive = true AND Sent_to__r.Id IN: peopleIdSet  '+
									' ORDER BY CreatedDate desc ';
			}

			List<App_Notification__c> notificationList = Database.query(notificationQuery);
			List<App_Notification__c> newNotificationList = new List<App_Notification__c>();
			Map<String, List<App_Notification__c>> notificationMap = new Map<String, List<App_Notification__c>>();
			for(App_Notification__c notification :  notificationList){
				if(peoplePrefMap.get(notification.sent_to__c).Email_Private_Site_Membership_Requests__c && 'CollaborationGroupMemberRequest'.equalsIgnoreCase(notification.Object_Type__c)){
					newNotificationList.add(notification);
				} else if(peoplePrefMap.get(notification.sent_to__c).Email_Content_Submitted_for_Moderation__c && ('Page_Submitted_For_Moderation'.equalsIgnoreCase(notification.category__c) || 
																												   'Event_Submitted_For_Moderation'.equalsIgnoreCase(notification.category__c) || 
																												   'Album_Submitted_For_Moderation'.equalsIgnoreCase(notification.category__c))){
					newNotificationList.add(notification);
				}
			}

			for(App_Notification__c notification :  newNotificationList) {
				if(peopleToUserIdMap.get(notification.sent_to__c) != null){
					if(notificationMap.get(notification.sent_to__c) == null) {
						notificationMap.put(notification.sent_to__c, new List<App_Notification__c>());
					}
					notificationMap.get(notification.sent_to__c).add(notification);
				}
			}
			
			for(People_Preference__c peoplePref : peoplePrefList) {
				
				String digestBody = '';
				String subject = '';
				if(notificationMap.get(peoplePref.people__c) != null){
					String localeKey = Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey);

					digestBody = getDigestBody(frequency, logoUrl, applicationName, peoplePref, notificationMap.get(peoplePref.people__c), localeKey);
					Integer notiCount = notificationMap.get(peoplePref.people__c).size();
					
					if(BATCH_TYPE_SITE_MODERATION.equalsIgnoreCase(batchContext)) {
						if(notiCount == 1) {
							subject = LocaleContext.getLabel(localeKey, KEY_SITE_REQUEST_PENDING_INTRO_SINGULAR).replace('{{count}}', String.valueOf(notiCount));
						} else {
							subject = LocaleContext.getLabel(localeKey, KEY_SITE_REQUEST_PENDING_INTRO_PLURAL).replace('{{count}}', String.valueOf(notiCount));
						}
					} else {
						if(notiCount == 1) {
							subject = LocaleContext.getLabel(localeKey, KEY_CONTENT_REQUEST_PENDING_INTRO_SINGULAR).replace('{{count}}', String.valueOf(notiCount));
						} else {
							subject = LocaleContext.getLabel(localeKey, KEY_CONTENT_REQUEST_PENDING_INTRO_PLURAL).replace('{{count}}', String.valueOf(notiCount));
						}
					}
		
					if(String.isNotBlank(digestBody) && String.isNotBlank(subject)) {
						Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
						singleMail.setTargetObjectId(peoplePref.people__r.User__c);
						singleMail.setSubject(subject);
						if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
							singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
						}
						if(SimpplrContext.DeeplinkingEnabled) {
							digestBody = EmailUtility.deeplinkedMailBody(digestBody);
						}
						singleMail.setHtmlBody(digestBody);
						singleMail.setCharset('UTF-8');
						singleMail.setUseSignature(false);
						singleMail.setSaveAsActivity(false);			
					singleMail.setSaveAsActivity(false);			
						singleMail.setSaveAsActivity(false);			
						digestEmailList.add(singleMail);
					}
				}
			}
			
			if(digestEmailList.size() > 0) {
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(digestEmailList);
			}
        
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    
    }
    
    public void finish(Database.BatchableContext BC){
    	
		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, 
									CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchPendingApprovalDigest', exceptionDetailsObj);
		}

		if (canStartNextBatch && runNextBatchInSequence) {
            if(BATCH_TYPE_SITE_MODERATION.equalsIgnoreCase(batchContext)) {
                BatchPendingApprovalDigest job = new BatchPendingApprovalDigest(BATCH_TYPE_CONTENT_MODERATION, true);
                Database.executeBatch(job,200);
			}
		}
    }
    
    
    @TestVisible 
    private String getDigestBody(Integer frequency, String logoUrl, String applicationName, People_Preference__c peoplePrefObj,
    							List<App_Notification__c> notificationList, String localeKey) {

		brandingInfo = EmailUtility.getBrandingInfo4People(peoplePrefObj.People__r);
    	String pendingApprovalDigestHtmlBody = '';
    	String notificationRows = '';
    	String showAllRequestRow = '';
    	Integer digestSize = 0;
    	if(frequency == 0) {
    		digestSize = 10;
    	} else {
    		digestSize = 20;
    	}
    	integer counter = 0;
    	
    	Map<String,Simpplr_Content__c> contentIdWithObjectMap;
    	Set<String> contentIds = new Set<String>();
    	String contentPrefix = Utility.getSimpplrContentPrefix();
    	for(App_Notification__c notification : notificationList){
    		if(notification.Object_Id__c.subString(0,3).equalsIgnoreCase(contentPrefix)) {
    			contentIds.add(notification.Object_Id__c);
    		}
    	}
		contentIdWithObjectMap = new Map<String,Simpplr_Content__c>([SELECT id, Type__c, Title__c, Is_Must_Read__c, Site__c, Site__r.Name, Site__r.Site_Type__c, Site__r.Landing_Page__c, 
																		Event_Start_Datetime__c, Event_TimezoneSidKey__c, Event_End_DateTime__c, Last_Edited_DateTime__c, 
																		Primary_Author__c, Primary_Author__r.Full_Name__c,
																		Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c,
																		Site__r.Title_Content_Version__c, Event_Is_All_Day__c,
																		(SELECT Id, Content_Version__c, Thumbnail_URL__c, Is_Title_Image__c, Title_Image_Type__c
																			FROM File_Simpplr_Content__r 
																			WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c ) 
																	FROM Simpplr_Content__c 
																	WHERE id IN :contentIds]);
		
		getcontentIdNPublicUrlMap(contentIdWithObjectMap.values());
        
    	List<String> formatterList = new List<String>();
    	for(App_Notification__c notification : notificationList) {	
    		if(counter < digestSize){

				if(contentIdWithObjectMap.containsKey(notification.Object_Id__c)) {
					Simpplr_Content__c contentObj = contentIdWithObjectMap.get(notification.Object_Id__c);

					// *******************Content ROW************************************
					String superPreString = '<tr><td class="content-block" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;padding-bottom:10px;padding-top:10px;text-align:left;vertical-align:top"><table style="border-collapse:separate;width:100%"><tbody><tr><td class="Post" style="border:1px solid #eeeeee;border-collapse:collapse;border-radius:5px;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;padding:10px 10px 0;text-align:left;vertical-align:top;">';
					String superPostString = '</td></tr></tbody></table></td></tr>';

					String preString = '<table style="border-collapse:separate;width:100%"><tbody>';
					String postString = '</tbody></table>';
					
					String contentBodyBlock = getContentBodyBlock(contentObj, localeKey, peoplePrefObj, brandingInfo.general_primaryColor);
					
					String authorDetails = getAuthorDetails(contentObj, peoplePrefObj, localeKey);
					String viewButtonBlock = getViewButtonBlock(contentObj, brandingInfo, localeKey);
					
					contentBodyBlock = authorDetails + preString + contentBodyBlock + postString;

					contentBodyBlock = superPreString + contentBodyBlock + viewButtonBlock + superPostString;

					notificationRows += contentBodyBlock;
					// *******************Content Row ends************************************

				} else {
					formatterList.add(getProfileDisplayIcon(notification.Sent_By__r.External_Photo_URL__c, 
 														notification.Sent_By__r.External_Photo_URL_Expiry_Date__c)); //{0}
 
					String notificationDetailPageUrl = getNotificationDetailPageUrl(notification, contentIdWithObjectMap, contentPrefix);
					formatterList.add(notificationDetailPageUrl); //{1}

					formatterList.add(notification.Sent_By__r.Full_Name__c); //{2}
					if(contentIdWithObjectMap.containsKey(notification.Object_Id__c)) {
						if('Page_Submitted_For_Moderation'.equalsIgnoreCase(notification.category__c)) {
							String localizedContentType = LocaleContext.getLocalisedContentTypeLabel(localeKey, 'Page');
							formatterList.add(LocaleContext.getLabel(localeKey, KEY_REQUEST_PAGE_APPROVAL)
															.replace('{{contentTitle}}', contentIdWithObjectMap.get(notification.Object_Id__c).Title__c)
															.replace('{{fullName}}', '')
															.replace('{{contentType}}', localizedContentType)
															.replace('{{contentType, lowercase}}', localizedContentType.toLowerCase()));

						} else if('Event_Submitted_For_Moderation'.equalsIgnoreCase(notification.category__c)) {
							formatterList.add(LocaleContext.getLabel(localeKey, KEY_REQUEST_EVENT_APPROVAL)
															.replace('{{fullName}}', '')
															.replace('{{contentTitle}}', contentIdWithObjectMap.get(notification.Object_Id__c).Title__c));

						} else if('Album_Submitted_For_Moderation'.equalsIgnoreCase(notification.category__c)) {
							formatterList.add(LocaleContext.getLabel(localeKey, KEY_REQUEST_ALBUM_APPROVAL)
															.replace('{{fullName}}', '')
															.replace('{{contentTitle}}', contentIdWithObjectMap.get(notification.Object_Id__c).Title__c));
						}
					} else {
						formatterList.add(LocaleContext.getLabel(localeKey, KEY_REQUEST_ACCESS_SITE)
														.replace('{{siteName}}', notification.Simpplr_Site__r.name)); //{3}
					}

					String localisedDate = LocaleContext.getLocalisedDateAsMMMDDYYYY(notification.createdDate, localeKey, peoplePrefObj.people__r.User__r.timeZonesidkey);
					String atStr = LocaleContext.getLabel(localeKey, KEY_AT);
					String dateAs24formatTime = LocaleContext.getLocalisedDateAs12HourFormatTime(notification.createdDate, localeKey, peoplePrefObj.people__r.User__r.timeZonesidkey);

					formatterList.add(localisedDate + ' ' + atStr + ' ' + dateAs24formatTime);//{4} -- Nov 7, 2018 at 6:57pm
					formatterList.add(notificationDetailPageUrl);//{5}
					formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_VIEW_BTN)); //{6}

					notificationRows = notificationRows + EmailUtility.format(pendingApprovalDigestPartMap.get('notificationRows'), formatterList);
					formatterList.clear();
				}
    		}
    		counter = counter + 1;
    	}
    	if(notificationList.size() > digestSize){
    		formatterList.add('' + SimpplrContext.salesforceBaseUrl  + Page.Notifications.getUrl()+'?origin=pade#filter=actionable');
			formatterList.add(LocaleContext.getLabel(localeKey, KEY_VIEW_ALL_REQUESTS));

    		showAllRequestRow = EmailUtility.format(pendingApprovalDigestPartMap.get('showAllRequestRow'), formatterList);
    		formatterList.clear();
    	}
    	notificationRows = notificationRows + showAllRequestRow;
		
		String userName = peoplePrefObj.people__r.Last_Name__c;
    	if(string.isNotBlank(peoplePrefObj.people__r.First_Name__c)){
    		userName = peoplePrefObj.people__r.First_Name__c;
    	}

		formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_HI).replace('{{firstName}}', userName));

		Integer notiCount = notificationList.size();
		String bodyHeading;
		
		if(BATCH_TYPE_SITE_MODERATION.equalsIgnoreCase(batchContext)) {
			if(notiCount == 1) {
				bodyHeading = LocaleContext.getLabel(localeKey, KEY_SITE_REQUEST_PENDING_INTRO_SINGULAR).replace('{{count}}', String.valueOf(notiCount));
			} else {
				bodyHeading = LocaleContext.getLabel(localeKey, KEY_SITE_REQUEST_PENDING_INTRO_PLURAL).replace('{{count}}', String.valueOf(notiCount));
			}
		} else {
			if(notiCount == 1) {
				bodyHeading = LocaleContext.getLabel(localeKey, KEY_CONTENT_REQUEST_PENDING_INTRO_SINGULAR).replace('{{count}}', String.valueOf(notiCount));
			} else {
				bodyHeading = LocaleContext.getLabel(localeKey, KEY_CONTENT_REQUEST_PENDING_INTRO_PLURAL).replace('{{count}}', String.valueOf(notiCount));
			}
		}

    	formatterList.add(bodyHeading);
    	String notificationDigestGreeting = EmailUtility.format(pendingApprovalDigestPartMap.get('notificationDigestGreeting'), formatterList);
    	formatterList.clear();
    	
    	formatterList.add(notificationDigestGreeting);
    	formatterList.add(notificationRows);
    	String notificationRowsWithGreeting = EmailUtility.format(pendingApprovalDigestPartMap.get('notificationRowsWithGreeting'), formatterList);
    	formatterList.clear();

		formatterList.add('<style> @media all { .ExternalClass { width: 100%; } .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div { line-height: 100%; } .apple-link a { color: inherit !important; font-family: inherit !important; font-size: inherit !important; font-weight: inherit !important; line-height: inherit !important; text-decoration: none !important; } } @media only screen and (max-width: 620px) { table[class=body] .wrapper, table[class=body] .header, table[class=body] .article { padding: 10px !important; } table[class=body] .content { padding: 0 !important; } table[class=body] .container { padding: 0 !important; width: 100% !important; } table[class=body] .main { border-left-width: 0 !important; border-radius: 0 !important; border-right-width: 0 !important; } table[class=body] .btn table { width: 100% !important; } table[class=body] .btn a { width: 100% !important; } table[class=body] .img-responsive { height: auto !important; max-width: 100% !important; width: auto !important; } td[class="mobile-hide"] { display: none; } .mobile-hide { display: none; } .wrapper, .header, .article { padding: 10px !important; } .content { padding: 0 !important; } .container { padding: 0 !important; width: 100% !important; } .main { border-left-width: 0 !important; border-radius: 0 !important; border-right-width: 0 !important; } .btn table { width: 100% !important; } .btn a { width: 100% !important; } .img-responsive { height: auto !important; max-width: 100% !important; width: auto !important; } } a[x-apple-data-detectors] { color: inherit !important; text-decoration: none !important; font-size: inherit !important; font-family: inherit !important; font-weight: inherit !important; line-height: inherit !important; } </style> <!--[if (gte mso 9)|(IE)]> <style type="text/css"> table {border-collapse: collapse;} </style> <![endif]-->'); //{0}
		formatterList.add(logoUrl); //{1}
    	formatterList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(), localekey));//{2}
    	formatterList.add(notificationRowsWithGreeting);//{3}
		formatterList.add(LocaleContext.getLabel(localekey, KEY_FOOTER_SETTINGS).replace('{{appName}}', SimpplrContext.applicationName));//{4}
    	formatterList.add((LocaleContext.getLabel(localekey, KEY_COPYRIGHT_TEXT)).replace('{{year}}', String.valueOf(Date.today().year())));//{5} 
    	formatterList.add(LocaleContext.getLabel(localekey, KEY_POWERED_BY));//{6}
		formatterList.add(LocaleContext.getLabel(localekey, KEY_DIGEST_HTML_TITLE));//{7}
		formatterList.add(BaseCtrl.salesForceBaseUrl + Page.PageRedirector.getUrl()+'?userId='+peoplePrefObj.people__r.user__c+'&pageToRedirect='+Pages.MySettingsEmail+'&origin=ne');//{8}

		if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('000000');
		} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
			formatterList.add(brandingInfo.general_primaryColor);
		} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('ffffff');
		} else {
			formatterList.add(brandingInfo.header_backgroundColor);
		}
    	pendingApprovalDigestHtmlBody = EmailUtility.format(pendingApprovalDigestPartMap.get('notificationDigestWithHeaderFooter'),formatterList);
    	return pendingApprovalDigestHtmlBody;
    }
    
    @testVisible
    private static String getNotificationDetailPageUrl(App_Notification__c notificationObj,Map<String,Simpplr_Content__c> contentIdWithObjectMap,String contentPrefix){
    	String notiDetailPageurl = '';
    	if(notificationObj.Object_Id__c.subString(0,3).equalsIgnoreCase(contentPrefix)) {
    		notiDetailPageurl = SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?siteId=' + notificationObj.Simpplr_Site__c +'&contentId='+notificationObj.Object_Id__c+'&pageToRedirect=ContentDetailPage'+'&origin=pade&contentType='+contentIdWithObjectMap.get(notificationObj.Object_Id__c).Type__c.tolowercase();
    	} else if(notificationObj.Object_Id__c.subString(0,3).equalsIgnoreCase('0I5')){	
			notiDetailPageurl = SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?siteId=' + notificationObj.Simpplr_Site__c +'&pageToRedirect='+Pages.NotificationsSiteMemberRequest+'&origin=pade';	
		}
		
    	return notiDetailPageurl;
    }

	private static String getProfileDisplayIcon(String publicPhotoURL, DateTime photoUrlExpiryDate) {
		List<String> formatterList = new List<String>();
		if(String.isBlank(publicPhotoURL) || photoUrlExpiryDate == null || photoUrlExpiryDate <= DateTime.now()) {
			formatterList.add(EmailConstants.peopleDefaultIcon);
		} else {
			formatterList.add(publicPhotoURL);
		}
		String profileDisplayIcon = EmailUtility.format(pendingApprovalDigestPartMap.get('profileImage'), formatterList);

		return profileDisplayIcon;
	}
	
    
    private String getContentBodyBlock(Simpplr_Content__c content, String localeKey, People_Preference__c peoplePrefObj, String generalPrimaryColor) {
		String contentBodyBlock = '';
				
		String contentPart = '';
		Map<String,String> partMap = contentBlockPartMap;

		String viewURL = '';
		String thumbnailTitleImageHTML = '';
		//String widescreenTitleImageHTML = '';
		
		Boolean isMustReadPage = false;
		if ('Page'.equalsIgnoreCase(content.type__c)) {

			if (content.Is_Must_Read__c) {
				isMustReadPage  = true;
			}

			if (String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
				contentPart = partMap.get('pageRow');
			} else {
				contentPart = partMap.get('pageWithoutImageRow');
			}

		} else if ('Event'.equalsIgnoreCase(content.type__c)) {
			
			contentPart = partMap.get('eventWithoutImageRow');

		} else if ('BlogPost'.equalsIgnoreCase(content.type__c)) {
			
			if (String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
				contentPart = partMap.get('blogPostRow');
			} else {
				contentPart = partMap.get('blogWithoutImagePostRow');
			}

		} else if ('Album'.equalsIgnoreCase(content.type__c)) {
			contentPart = partMap.get('albumRow');
		}

		contentPart = '<tr><td><table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">'
						+ contentPart 
						+ '</td></tr></table></td></tr>';

		List<String> contentPartList = new List<String>();
		String localizedContentType = LocaleContext.getLocalisedContentTypeLabel(localeKey, content.type__c.toLowerCase()).capitalize();
		contentPartList.add(EmailUtility.format(partmap.get('ContentType'),
							new List<String>{
									localizedContentType
									})); // 10.0								

		//10.1
		contentPartList.add(''+SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?siteId=' + content.site__c +'&contentId='+content.id+'&pageToRedirect=ContentDetailPage'+'&origin=tse&contentType='+content.type__c.tolowercase()+'&utm_source=activity_notifications_email&utm_term=content_marked_must_read&utm_medium=email');
		//10.2
		contentPartList.add(content.Title__c.length()>100 ? content.Title__c.substring(0,97)+'...' : content.Title__c);
		viewURL = '' +SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?siteId=' + content.site__c +'&contentId='+content.id+'&pageToRedirect=ContentDetailPage'+'&origin=tse&contentType='+content.type__c.tolowercase();
		//Adding title Image 

		if(!'Event'.equalsIgnoreCase(content.type__c) && String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
			//10.3
			contentPartList.add(contentIdWithPublicUrlMap.get(content.id));
		
		} else {
			contentPartList.add(' ');
		}
		
		// adding content body text (summary)
		//10.4
		contentPartList.add('');

		//Promoted Stamp
		//10.5
		contentPartList.add('');
		
		if(content.site__r.Site_Type__c != null && content.site__r.Site_Type__c.equalsIgnoreCase('Private')){
			//10.6
			contentPartList.add('<span style="border: 1px solid #cccccc; color: #666; font-size: 8px; line-height: 1; padding: 1px 3px; text-align: center; text-decoration: none; text-transform: uppercase; margin-right: 6px;" href="#">PRIVATE</span>');
		} else if(content.site__r.Site_Type__c != null && content.site__r.Site_Type__c.equalsIgnoreCase('Unlisted')){
			//10.6
			contentPartList.add('<span style="border: 1px solid #cccccc; color: #666; font-size: 8px; line-height: 1; padding: 1px 3px; text-align: center; text-decoration: none; text-transform: uppercase; margin-right: 6px;" href="#">UNLISTED</span>');
		} else{
			//10.6
			contentPartList.add('');
		}

		// adding view button 
		//10.7
		contentPartList.add(viewURL);
		//10.8
		contentPartList.add(brandingInfo.general_primaryColor); // {7} branding color for links/buttons 
		//10.9
		contentPartList.add(thumbnailTitleImageHTML);
		
		String eventMonth = '';
		String eventDay = '';

		if('Event'.equalsIgnoreCase(content.type__c)){
			String badge = '';
			String dayForEvent = '';
			String startDay = LocaleContext.getLocalisedDateAsEEEEMMMDYYYY(content.Event_Start_Datetime__c, localeKey, content.Event_TimezoneSidKey__c);
			String endDay = LocaleContext.getLocalisedDateAsEEEEMMMDYYYY(content.Event_End_DateTime__c, localeKey, content.Event_TimezoneSidKey__c);
			String startTime = LocaleContext.getLocalisedDateAs12HourFormatTime(content.Event_Start_DateTime__c, localeKey, content.Event_TimezoneSidKey__c);
			String endTime = LocaleContext.getLocalisedDateAs12HourFormatTime(content.Event_End_DateTime__c, localeKey, content.Event_TimezoneSidKey__c);
			eventMonth = LocaleContext.getLocalisedMonth(content.Event_Start_Datetime__c, localeKey, content.Event_TimezoneSidKey__c);
			eventDay = content.Event_Start_Datetime__c.format('dd', content.Event_TimezoneSidKey__c);

			String timeZoneLabel;
			if(content.Event_Is_All_Day__c == false) {
				timeZoneLabel = Utility.timezoneIdToDisplayLabel(peoplePrefObj.People__r.User__r.Timezonesidkey);
			} else {
				timeZoneLabel = Utility.timezoneIdToDisplayLabel(content.Event_TimezoneSidKey__c);
			}

			if('12:00 AM'.equalsIgnoreCase(content.Event_Start_Datetime__c.format('h:mm a')) && content.Event_Start_Datetime__c.addDays(1) == content.Event_End_DateTime__c){
				dayForEvent = startDay;
				badge = LocaleContext.getLabel(localeKey, KEY_EMAIL_ALL_DAY_DIGEST);
			}else if(content.Event_Start_DateTime__c.isSameDay(content.Event_End_DateTime__c)){
				dayForEvent = startDay;
				badge = startTime+' - '+endTime + ' (' + timeZoneLabel + ')';
			}else if('12:00 AM'.equalsIgnoreCase(content.Event_Start_Datetime__c.format('h:mm a')) && '12:00 AM'.equalsIgnoreCase(content.Event_End_DateTime__c.format('h:mm a'))){
				String eventEndDateMinusOneMinute = LocaleContext.getLocalisedDateAsEEEEDMMMYYYY(content.Event_End_DateTime__c.addMinutes(-1), localeKey, content.Event_TimezoneSidKey__c);
				badge = startDay+' - '+ eventEndDateMinusOneMinute + ' (' + timeZoneLabel + ')';
			}else{
				badge = startDay+' - '+endDay + ' (' + timeZoneLabel + ')';
			}
			//10.10
			contentPartList.add(EmailUtility.format(partmap.get('BadgeForEvent'),//10
					new List<String>{dayForEvent}));
			//10.11
			contentPartList.add(EmailUtility.format(partmap.get('BadgeForEvent'),//11
					new List<String>{badge}));
		}else{
			//10.10
			contentPartList.add(' ');
			//10.11
			contentPartList.add(' ');
		}

		if (String.isNotBlank(content.site__c)) {
			//10.12
			contentPartList.add(content.site__r.name); // Site name
			//10.13
			contentPartList.add(PageContext.getPageURL(Pages.app) +'?u=/site/' + content.site__c + '/' + content.site__r.Landing_Page__c); // Site Link
			
		} else {
			//10.12
			contentPartList.add(' ');
			//10.13
			contentPartList.add(' ');
		}

		//10.14
		//contentPartList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(content.Last_Edited_DateTime__c, localeKey, peoplePrefObj.People__r.User__r.timezonesidkey));//Created date time
		contentPartList.add(' ');

		if ('BlogPost'.equalsIgnoreCase(content.type__c) && 
				String.isNotBlank(content.Primary_Author__r.Full_Name__c)) {
			//10.15 
			contentPartList.add(content.Primary_Author__r.Full_Name__c);
			//10.16
			contentPartList.add(PageContext.getPageURL(Pages.app)+ '?u=/people/' + content.Primary_Author__c);
		
		} else {
			//10.15 
			contentPartList.add('');
			//10.16 
			contentPartList.add('');
		}
		
		//10.17 
		contentPartList.add(eventMonth) ;
		//10.18 
		contentPartList.add(eventDay);

		//10.19 must read stamp 
		if(isMustReadPage) {
			contentPartList.add('');
			//contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.people__r.User__r.languagelocalekey),EmailConstants.KEY_LABEL_MUSTREAD));
		}  else {
			contentPartList.add('');
		}

		// 10.20 contentType 
		if ('Page'.equalsIgnoreCase(content.type__c)) {
			contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
						peoplePrefObj.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_PAGE));
		
		} else if ('Album'.equalsIgnoreCase(content.type__c)){
			contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
						peoplePrefObj.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_ALBUM));
		
		} else if ('BlogPost'.equalsIgnoreCase(content.type__c)){
			contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
						peoplePrefObj.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_BLOGPOST));
		
		} else if ('Event'.equalsIgnoreCase(content.type__c)){
			contentPartList.add(LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(
						peoplePrefObj.people__r.User__r.languagelocalekey), EmailConstants.KEY_LABEL_EVENT));
		}

		//10.21 In keyword
		contentPartList.add(LocaleContext.getLabel(localeKey, KEY_IN));
		
		//10.22 By keyword 
		contentPartList.add(LocaleContext.getLabel(localeKey, KEY_BY));

		contentBodyBlock = EmailUtility.format(contentPart, contentPartList);

		return contentBodyBlock;
	}

	private void getcontentIdNPublicUrlMap(List<Simpplr_Content__c> contentList) {
    	Map<Id, Id> contentIdAndCVIdMap = new Map<Id, Id>();
    	
    	// Widescreen image is required for First content, Thumbnail image for the rest..
    	String desiredImageType = 'Thumbnail';
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
							} else if(desiredImageType.equalsIgnoreCase(fileObj.Title_Image_Type__c)) {
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
    		
    			desiredImageType = 'Thumbnail';
    		}
    	}
    	Map<Id, String> cvIdNPublicUrlMap;
    	if(contentIdAndCVIdMap.size()>0){
    		cvIdNPublicUrlMap = FileContentProvider.generateEmbedPublicUrl(contentIdAndCVIdMap.values());
    	
	    	for(Id contentId : contentIdAndCVIdMap.keySet()){
	    		contentIdWithPublicUrlMap.put(contentId,cvIdNPublicUrlMap.get( contentIdAndCVIdMap.get(contentId)));
	    	}
    	}
	}
	
	private String getAuthorDetails(Simpplr_Content__c contentObj, People_Preference__c peoplePrefObj, String localeKey) {
		String authorDetailsPart = contentBlockPartMap.get('authorDetailsRow');

		String publicPhotoURL = contentObj.Primary_Author__r.External_Photo_URL__c;
		DateTime photoUrlExpiryDate = contentObj.Primary_Author__r.External_Photo_URL_Expiry_Date__c;

		if(String.isBlank(publicPhotoURL) || photoUrlExpiryDate == null || photoUrlExpiryDate <= DateTime.now()) {
			publicPhotoURL = (EmailConstants.peopleDefaultIcon);
		}

		String submitMessage = '';

		if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)) {
			submitMessage = LocaleContext.getLabel(localekey, KEY_REQUEST_ALBUM_APPROVAL);
		} else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.Type__c)) {
			submitMessage = LocaleContext.getLabel(localekey, KEY_REQUEST_EVENT_APPROVAL);
		} else if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.Type__c)) {
			submitMessage = LocaleContext.getLabel(localekey, KEY_REQUEST_PAGE_APPROVAL);
		}

		List<String> authorDetailsPartList = new List<String>();
		authorDetailsPartList.add(publicPhotoURL);  //{0}
		authorDetailsPartList.add(contentObj.Primary_Author__r.Full_Name__c); //{1}
		authorDetailsPartList.add(submitMessage); //{2}

		String localisedDate = LocaleContext.getLocalisedDateAsMMMDDYYYY(contentObj.Last_Edited_DateTime__c, localeKey, peoplePrefObj.People__r.User__r.timeZonesidkey);
		String atStr = LocaleContext.getLabel(localeKey, KEY_AT);
		String dateAs24formatTime = LocaleContext.getLocalisedDateAs12HourFormatTime(contentObj.Last_Edited_DateTime__c, localeKey, peoplePrefObj.People__r.User__r.timeZonesidkey);
		authorDetailsPartList.add(localisedDate + ' ' + atStr + ' ' + dateAs24formatTime); //{3} -- Nov 7, 2018 at 6:57pm
		
		authorDetailsPart = EmailUtility.format(authorDetailsPart, authorDetailsPartList);

		return authorDetailsPart;
	}

	private String getViewButtonBlock(Simpplr_Content__c contentObj, NotificationHelper.BrandingInfo brandingInfo, String localeKey) {
		String viewButtonPart = contentBlockPartMap.get('viewButtonRow');
		
		List<String> viewButtonPartList = new List<String>();
		String contentLink = SimpplrContext.salesForceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + contentObj.site__c +'&contentId='+contentObj.id+'&pageToRedirect=ContentDetailPage'+'&origin=ne&contentType='+contentObj.type__c.tolowercase();
		
		viewButtonPartList.add(contentLink);
		viewButtonPartList.add(brandingInfo.general_primaryColor);
		viewButtonPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_VIEW_BTN));
		
		viewButtonPart = EmailUtility.format(viewButtonPart, viewButtonPartList);

		return viewButtonPart;
	}

}