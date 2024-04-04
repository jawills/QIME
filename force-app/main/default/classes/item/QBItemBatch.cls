public class QBItemBatch implements Database.Batchable<sobject>, Database.AllowsCallouts, Schedulable {
  public void execute(SchedulableContext SC) {
    QBItemBatch batch = new QBItemBatch();
    Database.executeBatch(batch, 20);
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          UnitPrice,
          ProductCode,
          IsActive,
          Product2.qime__Qty_On_Hand__c,
          Product2Id,
          Product2.qime__Income_Account__c,
          Product2.qime__QB_Id__c,
          Product2.qime__QB_Type__c,
          Product2.Name
        FROM PriceBookEntry
        WHERE
          (Product2.qime__QB_Id__c != NULL
          OR Product2.qime__QB_Product__c = TRUE)
          AND Pricebook2.QB_Pricebook__c = TRUE
          AND Product2.QB_Type__C != NULL
      ]
    );
  }

  public void Execute(
    Database.BatchableContext BC,
    List<PriceBookEntry> pbeList
  ) {
    List<Product2> prods = new List<Product2>();
    for (PricebookEntry pbe : pbeList) {
      Product2 p = QBItemHelper.createOrUpdateItem(pbe);
      prods.add(p);
    }

    if (prods.size() > 0) {
      update prods;
    }
  }

  public void finish(Database.BatchableContext BC) {
    System.debug('Finished');
  }
}
