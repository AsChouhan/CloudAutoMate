import { LightningElement, api, track } from 'lwc';

export default class TableAssignmentCHildComponent extends LightningElement {
    @api record;
    @api field;
    @track displayValue;

    connectedCallback(){
        if(this.record && this.field){
            this.displayValue = this.record[this.field];
        }
    }
}