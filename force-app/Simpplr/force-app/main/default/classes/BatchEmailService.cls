public class BatchEmailService implements Database.Batchable<EmailWrapper.EmailRequest> {
    Iterable<EmailWrapper.EmailRequest> emailToSendList = new List<EmailWrapper.EmailRequest>();

    Map<String, EmailWrapper.Snippetwrapper> snippetsMap;
    Map<String, String> snippetRefValueMap = new Map<String, String>();

    public BatchEmailService(EmailWrapper emailWrapperObj) {
        this.snippetsMap = emailWrapperObj.htmlSnippets;
        this.emailToSendList = emailWrapperObj.emailRequests;
    }

    public Iterable<EmailWrapper.EmailRequest> start(Database.BatchableContext info){ 
        return emailToSendList;
    }

    public void execute(Database.BatchableContext info, List<EmailWrapper.EmailRequest> emailWrapperList){
        sendEmail(emailWrapperList);
    }

    public void finish(Database.BatchableContext info){
    }

    public void sendEmail(List<EmailWrapper.EmailRequest> emailRequestList) {
        List<Messaging.SingleEmailMessage> singleEmailMessageList = new List<Messaging.SingleEmailMessage>();
        String orgWideEmailId = SimpplrContext.SEDFromEmail;

        for(EmailWrapper.EmailRequest emailObj : emailRequestList) {
            String htmlBody = emailObj.htmlBody;
            if(emailObj.generateHtmlBody != null && emailObj.generateHtmlBody && snippetsMap.containsKey(emailObj.htmlSnippetName)) {
                snippetRefValueMap = emailObj.snippetRefValueMap;
                htmlBody = getSnippetText(snippetsMap.get(emailObj.htmlSnippetName));
            }
            singleEmailMessageList.add(EmailUtility.getSingleEmailElement(emailObj.subject, htmlBody, emailObj.targetUserId, orgWideEmailId));
        }
        Messaging.sendEmail(singleEmailMessageList);
    }

    private String getSnippetText(EmailWrapper.Snippetwrapper snippetWrap) {
        if(snippetWrap.values != null) {
            return String.format(snippetWrap.snippet, getSnippetValues(snippetWrap.values));
        } else {
            return snippetWrap.snippet;
        }
    }
    
    private List<String> getSnippetValues(List<EmailWrapper.Snippetwrapper> listOfSnippets) {
        List<String> snippetValues = new List<String>();
        for(EmailWrapper.Snippetwrapper snippetWrap : listOfSnippets) {
            if(String.isNotBlank(snippetWrap.snippet)) {
                snippetValues.add(getSnippetText(snippetWrap));
            } else if(String.isNotBlank(snippetWrap.snippetRef)){
                snippetValues.add((snippetRefValueMap.containsKey(snippetWrap.snippetRef) ? snippetRefValueMap.get(snippetWrap.snippetRef) : ''));
            } else {
                snippetValues.add((String.isNotBlank(snippetWrap.snippetText) ? snippetWrap.snippetText : ''));
            }
        }
        return snippetValues;
    }
}