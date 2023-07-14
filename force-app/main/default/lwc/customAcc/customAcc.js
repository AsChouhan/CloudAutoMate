
import { LightningElement, wire, track, api } from 'lwc';
import objectName from '@salesforce/schema/AccountCustom__c';
import getData from '@salesforce/apex/DynamicTable.getData';
import uploadData from '@salesforce/apex/DynamicTable.uploadData';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import industry from '@salesforce/schema/AccountCustom__c.Industry__c';
import rating from '@salesforce/schema/AccountCustom__c.Rating__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class CustomAcc extends LightningElement {


    countId = 1;
    obName = objectName.objectApiName;
    objectFields = [];
    @track data = [];
    @track enableEdit = false;
    @track industryList = [];
    @track ratingList = [];
    @api accountid = '0015g000019NGt4AAG';
    @track tableRefrence;
    changePostionOfScrollTop = false;

    //Wire method for getting picklist values for industry field...
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: industry })
    industryValue({ data, error }) {
        if (data) {
            this.industryList = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    //Wire method for getting picklist values for rating field...
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: rating })
    ratingValue({ data, error }) {
        if (data) {
            this.ratingList = data.values;
        } else if (error) {
            console.log(error);
        }
    }

    // wire method for getting object info...
    @wire(getObjectInfo, { objectApiName: objectName })
    objectInfo;

    get disableD() {
        return !this.enableEdit;
    }

    connectedCallback() {
        //Getting objects records....
        getData({ accountId: this.accountid })
            .then(result => {
                var tmpData = result[0].AccountCustoms__r;
                this.enableEdit = (result[0].Status__c == 'Open') ? true : false;
                var currentDate = new Date();
                for (var x of tmpData) {
                    x.attributes = { "type": "AccountCustom__c" };
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

    renderedCallback() {
        if (this.changePostionOfScrollTop == true) {
            var tables = this.template.querySelectorAll('.slds-table_col-bordered');
            tables[0].scrollTop = tables[0].scrollHeight;
            this.changePostionOfScrollTop = false;
        }
    }

    addRowMethod() {
        var newRow = { Id: this.countId, attributes: { "type": "AccountCustom__c" } };
        this.data.push(newRow);
        this.changePostionOfScrollTop = true;
        this.countId++;
    }

    // Method for getting value inserted in column and add in that record...
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
        } else if (fieldType == 'Industry') {
            for (var x of this.data) {
                if (x.Id == recordId) {
                    x.Industry__c = val;
                    break;
                }
            }
        } else if (fieldType == 'Rating') {
            for (var x of this.data) {
                if (x.Id == recordId) {
                    x.Rating__c = val;
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
    async enable_disable_EditFunctionalities() {
        // here we convert edit or save button visiblity...
        this.enableEdit = !this.enableEdit;

        // it will called only when save button pressed and enableEdit value going to false...
        if (this.enableEdit == false) {
            var fil = this.data;
            if (this.isInputValid()) {
                for (var x of fil) {
                    x.parent__c = this.accountid;
                    if (parseInt(x.Id) <= parseInt(this.countId)) {
                        delete (x.Id);
                    }
                }

                uploadData({ updatingRecords: fil })
                    .then((result) => {
                        var currentDate = new Date();
                        for (var x of result) {
                            x.attributes = { "type": "AccountCustom__c" };
                            var recordDate = new Date(x.Date__c);
                            if (recordDate.getDate() == currentDate.getDate() && recordDate.getMonth() == currentDate.getMonth() && recordDate.getFullYear() == currentDate.getFullYear()) {
                                x.isToday = true;
                            } else {
                                x.isToday = false;
                            }
                        }
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
        if (recordId.length > 10) {
            deleteRecord(recordId)
                .then(() => {
                    for (var i = 0; i < this.data.length; i++) {
                        if (this.data[i].Id == recordId) {
                            this.data.splice(i, 1);
                            // after delete record a pop alert show using toast event...
                            const event = new ShowToastEvent({
                                title: 'Delete',
                                message: 'Success.',
                                variant: 'success'
                            });
                            this.dispatchEvent(event);
                            break;
                        }
                    }
                })
                .catch(error => {
                    const event = new ShowToastEvent({
                        title: 'Deletion Failed',
                        message: 'Error.',
                        variant: 'error',

                    });
                    this.dispatchEvent(event);
                })
        }
        // If record is not present in database but present in data list from add row....
        else {
            for (var i = 0; i < this.data.length; i++) {
                if (this.data[i].Id == recordId) {
                    this.data.splice(i, 1);
                    const event = new ShowToastEvent({
                        title: 'Get Help',
                        message: 'Success.',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);
                    break;
                }
            }
        }
    }
}