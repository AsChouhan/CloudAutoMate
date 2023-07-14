trigger AutoAssingToCOn on Account (after insert) {
    List<Account> acct = Trigger.new;
    AutoAssignToContact.autoAssign(acct);
}