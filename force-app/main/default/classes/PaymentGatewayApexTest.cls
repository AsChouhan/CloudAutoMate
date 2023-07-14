@isTest
private class PaymentGatewayApexTest {
    @isTest
    static void testpayByCreditCard(){
        String cardNumber = '3566000020000410';
        String amount = '10000';
        String cardMonth = '05';
        String cardYear = '2023';
        String cvv = '123';

        String result = PaymentGatewayApex.payByCreditCard(cardNumber, amount, cardMonth, cardYear, cvv);
        System.assertEquals('This transaction has been approved.', result);
    }
}