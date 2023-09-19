public class InvoiceLineItemTriggerHandler {
    
    /**
     * Before Update Trigger Handler
     * @param ilis Invoice Line Items from Trigger.new
     */
    public static void beforeUpdateHandler(List<Invoice_Line_Item__c> ilis){
        linkProducts(ilis);
    }

    /**
     * Before Insert Trigger Handler
     * @param ilis Invoice Line Items from Trigger.new
     */
    public static void beforeInsertHandler(List<Invoice_Line_Item__c> ilis){
        linkProducts(ilis);
    }

    /**
     * Link invoice line items to products based on product id in QBO
     * @param ilis Invoice Line Items from Trigger.new
     */
    private static void linkProducts(List<Invoice_Line_Item__c> ilis){
        Set<String> productQBIds = new Set<String>();
        for(Invoice_Line_Item__c ili : ilis){
            if(String.isNotBlank(ili.ItemRef_Id__c)){
                productQBIds.add(ili.ItemRef_Id__c);
            }
        }

        List<Product2> products = [SELECT Id, QB_Id__c 
                                    FROM Product2 
                                    WHERE QB_Id__c in: new List<String>(productQBIds)];
        Map<String, Id> productMap = new Map<String, Id>();
        for(Product2 p : products){
            productMap.put(p.QB_Id__c, p.Id);
        }
        for(Invoice_Line_Item__c ili : ilis){
            if(String.isNotBlank(ili.ItemRef_Id__c) && productMap.containsKey(ili.ItemRef_Id__c)){
                ili.Product__c = productMap.get(ili.ItemRef_Id__c);
            }
        }  
    }
}