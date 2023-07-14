public with sharing class ConfigureMetadataServiceClass {
    public static HttpResponse getRresponse(String methodName, String endPoint, Map<String, String> headers, String body){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        for(String st : headers.keySet()){
            req.setHeader(st,  headers.get(st));
        }       
        req.setMethod(methodName);
        if(body != ''){
            req.setBody(body);
        }
        Http ht = new Http();
        HttpResponse res = ht.send(req);
        return res;
    }
}