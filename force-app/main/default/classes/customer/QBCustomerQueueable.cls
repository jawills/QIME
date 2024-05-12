global class QBCustomerQueueable implements Queueable, Database.AllowsCallouts {
  Integer currentCount;
  Integer totalCount;
  Integer iteratorSize;
  Integer stackDepth;
  global QBCustomerQueueable(
    Integer currentCount,
    Integer totalCount,
    Integer iteratorSize,
    Integer stackDepth
  ) {
    this.currentCount = currentCount;
    this.totalCount = totalCount;
    this.iteratorSize = iteratorSize;
    this.stackDepth = stackDepth;
  }

  global void execute(QueueableContext context) {
    if (totalCount == 0) {
      totalCount = QBMap.getCount(QBCallout.getCustomerCount());
    }
    List<Account> accs = new List<Account>();
    String query =
      'select * from Customer MAXRESULTS ' +
      String.valueOf(this.iteratorSize) +
      ' STARTPOSITION ' +
      String.valueOf(this.currentCount);
    QBCustomerJSON res = QBCallout.queryCustomers(query);
    List<Account> returnList = QBMap.mapCustomersToAccounts(res);

    Database.upsert(returnList, Account.QB_Id__c, false);
    this.currentCount += this.iteratorSize;
    if (this.currentCount < this.totalCount) {
      System.enqueueJob(
        new QBCustomerQueueable(
          currentCount,
          totalCount,
          iteratorSize,
          stackDepth++
        )
      );
    }
  }
}
