@isTest
private class CountryLayerServiceTest {
    
    @isTest
    private static void getCountriesByName() {
        List<Country__c> testCountries = TestData.insertCountryRecords(10);

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        Map<String, Country__c> countriesByName = service.getCountriesByName();
        Test.stopTest();

        System.assertEquals(10, countriesByName.size(), 'The country list size is not correct');
        System.assertEquals(
            'CD',
            countriesByName.get('Test Country CDE').Alpha2Code__c,
            'The alpha2Code is not correct for country CDE'
        );
        System.assertEquals(
            'Test Region JKL',
            countriesByName.get('Test Country JKL').Region__c,
            'The region is not correct for country JKL'
        );
    }

    @isTest
    private static void getCountriesByName_NoData() {
        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        Map<String, Country__c> countriesByName = service.getCountriesByName();
        Test.stopTest();

        System.assert(countriesByName.isEmpty(), 'The country map size is not correct');
    }

    @isTest
    private static void getCountriesByName_NoAccess() {
        Exception ex;
        User testUser = TestData.createUsers(1, 'Chatter Free User')[0];

        Test.startTest();
        try {
            System.runAs(testUser) {
                CountryLayerService service = new CountryLayerService();
                Map<String, Country__c> countriesByName = service.getCountriesByName();
            }
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        
        System.assertEquals('System.QueryException', ex.getTypeName(), 'Exception type incorrect');
    }

    @isTest
    private static void getDeserializedApiResponse() {
        CountryLayerAPI__c settings = TestData.insertApiSettings();
        String mockResponse = TestData.mockApiResponseBody(10);
        Test.setMock(HttpCalloutMock.class, new TestData.MockHttpResponse(mockResponse, 200));

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        Map<String, CountryLayerService.ApiCountry> countriesByName = service.getDeserializedApiResponse();
        Test.stopTest();

        System.assertEquals(10, countriesByName.size(), 'The country list size is not correct');
        System.assertEquals(
            'CD',
            countriesByName.get('Test Country CDE').alpha2Code,
            'The alpha3Code is not correct for country CDE'
        );
        System.assertEquals(
            'Test Region JKL',
            countriesByName.get('Test Country JKL').region,
            'The region is not correct for country JKL'
        );
    }

    @isTest
    private static void getDeserializedApiResponse_ApiError() {
        Exception ex;
        CountryLayerAPI__c settings = TestData.insertApiSettings();
        String mockResponse = TestData.mockApiErrorResponseBody();
        Test.setMock(HttpCalloutMock.class, new TestData.MockHttpResponse(mockResponse, 400));

        Test.startTest();
        try {
            CountryLayerService service = new CountryLayerService();
            Map<String, CountryLayerService.ApiCountry> countriesByName = service.getDeserializedApiResponse();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(
            'API status 400: You have not supplied some info',
            ex.getMessage(),
            'Exception message incorrect'
        );
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }

    @isTest
    private static void getDeserializedApiResponse_ApiNoBody() {
        Exception ex;
        CountryLayerAPI__c settings = TestData.insertApiSettings();
        Test.setMock(HttpCalloutMock.class, new TestData.MockHttpResponse('', 200));

        Test.startTest();
        try {
            CountryLayerService service = new CountryLayerService();
            Map<String, CountryLayerService.ApiCountry> countriesByName = service.getDeserializedApiResponse();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(
            'API status 200: An unexpected error occurred',
            ex.getMessage(),
            'Exception message incorrect'
        );
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }

    @isTest
    private static void getDeserializedApiResponse_ApiInvalidBody() {
        Exception ex;
        CountryLayerAPI__c settings = TestData.insertApiSettings();
        Test.setMock(HttpCalloutMock.class, new TestData.MockHttpResponse('[[{"test":"invalid"}]]', 200));

        Test.startTest();
        try {
            CountryLayerService service = new CountryLayerService();
            Map<String, CountryLayerService.ApiCountry> countriesByName = service.getDeserializedApiResponse();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(
            'API status 200: An unexpected error occurred',
            ex.getMessage(),
            'Exception message incorrect'
        );
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }

    @isTest
    private static void getDeserializedApiResponse_SettingsError() {
        Exception ex;

        Test.startTest();
        try {
            CountryLayerService service = new CountryLayerService();
            Map<String, CountryLayerService.ApiCountry> countriesByName = service.getDeserializedApiResponse();
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();

        System.assertEquals(
            'Missing access key in settings.',
            ex.getMessage(),
            'Exception message incorrect'
        );
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }

    @isTest
    private static void deleteObsoleteCountries() {
        Map<String, Country__c> testCountryRecordsByName = TestData.insertCountryRecordsByNameMap(10);
        Map<String, CountryLayerService.ApiCountry> testApiCountriesByName =
            TestData.createApiCountriesByNameMap(7);

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        service.deleteObsoleteCountries(testCountryRecordsByName, testApiCountriesByName);
        Test.stopTest();

        List<Country__c> countries = [SELECT Name__c FROM Country__c ORDER BY Name__c DESC];
        System.assertEquals(7, countries.size(), 'The remaining country list size is not correct');
        System.assertEquals(
            'Test Country GHI',
            countries[0].Name__c,
            'First country in DESC order is not correct'
        );
    }

    @isTest
    private static void deleteObsoleteCountries_NoAccess() {
        Exception ex;
        User testUser = TestData.createUsers(1, 'Chatter Free User')[0];
        Map<String, Country__c> testCountryRecordsByName = TestData.insertCountryRecordsByNameMap(2);
        Map<String, CountryLayerService.ApiCountry> testApiCountriesByName =
            TestData.createApiCountriesByNameMap(1);

        Test.startTest();
        try {
            System.runAs(testUser) {
                CountryLayerService service = new CountryLayerService();
                service.deleteObsoleteCountries(testCountryRecordsByName, testApiCountriesByName);
            }
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }

    @isTest
    private static void upsertCountries() {
        Map<String, Country__c> testCountryRecordsByName = TestData.insertCountryRecordsByNameMap(10);
        Map<String, CountryLayerService.ApiCountry> testApiCountriesByName =
            TestData.createApiCountriesByNameMap(11);
        testApiCountriesByName.get('Test Country CDE').alpha2Code = 'ZZ';
        testApiCountriesByName.get('Test Country JKL').region = 'Europe';

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        service.upsertCountries(testCountryRecordsByName, testApiCountriesByName);
        Test.stopTest();

        List<Country__c> countries = [SELECT Name__c, Region__c, Alpha2Code__c FROM Country__c ORDER BY Name__c ASC];
        System.assertEquals(11, countries.size(), 'The new country list size is not correct');
        System.assertEquals('ZZ', countries[2].Alpha2Code__c, 'Alpha2code for country CDE not correct');
        System.assertEquals('Europe', countries[9].Region__c, 'Region for country JKL not correct');
        System.assertEquals('Test Country KLM', countries[10].Name__c, 'Name for country KLM not correct');
    }

    @isTest
    private static void insertCountries() {
        Map<String, CountryLayerService.ApiCountry> testApiCountriesByName =
            TestData.createApiCountriesByNameMap(10);

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        service.upsertCountries(new Map<String, Country__c>(), testApiCountriesByName);
        Test.stopTest();

        List<Country__c> countries = [SELECT Region__c, Alpha2Code__c FROM Country__c ORDER BY Name__c ASC];
        System.assertEquals(10, countries.size(), 'The new country list size is not correct');
        System.assertEquals('CD', countries[2].Alpha2Code__c, 'Alpha2code for country CDE not correct');
        System.assertEquals('Test Region JKL', countries[9].Region__c, 'Region for country JKL not correct');
    }

    @isTest
    private static void insertCountries_NoAccess() {
        Exception ex;
        User testUser = TestData.createUsers(1, 'Chatter Free User')[0];
        Map<String, CountryLayerService.ApiCountry> testApiCountriesByName =
            TestData.createApiCountriesByNameMap(1);

        Test.startTest();
        try {
            System.runAs(testUser) {
                CountryLayerService service = new CountryLayerService();
                service.upsertCountries(new Map<String, Country__c>(), testApiCountriesByName);
            }
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }
}