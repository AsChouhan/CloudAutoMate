/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SchedulerDao{

	
	private final DateTime currentTime = DateTime.now();
	
    public SchedulerDao() {
    	prepareScheduleJobInfo();
    	prepareJobsMetaInfo();
    }
	
	private List<Object> schedulerClassSettingsList; 
	private Map<String,CronTrigger> scheduleJobsMap;
	
	private List<Simpplr_Metadata__c> listOfSimpplrMetaDataToDelete =  new List<Simpplr_Metadata__c>();
	private Map<String,Map<String,Object>> schedulerClassMap= new Map<String,Map<String,Object>>();
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private void prepareJobsMetaInfo(){
		scheduleJobsMap = new Map<String,CronTrigger>();
		listOfSimpplrMetaDataToDelete  =  new List<Simpplr_Metadata__c>(); 
		Map<String,Simpplr_Metadata__c> jobsMetaMap = new Map<String,Simpplr_Metadata__c>();
		for(Simpplr_Metadata__c meta : [SELECT value__c,type__c 
										FROM Simpplr_Metadata__c 
										WHERE type__c IN : schedulerClassMap.keySet() WITH SECURITY_ENFORCED]){
			if(!String.isBlank(meta.value__c)){
				jobsMetaMap.put(meta.value__c,meta);	
			}											
		}
		Map<Id,CronTrigger> cronJobsMap = new Map<Id,CronTrigger>([select Id,NextFireTime, PreviousFireTime, OwnerId from CronTrigger where id in:jobsMetaMap.keyset()]);
		for(String jobId :jobsMetaMap.keyset()){
			if(cronJobsMap.containsKey(jobId)){
				scheduleJobsMap.put(jobsMetaMap.get(jobId).type__c,cronJobsMap.get(jobId));
			}else{
				listOfSimpplrMetaDataToDelete.add(jobsMetaMap.get(jobId));
			}
		}
		if(listOfSimpplrMetaDataToDelete.size() > 0){
			SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfSimpplrMetaDataToDelete);
		}
		
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private void prepareScheduleJobInfo(){
		try{
			schedulerClassSettingsList = new List<Object>();
			List<Simpplr_Metadata__c> metaList = [SELECT value__c,type__c 
													FROM Simpplr_Metadata__c
													WHERE type__c = :ServiceConstants.SIMPPLR_SCHEDULE_JOB WITH SECURITY_ENFORCED LIMIT 1];
			
			if(metaList.size() > 0 && !String.isBlank(metaList[0].value__c)){
				schedulerClassSettingsList = (List<Object>) JSON.deserializeUntyped(metaList[0].value__c);
				for(Object scheduleMapObject : schedulerClassSettingsList){
					Map<String,Object> scheduleClassMap = (Map<String,Object>)scheduleMapObject;
					schedulerClassMap.put((String)scheduleClassMap.get('name'),scheduleClassMap);
				}
			}
			
		}catch(Exception e){
			
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<SchedulerWrapper.ApexClassWrapper> getApexClassWrapperList(){
		List<SchedulerWrapper.ApexClassWrapper> apexClassWrapperList = new List<SchedulerWrapper.ApexClassWrapper>(); 
		SchedulerWrapper.ApexClassWrapper classWrapper;
		
		//Getting a map of "jobName to Batch class set" map
		Map<String,Set<String>> apexJobNameToClassNamesToBeRunMap = new Map<String,Set<String>>();
		for(Object scheduleMapObject : schedulerClassSettingsList){
			Map<String,Object> scheduleClassMap = (Map<String,Object>)scheduleMapObject;
			Set<String> apexClassSet = new Set<String>();
			for(Object obj : (List<Object>)scheduleClassMap.get('setOfApexClass')){
				apexClassSet.add(String.valueOf(obj));
			}
			apexJobNameToClassNamesToBeRunMap.put((String)(scheduleClassMap.get('name')), apexClassSet);
			
		}
		//Getting Set of all batch jobs to be run
		Set<String> apexClassNamesToBeRun = new Set<String>();
		for(Set<String> batchClassNameSet : apexJobNameToClassNamesToBeRunMap.values()){
			apexClassNamesToBeRun.addAll(batchClassNameSet);
		}
		//getting list of already active batch jobs
		List<AsyncApexJob> runningJobList=[SELECT ApexClass.Name FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClass.Name IN:apexClassNamesToBeRun AND 
											(Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding') WITH SECURITY_ENFORCED];
		
		Set<String> setOfJobsRunning = new Set<String>();
		for(AsyncApexJob job : runningJobList){
			setOfJobsRunning.add(job.ApexClass.Name);
		}
		
		
		for(Object scheduleMapObject : schedulerClassSettingsList){
			Map<String,Object> scheduleClassMap = (Map<String,Object>)scheduleMapObject;
			classWrapper = new SchedulerWrapper.ApexClassWrapper();
			String name = (String)scheduleClassMap.get('name');
			String batchName = (String)scheduleClassMap.get('batchName');
			classWrapper.id=name;
			classWrapper.name = name;
			classWrapper.batchName = batchName;
			classWrapper.isRunning = false;
			if(setOfJobsRunning.isEmpty()){
				classWrapper.isRunning = false;
			} else {
				for(String batchClassName : apexJobNameToClassNamesToBeRunMap.get(name)){
					if(setOfJobsRunning.contains(batchClassName)){
						classWrapper.isRunning = true;
						break;
					}
				}
			}
			classWrapper.isScheduled = scheduleJobsMap.containsKey(name);
			
			if(classWrapper.isScheduled){
				DateTime dateTimeValue = ((CronTrigger)scheduleJobsMap.get(name)).NextFireTime; 
				classWrapper.nextRunAt = dateTimeValue == null ? '' : dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				
				dateTimeValue = ((CronTrigger)scheduleJobsMap.get(name)).PreviousFireTime;
				classWrapper.lastRunAt = dateTimeValue == null ? '' : dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			}
			classWrapper.description = (String)scheduleClassMap.get('description');
			classWrapper.size = (Integer)scheduleClassMap.get('size');
			classWrapper.jsonText = Json.serialize(classWrapper);
			classWrapper.canOperate = false;
			
			if (UserContext.hasModifyAllDataPermission){
				classWrapper.canOperate = true;
			}			
			
			apexClassWrapperList.add(classWrapper);
		}
		return apexClassWrapperList;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public void runSchedulerNow (List<String> listOfJobsToBeRun){
		
		Set<String> apexClassNamesToBeRun = new Set<String>();
		for(String jobName: listOfJobsToBeRun){
			for(Object className : (List<Object>)schedulerClassMap.get(jobName).get('setOfApexClass')){
				apexClassNamesToBeRun.add(String.valueOf(className));
			}
		}
		List<AsyncApexJob> runningJobList=[SELECT ApexClass.Name FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClass.Name IN:apexClassNamesToBeRun AND 
											(Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing' OR Status = 'Holding') WITH SECURITY_ENFORCED];
		if(runningJobList.isEmpty()){
			for(String jobName: listOfJobsToBeRun){
				runBatch(jobName, Integer.valueOf((schedulerClassMap.get(jobName)).get('size')));
			}
		}else{
			throw new SimpplrException('Scheduler is already running');	
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public List<SchedulerWrapper.ApexClassWrapper> scheduleSchedulerNow(List<String> listOfJobsToBeScheduled, Integer size, String cronExp, Boolean killAll){
		
		if(killAll){ //to kill old scheduled jobs.
			for(String jobName: listOfJobsToBeScheduled){
				abort(jobName);
			}
		}
		Map<String, String> mapOfJobIdAndJobName = new Map<String, String>();	
		for(String jobName: listOfJobsToBeScheduled){
			// to override the batch size
			Integer tsize = Integer.valueOf((schedulerClassMap.get(jobName)).get('size'));
			if(size != null && size != 0){
				tsize = size;
			}
			// to override the cron exp
			String tcronexp = (String)(schedulerClassMap.get(jobName).get('cron_exp'));
			if(!String.isBlank(cronExp)){
				tcronexp = cronExp;
			}
			String jobId = run(jobName, tsize, tcronexp);
			mapOfJobIdAndJobName.put(jobId, jobName);
		}
		Map<Id,CronTrigger> cronJobsMap = new Map<Id,CronTrigger>([select Id,NextFireTime, PreviousFireTime from CronTrigger where id in:mapOfJobIdAndJobName.keyset()]);
		List<SchedulerWrapper.ApexClassWrapper> apexClassWrapperList = new List<SchedulerWrapper.ApexClassWrapper>();
		SchedulerWrapper.ApexClassWrapper classWrapper;
		for(String jobId :mapOfJobIdAndJobName.keyset()){
			classWrapper = new SchedulerWrapper.ApexClassWrapper();
			classWrapper.id = mapOfJobIdAndJobName.get(jobId);
			String name = mapOfJobIdAndJobName.get(jobId);
			classWrapper.name = name;
			classWrapper.isRunning=false;
			classWrapper.isScheduled = true;

			DateTime dateTimeValue = ((CronTrigger)cronJobsMap.get(jobId)).NextFireTime; 
			classWrapper.nextRunAt = dateTimeValue == null ? '' : dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			
			dateTimeValue = ((CronTrigger)cronJobsMap.get(jobId)).PreviousFireTime;
			classWrapper.lastRunAt = dateTimeValue == null ? '' : dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			classWrapper.canOperate = true;
			if ('SchedulerAnalytics'.equalsIgnoreCase(name) && !UserContext.hasModifyAllDataPermission){
				classWrapper.canOperate = false;
			}
			
			apexClassWrapperList.add(classWrapper);
		}
		return apexClassWrapperList;
	}

	/**
	 * @description scheduleAllSchedulerNow - schedule all simpplr jobs which are not scheduled yet.
	 */
	public void scheduleAllSchedulerNow() {
		Map<String, Simpplr_Metadata__c> metadataMap = new Map<String, Simpplr_Metadata__c>();
		Set<String> setOfJobsToBeScheduled = schedulerClassMap.keySet();
		setOfJobsToBeScheduled.removeAll(scheduleJobsMap.keySet());
		for(Simpplr_Metadata__c meta : [SELECT Id, Value__c, Type__c, User__c FROM Simpplr_Metadata__c WHERE Type__c IN : setOfJobsToBeScheduled WITH SECURITY_ENFORCED]){
			metadataMap.put(meta.Type__c, meta);
		}
		for(String jobName: setOfJobsToBeScheduled){
			Type t =  Type.forName(jobName);
			SimpplrScheduler sc = (SimpplrScheduler) t.newInstance();
			sc.size = Integer.valueOf((schedulerClassMap.get(jobName)).get('size'));
			sc.CRON_EXP = (String)(schedulerClassMap.get(jobName).get('cron_exp'));

			Id jobId = SimpplrScheduler.scheduleMe(jobName, sc);
			Simpplr_Metadata__c metadataObj = metadataMap.get(jobName);
			if(metadataObj != null){
				metadataObj.value__c = jobId;
			}else{
				metadataObj = new Simpplr_Metadata__c(
					Value__c = jobId,
					User__c = UserContext.id,
					Type__c = jobName
				);
			}
			metadataMap.put(jobName, metadataObj);
		}
		if(!metadataMap.isEmpty()) {
			SIMPESAPI.accessController().upsertAsUser(metadataMap.values(),new List<Schema.SObjectField>{
				Simpplr_Metadata__c.Value__c,
				Simpplr_Metadata__c.User__c,
				Simpplr_Metadata__c.Type__c
			});
		}
	}
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public void clear(List<String> listOfJobsToBeCleared){
		for(String jobName: listOfJobsToBeCleared){
			abort(jobName);
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private Id run(String name, Integer size, String cronExp){
		
		Id jobId;	
		try{
			
			Type t =  Type.forName(name);
			SimpplrScheduler sc = (SimpplrScheduler) t.newInstance();
			sc.size = size;
			sc.CRON_EXP=cronExp;
			jobId = SimpplrScheduler.scheduleMe(name,sc);
			List<Simpplr_Metadata__c> currentClassJobMetaList = [SELECT value__c 
																	FROM Simpplr_Metadata__c
																	WHERE type__c=:name WITH SECURITY_ENFORCED limit 1];
			Simpplr_Metadata__c metadataObj;
			if(currentClassJobMetaList.size() > 0){
				metadataObj = currentClassJobMetaList[0];
				metadataObj.value__c = jobId;
			}else{
				metadataObj = new Simpplr_Metadata__c(
										value__c = jobId,
										User__c = UserContext.id,
										type__c = name);
			}
			
			List<Schema.SObjectField> fieldListForUpsert = new List<Schema.SObjectField> {
				Simpplr_Metadata__c.value__c,
				Simpplr_Metadata__c.User__c,
				Simpplr_Metadata__c.type__c
			};
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().upsertAsUser(new List<Simpplr_Metadata__c>{metadataObj},fieldListForUpsert);
		}catch(Exception e){
			
		}
		return jobId;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private void runBatch(String name, Integer size){
		try{
			Type t =  Type.forName(name);
			SimpplrScheduler sc = (SimpplrScheduler) t.newInstance();
			sc.size = size;
			sc.execute(null);
		} catch (NullPointerException ex){
			
		}
		catch(Exception e){
			
		}
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	private void abort(String name){
		List<Simpplr_Metadata__c> listToDelete = new List<Simpplr_Metadata__c>();
		List<Simpplr_Metadata__c> metadataObjList = [SELECT value__c
													FROM Simpplr_Metadata__c
													WHERE type__c =:name WITH SECURITY_ENFORCED];
		for(Simpplr_Metadata__c jobMeta : metadataObjList){
			try{
				system.abortJob(jobMeta.value__c);
				listToDelete.add(jobMeta);
			}catch(Exception e){
				
			}
			if(listToDelete.size() > 0){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(listToDelete);
			}
		}														
	}

	/**
	 * @description abortNonServiceAccountScheduledJob - abort scheduled jobs which are not scheduled by user
	 * @param serviceAccUserId
	 */
	public void abortNonServiceAccountScheduledJob(String serviceAccUserId) {
		Boolean isSchedulerAborted = false;
		for(CronTrigger cronJob : scheduleJobsMap.values()) {
			if(cronJob.OwnerId != serviceAccUserId) {
				system.abortJob(cronJob.Id);
				isSchedulerAborted = true;
			}
		}
		if(isSchedulerAborted) {
			prepareJobsMetaInfo();
		}
	}
}