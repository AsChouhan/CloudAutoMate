public class DropBoxServiceClass {
    public static HttpResponse getRresponse(String methodName, String endPoint, Map<String, String> headers){

        System.debug(methodName+'\n'+endPoint);
        for(string str : headers.keySet()){
            System.debug(str+'  ->   '+headers.get(str));
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        
      
        for(String st : headers.keySet()){
            req.setHeader(st,  headers.get(st));
        }       
        req.setMethod(methodName);
        Http ht = new Http();
        HttpResponse res = ht.send(req);
        return res;
    } 

    public static HttpResponse getRresponse(String methodName, String endPoint, Map<String, String> headers, String body, Integer timeOut){

        System.debug(methodName+'\n'+endPoint);
        for(string str : headers.keySet()){
            System.debug(str+'  ->   '+headers.get(str));
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        
      
        for(String st : headers.keySet()){
            req.setHeader(st,  headers.get(st));
        }       
        req.setMethod(methodName);
        req.setBody(body);
        req.setTimeout(timeOut);
        Http ht = new Http();
        HttpResponse res = ht.send(req);
        return res;
    }
}