public class LightningPopularContentCtrl {
	
    @auraEnabled 
    public static String getLatestContent(String contentType, String siteId){
        AllContentDataServer obj = new AllContentDataServer();
        List<ContentWrapper> lisOfContentWrap = new List<ContentWrapper>();
		lisOfContentWrap = obj.getLatestContentListWrap(contentType, siteId);
		
		if (!lisOfContentWrap.isEmpty()) {
			for  (ContentWrapper contWrapObj: lisOfContentWrap) {
				if (contWrapObj.img == null) {
					String staticImgUrl = ''; 
					
					if (contWrapObj.type == 'Page') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_page.jpg';
						
					} else if (contWrapObj.type == 'Album') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_album.png';
						
					} else if (contWrapObj.type == 'blog_post') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_blog.jpg';
						
					} else if (contWrapObj.type == 'Event') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_event.png';
					}
					
					contWrapObj.img = staticImgUrl;
				}
				 
			}
		}
		
        return json.serialize(lisOfContentWrap);     
    }
	
    @auraEnabled
    public static String getPopularContent(String contentType, String siteId){
    	
    	if(contentType == 'All') {
        	contentType = null;
        }
        
        AllContentDataServer obj = new AllContentDataServer();
        List<ContentWrapper> lisOfContentWrap = new List<ContentWrapper>();
		lisOfContentWrap = obj.getPopularContentListWrap(contentType, siteId);
		
		if (!lisOfContentWrap.isEmpty()) {
			for  (ContentWrapper contWrapObj: lisOfContentWrap) {
				if (contWrapObj.img == null) {
					String staticImgUrl = ''; 
					
					if (contWrapObj.type == 'Page') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_page.jpg';
						
					} else if (contWrapObj.type == 'Album') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_album.png';
						
					} else if (contWrapObj.type == 'blog_post') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_blog.jpg';
						
					} else if (contWrapObj.type == 'Event') {
						staticImgUrl = 'https://static.simpplr.com/lightning-asset/img/content_square_event.png';
					}
					
					contWrapObj.img = staticImgUrl;
				}
				 
			}
		}
		
        return json.serialize(lisOfContentWrap);     
    }
    
}