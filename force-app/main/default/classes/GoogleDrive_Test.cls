@isTest
public class GoogleDrive_Test {
	
    static String client_id= '628511661444-b31n71hm3v6kigbphkm9bn58d1qd63g2.apps.googleusercontent.com';
    static String redirectUri = 'https://briskmind9-dev-ed.my.site.com/DemoCompInt/s/?tabset-b975d=2';
    @isTest
    public  static void testCheckUserInDatabase() {
        // Create a test user
        User testUser = new User(
            Username = 'aashessh.singh@gmail.com',
          
            Email = 'testuser@example.com',
            Alias = 'testuser',
            CommunityNickname = 'testuser',
            LastName = 'Testing11',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        System.runAs(testUser){
            System.debug(userInfo.getUserId());
            // Create a test GoogleDriveUserData__c record for the test user
            GoogleDriveUserData__c testUserDetail = new GoogleDriveUserData__c(
                User_ID__c = userInfo.getUserId(),
                Access_Token__c = 'testAccessToken'
            );
            insert testUserDetail;
            
            // Call the Apex method being tested
            Test.startTest();
            String result = GoogleDriveApexController.checkUserInDatabase();
            Test.stopTest();
            
            // Assert that the result is as expected
            System.assertEquals('Found', result);
            
        }
          
       
    }
    
    @isTest
    static void testCreateAuthURL() {
        String uri = EncodingUtil.urlEncode(redirectUri,'UTF-8');
        // Define test data
        String expectedAuthUri = 'https://accounts.google.com/o/oauth2/auth?' +
            'client_id='+client_id+'&response_type=code&scope=https://www.googleapis.com/auth/drive&' +
            'redirect_uri='+uri+'&access_type=offline';
        String key1 = 'KEY_VALUE';
        String redirect_uri = 'REDIRECT_URI_VALUE';
        
        // Call the method being tested
        Test.startTest();
        
        String authUri = GoogleDriveApexController.createAuthURL();
        Test.stopTest();
        
        // Check the result
        System.debug(authUri);
        System.debug(expectedAuthUri);
        System.assertEquals(expectedAuthUri, authUri);
    }
    

    @isTest
    static void testGetAccessToken() {
        // Define test data
        String expectedToken = 'test_token';
        String expectedRefreshToken = 'test_refresh_token';
        String code = 'test_code';
        String key1 = 'test_key';
        String secret = 'test_secret';
        String redirect_uri = 'test_uri';
        
        // Mock the Http callout response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"access_token":"' + expectedToken + '","refresh_token":"' + expectedRefreshToken + '","expires_in":3600}');
        Test.setMock(HttpCalloutMock.class, new MockClassOfGoogleDrive());
        
        // Call the method being tested
        Test.startTest();
        String token = GoogleDriveApexController.getAccessToken(code);
        Test.stopTest();
        
        // Check the result
        GoogleDriveUserData__c[] accessInfos = [SELECT Name, Access_Token__c, Refresh_Token__c, User_ID__c, Expire_In__c FROM GoogleDriveUserData__c WHERE User_ID__c = :UserInfo.getUserId()];
        System.assertEquals(1, accessInfos.size());
        GoogleDriveUserData__c accessInfo = accessInfos[0];
        System.assertEquals(expectedToken, accessInfo.Access_Token__c);
        System.assertEquals(expectedRefreshToken, accessInfo.Refresh_Token__c);
        System.assertEquals(UserInfo.getUserId(), accessInfo.User_ID__c);
        System.assertNotEquals(null, accessInfo.Expire_In__c);
        System.assertEquals(token, accessInfo.Access_Token__c);
    }
   
    // @isTest
    // static void testDeleteData() {
    //     // Create test data
    //     GoogleDriveUserData__c testUser = new GoogleDriveUserData__c(
    //         Access_Token__c = 'test_access_token',
    //         User_ID__c = 'test_user_id'
    //     );
    //     insert testUser;

    //     // Call the method with test data
    //     Test.startTest();
    //     GoogleDriveApexController.deleteData('test_file_id');
    //     Test.stopTest();

    //     // Verify the response
    //      Test.setMock(HttpCalloutMock.class, new MockClassOfGoogleDrive());
    //     System.assertEquals(204, 204);
    // }    

}