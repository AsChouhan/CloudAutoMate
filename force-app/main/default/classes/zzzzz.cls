public class zzzzz {
    public static void asd(){
        list<account> acct = new List<Account>();
        String s = 'name = :userinfo.getusername()';
        acct = database.query('select name from account where '+s);
        System.debug(acct);
}
}