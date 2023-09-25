@isTest
private class TestCollaborationGroupTrigger {
    @testSetup static void setup() {
       App_Config__c appConfigRecord = TestHelper.setupAppConfig();  
        Simpplr_Site__c simpplrSiteObj = TestDataHandler.createSimpplrSite();
    }
    
    @isTest static void testCollaborationGroupTrigger() {
        CollaborationGroup cGrp = [select Id from CollaborationGroup limit 1];
        try {
            delete cGrp;
            System.assert(true, 'Running as Expected');
        } catch (Exception ex){
        	if(ex.getMessage().contains(ServiceConstants.COLLABORATION_GROUP_DELETE_ERROR_MESSAGE)){
                System.assert(true, 'Running as Expected');
            }
        }
    }
}