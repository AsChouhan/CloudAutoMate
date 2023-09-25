/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PeopleCategoryDao{

	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<People_Category__c> getPeopleCategory(Integer offset, Integer recordLimit, String term, String sortBy){
        Map<String, Object> sqlParamMap = new Map<String, Object>();
        String queryStr = 'SELECT id, Is_Deleted__c, Name__c, ';
    	
        if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' (SELECT id FROM Simpplr_People__r WHERE User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\' AND User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' (SELECT id FROM Simpplr_People__r WHERE User__r.Show_Simpplr__c =\'Yes\' OR (User__r.Show_Simpplr__c != \'No\' AND User__r.isActive=true AND User__r.UserType=\'Standard\')) ';
		}
    	
        queryStr += ' FROM People_Category__c WHERE Is_Deleted__c = false ';

    	if(String.isNotBlank(term)){
    		term = '%' + term + '%';
    		queryStr += ' And Name__c like :soqlParam1 ';
            sqlParamMap.put('soqlParam1', term);
    	}
    	if (String.isBlank(sortBy) || 'alphabetical'.equalsIgnoreCase(sortby)) {
        	queryStr += ' Order by Name__c asc '; 
        } else {
        	queryStr += ' Order by lastModifiedDate desc ';
		}
    	queryStr += ' limit :soqlParam2 offset :soqlParam3 ';
        sqlParamMap.put('soqlParam2', recordLimit);
        sqlParamMap.put('soqlParam3', offset);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Category__c> listOfPeopleCategory = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(queryStr, sqlParamMap);
        return listOfPeopleCategory;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public People_Category__c savePeopleCategory(PeopleCategoryListingWrapper peopleCategoryObj){
		People_Category__c peopleCategoryConf= new People_Category__c();
		peopleCategoryConf.Name__c=peopleCategoryObj.name;
		peopleCategoryConf.Name=peopleCategoryObj.name;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		peopleCategoryConf = (People_Category__c) SIMPESAPI.accessController().insertAsUser(peopleCategoryConf, 
								new List<Schema.SObjectField>{People_Category__c.Name__c});
		return peopleCategoryConf;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void deletePeopleCategory(List<String> listOfPageCategoryIds){
    		List<People_Category__c> listOfPeopleCategoryObject= new List<People_Category__c>();
    		for(String peopleCategoryId : listOfPageCategoryIds) {
	    		People_Category__c categoryObj = new People_Category__c();
	    		categoryObj.Id=peopleCategoryId;
	    		categoryObj.Is_Deleted__c=true;
	    		listOfPeopleCategoryObject.add(categoryObj);
    		}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,People_Category__c>(listOfPeopleCategoryObject), 
													  new List<Schema.SObjectField>{
															People_Category__c.Is_Deleted__c});
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
     public void renamePeopleCategory(PeopleCategoryListingWrapper listOfPageCategoryIds){
     		
    		List<People_Category__c> listOfPeopleCategoryObject= new List<People_Category__c>();
    		People_Category__c categoryObj = new People_Category__c();
    		categoryObj.Id=listOfPageCategoryIds.id;
    		categoryObj.Name__c=listOfPageCategoryIds.name;
    		listOfPeopleCategoryObject.add(categoryObj);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,People_Category__c>(listOfPeopleCategoryObject), 
													  new List<Schema.SObjectField>{
															People_Category__c.Name__c});
    }
    
}