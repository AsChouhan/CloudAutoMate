import { LightningElement, wire, api, track } from 'lwc';
import LightningPrompt from 'lightning/prompt';
import createAuthUrl from '@salesforce/apex/BoxApexController.createAuthUrl';
import getAccessToken from '@salesforce/apex/BoxApexController.getAccessToken';
import getFiles from '@salesforce/apex/BoxApexController.getFiles';
import DeleteData from '@salesforce/apex/BoxApexController.DeleteData';
import checkUserInDatabase from '@salesforce/apex/BoxApexController.checkUserInDatabase';
import checkForAccessToken from '@salesforce/apex/BoxApexController.checkForAccessToken';
import getNewAccessToken from '@salesforce/apex/BoxApexController.getNewAccessToken';
import downloadFiles from '@salesforce/apex/BoxApexController.downloadFiles';
import createFolder from '@salesforce/apex/BoxApexController.createFolder';
import uploadFileToBox from '@salesforce/apex/BoxApexController.uploadFileToBox';
import deleteUserRecord from '@salesforce/apex/BoxApexController.deleteUserRecord';


export default class BoxComponent extends LightningElement {
    @track showBool = false;
    @track boxFilesList = [];
    @track showSpinnerBool = false;
    fileName = 'newFolder';
    @track folderId = '0';
    @track breadCrumbList = [{'label': 'Home', 'value': '0'}];


    connectedCallback(){
        this.showSpinnerBool = true;
        var startingUrl = new URL(window.location.href);
        var authcode = startingUrl.searchParams.get('code');
        
        checkUserInDatabase()
        .then(result=>{
            console.log('check in db');
            if(result == 'FOUND'){
                checkForAccessToken()
                .then(result=>{
                    console.log('check for exp');
                    if(result == 'NOT EXPIRED'){
                        this.showBool = true;
                        this.getFilesInJs();
                        this.showBool = false;

                    }else{
                        this.showBool = true;
                        getNewAccessToken()
                        .then(result=>{
                            if(result == 200){
                                this.showBool = true;
                                this.getFilesInJs();
                            }else{
                                alert(result,' error at apex while getting ')
                            }
                        })
                        this.showBool = false;
                    }
                })
            }else{
                console.log('auth code null');
                if(authcode == null){
                    createAuthUrl()
                    .then(result=>{
                        window.location.href = result;
                    })
                    .catch(result=>{
                        alert('error');
                    })
                }else{
                    console.log('auth code not null');
                    getAccessToken({authC: authcode})
                    .then(result=>{
                        if(result == 'pass'){
                            this.getFilesInJs();
                        }
                    })
                    .catch(result=>{
                        alert('error');
                    })
                }
            }
        })
    }

    // Create Folder.....
    handlePromptClick() {
        LightningPrompt.open({
            message: 'this is the prompt message',
            //theme defaults to "default"
            label: 'Create Folder', // this is the header text
            defaultValue: '', //this is optional
        }).then((result) => {
            if(result != null && result != ''){
                createFolder({folderName: result, parentId: this.folderId})
                .then(result1=>{
                    if(result1 == 201){
                        this.getFilesInJs();
                    }else if(result1 == 409){
                        alert('Folder with this name alredy exisit');
                    }else{
                        this.handleUnauthorizedErr(result1);
                    }
                })
            }else{
                alert('Please enter folder name');
            }
        });
    }

    getFilesInJs(){
        console.log('in get files');
        console.log('a');
        this.showSpinnerBool = true;        
        getFiles({folderId: this.folderId})
        .then(result=>{
            console.log('b');
            let key;
            let resul = [];
            for(var x in result){
                key = x;
                resul = result[x];
            }
            console.log('c');
            console.log(key);
            if(key == 200){
                console.log('success');
                this.boxFilesList = resul;
                this.addIsFolder();
            }else{
                this.handleUnauthorizedErr(key);
            }
            this.showSpinnerBool = false; 
        })
    }


