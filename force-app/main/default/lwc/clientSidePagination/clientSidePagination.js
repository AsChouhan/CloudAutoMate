import { LightningElement, api, track } from 'lwc';
import getObjectList from '@salesforce/apex/ClientSidePaginationApex.getObjectList';
import getObjectFields from '@salesforce/apex/ClientSidePaginationApex.getObjectFields';
import getRecords from '@salesforce/apex/ClientSidePaginationApex.getRecords';

export default class ClientSidePagination extends LightningElement {
    @track showSpinner = false;
    checkedRecords = new Set();
    objectList = [];
    pageSizeList = [{ 'label': '5', 'value': '5' }, { 'label': '10', 'value': '10' }, { 'label': '15', 'value': '15' }, { 'label': '20', 'value': '20' }];
    @track pageSize = 5;
    @track paginationList = [];
    tmpListForPagiList = [];
    dashesString = '. .';
    @track rightDashes = false;
    @track leftDashes = false;
    @track processBool = true;
    @track objectNam = 'None';
    @track fieldsList = [];
    @track selectedFields = [];
    @track showDualBox = false;
    @track totalPages;
    @track currentPage = 1;
    @track showDataTable = false;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track totalRecords;
    @track columns = [];
    @track min = 1;
    @track max = 10;
    @track data = [];
    @track trackStartingIndex = 0;
    @track recordsForDisplay = [];
    @track firstBool;
    @track lastBool;

    displaySpinner() {
        this.showSpinner = true;
    }

    hideSpinner() {
        this.showSpinner = false;
    }

    connectedCallback() {
        this.displaySpinner();
        getObjectList()
            .then(result => {
                this.objectList = result;
            }).catch(error => {
                console.log(error);
            })
        this.hideSpinner();
    }

    get disablePreviousButtons() {
        if (this.currentPage == 1) {
            return true;
        }
    }

    get disableNextButtons() {
        if (this.currentPage == this.totalPages) {
            return true;
        }
    }

    dynamicSortASC(property) {
        return function (a, b) {
            if (a[property] < b[property]) {
                return -1;
            } else if (a[property] > b[property]) {
                return 1;
            } else {
                return 0;
            }
        };
    }
    dynamicSortDESC(property) {
        return function (a, b) {
            if (a[property].toLowerCase() < b[property].toLowerCase()) {
                return 1;
            } else if (a[property].toLowerCase() > b[property].toLowerCase()) {
                return -1;
            } else {
                return 0;
            }
        };
    }

    sorting(event) {
        if (this.sortDirection == 'asc') {
            var fld = event.target.dataset.name;
            this.recordsForDisplay.sort(this.dynamicSortASC(fld));
            this.sortDirection = 'desc';
        }else if(this.sortDirection == 'desc'){
            var fld = event.target.dataset.name;
            this.recordsForDisplay.sort(this.dynamicSortDESC(fld));
            this.sortDirection = 'asc';
        }
    }

    reset() {
        this.displaySpinner();
        this.checkedRecords = new Set();
        this.data = [];
        this.rightDashes = false;
        this.leftDashes = false;
        this.showDataTable = false;
        this.showDualBox = false;
        this.columns = [];
        this.trackStartingIndex = 0;
        this.recordsForDisplay = [];
        this.paginationList = [];
        this.currentPage = 1;
        this.fieldsList = [];
        this.selectedFields = [];
        this.tmpListForPagiList = [];
        this.pageSize = 5;
        this.objectNam = 'None';
        this.hideSpinner();
    }

    whenObjectSelect(event) {
        this.displaySpinner();
        this.checkedRecords = new Set();
        this.rightDashes = false;
        this.leftDashes = false;
        this.data = [];
        this.showDataTable = false;
        this.columns = [];
        this.trackStartingIndex = 0;
        this.recordsForDisplay = [];
        this.paginationList = [];
        this.currentPage = 1;
        this.fieldsList = [];
        this.selectedFields = [];
        this.tmpListForPagiList = [];
        this.pageSize = 5;
        let object = event.detail.value;
        this.objectNam = object;
        if (this.objectNam != 'None') {
            getObjectFields({ objectName: object })
                .then(result => {
                    this.fieldsList = result;
                    this.showDualBox = true;
                }).catch(error => {
                    console.log(error);
                })
        }
        this.hideSpinner();
    }

