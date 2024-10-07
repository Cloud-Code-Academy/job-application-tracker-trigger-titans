@isTest
public class CloseOldApplicationsTest {
  @TestSetup
  static void makeData(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        List<Job_Application__c> appList = new List<Job_Application__c>();

        for(Integer i = 0; i < 200; i++) {
            Job_Application__c app = new Job_Application__c();
            app.Company__c = account.Id;
            app.Follow_Up_Date__c = Date.today().addDays(-35);
            app.Status__c = 'Saved';
            appList.add(app);
        }

        for(Integer j = 0; j < 10; j++) {
            Job_Application__c app = new Job_Application__c();
            app.Company__c = account.Id;
            app.Follow_Up_Date__c = Date.today().addDays(-10);
            app.Status__c = 'Interviewing';
            appList.add(app);
        }
        insert appList;
  }

    @isTest
    static void testCloseApplicationAfter30Days() {
        Test.startTest();
        Database.executeBatch(new CloseOldApplications(), 200);
        Test.stopTest();

        List<Job_Application__c> updatedRecords = [SELECT Id, Status__c, Notes__c, Follow_Up_Date__c FROM Job_Application__c];
        
        for (Job_Application__c record : updatedRecords) {
            if (record.Follow_Up_Date__c != null && record.Follow_Up_Date__c <= Date.today().addDays(-30)) {
                if (record.Status__c == 'Saved') {
                    String expectedNote = 'Closed by automatic process 30 days after Follow-Up Date: ' +
                                        record.Follow_Up_Date__c.format() + '.';
                    System.assertEquals('Closed', record.Status__c, 'These should be closed.');
                        System.assert(record.Notes__c.contains(expectedNote), 'Notes field does not contain the expected text.');
                } else if (record.Status__c == 'Interviewing') {
                    System.assertEquals('Interviewing', record.Status__c, 'Interviewing records should remain unchanged.');
                    System.assert(record.Notes__c == null || record.Notes__c == '', 'Interviewing records should not have notes.');
                }
            }
        }
    }
}