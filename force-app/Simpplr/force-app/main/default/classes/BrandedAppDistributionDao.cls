/**
 * @description BrandedAppDistributionDao data access for object Branded App distribution
 */
public with sharing class BrandedAppDistributionDao {

    /**
     * @description getAllCodes is used to get all codes
     * @return List<Branded_App_Distribution__c> list of codes
     */    
    public List<Branded_App_Distribution__c> getAllCodes(){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        String query = 'SELECT Id, Is_Used__c ' +
            ' FROM Branded_App_Distribution__c ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return (List<Branded_App_Distribution__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

    }

    /**
     * @description getCountOfUnusedCodesByCountry is used to get no of codes by country
     * @return List<AggregateResult> 
     */
    public  List<AggregateResult> getCountOfCodesByCountry(){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        String query = 'SELECT  count(id)c, Country__c country' +
            ' FROM Branded_App_Distribution__c '+
            ' GROUP BY Country__c';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    }

    /**
     * @description getUsedCodes to get all used codes
     * @return List<Branded_App_Distribution__c> list of codes
     */
    public List<Branded_App_Distribution__c> getUsedCodes(){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        String query = 'SELECT Id, people__c ' +
            ' FROM Branded_App_Distribution__c '+
            ' WHERE people__c != NULL ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        return (List<Branded_App_Distribution__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    }

    /**
     * @description getExistingAppDistributionCode to get code using people_id
     * @param peopleId 
     * @return List<Branded_App_Distribution__c> list of codes
     */
    public List<Branded_App_Distribution__c> getExistingAppDistributionCode(String peopleId)	{
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleId);
		String query = 'SELECT Id, Code__c,  Link__c ' +
			' FROM Branded_App_Distribution__c '+
			' WHERE People__c =: soqlParam1 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Branded_App_Distribution__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	}

    /**
     * @description getAppDistributionCodeUsingCountry to get code using country
     * @param userCountry 
     * @return List<Branded_App_Distribution__c> list of codes
     */
    public List<Branded_App_Distribution__c> getAppDistributionCodeUsingCountry(String userCountry){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam2', userCountry);
		String query = 'SELECT Id, Type__c, Code__c,  Country__c,  Email__c,  Is_Used__c,  Link__c,  Phone__c, People__c ' +
			' FROM Branded_App_Distribution__c '+
			' WHERE Country__c =: soqlParam2 AND '+
			' Is_Used__c = false LIMIT 1 FOR UPDATE';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Branded_App_Distribution__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	}
    /**
     * @description codeCount to get code using country
     * @return Integer all Code Count
     */
    public Integer codeCount(){
        return database.countQuery('select count() from Branded_App_Distribution__c');
    }
    /**
     * @description unUsedCodeCount to get code using country
     * @return Integer unusedCodeCount
     */
    public Integer unUsedCodeCount(){
        return database.countQuery('select count() from Branded_App_Distribution__c WHERE Is_Used__c = False');
    }
    
}