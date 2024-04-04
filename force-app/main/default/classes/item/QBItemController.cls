public class QBItemController {
  public Id prodId { get; set; }
  public PricebookEntry pbe { get; set; }

  public QBItemController(ApexPages.StandardController controller) {
    prodId = controller.getRecord().Id;
    pbe = QBItemHelper.getPBE(prodId);

    if (String.isBlank(pbe.Product2.qime__QB_Type__c)) {
      throw new QBException('Please add a type before pushing to QB');
    }
  }

  public PageReference syncQB() {
    Product2 p = QBItemHelper.createOrUpdateItem(pbe);
    update p;
    return new PageReference('/' + prodId);
  }
}
