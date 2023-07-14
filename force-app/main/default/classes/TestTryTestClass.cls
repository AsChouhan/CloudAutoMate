@istest
public class TestTryTestClass{
    @isTest
    private static void MulTest(){
        Integer i = TestTry.Multiplication(8,9);
        System.assertEquals(72,i);
    }
}