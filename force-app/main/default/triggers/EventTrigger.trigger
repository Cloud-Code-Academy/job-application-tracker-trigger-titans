trigger EventTrigger on Event (before insert) {
    Switch on Trigger.OperationType {
        when BEFORE_INSERT {
            EventHandler.scheduledEventValidation(Trigger.new);
        }
    }
}