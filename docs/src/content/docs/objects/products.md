---
title: Products
description: A reference page in my new Starlight docs site.
---


## Syncing Products

Syncing products is essential to the QB linking if products in invoice line items are used in invoices. The products in QuickBooks can be linked to products in Salesforce, through the field `qime__QB_Id__c`. At a later release, this process of linking products will be simplified. At the time of writing, there is a good YouTube video on how to export products from QuickBooks to an excel sheet:


Once products with Ids are exported, perform the following to link QB products with SF Products:

1. Link products from QB to Products in QB using Excel
2. Upload QB Ids to SF

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