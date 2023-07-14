import { LightningElement, api, track } from 'lwc';

export default class ClientsideChildCmp extends LightningElement {
    @api field;
    @track displayData;
    @api record;
    @api  recordId;
   // @track show = false;
    // get record() {
    //     return this.record;
    // }
 
    // set record(value) {
    //     this.record1 = value;
    // }
    connectedCallback() {
        var rec = this.record;
        var fld = this.field;
        this.displayData = rec[fld];
        console.log(rec,'   '+fld+'   '+this.displayData);
        // this.show = true;
    }
}