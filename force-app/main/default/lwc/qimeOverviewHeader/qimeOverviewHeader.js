import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getEnvironmentDetails from '@salesforce/apex/OverviewController.getEnvironmentDetails';

const GITHUB_REPO_URL = 'https://github.com/jawills/QIME/';

export default class QimeOverviewHeader extends NavigationMixin(LightningElement) {
    environment = {};
    showEnvironmentDetailsModal = false;

    @wire(getEnvironmentDetails)
    wiredEnvironmentDetails({ data }) {
        if (data) {
            this.environment = data;
        }
    }

    get title() {
        let titleText = 'QIME';
        if (this.environment.loggerVersionNumber) {
            titleText += ' ' + this.environment.qimeVersionNumber;
        }
        return titleText;
    }


    get environmentDetailsButtonLabel() {
        return `View Environment Details`;
    }

    get showReleaseNotesButton() {
        return !!this.environment?.qimeVersionNumber;
    }

    get releaseNotesButtonLabel() {
        return `View ${this.environment.qimeVersionNumber} Release Notes`;
    }

    handleViewReleaseNotes() {
        const pageReference = {
            type: 'standard__webPage',
            attributes: {
                url: `${GITHUB_REPO_URL}releases/tag/${this.environment.qimeVersionNumber}`
            }
        };
        this[NavigationMixin.Navigate](pageReference);
    }

}