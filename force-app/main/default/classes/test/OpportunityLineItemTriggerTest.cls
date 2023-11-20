@isTest
public class OpportunityLineItemTriggerTest {

    @isTest(seeAllData=false)
    static void testLineItemInsert() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Product2 p = new Product2();
        p.Name = 'Test Product';
        insert p;
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.Product2Id = p.Id;
        pbe.IsActive = true;
        insert pbe;

        Opportunity o = new Opportunity();
        o.CloseDate = Date.today();
        o.Name = 'Test Opp QIME';
        o.AccountId = a.Id;
        o.StageName = 'Closed Won';
        insert o;
        List<Invoice__c> invs = [SELECT Id FROM qime__Invoice__c];
        System.assertEquals(1, invs.size());
        List<qime__Invoice_Line_Item__c> ilis = [SELECT Id FROM qime__Invoice_Line_Item__c];
        System.assertEquals(0, ilis.size());
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe.Id;
        oli.UnitPrice = 100;
        oli.Quantity = 1;
        oli.OpportunityId = o.id;

        Test.startTest();
        insert oli;

        Test.stopTest();
        ilis = [SELECT Id FROM qime__Invoice_Line_Item__c];
        System.assertEquals(1, ilis.size());
    }

    @isTest(seeAllData=false)
    static void testLineItemUpdate() {

        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Product2 p = new Product2();
        p.Name = 'Test Product';
        insert p;
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.Product2Id = p.Id;
        pbe.IsActive = true;
        insert pbe;

        Opportunity o = new Opportunity();
        o.CloseDate = Date.today();
        o.Name = 'Test Opp QIME';
        o.AccountId = a.Id;
        o.StageName = 'Closed Won';
        insert o;
        List<Invoice__c> invs = [SELECT Id FROM qime__Invoice__c];
        System.assertEquals(1, invs.size());
        List<qime__Invoice_Line_Item__c> ilis = [SELECT Id FROM qime__Invoice_Line_Item__c];
        System.assertEquals(0, ilis.size());
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe.Id;
        oli.UnitPrice = 100;
        oli.Quantity = 1;
        oli.OpportunityId = o.id;
        insert oli;
        ilis = [SELECT Id FROM qime__Invoice_Line_Item__c];
        System.assertEquals(1, ilis.size());

        Test.startTest();
        oli.Quantity = 2;
        update oli;
        Test.stopTest();
        ilis = [SELECT Id,qime__Quantity__c FROM qime__Invoice_Line_Item__c];
        System.assertEquals(1, ilis.size());
        System.assertEquals(2, ilis[0].qime__Quantity__c);

    }

    @isTest(seeAllData=false)
    static void testLineItemDelete() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Product2 p = new Product2();
        p.Name = 'Test Product';
        insert p;
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 100;
        pbe.Product2Id = p.Id;
        pbe.IsActive = true;
        insert pbe;

        Opportunity o = new Opportunity();
        o.CloseDate = Date.today();
        o.Name = 'Test Opp QIME';
        o.AccountId = a.Id;
        o.StageName = 'Closed Won';
        insert o;
        List<Invoice__c> invs = [SELECT Id FROM qime__Invoice__c];
        System.assertEquals(1, invs.size());
        List<qime__Invoice_Line_Item__c> ilis = [SELECT Id FROM qime__Invoice_Line_Item__c];
        System.assertEquals(0, ilis.size());
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe.Id;
        oli.UnitPrice = 100;
        oli.Quantity = 1;
        oli.OpportunityId = o.id;
        insert oli;
        ilis = [SELECT Id FROM qime__Invoice_Line_Item__c];
        System.assertEquals(1, ilis.size());

        Test.startTest();
        delete oli;
        Test.stopTest();

        List<OpportunityLineItem> oliAfter = [SELECT Id FROM OpportunityLineItem WHERE Id =: oli.Id];
        System.assertEquals(0, oliAfter.size(), 'OLI was not deleted');

        List<qime__Invoice_Line_Item__c> iliAfter = [SELECT Id FROM qime__Invoice_Line_Item__c WHERE Invoice__c =: invs[0].id];
        System.assertEquals(0, iliAfter.size(), 'ILI was not deleted');
    }
}