public class InvoiceTriggerHandler {

    public static void beforeUpdateHandler(List<qime__Invoice__c> invoices){
        linkAccounts(invoices);
    }

    public static void beforeInsertHandler(List<qime__Invoice__c> invoices){
        linkAccounts(invoices);
    }

    private static void linkAccounts(List<qime__Invoice__c> invoices){
        Set<String> customerIdSet = new Set<String>();
        Map<String, Id> accountMap = new Map<String, Id>();
        for(qime__Invoice__c invoice : invoices){
            if(String.isNotBlank(invoice.qime__Customer_Id__c)){
                customerIdSet.add(invoice.qime__Customer_Id__c);
            }
        }
        
        List<Account> accounts = [SELECT Id, qime__QB_Id__c
                                    FROM Account 
                                    WHERE qime__QB_Id__c in: new List<String>(customerIdSet)];
        for(Account a : accounts){
            accountMap.put(a.qime__QB_Id__c, a.Id);
        }

        for(qime__Invoice__c invoice : invoices){
            if(String.isNotBlank(invoice?.qime__Customer_Id__c) 
                && accountMap.containsKey(invoice.qime__Customer_Id__c)){
                    invoice.qime__Account__c = accountMap.get(invoice.qime__Customer_Id__c);
                }
        }
    }
}