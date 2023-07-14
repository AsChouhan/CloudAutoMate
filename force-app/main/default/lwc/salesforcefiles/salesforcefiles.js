import { LightningElement, track } from 'lwc';
import getFiles from '@salesforce/apex/salesforceintiApex.getFiles';
import uploadFiles from '@salesforce/apex/salesforceintiApex.uploadFiles';

export default class Salesforcefiles extends LightningElement {


    @track files = [];

    connectedCallback(){
        console.log('at connected call back');
        getFiles()
        .then(result=>{
            console.log('at result');
            var tmpFiles = [];
            for(var x of result){
                console.log(x);
                tmpFiles.push(x);
            }
            this.files = tmpFiles;
        })
    }

    handleUploadFinished(event){
        console.log('upload called');
        var uploadingFiles = event.detail.files[0];

        console.log(uploadingFiles);
        console.log('a');
        var jsonString = JSON.stringify(uploadingFiles);
        console.log(jsonString);
        console.log('c');
        console.log(btoa(jsonString));
        //var filetoString = Buffer.from(jsonString, 'base64');
        var filetoString = btoa(jsonString);
        console.log('b');

        var filename11 = uploadingFiles.name;
        var parentId = this.folderId;
        var typeOf = uploadingFiles.mimeType;
        uploadFiles({filename: filename11, file64: filetoString})
        .then(result=>{
            alert(result);
            if(result == 'Upload Success'){
                console.log('inseide succes upload '+ filename11);
                var files = this.files;
                var item = ({
                    Title : filename11
                })
                files.push(item);
                this.files = files;
            }

        })
    }
}