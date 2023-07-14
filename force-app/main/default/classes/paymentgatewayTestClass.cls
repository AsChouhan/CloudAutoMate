@isTest
public with sharing class paymentgatewayTestClass implements HttpCalloutMock {
    public static HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint()=='https://apitest.authorize.net/xml/v1/request.api'){
            res.setBody('"description":"This transaction has been approved."');
        }
        return res;
    }
}