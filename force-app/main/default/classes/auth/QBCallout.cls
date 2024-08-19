public class QBCallout {
  /**
   * Wrapper for callouts to QBO. Uses
   * 1. Named credential to handle auth
   * 2. takes realm / company id for the endpoint url
   * 3. minor version of qbo api
   * @param endpoint QBO endpoint to callout to
   * @param method Http method (needs to be all caps)
   * @param body http body. Should be null if no body is provided
   * @return HttpResponse object from the
   */

  private static HttpResponse calloutHelper(
    String endpoint,
    String method,
    String body
  ) {
    QB_Credential__mdt credentials;
    if (Test.isRunningTest()) {
      credentials = QBTestHelper.getCredential();
    } else {
      List<QB_Credential__mdt> creds = [
        SELECT Id, Realm_Id__c, MinorVersion__c
        FROM QB_Credential__mdt
        WHERE DeveloperName = 'QB_Auth_Provider'
      ];
      if (creds.size() > 0) {
        credentials = creds[0];
      } else {
        throw new QBException(
          'Please ensure your auth provider has the Developer Name: \'QB_Auth_Provider\''
        );
      }
    }

    HttpRequest req = new HttpRequest();
    String url = 'v3/company/' + credentials.Realm_Id__c + '/' + endpoint;
    if (!url.contains('?')) {
      url += '?minorversion=' + credentials.MinorVersion__c;
    } else {
      url += '&minorversion=' + credentials.MinorVersion__c;
    }
    req.setEndpoint('callout:QB_Named_Credential/' + url);
    req.setMethod(method);
    if (body != null) {
      System.debug(body);
      req.setBody(body);
    }
    req.setheader('Accept', 'application/json');
    req.setHeader('Content-Type', 'application/json');
    req.setHeader('Authorization', 'Bearer {!$Credential.OAuthToken}');

    if (endpoint.contains('query')) {
      req.setHeader('Content-Type', 'application/text');
    }

    Http http = new Http();
    HTTPResponse res;
    try {
      res = http.send(req);
    } catch (Exception e) {
      System.debug(e.getMessage());
      throw new QBException(e.getMessage());
    }
    if (res.getStatusCode() >= 500 || res.getStatusCode() == 401) {
      throw new QBException(
        'An authorization error ocurred. Please ensure QIME is configured correctly before syncing'
      );
    }
    if (res.getStatusCode() == 301) {
      throw new QBException(
        'URL permanently moved. Please ensure the correct base url is used in the named credential.'
      );
    }
    System.debug(res.getBody());
    handleResponseError(res.getBody());
    return res;
  }

  /**
   * Throws exception if there is an error in the callout
   * @param body The json response from the QB callout
   */
  private static void handleResponseError(String body) {
    QBErrorJSON error = QBErrorJSON.parse(body);
    if (error != null) {
      if (
        error.Fault != null &&
        error.Fault.Error != null &&
        error.Fault.Error.size() > 0
      )
        throw new QBException(String.valueOf(error.Fault.Error[0]));
    }
  }

  /**
   * Get customer data from QBO based on QB Id
   * @param Account Account data to be queried from QBO
   * @return The wrapped json response from the QB callout
   */
  public static QBCustomerJSON getCustomer(Account a) {
    String query = '';
    qime__QIME_Config__mdt config = qime__QIME_Config__mdt.getInstance(
      'Default'
    );
    if (String.isNotBlank(a.qime__QB_Id__c)) {
      query = 'select * from customer where id = \'' + a.QB_Id__c + '\'';
    } else if (config.qime__Link_Customer_By_Name__c) {
      query = 'select * from customer where CompanyName = \'' + a.Name + '\'';
    } else if (String.isNotBlank(a.primary_email__c)) {
      query =
        'select * from customer where PrimaryEmailAddr = \'' +
        a.primary_email__c +
        '\'';
    }
    HttpResponse res = calloutHelper('query', 'POST', query);
    return QBCustomerJSON.parse(res.getBody());
  }

  /**
   * Create customer data from QBO based on QB Id
   * @param customerJson Account data as a json
   * @return The wrapped json response from the QB callout
   */
  public static QBCustomerResponseJSON createCustomer(String customerJson) {
    HttpResponse res = calloutHelper('customer', 'POST', customerJson);
    return QBCustomerResponseJSON.parse(res.getBody());
  }

  /**
   * Query invoice based on QB Id
   * @param inv Invoice to be queried
   * @return The wrapped json response from the QB callout
   */
  public static QBInvoiceQueryJSON getInvoice(Invoice__c inv) {
    String query = 'select * from invoice where id = \'' + inv.QB_Id__c + '\'';
    HttpResponse res = calloutHelper('query', 'POST', query);
    return QBInvoiceQueryJSON.parse(res.getBody());
  }

  /**
   * Get Invoice count from QBO
   * @return The wrapped json response from the QB callout
   */
  public static QBQueryResponseCountJSON getInvoiceCount() {
    HttpResponse res = calloutHelper(
      'query',
      'POST',
      'select count(*) from Invoice'
    );
    return QBQueryResponseCountJSON.parse(res.getBody());
  }

  /**
   * Get Customer count from QBO
   * @return The wrapped json response from the QB callout
   */
  public static QBQueryResponseCountJSON getCustomerCount() {
    HttpResponse res = calloutHelper(
      'query',
      'POST',
      'select count(*) from Customer'
    );
    return QBQueryResponseCountJSON.parse(res.getBody());
  }

  /**
   * Get Payment count from QBO
   * @return The wrapped json response from the QB callout
   */
  public static QBQueryResponseCountJSON getPaymentCount() {
    HttpResponse res = calloutHelper(
      'query',
      'POST',
      'select count(*) from Payment'
    );
    return QBQueryResponseCountJSON.parse(res.getBody());
  }

  /**
   * Get Income Account from QBO
   * @return The wrapped json response from the QB callout
   */
  public static QBAccountQueryResponseJSON getIncomeAccounts() {
    HttpResponse res = calloutHelper(
      'query',
      'POST',
      'Select * FROM Account WHERE AccountType = \'Income\''
    );
    return QBAccountQueryResponseJSON.parse(res.getBody());
  }

  /**
   * Query invoices from QBO
   * @param query SQL format query
   * @return The wrapped json response from the QB callout
   */
  public static QBInvoiceQueryJSON queryInvoices(String query) {
    HttpResponse res = calloutHelper('query', 'POST', query);
    return QBInvoiceQueryJSON.parse(res.getBody());
  }

  /**
   * Query customers from QBO
   * @param query SQL format query
   * @return The wrapped json response from the QB callout
   */
  public static QBCustomerJSON queryCustomers(String query) {
    HttpResponse res = calloutHelper('query', 'POST', query);
    return QBCustomerJSON.parse(res.getBody());
  }

  /**
   * Create invoice in QBO based on provided data
   * @param invoiceJSON JSON formatted invoice data
   * @return The wrapped json response from the QB callout
   */
  public static QBInvoiceResponseJSON createInvoice(String invoiceJson) {
    HttpResponse res = calloutHelper('invoice', 'POST', invoiceJson);
    return QBInvoiceResponseJSON.parse(res.getBody());
  }

  /**
   * Get payment data from QBO
   * @param pmt Payment to be queried
   * @return The wrapped json response from the QB callout
   */
  public static QBPaymentQueryJSON getPayment(Payment__c pmt) {
    String query = 'select * from payment where id = \'' + pmt.QB_Id__c + '\'';
    HttpResponse res = calloutHelper('query', 'POST', query);
    return QBPaymentQueryJSON.parse(res.getBody());
  }

  /**
   * Query payments from QBO
   * @param query SQL format query
   * @return The wrapped json response from the QB callout
   */
  public static QBPaymentQueryJSON queryPayments(String query) {
    HttpResponse res = calloutHelper('query', 'POST', query);
    return QBPaymentQueryJSON.parse(res.getBody());
  }

  /**
   * Query terms from QBO
   * @return The wrapped json response from the QB callout
   */
  public static QBTermJSON queryTerms() {
    HttpResponse res = calloutHelper('query', 'POST', 'select * from Term');
    return QBTermJSON.parse(res.getBody());
  }

  /**
   * Create item in QBO based on provided data
   * @param itemJSON JSON formatted item data
   * @return The wrapped json response from the QB callout
   */
  public static QBItemResponseJSON createItem(String itemJSON) {
    HttpResponse res = calloutHelper('item', 'POST', itemJSON);
    return QBItemResponseJSON.parse(res.getBody());
  }

  public static QBSalesReceiptQueryJSON getSalesReceiptCount() {
    String query = 'select count(*) from SalesReceipt';
    return QBSalesReceiptQueryJSON.parse(
      calloutHelper('query', 'POST', query).getBody()
    );
  }

  public static QBSalesReceiptQueryJSON getSalesReceipts(String query) {
    return QBSalesReceiptQueryJSON.parse(
      calloutHelper('query', 'POST', query).getBody()
    );
  }
}
