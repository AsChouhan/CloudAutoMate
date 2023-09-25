public with sharing class CalendarUtility {

	private final String dateTimeFormat = 'yyyyMMdd\'T\'HHmmssZ';
	private final String NEW_LINE = '\n';
	private final String uniqueId = DateTime.now().getTime() + '@simpplr.com';
	String FILE_LINE_BREAK = '\\n';
	String WEB_URL_LINE_BREAK = '%0A';
	String Office365_LINE_BREAK = '</br>';
    		
    public String getGoogleCalendarWebUrl(Simpplr_Content__c contentObj) {
    	
    	String googleCalendarWebUrl = 'https://calendar.google.com/calendar/render' +
    								   '?action=' 	+ 	'TEMPLATE' +
    								   '&text='		+ 	EncodingUtil.urlEncode(contentObj.Title__c, 'UTF-8');
    	
    	if(contentObj.Event_Is_All_Day__c) {
    		googleCalendarWebUrl +=	   '&dates='	+	contentObj.Event_Start_DateTime__c.format('yyyyMMdd') + '/' + 
    								   					contentObj.Event_End_DateTime__c.addSeconds(1).format('yyyyMMdd');
    								   
    	} else {
    		googleCalendarWebUrl +=	   '&dates='	+	contentObj.Event_Start_DateTime__c.format('yyyyMMdd\'T\'HHmmss') + '/' + 
    								   					contentObj.Event_End_DateTime__c.format('yyyyMMdd\'T\'HHmmss') +
    								   '&ctz='		+	UserInfo.getTimeZone().getID();
    								   
    	}
    	
    	googleCalendarWebUrl +=		   '&details='	+	getDescription(contentObj, WEB_URL_LINE_BREAK, true) +
    								   '&location='	+	EncodingUtil.urlEncode(contentObj.Event_Location__c, 'UTF-8') +
    								   '&pli='		+	'1' +
    								   '&uid='		+	uniqueId +
    								   '&sf='		+	'true' +
    								   '&output='	+	'xml';
    	return googleCalendarWebUrl;
    }
    
    public String getOutlookWebUrl(Simpplr_Content__c contentObj) {
		String OutlookWebdateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
		String outlookWebUrl 	=	'https://outlook.live.com/calendar/0/deeplink/compose?rru=addevent&' +
    								'subject='	+	EncodingUtil.urlEncode(contentObj.Title__c, 'UTF-8');
		if(contentObj.Event_Is_All_Day__c) {
    		
    		outlookWebUrl +=	  	'&startdt='	+	contentObj.Event_Start_DateTime__c.formatGMT(OutlookWebdateTimeFormat) + 'Z' + 
    								'&enddt='	+	contentObj.Event_End_DateTime__c.addSeconds(1).formatGMT(OutlookWebdateTimeFormat) + 'Z' +
    								'&allday='	+	'true';
    								   
    	} else {
    		outlookWebUrl +=	    '&startdt='	+	contentObj.Event_Start_DateTime__c.formatGMT(OutlookWebdateTimeFormat) + 'Z' +   
									'&enddt='	+	contentObj.Event_End_DateTime__c.formatGMT(OutlookWebdateTimeFormat) + 'Z' +
    								'&allday='	+	'false';
    								   
    	}
    	
    	outlookWebUrl +=			'&location='	+	EncodingUtil.urlEncode(contentObj.Event_Location__c, 'UTF-8') +
    								'&body='	+	getDescription(contentObj, WEB_URL_LINE_BREAK, true) +
    								'&uid='			+	uniqueId +
    								'&path='		+	'/calendar/action/compose';
    								
    								
    	return outlookWebUrl;
    }
    
    public String getIcsDownloadUrl(Simpplr_Content__c contentObj) {
    	String addToCalendarAppURL = '';
    	String userAgent = SimpplrContext.userAgent;
    	if(String.isNotBlank(userAgent) && (userAgent.containsIgnoreCase('Windows Phone') || 
    										userAgent.containsIgnoreCase('iPhone')  || 
    										userAgent.containsIgnoreCase('iPad') || 
    										userAgent.containsIgnoreCase('Android') || 
    										userAgent.containsIgnoreCase('SymbianOS')||  
    										userAgent.containsIgnoreCase('BlackBerry'))) {
    	
	    	addToCalendarAppURL 	=	'https://services.simpplr.com/calendar/eventprocessor.php?' +
	    								'su='	+	EncodingUtil.urlEncode(contentObj.Title__c, 'UTF-8') +
	    								'&de='	+	getDescription(contentObj, WEB_URL_LINE_BREAK, true) +
	    								'&ad='   +	contentObj.Event_Is_All_Day__c +
	    								'&st='	+	contentObj.Event_Start_DateTime__c.formatGMT(dateTimeFormat) +
	    								'&et='	+	contentObj.Event_End_DateTime__c.formatGMT(dateTimeFormat) +
	    								'&ct='	+	contentObj.Publish_Start_DateTime__c.formatGMT(dateTimeFormat) +
	    								'&loc='	+	EncodingUtil.urlEncode(contentObj.Event_Location__c, 'UTF-8');
	    	
	    	if(contentObj.Content_Collaborators_Simpplr_Content__r.isEmpty() == false) {
	    		Content_Collaborator__c firstOrganizer = contentObj.Content_Collaborators_Simpplr_Content__r[0];
	    		addToCalendarAppURL	 +=	'&on='	+ EncodingUtil.urlEncode(firstOrganizer.Collaborator__r.Full_Name__c, 'UTF-8') + 
	    								'&oe=' 	+ firstOrganizer.Collaborator__r.Email__c;
	    	}
	    	
    	} else {
    		addToCalendarAppURL = PageContext.getPageURL(Pages.DownloadCalendar)+'?action=downloadEventICSFile&contentId=' + contentObj.Id;
    	}
    	
    	return addToCalendarAppURL;
    }
    
    public String getEventICSFileContents(Simpplr_Content__c contentObj) {
    	String fileContents='';
    	String eventStartEndDateTimeFormat;
    	Boolean isSingleDayAllDayEvent = false;
    	String timezone = '';
    	
    	if(contentObj.Event_Is_All_Day__c) {
    		eventStartEndDateTimeFormat = 'yyyyMMdd';
    		if(contentObj.Event_Start_DateTime__c.addDays(1) == contentObj.Event_End_DateTime__c) {
    			isSingleDayAllDayEvent = true;
    		}
    	} else {
    		eventStartEndDateTimeFormat = 'yyyyMMdd\'T\'HHmmss';
    		timezone = 'Z';
    	}
    	
    	fileContents += 'BEGIN:'			+	'VCALENDAR'	+ NEW_LINE +
    					'PRODID:'			+	'-//Simpplr Inc//Simpplr Calendar 70.9054//EN' + NEW_LINE +
    					'VERSION:'			+	'2.0' + NEW_LINE +
    					'CALSCALE:'			+	'GREGORIAN' + NEW_LINE +
    					'METHOD:'			+	'PUBLISH' + NEW_LINE +
    					'BEGIN:'			+	'VEVENT' + NEW_LINE +
    					'DTSTART:'			+	contentObj.Event_Start_DateTime__c.formatGMT(eventStartEndDateTimeFormat) + timezone + NEW_LINE;
    	if(isSingleDayAllDayEvent == false) {
    		fileContents += 'DTEND:'		+	contentObj.Event_End_DateTime__c.formatGMT(eventStartEndDateTimeFormat) + timezone + NEW_LINE;
    	}
    	fileContents +=	'DTSTAMP:'			+	DateTime.now().formatGMT(dateTimeFormat) + NEW_LINE +
    					'CREATED:'			+	contentObj.Publish_Start_DateTime__c.formatGMT(dateTimeFormat) + NEW_LINE +
    					'UID:'				+	uniqueId + NEW_LINE;
    	
    	if(contentObj.Content_Collaborators_Simpplr_Content__r.isEmpty() == false) {
    		Content_Collaborator__c firstOrganizer = contentObj.Content_Collaborators_Simpplr_Content__r[0];
    		fileContents +=	'ORGANIZER;CN='	+ firstOrganizer.Collaborator__r.Full_Name__c + 
    						':mailto:' + firstOrganizer.Collaborator__r.Email__c + NEW_LINE;
    	}
    	
    	fileContents +=	'LOCATION:'			+	contentObj.Event_Location__c + NEW_LINE +
    					'SUMMARY:'			+	contentObj.Title__c + NEW_LINE +
    					'DESCRIPTION:'		+	getDescription(contentObj, FILE_LINE_BREAK, false) + NEW_LINE +
    					'LAST-MODIFIED:'	+	contentObj.Last_Edited_DateTime__c.formatGMT(dateTimeFormat) + NEW_LINE +
    					'SEQUENCE:'			+	'1' + NEW_LINE +
    					'STATUS:'			+	'CONFIRMED' + NEW_LINE +
    					'TRANSP:'			+	'OPAQUE' + NEW_LINE +
						'BEGIN:'			+	'VALARM' + NEW_LINE +
						'ACTION:'			+	'DISPLAY' + NEW_LINE +
						'DESCRIPTION:'		+	'REMINDER:' + NEW_LINE +
						'TRIGGER:'			+	'-PT10M' + NEW_LINE +
						'END:'				+	'VALARM' + NEW_LINE +
    					'END:'				+	'VEVENT' + NEW_LINE +
    					'END:'				+	'VCALENDAR' + NEW_LINE;
    					
    	return fileContents;
    }
    
    private String getDescription(Simpplr_Content__c contentObj, String lineBreak, Boolean encodeData) {
		String COMMA = '';
		String colon;
		String description = 'Author';
		if(encodeData) { 
			colon = '%3A';
			description += colon + lineBreak + EncodingUtil.urlEncode(contentObj.Primary_Author__r.Full_Name__c + ' ( ' + contentObj.Primary_Author__r.Email__c + ')', 'UTF-8');
		} else {
			colon = ':';
			description += colon + lineBreak + contentObj.Primary_Author__r.Full_Name__c + '(' + contentObj.Primary_Author__r.Email__c + ')';
		}
		if(contentObj.Content_Collaborators_Simpplr_Content__r != null &&
				 contentObj.Content_Collaborators_Simpplr_Content__r.isEmpty() == false) {		 
			Integer index=1;	
			
			if(contentObj.Content_Collaborators_Simpplr_Content__r.size() > 1) {
				description += lineBreak + lineBreak +'Organizers' + colon + lineBreak; 				 
			} else {
				description += lineBreak + lineBreak +'Organizer' + colon + lineBreak;
			}
			
			for(Content_Collaborator__c organizer : contentObj.Content_Collaborators_Simpplr_Content__r) {
				if(encodeData) { 
	    			description +=	EncodingUtil.urlEncode(COMMA + organizer.Collaborator__r.Full_Name__c + ' (' + organizer.Collaborator__r.Email__c + ')', 'UTF-8');
				} else {
					description +=	COMMA + organizer.Collaborator__r.Full_Name__c + ' (' + organizer.Collaborator__r.Email__c + ')';
				}
				COMMA = ', ';
			}
    	}
    	
    	description +=	lineBreak + lineBreak + 'Summary'  + colon + lineBreak;
    	if(String.isNotBlank(contentObj.Display_Excerpt__c)) {
	    	if(encodeData) {
	    	 	description += EncodingUtil.urlEncode(contentObj.Display_Excerpt__c, 'UTF-8');
	    	} else {
	    		description += contentObj.Display_Excerpt__c;
	    	}
    	}
    	
    	description +=	lineBreak + lineBreak;
        String eventURL = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentObj.site__c+'/event/'+contentObj.Id;
        
    	if(encodeData) {
    		description += EncodingUtil.urlEncode(eventURL, 'UTF-8');
    	} else {
    		description += eventURL;
    	}
    	
    	return description;
	}
	
	public String getOffice365WebUrl(Simpplr_Content__c contentObj, String baseURL) {
	String office365dateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
    	String office365WebUrl 	=	baseURL+'/owa?rru=addevent&' +
    								'subject='	+	EncodingUtil.urlEncode(contentObj.Title__c, 'UTF-8');
    	
		office365WebUrl +=	   		'&startdt='	+	contentObj.Event_Start_DateTime__c.formatGMT(office365dateTimeFormat) + 'Z';

		
		if(contentObj.Event_Is_All_Day__c) {			
			office365WebUrl += '&enddt='	+	contentObj.Event_End_DateTime__c.addSeconds(1).formatGMT(office365dateTimeFormat) + 'Z' 
							+ '&allday='	+	'true';  						
										
		} else {
			office365WebUrl += '&enddt='	+	contentObj.Event_End_DateTime__c.formatGMT(office365dateTimeFormat) + 'Z' 
							+ '&allday='	+	'false';

		}
    	
    	office365WebUrl +=			'&location='	+	EncodingUtil.urlEncode(contentObj.Event_Location__c, 'UTF-8') +
    								'&body='	+	getDescription(contentObj, Office365_LINE_BREAK, true) +
    								'&uid='			+	uniqueId +
    								'&path='		+	'/calendar/action/compose';
    								
    								
    	return office365WebUrl;
    }
}