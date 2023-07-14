import { LightningElement, track } from 'lwc';
import pg from '@salesforce/resourceUrl/pg';
//import Ecard from '@salesforce/resourceUrl/Ecard'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import payByCreditCard from '@salesforce/apex/PaymentGatewayApex.payByAuthrizePayment';
import payByEcheck from '@salesforce/apex/PaymentGatewayApex.payByEcheck';
export default class paymentgateway extends LightningElement {

    pymntGatewayLogo = pg;
    //pymntGatewayLogo = Ecard;
    @track showSpinner = false;
    @track creditCard = true;
    @track eCheck = false;
    ShowECheck() {
        this.creditCard = false;
        this.eCheck = true;
    }
    ShowCard() {
        this.creditCard = true;
        this.eCheck = false;
    }

    monthOptions = [
        {
            value: "01",
            label: "January"
        },
        {
            value: "02",
            label: "February"
        },
        {
            value: "03",
            label: "March"
        },
        {
            value: "04",
            label: "April"
        },
        {
            value: "05",
            label: "May"
        },
        {
            value: "06",
            label: "June"
        },
        {
            value: "07",
            label: "July"
        },
        {
            value: "08",
            label: "August"
        },
        {
            value: "09",
            label: "September"
        },
        {
            value: "10",
            label: "October"
        },
        {
            value: "11",
            label: "November"
        },
        {
            value: "12",
            label: "December"
        }
    ];
    yearOptions = [
        {
            value: "2023",
            label: "2023"
        },
        {
            value: "2024",
            label: "2024"
        },
        {
            value: "2025",
            label: "2025"
        },
        {
            value: "2026",
            label: "2026"
        },
        {
            value: "2027",
            label: "2027"
        },
        {
            value: "2028",
            label: "2028"
        },
        {
            value: "2029",
            label: "2029"
        },
        {
            value: "2030",
            label: "2030"
        }

    ];
    @track cardNumber;
    @track cvv;
    @track cardMonth;
    @track cardYear;
    @track amount;
    @track routingNumber;
    @track accountNumber;
    @track nameOnAccount;
    @track amount = 150;

    handleChange(event) {
        if (event.target.name == 'cardNumber') {
            this.cardNumber = event.detail.value;
        } else if (event.target.name == 'amount') {
            this.amount = event.detail.value;
        } else if (event.target.name == 'month') {
            this.cardMonth = event.detail.value;
        } else if (event.target.name == 'year') {
            this.cardYear = event.detail.value;
        } else if (event.target.name == 'cvv') {
            this.cvv = event.detail.value;
        }
        else if (event.target.name == 'routingNumber') {
            this.routingNumber = event.detail.value;
        } else if (event.target.name == 'accountNumber') {
            this.accountNumber = event.detail.value;
        } else if (event.target.name == 'nameOnAccount') {
            this.nameOnAccount = event.detail.value;
        }
    }

    handlePayment() {
        console.log(this.cardNumber);
        this.handleSpinner();
        payByCreditCard({
            cardNumber: this.cardNumber, amount: this.amount,
            cardMonth: this.cardMonth, cardYear: this.cardYear, cvv: this.cvv
        })
            .then(res => {
                let title = res;
                this.ShowToast('Success!', title, 'success', 'dismissable');
            }).catch(err => {
                this.ShowToast('Error!!', err.body.message, 'error', 'dismissable');
            }).finally(() => {
                this.handleSpinner();
            })
        console.log('end js method');
    }

    handleECheckPayment() {
        console.log(this.routingNumber);
        this.handleSpinner();
        payByEcheck({
            routingNumber: this.routingNumber, accountNumber: this.accountNumber, nameOnAccount: this.nameOnAccount
        })
            .then(res => {
                let title = res;
                this.ShowToast('Success!', title, 'success', 'dismissable');
            }).catch(err => {
                this.ShowToast('Error!!', err.body.message, 'error', 'dismissable');
            }).finally(() => {
                this.handleSpinner();
            })
    }
    handleSpinner() {
        this.showSpinner = !this.showSpinner;
    }
    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}