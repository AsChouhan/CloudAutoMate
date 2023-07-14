public class ChangeFieldAccount {
    public static Boolean CheckStageName(String s){
        if(s == 'Closed Won'){            
            return true;
        }
        return false;
    }
    public static List<Account> acct1 = new List<Account>();
    public static void ChangeToHot(id acct){
        Account acc = [SELECT Name,rating FROM Account WHERE id =: acct];
        acc.Rating = 'Hot';
       	acct1.add(acc);
    }  
    public static void UpdateList(){
        update acct1;
    }
}