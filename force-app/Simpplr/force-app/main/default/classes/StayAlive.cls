public with sharing class StayAlive {
    public transient string textString {get; set;}
    public transient string contentType {get; set;}
    public transient boolean bHTML {get; set;}
    public transient string refreshInterval {get; set;}
    public StayAlive() {
        String cType = SIMPESAPI.encoder().SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('type'));
        String ti = SIMPESAPI.encoder().SFDC_JSENCODE(ApexPages.currentPage().getParameters().get('ti'));
        refreshInterval = String.isNotBlank(ti) ? ti : '840000';
        if(String.isBlank(cType)) {
            cType = '1';
        }
        if(ctYpe == '1') {
            contentType = 'text/plain';
            bHTML = false;
            textString = '1';
        } else {
            contentType = 'text/html';
            bHTML = true;
            textString = '';
        }
    }
}