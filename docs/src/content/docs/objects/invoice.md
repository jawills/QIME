---
title: Invoice
description: A reference page in my new Starlight docs site.
---

## Syncing Invoices

Next, we will cover how to sync invoices between QuickBooks and Salesforce. There are a few things that need to be configured before syncing with the two systems. These are:

- Linking products between QuickBooks and Salesforce
- Setting up the invoice terms



## Syncing Terms

Invoice terms are unique per instance of QuickBooks. Companies can also add additional custom invoice terms within QuickBooks. Thus, we need a way to sync the terms between environments. To do this, there are two places that the invoice terms are stored under:

- `Terms` custom field on the `Invoice` object.
- `QB Terms` custom setting to store the id mapping.

The `Terms` picklist on the `Invoice` object allows companies to show what terms are available to sync, while the `QB Terms` custom setting syncs all terms object stored within QuickBooks.

To add invoice terms:

1. Go to `Setup` -> `Object Manager`
2. Find the `Invoice` object
3. Find the `Terms` field under the `Fields & Relationships` section
4. Under the values section, add the terms that will be available to map to invoices.

To sync invoice term IDs:

1. Open the Developer Console
2. Run the following code snippet:

```apex
qime.QBTermBatch batch= new qime.QBTermBatch();
Database.executeBatch(batch, 50);
```

## Syncing Invoices from QBO -> Salesforce

Syncing invoices from QuickBooks to Salesforce is essential for any QuickBooks integration. This allows data like payment date, balance due, and more to be synced with Salesforce, even if the invoice data is originating from Salesforce. First, let's take a look at how fields from QuickBooks are mapped to Salesforce.

| QuickBooks Field             | Salesforce Label         | Salesforce API Name                 |
| ---------------------------- | ------------------------ | ----------------------------------- |
| AllowOnlineACHPayment        | Allow Online ACH Payment | `qime__Allow_Online_ACH_Payment__c` |
| AllowOnlineCreditCardPayment | Allow Online CC Payment  | `qime__Allow_Online_CC_Payment__c`  |
| AutoDocNumber                | True\*                   | `True`                              |
| TotalTax                     | Tax                      | `qime__tax__c`                      |
| BillEmail                    | Emails                   | `qime__emails__c`                   |
| Customer Id                  | Customer Id              | `qime__Customer_Id__c`              |
| SyncToken                    | QB SyncToken             | `qime__QB_SyncToken__c`             |
| DocNumber                    | Document Number          | `qime__Document_Number__c`          |
| DocNumber                    | Name                     | `'INV-' + qime__Document_Number__c` |
| Txn Date                     | Transaction Date         | `qime__Transaction_Date__c`         |
| BCC Emails                   | BCC Emails               | `qime__bcc_emails__c`               |
| CC Emails                    | CC Emails                | `qime__cc_emails__c`                |
| Balance                      | Balance                  | `qime__Balance__c`                  |
| Terms                        | Terms                    | `qime__Terms__c`                    |
| Private Note                 | Message On Statement     | `Message_on_Statement__c`           |
| Delivery TIme                | Delivery Time            | `qime__Delivery_Time__c`            |
| Due Date                     | Due Date                 | `qime__Due_Date__c`                 |
| Total                        | Total                    | `qime__Total__c`                    |
| Memo                         | Memo                     | `qime__Memo__c`                     |

\* Value is hard-coded

## Schedule Invoice Sync From QuickBooks -> Salesforce

Invoices can be brought over hourly. To schedule Invoices syncing, perform the following:

1. Open the `Developer Console`
2. Run the following code snippet

```apex
System.schedule('QB Invoice Sync XX:00', '0 0 * * * ?', new qime.QBInvoiceBatch());
```

This will sync invoices from QuickBooks to Salesforce at the top of every hour.

## Sync All Invoices From QuickBooks -> Salesforce

During an initial setup, it is advised to sync all invoices from QuickBooks to Salesforce. To bring all invoices from QuickBooks to Salesforce, perform the following:

1. Open the `Developer Console`
2. Run the following code snippet

```apex
System.enqueueJob(new qime.QBInvoiceQueueable(0, 0, 50, 0));
```
