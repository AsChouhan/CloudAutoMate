public with sharing class DBAPIModelUsers {
    

	public class GetAccountArg extends SCoreAbstractJsonSerializable {
		public String account_id;

		public GetAccountArg(String account_id) {
				this.account_id = account_id;
		}
	}

  public class BasicAccount extends SCoreAbstractJsonSerializable {
		public String account_id;
		public Name name;
		public String email;
		public Boolean email_verified;
		public Boolean disabled;
		public Boolean is_teammate;
		public String profile_photo_url; //optional
		public String team_member_id; //optional
	}

	public class Name extends SCoreAbstractJsonSerializable {
		public String given_name;
		public String surname;
		public String familiar_name;
		public String display_name;
		public String abbreviated_name;
	}
}