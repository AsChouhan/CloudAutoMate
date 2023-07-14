public class ClassTriggerAssignment {
    Map<id,List<Contact>> conMap = new Map<Id,List<Contact>>();
    Map<Id,List<Contact>> conMapExists = new Map<Id,List<Contact>>();
    List<Contact> nullSequenceNumber = new List<Contact>();
    List<Contact> contactForUpdate = new List<Contact>();
    List<Contact> TempConForTn = new List<Contact>();
    Map<id,Contact> MapC = new Map<id,Contact>();
    List<Contact> allContact = new List<Contact>();
    Integer min;
    Integer currentSeq;
    Integer max = 0;
    Boolean longSeqBool;

    //Adding existing contact record into  conMapExists..........
    public void addExistingRecord(Map<Id,List<Contact>> Ids){
        allContact = [Select Name,AccountId,Sequence_Number__c from contact WHERE AccountId in :Ids.keySet()];
        
        for(Contact ct : allContact){
            if(!conMapExists.containsKey(ct.AccountId)){
                conMapExists.put(ct.AccountId, new List<Contact>());
            }
            conMapExists.get(ct.AccountId).add(ct);
        }
        System.debug(allContact.size());
    }   
    list<Integer> op = new List<Integer>();

    public void findLongestSunSequence(List<Contact> ct){               
        Integer k = min;
        for(Integer i=0;i<ct.size();i++){              
            Integer sN = Integer.valueOf(ct[i].Sequence_Number__c);
            if(sN == k+1){
                k+=1;
                op.add(i);
                if(i < ct.size()-1 && (Integer)(ct[i+1].Sequence_Number__c) == k+1){
                    continue;
                }else{
                    i = 1;
                }
            }
        }
        System.debug(op.size());
    }

    public void addCurrentInMap(List<Contact> cList){
        min = Integer.valueOf(cList[0].Sequence_Number__c);
        for(Contact c : cList){
            if(!conMap.containsKey(c.AccountId)){
                conMap.put(c.AccountId, new List<Contact>());
            }else if(c.AccountId == null){
                continue;
            }
            if(c.AccountId != null){
                conMap.get(c.AccountId).add(c); 
                if(min>c.Sequence_Number__c){
                    min = Integer.valueOf(c.Sequence_Number__c);
                }
            }      
        }
        System.debug(min);
    }

    public void checkEqual(List<Contact> ct){
        //for()
    }


    public void OrderSequenceNumber(List<Contact> cList){        
        // Adding Account id and their Related Conatact From Trigger.New List........
        addCurrentInMap(cList);
        addExistingRecord(conMap);
        longSeqBool = true;
        for(id acctId : conMap.keySet()){
            max = 0;
            Integer totalRecord = [SELECT COUNT() FROM Contact WHERE AccountId = :acctId];
            // If That Account Has No Records in this case account id not present in Map(conMapExists).......
            if(!conMapExists.containsKey(acctId)){

                for(Integer i = 0;i<conMap.get(acctId).size();i++){     
                    conMap.get(acctId)[i].Sequence_Number__c = i+1;                     
                }                
                Continue;
            }
            for(Contact c1 : conMap.get(acctId)){  
               if(c1.Sequence_Number__c != null){
                    if(conMap.get(acctId).size()>100){
                        if(longSeqBool){
                            longSeqBool = false;
                            findLongestSunSequence(conMap.get(acctId));
                            if(op.size() == 0){
                                checkEqual(conMap.get(acctId));
                            }
                        }

                        for(Integer i=0;i<conMapExists.get(acctId).size();i++){
                            currentSeq = Integer.valueOf(conMapExists.get(acctId)[i].Sequence_Number__c);
                            if(currentSeq>=min){
                                conMapExists.get(acctId)[i].Sequence_Number__c = currentSeq+(op.size()+1);
                                MapC.put(conMapExists.get(acctId)[i].id,conMapExists.get(acctId)[i]);
                            }
                        }
                    }
                  

                 
                    if(c1.Sequence_Number__c > min+op.size()){
                        if(c1.Sequence_Number__c>totalRecord){
                            c1.Sequence_Number__c = totalRecord+1;
                            totalRecord+=1;
                        }else{
                            for(Integer i=0;i<conMapExists.get(acctId).size();i++){                        
                                if(conMapExists.get(acctId)[i].Sequence_Number__c>=c1.Sequence_Number__c){
                                    conMapExists.get(acctId)[i].Sequence_Number__c = conMapExists.get(acctId)[i].Sequence_Number__c+1;
                                    MapC.put(conMapExists.get(acctId)[i].id,conMapExists.get(acctId)[i]);
                                    totalRecord+=1;                            
                                }

                            } 
                        }
                }
                    // Check And reorder Sequence In Trigger New List........
                    
                   for(Integer j=0;j<TempConForTn.size();j++){
                        if(TempConForTn[j].Sequence_Number__c>=c1.Sequence_Number__c && TempConForTn[j]!= c1){
                            TempConForTn[j].Sequence_Number__c = TempConForTn[j].Sequence_Number__c+1;
                        }
                    }

                    TempConForTn.add(c1);    

                } else if(c1.Sequence_Number__c == null){                
                    nullSequenceNumber.add(c1);
                }
            }
            // Adding Records At Last In Which Sequence Number Is Not Defining ........

            for(Integer k=0;k<nullSequenceNumber.size();k++){
                nullSequenceNumber[k].Sequence_Number__c = totalRecord+1;
                totalRecord+=1;
            }
            
        }




        for(id vr : MapC.keySet()){
            contactForUpdate.add(MapC.get(vr));
        }
        update contactForUpdate;
    }
}