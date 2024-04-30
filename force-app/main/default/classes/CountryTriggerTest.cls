@isTest
private class CountryTriggerTest {
    
    /**
     * Checks Country__c record insert is updating corresponding Leads
     */
    @isTest
    private static void onInsert() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.createCountryRecordsByNameMap(2);
        List<Lead> testLeads = TestData.createLeadRecords(3, testCountries.values()[0].Name__c);
        testLeads.addAll(TestData.createLeadRecords(2, testCountries.values()[1].Name__c));
        testLeads[1].CountryCapital__c = 'Random Capital';
        testLeads[4].CountryAlpha3Code__c = 'RCD';
        insert testLeads;

        Test.startTest();
        settings.DisableAutomation__c = false;
        update settings; // re-enable automation
        insert testCountries.values();
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
     * Checks Country__c record update is updating corresponding Leads
     */
    @isTest
    private static void onUpdate() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.insertCountryRecordsByNameMap(2);
        List<Lead> testLeads = TestData.insertLeadRecords(3, testCountries.values()[0].Name__c);
        testLeads.addAll(TestData.insertLeadRecords(2, testCountries.values()[1].Name__c));

        Test.startTest();
        settings.DisableAutomation__c = false;
        update settings; // re-enable automation
        
        testCountries.values()[0].CapitalCity__c = 'Random Capital';
        testCountries.values()[1].Alpha3Code__c = 'RCD';
        update testCountries.values();
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
     * Checks Country__c record delete is updating corresponding Leads
     */
    @isTest
    private static void onDelete() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        List<Country__c> testCountries = TestData.insertCountryRecords(2);
        List<Lead> testLeads = TestData.insertLeadRecords(3, testCountries[0].Name__c);
        testLeads.addAll(TestData.insertLeadRecords(2, testCountries[1].Name__c));
        
        Test.startTest();
        settings.DisableAutomation__c = false;
        update settings; // re-enable automation
        delete testCountries;
        Test.stopTest();

        List<Lead> leads = [SELECT CountryCapital__c, CountryAlpha3Code__c, Country FROM Lead];
        for(Lead lead : leads) {
            System.assertEquals(null, lead.CountryCapital__c, 'Capital on Lead not null');
            System.assertEquals(null, lead.CountryAlpha3Code__c, 'Alpha3Code on Lead not null');
        }
    }

    /**
     * Checks Country__c record undelete is updating corresponding Leads
     */
    @isTest
    private static void onUndelete() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.insertCountryRecordsByNameMap(2);
        List<Lead> testLeads = TestData.createLeadRecords(3, testCountries.values()[0].Name__c);
        testLeads.addAll(TestData.createLeadRecords(2, testCountries.values()[1].Name__c));
        testLeads[1].CountryCapital__c = 'Random Capital';
        testLeads[4].CountryAlpha3Code__c = 'RCD';
        insert testLeads;
        delete testCountries.values();

        Test.startTest();
        settings.DisableAutomation__c = false;
        update settings; // re-enable automation
        undelete testCountries.values();
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
     * Checks Country__c trigger doesn't run when automation is disabled
     */
    @isTest
    private static void disableTrigger() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        List<Country__c> testCountries = TestData.createCountryRecords(2);
        List<Lead> testLeads = TestData.createLeadRecords(1, testCountries[0].Name__c);
        testLeads.addAll(TestData.createLeadRecords(1, testCountries[1].Name__c));
        testLeads[0].CountryCapital__c = 'Random Capital';
        testLeads[1].CountryAlpha3Code__c = 'RCD';
        insert testLeads;

        Test.startTest();
        insert testCountries;
        Test.stopTest();

        List<Lead> leads = [SELECT CountryCapital__c, CountryAlpha3Code__c, Country FROM Lead ORDER BY Country ASC];
        System.assertEquals('Random Capital', leads[0].CountryCapital__c, 'Capital on Lead not correct');
        System.assertEquals('RCD', leads[1].CountryAlpha3Code__c, 'Alpha3Code on Lead not correct');
    }

}