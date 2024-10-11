import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SALARY_FIELD from '@salesforce/schema/Job_Application__c.Salary__c';

export default class SalaryCalculator extends LightningElement {
    @api recordId;
    @track salary = 0;
    @track calculations = {
        federalTax: '0.00',
        medicare: '0.00',
        socialSecurity: '0.00',
        takeHome: '0.00',
        yearly: '0.00',
        sixMonths: '0.00',
        monthly: '0.00',
        biWeekly: '0.00'
    };

    @wire(getRecord, { recordId: '$recordId', fields: [SALARY_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.salary = getFieldValue(data, SALARY_FIELD) || 0;
            this.calculateTakeHome();
        } else if (error) {
            console.error('Error loading record', error);
        }
    }

    formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });

    handleSalaryChange(event) {
        const inputValue = event.target.value;
        this.salary = inputValue === '' ? 0 : parseFloat(inputValue);
        this.calculateTakeHome();
    }

    calculateTakeHome() {
        const salary = this.salary;
        const federalTax = salary * 0.22;
        const medicare = salary * 0.0145;
        const socialSecurity = Math.min(salary * 0.062, 9114);
        const takeHome = salary - federalTax - medicare - socialSecurity;

        this.calculations = {
            federalTax: this.formatter.format(federalTax),
            medicare: this.formatter.format(medicare),
            socialSecurity: this.formatter.format(socialSecurity),
            takeHome: this.formatter.format(takeHome),
            yearly: this.formatter.format(takeHome),
            sixMonths: this.formatter.format(takeHome / 2),
            monthly: this.formatter.format(takeHome / 12),
            biWeekly: this.formatter.format(takeHome / 26)
        };
    }

    get formattedSalary() {
        return this.formatter.format(this.salary);
    }
}