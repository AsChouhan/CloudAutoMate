public with sharing class DataTransferInDifferentOrg{
    public Static String accessToken = '00D5i00000EUVZA!AQ8AQB9XF7T2Se8PQ4TfqtskJnm2e5lDOC47tRCbKUn1QCoupMD0qK9KDhI8xmVeTw7s4Fsed0VbYp.AQO8ajXV3wyoMK_MH';
    @AuraEnabled
    public static object objectList(){
        Map<String, object> responseMap = new Map<String, object>();
        //IsDeletable
        String str = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v58.0/tooling/query/?q=SELECT+QualifiedApiName+From+EntityDefinition+where+IsCustomizable=true';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(str);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode() + ' ' + res.getBody());
        if (res.getStatusCode() == 200){
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody());
            for (String st : responseMap.keyset()){
                System.debug(st + ' -->  ' + responseMap.get(st));
            }
            return responseMap.get('records');
        }
        return 'no code found';
    }

    @AuraEnabled
    public static object getRelatedObject(String parentObject){
        Map<String, object> responseMap = new Map<String, object>();
        //IsDeletable
        String str = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v58.0/tooling/query/?q=SELECT+ChildSobjectId,RelationshipName+From+RelationshipDomain+where+ParentSobjectId=' + '\'' + parentObject + '\'' + '+limit+10';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(str);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode() + ' ' + res.getBody());
        if (res.getStatusCode() == 200){
            responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody());
            for (String st : responseMap.keyset()){
                System.debug(st + ' -->  ' + responseMap.get(st));
            }
            return responseMap.get('records');
        }
        return 'no code found';
    }

    @AuraEnabled
    public static List<Object> getRecords(String parentObject,List <String>childObjects){
        System.debug(childObjects);
        String instanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug(instanceUrl);
        String objectApiName = parentObject;
        HttpRequest request = new HttpRequest();
        String query = 'SELECT+Id,Name';
        for(String st : childObjects){
            query+=',(SELECT+Id,Name+FROM+'+st+')';
        }
        query+='+FROM+'+objectApiName;
        System.debug(query);
        request.setEndpoint(instanceUrl + '/services/data/v58.0/query/?q='+query);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        Map<String, List<Object>> recordsMap = new Map<String, List<Object>>();
        HttpResponse response = new Http().send(request);
            System.debug(response.getStatusCode());
            List<Object> records = new List<Object> ();
        if (response.getStatusCode() == 200){
            String jsonResponse = response.getBody();
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
             records = (List<Object>) result.get('records');

        }
        System.debug(records);
       return records;
    }

    @AuraEnabled
    public static String sendRecords(String Data){
       System.debug(Data);
       List<Map<String, Object>> records = new List<Map<String, Object>>();

       Map<String, Object> record1 = new Map<String, Object>{
           'attributes' => new Map<String, Object>{
               'type' => 'Account',
               'referenceId' => 'ref4'
           },
           'name' => 'bhanuSHarma'
       };
       records.add(record1);
       
       Map<String, Object> record2 = new Map<String, Object>{
           'attributes' => new Map<String, Object>{
               'type' => 'Account',
               'referenceId' => 'ref5'
           },
           'name' => 'AshishSingh'
       };
       records.add(record2);
       
       Map<String, Object> requestBody = new Map<String, Object>{
           'records' => records
       };

       System.debug(JSON.serialize(requestBody));
        String str = 'https://briskmind9-dev-ed.my.salesforce.com/services/data/v58.0/composite/tree/Account';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(str);
        req.setMethod('POST');
        req.setBody('{ "records" :[{ "attributes" : {"type" : "Account", "referenceId" : "ref1"}, "name" : "SampleAccount", "phone" : "1234567890", "numberOfEmployees" : "100", "industry" : "Banking", "Contacts" : { "records" : [{ "attributes" : {"type" : "Contact", "referenceId" : "ref2"}, "lastname" : "atul", "title" : "President" },{ "attributes" : {"type" : "Contact", "referenceId" : "ref3"}, "lastname" : "vans", "title" : "Vice President", "email" : "sale@salesforce.com" }] } },{ "attributes" : {"type" : "Account", "referenceId" : "ref4"}, "name" : "SampleAccou444nt2", "phone" : "1234567890", "website" : "www.salesforce2.com", "numberOfEmployees" : "100", "industry" : "Banking" }] }');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer 00D5g00000KCl9K!AQ0AQEw6pRjpI_FYhZagXxPr0BlyJ.nGPIYR7d8T82Nkq3rCrvEJiR0d7U5e6X3.Jagcf3Qr9W_lWR77GVhsU7rj7AsOVfIj');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode() + ' ' + res.getBody());
        if(res.getStatusCode() == 201) {
            
            return 'DOne';
        }
         return 'no code found';
    }

}