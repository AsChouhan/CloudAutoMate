/**
 * @description LaunchpadWrapper
 */
public with sharing class LaunchpadWrapper {
    public String appsIntegrationProvider;
    public String customJson;
    public List<LinkWrapper> externalLinks;
    public String segmentId;

    /**
     * @description LinkWrapper
     */
    public class LinkWrapper implements Comparable{
        public String url;
        public String name;
        public Boolean onOff;
        public String itemOrder;
        public String id;
        
        public Integer compareTo(Object compareTo) {
            LinkWrapper obj = (LinkWrapper) compareTo;
            Integer odr = Integer.valueOf(itemOrder);
            if(odr==null || obj.itemOrder==null || odr == Integer.valueOf(obj.itemOrder)){
                return 0;
            } else if (odr < Integer.valueOf(obj.itemOrder)) {
                return -1;
            }
            return 1;
        }
    }
}