@isTest
private class WorkdayUtilityTest {
	private static People__c peopleObj; 
	static void setUp() {
		peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		System.assert(true,'Running as expected');
	}
	
	@isTest static void updateFields() {
		setUp();
		WorkdayUtility.updateBusinessTitle(peopleObj,'New Value');
		WorkdayUtility.updateFirstName(peopleObj,'New Value');
		WorkdayUtility.updateLastName(peopleObj,'New Value');
		WorkdayUtility.updateDepartment(peopleObj,'New Value', true);
		WorkdayUtility.updateDivision(peopleObj,'New Value');
		WorkdayUtility.updateStreet(peopleObj,'New Value','New Value','New Value');
		WorkdayUtility.updateStateProvince(peopleObj,'New Value');
		WorkdayUtility.updateCountry(peopleObj,'New Value');
		WorkdayUtility.updateCity(peopleObj,'New Value');
		WorkdayUtility.updateEmail(peopleObj,'New Value');
		WorkdayUtility.updatePostalCode(peopleObj,'New Value');
		WorkdayUtility.updatePhones(peopleObj,'New Value');
		WorkdayUtility.updateMobilePhone(peopleObj,'New Value');
		WorkdayUtility.updateRole(peopleObj,'New Value');
        WorkdayUtility.updateHireDate(peopleObj,'2000-01-01');
        WorkdayUtility.updateAboutMe(peopleObj,'New Value');
        WorkdayUtility.updateBirthDate(peopleObj,'2000-01-01');
        WorkdayUtility.updateBirthDate(peopleObj,'2000-01');
        WorkdayUtility.updateCommunityNickName(peopleObj,'New Value');
        WorkdayUtility.updateCompanyName(peopleObj,'New Value');
        WorkdayUtility.updateFax(peopleObj,'New Value');
        WorkdayUtility.updateExtension(peopleObj,'New Value');
		WorkdayUtility.updateReportingManager(peopleObj,'New Value', new Map<String, String>(), new Set<String>());
		System.assert(true,'Running as expected');
	} 
    
    @isTest static void testUpdateFieldsException() {
        Test.startTest();
        People__c peopleObj;
        WorkdayUtility.updateBusinessTitle(peopleObj, '###');
        WorkdayUtility.updateFirstName(peopleObj, '###');
        WorkdayUtility.updateLastName(peopleObj, '###');
        WorkdayUtility.updateDepartment(peopleObj, '###', true);
        WorkdayUtility.updateDivision(peopleObj, '###');
        WorkdayUtility.updateStreet(peopleObj, '###', '###', '###');
        WorkdayUtility.updateStateProvince(peopleObj, '###');
        WorkdayUtility.updateCountry(peopleObj, '###');
        WorkdayUtility.updateCity(peopleObj, '###');
        WorkdayUtility.updateEmail(peopleObj, '###');
        WorkdayUtility.updatePostalCode(peopleObj, '###');
        WorkdayUtility.updatePhones(peopleObj, '###');
        WorkdayUtility.updateMobilePhone(peopleObj, '###');
        WorkdayUtility.updateRole(peopleObj, '###');
        WorkdayUtility.updateHireDate(peopleObj, '###');
        WorkdayUtility.updateAboutMe(peopleObj, '###');
        WorkdayUtility.updateBirthDate(peopleObj, '###');
        WorkdayUtility.updateCommunityNickName(peopleObj, '###');
        WorkdayUtility.updateCompanyName(peopleObj, '###');
        WorkdayUtility.updateExtension(peopleObj, '###');
        WorkdayUtility.updateFax(peopleObj, '###');
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testCustomFields() {
        Test.startTest();
        setup();
        WorkdayUtility.updateCustomField(peopleObj, 'Custom Field 1', 'Custom_Field_1__c');
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testCustomFieldsException() {
        Test.startTest();
        People__c peopleObj;
        WorkdayUtility.updateCustomField(peopleObj, 'CustomFieldValue1', 'Custom_Field_1__c');
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }

}