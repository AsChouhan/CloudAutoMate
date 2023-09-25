@isTest
private class BatchSyncAudienceMembersFromADTest {

    private static Audience__c audienceObj;
    private static List<String> audienceList;
    private static Active_Directory_Group__c adGroupObj;

    @TestSetup
    static void setup() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    }

    private static void init() {

        User userRec1 = TestHelper.createUser('test1', null, false);
        User userRec2 = TestHelper.createUser('test2', null, false);
        User userRec3 = TestHelper.createUser('test3', null, false);  
        User userRec4 = TestHelper.createUser('test4', null, false);        
        People__c peopleRec1 = [Select id From people__c where user__c =: userRec1.id];
        People__c peopleRec2 = [Select id From people__c where user__c =: userRec2.id];
        People__c peopleRec3 = [Select id From people__c where user__c =: userRec3.id]; 
        People__c peopleRec4 = [Select id From people__c where user__c =: userRec4.id]; 

        adGroupObj = TestHelper.createActiveDirectoryGroup();
        TestHelper.createActiveDirectoryGroupMember(adGroupObj.Id, peopleRec1.Id);
        TestHelper.createActiveDirectoryGroupMember(adGroupObj.Id, peopleRec2.Id);
        TestHelper.createActiveDirectoryGroupMember(adGroupObj.Id, peopleRec4.Id);

        audienceObj = TestHelper.createAudienceForADGroup(adGroupObj.AD_Object_Id__c);
        audienceList= new List<String>();
        audienceList.add(audienceObj.Id);
        TestHelper.createAudienceMember(audienceObj.Id, peopleRec3.Id);
        TestHelper.createAudienceMember(audienceObj.Id, peopleRec4.Id);
    }

    @isTest
    static void testSyncAudienceMemWithAD() {

        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));        
        Test.startTest();
        List<Audience_Member__c> audienceMemberList = [SELECT Id FROM Audience_Member__c WHERE Audience__c =: audienceObj.Id];

        System.assertEquals(2, audienceMemberList.size(), 'Current Audience Member count should be 2');

        Database.executeBatch(new BatchSyncAudienceMembersFromAD('syncAudienceMemWithAD', audienceList, true), 2000);
        Test.stopTest();

        audienceMemberList = [SELECT Id FROM Audience_Member__c WHERE Audience__c =: audienceObj.Id];
        System.assertEquals(3, audienceMemberList.size(), 'Current Audience Member count should be 3');
    }

    @isTest
    static void testUpdateRemovedADGroupAudience() {

        init();
        Set<String> adGroupIds = new Set<String>();
        adGroupIds.add(adGroupObj.AD_Object_Id__c);

        Test.startTest();
        Database.executeBatch(new BatchSyncAudienceMembersFromAD('updateRemovedADGroupAudience', adGroupIds, false), 1);
        Test.stopTest();

        List<Audience__c> audienceList = [SELECT Id FROM Audience__c WHERE Id =: audienceObj.Id AND Is_Deleted__c = FALSE];
        System.assertEquals(0, audienceList.size(), 'Audience should have been deleted');
    }

    @isTest
    static void testDeleteAllADGroups() {

        init();

        Test.startTest();
        Database.executeBatch(new BatchSyncAudienceMembersFromAD('deleteAllADGroupAudience'), 2000);
        Test.stopTest();       

        List<Audience__c> audienceList = [SELECT Id FROM Audience__c WHERE Is_Created_From_AD_Groups__c = True AND Is_Deleted__c = FALSE];
        System.assertEquals(0, audienceList.size(), 'Audiences should have been deleted');        
    }

    @isTest
    static void testCreateAutomaticAudienceAD() {

        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));        
        Test.startTest();
        Database.executeBatch(new BatchSyncAudienceMembersFromAD('createAutomaticAudienceAD', false), 2000);
        Test.stopTest();

        List<Audience__c> audienceList = [SELECT Id FROM Audience__c WHERE Is_Audience_Created_Automatically__c = TRUE];
        System.assertEquals(1, audienceList.size(), 'Automatic AD Audience should have been created'); 
    }
}