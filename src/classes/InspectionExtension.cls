public with sharing class InspectionExtension {
    
    public Inspection__c ip {get;set;}
    public String InspectionDateTime {get;set;}
    public Boolean renderA {get;set;}
    public Boolean renderB {get;set;}
    public Boolean renderC {get;set;}
    public Boolean renderD {get;set;}

    private Id currentWorkerInspectionId;
    private Integer inspectionCount;
    private List<Inspection__c> currentWorkerInspectionList;
    public String Message {get;set;}
    public String pageInformation {get;set;}
    public Boolean renderMoveButton {get;set;}
    public Boolean renderCancelButton {get;set;}
    public Boolean renderPDFButton {get;set;}
    public Boolean renderApprovalButton {get;set;}
    public Boolean renderPhoneReportButton {get;set;}
    public String selectionUser { get; set; }
    public List<SelectOption> selectUserList {get; set;}

    public Inspection__c ipPdf {get;set;}
    public Attachment imageAtt {get;set;}
    public Boolean renderQR {get;set;}
    
    public InspectionExtension(ApexPages.StandardController stdController){
        System.debug('@@@InspectionExtension');
        Id currentId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('***currentId ' + currentId);
        Message = '';
        renderQR = false;
        renderMoveButton = false;
        renderCancelButton = false;
        if(currentId == null){
            getCurrentWorkerInspection();
        }else{
            renderCancelButton = true;
            getInspection(currentId);
        }
    }

    public void getCurrentWorkerInspection(){
        System.debug('@@@getCurrentWorkerInspection()');
        String userId = UserInfo.getUserId();
        System.debug('***userId ' + userId);
        inspectionCount = [SELECT COUNT() FROM Inspection__c WHERE Worker__c = :userId AND TodayTarget__c = true];
        if(inspectionCount > 0){
            currentWorkerInspectionList = [SELECT Id, TodayTarget__c, Worker__c, InspectionDateTime__c FROM Inspection__c WHERE Worker__c = :userId AND TodayTarget__c = true ORDER BY InspectionDateTime__c];
            for(Inspection__c ip :currentWorkerInspectionList){
                System.debug('***ip ' + ip);
            }
            renderMoveButton = true;
            currentWorkerInspectionId = currentWorkerInspectionList[0].Id;
            pageInformation = 1 + '/' + inspectionCount;
            getInspection(currentWorkerInspectionId);
        }
    }

    public void getNextInspection(){
        System.debug('@@@getNetInspection()');
        renderMoveButton = true;
        renderPhoneReportButton = false;
        renderApprovalButton = false;
        renderPDFButton = false;
        Message = '';
        String userId = UserInfo.getUserId();
        System.debug('***userId ' + userId);
        System.debug('***currentWorkerInspectionId ' + currentWorkerInspectionId);
        if(inspectionCount > 0){
            for(Integer i=0;i<inspectionCount-1;i++) {
                if(currentWorkerInspectionList[i].Id == currentWorkerInspectionId){
                    Integer nextIdNum = i + 1;
                    pageInformation = nextIdNum + 1 + '/' + inspectionCount;
                    Id nextWorkerInspectionId = currentWorkerInspectionList[nextIdNum].Id;
                    System.debug('***nextWorkerInspectionId ' + nextWorkerInspectionId);
                    currentWorkerInspectionId = nextWorkerInspectionId;
                    getInspection(nextWorkerInspectionId);
                    break;
                }
            }
        }
    }

    public void getPreviousInspection(){
        System.debug('@@@getLastInspection()');
        renderMoveButton = true;
        renderPhoneReportButton = false;
        renderApprovalButton = false;
        renderPDFButton = false;
        Message = '';
        String userId = UserInfo.getUserId();
        System.debug('***userId ' + userId);
        System.debug('***currentWorkerInspectionId ' + currentWorkerInspectionId);
        if(inspectionCount > 0){
            for(Integer i=1;i<inspectionCount;i++) {
                if(currentWorkerInspectionList[i].Id == currentWorkerInspectionId){
                    Integer lastIdNum = i - 1;
                    pageInformation = lastIdNum + 1 + '/' + inspectionCount;
                    Id lastWorkerInspectionId = currentWorkerInspectionList[lastIdNum].Id;
                    System.debug('***lastWorkerInspectionId ' + lastWorkerInspectionId);
                    currentWorkerInspectionId = lastWorkerInspectionId;
                    getInspection(lastWorkerInspectionId);
                    break;
                }
            }
        }
    }

    public void getInspection(Id currentId){
        System.debug('@@@getInspection()');
        ip = [SELECT Id, Name, 
              RecordType.DeveloperName, RecordType.Name, 
              Equipment__c, EquipmentId__c, EquipmentNumber__c, 
              Manufacturer__c, ModelName__c, 
              InspectionCompleted__c, InspectionDateTime__c,
              InspectionRresultA__c, 
              InspectionRresultB__c, 
              InspectionRresultC__c, 
              InspectionRresultD__c, 
              InspectionNoticesA__c, 
              InspectionNoticesB__c, 
              InspectionNoticesC__c, 
              InspectionNoticesD__c, 
              WorkerName__c, AccountName__c, 
              PhoneReport__c, 
              Remarks__c
              FROM Inspection__c WHERE Id = :currentId];
        System.debug('***ip ' + ip);
        if (ip.InspectionDateTime__c != null){
            DateTime ipDateTime = ip.InspectionDateTime__c;
            InspectionDateTime = ipDateTime.format();
        }
        System.debug('***InspectionDateTime ' + InspectionDateTime);
        System.debug('***DeveloperName ' + ip.RecordType.DeveloperName);
        renderA = true;
        renderB = true;
        renderC = true;
        renderD = true;
        if(ip.RecordType.DeveloperName == 'Air'){
            renderA = true;
            renderB = false;
            renderC = true;
            renderD = true;
        }else if(ip.RecordType.DeveloperName == 'Cogener'){
            renderA = true;
            renderB = true;
            renderC = false;
            renderD = true;
        }else if(ip.RecordType.DeveloperName == 'Solar'){
            renderA = true;
            renderB = true;
            renderC = true;
            renderD = false;
        }else if(ip.RecordType.DeveloperName == 'Storage'){
            renderA = true;
            renderB = false;
            renderC = false;
            renderD = true;
        }
    }
    
    public void confirmationCreateInspectionPDF(){
        System.debug('@@@confirmationCreateInspectionPDF()');
        Message = '　PDFを作成しますか？';
        renderPDFButton = true;
        renderApprovalButton = false;
        renderPhoneReportButton = false;
    }

    public void confirmationPhoneReportInspection(){
        System.debug('@@@confirmationPhoneReportInspection()');
        Message = '　連絡を依頼しますか？';
        renderPDFButton = false;
        renderApprovalButton = false;
        renderPhoneReportButton = true;
        List<User> userList = [SELECT Id, Name, IsActive, UserType, LastLoginDate FROM User WHERE LastLoginDate != null AND UserType = 'Standard' AND IsActive = true];
        selectUserList = new List<selectOption>();
	    selectOption soNull = new selectOption('', '-未選択-');
    	selectUserList.add(soNull);
        for(User u :userList){
            selectOption so = new selectOption(u.Id, u.Name);
         	selectUserList.add(so);
        }
    }

    public void confirmationApprovalInspection(){
        System.debug('@@@confirmationApprovalInspection()');
        Message = '　承認を申請しますか？';
        renderPDFButton = false;
        renderApprovalButton = true;
        renderPhoneReportButton = false;
    }

    public void confirmationCancel(){
        System.debug('@@@confirmationCancel()');
        Message = '';
        renderPDFButton = false;
        renderApprovalButton = false;
        renderPhoneReportButton = false;
    }

    public void createInspectionPDF(){
        System.debug('@@@createInspectionPDF()');
        Message = '';
        if(ip != null){
            InspectionLogic.QueueableCreatePDF queueableCreatePDF = new InspectionLogic.QueueableCreatePDF(ip);
            System.enqueueJob(queueableCreatePDF);
        }
        renderPDFButton = false;
    }

    public void phoneReportInspection(){
        System.debug('@@@phoneReportInspection()');
        Message = '';
        if(ip != null){
            try{
                ip.PhoneReport__c = selectionUser;
                update ip;
            }catch (System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    Message += e.getDmlMessage(i);
                    System.debug('*** Message = ' + Message);
                }
            }
        }
        renderPhoneReportButton = false;
    }

    public void approvalInspection(){
        System.debug('@@@approvalInspection()');
        Message = '';
        if(ip != null){
            try{
                Approval.ProcessSubmitRequest apsr = new Approval.ProcessSubmitRequest();
                apsr.setObjectId(ip.Id);
                apsr.setNextApproverIds(null);
                Approval.ProcessResult apr = Approval.process(apsr);
            }catch (System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    Message += e.getDmlMessage(i);
                    System.debug('*** Message = ' + Message);
                }
            }
        }
        renderApprovalButton = false;
    }

    public void saveInspection(){
        System.debug('@@@saveInspection()');
        Message = '';
        if(ip != null){
            try{
                update ip;
            }catch (System.DmlException e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    Message += e.getDmlMessage(i);
                    System.debug('*** Message = ' + Message);
                }
            }            
        }
    }
    
    public void initPDF(){
        System.debug('@@@initPDF()');
        if(ip != null){
            ipPdf = [SELECT Id,  
                     toLabel(InspectionRresultA__c), 
                     toLabel(InspectionRresultB__c), 
                     toLabel(InspectionRresultC__c), 
                     toLabel(InspectionRresultD__c)
                     FROM Inspection__c WHERE Id = :ip.Id];
            System.debug('***ipPdf ' + ipPdf);
            String ipId15 = String.valueOf(ip.Id).substring(0, 15);
            System.debug('***ipId15 ' + ipId15);
            Integer existAttCount = [SELECT COUNT() FROM Attachment WHERE ParentId = :ip.Id AND Name = :ipId15];
            if(existAttCount > 0){
                Attachment existAtt = [SELECT Id, ParentId, Name FROM Attachment WHERE ParentId = :ip.Id AND Name = :ipId15];
                imageAtt = existAtt;
                renderQR = true;
                System.debug('***imageAtt(Exist) ' +imageAtt);
            }else{
                Integer existVcCount = [SELECT COUNT() FROM ContentVersion WHERE Title = :ipId15 AND IsMajorVersion = true];
                if(existVcCount > 0){
                    ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Title = :ipId15 AND IsMajorVersion = true LIMIT 1];
                    Attachment att = new Attachment();
                    att.Name = cv.Title;
                    att.Body = cv.VersionData;
                    att.ContentType = 'image/png';
                    att.ParentId = ip.Id;
                    insert att;
                    imageAtt = att;
                    renderQR = true;
                    System.debug('***imageAtt(New) ' +imageAtt);                    
                }else{
                    System.debug('***imageVc(not found) ' +ipId15);
                    List<Inspection__c> ipList = new List<Inspection__c>();
                    ipList.add(ip);
                    InspectionLogic.QRcodeImageToGet(ipList);
                }
            }
        }
    }
    
}