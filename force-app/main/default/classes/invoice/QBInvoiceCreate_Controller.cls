public with sharing class QBInvoiceCreate_Controller {

    public Id invId{get;set;}
    public qime__Invoice__c inv {get;set;}

    public QBInvoiceCreate_Controller(ApexPages.StandardController controller) {
        invId = controller.getRecord().Id;
        inv = QBInvoiceHelper.getInvoice(invId);
    }

    public Pagereference syncQB(){
        QBInvoiceHelper.createOrUpdateInvoice(inv);
        return new PageReference('/'+ invId);
    }
    
}