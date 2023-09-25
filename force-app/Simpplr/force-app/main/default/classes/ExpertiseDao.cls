/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ExpertiseDao{
	
    public ExpertiseDao() {

    }
    
	public List<People_Expertise__c> getPeopleExpertisesById(List<String> expertiseIds) {
        List<People_Expertise__c> peopleExpertiseList = [SELECT Id, Expertise__c, Is_Self_Endorsed__c, People__c, Endorser_Count__c 
                                                            FROM People_Expertise__c where Expertise__c = :expertiseIds WITH SECURITY_ENFORCED];
    	return peopleExpertiseList;
    }
    
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Expertise__c> getExpertiseWithCriteria(String searchText,String orderByField,String order,Integer recordLimit, Integer offsetVal){
    	List<String> fieldList = New List<String>{
            'Id',
            'Name__c', 
            'Display_Name__c',
            'CreatedBy.Id', 
            'CreatedBy.Name',
            'User_Count__c'
        };
        String conditionString = '';
        if(String.isNotBlank(searchText)){
	        	Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
	        	String andClause = '';
	        	for(String searchToken: searchTokens){
		    		conditionString += andClause + ' Name__c like \'%'+searchToken+'%\' ';
		    		andClause = ' And ';
		    	}   
        }
        
        if(String.isNotBlank(conditionString)){
            conditionString = ' WHERE'+conditionString;
        }
        String subConditionString = '';
        if(String.isBlank(order)){
            order = 'DESC';
        }
        if(String.isNotBlank(orderByField)){
            subConditionString+=' ORDER BY ' + orderByField + ' ' + order + ', CreatedDate DESC';
        }
        if(recordLimit != null && recordLimit > 0){
            subConditionString+=' LIMIT :recordLimit';
        }
        if(offsetVal != null && offsetVal > 0){
            subConditionString+=' OFFSET :offsetVal';
        }


        String query = 'SELECT '+String.join(fieldList,',')+' FROM Expertise__c '+conditionString+subConditionString;
        logger.logDebug('ExpertiseDao.getExpertiseWithCriteria()----query----' + query);
        return Database.query(query); 
    }
    
    public Boolean deleteExpertise(List<String> expertiseIdList) {
        List<Expertise__c> expertiseList = new List<Expertise__c>();

        for(String expertiseId : expertiseIdList) {
            Expertise__c expertiseObj = new Expertise__c(Id = expertiseId);
            expertiseList.add(expertiseObj);
        }
        
        if( !expertiseList.isEmpty() ) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().deleteAsUser(expertiseList);
        }

        return true;
    }

    public Boolean mergeExpertises(String fromExpertiseId, String toExpertiseId) {
        List<People_Expertise__c> peopleExpertiseList = [SELECT Id, Expertise__c from People_Expertise__c WHERE Expertise__c = :fromExpertiseId WITH SECURITY_ENFORCED];
        RecursionCheck.stopRecursion();
        if (!peopleExpertiseList.isEmpty()) {

            for(People_Expertise__c pEObj : peopleExpertiseList) {
                pEObj.Expertise__c = toExpertiseId;
            }

    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<id, People_Expertise__c>(peopleExpertiseList), 
												        new List<Schema.SObjectField>{
														    People_Expertise__c.Expertise__c});
        }
        
        removeDuplicateExperts(toExpertiseId);
        
        List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
        if(SimpplrContext.isFeatureEnabled('Full_External_Search')){
	    	External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
			obj.Expertise__c = toExpertiseId;
	    	obj.Type__c = 'Expertise';
			listToInsert.add(obj);

            if(listToInsert.isEmpty() == false){

                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
                    External_Search_Data_Trail__c.Expertise__c,
                    External_Search_Data_Trail__c.Type__c});
            }
            
        }
        RecursionCheck.allowTorun();
        deleteExpertise(new List<String>{fromExpertiseId});
        
        return true;
    }

    private Boolean removeDuplicateExperts(String toExpertiseId) {
        List<String> allPEPeopleIds = new List<String>();
        List<String> toBeDeletedPEIds = new List<String>();
        
        List<People_Expertise__c> peopleExpertiseList = [SELECT Id, People__c, Expertise__c from People_Expertise__c WHERE Expertise__c = :toExpertiseId WITH SECURITY_ENFORCED];

        for(People_Expertise__c peopleExpertiseObj : peopleExpertiseList) {
            if(allPEPeopleIds.contains(peopleExpertiseObj.People__c)) {
                toBeDeletedPEIds.add(peopleExpertiseObj.Id);
            } else {
                allPEPeopleIds.add(peopleExpertiseObj.People__c);
            }
        }

        deletePeopleExpertise(toBeDeletedPEIds);

        return true;
    }

    private Integer deletePeopleExpertise(List<String> pEIdsList) {
        List<People_Expertise__c> pEList = new List<People_Expertise__c>();

        for(String peId : pEIdsList) {
            People_Expertise__c pEObj = new People_Expertise__c(Id = peId);
            pEList.add(pEObj);
        }
        
        if( !pEList.isEmpty() ) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().deleteAsUser(pEList);
        }

        return pEList.size();
    }

    public Boolean removeExpertiseFromProfile(String expertiseId, String peopleId) {
        List<People_Expertise__c> peopleExpertiseList = [SELECT Id, People__c, Expertise__c from People_Expertise__c WHERE Expertise__c= :expertiseId AND People__c = :peopleId WITH SECURITY_ENFORCED LIMIT 1];
        if (!peopleExpertiseList.isEmpty()) {
            //hide expertise from user's profile
            if(UserContext.peopleId.equalsIgnorecase(peopleExpertiseList[0].People__c)) {
                for(People_Expertise__c pEObj : peopleExpertiseList) {
                    pEObj.Is_Self_Hidden__c = true;
                    pEObj.Is_Self_Endorsed__c = false;
                }
            
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<id, People_Expertise__c>(peopleExpertiseList), 
                                                            new List<Schema.SObjectField>{
                                                                People_Expertise__c.Is_Self_Hidden__c,
                                                                People_Expertise__c.Is_Self_Endorsed__c});
            }

            String peopleExpertiseId = peopleExpertiseList[0].Id;
            List<People_Expertise_Detail__c> pEDlist = [SELECT Id FROM People_Expertise_Detail__c WHERE People_Expertise__c = :peopleExpertiseId WITH SECURITY_ENFORCED];
            
            if (!pEDlist.isEmpty()) {
                
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(pEDlist);
            }
        }

        return true;
    }

    public Expertise__c getExpertiseById(String expertiseId) {
        Expertise__c expertiseList = [SELECT Id, User_Count__c from Expertise__c WHERE id= :expertiseId WITH SECURITY_ENFORCED LIMIT 1];
        return expertiseList;
    }
}