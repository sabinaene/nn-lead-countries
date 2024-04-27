public with sharing class CountryLayerScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {    
        System.enqueueJob(new AsyncCallout());
    }

    /**
     * Async class to process API country data
     */
    public class AsyncCallout implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext qc) {    
            CountryLayerService service = new CountryLayerService();
            service.executeUpdates();
        }
    }
}