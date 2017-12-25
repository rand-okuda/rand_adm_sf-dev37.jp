trigger EquipmentTrigger on Equipment__c (after update, after insert) {

    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('%%%EquipmentTrigger isAfter isInsert');
        List<Equipment__c> equipmentList = new List<Equipment__c>();
        for(Equipment__c eqNew :Trigger.New){
            equipmentList.add(eqNew);
        }
        EquipmentLogic.QRcodeImageToGet(equipmentList);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%EquipmentTrigger isAfter isUpdate');
        List<Equipment__c> equipmentList = new List<Equipment__c>();
        for(Equipment__c eqNew :Trigger.New){
            for(Equipment__c eqOld :Trigger.Old){
                if(eqNew.Id == eqOld.Id){
                    if(eqNew.LastInspectionDateTime__c == eqOld.LastInspectionDateTime__c){
                        equipmentList.add(eqNew);
                        break;
                    }else{
                        break;
                    }
                }
            }
        }
        if(equipmentList.size() > 0){
            EquipmentLogic.QRcodeImageToGet(equipmentList);
        }
    }

}