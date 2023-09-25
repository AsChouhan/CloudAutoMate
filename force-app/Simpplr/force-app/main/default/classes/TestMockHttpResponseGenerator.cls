@isTest
public class TestMockHttpResponseGenerator implements HttpCalloutMock{
  
  public String resStatus{get;set;}
  public String restType{get;set;}
  public Integer resStatusCode{get;set;}
  public String resbody{get;set;}
  public Boolean isNegativeTest{get;set;}
  public String contentId{get;set;}

     string xlmBody = '<?xml version="1.0" encoding="utf-8"?>' +
'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
  'xmlns="urn:partner.soap.sforce.com"' +
  'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
  '<soapenv:Body>' +
     '<loginResponse>' +
        '<result>' +
           '<passwordExpired>false</passwordExpired>' +
           '<id>testId</id>' +
           '<name>testName</name>' +
           '<icon>testIcon</icon>' +
        '</result>' +
     '</loginResponse>' +
  '</soapenv:Body>' +
'</soapenv:Envelope>';
  public TestMockHttpResponseGenerator(String pResStatus,Integer pResStatusCode,String pRestType,Boolean pIsNegativeTest)
  {
    this.resStatus=pResStatus;
    this.resStatusCode=pResStatusCode;
    this.restType=pRestType;
    this.isNegativeTest=pIsNegativeTest;
  }
  public TestMockHttpResponseGenerator(String pResStatus,Integer pResStatusCode,String pRestType,Boolean pIsNegativeTest, String contentId)
  {
  	this.contentId = contentId;
    this.resStatus=pResStatus;
    this.resStatusCode=pResStatusCode;
    this.restType=pRestType;
    this.isNegativeTest=pIsNegativeTest;
  }
  public TestMockHttpResponseGenerator(String pResStatus,Integer pResStatusCode,String pRestType,String pResBody,Boolean pIsNegativeTest)
  {
    this.resStatus=pResStatus;
    this.resStatusCode=pResStatusCode;
    this.restType=pRestType;
    this.resbody=pResBody;
    this.isNegativeTest=pIsNegativeTest;
  }
  public HTTPResponse getResponse()
  {
    HTTPResponse hr=new HTTPResponse();
    hr.setBody(resbody);    
    hr.setStatus(resStatus);
    hr.setStatusCode(resStatusCode);
    if(isNegativeTest!=null && isNegativeTest )
    {
      hr.setStatusCode(400);
      hr.setStatus('Bad Request');
    }
    return hr; 
  }
  
