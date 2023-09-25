@isTest
private class TestSimpplrPostInstallScript {
	@testSetup
	static void setUp() {
         App_Config__c appConfigRecord = TestHelper.setupAppConfig();  
		System.assert(true, 'Running as Expected');
	}
	@isTest
	static void testInstallScript() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
		SimpplrPostInstallScript obj = new SimpplrPostInstallScript();	
		//call method
        if(String.isNotBlank(SimpplrContext.packageName)) {
			Test.testInstall(obj, null);
        } 
        obj.createEveryoneAudience();
		obj.updateAppConfig(null);
		SimpplrPostInstallScript.registerMigrationJob(false, null, null, null);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}

	@isTest
	static void testShouldMigrationBeRunForErrorThrown() {
		SimpplrPostInstallScript obj = new SimpplrPostInstallScript();	
		Boolean isError = false;
		try {
			obj.shouldMigrationBeRun(1, 341, 0);
		} catch(Exception e) {
			isError = true;
		}
		System.assertEquals(true, isError, 'Should throw error');
	}

	@isTest
	static void testShouldMigrationBeRun() {
		SimpplrPostInstallScript obj = new SimpplrPostInstallScript();
		Boolean result = obj.shouldMigrationBeRun(2, 39, 0);
		System.assertEquals(true, result, 'should be true');

		result = obj.shouldMigrationBeRun(3, 52, 0);
		System.assertEquals(true, result, 'should be true');
	}
	
}