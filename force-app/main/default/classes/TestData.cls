@isTest
public class TestData {

    private static final List<String> LETTERS = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ').split('');

    public static List<Country__c> createCountryRecords(Integer recordCount) {
        List<Country__c> countries = new List<Country__c>();

        for(Integer i = 0; i < recordCount; i++) {
            countries.add(new Country__c(
                Name__c = 'Test Country ' + i,
                Alpha2Code__c = LETTERS[i] + LETTERS[i + 1],
                Alpha3Code__c = LETTERS[i] + LETTERS[i + 1] + LETTERS[i + 2],
                CapitalCity__c = 'Capital ' + i,
                Region__c = 'Test Region ' + i
            ));
        }

        return countries;
    }

    public static List<Country__c> insertCountryRecords(Integer recordCount) {
        List<Country__c> countries = createCountryRecords(recordCount);
        insert countries;
        return countries;
    }

    public static Map<String, Country__c> createCountryRecordsByNameMap(Integer recordCount) {
        Map<String, Country__c> countriesByName = new Map<String, Country__c>();

        for(Country__c country : createCountryRecords(recordCount)) {
            countriesByName.put(country.Name__c, country);
        }

        return countriesByName;
    }

    public static Map<String, CountryLayerService.ApiCountry> createApiCountriesByNameMap(Integer recordCount) {
        Map<String, CountryLayerService.ApiCountry> countriesByName = new Map<String, CountryLayerService.ApiCountry>();

        for(Integer i = 0; i < recordCount; i++) {
            CountryLayerService.ApiCountry country = new CountryLayerService.ApiCountry();
            country.name = 'Test Country ' + i;
            country.alpha2Code = LETTERS[i] + LETTERS[i + 1];
            country.alpha3Code = LETTERS[i] + LETTERS[i + 1] + LETTERS[i + 2];
            country.capital = 'Capital ' + i;
            country.region = 'Test Region ' + i;
            countriesByName.put(country.name, country);
        }

        return countriesByName;
    }

    public static String mockApiResponseBody(Integer countryCount) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();

        for(Integer i = 0; i < countryCount; i++) {
            gen.writeStartObject();
            gen.writeStringField('name', 'Test Country ' + i);
            gen.writeStringField('alpha2Code', LETTERS[i] + LETTERS[i + 1]);
            gen.writeStringField('alpha3Code', LETTERS[i] + LETTERS[i + 1] + LETTERS[i + 2]);
            gen.writeStringField('capital', 'Capital ' + i);
            gen.writeStringField('region', 'Test Region ' + i);
            gen.writeEndObject();
        }

        gen.writeEndArray();
        return gen.getAsString();
    }

    public class MockHttpResponse implements HttpCalloutMock {
        private String mockResponse;

        public MockHttpResponse(String mockResponse) {
            this.mockResponse = mockResponse;
        }

        public HttpResponse respond(HttpRequest req) {
            System.assert(req.getEndpoint().startsWith('http://api.countrylayer.com/all'));
            System.assertEquals('GET', req.getMethod());
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }
}