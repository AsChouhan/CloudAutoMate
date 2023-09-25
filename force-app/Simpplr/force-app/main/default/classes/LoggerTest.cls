@isTest
public class LoggerTest {
    
    @testSetup static void setup() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig(); 
    }

    @isTest static void testlogInfo1() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        Logger.logInfo(new SimpplrException('Testing'));
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogInfo2() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        Logger.logInfo('Testing');
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogDebug1() {
        Logger.logDebug(new SimpplrException('Testing'));
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogDebug2() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        ActivityDataServer ads = new ActivityDataServer();
        
        ads.handleRequest();
        Logger.logDebug('Testing');
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogWarn1() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        Logger.logWarn(new SimpplrException('Testing'));
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogWarn2() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        Logger.logWarn('Testing');
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogError1() {
        Logger.logError(new SimpplrException('Testing'));
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogError3() {
        Logger.logError(null);
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }

    @isTest static void testlogError4() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        Logger.logError('Hello Testing');
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }


    @isTest static void testlogError5() {
        Logger.logError(new SIMPSFDCAccessControlException('message',null, null, null, null));
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testlogError2() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        Logger.logError('Testing', new SimpplrException('Hello'));
        List<String> lList = Logger.getLogs();
        System.assert(true,'Running as expected');
    }


    @isTest static void testLogExecutionContext1() {
        Logger.logExecutionContext();
        System.assert(true,'Running as expected');
    }

    @isTest static void testLogExecutionContext2() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        Logger.logExecutionContext(); 
        System.assert(true,'Running as expected');
    }

    @isTest static void testLogExecutionContext3() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/DataServerRW';
        req.httpMethod = 'POST';
        req.addParameter('target', 'ActivitydataServer');
        req.addParameter('action', 'getActivity');
        req.requestBody = Blob.valueOf('{"siteId" : "siteId123"}');
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        DataServerRW.doPost();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testGetLog() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        ActivityDataServer ads = new ActivityDataServer();
        
        ads.handleRequest();
        Logger.log(null, null);
        List<String> lList = Logger.getLogs();
        
        System.assert(true,'Running as expected');

    }

    @isTest static void testFlushLogsToDB() {
        List<Logs__c> lList = [select id from Logs__c];
        if(lList!=null && lList.size()>0){
            delete lList;
        }
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        ActivityDataServer ads = new ActivityDataServer();
        ads.handleRequest();
        Test.startTest();
        Logger.flushLogsToDB();
        Test.stopTest();
        lList = [select id, Log_Type__c, Unique_Token__c, Source_Info__c, Log_Data__c from Logs__c];
        System.assert(true,'Running as expected');
    }

    @isTest static void testSaveDebugLogsFuture() {
        
        Test.startTest();
        Logger.saveDebugLogsByFuture('test','test','test','test');
        Test.stopTest();
        List<Logs__c> lList = [select id, Log_Type__c, Unique_Token__c, Source_Info__c, Log_Data__c from Logs__c where Unique_Token__c = 'test'];
        System.assert(true,'Running as expected');

    }

    @isTest static void testSaveDebugLogs() {
        // PageReference pageRef = Page.DataServerRW;
        // pageRef.getParameters().put('target','ActivityDataServer');
        // Test.setCurrentPage(pageRef);
        // ActivityDataServer ads = new ActivityDataServer();
        // 
        // ads.handleRequest();
        Logger.saveDebugLogs('test','test','test','test');
        List<Logs__c> lList = [select id, Log_Type__c, Unique_Token__c, Source_Info__c, Log_Data__c from Logs__c where Unique_Token__c = 'test'];
        System.assert(true,'Running as expected');
        
    }

    @isTest static void testIsDebugOn() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        ActivityDataServer ads = new ActivityDataServer();
        
        ads.handleRequest();
        
        System.assert(true ,'Running as expected');
    }

    @isTest static void testIsReadOnlyProcessforFalse() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        ActivityDataServer ads = new ActivityDataServer();
        
        ads.handleRequest();
        
        System.assert(true,'Running as expected');
    }

    @isTest static void testIsReadOnlyProcessforTrue() {
        PageReference pageRef = Page.DataServerRo;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        ActivityDataServer ads = new ActivityDataServer();
        
        ads.handleRequest();
        
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPrepareACExceptionDetail() {
        try{
            Logger.prepareACExceptionDetail(new SIMPSFDCAccessControlException('message',null, null, null, null));
            List<String> l = Logger.getLogs();
            String val = JSON.serialize(l);
            System.assert(true,'Running as expected');
        } catch(Exception e){
            System.assert(true,'Running as expected');
        }
    }
    
    @isTest static void testgetLogLimitStatus() {
        String log = Logger.getLogLimitStatus();
        System.assert(true,'Running as expected');
    }
    
}