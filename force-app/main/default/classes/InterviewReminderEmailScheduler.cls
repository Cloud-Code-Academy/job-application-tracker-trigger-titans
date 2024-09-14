public class InterviewReminderEmailScheduler implements Schedulable {
    
    // This method will be executed when the scheduled job runs
    public void execute(SchedulableContext sc) {
        // Calculate the start and end of the next day
        DateTime startOfNextDay = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0));
        DateTime endOfNextDay = DateTime.newInstance(Date.today().addDays(2), Time.newInstance(0, 0, 0, 0)).addSeconds(-1);
        
        // Query events (interviews) that are scheduled for the next day
        List<Event> upcomingInterviews = [
            SELECT Id, Subject, StartDateTime, WhoId, WhatId, Location, Description
            FROM Event 
            WHERE StartDateTime >= :startOfNextDay 
                  AND StartDateTime <= :endOfNextDay
                  AND RecordType.Name = 'Interview'
        ];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Loop through each interview and prepare the email
        for (Event interview : upcomingInterviews) {
            if (interview.WhoId != null) {
                // Get contact information
                Contact contact = [SELECT Email FROM Contact WHERE Id = :interview.WhoId LIMIT 1];
                
                if (contact.Email != null) {
                    // Create an email message
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new String[] {contact.Email});
                    email.setSubject('Reminder: Upcoming Interview Scheduled for Tomorrow');
                    email.setPlainTextBody('Hello, \n\nThis is a reminder for your interview scheduled tomorrow. Here are the details:\n'
                                           + 'Subject: ' + interview.Subject + '\n'
                                           + 'Date and Time: ' + interview.StartDateTime.format('yyyy-MM-dd HH:mm') + '\n'
                                           + 'Location: ' + (interview.Location != null ? interview.Location : 'N/A') + '\n'
                                           + 'Description: ' + (interview.Description != null ? interview.Description : 'No additional details provided') + '\n\n'
                                           + 'Please make sure to be available at the scheduled time.\n\nThank you.');
                    emails.add(email);
                }
            }
        }
        
        // Send all reminder emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}
