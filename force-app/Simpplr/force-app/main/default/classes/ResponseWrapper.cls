/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ResponseWrapper {

	public String status;
	public String message;
	public String i18nMessage;
	public List<String> debugLogs;
	public Object result;
	public String redirectUrl;
	public String responseTimeStamp;
	
	public ResponseWrapper() {
		this.status = 'success';
		this.message = '';
		this.debugLogs = new List<String>();
		this.result = new BlankObject();
		this.responseTimeStamp = String.valueOf(DateTime.now().getTime());
	}
	
	public class BlankObject{
		
	}
}