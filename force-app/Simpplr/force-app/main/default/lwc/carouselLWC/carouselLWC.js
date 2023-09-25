import { LightningElement, wire, api } from 'lwc';
import getCarouselData from '@salesforce/apex/LightningCarouselCtrl.getCarouselData';
export default class CarouselLWC extends LightningElement {
    carouselData;

    connectedCallback() {
        this.loadCarouselData();  
    }
    loadCarouselData() {
        getCarouselData({})
        .then(data => {
            let jsonData = JSON.parse(data);
            jsonData = jsonData.result.listOfItems;
            for (var counter=0; counter < jsonData.length; counter++) {
                jsonData[counter].srNo = counter+1;
                
                if (jsonData[counter].item.imgLandscape == null) {
                    
                    if (jsonData[counter].item.type == 'Page') {
                        jsonData[counter].item.imgLandscape = 'https://static.simpplr.com/lightning-asset/img/carousel_page.png';
                    
                    } else if (jsonData[counter].item.type == 'BlogPost') {
                        jsonData[counter].item.imgLandscape = 'https://static.simpplr.com/lightning-asset/img/carousel_blog.png';
                    
                    } else if (jsonData[counter].item.type == 'Event') { 
                        jsonData[counter].item.imgLandscape =  'https://static.simpplr.com/lightning-asset/img/carousel_event.png';
                    }
                    
                }
            } 
            this.carouselData = jsonData;
        }).catch(error=>{
            console.error(error.message);
        });
    }
}