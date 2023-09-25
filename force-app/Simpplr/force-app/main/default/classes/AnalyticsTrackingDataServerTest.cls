@isTest
private class AnalyticsTrackingDataServerTest {
	@testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        People__c peopleRecord = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        People_Preference__c peoplePreferenceRec = Testhelper.createPeoplePreference(peopleRecord.Id);
        User grpMngr = TestHelper.createUser('Simpplr_grpMngr', null, false);
        
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('AccessManagerTest_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, grpMngr.id,'Admin');
        
        List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'dropbox'});
        List<People_Integration__c> peopleIntegList = TestHelper.createPeopleIntegrationRecords(appIntegList, UserContext.peopleId, 'asdsada');
        peopleIntegList[0].Batch_Flag__c = true;
        update peopleIntegList;
    }
    
    private static Simpplr_Site__c getSimpplrSite(){
    	 return([select id from Simpplr_Site__c limit 1]);
    }
    
    @isTest static void testHandleRequest() { 
  	  	Simpplr_Site__c rec = getSimpplrSite();
        TestHelper.shareSitesToAllPeople(new List<String>{rec.Id});
  	  	User testUser = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
  	  	Simpplr_Content__c content = TestHelper.createContent('Developer','Event', 'open', testUser, rec);
  	  	Mailer__c newLetter = TestHelper.getMailerRecord('test', UserContext.peopleId, rec.Id,content.Id);
  	  	Topic testTopic = TestHelper.createTopic('TestTopic');
  	  	
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','analyticsTrackingDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsTrackingDataServer analyticsDSObject= new AnalyticsTrackingDataServer();
        analyticsDSObject.getPageFeature();
        
        pageRef.getParameters().put('data','{"userAgent":"Desktop App","pageURL":"/apex/homealbums","pageName":"homealbums","origin":"pade", "topicId": "'+testTopic.id+'"}');
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"userAgent":"Desktop App","pageURL":"/apex/HomeMyDashboard","pageName":"HomeMyDashboard","pageGroup":"home_dashboard","pageCategory":"home_dashboard"}');
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"userAgent":"Mobile App","origin": "nle", "contentId":"'+String.valueOf(content.Id).substring(0,15)+'", "newsletterId": "'+String.valueOf(newLetter.Id).substring(0,15)+'"}');
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"userAgent":"BlackBerry", "origin":"ab"}');
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"userAgent":"abc", "origin":"gs"}');
        analyticsDSObject.handleRequest();

        pageRef.getParameters().put('data','{"context":"gdrive","externalUrl":"https://drive.google.com/file/d/1Jrtla1YoEVMWuxgbEMXOKqz52Qj7NOo6/view?usp=drivesdk","fileExtension":"CSV","fileUrl":"/apex/FileDetail?fileId=1Jrtla1YoEVMWuxgbEMXOKqz52Qj7NOo6&directory=1Zco0Du-CMMsn-zixFDEXB0fjMWtDch-o&provider=gdrive&siteId=undefined","id":"1Jrtla1YoEVMWuxgbEMXOKqz52Qj7NOo6","isBookmarked":false,"isNew":true,"name":"bulkQuery_result.csv","ownerId":"a0t3h000000tcsdAAA","provider":"gdrive","siteId":"","size":"28458","source":"intranet","title":"bulkQuery_result.csv","type":"CSV","action":"upload"}');
        pageRef.getParameters().put('action','createAnalyticsFileUploadRecord');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();

        
        pageRef.getParameters().put('data','###');
        analyticsDSObject.handleRequest();
  	  	System.assert(true,'Running as expected');  
    }
}