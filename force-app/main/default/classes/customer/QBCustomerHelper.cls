public class QBCustomerHelper {

    /**
     * Wrapper SOQL to get account with all fields
     * @param accId the account Id
     * @return Account data with all necessary fields 
     */
    public static Account getAccount(Id accId){
        return [SELECT Id,
                      Name, 
                      qime__QB_Id__c, 
                      qime__QB_SyncToken__c,
                      ShippingCity,
                      ShippingStreet,
                      ShippingState,
                      ShippingCountry,
                      ShippingPostalCode,
                      Phone,
                      qime__Taxable__c,
                      qime__Tax_Exemption_Reason__c,
                      BillingCity,
                      BillingStreet,
                      BillingCountry,
                      BillingPostalCode,
                      BillingState,
                      BillingLatitude,
                      BillingLongitude
              FROM Account 
              WHERE Id =: accId];
    }
}