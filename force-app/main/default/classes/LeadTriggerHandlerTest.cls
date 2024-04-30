@isTest
private class LeadTriggerHandlerTest {
    
    /**
     * Checks the Lead records are updated from Country__c records
     */
    @isTest
    private static void updateLeadsWithCountries() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.createCountryRecordsByNameMap(2);
        List<Lead> testLeads = TestData.createLeadRecords(2, testCountries.values()[0].Name__c);
        testLeads.addAll(TestData.createLeadRecords(2, testCountries.values()[1].Name__c));
        testLeads.addAll(TestData.createLeadRecords(2, null));

        Test.startTest();
        LeadTriggerHandler.updateLeadsWithCountries(testLeads, testCountries);
        Test.stopTest();

        System.assertEquals(
            testCountries.values()[0].CapitalCity__c,
            testLeads[0].CountryCapital__c,
            'Capital is not correct on Lead'
        );
        System.assertEquals(
            testCountries.values()[0].Region__c,
            testLeads[1].CountryRegion__c,
            'Region is not correct on Lead'
        );
        System.assertEquals(
            testCountries.values()[1].Alpha2Code__c,
            testLeads[2].CountryAlpha2code__c,
            'Alpha2Code is not correct on Lead'
        );
        System.assertEquals(
            testCountries.values()[1].Alpha3Code__c,
            testLeads[3].CountryAlpha3code__c,
            'Alpha3Code is not correct on Lead'
        );
        System.assertEquals(null, testLeads[4].CountryCapital__c, 'Capital is not null');
        System.assertEquals(null, testLeads[5].CountryAlpha3code__c, 'Alpha3Code is not null');
    }

    /**
     * Checks that User can't query Country__c records
     */
    @isTest
    private static void canQueryCountries_ContractManager() {
        User testUser = TestData.createUsers(1, 'Contract Manager')[0];
        Boolean hasPermission;

        Test.startTest();
        System.runAs(testUser) {
            hasPermission = LeadTriggerHandler.canQueryCountries();
        }
        Test.stopTest();

        System.assertEquals(false, hasPermission, 'User should not be able to query countries');
    }

    /**
     * Checks that User can query Country__c records
     */
    @isTest
    private static void canQueryCountries_ReadCountriesPermSet() {
        User testUser = TestData.insertUsers(1, 'Contract Manager')[0];
        TestData.assignPermissionSet(new List<Id>{ testUser.Id }, 'ReadCountries');
        Boolean hasPermission;

        Test.startTest();
        System.runAs(testUser) {
            hasPermission = LeadTriggerHandler.canQueryCountries();
        }
        Test.stopTest();

        System.assertEquals(true, hasPermission, 'User should be able to query countries');
    }

}