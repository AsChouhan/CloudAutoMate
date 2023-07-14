@isTest
public class sspFactory {
    public static List<Account> createAccounts(Integer numOfAccts){
        List<Account> listOfAcc = new List<Account>();
        for(Integer i=1;i<=numOfAccts;i++){
            listOfAcc.add(new Account(Name='Acc '+i));
        }
        insert listOfAcc;
        return listOfAcc;
    }
}