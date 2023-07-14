public class CommunityHomePageClass {
	@AuraEnabled
    public static sObject getUserInfo(){
        sObject sc = [select name, email from user where Id= :userInfo.getUserId()];
        return sc;
    }
}