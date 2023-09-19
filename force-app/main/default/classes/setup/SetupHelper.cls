public with sharing class SetupHelper {

    private static final String AUTH_URL = 'https://appcenter.intuit.com/connect/oauth2';
    private static final String AUTH_PROVIDER_NAME = 'QB_Auth_Provider';
    private static final String AUTH_PROVIDER_LABEL = 'QB Auth Provider';
    private static final String PROVIDER_TYPE = 'qime__QBAuthProvider';
    private static final String PLUGIN = 'qime__QBAuthProvider';
    private static final String NAMED_CREDENTIAL_NAME = 'QB_Named_Credential';
    private static final String CUSTOM_METADATA_NAME = 'qime__QB_Credential__mdt.QB_Auth_Provider';
    private static final String TOKEN_URL = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
    private static final String SCOPE = 'com.intuit.quickbooks.accounting';

    /**
     * @description Create the initial Auth Provider used for QIME
     * @param clientId
     */
    public static void createAuthProvider(String clientId, String clientSecret, String executionUser){
        MetadataService.MetadataPort service = createService();
        MetadataService.AuthProvider authProvider = getAuthProvider();

        // If full Name == null, no match is found
        Boolean isUpdate = authProvider.fullName != null;

        authProvider.fullName = AUTH_PROVIDER_NAME;
        authProvider.friendlyName = AUTH_PROVIDER_LABEL;
        authProvider.authorizeUrl = AUTH_URL;
        authProvider.consumerKey = clientId;
        authProvider.consumerSecret = clientSecret;
        authProvider.customMetadataTypeRecord = CUSTOM_METADATA_NAME;
        authProvider.defaultScopes = SCOPE;
        authProvider.executionUser = executionUser; // Required Field
        authProvider.plugin = PLUGIN;
        authProvider.providerType = 'Custom';
        authProvider.sendAccessTokenInHeader = false;
        authProvider.tokenUrl = TOKEN_URL;

        // Provider Type: QBAuthProvider
        // Name: QB Auth Provider
        // URL Suffix: QB_Auth_Provider
        // Auth URL: https://appcenter.intuit.com/connect/oauth2
        // Token URL: https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer
        // Scope: com.intuit.quickbooks.accounting
        // Realm Id: The company Id copied previously
        // Minorversion: 65
        // Execute Registration As: Any Admin User
        
        //We can save the results in a List<SaveResult> to determine if the metadata service exits 
        if (!isUpdate){
            List<MetadataService.SaveResult> insertResults = service.createMetadata(new MetadataService.Metadata[] { authProvider });
            handleSaveResults(insertResults[0]);
        }else{
            List<MetadataService.SaveResult> updateResults =service.updateMetadata(new MetadataService.Metadata[] { authProvider });
            handleSaveResults(updateResults[0]);
        }
        
    }

    public static MetadataService.AuthProvider getAuthProvider(){
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        // You use the developer name which is unique, and the result can never be null, so indexing the first record is 'safe'
        MetadataService.AuthProvider result = (MetadataService.AuthProvider) service.readMetadata('AuthProvider', new String[] {AUTH_PROVIDER_NAME}).getRecords()[0];
        // If full Name == null, no match is found
        System.debug(result.fullName);
        System.debug(result.friendlyName);
        System.debug(result.consumerSecret);
        System.debug(result.providerType);
        System.debug(result.plugin);
        return result;
    }

    public static MetadataService.NamedCredential getNamedCredential(){
        MetadataService.MetadataPort service = createService();
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        
        // You use the developer name which is unique, and the result can never be null, so indexing the first record is 'safe'
        MetadataService.NamedCredential result = (MetadataService.NamedCredential) service.readMetadata('NamedCredential', new String[] {NAMED_CREDENTIAL_NAME}).getRecords()[0];
        // If full Name == null, no match is found
        System.debug(result.fullName);
        return result;
    }

    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        QIME.SessionId sessionObj = (QIME.SessionId) JSON.deserialize(QIME.getSessionIdFromVFPage(Page.SessionIdPage), QIME.SessionId.class);
        // UserInfo.getSessionId();
        System.debug(sessionObj.sessionId);
        service.SessionHeader.sessionId = sessionObj.sessionId;
        return service;
    }

    /**
     * Example helper method to interpret a SaveResult, throws an exception if errors are found
     **/
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors){
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            }
            for(String message : messages){
                System.debug(message);
            }
        }
        
    }

    public static void createExternalCredential(){
        MetadataService.MetadataPort service = createService();
        MetadataService.ExternalCredential externalCredential = new MetadataService.ExternalCredential();
        externalCredential.authenticationProtocol = 'Oauth';
        externalCredential.description = 'QIME External Credential';
        externalCredential.label = 'QB External Credential';
        externalCredential.fullName = 'QB_External_Credential';
        // externalCredential.externalCredentialParameters = new List<MetadataService.ExternalCredentialParameter>();
        // MetadataService.ExternalCredentialParameter authProvider = new MetadataService.ExternalCredentialParameter();
        // authProvider.authProvider = AUTH_PROVIDER_NAME;
        // authProvider.parameterType = 'AuthProvider';
        // authProvider.parameterName = 'AuthProvider';
        // externalCredential.externalCredentialParameters.add(authProvider);

        List<MetadataService.SaveResult> insertResults = service.createMetadata(new MetadataService.Metadata[] { externalCredential });
        handleSaveResults(insertResults[0]);
    }

    // public static void createNamedCredential(){
    //     MetadataService.MetadataPort service = createService();
    //     MetadataService.NamedCredential credential = new MetadataService.NamedCredential();
    //     credential.fullName = 'Demo_Credential';
    //     credential.label = 'Demo Credential';
    //     credential.endpoint = 'https://www.DEMO2.com';
    //     credential.principalType = 'NamedUser';
    //     credential.protocol = 'NoAuthentication';

    //     // Label: QB External Credential
    //     // Name: QB External Credential
    //     // Authentication Protocol: OAuth 2.0
    //     // Authentication Flow Type: Browser Flow
    //     // Authentication Provider: QBAuthProvider


    //     // Label: QB Named Credential
    //     // Name: QB_Named_Credential
    //     // URL: https://quickbooks.api.intuit.com *
    //     // External Credential: QB External Credential
    //     // Generate Authorization Header: False
    //     // Allow Formulas in HTTP Header: True
    //     // Allowed Namespaces: QIME

    //     system.debug(createMetadata(credential));
    //     system.debug(updateMetadata(credential));
    // }
}