/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public without sharing class FeedUpdatesServer extends DataServer {	
	public override void handleRequest () {

		try {
			String feedType = readParam('Type');
			String pageSize = readParam('pageSize');
			String pageName = readParam('pageName');
			String timeStamp = readParam('timeStamp');
			String subjectId = readParam('subjectId');
			String updatesToken = readParam('updatesToken');
			String feedIdsInViewPort =  readParam('idsInViewPort');
			String feedSortedBy = readParam('sortBy');

            if (!Test.isRunningTest()) {
                timeStamp = String.isBlank(timeStamp) ? String.valueOf(system.now().getTime()) : timeStamp;
                updatesToken = String.isBlank(updatesToken) ? 
                        ('date'.equalsIgnoreCase(feedSortedBy) ? '2:'+ timeStamp : '4:'+ timeStamp) : updatesToken;
            }

            /**Checking feed updates for timeline */
            if (SimpplrContext.feedMode == 'timeline') {
                Boolean isUpdated = checkForFeedUpdatesForTimeLine(timeStamp, 
                        feedType);
                        
                if (isUpdated) {
                    response =  buildResponseWrapper('success', 'Feeds updated', isUpdated);
                    
                } else {
                    response =  buildResponseWrapper('success', 'Feeds not updated', isUpdated);
                }
            
            /**Checking feed update for timeline_comment and full feed */
            } else {
                
                if (feedType.equalsIgnoreCase('record') || feedType.equalsIgnoreCase('userprofile')) {
                    
                    if (subjectId != null && subjectId.startsWith('0F9')) {
                        Boolean isUpdated = checkForFeedUpdatesForSite(subjectId, pageName, timeStamp,
                                feedSortedBy, updatesToken, feedType);
                        
                        if (isUpdated) {
                            response =  buildResponseWrapper('success', 'Feeds updated', isUpdated);
                            
                        } else {
                            response =  buildResponseWrapper('success', 'Feeds not updated', isUpdated);
                        }
                        
                    } else if (subjectId != null && subjectId.startsWith('005')) {
                        Boolean isUpdated = checkForFeedUpdatesForUser(subjectId, pageName, timeStamp,
                                feedSortedBy, updatesToken, feedType);
                        
                        if (isUpdated) {
                            response =  buildResponseWrapper('success', 'Feeds updated', isUpdated);
                            
                        } else {
                            response =  buildResponseWrapper('success', 'Feeds not updated', isUpdated);
                        }
                        
                    } else {
                        Boolean isUpdated = checkForFeedUpdatesForRecord(subjectId, pageName, timeStamp, 
                                feedSortedBy, updatesToken, feedType);
                        
                        if (isUpdated) {
                            response =  buildResponseWrapper('success', 'Feeds updated', isUpdated);
                            
                        } else {
                            response =  buildResponseWrapper('success', 'Feeds not updated', isUpdated);
                        }

                    }
                    
                } else if (feedType.equalsIgnoreCase('company')) {
                    
                    if (subjectId != null) {
                        Boolean isUpdated = checkForFeedUpdatesForCompany(subjectId, pageName, timeStamp,
                                feedSortedBy, updatesToken);
                        
                        if (isUpdated) {
                            response =  buildResponseWrapper('success', 'Feeds updated', isUpdated);
                            
                        } else {
                            response =  buildResponseWrapper('success', 'Feeds not updated', isUpdated);
                        }
                        
                    }
                    
                } else if (feedType.equalsIgnoreCase('news')) {
                    
                    if (subjectId != null && feedIdsInViewPort != null) {
                        List<String> listOfFeedIdsInViewPort = new List<String>();
                        listOfFeedIdsInViewPort = feedIdsInViewPort.split(',', -2);
                        Boolean isUpdated = false;
                        
                        if (!listOfFeedIdsInViewPort.isEmpty()) {
                            isUpdated = checkForFeedUpdatesForNews(subjectId, pageName, 
                                timeStamp, listOfFeedIdsInViewPort, feedSortedBy, updatesToken);
                        } 
                        
                        if (isUpdated) {
                            response =  buildResponseWrapper('success', 'Feeds updated', isUpdated);
                            
                        } else {
                            response =  buildResponseWrapper('success', 'Feeds not updated', isUpdated);
                        }
                        
                    }
                    
                }

            } 

		} catch (Exception e) {
			logger.logError('FeedUpdatesServer.handleRequest()-----could not retrieve data----',e);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

	}
	
	private Boolean checkForFeedUpdatesForNews (String recordIdArg, String pageNameArg, 
			String timeStampArg, List<String> listOfFeedIdsInViewPort, String feedSortedBy, String updatesTokenArg) {
		
		Long longTimeStamp = Long.valueOf(timeStampArg);
		DateTime dTObj = DateTime.newInstance(longTimeStamp);
		String currentUserId = userInfo.getUserID();
		String BASE_QUERY_FOR_GRP = 'Select MemberId, CollaborationRole, CollaborationGroupId From CollaborationGroupMember where MemberId =:currentUserId And CollaborationGroup.IsArchived = false';
		String BASE_QUERY_FOR_ENTITY_SUBSCRIPTION = 'SELECT SubscriberId, ParentId, Id,CreatedById FROM EntitySubscription WHERE SubscriberId=:currentUserId';
		String SUB_CONDITION = ' limit 1000';
		
		// if app_Config.Use_ConnectAPI_for_Feed_Update_Check__c = true then use connect api
		if (SimpplrContext.appConfig.Use_ConnectAPI_for_Feed_Update_Check__c) {
			
			if (String.isNotBlank(updatesTokenArg)) {
				Long updatesTokenMiliSeconds = Long.valueOf(updatesTokenArg.substringAfter(':'));
				String updateTokenPrefix = updatesTokenArg.substringBefore(':');

				if (updatesTokenMiliSeconds < longTimeStamp) {
					updatesTokenArg = updateTokenPrefix + ':' + longTimeStamp;
				}

			}	

			ConnectApi.FeedElementPage feedElementPageObj;
			feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(null, 
					ConnectApi.FeedType.News, 'me', 10, ConnectApi.FeedDensity.AllUpdates, 
					null, null, updatesTokenArg); 
			
			FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
			feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
			
			if (feedElementPageWrapObj.listOfItems.size() > 0) {
				return true;	
			}
			
		} else { // if app_Config.Use_ConnectAPI_for_Feed_Update_Check__c = false 
			
			if (feedSortedBy == 'date') {
				
				Boolean isSuccess = false;
				List<FeedItem> listOfFeedItem = new List<FeedItem >();
				List<CollaborationGroupMember> listOfCollabGroupMem = new List<CollaborationGroupMember>();
				
				if (SimpplrContext.isCommunitiesEnabled) {
		    		BASE_QUERY_FOR_GRP = BASE_QUERY_FOR_GRP+' and CollaborationGroup.NetworkId = null';
		    	}

		    	listOfCollabGroupMem = Database.query(BASE_QUERY_FOR_GRP);
				List<Id> listOfGroupIdLoggedInUserMember = new List<Id>();
				
				if (!listOfCollabGroupMem.isEmpty()) {
					
					for (CollaborationGroupMember collabGrpMemObj : listOfCollabGroupMem) {
						listOfGroupIdLoggedInUserMember.add(collabGrpMemObj.CollaborationGroupId);
					}
					
					if (!listOfGroupIdLoggedInUserMember.isEmpty()) {
						listOfFeedItem = new List<FeedItem >();
						listOfFeedItem = [SELECT ParentId, Id, CreatedDate FROM FeedItem WHERE 
								CreatedDate >:dTObj AND ParentId IN:listOfGroupIdLoggedInUserMember limit 1]; 
						
						if (!listOfFeedItem.isEmpty()) {
							return true;
							
						} 
					
					}
					
				}
				
				List<EntitySubscription> listOfEntitySubscription = new List<EntitySubscription>();
				
                if (SimpplrContext.isCommunitiesEnabled) {
		    		BASE_QUERY_FOR_ENTITY_SUBSCRIPTION = BASE_QUERY_FOR_ENTITY_SUBSCRIPTION+' and NetworkId = null';
		    	}

		    	BASE_QUERY_FOR_ENTITY_SUBSCRIPTION += SUB_CONDITION;
		    	listOfEntitySubscription = Database.query(BASE_QUERY_FOR_ENTITY_SUBSCRIPTION);
				List<Id> listOfUserIdFollowed = new List<Id>();
				
				if (!listOfEntitySubscription.isEmpty()) {
					
					for (EntitySubscription entitySubsObj : listOfEntitySubscription) {
						
						if (entitySubsObj.ParentId != null && String.valueOf(entitySubsObj.ParentId).startsWith('005')) {
							listOfUserIdFollowed.add(entitySubsObj.ParentId);
						}
						
					}
					
				}
				
				if (!listOfUserIdFollowed.isEmpty()) {
					listOfFeedItem = new List<FeedItem >();
					listOfFeedItem = [SELECT ParentId, Id, CreatedDate FROM FeedItem WHERE
							CreatedDate >:dTObj AND ParentId IN:listOfUserIdFollowed limit 1]; 
					
					if (!listOfFeedItem.isEmpty()) {
						return true;
						
					} 
					
				}

			} else {
				Boolean isSuccess = false;
				List<FeedItem> listOfFeedItem = [SELECT ID, LastModifiedDate 
                        FROM FeedItem 
						WHERE LastModifiedDate >:dTObj AND Id IN :listOfFeedIdsInViewPort];
				
                if (!listOfFeedItem.isEmpty()) {
					return true;
					
				} else {
					List<CollaborationGroupMember> listOfCollabGroupMem = new List<CollaborationGroupMember>();
					
                    if (SimpplrContext.isCommunitiesEnabled) {
			    		BASE_QUERY_FOR_GRP = BASE_QUERY_FOR_GRP + ' and CollaborationGroup.NetworkId = null';
			    	}

			    	listOfCollabGroupMem = Database.query(BASE_QUERY_FOR_GRP);
							
					List<Id> listOfGroupIdLoggedInUserMember = new List<Id>();
					
					if (!listOfCollabGroupMem.isEmpty()) {
						
						for (CollaborationGroupMember collabGrpMemObj : listOfCollabGroupMem) {
							listOfGroupIdLoggedInUserMember.add(collabGrpMemObj.CollaborationGroupId);
						}
						
						if (!listOfGroupIdLoggedInUserMember.isEmpty()) {
							listOfFeedItem = new List<FeedItem >();
							listOfFeedItem = [SELECT ParentId, Id FROM FeedItem WHERE LastModifiedDate >:dTObj 
									AND ParentId IN:listOfGroupIdLoggedInUserMember limit 1]; 
							
							if (!listOfFeedItem.isEmpty()) {
								return true;
								
							} 
						
						}
						
					}
						
					List<EntitySubscription> listOfEntitySubscription = new List<EntitySubscription>();
					
                    if (SimpplrContext.isCommunitiesEnabled){
			    		BASE_QUERY_FOR_ENTITY_SUBSCRIPTION = BASE_QUERY_FOR_ENTITY_SUBSCRIPTION+' and NetworkId = null';
			    	}

			    	BASE_QUERY_FOR_ENTITY_SUBSCRIPTION += SUB_CONDITION;
			    	listOfEntitySubscription = Database.query(BASE_QUERY_FOR_ENTITY_SUBSCRIPTION);
					List<Id> listOfUserIdFollowed = new List<Id>();
					
					if (!listOfEntitySubscription.isEmpty()) {
						
						for (EntitySubscription entitySubsObj : listOfEntitySubscription) {
							
							if (entitySubsObj.ParentId != null && String.valueOf(entitySubsObj.ParentId).startsWith('005')) {
								listOfUserIdFollowed.add(entitySubsObj.ParentId);
							}
							
						}
						
					}
					
					if (!listOfUserIdFollowed.isEmpty()) {
						listOfFeedItem = new List<FeedItem >();
						listOfFeedItem = [SELECT ParentId, Id FROM FeedItem WHERE LastModifiedDate >:dTObj 
								AND ParentId IN:listOfUserIdFollowed limit 1]; 
						
						if (!listOfFeedItem.isEmpty()) {
							return true;
							
						} 
						
					}
					
				}
				
			}
			
		}
		
		return false;
	}
	
	private Boolean checkForFeedUpdatesForCompany (String recordIdArg, String pageNameArg, 
			String timeStampArg, String feedSortedBy, String updatesTokenArg) {
		Long longTimeStamp = Long.valueOf(timeStampArg);
		DateTime dTObj = DateTime.newInstance(longTimeStamp);
		List<FeedItem> listOfFeedItem = new List<FeedItem>();
		// if app_Config.Use_ConnectAPI_for_Feed_Update_Check__c = true then use connect api

		if (SimpplrContext.appConfig.Use_ConnectAPI_for_Feed_Update_Check__c) {
			
			if (String.isNotBlank(updatesTokenArg)) {
				Long updatesTokenMiliSeconds = Long.valueOf(updatesTokenArg.substringAfter(':'));
				String updateTokenPrefix = updatesTokenArg.substringBefore(':');
				
                if (updatesTokenMiliSeconds < longTimeStamp) {
					updatesTokenArg = updateTokenPrefix + ':' + longTimeStamp;
				}

			}
			
			ConnectApi.FeedElementPage feedElementPageObj;
			feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(null, 
					ConnectApi.FeedType.Company, null, ConnectApi.FeedDensity.AllUpdates, null,null, updatesTokenArg);
			
			
			FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
			feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
			
			if (feedElementPageWrapObj.listOfItems.size() > 0) {
				return true;

			} else {
				return false;
			}
			
		} else {

			if (feedSortedBy == 'date') {
				 listOfFeedItem = [SELECT ID, CreatedDate FROM FeedItem 
						WHERE CreatedDate >:dTObj limit 1]; 
				
				if (!listOfFeedItem.isEmpty()) {
					return true;
					
				} else {
					return false;
				}
				
			} else {
				listOfFeedItem = [SELECT ID,LastModifiedDate FROM FeedItem 
						WHERE LastModifiedDate >:dTObj limit 1]; 
				
				if (!listOfFeedItem.isEmpty()) {
					return true;
					
				} else {
					return false;
				}
				
			}

		}

	}
	
	private Boolean checkForFeedUpdatesForRecord (String recordIdArg, String pageNameArg, 
			String timeStampArg, String feedSortedBy, String updatesTokenArg, String feedTypeArg) {
		Long longTimeStamp = Long.valueOf(timeStampArg);
		DateTime dTObj = DateTime.newInstance(longTimeStamp);
		List<Simpplr_Content__c> listOfSimpplrContent = new List<Simpplr_Content__c>();
		
		// if app_Config.Use_ConnectAPI_for_Feed_Update_Check__c = true then use connect api
		if (SimpplrContext.appConfig.Use_ConnectAPI_for_Feed_Update_Check__c) {
			
			return getFeedUpdatedSince (recordIdArg, timeStampArg, updatesTokenArg, feedTypeArg);
			
		} else {

			if (feedSortedBy == 'date') {
				listOfSimpplrContent = [SELECT ID, 
					(SELECT ID,CreatedDate FROM Feeds WHERE CreatedDate >:dTObj limit 1)
					FROM Simpplr_Content__c WHERE Id=:recordIdArg]; 
				
				if (!listOfSimpplrContent.isEmpty() && !listOfSimpplrContent[0].Feeds.isEmpty()) {
					return true;
					
				} else {
					return false;
				}
			
			} else {
				listOfSimpplrContent = [SELECT ID, 
					(SELECT ID,LastModifiedDate FROM Feeds WHERE LastModifiedDate >:dTObj limit 1)
					FROM Simpplr_Content__c WHERE Id=:recordIdArg]; 
				
				if (!listOfSimpplrContent.isEmpty() && !listOfSimpplrContent[0].Feeds.isEmpty()) {
					return true;
					
				} else {
					return false;
				}

			}

		}

	}
	
	private Boolean checkForFeedUpdatesForSite (String recordIdArg, String pageNameArg, 
			String timeStampArg, String feedSortedBy, String updatesTokenArg, String feedTypeArg) {
		Long longTimeStamp = Long.valueOf(timeStampArg);
		DateTime dTObj = DateTime.newInstance(longTimeStamp);
		List<CollaborationGroup > listOfSimpplrSite = new List<CollaborationGroup >();
		// if app_Config.Use_ConnectAPI_for_Feed_Update_Check__c = true then use connect api

		if (SimpplrContext.appConfig.Use_ConnectAPI_for_Feed_Update_Check__c) {
			return getFeedUpdatedSince (recordIdArg, timeStampArg, updatesTokenArg, feedTypeArg);
			
		} else {
			String BASE_QUERY= 'Select Id';
			String BASE_FROM_WHERE = 'From CollaborationGroup where Id = :recordIdArg ';
			
            if (feedSortedBy == 'date') {
				BASE_QUERY = BASE_QUERY+', (Select ID,CreatedDate FROM Feeds where  CreatedDate >:dTObj limit 1) ';
				
				if (SimpplrContext.isCommunitiesEnabled) {
		    		BASE_FROM_WHERE = BASE_FROM_WHERE+'AND NetworkId = null';
		    	}

				String queryStr=BASE_QUERY+BASE_FROM_WHERE;
				
				listOfSimpplrSite = Database.query(queryStr);
				
				if (!listOfSimpplrSite.isEmpty() && !listOfSimpplrSite[0].Feeds.isEmpty()) {
					return true;
					
				} else {
					return false;
				}
				
			} else {
				BASE_QUERY = BASE_QUERY + ', (Select ID,LastModifiedDate FROM Feeds where  LastModifiedDate >:dTObj limit 1) ';
				
                if (SimpplrContext.isCommunitiesEnabled) {
		    		BASE_FROM_WHERE = BASE_FROM_WHERE+'AND NetworkId = null';
		    	}

				String queryStr=BASE_QUERY+BASE_FROM_WHERE;
				listOfSimpplrSite = Database.query(queryStr); 
				
				if (!listOfSimpplrSite.isEmpty() && !listOfSimpplrSite[0].Feeds.isEmpty()) {
					return true;
					
				} else {
					return false;
				}

			}

		}

	}
	
	private Boolean checkForFeedUpdatesForUser (String recordIdArg, String pageNameArg, 
			String timeStampArg, String feedSortedBy, String updatesTokenArg, String feedTypeArg) {
		Long longTimeStamp = Long.valueOf(timeStampArg);
		DateTime dTObj = DateTime.newInstance(longTimeStamp);
		List<User> listOfUser = new List<User >();
		
		// if app_Config.Use_ConnectAPI_for_Feed_Update_Check__c = true then use connect api
		if (SimpplrContext.appConfig.Use_ConnectAPI_for_Feed_Update_Check__c) {
			
			return getFeedUpdatedSince (recordIdArg, timeStampArg, updatesTokenArg, feedTypeArg);
			
		} else {
		
			if (feedSortedBy == 'date') {
				listOfUser = [SELECT ID, (SELECT ID, CreatedDate FROM Feeds 
						WHERE CreatedDate >:dTObj limit 1)
						FROM User WHERE Id=:recordIdArg]; 
				
				if (!listOfUser.isEmpty() && !listOfUser[0].Feeds.isEmpty()) {
					return true;
					
				} else {
					return false;
				}
				
			} else {
				listOfUser = [SELECT ID, (SELECT ID,LastModifiedDate FROM Feeds 
						WHERE LastModifiedDate >:dTObj limit 1)
						FROM User WHERE Id=:recordIdArg]; 
				
				if (!listOfUser.isEmpty() && !listOfUser[0].Feeds.isEmpty()) {
					return true;
					
				} else {
					return false;
				}

			}

		}

	}
	
	@TestVisible 
    private Boolean getFeedUpdatedSince (String recordIdArg, String timeStampArg, 
            String updatesTokenArg, String feedTypeArg) {
		ConnectApi.FeedElementPage feedElementPageObj;
		Long longTimeStamp = Long.valueOf(timeStampArg);
		
		if (String.isNotBlank(updatesTokenArg)) {
			Long updatesTokenMiliSeconds = Long.valueOf(updatesTokenArg.substringAfter(':'));
			String updateTokenPrefix = updatesTokenArg.substringBefore(':');

			if (updatesTokenMiliSeconds < longTimeStamp) {
				updatesTokenArg = updateTokenPrefix + ':' + longTimeStamp;
			}

		}
			
		if ('Record'.equalsIgnoreCase(feedTypeArg) && recordIdArg != null) {

			if ( recordIdArg.startsWith('0F9')) {
				feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(null, 
					    ConnectApi.FeedType.Groups, recordIdArg, 10, 
                        ConnectApi.FeedDensity.AllUpdates, null, null, updatesTokenArg); 
			
            } else if (recordIdArg.startsWith('005')) {
				feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(null, 
					    ConnectApi.FeedType.People, recordIdArg, 10, 
                        ConnectApi.FeedDensity.AllUpdates, null, null, updatesTokenArg); 

			} else {
				feedElementPageObj = ConnectApi.ChatterFeeds.getFeedElementsUpdatedSince(null, 
					    ConnectApi.FeedType.Record, recordIdArg, 10, 
                        ConnectApi.FeedDensity.AllUpdates, null, null, updatesTokenArg); 
			}
			
		}
		
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
		
		if (feedElementPageWrapObj.listOfItems.size() > 0) {
			return true;	
		}

		return false;
	}

    @testVisible
    private Boolean checkForFeedUpdatesForTimeLine(String timeStampArg, String feedTypeArg) {
        List<Simpplr_Content__Feed> listOfSimpContentFeed = new List<Simpplr_Content__Feed>();
        Set<Id> chatterGroupsIFollowIdSet = UserContext.chatterGroupsIFollowIdSet;
        Long longTimeStamp = Long.valueOf(timeStampArg);
		DateTime dTObj = DateTime.newInstance(longTimeStamp);

        /**I follow case*/
        if (feedTypeArg == 'news') {
             List<Simpplr_Content__c> listOfContent = [SELECT id, site__r.Chatter_Group_Id__c 
                    FROM Simpplr_Content__c 
                    WHERE site__r.Chatter_Group_Id__c IN: chatterGroupsIFollowIdSet];
            listOfSimpContentFeed = [SELECT id, parentId, type, CreatedDate  
                    FROM simpplr_content__feed 
                    WHERE type= 'LinkPost' AND parentId IN:listOfContent AND CreatedDate >:dTObj limit 1];

        /**All company case*/
        } else {
            listOfSimpContentFeed = [SELECT id, parentId, type, CreatedDate  
                    FROM simpplr_content__feed 
                    WHERE type= 'LinkPost' AND CreatedDate >:dTObj limit 1];
        }

        if (!listOfSimpContentFeed.isEmpty()) {
            return true;

        } else {
            return false;
        }
        
    }
	
}