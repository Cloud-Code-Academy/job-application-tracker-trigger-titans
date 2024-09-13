global class JoobleCallout {
    public class JobPostingWrapper {
        @AuraEnabled
        public String company {get; set;}
        @AuraEnabled
        public String salaryRange { get; set; }
        @AuraEnabled
        public String description {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String location {get; set;}
        @AuraEnabled
        public String url {get; set;}
    }

    @AuraEnabled 
    public static List<JobPostingWrapper> getNewJobPostings() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        String key = '9930cac1-8aab-4898-ac34-b00e748452a7';
         request.setEndpoint('https://jooble.org/api/' + key);
         request.setMethod('POST');
         request.setHeader('Content-Type', 'application/json');

         String requestBody = '{"keywords": "Salesforce Developer", "location": "Remote", "salary": 100000}';
         request.setBody(requestBody);
         
         List<JobPostingWrapper> jobPostings = new List<JobPostingWrapper>();

         try {
             HttpResponse response = http.send(request);
             
             if (response.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                List<Object> jobs = (List<Object>) jsonResponse.get('jobs'); 

                for (Object jobObj : jobs) {
                    Map<String, Object> job = (Map<String, Object>) jobObj;

                    JobPostingWrapper jobPosting = new JobPostingWrapper();
                    jobPosting.company = (String) job.get('company');
                    jobPosting.salaryRange = (String) job.get('salary');
                    jobPosting.description = stripHtml((String) job.get('snippet'));  
                    jobPosting.title = (String) job.get('title');
                    jobPosting.location = (String) job.get('location');
                    jobPosting.url = (String) job.get('link');  
                   
                    jobPostings.add(jobPosting);
                }
            } else {
                System.debug('Error: ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }

        System.debug('Job Postings: ' + jobPostings);
        return jobPostings;
    }

    @AuraEnabled
    public static void saveSelectedJobs(List<JobPostingWrapper> jobs) {
        List<Job_Application__c> jobApplications = new List<Job_Application__c>();

        for (JobPostingWrapper job : jobs) {
            Job_Application__c newJobApplication = new Job_Application__c();
            newJobApplication.Company_Text__c = job.company;
            newJobApplication.Position_Title__c = job.title;
            newJobApplication.Location__c = job.location;
            newJobApplication.Description__c = job.description;
            newJobApplication.URL__c = job.url;
            newJobApplication.Name = job.title + ' - ' + job.company;
            newJobApplication.Salary_Range__c = job.salaryRange;

            jobApplications.add(newJobApplication);
        }

        try {
            if (!jobApplications.isEmpty()) {
                insert jobApplications;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error saving job applications: ' + e.getMessage());
        }
    }

    public static String stripHtml(String input) {
        if (String.isBlank(input)) {
            return input; 
        }
        String output = input.replaceAll('<.*?>', '');
    
        output = output.replace('&nbsp;', ''); 
        output = output.replace('&amp;', '&'); 
        output = output.replace('&lt;', '<');  
        output = output.replace('&gt;', '>');   
    
        return output;
    }
}