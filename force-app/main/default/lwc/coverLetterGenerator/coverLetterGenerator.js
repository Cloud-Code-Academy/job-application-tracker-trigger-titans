import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import COMPANY_FIELD from '@salesforce/schema/Job_Application__c.Company__c';
import POSITION_FIELD from '@salesforce/schema/Job_Application__c.Position_Title__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Job_Application__c.Description__c';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
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
    @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
    userInfo;

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

    get userName() {
      return this.userInfo.data ? this.userInfo.data.fields.Name.value : '';
    }

    // Method to handle the "Generate Cover Letter" button click
    async handleGenerateClick() {
        this.isLoading = true;
        try {
            const requestBody = {
                messages: [{"role": "user", "content": `Write a professional cover letter for the following job position:\n\nCompany: ${this.companyName}\nPosition: ${this.positionTitle}\nDescription: ${this.jobDescription}. The tone should be friendly and casual. Please do not include any of the formal cover letter heading contact information like address, phone number, email, etc. Your response should skip all of that and start with the part that addresses the receiver of the letter. My name is ${this.userName}`}],
                max_tokens: 500,
                temperature: 0.7,
                model: "gpt-4o-mini"
            };

            const response = await callOpenAIApi({ body: JSON.stringify(requestBody) });
            this.coverLetter = JSON.parse(response).choices[0].message.content.trim(); // Set the cover letter
            this.showNotification('Success', 'Cover letter generated successfully', 'success');
        } catch (error) {
            console.error('Error generating cover letter: ', error);
            this.showNotification('Error', 'Failed to generate cover letter', 'error');
        } finally {
            this.isLoading = false;
        }
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
