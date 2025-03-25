global class QBCustomerPushQueueable implements Queueable, Database.AllowsCallouts {
  List<Account> accs;
  global QBCustomerPushQueueable(List<Account> accs) {
    this.accs = accs;
  }

  global void execute(QueueableContext context) {
    if (accs.isEmpty()) {
      return;
    }
    Account acc = QBCustomerHelper.getAccount(accs.remove(0).id);
    try {
      acc = QBCustomerHelper.createOrUpdateCustomer(acc);
      QIMEUtil.printResult(Database.upsert(acc, Account.QB_Id__c, false));
    } catch (Exception e) {
      System.debug(e.getMessage());
    }

    if (!this.accs.isEmpty()) {
      System.enqueueJob(new QBCustomerPushQueueable(this.accs));
    }
  }
}
