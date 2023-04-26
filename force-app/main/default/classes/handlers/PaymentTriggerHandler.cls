public class PaymentTriggerHandler {

    public static void beforeUpdateHandler(List<qime__Payment__c> payments){
        linkAccounts(payments);
    }

    public static void beforeInsertHandler(List<qime__Payment__c> payments){
        linkAccounts(payments);
    }

    private static void linkAccounts(List<qime__Payment__c> payments){
        Set<String> customerIdSet = new Set<String>();
        Map<String, Id> accountMap = new Map<String, Id>();
        for(qime__Payment__c payment : payments){
            if(String.isNotBlank(payment.qime__Customer_Id__c)){
                customerIdSet.add(payment.qime__Customer_Id__c);
            }
        }
        
        List<Account> accounts = [SELECT Id, qime__QB_Id__c
                                    FROM Account 
                                    WHERE qime__QB_Id__c in: new List<String>(customerIdSet)];
        for(Account a : accounts){
            accountMap.put(a.qime__QB_Id__c, a.Id);
        }

        for(qime__Payment__c payment : payments){
            if(String.isNotBlank(payment?.qime__Customer_Id__c) 
                && accountMap.containsKey(payment.qime__Customer_Id__c)){
                    payment.qime__Account__c = accountMap.get(payment.qime__Customer_Id__c);
                }
        }
    }
}