trigger TriggerAssignment on Contact (before insert,after undelete, after delete,before update) {  
    TriggerAsignent2023 taInst = new TriggerAsignent2023();   
 /*   // strt try....
    if(TriggerAsignent2023.bool12){
        TriggerAsignent2023.chunksValue = (Math.mod(limits.getDmlRows(),200) == 0)?(limits.getDmlRows()/200):((limits.getDmlRows()/200)+1);
        //Integer j = limits.getDmlRows()/200;
        System.debug(limits.getDmlRows()+'   '+TriggerAsignent2023.chunksValue);
        TriggerAsignent2023.bool12 = false;
    }
    /*if(Trigger.isBefore){
        if(Trigger.isInsert){

           taInst.countRecords();
        }
    }*/
    // End try......  */
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            System.debug('insert called');
            taInst.OrderSequenceNumber(trigger.new);
        }else if(Trigger.isUpdate && TriggerAsignent2023.recursive){
            System.debug('update called');
            TriggerAsignent2023.beforeUpdateConSeq(Trigger.new,Trigger.oldMap);
        }
    }else if(Trigger.isAfter){
        System.debug('inside after....');        
        if(Trigger.isDelete){
            System.debug('delete called');
            taInst.afterdelete(trigger.old);
        }else if(Trigger.isUndelete){
            taInst.afterUndelete(Trigger.new);
        }
    }
}