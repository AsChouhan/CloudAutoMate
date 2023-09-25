/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class TopicDao{

    public TopicDao() {

    }
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    public List<Topic> getTopicsById(List<String> topicIds) {
    	List<Topic> topicsList = [SELECT Id, Name from Topic where Id = :topicIds WITH SECURITY_ENFORCED];
    	return topicsList;
    }

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public List<Topic> getTopicsWithCriteriaForManagePage(String searchText,String orderByField,String order,Integer recordLimit, Integer offsetVal,List<String> topicIds){
    	List<String> fieldList = New List<String>{
            'Id',
            'Name',
            'TalkingAbout', 
            'CreatedBy.Id', 
            'CreatedBy.Name'
        };
        String conditionString = '';
        String subConditionString = '';
        if(topicIds!=null){
            conditionString+=' where id in:topicIds';
        }else{

            if(String.isNotBlank(searchText)){
                    Set<String> searchTokens= Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
                    String andClause = '';
                    for(String searchToken: searchTokens){
                        conditionString += andClause + ' Name like \'%'+searchToken+'%\' ';
                        andClause = ' And ';
                    }
            }
            if(SimpplrContext.isCommunitiesEnabled){
                    if(String.isNotBlank(conditionString)){
                        conditionString+=' AND NetworkId = null';
                    }else{
                        conditionString+=' NetworkId = null';
                    }
                    
            }
            if(String.isNotBlank(conditionString)){
                conditionString = ' WHERE'+conditionString;
            }
            
            if(String.isBlank(order)){
                order = 'DESC';
            }
            if(String.isNotBlank(orderByField)){
                subConditionString+=' ORDER BY '+orderByField+' '+order;
            }
            if(recordLimit != null && recordLimit > 0){
                subConditionString+=' LIMIT :recordLimit';
            }
            if(offsetVal != null && offsetVal > 0){
                subConditionString+=' OFFSET :offsetVal';
            }
                
        }
        String query = 'SELECT '+String.join(fieldList,',')+' FROM Topic'+conditionString+subConditionString;
        logger.logDebug('TopicDao.getTopicsWithCriteriaForManagePage()----query----' + query);
        return Database.query(query); 
    }

    public Integer getTopicCountForCleanUp() {
        
        String query = 'SELECT Id from Topic WHERE Id NOT IN (SELECT TopicId FROM TopicAssignment)';
        
        if(SimpplrContext.isCommunitiesEnabled){
            query += ' AND NetworkId = null';
        }
        
        List<Topic> topicList = Database.query(query);

        return topicList.size();
    }
}