    getSelectedFields(event) {
        this.displaySpinner();
        this.processBool = false;
        this.selectedFields = [];
        var fields = event.detail.value;
        this.selectedFields = fields;
        this.hideSpinner();
    }

    showRecords() {
        var iii = 1;
        console.log('comes here ', iii++);
        this.displaySpinner();
        var col = [];
        for (var x of this.selectedFields) {
            for (var y of this.fieldsList) {
                if (x == y.value) {
                    var item = {
                        "label": y.label,
                        "fieldName": y.value,
                        "sortable": true,
                        "sortedBy": y.value
                    };
                    col.push(item);
                }
            }
        }
        console.log('comes here ', iii++);
        this.processBool = true;
        this.columns = col;
        getRecords({ fields: this.selectedFields, objectName: this.objectNam })
            .then(result => {
                console.log('inside get Records result');
                var pTList = [];
                this.showDataTable = true;

                this.data = result;
                this.totalRecords = result.length;
                let pageSize = this.pageSize;
                this.currentPage = 1;
                this.totalPages = Math.ceil(result.length / pageSize);//(result.length/pageSize == 0)?(result.length/pageSize):((result.length/pageSize)+1);
                this.leftDashes = (this.totalPages > 5) ? true : false;
                if (this.leftDashes == true && this.tmpListForPagiList.length == 0) {
                    for (var x = 1; x <= 5; x++) {
                        pTList.push(x);
                    }
                    this.tmpListForPagiList = pTList;
                } else {
                    for (var x = 1; x <= this.totalPages; x++) {
                        pTList.push(x);
                    }
                    this.tmpListForPagiList = pTList;
                }
                if (this.tmpListForPagiList.length != 0) {
                    this.paginationList = this.tmpListForPagiList;
                }
                this.addRecordsInList();
                if (result.length > 0) {
                    this.addIntoPagiList();
                    console.log('comes here ', iii++);
                }
            })
            .catch(error => {
                console.log(error);
            })
        console.log('comes here ', iii++);
        this.hideSpinner();
    }

    handlePageSize(event) {
        this.displaySpinner();
        var pageSize = event.detail.value;
        this.pageSize = pageSize;
        this.trackStartingIndex = 0;
        this.currentPage = 1;
        var pTList = [];
        this.totalPages = Math.ceil(this.totalRecords / pageSize);
        this.leftDashes = (this.totalPages > 5) ? true : false;
        if (this.trackStartingIndex == 0) {
            this.addRecordsInList();
        }

        if (this.totalPages >= this.tmpListForPagiList.length) {
            this.paginationList = this.tmpListForPagiList;
        } else {
            for (var x = 1; x <= this.totalPages; x++) {
                pTList.push(x);
            }
            this.paginationList = pTList;
            this.leftDashes = false;
            this.rightDashes = false;
        }
        if (this.totalPages >= 5) {
            setTimeout(() => {
                this.leftDashes = (this.totalPages > this.paginationList[4]) ? true : false;
                this.rightDashes = (1 < this.paginationList[0]) ? true : false;
            }, 30);
        }
        this.hideSpinner();
    }

    next() {
        this.displaySpinner();
        var currentpage = this.currentPage;
        var strtIndx = this.pageSize * (currentpage);
        this.trackStartingIndex = strtIndx;
        this.currentPage++;

        if (this.trackStartingIndex == strtIndx) {
            this.addRecordsInList();
        }
        console.log(this.currentPage + '  before add in records');
        this.addIntoPagiList();
        this.hideSpinner();
    }

