@isTest
global class EFSHTTPMock implements HttpCalloutMock {
	public String requestType = '';
	public Boolean googledriveFlag = false;
	public Boolean dropboxFlag = false;
	public Boolean spFlag = false;
	public Boolean odFlag = false;
	
	public Boolean getFlag = false;
	public Boolean postFlag = false;
	public Boolean patchFlag = false;
	public Boolean deleteFlag = false;
	public Boolean putFlag = false;
	
	public EFSHTTPMock(String efsTyp) {
		if(String.isNotBlank(efsTyp)) {
			this.setStorageFlag(efsTyp);
		}
	}
		
	public EFSHTTPMock(String efsTyp, String reqType) {
		this.setStorageFlag(efsTyp);
		this.requestType = reqType;
    }

	private void setStorageFlag(String storage) {
		if(storage.equalsIgnoreCase('googledrive')) {
			this.googledriveFlag = true;
		} else if(storage.equalsIgnoreCase('dropbox')) {
			this.dropboxFlag = true;
		} else if(storage.equalsIgnoreCase('sharepoint')) {
			this.spFlag = true;
		} else if(storage.equalsIgnoreCase('onedrive')) {
			this.odFlag = true;
		}
	}

	global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();
        String method = req.getMethod();

    	if(method.equalsIgnoreCase('GET')) {
    		this.getFlag = true;
    	} else if(method.equalsIgnoreCase('POST')) {
    		this.postFlag = true;
    	} else if(method.equalsIgnoreCase('DELETE')) {
    		this.deleteFlag = true;
    	} else if(method.equalsIgnoreCase('PATCH')) {
    		this.patchFlag = true;
    	} else if(method.equalsIgnoreCase('PUT')) {
    		this.putFlag = true;
    	}  
    	 
        HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		// Default Values
		res.setStatusCode(200);
		res.setStatus('OK');  

		if(this.googledriveFlag) {
			res.setBody('{"status" : "success"}');
			
			if(this.getFlag) {
				
			} else if(this.postFlag) {
				if(endpoint.containsIgnoreCase('https://www.googleapis.com/admin/directory/v1/groups')) { 
					if (endpoint.containsIgnoreCase('members')) {
						GDAPIModelDirectory.Members memOut = (GDAPIModelDirectory.Members)JSON.deserialize(req.getBody(), GDAPIModelDirectory.Members.class);
        
						if(memOut.getEmail().containsIgnoreCase('badRequest')) { 
							throw new SCoreAppException(400,'badRequest');
						} else if (memOut.getEmail().containsIgnoreCase('httpConflict')) {
							throw new SCoreAppException(409,'httpConflict');
						} 
					} else {
						GDAPIModelDirectory.Groups grp = (GDAPIModelDirectory.Groups)JSON.deserialize(req.getBody(), GDAPIModelDirectory.Groups.class); 

						if(grp.getName() == 'Forbidden') { 
							res.setStatus('Forbidden'); 
							res.setStatusCode(409);
							res.setBody('{"status" : "just testing"}');
							throw new SCoreAppException(409,'status');
						} 
					}
				} else if(endpoint.containsIgnoreCase('addPermissionsToFolderForGroups')) {
					GoogleDriveModel.GroupPermissionResponse response = new GoogleDriveModel.GroupPermissionResponse();
					response.status = 'success';
					response.result = new GoogleDriveModel.GroupPermission();
					response.result.pubPermissionId = 'pubPermissionId';
					response.result.rPermissionId = 'rPermissionId';
					response.result.rWPermissionId = 'rWPermissionId';
					res.setBody(JSON.serialize(response));
				} else if(endpoint.containsIgnoreCase('getGoogleDriveDetails')) {
					res.setBody('{"status": "success","message": "Drive details fetched successfully.","result": {"kind": "drive#drive","id": "12345","name": "Test Folder123"}}');
				} else if(endpoint.containsIgnoreCase('getDriveFolders')) {
					res.setBody('{"status": "success","message": "","result": {"kind": "drive#fileList","incompleteSearch": false,"files": [{"kind": "drive#file","id": "12345","name": "Test Folder","mimeType": "application/vnd.google-apps.folder"}]}}');
				} else if(endpoint.containsIgnoreCase('getAllSharedDrives')) {
					res.setBody('{"status": "success","message": "","result": {"kind": "drive#driveList","nextPageToken": null,"drives": [{"kind": "drive#drive","id": "12345","name": "Test Drive"}]}}');
				} else {
					Map<String, Object> response = new Map<String, Object>();
					response.put('status', 'success');
					res.setBody(JSON.serialize(response));
				}
			} else if(this.deleteFlag) {
				if(endpoint.containsIgnoreCase('https://www.googleapis.com/admin/directory/v1/groups')) {
					if (endpoint.containsIgnoreCase('Forbidden')) {
						throw new SCoreAppException(404,'status');
					} else if (endpoint.containsIgnoreCase('BadRequest')) {
						throw new SCoreAppException(400,'status');
					}
				}
			} else if(this.patchFlag) {
				
			}
			
	        if(endpoint.equalsIgnoreCase('https://accounts.google.com/o/oauth2/auth')) {
		        if (endpoint.containsIgnoreCase('Forbidden') || req.getBody().containsIgnoreCase('Forbidden')) {
		  			throw new SCoreAppException(404,'statusCode');
		  		} else { 
		       		res.setBody('{"status" : "success", "code":"dummycode", "scope":"https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/admin.directory.group https://www.googleapis.com/auth/admin.directory.domain.readonly https://www.googleapis.com/auth/drive.appdata", "state":"googledriveadmin"}');  
		        }	      
	        } else if(endpoint.equalsIgnoreCase('https://accounts.google.com/o/oauth2/token?access_type=offline')) {
	            if (endpoint.containsIgnoreCase('Forbidden') || req.getBody().containsIgnoreCase('Forbidden')) {
		  			throw new SCoreAppException(404,'statusCode');
		  		} else { 
	           		res.setBody('{"access_token":"dummyaccesstoken", "expires_in":3600, "refresh_token":"dummyrefreshtoken", "token_type":"Bearer"}'); 
	            }	   
	        } else if(endpoint.equalsIgnoreCase('https://www.googleapis.com/drive/v3/about?fields=kind%2Cuser%2CstorageQuota')) {
	      		if (endpoint.containsIgnoreCase('Forbidden') || req.getBody().containsIgnoreCase('Forbidden')) {
		  			throw new SCoreAppException(404,'statusCode');
		  		} else { 
	               	res.setBody('{"kind": "drive#about","user": {"kind": "drive#user","displayName": "Amit Kumar","me": true,"permissionId": "11551083267734841420","emailAddress": "amit@bhootnath.in"},"storageQuota": {"limit": "16106127360","usage": "9788914","usageInDrive": "9788914","usageInDriveTrash": "0"}}');
	      		}    
	        } else if(endpoint.equalsIgnoreCase('https://www.googleapis.com/drive/v3/files')) {
		  	   	if(req.getBody().containsIgnoreCase('Forbidden')) {
		  			throw new SCoreAppException(404,'statusCode');
		  		} else if(req.getBody().containsIgnoreCase('TestCreateFolder') || 
		  				  req.getBody().containsIgnoreCase('TestRenameFolder') ||
		  				  req.getBody().containsIgnoreCase('"parents"')) {
		  			// Folder Response
		           res.setBody(GDAPITestDataFactory.createModelFileString('googledrivefolderexternalid', 'googledriveTESTFOLDER', true));
		  		} else {
		  			// File Response
		           res.setBody(GDAPITestDataFactory.createModelFileString('googledrivefileexternalid', 'googledriveTESTFILE.jpg', false));
		  	    }    
	        } else if(endpoint.contains('https://www.googleapis.com/drive/v3/files?q=')) {
	           	if(endpoint.containsIgnoreCase('Forbidden') || req.getBody().containsIgnoreCase('Forbidden')) {
		  			throw new SCoreAppException(404,'statusCode');
		  		} else {
	               	res.setBody('{"kind": "drive#fileList","files": []}');
	            }        
	        } else if(endpoint.containsIgnoreCase('https://www.googleapis.com/drive/v3/files/Forbidden')) {
	  			throw new SCoreAppException(404,'statusCode');
		  	} else if(endpoint.containsIgnoreCase('https://www.googleapis.com/drive/v3/files')) {
		  		if(endpoint.containsIgnoreCase('googledrivetestlinkfolderid')) {
		  			res.setBody(GDAPITestDataFactory.createModelFileString('googledrivefolderexternalid', 'googledriveTESTFOLDER', true));
		  		} else if(endpoint.containsIgnoreCase('/revisions')) {
		  			res.setBody('{"kind": "drive#revisionList", "revisions": [' + GDAPITestDataFactory.getRevisionString() + ']}');
		  		} else {
		  			res.setBody(GDAPITestDataFactory.createModelFileString('googledrivefileexternalid', 'googledriveTESTFILE.jpg', false));
		  		}
	        } else if(endpoint.equalsIgnoreCase('https://www.googleapis.com/batch/drive/v3')) {   
	            res.setHeader('Content-Type', req.getHeader('Content-Type')); 
	            res.setBody('{}');
	/*        } else if(endpoint.containsIgnoreCase('https://www.googleapis.com/drive/v3/files/dummyFileId/revisions')) {
	            if (endpoint.containsIgnoreCase('Forbidden') || req.getBody().containsIgnoreCase('Forbidden')) {
		  			throw new SCoreAppException(404,'statusCode');
		  		} 
		  	} else if(endpoint.containsIgnoreCase('https://www.googleapis.com/drive/v3/files/dummyFileId?fields=WebContentLink')) {
	            if (endpoint.containsIgnoreCase('Forbidden') || req.getBody().containsIgnoreCase('Forbidden')) {
		  			throw new SCoreAppException(404,'statusCode');
		  		} */ 
		  	} 
		} else if(this.dropboxFlag) {
			if(this.getFlag) {
				
			} else if(this.postFlag) {
				if (endpoint == 'https://api.dropboxapi.com/2/files/get_metadata') {
					res.setbody(GDAPITestDataFactory.getDropboxMetadataString(true, 'Dummy Folder'));
				} else if (endpoint == 'https://api.dropboxapi.com/oauth2/token') {
					res.setbody('{"token_type": "bearer", "expires_in": 9999, "access_token":"testtoken"}');
				} else if (endpoint == 'https://api.dropboxapi.com/2/team/token/get_authenticated_admin') {
                    res.setbody('{"admin_profile": {"name": {"display_name": "test UserName"}, "account_id": "123", "email": "test@email.com", "member_folder_id": "folder-id"}}');
                } else if (endpoint == 'https://api.dropboxapi.com/2/users/get_current_account') {
                    res.setbody('{"name": {"display_name": "test UserName"}, "account_id": "123", "email": "test@email.com", "member_folder_id": "folder-id"}');
                }
			}

			if (endpoint.containsIgnoreCase('https://api.dropboxapi.com/2/users/get_account')) {
		 		if (req.getBody().containsIgnoreCase('Forbidden')) {
			 		throw new SCoreAppException(400,'badRequest');
			 	} else {
					res.setBody('{"account_id": "dbId:","name": {"given_name": "Amit","surname": "Kumar","familiar_name": "Amit","display_name": "Amit Kumar (Personal)","abbreviated_name": "AK"},"email": "franz@dropbox.com","email_verified": true,"disabled": false,"is_teammate": false,"profile_photo_url": "#blank"}');
		 		}			
	        } else if (endpoint.containsIgnoreCase('https://api.dropboxapi.com/2/files/create_folder_v2')) {
		 		if (req.getBody().containsIgnoreCase('Forbidden')) {
			 		throw new SCoreAppException(400,'badRequest');
			 	} else {
	           		res.setBody('{"kind": "drive#about","metadata": {"id": "drive#user","name": "Amit Kumar","path_lower": "/dummyFolder","path_display": "/dummyFolder"}}');
		 		}			
	        } else if (endpoint.containsIgnoreCase('https://api.dropboxapi.com/2/files/list_revisions')) {
			 	if (req.getBody().containsIgnoreCase('Forbidden')) {
			 		throw new SCoreAppException(400,'badRequest');
			 	} else {
		           	res.setBody('{"is_deleted": false,'+
							    '"entries": [' + GDAPITestDataFactory.getDropboxMetadataString(false, 'PrimeNumbers.txt') + ']}');
			 	} 
	        } else if (endpoint.containsIgnoreCase('https://api.dropboxapi.com/2/sharing/list_mountable_folders')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				} else {
	           		res.setBody('{"entries":[{"is_inside_team_folder":false,"is_team_folder":false,"name":"dir","preview_url":"https://www.dropbox.com/scl/fo/fir9vjelf","shared_folder_id":"84528192421","time_invited":"2016-01-20T00:00:00Z","path_lower":"/dir","permissions":[]}]}');		
				}  
			} else if (endpoint.containsIgnoreCase('https://api.dropboxapi.com/2/sharing/mount_folder')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				} else {
	           		res.setBody('{"entries":[{"is_inside_team_folder":false,"is_team_folder":false,"name":"dir","preview_url":"https://www.dropbox.com/scl/fo/fir9vjelf","shared_folder_id":"84528192421","time_invited":"2016-01-20T00:00:00Z","path_lower":"/dir","permissions":[]}]}');		
				}  
			} else if (endpoint.containsIgnoreCase('https://api.dropboxapi.com/2/files/list_folder')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				} else {
		           	res.setBody('{"entries":[{"is_inside_team_folder":false,"is_team_folder":false,"name":"dir","preview_url":"https://www.dropbox.com/scl/fo/fir9vjelf","shared_folder_id":"84528192421","time_invited":"2016-01-20T00:00:00Z","path_lower":"/dir","permissions":[]}],"cursor": "ZtkX9_EHj3x7PMkVuFIhwKYXEpwpLwyxp9vMKomUhllil9q7eWiAu","has_more": false}');
				}		
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/sharing/add_folder_member')) {
				if (endpoint.containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(400,'badRequest');
				}	
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/files/move_v2')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/sharing/update_folder_member')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/sharing/remove_folder_member')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/sharing/transfer_folder')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/team/groups/create')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/team/groups/update')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			} else if (endpoint.equalsIgnoreCase('https://api.dropboxapi.com/2/team/groups/delete')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			} else if (endpoint.containsIgnoreCase('https://api.dropboxapi.com/2/team/groups/members')) {
				if (req.getBody().containsIgnoreCase('Forbidden')) {
					throw new SCoreAppException(409,'ERROR_HTTP_CONFLICT');
				}	
			}
		} else if(this.spFlag || this.odFlag) {
			if(getFlag) {
				if(endpoint.startsWithIgnoreCase('https://graph.microsoft.com/v1.0/sites')) {
//				   endpoint == 'https://graph.microsoft.com/v1.0/sites/siteid1?$expand=sites') {
					res.setBody('{"value":[{"id":"siteid1","name":"Team A Subsite","description":"","createdDateTime":"2016-10-18T03:05:59Z","lastModifiedDateTime":"2016-10-18T10:40:59Z","webUrl":"https://contoso.sharepoint.com/sites/site1"},' + 
						 				  '{"id":"siteid2","name":"Team B Subsite","description":"","createdDateTime":"2016-10-18T03:05:59Z","lastModifiedDateTime":"2016-10-18T10:40:59Z","webUrl":"https://contoso.sharepoint.com/sites/site2"}]}');
				} else if(endpoint.startsWithIgnoreCase('https://graph.microsoft.com/v1.0/drives/')) {
					res.setBody(GDAPITestDataFactory.getMSAPIDriveItemWithRelations(true, 'Sample Folder'));
				} else if(endpoint.equalsIgnoreCase('https://graph.microsoft.com/v1.0/organization')) {
                    res.setBody('{"value": [{"id": "16e59f39-4074-434d-ba27-6b491d7c1516"}]}');
                } else if(endpoint.equalsIgnoreCase('https://graph.microsoft.com/v1.0/me/memberOf')) {
                    res.setBody('{"value": [{"id": "16e59f39-4074-434d-ba27-6b491d7c1516", "displayName": "Sharepoint Administrator"}]}');
                } else if(endpoint.equalsIgnoreCase('https://graph.microsoft.com/v1.0/me')) {
                    res.setBody('{"displayName": "SharepointUser", "id": "15f0dfec-2635-42ee-bd92-f354490506ee", "mail": "admin@simpplr.onmicrosoft.com"}');
                }
			} else if(postFlag) {
				if(endpoint == 'https://graph.microsoft.com/v1.0/drives/sharepointdocumentlibraryid/items/sharepointtestid/children') {
					if(String.isNotBlank(req.getBody())) {
						res.setBody(GDAPITestDataFactory.getMSAPIDriveItem(true, 'New Folder'));
					}					
				} else if(endpoint.startsWithIgnoreCase('https://graph.microsoft.com/v1.0/drives/')) {
					res.setBody(GDAPITestDataFactory.getMSAPIDriveItem(true, 'New Folder'));
				} else if(endpoint.equalsIgnoreCase('https://login.microsoftonline.com/common/oauth2/token')) {
                    res.setBody('{"token_type": "bearer", "expires_in": 9999, "access_token":"testtoken"}');  
                }
			} else if(putFlag) {
				if(endpoint.startsWithIgnoreCase('https://graph.microsoft.com/v1.0/drives')) {
					res.setBody(GDAPITestDataFactory.getMSAPIDriveItem(true, 'Moved Folder'));
				}
			}
			
	        if ('drive_listing'.equalsIgnoreCase(requestType)) {
           		res.setBody('{"value":[{"id":"942CAEB0-13AE-491B-85E4-7557CDC0F25F","driveType":"documentLibrary","name":"Shared Documents","owner":{"user":{"id":"AE2A1EE9-81A7-423C-ABE4-B945F47509BB","displayName":"Ryan Gregg"}}},{"id":"C1CD3ED9-0E98-4B0B-82D3-C8FB784B9DCC","driveType":"documentLibrary","name":"Contoso Project Files","owner":{"user":{"id":"406B2281-18E8-4416-9857-38C531B904F1","displayName":"Daron Spektor"}}}]}');
	    	} else if ('drive_item_listing'.equalsIgnoreCase(requestType)) {
           		res.setBody('{"value":[{"id":"942CAEB0-13AE-491B-85E4-7557CDC0F25F","driveType":"documentLibrary","name":"Shared Documents","owner":{"user":{"id":"AE2A1EE9-81A7-423C-ABE4-B945F47509BB","displayName":"Ryan Gregg"}}},{"id":"C1CD3ED9-0E98-4B0B-82D3-C8FB784B9DCC","driveType":"documentLibrary","name":"Contoso Project Files","owner":{"user":{"id":"406B2281-18E8-4416-9857-38C531B904F1","displayName":"Daron Spektor"}}}]}');
	    	} else if('drive_detail'.equalsIgnoreCase(requestType)){
           		res.setBody('{"id":"b!t18F8ybsHUq1z3LTz8xvZqP8zaSWjkFNhsME-Fepo75dTf9vQKfeRblBZjoSQrd7","driveType":"business","owner":{"user":{"id":"efee1b77-fb3b-4f65-99d6-274c11914d12","displayName":"Ryan Gregg"}},"quota":{"deleted":256938,"remaining":1099447353539,"state":"normal","total":1099511627776}}');
	    	} else if('drive_item_detail'.equalsIgnoreCase(requestType)){
           		res.setBody('{"createdBy":{"user":{"id":"efee1b77-fb3b-4f65-99d6-274c11914d12","displayName":"Ryan Gregg"}},"createdDateTime":"2016-03-21T20:01:37Z","cTag":"\"c:{86EB4C8E-D20D-46B9-AD41-23B8868DDA8A},0\"","eTag":"\"{86EB4C8E-D20D-46B9-AD41-23B8868DDA8A},1\"","folder":{"childCount":120},"id":"01NKDM7HMOJTVYMDOSXFDK2QJDXCDI3WUK","lastModifiedBy":{"user":{"id":"efee1b77-fb3b-4f65-99d6-274c11914d12","displayName":"Ryan Gregg"}},"lastModifiedDateTime":"2016-03-21T20:01:37Z","name":"OneDrive","root":{},"size":157286400,"webUrl":"https://contoso-my.sharepoint.com/personal/rgregg_contoso_com/Documents"}');
	    	} else if('site_listing'.equalsIgnoreCase(requestType)){
           		res.setBody('{"value":[{"id":"contoso.sharepoint.com,da60e844-ba1d-49bc-b4d4-d5e36bae9019,712a596e-90a1-49e3-9b48-bfa80bee8740","name":"Team A Subsite","description":"","createdDateTime":"2016-10-18T03:05:59Z","lastModifiedDateTime":"2016-10-18T10:40:59Z","webUrl":"https://contoso.sharepoint.com/sites/site/subsiteA"},{"id":"contoso.sharepoint.com,da60e844-ba1d-49bc-b4d4-d5e36bae9019,0271110f-634f-4300-a841-3a8a2e851851","name":"Team B Subsite","description":"","createdDateTime":"2016-10-18T03:05:59Z","lastModifiedDateTime":"2016-10-18T10:40:59Z","webUrl":"https://contoso.sharepoint.com/sites/site/subsiteB"}]}');
	    	} else if('exception'.equalsIgnoreCase(requestType)){
           		res.setBody('{"error":{"code":"invalidRequest","message":"Uploaded fragment overlaps with existing data.","innerError":{"requestId":"request-id","date":"date-time"}}}');
           		res.setStatus('error');
           		res.setStatusCode(400);
	    	}
		} else {
			res.setBody('{}');
		}
		        
		return res;
	}
}