    handleUnauthorizedErr(key){
        if(key == 401){
            alert('getting new access token');
            getNewAccessToken()
            .then(result=>{
                console.log('d');
                console.log(result);
                if(result == 200){
                    console.log('e');
                    this.showBool = true;
                    this.getFilesInJs();
                }else if(result == 401 || result == 400){
                    console.log('f');
                    deleteUserRecord()
                    .then(result=>{
                        console.log('g');

                        if(result == 'success'){
                            var str = window.location.href;
                            console.log(str);
                            var lisss = str.split('?');
                            console.log(lisss[0]);
                            window.location.href = lisss[0];
                        }else{
                            alert('error while delete user record');
                        }
                    })
                }else{
                     alert('can\'t solve error ',result);
                }
            })
        }
    }

    addIsFolder(){
        for(var x of this.boxFilesList){
            if(x.type == 'folder'){
                x.isFolder = true;
            }else{
                x.isFolder = false;
            }
        }    
        this.showSpinnerBool = false;
    }

    deleteFile(event){
        this.showSpinnerBool = true;
        var type = event.currentTarget.dataset.id;
        var ids = event.currentTarget.id;
        ids = ids.substring(0, ids.length-2);
        DeleteData({fileId: ids, fileType: type})
        .then(result=>{
            if(result == 204){
                alert('Successfully deleted!');
                this.boxFilesList.splice(this.boxFilesList.findIndex(item => item.id == ids), 1);


                // var tempList = [];
                // for(var x of this.boxFilesList){
                //     if(x.id != ids){
                //         tempList.push(x);
                //     }
                // }
                // this.boxFilesList = tempList;
            }else{
                alert('error while deleting TRY agaiN');
                this.handleUnauthorizedErr(result);
            }
            this.showSpinnerBool = false;
        })
    }

    downloadFile(event){
        console.log('inside download');
        var fileId1 = event.currentTarget.id;
        fileId1 = fileId1.substring(0, fileId1.length-2);
        downloadFiles({fileId: fileId1})
        .then(result=>{
            console.log(result);
            let key;
            let resul = [];
            for(var x in result){
                key = x;
                resul = result[x];
            }
            console.log(key+'  '+resul);
            var res = result;
            //console.log(res.download_url);
            if(key == 302){
                window.open(resul);
            }else if(key == 302 && resul == null){
                alert('currently shared link not available');
            }else if(key == 404){
                alert('folder cannot download!');
            }else{
                this.handleUnauthorizedErr(key);
            }
        })
    }

    openFolder(event){
        this.showSpinnerBool = true;
        var ids = event.target.id;
        ids = ids.substring(0, ids.length-2);
        var fileName = event.target.name;
        this.folderId = ids;
        this.breadCrumbList.push({'label': fileName, 'value': ids});
        this.getFilesInJs();
    }
   
    
    gotoPage(event){
        this.showSpinnerBool = true;
        var ids = event.target.name;
        var tmpList = [];
        for(var x of this.breadCrumbList){
            if(x.value == ids){
                tmpList.push(x);
                break;
            }
            tmpList.push(x);
        }
        this.breadCrumbList = tmpList;
        this.folderId = ids;
        this.getFilesInJs();
    }

    handleUpload(event){
        this.showSpinnerBool = true;
        console.log('in upload method');
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
        console.log(filename11+'\n'+parentId);
        var docId = uploadingFiles.documentId;
        uploadFileToBox({base64: filetoString, filename: filename11, folderId: parentId})
        .then(result=>{
            console.log(result);
            if(result == 201){
                alert('Successfully uploaded!....');
                var item = ({
                    id: docId,
                    name: filename11,
                    type: typeOf
                })
                this.boxFilesList.push(item);
            }else if(result == 409){
                alert('file alredy exist....');
            }else{
                this.handleUnauthorizedErr(result);
            }
        })
        this.showSpinnerBool = false;
    }
}