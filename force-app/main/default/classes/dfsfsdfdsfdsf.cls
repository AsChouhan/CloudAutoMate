public class dfsfsdfdsfdsf {
	List<account> accountList = [SELECT Name FROM Account LIMIT 20];
	ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(accountList);
    public void me()
    {
		System.debug(ssc);
    }
}