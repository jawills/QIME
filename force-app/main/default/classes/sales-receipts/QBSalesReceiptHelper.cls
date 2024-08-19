public class QBSalesReceiptHelper {
  public static List<SObject> getSalesReceipts(String query) {
    QBSalesReceiptQueryJSON res = QBCallout.getSalesReceipts(query);
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
    addAccounts(updateList);
    printResults(Database.upsert(updateList, Opportunity.QBO_Id__c, false));
    printResults(
      Database.upsert(oliList, OpportunityLineItem.QBO_Id__c, false)
    );
  }

  private static void addAccounts(List<Opportunity> opps) {
    Set<String> customerIds = new Set<String>();
    // Key QBO Id, Value: Account Id
    Map<String, Id> customerMap = new Map<String, Id>();
    for (Opportunity opp : opps) {
      customerIds.add(opp.customer_Id__c);
    }
    List<Account> accs = [
      SELECT Id, qime__QB_Id__c
      FROM Account
      WHERE qime__QB_Id__c IN :customerIds
    ];
    for (Account acc : accs) {
      customerMap.put(acc.qime__QB_Id__c, acc.Id);
    }

    for (Opportunity opp : opps) {
      if (customerMap.containsKey(opp.customer_Id__c)) {
        opp.AccountId = customerMap.get(opp.customer_id__c);
      }
    }
  }

  private static void printResults(Database.UpsertResult[] results) {
    for (Database.UpsertResult result : results) {
      if (!result.success) {
        System.debug(result.getErrors());
      }
    }
  }
}
