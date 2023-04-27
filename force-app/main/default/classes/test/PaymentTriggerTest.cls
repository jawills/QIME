@isTest public class PaymentTriggerTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test Name From Apex';
        a.qime__QB_Id__c = 'test';
        insert a;
    }

    @isTest static void testInsert(){
        qime__Payment__c pmt = new qime__Payment__c();
        pmt.name = 'PMT-XXXX';
        pmt.qime__Customer_Id__c = 'test';
        Test.startTest();
        insert pmt;
        Test.stopTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        qime__Payment__c returnpmt = [SELECT Id, qime__Account__c FROM qime__Payment__c where Id =: pmt.Id];
        System.assert(returnpmt.qime__Account__c == a.Id);
    }

    @isTest static void testUpdate(){
        qime__Payment__c pmt = new qime__Payment__c();
        pmt.name = 'PMT-XXXX';
        insert pmt;

        Test.startTest();
        pmt.qime__Customer_Id__c = 'test';
        update pmt;
        Test.stopTest();

        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        qime__Payment__c returnpmt = [SELECT Id, qime__Account__c FROM qime__Payment__c where Id =: pmt.Id];
        System.assert(returnpmt.qime__Account__c == a.Id);
    }
}