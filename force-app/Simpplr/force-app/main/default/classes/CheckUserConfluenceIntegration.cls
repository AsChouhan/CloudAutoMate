/**
* Class CheckUserConfulenceIntegration
* Purpose:  Class to authenticate user's confluence integration token if the token is invalid 
* disconnect confluence and send email to users
*
*/
public with sharing class CheckUserConfluenceIntegration {
    
    /**
     * @description call method to call Lambda function to authenticate user oauth tokens
     */
    public static void callConfluenceLambda(Boolean runNext){
        if(SimpplrContext.isAtlassianConnected) {
            AtlassianService.refreshUserTokens();
        }
        if(runNext){
            if(SimpplrContext.isGdriveConnected || SimpplrContext.isGoogleCalendarEnabled){
                PeopleDataServer.refreshUserGoogleToken();
            }
        }
    }
}