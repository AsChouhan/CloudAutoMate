@isTest
private class AudienceDataServerTest {
	
	@testSetup static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
		appConfigRecord.Segment_Enabled__c = true;
		appConfigRecord.Segment_Column_Name__c = 'Country__c';
		update appConfigRecord;
        People__c peopleRec = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id);
        Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
        Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleRec.Id, 'Site');
	
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        User userRec2 = TestHelper.createUser('test1', userRec, false);
        User userRec3 = TestHelper.createUser('test2', userRec, false);
        User userRec4 = TestHelper.createUser('test3', userRec, false);
        User userRec5 = TestHelper.createUser('test4', userRec, false);
        User userRec6 = TestHelper.createUser('test5', userRec, false);

        People__c peopleRec2 = [Select id From people__c where user__c =: userRec2.id];
        People__c peopleRec3 = [Select id From people__c where user__c =: userRec3.id];
        People__c peopleRec4 = [Select id From people__c where user__c =: userRec4.id];
        People__c peopleRec5 = [Select id From people__c where user__c =: userRec5.id];
        People__c peopleRec6 = [Select id From people__c where user__c =: userRec6.id];
        
        TestHelper.createAudienceMember(audienceRec.id,peopleRec.id);
        TestHelper.createAudienceMember(audienceRec.id,peopleRec2.id);
        TestHelper.createAudienceMember(audienceRec.id,peopleRec3.id);
        TestHelper.createAudienceMember(audienceRec.id,peopleRec4.id);
        TestHelper.createAudienceMember(audienceRec.id,peopleRec5.id);
        TestHelper.createAudienceMember(audienceRec.id,peopleRec6.id);

        createCustomProfileFields(appConfigRecord);
        
    }

    private static void createCustomProfileFields(App_Config__c apConfigObj) {
        List<CustomProfileField> customFieldsList = new List<CustomProfileField>();
        for(Integer i = 1; i <= 25; i++) {
            CustomProfileField customProfileField = new CustomProfileField();
            customProfileField.usedForAudience = null;
            customProfileField.syncSource = 'salesforce';
            customProfileField.singular = 'Custom_Field_' + i + '__c';
            customProfileField.plural = 'Custom_Field_' + i + '__c';
            customProfileField.onOff = true;
            customProfileField.listOfOptions = null;
            customProfileField.itemOrder = i;
            customProfileField.isHtml = null;
            customProfileField.isEditable = false;
            customProfileField.fieldType = null;
            customProfileField.fieldName = 'Custom_Field_' + i + '__c';
            customProfileField.displayPeopleFilter = true;
            customProfileField.columnName = 'Custom_Field_' + i + '__c';
            customProfileField.category = null;
            customFieldsList.add(customProfileField);
        }
        apConfigObj.PP_User_Custom_Fields__c = JSON.serialize(customFieldsList);
        update apConfigObj;
    }

   @isTest static void testHandleRequest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        PageReference pageRef = Page.DataServerRW;
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
  
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','getFieldValues');
        pageRef.getParameters().put('data','{"segmentId":'+null+',"field":"category"}');
        Test.setCurrentPage(pageRef);
      	audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{"segment": {"Id":"' + audienceRec.id + '","audience": {"name":"test-aud-01","audienceCount":0,"listOfConditions":[{"name":"country","label":"Country","values":[{"id":null,"name":"India"}]},{"name":"hire date after","label":"hire date after","values":[{"id":null,"name":"2015-01-01T00:00:00.000+0530"}]}]}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"Id":"' + audienceRec.Id + '"}'); 
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','delete');
        pageRef.getParameters().put('data','{"audienceId":"' + audienceRec.Id + '"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"segmentId":"'+segmentRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"segmentId":"'+segmentRec.Id+'","term":"test"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"country","label":"Department","values":[{"name":"US"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":null}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"country","label":"Department","values":[{"name":"US"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{"type":"people","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"department","label":"Department","values":[]}],"listOfPeople":[{"id":"'+peopleRec.Id+'","peopleId":"'+peopleRec.Id+'","sfUserId":"'+UserInfo.getUserId()+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh","name":"Priya Singh","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true}],"name":"TestAudi","audienceId":null}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{"type":"people","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"department","label":"Department","values":[]}],"listOfPeople":[{"id":"'+peopleRec.Id+'","peopleId":"'+peopleRec.Id+'","sfUserId":"'+UserInfo.getUserId()+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh","name":"Priya Singh","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true}],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        audienceRec.Audience_Rule_Json__c = '[{"category":["Uncategorized"]}]';
        audienceRec.Name__c = 'new Audience Record';
        audienceRec.Is_Deleted__c = false;
        update audienceRec;
        AudienceService serviceObj = new AudienceService();
        serviceObj.getAudienceByIdAndRuleJSON(audienceRec, new Map<String, Active_Directory_Group__c>());
        Test.stopTest();
        System.assert(true,'Running as expected');
        
    }  

    @isTest static void testHandleRequestCallSF() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        PageReference pageRef = Page.DataServerRO;
        
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        User userRec2 = TestHelper.createUser('Test_Simpplr_usr2', userRec, false);
        User userRec3 = TestHelper.createUser('Test_Simpplr_usr3', userRec, false);
        User userRec4 = TestHelper.createUser('Test_Simpplr_usr4', userRec, false);
        User userRec5 = TestHelper.createUser('Test_Simpplr_usr5', userRec, false);
        User userRec6 = TestHelper.createUser('Test_Simpplr_usr6', userRec, false);

        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        People__c peopleRec2 = [Select id From people__c where user__c =: userRec2.id];
        People__c peopleRec3 = [Select id From people__c where user__c =: userRec3.id];
        People__c peopleRec4 = [Select id From people__c where user__c =: userRec4.id];
        People__c peopleRec5 = [Select id From people__c where user__c =: userRec5.id];
        People__c peopleRec6 = [Select id From people__c where user__c =: userRec6.id];
        
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','getFieldValues');
        pageRef.getParameters().put('data','{"segmentId":'+null+',"field":"category"}');
        Test.setCurrentPage(pageRef);
      	audienceDataServerObj.handleRequest();
        audienceDataServerObj.getAudienceFieldValuesFromSF(segmentRec.id,'category');

        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{"type":"people","segmentId":"'+segmentRec.Id+'","listOfConditions":,"audienceId":"' + audienceRec.Id + '","listOfPeople":[{"id":"'+peopleRec.Id+'","peopleId":"'+peopleRec.Id+'","sfUserId":"'+UserInfo.getUserId()+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh","name":"Priya Singh","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true},{"id":"'+peopleRec2.Id+'","peopleId":"'+peopleRec2.Id+'","sfUserId":"'+peopleRec2.Id+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh2","name":"Priya Singh2","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh2@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true},{"id":"'+peopleRec3.Id+'","peopleId":"'+peopleRec3.Id+'","sfUserId":"'+peopleRec3.Id+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh3","name":"Priya Singh3","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh3@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true},{"id":"'+peopleRec4.Id+'","peopleId":"'+peopleRec4.Id+'","sfUserId":"'+peopleRec4.Id+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh4","name":"Priya Singh4","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh4@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true},{"id":"'+peopleRec5.Id+'","peopleId":"'+peopleRec5.Id+'","sfUserId":"'+peopleRec5.Id+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh5","name":"Priya Singh5","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh5@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true},{"id":"'+peopleRec6.Id+'","peopleId":"'+peopleRec6.Id+'","sfUserId":"'+peopleRec6.Id+'","segmentId":null,"segmentName":"S1","nickname":"priya.singh6","name":"Priya Singh6","department":"Dep-1","location":"India","division":"Div-1","country":"India","email":"priya.singh6@simpplr.com","videoCallProvider":"zoom","isFollowing":false,"isFavorited":false,"isActive":true}],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
   @isTest static void testHandleRequest2() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRO;
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        audienceRec.Audience_Rule_Json__c = '[{"department":["Dep-1"]}]';
        audienceRec.Name__c = 'new Audience Record';
        audienceRec.Is_Deleted__c = false;
        update audienceRec;
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{"audienceId":"'+audienceRec.Id+'"}');
        Test.setCurrentPage(pageRef);
        audienceDataServerObj.handleRequest();

        audienceRec.Audience_Rule_Json__c = '[{"city":["delhi"]},{"country":["US"]},{"hireDateBefore":["2021-11-01"]}]';
        update audienceRec;
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{"audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testHandleRequestPeopleAudience() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRO;
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        audienceRec.Audience_Rule_Json__c = '[{"peopleId":[]}]';
        audienceRec.Name__c = 'new Audience Record';
        audienceRec.Is_Deleted__c = false;
        audienceRec.Is_Created_By_Csv__c = true;
        update audienceRec;
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        Test.setCurrentPage(pageRef);

        Criteria.AudienceDeleteParams criteriaAudienceObj = new Criteria.AudienceDeleteParams();
        criteriaAudienceObj.fromEditModal = true;
        criteriaAudienceObj.audienceId = audienceRec.Id;
        ApexPages.currentPage().getParameters().put('data', Utility.getJsonFormat(criteriaAudienceObj));
        pageRef.getParameters().put('action','get');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('action','delete');
        pageRef.getParameters().put('data','{"audienceId":"' + audienceRec.Id + '"}');
        audienceDataServerObj.handleRequest();
        
        Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testHandleRequestSave() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        
        PageReference pageRef = Page.DataServerRO;
        
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"city","label":"City","values":[{"name":"Delhi"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"company","label":"Company","values":[{"name":"Simpplr"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"department","label":"Department","values":[{"name":"Dep-1"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        System.assertEquals(audienceDataServerObj.response.status, 'success', 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSave3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        
        PageReference pageRef = Page.DataServerRO;
        
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef);

        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"division","label":"Division","values":[{"name":"Div-1"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Hire Date","label":"Hire Date","values":[{"name":"2020-03-18 00:00:00"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"category","label":"Category","values":[{"name":"uncategorized"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"state","label":"State","values":[{"name":"Delhi"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSave2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        
        PageReference pageRef = Page.DataServerRO;
        
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"title","label":"Title","values":[{"name":"TestTitle"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_1__c","label":"Custom_Field_1__c","values":[{"name":"Custom_Field_1__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_2__c","label":"Custom_Field_2__c","values":[{"name":"Custom_Field_2__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_3__c","label":"Custom_Field_3__c","values":[{"name":"Custom_Field_3__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_4__c","label":"Custom_Field_4__c","values":[{"name":"Custom_Field_4__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_5__c","label":"Custom_Field_5__c","values":[{"name":"Custom_Field_5__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        Test.stopTest();
        System.assertEquals(audienceDataServerObj.response.status, 'success', 'Running as Expected');
        
    }

    @isTest static void testHandleRequestSave4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        
        PageReference pageRef = Page.DataServerRO;
        
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef);  
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_6__c","label":"Custom_Field_6__c","values":[{"name":"Custom_Field_6__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_7__c","label":"Custom_Field_7__c","values":[{"name":"Custom_Field_7__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();        
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_8__c","label":"Custom_Field_8__c","values":[{"name":"Custom_Field_8__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_9__c","label":"Custom_Field_9__c","values":[{"name":"Custom_Field_9__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_10__c","label":"Custom_Field_10__c","values":[{"name":"Custom_Field_10__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();      

        System.assertEquals(audienceDataServerObj.response.status, 'success', 'Running as Expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestSave5() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        
        PageReference pageRef = Page.DataServerRO;
        
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef); 

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_11__c","label":"Custom_Field_11__c","values":[{"name":"Custom_Field_11__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_12__c","label":"Custom_Field_12__c","values":[{"name":"Custom_Field_12__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_13__c","label":"Custom_Field_13__c","values":[{"name":"Custom_Field_13__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_14__c","label":"Custom_Field_14__c","values":[{"name":"Custom_Field_14__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();          

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_15__c","label":"Custom_Field_15__c","values":[{"name":"Custom_Field_5__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest(); 
        
        System.assertEquals(audienceDataServerObj.response.status, 'success', 'Running as Expected');
        Test.stopTest();
    }

    @isTest static void testHandleRequestSave6() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        
        PageReference pageRef = Page.DataServerRO;
        
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef);  

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_16__c","label":"Custom_Field_16__c","values":[{"name":"Custom_Field_16__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_17__c","label":"Custom_Field_17__c","values":[{"name":"Custom_Field_17__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_18__c","label":"Custom_Field_18__c","values":[{"name":"Custom_Field_18__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_19__c","label":"Custom_Field_19__c","values":[{"name":"Custom_Field_19__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();

        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_20__c","label":"Custom_Field_20__c","values":[{"name":"Custom_Field_20__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest(); 
        
        System.assertEquals(audienceDataServerObj.response.status, 'success', 'Running as Expected');
        Test.stopTest();
    }  
    
    @isTest static void testHandleRequestSave7() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'getAudienceFieldValues',true));
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        
        PageReference pageRef = Page.DataServerRO;
        
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        Test.setCurrentPage(pageRef);   
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_21__c","label":"Custom_Field_21__c","values":[{"name":"Custom_Field_21__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();         
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_22__c","label":"Custom_Field_22__c","values":[{"name":"Custom_Field_22__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_23__c","label":"Custom_Field_23__c","values":[{"name":"Custom_Field_23__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_24__c","label":"Custom_Field_24__c","values":[{"name":"Custom_Field_24__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        pageRef.getParameters().put('data','{"type":"conditions","segmentId":"'+segmentRec.Id+'","listOfConditions":[{"name":"Custom_Field_25__c","label":"Custom_Field_25__c","values":[{"name":"Custom_Field_25__c"}]}],"listOfPeople":[],"name":"TestAudi","audienceId":"'+audienceRec.Id+'"}');
        audienceDataServerObj.handleRequest();
        
        System.assertEquals(audienceDataServerObj.response.status, 'success', 'Running as Expected');
        Test.stopTest();
    }          


   @isTest static void testHandleRequestGetByIds() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRO;
        User userRec = TestHelper.getUserById(String.valueOf(userInfo.getUserId()));
        People__c peopleRec = [Select id From people__c where user__c =: userRec.id];
        Segment__c segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        Audience__c audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
        audienceRec.Audience_Rule_Json__c = '[{"department":["Dep-1"]}]';
        audienceRec.Name__c = 'new Audience Record';
        audienceRec.Is_Deleted__c = false;
        update audienceRec;
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','getByIds');
        pageRef.getParameters().put('data', '["'+audienceRec.Id+'"]');        
        Test.setCurrentPage(pageRef);
        audienceDataServerObj.handleRequest();
        
        Test.stopTest();
        System.assertEquals('success',audienceDataServerObj.response.status ,'Running as expected');
    }        


    @isTest
    static void testsaveAudienceADGroups() {

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AudienceDataServer');
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data', '{"name":"TestADGroup","isDeleted":false,"segment":null,"audienceCount":0,"usage":{},"type":"people","listOfConditions":[],"listOfPeople":[],"listOfActiveDirectoryGroups":[{"id":"0b66ec38-359b-4ffb-be82-8e1fb3a2ce23"},{"id":"4ddd47bf-2992-4488-b6ce-734e1495f9ae"}]}'); 
        Test.setCurrentPage(pageRef);
        AudienceDataServer audienceDataServerObj = new AudienceDataServer();
        Test.startTest();
        audienceDataServerObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success', audienceDataServerObj.response.status , 'Response should be success');         
    }
}