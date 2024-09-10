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
    
}