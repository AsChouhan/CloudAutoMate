public with sharing class PeopleLiteWrapper {
	public String id;
	public String peopleId;
	public String userId;
	public String sfUserId;
	public String name;
	public String nickname;
	public String url; 
	public String img;
	public String department;
	public String title;
	public String location;
	public String email;
	public String phone;
	public String mobile;
	public String phoneExtension;
	public String segmentId;
	public String videoCallUsername;
	public String videoCallProvider;
	
	public String about;
	public String birthday;
	public String hireDate;
	public String workAnniversary;
	public Boolean isFollowing;
	public Boolean isFavorited;
	public Boolean isActive;
	public Boolean canFollow;
	
	// --- remove below
	public String address;
	public String city;
	public String state;
	public String country;
	public Boolean isCurrentUserFollow;
	public String role;

	//TimeZone related info
	public String timezoneName;
	public String timezoneIso;
	public Integer timezoneOffset;

	/**
	 * @description wrapper class for super lite wrapper Obj
	 */
	public class PeopleMinWrapper {
		public String peopleId;
		public String sfUserId;
		public String name;
		public String img;
	}
}