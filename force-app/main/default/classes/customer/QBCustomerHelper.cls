public class QBCustomerHelper {
  public static Account createOrUpdateCustomer(Account acc) {
    qime__QIME_Config__mdt config = qime__QIME_Config__mdt.getInstance(
      'Default'
    );
    if (
      String.isNotBlank(acc.QB_Id__c) ||
      String.isNotBlank(acc.primary_email__c) ||
      config.qime__Link_Customer_By_Name__c
    ) {
      QBCustomerJSON accountData = QBCallout.getCustomer(acc);

      //Check if a customer was found
      if (accountData.QueryResponse.Customer != null) {
        //Check if only 1 customer was found
        if (accountData.QueryResponse.Customer.size() == 1) {
          for (QBCustomerJSON.Customer c : accountData.QueryResponse.Customer) {
            acc.QB_Id__c = c.id;
            System.debug('QB Id: ' + acc.QB_Id__c);
            acc.QB_SyncToken__c = c.SyncToken;
            System.debug('QB Synctoken: ' + acc.QB_SyncToken__c);
          }
        } else {
          //Multiple Customer Error Handling
          throw new ListException();
        }
      }
    }

    QBCustomerResponseJSON accountPushData = QBCallout.createCustomer(
      QBMap.mapAccountData(acc)
    );

    if (accountPushData.Customer.Id != null) {
      acc.QB_ID__c = accountPushData.Customer.Id;
    }
    if (accountPushData.Customer.SyncToken != null) {
      acc.QB_SyncToken__c = accountPushData.Customer.SyncToken;
    }

    //DML After Callouts
    return acc;
  }

  /**
   * Wrapper SOQL to get account with all fields
   * @param accId the account Id
   * @return Account data with all necessary fields
   */
  public static Account getAccount(Id accId) {
    return [
      SELECT
        Id,
        Name,
        QB_Id__c,
        QB_SyncToken__c,
        ShippingCity,
        ShippingStreet,
        ShippingState,
        ShippingCountry,
        ShippingPostalCode,
        Phone,
        Taxable__c,
        Primary_Email__c,
        Tax_Exemption_Reason__c,
        BillingCity,
        BillingStreet,
        BillingCountry,
        BillingPostalCode,
        BillingState,
        BillingLatitude,
        BillingLongitude
      FROM Account
      WHERE Id = :accId
    ];
  }

  public static Account createAccountFromCustomer(String qbId) {
    QBCustomerJSON accountData = QBCallout.getCustomer(qbId);
    List<Account> accs = QBMap.mapCustomersToAccounts(accountData);
    if (accs.size() > 0) {
      return accs[0];
    }
    return null;
  }
}
