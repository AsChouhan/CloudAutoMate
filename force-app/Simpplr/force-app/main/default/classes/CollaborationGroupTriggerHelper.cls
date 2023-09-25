public without sharing class CollaborationGroupTriggerHelper {
    
    public static void createUserGroup(List<String> contentObjectNameList, List<CollaborationGroup> listOfCollaborationGroups) {
    	List<Group> listOfUserGroups = new List<Group>();
    	Map<String, String> mapOfOfGroupNamesAndOwnerId = new Map<String, String>();  
    	for(CollaborationGroup cg:listOfCollaborationGroups) {
    		mapOfOfGroupNamesAndOwnerId.put('Simpplr_' + cg.Id + '_Standard', cg.OwnerId);
    		mapOfOfGroupNamesAndOwnerId.put('Simpplr_' + cg.Id + '_Admin', cg.OwnerId);
    	}
    	List<Group> listOfGroups = [select id, DeveloperName from Group where DeveloperName=:mapOfOfGroupNamesAndOwnerId.keySet()];
    	Set<String> setOfExistingGroupNames = new Set<String>();
    	for(Group grp:listOfGroups) {
    		setOfExistingGroupNames.add(grp.DeveloperName);
    	}
    	Group groupObj; 
    	for(CollaborationGroup cg:listOfCollaborationGroups) {
    		
    		String standardGrpName = 'Simpplr_' + cg.Id + '_Standard';
    		if(!setOfExistingGroupNames.contains(standardGrpName)) {
	    		groupObj = new Group();
	    		groupObj.DeveloperName = standardGrpName;
	    		groupObj.DoesSendEmailToMembers = false;
	    		groupObj.type='Queue';
	    		groupObj.Name = standardGrpName; 
	    		listOfUserGroups.add(groupObj);
    		}
    		
    		String adminGrpName = 'Simpplr_' + cg.Id + '_Admin';
    		if(!setOfExistingGroupNames.contains(adminGrpName)) {
	    		groupObj = new Group();
	    		groupObj.DeveloperName = adminGrpName;
	    		groupObj.DoesSendEmailToMembers = false;
	    		groupObj.type='Queue';
	    		groupObj.Name = adminGrpName;
	    		listOfUserGroups.add(groupObj);
    		}
    	}
    	if(listOfUserGroups.size() > 0) {
    		insert listOfUserGroups;
    	}
    }
}