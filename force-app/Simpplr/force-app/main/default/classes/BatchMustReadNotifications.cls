public without sharing class BatchMustReadNotifications implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
	
	
	private static final String KEY_EMAIL_MUST_READ_INTRO = 'email.notification.content.must_read.intro';
	private static final String KEY_EMAIL_MUST_READ_SUBJECT = 'email.notification.content.must_read.subject';
	private static final String KEY_EMAIL_MUST_READ_REMINDER_SUBJECT = 'email.notification.summary.must_reads.subject_singular';
	private static final String KEY_EMAIL_MUST_READ_REMINDER_SUBJECT_PLURAL = 'email.notification.summary.must_reads.subject_plural';
	private static final String KEY_EMAIL_MUST_READ_BODY = 'email.notification.content.must_read.body';
	private static final String KEY_EMAIL_SUMMARY_MUST_READ_INTRO_SINGULAR = 'email.notification.summary.must_reads.intro_singular';
	private static final String KEY_EMAIL_SUMMARY_MUST_READ_INTRO_PLURAL = 'email.notification.summary.must_reads.intro_plural';
	private static final String KEY_EMAIL_SUMMARY_MUST_READ_LEAD_IN = 'email.notification.summary.must_reads.lead_in';
	private static final String KEY_EMAIL_MUST_READ_SHARED_WITH_APP = 'email.notification.content.must_read.shared_with_app';
	private static final String KEY_EMAIL_MUST_READ_SHARED_WITH_SITE = 'email.notification.content.must_read.shared_with_site';
	private static final String KEY_EMAIL_ALL_DAY_DIGEST = 'email.common.all_day.digest';
	private static final String KEY_DATE_PM = 'common.date_pm';
	private static final String KEY_DATE_AM = 'common.date_am';
	private static final String KEY_AT = 'email.common.at_time';
	private static final String KEY_IN = 'common.in';
	private static final String KEY_ON = 'common.on';
	private static final String KEY_BY = 'email.common.by';
	private static final String KEY_PUSH_NOTIFICATION_MUST_READ = 'push.notification.content.must_read';
	private static final String KEY_EMAIL_HI = 'email.common.salutation';
	private static final String KEY_EMAIL_VIEW_BTN = 'email.common.view_button';
	public static final String KEY_DIGEST_HTML_TITLE = 'email.notification.batch.digest.html_title';
	public static final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';
	public static final String KEY_COPYRIGHT_TEXT = 'email.common.footer.copyright';
	public static final String KEY_POWERED_BY = 'email.common.footer.powered_by';

	private static final Map<String, String> CONTENT_TYPE_LOCALIZE_MAP = new Map<String, String>{
		'blogpost' => 'email.common.blog_post',
		'album' => 'email.common.label.album',
		'event' => 'email.common.label.event',
		'page' => 'email.common.label.page'
	};

	public static Map<String,String> contentMustReadsPartMap = new Map<String,String>{
		'BaseEmailBody' => '<html xmlns="http://www.w3.org/1999/xhtml"> <head> <meta http-equiv="Content-Type" content="text/html; charset=utf-8"> {23} <title>Simpplr Email Digest</title> </head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{12}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span> </td> </tr> </tbody> </table> </td> </tr> <tr> <td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;">{3},<br>{4}</h2> </td> </tr> {10} </tbody> </table> </td> </tr> </tbody> </table> {24} <div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> <a href="{11}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;"> {18}. </a> <br>{20}. </td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {21} <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">{9}</a>. </td> </tr> </table> </div> </div> </td> </tr> </tbody> </table> </body> </html>',
		'ContentRow' => '<tr><td style="padding-bottom:16px;"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; border-spacing: 0;"><tr><td bgcolor="#FFFFFF" valign="top" style="padding: 0 16px;"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; border-spacing: 0;"> <tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; border-spacing: 0;"><tr><td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-collapse: collapse; border-spacing: 0;font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; color: #333333;"><tr><td style="padding: 2px 0 6px; font-size: 20px; line-height: 26px;"><div style="padding-bottom: 6px; line-height: 0; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;">{0}{3}</div><a href="{1}" style="color: #{6}; text-decoration: none; word-break: break-word;">{2}</a>{7}{8}</td></tr><tr><td style="padding-bottom:4px;"><p style="margin: 0 ; font-size: 14px; line-height: 21px;">{4}</p></td></tr></table></td>{5}</tr></table></td></tr> </table></td></tr></table></td></tr>',
		'ContentType' =>'<span style="border: 1px solid #cccccc; color: #666; font-size: 8px; line-height: 1; padding: 1px 3px; text-align: center; text-decoration: none; text-transform: uppercase; margin-right: 6px;" href="#">{0}</span>',
		'BadgeForEvent' => '<div style="padding-top: 6px; line-height: 0; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;"><span style="color: #999; font-size: 12px; line-height: 1;">{0}</span></div>',
		'ThumbnailTitleImage' =>  '<td class="mobile-hide" width="80" align="right" valign="top" style="padding: 0 0 0 32px;"><a href="{0}" style="overflow: hidden; display: block; max-width: 80px; max-height: 80px; border: none; text-decoration: none;"></a><table width="80" align="center" cellspacing="0" cellpadding="0" border="0" style="border-collapse: collapse; border-spacing: 0; background-color: #ffffff; padding: 0; margin: 0;"><tbody><tr><td width="80" height="80" align="center" valign="middle" style="background-color: #f9f9f9; margin: 0; font-size: 18px; padding: 0; text-decoration: none; color: #ffffff; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif;"><img src="{1}" alt="alt" width="80" height="80" style="border: none;"></td></tr></tbody></table></td>',
		'allDayEventRow' => '<tr><td><p style="font-weight:bold;text-decoration:none">{23}</p></td></tr> <tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;">All Day</span> </div> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;">{10}{11}</span> </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4} </p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'eventWithoutImageRow' => '<tr><td><p style="font-weight:bold;text-decoration:none">{23}</p></td></tr> <tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #fff; border: 1px solid #e6e6e6; border-collapse: separate; border-radius: 2px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-decoration: none; width: 100%;"> <tbody><tr> <td align="center" valign="top" class="CalendarMonth" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{8}; border-collapse: collapse; color: #fff; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: normal; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px 0; text-align: center; text-transform: uppercase; vertical-align: top;"> <a href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #fff; text-decoration: none;"> {17} </a> </td> </tr> <tr> <td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 60px; font-weight: 100; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: center; vertical-align: top;"> <a href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; text-decoration: none;"> {18} </a> </td> </tr> </tbody></table> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> <div style="padding-top: 6px; line-height: 0;"> <span style="color: #999; font-size: 12px; line-height: 1;"> {10} {11}</span> </div> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'pageWithoutImageRow' => '<tr><td><p style="font-weight:bold;text-decoration:none">{23}</p></td></tr><tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="'+ EmailConstants.pageDefaultIconSquareIcon+'" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20} <span class="type--mustRead" style="color: #333;">{19}</span></span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;"> {12} </a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'pageRow' => '<tr><td><p style="font-weight:bold;text-decoration:none">{23}</p></td></tr> <tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20} <span class="type--mustRead" style="color: #333;">{19}</span></span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2}</a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;"> {12} </a> {14}</p> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td></tr>',
		'blogPostRow' => '<tr><td><p style="font-weight:bold;text-decoration:none">{23}</p></td></tr> <tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}</span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;">{2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{22} <a href="{16}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;">{15} </a> on {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'blogWithoutImagePostRow' => '<tr><td><p style="font-weight:bold;text-decoration:none">{23}</p></td></tr> <tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="'+EmailConstants.blogDefaultIconSquareIcon+'" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}</span> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;"> {2} </a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{22} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;">{15}</a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'albumRow' => '<tr><td><p style="font-weight:bold;text-decoration:none">{23}</p></td></tr> <tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody><tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{1}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{3}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{20}<span class="type--mustRead" style="color: #333;">{19}</span></span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{1}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: bold; text-decoration: none; word-break: break-word;">{2}</a> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;"> {4} </p> </td> </tr> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{21} <a href="{13}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{8}; text-decoration: none;">{12}</a> {14}</p> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td> </tr> </tbody></table> </td></tr>',
		'viewButtonRow' => '<table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><center><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; box-sizing: border-box; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px !important;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"></td><td align="center" class="btn-spacer" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 15px; padding-top: 15px; text-align: left; vertical-align: top; width: 120px;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px;"><tbody><tr><td class="btn-inner" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{1}; border-collapse: collapse; border-radius: 4px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top; width: 120px;"><a href="{0}" target="_blank" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: {1}; border: solid 1px #1abc9c; border-color: #1abc9c; border-radius: 5px; box-sizing: border-box; color: #ffffff; cursor: pointer; display: inline-block; font-size: 14px; font-weight: normal; margin: 0; padding: 5px 15px; text-decoration: none; text-transform: capitalize; width: 120px;">{2}</a></td></tr></tbody></table></td><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"></td></tr></table></center></td></tr></table>',
		'topMessageRow' => '<table style="border-collapse:separate;width:100%"><tbody><tr> <td class="Post-body" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"> <p style="font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;font-weight:normal;margin:0;margin-bottom:15px"> </p><p>{0}</p> <p></p> </td> </tr></tbody></table>',
		'authorDetailsRow' => '<table style="border-collapse:separate;width:100%"><tbody><tr> <td class="Notification-avatar-cell" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top;width:45px"> <img class="Notification-avatar CToWUd" src="{0}" style="border:none;border-radius:50%;display:block;height:auto;max-width:100%;outline:none;text-decoration:none;width:45px"> </td> <td class="Post-header" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;line-height:14px;padding-left:10px;padding-top:4px;text-align:left;vertical-align:middle"> <table width="500" style="border-collapse:separate;width:100%"> <tbody><tr> <td style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"> <a class="Post-name" style="color:#222;font-weight:bold;text-decoration:none">{1}</a> </td> </tr> <tr> <td style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"> <span class="Post-date" style="color:#999;font-size:12px"></span> </td> </tr> </tbody></table> </td> </tr></tbody></table>',
		'emailTemplateWithHeaderFooterWithNoSettings' => '<!doctype html> <html> <head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection"> {7} <title>Email Notification</title> </head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #F6F6F6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #F6F6F6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <!-- START CENTERED WHITE CONTAINER --> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #FFFFFF; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <!-- START HEADER --> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{10}; border-bottom: 1px solid #EEEEEE; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{0}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #C5C5C5; font-size: 12px; font-weight: normal;">{1}</span> </td> </tr> </table> </td> </tr> <!-- END HEADER --> <!-- START MAIN CONTENT AREA --> {2} <!-- END MAIN CONTENT AREA --> </table> <!-- START FOOTER --> {9}<div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;"> {3}. </a> <br>{4} </td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {5} <a href="{6}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">Simpplr</a>. </td> </tr><tr><td><img src={11}{12} width="1" height="1" alt="Simpplr" style="display:none";/></td></tr></table> </div> <!-- END FOOTER --> <!-- END CENTERED WHITE CONTAINER --> </div> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </body> </html>',		'authorDetailsRow' => '<table style="border-collapse:separate;width:100%"><tbody><tr> <td class="Notification-avatar-cell" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top;width:45px"> <img class="Notification-avatar CToWUd" src="{0}" style="border:none;border-radius:50%;display:block;height:auto;max-width:100%;outline:none;text-decoration:none;width:45px"> </td> <td class="Post-header" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;line-height:14px;padding-left:10px;padding-top:4px;text-align:left;vertical-align:middle"> <table width="500" style="border-collapse:separate;width:100%"> <tbody><tr> <td style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"> <a class="Post-name" style="color:#222;font-weight:bold;text-decoration:none">{1}</a> </td> </tr> <tr> <td style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;text-align:left;vertical-align:top"> <span class="Post-date" style="color:#999;font-size:12px"></span> </td> </tr> </tbody></table> </td> </tr></tbody></table>'

	};
	
	public String contentId; 
	public String chatterGroupId; 
    public String logoUrl;
    public Boolean isSimpplrEmailEnabled;
	public NotificationHelper.BrandingInfo brandingInfo;
	public String packageName;
	public Integer batchNumber = 1;
    public String activity;
    public Boolean simpplrMobileNotificationAllowed;
	public Map<Id, String> contentIdWithPublicUrlMap = new Map<Id, String>();
    private Exception exceptionDetailsObj;
	public Set<String> memberUserIdSet;
	Map<String, Set<String>> memberIdToSetOfCGIdSet;
	App_Config__c appConfig ;
	
    
    public BatchMustReadNotifications(String contentId,String activity) {
    	this.contentId = contentId;
    	this.activity = activity;
    	
		String appConfigQuery = 'Select Simpplr_Emails_Allowed__c, Simpplr_Mobile_Notification_Allowed__c,Package_Name__c,Branding_JSON__c,Branding_Logo__c from App_Config__c Limit 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

		simpplrMobileNotificationAllowed = appConfig.Simpplr_Mobile_Notification_Allowed__c;
        packageName = appConfig.Package_Name__c;
        isSimpplrEmailEnabled = appConfig.Simpplr_Emails_Allowed__c;
        brandingInfo = new NotificationHelper.BrandingInfo();
    }
	public BatchMustReadNotifications(String contentId,String activity, String chatterGroupId) {
		this.chatterGroupId = chatterGroupId;
		this.contentId = contentId;
    	this.activity = activity;
    	
		String appConfigQuery = 'Select Simpplr_Emails_Allowed__c, Simpplr_Mobile_Notification_Allowed__c,Package_Name__c,Branding_JSON__c,Branding_Logo__c from App_Config__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

        simpplrMobileNotificationAllowed = appConfig.Simpplr_Mobile_Notification_Allowed__c;
        packageName = appConfig.Package_Name__c;
        isSimpplrEmailEnabled = appConfig.Simpplr_Emails_Allowed__c;
        brandingInfo = new NotificationHelper.BrandingInfo();
	}

	public BatchMustReadNotifications(Map<String, Set<String>> memberIdToSetOfCGIdSet, String activity) {
		this.activity = activity;
		if(memberIdToSetOfCGIdSet != null){
    		memberUserIdSet = memberIdToSetOfCGIdSet.keySet();
			this.memberIdToSetOfCGIdSet = memberIdToSetOfCGIdSet;
		}
	}


    public database.querylocator start(Database.BatchableContext bc) {
        String query = 'Select id,Email_Notification_Digest_Frequency__c,people__c,people__r.user__c, people__r.New_Notification_Count__c, '+
            		'people__r.Full_Name__c,people__r.First_Name__c,people__r.Last_Name__c, '+
            		'people__r.user__r.userName,people__r.External_Photo_URL__c, '+
            		'people__r.External_Photo_URL_Expiry_Date__c,people__r.User__r.timezonesidkey, '+
            		'Mobile_Allow_Notifications__c,Allow_Simpplr_Emails__c,Email_Content_Marked_As_Must_Read__c, SMS_Must_Reads__c, '+
            		'People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, ' +
            		'Mobile_Content_Marked_As_Must_Read__c, Native_Mob_Content_Marked_As_Must_Read__c, people__r.Mobile_Token_IOS__c, '+
            		'people__r.Mobile_Token_Android__c, people__r.Mobile_App_Type_iOS__c, '+
            		'people__r.Mobile_FCM_ID_iOS__c, people__r.Mobile_Bundle_ID_iOS__c, people__r.Mobile_FCM_ID_Android__c, people__r.Mobile_Bundle_ID_Android__c, ' +
					'people__r.Mobile_App_Type_Android__c, people__r.User__r.languagelocalekey, people__r.Mobile_Phone__c,people__r.User_Hash__c, ' + 
					'Allow_Browser_Notifications__c, Browser_Must_Read__c ' +
					'FROM People_Preference__c '+
            		'WHERE people__r.User__r.IsActive=true and people__r.User__r.UserType=\'Standard\' ';
            		
        if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
            query +=' and User__c IN '+
            		'(select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
        } 
        
        if('mustReadsReminderEmail'.equalsIgnoreCase(activity)){
        	query += 'AND Allow_Simpplr_Emails__c = true AND Email_Content_Marked_As_Must_Read__c=true '; 
		}
		if('mustReadsNotificationOnSiteFollow'.equalsIgnoreCase(activity) || 'removeMustReadsNotificationOnSitenUnFollow'.equalsIgnoreCase(activity)) {
			query += 'AND User__c IN : memberUserIdSet '; 
		}
		if(String.isNotBlank(chatterGroupId)) {
			if('sendNewMustReadToSiteMembers'.equalsIgnoreCase(activity) || 'mustReadsReminderEmailForSingleContentToSiteMembers'.equalsIgnoreCase(activity)){
				query += 'AND people__c in (Select People__c FROM Site_Role__c WHERE Is_Member__c = true AND Is_Deleted__c = false  AND (Site__r.Chatter_Group_Id__c=:chatterGroupId)) '; 
			} else {
				query += 'AND User__c in (Select MemberId from CollaborationGroupMember where CollaborationGroupId=:chatterGroupId) ';
			}
		}
         
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {
    	
    	try{
			Set<String> localeSet = new Set<String>{'en_US'};
		    List<People_Preference__c> peoplePrefList = (List<People_Preference__c>)listOfsObject;
	       
		   	for(People_Preference__c peoplePref: peoplePrefList){
				localeSet.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey));
			}

			// Initialize Locale Context
			LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
			LocaleContext.getAllLabelMap('PushNotifications', new List<String>(localeSet));
 
			DateTime currentDateTime = DateTime.now();
	        if(String.isNotBlank(contentId) && 'sendNewMustReadToEveryone'.equalsIgnoreCase(activity)){ 
	        	Set<String> peopleWhoHaveReadContent = new Set<String>();
				List<Must_Read_Confirm_History__c> confirmHistoryList = [SELECT people__c FROM Must_Read_Confirm_History__c WHERE content__c=:contentId AND Must_Read_Audit__r.Removed_DateTime__c=null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) ];
		        for(Must_Read_Confirm_History__c obj : confirmHistoryList){
		        	peopleWhoHaveReadContent.add(obj.people__c);
				}
				sendNewMustReadsNotifications(peoplePrefList,peopleWhoHaveReadContent);
				batchNumber = batchNumber + 1;

	        } else if(String.isNotBlank(contentId) && ('sendNewMustReadToSiteMembers'.equalsIgnoreCase(activity) || 'sendNewMustReadToSiteMembersAndFollowers'.equalsIgnoreCase(activity))){ 
	        	Set<String> peopleWhoHaveReadContent = new Set<String>();
		        List<Must_Read_Confirm_History__c> confirmHistoryList = [select people__c from Must_Read_Confirm_History__c where content__c=:contentId and Must_Read_Audit__r.Removed_DateTime__c=null AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) ];
		        for(Must_Read_Confirm_History__c obj : confirmHistoryList){
		        	peopleWhoHaveReadContent.add(obj.people__c);
		        }
				sendNewMustReadsNotifications(peoplePrefList,peopleWhoHaveReadContent);
				batchNumber = batchNumber + 1;
			
			} else if('mustReadsReminderEmailForSingleContent'.equalsIgnoreCase(activity) || 'mustReadsReminderEmailForSingleContentToSiteMembers'.equalsIgnoreCase(activity)){
	    		mustReadsReminderEmailForSingleContent(peoplePrefList);
				
			} else if('mustReadsReminderEmail'.equalsIgnoreCase(activity)){
	    		sendReminderForMustReadsEmail(peoplePrefList);
	    	} else if('mustReadsNotificationOnSiteFollow'.equalsIgnoreCase(activity)) {
				if(memberUserIdSet.isEmpty() == false){
					mustReadsNotificationOnSiteFollow(memberIdToSetOfCGIdSet, peoplePrefList);
				}
			} else if('removeMustReadsNotificationOnSitenUnFollow'.equalsIgnoreCase(activity)) {
				if(memberUserIdSet.isEmpty() == false){
					
					removeMustReadsNotificationOnSiteUnFollow(memberIdToSetOfCGIdSet, peoplePrefList);
				}
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
			Utility.sendExceptionEmail('BatchMustReadNotifications.' + activity, exceptionDetailsObj);
		}
    }
    

	private void mustReadsNotificationOnSiteFollow(Map<String,Set<String>> memberIdToSetOfFollowedCGIdSet,List<People_Preference__c> peoplePrefList){
        Set<String> cgIdSet = new Set<String>();
		Set<String> peopleIdSet = new Set<String>();
		for(People_Preference__c peoplePrefObj :  peoplePrefList){
			cgIdSet.addAll(memberIdToSetOfFollowedCGIdSet.get(peoplePrefObj.People__r.User__c));
			peopleIdSet.add(peoplePrefObj.People__c);
		}

		List<Site_Role__c> siteRoleList = [Select Id, Site__c, Is_Member__c From Site_Role__c Where Site__r.Chatter_Group_Id__c IN :cgIdSet AND People__c IN :peopleIdSet AND Is_Deleted__c = false];
		Map<Id,Site_Role__c> mapOfPeopleIdAndSiteRole = new Map<Id,Site_Role__c>();
		for(Site_Role__c siteRoleObj : siteRoleList) {
			mapOfPeopleIdAndSiteRole.put(siteRoleObj.Site__c, siteRoleObj);
		}

		DateTime currentDateTime = DateTime.now();
		List <Must_Read_Audit__c> mRAObjList = [SELECT Id, Content__r.Title__c, Content__c, 
				Content__r.Type__c, Content__r.Site__c, Content__r.Site__r.Chatter_Group_Id__c,  Message__c, Audience_Type__c
				FROM Must_Read_Audit__c 
				WHERE Content__r.Is_Deleted__c = false AND Removed_DateTime__c = null 
				AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime)
				AND Content__r.Is_Published__c = true 
				AND Content__r.Site__r.Chatter_Group_Id__c IN: cgIdSet AND 
				(Audience_Type__c='site_members' OR Audience_Type__c = 'site_members_and_followers')];
    	
		if(!mRAObjList.isEmpty()) {
			Map<String, List<Must_Read_Audit__c>> mapOfCGIdToMRAList = new Map<String, List<Must_Read_Audit__c>>();
			Set<Id> mustReadAuditIdSet = new Set<Id>();
			for(Must_Read_Audit__c mraObj : mRAObjList){
				if(mapOfCGIdToMRAList.get(mraObj.Content__r.Site__r.Chatter_Group_Id__c) == null ){
					mapOfCGIdToMRAList.put(mraObj.Content__r.Site__r.Chatter_Group_Id__c, new List<Must_Read_Audit__c>());
				}
				mustReadAuditIdSet.add(mraObj.Id);
				mapOfCGIdToMRAList.get(mraObj.Content__r.Site__r.Chatter_Group_Id__c).add(mraObj);
			}

			List <Must_Read_Confirm_History__c> mRCHObjList = [SELECT Id, Content__c, People__r.User__c, Must_Read_Audit__c FROM Must_Read_Confirm_History__c
																 WHERE Must_Read_Audit__c = :mustReadAuditIdSet AND People__r.User__c IN :memberIdToSetOfFollowedCGIdSet.keySet()];

			Map<String, String> mustReadConfirmPeopleIdVsAuditIdMap = new Map<String, String>();
			for(Must_Read_Confirm_History__c confirmHistoryObj : mRCHObjList){
				mustReadConfirmPeopleIdVsAuditIdMap.put(confirmHistoryObj.People__r.User__c, confirmHistoryObj.Must_Read_Audit__c);
			}

			List<Must_Read_Audit__c> listOfContentPerMember = new List<Must_Read_Audit__c>();
			
			
			List<App_Notification__c> notiListToInsert = new List<App_Notification__c>();
			Map<String,People_Preference__c> mapOfuserIdToPeoplePref = new Map<String,People_Preference__c>();
			for(People_Preference__c peoplePref : peoplePrefList){
				mapOfuserIdToPeoplePref.put(peoplePref.People__r.User__c, peoplePref) ;
			}

			for(String memberId : memberIdToSetOfFollowedCGIdSet.keySet()){
				People_Preference__c peoplePrefObj = mapOfuserIdToPeoplePref.get(memberId);

				for(String cgId: memberIdToSetOfFollowedCGIdSet.get(memberId)){
					if(mapOfCGIdToMRAList.containsKey(cgId)) {
						List<Must_Read_Audit__c> mustReadAuditObjList = mapOfCGIdToMRAList.get(cgId);

						for(Must_Read_Audit__c mustReadAuditObj : mustReadAuditObjList){
							if(mustReadConfirmPeopleIdVsAuditIdMap.get(memberId) == null || mustReadConfirmPeopleIdVsAuditIdMap.get(memberId).equalsIgnoreCase(mustReadAuditObj.Id) == false){
								if(mustReadAuditObj.Audience_Type__c == 'site_members') {
									if(mapOfPeopleIdAndSiteRole.containsKey(mustReadAuditObj.Content__r.Site__c)) {
										Site_Role__c siteRoleObj = mapOfPeopleIdAndSiteRole.get(mustReadAuditObj.Content__r.Site__c);
										if(siteRoleObj.Is_Member__c == true) {
											listOfContentPerMember.add(mustReadAuditObj);
										}
									}
								} else {
									listOfContentPerMember.add(mustReadAuditObj);
								}
							}	
						}
					}
				}

				if(!listOfContentPerMember.isEmpty()){
					notiListToInsert.addAll(getMustReadNotificationListToBeInsertedForAMember(listOfContentPerMember, peoplePrefObj));
				}
			}
			if(notiListToInsert.size()>0){

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(notiListToInsert, new List<Schema.SObjectField> { 
					App_Notification__c.GUID__c,
					App_Notification__c.Object_Id__c,
					App_Notification__c.Content__c,
					App_Notification__c.Object_Type__c,
					App_Notification__c.Snippet__c,
					App_Notification__c.Category__c,
					App_Notification__c.Type__c,
					App_Notification__c.Sub_Type__c,
					App_Notification__c.Status__c,
					App_Notification__c.Sent_To__c,
					App_Notification__c.Simpplr_Site__c,
					App_Notification__c.Created_DateTime__c,
					App_Notification__c.Is_New__c,
					App_Notification__c.Is_Read__c});
			}
		}
	}



	private void removeMustReadsNotificationOnSiteUnFollow(Map<String,Set<String>> memberIdToSetOfFollowedCGIdSet,List<People_Preference__c> peoplePrefList){
        Set<String> cgIdSet = new Set<String>();
		for(People_Preference__c peoplePrefObj :  peoplePrefList){
			cgIdSet.addAll(memberIdToSetOfFollowedCGIdSet.get(peoplePrefObj.People__r.User__c));
		}
		
		List <Must_Read_Audit__c> mRAObjList = [SELECT Id, Content__c, Content__r.Site__r.Chatter_Group_Id__c
										FROM Must_Read_Audit__c 
										WHERE Content__r.Is_Deleted__c = false AND Removed_DateTime__c = null 
										AND Content__r.Is_Published__c = true 
										AND Content__r.Site__r.Chatter_Group_Id__c IN: cgIdSet AND (Audience_Type__c='site_members' OR Audience_Type__c = 'site_members_and_followers')];
    	
		if(!mRAObjList.isEmpty()) {
			Map<String,Set<String>> mapOfCGIdToContentIdSet = new Map<String,Set<String>>();
			for(Must_Read_Audit__c mraObj : mRAObjList){
				if(mapOfCGIdToContentIdSet.get(mraObj.Content__r.Site__r.Chatter_Group_Id__c) == null ){
					mapOfCGIdToContentIdSet.put(mraObj.Content__r.Site__r.Chatter_Group_Id__c, new Set<String>());
				}
				mapOfCGIdToContentIdSet.get(mraObj.Content__r.Site__r.Chatter_Group_Id__c).add(mraObj.Content__c);
			}
			
			Map<String,Set<String>> mapOfMemberIdToSetOfContentIds = new Map<String,Set<String>>();
			Set<String> setOfContentIds = new Set<String>();
			for(String memberId : memberIdToSetOfFollowedCGIdSet.keySet()){
				for(String cgId: memberIdToSetOfFollowedCGIdSet.get(memberId)){
					if(mapOfCGIdToContentIdSet.containsKey(cgId)) {
						if(mapOfMemberIdToSetOfContentIds.get(memberId) == null){
							mapOfMemberIdToSetOfContentIds.put(memberId, new Set<String>());
						}
						mapOfMemberIdToSetOfContentIds.get(memberId).addAll(mapOfCGIdToContentIdSet.get(cgId));
						setOfContentIds.addAll(mapOfCGIdToContentIdSet.get(cgId));
					}
				}
			}
			List<App_Notification__c> notiList = [SELECT Id, Is_Deleted__c,  Content__c, Sent_To__r.User__c ,Simpplr_Site__r.Chatter_Group_Id__c FROM App_Notification__c 
																WHERE Content__c IN : setOfContentIds AND Sub_Type__c='Must Read' AND Type__c='Actionable' AND Is_Deleted__c = false LIMIT 9900];

			List<App_Notification__c> notiListToBeDeleted = new List<App_Notification__c>();
			for(App_Notification__c notiObj : notiList){
				if(mapOfMemberIdToSetOfContentIds.keySet().contains(notiObj.Sent_To__r.User__c) && mapOfMemberIdToSetOfContentIds.get(notiObj.Sent_To__r.User__c).contains(notiObj.Content__c)){
					notiObj.Is_Deleted__c = true;
					notiListToBeDeleted.add(notiObj);
				}
			}
			if(notiListToBeDeleted.size()>0){
				List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
						App_Notification__c.Is_Deleted__c
					};

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notiListToBeDeleted), listOfColumnsToBeUpdated);
			}
		}
	}


	private List<App_Notification__c> getMustReadNotificationListToBeInsertedForAMember(List<Must_Read_Audit__c> MRAContentList, People_Preference__c peoplePrefObj){
		List<App_Notification__c> notiListToInsert = new List<App_Notification__c>();
    	for(Must_Read_Audit__c mraObj : MRAContentList){
			App_Notification__c notificationObj = new App_Notification__c();
			notificationObj.GUID__c = UserContext.id + '-' + System.currentTimeMillis();
			notificationObj.Object_Id__c = mraObj.Content__c;
			notificationObj.Content__c = mraObj.Content__c;
			notificationObj.Object_Type__c = mraObj.Content__r.Type__c;
			notificationObj.Snippet__c = Utility.chompString(mraObj.Content__r.Title__c,255);
			notificationObj.Category__c = 'Must_Read';
			notificationObj.Type__c = 'Actionable';
			notificationObj.Sub_Type__c = 'Must Read';
			notificationObj.Status__c = 'Pending';
			notificationObj.Sent_To__c = peoplePrefObj.people__c;
			notificationObj.Simpplr_Site__c = mraObj.Content__r.site__c;
			notificationObj.Created_DateTime__c = DateTime.now();
			notificationObj.Is_New__c = true;
			notificationObj.Is_Read__c = false;
			notiListToInsert.add(notificationObj);
		}
		return notiListToInsert;
	}


     private void sendNewMustReadsNotifications(List<People_Preference__c> peoplePrefList,Set<String> peopleWhoHaveReadContent){
        Simpplr_Content__c contentObj = [SELECT Id, Name, Is_Must_Read__c, Title__c, Site__c, Site__r.Name, Type__c, Site__r.Site_Type__c, Site__r.Landing_Page__c, 
												Display_Excerpt__c, Event_Start_Datetime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c, Last_Edited_DateTime__c, 
												Primary_Author__r.Full_Name__c, Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, 
												CreatedDate,
												Site__r.Title_Content_Version__c, Event_Is_All_Day__c,
												(SELECT Id,Content_Version__c,Thumbnail_URL__c,Is_Title_Image__c,Title_Image_Type__c
														FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c )
											FROM Simpplr_Content__c WHERE ID =: contentId AND Is_Deleted__c = false limit 1];

    	Must_Read_Audit__c mRAObj = [SELECT Id, Marked_By_People__c, Message__c, Audience_Type__c, Marked_By_People__r.Full_Name__c, 
											Marked_By_People__r.External_Photo_URL__c, Marked_By_People__r.External_Photo_URL_Expiry_Date__c
										FROM Must_Read_Audit__c 
										WHERE Content__c =: contentObj.Id AND Is_Deleted__c = false 
										ORDER BY CreatedDate DESC LIMIT 1];
    	
		List<Messaging.SingleEmailMessage> mustReadsEmailList = new List<Messaging.SingleEmailMessage>();
		List<Map<String, String>> mobileLanguageMapList = new List<Map<String, String>>();
    	String emailHeading = '';
    	String subject = '';
    	List<App_Notification__c> notiListToInsert = new List<App_Notification__c>();
    	String currentUserId = UserContext.id;
		
		List<PushNotifcationWrapper> pushNotiListMobile = new List<PushNotifcationWrapper>();
		List<PushNotifcationWrapper> pushNotiListBrowser = new List<PushNotifcationWrapper>();
		
		String baseUrl = Url.getSalesforceBaseUrl().toExternalForm(); 
		String guid= currentUserId + '-' + System.currentTimeMillis(); // all user share same guid becuase later on we can process same guid's pending requests 
    	String localeKey = '';
		for(People_Preference__c peoplePrefObj : peoplePrefList) {
			localeKey = Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.people__r.User__r.languagelocalekey);

			emailHeading = LocaleContext.getLabel(localeKey, KEY_EMAIL_MUST_READ_INTRO)
									.replace('{{appName}}', SimpplrContext.applicationName);
    		brandingInfo = EmailUtility.getBrandingInfo4People(peoplePrefObj.People__r);
    		 
    		App_Notification__c notificationObj = new App_Notification__c();
			notificationObj.GUID__c = guid;
			notificationObj.Object_Id__c = contentObj.Id;
			notificationObj.Content__c = contentObj.Id;
			notificationObj.Object_Type__c = contentObj.Type__c;
			notificationObj.Snippet__c = Utility.chompString(contentObj.Title__c,255);
			notificationObj.Category__c = 'Must_Read';
			notificationObj.Type__c = 'Actionable';
			notificationObj.Sub_Type__c = 'Must Read';
			notificationObj.Status__c = 'Pending';
			notificationObj.Sent_By__c = UserContext.peopleId;
			notificationObj.Sent_To__c = peoplePrefObj.people__c;
			notificationObj.Simpplr_Site__c = contentObj.site__c;
			notificationObj.Created_DateTime__c = DateTime.now();
			if(peopleWhoHaveReadContent.contains(peoplePrefObj.people__c)){
				notificationObj.Action_By__c = peoplePrefObj.people__c;
				notificationObj.Action_On__c = DateTime.now();
				notificationObj.Is_Read__c = true;
				notificationObj.Is_New__c = false;
			}else{
				notificationObj.Is_New__c = true;
				notificationObj.Is_Read__c = false;
			}
			
    		notiListToInsert.add(notificationObj);
    		if(simpplrMobileNotificationAllowed && !peopleWhoHaveReadContent.contains(peoplePrefObj.people__c)){
	    		if(('native'.equalsIgnoreCase(peoplePrefObj.people__r.Mobile_App_Type_Android__c) && peoplePrefObj.Native_Mob_Content_Marked_As_Must_Read__c == true) || 
	    			('hybrid'.equalsIgnoreCase(peoplePrefObj.people__r.Mobile_App_Type_Android__c) && peoplePrefObj.Mobile_Allow_Notifications__c == true && peoplePrefObj.Mobile_Content_Marked_As_Must_Read__c == true)){
	    			if(String.isNotBlank(peoplePrefObj.people__r.Mobile_Token_Android__c)){
		    			PushNotifcationWrapper pushNotiAndroidObj = new PushNotifcationWrapper();
						pushNotiAndroidObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_PUSH_NOTIFICATION_MUST_READ)
																.replace('{{contentTitle}}', Utility.chompString(contentObj.Title__c,
																		 ServiceConstants.CONTENT_TITLE_IN_NOTIFICATION_MAX_LENGTH));
		    			pushNotiAndroidObj.deviceToken = String.valueOf(peoplePrefObj.people__r.Mobile_Token_Android__c);
		    			pushNotiAndroidObj.deviceType = 'android';
		    			pushNotiAndroidObj.appType = String.isNotBlank(peoplePrefObj.people__r.Mobile_App_Type_Android__c)?peoplePrefObj.people__r.Mobile_App_Type_Android__c:'hybrid';
		    			pushNotiAndroidObj.Url = baseUrl + Page.PageRedirector.getUrl() + '?siteId=' + contentObj.site__c +'&contentId='+contentObj.id+'&pageToRedirect=ContentDetailPage'+'&mustRead=1&origin=pn&contentType='+contentObj.type__c.tolowercase();
						pushNotiAndroidObj.notificationId = '';
						pushNotiAndroidObj.notificationType = 'content';
						pushNotiAndroidObj.sentById = UserContext.peopleId;
						pushNotiAndroidObj.siteId = contentObj.site__c;
						pushNotiAndroidObj.contentId = contentObj.id;
						pushNotiAndroidObj.contentType = contentObj.Type__c;
						pushNotiAndroidObj.privateSiteRequestId = '';
						pushNotiAndroidObj.isClickable = true;
						pushNotiAndroidObj.isActionable = true;
						pushNotiAndroidObj.isMustRead = true;
						pushNotiAndroidObj.badge = Integer.valueOf(peoplePrefObj.people__r.New_Notification_Count__c);
						pushNotiAndroidObj.sound = 'default';
						pushNotiAndroidObj.fcmId = peoplePrefObj.people__r.Mobile_FCM_ID_Android__c;
		    			pushNotiAndroidObj.bundleId = peoplePrefObj.people__r.Mobile_Bundle_ID_Android__c;
						pushNotiListMobile.add(pushNotiAndroidObj);
	    			}
    			}
    			if(('native'.equalsIgnoreCase(peoplePrefObj.people__r.Mobile_App_Type_IOS__c) && peoplePrefObj.Native_Mob_Content_Marked_As_Must_Read__c == true) || 
	    			('hybrid'.equalsIgnoreCase(peoplePrefObj.people__r.Mobile_App_Type_IOS__c) && peoplePrefObj.Mobile_Allow_Notifications__c == true && peoplePrefObj.Mobile_Content_Marked_As_Must_Read__c == true)){
	    			if(String.isNotBlank(peoplePrefObj.people__r.Mobile_Token_IOS__c)){
			        	PushNotifcationWrapper pushNotiIOSObj = new PushNotifcationWrapper();
						pushNotiIOSObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_PUSH_NOTIFICATION_MUST_READ)
																.replace('{{contentTitle}}', Utility.chompString(contentObj.Title__c,
																		ServiceConstants.CONTENT_TITLE_IN_NOTIFICATION_MAX_LENGTH));
						
						pushNotiIOSObj.deviceToken = String.valueOf(peoplePrefObj.people__r.Mobile_Token_IOS__c);
		    			pushNotiIOSObj.deviceType = 'ios';
		    			pushNotiIOSObj.appType = String.isNotBlank(peoplePrefObj.people__r.Mobile_App_Type_IOS__c)?peoplePrefObj.people__r.Mobile_App_Type_IOS__c:'hybrid';
		    			pushNotiIOSObj.Url = baseUrl + Page.PageRedirector.getUrl() + '?siteId=' + contentObj.site__c +'&contentId='+contentObj.id+'&pageToRedirect=ContentDetailPage'+'&mustRead=1&origin=pn&contentType='+contentObj.type__c.tolowercase();
		    			pushNotiIOSObj.notificationId = '';
						pushNotiIOSObj.notificationType = 'content';
						pushNotiIOSObj.sentById = UserContext.peopleId;
						pushNotiIOSObj.siteId = contentObj.site__c;
						pushNotiIOSObj.contentId = contentObj.id;
						pushNotiIOSObj.contentType = contentObj.Type__c;
						pushNotiIOSObj.privateSiteRequestId = '';
						pushNotiIOSObj.isClickable = true;
						pushNotiIOSObj.isActionable = true;
						pushNotiIOSObj.isMustRead = true;
						pushNotiIOSObj.badge = Integer.valueOf(peoplePrefObj.people__r.New_Notification_Count__c);
						pushNotiIOSObj.sound = 'default';
						pushNotiIOSObj.fcmId = peoplePrefObj.people__r.Mobile_FCM_ID_iOS__c;
		    			pushNotiIOSObj.bundleId = peoplePrefObj.people__r.Mobile_Bundle_ID_iOS__c;
		    			pushNotiListMobile.add(pushNotiIOSObj);
		        	}
	    		}
			}
			// check if Mobile Number available
			if(SimpplrContext.isSMSEnabled) {
				if(peoplePrefObj.people__r.Mobile_Phone__c != NULL && peoplePrefObj.SMS_Must_Reads__c == true) {
					Map<String, String> MobileVsLangMap = new Map<String, String>();
					MobileVsLangMap.put('people_id', peoplePrefObj.people__r.id);
					MobileVsLangMap.put('mobile_number', peoplePrefObj.people__r.Mobile_Phone__c);
					MobileVsLangMap.put('languageLocaleKey', Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.people__r.User__r.languagelocalekey).replace('_', '-'));
					mobileLanguageMapList.add(MobileVsLangMap);
				}

			}

			// prepare notification list for browser push
			if('Yes'.equalsIgnoreCase(peoplePrefObj.Allow_Browser_Notifications__c) && peoplePrefObj.Browser_Must_Read__c) {
				PushNotifcationWrapper pushNotiBrowserObj = new PushNotifcationWrapper();
				
				pushNotiBrowserObj.notificationtext = LocaleContext.getLabel(localeKey, KEY_PUSH_NOTIFICATION_MUST_READ)
														.replace('{{contentTitle}}', Utility.chompString(contentObj.Title__c,
																	ServiceConstants.CONTENT_TITLE_IN_NOTIFICATION_MAX_LENGTH));
				
				
				pushNotiBrowserObj.title = SimpplrContext.applicationName;
				pushNotiBrowserObj.deviceType = 'browser';
				pushNotiBrowserObj.Url = baseUrl + Page.PageRedirector.getUrl() + '?siteId=' + contentObj.site__c +'&contentId='+contentObj.id+'&pageToRedirect=ContentDetailPage'+'&mustRead=1&origin=pn&contentType='+contentObj.type__c.tolowercase();
				pushNotiBrowserObj.notificationId = '';
				pushNotiBrowserObj.notificationType = 'content';
				pushNotiBrowserObj.sentById = UserContext.peopleId;
				pushNotiBrowserObj.sentToId = ((String)peoplePrefObj.people__c).substring(0, 15);
				pushNotiBrowserObj.siteId = contentObj.site__c;
				pushNotiBrowserObj.contentId = contentObj.id;
				pushNotiBrowserObj.contentType = contentObj.Type__c;
				pushNotiBrowserObj.privateSiteRequestId = '';
				pushNotiBrowserObj.isClickable = true;
				pushNotiBrowserObj.isActionable = true;
				pushNotiBrowserObj.isMustRead = true;
				
				pushNotiListBrowser.add(pushNotiBrowserObj);
			}

		} // end - For loop

		if(!test.isRunningTest()) {
			if(mobileLanguageMapList.size() > 0) {
				sendMustReadSms(mobileLanguageMapList, contentObj);
			}
			
			// send mobile/web push notifications
			if(pushNotiListMobile.size() > 0 || pushNotiListBrowser.size() > 0) {
				try {
					String notiListJsonMobile = null;
					String notiListJsonBrowser = null;
					
					if( !pushNotiListMobile.isEmpty() ) {
						notiListJsonMobile = JSON.serialize(pushNotiListMobile);
					}
					if( !pushNotiListBrowser.isEmpty() ) {
						notiListJsonBrowser = JSON.serialize(pushNotiListBrowser);
					}

					Utility.sendPushNotifications(notiListJsonMobile, notiListJsonBrowser);
				} catch (Exception ex) {
					//Ignore error while trying to send Push notifications
				}
			}
		}
    	
		if(notiListToInsert.size()>0){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(notiListToInsert, new List<Schema.SObjectField> { 
				App_Notification__c.GUID__c,
				App_Notification__c.Object_Id__c,
				App_Notification__c.Content__c,
				App_Notification__c.Object_Type__c,
				App_Notification__c.Snippet__c,
				App_Notification__c.Category__c,
				App_Notification__c.Type__c,
				App_Notification__c.Sub_Type__c,
				App_Notification__c.Status__c,
				App_Notification__c.Sent_To__c,
				App_Notification__c.Simpplr_Site__c,
				App_Notification__c.Created_DateTime__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Is_Read__c,
				App_Notification__c.Sent_By__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c
			});
    	}

		Map<Id, String> peopleIdToSiteMemberTypeMap = new Map<Id, String>();
		List<Id> peopleIds = new List<Id>();

		if(String.isNotBlank(contentObj.Site__c)) {
			for(People_Preference__c peoplePrefObj : peoplePrefList) {
				peopleIds.add(peoplePrefObj.People__c);
			}

			List<Site_Role__c> siteRoleList = [SELECT Id, People__c, Is_Member__c FROM Site_Role__c 
												WHERE Site__c = :contentObj.Site__c 
												AND People__c = :peopleIds 
												AND Is_Deleted__c = false];
			
			for(Site_Role__c siteRoleObj : siteRoleList) {
				String memberType = '';
				if(siteRoleObj.Is_Member__c == true) {
					peopleIdToSiteMemberTypeMap.put(siteRoleObj.People__c, 'member');
				} else {
					peopleIdToSiteMemberTypeMap.put(siteRoleObj.People__c, 'follower');
				}
			}
		}

		for(People_Preference__c peoplePrefObj : peoplePrefList) { 
    		brandingInfo = EmailUtility.getBrandingInfo4People(peoplePrefObj.People__r);

			if(isSimpplrEmailEnabled) {
	    		if(peoplePrefObj.Allow_Simpplr_Emails__c == true && peoplePrefObj.Email_Content_Marked_As_Must_Read__c == true && peoplePrefObj.Email_Notification_Digest_Frequency__c=='Immediate' && !peopleWhoHaveReadContent.contains(peoplePrefObj.people__c)){
		    		subject = LocaleContext.getLabel(localeKey, KEY_EMAIL_MUST_READ_SUBJECT)
																.replace('{{contentTitle}}', Utility.chompString(contentObj.Title__c,
																		ServiceConstants.SNIPPET_IN_NOTIFICATION_MAX_LENGTH));

					String memberType = peopleIdToSiteMemberTypeMap.get(peoplePrefObj.People__c);
		    		String mustReadsBody = getMustReadsHTMLEmailBody(emailHeading, contentObj, mRAObj, localeKey, peoplePrefObj, memberType);
		    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
					singleMail.setTargetObjectId(peoplePrefObj.people__r.User__c);
					singleMail.setSubject(subject);
					// singleMail.setReplyTo(ServiceConstants.EMAIL_NOTI_NOREPLY_ADDRESS);
					if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
						singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
					}
					if(SimpplrContext.DeeplinkingEnabled) {
						mustReadsBody = EmailUtility.deeplinkedMailBody(mustReadsBody);
					}
					
					singleMail.setHtmlBody(mustReadsBody);
					singleMail.setCharset('UTF-8');
					singleMail.setUseSignature(false);
					singleMail.setSaveAsActivity(false);
					mustReadsEmailList.add(singleMail);
	    		}
    		}
		}
        if(mustReadsEmailList.size() > 0) {
        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(mustReadsEmailList);
		}
    }
    
	private String getMustReadsHTMLEmailBody(String heading, Simpplr_Content__c simpplrContentObj, Must_Read_Audit__c mRAObj,
						String localeKey, People_Preference__c peoplePrefObj, String siteMemberType){
		
		String targetPeopleId = peoplePrefObj.people__c;
		String targetUserName = peoplePrefObj.people__r.user__r.userName;

		List<String> formatterList = new List<String>();

		String externalPhotoUrl = mRAObj.Marked_By_People__r.External_Photo_URL__c;
		DateTime externalPhotoUrlExpiryDate = mRAObj.Marked_By_People__r.External_Photo_URL_Expiry_Date__c;

		String profileDisplayIcon = getProfileDisplayIcon(externalPhotoUrl, externalPhotoUrlExpiryDate);
		String contentLink = SimpplrContext.salesForceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + simpplrContentObj.site__c +'&contentId='+simpplrContentObj.id+'&pageToRedirect=ContentDetailPage'+'&mustRead=1&origin=ne&contentType='+simpplrContentObj.type__c.tolowercase()+'&utm_source=activity_notifications_email&utm_term=content_marked_must_read&utm_medium=email';
				
		String emailBodyMustReads = EmailTemplateService.templatePartMap.get('mustReads');
		//0=Target User First Name 1=Subject  2=profileImage 3=Logged in user Full Name 4= email body with type and title 5=View Link to Content 6=Branding Info
		
		String userName = peoplePrefObj.people__r.Last_Name__c;
		if(String.isNotBlank(peoplePrefObj.people__r.First_Name__c)){
			userName = peoplePrefObj.people__r.First_Name__c;
		}

		// 0
		formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_HI)
						.replace('{{firstName}}', userName));

		String uName = '';
		uName = UserContext.getCurrentUserInfo.Full_Name__c;
		
		String contentType = simpplrContentObj.Type__c;
		contentType = LocaleContext.getLabel(localeKey, CONTENT_TYPE_LOCALIZE_MAP.get(contentType.toLowerCase())); 
		
		formatterList.add(heading); // 1
		formatterList.add(profileDisplayIcon); // 2
		formatterList.add(uName); // 3
		formatterList.add(''); // 4
		formatterList.add((String.isNotBlank(mRAObj.Message__c)) ? mRAObj.Message__c : ''); // 5
		formatterList.add(contentLink); // 6
		formatterList.add(brandingInfo.general_primaryColor); // 7
		formatterList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_VIEW_BTN)); // 8

		//formatterList.add('<tr><td>contentBlock</td></tr>');
		List<Simpplr_Content__c> contentTempList = new List<Simpplr_Content__c>();
		contentTempList.add(simpplrContentObj);
		getcontentIdNPublicUrlMap(contentTempList);
		formatterList.add(getContentBodyBlock(simpplrContentObj, mRAObj, localeKey, peoplePrefObj, siteMemberType, brandingInfo.general_primaryColor)); // 9
		emailBodyMustReads = EmailUtility.format(emailBodyMustReads, formatterList); // 10

		formatterList.clear();

		return getEmailTemplateWithHeaderFooterWithNoSettings(targetUserName, targetPeopleId, emailBodyMustReads, localeKey,mRAObj,peoplePrefObj);
	}
	
	private String getEmailTemplateWithHeaderFooterWithNoSettings(String targetUserName, String targetPeopleId, String emailBody, String localeKey,Must_Read_Audit__c mRAObj,People_Preference__c peoplePrefObj){
		String finalEmailWithTemplate = '';
		logoUrl = brandingInfo.logo_url;
		List<String> formatterList = new List<String>();
		String templateWithHeaderFooter = contentMustReadsPartMap.get('emailTemplateWithHeaderFooterWithNoSettings');
		
		formatterList.add(logoUrl); //{0}
    	formatterList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(), localekey));//{1}
    	formatterList.add(emailBody);//{2}
    	formatterList.add(LocaleContext.getLabel(localekey, KEY_FOOTER_SETTINGS).replace('{{appName}}', SimpplrContext.applicationName));//{3}
		formatterList.add((LocaleContext.getLabel(localekey, KEY_COPYRIGHT_TEXT)).replace('{{year}}', String.valueOf(Date.today().year())));//{4} 
    	formatterList.add(LocaleContext.getLabel(localekey, KEY_POWERED_BY));//{5}
		formatterList.add('http://www.simpplr.com');//{6}
		formatterList.add('<style> @media all {.ExternalClass {width: 100%;}.ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font, .ExternalClass td,.ExternalClass div {line-height: 100%; }.apple-link a {color: inherit !important;font-family: inherit !important;font-size: inherit !important;font-weight: inherit !important; line-height: inherit !important; text-decoration: none !important;}}@media only screen and (max-width: 620px) {table[class=body] .wrapper,table[class=body] .header, table[class=body] .article { padding: 10px !important; } table[class=body] .content { padding: 0 !important; } table[class=body] .container {padding: 0 !important; width: 100% !important; }table[class=body] .main {border-left-width: 0 !important;border-radius: 0 !important;border-right-width: 0 !important;} table[class=body] .btn table {width: 100% !important;}table[class=body] .btn a {width: 100% !important; }table[class=body] .img-responsive {height: auto !important;max-width: 100% !important;width: auto !important; }td[class="mobile-hide"] {display: none; }.mobile-hide {display: none;} .wrapper,.header, .article { padding: 10px !important;} .content { padding: 0 !important;}.container {padding: 0 !important;width: 100% !important;}.main { border-left-width: 0 !important;border-radius: 0 !important; border-right-width: 0 !important;}.btn table { width: 100% !important;} .btn a { width: 100% !important; }.img-responsive { height: auto !important;max-width: 100% !important;width: auto !important;}} a[x-apple-data-detectors] {color: inherit !important;text-decoration: none !important;font-size: inherit !important;font-family: inherit !important; font-weight: inherit !important;line-height: inherit !important; }</style><!--[if (gte mso 9)|(IE)]> <style type="text/css"> table {border-collapse: collapse;} </style> <![endif]-->');//{7}
    	formatterList.add(BaseCtrl.salesForceBaseUrl + Page.PageRedirector.getUrl()+'?userId='+targetPeopleId+'&pageToRedirect='+Pages.MySettingsEmail+'&origin=ne');//{8}
		
		formatterList.add(EmailUtility.getMobilePromotionFooterDiv(localekey, targetPeopleId)); // mobile promotion footer
		
		// header background // 10
		if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('000000');
		} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
			formatterList.add(brandingInfo.general_primaryColor);
		} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('ffffff');
		} else {
			formatterList.add(brandingInfo.header_backgroundColor);
		}
		formatterList.add(SimpplrContext.simpplrAPIEndpoint+'/sneot?td='); //11
		formatterList.add(Utility.getNewsletterTrackerCode(mRAObj.Id, peoplePrefObj.people__r.User_Hash__c)+'&action=mustread'); //12

		finalEmailWithTemplate = EmailUtility.format(templateWithHeaderFooter, formatterList);

		return finalEmailWithTemplate;
	}

	private String getAuthorDetails(Simpplr_Content__c contentObj) {
		String authorDetailsPart = contentMustReadsPartMap.get('authorDetailsRow');

		String publicPhotoURL = contentObj.Primary_Author__r.External_Photo_URL__c;
		DateTime photoUrlExpiryDate = contentObj.Primary_Author__r.External_Photo_URL_Expiry_Date__c;

		if(String.isBlank(publicPhotoURL) || photoUrlExpiryDate == null || photoUrlExpiryDate <= DateTime.now()) {
			publicPhotoURL = (EmailConstants.peopleDefaultIcon);
		}

		List<String> authorDetailsPartList = new List<String>();
		authorDetailsPartList.add(publicPhotoURL);
		authorDetailsPartList.add(contentObj.Primary_Author__r.Full_Name__c);
		
		authorDetailsPart = EmailUtility.format(authorDetailsPart, authorDetailsPartList);

		return authorDetailsPart;
	}

	private String getMustReadMsg(String mRMessage) {
		String mustReadMsgPart = contentMustReadsPartMap.get('topMessageRow');
		
		List<String> mustReadMsgPartList = new List<String>();
		mustReadMsgPartList.add((String.isNotBlank(mRMessage)) ? mRMessage : '');
		
		mustReadMsgPart = EmailUtility.format(mustReadMsgPart, mustReadMsgPartList);

		return mustReadMsgPart;
	}

	private String getViewButtonBlock(Simpplr_Content__c contentObj, NotificationHelper.BrandingInfo brandingInfo, String localeKey) {
		String viewButtonPart = contentMustReadsPartMap.get('viewButtonRow');
		
		List<String> viewButtonPartList = new List<String>();
		String contentLink = SimpplrContext.salesForceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + contentObj.site__c +'&contentId='+contentObj.id+'&pageToRedirect=ContentDetailPage'+'&mustRead=1&origin=ne&contentType='+contentObj.type__c.tolowercase();
		
		viewButtonPartList.add(contentLink);
		viewButtonPartList.add(brandingInfo.general_primaryColor);
		viewButtonPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_VIEW_BTN));
		
		viewButtonPart = EmailUtility.format(viewButtonPart, viewButtonPartList);

		return viewButtonPart;
	}

	private String getContentBodyBlock(Simpplr_Content__c content, Must_Read_Audit__c mRAObj, String localeKey, People_Preference__c peoplePrefObj, String memberType, String generalPrimaryColor) {
		String contentBodyBlock = '';
				
		String contentPart = '';
		Map<String,String> partMap = contentMustReadsPartMap;

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

		contentPart = '<table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">'
						+ contentPart 
						+ '</td></tr></table>';

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
				if(content.Event_Is_All_Day__c == false) {
					startDay = LocaleContext.getLocalisedDateAsUMMDDHHMMAA(content.Event_Start_Datetime__c, localeKey, content.Event_TimezoneSidKey__c);
					endDay = LocaleContext.getLocalisedDateAsUMMDDHHMMAA(content.Event_End_DateTime__c, localeKey, content.Event_TimezoneSidKey__c);
				}
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
		contentPartList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(content.Last_Edited_DateTime__c, localeKey, peoplePrefObj.People__r.User__r.timezonesidkey));//Created date time
		
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

		if((mRAObj != null && 'everyone'.equalsIgnoreCase(mRAObj.Audience_Type__c)) || 'BlogPost'.equalsIgnoreCase(content.type__c)) {
			//10.23
			String label_must_read_for_app = LocaleContext.getLabel(localeKey, KEY_EMAIL_MUST_READ_SHARED_WITH_APP).replace('{{appName}}',SimpplrContext.applicationName);
			contentPartList.add(label_must_read_for_app);
		} else {
			//10.23
			if(String.isNotBlank(memberType)) {
				String label_must_read_for_site = LocaleContext.getLabel(localeKey, KEY_EMAIL_MUST_READ_SHARED_WITH_SITE)
										.replace('{{memberType}}', memberType)
										.replace('{{siteName}}', content.Site__r.Name);
				contentPartList.add(label_must_read_for_site);
				
			}
		}
		contentBodyBlock = EmailUtility.format(contentPart, contentPartList);
		return contentBodyBlock;
	}

	public void mustReadsReminderEmailForSingleContent(List<People_Preference__c> peoplePrefList){
    	List<Messaging.SingleEmailMessage> reminderForMustReadsEmailList = new List<Messaging.SingleEmailMessage>();
    	List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
    	String localeKey = '';
		
		DateTime currentDateTime = DateTime.now();
		for(People_Preference__c peoplePrefObj : peoplePrefList) {
			localeKey = Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.people__r.User__r.languagelocalekey);

			brandingInfo = EmailUtility.getBrandingInfo4People(peoplePrefObj.People__r);
			
			List<Simpplr_Content__c> contentTempList = new List<Simpplr_Content__c>();
			List<Must_Read_Audit__c> mRAObjList = new List<Must_Read_Audit__c>();

			String peopleId = peoplePrefObj.people__c;

			String contentQuery = 'select id,Popularity_Score__c, Title__c, Type__c,Text_Intro__c, Site__c, Site__r.Name, Site__r.Site_Type__c, ' + 
								' Site__r.Landing_Page__c, Publish_Start_DateTime__c, Last_Edited_DateTime__c, '+
								' Event_Start_Datetime__c,Event_End_Datetime__c,Event_TimezoneSidKey__c,Event_Is_All_Day__c,Primary_Author__c,Primary_Author__r.Full_Name__c,Display_Excerpt__c, ' +
								' Site__r.Chatter_Group_Id__c,Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, Is_Must_Read__c, createdDate, ' + 
								' Site__r.Title_Content_Version__c, ' +
								' (SELECT Id,Content_Version__c,Thumbnail_URL__c,Is_Title_Image__c,Title_Image_Type__c ' +
								'       FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c )' + 
								' FROM Simpplr_Content__c WHERE id = :contentId' + 
								' AND id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime)) ' + 
								' AND Id NOT IN (Select content__c from Must_Read_Confirm_History__c where People__c=:peopleId AND Must_Read_Audit__r.Removed_DateTime__c = null) ';
			
			contentQuery += ' And Is_Deleted__c = false ';
	        contentQuery += ' AND Activated_By_Feature__c = true ';
	        contentQuery += ' AND Is_Published__c = true ';
	        contentQuery += ' And TYPE__c IN : allowedFeaturesInAppList ';
			
			contentQuery += ' Order By Publish_Start_DateTime__c Desc, Last_Edited_DateTime__c desc ';

			String mRAQuery = 'SELECT Id, Content__r.Id, Marked_By_People__c, Message__c, Audience_Type__c FROM Must_Read_Audit__c ' +
										' WHERE Content__r.Id = :contentId AND Removed_DateTime__c = null ' + 
											' AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime)';
			
			contentTempList.addAll((List<Simpplr_Content__c>)Database.query(contentQuery));
			mRAObjList.addAll((List<Must_Read_Audit__c>)Database.query(mRAQuery));
			
			if(contentTempList.size()>0 && mRAObjList.size() > 0 && peoplePrefObj!=null){
	    		String emailBody = getMustReadsReminderBody(peoplePrefObj, contentTempList, mRAObjList, localeKey);
				String subject = contentTempList.size() == 1 ? 
									(LocaleContext.getLabel(localeKey, KEY_EMAIL_MUST_READ_REMINDER_SUBJECT)).replace('{{count}}', '1') : 
				 					(LocaleContext.getLabel(localeKey, 
									 	KEY_EMAIL_MUST_READ_REMINDER_SUBJECT_PLURAL)).replace('{{count}}', String.valueOf(contentTempList.size()));
	    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
				singleMail.setTargetObjectId(peoplePrefObj.people__r.User__c);
				singleMail.setSubject(subject);
				// singleMail.setReplyTo(ServiceConstants.EMAIL_NOTI_NOREPLY_ADDRESS);
				if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
					singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
				}
				if(SimpplrContext.DeeplinkingEnabled) {
					emailBody = EmailUtility.deeplinkedMailBody(emailBody);
				}
				
				singleMail.setHtmlBody(emailBody);
				singleMail.setCharset('UTF-8');
				singleMail.setUseSignature(false);
				singleMail.setSaveAsActivity(false);
				reminderForMustReadsEmailList.add(singleMail);
			}
		}
		
		if(reminderForMustReadsEmailList.size() > 0) {
        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(reminderForMustReadsEmailList);
        }
    }
	
	public void sendReminderForMustReadsEmail(List<People_Preference__c> peoplePrefList){
    	List<Messaging.SingleEmailMessage> reminderForMustReadsEmailList = new List<Messaging.SingleEmailMessage>();
    	List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
    	String localeKey = '';
		DateTime currentDateTime = DateTime.now();

		Map<Id, List<Site_Role__c>> mapOfPeopleIdBySiteRole = getMapOfPeopleIdBySiteRole(peoplePrefList);

		for(People_Preference__c peoplePrefObj : peoplePrefList) {
			Set<Id> groupsIFollowIdSet = new Set<Id>();
			Set<Id> groupsIMemberIdSet = new Set<Id>();
			localeKey = Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.people__r.User__r.languagelocalekey);

			brandingInfo = EmailUtility.getBrandingInfo4People(peoplePrefObj.People__r);
			
			List<Simpplr_Content__c> contentTempList = new List<Simpplr_Content__c>();
			List<Must_Read_Audit__c> mRAObjList = new List<Must_Read_Audit__c>();

			String peopleId = peoplePrefObj.people__c;

			List<Site_Role__c> siteRoleList = mapOfPeopleIdBySiteRole.get(peopleId);
		
			for(Site_Role__c siteRoleObj : siteRoleList) {
				groupsIFollowIdSet.add(siteRoleObj.Site__r.Chatter_group_id__c);
				if(siteRoleObj.Is_Member__c == true) {
					groupsIMemberIdSet.add(siteRoleObj.Site__r.Chatter_group_id__c);
				}
			}

			String contentQuery = 'select id,Popularity_Score__c, Title__c, Type__c,Text_Intro__c, Site__c, Site__r.Name, Site__r.Site_Type__c, ' + 
								' Site__r.Landing_Page__c, Publish_Start_DateTime__c, Last_Edited_DateTime__c, '+
								' Event_Start_Datetime__c,Event_End_Datetime__c,Event_TimezoneSidKey__c,Event_Is_All_Day__c,Primary_Author__c,Primary_Author__r.Full_Name__c,Display_Excerpt__c, ' +
								' Site__r.Chatter_Group_Id__c,Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, Is_Must_Read__c, createdDate, ' + 
								' Site__r.Title_Content_Version__c, ' +
								' (SELECT Id,Content_Version__c,Thumbnail_URL__c,Is_Title_Image__c,Title_Image_Type__c ' +
								'       FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c )' + 
								' FROM Simpplr_Content__c ' + 
								' WHERE id IN (SELECT Content__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) ' + 
								' AND  ( Audience_Type__c=\'everyone\' OR (Audience_Type__c=\'site_members\' AND Content__r.Site__r.Chatter_Group_Id__c = :groupsIMemberIdSet) OR (Audience_Type__c=\'site_members_and_followers\' AND Content__r.Site__r.Chatter_Group_Id__c = :groupsIFollowIdSet)))  ' + 
								' AND Id NOT IN (Select content__c from Must_Read_Confirm_History__c where People__c=:peopleId AND Must_Read_Audit__r.Removed_DateTime__c = null) ';
			
			contentQuery += ' And Is_Deleted__c = false ';
	        contentQuery += ' AND Activated_By_Feature__c = true ';
	        contentQuery += ' AND Is_Published__c = true ';
	        contentQuery += ' And TYPE__c IN : allowedFeaturesInAppList ';
			
			contentQuery += ' Order By Publish_Start_DateTime__c Desc, Last_Edited_DateTime__c desc ';

			String mRAQuery = 'SELECT Id, Content__r.Id, Marked_By_People__c, Message__c, Audience_Type__c FROM Must_Read_Audit__c ' +
										' WHERE Removed_DateTime__c = null  AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime) AND  ( Audience_Type__c=\'everyone\' OR (Audience_Type__c=\'site_members\' AND Content__r.Site__r.Chatter_Group_Id__c = :groupsIMemberIdSet) OR (Audience_Type__c=\'site_members_and_followers\' AND Content__r.Site__r.Chatter_Group_Id__c = :groupsIFollowIdSet))';
			
			contentTempList.addAll((List<Simpplr_Content__c>)Database.query(contentQuery));
			mRAObjList.addAll((List<Must_Read_Audit__c>)Database.query(mRAQuery));
			
			if(contentTempList.size()>0 && peoplePrefObj!=null){
	    		String emailBody = getMustReadsReminderBody(peoplePrefObj, contentTempList, mRAObjList, localeKey);
				String subject = contentTempList.size() == 1 ? 
									(LocaleContext.getLabel(localeKey, KEY_EMAIL_MUST_READ_REMINDER_SUBJECT)).replace('{{count}}', '1') : 
				 					(LocaleContext.getLabel(localeKey, 
									 	KEY_EMAIL_MUST_READ_REMINDER_SUBJECT_PLURAL)).replace('{{count}}', String.valueOf(contentTempList.size()));
	    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
				singleMail.setTargetObjectId(peoplePrefObj.people__r.User__c);
				singleMail.setSubject(subject);
				// singleMail.setReplyTo(ServiceConstants.EMAIL_NOTI_NOREPLY_ADDRESS);
				if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
					singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
				}
				if(SimpplrContext.DeeplinkingEnabled) {
					emailBody = EmailUtility.deeplinkedMailBody(emailBody);
				}
				
				singleMail.setHtmlBody(emailBody);
				singleMail.setCharset('UTF-8');
				singleMail.setUseSignature(false);
				singleMail.setSaveAsActivity(false);
				reminderForMustReadsEmailList.add(singleMail);
			}
		}
		
		if(reminderForMustReadsEmailList.size() > 0) {
        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(reminderForMustReadsEmailList);
        }
    }
	
	private String getMustReadsReminderBody(People_Preference__c peoplePrefObj, 
						List<Simpplr_Content__c> contentTempList, List<Must_Read_Audit__c> mRAObjList, String localeKey) {
    	
		String mustReadsReminderEmailBody = '';
    	logoUrl = brandingInfo.logo_url;
    	String targetPeopleId = peoplePrefObj.people__c;
    	Map<String,String> partMap = contentMustReadsPartMap; 
    	List<String> baseEmailBodyList = new List<String>();
    	baseEmailBodyList.add('' +SimpplrContext.salesforceBaseUrl  + Page.app.getUrl()); // 0-repeated with 11th
    	baseEmailBodyList.add(logoUrl); // 1
    	baseEmailBodyList.add(EmailUtility.getFormattedDate(DateTime.now(), peoplePrefObj.people__r.User__r.timezonesidkey));//2

		String userName = peoplePrefObj.people__r.Full_Name__c;
		if(String.isNotBlank(peoplePrefObj.people__r.First_Name__c)){
			userName = peoplePrefObj.people__r.First_Name__c;
		}
		baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_HI)
						.replace('{{firstName}}', userName)); //{3}

        if(contentTempList.size() == 1){
        	baseEmailBodyList.add(LocaleContext.getLabel(localeKey,
					KEY_EMAIL_SUMMARY_MUST_READ_INTRO_SINGULAR).replace('{{count}}', String.valueOf(contentTempList.size())).replace('{{appName}}', SimpplrContext.applicationName)); //4
        }else{
        	baseEmailBodyList.add(LocaleContext.getLabel(localeKey, 
					KEY_EMAIL_SUMMARY_MUST_READ_INTRO_PLURAL).replace('{{count}}', String.valueOf(contentTempList.size())).replace('{{appName}}', SimpplrContext.applicationName)); //4
        }
    	baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_SUMMARY_MUST_READ_LEAD_IN)); // {5}
    	baseEmailBodyList.add(peoplePrefObj.people__r.User__r.UserName); // 6
		baseEmailBodyList.add(''); // 7
		baseEmailBodyList.add('https://www.simpplr.com'); //8
		baseEmailBodyList.add('Simpplr'); //9
		
		String allContentRows = '';
		String viewURL = '';
		String thumbnailTitleImageHTML = '';
		String widescreenTitleImageHTML = '';
		
		getcontentIdNPublicUrlMap(contentTempList);
		
		// *******************Content ROW************************************
		Map<String, Must_Read_Audit__c> mapOfContentIdWithMustReadAuditObj = new Map<String, Must_Read_Audit__c>();
		for(Must_Read_Audit__c mRAObject: mRAObjList) {
			mapOfContentIdWithMustReadAuditObj.put(mRAObject.Content__r.Id, mRAObject);
		}

		String superPreString = '<tr><td class="content-block" style="border-collapse:collapse;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;padding-bottom:10px;padding-top:10px;text-align:left;vertical-align:top"><table style="border-collapse:separate;width:100%"><tbody><tr><td class="Post" style="border:1px solid #eeeeee;border-collapse:collapse;border-radius:5px;color:#333;font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size:14px;padding:10px 10px 0;text-align:left;vertical-align:top;">';
		String superPostString = '</td></tr></tbody></table></td></tr>';


		Map<Id, String> siteIdVsPeopleMembershipMap = new Map<Id, String>();
		Set<Id> siteIdsSet = new Set<Id>();
		for(Simpplr_Content__c contentObj : contentTempList) {
			siteIdsSet.add(contentObj.Site__c);
		}

		if( !siteIdsSet.isEmpty() ) {
			List<Site_Role__c> siteRoleList = [SELECT Id, Site__c, People__c, Is_Member__c FROM Site_Role__c 
												WHERE Site__c = :siteIdsSet
												AND People__c = :peoplePrefObj.People__c 
												AND Is_Deleted__c = false];
			
			for(Site_Role__c siteRoleObj : siteRoleList) {
				String memberType = '';
				if(siteRoleObj.Is_Member__c == true) {
					siteIdVsPeopleMembershipMap.put(siteRoleObj.Site__c, 'member');
				} else {
					siteIdVsPeopleMembershipMap.put(siteRoleObj.Site__c, 'follower');
				}
			}
		}

		Must_Read_Audit__c mRAObj;
	    for (Simpplr_Content__c contentObj : contentTempList) {
			mRAObj = mapOfContentIdWithMustReadAuditObj.get(contentObj.Id);
			
			String preString = '<table style="border-collapse:separate;width:100%"><tbody>';
			String postString = '</tbody></table>';

			String memberType = siteIdVsPeopleMembershipMap.get(contentObj.Site__c);
			String contentBodyBlock = getContentBodyBlock(contentObj, mRAObj, localeKey, peoplePrefObj, memberType, brandingInfo.general_primaryColor);
			
			String authorDetails = getAuthorDetails(contentObj);
			String mustReadMsg = '';
			if(mRAObj != null) {
				mustReadMsg = getMustReadMsg(mRAObj.Message__c);
			}
			
			String viewButtonBlock = getViewButtonBlock(contentObj, brandingInfo, localeKey);
			
			contentBodyBlock = authorDetails + mustReadMsg + preString + contentBodyBlock + postString;

			contentBodyBlock = superPreString + contentBodyBlock + viewButtonBlock + superPostString;

			allContentRows += contentBodyBlock;
	    }
	    // *******************Content Row ends************************************
	    
		baseEmailBodyList.add(allContentRows); // 10 for content rows. 
		
		//baseEmailBodyList.add(getMustReadsReminderContentBody(contentTempList, localeKey, peoplePrefObj.people__r.User__r.timezonesidkey));//10
		baseEmailBodyList.add('' + SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?userId=' + peoplePrefObj.people__r.user__c +'&pageToRedirect='+Pages.MySettingsEmail+'&origin=tse');//{11}
		// header background // 12
		if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
			baseEmailBodyList.add('000000');
		} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
			baseEmailBodyList.add(brandingInfo.general_primaryColor);
		} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
			baseEmailBodyList.add('ffffff');
		} else {
			baseEmailBodyList.add(brandingInfo.header_backgroundColor);
		}
		
		// footer background //13
		baseEmailBodyList.add('f8f8f8');
		baseEmailBodyList.add(brandingInfo.header_iconColor); // header text color Applicable for date only. // 14
		//baseEmailBodyList.add(brandingInfo.footer_textColor); // footer text color Applicable for footer text only. // 15
		baseEmailBodyList.add('333333'); // footer text color Applicable for footer text only. // 15
		baseEmailBodyList.add(brandingInfo.general_primaryColor); // Link color Applicable for all links in header and footer. // 16
		//17 CSS media rule
		baseEmailBodyList.add('<style type="text/css">/* MOBILE STYLES */@media screen and (max-width: 525px) {/* USE THESE CLASSES TO HIDE CONTENT ON MOBILE */td[class="mobile-hide"]{display:none;}}</style><!--[if(gte mso 9)|(IE)]><style type="text/css">table {border-collapse: collapse;}</style><![endif]-->');
		
		String languagelocalekey = Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.People__r.User__r.languagelocalekey);

		//18 app name
		baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, EmailConstants.KEY_FOOTER_SETTINGS).replace('{{appName}}',SimpplrContext.applicationName));
		//19 app name
		baseEmailBodyList.add('');
		//20 copyright 
		baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, EmailConstants.KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
		//21 powered by 
		baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, EmailConstants.KEY_POWERED_BY));
		//22 APPName 
		baseEmailBodyList.add(SimpplrContext.applicationName);
		// 23 mediaCSS
		baseEmailBodyList.add('<style>@media all {    .ExternalClass {      width: 100%;    }    .ExternalClass,    .ExternalClass p,    .ExternalClass span,    .ExternalClass font,    .ExternalClass td,    .ExternalClass div {      line-height: 100%;    }    .apple-link a {      color: inherit !important;      font-family: inherit !important;      font-size: inherit !important;      font-weight: inherit !important;      line-height: inherit !important;      text-decoration: none !important;    }  }@media only screen and (max-width:620px) {    table[class=body] .wrapper,    table[class=body] .header,    table[class=body] .article {      padding: 10px !important;    }    table[class=body] .content {      padding: 0 !important;    }    table[class=body] .container {      padding: 0 !important;      width: 100% !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .btn a {      width: 100% !important;    }    table[class=body] .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }    td[class="mobile-hide"] {      display: none;    }    .mobile-hide {      display: none;    }    .newsletter-item .media {      width: 100px !important;    }    .newsletter-item .media .Calendar .CalendarMonth {      font-size: 14px !important;    }    .newsletter-item .media .Calendar .CalendarDay {      font-size: 33px !important;    }    .newsletter-item--showCase .media {      width: 100% !important;    }    .newsletter-item--showCase .media .Calendar .CalendarMonth {      font-size: 20px !important;    }    .newsletter-item--showCase .media .Calendar .CalendarDay {      font-size: 40px !important;    }    .wrapper,    .header,    .article {      padding: 10px !important;    }    .content {      padding: 0 !important;    }    .container {      padding: 0 !important;      width: 100% !important;    }    .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    .btn table {      width: 100% !important;    }    .btn a {      width: 100% !important;    }    .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }  }    a[x-apple-data-detectors] {        color: inherit !important;        text-decoration: none !important;        font-size: inherit !important;        font-family: inherit !important;        font-weight: inherit !important;        line-height: inherit !important;    }</style>');
		
		// 24 mobile promotion footer
		baseEmailBodyList.add(EmailUtility.getMobilePromotionFooterDiv(languagelocalekey, peoplePrefObj.people__c));
		
		mustReadsReminderEmailBody = EmailUtility.format(partMap.get('BaseEmailBody'), baseEmailBodyList);

    	return mustReadsReminderEmailBody;
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

	private String getProfileDisplayIcon(String publicPhotoURL, DateTime photoUrlExpiryDate) {
		List<String> formatterList = new List<String>();
		if(String.isBlank(publicPhotoURL) || photoUrlExpiryDate == null || photoUrlExpiryDate <= DateTime.now()) {
			formatterList.add(EmailConstants.peopleDefaultIcon);
		} else {
			formatterList.add(publicPhotoURL);
		}
		String profileDisplayIcon = EmailUtility.format(EmailTemplateService.templatePartMap.get('profileImage'),formatterList);
		return profileDisplayIcon;
	}

	private ResponseWrapper sendMustReadSms (List<Map<String, String>> mobileLanguageMapList, Simpplr_Content__c contentObj) {
		logger.logDebug('NotificationDataServer----sendMustReadSms----');
		String MUST_READ_SMS_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/notifications/sms-processor?utm_medium=sms&utm_source=sms_must_read'; 
		ResponseWrapper response;
		Http httpObj = new Http();
		String simpplrDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
        HttpRequest req = new HttpRequest();
		req.setEndpoint(MUST_READ_SMS_ENDPOINT);
		
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('mobileLanguageMapList', mobileLanguageMapList);
		requestBody.put('appName', SimpplrContext.applicationName);
		requestBody.put('content_title', contentObj.Title__c);
		requestBody.put('content_id', contentObj.Id);
		requestBody.put('url', SimpplrContext.salesForceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + contentObj.site__c +'&contentId='+contentObj.id+'&pageToRedirect=ContentDetailPage'+'&mustRead=1&origin=ne&contentType='+contentObj.type__c.tolowercase()+'&utm_source=sms_must_read&utm_medium=sms');
		requestBody.put('sms_type', 'MustRead');
		requestBody.put('batch_number', batchNumber);
		requestBody.put('sender_id', UserContext.peopleId);
		requestBody.put('org_id', SimpplrContext.simpplrOrgId.substring(0, 15));
		requestBody.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
		req.setBody(Json.serialize(requestBody));
		req.setHeader('simpplr-dri', simpplrDri);
		
        req.setMethod('POST');
        HttpResponse res = httpObj.send(req);
		String smsResponse= res.getBody();
		logger.logError('BatchMustReadNotifications.sendMustReadSms()----smsResponse----' + smsResponse);
		Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(smsResponse);

		if (requestDataMap != null && requestDataMap.containsKey('status')) {

			if ('error'.equalsIgnoreCase((String)requestDataMap.get('status'))) {
				logger.logError('BatchMustReadNotifications.sendMustReadSms()-------' + 'error'); 
			
			} else {
				logger.logError('BatchMustReadNotifications.sendMustReadSms()-------' + 'success');
			}

		} else {
			logger.logError('BatchMustReadNotifications.sendMustReadSms()-------' + 'error');
		}
		
		return response;
	}

	private Map<Id, List<Site_Role__c>> getMapOfPeopleIdBySiteRole(List<People_Preference__c> peoplePrefList) {
		Set<Id> peopleIdsForBatch = new Set<Id>();
		for(People_Preference__c peoplePrefObj : peoplePrefList) {
			peopleIdsForBatch.add(peoplePrefObj.People__c);
		}

		List<Site_Role__c> siteRoleList = [SELECT Id, People__c, Is_Member__c, Site__r.Chatter_group_id__c FROM Site_Role__c Where People__c = :peopleIdsForBatch AND Is_Deleted__c = false ORDER BY People__c];

		List<Site_Role__c> siteRoleListForPeople;
		Map<Id, List<Site_Role__c>> mapOfPeopleIdBySiteRole = new Map<Id, List<Site_Role__c>>();

		for(Site_Role__c siteRole : siteRoleList) {
			Id pplId = siteRole.People__c;
			if(mapOfPeopleIdBySiteRole.containsKey(pplId)) {
				siteRoleListForPeople = mapOfPeopleIdBySiteRole.get(pplId);
			} else {
				siteRoleListForPeople = new List<Site_Role__c>();
			}

			siteRoleListForPeople.add(siteRole);

			mapOfPeopleIdBySiteRole.put(pplId, siteRoleListForPeople);
		}

		return mapOfPeopleIdBySiteRole;
	}
	
}