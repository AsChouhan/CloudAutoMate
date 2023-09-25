public abstract class GDAPIModelAbstract extends SCoreAbstractJsonSerializable {
	//Instance Variables
	private String kind;								//The kind of Google Drive object

	// Constructor
	public GDAPIModelAbstract(String kind) {
		this.kind = kind;
	}
	
	// Getter & Setter Methods
	public String getKind() {
		return kind;
	}
}