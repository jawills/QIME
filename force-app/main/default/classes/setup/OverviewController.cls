public with sharing class OverviewController {

    @AuraEnabled(cacheable=True)
    public static Integer getSFAccounts(){

        return [SELECT COUNT() FROM Account WHERE QB_Id__c != null WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=True)
    public static Integer getSFInvoices(){

        return [SELECT COUNT() FROM qime__Invoice__c WHERE QB_Id__c != null WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=True)
    public static Integer getSFPayments(){

        return [SELECT COUNT() FROM qime__Payment__c WHERE QB_Id__c != null WITH SECURITY_ENFORCED];
    }

    @AuraEnabled(cacheable=True)
    public static Integer getQBInvoices(){
        try{
            return QBCallout.getInvoiceCount()?.QueryResponse?.totalCount;
        }catch(Exception e){
            system.debug(e);
        }
        return null;
    }

    @AuraEnabled(cacheable=True)
    public static Integer getQBCustomers(){
        try{
            return QBCallout.getCustomerCount()?.QueryResponse?.totalCount;
        }catch (Exception e){
            System.debug(e);
        }
        return null;
    }


    @AuraEnabled(cacheable=True)
    public static Integer getQBPayments(){
        try{
            return QBCallout.getPaymentCount()?.QueryResponse?.totalCount;
        }catch (Exception e){
            System.debug(e);
        }
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Environment getEnvironmentDetails() {
        Environment environment = new Environment();
        environment.qimeVersionNumber = QIME.getVersionNumber();
        environment.organizationName = System.UserInfo.getOrganizationName();
        return environment;
    }

    @SuppressWarnings('PMD.ApexDoc, PMD.TooManyFields')
    public class Environment {
        @AuraEnabled
        public String qimeVersionNumber = 'Unknown';
        @AuraEnabled
        public String organizationName = 'Unknown';
    }
}