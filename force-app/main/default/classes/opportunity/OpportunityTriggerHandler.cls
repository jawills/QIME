public class OpportunityTriggerHandler {

    public static void afterInsertHandler(List<Opportunity> newOppList){
        mapOpportunityInsert(newOppList);
    }

    public static void afterUpdateHandler(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        mapOpportunityUpdate(newOppList, oldOppMap);
    }


    private static void mapOpportunityInsert(List<Opportunity> opps){
        List<Invoice__c> invs = new List<Invoice__c>();
        List<qime__QIME_Config__mdt> config = QIME.getConfig();
        if(!checkCreateInvoice(config)){
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

    private static void mapOpportunityUpdate(List<Opportunity> opps, Map<Id, Opportunity> oldOppMap){
        List<Invoice__c> invs = new List<Invoice__c>();
        Set<Id> oppIdSet = new Set<Id>();
        // Key: Opp Id - Value: Opp Inv
        Map<Id,Id> invMap = new Map<Id,Id>();

        List<qime__QIME_Config__mdt> config = QIME.getConfig();
        if(!checkCreateInvoice(config)){
            // Exit if no config or do not create invoice from opportunity
            return;
        }


        // Retrieve existing invoices
        List<Invoice__c> existingInvs = [SELECT Id, opportunity__c FROM Invoice__c WHERE Id IN: new Map<Id, Opportunity>(opps).keySet() ];
        for(Invoice__c inv : existingInvs){
            invMap.put(inv.Opportunity__c, inv.Id);
        }

        for(Opportunity opp : opps){
            if(opp.StageName == config[0].qime__Invoice_Stage_Name__c && opp.StageName != oldOppMap.get(opp.Id).StageName){
                List<SObject> sObjectList = OpportunityHelper.mapInvoice(opp, null);
                Invoice__c inv = (Invoice__c) sObjectList.remove(0);
                if(invMap.containsKey(opp.Id)){
                    inv.Id = invMap.get(opp.Id);
                }
                invs.add(inv);
                oppIdSet.add(opp.Id);
            }
        }
        
        if(invs.size() > 0){
            upsert invs;
        }

        for(Invoice__c inv : invs){
            invMap.put(inv.Opportunity__c, inv.Id);
        }
        
        List<OpportunityLineItem> olis = [SELECT Id, OpportunityId,UnitPrice,Quantity, TotalPrice,
                                            SortOrder, Product2Id
                                         FROM OpportunityLineItem 
                                         WHERE OpportunityId IN : new List<Id>(oppIdSet)];
        Map<Id, Id> oliMap = new Map<Id, Id>();
        for(OpportunityLineItem oli : olis){
            oliMap.put(oli.Id, oli.opportunityId);
        }
        List<qime__Invoice_Line_Item__c> ilis = OpportunityHelper.mapOLItoILI(olis);
        for(qime__Invoice_Line_Item__c ili : ilis){
            ili.qime__Invoice__c = invMap.get(oliMap.get(ili.qime__Opportunity_Product__c));
            System.debug(invMap.get(oliMap.get(ili.Id)));
        }

        if(ilis.size() > 0){
            Database.upsert(ilis, Invoice_Line_Item__c.OLI_Id__c);
        }

    }

    public static Boolean checkCreateInvoice(List<qime__QIME_Config__mdt> config){
        List<Invoice__c> invs = new List<Invoice__c>();

        // Check if Setting is set to create invoice on close won stage.
        if(config.size() == 0 || !config[0].qime__Create_Invoice_From_Opp__c){
            // Exit if no config or do not create invoice from opportunity
            return false;
        }
        return true;
    }

}