  public HTTPResponse respond(HTTPRequest req) {

    String endpoint = req.getEndpoint();
    // Create a fake response            
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('headerData', '{"size":10}');
    res.setStatus(resStatus);
    res.setStatusCode(resStatusCode);
    
    if(endpoint.equalsIgnoreCase('https://services.simpplr.com/upload/s3/app_asset_upload.php')) {
      res.setBody( '{"status":"success","imageURL":"https://simpplr.com"}' );

    } if( restType.contains('rename')){
      res.setBody( '{"status":"success","message":"Rename successfull","result":"asdfghjkl123"}' );
    } else if(restType.contains('youtu')){
    res.setBody('[{"id":"lELkGEH-Sbk","snippet":{"thumbnails":{"default":{"url":"https://i1.ytimg.com/vi/lELkGEH-Sbk/default.jpg","width":120,"height":90},"medium":{"url":"https://i1.ytimg.com/vi/lELkGEH-Sbk/mqdefault.jpg","width":320,"height":180},"high":{"url":"https://i1.ytimg.com/vi/lELkGEH-Sbk/hqdefault.jpg","width":480,"height":360},"standard":{"url":"https://i1.ytimg.com/vi/lELkGEH-Sbk/sddefault.jpg","width":640,"height":480},"maxres":{"url":"https://i1.ytimg.com/vi/lELkGEH-Sbk/maxresdefault.jpg","width":1280,"height":720}}},"contentDetails":{"duration":"PT1H20M4S"}}]}');
    }  else if(restType.contains('vimeo')){
      res.setBody('[{"id":98724836,"title":"Times the Charm, John Lobb","description":"beautiful short film","url":"https://vimeo.com/98724836","upload_date":"2014-06-20 07:39:44","thumbnail_small":"https://i.vimeocdn.com/video/479541410_100x75.jpg","thumbnail_medium":"https://i.vimeocdn.com/video/479541410_200x150.jpg","thumbnail_large":"https://i.vimeocdn.com/video/479541410_640.jpg","user_id":469544,"user_name":"Carlos De Faria","user_url":"https://vimeo.com/user469544","user_portrait_small":"https://i.vimeocdn.com/portrait/6731424_30x30.jpg","user_portrait_medium":"https://i.vimeocdn.com/portrait/6731424_75x75.jpg","user_portrait_large":"https://i.vimeocdn.com/portrait/6731424_100x100.jpg","user_portrait_huge":"https://i.vimeocdn.com/portrait/6731424_300x300.jpg","stats_number_of_likes":58,"stats_number_of_plays":331,"stats_number_of_comments":8,"duration":83,"width":640,"height":360,"tags":"John Lobb","embed_privacy":"anywhere"}]');
    } else if(restType.contains('UserEndorsement/topicOptOuts')){
    	res.setBody('');
    } else if(restType.contains('BoxFolderFile/FolderContents')) {
      res.setBody('{"total_count":1,"offset":1,"entries":[{"permissions":{"can_invite_collaborator":true,"can_set_share_access":true,"can_upload":true,"can_download":true,"can_preview":true,"can_delete":true,"can_rename":true},"type":"folder","id":"5000948880","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","modified_at":"2012-12-12T11:15:04-08:00","path_collection":{"total_count":1,"entries":[{"type":"folder","id":"1","sequence_id":null,"etag":null,"name":"All Files","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"}}]}},{"permissions":{"can_invite_collaborator":true,"can_set_share_access":true,"can_upload":true,"can_download":true,"can_preview":true,"can_delete":true,"can_rename":true},"type":"file","id":"5000948880","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","modified_at":"2012-12-12T11:15:04-08:00","path_collection":{"total_count":1,"entries":[{"type":"folder","id":"1","sequence_id":null,"etag":null,"name":"All Files","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"}}]}},{"type":"folder","id":"5000948880","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","modified_at":"2012-12-12T11:15:04-08:00","permissions":{"can_upload":true,"can_download":true,"can_preview":true,"can_delete":true,"can_rename":true},"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"1","sequence_id":null,"etag":null,"name":"All Files","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"}}]}}],"type":"folder","id":"11446498","expiring_embed_link":{"url":"google.com"},"permissions":{"can_upload":true,"can_download":true,"can_preview":true,"can_delete":true,"can_rename":true},"sequence_id":"1","etag":"1","name":"Pictures","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"1","sequence_id":null,"etag":null,"name":"All Files","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"}}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/vspke7y05sb214wjokpk","download_url":null,"vanity_url":null,"preview_count":0,"access":"open","permissions":{"can_upload":true,"can_download":true,"can_preview":true}},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},"item_status":"active","item_collection":{"total_count":1,"entries":[{"type":"folder","id":"5000948880","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","modified_at":"2012-12-12T11:15:04-08:00","permissions":{"can_upload":true,"can_download":true,"can_preview":true,"can_delete":true,"can_rename":true},"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"1","sequence_id":null,"etag":null,"name":"All Files","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"}}]}},{"type":"folder","id":"5000948880","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","modified_at":"2012-12-12T11:15:04-08:00","permissions":{"can_upload":true,"can_download":true,"can_preview":true,"can_delete":true,"can_rename":true},"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"1","sequence_id":null,"etag":null,"name":"All Files","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"}}]}}],"offset":0,"limit":100}}');
    } else if(restType.contains('/FileVersion')) {
      res.setBody('{"total_count": 1,"entries": [{"type": "file","id": "172245607","sequence_id": "1","etag": "1","sha1": "f89d97c5eea0a68e2cec911s932eca34a52355d2","name": "Box for Sales - Empowering Your Mobile Worker White paper 2pg (External).pdf","description": "This is old and needs to be updated - but general themes still apply", "size": 408979,"path_collection": {"total_count": 2,"entries": [{"type": "folder","id": "0","sequence_id": null, "etag": null,"name": "All Files"},{"type": "folder","id": "2150506","sequence_id": "1","etag": "1","name": "Marketing Active Work"}]},"created_at": "2014-05-17T12:59:45-07:00","modified_at": "2014-05-17T13:00:20-07:00","created_by": {"type": "user","id": "19551097","name": "Ted Blosser", "login": "ted@box.com"},"modified_by": { "type": "user","id": "19551097","name": "Ted Blosser","login": "ted@box.com"},"owned_by": {"type": "user","id": "19551097","name": "Ted Blosser","login": "ted@box.com"},            "shared_link": null,"parent": {"type": "folder","id": "2150506","sequence_id": "1","etag": "1","name": "Marketing Active Work"  },"item_status": "active"}], "limit": 30,"offset": 0}');
    }else if(restType.contains('googledrive/FileVersion')) {
      res.setBody('{"status":"success","message":"","result":{"revisions":[{"id":"0B9203iUOLMYwMFN1UHRjWjE3L1ArcjRrRGgxcVhTajcremVZPQ","mimeType":"application/pdf","modifiedTime":"2021-04-07T08:07:40.520Z","lastModifyingUser":{"displayName":"Craig Gordon","emailAddress":"craig.gordon@simpplr.dev"}}]}}');
    } else if(restType.contains('Box/UserDetails')) {
      res.setBody('{"id": "17738362","enterprise": {"type": "enterprise","id": "17077211","name": "seanrose enterprise"},"type": "group", "login": "sean@box.com","access_token": "T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl","refresh_token": "J7rxTiWOHMoSC1isKZKBZWizoRXjkQzig5C6jFgCVJ9bUnsUfGMinKBDLZWP9BgR","entries":[{"type":"group_membership","id":"1560354","user":{"type":"user","id":"13130906","name":"Alice","login":"alice@gmail.com"},"group":{"type":"group","id":"119720","name":"family"},"role":"member"}]}');
    } else if(restType.contains('Box/FileDetails')) {
      res.setBody('{"type":"file","id":"5000948880","permissions": {"can_download": true,"can_preview": true},"file_version":{"type":"file_version","id":"26261748416","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","description":"a picture of tigers","size":629644,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"1","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"}]},"created_at":"2012-12-12T10:55:30-08:00","modified_at":"2012-12-12T11:04:26-08:00","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/rh935iit6ewrmw0unyul","download_url":"https://www.box.com/shared/static/rh935iit6ewrmw0unyul.jpeg","vanity_url":null,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"parent":{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"},"item_status":"active"}');
    } else if(restType.contains('googledrive/FileDetails')) {
      res.setBody('{"message": "File fetched successfully.", "result": {"starred": true, "webViewLink": "https://docs.google.com/spreadsheets/d/1PeA4vGoDMRehsytBlbzoIZrTy7NqCz6gDfYKKWdnNUI/edit?usp=drivesdk", "thumbnailLink": "https://docs.google.com/feeds/vt?gd=true&id=1PeA4vGoDMRehsytBlbzoIZrTy7NqCz6gDfYKKWdnNUI&v=5&s=AMedNnoAAAAAYVsDdrZ74Os29B-nKmaeN23jrJl8z9lh&sz=s220", "modifiedTime": "2020-12-12T11:08:46.471Z", "name": "Denali", "parents": ["1diZvlQQljTRlS7BT8B5PHMJvbmosHWmS"], "capabilities": {"canRemoveChildren": false, "canTrash": true, "canEdit": true, "canAddChildren": false, "canModifyContent": true, "canDelete": true, "canMoveItemWithinDrive": true, "canComment": true, "canRemoveMyDriveParent": true, "canCopy": true, "canMoveChildrenWithinDrive": false, "canShare": true, "canReadRevisions": true, "canMoveItemOutOfDrive": true, "canRename": true, "canAddMyDriveParent": false, "canMoveItemIntoTeamDrive": true, "canChangeViewersCanCopyContent": true, "canListChildren": false, "canUntrash": true, "canChangeSecurityUpdateEnabled": false, "canDownload": true, "canChangeCopyRequiresWriterPermission": true}, "version": "200", "id": "1PeA4vGoDMRehsytBlbzoIZrTy7NqCz6gDfYKKWdnNUI", "owners": [{"emailAddress": "craig.gordon@simpplr.dev", "displayName": "Craig Gordon"}], "permissions": [{"id": "07281194056642918863", "displayName": "Site owner Administrators", "kind": "drive#permission", "role": "writer", "deleted": false, "emailAddress": "0F95Y000000NtEnSAK.rw_sfsm@simpplr.dev", "type": "group"}], "mimeType": "application/vnd.google-apps.spreadsheet"}, "status": "success"}');
    } else if(restType.contains('Dropbox/FileDetails')) {
      res.setBody('{"type":"file","id":"5000948880","permissions": {"can_download": true,"can_preview": true},"file_version":{"type":"file_version","id":"26261748416","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","description":"a picture of tigers","size":629644,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"}]},"created_at":"2012-12-12T10:55:30-08:00","modified_at":"2012-12-12T11:04:26-08:00","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/rh935iit6ewrmw0unyul","download_url":"https://www.box.com/shared/static/rh935iit6ewrmw0unyul.jpeg","vanity_url":null,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"parent":{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"},"item_status":"active"}');
    } else if(restType.contains('sharepoint/FileDetails')) {
      res.setBody('{"type":"file","id":"5000948880","permissions": {"can_download": true,"can_preview": true},"file_version":{"type":"file_version","id":"26261748416","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","description":"a picture of tigers","size":629644,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"}]},"created_at":"2012-12-12T10:55:30-08:00","modified_at":"2012-12-12T11:04:26-08:00","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/rh935iit6ewrmw0unyul","download_url":"https://www.box.com/shared/static/rh935iit6ewrmw0unyul.jpeg","vanity_url":null,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"parent":{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"},"item_status":"active"}');
    } else if(restType.contains('/sharepointFolders')) {
      res.setBody('{"listOfFiles":[{"driveId":"sharepointtestid","webUrl":"https://simpplr.sharepoint.com/sites/RohitSite2/Shared%20Documents"},{"driveId":"b!MT0qs7Zf9UOslURFdgaGhEsSxQ654dZLvAgiIDihiUFM4PXqx03bQql3qycF_ZMb","webUrl":"https://simpplr.sharepoint.com/sites/RohitSite2/Shared%20Documents"}],"size":2}');
    } else if(restType.contains('search/sharepoint')) {
      res.setBody('{"result":[{"lastModifiedBy":{"user":{"displayName":"Ashish Narang","email":"ashish@simpplr.onmicrosoft.com"}},"createdBy":{"user":{"displayName":"Ashish Narang","email":"ashish@simpplr.onmicrosoft.com"}},"id":"0145WK2VY6EB3IQIWDPFDZCDHKYQYXGHRL","size":186902,"name":"LOGO.png","webDavUrl":"https://simpplr.sharepoint.com/BU/UK-IT/Shared Documents/Forms/DispForm.aspx?ID=14","webUrl":"https://simpplr.sharepoint.com/BU/UK-IT/Shared Documents/Forms/DispForm.aspx?ID=14","mimeType":"aspx?ID=14","lastModifiedDateTime":"2021-05-17T03:59:05Z","parentReference":{"driveId":"b!9TFEj45IiESFPQGou8YgOBahVg6nnJZFqYltM903shLxqlmGJFWOTKWrPGe69SMI"},"version":["0145WK2VY6EB3IQIWDPFDZCDHKYQYXGHRL"],"file":{"mimeType":"aspx?ID=14"}},{"lastModifiedBy":{"user":{"displayName":"Ashish Narang","email":"ashish@simpplr.onmicrosoft.com"}},"createdBy":{"user":{"displayName":"Ashish Narang","email":"ashish@simpplr.onmicrosoft.com"}},"id":"0145WK2V3OVAJPQT5CWND2AQQSSLMLEDZ2","size":80510,"name":"GLG_LOGO_MASTER_NAVY.png","webDavUrl":"https://simpplr.sharepoint.com/BU/UK-IT/Shared Documents/Forms/DispForm.aspx?ID=15","webUrl":"https://simpplr.sharepoint.com/BU/UK-IT/Shared Documents/Forms/DispForm.aspx?ID=15","mimeType":"aspx?ID=15","lastModifiedDateTime":"2021-05-17T03:59:17Z","parentReference":{"driveId":"b!9TFEj45IiESFPQGou8YgOBahVg6nnJZFqYltM903shLxqlmGJFWOTKWrPGe69SMI"},"version":["0145WK2V3OVAJPQT5CWND2AQQSSLMLEDZ2"],"file":{"mimeType":"aspx?ID=15"}},{"lastModifiedBy":{"user":{"displayName":"Manu Bhardwaj","email":"manu@simpplr.onmicrosoft.com"}},"createdBy":{"user":{"displayName":"Manu Bhardwaj","email":"manu@simpplr.onmicrosoft.com"}},"id":"0145WK2V3JDCS7DAMDDBH2FVJQ4LQMZVSF","size":11067637,"name":"platform-tools_r28.0.2-windows.zip","webDavUrl":"https://simpplr.sharepoint.com/BU/UK-IT/Shared Documents/platform-tools_r28.0.2-windows.zip","webUrl":"https://simpplr.sharepoint.com/BU/UK-IT/Shared Documents/platform-tools_r28.0.2-windows.zip","mimeType":"zip","lastModifiedDateTime":"2019-05-27T06:24:18Z","parentReference":{"driveId":"b!9TFEj45IiESFPQGou8YgOBahVg6nnJZFqYltM903shLxqlmGJFWOTKWrPGe69SMI"},"version":["0145WK2V3JDCS7DAMDDBH2FVJQ4LQMZVSF"],"file":{"mimeType":"zip"}}],"nextPageToken":null,"totalItem":3}');
    } else if(restType.contains('onedrive/FileDetails')) {
      res.setBody('{"type":"file","id":"5000948880","permissions": {"can_download": true,"can_preview": true},"file_version":{"type":"file_version","id":"26261748416","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","description":"a picture of tigers","size":629644,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"}]},"created_at":"2012-12-12T10:55:30-08:00","modified_at":"2012-12-12T11:04:26-08:00","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/rh935iit6ewrmw0unyul","download_url":"https://www.box.com/shared/static/rh935iit6ewrmw0unyul.jpeg","vanity_url":null,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"parent":{"type":"folder","id":"11446498","sequence_id":"1","etag":"1","name":"Pictures"},"item_status":"active"}');
    } else if(restType.contains('/FolderContent')) {
      res.setBody('{"total_count": 24,"entries": [{"type": "folder","id": "192429928","sequence_id": "1","etag": "1","name": "Stephen Curry Three Pointers" },{"type": "file","id": "818853862","sequence_id": "0","etag": "0","name": "Warriors.jpg"}],"offset": 0,"limit": 2,"order": [{"by": "type","direction": "ASC"},{"by": "name","direction": "ASC"}]}');
    } else if(restType.contains('/Workday'))  {
      res.setBody('{"Report_Entry":[{"EmployeeID":"100","FirstName":"sup","LastName":"manager","HireDate":"2011-06-06","businessTitle":"Colo Contractor","ManagerID":"","Manager":"","Department":"Eng Lab","CostCenterName":"Engineering Operations","CostCenterID":"43777","Location":"650 Castro","WorkAddressFormattedLine1":"650 Castro Street","WorkAddressFormattedLine2":"Suite 400","WorkAddressFormattedLine3":"Mountain View, CA 94041","WorkAddressCity":"Mountain View","WorkAddressStateProvince":"California","WorkAddressPostalCode":"94041","WorkAddressCountry":"United States of America","primaryWorkEmail":"supermanager@test.simpplr.com","CurrentMomentDateTime":"2015-08-12T19:56:54.871-07:00"},{"EmployeeID":"1000","FirstName":"test","LastName":"manager","HireDate":"2012-07-07","businessTitle":"Recruiter","ManagerID":"100","Manager":"Sup User","Department":"Recruiting (Sup User)","CostCenterName":"General Recruiting","CostCenterID":"15999","Location":"650 Castro","WorkAddressFormattedLine1":"650 Castro Street","WorkAddressFormattedLine2":"Suite 400","WorkAddressFormattedLine3":"Mountain View, CA 94041","WorkAddressCity":"Mountain View","WorkAddressStateProvince":"California","WorkAddressPostalCode":"94041","WorkAddressCountry":"United States of America","primaryWorkEmail":"manager@test.simpplr.com","CurrentMomentDateTime":"2015-08-12T19:56:54.871-07:00"},{"EmployeeID":"1100","FirstName":"test","LastName":"user","HireDate":"2013-08-08","businessTitle":"Technician Contractor","ManagerID":"1000","Manager":"Test Manager","Department":"Iridium (Test Manager)","CostCenterName":"test cost center","CostCenterID":"868686","Location":"444 Castro","WorkAddressFormattedLine1":"444 Castro Street","WorkAddressFormattedLine2":"Suite 1100","WorkAddressFormattedLine3":"Mountain View, CA 94041","WorkAddressCity":"Mountain View","WorkAddressStateProvince":"California","WorkAddressPostalCode":"94041","WorkAddressCountry":"United States of America","primaryWorkEmail":"user@test.simpplr.com","CurrentMomentDateTime":"2015-08-12T19:56:54.871-07:00"}]}');
    } else if(restType.contains('/PushAnalytics')) {
    	res.setBody('{"status" : "success"}'); 	
    } else if(restType.contains('/NewsletterTracking')) {
    	res.setBody('{"status" : "success", "lastdataid":"1","hasmoredata":false,"data":[]}');
    } else if(restType.contains('GoogleDriveAdminInfoSave')){
    	res.setBody('{"status" : "success", "code":"4BJmdgd4rhhGWprJR_PpXADaF5roZHzui72MY8zjCLQc", "scope":"https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/admin.directory.group https://www.googleapis.com/auth/admin.directory.domain.readonly https://www.googleapis.com/auth/drive.appdata", "state":"gdriveadmin"}');
    } else if(restType.contains('GoogleDriveNonAdminInfoSave')){
    	res.setBody('{"status" : "success", "code":"4zYqSaNCPpRkPXjtEAHVTVdLVc27gaoNdka3mvoYOmNA", "scope":"https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/admin.directory.group https://www.googleapis.com/auth/admin.directory.domain.readonly", "state":"gdrive"}');
    } else if(restType.contains('GoogleDriveGetAbout')){
    	res.setBody('{"kind": "drive#about", "user": {"kind": "drive#user","displayName": "Dummy User","isAuthenticatedUser": true,"permissionId": "11551083267734841420","emailAddress": "amit123@bhootnath.in"}, "storageQuota": {"quotaLimit" : "", "usage" : "5120471", "usageInDrive" : "5120471", "usageInDriveTrash" : "0"} }');
    } else if(restType.contains('GoogleDriveFolderCreate')){
    	res.setBody('{"kind":"drive#file", "id":"0B2nKz9lsjFNlYjY4LUVQanNCcms", "name":"DummyFolder", "mimeType":"application/octet-stream", "size":"10"}');
    } else if(restType.contains('GoogleDriveCreateSiteFolder')){
    	res.setBody('{"kind":"drive#file", "id":"0B2nKz9lsjFNlYjY4LUVQanNCcms", "name":"DummyFolder", "mimeType":"application/octet-stream", "size":"10"}');
    } else if(restType.contains('GoogleDriveAddMember')){
    	res.setBody('{"kind":"drive#file", "id":"0B2nKz9lsjFNlYjY4LUVQanNCcms", "name":"DummyFolder", "mimeType":"application/octet-stream", "size":"10"}');
    } else if(restType.contains('GoogleDriveAddAdmin')){
    	res.setBody('{"kind":"drive#file", "id":"0B2nKz9lsjFNlYjY4LUVQanNCcms", "name":"DummyFolder", "mimeType":"application/octet-stream", "size":"10"}');
    } else if(restType.contains('GoogleDriveRemoveMember')){
    	res.setBody('{"kind":"drive#file", "id":"0B2nKz9lsjFNlYjY4LUVQanNCcms", "name":"DummyFolder", "mimeType":"application/octet-stream", "size":"10"}');
    } else if(restType.contains('GoogleDriveRemoveAdmin')){
    	res.setBody('{"kind":"drive#file", "id":"0B2nKz9lsjFNlYjY4LUVQanNCcms", "name":"DummyFolder", "mimeType":"application/octet-stream", "size":"10"}');
    } else if(restType.contains('/NPS')) {
      res.setBody('{"status" : "success"}');
    } else if(restType.contains('/externalSearch')) {
    	res.setBody('{"status" : "success"}');
    } else if(restType.contains('/campagindataserver/facebookshare')) {
    	res.setBody('{"id" : "123"}');
    } else if(restType.contains('/campaigndataserver/twitterRequest')){
    	res.setBody('oauth_token=abcd1234&oauth_token_secret=defg5555&oauth_callback_confirmed=true');	
    } else if(restType.contains('/campaigndataserver/twitterSaveToken')){
    	res.setBody('oauth_token=abcd1111&oauth_token_secret=defg4321&user_id=6253282&screen_name=twitteruser');	
    } else if(restType.contains('/campaigndataserver/twitterShare')){
    	res.setBody('{"id" : "123"}');	
    } else if(restType.contains('/connectexternalapp/processcodefromfacebook')){
    	res.setBody('{"data":["permission":"publish_actions", "status":"declined"]}');	
    } else if(restType.contains('/connectexternalapp/processCodefromlinkedin')){
    	res.setBody('{"id":"id", "firstname":"firstname","lastname":"lastname"}');	
    } else if(restType.contains('/connectexternalapp/processCodefromadsi')){
    	res.setBody('{"id":"id", "displayname":"displayname","mail":"mail"}');	
    } else if(restType.contains('/pushsitefeed/pushSlackNotificationEmail')){ 	
    	res.setBody('{"res" : "pass","ok":false}');	 	
    } else if(restType.contains('/pushsitefeed/pushSlackNotification')){
    	res.setBody('{"res" : "pass"}');
    } else if(restType.contains('/pushsitefeed/pushMicrosoftTeamsNotification')){
    	res.setBody('');	
    } else if(restType.contains('/utility/sendPushNotifications')){
    	res.setBody('');	
    } else if(restType.contains('/manage-slack-info')){
    	res.setBody('true');
    } else if(restType.contains('/get-jwt-token')){
    	res.setBody('{"token_type":"Bearer","jwtToken":"absdhofisdofhsdlkfhsdo"}');
    } else if(restType.contains('/save-slack-enabled')){
    	res.setBody('true');
    } else if(restType.contains('dummy_link_okta')){
    	res.setBody('{}');	
    } else if(restType.contains('/getUsersFromOkta')){
    	res.setBody('[{"id":"testId","status":"PROVISIONED","created":"2015-11-05T05:59:24.000Z","activated":"2015-11-05T05:59:24.000Z","statusChanged":"2015-11-05T05:59:24.000Z","lastUpdated":"2015-11-05T05:59:24.000Z","type":{"id":"testTypeId"},"profile":{"firstName":"Test","lastName":"Test","mobilePhone":null,"secondEmail":"","login":"test@simpplr.com","email":"test@simpplr.com", "city":"city"},"credentials":{"provider":{"type":"OKTA","name":"OKTA"}},"_links":{"self":{"href":"https://simpplr.okta.com/api/v1/users/testId"}}}]');	
    } else if(restType.contains('launchpad/getRespBasicAuth')){
      res.setBody('{}');
    } else if(restType.contains('/slackDataServer/channels.list')){
    	res.setBody('{"ok":true,"channels":[{"id":"C0G9QF9GW","name":"random","is_channel":true,"created":1449709280,"creator":"U0G9QF9C6","is_archived":false,"is_general":false,"name_normalized":"random","is_shared":false,"is_org_shared":false,"is_member":true,"is_private":false,"is_mpim":false,"members":["U0G9QF9C6","U0G9WFXNZ"],"topic":{"value":"Other stuff","creator":"U0G9QF9C6","last_set":1449709352},"purpose":{"value":"A","creator":"","last_set":0},"previous_names":[],"num_members":2},{"id":"C0G9QKBBL","name":"general","is_channel":true,"created":1449709280,"creator":"U0G9QF9C6","is_archived":false,"is_general":true,"name_normalized":"general","is_shared":false,"is_org_shared":false,"is_member":true,"is_private":false,"is_mpim":false,"members":["U0G9QF9C6","U0G9WFXNZ"],"topic":{"value":"Talk about anything!","creator":"U0G9QF9C6","last_set":1449709364},"purpose":{"value":"To talk about anything!","creator":"U0G9QF9C6","last_set":1449709334},"previous_names":[],"num_members":2}],"response_metadata":{"next_cursor":"dGVhbTpDMUg5UkVTR0w="}}');
    } else if(restType.contains('/slackDataServer/groups.list')){
    	res.setBody('{"ok":true,"groups":[{"id":"G024BE91L","name":"secretplans","created":1360782804,"creator":"U024BE7LH","is_archived":false,"members":["U024BE7LH"],"topic":{"value":"Secret plans on hold","creator":"U024BE7LV","last_set":1369677212},"purpose":{"value":"Discuss secret plans that no-one else should know","creator":"U024BE7LH","last_set":1360782804}}]}');
    } else if(restType.contains('/slackDataServer/chat.postMessage')){
    	res.setBody('{"ok":true,"channel":"C1H9RESGL","ts":"1503435956.000247","message":{"text":"Here is a message for you","username":"ecto1","bot_id":"B19LU7CSY","attachments":[{"text":"This is an attachment","id":1,"fallback":"This is an attachment fallback"}],"type":"message","subtype":"bot_message","ts":"1503435956.000247"}}');
    } else if(restType.contains('/slackUnfurl')){
    	res.setBody('{"message":"Successfully deleted integration record"}');
    } else if(restType.contains('/serviceNowDataServer/kb_knowledge_base')){
    	res.setBody('{"access_token":"sadasdahj","isAccessTokenNew":false,"result":[{"parent":"","made_sla":"true","caused_by":"","watch_list":"","upon_reject":"Cancel all future Tasks","sys_updated_on":{"value":"2016-12-13 18:46:44"},"child_incidents":"0","hold_reason":"","approval_history":"","number":{"value":"INC0000060"},"resolved_by":{"display_value":"David Loo","link":""},"sys_updated_by":"employee","opened_by":{"display_value":"Joe Employee","link":""},"user_input":"","sys_created_on":"2016-12-12 07:19:57","sys_domain":{"display_value":"global","link":""},"state":{"value":"Closed"},"sys_created_by":"employee","knowledge":"false","order":"","calendar_stc":"102,197","closed_at":"2016-12-13 18:46:44","cmdb_ci":{"display_value":"","link":""},"delivery_plan":"","impact":"2 - Medium","active":"false","work_notes_list":"","business_service":{"display_value":"Email","link":""},"priority":{"value":"3 - Moderate"},"sys_domain_path":"/","rfc":"","time_worked":"","expected_start":"","opened_at":"2016-12-12 07:19:57","business_duration":"8 Hours","group_list":"","work_end":"","caller_id":{"display_value":"Joe Employee","link":""},"reopened_time":"","resolved_at":"2016-12-13 13:43:14","approval_set":"","subcategory":"Email","work_notes":"","short_description":{"value":"Unable to connect to email"},"close_code":"Solved (Permanently)","correlation_display":"","delivery_task":"","work_start":"","assignment_group":{"display_value":"Network","link":""},"additional_assignee_list":"","business_stc":"28,800","description":"I am unable to connect to the email server. It appears to be down.","calendar_duration":"","close_notes":"","notify":"Do Not Notify","sys_class_name":"Incident","closed_by":{"display_value":"Joe Employee","link":""},"follow_up":"","parent_incident":"","sys_id":{"display_value":"1"},"title":{"display_value":"1"},"contact_type":"Self-service","reopened_by":"","incident_state":"Closed","urgency":"2 - Medium","problem_id":"","company":{"display_value":"ACME North America","link":""},"reassignment_count":"2","activity_due":"2016-12-12 17:26:36","assigned_to":{"display_value":"David Loo","link":""},"severity":"3 - Low","comments":"","approval":"Not Yet Requested","sla_due":"UNKNOWN","comments_and_work_notes":"","due_date":"","sys_mod_count":"15","reopen_count":"0","sys_tags":"","escalation":"Normal","upon_approval":"Proceed to Next Task","correlation_id":"","location":"","category":"Inquiry / Help"}], "status":"success"}');
    } else if(restType.contains('/serviceNowDataServer/kb_knowledge')){
    	res.setBody('{"result":[], "status":"success"}');
    } else if(restType.contains('/serviceNowDataServer/incidentList')){
      res.setBody('{"result":[{"parent":"","made_sla":"true","caused_by":"","watch_list":"","upon_reject":"Cancel all future Tasks","sys_updated_on":{"value":"2016-12-13 18:46:44"},"child_incidents":"0","hold_reason":"","approval_history":"","number":{"value":"INC0000060"},"resolved_by":{"display_value":"David Loo","link":""},"sys_updated_by":"employee","opened_by":{"display_value":"Joe Employee","link":""},"user_input":"","sys_created_on":"2016-12-12 07:19:57","sys_domain":{"display_value":"global","link":""},"state":{"value":"Closed"},"sys_created_by":"employee","knowledge":"false","order":"","calendar_stc":"102,197","closed_at":"2016-12-13 18:46:44","cmdb_ci":{"display_value":"","link":""},"delivery_plan":"","impact":"2 - Medium","active":"false","work_notes_list":"","business_service":{"display_value":"Email","link":""},"priority":{"value":"3 - Moderate"},"sys_domain_path":"/","rfc":"","time_worked":"","expected_start":"","opened_at":"2016-12-12 07:19:57","business_duration":"8 Hours","group_list":"","work_end":"","caller_id":{"display_value":"Joe Employee","link":""},"reopened_time":"","resolved_at":"2016-12-13 13:43:14","approval_set":"","subcategory":"Email","work_notes":"","short_description":{"value":"Unable to connect to email"},"close_code":"Solved (Permanently)","correlation_display":"","delivery_task":"","work_start":"","assignment_group":{"display_value":"Network","link":""},"additional_assignee_list":"","business_stc":"28,800","description":"I am unable to connect to the email server. It appears to be down.","calendar_duration":"","close_notes":"","notify":"Do Not Notify","sys_class_name":"Incident","closed_by":{"display_value":"Joe Employee","link":""},"follow_up":"","parent_incident":"","sys_id":{"value":"1"},"contact_type":"Self-service","reopened_by":"","incident_state":"Closed","urgency":"2 - Medium","problem_id":"","company":{"display_value":"ACME North America","link":""},"reassignment_count":"2","activity_due":"2016-12-12 17:26:36","assigned_to":{"display_value":"David Loo","link":""},"severity":"3 - Low","comments":"","approval":"Not Yet Requested","sla_due":"UNKNOWN","comments_and_work_notes":"","due_date":"","sys_mod_count":"15","reopen_count":"0","sys_tags":"","escalation":"Normal","upon_approval":"Proceed to Next Task","correlation_id":"","location":"","category":"Inquiry / Help"}]}');
    } else if(restType.contains('/serviceNowDataServer/incident/createIncident')){
    	res.setBody('{"result":{"parent":"","made_sla":"true","caused_by":"","watch_list":"","upon_reject":"Cancel all future Tasks","sys_updated_on":"2019-08-29 05:07:17","child_incidents":"0","hold_reason":"","approval_history":"","number":"INC0010084","resolved_by":"","sys_updated_by":"ashish@simpplr.com","opened_by":{"display_value":"Ashish Narang","link":"https://dev77835.service-now.com/api/now/table/sys_user/13fef7321bc63300937d986cbc4bcbb5"},"user_input":"","sys_created_on":"2019-08-29 05:07:17","sys_domain":{"display_value":"global","link":"https://dev77835.service-now.com/api/now/table/sys_user_group/global"},"state":"New","sys_created_by":"ashish@simpplr.com","knowledge":"false","order":"","calendar_stc":"","closed_at":"","cmdb_ci":"","delivery_plan":"","impact":"3 - Low","active":"true","work_notes_list":"","business_service":"","priority":"5 - Planning","sys_domain_path":"/","rfc":"","time_worked":"","expected_start":"","opened_at":"2019-08-29 05:07:17","business_duration":"","group_list":"","work_end":"","caller_id":"","reopened_time":"","resolved_at":"","approval_set":"","subcategory":null,"work_notes":"","short_description":"","close_code":null,"correlation_display":"","delivery_task":"","work_start":"","assignment_group":"","additional_assignee_list":"","business_stc":"","description":"","calendar_duration":"","close_notes":"","notify":"Do Not Notify","sys_class_name":"Incident","closed_by":"","follow_up":"","parent_incident":"","sys_id":"0b89dab51be33300937d986cbc4bcb42","contact_type":null,"reopened_by":"","incident_state":"New","urgency":"3 - Low","problem_id":"","company":"","reassignment_count":"0","activity_due":"UNKNOWN","assigned_to":"","severity":"3 - Low","comments":"","approval":"Not Yet Requested","sla_due":"UNKNOWN","comments_and_work_notes":"","due_date":"","sys_mod_count":"0","reopen_count":"0","sys_tags":"","escalation":"Normal","upon_approval":"Proceed to Next Task","correlation_id":"","location":"","category":"Inquiry / Help"}}');
    } else if(restType.contains('/serviceNowDataServer/sys_choice/category')){
        res.setBody('{"result":[{"label":"test"}],"status":"pass"}');
    } else if(restType.contains('/serviceNowDataServer/sys_choice/subCategory')){
        res.setBody('{"result":[{"label":"test"}],"status":"pass"}');
    } else if (restType.contains('serviceNowDataServer/revokeAccessToken')) {
      	res.setBody('{"result":"success"}');
    } else if(restType.contains('/serviceNowDataServer/refreshToken')){
    	res.setBody('{"access_token":"test","refresh_token":"test","expires_in":36000}');
    } else if (restType.contains('campaign/mobile-app-download/sendsms')) {
      	res.setBody('{"result":"success"}');
    
    } else if (restType.equalsIgnoreCase('/connectExternalApp/getServicenowUser')) {
      	res.setBody('{"result":[],"status":"success"}');
    
    } else if (restType.equalsIgnoreCase('/SettingDataServer/regenerateToken')) {
      	res.setBody('{"result":[],"status":"success"}');
    
    } else if (restType.equalsIgnoreCase('/SettingDataServer/createToken')) {
      	res.setBody('{"result":[],"status":"success"}');
    } else if (restType.equalsIgnoreCase('/SettingDataServer/deleteToken')) {
      	res.setBody('{"result":[],"status":"success"}');
    
    } else if (restType.equalsIgnoreCase('/SettingDataServer/disconnectAtlassianAdmin')) {
      res.setBody('{"result":[],"status":"success"}');
    } else if (restType.equalsIgnoreCase('/SettingDataServer/getUKGUserFieldConfig')) {
      res.setBody('{"result":[],"status":"success"}');
    } else if (restType.equalsIgnoreCase('/AtlassianService/getConfluenceUsers')) {
      res.setBody('{"size":20,"results":[{"user":{"type":"known","accountId":"'+UserInfo.getUserId()+'","accountType":"","email":"rohit.kumar@simpplr.com","publicName":"Rohit Kumar","profilePicture":{"path":"xyz","width":48,"height":48,"isDefault":false},"displayName":"Rohit Kumar","isExternalCollaborator":false,"_links":{"self":"self"}},"title":"Rohit Kumar","excerpt":"desc","url":"url","breadcrumbs":[],"entityType":"user","iconCssClass":"aui-iconfont-user","lastModified":"2021-06-22T09:01:03.426Z","score":0},{"user":{"type":"known","accountId":"5fc60c55aa1d30006f4d9a19","accountType":"","email":"rohit.madhok@simpplr.com","publicName":"Rohit Madhok","profilePicture":{"path":"path","width":48,"height":48,"isDefault":false},"displayName":"Rohit Madhok","isExternalCollaborator":false,"_links":{"self":"self"}},"title":"Rohit Madhok","excerpt":"","url":"url","breadcrumbs":[],"entityType":"user","iconCssClass":"aui-iconfont-user","lastModified":"2021-06-22T09:01:03.426Z","score":0}],"start":0,"limit":250,"size":2,"totalSize":2,"_links":{"base":"base","context":"/wiki"},"status":"success"}}');
    } else if (restType.equalsIgnoreCase('/AtlassianService/searchConfluence')) {
      res.setBody('{"results":[{"content":{"id":"34543","type":"page","status":"current","title":"User story: Notifications","childTypes":{},"macroRenderedOutput":{},"restrictions":{},"_expandable":{"container":"","metadata":"","extensions":"","operations":"","children":"","history":"/rest/api/content/34543/history","ancestors":"","body":"","version":"","descendants":"","space":"/rest/api/space/SWPRJ"},"_links":{"webui":"/spaces/SWPRJ/pages/34543/User+story%3A+Notifications","self":"self","tinyui":"/x/74Y"}},"title":"title","excerpt":"desc","url":"/spaces/SWPRJ/pages/34543/User+story%3A+Notifications","resultGlobalContainer":{"title":"Demo Project Home","displayUrl":"/spaces/SWPRJ"},"breadcrumbs":[],"entityType":"content","iconCssClass":"aui-iconfont-page-default","lastModified":"2017-06-23T17:10:50.000Z","friendlyLastModified":"Jun 23, 2017","score":0}],"start":0,"limit":250,"size":1,"totalSize":1,"searchDuration":154,"_links":{"base":"base","context":"/wiki","self":"self"},"status":"success"}}');
    } else if(restType.contains('/AtlassianService/searchConfluenceFail')){
      res.setBody('confluence.refresh_token.expired'); 
    } else if (restType.equalsIgnoreCase('/AtlassianService/getConfluenceSpaces')) {
      res.setBody('{"size":20,"results":[{"space":{"key":"SimpplrOnAWS","name":"Simpplr On AWS"}}],"_links":{"next":"https://simpplr.atlassian.net/wiki"},"status":"success"}');
    
    } else if(restType.contains('AnalyticsDataServer/getAdoptiondata')){
      res.setBody('{"status":"success","result":{"data":{"usersLoggedInCount":0,"totalUserCount":0,"totalUniqueUserCount":0,"pageViewCount":0,"mobileLogins":0,"mobileAppLogins":0,"loginsOverTime":[],"loggedInPercentage":0,"desktopLogins":0,"contentViewCount":0,"contentPublished":0,"averageLoginsPerUser":0,"averageContentViewsPerUser":0},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getAdoptionData&to=2020-05-03&from=2020-02-03&groupBy=week&filterBy=null&filterValue=null&excludeLoginsOverTime=false&excludeDeviceData=false"}}');
    } else if(restType.contains('AnalyticsDataServer/getPeoplePerformance')){
      res.setBody('{"status":"success","result":{"data":[{"id":"dummy","location":"delhi"}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getPeoplePerformance&includeName=true&to=2020-05-03&from=2020-02-03&metric=profileViews"}}');
    } else if(restType.contains('AnalyticsDataServer/getKnowledgePageStats')){
      res.setBody('{"status":"success","result":{"data":[],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getKnowledgePageCsv&to=2020-05-03&from=2020-02-03"}}');
    } else if(restType.contains('AnalyticsDataServer/getAppPageViews')){
      res.setBody('{"status":"success","result":{"data":[{"name":"Dummy","uniqueViewsPercentage":2.021,"totalViewsPercentage":2.021}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getKnowledgePageCsv&to=2020-05-03&from=2020-02-03"}}');
    } else if(restType.contains('AnalyticsDataServer/getContentReferralSources')){
      res.setBody('{"status":"success","result":{"data":[{"label":"labelforCodeCoverage","siteName":"TestSite","contentTitle ":"TestCoverage","contentItemsCount":2.01,"totalViewsCount ":2.01,"referralsCount ":2.01,"referralsPerItemCount":2.01,"referralsPerItemPercentage ":2.01}]}}');
    } else if(restType.contains('AnalyticsDataServer/getSearchList')){
      res.setBody('{"status":"success","result":{"data":{"searchList":[{"name":"testSites"}],"searchesOverTime":[{"name":"testSites"}]},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getSearchList&to=2020-05-03&from=2020-02-03&orderBy=bottom&type=searches&resultType=segment"}}');
    } else if(restType.contains('AnalyticsDataServer/getSearches')){
      res.setBody('{"status":"success","result":{"data":{"totalCount":0,"searchesOverTime":[]},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getSearches&to=2020-05-03&from=2020-02-03&groupBy=week"}}');
    } else if(restType.contains('AnalyticsDataServer/getPeopleProfileCompleteness')){
      res.setBody('{"status":"success","result":{"totalUserCount":0,"profilePhotoCount":0,"phoneCount":0,"aboutMeCount":0,"birthdateCount":0,"data":{"totalUserCount":0,"profileCompletenessList":[{"value":0,"label":"Profile picture"}]},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getPeopleProfileCompleteness&to=2020-05-03&from=2020-02-03"}}');
    } else if(restType.contains('AnalyticsDataServer/getContentViewsList')){
      res.setBody('{"status":"success","result":{"data":[{"title":"Dummy","publishedDate":"2020-02-03","type":"Page"}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getContentViewsList&to=2020-05-03&from=2020-02-03&orderBy=bottom"}}');
    } else if(restType.contains('AnalyticsDataServer/getContentPopularity')){
      res.setBody('{"status":"success","result":{"data":[{"type":"Page","publishedDate":"2020-02-03"}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getContentPopularity&to=2020-05-03&from=2020-02-03&orderBy=bottom"}}');
    } else if(restType.contains('AnalyticsDataServer/getGovernanceList')){
      res.setBody('{"status":"success","result":{"data":[{"label":"Page","value":1}]}}');
    } else if(restType.contains('AnalyticsDataServer/getSitePopularity')){
      res.setBody('{"status":"success","result":{"data":{"sites":[{"likes":2,"access":"public"}]},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getSitePopularity&to=2020-05-03&from=2020-02-03&orderBy=top"}}');
    } else if(restType.contains('AnalyticsDataServer/getSitePublication')){
      res.setBody('{"status":"success","result":{"data":{"sites":[{"albums":2,"access":"public"}]},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getSitePublication&to=2020-05-03&from=2020-02-03&orderBy=bottom"}}');
    } else if(restType.contains('AnalyticsDataServer/getLowActivitySites')){
      res.setBody('{"status":"success","result":{"listOfSites":[{"name":"testSite","access":"public"}]}}');
    } else if(restType.contains('AnalyticsDataServer/getLoginsList')){
      res.setBody('{"status":"success","result":{"data":[],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getLoginsList&to=2020-05-03&from=2020-02-03&resultType=segment&orderBy=top"}}');
    } else if(restType.contains('AnalyticsDataServer/getPerformanceContent')){
      res.setBody('{"status":"success","result":{"hasLowActivityContent":true,"data":[{"type":"Page","publishedDate":"2020-02-03","siteName":"TestSite"}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getLoginsList&to=2020-05-03&from=2020-02-03&resultType=segment&orderBy=top"}}');
    } else if(restType.contains('AnalyticsDataServer/getAdoptionAverage')){
      res.setBody('{"status":"success","result":{"data":[{"name":"test","count":2}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getAdoptionAverage&to=2020-05-03&from=2020-02-03&groupBy=week"}}');
    } else if(restType.contains('AnalyticsDataServer/getViewsOverTime')){
      res.setBody('{"status":"success","result":{"data":{"views":[],"uniqueViews":0,"mobileViews":0,"mobileAppViews":0,"desktopViews":0},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getViewsOverTimeCsv&to=2020-05-03&from=2020-02-03&groupBy=week"}}');
    } else if(restType.contains('AnalyticsDataServer/getMonthlyReport')){
      res.setBody('{"status":"success","result":{"data":[{"usersLoggedInCount":1,"viewedContentCount":1,"postsAndRepliesCount":1,"likesCount":1,"sharesCount":1,"usersLoggedInPercentage":1.01,"viewedContentPercentage":1.01,"averageViewsPerUserCount":1.01,"label":"test","month":12,"year":1997}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getMonthlyReports"}}');
    } else if(restType.contains('AnalyticsDataServer/getEngagement')){
      res.setBody('{"status":"success","result":{"trackingStartdate":"","data":{"shares":[{"value":0,"label":"2020-11-17"}],"replies":[{"value":0,"label":"2020-11-17"}],"likes":[{"value":0,"label":"2020-11-17"}],"favorites":[{"value":0,"label":"2020-11-17"}],"comments":[{"value":0,"label":"2020-11-17"}]},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getEngagement&to=2020-05-04&from=2020-02-04&groupBy=week"}}');
    } else if(restType.contains('AnalyticsDataServer/getEngagementList')){
      res.setBody('{"status":"success","result":{"data":[],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getEngagementList&to=2020-05-04&from=2020-02-04&orderBy=top&resultType=segment"}}');
    } else if(restType.contains('AnalyticsDataServer/getSiteViews')){
      res.setBody('{"status":"success","result":{"data":[{"totalViewCount":2}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getSiteViews&to=2020-05-04&from=2020-02-04&orderBy=bottom&resultType=segment"}}');
    } else if(restType.contains('AnalyticsDataServer/getSiteCounts')){
      res.setBody('{"status":"success","result":{"data":{"unlistedSiteCount":0,"siteManagerCount":0,"publicSiteCount":0,"privateSiteCount":0,"newlyAddedSiteCount":0,"hasLowActivitySites":false,"featuredSiteCount":0},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getSiteCounts&to=null&from=null"}}');
    } else if(restType.contains('AnalyticsDataServer/getContentPublications')){
      res.setBody('{"status":"success","result":{"data":{"publishedLocalizedDate":"","pages":0,"events":0,"blogPosts":0,"averageContentAge":0,"albums":0},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getContentPublications&to=2020-05-04&from=2020-02-04&onlyPublished=true"}}');
    } else if(restType.contains('AnalyticsDataServer/getContentViewsByType')){
      res.setBody('{"status":"success","result":{"data":{"pageViewCount":0,"eventViewCount":0,"blogPostViewCount":0,"averageViewsPerPageCount":0,"averageViewsPerEventCount":0,"averageViewsPerBlogPostCount":0,"averageViewsPerAlbumCount":0,"albumViewCount":0},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getContentViewsByTypeCsv&to=2020-05-04&from=2020-02-04"}}');
    } else if(restType.contains('AnalyticsDataServer/getPeopleOverview')){
      res.setBody('{"status":"success","result":{"data":{"totalUserCount":0,"locationCount":1,"departmentCount":0,"customCategoryCount":0,"activeUserCount":0}}}');
    } else if(restType.contains('AnalyticsDataServer/getLastSyncDate')){
      res.setBody('{"status":"success","result":{}}');
    } else if(restType.contains('ReportCtrl/getContentPublications')){
      res.setBody('{"status":"success","result":{"data":[{"publishedDate":"2020-02-03","content_type":"Page"}]}}');
    } else if(restType.contains('ReportCtrl/getPeopleProfileCompletenessCsv')){
      res.setBody('{"status":"success","result":{"data":[{"name":"testData"}]}}');
    } else if(restType.contains('AnalyticsDataServer/getContentEngagement')){
      res.setBody('{"status":"success","result":{"trackingStartdate":"","data":{"shares":[],"replies":[],"likes":[],"favorites":[],"comments":[]},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getEngagementCsv&to=2020-05-04&from=2020-02-04&groupBy=week"}}');
    } else if(restType.contains('AnalyticsDataServer/getRecommendationByType')){
      res.setBody('{"status":"success","result":{"data":{"recommendationGroup":"contentConsumption","recommendationItem":[{"label":"simpplrEmailsAllowed","value":true},{"label":"homeCarouselEnabled","value":true},{"label":"recommendedFeedMode","value":true},{"label":"homeCarousalUpdated","value":true},{"label":"MobileAppEnabled","value":false},{"label":"RecommendedHomeDefaultLayout","value":true},{"label":"AudienceEnabled","value":true},{"label":"SiteSubscriptionEnabled","value":true},{"label":"FeaturedSiteEnabled","value":true},{"label":"FeedOnHomeDashboardLayout","value":true}],"recommendationStats":[{"label":"avgContentViewsPerUser","value":172},{"label":"usersWhoViewedContent","value":51}]}},"message":"contentConsumption data returned successfully","recordCount":0}');
    } else if(restType.contains('AnalyticsDataServer/getCustomerSegmentAdoption')){
      res.setBody('{"status":"success","result":{"usersLoggedInPercentage":79,"contentPublishedPercentage":66.92502532928064,"averageViewsPerUserCount":44,"contributorsParticipantPercentage":66.82370820668693,"viewedContentPercentage":46.82370820668693},"message":" Monthly Customer Segment Adoption data returned successfully","recordCount":0}');
    } else if(restType.contains('ReportCtrl/getContentEngagementCsv')){
      res.setBody('{"status":"success","result":{"trackingStartdate":"","data":{"shares":[],"replies":[],"likes":[],"favorites":[],"comments":[],"contentViews":[],"uniqueContentViews:[]"},"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getEngagementCsv&to=2020-05-04&from=2020-02-04&groupBy=week"}}');
    } else if(restType.contains('AnalyticsDataServer/getAppAdoption')){
      res.setBody('{"status":"success","result":{"data":[],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getAppAdoption&to=2020-05-03&from=2020-02-03&resultType=segment&orderBy=top"}}');
    } else if(restType.contains('AnalyticsDataServer/getViewedByMetricData')){
      res.setBody('{\"status\":\"success\",\"result\":{\"membersViewedCount\":12,\"followersViewedCount\":10,\"othersViewedCount\":11,\"totalSiteMembers\":1100,\"totalSiteFollowers\":122,\"data\":[{\"id\":\"id1\",\"lastViewed\":\"2021-12-11\",\"firstViewed\":\"2021-12-01\",\"totalViews\":200,\"role\":\"Member\"},{\"id\":\"id2\",\"lastViewed\":\"2022-01-05\",\"firstViewed\":\"2021-12-21\",\"totalViews\":100,\"role\":\"Follower\"}]},\"message\":\"Analytics content returned successfully\"}');
    } else if(restType.contains('AnalyticsDataServer/getConsumptionOverTime')){
      res.setBody('{"status":"success","result":{"totalViewCount":16,"uniqueViewCount":1,"viewsOverTime":[{"label":"2022-01-18","value":5},{"label":"2022-01-21","value":1},{"label":"2022-01-25","value":2},{"label":"2022-02-07","value":2},{"label":"2022-02-08","value":2},{"label":"2022-02-09","value":4}],"uniqueViewsOverTime":[{"label":"2022-01-18","value":1},{"label":"2022-01-21","value":3},{"label":"2022-01-25","value":2},{"label":"2022-02-07","value":2},{"label":"2022-02-08","value":1},{"label":"2022-02-09","value":1}]},"message":"Analytics content views data returned successfully","recordCount":0}');
    }
    else if(restType.contains('ReportCtrl/getPerformanceSitesMembers')){
      res.setBody('{"status":"success","result":{"data":[{"name":"testData"}]}}');
    
    } else if(restType.contains('ReportCtrl/getPerformanceTopicsEndorsements')){
      res.setBody('{"status":"success","result":{"data":[{"name":"testData","count":1}]}}');
    
    } else if(restType.contains('ReportCtrl/getPerformanceSearch')){
      res.setBody('{"status":"success","result":{"data":[{"name":"testData","count":1,"url":"dummyUrl"}]}}');
    
    } else if(restType.contains('ReportCtrl/getEngagementFeed')){
      res.setBody('{"status":"success","result":{"data":[{"localizedDate":"2020-02-03","day":"monday","likes":2}]}}');
    
    } else if(restType.contains('ReportCtrl/getEngagementContentTypes')){
      res.setBody('{"status":"success","result":{"data":[{"day":"monday"}]}}');
    
    } else if(restType.contains('ReportCtrl/getAdoptionOverview')){
      res.setBody('{"status":"success","result":{"data":[{"name":"contributors","count":0},{"name":"participants","count":0},{"name":"observers","count":0},{"name":"inactive","count":0}],"csvUrl":"https://c.na136.visual.force.com/apex/Reports?action=getAdoptionAverage&to=2020-12-17&from=2020-11-17&groupBy=day"}}');
  
    } else if(restType.contains('ReportCtrl/getVideoAdoption')){
      res.setBody('{"status":"success","result":{"data":{"totalWatchTime":124.55,"totalViewers":9,"totalVideoViews":233,"totalVideosPlayed":128,"totalPeople":48},"csvUrl":"https://denali-stg1--simpplr.visualforce.com/apex/simpplr__Reports?action=getVideoAdoptionCsv&to=2020-12-17&from=2020-11-17&orderBy=null"}}');
  
    } else if(restType.contains('ReportCtrl/getVideoPopularity')){
      res.setBody('{"status":"success","result":{"data":[{"views":6,"videoId":"1_57re1s0b","url":"https://denali-stg1--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_57re1s0b&provider=native_video","uploader":"System Admin","uploadedAt":"2020-11-27","label":"20051210-w50s_56K (1)(4).flv"},{"views":6,"videoId":"1_nj307tsn","url":"https://denali-stg1--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_nj307tsn&provider=native_video","uploader":"System Admin","uploadedAt":"2020-11-27","label":"sample_3840x2160(7).m4v"},{"views":6,"videoId":"1_acuzki07","url":"https://denali-stg1--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_acuzki07&provider=native_video","uploader":"System Admin","uploadedAt":"2020-12-14","label":"file_example_MP4_480_1_5MG.mp4"},{"views":6,"videoId":"1_125p2e4a","url":"https://denali-stg1--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_125p2e4a&provider=native_video","uploader":"System Admin","uploadedAt":"2020-11-27","label":"SampleVideo_1280x720_1mb.mkv"},{"views":6,"videoId":"1_jn5cigxt","url":"https://denali-stg1--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_jn5cigxt&provider=native_video","uploader":"System Admin","uploadedAt":"2020-11-27","label":"sample_960x540.3gp"}],"csvUrl":"https://denali-stg1--simpplr.visualforce.com/apex/simpplr__Reports?action=getVideoPopularity&to=2020-12-17&from=2020-11-17&orderBy=top"}}');
  
    } else if(restType.contains('success')){
      res.setBody('{"result":"success","status":"success"}');

    } else if(restType.contains('web-push-manager')){
      res.setBody('{"result":["test"]}');

    } else if(restType.contains('blobBody')){
      res.setBodyAsBlob(Blob.valueOf('Test'));

    } else if(restType.contains('settingDataServer/getGeneralSetupConfig')) {
      res.setBody('{"status":"success","result":{"socialCampaignPolicyURL":"aaa","socialCampaignEnabled":"true","nativeAppEnabled":false,"shareFeedback":true,"postLogoutUrl":"https://login.salesforce.com/","pagesFeatureEnabled":true,"newsFeatureEnabled":false,"mobilePromotionEnabled":"false","mobileAppAdditionalSecurityEnabled":"true","loginTimeoutSeconds":"86400","languages":[{"onOff":true,"name":"en_US","label":"en_US.language.en_us"},{"onOff":false,"name":"en_GB","label":"en_US.language.en_gb"},{"onOff":false,"name":"fr_FR","label":"en_US.language.fr_fr"},{"onOff":false,"name":"de_DE","label":"en_US.language.de_de"},{"onOff":false,"name":"it_IT","label":"en_US.language.it_it"},{"onOff":false,"name":"ja_JP","label":"en_US.language.ja_jp"},{"onOff":false,"name":"pt_BR","label":"en_US.language.pt_br"},{"onOff":false,"name":"es_ES","label":"en_US.language.es_es"}],"fileFeatureEnabled":true,"feedbackRecipients":[],"feature":[],"eventsFeatureEnabled":true,"enablePushNotificationMobile":true,"enablePushNotificationDesktop":true,"calendarOutlookEnabled":true,"calendarOffice365Enabled":true,"calendarGoogleEnabled":true,"calendarAppEnabled":true,"blogsFeatureEnabled":false,"blogPostSetup":"enable","automatedTranslationEnabled":"false","applicationName":"Simpplr","albumsFeatureEnabled":true}}');
    
    } else if(restType.contains('ToggleBookmarkDataServer/bookmarkFile')){
      res.setBody('{"status":"success","message":"File bookmarked successfully","result":"success"}');
    
    } else if(restType.contains('ToggleBookmarkDataServer/unbookmarkFile')){
      res.setBody('{"status":"success","message":"File bookmarked successfully","result":"success"}');
    
    } else if(restType.contains('googleCalendarEvents')) {
      res.setBody('{"timeZone":"America/Los_Angeles","accessRole":"owner","nextPageToken":"EjYKKzI2MmM4MGRmNG0zNjh0bjZuMmw4cHE5cWQ0XzIwMjAwNzIyVDE3MzAwMFoYgLTGxtPg6gIiBwgFELKOpgg=","items":[{"id":"3fi4ddb7qnq1mka6d5b8b6o20q","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=M2ZpNGRkYjdxbnExbWthNmQ1YjhiNm8yMHEgcnlhbi50YXlsb3JAc2ltcHBsci5kZXY","created":"2020-07-16T06:18:15.000Z","updated":"2020-07-17T14:33:40.870Z","summary":"Tambola ","description":"Game time","creator":{"email":"ryan.taylor@simpplr.dev"},"start":{"dateTime":"2020-07-20T03:30:00-07:00","timeZone":"Asia/Kolkata"},"end":{"dateTime":"2020-07-20T04:30:00-07:00","timeZone":"Asia/Colombo"},"iCalUID":"3fi4ddb7qnq1mka6d5b8b6o20q@google.com"},{"id":"262c80df4m368tn6n2l8pq9qd4_20200720T173000Z","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=MjYyYzgwZGY0bTM2OHRuNm4ybDhwcTlxZDRfMjAyMDA3MjBUMTczMDAwWiByeWFuLnRheWxvckBzaW1wcGxyLmRldg","created":"2020-07-16T05:20:46.000Z","updated":"2020-07-16T05:23:25.409Z","summary":"Daily standup","description":"standup","location":"Online","creator":{"email":"ryan.taylor@simpplr.dev"},"start":{"dateTime":"2020-07-20T10:30:00-07:00","timeZone":"America/Los_Angeles"},"end":{"dateTime":"2020-07-20T11:30:00-07:00","timeZone":"America/Los_Angeles"},"originalStartTime":{"dateTime":"2020-07-20T10:30:00-07:00","timeZone":"America/Los_Angeles"},"iCalUID":"262c80df4m368tn6n2l8pq9qd4@google.com"},{"id":"262c80df4m368tn6n2l8pq9qd4_20200721T173000Z","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=MjYyYzgwZGY0bTM2OHRuNm4ybDhwcTlxZDRfMjAyMDA3MjFUMTczMDAwWiByeWFuLnRheWxvckBzaW1wcGxyLmRldg","created":"2020-07-16T05:20:46.000Z","updated":"2020-07-16T05:23:25.409Z","summary":"Daily standup","description":"standup","location":"Online","creator":{"email":"ryan.taylor@simpplr.dev"},"start":{"dateTime":"2020-07-21T10:30:00-07:00","timeZone":"America/Los_Angeles"},"end":{"dateTime":"2020-07-21T11:30:00-07:00","timeZone":"America/Los_Angeles"},"originalStartTime":{"dateTime":"2020-07-21T10:30:00-07:00","timeZone":"America/Los_Angeles"},"iCalUID":"262c80df4m368tn6n2l8pq9qd4@google.com"},{"id":"262c80df4m368tn6n2l8pq9qd4_20200722T173000Z","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=MjYyYzgwZGY0bTM2OHRuNm4ybDhwcTlxZDRfMjAyMDA3MjJUMTczMDAwWiByeWFuLnRheWxvckBzaW1wcGxyLmRldg","created":"2020-07-16T05:20:46.000Z","updated":"2020-07-16T05:23:25.409Z","summary":"Daily standup","description":"standup","location":"Online","creator":{"email":"ryan.taylor@simpplr.dev"},"start":{"dateTime":"2020-07-22T10:30:00-07:00","timeZone":"America/Los_Angeles"},"end":{"dateTime":"2020-07-22T11:30:00-07:00","timeZone":"America/Los_Angeles"},"originalStartTime":{"dateTime":"2020-07-22T10:30:00-07:00","timeZone":"America/Los_Angeles"},"iCalUID":"262c80df4m368tn6n2l8pq9qd4@google.com"}]}"');
    
    } else if(restType.contains('peopleDataServer/addEndorsement')) {
      res.setBody('{"status":"success","result":{"isEndorsed":true,"expertise":{"name":"newTopic","id":"a1F4T0000005tKiUAI"},"count":4}}');
    
    } else if(restType.contains('peopleDataServer/getUserWebpushTokens')) {
      res.setBody('{"status": "success", "result": ["dummy-token"]}');
    
    } else if(restType.contains('oembed')) {
      res.setBody('{"width":480,"version":"1.0","url":"https://www.youtube.com/watch?v=vqcHjS1O8kM&t=9s","type":"video","title":"Simpplr 3 Minute Demo","thumbnail_width":480,"thumbnail_url":"https://i.ytimg.com/vi/vqcHjS1O8kM/hqdefault.jpg","thumbnail_height":360,"provider_url":"https://www.youtube.com/","provider_name":"YouTube","html":"<iframe width=\'480\' height=\'270\' src=\'https://www.youtube.com/embed/vqcHjS1O8kM?start=9&amp;feature=oembed\' frameborder=\'0\' allow=\'accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\' allowfullscreen=\'\'></iframe>","height":270,"duration":0,"description":"","author_url":"https://www.youtube.com/channel/UCBSkpP2rV2Ql3t5mKPF3zmw","author_name":"Simpplr"}');
    
    } else if(restType.contains('AnalyticsDataServer/getVideoPopularity')) {
      res.setBody('{"status":"success","result":{"data":[{"videoId":"1_imoh020u","label":"3114883_1612557221","views":71,"uploader":"a2L3l000001iSm4","uploadedAt":"2021-02-05"},{"videoId":"1_bbtf8f5w","label":"zoom_0.mp4","views":65,"uploader":"a2L1N000000kuDK","uploadedAt":"2021-01-27"},{"videoId":"1_xr6c9cwp","label":"3114883_1614353265","views":21,"uploader":"a2L1N000001RpoD","uploadedAt":"2021-02-26"},{"videoId":"1_1f4d09qe","label":"file_example_MP4_480_1_5MG.mp4","views":20,"uploader":"a2Lo0000000MYYW","uploadedAt":"2021-02-09"},{"videoId":"1_qn6uk2rx","label":"Simpplr-Video-Offering.mp4","views":17,"uploader":"a2L1N000001T7WT","uploadedAt":"2021-02-05"}]},"recordCount":0}"');
    
    } else if(restType.contains('AnalyticsDataServer/getVideoAdoption')) {
      res.setBody('{"status":"success","result":{"data":{"totalVideosPlayed":26,"totalViewers":60,"totalVideoViews":147,"totalWatchTime":692.18333333333,"totalPeople":150}},"recordCount":0}"');
      
    } else if(restType.contains('FileDataServer/googledrive')) {
      res.setBody('{"files":[{"kind":"drive#file","id":"1yht3BTYAIa3hZcvHHyamQhtcmZ8sYZkt","name":"Polity6.pdf","mimeType":"application/pdf","starred":true,"trashed":false,"parents":["15zG70DTLDRq6W8IhHVuZ62iq4ms3Uy6u"],"version":"20","webViewLink":"https://drive.google.com/file/d/1yht3BTYAIa3hZcvHHyamQhtcmZ8sYZkt/view?usp=drivesdk","iconLink":"https://drive-thirdparty.googleusercontent.com/16/type/application/pdf","thumbnailLink":"https://lh3.googleusercontent.com/78g-Zgh4JWe98BvtTqkfAKgET6u6QCGINcTwxDBOLRQmwNp6oZlYU86G3DwoCiytKMyG15yWsOrOUC0=s220","createdTime":"2020-12-15T07:31:54.614Z","modifiedTime":"2020-12-17T08:45:00.256Z","owners":[{"displayName":"Craig Gordon","emailAddress":"craig.gordon@simpplr.dev"}],"capabilities":{"canAddChildren":false,"canAddMyDriveParent":false,"canChangeCopyRequiresWriterPermission":false,"canChangeViewersCanCopyContent":false,"canComment":true,"canCopy":true,"canDelete":false,"canDownload":true,"canEdit":true,"canListChildren":false,"canModifyContent":true,"canMoveChildrenWithinDrive":false,"canMoveItemIntoTeamDrive":false,"canMoveItemOutOfDrive":false,"canMoveItemWithinDrive":true,"canReadRevisions":true,"canRemoveChildren":false,"canRemoveMyDriveParent":true,"canRename":true,"canShare":true,"canTrash":false,"canUntrash":false,"permissions":[{"id":"06980517518131251071","emailAddress":"erica.kane@simpplr.dev","role":"writer"}],"size":"13264","isAppAuthorized":false}}],"directory":{"id":"15zG70DTLDRq6W8IhHVuZ62iq4ms3Uy6u","name":"Brown 4","mimeType":"application/vnd.google-apps.folder","starred":false,"parents":["0AKqBx2jzzO2TUk9PVA"],"version":"19","webViewLink":"https://drive.google.com/drive/folders/15zG70DTLDRq6W8IhHVuZ62iq4ms3Uy6u","modifiedTime":"2020-12-17T08:44:17.679Z","capabilities":{"canAddChildren":true,"canAddMyDriveParent":false,"canChangeCopyRequiresWriterPermission":false,"canChangeViewersCanCopyContent":false,"canComment":true,"canCopy":false,"canDelete":true,"canDownload":true,"canEdit":true,"canListChildren":true,"canModifyContent":true,"canMoveChildrenWithinDrive":true,"canMoveItemIntoTeamDrive":true,"canMoveItemOutOfDrive":true,"canMoveItemWithinDrive":true,"canReadRevisions":false,"canRemoveChildren":true,"canRemoveMyDriveParent":true,"canRename":true,"canShare":true,"canTrash":true,"canUntrash":true},"permissions":[{"kind":"drive#permission","id":"16869940733204619107","type":"user","emailAddress":"craig.gordon@simpplr.dev","role":"reader","displayName":"Craig Gordon","deleted":false}]},"status":"success","statusCode":200}');
    
    } else if(restType.contains('GoogleDrive/GetFile')){
      res.setBody('{"status": "success","message": "File fetched successfully.","result": {"id": "googledrivefileId","name": "abc.jpg","mimeType": "image/jpeg","starred": false,"version": "1","webContentLink": "https://drive.google.com/uc?id=googledrivefileId&export=download","webViewLink": "https://drive.google.com/file/d/googledrivefileId/view?usp=drivesdk","thumbnailLink": "abc","modifiedTime": "2020-08-20T06:22:59.115Z","teamDriveId": "driveId","driveId": "driveId","fileExtension": "jpg","size": "12142"}}');
    
    } else if(restType.contains('FileDataServer/searchGoogleDrive')) {
      res.setBody('{\"status\":\"success\",\"files\":[],\"totalRecords\":0}');
    } else if(restType.contains('/Videos')) {
    	res.setBody('{"status" : "success"}');  	
    } else if(restType.contains('/GetNativeVideosFromKaltura')){
       res.setBody('{\"objects\":[{\"object\":{\"mediaType\":1,\"conversionQuality\":17240523,\"sourceType\":\"1\",\"dataUrl\":\"https://cdnapisec.kaltura.com/p/4236553/sp/423655300/playManifest/entryId/1_u3bhe47k/format/url/protocol/https\",\"flavorParamsIds\":\"0,487041,487051,487061,487071\",\"plays\":1,\"views\":1,\"lastPlayedAt\":1641459600,\"width\":1280,\"height\":720,\"duration\":5,\"msDuration\":5364,\"id\":\"1_ohwe1e04\",\"name\":\"Video111.mp4\",\"description\":\"\",\"partnerId\":4236553,\"userId\":\"00D5Y0000024RSFUA2a145Y00000tMTWMQA4\",\"creatorId\":\"00D5Y0000024RSFUA2a145Y00000tMTWMQA4\",\"tags\":\"\",\"status\":2,\"moderationStatus\":6,\"moderationCount\":0,\"type\":1,\"createdAt\":1641460173,\"updatedAt\":1641833687,\"rank\":0,\"totalRank\":0,\"votes\":0,\"downloadUrl\":\"https://cdnapisec.kaltura.com/p/4236553/sp/423655300/playManifest/entryId/1_ohwe1e04/format/download/protocol/https/flavorParamIds/0\",\"searchText\":\"_PAR_ONLY__4236553__MEDIA_TYPE_1|Video111.mp4\",\"licenseType\":-1,\"version\":0,\"thumbnailUrl\":\"https://cfvod.kaltura.com/p/4236553/sp/423655300/thumbnail/entry_id/1_ohwe1e04/version/100001\",\"accessControlId\":5101133,\"replacementStatus\":0,\"partnerSortValue\":0,\"conversionProfileId\":17240523,\"rootEntryId\":\"1_ohwe1e04\",\"operationAttributes\":[],\"entitledUsersEdit\":\"\",\"entitledUsersPublish\":\"\",\"entitledUsersView\":\"\",\"capabilities\":\"\",\"displayInSearch\":1,\"blockAutoTranscript\":false,\"objectType\":\"KalturaMediaEntry\"},\"highlight\":[{\"fieldName\":\"name\",\"hits\":[{\"value\":\"Video111.<em>mp4</em>\",\"objectType\":\"KalturaString\"}],\"objectType\":\"KalturaESearchHighlight\"}],\"itemsData\":[],\"objectType\":\"KalturaESearchEntryResult\"}],\"totalCount\":18,\"objectType\":\"KalturaESearchEntryResponse\",\"status\":\"success\"}');
    } else if(restType.contains('/CleanupOrphanNativeVideos')) {
      res.setBody('{"status" : "success", "totalCount" : 1, "objects" : [{"id" : "native_video_external_id"}]}');
    } else if(restType.contains('ai')) {
    	res.setBody('{"status" : "success"}');  	
    
    } else if(restType.contains('AIDataServer/checkCommentToxicity')) {
    	res.setBody('{"isToxic" : true, "version" : "v11", "categories" : ["dummy1","dummy2"] }');  	
    } else if(restType.contains('AIDataServer/markModerationItemDismissed')) {
    	res.setBody('{"status" : "success"}');  	
    } else if(restType.contains('AIDataServer/markModerationItemRemoved')) {
    	res.setBody('{"status" : "success"}');  	
    } else if(restType.contains('AIDataServer/reportContent')) {
    	res.setBody('{"status" : "success"}');  	
    } else if(restType.contains('AIDataServer/getModerationDataFromMS')) {
    	res.setBody('{"moderationResults":[{"chatter_comment_id":"0D54x00001IwlejCAB","moderation_metadata":{"moderation_status":"reported post"},"replies":[{"chatter_reply_id":"0D74x0000005YlxCAE","moderation_metadata":{"moderation_status":"reported reply"}}]},{"chatter_comment_id":"0D54x00001Iwld7CAB","moderation_metadata":{"moderation_status":"reported"},"replies":[]}]}');  	
    } else if(restType.contains('recommendationsSetUp')) {
    	res.setBody('{"status" : "success","job_id" : "11jjjshhyu"}');  	
    } else if(restType.contains('sp/removelinkeditem')) {
      res.setBody('');
    } else if(restType.contains('newsletter')) {
    	res.setBody('{"status" : "success","body" : "response_Body"}');  	

    } else if(restType.contains('VideoDataServer/accessToken')) {
      res.setBody('{"accessToken":{"ks":"djJ8MzEzNjgyM3zLClHh08p_UZ0TRrxddOd3oE0R0MegO60jmQShQqklTeajkRpkP89IPq-yqpBoBLSEyjAHEGq6rotyV_7-GlInm0LClgeKB0b8p5LEi2w5K9IdPq2jFowT7BjykfsUA6xZOoif027pgrH7wPg3TTdltV6M80cM_H2AgHcagPhYDte325S71rgPqSVe5nvFajV69AR2VtII585B1oGwHpC6A4ebhR0xBZ5HN9berbhMXn5XQW_uOaioNyCBYceNIT4=","sessionType":0,"partnerId":"3136823","userId":"00D4T000000EkA4UAKa0t4T0000004jXiQAI","expiry":"1633751516","privileges":"sessionid:1_5516csy3,apptoken:1_5516csy3,enableentitlement,privacycontext:rootCategory","objectType":"KalturaSessionInfo"},"uiconfIds":{"defaultPlayer":"46859913","playerWithTranscript":"48311333"},"uiconfId":"46859913","partnerId":"3136823","subPartnerId":"313682300","playerUrl":"https://cdnapisec.kaltura.com/p/3136823/embedPlaykitJs/uiconf_id/46859913?iframeembed=true&ks=djJ8MzEzNjgyM3zLClHh08p_UZ0TRrxddOd3oE0R0MegO60jmQShQqklTeajkRpkP89IPq-yqpBoBLSEyjAHEGq6rotyV_7-GlInm0LClgeKB0b8p5LEi2w5K9IdPq2jFowT7BjykfsUA6xZOoif027pgrH7wPg3TTdltV6M80cM_H2AgHcagPhYDte325S71rgPqSVe5nvFajV69AR2VtII585B1oGwHpC6A4ebhR0xBZ5HN9berbhMXn5XQW_uOaioNyCBYceNIT4=","playerId":""}');  	
    } else if(restType.contains('slackAuthTest')){
      res.setBody('{ "ok": false, "error": "invalid_auth"}');
    } else if(restType.contains('serviceNowError')){
      res.setBody('{"error":"server_error","error_description":"access_denied"}');
    } else if(restType.contains('/Audience')){
      res.setBody('{"status" : "success","body" : "{}"');
    } else if(restType.contains('/Box/CreateFolder')){
      res.setBody('{"status" : "success","body" : {"type":"folder","id":"156172386121","sequence_id":"0","etag":"0","name":"Box Fldr 11","created_at":"2022-02-13T20:12:22-08:00","modified_at":"2022-02-13T20:12:22-08:00","description":"","size":0,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"}]},"created_by":{"type":"user","id":"238851582","name":"Joanna Smith","login":"box1@simpplr.com"},"modified_by":{"type":"user","id":"238851582","name":"Joanna Smith","login":"box1@simpplr.com"},"trashed_at":null,"purged_at":null,"content_created_at":"2022-02-13T20:12:22-08:00","content_modified_at":"2022-02-13T20:12:22-08:00","owned_by":{"type":"user","id":"238851582","name":"Joanna Smith","login":"box1@simpplr.com"},"shared_link":null,"folder_upload_email":null,"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},"item_status":"active","item_collection":{"total_count":0,"entries":[],"offset":0,"limit":100,"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}}');
    } else if (restType.contains('/NotificationDataServer/peopleByCountry')) {
      res.setBody('{"hits":{"start": 0, "total": {"value":1},"aggregation":[{"key":"India","doc_count":0}]},"status":"success"}');
    } else if (restType.contains('oneloginapps/get')) {
      res.setBody(xlmBody);
    } else if (restType.contains('oktaapps/get')) {
      res.setBody('{"errorSummary": "testSummary"}');
    } else if(restType.contains('getJWTToken')) {
      res.setBody('{"access_token": "eyJcluLWFs","token_type": "Bearer","expires_in": 300}');
    } else if(restType.contains('getSSJWTToken')) {
      res.setBody('{"access_token": "eyJcluLWFs","token_type": "Bearer","expires_in": 300}');
    } else if(restType.contains('/ActiveDirectory')) {
      res.setBody('{\"@odata.context\":\"https://graph.microsoft.com/v1.0/$metadata#groups\",\"@odata.count\":1,\"@odata.nextLink\":\"https://graph.microsoft.com/v1.0/groups?$top=1&$count=true&$skiptoken=m~AQAnOzAwNGQyMDc1MWUxYjRmMTViOTRjNzc4YjBlNDhjYzljOzswOzA7\",\"value\":[{\"id\":\"004d2075-1e1b-4f15-b94c-778b0e48cc9c\",\"deletedDateTime\":null,\"classification\":null,\"createdDateTime\":\"2021-10-28T08:24:12Z\",\"creationOptions\":[\"ProvisionGroupHomepage\",\"HubSiteId:00000000-0000-0000-0000-000000000000\",\"SPSiteLanguage:1033\"],\"description\":\"TestSp\",\"displayName\":\"TestSp\",\"expirationDateTime\":null,\"groupTypes\":[\"Unified\"],\"isAssignableToRole\":null,\"mail\":\"TestSp@simpplr.onmicrosoft.com\",\"mailEnabled\":true,\"mailNickname\":\"TestSp\",\"membershipRule\":null,\"membershipRuleProcessingState\":null,\"onPremisesDomainName\":null,\"onPremisesLastSyncDateTime\":null,\"onPremisesNetBiosName\":null,\"onPremisesSamAccountName\":null,\"onPremisesSecurityIdentifier\":null,\"onPremisesSyncEnabled\":null,\"preferredDataLocation\":null,\"preferredLanguage\":null,\"proxyAddresses\":[\"SPO:SPO_9c2d6bc7-6c85-45e4-bf33-50abab1733cf@SPO_16e59f39-4074-434d-ba27-6b491d7c1516\",\"SMTP:TestSp@simpplr.onmicrosoft.com\"],\"renewedDateTime\":\"2021-10-28T08:24:12Z\",\"resourceBehaviorOptions\":[],\"resourceProvisioningOptions\":[],\"securityEnabled\":false,\"securityIdentifier\":\"S-1-12-1-5054581-1326784027-2339851449-2630633486\",\"theme\":null,\"visibility\":\"Private\",\"onPremisesProvisioningErrors\":[]},{\"id\":\"004d2075-1e1b-4f15-b94c-778b0e48cc9c\",\"deletedDateTime\":null,\"classification\":null,\"createdDateTime\":\"2021-10-28T08:24:12Z\",\"creationOptions\":[\"ProvisionGroupHomepage\",\"HubSiteId:00000000-0000-0000-0000-000000000000\",\"SPSiteLanguage:1033\"],\"description\":\"TestSp\",\"displayName\":\"TestSp\",\"expirationDateTime\":null,\"groupTypes\":[],\"isAssignableToRole\":null,\"mail\":\"TestSp@simpplr.onmicrosoft.com\",\"mailEnabled\":true,\"mailNickname\":\"TestSp\",\"membershipRule\":null,\"membershipRuleProcessingState\":null,\"onPremisesDomainName\":null,\"onPremisesLastSyncDateTime\":null,\"onPremisesNetBiosName\":null,\"onPremisesSamAccountName\":null,\"onPremisesSecurityIdentifier\":null,\"onPremisesSyncEnabled\":null,\"preferredDataLocation\":null,\"preferredLanguage\":null,\"proxyAddresses\":[\"SPO:SPO_9c2d6bc7-6c85-45e4-bf33-50abab1733cf@SPO_16e59f39-4074-434d-ba27-6b491d7c1516\",\"SMTP:TestSp@simpplr.onmicrosoft.com\"],\"renewedDateTime\":\"2021-10-28T08:24:12Z\",\"resourceBehaviorOptions\":[],\"resourceProvisioningOptions\":[],\"securityEnabled\":false,\"securityIdentifier\":\"S-1-12-1-5054581-1326784027-2339851449-2630633486\",\"theme\":null,\"visibility\":\"Private\",\"onPremisesProvisioningErrors\":[]},{\"id\":\"004d2075-1e1b-4f15-b94c-778b0e48cc9c\",\"deletedDateTime\":null,\"classification\":null,\"createdDateTime\":\"2021-10-28T08:24:12Z\",\"creationOptions\":[\"ProvisionGroupHomepage\",\"HubSiteId:00000000-0000-0000-0000-000000000000\",\"SPSiteLanguage:1033\"],\"description\":\"TestSp\",\"displayName\":\"TestSp\",\"expirationDateTime\":null,\"groupTypes\":[],\"isAssignableToRole\":null,\"mail\":\"TestSp@simpplr.onmicrosoft.com\",\"mailEnabled\":false,\"mailNickname\":\"TestSp\",\"membershipRule\":null,\"membershipRuleProcessingState\":null,\"onPremisesDomainName\":null,\"onPremisesLastSyncDateTime\":null,\"onPremisesNetBiosName\":null,\"onPremisesSamAccountName\":null,\"onPremisesSecurityIdentifier\":null,\"onPremisesSyncEnabled\":null,\"preferredDataLocation\":null,\"preferredLanguage\":null,\"proxyAddresses\":[\"SPO:SPO_9c2d6bc7-6c85-45e4-bf33-50abab1733cf@SPO_16e59f39-4074-434d-ba27-6b491d7c1516\",\"SMTP:TestSp@simpplr.onmicrosoft.com\"],\"renewedDateTime\":\"2021-10-28T08:24:12Z\",\"resourceBehaviorOptions\":[],\"resourceProvisioningOptions\":[],\"securityEnabled\":true,\"securityIdentifier\":\"S-1-12-1-5054581-1326784027-2339851449-2630633486\",\"theme\":null,\"visibility\":\"Private\",\"onPremisesProvisioningErrors\":[]}]}');
    } else if(restType.contains('getCSVDownloadUrl')) {
      res.setBody('{"url": "DummyURL"}');
    } else if(restType.contains('microsoftTeams')) {
      res.setBody('{"id": "dummyId", "displayName" : "dummyName"}');
    } else if(restType.contains('microsoftTeamsAlert')) {
      res.setBody('{"id": "dummyId", "displayName" : "dummyName"}');
    } else if(restType.contains('qna/question')) {
      res.setBody('{\"success\":true,\"status\":200,\"textStatus\":\"\",\"message\":\"\",\"responseTimeStamp\":1651053429205,\"result\":{}}');
    } else if(restType.contains('qna/answer')) {
      res.setBody('{\"success\":true,\"status\":200,\"textStatus\":\"\",\"message\":\"\",\"responseTimeStamp\":1651053429205,\"result\":{}}');
    }else if(restType.contains('SettingDataServer/saveGeneralSetupConfig')) {
      res.setBody('{\"fullName\":\"Security\",\"success\":\"true\"}');
    }else if(restType.contains('/utility/sanitize-html')) {
    	res.setBody('{"status" : "success","body" : "response_Body"}');  	
    }else if(restType.contains('AnalyticsDataServer/getContentViews')) {
    	res.setBody('{\"status\":\"success\",\"result\":{\"totalViewCount\":0,\"uniqueViewCount\":0,\"viewsOverTime\":[],\"topDepartments\":[],\"topLocations\":[],\"uniqueViewsOverTime\":null},\"message\":\"Analytics content returned successfully\",\"recordCount\":0}');  	
    }else if(restType.contains('AnalyticsDataServer/getContentListViews')) {
    	res.setBody('{\"status\":\"success\",\"result\":[{\"totalViewCount\":0,\"uniqueViewCount\":0,\"viewsOverTime\":[],\"topDepartments\":[],\"topLocations\":[],\"uniqueViewsOverTime\":null}],\"message\":\"Analytics content returned successfully\",\"recordCount\":0}');  	
    }else if(restType.contains('/content/topic-suggest')) {
    	res.setBody('{\"status\":\"success\",\"content_recommendations\":{}}');  	
    }else if(restType.contains('/ai-es-analysis/emotion')) {
    	res.setBody('{\"status\":\"success\"}'); 
    } else if (restType.contains('/connectExternalApp/outlookCalendar')) {
      res.setBody('{\"result\":{\"mail\":\"test@test.com\",\"displayName\":\"test\",\"id\":\"testid\"}}');
    } else if (restType.contains('/connectExternalApp/microsoftteams')) {
      res.setBody('{\"result\":{\"mail\":\"test@test.com\",\"displayName\":\"test\",\"id\":\"testid\","tenantId\":\"testtenantid\"}}');
    } else if (restType.contains('/connectExternalApp/slack')) {
      res.setBody('{\"result\":{\"listOfApps\":[{\"connectedAs\":\"test\",\"userId\":\"testid\",\"teamId\":\"tenantid\",\"name\":\"slackContentShare\"}]}, "token_type":"Bearer", "jwtToken":"absdhofisdofhsdlkfhsdo"}');
    } else if (restType.contains('VideoDataService/sendNotification')) {
      res.setBody('{\"message\":\"Successfully returned.\",\"result\":{\"totalVideos\":63,\"totalBandwidth\":128000000000,\"consumedBandwidth\":111000000000}}');
    } else if (restType.contains('AIRelatedContent')) {
      res.setBody('{"similar_text":[[{"text":null,"score":0.5,"probability":1,"question":null,"id":"a0H1N00000KBdk8UAD","expires_at":"","text_intro":"Test","site_type":"Public","publishStartDate":"2017-10-21T18:30:00.000Z","site_id":"a0No000000GzYKNEA3","page_category":" ","type":"Event","topic_list":["potluck"],"title":"Test","similarity_score":1,"recency_rate":0.10192943828752511}]]}');
    } else if(restType.contains('/v1/identity/oauth/client/token')){
      res.setBody('{"access_token":"accesstoken"}');
    } else if(restType.contains('/people-onboarding')){
      res.setBody('{"peopleUuid":"123"}');
    } else if(restType.contains('/gsuite/user-manager')) {
    	res.setBody('{"result":{"users":[{"kind":"admin#directory#user","id":"112578370361342691059","etag":"nM32qckM4XsKqhG",' + 
      '"Simpplr": {"Birthdate": "1947-08-15","CompanyName": "Simpplr","JoiningDate": "2000-01-01"},"customSchemas":{"Simpplr":{"Birthdate":"1947-08-15","CompanyName":"Simpplr","JoiningDate":"2000-01-01","StreetName":"dummyStreet","StateName":"dummyState","CityName":"dummyCity","CountryName":"dummyCountry","PostalCodeName":"dummyPostalCode"}}, "primaryEmail":"BatchGoogleUserProvTest_usr@testorg.com","name":{"givenName":"admin","familyName":"two","fullName":"admin two"},"isAdmin":false,"isDelegatedAdmin":true,"lastLoginTime":"2019-03-28T11:11:38.000Z","creationTime":"2019-03-28T11:00:34.000Z","agreedToTerms":true,"suspended":false,"archived":false,"changePasswordAtNextLogin":false,"ipWhitelisted":false,"emails":[{"address":"admintwo@bhootnath.in","primary":true}],"externalIds":[{"value":"E007","type":"organization"}],"relations":[{"value":"amit@bhootnath.in","type":"manager"}],"addresses":[{"type":"work","formatted":"WeWork, Sector 15, Gurgaon, Haryana, India","streetAddress":"dummy street","postalCode":"1234","locality":"dummy","region":"dummy","country":"dummy"}],"organizations":[{"title":"Simpplr Admin","name":"name hai ye","primary":true,"customType":"","department":"Intranet Admin","description":"Permanent"}],"phones":[{"value":"900","type":"work"},{"value":"100","type":"mobile"}],"locations":[{"type":"desk","area":"desk","buildingId":"WeWork","floorName":"2nd Floor","floorSection":"Right Side"}],"customerId":"C01gzjfgr","orgUnitPath":"","isMailboxSetup":true,"isEnrolledIn2Sv":false,"isEnforcedIn2Sv":false,"includeInGlobalAddressList":true},{"kind":"admin#directory#user","id":"112578370361342691087","etag":"nM32qcee4XsKqhG-zylXvkNQRY8foRHt9wwiAEAmQRcZe09epyAwLE","primaryEmail":"enemy1@dummy1.com","name":{"givenName":"dummy2","familyName":"dddddd","fullName":"dummy2 ddddd"},"isAdmin":false,"isDelegatedAdmin":true,"lastLoginTime":"2019-03-28T11:11:38.000Z","creationTime":"2019-03-28T11:00:34.000Z","agreedToTerms":true,"suspended":false,"archived":false,"changePasswordAtNextLogin":false,"ipWhitelisted":false,"emails":[{"address":"enemy1@dummy1.com","primary":true}],"externalIds":[{"value":"E008","type":"organization"}],"relations":[{"value":"dummy@dummy.com","type":"manager"}],"addresses":[{"type":"work","formatted":"WeWork, Sector 15, Gurgaon, Haryana, India","streetAddress":"dummy street","postalCode":"1234","locality":"dummy","region":"dummy","country":"dummy"}],"organizations":[{"title":"Simpplr Admin","name":"name hai ye","primary":true,"customType":"","department":"Intranet Admin","description":"Permanent"}],"phones":[{"value":"900","type":"work"},{"value":"100","type":"mobile"}],"locations":[{"type":"desk","area":"desk","buildingId":"WeWork","floorName":"2nd Floor","floorSection":"Right Side"}],"customerId":"C01gzjfgr","orgUnitPath":"","isMailboxSetup":true,"isEnrolledIn2Sv":false,"isEnforcedIn2Sv":false,"includeInGlobalAddressList":true}]}}');
    }else if(restType.contains('/normalization/locations/validate-address')) {
    	res.setBody('[{\"normalizationStatus\":1}]'); 
    } else if(restType.contains('VideoDataServer/syncPeopleData')) {
      res.setBody('{\"status\":\"success\"}'); 
    } else {
      res.setBody(resBody);
    }
    res.setStatusCode(resStatusCode);
    res.setStatus(resStatus);
    return res;    
    }
}