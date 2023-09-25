public with sharing class ProfileAboutWrapper {
	public String peopleId;
	public String sfUserId;
    public String encryptedUserId;
	public String smallPhotoUrl;
	public String mediumPhotoUrl;
	public String fullPhotoUrl;
	public String firstName;
	public String lastName;
	public String department;
	public String address;
	public String title;
	public Boolean canFollow;
	public Boolean isActive;
	public String showInSimpplr;
	public Boolean isFollowing;
	public Boolean canFavorite;
	public Boolean isFavorited;
	public Boolean isBlogEnabled;
	public Boolean hasBlogs;
	public Boolean isAppManager;
	public Boolean isSystemAdmin;
	public Boolean isUnlistedAdmin;
	public Boolean canCreateTopics;
	public String extension;
	public String phone;
	public String mobile;
	public String email;
	public String aboutMe;
	public String timeZone;
    public Integer timeZoneOffset;
	public List<Expertise> expertise;
	public List<PeopleWrapper.UserCustomFieldsWrapper> profileFields;  
	
	public class Expertise{
		public String name;
		public String id;
	}

}