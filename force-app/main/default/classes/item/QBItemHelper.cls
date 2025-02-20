public class QBItemHelper {
  public static Product2 createOrUpdateItem(PricebookEntry pbe) {
    String itemJSON = QBMap.mapItem(pbe);
    QBItemResponseJSON res = QBCallout.createItem(itemJSON);

    // Create Dummy Product To run update call
    Product2 p = new Product2();
    p.id = pbe.Product2Id;

    QBMap.mapItemResponse(p, res);
    return p;
  }

  /**
   * get pricebook entry from product id
   * @param prodId the desired product
   * @return pricebook entry for
   */
  public static PricebookEntry getPBE(Id prodId) {
    return [
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
      FROM PricebookEntry
      WHERE Product2Id = :prodId AND Pricebook2.qime__QB_Pricebook__c = TRUE
    ];
  }
}