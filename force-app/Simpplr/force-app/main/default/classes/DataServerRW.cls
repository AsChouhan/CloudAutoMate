/**
 * @description       : /services/apexrest/DataServerRW
 * @author            : simpplr.com
 * @last modified on  : 11-23-2021
 * @last modified by  : simpplr.com
**/
@RestResource(urlMapping='/DataServerRW/*')
global with sharing class DataServerRW {
    
    /**
    * @description HTTP GET
    **/
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestWebServiceHandler restHandler = new RestWebServiceHandler(req, res, DataServerRW.class.getName());
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
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug('@@@ req '+req.requestBody);
        RestWebServiceHandler restHandler = new RestWebServiceHandler(req, res, DataServerRW.class.getName());
        restHandler.handleRequest();

        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    } 
}