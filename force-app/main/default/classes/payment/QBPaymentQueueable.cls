global class QBPaymentQueueable implements Queueable, Database.AllowsCallouts {
  Integer currentCount;
  Integer totalCount;
  Integer iteratorSize;
  Integer stackDepth;
  global QBPaymentQueueable(
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
      totalCount = QBMap.getCount(QBCallout.getPaymentCount());
    }
    String query =
      'select * from Payment MAXRESULTS ' +
      String.valueOf(this.iteratorSize) +
      ' STARTPOSITION ' +
      String.valueOf(this.currentCount);
    QBPaymentQueryJSON queryJson = QBCallout.queryPayments(query);
    List<Payment__c> payments = QBMap.mapPayments(queryJson);
    Database.UpsertResult[] upsertResults = Database.upsert(
      payments,
      Payment__c.qb_Id__c,
      false
    );
    for (Database.UpsertResult ur : upsertResults) {
      if (!ur.isSuccess()) {
        System.debug(ur.getErrors());
      }
    }
    this.currentCount += this.iteratorSize;
    if (this.currentCount < this.totalCount) {
      System.enqueueJob(
        new QBPaymentQueueable(
          currentCount,
          totalCount,
          iteratorSize,
          stackDepth++
        )
      );
    }
  }
}
