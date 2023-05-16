public class InvoiceTriggerHandler {

    public static void beforeUpdateHandler(List<qime__Invoice__c> invoices){
        linkAccounts(invoices);
        linkOpportunities(invoices);
    }

    public static void beforeInsertHandler(List<qime__Invoice__c> invoices){
        linkAccounts(invoices);
        linkOpportunities(invoices);
    }

    private static void linkAccounts(List<qime__Invoice__c> invoices){
        Set<String> customerIdSet = new Set<String>();
        Map<String, Id> accountMap = new Map<String, Id>();
        for(qime__Invoice__c invoice : invoices){
            if(String.isNotBlank(invoice.qime__Customer_Id__c)){
                customerIdSet.add(invoice.qime__Customer_Id__c);
            }
        }
        
        List<Account> accounts = [SELECT Id, qime__QB_Id__c
                                    FROM Account 
                                    WHERE qime__QB_Id__c in: new List<String>(customerIdSet)];
        for(Account a : accounts){
            accountMap.put(a.qime__QB_Id__c, a.Id);
        }

        for(qime__Invoice__c invoice : invoices){
            if(String.isNotBlank(invoice?.qime__Customer_Id__c) 
                && accountMap.containsKey(invoice.qime__Customer_Id__c)){
                    invoice.qime__Account__c = accountMap.get(invoice.qime__Customer_Id__c);
                }
        }
    }

    private static void linkOpportunities(List<qime__Invoice__c> invoices){
        qime__QIME_Config__mdt config;
        if(!Test.isRunningTest()){
            config = [SELECT Id, qime__Link_By_Memo__c 
                        FROM qime__QIME_Config__mdt 
                        WHERE Label = 'Default'];
        }else{
            config = QBTestHelper.getConfig();
        }
        
        if(!config.qime__Link_By_Memo__c){
            return;
        }
        Set<Id> oppIds = new Set<Id>();
        for(qime__Invoice__c inv : invoices){
            if(String.isNotBlank(inv.qime__Memo__c) && isValidSalesforceId(inv.qime__Memo__c, Opportunity.class)){
                oppIds.add((Id) inv.qime__Memo__c);
            }
        }

        List<Opportunity> opps = [SELECT Id 
                                    FROM Opportunity 
                                    WHERE Id In: new List<Id>(oppIds)];
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity o : opps){
            opportunityIds.add(o.Id);
        }

        for(qime__Invoice__c inv : invoices){
            if(String.isNotBlank(inv.qime__Memo__c) 
                && inv.qime__Memo__c instanceof Id
                && opportunityIds.contains(inv.qime__Memo__c)){
                inv.qime__Opportunity__c = (Id) inv.qime__Memo__c;
            }
        }
    }

        /**
     * Test a String to see if it is a valid SFDC  ID
     * @param  sfdcId The ID to test.
     * @param  t      The Type of the sObject to compare against
     * @return        Returns true if the ID is valid, false if it is not.
     */
    public static Boolean isValidSalesforceId( String sfdcId, System.Type t ){
        try {
 
            if ( Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( sfdcId ).matches() ){
                // Try to assign it to an Id before checking the type
                Id id = sfdcId;
 
                // Use the Type to construct an instance of this sObject
                sObject sObj = (sObject) t.newInstance();
      
                // Set the ID of the new object to the value to test
                sObj.Id = id;
 
                // If the tests passed, it's valid
                return true;
            }
        } catch ( Exception e ){
            // StringException, TypeException
        }
 
        // ID is not valid
        return false;
    }
}