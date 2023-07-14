public class TriggerAsignent2023 {
    public Map<Id,Map<Decimal,Contact>> ImpMap = new Map<Id,Map<Decimal,Contact>>();
    public Map<Id,List<Contact>> newRecConMap = new Map<Id,List<Contact>>();
    Map<Id,Map<Id,Contact>> MapUndelete = new Map<Id,Map<Id,Contact>>();
    public List<Contact> existRecords = new List<Contact>();
    public List<Contact> wrongSnList = new List<Contact>();
    public List<Contact> nullSnList = new List<Contact>();
    public List<Contact> greaterSnList = new List<Contact>();
    public List<Contact> contactForUpdate = new List<Contact>();
    public static Boolean recursive = true;
    public static Integer enterOrNot;
    public Decimal tempK = 0;
    public Integer addIn = 1;
    Integer lastSnNumber;
    Integer range;


    // Add undeleted records in map for undelete operaton..........
    public void addIntoUndeleteMap(List<Contact> cList){
        for(Contact ct : cList){
            if(!MapUndelete.containsKey(ct.AccountId)){
                MapUndelete.put(ct.AccountId,new Map<Id,Contact>());
            }if(ct.AccountId != null){
                MapUndelete.get(ct.AccountId).put(ct.Id,ct);
            }
        }
    }

    // Undelete method....
    public void afterUndelete(List<Contact> cList){
        addIntoUndeleteMap(cList);
        for(Id acctId : MapUndelete.keySet())
        {
            List<Contact> tempCon = [SELECT name,Sequence_Number__c FROM Contact WHERE AccountId = : acctId];
            Integer lastSn = tempCon.size();
            for(Contact ct : tempCon){
                if(MapUndelete.get(acctId).containsKey(ct.id)){
                    ct.Sequence_Number__c = lastSn;
                    contactForUpdate.add(ct);
                    lastSn+=1;
                }
            }
        }
        recursive = false;
        update contactForUpdate;
        recursive = true;
    }

    // Delete method...........
    public void afterdelete(List<Contact> cList){
        addNewIntoMap(cList);
        System.debug('inside after delete ...');
        for(Id acctId : newRecConMap.keySet()){
            existRecords.clear();
            existRecords = [SELECT name,Sequence_Number__c FROM Contact WHERE AccountId = :acctId ORDER BY Sequence_Number__c];
            for(Integer i=0;i<existRecords.size();i++){
                existRecords[i].Sequence_Number__c = i+1;
                System.debug(i+1);
            }
            recursive = false;
            update existRecords;
            recursive = true;
        }
    }

    // added trigger.new records into map..............
    public void addNewIntoMap(List<Contact> cList){
        System.debug('inside collection map...');
        for(Contact c : cList){
            if(!newRecConMap.containsKey(c.AccountId)){
                newRecConMap.put(c.AccountId, new List<Contact>());
            }else if(c.AccountId == null){
                continue;
            }
            if(c.AccountId != null){
                newRecConMap.get(c.AccountId).add(c);                 
            }      
        }
    }

    // Seprate record comes in trigger.new List (LIKE nulls,wrong sequence number or sequence within range)...........
    public void mainMethod(Id acctId){
        enterOrNot = 1;
        existRecords.clear();
        nullSnList.clear();
        wrongSnList.clear();
        greaterSnList.clear();
        existRecords = [SELECT name,Sequence_Number__c FROM Contact WHERE AccountId = :acctId ORDER BY Sequence_Number__c];
        range = existRecords.size()+newRecConMap.get(acctId).size();
        
        for(Integer i=newRecConMap.get(acctId).size()-1;i>=0;i--){
            if(newRecConMap.get(acctId)[i].Sequence_Number__c<1){
                wrongSnList.add(newRecConMap.get(acctId)[i]);
            }else if(newRecConMap.get(acctId)[i].Sequence_Number__c >range){
                greaterSnList.add(newRecConMap.get(acctId)[i]);
            }else if(newRecConMap.get(acctId)[i].Sequence_Number__c == null){
                nullSnList.add(newRecConMap.get(acctId)[i]);
            }else{
                if(!ImpMap.containsKey(acctId)){
                    ImpMap.put(acctId, new Map<Decimal,Contact>());
                }
                if(!ImpMap.get(acctId).containsKey(newRecConMap.get(acctId)[i].Sequence_Number__c)){
                    ImpMap.get(acctId).put(newRecConMap.get(acctId)[i].Sequence_Number__c, newRecConMap.get(acctId)[i]);
                    enterOrNot+=1;
                }else{                  
                    tempk = newRecConMap.get(acctId)[i].Sequence_Number__c ;
                    for(Decimal k=newRecConMap.get(acctId)[i].Sequence_Number__c;k<=range;k++){
                        newRecConMap.get(acctId)[i].Sequence_Number__c = k;         
                        if(!ImpMap.get(acctId).containsKey(newRecConMap.get(acctId)[i].Sequence_Number__c)){
                            ImpMap.get(acctId).put(newRecConMap.get(acctId)[i].Sequence_Number__c, newRecConMap.get(acctId)[i]);
                            enterOrNot+=1;
                            break;
                        }
                        if(k == range){
                            for(Integer p=1;p<tempk;p++){
                                System.debug('1 comes');
                                newRecConMap.get(acctId)[i].Sequence_Number__c = p;
                                if(!ImpMap.get(acctId).containsKey(newRecConMap.get(acctId)[i].Sequence_Number__c) ){
                                    ImpMap.get(acctId).put(newRecConMap.get(acctId)[i].Sequence_Number__c, newRecConMap.get(acctId)[i]);
                                    enterOrNot+=1;
                                    break;
                                }
                            }
                        }
                    }
                }
            }            
        }  
        lastSnNumber = existRecords.size() + enterOrNot;
        for(Integer i=nullSnList.size()-1;i>=0;i--){
            nullSnList[i].Sequence_Number__c = lastSnNumber;
            lastSnNumber+=1;
        } 
        for(Integer i=0;i<wrongSnList.size();i++){
            wrongSnList[i].Sequence_Number__c = lastSnNumber;
            lastSnNumber+=1;
        }
        for(Integer i=0;i<greaterSnList.size();i++){
            greaterSnList[i].Sequence_Number__c = lastSnNumber;
            lastSnNumber+=1;
        }      
    }

    // Insert Method............
    public void OrderSequenceNumber(List<Contact> cList){       
        addNewIntoMap(cList);

        for(Id acctId : newRecConMap.keySet()){
            mainMethod(acctId);              
         
              if(enterOrNot>1){
                for(Integer i=0;i<existRecords.size();i++){
                    if(!ImpMap.get(acctId).containsKey(existRecords[i].Sequence_Number__c)){      
                        if(existRecords[i].Sequence_Number__c == 1){
                        }               
                        ImpMap.get(acctId).put(existRecords[i].Sequence_Number__c, existRecords[i]);
                        contactForUpdate.add(existRecords[i]);                     
                    }else{                       
                        for(Integer k=1;k<=newRecConMap.get(acctId).size();k++){
                            existRecords[i].Sequence_Number__c = existRecords[i].Sequence_Number__c + 1;
                            if(!ImpMap.get(acctId).containsKey(existRecords[i].Sequence_Number__c)){
                                ImpMap.get(acctId).put(existRecords[i].Sequence_Number__c, existRecords[i]);
                                contactForUpdate.add(existRecords[i]);
                                break;
                            }                     
                        }                 
                    }
                } 
            }  
            enterOrNot = 1;               
        }
        recursive = false;       
            update contactForUpdate;    
        recursive = true;
    }
// Static varibales for update...........
    public static Set<Id> listOfContactId = new Set<Id>();
    public static Set<Id> listOfAccountId = new Set<Id>();
    public static List<Contact> allContact = new List<Contact>();
    public static Map<Id,Map<Decimal,contact>> newImpMap = new Map<Id,Map<Decimal,Contact>>();
    public static Map<Id,List<Contact>> existingRecordsMap = new Map<Id,List<Contact>>();
    public static Map<Id,List<Contact>> updatingRecordsMap = new Map<Id,List<Contact>>();
    public static List<Contact> updateOn = new List<Contact>();
    public static List<Contact> addedToLast = new List<Contact>();
    public static Integer highest;
    public static Integer rangeforthis;
    public static Integer inc;
    public static Boolean arrengeBool = true;

    public static List<Contact> sendForInsert = new List<Contact>();
    // Itrate list of contact which gone be update and add into map.........
    public static void beforeUpdateConSeq(List<Contact> newConList , Map<Id,Contact> oldMap){
        updateOn.clear();
        updatingRecordsMap.clear();
        existingRecordsMap.clear();
        newImpMap.clear();
        sendForInsert.clear();

        for(Contact ct : newConList){
            if(!updatingRecordsMap.containsKey(ct.AccountId)){
                updatingRecordsMap.put(ct.AccountId,new List<Contact>());
            }
            if(ct.AccountId != null){
                updatingRecordsMap.get(ct.AccountId).add(ct);
            }          
        }
        set<Id> oldIds = new Set<Id>();
        for(Id oId : oldMap.keySet()){
            oldIds.add(oldMap.get(oId).AccountID);
        }
        for(Id ids : updatingRecordsMap.keySet()){
            oldIds.add(ids);
        }
        System.debug(oldIds);
        // geting all existing contact and add into map........
        allContact = [SELECT name,Sequence_Number__c,AccountId FROM Contact WHERE AccountId IN :oldIds AND Id NOT IN :newConList ORDER BY Sequence_Number__c];
        System.debug(allContact.size()+'  '+oldIds.size());
       
        for(Contact ct : allContact){
            if(!existingRecordsMap.containsKey(ct.AccountId)){
                existingRecordsMap.put(ct.AccountId,new List<Contact>());
            }
            existingRecordsMap.get(ct.AccountId).add(ct);
        }
        Integer tempk1;
        for(Id acctId : updatingRecordsMap.keyset()){
            inc = 1;
            highest = (existingRecordsMap.containsKey(acctId))? existingRecordsMap.get(acctId).size()+1:1;
            rangeforthis = (highest-1)+updatingRecordsMap.get(acctId).size();
            for(Contact ct : updatingRecordsMap.get(acctId)){
                if(ct.AccountId == oldMap.get(ct.Id).AccountId){
                    if(ct.Sequence_Number__c < 1 || ct.Sequence_Number__c == null || ct.Sequence_Number__c > rangeforthis){                           
                        ct.Sequence_Number__c = highest++;
                        if(!newImpMap.containsKey(acctId)){
                            newImpMap.put(acctId,new Map<Decimal,contact>());
                        }
                        newImpMap.get(acctId).put(ct.Sequence_Number__c,ct);
                    }else{
                        if(!newImpMap.containsKey(acctId)){
                            newImpMap.put(acctId, new Map<Decimal,Contact>());
                        }
                        if(!newImpMap.get(acctId).containsKey(ct.Sequence_Number__c)){
                            newImpMap.get(acctId).put(ct.Sequence_Number__c, ct);
                           inc+=1;
                        }else{                  
                            tempk1 = Integer.valueOf(ct.Sequence_Number__c);                            
                            for(Decimal k=ct.Sequence_Number__c;k<=rangeforthis;k++){                          
                                ct.Sequence_Number__c = k;         
                             
                                if(!newImpMap.get(acctId).containsKey(ct.Sequence_Number__c)){
                                    newImpMap.get(acctId).put(ct.Sequence_Number__c, ct);
                                    inc+=1;
                                    break;
                                }
                                if(k == rangeforthis){
                                    for(Integer p=1;p<tempk1;p++){
                                        ct.Sequence_Number__c = p;
                                        if(!newImpMap.get(acctId).containsKey(ct.Sequence_Number__c) ){
                                            newImpMap.get(acctId).put(ct.Sequence_Number__c, ct);
                                            inc+=1;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else if(ct.AccountId != oldMap.get(ct.Id).AccountId){
                    System.debug('comes in reprenting');
                    updateOn.clear();
                    Integer seqNo = 1;
                    ct.Sequence_Number__c = null;
                    sendForInsert.add(ct);
                    if(existingRecordsMap.containsKey(oldMap.get(ct.Id).AccountId)){
                        for(Contact ct1 : existingRecordsMap.get(oldMap.get(ct.Id).AccountId)){
                                ct1.Sequence_Number__c = seqNo++;
                                updateOn.add(ct1);
                        }
                        System.debug(existingRecordsMap.get(oldMap.get(ct.Id).AccountId).size());
                        System.debug(seqNo);
                    }
                    arrengeBool = false;               
                }        
            }  
            System.debug(sendForInsert.size());

            // call inserrt method for insert thats records into new account...........
            callInstance(sendForInsert); 

         // Check in Existing Record and Rearrenge order of sequence...........   
            if(existingRecordsMap.containsKey(acctId) && arrengeBool){                    
                    for(Integer i=0;i<existingRecordsMap.get(acctId).size();i++){
                        if(!newImpMap.get(acctId).containsKey(existingRecordsMap.get(acctId)[i].Sequence_Number__c)){      
                            newImpMap.get(acctId).put(existingRecordsMap.get(acctId)[i].Sequence_Number__c, existingRecordsMap.get(acctId)[i]);
                            updateOn.add(existingRecordsMap.get(acctId)[i]);                     
                        }else{   
                            Integer tem = Integer.valueof(existingRecordsMap.get(acctId)[i].Sequence_Number__c);                    
                            for(Decimal k=existingRecordsMap.get(acctId)[i].Sequence_Number__c;k<=rangeforthis;k++){
                                existingRecordsMap.get(acctId)[i].Sequence_Number__c = k ;
                                if(!newImpMap.get(acctId).containsKey(existingRecordsMap.get(acctId)[i].Sequence_Number__c)){
                                    newImpMap.get(acctId).put(existingRecordsMap.get(acctId)[i].Sequence_Number__c, existingRecordsMap.get(acctId)[i]);
                                    updateOn.add(existingRecordsMap.get(acctId)[i]);
                                    break;
                                } 
                                if(k == rangeforthis){
                                    for(Integer po = 1;po<tem;po++){
                                        existingRecordsMap.get(acctId)[i].Sequence_Number__c = po;
                                        if(!newImpMap.get(acctId).containsKey(existingRecordsMap.get(acctId)[i].Sequence_Number__c)){
                                            newImpMap.get(acctId).put(existingRecordsMap.get(acctId)[i].Sequence_Number__c, existingRecordsMap.get(acctId)[i]);
                                            updateOn.add(existingRecordsMap.get(acctId)[i]);
                                            break;
                                        }
                                    }
                                }                    
                            }                 
                        }
                    } 
                }  
        }
        recursive = false;
        update updateOn;
        recursive = true;
        arrengeBool = true;
    } 

    // Static Method for call insert ................
    public static void callInstance(List<Contact> cList){
        TriggerAsignent2023 tt = new TriggerAsignent2023();
        tt.OrderSequenceNumber(cList);
    }
}