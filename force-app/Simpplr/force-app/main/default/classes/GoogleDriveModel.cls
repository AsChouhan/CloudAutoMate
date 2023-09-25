public with sharing class GoogleDriveModel {
    public class DriveList {
        public String kind;
        public List<Drive> drives;  
        public String nextPageToken;
    }

    public class Drive {
        public String id;
        public String name;
        public String kind; 
    }

    public class MyDrive {
        public String kind;
        public List<File> files;
        public List<File> revisions;
        public String nextPageToken;
    }

    public class FileListResponse {
        public String kind;
        public String nextPageToken;
        public String totalRecords;
        public List<File> files;
        public File directory;
    }

    public class File {
        public String id;
        public String name;
        public String kind; 
        public String mimeType; 
        public String teamDriveId; 
        public String driveId;
        public String fileType; 
        public Long size; 
        public String description;
        public Boolean starred; 
        public String webViewLink; 
        public String thumbnailLink;
        public String fileExtension; 
        public Long version; 
        public DateTime modifiedTime;
        public capability capabilities;
        public List<String> parents;
        public List<Permission> permissions; 
        public List<Owner> owners;
        public Owner lastModifyingUser;
    }

    public class Owner{
        public string emailAddress;
        public string displayName;
    }

    public class FileResponse {
        public String status;
        public String message;
        public File result; 
    }

    public class DriveListResponse {
        public String status;
        public String message;
        public DriveList result; 
    }

    public class MyDriveResponse {
        public String status;
        public String message;
        public MyDrive result; 
    }

    public class AccessResponse {
        public String status;
        public String message;
        public String result; 
    }

    public class Capability {
        public Boolean canRename;
        public Boolean canShare;
        public Boolean canEdit;
        public Boolean canTrash;
        public Boolean canAddChildren;
        public Boolean canDownload;
    }

    public class Permission {
        public String kind;
        public String id;
        public String type;
        public String emailAddress;
        public String role;
        public String displayName;
        public Boolean deleted;
    }

    public class GroupPermissionResponse {
        public String status;
        public String message;
        public GroupPermission result; 
    }

    public class GroupPermission {
        public String rPermissionId;
        public String rWPermissionId;
        public String pubPermissionId;
        public String searchPermissionId;
    }

    public class RemovePermissionResp {
        public String status;
        public String message;
        public Boolean result; 
    }
    
    public class GroupMemberRequest {
        public String memberEmail;
        public String groupEmail;
    }

    public class FolderAndGroupReq {
        public String newRGroupId;
        public String newRGroupName;
        public String oldRGroupId;
        public String newRWGroupId;
        public String newRWGroupName;
        public String oldRWGroupId;
        public String folderId; 
        public String siteId;
        public String ownerId;
        public String peopleId;
        public Boolean ownerIsActive;
        public String siteType;
        public String sfFolderId;
        public String folderName;
    }

    public class RemovePermissionReq {
        public String folderId;
        public String permissionId;
    }

    public class AddPermissionReq {
        public String folderId;
        public String groupEmail;
    }

    public class MigrationFolderSummary {
        public Integer failedCount;
        public Integer successCount;
        public List<MigrateFolder> failedList;
        public List<MigrateFolder> successList;
        
    }

    public class MigrateFolder {
        public String name; 
        public String site_id; 
        public String external_folder_id;
        public String people_id;
        public String parent_id;
    } 

}