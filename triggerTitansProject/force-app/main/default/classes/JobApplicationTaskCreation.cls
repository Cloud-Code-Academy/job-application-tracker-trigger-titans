public with sharing class JobApplicationTaskCreation {
    public static void createTasksForApplications(Map<Id, Job_Application__c> oldMap, List<Job_Application__c> applications) {
        List<String> savedStatusSubjects = new List<String>{
            'Check if the job description aligns with your interests and values',
            'Review the highlighted skills to see if the role is a good fit',
            'Research the company or role and mark your excitement level'
        };

        List<String> applyingStatusSubjects = new List<String>{
            'Find and research someone who works at the company and add them as a contact',
            'Set up an informational interview to learn more about the role/company',
            'Identify potential referrals to help get your application on the top of the pile',
            'Customize your work achievements using the job description keywords',
            'Submit your application on the company website if possible'
        };

        List<String> appliedStatusSubjects = new List<String>{
            'Reach out to the hiring manager or recruiter',
            'Follow up on your application via email weekly',
            'Continue identifying and saving similar job opportunities',
            'Set up weekly networking calls to explore similar companies/roles'
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

    public static void createTasks(Job_Application__c application, List<String> subjectStrings) {
        List<Task> taskList = new List<Task>();

        for(String subject : subjectStrings) {
            Task newTask = new Task();
            newTask.ActivityDate = Date.today().addDays(1);
            newTask.Subject = subject;
            newTask.Priority = 'Low';
            newTask.OwnerId = application.OwnerId;
            newTask.WhatId = application.Id;
            taskList.add(newTask);
        }

        try {
            insert taskList;
        } catch (Exception e) {
            System.debug(e);
        }
    }
}