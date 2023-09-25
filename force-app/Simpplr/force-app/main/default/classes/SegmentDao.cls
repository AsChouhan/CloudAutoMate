public with sharing class SegmentDao {
    
 	public String packageName = SimpplrContext.packageName;
 	
    public static List<People__c> getSegmentMembersForSaveManager (String segmentId, Set<Id> managerIdSet) {
    	List<People__c> peopleList = new List<People__c>();
    	peopleList = [SELECT Id, Is_Segment_Manager__c 
    			FROM People__c 
    			WHERE (Segment__c = :segmentId) AND 
    			((Id IN :managerIdSet AND Is_Segment_Manager__c = FALSE) OR 
    			((Id NOT IN :managerIdSet) AND Is_Segment_Manager__c = TRUE)) WITH SECURITY_ENFORCED];
    		
    	return 	peopleList;
    }
    
    public static void updatePeopleList (List<People__c> peopleListToUpdate) {
    	
    	if (!peopleListToUpdate.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(peopleListToUpdate), new List<Schema.SObjectField>{
				People__c.Is_Segment_Manager__c
			});
    	}
    		
    }
    
    public List<PeopleListWrapper> getUnassignedSegmentUsers(String profileField) {
    	List<PeopleListWrapper> listOfUnassignedSegmentUsers = new List<PeopleListWrapper>();
    	
	String queryString = 'SELECT Id, Full_Name__c, Email__c, Company_Name__c, Division__c, ' + 
				' Department__c, City__c, State__C, Country__c' + 
				' FROM People__c WHERE segment__c = null AND User__r.IsActive = true AND' + 
				' User__r.UserType = \'Standard\' ' ;
    	if (String.isNotBlank(profileField)) {
	    	queryString += ' And '+  profileField + '= null ';
    	}
	   
	    if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 queryString += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		} 	
    	
    	List<People__c> listOfUnassignedSegmentPeople = Database.query(queryString);
    	
		for (People__c peopleRec: listOfUnassignedSegmentPeople) {
			PeopleListWrapper unassignedUser = new PeopleListWrapper();
			unassignedUser.name = peopleRec.Full_Name__c;
			unassignedUser.email = peopleRec.Email__c;
			unassignedUser.companyName = peopleRec.Company_Name__c; 
			unassignedUser.division = peopleRec.Division__c;
			unassignedUser.department = peopleRec.Department__c;
			unassignedUser.city = peopleRec.City__c;
			unassignedUser.state = peopleRec.State__C;
			unassignedUser.country = peopleRec.Country__c;
			listOfUnassignedSegmentUsers.add(unassignedUser);
		}
		
		return listOfUnassignedSegmentUsers;
    }

    
    public List<Segment__c> getSegmentsByIds (List<String> listOfSegmentId) {
        String queryStr = 'SELECT Id, Name__c FROM Segment__C  WHERE Id IN:listOfSegmentId';
        List<Segment__C> listOfSegment = new List<Segment__C>();
        listOfSegment = Database.query(queryStr);
        return listOfSegment;
    } 

}