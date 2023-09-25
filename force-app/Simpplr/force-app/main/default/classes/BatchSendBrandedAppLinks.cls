/**
 * @description BatchSendBrandedAppLinks : Sends bulk SMS/ email
 * notifications to all the users of org who do not have branded app installed.
 */
public with sharing class BatchSendBrandedAppLinks implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public final Set<String> countries;
    public final String notifType;
    public final String androidAppLink=null;
    public static String baseUrl = BaseCtrl.salesForceBaseUrl;
   	public String packageName = SimpplrContext.packageName;
    
 
    
      /**
     * @description BatchSendBrandedAppLinks - send notification batch 
     * @param countries
     * @param notifType
     */
    public BatchSendBrandedAppLinks(Set<String> countries, String notifType){
        this.countries = countries;
        this.notifType = notifType;
        if(String.isNotBlank(SimpplrContext.androidAppLink)){
            androidAppLink = SimpplrContext.androidAppLink;
        }
    }
    

    /**
     * @description based on notifType select appropriate records
     * @param bc batchanblecontext
     * @return Database.QueryLocator 
     */
    public Database.QueryLocator start(Database.BatchableContext bc){
		String soqlParam1 = '';
        Set<String> soqlParam2 = countries;
        String query = '';
        if ('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(notifType)) {
            query = 'SELECT Id, Country__c ,User__r.languageLocaleKey,User__r.timeZoneSIDKey,User__r.firstName , Segment__c, Segment__r.Branding_JSON__c , Mobile_Phone__c, Email__c, First_Name__c' +
                ' FROM People__c '+
                ' WHERE (country__c IN :soqlParam2) AND '+
                ' ( Mobile_Phone__c != NULL AND Mobile_Phone__c != :soqlParam1 ) AND ( user__r.firstname != NULL AND User__r.languageLocaleKey != NULL ) AND '+
                ' ( (Mobile_Token_Android__c = NULL OR Mobile_Token_Android__c = :soqlParam1) AND (Mobile_Token_iOS__c = NULL OR Mobile_Token_iOS__c = :soqlParam1) ) ';
            
        } else if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(notifType)) {
            query = 'SELECT Id, Country__c ,User__r.languageLocaleKey,User__r.timeZoneSIDKey, User__r.firstName , Segment__c, Segment__r.Branding_JSON__c , Mobile_Phone__c, Email__c, First_Name__c' +
                ' FROM People__c '+
                ' WHERE country__c IN :soqlParam2 AND'+
                ' (Email__c != NULL AND Email__c !=  :soqlParam1) AND user__r.firstname != NULL AND User__r.languageLocaleKey != NULL AND '+
                ' ( (Mobile_Token_Android__c = NULL OR Mobile_Token_Android__c = :soqlParam1) AND (Mobile_Token_iOS__c = NULL OR Mobile_Token_iOS__c = :soqlParam1) )  ';
        }
        if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
			 query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
		}
        return Database.getQueryLocator(query);
    }

    private List<Branded_App_Distribution__c> getAssignedCodes(Set<id> userids){
        List<Branded_App_Distribution__c> assignedCodes = new List<Branded_App_Distribution__c>();
        assignedCodes = [SELECT id, Type__c, Phone__c,Email__c, Is_Used__c, Code__c, Link__c, Country__c, People__c  FROM Branded_App_Distribution__c WHERE People__c IN :userIds];
        return assignedCodes;
    }
    
    /**
     * @description execute - sends notification 
     * @param bc
     * @param listOfsObject
     */
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
        List<Branded_App_Distribution__c> codesToUpdate = new List<Branded_App_Distribution__c> ();
        Map<String, MobileAppDistributionWrapper> distributionWrapperObjByUsrId = new Map<String, MobileAppDistributionWrapper>();
        Map<id, People__c> peopleById = new Map<id, People__c>((List<People__c>)listOfsObject);
        
        Map<Id, People__c> usersById = new Map<Id, People__c>();
        usersById.putAll((List<People__c>)listOfsObject);
        
        List<Branded_App_Distribution__c> assignedCodes = new List<Branded_App_Distribution__c> ();
        assignedCodes = getAssignedCodes(usersById.keySet());
        if(assignedCodes!=null && assignedCodes.size()>0){//process and remove from userById
            for(Branded_App_Distribution__c code : assignedCodes){
                People__c usr = usersById.get(code.People__c);
                if(usr.Country__c != code.Country__c ){
                    continue;
                }
                    
                String mobile = usr.Mobile_Phone__c;
                String email = usr.Email__c;
                
                MobileAppDistributionWrapper distributionWrapperObj = new MobileAppDistributionWrapper();
                distributionWrapperObj.iosLink = code.Link__c;
                distributionWrapperObj.iosCode = code.Code__c;
                distributionWrapperObj.androidLink = androidAppLink;
                
                if ('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(notifType)) {
                    code.Type__c = 'SMS';
                    code.Phone__c = mobile;
                    distributionWrapperObjByUsrId.put(usr.Id, distributionWrapperObj);
                    
                } else if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(notifType)) {
                        code.Type__c = 'Email';
                        code.Email__c = email;
                        distributionWrapperObj.peopleObj = usr;
                        distributionWrapperObjByUsrId.put(usr.Id, distributionWrapperObj); 
                }
                code.People__c = usr.Id;
                codesToUpdate.add(code);
                usersById.remove(usr.Id);
            }
        }
        
        if(usersById!=null && usersById.size()>0){//process the new users
            Map<String, List<People__c>> usersByCountry = new Map<String, List<People__c>>();
            usersByCountry = getUsersByCountry(usersById.values());
            for(String country : usersByCountry.keySet()){
                List<Branded_App_Distribution__c> codes = new List<Branded_App_Distribution__c> ();
                codes = getCodesFromCountry(country, usersByCountry.get(country).size());
                
                for(People__c usr : usersByCountry.get(country)){
                    Branded_App_Distribution__c code  = codes.get(0);
                    if(code!=null){
                        String mobile = usr.Mobile_Phone__c;
                        String email = usr.Email__c;
                        code.Is_Used__c  = True;
                        MobileAppDistributionWrapper distributionWrapperObj = new MobileAppDistributionWrapper();
                        distributionWrapperObj.iosLink = code.Link__c;
                        distributionWrapperObj.iosCode = code.Code__c;
                        distributionWrapperObj.androidLink = androidAppLink;
                        
                        if ('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(notifType)) {
                            code.Type__c = 'SMS';
                            code.Phone__c = mobile;
                            distributionWrapperObjByUsrId.put(usr.Id, distributionWrapperObj);
                            
                        } else if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(notifType)) {
                            code.Type__c = 'Email';
                            code.Email__c = email;
                            distributionWrapperObj.peopleObj = usr;
                            distributionWrapperObjByUsrId.put(usr.Id, distributionWrapperObj); 
                        }
                        code.People__c = usr.Id;
                        codesToUpdate.add(code);
                        
                    }
                    codes.remove(0);
                }
            }
        }
        
        sendNotification(distributionWrapperObjByUsrId, notifType, peopleById);
        updateCodes(codesToUpdate);
    }
    
    private List<Branded_App_Distribution__c> getCodesFromCountry(String country, Integer numberOfRecords){
        List<Branded_App_Distribution__c> codes = new List<Branded_App_Distribution__c>();
        codes = [SELECT id, Type__c, Phone__c,Email__c, Is_Used__c, Code__c, Link__c, Country__c, People__c 
                 FROM Branded_App_Distribution__c 
                 WHERE Country__c = :country AND
                 Is_Used__c = False
                 LIMIT :numberOfRecords];
        return codes;
    }
    
    private Map<String, List<People__c>> getUsersByCountry(List<People__c> users){
        Map<String, List<People__c>> usersByCountry =  new Map<String, List<People__c>> ();
        for(People__c usr : users){
            if(usersByCountry.containsKey(usr.Country__c)){
                usersByCountry.get(usr.Country__c).add(usr);
            }else{
                List<People__c> people = new List<People__c>();
                people.add(usr);
                usersByCountry.put(usr.Country__c, people);
            }
        }
        return usersByCountry;
    }
    
    private Map<id, Branded_App_Distribution__c> getUserCodeMapping(Set<Id>  userIds){
        Map<id, Branded_App_Distribution__c> userCodeMap = new Map<id, Branded_App_Distribution__c>();
        for(Branded_App_Distribution__c bad : [SELECT id, Type__c, Phone__c,Email__c, Is_Used__c, Code__c, Link__c, Country__c, People__c  FROM Branded_App_Distribution__c WHERE People__c IN :userIds]){
            userCodeMap.put(bad.People__c, bad);
        }
        return userCodeMap;
    }

    private void updateCodes(List<Branded_App_Distribution__c> codesToUpdate ){
        if(codesToUpdate!=null && codesToUpdate.size()>0){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Branded_App_Distribution__c>(codesToUpdate), new List<Schema.SObjectField>{
                Branded_App_Distribution__c.Is_Used__c,
                Branded_App_Distribution__c.Type__c,
                Branded_App_Distribution__c.Phone__c,
                Branded_App_Distribution__c.Email__c ,
                Branded_App_Distribution__c.People__c
            });
        }
    }

    private void sendNotification(Map<String, MobileAppDistributionWrapper> distributionWrapperObjByUsrId, String type, Map<id, People__c> peopleById ){
        if(distributionWrapperObjByUsrId!=null && distributionWrapperObjByUsrId.size()>0){
            if ('MOBILE_PROMOTION_PHONE'.equalsIgnoreCase(notifType)) {
                sendMobilePromotionLinkSms(distributionWrapperObjByUsrId, peopleById);
            }
            else if ('MOBILE_PROMOTION_EMAIL'.equalsIgnoreCase(notifType)) {
                sendMobilePromotionLinkEmail(distributionWrapperObjByUsrId, peopleById);
            }
        }
    }
    
    private void sendMobilePromotionLinkEmail(Map<String, MobileAppDistributionWrapper> distributionWrapperObjByUsrId, Map<id, People__c> users){
        List<Messaging.SingleEmailMessage> listOfEmailsToSend = new List<Messaging.SingleEmailMessage>();      
        for(String usrId :distributionWrapperObjByUsrId.keySet()){
            People__c usr = users.get(usrId);
            MobileAppDistributionWrapper obj = distributionWrapperObjByUsrId.get(usrId);
            LocaleContext.getAllLabelMap('EmailNotifications', new List<String>{Utility.getSimpplrLanguageLocaleKey(usr.User__r.languagelocalekey)});
            NotificationHelper.BrandingInfo brandingInfo = EmailUtility.getBrandingInfo4People(usr);
            String emailSubjectStr = LocaleContext.getLabel(Utility.getSimpplrLanguageLocaleKey(usr.User__r.languageLocaleKey), 
                                                            'email.mobile_promotion.subject').replace('{{appName}}', 
                                                                                                      SimpplrContext.applicationName);
            String mobilePromotionEmailBody = EmailUtility.getMobilePromotionEmailBody(brandingInfo, true, obj);
            Messaging.SingleEmailMessage singleMailObj = EmailUtility.getSingleEmailElement(emailSubjectStr, mobilePromotionEmailBody, usr.User__c, SimpplrContext.SEDFromEmail );
            listOfEmailsToSend.add(singleMailObj);
        }
        if (listOfEmailsToSend.size() > 0) {
            Messaging.sendEmail(listOfEmailsToSend);
        }
    }


    private  void sendMobilePromotionLinkSms (Map<String, MobileAppDistributionWrapper> distributionWrapperObjByUsrId, Map<id, People__c> users) {
        Map<String, Object> requestDataMap = new Map<String, Object>();
        
        String mobileSmsEndpoint = SimpplrContext.simpplrAPIEndpoint + '/campaign/mobile-app-download/send-bulk?utm_campaign=mobile_promotion&utm_source=sms';    
        Http httpObj = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(mobileSmsEndpoint); 
        req.setBody(JSON.serialize(getRequestBody(distributionWrapperObjByUsrId, users)));
        req.setMethod('POST');
        if(!Test.isRunningTest()){ 
            httpObj.send(req);
        }
    }

    private Map<String, Object> getRequestBody(Map<String, MobileAppDistributionWrapper> distributionWrapperObjByUsrId, Map<id, People__c> users){

        Map<String, Object> body = new Map<String, Object>();
        String driStr = Utility.requestAdoptionDataAuthToken();
        body.put('dri', driStr);
        body.put('app_type', 'branded');
        List<Map<String, Object>> data = new List<Map<String, Object>> ();
        for(String usrId :distributionWrapperObjByUsrId.keySet()){
            People__c usr = users.get(usrId);
            String mobile = usr.Mobile_Phone__c;
            Map<String, Object> reqBodyItem = new Map<String, Object> ();
            MobileAppDistributionWrapper obj = distributionWrapperObjByUsrId.get(usrId);
            reqBodyItem.put('to', mobile);
            reqBodyItem.put('languageLocaleKey', Utility.getSimpplrLanguageLocaleKey(usr.User__r.languageLocaleKey));
            reqBodyItem.put('appName', SimpplrContext.applicationName);
            reqBodyItem.put('people_id', usrId);
            reqBodyItem.put('org_id', SimpplrContext.simpplrOrgId);
            reqBodyItem.put('ios_link', obj.iosLink);
            reqBodyItem.put('ios_code', obj.iosCode);
            reqBodyItem.put('android_link', obj.androidLink);  
            data.add(reqBodyItem);
        }
        body.put('data', data);
        return body;
    }
    
   /**
     * @description finish - does nothing
     * @param bc
     */
    public void finish(Database.BatchableContext bc){
        
    }
    
}