@isTest
private class JoobleCalloutMockTest {
   
    @isTest
    static void testGetNewJobPostings() {
        Test.setMock(HttpCalloutMock.class, new JoobleCalloutMock());
        
        List<JoobleCallout.JobPostingWrapper> jobs = JoobleCallout.getNewJobPostings();
        
        System.assertNotEquals(0, jobs.size(), 'Job postings should not be empty');
        System.assertEquals('Test Company 1', jobs[0].company, 'Company should match mock response');
        System.assertEquals('Salesforce Developer', jobs[0].title, 'Job title should match mock response');
        System.assertEquals('100000', jobs[0].salaryRange, 'Salary range should match mock response');
        System.assertEquals('Remote', jobs[0].location, 'Location should match mock response');
        System.assertEquals('https://testlink.com/job1', jobs[0].url, 'URL should match mock response');
    }

    @isTest
    static void testSaveSelectedJobs() {
        List<JoobleCallout.JobPostingWrapper> jobPostings = new List<JoobleCallout.JobPostingWrapper>();

        JoobleCallout.JobPostingWrapper job1 = new JoobleCallout.JobPostingWrapper();
        job1.company = 'New Company';
        job1.title = 'Salesforce Developer';
        job1.location = 'Remote';
        job1.description = 'A great job';
        job1.url = 'https://newcompany.com/job';
        job1.salaryRange = '120000';
        jobPostings.add(job1);

        JoobleCallout.JobPostingWrapper job2 = new JoobleCallout.JobPostingWrapper();
        job2.company = 'Test Company 1';
        job2.title = 'Salesforce Admin';
        job2.location = 'Remote';
        job2.description = 'A good job';
        job2.url = 'https://testcompany.com/job';
        job2.salaryRange = '100000';
        jobPostings.add(job2);

        Test.startTest();
        JoobleCallout.saveSelectedJobs(jobPostings);
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Name FROM Account WHERE Name = 'New Company'];
        System.assertEquals(1, insertedAccounts.size(), 'New company account should be inserted');
        System.assertEquals('New Company', insertedAccounts[0].Name, 'Inserted account should have the correct name');
        
        List<Job_Application__c> jobApps = [SELECT Name, Company_Text__c, Position_Title__c, Salary_Range__c, Company__c FROM Job_Application__c];
        System.assertEquals(2, jobApps.size(), 'There should be 2 job applications inserted');
        
        System.assertNotEquals(null, jobApps[0].Company__c, 'Job application should have a linked account');
        System.assertNotEquals(null, jobApps[1].Company__c, 'Job application should have a linked account');
    }
    
    private class JoobleCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"jobs":[' +
                '{"company": "Test Company 1", "title": "Salesforce Developer", "location": "Remote", "salary": "100000", "snippet": "<b>Great opportunity</b>", "link": "https://testlink.com/job1"},' +
                '{"company": "Test Company 2", "title": "Salesforce Architect", "location": "Remote", "salary": "150000", "snippet": "<b>Excellent position</b>", "link": "https://testlink.com/job2"}' +
            ']}');
            return res;
        }
    }
}
