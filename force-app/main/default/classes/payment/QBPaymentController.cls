public with sharing class QBPaymentController {

    public Id pmtId {get;set;}
    public qime__Payment__c pmt {get;set;}

    public QBPaymentController(ApexPages.StandardController controller) {
        pmtId = controller.getRecord().Id;
        pmt = QBPaymentHelper.getPayment(pmtId);
    }

    public Pagereference syncQB(){
        if(String.isBlank(pmt.QB_Id__c)){
            throw new QBException('Please enter a QB Id');
        }

        QBPaymentQueryJSON queryJson = QBCallout.getPayment(pmt);
        List<qime__Payment__c> payments = QBMap.mapPayments(queryJson);
        Database.update(payments, false);

        return new PageReference('/'+ pmtId);
    }
    
}