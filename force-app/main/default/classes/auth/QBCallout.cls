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

    private static HttpResponse calloutHelper(String endpoint, String method, String body){
        QIME__QB_Credential__mdt credentials;
        if(Test.isRunningTest()){
            credentials = QBTestHelper.getCredential();
        }else{
            List<QIME__QB_Credential__mdt> creds = [SELECT Id, Realm_Id__c, MinorVersion__c FROM QIME__QB_Credential__mdt WHERE DeveloperName = 'QB_Auth_Provider'];
            if(creds.size() > 0){
                credentials = creds[0];
            }else{
                throw new QBException('Please ensure your auth provider has the Developer Name: \'QB_Auth_Provider\'');
            }
        }
        
        HttpRequest req = new HttpRequest();
        String url = 'v3/company/' + credentials.Realm_Id__c + '/' + endpoint;
        if(!url.contains('?')){
            url += '?minorversion=' + credentials.MinorVersion__c;
        }else{
            url += '&minorversion=' + credentials.MinorVersion__c;
        }
        req.setEndpoint('callout:QB_Named_Credential/' + url);
        req.setMethod(method);
        if(body != null){
            System.debug(body);
            req.setBody(body);
        }
        req.setheader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer {!$Credential.OAuthToken}');

        if(endpoint.contains('query')){
            req.setHeader('Content-Type', 'application/text');
        }
        

        Http http = new Http();
        HTTPResponse res;
        try{
            res = http.send(req);
        }catch(Exception e){
            throw new QBException(e.getMessage());
        }
        System.debug(res.getBody());
        handleResponseError(res.getBody());
        return res;
    }


    /**
     * Throws exception if there is an error in the callout
     * @param body The json response from the QB callout
     */
    private static void handleResponseError(String body){
        QBErrorJSON error = QBErrorJSON.parse(body);
        if(error != null){
            if(error.Fault != null && error.Fault.Error != null && error.Fault.Error.size() > 0)
            Throw new QBException(String.valueOf(error.Fault.Error[0]));
        }
    }

    public static QBCustomerJSON getCustomer(Account a){
        String query = 'select * from customer where id = \'' + a.QIME__QB_Id__c + '\'';
        HttpResponse res = calloutHelper('query', 'POST', query);
        return QBCustomerJSON.parse(res.getBody());
    }


    public static QBCustomerResponseJSON createCustomer(String customerJson){
        HttpResponse res = calloutHelper('customer', 'POST', customerJson);
        return QBCustomerResponseJSON.parse(res.getBody());
    }

    public static QBInvoiceQueryJSON getInvoice(Invoice__c inv){
        String query = 'select * from invoice where id = \'' + inv.QIME__QB_Id__c + '\'';
        HttpResponse res = calloutHelper('query', 'POST', query);
        return QBInvoiceQueryJSON.parse(res.getBody());
    }

    public static QBQueryResponseCountJSON getInvoiceCount(){
        HttpResponse res = calloutHelper('query', 'POST', 'select count(*) from Invoice');
        return QBQueryResponseCountJSON.parse(res.getBody());
    }

    public static QBInvoiceQueryJSON queryInvoices(String query){
        HttpResponse res = calloutHelper('query', 'POST', query);
        return QBInvoiceQueryJSON.parse(res.getBody());
    }

    public static QBInvoiceResponseJSON createInvoice(String invoiceJson){
        HttpResponse res = calloutHelper('invoice', 'POST', invoiceJson);
        return QBInvoiceResponseJSON.parse(res.getBody());
    }

    public static QBPaymentQueryJSON getPayment(Payment__c pmt){
        String query = 'select * from payment where id = \'' + pmt.QIME__QB_Id__c + '\'';
        HttpResponse res = calloutHelper('query', 'POST', query);
        return QBPaymentQueryJSON.parse(res.getBody());
    }

    public static QBPaymentQueryJSON queryPayments(String query){
        HttpResponse res = calloutHelper('query', 'POST', query);
        return QBPaymentQueryJSON.parse(res.getBody());
    }

    public static QBQueryResponseCountJSON getPaymentCount(){
        HttpResponse res = calloutHelper('query', 'POST', 'select count(*) from Payment');
        return QBQueryResponseCountJSON.parse(res.getBody());
    }

    public static QBTermJSON queryTerms(){
        HttpResponse res = calloutHelper('query', 'POST', 'select * from Term');
        return QBTermJSON.parse(res.getBody()); 
    }


}