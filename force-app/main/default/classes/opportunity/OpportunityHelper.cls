public with sharing class OpportunityHelper {

    public static List<SObject> mapInvoice(Opportunity o, List<OpportunityLineItem> olis){
        List<SObject> returnList = new List<SObject>();
        Invoice__c inv = new Invoice__c();
        List<Invoice_Line_Item__c> ilis = new List<Invoice_Line_Item__c>();
        inv.Name = 'INV-XXXX';
        inv.Opportunity__c = o.Id;
        inv.Subtotal__c = o.Amount;
        inv.Account__c = o.AccountId;
        inv.Transaction_Date__c = o.CloseDate;
        
        returnList.add(inv);
        if(olis == null){
            return returnList;
        }

        returnList.addAll(mapOLItoILI(olis));
        return returnList;
    }

    public static List<Invoice_Line_Item__c> mapOLItoILI(List<OpportunityLineItem> olis){
        List<Invoice_Line_Item__c> ilis = new List<Invoice_Line_Item__c>();

        for(OpportunityLineItem oli : olis){
            Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
            ili.Amount__c = oli.TotalPrice;
            ili.Unit_Price__c = oli.UnitPrice;
            ili.Quantity__c = oli.Quantity;
            ili.LineNum__c = oli.SortOrder;
            ili.Product__c = oli.Product2Id;
            ili.Opportunity_Product__c = oli.Id;
            //Seperate Id is useful to check for upsert / delete
            ili.qime__Opportunity_Product_Id__c = oli.Id;
            ilis.add(ili);
        }
        return ilis;
    }

    public static Opportunity getOpportunity(Id oppId){
        return [SELECT Id, Name, CloseDate, StageName, Amount,Account.QB_Id__c,
                (SELECT Id, Product2Id, Product2.QB_Id__c, quantity, UnitPrice,TotalPrice, ListPrice,SortOrder 
                    FROM OpportunityLineItems),
                (SELECT Id FROM Invoices__r) 
                FROM Opportunity 
                WHERE Id =: oppId];
    }
}