@isTest private class QBPaymentTest {

    @TestSetup
    static void makeData(){
        Account a = new Account();
        a.Name = 'Jizuke';
        a.QB_Id__c = 'Test';
        insert a;

        Contact c = new Contact();
        c.LastName = 'Jizuke Kazoo';
        c.AccountId = a.Id;
        insert c;
        
        Payment__c pmt = new Payment__c();
        pmt.Name = 'PMT-XXXX';
        pmt.QB_Id__c = 'test-pmt';
        insert pmt;

    }

    @isTest static void testController(){
        Test.setMock(HttpCalloutMock.class, new QBMock());

        Payment__c inv = QBPaymentHelper.getPayment([SELECT Id FROM Payment__c WHERE Name = 'PMT-XXXX'].Id);

        Test.startTest();

        PageReference pageRef = Page.QBPaymentVF; // Add your VF page Name here
        pageRef.getParameters().put('Id', String.valueOf(inv.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdPayment = new ApexPages.StandardController(inv);
        QBPaymentController controller = new QBPaymentController(stdPayment);
        controller.syncQB();
        Test.stopTest();

        System.assert(controller != null);

    }

    @isTest static void testPaymentQuery(){
        Test.setMock(HttpCalloutMock.class, new QBMock());
        Payment__c pmt = QBPaymentHelper.getPayment([SELECT Id FROM Payment__c WHERE Name = 'PMT-XXXX'].Id);
        Test.startTest();
        QBPaymentQueryJSON Payment = QBCallout.getPayment(pmt);
        Test.stopTest();

        System.assert(Payment != null);
        System.assert(Payment.QueryResponse != null);
    }

    @isTest static void testPaymentBatch(){
        Test.setMock(HttpCalloutMock.class, new QBMock());

        Test.startTest();
        QBPaymentBatch batch= new QBPaymentBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        System.assert(batch != null);
    }

    @isTest static void testPaymentQueueable(){
        Test.setMock(HttpCalloutMock.class, new QBMock());
        Test.startTest();
        System.enqueueJob(new QBPaymentQueueable(0,0,0,0));
        Test.stopTest();
        
    }

    // Implement a mock http response generator for QBAuth. 
    public class QBMock implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        {  
            HTTPResponse res = new HTTPResponse();
 
            if (req.getEndpoint().contains('query')) {
                res.setBody(QBPaymentQueryJSON_Test.json);
                res.setStatusCode(200);
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }

            return res;
        } 
    
    }

}