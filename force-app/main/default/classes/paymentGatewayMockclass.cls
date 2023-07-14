@isTest
public with sharing class paymentGatewayMockclass {
    static String apiLoginId = '5qRUG8x5edX3';
    static String transactionKey = '8VnuGbu82vS72852';

    @isTest
    static void testpayByCreditCard(){

        Test.setMock(HttpCalloutMock.class, new paymentgatewayTestClass());

        String cardNumber = '123456789';
        String amount = '10000';
        String cardMonth = '06';
        String cardYear = '2023';
        String cvv = '789';

        String res = PaymentGatewayApex.payByCreditCard(cardNumber, amount, cardMonth, cardYear, cvv);
        System.assertEquals(res, 'This transaction has been approved.');        
    }
}