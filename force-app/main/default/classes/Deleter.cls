public class Deleter {
    public static void DeleterRec(){
        Datetime dt = System.now().addhours(-2);
        List<Account> lr = [select id from Account where LastModifiedDate >=: dt];
        System.debug(lr.size());
        delete lr;
    }
    public static void EmptyRecycle(){
		List<sObject> s1 = [select name from Account allrows where isdeleted = true];
        System.debug(s1.size());
        Database.emptyRecycleBin(s1);
    }
}