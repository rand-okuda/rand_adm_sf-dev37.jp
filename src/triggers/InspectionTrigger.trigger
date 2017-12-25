trigger InspectionTrigger on Inspection__c (before insert, after insert, after update) {

    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('%%%InspectionTrigger isBefore isInsert');
        List<Inspection__c> inspectionList = new List<Inspection__c>();
        for(Inspection__c ip :Trigger.new){
            inspectionList.add(ip);
        }
        InspectionLogic.RecordTypeChanger(inspectionList);        
    }

    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('%%%InspectionTrigger isAfter isInsert');
        List<Inspection__c> ChangeScheduleInspectionList = new List<Inspection__c>();
        for(Inspection__c ipNew :Trigger.new){
            if(ipNew.InspectionDateTime__c != null && ipNew.Worker__c != null){
                ChangeScheduleInspectionList.add(ipNew);
            }
        }
        if(ChangeScheduleInspectionList.size() > 0){
            InspectionLogic.CreateInspectionActivity(ChangeScheduleInspectionList);                
        }
    }

    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('%%%InspectionTrigger isAfter isInsert');
        List<Inspection__c> QRcodeImageToGetInspectionList = new List<Inspection__c>();
        for(Inspection__c ip :Trigger.new){
            QRcodeImageToGetInspectionList.add(ip);
        }
        InspectionLogic.QRcodeImageToGet(QRcodeImageToGetInspectionList);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%InspectionTrigger isAfter isUpdate');
        List<Inspection__c> ChangeScheduleInspectionList = new List<Inspection__c>();
        for(Inspection__c ipNew :Trigger.new){
            if(ipNew.InspectionDateTime__c != null && ipNew.Worker__c != null){
                for(Inspection__c ipOld :Trigger.old){
                    if(ipNew.Id == ipOld.Id){
                        if(ipNew.InspectionDateTime__c != ipOld.InspectionDateTime__c || ipNew.Worker__c != ipOld.Worker__c){
                            ChangeScheduleInspectionList.add(ipNew);
                            break;
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        if(ChangeScheduleInspectionList.size() > 0){
            InspectionLogic.CreateInspectionActivity(ChangeScheduleInspectionList);                
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%InspectionTrigger isAfter isUpdate');
        List<Inspection__c> CompletedInspectionList = new List<Inspection__c>();
        for(Inspection__c ipNew :Trigger.new){
            if(ipNew.InspectionCompleted__c){
                for(Inspection__c ipOld :Trigger.old){
                    if(ipNew.Id == ipOld.Id){
                        if(ipNew.InspectionCompleted__c != ipOld.InspectionCompleted__c){
                            CompletedInspectionList.add(ipNew);
                            break;
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        if(CompletedInspectionList.size() > 0){
            InspectionLogic.CreateNextInspection(CompletedInspectionList);
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%InspectionTrigger isAfter isUpdate');
        List<Inspection__c> PDFOutputInspectionList = new List<Inspection__c>();
        for(Inspection__c ipNew :Trigger.new){
            for(Inspection__c ipOld :Trigger.old){
                if(ipNew.Id == ipOld.Id){
                    if(ipNew.TablePDFOutput__c){
                        PDFOutputInspectionList.add(ipNew);
                        break;
                    }else{
                        break;
                    }
                }
            }
        }
        if(PDFOutputInspectionList.size() > 0){
            InspectionLogic.CreateInspectionPDF(PDFOutputInspectionList);
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%InspectionTrigger isAfter isUpdate');
        List<Inspection__c> QRcodeImageToGetInspectionList = new List<Inspection__c>();
        for(Inspection__c ipNew :Trigger.new){
            for(Inspection__c ipOld :Trigger.old){
                if(ipNew.Id == ipOld.Id){
                    if(ipNew.InspectionDateTime__c != ipOld.InspectionDateTime__c || ipNew.Worker__c != ipOld.Worker__c){
                        QRcodeImageToGetInspectionList.add(ipNew);
                        break;
                    }else{
                        break;
                    }
                }
            }
        }
        if(QRcodeImageToGetInspectionList.size() > 0){
            InspectionLogic.QRcodeImageToGet(QRcodeImageToGetInspectionList);
        }
    }

}