public class OpportunityController {

    public Id oppId{get;set;}
    public Opportunity opp {get;set;}
    public List<OpportunityLineItem> olis {get;set;}

    public OpportunityController(ApexPages.StandardController controller) {
        oppId = controller.getRecord().Id;
        opp = OpportunityHelper.getOpportunity(oppId);
        olis = opp.OpportunityLineItems;
    }

    public Pagereference createInvoice(){
        if(opp.qime__Invoices__r.size() > 0){
            throw new QIMEException('Please use the existing Invoice');
        }
        List<SObject> upsertObjects = OpportunityHelper.mapInvoice(opp, olis);
        qime__Invoice__c inv;
        List<qime__Invoice_Line_Item__c> ilis = new List<qime__Invoice_Line_Item__c>();
        for(SObject so : upsertObjects){
            if(so instanceof qime__Invoice__c){
                inv = (qime__Invoice__c) so;
            }else if(so instanceof qime__Invoice_Line_Item__c){
                ilis.add((qime__Invoice_Line_Item__c) so);
            }
        }
        insert inv;
        for(qime__Invoice_Line_Item__c ili : ilis){
            ili.qime__Invoice__c = inv.Id;
        }
        insert ilis;
        return new PageReference('/'+ inv.Id);
    }
    
}