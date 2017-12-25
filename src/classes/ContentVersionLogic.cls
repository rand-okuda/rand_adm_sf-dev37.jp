public class ContentVersionLogic {

    public static void QRcodeImageSearch(List<ContentVersion> contentVersionList){
        System.debug('@@@ QRcodeImageSearch()');
        System.debug('***contentVersionList ' + contentVersionList);
        List<ContentDistribution> cDiList = new List<ContentDistribution>();
        Set<Id> contentVersionIdSet = new Set<Id>();
        for(ContentVersion cv :contentVersionList){
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
            String encodedUrl = EncodingUtil.urlEncode(cDi.ContentDownloadUrl, 'UTF-8');
            String endpoint = 'https://zxing.org/w/decode?u=' + encodedUrl;
            System.debug('***endpoint ' + endpoint);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            HttpResponse response = new HttpResponse();
            String responseFiBody = '';
            try{
                response = http.send(request);
            }catch(System.Exception e){
                System.debug('***Exception ' + e.getMessage());
                responseFiBody = 'QRコードの解析に問題 ' + e.getMessage() + ' が発生しました。\n\rファイル名変更するとQRコードの解析を再実行します。';
            }
            System.debug('***getStatusCode() ' + response.getStatusCode());
            System.debug('***getStatus() ' + response.getStatus());
            List<String> resHeaderKeys =  response.getHeaderKeys();
            for (String HeaderKey : resHeaderKeys){
                System.debug('***Header ' + HeaderKey + ' : ' + response.getHeader(HeaderKey));
            }
            String resBody = response.getBody();
            resBody = resBody.replaceAll( '[\\r\\n]+', '' );
            System.debug('***resBody ' + resBody);
            String startString = 'Raw text</td><td><pre>';
            String endString = '</pre></td></tr><tr><td>Raw bytes';
            Integer startIndex = resBody.indexOf(startString);
            Integer endIndex = resBody.indexOf(endString, startIndex);
            String decodeQR;
            if(startIndex > 0 && endIndex > 0){
                decodeQR = resBody.substring(startIndex + startString.length(), endIndex);
            }
            System.debug('***decodeQR ' + decodeQR);
            FeedItem responseFi = new FeedItem();
            responseFi.ParentId = cDi.ContentVersion.OwnerId;
            responseFi.RelatedRecordId = cDi.ContentVersionId;
            if(response.getStatusCode() == 200 && resBody.contains('Decode Succeeded' )){
                Integer ipCount = [SELECT COUNT() FROM Inspection__c WHERE Id = :decodeQR];
                if(ipCount > 0){
                    Inspection__c ip = [SELECT Id FROM Inspection__c WHERE Id = :decodeQR];
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cDi.ContentDocumentId;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    cdl.LinkedEntityId = ip.Id;
                    insert cdl;
                    System.debug('***cdl ' + cdl);
                }else{
                    responseFiBody += 'QRコードを解析出来ましたがデータと一致しませんでした。\n\r別の画像を取り込みしてください。';
                    responseFi.Body = responseFiBody;
                    insert responseFi;
                }
            }else{
                if(response.getStatusCode() == 400 && resBody.contains('No Barcode Found')){
                    responseFiBody += 'QRコードを解析出来ませんでした。\n\r画像を再取り込みしてください。';
                }
                responseFi.Body = responseFiBody;
                insert responseFi;
            }
        }
    }

}