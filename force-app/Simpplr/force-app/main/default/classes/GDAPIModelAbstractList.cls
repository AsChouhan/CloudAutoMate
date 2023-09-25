public abstract class GDAPIModelAbstractList extends GDAPIModelAbstract {
	//Instance Variables
	private String nextPageToken;		//The page token for the next page of files. This will be absent if the end of the files list has been reached. If the token is rejected for any reason, it should be discarded, and pagination should be restarted from the first page of results.
		
	// Constructor
	public GDAPIModelAbstractList(String kind) {
		super(kind);
	}

	public String getNextPageToken() { return this.nextPageToken; }	
}