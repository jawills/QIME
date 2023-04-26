public class QBTestHelper {
    public static qime__QB_Credential__mdt getCredential(){
        qime__QB_Credential__mdt creds = new qime__QB_Credential__mdt();
        creds.DeveloperName = 'QB_Provider';
        creds.Realm_Id__c = '1234';
        creds.MinorVersion__c = '60';
        return creds;
    } 
}