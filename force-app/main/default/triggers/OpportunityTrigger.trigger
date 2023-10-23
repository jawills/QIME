trigger OpportunityTrigger on Opportunity (after update, after insert) {

    if(Trigger.isAfter && Trigger.isUpdate){

    }

    if(Trigger.isAfter && Trigger.isInsert){

    }
}