trigger EventTrigger on Event (after update) {

    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('%%%EventTrigger isAfter isUpdate');
        List<Event> evList = new List<Event>();
        for(Event evNew :Trigger.new){
            for(Event evOld :Trigger.old){
                if(evNew.Id == evOld.Id){
                    if(evNew.OwnerId != evOLD.OwnerId || evNew.StartDateTime != evOld.StartDateTime){
                        evList.add(evNew);
                        break;
                    }else{
                        break;
                    }
                }
            }
        }
        if(evList.size() > 0){
            EventLogic.UpdateInspectionWorkerDateTime(evList);
        }
    }

}