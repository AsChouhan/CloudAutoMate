import { LightningElement, track, api, wire } from 'lwc';
import STATUS from '@salesforce/schema/Account.Status__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ParentComponentForDT extends LightningElement {
    @track enableEdit;

    @api recordId = '0015g000019NGt4AAG';

    status;

    @wire(getRecord, { recordId: '$recordId', fields: STATUS })
    account({ data, error }) {
        if (data) {
            this.status = getFieldValue(data, STATUS);
        } else {
            console.log(error);
        }
    }

    // get gEnable() {
    //     console.log('get Enble called');
    //     var childMethod = this.template.querySelector('c-custom-acc');
    //     console.log(childMethod);
    //     console.log(childMethod.disableD());
    //     return childMethod.disableD();
    // }

    connectedCallback() {
        console.log('connected call back called');
        setTimeout(() => {
            console.log(this.status);
            if (this.status == 'Open') {
                console.log('inside open status');
                this.enableEdit = true;
                console.log(this.enableEdit);
            }
        }, 2000);
    }

    pressEdit() {
        var childMethod = this.template.querySelector('c-custom-acc');
        var contactcus = this.template.querySelector('c-custom-contact');
        var caseCus = this.template.querySelector('c-case-custom');
        var contractCus = this.template.querySelector('c-contract-custom');


        childMethod.enable_disable_EditFunctionalities();
        contactcus.enable_Disable_With_Update();
        caseCus.enable_Disable_With_Update();
        contractCus.enable_Disable_With_Update();

        this.enableEdit = true;
    }

    pressSave() {
        var childMethod = this.template.querySelector('c-custom-acc');
        var contactcus = this.template.querySelector('c-custom-contact');
        var caseCus = this.template.querySelector('c-case-custom');
        var contractCus = this.template.querySelector('c-contract-custom');


        childMethod.enable_disable_EditFunctionalities().then(result => {
            if (result == true) {
                contactcus.enable_Disable_With_Update().then(result => {
                    if (result == true) {
                        caseCus.enable_Disable_With_Update().then(result => {
                            if (result == true) {
                                contractCus.enable_Disable_With_Update().then(result => {
                                    if (result == true) {
                                        console.log('comes at the end contract');
                                        this.enableEdit = false;
                                        this.ShowToast('Success!', 'Saved.', 'Success');
                                    }
                                    else {
                                        childMethod.enable_disable_EditFunctionalities();
                                        contactcus.enable_Disable_With_Update();
                                        caseCus.enable_Disable_With_Update();
                                        this.ShowToast('Error!', 'Failed To Save At Contract.', 'error');
                                    }
                                })
                            } else {
                                childMethod.enable_disable_EditFunctionalities();
                                contactcus.enable_Disable_With_Update();
                                this.ShowToast('Error!', 'Failed To Save At Case.', 'error');
                            }
                        })
                    } else {
                        childMethod.enable_disable_EditFunctionalities();
                        this.ShowToast('Error!', 'Failed To Save At Contact.', 'error');
                    }
                })
            } else {
                this.enableEdit = true;
                this.ShowToast('Error!', 'Failed To Save At Account.', 'error');
            }
        })
    }


    ShowToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}