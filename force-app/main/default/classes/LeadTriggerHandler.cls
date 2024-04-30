public with sharing class LeadTriggerHandler {
    
    /**
     * Before insert trigger handler
     * @param newLeads List of new Leads records before save
     */
    public static void beforeInsert(List<Lead> newLeads) {
        if(canQueryCountries()) {
            List<String> countryNames = new List<String>();
            List<Lead> leadsToUpdate = new List<Lead>();

            for(Lead ld : newLeads) {
                if(!String.isBlank(ld.Country)) {
                    leadsToUpdate.add(ld);
                    countryNames.add(ld.Country);
                }
            }

            Map<String, Country__c> countriesByName = CountryLayerService.getCountriesByName();
            updateLeadsWithCountries(leadsToUpdate, countriesByName);
        }
    }

    /**
     * Before update trigger handler
     * @param newLeads List of newly updated Leads records before save
     * @param oldLeadMap Map with old versions of newly updated Lead records, by ID
     */
    public static void beforeUpdate(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        if(canQueryCountries()) {
            List<String> countryNames = new List<String>();
            List<Lead> leadsToUpdate = new List<Lead>();

            for(Lead ld : newLeads) {
                if(ld.Country != oldLeadMap.get(ld.Id).Country) {
                    leadsToUpdate.add(ld);
                    countryNames.add(ld.Country);
                }
            }

            Map<String, Country__c> countriesByName = CountryLayerService.getCountriesByName();
            updateLeadsWithCountries(leadsToUpdate, countriesByName);
        }
    }

    /**
     * Checks if the current user has permission to query Country__c
     * @return Has/doesn't have permission
     */
    @TestVisible
    private static Boolean canQueryCountries() {
        return SObjectType.Country__c.fields.CapitalCity__c.isAccessible() &&
            SObjectType.Country__c.fields.Region__c.isAccessible() &&
            SObjectType.Country__c.fields.Alpha2Code__c.isAccessible() &&
            SObjectType.Country__c.fields.Alpha3Code__c.isAccessible();
    }

    /**
     * Updates Lead records with country info from the Country__c record
     * matching the Address Country
     * @param leads List of Lead records to update
     * @param countriesByName Map of Country__c records by Name__c
     */
    @TestVisible
    private static void updateLeadsWithCountries(List<Lead> leads, Map<String, Country__c> countriesByName) {
        for(Lead ld : leads) {
            Country__c country = countriesByName.get(ld.Country);
            ld.CountryCapital__c = country != null ? country.CapitalCity__c : null;
            ld.CountryRegion__c = country != null ? country.Region__c : null;
            ld.CountryAlpha2Code__c = country != null ? country.Alpha2Code__c : null;
            ld.CountryAlpha3Code__c = country != null ? country.Alpha3Code__c : null;
        }
    }
}