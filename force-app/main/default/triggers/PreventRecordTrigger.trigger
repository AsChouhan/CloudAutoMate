trigger PreventRecordTrigger on Account (before insert,before update,before delete){
    
    
if(Trigger.isInsert || Trigger.isUpdate){
    List<Account> acct = Trigger.new;
    for(Account af : acct){            
        af.addError('You Can\'t modify on that object');
        }
}else if(Trigger.isDelete){
    List<Account> Oldacct = Trigger.old;
    for(Account afk : Oldacct){
        afk.addError('You Can\'t modify on that object');
    }
}
    
    
    /*for(Id idd : acctNew.keySet()){
        /*if(acctNew.get(idd).LastModifiedDate != acctOld.get(idd).LastModifiedDate)
               acctNew.get(idd).addError('Can\'t Insert Records');  
            
              
        }*/
    }