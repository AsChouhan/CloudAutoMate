public class CommunityLoginApexController {
    @AuraEnabled
    public static string loginCheck(String username,String password,String startUrl){
        try {
            ApexPages.PageReference lgn = Site.login(username,password,startUrl);
            aura.redirect(lgn);
            return 'success';
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }
}