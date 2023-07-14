public with sharing class salesforceintiApex {
    @AuraEnabled
    public static List<object> getFiles(){        
            List<object> files = new List<object>();
            String methodName = 'GET';
            String endPoint = 'callout:salesforce_name_credential1/services/apexrest/content'
            HttpRequest req = new HttpRequest();
            req.setMethod(methodName);
            req.setEndpoint(endPoint);

            Http ht = new Http();
            HttpResponse res = ht.send(req);
            System.debug(res.getStatusCode());
            System.debug(res.getBody());
            if(res.getStatusCode() == 200){
                System.debug(JSON.deserializeUntyped(res.getBody()));
                files = (List<Object>) JSON.deserializeUntyped(res.getBody());
                System.debug(files.size());
            }
            return files;        
    }

    @AuraEnabled
    public static String uploadFiles(String filename, String file64){
        System.debug(filename+'  '+ file64);
        String methodName = 'POST';
        String endPoint = 'callout:salesforce_name_credential1/services/apexrest/content';
        String body = '"filename": "'+filename+'" , "file": "'+file64+'"';
        HttpRequest req = new HttpRequest();
        req.setMethod(methodName);
        req.setEndpoint(endPoint);
        req.setBody(body);

        Http ht = new Http();
        HttpResponse res = ht.send(req);
        System.debug(res.getStatusCode());
       if(res.getStatusCode() == 200){
            System.debug('Upload Success');
            return 'Upload Success';
       }
        return 'upload fail';
    }
}