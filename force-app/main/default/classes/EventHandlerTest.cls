@isTest
public class EventHandlerTest {
    @isTest
    static void testScheduledEventValidation() {
        Event existingEvent = new Event(
            StartDateTime = DateTime.newInstance(2024, 9, 16, 16, 0, 0), // 4:00 PM
            EndDateTime = DateTime.newInstance(2024, 9, 16, 17, 0, 0),   // 5:00 PM
            Subject = 'Existing Event'
        );
        insert existingEvent;

        Event overlappingEvent = new Event(
            StartDateTime = DateTime.newInstance(2024, 9, 16, 16, 30, 0), // 4:30 PM
            EndDateTime = DateTime.newInstance(2024, 9, 16, 17, 30, 0),   // 5:30 PM
            Subject = 'Overlapping Event'
        );
        
        Event nonOverlappingEvent = new Event(
            StartDateTime = DateTime.newInstance(2024, 9, 16, 17, 30, 0), // 5:30 PM
            EndDateTime = DateTime.newInstance(2024, 9, 16, 18, 30, 0),   // 6:30 PM
            Subject = 'Non-Overlapping Event'
        );

        List<Event> eventsToInsert = new List<Event>{ overlappingEvent, nonOverlappingEvent };

        Test.startTest();

        Database.SaveResult[] results = Database.insert(eventsToInsert, false);
        Test.stopTest();

        Boolean overlappingEventHasError = false;
        Boolean nonOverlappingEventCreated = false;

        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                if (result.getErrors()[0].getMessage().contains('There is already an event scheduled during this time.')) {
                    overlappingEventHasError = true;
                }
            } else {
                if (result.getId() == nonOverlappingEvent.Id) {
                    nonOverlappingEventCreated = true;
                }
            }
        }

        System.assert(overlappingEventHasError, 'Expected error for overlapping event.');
        System.assert(nonOverlappingEventCreated, 'Non-overlapping event should be created without errors.');
    }
}
