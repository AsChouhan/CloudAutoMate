trigger FeedCommentTrigger on FeedComment (after insert, after update, after delete, after undelete) {
	try {
		
		if (String.isBlank(SimpplrContext.packageName) || 
				UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
					
			if (SimpplrContext.isATFeedCommentEnabled) {
				
				if (SimpplrContext.isFeedEnabled != null && SimpplrContext.isFeedEnabled){
					
					ObjectHandler objHandler = new ObjectHandler();
					objHandler.triggerHandler('FeedComment');
					
					if (Trigger.isAfter) { 
						
						String simpplrCntntObjectPrefix = Utility.getSimpplrContentPrefix();
						if (Trigger.isInsert) {
						
							if (!Test.isRunningTest() && trigger.new.size() == 1 ) {
								for (FeedComment newFeedCommentObj : Trigger.new) {
									if(!ServiceConstants.FEED_COMMENT_BODY_PLACEHOLDER.equalsIgnoreCase(newFeedCommentObj.commentBody)) {       	
										NotificationDispatcher.sendFeedCommentNotificationsAndEmail(trigger.new);
									}
									break;
								}
							}
							if (trigger.new.size() == 1) {
								Set<Id> setOfNewCommentparentId = new set<Id>();
								
								for (FeedComment  newFeedCommentObj : Trigger.new) {
									if(String.valueOf(newFeedCommentObj.ParentId).startsWithIgnoreCase(simpplrCntntObjectPrefix)){
										setOfNewCommentparentId.add(newFeedCommentObj.ParentId);
									}
								}
								
								if (!setOfNewCommentparentId.isEmpty()) {
									List<Simpplr_content__c> listOfSimpplrContent =  [SELECT Id, Feed_Comments__c  
											FROM Simpplr_Content__c WHERE Id IN: setOfNewCommentparentId
											limit 50000]; 
									
									if (!listOfSimpplrContent.isEmpty()) {
										
										for (Integer i =0; i < listOfSimpplrContent.size(); i++) {
											listOfSimpplrContent[i].Feed_Comments__c = listOfSimpplrContent[i].Feed_Comments__c + 1 ;
										}
										update listOfSimpplrContent;
									}
								}
								
								// create File__c record for Files uploaded in FeedComments (belonging to Site / Site-content)
					        		FileDao.createFileRecords4FeedComments(Trigger.new);
							}
						}
						
						if (Trigger.isDelete) {
							
							if (!Test.isRunningTest()) {
								//NotificationDispatcher.updateSimpplrMetadaRecords(trigger.old);
							}
							if (trigger.old.size() == 1) {
								Set<Id> setOfNewCommentparentId = new set<Id>();
							
								for (FeedComment  newFeedCommentObj : Trigger.old) {
									if(String.valueOf(newFeedCommentObj.ParentId).startsWithIgnoreCase(simpplrCntntObjectPrefix)){
										setOfNewCommentparentId.add(newFeedCommentObj.ParentId);
									}
								}
								
								if (!setOfNewCommentparentId.isEmpty()) {
									List<Simpplr_content__c> listOfSimpplrContent =  [SELECT Id, Feed_Comments__c  
											FROM Simpplr_Content__c WHERE Id IN: setOfNewCommentparentId
											limit 50000]; 
									
									if (!listOfSimpplrContent.isEmpty()) {
										
										for (Integer i =0; i < listOfSimpplrContent.size(); i++) {
											
											if (listOfSimpplrContent[i].Feed_Comments__c > 0) {
												listOfSimpplrContent[i].Feed_Comments__c = listOfSimpplrContent[i].Feed_Comments__c - 1 ;
											}
										}
										update listOfSimpplrContent;
									}
								}
							}
							for (FeedComment oldFeedCommentObj : Trigger.old) {
								NotificationHelper.deleteFeedCommentCache(oldFeedCommentObj.id);
								break;
							}
						}
						
						if (Trigger.isUpdate) {
				        	if(Trigger.old.size() == 1) {
								for (FeedComment oldFeedCommentObj : Trigger.old) {
									// send notification for slack msg
									if(ServiceConstants.FEED_COMMENT_BODY_PLACEHOLDER.equalsIgnoreCase(oldFeedCommentObj.CommentBody)) {
										Id sentByUserId = oldFeedCommentObj.CreatedById;
										Boolean isUpdatingPlaceholderFeed = true;
										NotificationDispatcher.sendFeedCommentNotificationsAndEmail(trigger.new, sentByUserId, isUpdatingPlaceholderFeed);
									} else {
										NotificationHelper.updateFeedCommentCache(oldFeedCommentObj.id,oldFeedCommentObj.FeedItemId);
									}
								}
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