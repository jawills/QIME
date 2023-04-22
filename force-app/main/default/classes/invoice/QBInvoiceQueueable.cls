public class QBInvoiceQueueable implements Queueable, Database.AllowsCallouts{
    Integer currentCount;
    Integer totalCount;
    Integer iteratorSize;
    Integer stackDepth;
    public QBInvoiceQueueable(Integer currentCount, Integer totalCount, Integer iteratorSize, Integer stackDepth) {
        this.currentCount = currentCount;
        this.totalCount = totalCount;
        this.iteratorSize = iteratorSize;
        this.stackDepth = stackDepth;
    }

    public void execute(QueueableContext context) {
        if(totalCount == 0){
            totalCount = QBMap.getCount(QBCallout.getInvoiceCount());
        }
        String query = 'select * from Invoice MAXRESULTS '+ String.valueOf(this.iteratorSize) +' STARTPOSITION ' + String.valueOf(this.currentCount);
        QBInvoiceHelper.mapInvoices(query);

        this.currentCount += this.iteratorSize;
        if(this.currentCount < this.totalCount && !Test.isRunningTest()){
            System.enqueueJob(new QBInvoiceQueueable(currentCount, totalCount, iteratorSize, stackDepth ++));
        }
    }

}