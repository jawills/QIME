@isTest public class InvoiceTriggerTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test Name From Apex';
        a.qime__QB_Id__c = 'test';
        insert a;
    }

    @isTest static void testInsert(){
        qime__Invoice__c inv = new qime__Invoice__c();
        inv.name = 'INV-XXXX';
        inv.qime__Customer_Id__c = 'test';
        Test.startTest();
        insert inv;
        Test.stopTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        qime__Invoice__c returnInv = [SELECT Id, qime__Account__c FROM qime__Invoice__c where Id =: inv.Id];
        System.assert(returnInv.qime__Account__c == a.Id);
    }

    @isTest static void testUpdate(){
        qime__Invoice__c inv = new qime__Invoice__c();
        inv.name = 'INV-XXXX';
        insert inv;

        Test.startTest();
        inv.qime__Customer_Id__c = 'test';
        update inv;
        Test.stopTest();

        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        qime__Invoice__c returnInv = [SELECT Id, qime__Account__c FROM qime__Invoice__c where Id =: inv.Id];
        System.assert(returnInv.qime__Account__c == a.Id);
    }
}