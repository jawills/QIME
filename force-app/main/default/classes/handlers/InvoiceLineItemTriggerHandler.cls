public class InvoiceLineItemTriggerHandler {
    public static void beforeUpdateHandler(List<qime__Invoice_Line_Item__c> ilis){
        linkProducts(ilis);
    }

    public static void beforeInsertHandler(List<qime__Invoice_Line_Item__c> ilis){
        linkProducts(ilis);
    }

    private static void linkProducts(List<qime__Invoice_Line_Item__c> ilis){
        Set<String> productQBIds = new Set<String>();
        for(qime__Invoice_Line_Item__c ili : ilis){
            if(String.isNotBlank(ili.qime__ItemRef_Id__c)){
                productQBIds.add(ili.qime__ItemRef_Id__c);
            }
        }

        List<Product2> products = [SELECT Id, qime__QB_Id__c 
                                    FROM Product2 
                                    WHERE qime__QB_Id__c in: new List<String>(productQBIds)];
        Map<String, Id> productMap = new Map<String, Id>();
        for(Product2 p : products){
            productMap.put(p.qime__QB_Id__c, p.Id);
        }

        for(qime__Invoice_Line_Item__c ili : ilis){
            if(String.isNotBlank(ili.qime__ItemRef_Id__c) && productMap.containsKey(ili.qime__ItemRef_Id__c)){
                ili.qime__Product__c = productMap.get(ili.qime__ItemRef_Id__c);
            }
        }
    }
}