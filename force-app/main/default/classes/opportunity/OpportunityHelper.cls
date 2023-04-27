public class OpportunityHelper {

    public static List<SObject> mapInvoice(Opportunity o, List<OpportunityLineItem> olis){
        List<SObject> returnList = new List<SObject>();
        qime__Invoice__c inv = new qime__Invoice__c();
        List<qime__Invoice_Line_Item__c> ilis = new List<qime__Invoice_Line_Item__c>();
        inv.Name = 'INV-XXXX';
        inv.qime__Opportunity__c = o.Id;
        inv.qime__Subtotal__c = o.Amount;
        inv.qime__Account__c = o.AccountId;
        inv.qime__Transaction_Date__c = o.CloseDate;

        for(OpportunityLineItem oli : olis){
            qime__Invoice_Line_Item__c ili = new qime__Invoice_Line_Item__c();
            ili.qime__Amount__c = oli.UnitPrice;
            ili.qime__Quantity__c = oli.Quantity;
            ili.qime__LineNum__c = oli.SortOrder;
            ili.qime__Product__c = oli.Product2Id;
            ilis.add(ili);
        }

        returnList.add(inv);
        returnList.addAll(ilis);
        return returnList;
    }

    public static Opportunity getOpportunity(Id oppId){
        return [SELECT Id, Name, CloseDate, StageName, Amount,Account.qime__QB_Id__c,
                (SELECT Id, Product2Id, Product2.qime__QB_Id__c, quantity, UnitPrice, ListPrice,SortOrder 
                    FROM OpportunityLineItems),
                (SELECT Id FROM qime__Invoices__r) 
                FROM Opportunity 
                WHERE Id =: oppId];
    }
}