public class AutoAssignToContact {
    public static void autoAssign(List<Account> acct){
		List<Contact> con = new List<Contact>();
        for(Account ac:acct){
			Contact c1 = new Contact();
            c1.LastName = ac.Name;
            c1.AccountId = ac.Id;
            con.add(c1);
        }
        insert con;
    }
}