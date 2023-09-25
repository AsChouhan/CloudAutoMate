trigger FeedItemTrigger on FeedItem (after insert, after update, after delete, after undelete) {
	try {
		
		if (String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
			
			if (SimpplrContext.isATFeedItemEnabled) {
				
				if (SimpplrContext.isFeedEnabled != null && SimpplrContext.isFeedEnabled) {
				    if (Trigger.isAfter) {
				    	String simpplrCntntObjectPrefix = Utility.getSimpplrContentPrefix();
				    	if(SimpplrContext.isExternalDataSyncEnabled 
							&& (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete)){
								
								Boolean isSaveExternalDataTrail = false;
								List<FeedItem> feeditemList= Trigger.new != null ? Trigger.new : Trigger.old;
								for(FeedItem feedItemObj : feeditemList){

									if(feedItemObj != null && feedItemObj.ParentId != null){

										String parentId = String.valueOf(feedItemObj.ParentId);
										if(parentId.startsWith('005') || parentId.startsWith('0F9') || parentId.startsWith(simpplrCntntObjectPrefix)){
											isSaveExternalDataTrail = true;

											break;
										}
									}
								}
								if(isSaveExternalDataTrail){
									ObjectHandler objHandler = new ObjectHandler();
									objHandler.triggerHandler('FeedItem');
								}
				    	}

				        if (Trigger.isInsert) {
							String source = null;
							if (trigger.new.size() == 1) {

								for(FeedItem feedItemobj : trigger.new){
									ConnectApi.FeedElement feedObject = NotificationHelper.getFeedElementObject(feedItemobj.Id);
									ConnectAPI.FeedItem feedItemCastedObj = (ConnectApi.FeedItem)feedObject;
									if (feedItemobj.body != null && (feedItemobj.body.contains(ServiceConstants.RECOGNITION_FILE_SEPRATOR) || feedItemobj.body.contains(ServiceConstants.FEED_BODY_PLACEHOLDER)) && feedItemCastedObj.originalFeedItem == null) { // Suppress unwanted notifications for external source feed creation
										source = 'external-source-feed';

										break;
									}
								}
							}
                            if (!Test.isRunningTest() && trigger.new.size() == 1 && !'external-source-feed'.equalsIgnoreCase(source)) {
								
								FeedItem feedItemDataObj = null;
								for(FeedItem feedItemobj : trigger.new){
									
									if(!(feedItemobj.ParentId != null  
										&& String.valueOf(feedItemobj.ParentId).startswith(Utility.getSimpplrContentPrefix())
										&& feedItemobj.Type == 'LinkPost')){

											feedItemDataObj = feedItemobj;

											break;
									}
								}      
                                if (SimpplrContext.isCommunitiesEnabled && feedItemDataObj != null) {
				        			String jsonData = JSON.serialize(feedItemDataObj);
				        			Map<String, Object> feedItemData = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
				        			
                                    if (feedItemData.get('NetworkScope') == null || String.valueOf(feedItemData.get('NetworkScope')).equalsIgnoreCase('AllNetworks')){
				        				NotificationDispatcher.sendFeedItemNotificationsAndEmail(trigger.new, null);
				        			} 

				        		} else {
				        			NotificationDispatcher.sendFeedItemNotificationsAndEmail(trigger.new, null);
				        		}

				        	}
				        	
				        	if (trigger.new.size() == 1) {
					        	Set<Id> setOfNewFeedItemsParentId = new set<Id>();
					        	List<String> siteFeedItemIdList = new List<String>();
								List<FeedItem> feedItemList = Trigger.new;
								String parentId ;
								Map<String, Boolean> isQuestionPostMap = new Map<String, Boolean>();
								
								for (FeedItem newFeedItemObj : feedItemList) {
									parentId = newFeedItemObj.ParentId; // will run only once as size remains always =1
									
                                    if (newFeedItemObj.ParentId != null) {
										
                                        if (string.valueOf(newFeedItemObj.ParentId).startsWithIgnoreCase(simpplrCntntObjectPrefix)) {
											
                                            if (newFeedItemObj.type != 'LinkPost') { 
                                                 setOfNewFeedItemsParentId.add(newFeedItemObj.ParentId);
                                            }
											if(String.isNotBlank(newFeedItemObj.Body) && newFeedItemObj.Body.contains(ServiceConstants.QNA_QUESTION_SEPERATOR)) {
												isQuestionPostMap.put(string.valueOf(newFeedItemObj.ParentId), true);
											}
											
                                            if (String.isNotBlank(newFeedItemObj.RelatedRecordId)) {
												siteFeedItemIdList.add(newFeedItemObj.Id);
											}

										} else if (String.valueOf(newFeedItemObj.ParentId).startsWith('0F9')) {
											
                                            if (String.isNotBlank(newFeedItemObj.RelatedRecordId)) {
												siteFeedItemIdList.add(newFeedItemObj.Id);
											}	

										}

									}

								}
								
								if (!setOfNewFeedItemsParentId.isEmpty()) {
									List<Simpplr_content__c> listOfSimpplrContent =  [SELECT Id, Feed_Posts__c, Feed_Questions__c  
											FROM Simpplr_Content__c WHERE Id IN: setOfNewFeedItemsParentId
											limit 50000]; 
									
									if (!listOfSimpplrContent.isEmpty()) {
										
										for (Integer i =0; i < listOfSimpplrContent.size(); i++) {
											if(isQuestionPostMap.containsKey(listOfSimpplrContent[i].Id) && isQuestionPostMap.get(listOfSimpplrContent[i].Id)) {
												Decimal questionCount = listOfSimpplrContent[i].Feed_Questions__c;
												listOfSimpplrContent[i].Feed_Questions__c = questionCount != null ? questionCount + 1 : 1;

											} else {
												listOfSimpplrContent[i].Feed_Posts__c = listOfSimpplrContent[i].Feed_Posts__c + 1 ;
											}
										}
										
										update listOfSimpplrContent;
									}

								}
								
								// create File__c record for Files uploaded in FeedItems (belonging to Site / Site-content)
								if (!siteFeedItemIdList.isEmpty()) {
									FileDao.createFileRecords4FeedItems(siteFeedItemIdList,parentId);
								}

				        	}
				        	
				        } else if (Trigger.isDelete) {
				        	
				        	if (trigger.old.size() == 1) {
								Set<Id>setOfNewFeedItemsParentId = new set<Id>();
								Map<String, Boolean> isQuestionPostMap = new Map<String, Boolean>();
								
								FeedItem oldFeedItemObj = null;
                                for (FeedItem newFeedItemObj : Trigger.old){

									oldFeedItemObj = newFeedItemObj;

									if(newFeedItemObj.ParentId != null && string.valueOf(newFeedItemObj.ParentId).startsWithIgnoreCase(simpplrCntntObjectPrefix)){
										setOfNewFeedItemsparentId.add(newFeedItemObj.ParentId);
									}
										

									if(String.isNotBlank(newFeedItemObj.Body) && newFeedItemObj.Body.contains(ServiceConstants.QNA_QUESTION_SEPERATOR)) {
										isQuestionPostMap.put(string.valueOf(newFeedItemObj.ParentId), true);
									}
								}
								
								if (!setOfNewFeedItemsparentId.isEmpty()) {
									List<Simpplr_content__c> listOfSimpplrContent =  [SELECT Id, Feed_Posts__c, Feed_Questions__c  
											FROM Simpplr_Content__c WHERE Id IN: setOfNewFeedItemsparentId
											limit 50000]; 
									
									if (!listOfSimpplrContent.isEmpty()) {
										
										for (Integer i =0; i < listOfSimpplrContent.size(); i++) {
											if(isQuestionPostMap.containsKey(listOfSimpplrContent[i].Id) && isQuestionPostMap.get(listOfSimpplrContent[i].Id)) {
												Decimal questionCount = listOfSimpplrContent[i].Feed_Questions__c;
												listOfSimpplrContent[i].Feed_Questions__c = questionCount > 0 ? questionCount - 1 : 0;

											} else if (listOfSimpplrContent[i].Feed_Posts__c > 0){
												listOfSimpplrContent[i].Feed_Posts__c = listOfSimpplrContent[i].Feed_Posts__c - 1 ;
											}
											
										}

										update listOfSimpplrContent;
									}

								}

								NotificationHelper.deleteFeedItemCache(oldFeedItemObj.id);
								FeedDataAdapter.deleteRecognition(oldFeedItemObj.id); // Delete Related Recognition record If any
				        	}

						} else  if (Trigger.isUpdate) {
				        	
                            if (Trigger.old.size() == 1) {

								FeedItem oldFeedItemObj = null;
								for (FeedItem oldFeedItemObjTemp : Trigger.old){
									oldFeedItemObj = oldFeedItemObjTemp;

									break;
								}
				        		NotificationHelper.updateFeedItemCache(oldFeedItemObj.id);
				        	}

			        	}
				        
				    }
				    
				}
				
			}
			
		}

	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}

}