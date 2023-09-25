public with sharing class TipTapBodyWrapper {

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
        public String href;
        public String target;
        public String tableClass;
        public Integer colspan;
        public Integer rowspan;
        public Integer colwidth;
        public String verticalAlign;
        public String horizontalAlign;
        public String src;
        public String url;
        public String alt;
        public String title;
        public String align;
        public String width;
        public String name;
        public String entryId;
        public String poster;
        public Boolean showProcessingOverlay;
        public Boolean isUploading;
        public Integer progressPercentage;
        public String tagName;
        public String display;
        public String via;
        public Integer level;
        public String color;    
        public String backgroundColor;
        public String frameBorder;
        public Boolean allowFullScreen;
        public String height;
        public String scrolling;
        public String dataHtml;
        public Boolean resized;
        public Integer duration;
        public String contentVersionId;
        public String contentDocumentId;
        public String link;
        public String thumbnailurl;
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