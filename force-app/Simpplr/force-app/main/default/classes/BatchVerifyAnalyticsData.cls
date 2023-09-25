public with sharing class BatchVerifyAnalyticsData implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.stateful {
    
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3};
    private String recordType;
    private Boolean runNextBatchInSequence;
    private Boolean isCountVerificationFailed;
    private static final List<String> objectWithDateTimeField = new List<String> {'analytics_search_result_select','social_analytics'};
    Object startDate,endDate;
    
    public BatchVerifyAnalyticsData(String recordType, Boolean runNextBatchInSequence) {
        this.recordType = recordType;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    	String queryToFindMax = '',query='', queryToFindCount='';
        Integer countFromSalesforce,countFromExternalAPI;
    	
        if('analytics_adoption'.equalsIgnoreCase(recordType)) {
            query = 'select Id, Sync_Status__c from Analytics_Adoption__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Adoption__c where Sync_Status__c =:SYNC_STATUS_SENT';
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Adoption__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_Adoption__c> analyticsAdotionMaxList = Database.query(queryToFindMax);
        	if(!analyticsAdotionMaxList.isEmpty()) {
            	endDate = analyticsAdotionMaxList[0].Date__c;
            
	            String queryToFindMin = 'SELECT Date__c FROM Analytics_Adoption__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
	            List<Analytics_Adoption__c> analyticsAdotionMinList = Database.query(queryToFindMin);
	        	if(!analyticsAdotionMinList.isEmpty()) {
	            	startDate = analyticsAdotionMinList[0].Date__c;
	            }
        	}
        
        }else if('analytics_content_count'.equalsIgnoreCase(recordType)){
            query = ' select Id, Sync_Status__c from Analytics_Content_Count__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Content_Count__c where Sync_Status__c =:SYNC_STATUS_SENT';
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Content_Count__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_Content_Count__c> analyticsContentCountMaxList = Database.query(queryToFindMax);
            if(!analyticsContentCountMaxList.isEmpty()) {
            	endDate = analyticsContentCountMaxList[0].Date__c;

	            String queryToFindMin = 'SELECT Date__c FROM Analytics_Content_Count__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
	            List<Analytics_Content_Count__c> analyticsContentCountMinList = Database.query(queryToFindMin);
	            if(!analyticsContentCountMinList.isEmpty()) {
	            	startDate = analyticsContentCountMinList[0].Date__c;
	            }
            }
                    
        }else if('analytics_feed_count'.equalsIgnoreCase(recordType)) {
            query = ' select Id, Sync_Status__c from Analytics_Feed_Count__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from analytics_feed_count__c where Sync_Status__c =:SYNC_STATUS_SENT';
            
            queryToFindMax = 'SELECT Date__c FROM analytics_feed_count__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<analytics_feed_count__c> analyticsFeedCountMaxList = Database.query(queryToFindMax);
            if(!analyticsFeedCountMaxList.isEmpty()) {
            	endDate = analyticsFeedCountMaxList[0].Date__c;
            	
	            String queryToFindMin = 'SELECT Date__c FROM analytics_feed_count__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
	            List<analytics_feed_count__c> analyticsFeedCountMinList = Database.query(queryToFindMin);
	            if(!analyticsFeedCountMinList.isEmpty()) {
	            	startDate = analyticsFeedCountMinList[0].Date__c;
	            }
            }
            
        }else if('analytics_login'.equalsIgnoreCase(recordType)) {
            query = ' select Id, Sync_Status__c from Analytics_Login__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Login__c where Sync_Status__c =:SYNC_STATUS_SENT';     
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Login__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_Login__c> analyticsLoginMaxList = Database.query(queryToFindMax);
            if(!analyticsLoginMaxList.isEmpty()) {
            	endDate = analyticsLoginMaxList[0].Date__c;
               
	            String queryToFindMin = 'SELECT Date__c FROM Analytics_Login__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1'; 
	            List<Analytics_Login__c> analyticsLoginMinList = Database.query(queryToFindMin);
	            if(!analyticsLoginMaxList.isEmpty()) {
					startDate = analyticsLoginMinList[0].Date__c;
	            }
            }
        
        }else if('analytics_page_view'.equalsIgnoreCase(recordType)) {
            query = ' select Id,Sync_Status__c from Analytics_PageView__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_PageView__c where Sync_Status__c =:SYNC_STATUS_SENT';

            queryToFindMax = 'SELECT Date__c FROM Analytics_PageView__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_PageView__c> analyticsPageViewMaxList = Database.query(queryToFindMax);
            if(!analyticsPageViewMaxList.isEmpty()) {
            	endDate = analyticsPageViewMaxList[0].Date__c;
            
            	String queryToFindMin = 'SELECT Date__c FROM Analytics_PageView__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
            	List<Analytics_PageView__c> analyticsPageViewMinList = Database.query(queryToFindMin);
	            if(!analyticsPageViewMinList.isEmpty()) {
	            	startDate = analyticsPageViewMinList[0].Date__c;
	            }
        	}
        
        } else if('analytics_search_result_select'.equalsIgnoreCase(recordType)) {
            query = ' select Id,Sync_Status__c from Analytics_Search_Result_Select__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Search_Result_Select__c where Sync_Status__c =:SYNC_STATUS_SENT';     
            
            queryToFindMax = 'SELECT CreatedDate FROM Analytics_Search_Result_Select__c where Sync_Status__c =:SYNC_STATUS_SENT order by CreatedDate Desc Limit 1';
            List<Analytics_Search_Result_Select__c> analyticsSearchResultSelectMaxList = Database.query(queryToFindMax);
            if(!analyticsSearchResultSelectMaxList.isEmpty()) {
            	endDate = analyticsSearchResultSelectMaxList[0].CreatedDate;
            	
            	String queryToFindMin = 'SELECT CreatedDate FROM Analytics_Search_Result_Select__c where Sync_Status__c =:SYNC_STATUS_SENT order by CreatedDate Asc Limit 1';
            	List<Analytics_Search_Result_Select__c> analyticsSearchResultSelectMinList = Database.query(queryToFindMin);
            	if(!analyticsSearchResultSelectMinList.isEmpty()) {
            		startDate = analyticsSearchResultSelectMinList[0].CreatedDate;
            	}
            } 
            
        
        }else if('analytics_social_campaign'.equalsIgnoreCase(recordType)) {
            query = ' select Id,Sync_Status__c from Analytics_Social_Campaign__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Social_Campaign__c where Sync_Status__c =:SYNC_STATUS_SENT';
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Social_Campaign__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_Social_Campaign__c> analyticsSocialCampaignMaxList = Database.query(queryToFindMax);
            if(!analyticsSocialCampaignMaxList.isEmpty()) {
            	endDate = analyticsSocialCampaignMaxList[0].Date__c;
            
            	String queryToFindMin = 'SELECT Date__c FROM Analytics_Social_Campaign__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
            	List<Analytics_Social_Campaign__c> analyticsSocialCampaignMinList = Database.query(queryToFindMin);
            	if(!analyticsSocialCampaignMinList.isEmpty()) {
            		startDate = analyticsSocialCampaignMinList[0].Date__c;
            	}
            }
        
        }else if('analytics_top_content'.equalsIgnoreCase(recordType)) {
            query = ' select Id,Sync_Status__c from Analytics_Top_Content__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Top_Content__c where Sync_Status__c =:SYNC_STATUS_SENT';       
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Top_Content__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_Top_Content__c> analyticsTopContentMaxList = Database.query(queryToFindMax);
            if(!analyticsTopContentMaxList.isEmpty()) {
            	endDate = analyticsTopContentMaxList[0].Date__c;
            	
            	String queryToFindMin = 'SELECT Date__c FROM Analytics_Top_Content__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1'; 
            	List<Analytics_Top_Content__c> analyticsTopContentMinList = Database.query(queryToFindMin);
            	if(!analyticsTopContentMinList.isEmpty()) {
            		startDate = analyticsTopContentMinList[0].Date__c;
            	}
            }
        
        }else if('analytics_top_people'.equalsIgnoreCase(recordType)) {
            query = 'select Id,Sync_Status__c from Analytics_Top_People__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Top_People__c where Sync_Status__c =:SYNC_STATUS_SENT';    
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Top_People__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1'; 
            List<Analytics_Top_People__c> analyticsTopPeopleMaxList = Database.query(queryToFindMax);
            if(!analyticsTopPeopleMaxList.isEmpty()) {
            	endDate = analyticsTopPeopleMaxList[0].Date__c;
               
            	String queryToFindMin = 'SELECT Date__c FROM Analytics_Top_People__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';  
            	List<Analytics_Top_People__c> analyticsTopPeopleMinList = Database.query(queryToFindMin);
            	if(!analyticsTopPeopleMinList.isEmpty()) {
            		startDate = analyticsTopPeopleMinList[0].Date__c;
            	}
            }
        
        }else if('analytics_top_search'.equalsIgnoreCase(recordType)) {
            query = ' select Id,Sync_Status__c from Analytics_Top_Search__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Top_Search__c where Sync_Status__c =:SYNC_STATUS_SENT';
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Top_Search__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_Top_Search__c> analyticsTopSearchMaxList = Database.query(queryToFindMax);
            if(!analyticsTopSearchMaxList.isEmpty()) {
            	endDate = analyticsTopSearchMaxList[0].Date__c;
            
           		String queryToFindMin = 'SELECT Date__c FROM Analytics_Top_Search__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
           		List<Analytics_Top_Search__c> analyticsTopSearchMinList = Database.query(queryToFindMin);
	            if(!analyticsTopSearchMinList.isEmpty()) {
	            	startDate = analyticsTopSearchMinList[0].Date__c;
	            }
            }
        
        }else if('analytics_top_site'.equalsIgnoreCase(recordType)) {
            query = ' select Id,Sync_Status__c from Analytics_Top_Site__c where Sync_Status__c =:SYNC_STATUS_SENT ';
            queryToFindCount = 'SELECT count(id) totalCount from Analytics_Top_Site__c where Sync_Status__c =:SYNC_STATUS_SENT';
            
            queryToFindMax = 'SELECT Date__c FROM Analytics_Top_Site__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
            List<Analytics_Top_Site__c> analyticsTopSiteMaxList = Database.query(queryToFindMax);
            if(!analyticsTopSiteMaxList.isEmpty()) {
            	endDate = analyticsTopSiteMaxList[0].Date__c;
            	
            	String queryToFindMin = 'SELECT Date__c FROM Analytics_Top_Site__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
            	List<Analytics_Top_Site__c> analyticsTopSiteMinList = Database.query(queryToFindMin);
            	if(!analyticsTopSiteMinList.isEmpty()) {
            		startDate = analyticsTopSiteMinList[0].Date__c;
        		}
            }
            
        
        }else if('analytics_top_topic'.equalsIgnoreCase(recordType)) {
            query = 'select Id,Sync_Status__c from Analytics_Top_Topic__c where Sync_Status__c =:SYNC_STATUS_SENT ';
        	queryToFindCount = 'SELECT count(id) totalCount from analytics_top_topic__c where Sync_Status__c =:SYNC_STATUS_SENT';
        	
        	queryToFindMax = 'SELECT Date__c FROM analytics_top_topic__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Desc Limit 1';
        	List<analytics_top_topic__c> analyticsTopTopicMaxList = Database.query(queryToFindMax);
        	if(!analyticsTopTopicMaxList.isEmpty()) {
            	endDate = analyticsTopTopicMaxList[0].Date__c;
            	
        		String queryToFindMin = 'SELECT Date__c FROM analytics_top_topic__c where Sync_Status__c =:SYNC_STATUS_SENT order by Date__c Asc Limit 1';
        		List<analytics_top_topic__c> analyticsTopTopicMinList = Database.query(queryToFindMin);
        		if(!analyticsTopTopicMinList.isEmpty()) {
            		startDate = analyticsTopTopicMinList[0].Date__c;
        		}
        	}
        
        }else if('social_analytics'.equalsIgnoreCase(recordType)) {
    		query = 'Select Id, Sync_Status__c from Simpplr_Social_Analytics__c where Sync_Status__c =:SYNC_STATUS_SENT ';
    		queryToFindCount = 'SELECT count(id) totalCount from Simpplr_Social_Analytics__c where Sync_Status__c =:SYNC_STATUS_SENT';
    		
    		queryToFindMax = 'SELECT CreatedDate FROM Simpplr_Social_Analytics__c where Sync_Status__c =:SYNC_STATUS_SENT order by CreatedDate Desc Limit 1';
    		List<Simpplr_Social_Analytics__c> socialAnalyticsMaxList = Database.query(queryToFindMax);
        	if(!socialAnalyticsMaxList.isEmpty()) {
            	endDate = socialAnalyticsMaxList[0].CreatedDate;
    		
	    		String queryToFindMin = 'SELECT CreatedDate FROM Simpplr_Social_Analytics__c where Sync_Status__c =:SYNC_STATUS_SENT order by CreatedDate Asc Limit 1';
	    		List<Simpplr_Social_Analytics__c> socialAnalyticsMinList = Database.query(queryToFindMin);
        		if(!socialAnalyticsMinList.isEmpty()) {
            		startDate = socialAnalyticsMinList[0].CreatedDate;
        		}
        	}
	    		
        }
    	List<AggregateResult> result = (List<AggregateResult>)Database.query(queryToFindCount);
    	countFromSalesforce = 0;
        isCountVerificationFailed = true;
        if(result.size()>0){
        	countFromSalesforce = (Integer)result[0].get('totalCount');
        }
        if(startDate!=null && endDate!=null){
			
			HTTPResponse res = hitExternalAPI('getRecordCount',null);
			// assign to countFromExternalAPI- whatever is coming in response
			Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			countFromExternalAPI = (Integer)m.get('recordCount');
			if(countFromSalesforce == countFromExternalAPI){
				isCountVerificationFailed = false;
			}
			
        } 
	    return (Database.getQueryLocator(query));
	}
   
   private HttpResponse hitExternalAPI(String methodName,Set<String> idSet){ 
   		String endPointURL = SimpplrContext.appConfig.External_Analytics_URL__c + methodName;
		Map<String, Object> requestBody = new Map<String, Object>();
		if('getRecordCount'.equalsIgnoreCase(methodName)){
			if(objectWithDateTimeField.contains(recordType)) {
				String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
				requestBody.put('from', Utility.dateTimeStringInGMT( (DateTime)startDate, dateTimeFormat));
				requestBody.put('to', Utility.dateTimeStringInGMT( (DateTime)endDate, dateTimeFormat));
			} else {
				requestBody.put('from', startDate);
				requestBody.put('to', endDate);
			}
			
		}else if('getMissingRecords'.equalsIgnoreCase(methodName)){
			if(idSet.size()>0){
				requestBody.put('ids', idSet);
			}
		}
		
		requestBody.put('org_id', UserInfo.getOrganizationId().subString(0,15));
		requestBody.put('tableName',recordType);
		
		HttpResponse response = Utility.getJsonResponseFromExternalSystem('POST',endPointURL,Utility.externalRequestAuthToken(),Json.serialize(requestBody));
		if (response.getStatusCode() == 403){
			throw new SimpplrException(ServiceConstants.ERROR_403);
		
		} else if (response.getStatusCode() == 404) {
			throw new SimpplrException(ServiceConstants.ERROR_404);
			
		} else if (response.getStatusCode() == 500) {
			throw new SimpplrException(ServiceConstants.ERROR_500);
			
		} else if(response.getStatusCode() != 200) {
			throw new SimpplrException('Status ' + response.getStatusCode()  + ' received from server');
			
		}
		return response;
   } 
   
   public void execute(Database.BatchableContext BC, List<sObject> listOfsObject) {
   	
	   	Set<String> setOfFailedIds = new Set<String>();
	   	
	   	if(isCountVerificationFailed) {
		   	Map<String,Sobject> ObjectsMap = new Map<String,Sobject>(listOfsObject);
	   		//hit external API
	   		Http http = new Http();
			HTTPResponse res = hitExternalAPI('getMissingRecords', ObjectsMap.keySet());
			
			Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			Map<String, Object> resultMap = (Map<String, Object>) m.get('result');
			List<Object> listOfIds = (List<Object>) resultMap.get('listOfIds');
			for(Object obj:listOfIds) {
				setOfFailedIds.add((String)obj);
			}
	   	}
   	
   		updateObject(listOfsObject, setOfFailedIds);
    }
    
    private void updateObject(List<sObject> listToProcess, Set<String> setOfFailedIds) {
    	if('analytics_adoption'.equalsIgnoreCase(recordType)) {
			List<Analytics_Adoption__c> objList = (List<Analytics_Adoption__c>)listToProcess;
			for(Analytics_Adoption__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Analytics_Adoption__c>(objList), new List<Schema.SObjectField>{
																						Analytics_Adoption__c.Sync_Status__c});

		} else if('analytics_content_count'.equalsIgnoreCase(recordType)) {
        	List<analytics_content_count__c> objList = (List<analytics_content_count__c>)listToProcess;
			for(analytics_content_count__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Content_Count__c>(objList), new List<Schema.SObjectField>{
				Analytics_Content_Count__c.Sync_Status__c
			});
        
        } else if('analytics_feed_count'.equalsIgnoreCase(recordType)) {
       		List<analytics_feed_count__c> objList = (List<analytics_feed_count__c>)listToProcess;
			for(analytics_feed_count__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Feed_Count__c>(objList), new List<Schema.SObjectField>{
				Analytics_Feed_Count__c.Sync_Status__c
			});
        
        } else if('analytics_login'.equalsIgnoreCase(recordType)) {
        	List<analytics_login__c> objList = (List<analytics_login__c>)listToProcess;
			for(analytics_login__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,analytics_login__c>(objList),new List<Schema.SObjectField>{analytics_login__c.Sync_Status__c});
       
        } else if('analytics_page_view'.equalsIgnoreCase(recordType)) {
	       List<Analytics_PageView__c> objList = (List<Analytics_PageView__c>)listToProcess;
	       for(Analytics_PageView__c obj : objList){
	       		obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
	       }
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_PageView__c>(objList), new List<Schema.SObjectField>{
				Analytics_PageView__c.Sync_Status__c
			});
        
        } else if('analytics_search_result_select'.equalsIgnoreCase(recordType)) {
        	List<analytics_search_result_select__c> objList = (List<analytics_search_result_select__c>)listToProcess;
			for(analytics_search_result_select__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Search_Result_Select__c>(objList), new List<Schema.SObjectField>{
				Analytics_Search_Result_Select__c.Sync_Status__c
			});
        } else if('analytics_social_campaign'.equalsIgnoreCase(recordType)) {
        	List<analytics_social_campaign__c> objList = (List<analytics_social_campaign__c>)listToProcess;
			for(analytics_social_campaign__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,analytics_social_campaign__c>((List<analytics_social_campaign__c>)objList),new List<Schema.SObjectField>{analytics_social_campaign__c.Sync_Status__c});
        
        } else if('analytics_top_content'.equalsIgnoreCase(recordType)) {
        	List<analytics_top_content__c> objList = (List<analytics_top_content__c>)listToProcess;
			for(analytics_top_content__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,analytics_top_content__c>(objList),new List<Schema.SObjectField>{
														analytics_top_content__c.Sync_Status__c
													});
        
        } else if('analytics_top_people'.equalsIgnoreCase(recordType)) {
        	List<analytics_top_people__c> objList = (List<analytics_top_people__c>)listToProcess;
			for(analytics_top_people__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,analytics_top_people__c>(objList),new List<Schema.SObjectField>{analytics_top_people__c.Sync_Status__c});
        
        } else if('analytics_top_search'.equalsIgnoreCase(recordType)) {
        	List<analytics_top_search__c> objList = (List<analytics_top_search__c>)listToProcess;
			for(analytics_top_search__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,analytics_top_search__c>(objList),new List<Schema.SObjectField>{analytics_top_search__c.Sync_Status__c});
        
        } else if('analytics_top_site'.equalsIgnoreCase(recordType)) {
	       List<analytics_top_site__c> objList = (List<analytics_top_site__c>)listToProcess;
			for(analytics_top_site__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			} 
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Top_Site__c>(objList), new List<Schema.SObjectField>{
				Analytics_Top_Site__c.Sync_Status__c
			});
       
        } else if('analytics_top_topic'.equalsIgnoreCase(recordType)) {
        	List<analytics_top_topic__c> objList = (List<analytics_top_topic__c>)listToProcess;
			for(analytics_top_topic__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,analytics_top_topic__c>(objList), new List<Schema.SObjectField>{
				analytics_top_topic__c.Sync_Status__c
			});
        
        } else if('social_analytics'.equalsIgnoreCase(recordType)) {
			List<Simpplr_Social_Analytics__c> objList = (List<Simpplr_Social_Analytics__c>)listToProcess;
			for(Simpplr_Social_Analytics__c obj : objList){
				obj.Sync_Status__c = isCountVerificationFailed && setOfFailedIds.contains(obj.id) ? (obj.Sync_Status__c + 1) : 5;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Social_Analytics__c>(objList), new List<Schema.SObjectField>{
				Simpplr_Social_Analytics__c.Sync_Status__c
			});
        }
    }
    
    public void finish(Database.BatchableContext BC) {
    	
		if(runNextBatchInSequence){
			if('analytics_adoption'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_content_count', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
    		
    		}else if('analytics_content_count'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_feed_count', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	        
	        }else if('analytics_feed_count'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_login', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	        
	        }else if('analytics_login'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_page_view', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	        
	        }else if('analytics_page_view'.equalsIgnoreCase(recordType)) {
	        	BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_search_result_select', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	       
	        }else if('analytics_search_result_select'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_social_campaign', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	        
	        }else if('analytics_social_campaign'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_top_content', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	       
	        }else if('analytics_top_content'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_top_people', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	        
	        }else if('analytics_top_people'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_top_search', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	        
	        }else if('analytics_top_search'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_top_site', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	       
	        }else if('analytics_top_site'.equalsIgnoreCase(recordType)) {
	            BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_top_topic', runNextBatchInSequence);
	            Database.executeBatch(job,1000);
	       
	        }else if('analytics_top_topic'.equalsIgnoreCase(recordType)) {
				BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('social_analytics',runNextBatchInSequence);
	            Database.executeBatch(job,1000);
        	
        		
        	}else if('social_analytics'.equalsIgnoreCase(recordType)) {
        		if(SimpplrContext.isExternalAnalyticsEnabled == false) {
					App_Config__c appConfigObject = [select id, External_Analytics_Enabled__c from App_Config__c limit 1];
					appConfigObject.External_Analytics_Enabled__c = true;

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(appConfigObject, new List<Schema.SObjectField>{
							App_Config__c.External_Analytics_Enabled__c});

				}
        	}
    	}
	}
}