public with sharing class ServiceNowWrapper {
    public List<ResultItem> result;
    public String status;

    public class ResultItem{
        public KBCategory user_name;
        public KBCategory sys_updated_on;
        public KBCategory title;
        public KBCategory sys_id;
        public KBCategory kb_category;
        public KBCategory kb_knowledge_base;
        public KBCategory number_x;
        public KBCategory state;
        public KBCategory short_description;
        public KBCategory topic;
        public KBCategory priority;
        public String incident_sys_updated_on;
        public String new_incident_priority;
        public String new_incident_state;
        public String incident_number_x;
        public String incident_sys_id;
        public String incident_short_description;
        public String label;
        public String value;

    }   
    public class Header{
        public Integer size;
    }
    public class KnowledgeBaseWrapper{
        public String id{get;set;}
        public String sysId{get;set;}
        public String name{get;set;}
        public String status{get;set;}
        public String title{get;set;}
        public String impact{get;set;}
        public String priority{get;set;}
        public String url{get;set;}
        public KBCategoryWrapper category{get;set;}
        public String modifiedAt{get;set;}
        public Boolean isDeleted{get;set;}
        public Boolean isSelected{get;set;}
        public String jsonDataString{get;set;}
    }

    public class KBCategory{
        public String link;
        public String display_value;
        public String value;
    }

    public class KBCategoryWrapper{
        public String id;
        public String name;
    }

    public class KBItemSearchWrapper {
        public String itemType;
		public Object item;
    }

    public class CreateIncidentWrapper{
        public ResultItem result;
        public String status;
    }

    public class SNWrapper{
        public Boolean snEnabled;
		public String snClientId;
    	public String snClientSecret;

		public String snConnectedAs;
		public Boolean snKeysSaved;
		public String servicenowInstanceUrl;
		public String customSNKnowledgebaseName;
		public String customSNTicketingSystemName;
		public Boolean isSNTicketingDefaultSelected;
		public Boolean isSNKnowledgeDefaultSelected;
		public Boolean snNotificationsEnabled;
        public Boolean snKnowledgebaseEnabled;
        public Boolean snTicketEnabled;
        public Boolean snTicketCreationEnabled;
        public Boolean isSNKnowledgebaseUrlDefaultSelected;
        public String customSNKnowledgebaseUrl;
        public Boolean isSNTicketsUrlDefaultSelected;
        public String customServiceNowTicketsUrl;
		public List<KnowledgeBaseWrapper> kbWrapperList;
    }
}