trigger DupEmailTrigger on Contact (before insert,before update) {
    List<Contact> conList = Trigger.new; 
    if(Trigger.isInsert){
        for(Contact con : conList){
            if(!DuplicateRecord.CheckEmailInsert(con)){
                con.addError('Duplicate Email Found');
            }
        }
    }else if(Trigger.isUpdate){
        List<Contact> conList2 = Trigger.new;
        for(Contact cc1 : conList2){
            if(!DuplicateRecord.CheckEmailUpdate(cc1)){
                cc1.addError('Duplicate Email Found');
            }
        }
        
    }    
}