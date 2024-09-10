public with sharing class JobApplicationTriggerHandler extends TriggerHandler {

    public static Boolean hasRun = false;

    public JobApplicationTriggerHandler() {

    }

    public override void beforeInsert() {
        JobApplicationTriggerHelper.setPrimaryContact(Trigger.new);
    }

    public override void beforeUpdate() {
        JobApplicationTriggerHelper.setPrimaryContact(Trigger.new);
    }
}