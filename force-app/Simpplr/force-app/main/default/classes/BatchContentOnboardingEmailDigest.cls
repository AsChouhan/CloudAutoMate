public without sharing class BatchContentOnboardingEmailDigest implements Database.Batchable<sObject>, Database.Stateful{

    private static final String KEY_EMAIL_HI = 'email.common.salutation';
    private static final String KEY_EMAIL_ONBOARDING_SUBJECT = 'email.notification.content.onboarding.subject';
    private static final String KEY_EMAIL_SUMMARY_ONBOARDING_INTRO_SINGULAR = 'email.notification.summary.onboarding.intro_singular';
    private static final String KEY_EMAIL_SUMMARY_ONBOARDING_INTRO_PLURAL = 'email.notification.summary.onboarding.intro_plural';
    private static final String KEY_EMAIL_VIEW_ALL_ONBOARDING_BTN = 'email.view.all.onboarding.btn';
    private static final String KEY_EMAIL_ONBOARDING_SHARED_WITH_APP = 'email.notification.content.onboarding.shared_with_app';
    private static final String KEY_EMAIL_ONBOARDING_SHARED_WITH_SITE = 'email.notification.content.onboarding.shared_with_site';
    private static final String KEY_FOOTER_PROMOTION_TEXT = 'email.common.footer.promotion_text';
    private static final String KEY_FOOTER_PROMOTION_HEADING = 'email.common.footer.promotion_heading';
    private static final String KEY_FOOTER_SETTINGS_PART1 = 'email.adjust.your';
    private static final String KEY_FOOTER_SETTINGS_PART2 = 'email.notification.settings';
    private static final String KEY_FOOTER_SETTINGS_PART3 = 'email.in.key.with.app_name';
    private static final String KEY_ON = 'common.on';
    private static final String KEY_BY = 'email.common.by';
    private static final String KEY_AT = 'email.common.at_time';
    private Exception exceptionDetailsObj;
    private Map<Id, String> contentIdWithPublicUrlMap = new Map<Id, String>();

    public static Map<String,String> contentOnboardingPartMap = new Map<String,String>{  
        'baseEmailBody' => '<!doctype html><html><head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection">{20}<title>Email template</title></head><body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td><td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #{10}; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td><td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span> </td></tr></tbody> </table> </td></tr><tr> <td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;">{3}<br>{4}</h2> </td></tr><tr> <td class="content-block" style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;border-collapse: collapse;color: #333;font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 14px;mso-table-lspace: 0pt;mso-table-rspace: 0pt;padding-bottom: 0;padding-top: 0;text-align: left;vertical-align: top;"> <table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td class="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody>{8}</tbody> </table>{5}</td></tr></tbody> </table> </td></tr></tbody> </table> </td></tr></tbody> </table>{21}<div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;">{23}<a href="{9}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{24}</a>{25}. <br>{17}</td></tr><tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;">{18}<a href="http://simpplr.com" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">Simpplr</a>. </td></tr></tbody> </table> </div></div></td><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td></tr></tbody> </table></body></html>',
        'viewAllOnboardingButton' => '<table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <center> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; box-sizing: border-box; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px !important;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td><td align="center" class="btn-spacer" style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;border-collapse: collapse;color: #333;font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 14px;mso-table-lspace: 0pt;mso-table-rspace: 0pt;padding-bottom: 0;padding-top: 20px;text-align: left;vertical-align: top;width: 120px;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px;"> <tbody> <tr> <td class="btn-inner" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{1}; border-collapse: collapse; border-radius: 4px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top; width: 120px;"> <a href="{0}" target="_blank" style="-moz-box-sizing: border-box;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;background-color: #{1};border: solid 1px #1abc9c;border-color: #{1};border-radius: 5px;box-sizing: border-box;color: #ffffff;cursor: pointer;display: inline-block;font-size: 14px;font-weight: 400;margin: 0;padding: 5px 15px;text-decoration: none;width: 183px;">{2}</a> </td></tr></tbody> </table> </td><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td></tr></tbody> </table> </center> </td></tr></tbody></table>',
        'contentRow' => '<tr> <td class="newsletter-item expired-box" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 15px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr>{0}<td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody>{2}{3}{1}</tbody> </table> </td></tr></tbody> </table> </td></tr></tbody> </table> </td></tr></tbody> </table> </td></tr>',
        'eventThumbnail' => '<td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{3}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #fff; border: 1px solid #e6e6e6; border-collapse: separate; border-radius: 2px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-decoration: none; width: 100%;"> <tbody> <tr> <td align="center" valign="top" class="CalendarMonth" style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;background-color: #{13};border-collapse: collapse;color: #fff;font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 16px;font-weight: normal;mso-table-lspace: 0pt;mso-table-rspace: 0pt;padding: 5px 0;text-align: center;text-transform: uppercase;vertical-align: top;"> <a href="{3}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #fff; text-decoration: none;">{14}</a> </td></tr><tr> <td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;border-collapse: collapse;color: #999;font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 60px;font-weight: 300;mso-table-lspace: 0pt;mso-table-rspace: 0pt;opacity: 0.6;padding: 4px 0 3px;text-align: center;vertical-align: top;"> <a href="{3}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; text-decoration: none;">{15}</a> </td></tr></tbody> </table> </a></td>',
        'thumbnail' => '<td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{3}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="{17}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td></tr></tbody> </table> </a></td>',
        'eventDateTime' => '<tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 12px; line-height: 21px; margin: 0;">{12}</p></td></tr>',
        'contentSiteNameNDate' => '<tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 12px; line-height: 21px; margin: 0;">{8}<a href="{6}" class="u-brandText" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{13}; text-decoration: none;">{5}</a> &nbsp;{9}&nbsp;{16} </p></td></tr>',
        'contentAuthorNameNDate' => '<tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 12px; line-height: 21px; margin: 0;">{10}<a href="{6}" class="u-brandText" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{13}; text-decoration: none;"> &nbsp;{11}</a>&nbsp;{9}&nbsp;{16} </p></td></tr>',
        'siteOnboarding' => '<tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 12px; line-height: 21px; margin: 0;">{4}<a href="{6}" class="u-brandText" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{13}; text-decoration: none;">{5}</a> </p></td></tr>',
        'orgOnboarding' => '<tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 12px; line-height: 21px; margin: 0;">{4}</p></td></tr>',
        'contentRowDivider' => ' <tr> <td height="15" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <div class="newsletter-divider-line" style="border-top: 1px solid #e5e5e5; height: 1px;"></div></td></tr>',
        'titleRow' => ' <tr> <td style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;border-collapse: collapse;color: #333;font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 14px;mso-table-lspace: 0pt;mso-table-rspace: 0pt;padding-bottom: 0;text-align: left;vertical-align: top;"> <a href="{3}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 14px; font-weight: 500; text-decoration: none; word-break: break-word;">{7}</a> </td></tr>'
    };
    
   
    public database.querylocator start(Database.BatchableContext bc) {
        Date within30Days = Date.today().addDays(-30);
        String query =  'SELECT Id, People__c, People__r.First_Name__c, People__r.User__c, People__r.Joining_Date__c, People__r.Full_Name__c, People__r.User__r.LanguageLocaleKey, People__r.User__r.timezonesidkey '+
                        'FROM People_Preference__c WHERE Is_Deleted__c = false AND People__r.Is_Deleted__c = false AND People__r.User__r.IsActive=true AND People__r.User__r.UserType = \'Standard\' ' + 
                        'AND People__r.Joining_Date__c >= :within30Days AND People__r.Joining_Date__c != TODAY AND Email_Onboarding_Frequency__c = \'Weekly\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {
        try {
            List<People_Preference__c> peoplePrefList = (List<People_Preference__c>) listOfsObject;
            Set<String> localeSet = new Set<String>{'en_US'};
            for(People_Preference__c peoplePref: peoplePrefList){
                localeSet.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey));
            }
            // Initialize Locale Context
            LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
            Map<Id, People_Preference__c> peoplePrefMap = new Map<Id, People_Preference__c>();
            for(People_Preference__c peoplePrefObj:peoplePrefList) {
                peoplePrefMap.put(peoplePrefObj.People__c, peoplePrefObj);
            }
            sendOnboardingEmail(peoplePrefMap);
        } catch(Exception ex) {
            exceptionDetailsObj =  ex;
            throw ex;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
        if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {} else {
            Utility.sendExceptionEmail('BatchContentOnboardingEmailDigest', exceptionDetailsObj);
        }
    }

    public class ContentWrapper implements Comparable {
        public ContentWrapper(Date onboardingAddedDate, Simpplr_Content__c content) {
            this.onboardingAddedDate = onboardingAddedDate;
            this.content = content;
        }
        public Date onboardingAddedDate {get; set;}
        public Simpplr_Content__c content {get; set;}
        public Integer compareTo(Object compareTo){
            ContentWrapper wrapperObj = (ContentWrapper) compareTo;
            if(onboardingAddedDate == null || wrapperObj.onboardingAddedDate == null){
                return 0;
            }
            if (onboardingAddedDate == wrapperObj.onboardingAddedDate) return 0;
            if (onboardingAddedDate > wrapperObj.onboardingAddedDate) return -1;
            return 1;
        }
    }

    private void sendOnboardingEmail(Map<Id, People_Preference__c> peoplePrefMap) {
        List<People_Preference__c> peoplePrefList = peoplePrefMap.values();
        Set<Id> peopleIds = new Set<Id>();
        for(People_Preference__c peoplePrefObj:peoplePrefList) {
            peopleIds.add(peoplePrefObj.People__c);
        }
        List<Site_Role__c> siteRoleList = [SELECT Id, People__c, Site__c FROM Site_Role__c WHERE People__c IN :peopleIds AND Is_Deleted__c = false AND Site__r.Is_Deleted__c = false AND Site__r.Is_Active__c=true];
        Map<Id, Set<Id>> peopleSiteListMap = new Map<Id, Set<Id>>();
        Set<Id> siteIds = new Set<Id>();
        for(Site_Role__c role:siteRoleList) {
            Set<Id> temp = peopleSiteListMap.get(role.People__c);
            if(temp == null) {
                temp = new Set<Id>();
            }
            temp.add(role.Site__c);
            peopleSiteListMap.put(role.People__c, temp);
            siteIds.add(role.Site__c);
        }

        String orgOnboarding = ServiceConstants.CONTENT_STATUS_ORG_ONBOARDING;
        String siteOnboarding = ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING;
        List<String> onboardingStatus = new List<String> {orgOnboarding, ServiceConstants.CONTENT_STATUS_SITE_ONBOARDING};
        Map<Id, List<Simpplr_Content__c>> peopleContentMap = new Map<Id, List<Simpplr_Content__c>>();
        
        List<Content_Interaction__c> myReadDetails = [SELECT Id, Content__c, People__c FROM Content_Interaction__c WHERE People__c IN :peopleIds AND View_Count__c > 0 AND Content__r.Content_Onboarding_Status__c IN :onboardingStatus AND (Content__r.Site__c IN :siteIds OR (Content__r.Site__r.Site_Type__c = 'Public' AND Content__r.Content_Onboarding_Status__c =: orgOnboarding))];
        Map<Id, Set<Id>> userReadDetails = new Map<Id, Set<Id>>();
        for(Content_Interaction__c ci:myReadDetails) {
            Set<Id> contentIds = userReadDetails.get(ci.People__c);
            if(contentIds == null) {
                contentIds = new Set<Id>();
            }
            contentIds.add(ci.Content__c);
            userReadDetails.put(ci.People__c, contentIds);
        }

        List<Simpplr_Content__c> contentList = [SELECT Id, Content_Onboarding_Status__c, Title__c, Type__c, Site__c, Site__r.Name, Site__r.Site_Type__c, Site__r.Title_Content_Version__c,
                                                        Onboarding_Added_Date__c, Site__r.Landing_Page__c, Publish_Start_DateTime__c, Last_Edited_DateTime__c, Primary_Author__r.Full_Name__c, Event_Start_Datetime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c, Event_Is_All_Day__c,
                                                        (SELECT Id, Content_Version__c, Thumbnail_URL__c, Is_Title_Image__c, Title_Image_Type__c FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Is_Title_Image__c = true ORDER BY Title_Image_Type__c)
                                                FROM    Simpplr_Content__c 
                                                WHERE  ((Content_Onboarding_Status__c = :siteOnboarding AND Site__c IN :siteIds) 
                                                OR      (Content_Onboarding_Status__c = :orgOnboarding))
                                                AND     Is_Deleted__c = false 
                                                AND     Is_Published__c = true 
                                                ORDER BY Onboarding_Added_Date__c DESC];

        for(Id peopleId:peopleSiteListMap.keySet()) {
            siteIds = peopleSiteListMap.get(peopleId);
            Set<Id> contentIdsToExclude = userReadDetails.containsKey(peopleId) ? userReadDetails.get(peopleId) : new Set<Id>();
            
            Map<Id, List<Simpplr_Content__c>> siteContentMap = new Map<Id, List<Simpplr_Content__c>>();
            for(Simpplr_Content__c content:contentList) {
                if(!contentIdsToExclude.contains(content.Id)) {
                    List<Simpplr_Content__c> temp = siteContentMap.get(content.Site__c);
                    if(temp == null) {
                        temp = new List<Simpplr_Content__c>();
                    }
                    temp.add(content);
                    siteContentMap.put(content.Site__c, temp);
                    if(orgOnboarding.equals(content.Content_Onboarding_Status__c)) {
                        siteIds.add(content.Site__c);
                    }
                }
            }

            List<Simpplr_Content__c> peopleContentTempList = peopleContentMap.get(peopleId);
            if(peopleContentTempList == null) {
                peopleContentTempList = new List<Simpplr_Content__c>();
            }
            for(Id siteId:siteIds) {
                List<Simpplr_Content__c> siteContentList = siteContentMap.get(siteId);
                if(siteContentList == null) {
                    siteContentList = new List<Simpplr_Content__c>();
                }
                peopleContentTempList.addAll(siteContentList);
            }
            peopleContentMap.put(peopleId, peopleContentTempList);
        }
        List<Messaging.SingleEmailMessage> onboardingEmailList = new List<Messaging.SingleEmailMessage>();
        for(Id peopleId:peopleContentMap.keySet()) {
            List<Simpplr_Content__c> tempContentList = peopleContentMap.containsKey(peopleId) ? peopleContentMap.get(peopleId) : new List<Simpplr_Content__c>();
            List<ContentWrapper> cwList = new List<ContentWrapper>();
            for(Simpplr_Content__c contentRec:tempContentList) {
                cwList.add(new ContentWrapper(contentRec.Onboarding_Added_Date__c, contentRec));
            }
            cwList.sort();

            List<Simpplr_Content__c> unreadContentList = new List<Simpplr_Content__c>();
            for(ContentWrapper cw:cwList) {
                unreadContentList.add(cw.content);
            }

            if(unreadContentList.size() > 0) {
                People_Preference__c peoplePrefObj = peoplePrefMap.get(peopleId);
                String languagelocalekey = Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.People__r.User__r.Languagelocalekey);
                
                Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                singleMail.setTargetObjectId(peoplePrefObj.People__r.User__c);
                singleMail.setSubject(LocaleContext.getLabel(languagelocalekey, KEY_EMAIL_ONBOARDING_SUBJECT ).replace('{{appName}}', SimpplrContext.applicationName));
                if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
                    singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
                }
                String emailBody = getOnboardingHTMLEmailBody(peoplePrefObj, unreadContentList, languagelocalekey);
                singleMail.setHtmlBody(SimpplrContext.DeeplinkingEnabled ? EmailUtility.deeplinkedMailBody(emailBody) : emailBody);
                singleMail.setCharset('UTF-8');
                singleMail.setUseSignature(false);
                singleMail.setSaveAsActivity(false);
                onboardingEmailList.add(singleMail);
            }
        }
        
        if(onboardingEmailList.size() > 0) {
            Messaging.sendEmail(OnboardingEmailList);
        }
    }

    private String getOnboardingHTMLEmailBody(People_Preference__c peoplePrefObj, List<Simpplr_Content__c> unreadContentList, String localeKey) {
        NotificationHelper.BrandingInfo brandingInfo = EmailUtility.getBrandingInfo4People(peoplePrefObj.People__r);
        String logoUrl = brandingInfo.logo_url;
        String targetPeopleId = peoplePrefObj.People__c;
        List<String> baseEmailBodyList = new List<String>();
        String userName = peoplePrefObj.People__r.Full_Name__c;
        if(String.isNotBlank(peoplePrefObj.People__r.First_Name__c)){
            userName = peoplePrefObj.People__r.First_Name__c;
        }

        baseEmailBodyList.add('' +SimpplrContext.salesforceBaseUrl  + Page.app.getUrl()); // 0-repeated with 11th
        baseEmailBodyList.add(logoUrl); // 1
        baseEmailBodyList.add(EmailUtility.getFormattedDate(DateTime.now(), peoplePrefObj.People__r.User__r.Timezonesidkey));//2
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_HI).replace('{{firstName}}', userName)); //{3}
        if(unreadContentList.size() == 1) {
            baseEmailBodyList.add(LocaleContext.getLabel(localeKey,KEY_EMAIL_SUMMARY_ONBOARDING_INTRO_SINGULAR).replace('{{count}}', String.valueOf(unreadContentList.size())).replace('{{appName}}', SimpplrContext.applicationName)); //4
        } else {
            baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_SUMMARY_ONBOARDING_INTRO_PLURAL).replace('{{count}}', String.valueOf(unreadContentList.size())).replace('{{appName}}', SimpplrContext.applicationName)); //4
        }
        String viewAllBtmBody = getViewButtonBlock(brandingInfo, localeKey);//TODO: need to add in baseEmailBodyList
        baseEmailBodyList.add(viewAllBtmBody); // 5 View all button
        baseEmailBodyList.add('https://www.simpplr.com'); //6
        baseEmailBodyList.add(SimpplrContext.applicationName); //7
        
        getContentIdNPublicUrlMap(unreadContentList);
        // *******************Content ROW************************************
        String allContentRows = '';
        String preString = ' <table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody>';
        String postString = ' </tbody> </table>';
        Integer contentCount = 0;
        for (Simpplr_Content__c contentObj:unreadContentList) {
            String contentBodyBlock = getContentBodyBlock(contentObj, localeKey, peoplePrefObj, brandingInfo.general_primaryColor);
            allContentRows += contentBodyBlock;
            contentCount++;
            if(contentCount == 5){
                break;
            }
        }
       
        allContentRows = preString + allContentRows  + postString  ;
        // *******************Content Row ends ************************************

        baseEmailBodyList.add(allContentRows); // 8 for content rows. 
        //Setting page URL
        baseEmailBodyList.add('' + SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?userId=' + peoplePrefObj.People__r.User__c +'&pageToRedirect='+Pages.MySettingsEmail+'&origin=tse');//9
        // header background // 10
        if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
            baseEmailBodyList.add('000000');
        } else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
            baseEmailBodyList.add(brandingInfo.general_primaryColor);
        } else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
            baseEmailBodyList.add('ffffff');
        } else {
            baseEmailBodyList.add(brandingInfo.header_backgroundColor);
        }
        
        // footer background //11
        baseEmailBodyList.add('f8f8f8');
        baseEmailBodyList.add(brandingInfo.Header_IconColor); // header text color Applicable for date only. // 12
        baseEmailBodyList.add('333333'); // footer text color Applicable for footer text only. // 13
        baseEmailBodyList.add(brandingInfo.General_PrimaryColor); // Link color Applicable for all links in content part. // 14

        baseEmailBodyList.add('');// 15 
        //16 Footer promotion text
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_FOOTER_PROMOTION_TEXT ).replace('{{appName}}',SimpplrContext.applicationName)); 
        //17 copyright 
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, EmailConstants.KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
        //18 powered by 
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, EmailConstants.KEY_POWERED_BY)+' ');
        //19 APPName 
        baseEmailBodyList.add(SimpplrContext.applicationName);
        // 20 mediaCSS
        baseEmailBodyList.add('<style>@media all {    .ExternalClass {      width: 100%;    }    .ExternalClass,    .ExternalClass p,    .ExternalClass span,    .ExternalClass font,    .ExternalClass td,    .ExternalClass div {      line-height: 100%;    }    .apple-link a {      color: inherit !important;      font-family: inherit !important;      font-size: inherit !important;      font-weight: inherit !important;      line-height: inherit !important;      text-decoration: none !important;    }  }@media only screen and (max-width:620px) {    table[class=body] .wrapper,    table[class=body] .header,    table[class=body] .article {      padding: 10px !important;    }    table[class=body] .content {      padding: 0 !important;    }    table[class=body] .container {      padding: 0 !important;      width: 100% !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .btn a {      width: 100% !important;    }    table[class=body] .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }    td[class="mobile-hide"] {      display: none;    }    .mobile-hide {      display: none;    }    .newsletter-item .media {      width: 100px !important;    }    .newsletter-item .media .Calendar .CalendarMonth {      font-size: 14px !important;    }    .newsletter-item .media .Calendar .CalendarDay {      font-size: 33px !important;    }    .newsletter-item--showCase .media {      width: 100% !important;    }    .newsletter-item--showCase .media .Calendar .CalendarMonth {      font-size: 20px !important;    }    .newsletter-item--showCase .media .Calendar .CalendarDay {      font-size: 40px !important;    }    .wrapper,    .header,    .article {      padding: 10px !important;    }    .content {      padding: 0 !important;    }    .container {      padding: 0 !important;      width: 100% !important;    }    .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    .btn table {      width: 100% !important;    }    .btn a {      width: 100% !important;    }    .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }  }    a[x-apple-data-detectors] {        color: inherit !important;        text-decoration: none !important;        font-size: inherit !important;        font-family: inherit !important;        font-weight: inherit !important;        line-height: inherit !important;    }</style>');
        // 21 mobile promotion footer
        baseEmailBodyList.add(EmailUtility.getMobilePromotionFooterDiv(localeKey, peoplePrefObj.People__c));
        //22  promotion heading 
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_FOOTER_PROMOTION_HEADING).replace('{{appName}}',SimpplrContext.applicationName));
        //23  footer setting part1
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_FOOTER_SETTINGS_PART1)+' ');
        //24  footer setting part2
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_FOOTER_SETTINGS_PART2)+' ');
        //25  footer setting part3
        baseEmailBodyList.add(LocaleContext.getLabel(localeKey, KEY_FOOTER_SETTINGS_PART3).replace('{{appName}}',SimpplrContext.applicationName));
        return EmailUtility.format(contentOnboardingPartMap.get('baseEmailBody'), baseEmailBodyList);
    }

    private String getViewButtonBlock( NotificationHelper.BrandingInfo brandingInfo, String localeKey) {
        List<String> viewAllOnboardingButtonPartList = new List<String>();
        String contentLink = SimpplrContext.salesForceBaseUrl + Page.PageRedirector.getUrl() + '?pageToRedirect='+Pages.ViewAllContentOnboarding+'&sortBy=dateadded&referralSource=email'; //TODO: need to add link all onboarding contents
        viewAllOnboardingButtonPartList.add(contentLink); //0
        viewAllOnboardingButtonPartList.add(brandingInfo.general_primaryColor); //1
        viewAllOnboardingButtonPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_VIEW_ALL_ONBOARDING_BTN)); //2
        return EmailUtility.format(contentOnboardingPartMap.get('viewAllOnboardingButton'), viewAllOnboardingButtonPartList);
        
    }

    private String getContentBodyBlock(Simpplr_Content__c contentObj,  String localeKey, People_Preference__c peoplePrefObj, String generalPrimaryColor) {
        String contentBodyBlock = '';
        List<String> contentPartList = new List<String>();

        contentPartList.add(' ');//8.0
        contentPartList.add(' ');//8.1
        contentPartList.add(' ');//8.2
        // 8.3: content URL
        contentPartList.add('' +SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?siteId=' + contentObj.Site__c +'&contentId='+contentObj.Id+'&pageToRedirect=ContentDetailPage'+'&origin=tse&contentType='+contentObj.Type__c.tolowercase()+'&utm_source=onboarding_summary_email'); 
        if('orgOnboarding'.equalsIgnoreCase(contentObj.Content_Onboarding_Status__c)) {
            contentPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_ONBOARDING_SHARED_WITH_APP).replace('{{appName}}',SimpplrContext.applicationName)); // 8.4: 
        } else if('siteOnboarding'.equalsIgnoreCase(contentObj.Content_Onboarding_Status__c)){
            contentPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_ONBOARDING_SHARED_WITH_SITE));// 8.4: 
        }

        if (String.isNotBlank(contentObj.Site__c)) {
            contentPartList.add(contentObj.Site__r.name + ' '); // 8.5 Site name
            contentPartList.add(PageContext.getPageURL(Pages.app) +'?u=/site/' + contentObj.Site__c + '/' + contentObj.Site__r.Landing_Page__c); //8.6 Site url 
        } else {
            contentPartList.add(' ');//8.5
            contentPartList.add(' ');//8.6
        }
        // 8.7: Content Title 
        contentPartList.add(contentObj.Title__c.length()>100 ? contentObj.Title__c.substring(0,97)+'...' : contentObj.Title__c);
        
        contentPartList.add(LocaleContext.getLabel(localeKey, EmailConstants.KEY_LABEL_IN) + ' ');// 8.8: In keyword
        contentPartList.add(LocaleContext.getLabel(localeKey, KEY_ON) + ' ');// 8.9: on Keyword
        contentPartList.add(LocaleContext.getLabel(localeKey, KEY_BY)+ ' ');// 8.10  By keyword
        contentPartList.add(contentObj.Primary_Author__r.Full_Name__c +' '); // 8.11 Author name

        String eventMonth = '';
        String eventDay = '';

        if('Event'.equalsIgnoreCase(contentObj.Type__c)){
            String dayForEvent = '';
            String startTime = LocaleContext.getLocalisedDateAs12HourFormatTime(contentObj.Event_Start_DateTime__c, localeKey, contentObj.Event_TimezoneSidKey__c);
            String startDay = LocaleContext.getLocalisedDateAsEEEEMMMDYYYY(contentObj.Event_Start_Datetime__c, localeKey, contentObj.Event_TimezoneSidKey__c);
            eventMonth = LocaleContext.getLocalisedMonth(contentObj.Event_Start_Datetime__c, localeKey, contentObj.Event_TimezoneSidKey__c);
            eventDay = contentObj.Event_Start_Datetime__c.format('dd', contentObj.Event_TimezoneSidKey__c);

            if('12:00 AM'.equalsIgnoreCase(contentObj.Event_Start_Datetime__c.format('h:mm a')) && contentObj.Event_Start_Datetime__c.addDays(1) == contentObj.Event_End_DateTime__c){
                dayForEvent = startDay;
            }else if(contentObj.Event_Start_DateTime__c.isSameDay(contentObj.Event_End_DateTime__c)){
                dayForEvent = startDay;
            }
            //8.12 event date time
            contentPartList.add(dayForEvent+' '+LocaleContext.getLabel(localeKey, KEY_AT)+' '+startDay+' '+startTime);
        }else{
            //8.12
            contentPartList.add(' ');
        }
        //8.13
        contentPartList.add(generalPrimaryColor); // generalPrimaryColor
        contentPartList.add(eventMonth); //8.14 Event month
        contentPartList.add(eventDay); // 8.15 Event day
        //8.16:Created date time
        contentPartList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(contentObj.Publish_Start_DateTime__c, localeKey, peoplePrefObj.People__r.User__r.timezonesidkey));
        

        //8.17 : 
        if(String.isNotBlank(contentIdWithPublicUrlMap.get(contentObj.id))) {
            
            contentPartList.add(contentIdWithPublicUrlMap.get(contentObj.id));
        } else {
            contentPartList.add(EmailConstants.pageDefaultIconSquareIcon);
        }
        
        List<String> contentHTMLPartList = new List<String>();
        if ('Event'.equalsIgnoreCase(contentObj.Type__c)){

                contentHTMLPartList.add(contentOnboardingPartMap.get('eventThumbnail')); //8.0 :event date with month name
                contentHTMLPartList.add(contentOnboardingPartMap.get('eventDateTime')); //8.1 :event date with day  name
        } else {
                contentHTMLPartList.add(contentOnboardingPartMap.get('thumbnail')); //8.0 :thumbnail
            
                if('orgOnboarding'.equalsIgnoreCase(contentObj.Content_Onboarding_Status__c)) {
                    contentHTMLPartList.add(contentOnboardingPartMap.get('contentSiteNameNDate')); // 8.1: site name with date
                } else {
                    contentHTMLPartList.add(contentOnboardingPartMap.get('contentAuthorNameNDate'));// 8.1: author name with date
                } 
        }

        if('orgOnboarding'.equalsIgnoreCase(contentObj.Content_Onboarding_Status__c)) {
            
            contentHTMLPartList.add(contentOnboardingPartMap.get('orgOnboarding')); // 8.2: orgOnboarding  
        } else {
            contentHTMLPartList.add(contentOnboardingPartMap.get('siteOnboarding'));// 8.2: siteOnboarding 
        }
        contentHTMLPartList.add(contentOnboardingPartMap.get('titleRow'));//8.3 titleRow 
        String contentModifyRow = EmailUtility.format( contentOnboardingPartMap.get('contentRow'), contentHTMLPartList);


        return EmailUtility.format(contentOnboardingPartMap.get('contentRowDivider') + contentModifyRow, contentPartList);
    }

    private void getContentIdNPublicUrlMap(List<Simpplr_Content__c> contentList) {
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



}