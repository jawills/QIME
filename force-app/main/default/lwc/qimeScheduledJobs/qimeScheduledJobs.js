import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Scheduled Jobs
import getScheduledJobs from "@salesforce/apex/SchedulerController.getScheduledJobs";
import scheduleInvoiceJob from "@salesforce/apex/SchedulerController.scheduleInvoiceJob";
import schedulePaymentJob from "@salesforce/apex/SchedulerController.schedulePaymentJob";
import scheduleTermJob from "@salesforce/apex/SchedulerController.scheduleTermJob";
import scheduleCustomerJob from "@salesforce/apex/SchedulerController.scheduleCustomerJob";
import scheduleSalesReceiptJob from "@salesforce/apex/SchedulerController.scheduleSalesReceiptJob";

import unscheduleInvoiceJob from "@salesforce/apex/SchedulerController.unscheduleInvoiceJob";
import unschedulePaymentJob from "@salesforce/apex/SchedulerController.unschedulePaymentJob";
import unscheduleTermJob from "@salesforce/apex/SchedulerController.unscheduleTermJob";
import unscheduleCustomerJob from "@salesforce/apex/SchedulerController.unscheduleCustomerJob";
import unscheduleSalesReceiptJob from "@salesforce/apex/SchedulerController.unscheduleSalesReceiptJob";

export default class QimeScheduledJobs extends LightningElement {
  title = "QIME Scheduled Jobs";
  showLoadingSpinner = false;

  // ScheduledJobs data
  records;

  columns = [
    { fieldName: "scheduledObject", label: "Scheduled Object", type: "text" },
    {
      fieldName: "scheduleFrequency",
      label: "Schedule Frequency",
      type: "text"
    },
    { fieldName: "isScheduled", label: "Currently Scheduled", type: "boolean" },
    {
      type: "action",
      typeAttributes: { rowActions: this.getRowActions }
    }
  ];

  connectedCallback() {
    this.loadScheduledJobs();
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    /* eslint-disable-next-line default-case */
    switch (actionName) {
      case "schedule":
        this.scheduleCurrentRecord(row);
        break;
      case "unschedule":
        this.unscheduleCurrentRecord(row);
        break;
    }

    // Set manual sleep to await for scheduled job to be scheduled
    // @TODO make this tied to the creation of the job and not arbitrary value
    this.showLoadingSpinner = true;
    this.timeoutId = setTimeout(this.loadScheduledJobs.bind(this), 1000);
  }

  loadScheduledJobs() {
    this.showLoadingSpinner = true;
    getScheduledJobs()
      .then((scheduledJobResult) => {
        this.buildRows(scheduledJobResult);

        this.showLoadingSpinner = false;
      })
      .catch(this._handleError);
  }

  scheduleCurrentRecord(row) {
    switch (row.scheduledObject) {
      case "Invoices":
        scheduleInvoiceJob();
        break;
      case "Payments":
        schedulePaymentJob();
        break;
      case "Terms":
        scheduleTermJob();
        break;
      case "Customers":
        scheduleCustomerJob();
        break;
      case "Sales Receipts":
        scheduleSalesReceiptJob();
        break;
    }
  }

  unscheduleCurrentRecord(row) {
    switch (row.scheduledObject) {
      case "Invoices":
        unscheduleInvoiceJob();
        break;
      case "Payments":
        unschedulePaymentJob();
        break;
      case "Terms":
        unscheduleTermJob();
        break;
      case "Customers":
        unscheduleCustomerJob();
        break;
      case "Sales Receipts":
        unscheduleSalesReceiptJob();
        break;
    }
  }

  buildRows(scheduledJobResult) {
    console.log(scheduledJobResult);
    const rows = [];
    let invoiceRow = {
      scheduledObject: "Invoices",
      scheduleFrequency: "Hourly",
      isScheduled: scheduledJobResult.invoiceJob
    };
    rows.push(invoiceRow);
    let paymentRow = {
      scheduledObject: "Payments",
      scheduleFrequency: "Hourly",
      isScheduled: scheduledJobResult.paymentJob
    };
    rows.push(paymentRow);
    let termRow = {
      scheduledObject: "Terms",
      scheduleFrequency: "Hourly",
      isScheduled: scheduledJobResult.termJob
    };
    rows.push(termRow);

    let customerRow = {
      scheduledObject: "Customers",
      scheduleFrequency: "Hourly",
      isScheduled: scheduledJobResult.customerJob
    };
    rows.push(customerRow);

    let salesReceiptRow = {
      scheduledObject: "Sales Receipts",
      scheduleFrequency: "Hourly",
      isScheduled: scheduledJobResult.salesReceiptJob
    };
    rows.push(salesReceiptRow);

    this.records = rows;
  }

  getRowActions(row, doneCallback) {
    if (row.isScheduled === false) {
      doneCallback([{ label: "Schedule", name: "schedule" }]);
    }
    if (row.isScheduled === true) {
      doneCallback([{ label: "Unschedule", name: "unschedule" }]);
    }
  }

  _handleError = (error) => {
    const errorMessage = error.body ? error.body.message : error.message;
    /* eslint-disable-next-line no-console */
    console.error(errorMessage, error);
    this.dispatchEvent(
      new ShowToastEvent({
        mode: "sticky",
        title: errorMessage,
        variant: "error"
      })
    );
    this.showLoadingSpinner = false;
  };
}