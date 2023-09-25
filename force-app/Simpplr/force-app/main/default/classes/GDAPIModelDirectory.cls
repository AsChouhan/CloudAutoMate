public with sharing class GDAPIModelDirectory  {   
    // DomainAliases Resource Representation
    public class DomainAliases extends GDAPIModelAbstract {
    	public String etag{ get; set; }
    	public String domainAliasName{ get; set; }
    	public String parentDomainName{ get; set; }
    	public Boolean verified{ get; set; }
    	public Long creationTime{ get; set; }
    	
    	public DomainAliases() {
    		super('admin#directory#domainAlias');
    	}
    }
    
    // Domains Resource Representation
    public class Domains extends GDAPIModelAbstract {
    	public String etag{ get; set; }
    	public String domainName{ get; set; }
    	public Boolean isPrimary{ get; set; }
    	public Boolean verified{ get; set; }
    	public Long creationTime{ get; set; }
    	public List<DomainAliases> domainAliases { get; set; }
    	
    	public Domains() {
    		super('admin#directory#domain');
    	}
    }
    
	// Groups.aliases Resource Representation
    public class Alias extends GDAPIModelAbstract {
    	public String id{ get; set; }
    	public String etag{ get; set; }
    	public String primaryEmail{ get; set; }
    	public String alias{ get; set; }
    	
    	public Alias() {
    		super('admin#directory#alias');
    	}
    }
    
	// Groups Resource Representation
    public class Groups extends GDAPIModelAbstract {
    	private String id;
    	private String etag;
    	private String email;
    	private String name;
    	private Long directMembersCount;
    	private String description;
    	private Boolean adminCreated;
    	private List<String> aliases;
    	private List<String> nonEditableAliases;
    	
    	// Getter & Setter Methods
    	public String getId() { return this.id; }
    	public String getEtag() { return this.etag; }
    	public String getEmail() { return this.email; }
    	public void setEmail(String email) {
    		this.email = email;
    	}
    	public String getName() { return this.name; }
    	public void setName(String name) {
    		this.name = name;
    	}
    	public Long getDirectMembersCount() { return this.directMembersCount; }
    	public String getDescription() { return this.description; }
    	public void setDescription(String des) {
    		this.description = des;
    	}
    	public Boolean getAdminCreated() { return this.adminCreated; }
    	public List<String> getAliases() { return this.aliases; }
    	public List<String> getNonEditableAliases() { return this.nonEditableAliases; }
    	
    	// Constructor
    	public Groups() {
    		super('admin#directory#group');
    	}
    }
    
	// GroupsList Resource Representation
    public class GroupsList extends GDAPIModelAbstractList {
    	public String etag{ get; set; }
		public List<Groups> groups { get; set; }
    	public String nextPageToken{ get; set; }
    	
    	public GroupsList() {
    		super('admin#directory#groups');
    	}
    }
    
	// Members Resource Representation
    public class Members extends GDAPIModelAbstract {
    	private String id{ get; set; }
    	private String etag{ get; set; }
    	private String email{ get; set; }
    	private String role{ get; set; }
    	private String type{ get; set; }
    	
    	public Members() {
    		super('admin#directory#member');
    	}
    	
    	// Getter & Setter Methods
    	public String getId() { return this.Id;	}
    	public String getEtag() { return this.etag;	}
    	public String getEmail() { return this.email; }
    	public void setEmail(String eml) {
    		this.email = eml;
    	}
    	public String getRole() { return this.role; }
    	public void setRole(String rol) {
    		this.role = rol;
    	}
    	public String getType() { return this.type; }
    }
    
	// MembersList Resource Representation
    public class MembersList extends GDAPIModelAbstractList {
    	public String etag{ get; set; }
		public List<Members> members { get; set; }
    	public String nextPageToken{ get; set; }
    	
    	public MembersList() {
    		super('admin#directory#members');
    	}
    }
}