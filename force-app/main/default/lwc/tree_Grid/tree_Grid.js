import { LightningElement,wire, track} from 'lwc';
import getAccounts from '@salesforce/apex/Tree_Grid_Handler.getAccounts';
import sendChildRecord from '@salesforce/apex/Tree_Grid_Handler.sendChildRecord';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class Tree_Grid extends LightningElement {
    @track jsonList;
    @track ashish;
    @track jsonList1 = [
        {
            "Name": "Trigger2",
            "_children": [
                {
                    "Name": "747773-jw",
                    "accountName": "Corkery-Abshire",
                    "phone": "837-555-0100"
                },
                {
                    "Name": "377526-zg",
                    "accountName": "Robel, Friesen and Flatley",
                    "phone": "837-555-0100",
                    "_children": [
                        {
                            "Name": "955330-wp",
                            "accountName": "Donnelly Group",
                            "phone": "837-555-0100"
                        },
                        {
                            "Name": "343693-9x",
                            "accountName": "Kshlerin Group",
                            "phone": "837-555-0100"
                        }
                    ]
                }
            ]
        },
        {
            "Name": "Triggvcvcxer3",
            "_children": [
                {
                    "Name": "747773-jw",
                    "accountName": "Corkery-Abshire",
                    "phone": "837-555-0100"
                },
                {
                    "Name": "377526-zg",
                    "accountName": "Robel, Friesen and Flatley",
                    "phone": "837-555-0100",
                    "_children": [
                        {
                            "Name": "955330-wp",
                            "accountName": "Donnelly Group",
                            "phone": "837-555-0100"
                        },
                        {
                            "Name": "343693-9x",
                            "accountName": "Kshlerin Group",
                            "phone": "837-555-0100"
                        }
                    ]
                }
            ]
        }
    ];
    @track selectedList = [];
    @track bool = true;
    @track childRecords;
    @track childObjects = ['Contacts', 'Opportunity'];

    @track gridColumn = [{
        type: 'text',
        fieldName: 'Name',
        label: 'Account Name',
        initialWidth: 300,
    }]

    @wire(getObjectInfo, { objectApiName: {objectApiName: 'Account'}})
    propertyOrFunction({error, data}){
        if(data){
            console.log('gere => ');
            console.log(data);
        }
    }

    handleSelect(event){
        this.selectedList = event.detail.selectedRows;
       
    }

    handleProceed(){
        this.bool = false;
        this.ashish = this.jsonList;
       /* var tempList = [];
      
        sendChildRecord({parentId : tempList})
        .then(result=>{
            var temp1 = [];
            this.childRecords = result;
            for(var x of this.selectedList){
                var obj = {
                    Name : x.Name,
                    _children: [
                        {
                            Name: '747773-jw',
                            accountName: 'Corkery-Abshire',
                            phone: '837-555-0100',
                        },
                        {
                            Name: '377526-zg',
                            accountName: 'Robel, Friesen and Flatley',
                            phone: '837-555-0100',
                            _children: [
                                {
                                    Name: '955330-wp',
                                    accountName: 'Donnelly Group',
                                    phone: '837-555-0100',
                                },
                                {
                                    Name: '343693-9x',
                                    accountName: 'Kshlerin Group',
                                    phone: '837-555-0100',
                                },
                            ],   
                        }
                    ]              
                }
                // obj._children = [];
                // for(var y of this.childObjects){
                //     obj._children.push({Name: y});
                // }
                temp1.push(obj);
            }
            var temp = JSON.stringify(temp1)
            this.jsonList = JSON.parse(temp);
            console.log(JSON.stringify(this.jsonList));
        })*/

    }

    connectedCallback(){
        getAccounts().then(result=>{
            var temp1 = [];
            for(var x of result){
                var obj = {
                    Name: x.Name
                }
                obj._children = [];
                if(x.Contacts != null){
                    for(var y of x.Contacts){
                        obj._children.push({Name: y.Name});
                    }
                }
                temp1.push(obj);                
            }
            this.jsonList = temp1;
        })
    }
}