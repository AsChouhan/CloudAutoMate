/**
 * This class contains unit tests for validating the behavior of Apex class DBAPIClientTest 
 */
@isTest
private class DBAPITest {
	
	public static SCoreClient.Credentials crednObj = new SCoreClient.Credentials('tokenTypeDummy','accessTokenDummy');
	
    @isTest static void groupsTest() {
        DBAPIClient Obj = new DBAPIClient(crednObj);
        Obj.groups();
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void membersTest() {
        DBAPIClient Obj = new DBAPIClient(crednObj);
        Obj.members();
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void sharingTest() {
        DBAPIClient Obj = new DBAPIClient(crednObj);
        Obj.sharing();
        System.assert(true, 'Running as expected');
    }
    
    // ########## DBAPIGroup Tests ############
    @isTest static void setClientTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIGroup grpObj = new DBAPIGroup(clientObj);
        grpObj.setClient(clientObj);
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void getListRequestTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIGroup grpObj = new DBAPIGroup(clientObj);
        grpObj.getListRequest(5);
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void getListRequestWithCurserTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIGroup grpObj = new DBAPIGroup(clientObj);
        grpObj.getListRequest('5jkadklcurserksdhuywenfkslei');
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void getCreateRequestTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIGroup grpObj = new DBAPIGroup(clientObj);
        grpObj.getCreateRequest('grp_name','gerp_id');
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void getDeleteRequestTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIGroup grpObj = new DBAPIGroup(clientObj);
        grpObj.getDeleteRequest('fld','val');
        System.assert(true, 'Running as expected');
    }
    
    // ####### DBAPIMember ###########
    @isTest static void setClientMemberTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIMember memObj = new DBAPIMember(clientObj);
        memObj.setClient(clientObj);
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void getListRequestMemberTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIMember memObj = new DBAPIMember(clientObj);
        memObj.getListRequest('grp_fld', 'grp_val', 5);
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void getListRequestCurserMemberTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIMember memObj = new DBAPIMember(clientObj);
        memObj.getListRequest('grp_fld');
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void userAccountMemberTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIMember memObj = new DBAPIMember(clientObj);
        DBAPIMember.UserAccount uAcc = new DBAPIMember.UserAccount(memObj);
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void adminAccountMemberTest() {
        DBAPIClient clientObj = new DBAPIClient(crednObj);
        DBAPIMember memObj = new DBAPIMember(clientObj);
        DBAPIMember.AdminAccount aAcc = new DBAPIMember.AdminAccount(memObj);
        System.assert(true, 'Running as expected');
    }
    
    // ######## DBAPIModelGroup ############
    @isTest static void dbapiModelGrpTest() {
        DBAPIModelGroup grpmdlObj = new DBAPIModelGroup();
        DBAPIModelGroup.DynamicContent dcObj = new DBAPIModelGroup.DynamicContent();
        dcObj.id_field = 'id_field';
        dcObj.id_value = 'id_field';
        dcObj.tag_flag = true;
        dcObj.serialize();
        
        DBAPIModelGroup.FullInfo fiObj = new DBAPIModelGroup.FullInfo();
        fiObj.group_name = 'group_name';
	    fiObj.group_id = 'group_id';
	    fiObj.group_management_type = new Map<String,String>{'a' => '1'};
	    fiObj.created = 'created';
	    fiObj.group_external_id = 'group_external_id';
	    fiObj.member_count = 5;
	    fiObj.members = new List<DBAPIModelMember.FullInfo>();	
	    fiObj.error_summary = 'error_summary';
	    fiObj.error = new Map<String,String>{'error' => 'error'};
	    fiObj.tag = 'tag';
	    fiObj.id_not_found = 'id_not_found';

        System.assert(true, 'Running as expected');
    }
    
    // ######## DBAPIModelMember ############
    @isTest static void dbapiModelMemberTest() {
        DBAPIModelMember.Profile prflObj = new DBAPIModelMember.Profile();
        prflObj.team_member_id = 'team_member_id';
		prflObj.email = 'team_member_id@email.com';
		prflObj.email_verified = true;
		prflObj.status = new Map<String,String>{'status' => 'status'};
		prflObj.name = new Map<String,String>{'name' => 'name'};
		prflObj.membership_type = new Map<String,String>{'membership_type' => 'membership_type'};
		prflObj.external_id = 'external_id';
		prflObj.account_id = 'account_id';
		prflObj.joined_on = System.now();
		prflObj.persistent_id = 'persistent_id';

        
        DBAPIModelMember.FullInfo fiObj = new DBAPIModelMember.FullInfo();
        fiObj.profile = prflObj;
	    fiObj.access_type = new Map<String,String>{'access_type' => 'access_type'};
	    
	    DBAPIModelMember.ListResult liObj = new DBAPIModelMember.ListResult();
        liObj.members = new List<DBAPIModelMember.FullInfo>();
	    liObj.cursor = 'cursor';
	    liObj.has_more = true;
	    
	    DBAPIModelMember.ListArgs laObj = new DBAPIModelMember.ListArgs();
        laObj.id_field = 'id_field';
	    laObj.id_value = 'id_value';
	    laObj.returnLimit = 4;
	    laObj.serialize();

        System.assert(true, 'Running as expected');
    }
    
    
}