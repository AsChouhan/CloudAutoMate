public with sharing class ServiceNowIntegrationService {
	String commonErrorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.error_message');
	public List<ServiceNowWrapper.KnowledgeBaseWrapper> getKnowledgeBases(){
		List<ServiceNowWrapper.KnowledgeBaseWrapper> kbWrapperObjList = new List<ServiceNowWrapper.KnowledgeBaseWrapper>();
		try{
			if(SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
				Map<String,Object>  accessTokenResponseMap = getAccessTokenResponseMap(true);
				String accessToken = accessTokenResponseMap.get('access_token')!=null? String.valueOf(accessTokenResponseMap.get('access_token')):'';
				HttpRequest reqObj = new HttpRequest();
				reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getKBList');
				reqObj.setHeader('content-type','application/json');
				reqObj.setHeader('accept', 'application/json');
				reqObj.setMethod('POST');
				reqObj.setBody('{"accessToken":"'+accessToken+'","endpoint":"'+SimpplrContext.serviceNowInstanceUrl+'/api/now/table/kb_knowledge_base?sysparm_display_value=all&sysparm_query=active%3Dtrue%5EORDERBYtitle&sysparm_display_value=true","integrationname":"servicenow"}');
				Http httpObj = new Http();
				logger.logDebug('Servicenow.getKnowledgeBases()----Request Body----' + reqObj.getBody());
				HTTPResponse resObj = httpObj.send(reqObj);
				if (resObj.getStatusCode()== 200) { 
					String resBodyJSON = resObj.getBody();
					logger.logDebug('Servicenow.getKnowledgeBases()----Response Body----' + resBodyJSON);
					if(resBodyJSON.startsWithIgnoreCase('<!DOCTYPE html') == false){
						ServiceNowWrapper snWrapperObj = (ServiceNowWrapper)JSON.deserialize(resBodyJSON,ServiceNowWrapper.class);
						if('failure'.equalsIgnoreCase(snWrapperObj.status) == false){
							for(ServiceNowWrapper.ResultItem kb : snWrapperObj.result){
								ServiceNowWrapper.KnowledgeBaseWrapper kbWrapperObj = new ServiceNowWrapper.KnowledgeBaseWrapper();
								kbWrapperObj.id = kb.sys_id.display_value;
								kbWrapperObj.name = kb.title.display_value;
								kbWrapperObj.isDeleted = false;
								kbWrapperObjList.add(kbWrapperObj);
							
							}
						} else {
							logger.logError('Servicenow Exception:'+resObj.getBody());
							
							throw new SimpplrException(commonErrorMessage);
						}
					} else {
						logger.logError('Servicenow Exception:'+resObj.getBody());
						throw new SimpplrException(commonErrorMessage);
					}
				} else {
					logger.logError('Servicenow Exception:'+resObj.getBody());
					throw new SimpplrException(commonErrorMessage);
				}
				if(accessTokenResponseMap.get('isAccessTokenNew') == null){
					updateAppIntegRecord(JSON.serialize(accessTokenResponseMap));
				}
			}
		} catch(Exception ex){
			logger.logError('Servicenow Exception', ex);
			String errMsg = (ex instanceof SimpplrException) ? ex.getMessage() : commonErrorMessage;
			throw new SimpplrException(errMsg);
		}

        return kbWrapperObjList;
    }
    
	public List<String> getKnowledgeBaseIdList(String accessToken, String commaSeparatedKBIds){
		List<String> kbIdList = new List<String>();
		try{
			HttpRequest reqObj = new HttpRequest();
			reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getKBIdList');
			reqObj.setHeader('content-type','application/json');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setMethod('POST');
			reqObj.setBody('{"accessToken":"'+accessToken+'","endpoint":"'+SimpplrContext.serviceNowInstanceUrl+'/api/now/table/kb_knowledge_base?sysparm_display_value=all&sysparm_query=active%3Dtrue%5Esys_idIN'+commaSeparatedKBIds+'%5EORDERBYtitle&sysparm_display_value=true","integrationname":"servicenow"}');
			Http httpObj = new Http();
			logger.logDebug('Servicenow.getKnowledgeBaseIdList()----Request Body----' + reqObj.getBody());
			HTTPResponse resObj = httpObj.send(reqObj);
			if (resObj.getStatusCode()== 200) { 
				String resBodyJSON = resObj.getBody();
				logger.logDebug('Servicenow.getKnowledgeBaseIdList()----Response Body----' + resBodyJSON);
				if(resBodyJSON.startsWithIgnoreCase('<!DOCTYPE html') == false){
					ServiceNowWrapper snWrapperObj = (ServiceNowWrapper)JSON.deserialize(resBodyJSON,ServiceNowWrapper.class);
					if('failure'.equalsIgnoreCase(snWrapperObj.status) == false){
						for(ServiceNowWrapper.ResultItem kb : snWrapperObj.result){
							kbIdList.add(kb.sys_id.display_value);
						}
					} else {
						logger.logError('Servicenow Exception:'+resObj.getBody());
						throw new SimpplrException(commonErrorMessage);
					}
				} else {
					logger.logError('Servicenow Exception:'+resObj.getBody());
					throw new SimpplrException(commonErrorMessage);
				}
			} else {
				logger.logError('Servicenow Exception:'+resObj.getBody());
				throw new SimpplrException(commonErrorMessage);
			}
				
		} catch(Exception ex){
			logger.logError('Servicenow Exception', ex);
			throw new SimpplrException(commonErrorMessage);
		}

        return kbIdList;
    }

    public Map<String,Object> getKnowledgeBaseItems(String searchTerm, Integer nextPageToken, Integer size){
		Map<String,Object> resultmap = new Map<String,Object>();
		try{
			List<ServiceNowWrapper.KBItemSearchWrapper> kbItemWrapperObjList = new List<ServiceNowWrapper.KBItemSearchWrapper>();
			if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
				String storedKBJSON = SimpplrContext.ServiceNowKnowledgeBasesJSON;
				Map<String,Object>  accessTokenResponseMap = new Map<String,Object>();
				if(String.isNotBlank(storedKBJSON)){
					List<ServiceNowWrapper.KnowledgeBaseWrapper> storedKBList = (List<ServiceNowWrapper.KnowledgeBaseWrapper>)JSON.deserialize(storedKBJSON, List<ServiceNowWrapper.KnowledgeBaseWrapper>.class);
					accessTokenResponseMap = getAccessTokenResponseMap(false);
					String accessToken = accessTokenResponseMap.get('access_token')!=null? String.valueOf(accessTokenResponseMap.get('access_token')):'';
					String KBIds = '';
					for(ServiceNowWrapper.KnowledgeBaseWrapper kbObj : storedKBList){
						KBIds = KBIds + kbObj.id +',';
					}
					KBIds = KBIds.removeEnd(',');
					List<String> KBIdList = getKnowledgeBaseIdList(accessToken, KBIds);
					String commaSeparatedKBIds = '';
					for(String kbId : KBIdList){
						commaSeparatedKBIds = commaSeparatedKBIds + kbId +',';
					}
					commaSeparatedKBIds = commaSeparatedKBIds.removeEnd(',');
					commaSeparatedKBIds = EncodingUtil.urlEncode(commaSeparatedKBIds,'UTF-8');
					
					HttpRequest reqObj = new HttpRequest();
					reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getKnowledgeBaseItems');
					reqObj.setHeader('content-type','application/json');
					reqObj.setHeader('accept', 'application/json');
					reqObj.setMethod('POST');
					
					Map<String, Object> requestBody = new Map<String, Object>();
					requestBody.put('accessToken',accessToken);
					requestBody.put('endpoint',SimpplrContext.serviceNowInstanceUrl+'/api/now/table/kb_knowledge?sysparm_display_value=all&sysparm_query=kb_knowledge_base.sys_idIN'+commaSeparatedKBIds+'%5Eworkflow_state%3Dpublished%5E123TEXTQUERY321LIKE'+searchTerm+'&sysparm_limit='+size+'&sysparm_offset='+nextPageToken);
					requestBody.put('integrationname','servicenow');
					
					reqObj.setBody(JSON.serialize(requestBody));
					Http httpObj = new Http();
					HTTPResponse resObj = httpObj.send(reqObj);
					if (resObj.getStatusCode()== 200) {
						String resBodyJSON = resObj.getBody();
						String resHeaderJSON = resObj.getHeader('headerData');
						if(resBodyJSON.startsWithIgnoreCase('<!DOCTYPE html') == false){
							ServiceNowWrapper snWrapperObj = (ServiceNowWrapper)JSON.deserialize(resBodyJSON.replaceAll('"number":', '"number_x":'),ServiceNowWrapper.class);
							ServiceNowWrapper.Header headerObj = (ServiceNowWrapper.Header)JSON.deserialize(resHeaderJSON.replaceAll('"x-total-count":', '"size":'),ServiceNowWrapper.Header.class);
							if('failure'.equalsIgnoreCase(snWrapperObj.status) == false){
								for(ServiceNowWrapper.ResultItem kb : snWrapperObj.result){
									ServiceNowWrapper.KnowledgeBaseWrapper kbWrapperObj = new ServiceNowWrapper.KnowledgeBaseWrapper();
									kbWrapperObj.id = kb.sys_id.display_value;
									if(kb.short_description == null){
										logger.logDebug('short_description is missing ' +kb);
										continue;
									}
									kbWrapperObj.title = kb.short_description.display_value;
									if(kb.sys_updated_on != null && kb.sys_updated_on.value != null){
										kbWrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(DateTime.valueOfGmt(kb.sys_updated_on.value));
									}
									ServiceNowWrapper.KBCategoryWrapper categoryWrappperObj = new ServiceNowWrapper.KBCategoryWrapper();
									if(kb.kb_category != null){
										categoryWrappperObj.name = kb.kb_category.display_value;
									}
									kbWrapperObj.category = categoryWrappperObj;
									kbWrapperObj.url = '';
									if(kb.number_x != null){
										if(String.isNotBlank(SimpplrContext.serviceNowCustomKnowledgebaseUrl)){ 
											kbWrapperObj.url = SimpplrContext.serviceNowCustomKnowledgebaseUrl.replace('{{sys_kb_id}}', 'sys_kb_id='+kb.sys_id.display_value);	
										}else{
											kbWrapperObj.url = SimpplrContext.serviceNowInstanceUrl +'/nav_to.do?uri=%2Fkb_view.do%3Fsysparm_article%3D'+kb.number_x.display_value;	
										}
									}
									ServiceNowWrapper.KBItemSearchWrapper kbIttemWrapperObj = new ServiceNowWrapper.KBItemSearchWrapper();
									kbIttemWrapperObj.itemType = 'knowledgebase';
									kbIttemWrapperObj.item = kbWrapperObj;
									kbItemWrapperObjList.add(kbIttemWrapperObj);

								}
								resultmap.put('listOfItems',kbItemWrapperObjList);
								resultmap.put('totalRecords',headerObj.size);
								
								Integer offset = 0;
								if((size + nextPageToken) >= headerObj.size){
									offset = null;
								} else {
									offset = size + nextPageToken;
								}
								resultmap.put('nextPageToken',offset);
							} else {
								logger.logError('Servicenow Exception:'+resObj.getBody());
								throw new SimpplrException(commonErrorMessage);		
							}

						} else {
							logger.logError('Servicenow Exception:'+resObj.getBody());
							throw new SimpplrException(commonErrorMessage);
						}
					} else {
						logger.logError('Servicenow Exception:'+resObj.getBody());
						throw new SimpplrException(commonErrorMessage);
					}
				}
				if(accessTokenResponseMap.get('isAccessTokenNew') == null){
					updatePeopleIntegRecord(accessTokenResponseMap);
				}
			}
		} catch(Exception ex){
			logger.logError('Servicenow Exception', ex);
			String errMsg = (ex instanceof SimpplrException) ? ex.getMessage() : commonErrorMessage;
			throw new SimpplrException(errMsg);		
		}
		return resultmap;
    }

	public Map<String,Object> getIncidents(String searchTerm, Integer nextPageToken, Integer size, String sortOrder, String filter){
		Map<String,Object> resultmap = new Map<String,Object>(); 
		try{
			List<ServiceNowWrapper.KnowledgeBaseWrapper> incidentList = new List<ServiceNowWrapper.KnowledgeBaseWrapper>();
			if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
				Map<String,Object>  accessTokenResponseMap = getAccessTokenResponseMap(false);
				String accessToken = accessTokenResponseMap.get('access_token')!=null? String.valueOf(accessTokenResponseMap.get('access_token')):'';
				HttpRequest reqObj = new HttpRequest();
				reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getIncidents');
				reqObj.setHeader('content-type','application/json');
				reqObj.setHeader('accept', 'application/json');
				reqObj.setMethod('POST');
				String body = '{"accessToken":"'+accessToken+'","endpoint":"'+SimpplrContext.serviceNowInstanceUrl+'/api/now/table/incident?sysparm_display_value=all&sysparm_query=caller_id%3Djavascript%3Ags.getUserID()%3B%5EORDERBY' + sortOrder + filter + '&sysparm_display_value=true&sysparm_limit='+size + '&sysparm_offset='+nextPageToken+'","integrationname":"servicenow"}';
				if('sys_updated_on'.equalsIgnoreCase(filter) == false ){
					body = '{"accessToken":"'+accessToken+'","endpoint":"'+SimpplrContext.serviceNowInstanceUrl+'/api/now/table/incident?sysparm_display_value=all&sysparm_query=caller_id%3Djavascript%3Ags.getUserID()%3B%5EORDERBY' + sortOrder + filter + '%5EORDERBYDESCsys_updated_on&sysparm_display_value=true&sysparm_limit='+size + '&sysparm_offset='+nextPageToken+'","integrationname":"servicenow"}';
				}
				logger.logDebug('Servicenow.getIncidents()----Request Body----' + body);
				reqObj.setBody(body);				
				Http httpObj = new Http();
				HTTPResponse resObj = httpObj.send(reqObj);
				
				if (resObj.getStatusCode()== 200) {
					String resBodyJSON = resObj.getBody();
					logger.logDebug('Servicenow.getIncidents()----Response Body----' + resBodyJSON);
					String resHeaderJSON = resObj.getHeader('headerData');
					if(resBodyJSON.startsWithIgnoreCase('<!DOCTYPE html') == false){
						resBodyJSON = resBodyJSON.replaceAll('"number":', '"number_x":');
						
						ServiceNowWrapper snWrapperObj = (ServiceNowWrapper)JSON.deserialize(resBodyJSON,ServiceNowWrapper.class);
						if('failure'.equalsIgnoreCase(snWrapperObj.status) == false){
							ServiceNowWrapper.Header headerObj = (ServiceNowWrapper.Header)JSON.deserialize(resHeaderJSON.replaceAll('"x-total-count":', '"size":'),ServiceNowWrapper.Header.class);
							for(ServiceNowWrapper.ResultItem kb : snWrapperObj.result){
								ServiceNowWrapper.KnowledgeBaseWrapper kbWrapperObj = new ServiceNowWrapper.KnowledgeBaseWrapper();
								kbWrapperObj.id = kb.number_x.display_value;
								kbWrapperObj.status = kb.state.display_value;
								kbWrapperObj.title = kb.short_description.display_value;
								kbWrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(DateTime.valueOfGmt(kb.sys_updated_on.value));
								if(String.isNotBlank(SimpplrContext.customServiceNowTicketsUrl)){
									kbWrapperObj.url = SimpplrContext.customServiceNowTicketsUrl.replace('{{sys_id}}', 'sys_id='+kb.sys_id.value);	
								}else{
									kbWrapperObj.url = SimpplrContext.serviceNowInstanceUrl +'/incident.do?sys_id='+kb.sys_id.value+'&sysparm_view=&sysparm_record_target=incident&sysparm_record_row=1&sysparm_record_rows=1&sysparm_record_list=caller_id%3Djavascript%3Ags.getUserID%28%29%5Eactive%3Dtrue%5E';
								}
								incidentList.add(kbWrapperObj);

							}
							resultmap.put('listOfItems',incidentList);
							resultmap.put('totalRecords',headerObj.size);
							
							Integer offset = 0;
							if((size + nextPageToken) >= headerObj.size){
								offset = null;
							} else {
								offset = size + nextPageToken;
							}
							resultmap.put('nextPageToken',offset);
						} else {
							logger.logError('Servicenow Exception:'+resObj.getBody());
							throw new SimpplrException(commonErrorMessage);		
						}

					} else {
						logger.logError('Servicenow Exception:'+resObj.getBody());
						throw new SimpplrException(commonErrorMessage);		
					}
				} else {
					logger.logError('Servicenow Exception:'+resObj.getBody());
					throw new SimpplrException(commonErrorMessage);		
				}
				if(accessTokenResponseMap.get('isAccessTokenNew') == null){
					updatePeopleIntegRecord(accessTokenResponseMap);
				}
			}
		} catch(Exception ex){
			logger.logError('Servicenow Exception:', ex);
			String errMsg = (ex instanceof SimpplrException) ? ex.getMessage() : commonErrorMessage;
			throw new SimpplrException(errMsg);		
		}
		return resultmap;
    }
	

    public ServiceNowWrapper.KnowledgeBaseWrapper createIncident(String category, String subCategory, String urgency, String shortDescription,String description, Integer attachmentCount, String impact){
		ServiceNowWrapper.KnowledgeBaseWrapper kbWrapperObj = new ServiceNowWrapper.KnowledgeBaseWrapper();
        try{
			if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
				Map<String,Object>  accessTokenResponseMap = getAccessTokenResponseMap(false);
				String accessToken = accessTokenResponseMap.get('access_token')!=null? String.valueOf(accessTokenResponseMap.get('access_token')):'';
				HttpRequest reqObj = new HttpRequest();
				reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=createIncident');
				reqObj.setHeader('content-type','application/json');
				reqObj.setHeader('accept', 'application/json');
				reqObj.setMethod('POST');
				
				Map<String, Object> incidentBody = new Map<String, Object>();
				if(String.isNotBlank(impact)) {
					incidentBody.put('impact', impact);
				}
				incidentBody.put('state', 'New');
				incidentBody.put('short_description', shortDescription);
				incidentBody.put('urgency', urgency);
				incidentBody.put('category', category);
				incidentBody.put('subcategory', subCategory);
				incidentBody.put('description', description);
				incidentBody.put('caller_id', UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).External_id__c);

				Map<String, Object> requestBody = new Map<String, Object>();
				requestBody.put('accessToken', accessToken);
				requestBody.put('endpoint', SimpplrContext.serviceNowInstanceUrl+'/api/now/v1/table/incident');
				requestBody.put('integrationname', 'servicenow');
				requestBody.put('data', incidentBody);
				requestBody.put('method', 'POST');
				requestBody.put('orgId', SimpplrContext.simpplrOrgId);
				requestBody.put('peopleId', UserContext.peopleId);
				requestBody.put('attachmentCount', attachmentCount);
				reqObj.setBody(Json.serialize(requestBody));								
				
				logger.logDebug('Servicenow.createIncident()----Request Body----' + reqObj.getBody());
				Http httpObj = new Http();
				HTTPResponse resObj = httpObj.send(reqObj);
				logger.logDebug('Servicenow.createIncident()----Response Body----' + resObj.getBody());
				if (resObj.getStatusCode()== 200) {
					String resBodyJSON = resObj.getBody();
					String resHeaderJSON = resObj.getHeader('headerData');
					if(resBodyJSON.startsWithIgnoreCase('<!DOCTYPE html') == false){
						resBodyJSON = resBodyJSON.replaceAll('"number":', '"incident_number_x":');
						resBodyJSON = resBodyJSON.replaceAll('"sys_id":', '"incident_sys_id":');
						resBodyJSON = resBodyJSON.replaceAll('"state":', '"new_incident_state":');
						resBodyJSON = resBodyJSON.replaceAll('"priority":', '"new_incident_priority":');
						resBodyJSON = resBodyJSON.replaceAll('"sys_updated_on":', '"incident_sys_updated_on":');
						resBodyJSON = resBodyJSON.replaceAll('"short_description":', '"incident_short_description":');
						
						ServiceNowWrapper.CreateIncidentWrapper snWrapperObj = (ServiceNowWrapper.CreateIncidentWrapper)JSON.deserialize(resBodyJSON,ServiceNowWrapper.CreateIncidentWrapper.class);
						if('failure'.equalsIgnoreCase(snWrapperObj.status) == false){
							kbWrapperObj.id = snWrapperObj.result.incident_number_x;
							kbWrapperObj.sysId = snWrapperObj.result.incident_sys_id; 
							kbWrapperObj.status = 'New';
							kbWrapperObj.impact = impact;
							Map<String,String> priorityValMap = new Map<String,String>{'1'=>'Critical','2'=>'High','3'=>'Moderate','4'=>'Low','5'=>'Planning'};
							kbWrapperObj.priority = priorityValMap.get(snWrapperObj.result.new_incident_priority);
							kbWrapperObj.title = snWrapperObj.result.incident_short_description;
							kbWrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(DateTime.now());
							kbWrapperObj.url = SimpplrContext.serviceNowInstanceUrl +'/incident.do?sys_id='+snWrapperObj.result.incident_sys_id;
						} else {
							throw new SimpplrException(commonErrorMessage);		
						}
					} else {
						throw new SimpplrException(commonErrorMessage);		
					}
				} else {
					throw new SimpplrException(commonErrorMessage);		
				}
				if(accessTokenResponseMap.get('isAccessTokenNew') == null){
					updatePeopleIntegRecord(accessTokenResponseMap);
				}
			}
		} catch(Exception ex){
			logger.logError('Servicenow Exception:',ex);
			String errMsg = (ex instanceof SimpplrException) ? ex.getMessage() : commonErrorMessage;
			throw new SimpplrException(errMsg);		
		}
		return kbWrapperObj;
    }

	public List<ServiceNowWrapper.KBCategoryWrapper> getCategory(){
		List<ServiceNowWrapper.KBCategoryWrapper> catList = new List<ServiceNowWrapper.KBCategoryWrapper>();
        try{
			if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
				Map<String,Object>  accessTokenResponseMap = getAccessTokenResponseMap(false);
				String accessToken = accessTokenResponseMap.get('access_token')!=null? String.valueOf(accessTokenResponseMap.get('access_token')):'';
				HttpRequest reqObj = new HttpRequest();
				reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getCategory');
				reqObj.setHeader('content-type','application/json');
				reqObj.setHeader('accept', 'application/json');
				reqObj.setMethod('POST');
				String bodyDataJSON = '{}';
				reqObj.setBody('{"accessToken":"'+accessToken+'","endpoint":"'+SimpplrContext.serviceNowInstanceUrl+'/api/now/table/sys_choice?sysparm_query=name=incident^element=category^inactive=false&sysparm_fields=label,value,inactive","integrationname":"servicenow","data":'+bodyDataJSON+',"method":"GET"}');
				Http httpObj = new Http();
				HTTPResponse resObj = httpObj.send(reqObj);
				if (resObj.getStatusCode()== 200) {
					String resBodyJSON = resObj.getBody();
					logger.logDebug('ServiceNowIntegrationService.getCategory()----Response Body----' + resBodyJSON);
					if(resBodyJSON.startsWithIgnoreCase('<!DOCTYPE html') == false){
						ServiceNowWrapper snWrapperObj = (ServiceNowWrapper)JSON.deserialize(resBodyJSON,ServiceNowWrapper.class);
						if('failure'.equalsIgnoreCase(snWrapperObj.status) == false){
							for(ServiceNowWrapper.ResultItem itemObj : snWrapperObj.result){
								ServiceNowWrapper.KBCategoryWrapper catObj = new ServiceNowWrapper.KBCategoryWrapper();
								catObj.id = itemObj.value;
								catObj.name = itemObj.label;
								catList.add(catObj);
							}
						} else {
							logger.logError('Servicenow Exception:'+resObj.getBody());
							if(resObj.getBody().containsIgnoreCase('Insufficient rights to query records')){
								return catList;
							}
							throw new SimpplrException(commonErrorMessage);		
						}
						
					} else {
						logger.logError('Servicenow Exception:'+resObj.getBody());
						throw new SimpplrException(commonErrorMessage);		
					}
				} else {
					logger.logError('Servicenow Exception:'+resObj.getBody());
					throw new SimpplrException(commonErrorMessage);		
				}
				if(accessTokenResponseMap.get('isAccessTokenNew') == null){
					updatePeopleIntegRecord(accessTokenResponseMap);
				}
			}
		} catch(Exception ex){
			logger.logError('Servicenow Exception:',ex);
			String errMsg = (ex instanceof SimpplrException) ? ex.getMessage() : commonErrorMessage;
			throw new SimpplrException(errMsg);		
		}
		return catList;
    }


	public List<String> getSubcategory(String categoryName){
		List<String> subCatList = new List<String>();
        try{
			if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
				Map<String,Object>  accessTokenResponseMap = getAccessTokenResponseMap(false);
				String accessToken = accessTokenResponseMap.get('access_token')!=null? String.valueOf(accessTokenResponseMap.get('access_token')):'';
				HttpRequest reqObj = new HttpRequest();
				reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getSubcategory');
				reqObj.setHeader('content-type','application/json');
				reqObj.setHeader('accept', 'application/json');
				reqObj.setMethod('POST');
				String bodyDataJSON = '{}';
				reqObj.setBody('{"accessToken":"'+accessToken+'","endpoint":"'+SimpplrContext.serviceNowInstanceUrl+'/api/now/table/sys_choice?sysparm_query=name=incident^element=subcategory^inactive=false^dependent_value='+categoryName+'&sysparm_fields=label","integrationname":"servicenow","data":'+bodyDataJSON+',"method":"GET"}');
				Http httpObj = new Http();
				HTTPResponse resObj = httpObj.send(reqObj);
				if (resObj.getStatusCode()== 200) {
					String resBodyJSON = resObj.getBody();
					String resHeaderJSON = resObj.getHeader('headerData');
					if(resBodyJSON.startsWithIgnoreCase('<!DOCTYPE html') == false){
						ServiceNowWrapper snWrapperObj = (ServiceNowWrapper)JSON.deserialize(resBodyJSON,ServiceNowWrapper.class);
						if('failure'.equalsIgnoreCase(snWrapperObj.status) == false){
							for(ServiceNowWrapper.ResultItem itemObj : snWrapperObj.result){
								subCatList.add(itemObj.label);
							}
						} else {
							logger.logError('Servicenow Exception:'+resObj.getBody());
							throw new SimpplrException(commonErrorMessage);		
						}	
					} else {
						logger.logError('Servicenow Exception:'+resObj.getBody());
						throw new SimpplrException(commonErrorMessage);			
					}
				} else {
					logger.logError('Servicenow Exception:'+resObj.getBody());
					throw new SimpplrException(commonErrorMessage);		
				}
				if(accessTokenResponseMap.get('isAccessTokenNew') == null){
					updatePeopleIntegRecord(accessTokenResponseMap);
				}
			}
		} catch(Exception ex){
			logger.logError('Servicenow Exception:',ex);
			String errMsg = (ex instanceof SimpplrException) ? ex.getMessage() : commonErrorMessage;
			throw new SimpplrException(errMsg);		
		}
		
		return subCatList;
    }
	@testVisible
    private Map<String,Object> getAccessTokenResponseMap(Boolean isServiceNowAdmin){
        Map<String,Object> resBodyMap =   new Map<String,Object>();
		if(isAccessTokenExpired(isServiceNowAdmin) == true){
			Blob headerValue = Blob.valueOf(Utility.decryptFn(SimpplrContext.ServiceNowClientId) + ':' + Utility.decryptFn(SimpplrContext.ServiceNowClientSecret));
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

			HttpRequest reqObj = new HttpRequest();
			reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getaccesstoken');
			reqObj.setHeader('content-type','application/x-www-form-urlencoded');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setMethod('POST');
			String redUrl = EncodingUtil.urlEncode('https://services.simpplr.com/oauth/redirect/code_passthrough.php', 'UTF-8');
			String clientId = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Id__c;
			String clientSecret = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Secret__c;
			String refreshToken = isServiceNowAdmin==true?SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).App_Refresh_Token__c:UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Refresh_Token__c;
			reqObj.setBody('{"refreshToken":"'+refreshToken+'","grantType":"refresh_token","tokenUrl":"'+SimpplrContext.serviceNowInstanceUrl+'/oauth_token.do","integrationname":"servicenow","redirectUrl":"'+redUrl+'","scope":"useraccount","clientId":"'+Utility.decryptFn(clientId)+'","clientSecret":"'+Utility.decryptFn(clientSecret)+'","method":"POST", "authorizationHeader": "'+authorizationHeader+'"}');
			Http httpObj = new Http();
			logger.logDebug('ServiceNowIntegrationService.getAccessTokenResponseMap()----Request Body----' + reqObj.getBody());
			HTTPResponse resObj = httpObj.send(reqObj);
			if (resObj.getStatusCode()== 200) { 
				logger.logDebug('ServiceNowIntegrationService.getAccessTokenResponseMap()----Response Body----' + resObj.getBody());
				resBodyMap = (Map<String,Object>)JSON.deserializeUntyped(resObj.getBody());
			}
		} else {
			if(isServiceNowAdmin){
				if(SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
					resBodyMap.put('access_token',SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).App_Access_Token__c);
					resBodyMap.put('isAccessTokenNew',false);
				}
			} else {
				if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
					resBodyMap.put('access_token',UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Access_Token__c);
					resBodyMap.put('isAccessTokenNew',false);
				}
			}
		}
		if(String.isBlank(String.valueOf(resBodyMap.get('access_token')))) {
			throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey, 'servicenow.must.connected'));
		}
        return resBodyMap;
    }

	@testVisible
	private void updatePeopleIntegRecord(Map<String,Object> resBody){
		if(resBody != null && resBody.keySet().isEmpty() == false){
			People_Integration__c peopleIntegObj = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
			peopleIntegObj.Access_Token__c = String.valueOf(resBody.get('access_token'));
			peopleIntegObj.Refresh_Token__c = String.valueOf(resBody.get('refresh_token'));
			peopleIntegObj.Access_Token_Expiry__c =  (Decimal)resBody.get('expires_in');
			peopleIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(peopleIntegObj.Access_Token_Expiry__c.intValue());
			peopleIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
			peopleIntegObj.Name = IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW;
			peopleIntegObj.Connected__c = true;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(peopleIntegObj, new List<Schema.SObjectField>{
					People_Integration__c.Access_Token__c,
					People_Integration__c.Refresh_Token__c,
					People_Integration__c.Access_Token_Expiry__c,
					People_Integration__c.Access_Token_Expiration_Datetime__c,
					People_Integration__c.Access_Token_Requested_Datetime__c,
					People_Integration__c.Connected__c,
					People_Integration__c.Name
			});
		}
	}

	@future
	private static void updateAppIntegRecord(String resBodyString){
		Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyString);
		if(resBody != null && resBody.keySet().isEmpty() == false){
			App_Integration__c appIntegObj = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
			appIntegObj.App_Access_Token__c = String.valueOf(resBody.get('access_token'));
			appIntegObj.App_Refresh_Token__c = String.valueOf(resBody.get('refresh_token'));
			appIntegObj.Access_Token_Expiry__c =  (Decimal)resBody.get('expires_in');
			appIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(appIntegObj.Access_Token_Expiry__c.intValue());
			appIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
			appIntegObj.Name = IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW;
			appIntegObj.Connected__c = true;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(appIntegObj, new List<Schema.SObjectField>{
					App_Integration__c.App_Access_Token__c,
					App_Integration__c.App_Refresh_Token__c,
					App_Integration__c.Access_Token_Expiry__c,
					App_Integration__c.Access_Token_Expiration_Datetime__c,
					App_Integration__c.Access_Token_Requested_Datetime__c,
					App_Integration__c.Connected__c,
					App_Integration__c.Name
			});
		}
	}

	public Boolean isAccessTokenExpired(Boolean isServiceNowAdmin){
        Boolean isAccessTokenExpired = true;
		DateTime tokenRequestDateTime;
		if(isServiceNowAdmin){
			tokenRequestDateTime = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null ? SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Access_Token_Requested_Datetime__c.addMinutes(-5): null;
		} else {
			tokenRequestDateTime = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null ? UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Access_Token_Requested_Datetime__c.addMinutes(-5): null;
		}
		if(tokenRequestDateTime != null){
			Long tokenExpiryInMilliSeconds;
			if(isServiceNowAdmin){
				tokenExpiryInMilliSeconds = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null ? SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Access_Token_Expiry__c.longValue(): null;
			} else {
				tokenExpiryInMilliSeconds = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null ? UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Access_Token_Expiry__c.longValue(): null;
			}
			Long tokenExpiryFromRequestedTimeInMS = tokenRequestDateTime.getTime() + (tokenExpiryInMilliSeconds*1000);
			Long currentDateTimeInMilliSeconds = (DateTime.now()).getTime();
			if(tokenExpiryFromRequestedTimeInMS > currentDateTimeInMilliSeconds){
				isAccessTokenExpired = false;
			}
		}
		return isAccessTokenExpired;
    }

	public void revokeAccessToken(){
		Boolean isSuccess = false;
		String accessToken = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null ? UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Access_Token__c:'';
		HttpRequest reqObj = new HttpRequest();
		reqObj.setEndpoint(SimpplrContext.serviceNowInstanceUrl+'/oauth_revoke_token.do?token='+accessToken);
		reqObj.setHeader('content-type','application/json');
		reqObj.setHeader('accept', 'application/json');
		reqObj.setMethod('GET');
		Http httpObj = new Http();
		HTTPResponse resObj = httpObj.send(reqObj);
		People_Integration__c peopleIntegObj = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
				peopleIntegObj.Access_Token_Expiry__c =  0;
				peopleIntegObj.Connected__c = true;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(peopleIntegObj, new List<Schema.SObjectField>{
						People_Integration__c.Access_Token_Expiry__c,
						People_Integration__c.Connected__c
				});
			
	}

	public ServiceNowWrapper.SNWrapper getSupportIntegrationsConfig(){   
		
		ServiceNowWrapper.SNWrapper integrationWrapperServicenowObj = new ServiceNowWrapper.SNWrapper();
		integrationWrapperServicenowObj.snEnabled = SimpplrContext.serviceNowIntegrationEnabled;
		integrationWrapperServicenowObj.snConnectedAs = SimpplrContext.serviceNowUserName;
		integrationWrapperServicenowObj.snKeysSaved = SimpplrContext.serviceNowIntegrationEnabled;
		integrationWrapperServicenowObj.servicenowInstanceUrl = SimpplrContext.serviceNowInstanceUrl;
		integrationWrapperServicenowObj.isSNTicketingDefaultSelected = String.isBlank(SimpplrContext.serviceNowCustomTicketingName);
		integrationWrapperServicenowObj.isSNKnowledgeDefaultSelected = String.isBlank(SimpplrContext.serviceNowCustomKBName);
		integrationWrapperServicenowObj.customSNTicketingSystemName = SimpplrContext.serviceNowCustomTicketingName;
		integrationWrapperServicenowObj.customSNKnowledgebaseName = SimpplrContext.serviceNowCustomKBName;
		integrationWrapperServicenowObj.snKnowledgebaseEnabled = SimpplrContext.isServiceNowKnowledgebaseEnabled;
		integrationWrapperServicenowObj.snTicketEnabled = SimpplrContext.isServiceNowTicketEnabled;
		integrationWrapperServicenowObj.snTicketCreationEnabled = SimpplrContext.isServiceNowTicketCreationEnabled;
		integrationWrapperServicenowObj.snNotificationsEnabled = false;
		integrationWrapperServicenowObj.isSNKnowledgebaseUrlDefaultSelected = String.isBlank(SimpplrContext.serviceNowCustomKnowledgebaseUrl);
		integrationWrapperServicenowObj.isSNTicketsUrlDefaultSelected = String.isBlank(SimpplrContext.customServiceNowTicketsUrl);
		integrationWrapperServicenowObj.customSNKnowledgebaseUrl = SimpplrContext.serviceNowCustomKnowledgebaseUrl;
		integrationWrapperServicenowObj.customServiceNowTicketsUrl = SimpplrContext.customServiceNowTicketsUrl;
		if(SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SALESFORCE) != null){
			integrationWrapperServicenowObj.snNotificationsEnabled = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SALESFORCE).Integration_Enabled__c;
		} 
		String storedKBJson = String.isBlank(SimpplrContext.ServiceNowKnowledgeBasesJSON) ? '[]' : SimpplrContext.ServiceNowKnowledgeBasesJSON;
		integrationWrapperServicenowObj.kbWrapperList = (List<ServiceNowWrapper.KnowledgeBaseWrapper>)JSON.deserialize(storedKBJson, List<ServiceNowWrapper.KnowledgeBaseWrapper>.class);		
		
		return integrationWrapperServicenowObj;
	}

	public Boolean refreshServiceNowToken(Boolean isAdminToken){
		Boolean isSuccess = false;
		try{
			Blob headerValue = Blob.valueOf(Utility.decryptFn(SimpplrContext.ServiceNowClientId) + ':' + Utility.decryptFn(SimpplrContext.ServiceNowClientSecret));
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

			HttpRequest reqObj = new HttpRequest();
			reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getaccesstoken');
			reqObj.setHeader('content-type','application/x-www-form-urlencoded');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setMethod('POST');
			String redUrl = EncodingUtil.urlEncode('https://services.simpplr.com/oauth/redirect/code_passthrough.php', 'UTF-8');
			String clientId = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Id__c;
			String clientSecret = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Client_Secret__c;
			String refreshToken = isAdminToken==true?SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).App_Refresh_Token__c:UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Refresh_Token__c;
			reqObj.setBody('{"refreshToken":"'+refreshToken+'","grantType":"refresh_token","tokenUrl":"'+SimpplrContext.serviceNowInstanceUrl+'/oauth_token.do","integrationname":"servicenow","redirectUrl":"'+redUrl+'","scope":"useraccount","clientId":"'+Utility.decryptFn(clientId)+'","clientSecret":"'+Utility.decryptFn(clientSecret)+'","method":"POST", "authorizationHeader": "'+authorizationHeader+'"}');
			Http httpObj = new Http();
			logger.logDebug('ServiceNowIntegrationService.refreshServiceNowToken()----Request Body----' + reqObj.getBody());
			HTTPResponse resObj = httpObj.send(reqObj);
			if (resObj.getStatusCode()== 200) { 
				String resBodyJSON = resObj.getBody();
				logger.logDebug('ServiceNowIntegrationService.refreshServiceNowToken()----Response Body----' + resBodyJSON);
				Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
				isSuccess = true;
				if(String.isNotBlank(String.valueOf(resBody.get('error')))) {
					isSuccess = false;
				} else if(isAdminToken ==  true){
					String orgId = UserInfo.getOrganizationId();
					String appIntQuery = 'Select Id, Connected__c, App_Access_Token__c, App_Refresh_Token__c, User_Name__c, External_id__c,'
													+ ' Access_Token_Expiry__c, Access_Token_Expiration_Datetime__c,'
													+ ' Access_Token_Requested_Datetime__c From App_Integration__c'
													+ ' Where  Name =: soqlParam1'
													+ ' AND Integration_Enabled__c=true'
													+ ' AND Org_Id__c =: soqlParam1'
													+ ' AND Is_Deleted__c = false limit 1';
					Map<String, Object> sqlParamMap = new Map<String, Object>();
					sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
					sqlParamMap.put('soqlParam2', orgId);
			
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					App_integration__c appIntegObj = ((List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap))[0];

					appIntegObj.App_Access_Token__c = String.valueOf(resBody.get('access_token'));
					appIntegObj.App_Refresh_Token__c = String.valueOf(resBody.get('refresh_token'));		
					appIntegObj.Access_Token_Expiry__c =  (Decimal)resBody.get('expires_in');
					appIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(appIntegObj.Access_Token_Expiry__c.intValue());
					appIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
					
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().updateAsUser(appIntegObj, new List<Schema.SObjectField>{
							App_Integration__c.App_Access_Token__c,
							App_Integration__c.App_Refresh_Token__c,
							App_Integration__c.Access_Token_Expiry__c,
							App_Integration__c.Access_Token_Expiration_Datetime__c,
							App_Integration__c.Access_Token_Requested_Datetime__c
					});
				} else {
					People_Integration__c peopleIntegObj = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
					peopleIntegObj.Access_Token__c = String.valueOf(resBody.get('access_token'));
					peopleIntegObj.Refresh_Token__c = String.valueOf(resBody.get('refresh_token'));
					peopleIntegObj.Access_Token_Expiry__c =  (Decimal)resBody.get('expires_in');
					peopleIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(peopleIntegObj.Access_Token_Expiry__c.intValue());
					peopleIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
					peopleIntegObj.Connected__c = true;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(peopleIntegObj, new List<Schema.SObjectField>{
							People_Integration__c.Access_Token__c,
							People_Integration__c.Refresh_Token__c,
							People_Integration__c.Access_Token_Expiry__c,
							People_Integration__c.Access_Token_Expiration_Datetime__c,
							People_Integration__c.Access_Token_Requested_Datetime__c,
							People_Integration__c.Connected__c
							
					});
				}
			}		
		} catch(Exception ex) {
			logger.logError('Servicenow Exception:',ex);
			isSuccess = false;
		}
		return isSuccess;
	}
	
}