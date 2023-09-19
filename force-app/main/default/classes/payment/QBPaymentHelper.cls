public class QBPaymentHelper {
    public static Payment__c getPayment(Id pmtId){
        return [SELECT Id,
                    Name, 
                    QB_Id__c,
                    QB_SyncToken__c,
                    Amount__c,
                    Transaction_Date__c,
                    customer_id__c,
                    unapplied_amount__c
                FROM Payment__c 
                WHERE Id =: pmtId];
    }
}