public with sharing class NotificationContentProvider {

  
    public static NotificationListingWrapper.PaginationWrapper getAllNotifications(Criteria.Notification notificationCriteriaObj) {
        groupNotifications();

        NotificationListingWrapper.PaginationWrapper notificationPaginatorObj = new NotificationListingWrapper.PaginationWrapper();
        List<NotificationListingWrapper> listOfNotificationWrap = new List<NotificationListingWrapper>();
		List<App_Notification__c> listOfNotification = new List<App_Notification__c>();
		NotificationDao notificationDaoObj = new NotificationDao();
    	notificationDaoObj.markInActiveSitesNotificationAsDeleted();
		NotificationListingWrapper notificationWrapObj;
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize+1;
		listOfNotification = notificationDaoObj.getAllNotifications(notificationCriteriaObj.peopleId, notificationCriteriaObj.offset, recordLimit, notificationCriteriaObj.sortBy,
    			notificationCriteriaObj.siteId, notificationCriteriaObj.filter, notificationCriteriaObj.origin);
        Boolean isAnyContentNotAccessible = false; 
        
		if (!listOfNotification.isEmpty()) {
            Map<String, String> contentToImgURL = new Map<String, String>();
            Set<String> contentIds = new Set<String>();
            for (App_Notification__c notificationObj : listOfNotification) {
                if('Content_For_Review'.equalsIgnoreCase(notificationObj.Category__c) && String.isNotBlank(notificationObj.Content__c)){
                    contentIds.add(notificationObj.Content__c);
                }
            }
            contentToImgURL = NotificationDao.getContentImage(contentIds);
            // Intialize In App Notification labels, if not done yet.
            LocaleContext.getLabelMap('InAppNotifications', UserContext.languageLocaleKey);
            for (App_Notification__c notificationObj : listOfNotification) {
                logger.logDebug('notificationObj '+notificationObj);
                notificationWrapObj = new NotificationListingWrapper();

                if (!(notificationObj.Content__c != null && 
                        notificationObj.Content__r.Type__c == null)) {
                        
                    if('mobile'.equalsIgnoreCase(notificationCriteriaObj.origin)) {
                        notificationWrapObj = ObjectToWrapperAdapter.notificationToWrapperForMobile(notificationObj, UserContext.languageLocaleKey);
                    
                    } else {
                        notificationWrapObj = ObjectToWrapperAdapter.notificationToWrapper(notificationObj, 'ian');

                    }
                    notificationWrapObj.stamp = '';
                    notificationWrapObj.imgContent = 'Content_For_Review'.equalsIgnoreCase(notificationObj.Category__c) && String.isNotBlank(notificationObj.Content__c) && contentToImgURL.containsKey(notificationObj.Content__c) ? contentToImgURL.get(notificationObj.Content__c) : null;
                    notificationWrapObj.imgSite = 'Content_For_Review'.equalsIgnoreCase(notificationObj.Category__c) && String.isNotBlank(notificationObj.Simpplr_Site__r.Title_Content_Version__c) ? Utility.getFileDownloadURLFor120BY90(notificationObj.Simpplr_Site__r.Title_Content_Version__c) : null;
                    listOfNotificationWrap.add(notificationWrapObj); 

                } else {
                    isAnyContentNotAccessible = true;
                }
            }
        }

        notificationPaginatorObj.listOfItems.addAll(listOfNotificationWrap);

        if (listOfNotification.size() == (SimpplrContext.simpplrDefaultPageSize + 1) &&
                notificationCriteriaObj.offset < 2000) {

            if (!isAnyContentNotAccessible) {
                notificationPaginatorObj.listOfItems.remove((notificationPaginatorObj.listOfItems.size()-1));
            }
            
            notificationPaginatorObj.nextPageToken = Integer.valueOf(notificationCriteriaObj.offset + SimpplrContext.simpplrDefaultPageSize);
        } else {
            notificationPaginatorObj.nextPageToken = null;
        }
        
        notificationPaginatorObj.viewAllLink = PageContext.getPageURL(Pages.Notifications);
        notificationPaginatorObj.totalCounts = new NotificationListingWrapper.countWrapper();
        notificationPaginatorObj.totalCounts.activity = 0;
        notificationPaginatorObj.totalCounts.actionable = 0;
            
        notificationPaginatorObj.newCounts = getNewNotificationCount(notificationCriteriaObj.peopleId, notificationCriteriaObj.origin);
		
    	return notificationPaginatorObj;
    }

    private static Integer resetActionCount(App_Notification__c notificationObj) {
        Integer actionCount = (Integer)notificationObj.Action_Count__c;

        if(String.isBlank(notificationObj.RAB_3__c)) {
            actionCount = 2;
        }
        if(String.isBlank(notificationObj.RAB_2__c)) {
            actionCount = 1;
        }

        return actionCount;
    }

    public static void groupNotifications() {
        //(ObjectId , ObjId) is the id of object on which action is taken which generated the notification
        // Fetch ungrouped notifications for loggedInUser 
        
        Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);

        String queryString = 'SELECT Id, Name, Is_Read__c, App_Notification__c, Created_DateTime__c,'
            + ' Object_Type__c, Object_Id__c, Parent_Object_Id__c, Type__c, Category__c, Content__c, Simpplr_Site__c,'
            + ' Sent_By__c, Sent_To__c, snippet__c, Status__c, Sub_Type__c'
            + ' FROM Ungrouped_Notification__c'
            + ' WHERE App_Notification__c = null AND Is_Read__c=false AND Sent_to__c = :soqlParam1'
            + ' AND Is_New__c = true AND Is_Deleted__c=false'
            + ' AND (Not(Content__c != null AND Content__r.Type__c = null))'
            + ' AND (Simpplr_Site__c = null OR (Simpplr_Site__r.is_active__c = true And Simpplr_Site__r.Show_In_Simpplr__c = true))'
            + ' FOR UPDATE';

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Ungrouped_Notification__c> listOfUngroupedNoti = (List<Ungrouped_Notification__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

        if (!listOfUngroupedNoti.isEmpty()) {
            // Ungrouped notifcations can be there for multiple objects and types
            Map<String, NotificationWrapper.GroupedNotification> mapOfObjIdWithGroupedNotifWrap = new Map<String, NotificationWrapper.GroupedNotification>();

            // Set to query app_notification 
            Set<String> setOfObjectIdForQuery = new Set<String>();
            Set<String> setOfParentObjectIdForQuery = new Set<String>();

            for (Ungrouped_Notification__c ungrpedNotiObj : listOfUngroupedNoti) {
                String keyForGrouping = getKeyForGrouping(ungrpedNotiObj.Parent_Object_Id__c, ungrpedNotiObj.Object_Id__c, ungrpedNotiObj.Category__c, ungrpedNotiObj.content__c, ungrpedNotiObj.sub_Type__c);
                
                // GET new/updated GroupedNotification wrapper obj for the specified key.. 
                NotificationWrapper.GroupedNotification groupedNotfiWrap = getGroupedNotiWrapperObj(keyForGrouping, ungrpedNotiObj, mapOfObjIdWithGroupedNotifWrap);

                // PUT GroupedNotification wrapper obj into map
                mapOfObjIdWithGroupedNotifWrap.put(keyForGrouping, groupedNotfiWrap);

                setOfObjectIdForQuery.add(ungrpedNotiObj.Object_Id__c);
                setOfParentObjectIdForQuery.add(ungrpedNotiObj.Parent_Object_Id__c);
            }

            // Fetch the existing notification records if record exist then update else insert 
            List<App_Notification__c> listOfAppNotications = [SELECT Id, Name, Is_Read__c, Parent__c, Category__c, Sent_By__c,
                        Created_DateTime__c, Object_Type__c, Object_Id__c, Parent_Object_Id__c, Is_Deleted__c,
                        RAB_1__c, RAB_2__c, RAB_3__c, Action_Count__c, Content__c, Sub_Type__c
                    FROM App_Notification__c 
                    WHERE Is_Read__c=false AND Is_New__c=true AND (Object_Id__c IN :setOfObjectIdForQuery OR Parent_Object_Id__c IN :setOfParentObjectIdForQuery)
                    AND Is_Deleted__c=false AND (Type__c='Information' OR (Type__c = 'Actionable' AND Category__c IN ('Private_Site_Membership_Requests', 'Public_Site_Membership_Requests')))
                    AND Sent_to__c=:UserContext.peopleId WITH SECURITY_ENFORCED];

            List<App_Notification__c> listOfAppNotiForUpdate = new List<App_Notification__c> ();
            Map<String, App_Notification__c> mapOfObjectIdWithAppNotiRecord = new Map<String, App_Notification__c>();
            for (App_Notification__c appNotiObj: listOfAppNotications) {

                // If there is any app_notification record is present for ungroupedNotification record
                String keyForGrouping = getKeyForGrouping(appNotiObj.Parent_Object_Id__c, appNotiObj.Object_Id__c, appNotiObj.Category__c, appNotiObj.Content__c, appNotiObj.Sub_Type__c);
                if (mapOfObjIdWithGroupedNotifWrap.keySet().contains(keyForGrouping)) {
                    if(mapOfObjectIdWithAppNotiRecord.containsKey(keyForGrouping)) {
                        appNotiObj.Is_Deleted__c = true;
                        listOfAppNotiForUpdate.add(appNotiObj);
                    } else {
                        mapOfObjectIdWithAppNotiRecord.put(keyForGrouping, appNotiObj);
                    }
                }

            }

            List<App_Notification__c> listOfAppNotiForInsert = new List<App_Notification__c> ();
            

            for (String keyForGrouping : mapOfObjIdWithGroupedNotifWrap.keySet()) {
                NotificationWrapper.GroupedNotification groupNotifWrapObj= new NotificationWrapper.GroupedNotification();
                groupNotifWrapObj = mapOfObjIdWithGroupedNotifWrap.get(keyForGrouping);

                // Update the existing app_notification record
                if (mapOfObjectIdWithAppNotiRecord.containsKey(keyForGrouping)) {
                    App_Notification__c appNotifObjForUpdate = mapOfObjectIdWithAppNotiRecord.get(keyForGrouping);

                    appNotifObjForUpdate.Sent_By__c = groupNotifWrapObj.rAB1;
                    appNotifObjForUpdate.Action_Count__c +=  groupNotifWrapObj.total;
                    appNotifObjForUpdate.Created_DateTime__c = groupNotifWrapObj.rAB1DateTime; 
                    appNotifObjForUpdate.Object_Id__c = groupNotifWrapObj.ObjectId;
                    if(String.isNotBlank(groupNotifWrapObj.rAB1) && String.isNotBlank(groupNotifWrapObj.rAB2) && String.isNotBlank(groupNotifWrapObj.rAB3)) {
                        appNotifObjForUpdate.RAB_1__c = groupNotifWrapObj.rAB1;
                        appNotifObjForUpdate.RAB_2__c = groupNotifWrapObj.rAB2;
                        appNotifObjForUpdate.RAB_3__c = groupNotifWrapObj.rAB3;
                    } else if(String.isNotBlank(groupNotifWrapObj.rAB1) && String.isNotBlank(groupNotifWrapObj.rAB2)) {
                        if(String.isNotBlank(appNotifObjForUpdate.RAB_1__c)) {
                            appNotifObjForUpdate.RAB_3__c = appNotifObjForUpdate.RAB_1__c;
                        }

                        appNotifObjForUpdate.RAB_1__c = groupNotifWrapObj.rAB1;
                        appNotifObjForUpdate.RAB_2__c = groupNotifWrapObj.rAB2;
                    } else if(String.isNotBlank(groupNotifWrapObj.rAB1)) {
                        if(String.isNotBlank(appNotifObjForUpdate.RAB_1__c) && String.isNotBlank(appNotifObjForUpdate.RAB_2__c)) {
                            appNotifObjForUpdate.RAB_3__c = appNotifObjForUpdate.RAB_2__c;
                            appNotifObjForUpdate.RAB_2__c = appNotifObjForUpdate.RAB_1__c;
                        } else if(String.isNotBlank(appNotifObjForUpdate.RAB_1__c)) {
                            appNotifObjForUpdate.RAB_2__c = appNotifObjForUpdate.RAB_1__c;
                        }

                        appNotifObjForUpdate.RAB_1__c = groupNotifWrapObj.rAB1;
                    }

                    if(((String)appNotifObjForUpdate.RAB_1__c).equalsIgnoreCase(appNotifObjForUpdate.RAB_2__c)) {
                        appNotifObjForUpdate.RAB_2__c = appNotifObjForUpdate.RAB_3__c;
                        appNotifObjForUpdate.RAB_3__c = null;
                    }

                    if(((String)appNotifObjForUpdate.RAB_1__c).equalsIgnoreCase(appNotifObjForUpdate.RAB_3__c) || 
                            (   (appNotifObjForUpdate.RAB_2__c != null) &&
                                ((String)appNotifObjForUpdate.RAB_2__c).equalsIgnoreCase(appNotifObjForUpdate.RAB_3__c))) {
                        
                        appNotifObjForUpdate.RAB_3__c = null;
                    }
                    
                    if(String.isBlank(appNotifObjForUpdate.RAB_3__c) && String.isNotBlank(appNotifObjForUpdate.RAB_2__c)) {
                        appNotifObjForUpdate.Action_Count__c = 2;
                    } else if(String.isBlank(appNotifObjForUpdate.RAB_2__c)) {
                        appNotifObjForUpdate.Action_Count__c = 1;
                    }

                    // ActionCount should be in sync with users(rab1, rab2, rab3)
                    appNotifObjForUpdate.Action_Count__c = resetActionCount(appNotifObjForUpdate);
                   
                    listOfAppNotiForUpdate.add(appNotifObjForUpdate);
                
                // Insert app_notification record
                } else {
                    App_Notification__c appNotifObjForInsert = new App_Notification__c();
                    appNotifObjForInsert.Sent_to__c = UserContext.peopleId;
                    appNotifObjForInsert.Is_Read__c = false;
                    appNotifObjForInsert.Is_New__c = true;
                    appNotifObjForInsert.Is_Grouped__c = true;
                    appNotifObjForInsert.Parent_Object_Id__c = groupNotifWrapObj.parentObjectId;
                    appNotifObjForInsert.Object_Id__c = groupNotifWrapObj.ObjectId;
                    appNotifObjForInsert.Object_Type__c = groupNotifWrapObj.ObjectType;
                    appNotifObjForInsert.Content__c = groupNotifWrapObj.contentId;
                    appNotifObjForInsert.Simpplr_Site__c = groupNotifWrapObj.siteId;
                    appNotifObjForInsert.Sent_By__c = groupNotifWrapObj.rAB1;
                    appNotifObjForInsert.Snippet__c = groupNotifWrapObj.snippet;
                    appNotifObjForInsert.Status__c = groupNotifWrapObj.status;
                    appNotifObjForInsert.Sub_Type__c = groupNotifWrapObj.subType;
                    appNotifObjForInsert.Type__c = groupNotifWrapObj.type;
                    appNotifObjForInsert.Category__c = groupNotifWrapObj.category;
                    //appNotifObjForInsert.id = mapOfObjectIdWithAppNotiRecord.get(keyForGrouping).Id;
                    appNotifObjForInsert.Created_DateTime__c = groupNotifWrapObj.rAB1DateTime; 
                    appNotifObjForInsert.RAB_1__c = groupNotifWrapObj.rAB1;
                    appNotifObjForInsert.RAB_2__c = groupNotifWrapObj.rAB2;
                    appNotifObjForInsert.RAB_3__c = groupNotifWrapObj.rAB3;
                    appNotifObjForInsert.Action_Count__c = groupNotifWrapObj.total;

                    // ActionCount should be in sync with users(rab1, rab2, rab3) 
                    appNotifObjForInsert.Action_Count__c = resetActionCount(appNotifObjForInsert);
                   
                    listOfAppNotiForInsert.add(appNotifObjForInsert);
                }
            }

            if (!listOfAppNotiForInsert.isEmpty()) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listOfAppNotiForInsert, new List<Schema.SObjectField> {
                                                                        App_Notification__c.Sent_to__c,
                                                                        App_Notification__c.Is_Read__c,
                                                                        App_Notification__c.Is_New__c,
                                                                        App_Notification__c.Is_Grouped__c,
                                                                        App_Notification__c.Parent_Object_Id__c,
                                                                        App_Notification__c.Object_Id__c,
                                                                        App_Notification__c.Object_Type__c,
                                                                        App_Notification__c.Content__c,
                                                                        App_Notification__c.Simpplr_Site__c,
                                                                        App_Notification__c.Sent_By__c,
                                                                        App_Notification__c.Snippet__c,
                                                                        App_Notification__c.Status__c,
                                                                        App_Notification__c.Sub_Type__c,
                                                                        App_Notification__c.Type__c,
                                                                        App_Notification__c.Category__c,
                                                                        App_Notification__c.Created_DateTime__c, 
                                                                        App_Notification__c.RAB_1__c,
                                                                        App_Notification__c.RAB_2__c,
                                                                        App_Notification__c.RAB_3__c,
                                                                        App_Notification__c.Action_Count__c
																	});
                listOfAppNotiForInsert = (List<App_Notification__c>)result.getInsertedObjects();
                // For newly inserted records add app_notification recordId to map  
                for (App_Notification__c appNotiObj: listOfAppNotiForInsert) {
                    String keyForGrouping = getKeyForGrouping(appNotiObj.Parent_Object_Id__c, appNotiObj.Object_Id__c, appNotiObj.Category__c, appNotiObj.Content__c, appNotiObj.Sub_Type__c);
                    mapOfObjectIdWithAppNotiRecord.put(keyForGrouping, appNotiObj);
                }

            } 

            if (!listOfAppNotiForUpdate.isEmpty()) {
                List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
                        App_Notification__c.Sent_By__c,
                        App_Notification__c.Action_Count__c,
                        App_Notification__c.Created_DateTime__c,
                        App_Notification__c.RAB_1__c,
                        App_Notification__c.RAB_2__c,
                        App_Notification__c.RAB_3__c,
                        App_Notification__c.Is_Deleted__c,
                        App_Notification__c.Object_Id__c
                };

                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(listOfAppNotiForUpdate), listOfColumnsToBeUpdated);
            }

            // Create ungrouped to releventexistingNoti map while updating 
            for (Ungrouped_Notification__c ungrpedNotiObj: listOfUngroupedNoti) {
                String keyForGrouping = getKeyForGrouping(ungrpedNotiObj.Parent_Object_Id__c, ungrpedNotiObj.Object_Id__c, ungrpedNotiObj.Category__c, ungrpedNotiObj.content__c, ungrpedNotiObj.sub_Type__c);
                ungrpedNotiObj.App_Notification__c = mapOfObjectIdWithAppNotiRecord.get(keyForGrouping).Id; 
            }

            List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
                    Ungrouped_Notification__c.App_Notification__c
                };

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id,Ungrouped_Notification__c>(listOfUngroupedNoti), listOfColumnsToBeUpdated);
        }
    }

    private static NotificationWrapper.GroupedNotification getGroupedNotiWrapperObj(String keyForGrouping, Ungrouped_Notification__c ungrpedNotiObj, Map<String, NotificationWrapper.GroupedNotification> mapOfObjIdWithGroupedNotifWrap) {
        
        NotificationWrapper.GroupedNotification groupedNotfiWrap = new NotificationWrapper.GroupedNotification();
        
        if (mapOfObjIdWithGroupedNotifWrap.keySet().contains(keyForGrouping)) {
            groupedNotfiWrap = mapOfObjIdWithGroupedNotifWrap.get(keyForGrouping);
            
            if( !((String)ungrpedNotiObj.Sent_By__c).equalsIgnoreCase(groupedNotfiWrap.rAB1) 
                && !((String)ungrpedNotiObj.Sent_By__c).equalsIgnoreCase(groupedNotfiWrap.rAB2)
                && !((String)ungrpedNotiObj.Sent_By__c).equalsIgnoreCase(groupedNotfiWrap.rAB3)
                    ) {
                groupedNotfiWrap.total++; 
            }
            
            DateTime dateTimeSwapVar;
            String rabPeopleIdSwapVar;
            Boolean executeIfCondition = true;

            // Second value is not populated That means third is also not populated
            if (groupedNotfiWrap.rAB2DateTime == null) {
                executeIfCondition = false; 
                
                // If only RAB1 exists and incoming ungroupedNoti Object is equal to RAB1 then, ----- do nothing
                if(groupedNotfiWrap.rAB1.equalsIgnoreCase(ungrpedNotiObj.Sent_By__c)) {
                    // do nothing
                } else {
                    groupedNotfiWrap.rAB2DateTime = ungrpedNotiObj.Created_DateTime__c;
                    groupedNotfiWrap.rAB2 = ungrpedNotiObj.Sent_By__c;
    
                    // If rab2 is latest as compared to rab1 then switch values 
                    if (groupedNotfiWrap.rAB1DateTime < groupedNotfiWrap.rAB2DateTime) {
                        //Swapping created date time stamp
                        dateTimeSwapVar = groupedNotfiWrap.rAB1DateTime;
                        groupedNotfiWrap.rAB1DateTime = groupedNotfiWrap.rAB2DateTime;
                        groupedNotfiWrap.rAB2DateTime = dateTimeSwapVar; 
    
                        //Swapping createdBy people
                        rabPeopleIdSwapVar = groupedNotfiWrap.rAB1;
                        groupedNotfiWrap.rAB1 = groupedNotfiWrap.rAB2;
                        groupedNotfiWrap.rAB2 = rabPeopleIdSwapVar;
                    }
                }
            }

            // Third value is not populated
            else if (executeIfCondition && groupedNotfiWrap.rAB3DateTime == null) { 
                groupedNotfiWrap.rAB3DateTime = ungrpedNotiObj.Created_DateTime__c;
                groupedNotfiWrap.rAB3 = ungrpedNotiObj.Sent_By__c;

                //(rab2 <rab3) If rab3 is latest as compared to rab2 then switch values 
                if (groupedNotfiWrap.rAB2DateTime < groupedNotfiWrap.rAB3DateTime) {

                    //(rab3 > rab1 > rab2)  If rab3 is latest as compared to rab1 then switch values 
                    if (groupedNotfiWrap.rAB1DateTime < groupedNotfiWrap.rAB3DateTime) {
                        // rab 1 and rab 3 datetime exchange 
                        dateTimeSwapVar = groupedNotfiWrap.rAB1DateTime;
                        groupedNotfiWrap.rAB1DateTime = groupedNotfiWrap.rAB3DateTime;
                        groupedNotfiWrap.rAB3DateTime = groupedNotfiWrap.rAB2DateTime; 
                        groupedNotfiWrap.rAB2DateTime = dateTimeSwapVar;

                        //Swapping createdBy people 
                        rabPeopleIdSwapVar = groupedNotfiWrap.rAB1;
                        groupedNotfiWrap.rAB1 = groupedNotfiWrap.rAB3;
                        groupedNotfiWrap.rAB3 = groupedNotfiWrap.rAB2; 
                        groupedNotfiWrap.rAB2 = rabPeopleIdSwapVar;

                    //(rab1 > rab3 > rab2) if rab3 is older then rab1 
                    } else {
                        //Datetime exchange  rab2 and rab3 
                        dateTimeSwapVar = groupedNotfiWrap.rAB2DateTime;
                        groupedNotfiWrap.rAB2DateTime = groupedNotfiWrap.rAB3DateTime;
                        groupedNotfiWrap.rAB3DateTime = dateTimeSwapVar; 

                        //People exchange  rab2 and rab3  
                        rabPeopleIdSwapVar = groupedNotfiWrap.rAB2;
                        groupedNotfiWrap.rAB2 = groupedNotfiWrap.rAB3;
                        groupedNotfiWrap.rAB3 = rabPeopleIdSwapVar;
                    }
                }
            
            // All three rab1, rab2, rab3 populated
            } else if (executeIfCondition) {
                //(rab1 > rab2 > rab3 < newUnGroupedNotiDateTime) if value is less than rab3 then no change is required
                if (groupedNotfiWrap.rAB3DateTime < ungrpedNotiObj.Created_DateTime__c) {

                    //(rab3 < rab2 < rab1 < newUnGroupedNotiDateTime )
                    if (groupedNotfiWrap.rAB1DateTime < ungrpedNotiObj.Created_DateTime__c) {
                        // newDateTime added to rab1DateTime and rab2DateTime moved to rab3DateTime and rab1DateTime at rab2DateTime 
                        dateTimeSwapVar = groupedNotfiWrap.rAB1DateTime;
                        groupedNotfiWrap.rAB1DateTime = ungrpedNotiObj.Created_DateTime__c;
                        groupedNotfiWrap.rAB3DateTime = groupedNotfiWrap.rAB2DateTime; 
                        groupedNotfiWrap.rAB2DateTime = dateTimeSwapVar;

                        // new people added to rab1 and rab2 moved to rab3 and rab 1 at rab2 
                        rabPeopleIdSwapVar = groupedNotfiWrap.rAB1;
                        groupedNotfiWrap.rAB1 = ungrpedNotiObj.Sent_By__c;
                        groupedNotfiWrap.rAB3 = groupedNotfiWrap.rAB2; 
                        groupedNotfiWrap.rAB2 = rabPeopleIdSwapVar;

                    //(rab3 < rab2 <  newUnGroupedNotiDateTime < rab1 )
                    } else if (groupedNotfiWrap.rAB2DateTime < ungrpedNotiObj.Created_DateTime__c) {
                        // rab2 is moved to rab3datetime and rab2datetime is now new value 
                        groupedNotfiWrap.rAB3DateTime = groupedNotfiWrap.rAB2DateTime;
                        groupedNotfiWrap.rAB2DateTime = ungrpedNotiObj.Created_DateTime__c;

                            // rab2 people is moved to rab3 and rab2 people is now new value 
                            groupedNotfiWrap.rAB3 = groupedNotfiWrap.rAB2;
                            groupedNotfiWrap.rAB2 = ungrpedNotiObj.Sent_By__c;

                    //(rab3 < newUnGroupedNotiDateTime < rab2 < rab1)
                    } else {
                        // rab3datetime is overwritten by new value. 
                        groupedNotfiWrap.rAB3DateTime = ungrpedNotiObj.Created_DateTime__c;

                        // rab3 people is overwritten by new value. 
                        groupedNotfiWrap.rAB3 = ungrpedNotiObj.Sent_By__c;
                    }
                }
            }
            
        } else {
            //Entring first value for keyForGrouping combination, So only Rab1 is populated
            groupedNotfiWrap.rAB1 = ungrpedNotiObj.Sent_By__c;
            groupedNotfiWrap.rAB1DateTime = ungrpedNotiObj.Created_DateTime__c;
            groupedNotfiWrap.total = 1;
        }

        //Like Unlike Case
        if (groupedNotfiWrap.rAB1!=null && groupedNotfiWrap.rAB2!=null && groupedNotfiWrap.rAB3!=null) {
            //When 3 persons liked and 1st and 3rd are same and it all goes in a single hit.
            if (groupedNotfiWrap.rAB1==groupedNotfiWrap.rAB3){
                groupedNotfiWrap.rAB3 = null;
                groupedNotfiWrap.rAB3DateTime = null;
                groupedNotfiWrap.total--;
            } else if (groupedNotfiWrap.rAB1==groupedNotfiWrap.rAB2 ){
                if (groupedNotfiWrap.rAB3==null){
                    groupedNotfiWrap.rAB2 = null;
                    groupedNotfiWrap.rAB2DateTime = null;
                } else {
                    groupedNotfiWrap.rAB2 = groupedNotfiWrap.rAB3;
                    groupedNotfiWrap.rAB2DateTime = groupedNotfiWrap.rAB3DateTime;
                    groupedNotfiWrap.rAB3 = null;
                    groupedNotfiWrap.rAB3DateTime = null;
                }
                groupedNotfiWrap.total--;
            }
        } else if (groupedNotfiWrap.rAB1!=null && groupedNotfiWrap.rAB2!=null && groupedNotfiWrap.rAB3==null){
            //When 2 ungrouped notifications picked in a single hit
            if (groupedNotfiWrap.rAB1==groupedNotfiWrap.rAB2){
                groupedNotfiWrap.rAB2 = null;
                groupedNotfiWrap.rAB2DateTime = null;
                groupedNotfiWrap.total--;
            }
        }

        groupedNotfiWrap.parentObjectId = ungrpedNotiObj.Parent_Object_Id__c;
        groupedNotfiWrap.objectId = ungrpedNotiObj.Object_Id__c;
        groupedNotfiWrap.objectType = ungrpedNotiObj.Object_Type__c;
        groupedNotfiWrap.contentId = ungrpedNotiObj.Content__c;
        groupedNotfiWrap.siteId = ungrpedNotiObj.Simpplr_Site__c;
        groupedNotfiWrap.sentBy = ungrpedNotiObj.Sent_By__c;
        groupedNotfiWrap.snippet = ungrpedNotiObj.Snippet__c;
        groupedNotfiWrap.status = ungrpedNotiObj.Status__c;
        groupedNotfiWrap.subType = ungrpedNotiObj.Sub_Type__c;
        groupedNotfiWrap.type = ungrpedNotiObj.Type__c;
        groupedNotfiWrap.category = ungrpedNotiObj.Category__c;

        return groupedNotfiWrap;
    }


    private static String getKeyForGrouping(String parentObjectId, String objectId, String category, String contentID, String subtype) {
        String key;

		NotificationDao notiDaoObj = new NotificationDao();
		List<String> groupedNotiCategories = notiDaoObj.getGroupedNotificationCategories();

		if(String.isNotBlank(contentID) && groupedNotiCategories.contains(category)) {
            key = contentID + '----' + category;
    
        } else if (String.isNotBlank(parentObjectId)) {
            key = parentObjectId + '----' + category;
    
        } else if (String.isNotBlank(objectId)) {
            key = objectId + '----' + category;

        }
        
        return key;
    }

    public static List<NotificationListingWrapper> getPopUpNotifications(Criteria.Notification notificationCriteriaObj) {
        groupNotifications();
        List<NotificationListingWrapper> listOfNotificationWrap = new List<NotificationListingWrapper>();
    	List<App_Notification__c> listOfNotification = new List<App_Notification__c>();
    	Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
    	NotificationDao notificationDaoObj = new NotificationDao();
    	
    	if (notificationCriteriaObj.markAsSeen == true && notificationCriteriaObj.filter == 'activity'){
    		notificationDaoObj.markNotificationAsSeenForMobile('Information',notificationCriteriaObj.includeFeedNotification);
    	}

    	List<NotificationListingWrapper> lstAll = new List<NotificationListingWrapper>();
		listOfNotification = notificationDaoObj.getPopUpNotifications(notificationCriteriaObj.filter,
				notificationCriteriaObj.offSet,recordLimit, notificationCriteriaObj.since, 
				notificationCriteriaObj.peopleId,notificationCriteriaObj.origin, 
				notificationCriteriaObj.includeFeedNotification);

    	if (!listOfNotification.isEmpty()) {	

			if('mobile'.equalsIgnoreCase(notificationCriteriaObj.origin)){
				// Intialize In App Notification labels, if not done yet.
				String languageLocaleKey = String.isBlank(notificationCriteriaObj.languageLocaleKey) ? 'en_US' : notificationCriteriaObj.languageLocaleKey;
				LocaleContext.getLabelMap('InAppNotifications', languageLocaleKey);

				for (App_Notification__c notificationObj : listOfNotification) {
					NotificationListingWrapper notifactionWrapObj = new NotificationListingWrapper();
					notifactionWrapObj = ObjectToWrapperAdapter.notificationToWrapperForMobile(notificationObj,notificationCriteriaObj.languageLocaleKey);
					listOfNotificationWrap.add(notifactionWrapObj);
				}

			} else {
				// Intialize In App Notification labels, if not done yet.
				LocaleContext.getLabelMap('InAppNotifications', UserContext.languageLocaleKey);

				for (App_Notification__c notificationObj : listOfNotification) {
					NotificationListingWrapper notifactionWrapObj = new NotificationListingWrapper();
					notifactionWrapObj = ObjectToWrapperAdapter.notificationToWrapper(notificationObj,'ian');
					listOfNotificationWrap.add(notifactionWrapObj);
                }
            }
        }
        
    	return listOfNotificationWrap;
    }
    
    public static NotificationListingWrapper.CountWrapper getTotalNotificationCount(String peopleId) {
    	List<App_Notification__c> activityList = new List<App_Notification__c>();
    	List<App_Notification__c> actionableList = new List<App_Notification__c>();
    	List<App_Notification__c> allNotificationList = NotificationDao.getTotalNotificationCount(peopleId);
    	for (App_Notification__c notObj : allNotificationList){
    		if ('Information'.equalsIgnoreCase(notObj.Type__c)  ){
    			activityList.add(notObj);
    		} else {
    			actionableList.add(notObj);
    		}
    	}
    	NotificationListingWrapper.CountWrapper wrapperObj = new NotificationListingWrapper.CountWrapper();
    	Map<String, Integer> countMap = new Map<String, Integer>(); 
        countMap.put('Information', (Integer) activityList.size());
        countMap.put('Actionable', (Integer) actionableList.size());
        if(countMap.containsKey('Actionable')) {
        	wrapperObj.actionable = countMap.get('Actionable');
        } else {
        	wrapperObj.actionable = 0;
        }
        if(countMap.containsKey('Information')) {
        	wrapperObj.activity = countMap.get('Information');
        } else {
        	wrapperObj.activity = 0;
        }
    	return wrapperObj;
    }

	public Map<String, Object> getContentNotificationMessage(String contentMessageId) {
		Map<String, Object> resultMap = new Map<String, Object>();
		NotificationDao daoObj = new NotificationDao();
		List<Content_Message__c> contentMessageList = daoObj.getContentNotificationMessage(contentMessageId);
		if(!contentMessageList.isEmpty()) {
			resultMap.put('createdAt', Utility.dateToDisplayString(contentMessageList[0].CreatedDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			
			PeopleWrapper pwObj = new PeopleContentProvider().getUser(contentMessageList[0].Sent_By_People__c, false,false);
			resultMap.put('createdBy', pwObj);
			resultMap.put('message', contentMessageList[0].Message__c);
		}
		return resultMap;
	}
    
    public static NotificationListingWrapper.CountWrapper getNewNotificationCount(String peopleId, String origin) {
    	
    	AggregateResult[] groupedResults;
    	
    	if('mobile'.equalsIgnoreCase(origin)){
    		groupedResults = NotificationDao.getNewNotificationCountForMobile(peopleId);
    	}else{
    		groupedResults = NotificationDao.getNewNotificationCount(peopleId);
    	}
    	NotificationListingWrapper.CountWrapper wrapperObj = new NotificationListingWrapper.CountWrapper();
    	Map<String, Integer> countMap = new Map<String, Integer>(); 
    	for(AggregateResult ar : groupedResults){
            countMap.put(String.valueOf(ar.get('notifcationType')), (Integer) ar.get('expr0'));
        }
        if(countMap.containsKey('Actionable')) {
        	wrapperObj.actionable = countMap.get('Actionable');
        } else {
        	wrapperObj.actionable = 0;
        }
        if(countMap.containsKey('Information')) {
        	wrapperObj.activity = countMap.get('Information');
        } else {
        	wrapperObj.activity = 0;
        }
    	return wrapperObj;
	}
	
	public String createNotification(Map<String, String> requestMap) {
		PeopleDao peopleDaoObj = new PeopleDao();
		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();   
        App_Notification__c noti = new App_Notification__c();
        
		noti.Object_Type__c = 'External';
		noti.Category__c = 'External';
		noti.External_Id__c = requestMap.get('externalid');
		noti.Type__c = 'Actionable'.equalsIgnoreCase(requestMap.get('notificationType')) ? 'Actionable' : 'Information';
		noti.External_URL__c = requestMap.get('url');
		noti.Submitter_Comment__c = requestMap.get('comment');
        noti.Sub_Type__c = requestMap.get('subType');
        noti.Object_Id__c = requestMap.get('surveyId');

        fieldList.add(App_Notification__c.Object_Type__c);
        fieldList.add(App_Notification__c.Category__c);
        fieldList.add(App_Notification__c.External_Id__c);
        fieldList.add(App_Notification__c.Type__c);
        fieldList.add(App_Notification__c.External_URL__c);
        fieldList.add(App_Notification__c.Submitter_Comment__c);
        fieldList.add(App_Notification__c.Sub_Type__c);
        fieldList.add(App_Notification__c.Object_Id__c);
        

		Map<String, People__c> pplMap = peopleDaoObj.findPeopleByValue(requestMap.get('propertyName'),
											new Set<String>{ requestMap.get('sentTo'), 
															requestMap.get('sentBy'),
															requestMap.get('actionBy')
											});

		if(pplMap.get(requestMap.get('sentBy')) == null || pplMap.get(requestMap.get('sentTo')) == null) {
			throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());

		} else if(!UserInfo.getUserId().equalsIgnoreCase(pplMap.get(requestMap.get('sentBy')).User__c) && 
					!UserContext.isUserAppModerator) {
			throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
		}

		noti.Sent_By__c = pplMap.get(requestMap.get('sentBy')).id;
		noti.Sent_To__c = pplMap.get(requestMap.get('sentTo')).id;
		noti.Created_DateTime__c = DateTime.now();

        fieldList.add(App_Notification__c.Sent_By__c);
        fieldList.add(App_Notification__c.Sent_To__c);
        fieldList.add(App_Notification__c.Created_DateTime__c);

		if(requestMap.get('actionBy') != null && !String.isBlank(requestMap.get('actionBy'))) {
			noti.Action_By__c = pplMap.get(requestMap.get('actionBy')).id;
            fieldList.add(App_Notification__c.Action_By__c);
		}

        List<App_Notification__c> notiList = new List<App_Notification__c>{noti};

        if( !notiList.isEmpty() ) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(notiList, fieldList);
            noti = (App_Notification__c)(result.getInsertedObjects()[0]);
        }
        
		return noti.id;
	}

	public void markAsActioned(String notificationId, Map<String, Object> requestMap) {
		PeopleDao peopleDaoObj = new PeopleDao();
		List<App_Notification__c> notiList = [Select id, CreatedById, Object_Type__c, Action_By__c from App_Notification__c WHERE Id = :notificationId AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
		if(notiList.isEmpty()) {
			throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());

		} else if(!'External'.equalsIgnoreCase(notiList[0].Object_Type__c) && 
				  !UserContext.isUserAppModerator) {
			throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());

		} else if(notiList[0].Action_By__c != null) {
			throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
			
		}
		App_Notification__c noti = new App_Notification__c();
		noti.id = notificationId;

		if(requestMap.get('actionBy') != null) {
			String actionedBy = (String) requestMap.get('actionBy');
			Map<String, People__c> pplMap = peopleDaoObj.findPeopleByValue((String) requestMap.get('propertyName'),
											new Set<String>{
												actionedBy
											});
			if(pplMap.get(actionedBy) == null) {
				throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
			} 
			noti.Action_By__c = pplMap.get(actionedBy).id;
		}
		noti.Is_New__c = false;
		noti.Is_Read__c = true;
		noti.Action_On__c = Utility.momentJSDateTimeStringToDateTime((String)requestMap.get('actionAt'));
        noti.Is_Deleted__c = false;
		if(requestMap.get('isDeleted') != null) {
			noti.Is_Deleted__c = Boolean.valueOf(requestMap.get('isDeleted'));
		}
		//update noti;
        List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
            App_Notification__c.Action_By__c,
            App_Notification__c.Is_New__c,
            App_Notification__c.Is_Read__c,
            App_Notification__c.Action_On__c,
            App_Notification__c.Is_Deleted__c
        };

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(new List<App_Notification__c>{noti}), listOfColumnsToBeUpdated);
	}
}