public with sharing virtual class SimpplrScheduler implements Schedulable {
	
	public String CRON_EXP{get;set;}
	public Integer size{get;set;}
	
	
	public static String scheduleMe(String jobName, SimpplrScheduler classObj) {
		return System.schedule(jobName, classObj.CRON_EXP, classObj);
    }
    
	public virtual void execute(SchedulableContext  sc){ 
	
	}
}