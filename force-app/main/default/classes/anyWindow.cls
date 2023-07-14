public class anyWindow {
    {
    List<Contact> con = [select name,Sequence_Number__c,AccountId from Contact];
    List<Contact> all = new List<Contact>();
    
    Map<Id,List<Contact>> conMap = new Map<Id,List<Contact>>();
    for(Contact c : con){
        if(!conMap.containsKey(c.AccountId)){
            conMap.put(c.AccountId, new List<Contact>());
        }else if(c.AccountId == null){
            System.debug(c.AccountId);
            
            continue;
        }
        conMap.get(c.AccountId).add(c);
    }
    System.debug(con.size());
    System.debug(conMap.size());
    
    for(id acctId : conMap.keySet()){
        Integer i = 1;
        for(contact ct : conMap.get(acctId)){
            ct.Sequence_Number__c = i++;
            all.add(ct);
        }
    }
    System.debug(con.size()+' '+all.size());
    System.debug(conMap.size());
    upsert all;
    }
}