public class QBSalesReceiptHelper {
  public static List<SObject> getSalesReceipts(String query) {
    QBSalesReceiptQueryJSON res = QBCallout.getSalesReceipts(query);
    System.debug(res);
    return QBSalesReceiptMapping.mapSalesReceiptToOpportunities(res);
  }

  public static void updateObjects(List<SObject> sobjects) {
    List<Opportunity> updateList = new List<Opportunity>();
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    for (SObject so : sobjects) {
      if (so instanceof Opportunity) {
        updateList.add((Opportunity) so);
      } else if (so instanceof OpportunityLineItem) {
        oliList.add((OpportunityLineItem) so);
      }
    }

    printResults(Database.upsert(updateList, Opportunity.QBO_Id__c, false));
    printResults(
      Database.upsert(oliList, OpportunityLineItem.QBO_Id__c, false)
    );
  }

  private static void printResults(Database.UpsertResult[] results) {
    for (Database.UpsertResult result : results) {
      if (!result.success) {
        System.debug(result.getErrors());
      }
    }
  }
}
