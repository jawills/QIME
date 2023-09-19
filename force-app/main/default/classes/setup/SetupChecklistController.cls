public with sharing class SetupChecklistController {

    @AuraEnabled(cacheable=True)
    public static Boolean checkNamedCredential(){
        MetadataService.NamedCredential namedCredential = SetupHelper.getNamedCredential();
        return namedCredential?.fullName != null;
    }

    @AuraEnabled(cacheable=True)
    public static Boolean checkAuthProvider(){
        MetadataService.AuthProvider authProvider = SetupHelper.getAuthProvider();
        return authProvider?.fullName != null;

    }

    @AuraEnabled(cacheable=True)
    public static Boolean checkExternalCredential(){
        MetadataService.NamedCredential externalCredential = SetupHelper.getNamedCredential();
        return externalCredential?.fullName != null;

    }

    @AuraEnabled(cacheable=True)
    public static Boolean checkAuthentication(){
        try {
            return QBCallout.getCustomerCount()?.QueryResponse?.totalCount >= 0;
        }catch (Exception e){

        }
        return false;
    }
}