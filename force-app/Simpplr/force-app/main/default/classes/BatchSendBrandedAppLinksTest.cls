@isTest
public with sharing class BatchSendBrandedAppLinksTest {
    @testSetup
    static void setup() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Default_Page_Size__c = 0;
        appConfigRecord.Segment_Enabled__c = true;
        appConfigRecord.Segment_Column_Name__c = 'country__c';
        update appConfigRecord;
        TestHelper.createContentVersion('H');
        TestHelper.createPeopleRecordForUser(UserContext.id);
        People__c[] users = [SELECT id, Mobile_Phone__c, Email__c, country__c FROM People__c ];
        for(People__c usr: users){
            usr.Email__c = 'abctest112@iwui.com';
            usr.Mobile_Phone__c = '9787878787';
            usr.country__c = 'India';
            usr.Mobile_Token_iOS__c = '';
            usr.Mobile_Token_Android__c = '';
        }
        update users;
        List<Branded_App_Distribution__c> codes = new  List<Branded_App_Distribution__c> ();
        Branded_App_Distribution__c code = new Branded_App_Distribution__c();
        code.Code__c = 'test';
        code.Link__c = 'link';
        code.Is_Used__c = false;
        code.country__c = 'India';
        codes.add(code);
        insert codes;
    }
    
    @isTest
    static void testBatchSendBrandedAppLinksSMS(){
        //Arrange
        Set<String> countries = new Set<String>();
        countries.add('India');
        String notifType = 'MOBILE_PROMOTION_PHONE';
        Boolean expected = True;
        //Act
        Test.startTest();
        BatchSendBrandedAppLinks job = new BatchSendBrandedAppLinks(countries, notifType);
        Database.executeBatch(job,200);
        Test.stopTest();   
        //Assert
        List<Branded_App_Distribution__c> codesafter = [SELECT id, is_Used__c  from Branded_App_Distribution__c];
        System.assertEquals(expected ,codesafter[0].is_Used__c, 'Should be Updated to true, MOBILE_PROMOTION_PHONE failed');
    }
       @isTest
    static void testBatchReSendBrandedAppLinksSMS(){
        //Arrange
        Set<String> countries = new Set<String>();
        countries.add('India');
        String notifType = 'MOBILE_PROMOTION_PHONE';
        Boolean expected = True;
        //Act
        Test.startTest();
        BatchSendBrandedAppLinks job = new BatchSendBrandedAppLinks(countries, notifType);
        Database.executeBatch(job,200);
        Database.executeBatch(job,200);
        Test.stopTest();   
        //Assert
        List<Branded_App_Distribution__c> codesafter = [SELECT id, is_Used__c  from Branded_App_Distribution__c];
        System.assertEquals(expected ,codesafter[0].is_Used__c, 'Should be Updated to true, MOBILE_PROMOTION_PHONE failed');
    }
    
    @isTest
    static void testBatchSendBrandedAppLinksEmail(){     
        //Arrange
        Set<String> countries = new Set<String>();
        countries.add('India');
        String notifType = 'MOBILE_PROMOTION_EMAIL';
        Boolean expected = True;
        //Act
        Test.startTest();
        BatchSendBrandedAppLinks job = new BatchSendBrandedAppLinks(countries, notifType);
        Database.executeBatch(job,200);
        Test.stopTest();
        //Assert
        List<Branded_App_Distribution__c> codesafter = [SELECT id, is_Used__c from Branded_App_Distribution__c];
        System.assertEquals(expected ,codesafter[0].is_Used__c, 'Should be Updated to true, MOBILE_PROMOTION_EMAIL failed');       
    }
    @isTest
    static void testBatchReSendBrandedAppLinksEmail(){     
        //Arrange
        Set<String> countries = new Set<String>();
        countries.add('India');
        String notifType = 'MOBILE_PROMOTION_EMAIL';
        Boolean expected = True;
        //Act
        Test.startTest();
        BatchSendBrandedAppLinks job = new BatchSendBrandedAppLinks(countries, notifType);
        Database.executeBatch(job,200);
        Database.executeBatch(job,200);
        Test.stopTest();
        //Assert
        List<Branded_App_Distribution__c> codesafter = [SELECT id, is_Used__c from Branded_App_Distribution__c];
        System.assertEquals(expected ,codesafter[0].is_Used__c, 'Should be Updated to true, MOBILE_PROMOTION_EMAIL failed');       
    }
}