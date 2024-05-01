@isTest
private class FlowTest {

    public static final String VALIDATION_RULE_MESSAGE =
        'You must fill in the following before changing the Lead Owner: ' +
        'Lead Source, Country (except System Administrator), Number of Employees ' +
        '(except System Administrator and Contract Manager).';
    
    /**
     * Checks that OwnerSince__c is correctly set for new Leads
     */
    @isTest
    private static void insertLead() {
        User testUser = TestData.insertUsers(1, 'Contract Manager')[0];
        List<Lead> testLeads = TestData.createLeadRecords(5, null);
        testLeads[0].OwnerId = testUser.Id;
        testLeads[1].OwnerId = testUser.Id;

        Test.startTest();
        Datetime now = Datetime.now();
        insert testLeads;
        Test.stopTest();

        List<Lead> leads = [SELECT OwnerId, OwnerSince__c FROM Lead ORDER BY LastName ASC];
        for(Integer i = 0; i < 5; i++) {
            System.assertEquals(
                i < 2 ? testUser.Id : UserInfo.getUserId(),
                leads[i].OwnerId,
                'OwnerId is not correct' 
            );
            System.assertEquals(now, leads[i].OwnerSince__c, 'OwnerId was not set correctly');
        }
    }

    /**
     * Checks that OwnerSince__c is correctly set for Lead Owner change
     * (Standard User profile)
     */
    @isTest
    private static void updateLeadOwner_StandardUser() {
        User testUser = TestData.insertUsers(1, 'Standard User')[0];
        List<Lead> testLeads = TestData.insertLeadRecords(5, 'Test Country');

        Test.startTest();
        testLeads[0].OwnerId = testUser.Id;
        testLeads[0].LeadSource = 'Web';
        testLeads[0].NumberOfEmployees = 50;
        testLeads[1].OwnerId = testUser.Id;
        testLeads[1].LeadSource = 'Web';
        testLeads[1].NumberOfEmployees = 50;
        Datetime now = Datetime.now();

        System.runAs(testUser) {
            update testLeads;
        }
        Test.stopTest();

        List<Lead> leads = [SELECT OwnerId, OwnerSince__c FROM Lead ORDER BY LastName ASC];
        for(Integer i = 0; i < 5; i++) {
            System.assertEquals(
                i < 2 ? testUser.Id : UserInfo.getUserId(),
                leads[i].OwnerId,
                'OwnerId is not correct' 
            );
            System.assertEquals(now, leads[i].OwnerSince__c, 'OwnerId was not set correctly');
        }
    }

    /**
     * Checks that OwnerSince__c is correctly set for Lead Owner change
     * (Contract Manager profile)
     */
    @isTest
    private static void updateLeadOwner_ContractManager() {
        User testUser = TestData.insertUsers(1, 'Contract Manager')[0];
        List<Lead> testLeads = TestData.insertLeadRecords(5, 'Test Country');

        Test.startTest();
        testLeads[0].OwnerId = testUser.Id;
        testLeads[0].LeadSource = 'Web';
        testLeads[1].OwnerId = testUser.Id;
        testLeads[1].LeadSource = 'Web';
        Datetime now = Datetime.now();

        System.runAs(testUser) {
            update testLeads;
        }
        Test.stopTest();

        List<Lead> leads = [SELECT OwnerId, OwnerSince__c FROM Lead ORDER BY LastName ASC];
        for(Integer i = 0; i < 5; i++) {
            System.assertEquals(
                i < 2 ? testUser.Id : UserInfo.getUserId(),
                leads[i].OwnerId,
                'OwnerId is not correct' 
            );
            System.assertEquals(now, leads[i].OwnerSince__c, 'OwnerId was not set correctly');
        }
    }

    /**
     * Checks that OwnerId can't be changed without required fields
     * (Standard User profile)
     */
    @isTest
    private static void updateLeadOwner_MissingFields_StandardUser() {
        User testUser = TestData.insertUsers(1, 'Standard User')[0];
        Lead testLead = TestData.insertLeadRecords(1, 'Test Country')[0];
        Exception ex;

        Test.startTest();
        testLead.OwnerId = testUser.Id;
        testLead.LeadSource = 'Web';
        Datetime now = Datetime.now();

        System.runAs(testUser) {
            try {
                update testLead;
            }
            catch(Exception e) {
                ex = e;
            }
        }
        Test.stopTest();

        Lead lead = [SELECT OwnerId FROM Lead];
        System.assertEquals(UserInfo.getUserId(), lead.OwnerId, 'OwnerId should not change');
        System.assert(ex.getMessage().contains(VALIDATION_RULE_MESSAGE), 'Exception message should match validation rule');
        System.assertEquals('System.DmlException', ex.getTypeName(), 'Exception type incorrect');
    }

    /**
     * Checks that OwnerId can't be changed without required fields
     * (Contract Manager profile)
     */
    @isTest
    private static void updateLeadOwner_MissingFields_ContractManager() {
        User testUser = TestData.insertUsers(1, 'Contract Manager')[0];
        Lead testLead = TestData.insertLeadRecords(1, 'Test Country')[0];
        Exception ex;

        Test.startTest();
        testLead.OwnerId = testUser.Id;
        Datetime now = Datetime.now();

        System.runAs(testUser) {
            try {
                update testLead;
            }
            catch(Exception e) {
                ex = e;
            }
        }
        Test.stopTest();

        Lead lead = [SELECT OwnerId FROM Lead];
        System.assertEquals(UserInfo.getUserId(), lead.OwnerId, 'OwnerId should not change');
        System.assert(ex.getMessage().contains(VALIDATION_RULE_MESSAGE), 'Exception message should match validation rule');
        System.assertEquals('System.DmlException', ex.getTypeName(), 'Exception type incorrect');
    }
}