    first() {
        this.displaySpinner();
        this.rightDashes = false;
        this.leftDashes = (this.totalPages > 5) ? true : false;
        this.trackStartingIndex = 0;
        this.currentPage = 1;
        this.paginationList = this.tmpListForPagiList;
        console.log(this.currentPage + '  ' + this.paginationList[0]);
        this.addRecordsInList();
        this.hideSpinner();
    }

    previous() {
        this.displaySpinner();
        this.rightDashes = (1 < this.paginationList[0]) ? true : false;
        var currentpage = this.currentPage;
        var strtIndx = this.pageSize * (currentpage - 2);
        this.trackStartingIndex = strtIndx;
        this.currentPage--;
        if (this.trackStartingIndex == strtIndx) {
            this.addRecordsInList();
        }
        this.addIntoPagiList();
        this.hideSpinner();
    }

    last() {
        console.log('last call ');
        this.displaySpinner();
        var lastPage = this.totalPages;
        var strtIndx = this.pageSize * (lastPage - 1);
        console.log(strtIndx);
        this.currentPage = lastPage;
        this.trackStartingIndex = strtIndx;
        // if (this.trackStartingIndex == strtIndx) {
        // }
        if (this.totalPages > 5) {
            console.log('inseide greter then 5');
            var tmpLis = [];
            for (var x = parseInt(this.totalPages) - 4; x <= this.totalPages; x++) {
                tmpLis.push(x);
            }
            console.log('after for loop    ' + tmpLis.length);
            console.log(tmpLis.length != 0);
            if (tmpLis.length != 0) {
                this.paginationList = tmpLis;
                this.addRecordsInList();
            }
            console.log('after else aprt');
            this.leftDashes = false;
            this.rightDashes = true;
        }
        console.log('after dashes....');
        // this.hideSpinner();
        console.log('after spinneer....');

    }

    addRecordsInList() {
        this.displaySpinner();
        console.log('add in records => ' + this.currentPage);
        this.makeNumRed();

        var recordList = this.data;
        let tempRecList = [];
        var indx = this.trackStartingIndex;
        for (var i = 0; i < this.pageSize; i++) {
            if (indx < this.totalRecords) {
                if (this.checkedRecords.has(recordList[indx].Id)) {
                    recordList[indx].isChecked = true;
                    tempRecList.push(recordList[indx]);
                    console.log('comes in if....');
                } else {
                    recordList[indx].isChecked = false;
                    tempRecList.push(recordList[indx]);
                    console.log('comes in else');
                }
                indx++;
            }
            else {
                console.log('else part called ffff.......................');

            }
        }
        console.log('after loop..');
        this.recordsForDisplay = tempRecList;
        console.log(this.recordsForDisplay);
        this.trackStartingIndex = indx;
        this.makeParentChacked();
        this.hideSpinner();
    }

    handlePageJump(event) {
        this.displaySpinner();
        var number = event.target.dataset.id;
        console.log(number);
        if (number != 0) {
            this.currentPage = number;
            var strtIndx = this.pageSize * (number - 1);
            this.trackStartingIndex = strtIndx;
            if (this.trackStartingIndex == strtIndx) {
                this.addRecordsInList();
                this.addIntoPagiList();
                this.makeNumRed();
            }
        }
        this.hideSpinner();
    }

