public class LightningCarouselCtrl {
	@auraEnabled 
    public static String getCarouselData(){
        CarouselDataServer obj = new CarouselDataServer();
        ResponseWrapper resultObj = new ResponseWrapper();
		resultObj = obj.carouselDataForDashboard(null, UserContext.segmentId, false);
        return json.serialize(resultObj);     
    }
    
}