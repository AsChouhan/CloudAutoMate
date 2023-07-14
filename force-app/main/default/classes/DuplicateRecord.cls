public class DuplicateRecord {
    public static Boolean CheckEmailInsert(Contact ct){
        List<Contact> con = [SELECT Email FROM Contact WHERE Email =: ct.Email];
        if(con.size() == 0){
            return true;
        }else return false;
    }
    
    
    public static boolean CheckEmailUpdate(Contact ct1){        
        List<Contact> con = [SELECT Email FROM Contact WHERE Email =: ct1.Email and id!=:ct1.Id];
        if(con.size() == 0){
            return true;
        }
        return false;
        
    }
}