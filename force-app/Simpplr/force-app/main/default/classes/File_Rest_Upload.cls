@RestResource(urlMapping='/file_rest_upload')
global with sharing class File_Rest_Upload {
   @HttpPost
    global static String attach(){
        return null;
    }
    @TestVisible
    private static ContentVersion createContentVersionRecord(Blob bin, String title, String pathOnClient){
        return null;
    }
}