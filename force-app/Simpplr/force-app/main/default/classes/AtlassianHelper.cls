public with sharing class AtlassianHelper { 

    private static final String AUTH_INTEGRATION_ATLASSIAN_ENDPOINT = 'https://auth.atlassian.com/authorize';
    
    public String getAdminAuthUrl () { 
        String atlassianClientId = IntegrationConstants.ATLASSIAN_CLIENT_ID;
        String atlassianAuthEndpoint = AUTH_INTEGRATION_ATLASSIAN_ENDPOINT;
        String atlassianRedirectURlStr = 'https://api.simpplr.com/oauth/callback-passthrough';

        String atlassianScopeStr = 'read:confluence-content.summary ' + 
                                        'read:confluence-user ' + 
                                        'search:confluence ' + 
                                        'read:confluence-props ' + 
                                        'read:confluence-content.all ' + 
                                        'read:confluence-space.summary '+
                                        'read:me '+
                                        'offline_access';
                                        //'write:confluence-props ' + 
                                        //'write:confluence-content'
        
        
        String atlassianStateString = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + 
                '?state=' + IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN + 'admin' + 
                '&orgId=' + SimpplrContext.simpplrOrgId + 
                '&peopleId=' + UserContext.peopleId + 
                '&userId=' + UserContext.userId + 
                '&appName=' + SimpplrContext.applicationName +
                '&siteURL=' + SimpplrContext.atlassianInstanceUrl;

        String state = SimpplrContext.simpplrAPIEndpoint + '/oauth/atlassian?state='+EncodingUtil.urlEncode(atlassianStateString,'UTF-8');
       
        String finalRedirectUrl = EmailUtility.format(
                                            '{0}' + 
                                            '?audience=api.atlassian.com' +
                                            '&client_id={1}' + 
                                            '&scope={2}' + 
                                            '&redirect_uri={3}' +
                                            '&response_type=code' + 
                                            '&prompt=consent' +
                                            '&state={4}',
            new List<String>{
                atlassianAuthEndpoint, //0
                EncodingUtil.urlEncode(atlassianClientId, 'UTF-8'), //1
                EncodingUtil.urlEncode(atlassianScopeStr, 'UTF-8'), //2
                EncodingUtil.urlEncode(atlassianRedirectURlStr, 'UTF-8'), //3
                EncodingUtil.urlEncode(state, 'UTF-8') //4
            }
        );
        
        if(Test.isRunningTest()){
            finalRedirectUrl = 'https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=test_client_id&scope=read%3Aconfluence-content.summary+read%3Aconfluence-user+search%3Aconfluence+read%3Aconfluence-props+read%3Aconfluence-content.all+read%3Aconfluence-space.summary+read%3Ame+offline_access&redirect_uri=https%3A%2F%2Fapi.simpplr.com%2Foauth%2Fcallback-passthrough&response_type=code&prompt=consent&state=https%3A%2F%2Ftest.simpplr.com%2Foauth%2Fatlassian%3Fstate%3DstateString';
        }

        return finalRedirectUrl;  
    }

    public String getPeopleAuthUrl () { 
        String atlassianClientId = IntegrationConstants.ATLASSIAN_CLIENT_ID;
        String atlassianAuthEndpoint = AUTH_INTEGRATION_ATLASSIAN_ENDPOINT;
        String atlassianRedirectURlStr = 'https://api.simpplr.com/oauth/callback-passthrough';
 
        String atlassianScopeStr = 'read:confluence-content.summary ' + 
                                        'read:confluence-user ' + 
                                        'search:confluence ' + 
                                        'read:confluence-props ' + 
                                        'read:confluence-content.all ' + 
                                        'read:confluence-space.summary '+
                                        'read:me '+
                                        'offline_access';
                                        //'write:confluence-props ' + 
                                        //'write:confluence-content'
        
        
        String atlassianStateString = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + 
                '?state=' + IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN + 'user' + 
                '&orgId=' + SimpplrContext.simpplrOrgId + 
                '&peopleId=' + UserContext.peopleId + 
                '&userId=' + UserContext.userId + 
                '&appName=' + SimpplrContext.applicationName +
                '&siteURL=' + SimpplrContext.atlassianInstanceUrl;

        String state = SimpplrContext.simpplrAPIEndpoint + '/oauth/atlassian?state='+EncodingUtil.urlEncode(atlassianStateString,'UTF-8');
       
        String finalRedirectUrl = EmailUtility.format(
                                            '{0}' + 
                                            '?audience=api.atlassian.com' +
                                            '&client_id={1}' + 
                                            '&scope={2}' + 
                                            '&redirect_uri={3}' + 
                                            '&response_type=code' + 
                                            '&prompt=consent'+
                                            '&state={4}',
            new List<String>{
                atlassianAuthEndpoint, //0
                EncodingUtil.urlEncode(atlassianClientId, 'UTF-8'), //1
                EncodingUtil.urlEncode(atlassianScopeStr, 'UTF-8'), //2
                EncodingUtil.urlEncode(atlassianRedirectURlStr, 'UTF-8'), //3
                EncodingUtil.urlEncode(state, 'UTF-8') //4
            }
        );
        
        if(Test.isRunningTest()){
            finalRedirectUrl = 'https://auth.atlassian.com/authorize?audience=api.atlassian.com&client_id=test_client_id&scope=read%3Aconfluence-content.summary+read%3Aconfluence-user+search%3Aconfluence+read%3Aconfluence-props+read%3Aconfluence-content.all+read%3Aconfluence-space.summary+read%3Ame+offline_access&redirect_uri=https%3A%2F%2Fapi.simpplr.com%2Foauth%2Fcallback-passthrough&response_type=code&prompt=consent&state=https%3A%2F%2Ftest.simpplr.com%2Foauth%2Fatlassian%3Fstate%3DstateString';
        }
        
        return finalRedirectUrl;  
    }

    public Boolean upsertAppIntegrationRecord (String aUserId, String aUserName, String aUserEmail) {
        App_Integration__c appIntObj = new  App_Integration__c();
        Boolean isRecordExist = false; 

        if (SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) != null) {
            appIntObj = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN);
            isRecordExist = true; 
        }

        appIntObj.Name = IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN;
        appIntObj.External_Id__c = aUserId;
        appIntObj.User_Name__c = aUserName;
        appIntObj.User_Email__c = aUserEmail;
        appIntObj.Integration_Enabled__c = true;
        appIntObj.Connected__c = true;
        appIntObj.Org_Id__c = SimpplrContext.simpplrOrgId;
        appIntObj.Client_Id__c = 'DUMMY'; 
        appIntObj.Client_Secret__c = 'DUMMY';
        appIntObj.Connected_DateTime__c = DateTime.now();
        appIntObj.Refresh_Token_Expiration_Datetime__c = DateTime.now().addDays(90);

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                                                    App_Integration__c.Name,
                                                    App_Integration__c.External_Id__c,
                                                    App_Integration__c.User_Name__c,
                                                    App_Integration__c.User_Email__c,
                                                    App_Integration__c.Integration_Enabled__c,
                                                    App_Integration__c.Connected__c,
                                                    App_Integration__c.Org_Id__c,
                                                    App_Integration__c.Client_Id__c,
                                                    App_Integration__c.Client_Secret__c,
                                                    App_Integration__c.Connected_DateTime__c,
                                                    App_Integration__c.Refresh_Token_Expiration_Datetime__c
                                                };

        if (isRecordExist) { // Update the appIntegration record  
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(appIntObj, fieldList);
        
        } else { // Insert the appIntegration record 
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(appIntObj, fieldList); 

        }
        
        return true; 
    }

    public void createPeopleIntegrationRecord (String aUserId, String aUserName, String aUserEmail) {
        People_Integration__c peopleIntegrationObj = new  People_Integration__c();
        peopleIntegrationObj.Name = IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN;
        peopleIntegrationObj.People__c = UserContext.peopleId;
        peopleIntegrationObj.Connected__c = true;
        peopleIntegrationObj.External_Id__c = aUserId;
        peopleIntegrationObj.User_Email__c = aUserEmail;
        peopleIntegrationObj.User_Name__c = aUserName;
		peopleIntegrationObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).id;
        peopleIntegrationObj.User__c = UserInfo.getUserID();

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                        People_Integration__c.Name, 
                        People_Integration__c.People__c,
                        People_Integration__c.Connected__c,
                        People_Integration__c.External_Id__c,
                        People_Integration__c.User_Email__c,
                        People_Integration__c.User_Name__c,
                        People_Integration__c.App_Integration__c,
                        People_Integration__c.User__c                            
                    };
        if(UserContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN)) {
            peopleIntegrationObj.id = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Id;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(peopleIntegrationObj, fieldList);
        } else {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(peopleIntegrationObj, fieldList);      
        }
    }
}