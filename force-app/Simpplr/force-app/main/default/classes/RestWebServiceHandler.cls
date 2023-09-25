/**
 * @description       : generic REST webservice handler class
 * @author            : simpplr.com
 * @last modified on  : 11-22-2021
 * @last modified by  : simpplr.com
**/
public with sharing class RestWebServiceHandler extends DataServer{

    protected RestRequest req;
    protected RestResponse res;
    private String apiClass;

    private String target;
    private String action;
    private String siteId;

	
    /**
    * @description constructor
    * @param req request obj
    * @param res response obj
    * @param apiClass api class name
    **/
    public RestWebServiceHandler(RestRequest req, RestResponse res, String apiClass) {
        this.req = req;
        this.res = res;
        this.apiClass = apiClass;
    }

    /**
    * @description this exposes the protected variable to other classes within namespace
    * @return Map<String, String> read request parameters
    **/
    public Map<String, String> getRequestParameters(){
        return mapOfRequestParameters;
    }

    /**
    * @description get page features
    * @return String 
    **/
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    /**
    * @description handle request
    **/
    public override void handleRequest(){
        try {
        	logger.logDebug('RestWebServiceHandler----entered handleRequest----');

            setContext();
            logger.logDebug('isRESTServiceContext =>' + SimpplrContext.isRESTServiceContext);

            setHeaders();
            logger.logDebug('mapOfRequestHeaders =>' + mapOfRequestHeaders);

            setParams();
            logger.logDebug('mapOfRequestParameters =>' + mapOfRequestParameters);

            target = readParam(REQUEST_TARGET);
            action = readParam(REQUEST_PARAM_ACTION);
            siteId = readParam('siteId');

            setRequestContext();
            validateRequest();
            executeRequest();
            setResponse();
        } catch (Exception e) {
            logger.logError('Either no API access or wrong parameter.', e);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
            setResponse();
        }
        flushLogs();
    }

    /**
    * @description set execution context
    **/
    public void setContext(){
        // This indicates rest web service code execution
        // This flag can be used to bypass/add code executions specific rest call
        // Defalt value is false in SimpplrContext 
        SimpplrContext.isRESTServiceContext = true;
    }

    /**
    * @description set headers from request obj
    **/
    public void setHeaders(){
        if(mapOfRequestHeaders == null){
            mapOfRequestHeaders = new Map<String, String>();
        }
        if(req != null && req.headers != null && !req.headers.isEmpty()){
            mapOfRequestHeaders = new Map<String, String>(req.headers); 
        }
    }

    /**
    * @description read parameters from request object
    **/
    public void setParams(){
        if(mapOfRequestParameters == null){
            mapOfRequestParameters = new Map<String, String>();
        }
        // parse request params and request body
        if(req != null){
            readUrlParams();
            readRequestBody();
        }
    }

    /**
    * @description read URL parameters
    **/
    public void readUrlParams(){
        // parse request parameters
        if(req.params != null && !req.params.isEmpty()){
            mapOfRequestParameters = new Map<String, String>(req.params); 
        }
    }

    /**
    * @description read post request body
    **/
    public void readRequestBody(){
        // parse request body
        if(req.requestBody != null && req.requestBody.size() > 0){
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            logger.logDebug('requestBody => ' + requestBody);
            if(requestBody != null && !requestBody.isEmpty()){
                for(String key: requestBody.keySet()){
                    collectRequestBodyParams(key, requestBody.get(key));
                }
            }//END requestBody
        }
    }

    /**
    * @description collect request body params
    * @param key request key
    * @param value request value
    **/
    public void collectRequestBodyParams(String key, Object value){
        if(value != null){
            try {
                mapOfRequestParameters.put(key, (String)value);
            } catch (Exception exp) {
                mapOfRequestParameters.put(key, JSON.serialize(value));
            }
        }else{
            mapOfRequestParameters.put(key, null);
        }
    }

    /**
    * @description set request context
    **/
    public void setRequestContext(){
        //This is required for SiteContext
        logger.logDebug('siteId =>' + siteId);
        if(String.isNotBlank(siteId)){
            SiteContext.siteId = siteId;
        }

        //This is required for PageContext
        PageContext.currentPageName = apiClass;
        //This is required to access user agent in utility classes
        SimpplrContext.headers = mapOfRequestHeaders;

        setRequestURI();
        SimpplrContext.requestURI = requestURI;

        logger.logDebug('requestURI => ' + SimpplrContext.requestURI);
    }

    /**
    * @description This implements the same functionality as ApexPages.currentPage().getUrl() 
    **/
    public void setRequestURI(){
        String paramStr = '';
        if(req.params != null && !req.params.isEmpty()){
            for(String key: req.params.keySet()){
                if (String.isNotBlank(paramStr)){
                    paramStr += '&';
                }                
                paramStr += key + '=' + req.params.get(key);
            }
        }

        String url = '/services/apexrest';
        if(String.isNotBlank(paramStr)){
            requestURI = url + req.requestURI + '?' + EncodingUtil.urlEncode(paramStr, 'UTF-8');
        }else{
            requestURI = url + req.requestURI;
        }
    }

    /**
    * @description validate request details
    **/
    public void validateRequest(){
        if(!AccessManager.hasPageAccess(getPageFeature())) {
            throw new SimpplrException(ServiceConstants.ERROR_404);
        }

        logger.logDebug('target =>' + target);
        if (String.isBlank(target)) {
            throw new SimpplrException(ServiceConstants.MISSING_TARGET_PARAM);
        }
        // action parameter is not mandatory for some actions
        logger.logDebug('action =>' + action);
    }

    /**
    * @description execute request i.e perform action
    * @author simpplr.com | 11-22-2021 
    **/
    public void executeRequest(){
        String namespace = String.isBlank(SimpplrContext.packageName)? '': SimpplrContext.packageName;
        logger.logDebug('namespace =>' + namespace);
        
        Type t = Type.forName(namespace, target);
        DataServer ds = (DataServer)t.newInstance();
        ds.mapOfRequestParameters = mapOfRequestParameters;
        ds.mapOfRequestHeaders = mapOfRequestHeaders;
        ds.requestURI = requestURI;

        if(String.isNotBlank(target)) {
            ds.labelMap = LocaleContext.getLabelMap(target, UserContext.languageLocaleKey);
        }

        if(ds.featureFlagList !=null) {
            FeatureFlagManager.initializeFeatureFlagValueMap(ds.featureFlagList);
        }
        ds.handleRequest();
        ds.flushLogs();
        this.response = ds.response;
    }

    /**
    * @description set response for the request
    **/
    public void setResponse(){
        res.StatusCode = 200;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(resultString);
    }

}