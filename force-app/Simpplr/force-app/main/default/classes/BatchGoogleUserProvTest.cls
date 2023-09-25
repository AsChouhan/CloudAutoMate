@istest
public with sharing class BatchGoogleUserProvTest implements HttpCalloutMock{
    
    private static User userAdmin;

    @testSetup
	public static void setUp() {
		App_Config__c appConfigObj = TestHelper.setupAppConfig();        
        TestHelper.createPeopleRecordForUser(UserContext.id);
        TestHelper.createUser('BatchGoogleUserProvTest', null, false);
        userAdmin = TestHelper.createUser('BatchGoogleUserProvTest_adminUser', null, true);
        appConfigObj.AT_User_Trigger_Type__c = 'JustInTime';
        update appConfigObj;
        createUserProvisioningConfig();  
        
        User_Provisioning_Config__c userProvConfigRecord = [SELECT Id,
                                                        Firstname__c, Lastname__c, User_Title__c, User_Email__c, Manager__c,
                                                        Department__c, Company_Name__c, Fax__c, Street__c, PostalCode__c,
                                                        Country__c, City__c, State__c, Phone__c, MobilePhone__c,
                                                        Birthdate__c, Joining_Date__c, Joining_Date_Field__c,
                                                        Birthdate_Field__c, Company_Name_Field__c,
                                                        Create_New_Users__c, Deactive_User__c, FedrationId__c,
                                                        Profile_Type__c, TimezoneSidKey__c, Username_Suffix__c, Query_Filter__c,
                                                        Street_Field__c, City_Field__c, Country_Field__c, State_Field__c, Postal_Code_Field__c
                                                        FROM User_Provisioning_Config__c LIMIT 1];       

		People__c peopleObj = [SELECT Id, User__c, First_Name__c, Last_Name__c, Title__c, 
                                        Manager__c, Department__c, Company_Name__c, Street__c,
                                        Postal_Code__c, City__c, State__c, Country__c, Phone__c, Mobile_Phone__c, 
                                        Employee_Number__c, Sync_Field__c, User__r.IsActive, 
                                        Last_Sync_DateTime__c, Email__c 
                                        FROM People__c LIMIT 1];
		
    }

    private static void init() {
        List<User> listOfUsers = [select id,lastName from User where lastName='BatchGoogleUserProvTest_adminUser'];
         for(User userObj : listOfUsers) {
             if(userObj.lastName == 'BatchGoogleUserProvTest_adminUser') {
                 userAdmin = userObj;
             }
         }
     }
    
    public static void createUserProvisioningConfig(){
        Profile pfl = [SELECT Id FROM Profile WHERE name='Standard User' Limit 1];

        User_Provisioning_Config__c configObj = new User_Provisioning_Config__c(
                Firstname__c = true, Lastname__c = true, User_Title__c = true, User_Email__c = true, Manager__c = true,
                Department__c = true, Company_Name__c = true, Fax__c = true, Street__c = true, PostalCode__c = true,
                City__c = true, State__c = true, Phone__c = true, MobilePhone__c = true,Country__c = true,
                Birthdate__c = true, Joining_Date__c = true, Joining_Date_Field__c = '',
                Birthdate_Field__c = '', Company_Name_Field__c = '', Street_Field__c = '', 
            	City_Field__c = '', Country_Field__c = '', State_Field__c = '', Postal_Code_Field__c = '',                              
                Profile_Type__c = pfl.id, Create_New_Users__c = true, Deactive_User__c = false, FedrationId__c = true,
                TimezoneSidKey__c = 'America/Los_Angeles', Username_Suffix__c  = 'dummy.com'); 

        insert configObj;       
    }

    @isTest
    public static void testBatchUserProv(){
        List<user> userList = [SELECT Id, IsActive FROM User WHERE LastName = 'BatchGoogleUserProvTest'];
        userList[0].IsActive = false;
        update userList;
        SimpplrContext.packageName = 'Simpplr';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserProvTest());

		BatchGoogleUserProv bGUSObj = new BatchGoogleUserProv('UserProv');
		Database.executeBatch(bGUSObj, 1);

		Test.stopTest();
        list<Logs__c> log = [Select Id, Log_Data__c from Logs__c];
        System.assertEquals('successful', log[0].Log_Data__c,'User Prov failed');
	}

    /**
     * @description testBatchUserProvConfig test case with custom address fields
     */
    @isTest
    public static void testBatchUserProvConfig(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserProvTest());
		User_Provisioning_Config__c userProvConfigRecord = [SELECT Id,
                                                        Firstname__c, Lastname__c, User_Title__c, User_Email__c, Manager__c,
                                                        Department__c, Company_Name__c, Fax__c, Street__c, PostalCode__c,
                                                        Country__c, City__c, State__c, Phone__c, MobilePhone__c,
                                                        Birthdate__c, Joining_Date__c, Joining_Date_Field__c,
                                                        Birthdate_Field__c, Company_Name_Field__c,
                                                        Create_New_Users__c, Deactive_User__c, FedrationId__c,
                                                        Profile_Type__c, TimezoneSidKey__c, Username_Suffix__c, Query_Filter__c,
                                                        Street_Field__c, City_Field__c, Country_Field__c, State_Field__c, Postal_Code_Field__c
                                                        FROM User_Provisioning_Config__c LIMIT 1];       
		
        userProvConfigRecord.Street_Field__c = 'Simpplr.StreetName';
        userProvConfigRecord.City_Field__c = 'Simpplr.CityName'; 
        userProvConfigRecord.Country_Field__c = 'Simpplr.CountryName'; 
        userProvConfigRecord.State_Field__c = 'Simpplr.StateName'; 
        userProvConfigRecord.Postal_Code_Field__c = 'Simpplr.PostalCodeName';
        userProvConfigRecord.Joining_Date_Field__c = 'Simpplr.JoiningDate';
        userProvConfigRecord.Birthdate_Field__c = 'Simpplr.Birthdate'; 
        userProvConfigRecord.Company_Name_Field__c = 'Simpplr.CompanyName';
        update userProvConfigRecord;
		BatchGoogleUserProv bGUSObj = new BatchGoogleUserProv('UserProv');
		Database.executeBatch(bGUSObj, 1);

		Test.stopTest();
        list<Logs__c> log = [Select Id, Log_Data__c from Logs__c];
        System.assertEquals('successful', log[0].Log_Data__c,'User Prov failed');
	}

    @isTest
    public static void testBatchUserProv2(){
        List<user> userList = [SELECT Id, IsActive, Email FROM User WHERE LastName = 'BatchGoogleUserProvTest'];
        List<String> existingUserIdList = new List<String>();
        existingUserIdList.add(userList[0].id); 
        Map<String,String> userToManagerMap = new Map<String,String>();
        userToManagerMap.put(userList[0].Email, 'user@dev.com');
        userList[0].IsActive = false;
        update userList;
        SimpplrContext.packageName = 'Simpplr';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserProvTest());
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/gsuite/user-manager',false));

        BatchGoogleUserProv bGUSObj = new BatchGoogleUserProv('UserProv','2',existingUserIdList,userToManagerMap);
		Database.executeBatch(bGUSObj, 1);

		Test.stopTest();
        list<Logs__c> log = [Select Id, Log_Data__c from Logs__c];
        System.assertEquals('successful', log[0].Log_Data__c,'User Prov failed');
	}

    @isTest
    public static void testBatchUserProv3(){
        init();
        List<User_Provisioning_Config__c> configObj1 = new List<User_Provisioning_Config__c>([SELECT Manager__c, Deactive_User__c FROM User_Provisioning_Config__c]);
        configObj1[0].Manager__c = false;
        configObj1[0].Deactive_User__c = true;
        update configObj1;    

        System.runAs(userAdmin){
            List<user> userList = [SELECT Id, IsActive, Email FROM User WHERE LastName = 'BatchGoogleUserProvTest'];
            
            List<String> existingUserIdList = new List<String>();
            Map<String,String> userToManagerMap = new Map<String,String>();
            userToManagerMap.put(userList[0].Email, 'user@dev.com');
            userList[0].IsActive = false;
            update userList;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BatchGoogleUserProvTest());
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/gsuite/user-manager',false));

            BatchGoogleUserProv bGUSObj2 = new BatchGoogleUserProv('UserProv','',existingUserIdList,userToManagerMap);
            Database.executeBatch(bGUSObj2, 1);
            
        }
		Test.stopTest();
        list<Logs__c> log = [Select Id, Log_Data__c from Logs__c];
        System.assertEquals('successful', log[0].Log_Data__c,'User Prov failed');
	}

    @isTest
    public static void testActivateUsers(){
        init();
        List<User_Provisioning_Config__c> configObj1 = new List<User_Provisioning_Config__c>([SELECT Manager__c, Deactive_User__c FROM User_Provisioning_Config__c]);
        configObj1[0].Manager__c = false;
        configObj1[0].Deactive_User__c = true;
        update configObj1;    

        System.runAs(userAdmin){
            List<user> userList = [SELECT Id, IsActive, Email FROM User WHERE LastName = 'BatchGoogleUserProvTest'];
            List<String> existingUserList = new List<String>();
            Map<String,String> userToManagerMap = new Map<String,String>();
            userToManagerMap.put(userList[0].Email, 'user@dev.com');
            userList[0].IsActive = false;
            update userList;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new BatchGoogleUserProvTest());

            BatchGoogleUserProv batchObj = new BatchGoogleUserProv();
            batchObj.existingUserIdList = existingUserList;
            batchObj.activateUserIdSet = new Set<String>();
            batchObj.activateUserIdSet.add(userList[0].Id);
            batchObj.activateUsers();
        }
		Test.stopTest();
        User userObj = [SELECT Id, IsActive FROM User WHERE LastName = 'BatchGoogleUserProvTest'];
        System.assert(true, userObj.isActive);
	}
  
    public HTTPResponse respond(HTTPRequest req) {

      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      
      if(req.getEndpoint().contains('action=getgsuiteusers')){
          res.setBody('{"result":{"users":[{"kind":"admin#directory#user","id":"112578370361342691059","etag":"nM32qckM4XsKqhG",' + 
                        '"Simpplr": {"Birthdate": "1947-08-15","CompanyName": "Simpplr","JoiningDate": "2000-01-01"},"customSchemas":{"Simpplr":{"Birthdate":"1947-08-15","CompanyName":"Simpplr","JoiningDate":"2000-01-01","StreetName":"dummyStreet","StateName":"dummyState","CityName":"dummyCity","CountryName":"dummyCountry","PostalCodeName":"dummyPostalCode"}}, "primaryEmail":"BatchGoogleUserProvTest_usr@testorg.com","name":{"givenName":"admin","familyName":"two","fullName":"admin two"},"isAdmin":false,"isDelegatedAdmin":true,"lastLoginTime":"2019-03-28T11:11:38.000Z","creationTime":"2019-03-28T11:00:34.000Z","agreedToTerms":true,"suspended":false,"archived":false,"changePasswordAtNextLogin":false,"ipWhitelisted":false,"emails":[{"address":"admintwo@bhootnath.in","primary":true}],"externalIds":[{"value":"E007","type":"organization"}],"relations":[{"value":"amit@bhootnath.in","type":"manager"}],"addresses":[{"type":"work","formatted":"WeWork, Sector 15, Gurgaon, Haryana, India","streetAddress":"dummy street","postalCode":"1234","locality":"dummy","region":"dummy","country":"dummy"}],"organizations":[{"title":"Simpplr Admin","name":"name hai ye","primary":true,"customType":"","department":"Intranet Admin","description":"Permanent"}],"phones":[{"value":"900","type":"work"},{"value":"100","type":"mobile"}],"locations":[{"type":"desk","area":"desk","buildingId":"WeWork","floorName":"2nd Floor","floorSection":"Right Side"}],"customerId":"C01gzjfgr","orgUnitPath":"","isMailboxSetup":true,"isEnrolledIn2Sv":false,"isEnforcedIn2Sv":false,"includeInGlobalAddressList":true},{"kind":"admin#directory#user","id":"112578370361342691087","etag":"nM32qcee4XsKqhG-zylXvkNQRY8foRHt9wwiAEAmQRcZe09epyAwLE","primaryEmail":"enemy1@dummy1.com","name":{"givenName":"dummy2","familyName":"dddddd","fullName":"dummy2 ddddd"},"isAdmin":false,"isDelegatedAdmin":true,"lastLoginTime":"2019-03-28T11:11:38.000Z","creationTime":"2019-03-28T11:00:34.000Z","agreedToTerms":true,"suspended":false,"archived":false,"changePasswordAtNextLogin":false,"ipWhitelisted":false,"emails":[{"address":"enemy1@dummy1.com","primary":true}],"externalIds":[{"value":"E008","type":"organization"}],"relations":[{"value":"dummy@dummy.com","type":"manager"}],"addresses":[{"type":"work","formatted":"WeWork, Sector 15, Gurgaon, Haryana, India","streetAddress":"dummy street","postalCode":"1234","locality":"dummy","region":"dummy","country":"dummy"}],"organizations":[{"title":"Simpplr Admin","name":"name hai ye","primary":true,"customType":"","department":"Intranet Admin","description":"Permanent"}],"phones":[{"value":"900","type":"work"},{"value":"100","type":"mobile"}],"locations":[{"type":"desk","area":"desk","buildingId":"WeWork","floorName":"2nd Floor","floorSection":"Right Side"}],"customerId":"C01gzjfgr","orgUnitPath":"","isMailboxSetup":true,"isEnrolledIn2Sv":false,"isEnforcedIn2Sv":false,"includeInGlobalAddressList":true}]}}');

      }else if(req.getEndpoint().contains('https://www.googleapis.com/oauth2/v4/token')){
        res.setBody('{"access_token":"xyzmmmmm","type":"bearer","expires_in":"3600"}');	

      }

      res.setStatusCode(200);
      res.setStatus('success');
      
      return res;    
    }
}