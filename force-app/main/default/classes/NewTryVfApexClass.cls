public class NewTryVfApexClass {
    static integer a1;
    //public string a{get{System.debug('getter called');return a;}set{this.a = a;System.debug('setter called');}}
    public integer b1{get;set;}
    public string accName{get;set;}
    public string accEmplyeesNo{get;set;}
    INteger b;
    
    
    public NewTryVfApexClass(){
        System.debug('Constuctor called!');
    }
    public void SaveRec(){
		Account acc = new Account(Name = accName);
        insert acc;
    }
    static{
        a1 = 10;
        System.debug('Static initilizer called!');
    }
    
    {
        b = 56;
        System.debug('instance initilizzer called!');
    }    
}