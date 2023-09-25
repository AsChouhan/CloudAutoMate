public with sharing class MSAPIModelDriveItemVersionContainer {
	public List<MSIAPIModelDriveItemVersion> value;
	
	public class MSIAPIModelDriveItemVersion{
		public String id;
		public LastModifiedByWrapper lastModifiedBy;
		public String lastModifiedDateTime;
		public Long size;
	}   
	
	public class LastModifiedByWrapper {
		public UserWrapper user;
	}
	
	public class UserWrapper {
		public String displayName;
		public String id;
	}
}