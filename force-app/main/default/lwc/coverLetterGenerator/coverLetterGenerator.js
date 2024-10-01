import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import COMPANY_FIELD from '@salesforce/schema/Job_Application__c.Company__c';
import POSITION_FIELD from '@salesforce/schema/Job_Application__c.Position_Title__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Job_Application__c.Description__c';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import callOpenAIApi from '@salesforce/apex/ExternalApiService.callOpenAIApi';

// Fields to retrieve from the Job Application record
const FIELDS = [
  COMPANY_FIELD,
  POSITION_FIELD,
  DESCRIPTION_FIELD,
  `Company__c.${ACCOUNT_NAME_FIELD.fieldApiName}` // Retrieve Account Name through the Company__c relationship
];

export default class JobApplicationCoverLetter extends LightningElement {
    @api recordId; // ID of the Job Application record
    @track coverLetter; 
    @track isLoading = false;

    // Wire service to get the Job Application fields
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    jobApplication;
    @wire(getRecord, { recordId: '$companyId', fields: [ACCOUNT_NAME_FIELD] })
    account;

    get companyId() {
      return getFieldValue(this.jobApplication.data, COMPANY_FIELD);
    }

    get companyName() {
      return getFieldValue(this.account.data, ACCOUNT_NAME_FIELD);
    }

    get positionTitle() {
      return getFieldValue(this.jobApplication.data, POSITION_FIELD);
    }

    get jobDescription() {
      return getFieldValue(this.jobApplication.data, DESCRIPTION_FIELD);
    }

    wiredJobApplication({ error, data }) {
        if (data) {
            this.positionTitle = data.fields.Position_Title__c.value;
            this.jobDescription = data.fields.Description__c.value;
        } else if (error) {
            this.showNotification('Error', 'Failed to load job application data', 'error');
        }
    }

    // Method to handle the "Generate Cover Letter" button click
    async handleGenerateClick() {
        this.isLoading = true;
        try {
            const requestBody = {
                messages: [{"role": "user", "content": `Write a professional cover letter for the following job position:\n\nCompany: ${this.companyName}\nPosition: ${this.positionTitle}\nDescription: ${this.jobDescription}. The tone should be friendly and casual. Please do not include any of the formal cover letter heading contact information like address, phone number, email, etc. Your response should skip all of that and start with the part that addresses the receiver of the letter.`}],
                max_tokens: 500,
                temperature: 0.7
            };

            const response = await callOpenAIApi({ body: requestBody });
            this.coverLetter = response.choices[0].message.content.trim(); // Set the cover letter
            this.showNotification('Success', 'Cover letter generated successfully', 'success');
        } catch (error) {
            console.error('Error generating cover letter: ', error);
            this.showNotification('Error', 'Failed to generate cover letter', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // Method to make the OpenAI API callout
    async fetchFromOpenAI(requestBody) {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`
            },
            body: JSON.stringify({
                model: 'gpt-4o-mini', 
                ...requestBody
            })
        });

        if (!response.ok) {
            throw new Error('Failed to fetch from OpenAI API');
        }

        return await response.json();
    }

    // Helper method to show toast notifications
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(evt);
    }
}
