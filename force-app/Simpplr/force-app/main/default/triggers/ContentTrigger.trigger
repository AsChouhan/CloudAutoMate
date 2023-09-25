/**
* @Trigger [Trigger Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
trigger ContentTrigger on Simpplr_Content__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
	try {
		CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_TILE);
		CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_CAROUSEL);
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
			if(SimpplrContext.isATSimpplrContentEnabled != null && SimpplrContext.isATSimpplrContentEnabled) {

				ObjectHandler objHandler = new ObjectHandler();
				objHandler.triggerHandler('Simpplr_Content__c');
				
				if (Trigger.isBefore) {	
					if(Trigger.isUpdate){
						DateTime currentTime = DateTime.now();
						for(Simpplr_Content__c contentObj : Trigger.new){
							contentObj.Display_Excerpt__c = Utility.getDisplayExcerpt(contentObj.Excerpt__c,contentObj.Summary_1__c);
							if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c) && 
								(contentObj.First_Publish_DateTime__c == null || contentObj.First_Publish_DateTime__c > currentTime)) {
					        	contentObj.First_Publish_DateTime__c = contentObj.Publish_Start_DateTime__c > contentObj.Last_Edited_DateTime__c ? contentObj.Publish_Start_DateTime__c : contentObj.Last_Edited_DateTime__c;
					        }
						}
					}
					if(Trigger.isInsert){
						for(Simpplr_Content__c contObj: Trigger.new ){
							contObj.Version__c = 1;
							contObj.Display_Excerpt__c = Utility.getDisplayExcerpt(contObj.Excerpt__c,contObj.Summary_1__c);
							if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contObj.Status__c) && contObj.First_Publish_DateTime__c == null) {
								contObj.First_Publish_DateTime__c = contObj.Publish_Start_DateTime__c > contObj.Last_Edited_DateTime__c ? contObj.Publish_Start_DateTime__c : contObj.Last_Edited_DateTime__c;
							}
						}	
					}
					
					if (Trigger.isDelete){ 
						List<App_Notification__c> listOfSimpplrNotification;
						try{
							
							listOfSimpplrNotification = [select id from App_Notification__c WHERE Is_Deleted__c = false AND Object_Id__c IN :Trigger.oldMap.keyset()];
							for(App_Notification__c notificationObj: listOfSimpplrNotification){
								notificationObj.Is_Deleted__c = true;
							}
							if(listOfSimpplrNotification.size() > 0) {
								SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
								SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Notification__c>(listOfSimpplrNotification), new List<Schema.SObjectField>{App_Notification__c.Is_Deleted__c});
							}
							
						}catch(DmlException e){
							for(App_Notification__c notification : listOfSimpplrNotification){
								notification.addError('There was a problem while deleting the Simpplr Notification. '+ 
														'Please contact the System Administrator');
							}
						}
					}
				}

				if (Trigger.isAfter) {
					
					if (Trigger.isInsert) {
						List<Simpplr_Content__c> listOfSimpplrContents = [select id, Type__c, Site__c, site__r.chatter_group_id__c, site__r.Site_type__c from Simpplr_Content__c where id=:Trigger.newMap.keySet()];
						Utility.createSimpplrContentShareRecords(listOfSimpplrContents);

						if(SimpplrContext.aiRelatedContentEnabled) {
							Set<Id> contentIds = new Set<Id>();

							//add content id's to pust published data for AI recommendation
							for(Simpplr_Content__c content:Trigger.new){
								if(content.Is_Published__c){
									contentIds.add(content.Id);
								}
							}
							//Push Content for AI processing
							if(contentIds.size() > 0){
								ContentTriggerHandler.pushContentForAIRecommendation(contentIds);
							}
						}
					}

					if (Trigger.isUpdate) {

						if(Utility.isContentEditFromContentDetailPage == false){
							List<String> listOfContentIds = new List<String>();
							List<Simpplr_Content__Feed> listOfFeedItem = new List<Simpplr_Content__Feed>();
							List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();
							
							for(Simpplr_Content__c contentObj : Trigger.new){
								if(contentObj.is_Deleted__c) {
									listOfContentIds.add(contentObj.id);
								}
	
								Boolean isLastValidatedDateUpdated = false;
								if( 'knowledge'.equalsIgnoreCase(Trigger.newMap.get(contentObj.id).Content_Sub_Type__c)
										&& ((Trigger.newMap.get(contentObj.id).Last_Validated_DateTime__c != null &&  Trigger.oldMap.get(contentObj.id).Last_Validated_DateTime__c == null)
										|| Trigger.newMap.get(contentObj.id).Last_Validated_DateTime__c > Trigger.oldMap.get(contentObj.id).Last_Validated_DateTime__c) ) {
									
									isLastValidatedDateUpdated = true;
								}
	
								if(SimpplrContext.isExternalSearchAppConnected && Trigger.oldMap.containsKey(contentObj.id)
										&& (((Trigger.newMap.get(contentObj.id).Last_Edited_DateTime__c) > (Trigger.oldMap.get(contentObj.id).Last_Edited_DateTime__c))
										|| isLastValidatedDateUpdated)) {
	
									External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
									obj.Content__c = contentObj.id;
									obj.Type__c = 'Content';
									listToInsert.add(obj);
								}
							}
	
							if(listToInsert.size()>0){
								insert listToInsert;
							}
							
							if(listOfContentIds.isEmpty() == false) {
								listOfFeedItem =[SELECT Id,ParentId FROM Simpplr_Content__Feed WHERE ParentId IN : listOfContentIds];
																				
								if(listOfFeedItem.isEmpty() == false) {
									SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
									SIMPESAPI.accessController().deleteAsUser(listOfFeedItem);
								}
							}
						}
												
						if(SimpplrContext.aiRelatedContentEnabled && !System.isBatch()) {
							Set<Id> contentIds = new Set<Id>();
							Set<Id> contentIdsToRemove = new Set<Id>();

							//add content id's to take action for AI recommendation
							for(Simpplr_Content__c content:Trigger.new){
								if( content.Is_Published__c && ( 
										Trigger.oldMap.get(content.Id).Is_Published__c != content.Is_Published__c || 
										Trigger.oldMap.get(content.Id).Text_Intro__c != content.Text_Intro__c || 
										Trigger.oldMap.get(content.Id).Title__c != content.Title__c || 
										Trigger.oldMap.get(content.Id).Site__c != content.Site__c || 
										Trigger.oldMap.get(content.Id).Site__r.Site_Type__c != content.Site__r.Site_Type__c ||
										Trigger.oldMap.get(content.Id).Type__c != content.Type__c || 
										Trigger.oldMap.get(content.Id).Pages_Category__r.Name__c != content.Pages_Category__r.Name__c || 
										Trigger.oldMap.get(content.Id).Publish_End_DateTime__c != content.Publish_End_DateTime__c
									))
								{
									contentIds.add(content.Id);
								}

								if((content.Is_deleted__c && Trigger.oldMap.get(content.Id).Is_deleted__c != content.Is_deleted__c) || 
									(!content.Is_Published__c && ( 
										Trigger.oldMap.get(content.Id).Is_Published__c != content.Is_Published__c))
								)
								{
									contentIdsToRemove.add(content.Id);
								}
							}

							//Push Content for AI processing
							if(contentIds.size() > 0){
								ContentTriggerHandler.pushContentForAIRecommendation(contentIds);
							}

							//Remove Content form AI server
							if(!test.isRunningTest() && contentIdsToRemove.size() > 0){
								ContentTriggerHandler.removeContentFromAIServer(contentIdsToRemove);
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