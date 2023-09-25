/**
 * @description       : /services/apexrest/DataServerRO
 * @author            : simpplr.com
 * @last modified on  : 11-23-2021
 * @last modified by  : simpplr.com
**/
@RestResource(urlMapping='/DataServerRO/*')
global with sharing class DataServerRO {
    
    /**
    * @description HTTP GET
    **/
    @ReadOnly
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestWebServiceHandler restHandler = new RestWebServiceHandler(req, res, DataServerRO.class.getName());
        restHandler.handleRequest();
        
        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }

    /**
    * @description HTTP POST
    **/
    @ReadOnly
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestWebServiceHandler restHandler = new RestWebServiceHandler(req, res, DataServerRO.class.getName());
        restHandler.handleRequest();

        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    } 
}