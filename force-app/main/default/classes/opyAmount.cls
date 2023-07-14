public class opyAmount {
    Public static void UpdateAmount(Opportunity opp){       
        Account ac = [select name,Amount__c from account where id =:opp.AccountId];
        if(ac.Amount__c!=null){
            ac.Amount__c+=opp.Amount;
        }else{
            ac.Amount__c = opp.Amount;
        }   
        System.debug(ac.Amount__c);
        update ac;       
    }
    Public static void SubtractAmount(Opportunity opp){
        Account ac = [select name,Amount__c from account where id =:opp.AccountId];
        if(ac.Amount__c-opp.Amount!=null){
            ac.Amount__c-=opp.Amount;
        }else{
            ac.Amount__c = null;
        }
        update ac;
    }
}