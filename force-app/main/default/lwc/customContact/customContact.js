import { LightningElement, wire, track, api } from 'lwc';
import objectName from '@salesforce/schema/Contact_Custom__c';
import getData from '@salesforce/apex/DynamicTable.getData';
import uploadData from '@salesforce/apex/DynamicTable.uploadData';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import gender from '@salesforce/schema/Contact_Custom__c.PickList__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';


export default class CustomContact extends LightningElement {

    countId = 1;
    obName = objectName.objectApiName;
    objectFields = [];
    @track data = [];
    @track enableEdit = false;
    @track editView;
    @track genderPickList = [];
    @api accountid = '0015g000019NGt4AAG';
    changePostionOfScrollTop = false;

    //Wire method for getting picklist values for gender field...
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: gender })
    genderValue({ data, error }) {
        if (data) {
            this.genderPickList = data.values;
            console.log(data.values);
        } else if (error) {
            console.log(error);
        }
    }

    get disableD() {
        return !this.enableEdit;
    }

    renderedCallback() {
        if (this.changePostionOfScrollTop == true) {
            var tables = this.template.querySelectorAll('.slds-table_col-bordered');
            tables[0].scrollTop = tables[0].scrollHeight;
            this.changePostionOfScrollTop = false;
        }
    }

    connectedCallback() {
        console.log('accounr id--->    ' + this.accountid);
        //Getting objects records....
        getData({ accountId: this.accountid })
            .then(result => {
                console.log(result[0]);
                var tmpData = result[0].Contact_Customs__r;
                this.enableEdit = (result[0].Status__c == 'Open') ? true : false;
                console.log(this.enableEdit);
                var currentDate = new Date();
                for (var x of tmpData) {
                    x.attributes = { "type": "Contact_Custom__c" };
                    var recordDate = new Date(x.Date__c);
                    if (recordDate.getDate() == currentDate.getDate() && recordDate.getMonth() == currentDate.getMonth() && recordDate.getFullYear() == currentDate.getFullYear()) {
                        x.isToday = true;
                    } else {
                        x.isToday = false;
                    }
                }
                this.data = tmpData;
            })
            .catch(error => {
                console.log(error);
            })
    }

    addRowMethod() {
        var newRow = { Id: this.countId, attributes: { "type": "Contact_Custom__c" } };
        this.data.push(newRow);
        this.countId++;
        this.changePostionOfScrollTop = true
    }

    getValue(event) {
        var val = event.detail.value;
        var recordId = event.target.dataset.id;
        var fieldType = event.target.dataset.name;

        if (fieldType == 'Name') {
            for (var x of this.data) {
                if (x.Id == recordId) {
                    x.Name = val;
                    break;
                }
            }
        } else if (fieldType == 'Date') {
            for (var x of this.data) {
                if (x.Id == recordId) {
                    x.Date__c = val;
                    break;
                }
            }
        } else if (fieldType == 'gender') {
            for (var x of this.data) {
                if (x.Id == recordId) {
                    x.Industry__c = val;
                    break;
                }
            }
        }
    }

    @api isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
            //this.contact[inputField.name] = inputField.value;
        });
        return isValid;
    }


    @api
    async enable_Disable_With_Update() {
        // here we convert edit or save button visiblity...
        this.enableEdit = !this.enableEdit;
        // it will called only when save button pressed and enableEdit value going to false...
        if (this.enableEdit == false) {
            var records = this.data;
            if (this.isInputValid()) {
                for (var x of records) {
                    x.parent__c = this.accountid;
                    if (parseInt(x.Id) <= parseInt(this.countId)) {
                        delete (x.Id);
                    }
                }

                uploadData({ updatingRecords: records })
                    .then((result) => {
                        var currentDate = new Date();
                        for (var x of result) {
                            x.attributes = { "type": "Contact_Custom__c" };
                            var recordDate = new Date(x.Date__c);
                            if (recordDate.getDate() == currentDate.getDate() && recordDate.getMonth() == currentDate.getMonth() && recordDate.getFullYear() == currentDate.getFullYear()) {
                                x.isToday = true;
                            } else {
                                x.isToday = false;
                            }
                        }
                        console.log('in success part');
                        this.data = result;
                    })
                    .catch(error => {
                        console.log(error);
                    })
                return true;
            } else {
                this.enableEdit = !this.enableEdit;
                return false;
            }
        }
    }

    delete_record(event) {
        var recordId = event.currentTarget.dataset.id;
        console.log(recordId);
        if (recordId.length > 10) {
            deleteRecord(recordId)
                .then(() => {
                    for (var i = 0; i < this.data.length; i++) {
                        if (this.data[i].Id == recordId) {
                            this.data.splice(i, 1);
                            // after delete record a pop alert show using toast event...
                            this.ShowToast('Delete', 'Success.', 'success');
                            break;
                        }
                    }
                })
                .catch(error => {
                    this.ShowToast('Deletion Failed', 'Error.', 'error');
                })
        }
        // If record is not present in database but present in data list from add row....
        else {
            for (var i = 0; i < this.data.length; i++) {
                if (this.data[i].Id == recordId) {
                    this.data.splice(i, 1);
                    this.ShowToast('Get Help', 'Success.', 'Success');
                    break;
                }
            }
        }
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