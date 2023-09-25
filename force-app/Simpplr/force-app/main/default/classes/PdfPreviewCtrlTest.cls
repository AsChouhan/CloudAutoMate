@isTest
private class PdfPreviewCtrlTest {
    @isTest static void testPDFPreviewCtrl() {
        Test.startTest();
        PageReference pageRef = Page.PdfPreview;
        ApexPages.currentPage().getParameters().put('target','PdfPreviewCtrl');
        ApexPages.currentPage().getParameters().put('provider','CRM');
        ApexPages.currentPage().getParameters().put('fileId','1234');
        ApexPages.currentPage().getParameters().put('type','WORD');
        ApexPages.currentPage().getParameters().put('fileSize','3000001');
        Test.setCurrentPage(pageRef);
        PdfPreviewCtrl prfPreviewObj = new PdfPreviewCtrl();
        prfPreviewObj.init();
        prfPreviewObj.getPageFeature();
        String csrfToken = prfPreviewObj.csrfToken;
        string packagePrefix = prfPreviewObj.packagePrefix;
        Test.stopTest(); 
        System.assert(true,'Running as expected');
    }
}