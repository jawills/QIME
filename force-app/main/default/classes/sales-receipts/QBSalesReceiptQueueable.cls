public class QBSalesReceiptQueueable implements Queueable, Database.AllowsCallouts {
  Integer currentCount;
  Integer totalCount;
  Integer iteratorSize;
  Integer stackDepth;
  public QBSalesReceiptQueueable(
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

  public void execute(QueueableContext context) {
    if (totalCount == 0) {
      totalCount = QBMap.getCount(QBCallout.getSalesReceiptCount());
    }
    String query =
      'select * from SalesReceipt MAXRESULTS ' +
      String.valueOf(this.iteratorSize) +
      ' STARTPOSITION ' +
      String.valueOf(this.currentCount);

    List<SObject> returnList = QBSalesReceiptHelper.getSalesReceipts(query);
    QBSalesReceiptHelper.updateObjects(returnList);

    this.currentCount += this.iteratorSize;
    if (this.currentCount < this.totalCount) {
      System.enqueueJob(
        new QBSalesReceiptQueueable(
          currentCount,
          totalCount,
          iteratorSize,
          stackDepth++
        )
      );
    }
  }
}
