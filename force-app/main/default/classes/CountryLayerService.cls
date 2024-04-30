public with sharing class CountryLayerService {

    /**
     * Fetches all the Country__c records in the org
     * @return List of all Country__c records
     */
    public static Map<String, Country__c> getCountriesByName() {
        Map<String, Country__c> existingCountriesByName = new Map<String, Country__c>();
        
        try {
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
                existingCountriesByName.put(country.Name__c, country);
            }
        }
        catch(Exception ex) {
            // call log service
            throw new CustomException(ex.getMessage());
        }

        return existingCountriesByName;
    }

    /**
     * Calls CountryLayer API and deserialises reponse
     * into ApiCountry wrapper object
     * @return Deserialised API response 
     */
    public static Map<String, ApiCountry> getDeserializedApiResponse() {
        Map<String, ApiCountry> apiCountriesByName = new Map<String, ApiCountry>();
        CountryLayerAPI__c apiSettings = CountryLayerAPI__c.getInstance();
        
        if(apiSettings == null || String.isBlank(apiSettings.AccessKey__c)) {
            throw new CustomException('Missing access key in settings.');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://api.countrylayer.com/v2/all?access_key=' + apiSettings.AccessKey__c);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res;

        try {
            res = http.send(req);
        }
        catch(Exception ex) {
            // call log service
            throw new CustomException(ex.getMessage());
        }

        if(res.getStatusCode() != 200 || String.isBlank(res.getBody())) {
            throw new CustomException(res);
        }

        try {
            List<ApiCountry> countries = (List<ApiCountry>)JSON.deserialize(res.getBody(), List<ApiCountry>.class);
            for(ApiCountry country : countries) {
                apiCountriesByName.put(country.name, country);
            }
        }
        catch(Exception ex) {
            // call log service
            throw new CustomException(ex.getMessage());
        }

        return apiCountriesByName;
    }

    /**
     * Deletes Country__c records that don't have a match
     * in the API response
     * @param existingCountriesByName Country__c records mapped by Name__c
     * @param apiCountriesByName API response countries mapped by name
     */
    public static void deleteObsoleteCountries(
        Map<String, Country__c> existingCountriesByName,
        Map<String, ApiCountry> apiCountriesByName
    ) {
        List<Country__c> countriesToDelete = new List<Country__c>();
        Set<String> existingCountryNamesNotInApi = new Set<String>(existingCountriesByName.keySet());
        existingCountryNamesNotInApi.removeAll(apiCountriesByName.keySet());

        for(String name : existingCountryNamesNotInApi) {
            countriesToDelete.add(existingCountriesByName.get(name));
        }

        Database.DeleteResult[] results = Database.delete(countriesToDelete, false);
        List<Database.Error> errors = new List<Database.Error>();
        for(Database.DeleteResult dr : results) {
            errors.addAll(dr.getErrors());
        }
        if(!errors.isEmpty()) {
            throw new CustomException(errors);
        }
    }
	
    /**
     * Updates Country__c records that are not up to date
     * with the API response and inserts new ones if found
     * @param existingCountriesByName Country__c records mapped by Name__c
     * @param apiCountriesByName API response countries mapped by name
     */
    public static void upsertCountries(
        Map<String, Country__c> existingCountriesByName,
        Map<String, ApiCountry> apiCountriesByName
    ) {
        List<Country__c> countriesToUpsert = new List<Country__c>();

        for(ApiCountry country : apiCountriesByName.values()) {
            Country__c record = existingCountriesByName.get(country.name);
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
                countriesToUpsert.add(record);
            }
        }

        List<Database.UpsertResult> results = Database.upsert(countriesToUpsert, false);
        List<Database.Error> errors = new List<Database.Error>();
        for(Database.UpsertResult ur : results) {
            errors.addAll(ur.getErrors());
        }
        if(!errors.isEmpty()) {
            throw new CustomException(errors);
        }
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

    
    /**
     * Wrapper objects for API error response
     */
    public class ApiError {
        public ApiErrorInfo error;
    }

    public class ApiErrorInfo {
        public String info;
    }
}