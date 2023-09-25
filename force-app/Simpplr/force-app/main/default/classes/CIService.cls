public with sharing class CIService {
	public static final String JWT_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/jwt';
  
	@future (callout=true)
    public static void deleteCIItems(String type, String contentId){
		String endpointUrl = '';
        if(type=='content'){
            endpointUrl = SimpplrContext.simpplrAPIEndpoint + '/campaign-initiative/campaignitems/content/' + contentId;
        }else if(type=='video'){
            endpointUrl =  SimpplrContext.simpplrAPIEndpoint + '/campaign-initiative/video/' + contentId;
        }
        if(endpointUrl != ''){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpointUrl);
            request.setMethod('DELETE');
            request.setHeader('jwttoken', Utility.getJWTToken());		
            HttpResponse response = http.send(request);
        }	
	}    

}