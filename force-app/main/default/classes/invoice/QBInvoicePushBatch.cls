global class QBInvoicePushBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Schedulable {
  global void execute(SchedulableContext SC) {
    QBInvoicePushBatch batch = new QBInvoicePushBatch();
    Database.executeBatch(batch, 50);
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          Due_Date__c,
          Subtotal__c,
          Balance__c,
          Name,
          QB_Id__c,
          Memo__c,
          Opportunity__r.Account.QB_Id__c,
          Opportunity__r.AccountId,
          QB_SyncToken__c,
          Terms__c,
          Tax__c,
          emails__c,
          cc_emails__c,
          bcc_emails__c,
          Shipping_Handling__c,
          Allow_Online_ACH_Payment__c,
          Allow_Online_CC_Payment__c,
          Bill_City__c,
          Bill_Street__c,
          Bill_Suite__c,
          Bill_State__c,
          Bill_Zip__c,
          Bill_Country__c,
          Ship_City__c,
          Ship_Street__c,
          Ship_Suite__c,
          Ship_Zip__c,
          Ship_State__c,
          Ship_Country__c,
          QB_Custom_Field_1__c,
          QB_Custom_Field_2__c,
          QB_Custom_Field_3__c,
          Account__r.QB_Default_Tax_Code__c,
          (
            SELECT
              Id,
              Unit_Price__c,
              Quantity__c,
              Amount__c,
              ItemRef_Id__c,
              QB_Id__c,
              Product__r.QB_Id__c,
              Product__r.QB_Description__c,
              LineNum__c,
              Product__c,
              Description__c,
              Taxable__c,
              Service_Date__c
            FROM Invoice_Line_Items__r
          )
        FROM Invoice__c
        WHERE QB_ID__c = NULL
      ]
    );
  }

  global void Execute(Database.BatchableContext BC, List<Invoice__c> invList) {
    QBInvoiceHelper.createOrUpdateInvoices(invList);
  }

  global void finish(Database.BatchableContext BC) {
    System.debug('Finished');
  }
}