    addIntoPagiList() {
        this.displaySpinner();
        if (this.totalPages >= 5) {
            console.log('pagilist')
            var num = this.currentPage;
            var totalPages = this.totalPages;
            console.log(num + ' \n ' + totalPages);
            var tempList = [];
            if (this.currentPage == this.paginationList[3] || this.currentPage == this.paginationList[4]) {
                console.log('first if 1');
                var bool = this.totalPages >= parseInt(this.currentPage) + 2;
                if (bool) {
                    console.log('inside first if 1');
                    for (var x = num - 2; x <= parseInt(num) + 2; x++) {
                        tempList.push(x);
                    }
                    if (tempList.length != 0) {
                        this.paginationList = tempList;
                    }
                } else {
                    console.log('inside first if 1 else part');
                    for (var x = this.totalPages - 4; x <= this.totalPages; x++) {
                        tempList.push(x);
                    }
                    if (tempList.length != 0) {
                        this.paginationList = tempList;
                    }
                }
            } else if (this.currentPage == this.paginationList[1] || this.currentPage == this.paginationList[0]) {
                var bool = (1 <= parseInt(this.currentPage) - 2);
                console.log('first else if 1');
                if (bool) {
                    console.log('inside first else if  if 1');

                    for (var x = num - 2; x <= parseInt(num) + 2; x++) {
                        tempList.push(x);
                    }
                    if (tempList.length != 0) {
                        this.paginationList = tempList;
                    }
                } else {
                    console.log('inside first else if else 1');

                    for (var x = 1; x <= 5; x++) {
                        tempList.push(x);
                    }
                    if (tempList.length != 0) {
                        this.paginationList = tempList;
                    }
                }
            }
            setTimeout(() => {
                this.leftDashes = (this.totalPages > this.paginationList[4]) ? true : false;
                this.rightDashes = (1 < this.paginationList[0]) ? true : false;
            }, 100);
        }
        this.hideSpinner();
    }

    parentCheckBox(event) {
        this.displaySpinner();
        const parentBox = this.template.querySelector('[data-id="myCheck"]');
        var childBoxes = this.template.querySelectorAll('.childBox');

        console.log(parentBox);
        console.log(childBoxes);
        var val = parentBox.checked;
        for (var x of childBoxes) {
            if (val == true) {
                x.checked = true;
            } else {
                x.checked = false;
            }
        }
        for (var x of this.recordsForDisplay) {
            if (val == true)
                this.checkedRecords.add(x.Id);
            else
                this.checkedRecords.delete(x.Id);
        }
        this.hideSpinner();
    }

    childCheckBox(event) {
        this.displaySpinner();
        var childBoxes = this.template.querySelectorAll('.childBox');
        var parentBox = this.template.querySelector('[data-id="myCheck"]');
        var tmpList = this.recordsForDisplay;
        var value = event.currentTarget.checked;
        var recId = event.target.dataset.name;
        if (value == true) {
            this.checkedRecords.add(recId);
        } else {
            this.checkedRecords.delete(recId);
        }
        for (var y of childBoxes) {
            if (y.checked == true) {
                parentBox.checked = true;
            } else {
                console.log('unchacked    ->  ' + y.Id);
                parentBox.checked = false;
                break;
            }
        }
        if (this.recordsForDisplay.length == 0) {
            parentBox.checked = false;
        }
        console.log(this.checkedRecords.size);
        this.hideSpinner();
    }

    makeParentChacked() {
        this.displaySpinner();
        console.log('mpc called');
        var records = this.recordsForDisplay;
        var parentBox = this.template.querySelector('[data-id="myCheck"]');
        for (var x of records) {
            if (this.checkedRecords.has(x.Id)) {
                console.log('comes in true');
                parentBox.checked = true;
            } else {
                console.log('comes in false');
                console.log('yet here');
                if (parentBox != null) {
                    parentBox.checked = false;
                }
                console.log('after checked');
                break;
            }
        }
        console.log('after break');
        if (this.recordsForDisplay.length == 0) {
            parentBox.checked = false;
        }
        console.log('hwlop');
        this.hideSpinner();
    }

    makeNumRed() {
        this.displaySpinner();
        var allNums = this.template.querySelectorAll('.numbersOf');
        console.log('mkae in red => ' + this.currentPage + '   length of boxes  =>  ' + allNums.length);

        for (var x of allNums) {
            console.log(x.dataset.id);
            if (x.dataset.id == this.currentPage) {
                console.log('found color changed');
                x.style.color = "red";
            } else {
                x.style.color = "black";
            }
        }
        this.hideSpinner();
    }
}