/**
 * @description       : /services/apexrest/RestAPIDataConsumer
 * @author            : simpplr.com
 * @last modified on  : 11-23-2021
 * @last modified by  : simpplr.com
**/
@RestResource(urlMapping='/RestAPIDataConsumer/*')
global with sharing class RestDataConsumer {
    
    /**
    * @description HTTP GET
    **/
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        RestDataConsumerHandler restHandler = new RestDataConsumerHandler(req, res, RestDataConsumer.class.getName());
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

        RestDataConsumerHandler restHandler = new RestDataConsumerHandler(req, res, RestDataConsumer.class.getName());
        restHandler.handleRequest();

        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    } 
}