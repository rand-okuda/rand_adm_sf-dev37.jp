public class EquipmentLogic {

    public static void QRcodeImageToGet(List<Equipment__c> equipmentList){
        System.debug('***@@@QRcodeImageToGet()');
        System.debug('***equipmentList ' + equipmentList);
        for(Equipment__c eq :equipmentList){
            System.debug('***Id ' + eq.Id);
            QueueableGoogleCall queueableGoogleCall = new QueueableGoogleCall(eq);
            System.enqueueJob(queueableGoogleCall);
        }
    }

    public class QueueableGoogleCall implements System.Queueable, Database.AllowsCallouts {
        private Equipment__c eq;
        public QueueableGoogleCall(Equipment__c eq){
            System.debug('@@@ QueueableGoogleCall()');
            this.eq = eq;
        }
        public void execute(QueueableContext context) {
            String endpoint = 'https://chart.apis.google.com/chart?cht=qr&chs=100x100&chl=' + eq.Id;
            System.debug('***endpoint ' + endpoint);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'image/png');
            HttpResponse response = new HttpResponse();
            try{
                response = http.send(request);
            }catch(System.Exception e){
                System.debug('***Exception ' + e.getMessage());
            }
            System.debug('***getStatusCode() ' + response.getStatusCode());
            System.debug('***getStatus() ' + response.getStatus());
            List<String> resHeaderKeys =  response.getHeaderKeys();
            for (String HeaderKey : resHeaderKeys){
                System.debug('***Header ' + HeaderKey + ' : ' + response.getHeader(HeaderKey));
            }
            if(response.getStatusCode() == 200 && response.getStatus() == 'OK'){
                ContentVersion cv = new ContentVersion();
                cv.VersionData = response.getBodyAsBlob();
                cv.PathOnClient = '/' + cv.Title + '.png';
                if(eq.Id != null){
                    cv.Title = String.valueOf(eq.Id).substring(0, 15);
                }
                Integer existImageCount = [SELECT COUNT() FROM ContentDocument WHERE Title = :cv.Title];
                if(existImageCount > 0){
                    ContentDocument existImage = [SELECT Id, Title FROM ContentDocument WHERE Title = :cv.Title];
                    cv.ContentDocumentId = existImage.Id;
                }
                insert cv;
                System.debug('***cv ' + cv);
                ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
                Integer existCdlCount = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :insertedCv.ContentDocumentId AND ShareType = 'V' AND Visibility = 'AllUsers' AND LinkedEntityId = :eq.Id];
                if(existCdlCount == 0){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    cdl.LinkedEntityId = eq.Id;
                    cdl.ContentDocumentId = insertedCv.ContentDocumentId;
                    insert cdl;
                    System.debug('***cdl ' + cdl);                    
                }
            }
        }
    }

}