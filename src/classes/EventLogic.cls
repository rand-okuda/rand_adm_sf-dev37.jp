public class EventLogic {

    public static void UpdateInspectionWorkerDateTime(List<Event> evList){
        System.debug('@@@ UpdateInspectionWorkerDateTime()');
        Set<Id> inspectionIdSet = new Set<Id>();
        for(Event ev :evList){
            inspectionIdSet.add(ev.WhatId);
        }
        for(Inspection__c ip :[SELECT Id, InspectionDateTime__c, Worker__c FROM Inspection__c WHERE Id = :inspectionIdSet]){
            for(Event ev :evList){
                if(ev.WhatId == ip.Id){
                    System.debug('***ev ' + ev);
                    System.debug('***ip ' + ip);
                    QueueableUpdateInspection queueableUpdateInspection = new QueueableUpdateInspection(ev, ip);
                    System.enqueueJob(queueableUpdateInspection);
                }
            }
        }
    }

    public class QueueableUpdateInspection implements System.Queueable {
        private Event ev;
        private Inspection__c ip;
        public QueueableUpdateInspection(Event ev, Inspection__c ip){
            System.debug('@@@ QueueableUpdateInspection()');
            this.ev = ev;
            this.ip = ip;
        }
        public void execute(QueueableContext context) {
            ip.Worker__c = ev.OwnerId;
            ip.InspectionDateTime__c = ev.StartDateTime;
            update ip;
            System.debug('***ev(Q) ' + ev);
            System.debug('***ip(Q) ' + ip);
        }
    }

}