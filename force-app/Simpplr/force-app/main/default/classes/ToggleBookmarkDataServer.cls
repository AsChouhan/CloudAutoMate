public with sharing class ToggleBookmarkDataServer extends DataServer {
	
	public override void handleRequest(){
		try {
			response = new ResponseWrapper();
			String action = readSafeParam('action');
			String recordId = readSafeParam('recordId');
			String peopleId = readSafeParam('peopleId');
			String siteId = readSafeParam('siteId');
			String context = readSafeParam('context');
			
			String simpplrContentPrefix = Utility.getSimpplrContentPrefix();
			
			if (String.isNotBlank(action) && action.equalsIgnoreCase('addfavorite') &&
				String.isNotBlank(siteId)) {
					
				Boolean isSuccess = addSiteFavorite(siteId);
				response = buildResponseWrapper('success', null, isSuccess);
				
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('removefavorite') &&
					String.isNotBlank(siteId)) {
				
				Boolean isSuccess = removeSitefavorite(siteId);
				response = buildResponseWrapper('success', null, isSuccess);
				
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('bookmark') && String.isNotBlank(recordId) && recordId.startsWith(simpplrContentPrefix)) {
				Boolean isSuccess = bookmarkContent(recordId);
				response = buildResponseWrapper('success', null, isSuccess);
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('unbookmark') && String.isNotBlank(recordId) && recordId.startsWith(simpplrContentPrefix)) {
				Boolean isSuccess = unBookmarkContent(recordId);
				response = buildResponseWrapper('success', null, isSuccess);
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('bookmark') && String.isNotBlank(recordId)) {
				Boolean isSuccess = bookmarkFile(recordId, context);
				response = buildResponseWrapper('success', null, isSuccess);
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('unbookmark') && String.isNotBlank(recordId)) {
				Boolean isSuccess = unBookmarkFile(recordId, context);
				response = buildResponseWrapper('success', null, isSuccess);						
			
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('favoritepeople') &&
					peopleId != null) {
				Boolean isSuccess = favoritePeople(peopleId);
				response = buildResponseWrapper('success', null, isSuccess);						
				
			} else if (String.isNotBlank(action) && action.equalsIgnoreCase('unfavoritepeople') && 
					peopleId != null) {
				Boolean isSuccess = unfavoritePeople(peopleId);
				response = buildResponseWrapper('success', null, isSuccess);						
			
			} else{
				throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
			}
		}catch(Exception ex){
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		
	}
	
	private Boolean addSiteFavorite (String siteIdArg) {
		
		List<Simpplr_Site__c> listOfSimpplrSite =  [SELECT Id, name	FROM Simpplr_Site__c WHERE Id=:siteIdArg WITH SECURITY_ENFORCED];
		String siteOwnerId = SiteContext.currentChatterGroup.ownerId;
		List<String> userIdList = new List<String>();
		userIdList.add(siteOwnerId);
		List<String> getPeopleIdList = Utility.getPeopleIdList(userIdList);
		String peopleIdArg = getPeopleIdList[0];
		
		List<Bookmark__c> listOfFavorite =  new List<Bookmark__c> ();
    	listOfFavorite = [SELECT Is_Deleted__c, Type__c, People__c, Id, Name, Bookmark_Receiver__c FROM Bookmark__c 
    							WHERE Simpplr_Site__c =:siteIdArg 
    								AND People__c =:UserContext.getCurrentUserInfo.Id 
    								AND Type__c='Site' WITH SECURITY_ENFORCED];
    			
    	if (!listOfFavorite.isEmpty()) {
	    		for(Bookmark__c bookmarkObj : listOfFavorite){
		    		if(bookmarkObj.Is_Deleted__c == true){
			    		bookmarkObj.Is_Deleted__c = false;
			    		bookmarkObj.Name = listOfSimpplrSite[0].Name;
			    		bookmarkObj.Bookmark_Receiver__c=peopleIdArg;
		    		}
		    	} 
	    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   				SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfFavorite), new List<Schema.SObjectField>{Bookmark__c.Bookmark_Receiver__c, 
   																														  Bookmark__c.Is_Deleted__c, 
   																														  Bookmark__c.Name});
    	} else {
    		Bookmark__c  favouriteObj = new Bookmark__c();
    		favouriteObj.Simpplr_Site__c = siteIdArg;
    		favouriteObj.People__c = UserContext.getCurrentUserInfo.Id;
    		favouriteObj.Type__c = 'Site';
    		favouriteObj.Is_Deleted__c = false;
    		favouriteObj.Bookmark_Receiver__c = peopleIdArg;
    		favouriteObj.Name = listOfSimpplrSite[0].Name;
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		   	SIMPESAPI.accessController().insertAsUser(favouriteObj,
		   			new List<Schema.SObjectField>{Bookmark__c.Name, Bookmark__c.Simpplr_Site__c, Bookmark__c.People__c, Bookmark__c.Type__c, Bookmark__c.Bookmark_Receiver__c,Bookmark__c.Is_Deleted__c}); 
    	}
		return true ;
	}
	
	private Boolean removeSitefavorite (String siteIdArg) {
		List<Bookmark__c> listOfBookmark = [SELECT Id, Is_Deleted__c, Simpplr_Site__c 
											FROM Bookmark__c 
											WHERE Simpplr_Site__c =: siteIdArg
											AND People__c =: UserContext.getCurrentUserInfo.Id AND Is_Deleted__c = false WITH SECURITY_ENFORCED]; 
		if (!listOfBookmark.isEmpty()) {
			for(Bookmark__c bookMarkObj : listOfBookmark){
				bookMarkObj.Is_Deleted__c = true;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfBookmark), new List<Schema.SObjectField>{
        			Bookmark__c.Is_Deleted__c});

   			return true;
   			
		} else {
			return false;
		}
	}
	
	private Boolean bookmarkFile (String fileIdArg, String context) {
		Boolean success = true;
		if('box'.equalsIgnoreCase(context)) {
			success = new BoxDao().bookmarkFile(fileIdArg);
		} else if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(context)) {
			ResponseWrapper gResponseObj = new GoogleDriveService().bookmarkFile(fileIdArg);
			logger.logDebug('gResponseObj'+ gResponseObj.result);
		
			if (gResponseObj == null) {
				success = false;
				throw new  SimpplrException('Not able to bookmark file');
			}

		}
		List<Bookmark__c> listOfBookmark = [SELECT Id, Is_Deleted__c 
											FROM Bookmark__c 
											WHERE External_File_Id__c =: fileIdArg
											And Type__c = :context
											And People__c =: UserContext.getCurrentUserInfo.Id WITH SECURITY_ENFORCED]; 
		if (success){ 
			if(listOfBookmark.isEmpty()){
				String receiverPeopleId;
				if(!'box'.equalsIgnoreCase(context) || !ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equals(context) || !ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equals(context)) {
					receiverPeopleId = getFileOwnerPeopleId(fileIdArg);
				}
				Bookmark__c  favouriteObj = new Bookmark__c(External_File_Id__c = fileIdArg,
															Type__c = context,
															Is_Deleted__c = false, 
															People__c = UserContext.getCurrentUserInfo.Id,
															Bookmark_Receiver__c = receiverPeopleId);
						
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		   		SIMPESAPI.accessController().insertAsUser(favouriteObj,
		   												new List<Schema.SObjectField>{
		   													Bookmark__c.External_File_Id__c,
		   													Bookmark__c.Type__c, 
		   													Bookmark__c.People__c,
		   													Bookmark__c.Is_Deleted__c,
		   													Bookmark__c.Bookmark_Receiver__c});
			} else {
				for(Bookmark__c bookMarkObj : listOfBookmark){
					if(bookMarkObj.Is_Deleted__c == true){
						bookMarkObj.Is_Deleted__c = false;
					}
				}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   			SIMPESAPI.accessController().updateAsUser(new Map<Id, Bookmark__c>(listOfBookmark),
		   												new List<Schema.SObjectField>{Bookmark__c.Is_Deleted__c});
			}

		} else {
			success = false;
		}
		
		return success;
	}
	
	private String getFileOwnerPeopleId(String fileIdArg) {
		String ownerPeopleId;
		String queryStr = 'Select OwnerId From ContentDocument where id =:fileIdArg';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND LatestPublishedVersion.networkid = null';
    	}
    	
		List<ContentDocument> listOfContentDocument = Database.query(queryStr);
		if(!listOfContentDocument.isEmpty()) {
			List<String> listOfPeopleId = Utility.getPeopleIdList(new List<String>{listOfContentDocument[0].OwnerId});
			if(!listOfPeopleId.isEmpty()) {
				ownerPeopleId = listOfPeopleId[0];
			}
		}
		return ownerPeopleId;
	}
	
	private Boolean unbookmarkFile (String fileIdArg, String context) {
		Boolean success = true;
		if('box'.equalsIgnoreCase(context)) {
			success = new BoxDao().unbookmarkFile(fileIdArg);
		} else if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(context)) {
			ResponseWrapper gResponseObj = new GoogleDriveService().unbookmarkFile(fileIdArg);
			logger.logDebug('gResponseObj'+ gResponseObj.result);
		
			if (gResponseObj == null) {
				success = false;
				throw new  SimpplrException('Not able to unbookmark file');
			}
		}
		List<Bookmark__c> listOfBookmark = [SELECT Id , Is_Deleted__c
											FROM Bookmark__c 
											WHERE External_File_Id__c =: fileIdArg
											And Type__c = :context
											And Is_Deleted__c = false
											And People__c =: UserContext.getCurrentUserInfo.Id WITH SECURITY_ENFORCED]; 
		if (success && !listOfBookmark.isEmpty()) {
			for(Bookmark__c bookmarkObj : listOfBookmark){
		    	bookmarkObj.Is_Deleted__c = true;
	    	}
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfBookmark), new List<Schema.SObjectField>{Bookmark__c.Is_Deleted__c});

		} else {
			success = false;
		}
		
		return success;
	}
	
		/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	private Boolean bookmarkContent (String contentIdArg) {
		
		List<Simpplr_content__c> listOfSimpplrContent = [SELECT Id, Type__c,Title__c,CreatedById,Site__c FROM Simpplr_content__c WHERE id=:contentIdArg WITH SECURITY_ENFORCED];
		if(listOfSimpplrContent.isEmpty()){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		List<String> userIdList = new List<String>();
		userIdList.add(listOfSimpplrContent[0].CreatedById);
		List<String> getPeopleIdList = Utility.getPeopleIdList(userIdList);
		String peopleIdArg = getPeopleIdList[0];
		String bookmarkName = listOfSimpplrContent[0].Title__c.length() > 80 ? listOfSimpplrContent[0].Title__c.subString(0,80) : listOfSimpplrContent[0].Title__c;
		
		List<Bookmark__c> listOfFavorite =  new List<Bookmark__c> ();
    	listOfFavorite = [SELECT Is_Deleted__c, Name, Type__c, People__c, Id, Bookmark_Receiver__c 
    			FROM Bookmark__c 
    			WHERE  People__c =:UserContext.getCurrentUserInfo.Id
    			AND Type__c=: listOfSimpplrContent[0].Type__c AND Simpplr_Content__c =:listOfSimpplrContent[0].Id WITH SECURITY_ENFORCED];
    			
    	if (!listOfFavorite.isEmpty()) {
    		for(Bookmark__c bookmarkObj : listOfFavorite){
    			if(bookmarkObj.Is_Deleted__c == true){
    				bookmarkObj.Name = bookmarkName;
    				bookmarkObj.Bookmark_Receiver__c = peopleIdArg;
		    		bookmarkObj.Is_Deleted__c = false;
    			}
	    	}
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfFavorite), new List<Schema.SObjectField>{
    																									Bookmark__c.Bookmark_Receiver__c, 
    																									Bookmark__c.Is_Deleted__c, 
    																									Bookmark__c.Name});
    		
    	} else {
    		Bookmark__c  favouriteObj = new Bookmark__c();
    		favouriteObj.Simpplr_Site__c = listOfSimpplrContent[0].Site__c;
    		favouriteObj.Simpplr_Content__c = listOfSimpplrContent[0].Id;
    		favouriteObj.People__c = UserContext.getCurrentUserInfo.Id;
    		favouriteObj.Name = bookmarkName;
    		favouriteObj.Type__c = listOfSimpplrContent[0].Type__c;
    		favouriteObj.Is_Deleted__c = false;
    		favouriteObj.Bookmark_Receiver__c = peopleIdArg;
    		favouriteObj.Name = bookmarkName;
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		   	SIMPESAPI.accessController().insertAsUser(favouriteObj,
		   			new List<Schema.SObjectField>{Bookmark__c.Name, Bookmark__c.Simpplr_Site__c, Bookmark__c.Simpplr_Content__c, Bookmark__c.People__c, Bookmark__c.Type__c, Bookmark__c.Bookmark_Receiver__c,Bookmark__c.Is_Deleted__c}); 
    	}
		return true;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	private Boolean unBookmarkContent (String contentIdArg) {
		List<Simpplr_Content__c> contentList = [Select Id from Simpplr_Content__c where Id =: contentIdArg];
		if(contentList.isEmpty()){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
			
		List<Bookmark__c> listOfBookmark = [SELECT Id, Is_Deleted__c, Simpplr_Content__c FROM Bookmark__c 
				WHERE People__c =: UserContext.getCurrentUserInfo.Id AND Simpplr_Content__c=:contentIdArg AND Is_Deleted__c = false WITH SECURITY_ENFORCED]; 
				
		if (!listOfBookmark.isEmpty()) {
			for(Bookmark__c bookmarkObj : listOfBookmark){
		    	bookmarkObj.Is_Deleted__c = true;
	    	}
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfBookmark), new List<Schema.SObjectField>{Bookmark__c.Is_Deleted__c});

   			return true;
   			
		} else {
			return false;
		}
	}
	
	private Boolean favoritePeople (String peopleIdArg) {
		List<Bookmark__c> listOfFavorite =  new List<Bookmark__c> ();
    	listOfFavorite = [SELECT Is_Deleted__c, Type__c, People__c, Id, Bookmark_Receiver__c 
    			FROM Bookmark__c 
    			WHERE People__c=:UserContext.peopleId AND Bookmark_Receiver__c=:peopleIdArg
    			AND Type__c='People' WITH SECURITY_ENFORCED];
    	if (!listOfFavorite.isEmpty()) {
    		for(Bookmark__c bookmarkObj : listOfFavorite){
    			if(bookmarkObj.Is_Deleted__c == true){
		    		bookmarkObj.Is_Deleted__c = false;
    			}
	    	}
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfFavorite), new List<Schema.SObjectField>{
    																									Bookmark__c.Is_Deleted__c});
    		
    	} else {
    		Bookmark__c  favouriteObj = new Bookmark__c();
    		favouriteObj.People__c = UserContext.peopleId;
    		favouriteObj.Type__c = 'People';
    		favouriteObj.Is_Deleted__c = false;
    		favouriteObj.Bookmark_Receiver__c = peopleIdArg;
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		   	SIMPESAPI.accessController().insertAsUser(favouriteObj,
		   			new List<Schema.SObjectField>{Bookmark__c.People__c, Bookmark__c.Bookmark_Receiver__c,Bookmark__c.Is_Deleted__c, 
		   			Bookmark__c.Type__c}); 
    	}
    	return true;
	}
	
	private Boolean unfavoritePeople (String peopleIdArg) {
		List<Bookmark__c> listOfFavorite =  new List<Bookmark__c> ();
    	listOfFavorite = [SELECT Type__c, Is_Deleted__c, People__c, Id, Bookmark_Receiver__c 
    			FROM Bookmark__c 
    			WHERE People__c=:UserContext.peopleId AND Bookmark_Receiver__c=:peopleIdArg
    			AND Type__c='People' AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
    	
    	if (!listOfFavorite.isEmpty()) {
    		for(Bookmark__c bookmarkObj :listOfFavorite){
	    		bookmarkObj.Is_Deleted__c = true;
	    	}
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
   			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfFavorite), new List<Schema.SObjectField>{
        			Bookmark__c.Is_Deleted__c});
   			return true;
   			
    	} else {
    		return false;
    	}
	}
}