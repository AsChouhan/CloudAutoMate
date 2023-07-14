public class DropBoxApex {
    static DropBoxUserInfo__mdt custMeta = [select AppKey__c, AppScreat__c, Redirect_Url__c from DropBoxUserInfo__mdt];
    
    static String key1 = custMeta.AppKey__c;
    static String secert = custMeta.AppScreat__c;
    static string redirect_uri = custMeta.Redirect_Url__c;

    @AuraEnabled
    public static string creatAuthUrl(){
        
        System.debug('auth url called');
        String key = EncodingUtil.urlEncode(key1,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');

        String authuri = '';
        authuri = 'https://www.dropbox.com/oauth2/authorize?'+
        'client_id='+key+
        '&token_access_type=offline'+
        '&response_type=code'+            
        '&redirect_uri='+uri;
        
        System.debug(authuri);
        return authuri;
        
    }

    @AuraEnabled
    public static string checkUserInDB(){
        List<DropBox_Users__c> userDetail = [select Name from DropBox_Users__c where User_ID__c=: userInfo.getUserId()];
        if(userDetail.size() > 0){
            return 'FOUND';
        }else{
            return 'NOT FOUND';
        }

    }

    @AuraEnabled
    public static String checkExpiration(){
        DropBox_Users__c userDetail = [select Expire_In__c from DropBox_Users__c where User_ID__c=: userInfo.getUserId()];
        if(userDetail.Expire_In__c < Datetime.now()){
            return 'EXPIRED';
        }else{
            return 'NOT EXPIRED';
        }
    }

    @AuraEnabled
    public static string getAccessToken(String code){
            String methodName = 'POST';
            String endPoint = 'https://api.dropboxapi.com/oauth2/token';
            String body = 'code='+code+'&client_id='+key1+'&client_secret='+secert+'&redirect_uri='+redirect_uri+'&grant_type=authorization_code';
            System.debug(body);
            Integer timeOut = 60000;
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('content-type','application/x-www-form-urlencoded');
            headerMap.put('Content-length',String.valueOf(body.length()));

            HttpResponse res = DropBoxServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);
            System.debug(res.getStatusCode());
            String resp = res.getBody();
            Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(resp) ;
            String accessToken =  String.valueOf(responseMap.get('access_token'));
            String refreshToken = String.valueOf(responseMap.get('refresh_token'));
            System.debug('refresh token   ->   '+refreshToken);
            Datetime dTime = Datetime.now();
            Long tokenDate = dTime.getTime();
            tokenDate = tokenDate + (Integer) responseMap.get('expires_in') * 1000;
            dTime = Datetime.newInstance(tokenDate); 

            if(refreshToken == null){
                DropBox_Users__c userDetail = [select Name, Access_Token__c, Refresh_Token__c, User_ID__c, Expire_In__c from DropBox_Users__c where User_ID__c=: userInfo.getUserId()];
                userDetail.Name = userInfo.getName();
                userDetail.Access_Token__c = accessToken;
                userDetail.User_ID__c = UserInfo.getUserId();
                userDetail.Expire_In__c = dTime;
                update userDetail;
            }else{
                DropBox_Users__c userDetail = new DropBox_Users__c(Name= UserInfo.getName(), Access_Token__c= accessToken, Refresh_Token__c= refreshToken, Expire_In__c=  dTime, User_ID__c= UserInfo.getUserId());
                insert userDetail;
            }
            System.debug(res.getStatusCode());
            return accessToken;       
    }


    @AuraEnabled
    public static String getNewAccessToken(){
        DropBox_Users__c userDetail = [select Name, Access_Token__c, Refresh_Token__c, User_ID__c, Expire_In__c from DropBox_Users__c where User_ID__c=: userInfo.getUserId()];
        System.debug(key1+'\n'+secert);
        System.debug('old access token -->  '+userDetail.Access_Token__c);
        String methodName = 'POST';
        String endPoint = 'https://api.dropboxapi.com/oauth2/token';
        String body = 'refresh_token=' + userDetail.Refresh_Token__c + '&grant_type=refresh_token&client_id=' +key1+ '&client_secret=' + secert;
        System.debug(body);
        Integer timeOut = 60000;
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-length', String.valueOf(endPoint.length()));      
        HttpResponse res = DropBoxServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);  
       System.debug(res.getStatusCode());
        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(res.getBody()) ; 
        System.debug('a');
        String accesstoken =  String.valueOf(responseMap.get('access_token'));
        System.debug('a1');
        Datetime dTime = Datetime.now();
        Long tokenDate = dTime.getTime();

        for(string str : responseMap.keySet()){
            System.debug(str+'   - >   '+responseMap.get(str));
        }


        System.debug('expire above');
        System.debug(responseMap.get('expires_in'));
        tokenDate = tokenDate + ((Integer) responseMap.get('expires_in') * 1000);
        System.debug('a2');
        dTime = Datetime.newInstance(tokenDate);
        System.debug(accesstoken);
        
        userDetail.Access_Token__c = accesstoken;
        userDetail.Expire_In__c = dTime;
        update userDetail;
        return 'UPDATED';
    }

    @AuraEnabled
    public static List<object> getFiles(String path){
        
            System.debug('apex get files called');
            List<object> files = new List<object>();
            String userId = userInfo.getUserId();          
            DropBox_Users__c userDetail = [SELECT Access_Token__c FROM DropBox_Users__c WHERE User_ID__c =:userId];
            String accessToken = userDetail.Access_Token__c;
            System.debug(accessToken);
            String methodName = 'GET';
            String endPoint = 'https://api.dropboxapi.com/2/files/list_folder';
            String body = '{"path":"' + path + '"}';
            Integer timeOut = 60000;
            Map<String, String> headerMap = new Map<String, String>();
            headerMap.put('Authorization','Bearer ' + accessToken);
            headerMap .put('Content-Type', 'application/json');
            HttpResponse res = DropBoxServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);     
            
            System.debug(res.getStatusCode());
            if(res.getStatusCode()==200){
                string response = res.getBody();
                System.debug('a');
                String resBody = res.getBody();
                System.debug(res.getBody());
                resBody = resBody.replaceAll('.tag', 'tag');
                System.debug(resBody);
                Map<String, Object> results = (Map<String, Object>)
                    JSON.deserializeUntyped(resBody);              
                files = (List<Object>) results.get('entries');
            }
            System.debug(files.size());
            return files;        
    }

    @AuraEnabled
    public static String deleteFiles(String path){
        System.debug(path);
        DropBox_Users__c userDetail = [SELECT Access_Token__c FROM DropBox_Users__c WHERE User_ID__c =:userInfo.getUserId()];
        String methodName = 'POST';
        String endPoint = 'https://api.dropboxapi.com/2/files/delete_v2';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Authorization', 'Bearer '+userDetail.Access_Token__c);
        headerMap.put('Content-Type', 'application/json');
        String body = '{"path":"' + path + '"}';
        Integer timeOut = 60000;

        HttpResponse res = DropBoxServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);  
        
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            return 'FILE DELETED';
        }else{
            return 'ERROR WHILE DELETING FILE';
        }
    }

    @AuraEnabled
    public static object downloadFiles(String path){
        DropBox_Users__c userDetail = [SELECT Access_Token__c FROM DropBox_Users__c WHERE User_ID__c =:userInfo.getUserId()];
        String methodName = 'POST';
        String endPoint = 'https://api.dropboxapi.com/2/files/get_temporary_link';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Authorization', 'Bearer '+userDetail.Access_Token__c);
        headerMap.put('Content-Type', 'application/json');
        String body = '{"path":"' + path + '"}';
        Integer timeOut = 60000;

        HttpResponse res = DropBoxServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);  
        System.debug(res.getStatusCode());
        System.debug(res.getBody());

        if(res.getStatusCode() == 200){
            Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(res.getBody());
            for(String str : responseMap.keyset()){
                System.debug(str+'  ->   '+responseMap.get(str));
            }            
            return responseMap.get('link');
        }
        return 'none';
    }


   /* @AuraEnabled static void uploadFiles(String filename, String path ){
        System.debug('uploadFiles called');

    }*/

    @AuraEnabled
    public static String uploadFile(String filename, String path, String file){
        System.debug('vvgg');
        DropBox_Users__c userDetail = [SELECT Access_Token__c FROM DropBox_Users__c WHERE User_ID__c =:userInfo.getUserId()];
        System.debug('aaa');
        String dbxApiArg = '{"path":"'+ path + '/' + filename + '", "mode": "add", "autorename": true, "mute": false, "strict_conflict": false }';
        System.debug('at top');
        blob  b = EncodingUtil.base64Decode(file);
           Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://content.dropboxapi.com/2/files/upload');
            req.setMethod('POST');
            req.setHeader('Authorization','Bearer '+userDetail.Access_Token__c);
            req.setHeader('Content-Type', 'application/octet-stream');
            req.setHeader('Dropbox-API-Arg', dbxApiArg);
            req.setBodyAsBlob(b);
            req.setTimeout(120000);
            HttpResponse res = http.send(req);
            System.debug(res.getStatusCode());
            if(res.getStatusCode() == 200){
                return 'success';
            }
            return 'err';
    }



    //Unknown Error ............................
    /*
    @AuraEnabled
    public static String createFolder(String folderName, String path){
        DropBox_Users__c userDetail = [SELECT Access_Token__c FROM DropBox_Users__c WHERE User_ID__c =:userInfo.getUserId()];

  
        String endPoint = 'https://api.dropboxapi.com/2/files/create_folder_v2';
        String body = '{"path":"'+ path+ '/' + folderName+ '", "autorename":true}';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer '+userDetail.Access_Token__c);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(body);
        res = http.send(req);
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            System.debug('send pass');
            return 'pass';
        }else{
            System.debug('fali');

            return 'fail';
        }
    }
*/
    @AuraEnabled
    public static String tryCreate(String folderName, String path){
        DropBox_Users__c userDetail = [SELECT Access_Token__c FROM DropBox_Users__c WHERE User_ID__c =:userInfo.getUserId()];

  
        String endPoint = 'https://api.dropboxapi.com/2/files/create_folder_v2';
        String body = '{"path":"'+ path+ '/' + folderName+ '", "autorename":true}';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer '+userDetail.Access_Token__c);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(body);
        res = http.send(req);
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            System.debug('send pass');
            return 'pass';
        }else{
            System.debug('fali');
            return 'fail';
        }
    }






    /*@AuraEnabled
    public static void previewFile(String path){
        DropBox_Users__c userDetail = [SELECT Access_Token__c FROM DropBox_Users__c WHERE User_ID__c =:userInfo.getUserId()];
        String methodName = 'POST';
        String endPoint = 'https://content.dropboxapi.com/2/files/get_preview';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Authorization', 'Bearer '+userDetail.Access_Token__c);
        String pth = '{'+'\''+'path'+'\':'+'\''+path+'\''+'}';
        headerMap.put('Dropbox-API-Arg', pth);

        HttpResponse res = GoogleDriveServiceClass.getRresponse(methodName, endPoint, headerMap);  
        System.debug(res.getStatusCode());
        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(res.getBody());
        for(String st : responseMap.keySet()){
            System.debug(st+'   ->    '+responseMap.get(st));
        }
    }*/
}