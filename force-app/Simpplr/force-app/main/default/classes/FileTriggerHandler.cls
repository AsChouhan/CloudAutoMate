public with sharing class FileTriggerHandler {
    public void OnAfterInsert(List<File__c> fileList){
		OnAfterInsertOrUpdate(fileList);
	}
	
	public void OnAfterUpdate(List<File__c> fileList){
		OnAfterInsertOrUpdate(fileList);
	}
	 
    private void OnAfterInsertOrUpdate(List<File__c> fileList) {
		List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        
			for (File__c fileObj : fileList) {
                if('native_video'.containsIgnoreCase(fileObj.Repository__c) || 'native_video'.containsIgnoreCase(fileObj.Video_Provider__c)) {
                    External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
                    obj.File__c = fileObj.id;
                    obj.Type__c = 'native_video';
                    listToInsert.add(obj);
                }
			} 
            if(listToInsert.size() > 0) {

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
					External_Search_Data_Trail__c.File__c,
					External_Search_Data_Trail__c.Type__c});
			}    
           
	}
}