import { LightningElement, wire, track, api } from 'lwc';
import objectName from '@salesforce/schema/ContractCustom__c';
import getData from '@salesforce/apex/DynamicTable.getData';
import uploadData from '@salesforce/apex/DynamicTable.uploadData';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import status from '@salesforce/schema/ContractCustom__c.Status__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
export default class ContractCustom extends LightningElement {
    countId = 1;
    obName = objectName.objectApiName;
    objectFields = [];
    @track data = [];
    @track enableEdit = false;
    @track editView;
    @track statusPickList = [];
    @api accountid = '0015g000019NGt4AAG';
    changePostionOfScrollTop = false;

    //Wire method for getting picklist values for gender field...
    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: status })
    statusValues({ data, error }) {
        if (data) {
            this.statusPickList = data.values;
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
        //Getting objects records....
        getData({ accountId: this.accountid })
            .then(result => {
                var tmpData = result[0].ContractCustoms__r;
                this.enableEdit = (result[0].Status__c == 'Open') ? true : false;
                var currentDate = new Date();
                for (var x of tmpData) {
                    x.attributes = { "type": "ContractCustom__c" };
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
        var newRow = { Id: this.countId, attributes: { "type": "ContractCustom__c" } };
        this.data.push(newRow);
        this.changePostionOfScrollTop = true;
        this.countId++;
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
        } else if (fieldType == 'Status') {
            for (var x of this.data) {
                if (x.Id == recordId) {
                    x.Status__c = val;
                    break;
                }
            }
        } else if (fieldType == 'Description') {
            for (var x of this.data) {
                if (x.Id == recordId) {
                    x.Description__c = val;
                    break;
                }
            }
        }
    }


    @api
    async enable_Disable_With_Update() {
        // here we convert edit or save button visiblity...
        this.enableEdit = !this.enableEdit;
        // it will called only when save button pressed and enableEdit value going to false...
        if (this.enableEdit == false) {
            var records = this.data;
            // Removing temprary id and check required field is filled or not...
            for (var x of records) {
                x.parent__c = this.accountid;
                if (parseInt(x.Id) <= parseInt(this.countId)) {
                    delete (x.Id);
                }
            }


            for (var x of records) {
                console.log(JSON.stringify(x));
            }

            // Here is upload method call and the bool value is defining the all required field are filled or not...
            uploadData({ updatingRecords: records })
                .then((result) => {
                    var currentDate = new Date();
                    for (var x of result) {
                        x.attributes = { "type": "ContractCustom__c" };
                        var recordDate = new Date(x.Date__c);
                        if (recordDate.getDate() == currentDate.getDate() && recordDate.getMonth() == currentDate.getMonth() && recordDate.getFullYear() == currentDate.getFullYear()) {
                            x.isToday = true;
                        } else {
                            x.isToday = false;
                        }
                    }
                    console.log('in success part contract custom');
                    this.data = result;

                })
                .catch(error => {
                    console.log('error in contract custom');
                    console.log(error);
                    return false;
                })
            return true;
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