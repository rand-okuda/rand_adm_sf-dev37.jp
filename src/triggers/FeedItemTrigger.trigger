trigger FeedItemTrigger on FeedItem (after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('%%%FeedItemTrigger isAfter isInsert');
        List<FeedItem> contentPostfeedItemList = new List<FeedItem>();
        List<FeedItem> textPostfeedItemList = new List<FeedItem>();
        for(FeedItem fi : Trigger.new){
            if(fi.Type == 'ContentPost' && fi.Body == null && fi.Title != null){
                contentPostfeedItemList.add(fi);
            }else if(fi.Type == 'TextPost' && fi.Title == null){
                String body = fi.Body;
                if(body.containsNone('Auto feed')){
                    textPostfeedItemList.add(fi);
                }
            }
        }
        if(contentPostfeedItemList.size() > 0){
            FeedItemLogic.QRcodeImageSearch(contentPostfeedItemList);
        }
        if(textPostfeedItemList.size() > 0){
            FeedItemLogic.CommentFeedSearch(textPostfeedItemList);
        }
    }

}