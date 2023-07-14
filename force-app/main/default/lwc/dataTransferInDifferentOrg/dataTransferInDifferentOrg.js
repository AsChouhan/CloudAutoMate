import { LightningElement, wire, track } from 'lwc';
import objectList from '@salesforce/apex/DataTransferInDifferentOrg.objectList';
import getRecords from '@salesforce/apex/DataTransferInDifferentOrg.getRecords';
import getRelatedObject from '@salesforce/apex/DataTransferInDifferentOrg.getRelatedObject';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Longitude from '@salesforce/schema/Lead.Longitude';
import sendRecords from '@salesforce/apex/DataTransferInDifferentOrg.sendRecords';
import UserPreferencesHideLightningMigrationModal from '@salesforce/schema/User.UserPreferencesHideLightningMigrationModal';



export default class DataTransferInDifferentOrg extends LightningElement {
    columns = [{
        label: 'Name',
        fieldName: 'Name'
    }
    ];
    tempListForObTree = [];
    countId = 1;
    innerBool =true;
    @track selectedRecordId = [];
    @track objectList = [];
    @track selectedIds = ['0015i00000qGHqRAAW'];
    @track recordList = [];
    @track fieldList = [];
    @track gridData = [];
    recordBool = false;
    finalBool = false;
    @track reletedObjects = [];
    selectedChildObject = [];
    @track sendData = [];
    ParentrecordName = [];
    @track FinalList = [];
    @track showSpinnerBool = false;
    @track gridColumn = [{
        type: 'text',
        fieldName: 'Name',
        label: 'Records',
    }];
    Totalrecords = [];
    childColumn = [{
        type: 'text',
        fieldName: 'ChildSobjectId',
        label: 'Related Object Name',
    }];

    @track bool = true;
    @track objectName;

    connectedCallback() {
        objectList()
            .then(result => {
                this.objectList = result;
            })
    }

    handleSelect(event) {
        this.selectedChildObject = event.detail.selectedRows;
    }

    handleSectionToggle(event) {
        var section = event.detail.openSections;
        console.log(section);
        this.objectName = section[section.length - 1];
        getRelatedObject({ parentObject: this.objectName })
            .then(result => {
                this.reletedObjects = result

            })
            for(var x of this.selectedRecordId){
            }
    }

    AfterRelatedObjectSelected() {
        console.log('sendToAPex');
        var objectApiName = [];
        for (var x of this.selectedChildObject) {
            objectApiName.push(x.RelationshipName);
        }
        var temp = [];
        getRecords({ parentObject: this.objectName, childObjects: JSON.stringify(objectApiName)})
            .then(result => {
                for (var x of result) {
                    var obj = {
                        Id : x.Id,
                        Name: x.Name
                    }
                    obj._children = [];
                    for (var y of this.selectedChildObject) {
                        var tempOBJ = {};
                        tempOBJ.Name = y.ChildSobjectId;
                        
                        if (x[y.RelationshipName] != null) {
                            tempOBJ._children = [];

                             var teee = JSON.parse(JSON.stringify(x[y.RelationshipName]));
                            for (var z of teee.records) {
                                tempOBJ._children.push({
                                    Id : z.Id,
                                    Name: z.Name
                                });
                            }
                        }
                        obj._children.push(tempOBJ);
                    }
                    temp.push(obj);
                }
                this.gridData = temp;
                console.log(JSON.stringify(temp));
                this.recordBool = true;
            })
    }
    selectedParentRecord(event) {
        console.log('this.selectedParentRecord');
        this.ParentrecordName = event.detail.selectedRows;
        
        // var temp = this.selectedRecordId;
        // this.tempListForObTree = [];
        var temp = [];
        var anTemp = new Array();
        // this.selectedIds.add(x.Id);
        for(var x of this.ParentrecordName){
            console.log(this.selectedIds.findIndex(item => item == x.Id));
            if(this.selectedIds.findIndex(item => item == x.Id) == -1){
                console.log('inside true');
                anTemp.push(x.Id);
            }else{
                // this.selectedIds.splice[this.selectedIds.findIndex(item => item == x.Id), 1];
            }

            var obj = {};
            obj.attributes = {
                type : this.objectName,
                referenceId : 'ref'+this.countId++
            }
            obj.Name = x.Name;
            for(var y of this.selectedChildObject){
                obj[y.RelationshipName] = {
                    Name : this.countId,
                    records : []
                }                
            }
            temp.push(obj);     
        }
        console.log(JSON.stringify(this.selectedIds));

        this.tempListForObTree = temp;
        // console.log(JSON.stringify(this.tempListForObTree));


        this.selectedIds = anTemp;
        this.selectedRecordId = temp;
    }


    handleSelectOne(event) {
        console.log('this.handleSelectOne');
        this.sendData = event.detail.selectedRows;
    }

    selectChildRecord() {
        console.log('this.selectChildRecord');
        this.finalBool = true;
        let accountList = [];
        for (let i = 0; i < this.ParentrecordName.length; i++) {
            let account = {
                Name: this.ParentrecordName[i].Name,
                child: JSON.parse(JSON.stringify(this.ParentrecordName[i]._children))
            };
            accountList.push(account);
        }
        this.Totalrecords = accountList;
        console.log(JSON.stringify(this.Totalrecords));
        // if (this.Totalrecords.length > 0) {
        //     this.innerBool = false;
        // }
    }

    sendThisData(event) {
        console.log('SendThisData');
        this.FinalList = event.detail.selectedRows;
        console.log(JSON.stringify(this.FinalList));
         for(var x in this.FinalList){
            console.log('12345');
            let obj = {};
            obj.attributes = {
                type : this.objectName,
                referenceId : 'ref'+(x+1)
            }
            console.log('123456554848546');
             obj.Name = x.Name;
            for(var y of this.selectedChildObject){
                console.log('1111111');
                    console.log(y.RelationshipName);
                obj[y.RelationshipName] = {
                    Name : JSON.parseInt(x+1),
                    records : []
                }                
            }
           // temp.push(x.Name);
            this.tempListForObTree.push(obj);
       }
       console.log(JSON.stringify(this.tempListForObTree));
    }

    TransferData() {
        sendRecords({Data : JSON.stringify(this.FinalList)})
            .then(result => {
            })
            .catch(error => {
               
            });

            console.log('End ');
    }

    handleChildTogle(event){
        console.log('CheckBox');
        var section = event.detail.openSections.Name;
        console.log(section);
    }

}