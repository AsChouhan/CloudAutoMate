public without sharing class BatchGoogleDriveSync implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private String batchContext;
    private String query; 
    private Boolean runNextBatchInSequence;
    private String groupIdToProcess;
    private Set<String> setOfSiteManagerId = new Set<String>();
    private Exception exceptionDetailsObj;
    private final String BATCH_ADD_GROUP_MEMBER = 'addMembersToGoogleGroup';
    private final String BATCH_REMOVE_GROUP_MEMBER = 'removeMembersFromGoogleGroup';
    private String domainStr; 

    public BatchGoogleDriveSync(String batchContext, Boolean runNextBatchInSequence){
        this.batchContext = batchContext;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }

    public BatchGoogleDriveSync(String batchContext, Boolean runNextBatchInSequence, String groupIdToProcess){
        this.batchContext = batchContext;
        this.runNextBatchInSequence = runNextBatchInSequence;
        this.groupIdToProcess = groupIdToProcess;
    }

    public database.querylocator start(Database.BatchableContext bc) {	
        
        if (BATCH_ADD_GROUP_MEMBER.equalsIgnoreCase(batchContext)) {
            this.domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
            query = ' SELECT id, Group_Id_Set__c, Unsuccessful_Group_Id_Set__c, ' + 
                    ' User__c, User_Email__c FROM People_Integration__c WHERE ' + 
                    ' User__r.IsActive = true AND User_Email__c!=null AND ' + 
                    ' is_deleted__c=false AND name=\'googledrive\'';
            
            List<CollaborationGroupMember> grpMemList = [SELECT memberId, CollaborationRole 
                    FROM CollaborationGroupMember WHERE 
                    CollaborationGroupId =:groupIdToProcess];
            Set<Id> membersOfGrp = new Set<Id>();

            for (CollaborationGroupMember cgmObj: grpMemList) {
                membersOfGrp.add(cgmObj.memberId);

                if ('Admin'.equalsIgnoreCase(cgmObj.CollaborationRole)) {
                    setOfSiteManagerId.add(cgmObj.memberId);
                }
            }

            query += ' AND User__c IN :membersOfGrp';

        } else if (BATCH_REMOVE_GROUP_MEMBER.equalsIgnoreCase(batchContext)) {}

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
        try {

            if (BATCH_ADD_GROUP_MEMBER.equalsIgnoreCase(batchContext) &&  !SimpplrContext.googleManagedPermission) {
                List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)listOfsObject;
                addMembersToGoogleGroup(listOfPeopleInteg);

            } 
        } catch(Exception ex) {
            exceptionDetailsObj =  ex;
    		throw ex;
        }
    }

    public void finish(Database.BatchableContext bc) {

    }

    public void addMembersToGoogleGroup(List<People_Integration__c> listOfPeopleInteg) { 
        List<People_Integration__c> listOfPeopleIntegForAddMember  = new List<People_Integration__c>();
        String chatterGrpId = this.groupIdToProcess;

        for (People_Integration__c peopleIntgObj: listOfPeopleInteg) {
            Set<String> setOfSuccessfulGroupForPeople = new Set<String>();

            if (String.isNotBlank(peopleIntgObj.Group_Id_Set__c)) {
                setOfSuccessfulGroupForPeople = stringToSet(peopleIntgObj.Group_Id_Set__c, ',');
            } 

            if (setOfSuccessfulGroupForPeople.isEmpty() || !setOfSuccessfulGroupForPeople.contains(chatterGrpId)) {
                listOfPeopleIntegForAddMember.add(peopleIntgObj);
            } 

        }
       
        List<GoogleDriveModel.GroupMemberRequest> listOfGrpMemReq = new List<GoogleDriveModel.GroupMemberRequest>();
        
        for (People_Integration__c peopleIntegObj: listOfPeopleIntegForAddMember) {

            // RGroup member will be added only when permisssions are simp managed 
            if (!SimpplrContext.googleManagedPermission) {
                GoogleDriveModel.GroupMemberRequest addRGroupMemberReq = new GoogleDriveModel.GroupMemberRequest();
                String rGroupEmail = chatterGrpId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + this.domainStr;
                addRGroupMemberReq.groupEmail = rGroupEmail;
                addRGroupMemberReq.memberEmail = peopleIntegObj.User_Email__c;
                listOfGrpMemReq.add(addRGroupMemberReq);
            }

            // RWGroup member will be added in both case simp/Google managed 
            if (setOfSiteManagerId.contains(peopleIntegObj.user__c)) {
                GoogleDriveModel.GroupMemberRequest addRWGroupMemberReq = new GoogleDriveModel.GroupMemberRequest();
                String rWGroupEmail = chatterGrpId + GoogleDriveService.READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + this.domainStr;
                addRWGroupMemberReq.groupEmail = rWGroupEmail;
                addRWGroupMemberReq.memberEmail = peopleIntegObj.User_Email__c;
                listOfGrpMemReq.add(addRWGroupMemberReq);
            }

        }
        if(!test.isRunningTest()){
            String resultBody = new GoogleDriveService().addMembersToGroupBulk(listOfGrpMemReq);
        }
    }

    public String setToString(Set<String> strSet, String delimiter) {
        return strSet.size()>0 ? String.join(new List<String>(strSet), delimiter) : '';
    }

    public static Set<String> stringToSet(String inpStr, String delimiter) {
        return String.isNotBlank(inpStr) ? new Set<String>(inpStr.split(delimiter)) : new Set<String>();
    }
}