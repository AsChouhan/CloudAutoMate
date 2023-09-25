public class PushExternalData {
 
   @InvocableMethod(label='Push External Data')
   public static void pushToAWS(List<Id> propertyId) { 
       
        if (!SimpplrContext.isFlowExternalSearchEnabled) {
            return;
        }
	   
	    if (!Utility.isSmartSearchTokenValid()) {
	   		Utility.resetSmartSearch();
	   		return;
	    }
	   
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', propertyId[0]);
        String esdtQuery = 'SELECT Id, ' +
            ' People__c, People_Category__c, Content_Document__c, Site_Category__c, ' +
            ' Pages_Category__c, site__c, Content__c, Type__c, Site_Role__c, Expertise__c, Topic__c, ' +
            ' Site_Membership_Request__c, Mailer__c, Tiles_Config__c,' +
            ' Merge_To__c, Merge_From__c, Event_RSVP_Response__c, Alert__c, File__c, Segment__c, Content_Template__c, ' +
            ' Must_Read_Audit__c, Must_Read_Confirm_History__c ' +
            ' FROM External_Search_Data_Trail__c ' +
            ' WHERE Id =: soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<External_Search_Data_Trail__c> listOfDataTrailObj = (List<External_Search_Data_Trail__c>)SIMPESAPI.accessController().queryAsUser(esdtQuery, soqlParamMap);
	   
	   List<ExternalSearchWrapper.SearchDataWrapper> listOfObjectsToBePassed;
	   PushDataHelperForExternalSearch pushDataHelperObj = new PushDataHelperForExternalSearch();
	   ExternalSearchWrapper.CategoryWrapper catObj;
	   String body ;
       String recordType;
	   
	   for(External_Search_Data_Trail__c trailObj : listOfDataTrailObj){
            String upsertType = 'upsert';

   			if('People'.equalsIgnoreCase(trailObj.Type__c)){
 				body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForPeople(trailObj.People__c));
	   		
	   		} else if('Site'.equalsIgnoreCase(trailObj.Type__c)){
	   			body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForSite(trailObj.Site__c));
	   		
	   		} else if('Content'.equalsIgnoreCase(trailObj.Type__c)){
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForSimpplrContent(trailObj.Content__c));
            
            } else if('Content_Template'.equalsIgnoreCase(trailObj.Type__c)){
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForContentTemplate(trailObj.Content_Template__c));
            
            } else if('Event_RSVP_Response'.equalsIgnoreCase(trailObj.Type__c)){
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForEventRSVPResponse(trailObj.Event_RSVP_Response__c));
            
            } else if('ContentDocument'.equalsIgnoreCase(trailObj.Type__c)){
	   			body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForContentDocument(trailObj.Content_Document__c));
               
            } else if('People_Category'.equalsIgnoreCase(trailObj.Type__c)){
	   			body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForPeopleCategory(trailObj.People_Category__c));
   			
   			} else if('Site_Category'.equalsIgnoreCase(trailObj.Type__c)){
	   			body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForSiteCategory(trailObj.Site_Category__c));
   			
   			} else if('Pages_Category'.equalsIgnoreCase(trailObj.Type__c)){
	   			body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForPagesCategory(trailObj.Pages_Category__c));
            
            } else if('ContentDocumentLink'.equalsIgnoreCase(trailObj.Type__c)){
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForContentDocument(trailObj.Content_Document__c));
            
            } else if  ('Site_Role'.equalsIgnoreCase(trailObj.Type__c)) {
                ExternalSearchWrapper.SiteRole resp = pushDataHelperObj.getSearchDataWrapperForSiteRole(trailObj.Site_Role__c);
                if(resp != null) {
                    body = JSON.serialize(resp);
                } else {
                    body = null;
                }
            
            } else if  ('Site_Membership_Request'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapForSiteMembershipReq(trailObj.Site_Membership_Request__c));
            
            } else if  ('Expertise'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForExpertise(trailObj.Expertise__c));
            } else if  ('Alert'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForAlert(trailObj.Alert__c));
            
            } else if  ('Merge_Expertise'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForMergeExpertise(trailObj.Merge_To__c, trailObj.Merge_From__c));
                
            } else if  ('Topic'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForTopic(trailObj.Topic__c));
            
            } else if  ('Merge_Topic'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForMergeTopic(trailObj.Merge_To__c, trailObj.Merge_From__c));
            
            } else if  ('Newsletter'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapForNewsletter(trailObj.Mailer__c));
            
            } else if  ('native_video'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForNativeVideo(trailObj.File__c));
            
            } else if  ('Links'.equalsIgnoreCase(trailObj.Type__c)) {
                body = JSON.serialize(pushDataHelperObj.getSearchDataWrapperForLinks(trailObj.Segment__c));
                upsertType = 'upsert_many';
            } else if  ('Tiles'.equalsIgnoreCase(trailObj.Type__c)) {
                ExternalSearchWrapper.TilesConfig resp = pushDataHelperObj.getSearchDataWrapperForTilesConfig(trailObj.Tiles_Config__c);
                if(resp != null) {
                    body = JSON.serialize(resp);
                } else {
                    body = null;
                }
            
            } else if  ('Must_Read'.equalsIgnoreCase(trailObj.Type__c)) {
                ExternalSearchWrapper.MustReadAudit resp = pushDataHelperObj.getSearchDataWrapperForMustReadContentConfig(trailObj.Must_Read_Audit__c);
                if(resp != null) {
                    body = JSON.serialize(resp);
                } else {
                    body = null;
                }
                
            } else if  ('Must_Read_Confirm_History'.equalsIgnoreCase(trailObj.Type__c)) {
                ExternalSearchWrapper.MustReadConfirmHistory resp = pushDataHelperObj.getSearchDataWrapperForMustReadConfirmHistoryConfig(trailObj.Must_Read_Confirm_History__c);
                if(resp != null) {
                    body = JSON.serialize(resp);
                } else {
                    body = null;
                }
            
            }

	   		if (String.isNotBlank(body)) { 
                if ( Limits.getQueueableJobs() != Limits.getLimitQueueableJobs()) {
                    recordType = trailObj.Type__c; 
                    System.enqueueJob(new QueueablePushData(recordType, body, 
                            SearchConstants.APIS_UPSERT, trailObj, upsertType));
	   			} 
	   		} else{
                PushDataHelperForExternalSearch.deleteSearchTrails(new List<Id>{trailObj.Id});
	   		}
	   }
		  
   }
   
   public class QueueablePushData implements System.Queueable, Database.AllowsCallouts {
       private  String body;
       private final String externalEndPoint;
       private final External_Search_Data_Trail__c trailObj;
       private final String objectType;
       private final String upsertType;
       public QueueablePushData(String objectType, String body, 
                String externalEndPoint, External_Search_Data_Trail__c trailObj, String upsertType) {
            this.body = body;
            this.externalEndPoint = externalEndPoint;
            this.trailObj = trailObj;
            this.objectType = objectType;
            this.upsertType = upsertType;
       }
 
       
       
        public void execute(System.QueueableContext ctx) {
            String simpDri = Utility.externalRequestAuthToken() + 
                    ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                    ' ' + UserContext.userId.substring(0, 15);
            String skipFileStr = '';  

            if ('contentdocumentlink'.equalsIgnoreCase(objectType)) {
                skipFileStr = ',"skip_file_download":1';
            
            } else if ('contentdocument'.equalsIgnoreCase(objectType)) {
                skipFileStr = ',"skip_file_download":0';
            }

            String reqBodyStr = '{"data":' + body + ', "base_url":"' + 
                    SimpplrContext.getExternalSearchBaseUrl + '",'+ 
                    ' "org_id":"' + SimpplrContext.simpplrOrgId + '", '+ 
                    ' "newsletter_v2_enabled":' + SimpplrContext.newsletterPlusEnabled + ', '+ 
                    ' "request_path":"'+ upsertType +'", "instance_url":"' + 
                    SimpplrContext.salesforceHost + '" '+ skipFileStr + '}';

            HttpRequest req = new HttpRequest();
            req.setEndpoint(externalEndPoint);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('simpplr-dri', simpDri);
            req.setMethod('POST');
            req.setBody(reqBodyStr);
            req.setTimeout(60000);
            
            Http http = new Http();
            HttpResponse res;
            
            if (!Test.isRunningTest()) {
                req.setEndpoint(externalEndPoint);
                res = http.send(req);

                if (res.getStatusCode() == 200){
                    PushDataHelperForExternalSearch.deleteSearchTrails(new List<Id>{trailObj.Id});
                }	

            }

       }

   }
   
}