public with sharing class EmailUtility {
    
    /*** @description this is the relative url of aws send email endpoint */
    private static final String AWS_EMAIL_ENDPOINT = '/spodbc/search-sp?action=sendmail';
	private static final String SIMPPLR_APP_NAME = 'Simpplr';

    /*** @description this is the instance of simpplr logger */

    /**
     * @description the class is used to create a email to be sent by aws
     */
    public class EmailParts {
        /*** @description this is to specify the sender */
        public String sender {get; set;}
        /*** @description this is to specify the to address list */
        public List<String> to {get; set;}
        /*** @description this is to specify the subject */
        public String subject {get; set;}
        /*** @description this is to specify the body */
        public String body {get; set;}
    }

    public static String applyLinksFormatting(String text) {
    	String formattedText = '';
    	if(String.isNotBlank(text)) {
    		formattedText = text.replace('<a ','<a style="color:#008AC6;text-decoration:none;word-break:break-word"');
    	}
    	return formattedText;
    }
    
    public static String getFormattedDate(DateTime dateTimeVal, String userTimeZone) {
		String formatedDateTime =  String.valueOf(dateTimeVal.format(ServiceConstants.EMAIL_DIGEST_HEADER_DATETIME_FORMAT,userTimeZone));
		return formatedDateTime;
    }
    
    //With date format as param
    public static String getFormattedDate(DateTime dateTimeVal, String dateFormat, String userTimeZone) {
		String formatedDateTime =  String.valueOf(dateTimeVal.format(dateFormat,userTimeZone));
		return formatedDateTime;
    }

    public static Integer getDigestLimitSize(Integer frequency) {
    	Integer digestLimitSize = 0;
    	if(frequency == 1) {
	        if (SimpplrContext.SEDDailyDigestSize != null) {
	        	digestLimitSize = SimpplrContext.SEDDailyDigestSize;
	        } 
        	digestLimitSize = digestLimitSize == 0  ? 10 : digestLimitSize;
        } else if(frequency == 7) {
    		 if (SimpplrContext.SEDWeeklyDigestSize != null) {
    			digestLimitSize = (SimpplrContext.SEDWeeklyDigestSize);
    		 } 
			digestLimitSize = digestLimitSize == 0  ? 20 : digestLimitSize;
    	} else {
    		digestLimitSize = 10;
    	}
    	return digestLimitSize;
    }
    
    public static String getSimpplrContentObjName() {
		String strVar = SimpplrContext.packageName;
		if(String.isNotBlank(strVar)){
			strVar=strVar + '__Simpplr_Content__c';
			return strVar;
		}
		else{
			return 'Simpplr_Content__c';
		}
	}
	
	public static Messaging.SingleEmailMessage getSingleEmailMessageObject(String emailBody, String subject, String toEmail, String replyTo) {
		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
		singleMail.setToAddresses(new List<String>{toEmail});
		if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
			singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
		}
		singleMail.setSubject(subject);
		singleMail.setHtmlBody(emailBody);
		singleMail.setCharset('UTF-8');
		singleMail.setUseSignature(false);
		singleMail.setSaveAsActivity(false);
		
		return singleMail;
	}
	
	public static Messaging.SingleEmailMessage getSingleEmailElement(String subject, String emailBody, String targetUser, String orgWideEmailId) {
		Messaging.SingleEmailMessage singleMail;
		singleMail = new Messaging.SingleEmailMessage();
		singleMail.setTargetObjectId(targetUser);
		singleMail.setSubject(subject);
		if(String.isNotBlank(orgWideEmailId)) {
			singleMail.setOrgWideEmailAddressId(orgWideEmailId);
		}
		if(String.isNotBlank(emailBody) && SimpplrContext.DeeplinkingEnabled) {
			emailBody = deeplinkedMailBody(emailBody);
		}
		singleMail.setHtmlBody(emailBody);
		singleMail.setCharset('UTF-8');
		singleMail.setUseSignature(false);
		singleMail.setSaveAsActivity(false);			
		return singleMail;
	}
	
	public static String deeplinkedMailBody(String strBody) {
		String regexFormat = '(?<=href=(\"|\'))[^\"\']+(?=(\"|\'))';
		Pattern myPattern = Pattern.Compile(regexFormat); 
		Matcher myMatch = myPattern.matcher(strBody);
		Map<String, String> mapURL = new Map<String, String>();
		while (myMatch.find()) {		    
		    mapURL.put(myMatch.group(0), myMatch.group(0));
		}
		for (String fieldName : mapURL.keySet()){
		    if(fieldName.containsIgnoreCase('/apex/')){
		    	String url = (String.isNotBlank(SimpplrContext.DeeplinkingRedirectURL)?SimpplrContext.DeeplinkingRedirectURL: ServiceConstants.SIMPPLR_DEEPLINKING_REDIRECTOR_URL) + EncodingUtil.urlEncode(fieldName, 'UTF-8');
				String strReplace = 'href="' + url + '"';
			    String strSearch = 'href="' + fieldName + '"';
			    strBody = strBody.replace(strSearch,strReplace);
			    strReplace = 'href=\'' + url + '\'';
			    strSearch = 'href=\'' + fieldName + '\'';
			    strBody = strBody.replace(strSearch,strReplace);
		    }
		}
		return strBody;
    }
	public void sendMailToCurrentUser(String subject, String mailContentHtml){
		try{
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> sendTo = new List<String>();
			mail.setTargetObjectId(UserInfo.getUserId());
			if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
				mail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
			}
			mail.setSaveAsActivity(false);
			mail.setSubject(subject);
			String body = '';
			body=body+mailContentHtml;
			mail.setHtmlBody(body);
			mail.setCharset('UTF-8');
			mail.setUseSignature(false);
			mails.add(mail);
			Messaging.sendEmail(mails);
		}
		catch(Exception ex){
			
		}
	}
	
    /**
     * @description This is the method used to send email using AWS service
     * @param emailDetails object having all email information
     */
    public void sendEmailByAws(EmailParts emailDetails) {
        try{
			String simpDri = Utility.externalRequestAuthToken() + ' '
                    			+ SimpplrContext.simpplrOrgId.substring(0, 15) + ' '
								+ UserContext.userId.substring(0, 15);
			
			HttpRequest reqObj = new HttpRequest();
            reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + AWS_EMAIL_ENDPOINT); 
			reqObj.setTimeout(60000);
			reqObj.setHeader('content-type','application/json');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setHeader('simpplr-dri', simpDri);
			reqObj.setMethod('POST');

			Map<String, Object> requestMap = new Map<String, Object>();
			requestMap.put('emailSubject', emailDetails.subject);
			requestMap.put('emailHtmlBody', emailDetails.body);
			requestMap.put('to', emailDetails.to);
			requestMap.put('sender', emailDetails.sender);
			reqObj.setBody(Json.serialize(requestMap));
			
			Http httpObj = new Http();
			httpObj.send(reqObj);
		} catch(Exception ex){
			logger.logError('Unable to send Email', ex);
		}
    }
	
	public void sendMailToPackageManager(String subject, String mailContentHtml){
		try{
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> sendTo = new List<String>();
			String userEmail = UserInfo.getUserEmail();
			sendTo.add(userEmail);
			if(String.isBlank(SimpplrContext.packageName)) {
				mail.setToAddresses(new List<String>{userEmail});
			} else {
				mail.setToAddresses(new List<String>{'package.managers@simpplr.com'});
			}
			mail.setSubject(subject);
			if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
				mail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
			}
			String body = '';
			body=body+mailContentHtml;
			mail.setHtmlBody(body);
			mail.setCharset('UTF-8');
			mail.setUseSignature(false);
			mails.add(mail);
			Messaging.sendEmail(mails);
		}
		catch(Exception ex){
			
		}
	}
	
    public static String getLinkWithFromEmail(String url){
		if(url.containsIgnoreCase('/apex/')){
			List<String> lstURLParts = url.split('#');
			if(lstURLParts.size() > 1) {
				url = lstURLParts[0] + ((lstURLParts[0].indexOf('?') > -1) ? '&' : '?') + 'fromEmail=1'+ '#' + lstURLParts[1];
			} else {
				url = lstURLParts[0] + ((lstURLParts[0].indexOf('?') > -1) ? '&' : '?') + 'fromEmail=1';
			}
		}
		return url;
    }
    
    public static NotificationHelper.BrandingInfo getBrandingInfo4People(People__c peopleObj) {
    	NotificationHelper.BrandingInfo brandingInfoObj = null;
    	
    	
    	String brandingJsonString = null;
    	if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled) {
			if(String.isNotBlank(peopleObj.Segment__c)) {
				brandingJsonString = peopleObj.Segment__r.Branding_JSON__c;
			} else {
				brandingJsonString = '';
			}
    	} else {
    		brandingJsonString = SimpplrContext.SABrandingJSON;
    	}
    	
		brandingInfoObj = Utility.getBrandingInfoJson(brandingJsonString, getBrandingLogoUrl(peopleObj));
		return brandingInfoObj;
    }
    
    public static String getBrandingLogoUrl(People__c peopleObj) {
    	String logoUrl = EmailConstants.simpplrDefaultLogoUrl; 
    	
    	if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled) {
			if(String.isNotBlank(peopleObj.Segment__c)) {
				logoUrl = String.isBlank(peopleObj.Segment__r.Branding_Logo__c) ? logoUrl : peopleObj.Segment__r.Branding_Logo__c;
			}
    	} else {
    		if(String.isNotBlank(SimpplrContext.SALogo)) {
				logoUrl = SimpplrContext.SALogo;
			}
    	}
    	
    	return logoUrl;
    }
    
    public static String format(String stringToFormat, List<String> formatterList){
		if(!formatterList.isEmpty()){
			Integer paramInteger = formatterList.size();
			if(stringToFormat.contains('\'')){
				String quoteReplaceString = '{' + String.valueOf(paramInteger) + '}';
				stringToFormat = stringToFormat.replaceAll('\'', quoteReplaceString);
				formatterList.add('\'');
			}		
			stringToFormat = String.format(stringToFormat, formatterList); 
		} 
		return stringToFormat;
    }

	public static String htmlBold(String textStr) {
		String BOLD_STYLE_HTML_TAG_START = '<a class="Post-name" href="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #222; font-weight: bold; text-decoration: none;">';
		String BOLD_STYLE_HTML_TAG_END = '</a>';

		textStr = BOLD_STYLE_HTML_TAG_START + textStr + BOLD_STYLE_HTML_TAG_END ;

		return textStr;
	}

	public static void sendEmailForUnavailableLicense(Integer allowedLicenses, List<Id> listOfuserIds, Organization organizationRec){
		String subject = 'Unable to assign Simpplr License to User in '+ organizationRec.Name;		
		String body = 'Unable to assign Simpler License in following org \n\n';
		body += 'Org Id - ' + organizationRec.Id +'\n';
		body += 'Org Name - ' + organizationRec.Name +'\n';
		body += 'Allowed Licenses - ' + allowedLicenses + '\n';	
		body += 'Used Licenses - ' + allowedLicenses + '\n';
		body += 'UserId - ';
		for(Id userId : listOfuserIds){
			body += String.valueOf(userId) + ', ';
		}
		body = body.removeEnd(', ') ;
		EmailUtility emailUtilityObj = new EmailUtility();
		emailUtilityObj.sendMailToPackageManager(subject, body);
    }

	public static String getMobilePromotionFooterDiv(String localekey, String peopleId) {
		String footerMobilePromotionDiv = '';

		if (SimpplrContext.mobilePromotionEnabled) {
			String footerMobilePromotionPart = EmailTemplateService.commonPartMap.get('footerMobilePromotion');

			String pid = UserInfo.getOrganizationId().subString(0,15) + String.valueOf(peopleId).subString(0,15);  

			String KEY_FOOTER_PROMOTION_HEADING = 'email.common.footer.promotion_heading';
			String KEY_FOOTER_PROMOTION_TEXT = 'email.common.footer.promotion_text';
			
			List<String> formatterList = new List<String>();
   
			//{0} Promotion heading
			formatterList.add(LocaleContext.getLabel(localeKey, 
					KEY_FOOTER_PROMOTION_HEADING).replace('{{appName}}',
					SimpplrContext.applicationName));
			//{1} Promotion text 
			formatterList.add(LocaleContext.getLabel(localeKey, 
					KEY_FOOTER_PROMOTION_TEXT).replace('{{appName}}',
					SimpplrContext.applicationName));
			//{2} iOS APP LInk 
			formatterList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'iOS&utm_source=email_footer&utm_term=' + pid);
			//{3} IOS badge 
			formatterList.add(EmailConstants.footerPromotionBadgeIOS.replace('{{locale}}',localeKey));
			//{4} Android app link 
			formatterList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'android&utm_source=email_footer&utm_term=' + pid);
			//{5} Android badge 
			formatterList.add(EmailConstants.footerPromotionBadgeAndroid.replace('{{locale}}',localeKey));
			footerMobilePromotionDiv = EmailUtility.format(footerMobilePromotionPart, formatterList);
		}
		
		return footerMobilePromotionDiv;
	}

	/**
	 * @description getMobilePromotionEmailBody - get email body for downloading mobile app
	 * @param brandingInfo
	 * @param isBulkEmailTemplate
	 * @param distributionWrapperObj
	 * @return finalHtml - email body html
	 */
	public static String getMobilePromotionEmailBody(NotificationHelper.BrandingInfo brandingInfo, Boolean isBulkEmailTemplate,
		MobileAppDistributionWrapper distributionWrapperObj) {

		String finalHtml = '';
		List<String> formatterList = new List<String>();
		String languagelocalekey = Utility.getSimpplrLanguageLocaleKey(distributionWrapperObj.peopleObj.User__r.languageLocaleKey);
		String pid = UserInfo.getOrganizationId().subString(0,15) + ((String)distributionWrapperObj.peopleObj.Id).subString(0,15); 
		String mobilePromotionEmailTemplate = EmailTemplateService.templatePartMap.get('templateMobilePromotionEmail');
		// {0} logo of app 
		formatterList.add(brandingInfo.logo_url);
		// {1}Date 
		formatterList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(),
				languagelocalekey, distributionWrapperObj.peopleObj.User__r.timeZoneSIDKey));
		//{2} Salutation 
		formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				EmailConstants.KEY_EMAIL_COMMON_SALUTATION).replace('{{firstName}}', distributionWrapperObj.peopleObj.First_Name__c));
		if(SimpplrContext.brandedAppDistributionEnabled && isBulkEmailTemplate) {
			//{3} Message for download 
			formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				'email.branded_promotion.download_message').replace('{{appName}}', SimpplrContext.applicationName));
		} else {
			//{3} Message for download 
			formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				'email.mobile_promotion.download_message').replace('{{appName}}', SimpplrContext.applicationName));
		}
		//{4} image link simpplr app 
		formatterList.add(SimpplrContext.brandedAppDistributionEnabled ? EmailConstants.BRANDED_PROMOTION_CENTER_LOGO.replace('{{logoNameOrId}}', UserInfo.getOrganizationId()) : EmailConstants.MOBILE_PROMOTION_CENTER_LOGO);
		//{5} app name -- SEN-4615 -- Should be Intranet name
		formatterList.add(SimpplrContext.applicationName);
		//{6} company intro 
		formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				'email.mobile_promotion.app_intro'));
		//{7} ios Android link n badge
		formatterList.add(getIosAndroidBadgeTemplate(distributionWrapperObj, languagelocalekey, pid));
		//{8} app confirm message
		if(SimpplrContext.brandedAppDistributionEnabled) {
			formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				'email.branded_promotion.app_confirm_message').replace('{{redeemCode}}', distributionWrapperObj.iosCode));
		} else {
			formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				'email.mobile_promotion.app_confirm_message').replace('{{appName}}', SimpplrContext.applicationName));
		}
		// {9} Email prefrence link 
		formatterList.add(SimpplrContext.salesforceBaseUrl + Page.PageRedirector.getUrl() + '?userId=' + 
			distributionWrapperObj.peopleObj.Id + '&pageToRedirect=' + Pages.MySettingsEmail + 
				'&origin=ne');
		// {10} Email prefrence link text
		formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				EmailConstants.KEY_FOOTER_SETTINGS).replace('{{appName}}', SimpplrContext.applicationName));
		// {11} copy right 
		formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				EmailConstants.KEY_COPYRIGHT).replace('{{year}}', '' + DateTime.now().year()));
		//{12}  powered by text 
		formatterList.add(LocaleContext.getLabel(languagelocalekey, 
				EmailConstants.KEY_POWERED_BY));
		// {13} css 
		formatterList.add('<style>@media all{.ExternalClass{width:100%}.ExternalClass,.ExternalClass p,.ExternalClass span,.ExternalClass font,.ExternalClass td,.ExternalClass div{line-height:100%}.apple-link a{color:inherit!important;font-family:inherit!important;font-size:inherit!important;font-weight:inherit!important;line-height:inherit!important;text-decoration:none!important}}@media only screen and (max-width:620px){table[class=body] .wrapper,table[class=body] .header,table[class=body] .article{padding:10px!important}table[class=body] .content{padding:0!important}table[class=body] .container{padding:0!important;width:100%!important}table[class=body] .main{border-left-width:0!important;border-radius:0!important;border-right-width:0!important}table[class=body] .main{border-left-width:0!important;border-radius:0!important;border-right-width:0!important}table[class=body] .btn a{width:100%!important}table[class=body] .img-responsive{height:auto!important;max-width:100%!important;width:auto!important}td[class="mobile-hide"]{display:none}.mobile-hide{display:none}.newsletter-item .media{width:100px!important}.newsletter-item .media .Calendar .CalendarMonth{font-size:14px!important}.newsletter-item .media .Calendar .CalendarDay{font-size:33px!important}.newsletter-item--showCase .media{width:100%!important}.newsletter-item--showCase .media .Calendar .CalendarMonth{font-size:20px!important}.newsletter-item--showCase .media .Calendar .CalendarDay{font-size:40px!important}.wrapper,.header,.article{padding:10px!important}.content{padding:0!important}.container{padding:0!important;width:100%!important}.main{border-left-width:0!important;border-radius:0!important;border-right-width:0!important}.btn table{width:100%!important}.btn a{width:100%!important}.img-responsive{height:auto!important;max-width:100%!important;width:auto!important}}a[x-apple-data-detectors]{color:inherit!important;text-decoration:none!important;font-size:inherit!important;font-family:inherit!important;font-weight:inherit!important;line-height:inherit!important}</style>');
		finalHtml = EmailUtility.format(mobilePromotionEmailTemplate, formatterList);
		return finalHtml;
	}

	private static String getIosAndroidBadgeTemplate(MobileAppDistributionWrapper distributionWrapperObj, String languagelocalekey, String pid) {
		String iosAndroidBadgeTemplateName = 'singleStoreBadgeTemplate';
		List<String> iosAndroidFormatterList = new List<String>();
		if(SimpplrContext.brandedAppDistributionEnabled) {
			//{0} ios link
			iosAndroidFormatterList.add(distributionWrapperObj.iosLink);
			//{1} ios badge
			iosAndroidFormatterList.add(EmailConstants.footerPromotionBadgeIOS.replace('{{locale}}', languagelocalekey));
			if(String.isNotBlank(distributionWrapperObj.androidLink)) {
				iosAndroidBadgeTemplateName = 'multiStoreBadgeTemplate';
				//{2} Android link
				iosAndroidFormatterList.add(distributionWrapperObj.androidLink);
				//{1} Android badge
				iosAndroidFormatterList.add(EmailConstants.footerPromotionBadgeAndroid.replace('{{locale}}', languagelocalekey));
			}
		} else {
			iosAndroidBadgeTemplateName = 'multiStoreBadgeTemplate';
			//{0} ios link
			iosAndroidFormatterList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'iOS&utm_source=email&utm_term=' + pid);
			//{1} ios badge
			iosAndroidFormatterList.add(EmailConstants.footerPromotionBadgeIOS.replace('{{locale}}', languagelocalekey));
			//{2} Android link
			iosAndroidFormatterList.add(EmailConstants.MOBILE_PROMOTION_LINK + 'android&utm_source=email&utm_term=' + pid);
			//{1} Android badge
			iosAndroidFormatterList.add(EmailConstants.footerPromotionBadgeAndroid.replace('{{locale}}', languagelocalekey));
		}
		String iosAndroidBadgeTemplate = EmailTemplateService.templatePartMap.get(iosAndroidBadgeTemplateName);
		return EmailUtility.format(iosAndroidBadgeTemplate, iosAndroidFormatterList);
	}

}