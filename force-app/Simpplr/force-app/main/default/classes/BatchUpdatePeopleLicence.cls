/**
 *  @description This batch class updates the People Object Has_Simpplr_License__c field based on UserId From UserPackageLicense
 */
public with sharing class BatchUpdatePeopleLicence implements Database.Batchable<SObject> {
    /**
     * @description  exceptionDetailsObj should hold the exception details about the exception.
     */
    private Exception exceptionDetailsObj;
    private String batchType;

    /**
     * @description constructor
     * @param batchType
     */
    public BatchUpdatePeopleLicence(String batchType) {
        this.batchType = batchType;
    }

    /**
     * @description This is start method of this batch class.
     * @return QueryLocator object. 
     * @param Database.BatchableContext object.
     */
    public database.querylocator start(Database.BatchableContext bc){
        String query;
        String packageName = SimpplrContext.packageName;
        if('syncLicenseFlagToTrue'.equalsIgnoreCase(batchType)) {
            query = 'SELECT id, Has_Simpplr_License__c, Last_Edited_DateTime__c FROM People__c'
                + ' WHERE Has_Simpplr_License__c = false and User__r.IsActive = true';
            if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
                query += ' AND User__c in (select UserId from UserPackageLicense where PackageLicense.NamespacePrefix = :packageName)';
            }

        } else if('syncLicenseFlagToFalse'.equalsIgnoreCase(batchType)) {
            query = 'SELECT id, Has_Simpplr_License__c, Last_Edited_DateTime__c FROM People__c'
                + ' WHERE Has_Simpplr_License__c = true and User__r.IsActive = true'
                + ' AND User__c not in (select UserId from UserPackageLicense where PackageLicense.NamespacePrefix = :packageName)';
        }
    	return Database.getQueryLocator(query);
    }
    /**
     * @description This is execute method of this batch class.
     * @param Database.BatchableContext object 
     * @param Array of sObject object.
     */
    public void execute(Database.BatchableContext bc, sObject[] objects){
    	try {
            if('syncLicenseFlagToTrue'.equalsIgnoreCase(batchType)) {
                List<People__c> peopleList = (List<People__c>)objects;
                updateLicenseFlagValue(peopleList, true);
    
            } else if('syncLicenseFlagToFalse'.equalsIgnoreCase(batchType)) {
                List<People__c> peopleList = (List<People__c>)objects;
                updateLicenseFlagValue(peopleList, false);
            }
        } catch(Exception ex) {
            exceptionDetailsObj =  ex;
            throw ex;
        }
    }
    /**
     * @description This is finish method of this batch class.
     * @param Database.BatchableContext object
     */
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        if(!currentJob.Status.equalsIgnoreCase('Completed') && currentJob.NumberOfErrors > 0) {
            Utility.sendExceptionEmail('BatchUpdatePeopleLicence -> ' + batchType, exceptionDetailsObj);
        }
        if('syncLicenseFlagToTrue'.equalsIgnoreCase(batchType) && String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false) {
            BatchUpdatePeopleLicence updatePeopleLicenseJob = new BatchUpdatePeopleLicence('syncLicenseFlagToFalse');
		    Database.executeBatch(updatePeopleLicenseJob, 5);
        }
    }
    
    /**
     * @description updateLicenseFlagValue
     * @param peopleList
     * @param licenseFlagValue
     */
    private void updateLicenseFlagValue(List<People__c> peopleList, Boolean licenseFlagValue) {
        for(People__c peopleObj : peopleList) {
            peopleObj.Has_Simpplr_License__c = licenseFlagValue;
            peopleObj.Last_Edited_DateTime__c = Datetime.now();
        }
        update peopleList;
    }
}