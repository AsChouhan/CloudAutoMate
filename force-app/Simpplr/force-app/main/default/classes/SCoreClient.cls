/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * SCoreClient
 *
 * Creates a HTTP client capable of sending HTTPRequests.
 */
public with sharing class SCoreClient 
{
	//Client request method calls
	public static final String REQUEST_METHOD_DELETE = 'DELETE';
	public static final String REQUEST_METHOD_GET = 'GET';
	public static final String REQUEST_METHOD_POST = 'POST';
	public static final String REQUEST_METHOD_PUT = 'PUT';
	public static final String REQUEST_METHOD_PATCH = 'PATCH';
	
	//Header statics
	public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';
	public static final String HTTP_HEADER_CONTENT_DISPOSITION = 'Content-Disposition';
	public static final String HTTP_HEADER_CONTENT_LENGTH = 'Content-Length';
	public static final String HTTP_HEADER_CONTENT_TYPE = 'Content-Type';
	
	//Separator
	public static final String HTTP_REQUEST_ENDPOINT_SEPARATOR = '&';
	public static final String HTTP_REQUEST_PARAMETER_SEPARATOR = '=';
	public static final String HTTP_REQUEST_PARAMETER_PREFIX = '?';
	
	//Charset
	public static final String CHARSET_UTF8 = 'UTF-8';
	
	/**
	 * Credentials Interface
	 */
	public interface ICredentials
	{	
		String getTokenType();
		String getAccessToken();
	}

	/**
	 * Credentials
	 * 
	 * Wraps up the accessToken and the token type that is required to communicate with the API.
	 */
	public class Credentials implements ICredentials
	{
		private String m_tokenType;
		private String m_accessToken;
		
		public Credentials(String tokenType, String accessToken) 
		{	
			if (tokenType == null) throw new SCoreSystemException('TokenType cannot be null');
			if (accessToken == null) throw new SCoreSystemException('AccessToken cannot be null');
			
			m_tokenType = tokenType;
			m_accessToken = accessToken;
		}
		
		public String getTokenType()
		{
			return m_tokenType;
		}
		public Credentials setTokenType(String tokenType)
		{
		 	m_tokenType = tokenType;
		 	return this;
		}
		public String getAccessToken()
		{
		 	return m_accessToken;
		}
		public Credentials setAccessToken(String accessToken)
		{
		 	m_accessToken = accessToken;
		 	return this;
		}
	}

	/*
	 * AbstractClient Interface
	 */
	public interface IAbstractClient
    {
        Boolean getCredentialsRequired();
        IAbstractClient setCredentialsRequired(Boolean credentialsRequired);
        ICredentials getCredentials();
        IAbstractClient setCredentials(ICredentials credentials);
        Map<String, String> getAdditionalHeaders();
        IAbstractClient setAdditionalHeaders(Map<String, String> additionalHeaders);
        String getClientType();
        IAbstractClient setClientType(String clientType);
    }

	/**
	 * AbstractClient
	 *
	 * Abstract HTTP Client class.
	 *
	 * All requests made to a particular service have a reference to this so that the required 
	 * credentials are set in any callout.
	 */
	public abstract class AbstractClient implements IAbstractClient 
	{
		private Boolean m_credentialsRequired = true;	//Make the default for credentialsRequired true.
		private ICredentials m_credentials;
		private Map<String, String> m_additionalHeaders;
		private String m_clientType;
		
		public Boolean getCredentialsRequired()
		{
			return m_credentialsRequired;
		}
		public IAbstractClient setCredentialsRequired(Boolean credentialsRequired)
		{
			m_credentialsRequired = credentialsRequired;
			return this;
		}
		public ICredentials getCredentials()
		{
			return m_credentials;
		}
		public IAbstractClient setCredentials(ICredentials credentials)
		{
			m_credentials = credentials;
			return this;
		}
		public Map<String, String> getAdditionalHeaders()
		{
			return m_additionalHeaders;
		}
		public IAbstractClient setAdditionalHeaders(Map<String, String> additionalHeaders)
		{
			m_additionalHeaders = additionalHeaders;
			return this;
		}
		
		// Function to add Additional Headers
		public IAbstractClient addAdditionalHeader(String hKey, String hValue) {
			if(m_additionalHeaders == null) {
				m_additionalHeaders = new Map<String, String>();
			}
			
			m_additionalHeaders.put(hKey, hValue);
			
			return this;
		}
		public String getClientType()
		{
			return m_clientType;
		}
		public IAbstractClient setClientType(String clientType)
		{
			m_clientType = clientType;
			return this;
		}
	}

	/**
	 * AbstractClientRequest Interface
	 */
	public interface IAbstractClientRequest
	{
		HttpRequest buildHttpRequest();
		Object execute();
		HttpResponse executeUnparsed();
		Object parse(HttpResponse response);
	}
    
	/**
	 * AbstractClientRequest
	 *
	 * Abstract class that all API requests extend. 
	 * This class deals with building the URL sent via HTTP to the particular service.
	 */
	public abstract class AbstractClientRequest implements IAbstractClientRequest
	{

		protected IAbstractClient abstractClient {get;set;}
		protected String requestMethod {get;set;}
		protected String endpoint {get;set;}
		protected SCoreIHttpContent httpContent {get;set;}
		protected SCoreIDeserialize responseDeserializer {get;set;}
		
		private Map<String, String> m_params = new Map<String, String>();

		protected AbstractClientRequest() 
		{
		}

		protected AbstractClientRequest(IAbstractClient abstractClient, String endpoint, 
										String requestMethod, SCoreIHttpContent httpContent, 
										SCoreIDeserialize responseDeserializer) 
		{ 
			this.abstractClient = abstractClient;
			this.endpoint = endpoint;
			this.requestMethod = requestMethod;
			this.httpContent = httpContent;
			this.responseDeserializer = responseDeserializer;
		}

		/**
		 * Method to build the HTTP Request based on the parameters provided.
		 */
		public HttpRequest buildHttpRequest() 
		{
			if (abstractClient == null) 
			{
				throw new SCoreSystemException('AbstractClient not set');
			}
			
			if (abstractClient.getCredentialsRequired() != null 
			  && abstractClient.getCredentialsRequired() == true 
			  && abstractClient.getCredentials() == null) 
			{
				throw new SCoreSystemException('AbstractClient Credentials not set');
			}
			
	        HttpRequest req = new HttpRequest();
	        req.setEndpoint(createEndpoint());
	        if(this.requestMethod.equalsIgnoreCase('PATCH')) {
	        	if(abstractClient.getClientType().equalsIgnoreCase('gdrive')) {
	        		req.setMethod('POST');
	        	} else if(abstractClient.getClientType().equalsIgnoreCase('sharepoint') ||
	        			  abstractClient.getClientType().equalsIgnoreCase('onedrive')) {
	        		req.setMethod('PUT');
	        	}
	        	req.setHeader('X-HTTP-Method-Override','PATCH');
	        } else {
	        	req.setMethod(this.requestMethod);
	        }
	        req.setTimeout(60000);
	        
	        ICredentials clientCredentials = abstractClient.getCredentials();
	        if (clientCredentials != null) 
	        {	
	        	String tokenType = clientCredentials.getTokenType();
	        	String accessToken = clientCredentials.getAccessToken();
	        	req.setHeader(HTTP_HEADER_AUTHORIZATION, tokenType + ' ' + accessToken);
	        }

	        if (httpContent != null) 
	        {
		        Object body = httpContent.getHttpContent();
		        if (body instanceOf Blob) 
		        {
		  			Blob bodyBlob = (Blob)body;
		  			req.setBodyAsBlob(bodyBlob);
		  			req.setHeader(HTTP_HEADER_CONTENT_LENGTH, String.valueOf(bodyBlob.size()));
		  		}
		  		else 
		  		{
		  			String bodyStr = String.valueof(body);
		  			req.setBody(bodyStr);
		  			req.setHeader(HTTP_HEADER_CONTENT_LENGTH, String.valueOf(bodyStr.length()));
		  		}
		  
		        String httpContentType = httpContent.getHttpContentType();
		        req.setHeader(HTTP_HEADER_CONTENT_TYPE, httpContentType);
			}
			else
			{
				//Shouldn't need this but some of the Google API calls expect a content length in the header
				//even though they expect nothing in the body of the call e.g. Files.Trash call.
				req.setHeader(HTTP_HEADER_CONTENT_LENGTH, String.valueOf(0));
			}
			
			Map<String, String> addl_headers = abstractClient.getAdditionalHeaders();
			
			if(addl_headers != null) {
				for(String h_key: addl_headers.keySet()) {
					req.setHeader(h_key, addl_headers.get(h_key));	
					logger.logDebug('Header: ' + h_key + '[' + addl_headers.get(h_key) + ']');
				}
			}
			
			return req;
		}
		
		/**
		 * Creates the endpoint taking into account the endpoint, urlParam and parameters provided.
		 */
		private String createEndpoint() 
		{	
			String endpoint = this.endpoint;
						
			Set<String> keys = m_params.keySet();
			if (keys.size() > 0) 
			{
				endpoint += HTTP_REQUEST_PARAMETER_PREFIX;
				
				for (String key : keys) 
				{
					String param = (String)m_params.get(key);
					if (param != null) 
					{
						endpoint += key;
						endpoint += HTTP_REQUEST_PARAMETER_SEPARATOR;
						endpoint += EncodingUtil.urlEncode(param, CHARSET_UTF8);
						endpoint += HTTP_REQUEST_ENDPOINT_SEPARATOR;
					}
				}
			}
			
			if (endpoint.endsWith(HTTP_REQUEST_ENDPOINT_SEPARATOR)) 
			{
				endpoint = endpoint.substring(0, endpoint.length() - 1);
			}
			
			return endpoint;
		}

		public HttpResponse executeUnparsed() 
		{
			HttpRequest httpRequest = buildHttpRequest();
			logger.logDebug('HTTP Request :' + httpRequest + ' containing body [' + httpRequest.getbody() + ']');
            
            if(Test.isRunningTest()) {
				return new EFSHTTPMock(abstractClient.getClientType()).respond(httpRequest);
            }
            
			HttpResponse httpResponse = new Http().send(httpRequest);
			Integer statusCode = httpResponse.getStatusCode();
			String status = httpResponse.getStatus();
			logger.logDebug('HTTP Response :' + status + '[' + httpResponse.getBody() + ']');
			if (statusCode >= SCoreAppException.ERROR_HTTP_BAD_REQUEST) 
			{
				throw new SCoreAppException(statusCode, status);
	        }
	        return httpResponse;
		}
	
		public Object execute() 
		{
			HttpResponse httpResponse = executeUnparsed();
			return parse(httpResponse);
		}

		public Object parse(HttpResponse response)
		{
			return responseDeserializer==null ? null : responseDeserializer.deserialize(response.getBody());
		}
				
		@TestVisible
		protected Boolean getParam(String name, Boolean defaultValue) 
		{
			String param = getParam(name);
			if (param == null) 
			{
				return defaultValue;
			}
			return Boolean.valueOf(param);
		}
		
		@TestVisible
		protected Integer getParam(String name, Integer defaultValue)
		{
			String param = getParam(name);
			if (param == null) 
			{
				return defaultValue;
			}
			return Integer.valueOf(param);
		}
		
		@TestVisible
		protected Long getParam(String name, Long defaultValue) 
		{
			String param = getParam(name);
			if (param == null) 
			{
				return defaultValue;
			}
			return Long.valueOf(param);
		}
		
		@TestVisible
		protected String getParam(String name, String defaultValue) 
		{
			String param = getParam(name);
			if (param == null) 
			{
				return defaultValue;
			}
			return param;
		}
		
		@TestVisible
		protected String getParam(String name) 
		{
			return m_params.get(name);
		}
		
		@TestVisible
		protected AbstractClientRequest addParam(String name, Boolean param) 
		{
			m_params.put(name, String.valueOf(param));
			return this;
		}
		
		@TestVisible
		protected AbstractClientRequest addParam(String name, Integer param) 
		{
			m_params.put(name, String.valueOf(param));
			return this;
		}
		
		@TestVisible
		protected AbstractClientRequest addParam(String name, Long param) 
		{
			m_params.put(name, String.valueOf(param));
			return this;
		}
		
		@TestVisible
		protected AbstractClientRequest addParam(String name, String param) 
		{
			m_params.put(name, param);
			return this;
		}
	}
}