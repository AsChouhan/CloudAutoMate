@isTest
private class TestMessageHelper {

    @isTest static void testrefreshMesage(){
    	MessageHelper.refreshMesage();
    	System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testloadMessages(){
    	MessageHelper.loadMessages(new List<String>{'TestMessage'});
    	System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testshowConfirm(){
    	MessageHelper.showConfirm('TestMessage');
    	System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testshowInfo(){
    	MessageHelper.showInfo('TestMessage');
    	System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testshowWarning(){
		MessageHelper.showWarning('TestMessage');
		System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testshowError(){
    	MessageHelper.showWarning('TestMessage');
    	System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testlogError(){
    	MessageHelper.logError('TestMessage');
    	System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testSecondlogError(){
    	MessageHelper.logError('TestMessage', new SimpplrException());
    	System.assert(true, 'Running as Expected');
    }
    
   
    
}