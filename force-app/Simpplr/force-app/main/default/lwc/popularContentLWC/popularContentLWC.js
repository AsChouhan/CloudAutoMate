import { LightningElement, wire, api, track } from 'lwc';
import getPopularContent from '@salesforce/apex/LightningPopularContentCtrl.getPopularContent';
import getLatestContent from '@salesforce/apex/LightningPopularContentCtrl.getLatestContent';

export default class PopularContentLWC extends LightningElement {

    @api contentType;
    @api siteId;
    @api tileLayout;
    @api contentLabel;
    
    popularContents;
    latestContents;

    // GETTERS
    get contentTypePage() {
        return this.contentType === 'Page';
    }

    get contentTypeEvent() {
        return this.contentType === 'Event';
    }

    get contentTypeBlogPost() {
        return this.contentType === 'BlogPost';
    }

    get contentTypeAll() {
        return this.contentType === 'All';
    }

    get contentTypeAlbum() {
        return this.contentType === 'Album';
    }

    get tileLayoutStandard() {
        return this.tileLayout === 'Standard';
    }

    connectedCallback() {
        this.loadLatestContent();    
        this.loadPopularContent();    
    }

    loadLatestContent() {
        getLatestContent({
            contentType: this.contentType,
            siteId: this.siteId
        }).then(data => {
            this.latestContents = JSON.parse(data);
            this.latestContents.forEach(contWrapObj => {
                contWrapObj.isObjTypePage = contWrapObj.type === 'Page';
                contWrapObj.isObjTypeEvent = contWrapObj.type === 'Event';
                contWrapObj.isObjTypeBlog = contWrapObj.type === 'BlogPost';
                contWrapObj.isObjTypeAlbum = contWrapObj.type === 'Album';
                contWrapObj.createdAt = contWrapObj.createdAt ? contWrapObj.createdAt.split('.')[0] + 'Z' : contWrapObj.createdAt;
            });
        }).catch(error=>{
            console.error(error.message);
        });
    }
    
    loadPopularContent() {
        getPopularContent({
            contentType: this.contentType,
            siteId: this.siteId
        }).then(data => {
            this.popularContents = JSON.parse(data);
            this.popularContents.forEach(contWrapObj => {
                contWrapObj.isObjTypePage = contWrapObj.type === 'Page';
                contWrapObj.isObjTypeEvent = contWrapObj.type === 'Event';
                contWrapObj.isObjTypeBlog = contWrapObj.type === 'BlogPost';
                contWrapObj.isObjTypeAlbum = contWrapObj.type === 'Album';
                contWrapObj.createdAt = contWrapObj.createdAt ? contWrapObj.createdAt.split('.')[0] + 'Z' : contWrapObj.createdAt;
            });
        }).catch(error=>{
            console.error(error.message);
        });
    }

}