public with sharing class JobApplicationTriggerHandler extends TriggerHandler {

    public static Boolean hasRun = false;

    public JobApplicationTriggerHandler() {

    }

    public override void beforeInsert() {
        JobApplicationTriggerHelper.setPrimaryContact(Trigger.new);
        JobApplicationTriggerHelper.calculateTaxLiabilities(Trigger.new);
    }

    public override void beforeUpdate() {
        JobApplicationTriggerHelper.setPrimaryContact(Trigger.new);
        JobApplicationTriggerHelper.calculateTaxLiabilities(Trigger.new);
    }
   
    public override void afterUpdate() {
        JobApplicationTriggerHelper.createTasksForApplications((Map<Id, Job_Application__c>)Trigger.oldMap, (List<Job_Application__c>)Trigger.new);
    }   
    
}