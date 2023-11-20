trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update, after delete) {
    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityLineItemTriggerHandler.afterUpdateHandler(Trigger.new,Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityLineItemTriggerHandler.afterInsertHandler(Trigger.new, Trigger.newMap);
    }

    if(Trigger.isAfter && Trigger.isDelete){
        OpportunityLineItemTriggerHandler.afterDeleteHandler(Trigger.oldMap);
    }
}