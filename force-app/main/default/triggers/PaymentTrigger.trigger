trigger PaymentTrigger on Payment__c (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
        PaymentTriggerHandler.beforeInsertHandler(Trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        PaymentTriggerHandler.beforeUpdateHandler(Trigger.new);
    }
}