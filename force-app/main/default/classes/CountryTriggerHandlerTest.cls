@isTest
private class CountryTriggerHandlerTest {

    /**
     * Checks that Country__c records are grouped correctly by names
     */
    @isTest
    private static void getCountriesByNames() {
        List<Country__c> testCountries = TestData.createCountryRecords(3);

        Test.startTest();
        Map<String, Country__c> countriesByName = CountryTriggerHandler.getCountriesByNames(testCountries);
        Test.stopTest();

        System.assertEquals(
            testCountries[0],
            countriesByName.get('Test Country ABC'),
            'Test Country ABC not mapped'
        );
        System.assertEquals(
            testCountries[1],
            countriesByName.get('Test Country BCD'),
            'Test Country BCD not mapped'
        );
        System.assertEquals(
            testCountries[2],
            countriesByName.get('Test Country CDE'),
            'Test Country CDE not mapped'
        );
    }
    
    /**
     * Checks that Lead records are fetched correctly by country names
     */
    @isTest
    private static void getLeadsByCountries() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        List<Country__c> testCountries = TestData.insertCountryRecords(2);
        List<Lead> testLeads = TestData.insertLeadRecords(3, testCountries[0].Name__c);
        testLeads.addAll(TestData.insertLeadRecords(2, testCountries[1].Name__c));
        testLeads.addAll(TestData.insertLeadRecords(2, 'Random Country'));

        Test.startTest();
        List<Lead> leads = CountryTriggerHandler.getLeadsByCountries(new Set<String>{
            testCountries[0].Name__c,
            testCountries[1].Name__c
        });
        Test.stopTest();

        System.assertEquals(5, leads.size(), 'The Lead list size is not correct');
    }

    /**
     * Checks that an exception is thrown when a user without
     * access to Lead records is running the query
     */
    @isTest
    private static void getLeadsByCountries_NoAccess() {
        Exception ex;
        User testUser = TestData.createUsers(1, 'Chatter External User')[0];

        Test.startTest();
        try {
            System.runAs(testUser) {
                List<Lead> leads = CountryTriggerHandler.getLeadsByCountries(new Set<String>{
                    'Random Country'
                });
            }
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }

    /**
     * Checks that Lead records are updated correctly with country info
     */
    @isTest
    private static void updateLeadCountryInfo() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.insertCountryRecordsByNameMap(2);
        List<Lead> testLeads = TestData.createLeadRecords(3, testCountries.values()[0].Name__c);
        testLeads.addAll(TestData.createLeadRecords(2, testCountries.values()[1].Name__c));
        testLeads[1].CountryCapital__c = 'Random Capital';
        testLeads[4].CountryAlpha3Code__c = 'RCD';
        insert testLeads;

        Test.startTest();
        CountryTriggerHandler.updateLeadCountryInfo(testLeads, testCountries);
        Test.stopTest();

        List<Lead> leads = [SELECT CountryCapital__c, CountryAlpha3Code__c, Country FROM Lead];
        for(Lead lead : leads) {
            System.assertEquals(
                testCountries.get(lead.Country).CapitalCity__c,
                lead.CountryCapital__c,
                'Capital on Lead not correct'
            );
            System.assertEquals(
                testCountries.get(lead.Country).Alpha3Code__c,
                lead.CountryAlpha3Code__c,
                'Alpha3Code on Lead not correct'
            );
        }
    }

    /**
     * Checks that an exception is thrown if a user without rights
     * to update Lead records is trying to update
     */
    @isTest
    private static void updateLeadCountryInfo_NoAccess() {
        Exception ex;
        User testUser = TestData.createUsers(1, 'Chatter External User')[0];
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.insertCountryRecordsByNameMap(1);
        List<Lead> testLeads = TestData.createLeadRecords(2, testCountries.values()[0].Name__c);
        testLeads[0].CountryCapital__c = 'Random Capital';
        testLeads[1].CountryAlpha3Code__c = 'RCD';
        insert testLeads;

        Test.startTest();
        try {
            System.runAs(testUser) {
                CountryTriggerHandler.updateLeadCountryInfo(testLeads, testCountries);
            }
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }
    
    /**
     * Checks that Lead records are updated correctly without country info
     */
    @isTest
    private static void removeLeadCountryInfo() {
        List<Lead> testLeads = TestData.createLeadRecords(2, 'Random Country');
        testLeads[0].CountryCapital__c = 'Random Capital';
        testLeads[1].CountryAlpha3Code__c = 'RCD';
        insert testLeads;

        Test.startTest();
        CountryTriggerHandler.removeLeadCountryInfo(testLeads);
        Test.stopTest();

        List<Lead> leads = [SELECT CountryCapital__c, CountryAlpha3Code__c, Country FROM Lead];
        for(Lead lead : leads) {
            System.assertEquals(null, lead.CountryCapital__c, 'Capital on Lead not null');
            System.assertEquals(null, lead.CountryAlpha3Code__c, 'Alpha3Code on Lead not null');
        }
    }

    /**
     * Checks that an exception is thrown if a user without rights
     * to update Lead records is trying to remove country data
     */
    @isTest
    private static void removeLeadCountryInfo_NoAccess() {
        Exception ex;
        User testUser = TestData.createUsers(1, 'Chatter External User')[0];
        List<Lead> testLeads = TestData.createLeadRecords(2, 'Random Country');
        testLeads[0].CountryCapital__c = 'Random Capital';
        testLeads[1].CountryAlpha3Code__c = 'RCD';
        insert testLeads;

        Test.startTest();
        try {
            System.runAs(testUser) {
                CountryTriggerHandler.removeLeadCountryInfo(testLeads);
            }
        }
        catch(Exception e) {
            ex = e;
        }
        Test.stopTest();
        
        System.assertEquals('CustomException', ex.getTypeName(), 'Exception type incorrect');
    }
}