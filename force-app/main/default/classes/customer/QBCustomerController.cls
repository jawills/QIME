public with sharing class QBCustomerController {

    public Id accId{get;set;}
    public Account acc {get;set;}

    /**
     * Initialize controller
     * @param controller standard controller
     */
    public QBCustomerController(ApexPages.StandardController controller) {
        accId = controller.getRecord().Id;
        acc = QBCustomerHelper.getAccount(accId);
    }

    /**
     * Sync customer to QBO
     * @return Account PageReference
     */
    public Pagereference syncQB(){
        if(String.isNotBlank(acc.QB_Id__c)){
            QBCustomerJSON accountData = QBCallout.getCustomer(acc);

            //Check if a customer was found
            if(accountData.QueryResponse.Customer != null){
                
                //Check if only 1 customer was found
                if(accountData.QueryResponse.Customer.size() == 1){
                    for(QBCustomerJSON.Customer c : accountData.QueryResponse.Customer){
                        acc.QB_Id__c = c.id;
                        System.debug('QB Id: ' + acc.QB_Id__c);
                        acc.QB_SyncToken__c = c.SyncToken;
                        System.debug('QB Synctoken: ' + acc.QB_SyncToken__c );
                    }
                }else{
                    //Multiple Customer Error Handling
                throw new ListException(); 
                }
            }
        }

        QBCustomerResponseJSON accountPushData = QBCallout.createCustomer(QBMap.mapAccountData(acc));

        if(accountPushData.Customer.Id != null){
            acc.QB_ID__c = accountPushData.Customer.Id;
        }
        if(accountPushData.Customer.SyncToken != null){
            acc.QB_SyncToken__c = accountPushData.Customer.SyncToken;
        }

        //DML After Callouts
        update acc;

        return new PageReference('/'+accId);
    }
    
}