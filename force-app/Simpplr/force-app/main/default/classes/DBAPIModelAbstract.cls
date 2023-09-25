public abstract class DBAPIModelAbstract extends SCoreAbstractJsonSerializable {
	public class ErrorClass {
		public String tag { get; set; }
	}
	
    public String error_summary { get; set; }
    public ErrorClass error { get; set; }
}