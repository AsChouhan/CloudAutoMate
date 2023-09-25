/**
* @Class FilterService
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
* // test method 
*/
public with sharing class FilterService {
	
	
	private List<People__c> userListForFilters = null;
	private List<OrgWideEmailAddress> listOrgWideEmailForFilters = null;
	private List<Profile> listOfAllProfilesForFilters = null;

    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public Set<FilterAttributeWrapper> getListOfSiteCategories(){
		Set<FilterAttributeWrapper> listOfFilterWrapper=new Set<FilterAttributeWrapper>();
		String query = 'select Id, Name__c from Site_Category__c where Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Category__c> listOfSiteCategory = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, null);
    	for(Site_Category__c catObj: listOfSiteCategory) {
    		FilterAttributeWrapper filter = new FilterAttributeWrapper();
    		filter.id = catObj.id;
    		filter.name = catObj.Name__c;
    		listOfFilterWrapper.add(filter);
    	}
    	logger.logDebug('FilterService.getListOfSiteCategories()----listOfFilterWrapper----'+listOfFilterWrapper);
    	return listOfFilterWrapper;
	}
	
	public Set<FilterAttributeWrapper> getListOfPeopleCategories(){
		return getListOfPeopleCategories(true);
	}
	
	/*
	 * Return unsorted set of FilterAttributeWrapper
	 */
	public Set<FilterAttributeWrapper> getListOfPeopleCategories(Boolean includeUncategorised){
		Set<FilterAttributeWrapper> listOfFilterWrapper=new Set<FilterAttributeWrapper>();
		String pCatQuery = 'SELECT Id, Name__c FROM People_Category__c WHERE Is_Deleted__c = false ';
																
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Category__c> listOfPeopleCategory = (List<People_Category__c>)SIMPESAPI.accessController().queryAsUser(pCatQuery, null);

    	for(People_Category__c catObj: listOfPeopleCategory) {
    		FilterAttributeWrapper filter = new FilterAttributeWrapper();
    		filter.id = catObj.id;
    		filter.name = catObj.Name__c.capitalize();
    		listOfFilterWrapper.add(filter);
    	}
    	
    	if(includeUncategorised){
    		// Add uncategorized category at last
	    	FilterAttributeWrapper fawObj = new FilterAttributeWrapper();
			fawObj.id = ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
			fawObj.name = ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
			
	    	listOfFilterWrapper.add(fawObj);
    	}

    	logger.logDebug('FilterService.getListOfPeopleCategories()----listOfFilterWrapper----'+listOfFilterWrapper);
    	return listOfFilterWrapper;
	}
	
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      None
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public Set<FilterAttributeWrapper> getSiteFilterList() {
    	Set<FilterAttributeWrapper> listOfFilterWrapper = new Set<FilterAttributeWrapper>();
    	
    	List<Simpplr_Site__c> simpSiteList =  Utility.getAllSimpplrSiteMap().values();
    	for(Simpplr_Site__c siteObj: simpSiteList) {
    		FilterAttributeWrapper filter = new FilterAttributeWrapper();
    		filter.id = siteObj.id;
    		filter.name = siteObj.Name;
    		listOfFilterWrapper.add(filter);
    	}
    	logger.logDebug('FilterService.getSiteFilterList()----listOfFilterWrapper----'+listOfFilterWrapper);
    	return listOfFilterWrapper;
    }
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public Set<FilterAttributeWrapper> getListOfUserLocation(){		
		List<People__c> tempList = getUserListForFilters();		
		Map<String, FilterAttributeWrapper> mapFilterAttributeWrapper = new Map<String, FilterAttributeWrapper>();
		for(People__c p:tempList){
			String location='';			
			if(String.isNotBlank(p.city__c)){
				location+=p.city__c+'@@';
			}else{
				location+='_00_@@';
			}			
			if(String.isNotBlank(p.state__c)){
				location+=p.state__c+'@@';
			}else{
				location+='_11_@@';
			}		
			if(String.isNotBlank(p.country__c)){
				location+=p.country__c;
			}else{
				location+='_22_';
			}			
			String label=location.replace('@@',', ').replace('_00_, ','').replace('_11_, ','').replace('_22_','');
			label=label.trim();
			label=label.removeEnd(',');
			label=label.removeStart(','); 
			if(String.isNotBlank(label)){
				if(!mapFilterAttributeWrapper.containsKey(location)) {
					mapFilterAttributeWrapper.put(location,new FilterAttributeWrapper(location,label));
				}
			}
		}
		List<FilterAttributeWrapper> listOfFilterWrapper = mapFilterAttributeWrapper.values();
		listOfFilterWrapper.sort();
		Set<FilterAttributeWrapper> setOfFilterWrapper =new Set<FilterAttributeWrapper>(listOfFilterWrapper);
		logger.logDebug('FilterService.getListOfUserLocation()----setOfFilterWrapper----'+setOfFilterWrapper);
		return setOfFilterWrapper;
	}
	
	public Integer getEmployeeCount(){
		return getUserListForFilters().size();
	}
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public Set<FilterAttributeWrapper> getListOfUserDepartment(){
		List<People__c> tempList = getUserListForFilters();
		List<FilterAttributeWrapper> listOfDepartment = new List<FilterAttributeWrapper >();
		Set<String> alreadyExistSet =new Set<String>();
		Set<FilterAttributeWrapper> setOfDepartment =new Set<FilterAttributeWrapper>();
		if(SimpplrContext.isPPDepartmentDisplay){
			for(People__c p:tempList){
				if(String.isNotBlank(p.Department__c)){
					if(!alreadyExistSet.contains(p.Department__c.tolowercase())) {
						FilterAttributeWrapper filter = new FilterAttributeWrapper();
						filter.id = p.Department__c;
						filter.name = p.Department__c;
						listOfDepartment.add(filter);
						alreadyExistSet.add(p.Department__c.tolowercase());
					}
				}
			}
			listOfDepartment.sort();
			setOfDepartment =new Set<FilterAttributeWrapper>(listOfDepartment);
		}
		
		logger.logDebug('FilterService.getListOfUserDepartment()----setOfDepartment----'+setOfDepartment);
		return setOfDepartment;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	private List<People__c> getUserListForFilters() {
		String packageName = SimpplrContext.packageName;
		if(userListForFilters == null) {
			String query ='Select id,user__c,city__c,state__c,country__c,Department__c,user__r.isActive from People__c where'; 
			if(isApiOnlyUserQueryable()){
				query += ' (user__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
			}else {
				query += ' (user__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
			}
			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				 query = query + ' and user__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
			}
			logger.logDebug('FilterService.getUserListForFilters()----query----'+query);
			userListForFilters = Database.query(query);
		}
		logger.logDebug('FilterService.getUserListForFilters()----userListForFilters----'+userListForFilters);
		return userListForFilters;
	} 
	
	
	private Integer getCountOfUsersWithNotBlankCity(List<People__c> listOfPeople) {
		logger.logDebug('FilterService.getCountOfUsersWithNotBlankCity()----listOfPeople----'+listOfPeople);
		Integer usersWithNotBlankCity = 0;
		for(People__c peopleObj : listOfPeople) {
			if(String.isNotBlank(peopleObj.city__c)) {
				usersWithNotBlankCity++;
			}
		}
		logger.logDebug('FilterService.getCountOfUsersWithNotBlankCity()----usersWithNotBlankCity----'+usersWithNotBlankCity);
		return usersWithNotBlankCity;
	}
	
	// method exists in SimpplrService TODO 
	private Boolean isApiOnlyUserQueryable(){
		Schema.DescribeSObjectResult r = Profile.sObjectType.getDescribe();
		Map<String, Schema.SObjectField> fields = r.fields.getMap();
		for(String field : fields.keyset()){
			if(field.equals(ServiceConstants.API_ONLY_USER_PERMISSION_NAME)){
				return true;
			}
		}
		return false;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	
	public Map<String, String> getOrgWideEmailsForFilters(){
		List<OrgWideEmailAddress> tempList = getOrgWideEmailsList();
		
		Map<String, String> mapOfOrgWideEmail = new Map<String, String>();		
		for(OrgWideEmailAddress oweObj : tempList){			
			mapOfOrgWideEmail.put(oweObj.Id, oweObj.Address);
		}
		return mapOfOrgWideEmail;
	}
	
	public List<Map<String, String>> getFromAddresses(){
		List<OrgWideEmailAddress> tempList = getOrgWideEmailsList();
		List<Map<String, String>> idEmailMapList = new List<Map<String, String>>();
		
		for(OrgWideEmailAddress oweObj : tempList){
			Map<String, String> idVsEmailMap = new Map<String, String>();
			idVsEmailMap.put('id', oweObj.Id);
			idVsEmailMap.put('email', oweObj.Address);
			
			idEmailMapList.add(idVsEmailMap);
		}
		logger.logDebug('FilterService.getFromAddresses()----idEmailMapList----' + idEmailMapList);
		
		return idEmailMapList;
	}
	
	public List<String> getDayList(){ 
		return new List<String> {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12',
   	 '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31'};
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	private List<OrgWideEmailAddress> getOrgWideEmailsList() {
		if(listOrgWideEmailForFilters == null) {
			String query ='SELECT id,Address FROM OrgWideEmailAddress where IsAllowAllProfiles = true LIMIT 20000'; 
			listOrgWideEmailForFilters = Database.query(query);
		}
		logger.logDebug('FilterService.getOrgWideEmailsList()----listOrgWideEmailForFilters----'+listOrgWideEmailForFilters);
		return listOrgWideEmailForFilters;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public Set<Pair> getAllProfilesListForFilters(){
		List<Profile> tempList = getAllProfilesList();
		Set<Pair> setOfAllProfiles = new Set<Pair>();
		
		for(Profile prof : tempList){
			Pair filter = new Pair();
			filter.id = String.valueOf(prof.Id);
			filter.name = prof.Name;
			setOfAllProfiles.add(filter);
		}
		logger.logDebug('FilterService.getAllProfilesListForFilters()----setOfAllProfiles----'+setOfAllProfiles);
		return setOfAllProfiles;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	private List<Profile> getAllProfilesList() {
		if(listOfAllProfilesForFilters == null) {
			String query ='SELECT Id,Name FROM Profile LIMIT 20000'; 
			listOfAllProfilesForFilters = Database.query(query);
		}
		logger.logDebug('FilterService.getAllProfilesList()----listOfAllProfilesForFilters----'+listOfAllProfilesForFilters);
		return listOfAllProfilesForFilters;
	}
	
	public PeopleWrapper.InstallStats getInstallStats() {
		PeopleWrapper.InstallStats installStats = new PeopleWrapper.InstallStats();
		String packageName = SimpplrContext.packageName;
		System.debug('packageName--323--' + packageName);
		
		//CONT-9731

		String query = 'Select count(id)totalID from User Where isActive=true And UserType= \'Standard\' ';
		
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			query += 'And id in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		}
		List<AggregateResult> aggegateUserList = Database.query(query);
		if (aggegateUserList != null && aggegateUserList.size()>0) {
			installStats.activeLicenseCount = Integer.valueOf(aggegateUserList[0].get('totalID'));
			installStats.totalLicenseCount = Integer.valueOf(aggegateUserList[0].get('totalID'));
			System.debug('Record Count: ' + Integer.valueOf(aggegateUserList[0].get('totalID')));
		}
		//COUNT-9731


		// String query = 'Select id from User Where isActive=true And UserType= \'Standard\' ';
		
		// if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
		// 	query += 'And id in (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:packageName) ';
		// }
		// List<User> userList = Database.query(query);

		
		// installStats.activeLicenseCount = userList.size();
		// installStats.totalLicenseCount = userList.size();
		
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
			List<PackageLicense> packageLicenseList = [select id, AllowedLicenses from PackageLicense where NamespacePrefix =:packageName];
			if(!packageLicenseList.isEmpty() && packageLicenseList[0].AllowedLicenses > 0) {
				installStats.totalLicenseCount = packageLicenseList[0].AllowedLicenses;
			}
		} 
		
		return installStats;
	}
	
	public List<AudienceWrapper.ProfileFields> getStandardProfileFieldList() {
		List<AudienceWrapper.ProfileFields> profileFieldList = new List<AudienceWrapper.ProfileFields>();
		Boolean syncDisabled = ('None'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)); 

		String videoFieldName = '';
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			videoFieldName = 'Zoom_Id__c';

		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			videoFieldName = 'Skype_Id__c';

		}

		if(syncDisabled){
			profileFieldList.add(new AudienceWrapper.ProfileFields('firstName', 'First_Name__c', false, SimpplrContext.isPPFirstNameEditable, SimpplrContext.isPPFirstNameDisplay, SimpplrContext.isPDSFirstName, false)); 
			profileFieldList.add(new AudienceWrapper.ProfileFields('lastName', 'Last_Name__c', false, SimpplrContext.isPPLastNameEditable, SimpplrContext.isPPLastNameDisplay, SimpplrContext.isPDSLastName, false)); 
			profileFieldList.add(new AudienceWrapper.ProfileFields('company', 'Company_Name__c', false, SimpplrContext.isPPCompanyNameEditable, SimpplrContext.isPPCompanyNameDisplay, SimpplrContext.isPDSCompanyName, false)); 
			profileFieldList.add(new AudienceWrapper.ProfileFields('department', 'Department__c', false, SimpplrContext.isPPDepartmentEditable, SimpplrContext.isPPDepartmentDisplay, SimpplrContext.isPDSDepartment, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('division', 'Division__c', false, SimpplrContext.isPPDivisionEditable, SimpplrContext.isPPDivisionDisplay, SimpplrContext.isPDSDivision, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('city', 'City__c', false, SimpplrContext.isPPCityEditable, SimpplrContext.isPPCityDisplay, SimpplrContext.isPDSCity, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('state', 'State__c', false, SimpplrContext.isPPStateEditable, SimpplrContext.isPPStateDisplay, SimpplrContext.isPDSState, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('country', 'Country__c', false, SimpplrContext.isPPCountryEditable, SimpplrContext.isPPCountryDisplay, SimpplrContext.isPDSCountry, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('about', 'About__c', false, SimpplrContext.isPPAboutMeEditable, SimpplrContext.isPPAboutMeDisplay, SimpplrContext.isPDSAboutMe, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('phone', 'Phone__c', false, SimpplrContext.isPPPhoneEditable, SimpplrContext.isPPPhoneDisplay, SimpplrContext.isPDSPhone, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('mobile', 'Mobile_Phone__c', false, SimpplrContext.isPPMobilePhoneEditable, SimpplrContext.isPPMobilePhoneDisplay, SimpplrContext.isPDSMobilePhone, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('hireDate', 'Joining_Date__c', false, SimpplrContext.isPPJoiningDateEditable, SimpplrContext.isPPJoiningDateDisplay, SimpplrContext.isPDSJoiningDate, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('birthday', 'Birth_Date__c', false, SimpplrContext.isPPBirthDateEditable, SimpplrContext.isPPBirthDateDisplay, SimpplrContext.isPDSBirthDate, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('title', 'Title__c', false, SimpplrContext.isPPTitleEditable, SimpplrContext.isPPTitleDisplay, SimpplrContext.isPDSTitle, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('manager', 'Manager__c', false, SimpplrContext.isPPManagerEditable, SimpplrContext.isPPManagerDisplay, SimpplrContext.isPDSManagerId, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('phoneExtension', 'Extension__c', false, SimpplrContext.isPPExtensionEditable, SimpplrContext.isPPExtensionDisplay, SimpplrContext.isPDSExtension, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('street', 'Street__c', false, SimpplrContext.isPPStreetEditable, SimpplrContext.isPPStreetDisplay, SimpplrContext.isPDSStreet, false));
			
		} else {
			profileFieldList.add(new AudienceWrapper.ProfileFields('firstName', 'First_Name__c', false, !SimpplrContext.isPDSFirstName && SimpplrContext.isPPFirstNameEditable, SimpplrContext.isPPFirstNameDisplay, SimpplrContext.isPDSFirstName, false)); 
			profileFieldList.add(new AudienceWrapper.ProfileFields('lastName', 'Last_Name__c', false, !SimpplrContext.isPDSLastName && SimpplrContext.isPPLastNameEditable, SimpplrContext.isPPLastNameDisplay, SimpplrContext.isPDSLastName, false)); 
			profileFieldList.add(new AudienceWrapper.ProfileFields('company', 'Company_Name__c', false, !SimpplrContext.isPDSCompanyName && SimpplrContext.isPPCompanyNameEditable, SimpplrContext.isPPCompanyNameDisplay, SimpplrContext.isPDSCompanyName, false)); 
			profileFieldList.add(new AudienceWrapper.ProfileFields('department', 'Department__c', false, !SimpplrContext.isPDSDepartment && SimpplrContext.isPPDepartmentEditable, SimpplrContext.isPPDepartmentDisplay, SimpplrContext.isPDSDepartment, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('division', 'Division__c', false, !SimpplrContext.isPDSDivision && SimpplrContext.isPPDivisionEditable, SimpplrContext.isPPDivisionDisplay, SimpplrContext.isPDSDivision, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('city', 'City__c', false, !SimpplrContext.isPDSCity && SimpplrContext.isPPCityEditable, SimpplrContext.isPPCityDisplay, SimpplrContext.isPDSCity, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('state', 'State__c', false, !SimpplrContext.isPDSState && SimpplrContext.isPPStateEditable, SimpplrContext.isPPStateDisplay, SimpplrContext.isPDSState, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('country', 'Country__c', false, !SimpplrContext.isPDSCountry && SimpplrContext.isPPCountryEditable, SimpplrContext.isPPCountryDisplay, SimpplrContext.isPDSCountry, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('about', 'About__c', false, !SimpplrContext.isPDSAboutMe && SimpplrContext.isPPAboutMeEditable, SimpplrContext.isPPAboutMeDisplay, SimpplrContext.isPDSAboutMe, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('phone', 'Phone__c',false, !SimpplrContext.isPDSPhone && SimpplrContext.isPPPhoneEditable, SimpplrContext.isPPPhoneDisplay, SimpplrContext.isPDSPhone, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('mobile', 'Mobile_Phone__c', false, !SimpplrContext.isPDSMobilePhone && SimpplrContext.isPPMobilePhoneEditable, SimpplrContext.isPPMobilePhoneDisplay, SimpplrContext.isPDSMobilePhone, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('hireDate', 'Joining_Date__c', false, !SimpplrContext.isPDSJoiningDate && SimpplrContext.isPPJoiningDateEditable, SimpplrContext.isPPJoiningDateDisplay, SimpplrContext.isPDSJoiningDate, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('birthday', 'Birth_Date__c', false, !SimpplrContext.isPDSBirthDate && SimpplrContext.isPPBirthDateEditable, SimpplrContext.isPPBirthDateDisplay, SimpplrContext.isPDSBirthDate, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('title', 'Title__c', false, !SimpplrContext.isPDSTitle && SimpplrContext.isPPTitleEditable, SimpplrContext.isPPTitleDisplay, SimpplrContext.isPDSTitle, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('manager', 'Manager__c', false, !SimpplrContext.isPDSManagerId && SimpplrContext.isPPManagerEditable, SimpplrContext.isPPManagerDisplay, SimpplrContext.isPDSManagerId, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('phoneExtension', 'Extension__c', false, !SimpplrContext.isPDSExtension && SimpplrContext.isPPExtensionEditable, SimpplrContext.isPPExtensionDisplay, SimpplrContext.isPDSExtension, false));
			profileFieldList.add(new AudienceWrapper.ProfileFields('street', 'Street__c', false, !SimpplrContext.isPDSStreet && SimpplrContext.isPPStreetEditable, SimpplrContext.isPPStreetDisplay, SimpplrContext.isPDSStreet, false));
				
		}
		
		profileFieldList.add(new AudienceWrapper.ProfileFields('timezone', 'User__r.TimezoneSIDKey', false, SimpplrContext.isPPTimezoneEditable, SimpplrContext.isPPTimezoneDisplay, false, false));
		profileFieldList.add(new AudienceWrapper.ProfileFields('language', 'User__r.languagelocalekey', false, SimpplrContext.isPPLanguageEditable, SimpplrContext.isPPLanguageDisplay, false, false));
		profileFieldList.add(new AudienceWrapper.ProfileFields('videoCallUsername', videoFieldName, false, SimpplrContext.isPPVideoEditable, SimpplrContext.isPPVideoDisplay, false, false));
		if(SimpplrContext.isPeopleCategoryEnable){
			profileFieldList.add(new AudienceWrapper.ProfileFields('category', 'People_Category__c', false, SimpplrContext.isPPCategoryEditable, SimpplrContext.isPPCategoryDisplay, false, false));
		}

		return profileFieldList;
	}

	public Map<String, Object> getCaptionsLanguages() {
		List<Object> captionsLanguageList = new List<Object>();
		for(Integer key : ServiceConstants.ID_VS_KALTURA_SUPPORTED_LANGUAGE_MAP.keySet()) {
			Map<String, Object> captionsLanguage = new Map<String, Object>();
			captionsLanguage.put('id', key);
			captionsLanguage.put('language', ServiceConstants.ID_VS_KALTURA_SUPPORTED_LANGUAGE_MAP.get(key));
			captionsLanguageList.add(captionsLanguage);
		}
		Map<String, Object> languagesMap = new Map<String, Object>();
		languagesMap.put('languages', captionsLanguageList);
		return languagesMap;
	}
	
	public Map<String, String> getAudienceAvailableFields(){
		Map<String, String> audienceAvailableFieldsMap = new Map<String, String>();
		
		audienceAvailableFieldsMap.put('Company_Name__c', 'company');
		audienceAvailableFieldsMap.put('Department__c', 'department');
		audienceAvailableFieldsMap.put('Division__c', 'division');
		audienceAvailableFieldsMap.put('City__c', 'city');
		audienceAvailableFieldsMap.put('State__c', 'state');
		audienceAvailableFieldsMap.put('Country__c', 'country');
		audienceAvailableFieldsMap.put('Title__c', 'title');
		audienceAvailableFieldsMap.put('Joining_Date__c', 'hireDate');
		
		if(SimpplrContext.isPeopleCategoryEnable){
			audienceAvailableFieldsMap.put('People_Category__c', 'category');		
		}
		
		return audienceAvailableFieldsMap;
	}
		public Set<Pair> getAllLocale(){
		Set<Pair> setOfAllLocales = new Set<Pair>();
		for( Schema.PicklistEntry pickListVal : User.LocaleSidKey.getDescribe().getPicklistValues()){
		Pair filter = new Pair();
		filter.id = pickListVal.getValue();
		filter.name = pickListVal.getLabel();
		setOfAllLocales.add(filter);
		}
	return setOfAllLocales;
	}
}