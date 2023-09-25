@isTest
private class DataServicesTestClass {
    static People__c currentUserPeopleObj; 
    
    @testSetup static void setup() {
		currentUserPeopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
	}
    
    @isTest static void doPostTest1(){
   		
   		Map<String, Object>mapRequestBody = new Map<String,Object>();
   		mapRequestBody.put('action','create');
   		mapRequestBody.put('objecttype', 'notification');
   		mapRequestBody.put('externalUrl', 'https://google.com');
   		
   		map<String,Object>mapJsonBody = new map<String, Object>();
   		mapJsonBody.put('sentto', userInfo.getUserEmail());
   		mapJsonBody.put('sentby', userInfo.getUserEmail());
   		mapJsonBody.put('actionby', userInfo.getUserEmail());
   		mapJsonBody.put('propertyName', 'email');
   		
   		mapRequestBody.put('jsondata',mapJsonBody);
	
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/abc/xyz/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(mapRequestBody));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            DataServices.doPost();
        Test.StopTest();

		System.assert(true, 'Running as expected');
    }
    
     @isTest static void doPostTest2(){
     	   		
		currentUserPeopleObj = [select Id from People__c];
   		Alert__c alertObj = new Alert__c();
		alertObj.name = 'Test Alert';
		alertObj.Author__c = currentUserPeopleObj.Id;
		alertObj.Alert_Message__c = 'Hi Alert';
		alertObj.Display_To_DateTime__c = System.now().addDays(-2);
		alertObj.Is_Deleted__c = false;
		insert alertObj;
		
		Map<String, Object>mapRequestBody = new Map<String,Object>();
   		mapRequestBody.put('action','expirenow');
   		mapRequestBody.put('objecttype', 'alert');
   		mapRequestBody.put('externalUrl', 'https://google.com');
   		
   		map<String,Object>mapJsonBody = new map<String, Object>();
   		mapJsonBody.put('recordid', alertObj.Id);
   		mapRequestBody.put('jsondata',mapJsonBody);
   		
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/abc/xyz/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(mapRequestBody));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            DataServices.doPost();
        Test.StopTest();

		System.assert(true, 'Running as expected');
    
    }
    
     @isTest static void doPostTest3(){
		
   		Map<String, Object>mapRequestBody = new Map<String,Object>();
   		mapRequestBody.put('action','create');
   		mapRequestBody.put('objecttype', 'alert');
   		mapRequestBody.put('externalUrl', 'https://google.com');
   		
   		map<String,Object>mapJsonBody = new map<String, Object>();
   		mapJsonBody.put('displayfrom',System.now().addDays(+1));
   		mapJsonBody.put('displayto', System.now());
   		mapJsonBody.put('siteid', 1234);
   		mapRequestBody.put('jsondata',mapJsonBody);
		
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        
        req.requestURI = '/services/apexrest/abc/xyz/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(mapRequestBody));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            DataServices.doPost();
        Test.StopTest();

		System.assert(true, 'Running as expected');
    }
    
    @isTest static void doPostTest4(){
   		
   		currentUserPeopleObj = [select Id from People__c];
   		Alert__c alertObj = new Alert__c();
		alertObj.name = 'Test Alert';
		alertObj.Author__c = currentUserPeopleObj.Id;
		alertObj.Alert_Message__c = 'Hi Alert';
		alertObj.Display_From_DateTime__c = System.now().addDays(+1);
		alertObj.Display_To_DateTime__c = System.now().addDays(+10);
		alertObj.Is_Deleted__c = false;
		insert alertObj;
		
   		Map<String, Object>mapRequestBody = new Map<String,Object>();
   		mapRequestBody.put('action','update');
   		mapRequestBody.put('objecttype', 'alert');
   		mapRequestBody.put('externalUrl', 'https://google.com');
   		
   		map<String,Object>mapJsonBody = new map<String, Object>();
   		mapJsonBody.put('recordid', alertObj.Id);
   		mapJsonBody.put('isdismissable', 'yes');
   		mapRequestBody.put('jsondata',mapJsonBody);		
		
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/abc/xyz/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(mapRequestBody));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            DataServices.doPost();
        Test.StopTest();

		System.assert(true, 'Running as expected');
    }
    
        @isTest static void doPostTest5(){
   		
   		//String JSONMsg = '{"action":"update", "objecttype" : "alert", '+'"externalUrl":"https://google.com"}';
   		currentUserPeopleObj = [select Id from People__c];
   		Alert__c alertObj = new Alert__c();
		alertObj.name = 'Test Alert';
		alertObj.Author__c = currentUserPeopleObj.Id;
		alertObj.Alert_Message__c = 'Hi Alert';
		alertObj.Display_To_DateTime__c = System.now().addDays(-2);
		alertObj.Is_Deleted__c = false;
		insert alertObj;
		
   		Map<String, Object>mapRequestBody = new Map<String,Object>();
   		mapRequestBody.put('action','displaynow');
   		mapRequestBody.put('objecttype', 'alert');
   		mapRequestBody.put('externalUrl', 'https://google.com');
   		
   		map<String,Object>mapJsonBody = new map<String, Object>();
   		mapJsonBody.put('recordid', alertObj.Id);
   		mapRequestBody.put('jsondata',mapJsonBody);		
		
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/abc/xyz/';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JSON.serialize(mapRequestBody));
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            DataServices.doPost();
        Test.StopTest();

		System.assert(true, 'Running as expected');
    }
}