public with sharing class QuestionAnswerService {

    public static Map<String, Object> getQnARepsonseFromAWS(String endpoint, String method, Map<String, Object> body, Boolean canManageSite){
		String endpointUrl = SimpplrContext.simpplrAPIEndpoint + '/qna' + endpoint;

		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpointUrl);
		request.setMethod(method);
		request.setHeader('jwttoken', Utility.getJWTToken());
		if(body != null){
			request.setBody(JSON.serialize(body));
		}
		HttpResponse response = http.send(request);

		logger.logDebug('QuestionAnswerService.getRepsonseFromAWS()----request url----' + request.getEndpoint());
		logger.logDebug('QuestionAnswerService.getRepsonseFromAWS()----request body----' + request.getBody());
		logger.logDebug('QuestionAnswerService.getRepsonseFromAWS()----response body----' + response.getBody());
		Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		Map<String, Object> result = new Map<String, Object>{
			'status' => (response.getStatusCode() == 200 ? 'success' : 'error'),
			'message' => (response.getStatusCode() == 404 || response.getStatusCode() == 403 ? String.valueOf(response.getStatusCode()) : null),
			'result' => (response.getStatusCode() == 200 ? resBody.get('result') : null)
		};
		return result;
	}	
}