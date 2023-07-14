public class TriggerClassAsign
 {
   /* Map<id,List<Contact>> conMap = new Map<Id,List<Contact>>();

    public void addIntoMap(List<Contact> ct,Map<id,List<Contact>> mapCon){
        for(contact c : ct){
            if(!mapCon.containsKey(c.AccountId)){
                mapCon.put(c.AccountId, new List<Contact>());                
            }else if(c.AccountId == null){
                continue;
            }
            mapCon.get(c.AccountId).add(c);   
        }
    }
    set<Integer> index = new set<Integer>();

   
    public void tempMethod(List<Contact> ct){               
        System.debug(ct.size());
        Integer k = Integer.valueOf(ct[0].Sequence_Number__c);
        index.add(0);
        for(Integer i=1;i<ct.size();i++){
            System.debug(!index.contains(i));
            if(!index.contains(i)){
                System.debug('CALLED');
                if(i == 1){
                    System.debug('called');
                }
                Integer sN = Integer.valueOf(ct[i].Sequence_Number__c);
                if(sN == k+1){
                    k+=1;
                    Index.add(i);
                    if(i < ct.size()-1 && (Integer)(ct[i+1].Sequence_Number__c) == k+1){
                        continue;
                    }else{
                        i = 1;
                    }
                }
            }
        }


        
        
        System.debug(index.size() +'    '+index);

    }

    public void OrderSequenceNumber(List<Contact> cList){
        set<id> parentIds = new Set<Id>();
       /* for(Contact con : cList){
            parentIds.add(con.Id);
        }
        for(Id actId : parentIds){
            List<Contact> conList = [select name,Sequence_Number__c from contact WHERE AccountId = :actId];
        }
      Integer k;
        for(Integer i=0;i<3;i++){
            tempMethod(cList);
            k = i;
        }
        System.debug(k);
    }    */
}