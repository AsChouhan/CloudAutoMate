import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class ComponentForPickList extends LightningElement {
    @api record;
    @api field;
    @api object;
    @api isenableedit;
    fieldInfo;
    @track value;
    @track pickListValues = [];

    @wire(getPicklistValues, {recordTypeId: '012000000000000AAA', fieldApiName: '$fieldInfo'})
    values({data, error}){
        if(data){
            // console.log(data.values);
            // for(var x of data.values){
            //     console.log(x);
            // }
            this.pickListValues = data.values;
        }
        else if(error){
            console.log(error);
        }
    }
 
    connectedCallback(){
        this.fieldInfo = JSON.parse(JSON.stringify({'fieldApiName': this.field, 'objectApiName': this.object}));
        this.isenableedit = !this.isenableedit;
        var rec = this.record;
        var fld = this.field;
        this.value = rec[fld];
        console.log(this.value);

        console.log(this.object);
        console.log(this.field);
        console.log(this.record);
        console.log(this.values.data);
        console.log(this.fieldInfo);
    }
}