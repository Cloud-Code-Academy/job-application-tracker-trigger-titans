public class CloseOldApplications implements Database.Batchable<sObject> {
    private Date dateThreshold;

    public CloseOldApplications() {
        dateThreshold = Date.today().addDays(-30);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Status__c, Follow_Up_Date__c, Notes__c ' +
            'FROM Job_Application__c ' +
            'WHERE Status__c != \'Closed\' ' +
            'AND Status__c != \'Accepted\' ' +
            'AND Follow_Up_Date__c <= :dateThreshold'
        );
    }
    public void execute(Database.BatchableContext BC, List<Job_Application__c> scope) {
        for (Job_Application__c application : scope) {
            application.Status__c = 'Closed';
            application.Notes__c = 'Closed by automatic process 30 days after Follow-Up Date: ' + application.Follow_Up_Date__c.format() + '.';
        }
        try {
            update scope;
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
