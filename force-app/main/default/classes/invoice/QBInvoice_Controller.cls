public with sharing class QBInvoice_Controller {

    public Id invId{get;set;}
    public qime__Invoice__c inv {get;set;}

    public QBInvoice_Controller(ApexPages.StandardController controller) {
        invId = controller.getRecord().Id;
        inv = QBInvoiceHelper.getInvoice(invId);
    }

    public Pagereference syncQB(){
        QBInvoiceHelper.mapInvoice(inv);
        return new PageReference('/'+ invId);
    }
    
}