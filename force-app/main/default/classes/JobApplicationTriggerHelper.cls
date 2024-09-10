public with sharing class JobApplicationTriggerHelper {
    public JobApplicationTriggerHelper() {

    }

    // Handler for before insert or before update operations
    public static void setPrimaryContact(List<Job_Application__c> jobApplications) {
        Set<Id> companyIds = new Set<Id>();
        
        // Collect all Company (Account) Ids from the Job Applications
        for (Job_Application__c application : jobApplications) {
            if (application.Primary_Contact__c == null && application.Company__c != null) {
                companyIds.add(application.Company__c);
            }
        }
        
        // Query related Contacts based on Company (Account) Ids
        Map<Id, Contact> companyToContactMap = new Map<Id, Contact>();
        if (!companyIds.isEmpty()) {
            for (Contact contact : [
                SELECT Id, AccountId 
                FROM Contact 
                WHERE AccountId IN :companyIds
                LIMIT 1
            ]) {
                companyToContactMap.put(contact.AccountId, contact);
            }
        }
        
        // Assign the first related contact to the Primary_Contact__c field
        for (Job_Application__c application : jobApplications) {
            if (application.Primary_Contact__c == null && companyToContactMap.containsKey(application.Company__c)) {
                application.Primary_Contact__c = companyToContactMap.get(application.Company__c).Id;
            }
        }
    }

    //Author: Jodi Eagan
    public static void createTasksForApplications(Map<Id, Job_Application__c> oldMap, List<Job_Application__c> applications) {
        List<Task> taskList = new List<Task>();
        
        for(Job_Application__c application : applications) {
            if(application.Status__c != oldMap.get(application.Id).Status__c) {
                taskList.addAll(createTasks(application));
            }
        }
        
        try {
            if (!taskList.isEmpty()) {
                insert taskList;
            }
        } catch (Exception e) {
            System.debug(e);
        }
    } 

    //Author: Jodi Eagan
    public static List<Task> createTasks(Job_Application__c application) {
        List<Task> taskList = new List<Task>();
        String priority = null;
        List<String> subjectStrings = new List<String>();

        Map<String, List<String>> statusSubjects = new Map<String, List<String>>{
            'Saved' => new List<String>{
                'Check if the job description aligns with your interests and values',
                'Review the highlighted skills to see if the role is a good fit',
                'Research the company or role and mark your excitement level'
            },
            'Applying' => new List<String>{
                'Find and research someone who works at the company and add them as a contact',
                'Set up an informational interview to learn more about the role/company',
                'Identify potential referrals to help get your application on the top of the pile',
                'Customize your work achievements using the job description keywords',
                'Submit your application on the company website if possible'
            },
            'Applied' => new List<String>{
                'Reach out to the hiring manager or recruiter',
                'Follow up on your application via email weekly',
                'Continue identifying and saving similar job opportunities',
                'Set up weekly networking calls to explore similar companies/roles'
            },
            'Interviewing' => new List<String>{
                'Prepare your blurb or “tell me about yourself” response',
                'Practice answering behavioral interview questions',
                'Research the company and your interviewers',
                'Set up your virtual interview space and test your tech',
                'Send thank you emails within 24 hours'
            },
            'Negotiating' => new List<String>{
                'Research your market value and know your numbers',
                'Prepare your negotiation scripts',
                'Evaluate your offer and decline or accept'
            },
            'Accepted' => new List<String>{
                'Plan your resignation if applicable',
                'Take some time to relax and recharge',
                'Prepare for your first day of onboarding'
            },
            'Closed' => new List<String>{
                'Send a follow-up email thanking the interviewer and asking for feedback',
                'Review your notes and reflect on areas of improvement'
            }
        };

        if (statusSubjects.containsKey(application.Status__c)) {
            subjectStrings = statusSubjects.get(application.Status__c);
            if (application.Status__c == 'Saved') {
                priority = 'Low';
            } else if (application.Status__c == 'Interviewing' || application.Status__c == 'Negotiating' || application.Status__c == 'Accepted') {
                priority = 'High';
            } else {
                priority = 'Medium';
            }
        } else {
            return taskList;
        }

        for (String subject : subjectStrings) {
            Task newTask = new Task();
            newTask.ActivityDate = Date.today().addDays(1);
            newTask.Subject = subject;
            newTask.Priority = priority;
            newTask.OwnerId = application.OwnerId;
            newTask.WhatId = application.Id;
            taskList.add(newTask);
        }

        return taskList;
    }
}