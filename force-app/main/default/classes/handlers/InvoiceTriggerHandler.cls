public class InvoiceTriggerHandler {

    /**
     * Before Update Trigger Handler
     * @param invoices Invoices from Trigger.new
     */
    public static void beforeUpdateHandler(List<Invoice__c> invoices){
        linkAccounts(invoices);
        linkOpportunities(invoices);
        setPaymentDate(invoices);
    }

    /**
     * Before Insert Trigger Handler
     * @param invoices Invoices from Trigger.new
     */
    public static void beforeInsertHandler(List<Invoice__c> invoices){
        linkAccounts(invoices);
        linkOpportunities(invoices);
        setPaymentDate(invoices);
    }

    /**
     * Link invoices to accounts based on customer id in QBO
     * @param invoices Invoices from Trigger.new
     */
    private static void linkAccounts(List<Invoice__c> invoices){
        Set<String> customerIdSet = new Set<String>();
        Map<String, Id> accountMap = new Map<String, Id>();
        for(Invoice__c invoice : invoices){
            if(String.isNotBlank(invoice.Customer_Id__c)){
                customerIdSet.add(invoice.Customer_Id__c);
            }
        }
        
        List<Account> accounts = [SELECT Id, QB_Id__c
                                    FROM Account 
                                    WHERE QB_Id__c in: new List<String>(customerIdSet)];
        for(Account a : accounts){
            accountMap.put(a.QB_Id__c, a.Id);
        }

        for(Invoice__c invoice : invoices){
            if(String.isNotBlank(invoice?.Customer_Id__c) 
                && accountMap.containsKey(invoice.Customer_Id__c)){
                    invoice.Account__c = accountMap.get(invoice.Customer_Id__c);
                }
        }
    }

    /**
     * Link invoices to opportunities based on memo
     * @param invoices Invoices from Trigger.new
     */
    private static void linkOpportunities(List<Invoice__c> invoices){
        QIME_Config__mdt config;
        if(!Test.isRunningTest()){
            config = [SELECT Id, Link_By_Memo__c 
                        FROM QIME_Config__mdt 
                        WHERE Label = 'Default'];
        }else{
            config = QBTestHelper.getConfig();
        }
        
        if(!config.Link_By_Memo__c){
            return;
        }
        Set<Id> oppIds = new Set<Id>();
        for(Invoice__c inv : invoices){
            if(String.isNotBlank(inv.Memo__c) && isValidSalesforceId(inv.Memo__c, Opportunity.class)){
                oppIds.add((Id) inv.Memo__c);
            }
        }

        List<Opportunity> opps = [SELECT Id 
                                    FROM Opportunity 
                                    WHERE Id In: new List<Id>(oppIds)];
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity o : opps){
            opportunityIds.add(o.Id);
        }

        for(Invoice__c inv : invoices){
            if(String.isNotBlank(inv.Memo__c) 
                && inv.Memo__c instanceof Id
                && opportunityIds.contains(inv.Memo__c)){
                inv.Opportunity__c = (Id) inv.Memo__c;
            }
        }
    }

    private static void setPaymentDate(List<Invoice__c> invoices){
        for(Invoice__c inv : invoices){
            if(inv.Payment_Date__c == null && inv.Balance__c == 0.0 && inv.Total__c > 0){
                inv.Payment_Date__c = Date.today();
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
            System.debug(e);
        }
 
        // ID is not valid
        return false;
    }
}