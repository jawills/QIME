import { LightningElement, track, wire } from 'lwc';

import getSFAccounts from '@salesforce/apex/OverviewController.getSFAccounts';
import getSFInvoices from '@salesforce/apex/OverviewController.getSFInvoices';
import getSFPayments from '@salesforce/apex/OverviewController.getSFPayments';
import getQBCustomers from '@salesforce/apex/OverviewController.getQBCustomers';
import getQBInvoices from '@salesforce/apex/OverviewController.getQBInvoices';
import getQBPayments from '@salesforce/apex/OverviewController.getQBPayments';

export default class QimeOverview extends LightningElement {
   //Customers
    @track sfAccounts;
    @track sfAccountsLoading = true;
    @track qbAccounts;
    @track qbAccountsLoading = true;
    // Invoices
    @track sfInvoices;
    @track sfInvoicesLoading = true;
    @track qbInvoices;
    @track qbInvoicesLoading = true;
    //Payments
    @track sfPayments;
    @track sfPaymentsLoading = true;
    @track qbPayments;
    @track qbPaymentsLoading = true;

    // Get SF Data
    @wire (getSFAccounts)
    async mySFAccounts(result) {
      if (result.data !== undefined) {
        this.sfAccounts = result.data
        this.sfAccountsLoading = false;
      }
    }

    @wire (getSFInvoices)
    async mySFInvoices(result) {
      this.wiredData = result;
      if (result.data !== undefined ) {
        this.sfInvoices = result.data
        this.sfInvoicesLoading = false;
      }
    }

    @wire (getSFPayments)
    async mySFPayments(result) {
      this.wiredData = result;
      if (result.data !== undefined ) {
        this.sfPayments = result.data
        this.sfPaymentsLoading = false;
      }
    }

    //QB Getters
    @wire (getQBCustomers)
    async myQBCustomers(result) {
      if (result.data !== undefined) {
        this.qbAccounts = result.data
        this.qbAccountsLoading = false;
      }
    }

    @wire (getQBInvoices)
    async myQBInvoices(result) {
      this.wiredData = result;
      if (result.data !== undefined ) {
        this.qbInvoices = result.data
        this.qbInvoicesLoading = false;
      }
    }

    @wire (getQBPayments)
    async myQBPayments(result) {
      this.wiredData = result;
      if (result.data !== undefined ) {
        this.qbPayments = result.data
        this.qbPaymentsLoading = false;
      }
    }
}