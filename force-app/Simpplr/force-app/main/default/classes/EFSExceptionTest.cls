/**
 * This class contains unit tests for validating the behavior of Apex class EFSException 
 */
@isTest
private class EFSExceptionTest {

	static EFSException sfEx = new EFSException('Err','Error message is here');
	
    @isTest static void getErrorTest() {
        System.assertEquals(sfEx.getError(),'Err');
    }
    
    @isTest static void getMessageTest() {
    		sfEx.getMessage();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void addTraceTest() {
    		EFSException.addTrace('src');
    		String errorTrace = EFSException.trace;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void resetTraceTest() {
    	EFSException.resetTrace();
        System.assertEquals(EFSException.trace,'');
    }
    
    @isTest static void pushSourceTest() {
    	EFSException.pushSource('src');
        System.assert(true);
    }
    
    @isTest static void popSourceTest() {
    	EFSException.popSource();
        System.assert(true);
    }
    
    @isTest static void showSourceTest() {
        System.assertEquals(EFSException.showSource(),'');
        EFSException.pushSource('src1');
        EFSException.pushSource('src2');
        System.assertEquals(EFSException.showSource(),'src1');
    }
}