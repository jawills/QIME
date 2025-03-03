global class QBPaymentBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Schedulable {
  global void execute(SchedulableContext SC) {
    QBPaymentBatch batch = new QBPaymentBatch();
    Database.executeBatch(batch, 50);
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator('SELECT Id FROM Account LIMIT 1');
  }

  global void Execute(Database.BatchableContext BC, List<Account> accList) {
    String query =
      'select * from Payment WHERE Metadata.LastUpdatedTime > \'' +
      String.valueOf(
        Datetime.now()
          .addhours(-2)
          .formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
      ) +
      '\'';
    QBPaymentQueryJSON queryJson = QBCallout.queryPayments(query);
    List<Payment__c> payments = QBMap.mapPayments(queryJson);
    Database.UpsertResult[] upsertResults = Database.upsert(
      payments,
      Payment__c.qb_Id__c,
      false
    );
  }
  global void finish(Database.BatchableContext BC) {
    System.debug('Finished');
  }
}
