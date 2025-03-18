---
title: Customers
description: How to sync customers between Quickbooks and Salesforce
---

## Syncing Customers

One of the objects that is essential to be linked is the `Customer` object in QuickBooks. All accounting entities within QuickBooks are linked to customers. This means that accounts in Salesforce need to be linked to customers in QuickBooks. Most implementations will need to account for creating new customers, and syncing existing customers to accounts.

### Creating New Customers from Accounts

If you are starting with a fresh account, and the customer does not exist inside of QuickBooks, this is the easiest path to push data. There is an action to create new customers in QB from Salesforce accounts. To add this to the page layout:

1. Go to `Setup` → `Object Manager`
2. Navigate to `Account`
3. Select `Page Layouts` and open the desired page layout
4. In the `Mobile & Lightning Actions` find the `Push to QB` action and add this to the actions section.

From here, just press `Push to QB` on any account that needs to be pushed to QuickBooks.

To see how your Salesforce fields are mapped to QuickBooks Customers, please view the mapping table below

| QuickBooks Field                | Salesforce Label     | Salesforce API Name             |
| ------------------------------- | -------------------- | ------------------------------- |
| Active                          | True\*               | `True`                          |
| Billing Address Line 1          | Billing Street       | `BillingStreet`                 |
| Billing Address City            | Billing City         | `BillingCity`                   |
| Billing CountrySubDivisionCode  | Billing State        | `BillingState`                  |
| Billing Country                 | Billing Country      | `BillingCountry`                |
| Billing PostalCode              | Billing PostalCode   | `BillingPostalCode`             |
| CompanyName                     | Account Name         | `Name`                          |
| DisplayName                     | Account Name         | `Name`                          |
| FreeFormNumber                  | Phone                | `Phone`                         |
| IsProject                       | False\*              | `False`                         |
| Id                              | QB Id                | `qime__QB_ID__c`                |
| Job                             | False\*              | `False`                         |
| PrintOnCheckName                | Account Name         | `Name`                          |
| ResaleNum                       | Resale Number        | `qime__Resale_Number__c`        |
| SyncToken                       | SyncToken            | `qime__QB_SyncToken__c`         |
| Shipping Address Line 1         | Shipping Street      | `ShippingStreet`                |
| Shipping Address City           | Shipping City        | `ShippingCity`                  |
| Shipping CountrySubDivisionCode | Shipping State       | `ShippingState`                 |
| Shipping Country                | Shipping Country     | `ShippingCountry`               |
| Shipping PostalCode             | Shipping PostalCode  | `ShippingPostalCode`            |
| Taxable                         | Taxable              | `qime__Taxable__c`              |
| TaxExemptionReason              | Tax Exemption Reason | `qime__Tax_Exemption_Reason__c` |

\* Value is hard-coded

## Schedule Customer Sync From QuickBooks -> Salesforce

Customers can be brought over hourly. To schedule Customer syncing, perform the following:

1. Open the `Developer Console`
2. Run the following code snippet

```apex
System.schedule('QB Customer Sync XX:00', '0 0 * * * ?', new qime.QBCustomerBatch());
```

This will sync customers from QuickBooks to Salesforce at the top of every hour.

## Sync All Customers From QuickBooks -> Salesforce

During an initial setup, you can bring all customers from QuickBooks to Salesforce. To bring all invoices from QuickBooks to Salesforce, perform the following:

1. Open the `Developer Console`
2. Run the following code snippet

```apex
System.enqueueJob(new qime.QBCustomerQueueable(0, 0, 50, 0));
```

**Please keep in mind that this will overwrite your exsting data under the same `QB_Id__c` and will not match existing data.**

### Customer -> Account Mapping

If you are working with a fresh account, and the customer does not exist inside of QuickBooks, this is the easiest path to push data. There is an action to create new customers in QB from Salesforce accounts. To add this to the page layout:

1. Go to `Setup` → `Object Manager`
2. Navigate to `Account`
3. Select `Page Layouts` and open the desired page layout
4. In the `Mobile & Lightning Actions` find the `Pull from QB` action and add this to the actions section.

From here, just press `Pull from QB` on any account that needs to be pushed to QuickBooks.

To see how your Salesforce fields are mapped to QuickBooks Customers, please view the mapping table below

| QuickBooks Field                | Salesforce Label     | Salesforce API Name             |
| ------------------------------- | -------------------- | ------------------------------- |
| Active                          | True\*               | `True`                          |
| Billing Address Line 1          | Billing Street       | `BillingStreet`                 |
| Billing Address City            | Billing City         | `BillingCity`                   |
| Billing CountrySubDivisionCode  | Billing State        | `BillingState`                  |
| Billing Country                 | Billing Country      | `BillingCountry`                |
| Billing PostalCode              | Billing PostalCode   | `BillingPostalCode`             |
| CompanyName                     | Account Name         | `Name`                          |
| DisplayName                     | Account Name         | `Name`                          |
| FreeFormNumber                  | Phone                | `Phone`                         |
| IsProject                       | False\*              | `False`                         |
| Id                              | QB Id                | `qime__QB_ID__c`                |
| Job                             | False\*              | `False`                         |
| PrintOnCheckName                | Account Name         | `Name`                          |
| ResaleNum                       | Resale Number        | `qime__Resale_Number__c`        |
| SyncToken                       | SyncToken            | `qime__QB_SyncToken__c`         |
| Shipping Address Line 1         | Shipping Street      | `ShippingStreet`                |
| Shipping Address City           | Shipping City        | `ShippingCity`                  |
| Shipping CountrySubDivisionCode | Shipping State       | `ShippingState`                 |
| Shipping Country                | Shipping Country     | `ShippingCountry`               |
| Shipping PostalCode             | Shipping PostalCode  | `ShippingPostalCode`            |
| Taxable                         | Taxable              | `qime__Taxable__c`              |
| TaxExemptionReason              | Tax Exemption Reason | `qime__Tax_Exemption_Reason__c` |

\* Value is hard-coded

### Mapping Existing Accounts and Customers

Mapping existing customers within 2 data sets can be a challenging and laborious effort. While it would be nice to be able to link this data automatically, there are too many edge cases to make this possible. If you are looking to sync the two databases, the general workflow is as follows:

1. Export data from both systems.
2. Use `VLOOKUP` in an Excel sheet to match the databases on fields like name and email.
3. Update the `qime__QB_Id__c` field in Salesforce using the newly merged data.

If you are interested in a service like this, reach out to me [here](https://1sync.co/contact)
