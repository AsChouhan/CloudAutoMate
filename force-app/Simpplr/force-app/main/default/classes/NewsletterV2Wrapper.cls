public with sharing class NewsletterV2Wrapper {
    public String newsletterId;
   
    public class requestValidation {
        public List<String> contentIds;
        public recipientWrapper recipient; 
    }

    public class recipientWrapper {
        public String type; 
        public String id; 
        public String siteMembersType;
    }

    public class contentValidationResponse {
        public String contentId;
        public String result; //: "ok", // "notFound" or "unpublished" or "notAccessible"
    }
}