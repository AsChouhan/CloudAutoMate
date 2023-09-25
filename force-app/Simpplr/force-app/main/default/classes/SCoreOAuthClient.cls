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
 * SCoreOAuthClient
 *
 * Class to represent the OAuth HTTP client.
 * This class deals with sending and receiving OAuth authentication requests and responses.
 */
public with sharing class SCoreOAuthClient extends SCoreClient.AbstractClient
{
	
	public static final String REDIRECT_URL_STRING = 'https://services.simpplr.com/oauth/redirect/code_passthrough.php';
	private static final String AUTH_INTEGRATION_MICROSOFT_TEAMS_ENDPOINT = 'https://login.microsoftonline.com/common/oauth2/authorize';

	/**
	 * Constructor
	 */
	public SCoreOAuthClient()
	{
		this.setCredentialsRequired(false);
	}
	
	/**
	 * @description method to get authorization url
	 * @return url string type
	 * @param connectorType of type SCoreIConnectorType
	 * @param state of type string
	 */
	public String generateAuthorizationUrl(SCoreIConnectorType connectorType, String state)
	{
		if(state.equalsIgnoreCase('activedirectoryadmin')){
			String adClientId = IntegrationConstants.ACTIVE_DIRECTORY_CLIENT_ID;
			String adAuthEndpoint = AUTH_INTEGRATION_MICROSOFT_TEAMS_ENDPOINT;
			String adRedirectURlStr = 'https://api.simpplr.com/oauth/callback-passthrough';
			
			
			String adStateString = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + 
					'?state=' + IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY+'admin'+ 
					'&orgId=' + SimpplrContext.simpplrOrgId + 
					'&peopleId=' + UserContext.peopleId + 
					'&userId=' + UserContext.userId + 
					'&appName=' + SimpplrContext.applicationName;
	
			String stateValue = SimpplrContext.simpplrAPIEndpoint + '/oauth/ad-oauth-manager?state='+EncodingUtil.urlEncode(adStateString,'UTF-8');
			
			String finalRedirectUrl = EmailUtility.format(
												'{0}' + 
												'?client_id={1}' + 
												'&response_type=code' + 
												'&redirect_uri={2}' +
												'&prompt=admin_consent' +
												'&response_mode=query' +
												'&state={3}',
				new List<String>{
					adAuthEndpoint, //0
					EncodingUtil.urlEncode(adClientId, 'UTF-8'), //1
					EncodingUtil.urlEncode(adRedirectURlStr, 'UTF-8'), //2
					EncodingUtil.urlEncode(stateValue, 'UTF-8') //3
				}
			);

			return finalRedirectUrl;
		} else if(state.equalsIgnoreCase('microsoftteams') && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
			String msTeamsClientId = IntegrationConstants.MICROSOFT_TEAMS_CLIENT_ID;
			String msTeamsAuthEndpoint = AUTH_INTEGRATION_MICROSOFT_TEAMS_ENDPOINT;
			String msTeamsRedirectURlStr = 'https://api.simpplr.com/oauth/callback-passthrough';


			String msTeamsStateString = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + 
					'?state=' + IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS+
					'&orgId=' + SimpplrContext.simpplrOrgId + 
					'&peopleId=' + UserContext.peopleId + 
					'&userId=' + UserContext.userId + 
					'&appName=' + SimpplrContext.applicationName;

			String stateValue = SimpplrContext.simpplrAPIEndpoint + '/oauth/ms-teams-oauth-manager?state='+EncodingUtil.urlEncode(msTeamsStateString,'UTF-8');

			String finalRedirectUrl = EmailUtility.format(
												'{0}' + 
												'?client_id={1}' + 
												'&response_type=code' + 
												'&redirect_uri={2}' +
												'&response_mode=query' +
												'&state={3}',
				new List<String>{
					msTeamsAuthEndpoint, //0
					EncodingUtil.urlEncode(msTeamsClientId, 'UTF-8'), //1
					EncodingUtil.urlEncode(msTeamsRedirectURlStr, 'UTF-8'), //2
					EncodingUtil.urlEncode(stateValue, 'UTF-8') //3
				}
			);

			return finalRedirectUrl;
		}

		String url = EmailUtility.format(
    		'{0}?response_type=code&client_id={1}&redirect_uri={2}&{4}&state={3}',
    		new List<String>{
    			connectorType.getAuthorizationEndpoint(),
    			EncodingUtil.urlEncode(connectorType.getClientId(), SCoreClient.CHARSET_UTF8),
    			EncodingUtil.urlEncode(REDIRECT_URL_STRING, SCoreClient.CHARSET_UTF8),
    			EncodingUtil.urlEncode(connectorType.getRedirectUri() + '?state=' + state, SCoreClient.CHARSET_UTF8),
    			connectorType.getExtraUrlParameters()
    		}
		);
	
		return url;
	}
	
	/*********************************************************************************************************
	 * Requests
	 *********************************************************************************************************/
	 
	public ExchangeAuthCodeRequest exchangeAuthCodeRequest(SCoreIConnectorType ct, String code) 
	{
		AuthCodeRequestBody content = new AuthCodeRequestBody(ct, 'authorization_code', code, null);
		return new ExchangeAuthCodeRequest(this, ct.getTokenEndpoint(), content);
	}
	
	public ExchangeRefreshTokenRequest exchangeRefreshTokenRequest(SCoreIConnectorType ct, String refreshToken)
	{	
		AuthCodeRequestBody content = new AuthCodeRequestBody(ct, 'refresh_token', null, refreshToken);
		return new ExchangeRefreshTokenRequest(this, ct.getTokenEndpoint(), content);
	}
	
	/*********************************************************************************************************
	 * API Callout Inner Classes
	 *********************************************************************************************************/
	 
	public class ExchangeAuthCodeRequest extends SCoreClient.AbstractClientRequest
	{
		public ExchangeAuthCodeRequest(SCoreClient.AbstractClient client, String endpoint, AuthCodeRequestBody httpContent)
		{
			super(client, endpoint, REQUEST_METHOD_POST, httpContent, new SCoreJsonDeserializer(AccessTokenResponse.class));	
		}
		
		public ExchangeAuthCodeRequest(SCoreClient.AbstractClient client, String endpoint, SCoreIHttpContent httpContent) {
			super(client, endpoint, REQUEST_METHOD_POST, httpContent, new SCoreJsonDeserializer(AccessTokenResponse.class));	
		}
	}
	
	public class ExchangeRefreshTokenRequest extends SCoreClient.AbstractClientRequest
	{
		public ExchangeRefreshTokenRequest(SCoreClient.AbstractClient client, String endpoint, AuthCodeRequestBody httpContent)
		{
			super(client, endpoint, REQUEST_METHOD_POST, httpContent, new SCoreJsonDeserializer(AccessTokenResponse.class));	
		}
		
		public ExchangeRefreshTokenRequest(SCoreClient.AbstractClient client, String endpoint, SCoreIHttpContent httpContent)
		{
			super(client, endpoint, REQUEST_METHOD_POST, httpContent, new SCoreJsonDeserializer(AccessTokenResponse.class));	
		} 
	}
	
	/*********************************************************************************************************
	 * Inner Classes
	 *********************************************************************************************************/
	
	class AuthCodeRequestBody implements SCoreIHttpContent 
	{
		String grantType;
		String code;
		String clientId;
		String clientSecret;
		String redirectUri;
		String refreshToken;
		
		public AuthCodeRequestBody(SCoreIConnectorType ct, String grantType, String code, String refreshToken)
		{
			this.clientId = ct.getClientId();
			this.clientSecret = ct.getClientSecret();
			this.redirectUri = REDIRECT_URL_STRING;
			
			this.grantType = grantType;
			this.code = code;
			this.refreshToken = refreshToken;
		}
		
		/**
		 * IHttpContent implementation
		 */
		public String getHttpContentType()
		{
			return 'application/x-www-form-urlencoded';
		}
	
		public Object getHttpContent()
		{	
			String content = '';
			content = addParameterIfStringNotEmpty(content, 'grant_type', grantType, false);
			content = addParameterIfStringNotEmpty(content, 'client_id', clientId, true);
			content = addParameterIfStringNotEmpty(content, 'client_secret', clientSecret, true);
			// Google Drive is throwing 400 bad request when redirect_uri and code parameters are passed for refresh_token exchange
			if(!grantType.equalsIgnoreCase('refresh_token')) {
				content = addParameterIfStringNotEmpty(content, 'redirect_uri', redirectUri, true);
				content = addParameterIfStringNotEmpty(content, 'code', code, false);
			}
			content = addParameterIfStringNotEmpty(content, 'refresh_token', refreshToken, false);		
			return content;
		}
		
		private String addParameterIfStringNotEmpty(String content, String parameter, String value, Boolean encode)
		{
			if (String.isEmpty(value))
			{
				return content;
			}
			
			if (!String.isEmpty(content))
			{
				content += SCoreClient.HTTP_REQUEST_ENDPOINT_SEPARATOR;
			}
			
			if (encode)
			{
				value = EncodingUtil.urlEncode(value, SCoreClient.CHARSET_UTF8);
			}
			
			return content += parameter + SCoreClient.HTTP_REQUEST_PARAMETER_SEPARATOR + value;
		}
	}
	
	public class AccessTokenResponse extends SCoreAbstractJsonSerializable
	{
		public String token_type { get; set; }
		public String access_token { get; set; }
		public String refresh_token { get; set; }
		public String id_token;
		public String resource;
		public String scope;
		public Decimal expires_in { get; set; }
		public Decimal ext_expires_in;
		public String expires_on;
		public String not_before;
	}
}