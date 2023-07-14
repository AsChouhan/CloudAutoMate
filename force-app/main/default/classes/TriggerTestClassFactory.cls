public class TriggerTestClassFactory {
	public static List<Account> createAccounts(Integer numAccts) {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=1;i<=numAccts;i++) {
            testAccts.add(new Account(Name = 'TestAcct '+i));
        }
        insert testAccts; 
        return testAccts;
    }
    
     public static List<Contact> createContactsOne(Integer numContacts, Account acc, Integer seqNum) {
        // Create common list of contacts with single sequence number
        List<Contact> conList = new List<Contact>();
		for(Integer i=1;i<=numContacts;i++) {
            Contact con = new Contact(LastName = 'Test contact ' + i, Sequence_Number__c = seqNum, AccountId=acc.Id);
        	conList.add(con);
        }
        //insert conList;
        return conList;
    }

    public static List<Contact> createContactsMulti(Integer numContacts, Account acc, String order) {
        List<Contact> conList = new List<Contact>();
        if(order == 'ASC'){
            for(Integer i=1;i<=numContacts;i++) {
                Contact con = new Contact(LastName = 'Test contact ' + i, Sequence_Number__c = i, AccountId=acc.Id);
                conList.add(con);
            }
        }
        else{
            Integer j=numContacts;
            for(Integer i=1;i<=numContacts;i++) {
                Contact con = new Contact(LastName = 'Test contact ' + j, Sequence_Number__c = i, AccountId=acc.Id);
                j--;
                conList.add(con);
            }
        }
        //insert conList;
        return conList;
    }
}