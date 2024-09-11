@isTest
public class Schedule_CloseOldApplicationsTest {

    @isTest
    static void testJobScheduled() {
        Test.startTest();
        Schedule_CloseOldApplications scheduler = new Schedule_CloseOldApplications();
        String jobID = System.schedule('Test Schedule Close Old Applications', '0 5 * * * ?', scheduler);
        Test.stopTest();

        CronTrigger[] scheduledJobs = [SELECT Id, CronJobDetail.Name, CronJobDetail.JobType, State FROM CronTrigger WHERE Id = :jobID];
        System.assertEquals(1, scheduledJobs.size(), 'The job should be scheduled.');
    }
}
