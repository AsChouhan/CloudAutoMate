@IsTest
public class GanreateRecForTest {
    public static list<Account> AccountRecords(){
        List<Account> accountList = new List<Account>();
        for(Integer i=1;i<=15;i++){
            accountList.add(new Account(Name = 'test'+i));
        }
        insert accountList;
        return accountList;
    }
}