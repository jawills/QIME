@isTest
public class QBSalesReceiptTest {
  private class Mock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      if (req.getEndpoint().endsWith('oauth2/v1/tokens/bearer')) {
        res.setBody(
          '{"x_refresh_token_expires_in":8726208,"refresh_token":"AB11573225348vwgpWeRhOnBYPabGNL3VOR17MWPluPdJHq734","access_token":"eyJlbmMiOiJBMTI4Q0JDLUhTMjU2IiwiYWxnIjoiZGlyIn0..9cmqH5Ub6ukl8n5sO5sbDw.gUhhaOZn8DH3UE0NJWbfOvlbyTqt4sUDk-y7UxzggDOtwueR0gENSJbVheUOb7_pfqvCnc30dxWz9AB5csBz0rPhCAJaTMI9swIb0fDJdFc_4hIWxGUBNirD-OF9CQqHEG3HOVuC5mDDL5N_b77o5etY3iXjGWi1iwfck0L5hAyyV-zovUEDqF_l2WgrS0ii3EOgZT2qriq80XROjZbGaoLRu3kdEboBfP9-MooxXyCZLfCQ7BMSbQsKUUR_tPV2Kdq4n85SH3sM2P67TLGGLnH4PjHS_IoHhdWodsQSJW8Ur1rPIt_bYw6IY9ctPxYNrQZ0TDlbxjItwRyJOVARSQ9BPvqA7W5dXrOg45uuNijeV81885AvyJ7B_TnIRjpe1Di-ZtmZkwp-kW0smxU_u96xTAk_EJldkF5qETmNKDUaO4GWq_4d2V14nGGKuhqPPld6GxAVsahTDGqngPmWg6g7kFmQkhfd09dTYONFaD4rPEVaUSX2yc-PMtwcksXrLmSbvE2TdxVSNmBZqar2Uckvfjx74RqBiktEz0c179voLiJt6M71kzD0rtO2KHCYNbaHkF5QI3iB5z7FOt0jotZ-eg9_XpR9YFqy8lQFxtOBZSBlS0-a0M__gsmCZLLn--kEpn4zxF2-wI_SyyuotLQQtGJXwaTIkBo22jlrbP2bQAjdIaJNBwx7PDd73LKprcMHkFLnf59m8ArrCRaQy8SdQRUgp8fB5H7GAKXE4p7eqPOqe9d7_lO-Ezcf9mmhrAkes79yx90jcHMlECNEa4VDHSqi3SfGCFOUDUtzIVCw03nFSYTuYWPUWN6paO7sPC8cwolI0nRqwcykpafpgkLj4Q6jp8BKcyUo3ZhTodA.dbobAIvcKw2COU5-RR6prA","token_type":"bearer","expires_in":3600}'
        );
        res.setStatusCode(200);
      } else if (req.getEndpoint().contains('/query?')) {
        res.setBody(QBSalesReceiptQueryJSON_Test.json);
        res.setStatusCode(200);
      } else if (req.getEndpoint().contains('/customer')) {
        res.setBody(
          '{"Customer":{"Taxable":true,"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","IsProject":false,"domain":"QBO","sparse":false,"Id":"3","SyncToken":"2","MetaData":{"CreateTime":"2019-06-19T16:51:22-07:00","LastUpdatedTime":"2019-07-29T03:41:27-07:00"},"GivenName":"Grace","FamilyName":"Pariente","FullyQualifiedName":"Cool Cars LLC","CompanyName":"Cool Cars LLC","DisplayName":"Cool Cars LLC","PrintOnCheckName":"Cool Cars LLC","Active":true,"PrimaryEmailAddr":{"Address":"Cool_Cars@intuit.com"},"DefaultTaxCodeRef":{"value":"2"}},"time":"2019-07-29T03:41:27.543-07:00"}'
        );
        res.setStatusCode(200);
      } else {
        System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
        return null;
      }
      return res;
    }
  }
  @isTest(seeAllData=false)
  static void testBatch() {
    Test.setMock(HttpCalloutMock.class, new Mock());
    QBSalesReceiptBatch rubt = new QBSalesReceiptBatch();

    Test.startTest();
    Database.executeBatch(rubt);
    Test.stopTest();
    System.assert(rubt != null);
  }

  @isTest(seeAllData=false)
  static void testQueueable() {
    Test.setMock(HttpCalloutMock.class, new Mock());

    Test.startTest();
    System.enqueueJob(new QBSalesReceiptQueueable(0, 0, 100, 0));
    Test.stopTest();
  }
}
