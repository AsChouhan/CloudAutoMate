public class PageQue1 {
    public Account a{get;set;}
    ID ids{get;set;}
    Boolean bool{get;set;}
    String url{get;set;}
    id Ownerid = apexpages.currentPage().getparameters().get('owner.id');
    
    {
        a = new Account();       
    }   
  
    public pageReference save1(){        
        upsert a;
        ids = a.id;
        pageReference redirect1 = new pageReference('/'+a.id);
        return redirect1;
    }
    
    public void QuickSave1(){        
        insert a;
		bool =true;          
    }
    
    public pageReference Cancel1(){    
        String pageName = ApexPages.currentPage().getUrl().split('apex/')[1];
        pageReference redirect1 = new pageReference('https://briskmind9-dev-ed--c.vf.force.com/apex/'+pageName+'?core.apexpages.request.devconsole=1');
        return redirect1;
    }
    
    public pageReference Edit1(){           
        pageReference redirect1 = new pageReference('https://briskmind9-dev-ed.my.salesforce.com/'+a.id+'/e?retURL=%2F'+a.id);        
        return redirect1;
    }
    
    public pageReference Delete1(){
		Delete a;
        pageReference redirect1 = new pageReference('https://briskmind9-dev-ed.my.salesforce.com/001/o');       
        return redirect1;
    }
}