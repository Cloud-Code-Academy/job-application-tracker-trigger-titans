public class JobApplicationLWCController {
    @AuraEnabled
    public static void createJobApplications(List<JobDetails> jobDetails) {
        List<Job_Application__c> applications = new List<Job_Application__c>();
        
        for (JobDetails job : jobDetails) {
            Decimal salaryValue;
          
            
            applications.add(new Job_Application__c(
                Name = job.title + ', ' + job.company,
                Company_Text__c = job.company,
               // Salary__c = salaryValue,
                Description__c = job.description,
                Position_Title__c = job.title,
                Location__c = job.location,
                URL__c = job.url
            ));
        }
        
        try {
            insert applications;
        } catch (DmlException e) {
            System.debug('DML Error: ' + e.getMessage());
            throw new AuraHandledException('Error creating job applications: ' + e.getMessage());
        }
    }

    public class JobDetails {
        @AuraEnabled public String company { get; set; }
        @AuraEnabled public String salary { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String location { get; set; }
        @AuraEnabled public String url { get; set; }
    }
}
