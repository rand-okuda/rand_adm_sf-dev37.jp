public class FeedItemLogic {
    
    public static void CommentFeedSearch(List<FeedItem> feedItemList){
        System.debug('@@@ CommentFeedSearch()');
        System.debug('***feedItemList ' + feedItemList);
        for(FeedItem fi :feedItemList){
            QueueableSearcResponse queueableSearcResponse = new QueueableSearcResponse(fi);
            System.enqueueJob(queueableSearcResponse);
        }
    }
    
    public class QueueableSearcResponse implements System.Queueable {
        private FeedItem fi;
        public QueueableSearcResponse(FeedItem fi){
            System.debug('@@@ QueueableSearcResponse()');
            this.fi = fi;
        }
        public void execute(QueueableContext context) {
            String Body = fi.Body;
            System.debug('***fi.Body ' + fi.Body);
            Body = Body.replaceAll( '\\D', '' );
            Body = Body.stripHtmlTags();
            String SearchText = '%' + Body + '%';
            System.debug('***SearchText ' + SearchText);
            Integer eqCount = [SELECT COUNT() FROM Equipment__c WHERE Name LIKE :SearchText];
            if(eqCount > 0){
                Equipment__c eq = [SELECT Id, Name, Account__r.Name, Model__r.Name FROM Equipment__c WHERE Name LIKE :SearchText];
                Integer ipCount = [SELECT COUNT() FROM Inspection__c WHERE Equipment__r.Id = :eq.Id AND TodayTarget__c = true];
                if(ipCount > 0){
                    List<FeedItem> commentFiList = new List<FeedItem>();
                    for(Inspection__c ip :[SELECT Id, Equipment__r.Id, TodayTarget__c FROM Inspection__c WHERE Equipment__r.Id = :eq.Id AND TodayTarget__c = true]) {
                        FeedItem commentFi = new FeedItem();
                        commentFi.ParentId = eq.Id;
                        commentFi.Body = eq.Account__r.Name + '様 ' + eq.Model__r.Name + ' ' + eq.Name+ ' に 本日予定されている点検がみつまりました。';
                        commentFi.Title = '点検表';
                        commentFi.LinkUrl = '/' + ip.Id;
                        commentFiList.add(commentFi);
                    }
                    insert commentFiList;
                }else{
                    FeedItem responseFi = new FeedItem();
                    responseFi.ParentId = eq.Id;
                    responseFi.Body = eq.Account__r.Name + '様 ' + eq.Model__r.Name + ' ' + eq.Name + ' に本日予定されている点検は見つかりませんでした。';
                    insert responseFi;
                }
            }else{
                FeedItem responseFi = new FeedItem();
                responseFi.Body = '施設番号 ' + Body + ' は見つかりませんでした。\n\r別の番号を入力してください。';
                responseFi.ParentId = fi.ParentId;
                insert responseFi;
            }
        }
    }
    
    public static void QRcodeImageSearch(List<FeedItem> feedItemList){
        System.debug('@@@ QRcodeImageSearch()');
        System.debug('***feedItemList ' + feedItemList);
        Set<Id> relatedRecordIdSet = new Set<Id>();
        for(FeedItem fi :feedItemList){
            relatedRecordIdSet.add(fi.RelatedRecordId);
        }
        System.debug('*** relatedRecordIdSet' + relatedRecordIdSet);
        List<ContentDistribution> cDiList = new List<ContentDistribution>();
        Set<Id> contentVersionIdSet = new Set<Id>();
        for(ContentVersion cv :[SELECT Id FROM ContentVersion WHERE Id = :relatedRecordIdSet]){
            ContentDistribution cDi = new ContentDistribution();
            cDi.Name = 'Auto Create By Trigger';
            cDi.ContentVersionId = cv.Id;
            cDi.PreferencesNotifyOnVisit = false;
            cDiList.add(cDi);
            contentVersionIdSet.add(cv.Id);
        }
        List<ContentDistribution> existCDiList = [SELECT Id, ContentVersionId FROM ContentDistribution WHERE ContentVersionId = :contentVersionIdSet];
        delete existCDiList;
        insert cDiList;
        System.debug('***cDiList ' + cDiList);
        for(ContentDistribution cDi :[SELECT ContentVersionId, ContentDownloadUrl, ContentDocumentId, ContentVersion.OwnerId FROM ContentDistribution WHERE ContentVersionId = :contentVersionIdSet]){
            System.debug('***ContentDownloadUrl ' + cDi.ContentDownloadUrl);
            QueueableZXingCall queueableZXingCall = new QueueableZXingCall(cDi);
            System.enqueueJob(queueableZXingCall);
        }
    }
    
    public class QueueableZXingCall implements System.Queueable, Database.AllowsCallouts {
        private ContentDistribution cDi;
        public QueueableZXingCall(ContentDistribution cDi){
            System.debug('@@@ QueueableZXingCall()');
            this.cDi = cDi;
        }
        public void execute(QueueableContext context) {
            String encodedUrl;
            if(cDi.ContentDownloadUrl != null){
                encodedUrl = EncodingUtil.urlEncode(cDi.ContentDownloadUrl, 'UTF-8');                
            }
            String endpoint = 'https://zxing.org/w/decode?u=' + encodedUrl;
            System.debug('***endpoint ' + endpoint);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            HttpResponse response = new HttpResponse();
            try{
                response = http.send(request);
            }catch(System.Exception e){
                System.debug('***Exception ' + e.getMessage());
                FeedItem fi = new FeedItem();
                fi.ParentId = cDi.ContentVersion.OwnerId;
                fi.RelatedRecordId = cDi.ContentVersionId;
                fi.Body = 'QRコードの解析に問題 ' + e.getMessage() + ' が発生しました。\n\r再撮影してください。';
                insert fi;
            }
            System.debug('***getStatusCode() ' + response.getStatusCode());
            System.debug('***getStatus() ' + response.getStatus());
            List<String> resHeaderKeys =  response.getHeaderKeys();
            for (String HeaderKey : resHeaderKeys){
                System.debug('***Header ' + HeaderKey + ' : ' + response.getHeader(HeaderKey));
            }
            String decodeQR;
            if(response.getStatusCode() == 200 && response.getBody().contains('Decode Succeeded') ){
                String resBody = response.getBody();
                resBody = resBody.replaceAll( '[\\r\\n]+', '' );
                System.debug('***resBody ' + resBody);
                String startString = 'Raw text</td><td><pre>';
                String endString = '</pre></td></tr><tr><td>Raw bytes';
                Integer startIndex = resBody.indexOf(startString);
                Integer endIndex = resBody.indexOf(endString, startIndex);
                if(startIndex > 0 && endIndex > 0){
                    decodeQR = resBody.substring(startIndex + startString.length(), endIndex);
                }
                System.debug('***decodeQR ' + decodeQR);
            }
            FeedItem responseFi = new FeedItem();
            Integer eqCount = [SELECT COUNT() FROM Equipment__c WHERE Id = :decodeQR];
            if(eqCount >= 1){
                Equipment__c eq = [SELECT Id, Name, Account__r.Name, Model__r.Name FROM Equipment__c WHERE Id = :decodeQR];
                responseFi.ParentId = eq.Id;
                Integer ipCount = [SELECT COUNT() FROM Inspection__c WHERE Equipment__r.Id = :eq.Id AND TodayTarget__c = true];
                if(ipCount > 0){
                    Inspection__c ip = [SELECT Id, Equipment__r.Id, TodayTarget__c FROM Inspection__c WHERE Equipment__r.Id = :eq.Id AND TodayTarget__c = true];
                    responseFi.Title = '点検表';
                    responseFi.LinkUrl = '/' + ip.Id;
                    responseFi.Body = eq.Account__r.Name + '様 ' + eq.Model__r.Name + ' ' + eq.Name+ ' に 本日予定されている点検がみつまりました。';
                }else{
                    responseFi.RelatedRecordId = cDi.ContentVersionId;
                    responseFi.Body = eq.Account__r.Name + '様 ' + eq.Model__r.Name + ' ' + eq.Name + ' に本日予定されている点検は見つかりませんでした。';
                }
                insert responseFi;
            }else{
                if(cDi.ContentVersion.OwnerId != null && cDi.ContentVersionId != null){
                    responseFi.ParentId = cDi.ContentVersion.OwnerId;
                    responseFi.RelatedRecordId = cDi.ContentVersionId;
                    responseFi.Body = 'QRコードを読み取れませんでした。\n\r再撮影してください。';
                    insert responseFi;
                }
            }
        }
    }
    
}