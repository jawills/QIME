trigger OpportunityTrigger on Opportunity (after update, after insert) {

    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isInsert){ 
        OpportunityTriggerHandler.afterInsertHandler(Trigger.new);

    }
}