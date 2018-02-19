public class InspectionLogic {
    
    public static void QRcodeImageToGet(List<Inspection__c> inspectionList){
        System.debug('***@@@QRcodeImageToGet()');
        System.debug('***inspectionList ' + inspectionList);
        for(Inspection__c ip :inspectionList){
            System.debug('***Id ' + ip.Id);
            QueueableGoogleCall queueableGoogleCall = new QueueableGoogleCall(ip);
            System.enqueueJob(queueableGoogleCall);
        }
    }
    
    public class QueueableGoogleCall implements System.Queueable, Database.AllowsCallouts {
        private Inspection__c ip;
        public QueueableGoogleCall(Inspection__c ip){
            System.debug('@@@ QueueableGoogleCall()');
            this.ip = ip;
        }
        public void execute(QueueableContext context) {
            String endpoint = 'https://chart.apis.google.com/chart?cht=qr&chs=100x100&chl=' + ip.Id;
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
                if(ip.Id != null){
                    cv.Title = String.valueOf(ip.Id).substring(0, 15);
                }
                Integer existImageCount = [SELECT COUNT() FROM ContentDocument WHERE Title = :cv.Title];
                if(existImageCount > 0){
                    ContentDocument existImage = [SELECT Id, Title FROM ContentDocument WHERE Title = :cv.Title];
                    cv.ContentDocumentId = existImage.Id;
                }
                insert cv;
                System.debug('***cv ' + cv);
                ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
                Organization org = [SELECT Id FROM Organization LIMIT 1];
                Integer existCdlCount = [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :insertedCv.ContentDocumentId AND ShareType = 'V' AND Visibility = 'AllUsers' AND LinkedEntityId = :org.Id];
                if(existCdlCount == 0){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    cdl.LinkedEntityId = org.Id;
                    cdl.ContentDocumentId = insertedCv.ContentDocumentId;
                    insert cdl;
                    System.debug('***cdl ' + cdl);                    
                }
            }
        }
    }
    
    public static void CreateInspectionPDF(list<Inspection__c> inspectionList){
        System.debug('@@@ CreateInspectionPDF()');
        System.debug('***inspectionList ' + inspectionList);
        for(Inspection__c ip :inspectionList){
            QueueableCreatePDF queueableCreatePDF = new QueueableCreatePDF(ip);
            System.enqueueJob(queueableCreatePDF);
        }
    }
    
    public class QueueableCreatePDF implements System.Queueable, Database.AllowsCallouts {
        private Inspection__c ip;
        public QueueableCreatePDF(Inspection__c ip){
            System.debug('@@@ QueueableCreatePDF()');
            this.ip = ip;
        }
        public void execute(QueueableContext context) {
            PageReference pdfPage = Page.InspectionTablePDF;
            pdfPage.getParameters().put('id',ip.id);
            ContentVersion cv = new ContentVersion();
            Blob pdfPageContent = Blob.valueOf('DummyString');
            try {
                pdfPageContent = pdfPage.getContent();
            }catch(System.VisualforceException e){
                System.debug('***Exception ' + e.getMessage());
            }
            cv.VersionData = pdfPageContent;
            cv.Title = ip.AccountName__c + '_' + ip.ModelName__c + '_' + ip.EquipmentNumber__c + '_' + ip.InspectionDateTime__c;
            Integer existPDFCount = [SELECT COUNT() FROM ContentDocument WHERE Title = :cv.Title];
            if(existPDFCount > 0){
                ContentDocument existPDF = [SELECT Id, Title FROM ContentDocument WHERE Title = :cv.Title];
                cv.ContentDocumentId = existPDF.Id;
            }
            cv.PathOnClient = '/' + cv.Title + '.pdf';
            insert cv;
            System.debug('***cv ' + cv);
            FeedItem fi = new FeedItem();
            fi.Body = 'Auto feed by Trigger';
            fi.ParentId = ip.Id;
            fi.RelatedRecordId = cv.Id;
            insert fi;
        }
    }

    public static void CreateNextInspection(list<Inspection__c> inspectionList){
        System.debug('@@@ CreateNextInspection()');
        Set<Id> existInspectionIdSet = new Set<Id>();
        for(Inspection__c ip :inspectionList){
            existInspectionIdSet.add(ip.Id);
        }
        List<Inspection__c> existInspectionList = [SELECT Id FROM Inspection__c WHERE LastInspection__c IN :existInspectionIdSet];
        if(existInspectionList.size() > 0){
            delete existInspectionList;
        }
        List<Inspection__c> nextInspection = inspectionList.deepClone();
        for(Inspection__c nextIp :nextInspection){
            nextIp.InspectionRresultA__c = null;
            nextIp.InspectionRresultB__c = null;
            nextIp.InspectionRresultC__c = null;
            nextIp.InspectionRresultD__c = null;
            Datetime currentDatetime = nextIp.InspectionDateTime__c;
            Datetime nextDatetime = currentDatetime.addDays(Integer.valueOf(nextIp.CheckSpan__c));
            nextIp.InspectionDateTime__c = nextDatetime;
            for(Inspection__c ip :inspectionList){
                if(nextIp.Equipment__c == ip.Equipment__c){
                    nextIp.LastInspection__c = ip.Id;
                    System.debug('***ip ' + ip);
                    System.debug('***nextIp ' + nextIp);
                    break;
                }
            }
        }
        insert nextInspection;
    }
    
    public static void CreateInspectionActivity(list<Inspection__c> inspectionList){
        System.debug('@@@ CreateInspectionActivity()');
        Set<Id> inspectionIdList = new Set<Id>();
        for(Inspection__c ip :inspectionList){
            inspectionIdList.add(ip.Id);
            System.debug('***ip ' + ip);
        }
        List<Event> existEvList = [SELECT Id, WhatId, StartDateTime, OwnerId, AutoCreateByTrigger__c FROM Event WHERE WhatId = :inspectionIdList AND AutoCreateByTrigger__c = true];
        System.debug('***existEvList' + existEvList);
        Set<Id> deleteEvIdSet = new Set<Id>();
        List<Event> evList = new List<Event>();
        if(existEvList.size() > 0){
            for(Inspection__c ip :inspectionList){
                for(Event existEv :existEvList){
                    if(ip.Id == existEv.WhatId){
                        if(existEv.OwnerId != ip.Worker__c || existEv.StartDateTime != ip.InspectionDateTime__c){
                            deleteEvIdSet.add(existEv.Id);
                            Event ev = CreateEvent(ip);
                            evList.add(ev);
                            System.debug('***ev(Replacement) ' + ev);
                        }else{
                            System.debug('*** Nothing to Processing');
                        }
                    }
                }
            }
        }else{
            for(Inspection__c ip :inspectionList){
                Event ev = CreateEvent(ip);
                evList.add(ev);
                System.debug('***ev(Addition) ' + ev);
            }
        }
        if(deleteEvIdSet.size() > 0){
            System.debug('***deleteEvList ' + deleteEvIdSet);
            delete [SELECT Id FROM Event WHERE Id = :deleteEvIdSet];
        }
        if(evList.size() > 0){
            System.debug('***evList ' + evList);
            insert evList;
        }
    }
    
    private static Event CreateEvent(Inspection__c ip){
        System.debug('@@@ CreateEvent()');
        Event ev = new Event();
        ev.Subject = ip.AccountName__c + ' ' + ip.ModelName__c + ' ' + ip.WorkerName__c;
        ev.StartDateTime = ip.InspectionDateTime__c;
        ev.EndDateTime = ip.InspectionDateTime__c.addHours(2);
        ev.OwnerId = ip.Worker__c;
        ev.WhatId = ip.Id;
        ev.AutoCreateByTrigger__c = true;
        return ev;
    }

    public static void DeleteEvent(list<Inspection__c> inspectionList){
        System.debug('@@@ DeleteEvent()');
        Set<Id> ipIdSet = new Set<Id>();
        for(Inspection__c ip :inspectionList){
            ipIdSet.add(ip.Id);
        }
        delete [SELECT Id, StartDateTime, OwnerId, WhatId FROM Event WHERE WhatId = :ipIdSet AND AutoCreateByTrigger__c = true];
    }

    public static void RecordTypeChanger(list<Inspection__c> inspectionList){
        System.debug('@@@ RecordTypeChanger()');
        Map<String, String> recordTypeMap = new Map<String, String>();
        for(RecordType rt :[SELECT Id, DeveloperName FROM RecordType WHERE sObjectType = 'Inspection__c']){
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        Set<Id> equipmentIdSet = new Set<Id>();
        for(Inspection__c ip :inspectionList){
            equipmentIdSet.add(ip.Equipment__c);
        }
        Map<String, String> modelTypeMap = new Map<String, String>();
        for(Equipment__c eq :[SELECT Id, Model__r.ModelType__c FROM Equipment__c WHERE Id = :equipmentIdSet]){
            modelTypeMap.put(eq.Id, eq.Model__r.ModelType__c);
        }
        for(Inspection__c ip :inspectionList){
            String modelType = modelTypeMap.get(ip.Equipment__c);
            System.debug('***modelType ' + modelType);
            Id recordTypeId = recordTypeMap.get(modelType);
            System.debug('***recordTypeId ' + recordTypeId);
            ip.RecordTypeId = recordTypeId;
            System.debug('***ip ' + ip);
        }
    }
    
}