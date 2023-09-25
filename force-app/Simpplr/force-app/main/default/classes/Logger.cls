public without sharing class Logger {

    private Logger() {}

    @TestVisible private static Integer order = 0;
	@TestVisible private static Integer charLimit = 0;
    @TestVisible private static String  logContext = '';
	@TestVisible private static Boolean showLineNumbers = true;

	@TestVisible private static String requestId = Request.getCurrent().getRequestId();
	@TestVisible private static String logType = Request.getCurrent().getQuiddity().name();

	@TestVisible private static List<String> logList = new List<String>();
	@TestVisible private static List<String> debugLogList = new List<String>();

	@TestVisible private static Boolean isReadOnlyProcess{
    	get{
			if(Test.isRunningTest()){
				return true;
			}
	    	if(isReadOnlyProcess == null){
				isReadOnlyProcess = false;
				if (ApexPages.currentPage() != null) {
					String reqURI = ApexPages.currentPage().getUrl();
					isReadOnlyProcess = (reqURI!=null && reqURI.containsIgnoreCase('dataserverro')) ? true : false;
				}else if(RestContext.request != null){
					String reqURI = RestContext.request?.requestURI;
					isReadOnlyProcess =(reqURI!=null && reqURI.containsIgnoreCase('dataserverro')) ? true : false;
				}else{
					isReadOnlyProcess = false;
				}
				System.debug('isReadOnlyProcess = ' + isReadOnlyProcess);
	    	}
	    	return isReadOnlyProcess;
    	}private set;
    }

    @TestVisible private static void logExecutionContext(){
        String debugLine = '';
        if(SimpplrContext.loggingLevel>=1 && isDebugOn()){
			logList.add('Execution Started');
			logList.add('Please login with subscriber access and create user trace flags(debug log screen) for the current user to see detailed logs with line numbers.');
			
            if (ApexPages.currentPage() != null) {
				logList.add('Request URL ' + ApexPages.currentPage()?.getUrl()?.left(1000));
				logList.add('Request header ' + JSON.serialize(ApexPages.currentPage()?.getHeaders()));
				logList.add('Request params ' + (JSON.serialize(ApexPages.currentPage()?.getParameters()))?.left(1000));
				logList.add('Request cookies ' + ApexPages.currentPage()?.getCookies());
			}else if(RestContext.request != null){
				RestRequest req = RestContext.request;
				logList.add('Request URL ' + req.requestURI?.left(1000));
				logList.add('Request header ' + JSON.serialize(req.headers));
				logList.add('Request params ' + (JSON.serialize(req.params))?.left(1000));
				logList.add('Request remoteAddress ' + req.remoteAddress);
			}else{
				logList.add('Is Future=' + System.isFuture());
				logList.add('Is Queueable=' + System.isQueueable());
				logList.add('Is Scheduled=' + System.isScheduled());
				logList.add('Is Batch=' + System.isBatch());
			}
			debugLogList.addAll(logList);
		}	 
    }

    public static String getLogLimitStatus(){
    	String logLimitString = '';
    	if(SimpplrContext.loggingLevel>0){
    	logLimitString ='Number of SOQL queries: '+Limits.getQueries()+' out of '+ Limits.getLimitQueries() + ' | ' +
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

    @TestVisible private static String prepareACExceptionDetail(Exception e) {

    	String exceptionDetail = '';
    	if (e instanceof SIMPSFDCAccessControlException){
			SIMPSFDCAccessControlException ace = (SIMPSFDCAccessControlException)e;
			exceptionDetail+=' <br/><br/>Access violation Details:<br/>';
			exceptionDetail+=' <br/>Type - ' + ace.getExceptionType();
			exceptionDetail+=' <br/>Reason - ' + ace.getExceptionReason();
			exceptionDetail+=' <br/>Object - ' + ace.getExceptionObject();  
			exceptionDetail+=' <br/>Field - ' + ace.getExceptionField();  
			exceptionDetail+=' <br/>Text - ' + ace.getText();  			
        }
        return exceptionDetail;
    }

    public static List<String> getLogs () {
    	if (isDebugOn()) {
    		debugLogList.add(getLogLimitStatus());
    	}
        return debugLogList;
    }

    public static void logInfo (Object message) {
		if(SimpplrContext.loggingLevel>=3 && isDebugOn()){
			try {
				if(message!=null && message instanceof Exception) {
					Exception ex = (Exception)message;
					log(LoggingLevel.INFO, ex.getMessage());
					log(LoggingLevel.INFO, 'Stack Trace of Exception | '+  ex.getStackTraceString());
				}else{
					if (message == null) {
						log(LoggingLevel.INFO, 'null');
						return;
					}
					if(showLineNumbers) {
						throw new SimpplrException(JSON.serialize(message));
					} else {
						log(LoggingLevel.INFO, message);
					}
				}
			} catch (Exception e) {
				String l = e.getStackTraceString();
				String debugLine = '';
				List<String> spliList = l.split('column 1');
				if(spliList.size()>1){
					debugLine = spliList[1].substringBetween('Class.', ',');
				}
				log(LoggingLevel.INFO, debugLine +'||'+  e.getMessage());
			}
		}	    	
    }

    public static void logDebug (Object message) {
		if(SimpplrContext.loggingLevel>=4 && isDebugOn()){
			try {
				if(message!=null && message instanceof Exception) {
					Exception ex = (Exception)message;
					log(LoggingLevel.DEBUG, ex.getMessage());
					log(LoggingLevel.DEBUG, 'Stack Trace of Exception | '+  ex.getStackTraceString());
				}else{
					if (message == null) {
						log(LoggingLevel.DEBUG, 'null');
						return;
					}
					if(showLineNumbers) {
						throw new SimpplrException(JSON.serialize(message));
					} else {
						log(LoggingLevel.DEBUG, message);
					}
				}
			} catch (Exception e) {
				String l = e.getStackTraceString();
				String debugLine = '';
				List<String> spliList = l.split('column 1');
				if(spliList.size()>1){
					debugLine = spliList[1].substringBetween('Class.', ',');
				}
				log(LoggingLevel.DEBUG, debugLine +'||'+  e.getMessage());
			}
		}	    	
    }

    public static void logError (Object message) {
		if(SimpplrContext.loggingLevel>=1 && isDebugOn()){
			try {
				if(message!=null && message instanceof Exception) {
					Exception ex = (Exception)message;
					log(LoggingLevel.ERROR, ex.getMessage());
					log(LoggingLevel.ERROR, 'Stack Trace of Exception | '+  ex.getStackTraceString());
					String exceptionDetail = prepareACExceptionDetail(ex);
					if(String.isNotEmpty(exceptionDetail)){
						log(LoggingLevel.ERROR, exceptionDetail);
					}
				}else{
					if (message == null) {
						log(LoggingLevel.ERROR, 'null');
						return;
					}
					if(showLineNumbers) {
						throw new SimpplrException(JSON.serialize(message));
					} else {
						log(LoggingLevel.ERROR, message);
					}
				}
			} catch (Exception e) {
				String l = e.getStackTraceString();
				String debugLine = '';
				List<String> spliList = l.split('column 1');
				if(spliList.size()>1){
					debugLine = spliList[1].substringBetween('Class.', ',');
				}
				log(LoggingLevel.ERROR, debugLine +'||'+  e.getMessage());
			}
		}	    	
    }

	public static void logWarn (Object message) {
		if(SimpplrContext.loggingLevel>=2 && isDebugOn()){
			try {
				if(message!=null && message instanceof Exception) {
					Exception ex = (Exception)message;
					log(LoggingLevel.WARN, ex.getMessage());
					log(LoggingLevel.WARN, 'Stack Trace of Exception | '+  ex.getStackTraceString());
				}else{
					if (message == null) {
						log(LoggingLevel.WARN, 'null');
						return;
					}
					if(showLineNumbers) {
						throw new SimpplrException(JSON.serialize(message));
					} else {
						log(LoggingLevel.WARN, message);
					}
				}
			} catch (Exception e) {
				String l = e.getStackTraceString();
				String debugLine = '';
				List<String> spliList = l.split('column 1');
				if(spliList.size()>1){
					debugLine = spliList[1].substringBetween('Class.', ',');
				}
				log(LoggingLevel.WARN, debugLine +'||'+  e.getMessage());
			}
		}	    	
    }

    public static void logError (String message, Exception ex) {
		if(SimpplrContext.loggingLevel>=1 && isDebugOn()){
			log(LoggingLevel.ERROR, (message!=null)? message : 'null');
			if(ex!=null) {
				log(LoggingLevel.ERROR, ex.getMessage());
				log(LoggingLevel.ERROR, 'Stack Trace of Exception | '+  ex.getStackTraceString());
				String exceptionDetail = prepareACExceptionDetail(ex);
				if(String.isNotEmpty(exceptionDetail)){
					log(LoggingLevel.ERROR, exceptionDetail);
				}
			}
		}
    }

    @testVisible 
    private static void log (LoggingLevel level, Object message) {

		if(level==null){
			level = LoggingLevel.DEBUG;
		}
		if(message==null){
			message = 'NULL';
		}

		if(logList.size()<1){
            logExecutionContext();
        }

		order++;

		String logString  = level.name() + '||' + (JSON.serialize(message)).left(5000);
		if(isDebugOn()) System.debug(logString);
		if(isDebugOn()) debugLogList.add(logString);

		logString = order + '||'+ System.currentTimeMillis() + '||' + UserInfo.getOrganizationId() +'||'+ UserInfo.getUserId()  +'||'+ logType +'||'+ requestId +'||'+ logString;

		charLimit = charLimit + logString.length();
		if(charLimit>130000){
			logList.add(getLogLimitStatus());
			// setting true to ensure using future call to save logs when log size exceeds character  130,000 limit 
			flushLogsToDB();
		}else{
			logList.add(logString);
		}
    }

    public static void flushLogsToDB () {
		
    	if (logList != null && logList.size() > 0 && SimpplrContext.loggingLevel>0 && isDebugOn()) {
    		try {
				System.debug('Inside try block flushLogsToDB');
				Boolean isAsync = System.isFuture() || System.isQueueable() || System.isScheduled() || System.isBatch();
				if(isAsync){
					System.debug('Inside isAsync block saveDebugLogs');
					saveDebugLogs(logContext, logType, requestId, JSON.serialize(logList));
				}else{
					System.debug('Inside else isAsync block saveDebugLogsByFuture');
					saveDebugLogsByFuture(logContext, logType, requestId, JSON.serialize(logList));
				}
				logList = new List<String>();
				System.debug('init logList');
    		} catch (Exception ex) {
				System.debug('Exception in flushLogsToDB - ' + ex.getStackTraceString());
    		}
    	}
		System.debug('Exiting flushLogsToDB');
		charLimit = 0;
    }

	@TestVisible private static boolean isDebugOn(){
		return SimpplrContext.isDebugEnabled && SimpplrContext.debugEnabledforUsers.contains(String.valueOf(UserInfo.getUserId())) && System.now() < SimpplrContext.debugTurnOffTime;
	}

	@TestVisible private static void saveDebugLogs(String logContext, String logType, String uniqueToken, String logText){   
		try {
			System.debug('Inside saveDebugLogs');
			Logs__c simpplrLogObj = new Logs__c(Log_Type__c = logType, Unique_Token__c=uniqueToken, Source_Info__c = logContext, Log_Data__c = logText);
			System.debug('inserting simpplrLogObj' + simpplrLogObj);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(simpplrLogObj, new List<Schema.SObjectField>{
																			Logs__c.Log_Data__c,
																			Logs__c.Log_Type__c,
																			Logs__c.Source_Info__c,
																			Logs__c.Unique_Token__c});	
		} catch (Exception e) {
			System.debug('saveDebugLogs Exception -  '  + e.getStackTraceString());
		}
    }

	@future
    @TestVisible private static void saveDebugLogsByFuture(String logContext, String logType, String uniqueToken, String logText){   
		try {
			System.debug('Executing saveDebugLogs in Future');
			saveDebugLogs(logContext, logType, uniqueToken,  logText);
		} catch (Exception e) {
			System.debug('Executing saveDebugLogs in Future Exception -  '  + e.getStackTraceString());
		}
    }
}