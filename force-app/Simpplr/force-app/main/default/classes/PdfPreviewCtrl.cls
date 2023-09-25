public with sharing class PdfPreviewCtrl extends BaseCtrl {
    public FileWrapper fileWrapObj {get;set;}
    public Boolean usePDFJsStdReq {get;set;}
    public override String getPageFeature () {
    	return AccessManager.FEATURE_FILE;
   	}
   	
   	public String packagePrefix {
		get {
			String packageName = String.isNotBlank(SimpplrContext.packageName) ? (SimpplrContext.packageName + '__') : '';
			return packageName;
		} 
	}

	/**
	* @description fetch new token based on session and create/update cookie
	* @return String token
	**/
	public String csrfToken { 
		get {
			if(String.isBlank(csrfToken)){
				csrfToken = AccessManager.getCsrfToken();
				AccessManager.manageCookieCsrf(csrfToken);
			}
			return csrfToken;
		} private set; 
	}
   	
   	public PageReference init () {
   		usePDFJsStdReq = false;
   		PageReference returnPage = null;
   		fileWrapObj = new FileWrapper();
   		fileWrapObj.id = readParam('fileId');
   		
   		fileWrapObj.type = readParam('type');
   		fileWrapObj.provider = readParam('provider');
   		fileWrapObj.fileUrl = readParam('folderPath');
   		fileWrapObj.size = readParam('fileSize');
   		
		   if (fileWrapObj.provider != null && 
		   		('Intranet'.equalsIgnoreCase(fileWrapObj.provider) || 'CRM'.equalsIgnoreCase(fileWrapObj.provider)) &&
   				fileWrapObj.type != null && ((FileDetailCtrl.INTRANET_FILES_NON_PDF_PREVIEW_SET.contains(fileWrapObj.type)) ||
   				(fileWrapObj.type == 'PDF' && Integer.valueOf(fileWrapObj.size) > 3000000))) {
   			usePDFJsStdReq = true;
   		}
   		
   		return returnPage;
   	}
	
	public Class FileWrapper {
		public String id {get;set;}
		public String type {get;set;}
		public String provider {get;set;}
		public String size {get;set;}
		public String fileUrl {get;set;}
 	}  
}