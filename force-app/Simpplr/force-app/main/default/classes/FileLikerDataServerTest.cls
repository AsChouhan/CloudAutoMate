/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class FileLikerDataServerTest {
    private static App_Config__c appConfigRecord;
    private static User standardUserObj ;
    private static People__c  peopleObj;
    private static CollaborationGroup cgroup;
    private static Simpplr_Site__c  siteObj;
    private static Simpplr_Content__c  contentObj;
    
    @testSetup static void setup() {
    	
        appConfigRecord = TestHelper.setupAppConfig();
        standardUserObj = TestHelper.createUser('FileLikerDataServer_User', null ,false);
        cgroup = TestHelper.createCollaborationGroup('FileLikerDataServer_Grp', 'Public');
        siteObj = TestHelper.getSiteRecord(cgroup.id);
        TestHelper.shareSitesToAllPeople(new List<String>{siteObj.Id});
        contentObj = TestHelper.createContent('SimpplrPage', 'page', 'Published', standardUserObj, siteObj);
    }

    static void init() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileLikerDataServer');
        Test.setCurrentPage(pageRef);
    }

    @isTest static void handleRequest() {
        init();
        standardUserObj = [Select id From User Where lastName =: 'FileLikerDataServer_User'];
        peopleObj = [Select id From people__c Where user__c =: standardUserObj.id];
        contentObj = [Select id From Simpplr_Content__c Where title__c =: 'SimpplrPage'];
        File__c fileObj = TestHelper.createContentTitleImage(contentObj.id);
        Like__c likeObj = TestHelper.createContentLike(contentObj.id, peopleObj.id);
        likeObj.External_File_Id__c = fileObj.id;
        update likeObj;
        Bookmark__c bookmarkObj =  TestHelper.createContentBookmark(contentObj.id, peopleObj.id);
        bookmarkObj.Type__c='People';  
        bookmarkObj.Is_Deleted__c = false;
        update bookmarkObj;
        FileLikerDataServer fLikerDSObj = new FileLikerDataServer();
        ApexPages.currentPage().getParameters().put('target','FileLikerDataServer');
        ApexPages.currentPage().getParameters().put('data','{"id":"'+fileObj.id+'", "size":"1", "nextPageToken":"null"}');
        String pageFeatures = fLikerDSObj.getPageFeature();
        fLikerDSObj.handleRequest(); 
        System.assertEquals('success', fLikerDSObj.response.status, 'Running as expected');
    }
   
}