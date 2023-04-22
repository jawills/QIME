@isTest private class QBInvoiceTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Jizuke';
        a.qime__QB_Id__c = 'Test';
        insert a;

        Contact c = new Contact();
        c.LastName = 'Jizuke Kazoo';
        c.AccountId = a.Id;
        insert c;
        
        qime__Invoice__c inv = new qime__Invoice__c();
        inv.Name = 'INV-XXXX';
        inv.qime__QB_Id__c = 'test-inv';
        insert inv;

        qime__Invoice_Line_Item__c ili = new qime__Invoice_Line_Item__c();
        ili.qime__Invoice__c = inv.Id;
        ili.qime__Quantity__c = 1.0;
        ili.qime__Unit_Price__c = 2.0;
        ili.qime__Taxable__c = true;
        insert ili; 
    }

    @isTest static void testController(){
        Test.setMock(HttpCalloutMock.class, new QBMock());

        qime__Invoice__c inv = QBInvoiceHelper.getInvoice([SELECT Id FROM qime__Invoice__c WHERE Name = 'INV-XXXX'].Id);

        Test.startTest();

        PageReference pageRef = Page.QBInvoiceVF; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(inv.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdInvoice = new ApexPages.StandardController(inv);
        QBInvoice_Controller controller = new QBInvoice_Controller(stdInvoice);
        controller.syncQB();
        Test.stopTest();

        System.assert(controller != null);

    }

    @isTest static void testInvoiceCreate(){
        Test.setMock(HttpCalloutMock.class, new QBMock());
        qime__Invoice__c inv = QBInvoiceHelper.getInvoice([SELECT Id FROM qime__Invoice__c WHERE Name = 'INV-XXXX'].Id);
        List<qime__Invoice_Line_Item__c> ilis = getILIs(inv.Id);
        Test.startTest();
        QBInvoiceJSON invoice = QBCallout.createInvoice(QBMap.mapInvoice(inv, ilis, 'testId'));
        Test.stopTest();

        System.assert(invoice != null);
    }

    @isTest static void testInvoiceQuery(){
        Test.setMock(HttpCalloutMock.class, new QBMock());
        qime__Invoice__c inv = QBInvoiceHelper.getInvoice([SELECT Id FROM qime__Invoice__c WHERE Name = 'INV-XXXX'].Id);
        Test.startTest();
        QBInvoiceQueryJSON invoice = QBCallout.getInvoice(inv);
        Test.stopTest();

        System.assert(invoice != null);
        System.assert(invoice.QueryResponse != null);
    }

    @isTest static void testInvoiceBatch(){
        Test.setMock(HttpCalloutMock.class, new QBMock());

        Test.startTest();
        QBInvoiceBatch batch= new QBInvoiceBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        System.assert(batch != null);
    }

    @isTest static void testInvoiceQueueable(){
        Test.setMock(HttpCalloutMock.class, new QBMock());
        Test.startTest();
        System.enqueueJob(new QBInvoiceQueueable(0,0,0,0));
        Test.stopTest();
        
    }

    // Implement a mock http response generator for QBAuth. 
    public class QBMock implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        {  
            HTTPResponse res = new HTTPResponse();
 
            if (req.getEndpoint().contains('query')) {
                res.setBody(QBInvoiceQueryJSON_Test.json);
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('invoice')) {
                res.setBody(QBInvoiceResponseJSON_Test.json);
                res.setStatusCode(200);
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }

            return res;
        } 
    
    }

    private static List<qime__Invoice_Line_Item__c> getILIs(Id invId){
        return [SELECT Id, qime__Invoice__c, qime__Unit_Price__c,
                     qime__Quantity__c, qime__Product__c, 
                     qime__Product__r.qime__QB_Id__c, qime__QB_Id__c, 
                     qime__Taxable__c
                FROM qime__Invoice_Line_Item__c 
                WHERE qime__Invoice__c =: invId];
    }
}