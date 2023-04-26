trigger InvoiceTrigger on qime__Invoice__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
        InvoiceTriggerHandler.beforeInsertHandler(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        InvoiceTriggerHandler.beforeUpdateHandler(Trigger.new);
    }
}