@isTest public class PaymentTriggerTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test Name From Apex';
        a.QB_Id__c = 'test';
        insert a;
    }

    @isTest static void testInsert(){
        Payment__c pmt = new Payment__c();
        pmt.name = 'PMT-XXXX';
        pmt.Customer_Id__c = 'test';
        Test.startTest();
        insert pmt;
        Test.stopTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        Payment__c returnpmt = [SELECT Id, Account__c FROM Payment__c where Id =: pmt.Id];
        System.assert(returnpmt.Account__c == a.Id);
    }

    @isTest static void testUpdate(){
        Payment__c pmt = new Payment__c();
        pmt.name = 'PMT-XXXX';
        insert pmt;

        Test.startTest();
        pmt.Customer_Id__c = 'test';
        update pmt;
        Test.stopTest();

        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        Payment__c returnpmt = [SELECT Id, Account__c FROM Payment__c where Id =: pmt.Id];
        System.assert(returnpmt.Account__c == a.Id);
    }
}