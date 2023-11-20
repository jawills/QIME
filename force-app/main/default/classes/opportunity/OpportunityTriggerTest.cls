@isTest
public class OpportunityTriggerTest {

    @isTest(seeAllData=false)
    static void testTriggerInsert() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Opportunity o = new Opportunity();
        o.CloseDate = Date.today();
        o.Name = 'Test Opp QIME';
        o.AccountId = a.Id;
        o.StageName = 'Closed Won';
        Test.startTest();
        insert o;
        Test.stopTest();
        
        List<Invoice__c> invs = [SELECT Id FROM qime__Invoice__c];

        System.assert(invs.size() == 1);
    }

    @isTest(seeAllData=false)
    static void testTriggerUpdate() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Opportunity o = new Opportunity();
        o.CloseDate = Date.today();
        o.Name = 'Test Opp QIME';
        o.AccountId = a.Id;
        o.StageName = 'Prospecting';
        insert o;
        List<Invoice__c> invs = [SELECT Id FROM qime__Invoice__c];
        System.assert(invs.size() == 0);
        Test.startTest();
        o.StageName = 'Closed Won';
        update o;
        Test.stopTest();
        invs = [SELECT Id FROM qime__Invoice__c];
        System.assert(invs.size() == 1);
    }

    @isTest(seeAllData=false)
    static void testTriggerUpdateWithLineItems() {
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
        o.StageName = 'Prospecting';
        insert o;
        List<Invoice__c> invs = [SELECT Id FROM qime__Invoice__c];
        System.assert(invs.size() == 0);

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe.Id;
        oli.UnitPrice = 100;
        oli.Quantity = 1;
        oli.OpportunityId = o.id;
        insert oli;

        Test.startTest();
        o.StageName = 'Closed Won';
        update o;
        Test.stopTest();
        invs = [SELECT Id FROM qime__Invoice__c];
        System.assertEquals(1, invs.size());

        List<qime__Invoice_Line_Item__c> ilis = [SELECT Id FROM qime__Invoice_Line_Item__c];
        System.assertEquals(1, ilis.size());

    }
}