public class GenrateRecords {
    public static void gR(Lead l1){
        Lead obj = [select name from Lead where id =: l1.id];
        Account ac = new Account(Name ='l1'+obj.Name);
        
        upsert ac;
        
        /* List<Account> a1 = new List<Account>();
         List<Contact> c1 = new List<Contact>();
         List<Opportunity> o1 = new List<Opportunity>();
        for(Lead le:l1){            
            Account ac = new Account(Name = le.Name);
            Contact con = new Contact(LastName = le.Name);
            Opportunity op = new Opportunity(Name = le.Name,CloseDate = date.Today(),StageName = 'Closed Won1212');
            a1.add(ac);c1.add(con);
        }*/
    }
}