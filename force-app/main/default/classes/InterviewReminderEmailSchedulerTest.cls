/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class InterviewReminderEmailSchedulerTest {

    @TestSetup
    static void setup() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a test Contact
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        // Create a Record Type for Interview events
        RecordType interviewRecordType = new RecordType(
            Name = 'Interview',
            SObjectType = 'Event',
            IsActive = true
        );
        insert interviewRecordType;
    }

    @isTest
    static void testSchedulerWithUpcomingInterviews() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        RecordType interviewRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND Name = 'Interview' LIMIT 1];
        
        // Create test Events (Interviews) for tomorrow
        DateTime tomorrow = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(10, 0, 0, 0));
        List<Event> testEvents = new List<Event>();
        for (Integer i = 0; i < 3; i++) {
            testEvents.add(new Event(
                Subject = 'Test Interview ' + i,
                StartDateTime = tomorrow.addHours(i),
                EndDateTime = tomorrow.addHours(i + 1),
                WhoId = testContact.Id,
                RecordTypeId = interviewRecordType.Id,
                Location = 'Room ' + i,
                Description = 'Interview Description ' + i
            ));
        }
        insert testEvents;
        
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule('Test Interview Reminder', '0 0 0 * * ?', new InterviewReminderEmailScheduler());
        
        // Simulate the scheduler running
        InterviewReminderEmailScheduler scheduler = new InterviewReminderEmailScheduler();
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify that emails were sent
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(1, invocations, 'Expected one email invocation');
        
        // Verify the number of emails sent
        List<EmailMessage> sentEmails = [SELECT Id, ToAddress, Subject, TextBody FROM EmailMessage];
        System.assertEquals(3, sentEmails.size(), 'Expected 3 emails to be sent');
        
        // Verify email content
        for (EmailMessage email : sentEmails) {
            System.assertEquals('john.doe@example.com', email.ToAddress, 'Email should be sent to the correct address');
            System.assertEquals('Reminder: Upcoming Interview Scheduled for Tomorrow', email.Subject, 'Email subject should match');
            System.assert(email.TextBody.contains('This is a reminder for your interview scheduled tomorrow'), 'Email body should contain reminder text');
        }
    }
    
    @isTest
    static void testSchedulerWithNoUpcomingInterviews() {
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule('Test Interview Reminder', '0 0 0 * * ?', new InterviewReminderEmailScheduler());
        
        // Simulate the scheduler running
        InterviewReminderEmailScheduler scheduler = new InterviewReminderEmailScheduler();
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify that no emails were sent
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(0, invocations, 'Expected no email invocations');
        
        List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage];
        System.assertEquals(0, sentEmails.size(), 'Expected no emails to be sent');
    }
    
    @isTest
    static void testSchedulerWithInterviewsOutsideTimeRange() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        RecordType interviewRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Event' AND Name = 'Interview' LIMIT 1];
        
        // Create test Events (Interviews) for day after tomorrow
        DateTime dayAfterTomorrow = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(10, 0, 0, 0));
        Event testEvent = new Event(
            Subject = 'Test Interview Outside Range',
            StartDateTime = dayAfterTomorrow,
            EndDateTime = dayAfterTomorrow.addHours(1),
            WhoId = testContact.Id,
            RecordTypeId = interviewRecordType.Id
        );
        insert testEvent;
        
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule('Test Interview Reminder', '0 0 0 * * ?', new InterviewReminderEmailScheduler());
        
        // Simulate the scheduler running
        InterviewReminderEmailScheduler scheduler = new InterviewReminderEmailScheduler();
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify that no emails were sent
        Integer invocations = Limits.getEmailInvocations();
        System.assertEquals(0, invocations, 'Expected no email invocations');
        
        List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage];
        System.assertEquals(0, sentEmails.size(), 'Expected no emails to be sent');
    }
}