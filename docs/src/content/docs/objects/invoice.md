---
title: Invoice
description: How to sync invoices from Quickbooks to Salesforce.
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

Invoices can be brought over hourly. To schedule Invoices syncing, use the `scheduled jobs` tab in the `QIME` app. To manually schedule, perform the following:

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

## Custom Fields

Custom fields can be set based on your business needs. To create a custom field, use the [following](https://developer.intuit.com/app/developer/qbo/docs/workflows/create-custom-fields) guide to create the desired custom field in QB. At this time the maximum custom fields supported is 3.

Now that the custom field is created, we need the custom field's id to link inside of Salesforce. The easiest way of retrieving the id is using Postman, and querying invoice endpoint. You will find a custom field definition like so:

```json
"CustomField": [
    {
        "DefinitionId": "1",
        "Name": "Test 123",
        "Type": "StringType",
        "StringValue": "Val"
    }
],
```

Take the `DefinitionId` field, and go to Salesforce -> Setup -> Custom Metadata -> QIME Config -> Default, and paste it in the `Custom Field 1 Id` field.

This can be done up to 3 times.

To add your own data to these fields, I reccomend using a flow to copy the data from a custom field e.g. `Sales_Rep__c` to the `QB_Custom_Field_1__c`. Please keep in mind that at this time QB only allows strings, so you must convert your custom field value to a string.

The following are the relationship between the Invoice Custom fields and metadata config:

| Invoice Field          | Config Id Field        |
| ---------------------- | ---------------------- |
| `QB_Custom_Field_1__c` | `Custom_Field_1_Id__c` |
| `QB_Custom_Field_2__c` | `Custom_Field_2_Id__c` |
| `QB_Custom_Field_3__c` | `Custom_Field_3_Id__c` |

## Setting A Tax Id

International companies need to specify a tax code, or will recieve the following error:

```
Make sure all your transactions have a GST/HST rate before you save
```

To use this feature, go to custom metadata -> QIME Config -> Default,

and ensure that `qime__Use_Tax_Id__c` is set to true.

Additionally, you will need a default tax id. This can be set under `qime__Default_Tax_Id__c`.

To see the default Id, the easiest way is to go to an account in SF and press `Pull from QB`, and read the `QB_Default_Tax_Code__c` field.

**NOTE: The integration will use the tax code set on the customer over the default code if it is present.**
