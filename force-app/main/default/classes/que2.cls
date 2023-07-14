public class que2 {
    
    public list<Integer> con = new List<Integer>();
    {
        for(Integer i = 0 ;i<10;i++){
            con.add(i);
        }
        
     
        
        
    }
    public List<Integer> copy = new List<Integer>();
    public void mettt(){
        copy = con;
        for(Integer cc : copy){
            System.debug(cc);
        }
    }
}