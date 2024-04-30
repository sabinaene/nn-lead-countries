public with sharing class CountryLayerScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {    
        System.enqueueJob(new AsyncCallout());
    }

    /**
     * Async class to process API country data
     */
    public class AsyncCallout implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext qc) {
            Map<String, Country__c> existingCountriesByName = CountryLayerService.getCountriesByName();
            Map<String, CountryLayerService.ApiCountry> apiCountriesByName =
                CountryLayerService.getDeserializedApiResponse();

            CountryLayerService.upsertCountries(existingCountriesByName, apiCountriesByName);
            CountryLayerService.deleteObsoleteCountries(existingCountriesByName, apiCountriesByName);
        }
    }
}