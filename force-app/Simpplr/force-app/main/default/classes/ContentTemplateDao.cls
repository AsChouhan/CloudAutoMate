/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ContentTemplateDao {

    
    /**
     * 
     * @Description:  [This method retrived the Content Template details from Salesforce based on parameters]
     * @Parameters:
        * siteId -> This parameter required to fetch templates from a particular site
        * type -> it defines type of Content template. It may be Page, Event and Album.
        * searchText -> it defines that name of template should be like searchText
        * orderBy -> defines returned list of templates should be sorted based on the orderBy field
        * order -> This parameter is define sorting order of template in returned list
        * recordLimit -> defines number of records to be returned in one go
        * offset -> defines from which index list should prepare
     *      
     * @Returns:  [Returns the list of Content Templates fulfilling request criteria]
    */
    public List<Content_Template__c> getContentTemplateListFromCriteria(String siteId, String type, String searchText, String orderBy, String order, Integer recordLimit, Integer offset) {
        logger.logDebug('ContentTemplateDao.getContentTemplateListFromCriteria()----siteId----'+siteId+'----contentTemplateType----'+type+'----searchText----'+searchText+'----order----'+order+'----orderByField----'+orderBy+'----recordLimit----'+recordLimit+'----offsetVal----'+offset);
        String filterCondition = '';
        String filterSubCondition = '';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        filterCondition += ' Is_Deleted__c = false';
        filterCondition += ' And (Site__c != null And Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true)';
        if (String.isNotBlank(siteId)) {
            filterCondition += ' AND Site__c =:soqlParam1';
            soqlParamMap.put('soqlParam1',siteId);
        }
        if (String.isNotBlank(type)) {
            filterCondition += ' AND Type__c =:soqlParam2';
            soqlParamMap.put('soqlParam2',type);
        }
        if  (String.isNotBlank(searchText)) {
            Set<String> setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(searchText));
            filterCondition += getSearchTermCondition(setOfSearchTerms, 'Name__c');
        }
        filterSubCondition += ' ORDER BY Is_System_Template__c';
        if(String.isNotBlank(orderBy)){
            filterSubCondition+=', '+orderBy+' '+order;
        }
        if (recordLimit != null && recordLimit > 0) {
            filterSubCondition += ' LIMIT :soqlParam3';
            soqlParamMap.put('soqlParam3',recordLimit);
        }
        if (offset != null && offset > 0) {
            filterSubCondition += ' OFFSET :soqlParam4';
            soqlParamMap.put('soqlParam4',offset);
        }
        filterCondition = !filterCondition.equals('')?' WHERE'+filterCondition : '';
        String query = 'SELECT '+String.join(getContentTemplateFieldList(),',')+' FROM Content_Template__c'+filterCondition+filterSubCondition;
        logger.logDebug('ContentTemplateDataServer.getContentTemplateListFromCriteria()----query----'+query);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<Content_Template__c> listOfContentTemplates = (List<Content_Template__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        return listOfContentTemplates;
    }
    /**
     * 
     * @Description:  [This method defines the number of fields of content Template object to be queried]
     * @Parameters:  no parameter
     * @Returns:  [Returns the list of Content Templates fields]
    */
    public List<String> getContentTemplateFieldList() {
        List<String> fieldList = new List<String>{
            'Id',
            'Type__c',
            'site__c',
            'Cover_Image_Layout__c',
            'Is_Enabled__c',
            'Is_Deleted__c',
            'Is_System_Template__c',
            'Language__c',
            'Name__c',
            'Pages_Category__c',
            'Sub_Type__c',
            'Title__c',
            'Title_Image_Caption__c',
            'Pages_Category__r.Name__c',
            'createdDate',
            'LastModifiedDate',
            'Primary_Author__c',
            'Primary_Author__r.user__r.Id',
            'Primary_Author__r.First_Name__c', 
            'Primary_Author__r.Community_Nickname__c',
            'Primary_Author__r.Last_Name__c',
            'Primary_Author__r.Full_Name__c',
            'Primary_Author__r.user__r.SmallPhotoURL',
            'Primary_Author__r.user__r.FullPhotoURL',
            'Primary_Author__r.Department__c',
            'Primary_Author__r.About__c',
            'Primary_Author__r.Title__c',
            'Primary_Author__r.City__c',
            'Primary_Author__r.State__c',
            'Primary_Author__r.Country__c',
            'Primary_Author__r.Email__c',
            'Primary_Author__r.Phone__c',
            'Primary_Author__r.mobile_phone__c',
            'Primary_Author__r.extension__c',
            'Primary_Author__r.Birth_Date__c',
            'Primary_Author__r.Joining_Date__c',
            'Primary_Author__r.User__c',
            'Primary_Author__r.User__r.isactive',
            'Site__r.name',
            'Site__r.Is_Active__c',
            'Site__r.Chatter_Group_Id__c',
            'Site__r.Site_Type__c',
            'Site__r.Landing_Page__c',
            'Site__r.Title_Content_Document__c',
            'Site__r.Title_Content_Version__c',
            'Site__r.Show_In_Simpplr__c',
            'Site__r.Is_Onboarding_Enabled__c',
            'Site__r.Is_Must_Read_Enabled__c'
        };
        return fieldList;
    }
    /**
     * 
     * @Description:  [This method creates search string for soql query]
     * @Parameters:  
     *      setOfSearchTerms - set of search term used to fetch template
     *      fieldToSearch - Content_template object's field to be search
     * @Returns:  [Returns search string for query]
    */
    private String getSearchTermCondition(Set<String> setOfSearchTerms, String fieldToSearch){
		String queryStr = '';
		if (setOfSearchTerms != null) {
			for(String searchToken:setOfSearchTerms) {
				queryStr += ' And ' + fieldToSearch + ' like \'%' + searchToken + '%\' ';
			}
        }
        return queryStr;
	}
    /**
     * 
     * @Description:  this method retrives template detail from Id
     * @Parameters:  contentTemplateIdSet - set of content template ids
     * @Returns:  [Returns list of content templates corresponding to id set]
    */
    public List<Content_Template__c> getContentTemplateListFromIdSet(Set<String> contentTemplateIdSet, String wrapperType) {
        List<String> queryFields = getContentTemplateFieldList();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', contentTemplateIdSet);
        if (wrapperType.equalsIgnoreCase('fullWrapper')) {
            queryFields.addAll(new List<String>{'Text_Intro__c','Text_Main__c','Text_Main_Continued__c'});
        }
        String query = 'SELECT '+String.join(queryFields, ',')+' FROM Content_Template__c where Id IN :soqlParam1';
        logger.logDebug('ContentTemplateDataServer.getContentTemplateListFromIdSet()----query----'+query);

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<Content_Template__c> listOfContentTemplates = (List<Content_Template__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        return listOfContentTemplates;
    }
}