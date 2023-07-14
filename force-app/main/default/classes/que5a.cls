public class que5a {
    public list<Position__c> pos{get;set;}
    {
		pos = [select name,Min_Pay__c,Max_Pay__c from position__c];        
    }
    
    public void save(){
        update pos;
    }
}