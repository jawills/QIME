global class QBItemQueueable implements Queueable, Database.AllowsCallouts {
  Integer currentCount;
  Integer totalCount;
  Integer iteratorSize;
  Integer stackDepth;

  global QBItemQueueable(
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
      totalCount = QBMap.getCount(QBCallout.getItemCount());
    }
    String query =
      'select * from Item MAXRESULTS ' +
      String.valueOf(this.iteratorSize) +
      ' STARTPOSITION ' +
      String.valueOf(this.currentCount);
    QBItemQueryJSON res = QBCallout.queryItems(query);
    List<Product2> returnList = QBMap.mapItemsToProducts(res);

    QIMEUtil.printResult(Database.upsert(returnList, Product2.QB_Id__c, false));
    this.currentCount += this.iteratorSize;
    if (this.currentCount < this.totalCount) {
      System.enqueueJob(
        new QBItemQueueable(
          currentCount,
          totalCount,
          iteratorSize,
          this.stackDepth++
        )
      );
    }
  }
}