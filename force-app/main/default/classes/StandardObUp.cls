public class StandardObUp {
	List<Account> a1 = [Select Name from Account];
    public void AccountUp(){
        for(Integer i=1;i<a1.size();i++){
        	a1[i].name = 'new '+i;
        }upsert a1;        
    }
    public void AccountIn(){
        Account a2 = new Account(Name = 'Created New1');
        Account a3= new Account(Name = 'Created New2');
        a1.add(a2);a1.add(a3);
        upsert a1;
    }
    
}