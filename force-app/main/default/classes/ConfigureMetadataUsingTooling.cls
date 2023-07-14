public with sharing class ConfigureMetadataUsingTooling {
    public static String sessionId = '00D5i00000EUVZA!AQ8AQJb_QImWnrVEBl9bxC6AfooiosEhLdqzkQDl6rEvDeFq4lE0TWk.zvEtD8gMlIVOyKFKKefNjaOGSHv575xcPn0SqU.P';

    // classMetadata contains class name and class body for deploy..
    // sameple classMetadata = '{"name":"aasheesh","body":"public class aasheesh{public String name = \'bhanu\';}"}'
    public static void createApexClass(String classMetadata){
        ConfigureMetadataWrapper.createApexWrapper meta = (ConfigureMetadataWrapper.createApexWrapper)System.JSON.deserialize(classMetadata, ConfigureMetadataWrapper.createApexWrapper.class);
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ApexClass';
        String body = '{"Name": "'+meta.name+'","Body" : "'+meta.body+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getRresponse('POST',endPoint, headers, body);
        SYstem.debug(res.getBody());
    }
    
    // Update apex class...   
    
    //Ganreting metadata containor id...
    public static String getMetadataContainer(){ 
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/query/?q=select+id+from+MetadataContainer+where+name=\'myContainor\'';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getRresponse('GET',endPoint, headers, '');
        SYstem.debug(res.getBody());        
        
        //Getting container id.
        JSONParser parser = JSON.createParser(res.getBody());
        System.JSONToken jt;        
        while (parser.nextToken() != null) {   
            if(parser.getCurrentToken()==JSONToken.FIELD_NAME && parser.getText() == 'id'){
                jt = parser.nextToken();       
            }   
            if(jt== parser.getCurrentToken()){
                System.debug(parser.getText());
                return parser.getText();
            }
        }
        return null;
    }

    // Ganreting apex class mamber id...
    public static String createApexClassMember(String apexClassMetadata){
        ConfigureMetadataWrapper.UpdateApexWrapper meta = (ConfigureMetadataWrapper.UpdateApexWrapper)System.JSON.deserialize(apexClassMetadata, ConfigureMetadataWrapper.UpdateApexWrapper.class);
        HttpRequest req = new HttpRequest();
        //Metadata container Id...
        String MetadataContainerId = getMetadataContainer();
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ApexClassMember';
        String body = '{"ContentEntityId":"'+meta.id+'","MetadataContainerId":"'+MetadataContainerId+'","Body":"'+meta.body+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getRresponse('POST',endPoint, headers, body);
        SYstem.debug(res.getBody());
        return MetadataContainerId;
    }

    // apexMetadata contains apexClass Id and body(updated code)...   
    // sample apexMetadata = '{"id":"01p5i00000WKLSQAA5","body":"public class aasheesh{public String name = \'aasheesh singh chouhan\';}"}'
    public static void updateApex(String apexMetadata){
        String metadataContainerId = createApexClassMember(apexMetadata);
        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v36.0/tooling/sobjects/ContainerAsyncRequest';
        String body = '{ "IsCheckOnly": "false","MetadataContainerId":"'+metadataContainerId+'"}';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getRresponse('POST',endPoint, headers, body);
        SYstem.debug(res.getBody());
    }   


    // Lwc Configuration methods....
    public static void createLwcComponent(String lwcComponentMetadata){   
        ConfigureMetadataWrapper.LwcMetaWrapper meta = (ConfigureMetadataWrapper.LwcMetaWrapper)System.JSON.deserialize(lwcComponentMetadata, ConfigureMetadataWrapper.LwcMetaWrapper.class);
        String targ =  '"targets": {"target": '+JSON.serialize(meta.target)+'}';
        targ = targ.replace('(','[').replace(')',']');
        String body = '{"FullName":"'+meta.fullName+'","Metadata":{"apiVersion":48,"description": "'+meta.description+'","isExplicitImport": false,"isExposed": true,"masterLabel": "'+meta.masterLabel+'",'+targ+'}}';

        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/tooling/sobjects/LightningComponentBundle';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getRresponse('POST',endPoint, headers, body);
        system.debug(res.getBody());

        JSONParser parser = JSON.createParser(res.getBody());
        System.JSONToken jt;
        String bundleId;
        while (parser.nextToken() != null) {   
            if(parser.getCurrentToken()==JSONToken.FIELD_NAME && parser.getText() == 'id'){
                jt = parser.nextToken();       
            }   
            if(jt== parser.getCurrentToken()){
                bundleId = parser.getText();
                
                System.debug(bundleId);
            }
        }       
    }

    public static void insertSourceToLwcComponent(String lwcInsertMetadata){
        ConfigureMetadataWrapper.LwcInsertWrapper meta = (ConfigureMetadataWrapper.LwcInsertWrapper)System.JSON.deserialize(lwcInsertMetadata, ConfigureMetadataWrapper.LwcInsertWrapper.class);
        String path = 'lwc/'+meta.devloperName+'/'+meta.devloperName+'.'+meta.formate;
        String body = '{"FilePath": "'+path+'","LightningComponentBundleId":"'+meta.componentId+'","Format":"'+meta.formate+'", "Source" : "' + meta.sourceCode + '"}';
        System.debug(body);

        Map<String, String> headers = new Map<String, String>();
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/tooling/sobjects/LightningComponentResource';
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getRresponse('POST',endPoint, headers, body);
        system.debug(res.getBody());
    }    
    
    public static void updateLwcResource(String lwcResouceMetadata){   
        ConfigureMetadataWrapper.LwcResourceWrapper meta = (ConfigureMetadataWrapper.LwcResourceWrapper)System.JSON.deserialize(lwcResouceMetadata, ConfigureMetadataWrapper.LwcResourceWrapper.class);
        Map<String, String> headers = new Map<String, String>();
        String body = '{"Source" : "' + meta.source + '"}';
        String endPoint = URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v49.0/tooling/sobjects/LightningComponentResource/'+meta.sourceFileId;
        headers.put('Authorization', 'Bearer '+sessionId);
        headers.put('Content-Type', 'application/json');
        HttpResponse res = ConfigureMetadataServiceClass.getRresponse('PATCH',endPoint, headers, body);
        while (res.getStatusCode() == 302) {
            System.debug('inside 302');
            endPoint = res.getHeader('Location');
            res = ConfigureMetadataServiceClass.getRresponse('PATCH',endPoint, headers, body);
        }
        System.debug(res.getStatusCode());
        system.debug(res.getBody());
    }    
}