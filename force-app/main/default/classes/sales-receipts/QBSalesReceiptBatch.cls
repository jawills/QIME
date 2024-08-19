global class QBSalesReceiptBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Schedulable {
  global void execute(SchedulableContext SC) {
    QBSalesReceiptBatch batch = new QBSalesReceiptBatch();
    Database.executeBatch(batch);
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator('SELECT Id FROM Account Limit 1');
  }

  global void Execute(Database.BatchableContext BC, List<Account> accList) {
    String query =
      'SELECT * FROM SalesReceipt WHERE Metadata.LastUpdatedTime > \'' +
      String.valueOf(
        Datetime.now()
          .addhours(-1 * QIMEParameter.SALES_RECEIPT_HOURS_LOOKBACK)
          .formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
      ) +
      '\'';
    List<SObject> returnList = QBSalesReceiptHelper.getSalesReceipts(query);
    QBSalesReceiptHelper.updateObjects(returnList);
  }

  global void finish(Database.BatchableContext BC) {
    System.debug('Finished');
  }
}
