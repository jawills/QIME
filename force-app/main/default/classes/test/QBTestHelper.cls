public class QBTestHelper {
    public static qime__QB_Credential__mdt getCredential(){
        qime__QB_Credential__mdt creds = new qime__QB_Credential__mdt();
        creds.DeveloperName = 'QB_Provider';
        creds.Realm_Id__c = '1234';
        creds.MinorVersion__c = '60';
        return creds;
    }

    public static qime__QIME_Config__mdt getConfig(){
        qime__QIME_Config__mdt config = new qime__QIME_Config__mdt();
        config.DeveloperName = 'Default';
        config.qime__Line_Item_Id__c = '1';
        config.qime__Use_Single_Line_Item__c = true;
        config.qime__Link_Invoice_To_Opp_Using_Memo__c = true;
        return config;
    } 
}