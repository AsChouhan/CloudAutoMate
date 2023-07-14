public class Que2A {
    public List<Account> acct{get;set;}
    
    {
    	acct = [select name,rating,industry from account];
    }
    
    public pageReference save1(){        
        upsert acct;
        
        pageReference redirect1 = new pageReference('https://briskmind9-dev-ed.my.salesforce.com/001/o');
        return redirect1;
    }
    
    public void QuickSave1(){        
        upsert acct;
    }
}