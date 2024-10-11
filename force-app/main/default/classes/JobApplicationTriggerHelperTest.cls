@isTest
public class JobApplicationTriggerHelperTest {
    @TestSetup
    static void makeData(){
        List<Account> testAccounts = new List<Account>();

        for(Integer i = 0; i < 200; i++) {
            Account account = new Account();
            account.Name = 'Test Account ' + i;
            testAccounts.add(account);
        }
        insert testAccounts;

        List<Job_Application__c> applications = new List<Job_Application__c>();

        for(Account a : testAccounts) {
            Job_Application__c application = new Job_Application__c();
            application.Name = 'Test App';
            application.Company__c = a.Id;
            applications.add(application);
        }
        insert applications;

        // Create test contacts
        List<Contact> testContacts = new List<Contact>();
        for (Account acc : testAccounts) {
            testContacts.add(new Contact(LastName = 'Test Contact', AccountId = acc.Id));
        }
        insert testContacts;
    }

    @isTest
    static void testStatusSaved() {
        Job_Application__c app = [SELECT Id, Status__c FROM Job_Application__c LIMIT 1];
        app.Status__c = 'Saved';

        Test.startTest();
        update app;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(3, tasks.size(), 'Expected 3 tasks for status "Saved"');
    }

    @isTest
    static void testStatusApplying() {
        Job_Application__c app = [SELECT Id, Status__c FROM Job_Application__c LIMIT 1];
        app.Status__c = 'Applying';

        Test.startTest();
        update app;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(5, tasks.size(), 'Expected 5 tasks for status "Applying"');
    }

    @isTest
    static void testStatusApplied() {
        Job_Application__c app = [SELECT Id, Status__c FROM Job_Application__c LIMIT 1];
        app.Status__c = 'Applied';

        Test.startTest();
        update app;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(4, tasks.size(), 'Expected 4 tasks for status "Applied"');
    }

    @isTest
    static void testStatusInterviewing() {
        Job_Application__c app = [SELECT Id, Status__c FROM Job_Application__c LIMIT 1];
        app.Status__c = 'Interviewing';

        Test.startTest();
        update app;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(5, tasks.size(), 'Expected 5 tasks for status "Interviewing"');
    }

    @isTest
    static void testStatusNegotiating() {
        Job_Application__c app = [SELECT Id, Status__c FROM Job_Application__c LIMIT 1];
        app.Status__c = 'Negotiating';

        Test.startTest();
        update app;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(3, tasks.size(), 'Expected 3 tasks for status "Negotiating"');
    }

    @isTest
    static void testStatusAccepted() {
        Job_Application__c app = [SELECT Id, Status__c FROM Job_Application__c LIMIT 1];
        app.Status__c = 'Accepted';

        Test.startTest();
        update app;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(3, tasks.size(), 'Expected 3 tasks for status "Accepted"');
    }

    @isTest
    static void testStatusClosed() {
        Job_Application__c app = [SELECT Id, Status__c FROM Job_Application__c LIMIT 1];
        app.Status__c = 'Closed';

        Test.startTest();
        update app;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(2, tasks.size(), 'Expected 2 tasks for status "Closed"');
    }

    @isTest
    static void negativeTestTaskCreation() {
        List<Job_Application__c> applications = [
            SELECT Id, Status__c, Rating__c FROM Job_Application__c
        ];

        for(Job_Application__c app : applications) {
            app.Rating__c = '4';
        }
        Test.startTest();
        update applications;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject, Priority FROM Task WHERE WhatId IN :applications];
        System.assertEquals(0, tasks.size(), 'No Tasks should be created');

    }

    @isTest
    static void nullTestTaskCreation() {
        List<Job_Application__c> applications = [
            SELECT Id, Status__c FROM Job_Application__c
        ];

        for(Job_Application__c app : applications) {
            app.Status__c = null;
        }
        update applications;

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :applications];
        System.assertEquals(0, tasks.size(), 'No tasks should be created for null status');
    }

    @isTest
    static void testSetPrimaryContactPositive() {
        // Positive test: Job Applications with Companies should get Primary Contacts set
        List<Account> testAccounts = [SELECT Id FROM Account];
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        
        for (Account acc : testAccounts) {
            jobApps.add(new Job_Application__c(Company__c = acc.Id));
        }
        
        Test.startTest();
        insert jobApps;
        Test.stopTest();
        
        // Verify results
        List<Job_Application__c> updatedJobApps = [SELECT Id, Company__c, Primary_Contact__c FROM Job_Application__c];
        System.assertEquals(testAccounts.size(), updatedJobApps.size(), 'All job applications should be inserted');
        
        for (Job_Application__c app : updatedJobApps) {
            System.assertNotEquals(null, app.Primary_Contact__c, 'Primary Contact should be set for each Job Application');
        }
    }

    @isTest
    static void testSetPrimaryContactNegative() {
        // Negative test: Job Application without Company should not get Primary Contact set
        Job_Application__c jobApp = new Job_Application__c();
        
        Test.startTest();
        insert jobApp;
        Test.stopTest();
        
        // Verify results
        Job_Application__c updatedJobApp = [SELECT Id, Company__c, Primary_Contact__c FROM Job_Application__c WHERE Id = :jobApp.Id];
        System.assertEquals(null, updatedJobApp.Primary_Contact__c, 'Primary Contact should not be set for Job Application without Company');
    }

    @isTest
    static void testSetPrimaryContactBulk() {
        // Bulk test: Test with more than 200 records
        List<Account> testAccounts = [SELECT Id FROM Account];
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        
        for (Integer i = 0; i < 201; i++) {
            jobApps.add(new Job_Application__c(Company__c = testAccounts[Math.mod(i, testAccounts.size())].Id));
        }
        
        Test.startTest();
        insert jobApps;
        Test.stopTest();
        
        // Verify results
        List<Job_Application__c> updatedJobApps = [SELECT Id, Company__c, Primary_Contact__c FROM Job_Application__c];
        System.assertEquals(201, updatedJobApps.size(), 'All 201 job applications should be inserted');
        
        for (Job_Application__c app : updatedJobApps) {
            System.assertNotEquals(null, app.Primary_Contact__c, 'Primary Contact should be set for each Job Application in bulk operation');
        }
    }
}