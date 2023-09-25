/**
 * This class contains unit tests for validating the behavior of Apex class GDAPIModelPermission 
 */
@isTest
private class GDAPIModelPermissionTest {

    static GDAPIModelPermission permission = GDAPITestDataFactory.createPermission();
    
    @isTest static void getIdTest() {
        
        System.assertEquals(permission.getId(),'kj4jk53ii64joo6o2o8k5');
    }
    
    @isTest static void getTypeTest() {
        
        System.assertEquals(permission.getType(),'user');
        permission.setType('write');
        System.assertEquals(permission.getType(),'write');
    }
    
    @isTest static void getEmailAddressTest() {
        
        System.assertEquals(permission.getEmailAddress(),'test@test.com');
        permission.setEmailAddress('test1@test.com');
        System.assertEquals(permission.getEmailAddress(),'test1@test.com');
    }
    
    @isTest static void getDomainTest() {
        
        System.assertEquals(permission.getDomain(),'test.com');
        permission.setDomain('test1.com');
        System.assertEquals(permission.getDomain(),'test1.com');
    }
    
    @isTest static void getRoleTest() {
        
        System.assertEquals(permission.getRole(),'writer');
        permission.setRole('commenter');
        System.assertEquals(permission.getRole(),'commenter');
    }
    
    @isTest static void getAllowFileDiscoveryTest() {
        
        System.assertEquals(permission.getAllowFileDiscovery(),true);
        permission.setAllowFileDiscovery(false);
        System.assertEquals(permission.getAllowFileDiscovery(),false);
    }
    
    @isTest static void getDisplayNameTest() {
        
        System.assertEquals(permission.getDisplayName(),'displayName');
    }
    
    @isTest static void getPhotoLinkTest() {
        
        System.assertEquals(permission.getPhotoLink(),'https://www.test.com/test.jpeg');
    }
    
    @isTest static void getExpirationTimeTest() {
        
        System.assertEquals(permission.getExpirationTime(),DateTime.newInstanceGmt(2017, 6, 6, 10, 3, 3));
        permission.setExpirationTime(DateTime.newInstance(2017, 6, 6, 4, 3, 3));
        System.assertEquals(permission.getExpirationTime(),DateTime.newInstance(2017, 6, 6, 4, 3, 3));
    }
    
    @isTest static void getTeamDrivePermissionDetailsTest() {
    	String tdpdString = '{"teamDrivePermissionType":"file member",'+
								'"role":"writer",'+
								'"inheritedFrom":"kj4jk53ii64joo6o2o8k5",'+
								'"inherited":true}';
		GDAPIModelPermission.TeamDrivePermissionDetail tdpd = (GDAPIModelPermission.TeamDrivePermissionDetail)
					JSON.deserialize(tdpdString,GDAPIModelPermission.TeamDrivePermissionDetail.class);															
        
        System.assertEquals(permission.getTeamDrivePermissionDetails().size(),1);
        //to test set method
        tdpdString = '{"teamDrivePermissionType":"file1 member",'+
								'"role":"commenter",'+
								'"inheritedFrom":"kj4jk53ii64joo6o2o8k5",'+
								'"inherited":true}';	
		tdpd = new GDAPIModelPermission.TeamDrivePermissionDetail();
		tdpd = (GDAPIModelPermission.TeamDrivePermissionDetail)
					JSON.deserialize(tdpdString,GDAPIModelPermission.TeamDrivePermissionDetail.class);							
        permission.setTeamDrivePermissionDetails(new List<GDAPIModelPermission.TeamDrivePermissionDetail>{tdpd});
        System.assertEquals(permission.getTeamDrivePermissionDetails().size(),1);
    }
}