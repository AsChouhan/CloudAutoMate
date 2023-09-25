/**
 * @description       : rest api for RestAPIDataConsumer
 * @author            : simpplr.com
 * @last modified on  : 11-27-2021
 * @last modified by  : simpplr.com
**/
public with sharing class RestDataConsumerHandler{

    protected RestRequest req;
    protected RestResponse res;
    private String apiClass;

    /**
    * @description constructor
    * @param req request obj
    * @param res response obj
    * @param apiClass api class name
    **/
    public RestDataConsumerHandler(RestRequest req, RestResponse res, String apiClass) {
        this.req = req;
        this.res = res;
        this.apiClass = apiClass;
    }

    /**
    * @description handle request
    **/
    public void handleRequest(){
        // set context and set headers and parameters
        RestWebServiceHandler restHandler = new RestWebServiceHandler(req, res, apiClass);
        restHandler.setContext();
        restHandler.setHeaders();
        restHandler.setParams();
        restHandler.setRequestContext();

        // invoke target class to execute the logic
        RestAPIDataConsumer apiConsumer = new RestAPIDataConsumer();
        apiConsumer.urlParams = restHandler.getRequestParameters();
        apiConsumer.handleRequest();

        res.StatusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(apiConsumer.jsonString);

        try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }
    
    
}