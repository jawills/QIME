global class QBAuthProvider extends Auth.AuthProviderPluginClass {
               
    public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
    private String key;
    private String secret;
    private String scope;
    private String authUrl;    // application redirection to the Concur website for authentication and authorization
    private String accessTokenUrl; // uri to get the new access token from concur  using the GET verb
    private String customMetadataTypeApiName = 'qime__QB_Credential__mdt';
    private String userAPIUrl; // api url to access the user in concur
    private String userAPIVersionUrl; // version of the user api url to access data from concur

    /**
     * @description Get the static value of the custom metadata name
     * @return Developer name of custom metadata name
     */
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }


    /**
     * @description Initiate OAuth 2.0 sequence
     * @return OAuth 2.0 page start
     */
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        key = authProviderConfiguration.get('qime__Client_Id__c');
        authUrl = authProviderConfiguration.get('qime__Auth_URL__c');
        scope = authProviderConfiguration.get('qime__Scope__c');
        redirectUrl = authProviderConfiguration.get('qime__Callback_URL__c');
        String urlToRedirect = authUrl+'?response_type=code&client_id='+key+'&redirect_uri='+redirectUrl+'&scope='+scope+
                        '&state='+stateToPropagate;      
        PageReference pageRef = new PageReference(urlToRedirect);                    
        return pageRef; 
    }

    /**
     * @description Handle OAuth 2.0 callback
     * @return Wrapped Oauth2.0 token data
     */
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        //Here, the developer will get the callback with actual protocol.  
        //Their responsibility is to return a new object called AuthProviderToken
        //This will contain an optional accessToken and refreshToken
        key = authProviderConfiguration.get('qime__Client_Id__c'); 
        secret = authProviderConfiguration.get('qime__Client_Secret__c'); 
        accessTokenUrl = authProviderConfiguration.get('qime__Token_URL__c'); 
        authUrl = authProviderConfiguration.get('qime__Auth_URL__c');
        scope = authProviderConfiguration.get('qime__Scope__c');
        redirectUrl = authProviderConfiguration.get('qime__Callback_URL__c');
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
        HttpRequest req = new HttpRequest();
        String url = accessTokenUrl;
        String header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(key + ':' + secret));
        
        String body = 'code=' + code + '&grant_type=authorization_code&redirect_uri=' + redirectUrl ;
        req.setEndpoint(url);
        req.setHeader('Authorization', header);
        req.setHeader('Accept','application/json');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');

        req.setBody(body);
        req.setMethod('POST');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        BearerTokenWrapper wrapper = (BearerTokenWrapper)System.JSON.deserialize(responseBody, BearerTokenWrapper.class);

        return new Auth.AuthProviderTokenResponse('QBO', wrapper.access_token, wrapper.refresh_token, sfdcState);
    }

    /**
     * @description Handle OAuth 2.0 refresh
     * @return Wrapped Oauth2.0 refresh data
     */
    global override Auth.OAuthRefreshResult refresh(Map<String,String> authProviderConfiguration, String refreshToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(authProviderConfiguration.get('qime__Token_URL__c'));

        String clientId = authProviderConfiguration.get('qime__Client_Id__c');
        String clientSecret = authProviderConfiguration.get('qime__Client_Secret__c');

        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Accept','application/json');

        String header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret));
        req.setHeader('Authorization', header);

        String body = 'grant_type=refresh_token&refresh_token=' + refreshToken;
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        BearerTokenWrapper response = (BearerTokenWrapper) JSON.deserialize(res.getBody(), BearerTokenWrapper.class);

        return new Auth.OAuthRefreshResult(response.access_token, response.refresh_token);
    }

    /**
     * @description Handle OAuth 2.0 user info
     * @return Wrapped Oauth2.0 user data
     */
    global Auth.UserData  getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        System.debug(LoggingLevel.WARN, 'getUserInfo-config: ' + authProviderConfiguration);
        System.debug(LoggingLevel.WARN, 'getUserInfo-response: ' + response);
        return new Auth.UserData('fakeId', 'first', 'last', 'first last', 'email', 'link', 'locale', null, 'QBAuth', null, null);

    }
    
    /**
     * @description Wrapper class to parse OAuth token data
     */
    @SuppressWarnings('PMD.PropertyNamingConventions, PMD.VariableNamingConventions, PMD.FieldNamingConventions')
    public class BearerTokenWrapper{
        public Integer x_refresh_token_expires_in;
        public String refresh_token {get; set;}
        public String access_token {get;set;}
        public Integer expires_in;
        public String token_type;
    }

}

