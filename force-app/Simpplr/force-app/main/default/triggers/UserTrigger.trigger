/**
* @Trigger [Trigger Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
trigger UserTrigger on User (before insert, after insert, after update, after delete, after undelete) {
	try {

			if(SimpplrContext.isATUserEnabled != null && SimpplrContext.isATUserEnabled) {
				
				//Disabled CDC due to mixed DML error
				//ObjectHandler objHandler = new ObjectHandler();
				//objHandler.triggerHandler('User');
				
				if(Trigger.isBefore) {
					if (Trigger.isInsert) {
						if('Do Not Change'.equalsIgnoreCase(SimpplrContext.chatterEmails) == false) {
							
							for(User userObj : Trigger.new) {
								if('Standard'.equalsIgnoreCase(userObj.usertype)) {
									if('Off For All'.equalsIgnoreCase(SimpplrContext.chatterEmails)) {
										userObj.UserPreferencesDisableAllFeedsEmail = true;
									} else if('On For All'.equalsIgnoreCase(SimpplrContext.chatterEmails)) {
										userObj.UserPreferencesDisableAllFeedsEmail = false;
									} else if (String.isNotBlank(SimpplrContext.appConfig.Chatter_Email_Off_Profiles__c) &&
											   SimpplrContext.appConfig.Chatter_Email_Off_Profiles__c.containsIgnoreCase(userObj.profileId)) {
										userObj.UserPreferencesDisableAllFeedsEmail = true;
									}
								}
							}
						}
					}
				}
				if(Trigger.isAfter) {
					if (Trigger.isInsert) {	
						if(!System.isBatch()){
							PeopleDao.insertPeopleInRealtime(Trigger.new);
						}
					}
				}
			}
		
	} catch (Exception ex) {
		//Ignore any exception coming in Trigger
	}
}