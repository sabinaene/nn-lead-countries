@isTest
public class TestData {

    private static final List<String> LETTERS = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ').split('');

    /**
     * Generates a 3-letter country code based on the given
     * record/entry sequence; Example: country #0 has code ABC,
     * country #1 has code BCD, etc.
     * @param index Country sequence within collection
     * @return Alpha 3 code
     */
    private static String generateAlpha3Code(Integer index) {
        Integer letterIndex = Math.mod(index, LETTERS.size() - 1);
        return LETTERS[letterIndex] + LETTERS[letterIndex + 1] + LETTERS[letterIndex + 2];
    }

    /**
     * Generates a list of Country__c records without inserting
     * @param recordCount Number of records to generate
     * @return List of Country__c records
     */
    public static List<Country__c> createCountryRecords(Integer recordCount) {
        List<Country__c> countries = new List<Country__c>();

        for(Integer i = 0; i < recordCount; i++) {
            String alpha3Code = generateAlpha3Code(i);
            
            countries.add(new Country__c(
                Name__c = 'Test Country ' + alpha3Code,
                Alpha2Code__c = alpha3Code.substring(0, 2),
                Alpha3Code__c = alpha3Code,
                CapitalCity__c = 'Capital ' + alpha3Code,
                Region__c = 'Test Region ' + alpha3Code
            ));
        }

        return countries;
    }

    /**
     * Creates and inserts a list of Country__c records
     * @param recordCount Number of records to create
     * @return List of Country__c records after insert
     */
    public static List<Country__c> insertCountryRecords(Integer recordCount) {
        List<Country__c> countries = createCountryRecords(recordCount);
        insert countries;
        return countries;
    }

    /**
     * Generates a map of Country__c records without inserting
     * @param recordCount Number of records to generate
     * @return Map of Country__c records grouped by Name__c
     */
    public static Map<String, Country__c> createCountryRecordsByNameMap(Integer recordCount) {
        Map<String, Country__c> countriesByName = new Map<String, Country__c>();

        for(Country__c country : createCountryRecords(recordCount)) {
            countriesByName.put(country.Name__c, country);
        }

        return countriesByName;
    }

    /**
     * Insert Country__c records an returns map by name
     * @param recordCount Number of records to insert
     * @return Map of Country__c records grouped by Name__c
     */
    public static Map<String, Country__c> insertCountryRecordsByNameMap(Integer recordCount) {
        Map<String, Country__c> countriesByName = createCountryRecordsByNameMap(recordCount);
        insert countriesByName.values();
        return countriesByName;
    }

    /**
     * Generates a map of country entries in CountryLayer API format
     * @param entryCount Number of entries to generate
     * @return Map of country entries grouped by name
     */
    public static Map<String, CountryLayerService.ApiCountry> createApiCountriesByNameMap(Integer entryCount) {
        Map<String, CountryLayerService.ApiCountry> countriesByName = new Map<String, CountryLayerService.ApiCountry>();

        for(Integer i = 0; i < entryCount; i++) {
            String alpha3Code = generateAlpha3Code(i);
            CountryLayerService.ApiCountry country = new CountryLayerService.ApiCountry();
            country.name = 'Test Country ' + alpha3Code;
            country.alpha2Code = alpha3Code.substring(0, 2);
            country.alpha3Code = alpha3Code;
            country.capital = 'Capital ' + alpha3Code;
            country.region = 'Test Region ' + alpha3Code;
            countriesByName.put(country.name, country);
        }

        return countriesByName;
    }

    /**
     * Creates a list of Lead records without inserting
     * @param recordCount Number of records to create
     * @param countryName Country name for Lead
     * @return List of Lead records
     */
    public static List<Lead> createLeadRecords(Integer recordCount, String countryName) {
        List<Lead> leads = new List<Lead>();

        for(Integer i = 0; i < recordCount; i++) {
            leads.add(new Lead(
                FirstName = 'Test ' + i,
                LastName = 'Lead ' + i,
                Company = 'Company ' + i,
                Country = countryName
            ));
        }

        return leads;
    }

    /**
     * Creates and inserts a list of Lead records
     * @param recordCount Number of records to create
     * @param countryName Country name for Lead
     * @return List of Lead records after insert
     */
    public static List<Lead> insertLeadRecords(Integer recordCount, String countryName) {
        List<Lead> leads = createLeadRecords(recordCount, countryName);
        insert leads;
        return leads;
    }

    /**
     * Generates CountryLayerAPI__c custom settings without inserting
     * @return CountryLayerAPI__c custom settings instance
     */
    public static CountryLayerAPI__c createApiSettings() {
        return new CountryLayerAPI__c(
            SetupOwnerId = UserInfo.getUserId(),
            Name = 'Test Settings',
            AccessKey__c = '1234567'
        );
    }

