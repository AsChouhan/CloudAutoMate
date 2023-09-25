public with sharing class V1ToV2PageRedirectorController {
    public PageReference redirectToV2() {
        String currentPageName = PageContext.currentPageName;
        Map<String, String> urlParameters = ApexPages.currentPage().getParameters();
        String contentId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('Id'));
        if(String.isBlank(contentId)) {
            contentId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('contentId'));
        }
        String siteId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('siteId'));
        String userId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('userId'));
        String topicId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('topicId'));
        
        //CRM Libray
        String libraryId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('libraryId'));
        
        //Box Folders
        String boxFolderId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('boxFolderId'));
        String rootFolderId = SIMPESAPI.encoder().SFDC_JSENCODE(urlParameters.get('rootFolderId'));
        String fileId = urlParameters.get('fileId');
        
        //Intranet Folders
        String folderId = urlParameters.get('folderId');
        String cvId = urlParameters.get('cvId');
        String FId = urlParameters.get('FId');
        
        PageReference pgref;
        if ('Home'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/');
            
        } else if ('Dashboard'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId);            
            
        } else if ('HomeMyDashboard'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/');
            
        } else if ('SiteDetails'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/about');  
        
        // Content Listing Pages
        } else if('SiteNews'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/pages'); 
            
        } else if('News'.equalsIgnoreCase(currentPageName)) {
            if(String.isNotBlank(siteId)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/pages'); 
            } 
        } else if('Events'.equalsIgnoreCase(currentPageName)) {
            if(String.isNotBlank(siteId)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/events'); 
            } 
        } else if ('articleindex'.equalsIgnoreCase(currentPageName)){
            if(String.isNotBlank(siteId)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/pages'); 
            } 
        } else if ('albums'.equalsIgnoreCase(currentPageName)){
            if(String.isNotBlank(siteId)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/albums'); 
            } 
        } else if ('videos'.equalsIgnoreCase(currentPageName)){
            if(String.isNotBlank(siteId)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/albums'); 
            } 
        //Content Detail Pages    
        } else if('NewsDetail'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.PageRedirector;
        } else if('SiteNewsDetail'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.PageRedirector;
        } else if('ArticleDetail'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.PageRedirector;
        } else if('EventDetail'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.PageRedirector;
        } else if('AlbumDetail'.equalsIgnoreCase(currentPageName)){
            pgref = Page.PageRedirector;
        } else if('VideoDetail'.equalsIgnoreCase(currentPageName)){
            pgref = Page.PageRedirector;
        }  else if('BlogDetail'.equalsIgnoreCase(currentPageName)){
            pgref = Page.PageRedirector;

        // Topic - Content Pages
        } else if('TopicAlbums'.equalsIgnoreCase(currentPageName) ||
                    'TopicPages'.equalsIgnoreCase(currentPageName) ||
                    'TopicEvents'.equalsIgnoreCase(currentPageName) ||
                    'TopicBlogPosts'.equalsIgnoreCase(currentPageName)){

            pgref = Page.app;
            pgref.getParameters().put('u','/topic/' + topicId + '/content');
        } else if('TopicFeed'.equalsIgnoreCase(currentPageName)){

            pgref = Page.app;
            pgref.getParameters().put('u','/topic/' + topicId + '/feed');
        } else if('TopicFiles'.equalsIgnoreCase(currentPageName)){
            
            pgref = Page.app;
            pgref.getParameters().put('u','/topic/' + topicId);
        //File Listing Pages    
        } else if('Files'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.MyFiles;
            
        } else if ('boxlibrary'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/files'); 
        
        } else if ('library'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/files');   

        } else if ('internalLibrary'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + siteId + '/files'); 

        //File Detail Pages
        } else if ('libraryDetail'.equalsIgnoreCase(currentPageName)){
            pgref = Page.FileDetail;
        
        } else if ('BoxFileDetail'.equalsIgnoreCase(currentPageName)){
            pgref = Page.FileDetail;
        } else if('ReportingStructure'.equalsIgnoreCase(currentPageName)){
            
            pgref = Page.app;
            pgref.getParameters().put('u','/orgchart/' + urlParameters.get('profileId'));
                
        } else if('NotificationSettings'.equalsIgnoreCase(currentPageName) || 'MySettingsEmail'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/my-settings/notifications/email');

        } else if('ManageContent'.equalsIgnoreCase(currentPageName) || 'ManageContent'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/manage/content');

        } else if('Notification'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.Notifications;
        } else if('HomeLatest'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/error/404');
        } else if('HomeFeed'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/feed');
        } else if('MyFiles'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/people/' + urlParameters.get('profileId'));
        } else if('ProfileSites'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/people/' + urlParameters.get('profileId'));
        } else if('ProfileFeed'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/people/' + urlParameters.get('profileId'));
            
        } else if('ProfileAbout'.equalsIgnoreCase(currentPageName) || 'AboutUser'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
                pgref.getParameters().put('u','/people/' + urlParameters.get('profileId'));
        } else if('Favorites'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/favorites');
        } else if('ProfileCalendar'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/people/' + urlParameters.get('profileId') + '/calendar/all');
        } else if('ProfileBlog'.equalsIgnoreCase(currentPageName) || 'UserBlogs'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/people/' + urlParameters.get('profileId') + '/blogposts');
        } else if('ProfileConnections'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/people/' + urlParameters.get('profileId'));
        } else if('ProfileMustReads'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/people/' + urlParameters.get('profileId') + '/must-reads');
        } else if('ProfileOrgChart'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/orgchart/' + urlParameters.get('profileId'));
        } else if('SiteDashboard'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + urlParameters.get('siteId') + '/dashboard');               
        } else if('SiteEvents'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            if(urlParameters.containsKey(siteId)){
                pgref.getParameters().put('u','/site/' + urlParameters.get('siteId') + '/events');  
            } else {
                pgref.getParameters().put('u',urlParameters.get('u'));      
            }               
        } else if('SiteFeed'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + urlParameters.get('siteId') + '/feed');                
        } else if('SitePages'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + urlParameters.get('siteId') + '/pages');               
        } else if('SiteAlbums'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + urlParameters.get('siteId') + '/albums');              
        } else if('SiteFiles'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + urlParameters.get('siteId') + '/files');               
        } else if('SiteAbout'.equalsIgnoreCase(currentPageName)){
            pgref = Page.app;
            pgref.getParameters().put('u','/site/' + urlParameters.get('siteId') + '/about');               
        } else if('ManageApplicationFeed'.equalsIgnoreCase(currentPageName)) {
            pgref = Page.app;
            pgref.getParameters().put('u','/manage/app/defaults/home-feed');
        } else {
            pgref = Page.app;
            pgref.getParameters().put('u','/error/404');
        }
        
        
        
        if(String.isNotBlank(contentId)) {
            pgref.getParameters().put('contentId',contentId);
            pgref.getParameters().put('pageToRedirect','ContentDetailPage');
        }
        if(String.isNotBlank(siteId)) {
            pgref.getParameters().put('siteId',siteId);
        }
        if(String.isNotBlank(userId)) {
            pgref.getParameters().put('profileId',userId);
        }
        
        if(String.isNotBlank(fileId)) {
            pgref.getParameters().put('fileId',fileId);
        } else if(String.isNotBlank(FId)) {
            pgref.getParameters().put('fileId',FId);
        }
        
        if('library'.equalsIgnoreCase(currentPageName) && String.isNotBlank(libraryId)) {
            String hashParam = 'provider=crm&directory=' + libraryId;
            pgref.setAnchor(hashParam);
        }
        
        if('libraryDetail'.equalsIgnoreCase(currentPageName) && String.isNotBlank(libraryId)) {
            String queryStr = 'select contentDocumentId from contentVersion where id=:libraryId';
            
            if(SimpplrContext.isCommunitiesEnabled){
                queryStr += ' AND networkid = null';
            }
            
            List<ContentVersion> listOfContentVersion = Database.query(queryStr);
            if(!listOfContentVersion.isEmpty()) {
                pgref.getParameters().put('fileId',listOfContentVersion[0].contentDocumentId);
                List<ContentWorkspaceDoc> cwDocList = [select ContentWorkspaceId from ContentWorkspaceDoc where ContentDocumentId =:listOfContentVersion[0].contentDocumentId WITH SECURITY_ENFORCED];
                if(!cwDocList.isEmpty()) {
                    pgref.getParameters().put('directory',cwDocList[0].ContentWorkspaceId);
                }
            }
        }

        if ('boxlibrary'.equalsIgnoreCase(currentPageName)){
            if(String.isNotBlank(boxFolderId)) {
                String hashParam = 'directory=' + boxFolderId;
                if(String.isNotBlank(rootFolderId)) {
                    hashParam = hashParam + '&rootDirectory=' + rootFolderId;
                }
                pgref.setAnchor(hashParam);
            }
        }
        
        if ('BoxFileDetail'.equalsIgnoreCase(currentPageName)){
            if(String.isNotBlank(boxFolderId)) {
                pgref.getParameters().put('directory',boxFolderId);
            }
            if(String.isNotBlank(rootFolderId)) {
                pgref.getParameters().put('rootDirectory',rootFolderId);
            }
        }
        
        if ('internalLibrary'.equalsIgnoreCase(currentPageName)){
            if(String.isNotBlank(libraryId)) {
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', libraryId);
                String folderQuery = 'Select Id from Folder__c where External_Folder_Id__c=:soqlParam1';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
                if(!listOfFolders.isEmpty()) {
                    String hashParam = 'directory=' + listOfFolders[0].id;
                    pgref.setAnchor(hashParam);
                }
            }
        }
        
        if ('filedetail'.equalsIgnoreCase(currentPageName) && String.isNotBlank(cvId)){
            String queryStr = 'select contentDocumentId from contentVersion where id=:cvId';
            
            if(SimpplrContext.isCommunitiesEnabled){
                queryStr += ' AND networkid = null';
            }
            
            List<ContentVersion> listOfContentVersion = Database.query(queryStr);
            if(!listOfContentVersion.isEmpty()) {
                pgref.getParameters().put('fileId',listOfContentVersion[0].contentDocumentId);
                if(String.isNotBlank(folderId)) {
                    Map<String, Object> soqlParamMap = new Map<String, Object>();
                    soqlParamMap.put('soqlParam1', folderId);
                    String folderQuery = 'Select Id from Folder__c where External_Folder_Id__c=:soqlParam1';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
                    if(!listOfFolders.isEmpty()) {
                        pgref.getParameters().put('directory',listOfFolders[0].id);
                    }
                }
            }
        }
        //pgref.getParameters().put('oldLink','1');
        pgref.setRedirect(true);
        return pgref;
    }
    
    public pageReference redirectToNewFilePage() {
        PageReference pageRef = Page.FileDetail;
        
        String currentPageName = PageContext.currentPageName;
        Map<String, String> urlParameters = ApexPages.currentPage().getParameters();
        pageRef.getParameters().putAll(urlParameters);
        pageRef.setRedirect(true);
        return pageRef;
    }   
}