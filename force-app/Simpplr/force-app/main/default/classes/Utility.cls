/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public class Utility {
	public static Boolean IsSiteCreationFromSimpplrUI = false; 
	public static Boolean isContentEditFromContentDetailPage = false; 
	public static Boolean isSiteRoleUpdationFromMigration = false; 
    public static List<Simpplr_Site__c> allSimpplrSite;
    public static Set<String> setOfPrivateChatterGroupIdsNotFollowedByCurrentUser;
    public static Set<Id> setOfFollowingSitesChatterGroupIdForCurrentUser;
    public static Boolean isApiOnlyUserQueryable;
	public static Map<String, Simpplr_Site__c> mapOfSimpplrSiteIdAndSimpplrSite;
    public static Map<Id, CollaborationGroup> mapOfChatterGroupsForCurrentUser;
    public static Map<Id,CollaborationGroup> allCollaborationGroupMap;
	private static final Map<String, String> PEOPLE_COLUMN_API_NAME_LABEL_MAP = new Map<String, String>{
					'Division__c' => 'Division',
					'Company_Name__c' => 'Company', 
					'Country__c' => 'Country',
					'Department__c' => 'Department',
					'State__c' => 'State',
					'City__c' => 'City',
					'Joining_Date__c' => 'hireDate'
    }; 
	public static final List<String> PEOPLE_CUSTOM_FIELDS_NAME_LIST = new List<String>{
                                                                        'Custom_Field_1__c',
                                                                        'Custom_Field_2__c',
                                                                        'Custom_Field_3__c',
                                                                        'Custom_Field_4__c',
                                                                        'Custom_Field_5__c',
                                                                        'Custom_Field_6__c',
                                                                        'Custom_Field_7__c',
                                                                        'Custom_Field_8__c',
                                                                        'Custom_Field_9__c',
                                                                        'Custom_Field_10__c',
                                                                        'Custom_Field_11__c',
                                                                        'Custom_Field_12__c',
                                                                        'Custom_Field_13__c',
                                                                        'Custom_Field_14__c',
                                                                        'Custom_Field_15__c',
                                                                        'Custom_Field_16__c',
                                                                        'Custom_Field_17__c',
                                                                        'Custom_Field_18__c',
                                                                        'Custom_Field_19__c',
                                                                        'Custom_Field_20__c',
                                                                        'Custom_Field_21__c',
                                                                        'Custom_Field_22__c',
                                                                        'Custom_Field_23__c',
                                                                        'Custom_Field_24__c',
                                                                        'Custom_Field_25__c'
	}; 
	public static final Map<String, String> AUDIENCE_STR_OBJ_FIELD_MAP = new Map<String, String>{
																		'city' => 'City__c',
																		'company' => 'Company_Name__c', 
																		'country' => 'Country__c',
																		'department' => 'Department__c',
																		'division' => 'Division__c',
																		'hireDate' => 'Joining_Date__c',
                                                                        'state' => 'State__c',
																		'title' => 'Title__c'

    };
    public static final Map<String, String> AUDIENCE_FIELD_API_NAME_N_LABEL_MAP = new Map<String, String>{
																		'City__c' => 'City',
																		'Company_Name__c' => 'Company', 
																		'Country__c' => 'Country',
																		'Department__c' => 'Department',
																		'Division__c' => 'Division',
																		'Joining_Date__c' => 'Hire Date',
																		'People_Category__c' => 'Category',
																		'State__c' => 'State',
																		'title__c' => 'Title'
    };
    public static String validteURLProtocol (String inputString) {
    	
    	if (String.isNotBlank(inputString)) {
    		
	    	if (inputString.startsWithIgnoreCase('http://') == false 
	    			&& inputString.startsWithIgnoreCase('https://') == false
	    			&& inputString.startsWithIgnoreCase('mailto:') == false
	    			&& inputString.containsIgnoreCase('://') == false) {
	    		inputString = 'http://' + inputString;
	    	}
	    	
    	}
    	
    	return inputString;
    }
    
    public static Set<User> getAllAppModeratorsWithContentModedrnOn (String appManagerNotiType) {
		Set<User> setOfAllModerators = new Set<User> ();
		Set<Id> userIdSet = new Set<Id>();
		List<People_Preference__c> peoplePreList = new List<People_Preference__c>();
		List<PermissionSetAssignment> pSetList = [SELECT Id,AssigneeId 
				FROM PermissionSetAssignment
				WHERE PermissionSet.PermissionsModerateChatter = true];
		
		for (PermissionSetAssignment pSetObj: pSetList) {
			userIdSet.add(pSetObj.AssigneeId);
		}							
		
		Map<Id,User> usersMap = new Map<Id,User>([SELECT id 
				FROM User 
				WHERE IsActive=true AND (profile.PermissionsModerateChatter = true or id=:userIdSet)]);
		userIdSet.addAll(usersMap.keySet());
		
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', userIdSet);
		String query = '';
		
		if ('appManagerNotifications'.equalsIgnoreCase(appManagerNotiType)) {	
			query = 'SELECT id, Receive_Content_Moderation_Notifications__c, people__r.User__c ' 
				+ ' FROM People_Preference__c ' 
				+ ' WHERE Receive_Content_Moderation_Notifications__c = true '
				+ ' And people__r.App_Moderation_Permission__c != \'No\' ' 
				+ ' AND people__r.User__c IN : soqlParam1';
		
		} else if ('appManagerUpdateNotification'.equalsIgnoreCase(appManagerNotiType)) {	
			query = 'SELECT id, Receive_Content_Moderation_Notifications__c, people__r.User__c '
				+ ' FROM People_Preference__c '
				+ ' WHERE Receive_Content_Update_Notifications__c = true '
				+ ' And people__r.App_Moderation_Permission__c != \'No\' '  
				+ ' AND people__r.User__c IN : soqlParam1';
		
		} else {
			query = 'SELECT id, Receive_Content_Useful_Notifications__c, people__r.User__c '
				+ ' FROM People_Preference__c '
				+ ' WHERE Receive_Content_Useful_Notifications__c = true '
				+ ' And people__r.App_Moderation_Permission__c != \'No\' '  
				+ ' AND people__r.User__c IN : soqlParam1';
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		peoplePreList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
				
		for (People_Preference__c ppObj: peoplePreList) {
			
			if (usersMap.get(ppObj.people__r.User__c) != null){
				setOfAllModerators.add(usersMap.get(ppObj.people__r.User__c));
			}
				
		}	
		
		return setOfAllModerators;
	}
	
	public static Set<Id> getAppModeratorsList () {
		Set<Id> listOfAppModeratorIds = new Set<Id> ();
		Set<Id> userIdSet = new Set<Id>();
		List<People_Preference__c> peoplePreList = new List<People_Preference__c>();
		List<PermissionSetAssignment> pSetList = [SELECT Id, AssigneeId 
				FROM PermissionSetAssignment
				WHERE PermissionSet.PermissionsModerateChatter = true];
				
		for (PermissionSetAssignment pSetObj: pSetList){
			userIdSet.add(pSetObj.AssigneeId);
		}		
							
		List<User> moderatorsList = [SELECT id 
				FROM User 
				WHERE IsActive=true AND (profile.PermissionsModerateChatter = true or id=:userIdSet)];
		
		for (User userObj: moderatorsList) {
			listOfAppModeratorIds.add(userObj.Id);
		}
		
		return listOfAppModeratorIds;
	}
	
	public static string simpleObfuscateString (String inputVal) {
		String outputVal = '';
		
		if (inputVal.length() > 48) {
			outputVal = inputVal;
		
		} else {
			Blob seedKey = Crypto.generateDigest('SHA-256', Blob.valueOf(inputVal));
			String seedKeyString = EncodingUtil.base64Encode(seedKey);			
		
			for (Integer i = 0; i < inputVal.length(); i++) {
				outputVal = outputVal + inputVal.mid(i, 1) + seedKeyString.mid(i, 1);
			}
			
		}
		
		return outputVal;
	}
	
	public static string requestAuthToken () {
		String orgId = SimpplrContext.simpplrOrgId;
		
		if (orgId.length() == 18) {
		    orgId = orgId.substring(0, 15);
		}
		   
		String seedValue = String.valueOf(DateTime.now().getTime());         
		String initVectorString = (orgID + 'SIMPPLR').substring(0, 16);
		Blob initVector = Blob.valueOf(initVectorString);
		Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
		Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
		Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
		String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0, 40);
		String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0, 32);
		Blob dataToEncrypt = Blob.valueOf(seedValue);
		Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
		String keyVal = EncodingUtil.base64Encode(encryptedData);
		String paddingLeft = '';
		
		if (keyVal.endsWith('=') == false) {
			paddingLeft = 'C';
		}
		
		if (keyVal.endsWith('==')) {
			paddingLeft = 'A';
			keyVal = keyVal.removeEnd('==');
		}
		
		if (keyVal.endsWith('=')) {
			paddingLeft = 'B';
			keyVal = keyVal.removeEnd('=');
		} 
		
		String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
		
		if (cryptoKeyString.endsWith('=') == false) {
			paddingLeft = paddingLeft + 'c';
		}
		
		if (cryptoKeyString.endsWith('==')) {
			paddingLeft = paddingLeft + 'a';
			cryptoKeyString = cryptoKeyString.removeEnd('==');
		}
		
		if (cryptoKeyString.endsWith('=')) {
			paddingLeft = paddingLeft + 'b';
			cryptoKeyString = cryptoKeyString.removeEnd('=');
		} 
		
		paddingLeft = paddingLeft + saltStringPrefix.substring(0,32) 
			    + saltStringPrefix.substring(0,16) 
				+ cryptoKeyString
				+ saltStringPrefix.substring(16,32);
		String token = paddingLeft + keyVal + saltStringSuffix + Utility.simpleObfuscateString(orgId);
		return token;
	}
	
	public static String getNewsletterTrackerCode (String newsletterId, String userIdHash) {
		String orgId = SimpplrContext.simpplrOrgId;
		
		if (orgId.length() == 18) {
		    orgId = orgId.substring(0, 15);
		}  
		 
		String seedValue = orgId + newsletterId + userIdHash;
		String initVectorString = (orgID + 'SIMPPLR').substring(0, 16);
		Blob initVector = Blob.valueOf(initVectorString);
		Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
		Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
		Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
		String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0, 40);
		String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0, 32);
		Blob dataToEncrypt = Blob.valueOf(seedValue);
		Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
		String keyVal = EncodingUtil.base64Encode(encryptedData);
		String paddingLeft = '';
		
		if (keyVal.endsWith('=') == false) {
		    paddingLeft = 'C';
		}
		
		if (keyVal.endsWith('==')) {
		    paddingLeft = 'A';
		    keyVal = keyVal.removeEnd('==');
		}
		
		if (keyVal.endsWith('=')) {
		    paddingLeft = 'B';
		    keyVal = keyVal.removeEnd('=');
		} 	
			
		String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
		
		if (cryptoKeyString.endsWith('=') == false) {
		    paddingLeft = paddingLeft + 'c';
		}
		
		if (cryptoKeyString.endsWith('==')) {
		    paddingLeft = paddingLeft + 'a';
		    cryptoKeyString = cryptoKeyString.removeEnd('==');
		}
		
		if (cryptoKeyString.endsWith('=')) {
		    paddingLeft = paddingLeft + 'b';
		    cryptoKeyString = cryptoKeyString.removeEnd('=');
		} 	
			
		paddingLeft = paddingLeft + saltStringPrefix.substring(0, 32) 
		    + saltStringPrefix.substring(0, 16) 
		    + cryptoKeyString
		    + saltStringPrefix.substring(16, 32);
		String token = paddingLeft + keyVal + saltStringSuffix + simpleObfuscateString(orgId);
		return token;
	}
	
	public static string requestNewsltterDataAuthToken (String lastId) {
		String orgId = SimpplrContext.simpplrOrgId;
		
		if (orgId.length() == 18) {
		    orgId = orgId.substring(0, 15);
		}  
		 
		String seedValue = String.valueOf(datetime.now().getTime()) + '#$#$#$' + lastId;         
		String initVectorString = (orgID + 'SIMPPLR').substring(0, 16);
		Blob initVector = Blob.valueOf(initVectorString);
		Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
		Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
		Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
		String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0, 40);
		String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0, 32);
		Blob dataToEncrypt = Blob.valueOf(seedValue);
		Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
		String keyVal = EncodingUtil.base64Encode(encryptedData);
		String paddingLeft = '';
		
		if (keyVal.endsWith('=') == false) {
			paddingLeft = 'C';
		}
		
		if (keyVal.endsWith('==')) {
			paddingLeft = 'A';
			keyVal = keyVal.removeEnd('==');
		}
		
		if (keyVal.endsWith('=')) {
			paddingLeft = 'B';
			keyVal = keyVal.removeEnd('=');
		} 
		
		String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
		
		if (cryptoKeyString.endsWith('=') == false) {
			paddingLeft = paddingLeft + 'c';
		}
		
		if (cryptoKeyString.endsWith('==')) {
			paddingLeft = paddingLeft + 'a';
			cryptoKeyString = cryptoKeyString.removeEnd('==');
		}
		
		if (cryptoKeyString.endsWith('=')) {
			paddingLeft = paddingLeft + 'b';
			cryptoKeyString = cryptoKeyString.removeEnd('=');
		} 
		
		paddingLeft = paddingLeft + saltStringPrefix.substring(0, 32) 
			    + saltStringPrefix.substring(0, 16) 
				+ cryptoKeyString
				+ saltStringPrefix.substring(16, 32);
		String token = paddingLeft + keyVal + saltStringSuffix + Utility.simpleObfuscateString(orgId);
		return token;
	}
	
	public static string requestAdoptionDataAuthToken () {
		String orgId = SimpplrContext.simpplrOrgId;
		
		if (orgId.length() == 18) {
		    orgId = orgId.substring(0, 15);
		}  
		 
		String seedValue = String.valueOf(datetime.now().getTime()) + '#$#$#$' + orgId;         
		String initVectorString = (orgID + 'SIMPPLR').substring(0,16);
		Blob initVector = Blob.valueOf(initVectorString);
		Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
		Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
		Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
		String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0, 40);
		String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0, 32);
		Blob dataToEncrypt = Blob.valueOf(seedValue);
		Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
		String keyVal = EncodingUtil.base64Encode(encryptedData);
		String paddingLeft = '';
		
		if (keyVal.endsWith('=') == false) {
			paddingLeft = 'C';
		}
		
		if (keyVal.endsWith('==')) {
			paddingLeft = 'A';
			keyVal = keyVal.removeEnd('==');
		}
		
		if (keyVal.endsWith('=')) {
			paddingLeft = 'B';
			keyVal = keyVal.removeEnd('=');
		} 
		
		String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
		
		if (cryptoKeyString.endsWith('=') == false) {
			paddingLeft = paddingLeft + 'c';
		}
		
		if (cryptoKeyString.endsWith('==')) {
			paddingLeft = paddingLeft + 'a';
			cryptoKeyString = cryptoKeyString.removeEnd('==');
		}
		
		if (cryptoKeyString.endsWith('=')) {
			paddingLeft = paddingLeft + 'b';
			cryptoKeyString = cryptoKeyString.removeEnd('=');
		} 
		
		paddingLeft = paddingLeft + saltStringPrefix.substring(0, 32) 
			    + saltStringPrefix.substring(0, 16) 
				+ cryptoKeyString
				+ saltStringPrefix.substring(16, 32);
		String token = paddingLeft + keyVal + saltStringSuffix + Utility.simpleObfuscateString(orgId);
		return token;
	}
	
	public static String buildName(String fname, String lname){
		String name = '';
		
		if (String.isNotBlank(fname) ) {
			name += fname; 
		}
		
		if (String.isNotBlank(lname) ) { 
			name += name.trim().length() > 0 ? ' ' :''; 
			name += lname; 
		}
		
		return name;
	}
	
	public static String buildLocation (String city, String state, String country) { 
		String location = '';
		if (String.isNotBlank(city) && SimpplrContext.isPPCityDisplay && !city.equalsIgnoreCase('\u200b')) { 
			location += city; 
		}
		
		if (String.isNotBlank(state) && SimpplrContext.isPPStateDisplay && !state.equalsIgnoreCase('\u200b')) { 
			location += location.trim().length() > 0 ? ', ' : ''; 
			location += state; 
		}
		
		if (String.isNotBlank(country) && SimpplrContext.isPPCountryDisplay && !country.equalsIgnoreCase('\u200b')) { 
			location += location.trim().length() > 0 ? ', ' : ''; 
			location += country; 
		}
		
		return location;
	}
	
	public static Map<Id, CollaborationGroup> getMapOfIdWithCollaborationGroup (String userIdArg) {
		Map<Id, CollaborationGroup> mapOfChatterGroups = new Map<Id, CollaborationGroup>();
		String BASE_QUERY = 'SELECT Id, name, OwnerId, MemberCount, Description,InformationTitle, isBroadcast, smallPhotoUrl, FullPhotoURL, CanHaveGuests, CollaborationType,'+
				' (SELECT Id, CollaborationGroupId, MemberId, CollaborationRole FROM GroupMembers WHERE MemberId =:userIdArg),'+
				' (SELECT status FROM GroupMemberRequests WHERE status =\'Pending\' AND RequesterId =:userIdArg)';
		String BASE_FROM_WHERE = ' FROM CollaborationGroup WHERE IsArchived = false';
		String SUB_CONDITION = ' limit 5000';
		
		if (SimpplrContext.isCommunitiesEnabled) {
	    		BASE_FROM_WHERE = BASE_FROM_WHERE+' AND NetworkId = null';
	    }
	    
	    String query = BASE_QUERY+BASE_FROM_WHERE+SUB_CONDITION;
	    List<CollaborationGroup> listOfCollaborationGrp = new List<CollaborationGroup>();
	    listOfCollaborationGrp = Database.query(query);
	    
	    for (CollaborationGroup grpObj: listOfCollaborationGrp) {
	    	mapOfChatterGroups.put(grpObj.Id,grpObj);
	    }
	    
		return 	mapOfChatterGroups;
		
	}
    
    public static Set<String> getSetOfPrivateChatterGroupIdsNotFollowedByCurrentUser () {
		
		if (setOfPrivateChatterGroupIdsNotFollowedByCurrentUser == null) {
			setOfPrivateChatterGroupIdsNotFollowedByCurrentUser = new Set<String>();
		
			if (!UserContext.hasModifyAllDataPermission) {
				String currentUserId = UserContext.id;
				String BASE_QUERY= 'Select Id, Name' +
						', (Select Id, CollaborationGroupId FROM GroupMembers WHERE Member.IsActive=true and MemberId = :currentUserId) ';
				String BASE_FROM_WHERE = 'From CollaborationGroup where CollaborationType != \'Public\'';
				
				if (SimpplrContext.isCommunitiesEnabled) {
		    		BASE_FROM_WHERE = BASE_FROM_WHERE+' AND NetworkId = null';
		    	}
		    	
				String queryStr=BASE_QUERY+BASE_FROM_WHERE;
				List<CollaborationGroup> listOfCollaborationGroups=new List<CollaborationGroup>();
			    listOfCollaborationGroups = Database.query(queryStr); 
			    Boolean found = false;
			    
			    for (CollaborationGroup cg:listOfCollaborationGroups) {
			    	found = false;

			     	for (CollaborationGroupMember memberObj: cg.GroupMembers) {
			     		found = true;
			     		break;
			     	}
			     	
			     	if (!found) {
		     			setOfPrivateChatterGroupIdsNotFollowedByCurrentUser.add(cg.id);
			     	}
			     	
			    }
			     
		    }	
		}
		return setOfPrivateChatterGroupIdsNotFollowedByCurrentUser;
	}
	
	public static List<CollaborationGroup> getChatterGroupsForCurrentUser () {
		
		if (mapOfChatterGroupsForCurrentUser == null) {
			mapOfChatterGroupsForCurrentUser = new Map<Id, CollaborationGroup>();
			String currentUserId = UserContext.id;
			String baseQuery = 'SELECT Name,Id,SmallPhotoUrl, CollaborationType FROM CollaborationGroup'+
					' where isArchived=false And id in (SELECT CollaborationGroupID FROM CollaborationGroupMember WHERE MemberId =:currentUserId)';
			String subCondition = ' order by Name ASC LIMIT 1000';
			
			if (SimpplrContext.isCommunitiesEnabled) {
		    	baseQuery = baseQuery + ' AND NetworkId = null';
		    }
		    
		    List<CollaborationGroup> listOfCollaborationGrp = new List<CollaborationGroup>();
		    String query = baseQuery+subCondition;
		    listOfCollaborationGrp = Database.query(query);
		    
		    for (CollaborationGroup grpObj: listOfCollaborationGrp) {
		    	mapOfChatterGroupsForCurrentUser.put(grpObj.Id,grpObj);
		    }
		    
		}
		
		return mapOfChatterGroupsForCurrentUser.values();
	}
	
    public static String processPatternAndMatcher (String text, Boolean url) {
        Pattern p = Pattern.compile('<img [^>]*src="([^"]+)"[^>]*>');
        Matcher m = p.matcher(text);
        
        if (m.find()) {
        	
        	if (url) {
                return m.group(1);
        	
        	} else {
                return m.replaceAll('');
        	}
        	
        }
        
        return null;
    }
    
    public static String removeAllHashSymbolFromStart (String hashString) {
    	
    	if (String.isBlank(hashString)) {
    		throw new SimpplrException(ExceptionCode.INVALID_STRING_FOR_REMOVING_HASHTAG.name() + hashString);
    	}
    	
		String regexFormat = '^(\\s*#*)*';
		Pattern myPattern = Pattern.Compile(regexFormat); 
		hashString=hashString.trim();
		Matcher attribMatcher = myPattern.matcher(hashString);
		
		if (attribMatcher.find()) {
			hashString = hashString.replaceAll(regexFormat, '');
		}
		
    	return hashString;
    }
    
    public static String formattingDateAsMMDDYYYY (String storedDate) {
        //Formatting the Date as MM/dd/yyyy
        if (String.isBlank(storedDate)) {
    		return storedDate;
    	}
    	
        List<String> splittedString = storedDate.split('-');
        return splittedString[1]+'/'+splittedString[2]+'/'+splittedString[0];
    }
	
	public static String getDuration (DateTime adateTime) {
		String duration = ' sec';
		Double diff = (DateTime.now().getTime() - adateTime.getTime())/1000;
		
		if (diff > 60) {
			diff = diff/60;
			duration = ' min';
		
			if (diff > 60) {
				diff = diff/60;
				duration = ' hr';
				
				if (diff > 24) {
					diff = diff/24;
					duration = ' day';
				}
				
			}
			
		}
		
		if (diff.intValue() > 1) {
			duration = diff.intValue() + duration + 's ago';
		
		} else {
			duration = diff.intValue() + duration + ' ago';
		}
		
		return duration;
	}
	
    public static String dateToDisplayString (DateTime dateTimeValue, String format) {
        String result = '';
        
        if (dateTimeValue != null) {
			result = dateTimeValue.format(format);  
        }
        
        return result;
    }
    
    public static String dateTimeStringInGMT (DateTime dateTimeValue, String format) {
        String result = '';
        
        if (dateTimeValue != null) {
			result = dateTimeValue.formatGMT(format);  
        }
        
        return result;
    }
    
    public static String dateToDisplayString (Date dateValue, String format) {
        String result = '';
        
        if (dateValue != null) {
            DateTime dateTimeValue = Datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
         	result = dateTimeValue.format(format);  
        }
        
        return result;
	}
	
	public static String timezoneSecificDateToMomentJSDateTime (Date inputDate, TimeZone inputDateTimeZone) {
		Integer offset = inputDateTimeZone.getOffset(inputDate);
		Long timeInMilliSeconds =  DateTime.newInstanceGMT(inputDate.year(), inputDate.month(), inputDate.day()).getTime();  
		DateTime dateTimeInCurrentTimezone = DateTime.newInstance(timeInMilliSeconds - offset);              
		return dateTimeInCurrentTimezone.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
	}
    
    public static String dateTimeToMomentJSDateTime (DateTime inputDateTime) {
    	return inputDateTime != null ? inputDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') : null;
	}
	
    public static DateTime momentJSDateTimeStringToDateTime (String dateTimeString) {
    	//2016-03-28T16:09:23+05:30
    	String year = dateTimeString.substring(0, 4);
		String month = dateTimeString.substring(5, 7);
		String day = dateTimeString.substring(8, 10);
		String hour = dateTimeString.substring(11, 13);
		String minute = dateTimeString.substring(14, 16);
		String second = dateTimeString.substring(17, 19);
        DateTime returnDate = DateTime.newInstance(Integer.valueOf(year), 
        		Integer.valueOf(month), Integer.valueOf(day), Integer.valueOf(hour), 
        		Integer.valueOf(minute), Integer.valueOf(second));

        return returnDate;
    }

    /**
    * @description Extract date component from string
    **/
    public static Date momentJSDateTimeStringToDate(String dateTimeString) {
		//2022-07-04T00:00:00
		Integer year = Integer.valueOf(dateTimeString.substring(0, 4));
		Integer month = Integer.valueOf(dateTimeString.substring(5, 7));
		Integer day = Integer.valueOf(dateTimeString.substring(8, 10));
	    Date returnDate = Date.newInstance(year, month, day);
	    return returnDate;
	}

	/**
	* @description convert date and time to datetime
	* used for UI publishAt conversion for content
	**/
	public static Datetime momentJSDateTimeStringToDateTime(Date dateStr, Time timeStr) {
		DateTime returnDate = DateTime.newInstance(dateStr.year(), 
        		dateStr.month(), dateStr.day(), timeStr.hour(), 
        		timeStr.minute(), timeStr.second());
		return returnDate;
	}
    
    /**
	* 
	* Purpose:  [Converts Date in String format to Date]
	* Parameters:
	*      dateString -- 'NOV 2, 2017 (PST)' 
	*      
	* Returns:  Date
	*/

    public static Date stringToDate (String dateString) {
    	Date returnValue;
    	
    	if (String.isNotBlank(dateString)) {
	        List<String> stringPartList = dateString.split('-');
	        returnValue = Date.newInstance(Integer.valueOf(stringPartList[0]),
					Integer.valueOf(stringPartList[1]),
					Integer.valueOf(stringPartList[2]));
    	}
		
        return returnValue;
    }
    
    //-----Method to convert bytes into human readable formate---------AS/10/30/2015-------
    public static String byteToHumanReadableFormate(Decimal bytes){
        String result = '';
        bytes = bytes==null? 0.0 : bytes;
        
        if (bytes < 1024){
            result =  string.valueOf(bytes) + ' Bytes';
        }
        else if (bytes >= 1024 && bytes < (1024*1024)){
            //KB
            bytes = bytes.divide(1024,2);
            result = string.valueOf(bytes) + ' KB';
        }
        else if (bytes >= (1024*1024) && bytes < (1024*1024*1024)){
            //MB
            bytes = bytes.divide((1024*1024),2);
            result = string.valueOf(bytes) + ' MB';
        }
        else{
            //GB
            bytes = bytes.divide((1024*1024*1024),2);
            result = string.valueOf(bytes) + ' GB';
        }
        return result;   
    }
    
    public static HttpResponse getJsonResponseFromExternalSystem(String requestType, String endpoint, String authorizationHeader, String jsonBody) {
        HttpResponse res = null;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(60000);
		if(String.isNotBlank(authorizationHeader)) {
			req.setHeader('Authorization', authorizationHeader);
		}
        req.setHeader('Content-Type', 'application/json');
        req.setMethod(requestType);
        if(String.isNotBlank(jsonBody)) {
            req.setBody(jsonBody);
        }
        res = h.send(req);
        return res;
    }

    public static HttpResponse getJsonResponseFromExternalSystem(String requestType, String endpoint, String authorizationHeader, String jsonBody,Map<String,String> mapOfHeaders) {
        HttpResponse res = null;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = endpoint;
        req.setEndpoint(endPointValue);
        req.setTimeout(60000);
        req.setHeader('Authorization', authorizationHeader);
        for(String key:mapOfHeaders.keySet()){
            req.setHeader(key, mapOfHeaders.get(key));
        }
        req.setMethod(requestType);
        if(String.isNotBlank(jsonBody)) {
            req.setBody(jsonBody);
        }
        res = h.send(req);
        return res;
    }
	
    /** **/
    public static String getJsonFormat(Object obj) {
        try{
            return  Json.serialize(obj);
        } catch(Exception e) {
            throw e;
        }
    }
    
    //return valid words and spaces from specified maxlength. Default value for boolean is false in case of null
    public static String getAllValidWords(String s, Integer maxChar,Boolean isHtmlStrip)
    {
        if(maxChar==null || maxChar==0)
        {
            throw new SimpplrException(ExceptionCode.INVALID_MAX_LENGTH.name());
        }
        if(s==null || s.length()==0)
        {
            throw new SimpplrException(ExceptionCode.INVALID_STRING.name());
        }
        if(isHtmlStrip!=null && isHtmlStrip)
        {
            s=s.replaceAll('<[^>]+>','');
        }
        
        return chompString(s,maxChar);// let suppose max lenght=400 and valid word end on 358 so it will search in 400 and return 358 chars
    }
    
    public static String chompString(String s, Integer maxLength) {
        s=manageNullForString(s);
        if(s.length() > maxLength) {
            s=s.subString(0, maxLength);         
            Integer lastIndex=s.lastIndexOf(' ');
            
            if(lastIndex != -1 && lastIndex <= (maxLength-4)) {
				s = s.subString(0, lastIndex) + ' ...';
			} else if(lastIndex != -1) {
				s = chompString(s, lastIndex-1);
            } else {
            	s = s.subString(0, maxLength - 4) + ' ...';
            }
        }
        return s;
    }
    
    public static String manageNullForString(String s){
        return s==null?'':s.trim();
    }
    
    public static String getPhotoVersionId(String photoURL) {
    	String photoVersionId;
    	if(photoURL!=null) {
	    	String[] parts = photoURL.split('/');
	    	if(parts.size() > 2) {
				if(parts[parts.size() - 2].length() == 15) {
					photoVersionId = parts[parts.size() - 2];
				}
	    	}
    	}
    	return photoVersionId;
    }
    
    
	
	//added by jeevan
    public static String getSimpplrContentPrefix() {
		Schema.DescribeSObjectResult r = Simpplr_Content__c.sObjectType.getDescribe();
		return r.getKeyPrefix();
	}

    public static String getSimpplrContentApiName() {
		Schema.DescribeSObjectResult r = Simpplr_Content__c.sObjectType.getDescribe();
		return r.getname();
	}

    public static String getTopicPrefix() {
		Schema.DescribeSObjectResult r = Topic.sObjectType.getDescribe();
		return r.getKeyPrefix();
	}

	
	//added by jeevan
    public static String getSimpplrSitePrefix() {
		Schema.DescribeSObjectResult r = Simpplr_Site__c.sObjectType.getDescribe();
		return r.getKeyPrefix();
	}
	
	//added by jeevan
    public static String getPeoplePrefix() {
		Schema.DescribeSObjectResult r = People__c.sObjectType.getDescribe();
		return r.getKeyPrefix();
	}
	
	public static String getSimpplrFilePrefix() {
		Schema.DescribeSObjectResult r = File__c.sObjectType.getDescribe();
		return r.getKeyPrefix();
	}
    
    public static Set<String> getSearchTokens(String searchString) {
    	if(String.isBlank(searchString)){
    		return new Set<String>();
    	}
    	Set<String> stopWords=new Set<String>{'a', 'am', 'an', 'are','is', 'the',
    														  'and', 'or', '%', ' ', '', '  '};
    	
		List<String> listOfSearchTokens=new List<String>();
	    Set<String> setOfIndividualTokens=new Set<String>();
	    
	    String inputString = searchString.replaceAll('%','');
	    listOfSearchTokens.addAll(inputString.split(' '));
	    
	    for(Integer i=0;i<listOfSearchTokens.size();i++){
	        boolean found=false;
	        if(listOfSearchTokens[i].startsWith('"')){
	            String tokenElement=listOfSearchTokens[i];
	        	if(listOfSearchTokens[i].endsWith('"')) {
	        		setOfIndividualTokens.add(tokenElement.removeStart('"').removeEnd('"'));
	        		found=true;
	        	} else {
		            for(Integer j=i+1; j<listOfSearchTokens.size();j++){
		                tokenElement=tokenElement+' '+listOfSearchTokens[j];
		                if(listOfSearchTokens[j].endsWith('"')){
		                    setOfIndividualTokens.add(tokenElement.removeStart('"').removeEnd('"'));
		                    found=true;
		                    i=j;
		                    break;
		                }
		            }
	        	}
	        }
	        if(!found){
	        	setOfIndividualTokens.add(listOfSearchTokens[i]);
	        }
	    }
	    if(!stopWords.containsAll(setOfIndividualTokens)) { 
			setOfIndividualTokens.removeAll(stopWords);
	    }
		if(setOfIndividualTokens.size() == 0) {
			throw new SimpplrException(ExceptionCode.INVALID_SEARCH_TERM.name());
		}
	    return setOfIndividualTokens;
	}
	
    /**
     * Converts "list of string" to "comma separated string"
     */
    public static String convertToCommaSeparatedString(List<String> itemsList) {
    	String returnValue = '';
    	
    	for(String str : itemsList) {
    		if(str.trim().length() > 0) {
    			returnValue += str.trim() + ',';
    		}
    	}
    	
    	if(returnValue.length() > 0) {
    		returnValue = returnValue.subString(0, (returnValue.length() -1));
    	}
    	
    	return returnValue;
    }
    
    public static Boolean isApiOnlyUserQueryable(){
    	if(isApiOnlyUserQueryable == null) {
    		isApiOnlyUserQueryable = false;
			Schema.DescribeSObjectResult r = Profile.sObjectType.getDescribe();
			Map<String, Schema.SObjectField> mapOfFields = r.fields.getMap();
			if(mapOfFields.containsKey(ServiceConstants.API_ONLY_USER_PERMISSION_NAME)){
				isApiOnlyUserQueryable = true;
			}
    	}
		return isApiOnlyUserQueryable;
	}
	
	public static String getPlainText(String s, Integer maxChar,Boolean isHtmlStrip) {
        if(String.isNotBlank(s)) {
			if(maxChar==null || maxChar==0) {
				throw new SimpplrException(ExceptionCode.INVALID_MAX_LENGTH.name());
			}
			
			if(isHtmlStrip!=null && isHtmlStrip) {
			//String s = '<div>text</div><p>here</p><b>a</b><i>side</>';
				s = s.replaceAll('(?i)<td[^>]*>', ' ');
				s = s.replaceAll('(?i)</td[^>]*>', ' ');
				s =s.replaceAll('(?i)<p[^>]*>', ' ');
				s =s.replaceAll('(?i)</p[^>]*>', ' ');
				s =s.replaceAll('(?i)<li[^>]*>', ' ');
				s =s.replaceAll('(?i)</li[^>]*>', ' ');
				s =s.replaceAll('(?i)<br[^>]*>', ' ');
				s =s.replaceAll('(?i)<span class="fr-video-processing-overlay.*>', '');
				s =s.replaceAll('(?i)<div[^>]*>', ' ');
				s =s.replaceAll('(?i)</div[^>]*>', ' ');
				s = s.replaceAll('<[^>]*>', '').trim();
				s = s.replaceAll('\\s+', ' ').trim();
			}        
			s = chompString(s,maxChar);// let suppose max lenght=400 and valid word end on 358 so it will search in 400 and return 358 chars
		}

		return s;
    }
	
	public static String getFileDownloadBaseURL(){

        return SimpplrContext.isEnhancedDomainEnabled ? SimpplrContext.FileDownloadBaseURL : '';
    }
    
    public static String getFileDownloadURL(String contentId){
        return getFileDownloadBaseURL() + '/sfc/servlet.shepherd/version/Download/' + contentId + '?asPdf=false&operationContext=CHATTER';
    }
    
    public static String getFileDowloadRelativeURL(String contentId){
    	return '/sfc/servlet.shepherd/version/Download/' + contentId + '?asPdf=false&operationContext=CHATTER';
    }
    
	public static String getImageFullSizeRenderUrl(String contentId){
		return getFileDownloadBaseURL() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Png&versionId=' + contentId;
    }

    public static String getFileDownloadURLFor720By480(String contentId){
        return getFileDownloadBaseURL() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + contentId;
    }
    
    public static String getFileDownloadURLFor240BY180(String contentId){
        return getFileDownloadBaseURL() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=' + contentId;
    }
    
    public static String getFileDownload240BY180URLForMobile(String contentId){
        return SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL + contentId + '/rendition?type=THUMB240BY180';
    }
    
    public static String getFileDownloadURLFor120BY90(String contentId){
        return getFileDownloadBaseURL() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + contentId;
    }
    
    public static String getProfilePhotoURL(String photoURL) {
    		string profilePhotoURL;
    		if(String.isNotBlank(photoURL) && !photoURL.endsWith('005/T') && !photoURL.endsWith('005/F')) {
    			profilePhotoURL = photoURL;
    		}
        return profilePhotoURL;
    }

    public static Date parseStringDate(String str) {
    	if(str==null){
    		return null;
    	}
	    String[] strArray = str.split('-');
	    
	    return Date.newInstance(Integer.valueOf(strArray[0]), Integer.valueOf(strArray[1]), Integer.valueOf(strArray[2])); 
	}
	
	// Function to convert Exception details to String
	public static String convertExceptionToString(Exception ex) {
		String str = '';
		str +=' <br/><br/>Error Message - ' + ex.getMessage(); 
		str +=' <br/>Line Number - ' + ex.getLineNumber();
		str +=' <br/>Error cause - ' + ex.getCause(); 
		str +=' <br/>Error stack trace - ' + ex.getStackTraceString();
		str +=' <br/>Exception Type Name - ' + ex.getTypeName();
		str +=' <br/><br/>Org Details:<br/>';
		str +=' <br/>UserId - '+ UserContext.id;
		str +=' <br/>User Name - '+ UserContext.peopleName;
		str +=' <br/>OrgId - '+ UserInfo.getOrganizationId();
		str +=' <br/>Org Name - '+ UserInfo.getOrganizationName();
		
		if(ex instanceof EFSException || ex instanceof SCoreSystemException) {
			str += ' <br/><br/> Trace from EFSException - ' + EFSException.trace;
		}
		return str;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public static Boolean sendBatchFailedExceptionEmail(String className, Exception ex) {
		Boolean returnValue = false;
		String mailSubject='' + className + ' batch failed';
		
		String mailBodyHtml='Dear User'+ ', <br/><br/> ' + className + ' batch has failed due to following reasons:';
		mailBodyHtml+=convertExceptionToString(ex);
		mailBodyHtml+=' <br/> <br/> Thanks.!';
		
		EmailUtility emailUtilObj = new EmailUtility();
		emailUtilObj.sendMailToCurrentUser(mailSubject,mailBodyHtml);
		
		returnValue = true;
		
		return returnValue;
	}
	
    public static Boolean sendExceptionEmail(String className, Exception ex) {
		Boolean returnValue = false;
		String mailSubject='Exception in ' + className;
		
		String mailBodyHtml='Dear User'+ ', <br/><br/> ' + className + ' has thrown exception due to following reasons:';
		mailBodyHtml+=convertExceptionToString(ex);
		mailBodyHtml+=' <br/> <br/> Thanks.!';
		
		EmailUtility emailUtilObj=new EmailUtility();
		emailUtilObj.sendMailToPackageManager(mailSubject, mailBodyHtml);
		
		returnValue = true;
		
		return returnValue;
	}
	
	public static void sendPushNotifications(String notiListJsonMobile, String notiListJsonBrowser) {
		
		String PUSH_NOTI_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/notifications/web-push-manager'; 
		String simpplrDri = Utility.externalRequestAuthToken() + 
				' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
				' ' + UserContext.userId.substring(0, 15);
		HttpRequest req = new HttpRequest();
		req.setEndpoint(PUSH_NOTI_ENDPOINT);
		Map<String, Object> requestBody = new Map<String, Object>();
		String val = Utility.requestAuthToken();
		String orgId = UserInfo.getOrganizationId();
	 	String appName = SimpplrContext.applicationName;
		String payLoad = null;
		if(String.isNotBlank(notiListJsonMobile)) {
			requestBody.put('data', val);
            requestBody.put('notificationList', notiListJsonMobile);
            requestBody.put('appName', appName);
        }
		requestBody.put('action', 'pushnotifications');
		requestBody.put('notiListJsonBrowser', notiListJsonBrowser);
		requestBody.put('orgId', ((String)SimpplrContext.simpplrOrgId).substring(0, 15));
        requestBody.put('peopleId', ((String)UserContext.peopleId).substring(0, 15));
		req.setBody(Json.serialize(requestBody));
		req.setHeader('simpplr-dri', simpplrDri);
		req.setMethod('POST');
		Http httpObj = new Http();
		if (!test.isRunningTest()){
			HttpResponse response = httpObj.send(req);
		}
	}

	public static void sendWebPushConfigInfoToLambda(String peopleId, String webPushToken, String userAgent) {
		String WEB_PUSH_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/notifications/web-push-manager'; 
		String simpplrDri = Utility.externalRequestAuthToken() + 
				' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
				' ' + UserContext.userId.substring(0, 15);
				
		HttpRequest req = new HttpRequest();
		req.setEndpoint(WEB_PUSH_ENDPOINT);
		
		Map<String, Object> requestBody = new Map<String, Object>();
		
		String val = Utility.requestAuthToken();
		String orgId = UserInfo.getOrganizationId();
	 	String appName = SimpplrContext.applicationName;
		
		requestBody.put('action', 'saveUserWebPushConfig');

		requestBody.put('orgId', orgId.substring(0, 15));
		requestBody.put('peopleId', peopleId.substring(0, 15)); 
		requestBody.put('webPushToken', webPushToken); 
		requestBody.put('userAgent', userAgent); 
		requestBody.put('appName', appName); 
		
		req.setBody(Json.serialize(requestBody));
		req.setHeader('simpplr-dri', simpplrDri);
		
		req.setMethod('POST');
		Http httpObj = new Http();
		if (!test.isRunningTest()){
			HttpResponse response = httpObj.send(req);
		}
	}
	
	public static String getSimpplrLanguageLocaleKey(String salesforceLanguageLocaleKey) {
		String simpplrLanguageLocaleKey = ServiceConstants.SUPPORTED_LOCALE_MAP.get(salesforceLanguageLocaleKey);
		if(SimpplrContext.appLanguageEnabledSet.contains(simpplrLanguageLocaleKey) == false) {
			if('en_UK'.equalsIgnoreCase(simpplrLanguageLocaleKey) && SimpplrContext.appLanguageEnabledSet.contains('en_US')) {
				simpplrLanguageLocaleKey = 'en_US';

			} else if('en_US'.equalsIgnoreCase(simpplrLanguageLocaleKey) && SimpplrContext.appLanguageEnabledSet.contains('en_UK')) {
				simpplrLanguageLocaleKey = 'en_UK';

			} else {
				simpplrLanguageLocaleKey = SimpplrContext.appDefaultLanguage;
			}
		}
		return simpplrLanguageLocaleKey;
	}
	public static string timezoneIdToDisplayLabel(String inputTZID) {
		String outputLabel = '';
		Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getdescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
		List<MySettingsWrapper.TimezoneWrapper> lstTZ = new  List<MySettingsWrapper.TimezoneWrapper>();
		for(Schema.PicklistEntry p : ple) {	
		    if(p.getValue().equalsIgnorecase(inputTZID)) {
		        outputLabel = p.getlabel(); 
		        break;
		    }
		}
		outputLabel = outputLabel.substringAfter(')');
		outputLabel = outputLabel.trim();
		outputLabel = outputLabel.substringBeforeLast('(');
		outputLabel = outputLabel.trim();
		return outputLabel.trim();
	}

	/*
	* this will call Lambda to remove all script,select,input,button,textarea tags along with their text plus remove all event related attributes from all
	* elements from text and links
	*/
	public static String getSanitizedHTMLfromLambda(String htmlInput) {
		if(String.isBlank(htmlInput))
    	{
    		return htmlInput;
    	}
		Map<String, String> requestBody = new Map<String, String>();	
		requestBody.put('input', (htmlInput));
	 	HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint+'/utility/sanitize-html', requestBody);
		String responseVal; 
		String sanitizedHtml = '';//
		if(res.getStatusCode()==200){
			responseVal = res.getBody();
			Map<String, String> resMap = (Map<String, String>)JSON.deserialize(responseVal, Map<String, String>.class);
			sanitizedHtml = resMap.get('sanitizedHtml');
		}else{
			logger.logError('Utility.getSanitizedHtmlfromLambda()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
		}
		return sanitizedHtml;
	}
    
    private static String removeHtmlTagWithBody(String html, String tag){
    	String retVal = html;
    	//added (?i) for case insensitive
    	String scriptFormat = '(?i)<\\s*?'+tag+'([^\'"]|"[^"]*"|\'[^\']*\')*?<\\s*?\\/\\s*?'+tag+'\\s*?>';
        Pattern scriptPattern = Pattern.Compile(scriptFormat); 
		Matcher m = scriptPattern.matcher(retVal);
		retVal = m.replaceAll('');
		return retVal;
    }
    
    /**
    	value for parameter 
    	 - fileProvider ->  1. BOX - for box files
    	 					2. null - for CRM/Intranet files
    */
    public static Boolean isDownloadableOniOS(String fileType, String fileProvider) {
    	Boolean returnValue = false;		
		String userAgent = SimpplrContext.userAgent;
		
		if(String.isNotBlank(fileType) && String.isNotBlank(userAgent) && userAgent.containsIgnoreCase('mobile') && userAgent.containsIgnoreCase('apple') && String.isBlank(fileProvider)) {
			if(fileType.equalsIgnoreCase('jpg') || fileType.equalsIgnoreCase('gif')
				|| fileType.equalsIgnoreCase('png') || fileType.equalsIgnoreCase('jpeg')
				|| fileType.equalsIgnoreCase('tiff') || fileType.equalsIgnoreCase('pdf')
				|| fileType.equalsIgnoreCase('doc') || fileType.equalsIgnoreCase('docx') || fileType.equalsIgnoreCase('doc_x')
				|| fileType.equalsIgnoreCase('xls') || fileType.equalsIgnoreCase('xlsx') || fileType.equalsIgnoreCase('xls_x')
				|| fileType.equalsIgnoreCase('ppt') || fileType.equalsIgnoreCase('pptx') || fileType.equalsIgnoreCase('ppt_x')
				|| fileType.equalsIgnoreCase('txt') || fileType.equalsIgnoreCase('rtf')
				|| fileType.equalsIgnoreCase('key') || fileType.equalsIgnoreCase('key.zip')
				|| fileType.equalsIgnoreCase('numbers') || fileType.equalsIgnoreCase('numbers.zip')
				|| fileType.equalsIgnoreCase('pages') || fileType.equalsIgnoreCase('pages.zip')
				|| fileType.equalsIgnoreCase('mov') || fileType.equalsIgnoreCase('mp4')
				|| fileType.equalsIgnoreCase('mp3') || fileType.equalsIgnoreCase('aac')
				) {
				returnValue = true;
			}
		}    	
		return returnValue;
    }
    
    public static String convertTextToLowerCaseAndDeleteSpaces(String inputText){
    	if(String.isNotBlank(inputText)){
    		inputText = inputText.deleteWhitespace().toLowerCase();	
    	}
    	return inputText; 
    }
    
    public static String getTopicIdFromTopicName(String topicName){
    	String topicId;
    	topicName = convertTextToLowerCaseAndDeleteSpaces(topicName);
    	if(String.isNotBlank(topicName)){
	    	String firstLetter = topicName.substring(0,1);
			String lastLetter = topicName.substring(topicName.length()-1,topicName.length());
			Map<String,String> topicNameToIdMap = new Map<String,String>();
			List<Topic> topicList = [select id, Name from topic where name LIKE: firstLetter+'%' and name LIKE: '%'+lastLetter limit 49000];
			for(Topic topic : topicList){
				topicNameToIdMap.put(topic.Name.deleteWhitespace().toLowerCase(),topic.id);
			}
			if(!topicNameToIdMap.isEmpty() && topicNameToIdMap.get(topicName) != null) {
				topicId = topicNameToIdMap.get(topicName);
			}
    	}
    	return topicId;
    }
    
    public static Map<Id,CollaborationGroup> getAllCollaborationGroupMap(){
		if(allCollaborationGroupMap == null){
			allCollaborationGroupMap = New Map<Id,CollaborationGroup>();
			String BASE_QUERY = 'SELECT Id, Name, SmallPhotoUrl, CollaborationType, FullPhotoUrl, MemberCount FROM CollaborationGroup where IsArchived=false';
			if(SimpplrContext.isCommunitiesEnabled){
				BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
			}
			List<CollaborationGroup> collabGrpList = Database.query(BASE_QUERY);
			for(CollaborationGroup grp : collabGrpList){
				allCollaborationGroupMap.put(grp.id, grp);
			}
		}
		return allCollaborationGroupMap;
    } 
    
    public static Map<Id,CollaborationGroup> getAllCollaborationGroupMapForSiteIds(List<Id> groupIds){
    	
		Map<Id,CollaborationGroup> allCollaborationGroupMapForSite = New Map<Id,CollaborationGroup>();
		String userId = UserContext.id;
		String BASE_QUERY = 'SELECT Id, CreatedDate, SmallPhotoUrl,CollaborationType,description,InformationBody, InformationTitle, MemberCount,OwnerId,IsBroadcast,CanHaveGuests, (select Id, MemberId, CollaborationRole from GroupMembers where memberId=:userId), (SELECT status FROM GroupMemberRequests WHERE status =\'Pending\' AND RequesterId =:userId) FROM CollaborationGroup where IsArchived=false and Id IN :groupIds';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}
		List<CollaborationGroup> collabGrpList = Database.query(BASE_QUERY);
		for(CollaborationGroup grp : collabGrpList){
			allCollaborationGroupMapForSite.put(grp.id, grp);
		}
		return allCollaborationGroupMapForSite;
    } 
    
    public static Map<Id,CollaborationGroup> getAllPublicCollaborationGroupMap(){
    	
		Map<Id,CollaborationGroup> allPublicCollaborationGroupMap = New Map<Id,CollaborationGroup>();
		String BASE_QUERY = 'SELECT Id, Name, SmallPhotoUrl, CollaborationType, FullPhotoUrl, MemberCount FROM CollaborationGroup where IsArchived=false And CollaborationType=\'Public\'';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}
		List<CollaborationGroup> collabGrpList = Database.query(BASE_QUERY);
		for(CollaborationGroup grp : collabGrpList){
			allPublicCollaborationGroupMap.put(grp.id, grp);
		}
		return allPublicCollaborationGroupMap; 
    }
    
    public static Map<Id,CollaborationGroup> getAllUnlistedCollaborationGroupMap(){
    	
		Map<Id,CollaborationGroup> allPublicCollaborationGroupMap = New Map<Id,CollaborationGroup>();
		String BASE_QUERY = 'SELECT Id, Name, SmallPhotoUrl, CollaborationType, FullPhotoUrl, MemberCount FROM CollaborationGroup where IsArchived=false And CollaborationType=\'Unlisted\'';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}
		List<CollaborationGroup> collabGrpList = Database.query(BASE_QUERY);
		for(CollaborationGroup grp : collabGrpList){
			allPublicCollaborationGroupMap.put(grp.id, grp);
		}
		return allPublicCollaborationGroupMap; 
    }
    
    public static Map<Id,Simpplr_Site__c> getAllSimpplrSiteMap(){
    	Set<ID> chatterGroupIdSet = Utility.getAllCollaborationGroupMap().keySet();
    	Map<Id,Simpplr_Site__c> allSimpplrSiteMap = New Map<Id,Simpplr_Site__c>([Select Id, Name,Site_Type__c, Chatter_Group_Id__c,Title_Content_Version__c from Simpplr_Site__c where Is_Active__c=true and chatter_Group_Id__c != 'S06I000000MPPLR' and Is_Deleted__c = false and chatter_Group_Id__c in :chatterGroupIdSet order by Name]);
    	return allSimpplrSiteMap;
    }
    
    public static Map<Id,Simpplr_Site__c> getAllSitesExcludingUnlistedMap(){
    	Set<ID> chatterGroupIdSet = Utility.getAllCollaborationGroupMap().keySet();
    	Map<Id,Simpplr_Site__c> allSitesExcludingUnlistedMap = New Map<Id,Simpplr_Site__c>([Select Id, Name,Site_Type__c, Chatter_Group_Id__c from Simpplr_Site__c where  chatter_Group_Id__c != 'S06I000000MPPLR' and Is_Deleted__c = false and Site_Type__c != 'Unlisted' and chatter_Group_Id__c in :chatterGroupIdSet order by Name]);
    	return allSitesExcludingUnlistedMap;
    }

    public static map<Id,Simpplr_Site__c> sitesIManageWithAlertAccessMap(){
		Map<Id,Simpplr_Site__c> sitesIManageWithAlertAccessMap = new map<Id,Simpplr_Site__c>();
		sitesIManageWithAlertAccessMap = new Map<Id,Simpplr_Site__c>([select id, Name,Site_Type__c, Chatter_Group_Id__c from Simpplr_Site__c where Is_Alert_Enabled__c = true AND Is_Deleted__c = false and Id IN: UserContext.sitesIManageIdSet]);
    	return sitesIManageWithAlertAccessMap;
    }
    
    public static Map<Id,Simpplr_Site__c> getAllUnlistedSiteMap(){
    	Set<ID> chatterGroupIdSet = Utility.getAllUnlistedCollaborationGroupMap().keySet();
    	Map<Id,Simpplr_Site__c> allUnlistedSimpplrSiteMap = New Map<Id,Simpplr_Site__c>([Select Id,Name,Site_Type__c,Chatter_Group_Id__c,Title_Content_Version__c from Simpplr_Site__c where Is_Active__c=true and Site_Type__c = 'Unlisted' and chatter_Group_Id__c != 'S06I000000MPPLR' and Is_Deleted__c = false and chatter_Group_Id__c in :chatterGroupIdSet order by Name]);
    	return allUnlistedSimpplrSiteMap;
    }
    
    public static List<String> getuserIdList(List<String> peopleIdList) {
		List<String> userIdList = new List<String>();
		List<People__c> peopleList = [select user__c from people__c where id=:peopleIdList];
		for(People__c people: peopleList){
			userIdList.add(people.User__c);
		}
		return userIdList;
	}
	
	public static List<String> getPeopleIdList(List<String> userIdList) {
		Map<String,People__c> peopleMap = new Map<String,People__c>([select id from People__c where user__c=:userIdList]);		
		if(!peopleMap.keySet().isEmpty()) {
			return new List<String>(peopleMap.keySet());
		} else {
			return new List<String>();
		}
	}
	
	public static List<People__c> getListOfPeopleWithSegmentationFields(List<String> userIdList) {
		List<People__c> peopleList = [select id,user__r.Id, Name, Segment__r.Id, Segment__r.Branding_JSON__c, Segment__r.Branding_Logo__c from People__c where user__c=:userIdList];		
		
		return peopleList;
	}
	
	public static Map<String,People__c> userIdToPeopleMap( List<String> userIdList){		
		List<People__c> peopleList = [select id,user__r.Id, name, Full_Name__c from People__c where user__c=:userIdList];		
		Map<String,People__c> userIdToPeopleMap = new Map<String,People__c>(); 
		for (People__c ppl : peopleList){
			userIdToPeopleMap.put(ppl.user__r.Id,ppl);
		} 
		return userIdToPeopleMap;
	}
	
	public static Set<String> favouriteContentSet(List<String> contentIdList){		
		Set<String> favouriteContentIdSet = new Set<String>();
		List<Bookmark__c> bookmarkedContentList = [select Simpplr_Content__r.id from Bookmark__c where Simpplr_Content__c IN:contentIdList and people__r.User__c =:UserInfo.getUserId() and Is_Deleted__c = false];
		
		for(Bookmark__c bookMarkObj : bookmarkedContentList){
			favouriteContentIdSet.add(bookMarkObj.Simpplr_Content__r.id);
		}
		return favouriteContentIdSet;
	}
	
	public static String generateStringForSOSLQuery(Set<String> setOfSearchTokens){
        List<String> listOfFinalSearchTokens = new List<String>();
        for(String s : setOfSearchTokens){
        	s = escapeSOSLTerm(s);
        	if(s.containsIgnoreCase(' ')){
        		s = '"'+s+'"';
        	} else {
        		s += '*';
        	}
        	listOfFinalSearchTokens.add(s);
        }
        return String.join(listOfFinalSearchTokens,' OR ');
    }
    
    public static String escapeSOSLTerm(String term){
        Pattern reservedPattern = pattern.compile('[\\?&\\|!{}\\[\\]\\(\\)\\^~\\*:\\\"\\+-]');
        Matcher myMatcher = reservedPattern.matcher(term);
        List<Integer> escapeIndexs = new List<Integer>();
        while(true){
            if(myMatcher.find()){
                escapeIndexs.add(myMatcher.start());
            }else{
                break;
            }
        }
        escapeIndexs.sort();
        for(Integer i = escapeIndexs.size()-1; i>=0; i--){
            Integer escapeIndex = escapeIndexs[i];
            term = term.substring(0, escapeIndex) + '\\' + term.substring(escapeIndex);
        }
        return term; 
    }
    
    public static void setChatterEmailSettingsForUsers(Boolean disableChatterEmails, List<String> listOfUserId) {
    	if(null != listOfUserId && listOfUserId.size()>0){
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', listOfUserId);
	    	String query = 'Select id from user where id in :soqlParam1 And isactive = true ';
	    	
	    	if(disableChatterEmails){
	    		query += 'And UserPreferencesDisableAllFeedsEmail = false';
	    	}else{
	    		query += 'And UserPreferencesDisableAllFeedsEmail = true';
	    	}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    	List<User> listOfUsers = (List<User>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
	    	
	    	if(!listOfUsers.isEmpty()){
		    	for(User userObj : listOfUsers){
		    		userObj.UserPreferencesDisableAllFeedsEmail = disableChatterEmails;
		    	}
		    	try {
			    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, User>(listOfUsers),new List<Schema.SObjectField>{User.UserPreferencesDisableAllFeedsEmail});
		    	} catch (Exception ex) {
		    		sendExceptionEmail('Utility.setChatterEmailSettingsForUsers()', ex);
		    	}
	    	}	
    	}
    }
    
    public static DateTime convertStringTodateTime(String dateTimeString){
    	//2016-03-28T16:09:23+05:30
    	String year = dateTimeString.substring(0,4);
		String month = dateTimeString.substring(5,7);
		String day = dateTimeString.substring(8,10);
		String hour = dateTimeString.substring(11,13);
		String minute = dateTimeString.substring(14,16);
		String second = dateTimeString.substring(17,19);
        
        
        DateTime returnDate = DateTime.newInstanceGMT(Integer.valueOf(year), 
        										   Integer.valueOf(month), 
        										   Integer.valueOf(day), 
        										   Integer.valueOf(hour), 
        										   Integer.valueOf(minute),
        										   Integer.valueOf(second));

        return returnDate;
    }

    public static void createSimpplrSiteShareRecords(List<Simpplr_Site__c> listOfSites, Boolean shareWithSiteGroup) {
        List<String> listOfGroupNames = new List<String>();
        for(Simpplr_Site__c siteObj:listOfSites) {
            if(String.isNotBlank(siteObj.Id)) {
                listOfGroupNames.add('Simpplr_' + siteObj.chatter_group_id__c + '%');
            }
        }
        
        List<Group> listOfGroups = [select id,developername  from Group where developername like: listOfGroupNames];
        Map<String, String> mapOfGroupNameAndGroupId = new Map<String, String>(); 
        for(Group groupObj:listOfGroups) {
            mapOfGroupNameAndGroupId.put(groupObj.developername, groupObj.id);
        }
        
        List<Simpplr_Site__Share> listOfSiteShare = new List<Simpplr_Site__Share>(); 
        String allInternalUserGroupId = getUserGroupId('AllInternalUsers');
        String simpplrAppManagerGroupId = getUserGroupId('Simpplr_App_Managers');
        String simpplrUnlistedSiteManagerGroupId = getUserGroupId('Simpplr_Unlisted_Site_Managers');
        Simpplr_Site__Share shareObj;
        for(Simpplr_Site__c siteObj:listOfSites) {
            if(shareWithSiteGroup && String.isNotBlank(siteObj.Id)) {
                String key = 'Simpplr_' + siteObj.chatter_group_Id__c + '_Standard';
                if(mapOfGroupNameAndGroupId.containsKey(key)) {
                    shareObj = new Simpplr_Site__Share();
                    shareObj.ParentID = siteObj.id;
                    shareObj.AccessLevel='Edit';
                    shareObj.RowCause = Schema.Simpplr_Site__Share.RowCause.Manual;
                    shareObj.UserOrGroupId = mapOfGroupNameAndGroupId.get(key);
                    listOfSiteShare.add(shareObj);
                }
            }
            if('Public'.equalsIgnoreCase(siteObj.Site_Type__c) || 'Private'.equalsIgnoreCase(siteObj.Site_Type__c)) {
                if(String.isNotBlank(allInternalUserGroupId)) {
                    shareObj = new Simpplr_Site__Share();
                    shareObj.ParentID = siteObj.id;
                    shareObj.AccessLevel='Read';
                    shareObj.RowCause = Schema.Simpplr_Site__Share.RowCause.Manual;
                    shareObj.UserOrGroupId = allInternalUserGroupId;
                    listOfSiteShare.add(shareObj);
                }
                if('Public'.equalsIgnoreCase(siteObj.Site_Type__c) && String.isNotBlank(simpplrAppManagerGroupId)) {
                    shareObj = new Simpplr_Site__Share();
                    shareObj.ParentID = siteObj.id;
                    shareObj.AccessLevel='Edit';
                    shareObj.RowCause = Schema.Simpplr_Site__Share.RowCause.Manual;
                    shareObj.UserOrGroupId = simpplrAppManagerGroupId;
                    listOfSiteShare.add(shareObj);
                }
            } else if('Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c) && String.isNotBlank(simpplrUnlistedSiteManagerGroupId)){
                shareObj = new Simpplr_Site__Share();
                shareObj.ParentID = siteObj.id;
                shareObj.AccessLevel='Edit';
                shareObj.RowCause = Schema.Simpplr_Site__Share.RowCause.Manual;
                shareObj.UserOrGroupId = simpplrUnlistedSiteManagerGroupId;
                listOfSiteShare.add(shareObj);
            }
        }
        if(listOfSiteShare.size() > 0) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(listOfSiteShare,
                new List<Schema.SObjectField>{
                    Simpplr_Site__Share.ParentID,
                    Simpplr_Site__Share.AccessLevel,
                    Simpplr_Site__Share.RowCause,
                    Simpplr_Site__Share.UserOrGroupId
                });
        }
    }
    
    public static void createSimpplrContentShareRecords(List<Simpplr_Content__c> listOfContents) {
    	List<String> listOfGroupNames = new List<String>();
    	for(Simpplr_Content__c contentObj:listOfContents) {
    		if(String.isNotBlank(contentObj.Site__c)) {
    			listOfGroupNames.add('Simpplr_' + contentObj.Site__r.chatter_group_id__c + '%');
    		}
    	}
    	
    	List<Group> listOfGroups = [select id,developername  from Group where developername like: listOfGroupNames];
    	Map<String, String> mapOfGroupNameAndGroupId = new Map<String, String>(); 
    	for(Group groupObj:listOfGroups) {
    		mapOfGroupNameAndGroupId.put(groupObj.developername, groupObj.id);
    	}
    	
    	List<Simpplr_Content__Share> listOfContentShare = new List<Simpplr_Content__Share>(); 
    	String allInternalUserGroupId = getUserGroupId('AllInternalUsers');
    	String simpplrAppManagerGroupId = getUserGroupId('Simpplr_App_Managers');
    	String simpplrUnlistedSiteManagerGroupId = getUserGroupId('Simpplr_Unlisted_Site_Managers');
    	Simpplr_Content__Share shareObj;
    	for(Simpplr_Content__c contentObj:listOfContents) {
    		
    		if(String.isNotBlank(contentObj.Site__c)) {
	    		//Read Access
    			String key = 'Simpplr_' + contentObj.Site__r.chatter_group_Id__c + '_Standard';
	    		if(mapOfGroupNameAndGroupId.containsKey(key)) {
		    		shareObj = new Simpplr_Content__Share();
		    		shareObj.ParentID = contentObj.id;
		    		shareObj.AccessLevel='Edit';
		    		shareObj.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
		    		shareObj.UserOrGroupId = mapOfGroupNameAndGroupId.get(key);
		    		listOfContentShare.add(shareObj);
	    		}
	    		
    		}
    		if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.Type__c) || 'Public'.equalsIgnoreCase(contentObj.Site__r.Site_Type__c)) {
    			if(String.isNotBlank(allInternalUserGroupId)) {
	    			shareObj = new Simpplr_Content__Share();
		    		shareObj.ParentID = contentObj.id;
		    		shareObj.AccessLevel='Edit';
		    		shareObj.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
		    		shareObj.UserOrGroupId = allInternalUserGroupId;
		    		listOfContentShare.add(shareObj);
    			}
	    		
	    		if(String.isNotBlank(simpplrAppManagerGroupId)) {
		    		shareObj = new Simpplr_Content__Share();
		    		shareObj.ParentID = contentObj.id;
		    		shareObj.AccessLevel='Edit';
		    		shareObj.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
		    		shareObj.UserOrGroupId = simpplrAppManagerGroupId;
		    		listOfContentShare.add(shareObj);
	    		}
    		}else if('Unlisted'.equalsIgnoreCase(contentObj.Site__r.Site_Type__c) && 
    						String.isNotBlank(simpplrUnlistedSiteManagerGroupId)){
		    		shareObj = new Simpplr_Content__Share();
		    		shareObj.ParentID = contentObj.id;
		    		shareObj.AccessLevel='Edit';
		    		shareObj.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
		    		shareObj.UserOrGroupId = simpplrUnlistedSiteManagerGroupId;
		    		listOfContentShare.add(shareObj);
    		}
    	}
    	if(listOfContentShare.size() > 0) {
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().insertAsUser(listOfContentShare, new List<Schema.SObjectField>{Simpplr_Content__Share.ParentID,
	    																								Simpplr_Content__Share.AccessLevel,
	    																								Simpplr_Content__Share.RowCause,
	    																								Simpplr_Content__Share.UserOrGroupId});
    	}
    }
    
    public static void toggleContentPermissions(List<Simpplr_Content__c> listOfSimpplrContents, Boolean makePrivateBool) {
    	String allInternalUserGroupId = getUserGroupId('AllInternalUsers');
    	String simpplrAppManagerGroupId = getUserGroupId('Simpplr_App_Managers');
    	List<String> listOfUserGroupIds = new List<String>();
    	if(String.isNotBlank(allInternalUserGroupId)) {
    		listOfUserGroupIds.add(allInternalUserGroupId);
    	} 
    	if(String.isNotBlank(simpplrAppManagerGroupId)) {
    		listOfUserGroupIds.add(simpplrAppManagerGroupId);
    	}
    	if(listOfUserGroupIds.size() > 0) {
	    	if(makePrivateBool) {
	    		List<Simpplr_Content__Share> listOfShareRecords = [select id from Simpplr_Content__Share where ParentID=:listOfSimpplrContents
	    														   And UserOrGroupId=:listOfUserGroupIds];
	    		if(listOfShareRecords.size() > 0) {
	    			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    			SIMPESAPI.accessController().deleteAsUser(listOfShareRecords);
	    		}
	    	} else {
	    		Simpplr_Content__Share shareObj;
	    		List<Simpplr_Content__Share> listOfContentShare = new List<Simpplr_Content__Share>();
	    		for(Simpplr_Content__c contentObj:listOfSimpplrContents) {
	    			if(String.isNotBlank(allInternalUserGroupId)) {
		    			shareObj = new Simpplr_Content__Share();
			    		shareObj.ParentID = contentObj.id;
			    		shareObj.AccessLevel='Edit';
			    		shareObj.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
			    		shareObj.UserOrGroupId = allInternalUserGroupId;
			    		listOfContentShare.add(shareObj);
	    			}
		    		
		    		if(String.isNotBlank(simpplrAppManagerGroupId)) {
			    		shareObj = new Simpplr_Content__Share();
			    		shareObj.ParentID = contentObj.id;
			    		shareObj.AccessLevel='Edit';
			    		shareObj.RowCause = Schema.Simpplr_Content__Share.RowCause.Manual;
			    		shareObj.UserOrGroupId = simpplrAppManagerGroupId;
			    		listOfContentShare.add(shareObj);
		    		}
	    		}
	    		if(listOfContentShare.size() > 0) {
	    			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		    		SIMPESAPI.accessController().insertAsUser(listOfContentShare, new List<Schema.SObjectField>{Simpplr_Content__Share.ParentID,
    																								Simpplr_Content__Share.AccessLevel,
    																								Simpplr_Content__Share.RowCause,
    																								Simpplr_Content__Share.UserOrGroupId});
	    		}
	    	}
    	}
    }
    
    public static String getUserGroupId(String developerName) {
    	String groupId;
    	List<Group> listOfGroups = [select id from Group where developerName=:developerName];
    	if(!listOfGroups.isEmpty()) {
    		groupId = listOfGroups[0].id;
    	}
    	return groupId;
    }    
    
    public static Boolean isMobileMode{
    	 get {
	    if(isMobileMode == null){
	    	isMobileMode = false;
	    	String userAgent = '';
	    	if(String.isNotBlank(SimpplrContext.userAgent)){
	    		userAgent = SimpplrContext.userAgent;
	    	}
	        if(userAgent.containsIgnoreCase('Windows Phone') || userAgent.containsIgnoreCase('iPhone')  || userAgent.containsIgnoreCase('iPad') 
                        || userAgent.containsIgnoreCase('Android') || userAgent.containsIgnoreCase('SymbianOS')||  userAgent.containsIgnoreCase('BlackBerry')){
                 isMobileMode = true;       	
            }
	    }
	    return isMobileMode;
	   }set;
    }
    
    public static Integer getCGMemberCount(String recipientCollGrpId){
       CollaborationGroup cGMember = [select memberCount from CollaborationGroup where id=:recipientCollGrpId limit 1];
       return cGMember.memberCount;
    }
    
    
    public static Boolean checkContentEdited(DateTime publishedFromDateTime, DateTime lastModifiedDateTime) {
    	Boolean isContentEdited = false;
    	if(publishedFromDateTime != null && lastModifiedDateTime != null) {
    		Date publishedFromDate = date.newinstance(publishedFromDateTime.year(), publishedFromDateTime.month(), publishedFromDateTime.day());
        	Date lastModifiedDate = date.newinstance(lastModifiedDateTime.year(), lastModifiedDateTime.month(), lastModifiedDateTime.day());
        	if (lastModifiedDate > publishedFromDate){
        		isContentEdited = true;
        	}	
    	}
        return isContentEdited;
    }
    
    public static String getFileType(String sFType) {
   		String fileType = sFType;
   		if(ServiceConstants.FILE_TYPES_MAP.containsKey(sFType)) {
   			fileType = (String)ServiceConstants.FILE_TYPES_MAP.get(sFType);
   		}
   		return fileType;
   	}
   	
   	 public static Integer getTotalPeopleInSimpplr(){
   	 	String packageName = SimpplrContext.packageName;
   	 	String peopleQuery = 'select id from People__c where User__r.IsActive=true AND User__r.UserType=\'Standard\'';
    	if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false){
			peopleQuery = peopleQuery + ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName)';
		}
    	List<People__c> peopleInSimpplr = Database.query(peopleQuery);
    	return peopleInSimpplr.size();
    }
    
    public static Date getFirstDayOfQuarterForDate(Date inputDate) {
    		//Find quarter of year, Jan-Mar=1, Apr-Jun=2, Jul-Sep=3, Oct-Dec=4
    		Map<Integer, Integer> qurterMap = new Map<Integer, Integer> {
    				 1 => 1,   2 => 1,   3 => 1,
    				 4 => 4,   5 => 4,   6 => 4,
				 7 => 7,   8 => 7,   9 => 7,
				10 => 10, 11 => 10, 12 => 10    				
    		};
		return Date.newInstance(inputDate.year(), qurterMap.get(inputDate.month()), 1);
    }
    

    public static String getPackageVersion() {
		String packageVersion = '';
		Version versionObj = System.requestVersion();
		if(versionObj != null) {
			packageVersion = String.valueOf(versionObj.major()) + '.' + String.valueOf(versionObj.minor()) + '.' + ServiceConstants.PATCH_VERSION;
		}
		return packageVersion; 
    }
	
	public static CollaborationGroup getColGroupFromSiteId(String collaborationGrpId, String loggedInUserId){
    	
		String userId = UserContext.id;
		String BASE_QUERY = 'SELECT Id, SmallPhotoUrl, MediumPhotoUrl, FullPhotoUrl, CollaborationType,description,InformationBody, InformationTitle, MemberCount,OwnerId,IsBroadcast, '+
		' (SELECT status FROM GroupMemberRequests WHERE status =\'Pending\' AND RequesterId =:loggedInUserId) FROM CollaborationGroup where IsArchived=false and Id =:collaborationGrpId';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}
		List<CollaborationGroup> collabGrpList = Database.query(BASE_QUERY);
		
		return collabGrpList[0];
    }
    
    public static List<CollaborationGroupMember> getColGroupMembers(String collaborationGrpId){
    	
		String BASE_QUERY = 'select Id, MemberId,Member.Name, CollaborationRole FROM CollaborationGroupMember WHERE CollaborationGroupId =:collaborationGrpId ';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}
		BASE_QUERY = BASE_QUERY+' order by CollaborationRole DESC,CreatedDate DESC ';
		List<CollaborationGroupMember> collabGrpMemList = Database.query(BASE_QUERY);
		
		return collabGrpMemList;
    }
    
    public static void insertMobileAnalyticsRecord(String pageName, Map<String,String> requestDataMap){
		try{
			String pageUrl = EncodingUtil.urlDecode(SimpplrContext.requestURI,'UTF-8');
           	String refererURL = +Url.getSalesforceBaseUrl().toExternalForm()+pageUrl;
			String profileId = requestDataMap.get('peopleId');
			String siteId = requestDataMap.get('siteId');
			String contentId = requestDataMap.get('contentId');
			String fileId = requestDataMap.get('fileId');
			String term = requestDataMap.get('term');
			String os = SimpplrContext.headers.get('os') != null ? SimpplrContext.headers.get('os') : '';
			Map<String,String> analyticsReqMap = new Map<String, String>{'pageName'=>pageName,'pageURL'=>pageUrl,'refererURL'=>refererURL,
																		 'profileId'=>profileId,'siteId'=>siteId,'contentId'=>contentId,
																		 'fileId'=>fileId,'term'=>term,'os'=>os,'origin'=>'mobile',
																		 'userAgent'=>requestDataMap.get('userAgent')};
	
			AnalyticsDao  analDaoObj = new AnalyticsDao();
			analDaoObj.pushViewData(analyticsReqMap);
		} catch(Exception e){
			
		}
	}
	
	public static String getUserProfileImgUrl(String mediumPhotoUrl, String fullPhotoUrl){
		
		String photoUrl;
		if(String.isNotBlank(mediumPhotoUrl)){
			photoUrl = mediumPhotoUrl.endsWith('005/M')?null:mediumPhotoUrl;
		} else if(String.isNotBlank(fullPhotoUrl)){
			photoUrl = fullPhotoUrl.endsWith('005/F')?null:fullPhotoUrl;
		}
		return photoUrl;
		
	}
	
	public static Map<String, String> getSelectorArg(String fld, String val) {
		Map<String, String> selArg = new Map<String, String>();
		selArg.put('.tag', fld);
		selArg.put(fld, val);
		
		return selArg;
	}
	
	// method to get encryped auth token for Dropbox
	public static string droboxFileMgmtAuthToken() {
		String orgId = UserInfo.getOrganizationId();
		String userId = UserInfo.getUserId();
		String dropBoxAccessToken = UserContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Access_Token__c;	 
		if(orgId.length() == 18) {
		    orgId = orgId.substring(0, 15);
		} 
		if(userId.length() == 18) {
		    userId = userId.substring(0, 15);
		} 
		String seedValue = String.valueOf(datetime.now().getTime()) + '#$#$#$' + orgId + '#$#$#$' + userId  + '#$#$#$' + dropBoxAccessToken ;         
		String initVectorString = (orgID + 'SIMPPLR').substring(0,16);
		Blob initVector = Blob.valueOf(initVectorString);
		Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
		Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
		Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
		String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0,40);
		String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0,32);
		Blob dataToEncrypt = Blob.valueOf(seedValue);
		Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
		String keyVal = EncodingUtil.base64Encode(encryptedData);
		String paddingLeft = '';
		if(keyVal.endsWith('=') == false) {
			paddingLeft = 'C';
		}
		if(keyVal.endsWith('==')) {
			paddingLeft = 'A';
			keyVal = keyVal.removeEnd('==');
		}
		if(keyVal.endsWith('=')) {
			paddingLeft = 'B';
			keyVal = keyVal.removeEnd('=');
		} 
		
		String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
		if(cryptoKeyString.endsWith('=') == false) {
			paddingLeft = paddingLeft + 'c';
		}
		if(cryptoKeyString.endsWith('==')) {
			paddingLeft = paddingLeft + 'a';
			cryptoKeyString = cryptoKeyString.removeEnd('==');
		}
		if(cryptoKeyString.endsWith('=')) {
			paddingLeft = paddingLeft + 'b';
			cryptoKeyString = cryptoKeyString.removeEnd('=');
		} 
		
		paddingLeft = paddingLeft + saltStringPrefix.substring(0,32) 
			    + saltStringPrefix.substring(0,16) 
				+ cryptoKeyString
				+ saltStringPrefix.substring(16,32);
		String token = paddingLeft + keyVal + saltStringSuffix + simpleObfuscateString(orgId) + simpleObfuscateString(userId);
		return token;
	}

	Public static String replace(String inputString, String target, String replacement) {
		return inputString.replace(target, String.isBlank(replacement) ? '' : replacement);
	}

	public static String getSimpDri() {
		return externalRequestAuthToken() + ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) + ' ' + UserContext.userId.substring(0, 15);
	}
	
	public static String externalRequestAuthToken () {
        String orgId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
                 
        if (orgId.length() == 18) {
            orgId = orgId.substring(0, 15);
        } 
        
        if (userId.length() == 18) {
            userId = userId.substring(0, 15);
        } 
        
        String seedValue = String.valueOf(datetime.now().getTime()) + '#$#$#$' + orgId + '#$#$#$' + userId ;         
        String initVectorString = (orgID + 'SIMPPLR').substring(0,16);
        Blob initVector = Blob.valueOf(initVectorString);
        Blob cryptoKey = Crypto.generateDigest('SHA-256', Blob.valueOf(orgID));        
        Blob saltDataPrefix = Crypto.generateDigest('SHA-512', Blob.valueOf(seedValue));
        Blob saltDataSuffix = Crypto.generateDigest('SHA-512', saltDataPrefix);
        String saltStringPrefix = EncodingUtil.base64Encode(saltDataPrefix).substring(0,40);
        String saltStringSuffix = EncodingUtil.base64Encode(saltDataSuffix).substring(0,32);
        Blob dataToEncrypt = Blob.valueOf(seedValue);
        Blob encryptedData = Crypto.encrypt('AES256', cryptoKey, initVector, dataToEncrypt);
        String keyVal = EncodingUtil.base64Encode(encryptedData);
        String paddingLeft = '';
        
        if (keyVal.endsWith('=') == false) {
            paddingLeft = 'C';
        }
        
        if (keyVal.endsWith('==')) {
            paddingLeft = 'A';
            keyVal = keyVal.removeEnd('==');
        }
        
        if (keyVal.endsWith('=')) {
            paddingLeft = 'B';
            keyVal = keyVal.removeEnd('=');
        } 
        
        String cryptoKeyString = EncodingUtil.base64Encode(cryptoKey);
        
        if (cryptoKeyString.endsWith('=') == false) {
            paddingLeft = paddingLeft + 'c';
        }
        
        if (cryptoKeyString.endsWith('==')) {
            paddingLeft = paddingLeft + 'a';
            cryptoKeyString = cryptoKeyString.removeEnd('==');
        }
        
        if (cryptoKeyString.endsWith('=')) {
            paddingLeft = paddingLeft + 'b';
            cryptoKeyString = cryptoKeyString.removeEnd('=');
        } 
        
        paddingLeft = paddingLeft + saltStringPrefix.substring(0,32) 
                + saltStringPrefix.substring(0,16) 
                + cryptoKeyString
                + saltStringPrefix.substring(16,32);
        String token = paddingLeft + keyVal + saltStringSuffix + simpleObfuscateString(orgId) + simpleObfuscateString(userId);
        return token;
    }

	// Function to identify the image file extensions
	public static Boolean isImage(String extString) {
		Set<String>fileType = new Set<String>{'jpg', 'jpeg', 'gif', 'tiff', 'png'};
		
		if (String.isNotBlank(extString) && fileType.contains(extString.toLowerCase())){
			return true;
		}
		
		return false;
	}	
	
	//method to encode url string splitted by '/'
	public static string encodeUrlString (String urlArg) {
		List<String> splitedUrlList = urlArg.split('/');
		String encodedUrlStr = ''; 
		
		for (String str : splitedUrlList) {
			if (String.isNotBlank(str)) {
				encodedUrlStr = encodedUrlStr + '/'+ EncodingUtil.urlEncode(str,'UTF-8');
			}
		}
		
		return encodedUrlStr.replaceAll('\\+','%20');
   	}
   	
   	// Method to Camel Case the input String
	public static String toCamelCase(String inStr) {
	    String outStr = '';
	    for(String word:inStr.split(' ')) {
	        outStr += (outStr == ''?'':' ') + word.subString(0, 1).toUpperCase() + (word.length()>1?word.SubString(1):'');
	    }
	    return outStr;
	}

   	// Function to reset smart search in Sandbox when Smart Search is already enabled in Production before creating sandbox
   	public static void resetSmartSearch() {
   		String appConfigQuery = 'Select Id, External_Search_Enabled__c, External_search_app_connected__c,'
   											+ ' Flow_External_Search_Enabled__c, AWS_Access_Token__c, External_Search_Connected_By_People__c'
   											+ ' From App_Config__c limit 1'; 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
   		appConfigList[0].External_Search_Enabled__c = false;
   		appConfigList[0].External_search_app_connected__c = false;
   		appConfigList[0].Flow_External_Search_Enabled__c = false;
   		appConfigList[0].AWS_Access_Token__c = null;
   		appConfigList[0].External_Search_Connected_By_People__c = null;

		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField> {
			App_Config__c.External_Search_Enabled__c,
			App_Config__c.External_search_app_connected__c,
			App_Config__c.Flow_External_Search_Enabled__c,
			App_Config__c.AWS_Access_Token__c,
			App_Config__c.External_Search_Connected_By_People__c
		};
   		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Config__c>(appConfigList), fieldList);
   	}
   	
   	public static Boolean isSmartSearchTokenValid(){
   		Boolean isSmartSearchTokenValid = false;
   		
   		if(String.isNotBlank(SimpplrContext.getAWSAccessToken) && UserInfo.getOrganizationId().equalsIgnoreCase(SimpplrContext.getAWSAccessToken.subString(0,SimpplrContext.getAWSAccessToken.indexOf(':')))) {
   			isSmartSearchTokenValid = true;
   		}
   		return isSmartSearchTokenValid;
   	}
   	
   	public static Date adoptionEmailNextRunDate(){
 
		Date nextMonthStartDate = Date.today().toStartOfMonth().addMonths(1);
		String nextMonthStartDay = DateTime.newInstance(nextMonthStartDate.year(), nextMonthStartDate.month(), nextMonthStartDate.day()).format('EEEE');
		if(nextMonthStartDay =='Monday'){
			nextMonthStartDate = nextMonthStartDate.addDays(1);		
		
		} else if(nextMonthStartDay=='Tuesday'){
			
		} else if(nextMonthStartDay=='Wednesday'){
			nextMonthStartDate = nextMonthStartDate.addDays(6);	
		
		} else if(nextMonthStartDay=='Thursday'){
			nextMonthStartDate = nextMonthStartDate.addDays(5);	
		
		} else if(nextMonthStartDay=='Friday'){
			nextMonthStartDate = nextMonthStartDate.addDays(4);
		
		} else if(nextMonthStartDay=='Saturday'){
			nextMonthStartDate = nextMonthStartDate.addDays(3);
		
		} else if(nextMonthStartDay=='Sunday'){
			nextMonthStartDate = nextMonthStartDate.addDays(2);
		}
		
		return nextMonthStartDate;
   	}

    
    public static List<String> getLabelWithUserFieldAPIMap(List<String> userFieldToShow){
    	List<String> fieldAPIList = new List<String>();
    	if(String.isNotBlank(SimpplrContext.PPUserCustomFields)) {
			List<CustomProfileField> userFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);
			Map<String, Schema.SObjectField> userFieldAPIMap = Schema.SObjectType.User.fields.getMap(); 
			Map<String,String> userFieldAPINamesWithLabelMap = new Map<String,String>();
			
			for(Schema.SObjectField userField : userFieldAPIMap.values()){
					
				Schema.DescribeFieldResult userFieldDescribe = userField.getDescribe();

				if(Schema.DisplayType.MultiPicklist != userFieldDescribe.getType()){
					userFieldAPINamesWithLabelMap.put(userFieldDescribe.getName(),userFieldDescribe.getLabel());
				}
			}
			for(CustomProfileField userField: userFieldList) {
				if((userField.isHtml != true) && userFieldAPINamesWithLabelMap.containsKey(userField.fieldName)){
					userFieldToShow.add(userFieldAPINamesWithLabelMap.get(userField.fieldName));
					fieldAPIList.add(userField.fieldName);
				}
			}
    	}
    	return fieldAPIList;
    }

	public static String getParamValueFromUrl (String inputUrl, String paramKey) {
		String paramValue = '';
		// Params are not blank
		if (String.isNotBlank(inputUrl) && String.isNotBlank(paramKey) && inputUrl!='null') {
			Url url = new Url(inputUrl);
			PageReference vfPage = new PageReference('/apex/simpplr?' + url.getQuery()); 
			paramValue = vfPage.getParameters().get(paramKey);
		}
		return paramValue;
	}

	public static String getLabelForSegmentFieldApi(String fieldApiName){
		String label = PEOPLE_COLUMN_API_NAME_LABEL_MAP.get(fieldApiName);

		if(String.isBlank(label) && PEOPLE_CUSTOM_FIELDS_NAME_LIST.contains(fieldApiName)){
			String customFieldsStr = SimpplrContext.PPUserCustomFields;
			
			if(String.isNotBlank(customFieldsStr)){
				List<CustomProfileField> customFieldList = (List<CustomProfileField>)Json.deserialize(customFieldsStr, List<CustomProfileField>.class);
				
				Map<String, String> customFieldMap = new Map<String, String>();
				for(CustomProfileField customField : customFieldList){
					if(fieldApiName.equalsIgnoreCase(customField.columnName)){
						label = customField.singular;

						break;
					}
				}
			}
		}

		return label;
	}

	public static Map<String, String> getLabelVsPeopleFieldMap(){
		Map<String, String> fieldMap = AUDIENCE_STR_OBJ_FIELD_MAP;
		if(SimpplrContext.isPeopleCategoryEnable) {
			fieldMap.put('category', 'People_Category__c');
		}

		fieldMap.putAll(getPeopleCustomFieldsMap('labelVsApiName'));

		return fieldMap;
	}

	public static Map<String, String> getPeopleFieldVsLabelMap(){
		Map<String, String> fieldMap = PEOPLE_COLUMN_API_NAME_LABEL_MAP;
		fieldMap.putAll(getPeopleCustomFieldsMap('apiNameVsLabel'));

		return fieldMap;
	}

	public static Map<String, String> getPeopleCustomFieldsMap(String type){
		Map<String, String> mapObj = new Map<String, String>();

		String customFieldsStr = SimpplrContext.PPUserCustomFields;
		if(String.isNotBlank(customFieldsStr)){
			List<CustomProfileField> customFieldList = (List<CustomProfileField>)Json.deserialize(customFieldsStr, List<CustomProfileField>.class);
			
			Map<String, String> customFieldMap = new Map<String, String>();
			for(CustomProfileField customField : customFieldList){
				if(String.isNotBlank(customField.syncSource)){
					if('labelVsApiName'.equalsIgnoreCase(type)){
						mapObj.put(customField.columnName, customField.columnName);

					} else if('apiNameVsLabel'.equalsIgnoreCase(type)) {
						mapObj.put(customField.columnName, customField.fieldName);

					} else if('apiNameVsUiLabel'.equalsIgnoreCase(type)){
						mapObj.put(customField.columnName, customField.singular);

					}
					
				}
			}
		}

		return mapObj;
	}

	public static String encryptString(String param) {
		String encrypttedStr;
		if(String.isNotBlank(param)) {
			Blob vector = Blob.valueOf(ServiceConstants.ANALYTICS_VECTOR);
			Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
			Blob blobPassword = Blob.valueOf(param);
			encrypttedStr = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobPassword));
		}
		
		return encrypttedStr;
	}

	public static String decryptString(String encryptedStr) {
		String decryptedStr;
		if(String.isNotBlank(encryptedStr)) {
			try {
				Blob vector = Blob.valueOf(ServiceConstants.ANALYTICS_VECTOR);
				Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
				Blob cipherText = EncodingUtil.base64Decode(encryptedStr);
				decryptedStr = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

			} catch(Exception ex) {
				//Input may not be encrypted for older data, return input value
				decryptedStr = encryptedStr;
			}
		}
		
		return decryptedStr;
	}

	public static Boolean isLaunchpadConfigured() {
		Boolean isLaunchpadConfigured = UserContext.isLaunchpadConfigured;
		String jsonCustomLinksString;
		Boolean useSegmentAppsNLinks = SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled;
		if(!useSegmentAppsNLinks){
			jsonCustomLinksString = SimpplrContext.appConfig != null ? SimpplrContext.appConfig.Custom_Links_JSON__c : null;
		} else if(UserContext.getCurrentUserInfo != null && String.isNotBlank(UserContext.segmentId)){
			jsonCustomLinksString = UserContext.getCurrentUserInfo.Segment__r.Custom_Links_JSON__c;
		}
		if(!isLaunchpadConfigured && String.isNotBlank(jsonCustomLinksString)){
			List<LaunchpadWrapper.LinkWrapper> customlinksList = (List<LaunchpadWrapper.LinkWrapper>)Json.deserialize(jsonCustomLinksString, List<LaunchpadWrapper.LinkWrapper>.class);
			for (LaunchpadWrapper.LinkWrapper customlinkObj : customlinksList){
				if(customlinkObj.onOff){
					isLaunchpadConfigured = true;
					break;
				}
			}
		}
		return isLaunchpadConfigured;
	}

	public static DateTime getDateTimeFilterValue(String filter) {
		DateTime dateTimeFilterValue;
		if (String.isNotBlank(filter) && !'anytime'.equalsIgnoreCase(filter)) {

			if (filter.equalsIgnoreCase('past_24_hours')) {
				dateTimeFilterValue = System.now().addHours(-24);					

			} else if (filter.equalsIgnoreCase('past_week')) {
				dateTimeFilterValue = System.now().addDays(-7);

			} else if (filter.equalsIgnoreCase('past_month')) {
				dateTimeFilterValue = System.now().addMonths(-1);	

			} else if (filter.equalsIgnoreCase('past_year')) {
				dateTimeFilterValue = System.now().addYears(-1);

			}
		}
		return dateTimeFilterValue;
	}
	/**
	* @description method to get response from AWS without custom headers
	* @return HttpResponse - respnse from AWS
	* @param endpoint - URL to be hit
	* @param body - Object of request body
	*/
	public static HttpResponse getResponseFromAWS(String endpoint, Object body) {
		return getResponseFromAWS(endpoint, body, new Map<String, String>());
	}
	
	/**
	 * @description method to get response from AWS with custom headers
	 * @return HttpResponse - respnse from AWS
	 * @param endpoint - URL to be hit
	 * @param body - Object of request body
	 * @param customHeaders - Map of custom header if required
	 */
	public static HttpResponse getResponseFromAWS(String endpoint, Object body, Map<String, String> customHeaders) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('simpplr-dri', getSimpDri());
		for(String key: customHeaders.keySet()){
			req.setHeader(key, customHeaders.get(key));
		}
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setBody(Json.serialize(body));
        Http http = new Http();
        HttpResponse response = http.send(req);

		logger.logDebug('Utility.getResponseFromAWS()----endpoint----' + endpoint);
		logger.logDebug('Utility.getResponseFromAWS()----request body----' + body);
        logger.logDebug('Utility.getResponseFromAWS()----response body----' + response.getBody());
        if (response.getStatusCode() != 200) {
            logger.logDebug('Utility.getResponseFromAWS()----response status code ----' + response.getStatusCode());
            if (response.getStatusCode()== 404 ){
                throw new SimpplrException(ServiceConstants.ERROR_404);
            } else {
                throw new SimpplrException(ExceptionCode.UNEXPECTED_ERROR.name());
            }
        }
        return response;
    }


	public static String getDisplayExcerpt(String excerpt, String summary1){
		if(String.isNotBlank(summary1)){
			return summary1;
		} else if(String.isNotBlank(excerpt)){
			return excerpt;
		} else {
			return '';
		}
	}

	public static Map<String, Object> sendMobilePromotionLinkSms (String mobileNumber, MobileAppDistributionWrapper distributionWrapperObj) {
		Map<String, Object> requestDataMap = new Map<String, Object>();
		if(SimpplrContext.brandedAppDistributionEnabled || SimpplrContext.mobilePromotionEnabled) {
			String MOBILE_PROMOTION_SMS_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/campaign/mobile-app-download/sendsms?utm_campaign=mobile_promotion&utm_source=sms';    
			ResponseWrapper response;
			Http httpObj = new Http();
			String driStr = Utility.requestAdoptionDataAuthToken();
			Map<String, Object> reqBody = new Map<String, Object>();
			reqBody.put('dri', driStr);
			reqBody.put('to', mobileNumber);
			reqBody.put('languageLocaleKey', UserContext.languageLocaleKey);
			reqBody.put('appName', SimpplrContext.applicationName);
			reqBody.put('people_id', UserContext.peopleId);
			reqBody.put('app_type', (SimpplrContext.brandedAppDistributionEnabled ? 'branded' : 'native'));
			reqBody.put('org_id', SimpplrContext.simpplrOrgId);
			if(distributionWrapperObj != null) {
				reqBody.put('ios_link', distributionWrapperObj.iosLink);
				reqBody.put('ios_code', distributionWrapperObj.iosCode);
				reqBody.put('android_link', distributionWrapperObj.androidLink);
			}
			HttpRequest req = new HttpRequest();
			req.setEndpoint(MOBILE_PROMOTION_SMS_ENDPOINT); 
			req.setBody(JSON.serialize(reqBody));
			req.setMethod('POST');
			HttpResponse res = httpObj.send(req);
			String smsResponse= res.getBody();
			requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(smsResponse);
		}
		return requestDataMap;
	}

	public static String encryptFn(String value){
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		Blob blobValue = Blob.valueOf(value);
		String encryptedValue = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobValue));
		return encryptedValue;
	}

	public static String decryptFn(String value){
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		Blob cipherText = EncodingUtil.base64Decode(value);
		String decryptedValue = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();
		return decryptedValue;
	}

    /**
     * @description getGroupMembershipToCreate
     * @param listOfCollaborationGroupMembers
     * @return List<GroupMember>
     */
    public static List<GroupMember> getGroupMembershipToCreate(List<CollaborationGroupMember> listOfCollaborationGroupMembers) {
        Set<String> setOfGroupMemberIds = new Set<String>();
        List<String> listOfGroupNames = new List<String>();
        for(CollaborationGroupMember cgm : listOfCollaborationGroupMembers) {
            setOfGroupMemberIds.add(cgm.MemberId);
            String groupName = 'Simpplr_' + cgm.CollaborationGroupId + '_' + cgm.CollaborationRole;
            listOfGroupNames.add(groupName);
        }
        Map<Id, User> mapOfStandardActiveUsers = new Map<Id, User>([
            select id from user where id = :setOfGroupMemberIds And UserType='Standard' and isActive = true
        ]);
        
        List<Group> listOfGroups = [select id, DeveloperName from Group where DeveloperName = :listOfGroupNames];
        Map<String, String> mapOfGroupNameAndGroupId = new Map<String, String>();
        for(Group grpObj : listOfGroups) {
            mapOfGroupNameAndGroupId.put(grpObj.DeveloperName, grpObj.id);
        }
        List<GroupMember> listOfGroupMember = new List<GroupMember>();
        for(CollaborationGroupMember cgm : listOfCollaborationGroupMembers) {
            String groupName = 'Simpplr_' + cgm.CollaborationGroupId + '_' + cgm.CollaborationRole;
            if(mapOfGroupNameAndGroupId.containsKey(groupName) && mapOfStandardActiveUsers.containsKey(cgm.memberId)) {
                listOfGroupMember.add(new GroupMember(groupId=mapOfGroupNameAndGroupId.get(groupName), UserOrGroupId=cgm.memberId));
            }
        }
        return listOfGroupMember;
    }

	public static Map<String, Object> getJwtTokenRequestBody() {

		Map<String, String> claims = new Map<String, String>();
		claims.put('canAccessAnalytics', String.valueOf(UserContext.canAccessAnalytics));
		claims.put('canAccessLeadercast', String.valueOf(UserContext.canAccessLeadercast));
		claims.put('canCreateTopics', String.valueOf(UserContext.canCreateTopics));
		claims.put('canManageInternalUsers', String.valueOf(UserContext.canManageInternalUsers));
		claims.put('canManageRecognition', String.valueOf(UserContext.canManageRecognition));
		claims.put('canManageSentimentCheck', String.valueOf(UserContext.canManageSentimentCheck));
		claims.put('canManageSurveys', String.valueOf(UserContext.canManageSurveys));
		claims.put('canSendAlerts', String.valueOf(UserContext.canSendAlerts));
		claims.put('canSendNewsletter',String.valueOf(UserContext.canSendNewsletter));
		claims.put('hasManageCampaignAccess',String.valueOf(UserContext.hasManageCampaignAccess));
		claims.put('hasManageSegmentAccess',String.valueOf(UserContext.hasManageSegmentAccess));
		claims.put('hasManageUnlistedSitePermission',String.valueOf(UserContext.hasManageUnlistedSitePermission));
		claims.put('hasModifyAllDataPermission',String.valueOf(UserContext.hasModifyAllDataPermission));
		claims.put('id',UserContext.id);
		claims.put('isInitiativesAndCampaignsManager',String.valueOf(UserContext.isInitiativesAndCampaignsManager));
		claims.put('isSegmentManager',String.valueOf(UserContext.isSegmentManager));
		claims.put('isUserAppModerator',String.valueOf(UserContext.isUserAppModerator));
		claims.put('isUserSiteOnboardingManager',String.valueOf(UserContext.isUserSiteOnboardingManager));
		claims.put('languageLocaleKey',UserContext.languageLocaleKey);
		claims.put('segmentId',UserContext.segmentId);
		claims.put('timeZoneSIDKey',UserContext.timeZoneSIDKey);
		claims.put('timezoneName',UserContext.timeZoneLabel);
		claims.put('timezoneOffset',String.valueOf(UserContext.timezoneOffset));
		claims.put('userId',UserContext.userId );
		claims.put('orgUuid', SimpplrContext.uuid);
		claims.put('typ', 'Access');
		claims.put('peopleUuid', UserContext.uuid);
		claims.put('instanceName', SimpplrContext.instance);
		claims.put('location', UserContext.country);
		claims.put('locationId', UserContext.city + ' @@ ' + UserContext.state + ' @@ ' + UserContext.country );
		claims.put('department', UserContext.getUsersDepartmentDetail);
		claims.put('departmentId', String.isNotBlank(UserContext.getUsersDepartmentDetail) ? UserContext.getUsersDepartmentDetail.toLowerCase() : null);
	
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('firstname', UserContext.firstname);
		requestBody.put('lastname', UserContext.lastname);
		requestBody.put('iss', 'odin-all');
		requestBody.put('aud', 'odin-all');
		requestBody.put('sub', UserContext.peopleId);
		requestBody.put('claims', claims);
		
		return requestBody;
	}

	public static Map<String, Object> getPeopleOnboardingRequestBody() {
	
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('orgUuid', SimpplrContext.uuid);
		requestBody.put('firstname', UserContext.firstname);
		requestBody.put('lastname', UserContext.lastname);
		requestBody.put('email', UserContext.email);
		requestBody.put('isUserAppModerator', UserContext.isUserAppModerator);
		requestBody.put('username',UserContext.username);
		
		return requestBody;
	}

	public static Map<String, Set<String>> getSetDifference(Set<String> oldSet, Set<String> newSet) {

		Set<String> entriesAdded = new Set<String>();
		Set<String> entriesRemoved = new Set<String>();
		Set<String> commonEntries = new Set<String>();
		for(String newEntry : newSet) {
			if(!oldSet.contains(newEntry)) {
				entriesAdded.add(newEntry);
			} else {
				commonEntries.add(newEntry);
			}
		}
		for(String oldEntry : oldSet) {
			if(!commonEntries.contains(oldEntry)) {
				entriesRemoved.add(oldEntry);
			}
		}

		Map<String, Set<String>> setDifference = new Map<String, Set<String>>();
		setDifference.put('entriesAdded', entriesAdded);
		setDifference.put('entriesRemoved', entriesRemoved);

		return setDifference;
	}

	@testVisible 
	public static String getUpdatedMobileWapperBody(String body){
		Map<String, String> requestBody = new Map<String, String>();	
		requestBody.put('input', (body));
		requestBody.put('action', 'addAnchorForIframe');
		HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint+'/utility/sanitize-html', requestBody);
		String responseVal; 
		String updatedBody = body;
		if(res.getStatusCode()==200){
			responseVal = res.getBody();
			Map<String, String> resMap = (Map<String, String>)JSON.deserialize(responseVal, Map<String, String>.class);
			updatedBody = resMap.get('updatedBody');
		}else{
			logger.logError('SiteAddPageDataServer.getUpdatedMobileWapperBody()----status code----' + res.getStatusCode());
			throw new SimpplrException(String.valueOf(res.getStatusCode()));
		}
		return updatedBody;
	}

	public static void checkForRateLimit(String type) {

		// To Stop DOS attack limiting pagecreation to 2 request per second PS-816
		Datetime lastSecond = System.now().addSeconds(-1);
		String query = '';
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserInfo.getUserId());
		soqlParamMap.put('soqlParam2', lastSecond);
		switch on type {
			when 'content' {
				query = 'SELECT id FROM Simpplr_content__c WHERE createdBy.id=:soqlParam1 and  CreatedDate >=: soqlParam2';
			}
			when 'feeditem' {
				query = 'SELECT id FROM FeedItem WHERE CreatedById=:soqlParam1 and  CreatedDate >=: soqlParam2';
			}
			when 'feedcomment' {
				query = 'SELECT id FROM FeedComment WHERE CreatedById=:soqlParam1 and  CreatedDate >=: soqlParam2';
			}
		}
		query += ' LIMIT 3';
		logger.logDebug(query);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Object>objList = SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		if (!objList.isEmpty() && objList.size() > 2) {
			throw new SimpplrException(ServiceConstants.ERROR_429);
		}			
	}
		
	public static Map<String, Schema.SobjectField> getFieldMapByObjectName(String objectApiName){
		return Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
	}

    public static Map<String, NotificationHelper.BrandingInfo> getSimpplrBrandingMap(App_Config__c appConfig) {
        Map<String, NotificationHelper.BrandingInfo> resultMap = new Map<String, NotificationHelper.BrandingInfo>();
        
        NotificationHelper.BrandingInfo brandingInfo;
        if(appConfig == null) {
            String appConfigQuery = 'SELECT Branding_Logo__c, Branding_JSON__c FROM App_Config__c LIMIT 1';
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
        }
        brandingInfo = getBrandingInfoJson(appConfig.Branding_JSON__c, appConfig.Branding_Logo__c);
        resultMap.put('default', brandingInfo);

		if(SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentBrandingEnabled) {
			String segmentQuery = 'SELECT Id, Branding_JSON__c, Branding_Logo__c FROM Segment__c';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Segment__c> segmentList = ((List<Segment__c>)SIMPESAPI.accessController().queryAsUser(segmentQuery, null));
			for(Segment__c segmentRec : segmentList) {
				brandingInfo = getBrandingInfoJson(segmentRec.Branding_JSON__c, segmentRec.Branding_Logo__c);
				resultMap.put(segmentRec.Id, brandingInfo);
			}
		}
        return resultMap;
    }

    public static NotificationHelper.BrandingInfo getBrandingInfoJson(String brandingJsonString, String logoUrl) {
        NotificationHelper.BrandingInfo brandingInfo = new NotificationHelper.BrandingInfo();
        if(String.isNotBlank(brandingJsonString) && !'{}'.equalsIgnoreCase(brandingJsonString)) {
            brandingInfo = (NotificationHelper.BrandingInfo)JSON.deserialize(brandingJsonString, NotificationHelper.BrandingInfo.class);
        } else {
            brandingInfo.general_primaryColor = ServiceConstants.DEFAULT_BRANDING.get('general_primaryColor');
            brandingInfo.header_backgroundColor = ServiceConstants.DEFAULT_BRANDING.get('header_backgroundColor');
            brandingInfo.header_iconColor = ServiceConstants.DEFAULT_BRANDING.get('header_iconColor');
            brandingInfo.footer_backgroundColor = ServiceConstants.DEFAULT_BRANDING.get('footer_backgroundColor');
            brandingInfo.footer_textColor = ServiceConstants.DEFAULT_BRANDING.get('footer_textColor');
            brandingInfo.header_preset = ServiceConstants.DEFAULT_BRANDING.get('header_preset');
            brandingInfo.footer_preset = ServiceConstants.DEFAULT_BRANDING.get('footer_preset');
        }
        brandingInfo.logo_url = String.isNotBlank(logoUrl) ? logoUrl : EmailTemplateService.simpplrDefaultLogoUrl;
        return brandingInfo;
    }

	public static String getDefaultBrandingValues() {
		return JSON.serialize(new Map<String, String>{
			'general_primaryColor' => ServiceConstants.DEFAULT_BRANDING.get('general_primaryColor'),
			'general_primaryDarkModeColor' => ServiceConstants.DEFAULT_BRANDING.get('general_primaryDarkModeColor'),
			'general_backgroundColor' => ServiceConstants.DEFAULT_BRANDING.get('general_backgroundColor'),
			'general_lightModelinkColor' => ServiceConstants.DEFAULT_BRANDING.get('general_lightModelinkColor'),				//CONT-10737
			'general_darkModelinkColor' => ServiceConstants.DEFAULT_BRANDING.get('general_darkModelinkColor'),				//CONT-10737
			'general_brandingAnchorPrimaryColor' => ServiceConstants.DEFAULT_BRANDING.get('general_brandingAnchorPrimaryColor'),				//CONT-10737

			'general_backgroundImageTile' => 'repeat',
			'logo_faviconPath' => ServiceConstants.DEFAULT_BRANDING.get('logo_faviconPath'),
			'font_font' => SimpplrContext.defaultFontCSS,
			'font_font_css' => '',
			'header_preset' => ServiceConstants.DEFAULT_BRANDING.get('header_preset'),
			'header_backgroundColor' => ServiceConstants.DEFAULT_BRANDING.get('header_backgroundColor'),
			'header_textColor' => ServiceConstants.DEFAULT_BRANDING.get('header_textColor'),
			'header_iconColor' => ServiceConstants.DEFAULT_BRANDING.get('header_iconColor'),
			'footer_preset' => ServiceConstants.DEFAULT_BRANDING.get('footer_preset'),
			'footer_backgroundColor' => ServiceConstants.DEFAULT_BRANDING.get('footer_backgroundColor'),
			'footer_textColor' => ServiceConstants.DEFAULT_BRANDING.get('footer_textColor'),
			'general_backgroundImage' => null,
			'logo_logo' => null
		});
	}

	public static String getJwtToken() {
        String jwtToken;
        Map<String, Object> requestBody = Utility.getJwtTokenRequestBody();
        HttpResponse response =	Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/jwt', requestBody);
        Map<String, Object> respObj = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        jwtToken = respObj.get('token_type') + ' ' + respObj.get('jwtToken');
        return jwtToken;    
    }
}