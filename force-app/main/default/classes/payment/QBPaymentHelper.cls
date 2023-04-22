public class QBPaymentHelper {
    public static qime__Payment__c getPayment(Id pmtId){
        return [SELECT Id,
                    Name, 
                    QB_Id__c,
                    QB_SyncToken__c,
                    qime__Amount__c,
                    qime__Transaction_Date__c,
                    qime__customer_id__c,
                    qime__unapplied_amount__c
                FROM qime__Payment__c 
                WHERE Id =: pmtId];
    }
}