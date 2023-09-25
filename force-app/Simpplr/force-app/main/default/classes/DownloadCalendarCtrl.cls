public with sharing class DownloadCalendarCtrl extends BaseCtrl {
    public transient string outputText {set; get;}
    public transient string fileName {set; get;}
    
    private final String ACTION_VALUE_DOWNLOAD_EVENT_ICS_FILE = 'downloadEventICSFile';
    private final String REQUEST_PARAM_ACTION = 'action';
    
    public PageReference handleRequest() {
    	PageReference returnPage = null;
    	String action = readParam(REQUEST_PARAM_ACTION);
    	if(ACTION_VALUE_DOWNLOAD_EVENT_ICS_FILE.equalsIgnoreCase(action)) {
        	outputText = getEventICSFileContents();
    	} else {
    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	} 
    	return returnPage;
    }
    
    public override String getPageFeature() {
    	return AccessManager.FEATURE_EVENT;
    }
    
    public String getEventICSFileContents() {
    	String contentId = readParam('contentId');
    	List<Simpplr_Content__c> listOfSimpplrContents = [select id, Site__c, Title__c, Display_Excerpt__c, Event_Location__c,Event_Is_All_Day__c,
    													Publish_Start_DateTime__c, Last_Edited_DateTime__c,
    													Event_Start_DateTime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c,
    													Primary_Author__r.Full_Name__c, Primary_Author__r.Email__c, 
    													(select Collaborator__r.Full_Name__c, Collaborator__r.Email__c
    															from Content_Collaborators_Simpplr_Content__r
    															where Type__c=:ServiceConstants.EVENT_ORGANIZER 
    															And Is_Deleted__C = false) 
    													from Simpplr_Content__c 
    													where Id=:contentId WITH SECURITY_ENFORCED];
    	if(listOfSimpplrContents.isEmpty()) {
    		throw new SimpplrException(ServiceConstants.ERROR_500);
    	}
    	fileName = listOfSimpplrContents[0].title__c.length() > 100 ? listOfSimpplrContents[0].title__c.subString(0,100) : listOfSimpplrContents[0].title__c;
    	fileName = fileName.replaceAll('"','""').replaceAll(',','').replaceAll('#','_').replaceAll(' ','_');
    	String fileContents = new CalendarUtility().getEventICSFileContents(listOfSimpplrContents[0]);
    	return fileContents;
	}
	
	
}