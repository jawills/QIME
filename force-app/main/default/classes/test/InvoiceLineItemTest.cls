@isTest public class InvoiceLineItemTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test Name From Apex';
        a.QB_Id__c = 'test';
        insert a;

        Product2 p = new Product2();
        p.Name = 'TEST FROM Apex';
        p.QB_Id__c = 'TESTXD';
        insert p;

        Invoice__c inv = new Invoice__c();
        inv.name = 'INV-XXXX';
        inv.Customer_Id__c = 'test';
        insert inv;

    }

    @isTest static void testInsert(){
        Invoice__c inv = [SELECT Id FROM Invoice__c WHERE Name = 'INV-XXXX'];
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.ItemRef_Id__c = 'TESTXD';
        ili.Invoice__c = inv.Id;
        Test.startTest();
        insert ili;
        Test.stopTest();
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'TEST FROM Apex'];
        Invoice_Line_Item__c returnILI = [SELECT Id, Product__c FROM Invoice_Line_Item__c where Id =: ili.Id];
        System.assert(returnILI.Product__c == p.Id);
    }

    @isTest static void testUpdate(){
        Invoice__c inv = [SELECT Id FROM Invoice__c WHERE Name = 'INV-XXXX'];
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Invoice__c = inv.Id;
        insert ili;
        Test.startTest();
        ili.ItemRef_Id__c = 'TESTXD';
        update ili;
        Test.stopTest();
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'TEST FROM Apex'];
        Invoice_Line_Item__c returnILI = [SELECT Id, Product__c FROM Invoice_Line_Item__c where Id =: ili.Id];
        System.assert(returnILI.Product__c == p.Id);
    }
}