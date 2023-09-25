public with sharing class FeedGroupingService {
     
    public static FeedElementPageWrapper groupFeedPage(FeedElementPageWrapper feedElementPageWrapObjArg) {
        FeedElementPageWrapper resultFeedPageWrapObj = new FeedElementPageWrapper();
        resultFeedPageWrapObj.total = feedElementPageWrapObjArg.total;
        resultFeedPageWrapObj.nextPageToken = feedElementPageWrapObjArg.nextPageToken;
        resultFeedPageWrapObj.timeStamp = feedElementPageWrapObjArg.timeStamp;
        resultFeedPageWrapObj.updatesToken = feedElementPageWrapObjArg.updatesToken;
        resultFeedPageWrapObj.type = feedElementPageWrapObjArg.type;
        resultFeedPageWrapObj.sortBy = feedElementPageWrapObjArg.sortBy;
        resultFeedPageWrapObj.listOfItems = new List<FeedElementWrapper>();
        Map<String, FeedElementWrapper> mapOfGroupIdWithFeedElement = new Map<String, FeedElementWrapper>();
        String contentPrefix = Utility.getSimpplrContentPrefix();
        Map<String, FeedElementWrapper> mapOfTimeLineGrpIdWithFeedElement = new Map<String, FeedElementWrapper>();

        // Final processing for feed grouping 
        for  (FeedElementWrapper feedElementItrObj: feedElementPageWrapObjArg.listOfItems) {
            // do not include content's question post in home feed/site feed
            if(feedElementItrObj.postType == 'question') {
                continue;
            }

            // If feed is included in grouping
            if (feedElementItrObj.postedOn != null && feedElementItrObj.postedOn.id != null && 
                    feedElementItrObj.postedOn.id.startsWith(contentPrefix) &&
                    feedElementItrObj.postType != 'poll') { 

                // For timeline post
                if ((feedElementItrObj.postType == 'link' && feedElementItrObj.postedOn != null && 
                        (feedElementItrObj.postedOn.type == 'page' || 
                        feedElementItrObj.postedOn.type == 'album' || 
                        feedElementItrObj.postedOn.type == 'blogpost' || 
                        feedElementItrObj.postedOn.type == 'event')) 
                        || feedElementItrObj.postType == 'timeline') {
 
                    if (feedElementItrObj.postedOn.isPublished) { 

                        if (feedElementItrObj.postType == 'link') {
                                feedElementItrObj.postType = 'timeline';
                                feedElementItrObj.site = feedElementItrObj.postedOn.site;
                                feedElementItrObj.body = null; 
                        } 

                        if (!mapOfTimeLineGrpIdWithFeedElement.keySet().isEmpty()) {
                            FeedElementWrapper feedElemFinalObj = new FeedElementWrapper();
                            feedElemFinalObj.listOfPost = new List<FeedElementWrapper>();
                            //Get previously added timelines 
                            FeedElementWrapper feedElemObjTemp = new FeedElementWrapper(); 
                            feedElemObjTemp = mapOfTimeLineGrpIdWithFeedElement.get('groupedtimelinesId');
                            logger.logDebug('********'+feedElemObjTemp.listOfPost.size()+':' +feedElemObjTemp.listOfPost.isEmpty());
                            //Exactly 2 timelines in feed page case.
                            if (feedElemObjTemp.listOfPost.isEmpty()) {
                                feedElemFinalObj.listOfPost.add(feedElemObjTemp);
                                feedElemFinalObj.PostType = 'groupedtimelines'; 
                                feedElemFinalObj.id = feedElementItrObj.id;
                                feedElemFinalObj.groupingId = feedElementItrObj.postedOn.id + feedElementItrObj.id;
                                feedElemFinalObj.listOfPost.add(feedElementItrObj); // Adding feed in listOfPost
                            
                            // More than 2 timeline in the feed page case 
                            } else {
                                feedElemFinalObj = feedElemObjTemp;
                                feedElemFinalObj.listOfPost.add(feedElementItrObj);
                            }

                            mapOfTimeLineGrpIdWithFeedElement.put('groupedtimelinesId', feedElemFinalObj);

                        } else {
                            feedElementItrObj.listOfPost = new List<FeedElementWrapper>();
                            mapOfTimeLineGrpIdWithFeedElement.put('groupedtimelinesId', feedElementItrObj);
                            // Extra value in map to retain the position of post in feed page. 
                            mapOfGroupIdWithFeedElement.put('groupedtimelinesId', feedElementItrObj);
                        }

                    }                   

                // without Timeline post
                } else {

                    //If there is already a content type post is present for feed then adding to same group 
                    if (mapOfGroupIdWithFeedElement.keySet().contains(feedElementItrObj.postedOn.id)) { 
                        FeedElementWrapper feedElemFinalObj = new FeedElementWrapper();
                        feedElemFinalObj = mapOfGroupIdWithFeedElement.get(feedElementItrObj.postedOn.id);
                        feedElemFinalObj.listOfPost.add(feedElementItrObj); // Adding feed in listOfPost
                        mapOfGroupIdWithFeedElement.put(feedElementItrObj.postedOn.id, feedElemFinalObj);
                    
                    } else if(feedElementItrObj.postedOn.isPublished) { 
                        FeedElementWrapper feedElemFinalObj = new FeedElementWrapper();
                        feedElemFinalObj.listOfPost = new List<FeedElementWrapper>();
                        feedElemFinalObj.PostType = 'content'; // Parent feedType will be content 
                        feedElemFinalObj.postedOn = feedElementItrObj.postedOn;
                        feedElemFinalObj.id = feedElementItrObj.postedOn.id;
                        feedElemFinalObj.groupingId = feedElementItrObj.postedOn.id + feedElementItrObj.id;
                        feedElementItrObj.postedOn = null;
                        feedElemFinalObj.listOfPost.add(feedElementItrObj); // Adding feed in listOfPost
                        mapOfGroupIdWithFeedElement.put(feedElemFinalObj.id, feedElemFinalObj);
                    } 

                }

            } else {
                // If feed is not included in grouping 
                mapOfGroupIdWithFeedElement.put(feedElementItrObj.id, feedElementItrObj);

            } 

        }

        if (!mapOfTimeLineGrpIdWithFeedElement.keySet().isEmpty()) {
            mapOfGroupIdWithFeedElement.put('groupedtimelinesId',  
                    mapOfTimeLineGrpIdWithFeedElement.get('groupedtimelinesId')); 
        }

        logger.logDebug('in the feed grouping service' + 
                mapOfGroupIdWithFeedElement.values().size());

        resultFeedPageWrapObj.listOfItems.addAll(mapOfGroupIdWithFeedElement.values());
        return resultFeedPageWrapObj;
    } 

}