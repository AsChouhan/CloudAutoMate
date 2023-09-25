public with sharing class ContentDocumentTriggerHandler {
    public void OnAfterUpdate(List<ContentDocument> contentDocumentList){
   		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
   		if(SimpplrContext.isExternalSearchAppConnected){
   			for(ContentDocument cd : contentDocumentList) {
                if(!setOfFileExtensionToIgnore.contains(cd.FileType) && 
                        String.isNotBlank(cd.FileType) && 
                        !SimpplrContext.skipContentDocTrigger){
                    External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
                    obj.Content_Document__c = cd.Id;
                    obj.Type__c = 'ContentDocument';
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
   	
   	public void OnBeforeDelete(List<ContentDocument> contentDocumentList){

   		if (!contentDocumentList.isEmpty()) {
            Set<Id> contentDocumentIdSet = new Set<Id>();
            
			for(ContentDocument contentDocObj : contentDocumentList) {
                contentDocumentIdSet.add(contentDocObj.Id);
            }
            if(System.isFuture() || System.isBatch()){
                FileDao.markFileDeleted(contentDocumentIdSet);
                
            } else {
                FileDao.markFileDeletedInFuture(contentDocumentIdSet);    
            }
		}
    }

    public void OnAfterDelete(List<ContentDocument> contentDocumentList){
        List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();

   		if (!contentDocumentList.isEmpty()) {
            
			for (ContentDocument contentDocObj : contentDocumentList) {

                if (SimpplrContext.isExternalSearchAppConnected && 
                        !setOfFileExtensionToIgnore.contains(contentDocObj.FileType) && 
                        String.isNotBlank(contentDocObj.FileType) && 
                        !SimpplrContext.skipContentDocTrigger){
                    External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
                    obj.Content_Document__c = contentDocObj.Id;
                    obj.Type__c = 'ContentDocument';
                    listToInsert.add(obj);
                }
                
            }
            
            if (!listToInsert.isEmpty()) {

                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
                    External_Search_Data_Trail__c.Content_Document__c,
                    External_Search_Data_Trail__c.Type__c});
            }
			
		}
    }

   	private Set<String> setOfFileExtensionToIgnore{get{
		return new Set<String>{'JPG','GIF','PNG','JPEG'};
	}}
}