public class FilterClass {
    public list<SelectOption> op{get;set;}

    public List<Account> acct{get;set;}    
    public string act{get;set;}

    id ids = userinfo.getUserId();
    
    {
		acct = [select name,rating,industry from account ];
    }
    public  FilterClass(){
       
        op = new List<selectOption>{
        new SelectOption('select name,rating,industry from account','All Account'),
        new SelectOption('select name,rating,industry from account where ownerid = : ids','My Account'),        
        new SelectOption('select name,rating,industry from account where createddate = last_week','New Last Week'),
        new SelectOption('select name,rating,industry from account where createddate = last_month ','New Last Month')
        };        
    }   
   public void dsVal(){       
        acct.clear();   
        System.debug(act);
        acct = database.query(act); 

    }  
}