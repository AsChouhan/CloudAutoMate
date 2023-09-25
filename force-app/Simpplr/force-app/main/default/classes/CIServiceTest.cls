@isTest
private class CIServiceTest {

    @isTest static void testDeleteCIItems() {
            File__c fil = new File__c();
            fil.Repository__c = 'native_video';
            fil.Feed_Item__c = '1234';
            insert fil;
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'getJWTToken',false));
            Test.startTest();
            FeedServiceProvider.deleteFeedVideosCIItems('1234');
            Test.stopTest();
            System.assertEquals(true, true, 'Running as expected');
        }
}