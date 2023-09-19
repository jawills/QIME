import { LightningElement, wire, track } from 'lwc';

import checkNamedCredential from '@salesforce/apex/SetupChecklistController.checkNamedCredential';
import checkAuthProvider from '@salesforce/apex/SetupChecklistController.checkAuthProvider';
import checkExternalCredential from '@salesforce/apex/SetupChecklistController.checkExternalCredential';
import checkAuthentication from '@salesforce/apex/SetupChecklistController.checkAuthentication';

export default class QimeSetupChecklist extends LightningElement {
    @track authProviderLabel = 'Configure Auth. Provider';
    externalCredetnialLabel = 'Setup External Credential';
    namedCredentialLabel = 'Create Named Credential';
    authorizeQBOLabel = 'Authorize With Quickbooks';
    check = '✅'; // Unicode emoji for Green CheckBox 
    x = '❌'; // Unicode emoji for Red X 

    addEmoji(label, exists) {
        if(exists){
            label = label + this.check;
        }else{
            label = label + this.x;
        }
        return label;
    }


    @wire (checkAuthProvider)
    myAuthProvider(result) {
        if (result.data !== undefined) {
            this.authProviderLabel = this.addEmoji(this.authProviderLabel, result.data);
        }else{
            console.log(result);
        }
    }

    @wire (checkExternalCredential)
    myExternalCredential(result) {
        if (result.data !== undefined) {
            this.externalCredetnialLabel = this.addEmoji(this.externalCredetnialLabel, result.data);
        }
    }

    @wire (checkNamedCredential)
    myNamedCredential(result) {
        if (result.data !== undefined) {
            this.namedCredentialLabel = this.addEmoji(this.namedCredentialLabel, result.data);
        }
    }

    @wire (checkAuthentication)
    myAuthenticationCheck(result) {
        if (result.data !== undefined) {
            this.authorizeQBOLabel = this.addEmoji(this.authorizeQBOLabel, result.data);
        }
    }

}