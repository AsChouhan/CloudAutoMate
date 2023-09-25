trigger SimppplrContentVersionOnAdd on ContentVersion (after insert, before delete, after update, after delete, after undelete) {
	try {
		if(String.isBlank(SimpplrContext.packageName) || UserInfo.isCurrentUserLicensed(SimpplrContext.packageName)) {
	   		if(SimpplrContext.isATContentVersionEnabled != null && SimpplrContext.isATContentVersionEnabled) {
				
				ObjectHandler objHandler = new ObjectHandler();
				objHandler.triggerHandler('ContentVersion');
				
			   if (Trigger.isAfter) { 
					if (Trigger.isInsert) {
					   String orgId = UserInfo.getOrganizationId();
					   
					   List<String> siteIdsList = new List<String>();
					   for(ContentVersion objContentVersion: Trigger.new) {
							String versionNumber = objContentVersion.VersionNumber;
					   		
							if(String.isNotBlank(objContentVersion.PathOnClient) && versionNumber == '1') {	
								if(objContentVersion.PathOnClient.startsWith('simp_cont_') || objContentVersion.PathOnClient.startsWith(ServiceConstants.SITE_LIBRARY_PREFIX)){
									List<String> parts = objContentVersion.PathOnClient.split('#');
									if( !('BlogPost'.equalsIgnoreCase(parts[1])) ) {
										siteIdsList.add(parts[1]);
									}
								}
							}
						}

					   Map<Id, Simpplr_Site__c> siteIdVsSiteObjMap = new Map<Id, Simpplr_Site__c>([SELECT Site_Type__c, Chatter_Group_Id__c FROM Simpplr_Site__c WHERE id =: siteIdsList]);

					   List<ContentVersion> listOfContentVersion = new List<ContentVersion>();
					   List<String> contentDocIdsString = new List<String>();

					   List<File__c> listOfFiles = new List<File__c>();
					   List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
					   List<Simpplr_Content__c> listOfContentsToUpdate = new List<Simpplr_Content__c>();

					   for(ContentVersion objContentVersion: Trigger.new) {
					   		String versionNumber = objContentVersion.VersionNumber;
					   		
					   		// update content_version__c in File__c records 
					   		if(versionNumber != '1') {
								listOfContentVersion.add(objContentVersion);
					   		}
					   		
					   		if(String.isNotBlank(objContentVersion.PathOnClient) && versionNumber != '1') {
					   			if(objContentVersion.PathOnClient.startsWith('simp_cont_attach')) {
					   				List<String> parts = objContentVersion.PathOnClient.split('#');
					   				String siteId = parts[1];
									String pathPrefix = parts[0];
									
									if(pathPrefix.startsWith('simp_cont_attach')) {
										contentDocIdsString.add(objContentVersion.ContentDocumentId);
									}
					   			}
					   		}
					   		else if(String.isNotBlank(objContentVersion.PathOnClient) && versionNumber == '1') {
					   			
					       		if(objContentVersion.PathOnClient.startsWith('simp_cont_') || objContentVersion.PathOnClient.startsWith(ServiceConstants.SITE_LIBRARY_PREFIX)){
				       				List<String> parts = objContentVersion.PathOnClient.split('#');
				       				
				       				if('BlogPost'.equalsIgnoreCase(parts[1])) {
				       					ContentDocumentLink cdLink = new ContentDocumentLink();
							        	cdLink.ContentDocumentId = objContentVersion.ContentDocumentId; 
							        	cdLink.ShareType = 'V';
							        	cdLink.LinkedEntityId = orgId;               
							        	cdlInsert.add(cdLink);
				       				} else {
										String pathPrefix = parts[0];
										String siteId = parts[1];
										
										if(siteIdVsSiteObjMap.containsKey(siteId)) {
											Simpplr_Site__c siteObj = siteIdVsSiteObjMap.get(siteId);
											String groupId = siteObj.chatter_Group_id__c;
											String siteType = siteObj.Site_Type__c;
											
											// Create CDLs if file is not content cover/inline/attachment image
											if( !((pathPrefix.startsWith('simp_cont_original')) || (pathPrefix.startsWith('simp_cont_cropped')) 
													|| (pathPrefix.startsWith('simp_cont_attach')) || (pathPrefix.startsWith('simp_cont_inline'))
													|| (pathPrefix.startsWith('simp_cont_album')) ) ) {
												
												if('Public'.equalsIgnoreCase(siteType)) {
													ContentDocumentLink cdLink2 = new ContentDocumentLink();
													cdLink2.ContentDocumentId = objContentVersion.ContentDocumentId; 
													cdLink2.ShareType = 'V';
													cdLink2.LinkedEntityId = groupId;               
													cdlInsert.add(cdLink2);
												} else {
													ContentDocumentLink cdLink = new ContentDocumentLink();
													cdLink.ContentDocumentId = objContentVersion.ContentDocumentId; 
													cdLink.ShareType = 'C';
													cdLink.LinkedEntityId = groupId;               
													cdlInsert.add(cdLink);
												}
											}
											
											
											if(parts.size() == 4 && objContentVersion.PathOnClient.startsWith(ServiceConstants.SITE_LIBRARY_PREFIX)) {
												File__c fileObj = new File__c();
												fileObj.Content_Version__c = objContentVersion.Id;
												fileObj.Url__c = Utility.getFileDownloadURL(objContentVersion.Id);
												fileObj.Thumbnail_URL__c = Utility.getFileDownloadURLFor720By480(objContentVersion.Id);
												if(String.isNotBlank(parts[2])) {
													fileObj.Folder__c = parts[2];
												}
												if(String.isNotBlank(parts[1])) {
													fileObj.Site__c = parts[1];
												}
												fileObj.Content_Document__c = objContentVersion.ContentDocumentId;
												fileObj.Content_Name__c = parts[3];
												listOfFiles.add(fileObj);
											}
										} else {
											ContentDocumentLink cdLink = new ContentDocumentLink();
											cdLink.ContentDocumentId = objContentVersion.ContentDocumentId; 
											cdLink.ShareType = 'V';
											cdLink.LinkedEntityId = orgId;               
											cdlInsert.add(cdLink);
										}
				       				}
						       }
					   		} 
						}

						if(listOfFiles.size() > 0) {
							Database.SaveResult[] srList = Database.insert(cdlInsert , true);
						}
						if(listOfFiles.size() > 0) {
							Database.SaveResult[] fileList = Database.insert(listOfFiles, true);
						}
						if(listOfContentsToUpdate.size()>0){
							Database.SaveResult[] contentList = Database.update(listOfContentsToUpdate, true);
						}

						
						if( !listOfContentVersion.isEmpty() ) {
							FileDao.updateContentVersionInFileRecords(JSON.serialize(listOfContentVersion));
						}
						if( !contentDocIdsString.isEmpty() ) {
							ManageContentDao.updateEditDateForSiteContents(contentDocIdsString);
						}
					}
			    }
	   		}
		}
	} catch (Exception ex) { 
		//Ignore any exception coming in Trigger
	}
}