public with sharing class WorkdayUserWrapper {
    public String employeeID;
	public String firstName;
	public String lastName;
	public String role;
	public String hireDate;
	public String aboutMe;
	public String birthDate;
	public String businessTitle;
	public String managerID;
	public String manager;
	public String department;
	public String division;
	public String location;
    public String workAddressFormattedLine1;
    public String workAddressFormattedLine2;
    public String workAddressCity;
    public String workAddressStateProvince;
    public String workAddressPostalCode;
    public String workAddressCountry;
    public String primaryWorkEmail;
    public String publicWorkPhones;
    public String publicWorkMobilePhones;
	public String nickName;
	public String companyName;
	public String extension;
	public String fax;
	public String customField1;
	public String customField2;
	public String customField3;
	public String customField4;
	public String customField5;

	public class WorkDayResponseWrapper{
		public String status;
		public String message;
		public Boolean hasMore;
		public List<Map<String, Object>> Report_Entry;
	}
}