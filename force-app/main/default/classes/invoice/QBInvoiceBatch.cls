global class QBInvoiceBatch implements Database.Batchable<sobject>,Database.AllowsCallouts, Schedulable{
    global void execute(SchedulableContext SC){
        QBInvoiceBatch batch= new QBInvoiceBatch();
        Database.executeBatch(batch);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator('SELECT Id FROM Account Limit 1');
    }
    
    global void Execute(Database.BatchableContext BC,List<Account> accList){
        String query = 'select * from Invoice WHERE Metadata.LastUpdatedTime > \'' + String.valueOf(Datetime.now().addhours(-2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'')) + '\'';
        QBInvoiceHelper.mapInvoices(query);        
    } 
    
    global void finish(Database.BatchableContext BC){
        System.debug('Finished');
    }
    
}