public class QBTestHelper {
    public static QB_Credential__mdt getCredential(){
        QB_Credential__mdt creds = new QB_Credential__mdt();
        creds.DeveloperName = 'QB_Provider';
        creds.Realm_Id__c = '1234';
        creds.MinorVersion__c = '60';
        return creds;
    }

    public static QIME_Config__mdt getConfig(){
        QIME_Config__mdt config = new QIME_Config__mdt();
        config.DeveloperName = 'Default';
        config.QB_Product_Id__c = '1';
        config.Use_Line_Item__c = true;
        config.Link_By_Memo__c = true;
        config.qime__Create_Invoice_From_Opp__c = true;
        config.Invoice_Stage_Name__c = 'Closed Won';
        return config;
    } 
}