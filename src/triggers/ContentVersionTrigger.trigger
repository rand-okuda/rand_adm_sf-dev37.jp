trigger ContentVersionTrigger on ContentVersion (after insert, after update) {

    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('%%%ContentVersionTrigger isAfter isInsert');
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        for(ContentVersion cv : Trigger.new){
            if(cv.Origin == 'H' && cv.PublishStatus == 'R'){
                contentVersionList.add(cv);
            }
        }
        if(contentVersionList.size() > 0){
            ContentVersionLogic.QRcodeImageSearch(contentVersionList);
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%ContentVersionTrigger isAfter isUpdate');
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        for(ContentVersion cvNew : Trigger.new){
            if(cvNew.Origin == 'H' && cvNew.PublishStatus == 'P'){
                for(ContentVersion cvOld :Trigger.old){
                    if(cvNew.Id == cvOld.Id && cvNew.Title != cvOld.Title){
                        contentVersionList.add(cvNew);
                        break;
                    }else{
                        break;
                    }
                }
            }
        }
        if(contentVersionList.size() > 0){
            ContentVersionLogic.QRcodeImageSearch(contentVersionList);
        }
    }

}