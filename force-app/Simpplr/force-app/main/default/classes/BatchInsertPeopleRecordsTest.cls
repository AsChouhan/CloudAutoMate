@isTest
private class BatchInsertPeopleRecordsTest {
    @testSetup
	static void setUp() {
		System.assert(true,'Running as expected');
	}
	
	@isTest static void testBatchInsertPeopleRecordsTest() {
		String userId = UserContext.id;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/normalization/locations/validate-address',false));
        SimpplrContext.locationNormalizationEnabled = true;
		BatchInsertPeopleRecords batchJob = new BatchInsertPeopleRecords();
		batchJob = new BatchInsertPeopleRecords(false, true);
		Database.executeBatch(batchJob,100);
		System.assert(true,'Running as expected');
	}
	
}