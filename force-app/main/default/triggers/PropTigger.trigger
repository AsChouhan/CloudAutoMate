trigger PropTigger on Property__c (before insert) {
    Property__c a = trigger.new[0];
    a.Price__c = 500000;
    a.name = a.name+' Property';
}