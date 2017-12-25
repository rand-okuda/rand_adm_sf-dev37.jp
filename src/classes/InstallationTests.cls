@isTest
private class InstallationTests {
    
    @testSetup
    static void setup() {
        createMasterDatas(1,5);
    }
    
    @isTest
    static void InstallTest010() {
        // EquipmentTrigger & EquipmentLogic.QRcodeImageToGet
        System.debug('###InstallTest010');
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Model__c mo = [SELECT Id FROM Model__c LIMIT 1];
        Equipment__c eq = new Equipment__c();
        eq.Account__c = acc.Id;
        eq.Model__c = mo.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        insert eq;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest011() {
        // EquipmentTrigger & EquipmentLogic.QRcodeImageToGet
        System.debug('###InstallTest011');
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Model__c mo = [SELECT Id FROM Model__c LIMIT 1];
        Equipment__c eq = new Equipment__c();
        eq.Account__c = acc.Id;
        eq.Model__c = mo.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        insert eq;
        update eq;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest012() {
        // EquipmentTrigger & EquipmentLogic.QRcodeImageToGet
        System.debug('###InstallTest012');
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Model__c mo = [SELECT Id FROM Model__c LIMIT 1];
        Equipment__c eq = new Equipment__c();
        eq.Account__c = acc.Id;
        eq.Model__c = mo.Id;
        insert eq;
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        cv.Title = String.valueOf(eq.Id).substring(0, 15);
        insert cv;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        update eq;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest013() {
        // EquipmentTrigger
        System.debug('###InstallTest013');
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        ip.InspectionRresultA__c = '00';
        ip.InspectionRresultB__c = '00';
        ip.InspectionRresultC__c = '00';
        ip.InspectionRresultD__c = '00';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        update ip;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest020() {
        // InspectionTrigger & InspectionLogic.QRcodeImageToGet
        System.debug('###InstallTest020');
        createEqDatas(1);
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        Equipment__c eq = [SELECT Id FROM Equipment__c LIMIT 1];
        Inspection__c ip = new Inspection__c();
        ip.Equipment__c = eq.Id;
        ip.InspectionDateTime__c = System.now();
        ip.Worker__c = user01.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        insert ip;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest021() {
        // InspectionLogic.QueueableGoogleCall
        System.debug('###InstallTest021');
        Inspection__c ip = new Inspection__c();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        InspectionLogic.QueueableGoogleCall queueableGoogleCall = new InspectionLogic.QueueableGoogleCall(ip);
        System.enqueueJob(queueableGoogleCall);
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest022() {
        // InspectionLogic.QueueableGoogleCall
        System.debug('###InstallTest022');
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        InspectionLogic.QueueableGoogleCall queueableGoogleCall = new InspectionLogic.QueueableGoogleCall(ip);
        System.enqueueJob(queueableGoogleCall);
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest030() {
        // InspectionTrigger & InspectionLogic.CreateInspectionActivity
        System.debug('###InstallTest030');
        User user02 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3702'];
        createEqDatas(2);
        createIpDatas(2);
        List<Inspection__c> ipList = [SELECT Id FROM Inspection__c];
        ipList[0].InspectionDateTime__c = System.now();
        ipList[1].Worker__c = user02.Id;
        Test.startTest();
        update ipList;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest040() {
        // EventTrigger & EventLogic.UpdateInspectionWorkerDateTime
        System.debug('###InstallTest040');
        createEqDatas(2);
        createIpDatas(2);
        User user02 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3702'];
        List<Event> evList = [SELECT Id FROM Event];
        Test.startTest();
        evList[0].StartDateTime = System.now();
        evList[1].OwnerId = user02.Id;
        update evList;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest050() {
        // InspectionTrigger & InspectionLogic.RecordTypeChanger+CreateNextInspection
        System.debug('###InstallTest050');
        createEqDatas(4);
        createIpDatas(4);
        List<Inspection__c> ipList = [SELECT Id FROM Inspection__c];
        ipList[0].InspectionRresultA__c = '00';
        ipList[0].InspectionRresultB__c = '00';
        ipList[0].InspectionRresultC__c = '00';
        ipList[0].InspectionRresultD__c = '00';
        Test.startTest();
        update ipList;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest051() {
        // InspectionTrigger & InspectionLogic.CreateNextInspection
        System.debug('###InstallTest051');
        createEqDatas(1);
        createIpDatas(1);
        List<Inspection__c> ipList = [SELECT Id FROM Inspection__c];
        Test.startTest();
        ipList[0].InspectionRresultA__c = '00';
        ipList[0].InspectionRresultB__c = '00';
        ipList[0].InspectionRresultC__c = '00';
        ipList[0].InspectionRresultD__c = '00';
        update ipList[0];
        ipList[0].InspectionRresultA__c = null;
        ipList[0].InspectionRresultB__c = null;
        ipList[0].InspectionRresultC__c = null;
        ipList[0].InspectionRresultD__c = null;
        update ipList[0];
        ipList[0].InspectionRresultA__c = '00';
        ipList[0].InspectionRresultB__c = '00';
        ipList[0].InspectionRresultC__c = '00';
        ipList[0].InspectionRresultD__c = '00';
        update ipList;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest060() {
        // InspectionTrigger & InspectionLogic.CreateInspectionPDF
        System.debug('###InstallTest060');
        createEqDatas(1);
        createIpDatas(1);
        List<Inspection__c> ipList = [SELECT Id FROM Inspection__c];
        Test.startTest();
        ipList[0].TablePDFOutput__c = true;
        update ipList;
        ipList[0].TablePDFOutput__c = true;
        update ipList;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest070() {
        // FeedItemTrigger & FeedItemLogic.CommentFeedSearch
        System.debug('###InstallTest070');
        createEqDatas(1);
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        Equipment__c eq = [SELECT Name FROM Equipment__c LIMIT 1];
        FeedItem fi = new FeedItem();
        fi.Body = '<p>' + eq.Name + '</p>';
        fi.ParentId = user01.Id;
        Test.startTest();
        insert fi;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest071() {
        // FeedItemTrigger & FeedItemLogic.CommentFeedSearch
        System.debug('###InstallTest071');
        createEqDatas(1);
        createIpDatas(1);
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        Equipment__c eq = [SELECT Name FROM Equipment__c LIMIT 1];
        FeedItem fi = new FeedItem();
        fi.Body = '<p>' + eq.Name + '</p>';
        fi.ParentId = user01.Id;
        Test.startTest();
        insert fi;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest072() {
        // FeedItemTrigger & FeedItemLogic.CommentFeedSearch
        System.debug('###InstallTest072');
        createEqDatas(1);
        createIpDatas(1);
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        FeedItem fi = new FeedItem();
        fi.Body = '<p>' + '0000' + '</p>';
        fi.ParentId = user01.Id;
        Test.startTest();
        insert fi;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest080() {
        // FeedItemTrigger & FeedItemLogic.QRcodeImageSearch
        System.debug('###InstallTest080');
        createEqDatas(1);
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        insert cv;
        FeedItem fi = new FeedItem();
        fi.Title = 'TEST';
        fi.ParentId = user01.Id;
        fi.RelatedRecordId = cv.Id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock('', 200, 'Decode Succeeded'));
        insert fi;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest081() {
        // FeedItemLogic.QueueableZXingCall
        System.debug('###InstallTest081');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        insert cv;
        ContentDistribution cDi = new ContentDistribution();
        cDi.Name = 'TEST';
        cDi.ContentVersionId = cv.Id;
        insert cDi;
        createEqDatas(1);
        createIpDatas(1);
        Equipment__c eq = [SELECT Id FROM Equipment__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock(eq.Id, 200, 'Decode Succeeded'));
        FeedItemLogic.QueueableZXingCall queueableZXingCall = new FeedItemLogic.QueueableZXingCall(cDi);
        System.enqueueJob(queueableZXingCall);
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest082() {
        // FeedItemLogic.QueueableZXingCall
        System.debug('###InstallTest082');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        insert cv;
        ContentDistribution cDi = new ContentDistribution();
        cDi.Name = 'TEST';
        cDi.ContentVersionId = cv.Id;
        insert cDi;
        createEqDatas(1);
        Equipment__c eq = [SELECT Id FROM Equipment__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock(eq.Id, 200, 'Decode Succeeded'));
        FeedItemLogic.QueueableZXingCall queueableZXingCall = new FeedItemLogic.QueueableZXingCall(cDi);
        System.enqueueJob(queueableZXingCall);
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest090() {
        // ContentVersionTrigger & ContentVersionLogic.QRcodeImageSearch
        System.debug('###InstallTest090');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        cv.Origin = 'H';
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock(ip.Id, 200, 'Decode Succeeded'));
        insert cv;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest091() {
        // ContentVersionTrigger & ContentVersionLogic.QRcodeImageSearch
        System.debug('###InstallTest091');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        cv.Origin = 'H';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock('XXX', 200, 'Decode Succeeded'));
        insert cv;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest092() {
        // ContentVersionTrigger & ContentVersionLogic.QRcodeImageSearch
        System.debug('###InstallTest092');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        cv.Origin = 'H';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock('', 400, 'No Barcode Found'));
        insert cv;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest093() {
        // ContentVersionTrigger & ContentVersionLogic.QRcodeImageSearch
        System.debug('###InstallTest093');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        cv.Origin = 'H';
        insert cv;
        ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocument insertedCd = [SELECT Id, Title FROM ContentDocument WHERE Id = :insertedCv.ContentDocumentId];
        insertedCd.Title = 'xxx';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock('', 200, 'Decode Succeeded'));
        update insertedCd;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest094() {
        // ContentVersionTrigger & ContentVersionLogic.QRcodeImageSearch
        System.debug('###InstallTest094');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        cv.Origin = 'H';
        insert cv;
        ContentVersion insertedCv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocument insertedCd = [SELECT Id, Title FROM ContentDocument WHERE Id = :insertedCv.ContentDocumentId];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QueueableZXingCallMock('', 200, 'Decode Succeeded'));
        update insertedCd;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest095() {
        // ContentVersionTrigger & ContentVersionLogic.QRcodeImageSearch
        System.debug('###InstallTest095');
        delete [SELECT Id FROM ContentDocument];
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = '/TEST';
        cv.VersionData = blob.valueOf('TEST');
        cv.Origin = 'H';
        Test.startTest();
        insert cv;
        Test.stopTest();
    }
    
    @isTest
    static void InstallTest100() {
        // InspectionExtension.InspectionExtension
        System.debug('###InstallTest100');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
        }
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditS1;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
        }
    }
    
    @isTest
    static void InstallTest101() {
        // InspectionExtension.InspectionExtension
        System.debug('###InstallTest101');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            pageRef.getParameters().put('Id', ip.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
        }
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditS1;
            pageRef.getParameters().put('Id', ip.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
        }
    }
    
    @isTest
    static void InstallTest110() {
        // InspectionExtension.getNextInspection & getPreviousInspection
        System.debug('###InstallTest110');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(5);
        createIpDatas(5);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            extController.getNextInspection();
            extController.getNextInspection();
            extController.getNextInspection();
            extController.getNextInspection();
            extController.getNextInspection();
            extController.getPreviousInspection();            
            extController.getPreviousInspection();            
            extController.getPreviousInspection();            
            extController.getPreviousInspection();            
            extController.getPreviousInspection();            
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest120() {
        // InspectionExtension.confirmationCreateInspectionPDF & createInspectionPDF
        System.debug('###InstallTest120');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            extController.confirmationCreateInspectionPDF();
            extController.createInspectionPDF();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest130() {
        // InspectionExtension.confirmationPhoneReportInspection & phoneReportInspection
        System.debug('###InstallTest130');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            extController.confirmationPhoneReportInspection();
            extController.phoneReportInspection();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest131() {
        // InspectionExtension.confirmationPhoneReportInspection & phoneReportInspection
        System.debug('###InstallTest131');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            ip.InspectionRresultA__c = '00';
            ip.InspectionRresultB__c = '00';
            ip.InspectionRresultC__c = '00';
            ip.InspectionRresultD__c = '00';
            update ip;
            extController.approvalInspection();
            Test.startTest();
            extController.confirmationPhoneReportInspection();
            extController.phoneReportInspection();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest140() {
        // InspectionExtension.confirmationApprovalInspection & approvalInspection
        System.debug('###InstallTest140');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            ip.InspectionRresultA__c = '00';
            ip.InspectionRresultB__c = '00';
            ip.InspectionRresultC__c = '00';
            ip.InspectionRresultD__c = '00';
            update ip;
            Test.startTest();
            extController.confirmationApprovalInspection();
            extController.approvalInspection();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest141() {
        // InspectionExtension.confirmationApprovalInspection & approvalInspection
        System.debug('###InstallTest141');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            extController.confirmationApprovalInspection();
            extController.approvalInspection();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest150() {
        // InspectionExtension.saveInspection
        System.debug('###InstallTest150');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            extController.saveInspection();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest151() {
        // InspectionExtension.saveInspection
        System.debug('###InstallTest151');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            ip.InspectionRresultA__c = '00';
            ip.InspectionRresultB__c = '00';
            ip.InspectionRresultC__c = '00';
            ip.InspectionRresultD__c = '00';
            update ip;
            extController.approvalInspection();
            Test.startTest();
            extController.saveInspection();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest160() {
        // InspectionExtension.confirmationCancel
        System.debug('###InstallTest160');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTableEditLEX;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            extController.confirmationCancel();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest200() {
        // InspectionExtension.initPDF
        System.debug('###InstallTest200');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTablePDF;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            extController.initPDF();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest201() {
        // InspectionExtension.initPDF
        System.debug('###InstallTest201');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTablePDF;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            ContentVersion cv = new ContentVersion();
            cv.PathOnClient = '/TEST';
            cv.VersionData = blob.valueOf('TEST');
            cv.Origin = 'H';
            cv.Title = String.valueOf(ip.Id).substring(0, 15);
            insert cv;
            Attachment att = new Attachment();
            att.Name = String.valueOf(ip.Id).substring(0, 15);
            att.Body = cv.VersionData;
            att.ContentType = 'image/png';
            att.ParentId = ip.Id;
            insert att;
            Test.startTest();
            extController.initPDF();
            Test.stopTest();
        }
    }
    
    @isTest
    static void InstallTest202() {
        // InspectionExtension.initPDF
        System.debug('###InstallTest202');
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        createEqDatas(1);
        createIpDatas(1);
        Inspection__c ip = [SELECT Id FROM Inspection__c LIMIT 1];
        System.runAs(user01) {
            PageReference pageRef = Page.InspectionTablePDF;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ip);
            InspectionExtension extController = new InspectionExtension(stdController);
            Test.setCurrentPage(pageRef);
            ContentVersion cv = new ContentVersion();
            cv.PathOnClient = '/TEST';
            cv.VersionData = blob.valueOf('TEST');
            cv.Origin = 'H';
            cv.Title = String.valueOf(ip.Id).substring(0, 15);
            insert cv;
            Test.startTest();
            extController.initPDF();
            Test.stopTest();
        }
    }
    
    static void createMasterDatas(Integer numAcc, Integer numMo){
        // Setup Testing Datas
        System.debug('###createMasterDatas ');
        Profile testProfile = [SELECT Id FROM Profile WHERE Name LIKE '%モバイルQR Platform ユーザ%']; 
        User testUser01 = new User (Alias = 'rdok3701', Email='rand.okuda+37@gmail.com', LastName='randokuda01', ProfileId = testProfile.Id, LocaleSidKey='ja_JP', LanguageLocaleKey='ja', EmailEncodingKey='ISO-2022-JP', TimeZoneSidKey='Asia/Tokyo', UserName='rand.okuda.201711021414.01@gmail.com');
        insert testUser01;
        User testUser02 = new User (Alias = 'rdok3702', Email='rand.okuda+37@gmail.com', LastName='randokuda02', ProfileId = testProfile.Id, LocaleSidKey='ja_JP', LanguageLocaleKey='ja', EmailEncodingKey='ISO-2022-JP', TimeZoneSidKey='Asia/Tokyo', UserName='rand.okuda.201711021414.02@gmail.com');
        insert testUser02;
        List<Account> accList = new List<Account>();
        for (Integer i=0;i<numAcc;i++) {
            Account acc = new Account();
            acc.Name = 'ACC-' + i;
            accList.add(acc);
        }
        insert accList;
        List<String> modelTypeList = new List<String>();
        Schema.DescribeFieldResult modelTypeFidldResult = Model__c.ModelType__c.getDescribe();
        List<Schema.PicklistEntry> modelTypePicklistEntrys = modelTypeFidldResult.getPicklistValues();
        Integer numMtp = modelTypePicklistEntrys.size() - 1;
        for (Schema.PicklistEntry modelTypePicklistEntry : modelTypePicklistEntrys) {
            System.debug('###modelTypePicklistEntry ' + modelTypePicklistEntry);
            if(modelTypePicklistEntry.isActive()){
                modelTypeList.add(String.valueOf(modelTypePicklistEntry.getValue()));
            }
        }
        List<Model__c> moList = new List<Model__c>();
        Integer j = 0;
        for (Integer i=0;i<numMo;i++) {
            Model__c mo = new Model__c();
            mo.Name = 'MO-' + i;
            mo.ModelType__c = modelTypeList[j];
            mo.CheckSpan__c = 28;
            moList.add(mo);
            if(j == numMtp){
                j = 0;
            }else{
                j++;
            }
        }
        insert moList;
        for(Account acc :accList){
            System.debug('###acc ' + acc);
        }
        for(Model__c mo :moList){
            System.debug('###mo ' + mo);
        }
    }
    
    static void createEqDatas(Integer eqNum){
        // Setup Testing Datas
        System.debug('###createEqDatas ');
        delete [SELECT Id FROM Equipment__c];
        List<Equipment__c> eqList = new List<Equipment__c>();
        Integer i = 1;
        for (Account acc : [SELECT Id FROM Account]){
            for (Model__c mo : [SELECT Id FROM Model__c]){
                Equipment__c eq = new Equipment__c();
                eq.Account__c = acc.Id;
                eq.Model__c = mo.Id;
                if (i <= eqNum){
                    eqList.add(eq);
                }
            }
        }
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        insert eqList;
        for(Equipment__c eq :eqList){
            System.debug('###eq ' + eq);
        }
    }
    
    static void createIpDatas(Integer ipNum){
        // Setup Testing Datas
        System.debug('###createIpDatas ');
        delete [SELECT Id FROM Inspection__c];
        User user01 = [SELECT Id, Alias FROM User WHERE Alias = 'rdok3701'];
        List<Inspection__c> ipList = new List<Inspection__c>();
        Integer i = 1;
        for (Equipment__c eq : [SELECT Id FROM Equipment__c]){
            Inspection__c ip = new Inspection__c();
            ip.Equipment__c = eq.Id;
            ip.InspectionDateTime__c = System.now();
            ip.Worker__c = user01.Id;
            if (i <= ipNum){
                ipList.add(ip);
                i++;
            }
        }
        Test.setMock(HttpCalloutMock.class, new QueueableGoogleCallMock());
        insert ipList;
        for(Inspection__c ip :ipList){
            System.debug('###ip ' + ip);
        }
        for(Inspection__c ip :[SELECT Id, Name, RecordType.DeveloperName FROM Inspection__c]){
            System.debug('###ip.RecordType.DeveloperName ' + ip.Name + ' ' + ip.RecordType.DeveloperName);
        }
    }
    
}