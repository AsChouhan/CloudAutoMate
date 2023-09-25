public with sharing class WorkdayUtility {
	private static Boolean isRunningInSandbox = null;

	/**
     * Method update the Business Title field for user if find any changes in workday an SF data. 
	 * */    
    public static Boolean updateBusinessTitle(People__c peopleObj, String businessTitle){
        Boolean isModified = false;
        try{
	        if((String.isBlank(businessTitle) && String.isNotBlank(peopleObj.Title__c)) || !businessTitle.equals(peopleObj.Title__c)){
	            isModified = true;
	            peopleObj.Title__c = businessTitle;
	        } 
        }catch(Exception e){
        	logger.logDebug('updateBusinessTitle() Exception occurred' + e.getCause());
        	logger.logDebug('updateBusinessTitle() Exception occurred' + e.getStackTraceString());
        }
        
        return isModified;
    }

    /**
     * Method update the First NamE field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateFirstName(People__c peopleObj, String FirstName){
        Boolean isModified = false;
        try{
	        if(FirstName.length()>0 && !FirstName.equals(peopleObj.First_Name__c)){
	            isModified = true;
	            peopleObj.First_Name__c = FirstName;
	        }
        }catch(Exception e){
        	logger.logDebug('updateFirstName() Exception occurred' + e.getCause());
        	logger.logDebug('updateFirstName() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    /**
     * Method update the Last Name field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateLastName(People__c peopleObj, String LastName){
        Boolean isModified = false;
		try{
	        if(LastName.length()>0 && !LastName.equals(peopleObj.Last_Name__c)){
	            isModified = true;
	            peopleObj.Last_Name__c = LastName;
	        }
        }catch(Exception e){
        	logger.logDebug('updateLastName() Exception occurred' + e.getCause());
        	logger.logDebug('updateLastName() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    /**
     * Method update the department field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateDepartment(People__c peopleObj, String department, Boolean enableFormatting){
        Boolean isModified = false;
        try{
        	if(String.isBlank(department) && String.isNotBlank(peopleObj.department__c)) {
        		isModified = true;
	        peopleObj.department__c = department;
	        
        	} else if(Department.length()>0 && !Department.equals(peopleObj.department__c)){
	            isModified = true;
	            peopleObj.department__c = department;
	            if(enableFormatting){
	            	peopleObj.department__c = formatTextCase(department);    
            	}
        	}
        }catch(Exception e){
        	logger.logDebug('updateDepartment() Exception occurred' + e.getCause());
        	logger.logDebug('updateDepartment() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    /**
     * Method update the Division field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateDivision(People__c peopleObj, String Division){
        Boolean isModified = false;
		try{
	        if((String.isBlank(Division) && String.isNotBlank(peopleObj.Division__c)) || !Division.equals(peopleObj.Division__c)){
	            isModified = true;
	            peopleObj.Division__c = Division;
	        }
        }catch(Exception e){
        	logger.logDebug('updateDivision() Exception occurred' + e.getCause());
        	logger.logDebug('updateDivision() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    /**
     * Method update the street field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateStreet(People__c peopleObj, String Location, String WorkAddressFormattedLine1, String WorkAddressFormattedLine2){
        Boolean isModified = false;
        try{
	        String userStreet = '';
	        if(!String.isBlank(WorkAddressFormattedLine1)) userStreet = userStreet +' '+ WorkAddressFormattedLine1; 
	        if(!String.isBlank(WorkAddressFormattedLine2)) userStreet = userStreet +' '+ WorkAddressFormattedLine2; 
	        
	        if((String.isBlank(userStreet) && String.isNotBlank(peopleObj.street__c)) ||  !userStreet.equals(peopleObj.street__c)){
	            isModified = true;
	            peopleObj.street__c = userStreet;
	        }
	    }catch(Exception e){
	    	logger.logDebug('updateStreet() Exception occurred' + e.getCause());
        	logger.logDebug('updateStreet() Exception occurred' + e.getStackTraceString());
	    }
	    
        return isModified;
    }
    
    /**
     * Method update the state field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateStateProvince(People__c peopleObj, String WorkAddressStateProvince){
        Boolean isModified = false;
       try{
	        if((String.isBlank(WorkAddressStateProvince) && String.isNotBlank(peopleObj.State__c)) ||  !WorkAddressStateProvince.equals(peopleObj.State__c)){
	            isModified = true;
	            peopleObj.State__c=WorkAddressStateProvince;
	        }
        }catch(Exception e){
        	logger.logDebug('updateStateProvince() Exception occurred' + e.getCause());
        	logger.logDebug('updateStateProvince() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    
    /**
     * Method update the country field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateCountry(People__c peopleObj, String WorkAddressCountry){
        Boolean isModified = false;
        try{
	        if((String.isBlank(WorkAddressCountry) && String.isNotBlank(peopleObj.Country__c)) || !WorkAddressCountry.equals(peopleObj.Country__c)) {
	            isModified = true;
	            peopleObj.Country__c = WorkAddressCountry;
	        }
        }catch(Exception e){
        	logger.logDebug('updateCountry() Exception occurred' + e.getCause());
        	logger.logDebug('updateCountry() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }

    /**
     * Method update the city field for user if find any changes in workday an SF data. 
     * */
	public static Boolean updateCity(People__c peopleObj, String WorkAddressCity){
        Boolean isModified = false;
        try{
	        if((String.isBlank(WorkAddressCity) && String.isNotBlank(peopleObj.City__c)) || !WorkAddressCity.equals(peopleObj.City__c)) {
	            isModified = true;
	            peopleObj.City__c = WorkAddressCity;
	        }
	    }catch(Exception e){
	    	logger.logDebug('updateCity() Exception occurred' + e.getCause());
        	logger.logDebug('updateCity() Exception occurred' + e.getStackTraceString());
	    }
	    
        return isModified;
    }

	/**
     * Method update the email field for user if find any changes in workday an SF data. 
	 * */    
	public static Boolean updateEmail(People__c peopleObj, String primaryWorkEmail){
        Boolean isModified = false;
        try{
        
	        if(!String.isBlank(primaryWorkEmail) && !primaryWorkEmail.equals(peopleObj.Email__c)){
	            isModified = true;
	            String emailMask = ''; 
	            if(isRunningInSandbox()){ // if sandbox then add sandbox mask
	                emailMask = '.sandbox.simpplr.test';
	            }
	            peopleObj.Email__c = primaryWorkEmail + emailMask;
	        }
        }catch(Exception e){
        	logger.logDebug('updateEmail() Exception occurred' + e.getCause());
        	logger.logDebug('updateEmail() Exception occurred' + e.getStackTraceString());
        }

        return isModified;
    }
    
    /**
     * Method update the postal code field for user if find any changes in workday an SF data. 
     * */
	public static Boolean updatePostalCode(People__c peopleObj, String WorkAddressPostalCode){
        Boolean isModified = false;
        try{
	        if((String.isBlank(WorkAddressPostalCode) && String.isNotBlank(peopleObj.Postal_Code__c)) || !WorkAddressPostalCode.equals(peopleObj.Postal_Code__c)){
	            isModified = true;
	            peopleObj.Postal_Code__c = WorkAddressPostalCode;
	        }
	    }catch(Exception e){
	    	logger.logDebug('updatePostalCode() Exception occurred' + e.getCause());
        	logger.logDebug('updatePostalCode() Exception occurred' + e.getStackTraceString());
	    }
        return isModified;
    }
    
    /**
     * Method update the phone field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updatePhones(People__c peopleObj, String publicWorkPhones){
        Boolean isModified = false;
        try{
	        if((String.isBlank(publicWorkPhones) && String.isNotBlank(peopleObj.phone__c)) || !publicWorkPhones.equals(peopleObj.phone__c)){
	            isModified = true;
	            peopleObj.phone__c = String.isNotBlank(publicWorkPhones) && publicWorkPhones.length() > 40 ? publicWorkPhones.substring(0,40) : publicWorkPhones;
	        }
        }catch(Exception e){
        	logger.logDebug('updatePhones() Exception occurred' + e.getCause());
        	logger.logDebug('updatePhones() Exception occurred' + e.getStackTraceString());
        }
        
        return isModified;
    }
    
    /**
     * Method update the mobile phone field for user if find any changes in workday an SF data. 
     * */
    public static Boolean updateMobilePhone(People__c peopleObj, String publicWorkMobilePhones){
        Boolean isModified = false;
        try{
	        if((String.isBlank(publicWorkMobilePhones) && String.isNotBlank(peopleObj.Mobile_Phone__c)) || !publicWorkMobilePhones.equals(peopleObj.Mobile_Phone__c)){
	            isModified = true;
	            peopleObj.Mobile_Phone__c  = String.isNotBlank(publicWorkMobilePhones) && publicWorkMobilePhones.length() > 40 ? publicWorkMobilePhones.substring(0,40) : publicWorkMobilePhones;
	        }
        }catch(Exception e){
        	logger.logDebug('updateMobilePhone() Exception occurred' + e.getCause());
        	logger.logDebug('updateMobilePhone() Exception occurred' + e.getStackTraceString());
        }
        
        return isModified;
    }
    
    
    /**
     * Method update the Role field for user if find any changes in workday an SF data. 
     * Author: Bhuwan Devshali
     * */
    public static Boolean updateRole(People__c peopleObj, String role){
        Boolean isModified = false;
		try{
	        if((String.isBlank(role) && String.isNotBlank(peopleObj.Role__c)) || !role.equals(peopleObj.Role__c)){
	            isModified = true;
	            peopleObj.Role__c = role;
	        }
        }catch(Exception e){
        	logger.logDebug('updateRole() Exception occurred' + e.getCause());
        	logger.logDebug('updateRole() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    
    /**
     * Method update the Joining Date field for user if find any changes in workday an SF data. 
     * Author: Bhuwan Devshali
     * */
    public static Boolean updateHireDate(People__c peopleObj, String hireDate){
        Boolean isModified = false;
		try{
			if(String.isBlank(hireDate) && peopleObj.Joining_Date__c != null) {
				isModified = true;
				peopleObj.Joining_Date__c = null;
				
			} else if(hireDate.length()>0 && !(WorkdayUtility.convertStringToWorkdayDate(hireDate)==peopleObj.Joining_Date__c)){
	            isModified = true;
	            peopleObj.Joining_Date__c = WorkdayUtility.convertStringToWorkdayDate(hireDate);
	        }
        }catch(Exception e){
        	logger.logDebug('updateHireDate() Exception occurred' + e.getCause());
        	logger.logDebug('updateHireDate() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    /**
     * Method update the AboutMe field for user if find any changes in workday an SF data. 
     * Author: Bhuwan Devshali
     * */
    public static Boolean updateAboutMe(People__c peopleObj, String aboutMeFullText){
        Boolean isModified = false;
		try{
			if(String.isBlank(aboutMeFullText) && String.isNotBlank(peopleObj.About__c)) {
				isModified = true;
                peopleObj.About__c = null;
				
			} else if(String.isNotBlank(aboutMeFullText) && !aboutMeFullText.equals(peopleObj.About__c)){
	            isModified = true;
	            peopleObj.About__c= aboutMeFullText.stripHTMLTags();
            }
        }catch(Exception e){
        	logger.logDebug('updateAboutMe() Exception occurred' + e.getCause());
        	logger.logDebug('updateAboutMe() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    public static Boolean updateBirthDate(People__c peopleObj, String birthDate){
        Boolean isModified = false;
		try{
			if(String.isBlank(birthDate) && peopleObj.Birth_Date__c !=null) {
				isModified = true;
				peopleObj.Birth_Date__c = null;
			} else if(birthDate.length()>0 && !(WorkdayUtility.convertStringToWorkdayDate(birthDate)==peopleObj.Birth_Date__c)){
	            isModified = true;
	            peopleObj.Birth_Date__c = WorkdayUtility.convertStringToWorkdayDate(birthDate);
	        }
        }catch(Exception e){
        	logger.logDebug('updateBirthDate() Exception occurred' + e.getCause());
        	logger.logDebug('updateBirthDate() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    public static Boolean updateCommunityNickName(People__c peopleObj, String nickName){
        Boolean isModified = false;
		try{
	        if(String.isBlank(nickName) && String.isNotBlank((peopleObj.Community_Nickname__c)) || !nickName.equals(peopleObj.Community_Nickname__c)){
	            isModified = true;
	            peopleObj.Community_Nickname__c = nickName;
	        }
        }catch(Exception e){
    		logger.logDebug('updateCommunityNickName() Exception occurred' + e.getCause());
        	logger.logDebug('updateCommunityNickName() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    
    public static Boolean updateCompanyName(People__c peopleObj, String companyName){
        Boolean isModified = false;
		try{
	        if((String.isBlank(companyName) && String.isNotBlank(peopleObj.Company_Name__c)) || !companyName.equals(peopleObj.Company_Name__c)){
	            isModified = true;
	            peopleObj.Company_Name__c = companyName;
	        }
        }catch(Exception e){
        	logger.logDebug('updateCompanyName() Exception occurred' + e.getCause());
        	logger.logDebug('updateCompanyName() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
    public static Boolean updateExtension(People__c peopleObj, String extension){
        Boolean isModified = false;
		try{
	        if((String.isBlank(extension) && String.isNotBlank(peopleObj.Extension__c)) || !extension.equals(peopleObj.Extension__c)){
	            isModified = true;
	            peopleObj.Extension__c = String.isNotBlank(extension) && extension.length() > 40 ? extension.substring(0,40) : extension;
	        }
        }catch(Exception e){
        	logger.logDebug('updateExtension() Exception occurred' + e.getCause());
        	logger.logDebug('updateExtension() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }
    
     public static Boolean updateFax(People__c peopleObj, String fax){
        Boolean isModified = false;
		try{
	        if((String.isBlank(fax) && String.isNotBlank(peopleObj.Fax__c)) || !fax.equals(peopleObj.Fax__c)){
	            isModified = true;
	            peopleObj.Fax__c = fax;
	        }
        }catch(Exception e){
        	logger.logDebug('updateFax() Exception occurred' + e.getCause());
        	logger.logDebug('updateFax() Exception occurred' + e.getStackTraceString());
        }
        return isModified;
    }

    public static Boolean updateCustomField(People__c peopleObj, String fieldValue, String fieldApiName) {
        Boolean isModified = false;
        try {
            String newValue = fieldValue;
            String oldValue = (String) peopleObj.get(SimpplrContext.namespacePrefix + fieldApiName);
            if((String.isBlank(newValue) && String.isNotBlank(oldValue)) ||
                !newValue.equals(oldValue)) {
                isModified = true;
                peopleObj.put(SimpplrContext.namespacePrefix + fieldApiName, newValue);
            }
        } catch (Exception e) {
        	logger.logDebug('updateCustomField() - ' + fieldApiName + ' Exception occurred' + e.getCause());
        	logger.logDebug('updateCustomField() - ' + fieldApiName + ' Exception occurred' + e.getStackTraceString());            
        }
        return isModified;
    }           
    
    public static Date convertStringToWorkdayDate(String dateObj){ //dateObj is assumed to be in yyyy-MM-dd format
    	List<String> dateObjSplitArray=dateObj.split('-');
    	Date convertedDate;
    	if(dateObjSplitArray.size()==3){
			Integer year 	= Integer.valueOf(dateObjSplitArray[0]);
			Integer month 	= Integer.valueOf(dateObjSplitArray[1]);
			Integer day		= Integer.valueOf(dateObjSplitArray[2]);
			convertedDate 	= Date.newInstance(year, month, day);
    	} else if(dateObjSplitArray.size()==2) {
			Integer month 	= Integer.valueOf(dateObjSplitArray[0]);
			Integer day		= Integer.valueOf(dateObjSplitArray[1]);
			convertedDate	= Date.newInstance(1904, month, day);
    	} else {
    		convertedDate 	= Date.newInstance(1970, 01, 01);
    	}
    	return convertedDate;
    }
    
    /**
     *  Method update the managerID field for user if find any changes in workday an SF data. 
     * 
     * */
   	public static Boolean updateReportingManager(People__c peopleObj, String ManagerID, Map<String,String> managerEmployeeIdPeopleIdMap, Set<String> listOfManagerWorkdayIdNotSynchedwithSF){
        Boolean isModified = false;
        // Creating map of workdayID and salesforce id for managers. 
        
        if(String.isBlank (ManagerID)){
            ManagerID= '';
        }
        if(String.isBlank(ManagerID) && String.isBlank(peopleObj.Manager__c) ){
            // user dont have manager in workday and salesforce
            // leave as it is, dont do anything
        }
        if(String.isBlank(ManagerID) && !String.isBlank(peopleObj.Manager__c)){
            // user dont have manager in workday but in salesforce
            // update user's manager to null
            isModified = true;
            peopleObj.Manager__c = null;
        }
        if(!String.isBlank(ManagerID) && String.isBlank(peopleObj.Manager__c)){
            // user dont have manager in salesforce but in workday
            // update user's manager with new managerId
            String managerPeopleId = managerEmployeeIdPeopleIdMap.get(ManagerID);
            if(managerPeopleId!=null){ // manager record should have in salesforce system
            	if(managerPeopleId.equalsIgnoreCase(peopleObj.Id)) {
	            	//User Cannot be manager of itself, lets not update manager
            	} else {
                	isModified = true;
                	peopleObj.Manager__c = managerPeopleId;
	            }
            }else{ // if manager dont find in system then log these users.  
                listOfManagerWorkdayIdNotSynchedwithSF.add(ManagerID);
            }
        }
        if(!String.isBlank(ManagerID) && !String.isBlank(peopleObj.Manager__c)){
            // user do have same manager in workday and salesforce 
            // user have different managers in salesforce and workday
            
            String managerPeopleId = managerEmployeeIdPeopleIdMap.get(ManagerID);
            if(managerPeopleId!=null){ // manager record should have in salesforce system
                if(peopleObj.Manager__c != managerPeopleId){
                    // not equal, update 
                    if(managerPeopleId.equalsIgnoreCase(peopleObj.Id)) {
                    	//One cannot be manager of itself, lets remove manager from Salesforce System
                    	isModified = true;
	                    peopleObj.Manager__c = null; 
                    } else {
	                    isModified = true;
	                    peopleObj.Manager__c = managerPeopleId;
                    }
                    
                }else{
                    // both equal, just ignore 
                }
            }else{
                // Manager's record dont have WorkdayId
                listOfManagerWorkdayIdNotSynchedwithSF.add(ManagerID);
            }
        }
        
        return isModified;
    }
	
    /**
     * Return true if current environment is Sandbox.
     * */ 
    public static Boolean isRunningInSandbox() {
        if(isRunningInSandbox==null){
        	isRunningInSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        }
      return isRunningInSandbox;
    }
    
    /**
     *  Method formats the text string, if string length is less then 3 then 
     * 	it converts to upper case otherwise capitalize each word of string.
     * Examples: 
     * 'it' -> 'IT'
     * 'it department' -> 'IT Departments'
     * 'sales' -> 'Sales'
     * 
     * 
     * */
    public static String formatTextCase(String text){
        if(String.isBlank(text)) return '';
        
        String returnVal = '';
        List<String> words = text.split(' ');
        for(String word : words){
            String tWord = word;
            if(word.length()<=3){
                tword = word.toUpperCase();
            }else{
                tword = word.capitalize();
            }
            returnVal = returnVal + ' ' + tword;
        }
        returnVal = returnVal.normalizeSpace();
        return returnVal;
    }
}