trigger AutomeRecordGanrate on Lead (after insert) {
    Lead l1 = Trigger.new[0];    
    GenrateRecords.gR(l1);    
}