public class OpportunityTriggerHandler {

    public static void afterInsertHandler(List<Opportunity> newOppList){
        mapOpportunityInsert(newOppList);
    }

    public static void afterUpdateHandler(List<Opportunity> newOppList, Map<Id, Opportunity oldOppMap){
        mapOpportunityUpdate(newOppList, oldOppMap);
    }


    private static void mapOpportunityInsert(List<Opportunity> opps){
        List<Invoice__c> invs = new List<Invoice__c>();
        List<qime__QIME_Config__mdt> config = getConfig();
        if(checkCreateInvoice(config)){
            // Exit if no config or do not create invoice from opportunity
            return;
        }

        for(Opportunity o : opps){
            if(o.StageName == config[0].qime__Invoice_Stage_Name__c){
                List<SObject> sObjectList = OpportunityHelper.mapInvoice(o, null);
                invs.add((Invoice__c) sObjectList[0]);
            }
        }

        if(invs.size() > 0){
            insert invs;
        }
    }

    private static void mapOpportunityUpdate(List<Opportunity> opps, Map<Id, Opportunity oldOppMap){
        List<Invoice__c> invs = new List<Invoice__c>();
        Set<Id> oppIdSet = new Set<Id>();
        List<Invoice_Line_Item__c> ilis = new List<Invoice_Line_Item__c>();
        // Key: Inv Id - Value: Opp Id
        Map<Id,Id> invMap = new Map<Id,Id>();

        List<qime__QIME_Config__mdt> config = getConfig();
        if(checkCreateInvoice(config)){
            // Exit if no config or do not create invoice from opportunity
            return;
        }


        for(Opportunity opp : opps){
            if(opp.StageName == config[0].qime__Invoice_Stage_Name__c && opp.StageName != oldOppMap.get(opp.Id).StageName){
                List<SObject> sObjectList = OpportunityHelper.mapInvoice(o, null);
                invs.add((Invoice__c) sObjectList[0]);
                oppIdSet.add(opp.Id);
            }
        }
        
        if(invs.size() > 0){
            insert invs;
        }

        for(Invoice__c inv : invs){
            invMap.put(inv.Opportunity__c, inv.Id);
        }
        
        List<OpportunityLineItem> olis = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN : new List<Id>(oppIdSet)];


        
    }

    private static Boolean checkCreateInvoice(List<qime__QIME_Config__mdt> config){
        List<Invoice__c> invs = new List<Invoice__c>();

        // Check if Setting is set to create invoice on close won stage.

        if(config.size() == 0 || !config[0].qime__Create_Invoice_From_Opp__c){
            // Exit if no config or do not create invoice from opportunity
            return false;
        }
        return true;
    }

    private static List<qime__QIME_Config__mdt> getConfig(){
        return [SELECT Id,
        qime__Create_Invoice_From_Opp__c, qime__Invoice_Stage_Name__c FROM qime__QIME_Config__mdt LIMIT 1];
    }
}