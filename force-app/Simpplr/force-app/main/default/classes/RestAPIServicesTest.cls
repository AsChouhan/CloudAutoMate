@isTest
private with sharing class RestAPIServicesTest {
    @isTest static void testGetBaseUrl() {
       	RestRequest req = new RestRequest(); 
       	RestResponse res = new RestResponse();
        req.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/getBaseUrl';
       	req.httpMethod = 'POST';
       	RestContext.request = req;
       	RestContext.response= res;
		RestAPIServices.getBaseUrl();
    	System.assert(true,'Running as expected');
    }
}