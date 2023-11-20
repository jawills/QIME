public with sharing class OpportunityLineItemTriggerHandler {
    
    public static void afterInsertHandler(List<OpportunityLineItem> olis, Map<Id, OpportunityLineItem> newOliMap){
        checkILIUpsert(olis, newOliMap);
    }

    public static void afterUpdateHandler(List<OpportunityLineItem> olis,Map<Id, OpportunityLineItem> newOLIMap, Map<Id, OpportunityLineItem> oldOLIMap){
        checkILIUpsert(olis, newOliMap);
    }

    public static void afterDeleteHandler(Map<Id, OpportunityLineItem> oldOliMap){
        deleteILI(oldOliMap);
    }

    /**
     * @description check if related oli exist to ili then delete
     */
    private static void deleteILI(Map<Id, OpportunityLineItem> oldOLIMap){
        List<qime__QIME_Config__mdt> config = QIME.getConfig();
        if(!OpportunityTriggerHandler.checkCreateInvoice(config)){
            // Exit if no config or do not create invoice from opportunity
            return;
        }
        System.debug('Deleting ilis');
        
        List<qime__Invoice_Line_Item__c> ilis = [SELECT Id FROM qime__Invoice_Line_Item__c WHERE qime__Opportunity_Product_Id__c IN : oldOLIMap.keySet()];
        System.debug(oldOLIMap);
        if(ilis.size() > 0){
            //delete related ili if oli was deleted
            delete ilis;
        }
    }

    private static void checkILIUpsert(List<OpportunityLineItem> olis, Map<Id, OpportunityLineItem> newOliMap){
        Set<Id> oppIds = new Set<Id>();
        List<Id> oliIds = new List<Id>();
        // Key: oliId, Value: iliId
        Map<Id, Id> iliMap = new Map<Id, Id>();
        // Key: oppId, value: oppId
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        //Key: oppId, value: invoiceId
        Map<Id, Id> invMap = new Map<Id, Id>();

        List<OpportunityLineItem> olisCreate = new List<OpportunityLineItem>();

        List<qime__QIME_Config__mdt> config = QIME.getConfig();
        if(!OpportunityTriggerHandler.checkCreateInvoice(config)){
            // Exit if no config or do not create invoice from opportunity
            return;
        }


        for(OpportunityLineItem oli : olis){
            oppIds.add(oli.OpportunityId);
        }
        List<Opportunity> opps = [SELECT Id, Amount, AccountId, CloseDate, StageName FROM Opportunity WHERE Id in: new List<Id>(oppIds)];
        for(Opportunity o : opps){
            oppMap.put(o.Id, o);
        }

        // Get existing invoices

        List<Invoice__c> existingInvs = [SELECT Id, qime__Opportunity__c FROM qime__Invoice__c WHERE qime__Opportunity__c IN: oppMap.keySet()];
        // Create set of opp for existing inv to check next step
        Set<Id> oppsWithExistingInvs = new Set<Id>();
        for(Invoice__c inv : existingInvs){
            oppsWithExistingInvs.add(inv.Opportunity__c);
        }
        // Create Invoices if they don't exist
        List<Invoice__c> invInsert = new List<Invoice__c>();
        for(Opportunity opp : opps){
            if(opp.StageName == config[0].qime__Invoice_Stage_Name__c && 
            !oppsWithExistingInvs.contains(opp.Id)){
                List<SObject> sObjectList = OpportunityHelper.mapInvoice(opp, null);
                invInsert.add((Invoice__c) sObjectList[0]);
            }
        }
        
        if(invInsert.size() > 0){
            insert invInsert;
        }


        List<Invoice__c> invs = [SELECT Id, Opportunity__c FROM Invoice__c WHERE Opportunity__c in: new List<Id>(oppIds)]; 
        for(Invoice__c inv : invs){
            invMap.put(inv.Opportunity__c, inv.Id);
        }

        for(OpportunityLineItem oli : olis){
            if(oppMap.containsKey(oli.OpportunityId) && 
            oppMap.get(oli.OpportunityId).StageName == config[0].qime__Invoice_Stage_Name__c){
                oliIds.add(oli.Id);
                olisCreate.add(oli);
            }
        }

        // Return if no ILIs to create
        if(olisCreate.size() == 0){
            return;
        }

        List<Invoice_Line_Item__c> existingILIs = [SELECT Id, Opportunity_Product__c FROM Invoice_Line_Item__c WHERE Opportunity_Product__c in: oliIds];

        for(Invoice_Line_Item__c ili : existingILIs){
            iliMap.put(ili.Opportunity_Product__c, ili.Id);
        }

        List<qime__Invoice_Line_Item__c> ilis = OpportunityHelper.mapOLItoILI(olisCreate);
        for(invoice_line_item__c ili : ilis){
            if(iliMap.containsKey(ili.Opportunity_Product__c)){
                ili.Id = iliMap.get(ili.Opportunity_Product__c);
                ili.qime__Invoice__c = null;
            }
            if(invMap.containsKey(oppMap.get(newOliMap.get(ili.Opportunity_Product__c).OpportunityId).Id)){
                ili.Invoice__c = invMap.get(oppMap.get(newOliMap.get(ili.Opportunity_Product__c).OpportunityId).Id);
            }
        }

        if(ilis.size() > 0){
            upsert ilis;
        } 
    }
}