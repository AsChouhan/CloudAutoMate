@Istest
public class MockClassOfGoogleDrive implements HttpCalloutMock {

   public HttpResponse respond(HttpRequest req){
       HttpResponse res = new HttpResponse();
       String id = 'root';
       res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
       System.debug('condition>>>>>>>>>>>'+req.getEndpoint());
       if(req.getEndpoint()=='https://accounts.google.com/o/oauth2/token' ){
           System.debug('condition>>>>>>Called token');
           res.setBody('{"access_token": "xyzzy","token_type": "bearer","scope": "https://www.googleapis.com/auth/drive","refresh_token": "0eTsQ"}');
       }
       else if(req.getEndpoint()=='https://www.googleapis.com/drive/v3/files?q=\''+id+'\'+in+parents&trashed=false&fields=*'){
           //records
           System.debug('condition>>>>>>Called root');
            res.setBody('Success');
        }
        else if(req.getEndpoint()=='https://www.googleapis.com/drive/v3/files/?q=\''+id+'\'+in+parents&fields=*'){
            //filefolder
            
            System.debug('condition>>>>>>Called folder');
            res.setBody('FolderRecords');
        }
        else if(req.getEndpoint()=='https://www.googleapis.com/drive/v2/files/'){
            //create folder
            res.setBody('Folder Created');
        }
        else if(req.getEndpoint()=='https://www.googleapis.com/drive/v3/files/1hQlHXWEepj4XfqHCstkwRx_M3gZDvlpZ'){
            res.setBody('delete');
        }
        else if(req.getEndpoint()=='https://www.googleapis.com/upload/drive/v2/files/?uploadType=multipart'){
            System.debug('Upload called for test');
            res.setBody('File Uploaded successfully');
        }
        res.setStatusCode(200);
        return res;
    }

}