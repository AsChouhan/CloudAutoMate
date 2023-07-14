trigger PreventRecordTriggerQue3 on Que3__c (before update,before insert) {
	List<Que3__c> acct = Trigger.new;
    map<id,Que3__c> acctNew = Trigger.newmap;
    map<id,Que3__c> acctOld = Trigger.oldmap;
    for(Id idd : acctNew.keySet()){
        if(Trigger.isInsert){
            acctNew.get(idd).addError('Can\'t Insert Records');	
        }else if(acctNew.get(idd).LastModifiedDate != acctOld.get(idd).LastModifiedDate){
            acctNew.get(idd).addError('You Can\'t update or delete that records');
        }
        
    }
    
}