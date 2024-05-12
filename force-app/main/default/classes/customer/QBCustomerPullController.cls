public with sharing class QBCustomerPullController {
  public Id accId { get; set; }
  public Account acc { get; set; }

  /**
   * Initialize controller
   * @param controller standard controller
   */
  public QBCustomerPullController(ApexPages.StandardController controller) {
    accId = controller.getRecord().Id;
    acc = QBCustomerHelper.getAccount(accId);
    if (String.isEmpty(acc.qime__QB_Id__c)) {
      throw new QBException('Please sync Account with QB before pulling');
    }
  }

  /**
   * Sync customer to QBO
   * @return Account PageReference
   */
  public Pagereference syncQB() {
    QBCustomerJSON res = QBCallout.getCustomer(acc);
    List<Account> returnList = QBMap.mapCustomersToAccounts(res);
    if (returnList.size() > 0) {
      returnList[0].Id = accId;
      update returnList[0];
    }
    return new PageReference('/' + accId);
  }
}
