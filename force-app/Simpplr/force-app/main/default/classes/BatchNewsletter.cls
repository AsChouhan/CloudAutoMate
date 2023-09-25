public without sharing class BatchNewsletter implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
	
		public static Map<String,String> partMap = new Map<String,String> {
			'BaseEmailwithheaderfooter'=> '<!doctype html> <html> <head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection"> {0} <title>Event</title> </head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #{14}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span> </td> </tr> </table> </td> </tr> {3} </table> <div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="10" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top;"> <div class="footer-promotion-heading" style="color: #444; font-size: 16px; font-weight: bold; line-height: 18px;">{4}</div> <br> <div class="footer-promotion-text" style="color: #444; font-size: 13px; line-height: 15px; margin: 0 auto; max-width: 390px;"> {5} </div> <br> <div class="footer-promotion-box" style="border-bottom: 1px solid #e5e5e5; margin: 0 auto; max-width: 400px; padding-bottom: 20px;"> <a class="footer-promotion-link" href="{6}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; display: inline-block; font-size: 12px; text-align: center; text-decoration: underline; vertical-align: top;"> <img alt="alt" class="footer-promotion-badge" src="{7}" width="108" height="32" style="-ms-interpolation-mode: bicubic; border: none; display: inline-block; height: 32px; max-width: 100%; outline: none; text-decoration: none; vertical-align: top; width: 108px;"> </a> <a href="{8}" class="footer-promotion-link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; display: inline-block; font-size: 12px; text-align: center; text-decoration: underline; vertical-align: top;"> <img alt="alt" class="footer-promotion-badge" src="{9}" width="108" height="32" style="-ms-interpolation-mode: bicubic; border: none; display: inline-block; height: 32px; max-width: 100%; outline: none; text-decoration: none; vertical-align: top; width: 108px;"> </a> </div> </td> </tr> </table> </div> <div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> <a href="{10}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{11}</a> <br>{12} </td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {13} <a href="http://simpplr.com" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">Simpplr</a>. </td> </tr> <tr> <td><img src={15}{16} width="1" height="1" alt="" class="CToWUd"></td> </tr> </table> </div> </div> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </body></html>',
			'BaseEmailBody' => '<html> <head><meta charset="utf-8"><meta content="width=device-width, initial-scale=1.0" name="viewport"><meta content="text/html" http-equiv="Content-Type"><meta content="telephone=no" name="format-detection">{0}<title>Newsletter inside new frame</title></head><body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"><div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"><table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{8}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"></td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"><span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span></td></tr></table></td></tr>{3}</table><div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;">{6}</td> </tr><tr><td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;">{7}<a href="http://simpplr.com" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;"> Simpplr</a>.</td><td><img src="{9}{10}" width="1" height="1" alt="Simpplr"/></td></tr></table></div></div> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td></tr></table></body></html>',
			'BannerImage' => ' <tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 12px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><img style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;" src="{0}" width="568"></div></td></tr></table></td></tr>',
			'IntroBody' => ' <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><td class="Content" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 20px; text-align: left; vertical-align: top;">{0}</td></table></td></tr>',
			'ContentBody' => '<tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; max-width: 600px !important; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%">{0}</table></td></tr>',
			'EmailBodyWithBannerIntroANdContent' => '<tr><td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;">{0}{1}{2}</table></td></tr>',
			/*{0} LogoLink*/
			/*{1} LogoImage*/  
			/*{2} EmailDate*/
			/*{3} UserName*/
			/*{4} AppName*/
			/*{5} Introduction*/
			/*{6} EMAIL User Name*/
			/*{7} Copywrite*/
			/*{8} App Link*/
			/*{9} App Name*/
			/*{10} ContentRow*/
			'headingTypeRow' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="Heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 21px; font-weight: 400; line-height: 1.4; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top; word-break: break-word;">{0}</td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'divider' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><hr class="Divider" style="Margin: 20px 0; background: #e6e6e6; border: 0; border-bottom: 1px solid #f6f6f6; height: 1px; margin-bottom: 20px;"></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'richText' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="Content" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 20px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0; margin-bottom: 8px;">{0}</p></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			/*
				0 => Image
				1 => heading
				2 => description
				3 => site name
				4 => Last edited date time(Feb 18, 2018)
				5 => owner name
				6 => start date(EEEE d MMM, YYYY)
				7 => Month(MMM)
				8 => date(d)
				9 => weekday
				10 => end date (EEEE d MMM, YYYY)
				11 => viewURL 
				12 => Site URL
				13 => Owner Profile URL
	
				Formula for calculating key of the content row: (IsShowcase + _ + contentType + _ + Image)
			 */
			'page' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody><tr><td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td> </tr></tbody></table></a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span> </td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{9}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{3}</a> {4}</p></td></tr></table> </td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'page_without_image' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody><tr><td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="' + EmailConstants.pageDefaultIconSquareIcon + '" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td> </tr></tbody></table></a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span> </td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{9}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{3}</a> {4}</p></td></tr></table> </td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'event_single_day' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody><tr><td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td></tr></tbody></table></a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{14}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{15}</span></div></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'event_single_day_without_image' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #fff; border: 1px solid #e6e6e6; border-collapse: separate; border-radius: 2px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-decoration: none; width: 100%;"><tr><td align="center" valign="top" class="CalendarMonth" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{20}; border-collapse: collapse; color: #fff; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: normal; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px 0; text-align: center; text-transform: uppercase; vertical-align: top;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #fff; text-decoration: none;">{16}</a></td></tr><tr><td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 60px; font-weight: 100; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: center; vertical-align: top;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; text-decoration: none;">{17}</a></td></tr></table></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{14}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{15}</span></div></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'event_multi_day' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody><tr><td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td></tr></tbody></table></a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{6}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{7}</span></div></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'event_multi_day_without_image' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #fff; border: 1px solid #e6e6e6; border-collapse: separate; border-radius: 2px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-decoration: none; width: 100%;"><tr><td align="center" valign="top" class="CalendarMonth" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{20}; border-collapse: collapse; color: #fff; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: normal; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px 0; text-align: center; text-transform: uppercase; vertical-align: top;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #fff; text-decoration: none;">{16}</a></td></tr><tr><td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 60px; font-weight: 100; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: center; vertical-align: top;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; text-decoration: none;">{17}</a></td></tr></table></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{6}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{7}</span></div></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'album' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"><tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td></tr></tbody></table></a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span> </td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{9}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{3}</a> {4} </p></td></tr></table></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'blogpost' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr><td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="{0}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td></tr></tbody></table></a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td> </tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13} <a href="{10}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{5}</a> {19}{4}</p></td></tr></table></td></tr></table> </td></tr></table></td></tr></table></td></tr>',
			'blogpost_without_image' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td class="media" align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"><table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr><td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img alt="alt" height="125" src="'+EmailConstants.blogDefaultIconSquareIcon+'" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"></td></tr></tbody></table></a></td><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td> </tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13} <a href="{10}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{5}</a> {19}{4}</p></td></tr></table></td></tr></table> </td></tr></table></td></tr></table></td></tr>',
			'showcase_page' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"><img alt="alt" src="{0}" width="568" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;"></a> </div></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr> </table> </td></tr> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{9}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{3}</a> {4}</p></td></tr></table></td> </tr></table></td></tr>',
			'showcase_page_without_image' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"><img alt="alt" src="' + EmailConstants.pageDefaultIconWidescreenIcon + '" width="568" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;"></a> </div></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr> </table> </td></tr> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{9}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{3}</a> {4}</p></td></tr></table></td> </tr></table></td></tr>',
			'showcase_event_single_day' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"><img alt="alt" src="{0}" width="568" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;"></a></div></td> </tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{14}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{6}</span> </div></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr> </table> </td> </tr></table> </td></tr> </table> </td></tr>',
			'showcase_event_single_day_without_image' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"> <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"></a><table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar--showcase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{20}; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td align="center" valign="bottom" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 16px; text-align: left; vertical-align: top;" height="285"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: white; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 20px; font-weight: 300; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: left; vertical-align: top;">{18} </td></tr><tr><td align="center" valign="top" class="CalendarDate" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: white; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 40px; font-weight: 100; line-height: 1.2; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">{17} {16}</td></tr></table></td></tr></table></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{14}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{6}</span> </div></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'showcase_event_multi_day' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"><img alt="alt" src="{0}" width="568" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;"></a></div></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a> <div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{6}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{7}</span></div></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr></table></td></tr> </table></td></tr></table> </td> </tr>',
			'showcase_event_multi_day_without_image' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"></a><table border="0" cellpadding="0" cellspacing="0" width="125" class="Calendar--showcase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{20}; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td align="center" valign="bottom" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 16px; text-align: left; vertical-align: top;" height="285"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td align="center" valign="top" class="CalendarDay" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: white; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 20px; font-weight: 300; mso-table-lspace: 0pt; mso-table-rspace: 0pt; opacity: 0.6; padding: 9px 0; text-align: left; vertical-align: top;">{18}</td> </tr><tr><td align="center" valign="top" class="CalendarDate" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: white; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 40px; font-weight: 100; line-height: 1.2; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">{17} {16}</td></tr></table></td></tr></table></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{6}</span></div><div style="padding-top: 6px; line-height: 0;"><span style="color: #999; font-size: 12px; line-height: 1;">{7}</span></div></td> </tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr></table></td> </tr></table></td></tr></table></td></tr>',
			'showcase_album' => '<tr><td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"><img alt="alt" src="{0}" width="568" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;"></a></div></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td></tr><tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"> <p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p> </td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{9}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{3}</a> {4}</p></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'showcase_blogpost' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"><img alt="alt" src="{0}" width="568" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;"></a></div></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td> </tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{10}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{5}</a> {19} {4}</p></td></tr></table></td></tr></table></td></tr></table></td></tr>',
			'showcase_blogpost_without_image' => '<tr><td class="newsletter-item newsletter-item--showCase" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;" valign="top"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; text-decoration: none;"><img alt="alt" src="'+EmailConstants.blogDefaultIconWidescreenIcon+'" width="568" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none; width: 100%;"></a></div></td></tr><tr><td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;">{12} {11}</span></td> </tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"><a href="{8}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;">{1}</a></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 4px; text-align: left; vertical-align: top;"><p style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; font-size: 14px; line-height: 21px; margin: 0;">{2}</p></td></tr><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 14px; line-height: 21px; margin: 0;">{13}<a href="{10}" class="Link" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{20}; text-decoration: none;">{5}</a> {19} {4}</p></td></tr></table></td></tr></table></td></tr></table></td></tr>' 

	};

	public static final String KEY_LABEL_PAGE = 'email.common.label.page';
	public static final String KEY_LABEL_ALBUM = 'email.common.label.album';
	public static final String KEY_LABEL_EVENT = 'email.common.label.event';
	public static final String KEY_LABEL_BLOGPOST = 'email.common.blog_post';
	public static final String KEY_LABEL_MUSTREAD = 'email.common.stamp.must_read';
	public static final String KEY_LABEL_IN = 'email.common.newsletter.in';	
	public static final String KEY_LABEL_BY = 'email.common.by';	
	public static final string KEY_LABEL_ON = 'email.common.on.digest';
	public static final String KEY_LABEL_ALL_DAY = 'email.common.all_day.digest';
	public static final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';
	public static final String KEY_COPYRIGHT = 'email.common.footer.copyright';
	public static final String KEY_POWERED_BY = 'email.common.footer.powered_by';
	public static final String KEY_PREVIEW = 'email.common.newsletter.preview';
	public static final String KEY_FOOTER_PROMOTION_HEADING = 'email.common.footer.promotion_heading';
	public static final String KEY_FOOTER_PROMOTION_TEXT = 'email.common.footer.promotion_text';
	public static final String KEY_LABEL_STARTS = 'common.starts';
	public static final String KEY_LABEL_ENDS = 'common.ends';
	public static final String KEY_LABEL_STARTS_ENDS = 'common.starts_ends';
	public String batchType;
    public string query;	
    public String applicationName;
    public string packageName;
    public Mailer__c mailerObj;
    public Boolean canSendMail;
    public Boolean isCalledFromScheduler;
	public Datetime newsletterScheduledDate;
	public Boolean simpplrMobileNotificationAllowed;
	public String currentPeopleId = UserContext.peopleId;
	public String groupId = '';
	public String mainBody = '';
	public String audienceId = '';
	public App_Config__c appConfig;
	private List<String> allowedFeaturesInAppList;
	private Set<String>  allowedFeaturesInAppSet;
	private Map<String, String> datesVsFormatMap = new Map<String, String>{
    					'LastEditedDateTime' => 'MMM d, yyyy',
    					'EventStartDatetime' => 'EEEE d MMM, YYYY',
    					'EventStartMonth' => 'MMM',
    					'EventStartDate' => 'd',
    					'EventStartWeek' => 'EEEE',
						'EventEndDateTime' => 'EEEE d MMM, YYYY'};					
 
    public BatchNewsletter(Mailer__c newsletterRec, DateTime newsletterScheduledDate, Boolean isPreview, Boolean isCalledFromScheduler) {
    	String appConfigQuery = 'Select Simpplr_Mobile_Notification_Allowed__c,Newsletter_Open_Tracker_URL__c,Branding_JSON__c,Branding_Logo__c,App_Name__c,Package_Name__c from App_Config__c Limit 1';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

		allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').toLowerCase().split(',');
		allowedFeaturesInAppSet = new  Set<String>(allowedFeaturesInAppList);
		mailerObj = newsletterRec;
    	simpplrMobileNotificationAllowed = appConfig.Simpplr_Mobile_Notification_Allowed__c;
 
        query = 'Select First_Name__c,Last_Name__c,User__r.languageLocaleKey,User__r.timezonesidkey,Full_Name__c,User__r.UserName,User_Hash__c,Segment__c,Segment__r.Branding_Logo__c,Segment__r.Branding_JSON__c from People__c where User__r.UserType=\'Standard\' AND User__r.isActive = true';
        packageName = appConfig.Package_Name__c;
        if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
    		query = query + ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName)';
    	}
    	if(isPreview){
    		query = query + ' and Id=:currentPeopleId';
    	}
    	if(isPreview==false && newsletterRec != null){
			if(String.isNotBlank(newsletterRec.Site__c)){
				groupId = newsletterRec.site__r.Chatter_Group_Id__c;
				if(newsletterRec.Members_Type__c == 'site_members') {
					query = query + ' AND Id in (Select People__c FROM Site_Role__c WHERE Is_Member__c = true AND Is_Deleted__c = false  AND Site__r.Chatter_Group_Id__c=:groupId)';
				} else {
					query = query + ' and User__c IN (Select memberId from CollaborationGroupMember where CollaborationGroupId=:groupId)';
				}
			} else if(String.isNotBlank(newsletterRec.Audience__c)){
				audienceId = newsletterRec.Audience__c;
				query = query + ' and Id IN (Select people__c from Audience_Member__c where Audience__c=:audienceId )';
			}		
    	}
    	canSendMail = true;
    	this.isCalledFromScheduler = isCalledFromScheduler;
    	this.newsletterScheduledDate = newsletterScheduledDate;
        applicationName = appConfig.App_Name__c;
    }
    
    public BatchNewsletter(String batchType) {
    	this.batchType = batchType;
    	
	}
    
	public static void initLangKeyValueMap(List<People__c> peopleList) {
        Set<String> localeSet = new Set<String>();
		for(People__c peopleObj : peopleList){
			localeSet.add(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey));
		}
		LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
    	if('sendAnalyticsDataToAWS'.equalsIgnoreCase(batchType)) {
    		query = 'Select id, Actual_Recipient_Count__c, From_Address_Id__c, From_Address__c, Name__c, ' +
    				'Open_Count__c, Site__c, Total_Click_Count__c, Unique_Click_Count__c, Sent_Time__c ' + 
    				'From Mailer__c where Status__c=\'Sent\' and is_deleted__c = false and (Sent_Time__c = LAST_N_DAYS:365 or Sent_Time__c=today) ';
		
		}

		return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
    	if('sendAnalyticsDataToAWS'.equalsIgnoreCase(batchType)) {
    		PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
			analyticsHandler.sendMailerListToAWS(listOfsObject);

    	} else {
    		List<People__c> peopleList = (List<People__c >)listOfsObject;
			initLangKeyValueMap(peopleList);
			canSendMail = checkIfMailCanBeSent(mailerObj);

			if(canSendMail){
				sendNewsletter(peopleList, false,null);
			} else {
				markNewsletteronHold(mailerObj);
			}
    	}
	}

	private void markNewsletteronHold(Mailer__c mailerObj) {
		
		mailerObj.Status__c = 'On Hold';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(mailerObj,new List<Schema.SObjectField>{Mailer__c.Status__c});
	}
    
    private Boolean checkIfMailCanBeSent(Mailer__c mailerObj){
    	Boolean canSendNewsletterMail = true;
    	if(String.isNotBlank(mailerObj.site__c) && (mailerObj.Site__r.Is_Active__c == false || mailerObj.Site__r.Show_In_Simpplr__c == false)){
    		canSendNewsletterMail = false;
    	}else{
			List<Mailer_Details__c> listOfMailerDetail = getMailerDetails(mailerObj.id);

	    	for(Mailer_Details__c mailerDetail : listOfMailerDetail){
	    		if('Content'.equalsIgnoreCase(mailerDetail.Type__c)){
		    		if(mailerDetail.Content__r.Is_Unpublished__c || mailerDetail.Content__r.Is_Deleted__c
		    			|| ((mailerDetail.Content__r.Type__c !='BlogPost') && (mailerDetail.Content__r.Site__r.Is_Active__c == false || mailerDetail.Content__r.Site__r.Show_In_Simpplr__c == false || mailerDetail.Content__r.Site__r.Is_Deleted__c == true)) || mailerDetail.Content__r.Activated_By_Feature__c == false || !allowedFeaturesInAppSet.contains(mailerDetail.Content__r.Type__c.toLowerCase())){
							canSendNewsletterMail = false;
		    		}
	    		}
	    	}
		}
		
    	return canSendNewsletterMail;
    }
    
    public void sendPreview(String toEmailId){
		List<People__c> peopleList = (List<People__c>)Database.query(query);
    	initLangKeyValueMap(peopleList);
    	if(peopleList==null || peopleList.size()==0){
    		throw new SimpplrException('People record not found for user.');
    	}
    	
    	sendNewsletter(peopleList, true,toEmailId);
    	finish(null);
    }
    
     private void sendNewsletter(List<People__c> peopleList, Boolean isPreview,String toEmailId){
    	List<Messaging.SingleEmailMessage> newsletterEmailList = new List<Messaging.SingleEmailMessage>();
    	List<Mailer_Details__c> listOfMailerDetail = getMailerDetails(mailerObj.id);
        Map<ID, Boolean> contentIdWithShowcaseMap = new Map<ID, Boolean>();
        Map<ID, Boolean> contentIdWithMustReadMap = new Map<ID, Boolean>();
        
        for(Mailer_Details__c detailObj : listOfMailerDetail){
            if(String.isNotBlank(detailObj.Content__c)){
                if(!contentIdWithShowcaseMap.containsKey(detailObj.Content__c)){
                    contentIdWithShowcaseMap.put(detailObj.Content__c, detailObj.Is_Showcase__c);
                    contentIdWithMustReadMap.put(detailObj.Content__c, detailObj.content__r.Is_Must_Read__c);
                }
            }
            
        }

        Set<Id> contentIds = new Set<Id>();
        contentIds.addAll(contentIdWithShowcaseMap.keySet());
        List<Simpplr_Content__c> contentTempList = new List<Simpplr_Content__c>();
        String contentQuery = 'select id,Popularity_Score__c, Title__c, Type__c,Text_Intro__c, Site__c, Site__r.Name, Site__r.Site_Type__c, Publish_Start_DateTime__c, Last_Edited_DateTime__c, '+
                ' Event_Start_Datetime__c,Event_End_Datetime__c,Event_TimezoneSidKey__c,Event_Is_All_Day__c,Primary_Author__c,Primary_Author__r.Full_Name__c,Summary__c, Site__r.Chatter_Group_Id__c,Site__r.Show_In_Simpplr__c,Primary_Author__r.External_Photo_URL__c, createdDate, ' + 
				' Site__r.Title_Content_Version__c, ' +
                ' (SELECT Id,Simpplr_Content__c,title__c,Content_Version__c,Thumbnail_URL__c,Is_Title_Image__c,Title_Image_Type__c FROM File_Simpplr_Content__r ' + 
                '  WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c ),Is_Must_Read__c ' + 
                ' from Simpplr_Content__c where Id IN :contentIds';
        
        contentTempList.addAll((List<Simpplr_Content__c>)Database.query(contentQuery));
        
        Map<Id, String> contentIdNPublicUrlMap = getcontentIdNPublicUrlMap(contentTempList, 
                contentIdWithShowcaseMap);

    	for (People__c peopleObj : peopleList) {
            mainBody = getMainBody(mailerObj, isPreview, peopleObj, listOfMailerDetail, 
                    contentIdWithMustReadMap, contentIdNPublicUrlMap);
    		
    		String digestBody = getNewsletterBody(mailerObj,peopleObj);
			String subject = mailerObj.subject__c;
	        if(isPreview){
	        	subject = LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey),KEY_PREVIEW)+' : ' + subject;
	        }
	        
    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
    		if(String.isNotBlank(toEmailId)){
    			singleMail.setToAddresses(new List<String>{toEmailId});
    		}else{
    			singleMail.setTargetObjectId(peopleObj.User__c);
    		}
			
			singleMail.setSubject(subject);
			// singleMail.setReplyTo(ServiceConstants.EMAIL_NOTI_NOREPLY_ADDRESS);
			
			if(String.isNotBlank(mailerObj.From_Address_Id__c)){
				singleMail.setOrgWideEmailAddressId(mailerObj.From_Address_Id__c);
			} else if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
				singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
			}
			
			if(SimpplrContext.DeeplinkingEnabled) {
				digestBody = EmailUtility.deeplinkedMailBody(digestBody);
			}
			
			singleMail.setHtmlBody(digestBody);
			singleMail.setCharset('UTF-8');
			singleMail.setUseSignature(false);
			singleMail.setSaveAsActivity(false);
			newsletterEmailList.add(singleMail);
		}
        if(newsletterEmailList.size() > 0) {
        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(newsletterEmailList);
        }
    }
    
    private String getNewsletterBody(Mailer__c mailerRecord, People__c peopleObj) {
		String newsletterBody = '';
    
    	NotificationHelper.BrandingInfo brandingInfo = EmailUtility.getBrandingInfo4People(peopleObj);
	    
		List<String> baseEmailBodyList = new List<String>();
		// 0 banner image
		if(String.isNotBlank(mailerRecord.Banner_Url__c)){
			String bannerImage = partMap.get('BannerImage');
			String bannerImageHtml = String.format(bannerImage, new List<String>{mailerRecord.Banner_Url__c});
			
			baseEmailBodyList.add(bannerImageHtml);
		} else {
			baseEmailBodyList.add('');
		}
		//1 intro
		String mailerIntro = mailerRecord.Introduction_Inlined__c;
		if(String.isNotBlank(mailerIntro)){
			mailerIntro = mailerIntro.replace('#BRANDCOLOR#', '#' + brandingInfo.general_primaryColor);
			baseEmailBodyList.add(getIntroHTMLBody(partMap, mailerIntro)); 
		} else {
			baseEmailBodyList.add(''); 
		}
		//2 content body
		if(String.isNotBlank(mainBody)){
			mainBody = mainBody.replace('{20}', brandingInfo.general_primaryColor);
			String mainContentBody = String.format(partMap.get('ContentBody'),new String[]{mainBody});
			baseEmailBodyList.add(mainContentBody);
		}else{
			baseEmailBodyList.add('');
		}

		String emailbody = String.format(partMap.get('EmailBodyWithBannerIntroANdContent'),baseEmailBodyList);
		
		baseEmailBodyList.clear();
		String languagelocalekey = Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey);
		baseEmailBodyList.add('<style> @media all {.ExternalClass {width: 100%;}.ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font, .ExternalClass td,.ExternalClass div {line-height: 100%; }.apple-link a {color: inherit !important;font-family: inherit !important;font-size: inherit !important;font-weight: inherit !important; line-height: inherit !important; text-decoration: none !important;}}@media only screen and (max-width: 620px) {table[class=body] .wrapper,table[class=body] .header, table[class=body] .article { padding: 10px !important; } table[class=body] .content { padding: 0 !important; } table[class=body] .container {padding: 0 !important; width: 100% !important; }table[class=body] .main {border-left-width: 0 !important;border-radius: 0 !important;border-right-width: 0 !important;} table[class=body] .main {border-left-width: 0 !important;border-radius: 0 !important;border-right-width: 0 !important;} table[class=body] .btn a {width: 100% !important; }table[class=body] .img-responsive {height: auto !important;max-width: 100% !important;width: auto !important; }td[class="mobile-hide"] {display: none; }.mobile-hide {display: none;}.newsletter-item .media {width: 100px !important;}.newsletter-item .media .Calendar .CalendarMonth {font-size: 14px !important;} .newsletter-item .media .Calendar .CalendarDay {font-size: 33px !important;} .newsletter-item--showCase .media {width: 100% !important;}.newsletter-item--showCase .media .Calendar .CalendarMonth {font-size: 20px !important;}.newsletter-item--showCase .media .Calendar .CalendarDay {font-size: 40px !important;} .wrapper,.header, .article { padding: 10px !important;} .content { padding: 0 !important;}.container {padding: 0 !important;width: 100% !important;}.main { border-left-width: 0 !important;border-radius: 0 !important; border-right-width: 0 !important;}.btn table { width: 100% !important;} .btn a { width: 100% !important; }.img-responsive { height: auto !important;max-width: 100% !important;width: auto !important;}} a[x-apple-data-detectors] {color: inherit !important;text-decoration: none !important;font-size: inherit !important;font-family: inherit !important; font-weight: inherit !important;line-height: inherit !important; }<!--[if mso]><style type="text/css">*, table, td, a, p, span, h1, h2, h3, h4, h5, h6 {font-family: Arial, sans-serif !important;}</style><![endif]--></style>');
		//***url to backyard logo not used anymore*** formatterList.add(PageContext.getPageURL(Pages.app)+'?u=/&origin=ne');
		baseEmailBodyList.add(brandingInfo.logo_url);
		baseEmailBodyList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(),languagelocalekey, peopleObj.User__r.timeZonesidkey));// current date
		baseEmailBodyList.add(emailBody);
		String pid = UserInfo.getOrganizationId().subString(0,15) + String.valueOf(peopleObj.Id).subString(0,15); 
		
		if (SimpplrContext.appConfig.Mobile_Promotion_Enabled__c) {
			baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, 
					KEY_FOOTER_PROMOTION_HEADING).replace('{{appName}}',
					SimpplrContext.applicationName)); 
			baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey, 
					KEY_FOOTER_PROMOTION_TEXT).replace('{{appName}}',
					SimpplrContext.applicationName));
			baseEmailBodyList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'iOS&utm_source=email_footer&utm_term=' + pid);
			baseEmailBodyList.add(EmailConstants.footerPromotionBadgeIOS.replace('{{locale}}',languagelocalekey));
			baseEmailBodyList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'android&utm_source=email_footer&utm_term='  + pid);
			baseEmailBodyList.add(EmailConstants.footerPromotionBadgeAndroid.replace('{{locale}}',languagelocalekey));

		}
	baseEmailBodyList.add(BaseCtrl.salesForceBaseUrl + Page.PageRedirector.getUrl()+'?userId='+peopleObj.id+'&pageToRedirect='+Pages.MySettingsEmail+'&origin=ne');
			
	baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey,KEY_FOOTER_SETTINGS).replace('{{appName}}',SimpplrContext.applicationName));
	baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey,KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
	baseEmailBodyList.add(LocaleContext.getLabel(languagelocalekey,KEY_POWERED_BY));
	if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
		baseEmailBodyList.add('000000');
	} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
		baseEmailBodyList.add(brandingInfo.general_primaryColor);
	} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
		baseEmailBodyList.add('ffffff');
	} else {
		baseEmailBodyList.add(brandingInfo.header_backgroundColor);
	}
	baseEmailBodyList.add(appConfig.Newsletter_Open_Tracker_URL__c);
	baseEmailBodyList.add(Utility.getNewsletterTrackerCode(mailerRecord.Id, peopleObj.User_Hash__c));
	if (SimpplrContext.appConfig.Mobile_Promotion_Enabled__c) {
		newsletterBody = EmailUtility.format(partMap.get('BaseEmailwithheaderfooter'), baseEmailBodyList);
	}
	else
		{
			newsletterBody = EmailUtility.format(partMap.get('BaseEmailBody'), baseEmailBodyList);
		}
    	return newsletterBody;
    }
	

    private String getIntroHTMLBody(Map<String,String> partMap,String intro){
    	String introBody = '';
    	if(String.isNotBlank(intro)){
    		introBody = EmailUtility.format(partMap.get('IntroBody'), new List<String>{
								intro
							});
    	}
    	return introBody;
    }
    
    private String getMainBody(Mailer__c mailerRecord, Boolean isPreview, 
            People__c peopleObj, List<Mailer_Details__c> listOfMailerDetail,  
            Map<ID, Boolean> contentIdWithMustReadMap, Map<Id, String> contentIdNPublicUrlMap){
    	
		String userLanguage = Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey);
    	String mainBodyString = '';
		String startsString = LocaleContext.getLabel(userLanguage, KEY_LABEL_STARTS);
		String startsEndsString = LocaleContext.getLabel(userLanguage, KEY_LABEL_STARTS_ENDS);
		String endsString = LocaleContext.getLabel(userLanguage, KEY_LABEL_ENDS);
		Integer index = 1;
    	for(Mailer_Details__c detailObj : listOfMailerDetail){
    		List<String> contentPartList = new List<String>();
    		List<String> rowComponentList = new List<String>();
    		// Check for type
    		if('Content'.equalsIgnoreCase(detailObj.Type__c)){
    			
    			String viewURL = '';
    			if(String.isNotBlank(detailObj.Content__c)){
					viewURL = PageContext.getPageURL(Pages.PageRedirector)+'?pageToRedirect=ContentDetailPage&contentId=' + detailObj.Content__c+'&contentType='+detailObj.content__r.type__c.tolowercase();
					if(isPreview == false){
						viewURL += '&newsletterId=' + mailerRecord.Id + '&origin=nle' +'&utm_medium=email'+'&utm_source=newsletter'+'&utm_content='+mailerRecord.Id;	            	
					}
	    		}
	    		
    			String contentType = detailObj.content__r.type__c;
    			Boolean isShowCase = detailObj.Is_Showcase__c;
    			String contentTemplateKey = isShowCase ? 'showcase_' : '';
    			if('Event'.equalsIgnoreCase(contentType)){
					Boolean isSingleDayEvent;
					if(detailObj.content__r.Event_Is_All_Day__c) {						
						isSingleDayEvent = detailObj.content__r.Event_Start_DateTime__c.format('dd-MM-yyyy', detailObj.content__r.Event_TimezoneSidKey__c).equalsIgnoreCase(
											detailObj.content__r.Event_End_DateTime__c.format('dd-MM-yyyy', detailObj.content__r.Event_TimezoneSidKey__c));
					} else {
    					isSingleDayEvent = detailObj.content__r.Event_Start_DateTime__c.isSameDay(detailObj.content__r.Event_End_DateTime__c);
					}
    			
    				if(isSingleDayEvent){
    					contentTemplateKey += 'event_single_day';
    				} else {
    					contentTemplateKey += 'event_multi_day';
    				}
    			} else {
    				contentTemplateKey += contentType;
    			}
    			
    			// 0 Add Image
				if('Event'.equalsIgnoreCase(contentType)) { 
					if(isShowCase && contentIdNPublicUrlMap.get(detailObj.Content__c) != null){
						rowComponentList.add(contentIdNPublicUrlMap.get(detailObj.Content__c));
					} else {
						contentTemplateKey += '_without_image';
						
						rowComponentList.add('');
					}
				} else {
					if(contentIdNPublicUrlMap.get(detailObj.Content__c) != null){
						rowComponentList.add(contentIdNPublicUrlMap.get(detailObj.Content__c));
					} else {
						contentTemplateKey += '_without_image';
						
						rowComponentList.add('');
					}
				}
				
				// 1 Add Heading(title)
				if(String.isNotBlank(detailObj.content__r.Title__c)){
					rowComponentList.add((detailObj.content__r.Title__c.length() > 100) ? detailObj.content__r.Title__c.substring(0,97) + '...' : detailObj.content__r.Title__c);
				} else {
					rowComponentList.add('');
				}
				
				// 2 Add description
				if(String.isNotBlank(detailObj.content__r.Display_Excerpt__c)){
					rowComponentList.add(detailObj.content__r.Display_Excerpt__c);
				} else {
					rowComponentList.add('');
				}
				
				// 3 Add site name
				if(String.isNotBlank(detailObj.content__r.Site__c)){
					rowComponentList.add(detailObj.content__r.Site__r.Name);
				} else {
					rowComponentList.add('');
				}
				
				// 4 Add Last edited date time
				if(detailObj.content__r.Last_Edited_DateTime__c != null){
					rowComponentList.add(LocaleContext.getLocalisedDateAsMMMDDYYYY(detailObj.content__r.Last_Edited_DateTime__c, userLanguage, peopleObj.User__r.timeZonesidkey));// current date
				} else {
					rowComponentList.add('');
				}
				
				// 5 Add owner name for blog
				if(String.isNotBlank(detailObj.content__r.Primary_Author__r.Full_Name__c)){
					rowComponentList.add(detailObj.content__r.Primary_Author__r.Full_Name__c);
				} else {
					rowComponentList.add('');
				}

				// 6 Add start date(EEEE d MMM, YYYY) And 7 Month(MMM) And 8 date(d) And 9 WeekDay(EEEE)
				if('Event'.equalsIgnoreCase(contentType) && detailObj.content__r.Event_Start_Datetime__c != null){
					// (EEEE d MMM, YYYY) 
					if(contentTemplateKey.containsIgnoreCase('event_single_day')){
						String dateWithTimezone = getDateWithTimezone(detailObj.content__r.Event_TimezoneSidKey__c, detailObj.content__r.Event_Is_All_Day__c, detailObj.content__r.Event_End_DateTime__c, peopleObj);
						rowComponentList.add(endsString + ': ' + dateWithTimezone);
					} else {
						if(detailObj.content__r.Event_Is_All_Day__c) {
							rowComponentList.add(startsString + ': ' + LocaleContext.getLocalisedDayAndDate(detailObj.content__r.Event_Start_Datetime__c, userLanguage, detailObj.content__r.Event_TimezoneSidKey__c));
						} else {
							rowComponentList.add(startsString + ': ' + LocaleContext.getLocalisedDateAsUMMDDYYYYHHMMAA(detailObj.content__r.Event_Start_Datetime__c, userLanguage, peopleObj.User__r.timeZonesidkey));
						}
					}
				} else {
					rowComponentList.add('');
					
				}
				
				// 7 Add end date (EEEE d MMM, YYYY) 
				if('Event'.equalsIgnoreCase(contentType) && detailObj.content__r.Event_End_DateTime__c != null){
					if(contentTemplateKey.containsIgnoreCase('event_single_day')){
						rowComponentList.add('');
					} else {
						// (EEEE d MMM, YYYY) 
						String dateWithTimezone = getDateWithTimezone(detailObj.content__r.Event_TimezoneSidKey__c, detailObj.content__r.Event_Is_All_Day__c, detailObj.content__r.Event_End_DateTime__c, peopleObj);
						rowComponentList.add(endsString + ': ' + dateWithTimezone);
						
					}
				} else {
					rowComponentList.add('');
				}
				// 8 View URL
				rowComponentList.add(viewURL);
				
				// 9 Site URL
				if(String.isNotBlank(detailObj.content__r.Site__c)){
					rowComponentList.add(PageContext.getPageURL(Pages.app) +'?u=/site/' + detailObj.content__r.Site__c + '/' + detailObj.content__r.site__r.Landing_Page__c);
				} else {
					rowComponentList.add('');
				}
				
				// 10 Owner Profile URL
				if(String.isNotBlank(detailObj.content__r.Primary_Author__r.Full_Name__c)){
					rowComponentList.add(PageContext.getPageURL(Pages.People) +'?u=/people/' + detailObj.content__r.Primary_Author__c);
				} else {
					rowComponentList.add('');
				}
				// 11 Must Read Stamp
				if(contentIdWithMustReadMap.get(detailObj.Content__c)){
					rowComponentList.add('<span class="type--mustRead" style="color: #333;">'+LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey),KEY_LABEL_MUSTREAD)+'</span>');
				}else{
					rowComponentList.add('');
				}
				//12
				if('Page'.equalsIgnoreCase(contentType)){
					rowComponentList.add(LocaleContext.getLabel(userLanguage,KEY_LABEL_PAGE));
				} else if('Album'.equalsIgnoreCase(contentType)){
					rowComponentList.add(LocaleContext.getLabel(userLanguage,KEY_LABEL_ALBUM));
				}else if('BlogPost'.equalsIgnoreCase(contentType)){
					rowComponentList.add(LocaleContext.getLabel(userLanguage,KEY_LABEL_BLOGPOST));
				}else if('Event'.equalsIgnoreCase(contentType)){
					rowComponentList.add(LocaleContext.getLabel(userLanguage,KEY_LABEL_EVENT));
				}
				//13 In keyword
				if('BlogPost'.equalsIgnoreCase(contentType) == false){
					rowComponentList.add(LocaleContext.getLabel(userLanguage,KEY_LABEL_IN)+' ');
				}else{
					rowComponentList.add(LocaleContext.getLabel(userLanguage,KEY_LABEL_BY)+' ');
				}
				
				//14 All day keyword for a single day event 
				if('Event'.equalsIgnoreCase(contentType)) {
					if(!detailObj.content__r.Event_Is_All_Day__c) {
						String timeZoneLabel = Utility.timezoneIdToDisplayLabel(peopleObj.User__r.Timezonesidkey);
						rowComponentList.add(startsString + ': ' + LocaleContext.getLocalisedDateAsUMMDDYYYYHHMMAA(detailObj.content__r.Event_Start_Datetime__c,userLanguage, peopleObj.User__r.timeZonesidkey));
						rowComponentList.add(endsString + ': ' + LocaleContext.getLocalisedDateAsUMMDDYYYYHHMMAA(detailObj.content__r.Event_End_DateTime__c,userLanguage, peopleObj.User__r.timeZonesidkey) + ' (' + timeZoneLabel + ')');
					} else {
						String timeZoneLabel = Utility.timezoneIdToDisplayLabel(detailObj.content__r.Event_TimezoneSidKey__c);
						rowComponentList.add(startsEndsString + ': ' + LocaleContext.getLocalisedDayAndDate(detailObj.content__r.Event_Start_Datetime__c,userLanguage, detailObj.content__r.Event_TimezoneSidKey__c) + ' (' + timeZoneLabel + ')');
						rowComponentList.add('');
					}
					
				} else {
					rowComponentList.add('');
					rowComponentList.add('');
				}

				// Event without any image - need to get month , date and day of week - 15,16,17
				if(detailObj.content__r.Event_start_DateTime__c != null) {
					if(detailObj.content__r.Event_Is_All_Day__c) {
						rowComponentList.add(LocaleContext.getLocalisedMonth(detailObj.content__r.Event_start_DateTime__c, userLanguage, detailObj.content__r.Event_TimezoneSidKey__c));
						rowComponentList.add(detailObj.content__r.Event_start_DateTime__c.format('dd', detailObj.content__r.Event_TimezoneSidKey__c));
						rowComponentList.add(LocaleContext.getLocalisedDayOfWeek(detailObj.content__r.Event_start_DateTime__c, userLanguage, detailObj.content__r.Event_TimezoneSidKey__c));
					} else {
						rowComponentList.add(LocaleContext.getLocalisedMonth(detailObj.content__r.Event_start_DateTime__c, userLanguage, peopleObj.User__r.timeZonesidkey));
						rowComponentList.add(detailObj.content__r.Event_start_DateTime__c.format('dd', peopleObj.User__r.timeZonesidkey));
						rowComponentList.add(LocaleContext.getLocalisedDayOfWeek(detailObj.content__r.Event_start_DateTime__c, userLanguage, peopleObj.User__r.timeZonesidkey));
					}
				} else {
					rowComponentList.add('');
					rowComponentList.add('');
					rowComponentList.add('');
				}
				//18 on keyword
				rowComponentList.add(LocaleContext.getLabel(userLanguage,KEY_LABEL_ON)+' ');
				
				mainBodyString += String.format(partMap.get(contentTemplateKey.toLowerCase()), rowComponentList);    			

    		} else if ('Heading'.equalsIgnoreCase(detailObj.Type__c)){
    			String headingTypeRow = partMap.get('headingTypeRow');
    			
    			mainBodyString += EmailUtility.format(headingTypeRow, new List<String>{
	    								detailObj.Text__c});
			} else if ('Text'.equalsIgnoreCase(detailObj.Type__c)){
    			String richText = partMap.get('richText');
    			
    			mainBodyString += EmailUtility.format(richText, new List<String>{
	    								detailObj.Text__c});
    		} else if ('Divider'.equalsIgnoreCase(detailObj.Type__c)){
    			mainBodyString += partMap.get('divider');
    		}
    		
    	}
    	
    	return mainBodyString;
    }

	private String getDateWithTimezone(String eventTimeZoneKey, Boolean allDayEvent, DateTime eventdate, People__c peopleObj) {
		String dateWithTimezone;
		String timeZoneLabel;
		if(allDayEvent == false) {
			timeZoneLabel = Utility.timezoneIdToDisplayLabel(peopleObj.User__r.Timezonesidkey);
			dateWithTimezone = LocaleContext.getLocalisedDateAsUMMDDYYYYHHMMAA(eventdate,Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey), peopleObj.User__r.timeZonesidkey) + ' (' + timeZoneLabel + ')';
		} else {
			timeZoneLabel = Utility.timezoneIdToDisplayLabel(eventTimeZoneKey);
			dateWithTimezone = LocaleContext.getLocalisedDayAndDate(eventdate,Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey), eventTimeZoneKey) + ' (' + timeZoneLabel + ')';
		}

		return dateWithTimezone;
	}
    
    private Integer getCGMemberCount(String recipientCollGrpId){
    	Simpplr_Site__c siteObj = [select chatter_group_id__c from simpplr_site__c where id =:recipientCollGrpId limit 1];
    	String grpId = siteObj.chatter_group_id__c;
    	CollaborationGroup cGMember = [select memberCount from CollaborationGroup where Id =:grpId limit 1];
    	return cGMember.memberCount;
    }
    
    public void finish(Database.BatchableContext BC){
    	try{
    		if('sendAnalyticsDataToAWS'.equalsIgnoreCase(batchType)) {
    			BatchNotificationArchival notificationArchival = new BatchNotificationArchival('deleteUngroupedNotifications', true);
                Database.executeBatch(notificationArchival, 1000);
    		} else {
		    	if(BC!=null){
			    	AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems,
			                    CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :BC.getJobId()];
					List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
			        if(a.Status == 'Completed' && a.NumberOfErrors == 0) {
			        	if(isCalledFromScheduler){
				        	if(canSendMail){
						    	mailerObj.Status__c = 'Sent';
								listOfModifiedFields.add(Mailer__c.Status__c);
						    	if(String.isNotBlank(mailerObj.site__c)){
						    		mailerObj.Actual_Recipient_Count__c = getCGMemberCount(mailerObj.site__c);
						    	}else{
						    		mailerObj.Actual_Recipient_Count__c = Utility.getTotalPeopleInSimpplr();
						    	}
						    	mailerObj.Sent_Time__c = datetime.now();
								listOfModifiedFields.add(Mailer__c.Actual_Recipient_Count__c);
								listOfModifiedFields.add(Mailer__c.Sent_Time__c);
					    	}else if('Scheduled'.equalsIgnoreCase(mailerObj.Status__c)){
					    		mailerObj.Status__c = 'On Hold';
					    		NotificationDispatcher.sendNotificationForOnholdNewsletter(mailerObj.Sent_By__c,mailerObj.Id,'Unpublished Data');
			   					NotificationDispatcher.sendEmailForOnholdNewsletter(mailerObj.Sent_By__c,mailerObj.Subject__c,mailerObj.Id,'Unpublished Data');
								listOfModifiedFields.add(Mailer__c.Status__c);
					    	}
					    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        					SIMPESAPI.accessController().updateAsUser(mailerObj, listOfModifiedFields);
			        	}
			        }else{
			        	mailerObj.Status__c = 'On Hold';
			        	mailerObj.sent_time__c = null;
						listOfModifiedFields.add(Mailer__c.Status__c);
						listOfModifiedFields.add(Mailer__c.sent_time__c);
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        				SIMPESAPI.accessController().updateAsUser(mailerObj, listOfModifiedFields);
			        	NotificationDispatcher.sendNotificationForOnholdNewsletter(mailerObj.Sent_By__c,mailerObj.Id,'Errors found in job');
		   				NotificationDispatcher.sendEmailForOnholdNewsletter(mailerObj.Sent_By__c,mailerObj.Subject__c,mailerObj.Id,'Errors found in job');
			        }
			          
			        if(isCalledFromScheduler){
						Map<String, Object> soqlParamMap = new  Map<String, Object>();
						soqlParamMap.put('soqlParam1', newsletterScheduledDate);
						String queryNewsletter = ' SELECT ' + String.join(NewsletterDataServer.getNewsletterFieldList(),',') + 
									 ' FROM Mailer__c where Is_Deleted__c=false AND Status__c = \'Scheduled\' AND Scheduled_Date__c=:soqlParam1 LIMIT 1';	
						
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
						List<Mailer__c> mailerList  = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(queryNewsletter, soqlParamMap);
					
				    	if(mailerList.size()> 0){
				    		BatchNewsletter job = new BatchNewsletter(mailerList[0], newsletterScheduledDate, false, true);
				    		Database.executeBatch(job,25);
				    	}
			    	}
		    	}
    		}
    	}catch(Exception e){
    		
    	}
    }    
    
     private Map<Id, String> getcontentIdNPublicUrlMap(List<Simpplr_Content__c> contentList,Map<Id,Boolean> contentIdWithShowcaseMap) {
    	Map<Id, String> contentIdNPublicUrlMap = new Map<Id, String>();
    	Map<Id, File__c> contentIdAndFileMap = new Map<Id, File__c>();
    	
    	for(Simpplr_Content__c contentObj : contentList) {
    		Boolean isShowcase = contentIdWithShowcaseMap.get(contentObj.id);
    		String desiredImage = isShowcase ? 'Widescreen' : 'Thumbnail';
    		List<File__c> fileList = contentObj.File_Simpplr_Content__r;
			if(!fileList.isEmpty()) {
				for(File__c fileObj : fileList) {
					if(fileObj.Is_Title_Image__c){
						if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)){
							if(String.isNotBlank(fileObj.Content_Version__c)) {
								if(String.isNotBlank(fileObj.thumbnail_url__c) && fileObj.thumbnail_url__c.startsWith('https://static.simpplr.com')) {
									contentIdNPublicUrlMap.put(contentObj.id, fileObj.Thumbnail_URL__c);
								} else {
									contentIdAndFileMap.put(contentObj.Id, fileObj);
								}
							} else {
								contentIdNPublicUrlMap.put(contentObj.id, fileObj.Thumbnail_URL__c);
							}
							break;
						} else if(desiredImage.equalsIgnoreCase(fileObj.Title_Image_Type__c)) {
							if(String.isNotBlank(fileObj.thumbnail_url__c) && fileObj.thumbnail_url__c.startsWith('https://static.simpplr.com')) {
								contentIdNPublicUrlMap.put(contentObj.id, fileObj.Thumbnail_URL__c);
							} else {
								contentIdAndFileMap.put(contentObj.Id, fileObj);
							}
							break;
						}
					}
				}
			} else {
				Map<Id, Id> contentIdAndCVIdMap = new Map<Id, Id>();
				Simpplr_Site__c siteObj = contentObj.Site__r;
				if(siteObj != null && String.isNotBlank(siteObj.Title_Content_Version__c) && contentObj.Type__c != 'Event') {
					contentIdAndCVIdMap.put(contentObj.Id, siteObj.Title_Content_Version__c);
					
					Map<Id, String> cvIdNPublicUrlMap;
					if(contentIdAndCVIdMap.size()>0){
						cvIdNPublicUrlMap = FileContentProvider.generateEmbedPublicUrl(contentIdAndCVIdMap.values());
					
						for(Id contentId : contentIdAndCVIdMap.keySet()){
							contentIdNPublicUrlMap.put(contentId,cvIdNPublicUrlMap.get( contentIdAndCVIdMap.get(contentId)));
						}
					}
				}
			}
    		
    	}
		Map<String, String> contentVersionPublicURLMap = new Map<String, String>();
		FileContentProvider provider = new FileContentProvider();
		for(File__c fileObj : contentIdAndFileMap.values()) {
			String publicURL = provider.uploadImageToAWS(fileObj.title__c, fileObj.Content_Version__c);
			contentIdNPublicUrlMap.put(fileObj.Simpplr_Content__c, publicURL);
			contentVersionPublicURLMap.put(fileObj.Content_Version__c, publicURL);
		}
		if(!contentVersionPublicURLMap.isEmpty()) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentVersionPublicURLMap.keySet());
			String filesQuery = 'select id, content_version__c, thumbnail_url__c, title__c from file__c '+
									  ' where simpplr_content__c!= null '+
									  ' AND content_version__c=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
			provider.updateThumbnailURL(fileList, contentVersionPublicURLMap);
		} 	
    	 
    	return contentIdNPublicUrlMap;
    }
    
    public String converDistributionPublicUrlToImageURL(String contentVersionId, String distributionPublicUrl, String rendition) {
    	String publicURL;
    	if(String.isNotBlank(distributionPublicUrl)) {
	    	String urlPart = distributionPublicUrl.substringAfter(UserInfo.getOrganizationId().mid(3,12));
	    	publicURL = SimpplrContext.salesforceHost + '/sfc/dist/version/renditionDownload?versionId=' + contentVersionId + '&d=' + urlPart + '&oid=' + UserInfo.getOrganizationId() + '&rendition=' + rendition;
    	}
    	return publicURL;
    }

	private List<Mailer_Details__c> getMailerDetails(Id mailerId) {	
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', mailerId);
		String query = 'SELECT Id, Is_Deleted__c, Mailer__c, ' 
				+ ' content__r.Is_Must_Read__c, Order__c, Content__c, ' 
				+ ' Content__r.Last_Edited_DateTime__c, ' 
				+ ' content__r.Activated_By_Feature__c, content__r.Site__c, ' 
				+ ' content__r.Event_Is_All_Day__c, '
				+ ' content__r.Event_Start_Datetime__c, content__r.Event_End_Datetime__c, '
				+ ' content__r.Event_TimezoneSidKey__c, ' 
				+ ' content__r.Type__c, Content__r.Primary_Author__c, '
				+ ' Content__r.Primary_Author__r.Full_Name__c,content__r.Title__c, ' 
				+ ' content__r.Display_Excerpt__c, '
				+ ' Content__r.Is_Unpublished__c,Content__r.Is_Deleted__c, '
				+ ' Content__r.Site__r.Landing_Page__c, '
				+ ' Content__r.Site__r.Is_Active__c,Content__r.Site__r.Is_Deleted__c, '
				+ ' Content__r.Site__r.Show_In_Simpplr__c,Content__r.Site__r.Name, '
				+ ' Text__c,Type__c,Is_Showcase__c ' 
				+ ' FROM Mailer_Details__c '
				+ ' WHERE Mailer__c =:soqlParam1 '
				+ ' order by Order__c asc';
				
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Mailer_Details__c> listOfMailerDetail = (List<Mailer_Details__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		return listOfMailerDetail;
    }
}