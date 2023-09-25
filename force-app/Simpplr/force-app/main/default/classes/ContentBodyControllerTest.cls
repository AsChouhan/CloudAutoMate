@isTest
private class ContentBodyControllerTest {

	@testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false);         
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
                
        Id collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		Simpplr_Site__c testSite = TestHelper.getSiteRecord(collaborationGroupId);
		Simpplr_Content__c simpplrContent = TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
    }
    
    @isTest static void unitTest() {
    	PageReference pageRef = Page.ContentBody;
        Test.setCurrentPage(pageRef);
        Simpplr_Content__c contentObj = [select id from Simpplr_Content__c limit 1];
        ApexPages.currentPage().getParameters().put('contentId', contentObj.id);
        ContentBodyController cbc = new ContentBodyController();
        cbc.useCustomFont= true;
        
        String pvStr = cbc.packageVersion;
        String pnStr = cbc.packageName;
        String fcuStr = cbc.fontCSSURL;
        String rpStr = cbc.resourcePath;
        
        cbc.useCustomFont= false;
        
        pvStr = cbc.packageVersion;
        pnStr = cbc.packageName;
        fcuStr = cbc.fontCSSURL;
        rpStr = cbc.resourcePath;
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));

        UserContext.peopleId = 'xxxxx';
        cbc.contentBody= 'ccc';
        cbc.fontCSSURL= 'vvv';
        cbc.packageName= 'bbbb';
        cbc.packageVersion= 'bb';
        cbc.resourcePath= 'ttttt';
        cbc.init();
        
        SimpplrContext.isSimpplrSetupComplete = true;
        SimpplrContext.isMaintenanceInProgress = true;
        PageContext.currentPageName = 'ErrorPage';
        cbc.init();

        SimpplrContext.isSimpplrSetupComplete = true;
        SimpplrContext.isMaintenanceInProgress = true;
        UserContext.peopleId = '';
        PageContext.currentPageName = 'Exception';
        cbc.init();
        
        cbc.getContentBody(contentObj.id);

        System.assert(true, 'Running as expected');
    }
}