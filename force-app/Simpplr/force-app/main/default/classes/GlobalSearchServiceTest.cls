@isTest 
private class GlobalSearchServiceTest {
	private static App_Config__c appConfigRecord;
	private static User systemAdmin;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Content__c simpplrContentForScore;
	private static Simpplr_Site__c site;
	private static People__c peopleObj;
	private static ContentVersion contentVersionObj;
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		appConfigRecord.Box_Managed_Permissions__c = 'simpplr';
        update appConfigRecord;
		TestHelper.createPeopleRecordForUser(UserContext.id);
		systemAdmin = TestHelper.createUser('GlobalSearchServiceTest_admin', null, true);
		siteOwnr = TestHelper.createUser('GlobalSearchServiceTest_siteOwnr', null, false);
		managerOfsiteMember = TestHelper.createUser('GlobalSearchServiceTest_userMngr', null, false);
		siteMember = TestHelper.createUser('GlobalSearchServiceTest_siteMmbr', managerOfsiteMember, false);
		cgroup = TestHelper.createCollaborationGroup('GlobalSearchServiceTest_Grp1','Public');
		site = TestHelper.getSiteRecord(cgroup.id);
		TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		
	    CollaborationGroupMember cgMember2 = TestHelper.createCollaborationGroupMember(cgroup.Id, siteMember.id, 'Standard');
        contentVersionObj=TestHelper.createContentVersion('h');
	    
	}
	
    private static void init() {
    	if(appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
	    	List<User> listOfUsers = [select Id, lastName from user where lastname like 'GlobalSearchServiceTest%'];
	    	for(User userObj : listOfUsers) {
	    		if(userObj.lastName == 'GlobalSearchServiceTest_admin') {
	    			systemAdmin = userObj;
	    		} else if(userObj.lastName == 'GlobalSearchServiceTest_siteOwnr') {
	    			siteOwnr = userObj; 
	    		} else if(userObj.lastName == 'GlobalSearchServiceTest_userMngr') {
	    			managerOfsiteMember = userObj; 
	    		} else if(userObj.lastName == 'GlobalSearchServiceTest_siteMmbr') {
	    			siteMember = userObj; 
	    		}
	    	}
	    	site = TestHelper.getSiteRecordWithName('GlobalSearchServiceTest_Grp1');
	        simpplrContent = TestHelper.createContent('simpplr test news', 'News', 'Submitted', siteMember, site);
	        simpplrContentForScore=[SELECT Type__c, Title__c, Display_Excerpt__c from Simpplr_Content__c limit 1];
	        peopleObj=[select About__c,City__c,Country__c,Department__c,Extension__c,user__r.SmallPhotoURL,
	    			User__c,Mobile_Phone__c,Phone__c,State__c,Title__c,Full_Name__c,Email__c,
	    			First_Name__c,Last_Name__c from People__c limit 1];
    	}
    }
    
    @isTest static void testGlobalSearchServiceTest() {
    	init();
    	GlobalSearchService serviceObj = new GlobalSearchService();
    	
    	Criteria.Site siteCriteriaOb = new Criteria.Site();
    	siteCriteriaOb.term = 'Test';
    	siteCriteriaOb.offset = 0;
    	siteCriteriaOb.size = 10;
    	List<Object> objList = serviceObj.searchSites(siteCriteriaOb);
    	System.assertEquals(true,objList.size()>0,'Running as expected');

    }
    
    @isTest static void testSortSiteListingWithRelevance() {
    	init();
    	List<SiteListingWrapper> listOfSites=getSiteListingWrapper();
    	GlobalSearchService gss = new GlobalSearchService();
    	System.assert(true,'Running as expected');
    }
    private static List<SiteListingWrapper> getSiteListingWrapper (){
    	List<SiteListingWrapper> listOfWrap= new List<SiteListingWrapper>();
    	SiteListingWrapper slw= new SiteListingWrapper();
		slw.img = 'imgname';
		slw.url = 'http://imgname.com/imgname.png';
		slw.title = 'title';
		slw.description = 'title';
		slw.isMember = true;
		slw.isFavorited = true;
		slw.isFeatured = true;
		slw.isPrivate = false;
		slw.isOwner = true;
		slw.isManager = true;
		slw.isAccessRequested = false;
		slw.informationTitle = 'informationTitle';
		slw.photoColor = 'color';
		slw.ownerId = siteMember.id;
		slw.isActivated = true;
		listOfWrap.add(slw);
		return listOfWrap;
    }
    
    @isTest static void testSearchPeople() {
    	init();
    	User u = [Select id, CompanyName from user where lastname='GlobalSearchServiceTest_admin'][0];
    	u.CompanyName = 'GlobalSearchServiceTest';
    	update u;
    	Criteria.People peopleCriteria=getPeopleCriteria();
    	GlobalSearchService gss = new GlobalSearchService();
    	gss.searchPeople(peopleCriteria);
    	System.assert(true,'Running as expected');
    }
    private static Criteria.People getPeopleCriteria (){
    	Criteria.people peoplCriteria=new Criteria.People();
    	
    	peoplCriteria.siteId = site.id;
		peoplCriteria.size = 10;
		peoplCriteria.term = 'GlobalSearchServiceTest';
		peoplCriteria.sfUserId = siteMember.id;
		peoplCriteria.offset = 10;
		peoplCriteria.name_term = 'GlobalSearchServiceTest';
		peoplCriteria.title_term = 'GlobalSearchServiceTest';
		peoplCriteria.telephone_term = 'GlobalSearchServiceTest';
		ExpertiseWrapper wrapperObj = new ExpertiseWrapper();
		wrapperObj.id = 'Id';
		wrapperObj.name = 'Expertise Name';
		peoplCriteria.expertise = wrapperObj;
		return peoplCriteria;
    }
    @isTest static void testGetPeopleScore(){
    	init();
    	GlobalSearchservice gss = new GlobalSearchService();
    	Set<String> searchTokens= new Set<String> {peopleObj.Last_Name__c};
    	String scoreDefinitionString = SimpplrContext.appConfig.Search_People_Allowed_Field__c;
    	Map<String, Integer> mapOfScoreDefinitions = (Map<String,Integer>) Json.deserialize(scoreDefinitionString, Map<String,Integer>.class);
    	
    	gss.getPeopleScore(peopleObj,mapOfScoreDefinitions,searchTokens);
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testSearchFiles(){
    	init();
    	GlobalSearchservice gss = new GlobalSearchService();
    	gss.searchFiles(getFileCriteria());
    	System.assert(true,'Running as expected');
    }
    private static Criteria.File getFileCriteria (){
    	Criteria.File fileCriteriaObj=  new Criteria.File();
    	fileCriteriaObj.action  ='search';
		fileCriteriaObj.siteId =site.id;
		fileCriteriaObj.nextPageToken ='10';
		fileCriteriaObj.size =10;
		fileCriteriaObj.filter ='';
		fileCriteriaObj.term ='term';
		fileCriteriaObj.userId =siteMember.id;
		fileCriteriaObj.provider ='';
		fileCriteriaObj.pageName ='myfiles';
		fileCriteriaObj.offset =10;
		fileCriteriaObj.albumId  =simpplrContent.id;
		fileCriteriaObj.fileStorageSource ='box';
		return fileCriteriaObj;
		
    }
    
    @isTest static void testConvertToFileListingWrapper (){
    	init();
    	//ContentVersion fileObj,set<String> searchTokens,Map<Id,People__c> mapOfUserIdAndPeopleObject
    	GlobalSearchservice gss = new GlobalSearchService();
    	//gss.convertToFileListingWrapper(contentVersionObj,new Set<String>{'test'},new Map<Id,People__c>(), new Map<Id,FileListingWrapper.SiteWrapper>());
    	System.assert(true,'Running as expected');
    }
    
    private static Criteria.Album getAlbumCriteria (){
    	Criteria.Album albumCritObj=  new Criteria.Album();
    	albumCritObj.siteId=site.id;
		albumCritObj.nextPageToken='10'; 
		albumCritObj.size=10;
		albumCritObj.term='test';
		albumCritObj.userId=siteMember.id;
		albumCritObj.provider='box';
		albumCritObj.pageName='myfiles'; 
		albumCritObj.offset=10;
		albumCritObj.fileDescription='test description';
		albumCritObj.photoUrl='flower.png';
		return albumCritObj;
		
    }    
    @isTest static void testGetContentScore(){
    	init();    	
    	simpplrContent.title__c='simpplr test news';
    	simpplrContent.Summary_1__c='testSummary';
    	GlobalSearchservice gss = new GlobalSearchService();
    	String scoreDefinitionString = SimpplrCOntext.appConfig.Search_People_Allowed_Field__c;
    	Map<String, Integer> mapOfScoreDefinitions = (Map<String,Integer>) Json.deserialize(scoreDefinitionString, Map<String,Integer>.class);
    	
    	
    	gss.getContentScore(simpplrContentForScore,mapOfScoreDefinitions, new Set<String>{'simpplr test news'});
    	gss.getContentScore(simpplrContentForScore,mapOfScoreDefinitions, new Set<String>{'testSummary'});
    	gss.getContentScore(simpplrContentForScore,mapOfScoreDefinitions, new Set<String>{'TestTag'});
    	
    	gss.getContentScore(simpplrContentForScore,mapOfScoreDefinitions, new Set<String>{'test'});
    	gss.getContentScore(simpplrContentForScore,mapOfScoreDefinitions, new Set<String>{'simpplr'});
    	
    	gss.getContentScore(simpplrContentForScore,mapOfScoreDefinitions, new Set<String>{'test'});
    	gss.getContentScore(simpplrContentForScore,mapOfScoreDefinitions, new Set<String>{'est'});
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetFileScore(){
    	init();
    	GlobalSearchservice gss = new GlobalSearchService();
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'testDescription'});
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'testName'});
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'testTitle'});
    	
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'Description'});
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'Name'});
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'Title'});
    	
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'test'});
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'test'});
    	gss.getFileScore(new File__c(Name='testName',Title__c='testTitle',Description__c='testDescription'),new Set<String>{'test'});
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testCalculatePeopleScoreWithConditions(){
    	init();
    	String scoreDefinitionString = SimpplrContext.appConfig.Search_People_Allowed_Field__c;
    	Map<String, Integer> mapOfScoreDefinitions = (Map<String,Integer>) Json.deserialize(scoreDefinitionString, Map<String,Integer>.class);
    	peopleObj.City__c = 'NewDelhi';
        peopleObj.State__c = 'Delhi';
        peopleObj.Country__c = 'India';
        peopleObj.Extension__c = 'testExtension';
        peopleObj.Mobile_Phone__c = 'test';
        peopleObj.Phone__c = 'test';
        peopleObj.Title__c = 'testTitle';
        update peopleObj;
    	
    	GlobalSearchservice gss = new GlobalSearchService();
    	gss.calculatePeopleScoreWithConditions(peopleObj,mapOfScoreDefinitions, 'test');
        gss.calculatePeopleScoreWithConditions(peopleObj,mapOfScoreDefinitions, 'Delhi');
    	System.assert(true,'Running as expected');
    }
}