public with sharing class FilePreviewDataServer extends DataServer {
	
	public override void handleRequest () {
		try { 
			String fileId = readParam('fileId');
			String base64Data = '';
			
			if (fileId != null) {
				base64Data = getBase64ForContent(fileId);
			}
			
			response =  buildResponseWrapper('success', 'Successfully feteched base64 data.', base64Data);
		
		} catch (Exception ex) {
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
	} 
	
	private String getBase64ForContent (String fileId) {
		try {
			String base64Data = '';
			List<ContentVersion> listOfContentVersion = [SELECT VersionData, 
					ContentSize 
					From ContentVersion
					WHERE Id=:fileId WITH SECURITY_ENFORCED]; 
					
			if (!listOfContentVersion.isEmpty()) {
				base64Data = EncodingUtil.base64Encode(listOfContentVersion[0].VersionData);
				base64Data = 'data:application/pdf;base64,' + base64Data;
			}
			
			return base64Data;
		
		} catch (Exception e) {
			throw e; 
		}
	}
	
}