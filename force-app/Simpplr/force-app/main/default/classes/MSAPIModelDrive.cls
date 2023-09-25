public with sharing class MSAPIModelDrive {
    public String id;
    public String driveType;
    public Owner owner;
    
    public class Owner{
    	public MSAPIModelUser.Identity user;
    }
    
    public class MSSiteDriveListing{
    	public List<MSAPIModelDrive> value;
    }
    
    public class BatchRequest{
		public String id;
		public String method;
		public String url;
	}

	public class BatchRequestList extends SCoreAbstractJsonSerializable {
		public List<BatchRequest> requests;
	}
	
    public class ItemListing {
    	public List<MSAPIModelDriveItem> value;
    }
}