trigger JobApplicationTrigger on Job_Application__c (after update) {
    SWITCH ON Trigger.OperationType {
        WHEN AFTER_UPDATE {
            JobApplicationHandler.handleAfterUpdate(Trigger.New);
        }
    }
}