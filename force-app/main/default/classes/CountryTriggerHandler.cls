public with sharing class CountryTriggerHandler {
    
    /**
     * After insert trigger handler
     * @param newCountries List of newly inserted Country__c records
     */
    public static void afterInsert(List<Country__c> newCountries) {
        Map<String, Country__c> countriesByName = getCountriesByNames(newCountries);
        List<Lead> leadsToUpdate = getLeadsByCountries(countriesByName.keySet());
        updateLeadCountryInfo(leadsToUpdate, countriesByName);
    }

    /**
     * After update trigger handler
     * @param oldCountryMap Map with old versions of newly updated Country__c records, by ID
     * @param newCountryMap Map of newly updated Country__c records, by ID
     */
    public static void afterUpdate(Map<Id, Country__c> oldCountryMap, Map<Id, Country__c> newCountryMap) {
        Map<String, Country__c> countriesByName = new Map<String, Country__c>();

        for(Country__c country : newCountryMap.values()) {
            if(
                oldCountryMap.get(country.Id).CapitalCity__c != country.CapitalCity__c ||
                oldCountryMap.get(country.Id).Region__c != country.Region__c ||
                oldCountryMap.get(country.Id).Alpha2Code__c != country.Alpha2Code__c ||
                oldCountryMap.get(country.Id).Alpha3Code__c != country.Alpha3Code__c
            ) {
                countriesByName.put(country.Name__c, country);
            }
        }

        List<Lead> leadsToUpdate = getLeadsByCountries(countriesByName.keySet());
        updateLeadCountryInfo(leadsToUpdate, countriesByName);
    }

    /**
     * After delete trigger handler
     * @param oldCountries List of newly deleted Country__c records
     */
    public static void afterDelete(List<Country__c> oldCountries) {
        Map<String, Country__c> countriesByName = getCountriesByNames(oldCountries);
        List<Lead> leadsToUpdate = getLeadsByCountries(countriesByName.keySet());
        removeLeadCountryInfo(leadsToUpdate);
    }

    /**
     * After undelete trigger handler
     * @param newCountries List of newly restored Country__c records
     */
    public static void afterUndelete(List<Country__c> newCountries) {
        Map<String, Country__c> countriesByName = getCountriesByNames(newCountries);
        List<Lead> leadsToUpdate = getLeadsByCountries(countriesByName.keySet());
        updateLeadCountryInfo(leadsToUpdate, countriesByName);
    }

    /**
     * Generates map of Country__c records grouped by Name__c from given list
     * @param countries List of Country__c records
     * @return Map of Country__c records, by Name__c
     */
    @TestVisible
    private static Map<String, Country__c> getCountriesByNames(List<Country__c> countries) {
        Map<String, Country__c> countriesByNames = new Map<String, Country__c>();

        for(Country__c country : countries) {
            countriesByNames.put(country.Name__c, country);
        }

        return countriesByNames;
    }

    /**
     * Fetches Lead records with Country field value in given set
     * @param countryNames Set of country names
     * @return List of Lead records with given countries
     */
    @TestVisible
    private static List<Lead> getLeadsByCountries(Set<String> countryNames) {
        try {
            return [
                SELECT
                    Country,
                    CountryCapital__c,
                    CountryRegion__c,
                    CountryAlpha2Code__c,
                    CountryAlpha3Code__c
                FROM Lead
                WHERE Country IN :countryNames
                WITH SECURITY_ENFORCED
            ];
        }
        catch(Exception ex) {
            // call log service
            throw new CustomException(ex.getMessage());
        }
    }

    /**
     * Updates Lead country info based on given Country__c record data
     * @param leads List of Lead records to update
     * @param countriesByName Countries with freshly updated data, grouped by Name__c
     */
    @TestVisible
    private static void updateLeadCountryInfo(List<Lead> leads, Map<String, Country__c> countriesByName) {
        for(Lead lead : leads) {
            Country__c country = countriesByName.get(Lead.Country);
            
            if(Lead.CountryCapital__c != country.CapitalCity__c) {
                Lead.CountryCapital__c = country.CapitalCity__c;
            }

            if(Lead.CountryRegion__c != country.Region__c) {
                Lead.CountryRegion__c = country.Region__c;
            }

            if(Lead.CountryAlpha2Code__c != country.Alpha2Code__c) {
                Lead.CountryAlpha2Code__c = country.Alpha2Code__c;
            }

            if(Lead.CountryAlpha3Code__c != country.Alpha3Code__c) {
                Lead.CountryAlpha3Code__c = country.Alpha3Code__c;
            }
        }

        Database.SaveResult[] results = Database.update(leads, false);
        List<Database.Error> errors = new List<Database.Error>();
        for(Database.SaveResult sr : results) {
            errors.addAll(sr.getErrors());
        }
        if(!errors.isEmpty()) {
            throw new CustomException(errors);
        }
    }

    /**
     * Empties Lead country info fields
     * @param leads List of Lead records to update
     */
    @TestVisible
    private static void removeLeadCountryInfo(List<Lead> leads) {
        for(Lead lead : leads) {            
            Lead.CountryCapital__c = null;
            Lead.CountryRegion__c = null;
            Lead.CountryAlpha2Code__c = null;
            Lead.CountryAlpha3Code__c = null;
        }

        Database.SaveResult[] results = Database.update(leads, false);
        List<Database.Error> errors = new List<Database.Error>();
        for(Database.SaveResult sr : results) {
            errors.addAll(sr.getErrors());
        }
        if(!errors.isEmpty()) {
            throw new CustomException(errors);
        }
    }
}