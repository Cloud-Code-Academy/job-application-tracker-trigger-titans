import { LightningElement, track } from 'lwc';
import getNewJobPostings from '@salesforce/apex/JoobleCallout.getNewJobPostings';
import saveSelectedJobs from '@salesforce/apex/JoobleCallout.saveSelectedJobs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class JobPostings extends LightningElement {
    @track jobPostings = [];
    @track error;
    @track selectedJobs = [];
    @track isLoading = false; 

    columns = [
        { label: 'Company', fieldName: 'company' },
        { label: 'Title', fieldName: 'title' },
        { label: 'Location', fieldName: 'location' },
        { label: 'Salary Range', fieldName: 'salaryRange' }, 
        { label: 'Description', fieldName: 'description' },
        { label: 'URL', fieldName: 'url', type: 'url', typeAttributes: { label: { fieldName: 'url' }, target: '_blank' } }
    ];

    connectedCallback() {
        this.fetchJobPostings();
    }

    fetchJobPostings() {
        this.isLoading = true; 
        this.error = null; 
        getNewJobPostings()
            .then(result => {
                if (result.length === 0) {
                    this.error = 'No job postings found.';
                    this.jobPostings = []; 
                } else {
                    this.jobPostings = result.map(job => ({
                        ...job,
                        url: job.url
                    }));
                    this.error = null;
                }
                this.isLoading = false; 
            })
            .catch(error => {
                this.error = 'An error occurred while retrieving job postings.';
                console.error('Error fetching job postings:', error);
                this.isLoading = false; 
                this.jobPostings = []; 
            });
    }

    handleRowSelection(event) {
        this.selectedJobs = event.detail.selectedRows;
    }

    handleSaveSelectedJobs() {
        if (this.selectedJobs.length > 0) {
            saveSelectedJobs({ jobs: this.selectedJobs })
                .then(() => {
                    this.error = null;
                    this.showToast('Success', 'Jobs saved successfully!', 'success');
                })
                .catch(error => {
                    this.error = 'Error saving jobs.';
                    console.error('Error saving jobs:', error);
                    this.showToast('Error', 'Error saving jobs.', 'error');
                });
        } else {
            this.error = 'Please select at least one job to save.';
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}