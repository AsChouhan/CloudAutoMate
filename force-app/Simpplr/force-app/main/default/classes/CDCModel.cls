/**
 * @description       : change data capture wrapper
 * @author            : simpplr.com
 * @last modified on  : 04-29-2022
 * @last modified by  : simpplr.com
**/
public without sharing class CDCModel {

    public class Event{
        // constructor
        public Event(){
            header = new EventHeader();
            records = new List<SObject>();
        }

        public EventHeader header;
        public List<SObject> records;
    }

    public class EventHeader{
        // constructor
        public EventHeader(){
            recordIds = new Set<String>();
            dependentChildObjects = new List<Child>();
        }

        public String recordType;
        public String operationType;
        public String requestId;
        public Set<String> recordIds;
        public List<Child> dependentChildObjects;
    }

    public class Child{
        public String recordType;
        public String parentReference;
    }

}