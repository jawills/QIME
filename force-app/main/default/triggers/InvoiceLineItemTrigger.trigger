trigger InvoiceLineItemTrigger on qime__Invoice_Line_Item__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
        InvoiceLineItemTriggerHandler.beforeInsertHandler(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        InvoiceLineItemTriggerHandler.beforeUpdateHandler(Trigger.new);
    }

}