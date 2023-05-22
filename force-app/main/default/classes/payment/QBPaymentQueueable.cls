global class QBPaymentQueueable implements Queueable, Database.AllowsCallouts{
    Integer currentCount;
    Integer totalCount;
    Integer iteratorSize;
    Integer stackDepth;
    global QBPaymentQueueable(Integer currentCount, Integer totalCount, Integer iteratorSize, Integer stackDepth) {
        this.currentCount = currentCount;
        this.totalCount = totalCount;
        this.iteratorSize = iteratorSize;
        this.stackDepth = stackDepth;
    }

    global void execute(QueueableContext context) {
        if(totalCount == 0){
            totalCount = QBMap.getCount(QBCallout.getPaymentCount());
        }
        String query = 'select * from Payment MAXRESULTS '+ String.valueOf(this.iteratorSize) +' STARTPOSITION ' + String.valueOf(this.currentCount);
        QBPaymentQueryJSON queryJson = QBCallout.queryPayments(query);
        List<qime__Payment__c> payments = QBMap.mapPayments(queryJson);
        Database.update(payments, false);

        this.currentCount += this.iteratorSize;
        if(this.currentCount < this.totalCount){
            System.enqueueJob(new QBPaymentQueueable(currentCount, totalCount, iteratorSize, stackDepth ++));
        }
    }

}