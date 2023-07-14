public class TempCreate {
    public static void createRecord(){
		Account acct = new Account(Name = 'aasheesh');
    	insert acct; 
        
        Account a1 = [SELECT OwnerId FROM Account WHERE name = 'aasheesh'];
        System.debug(a1);
	}
}