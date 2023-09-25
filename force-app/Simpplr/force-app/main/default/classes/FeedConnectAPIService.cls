/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FeedConnectAPIService {
    public static Integer recentCommentCount = 3;
    private static String feedFilesVideoFolderId;
    private static String feedFilesVideoSiteId;
    private static Map<id, id> peopeIdUserIdMap = new Map<id, id>();
    private static Map<id, id> siteIdChatterGroupIdMap = new Map<id, id>();
    private static Set<id> mentionedPeopleIdsSet = new Set<id>();
    private static Set<id> mentionedSiteIdsSet = new Set<id>();


    public static Map<String,User> getMentionedUserMap(Set<String> userIdSet) {
        Map<String,User> mapOfUser = new Map<String, User>([SELECT Id, Name FROM User WHERE ID IN:userIdSet AND
            		(UserType = 'Standard' OR UserType = 'csnonly')]);
        return mapOfUser;
    }
    
	public static Map<String,CollaborationGroup> getMentionedCollGroupMap(Set<String> cgIdSet) {
        Map<String,CollaborationGroup> mapOfCollaborationGroup = new Map<String, CollaborationGroup>([SELECT Id, Name, CollaborationType FROM
            		CollaborationGroup WHERE ID IN:cgIdSet]);
        return mapOfCollaborationGroup;
    }
     
    /** Method to get feedElementWrapper by calling API **/
    public static ConnectApi.FeedElementPage getFeedElementsFromFeed (String communityIdArg, String feedTypeArg, 
            String subjectIdArg, String pageParamArg, Integer pageSizeArg, String sortParamArg) {
                 
        ConnectApi.FeedElementPage feedElementPageObj;
        Integer recentCommentCount = 3;
        ConnectApi.FeedDensity feedDensityObj = SimpplrContext.showTrackChangesFeedPosts ? ConnectApi.FeedDensity.AllUpdates 
                                                                            : ConnectApi.FeedDensity.FewerUpdates;       
        if (sortParamArg == 'activity') {
        
            if (feedTypeArg == 'Record') { 
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Record, subjectIdArg, recentCommentCount, feedDensityObj,  pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            
            } else if (feedTypeArg == 'Bookmarks') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Bookmarks, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            
            } else if (feedTypeArg == 'To') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.To, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
                                    
            } else if (feedTypeArg == 'People') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.People, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            
            } else if (feedTypeArg == 'Files') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Files, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            
            } else if (feedTypeArg == 'Topic') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Topics, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            
            } else if (feedTypeArg == 'UserProfile') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.UserProfile, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            
            } else if (feedTypeArg == 'Company') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Company, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            
            } else if (feedTypeArg == 'News'){
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.News, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc);
            }
        
        } else {
            
            if (feedTypeArg == 'Record') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Record, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            
            } else if (feedTypeArg == 'Bookmarks') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Bookmarks, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            
            } else if (feedTypeArg == 'To') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.To, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
                                    
            } else if (feedTypeArg == 'People') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.People, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            
            } else if (feedTypeArg == 'Files') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Files, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            
            } else if (feedTypeArg == 'Topic') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Topics, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            
            } else if (feedTypeArg == 'UserProfile') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.UserProfile, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            
            } else if (feedTypeArg == 'Company') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.Company, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            
            } else if (feedTypeArg == 'News') {
                feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(communityIdArg, 
                        ConnectApi.FeedType.News, subjectIdArg, recentCommentCount, feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc);
            }
        
        }
        
        return feedElementPageObj;
    }
    
    /**Method to like Comment**/
    public static ConnectApi.ChatterLike likeComment (String communityIdArg, String commentIdArg, 
    		String feedElementIdArg) {
        String currentUserId = UserContext.getCurrentUserInfo.id;
        List<Like__c> likesForFeedComment = [select id from Like__c where 
                Feed_Item_Comment_Id__c =:commentIdArg AND 
                Feed_Item_Id__c=:feedElementIdArg AND people__c =:currentUserId WITH SECURITY_ENFORCED limit 1];
                ConnectApi.ChatterLike chatterLikeObj;
                if(!Test.isRunningTest()){
                    chatterLikeObj = ConnectApi.ChatterFeeds.likeComment(communityIdArg, commentIdArg);
                }

        if (likesForFeedComment.size() == 0) {
            NotificationDispatcher.sendCommentLikeNotificationAndEmail(commentIdArg, feedElementIdArg);
        }

        return chatterLikeObj;
    }
    
    /**Method to like Feed Elements **/  
    public static ConnectApi.ChatterLike likeFeedElement (String communityIdArg, String feedElementIdArg) {
        ConnectApi.ChatterLike chatterLikeObj;
        if(!Test.isRunningTest()){            
            chatterLikeObj = ConnectApi.ChatterFeeds.likeFeedElement(communityIdArg, feedElementIdArg);
        }
        String currentUserId = UserContext.getCurrentUserInfo.id;
        List<Like__c> likesForFeedPost = [select id from Like__c where 
                Feed_Item_Id__c =:feedElementIdArg AND people__c =:currentUserId AND Is_Deleted__c =:false WITH SECURITY_ENFORCED limit 1];

        if (likesForFeedPost.size() == 0) {
            NotificationDispatcher.sendPostLikeNotificationAndEmail(feedElementIdArg);
        }

        return chatterLikeObj;
    }
    
    /** Method to get like obj for specified likeId **/
    public static ConnectApi.ChatterLike getLike (String communityIdArg, String likeIdArg) {
        ConnectApi.ChatterLike chatterLikeObj = ConnectApi.ChatterFeeds.getLike(communityIdArg, likeIdArg);
        return chatterLikeObj;
    }
    
    
    /**Method to get like obj for specified comment **/
    public static ConnectApi.ChatterLikePage getLikesForComment (String communityIdArg, String commentIdArg, 
            Integer pageParamArg, Integer pageSizeArg) {
        ConnectApi.ChatterLikePage chatterLikePageObj = ConnectApi.ChatterFeeds.getLikesForComment(communityIdArg, 
                commentIdArg, pageParamArg, pageSizeArg);
        return chatterLikePageObj;
    }
    
    
    /**OverLoaded Method to get like obj for specified comment **/
    public static ConnectApi.ChatterLikePage getLikesForComment (String communityIdArg, String commentIdArg) {
        ConnectApi.ChatterLikePage chatterLikePageObj = ConnectApi.ChatterFeeds.getLikesForComment(communityIdArg, 
                commentIdArg);
        //TODO Implement Method
        return chatterLikePageObj;
    }
    
    /**Method to get like obj for specified FeedElement**/
    public static ConnectApi.ChatterLikePage getLikesForFeedElement (String communityIdArg, String feedElementIdArg) {
        ConnectApi.ChatterLikePage chatterLikePageObj;
        chatterLikePageObj = ConnectApi.ChatterFeeds.getLikesForFeedElement(communityIdArg, feedElementIdArg);
        return chatterLikePageObj;
    }
    
    /**OverLoaded Method to get like obj for specified FeedElement **/
    public static ConnectApi.ChatterLikePage getLikesForFeedElement (String communityIdArg, String feedElementIdArg, 
            Integer pageParamArg, Integer pageSizeArg) {
        ConnectApi.ChatterLikePage chatterLikePageObj;
        chatterLikePageObj = ConnectApi.ChatterFeeds.getLikesForFeedElement(communityIdArg, feedElementIdArg, 
                pageParamArg, pageSizeArg);
        return chatterLikePageObj;
    }
    
    /** Get Comments for feed Element **/
    public static ConnectApi.CommentPage getCommentsForFeedElement (String communityIdArg, String feedElementIdArg) {
            ConnectApi.CommentPage commentPageObj;
        commentPageObj = ConnectApi.ChatterFeeds.getCommentsForFeedElement(communityIdArg, feedElementIdArg);
        return commentPageObj;
    }
    
    /**Overloaded Get Comments for feed Element **/
    public static ConnectApi.CommentPage getCommentsForFeedElement (String communityIdArg, String feedElementIdArg, 
            String pageParamArg, Integer pageSizeArg) {
        ConnectApi.CommentPage commentPageObj;
        commentPageObj = ConnectApi.ChatterFeeds.getCommentsForFeedElement(communityIdArg, feedElementIdArg, 
                pageParamArg, pageSizeArg);
        return commentPageObj;
    }
    
    /**Method to Post comment to FeedElement for text **/
    public static ConnectApi.Comment postCommentToFeedElement(String communityIdArg, String feedElementIdArg, 
            String commentArg, String bodyJsonArg, List<Criteria.ExternalFileWrapper> externalFiles){
        String textToProcess = commentArg;
        String processedStr = '';
        List<File__c> listOfFileToInsert = new List<File__c>();
        
        if (textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0) { // checking if google/ box file is present. 
            String extFilesStr =  textToProcess.substring(textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
                2, textToProcess.length()); // External file string extracted 
            processedStr = commentArg.substring(0, commentArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR)); // textbody without ext files
            List<String> listOfExtFile = new List<String>();
            listOfExtFile= extFilesStr.split('\n'); // Files are seprated by newline 
            
            if (!listOfExtFile.isEmpty()) {
                processedStr = processedStr + ServiceConstants.FEED_EXT_FILE_SEPRATOR;
                
                for (String singleExtFile: listOfExtFile) {
                    List<String> listOfSingleExtFileProp = new List<String>();
                    listOfSingleExtFileProp = singleExtFile.split('\\|'); // File properties are seprated by | symbol 
                    processedStr = processedStr + '\n'; // adding new line for new file
                    
                    if (listOfSingleExtFileProp.size() > 5) {
                        File__c fileObj = convertToFileObject(listOfSingleExtFileProp);
                        processedStr = processedStr + listOfSingleExtFileProp[5].trim() + '&fileName=' + EncodingUtil.urlEncode(listOfSingleExtFileProp[0].trim(), 'UTF-8') +'&size='+ Integer.valueOf(listOfSingleExtFileProp[2].trim()); // adding url to text
                        listOfFileToInsert.add(fileObj);
                    }
                    
                }
                
            }
        
        } else {
            if(externalFiles!=null && externalFiles.size()>0){
                for(Criteria.ExternalFileWrapper externalfile: externalFiles){
                    File__c fileObj = convertToFileObjFromExternalFileWrapper(externalfile);
                    listOfFileToInsert.add(fileObj);
                }
            }
            processedStr = commentArg;
        }
        
        ConnectApi.CommentInput commentInputObj = new ConnectApi.CommentInput();
        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            commentInputObj.body = processToSegments(processedStr, SimpplrContext.isFeedRichTextEnabled, false);
        }else{
            ConnectApi.MessageBodyInput inputBody =  processToSegmentsV1(bodyJsonArg, SimpplrContext.isFeedRichTextEnabled, false);

            List<ConnectApi.MessageSegmentInput> externalFileSegments = getExternalFilesSegments(externalFiles);
            
            if(externalFileSegments!=null && externalFileSegments.size()>0){
                inputBody.messageSegments.addAll(externalFileSegments);    
            }
            commentInputObj.body = inputBody;
        }
        
        ConnectApi.Comment commentObj = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityIdArg, 
                feedElementIdArg, commentInputObj, null);
                
        if (!listOfFileToInsert.isEmpty()) {
            Boolean isInitialize = false;
            for (File__c fileObj: listOfFileToInsert) {
                fileObj.Feed_Comment__c = commentObj.id; // Adding feedId to fileobj
                fileObj.Feed_Item__c = feedElementIdArg;
                if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                    if(!isInitialize) {
                        initializeFeedFilesVideoParams(commentObj.parent.id);
                    }
                    fileObj.Folder__c = feedFilesVideoFolderId;
                    fileObj.Site__c = feedFilesVideoSiteId;

                    Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
                    if(captionLanguageId != null){
                        
                        fileObj.Video_Caption_Language__c = String.valueOf(captionLanguageId);
                    }
                }
                if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileObj.Repository__c)) {
                    fileObj.Sp_Instance_Id__c = UserContext.spInstanceId;
                    fileObj.External_Folder_Id__c = Utility.getParamValueFromUrl(fileObj.Url__c, 'rootDirectory');
                }
            }
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listOfFileToInsert,new List<Schema.SObjectField>{
                File__c.Title__c,
                File__c.External_Id__c,
                File__c.Size__c,
                File__c.MIME_Type__c,
                File__c.Repository__c,
                File__c.thumbnail_url__c,
                File__c.Author__c,
                File__c.Url__c,
                File__c.Feed_Item__c,
                File__c.Folder__c,
                File__c.Site__c,
                File__c.Video_Caption_Language__c,
                File__c.Feed_Comment__c,
                File__c.Sp_Instance_Id__c,
                File__c.External_Folder_Id__c
            });
        }
        
        return commentObj;
    }
    
    public static File__c convertToFileObjFromExternalFileWrapper(Criteria.ExternalFileWrapper externalFile){
        File__c fileObj = new File__c();
        fileObj.Title__c = externalFile.title;
		fileObj.External_Id__c = externalFile.fileId;
		fileObj.Size__c = externalFile.size;
		fileObj.MIME_Type__c = externalFile.type;
        fileObj.Repository__c = externalFile.context;
        if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(externalFile.context)){
            fileObj.thumbnail_url__c = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileObj.External_Id__c +'/width/550/height/480';
            File__c file = FileDao.getFileRecordDetails(externalFile.fileId.trim());
            if(file != null && !String.isBlank(file.Author__c)){
                fileObj.Author__c = file.Author__c;
                fileObj.MIME_Type__c = file.MIME_Type__c;
            }
            else {
                fileObj.Author__c = UserContext.peopleId;
            }
        }
		fileObj.Url__c = externalFile.url;
		return fileObj;

    }

    private static File__c convertToFileObject(List<String> listOfFileProp) {

    		File__c fileObj = new File__c();
		fileObj.Title__c = listOfFileProp[0].trim();
		fileObj.External_Id__c = listOfFileProp[1].trim();
		fileObj.Size__c = Integer.valueOf(listOfFileProp[2].trim());
		fileObj.MIME_Type__c = listOfFileProp[3].toLowerCase().trim();
        fileObj.Repository__c = listOfFileProp[4].trim();
        if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(listOfFileProp[4].trim())){
            fileObj.thumbnail_url__c = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileObj.External_Id__c +'/width/550/height/480';
            File__c file = FileDao.getFileRecordDetails(listOfFileProp[1].trim());
            if(file != null && !String.isBlank(file.Author__c)){
                fileObj.Author__c = file.Author__c;
                fileObj.MIME_Type__c = file.MIME_Type__c;
            }
            else {
                fileObj.Author__c = UserContext.peopleId;
            }
        }
		fileObj.Url__c = listOfFileProp[5].trim();
		return fileObj;
    }
    
    /**Overloaded Method to Post comment to FeedElement for Attachment **/
    public static ConnectApi.Comment postCommentToFeedElement (String communityIdArg, String feedElementIdArg, 
            String contentDocumentIdArg, String commentArg, String bodyJsonArg, List<Criteria.ExternalFileWrapper> externalFiles) {
        String textToProcess = commentArg;
        String processedStr = '';
        List<File__c> listOfFileToInsert = new List<File__c>();
        
        if (textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0) { // checking if google/ box file is present. 
            String extFilesStr =  textToProcess.substring(textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
                2, textToProcess.length()); // External file string extracted 
            processedStr = commentArg.substring(0, commentArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR)); // textbody without ext files
            List<String> listOfExtFile = new List<String>();
            listOfExtFile= extFilesStr.split('\n'); // Files are seprated by newline 
            
            if (!listOfExtFile.isEmpty()) {
                processedStr = processedStr + ServiceConstants.FEED_EXT_FILE_SEPRATOR;
                
                for (String singleExtFile: listOfExtFile) {
                    List<String> listOfSingleExtFileProp = new List<String>();
                    listOfSingleExtFileProp = singleExtFile.split('\\|'); // File properties are seprated by | symbol 
                    processedStr = processedStr + '\n'; // adding new line for new file
                    
                    if (listOfSingleExtFileProp.size() > 5) {
                        File__c fileObj = convertToFileObject(listOfSingleExtFileProp);
                        processedStr = processedStr + listOfSingleExtFileProp[5].trim() + '&fileName=' + EncodingUtil.urlEncode(listOfSingleExtFileProp[0].trim(), 'UTF-8') +'&size='+ Integer.valueOf(listOfSingleExtFileProp[2].trim()); // adding url to text
                        listOfFileToInsert.add(fileObj);
                    }
                    
                }
                
            }
        
        } else {
            if(externalFiles!=null && externalFiles.size()>0){
                for(Criteria.ExternalFileWrapper externalfile: externalFiles){
                    File__c fileObj = convertToFileObjFromExternalFileWrapper(externalfile);
                    listOfFileToInsert.add(fileObj);
                }
            }
            processedStr = commentArg;
        }
        
        ConnectApi.BinaryInput binaryInputObj; 
        ConnectApi.CommentInput commentInputObj = new ConnectApi.CommentInput();
        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            commentInputObj.body = processToSegments(processedStr, SimpplrContext.isFeedRichTextEnabled, false);
        }else{
            ConnectApi.MessageBodyInput inputBody =  processToSegmentsV1(bodyJsonArg, SimpplrContext.isFeedRichTextEnabled, false);
            List<ConnectApi.MessageSegmentInput> externalFileSegments = getExternalFilesSegments(externalFiles);
            
            if(externalFileSegments!=null && externalFileSegments.size()>0){
                inputBody.messageSegments.addAll(externalFileSegments);    
            }
            commentInputObj.body = inputBody;
        }
        
        
        if (contentDocumentIdArg != null && contentDocumentIdArg.trim().length() > 0) {
            ConnectApi.CommentCapabilitiesInput commentCapabilitiesInputObj = new ConnectApi.CommentCapabilitiesInput();
            ConnectApi.ContentCapabilityInput contentCapabilityInputObj = new ConnectApi.ContentCapabilityInput();
            
            contentCapabilityInputObj.contentDocumentId = contentDocumentIdArg;
            commentCapabilitiesInputObj.content = contentCapabilityInputObj;
            commentInputObj.capabilities = commentCapabilitiesInputObj;
            
        }
            
        ConnectApi.Comment commentObj = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityIdArg, 
                feedElementIdArg, commentInputObj, binaryInputObj);
                
        if (!listOfFileToInsert.isEmpty()) {
            Boolean isInitialize = false;
            for (File__c fileObj: listOfFileToInsert) {
                fileObj.Feed_Comment__c = commentObj.id; // Adding feedId to fileobj
                if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                    if(!isInitialize) {
                        initializeFeedFilesVideoParams(commentObj.parent.id);
                    }
                    fileObj.Folder__c = feedFilesVideoFolderId;
                    fileObj.Site__c = feedFilesVideoSiteId;

                    Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
                    if(captionLanguageId != null){
                        
                        fileObj.Video_Caption_Language__c = String.valueOf(captionLanguageId);
                    }
                }
                if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileObj.Repository__c)) {
                    fileObj.Sp_Instance_Id__c = UserContext.spInstanceId;
                    fileObj.External_Folder_Id__c = Utility.getParamValueFromUrl(fileObj.Url__c, 'rootDirectory');
                }
            }
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listOfFileToInsert,new List<Schema.SObjectField>{
                File__c.Title__c,
                File__c.External_Id__c,
                File__c.Size__c,
                File__c.MIME_Type__c,
                File__c.Repository__c,
                File__c.thumbnail_url__c,
                File__c.Author__c,
                File__c.Url__c,
                File__c.Feed_Item__c,
                File__c.Folder__c,
                File__c.Site__c,
                File__c.Video_Caption_Language__c,
                File__c.Sp_Instance_Id__c,
                File__c.External_Folder_Id__c
            });
        }
        
        return commentObj;
    }

    /**Method to post feed Element without Capability without recognition */
    public static ConnectApi.FeedElement postFeedElementWithOutCapability (String communityIdArg, 
            String subjectIdArg, String feedElementType, String textArg, String bodyJsonArg, List<Criteria.ExternalFileWrapper>  externalFiles) {
        return postFeedElementWithOutCapability (communityIdArg, subjectIdArg, feedElementType, textArg, bodyJsonArg, false, externalFiles);
    }
    
    /**Method to post feed Element without Capability with recognition**/
    public static ConnectApi.FeedElement postFeedElementWithOutCapability (String communityIdArg, 
            String subjectIdArg, String feedElementType, String textArg, String bodyJsonArg, Boolean isRecognitionPost,List<Criteria.ExternalFileWrapper>  externalFiles) {
        String textToProcess = textArg;
        String processedStr = '';
        List<File__c> listOfFileToInsert = new List<File__c>();

        if (textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0) { // checking if google/ box file is present. 
            String extFilesStr =  textToProcess.substring(textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
                2, textToProcess.length()); // External file string extracted 
            processedStr = textArg.substring(0, textArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR)); // textbody without ext files
            List<String> listOfExtFile = new List<String>();
            listOfExtFile= extFilesStr.split('\n'); // Files are seprated by newline 
            
            if (!listOfExtFile.isEmpty()) {
                processedStr = processedStr + ServiceConstants.FEED_EXT_FILE_SEPRATOR;
                
                for (String singleExtFile: listOfExtFile) {
                    List<String> listOfSingleExtFileProp = new List<String>();
                    listOfSingleExtFileProp = singleExtFile.split('\\|'); // File properties are seprated by | symbol 
                    processedStr = processedStr + '\n'; // adding new line for new file
                    
                    if (listOfSingleExtFileProp.size() > 5) {
                        File__c fileObj = convertToFileObject(listOfSingleExtFileProp);
                        processedStr = processedStr + listOfSingleExtFileProp[5].trim()  + '&fileName=' + EncodingUtil.urlEncode(listOfSingleExtFileProp[0].trim(), 'UTF-8') +'&size='+ Integer.valueOf(listOfSingleExtFileProp[2].trim()); // adding url to text
                        listOfFileToInsert.add(fileObj);
                    }
                    
                }
                
            }
        
        } else {
            //for mobile
            if(externalFiles!=null && externalFiles.size()>0){
                for(Criteria.ExternalFileWrapper externalfile: externalFiles){
                    File__c fileObj = convertToFileObjFromExternalFileWrapper(externalfile);
                    listOfFileToInsert.add(fileObj);
                }
            }
            processedStr = textArg;	
        }
        
        ConnectApi.FeedItemInput feedElementInputObj = new ConnectApi.FeedItemInput(); 
        feedElementInputObj.subjectId = subjectIdArg;
        feedElementInputObj.feedElementType = ConnectApi.FeedElementType.feedItem;

        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            feedElementInputObj.body = processToSegments(processedStr, SimpplrContext.isFeedRichTextEnabled, isRecognitionPost);  
          
        }else{
            ConnectApi.MessageBodyInput inputBody =  processToSegmentsV1(bodyJsonArg, SimpplrContext.isFeedRichTextEnabled, isRecognitionPost);
            List<ConnectApi.MessageSegmentInput> externalFileSegments = getExternalFilesSegments(externalFiles);
            
            if(externalFileSegments!=null && externalFileSegments.size()>0){
                inputBody.messageSegments.addAll(externalFileSegments);    
            }
            feedElementInputObj.body = inputBody;
 
        }     
        
        ConnectApi.FeedElement feedElementObj = !Test.isRunningTest() ? ConnectApi.ChatterFeeds.postFeedElement(communityIdArg, 
                feedElementInputObj) : TestHelper.getFeedElement('https://apex.app/');
        
        Set<String> entryIds = new Set<String>();
        if (!listOfFileToInsert.isEmpty()) {
            Boolean isInitialize = false;
            for (File__c fileObj: listOfFileToInsert) {
                fileObj.Feed_Item__c = feedElementObj.id; // Adding feedId to fileobj
                if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                    if(!isInitialize) {
                        initializeFeedFilesVideoParams(feedElementObj.parent.id);
                    }
                    fileObj.Folder__c = feedFilesVideoFolderId;
                    fileObj.Site__c = feedFilesVideoSiteId;

                    Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
                    if(captionLanguageId != null){
                        
                        fileObj.Video_Caption_Language__c = String.valueOf(captionLanguageId);
                    }

                    if(String.isNotBlank(fileObj.External_Id__c)){
                        entryIds.add(fileObj.External_Id__c);
                    }
                }
                if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileObj.Repository__c)) {
                    fileObj.Sp_Instance_Id__c = UserContext.spInstanceId;
                    fileObj.External_Folder_Id__c = Utility.getParamValueFromUrl(fileObj.Url__c, 'rootDirectory');
                }
            }
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listOfFileToInsert,new List<Schema.SObjectField>{
                File__c.Title__c,
                File__c.External_Id__c,
                File__c.Size__c,
                File__c.MIME_Type__c,
                File__c.Repository__c,
                File__c.thumbnail_url__c,
                File__c.Author__c,
                File__c.Url__c,
                File__c.Feed_Item__c,
                File__c.Folder__c,
                File__c.Site__c,
                File__c.Video_Caption_Language__c,
                File__c.Sp_Instance_Id__c,
                File__c.External_Folder_Id__c
            });

            if(entryIds.size() > 0){
                Map<String,Integer> siteShareCountForEntry = new Map<String,Integer>();
                List<File__c> files = [SELECT Id, External_id__c, Site__c FROM File__c where External_id__c IN :entryIds AND Site__c != null AND Repository__c = 'native_video' AND Is_deleted__c = false WITH SECURITY_ENFORCED];
                for(File__c file : files){
                    Integer count = 1;
                    if(siteShareCountForEntry.containsKey(file.Site__c)){
                        count = siteShareCountForEntry.get(file.Site__c)+1;
                    }
                    siteShareCountForEntry.put(file.Site__c,count);
                }
                Map<String, Set<String>> fileExternalIdVsSiteIdMap = new Map<String, Set<String>>();
                for(File__c file: listOfFileToInsert){
                    if(siteShareCountForEntry.containsKey(file.Site__c)){
                        if(siteShareCountForEntry.get(file.Site__c) == 1){

                            if(fileExternalIdVsSiteIdMap.containsKey(file.External_id__c)){

                                fileExternalIdVsSiteIdMap.get(file.External_id__c).add(file.Site__c);
                            } else {

                                fileExternalIdVsSiteIdMap.put(file.External_id__c, new Set<String>{file.Site__c});
                            }
                        }
                    }
                }
                if(fileExternalIdVsSiteIdMap.isEmpty() == false){
                    
                    VideoDao.addVideoToCategoryInFuture(JSON.serialize(fileExternalIdVsSiteIdMap));
                }
            }
        }
                
        return feedElementObj;
    } 
    
    

    /**Method to post feed Element with Link Capability **/
    public static ConnectApi.FeedElement postFeedElementWithLinkCapability (String communityIdArg, 
            String subjectIdArg, String feedElementTypeArg, String urlArg, String urlNameArg, String textToPostArg, String bodyJsonArg) {
        ConnectApi.FeedItemInput feedElementInputObj = new ConnectApi.FeedItemInput(); 
        ConnectApi.LinkCapabilityInput newLinkCapabilityObj = new ConnectApi.LinkCapabilityInput();
        newLinkCapabilityObj.url = urlArg;
        newLinkCapabilityObj.urlName = urlNameArg;
        ConnectApi.FeedElementCapabilitiesInput capabilityInputObj =  new ConnectApi.FeedElementCapabilitiesInput();
        capabilityInputObj.Link = newLinkCapabilityObj;
        feedElementInputObj.subjectId = subjectIdArg;
        feedElementInputObj.feedElementType = ConnectApi.FeedElementType.feedItem;
        feedElementInputObj.capabilities = capabilityInputObj;
        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            feedElementInputObj.body = processToSegments(textToPostArg, SimpplrContext.isFeedRichTextEnabled, false);
        }else{
            feedElementInputObj.body = processToSegmentsV1(bodyJsonArg, SimpplrContext.isFeedRichTextEnabled, false);
        }
        
        ConnectApi.FeedElement feedElementObj = ConnectApi.ChatterFeeds.postFeedElement(communityIdArg, 
                feedElementInputObj);
        
        return feedElementObj;
    }
    
    /**Method to post feed element with poll capability**/
    public static ConnectApi.FeedElement postFeedElementWithPollCapability (String communityIdArg, 
            String subjectIdArg, String feedElementTypeArg, List<String> listOfPollChoicesArg,
            String pollMsgArg, String bodyJsonArg) {
        ConnectApi.FeedItemInput feedElementInputObj = new ConnectApi.FeedItemInput();
        ConnectApi.PollCapabilityInput newPollCapabilityObj = new ConnectApi.PollCapabilityInput();
        newPollCapabilityObj.choices = listOfPollChoicesArg;
        ConnectApi.FeedElementCapabilitiesInput capabilityInputObj =  new ConnectApi.FeedElementCapabilitiesInput();
        capabilityInputObj.poll = newPollCapabilityObj;
        feedElementInputObj.subjectId = subjectIdArg;
        feedElementInputObj.feedElementType = ConnectApi.FeedElementType.feedItem;
        feedElementInputObj.capabilities = capabilityInputObj;
        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            feedElementInputObj.body = processToSegments(pollMsgArg, false, false);
        }else{
            feedElementInputObj.body = processToSegmentsV1(bodyJsonArg, false, false);
        }
        
        ConnectApi.FeedElement feedElementObj;
        feedElementObj = ConnectApi.ChatterFeeds.postFeedElement(communityIdArg, feedElementInputObj);
        NotificationDispatcher.sendPollPostNotificationAndEmail(feedElementObj.id);
        return feedElementObj;
    }
    
    /**Method to post feedelement with contentCapabilty **/
    public static ConnectApi.FeedElement postFeedElementWithContentCapabilty (String communityIdArg, 
            String subjectIdArg, String feedElementTypeArg, String contentDocumentIdArg, 
            String contentCommentBodyArg) {
        String textToProcess = contentCommentBodyArg;
        String processedStr = '';
        List<File__c> listOfFileToInsert = new List<File__c>();
        
        if (textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) > 0){ // checking if google/ box file is present. 
            String extFilesStr =  textToProcess.substring(textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
                2, textToProcess.length()); // External file string extracted 
            processedStr = contentCommentBodyArg.substring(0, contentCommentBodyArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR)); // textbody without ext files
            List<String> listOfExtFile = new List<String>();
            listOfExtFile= extFilesStr.split('\n'); // Files are seprated by newline 
            
            if (!listOfExtFile.isEmpty()) {
                processedStr = processedStr + ServiceConstants.FEED_EXT_FILE_SEPRATOR;
                
                for (String singleExtFile: listOfExtFile) {
                    List<String> listOfSingleExtFileProp = new List<String>();
                    listOfSingleExtFileProp = singleExtFile.split('\\|'); // File properties are seprated by | symbol 
                    processedStr = processedStr + '\n'; // adding new line for new file
                    
                    if (listOfSingleExtFileProp.size() > 5) {
                        File__c fileObj = convertToFileObject(listOfSingleExtFileProp);
                        processedStr = processedStr + listOfSingleExtFileProp[5].trim()  + '&fileName=' + EncodingUtil.urlEncode(listOfSingleExtFileProp[0].trim(), 'UTF-8') +'&size='+ Integer.valueOf(listOfSingleExtFileProp[2].trim()); // adding url to text
                        listOfFileToInsert.add(fileObj);
                    }
                    
                }
                
            }
        
        } else {
            processedStr = contentCommentBodyArg;
        }
        
        ConnectApi.FilesCapabilityInput fileCapabilityIpObj = new ConnectApi.FilesCapabilityInput();
        fileCapabilityIpObj.items = new List<ConnectApi.FileIdInput>();
        ConnectApi.FileIdInput fileAttchedObj = new ConnectApi.FileIdInput();
        fileAttchedObj.id = contentDocumentIdArg; 
        fileCapabilityIpObj.items.add(fileAttchedObj);
        ConnectApi.FeedElementCapabilitiesInput capabilitiesObj = new ConnectApi.FeedElementCapabilitiesInput();
        capabilitiesObj.files = fileCapabilityIpObj;
        ConnectApi.FeedItemInput feedElementInputObj = new ConnectApi.FeedItemInput();
        feedElementInputObj.capabilities = capabilitiesObj; 
        feedElementInputObj.feedElementType = ConnectApi.FeedElementType.feedItem;
        feedElementInputObj.subjectId = subjectIdArg;
        feedElementInputObj.body = processToSegments(processedStr, SimpplrContext.isFeedRichTextEnabled, false);
        ConnectApi.FeedElement feedElementObj = ConnectApi.ChatterFeeds.postFeedElement(communityIdArg, 
                feedElementInputObj);
                
        if (!listOfFileToInsert.isEmpty()) {
            Boolean isInitialize = false;
            for (File__c fileObj: listOfFileToInsert) {
                fileObj.Feed_Item__c = feedElementObj.id; // Adding feedId to fileobj
                if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                    if(!isInitialize) {
                        initializeFeedFilesVideoParams(feedElementObj.parent.id);
                    }
                    fileObj.Folder__c = feedFilesVideoFolderId;
                    fileObj.Site__c = feedFilesVideoSiteId;

                    Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
                    if(captionLanguageId != null){
                        
                        fileObj.Video_Caption_Language__c = String.valueOf(captionLanguageId);
                    }
                }
                if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileObj.Repository__c)) {
                    fileObj.Sp_Instance_Id__c = UserContext.spInstanceId;
                    fileObj.External_Folder_Id__c = Utility.getParamValueFromUrl(fileObj.Url__c, 'rootDirectory');
                }
            }
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listOfFileToInsert,new List<Schema.SObjectField>{
                File__c.Title__c,
                File__c.External_Id__c,
                File__c.Size__c,
                File__c.MIME_Type__c,
                File__c.Repository__c,
                File__c.thumbnail_url__c,
                File__c.Author__c,
                File__c.Url__c,
                File__c.Feed_Item__c,
                File__c.Folder__c,
                File__c.Site__c,
                File__c.Video_Caption_Language__c,
                File__c.Sp_Instance_Id__c,
                File__c.External_Folder_Id__c
            });
        }
        
        return feedElementObj;
    }

    /** method to post feed element without recognition along with file attched */
    public static ConnectApi.FeedElement postFeedElementWithFileCapabilty (String communityIdArg, 
            String subjectIdArg, String feedElementTypeArg, List<String> listOfAttachedFileId, 
            String contentCommentBodyArg, String bodyJsonArg, List<Criteria.ExternalFileWrapper>  externalFiles) {
        return postFeedElementWithFileCapabilty (communityIdArg, subjectIdArg, feedElementTypeArg, listOfAttachedFileId, 
            contentCommentBodyArg, bodyJsonArg, false, externalFiles);
    }
    
    /** method to post feed element with recognition along with file attched */
    public static ConnectApi.FeedElement postFeedElementWithFileCapabilty (String communityIdArg, 
        String subjectIdArg, String feedElementTypeArg, List<String> listOfAttachedFileId, 
        String contentCommentBodyArg, String bodyJsonArg, Boolean isRecognitionPost, List<Criteria.ExternalFileWrapper>  externalFiles) {
        String textToProcess = contentCommentBodyArg;
        String processedStr = '';
        List<File__c> listOfFileToInsert = new List<File__c>();
        
        if (textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0){ // checking if google/ box file is present. 
            String extFilesStr =  textToProcess.substring(textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
                2, textToProcess.length()); // External file string extracted 
            processedStr = contentCommentBodyArg.substring(0, contentCommentBodyArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR)); // textbody without ext files
            List<String> listOfExtFile = new List<String>();
            listOfExtFile= extFilesStr.split('\n'); // Files are seprated by newline 
            
            if (!listOfExtFile.isEmpty()) {
                processedStr = processedStr + ServiceConstants.FEED_EXT_FILE_SEPRATOR;
                
                for (String singleExtFile: listOfExtFile) {
                    List<String> listOfSingleExtFileProp = new List<String>();
                    listOfSingleExtFileProp = singleExtFile.split('\\|'); // File properties are seprated by | symbol 
                    processedStr = processedStr + '\n'; // adding new line for new file
                    
                    if (listOfSingleExtFileProp.size() > 5) {
                        File__c fileObj = convertToFileObject(listOfSingleExtFileProp);
                        processedStr = processedStr + listOfSingleExtFileProp[5].trim()  + '&fileName=' + EncodingUtil.urlEncode(listOfSingleExtFileProp[0].trim(), 'UTF-8') +'&size='+ Integer.valueOf(listOfSingleExtFileProp[2].trim()); // adding url to text
                        listOfFileToInsert.add(fileObj);
                    }
                    
                }
            }
        
        } else {
            if(externalFiles!=null && externalFiles.size()>0){
                for(Criteria.ExternalFileWrapper externalfile: externalFiles){
                    File__c fileObj = convertToFileObjFromExternalFileWrapper(externalfile);
                    listOfFileToInsert.add(fileObj);
                }
            }
            processedStr = contentCommentBodyArg; 
        }

        SimpplrContext.skipContentDocTrigger = true; 
        ConnectApi.FeedItemInput feedElementInputObj = new ConnectApi.FeedItemInput();
        feedElementInputObj.subjectId = subjectIdArg;
        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            feedElementInputObj.body = processToSegments(processedStr, SimpplrContext.isFeedRichTextEnabled, isRecognitionPost);
        }else{
            ConnectApi.MessageBodyInput inputBody =  processToSegmentsV1(bodyJsonArg, SimpplrContext.isFeedRichTextEnabled, isRecognitionPost);
            List<ConnectApi.MessageSegmentInput> externalFileSegments = getExternalFilesSegments(externalFiles);
            
            if(externalFileSegments!=null && externalFileSegments.size()>0){
                inputBody.messageSegments.addAll(externalFileSegments);    
            }
            feedElementInputObj.body = inputBody;
        }
        
        ConnectApi.FilesCapabilityInput filesCapabilityInputObj = new ConnectApi.FilesCapabilityInput();
        filesCapabilityInputObj.items = new List<ConnectApi.FileIdInput>();
        
        for (String fileId : listOfAttachedFileId) {
            ConnectApi.FileIdInput idInput = new ConnectApi.FileIdInput();
            idInput.id = fileId;
            filesCapabilityInputObj.items.add(idInput);
        }
        
        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.files = filesCapabilityInputObj;
        feedElementInputObj.capabilities = feedElementCapabilitiesInput;
        ConnectApi.FeedElement feedElementObj = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedElementInputObj);
        
        if (!listOfFileToInsert.isEmpty()) {
            Boolean isInitialize = false;
            for (File__c fileObj: listOfFileToInsert) {
                fileObj.Feed_Item__c = feedElementObj.id; // Adding feedId to fileobj
                if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                    if(!isInitialize) {
                        initializeFeedFilesVideoParams(feedElementObj.parent.id);
                    }
                    fileObj.Folder__c = feedFilesVideoFolderId;
                    fileObj.Site__c = feedFilesVideoSiteId;

                    Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);
                    if(captionLanguageId != null){
                        
                        fileObj.Video_Caption_Language__c = String.valueOf(captionLanguageId);
                    }
                }
                if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileObj.Repository__c)) {
                    fileObj.Sp_Instance_Id__c = UserContext.spInstanceId;
                    fileObj.External_Folder_Id__c = Utility.getParamValueFromUrl(fileObj.Url__c, 'rootDirectory');
                }
            }
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listOfFileToInsert,new List<Schema.SObjectField>{
                File__c.Title__c,
                File__c.External_Id__c,
                File__c.Size__c,
                File__c.MIME_Type__c,
                File__c.Repository__c,
                File__c.thumbnail_url__c,
                File__c.Author__c,
                File__c.Url__c,
                File__c.Feed_Item__c,
                File__c.Folder__c,
                File__c.Site__c,
                File__c.Video_Caption_Language__c,
                File__c.Sp_Instance_Id__c,
                File__c.External_Folder_Id__c
            });
        }
        
        return feedElementObj;
    }
    
    /**Method to share FeedElement **/
    public static ConnectApi.FeedElement shareFeedElement (String communityIdArg, String subjectIdArg, 
            String feedElementTypeArg, String originalFeedElementIdArg, String commentTextArg ) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = commentTextArg;
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        //feedItemInput.originalFeedItemId = originalFeedElementIdArg;
        feedItemInput.subjectId = subjectIdArg;
        ConnectApi.FeedElement feedElementObj = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
        return feedElementObj;
    }
    
    /**Method to update FeedElement Bookmarks**/
    public static ConnectApi.BookmarksCapability updateFeedElementBookmarks(String communityIdArg, 
            String feedElementIdArg, String bookmarksCapabilityStr){
        ConnectApi.BookmarksCapabilityInput bookmarkIPCapabilityObj;
        ConnectApi.BookmarksCapability bookmarkCapabilityObj;
        bookmarkCapabilityObj = ConnectApi.ChatterFeeds.updateFeedElementBookmarks(communityIdArg, 
                feedElementIdArg, bookmarkIPCapabilityObj);
        return bookmarkCapabilityObj;
    }
    
    /**Overloaded Method to update FeedElement Bookmarks**/
    public static ConnectApi.BookmarksCapability updateFeedElementBookmarks (String communityIdArg, 
            String feedElementIdArg, Boolean isBookmarkedByCurrentUser) {
        ConnectApi.BookmarksCapability bookmarkCapabilityObj;
        bookmarkCapabilityObj = ConnectApi.ChatterFeeds.updateFeedElementBookmarks(communityIdArg, 
                feedElementIdArg, isBookmarkedByCurrentUser);
        return bookmarkCapabilityObj;
    }
    
    /** Method to poll on the feedElement**/
    public static ConnectApi.PollCapability voteOnFeedElementPoll (String communityIdArg, String feedElementIdArg, 
            String myChoiceIdArg) {
        ConnectApi.PollCapability pollCapabiltyObj;
        pollCapabiltyObj = ConnectApi.ChatterFeeds.voteOnFeedElementPoll(communityIdArg, feedElementIdArg, 
                myChoiceIdArg);
        return pollCapabiltyObj;
    }
    
    /**Method to delete specific feed element**/
    public static void deleteSpecifiedFeedElement (String communityIdArg, String feedElementIdArg) {
        ConnectApi.ChatterFeeds.deleteFeedElement(communityIdArg, feedElementIdArg);
    }
    
    /**Method to bookmark feed element**/
    public static Boolean toggleFeedElementBookMark (String communityIdArg, 
    String feedElementIdArg, Boolean isBookmarkedByCurrentUserArg) {
        Boolean result = false;
        ConnectApi.BookmarksCapabilityInput bookmarksInputObj = new ConnectApi.BookmarksCapabilityInput();
        bookmarksInputObj.isBookmarkedByCurrentUser = isBookmarkedByCurrentUserArg;
        ConnectApi.BookmarksCapability bookmarkCapbilityObj;
        if(!Test.isRunningTest()){
        bookmarkCapbilityObj = ConnectApi.ChatterFeeds.updateFeedElementBookmarks(communityIdArg, feedElementIdArg, 
                bookmarksInputObj);
            result = bookmarkCapbilityObj.isBookmarkedByCurrentUser;
        }
        return result; 
    }
    
    /**Method to search feeds**/
    public static ConnectApi.FeedElementPage searchFeeds(String communityIdArg, String feedTypeArg, String subjectIdArg,
            String pageParamArg, Integer pageSizeArg, String searchStrArg, String sortParamArg){
        ConnectApi.FeedElementPage feedElementPageObj;
        ConnectApi.FeedDensity feedDensityObj = SimpplrContext.showTrackChangesFeedPosts ? 
                ConnectApi.FeedDensity.AllUpdates : ConnectApi.FeedDensity.FewerUpdates;
                
        if (sortParamArg == 'activity') {
            
            if (feedTypeArg == 'To') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg,
                        ConnectApi.FeedType.To, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'Bookmarks') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg,
                        ConnectApi.FeedType.Bookmarks, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'Company') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.Company, recentCommentCount, feedDensityObj,
                        pageParamArg, pageSizeArg, ConnectApi.FeedSortOrder.LastModifiedDateDesc, 
                        searchStrArg);
                        
            } else if (feedTypeArg == 'People') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.People, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'Record') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.Record, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'UserProfile') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.UserProfile, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc, searchStrArg);
                        
            } else {        
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.news, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.LastModifiedDateDesc, searchStrArg);
            }
            
        } else {
            
            if (feedTypeArg == 'To') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg,
                        ConnectApi.FeedType.To, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg, 
                        ConnectApi.FeedSortOrder.CreatedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'Bookmarks') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg,
                        ConnectApi.FeedType.Bookmarks, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.CreatedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'Company') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.Company, recentCommentCount, feedDensityObj,
                            pageParamArg, pageSizeArg, ConnectApi.FeedSortOrder.CreatedDateDesc, 
                            searchStrArg);
                        
            } else if (feedTypeArg == 'People') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.People, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.CreatedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'Record') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.Record, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.CreatedDateDesc, searchStrArg);
                        
            } else if (feedTypeArg == 'UserProfile') {
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.UserProfile, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.CreatedDateDesc, searchStrArg);
                        
            } else {        
                feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFeed(communityIdArg, 
                        ConnectApi.FeedType.news, subjectIdArg, recentCommentCount, 
                        feedDensityObj, pageParamArg, pageSizeArg,
                        ConnectApi.FeedSortOrder.CreatedDateDesc, searchStrArg);
            }
            
        }
        
        return feedElementPageObj; 
    }
    
    /**Method to get the feed poll**/
    public static ConnectApi.PollCapability getFeedPoll (String communityIdArg, String feedElementIdArg) {
        ConnectApi.PollCapability pollCapabiltyObj;
        pollCapabiltyObj = ConnectAPI.ChatterFeeds.getFeedElementPoll(communityIdArg, feedElementIdArg);
        return pollCapabiltyObj;
    }
    
    /**Method to add get FeedElement**/
    public static ConnectApi.FeedElement getFeedElement (String communityIdArg, String feedElementIdArg) {
        try {
            ConnectApi.FeedElement feedElementObj = ConnectAPI.ChatterFeeds.getFeedElement(communityIdArg,
                    feedElementIdArg);
            return feedElementObj;
    
        } catch (exception e) {
        	
            if (e.getMessage().containsIgnoreCase('resource not found')) {
            	throw new SimpplrException(ServiceConstants.ERROR_404);

            } else {
            	throw e;
            }

        }

    }
    
    public static ConnectApi.FeedElement getFeedElement (String communityIdArg, String feedElementIdArg, String pageSize) {
        try {
            ConnectApi.FeedElement feedElementObj;
            if(Test.isRunningTest()) {
                feedElementObj = TestHelper.getFeedElement(null);

            } else {
                if (pageSize != null && Integer.valueOf(pageSize) <= 25) {
                        feedElementObj = ConnectAPI.ChatterFeeds.getFeedElement(communityIdArg,
                            feedElementIdArg, Integer.valueOf(pageSize), 1);
                
                } else {
                    feedElementObj = ConnectAPI.ChatterFeeds.getFeedElement(communityIdArg,
                            feedElementIdArg, 25, 1);
                }
            }        
            return feedElementObj;         
        } catch (exception e) {
            throw new SimpplrException(ServiceConstants.ERROR_404);
        }
    }
    
    /**Method to unlike Feed Elements **/  
    public static void unlikeFeedElement (String communityIdArg, String likeIdArg, String feedElementIdArg) {
        if(String.isNotEmpty(likeIdArg)){
            ConnectApi.ChatterFeeds.deleteLike(communityIdArg, likeIdArg);
        }
        String currentUserId = UserContext.getCurrentUserInfo.id;
        List<Like__c> likesForFeedPost = [select id, Feed_Item_Id__c, Is_Deleted__c 
                from Like__c 
                where  Feed_Item_Id__c =:feedElementIdArg AND 
                people__c =:currentUserId AND Is_Deleted__c =:false WITH SECURITY_ENFORCED limit 1];
        
        Like__c likeToUpdate = new Like__c();
        for (Like__c recList : likesForFeedPost) {
            likeToUpdate.Id = recList.Id;
            likeToUpdate.Feed_Item_Id__c = feedElementIdArg;
            likeToUpdate.people__c = currentUserId;
            likeToUpdate.Is_Deleted__c = true;

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(likeToUpdate, new List<Schema.SObjectField>{
				Like__c.Feed_Item_Id__c,
				Like__c.people__c,
				Like__c.Is_Deleted__c
			});
        }


    }
    
    /**Method to like comment**/
    public static ConnectApi.ChatterLike likeComment (String communityIdArg, String commentIdArg) {
        ConnectApi.ChatterLike commentLikeObj = ConnectApi.ChatterFeeds.likeComment(communityIdArg, commentIdArg);
        return commentLikeObj; 
    }
    
    /**Method to unlike Feed comments **/  
    public static void unlikeComment (String communityIdArg, String commentIdArg, String likeIdArg) {
        ConnectApi.ChatterFeeds.deleteLike(communityIdArg, likeIdArg);
        String currentUserId = UserContext.getCurrentUserInfo.id;
        List<Like__c> likesForFeedPostToDelete = [SELECT Id from Like__c 
                WHERE Feed_Item_Comment_Id__c = :commentIdArg AND people__c =:currentUserId WITH SECURITY_ENFORCED];
        
        if (!likesForFeedPostToDelete.isEmpty()) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().deleteAsUser(likesForFeedPostToDelete);
        }
                    
    }
    
    /**Method to get feed comment**/
    public static ConnectApi.Comment getComment (String communityIdArg, String commentIdArg) {
        ConnectApi.Comment commentObj = ConnectApi.ChatterFeeds.getComment(communityIdArg, commentIdArg);
        return commentObj;  
    }
    
    private static Map<String,Set<String>> getMentionedUserIdOrGrpIdMap(String postedText) {
		Map<String, Set<String>> mentionedUserOrGrpMap = new Map<String, Set<String>>();
		String remainingString = postedText;

		while (remainingString != null && remainingString.length() > 0) {
	        String mentionString = '';
	        Pattern patternObj = Pattern.compile('@\\[.*?\\]'); // if pattern is @[userId]
	        Matcher matcher = patternObj.matcher(remainingString);
	        
	        if (matcher.find()) {
	            mentionString = matcher.group(0);
	            String mentionId = '';

	            if (mentionString.length() == 21) {
	                mentionId = mentionString.substringBetween('[',']');
	            }

	            if (mentionId.startsWith('005')) {

	            	if (mentionedUserOrGrpMap.get('user') == null) {
	            		mentionedUserOrGrpMap.put('user',new Set<String>());
	            	}

	            	mentionedUserOrGrpMap.get('user').add(mentionId);
	                
	            } else if (mentionId.startsWith('0F9')) {

	                if (mentionedUserOrGrpMap.get('group') == null) {
	            		mentionedUserOrGrpMap.put('group',new Set<String>());
	            	}

	            	mentionedUserOrGrpMap.get('group').add(mentionId);
	            }

				remainingString = remainingString.substringAfter(mentionString);
	    
	        } else {
	            remainingString = null;
	        }

	    }
	
		return mentionedUserOrGrpMap;
		    
	}
    private static ConnectApi.MessageSegmentInput getBeginSegment(String type){
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        if(type=='paragraph'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
        }else if(type =='bold'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;
        }else if(type=='italic'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.Italic;
        }else if(type=='underline'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.Underline;         
        }else if(type=='strike'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.Strikethrough;
        }else if(type=='bulletList'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.UnorderedList;
        }else if(type=='orderedList'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.OrderedList;
        }else if(type=='listItem'){
            markupBeginSegment.markupType = ConnectApi.MarkupType.ListItem;
        }else{
            return null;
        }
        return markupBeginSegment;
    }

    private static ConnectApi.MessageSegmentInput getEndSegment(String type){
        ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
        if(type=='paragraph'){
            markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
        }else if(type =='bold'){
            markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
        }else if(type=='italic'){
            markupEndSegment.markupType = ConnectApi.MarkupType.Italic;
        }else if(type=='underline'){
            markupEndSegment.markupType = ConnectApi.MarkupType.Underline;
        }else if(type=='strike'){
            markupEndSegment.markupType = ConnectApi.MarkupType.Strikethrough;
        }else if(type=='bulletList'){
            markupEndSegment.markupType = ConnectApi.MarkupType.UnorderedList;
        }else if(type=='orderedList'){
            markupEndSegment.markupType = ConnectApi.MarkupType.OrderedList;
        }else if(type=='listItem'){
            markupEndSegment.markupType = ConnectApi.MarkupType.ListItem;
        }else{
            return null;
        }
        return markupEndSegment;
    }

    public static List<ConnectApi.MessageSegmentInput> getExternalFilesSegments(List<Criteria.ExternalFileWrapper> externalFiles){
        List<ConnectApi.MessageSegmentInput> externalFileSegments = new List<ConnectApi.MessageSegmentInput>();
        if(externalFiles!=null && externalFiles.size()>0){
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = ServiceConstants.FEED_EXT_FILE_SEPRATOR;		
            externalFileSegments.add(textSegment);
            ConnectApi.LinkSegmentInput linkSegment = new ConnectApi.LinkSegmentInput();
            String urlString = '';
            for(integer i=0;i<externalFiles.size(); i++){
                Criteria.ExternalFileWrapper externalFile = externalFiles[i];
                String url = externalFile.url+'&fileName=' + EncodingUtil.urlEncode(externalFile.title, 'UTF-8') +'&size='+ Integer.valueOf(externalFile.size);
                if(i==0){
                    if(externalFiles.size()==1){
                        urlString = url; 
                    }else{
                        urlString = url+'\n';
                    } 
                }else if(i==externalFiles.size()-1){
                    urlString += url; 
                }else{
                    urlString += url+'\n'; 
                }
            }
            linkSegment.url = urlString.replace('"', '%22');
            externalFileSegments.add(linkSegment);
          
        }
        return externalFileSegments;
    }

   
    private static List<ConnectApi.MessageSegmentInput> createSegments(FeedContentItemWrapper.content content, List<ConnectApi.MessageSegmentInput> segments){
        //type begin
        ConnectApi.MessageSegmentInput beginSegment = getBeginSegment(content.type);
        if(beginSegment!=null){
            segments.add(beginSegment);
        }
        Boolean processedLink = false; // if type is text and it contains link, just add the LinkSegmentInput and dotn add the text as it will duplicates
        if(content.marks!=null){
            //begin marks
            for(FeedContentItemWrapper.marks mark : content.marks){
                if(mark.type=='link'){

                    ConnectApi.LinkSegmentInput linkSegment = new ConnectApi.LinkSegmentInput();
                    linkSegment.url = mark.attrs.href;
                    segments.add(linkSegment);
                    processedLink = true;

                }else{
                    ConnectApi.MessageSegmentInput beginMarkSegment = getBeginSegment(mark.type);
                    if(beginMarkSegment!=null){
                        segments.add(beginMarkSegment);
                    }
                }
            }
        }
        if(content.type == 'text' && !processedLink){
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = content.text;		
        	segments.add(textSegment);
        }
        if(content.type == 'emoji' ){
            ConnectApi.TextSegmentInput emojiSegment = new ConnectApi.TextSegmentInput();
            emojiSegment.text = content.attrs.emoji;		
        	segments.add(emojiSegment);
        }
        if(content.type == 'UserAndSiteMention'){
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            if(content.attrs.type == 'user'){
                String userId = content.attrs.id;
                if(!userId.startsWith('005')){
                    mentionSegment.id = peopeIdUserIdMap.get(userId);
                }else{
                    mentionSegment.id = content.attrs.id;
                }
            }
            if(content.attrs.type == 'site'){
                String siteId = content.attrs.id;
                if(!siteId.startsWith('0F9')){
                    mentionSegment.id = siteIdChatterGroupIdMap.get(siteId);
                }else{
                    mentionSegment.id = content.attrs.id;
                }
            }
            segments.add(mentionSegment);

        }
        if(content.type =='TopicMention'){
            ConnectApi.HashTagSegmentInput hashSegment = new ConnectApi.HashTagSegmentInput();
            hashSegment.tag = content.attrs.label;
            segments.add(hashSegment);
        }


        if(content.content!=null && content.content.size()>0){
            for(FeedContentItemWrapper.content innerContent : content.content){
                segments.addAll(createSegments(innerContent, new List<ConnectApi.MessageSegmentInput>()));
            }
        }
        
        if(content.marks!=null){
            //end marks
            for(Integer i=content.marks.size()-1;i>=0;i--){
                ConnectApi.MessageSegmentInput endMarkSegment = getEndSegment(content.marks[i].type);
                if(endMarkSegment!=null){
                    segments.add(endMarkSegment);
                }
            }
        }
        //type end
        ConnectApi.MessageSegmentInput endSegment = getEndSegment(content.type);
        if(endSegment!=null){
            segments.add(endSegment);
        }
        return segments;
    }
    
    public static void populatePeopleSiteIdsSets(FeedContentItemWrapper.content content){

        if(content.type == 'UserAndSiteMention'){
            if(content.attrs.type == 'user'){
                mentionedPeopleIdsSet.add(content.attrs.id);
            }
            if(content.attrs.type == 'site'){
                mentionedSiteIdsSet.add(content.attrs.id);
            }
        }
        if(content.content!=null && content.content.size()>0){
            for(FeedContentItemWrapper.content innerContent : content.content){
                populatePeopleSiteIdsSets(innerContent);
            }
        }
    }
   
    public static void popuateMentionsMap(){
        if(mentionedPeopleIdsSet!=null && mentionedPeopleIdsSet.size()>0){
            PeopleDao peopleDaoObj = new PeopleDao();  
            peopeIdUserIdMap = peopleDaoObj.getPeopleIdUserIdMapByPeopleIds(mentionedPeopleIdsSet);
        }
        if(mentionedSiteIdsSet!=null && mentionedSiteIdsSet.size()>0){
            siteIdChatterGroupIdMap = SiteDao.getSiteIdChatterGroupIdMapBySiteIds(mentionedSiteIdsSet);
        }
    }

    public static ConnectApi.MessageBodyInput processToSegmentsV1 (String bodyJsonArg, Boolean isRichtextEnabled, Boolean isRecognitionPost) {
        
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        FeedContentItemWrapper wrap = (FeedContentItemWrapper)JSON.deserialize(bodyJsonArg, FeedContentItemWrapper.class);

        for(FeedContentItemWrapper.content content : wrap.content){
            populatePeopleSiteIdsSets(content);
        }
        popuateMentionsMap();

        Boolean isRecognitionSet = false;
        for(FeedContentItemWrapper.content content : wrap.content){
            if(isRecognitionPost && content.content.size() != 0){
                for(FeedContentItemWrapper.content contentInner : content.content){
                    if(!isRecognitionSet && 'text'.equalsIgnoreCase(contentInner.type)){
                        contentInner.text = ServiceConstants.RECOGNITION_FILE_SEPRATOR  + contentInner.text;
                        isRecognitionSet = true;
                        break;
                    }
                }
            }
            messageInput.messageSegments.addAll(createSegments(content, new List<ConnectApi.MessageSegmentInput>()));
        }
        return messageInput;
    }
   
   
	@testVisible 
    private static ConnectApi.MessageBodyInput processToSegments (String postedText, Boolean isRichtextEnabled, Boolean isRecognitionPost) {

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        String mentionIdPrefix = '@[';
        Integer MENTION_ID_LENGTH = 18;
        String hashPrefix = '#';
        String[] urlPrefixes = new List<String>{'https://', 'http://', 'www.'};
        String remainingString = isRecognitionPost ? postedText.startsWith('<p>') ? postedText.replace('<p>','<p>'+ServiceConstants.RECOGNITION_FILE_SEPRATOR) : ServiceConstants.RECOGNITION_FILE_SEPRATOR + postedText : postedText;
        Map<String,Set<String>> mentionedUserIdOrGrpIdMap = getMentionedUserIdOrGrpIdMap(postedText);
        Map<String,User> mapOfUser = new Map<String,User>();

        if (mentionedUserIdOrGrpIdMap.get('user')!= null && mentionedUserIdOrGrpIdMap.get('user').isEmpty() == false) {
        	mapOfUser = getMentionedUserMap(mentionedUserIdOrGrpIdMap.get('user'));
        }

        Map<String,CollaborationGroup> mapOfCollaborationGroup = new Map<String,CollaborationGroup>();

        if (mentionedUserIdOrGrpIdMap.get('group')!= null && mentionedUserIdOrGrpIdMap.get('group').isEmpty() == false) {
        	mapOfCollaborationGroup = getMentionedCollGroupMap(mentionedUserIdOrGrpIdMap.get('group'));
        }

        while (remainingString != null && remainingString.length() > 0) {
            // find first potential mention index
            Integer firstAtIndex = -1;
            String mentionString = '';
            Pattern patternObj = Pattern.compile('@\\[.*?\\]'); // if pattern is @[userId]
            Matcher matcher = patternObj.matcher(remainingString);
            
            if (matcher.find()) {
                mentionString = matcher.group(0);

                if (mentionString.length() == MENTION_ID_LENGTH + 3 
                        && (mentionString.startsWith(mentionIdPrefix + '005') || 
                        mentionString.startsWith(mentionIdPrefix + '0F9'))) {
                    firstAtIndex = remainingString.indexOf(mentionString);
                }
                
            }

            // find first url index
            Integer firstUrlIndex = -1; 
                    
            for (String urlPrefix: urlPrefixes) {
                Integer currFirstUrlIndex = remainingString.indexOf(urlPrefix);
               
                if (firstUrlIndex == -1 || currFirstUrlIndex < firstUrlIndex) {
                    firstUrlIndex = currFirstUrlIndex;
                    break; 
                }
                
            }
            
            // find first hash index
            Integer firstHashIndex = remainingString.indexOf(hashPrefix);
             
            // process for Mention Segment
            if (firstAtIndex != -1 && 
            		(firstHashIndex == -1 || firstAtIndex < firstHashIndex) 
                    && (firstUrlIndex == -1 || firstAtIndex < firstUrlIndex)) {
                String textString = remainingString.substring(0, firstAtIndex);
                String mentionId = '';              
                mentionId = mentionString.substring(2, mentionString.length() - 1);
                remainingString = remainingString.substring(textString.length() + mentionString.length());
                 
               if (!textString.equals('')) {
                    messageInput.messageSegments.addAll(getHTMLMessageSegmentList(textString, isRichtextEnabled));
                } 
                
                User user = null;
                CollaborationGroup collaborationGroup = null;
                
                if (mentionId.startsWith('005')) {
                    user = mapOfUser.get(mentionId);
                
                } else if (mentionId.startsWith('0F9')) {
                    collaborationGroup = mapOfCollaborationGroup.get(mentionId);
                }

                // if valid user then save it as @mention else simple text
                if (user == null && collaborationGroup == null) {
                    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = mentionString;
                    messageInput.messageSegments.add(textSegment);  
                    
                } else {
                    ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                    mentionSegment.id = mentionId;
                    messageInput.messageSegments.add(mentionSegment);
                    //logger.logDebug('Mention id received from database lookup: ' + mentionId);
                }
                
            // Process for Hash Segment  
            } else if (firstHashIndex != -1 && (firstAtIndex == -1 || firstHashIndex < firstAtIndex) 
                    && (firstUrlIndex == -1 || firstHashIndex < firstUrlIndex)) {
                String hashString = ''; // #[topic] or #topic
                String hashTag = '';
                // if pattern is #[topic]
                patternObj = Pattern.compile('#\\[.*?\\]');
                matcher = patternObj.matcher(remainingString);
                Boolean matchFound = false; 
                String firstOldHashTag = '';

                if (matcher.find()) {
                    matchFound = true; 
                    firstOldHashTag = matcher.group(0);
                }

                if (matchFound && firstHashIndex == remainingString.indexOf(firstOldHashTag)) {
                    hashString = matcher.group(0);
                   
                    if (hashString.length() > 3) {
                        hashTag = hashString.substring(2, hashString.length()-1);
                    }
                    
                // if pattern is #topic
                } else {
                    Integer whiteSpaceIndex = remainingString.indexOf(' ', firstHashIndex);
                    Integer newLineIndex = remainingString.indexOf(String.fromCharArray(new Integer[]{10}), firstHashIndex);
                    Integer commaIndex = remainingString.indexOf(',', firstHashIndex);
                    // get the smallest index where the hash tag ends
                    Integer cutPointIndex = -1;
                    
                    if (whiteSpaceIndex == -1 && newLineIndex != -1) {
                        cutPointIndex = newLineIndex;
                    
                    } else if (newLineIndex == -1 && whiteSpaceIndex != -1) {
                        cutPointIndex = whiteSpaceIndex;
                        /*if(commaIndex < whiteSpaceIndex){
                            cutPointIndex = commaIndex;
                        }*/
                    } else if (whiteSpaceIndex < newLineIndex) {
                        cutPointIndex = whiteSpaceIndex;
                        
                    } else {
                        cutPointIndex = newLineIndex;
                    }
                    
                    if (cutPointIndex == -1) {
                        hashString = remainingString.substring(firstHashIndex);
                   
                    } else {
                        hashString = remainingString.substring(firstHashIndex, cutPointIndex);
                    }
                    
                    if (hashString.length() > 1) {
                        hashTag = hashString.substring(1);
                    }
                    
                }
                
                //firstHashIndex SV2-16872
                String textString = remainingString.substring(0, remainingString.indexOf(hashString));  
                
                // Check for invalid characters in hashtag
                if (hashTag.length() == 0 || hashTag.isNumeric() || hashTag.indexOf(']') != -1 ||
                		hashTag.indexOf(',') != -1  || hashTag.indexOf('<') != -1) { // SV2-10181
                    textString = textString + hashString;
                    hashTag = '';
                    remainingString = remainingString.substring(textString.length());
                    
                } else {
                    remainingString = remainingString.substring(textString.length() + hashString.length());
                }     
                
                // save text string
                if (!textString.trim().equals('')) {
                    messageInput.messageSegments.addAll(getHTMLMessageSegmentList(textString, isRichtextEnabled));
                }
                
                // save hash tag
                if (!hashTag.trim().equals('')) {
                    ConnectApi.HashTagSegmentInput hashSegment = new ConnectApi.HashTagSegmentInput();
                    hashSegment.tag = hashTag;
                    messageInput.messageSegments.add(hashSegment);
                }
                
            // Process for Link Segment  
            } else if (firstUrlIndex != -1 && (firstAtIndex == -1 || firstUrlIndex < firstAtIndex) 
                    && (firstHashIndex == -1 || firstUrlIndex < firstHashIndex)) {
                String textString = remainingString.substring(0, firstUrlIndex);
                Integer urlStringEndIndex = remainingString.indexOf(' ', firstUrlIndex);
                Integer firstNextTagStartIndex = remainingString.indexOf('<', firstUrlIndex);

                if (urlStringEndIndex == -1 || (firstNextTagStartIndex != -1  && urlStringEndIndex != -1 
                		&& firstNextTagStartIndex < urlStringEndIndex)) {
                	urlStringEndIndex = firstNextTagStartIndex;
                }
                
                String urlString = ''; //http://xxxxx or www.xxxxx
                
                if (urlStringEndIndex == -1) {
                    urlString = remainingString.substring(firstUrlIndex);   
               
                } else {
                    urlString = remainingString.substring(firstUrlIndex, urlStringEndIndex);
                }
                
                remainingString = remainingString.substring(textString.length() + urlString.length());
                
                // save text string
                if (!textString.equals('')) {
                    messageInput.messageSegments.addAll(getHTMLMessageSegmentList(textString, isRichtextEnabled));
                }
                
                // save link tag
                if (!urlString.equals('')) {
                    ConnectApi.LinkSegmentInput linkSegment = new ConnectApi.LinkSegmentInput();
                    linkSegment.url = urlString.replace('"', '%22');
                    messageInput.messageSegments.add(linkSegment);
                }
                
            } else if (remainingString.indexOf(' ') == 0) {
            	ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = ' ';
                messageInput.messageSegments.add(textSegment); 
            	remainingString = remainingString.substring(1,remainingString.length());
            	
            }  else if (!remainingString.equals('')) {
                messageInput.messageSegments.addAll(getHTMLMessageSegmentList(remainingString, isRichtextEnabled));
                break;
            } 
            
        }
        return messageInput;
    }
    
    private static List<ConnectApi.MessageSegmentInput> getHTMLMessageSegmentList(String inputString, 
            Boolean isRichtextEnabled) {
        List<ConnectApi.MessageSegmentInput> messageSegmentList = new List<ConnectApi.MessageSegmentInput>();
        
        if (inputString !=null && inputString.length() > 0) {
        	
        	if (isRichtextEnabled) {
	            Set<String> validHTMLTagSet = new Set<String>{'<p>', '</p>',
	        		'<strong>','</strong>', '<em>','</em>', '<s>','</s>', '<u>', 
	        		'</u>', '<ul>', '</ul>', '<li>', '</li>', '<ol>', '</ol>', '<br>' };
	            Integer i = 0;
	            
	            while ( i < inputString.length()) {
	                String subStr = '';
	                Integer  intval = inputString.charAt(i);
	            
	                if (intval == '<'.charAt(0)) {
	                    subStr = inputString.subString(i, inputString.indexOf('>', i) + 1);
	                    
	                    if (validHTMLTagSet.contains(subStr)) {
	                        messageSegmentList.add(getMessageSegment(subStr));
	                    
	                    } else {
	                        messageSegmentList.add(getMessageSegment(inputString.subString(i, 
	                        		inputString.indexOf('<', i))));
	                    }
	                    
	                } else {
	                	
	                	if (inputString.indexOf('<', i) != -1) {
		                    subStr = inputString.subString(i, inputString.indexOf('<', i));
	                	
	                	} else {
	                		subStr = inputString.substring(i);	
	                	}
	                	
	                	messageSegmentList.add(getMessageSegment(subStr));
	                }
	                
	                i = i + subStr.length();
	            }	
	            
        	} else {
        		ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();	
	        	textSegment.text = inputString;
	        	messageSegmentList.add(textSegment);
        	}	
        			     
        }
      
        return messageSegmentList;
    }
    
    private static ConnectApi.MessageSegmentInput getMessageSegment(String segmentText) {
    	ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
    	ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
    	ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    	
        if ('<p>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
        	return 	markupBeginSegment;	  
        	  
        } else if ('</p>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
        	return 	markupEndSegment;
        	
        } else if ('<strong>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.Bold;		
        	return 	markupBeginSegment;
        	
        } else if ('</strong>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.Bold;
        	return 	markupEndSegment;	
        		
        } else if ('<em>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.Italic;	
        	return 	markupBeginSegment;	
        	
        } else if ('</em>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.Italic;	
        	return 	markupEndSegment;	
        	
        } else if ('<s>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.Strikethrough;		
        	return 	markupBeginSegment;
        	
        } else if ('</s>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.Strikethrough;	
        	return 	markupEndSegment;	
        	
        } else if ('<u>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.Underline;	
        	return 	markupBeginSegment;	
        	
        } else if ('</u>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.Underline;	
        	return 	markupEndSegment;	
        	
        } else if ('<ul>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.UnorderedList;
        	return 	markupBeginSegment;		
        	
        } else if ('</ul>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.UnorderedList;	
        	return 	markupEndSegment;	
        	
        } else if ('<li>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.ListItem;		
        	return 	markupBeginSegment;
        	
        } else if ('</li>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.ListItem;	
        	return 	markupEndSegment;	
        	
        } else if ('<ol>'.equalsIgnoreCase(segmentText)) {
        	markupBeginSegment.markupType = ConnectApi.MarkupType.OrderedList;	
        	return 	markupBeginSegment;	
        	
        } else if ('</ol>'.equalsIgnoreCase(segmentText)) {
        	markupEndSegment.markupType = ConnectApi.MarkupType.OrderedList;	
        	return 	markupEndSegment;	
        	
        } else if ('<br>'.equalsIgnoreCase(segmentText)) {
        	textSegment.text = '&nbsp;';		
        	return 	textSegment;
        	
        } else {
        	textSegment.text = segmentText;
        	return 	textSegment;			
        }	      
         
    }

    /** Method to delete the topic**/
    public static void unassignTopic (String communityIdArg, String recordIdArg, String topicIdArg) {
        ConnectApi.Topics.unassignTopic(communityIdArg, recordIdArg, topicIdArg);
    }
    
    public static ConnectApi.Topic assignTopic (String communityIdArg,String recordIdArg, String topicNameArg) {
        ConnectApi.Topic newTopicObj = ConnectApi.Topics.assignTopicByName(communityIdArg,
                recordIdArg, topicNameArg);    
        return newTopicObj;
    }
    
    public static ConnectApi.TopicPage getTopics (String communityIdArg, String recordIdArg) {
        ConnectApi.TopicPage topicPage =  ConnectApi.Topics.getTopics(communityIdArg, recordIdArg);
        return topicPage; 
    }
    
    /**method to update feed element without recognition*/
    public static ConnectApi.FeedElement updateFeedElement(String communityIdArg, String feedElementIdArg,
    		String bodyMsgArg, String bodyJsonArg, List<Criteria.ExternalFileWrapper>  externalFiles){
        return updateFeedElement(communityIdArg, feedElementIdArg,bodyMsgArg, bodyJsonArg, false, externalFiles);
    }

    /**method to update feed element with recognition*/
    public static ConnectApi.FeedElement updateFeedElement(String communityIdArg, String feedElementIdArg,
    		String bodyMsgArg, String bodyJsonArg, Boolean isRecognitionPost, List<Criteria.ExternalFileWrapper>  externalFiles){
                system.debug('FCAS >>>>>updateFeedElement>>>>1859>>>>bodyMsgArg : ' + bodyMsgArg); 
                system.debug('FCAS >>>>>updateFeedElement>>>>1860>>>>bodyJsonArg : ' + bodyJsonArg); 
                system.debug('FCAS >>>>>updateFeedElement>>>>1861>>>>externalFiles : ' + externalFiles); 
                system.debug('FCAS >>>>>updateFeedElement>>>>1862>>>>feedElementIdArg : ' + feedElementIdArg);
        String textToProcess = bodyMsgArg;
        String processedStr = '';
        List<File__c> listOfFileToInsert = new List<File__c>();
        
        if (textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0){ // checking if google/ box file is present. 
            system.debug('FCAS >>>>>updateFeedElement>>>>1868>>>>textToProcess' + textToProcess); 

            String extFilesStr =  textToProcess.substring(textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
                2, textToProcess.length()); // External file string extracted 
                system.debug('FCAS >>>>>updateFeedElement>>>1871>>>>extFilesStr' + extFilesStr); 

            processedStr = bodyMsgArg.substring(0, bodyMsgArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR)); // textbody without ext files
            List<String> listOfExtFile = new List<String>();
            listOfExtFile= extFilesStr.split('\n'); // Files are seprated by newline 
            
            if (!listOfExtFile.isEmpty()) {
                processedStr = processedStr + ServiceConstants.FEED_EXT_FILE_SEPRATOR;

                String query = 'SELECT Id, Url__c, External_Id__c FROM File__c ' + 
                                'WHERE Repository__c =: soqlParam1 AND Feed_Item__c =: soqlParam2 ';
                                system.debug('FCAS >>>>>updateFeedElement>>>1882>>>>query : ' + query); 

                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', ServiceConstants.VIDEO_PROVIDER_NATIVE);
                soqlParamMap.put('soqlParam2', feedElementIdArg);    
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<File__c> nvFileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);  
                Map<String, String> externalIdToNVUrlMap = new Map<String, String>();
                for(File__c fileObj : nvFileList) {
                    externalIdToNVUrlMap.put(fileobj.External_Id__c, fileObj.Url__c);
                }                                           
                for(Criteria.ExternalFileWrapper externalFileObj : externalFiles) {
                    if(externalIdToNVUrlMap.containsKey(externalFileObj.id)) {
                        externalFileObj.url = externalIdToNVUrlMap.get(externalFileObj.id) != null ? externalIdToNVUrlMap.get(externalFileObj.id) : externalFileObj.url;
                    }
                }
                for (String singleExtFile: listOfExtFile) {
                    system.debug('FCAS >>>>>updateFeedElement>>>1899>>>>singleExtFile : ' + singleExtFile.split('\\|')); 

                    List<String> listOfSingleExtFileProp = new List<String>();
                    listOfSingleExtFileProp = singleExtFile.split('\\|'); // File properties are seprated by | symbol 
                    processedStr = processedStr + '\n'; // adding new line for new file
                    if(listOfSingleExtFileProp[4].trim().equalsIgnoreCase(ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
                        String entityId = listOfSingleExtFileProp[5].trim().substringAfterLast('/'); 
                        listOfSingleExtFileProp[5] = externalIdToNVUrlMap.get(entityId) != null ? externalIdToNVUrlMap.get(entityId) : listOfSingleExtFileProp[5];
                    }
                    if (listOfSingleExtFileProp.size() > 5) {
                        processedStr = processedStr + listOfSingleExtFileProp[5].trim()  + '&fileName=' + EncodingUtil.urlEncode(listOfSingleExtFileProp[0].trim(), 'UTF-8') +'&size='+ Integer.valueOf(listOfSingleExtFileProp[2].trim()); // adding url to text
                    }
                    
                }
                
            }
        
        } else {
            if(externalFiles!=null && externalFiles.size()>0){
                for(Criteria.ExternalFileWrapper externalfile: externalFiles){
                    File__c fileObj = convertToFileObjFromExternalFileWrapper(externalfile);
                    listOfFileToInsert.add(fileObj);
                }
            }
            processedStr = bodyMsgArg;
        }
        
        ConnectApi.FeedEntityIsEditable isEditable = ConnectApi.ChatterFeeds.isFeedElementEditableByMe(communityIdArg,
                feedElementIdArg);
        ConnectApi.FeedElement editedFeedElement;
        
        if (isEditable.isEditableByMe == true) {
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            feedItemInput.body = processToSegments(processedStr, SimpplrContext.isFeedRichTextEnabled, isRecognitionPost);
        }else{
            ConnectApi.MessageBodyInput inputBody =  processToSegmentsV1(bodyJsonArg, SimpplrContext.isFeedRichTextEnabled, isRecognitionPost);
            List<ConnectApi.MessageSegmentInput> externalFileSegments = getExternalFilesSegments(externalFiles);
            
            if(externalFileSegments!=null && externalFileSegments.size()>0){
                inputBody.messageSegments.addAll(externalFileSegments);    
            }
            feedItemInput.body = inputBody;
        }
        
            editedFeedElement = ConnectApi.ChatterFeeds.updateFeedElement(communityIdArg, feedElementIdArg,
                    feedItemInput);
        }
        
        return editedFeedElement;
    }
    
    public static Boolean deleteComment (String communityIdArg, String commentIdArg) {
        ConnectApi.ChatterFeeds.deleteComment(communityIdArg, commentIdArg);
        return true;
    }
    
    public static ConnectApi.Comment updateComment (String communityIdArg, String commentIdArg,
     	    String commentBodyArg, String bodyJsonArg, List<Criteria.ExternalFileWrapper>  externalFiles) {
        String textToProcess = commentBodyArg;
        String processedStr = '';
        List<File__c> listOfFileToInsert = new List<File__c>();
        
        if (string.isNotBlank(textToProcess) && textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0) { // checking if google/ box file is present. 
            String extFilesStr =  textToProcess.substring(textToProcess.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
                    2, textToProcess.length()); // External file string extracted 
            processedStr = commentBodyArg.substring(0, commentBodyArg.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR)); // textbody without ext files
            List<String> listOfExtFile = new List<String>();
            listOfExtFile= extFilesStr.split('\n'); // Files are seprated by newline 
            
            if (!listOfExtFile.isEmpty()) {
                processedStr = processedStr + ServiceConstants.FEED_EXT_FILE_SEPRATOR;
                
                for (String singleExtFile: listOfExtFile) {
                    List<String> listOfSingleExtFileProp = new List<String>();
                    listOfSingleExtFileProp = singleExtFile.split('\\|'); // File properties are seprated by | symbol 
                    processedStr = processedStr + '\n'; // adding new line for new file
                    
                    if (listOfSingleExtFileProp.size() > 5) {
                        processedStr = processedStr + listOfSingleExtFileProp[5].trim()  + '&fileName=' + EncodingUtil.urlEncode(listOfSingleExtFileProp[0].trim(), 'UTF-8') +'&size='+ Integer.valueOf(listOfSingleExtFileProp[2].trim()); // adding url to text
                    }
                    
                }
                
            }
        
        } else {
            if(externalFiles!=null && externalFiles.size()>0){
                for(Criteria.ExternalFileWrapper externalfile: externalFiles){
                    File__c fileObj = convertToFileObjFromExternalFileWrapper(externalfile);
                    listOfFileToInsert.add(fileObj);
                }
            }
            processedStr = commentBodyArg;
        }
        
        ConnectApi.CommentInput commentInputObj = new ConnectApi.CommentInput();
        if(String.isBlank(bodyJsonArg) || bodyJsonArg.length()<5){
            commentInputObj.body = processToSegments(processedStr, SimpplrContext.isFeedRichTextEnabled, false);
        }else{
            ConnectApi.MessageBodyInput inputBody =  processToSegmentsV1(bodyJsonArg, SimpplrContext.isFeedRichTextEnabled, false);
            List<ConnectApi.MessageSegmentInput> externalFileSegments = getExternalFilesSegments(externalFiles);
            
            if(externalFileSegments!=null && externalFileSegments.size()>0){
                inputBody.messageSegments.addAll(externalFileSegments);    
            }
            commentInputObj.body = inputBody;
 
        }
        
        ConnectApi.Comment commentObj = ConnectAPI.ChatterFeeds.updateComment(communityIdArg, commentIdArg,
                commentInputObj);
        return commentObj;		
    }
    
    public static ConnectAPI.FeedElementPage feedUpdateSinceForCompany (String communityIdArg, String feedTypeArg,
    		Integer recentCommentCountArg, String densityArg, String pageParamArg, Integer pageSizeArg,
    		String  updatedSinceArg) {
        ConnectApi.FeedElementPage feedElementPageObj;
        
        if (densityArg.equalsIgnoreCase('AllUpdates')) {
            feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Company, recentCommentCountArg, ConnectApi.FeedDensity.AllUpdates,
                    pageParamArg, pageSizeArg, updatedSinceArg);
        } else {
            feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Company, recentCommentCountArg, ConnectApi.FeedDensity.FewerUpdates,
                    pageParamArg, pageSizeArg, updatedSinceArg);
        }
        
        return feedElementPageObj;
    }
    
    public static ConnectAPI.FeedElementPage feedUpdateSince (String communityIdArg, String feedTypeArg,
     		String subjectIdArg, Integer recentCommentCountArg, String densityArg, String pageParamArg,
     		Integer pageSizeArg, String updatedSinceArg) {
        ConnectApi.FeedElementPage feedElementPageObj;
        
        if (densityArg.equalsIgnoreCase('AllUpdates')) {
            
            if (feedTypeArg.equalsIgnoreCase('Record')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Record, subjectIdArg, recentCommentCountArg,
                    ConnectApi.FeedDensity.AllUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            } else if (feedTypeArg.equalsIgnoreCase('Groups')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Groups, subjectIdArg, recentCommentCountArg,
                    ConnectApi.FeedDensity.AllUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            } else if (feedTypeArg.equalsIgnoreCase('People')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.People, subjectIdArg, recentCommentCountArg, 
                    ConnectApi.FeedDensity.AllUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            } else if (feedTypeArg.equalsIgnoreCase('Files')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Files, subjectIdArg, recentCommentCountArg, 
                    ConnectApi.FeedDensity.AllUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            }  else {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.news, subjectIdArg, recentCommentCountArg, 
                    ConnectApi.FeedDensity.AllUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            }
            
        } else {
            
            if (feedTypeArg.equalsIgnoreCase('Record')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Record, subjectIdArg, recentCommentCountArg,
                    ConnectApi.FeedDensity.FewerUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            } else if (feedTypeArg.equalsIgnoreCase('Groups')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Groups, subjectIdArg, recentCommentCountArg,
                    ConnectApi.FeedDensity.FewerUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            } else if (feedTypeArg.equalsIgnoreCase('People')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.People, subjectIdArg, recentCommentCountArg, 
                    ConnectApi.FeedDensity.FewerUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            } else if (feedTypeArg.equalsIgnoreCase('Files')) {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.Files, subjectIdArg, recentCommentCountArg, 
                    ConnectApi.FeedDensity.FewerUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            
            }  else {
                ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(communityIdArg,
                    ConnectApi.FeedType.news, subjectIdArg, recentCommentCountArg, 
                    ConnectApi.FeedDensity.FewerUpdates, pageParamArg, pageSizeArg, updatedSinceArg);
            }
        }
        
        return feedElementPageObj;
    }
    
    public static ConnectApi.Photo setProfilePhoto(String communityIdArg, String userIdArg, String fileIdArg,
    		Integer versionNumber) {
        ConnectApi.Photo photoObj = ConnectApi.UserProfiles.setPhoto(communityIdArg, userIdArg,
                fileIdArg, versionNumber);
        return photoObj;
    }
    
    public static void removeProfilePhoto(String communityIdArg, String userIdArg) {
    	ConnectApi.UserProfiles.deletePhoto(communityIdArg, userIdArg);
    }

    public static List<ConnectApi.BatchResult> getFeedElementsForSpecifiedIds(String communityId, 
            List<String> feedElementIds) {
        ConnectApi.BatchResult[] listOfFeedElements;
        if(Test.isRunningTest()) {
            listOfFeedElements = new List<ConnectApi.BatchResult>();
        } else {
            listOfFeedElements = ConnectApi.ChatterFeeds.getFeedElementBatch(communityId, feedElementIds);
        }
        return listOfFeedElements; 
    }
    
    public static void closeFeedElement (String communityId, String feedElementId) {
        ConnectApi.CloseCapability closeCapOBj= ConnectApi.ChatterFeeds.setFeedElementIsClosed(
            communityId, feedElementId, true);
    }

    public static List<ConnectAPI.FeedElement> getTimeLineFeed (String comumunityIdArg, 
			List<String> listOfFeedIdArg) {
		ConnectApi.BatchResult[] batchResults = FeedConnectAPIService.getFeedElementsForSpecifiedIds(comumunityIdArg, listOfFeedIdArg);
		List<ConnectAPI.FeedElement> listOfFeedElement = new List<ConnectAPI.FeedElement>();

		for (ConnectApi.BatchResult batchResult : batchResults) {
			
			if (batchResult.isSuccess()) {

				if (batchResult.getResult() instanceof ConnectApi.FeedElement) {
					ConnectApi.FeedElement feedElementObj; 
					feedElementObj = (ConnectApi.FeedElement) batchResult.getResult();
					listOfFeedElement.add(feedElementObj);
				}

			}

		}

        return listOfFeedElement;
	}

    public static ConnectApi.FeedElementPage getTimelineAndContentFeed (String communityIdArg, 
            String feedTypeArg, String subjectIdArg, String pageParamArg, 
            Integer pageSizeArg, String sortParamArg, String keyPrefixArg) {
        ConnectApi.FeedElementPage feedElementObj = ConnectAPI.ChatterFeeds.getFeedElementsFromFilterFeed(communityIdArg, 
                subjectIdArg, keyPrefixArg, pageParamArg, pageSizeArg, 
                ConnectApi.FeedSortOrder.CreatedDateDesc);
        return feedElementObj;
    }

    public static ConnectApi.FeedElementPage searchTimeLineAndContentFeed(String communityIdArg, 
            String feedTypeArg, String subjectIdArg, String pageParamArg, Integer pageSizeArg, 
            String searchStrArg, String sortParamArg) {
        ConnectApi.FeedElementPage feedElementPageObj;
        ConnectApi.FeedDensity feedDensityObj = SimpplrContext.showTrackChangesFeedPosts ? 
                ConnectApi.FeedDensity.AllUpdates : ConnectApi.FeedDensity.FewerUpdates;

        if (sortParamArg == 'activity') {
            feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFilterFeed(communityIdArg, 
                    subjectIdArg, Utility.getSimpplrContentPrefix(), 3, feedDensityObj,
                    pageParamArg, pageSizeArg, ConnectApi.FeedSortOrder.LastModifiedDateDesc, 
                    searchStrArg);
                    
        } else {
            feedElementPageObj = ConnectAPI.ChatterFeeds.searchFeedElementsInFilterFeed(communityIdArg, 
                    subjectIdArg, Utility.getSimpplrContentPrefix(), 3, feedDensityObj,
                    pageParamArg, pageSizeArg, ConnectApi.FeedSortOrder.CreatedDateDesc, 
                    searchStrArg);
        }

        return feedElementPageObj;
        
    }

    public static void initializeFeedFilesVideoParams(String parentId) {
        List<Folder__c> folderList;
        if(parentId.startsWith('0F9')) {
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', parentId);
            String folderQuery = 'select id, Site__c from Folder__c ' +
                ' where Is_System_Folder__c = true ' +
                ' And Name__c=\'Videos\' ' +
                ' And Is_Deleted__c = False' +
                ' And Parent_Folder__r.Name__c=\'Feed Files\' ' +
                ' And site__r.Chatter_Group_id__c=:soqlParam1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
            
        } else if(parentId.startsWith(Simpplr_Content__c.sObjectType.getDescribe().getKeyPrefix())) {
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', parentId);
            String folderQuery = 'select id, Site__c from Folder__c ' +
                ' where Is_System_Folder__c = true ' +
                ' And Name__c=\'Videos\' ' +
                ' And Is_Deleted__c = False' +
                ' And Parent_Folder__r.Name__c=\'Feed Files\' ' +
                ' And Site__c in (Select site__c from Simpplr_Content__c where id=: soqlParam1)';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
            
        }
        if(folderList != null && !folderList.isEmpty()) {
            feedFilesVideoFolderId = folderList[0].id;
            feedFilesVideoSiteId = folderList[0].Site__c;
        }
    }


}