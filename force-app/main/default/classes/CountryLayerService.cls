public with sharing class CountryLayerService {

    // existing Country__c records in the org
    private Map<String, Country__c> existingCountriesByName = new Map<String, Country__c>();

    // deserialised API response
    private Map<String, ApiCountry> apiCountriesByName = new Map<String, ApiCountry>();

    // collects list of Country__c records to insert/update
    private List<Country__c> countriesToUpsert = new List<Country__c>();

    // collects list of Country__c records to delete
    private List<Country__c> countriesToDelete = new List<Country__c>();

    /**
     * Fetches all the Country__c records in the org
     */
    private void getCountriesByName() {
        List<Country__c> countries = [
            SELECT 
                Name__c,
                Alpha2Code__c,
                Alpha3Code__c,
                CapitalCity__c,
                Region__c
            FROM Country__c
            WITH SECURITY_ENFORCED
        ];
        for(Country__c country : countries) {
            this.existingCountriesByName.put(country.Name__c, country);
        }
    }

    /**
     * Calls CountryLayer API and deserialises reponse
     * into ApiCountry wrapper object
     */
    private void getDeserializedApiResponse() {
        CountryLayerAPI__c apiSettings = CountryLayerAPI__c.getInstance();
        // if no settings ==> error
        String apiKey = apiSettings.AccessKey__c;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://api.countrylayer.com/v2/all?access_key=' + apiKey);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);

        List<ApiCountry> countries = (List<ApiCountry>)JSON.deserialize(res.getBody(), List<ApiCountry>.class);
        for(ApiCountry country : countries) {
            this.apiCountriesByName.put(country.name, country);
        }
    }
	
    /**
     * Compares existing Country__c record content with the API response
     * and collects records to delete/upsert accordingly
     */
    private void checkCountryUpdates() {
        Set<String> existingCountryNamesNotInApi = new Set<String>(this.existingCountriesByName.keySet());
        existingCountryNamesNotInApi.removeAll(this.apiCountriesByName.keySet());

        for(String name : existingCountryNamesNotInApi) {
            this.countriesToDelete.add(this.existingCountriesByName.get(name));
        }

        for(ApiCountry country : this.apiCountriesByName.values()) {
            Country__c record = this.existingCountriesByName.get(country.name);
            Boolean isRecordChanged = false;

            if(record == null) {
                record = new Country__c(Name__c = country.name);
                isRecordChanged = true;
            }

            if(record.Alpha2Code__c != country.alpha2Code) {
                record.Alpha2Code__c = country.alpha2Code;
                isRecordChanged = true;
            }

            if(record.Alpha3Code__c != country.alpha3Code) {
                record.Alpha3Code__c = country.alpha3Code;
                isRecordChanged = true;
            }

            if(record.CapitalCity__c != country.capital) {
                record.CapitalCity__c = country.capital;
                isRecordChanged = true;
            }

            if(record.Region__c != country.region) {
                record.Region__c = country.region;
                isRecordChanged = true;
            }

            if(isRecordChanged) {
                this.countriesToUpsert.add(record);
            }
        }
    }

    /**
     * Collects all data and executes updates.
     * Callable from CountryLayerScheduler
     */
    public void executeUpdates() {
        this.getCountriesByName();
        this.getDeserializedApiResponse();
        this.checkCountryUpdates();

        // FIXME: check crud etc
        delete this.countriesToDelete;
        upsert this.countriesToUpsert;    
    }

    /**
     * Wrapper object for API response
     */
    public class ApiCountry {
        public String name;
        public String alpha2Code;
        public String alpha3Code;
        public String capital;
        public String region;
    }
}