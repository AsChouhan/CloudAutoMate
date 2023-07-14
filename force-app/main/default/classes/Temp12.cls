public class Temp12 {
    public static void tr(){
        List<Que3__c> t1 = [select Name from Que3__c];
        Delete t1;
    }
    public static void RetriveRec(){
        DateTime dt = System.now().addHours(-1);
        List<Que3__c> DeleteData = [select name from Que3__c ALLROWS where LastModifiedDate>=:dt AND IsDeleted = True ];
        System.debug( 'list is  = '+ DeleteData);
        undelete DeleteData;
    }
}