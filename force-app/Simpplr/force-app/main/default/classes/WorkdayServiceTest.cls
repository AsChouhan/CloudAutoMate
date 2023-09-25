@isTest
private class WorkdayServiceTest {
	@testSetup
	static void setUp() {
		App_Config__c appConfigObj = TestHelper.setupAppConfig();
        appConfigObj.PDS_Workday_Endpoint__c = 'Dummy';
        update appConfigObj;
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		TestHelper.createPeoplePreference(peopleObj.Id);
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testParseResponseIntoWorkdayUserWrapper(){
    	WorkdayService wrkDayObj=new WorkdayService();
    	wrkDayObj.parseResponseIntoWorkdayUserWrapper('{"Report_Entry":[]}');
        System.assert(true,'Running as expected');
    }
    @isTest static void testProcessWorkdaySync(){																																																						
    	Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/Workday',false));
    	WorkdayService wrkDayObj=new WorkdayService();
    	wrkDayObj.processWorkdaySync();
    	Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testUpdateUserPreferenceEmployeeNumber(){
    	WorkdayService wrkDayObj=new WorkdayService();
    	Map<String, Object> wrapperObj = new Map<String, Object>();
    	wrapperObj.put('EmployeeID', 'Test');	
		wrapperObj.put('FirstName', 'Test');
		wrapperObj.put('LastName', 'Test');
		wrapperObj.put('Role', 'Test');
		wrapperObj.put('HireDate', '2015-01-01');
		wrapperObj.put('AboutMe', 'Test');
		wrapperObj.put('BirthDate', '2015-01-01');
		wrapperObj.put('businessTitle', 'Test');
		wrapperObj.put('ManagerID', 'Test');
		wrapperObj.put('Manager', 'Test');
		wrapperObj.put('Department', 'Test');
		wrapperObj.put('Division', 'Test');
		wrapperObj.put('Location', 'Test');
		wrapperObj.put('WorkAddressFormattedLine1', 'Test');
		wrapperObj.put('WorkAddressFormattedLine2', 'Test');
		wrapperObj.put('WorkAddressCity', 'Test');
		wrapperObj.put('WorkAddressStateProvince', 'Test');
		wrapperObj.put('workAddressPostalCode', 'Test');
		wrapperObj.put('WorkAddressCountry', 'Test');
		wrapperObj.put('primaryWorkEmail', 'Test');
		wrapperObj.put('publicWorkPhones', 'Test');
		wrapperObj.put('publicWorkMobilePhones', 'Test');
		wrapperObj.put('nickName', 'Test');
		wrapperObj.put('companyName', 'Test');
		wrapperObj.put('extension', 'Test');
		wrapperObj.put('fax', 'Test');
    	wrkDayObj.updatePeopleEmployeeNumber(new List<Map<String, Object>>{wrapperObj});
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testUpdateUserPreferenceFromWorkdayData(){
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.PDS_Title__c = true;
        appConfigObj.PDS_Department__c = true;
        appConfigObj.PDS_Division__c = true;
        appConfigObj.PDS_State__c = true;
        appConfigObj.PDS_Country__c = true;
        appConfigObj.PDS_City__c = true;
        appConfigObj.PDS_Postal_Code__c = true;
        appConfigObj.PDS_Phone__c = true;
        appConfigObj.PDS_Mobile_Phone__c = true;
        appConfigObj.PDS_Street__c = true;
        appConfigObj.PDS_Role__c = true;
        appConfigObj.PDS_Joining_Date__c = true;
        appConfigObj.PDS_About_Me__c = true;
        appConfigObj.PDS_Birth_Date__c = true;
        appConfigObj.PDS_Community_Nickname__c = true;
        appConfigObj.PDS_Company_Name__c = true;
        appConfigObj.PDS_Extension__c = true;
        appConfigObj.PDS_Fax__c = true;
        appConfigObj.PP_User_Custom_Fields__c = '[{"syncSource":"workday","isEditable":false,"columnName":"Custom_Field_1__c", "fieldName":"CustomField1"},' +
                                                 '{"syncSource":"workday","isEditable":false,"columnName":"Custom_Field_2__c", "fieldName":"CustomField2"},' +
                                                 '{"syncSource":"workday","isEditable":false,"columnName":"Custom_Field_3__c", "fieldName":"CustomField3"},' +
                                                 '{"syncSource":"workday","isEditable":false,"columnName":"Custom_Field_4__c", "fieldName":"CustomField4"},' +
                                                 '{"syncSource":"workday","isEditable":true, "columnName":"Custom_Field_5__c", "fieldName":"CustomField5"}]';
        update appConfigObj;
        SImpplrContext.locationNormalizationEnabled = true;
    	WorkdayService wrkDayObj=new WorkdayService();
        
        Map<String, Object> wdUserMap = new Map<String, Object>();
        wdUserMap.put('EmployeeID', '123');
        wdUserMap.put('WorkAddressCity', 'city');
    	wrkDayObj.updatePeopleFromWorkdayData(new List<Map<String, Object>>{wdUserMap});
    	System.assert(true,'Running as expected');
    }
}