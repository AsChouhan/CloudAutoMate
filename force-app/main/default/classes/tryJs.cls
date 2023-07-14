public class tryJs {
    public Boolean bool{get;set;}
    public string str{get;set;}
    public List<String> op{get;set;}
    
    {
        op = new List<String>();
        String s = 'aasheesh';
        bool = true;
        str = 'Aasheesh';
    }
    
    public void addR(){
        apexPages.addMessage(new apexPages.Message(apexpages.Severity.WARNING,'Fields not more then 10'));
        System.debug(op.size());
    }
}