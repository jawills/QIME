@isTest
public class QBItemTest {
  private class Mock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (req.getEndpoint().contains('/item')) {
        res.setBody(QBItemResponseJSON_Test.json);
        res.setStatusCode(200);
      } else if (req.getEndpoint().contains('query')) {
        res.setBody(QBItemQueryJSON_Test.json);
        res.setStatusCode(200);
      } else {
        System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
        return null;
      }
      return res;
    }
  }

  @TestSetup
  static void setup() {
    Pricebook2 pb = new Pricebook2();
    pb.Name = 'Test QB Pricebook';
    pb.qime__QB_Pricebook__c = true;
    insert pb;

    Product2 prod = new Product2();
    prod.Name = 'Test Prod';
    prod.IsActive = true;
    prod.qime__QB_Type__c = 'Service';
    prod.qime__QB_Product__c = true;
    insert prod;

    PricebookEntry pbeStandard = new PricebookEntry();
    pbeStandard.Pricebook2Id = Test.getStandardPricebookId();
    pbeStandard.Product2Id = prod.Id;
    pbeStandard.UnitPrice = 50;
    insert pbeStandard;

    PricebookEntry pbe = new PricebookEntry();
    pbe.Product2Id = prod.Id;
    pbe.Pricebook2Id = pb.Id;
    pbe.UnitPrice = 10;
    pbe.IsActive = true;
    insert pbe;
  }

  @isTest(seeAllData=false)
  static void testBatch() {
    Test.setMock(HttpCalloutMock.class, new Mock());
    QBItemBatch batch = new QBItemBatch();
    Test.startTest();
    Database.executeBatch(batch);
    Test.stopTest();

    Product2 p = [SELECT Id, QB_Id__c FROM Product2 WHERE Name = 'Test Prod'];

    System.assert(p.qime__QB_Id__c != null, 'QB Id never set.');
  }

  @isTest(seeAllData=false)
  static void testQueueable() {
    Test.setMock(HttpCalloutMock.class, new Mock());
    QBItemQueueable queueable = new QBItemQueueable(0, 0, 50, 0);
    Test.startTest();
    System.enqueueJob(queueable);
    Test.stopTest();

    List<Product2> prods = [
      SELECT Id, QB_Id__c
      FROM Product2
      WHERE qime__QB_Id__c != NULL
    ];

    System.assert(prods.size() > 0, 'Products never created');
  }

  @isTest(seeAllData=false)
  static void testController() {
    Test.setMock(HttpCalloutMock.class, new Mock());

    Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Test Prod'];

    Test.startTest();

    PageReference pageRef = Page.QBCreateItemVF; // Add your VF page Name here
    pageRef.getParameters().put('Id', String.valueOf(prod.Id));
    Test.setCurrentPage(pageRef);
    ApexPages.StandardController stdProd = new ApexPages.StandardController(
      prod
    );
    QBItemController controller = new QBItemController(stdProd);
    controller.syncQB();
    Test.stopTest();

    System.assert(controller != null);
  }
}
