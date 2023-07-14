public class BoxApexController {
    public static BoxUserInfo__mdt userMDT = [select Cient_Id__c, Client_secret__c, Redirect_Url__c from BoxUserInfo__mdt where label='BoxCredential'];
    static String key = userMDT.Cient_Id__c;
    static String secert = userMDT.Client_secret__c;
    static string redirect_uri = userMDT.Redirect_Url__c;
    
    // Method for checking user is present in database or not.
    @AuraEnabled(cacheable=true)
    public static String checkUserInDatabase(){ 
        System.debug('checking user');
        List<Box_User__c> userDetail = [SELECT Access_Token__c FROM Box_User__c WHERE User_ID__c =:userInfo.getUserId()];
        if(userDetail.size() > 0){
            System.debug(userDetail[0].Access_Token__c);
            return 'FOUND';
        }else{
            return 'NOT FOUND';
        }
    }
    
    @AuraEnabled
    public static string checkForAccessToken(){
        String userId = userInfo.getUserId();
        Box_User__c userDetail = [SELECT Expire_In__c FROM Box_User__c WHERE User_ID__c =:userId];
        Datetime dTime = Datetime.now();
        if(userDetail.Expire_In__c < dTime){
            // Get new access token
            return 'EXPIRED';
        }
        else{
            // Get files
            return 'NOT EXPIRED';
        }
    }
    
    @AuraEnabled
    public static string createAuthUrl(){
        try {
            System.debug(key+'\n'+secert+'\n'+redirect_uri);
            System.debug(userMDT);
            String authUrl = 'https://account.box.com/api/oauth2/authorize?';
            authUrl+='response_type=code&';
            authUrl+='client_id='+key;
            authUrl+='&redirect_uri='+redirect_uri;
            return authUrl;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getAccessToken(String authC){
        String methodName = 'POST';
        String endPoint = 'https://www.box.com/api/oauth2/token?';
        String body = 'grant_type=authorization_code'+
            '&code='+ authC +
            '&client_id='+ key +
            '&client_secret='+ secert;
        Integer timeOut = 60000;
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('content-type','application/x-www-form-urlencoded');
        
        String resp;
        HttpResponse res = GoogleDriveServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);
        resp = res.getBody();
        System.debug(res.getStatusCode());
        Map<String, object> responseMap = (Map<String, object>)JSON.deserializeUntyped(resp);
        String accessToken = String.valueOf(responseMap.get('access_token'));
        String refreshToken = String.valueOf(responseMap.get('refresh_token'));
        
        SYstem.debug(accessToken);
        
        Datetime dTime = Datetime.now();
        Long tokenDate = dTime.getTime();
        tokenDate = tokenDate+(Integer)responseMap.get('expires_in')*1000;
        dTime = Datetime.newInstance(tokenDate);
        
        List<Box_User__c> userDetail = [select name, Access_Token__c, Refresh_Token__c, User_ID__c, Expire_In__c from Box_User__c where User_ID__c=: userInfo.getUserId()];
        
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            if(userDetail.size() == 1){
                userDetail[0].Access_Token__c = accessToken;
                userDetail[0].Refresh_Token__c = String.valueOf(responseMap.get('refresh_token'));
                userDetail[0].Expire_In__c = dTime;
                update userDetail;
                return 'pass';
            }else if(userDetail.size()>1){
                return 'Duplicate Records Found';
            }else{
                Box_User__c newUser = new Box_User__c(name= userInfo.getName(), Access_Token__c= accessToken, Refresh_Token__c= refreshToken, User_ID__c= userInfo.getUserId(), Expire_In__c= dTime);
                insert newUser;
                return 'pass';
            }            
        }else{
            return 'fail';
        }
    }
    
    @AuraEnabled
    public static Integer getNewAccessToken(){
        Box_User__c userDetail = [select Access_Token__c, Refresh_Token__c, Expire_In__c from Box_User__c where User_ID__c=:userInfo.getUserId()];
        
        String endPoint = 'https://api.box.com/oauth2/token';
        String methodName = 'POST';       
        
        String body = 'client_id='+ key +
            '&client_secret='+ secert+
            '&refresh_token='+ userDetail.Refresh_Token__c + 
            '&grant_type=refresh_token';
        
        
        System.debug(body);
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/x-www-form-urlencoded');
        Integer timeOut = 60000;
        
        System.debug('clientId->  '+key+'\n'+'client_secret - > '+ secert +'\n'+'refresh token ->  '+userDetail.Refresh_Token__c);
        
        HttpResponse res = GoogleDriveServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);
        Map<String, object> responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody()); 
        System.debug(res.getStatusCode());
        
        
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){        
            Datetime dtime = Datetime.now();
            Long tokenDate = dtime.getTime();
            tokenDate = tokenDate+((Integer)responseMap.get('expires_in')*1000);
            dtime = Datetime.newInstance(tokenDate);
            
            System.debug(responseMap.get('expires_in'));
            userDetail.Expire_In__c = dtime;
            userDetail.Access_Token__c = (String)responseMap.get('access_token');
            userDetail.Refresh_Token__c = (String)responseMap.get('refresh_token');
            
            update userDetail;
        }
        return res.getStatusCode();
    }
    
    @AuraEnabled
    public static Map<Integer, List<object>> getFiles(String folderId){
        Map<Integer, List<object>> returningMap = new Map<Integer, List<object>>();
        List<object> files = new List<object>();
        Box_User__c userDetail = [select Access_Token__c, Refresh_Token__c from Box_User__c where User_ID__c=:userInfo.getUserId()];
        System.debug(userDetail.Access_Token__c);
        String methodName = 'GET';
        String endPoint = 'https://api.box.com/2.0/folders/'+folderId+'/items';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Authorization', 'Bearer '+userDetail.Access_Token__c);
        HttpResponse res = GoogleDriveServiceClass.getRresponse(methodName, endPoint, headerMap);  
        System.debug(res.getStatusCode());  
        System.debug(res.getBody());
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 200){
            Map<String, object> responseMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody()); 
            System.debug(responseMap.get('entries'));
            files = (List<object>)responseMap.get('entries');
            returningMap.put(200, files);
            return returningMap;
        }else if(res.getStatusCode() == 401){
            returningMap.put(401, files);
            return returningMap;
        }else{
            returningMap.put(res.getStatusCode(), files);
            return returningMap;
        }
    }
    
    @AuraEnabled
    public static Integer DeleteData(String fileId, String fileType){
        System.debug(fileid+'\n'+fileType);
        Box_User__c userDetail = [select Access_Token__c, Refresh_Token__c from Box_User__c where User_ID__c=:userInfo.getUserId()];
        String endPoint;
        if(fileType == 'file'){
            endPoint = 'https://api.box.com/2.0/files/'+fileId;
        }else{
            endpoint = 'https://api.box.com/2.0/folders/'+fileId;
        }
        String methodName = 'DELETE';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Authorization', 'Bearer '+userDetail.Access_Token__c);
        HttpResponse res = GoogleDriveServiceClass.getRresponse(methodName, endPoint, headerMap);
        System.debug(res.getStatusCode());
        if(res.getStatusCode() == 204){
            return 204;
        }
        return 000;
        
    }
    
    @AuraEnabled
    public static Map<Integer, String> downloadFiles(String fileId){
        Map<Integer, String> returnItem = new Map<Integer, String>();
        Box_User__c userDetail = [select Access_Token__c, Refresh_Token__c from Box_User__c where User_ID__c=:userInfo.getUserId()];
        System.debug(fileId);
        String accessToken = userDetail.Access_Token__c;
        String endpoint = 'https://api.box.com/2.0/files/' + fileId + '/content';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getStatusCode()+'\n'+res.getHeader('Location'));
        if (res.getStatusCode() == 302) {
            String downloadUrl = res.getHeader('location');
            returnItem.put(302,downloadUrl);
            
            return returnItem;
        } else {
            returnItem.put(res.getStatusCode(),'blank');
            return returnItem; 
        }
    }
    
    @AuraEnabled
    public static Integer createFolder(String folderName, String parentId){
        Box_User__c userDetail = [select Access_Token__c, Refresh_Token__c from Box_User__c where User_ID__c=:userInfo.getUserId()];
        System.debug(folderName+'   '+parentId);
        String methodName = 'POST';
        String endPoint = 'https://api.box.com/2.0/folders';
        String body = '{"name":'+'"'+folderName+'",'+ '"parent":{"id":'+parentId+'}}';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Authorization', 'Bearer '+userDetail.Access_Token__c);
        headerMap.put('Content-Type', 'application/json');
        Integer timeOut =  60000;
        HttpResponse res = GoogleDriveServiceClass.getRresponse(methodName, endPoint, headerMap, body, timeOut);
        System.debug(res.getStatusCode());
        return res.getStatusCode();
    }
    
    
    
    
    
    @AuraEnabled
    public static Integer uploadFileToBox(String base64, String filename, String folderId){
        if(base64!=null){
            
            Box_User__c userDetail = [select Access_Token__c, Refresh_Token__c from Box_User__c where User_ID__c=:userInfo.getUserId()];
            
            
            //blob base64EncodeFile = EncodingUtil.base64Decode(base64);
            blob base64EncodeFile = base64EncodeFileContent(EncodingUtil.base64Decode(base64), filename);
            String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+folderId;
            System.debug(uploadEndPointURL);
            String boundary = '----------------------------741e90d31eff';
            String body = '{"name":"' + filename + '", "parent":{"id":"' + folderId + '"}}';
            HttpRequest req = new HttpRequest();
            req.setBody(body);
            req.setBodyAsBlob(base64EncodeFile);
            req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
            //req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
            req.setHeader('Authorization', 'Bearer ' + userDetail.Access_Token__c);
            req.setMethod('POST');
            req.setEndpoint(uploadEndPointURL);
            req.setTimeout(120000);
            //Send request to Box
            Http ht = new Http();
            HTTPResponse res = ht.send(req);
            
            System.debug('**Files upload Response: ' + res.getBody());
            Integer uploadStatusCode=res.getStatusCode();
            System.debug(uploadStatusCode);
            if(uploadStatusCode==201){
                return 201;
            }else{
                return res.getStatusCode();             
            }
        }else{
            return 999;
        }
    }
    
    
    
    public static blob base64EncodeFileContent(Blob file_body, String file_name){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        
        return bodyBlob;
    }
    
    @AuraEnabled
    public static String deleteUserRecord(){
        Box_User__c userDetail = [select Access_Token__c, Refresh_Token__c from Box_User__c where User_ID__c=:userInfo.getUserId()];
        delete userDetail;
        return 'success';
    }
}