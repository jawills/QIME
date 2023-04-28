@isTest public class InvoiceLineItemTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test Name From Apex';
        a.qime__QB_Id__c = 'test';
        insert a;

        Product2 p = new Product2();
        p.Name = 'TEST FROM Apex';
        p.qime__QB_Id__c = 'TESTXD';
        insert p;

        qime__Invoice__c inv = new qime__Invoice__c();
        inv.name = 'INV-XXXX';
        inv.qime__Customer_Id__c = 'test';
        insert inv;

    }

    @isTest static void testInsert(){
        qime__Invoice__c inv = [SELECT Id FROM qime__Invoice__c WHERE Name = 'INV-XXXX'];
        qime__Invoice_Line_Item__c ili = new qime__Invoice_Line_Item__c();
        ili.qime__ItemRef_Id__c = 'TESTXD';
        ili.qime__Invoice__c = inv.Id;
        Test.startTest();
        insert ili;
        Test.stopTest();
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'TEST FROM Apex'];
        qime__Invoice_Line_Item__c returnILI = [SELECT Id, qime__Product__c FROM qime__Invoice_Line_Item__c where Id =: ili.Id];
        System.assert(returnILI.qime__Product__c == p.Id);
    }

    @isTest static void testUpdate(){
        qime__Invoice__c inv = [SELECT Id FROM qime__Invoice__c WHERE Name = 'INV-XXXX'];
        qime__Invoice_Line_Item__c ili = new qime__Invoice_Line_Item__c();
        ili.qime__Invoice__c = inv.Id;
        insert ili;
        Test.startTest();
        ili.qime__ItemRef_Id__c = 'TESTXD';
        update ili;
        Test.stopTest();
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'TEST FROM Apex'];
        qime__Invoice_Line_Item__c returnILI = [SELECT Id, qime__Product__c FROM qime__Invoice_Line_Item__c where Id =: ili.Id];
        System.assert(returnILI.qime__Product__c == p.Id);
    }
}