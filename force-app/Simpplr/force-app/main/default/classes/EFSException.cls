/*
* Purpose: Exception for the Simpplr File Storage Errors
* 
* Constructors in EFSException
* 01. EFSException(String, String)
*
* Functions in EFSException
* 01. String getError()
* 02. String getMessage()
* 03. void addTrace(String)
* 04. void resetTrace()
* 05. void pushSource(String)
* 06. void popSource()
* 07. String showSource()
*/
public with sharing class EFSException extends Exception {
	// Static Variable
	public static String trace = '';
	
	public static List<String> traceStack = new List<String>();
	private static Integer traceIndex = -1; 
	
	// Instance Variable
    private String error;
    private String message;
	private String request;
	
    // Constructor
    public EFSException(String err, String msg) {
    	this.error = err;
    	this.message = msg;
    	
    }
    
    // Constructor
    public EFSException(Object req, String err, String msg) {
    	this.request = '\n\n' + req;
    	this.error = err;
    	this.message = msg;
    }

	// Getter Methods
	public String getError() { return this.error; }
	public override String getMessage() { return (this.message); } // + '\n\n' + trace + this.request); }
	
	public static void addTrace(String src) {
		logger.logDebug(src);
		trace += '-->' + src;
	}
	
	public static void resetTrace() {
		trace = '';
	}
	
	public static void pushSource(String src) {
		traceIndex++;
		traceStack.add(src);
	}
	
	public static void popSource() {
		if(traceIndex > 0) {
			traceStack.remove(traceIndex);
			traceIndex--;
		} else {
			traceStack = new List<String>();
			traceIndex = -1;
		}
	}
	
	public static String showSource() {
		if(traceIndex == -1) {
			return '';
		}
		
		String retStr = traceStack[0];
		
		If(traceIndex > 1) {
			for(Integer i=1; i<=traceIndex; i++) {
				retStr += ' > ' + traceStack[i];
			}
		}
		
		return retStr;
	}
}