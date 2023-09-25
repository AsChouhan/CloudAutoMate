public with sharing class FeedContentItemWrapper {

    public String type;	
    public List<content> content;

    public class attrs {
        public Integer indentation;	
        public String textAlign;	
        public String className;	
        public String id;
        public String label;
        public String type;
        public Integer start;
        public string href;
        public string target;
        public string emoji;
        public string name;
    }
    public class marks {
        public String type;	
        public attrs attrs;
    }

    public class content{
        public String type;	
        public attrs attrs;
        public List<content> content;
        public List<marks> marks;
        public String text;
    }



}