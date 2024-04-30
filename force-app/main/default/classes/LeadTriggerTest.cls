@isTest
private class LeadTriggerTest {
    
    /**
     * Checks Lead record insert is updating country info
     */
    @isTest
    private static void onInsert() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.insertCountryRecordsByNameMap(2);
        List<Lead> testLeads = TestData.createLeadRecords(3, testCountries.values()[0].Name__c);
        testLeads.addAll(TestData.createLeadRecords(2, testCountries.values()[1].Name__c));

        Test.startTest();
        settings.DisableAutomation__c = false;
        update settings; // re-enable automation
        insert testLeads;
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
     * Checks Lead record update is updating country info
     */
    @isTest
    private static void onUpdate() {
        GeneralSettings__c settings = TestData.insertGeneralSettings(); // disable automation
        Map<String, Country__c> testCountries = TestData.insertCountryRecordsByNameMap(2);
        List<Lead> testLeads = TestData.createLeadRecords(3, testCountries.values()[0].Name__c);
        testLeads.addAll(TestData.createLeadRecords(2, testCountries.values()[1].Name__c));
        testLeads[0].CountryCapital__c = 'Random Capital';
        testLeads[1].CountryAlpha3Code__c = 'RCD';
        insert testLeads;

        Test.startTest();
        settings.DisableAutomation__c = false;
        update settings; // re-enable automation
        
        testLeads[0].Country = testCountries.values()[1].Name__c;
        testLeads[2].Country = testCountries.values()[1].Name__c;
        testLeads[3].Country = testCountries.values()[0].Name__c;
        testLeads[4].Country = testCountries.values()[0].Name__c;
        testLeads[1].Country = null;
        update testLeads;
        Test.stopTest();

        List<Lead> leads = [SELECT CountryCapital__c, CountryAlpha3Code__c, Country FROM Lead];
        for(Lead lead : leads) {
        System.debug(lead);
            System.assertEquals(
                lead.Country != null ? testCountries.get(lead.Country).CapitalCity__c : null,
                lead.CountryCapital__c,
                'Capital on Lead not correct'
            );
            System.assertEquals(
                lead.Country != null ? testCountries.get(lead.Country).Alpha3Code__c : null,
                lead.CountryAlpha3Code__c,
                'Alpha3Code on Lead not correct'
            );
        }
    }
}