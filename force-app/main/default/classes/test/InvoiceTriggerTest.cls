@isTest public class InvoiceTriggerTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Test Name From Apex';
        a.QB_Id__c = 'test';
        insert a;
    }

    @isTest static void testInsert(){
        Invoice__c inv = new Invoice__c();
        inv.name = 'INV-XXXX';
        inv.Customer_Id__c = 'test';
        Test.startTest();
        insert inv;
        Test.stopTest();
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        Invoice__c returnInv = [SELECT Id, Account__c FROM Invoice__c where Id =: inv.Id];
        System.assert(returnInv.Account__c == a.Id);
    }

    @isTest static void testUpdate(){
        Invoice__c inv = new Invoice__c();
        inv.name = 'INV-XXXX';
        insert inv;

        Test.startTest();
        inv.Customer_Id__c = 'test';
        update inv;
        Test.stopTest();

        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];
        Invoice__c returnInv = [SELECT Id, Account__c FROM Invoice__c where Id =: inv.Id];
        System.assert(returnInv.Account__c == a.Id);
    }

    @isTest static void testMemoLink(){
        Invoice__c inv = new Invoice__c();
        inv.name = 'INV-XXXX';
        insert inv;
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];

        Opportunity o = new Opportunity();
        o.Name = 'Test Opp From Apex';
        o.CloseDate = Date.today();
        o.StageName = 'Closed Won';
        o.Amount = 10;
        o.AccountId = a.Id;
        insert o;
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp From Apex'];
        Test.startTest();
        inv.Memo__c = String.valueOf(opp.Id);
        update inv;
        Test.stopTest();

        Invoice__c returnInv = [SELECT Id, Account__c, Opportunity__c FROM Invoice__c where Id =: inv.Id];
        System.assert(returnInv.Opportunity__c == opp.Id);
    }


    @isTest static void testInvalidMemoLink(){
        Invoice__c inv = new Invoice__c();
        inv.name = 'INV-XXXX';
        insert inv;
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Name From Apex'];

        Opportunity o = new Opportunity();
        o.Name = 'Test Opp From Apex';
        o.CloseDate = Date.today();
        o.StageName = 'Closed Won';
        o.Amount = 10;
        o.AccountId = a.Id;
        insert o;
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp From Apex'];
        Test.startTest();
        inv.Memo__c = String.valueOf(opp.Id) + 'xxxxxxxxxxdddddddddddddd';
        update inv;
        Test.stopTest();

        Invoice__c returnInv = [SELECT Id, Account__c, Opportunity__c FROM Invoice__c where Id =: inv.Id];
        System.assert(returnInv.Opportunity__c == null);
    }


}