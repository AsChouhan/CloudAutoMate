/**
 * This class contains unit tests for validating the behavior of Apex class GDAPIModelDirectory
 */
@isTest
private class GDAPIModelDirectoryTest {

    @isTest static void domainAliasesTest() {
        GDAPIModelDirectory.DomainAliases daObj = new GDAPIModelDirectory.DomainAliases();
        String daObjString = '{"etag":"etag","domainAliasName":"domainAliasName",'+
        				'"parentDomainName":"parentDomainName","verified":true,'+
        				'"creationTime":"1498824114"}';
        daObj = (GDAPIModelDirectory.DomainAliases)JSON.deserialize(daObjString,GDAPIModelDirectory.DomainAliases.class);
        System.assertEquals(daObj.etag, 'etag' );
        System.assertEquals(daObj.domainAliasName, 'domainAliasName' );
        System.assertEquals(daObj.parentDomainName, 'parentDomainName' );
        System.assertEquals(daObj.verified, true );
        System.assertEquals(daObj.creationTime, Long.valueOf('1498824114') );
    }
    
    @isTest static void domainsTest() {
        GDAPIModelDirectory.Domains daObj = new GDAPIModelDirectory.Domains();
        String daObjString = '{"etag":"etag","domainName":"domainName",'+
        				'"isPrimary":true,"verified":true,'+
        				'"creationTime":"1498824114",'+
        				'"domainAliases":[{"etag":"etag","domainAliasName":"domainAliasName",'+
		        				'"parentDomainName":"parentDomainName","verified":true,'+
		        				'"creationTime":"1498824114"}]}';
        daObj = (GDAPIModelDirectory.Domains)JSON.deserialize(daObjString,GDAPIModelDirectory.Domains.class);
        System.assertEquals(daObj.etag, 'etag' );
        System.assertEquals(daObj.domainName, 'domainName' );
        System.assertEquals(daObj.isPrimary, true );
        System.assertEquals(daObj.verified, true );
        System.assertEquals(daObj.creationTime, Long.valueOf('1498824114') );
        System.assertEquals(daObj.domainAliases.size(),1);
    }
    
    @isTest static void aliasTest() {
        GDAPIModelDirectory.Alias daObj = new GDAPIModelDirectory.Alias();
        String daObjString = '{"id":"jqwlkj45ljk2","etag":"etag",'+
        				'"primaryEmail":"primaryEmail@email.com","alias":"alias"}';
        daObj = (GDAPIModelDirectory.Alias)JSON.deserialize(daObjString,GDAPIModelDirectory.Alias.class);
        System.assertEquals(daObj.etag, 'etag' );
        System.assertEquals(daObj.id, 'jqwlkj45ljk2' );
        System.assertEquals(daObj.primaryEmail, 'primaryEmail@email.com' );
        System.assertEquals(daObj.alias, 'alias' );
    }
    
    @isTest static void groupsTest() {
        GDAPIModelDirectory.Groups grpObj = new GDAPIModelDirectory.Groups();
        String grpObjString = '{"id":"jqwlkj45ljk2","etag":"etag",'+
        				'"description":"description",'+
        				'"email":"primaryEmail@email.com","name":"name","directMembersCount":"2352534",'+
        				'"nonEditableAliases":["nonEditableAlias1","nonEditableAlias2"],'+
        				'"adminCreated":true,"aliases":["alias1","alias2"]}';
        grpObj = (GDAPIModelDirectory.Groups)JSON.deserialize(grpObjString,GDAPIModelDirectory.Groups.class);
        System.assertEquals(grpObj.getId(), 'jqwlkj45ljk2' );
        System.assertEquals(grpObj.getEtag(), 'etag' );
        System.assertEquals(grpObj.getEmail(), 'primaryEmail@email.com' );
        grpObj.setEmail('email@email.com');
        System.assertEquals(grpObj.getEmail(), 'email@email.com' );
        System.assertEquals(grpObj.getName(), 'name' );
        grpObj.setName('name Changed');
        System.assertEquals(grpObj.getName(), 'name Changed' );
        System.assertEquals(grpObj.getDirectMembersCount(), Long.valueOf('2352534') );
        System.assertEquals(grpObj.getDescription(), 'description' );
        grpObj.setDescription('description Changed');
        System.assertEquals(grpObj.getDescription(), 'description Changed' );
        System.assertEquals(grpObj.getAdminCreated(), true );
        System.assertEquals(grpObj.getAliases(), new List<String>{'alias1','alias2'} );
        System.assertEquals(grpObj.getNonEditableAliases(), new List<String>{'nonEditableAlias1','nonEditableAlias2'} );
        GDAPIModelDirectory.GroupsList grpListObj = new  GDAPIModelDirectory.GroupsList();
        String grpListObjString = '{"etag":"etag","nextPageToken":"2",'+
        							'"groups":['+ JSON.serialize(grpObj) +']'+
        							'}';
		grpListObj = (GDAPIModelDirectory.GroupsList)
        					JSON.deserialize(grpListObjString,GDAPIModelDirectory.GroupsList.class);	
        System.assertEquals(grpListObj.etag,'etag');		
        System.assertEquals(grpListObj.nextPageToken,'2');		
        System.assertEquals(grpListObj.groups.size(),1);
    }
    
    @isTest static void membersTest() {
        GDAPIModelDirectory.Members membrObj = new GDAPIModelDirectory.Members();
        String membrObjString = '{"id":"jqwlkj45ljk2","etag":"etag",'+
        				'"email":"primaryEmail@email.com","role":"role","type":"type"}';
        				
        membrObj = (GDAPIModelDirectory.Members)JSON.deserialize(membrObjString,GDAPIModelDirectory.Members.class);
        System.assertEquals(membrObj.getId(), 'jqwlkj45ljk2' );
        System.assertEquals(membrObj.getEtag(), 'etag' );
        System.assertEquals(membrObj.getEmail(), 'primaryEmail@email.com' );
        membrObj.setEmail('email@email.com');
        System.assertEquals(membrObj.getEmail(), 'email@email.com' );
        System.assertEquals(membrObj.getRole(), 'role' );
        membrObj.setRole('role Changed');
        System.assertEquals(membrObj.getRole(), 'role Changed' );
        System.assertEquals(membrObj.getType(), 'type' );
        GDAPIModelDirectory.MembersList memberListObj = new  GDAPIModelDirectory.MembersList();
        String memListObjString = '{"etag":"etag","nextPageToken":"2",'+
        							'"members":['+ JSON.serialize(membrObj) +']'+
        							'}';
        memberListObj = (GDAPIModelDirectory.MembersList)
        					JSON.deserialize(memListObjString,GDAPIModelDirectory.MembersList.class);	
        System.assertEquals(memberListObj.etag,'etag');		
        System.assertEquals(memberListObj.nextPageToken,'2');		
        System.assertEquals(memberListObj.members.size(),1);								
    }
}