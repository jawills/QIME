public with sharing class QBCustomerController {

    public Id accId{get;set;}
    public Account acc {get;set;}

    /**
     * Initialize controller
     * @param controller standard controller
     */
    public QBCustomerController(ApexPages.StandardController controller) {
        accId = controller.getRecord().Id;
        acc = QBCustomerHelper.getAccount(accId);
    }

    /**
     * Sync customer to QBO
     * @return Account PageReference
     */
    public Pagereference syncQB(){
        acc = QBCustomerHelper.createOrUpdateCustomer(acc);
        update acc;
        return new PageReference('/'+accId);
    }
    
}