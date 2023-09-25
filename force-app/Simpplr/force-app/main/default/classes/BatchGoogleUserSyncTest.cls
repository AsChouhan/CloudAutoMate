@istest
public with sharing class BatchGoogleUserSyncTest implements HttpCalloutMock{ 

    @testSetup
	public static void setUp() {
        createAppConfig();

		App_Config__c appConfigRecord = [SELECT Id, 
                PDS_First_Name__c, PDS_Last_Name__c, PDS_Title__c, PDS_Email__c, PDS_Manager_Id__c, PDS_Department__c, 
                PDS_Company_Name__c, PDS_Street__c, PDS_Postal_Code__c, PDS_Joining_Date__c, PDS_Birth_Date__c,
                PDS_City__c, PDS_State__c, PDS_Country__c, PDS_Phone__c, PDS_Mobile_Phone__c, 
                PDS_Joining_Date_Key__c, PDS_Birth_Date_Key__c, PDS_Company_Name_Key__c, PDS_Query_Filter__c ,
                PDS_Street_Key__c, PDS_State_Key__c, PDS_City_Key__c, PDS_Country_Key__c, PDS_Postal_Code_Key__c                         
                FROM App_Config__c LIMIT 1];

        createPeople(UserInfo.getUserId());

        // dummy user creation
        createUserAndPeople();

		People__c peopleObj = [SELECT Id, User__c, First_Name__c, Last_Name__c, Title__c, 
                                        Manager__c, Department__c, Company_Name__c, Street__c,
                                        Postal_Code__c, City__c, State__c, Country__c, Phone__c, Mobile_Phone__c, 
                                        Employee_Number__c, Sync_Field__c, User__r.IsActive, 
                                        Last_Sync_DateTime__c, Email__c 
                                        FROM People__c LIMIT 1];
		
    }
    
    public static void createAppConfig(){
        Profile pfl = [SELECT Id FROM Profile WHERE name='Standard User' Limit 1];
        App_Config__c configObj = new App_Config__c(
                PDS_Query_Filter__c = '',
                PDS_First_Name__c = true, PDS_Last_Name__c  = true, PDS_Title__c = true, PDS_Email__c = true, PDS_Manager_Id__c = true, PDS_Department__c = true, 
                PDS_Company_Name__c = true, PDS_Street__c = true, PDS_Postal_Code__c = true, PDS_Fax__c = true, 
                PDS_City__c = true, PDS_State__c = true, PDS_Country__c = true, PDS_Phone__c = true, PDS_Mobile_Phone__c = true, PDS_Joining_Date__c = true,
                PDS_Birth_Date__c= true, PDS_Joining_Date_Key__c = '', PDS_Birth_Date_Key__c = '',PDS_Company_Name_Key__c ='', PDS_Street_Key__c  = '',
                PDS_State_Key__c  = '',PDS_City_Key__c  = '',PDS_Country_Key__c  = '',PDS_Postal_Code_Key__c  = '');

        insert configObj;        
    }

    public static void createPeople(String userId){
    	People__c peopleObj = new People__c();

        peopleObj.User__c = userId;
        peopleObj.User_id__c = userId;
        peopleObj.User_Hash__c = EncodingUtil.base64Encode(Crypto.generateDigest('SHA-512', Blob.valueOf(peopleObj.user__c)));
        peopleObj.User_Created_DateTime__c = DateTime.now();
            
        peopleObj.City__c = 'dummy';
        peopleObj.Company_Name__c = 'dummy';
        peopleObj.Country__c = 'dummy';
        peopleObj.Department__c = 'dummy';
        peopleObj.Email__c = 'dummy@dummy.com';
        peopleObj.Employee_Number__c = '1223';
        peopleObj.Fax__c = '1111';
        peopleObj.First_Name__c = 'dummy';
        peopleObj.Last_Name__c = 'dummy';
        peopleObj.Mobile_Phone__c = '1234567890';
        peopleObj.Phone__c = '1234567890';
        peopleObj.Postal_Code__c = '123';
        peopleObj.State__c = 'dummy';
        peopleObj.Street__c = 'dummy';
        peopleObj.Title__c = 'dummy';
        peopleObj.Last_Edited_DateTime__c = DateTime.now();
        peopleObj.Joining_Date__c = Date.today().addYears(22);
    	peopleObj.Birth_Date__c = Date.today().addYears(22);

        insert peopleObj;
    }

    public static void createUserAndPeople() {
		
        Profile pfl = [select id from profile where name='Standard User' LIMIT 1];
        String lastName = 'lastname';
        User testUser = new User(alias = 'u1', email='dummy@dummy.com', title=lastName,
            emailencodingkey='UTF-8', firstname=lastname,lastname=lastName, languagelocalekey='en_US',
            localesidkey='en_US', profileid = pfl.Id, city=lastName,state=lastName, 
            aboutme=lastName,phone=lastname,Extension=lastname,MobilePhone=lastname,
            country='United States' +lastName, CommunityNickname = 'u_' + Math.random(),
            department='a',
            timezonesidkey='America/Los_Angeles', username=lastName+'_usr@testorg.com');
          
        insert testUser;
    }

    @isTest
    public static void testBatchUserSync(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserSyncTest());
        SImpplrContext.locationNormalizationEnabled = true;

		BatchGoogleUserSync bGUSObj = new BatchGoogleUserSync('userSync');
		Database.executeBatch(bGUSObj, 1);
        
		Test.stopTest();
        list<Logs__c> log = [Select Id, Log_Data__c from Logs__c];
        System.assertEquals('successful', log[0].Log_Data__c,'User Sync failed');
    }
     
   @isTest
    public static void testBatchCleanSyncField(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserSyncTest());

        BatchGoogleUserSync bGUSObj = new BatchGoogleUserSync('CleanSyncField');
        Database.executeBatch(bGUSObj, 10);  
        Test.stopTest();
        list<People__c> people = [Select Id, Sync_Field__c from People__c Where Email__c = 'dummy@dummy.com'];
        System.assertEquals(null, people[0].Sync_Field__c,'Clean Sync failed');

	}
    
    /**
     * @description test case with custom address fields
     */
    
   @isTest
    public static void testBatchCleanSyncFieldUpdatedAppConfig(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserSyncTest());
        
                App_Config__c appConfigRecord = [SELECT Id, 
                PDS_First_Name__c, PDS_Last_Name__c, PDS_Title__c, PDS_Email__c, PDS_Manager_Id__c, PDS_Department__c, 
                PDS_Company_Name__c, PDS_Street__c, PDS_Postal_Code__c, PDS_Joining_Date__c, PDS_Birth_Date__c,
                PDS_City__c, PDS_State__c, PDS_Country__c, PDS_Phone__c, PDS_Mobile_Phone__c, 
                PDS_Joining_Date_Key__c, PDS_Birth_Date_Key__c, PDS_Company_Name_Key__c, PDS_Query_Filter__c ,
                PDS_Street_Key__c, PDS_State_Key__c, PDS_City_Key__c, PDS_Country_Key__c, PDS_Postal_Code_Key__c                         
                FROM App_Config__c LIMIT 1];
        
		appConfigRecord.PDS_Street_Key__c ='Simpplr.StreetName';
		appConfigRecord.PDS_State_Key__c ='Simpplr.StateName';
		appConfigRecord.PDS_City_Key__c ='Simpplr.CityName';
		appConfigRecord.PDS_Country_Key__c ='Simpplr.CountryName';
		appConfigRecord.PDS_Postal_Code_Key__c ='Simpplr.PostalCodeName';
        appConfigRecord.PDS_Joining_Date_Key__c ='Simpplr.JoiningDate';
        appConfigRecord.PDS_Birth_Date_Key__c ='Simpplr.Birthdate';
        appConfigRecord.PDS_Company_Name_Key__c ='Simpplr.CompanyName';
        update appConfigRecord;

        BatchGoogleUserSync bGUSObj = new BatchGoogleUserSync('CleanSyncField');
        Database.executeBatch(bGUSObj, 10);  
        Test.stopTest();
        list<People__c> people = [Select Id, Sync_Field__c from People__c Where Email__c = 'dummy@dummy.com'];
        System.assertEquals(null, people[0].Sync_Field__c,'Clean Sync failed');

	}
    
           @isTest
    public static void testBatchUserSyncUpdatedAppConfig(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserSyncTest());
        
                App_Config__c appConfigRecord = [SELECT Id, 
                PDS_First_Name__c, PDS_Last_Name__c, PDS_Title__c, PDS_Email__c, PDS_Manager_Id__c, PDS_Department__c, 
                PDS_Company_Name__c, PDS_Street__c, PDS_Postal_Code__c, PDS_Joining_Date__c, PDS_Birth_Date__c,
                PDS_City__c, PDS_State__c, PDS_Country__c, PDS_Phone__c, PDS_Mobile_Phone__c, 
                PDS_Joining_Date_Key__c, PDS_Birth_Date_Key__c, PDS_Company_Name_Key__c, PDS_Query_Filter__c ,
                PDS_Street_Key__c, PDS_State_Key__c, PDS_City_Key__c, PDS_Country_Key__c, PDS_Postal_Code_Key__c                         
                FROM App_Config__c LIMIT 1];
        
		appConfigRecord.PDS_Street_Key__c ='Simpplr.StreetName';
		appConfigRecord.PDS_State_Key__c ='Simpplr.StateName';
		appConfigRecord.PDS_City_Key__c ='Simpplr.CityName';
		appConfigRecord.PDS_Country_Key__c ='Simpplr.CountryName';
		appConfigRecord.PDS_Postal_Code_Key__c ='Simpplr.PostalCodeName';
        appConfigRecord.PDS_Joining_Date_Key__c ='Simpplr.JoiningDate';
        appConfigRecord.PDS_Birth_Date_Key__c ='Simpplr.Birthdate';
        appConfigRecord.PDS_Company_Name_Key__c ='Simpplr.CompanyName';
        update appConfigRecord;

		BatchGoogleUserSync bGUSObj = new BatchGoogleUserSync('userSync');
		Database.executeBatch(bGUSObj, 1);
        
		Test.stopTest();
        list<Logs__c> log = [Select Id, Log_Data__c from Logs__c];
        System.assertEquals('successful', log[0].Log_Data__c,'User Sync failed');
	}
	public @isTest static void testBatchForCleaningFields(){
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BatchGoogleUserSyncTest());

		BatchGoogleUserSync bGUSObj = new BatchGoogleUserSync('CleanSyncField');
		Database.executeBatch(bGUSObj, 1);      

		Test.stopTest();
        list<People__c> people = [Select Id, Sync_Field__c from People__c Where Email__c = 'dummy@dummy.com'];
        System.assertEquals(null, people[0].Sync_Field__c,'Clean Sync failed');

	}
  
  public HTTPResponse respond(HTTPRequest req) {

      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      
      if(req.getEndpoint().contains('action=getgsuiteusers')){
        res.setBody('{"result":{"users":[{"kind":"admin#directory#user","id":"112578370361342691059","etag":"nM32qckM4XsKqhG",' + 
                    '"Simpplr": {"Birthdate": "1947-08-15","CompanyName": "Simpplr","JoiningDate": "2000-01-01","StreetName":"dummyStreet","StateName":"dummyState","CityName":"dummyCity","CountryName":"dummyCountry","PostalCodeName":"dummyPostalCode"},"customSchemas":{"Simpplr":{"Birthdate":"1947-08-15","CompanyName":"Simpplr","JoiningDate":"2000-01-01","StreetName":"dummyStreet","StateName":"dummyState","CityName":"dummyCity","CountryName":"dummyCountry","PostalCodeName":"dummyPostalCode"}}, "primaryEmail":"dummy@dummy.com","name":{"givenName":"admin","familyName":"two","fullName":"admin two"},"isAdmin":false,"isDelegatedAdmin":true,"lastLoginTime":"2019-03-28T11:11:38.000Z","creationTime":"2019-03-28T11:00:34.000Z","agreedToTerms":true,"suspended":false,"archived":false,"changePasswordAtNextLogin":false,"ipWhitelisted":false,"emails":[{"address":"admintwo@bhootnath.in","primary":true}],"externalIds":[{"value":"E007","type":"organization"}],"relations":[{"value":"amit@bhootnath.in","type":"manager"}],"addresses":[{"type":"work","formatted":"WeWork, Sector 15, Gurgaon, Haryana, India","streetAddress":"dummy street","postalCode":"1234","locality":"dummy","region":"dummy","country":"dummy"}],"organizations":[{"title":"Simpplr Admin","name":"name hai ye","primary":true,"customType":"","department":"Intranet Admin","description":"Permanent"}],"phones":[{"value":"900","type":"work"},{"value":"100","type":"mobile"}],"locations":[{"type":"desk","area":"desk","buildingId":"WeWork","floorName":"2nd Floor","floorSection":"Right Side"}],"customerId":"C01gzjfgr","orgUnitPath":"","isMailboxSetup":true,"isEnrolledIn2Sv":false,"isEnforcedIn2Sv":false,"includeInGlobalAddressList":true},{"kind":"admin#directory#user","id":"112578370361342691087","etag":"nM32qcee4XsKqhG-zylXvkNQRY8foRHt9wwiAEAmQRcZe09epyAwLE","primaryEmail":"enemy1@dummy1.com","name":{"givenName":"dummy2","familyName":"dddddd","fullName":"dummy2 ddddd"},"isAdmin":false,"isDelegatedAdmin":true,"lastLoginTime":"2019-03-28T11:11:38.000Z","creationTime":"2019-03-28T11:00:34.000Z","agreedToTerms":true,"suspended":false,"archived":false,"changePasswordAtNextLogin":false,"ipWhitelisted":false,"emails":[{"address":"enemy1@dummy1.com","primary":true}],"externalIds":[{"value":"E008","type":"organization"}],"relations":[{"value":"dummy@dummy.com","type":"manager"}],"addresses":[{"type":"work","formatted":"WeWork, Sector 15, Gurgaon, Haryana, India","streetAddress":"dummy street","postalCode":"1234","locality":"dummy","region":"dummy","country":"dummy"}],"organizations":[{"title":"Simpplr Admin","name":"name hai ye","primary":true,"customType":"","department":"Intranet Admin","description":"Permanent"}],"phones":[{"value":"900","type":"work"},{"value":"100","type":"mobile"}],"locations":[{"type":"desk","area":"desk","buildingId":"WeWork","floorName":"2nd Floor","floorSection":"Right Side"}],"customerId":"C01gzjfgr","orgUnitPath":"","isMailboxSetup":true,"isEnrolledIn2Sv":false,"isEnforcedIn2Sv":false,"includeInGlobalAddressList":true}]}}');

      }else if(req.getEndpoint().contains('https://www.googleapis.com/oauth2/v4/token')){
        res.setBody('{"access_token":"xyzmmmmm","type":"bearer","expires_in":"3600"}');	

      }

      res.setStatusCode(200);
      res.setStatus('success');
      
      return res;    
    }
}