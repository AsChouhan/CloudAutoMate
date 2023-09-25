public with sharing class PageRedirectorController {
	

	
    public static String pageName {get{
    	if (pageName == null) {
    		pageName = PageContext.namespacePrefix + 'PageRedirector';
    	}
    	return pageName;
    }set;}
    	
    public PageReference handleRequest () {
    	PageReference pageRefObj;
    	try{
			Map<String, String> mapOfRequestParams = ApexPages.currentPage().getParameters();
	    	String pageNameToRedirect = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('pageToRedirect'));
	    	String chatterGroupId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('chatterGroupId'));
	    	String contentId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('contentId'));
	    	String mustRead = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('mustRead'));
	    	String peopleId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('userId'));
	    	String topicName = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('topicName'));
	    	String notificationId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('notificationId'));
	    	String siteId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('siteId'));
	    	String feedId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('feedId'));
	    	String questionId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('questionId'));
	    	String answerId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('answerId'));
	    	String requestId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('requestId'));
	    	String fileId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('fileId'));
	    	String profileId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('profileId'));
	    	String notificationType = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('notificationType'));
	    	String origin = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('origin'));
	    	String newsletterId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('newsletterId'));
	    	String openUsefulHistory = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('openUsefulHistory'));
			String showContentNotification = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('showContentNotification'));
			String utm_source = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('utm_source'));
			String utm_content = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('utm_content'));
			String utm_term = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('utm_term'));
			String utm_medium = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('utm_medium'));
	    	String modelVersion = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('model'));
			String orgDefaultEmailFrequency = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('org_email_freq'));
			String emailFrequency = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('email_freq'));
			String contentPosition = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('pos'));
			String csvDownloadRequestId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('Id'));
			Map<String, String> args = new Map<String, String>();
	    	// Mark notification as Read if coming from email as well
			
			List<App_Notification__c> notiList =  new List<App_Notification__c>();
			if(String.isNotBlank(feedId)){
				notiList = [SELECT Id,Is_Read__c,Is_new__c,Type__c FROM App_Notification__c WHERE Is_Deleted__c = false AND Object_Id__c =: feedId and Sent_To__r.User__c =:UserInfo.getUserId() and Is_Read__c = false and Type__c='information' WITH SECURITY_ENFORCED] ;
			} else if(String.isNotBlank(notificationId)){
				notiList = [SELECT Id,Object_Id__c,Sub_Type__c,Is_Read__c,Is_new__c,Type__c,
						 Simpplr_Site__r.Landing_Page__c, Simpplr_Site__r.Show_In_Simpplr__c, 
						 Simpplr_Site__r.Chatter_Group_Id__c FROM App_Notification__c WHERE Is_Deleted__c = false AND id =:notificationId and Type__c='information' WITH SECURITY_ENFORCED];
			} else if(String.isNotBlank(requestId)){
				notiList = [SELECT Id,Is_Read__c,Is_new__c,Type__c FROM App_Notification__c WHERE Is_Deleted__c = false AND Object_Id__c =: requestId and Sent_To__r.User__c =:UserInfo.getUserId() and Is_Read__c = false WITH SECURITY_ENFORCED];
			} else if(String.isNotBlank(contentId)){
				notiList = [SELECT Id,Is_Read__c,Is_new__c,Type__c FROM App_Notification__c WHERE Is_Deleted__c = false AND Object_Id__c =: contentId and Sent_To__r.User__c =:UserInfo.getUserId() and Is_Read__c = false and Type__c='information' WITH SECURITY_ENFORCED];
			} else if(String.isNotBlank(notificationType) && String.isNotBlank(profileId)) {
				notiList = [SELECT Id,Is_Read__c,Is_new__c,Type__c FROM App_Notification__c WHERE Is_Deleted__c = false AND Object_Id__c =: profileId and Sub_Type__c =:notificationType And Sent_To__r.User__c =:UserInfo.getUserId() and Is_Read__c = false and Type__c='information' WITH SECURITY_ENFORCED];
			}

			if(String.isBlank(requestId)){
				for(App_Notification__c noti : notiList){
					noti.Is_Read__c = true;
					noti.Is_New__c = false;
				}
				if(!notiList.isEmpty()) {
					List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
						App_Notification__c.Is_Read__c,
						App_Notification__c.Is_New__c
					};

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notiList), listOfColumnsToBeUpdated);
				}
			}
	    	if (pageNameToRedirect != null) {
	    		if(pageNameToRedirect.containsIgnoreCase(Pages.SiteDashboard)) {
		    		if(String.isNotBlank(chatterGroupId)) {
			    		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c 
			    				WHERE Chatter_Group_Id__c=:chatterGroupId WITH SECURITY_ENFORCED limit 1];
			    		String pageUrl = '';
			    		if (!listOfSimpplrSite.isEmpty()) {
			            	pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrSite[0].Id + '/dashboard';
			            	pageRefObj = new PageReference(pageUrl);
			            	
			    		} else {
							pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
			    		}
			    	} else if(String.isNotBlank(siteId)){
		            	String pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/dashboard';
		            	pageRefObj = new PageReference(pageUrl);
		    		} else {
		    			pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
		    		}
	    		} else if(pageNameToRedirect.containsIgnoreCase('manageDeactivatedSites')) {
		    		if(String.isNotBlank(siteId)) {
			    		if(AccessManager.hasUserManageSiteAccess(siteId)){
							SiteDao siteDaoObj = new SiteDao(); 
							String siteName = siteDaoObj.deActivateSite(siteId);
							String pageUrl = PageContext.getPageURL(Pages.app) +'?u=/manage/sites&filter=deactivated&term=' + siteName;
							pageRefObj = new PageReference(pageUrl);

						} else {
							pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
			    		}
			    	} else {
						pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
					}
	    		} else if(pageNameToRedirect.containsIgnoreCase(Pages.SiteFeed)){
	    			if(String.isNotBlank(chatterGroupId)) {
			    		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT Id, Chatter_Group_Id__c FROM Simpplr_Site__c 
			    				WHERE Chatter_Group_Id__c=:chatterGroupId WITH SECURITY_ENFORCED limit 1];
			    		String pageUrl = '';
			    		if (!listOfSimpplrSite.isEmpty()) {
			            	pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrSite[0].Id + '/feed';
			            	pageRefObj = new PageReference(pageUrl);
			            	
			    		} else {
			    			pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
			    		}
		    		} else {
		    			pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
		    		}
	    		} else if(pageNameToRedirect.containsIgnoreCase(Pages.ProfileAbout)){
	    			if(String.isNotBlank(peopleId)) {
		    			List<String> peopleList = Utility.getPeopleIdList(new List<String>{peopleId});
			    		String pageUrl = '';
		    			
		    			if(!peopleList.isEmpty()) {
			            	pageUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleList[0];
			            	pageRefObj = new PageReference(pageUrl);
		    				
		    			} else {
		    				pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
		    			}
	    			} else {
	    				pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
	    			}	    				    	
	    			
	    		} else if(pageNameToRedirect.containsIgnoreCase('TopicFeed')){
	    			if(String.isNotBlank(topicName)) {
			    		String pageUrl = '';
			    		String topicId = Utility.getTopicIdFromTopicName(topicName);
		    			if(String.isNotBlank(topicId)) {
			            	pageUrl = PageContext.getPageURL(Pages.app) + '?u=/topic/' + topicId + '/feed';
			            	pageRefObj = new PageReference(pageUrl);
		    				
		    			} else {
		    				pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
		    			}
	    			} else {
	    				pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
	    			}
	    			
	    		} else if(pageNameToRedirect.containsIgnoreCase('ContentDetailPage')) {
	    			if(String.isNotBlank(contentId)) {
		    			List<Simpplr_Content__c> listOfSimpplrContent = [SELECT Id, Is_Must_Read__c, Title__c, Type__c, Site__c,Primary_Author__c, Status__c 
		    															 FROM Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED];
						String pageUrl = '';
						if(!listOfSimpplrContent.isEmpty()) {
		    				if('Page'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+listOfSimpplrContent[0].Site__c+'/page/'+contentId;
		    				
		    				} else if('Album'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+listOfSimpplrContent[0].Site__c+'/album/'+contentId;
		    				
		    				} else if('Event'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+listOfSimpplrContent[0].Site__c+'/event/'+contentId;
		    				
		    				} else if('BlogPost'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/people/'+listOfSimpplrContent[0].Primary_Author__c+'/blog/'+contentId;
		    				
		    				}
		    				if(String.isNotBlank(mustRead)) {
		    					if(hasUserConfirmedMustRead(contentId)) {
		    						markMustReadNotificationStatusAsRead(contentId);
		    					}
		    					pageUrl += '&mustRead=1';
		    				} else if(ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(listOfSimpplrContent[0].Status__c)) {
		    					pageUrl += '&openModerationHistory=1';
		    				} else if(String.isNotBlank(newsletterId)){
		    					pageUrl += '&newsletterId='+newsletterId;
		    				} else if(String.isNotBlank(openUsefulHistory)) {
			            		pageUrl += '&openUsefulHistory=1';
			            	} else if(String.isNotBlank(showContentNotification)) {
								pageUrl += '&showContentNotification=' + showContentNotification;
							} if(String.isNotBlank(utm_source)) {
								pageUrl += '&utm_source=' + utm_source;
							} if(String.isNotBlank(utm_medium)) {
								pageUrl += '&utm_medium=' + utm_medium;
							} if(String.isNotBlank(utm_term)) {
								pageUrl += '&utm_term=' + utm_term;
							} if(String.isNotBlank(utm_content)) {
								pageUrl += '&utm_content=' + utm_content;
							} if(String.isNotBlank(modelVersion)) {
								pageUrl += '&model=' + modelVersion;
							} if(String.isNotBlank(orgDefaultEmailFrequency)) {
								pageUrl += '&org_email_freq=' + orgDefaultEmailFrequency;
							} if(String.isNotBlank(emailFrequency)) {
								pageUrl += '&email_freq=' + emailFrequency;
							} if(String.isNotBlank(contentPosition)) {
								pageUrl += '&pos=' + contentPosition;
							} if(String.isNotBlank(contentId)) {
								pageUrl += '&content_id=' + contentId;
							}
    						pageRefObj = new PageReference(pageUrl);
		    			} else {
		    				pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/403');
		    			}
	    			} else {
	    				pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
	    			}
	    			
	    		} else if(pageNameToRedirect.containsIgnoreCase('ContentDetailFromFeed')){
	    			
	    			if(String.isNotBlank(contentId)){
		    			List<Simpplr_Content__c> listOfSimpplrContent = [SELECT Id, Title__c, Type__c, Site__c,Primary_Author__c FROM Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED];
			    		String pageUrl = '';
						String baseUrl = SimpplrContext.salesforceBaseUrl;
		    			
		    			if(!listOfSimpplrContent.isEmpty()){
		    				args.put('contentId', listOfSimpplrContent[0].Id);
		    				String contentPageName;
							
		    				if('Page'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+listOfSimpplrContent[0].Site__c+'/page/'+contentId;
	    						pageRefObj = new PageReference(pageUrl);
		    				} else if('Album'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+listOfSimpplrContent[0].Site__c+'/album/'+contentId;
		    					pageRefObj = new PageReference(pageUrl);
		    				} else if('Event'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+listOfSimpplrContent[0].Site__c+'/event/'+contentId;
		    					pageRefObj = new PageReference(pageUrl);
		    				} else if('BlogPost'.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
		    					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/people/'+listOfSimpplrContent[0].Primary_Author__c+'/blog/'+contentId;
		    					pageRefObj = new PageReference(pageUrl);
		    				} else{
		    					pageRefObj = Page.app;
            					pageRefObj.getParameters().put('u','/error/404');
		    				}
		    			} else{
		    				pageRefObj = new PageReference(baseUrl +'/'+contentId);
		    			}
		    			
	    			} else {
	    				pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
	    			}
	    			
	    		} else if(pageNameToRedirect.containsIgnoreCase(Pages.MySettingsEmail)){
		    		if(String.isNotBlank(peopleId)) {
		    			List<String> peopleList;
		    			if(peopleId.substring(0,3).equalsIgnorecase('005')) {
		    				peopleList = Utility.getPeopleIdList(new List<String>{peopleId});
		    			} else {
		    				peopleList = new List<String>{peopleId};
		    			}
			    		String pageUrl = '';
		    			
		    			if(!peopleList.isEmpty()) {
		    				args.put('profileId', peopleList[0]);
			            	pageUrl = PageContext.getPageURL(Pages.MySettingsEmail, args);
			            	pageRefObj = new PageReference(pageUrl);
		    				
		    			} else {
		    				pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
		    			}
					} else {
						pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
					}
						
				} else if(pageNameToRedirect.containsIgnoreCase(Pages.Notificationsprivatesiterequest)){
		    		if(String.isNotBlank(requestId)) {
						
		            	String pageUrl = PageContext.getPageURL(Pages.app) + '?u=/manage/sites/request/' + requestId;
		            	pageRefObj = new PageReference(pageUrl);
		    				
					} else {
						pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
					}
						
				} else if(pageNameToRedirect.containsIgnoreCase(Pages.NotificationsSiteMemberRequest)){
					if(String.isNotBlank(siteId)) {	
						
						String pageUrl = PageContext.getPageURL(Pages.app) + '?u=/manage/sites/' + siteId +'/people/requests';
		            	pageRefObj = new PageReference(pageUrl);
		    				
					} else {
						pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
					}
						
				} else if(pageNameToRedirect.containsIgnoreCase('managesitesubscription')){
		    		if(String.isNotBlank(siteId)) {
		            	String pageUrl = PageContext.getPageURL(Pages.app)+'?u=/manage/sites/'+siteId+'/subscriptions';
		            	pageRefObj = new PageReference(pageUrl);
		    				
					} else {
						pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
					}

				} else if('manageContent'.equalsIgnoreCase(pageNameToRedirect)) {				
					String status = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('status'));
					pageRefObj = Page.app;
					if(String.isNotBlank(status)) {					
						pageRefObj.getParameters().put('u','/manage/content');
						pageRefObj.getParameters().put('status',status);
					} else {
						pageRefObj.getParameters().put('u','/manage/content');
					}
				} else if(pageNameToRedirect.containsIgnoreCase('onboarding')) {				
					String status = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('status'));
					String sortBy = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('sortBy'));
					String referralSource = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('referralSource'));
                    pageRefObj = Page.app;
                    pageRefObj.getParameters().put('u','/onboarding');
					
                    if(String.isNotBlank(sortBy)) {
                        pageRefObj.getParameters().put('sortBy', sortBy);
                    }
                    if(String.isNotBlank(status)) {
						pageRefObj.getParameters().put('status',status);
					}
					if(String.isNotBlank(referralSource)) {
						pageRefObj.getParameters().put('referralSource',referralSource);
					}		
				} else if(pageNameToRedirect.containsIgnoreCase('managesegmentsubscription')) {
						String pageUrl = PageContext.getPageURL(Pages.app) + '?u=/subscriptions';
						String subscriptionId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParams.get('subscriptionId'));
						
						Map<String, Object> soqlParamMap = new Map<String, Object>();
						soqlParamMap.put('soqlParam1', subscriptionId);
						
						String queryString = 'SELECT Audience__r.Segment__c from Subscription__c where id=:soqlParam1';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        				List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

						if(SimpplrContext.isSegmentsEnabled && 
								!subscriptionList.isEmpty() && 
								String.isNotBlank(subscriptionList[0].Audience__r.Segment__c)) {
							pageUrl += '/' + subscriptionList[0].Audience__r.Segment__c;
				
						} else {
							pageUrl += '/org';
						}						
						pageRefObj = new PageReference(pageUrl);
            	
            	}else if(pageNameToRedirect.containsIgnoreCase(Pages.SiteDashboard)){
		    		if(String.isNotBlank(siteId)) {
		            	String pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/dashboard';
		            	pageRefObj = new PageReference(pageUrl);
					} else {
						pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
					}
						
				} else if(pageNameToRedirect.containsIgnoreCase(Pages.HomeFeedSinglePost)){
		    		if(String.isNotBlank(feedId)) {
	    				args.put('feedId', feedId);
		            	String pageUrl = PageContext.getPageURL(Pages.app)+'?u=/feed/'+feedId;
		            	pageRefObj = new PageReference(pageUrl);
					} else {
						pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
					}
						
				} else if(pageNameToRedirect.containsIgnoreCase(Pages.FileDetail)){
		    		if(String.isNotBlank(fileId)) {
	    				args.put('fileId', fileId);
		            	String pageUrl = PageContext.getPageURL(Pages.FileDetail, args);
		            	pageRefObj = new PageReference(pageUrl);
					} else {
						pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
					}
				} else if(pageNameToRedirect.containsIgnoreCase(ServiceConstants.SITE_LANDING_PAGE_STRING)){
					
					if (String.isNotBlank(chatterGroupId)) {
			    		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT Id, Landing_Page__c, Show_In_Simpplr__c
			    				FROM Simpplr_Site__c WHERE Chatter_Group_Id__c=:chatterGroupId WITH SECURITY_ENFORCED limit 1];
			    		String pageUrl = '';
			    		if (!listOfSimpplrSite.isEmpty()) {
			            	
			            	if (listOfSimpplrSite[0].Show_In_Simpplr__c) {
			            		pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrSite[0].Id + '/' + listOfSimpplrSite[0].Landing_Page__c;
			            	} else {
			            		pageUrl = SimpplrContext.salesforceBaseUrl + '/'+chatterGroupId;
			            	}
			            	
			            	pageRefObj = new PageReference(pageUrl);
			    		} else {
			    			pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
			    		}
			    	} else if(String.isNotBlank(siteId)){
			    		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT Id, Landing_Page__c,Show_In_Simpplr__c,
			    				Chatter_Group_Id__c FROM Simpplr_Site__c WHERE id=:siteId WITH SECURITY_ENFORCED limit 1];
			    		String pageUrl = '';
			    		if (!listOfSimpplrSite.isEmpty()) {
			            	if (listOfSimpplrSite[0].Show_In_Simpplr__c) {
			            		pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrSite[0].Id + '/' + listOfSimpplrSite[0].Landing_Page__c;
			            	} else {
			            		pageUrl = SimpplrContext.salesforceBaseUrl + '/'+
			            							listOfSimpplrSite[0].Chatter_Group_Id__c;
			            	}
			            	
			            	pageRefObj = new PageReference(pageUrl);
			    		} else {
			    			pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
			    		}
		    		} else if(String.isNotBlank(notificationId)){
		    			if(!notiList.isEmpty()){
		    				App_Notification__c notificationObj = notiList[0];
				    		String pageUrl = '';
				    		
			            	if (notificationObj.Simpplr_Site__r.Show_In_Simpplr__c) {
			            		pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + notificationObj.Simpplr_Site__c + '/' + notificationObj.Simpplr_Site__r.Landing_Page__c;
			            	} else {
			            		pageUrl = SimpplrContext.salesforceBaseUrl + '/'+
			            							notificationObj.Simpplr_Site__r.Chatter_Group_Id__c;
			            	}
			            	
			            	pageRefObj = new PageReference(pageUrl);
		    			} else {
		    				pageRefObj = Page.app;
            				pageRefObj.getParameters().put('u','/error/404');
		    			}
		    		} else {
		    			pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
		    		}
				} else if(pageNameToRedirect.containsIgnoreCase('ManageApplicationFileIntegrations')){
                    pageRefObj = Page.app;
                    pageRefObj.getParameters().put('u', '/manage/app/integrations/files');
                } else if(pageNameToRedirect.containsIgnoreCase('ManageCsvDownload') && String.isNotBlank(csvDownloadRequestId)) {
					String downloadUrl = '';
					Boolean isDownloadLinkActive = false;
					Boolean isSameUser = false;
					String people = UserContext.peopleId;
					Map<String, Object> soqlParamMap = new  Map<String, Object>();
					soqlParamMap.put('soqlParam1', csvDownloadRequestId);
					List<App_Notification__c> csvNotificationList = [select id from App_Notification__c where sent_to__c=:people and Object_Type__c='CsvDownloadRequest' and is_read__c=false AND Is_Deleted__c = false AND Csv_Download_Request__c=:csvDownloadRequestId WITH SECURITY_ENFORCED];
					if(csvNotificationList.isEmpty() == false) {
						for(App_Notification__c notiObj : csvNotificationList){
							notiObj.Action_By__c = people;
							notiObj.Action_On__c = DateTime.now();
							notiObj.Is_Read__c = true;
							notiObj.Is_New__c = false;
						}
						
						List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
							App_Notification__c.Action_By__c,
							App_Notification__c.Action_On__c,
							App_Notification__c.Is_Read__c,
							App_Notification__c.Is_New__c
						};
		
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(csvNotificationList), listOfColumnsToBeUpdated);
					}	
					String query = 'SELECT Id, CreatedDate, CreatedById, LastModifiedDate, Content__c, Csv_Url__c, People__c, ' +
									'Request_DateTime__c, Download_Count_In_App_Link__c, Download_Count_Email_Link__c ' +
									' FROM Csv_Download_Request__c WHERE Id =: soqlParam1';

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
					List<Csv_Download_Request__c> csvDownloadRequestList = (List<Csv_Download_Request__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
					if(!csvDownloadRequestList.isEmpty()) {
						Csv_Download_Request__c csvDownloadRequestRecord = csvDownloadRequestList[0];
						downloadUrl = String.isNotBlank(csvDownloadRequestRecord.Csv_Url__c) ? (String) csvDownloadRequestRecord.Csv_Url__c: null;
						Datetime requestDateTime = csvDownloadRequestRecord.CreatedDate != null ? (Datetime) csvDownloadRequestRecord.CreatedDate: null;
						String peopleIdVal = String.isNotBlank(csvDownloadRequestRecord.People__c) ? (String) csvDownloadRequestRecord.People__c: null;
						
						Datetime currentDateTime = datetime.NOW();
						decimal millisecs = decimal.valueOf(currentDateTime.getTime() - requestDateTime.getTime());
						decimal diffInMinutes = millisecs/1000/60;
						isDownloadLinkActive = diffInMinutes < 4315.0 ? true : false;
						isSameUser = UserContext.PeopleId != null && peopleIdVal.equalsIgnoreCase(UserContext.peopleId) ? true : false;
					}
					if(String.isNotBlank(downloadUrl) && isDownloadLinkActive && isSameUser){
						Csv_Download_Request__c csvDownloadRequestRecord = csvDownloadRequestList[0];
						csvDownloadRequestRecord.Download_Count_Email_Link__c = Integer.valueOf(csvDownloadRequestRecord.Download_Count_Email_Link__c) + 1 ;
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
						SIMPESAPI.accessController().updateAsUser(csvDownloadRequestRecord, new List<Schema.SObjectField>{
							Csv_Download_Request__c.Download_Count_Email_Link__c});
						pageRefObj = new PageReference(downloadUrl);
					}else{
						pageRefObj = Page.app;
						pageRefObj.getParameters().put('u','/error/404');
					}
					pageRefObj.setRedirect(true);
					pageRefObj.setRedirectCode(301);
				} else if(pageNameToRedirect.containsIgnoreCase('QuestionDetail')){
                    pageRefObj = Page.app;
                    pageRefObj.getParameters().put('u', '/site/'+siteId+'/questions/'+questionId);

                } else if(pageNameToRedirect.containsIgnoreCase('AnswerDetail')){
                    pageRefObj = Page.app;
                    pageRefObj.getParameters().put('u', '/site/'+siteId+'/answers/'+answerId);
                } else {
	    			pageRefObj = Page.app;
					pageRefObj.getParameters().put('u','/error/404');
	    		}   
	    	} else {
	    		pageRefObj = Page.app;
				pageRefObj.getParameters().put('u','/error/404');
	    	}
	    	if(String.isNotBlank(origin)) {
	    		pageRefObj.getParameters().put('origin',origin);
	    	}
	    	pageRefObj.setRedirect(true);
    	} catch(Exception e){
    		logger.logError('Unable to open email Link',e);
    	}
	    return pageRefObj;
    }
    
    private void markMustReadNotificationStatusAsRead(String contentId) {
    	List<App_Notification__c> notificationList = [SELECT Id FROM App_Notification__c 
														WHERE Object_id__c = :contentId AND Sub_type__c='Must Read' 
														AND Action_By__c = null
														AND Is_Deleted__c = false 
														AND Sent_To__c = :UserContext.peopleId
														WITH SECURITY_ENFORCED
														ORDER BY CreatedDate desc
														LIMIT 1];
														
    	if(!notificationList.isEmpty()){
    		notificationList[0].Is_Read__c = true;
    		notificationList[0].Is_New__c = false;
    		notificationList[0].Action_On__c = DateTime.now();
    		notificationList[0].Action_By__c = UserContext.peopleId;
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notificationList),new List<Schema.SObjectField>{
																																App_Notification__c.Is_Read__c,
																																App_Notification__c.Is_New__c,
																																App_Notification__c.Action_On__c,
																																App_Notification__c.Action_By__c
																																	});
		}
	}

	private boolean hasUserConfirmedMustRead(String contentId) {
		Boolean returnValue = false;
		
		DateTime currentDateTime = DateTime.now();
		String peopleId = UserContext.peopleId;

		List<Must_Read_Confirm_History__c> historyList = [SELECT id 
								FROM Must_Read_Confirm_History__c 
								WHERE Content__c = :contentId AND People__c = :peopleId
								AND Must_Read_Audit__r.Removed_DateTime__c = null 
								AND (Must_Read_Audit__r.Expiry_DateTime__c = null OR Must_Read_Audit__r.Expiry_DateTime__c >: currentDateTime) WITH SECURITY_ENFORCED];

		if(historyList.size() > 0) {
			returnValue = true;
		}

		return returnValue;
	}
}