    /**
     * Inserts CountryLayerAPI__c custom settings instance
     * @return CountryLayerAPI__c custom settings after insert
     */
    public static CountryLayerAPI__c insertApiSettings() {
        CountryLayerAPI__c settings = createApiSettings();
        insert settings;
        return settings;
    }

    /**
     * Generates GeneralSettings__c custom settings without inserting
     * @return GeneralSettings__c custom settings instance
     */
    public static GeneralSettings__c createGeneralSettings() {
        return new GeneralSettings__c(
            SetupOwnerId = UserInfo.getUserId(),
            Name = 'Test Settings',
            DisableAutomation__c = true
        );
    }

    /**
     * Inserts GeneralSettings__c custom settings instance
     * @return GeneralSettings__c custom settings after insert
     */
    public static GeneralSettings__c insertGeneralSettings() {
        GeneralSettings__c settings = createGeneralSettings();
        insert settings;
        return settings;
    }

    /**
     * Creates User records without inserting
     * @param userCount Number of users to create
     * @param profileName Name of profile to assign to users
     * @return List of users
     */
    public static List<User> createUsers(Integer userCount, String profileName) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        List<User> users = new List<User>();

        for(Integer i = 0; i < userCount; i++) {
            Integer uniqueId = Integer.valueOf(Math.random() * 100000000);
            users.add(new User(
                Alias = String.valueOf(uniqueId),
                Email = uniqueId + '@example.com',
                EmailEncodingKey = 'UTF-8',
                FirstName = 'Test ' + i,
                LastName = 'User ' + i,
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profileId,
                TimeZoneSidKey = 'America/New_York',
                Username = 'test-' + uniqueId + '@example.com'
            ));
        }
        return users;
    }

    /**
     * Inserts User records
     * @param userCount Number of users to create
     * @param profileName Name of profile to assign to users
     * @return List of users after insert
     */
    public static List<User> insertUsers(Integer userCount, String profileName) {
        List<User> users = createUsers(userCount, profileName);
        insert users;
        return users;
    }

    /**
     * Assigns permission set to users
     * @param userIds List of users IDs to assign perm set to
     * @param permissionSetName Name of perm set to assign
     */
    public static void assignPermissionSet(List<Id> userIds, String permissionSetName) {
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName].Id;
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

        for(Id userId : userIds) {
            assignments.add(new PermissionSetAssignment(
                AssigneeId = userId,
                PermissionSetId = permissionSetId
            ));
        }

        insert assignments;
    }

    /**
     * Generates a mock CountryLayer API response
     * @param entryCount Number of country entries to generate
     * @return Mock response as string
     */
    public static String mockApiResponseBody(Integer entryCount) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();

        for(Integer i = 0; i < entryCount; i++) {
            String alpha3Code = generateAlpha3Code(i);

            gen.writeStartObject();
            gen.writeStringField('name', 'Test Country ' + alpha3Code);
            gen.writeStringField('alpha2Code', alpha3Code.substring(0, 2));
            gen.writeStringField('alpha3Code', alpha3Code);
            gen.writeStringField('capital', 'Capital ' + alpha3Code);
            gen.writeStringField('region', 'Test Region ' + alpha3Code);
            gen.writeEndObject();
        }

        gen.writeEndArray();
        return gen.getAsString();
    }

    /**
     * Generates a mock CountryLayer API error response
     * @return Mock error response as string
     */
    public static String mockApiErrorResponseBody() {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeBooleanField('status', false);
        gen.writeFieldName('error');
        gen.writeStartObject();
        gen.writeNumberField('code', 123);
        gen.writeStringField('type', 'missing_some_info');
        gen.writeStringField('info', 'You have not supplied some info');
        gen.writeEndObject();
        gen.writeEndObject();
        return gen.getAsString();
    }

    /**
     * Mock class to generate a fake API response when
     * CountryLayer API is called from tests
     */
    public class MockHttpResponse implements HttpCalloutMock {
        private String mockResponse;
        private Integer mockStatus;

        public MockHttpResponse(String mockResponse, Integer mockStatus) {
            this.mockResponse = mockResponse;
            this.mockStatus = mockStatus;
        }

        public HttpResponse respond(HttpRequest req) {
            System.assertEquals(
                'http://api.countrylayer.com/v2/all?access_key=1234567',
                req.getEndpoint(),
                'API endpoint is not correct'
            );
            System.assertEquals('GET', req.getMethod(), 'API method is not correct');
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.mockResponse);
            res.setStatusCode(this.mockStatus);
            return res;
        }
    }
}