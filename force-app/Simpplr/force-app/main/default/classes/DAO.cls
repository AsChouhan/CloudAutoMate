public abstract with sharing class DAO {
 
 	protected final String FILTER_BOOKMARKED  = 'bookmarked';
	protected final String FILTER_INFLUENCER  = 'influencer';
	protected final String FILTER_FOLLOWING  = 'following';
	
 	public abstract Map<Id,Simpplr_Content__c> getContentsMapFromIds(List<Id> listOfContentIds, String siteId);
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Simpplr_Content__c getContentFromId(String Id,String siteId){
        Simpplr_Content__c result;
        if(!String.isBlank(Id)){
           Map<Id,Simpplr_Content__c> mapOfContent = getContentsMapFromIds(New List<String>{Id},siteId);
            if(mapOfContent.size() > 0){
                result = mapOfContent.values().get(0);
            }
        }
        return result;
    }
    
    public String getContentOwnerId(String groupDeveloperName) {
		String ownerId = UserContext.Id;
		List<QueueSobject> listOfQueueSobject = [select QueueId from QueueSobject where queue.developerName =: groupDeveloperName WITH SECURITY_ENFORCED];
		if(listOfQueueSobject.size() > 0) {
			ownerId = listOfQueueSobject[0].QueueId;
		}
		return ownerId;
    }
    
    public Set<Id> getContentIdSetForFollowedTopics(String contentType){
	 	Set<Id> topicIdSet = UserContext.topicsIFollowIdSet;
	 	Set<Id> contentIdsSet = new Set<Id>();
	 	
		String allowedFeatures;
		String query = 'SELECT Id FROM Simpplr_Content__c ' +
	 				   'WHERE Status__c =\'Approved\' ' +
	 				   'AND Is_Published__c = true ' +
	 				   'AND Is_Deleted__c = false ' +
	 				   'AND Type__c = :contentType ' +
	 				   'AND Id in (SELECT EntityId from TopicAssignment where TopicId in : topicIdSet AND entitytype=\'Simpplr_Content\') ';
		
		if(ServiceConstants.TYPE_BlogPost.equalsIgnoreCase(contentType) == false) {													
			allowedFeatures = '%' + contentType + '%';
			if('album'.equalsIgnoreCase(contentType)) {
				query += 'And (Site__r.Is_Active__c = true AND Site__r.Show_In_Simpplr__c = true AND Site__r.Has_Albums__c = true) ';
			} else if('event'.equalsIgnoreCase(contentType)) {
				query += 'And (Site__r.Is_Active__c = true AND Site__r.Show_In_Simpplr__c = true AND Site__r.Has_Events__c = true) ';
			} else if('page'.equalsIgnoreCase(contentType)) {
				query += 'And (Site__r.Is_Active__c = true AND Site__r.Show_In_Simpplr__c = true AND Site__r.Has_Pages__c = true) ';
			}
		}
															
	 	List<Simpplr_Content__c> contentObjList = Database.query(query);
	 	
	 	for(Simpplr_Content__c contentObj : contentObjList) {
	 		contentIdsSet.add(contentObj.Id);
	 	}
	 	
	 	return contentIdsSet;
	 }
}