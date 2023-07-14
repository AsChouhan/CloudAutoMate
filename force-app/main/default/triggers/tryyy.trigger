trigger tryyy on Account (before insert) {
  	list<Account> l = trigger.new;
    System.debug(l);
}