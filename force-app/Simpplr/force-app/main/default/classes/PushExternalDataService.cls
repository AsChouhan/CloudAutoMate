public without sharing class PushExternalDataService {



    private String body;
    private List<String> trailRecordIds;

    public PushExternalDataService(String body, List<String> trailRecordIds) {
        this.body = body;
        this.trailRecordIds = trailRecordIds;
    }
    
    public void execute() {
        logger.logInfo('PushExternalDataV2.PushExternalDataService.execute() Start');
        String reqBodyStr = '{"data":' + body + ', "baseUrl":"' + 
                SimpplrContext.getExternalSearchBaseUrl + '",'+ 
                ' "orgId":"' + SimpplrContext.simpplrOrgId +'", "instanceUrl":"' + 
                SimpplrContext.salesforceHost + '"}';

        logger.logInfo('PushExternalDataV2.PushExternalDataService.execute() payload =>' + reqBodyStr);
        logger.logInfo('PushExternalDataV2.PushExternalDataService.PushExternalDataHelper.CDC_SERVICE_ENDPOINT =>' + PushExternalDataHelper.CDC_SERVICE_ENDPOINT);
        //TODO => Uncomment AND Test Data sent to service
        HttpRequest req = new HttpRequest();
        req.setEndpoint(PushExternalDataHelper.CDC_SERVICE_ENDPOINT);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setBody(reqBodyStr);
        req.setTimeout(60000);
        
        Http http = new Http();
        HttpResponse res;
        res = http.send(req);

        // release heap memory
        reqBodyStr = '';
        logger.logInfo('PushExternalDataV2.PushExternalDataService.getStatusCode => ' + res.getStatusCode());
        logger.logInfo('PushExternalDataV2.PushExternalDataService.res.getStatusCode() =>' + res.getStatusCode());
        if(res.getStatusCode() == 200){
            //Changes made to handle record insert failure in CDC database
            // when it fails crd returns fail record ids and this code is added to skip deleting failed records.
            //<!-- starts
            Map<String, Object> resBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> failedIds = (List<Object>) resBodyMap.get('data');

            List<String> failed15digitIds = new List<String>();
            for(Object o : failedIds){
                failed15digitIds.add((String.valueOf(o)).substring(0,15));
            }
            List<String> recordsToDelete = new List<String>();

            if(failed15digitIds!=null && failed15digitIds.size()>0){
                
                for (Object strid : trailRecordIds) {
                    String s = String.valueOf(strid).substring(0,15);

                    if(failed15digitIds.indexOf(s)!=-1){
                        recordsToDelete.add(s);
                        System.debug('adding records to recordsToDelete' + s);
                    }
                }
            }else{
                recordsToDelete.addAll(trailRecordIds);
            }
            // ends -->
            PushExternalDataHelper.deleteTrails(recordsToDelete);
            logger.logInfo('PushExternalDataV2.PushExternalDataService.deleteTrails =>' + recordsToDelete);
        }else{
            // If failure flush error to Log__c object
            logger.logDebug('PushExternalDataV2.PushExternalDataService.getBody => ' + res.getBody());
        }
    }

} //END PushExternalDataService