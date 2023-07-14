import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class FieldsComponentForDt extends LightningElement {
    @api record;
    @api field = {};
    @api objectname
    @api editable;
    @track displayInfo;
    fieldInfo
    @track pickListValues;

    @track isDateField = false;
    @track isPickListField = false;
    newRecord = { Id: '123456' };


    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: '$fieldInfo' })
    values({ data, error }) {
        if (data) {
            this.pickListValues = data.values;
            console.log(data.values);
        } else if (error) {
            console.log(error);
        }
    }

    connectedCallback() {
        this.editable = !this.editable;
        if (this.field.fieldType == 'Picklist') {

            console.log(this.field.apiName + '   ->   ' + this.objectname);
            this.fieldInfo = JSON.parse(JSON.stringify({ 'fieldApiName': this.field.apiName, 'objectApiName': this.objectname }));
            this.isPickListField = true;

        } else if (this.field.fieldType == 'DateTime') {
            this.isDateField = true;
        }
        this.displayInfo = this.record[this.field.apiName];
        if (this.isDateField == true) {
            var currentDate = new Date();
            var recordDate = new Date(this.displayInfo);
            if (currentDate.getDate() == recordDate.getDate()) {
                var row = this.template.querySelector('[data-id="ids"]');
                console.log(row);
                // row.style.color = "red";
            }
        }



        console.log(this.displayInfo);
    }


    renderedCallback() {
        console.log('This is renderedcallback');
        // if(this.isDateField == true){
        console.log('inside render calllback');
        var currentDate = new Date();
        var recordDate = new Date(this.record.Date__c);
        if (currentDate.getDate() == recordDate.getDate()) {
            var row = this.template.querySelector('[data-id="ids"]');
            console.log(row);
            row.style.border = "1px solid red";
        }
    }
    // }
    // console.log('Query Selector : ' ,this.template.querySelector('p'));
// }

loadColor(){
    console.log('load color called');
}

printVal(event){
    // console.log(event.detail.value);
    this.newRecord.Name = event.detail.value;
}

printDate(event){
    // console.log(event.detail.value);
    this.newRecord.Date = event.detail.value;
}

printRate(event){
    // console.log(event.detail.value);
    this.newRecord.Rating = event.detail.value;
}

printInd(event){
    // console.log(event.detail.value);
    this.newRecord.Industry = event.detail.value;
}

@api
callAllMethod(){
    // this.printVal();
    // this.printInd();
    // this.printRat();
    // this.printDate();
    console.log('all method called');
    console.log(JSON.parse(JSON.stringify(this.newRecord)));

}
}