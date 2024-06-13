![QIME Logo](/images/QIME-Logo.png)

# QIME - Quickbooks Integrations Made Easy

A free, open-source Salesforce -> Quickbooks Online integration.

## Package

Please use the following urls to install the latest version:

- [Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tDo000000Hysu)
- [Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tDo000000Hysu)

## Features

- Create customers in Quickbooks from accounts in Salesforce
- Create invoices in Salesforce and sync to Quickbooks online
- Sync Invoices from Quickbooks to Salesforce
- Sync Payments from Quickbooks to Salesforce
- Sync Customers from Quickbooks to Salesforce
- Sync Invoice Terms from Quickbooks to Salesforce
- Ready To Use Dashboards

## Requirements

- Enterprise Edition is required

## Configure

Please see my [write-up](https://www.1sync.co/integrate-quickbooks-salesforce) to learn how to configure this inside your org. Additionally, you can see a visual tutorial on [youtube](https://youtu.be/ZRwzeuJRmPg).

## Dashbaord

See the status of invoices, payments, and more with the QIME Dashboard

![QIME Dashboard](/images/dashboard.png)

## Streamlined Setup

Understand what part of the setup page you are at with the Setup helper

![QIME Setup Checklist](/images/setup-checklist.png)

## Manage Scheduled Jobs

Manage the syncing of invoices, payments, and terms with the scheduled job manager.

![QIME Scheduled Jobs](/images/manage-scheduled-jobs.png)

## Dependencies

QIME uses the [Metadata API](https://github.com/certinia/apex-mdapi) to help query and create metadata through Apex.
