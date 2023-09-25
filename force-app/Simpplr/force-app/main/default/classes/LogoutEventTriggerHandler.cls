public with sharing class LogoutEventTriggerHandler {
    
    public void OnAfterInsert (LogoutEventStream logoutEvent) {
        List<People__c> peopleList = [SELECT Id, Logout_dateTime__c FROM People__c WHERE User__c  =: logoutEvent.UserId WITH SECURITY_ENFORCED LIMIT 1];
        if(peopleList.size() > 0) {
            peopleList[0].Logout_DateTime__c = Datetime.now();
            update peopleList[0];
            // sendJwtInvalidateReqToAws(new List<String>{peopleList[0].id});
        }
    }

    @future(Callout=True)
    private static void sendJwtInvalidateReqToAws (List<String> peopleIdList){
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/jwt/invalidate'; 
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('orgId', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId',peopleIdList[0]);
        HTTPResponse res = Utility.getResponseFromAWS(endpoint, requestBody);
    }

}