import { LightningElement, api, track } from 'lwc';
import getSortedRecords from '@salesforce/apex/comboBoxApexController.getSortedRecords';

export default class ComboBoxChild extends LightningElement {

    @api options;
    @api selectedValue;
    @api selectedValues = [];
    @api label;
    @api minChar = 3;
    @api disabled = false;

    @track value;
    @track values = [];
    pillsList = [];

    @track optionData;
    @track searchString;
    @track count = 0;
    @track message;
    @track showDropdown = false;
    objectName;
    @track footerText;
    query;
    @track multiSelect;
    @track seprate;
    @track fieldstodisplay;
    @track noofrecordstodisplay;

    connectedCallback(){
        var data = JSON.parse(JSON.stringify(this.options));

        console.log('child component called');
        this.optionData = data.options;
        this.multiSelect = data.multiselect;
        this.disabled = data.issearchDisable;
        this.seprate = data.seprator;
        this.searchstring = data.searchstring;
        this.fieldstodisplay = data.fieldstodisplay;
        this.noofrecordstodisplay = data.noofrecordstodisplay;
        this.objectName = data.objectName;

        let txt = this.options.objectName+' '+this.options.seprator;

        var query = 'select ';
        for(var x of this.fieldstodisplay){
            txt+=x+',';
        }
        txt = txt.substring(0, txt.length-1);
        // query+=txt+' from '+objectName;
        console.log(txt);
        this.footerText = txt;
    }

    filterOptions(event) {
        this.searchString = event.target.value;
        console.log(this.searchString);
        if( this.searchString && this.searchString.length > 0 ) {
            this.message = '';
            if(this.searchString.length >= this.minChar) {
                setTimeout(() => {
                // var flag = true;
                getSortedRecords({str: this.searchString})
                .then(result=>{
                    var options = result;
                    for(var i = 0; i < options.length; i++) {
                        options[i].isVisible = true;
                        if(this.values.includes(options[i].Id)){
                            options[i].selected = true;
                        }
                    }
                    this.optionData = options;
                    if(result.length > 0){
                        this.optionData = result;
                        // flag = false;
                    }else {
                        this.message = "No results found for '" + this.searchString + "'";
                    }
                })
                }, 3000);
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
	}

    selectItem(event) {
        var selectedVal = event.currentTarget.dataset.id;
        var recName = event.currentTarget.dataset.name;
        console.log(recName+'   ->   '+selectedVal);
        if(selectedVal) {
            var count = this.values.length;
            console.log(count);
            var options = this.optionData;
            var pillsList = this.pillsList;
            for(var i = 0; i < options.length; i++) {
                if(options[i].Id === selectedVal){
                    if(this.multiSelect) {
                        if(this.values.includes(options[i].Id)) {
                            this.values.splice(this.values.indexOf(options[i].Id), 1);
                            options[i].selected = false;
                            for(var j=0;j<this.pillsList.length;j++){
                                if(pillsList[j].Id == selectedVal){
                                    this.pillsList.splice(j,1);
                                }
                            }
                            count--;
                        } else {
                            this.values.push(options[i].Id);
                            options[i].selected = true;
                            var item = ({
                                Id: selectedVal,
                                Name: recName
                            });
                            this.pillsList.push(item);
                            count++;
                        }
                        //options[i].selected = options[i].selected ? false : true;   
                    } else {
                        this.value = options[i].Id;
                        this.searchString = options[i].Name;
                    }
                }
            }
            this.optionData = options;
            if(this.multiSelect)
                this.searchString = count + ' Option(s) Selected';
            if(this.multiSelect)
                event.preventDefault();
            else
                this.showDropdown = false;
        }
    }

    showOptions(){
        console.log('show option called');
        if(this.disabled == false && this.options) {
            console.log('inside if -> ',this.options);
            this.message = '';
            this.searchString = '';
            var options = this.optionData;//JSON.parse(JSON.stringify(this.optionData));
            for(var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            console.log(options.length);
            if(options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }else{
            console.log('insde show option else part');
            this.message = '';
            this.searchString = '';
            var options = this.optionData;//JSON.parse(JSON.stringify(this.optionData));
            for(var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            console.log(options.length);
            if(options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
	}

    removePill(event) {
        event.preventDefault();
        var selectedVal = event.currentTarget.dataset.id;
        var count = this.values.length;
        var values = this.values;
        var pillsList = this.pillsList;
        var options = this.optionData;
        this.values.splice(this.values.indexOf(selectedVal), 1);
        for(var i=0;i<pillsList.length;i++){
            if(pillsList[i].Id == selectedVal){
                this.pillsList.splice(i,1);
                for(var j=0;j<options.length;j++){
                    if(options[j].Id == selectedVal){
                        options[j].selected = false;
                    }
                }
                this.optionData = options;
                count--;
            }
        }
         if(this.multiSelect){
             this.searchString = count + ' Option(s) Selected';
             event.preventDefault();
         }
    }

    blurEvent(){
        console.log('onblur event call ')
        var previousLabel;
        var count = this.values.length;
        for(var i = 0; i < this.optionData.length; i++) {
            if(this.optionData[i].Id === this.value) {
                previousLabel = this.optionData[i].Name;
            }
        }
        if(this.multiSelect)
        	this.searchString = count + ' Option(s) Selected';
        else
        	this.searchString = previousLabel;
        
        this.showDropdown = false;

        this.dispatchEvent(new CustomEvent('select', {
            detail: {
                'payloadType' : 'multi-select',
                'payload' : {
                    'value' : this.value,
                    'values' : this.values
                }
            }
        }));
    }
}