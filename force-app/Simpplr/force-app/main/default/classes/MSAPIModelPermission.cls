public with sharing class MSAPIModelPermission {
  	public String id;
  	public MSAPIModelUser.IdentitySet grantedTo;
  	public MSAPIModelDriveItem.ItemReference inheritedFrom;
  	public InvitationWrapper invitation;
  	public LinkWrapper link;
  	public List<String> roles; 
  	public String shareId; 
  		
	public class InvitationWrapper extends SCoreAbstractJsonSerializable {
		public String odataType;
	} 
	
	public class LinkWrapper extends SCoreAbstractJsonSerializable {
		public String odataType;
	}
}