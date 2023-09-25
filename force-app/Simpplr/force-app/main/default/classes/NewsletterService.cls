public with sharing class NewsletterService {

    private static String API_BASE = SimpplrContext.newsletterIntegrationServiceEndpoint;
    private static String API_BASE_NEWSLETTER = API_BASE + SimpplrContext.simpplrOrgId + '/newsletters';
    private static String API_BASE_NEWSLETTER_TEMPLATE = API_BASE + SimpplrContext.simpplrOrgId + '/newsletter-templates';
    
    /**
     * @description creates a Newsletter using data on AWS
     * @return HttpResponse from AWS
     */
    public String createNewsletter (String data) { 
        HttpResponse responseObj = postRequest(API_BASE_NEWSLETTER, data);
        return responseObj.getBody();
    }

    /**
     * @description updates a Newsletter using newsletterId and data on AWS
     * @return HttpResponse from AWS
     */
    public String updateNewsletter (String newsletterId, String data) {
        HttpResponse responseObj = putRequest(API_BASE_NEWSLETTER + '/' + newsletterId, data);
        return responseObj.getBody();
    }

    /**
     * @description delete a Newsletter using newsletterId on AWS
     * @return HttpResponse from AWS
     */
    public String deleteNewsletter (String newsletterId) {
        HttpResponse responseObj = deleteRequest(API_BASE_NEWSLETTER + '/' + newsletterId);
        return responseObj.getBody();
    }

    /**
     * @description search Newsletters using reqdate on AWS
     * @return HttpResponse from AWS
     */
    public String searchNewsletter(String reqdata) {
        HttpResponse responseObj;
        if (String.isBlank(reqdata)) {
            responseObj = getRequest(API_BASE_NEWSLETTER +'?');
        } else {
            reqdata =  EncodingUtil.urlEncode(reqdata, 'UTF-8');
            responseObj = getRequest(API_BASE_NEWSLETTER +'?' + 'data=' +reqdata);
        }

        return responseObj.getBody();
    }

    /**
     * @description get audit logs using newsletterId on AWS
     * @return HttpResponse from AWS
     */
    public String getAuditLog(String newsletterId) {
        API_BASE_NEWSLETTER = API_BASE_NEWSLETTER + '/' + newsletterId + '/audit-logs';
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER);
        return responseObj.getBody();
    }

    /**
     * @description get Newsletter using newsletterId on AWS
     * @return HttpResponse from AWS
     */
    public String getNewsletter(String newsletterId) {
        API_BASE_NEWSLETTER = API_BASE_NEWSLETTER + '/' + newsletterId;
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER);
        return responseObj.getBody();
    }

    /**
     * @description get Template using templateId on AWS
     * @return HttpResponse from AWS
     */
    public String getTemplate(String templateId) {
        API_BASE_NEWSLETTER_TEMPLATE = API_BASE_NEWSLETTER_TEMPLATE + '/' + templateId;
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER_TEMPLATE);
        return responseObj.getBody();
    }

    /**
     * @description create Template using data on AWS
     * @return HttpResponse from AWS
     */
    public String createTemplate(String data) { 
        HttpResponse responseObj = postRequest(API_BASE_NEWSLETTER_TEMPLATE, data);
        return responseObj.getBody();
    }

    /**
     * @description update Template using templateId and data on AWS
     * @return HttpResponse from AWS
     */
    public String updateTemplate(String templateId, String data) {
        HttpResponse responseObj = putRequest(API_BASE_NEWSLETTER_TEMPLATE + '/' + templateId, data);
        return responseObj.getBody();
    }

    /**
     * @description delete Template using templateId on AWS
     * @return HttpResponse from AWS
     */
    public String deleteTemplate(String templateId) {
        HttpResponse responseObj = deleteRequest(API_BASE_NEWSLETTER_TEMPLATE + '/' + templateId);
        return responseObj.getBody();
    }

    /**
     * @description search Templates on AWS
     * @return HttpResponse from AWS
     */
    public String searchTemplate(String reqdata ) {
        HttpResponse responseObj;
        if (String.isBlank(reqdata)) {
            responseObj = getRequest(API_BASE_NEWSLETTER_TEMPLATE +'?');
        } else {
            reqdata =  EncodingUtil.urlEncode(reqdata, 'UTF-8');
            responseObj = getRequest(API_BASE_NEWSLETTER_TEMPLATE +'?' + 'data=' + reqdata);
        }

        return responseObj.getBody(); 
    }

    /**
     * @description get Snapshot on AWS
     * @return HttpResponse from AWS
     */
    public String getSnapshot(String newsletterId, String peopleId) { 
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER +'/' + 
                newsletterId+'/snapshotsByRecipient/' + peopleId);
        return responseObj.getBody();
    }

    /**
     * @description send preview for newsletter from AWS
     * @return HttpResponse from AWS
     */
    public String sendPreview(String newsletterId, String data) { 
        HttpResponse responseObj = postRequest(API_BASE_NEWSLETTER +'/'+ 
                newsletterId + '/send-preview', data);
        return responseObj.getBody();
    }

    //to be remove later
    /**
     * @description get Analytics for newsletter from AWS
     * @return HttpResponse from AWS
     */
    public String getAnalytics(String newsletterId) { 
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER +'/'+ 
                newsletterId + '/analytics-info');
        return responseObj.getBody();
    }

    /**
     * @description get Analytics Overview for newsletter from AWS
     * @return HttpResponse from AWS
     */
    public String getAnalyticsOverview(String newsletterId) { 
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER +'/'+ 
                newsletterId + '/analytics/overview');
        return responseObj.getBody();
    }
    
    /**
     * @description get Analytics clicks for newsletter from AWS
     * @return HttpResponse from AWS
     * @param newsletterId and order of type string
     */
    public String getAnalyticsClicksListing(String newsletterId, String order) { 
        String endpoint = API_BASE_NEWSLETTER +'/' + newsletterId + '/analytics/clicks';
        if(String.isNotBlank(order)){
            endpoint += '?order='+order;
        }
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description get Analytics heatmap for newsletter from AWS
     * @return HttpResponse from AWS
     */
    public String getAnalyticsHeatmap(String newsletterId) { 
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER +'/'+ 
                newsletterId + '/analytics/heatmap');
        return responseObj.getBody();
    }

    /**
     * @description getEmailIdentities: get Email Identities from AWS
     * @return response body from AWS to UI
     */
    public String getEmailIdentities() { 
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER +'/identities');
        return responseObj.getBody();
    }

    /**
     * @description getEmailIdentityDetails: get Email Identity Details from AWS
     * @return response body from AWS to UI
     * @param id
     */
    public String getEmailIdentityDetails(String id) { 
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER +'/identities/'+id);
        return responseObj.getBody();
    }

    /**
     * @description createEmailIdentity: create Email Identity on AWS
     * @return response body from AWS to UI
     * @param data
     */
    public String createEmailIdentity(String data) { 
        HttpResponse responseObj = postRequest(API_BASE_NEWSLETTER +'/identities', data);
        return responseObj.getBody();
    }

    /**
     * @description updateEmailIdentity: update Email Identity on AWS
     * @return response body from AWS to UI
     * @param id
     * @param data
     */
    public String updateEmailIdentity(String id ,String data) { 
        HttpResponse responseObj = putRequest(API_BASE_NEWSLETTER +'/identities/'+id, data);
        return responseObj.getBody();
    }

    /**
     * @description deleteEmailIdentity: delete Email Identity on AWS
     * @return response body from AWS to UI
     * @param id
     */
    public String deleteEmailIdentity(String id) { 
        HttpResponse responseObj = deleteRequest(API_BASE_NEWSLETTER +'/identities/'+id);
        return responseObj.getBody();
    }

    /**
     * @description syncEmailIdentity: Sync Email Identity on AWS
     * @return response body from AWS to UI
     * @param id
     */
    public String syncEmailIdentity(String id) { 
        HttpResponse responseObj = postRequest(API_BASE_NEWSLETTER +'/identities/'+id+'/updateVerified', '{}');
        return responseObj.getBody();
    }

    /**
     * @description getFilterOptions from AWS for unsplash
     * @return response body with filter options from AWS to UI
     */
    public String getFilterOptions() { 
        HttpResponse responseObj = getRequest(API_BASE_NEWSLETTER +'/filters');
        return responseObj.getBody();
    }

    /**
     * @description getContentAnalytics from AWS for analytics
     * @return response body with content analytics from AWS to UI
     * @param days - String days number
     */
    public String getContentAnalytics(String days) { 
        String endpoint = API_BASE + SimpplrContext.simpplrOrgId +'/analytics/content';
        if(String.isNotBlank(days)){
            endpoint += '?days='+days;
        }
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description getPhotos from AWS for unsplash
     * @return response body from AWS to UI
     * @param query - string of query
     * @param page - String page number
     * @param perPage - String perPage count
     */
    public String getPhotos(String query,String page, String perPage) {
        String endpoint =  API_BASE +'unsplash?';

        if(String.isNotBlank(query)){
            endpoint += 'query='+EncodingUtil.urlEncode(query, 'UTF-8')+'&';
        }
        if(String.isNotBlank(page)){
            endpoint += 'page='+page+'&';
        }
        if(String.isNotBlank(perPage)){
            endpoint += 'perPage='+perPage;
        }
        endpoint = endpoint.removeEnd('&');
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description trackDownload info for unsplash
     * @return response body from AWS to UI
     * @param data - string of data params
     */
    public String trackDownload(String data) {
        String endpoint =  API_BASE +'/unsplash/track-download';
        HttpResponse responseObj = postRequest(endpoint, data);
        return responseObj.getBody();
    }

    /**
     * @description to track Session info
     * @return response body from AWS to UI
     * @param data - string of data params
     */
    public String sessionHeartbeat(String data) {
        String endpoint =  API_BASE +'/session';
        HttpResponse responseObj = postRequest(endpoint, data);
        return responseObj.getBody();
    }

    /**
     * @description to get categories
     * @return response body from AWS to UI
     */
    public String getCategories() {
        String endpoint =  API_BASE + SimpplrContext.simpplrOrgId + '/categories';
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to save categories
     * @return response body from AWS to UI
     * @param data - string
     */
    public String saveCategory(String data) {
        String endpoint =  API_BASE + SimpplrContext.simpplrOrgId + '/categories';
        HttpResponse responseObj = postRequest(endpoint, data);
        return responseObj.getBody();
    }

    /**
     * @description to get detailed categories
     * @return response body from AWS to UI
     */
    public String getDetailedCategories() {
        String endpoint =  API_BASE + SimpplrContext.simpplrOrgId + '/categories/detailed';
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to get category overview
     * @return response body from AWS to UI
     * @param categoryId - string
     */
    public String getCategoryOverview(String categoryId) {
        String endpoint =  API_BASE + SimpplrContext.simpplrOrgId + '/categories/'+categoryId+'/overview';
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to get Archived newsletters
     * @return response body from AWS to UI
     * @param requestData - string
     * @param forIds - Boolean
     */
    public String getArchivedNewsletters(String requestData, Boolean forIds) {
        String endpoint =  API_BASE_NEWSLETTER + '/snapshots';
        String val = forIds ? '/ids?' : '?';
        endpoint += val;
        
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
        String term = requestMap.containsKey('term') && requestMap.get('term') != null ? (String)requestMap.get('term') : null;
        String rangeStart = requestMap.containsKey('rangeStart') && requestMap.get('rangeStart') != null ? (String)requestMap.get('rangeStart') : null;
        String rangeEnd = requestMap.containsKey('rangeEnd') && requestMap.get('rangeEnd') != null ? (String)requestMap.get('rangeEnd') : null;
        String sortBy = requestMap.containsKey('sort') && requestMap.get('sort') != null ? (String)requestMap.get('sort') : null;
        String order = requestMap.containsKey('order') && requestMap.get('order') != null ? (String)requestMap.get('order') : null;
        String nextPageToken = requestMap.containsKey('nextPageToken') && requestMap.get('nextPageToken') != null ? (String)requestMap.get('nextPageToken') : null;
        String filter = requestMap.containsKey('filter') && requestMap.get('filter') != null ? (String)requestMap.get('filter') : null;
        Integer size = requestMap.containsKey('size') && requestMap.get('size') != null ? (Integer)requestMap.get('size') : SimpplrContext.simpplrDefaultPageSize;

        if(String.isNotBlank(term)){
            term = term.replaceAll(' ', '%20');
            endpoint += 'term='+term+'&';
        }
        if(String.isNotBlank(rangeStart)){
            endpoint += 'rangeStart='+rangeStart+'&';
        }
        if(String.isNotBlank(rangeEnd)){
            endpoint += 'rangeEnd='+rangeEnd+'&';
        }
        if(String.isNotBlank(sortBy)){
            endpoint += 'sort='+sortBy+'&';
        }
        if(String.isNotBlank(order)){
            endpoint += 'order='+order+'&';
        }
        if(String.isNotBlank(nextPageToken)){
            endpoint += 'nextPageToken='+nextPageToken+'&';
        }
        if(String.isNotBlank(filter)){
            endpoint += 'filter='+filter+'&';
        }

        endpoint += 'size='+size;

        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to get category sent Newsletters
     * @return response body from AWS to UI
     * @param data - string
     */
    public String getCategoryNewsletters(String data) {
        Map<String, Object> params = ((Map<String, Object>) JSON.deserializeUntyped(data));
        String categoryId = String.valueOf(params.get('categoryId'));
        String endpoint =  API_BASE + SimpplrContext.simpplrOrgId + '/categories/'+categoryId+'/sent-newsletters?';
        for(String key:params.keySet()){
            endpoint += key != 'categoryId' ? key+'='+EncodingUtil.urlEncode(String.valueOf(params.get(key)), 'UTF-8')+'&' : '';
        }
        endpoint = endpoint.removeEnd('&');
        logger.logDebug('endpoint--> '+endpoint);
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to get category unsent Newsletters
     * @return response body from AWS to UI
     * @param data - string
     */
    public String getCategoryUnsentNewsletters(String data) {
        Map<String, Object> params = ((Map<String, Object>) JSON.deserializeUntyped(data));
        String categoryId = String.valueOf(params.get('categoryId'));
        String endpoint =  API_BASE + SimpplrContext.simpplrOrgId + '/categories/'+categoryId+'/unsent-newsletters?';
        for(String key:params.keySet()){
            endpoint += key != 'categoryId' ? key+'='+EncodingUtil.urlEncode(String.valueOf(params.get(key)), 'UTF-8')+'&' : '';
        }
        endpoint = endpoint.removeEnd('&');
        logger.logDebug('endpoint--> '+endpoint);
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to get all senders addresses
     * @return response body from AWS to UI
     * @param data - string
     */
    public String getAllSenderAddresses(String data) {
        Map<String, Object> params = ((Map<String, Object>) JSON.deserializeUntyped(data));
        String endpoint =  API_BASE_NEWSLETTER + '/addresses?';
        for(String key:params.keySet()){
            endpoint += key+'='+EncodingUtil.urlEncode(String.valueOf(params.get(key)), 'UTF-8')+'&';
        }
        endpoint = endpoint.removeEnd('&');
        logger.logDebug('endpoint--> '+endpoint);
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to get all domains
     * @return response body from AWS to UI
     * @param data - string
     */
    public String getAllDomains(String data) {
        Map<String, Object> params = ((Map<String, Object>) JSON.deserializeUntyped(data));
        String endpoint =  API_BASE_NEWSLETTER + '/domains?';
        for(String key:params.keySet()){
            endpoint += key+'='+EncodingUtil.urlEncode(String.valueOf(params.get(key)), 'UTF-8')+'&';
        }
        endpoint = endpoint.removeEnd('&');
        logger.logDebug('endpoint--> '+endpoint);
        HttpResponse responseObj = getRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to create domain
     * @return response body from AWS to UI
     * @param data - string
     */
    public String createDomain(String data) {
        String endpoint =  API_BASE_NEWSLETTER + '/domains';
        HttpResponse responseObj = postRequest(endpoint, data);
        return responseObj.getBody();
    }

    /**
     * @description to create senders address
     * @return response body from AWS to UI
     * @param data - string
     */
    public String createSenderAddress(String data) {
        String endpoint =  API_BASE_NEWSLETTER + '/addresses';
        HttpResponse responseObj = postRequest(endpoint, data);
        return responseObj.getBody();
    }

    /**
     * @description to update sender address
     * @return response body from AWS to UI
     * @param id - string
     * @param data - string
     */
    public String updateSenderAddress(String id, String data) {
        String endpoint =  API_BASE_NEWSLETTER + '/addresses/'+id;
        HttpResponse responseObj = putRequest(endpoint, data);
        return responseObj.getBody();
    }

    /**
     * @description to delete senders address
     * @return response body from AWS to UI
     * @param id - string
     */
    public String deleteSenderAddress(String id) {
        String endpoint =  API_BASE_NEWSLETTER + '/addresses/'+id;
        HttpResponse responseObj = deleteRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description to delete domain
     * @return response body from AWS to UI
     * @param id - string
     */
    public String deleteDomain(String id) {
        String endpoint =  API_BASE_NEWSLETTER + '/domains/'+id;
        HttpResponse responseObj = deleteRequest(endpoint);
        return responseObj.getBody();
    }

    /**
     * @description postRequest
     * Accept: Endpoint and JSONBody to post
     * @return HttpResponse
     */
    public HttpResponse postRequest(String endpoint, String jsonBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-simpplr-tenant-id', SimpplrContext.simpplrOrgId); 
        req.setHeader('x-simpplr-people-id', UserContext.peopleId);
        req.setHeader('x-simpplr-user-name', UserContext.peopleName);
        req.setHeader('simpplr-dri', Utility.getSimpDri());

        req.setMethod('POST');
        req.setTimeout(60000); 
        req.setBody(jsonBody);
        Http http = new Http();
        HttpResponse response = http.send(req);
        logger.logDebug('NewsletterService.postRequest()----endpoint----' + endpoint);
        logger.logDebug('NewsletterService.postRequest()----response body----' + response.getBody());

        if (response.getStatusCode() >= 400) {
            throw new SimpplrException(response.getbody()); 
        }
        return response;
    }

    /**
     * @description putRequest
     * Accept: Endpoint and JSONBody to put
     * @return HttpResponse
     */
    public HttpResponse putRequest(String endpoint, String jsonBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-simpplr-tenant-id', SimpplrContext.simpplrOrgId);
        req.setHeader('x-simpplr-people-id', UserContext.peopleId);
        req.setHeader('x-simpplr-user-name', UserContext.peopleName);
        req.setHeader('simpplr-dri', Utility.getSimpDri());

        req.setMethod('PUT');
        req.setTimeout(60000); 
        req.setBody(jsonBody);
        Http http = new Http();
        HttpResponse response = http.send(req);
        logger.logDebug('NewsletterService.putRequest()----endpoint----' + endpoint);
        logger.logDebug('NewsletterService.putRequest()----response body----' + response.getBody());

        if (response.getStatusCode() >= 400) {
            throw new SimpplrException(response.getbody()); 
        }

        return response;
    }

    /**
     * @description getRequest
     * Accept: Endpoint to get data
     * @return HttpResponse
     */
    public HttpResponse getRequest(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-simpplr-tenant-id', SimpplrContext.simpplrOrgId);
        req.setHeader('x-simpplr-people-id', UserContext.peopleId);
        req.setHeader('x-simpplr-user-name', UserContext.peopleName);
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        
        req.setMethod('GET');
        req.setTimeout(60000); 
        Http http = new Http();
        HttpResponse response = http.send(req);
        logger.logDebug('NewsletterService.getRequest()----endpoint----' + endpoint);
        logger.logDebug('NewsletterService.getRequest()----response status----' + response.getStatusCode());
        logger.logDebug('NewsletterService.getRequest()----response body----' + response.getBody());

        if (response.getStatusCode() >= 400) {
            throw new SimpplrException(response.getbody()); 
        }
        
        return response;
    }

    /**
     * @description deleteRequest
     * Accept: Endpoint to delete data
     * @return HttpResponse
     */
    public HttpResponse deleteRequest(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/plain');
        req.setHeader('x-simpplr-tenant-id', SimpplrContext.simpplrOrgId);
        req.setHeader('x-simpplr-people-id', UserContext.peopleId);
        req.setHeader('x-simpplr-user-name', UserContext.peopleName);
        req.setHeader('simpplr-dri', Utility.getSimpDri());

        req.setMethod('DELETE');
        req.setTimeout(60000); 
        Http http = new Http();
        HttpResponse response = http.send(req);
        logger.logDebug('NewsletterService.deleteRequest()----endpoint----' + endpoint);
        logger.logDebug('NewsletterService.deleteRequest()----response body----' + response.getBody());

        if (response.getStatusCode() >= 400) {
            throw new SimpplrException(response.getbody()); 
        }

        return response;
    }

    /**
     * @description validateContentIds in data param
     * Accept: String data
     * @return List<NewsletterV2Wrapper.contentValidationResponse>
     */
    public List<NewsletterV2Wrapper.contentValidationResponse> validateContentIds(String data) { 
        NewsletterV2Wrapper.requestValidation reqValidationObj = (NewsletterV2Wrapper.requestValidation)JSON.deserialize(
                data, NewsletterV2Wrapper.requestValidation.class);

        List<NewsletterV2Wrapper.contentValidationResponse> listOfValidationResponse = new List<NewsletterV2Wrapper.contentValidationResponse>(); 

        if (!reqValidationObj.contentIds.isEmpty()) {
            Map<id, Simpplr_Content__c> mapOfIdWithContentObj = new  Map<id, Simpplr_Content__c>([SELECT id, 
                    name, Site__r.name, site__r.Is_Active__c, site__r.Site_Type__c , Is_Deleted__c, 
                    Is_Archived__c, Is_Published__c
                    FROM simpplr_content__c 
                    WHERE id IN: reqValidationObj.contentIds AND Is_Deleted__c=false 
                    AND site__r.Is_Active__c = true
                    limit 50]);
            
            // validating content If recipient is site 
            if ('site'.equalsIgnoreCase(reqValidationObj.recipient.type)) {
                listOfValidationResponse = validateContentIdsForSiteAsRecipient(reqValidationObj, mapOfIdWithContentObj); 
               
            // Validating content if recipient is All Company
            } else if (reqValidationObj.recipient.type == 'org') {
                listOfValidationResponse = validateContentIdsForOrg(reqValidationObj, mapOfIdWithContentObj);
               
            } else if (reqValidationObj.recipient.type == 'audience') {
                listOfValidationResponse = validateContentIdsForAudience(reqValidationObj, mapOfIdWithContentObj);

            } else if (reqValidationObj.recipient.type == 'segment') {

            }

        }
         
        
        return listOfValidationResponse;
    }

    /**
     * @description validateContentIdsForAudience in data param
     * Accept: NewsletterV2Wrapper.requestValidation reqValidationObj, 
                Map<id, Simpplr_Content__c> mapOfIdWithContentObj
     * @return List<NewsletterV2Wrapper.contentValidationResponse>
     */
    @testVisible 
    private List<NewsletterV2Wrapper.contentValidationResponse> validateContentIdsForAudience(NewsletterV2Wrapper.requestValidation reqValidationObj, 
                Map<id, Simpplr_Content__c> mapOfIdWithContentObj) { 
        List<NewsletterV2Wrapper.contentValidationResponse> listOfValidationResponse = new List<NewsletterV2Wrapper.contentValidationResponse>(); 
        
        //Fetch All Audience member for Audience 
        List<Audience_Member__c> listOfAudienceMember = [SELECT id, Audience__c, 
                People__c 
                FROM  Audience_Member__c 
                WHERE Audience__c=:reqValidationObj.recipient.id WITH SECURITY_ENFORCED];
        Set<Id> setOfNewsletterRecipientPeople = new Set<Id>();

        // Put all the newsletter recipients in set 
        for (Audience_Member__c audienceMemberObj : listOfAudienceMember) {
            setOfNewsletterRecipientPeople.add(audienceMemberObj.People__c);
        }

        for (String contentId : reqValidationObj.contentIds) {
            NewsletterV2Wrapper.contentValidationResponse contValidationRespObj = new NewsletterV2Wrapper.contentValidationResponse();
            contValidationRespObj.contentId = contentId;

            // If query return record for contentId passedBy AWS
            if (mapOfIdWithContentObj.keyset().contains(contentId)) {
                Simpplr_Content__c simpContObj = mapOfIdWithContentObj.get(contentId);

                if (!simpContObj.Is_Published__c) {
                    contValidationRespObj.result = 'unpublished';
                    
                } else {

                    if ('Public'.equalsIgnoreCase(simpContObj.site__r.Site_Type__c)) {
                        contValidationRespObj.result = 'ok';

                    } else {
                        // Query in for loop as there will never be more than 50 contents in newsletter. 
                        //Fetch All siteRoles for Site where sitemember is a recipient as well. 
                        List<Site_Role__c> listOfSiteRoleForSite = [SELECT id, Is_Member__c, 
                                Is_Deleted__c, People__c, Site__c 
                                FROM  Site_Role__c 
                                WHERE Site__c=:simpContObj.site__c AND People__c IN: setOfNewsletterRecipientPeople WITH SECURITY_ENFORCED];
                        
                        // If all the recipeients have siteRole record for site then content is accessible to all
                        //Otherwise content is not accessible to someof recipients so validation will be failed. 
                        if (listOfSiteRoleForSite.size() == setOfNewsletterRecipientPeople.size()) {
                            contValidationRespObj.result = 'ok';

                        } else {
                            contValidationRespObj.result = 'notAccessible';
                        }

                    }

                }

            } else {
                contValidationRespObj.result = 'notFound';
            } 

            listOfValidationResponse.add(contValidationRespObj);
        }
        return listOfValidationResponse;
    }

     /**
     * @description validateContentIdsForOrg in data param
     * Accept: NewsletterV2Wrapper.requestValidation reqValidationObj, 
                Map<id, Simpplr_Content__c> mapOfIdWithContentObj
     * @return List<NewsletterV2Wrapper.contentValidationResponse>
     */
    @testVisible 
    private  List<NewsletterV2Wrapper.contentValidationResponse> validateContentIdsForOrg(NewsletterV2Wrapper.requestValidation reqValidationObj , 
            Map<id, Simpplr_Content__c> mapOfIdWithContentObj) { 
        List<NewsletterV2Wrapper.contentValidationResponse> listOfValidationResponse = new List<NewsletterV2Wrapper.contentValidationResponse>(); 
        
        for (String contentId : reqValidationObj.contentIds) {
            NewsletterV2Wrapper.contentValidationResponse contValidationRespObj = new NewsletterV2Wrapper.contentValidationResponse();
            contValidationRespObj.contentId = contentId;

            // If query return record for contentId passedBy AWS
            if (mapOfIdWithContentObj.keyset().contains(contentId)) {
                Simpplr_Content__c simpContObj = mapOfIdWithContentObj.get(contentId);

                if (!simpContObj.Is_Published__c) {
                    contValidationRespObj.result = 'unpublished';

                } else {

                    if ('Public'.equalsIgnoreCase(simpContObj.site__r.Site_Type__c)) {
                        contValidationRespObj.result = 'ok';

                    } else {
                        contValidationRespObj.result = 'notAccessible';
                    }
                }

            } else {
                contValidationRespObj.result = 'notFound';
            } 

            listOfValidationResponse.add(contValidationRespObj);
        }

        return listOfValidationResponse;
    }

    /**
     * @description validateContentIdsForSiteAsRecipient in data param
     * Accept: NewsletterV2Wrapper.requestValidation reqValidationObj, 
                Map<id, Simpplr_Content__c> mapOfIdWithContentObj
     * @return List<NewsletterV2Wrapper.contentValidationResponse>
     */
    @testVisible
    private  List<NewsletterV2Wrapper.contentValidationResponse> validateContentIdsForSiteAsRecipient(NewsletterV2Wrapper.requestValidation reqValidationObj , 
            Map<id, Simpplr_Content__c> mapOfIdWithContentObj) { 
        List<NewsletterV2Wrapper.contentValidationResponse> listOfValidationResponse = new List<NewsletterV2Wrapper.contentValidationResponse>(); 

         // SiteMember and followers will be considered in query 
         if ('siteMembersAndFollowers'.equalsIgnoreCase(reqValidationObj.recipient.siteMembersType)) {
            //Fetch All siteRoles for recipient Site 
            List<Site_Role__c> listOfSiteRolesForRecipientSite = [SELECT id, Is_Member__c, 
                    Is_Deleted__c, People__c, Site__c 
                    FROM  Site_Role__c 
                    WHERE Site__c=:reqValidationObj.recipient.id AND Is_Deleted__c=false WITH SECURITY_ENFORCED];
            Set<Id> setOfNewsletterRecipientPeople = new Set<Id>();

            // Put all the newsletter recipients in set 
            for (Site_Role__c siteRoleObj : listOfSiteRolesForRecipientSite) {
                setOfNewsletterRecipientPeople.add(siteRoleObj.People__c);
            }

            for (String contentId : reqValidationObj.contentIds) {
                NewsletterV2Wrapper.contentValidationResponse contValidationRespObj = new NewsletterV2Wrapper.contentValidationResponse();
                contValidationRespObj.contentId = contentId;

                // If query return record for contentId passedBy AWS
                if (mapOfIdWithContentObj.keyset().contains(contentId)) {
                    Simpplr_Content__c simpContObj = mapOfIdWithContentObj.get(contentId);

                    if (!simpContObj.Is_Published__c) {
                        contValidationRespObj.result = 'unpublished';
                        
                    } else {

                        if ('Public'.equalsIgnoreCase(simpContObj.site__r.Site_Type__c)) {
                            contValidationRespObj.result = 'ok';

                        } else {
                            // Query in for loop as there will never be more than 50 contents in newsletter. 
                            //Fetch All siteRoles for Site where sitemember is a recipient as well. 
                            List<Site_Role__c> listOfSiteRoleForSite = [SELECT id, Is_Member__c, 
                                Is_Deleted__c, People__c, Site__c 
                                FROM  Site_Role__c 
                                WHERE Site__c=:simpContObj.site__c AND People__c IN: setOfNewsletterRecipientPeople WITH SECURITY_ENFORCED];
                            
                            if (listOfSiteRoleForSite.size() == setOfNewsletterRecipientPeople.size()) {
                                contValidationRespObj.result = 'ok';

                            } else {
                                contValidationRespObj.result = 'notAccessible';
                            }

                        }

                    }

                } else {
                    contValidationRespObj.result = 'notFound';
                } 

                listOfValidationResponse.add(contValidationRespObj);
            }
        
        // Only site members will be considered extra check in query Is_Member__c= true 
        } else {
             //Fetch All siteRoles for recipient Site 
             List<Site_Role__c> listOfSiteRolesForRecipientSite = [SELECT id, Is_Member__c, 
                    Is_Deleted__c, People__c, Site__c 
                    FROM  Site_Role__c 
                    WHERE Site__c=:reqValidationObj.recipient.id AND Is_Deleted__c=false AND Is_Member__c=true WITH SECURITY_ENFORCED];
            Set<Id> setOfNewsletterRecipientPeople = new Set<Id>();

            // Put all the newsletter recipients in set 
            for (Site_Role__c siteRoleObj : listOfSiteRolesForRecipientSite) {
                setOfNewsletterRecipientPeople.add(siteRoleObj.People__c);
            }

            for (String contentId : reqValidationObj.contentIds) {
                NewsletterV2Wrapper.contentValidationResponse contValidationRespObj = new NewsletterV2Wrapper.contentValidationResponse();
                contValidationRespObj.contentId = contentId;

                // If query return record for contentId passedBy AWS
                if (mapOfIdWithContentObj.keyset().contains(contentId)) {
                    Simpplr_Content__c simpContObj = mapOfIdWithContentObj.get(contentId);

                    if (!simpContObj.Is_Published__c) {
                        contValidationRespObj.result = 'unpublished';
                        
                    } else {

                        if ('Public'.equalsIgnoreCase(simpContObj.site__r.Site_Type__c)) {
                            contValidationRespObj.result = 'ok';

                        } else {
                            // Query in for loop as there will never be more than 50 contents in newsletter. 
                            //Fetch All siteRoles for Site where sitemember is a recipient as well. 
                            List<Site_Role__c> listOfSiteRoleForSite = [SELECT id, Is_Member__c, 
                                Is_Deleted__c, People__c, Site__c 
                                FROM  Site_Role__c 
                                WHERE Site__c=:simpContObj.site__c AND People__c IN: setOfNewsletterRecipientPeople
                                AND Is_Member__c=true WITH SECURITY_ENFORCED];
                            
                            if (listOfSiteRoleForSite.size() == setOfNewsletterRecipientPeople.size()) {
                                contValidationRespObj.result = 'ok';

                            } else {
                                contValidationRespObj.result = 'notAccessible';
                            }

                        }

                    }

                } else {
                    contValidationRespObj.result = 'notFound';
                } 

                listOfValidationResponse.add(contValidationRespObj);
            }

        }

        return listOfValidationResponse;
    }

}