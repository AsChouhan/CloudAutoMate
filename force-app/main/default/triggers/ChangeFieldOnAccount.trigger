trigger ChangeFieldOnAccount on Opportunity (after insert,after update) {
    List<Opportunity> op = Trigger.new;
    for(Opportunity opp:op){
        if(ChangeFieldAccount.CheckStageName(opp.StageName)){
            ChangeFieldAccount.ChangeToHot(opp.AccountId);
        }
    ChangeFieldAccount.UpdateList();
    }
}