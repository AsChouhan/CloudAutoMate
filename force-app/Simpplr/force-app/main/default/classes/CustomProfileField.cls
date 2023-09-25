public with sharing class CustomProfileField {
    public String syncSource;
    public String fieldName;
    public String columnName;
    public String singular;
    public String plural;
    public Boolean displayPeopleFilter;
    public Boolean isEditable;
    public Boolean usedForAudience;
    public Boolean onOff;
    public Boolean isHtml;
    public String category;
    public Integer itemOrder;
    public String fieldType;
    public List<Option> listOfOptions;

    public class Option {
        public String value; 
        public String label;
    }
}