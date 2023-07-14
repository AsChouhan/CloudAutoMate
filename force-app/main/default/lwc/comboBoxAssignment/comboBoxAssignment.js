import { LightningElement, track, api } from 'lwc';
import getRecords from '@salesforce/apex/comboBoxApexController.getRecords';
export default class ComboBoxAssignment extends LightningElement {
    @track recordlist;
    @track data;
    @track callComp = false;
    @track disabled = false;
    @track searchString = 'text';
    @track fields = ['id', 'type', 'name'];

    connectedCallback(){
    let strQuery = 'select id, Name from Account limit 10';
        console.log('a');
        getRecords({query: strQuery})
        .then(result=>{
            if(result.length != 0){
                this.recordlist = result;
                let jsondata = {
                    "multiselect": true,
                    "issearchDisable": false,
                    "options": this.recordlist,
                    "objectName": "Account",
                    "searchField": "Name",
                    "searchstring": 'text',
                    "seprator": ":",
                    "fieldstodisplay": ["Id", "Rating", "Type"],
                    "noofrecordstodisplay": 10
                }

                this.data = jsondata;
                this.callComp = true;

                console.log('b');
                var dsf = JSON.parse(JSON.stringify(jsondata));
                //console.log(dsf.objectName);

            }else{
                alert('not records availbale for show!');
            }
        })
        .catch(error=>{
            console.log(error);
        })
    }

    
}