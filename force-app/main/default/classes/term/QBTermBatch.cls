global class QBTermBatch implements Database.Batchable<sobject>,Database.AllowsCallouts, Schedulable{
    global void execute(SchedulableContext SC){
        QBTermBatch batch= new QBTermBatch();
        Database.executeBatch(batch, 50);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator('SELECT Id FROM Account LIMIT 1');
    }
    
    global void Execute(Database.BatchableContext BC,List<Account> accList){
        QBTermJSON queryJson = QBCallout.queryTerms();
        List<qime__QB_Term__c> terms = QBMap.mapTermsQuery(queryJson);
        Database.upsert(terms, qime__QB_Term__c.qime__QB_Id__c, false);
    } 
    global void finish(Database.BatchableContext BC){
        System.debug('Finished');
    }
    
}