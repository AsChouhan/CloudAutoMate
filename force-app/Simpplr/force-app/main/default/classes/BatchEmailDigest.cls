public class BatchEmailDigest implements Database.Batchable<sObject>, Database.stateful {
    public Integer frequency;
    public string query;	
    public String applicationName;
    public App_Config__c appConfig;
    public Map<String, NotificationHelper.BrandingInfo> brandingInfoMap;
    public string packageName = SimpplrContext.packageName;
    Set<String> feedCacheIdSet = new Set<String>();
    private Exception exceptionDetailsObj;
	public static final String KEY_DAILY_INTRO = 'email.notification.summary.digest.daily.intro';
	public static final String KEY_DAILY_SUBJECT = 'email.notification.summary.digest.daily.subject';
	public static final String KEY_WEEKLY_INTRO = 'email.notification.summary.digest.weekly.intro';
	public static final String KEY_WEEKLY_SUBJECT = 'email.notification.summary.digest.weekly.subject';

    public BatchEmailDigest(App_Config__c appConfig, Integer frequency, String query, 
            Map<String, NotificationHelper.BrandingInfo> brandingInfoMap) {
        this.appConfig = appConfig;
        this.query = query;
        this.frequency = frequency;
        this.applicationName = appConfig.App_Name__c;
        this.brandingInfoMap = brandingInfoMap;
    }
	
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
	}
    
    public void execute(Database.BatchableContext BC, List<People_Preference__c> userPrefList) {
    	try {
            String digestType = ''; 
            String intro = '';
            List<Messaging.SingleEmailMessage> digestEmailList = new List<Messaging.SingleEmailMessage>();
            List<String> userList = new List<String>();
            
            if (frequency == 1) {
                digestType = KEY_DAILY_SUBJECT;
                intro = KEY_DAILY_INTRO;
            
            } else if(frequency == 7) {
                digestType = KEY_WEEKLY_SUBJECT;
                intro = KEY_WEEKLY_INTRO;
            }
            
            String digestDate = String.valueOf((Datetime.now().addDays(-1)).format('EEEE, MMMM dd, YYYY'));
        
            Set<String> userIdSetForSOQLLike = new Set<String>();
            
            for (People_Preference__c usrPre : userPrefList) {
                userList.add(usrPre.People__r.user__c);
                userIdSetForSOQLLike.add('%' + usrPre.People__r.user__c + '%');
            }
            
            String BASE_QUERY_FOR_ENTITYSUBSCRIPTION = 'select parentId, SubscriberId from EntitySubscription  where SubscriberId IN : userList';
            
            if (SimpplrContext.isCommunitiesEnabled) {
                BASE_QUERY_FOR_ENTITYSUBSCRIPTION += ' and NetworkId = null';
            }

            Map<String, List<EntitySubscription>> userEntitySubMap = new  Map<String, List<EntitySubscription>>();
            
            for (EntitySubscription es : Database.query(BASE_QUERY_FOR_ENTITYSUBSCRIPTION)) {
                
                if (userEntitySubMap.get(es.SubscriberId) == null) {
                    userEntitySubMap.put(es.SubscriberId, new List<EntitySubscription>());
                }

                userEntitySubMap.get(es.SubscriberId).add(es);
            }
            
            Set<String> setOfPublicCollaborationGroupIds = new Set<String>();
            String baseQueryForCollaborationGroup = 'select id from CollaborationGroup where isArchived=false and CollaborationType=\'Public\' ';
            
            if (SimpplrContext.isCommunitiesEnabled) {
                baseQueryForCollaborationGroup += ' and NetworkId = null';
            }
            
            for (CollaborationGroup cg : Database.query(baseQueryForCollaborationGroup)) {
                setOfPublicCollaborationGroupIds.add(cg.Id);
            }

            String BASE_QUERY= 'SELECT CollaborationGroupId, memberid From CollaborationGroupMember where  memberid in :userList';
           
            if (SimpplrContext.isCommunitiesEnabled) {
                BASE_QUERY = BASE_QUERY+' and CollaborationGroup.networkid = null';
            }

            Map<String, Set<String>> userColGroupMap = new  Map<String, Set<String>>();

            for (CollaborationGroupMember cg : Database.query(BASE_QUERY)) {
                
                if (userColGroupMap.get(cg.memberid) == null) {
                    userColGroupMap.put(cg.memberid, new Set<String>());
                }

                userColGroupMap.get(cg.memberid).add(cg.CollaborationGroupId);
            }
        
            //applying filter to get commented feeditem id
            Datetime dateFilter = datetime.now().addHours(-24);
            Map<String, Set<String>> userFeedItemMap = new  Map<String, Set<String>>();
            
            for (FeedComment fComment : [SELECT FeedItemId, createdById, ParentId FROM FeedComment 
                WHERE ParentId != null and createdDate >=:dateFIlter and createdById in :userList]) {

                //If comment was on Site Feed and Site is not Public, check if user still has access to comment
                if(String.valueOf(fComment.parentId).startsWith('0F9') && 
                        setOfPublicCollaborationGroupIds.contains(fComment.parentId) == false) {
                    
                    //Mentions in private Site
                    if (userColGroupMap.containsKey(fComment.createdById) && 
                            userColGroupMap.get(fComment.createdById).contains(fComment.parentId)) {
                        //User is member of private site, we can include this post
                    } else {
                        //Since User is not member of private site, lets skip this post
                        continue;
                    }

                }

                if (userFeedItemMap.get(fComment.createdById) == null) {
                    userFeedItemMap.put(fComment.createdById, new Set<String>());
                }

                userFeedItemMap.get(fComment.createdById).add(fComment.FeedItemId);
            }
        
            String queryMetadata = 'Select Feed_Id__c,mentions__c,  Parent_Id__c, Site__c, Site__r.Chatter_Group_Id__c from Feed_Cache__c where Parent_Id__c != null And Is_Deleted__c = false And LastModifiedDate =  LAST_N_DAYS:'+frequency+' order by LastModifiedDate desc ';
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Feed_Cache__c> listOfFeedCache = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(queryMetadata, null);
            Map<String,Set<String>> cachedUserIdToListOfFeedItemIdMap = new Map<String,Set<String>>();
            
            for (People_Preference__c usrPre : userPrefList) {
                
                for (Feed_Cache__c fc : listOfFeedCache) {
                    //If mention was on Site Feed and Site is not Public, check if user still has access to Feed Post
                    
                    if (fc.parent_Id__c.startsWith('0F9') && 
                            setOfPublicCollaborationGroupIds.contains(fc.parent_Id__c) == false) {
                        //Mentions in private Site
                        
                        if (userColGroupMap.containsKey(usrPre.People__r.User__c) && userColGroupMap.get(usrPre.People__r.User__c).contains(fc.parent_Id__c)) {
                            //User is member of private site, we can include this post
                        
                        } else {
                            //Since User is not member of private site, lets skip this post
                            continue;
                        }

                    }

                    if (cachedUserIdToListOfFeedItemIdMap.get(usrPre.People__r.User__c) == null) {
                        cachedUserIdToListOfFeedItemIdMap.put(usrPre.People__r.User__c, new Set<String>());	
                    }

                    if (fc.mentions__c != null) {
                        
                        if (fc.mentions__c.containsIgnoreCase(usrPre.People__r.User__c)) {
                            cachedUserIdToListOfFeedItemIdMap.get(usrPre.People__r.User__c).add(fc.Feed_Id__c);
                        }

                    }
                    if (fc.Site__c != null && (setOfPublicCollaborationGroupIds.contains(fc.Site__r.Chatter_Group_Id__c) || (userColGroupMap.get(usrPre.People__r.User__c) != null && userColGroupMap.get(usrPre.People__r.User__c).contains(fc.Site__r.Chatter_Group_Id__c)))) {
                        cachedUserIdToListOfFeedItemIdMap.get(usrPre.People__r.User__c).add(fc.Feed_Id__c);
                    }

                }

            }

    	    initLangKeyValueMap(userPrefList);

            for (People_Preference__c users : userPrefList) {
                String targetUser = users.People__r.user__c;
                String languagelocalekey = Utility.getSimpplrLanguageLocaleKey(users.User__r.languagelocalekey);
                String subject = LocaleContext.getLabel(languagelocalekey, digestType).replace('{{appName}}',applicationName);
                Set<String> userColGrpSet = userColGroupMap.get(targetUser)!=null? userColGroupMap.get(targetUser) : new Set<String>();
                List<EntitySubscription> userEntSubList = userEntitySubMap.get(targetUser)!=null? userEntitySubMap.get(targetUser) : new List<EntitySubscription>();
                Set<String> commentFeedItemIdSet = userFeedItemMap.get(targetUser)!=null? userFeedItemMap.get(targetUser) : new Set<String>();
                Set<String> cachedFeedItemIdSet = cachedUserIdToListOfFeedItemIdMap.get(targetUser)!=null?cachedUserIdToListOfFeedItemIdMap.get(targetUser):new Set<String>();
                String brandingId = users.People__r.Segment__c != null && brandingInfoMap.containsKey(users.People__r.Segment__c) ? (String)users.People__r.Segment__c : 'default';
                String digestBody = EmailDigestBatchHelper.getDigestEmailBody(feedCacheIdSet, intro, users, userColGrpSet, userEntSubList, cachedFeedItemIdSet, commentFeedItemIdSet, frequency, applicationName, brandingInfoMap.get(brandingId));
                
                if (String.isNotBlank(digestBody)) {
                    Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
                    singleMail.setTargetObjectId(targetUser);
                    singleMail.setSubject(subject);
                    
                    if (String.isNotBlank(SimpplrContext.SEDFromEmail)) {
                        singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
                    }

                    if (SimpplrContext.DeeplinkingEnabled) {
                        digestBody = EmailUtility.deeplinkedMailBody(digestBody);
                    }

                    singleMail.setHtmlBody(digestBody);
                    singleMail.setCharset('UTF-8');
                    singleMail.setUseSignature(false);
                    singleMail.setSaveAsActivity(false);			
                    digestEmailList.add(singleMail);
                }
            }

            List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
            
            if (digestEmailList.size() > 0) {
                results = Messaging.sendEmail(digestEmailList);
            }

    	} catch (Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}

    }
    
	private void initLangKeyValueMap(List<People_Preference__c> PeoplePrefList) {
        Set<String> localeSet = new Set<String>();

		for (People_Preference__c peoplePrefObj : PeoplePrefList) {
			localeSet.add(Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.User__r.languagelocalekey));
		}

		LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
    }

	public void finish(Database.BatchableContext BC) {
		AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors, 
                JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus 
                FROM AsyncApexJob 
                WHERE Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;

		if (currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		
        } else {
			Utility.sendExceptionEmail('BatchEmailDigest', exceptionDetailsObj);
		}
		
		if (frequency == 1) {
			Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
			String dayOfWeek = dt.format('EEEE');
			String startOfWeek;
			
            if (SimpplrContext.StartOfWeek != null) {
				startOfWeek = SimpplrContext.StartOfWeek;
			
            } else {
				startOfWeek = 'Monday';
			}

			if (dayOfWeek.startsWithIgnoreCase(startOfWeek)) {
				String queryWeeklyEmailDigest = 'Select People__r.User__c,People__r.User__r.UserName, User__r.languagelocalekey, People__r.User__r.TimeZoneSidKey, People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c,People__r.Last_Name__c, Id from People_Preference__c where  people__r.User__r.isActive=true and people__r.User__r.UserType=\'Standard\' And Allow_Simpplr_Emails__c = true and Email_Digest_Frequency__c = \'Weekly\'';
				BatchEmailDigest jobWeeklyDigest = new BatchEmailDigest(appConfig, 7, queryWeeklyEmailDigest, brandingInfoMap);		
		        Database.executeBatch(jobWeeklyDigest, 25);
			}

		}
		        
    }
    
}