public class DML_INSERT {
    List<Account> l1 = new List<Account>();
    Public void addinAccount(Integer n){
        for(Integer i=1;i<=n;i++){
            Account a = new Account(Name = 'ashish '+i);
            l1.add(a);
        }
        
        insert l1;
            
    }
}