---
title: Payment
description: How to sync payments from Quickbooks to Salesforce.
---

## Schedule Payment Sync From QuickBooks to Salesforce

Payments need to be synced to Salesforce to not only get payment status and balance due, but also to see how much of a payment has been applied. The mapping document below describes how fields from QuickBooks map to the `payment` object in Salesofrce.

| QuickBooks Field | Salesforce Label | Salesforce API Name         |
| ---------------- | ---------------- | --------------------------- |
| Total Amt        | Amount           | `qime__Amount__c`           |
| Transaction Date | Transaction Date | `qime__Transaction_Date__c` |
| Customer Id      | Customer Id      | `qime__customer_id__c`      |
| Unapplied Amount | Unapplied Amount | `qime__unapplied_amount__c` |
| Id               | QB ID            | `qime__qb_Id__c`            |
| Sync Token       | QB SyncToken     | `qime__qb_SyncToken__c`     |

To schedule payments syncing, use the `scheduled jobs` tab in the `QIME` app. To manually schedule, perform the following:

1. Open the `Developer Console`
2. Run the following code snippet

```apex
System.schedule('QB Payment Sync XX:00', '0 0 * * * ?', new qime.QBPaymentBatch());
```

This will sync payments from QuickBooks to Salesforce at the top of every hour.

## Sync All Payments From QuickBooks -> Salesforce

During an initial setup, it is advised to sync all payments from QuickBooks to Salesforce. To bring all payments from QuickBooks to Salesforce, perform the following:

1. Open the `Developer Console`
2. Run the following code snippet

```apex
System.enqueueJob(new qime.QBPaymentQueueable(0, 0, 50, 0));
```
