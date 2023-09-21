@IsTest 
public class QBAuthProviderTest { 
        private static final String OAUTH_TOKEN = 'access_token'; 
        private static final String STATE = 'mocktestState'; 
        private static final String REFRESH_TOKEN = 'refresh'; 
        private static final String LOGIN_ID = 'fakeId'; 
        private static final String USERNAME = 'testUsername'; 
        private static final String FIRST_NAME = 'first'; 
        private static final String LAST_NAME = 'last'; 
        private static final String EMAIL_ADDRESS = 'email'; 
        private static final String LOCALE_NAME = 'locale'; 
        private static final String FULL_NAME = FIRST_NAME + ' ' + LAST_NAME; 
        private static final String PROVIDER = 'QBAuth'; 
        private static final String REDIRECT_URL = 
        'http://salesforce/services/callback'; 
        private static final String KEY = 'testKey'; 
        private static final String SECRET = 'testSecret';
        private static final String SCOPE = 'scope';  
        private static final String STATE_TO_PROPOGATE = 'testState'; 
        private static final String ACCESS_TOKEN_URL = 
        'https://appcenter.intuit.com/accessTokenUri'; 
        private static final String API_USER_VERSION_URL = 
        'https://appcenter.intuit.com/user/20/1'; 
        private static final String AUTH_URL = 
        'https://appcenter.intuit.com/authurl'; 
        private static final String API_USER_URL = 
        'https://appcenter.intuit.com/user/api'; 
    
    /**
     * Setup test data for Named credential parameters
     * @return Map of custom metadata values
     */
    private static Map<String,String> setupAuthProviderConfig () 
    { 
        Map<String,String> authProviderConfiguration = new Map<String,String>(); 
        authProviderConfiguration.put('qime__Client_Id__c', KEY); 
        authProviderConfiguration.put('qime__Auth_URL__c', AUTH_URL); 
        authProviderConfiguration.put('qime__Client_Secret__c', SECRET); 
        authProviderConfiguration.put('qime__Token_URL__c', ACCESS_TOKEN_URL); 
        authProviderConfiguration.put('qime__API_User_Url__c',API_USER_URL); 
        authProviderConfiguration.put('qime__API_User_Version_Url__c',
        API_USER_VERSION_URL); 
        authProviderConfiguration.put('qime__Scope__c', SCOPE); 
        authProviderConfiguration.put('qime__Callback_URL__c',REDIRECT_URL); 
        return authProviderConfiguration; 
    
    } 
    
    @isTest static void testInitiateMethod() 
    { 
        String stateToPropogate = 'mocktestState'; 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        QBAuthProvider authProv = new QBAuthProvider(); 
        authProv.redirectUrl = authProviderConfiguration.get('qime__Callback_URL__c'); 
        PageReference expectedUrl = new PageReference(authProviderConfiguration.get('qime__Auth_URL__c') + '?client_id='+ 
        authProviderConfiguration.get('qime__Client_Id__c') +'&response_type=code&scope=scope&redirect_uri='+ 
        authProviderConfiguration.get('qime__Callback_URL__c') + '&state=' + 
        STATE_TO_PROPOGATE); 
        PageReference actualUrl = authProv.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
    } 
    
    @isTest static void testHandleCallback() 
    { 
        Map<String,String> authProviderConfiguration = 
        setupAuthProviderConfig(); 
        QBAuthProvider authProv = new QBAuthProvider(); 
        authProv.redirectUrl = authProviderConfiguration.get
        ('qime__Redirect_Url_c'); 
    
        Test.setMock(HttpCalloutMock.class, new 
        QBAuthMockHttpResponseGenerator()); 
    
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',authProviderConfiguration.get('qime__State_c')); 
        Auth.AuthProviderCallbackState cbState = 
        new Auth.AuthProviderCallbackState(null,null,queryParams); 
        Auth.AuthProviderTokenResponse actualAuthProvResponse = 
        authProv.handleCallback(authProviderConfiguration, cbState); 
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = 
        new Auth.AuthProviderTokenResponse(
        'QBO', OAUTH_TOKEN, REFRESH_TOKEN, null); 
    
        System.assertEquals(expectedAuthProvResponse.provider, 
        actualAuthProvResponse.provider); 
        System.assertEquals(expectedAuthProvResponse.oauthToken, 
        actualAuthProvResponse.oauthToken); 
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, 
        actualAuthProvResponse.oauthSecretOrRefreshToken); 
        System.assertEquals(expectedAuthProvResponse.state, 
        actualAuthProvResponse.state); 

    } 
        
    @isTest static void testGetUserInfo() 
    { 
        Map<String,String> authProviderConfiguration = 
        setupAuthProviderConfig(); 
        QBAuthProvider authProv = new QBAuthProvider(); 
    
        Test.setMock(HttpCalloutMock.class, new 
        QBAuthMockHttpResponseGenerator()); 
    
        Auth.AuthProviderTokenResponse response = 
        new Auth.AuthProviderTokenResponse(
        PROVIDER, OAUTH_TOKEN ,'sampleOauthSecret', STATE); 
        Auth.UserData actualUserData = authProv.getUserInfo(
        authProviderConfiguration, response) ; 
    
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('key1', 'value1'); 
        provMap.put('key2', 'value2'); 
    
        Auth.UserData expectedUserData = new Auth.UserData(LOGIN_ID, 
        FIRST_NAME, LAST_NAME, FULL_NAME, EMAIL_ADDRESS, 
        null, LOCALE_NAME, null, PROVIDER, null, provMap); 
    
        System.assertNotEquals(expectedUserData,null); 
        System.assertEquals(expectedUserData.firstName, 
        actualUserData.firstName); 
        System.assertEquals(expectedUserData.lastName, 
        actualUserData.lastName); 
        System.assertEquals(expectedUserData.fullName, 
        actualUserData.fullName); 
        System.assertEquals(expectedUserData.email, 
        actualUserData.email); 
        System.assertEquals(expectedUserData.username, 
        actualUserData.username); 
        System.assertEquals(expectedUserData.locale, 
        actualUserData.locale); 
        System.assertEquals(expectedUserData.provider, 
        actualUserData.provider); 
        System.assertEquals(expectedUserData.siteLoginUrl, 
        actualUserData.siteLoginUrl); 
    } 
    
    
    /**
     * Implement a mock http response generator for QBAuth.
     */ 
    public class QBAuthMockHttpResponseGenerator implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        {   
            // Create a fake response 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            res.setBody('{"x_refresh_token_expires_in":8726208,"refresh_token":"refresh","access_token":"access_token","token_type":"bearer","expires_in":3600}'); 
            res.setStatusCode(200); 
            return res; 
        } 
    
    } 
}