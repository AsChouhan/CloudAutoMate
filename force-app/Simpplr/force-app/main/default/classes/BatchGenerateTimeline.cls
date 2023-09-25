public with sharing class BatchGenerateTimeline implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        DateTime CurrentDateTime = System.now();
        DateTime lastHour = CurrentDateTime.addHours(-1);
       
        String query = 'SELECT id, Is_Published__c, Publish_Start_DateTime__c, title__c, Type__c, ' + 
                ' Is_deleted__c, Site__c, Site__r.Chatter_group_Id__c, Site__r.Site_Type__c, Primary_Author__c, ' +
                ' (SELECT id, parentId, type FROM feeds WHERE type=\'LinkPost\') ' +
                ' FROM Simpplr_content__c WHERE (Publish_Start_DateTime__c > :lastHour ' + 
                ' OR createddate >: lastHour) ' + 
                ' AND Publish_Start_DateTime__c <=:CurrentDateTime AND Is_deleted__c=false ' + 
                ' AND Is_Published__c =true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
        List<Simpplr_Content__c> listOfSimpContent = new List<Simpplr_Content__c>();
        listOfSimpContent = (List<Simpplr_Content__c>)listOfsObject;

        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        for (Simpplr_Content__c simpObj: listOfSimpContent) {

            if (simpObj.feeds.isEmpty()) {
                String titleStr= Utility.getAllValidWords(simpObj.Title__c, 
                        simpObj.Title__c.length(), false);
                String urlStr = '';
                String groupMentionStr = '';

                if ('page'.equalsIgnoreCase(simpObj.type__c)) {
                    urlStr = PageContext.getPageURL(Pages.app) + 
                            '?u=/site/' + simpObj.site__c + '/page/' + simpObj.Id;

                } else if ('event'.equalsIgnoreCase(simpObj.type__c)) {
                    urlStr = PageContext.getPageURL(Pages.app) + 
                            '?u=/site/' + simpObj.site__c + '/event/' + simpObj.Id;
                
                } else if ('album'.equalsIgnoreCase(simpObj.type__c)) {
                    urlStr = PageContext.getPageURL(Pages.app) + 
                            '?u=/site/' + simpObj.site__c + '/album/' + simpObj.Id;                    

                } else if ('blogpost'.equalsIgnoreCase(simpObj.type__c)) {
                    urlStr = PageContext.getPageURL(Pages.app) + 
                            '?u=/people/' + simpObj.Primary_Author__c + '/blog/'+ simpObj.Id; 
                }
                if('Public'.equalsIgnoreCase(simpObj.Site__r.Site_Type__c) || 
                    ('Private'.equalsIgnoreCase(simpObj.Site__r.Site_Type__c) && 
                     chatterGroupsIFollowIdSet.contains(simpObj.site__r.Chatter_group_Id__c))) {
                    groupMentionStr = '@[' + simpObj.site__r.Chatter_group_Id__c + ']'; 
                }

                if(!Test.isRunningTest()) {
                    FeedServiceProvider.createTimeLineAndClose(null, simpObj.id, urlStr, 
                            titleStr, groupMentionStr);
                }

            } else if (simpObj.feeds.size() == 1) {
                FeedConnectAPIService.closeFeedElement(null, simpObj.feeds[0].id);
            }

        }

    }

    public void finish(Database.BatchableContext BC) {

    }
    
}