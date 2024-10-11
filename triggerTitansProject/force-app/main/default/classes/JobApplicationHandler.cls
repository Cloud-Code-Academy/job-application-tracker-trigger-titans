public with sharing class JobApplicationHandler {
    public static void handleAfterUpdate(Map<Id, Job_Application__c> oldMap, List<Job_Application__c> applications) {
        List<String> savedStatusSubjects = new List<String>{
                                                    'Check if the job description aligns with your interests and values',
                                                    'Review the highlighted skills to see if the role is a good fit',
                                                    'Research the company or role and mark your excitement level'
                                                };
        
        List<Job_Application__c> applicationsToUpdate = new List<Job_Application__c>();
        
        for(Job_Application__c application : applications) {
            if(application.Status__c != oldMap.get(application.Id).Status__c) {
                if(application.Status__c == 'Saved') {
                    JobApplicationTaskCreation.createTasks(application, savedStatusSubjects);
                }
            } else continue;
        }
    } 
}