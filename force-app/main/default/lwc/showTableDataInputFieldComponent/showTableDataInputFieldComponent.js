import { LightningElement, api, track } from 'lwc';

export default class ShowTableDataInputFieldComponent extends LightningElement {
    @api field;
    @track displayData;
    @api record;
    @api  fieldtype;
    isDate = false;

    connectedCallback() {
        console.log('type->>>'+this.fieldtype);
        if(this.fieldtype == 'DateTime'){
            this.isDate = true;
        }else{
            this.isDate = false;
        }

        var rec = this.record;
        var fld = this.field;
        this.displayData = rec[fld];
        console.log(rec,'   '+fld+'   '+this.displayData);
    }
}