public  with sharing class MobilePeopleDao {
	
	@TestVisible private String loggedInPeopleId = UserContext.peopleId;
	private String cacheBaseQuery = 'select id, User__r.UserType, User__r.Show_Simpplr__c, Is_Deleted__c, user__c, Title__c, About__c, Department__c, Full_Name__c, City__c, State__c, Country__c, Street__c, ' +
			' First_Name__c, Last_Name__c, Mobile_Phone__c, Extension__c, Phone__c, Email__c,Joining_Date__c, user__r.FullPhotoURL,  User__r.MediumPhotoUrl, User__r.SmallPhotoUrl, User__r.isActive, ' +
			' Zoom_Id__c, Skype_Id__c, Cover_Content_Document_Id__c, Segment__c, ' +
	        ' (SELECT People__c, Bookmark_Receiver__c FROM Bookmark_Receiver_People__r WHERE People__c=:loggedInPeopleId AND Type__c=\'People\' And Is_Deleted__c=false ) '+
	        ' FROM People__c ';
	public List<People__c> getAllPeopleForCaching(Integer size, Integer offset){
		Set<Id> peopleIdSet = getOffsetPeopleIdSet(size, offset);
	    String queryStr = cacheBaseQuery+' Where Id IN: peopleIdSet';
	    List<People__c> peopleList = Database.query(queryStr); 
	    return peopleList;
	}
	
	public Map<Id,People__c> getAllPeople(Set<Id>peopleIdSet){
	    String queryStr = cacheBaseQuery+' Where Id IN: peopleIdSet';
	    return new Map<Id,People__c>((List<People__c>)Database.query(queryStr));
	}
	
	public Map<Id,People__c> getAllPeopleCaching(Set<Id>userIdSet){
	    String queryStr = cacheBaseQuery+' Where User__c IN: userIdSet';
	    return new Map<Id,People__c>((List<People__c>)Database.query(queryStr));
	}
	
	public Boolean getPeopleChangeFlag(DateTime pollDateTime, List<Bookmark__c> favUpdateList){
    	
    	Boolean hasPeopleUpdated = false;
    	List<People__c> peopleUpdatedList = [select id from People__c where Last_Edited_DateTime__c >: pollDateTime OR User__r.LastModifiedDate >: pollDateTime WITH SECURITY_ENFORCED limit 1];
    	hasPeopleUpdated = peopleUpdatedList.isEmpty()?false:true;
		
		if(hasPeopleUpdated == false){   	
	    	for(Bookmark__c bookmarkObj : favUpdateList){
	    		if('People'.equalsIgnoreCase(bookmarkObj.Type__c)){
	    			if(bookmarkObj.LastModifiedDate > pollDateTime){
	    				hasPeopleUpdated = true;
	    				break;
	    			}
	    		}
	    	}
		}
    	return hasPeopleUpdated;
    }
	
	public List<People__c>  getLastEditedPeopleList(DateTime pollTimeStamp, Integer offset, Integer size){
		Set<Id> peopleFavOrUnFavIDSet = getPeopleFavOrUnFavIDSet(pollTimeStamp);
		String queryStr = cacheBaseQuery;
		if(Utility.isApiOnlyUserQueryable()){
			queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
		}
		queryStr += ' AND ( Last_Edited_DateTime__c>:pollTimeStamp OR User__r.LastModifiedDate >:pollTimeStamp OR Id IN: peopleFavOrUnFavIDSet) ';
		queryStr += ' Order By CreatedDate ';
        if(offset != null && offset != 0){
			queryStr += ' limit :size offset :offset ';
		}
        return Database.query(queryStr);
        
	}
	
	public List<Bookmark__c> getAllFavoritePeople(String term, Integer offset, Integer recordLimit) {
		List<Bookmark__c> listOfFavorite = new List<Bookmark__c>();
		String favoriteQueryStr = 'SELECT Bookmark_Receiver__c ' +
					   'FROM Bookmark__c '+
					   'WHERE People__c=:loggedInPeopleId AND Type__c=\'People\'  AND Is_Deleted__c = false ';
		
		if(Utility.isApiOnlyUserQueryable()){
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\' AND Bookmark_Receiver__r.User__r.Profile.PermissionsApiUserOnly = false)) ';
		} else {
			favoriteQueryStr += ' And (Bookmark_Receiver__r.User__r.Show_Simpplr__c =\'Yes\' OR (Bookmark_Receiver__r.User__r.Show_Simpplr__c != \'No\' AND Bookmark_Receiver__r.User__r.isActive=true AND Bookmark_Receiver__r.User__r.UserType=\'Standard\')) ';
		}
		Set<String> setOfSearchTerms = new Set<String>();
		if(String.isNotBlank(term)) {
			setOfSearchTerms = Utility.getSearchTokens(String.escapeSingleQuotes(term));
			for(String searchToken:setOfSearchTerms){
				favoriteQueryStr+=' And Bookmark_Receiver__r.Full_Name__c like \'%'+searchToken+'%\' ';
			}
		}
		
		favoriteQueryStr += 'Order by LastModifiedDate desc '+
					   		'limit :recordLimit  offset :offset ';
		
		return Database.query(favoriteQueryStr);
	}
    
    public List<People__c> getAllSiteMemberPeopleList(Set<Id> memberIdSet, Integer offset, Integer recordLimit){
	    String queryStr = cacheBaseQuery;
	    if(Utility.isApiOnlyUserQueryable()){
	      queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
	    } else {
	      queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
	    }
	    queryStr += ' AND User__c=:memberIdSet order by Full_Name__c';
	    
	    if(recordLimit >0){
	    		queryStr += ' limit ' + recordLimit;
	    }
	    if(offset >0){
	    		queryStr += ' offset '+offset;
	    }
	    List<People__c> peopleList = Database.query(queryStr); 
	    return peopleList;
	}

	public Map<Id,SiteDao.PeopleIdAndSiteRole> getMapOfSiteMemberIdAndRoleOfSite(String siteId) {
		Map<Id,SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = new Map<Id,SiteDao.PeopleIdAndSiteRole>(); 

		if (String.isNotBlank(siteId)) {
			List<Site_Role__c> listOfSiteRole = new List<Site_Role__c>();

			if(!Test.isRunningTest() && String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false){
				listOfSiteRole = [SELECT Id, Site__c, People__c, People__r.User__c, Is_Member__c,
									Is_Manager__c, Is_Content_Manager__c , Site__r.Chatter_Group_Id__c
									FROM Site_Role__c
									WHERE Site__c = :siteId
									AND Is_Deleted__c = false AND (People__r.User__r.Show_Simpplr__c ='Yes' OR (People__r.user__r.Show_Simpplr__c != 'No' AND People__r.user__r.isActive=true AND People__r.user__r.UserType='Standard')) 
									and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: SimpplrContext.packageName) WITH SECURITY_ENFORCED];
			} else {
				listOfSiteRole = [SELECT Id, Site__c, People__c, People__r.User__c, Is_Member__c,
									Is_Manager__c, Is_Content_Manager__c , Site__r.Chatter_Group_Id__c
									FROM Site_Role__c
									WHERE Site__c = :siteId
									AND Is_Deleted__c = false AND (People__r.User__r.Show_Simpplr__c ='Yes' OR (People__r.user__r.Show_Simpplr__c != 'No' AND People__r.user__r.isActive=true AND People__r.user__r.UserType='Standard')) WITH SECURITY_ENFORCED];
			}

														
			String chatterGrpId = '';
			if(listOfSiteRole.isEmpty()){
				List<Simpplr_Site__c> siteList = [SELECT Chatter_Group_Id__c from Simpplr_Site__c WHERE Id=:siteId WITH SECURITY_ENFORCED];
				chatterGrpId = siteList.isEmpty() == false ? siteList[0].Chatter_Group_Id__c:'';
			} else {
				chatterGrpId = listOfSiteRole[0].Site__r.Chatter_Group_Id__c;
			}
			List<CollaborationGroup> collabGrpList = [SELECT Id, OwnerId, Name FROM CollaborationGroup where  id  =: chatterGrpId WITH SECURITY_ENFORCED];											
			if(!collabGrpList.isEmpty() ) {
				for(Site_Role__c siteRoleObj : listOfSiteRole) {
					SiteDao.PeopleIdAndSiteRole peopleIdAndSiteRoleObj = new SiteDao.PeopleIdAndSiteRole();
					if(((String)siteRoleObj.People__r.User__c).equalsIgnoreCase(collabGrpList[0].OwnerId)) {
						peopleIdAndSiteRoleObj.role = 'Owner';
					} else if(siteRoleObj.Is_Manager__c == true){
						peopleIdAndSiteRoleObj.role = 'Manager';
					} else if(siteRoleObj.Is_Content_Manager__c == true){
						peopleIdAndSiteRoleObj.role = 'ContentManager';
					} else {
						if(siteRoleObj.Is_Member__c == true) {
							peopleIdAndSiteRoleObj.role = 'Member';
						} else {
							peopleIdAndSiteRoleObj.role = 'Follower';
						}
					}

					peopleIdAndSiteRoleObj.id = siteRoleObj.People__c;

					mapOfMemberIdAndRoleOfSite.put(siteRoleObj.People__r.User__c, peopleIdAndSiteRoleObj);
				}
				if(mapOfMemberIdAndRoleOfSite.get(collabGrpList[0].OwnerId) == null){
					SiteDao.PeopleIdAndSiteRole peopleIdAndSiteRoleObj = new SiteDao.PeopleIdAndSiteRole();
					peopleIdAndSiteRoleObj.role = 'Owner';
					mapOfMemberIdAndRoleOfSite.put(collabGrpList[0].OwnerId,peopleIdAndSiteRoleObj);
				}
			} else {
				//user does not have access to the site record now
				throw new SimpplrException(ExceptionCode.NO_SITE_ACCESS.name());
			}
			
		}
		
		return mapOfMemberIdAndRoleOfSite;
	}
    
    @testVisible
    private Set<Id> getPeopleFavOrUnFavIDSet(DateTime pollTimeStamp){
		Set<Id> peopleFavOrUnFavIDSet = new Set<Id>();
		List<Bookmark__c> bookmarkList = [Select Bookmark_Receiver__c From Bookmark__c Where Type__c = 'People' AND LastModifiedById =: UserContext.userId AND LastModifiedDate >: pollTimeStamp WITH SECURITY_ENFORCED];
		for(Bookmark__c bookMarkObj : bookmarkList){
			peopleFavOrUnFavIDSet.add(bookMarkObj.Bookmark_Receiver__c);
		}
		return peopleFavOrUnFavIDSet;
	}
	
	
	@testVisible
	private Set<Id> getOffsetPeopleIdSet(Integer size, Integer offset){
		Set<Id> peopleIdSet = new Set<Id>();
	    List<People__c> peopleList;
		if(Utility.isApiOnlyUserQueryable()){
	      peopleList = Database.query('SELECT Id FROM People__c WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) order by CreatedDate ');
	    } else {
	      peopleList = Database.query('SELECT Id FROM People__c WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' )) order by CreatedDate ');
	    }
	    Integer loopIterationIndex = (size+offset) > peopleList.size()? peopleList.size():(size+offset);
	    for(Integer Counter = offset; Counter<loopIterationIndex;  Counter++){
	    	peopleIdSet.add(peopleList[Counter].Id);
	    }
	    return peopleIdSet;
	}
	
	public Integer getPeopleCount(){
	    String queryStr = 'select count() FROM People__c ';
	    if(Utility.isApiOnlyUserQueryable()){
	      queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false)) ';
	    } else {
	      queryStr += ' WHERE (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\')) ';
	    }
	    Integer peopleCount = Database.countQuery(queryStr); 
	    return peopleCount;
	}  
}