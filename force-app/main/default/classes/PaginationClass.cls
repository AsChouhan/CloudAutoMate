public class PaginationClass {
    
    public List<selectoption> l1{get;set;}
    public string s{get;set;}
    public integer size{get;set;}
    
    
    
    public PaginationClass(){
        size = 5;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
        l1 = new List<SelectOption>();
        l1.add(new selectOption('5','5'));
        l1.add(new selectOption('10','10'));
        l1.add(new selectOption('50','50'));
        l1.add(new selectOption('100','100'));
    }
    
    public apexpages.standardSetController con{
        get{
            if(con == null){
              
                con = new apexpages.standardsetcontroller(database.getQueryLocator([select name,industry,rating from account]));        
                con.setPageSize(size);
            }			      
            return con;
        }
        set;
    }    
    public List<Account> getAccList(){
        return (List<Account>)con.getRecords();        
    }
    
    public void PageSize(){
		con.setPageSize(size);
    }
    
}