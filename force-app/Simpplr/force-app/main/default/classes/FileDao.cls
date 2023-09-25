/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FileDao {
	
	
	private final Integer FILE_SHARING_CDL_LIMIT = 90;
	private Map<Id, Integer> FILE_SHARING_CDL_COUNT_MAP = new Map<Id, Integer>();
	
	private final String BOOKMARK_TYPE_INTRANET_FILES = 'Intranet';
	private final String BOOKMARK_TYPE_CRM_FILES = 'CRM';
	private final String BOOKMARK_TYPE_BOX_FILES = 'Box';
	private final String FILE_TYPE_NATIVE_VIDEOS_FILES = 'native_video';
	private final String pathOnClientFilter = '%'+ServiceConstants.REMOVE_FILE_SEARCH_IDENTIFIER+'%';
	 		
	private List<Id> listOfMatchedContentDocumentIds = new List<Id>();
	private List<Id> listOfTitleContentDocumentIds = new List<Id>();
	private List<Id> listOfContentDocumentIdsForSite = new List<Id>();
	private List<Id> listOfTitleImageContentVersionIds = new List<Id>();
	private List<Id> listOfContentDocumentIdsWithoutFolder = new List<Id>();
	
	private Set<List<Id>> toBeDeletedCDLs = new Set<List<Id>>();
	
	List<String> listOfFileNamesToIgnore {get{
		return new List<String>{'%-thumbnail.jpeg', '%-thumbnail.jpg', '%-thumbnail.gif', '%-thumbnail.png',
							   	'%-banner.jpeg', '%-banner.jpg', '%-banner.gif', '%-banner.png'
							   };
	}}
	
	private String getBaseQuery(){
		String baseQueryStr = 'SELECT Id, Title, LatestPublishedVersion.pathOnClient, LatestPublishedVersion.VersionNumber, Owner.name,Owner.id,' +
		 						'LastModifiedDate, LatestPublishedVersionId, ' +
						 		'LatestPublishedVersion.description, LatestPublishedVersion.ContentSize,LatestPublishedVersion.FileExtension,' +
						 		'LatestPublishedVersion.fileType, LatestPublishedVersion.Origin, '+
						 		'(select id, ShareType, LinkedEntity.type, LinkedEntityId from ContentDocumentLinks) ' +
						 		' From ContentDocument Where (not title like: listOfFileNamesToIgnore) ';			
		
		if(SimpplrContext.isCommunitiesEnabled){
    		baseQueryStr += ' AND LatestPublishedVersion.networkid = null ';
    	}
    	
    	return baseQueryStr;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getMyFilesIntranetFiles (Criteria.File fileCriteriaObjArg, String ownerId, Integer recordLimit) {
		
		try {
			String queryStr = getBaseQuery();
			String term = fileCriteriaObjArg.term;
			
			if('image'.equalsIgnoreCase(fileCriteriaObjArg.type)){
				queryStr += ' AND (FileType = \'JPG\' OR FileType = \'JPEG\' OR FileType = \'PNG\' OR FileType = \'GIF\') '; 
			}
			
			if(String.isNotBlank(fileCriteriaObjArg.term)){
				term = '%' + term + '%';
				
				if(fileCriteriaObjArg.fullText == false){
					queryStr += 'And (title like : term)'; 
				}else{
					listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(fileCriteriaObjArg.term);
					queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like : term) ';
				}
			}
			
			if(String.isNotBlank(fileCriteriaObjArg.siteId) && !'all'.equalsIgnoreCase(fileCriteriaObjArg.siteId)){
				listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(fileCriteriaObjArg.siteId);
				queryStr += 'And  id=: listOfContentDocumentIdsForSite ';
			}
			
			if(String.isNotBlank(ownerId)) {
				queryStr += 'And  Owner.Id = :ownerId ';
			}
			
			if(String.isNotBlank(fileCriteriaObjArg.filter)) {
				queryStr += getFilterCondition(fileCriteriaObjArg.filter);
			}
			
			listOfTitleImageContentVersionIds = getTitleImageContentVersionIds(fileCriteriaObjArg.siteId);
			queryStr += 'And LatestPublishedVersionId != :listOfTitleImageContentVersionIds ';
			queryStr += 'And LatestPublishedVersion.Origin = \'H\' ';
			queryStr += getSortOrderCondition(fileCriteriaObjArg.sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+ fileCriteriaObjArg.offset;
			
			logger.logDebug('getMyFilesIntranetFiles -- queryStr :: ' + queryStr);
            return Database.query(queryStr);
			
		} catch (Exception e) {
			throw e;
		}
	}
	
	private String getFilterCondition(String filterArg) {
		String filterCondition = '';
		
		if('this_week'.equalsIgnoreCase(filterArg)) {
			filterCondition = 'And  LastModifiedDate = THIS_WEEK ';
		}
		else if('last_week'.equalsIgnoreCase(filterArg)) {
			filterCondition = 'And  LastModifiedDate = LAST_WEEK ';
		}
		else if('this_month'.equalsIgnoreCase(filterArg)) {
			filterCondition = 'And  LastModifiedDate = THIS_MONTH ';
		}
		
		return filterCondition;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getMyFilesCRMLibFiles (Criteria.File fileCriteriaObjArg, String ownerId) {
		
		try {
			String queryStr = getBaseQuery();
			Integer recordLimit = fileCriteriaObjArg.size + 1;
			String term = fileCriteriaObjArg.term;
			
			if(String.isNotBlank(fileCriteriaObjArg.term)){
				term = '%' + term + '%';
				
				if(fileCriteriaObjArg.fullText == false){
					queryStr += 'And (title like : term) ';
				}else{
					listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(fileCriteriaObjArg.term);
					queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like : term) ';
				}
			}

			if(String.isNotBlank(fileCriteriaObjArg.siteId) && !'all'.equalsIgnoreCase(fileCriteriaObjArg.siteId)){
				listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(fileCriteriaObjArg.siteId);
				queryStr += 'And  id=: listOfContentDocumentIdsForSite ';
			}
			
			if(String.isNotBlank(ownerId)) {
				queryStr += 'And  Owner.Id = :ownerId ';
			}
			
			if(String.isNotBlank(fileCriteriaObjArg.filter)) {
				queryStr += getFilterCondition(fileCriteriaObjArg.filter);
			}
			
			listOfTitleImageContentVersionIds = getTitleImageContentVersionIds(fileCriteriaObjArg.siteId);
			queryStr += 'And LatestPublishedVersionId != :listOfTitleImageContentVersionIds ';
			queryStr += 'And LatestPublishedVersion.Origin = \'C\' ';
			queryStr += getSortOrderCondition(fileCriteriaObjArg.sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+ fileCriteriaObjArg.offset;
			
            return Database.query(queryStr);
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	public List<ContentDocument> autoComplete (String termArg, String siteId) {
		try {
			String queryStr = getBaseQuery();
			
			if(String.isNotBlank(termArg)){
				termArg = '%' + termArg + '%'; 
				queryStr += 'And (title like :termArg) ';
			}
			
			if(String.isNotBlank(siteId) && !'all'.equalsIgnoreCase(siteId)){
				listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(siteId);
				queryStr += 'And  id=: listOfContentDocumentIdsForSite ';
			}
            return Database.query(queryStr);
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	public ContentDocument getContentDocumentById(String contentDocumentId){
		String queryStr = 'SELECT Id, Title, LatestPublishedVersion.pathOnClient, LatestPublishedVersion.VersionNumber, Owner.name,Owner.id,' +
		 						'LastModifiedDate, LatestPublishedVersionId, ' +
						 		'LatestPublishedVersion.description, LatestPublishedVersion.ContentSize,LatestPublishedVersion.FileExtension,' +
						 		'LatestPublishedVersion.fileType, LatestPublishedVersion.Origin, '+
						 		'(select id, ShareType, LinkedEntity.type, LinkedEntityId from ContentDocumentLinks) ' +
						 		' From ContentDocument Where Id =:contentDocumentId  ';			
		
		if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND LatestPublishedVersion.networkid = null ';
    	}
		List<ContentDocument> conDocuList = (List<ContentDocument>)Database.query(queryStr);
		if(conDocuList.isEmpty() == false){
			return conDocuList[0];
		} else {
			return null;
		}
	}
	
	private String getSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			String orderByField = '';
	        String order = '';
	        if (sortby.equalsIgnoreCase('alphabetical')) {
	        	orderByField = 'Title';
	        	order = 'ASC';
	        }else if (sortby.equalsIgnoreCase('createdNewest') || sortBy.equalsIgnoreCase('createdOldest')) {
				orderByField = 'CreatedDate';
		    	order = sortBy.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';
            } else if (sortby.equalsIgnoreCase('modifiedNewest') || sortby.equalsIgnoreCase('modifiedOldest')) {
            	orderByField = 'LastModifiedDate';
		        order = sortBy.equalsIgnoreCase('modifiedNewest')? 'DESC' : 'ASC';
			}
		queryStr += ' ORDER BY '+orderByField+' '+order;	
		}else{
			queryStr += ''; 
		}
        return queryStr;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getMyFilesBookmarkedFiles (List<String> fileIds) {
		try {
			String queryStr = getBaseQuery();
			queryStr += ' And id=: fileIds Order by LastModifiedDate Desc';
			return Database.query(queryStr);

	} catch (Exception e) {
			throw e;
		}
	}
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getMyFilesBookmarkedFiles (Criteria.File fileCriteriaObjArg) {
		try {
			String queryStr = getBaseQuery();
			Integer recordLimit = fileCriteriaObjArg.size + 1;
			String term = fileCriteriaObjArg.term;
			
			List<Id> listOfBookmarkedContentDocumentIds = getContentDocumentIdsBookmarkedByUser(BOOKMARK_TYPE_INTRANET_FILES);
			queryStr += 'And id=: listOfBookmarkedContentDocumentIds ';
			
			if(String.isNotBlank(fileCriteriaObjArg.term)){
				term = '%' + term + '%';
				
				if(fileCriteriaObjArg.fullText == false){
					queryStr += 'And (title like : term) ';
					
				}else{
					listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(fileCriteriaObjArg.term, listOfBookmarkedContentDocumentIds);
					queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like : term) ';
				}
			}
			if(String.isNotBlank(fileCriteriaObjArg.siteId) && !'all'.equalsIgnoreCase(fileCriteriaObjArg.siteId)){
				listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(fileCriteriaObjArg.siteId);
				queryStr += 'And  id=: listOfContentDocumentIdsForSite ';
			}
			
			queryStr += getSortOrderCondition(fileCriteriaObjArg.sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+ fileCriteriaObjArg.offset;

			Map<Id,ContentDocument> conDocMap = new Map<Id, ContentDocument>((List<ContentDocument>)Database.query(queryStr));
            List<ContentDocument> sortedConDocList = new List<ContentDocument>();
            for(Id conDocId : listOfBookmarkedContentDocumentIds){
            	if(conDocMap.get(conDocId) != null){
            		sortedConDocList.add(conDocMap.get(conDocId));
            	}
            }
            return sortedConDocList;
		
		} catch (Exception e) {
			throw e;
		}
	}

		/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getBookmarkedFiles (String termArg, Integer offset, Integer recordLimit,
			String filterArg, String siteId, String sortBy ) {
		try {
			String queryStr = getBaseQuery();
			
			List<Id> listOfBookmarkedContentDocumentIds = getContentDocumentIdsBookmarkedByUser(null);
			queryStr += 'And id=: listOfBookmarkedContentDocumentIds ';
			
			if(String.isNotBlank(termArg)){
				listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(termArg, listOfBookmarkedContentDocumentIds);
				termArg = '%' + termArg + '%'; 
				queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like :termArg) ';
			}
			if(String.isNotBlank(siteId) && !'all'.equalsIgnoreCase(siteId)){
				listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(siteId);
				queryStr += 'And  id=: listOfContentDocumentIdsForSite ';
			}
			
			queryStr += getSortOrderCondition(sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
			
            Map<Id,ContentDocument> conDocMap = new Map<Id, ContentDocument>((List<ContentDocument>)Database.query(queryStr));
            List<ContentDocument> sortedConDocList = new List<ContentDocument>();
            for(Id conDocId : listOfBookmarkedContentDocumentIds){
            	if(conDocMap.get(conDocId) != null){
            		sortedConDocList.add(conDocMap.get(conDocId));
            	}
            }
            return sortedConDocList;
		
		} catch (Exception e) {
			throw e;
		}
	}
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<File__c> getBookmarkedNativeVideoFiles (List<String> listOfExternalIds) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfExternalIds);
		String queryStr = 'SELECT Id, Size__c, Author__r.Full_Name__c, Content_Name__c, Description__c, Duration__c, External_Id__c,'
							+ ' Simpplr_Content__c, Thumbnail_URL__c, Thumbnail__c, Title__c, Url__c, Site__c,LastModifiedDate,Likes__c,CreatedDate,Video_Provider__c, '
							+ ' Author__c,Author__r.name, Video_Status__c, MIME_Type__c '
							+ ' FROM File__c WHERE External_Id__c IN :soqlParam1 Order by lastModifiedDate DESC';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);							
		return listOfFile;
	}
	

	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<File__c> getBookmarkedVideoFiles (String termArg, Integer offset, Integer recordLimit,
			String filterArg, String siteId, String sortBy ) {
		try {
			List<String> listOfBookmarkedExternalIds = getNativeVideoIdsBookmarkedByUser(FILE_TYPE_NATIVE_VIDEOS_FILES);
			
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', listOfBookmarkedExternalIds);

			String queryStr = 'SELECT Id, Size__c, Author__r.Full_Name__c, Content_Name__c, Description__c, Duration__c, External_Id__c,'
							 + ' Simpplr_Content__c, Thumbnail_URL__c, Thumbnail__c, Title__c, Url__c, Site__c,LastModifiedDate,Likes__c,CreatedDate,Video_Provider__c, '
							 + ' Author__c,Author__r.name, Video_Status__c, MIME_Type__c '
							 + ' FROM File__c WHERE External_Id__c IN :soqlParam1 ';

			if(String.isNotBlank(termArg)){
				termArg = '%' + termArg + '%'; 
				soqlParamMap.put('soqlParam2', termArg);
				queryStr += 'AND (Title__c like :soqlParam2 OR Content_Name__c like :soqlParam2 OR Description__c like :soqlParam2) ';
			}
			if(String.isNotBlank(siteId) && !'all'.equalsIgnoreCase(siteId)){
				soqlParamMap.put('soqlParam3', siteId);
				queryStr += 'AND Site__c =: soqlParam3 ';
			}
			
			queryStr += getSortOrderCondition(sortBy);
			queryStr += ' LIMIT ' + recordLimit + ' OFFSET ' + offset;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
            return listOfFile;
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getMyFilesFavoriteCRMFiles (Criteria.File fileCriteriaObjArg){
		try {
			String queryStr = getBaseQuery();
			Integer recordLimit = fileCriteriaObjArg.size + 1;
			String term = fileCriteriaObjArg.term;
			
			List<Id> listOfBookmarkedContentDocumentIds = getContentDocumentIdsBookmarkedByUser(BOOKMARK_TYPE_CRM_FILES);
			queryStr += 'And id=: listOfBookmarkedContentDocumentIds ';
			
			if(String.isNotBlank(fileCriteriaObjArg.term)){
				
				term = '%' + term + '%'; 
				
				if(fileCriteriaObjArg.fullText == false){
					queryStr += 'And (title like : term) ';
				}else{
					listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(fileCriteriaObjArg.term, listOfBookmarkedContentDocumentIds);
					queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like : term) ';
				}
			}
			if(String.isNotBlank(fileCriteriaObjArg.siteId) && !'all'.equalsIgnoreCase(fileCriteriaObjArg.siteId)){
				listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(fileCriteriaObjArg.siteId);
				queryStr += 'And  id=: listOfContentDocumentIdsForSite ';
			}
			
			queryStr += getSortOrderCondition(fileCriteriaObjArg.sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+ fileCriteriaObjArg.offset;
			
            Map<Id,ContentDocument> conDocMap = new Map<Id, ContentDocument>((List<ContentDocument>)Database.query(queryStr));
            List<ContentDocument> sortedConDocList = new List<ContentDocument>();
            for(Id conDocId : listOfBookmarkedContentDocumentIds){
            	if(conDocMap.get(conDocId) != null){
            		sortedConDocList.add(conDocMap.get(conDocId));
            	}
            }
            return sortedConDocList;
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getSiteFilesAllFiles (Criteria.File fileCriteriaObjArg, Integer recordLimit,String ownerId) {
			String pathOnClient;
			String queryStr = getBaseQuery();
			String term = fileCriteriaObjArg.term;
			
			if('image'.equalsIgnoreCase(fileCriteriaObjArg.type)){
				queryStr += ' AND (FileType = \'JPG\' OR FileType = \'JPEG\' OR FileType = \'PNG\' OR FileType = \'GIF\') '; 
			}
			
			if (String.isBlank(fileCriteriaObjArg.directory)) {
				listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(fileCriteriaObjArg.siteId);
				queryStr += 'And id=: listOfContentDocumentIdsForSite ';
				logger.logDebug('SiteFilesAllFiles -- listOfContentDocumentIdsForSite :: ' + listOfContentDocumentIdsForSite);
			}
			
			
			if(String.isNotBlank(ownerId)) {
				queryStr += 'And  Owner.Id = :ownerId ';
			}
			
			if(String.isNotBlank(fileCriteriaObjArg.filter)) {
				queryStr += getFilterCondition(fileCriteriaObjArg.filter);
			}
			
			if(String.isNotBlank(fileCriteriaObjArg.term)){
				term = '%' + term + '%';
				
				if(fileCriteriaObjArg.fullText == false){
					queryStr += 'And (title like :term) ';
				}else{
					listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(fileCriteriaObjArg.term, listOfContentDocumentIdsForSite);
					queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like : term) ';
				}
								
				//exclude Albums file from site-file search
				listOfTitleContentDocumentIds = getImageFilesCDIds4Site(listOfContentDocumentIdsForSite);
				queryStr += 'And id != : listOfTitleContentDocumentIds ';
				logger.logDebug('SiteFilesAllFiles -- listOfTitleContentDocumentIds with matched term:: ' + listOfTitleContentDocumentIds);
				
			} else if(String.isNotBlank(fileCriteriaObjArg.directory)) {
				listOfMatchedContentDocumentIds = getListOfFilesInDirectory(fileCriteriaObjArg.directory);
				queryStr += 'And id in : listOfMatchedContentDocumentIds ';
				logger.logDebug('SiteFilesAllFiles -- listOfMatchedContentDocumentIds in directory:: ' + listOfMatchedContentDocumentIds);
			} else {
				// both 'termArg' and 'directory' are blank
				listOfContentDocumentIdsWithoutFolder = getListOfContentDocumentIdsWithoutFolder(fileCriteriaObjArg.siteId);
				queryStr += 'And id in : listOfContentDocumentIdsWithoutFolder ';//and Folder__c = null ';
				logger.logDebug('SiteFilesAllFiles -- listOfContentDocumentIdsWithoutFolder :: ' + listOfContentDocumentIdsWithoutFolder);
			}
			
			if(String.isBlank(fileCriteriaObjArg.directory) && String.isBlank(fileCriteriaObjArg.term)) {
				listOfTitleImageContentVersionIds = getTitleImageContentVersionIds(fileCriteriaObjArg.siteId);
				queryStr += 'And LatestPublishedVersionId != :listOfTitleImageContentVersionIds ';
				logger.logDebug('SiteFilesAllFiles -- listOfTitleImageContentVersionIds :: ' + listOfTitleImageContentVersionIds);
			}
			
			queryStr += getSortOrderCondition(fileCriteriaObjArg.sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+ fileCriteriaObjArg.offset;
			
			logger.logDebug('SiteFilesAllFiles -- queryStr :: ' + queryStr);
			
            return Database.query(queryStr);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getSiteFilesOwnedFiles (String directory, String termArg, Integer offset, Integer recordLimit,
			String filterArg, String siteId, String sortBy ) {
		try {
			String pathOnClient;
			String loggedInUserId = UserContext.Id;
			String queryStr = getBaseQuery();
			queryStr += 'And Owner.id=: loggedInUserId ';
			listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(siteId);
			queryStr += 'And id=: listOfContentDocumentIdsForSite ';
			if(String.isNotBlank(termArg)){
				listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(termArg, listOfContentDocumentIdsForSite);
				termArg = '%' + termArg + '%'; 
				queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like :termArg) ';
			} else if(String.isNotBlank(directory)) {
				listOfMatchedContentDocumentIds = getListOfFilesInDirectory(directory);
				queryStr += 'And id in : listOfMatchedContentDocumentIds ';
			}
			queryStr += getSortOrderCondition(sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
            return Database.query(queryStr);
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getSiteFilesSharedFiles (String directory, String termArg, Integer offset, Integer recordLimit,
			String filterArg, String siteId, String sortBy ) {
		try {
			String pathOnClient;
			String queryStr = getBaseQuery();
			listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(siteId);
			queryStr += 'And id=: listOfContentDocumentIdsForSite ';
			
			List<Id> listOfSharedContentDocumentIds = getContentDocumentIdsSharedWithLoggedInUser();
			queryStr += 'And id=: listOfSharedContentDocumentIds ';
			if(String.isNotBlank(directory)) {
				pathOnClient = '%#' + siteId + '#' + directory + '%';
				queryStr += 'And LatestPublishedVersion.pathOnClient like : pathOnClient ';
			} else if(String.isNotBlank(directory)) {
				listOfMatchedContentDocumentIds = getListOfFilesInDirectory(directory); 
				queryStr += 'And id in : listOfMatchedContentDocumentIds ';
			}
			queryStr += getSortOrderCondition(sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
            return Database.query(queryStr);
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<ContentDocument> getSiteFilesBookmarkedFiles (String directory, String termArg, Integer offset, Integer recordLimit,
			String filterArg, String siteId, String sortBy ) {
		try {
			String pathOnClient;
			String queryStr = getBaseQuery();
			listOfContentDocumentIdsForSite = getContentDocumentIdsForSite(siteId);
			queryStr += 'And id=: listOfContentDocumentIdsForSite ';
			
			List<Id> listOfBookmarkedContentDocumentIds = getContentDocumentIdsBookmarkedByUser(BOOKMARK_TYPE_INTRANET_FILES);
			queryStr += 'And id=: listOfBookmarkedContentDocumentIds ';
            
            if(String.isNotBlank(termArg)){
				listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(termArg, listOfBookmarkedContentDocumentIds);
				termArg = '%' + termArg + '%'; 
				queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like :termArg) ';
			} else if(String.isNotBlank(directory)) {
				listOfMatchedContentDocumentIds = getListOfFilesInDirectory(directory);
				queryStr += 'And id in : listOfMatchedContentDocumentIds ';
			}
            queryStr += getSortOrderCondition(sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
			
            Map<Id,ContentDocument> conDocMap = new Map<Id, ContentDocument>((List<ContentDocument>)Database.query(queryStr));
            List<ContentDocument> sortedConDocList = new List<ContentDocument>();
            for(Id conDocId : listOfBookmarkedContentDocumentIds){
            	if(conDocMap.get(conDocId) != null){
            		sortedConDocList.add(conDocMap.get(conDocId));
            	}
            }
            return sortedConDocList;
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	public List<ContentDocument> getSiteCRMBookmarkedFiles (String directory, String termArg, Integer offset, Integer recordLimit,
			String siteId, String sortBy ) {
		try {
			String queryStr = getBaseQuery();
			if(String.isNotBlank(directory)) {
				listOfContentDocumentIdsForSite = getContentDocumentIdsInCRMLibraries(new Set<String>{directory});
			} else {
				listOfContentDocumentIdsForSite = getContentDocumentIdsInCRMLibraries(getSetOfSiteCRMLibraries(siteId));
			}
			queryStr += 'And id=: listOfContentDocumentIdsForSite ';
			
			List<Id> listOfBookmarkedContentDocumentIds = getContentDocumentIdsBookmarkedByUser(BOOKMARK_TYPE_CRM_FILES);
			queryStr += 'And id=: listOfBookmarkedContentDocumentIds ';
            
            if(String.isNotBlank(termArg)){
				listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(termArg, listOfBookmarkedContentDocumentIds);
				termArg = '%' + termArg + '%'; 
				queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like :termArg) ';
			}
           	queryStr += getSortOrderCondition(sortBy);
			queryStr += ' limit ' + recordLimit + ' offset '+offset;
			
			Map<Id,ContentDocument> conDocMap = new Map<Id, ContentDocument>((List<ContentDocument>)Database.query(queryStr));
            List<ContentDocument> sortedConDocList = new List<ContentDocument>();
            for(Id conDocId : listOfBookmarkedContentDocumentIds){
            	if(conDocMap.get(conDocId) != null){
            		sortedConDocList.add(conDocMap.get(conDocId));
            	}
            }
            return sortedConDocList;
		
		} catch (Exception e) {
			throw e;
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Id> getContentDocumentIdsForSite(String siteId) {
		List<Id> listOfIds = new List<Id>();
		Simpplr_Site__c siteObj = Utility.getAllSimpplrSiteMap().get(siteId);
		if(siteObj != null) {
			String groupId = siteObj.Chatter_Group_Id__c;
			List<CollaborationGroup> listOfCollaborationGroup=new List<CollaborationGroup>();
			String BASE_QUERY= 'Select Id'+
					', (Select ContentDocumentId From ContentDocumentLinks where IsDeleted = false) ';
			String BASE_FROM_WHERE = 'From CollaborationGroup where Id = :groupId ';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_FROM_WHERE = BASE_FROM_WHERE+'AND NetworkId = null';
	    	}
			String queryStr=BASE_QUERY+BASE_FROM_WHERE;
			listOfCollaborationGroup= Database.query(queryStr);
			for(CollaborationGroup collaborationGroupObj : listOfCollaborationGroup){
				for(ContentDocumentLink contentDocumentLinkObj : collaborationGroupObj.ContentDocumentLinks) {
					listOfIds.add(contentDocumentLinkObj.ContentDocumentId);  
				}
			}
		}
		return listOfIds;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Id> getContentDocumentIdsBookmarkedByUser(String fileType) {
		List<Id> listOfIds = new List<Id>();
		String loggedInUserPeopleId = UserContext.getCurrentUserInfo.Id;
		List<Bookmark__c> listOfBookmarks;
		if(String.isNotBlank(fileType)){
			listOfBookmarks = [select External_File_Id__c from Bookmark__c where People__c=:loggedInUserPeopleId and Type__c=:fileType  AND Is_Deleted__c = false WITH SECURITY_ENFORCED Order by LastModifiedDate Desc];
		} else {
			listOfBookmarks = [select External_File_Id__c from Bookmark__c where People__c=:loggedInUserPeopleId AND Is_Deleted__c = false AND (Type__c =: BOOKMARK_TYPE_INTRANET_FILES OR TYPE__c=: BOOKMARK_TYPE_CRM_FILES) WITH SECURITY_ENFORCED Order by LastModifiedDate Desc];
		}
		for(Bookmark__c bookmarkObj:listOfBookmarks) {
			listOfIds.add(bookmarkObj.External_File_Id__c);
		}
		return listOfIds;
	}

	public List<String> getNativeVideoIdsBookmarkedByUser(String fileType) {
		List<String> listOfIds = new List<String>();
		String loggedInUserPeopleId = UserContext.getCurrentUserInfo.Id;
		List<Bookmark__c> listOfBookmarks;
		if(String.isNotBlank(fileType)){
			listOfBookmarks = [select External_File_Id__c from Bookmark__c where People__c=:loggedInUserPeopleId and Type__c=:fileType  AND Is_Deleted__c = false WITH SECURITY_ENFORCED Order by LastModifiedDate Desc];
		} 
		for(Bookmark__c bookmarkObj:listOfBookmarks) {
			listOfIds.add(bookmarkObj.External_File_Id__c);
		}
		return listOfIds;
	}


	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Id> getContentDocumentIdsForSearchedText(String searchText) {
		List<Id> listOfIds = new List<Id>();
		if(searchText.trim().length() > 1) {
			List<List<SObject>> searchList = [FIND :searchText IN All FIELDS RETURNING ContentVersion (Id, ContentDocumentId,description 
															   WHERE  IsLatest =true AND IsDeleted = false)];
			for (List<SObject> lstSRElement : searchList) {
				if(!lstSRElement.isEmpty()) {
					for (SObject srElement : lstSRElement ) {
						listOfIds.add(((ContentVersion)srElement).ContentDocumentId);
					}
				}
			}	
		}
		return listOfIds;													   
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Id> getContentDocumentIdsForSearchedText(String searchText, List<Id> listOfContentDocumentIds) {
		List<Id> listOfIds = new List<Id>();
		if(searchText.trim().length() > 1) {
			List<List<SObject>> searchList = [FIND :searchText IN All FIELDS RETURNING ContentVersion (Id, ContentDocumentId,description 
															   WHERE  contentdocumentid=:listOfContentDocumentIds And IsLatest =true AND IsDeleted = false)];
			for (List<SObject> lstSRElement : searchList) {
				if(!lstSRElement.isEmpty()) {
					for (SObject srElement : lstSRElement ) {
						listOfIds.add(((ContentVersion)srElement).ContentDocumentId);
					}
				}
			}
		}
		return listOfIds;												   
	} 
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Id> getContentDocumentIdsSharedWithLoggedInUser() {
		List<Id> listOfIds = new List<Id>();
		String loggedInUserId = UserContext.Id;
		List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink 
															 WHERE LinkedEntityId  =:loggedInUserId 
															 And (shareType='V' or shareType='C') WITH SECURITY_ENFORCED LIMIT 10000];
		
		String contentDocSObjectPrefix =  ContentDocument.sObjectType.getDescribe().getKeyPrefix();
		for(ContentDocumentLink contentDocumentLinkObj : contentDocumentLinkList){
			if((String.valueOf(contentDocumentLinkObj.ContentDocumentId)).substring(0,3) == contentDocSObjectPrefix) {
				listOfIds.add(contentDocumentLinkObj.ContentDocumentId);
			}
		}
		return listOfIds;
		
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<File__c> getSiteAlbumDetailPhotoFiles (Integer offset, Integer recordLimit,
			String filterArg, String albumId) {
		List<File__c> listOfFile = new List<File__c>();
		
		if (albumId != null) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', albumId);
			soqlParamMap.put('soqlParam2', recordLimit);
			String filesQuery = 'SELECT Content_Name__c, likes__c,Simpplr_Content__r.Album_Image_Count__c, Simpplr_Content__r.Album_Video_Count__c, Content_Version__c, Is_Title_Image__c, Thumbnail_URL__c,Description__c,'+
					' Simpplr_Content__c, Url__c, MIME_Type__c FROM File__c '+
					' WHERE Simpplr_Content__c=:soqlParam1 AND MIME_Type__c=\'image\' AND Is_Deleted__c=false '+
					' limit :soqlParam2';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		}
				
		return listOfFile;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<File__c> getSiteAlbumDetailVideoFiles (Integer offset, Integer recordLimit,
			String filterArg, String albumId) {
		List<File__c> listOfFile = new List<File__c>();
		
		if (albumId != null) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', albumId);
			soqlParamMap.put('soqlParam2', recordLimit);
			String filesQuery = 'SELECT Content_Name__c, Simpplr_Content__r.Album_Image_Count__c, Simpplr_Content__r.Album_Video_Count__c, Content_Version__c, External_Id__c, Is_Title_Image__c, Thumbnail_URL__c,'+
					' name,Description__c, Simpplr_Content__c, Url__c, MIME_Type__c FROM File__c '+
					' WHERE Simpplr_Content__c=:soqlParam1 AND Is_Deleted__c=false'+ 
					' AND MIME_Type__c=\'video\' limit :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		}
				
		return listOfFile;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<File__c> getSiteAlbumDetailAllFiles (Integer offsetVal, Integer recordLimit, String albumId) {
		String loggedInPeopleId = UserContext.peopleId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', loggedInPeopleId);
		soqlParamMap.put('soqlParam2', albumId);
		String query = 'SELECT Content_Name__c, Content_Document__c, Order__c,Author__c,Author__r.name, Author__r.User__r.SmallPhotoUrl, Author__r.User__c,' 
					+' Location__c,Simpplr_Content__r.Album_Image_Count__c,Likes__c, Simpplr_Content__r.Album_Video_Count__c, Content_Version__c, '
					+' External_Id__c, Is_Deleted__c, name, Is_Title_Image__c, Video_Status__c, '
					+' Author__r.Zoom_Id__c, Author__r.Skype_Id__c,Video_Provider__c,'
					+' Thumbnail_URL__c, Simpplr_Content__c, Url__c, MIME_Type__c, Description__c,CreatedDate,'
					+' (SELECT Id FROM Likes_Simpplr_File__r WHERE People__c =:soqlParam1)'
					+' FROM File__c'
					+' WHERE Simpplr_Content__c =: soqlParam2  AND Is_Deleted__c=false AND Location__c = \'media\''
					+' Order by Order__c desc, CreatedDate desc';
		
		if(recordLimit != null && recordLimit >0){
			query += ' limit ' +recordLimit;
		}
		if(offsetVal != null && offsetVal >0){
			query += ' OFFSET ' +offsetVal;
		}	
		
		logger.logDebug('FileDao.getSiteAlbumDetailAllFiles()---query----' +query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		return listOfFile;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<Bookmark__c> getListOfBookmarks(List<String> listOfFileIds, String context) {
		List<Bookmark__c> listOfBookmarks = [SELECT External_File_Id__c 
											FROM Bookmark__c 
											WHERE External_File_Id__c =: listOfFileIds
											And Type__c =: context
											And People__c =: UserContext.peopleId  AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
		return listOfBookmarks;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    public Map<String,Integer> submitMediaToAlbum (String albumId, List<ContentWrapper.MediaWrapper> mediaWrapperList) {
    	Integer videoCount = 0;
    	Integer photoCount = 0; 
    	List<String> fileIdList = new List<String>();//needed list to maintain the order of files as they come from UI
    	Map<String,String> fileIdToDescriptionMap = new Map<String,String>();
    	
    	for (ContentWrapper.MediaWrapper mediaObj : mediaWrapperList) {
    		fileIdList.add(mediaObj.id);
    		fileIdToDescriptionMap.put(mediaObj.id,mediaObj.description);
    	}
        Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', albumId);
		soqlParamMap.put('soqlParam2', fileIdList);
        // get new file records of this album
        String filesQuery = 'SELECT Id, MIME_Type__c, Order__c, Is_deleted__c, Content_Document__c, '+
        								' Simpplr_Content__r.Site__c, Simpplr_Content__r.Site__r.Site_Type__c,'+
        								' Simpplr_Content__r.Site__r.Chatter_Group_Id__c, Repository__c'+
        							' FROM File__c WHERE Simpplr_Content__c =: soqlParam1 '+
        							' AND Id IN : soqlParam2';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
        
        String siteId = fileList[0].Simpplr_Content__r.Site__c;
        String groupId = fileList[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c;
        Boolean isPublicSite = 'public'.equalsIgnoreCase(fileList[0].Simpplr_Content__r.Site__r.Site_Type__c) ? true : false;
        
        // get the latest highest order from database
        String locationStr = ServiceConstants.FILE_LOCATION_MEDIA;

		Integer highestOrder; 
		List<File__c> listOfFile = new List<File__c>();
		Map<String, Object> soqlParamMap1 = new Map<String, Object>();
		soqlParamMap1.put('soqlParam1', albumId);
		soqlParamMap1.put('soqlParam2', locationStr);
        filesQuery = 'SELECT Order__c FROM File__c '+
        										' WHERE Simpplr_Content__c =: soqlParam1 AND Is_Deleted__c = false'+
        										' AND Location__c =: soqlParam2  order by Order__c desc LIMIT 1';
        
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap1);
		if(listOfFile.size() > 0){
			highestOrder = Integer.valueOf(listOfFile[0].Order__c);
		}		
        
        List<File__c> imageFileList = new List<File__c>();
        
        //for loop for adding order, getting count and making Is_Deleted__C flag to false of newly added files
        Integer totalCount = (highestOrder != null ? highestOrder : 0 ) + mediaWrapperList.size();
        for (File__c fileObj : fileList) {
        	
    		// image and video count that are being added
    		if ('image'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
        		photoCount = photoCount + 1;
        	} else if ('video'.equalsIgnoreCase(fileObj.MIME_Type__c)) {
        		videoCount = videoCount + 1;
        	}
        	fileObj.Order__c = totalCount--;
        	fileObj.Is_Deleted__c = false;
        	fileObj.Description__c = fileIdToDescriptionMap.get(fileObj.id);
        	
        	if(String.isNotBlank(fileObj.Content_Document__c)) {
        		imageFileList.add(fileObj);
        	}
        }
        
        createContentDocumentLinks(ServiceConstants.CONTENT_STATUS_APPROVED, true, imageFileList, groupId, isPublicSite);
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(
	        		new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{File__c.Is_Deleted__c,
	        																	  File__c.Order__c,
	        																	  File__c.Description__c});
	        																	  
        Map<String,Integer> albumMediaCountMap = new Map<String,Integer> ();
        albumMediaCountMap.put('videoCount',videoCount);
        albumMediaCountMap.put('photoCount',photoCount);
    	
    	return albumMediaCountMap;
    }
	
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public File__c addVideoToAlbum (String videoUrl, String albumId, String videoId, 
			String thumbnailImg , String title, String provider, Integer size) { 
		if (videoUrl != null && videoUrl.containsIgnoreCase('https://youtu.be/') && videoId != null) {
			videoUrl = 'https://www.youtube.com/watch?v='+videoId;
		} 
		
		File__c newVideoObj = new File__c();
		if (String.isNotBlank(title)) {
			newVideoObj.name = title.length() > 80 ? title.substring(0, 79) : title;

		} else if (videoUrl.containsIgnoreCase('microsoftstream.com') || videoUrl.containsIgnoreCase('sharepoint.com')){
			newVideoObj.name = 'Microsoft Video';
			
		} else if(!ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)) {
			newVideoObj.name = 'Private Video';
			
		}
			
		newVideoObj.Location__c = ServiceConstants.FILE_LOCATION_MEDIA;
		newVideoObj.Is_Deleted__c = true;
		newVideoObj.Url__c = videoUrl;
		newVideoObj.Simpplr_Content__c = albumId;
		newVideoObj.MIME_Type__c = 'video';
		newVideoObj.External_Id__c = videoId;
		newVideoObj.Video_Provider__c = provider;
		newVideoObj.Author__c = UserContext.peopleId;
		if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)){
			Map<String,String> videoFolderDetailsMap = getAlbumVideoFolderDetails(albumId);
			newVideoObj.Site__c = videoFolderDetailsMap.get('siteId');
			newVideoObj.Folder__c = videoFolderDetailsMap.get('parentFolderId');
			newVideoObj.Thumbnail_url__c = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + videoId +'/width/550/height/480';
			newVideoObj.size__c = size;
		}
			
		if (String.isNotBlank(thumbnailImg)) {
			newVideoObj.Thumbnail_URL__c = thumbnailImg;
			
		} else if(!ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)) {
			newVideoObj.Thumbnail_URL__c = SimpplrContext.resourcePath + 'images/Private_Video.jpg';
		}
		
		newVideoObj.Title__c = title;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        newVideoObj = (File__c)SIMPESAPI.accessController().insertAsUser(newVideoObj, new List<Schema.SObjectField>{
        		File__c.name, File__c.External_Id__c, File__c.Url__c, File__c.Simpplr_Content__c,File__c.Author__c,File__c.Video_Provider__c,File__c.Folder__c,
        		File__c.MIME_Type__c,File__c.Thumbnail_URL__c,File__c.Description__c,File__c.Title__c,File__c.Is_Deleted__c, File__c.Location__c, File__c.Site__c,
				File__c.Size__c});
        		
    	
        return newVideoObj;
	}

	private Map<String,String> getAlbumVideoFolderDetails(String contentId) {
		Map<String,String> videoFolderDetailsMap = new Map<String,String>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String folderQuery = 'Select id, Site__c from Folder__c where Name__c=\'Videos\' And Parent_Folder__r.External_Folder_Id__c =:soqlParam1 and Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!folderList.isEmpty()) {
			videoFolderDetailsMap.put('parentFolderId',folderList[0].id);
			videoFolderDetailsMap.put('siteId',folderList[0].Site__c);
		}
		return videoFolderDetailsMap;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public File__c addPhotoToAlbum(String photoUrl, String albumId, String fileDescription, 
			String fileContentDocId, String fileContentVersionId, String thumsnailUrl, String folder) {
		
		File__c newPhotoObj = new File__c();
		newPhotoObj.Location__c = ServiceConstants.FILE_LOCATION_MEDIA;
		newPhotoObj.Is_Deleted__c = true;
		newPhotoObj.name = fileDescription.left(80);
		newPhotoObj.Url__c = photoUrl;
		newPhotoObj.Simpplr_Content__c = albumId;
		newPhotoObj.MIME_Type__c = 'image';
		newPhotoObj.Thumbnail_URL__c = thumsnailUrl;
		newPhotoObj.Author__c = UserContext.peopleId;
		newPhotoObj.Title__c = fileDescription;
		newPhotoObj.Content_Document__c = fileContentDocId; 
		newPhotoObj.Content_Version__c = fileContentVersionId;
		newPhotoObj.Folder__c = folder;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        newPhotoObj = (File__c)SIMPESAPI.accessController().insertAsUser(newPhotoObj, new List<Schema.SObjectField>{
        		File__c.name, File__c.Url__c, File__c.Simpplr_Content__c,File__c.MIME_Type__c,File__c.Title__c,
        		File__c.Thumbnail_URL__c,File__c.Description__c, File__c.Content_Document__c, File__c.Author__c,
        		File__c.Content_Version__c, File__c.Folder__c, File__c.Is_Deleted__c, File__c.Location__c});
        		
        
        return newPhotoObj;
	}
	
	public ContentDocument getFileDetails(String fileId) {
		ContentDocument fileDetails;
		String queryStr = 'SELECT Title, Owner.Id, Owner.name, Owner.department,'
						+ ' LatestPublishedVersion.Description,'
						+ ' LatestPublishedVersion.ContentSize, LatestPublishedVersion.VersionNumber,' 
						+ ' Owner.SmallPhotoUrl, LastModifiedDate, Id,'
						+ ' LatestPublishedVersion.Id, LatestPublishedVersion.pathOnClient,'
						+ ' LatestPublishedVersion.FileExtension,'
						+ ' LatestPublishedVersion.fileType,LatestPublishedVersion.Origin' 
						+ ' FROM ContentDocument WHERE Id=:fileId';
		
		if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND LatestPublishedVersion.networkid = null';
    	}
    	
		List<ContentDocument> listOfContentDocument = Database.query(queryStr);
												
		if(!listOfContentDocument.isEmpty()) {
			fileDetails = listOfContentDocument[0];
		}
		return fileDetails;
	}
	
	public Boolean isFileBookmarked(String fileIdArg, String fileType) {
		Boolean isBookmarked = false;
		String currentUserPeopleId = UserContext.peopleId;
		String query  = 'SELECT Id FROM Bookmark__c WHERE External_File_Id__c =: fileIdArg ' +
						'And People__c =:  currentUserPeopleId  AND Is_Deleted__c = false'; 
		if(String.isNotBlank(fileType)) {
			query += ' And Type__c =: fileType ';
		} 
		List<Bookmark__c> listOfBookmark = Database.query(query); 
		if (!listOfBookmark.isEmpty()) {
			isBookmarked = true;
		}
		return isBookmarked;
	}
	
	public Boolean isFileLiked(String fileIdArg) {
		Boolean isLiked = false;
		List<Like__c> listOfLike = [SELECT Id 
									FROM Like__c 
									WHERE External_File_Id__c =: fileIdArg
									And People__c =: UserContext.peopleId WITH SECURITY_ENFORCED]; 
		if (!listOfLike.isEmpty()) {
			isLiked = true;
		}
		return isLiked;
   }
   
   public List<Like__c> getFileLikes(String fileIdArg) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileIdArg);
		String query = 'SELECT Id'+ 
									' FROM Like__c'+ 
									' WHERE External_File_Id__c =: soqlParam1'; 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Like__c> listOfLike = (List<Like__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		return listOfLike;
   }
   
   public Boolean setDescription(String fileId, String description) {
   		String queryStr = 'SELECT ID, Description FROM ContentVersion WHERE ContentDocumentId=:fileId and isLatest=true';
    	
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND networkid = null';
    	}
    	
		List<ContentVersion> listOfFile = Database.query(queryStr);
		if(!listOfFile.isEmpty()){
			ContentVersion fileObj = new ContentVersion ();
			fileObj = listOfFile[0];
			fileObj.Description=description; 
			//update fileObj;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(fileObj,new List<Schema.SObjectField>{
													ContentVersion.Description});
		}
		return true;
   }
   
   public List<ContentDocument> getSiteCRMFilesInLibrary(String directory, Integer offset,
    		String filterArg, Integer recordLimit, String sortBy, String ownerId) {
		
		String queryStr = getBaseQuery();
		listOfMatchedContentDocumentIds = getContentDocumentIdsInCRMLibraries(new Set<String>{directory});
		queryStr += 'And id=: listOfMatchedContentDocumentIds ';
		
		if(String.isNotBlank(ownerId)) {
			queryStr += 'And  Owner.Id = :ownerId ';
		}
		
		if(String.isNotBlank(filterArg)) {
			queryStr += getFilterCondition(filterArg);
		}
		
		queryStr += getSortOrderCondition(sortBy);
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
        return Database.query(queryStr);
   }
   
   public List<ContentDocument> searchSiteCRMFilesInAllLibraries(Criteria.File fileCriteriaObjArg) {
		
		String queryStr = getBaseQuery();
		Integer recordLimit = fileCriteriaObjArg.size + 1;
		String term = fileCriteriaObjArg.term;
		
		listOfContentDocumentIdsForSite = getContentDocumentIdsInCRMLibraries(getSetOfSiteCRMLibraries(fileCriteriaObjArg.siteId));
		queryStr += 'And id=: listOfContentDocumentIdsForSite ';
		
		if(String.isNotBlank(fileCriteriaObjArg.term)){
			term = '%' + term + '%';
			
			if(fileCriteriaObjArg.fullText == false){
				queryStr += 'And (title like : term) ';
			}else{
				listOfMatchedContentDocumentIds = getContentDocumentIdsForSearchedText(fileCriteriaObjArg.term, listOfContentDocumentIdsForSite);
				queryStr += 'And (id=: listOfMatchedContentDocumentIds or title like : term) ';
			}
		}
		
		queryStr += getSortOrderCondition(fileCriteriaObjArg.sortBy);
		queryStr += ' limit ' + recordLimit + ' offset '+ fileCriteriaObjArg.offset;
        return Database.query(queryStr);
   }
   
   public List<Id> getContentDocumentIdsInCRMLibraries(Set<String> setOfContentWorkspaceId) {
		List<Id> listOfIds = new List<Id>();
		String loggedInUserId = UserContext.Id;
		List<ContentWorkspaceDoc> listOfContentWorkspaceDoc = [SELECT ContentDocumentId FROM ContentWorkspaceDoc 
															 WHERE ContentWorkspaceId  =:setOfContentWorkspaceId WITH SECURITY_ENFORCED];
		
		for(ContentWorkspaceDoc contentWorkspaceDocObj : listOfContentWorkspaceDoc){
			listOfIds.add(contentWorkspaceDocObj.ContentDocumentId);
		}
		return listOfIds;
		
	}
	
	/*
		public sites: App: + Site: managers can soft delete from file tab except system files(Content Images, Content Files, custom folders) 
		private sites: App managers NO delete
	    			   Site managers Soft delete
		owner: hard delete	
	*/
	public void deleteFile(List<String> fileId) {
		String queryStr = 'SELECT id, OwnerId FROM ContentDocument WHERE Id in :fileId';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND LatestPublishedVersion.networkid = null';
    	}
    	
    	List<ContentDocument> listOfContentDocument = Database.query(queryStr);
		
		if(listOfContentDocument != null && !listOfContentDocument.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    	SIMPESAPI.accessController().deleteAsUser(listOfContentDocument);
		}
		if(listOfContentDocument.size() > 0){
			List<File__c> fileList = getFileRecords(null, fileId);
			deleteFileRecords(fileList);
		}
	}
	
	public void removeFileFromSite(String siteId, List<String> fileId) {
		if(fileId != null && !fileId.isEmpty()){
			softDeleteFiles(siteId, fileId);
		}
	}
	
	/*
		deleteFileRecords:
		
		This will delete file entry from ContentDocument and File_c Objects.
	*/
	private void deleteFileRecords(List<File__c> fileList){
		for(File__c fileObj : fileList){
			fileObj.Is_Deleted__c = true;
		}
		
		if(!fileList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{
														File__c.Is_Deleted__c
														});
		}
	}
	
	/* external file deletion
	*/
	public void deleteExternalFile(String extFileId) {
		if(extFileId != null && String.isNotBlank(extFileId)) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', extFileId);
			String filesQuery = 'SELECT Id, Is_Deleted__c, Simpplr_Content__c, Content_Version__c, Location__c, Folder__c '+
									  ' FROM File__c WHERE External_Id__c =:soqlParam1 AND Simpplr_Content__c <> null AND Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> eFileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
			deleteFileRecords(eFileList);
			
			deleteInlineFilesReference(eFileList, true);			
		}
		
		// Update content
	}
	
	/*
		softDeleteFiles:
		
		This will update 'is_deleted__c' flag in File_c Object.
	*/
	private void softDeleteFiles(String siteId, List<String> cdIdList){
		if(cdIdList != null && !cdIdList.isEmpty()){
			deleteCDLs(SiteContext.chatterGroupId, cdIdList);
			
			List<File__c> fileList = getFileRecords(siteId, cdIdList);
			deleteFileRecords(fileList);
			
			deleteInlineFilesReference(fileList, false);
		}
	}
	
	
	public void deleteInlineFilesReference(List<File__c> fileList, Boolean dtFlag) {
		Map<String, Set<String>> scIdCvIdMap = new Map<String, Set<String>>();
		
		for(File__c fileObj : fileList){
			if(String.isNotBlank(fileObj.Simpplr_Content__c)){
				if(!scIdCvIdMap.containsKey(fileObj.Simpplr_Content__c)){
					scIdCvIdMap.put(fileObj.Simpplr_Content__c, (new Set<String>{fileObj.Content_Version__c}));
				} else {
					(scIdCvIdMap.get(fileObj.Simpplr_Content__c)).add(fileObj.Content_Version__c);
				}
				
				logger.logDebug('FileDao.deleteInlineFilesReference() ---- scIdCvIdMap ---- ' + scIdCvIdMap);
			}
		}
		
		logger.logDebug('FileDao.deleteInlineFilesReference() ---- fileList ---- ' + fileList);
		logger.logDebug('FileDao.deleteInlineFilesReference() ---- scIdCvIdMap ---- ' + scIdCvIdMap);
		
		// ==== delete inline-files linking with current chatter group ====
		// This will remove soft delete File references as inline files and
		// there is no need to remove hard delete references as they will not exist.
		String imageUrl = null;
		Set<String> scIdSet = scIdCvIdMap.keySet();
		List<Simpplr_Content__c> scList = [SELECT Id, Text_Intro__c, Last_Edited_DateTime__c FROM Simpplr_Content__c WHERE
		 						  Id in :scIdSet AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
		
		logger.logDebug('FileDao.deleteInlineFilesReference() ---- scIdSet ---- ' + scIdSet);
		logger.logDebug('FileDao.deleteInlineFilesReference() ---- scList ---- ' + scList);
		
		Set<String> cvSet = null;
		String scText = null;
		String scId = null;
		
		Boolean isTextUpdated = false;
		List<Simpplr_Content__c> scListToUpdate = new List<Simpplr_Content__c>();
		for(Simpplr_Content__c sc  : scList){
			scId = sc.Id;
			cvSet = scIdCvIdMap.get(scId);
			scText = sc.Text_Intro__c;
			
			isTextUpdated = false;
			if(String.isNotBlank(scText)) {
				for (String cvId : cvSet){
					if(String.isNotBlank(cvId)) {
						scText = scText.replace(cvId, '');
						isTextUpdated = true;
					}						
				}
			}
			// Update text in the map
			sc.Text_Intro__c = scText;
			
			if(isTextUpdated || dtFlag) {
				if(dtFlag) {
					sc.Last_Edited_DateTime__c = DateTime.now(); 
				}
				scListToUpdate.add(sc);
			}
		}
	
		if(!scListToUpdate.isEmpty()){
			update scListToUpdate;
		}
	}
	
	
	private List<File__c> getFileRecords(String siteId, List<String> cdIdList) {
		List<File__c> fileList = new List<File__c>();

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', cdIdList);
		

		if(String.isNotBlank(siteId)) {
			soqlParamMap.put('soqlParam2', siteId);
			String filesQuery = 'SELECT Id, Is_Deleted__c, Simpplr_Content__c, Simpplr_Content__r.Text_Intro__c,'+
								' Content_Version__c, Location__c, Folder__c FROM File__c WHERE'+
								' Content_Document__c IN :soqlParam1 AND'+
								' (Simpplr_Content__r.site__c = :soqlParam2 OR Folder__r.site__c = :soqlParam2 OR Site__c = :soqlParam2)';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		} else {
			String filesQuery = 'SELECT Id, Is_Deleted__c, Simpplr_Content__c, Simpplr_Content__r.Text_Intro__c,'+
								' Content_Version__c, Location__c, Folder__c FROM File__c WHERE'+
								' Content_Document__c IN :soqlParam1';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		}
		
		return fileList;
	}
	
	private void deleteCDLs(String chatterGroupId, List<String> cdIdList) {
		// ==== delete CDLs for file with the chatter group ====
		List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE
											 ContentDocumentId IN :cdIdList AND 
											 LinkedEntityId = :chatterGroupId WITH SECURITY_ENFORCED];
		
		if(!cdlList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().deleteAsUser(cdlList);
		}
	}
	
	/*
		Handle Albums delete from here as 'ContentDocumentTrigger' is not handling this for Albums And update the image count also.
	*/
	public void markAlbumContentAsDeleted(String siteId, List<String> contentDocumentIdList, boolean isDeletedFromCD) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentDocumentIdList);
		String albumFileQueryStr = 'Select Id, Is_Deleted__c, MIME_Type__c, Simpplr_Content__c from File__c where Content_Document__c in :soqlParam1'
									+	' AND Is_Deleted__c = false and Simpplr_Content__r.Type__c = \'Album\'';
		
		// If it the file is not deleted from the ContentDocument that means it has been deleted by the person,
		// who is not the owner of this file and have DELETED this file from the CURRENT SITE ONLY.
		if(!isDeletedFromCD){
			soqlParamMap.put('soqlParam2', siteId);
			albumFileQueryStr += ' And Simpplr_Content__r.Site__c = :soqlParam2';
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFilesToUpdate = (List<File__c>)SIMPESAPI.accessController().queryAsUser(albumFileQueryStr, soqlParamMap);
		
		if(!listOfFilesToUpdate.isEmpty()){
			for(File__c fileObj : listOfFilesToUpdate){
				fileObj.Is_Deleted__c = true;
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(listOfFilesToUpdate), 
														new List<Schema.SObjectField>{File__c.Is_Deleted__c});
			
			updateContentCount(listOfFilesToUpdate[0].Simpplr_Content__c, listOfFilesToUpdate[0].MIME_Type__c, listOfFilesToUpdate.size());
		}
	}
	
	private void updateContentCount(Id contentId, String mimeType, Integer fileCount) {
		List<Simpplr_Content__c> listOfAlbum = [select Id, Album_Image_Count__c, Album_Video_Count__c from Simpplr_Content__c where Id = :contentId
												and Type__c =: ServiceConstants.TYPE_ALBUM WITH SECURITY_ENFORCED];
        
        if (!listOfAlbum.isEmpty()) {
        	Simpplr_Content__c albumObj = listOfAlbum[0];
        	
	        if('image'.equalsIgnoreCase(mimeType) && albumObj.Album_Image_Count__c > 0) {
	        	albumObj.Album_Image_Count__c -= fileCount;
	        }
	        
	        // videos cant be deleted from my files.. aren't even listed there..
        	/*if('video'.equalsIgnoreCase(mimeType) && albumObj.Album_Video_Count__c > 0) {
	        	albumObj.Album_Video_Count__c -= 1;
	        }*/
        	
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        	SIMPESAPI.accessController().updateAsUser(albumObj, new List<Schema.SObjectField>{
        					Simpplr_Content__c.Album_Image_Count__c});
        }
	}
	
	public Set<String> getSetOfSiteCRMLibraries(String siteId) {
		Set<String> setOfContentWorkspaceId = new Set<String>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		String folderQuery = 'select External_Folder_Id__c from Folder__c where is_deleted__c=false And type__c=\'CRM\' And Site__c=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		for(Folder__c folderObj : listOfFolders) {
			setOfContentWorkspaceId.add(folderObj.External_Folder_Id__c);	
		}
		return setOfContentWorkspaceId;
	}
	
	public List<ContentVersion> getVersionHistory(String fileId) {
		String queryStr = 'SELECT Title, Owner.Id, VersionNumber, contentModifiedById, contentModifiedBy.name, Owner.name, Owner.department,LastModifiedById,LastModifiedBy.id,LastModifiedBy.name,'
	                        + ' Description,ContentSize,Owner.SmallPhotoUrl, LastModifiedDate, Id,' 
	                        + ' ContentDocumentId,FileExtension,fileType,Origin FROM ContentVersion WHERE ContentDocumentId=:fileId';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND networkid = null';
    	}
    	
    	queryStr += ' order by LastModifiedDate desc';
    	
		List<ContentVersion> listOfContentVersions = Database.query(queryStr);
		return listOfContentVersions;
	}
	
	public List<ContentDocumentLink> getContentDocumentLinks(String fileId) {
		List<ContentDocumentLink> listOfContentDocumentLink = [select id, ShareType, LinkedEntity.type, LinkedEntityId from ContentDocumentLink 
															  where ContentDocumentId=:fileId];
		return listOfContentDocumentLink;
	}
	
	public Set<String> getSetOfBookmarkedFiles(List<String> listOfFileIds, String context) {
    	Set<String> setOfBookmarkedFiles = new Set<String>();
    	List<Bookmark__c> listOfBookmarks = getListOfBookmarks(listOfFileIds, context);
    	for(Bookmark__c bookmarkObj : listOfBookmarks) {
    		setOfBookmarkedFiles.add(bookmarkObj.External_File_Id__c);
    	}
    	return setOfBookmarkedFiles;
    }
    
    public Set<String> getSetOfLikedFiles(List<String> listOfFileIds) {
    	Set<String> setOfLikedFiles = new Set<String>();
    	List<Like__c> listOfLikes = [SELECT External_File_Id__c 
									FROM Like__c 
									WHERE External_File_Id__c =: listOfFileIds
									And People__c =: UserContext.peopleId WITH SECURITY_ENFORCED];
    	for(Like__c likeObj : listOfLikes) {
    		setOfLikedFiles.add(likeObj.External_File_Id__c);
    	}
    	return setOfLikedFiles;
    }
    
    public List<ContentDistribution> insertContentDistributionList(List<ContentDistribution> distributionsList) {
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(distributionsList,new List<Schema.SObjectField>{
    														ContentDistribution.ContentVersionId,
    														ContentDistribution.Name,
    														ContentDistribution.PreferencesAllowOriginalDownload,
    														ContentDistribution.PreferencesAllowPDFDownload,
    														ContentDistribution.PreferencesAllowViewInBrowser,
    														ContentDistribution.PreferencesExpires,
    														ContentDistribution.PreferencesLinkLatestVersion,
    														ContentDistribution.PreferencesNotifyOnVisit,
    														ContentDistribution.PreferencesPasswordRequired
    													});
    	
    	return result.getInsertedObjects();
    }
    
    private List<Id> getListOfFilesInDirectory(String directory) {
    	List<Id> listOfIds = new List<Id>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', directory);
    	String filesQuery = 'select content_Document__c from File__c where folder__c = :soqlParam1 and content_Document__c != null And Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFiles = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
    	
    	for(File__c fileObj : listOfFiles){
    		listOfIds.add(fileObj.content_Document__c);
    	}
    	return listOfIds;
    }
    
    private List<Id> getListOfContentDocumentIdsWithoutFolder(String siteId) {
    	List<Id> listOfIds = new List<Id>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
    	String filesQuery = 'select content_Document__c from File__c where folder__c = null AND Is_Deleted__c = false'+
    																			' AND (Site__c = :soqlParam1 OR Site__c = null)';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFiles = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
    	for(File__c fileObj:listOfFiles) {
    		listOfIds.add(fileObj.content_Document__c);
    	}
    	return listOfIds;
    }
    
    private List<Id> getTitleImageContentVersionIds(String siteId) {
    	List<Id> listOfIds = new List<Id>();
    	List<String> titleImageTypeToIgnore = new List<String>{ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN, ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL};
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', titleImageTypeToIgnore);
    	String query= 'select content_Version__c from File__c where Is_Title_Image__c = true and simpplr_Content__c!=null and content_Version__c !=null And (Title_Image_Type__c=:soqlParam1 Or simpplr_Content__r.Type__c = \'Album\') ';
    	if(String.isNotBlank(siteId)) {
			soqlParamMap.put('soqlParam2', siteId);
    		query += ' And simpplr_Content__r.site__c=:soqlParam2 ';
    	}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFiles = (List<File__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	for(File__c fileObj:listOfFiles) {
    		listOfIds.add(fileObj.content_Version__c);
    	}
    	return listOfIds;
    }

	/*
		This method will mark NON ALBUM files only as in case of Albums we need to update the image count and
		that has been handled in 'deleteFile' method Only (markAlbumDeleted). (The mentioned methods have been defined in this class)
	*/
	public static void markFileDeleted(Set<Id> contentDocumentIdSet) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentDocumentIdSet);
		String filesQuery = 'SELECT Id, Is_Deleted__c FROM File__c WHERE Content_Document__c IN :soqlParam1 AND Simpplr_Content__r.Type__c != \'Album\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		if (!fileList.isEmpty()) {
			for(File__c fileObj : fileList) {
				fileObj.Is_Deleted__c = true;
				fileObj.Content_Document__c = null;
				fileObj.Content_Version__c = null;
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        	SIMPESAPI.accessController().updateAsUser(new Map<Id,File__c>(fileList),new List<Schema.SObjectField>{
        																											File__c.Is_Deleted__c,
        																											File__c.Content_Document__c,
        																											File__c.Content_Version__c
        																										 });
		}
    }

    @future
    public static void markFileDeletedInFuture(Set<Id> contentDocumentIdSet) {
		markFileDeleted(contentDocumentIdSet);
    }
    
    /*
		This method will update content-version-id in File__c object when a ne wversion is uploaded for any file
	*/
	@future
    public static void updateContentVersionInFileRecords(String serializedContentVersionList) {
		List<Id> cdIds = new List<Id>();
		Map<Id, Id> cdIdVsCvIdMap = new Map<Id, Id>();
		Map<Id, String> cdIdVsTitleMap = new Map<Id, String>();

		List<ContentVersion> contentVersionList = (List<ContentVersion>)JSON.deserialize(serializedContentVersionList, ContentVersion.class);

		for(ContentVersion cvObj : contentVersionList) {
			cdIds.add(cvObj.ContentDocumentId);
			cdIdVsCvIdMap.put(cvObj.ContentDocumentId, cvObj.Id);
			cdIdVsTitleMap.put(cvObj.ContentDocumentId, cvObj.Title);
		}
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', cdIds);
		String filesQuery = 'Select Id, Content_Version__c, Content_Document__c from File__c where Content_Document__c = :soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> filesList  = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		for(File__c fileObj : filesList) {
			fileObj.Content_Version__c = cdIdVsCvIdMap.get(fileObj.Content_Document__c);
			fileObj.Title__c = cdIdVsTitleMap.get(fileObj.Content_Document__c);
		}
		
		if(filesList.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        SIMPESAPI.accessController().updateAsUser(new Map<Id,File__c>(filesList),new List<Schema.SObjectField>{
	        																										File__c.Content_Version__c,
	        																										File__c.Title__c
	        																									  });
		}
    }
    
    @future
    public static void createFileRecords4FeedItems(List<String> feedItemIdList, String parentId) {
        
        List<File__c> newFilesList = new List<File__c>();
        Map<Id, ContentVersion> contentVersionIdAndObjectMap = getContentVersionIdAndObjectMap(feedItemIdList);
        
        SiteDao siteDaoObj = new SiteDao();
        String siteId = getSiteIdFromFeedParent(parentId);
        Map<String, Folder__c> mapOfSystemFolders4Site = siteDaoObj.getMapOfSystemFoldersForSite(siteId);
		Folder__c feedFilesFolder = mapOfSystemFolders4Site.get('Feed Files.Files');
		Folder__c feedFImagesFolder = mapOfSystemFolders4Site.get('Feed Files.Images');
        
        for(String contentVersionObj : contentVersionIdAndObjectMap.keySet()) {
            File__c fileObj = new File__c();
            
            fileObj.Title__c = contentVersionIdAndObjectMap.get(contentVersionObj).Title;
            fileObj.Size__c = contentVersionIdAndObjectMap.get(contentVersionObj).ContentSize;
            fileObj.MIME_Type__c = contentVersionIdAndObjectMap.get(contentVersionObj).FileType;
            fileObj.Content_Version__c = contentVersionObj;
            fileObj.Content_Document__c = (contentVersionIdAndObjectMap.get(contentVersionObj)).ContentDocumentId;
            fileObj.Folder__c = Utility.isImage(fileObj.MIME_Type__c) ? feedFImagesFolder.id : feedFilesFolder.Id;
            fileObj.URL__c = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileObj.Content_Document__c, 'siteId' => siteId});
            fileObj.Location__c = ServiceConstants.FILE_LOCATION_FEED;
            fileObj.Repository__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
            fileObj.Site__c = siteId;
                                                                                                
            newFilesList.add(fileObj);
        }
        
        if(newFilesList.isEmpty() == false) {
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        SIMPESAPI.accessController().insertAsUser(newFilesList, new List<Schema.SObjectField>{
	                                                                                                    File__c.Title__c, 
	                                                                                                    File__c.Size__c,
	                                                                                                    File__c.MIME_Type__c,
	                                                                                                    File__c.Content_Version__c,
	                                                                                                    File__c.Content_Document__c,
	                                                                                                    File__c.Folder__c,
	                                                                                                    File__c.Repository__c,
	                                                                                                    File__c.URL__c,
	                                                                                                    File__c.Location__c,
	                                                                                                    File__c.Site__c
	                                                                                              });
        }
	
    }
    
    public static void createFileRecords4FeedComments(List<FeedComment> feedCommentList) {
        List<File__c> newFilesList = new List<File__c>();
        
        List<FeedComment> siteFeedCommentList = getSiteFeedCommentsWithAttachments(feedCommentList);
        
        if(siteFeedCommentList.isEmpty() == false) {
	        Map<Id, ContentVersion> contentVersionIdAndObjectMap = getContentVersionIdAndObjectMap(siteFeedCommentList);
	        //Map<Id, FeedItem> feedItemIdAndObjectMap = getFeedItemIdAndObjectMap(siteFeedCommentList);
	        
	        SiteDao siteDaoObj = new SiteDao();
	        String siteId = getSiteIdFromFeedParent(siteFeedCommentList[0].ParentId);
	        Map<String, Folder__c> mapOfSystemFolders4Site = siteDaoObj.getMapOfSystemFoldersForSite(siteId);
	        Folder__c feedFilesFolder = mapOfSystemFolders4Site.get(ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get('FEED_FILES'));
	        
	        
	        
	        for(FeedComment feedCommentObj : siteFeedCommentList) {
	            File__c fileObj = new File__c();
	            
	            fileObj.Title__c = contentVersionIdAndObjectMap.get(feedCommentObj.RelatedRecordId).Title;
	            fileObj.Size__c = contentVersionIdAndObjectMap.get(feedCommentObj.RelatedRecordId).ContentSize;
	            fileObj.MIME_Type__c = contentVersionIdAndObjectMap.get(feedCommentObj.RelatedRecordId).FileType;
	            fileObj.Content_Version__c = feedCommentObj.RelatedRecordId;
	            fileObj.Content_Document__c = (contentVersionIdAndObjectMap.get(feedCommentObj.RelatedRecordId)).ContentDocumentId;
	            fileObj.Folder__c = feedFilesFolder.Id;
	            fileObj.Repository__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
	            fileObj.Location__c = ServiceConstants.FILE_LOCATION_FEED;
	            fileObj.URL__c = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileObj.Content_Document__c, 'siteId' => siteId});
	            fileObj.Site__c = siteId;
	                                                                                                
	            newFilesList.add(fileObj);
	        }
	        
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        SIMPESAPI.accessController().insertAsUser(newFilesList, new List<Schema.SObjectField>{
	                                                                                                    File__c.Title__c, 
	                                                                                                    File__c.Size__c,
	                                                                                                    File__c.MIME_Type__c,
	                                                                                                    File__c.Content_Version__c,
	                                                                                                    File__c.Content_Document__c,
	                                                                                                    File__c.Folder__c,
	                                                                                                    File__c.Repository__c,
	                                                                                                    File__c.URL__c,
	                                                                                                    File__c.Location__c,
	                                                                                                    File__c.Site__c
	                                                                                              });
        }
    }
    
    private static List<FeedItem> getSiteFeedItemsWithAttachments(List<FeedItem> feedItemList) {
        List<FeedItem> returnList = new List<FeedItem>();
        
        String simpplrContentPrefix = Utility.getSimpplrContentPrefix();
        
        for(FeedItem feedItemObj : feedItemList) {
            String parentId = feedItemObj.ParentId;
                                    
            if(String.isNotBlank(parentId)){
                boolean isParentIdContentType = String.valueOf(parentId).startsWith(simpplrContentPrefix);
                boolean isParentIdSiteType = String.valueOf(parentId).startsWith('0F9');
                
                if((isParentIdSiteType || isParentIdContentType) && String.isNotBlank(feedItemObj.RelatedRecordId)){
                    returnList.add(feedItemObj);
                }
            }
        }
        
        return returnList;
    }
    
    private static List<FeedComment> getSiteFeedCommentsWithAttachments(List<FeedComment> feedCommentList) {
        List<FeedComment> returnList = new List<FeedComment>();
        
        String simpplrContentPrefix = Utility.getSimpplrContentPrefix();
        
        for(FeedComment feedCommentObj : feedCommentList) {
            String parentId = feedCommentObj.ParentId;
                                    
            if(String.isNotBlank(parentId)){
                boolean isParentIdContentType = String.valueOf(parentId).startsWith(simpplrContentPrefix);
                boolean isParentIdSiteType = String.valueOf(parentId).startsWith('0F9');
                
                if((isParentIdSiteType || isParentIdContentType) && 'ContentComment'.equalsIgnoreCase(feedCommentObj.CommentType) && String.isNotBlank(feedCommentObj.RelatedRecordId)){
                    returnList.add(feedCommentObj);
                }
            }
        }
        
        return returnList;
    }
    
    private static Map<Id, ContentVersion> getContentVersionIdAndObjectMap(List<FeedItem> feedItemList) {
        Set<Id> contentVersionIdsSet = new Set<Id>();
        for(FeedItem feedItemObj : feedItemList) {
                contentVersionIdsSet.add(feedItemObj.RelatedRecordId);
        }
        
        String queryStr = 'SELECT Id, Title, FileType, ContentSize, ContentDocumentId from ContentVersion where Id = :contentVersionIdsSet';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND networkid = null';
    	}
    	
		Map<Id, ContentVersion> contentVersionIdAndObjectMap = new Map<Id, ContentVersion>((List<ContentVersion>) Database.query(queryStr));
        
        return contentVersionIdAndObjectMap;
    }
    
    private static Map<Id, ContentVersion> getContentVersionIdAndObjectMap(List<String> feedItemIdList) {
        
        List<FeedAttachment> attachments =  [SELECT Id, Title, Type, FeedEntityId , RecordId FROM FeedAttachment
        		WHERE FeedEntityId IN :feedItemIdList WITH SECURITY_ENFORCED];
        Set<Id> contentVersionIdsSet = new Set<Id>();
        
        for(FeedAttachment attachObj : attachments) {
                contentVersionIdsSet.add(attachObj.RecordId);
        }
        
        String queryStr = 'SELECT Id, Title, FileType, ContentSize, ContentDocumentId from ContentVersion where Id = :contentVersionIdsSet';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND networkid = null';
    	}
    	
		Map<Id, ContentVersion> contentVersionIdAndObjectMap = new Map<Id, ContentVersion>((List<ContentVersion>) Database.query(queryStr));
        
        return contentVersionIdAndObjectMap;
    }
    
    private static Map<Id, ContentVersion> getContentVersionIdAndObjectMap(List<FeedComment> feedCommentList) {
        Set<Id> contentVersionIdsSet = new Set<Id>();
        for(FeedComment feedCommentObj : feedCommentList) {
                contentVersionIdsSet.add(feedCommentObj.RelatedRecordId);
        }
        
        String queryStr = 'SELECT Id, Title, FileType, ContentSize, ContentDocumentId from ContentVersion where Id = :contentVersionIdsSet';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND networkid = null';
    	}
    	
		Map<Id, ContentVersion> contentVersionIdAndObjectMap = new Map<Id, ContentVersion>((List<ContentVersion>) Database.query(queryStr));
        
        
        return contentVersionIdAndObjectMap;
    }
    
    private static String getSiteIdFromFeedParent(Id parentId) {
        String siteId = '';
        
        boolean isParentIdSiteType = false;
        if(String.isNotBlank(parentId)){
            if(String.valueOf(parentId).startsWith('0F9')) {
                List<Simpplr_Site__c> siteList = [SELECT Id from Simpplr_Site__c where Chatter_Group_Id__c = :parentId WITH SECURITY_ENFORCED];
                
                if(siteList.size() > 0) {
                    siteId = siteList[0].Id;
                }
            }
            else {
                List<Simpplr_Content__c> siteList = [SELECT Site__c from Simpplr_Content__c where Id = :parentId WITH SECURITY_ENFORCED];
                
                if(siteList.size() > 0) {
                    siteId = siteList[0].Site__c;
                }
            }
        }
        
        return siteId;
    }

    public List<File__c> moveFiles(String siteId, List<String> fileIdList, String destinationFolderId, String sourceFolderId){
    	List<File__c> movedFileList = null;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', sourceFolderId);
		soqlParamMap.put('soqlParam2', fileIdList);

    	String filesQuery = 'SELECT Id, Folder__c, Simpplr_Content__r.Site__c FROM File__c WHERE'+
    	 						  ' Folder__c = :soqlParam1 AND'+
    	 						  ' Folder__r.Is_System_Folder__c = false AND'+
    	 						  ' Content_Document__c IN :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

    	if(!fileList.IsEmpty()){
    		for (File__c fileObj : fileList){
    			fileObj.Folder__c = destinationFolderId;
    		} 	
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPSFDCAccessControlResults.UpdateResults result = SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), 
														new List<Schema.SObjectField>{File__c.Folder__c
																					 });
			movedFileList = (List<File__c>) result.getUpdatedObjects();																				 
    	}					  
    	 						  
    	return movedFileList;
    }
	
	public void createContentDocumentLinks(List<File__c> filesList, Set<String> setOfContentApprovers) {
    	Set<Id> contentDocumentIdsSet = getContentDocumentsIdsFromFiles(filesList);
    	
    	if(contentDocumentIdsSet.isEmpty() == false) {
	    	Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap = getLinkedEntitiesMap(contentDocumentIdsSet);
	    	
			Set<ContentDocumentLink> cdlSet = new Set<ContentDocumentLink>();
			for(String managerId : setOfContentApprovers) {
	    		cdlSet.addAll(createCDLWithUser('V', contentDocumentIdsSet, managerId, linkedEntitiesMap));     // CDL read - with user
			}
	    	logger.logDebug('FileDao.createContentDocumentLinks() ---- setOfContentApprovers ---- ' + setOfContentApprovers +  ' ---- cdlSet ---- ' + cdlSet);
	    	insertCDLsForFiles(cdlSet);
    	}
	}
	
	public void removeContentDocumentLinks(List<File__c> filesList, Set<String> setOfContentApprovers) {
    	Set<Id> contentDocumentIdsSet = getContentDocumentsIdsFromFiles(filesList);
    	Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', setOfContentApprovers);
		soqlParamMap.put('soqlParam2', contentDocumentIdsSet);
    	String query = 'SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :soqlParam1 AND ContentDocumentId = :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<ContentDocumentLink> cDLList = (List<ContentDocumentLink>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		
		if( !cDLList.isEmpty() ) {
			SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().deleteAsUser(cDLList);
		}
		
	}
	
    public void createContentDocumentLinks(String status, Boolean isPublished, List<File__c> filesList, String groupId, Boolean isPublicSite) {
    	Set<Id> contentDocumentIdsSet = getContentDocumentsIdsFromFiles(filesList);
    	
    	if(contentDocumentIdsSet.isEmpty() == false) {
	    	Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap = getLinkedEntitiesMap(contentDocumentIdsSet);
	    	
	    	Set<ContentDocumentLink> cdlSet = new Set<ContentDocumentLink>();
	    	if(ServiceConstants.CONTENT_STATUS_SUBMIITED.equalsIgnoreCase(status) || 
	    			ServiceConstants.CONTENT_STATUS_APPROVED.equals(status) || ServiceConstants.STATUS_UPDATE.equalsIgnoreCase(status)) {
	    		
	    		if(String.isNotBlank(groupId)) {
	    			if(isPublicSite) {
		    			cdlSet.addAll(createCDLWithGroup('V', contentDocumentIdsSet, linkedEntitiesMap, groupId));  // CDL read - with groupId
		    		}else {
		    			cdlSet.addAll(createCDLWithPvtGroup(contentDocumentIdsSet, linkedEntitiesMap, groupId));    // CDL read/write - with pvt groupId
		    		}
	    		} else {
	    			cdlSet.addAll(createCDLWithOrg('V', contentDocumentIdsSet, linkedEntitiesMap));     // CDL read - with orgId
	    		}
	    	}
	    	
	    	logger.logDebug('FileDao.createContentDocumentLinks() ---- cdlSet ---- ' + cdlSet);
	    	insertCDLsForFiles(cdlSet);
    	}
    }
    
    private void insertCDLsForFiles(Set<ContentDocumentLink> cdlSet) {
    	if(cdlSet.size() > 0) {
    		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>(cdlSet);
    	
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(cdlList, new List<Schema.SObjectField>{
																								ContentDocumentLink.ContentDocumentId,
																								ContentDocumentLink.ShareType,
																								ContentDocumentLink.LinkedEntityId
																							 });
    	} 
	}
	
	/**
     * @description create content doc links for files from templates
    */
	public void createContentDocumentLinks(List<File__c> filesList, String groupId, Boolean isPublicSite) {
    	Set<Id> contentDocumentIdsSet = getContentDocumentsIdsFromFiles(filesList);
    	
    	if(contentDocumentIdsSet.isEmpty() == false) {
	    	Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap = getLinkedEntitiesMap(contentDocumentIdsSet);
	    	
	    	Set<ContentDocumentLink> cdlSet = new Set<ContentDocumentLink>();
	    		
	    		if(String.isNotBlank(groupId)) {
	    			if(isPublicSite) {
		    			cdlSet.addAll(createCDLWithGroup('V', contentDocumentIdsSet, linkedEntitiesMap, groupId));  // CDL read - with groupId
		    		}else {
		    			cdlSet.addAll(createCDLWithPvtGroup(contentDocumentIdsSet, linkedEntitiesMap, groupId));    // CDL read/write - with pvt groupId
		    		}
	    		} else {
	    			cdlSet.addAll(createCDLWithOrg('V', contentDocumentIdsSet, linkedEntitiesMap));     // CDL read - with orgId
	    		}
	    	
	    	logger.logDebug('FileDao.createContentDocumentLinks() ---- cdlSet ---- ' + cdlSet);
	    	insertCDLsForFiles(cdlSet);
    	}
    }

	private List<ContentDocumentLink> createCDLWithUser(String cDLShareType, Set<Id> contentDocumentIdsSet, String managerId, Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap) {
    	List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
    	
    	
    	for(Id cdId : contentDocumentIdsSet) {
    		Map<Id, String> linkedEntityWithShareTypeMap = getLinkedEntityWithShareTypeMap(linkedEntitiesMap.get(cdId));
			if(linkedEntityWithShareTypeMap.containsKey(managerId) == false) {
				ContentDocumentLink cdLink = new ContentDocumentLink();
				cdLink.ContentDocumentId = cdId; 
				cdLink.ShareType = cDLShareType;
				cdLink.LinkedEntityId = managerId;
				cdlInsert.add(cdLink);
			}
    	}
    	
    	return cdlInsert;
    }
    
    private List<ContentDocumentLink> createCDLWithOrg(String cDLShareType, Set<Id> contentDocumentIdsSet, Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap) {
    	List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
    	String orgId = UserInfo.getOrganizationId();
    	
    	for(Id cdId : contentDocumentIdsSet) {
    		Map<Id, String> linkedEntityWithShareTypeMap = getLinkedEntityWithShareTypeMap(linkedEntitiesMap.get(cdId));
    		
    		if(linkedEntityWithShareTypeMap.containsKey(orgId) == false) {
		    	ContentDocumentLink cdLink = new ContentDocumentLink();
				cdLink.ContentDocumentId = cdId; 
				cdLink.ShareType = cDLShareType;
				cdLink.LinkedEntityId = orgId;
				cdlInsert.add(cdLink);
    		}
    	}
    	
    	return cdlInsert;
    }
    
    private List<ContentDocumentLink> createCDLWithGroup(String cDLShareType, Set<Id> contentDocumentIdsSet, Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap, String groupId) {
    	List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
    	
    	for(Id cdId : contentDocumentIdsSet) {
    		Map<Id, String> linkedEntityWithShareTypeMap = getLinkedEntityWithShareTypeMap(linkedEntitiesMap.get(cdId));
    		
    		if(linkedEntityWithShareTypeMap.containsKey(groupId) == false) {
		    	ContentDocumentLink cdLink = new ContentDocumentLink();
				cdLink.ContentDocumentId = cdId; 
				cdLink.ShareType = cDLShareType;
				cdLink.LinkedEntityId = groupId;
				cdlInsert.add(cdLink);
    		}
    	}
    	
    	return cdlInsert;
    }
    
    private List<ContentDocumentLink> createCDLWithPvtGroup(Set<Id> contentDocumentIdsSet, Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap, String groupId) {
    	List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
    	
    	Set<Id> cdIdsOwnedByMe = getContentDocumentsOwnedbyMe(contentDocumentIdsSet);
    	contentDocumentIdsSet.removeAll(cdIdsOwnedByMe);
    	
    	cdlInsert.addAll(createCDLWithGroup('C', cdIdsOwnedByMe, linkedEntitiesMap, groupId));         // CDL write - with groupId
    	cdlInsert.addAll(createCDLWithGroup('V', contentDocumentIdsSet, linkedEntitiesMap, groupId));  // CDL read  - with groupId
    	
    	
    	return cdlInsert;
    }
    
    private Set<Id> getContentDocumentsOwnedbyMe(Set<Id> contentDocumentIdsSet) {
    	Set<Id> cdIdsSet = new Set<Id>();
    	String ownerId = UserContext.Id;
    	String queryStr = 'select ContentDocumentId from ContentVersion where ContentDocumentId =:contentDocumentIdsSet AND Owner.Id = :ownerId AND Origin != \'C\' ';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND networkid = null';
    	}
    	
    	List<ContentVersion> cvList = Database.query(queryStr);
    	
    	for(ContentVersion cvObj : cvList) {
    		cdIdsSet.add(cvObj.ContentDocumentId);
    	}
    	
    	return cdIdsSet;
    }
    
    private Set<Id> getContentDocumentsIdsFromFiles(List<File__c> filesList) {
    	Set<Id> cdIdsSet = new Set<Id>();
    	
    	for(File__c fileObj : filesList) {
    		if(String.isNotBlank(fileObj.Content_Document__c) && 'CRM'.equalsIgnoreCase(fileObj.Repository__c) == false) {
    			cdIdsSet.add(fileObj.Content_Document__c);
    		}
    	}
    	
		String cdlQuery = 'SELECT Id FROM ContentDocument WHERE Id IN :soqlParam1';
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', cdIdsSet);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<SObject> results  = SIMPESAPI.accessController().queryAsUser(cdlQuery, soqlParamMap);
		Set<Id> cdIdsSetFinal = (new Map<Id,SObject>(results)).keySet();
    	return cdIdsSetFinal;    }
    
    private Map<Id, Set<ContentDocumentLink>> getLinkedEntitiesMap(Set<Id> contentDocumentIdsSet) {
    	Map<Id, Set<ContentDocumentLink>> linkedEntitiesMap = new Map<Id, Set<ContentDocumentLink>>();
    	List<ContentDocumentLink> cdLinkList = [Select Id, ContentDocumentId, ShareType, LinkedEntityId from ContentDocumentLink where ContentDocumentId = :contentDocumentIdsSet WITH SECURITY_ENFORCED];
    	
    	for(ContentDocumentLink cdLinkObj : cdLinkList) {
    		Id key = cdLinkObj.ContentDocumentId;
    		
    		Set<ContentDocumentLink> cdlSet = new Set<ContentDocumentLink>();
    		if(linkedEntitiesMap.containsKey(key)) {
    			cdlSet = linkedEntitiesMap.get(key);
    		}
    		
    		cdlSet.add(cdLinkObj);
    		linkedEntitiesMap.put(key, cdlSet);
    	}
    	
    	return linkedEntitiesMap;
    }
    
    private Map<Id, String> getLinkedEntityWithShareTypeMap(Set<ContentDocumentLink> cdlSet) {
    	Map<Id, String> returnMap = new Map<Id, String>();
    	
    	if(cdlSet != null) {
	    	for(ContentDocumentLink cdlObj : cdlSet) {
	    		returnMap.put(cdlObj.LinkedEntityId, cdlObj.ShareType);
	    	}
    	}
    	
    	return returnMap;
    }
    
    private List<Id> getImageFilesCDIds4Site(List<Id> cdIds) {
		List<Id> titleImageIds = new List<Id>(); 
		List<String> titleImageTypeToIgnore = new List<String>{ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN, ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL};
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', cdIds);
		soqlParamMap.put('soqlParam2', titleImageTypeToIgnore);
		String filesQuery = 'select Content_Document__c from File__c where Content_Document__c =:soqlParam1 And (Title_Image_Type__c=:soqlParam2 OR Simpplr_Content__r.Type__c = \'Album\')';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfSimpplrFiles = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		for(File__c simpplrFileObj : listOfSimpplrFiles) {
			titleImageIds.add(simpplrFileObj.Content_Document__c);
		}
		
		logger.logDebug('FileDao ------- getImageFilesCDIds4Site() :: ' + titleImageIds);
		return titleImageIds;
    }
    
    public List<File__c> getListOfTopAlbumImages(String contentId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
    	String filesQuery = 'SELECT Id,Content_Version__c,Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c '+
									' FROM File__c WHERE Simpplr_Content__c =:soqlParam1 AND Location__c =\'media\' AND Is_Deleted__c = false '+
									' ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, Order__c desc LIMIT 4';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		return fileList;
    }
    
    @TestVisible 
    public Map<Id, List<SiteLiteWrapper>> getCVRelatedSites(Set<Id> listOfCVIds, String provider) {
    	if('crm'.equalsIgnoreCase(provider)) {
    		return getRelatedCRMSites(true, listOfCVIds);
    	} else {
			return getRelatedSites(true, listOfCVIds);
    	}
    }
    
    @TestVisible 
    public Map<Id, List<SiteLiteWrapper>> getCDRelatedSites(Set<Id> listOfCDIds, String provider) {
    	if('crm'.equalsIgnoreCase(provider)) {
    		return getRelatedCRMSites(false, listOfCDIds);
    	} else {
    		return getRelatedSites(false, listOfCDIds);
    	}	
    } 
    
    // Function to return the SiteLiteWrapper for the content document query
    private Map<Id, List<SiteLiteWrapper>> getRelatedSites(Boolean inpCVFlag, Set<Id> listOfIds) {
    	String queryStr = '';
    	if(inpCVFlag) {
    		queryStr = 'Select Title, Id,' 
				    + ' (Select Id, LinkedEntityId, ContentDocumentId, IsDeleted, ShareType, Visibility From ContentDocumentLinks'
				    + ' where (ShareType = \'C\' or ShareType = \'V\') and IsDeleted = false and LinkedEntity.Type = \'CollaborationGroup\')' 
				    + ' From ContentDocument c where id in (Select ContentDocumentId From ContentVersion where Id in :listOfIds';
			if(SimpplrContext.isCommunitiesEnabled) {
	    		queryStr += ' AND networkid = null';
	    	}
	    	queryStr += ')';
    	} else {
    		queryStr = 'Select Title, Id,' 
				    + ' (Select Id, LinkedEntityId, ContentDocumentId, IsDeleted, ShareType, Visibility From ContentDocumentLinks'
				    + ' where (ShareType = \'C\' or ShareType = \'V\') and IsDeleted = false and LinkedEntity.Type = \'CollaborationGroup\')' 
				    + ' From ContentDocument c where id in :listOfIds';
			if(SimpplrContext.isCommunitiesEnabled) {
	    		queryStr += ' AND LatestPublishedVersion.networkid = null';
	    	}
    	}
    	
    	Map<Id, List<SiteLiteWrapper>> mapofCDIdAndRelatedSites= new Map<Id,List<SiteLiteWrapper>>();
    	
    	List<ContentDocument> lstCD = Database.query(queryStr);
    	List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
		
		// Get the Chatter Details related to the Content Document
		Map<Id,list<Id>> mapOfChatterIdAndContentDocId = new Map<Id,list<Id>>();
		for(ContentDocument cd : lstCD) {
		    if(cd.ContentDocumentLinks.size()>0){
		    	lstCDL.addAll(cd.ContentDocumentLinks);
		    	for(ContentDocumentLink cdl : cd.ContentDocumentLinks){
		    		if(cdl.ContentDocumentId==cd.id){
		    			if (!mapOfChatterIdAndContentDocId.containsKey(cdl.LinkedEntityId)) { 
   	     					mapOfChatterIdAndContentDocId.put(cdl.LinkedEntityId, new list<Id>()); 
   					    }
    					mapOfChatterIdAndContentDocId.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
		    		}
		    	}
		    }
		}
		
		List<Id> listOfChatterGroupIds= new List<Id>();
		listOfChatterGroupIds.addAll(mapOfChatterIdAndContentDocId.keySet());
		    	
		// Get the Site Details related to the Content Document
		List<Simpplr_Site__c> listOfSites = new List<Simpplr_Site__c>();
		Set<Id> setOfFollowedGrpIds = UserContext.chatterGroupsIFollowMap.keySet();
		if(!listOfChatterGroupIds.isEmpty()){
			listOfSites= [select Id, chatter_group_id__c,Name, Site_Type__c, Landing_Page__c, Title_Content_Version__c from Simpplr_Site__c where Is_Deleted__c = false and Is_Active__c = true and Chatter_Group_Id__c IN :listOfChatterGroupIds WITH SECURITY_ENFORCED];
		} 
		
		map<Id,Simpplr_Site__c> mapOfCollaborationGroupAndSite = new map<Id,Simpplr_Site__c>();
		for(Simpplr_Site__c siteObj: listOfSites){
			if('Public'.equalsIgnoreCase(siteObj.Site_Type__c) || 
				setOfFollowedGrpIds.contains(siteObj.chatter_group_id__c)) {
				mapOfCollaborationGroupAndSite.put(siteObj.chatter_group_id__c,siteObj);
			}
		}
		
		// Construct the Map of Content Document with SiteLiteWrapper
		for(ContentDocumentLink cdl : lstCDL) {
			if(mapOfCollaborationGroupAndSite.containsKey(cdl.LinkedEntityId)){
				Simpplr_Site__c siteObj = mapOfCollaborationGroupAndSite.get(cdl.LinkedEntityId);
				SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
				siteWrapObj.siteId= siteObj.id;
				siteWrapObj.name=siteObj.Name;
				siteWrapObj.url= PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.id + '/' + siteObj.Landing_Page__c;
				//siteWrapObj.fileURL = PageContext.getPageURL(Pages.FileDetail) +'?fileId=' + cdl.ContentDocumentId+'&siteId=' + siteObj.id;
				siteWrapObj.img = String.isNotBlank(siteObj.Title_Content_Version__c) ? Utility.getFileDownloadURLFor720By480(siteObj.Title_Content_Version__c) : null;
				siteWrapObj.access = siteObj.Site_Type__c; 
				siteWrapObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteObj.Site_Type__c)?true:false;
				siteWrapObj.isListed = ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteObj.Site_Type__c)?false:true;
				if(mapOfChatterIdAndContentDocId.containsKey(siteObj.chatter_group_id__c)){
					list<Id> listOfCDIds = mapOfChatterIdAndContentDocId.get(siteObj.chatter_group_id__c);
					for(Id idObj : listOfCDIds){
						if(cdl.ContentDocumentId == idObj){
							if(mapofCDIdAndRelatedSites.containsKey(idObj)) {
								List<SiteLiteWrapper> listOfSiteWrapper = mapofCDIdAndRelatedSites.get(idObj);
								listOfSiteWrapper.add(siteWrapObj);
								mapofCDIdAndRelatedSites.put(cdl.ContentDocumentId,listOfSiteWrapper);
							} else {
								mapofCDIdAndRelatedSites.put(cdl.ContentDocumentId,new List<SiteLiteWrapper>{siteWrapObj});
							}
						}
					}
				}
			}	
		}
		
		return mapofCDIdAndRelatedSites;
    }
    
    private Map<Id, List<SiteLiteWrapper>> getRelatedCRMSites(Boolean inpCVFlag, Set<Id> listOfIds) {
    	String queryStr = '';
    	if(inpCVFlag) {
    		queryStr = 'Select Title, Id,' 
				    + ' (Select Id, LinkedEntityId, ContentDocumentId, IsDeleted, ShareType, Visibility From ContentDocumentLinks'
				    + ' where ShareType = \'I\' and IsDeleted = false)' 
				    + ' From ContentDocument c where id in (Select ContentDocumentId From ContentVersion where Id in :listOfIds';
			if(SimpplrContext.isCommunitiesEnabled) {
	    		queryStr += ' AND networkid = null';
	    	}
	    	queryStr += ')';
    	} else {
    		queryStr = 'Select Title, Id,' 
				    + ' (Select Id, LinkedEntityId, ContentDocumentId, IsDeleted, ShareType, Visibility From ContentDocumentLinks'
				    + ' where ShareType = \'I\' and IsDeleted = false)' 
				    + ' From ContentDocument c where id in :listOfIds';
			if(SimpplrContext.isCommunitiesEnabled) {
	    		queryStr += ' AND LatestPublishedVersion.networkid = null';
	    	}
    	}
    	
    	Map<Id, List<SiteLiteWrapper>> mapofCDIdAndRelatedCRMSites= new Map<Id,List<SiteLiteWrapper>>();
    	
    	List<ContentDocument> lstCD = Database.query(queryStr);
    	List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
		
		// Get the Library Details related to the Content Document
		Map<Id,list<Id>> mapOfLibraryIdAndContentDocId = new Map<Id,list<Id>>();
		for(ContentDocument cd : lstCD) {
		    if(cd.ContentDocumentLinks.size()>0){
		    	lstCDL.addAll(cd.ContentDocumentLinks);
		    	for(ContentDocumentLink cdl : cd.ContentDocumentLinks){
		    		if(cdl.ContentDocumentId==cd.id){
		    			if (!mapOfLibraryIdAndContentDocId.containsKey(cdl.LinkedEntityId)) { 
   	     					mapOfLibraryIdAndContentDocId.put(cdl.LinkedEntityId, new list<Id>()); 
   					    }
    					mapOfLibraryIdAndContentDocId.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
		    		}
		    	}
		    }
		}
		
		List<Id> listOfLibraryIds= new List<Id>();
		listOfLibraryIds.addAll(mapOfLibraryIdAndContentDocId.keySet());
		    	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfLibraryIds);
		String folderQuery = 'SELECT Id, External_Folder_Id__c, Site__c, Site__r.Show_In_Simpplr__c, ' +
			' Site__r.Is_Active__c, Site__r.Chatter_group_id__c ' +
			' FROM Folder__c WHERE Type__c=\'CRM\' And Site__c != NULL   ' +
			' AND Site__r.Show_In_Simpplr__c = true AND Site__r.Is_Active__c = true And Is_Deleted__c=false ' +
			' And External_Folder_Id__c IN :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
    	
    	Set<Id> listOfSiteIds = new Set<Id>();
    	Map<Id, Set<Id>> mapOfLibraryIdToSites = new Map<Id, Set<Id>>();
    	for (Folder__c folderObj : folderList) {
    		listOfSiteIds.add(folderObj.Site__c);
			if (!mapOfLibraryIdToSites.containsKey(folderObj.External_Folder_Id__c)) { 
     			mapOfLibraryIdToSites.put(folderObj.External_Folder_Id__c, new Set<Id>()); 
			}
  			mapOfLibraryIdToSites.get(folderObj.External_Folder_Id__c).add(folderObj.Site__c);
    	}
    	
		// Get the Site Details related to the Content Document
		List<Simpplr_Site__c> listOfSites = new List<Simpplr_Site__c>();
		Set<Id> setOfFollowedGrpIds = UserContext.chatterGroupsIFollowMap.keySet();
		
		if(!listOfSiteIds.isEmpty()){
			listOfSites= [select Id, Name, chatter_group_id__c, Site_Type__c, Landing_Page__c, Title_Content_Version__c from Simpplr_Site__c where Is_Deleted__c = false and Is_Active__c = true and Id IN :listOfSiteIds WITH SECURITY_ENFORCED];
		} 
		
		map<Id,Simpplr_Site__c> mapOfSites = new map<Id,Simpplr_Site__c>();
		for(Simpplr_Site__c siteObj: listOfSites){
			if('Public'.equalsIgnoreCase(siteObj.Site_Type__c) || setOfFollowedGrpIds.contains(siteObj.chatter_group_id__c)) {
				mapOfSites.put(siteObj.id,siteObj);
			}
		}
		
		// Construct the Map of Content Document with SiteLiteWrapper
		for(ContentDocumentLink cdl : lstCDL) {
			if(mapOfLibraryIdToSites.containsKey(cdl.LinkedEntityId)) {
				for(Id linkedSiteId: mapOfLibraryIdToSites.get(cdl.LinkedEntityId)) {
					if(mapOfSites.containsKey(linkedSiteId)) {
						Simpplr_Site__c siteObj = mapOfSites.get(linkedSiteId);
						SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
						siteWrapObj.siteId= siteObj.id;
						siteWrapObj.name=siteObj.Name;
						siteWrapObj.url= PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.id + '/' + siteObj.Landing_Page__c;
						//siteWrapObj.fileURL = PageContext.getPageURL(Pages.FileDetail) +'?fileId=' + cdl.ContentDocumentId+'&siteId=' + siteObj.id;
						siteWrapObj.img = String.isNotBlank(siteObj.Title_Content_Version__c) ? Utility.getFileDownloadURLFor720By480(siteObj.Title_Content_Version__c) : null;
						siteWrapObj.access = siteObj.Site_Type__c; 
						siteWrapObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteObj.Site_Type__c)?true:false;
						siteWrapObj.isListed = ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteObj.Site_Type__c)?false:true;
						if(mapOfLibraryIdAndContentDocId.containsKey(cdl.LinkedEntityId)){
							list<Id> listOfCDIds = mapOfLibraryIdAndContentDocId.get(cdl.LinkedEntityId);
							for(Id idObj : listOfCDIds){
								if(cdl.ContentDocumentId == idObj){
									if(mapofCDIdAndRelatedCRMSites.containsKey(idObj)) {
										List<SiteLiteWrapper> listOfSiteWrapper = mapofCDIdAndRelatedCRMSites.get(idObj);
										listOfSiteWrapper.add(siteWrapObj);
										mapofCDIdAndRelatedCRMSites.put(cdl.ContentDocumentId, listOfSiteWrapper);
									} else {
										mapofCDIdAndRelatedCRMSites.put(cdl.ContentDocumentId, new List<SiteLiteWrapper>{siteWrapObj});
									}
								}
							}
						}
					}
				}	
			}
		}
		
		return mapofCDIdAndRelatedCRMSites;
	}
	public static File__c getFileRecordDetails(String fileId){
		File__c fileObj = null;

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileId);
		String filesQuery = 'SELECT id, OwnerId, Title_Image_Type__c, Description__c, Is_Title_Image__c, Thumbnail_URL__c, Simpplr_Content__c, Video_Caption_Status__c,'+
						' MIME_Type__c, Simpplr_Content__r.Site__c,Simpplr_Content__r.Site__r.Name,Simpplr_Content__r.Site__r.Landing_Page__c,External_Id__c, Repository__c, URL__c, Author__r.name, '+
						' Title__c, Site__c,Site__r.Name,Site__r.Landing_Page__c,Site__r.Has_Campaigns__c, Content_Document__c,Content_Version__c, size__c, Location__c,Author__c,Author__r.Full_Name__c,Folder__r.Name__c, '+
						' Likes__c,Simpplr_Content__r.Album_Image_Count__c,Thumbnail__c,LastModifiedDate,CreatedDate, Video_Caption_Language__c,Simpplr_Content__r.Site__r.Has_Campaigns__c,  '+
						' Simpplr_Content__r.Album_Video_Count__c,Video_Provider__c, Video_Status__c, Simpplr_Content__r.Site__r.Chatter_Group_Id__c,Simpplr_Content__r.Type__c, '+
						' Folder__c,Folder__r.name,CreatedById,Duration__c,Feed_Comment__c,Feed_Item__c,FileInfo_Last_Updated_DateTime__c,Views__c,is_Deleted__c,Folder__r.Path__c FROM File__c ' +
						' WHERE is_Deleted__c = false and External_Id__c = :soqlParam1 ORDER BY CreatedDate ASC LIMIT 1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

		if(!fileList.isEmpty()){
			fileObj = fileList[0];
		}			
		return fileObj ;
	}

	public static File__c getFileRecordDetailsWithFileId(String fileId){
		File__c fileObj = null;

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileId);
		String filesQuery = 'SELECT id,OwnerId, Title_Image_Type__c,Description__c, Is_Title_Image__c, Thumbnail_URL__c, Simpplr_Content__c,'+
						' MIME_Type__c, Simpplr_Content__r.Site__c,Simpplr_Content__r.Site__r.Name,Simpplr_Content__r.Site__r.Landing_Page__c,External_Id__c, Repository__c, URL__c, Author__r.name, '+
						' Title__c, Site__c,Site__r.Name,Site__r.Landing_Page__c, Content_Document__c,Content_Version__c, size__c, Location__c,Author__c,Folder__r.Name__c, '+
						' Likes__c,Simpplr_Content__r.Album_Image_Count__c,Thumbnail__c,LastModifiedDate,CreatedDate, Video_Caption_Language__c,  '+
						' Simpplr_Content__r.Album_Video_Count__c,Video_Provider__c, Video_Status__c, Simpplr_Content__r.Site__r.Chatter_Group_Id__c,Simpplr_Content__r.Type__c, '+
						' Folder__c,Folder__r.name,CreatedById,Duration__c,Feed_Comment__c,Feed_Item__c,FileInfo_Last_Updated_DateTime__c,Views__c,is_Deleted__c,Folder__r.Path__c FROM File__c WHERE is_Deleted__c = false and Id = :soqlParam1  LIMIT 1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

		if(!fileList.isEmpty()){
			fileObj = fileList[0];
		}			
		return fileObj ;
	}
	
	public static List<SiteLiteWrapper> getListOfSites(String fileId){
		List<SiteLiteWrapper> listOfSites = new List<SiteLiteWrapper>();
		Set<Id> siteIdSet = UserContext.sitesIFollowIdSet;
    	String loggedInPeopleId = UserContext.peopleId;
		String unlistedCondition ='';
		String systemAdminCondition ='';
		if(UserContext.hasManageUnlistedSitePermission ){ 
			unlistedCondition = ' OR site__r.site_type__c =\'Unlisted\''	;	
		}
		if(UserContext.hasModifyAllDataPermission ){
			systemAdminCondition = ' OR site__r.site_type__c =\'private\''	;	
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileId);
		soqlParamMap.put('soqlParam2', siteIdSet);
		soqlParamMap.put('soqlParam3', loggedInPeopleId);
		String filesQuery = 'SELECT id,OwnerId, Simpplr_Content__c,site__r.site_type__c,Simpplr_Content__r.Primary_Author__c,External_Id__c, Repository__c,'+
						' Site__c,Site__r.Name,Site__r.Landing_Page__c FROM File__c WHERE is_Deleted__c = false and External_Id__c = :soqlParam1 '+
						' and Site__c != null AND ( site__r.is_Active__c=true And (site__c IN:soqlParam2 or site__r.site_type__c =\'Public\''+unlistedCondition + systemAdminCondition+'))  Order by Site__r.Name';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		Set<String> sitesUniqueIdsSet = new Set<String>();
		for(File__c fileObj : fileList){
			if(!string.isBlank(fileObj.site__c) && !sitesUniqueIdsSet.contains(fileObj.site__c)){
				SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
				siteWrapObj.siteId = fileObj.site__c ;
				siteWrapObj.name = fileObj.site__r.Name ;
				siteWrapObj.access = fileObj.site__r.site_type__c;
				siteWrapObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + fileObj.site__c + '/' + fileObj.site__r.Landing_Page__c ;
				listOfSites.add(siteWrapObj);
				sitesUniqueIdsSet.add(fileObj.site__c);
			}
		}

		return listOfSites ;
	}

	public static Void SoftDeleteVideoFileRecord(File__c FileObj){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', FileObj.External_Id__c);
		String filesQuery = 'Select id, External_Id__c From File__c where External_Id__c =: soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		List<File__c> fileRecordToUpdate = new List<File__c>();
		for(File__c fileRecord : fileList) {
			fileRecord.is_Deleted__c = true;
			fileRecordToUpdate.add(fileRecord);
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileRecordToUpdate), new List<Schema.SObjectField>{
													File__c.Is_Deleted__c
													});
	}

	public Void unbookmarkFileForAllUsers (String fileIdArg, String context) {
		List<Bookmark__c> listOfBookmark = [SELECT Id , Is_Deleted__c
											FROM Bookmark__c 
											WHERE External_File_Id__c =: fileIdArg
											And Type__c = :context
											And Is_Deleted__c = false WITH SECURITY_ENFORCED]; 
		if (!listOfBookmark.isEmpty()) {
			for(Bookmark__c bookmarkObj : listOfBookmark){
		    	bookmarkObj.Is_Deleted__c = true;
	    	}
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
   			SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(listOfBookmark), new List<Schema.SObjectField>{Bookmark__c.Is_Deleted__c});
		}
	}

	public List<File__c> getSiteVideoFiles(Criteria.File fileCriteriaObjArg, Integer recordLimit) {
		String siteId = fileCriteriaObjArg.siteId;
		String folderId = fileCriteriaObjArg.directory;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', folderId);
		String query =  'SELECT id,OwnerId, Title_Image_Type__c,Description__c, Is_Title_Image__c, Thumbnail_URL__c, ' +
						'MIME_Type__c, Simpplr_Content__r.Site__c,External_Id__c, Repository__c, URL__c, ' +
						'Title__c, Site__c, size__c, Likes__c,Thumbnail__c,LastModifiedDate,Video_Provider__c, ' +
						'CreatedDate, Author__c, Author__r.name, Author__r.Full_Name__c, Video_Status__c, Folder__c, Folder__r.Path__c ' +
						'FROM File__c WHERE is_Deleted__c = false and Site__c = :soqlParam1 ';


		query += 'AND Folder__c = :soqlParam2 ';
		if(String.isNotBlank(fileCriteriaObjArg.sortby)) {
			String orderByField = '';
	        String order = '';
	        if (fileCriteriaObjArg.sortby.equalsIgnoreCase('alphabetical')) {
	        	orderByField = 'Title__c';
	        	order = 'ASC';
			}else if (fileCriteriaObjArg.sortby.equalsIgnoreCase('createdNewest') || 
						fileCriteriaObjArg.sortBy.equalsIgnoreCase('createdOldest')) {							
				orderByField = 'CreatedDate';
		    	order = fileCriteriaObjArg.sortBy.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';
			
			} else if (fileCriteriaObjArg.sortby.equalsIgnoreCase('modifiedNewest') || 
						fileCriteriaObjArg.sortby.equalsIgnoreCase('modifiedOldest')) {
            	orderByField = 'LastModifiedDate';
		        order = fileCriteriaObjArg.sortBy.equalsIgnoreCase('modifiedNewest')? 'DESC' : 'ASC';
			}
			query += ' ORDER BY '+orderByField+' '+order;	
		}
		if(recordLimit != null && recordLimit > 0) {
			soqlParamMap.put('soqlParam3', recordLimit);
			query += ' LIMIT :soqlParam3 ';
		}
		if(fileCriteriaObjArg.offset != null) {
			query += ' offset '+ fileCriteriaObjArg.offset;
		}
		
		logger.logDebug('FileDao.getSiteVideoFiles----query----' + query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		return listOfFile;
	}

	Public String getSiteVideosFolderId(String siteId) {
		String siteVideosFolderId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', FILE_TYPE_NATIVE_VIDEOS_FILES);
		String folderQuery = 'select id from Folder__c where is_system_folder__c=true And site__c=:soqlParam1 And Type__c=:soqlParam2 And Name__c=\'Site Videos\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!folderList.isEmpty()) {
			siteVideosFolderId = folderList[0].id;
		}
		return siteVideosFolderId;
	}

	Public void moveVideoFiles(String siteId, List<String> fileIdList, String destination, String source) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileIdList);
		soqlParamMap.put('soqlParam2', source);
		soqlParamMap.put('soqlParam3', siteId);
		String filesQuery = 'select id, Folder__c from File__c'+
								' Where External_id__c=:soqlParam1'+
								' And Folder__c=:soqlParam2'+
								' And Site__c =:soqlParam3 and Is_Deleted__c=false';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		for(File__c fileObj:fileList) {
			fileObj.Folder__c=destination;
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{
														File__c.Folder__c
													});
	}

	public List<File__c> getContentTemplateFiles(Id templateId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', templateId);
		String filesQuery = 'select id, Location__c, Content_Document__c, Repository__c, '+
								' Is_Title_Image__c, Content_Version__c, MIME_Type__c'+
								' from File__c'+
								' where is_deleted__c = false'+
								' And Content_Template__c=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		return fileList;
	}

	public List<FileListingWrapper> getAlbumMediaByVersionId(String albumId, String versionId) {
		List<FileListingWrapper> fileWrapperObjList = new List<FileListingWrapper>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', albumId);
		soqlParamMap.put('soqlParam2', Decimal.valueOf(versionId));
		String query = 'SELECT Id, Content__c, File_Json__c, File_Json_Part1__c, File_Json_Part2__c,File_Json_Part3__c, Version__c '+
							' FROM Content_History__c WHERE Content__c = :soqlParam1 AND Version__c  = :soqlParam2 AND IsDeleted = false';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_History__c> albumHistoryList = (List<Content_History__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		
		if(!albumHistoryList.isEmpty() && albumHistoryList.size() > 0) {
			ManageContentDao contentDao = new ManageContentDao();
			if(String.isNotBlank(albumHistoryList[0].File_Json__c)){
				String fileJsonStr = contentDao.mergeContentHistoryJsonStrings(albumHistoryList[0], 'file');
				String unescapedFileJsonStr = fileJsonStr.unescapeUnicode();
				List<File__c> fileList;
			
				try{
					fileList = (List<File__c>) JSON.deserialize(unescapedFileJsonStr, Type.forName('List<File__c>'));
				}catch(Exception e) {          
					fileList = (List<File__c>) JSON.deserialize(fileJsonStr, Type.forName('List<File__c>'));
				}
				for (File__c fileObj : fileList){
					
					if (ServiceConstants.FILE_MIME_TYPE_IMAGE.equalsIgnoreCase(fileObj.MIME_Type__c) || 
							ServiceConstants.FILE_MIME_TYPE_VIDEO.equalsIgnoreCase(fileObj.MIME_Type__c)) {
						FileListingWrapper fileWrapObj = ObjectToWrapperAdapter.fileToWrapperWithoutIsLiked(fileObj);
						fileWrapObj.isLiked = false;
						fileWrapperObjList.add(fileWrapObj);
					}

				}
				
			}
		}
		return fileWrapperObjList;
	}
}