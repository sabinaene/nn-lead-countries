@isTest
private class CountryLayerSchedulerTest {
    
    /**
     * Checks the queueable job calls the API and makes updates
     */
    @isTest
    private static void executeQueueable() {
        CountryLayerAPI__c settings = TestData.insertApiSettings();
        String mockResponse = TestData.mockApiResponseBody(14);
        List<Country__c> testCountries = TestData.createCountryRecords(15);

        // rename to delete
        testCountries[3].Name__c = 'Random Name';

        // change fields to update
        testCountries[5].Region__c = 'Random Region';
        testCountries[8].Alpha2Code__c = 'RR';

        insert testCountries;
        Test.setMock(HttpCalloutMock.class, new TestData.MockHttpResponse(mockResponse, 200));

        Test.startTest();
        System.enqueueJob(new CountryLayerScheduler.AsyncCallout());
        Test.stopTest();

        Map<String, Country__c> countriesByName = new Map<String, Country__c>();
        for(Country__c country : [SELECT Name__c, Alpha2Code__c, Region__c FROM Country__c]) {
            countriesByName.put(country.Name__c, country);
        }

        System.assertEquals(14, countriesByName.size(), 'Number of countries not correct');
        System.assertEquals(null, countriesByName.get('Random Name'), 'Country Random Name should not exist');
        System.assertEquals(
            'Test Region FGH',
            countriesByName.get('Test Country FGH').Region__c,
            'Region for country 5/FGH is not correct'
        );
        System.assertEquals(
            'IJ',
            countriesByName.get('Test Country IJK').Alpha2Code__c,
            'Alpha2Code for country 8/IJK is not correct'
        );
    }

    /**
     * Checks the schedulable job is set as expected
     */
    @isTest
    private static void executeSchedulable() {
        CountryLayerAPI__c settings = TestData.insertApiSettings();
        Test.setMock(HttpCalloutMock.class, new TestData.MockHttpResponse('[]', 200));

        Test.startTest();
        CountryLayerScheduler schedule = new CountryLayerScheduler();   
        String cronTime = '0 0 23 * * ?';        
        System.schedule('Test Schedule', cronTime, schedule);
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [
            SELECT NextFireTime
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'Test Schedule'
            AND CronJobDetail.JobType = '7'
        ];
        Time fireTime = Time.newInstance(23, 0, 0, 0);
        Date fireDate = Datetime.now().hour() == 23 ? Date.today().addDays(1) : Date.today();

        System.assertEquals(1, scheduledJobs.size(), 'Scheduled job not found');
        System.assertEquals(
            Datetime.newInstance(fireDate, fireTime),
            scheduledJobs[0].NextFireTime,
            'Job next fire time is not correct'
        );
    }
}