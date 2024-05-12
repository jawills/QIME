global class QBCustomerBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Schedulable {
  global void execute(SchedulableContext SC) {
    QBCustomerBatch batch = new QBCustomerBatch();
    Database.executeBatch(batch);
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator('SELECT Id FROM Account Limit 1');
  }

  global void Execute(Database.BatchableContext BC, List<Account> accList) {
    String query =
      'select * from Customer WHERE Metadata.LastUpdatedTime > \'' +
      String.valueOf(
        Datetime.now()
          .addhours(-1)
          .formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')
      ) +
      '\'';
    QBCustomerJSON res = QBCallout.queryCustomers(query);
    List<Account> returnList = QBMap.mapCustomersToAccounts(res);

    Database.upsert(returnList, Account.QB_Id__c, false);
  }

  global void finish(Database.BatchableContext BC) {
    System.debug('Finished');
  }
}
