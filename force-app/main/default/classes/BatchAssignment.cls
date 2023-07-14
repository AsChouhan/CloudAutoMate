public class BatchAssignment implements Database.Batchable<sObject>,database.stateful,System.Schedulable{
    public String downloadCsvString;
    public List<Contact> cList = new List<Contact>();
    
    public database.QueryLocator start(Database.BatchableContext bc){
        System.debug('comes in start method');
        String st = 'SELECT name,createddate,Email,Description FROM Contact';
        Database.QueryLocator db = database.getQueryLocator(st);
        return db;
    }
    
    public void execute(Database.BatchableContext bc,List<Contact> conList){
        System.debug('comes in execute method');

        downloadCsvString = 'Name,Created Date,Email,Description';
        System.debug(conList.size());
        for(Contact ct : conList){
            ct.Status__c = 'Ready For Approval';
            downloadCsvString+='\n';
            downloadCsvString+=(ct.name+',');
            downloadCsvString+=(ct.CreatedDate+',');
            downloadCsvString+=(ct.Email+',');
            downloadCsvString+=(ct.Description);
            
        }  
        //downloadCsvString+='.csv';
        update conList;

    }
    
    public void finish(Database.BatchableContext bc){
        
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        System.debug('in finish method');
        System.debug(downloadCsvString);
        Blob csvBlob = blob.valueOf(downloadCsvString);
        String csvName = 'Contact Details';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'saasheesh123@gmail.com'};
        String subject = 'Contact data';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Contact CSV');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
    
    public void execute(SchedulableContext sc){
		BatchAssignment ba = new BatchAssignment();
        Id batchId = Database.executeBatch(ba);
    }
    
}