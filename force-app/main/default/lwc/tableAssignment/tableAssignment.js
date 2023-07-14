import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TableAssignment extends LightningElement {
    @track headerList = [{label: 'A', value: 'a'}, {label: 'B', value: 'b'}, {label: 'C', value: 'c'}, {label: 'D', value: 'd'}];
    @track dataList = [{a: 'ahish', b: 'male', c: '9877', d: 'singh', Id: '1'}, {a: 'bhanu', b: 'male', c: '8080', d: 'sharma', Id: '2'}];
    rowId = this.dataList.length+1;
    colId = 0;


    addRow(){
        var obj = {Id: this.rowId};
        this.dataList.push(obj);
        this.rowId++;
    }

    addColumn(){
        if(this.headerList.length < 10){
            var header = {label: 'new'+this.colId, value: this.rowId, Id: this.colId};
            this.headerList.push(header);
            this.colId++;
        }else{
            this.ShowToast('Error', "can't add more then 10 column",'error');
        }        
    }

    removeColumn(){
        this.headerList.pop();
    }

    deleteRow(event){
        var recordId = event.currentTarget.dataset.id;
        this.dataList.splice(this.dataList.findIndex(item => item.Id == recordId), 1);
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