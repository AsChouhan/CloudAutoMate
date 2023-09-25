public with sharing class QuestionDao {
	public QuestionDao() {}

	
	public List<String> getQuestionFieldList() {
		
    	List<String> fieldList = new List<String>{
    		'Id', 'Title__c', 'Description__c', 'Questioned_By__c', 'Site__c', 'Parent_Question__c', 'Is_Published__c', 'Is_Duplicate__c',
            'Publish_DateTime__c', 'Last_Edited_DateTime__c', 'Questioned_By__r.user__r.Id', 'Questioned_By__r.First_Name__c', 
			'Questioned_By__r.Community_Nickname__c', 'Questioned_By__r.Last_Name__c',
            'Questioned_By__r.Full_Name__c', 'Questioned_By__r.user__r.SmallPhotoURL', 'Questioned_By__r.user__r.MediumPhotoUrl',
            'Questioned_By__r.user__r.FullPhotoURL', 'Questioned_By__r.Department__c', 'Questioned_By__r.About__c', 'Questioned_By__r.Street__c',
			'Questioned_By__r.Title__c', 'Questioned_By__r.City__c', 'Questioned_By__r.State__c', 'Questioned_By__r.Country__c',
			'Questioned_By__r.Email__c', 'Questioned_By__r.Phone__c', 'Questioned_By__r.mobile_phone__c','Questioned_By__r.extension__c',
            'Questioned_By__r.Birth_Date__c', 'Questioned_By__r.Joining_Date__c', 'Questioned_By__r.User__c', 'Questioned_By__r.User__r.isactive', 
            'Site__r.name', 'Site__r.Is_Active__c', 'Site__r.Chatter_Group_Id__c', 'Site__r.Site_Type__c', 'Site__r.Landing_Page__c',
            'Site__r.Title_Content_Version__c'
        };

		return fieldList;
	}
	
	private final String BASE_QUERY = 'SELECT '+String.join(getQuestionFieldList(),',')+
                	' FROM Question__c ' +
		            ' WHERE Is_Deleted__c = false '+
		            ' And Site__r.Is_Active__c = true ' + 
		            ' And Site__r.Show_In_Simpplr__c = true ';
    

    public Question__c getQuestionById(String questionId){
		String queryStr = BASE_QUERY;
		queryStr += ' And id =: questionId LIMIT 1';
        Question__c queryResult = Database.query(queryStr);
		return queryResult;
    }

    public static List<Question__c> getQuestionList(QuestionWrapper requestWrapperRecord){
        return [SELECT Id, Title__c, Description__c, Questioned_By__c, Site__c FROM Question__c WHERE Is_Deleted__c = false WITH SECURITY_ENFORCED];
    }

    public static List<File__c> getFilesByQuestionId(String questionId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', questionId);
		String filesQuery = 'SELECT id, Title_Image_Type__c,Description__c, Is_Title_Image__c, Thumbnail_URL__c, '+
									' MIME_Type__c, Question__r.Site__c,External_Id__c, Repository__c, URL__c, '+
									' Title__c, Site__c, Content_Document__c,Content_Version__c, size__c, Location__c,'+
									' Likes__c, Video_Status__c, is_Deleted__c'+
									' FROM File__c WHERE is_Deleted__c = false '+
									' AND Question__c = :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		return fileList;
	}

	public List<Question__c> getQuestionSearchResults(Criteria.Question criteriaObjArg){
		String loggedInUserPeopleId = UserContext.peopleId;
		String siteId = criteriaObjArg.siteId;
		String filter = criteriaObjArg.filter;
		Integer recordLimit = criteriaObjArg.size + 1;
		Integer offset = criteriaObjArg.offset;
		String sortBy = criteriaObjArg.sortBy;
		String queryStr = BASE_QUERY;
		Set<String> setOfSearchTerms = String.isNotBlank(criteriaObjArg.term) ? Utility.getSearchTokens(String.escapeSingleQuotes(criteriaObjArg.term)) : null;
		if('duplicate'.equalsIgnoreCase(filter)){
			queryStr += ' And Is_Duplicate__c = false';
			recordLimit = 10;
		}
		queryStr += getSearchTermCondition(setOfSearchTerms);
		queryStr += getSiteCondition(siteId);
		queryStr += getSortOrderCondition(sortBy);
		queryStr += getLimitOffsetCondition(recordLimit, null);
		
		logger.logDebug('QuestionDao.getQuestionSearchResults()----queryStr----' + queryStr);
		List<Question__c> queryResult = Database.query(queryStr);

		return queryResult;
	}
	
	private String getSearchTermCondition(Set<String> setOfSearchTerms){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms){
				queryStr += ' And Title__c like \'%'+searchToken+'%\' ';
			}
        }
        return queryStr;
	}

	private String getSiteCondition(String siteId){
		String queryStr = '';
		if(String.isNotBlank(siteId)){
			queryStr += ' And (site__c=: siteId OR Site__r.site_type__c = \'public\') ';
		}
    	return queryStr; 
	}
	
	private String getSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			
		}else{
			queryStr += 'order by  Publish_DateTime__c desc, Last_Edited_DateTime__c desc, Title__c asc ';
		}
        return queryStr;
	}

	private String getLimitOffsetCondition(Integer recordLimit, Integer offset){
		String	queryStr = '';
		if(recordLimit!=null && offset!=null) {
			queryStr += ' limit :recordLimit  offset :offset';
		}
		return queryStr;
	}
}