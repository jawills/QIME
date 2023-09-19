public class OpportunityHelper {

    public static List<SObject> mapInvoice(Opportunity o, List<OpportunityLineItem> olis){
        List<SObject> returnList = new List<SObject>();
        Invoice__c inv = new Invoice__c();
        List<Invoice_Line_Item__c> ilis = new List<Invoice_Line_Item__c>();
        inv.Name = 'INV-XXXX';
        inv.Opportunity__c = o.Id;
        inv.Subtotal__c = o.Amount;
        inv.Account__c = o.AccountId;
        inv.Transaction_Date__c = o.CloseDate;

        for(OpportunityLineItem oli : olis){
            Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
            ili.Amount__c = oli.UnitPrice;
            ili.Quantity__c = oli.Quantity;
            ili.LineNum__c = oli.SortOrder;
            ili.Product__c = oli.Product2Id;
            ilis.add(ili);
        }

        returnList.add(inv);
        returnList.addAll(ilis);
        return returnList;
    }

    public static Opportunity getOpportunity(Id oppId){
        return [SELECT Id, Name, CloseDate, StageName, Amount,Account.QB_Id__c,
                (SELECT Id, Product2Id, Product2.QB_Id__c, quantity, UnitPrice, ListPrice,SortOrder 
                    FROM OpportunityLineItems),
                (SELECT Id FROM Invoices__r) 
                FROM Opportunity 
                WHERE Id =: oppId];
    }
}