public class GDAPIModelFileList extends GDAPIModelAbstractList {
	// Constructor
	public GDAPIModelFileList() {
		super('drive#fileList');
	}
	
	private Boolean incompleteSearch;
	private List<GDAPIModelFile> files;
	
	public Boolean getIncompleteSearch() { return this.incompleteSearch; }
	public List<GDAPIModelFile> getFiles() { return this.files; }
}