public class PaymentTriggerHandler {

    /**
     * Before Update Trigger Handler
     * @param payments Payments from Trigger.new
     */
    public static void beforeUpdateHandler(List<Payment__c> payments){
        linkAccounts(payments);
    }

    /**
     * Before Insert Trigger Handler
     * @param payments Payments from Trigger.new
     */
    public static void beforeInsertHandler(List<Payment__c> payments){
        linkAccounts(payments);
    }

    /**
     * Link payments to accounts based on customer id
     * @param payments Payments from Trigger.new
     */
    private static void linkAccounts(List<Payment__c> payments){
        Set<String> customerIdSet = new Set<String>();
        Map<String, Id> accountMap = new Map<String, Id>();
        for(Payment__c payment : payments){
            if(String.isNotBlank(payment.Customer_Id__c)){
                customerIdSet.add(payment.Customer_Id__c);
            }
        }
        
        List<Account> accounts = [SELECT Id, QB_Id__c
                                    FROM Account 
                                    WHERE QB_Id__c in: new List<String>(customerIdSet)];
        for(Account a : accounts){
            accountMap.put(a.QB_Id__c, a.Id);
        }

        for(Payment__c payment : payments){
            if(String.isNotBlank(payment?.Customer_Id__c) 
                && accountMap.containsKey(payment.Customer_Id__c)){
                    payment.Account__c = accountMap.get(payment.Customer_Id__c);
                }
        }
    }
}