/**
* @Class SimpplrLog 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public class SimpplrLog {
	
	private static SimpplrLog logInstence = null;
	
    private String logContext;
	private List<String> logList;
	
	/**
	*
	**/
    private Boolean isDebugEnabled {
    	get{
			return SimpplrContext.isDebugEnabled;
		}
		set;
    }
    
    // private constructor to prevent direct creation of object
    private SimpplrLog() {

    	if (logList == null) {
			logList = new List<String>();
    	}
    	
    	//if (String.isBlank(uniqueToken) && isDebugEnabled) {
		//	uniqueToken = generateGUID();
    	//}
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static SimpplrLog getInstance (String clazzName) {
    	if(SimpplrLog.logInstence == null){
	    	SimpplrLog.logInstence = new SimpplrLog();
    	}
    	SimpplrLog.logInstence.logContext = clazzName;
    	SimpplrLog.logInstence.logList.add(clazzName);
    	
    	return SimpplrLog.logInstence;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void flushLogsToDB () {
    	if (logList != null && logList.size() > 0 && isDebugEnabled) {
    		logList.add(getLogLimitStatus());
    		logList.add('Simpplr log: ' + logContext + ' in ' + UserInfo.getOrganizationName() + '('+UserInfo.getOrganizationId()+')');
    		
    		try {
    			Logs__c simpplrLogObj = new Logs__c( Source_Info__c = logContext, Log_Data__c = JSON.serialize(logList));

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(simpplrLogObj, 
						new List<Schema.SObjectField>{
							Logs__c.Source_Info__c,
							Logs__c.Log_Data__c
				});
    		} catch (Exception ex) {
    		}
    	}
		logList = new List<String>();	
    }
    
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public List<String> getLogs () {
    	List<String> listToReturn = null;
    	if (logList != null && logList.size() > 0 && isDebugEnabled) {
    		logList.add(getLogLimitStatus());
    		logList.add('Simpplr log: ' + logContext + ' in ' + UserInfo.getOrganizationName() + '('+UserInfo.getOrganizationId()+')');
    	}
    	listToReturn = new List<String>(logList);
        logList = new List<String>();
        return listToReturn;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public String getLogLimitStatus(){
    	String logLimitString = '';
    	if(isDebugEnabled){
    	logLimitString = 'Number of SOQL queries: '+Limits.getQueries()+' out of '+ Limits.getLimitQueries() + ' | ' +
								'Number of query rows: '+Limits.getQueryRows()+' out of '+ Limits.getLimitQueryRows() + ' | ' +
								'Number of SOSL queries: '+Limits.getSoslQueries()+' out of '+Limits.getLimitSoslQueries() + ' | ' +
								'Number of DML statements: '+Limits.getDMLStatements()+' out of '+ Limits.getLimitDMLStatements() + ' | ' +
								'Number of DML rows: '+Limits.getDMLRows()+' out of ' + Limits.getLimitDMLRows() + ' | ' +
								'Maximum CPU time: '+Limits.getCpuTime()+' out of '+ Limits.getLimitCpuTime() + ' | ' +
								'Maximum heap size: '+Limits.getHeapSize()+' out of '+ Limits.getLimitHeapSize() + ' | ' +
								'Number of callouts: '+Limits.getCallouts()+' out of '+ Limits.getLimitCallouts() + ' | ' +
								'Number of Email Invocations: '+Limits.getEmailInvocations()+' out of '+ Limits.getLimitEmailInvocations() + ' | ' +
								'Number of future calls: '+Limits.getFutureCalls()+' out of '+ Limits.getLimitFutureCalls() + ' | ' +
								'Number of queueable jobs added to the queue: '+Limits.getQueueableJobs()+' out of '+ Limits.getLimitQueueableJobs() + ' | ' +
								'Number of Mobile Apex push calls: '+Limits.getMobilePushApexCalls()+' out of '+ Limits.getLimitMobilePushApexCalls() + ' | ' +
								'Number of aggregate queries: '+Limits.getAggregateQueries()+' out of '+ Limits.getLimitAggregateQueries() + ' | ' +
								'Number of records returned by the Database.getQueryLocator: '+Limits.getQueryLocatorRows()+' out of '+ Limits.getLimitQueryLocatorRows();
    	}
    	return logLimitString;
    }
    
    /**
	* 
	* Purpose:  to log salesforce remaining limits.
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void logLimitStatus(){
    	if(isDebugEnabled){
			log(LoggingLevel.DEBUG, getLogLimitStatus());
    	}
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void logInfo (Object message) {
    	if(isDebugEnabled){
        	log(LoggingLevel.INFO,message);
    	}
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void logDebug (Object message) {
    	if(isDebugEnabled){
	    	if(message instanceof Exception) {
	    		Exception ex = (Exception)message;
		        log(LoggingLevel.DEBUG, message +' | '+  ex.getMessage());
		        log(LoggingLevel.DEBUG,'Cause of Exception | '+  ex.getCause());
		        log(LoggingLevel.DEBUG,'Line Number | '+  ex.getLineNumber());
		        log(LoggingLevel.DEBUG, 'Stack Trace of Exception | '+  ex.getStackTraceString());
	    	}
			log(LoggingLevel.DEBUG, message);
    	}
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void logError (Object message) {
    	if(isDebugEnabled){
	    	if(message instanceof Exception){
	    		logError('Exception Message ', (Exception) message);
	    	}else{
	        	log(LoggingLevel.ERROR, message);
	    	}
    	}
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void logError(Object message, Exception e) {
    	if(isDebugEnabled){
	        log(LoggingLevel.ERROR, message +' | '+  e.getMessage());
	        log(LoggingLevel.ERROR,'Cause of Exception | '+  e.getCause());
	        log(LoggingLevel.ERROR,'Line Number | '+  e.getLineNumber());
	        log(LoggingLevel.ERROR, 'Stack Trace of Exception | '+  e.getStackTraceString());
	        logList.add(prepareExceptionDetail(e));
    	}
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    private void log (LoggingLevel level, Object message) {
    	
    	if (!isDebugEnabled) {
    	} else {
    		if(logList==null){
    			logList = new List<String>();
    		}
    		if(level==null){
    			level = LoggingLevel.INFO;
    		}
    		if(message==null){
    			message = 'BLANK';
    		}
    		if(String.isBlank(logContext)){
    			logContext = 'BLANK';
    		}
	        logList.add(String.valueOf(message));
    	}
    }
    
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    private String prepareExceptionDetail(Exception e) {
    	String exceptionDetail = '';
    	if (!Test.isRunningTest() && SimpplrContext.isDebugEnabled){
	    		
			exceptionDetail+=' <br/>Error Message - ' + e.getMessage(); 
			exceptionDetail+=' <br/>Line Number - ' + e.getLineNumber();
			exceptionDetail+=' <br/>Error cause - ' + e.getCause(); 
			exceptionDetail+=' <br/>Error stack trace - ' + e.getStackTraceString();
			exceptionDetail+=' <br/>Exception Type Name - ' + e.getTypeName();
			
			if(e instanceof SIMPSFDCAccessControlException) {
				SIMPSFDCAccessControlException ace = (SIMPSFDCAccessControlException)e;
				exceptionDetail+=' <br/><br/>Access violation Details:<br/>';
				exceptionDetail+=' <br/>Type - ' + ace.getExceptionType();
				exceptionDetail+=' <br/>Reason - ' + ace.getExceptionReason();
				exceptionDetail+=' <br/>Object - ' + ace.getExceptionObject();  
				exceptionDetail+=' <br/>Field - ' + ace.getExceptionField();  
				exceptionDetail+=' <br/>Text - ' + ace.getText();  
			}
        }
        return exceptionDetail;
    }
}