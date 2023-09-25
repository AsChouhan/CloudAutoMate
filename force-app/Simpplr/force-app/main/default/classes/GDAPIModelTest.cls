@isTest
public with sharing class GDAPIModelTest {  
  @isTest static void GDAPIModelUser()
  {
    //Create the user class. Chain the set calls so that we can check that we correctly return the user object.
    GDAPIModelUser user = createUser();
    
    //Assert that we get the appropriate return values.
	System.assertEquals(user.getKind(), 'drive#user');
    assertUser(user);
  }
  
	private static GDAPIModelUser createUser() {
	    GDAPIModelUser user = new GDAPIModelUser();
	    user.setDisplayName('User1 Testing')
	             .setMe(true)
	             .setPermissionId('13098600474491268344')
	             .setEmailAddress('user1@test.com')
	             .setPhotoLink('https://test.com/photo.jpg');
	    
	    assertUser(user);
	    
	    return user;
  	}
  
  	private static void assertUser(GDAPIModelUser user) {
	    System.assertEquals(user.getKind(), 'drive#user');
	    System.assertEquals(user.getDisplayName(), 'User1 Testing');
	    System.assertEquals(user.getMe(), true);
	    System.assertEquals(user.getPermissionId(), '13098600474491268344');
	    System.assertEquals(user.getEmailAddress(), 'user1@test.com');
	    System.assertEquals(user.getPhotoLink(), 'https://test.com/photo.jpg');
  	}
}