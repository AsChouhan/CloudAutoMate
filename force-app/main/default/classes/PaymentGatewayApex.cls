public with sharing class PaymentGatewayApex {
    static String apiLoginId = '5qRUG8x5edX3';
    static String transactionKey = '8VnuGbu82vS72852';
    @AuraEnabled
    public static String payByCreditCard(String cardNumber, String amount, String cardMonth, String cardYear, String cvv){
        String email = 'aasheesh.singh@brsikminds.com';//you can also feed this in LWC Form
        //String fullName = firstName + ' ' + lastName;
        String phone = '9999999999'; //you can also feed this in LWC Form
        String loginId = apiLoginId; // these get from authurize.net sandbox account tab
        String transactionKey = transactionKey;// these get from authurize.net sandbox account tab
        //create JSON body JSON Genertor
        JSONGenerator payBody = JSON.createGenerator(true);
        payBody.writeStartObject();//1
        payBody.writeFieldName('createTransactionRequest');
         
        payBody.writeStartObject();//2
        payBody.writeFieldName('merchantAuthentication');
         
        payBody.writeStartObject();//3
        payBody.writeStringField('name', loginId);
        payBody.writeStringField('transactionKey', transactionKey);
        payBody.writeEndObject();
         
        payBody.writeStringField('refId', '123456');
        payBody.writeFieldName('transactionRequest');
         
        payBody.writeStartObject();//4
        payBody.writeStringField('transactionType', 'authCaptureTransaction');
        payBody.writeStringField('amount', amount);
        payBody.writeFieldName('payment');
         
        payBody.writeStartObject();//5
        payBody.writeFieldName('creditCard');
         
        payBody.writeStartObject();//6
        payBody.writeStringField('cardNumber', cardNumber);
        payBody.writeStringField('expirationDate', cardYear + '-' + cardMonth);
        payBody.writeStringField('cardCode', cvv);
        payBody.writeEndObject();
         
        payBody.writeEndObject();
         
        payBody.writeFieldName('customer');
        payBody.writeStartObject();
        if(String.isNotBlank(email)){
            payBody.writeStringField('email', email);    
        }
        payBody.writeEndObject();
        
        payBody.writeFieldName('billTo');
        payBody.writeStartObject();
         
        if(String.isNotBlank(phone)){
            payBody.writeStringField('phoneNumber', phone);
        }
        payBody.writeEndObject();
        payBody.writeEndObject();
        payBody.writeEndObject();
        payBody.writeEndObject();
            // Instantiate a new http object
        Http h = new Http();
   
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(payBody.getAsString());
        System.debug(payBody.getAsString());
        // Send the request, and return a response
        HttpResponse res = new HttpResponse();
        res = h.send(req);
        System.debug(res.getBody());
        String responseBody = res.getBody();
        if(String.IsNotBlank(res.getBody())){
            System.debug(res.getBody());
            if(responseBody.contains('"description":"This transaction has been approved."') || responseBody.contains('"description":"Your order has been received. Thank you for your business!"')){
                return 'This transaction has been approved.';
            } else{
                string error = responseBody.substringBetween('"errorText":"','"');
                throw newMessageException('Error encountered: ' + error);   
            }
        } else{
            throw newMessageException('Error encountered. Status Code: ' + res.getStatus());  
        }
    }
   
    private static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }
    @AuraEnabled
    public static String payByEcheck(String routingNumber, String accountNumber, String nameOnAccount ){
        String email = 'aasheesh.singh@brsikminds.com';//you can also feed this in LWC Form
        String phone = '9999999999'; //you can also feed this in LWC Form
        String loginId = apiLoginId;
        String transactionKey = transactionKey;
        
        system.debug('routing number-->'+routingNumber+' acntNo-->'+accountNumber+' name-->'+nameOnAccount);
        
        JSONGenerator payBody = JSON.createGenerator(true);
        payBody.writeStartObject();//1
        payBody.writeFieldName('createTransactionRequest');
         
        payBody.writeStartObject();//2
        payBody.writeFieldName('merchantAuthentication');
         
        payBody.writeStartObject();//3
        payBody.writeStringField('name', loginId);
        payBody.writeStringField('transactionKey', transactionKey);
        payBody.writeEndObject();
         
        payBody.writeStringField('refId', '123456');
        payBody.writeFieldName('transactionRequest');
         
        payBody.writeStartObject();//4
         
        payBody.writeStringField('transactionType', 'authCaptureTransaction');
         
        payBody.writeStringField('amount', '100');
         
        payBody.writeFieldName('payment');
         
        payBody.writeStartObject();//5
        payBody.writeFieldName('bankAccount');
         
        payBody.writeStartObject();//6
        payBody.writeStringField('routingNumber', routingNumber);
        payBody.writeStringField('accountNumber', accountNumber);
        payBody.writeStringField('nameOnAccount', nameOnAccount);
        payBody.writeStringField('bankName', '');
        payBody.writeStringField('checkNumber', '');
        payBody.writeEndObject();
         
        payBody.writeEndObject();
         
        payBody.writeFieldName('customer');
        payBody.writeStartObject();
        if(String.isNotBlank(email)){
            payBody.writeStringField('email', email);
        }
         
        payBody.writeEndObject();
         
        payBody.writeFieldName('billTo');
        payBody.writeStartObject();
        payBody.writeStringField('firstName', '');
        payBody.writeStringField('lastName', '');
        payBody.writeStringField('company', '');
        payBody.writeStringField('address', '');
        payBody.writeStringField('city','');
        payBody.writeStringField('state', '');
        payBody.writeStringField('zip', '');
        payBody.writeStringField('country', '');
        payBody.writeStringField('phoneNumber', '');
         
        payBody.writeEndObject();
        payBody.writeEndObject();
        payBody.writeEndObject();
        payBody.writeEndObject();
        System.debug('payBody --> '+ payBody);
        // Instantiate a new http object
        Http h = new Http();
         
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://apitest.authorize.net/xml/v1/request.api');
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setBody(payBody.getAsString());
        system.debug('pay body-->'+payBody.getAsString());
        // Send the request, and return a response
        HttpResponse res = new HttpResponse();
        res = h.send(req);
        String responseBody = res.getBody();
        if(String.IsNotBlank(res.getBody())){
            System.debug(res.getBody());
            if(responseBody.contains('"description":"This transaction has been approved."') || responseBody.contains('"description":"Your order has been received. Thank you for your business!"')){
                return 'This transaction has been approved.';
               } else{
                string error = responseBody.substringBetween('"errorText":"','"');
                throw newMessageException('Error encountered: ' + error);   
               }
           } else{
            throw newMessageException('Error encountered. Status Code: ' + res.getStatus());  
           }
       }
   }