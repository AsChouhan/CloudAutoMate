public with sharing class ContentDocumentLinkTriggerHandler {
    public void OnAfterInsert(List<ContentDocumentLink> contentDocumentLinkList){
   		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
   		if(SimpplrContext.isExternalSearchAppConnected){
   			updateSearchTrailObjectForCdl(contentDocumentLinkList);
   		}
   	}
   	
   	public void OnAfterDelete(List<ContentDocumentLink> contentDocumentLinkList){
   		if(SimpplrContext.isExternalSearchAppConnected){
   			updateSearchTrailObjectForCdl(contentDocumentLinkList);
   		}
   	}
   	
   	private void updateSearchTrailObjectForCdl(List<ContentDocumentLink> contentDocumentLinkList){
   		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();

        for(contentDocumentLink cdl : contentDocumentLinkList) {
			String linkedEntityId = cdl.LinkedEntityId;
			if(linkedEntityId.startsWith('0F9')){
                External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
				obj.Content_Document__c = cdl.ContentDocumentId;
				obj.Type__c = 'ContentDocumentLink';
				listToInsert.add(obj);
				
			}
		}

		if(listToInsert.isEmpty() == false){
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
				External_Search_Data_Trail__c.Content_Document__c,
				External_Search_Data_Trail__c.Type__c});
		}

   	}
}