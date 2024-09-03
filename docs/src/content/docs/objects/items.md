---
title: Items
description: How to sync items from Quickbooks to products in Salesforce.
---

## Syncing Products

Syncing products is essential to the QB linking if products in invoice line items are used in invoices. The products in QuickBooks can be linked to products in Salesforce, through the field `qime__QB_Id__c`. At a later release, this process of linking products will be simplified. At the time of writing, there is a good YouTube video on how to export products from QuickBooks to an excel sheet:

Once products with Ids are exported, perform the following to link QB products with SF Products:

1. Link products from QB to Products in QB using Excel
2. Upload QB Ids to SF

## Pushing Products From SF to QB

We can push Products to QB from SF. QB does not have the concept, of pricebooks, so we need to select one pricebook to store the pricing.

To sync products, we need the following configuration:

1. Pricebook with `qime__QB_Pricebook__c` set to `true`.
2. Pricebook Entry associated with the pricebook.

Additionally, every product needs to be tied to an income account. This is controlled with the `Income Account` field in Salesforce. The default `Services` account is used but more accounts can be added by adding values to this picklist.

From here, we can use the `Push to QB` button to sync an individual product.

### Syncing Multiple Products

With the above configuration, we can mark products as `qime__QB_Product__c` to `true` to flag products to push to QB.

From here, we can run the following code to push all products:

```java
qime.QBItemBatch batch = new qime.QBItemBatch();
Database.executeBatch(batch, 20);
```

This will push all products that meet the above criteria from SF to QB.

This also assumes that SF will overwrite data for every field except the following

- Qty On Hand
- Purchase Cost

### Product -> Item Mapping

| QuickBooks Field | Salesforce Label | Salesforce API Name                |
| ---------------- | ---------------- | ---------------------------------- |
| Id               | QB Id            | `Product2.qime__QB_Id__c`          |
| Name             | Name             | `Product2.Name`                    |
| Unit Price       | Unit Price       | `PricebookEntry.UnitPrice`         |
| Active           | Is Active        | `PricebookEntry.isActive`          |
| Type             | QB Type          | `Product2.qime__QB_Type__c`        |
| Income Account   | Income Account   | `Product2.qime__Income_Account__c` |
| Synctoken        | QB Synctoken     | `Product2.qime__QB_SyncToken__c`   |
| Qty On Hand      | Qty On Hand      | `Product2.qime__Qty_On_Hand__c`    |
| Purchase Cost    | Purchase Cost    | `Product2.qime__Purchase_Cost__c`  |

## Pulling Products From QB to SF

We can also pull all the products from QB to SF.

Run the following code to perform this:

```java
System.enqueueJob(new qime.QBItemQueueable(0, 0, 50, 0));
```

### Item -> Product Mapping

| QuickBooks Field | Salesforce Label | Salesforce API Name                |
| ---------------- | ---------------- | ---------------------------------- |
| Id               | QB Id            | `Product2.qime__QB_Id__c`          |
| Name             | Name             | `Product2.Name`                    |
| Type             | QB Type          | `Product2.qime__QB_Type__c`        |
| Income Account   | Income Account   | `Product2.qime__Income_Account__c` |
| Synctoken        | QB Synctoken     | `Product2.qime__QB_SyncToken__c`   |
| Qty On Hand      | Qty On Hand      | `Product2.qime__Qty_On_Hand__c`    |
| Purchase Cost    | Purchase Cost    | `Product2.qime__Purchase_Cost__c`  |

## Using only a 'Services' Line Item

Some companies do not want multiple line items on their invoices, and just use a simple `Services` product on the invoice. If you are looking to sync invoices with only a services line item, perform the following to have this configured:

### Getting the Product ID From QuickBooks

To get the product ID from an individual product

1. Go to `Settings` -> `Products and Services`
2. Find the desired product.
3. Click on the down arrow, and select `Run Report`
4. Copy the URL into a text editor.
5. Find the `item=` URL parameter and copy down the id.

### Configure in Salesforce

1. Go to `Setup` -> `Custom Metadata Types`
2. Go to `QIME Config`
3. Edit the `Default` record.
4. Use the following properties: 3. `Use Line Item` - `True` 4. `QB Product Id` - The product id from QB
5. Save the record.
