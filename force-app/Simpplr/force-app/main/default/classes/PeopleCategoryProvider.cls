public with sharing class PeopleCategoryProvider {
    public static List<PeopleCategoryListingWrapper> getPeopleCategory(PeopleCategoryListingWrapper.PeopleCategory peopleCategoryCriteriaObjArg){
        List <PeopleCategoryListingWrapper> listOfPeopleCategory = new List <PeopleCategoryListingWrapper>();
        List <People_Category__c> listOfPeopleCategoryQuery;
        Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
        Integer offset = peopleCategoryCriteriaObjArg.offset;
        PeopleCategoryDao peoplecategoryDaoObj = new PeopleCategoryDao();
        listOfPeopleCategoryQuery = peoplecategoryDaoObj.getPeopleCategory(offset, recordLimit, peopleCategoryCriteriaObjArg.term, peopleCategoryCriteriaObjArg.sortBy);
        for (People_Category__c listOfPeopleCat : listOfPeopleCategoryQuery) {
        		PeopleCategoryListingWrapper PeopleCategoryObj = new PeopleCategoryListingWrapper();
    			PeopleCategoryObj.id = listOfPeopleCat.Id;
    			PeopleCategoryObj.name = listOfPeopleCat.Name__c;
    			PeopleCategoryObj.userCount = listOfPeopleCat.Simpplr_People__r.size();
    			listOfPeopleCategory.add(PeopleCategoryObj);
		}
		
        return listOfPeopleCategory;
    }
}