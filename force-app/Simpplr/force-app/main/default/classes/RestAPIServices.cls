@RestResource(urlMapping='/rest/*')
global with sharing class RestAPIServices{
    @HttpPost   
    global static void getBaseUrl() {
    		RestContext.response.responseBody = Blob.valueOf('API depricated, please use getBasicAppInformation');
    }
}