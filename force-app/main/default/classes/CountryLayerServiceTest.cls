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
            'CDE',
            countriesByName.get('Test Country 2').Alpha3Code__c,
            'The alpha3Code is not correct for country 2'
        );
        System.assertEquals(
            'Test Region 9',
            countriesByName.get('Test Country 9').Alpha3Code__c,
            'The region is not correct for country 9'
        );
    }

    @isTest
    private static void getDeserializedApiResponse() {
        String mockResponse = TestData.mockApiResponseBody(10);
        Test.setMock(HttpCalloutMock.class, new TestData.MockHttpResponse(mockResponse));

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        Map<String, CountryLayerService.ApiCountry> countriesByName = service.getDeserializedApiResponse();
        Test.stopTest();

        System.assertEquals(10, countriesByName.size(), 'The country list size is not correct');
        System.assertEquals(
            'CDE',
            countriesByName.get('Test Country 2').alpha3Code,
            'The alpha3Code is not correct for country 2'
        );
        System.assertEquals(
            'Test Region 9',
            countriesByName.get('Test Country 9').alpha3Code,
            'The region is not correct for country 9'
        );
    }

    @isTest
    private static void deleteObsoleteCountries() {
        Map<String, Country__c> testCountryRecordsByName = TestData.createCountryRecordsByNameMap(10);
        Map<String, CountryLayerService.ApiCountry> testApiCountriesByName =
            TestData.createApiCountriesByNameMap(7);

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        service.deleteObsoleteCountries(testCountryRecordsByName, testApiCountriesByName);
        Test.stopTest();

        List<Country__c> countries = [SELECT Name__c FROM Country__c ORDER BY Name__c DESC];
        System.assertEquals(7, countries.size(), 'The remaining country list size is not correct');
        System.assertEquals('Test Country 6', countries[0].Name__c, 'First country in DESC order is not correct');
    }

    @isTest
    private static void updateCountries() {
        Map<String, Country__c> testCountryRecordsByName = TestData.createCountryRecordsByNameMap(10);
        Map<String, CountryLayerService.ApiCountry> testApiCountriesByName =
            TestData.createApiCountriesByNameMap(11);
        testApiCountriesByName.get('Test Country 2').alpha3Code = 'ZZZ';
        testApiCountriesByName.get('Test Country 9').region = 'Europe';

        Test.startTest();
        CountryLayerService service = new CountryLayerService();
        service.updateCountries(testCountryRecordsByName, testApiCountriesByName);
        Test.stopTest();

        List<Country__c> countries = [SELECT Name__c FROM Country__c ORDER BY Name__c ASC];
        System.assertEquals(11, countries.size(), 'The new country list size is not correct');
        System.assertEquals('ZZZ', countries[2].Name__c, 'Alpha3code for country 3 not correct');
        System.assertEquals('Europe', countries[9].Name__c, 'Region for country 9 not correct');
        System.assertEquals('Test Country 10', countries[10].Name__c, 'Name for country 10 not correct');
    }
}