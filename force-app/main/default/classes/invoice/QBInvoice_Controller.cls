public with sharing class QBInvoice_Controller {

    public Id invId{get;set;}
    public Invoice__c inv {get;set;}

    /**
     * Initialize controller
     * @param controller standard controller
     */
    public QBInvoice_Controller(ApexPages.StandardController controller) {
        invId = controller.getRecord().Id;
        inv = QBInvoiceHelper.getInvoice(invId);
    }

    /**
     * Sync invoice to QBO
     * @return Invoice pagereference
     */
    public Pagereference syncQB(){
        QBInvoiceHelper.mapInvoice(inv);
        return new PageReference('/'+ invId);
    }
    
}