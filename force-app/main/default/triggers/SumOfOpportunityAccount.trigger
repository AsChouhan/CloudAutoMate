trigger SumOfOpportunityAccount on Opportunity (after insert,after update,after delete) {   
    
    List<Opportunity> op = [Select Name from Opportunity];
    List<Account> acct = [Select Name from Account];
    
    for(Account acc : acct){
        ChangeFieldAccount.ChangeAmount(acc);
    }
    
    /*for(Opportunity opp : op){
        ChangeFieldAccount.ChangeAmount(opp);
    }*/
}