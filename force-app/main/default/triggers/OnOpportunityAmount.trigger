trigger OnOpportunityAmount on Opportunity (before insert,before delete) {
    if(Trigger.isInsert)
    {
        List<opportunity> op = Trigger.new;
        for(Opportunity opp:op){           
            opyAmount.UpdateAmount(opp);
        }    
    }else{
        List<Opportunity> opp1 = Trigger.old;
        for(Opportunity op1:opp1){
            opyAmount.SubtractAmount(op1);
        }
    }
}