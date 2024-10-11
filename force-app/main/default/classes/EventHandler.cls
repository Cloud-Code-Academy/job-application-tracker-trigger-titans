public class EventHandler {
    public static void scheduledEventValidation(List<Event> newEvents) {
        Map<Id, Map<String, Long>> existingEventTimeMap = new Map<Id, Map<String, Long>>();

        Set<String> monthsToQuery = new Set<String>();
        for (Event newEvent : newEvents) {
            Date startDate = newEvent.StartDateTime.date();
            Date endDate = newEvent.EndDateTime.date();
            
            monthsToQuery.add(startDate.year() + '-' + startDate.month());
            monthsToQuery.add(endDate.year() + '-' + endDate.month());
        }

        List<Event> existingEvents = new List<Event>();
        for (String monthYear : monthsToQuery) {
            Integer year = Integer.valueOf(monthYear.split('-')[0]);
            Integer month = Integer.valueOf(monthYear.split('-')[1]);

            Date startDateOfMonth = Date.newInstance(year, month, 1);
            Date endDateOfMonth = startDateOfMonth.addMonths(1).addDays(-1);

            List<Event> eventsInMonth = [SELECT Id, StartDateTime, EndDateTime
                                          FROM Event
                                          WHERE (StartDateTime >= :startDateOfMonth AND StartDateTime <= :endDateOfMonth)
                                          OR (EndDateTime >= :startDateOfMonth AND EndDateTime <= :endDateOfMonth)
                                          OR (StartDateTime <= :startDateOfMonth AND EndDateTime >= :endDateOfMonth)];

            existingEvents.addAll(eventsInMonth);
        }

        DateTime fixedPoint = DateTime.newInstanceGmt(System.today(), Time.newInstance(0, 0, 0, 0));

        for (Event existingEvent : existingEvents) {
            DateTime eventStart = existingEvent.StartDateTime;
            DateTime eventEnd = existingEvent.EndDateTime;

            Long existingStartMinutes = (eventStart.getTime() - fixedPoint.getTime()) / 60000;
            Long existingEndMinutes = (eventEnd.getTime() - fixedPoint.getTime()) / 60000;

            Map<String, Long> timeMap = new Map<String, Long>{
                'startMinutes' => existingStartMinutes,
                'endMinutes' => existingEndMinutes
            };

            existingEventTimeMap.put(existingEvent.Id, timeMap);
        }

        for (Event newEvent : newEvents) {
            DateTime newEventStart = newEvent.StartDateTime;
            DateTime newEventEnd = newEvent.EndDateTime;

            Long newStartMinutes = (newEventStart.getTime() - fixedPoint.getTime()) / 60000;
            Long newEndMinutes = (newEventEnd.getTime() - fixedPoint.getTime()) / 60000;

            Boolean overlapDetected = false;

            for (Map<String, Long> existingTimes : existingEventTimeMap.values()) {
                Long existingStartMinutes = existingTimes.get('startMinutes');
                Long existingEndMinutes = existingTimes.get('endMinutes');

                if (newStartMinutes < existingEndMinutes && newEndMinutes > existingStartMinutes) {
                    if (!(newStartMinutes == existingEndMinutes && newEndMinutes <= existingEndMinutes)) {
                        overlapDetected = true;
                        break; 
                    }
                }
            }

            if (overlapDetected) {
                newEvent.addError('There is already an event scheduled during this time.');
            }
        }
    }
}