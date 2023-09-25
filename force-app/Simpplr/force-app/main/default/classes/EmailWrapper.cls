public with sharing class EmailWrapper {
    public Map<String, Snippetwrapper> htmlSnippets;
    public List<EmailRequest> emailRequests;

    public class EmailRequest {
        public String targetUserId;
        public String subject;
        public String textBody;
        public String htmlBody;

        public Boolean generateHtmlBody;
        public String htmlSnippetName;
        public Map<String, String> snippetRefValueMap;
    }

    public class Snippetwrapper {
        public string snippet;
        public List<Snippetwrapper> values;
        public string snippetRef;
        public string snippetText;
    }
}